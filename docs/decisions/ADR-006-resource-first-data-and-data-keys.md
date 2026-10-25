# ADR-006：新结构化数据优先 Resource，存量字典走 DataKeys

- **状态**：Accepted
- **记录日期**：2026-10-25
- **影响范围**：配置、运行时清单、存档字段、全局状态

## 背景

`PlayerData.player_data` 与 `Global` 中存在大量无类型字典、中文键和硬编码表。继续扩大这种模式会失去 Inspector 可编辑性、类型检查与迁移边界。另一方面，存量存档与业务逻辑已深度依赖这些字典，无法一次性替换。

## 决策

1. 新增结构化静态数据优先定义自定义 `Resource`，保存为 `.tres`，使用 `class_name` + `@export`；
2. 新增/修改字典键必须通过 `DataKeys` 常量访问，禁止裸中文字符串键；
3. 不继续扩大 `global.gd` 与裸字典配置；
4. 角色资源清单使用 `RoleRuntimeResourceManifest` + `RoleRuntimeCatalog`，按资源类型强类型登记；
5. 存量字典与 JSON 作为过渡保留，不做无计划全量迁移；
6. 字典与 Resource 混用期间，必须在代码中明确数据边界。

## 后果

- 新数据可在 Inspector 编辑、可被类型检查、可被资源依赖分析；
- 角色/关卡/怪物配置逐步从脚本常量迁移到资源；
- `DataKeys` 仍是存量字典的唯一入口，不能绕过；
- 新增字段需要同时更新默认档与 `ensure_*` 补全逻辑。

## 备选方案

| 方案 | 未采用原因 |
|:---|:---|
| 继续使用裸字典/JSON | 无类型、无 Inspector、难以审计 |
| 立即把所有字典迁移为 Resource | 破坏存档与业务行为，回归面过大 |
| 引入外部配置表/数据库 | 增加运行时依赖与构建复杂度，收益不足 |

## 证据

- [`../standards/godot_design_standard.md`](../standards/godot_design_standard.md) §3
- [`../standards/naming_standard.md`](../standards/naming_standard.md) §5
- [`../../source/Script/data/role_runtime_catalog.gd`](../../source/Script/data/role_runtime_catalog.gd)
- [`../../source/Script/data/role_runtime_resource_manifest.gd`](../../source/Script/data/role_runtime_resource_manifest.gd)
- [`../reference/architecture.md`](../reference/architecture.md) §5、§6
