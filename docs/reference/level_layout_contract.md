# 关卡布局数据契约

> 当前运行时集成见 [`architecture.md`](architecture.md)；域内验收与发布闭包判据见 [`acceptance.md`](acceptance.md)；最近验证见 [`status.md`](status.md)；阶段状态见 [`../roadmap/roadmap.md`](../roadmap/roadmap.md)；工具职责与 CLI 见 [`../../scripts/README.md`](../../scripts/README.md)。本页只记录布局 Resource 字段、域内数据所有权及不可替代的消费/失败边界。
>
> 设计依据：[ADR-023](../decisions/ADR-023-level-layout-data-contract.md)、[ADR-006](../decisions/ADR-006-resource-first-data-and-data-keys.md) 与 [ADR-005](../decisions/ADR-005-no-compatibility-or-fallback-layers.md)。通用数据载体规则见 [`../standards/target_architecture_contract.md`](../standards/target_architecture_contract.md)。

## 1. 模型与范围

| 类型 | 字段 / 职责 |
|:---|:---|
| `LevelLayoutCatalog` | `layout_paths: Dictionary[StringName, StringName]`；只保存关卡场景路径到布局资源路径的映射，不内嵌布局 |
| `LevelLayoutEntry` | 单关布局：`level_id: StringName`、`layout_size: Vector2`、`player_birth_points: PackedVector2Array`、`stages: Array[LevelStageSpec]`、`exit_rect: Rect2`、`exit_open_when: StringName` |
| `LevelStageSpec` | 阶段：`index: int`、`screen_rect` / `trigger_rect` / `spawn_trigger_rect: Rect2`、`close_walls` / `open_walls: PackedStringArray`、`spawn_points: Array[LevelSpawnPoint]` |
| `LevelSpawnPoint` | 刷怪点：`point_id: int`、`monster_ids: PackedInt32Array`、`position: Vector2`、`count: int`、`delay` / `interval: float`、`direction: int`、`after_spawn` / `after_dead: int`、`ignore_count_multiplier: bool` |
| `LevelLayoutStore` | `RefCounted` 只读入口；按场景路径加载、复用对应 Resource，不扫描目录或读取源 JSON |

布局资源描述关卡结构，不拥有渲染节点、碰撞几何或战斗数值；战斗数值归 `ZmwsConfig`。所有位置和矩形均为 Godot 坐标，外部坐标转换在构建期完成，运行时不得再次翻转坐标。[ADR-023](../decisions/ADR-023-level-layout-data-contract.md) 记录该域边界与选型依据。

## 2. 字段不变量与消费语义

- `layout_size` 的宽、高必须为正；所有矩形均须落在布局范围内且高度为正。只有 `screen_rect` 可为零宽，其他矩形宽度必须为正。
- `stages` 非空，`index` 从 1 连续递增；长度可变，并由构建 schema 限定上限。
- `player_birth_points` 是玩家槽位出生点数组，与刷怪点分离；缺少某槽位坐标时的既有出生位置由 [`architecture.md`](architecture.md) 描述。
- `LevelSpawnPoint.count >= 1`；`delay`、`interval` 非负；`monster_ids` 非空且只含正 ID。`point_id` 在整关范围内唯一且为正；非零 `after_spawn` / `after_dead` 必须引用该布局已登记的点。
- `after_spawn` 表示前置点完成刷怪后启动；`after_dead` 表示前置点全部死亡后启动；零表示无依赖。消费者同时遇到两者时，`after_spawn` 优先。
- `ignore_count_multiplier` 表示该点不乘入 `CreateMonsterCount`；其余点按运行时刷怪规则应用数量倍率。
- `monster_ids` 完整集合用于构建期预载路径闭包；既有刷怪字典消费者只读取数组首项作为该点的怪物 ID。请勿在运行时从未使用的后续 ID 额外生成单位。
- `direction` 在刷怪字典中映射为 `face`，朝向赋值由 `Game4ImportedLevel` 执行；布局构建不对该值做符号归一化。具体消费者见 [`game4_imported_level.gd`](../../source/Script/level/game4_imported_level.gd)。
- `exit_rect` 在 `ZmwsLevel` 中用于定位已存在的出口节点；`exit_open_when` 是序列化条件标签，当前运行时代码不读取它，不能据此宣称出口条件已由布局驱动。`spawn_trigger_rect` 目前也只由构建端保存、校验，当前运行时阶段推进不读取它。
- `close_walls` / `open_walls` 的运行时墙体匹配与缺失节点处理见 [`architecture.md`](architecture.md)，本页不另抄实现清单。

## 3. 数据源、双源禁止与失败边界

构建输入 [`level_layout_sources.json`](../../scripts/level_layout_sources.json) 是登记布局的可编辑事实源；生成的单关 `.tres` 与 `LevelLayoutCatalog` 是运行时只读数据。已登记布局的脚本不得再保留 `monster_group` 或坐标表副本；未登记关卡仍由其现有脚本逻辑单独拥有布局，不能为其生成空布局。运行时缺少 Catalog/已登记布局时必须报告失败，不扫描目录、解析构建源或回退到另一份数据表。

非静态布局例外仅由 [`level_layout_data_exceptions.json`](../../scripts/level_layout_data_exceptions.json) 登记；该登记与双源审计必须保持精确，未登记的数据表、失效例外或已登记布局残留脚本表均为失败。不要在本页抄录可变例外清单或数量；检查规则和验收档位见 [`acceptance.md`](acceptance.md)。
构建失败边界：无效 schema、缺失/非法场景、越界或尺寸非法的矩形、重复点位、非法怪物 ID、无效数量/时序或不存在的刷怪依赖都会失败，且不生成占位布局。阶段长度和矩形约束以本页上文及生成源 schema 为准。预载构建还必须解析布局引用的怪物场景及关卡资源；缺失路径不得静默跳过。Catalog 或登记资源缺失、生成物不同步时失败，不得当成“尚未登记”。

[`level_preload_export_dependencies.json`](../../source/Script/data/level_preload_export_dependencies.json) 是发布依赖清单，登记布局 Catalog 与其单关资源；PCK 闭包探针缺少其中任一路径即发布失败。发布判据见 [`acceptance.md`](acceptance.md)，最近一次验证只记在 [`status.md`](status.md)。

模型定义见 [`LevelLayoutEntry`](../../source/Script/data/level_layout_entry.gd)、[`LevelStageSpec`](../../source/Script/data/level_stage_spec.gd)、[`LevelSpawnPoint`](../../source/Script/data/level_spawn_point.gd)、[`LevelLayoutCatalog`](../../source/Script/data/level_layout_catalog.gd) 与 [`LevelLayoutStore`](../../source/Script/data/level_layout_store.gd)。
