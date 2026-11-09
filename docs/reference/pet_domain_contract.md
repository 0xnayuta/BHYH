# PlayerData 宠物域只读视图与命令契约

> **状态**：Phase 23-4 已完成；Phase 23-5 阶段验收通过（2026-11-03）；Phase 24-3 阵法升级命令已完成（2026-11-03）；Phase 28-3 宠物被动升级命令与共享数值表已完成（2026-11-09）。八族宠物规则与 `PetLevelController` 生成入口已完成；本页定义 `PlayerData` 宠物域的首个稳定读取/提交边界。
> **范围**：`PlayerDataStore` 的 `宠物列表` / `出战宠物` 读取、出战/休息、成长提交、阵法升级及保存失败回滚。
> **非目标**：不整体 Resource 化 `PlayerData`，不重写存档格式、宠物补全、八族数值/进化规则或 UI 布局。

---

## 1. 职责边界

| 层 | 职责 | 不负责 |
|:---|:---|:---|
| `PlayerDataStore` | 档案加载、补全、`ensure_pet_*`、快照/恢复、保存聚合 | 不提供可写宠物字典给 UI |
| `PetDomainView` | 绑定显式 `PlayerDataStore`，返回副本/标量 | 不保存、不补全、不修改 |
| `PetDomainCommand` | 显式出战/休息/成长/阵法/被动升级提交，失败回滚 | 不加载档案、不决定 UI 文案与场景切换 |
| `PetLevelController` + `Pet*Family` | 关卡生成生命周期与族规则 | 不直接拥有 UI 选择状态 |

View 显式接收 `PlayerDataStore`，不回落 `/root/PlayerData`；命令只修改调用方显式传入的档案。双人共享回滚快照以 1P 档案为根捕获 1P/2P 与共享容器，仅用于失败恢复，不用于选择操作目标。

## 2. 只读 View

`source/Script/pet/pet_domain_view.gd`：

```gdscript
var view := PlayerData.pet_domain_view()
view.is_valid()
view.is_empty()
view.pet_count()
view.active_name()
view.active_index()
view.active_pet()        # 副本
view.pets()              # 深副本
view.pet_at(index)       # 副本
view.find_index(name)
view.is_deployed(index)
```

- `pets()`、`pet_at()`、`active_pet()` 均返回副本；修改副本不影响档案。
- `active_index()` 按规范类型/别名/显示名解析 `出战宠物`；无匹配返回 `-1`。
- 空档案、无效 `PlayerDataStore` 返回空列表/空字典/`-1`，不抛错。
- `PlayerDataStore.pet_domain_view()` 是唯一创建入口；View 不成为 Autoload。

## 3. 显式命令

`source/Script/pet/pet_domain_command.gd`：

| 命令 | 语义 | 保存 reason | 失败 |
|:---|:---|:---|:---|
| `deploy(profile, index, active_name)` | 清其他 `出战`，设目标 `出战` 与规范活跃名 | `pet_deploy` | 快照恢复；数据/名称为空返回失败 |
| `rest(profile, index)` | 清目标 `出战`；若为当前活跃宠物，清活跃名 | `pet_rest` | 快照恢复；无变化不保存 |
| `commit_growth(profile, index, apply, reason)` | 快照 → 调用成长回调 → 保存 | 默认 `pet_growth` | 回调返回 `false`/失败字典或保存失败时恢复快照 |
| `upgrade_formation(profile, stat_name, requested_count, save_request)` | 校验等级/材料，按可负担级数一次扣材料、升级并保存 | `pet_formation` | 材料/等级校验失败不扣费；保存失败恢复完整档案 |
| `upgrade_passive(profile, pet_index, skill_name, save_request)` | 校验上限/灵魂，快照后扣费、写等级并保存 | `pet_passive_upgrade` | 满级/灵魂不足不扣费；保存失败恢复等级与共享灵魂 |
| `upgrade_all_passives(profile, pet_index, save_request)` | 按可负担级数一次扣费、一次保存 | `pet_passive_upgrade_all` | 无可升级返回失败；保存失败整批恢复 |

- 阵法规则表、等级上限与费用公式由 `PetDomainCommand` 持有；`PetFormationPopup` 只读规则与结果，不再写 `_data()`。
- 阵法命令通过 `MemoryClass.request_save_result` 获取结构化保存结果；`save_request` 仅供探针注入 `bool` 或结果字典。
- 双人会话中阵法快照以 1P 档案为根，覆盖 1P/2P 与共享道具、灵魂；2P 操作失败同样整批恢复。

