# Phase 14 归档：AtlasMetadata 类型化数据边界

> **归档日期**：2026-10-28
> **状态**：Archived
> **关联**：[Phase 15 归档](iteration_15_app_orchestration_lifecycle.md)、[AtlasMetadata 矩阵](../reference/atlas_metadata_schema.md)、[ADR-022](../decisions/ADR-022-atlas-metadata-view-and-path-identity.md)
>
> Phase 14 已完成：14-1~14-4 全部完成；六个直接消费者已走只读 View，旧 `data_for`/`validate_path`/`clear_cache`、`source_masks` 与惰性 atlas 配置已删除，`contract_scan.py` 已加入 AtlasMetadata 边界守卫。
> **版本**：6.9；不新增玩法、任务、掉落，不改变数值、存档格式或本地双人共享规则。
> **职责**：本页保存 Phase 14 的边界、批次、验证与恢复记录；后续阶段方向统一见 [`roadmap.md`](../roadmap/roadmap.md)。
> **依据**：[`总体目标契约`](../standards/target_architecture_contract.md) §3、§5、§7、§10~§11；[`architecture.md`](../reference/architecture.md)、[`atlas_metadata_schema.md`](../reference/atlas_metadata_schema.md)、[`acceptance.md`](../reference/acceptance.md)、[`status.md`](../reference/status.md)。
> **历史**：[Phase 13](iteration_13_visual_asset_contract.md) 已完成归档，历史不改写。

## 1. 阶段边界与决策

### 1.1 目标

以 AtlasMetadata 为有限试点，收敛源数据、共享只读定义与消费者访问边界，为后续模块治理提供一种可验证模式，而非把所有业务数据包装成资源。

- 保留正式源数据与现有资源身份；只改变读取、验证与失败传播。
- 构建校验覆盖真实 schema；运行时类型 API 覆盖实际消费字段，不为无消费者 schema 建完整对象体系。
- 所有生产调用方迁移完成后删除旧字典返回入口，禁止 deprecated/public 双路径。
- 不泄露可修改的共享容器，不复制 Texture2D/图集页；返回类型不等于自动不可变。
- 静态可序列化定义优先 Resource；纯运行时视图可用强类型 RefCounted。由生命周期与序列化需求决定，不先造一套通用类型框架。

### 1.2 不在本阶段

- 不重写 `player_data`，不把 JSON 存档改为 `.tres`；
- 不抽取全部 Global、改存档/双人视图、不重构战斗继承、不搬迁顶层目录；
- 不把 AtlasMetadata 变成所有资产中间层，不统一 Spine/SpriteFrames/FrameSequence 播放器；
- 不更改素材内容、region/margin、动画时序、loop、页路径、UID 或后端选择；
- 不重开 Phase 13 的冻结例外，不借类型化恢复缺资源回退。

### 1.3 当前事实与调查结果

| 现有边界 | 已知事实 | 本阶段取证要求 |
|:---|:---|:---|
| `AtlasMetadata` | Resource，`data: Dictionary`；当前无源码直接读 `.data`，均经 Store | 14-1 已核对实际 schema 与字段 |
| `AtlasMetadataStore` | 唯一公开入口为 `view_for`，缓存并返回深度校验后的 View；`data_for`、`validate_path`、`clear_cache` 已删除。Cloud、East、North、PalaceBossProjectile、PalaceFlyingBoss、MountVisual 均已接入 | 14-2/14-3A/14-3B-1/14-3B-2/14-3B-3/14-4 已完成 |
| 源 schema | 379 个 manifest，8 种顶层形态；运行时只消费 `pages+sequences` 与 `animation+frames` | 不为 `files`/旧 `animations`/数组/索引建运行时模型 |
| 直接消费者 | `cloud_boss`、`east_continent_monster`、`north_continent_monster`、`palace_boss_projectile`、`palace_flying_boss`、`mount_visual` | 已逐项记录字段、共享/复制与失败行为 |
| 构建入口 | `convert_atlas_metadata.py` 379/379 同步；`convert_monster_frames.py` 152 目标/42 跳过 | 构建校验与运行时类型化分开 |
| Phase 13 已收口路径 | `main_sword_array_weapon` 已删除 Atlas 回退 | 不将其重新列为待迁移消费者 |

