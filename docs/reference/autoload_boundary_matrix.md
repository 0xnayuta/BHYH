# Autoload 与 Global 边界（当前）

> **状态**：Phase 20-1B 已完成并归档；本页只登记当前注册项与边界规则。完整决策、迁移批次和量化基线见 [`../archive/iteration_20_autoload_boundary_matrix.md`](../archive/iteration_20_autoload_boundary_matrix.md)。

## 1. 当前注册项

`source/project.godot` 当前有 **11 个注册项**：10 个业务单例 + 1 个编辑器调试桥。

| # | Autoload | 当前职责 | 决策 |
|:---:|:---|:---|:---|
| 1 | `RoleProp` | `BaseRoleProperties` 单例形态与启动回退 | 保留，延期迁移 |
| 2 | `PlayerData` | 1P 档案数据仓库与补全 | 保留；新代码走槽位/上下文 |
| 3 | `MemoryClass` | 本地存档、后台保存、设置文件 | 保留（持久化边界） |
| 4 | `MainSet` | 设置字典、帧率、主菜单背景 | 保留（设置） |
| 5 | `MLdl` | 锻造台 UI 会话状态 | 迁移候选（场景状态） |
| 6 | `PaSkill` | 被动技能数值与灵魂收益 | 保留（被动数值） |
| 7 | `Signals` | 全局确认框信号 | 保留；禁止新增全局信号 |
| 8 | `Global` | 场景流、工厂、缓存/池/预载入口 | 拆分边界；不得继续扩张 |
| 9 | `LocalCoop` | 双人会话、槽位数据/属性/输入/面板 | 保留（双人会话） |
| 10 | `MCPGameBridge` | 编辑器调试桥 | 保留；不计业务 |
| 11 | `ZmwsConfig` | ZMWS 数值配置表查询与缓存 | 保留（配置查询） |

已删除：`BaseHit`、`MainMusic`、`AE`。旧 `all_equipment.gd` 与 `all_equipment_data.gd` 不再存在。

## 2. 边界规则

1. 不设 Autoload 数量目标；新增、合并、删除必须评审调用面、初始化顺序、生命周期与回归。
2. 新职责优先使用 `Resource`、`RefCounted`、静态 `class_name` 工具或场景节点；不以“方便访问”新增单例。
3. `Global` 只保留组合根与稳定公开入口；新业务状态不得回流。`contract_scan.py` 的 `global_surface_boundary` 以 `scripts/global_surface_baseline.json` 冻结当前 65 字段与 120 个 `add` 入口；新增项必须先评审并更新基线。
4. 业务访问角色/档案时使用 `BaseObject`/`BaseRole` 注入属性或 `LocalCoop.data_for/props_for`，不假定 1P。
5. 已删除的旧入口不得恢复为兼容 facade；调用方迁移完成后删除旧路径。
6. 调试桥在 release 中不承担业务职责；编辑器调试门控与导出行为单独验证。

## 3. 运行时服务

`RuntimeDiagnostics`、`UiRuntime`、`AudioRuntime`、`ResourceRuntime`、`SceneFlow`、`CombatPoolRuntime`、`MagicWeaponRuntime`、`LevelEntryRuntime`、`MonsterSpawnRuntime`、`RoleVisualRuntime` 与场景工厂族均为 `Global` 的普通子节点、静态工具或 `RefCounted`，不计入 Autoload。当前字段/入口、26 个普通子服务与 Phase 22 迁移判定见 [`global_runtime_inventory.md`](global_runtime_inventory.md)。

`RunContext` 持有迁移后的运行状态；新增字段应先判定是否属于实例状态、会话状态或全局上下文，不直接塞入 `Global`。`Global` 当前字段/入口基线与表面守卫见 [`global_runtime_inventory.md`](global_runtime_inventory.md) 与 [`acceptance.md`](acceptance.md) §4.1；本页不复制计数。

## 4. 验收

- Autoload 数量与注册顺序以 `source/project.godot` 为准；
- 删除/合并项必须无生产引用，且场景切换、暂停、切档、退出清理通过；
- 新增 Autoload 必须提供失败/退出路径与回归证据；
- 完整历史与剩余候选见归档页；当前不把历史迁移状态写成新计划。
