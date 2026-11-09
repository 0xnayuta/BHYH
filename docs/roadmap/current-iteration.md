# BHYH 当前候选迭代

> **状态**：Phase 35–38 的 7.1–7.4 内容回植已完成并归档；Phase 28、29 已完成并归档；**Phase 39 Scene/Script 目录收敛已完成并归档**；Phase 26 平台与发布验证长期暂缓；7.3/7.4 PCK/release 暂缓。
> **版本**：7.4 内容基线；Phase 28、29、39 已完成并归档。PCK/release 与最低配置/其他平台验证暂缓。
> **当前基线**：[`global_runtime_inventory.md`](../reference/global_runtime_inventory.md)、[`architecture.md`](../reference/architecture.md)、[`status.md`](../reference/status.md)、[`acceptance.md`](../reference/acceptance.md)。
> **历史指针**：归档文档中的 `current-iteration.md §1.2` 指向本页“跨阶段不变量”；`§4`、`§5C`、`§5D` 指向已迁移的批次记录，完整内容见 [`../archive/README.md`](../archive/README.md)。

---

## 1. 当前状态与边界

### 1.1 已完成阶段（归档）

| 阶段 | 状态 | 归档 |
|:---|:---|:---|
| Phase 22 `Global` 状态与入口契约 | 完成并归档 | [`iteration_22_global_state_boundary.md`](../archive/iteration_22_global_state_boundary.md) |
| Phase 23 关卡、宠物与档案数据边界 | 完成并归档 | [`iteration_23_pet_domain_boundary.md`](../archive/iteration_23_pet_domain_boundary.md) |
| Phase 24 UI 与成长命令边界 | 完成并关闭 | [`iteration_24_ui_growth_boundaries.md`](../archive/iteration_24_ui_growth_boundaries.md) |
| Phase 25 战斗实体行为切片 | 完成并关闭 | [`iteration_25_combat_behavior.md`](../archive/iteration_25_combat_behavior.md) |
| Phase 27 Theme 与字体契约收敛 | 完成并关闭 | [`iteration_27_theme_font_convergence.md`](../archive/iteration_27_theme_font_convergence.md) |
| Phase 35 7.1 内容回植 | 完成并归档 | [`iteration_35_38_content_backport.md`](../archive/iteration_35_38_content_backport.md) |
| Phase 36 7.2 内容回植 | 完成并归档 | [`iteration_35_38_content_backport.md`](../archive/iteration_35_38_content_backport.md) |
| Phase 37 7.3 内容回植 | 完成并归档 | [`iteration_35_38_content_backport.md`](../archive/iteration_35_38_content_backport.md) |
| Phase 38 7.4 内容回植 | 完成并归档 | [`iteration_35_38_content_backport.md`](../archive/iteration_35_38_content_backport.md) |
| Phase 28 全局通信与派生属性契约 | 完成并归档 | [`iteration_28_global_signal_and_passive_contract.md`](../archive/iteration_28_global_signal_and_passive_contract.md) |
| Phase 29 `Scene/` 脚本落位 | 完成并归档 | [`iteration_29_scene_script_relocation.md`](../archive/iteration_29_scene_script_relocation.md) |
| Phase 39 Scene/Script 目录收敛 | 完成并归档 | [`iteration_39_scene_script_layout.md`](../archive/iteration_39_scene_script_layout.md) |
| Phase 26 平台与发布验证 | 长期暂缓 | 见 §2 |

阶段产物与当前契约：

- 宠物调用面：[`pet_level_boundary_matrix.md`](../reference/pet_level_boundary_matrix.md)；宠物域 View/命令：[`pet_domain_contract.md`](../reference/pet_domain_contract.md)；
- 面板操作者/命令/保存边界：[`ui_panel_contract_matrix.md`](../reference/ui_panel_contract_matrix.md)；
- 战斗行为与探针映射：[`combat_behavior_matrix.md`](../reference/combat_behavior_matrix.md)；
- Theme/字体事实：[`theme_font_inventory.md`](../reference/theme_font_inventory.md)、[`ui_theme_contract.md`](../reference/ui_theme_contract.md)、[`typography_tokens.md`](../reference/typography_tokens.md)。

### 1.2 跨阶段不变量

1. 不夹带玩法变更：数值、时序、掉落、输入映射与存档格式不在架构/文档批次中改变。
2. 不新增 Autoload、不新增 `Global` 业务字段、不新增 `add` 系门面；新增能力先证明普通节点/`RefCounted`/`Resource`/静态工具不足。
3. 定义与实例分离：静态定义走 Resource/Catalog；玩家档案保持加密 JSON、`DataKeys` 与 `ensure_*`；不把 `PlayerData.player_data` 整体 Resource 化。
4. 失败显式：缺资源、无来源、保存失败、加载失败、过期回调必须报告给拥有者；不默认 1P、不猜旧路径、不静默成功。
5. 回滚通过版本控制，不保留永久双实现、兼容 facade 或双写路径。

### 1.3 Phase 39 Scene/Script 目录收敛（完成并归档）