14-1 的详细证据、资源域和构建期边界见 [`atlas_metadata_schema.md`](../reference/atlas_metadata_schema.md)。14-1~14-4 已完成；本页保留 Phase 14 收口记录，后续候选由 [`roadmap.md`](../roadmap/roadmap.md) 维护。本页中的后续类型名称是设计候选，不是现有符号。

## 2. 批次 14-1：生产/消费边界与 schema 决策（已完成）

**状态**：完成（2026-10-28）；只读调查与文档记录，无运行时/素材改动。

### 2.1 实施记录

| 项目 | 结果 |
|:---|:---|
| 生产者 | 仓库内唯一转换器 `convert_atlas_metadata.py`，把 379 个 `manifest.json` 生成同目录 `metadata.tres`；`--check` 379/379 同步，`--self-test` 4/4 通过 |
| 运行时入口 | 14-1 调查时 6 个 `AtlasMetadataStore.data_for` 调用点；迁移后旧入口与 `validate_path()`/`clear_cache()` 已删除 |
| 运行时资源域 | 267 个 metadata 路径可触达：East 83、North 51、Palace 2、Cloud 1、Mount 86+44；Palace 弹体复用前三域，不新增路径域 |
| schema 实际形态 | 379 个 manifest 分 8 组顶层形态、18 种键签名；运行时只直接消费 `pages+sequences`（East/Cloud/North/Palace）与 `animation+frames`（Mount） |
| 非运行时形态 | `files`、旧 `animations`、顶层数组、索引/其它字典：未发现 Store 读取；4 个剑阵 `animations` 由构建期帧转换器读取 |
| 共享与复制 | Store 缓存并返回 `AtlasMetadata.data` 同一字典；Mount 复制后加 `_base_path`，其余消费者保存共享引用 |
| 已发现风险 | 空路径静默返回 `{}`；多个消费者未检查空数据；Palace 弹体在声明路径不可用时退回基类碰撞；schema 校验未覆盖帧元组/geometry/masks/Mount 帧 |
| 身份 | 生成的 metadata 无资源头 `uid://`；当前以路径引用。已按 [ADR-022](../decisions/ADR-022-atlas-metadata-view-and-path-identity.md) 登记路径身份例外，不新增 UID |
| 惰性配置 | 4 个 `atlas_metadata` 写入方无实际读取链；`nanhai_projectile` 读入成员但未使用；2 个 `ATLAS_METADATA` 常量未使用；不作为类型化消费者 |
| 构建期边界 | `convert_monster_frames.py`：194 个怪物 metadata 中 152 目标（148 sequences + 4 旧 animations），42 跳过；`convert_frame_sequences.py` 读取 4 个剑阵 manifest 的 `pages/animations` |

### 2.2 结论

1. 原“四种 schema”假设不适用于实际源数据；不能按四种模型强行统一。
2. 运行时只需覆盖真实字段：序列帧几何、`geometry`/`masks`、Mount 动画帧与图层；`files`、旧 `animations`、顶层数组不建立运行时类型。
3. 失败语义必须先于 consumer 迁移：声明路径缺失、类型错误、空序列和空 mask 需要区分；当前静默退化/基类回退不能原样保留。
4. 14-2 已在 PalaceBossProjectile 处理声明路径失败；14-3B-1 已将 PalaceFlyingBoss 自有 geometry/masks 迁到 View；14-3B-2 已将 East/Cloud 与 Palace 继承序列路径迁到 View；14-3B-3 已迁移 North 并删除旧入口。空路径与失败语义由 `view_for` 统一报告；14-4 清理惰性配置并加入边界守卫。

**出口核对**：每个直接消费者均有字段与失败路径记录；只构建使用的 schema 已列明；没有新增未调查调用。14-2 已按此矩阵完成 PalaceBossProjectile 试点。

## 3. 批次 14-2：最小 View 与 PalaceBossProjectile 试点（已完成）

**状态**：完成（2026-10-28）；首个真实消费者已迁移，未继续迁移其它消费者。

### 3.1 实施记录

