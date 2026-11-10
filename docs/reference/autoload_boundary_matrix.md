# Autoload 与 Global 边界

> **职责**：定义 Autoload 增删评审和 `Global` 扩张边界；当前注册清单只在 [`architecture.md`](architecture.md) §2.1 与 [`source/project.godot`](../../source/project.godot) 维护。
> Phase 20/22 迁移记录见 [`../archive/iteration_20_autoload_boundary_matrix.md`](../archive/iteration_20_autoload_boundary_matrix.md) 与 [`../archive/iteration_22_global_state_boundary.md`](../archive/iteration_22_global_state_boundary.md)。

## 1. 边界规则

1. 不设 Autoload 数量目标；新增、合并或删除须评审完整调用面、初始化顺序、生命周期、清理和回归。
2. 新职责优先使用 `Resource`、`RefCounted`、静态 `class_name` 工具或场景节点；不得只为“方便访问”新增单例。
3. `Global` 只作为组合根和正式窄入口；新业务状态不得回流。`global_surface_boundary` 的机读登记源为 `scripts/global_surface_baseline.json`。
4. 角色/档案访问通过 `BaseObject` / `BaseRole` 注入属性或 `LocalCoop.data_for/props_for`，不假定 1P。
5. 已删除入口不得恢复为兼容 facade；迁移职责时同批迁移全部生产调用方并删除旧路径。
6. `MCPGameBridge` 是编辑器调试桥，不承担 release 业务职责；导出行为按 [`acceptance.md`](acceptance.md) 验证。

## 2. 当前事实来源

- Autoload 名称、数量、顺序与职责：`source/project.godot` 和 [`architecture.md`](architecture.md) §2.1。
- Global 当前职责和仍保留的正式 API 见 [`architecture.md`](architecture.md)；新增 `Global` 字段与 `add` 入口以 [`../../scripts/global_surface_baseline.json`](../../scripts/global_surface_baseline.json) 为机读登记源。
- 跨模块规则：[`../standards/godot_design_standard.md`](../standards/godot_design_standard.md) §4、[`../decisions/ADR-007-autoload-boundary.md`](../decisions/ADR-007-autoload-boundary.md)。
- 当前门禁判据：[`acceptance.md`](acceptance.md) §4。

## 3. 验收

- 新增/删除/合并 Autoload 前核对生产引用、初始化依赖与退出路径。
- 迁移职责时覆盖启动、场景切换、切档、暂停、失败和清理。
- 不以 Autoload 数量、`Global` 字段数或历史迁移计数作为目标。