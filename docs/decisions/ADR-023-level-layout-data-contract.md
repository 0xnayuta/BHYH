# ADR-023：关卡布局数据契约与绞杀式迁移

- **状态**：Proposed（设计阶段，尚未实施）
- **记录日期**：2026-10-31
- **影响范围**：`source/Script/base/base_through_level.gd`、`source/Script/level/*.gd`、`source/Script/data/level_layout_*.gd`、`scripts/convert_level_layout_catalog.py`、新增关卡数据资源
- **关联**：[ADR-005](ADR-005-no-compatibility-or-fallback-layers.md)（禁止兼容/回退层）、[ADR-006](ADR-006-resource-first-data-and-data-keys.md)（新结构化数据优先 Resource）、[ADR-008](ADR-008-type-based-directories-with-feature-subdirectories.md)（目录）、[ADR-021](ADR-021-project-wide-target-architecture.md)（总体目标架构）
- **契约细节**：[`../reference/level_layout_contract.md`](../reference/level_layout_contract.md)

## 背景

### 触发条件

需要把 ZMWS《造梦无双》1,701 个关卡场景接入 BHYH 的闯关流程。ZMWS 关卡为**纯数据驱动**（1,708 个关卡 json，`mapLogic.ts` 无关卡名特判），而 BHYH 当前把同类数据写进关卡脚本。

### 现状证据（2026-10-31 实测）

| 项 | 数值 | 命令 |
|:---|---:|:---|
| BHYH 关卡场景 / 脚本 | 153 / 164 | `ls source/Scene/level/*.tscn`、`ls source/Script/level/*.gd` |
| 关卡脚本总行数 | 33,647 | `cat source/Script/level/*.gd \| wc -l` |
| 硬编码 `monster_group = {` 的脚本 | **84** | `grep -l "^\tmonster_group = {"` |
| < 100 行的脚本（基本是纯数据表） | 76 | 行数分布统计 |
| 重写基类钩子的脚本 | 117 | `grep -l "func create_monster\|func check_can_pass\|…"` |
| 抽样 `level_1.gd` | 65 行，其中逻辑 5 行 | 人工核对 |
| ZMWS 关卡 json 总体积 | 40.4 MB / 1,708 个 | 平均 23.1 KB，中位 14.2 KB |
| 其中仅布局字段（birth/screen/triggers/Gateway/ground） | 13.1 MB | 去掉 `imagelayers` 与展示字段 |

### 已有可复用范式

项目已有「构建期生成 + 运行时只读」的成熟范式，本决策照其结构执行，不发明第二套：

| 组成部分 | 既有实现 | 作用 |
|:---|:---|:---|
| Entry | `source/Script/data/level_preload_entry.gd`（`LevelPreloadEntry`，`@export` 数组） | 单关卡数据载体 |
| Catalog | `source/Script/data/level_preload_catalog.gd`（`Dictionary[StringName, LevelPreloadEntry]`） | 聚合索引 |
| Store | `source/Script/data/level_preload_store.gd`（`RefCounted` 静态只读入口 + `CACHE_MODE_REUSE`） | 运行时访问 |
| 生成器 | `scripts/convert_level_preload_catalog.py` | 构建期从脚本字面量生成 `.tres` |

同时 `BaseLevel` 已预留四个数据契约扩展点（`_stage_count()` / `_stage_trigger_x()` / `_screen_starts()` / `_screen_rights()` / `_birth_points()`），其中前三个已被 `game4_imported_level.gd`、`level_48.gd`、`level_59.gd` 等子类覆写调用，`_birth_points()` 基类返回空且**无调用点**。

## 决策

1. **新增关卡布局资源五件套**，命名与结构对齐 `LevelPreload*`：
   - `LevelLayoutEntry`（单关卡布局，`Resource`）
   - `LevelStageSpec`（单阶段：分屏矩形、挡板、触发矩形）
   - `LevelSpawnPoint`（单刷怪点：坐标、怪物 id、数量、延迟、间隔、朝向）
   - `LevelLayoutCatalog`（`Dictionary[StringName, StringName]` 场景路径 → 布局资源路径，**只存路径不内联**）
   - `LevelLayoutStore`（`RefCounted` 静态只读入口，按需 `ResourceLoader.load` 单关卡布局）