- **39-0~39-4 完成**：`Scene/` 根级 `.tscn` 与 `Script/` 根级 `.gd` 清零；`Scene/other_scene` 44 个场景拆分；`show_text`、`monster_blood`/`monster_damage`、`special_effect` 共 29 个场景合并；`Scene/` 顶层目录为 22 个；`project.godot` 主场景为 `res://Scene/runtime/startup_loading.tscn`。
- **39-3 决策**：`Scene/level/zmws` 的 1727 个场景保持平铺；`Script/monster` 的 261 个脚本保持现状；10 个 shader 保留，`base_hero.gdshader` / `equipment_properies.gdshader` 不删除，角色描边暂缓。品质颜色表、装备图标边框与角色描边试验登记在 [`roadmap.md`](roadmap.md) §4.3。
- **39-4 验收**：根级清零、旧目录删除、`naming_audit` 根级门禁启用；`check_all --skip-engine`、`health_check`（823 脚本 0/0/0）、`scene_probe_runner` 31/31、`archive_probe_runner` 344/344、`level_1` 均通过；`docs_audit` 969 链接 / 0 缺失。
- 详细批次、路径结果、保留决策与验证证据见 [`../archive/iteration_39_scene_script_layout.md`](../archive/iteration_39_scene_script_layout.md)。

## 2. Phase 26：平台与发布验证（长期暂缓）

**状态**：长期暂缓；未启动，不阻塞后续阶段。Windows-only 验证口径见 [`ADR-027`](../decisions/ADR-027-platform-commitment-and-verification-device.md)。
**目标**：把“路径闭包”“release 启动”“验证机性能基线”“Spine 平台支持”分别证明。
**前置**：可做只读规划；涉及资源/导出变化时再与当前代码批次协调。
**非目标**：不把未验证平台写成支持，不用 PCK 可达替代 release，不用 headless 替代 HUD/VRAM。

### 26-0 平台支持矩阵

- 明确当前承诺平台、未验证平台与退出条件；
- 记录设备、OS、渲染后端、Spine 库、导出模板与许可证；
- Windows x86_64 先行；其它平台保持“延期/未验证”。

### 26-1 Windows release 启动与最小包

- 构建 release，验证冷启动、主菜单、存档列表、`level_1` 进入与退出；
- 区分离线验证包与最小发布包；记录实际包路径闭包与缺失资源；
- 失败必须显式，不以“全资源包可运行”替代发布结论。

### 26-2 验证机性能基线

- 在验证机记录首帧、战斗峰值 VRAM、加载时长、重复进出与退出；固定机器、驱动、渲染后端、分辨率与 `max_fps`，只做同机对照（ADR-027）；
- 至少覆盖一场战斗、一个 Boss、一次返回/重战；
- 结论写入 `status.md`，带设备、日期与未验证范围。

### 26-3 Spine 平台决策

- 复核 Windows 之外是否需要 Spine 扩展；没有设备/许可证/导出证据时保持延期；
- 不把 `.gdextension` 声明文件当作运行库已入库。

### 26-4 阶段验收

- 平台矩阵、release 启动记录、设备性能证据与发布包结论；
- 出口：支持平台有证据，未支持平台有明确原因；不新增未经证实的兼容承诺。

**恢复条件**：平台矩阵、设备、导出条件与 release 证据同时明确。

---

## 3. 启动新阶段的条件

1. 先在 [`roadmap.md`](roadmap.md) 登记阶段目标、依赖、边界与验收要求，不把未实现目标写成本页现状。
2. 进入候选前补齐调用面、所有权边界、原子迁移批次与可执行验收。
3. 一个批次一个所有权边界：迁移全部生产调用方，删除旧实现。
4. 验收按变更矩阵：静态门禁、相关探针、生产路径冒烟、全量回归、release/性能分别取证；不新增只验证 wiring 的永久测试。
5. 文档同步：每批完成后更新 `architecture.md`、`status.md`、对应矩阵与 `global_runtime_inventory.md`；归档只在阶段结束后进行。
6. 完整跨阶段纪律见 [`roadmap.md`](roadmap.md) §5。

---

## 4. 当前恢复入口

**当前下一步**：Phase 35–38、28、29、39 已完成并归档；当前无活跃代码批次。`roadmap.md` §4.3 的品质颜色表、装备图标边框与角色描边仅为待确认创意，未启动；PCK/release、最低配置与其他平台验证按用户决策另行执行。恢复前先按 [`acceptance.md`](../reference/acceptance.md) 与 [`status.md`](../reference/status.md) 的发布边界复核。

- 当前架构：[`architecture.md`](../reference/architecture.md)
- Global 清单：[`global_runtime_inventory.md`](../reference/global_runtime_inventory.md)
- 验收标准：[`acceptance.md`](../reference/acceptance.md)
- 当前状态：[`status.md`](../reference/status.md)
- 长期路线：[`roadmap.md`](roadmap.md)
- 归档索引：[`../archive/README.md`](../archive/README.md)
- 已归档程序记录：[`program_21_33_closeout.md`](../archive/program_21_33_closeout.md)