| 项目 | 结果 |
|:---|:---|
| View | 新增 `source/Script/atlas/atlas_metadata_view.gd`（`RefCounted`）；校验 `pages+sequences` 的页、序列帧元组/页索引、geometry、masks；提供值查询，不复制帧数据 |
| Store | 新增 `AtlasMetadataStore.view_for(path)`；路径为空报错，非空路径缺失/类型错误/schema 错误返回 `null`；按路径缓存 View 与失败结果 |
| 消费者 | `PalaceBossProjectile` 的 masks/geometry 改读 View；非空 metadata 路径无效时 `configure()` 返回 `false`；NorthBossProjectile 的 `source_masks` 覆盖当时保留，已在 14-3B-3 删除 |
| 未迁移 | East、North、Cloud、PalaceFlyingBoss、MountVisual 在 14-2 当时仍使用 `data_for`；Mount 已在 14-3A 完成，PalaceFlyingBoss 自有 geometry/masks 已在 14-3B-1 完成，East/Cloud 已在 14-3B-2 完成，North 已在 14-3B-3 完成 |
| 身份 | 按 [ADR-022](../decisions/ADR-022-atlas-metadata-view-and-path-identity.md) 保持 metadata 路径身份，不新增 UID |
| 范围 | 未修改 `source/Art/`、素材内容、既有 UID、数值/动画时序；未清理惰性 `atlas_metadata` 配置 |

### 3.2 验证

- 临时 GDScript 探针：137 个 `pages+sequences` 运行时资源建立 View，**137/137 PASS**；探针已删除。
- `level_73`、`level_74`、`level_75` 冒烟 PASS，日志 **0 ERROR / 0 WARNING**。
- `check_all --godot-bin` **8/8 PASS**；`health_check` **0 Parse / 0 Error / 0 Warning**。
- 既有 Atlas 同步 **379/379**、负向自测 **4/4**、怪物帧 **152 目标/42 跳过**不变。

### 3.3 出口核对

- 首个真实消费者运行正常；非空声明路径失败不再静默回退。
- View 不暴露可写共享容器；序列/mask 值返回原生值类型，不建立逐帧对象。
- `data_for`、`validate_path`、`clear_cache` 与 `NorthBossProjectile.source_masks` 已删除；业务只走 `view_for`。
- Mount、PalaceFlyingBoss、East/Cloud 与 North 已分别由 14-3A、14-3B-1、14-3B-2、14-3B-3 完成；Phase 14 只剩 14-4 的边界守卫与惰性配置清理。

## 4. 批次 14-3A/14-3B：生产消费者闭环迁移

**状态**：14-3A、14-3B-1、14-3B-2、14-3B-3、14-4 已完成。

### 4.1 14-3A：Mount（已完成）

- `AtlasMetadataView` 扩展 `animation+frames`：校验 fps/loop/frame_count、back/front 图层、rider/official_ride transform；
- `MountVisual` metadata 分支改用 `view_for`，移除 `data_for` 与 `_metadata_cache`；原生骨骼 parts 分支保留；
- 视图覆盖 130 个 Mount 资源；metadata 动画 `aoyi_skill` 的实际播放与视觉边界通过；
- 未修改素材、UID 或骨骼 parts 数据。

### 4.2 14-3B-1：PalaceFlyingBoss（已完成）

- 删除 `_palace_data` 共享字典；`_resolve_runtime_config` 改用 `view_for`，`_visual_offset`、`_keep_in_view`、`_sync_attack_collision` 只通过 View 读取 `geometry` 与 `masks`；
- `AtlasMetadataView` 增加 `geometry_origin` / `geometry_size`；`geometry_center`、`geometry_origin`、`geometry_size` 统一走同一个已校验 geometry 入口；
- View 无效时 PalaceFlyingBoss 自有几何退化为零值并禁用 hit1 碰撞，不再直接索引裸字典；
- 验证覆盖 3323/3343 的 `wait` geometry 与 `hit1` masks，并与原始 `AtlasMetadata.data` 逐值比较；`level_73` / `level_74` 冒烟 PASS；
- 继承 East 的序列辅助在 14-3B-2 已切换到 View；本切片本身只覆盖 PalaceFlyingBoss 自有读取；
- 未修改素材、UID 或动画时序。

### 4.3 14-3B-2：East + Cloud（已完成）