- 命令使用 `PlayerDataStore.snapshot_state()` / `restore_state()` 或共享回滚快照，保存由 `MemoryClass.request_save`/`request_save_result` 聚合。
- `deploy` 的 `active_name` 必须是 `Pet*Family.KIND` 规范名；UI 在调用前完成族归一化/进化。
- 同一命令无状态变化（如重复出战同一宠物）返回 `changed=false`，不重复保存。
- `save_request` 参数仅供探针注入保存结果；生产调用使用默认 `MemoryClass` 路径。

## 4. 调用面

| 入口 | 使用 | 结果 |
|:---|:---|:---|
| `PetInterface._refresh_pet_name_list` | `PlayerData.pet_domain_view()` | 列表只读副本，不直接读档案数组 |
| `PetInterface.fight_click` | `PetDomainCommand.deploy` | 出战与保存一次提交 |
| `PetInterface.rest_click` | `PetDomainCommand.rest` | 休息与活跃名清理一次提交 |
| `PetInterface._on_develop_fruit_pressed` | `PetDomainCommand.commit_growth` | 消耗成长果 + 属性增长 + 保存原子提交 |
| `PetInterface._upgrade_pet_formation_once` | `PetDomainCommand.upgrade_formation` | 阵法材料、等级与保存一次提交；UI 只刷新显示 |
| `PetInterface._upgrade_pet_passive` | `PetDomainCommand.upgrade_passive` | 单次被动升级；成功刷新活体，失败提示命令原因 |
| `PetInterface._on_pet_passive_one_key_upgrade_pressed` | `PetDomainCommand.upgrade_all_passives` | 一键被动升级；成功刷新活体 |

未迁移：`PlayerData` 的 `ensure_pet_*` 补全仍保留；八族 `normalize_spawn/evolve` 的档案写入仍由显式族规则负责，不在本页扩张。

## 5. 失败与验证

- View 副本测试：修改 `pets()` / `pet_at()` 返回值不改变档案。
- 出战/休息：保存成功 reason 分别为 `pet_deploy` / `pet_rest`；重复出战不额外保存。
- 成长：保存失败恢复经验/等级；回调返回 `false` 不保存并恢复。
- UI 接入：`fight_click`、`rest_click`、成长果路径分别产生 `pet_deploy`、`pet_rest`、`pet_growth`。
- 阵法：保存成功 reason 为 `pet_formation`；材料不足/满级不保存、不扣费；保存失败恢复等级、材料、共享道具与共享灵魂。
- 阵法 UI：`_upgrade_pet_formation_once` 经命令提交；1 级与 10 级均只保存一次，10 级按可负担级数升级。
- 探针：`archive_persistence_probe` **344/344 PASS**（10.54s，含 1P/2P 阵法命令与回滚）；`check_all --godot-bin` **9/9 PASS**（28.51s）；`coop_probe_runner` **33/33 PASS**（191.91s）；`scene_probe_runner` **17/17 PASS**（167.51s）；`level_1` 4 阶段 PASS（24.95s）；全量 **128/128 + 5 SKIP**（311.4s，无重试）。
- 宠物被动（Phase 28-3）：单次/一键升级保存成功后等级与灵魂按预期变化；`save_request` 注入失败时 `restore_state()` 恢复宠物等级与共享灵魂；满级/灵魂不足不扣费、不保存；成功后刷新当前槽位活体宠物。

## 6. 后续

- Phase 24-3 已完成：阵法规则与升级命令进入 `PetDomainCommand`，UI 阵法路径不再写 `_data()`；1P/2P 保存失败均整批恢复；
- Phase 28-3 已完成：宠物被动升级进入 `PetDomainCommand`，保存失败恢复等级与共享灵魂；玩家/宠物共用 `PassiveSkillTable`；宠物被动键收敛到 `DataKeys.Skill.PASSIVE_*`；`contract_scan` 新增 `pet_passive_boundary`。
- 不把本页 View/命令当作全部宠物写入面的迁移完成证明；`PlayerData` 的载入补全与族内写入仍按现有 owner 边界保留；
- 下一入口为 Phase 24-4 阶段验收。
