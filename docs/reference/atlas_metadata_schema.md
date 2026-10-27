# AtlasMetadata 生产者、schema 与消费者矩阵

> **状态**：Phase 14-1 只读调查结果（2026-10-28），不是运行时重构完成声明。
> **范围**：`manifest.json` → `metadata.tres` → `AtlasMetadataStore` → 生产消费者，以及直接读取源文件的构建工具。
> **事实快照**：本页数量来自当前私有完整素材工作区；公开 clone 缺少 `source/Art/`，不能复现本页的 379 个 manifest 与 267 个运行时可达资源。当前实现与验证事实分别见 [`architecture.md`](architecture.md)、[`status.md`](status.md)。
> **目标边界**：总体目标见 [`target_architecture_contract.md`](../standards/target_architecture_contract.md) §5、§7；Phase 14 批次见 [`current-iteration.md`](../roadmap/current-iteration.md)。

## 1. 数据流与职责

```mermaid
flowchart LR
    M["私有素材 manifest.json<br/>379 个"] --> C["convert_atlas_metadata.py<br/>构建期转换 + --check"]
    C --> R["同目录 metadata.tres<br/>AtlasMetadata.data 原始 JSON"]
    R --> S["AtlasMetadataStore.data_for()"]
    S --> E["East / North / Cloud / Palace<br/>Boss 运行时"]
    S --> P["PalaceBossProjectile<br/>masks / geometry"]
    S --> V["MountVisual<br/>animation + frames"]
    M --> B1["convert_monster_frames.py"]
    M --> B2["convert_frame_sequences.py"]
    R --> B1
```

- 仓库内唯一的 AtlasMetadata 生产者是 `scripts/convert_atlas_metadata.py`；它把每个 `manifest.json` 原样写入同目录 `metadata.tres`，只对顶层数组包装 `__top_level=array` 与 `items`。
- 运行时唯一读取入口是 `AtlasMetadataStore.data_for(path)`；它缓存并返回 `AtlasMetadata.data` 的 `Dictionary` 引用，不是独立副本。
- 构建期工具直接读取 `metadata.tres` 文本或源 manifest；它们不应被误算成运行时 `AtlasMetadataStore` 消费者。
- `manifest.json` 的生成链路不在公共仓库；本页只覆盖已入库的转换器与运行时读取边界。

## 2. 源文件形态

### 2.1 当前快照

`source/Art/**/manifest.json` 共 **379** 个，均有同目录 `metadata.tres`，`convert_atlas_metadata.py --check` 为 **379/379 同步**。按顶层键/值形态分为 8 组：

| 形态 | 数量 | 代表路径 | 运行时读取 |
|:---|:---:|:---|:---|
| `pages + sequences + files` | 95 | `monster/swf_png/3005/atlas/manifest.json` | `sequences` 可被 East 读取；`files` 未被 Store 消费者读取 |
| `pages + sequences` | 63 | `monster/swf_png/.../atlas/manifest.json` | East 读取 `sequences` |
| `pages + sequences + masks` | 54 | `monster/cloud_boss/model_3352/manifest.json` | Cloud/North/Palace/Projectile 读取 `geometry`、`masks`、`sequences` |
| `animation + frames` | 130 | `mount/runtime/mounts/.../manifest.json` | MountVisual 读取完整动画结构 |
| `animations`（旧形态） | 18 | 剑 Boss、北俱芦洲道具、角色特效 | 无 Store 读取；剑 Boss 由构建期帧转换器读取 |
| 顶层数组 | 16 | 关卡地图、角色装备图集 | 无 Store 读取 |
| `files`（独立关卡图集） | 1 | `level/game_4_level/runtime_atlas/level_50_52` | 无 Store 读取 |
| 索引/其它字典 | 2 | `constellations/`、`monster/swf_png/` 索引 | 无 Store 读取 |

合计 379。不同目录的键组合共有 18 种签名；它们不构成 18 套运行时类型。

### 2.2 结论

原先“四种 schema”的说法不足以覆盖真实输入：