- `EastContinentMonster._get_east_metadata` 改为 `_east_metadata_view`，删除 `_east_metadata_cache`；`_seq_frame_count`、`_seq_reg_anchor`、`_frame_geom` 改用 View 的值查询；
- `CloudBoss._source` 改为 `_cloud_view`，`_visual_offset` 只用 `geometry_center`；
- 该切片同时关闭 PalaceFlyingBoss 的继承 East 序列路径；
- 临时探针遍历 **149** 个 `pages+sequences` 资源、**1310** 个序列、**40222** 帧，逐帧比较长度、registration anchor、center/size/has_visual，**PASS**；
- `level_72`（East）、`level_75`（Cloud）冒烟 PASS；`level_73` / `level_74`（Palace 继承路径）在最终验证中复跑；
- 未修改素材、UID 或动画时序。

### 4.4 14-3B-3：North（已完成）

- `NorthContinentMonster` 删除 `_source`，改用 `_north_view` 与 `_has_sequence` / `_sequence_frame_count` / `_geometry_*` 查询；
- `NorthBossProjectile` 删除 `source_masks` 字典；mask alias 通过 `mask_sequence` 配置选择 View 中的 mask 序列；
- 删除 `AtlasMetadataStore.data_for`、`validate_path`、`clear_cache`，业务只走 `view_for`；
- 临时探针覆盖 **51** 个 North 资源、**586** 个序列、**20263** 帧、**1788** 个 mask，逐值比较 **PASS**；
- `level_76`、`level_81`（North）冒烟 PASS；全量关卡回归 **PASS 128/128 + SKIP 5，FAIL 0**（696.2s）；
- 剩余 4 个惰性 `atlas_metadata` 写入方、2 个未使用常量与 `nanhai_projectile` 惰性成员归入 14-4；未修改素材、UID 或动画时序。

**出口**：生产代码只走新正式入口；无外部 `.data` 访问；无双加载/失败回退；需要可变工作数据的消费者不修改共享定义。

## 5. 批次 14-4：边界守卫与收口

**状态**：已完成（2026-10-28）。

- 核对完整生产调用面，不仅搜索一个方法名；区分资源声明、构建数据与运行时访问。
- 如需长期访问守卫，扩展现有审计的明确检查项，并登记 `scripts/README.md` 与 `acceptance.md`；未实现前不得声称已有门禁自动阻断。
- 源/生成内容一致、UID 稳定、依赖清单不意外膨胀；转换器不得改不属于自己的输出。
- 更新实际架构、验收覆盖与带日期状态；只在全部出口满足后标记完成。
- 已删除 4 个无读取方的 `atlas_metadata` 写入方、2 个未使用 `ATLAS_METADATA` 常量与 `nanhai_projectile` 的惰性成员；
- `contract_scan.py` 新增第七类 `atlas_boundary` 门禁与负向自测：旧 `data_for`/`validate_path`/`clear_cache`、非 View `.data` 读取、`source_masks` 覆盖均阻断；
- `scripts/README.md`、`acceptance.md` 与 `docs/reference/atlas_metadata_schema.md` 已登记守卫与失败边界；
- L2 固定套件：`level_1` PASS、`coop_probe_runner` **16/16 PASS**、`scene_probe_runner` **4/4 PASS**；
- 全量关卡回归 **PASS 128/128 + SKIP 5，FAIL 0**（731.3s；`level_dsg_1` 首次瞬态 FAIL，单关重试 PASS）；
- `check_all --godot-bin` **8/8 PASS**；`health_check` **0 Parse / 0 Error / 0 Warning**；未执行 release 重验。

## 6. 验证矩阵

既有命令与档位以 [`acceptance.md`](../reference/acceptance.md) 为准，不在本页复制或虚构参数。

| 批次/变更 | 必需证据 | 不必无差别执行 |
|:---|:---|:---|
| 14-1 只读调查/文档 | 源码引用、完整矩阵、链接与格式 | 引擎、全量回归、release 不因文档变更复跑 |
| 14-2 资源 API/校验 | 转换器同步/负向样本、L1、真实消费者正常与错误资源冒烟 | 只做非空或编译检查不能代替行为 |
| 14-3 消费者 | 定向场景与相关关卡；读取值/几何/时序；共享资源不被修改；相关 1P/2P 路径 | 不以一个通用探针替代所有被改消费者 |
| 14-4 阶段收口 | L2 固定套件、全量回归、构建/引用/命名检查；调用面清零证据 | 包路径/序列化/导出无变化时不强制重导每批 release |
| 影响资源类型/路径/导出 | 实际 PCK 闭包与 release 加载 | 元数据或源文件可达不等于包可加载 |

