# BHYH 当前候选迭代

> **状态**：**Phase 22、Phase 23 已完成并归档**（2026-11-03）；**Phase 24 已完成**（24-0 面板契约盘点、24-1 `PetAttributePages` 拆分、24-2 `CoopPanelHost` 宿主分离、24-3 阵法升级命令、24-4 阶段验收）；**Phase 25-0 行为与验证映射、Phase 25-1 自动战斗控制器已完成**，25-2~25-5 未启动；Phase 26 已规划。
> **版本**：6.9；不改变玩法数值、动画时序、输入映射、存档格式或显示基线。
> **当前基线**：[`global_runtime_inventory.md`](../reference/global_runtime_inventory.md)（Phase 22-1）、[`architecture.md`](../reference/architecture.md)、[`status.md`](../reference/status.md)、[`acceptance.md`](../reference/acceptance.md)。
> **编号说明**：Phase 22~26 为本轮新增候选，承接 Phase 21；已归档的 Phase 30~33 不重开，也不把历史归档改写成新计划。

---

## 1. 已完成阶段（归档）

- **Phase 22 Global 状态与入口契约**：已完成并归档；详细批次、字段迁移与验证记录见 [`iteration_22_global_state_boundary.md`](../archive/iteration_22_global_state_boundary.md)。
- **Phase 23 关卡、宠物与档案数据边界**：已完成并关闭；八族生成只经 `PetLevelController`，`PlayerData` 宠物域只读 View/命令已建立；详细批次见 [`iteration_23_pet_domain_boundary.md`](../archive/iteration_23_pet_domain_boundary.md)，当前调用面见 [`pet_level_boundary_matrix.md`](../reference/pet_level_boundary_matrix.md) 与 [`pet_domain_contract.md`](../reference/pet_domain_contract.md)。

---

## 2. Phase 24：UI 与成长命令边界

**目标**：让面板成为“显式操作者 + 数据视图 + 命令”的界面层，成长操作统一为可回滚命令；不重做整套 UI。
**前置**：Phase 23 的宠物生成与宠物域视图至少完成首批；否则先处理 Phase 23。
**非目标**：不换 Theme、不改布局/显示基线、不启用全局 Theme、不一次性重写全部面板。

### 24-0 面板契约清单（已完成）

- 产出 [`ui_panel_contract_matrix.md`](../reference/ui_panel_contract_matrix.md)：`LocalCoop` 五个入口、`pet_interface` 子区域、LDL 成长面板与只读信息面板；
- 盘点结果：面板显式操作者由 `LocalCoop.data_for/props_for` 解析；`hud_panel_boundary` 已在 24-4 扩展为面板目录扫描并识别 `_data()`/嵌套修改/槽位档案别名写档；旧路径按 [`ui_panel_contract_matrix.md`](../reference/ui_panel_contract_matrix.md) §4.3 登记；
- 已具备回滚的路径：宠物出战/休息/成长果、LDL 强化/神铸/淬骨/合成/打造、主动技能升级；
- 待命令化：宠物被动/技能/装备/批量出售、法宝强化、LDL 分解/镶嵌/一键合成、背包昵称与坐骑培养；宠物阵法已在 24-3 完成；
- **24-1 首个拆分对象**：`PetAttributePages`（只读属性区域，无保存副作用）；
- **24-3 首个成长命令**：宠物阵法升级（已于 24-3 命令化；此前为 `_data()["宠物阵法等级"]` 直写、材料先扣、保存失败不回滚）；
- 本批次只改文档，未修改 `source/`。

### 24-1 `pet_interface` 分段拆分（已完成）

- 新增 `pet_attribute_pages.gd` 并挂到既有 `PetAttributePages` 节点：子控制器持有 2 页定义、10 行绑定、分页按钮与显示文本；
- 父面板只注入分页按钮和显示值 `Callable`，保留当前宠物、装备加成、数值计算与页面协调；子控制器不读取 `PlayerData`、不保存、不写档；
- 删除父面板的 `pet_attribute_page`、行/标签/按钮数组及旧分页回调，保留 `_refresh_pet_attribute_page` 作为委托入口；
- 未改布局、Theme、数值规则或存档格式；`PetAttributePages` 节点仍使用原场景行与按钮；
- 验证：`check_all --godot-bin` **9/9**（32.39s）、`health_check` **775 脚本 0/0/0**、`archive` **332/332**（11.02s，含控制器、真实按钮切页与显示值）、`scene` **17/17**（166.43s）、`coop` **33/33**（196.98s，含 2P 宠物面板操作者与切页）、全量 **128/128 + SKIP 5**（311.1s，无重试）。