- `files` 既可以是 `pages + sequences` 的可选字段，也可以是独立关卡图集；
- 存在旧 `animations` 形态、顶层数组和纯索引入口；
- 运行时 Store 实际只直接使用两类顶层数据：
  1. `pages + sequences`（可带 `files`、`geometry`、`masks`）；
  2. `animation + frames`（MountVisual）。
- `files`、旧 `animations`、顶层数组与索引字典是构建/溯源边界，不应为了“统一”强行生成运行时对象。

## 3. 资源域与运行时可达范围

按 `AtlasMetadataStore.data_for` 的路径规则统计，**267** 个 metadata 资源可被当前运行时入口按路径触达；这不等于所有资源都会在每一局加载。

| 资源域 | 路径规则 | 可触达数量 | 实际读取者 |
|:---|:---|:---:|:---|
| East 普通怪物 | `Art/monster/swf_png/<id>/atlas/metadata.tres` | 83 | `EastContinentMonster` 及子类 |
| North 怪物 | `Art/monster/north_original/<model>/metadata.tres` | 51 | `NorthContinentMonster` |
| Palace Boss | `Art/monster/palace_boss/<kind>/metadata.tres` | 2 | `PalaceFlyingBoss` |
| Cloud Boss | `Art/monster/cloud_boss/model_3352/metadata.tres` | 1 | `CloudBoss` |
| 坐骑运行时 | `Art/mount/runtime/mounts/<mount>/<candidate>/metadata.tres` | 86 | `MountVisual` |
| 坐骑特效 | `Art/mount/runtime/effects/<mount>/<candidate>/metadata.tres` | 44 | `MountVisual`（effect root） |
| **合计** | | **267** | 6 个代码调用点 + 间接弹体读取 |

其余 112 个 metadata 未被 `AtlasMetadataStore` 路径规则触达；它们可能只服务构建、溯源、地图/角色图集或尚未迁移的代码，不能据此断言“无消费者”。本阶段只确认 Store 边界。

## 4. 运行时消费者矩阵

**直接且唯一的 Store 调用点**共 6 个；`PalaceBossProjectile` 会从 Cloud/North/Palace 接收同一批 metadata 路径，形成间接读取，但不新增资源域。

| # | 消费者 | 路径来源 | 使用字段 | 共享/复制 | 失败路径 |
|:---:|:---|:---|:---|:---|:---|
| 1 | `Script/monster/cloud_boss.gd` | 固定 `cloud_boss/model_3352/metadata.tres` | `geometry[sequence].center`；继承 East 读取 `sequences`；向 `PalaceBossProjectile` 传同一路径 | `_source` 保存 Store 返回的共享字典 | 未检查空字典；直接索引缺失键会触发运行时错误 |
| 2 | `Script/monster/east_continent_monster.gd` | `swf_png/<monster_kind>/atlas/metadata.tres`，不存在时返回空路径 | `sequences[seq].frames` 的长度与帧元组 [4]–[9] | 静态 `_east_metadata_cache` 保存共享字典 | 空数据时帧数/几何退化为 0 或哨兵；无统一的“拒绝该怪物”出口 |
| 3 | `Script/monster/north_continent_monster.gd` | `north_original/<model>/metadata.tres` | `sequences`、`geometry`（`center`/`size`/`origin`）、`masks`；传路径给弹体 | `_source` 保存共享字典 | 未检查空字典；缺失键会导致初始化/碰撞路径错误 |
| 4 | `Script/monster/palace_boss_projectile.gd` | 配置键 `source_masks_metadata`，来自 Cloud/North/Palace | `masks[frames_animation]`；`geometry[animation].center` | `_source_metadata` 共享；`source_masks` 仅复制 masks 子字典 | 路径为空直接 `{}`；有路径但资源缺失时 masks 为空并退回基类碰撞，未显式拒绝“已声明但不可用” |
| 5 | `Script/monster/palace_flying_boss.gd` | `palace_boss/<monster_kind>/metadata.tres` | `geometry`（`center`/`size`/`origin`）、`masks["hit1"]`；传路径给弹体 | `_palace_data` 保存共享字典 | 未检查空字典；直接索引，失败会进入运行时错误 |
| 6 | `Script/mount/mount_visual.gd` | `Art/mount/runtime/mounts|effects/<mount>/<candidate>/metadata.tres` | `animation`、`fps`、`loop`、`frame_count`、`frames`、`back_atlases`、`front_atlases`；帧内 `back`/`front`/`ride`/`official_ride`；图层 `page`/`region`/`offset` | `data_for(...).duplicate(true)`，再补 `_base_path`；不修改共享源 | 路径不存在时在调用 Store 前返回 `{}`；动画播放返回 false。schema 错误由 Store 报错后返回空，但调用方只表现为无动画 |