14-1 的已完成证据：Atlas **379/379** 同步、负向自测 **4/4**、怪物帧 **152 目标/42 跳过**；这些是 2026-10-28 的只读构建检查，不是运行时回归。

14-2/14-3A 的已完成证据：View **267/267**（137 `pages+sequences` + 130 `animation+frames`）；`MountVisual` metadata 动画与边界 PASS；`level_73` / `level_74` / `level_75` 冒烟 PASS；`check_all --godot-bin` **8/8 PASS**；`health_check` **0 Parse / 0 Error / 0 Warning**。未执行全量关卡回归、L2 全固定套件或 release 重验；这些不因试点被宣称通过。

14-3B-1 的已完成证据：3323/3343 的 `geometry`（`center`/`size`/`origin`）与 `hit1` masks 从 View 读取并与原始 `.data` 逐值比较 **PASS**；`level_73` / `level_74` 冒烟 PASS（0 ERROR / 0 WARNING）；`check_all --godot-bin` **8/8 PASS**；`health_check` **0 Parse / 0 Error / 0 Warning**。继承 East 序列辅助已在 14-3B-2 切换到 View。

14-3B-2 的已完成证据：East/Cloud 辅助探针覆盖 **149** 个序列资源、**1310** 个序列、**40222** 帧，逐帧比较帧数、registration anchor、center/size/has_visual **PASS**；`level_72`（East）与 `level_75`（Cloud）冒烟 PASS（0 ERROR / 0 WARNING）；全量关卡回归 **PASS 128/128 + SKIP 5，FAIL 0**（682.3s），覆盖 `level_73`/`level_74` 的 Palace 继承路径。

14-3B-3 的已完成证据：North View 探针覆盖 **51** 个资源、**586** 个序列、**20263** 帧、**1788** 个 mask，逐值比较 **PASS**；`level_76`、`level_81` 冒烟 PASS（0 ERROR / 0 WARNING）；全量关卡回归 **PASS 128/128 + SKIP 5，FAIL 0**（696.2s）。

14-4 的已完成证据：`contract_scan.py --self-test` 的 AtlasMetadata 边界坏样本 **5/5** 拦截、好样本 **4/4** 放行；L2：`level_1` PASS、`coop_probe_runner` **16/16 PASS**、`scene_probe_runner` **4/4 PASS**；全量关卡回归 **PASS 128/128 + SKIP 5，FAIL 0**（731.3s，`level_dsg_1` 单次瞬态重试通过）；`check_all --godot-bin` **8/8 PASS**；`health_check` **0 Parse / 0 Error / 0 Warning**；未执行 release 重验。

涉及运行探针与枚举 `source/` 的门禁串行运行。临时夹具在结束后移除，不进入发布。完整私有工作区维持零错误零警告；未执行验证显式记录为未验证。

## 7. 阶段出口与恢复

- 所有实际运行时消费者迁移，旧公共入口与兼容分支删除；未消费源 schema 保持完整构建校验。
- 无可写共享容器泄露；页/纹理未重复常驻；行为与资源身份不变。
- 构建、L1、定向冒烟、L2 与阶段回归满足矩阵；发布变更按触发条件验证。
- 文档、ADR、脚本索引与状态一致；14-1/14-2/14-3A/14-3B-1/14-3B-2/14-3B-3/14-4 的字段矩阵保留在 reference，不复制进阶段目标。

中断时从 14-1 矩阵与已验证切片恢复；失败回滚该逻辑批次，不恢复旧来源回退。阶段全部完成后只归档本页的 Phase 14 记录，再重新建立下一候选计划；后续方向继续以 roadmap 为准。

**恢复入口**：Phase 14 已完成；如需复核，从 [`atlas_metadata_schema.md`](../reference/atlas_metadata_schema.md) 的消费者表与 `contract_scan.py` 的 `atlas_boundary` 规则继续；归档后本页转为历史记录。

**下一候选顺序**：Phase 15 应用编排/运行资源 → Phase 16 档案会话/持久化/槽位 → Phase 17 玩法/表现边界。该顺序是风险优先队列，不是 AtlasMetadata 对全部架构工作的强制技术前置。