### 24-2 `CoopPanelHost` 宿主分离（已完成）

- 新增普通节点 `CoopPanelHost`，由 `LocalCoop` 持有；`PANEL_PATHS`、面板实例/图层、窗口栈、暂停、1P/2P 选择器、场景按钮、关闭保存与本地清理迁入宿主；
- `LocalCoop` 只保留槽位、共享账本、输入会话、`slot_for`/`data_for`/`props_for` 与 `ui_slot` 状态；`backpack.gd`、`map_0.gd` 与探针全部改走 `LocalCoop.panel_host`；
- 关闭仍经 `coop_panel_close` 保存；`on_scene_changed`/`clear` 释放面板、图层、会话按钮与悬停弹层，并恢复暂停/窗口栈；全局临时 UI 仍由 `UiRuntime`/`SceneFlow` 持有；
- 新增 `shared_ledger` 门禁的宿主文件约束：`coop_panel_host.gd` 必须保留 `open_panel` 快照互斥，`local_coop.gd` 只校验共享账本；
- 验证：`check_all --godot-bin` **9/9**（34.77s）、`health_check` **776 脚本 0/0/0**、`archive` **332/332**（11.06s）、`scene` **17/17**（157.58s）、`coop` **33/33**（182.96s，含宿主节点/无旧入口、P2 面板操作者、1P/2P 选择器、切页、快照互斥与 `clear` 清理）、全量 **128/128 + SKIP 5**（308.8s，无重试）。

### 24-3 成长命令试点（已完成）

- `PetDomainCommand.upgrade_formation(profile, stat_name, requested_count, save_request)` 校验等级与材料，按可负担级数计算总消耗；
- 一次快照后扣材料、写入 `宠物阵法等级`，调用 `MemoryClass.request_save_result("pet_formation", false)`；保存失败恢复完整档案；
- 双人会话以 1P 档案快照覆盖 1P/2P 与共享道具、灵魂，2P 操作失败同样恢复共享容器；
- `PetFormationPopup` 只读规则与材料计数并显示命令结果，阵法路径不再写 `_data()`；升十级改为一次命令提交；
- 验证：`archive` **344/344**（10.54s，含 1P/2P 成功、失败整批回滚、材料/灵魂恢复与单次保存）、`check_all` **9/9**（28.51s）、`health_check` **776 脚本 0/0/0**、`scene` **17/17**（167.51s）、`coop` **33/33**（191.91s）、`level_1` **4 阶段 PASS**（24.95s，0/0/0）、全量 **128/128 + SKIP 5**（311.4s，无重试）。

### 24-4 阶段验收（已完成）

- 确认 24-1 子区域拆分与 24-3 成长命令已接入；面板关闭/暂停/窗口栈与快照互斥沿用 24-2 结果；
- `hud_panel_boundary` 扩展到 `Script/back_pack/`、`Script/skill/`、`Script/ldl/` 与显式 HUD 文件，识别 `PlayerData.player_data`、`_data()`、`data_for(_slot)(...).player_data` 的赋值、嵌套访问修改、列表/字典变更和局部别名；
- 旧路径按 [`ui_panel_contract_matrix.md`](../reference/ui_panel_contract_matrix.md) §4.3 登记：11 个文件整文件例外 + `pet_interface` 7 行、`synthesis` 3 行、`coop_backpack` 2 行逐行例外；档案 IO 不豁免；
- 验证：`contract_scan --self-test` HUD **14 坏 / 13 好 PASS**，`check_all` **9/9**（33.99s），`archive` **344/344**（10.47s），`scene` **17/17**（170.36s），`coop` **33/33**（199.88s），`level_1` **4 阶段 PASS**（24.95s，0/0/0），全量 **128/128 + SKIP 5**（305.8s，无重试）；
- Phase 24 出口：至少一个面板子区域与一个成长域完成命令化；未登记的新增直接/间接写档由门禁拦截；已登记旧路径有明确文件/行与迁移说明。

