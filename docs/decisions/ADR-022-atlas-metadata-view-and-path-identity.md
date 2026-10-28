# ADR-022：AtlasMetadata 只读 View、路径身份与失败语义

- **状态**：Accepted
- **记录日期**：2026-10-28
- **关联**：ADR-006、ADR-015、ADR-020、ADR-021
- **范围**：AtlasMetadata 的运行时读取边界；不改变素材、数值、动画时序或现有 UID

## 背景

AtlasMetadata 由 `manifest.json` 构建为同目录 `metadata.tres`，`AtlasMetadata.data` 完整保存源结构。Phase 14-1 调查确认：

- 379 个 manifest 分为 8 种顶层形态，运行时只实际消费 `pages+sequences` 与 `animation+frames`；
- 仅 6 个 `AtlasMetadataStore.data_for` 直接调用点；
- `data_for` 返回共享 `Dictionary`，多个消费者保存同一引用；
- 空路径静默返回空字典；
- 多个消费者在资源缺失时退化或回退，而不是拒绝；
- 生成的 metadata 没有资源头 UID，当前以路径引用；
- `files`、旧 `animations`、顶层数组与索引字典不属于运行时类型边界。

继续让业务直接读取裸字典，会把可写状态、重复校验和隐式失败扩散到更多模块；把 379 个资源改成嵌套 typed Resource 又会扩大构建与资源改造成本，且不解决运行时生命周期问题。

## 决策

1. `AtlasMetadata` 继续作为 `.tres` 的序列化资源；`data: Dictionary` 只保留为资源序列化与其拥有者实现细节。
2. 新增 `AtlasMetadataView`（`RefCounted`）作为运行时只读适配器；`AtlasMetadataStore` 提供按路径缓存的 `view_for(path)`，业务不再直接读取 `.data`。
3. View 是**惰性、值返回**的 facade，不复制完整源数据，不为每帧创建 `RefCounted`。只缓存校验结果与必要的轻量索引；几何、区域、mask、播放参数以原生值类型返回。
4. 运行时只支持真实消费的 schema 家族：`pages+sequences` 与 `animation+frames`。`files`、旧 `animations`、顶层数组、索引字典不建立通用运行时模型。
5. AtlasMetadata 的稳定身份是 `res://.../metadata.tres` 路径加 `schema_id`/`schema_version`，不新增 `uid://`。原因是生成物由构建器写入固定路径，当前无编辑器资源引用或跨路径引用；加 UID 会修改全部生成文件和转换器，却不改善当前边界。路径迁移仍必须走项目迁移工具并保持生成确定性。该选择是 ADR-020 §4.3 的明确例外，需持续通过构建检查保持路径身份稳定。
6. 失败语义固定为：
   - 空路径表示调用方未请求可选资源，调用方不得把空路径传给 Store；
   - 非空路径缺失、资源类型错误、schema 错误返回 `null` 并报告，不猜字段、不回退；
   - 合法空 mask 表示该帧无碰撞，不是资源失败；
   - 已声明路径不可用时，拥有者拒绝创建/播放对应视觉或对象，不使用旧路径、基类静默回退或默认空数据掩盖。
7. 迁移按单一职责切片：先迁移一个真实消费者，再扩展同一 View 的字段；最后一个消费者迁移完成后删除旧 `data_for` 公共路径、无生产调用的辅助入口与惰性配置。
8. 构建期仍负责源数据/生成物一致性与完整 schema 校验；运行时 View 仍做一次接纳校验，防止被外部或损坏资源绕过构建期。

## 后果

- 业务只接收值或只读查询，不再能修改共享 metadata；
- `data_for` 在迁移期保留给未迁移消费者，不能成为永久双 API；
- 旧 `atlas_metadata` 配置和 `validate_path`/`clear_cache` 等无消费者入口不能作为新消费者保留；
- 资源身份是路径；任何路径变化必须由迁移工具同步，构建 `--check` 必须保持确定性；
- 不为 `files`、旧 `animations`、顶层数组建立“万能 accessor”；
- 失败会更早暴露，原先静默退化路径可能在迁移时表现为拒绝创建，这是预期行为。

## 本次实施范围

Phase 14-2 / 14-3A / 14-3B-1 已实现：

- `AtlasMetadataView`（`source/Script/atlas/atlas_metadata_view.gd`）提供 `pages+sequences` 与 `animation+frames` 的只读查询；
- `AtlasMetadataStore.view_for()` 按路径缓存并返回经过 schema 校验的 View；失败返回 `null`；
- `PalaceBossProjectile` 的 masks/geometry 读取迁移到 View；声明路径失效时 `configure()` 返回失败；
- `MountVisual` 的 metadata 动画读取迁移到 View；原生骨骼 `_bone_index` 分支继续使用既有 parts 数据，不伪造 metadata；
- `PalaceFlyingBoss` 自有 `geometry`（`center`/`size`/`origin`）与 `masks` 迁移到 View；继承 East 的序列辅助仍走 `data_for`，归入 14-3B-2；
- `data_for` 继续服务 East、North、Cloud 及 PalaceFlyingBoss 的继承序列辅助；`source_masks` 保留给 NorthBossProjectile 迁移期覆盖；
- 未修改 `source/Art/`、素材内容或既有 UID。

验证：View 覆盖 267 个运行时资源（137 个 `pages+sequences`、130 个 `animation+frames`），**267/267 PASS**；`MountVisual` metadata 动画 `aoyi_skill` 播放与视觉边界 PASS；Palace 3323/3343 的 geometry 与 `hit1` masks 逐值比对 PASS；`level_73`、`level_74`、`level_75` 冒烟 PASS（0 ERROR / 0 WARNING）；`check_all --godot-bin` **8/8 PASS**；`health_check` 0 Parse / 0 Error / 0 Warning。

后续消费者按 `current-iteration.md` 的切片迁移；East/Cloud/North 与 PalaceFlyingBoss 的继承序列路径属于 14-3B-2/3，不在本次范围。禁止以本 ADR 为依据开展全量重写。

## 备选方案

- **把 379 个 metadata 改为嵌套 typed Resource**：生成物与帧图数量巨大，增加文件、加载和 UID 管理成本，不采用。
- **把 typed 方法直接放在 `AtlasMetadata`**：序列化资源承担运行时派生状态，且仍暴露 `data`，不采用。
- **为每帧创建 View 对象**：East/Mount 的高频逐帧查询会产生大量分配，不采用。
- **立即给全部 metadata 加 UID**：没有对应编辑器引用，产生大范围生成文件变化，不采用。
- **保留 `data_for` 作为永久便利入口**：双 API 会让旧裸字典路径长期存活，不采用。

## 证据

- [Phase 14 矩阵与试点](../reference/atlas_metadata_schema.md)
- [当前架构](../reference/architecture.md) §6
- [验收标准](../reference/acceptance.md)
- [总体目标契约](../standards/target_architecture_contract.md) §5、§7、§11
- [ADR-020](ADR-020-typed-visual-assets-and-streaming-lifecycle.md)
- [Phase 14 当前迭代](../roadmap/current-iteration.md)