### 4.1 字段契约

| 字段 | 实际结构 | 使用者 | 说明 |
|:---|:---|:---|:---|
| `pages` | `[{path: String}]` | 构建期 `convert_monster_frames` | 运行时消费者不读取；不可用它推断加载依赖 |
| `sequences` | `{name: {frames: [[frame, page, x, y, w, h, margin_l, margin_t, margin_r, margin_b]]}}` | East、Cloud、North、Palace | 运行时几何使用 `w/h/margin`；构建期使用页索引与 region |
| `geometry` | `{name: {center: [x,y], size: [w,h], origin: [x,y]}}` | Cloud、North、Palace、Projectile | `center` 用于视觉/受击中心，`size`/`origin` 用于碰撞与取景；`source_*` 仅是溯源 |
| `masks` | `{name: [[x, y, w, h] or []]}` | North、Cloud、Palace、Projectile | 空 mask 是合法“无碰撞”；不能把空数组当作缺失资源 |
| `animation` + `frames` + `back_atlases`/`front_atlases` | 动画名、FPS、loop、帧数、图集页名、逐帧 back/front/ride | MountVisual | 页名相对于 `_base_path`；`region` 与 `offset` 是显示几何 |
| `files` | 路径映射/清单 | 未发现 Store 消费者 | 不建立运行时 accessor；仅作为构建/溯源数据 |
| `animations` | 旧动画名到帧条目的映射 | `convert_monster_frames`（剑 Boss 目标） | 不作为运行时统一 schema |
| 顶层数组 `items` | 地图图层或装备图集条目 | 未发现 Store 消费者 | 不建立通用运行时模型 |

`AtlasMetadata.validate()` 目前只检查 `schema_id`/`schema_version`、顶层数组的 `items`、`animation+frames` 的数组类型，以及 `pages`/`sequences`/`files` 的浅层类型。它不校验序列帧元组长度、页索引、`geometry`/`masks` 内容、MountVisual 帧结构或 region/offset；这些是 **Phase 14-2 的类型/校验范围**。

## 5. 构建期消费者

| 工具 | 读取范围 | 当前结果 | 与运行时边界 |
|:---|:---|:---|:---|
| `scripts/convert_atlas_metadata.py` | 全部 379 个 manifest | `--check` 379 同步；`--self-test` 4 个帧数样本通过 | 生产者；输出 `metadata.tres` |
| `scripts/convert_monster_frames.py` | `Art/monster/**/metadata.tres`，其中 194 个含序列/旧动画 | 152 个目标（148 个 `sequences`，4 个旧 `animations`）；41 个空序列 + 1 个聚合宠物跳过 | 生成 `*_frames.tres`；不进入运行时 Store |
| `scripts/convert_frame_sequences.py` | 4 个剑阵 `manifest.json` 的 `pages`/`animations` | 4 套 × 3 个动作 | 生成流式帧序列；不进入运行时 Store |
| `scripts/contract_scan.py` | `.tres` 中 `script_class="AtlasMetadata"` | 跳过其内部源路径，不作为运行时依赖扫描 | 防止把构建溯源路径误算成依赖 |

构建工具的成功条件不能证明运行时消费正确；同样，运行时读取通过不能代替 `--check` 的源/生成同步。

## 6. 已发现但不在 Store 边界的引用

以下配置/常量在当前代码中没有形成 AtlasMetadata 读取链，不能在 Phase 14 中当作消费者继续类型化：