---

## 3. Phase 25：战斗实体行为切片

**目标**：在不改变战斗数值与时序的前提下，把 `BaseHero`/`BaseMonster` 中可独立生命周期的行为移出。
**前置**：Phase 22 的伤害/状态所有权稳定；建议在 Phase 24 之后再启动，避免 UI 与实体同时迁移。
**非目标**：不引入 ECS、不重排继承、不一次性拆完 `BaseHero`/`BaseMonster`、不改碰撞层与动作时序。

### 25-0 行为与验证映射（已完成）

- 产出 [`combat_behavior_matrix.md`](../reference/combat_behavior_matrix.md)：`BaseHero` 自动战斗的状态/输入/生命周期/失败路径、`BaseMonster` 受击反应/控制免疫/Boss 保护/死亡映射、现有探针覆盖与缺口；
- 首批选择 **自动战斗**：6 个 `_auto_battle_*` 字段、20 个 `_auto_battle*` 方法，目标/技能/移动可由显式上下文迁出；受击反应有 37 个 `state_hurt` 文件（含基类与覆写）和 3 个 `play_hit_effect` 文件，保留到 25-4；
- 记录必须保持的现状：1P/2P 共用运行时开关、按 `coop_slot` 读技能配置、自动重试归 `BaseThroughLevel`/胜利/失败/玲珑塔、手动 `is_t_mc` 与法宝输入仍可能绕过自动分支；
- 现有 `coop`/`scene`/全量回归没有直接驱动自动战斗或受击代次的探针；25-1 已补 `LocalCoopAutoBattleProbe`，25-4 仍需受击代次探针；
- 本批次未修改 `source/`，未改变数值/时序/输入映射。

### 25-1 自动战斗控制器（已完成）

- 新增 `Script/base/auto_battle_context.gd`：显式开关/配置/目标/技能/冷却/MP/动作/移动查询与受控命令，不持有节拍或游标；
- 新增 `Script/base/auto_battle_controller.gd`：接管目标缓存/筛选、技能游标/计数、0.22s 节拍、移动/朝向/障碍跳跃，以及自动法宝→剑阵→无双调用顺序；
- `BaseHero` 删除 6 个自动战斗字段与 20 个旧方法，保留实体根、`get_skill`/`use_fb`/`ws_skill`、`is_auto_battle_target_valid` 与 `is_auto_battle_skill_active` 钩子；角色 3/4/哪吒覆写改为公开钩子，玉兔索敌改走公开目标校验；
- `LocalCoopAutoBattleProbe` 覆盖 P1/P2 槽位配置、目标缓存/移动、真实 `slz` 起手与计数、无双短路、关闭清理、暂停、死亡、场景退出；
- 未改数值/动作时序/输入映射/碰撞层；障碍跳跃、自动重试转场与手动输入冲突仍留待后续验证。

### 25-2 法宝/时装/翅膀表现切片

- 只迁移有独立生命周期的实例状态与播放协调；
- 保留 `BaseMagicWeapon` 与装备/法宝命令边界；不把表现状态写回共享资源；
- 验证法宝切换、冷却、死亡清理与双人槽位归属。

### 25-3 `BaseMonster` Boss 保护与掉落

- 把 Boss 保护/白条状态与掉落结算从主 AI/受击循环中分离；
- 保持阶段、死亡结算和奖励单一提交；
- 验证 Boss 阶段、控制免疫、掉落、重战与重复结算。

### 25-4 受击与来源归属加固

- 统一受击反应状态、来源快照与池化重置；
- 不默认 1P；无来源时保持零伤害语义；
- 验证双人、召唤物、弹体、法宝与延迟回调。

### 25-5 阶段验收

- 相关关卡、`coop_probe_runner`、战斗/场景探针与全量回归；
- 出口：至少两个行为切片独立，且战斗结果与现有基线一致。

---

## 4. Phase 26：平台与发布验证