2. **布局数据由构建期生成器产出**，运行时只读；不在 `_process` / `_physics_process` 解析 JSON、不扫描目录、不解析脚本源文本。
3. **`BaseLevel` 的默认实现改为「优先读布局资源」**：
   - 布局资源登记了该关卡 → 用资源值；
   - 未登记 → 沿用现有默认常量（这是**未迁移关卡的现有行为**，不是新增回退层，ADR-005 允许）；
   - 一旦某关卡迁移完成，其脚本内的 `monster_group` / `monster_position_x/y` **删除**，不保留双份。
4. **绞杀式迁移**：新增数据通道与现有 164 个脚本并行；先跑通 1 个 ZMWS 关卡，再按批迁移 84 个「数据容器」脚本；55 个含真实玩法逻辑的脚本保留，只把其中的结构化数据块迁出。
5. **数据文件格式选 `.tres` 而非 `.json`**，依据 [ADR-006](ADR-006-resource-first-data-and-data-keys.md) 与 `godot_design_standard.md` §3.1。原「用 JSON」的初步设想在此修正。
6. **`ground` 碰撞不进布局资源**：它已在关卡 `.tscn` 中生成 `ZMWS_Ground` 静态节点，资源重复会让同一事实出现两个可写源。
7. **不新增 Autoload**：`LevelLayoutStore` 为 `RefCounted` 静态工具，与 `LevelPreloadStore` 一致。

## 后果

### 收益

- 关卡结构化数据可被 Inspector 审查、类型检查与依赖分析，符合 ADR-006；
- 新增关卡只需产出数据资源，不再复制 60 行脚本数据表；
- ZMWS 1,701 关有统一接入点，接线范围从「1,701 个脚本」降为「1 个基类 + 1 个生成器」；
- 迁移有验收边界：每批迁移可用 `level_regression_all.py` 对照原关卡行为。

### 代价与约束

- 引入 5 个新 `class_name` 与 1 个构建期生成器，需登记进命名白名单与转换器索引；
- 布局资源与加密 JSON 存档格式无关，不改变任何持久化语义；
- 若生成器与脚本内容漂移，必须在 `--check` 中失败，不能运行时兜底；
- `.tres` 文本比 JSON 大，1,708 关预计 20–35 MB，靠「按关卡懒加载」控制常驻。

### 必须遵守

- 不得为已迁移关卡保留脚本内数据表副本（ADR-005）；
- 不得在运行时用 JSON 解析或目录扫描补齐缺失布局（ADR-005、`target_architecture_contract.md` §7.2）；
- 不得借本决策改变任何现有玩法的数值、时序、掉落或输入（`current-iteration.md` §1.2）；
- 不得在 Phase 21 内实施：本决策属于新阶段候选，需另立批次。

## 备选方案

| 方案 | 未采用原因 |
|:---|:---|
| 维持脚本内硬编码数据表 | 新增 1,701 个关卡无法接受；违背 ADR-006；无法 Inspector 审查 |
| 运行时直接解析 ZMWS 关卡 json | 战斗热路径解析源 JSON 被 `target_architecture_contract.md` §7.2 禁止；无类型、不可审计 |
| 全部内联进单个大型 `Catalog.tres` | 1,708 关内联预计 20–35 MB 常驻，违背按需加载；单文件版本控制冲突面大 |
| 先全面重构 `BaseLevel` 与 164 个脚本，再接入 ZMWS | 无验收边界、回归面覆盖 153 场景；且不能解决「怪物 id 对不上」这一真实障碍 |
| 把 ZMWS 关卡做成独立玩法框架 | 与 §4.3「新关卡不复制第二套独立循环」冲突 |

## 证据

- [`../reference/architecture.md`](../reference/architecture.md) §4.3 关卡状态机、§9.2 已现代化清单
- [`../standards/target_architecture_contract.md`](../standards/target_architecture_contract.md) §4.3、§5.1、§7.2
- [`../standards/godot_design_standard.md`](../standards/godot_design_standard.md) §3.1
- `source/Script/data/level_preload_*.gd`、`scripts/convert_level_preload_catalog.py`
- `source/Script/base/base_through_level.gd:1817-1853`（四个契约扩展点）
- 数据来源：`G:/source/repos/ZMWS/cocos/assets/resources/map/*.json`（1,708 个）