- `emei_boss3040.gd`、`emei_boss3041.gd`、`linggan_king_boss.gd`、`monster_3370.gd` 写入 `atlas_metadata`/`atlas_sequence` 配置；
- `nanhai_projectile.gd` 把 `atlas_metadata`、`impact_atlas_metadata` 读入成员变量，但当前没有读取这些成员来加载 AtlasMetadata；`_configure_atlas_visual()` 直接返回 `false`；
- `minghai_boss3117.gd`、`zhuque_street_monster.gd` 定义 `ATLAS_METADATA` 常量，但静态检索未发现其使用；
- `source_masks_metadata` 是唯一的运行时“间接 metadata 路径”配置，读取者为 `palace_boss_projectile.gd`，来源为 Cloud/North/Palace；
- `atlas_metadata` 配置应在 Phase 14-3 的受控清理中移除，前提是再次扫描确认无外部调用方；本阶段不修改源码。

`AtlasMetadataStore.validate_path()` 与 `clear_cache()` 当前没有生产调用点；`data_for("")` 直接返回 `{}`，不触发 `push_error`，与其他失败路径不一致。它们作为候选死接口/待定边界记录，不据此删除。

## 7. 失败、缓存与身份风险

| 问题 | 证据 | Phase 14 处理方向 |
|:---|:---|:---|
| 共享字典泄露可写面 | `data_for` 把 `metadata.data` 缓存并返回；除 MountVisual 外消费者保存同一引用 | 返回强类型只读视图或不可写容器；业务不可直接改源数据 |
| 空数据静默退化 | East 返回零/哨兵几何；Palace 弹体退回基类碰撞；MountVisual 返回空动画 | 明确“资源声明但不可用”与“可选资源未声明”的区别；由拥有者中止或拒绝视觉 |
| schema 校验浅层 | `AtlasMetadata.validate()` 未验证帧元组、页索引、geometry/masks、MountVisual 帧 | 在 14-2 为实际消费字段建立校验；构建期仍需保留源 schema 校验 |
| Store 公共 API 未使用 | `validate_path`/`clear_cache` 无生产调用 | 迁移时删除或降为内部；不保留无消费者兼容层 |
| metadata 无资源头 UID | `render_tres()` 未生成 `uid://`，资源身份当前是路径 | 14-2 明确选择：登记路径身份例外，或另批加入确定性 UID；不得在消费者迁移中隐式改变 |
| 旧配置残留 | 4 个 `atlas_metadata` 写入方无实际读取方 | 14-3 确认后清理配置/常量；不把它们加入 typed 消费者清单 |

## 8. Phase 14-2 最小输入

基于本矩阵，下一批只应覆盖真实运行时字段：

1. **East/Cloud/North/Palace 序列**：按需提供 `sequence` 长度、帧几何与 reg anchor；不要先建完整 `pages/files` 模型。
2. **geometry/masks**：只暴露 center/size/origin 与 mask 帧数组；保留空 mask 语义。
3. **MountVisual**：按 `animation/fps/loop/frame_count/frames/back_atlases/front_atlases` 建立最小只读视图；`official_ride` 与图层 region/offset 需保留。
4. **不建立**：`files` 通用 accessor、旧 `animations` 运行时模型、顶层数组模型、索引字典模型。
5. **失败边界**：所有声明路径的缺失/类型错误必须由消费者显式处理；不得用“typed 失败再读 `.data`”或旧路径回退。
6. **构建期**：`convert_monster_frames` 可继续直接读取源 metadata；其 152 目标与 4 个旧动画形态不要求运行时 typed 化。

## 9. 验证与复现

本次只读调查执行：

```bash
python scripts/convert_atlas_metadata.py --check
python scripts/convert_atlas_metadata.py --self-test
python scripts/convert_monster_frames.py --check
```

结果：Atlas 同步 **379/379**；帧数负向自测 **4/4**；怪物帧检查 **152 目标 / 152 校验 / 0 缺失 / 0 失败**，跳过 **42**（41 空序列、1 聚合宠物）。未修改运行时、素材或归档。

再次调查时应从当前 `source/Art/`、`scripts/convert_*.py` 与本次命令输出重新生成，不把本页数量当作长期 SLA。