**目标**：把“路径闭包”“release 启动”“目标设备性能”“Spine 平台支持”分别证明。
**前置**：可与 Phase 23~25 并行做只读规划；涉及资源/导出变化时再与当前代码批次协调。
**非目标**：不把未验证平台写成支持，不用 PCK 可达替代 release，不用 headless 替代 HUD/VRAM。

### 26-0 平台支持矩阵

- 明确当前承诺平台、未验证平台与退出条件；
- 记录设备、OS、渲染后端、Spine 库、导出模板与许可证；
- Windows x86_64 先行；其它平台保持“延期/未验证”。

### 26-1 Windows release 启动与最小包

- 构建 release，验证冷启动、主菜单、存档列表、`level_1` 进入与退出；
- 区分离线验证包与最小发布包；记录实际包路径闭包与缺失资源；
- 失败必须显式，不以“全资源包可运行”替代发布结论。

### 26-2 目标设备性能

- 在目标设备记录首帧、战斗峰值 VRAM、加载时长、重复进出与退出；
- 至少覆盖一场战斗、一个 Boss、一次返回/重战；
- 结论写入 `status.md`，带设备、日期与未验证范围。

### 26-3 Spine 平台决策

- 复核 Windows 之外是否需要 Spine 扩展；没有设备/许可证/导出证据时保持延期；
- 不把 `.gdextension` 声明文件当作运行库已入库。

### 26-4 阶段验收

- 平台矩阵、release 启动记录、设备性能证据与发布包结论；
- 出口：支持平台有证据，未支持平台有明确原因；不新增未经证实的兼容承诺。

---

## 5. 跨阶段纪律

1. **一个批次一个所有权边界**：迁移全部生产调用方，删除旧实现；回滚用版本控制，不用永久双实现。
2. **不新增 Autoload、不新增 `Global` 业务字段、不新增 `add` 系门面**；新增能力先证明普通节点/`RefCounted`/`Resource`/静态工具不足。
3. **定义与实例分离**：静态定义走 Resource/Catalog；玩家档案保持加密 JSON、`DataKeys` 与 `ensure_*`；不整体 Resource 化。
4. **不搬目录**：保留 `Scene`/`Script`/`Art` 类型顶层；功能在内部聚合；路径迁移走 `rename_path.py`。
5. **失败显式**：缺资源、无来源、保存失败、加载失败、过期回调必须报告给拥有者；不默认 1P、不猜旧路径、不静默成功。
6. **验收按变更矩阵**：静态门禁、相关探针、生产路径冒烟、全量回归、release/性能分别取证；不新增只验证 wiring 的永久测试。
7. **文档同步**：每批完成后更新 `architecture.md`、`status.md`、对应矩阵与 `global_runtime_inventory.md`；归档只在阶段结束后进行。

---

## 6. 当前恢复入口

**当前下一步**：**Phase 25-2 法宝/时装/翅膀表现切片**；Phase 24 已完成，25-0/25-1 已完成。
**当前不启动**：Phase 26。
**23-0/23-1/23-2 产物**：[`pet_level_boundary_matrix.md`](../reference/pet_level_boundary_matrix.md)；**23-4/23-5 产物**：[`pet_domain_contract.md`](../reference/pet_domain_contract.md)、[`status.md`](../reference/status.md)；**24-0/24-1/24-2/24-3/24-4 产物**：[`ui_panel_contract_matrix.md`](../reference/ui_panel_contract_matrix.md)、`PetAttributePages` 子控制器、`CoopPanelHost`、`PetDomainCommand.upgrade_formation`、`hud_panel_boundary` 间接写档守卫；**25-0/25-1 产物**：[`combat_behavior_matrix.md`](../reference/combat_behavior_matrix.md)、`AutoBattleContext`、`AutoBattleController`、`LocalCoopAutoBattleProbe`

- 当前架构：[`architecture.md`](../reference/architecture.md)
- Global 清单：[`global_runtime_inventory.md`](../reference/global_runtime_inventory.md)
- 验收标准：[`acceptance.md`](../reference/acceptance.md)
- 当前状态：[`status.md`](../reference/status.md)
- 长期路线：[`roadmap.md`](roadmap.md)
- 已归档程序记录：[`program_21_33_closeout.md`](../archive/program_21_33_closeout.md)
