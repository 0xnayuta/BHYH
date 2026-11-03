# PlayerData 宠物域只读视图与命令契约

> **状态**：Phase 23-4 已完成；Phase 23-5 阶段验收通过（2026-11-03）。八族宠物规则与 `PetLevelController` 生成入口已完成；本页定义 `PlayerData` 宠物域的首个稳定读取/提交边界。
> **范围**：`PlayerDataStore` 的 `宠物列表` / `出战宠物` 读取、出战/休息、成长提交及保存失败回滚。
> **非目标**：不整体 Resource 化 `PlayerData`，不重写存档格式、宠物补全、八族数值/进化规则或 UI 布局。

---

## 1. 职责边界

| 层 | 职责 | 不负责 |
|:---|:---|:---|
| `PlayerDataStore` | 档案加载、补全、`ensure_pet_*`、快照/恢复、保存聚合 | 不提供可写宠物字典给 UI |
| `PetDomainView` | 绑定显式 `PlayerDataStore`，返回副本/标量 | 不保存、不补全、不修改 |
| `PetDomainCommand` | 显式出战/休息/成长提交，失败回滚 | 不加载档案、不决定 UI 文案与场景切换 |
| `PetLevelController` + `Pet*Family` | 关卡生成生命周期与族规则 | 不直接拥有 UI 选择状态 |

View 和命令均显式接收 `PlayerDataStore`，不回落 `/root/PlayerData`；1P/2P 由调用方持有档案决定。

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

- 命令使用 `PlayerDataStore.snapshot_state()` / `restore_state()`，保存仍由 `MemoryClass.request_save` 聚合。
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

未迁移：`PlayerData` 的 `ensure_pet_*` 补全仍保留；八族 `normalize_spawn/evolve` 的档案写入仍由显式族规则负责，不在本页扩张。

## 5. 失败与验证

- View 副本测试：修改 `pets()` / `pet_at()` 返回值不改变档案。
- 出战/休息：保存成功 reason 分别为 `pet_deploy` / `pet_rest`；重复出战不额外保存。
- 成长：保存失败恢复经验/等级；回调返回 `false` 不保存并恢复。
- UI 接入：`fight_click`、`rest_click`、成长果路径分别产生 `pet_deploy`、`pet_rest`、`pet_growth`。
- 探针：`archive_persistence_probe` **328/328 PASS**（11.20s）；`check_all --godot-bin` **9/9 PASS**（33.45s）；`coop_probe_runner` **33/33 PASS**（176.83s）；`scene_probe_runner` **17/17 PASS**（153.51s）；`level_1` PASS；全量 **128/128 + 5 SKIP**（300.7s，无重试）。

## 6. 后续

- Phase 23-5 已完成：`pet-runtime`、场景 17/17、协作 33/33、档案 328/328、`level_1` 与全量 128/128 + 5 SKIP 均通过；
- 不把本页 View/命令当作全部宠物写入面的迁移完成证明；`PlayerData` 的载入补全与族内写入仍按现有 owner 边界保留；
- 下一入口为 Phase 24-0 面板契约清单。
