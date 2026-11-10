# AtlasMetadata schema 与读写边界

> **职责**：说明 AtlasMetadata 的构建期序列化格式、运行时支持的 schema、Store/View 读写职责与失败语义，以及构建期与运行时的边界。当前验证与工程状态以 [`status.md`](status.md) 为准；运行架构见 [`architecture.md`](architecture.md)，验收判据见 [`acceptance.md`](acceptance.md)。路径身份与失败决策见 [`ADR-022`](../decisions/ADR-022-atlas-metadata-view-and-path-identity.md)。

## 1. 生产、序列化与读取角色

```text
manifest.json --convert_atlas_metadata.py--> metadata.tres
                                             |
                                             v
                              AtlasMetadataStore.view_for(path)
                                             |
                                             v
                                    AtlasMetadataView
```

- `scripts/convert_atlas_metadata.py` 是仓库内 AtlasMetadata 资源的构建期生产者：将 manifest 数据序列化到同目录 `metadata.tres`；顶层数组包装为 `{"__top_level": "array", "items": [...]}`。`--check` 只比较预期输出，不写资源。
- 转换器从 `source/Art/` 中发现的 `manifest.json` 读取输入并写入同目录资源；仓库内该脚本没有定义 manifest 的上游生成者，故本页不推断其来源链路，也不登记私有素材数量。
- `AtlasMetadata` 以 `schema_id = "atlas_metadata"`、`schema_version = 1` 和 `data: Dictionary` 序列化。资源负责存储与浅层顶层检查；`data` 不是业务侧的可写接口。运行时只通过 `AtlasMetadataStore.view_for(path)` 取得只读查询对象，不直接取出或修改原始字典。
- 构建转换器可读取 manifest 或 `metadata.tres` 并生成 `SpriteFrames` 等资源；这些构建期读取不构成运行时 `AtlasMetadataStore` 消费。

## 2. 运行时 schema 契约

`AtlasMetadataView` 只接受真实运行时消费的两种结构；其它源数据可以留给相应构建工具处理，不应为它们增加通用运行时模型。

| 运行时结构 | 数据形态 | View 接纳检查与查询边界 |
|:---|:---|:---|
| `pages` + `sequences` | `pages: [{path: String}]`；`sequences: {name: {frames: [[frame, page, x, y, w, h, margin_l, margin_t, margin_r, margin_b]]}}`；可带 `geometry`、`masks` 及构建/溯源用 `files` | 页与序列需为非空数组/字典；页路径为非空字符串；帧条目至少含 10 个数值，页索引须为整数且位于页表范围内。`geometry` 的 `center`、`size`、`origin` 是二元数值数组；`masks` 是逐帧数组，非空矩形至少含 4 个数值。空 mask 合法，表示该帧没有碰撞区域；`files` 不由 View 读取。 |
| `animation` + `frames` | 单一动画及逐帧 `back` / `front` 图层，可选 `ride` / `official_ride` 变换 | 动画名非空；`fps` 为正数；`loop` 为布尔值；`frame_count` 与非空帧数组长度一致；`back_atlases`、`front_atlases` 为字符串数组。图层页索引、region、offset 及可选变换均按对应结构检查。 |

`AtlasMetadata.validate()` 检查 schema 标识/版本与资源级顶层形状；更深的帧元组、页索引、geometry、mask、动画层及变换检查由 `AtlasMetadataView` 在接纳时完成。越界或缺失查询按对应 accessor 返回零值、空结果、`-1` 或单位变换，不向业务侧暴露底层字典。
View 的公开查询返回值为帧数/页索引等标量、`Vector2`、`Rect2`、`Transform2D` 或 `Array[String]`；不向业务侧暴露底层字典。

`files`、旧式 `animations`、顶层数组包装结构和索引字典不是运行时 View schema；它们只作为序列化输入、溯源数据或相应构建转换器的输入保留。不要从它们推断运行时加载依赖，也不要为统一格式而强行建立运行时 accessor。

## 3. 运行时消费者与失败语义

| 消费者 | View 查询职责 | 消费者侧处理 |
|:---|:---|:---|
| `EastContinentMonster` | 序列帧数、帧尺寸、registration anchor 与帧几何；`CloudBoss`、`PalaceFlyingBoss` 继承其序列读取 | View 无效时帧数为 0、anchor 为零；不可用帧几何使用显式缺失哨兵，不直接索引裸字典。 |
| `CloudBoss` | `geometry.center`，用于视觉偏移 | View 无效时视觉偏移为零；序列仍由继承的 East 路径读取。 |
| `NorthContinentMonster` | 序列、`geometry` 与 `masks`；向弹体传递 metadata 路径及可选 mask 序列别名 | View 缺失时序列数为 0、几何为零；弹体的 mask 别名选择查询序列，不复制或覆盖 mask 字典。 |
| `PalaceFlyingBoss` | 自有 `geometry` 与 `hit1` mask；序列沿 East 继承路径读取 | View 无效时偏移/几何查询为零，依赖 mask 的攻击碰撞禁用。 |
| `PalaceBossProjectile`（含 `NorthBossProjectile`） | `source_masks_metadata` 对应的 `geometry` / `masks` | 非空路径无法建立有效 View 时 `configure()` 返回 `false`；空路径表示未请求可选 masks。空 mask 是合法无碰撞帧，不是资源加载失败。 |
| `MountVisual` | `animation`、播放参数、逐帧图层 region/offset 与 ride transform | 缺失或无效 metadata 时 `play()` 返回 `false`。原生骨骼 parts 分支使用其既有数据，不经 AtlasMetadata。 |

`AtlasMetadataStore.view_for()` 对空路径、文件缺失、资源类型不符或 schema 无效报告错误并返回 `null`；调用方表示“未请求可选资源”时不应把空路径传给 Store。成功 View 与非空路径的失败状态按路径缓存，错误报告按路径去重。消费者对 `null` 的处理由上表和相应实现决定；不得把无效 metadata 静默替换为另一 schema、旧路径或裸字典。

metadata 的稳定身份为资源路径加 `schema_id` / `schema_version`，不新增 `uid://`；路径变更须同步引用与确定性生成，详见 ADR-022。

## 4. 构建期边界与守卫

- 构建转换器可直接读取 manifest 或序列化后的 `metadata.tres` 并生成 `SpriteFrames` 等资源，例如 `convert_frame_sequences.py` 消费 manifest、`convert_monster_frames.py` 消费 metadata。构建期读取不等于游戏运行时读取，也不能代替运行时消费者对 View 的校验。
- 运行时不得直接解析 atlas manifest。`scripts/contract_scan.py` 的运行时 manifest 规则守住此边界；`atlas_boundary` 规则禁止恢复旧 Store 入口、业务直接读取 `.data` 或 `source_masks` 字典覆盖，业务查询应使用 `view_for()` 与 View 值接口。
- 当前验证结果由 `status.md` 汇总；需要执行的命令与判据由 `acceptance.md` 维护，本页不复制阶段记录或一次性探针结果。
