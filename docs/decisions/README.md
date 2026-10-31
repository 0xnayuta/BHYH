# 架构决策记录 (Architecture Decision Records)

> **状态**：活跃索引（2026-10-25 新建）。
>
> **定位**：记录项目已接受的架构选择及替代关系。历史回溯记录与后续新决策并存；Accepted 表示决策有效，不表示所有迁移工作已经完成。

---

## 1. 记录格式

每个 ADR 包含：

- **状态**：使用 `Accepted`、`Superseded` 等明确状态，并保留替代关系；
- **背景**：问题、约束与触发条件；
- **决策**：明确执行的选择；
- **后果**：收益、代价与必须遵守的约束；
- **备选方案**：当时未选择的路径及原因；
- **证据**：规范、代码、脚本、归档或提交记录。

ADR 只记录**架构级、跨模块、长期有效**的决定；局部实现细节写入 `docs/reference/architecture.md` 或代码注释。

---

## 2. 索引

| 编号 | 决策 | 状态 | 主要影响 |
|:---|:---|:---:|:---|
| [ADR-001](ADR-001-single-active-godot-project.md) | 仓库只保留一个活跃 Godot 工程 | Accepted | 仓库结构、构建、发布 |
| [ADR-002](ADR-002-godot-4-7-2-and-gdscript-baseline.md) | Godot 4.7.2 + GDScript 2.0 基线 | Accepted | 引擎、语言、渲染 |
| [ADR-003](ADR-003-modern-godot-design-with-legacy-exceptions.md) | 新代码遵循 Godot 现代设计规范，遗留结构登记例外 | Accepted | 场景、Resource、Autoload |
| [ADR-004](ADR-004-naming-contract-and-frozen-whitelist.md) | 全工程命名契约与冻结白名单 | Accepted | 目录、文件、节点、标识符 |
| [ADR-005](ADR-005-no-compatibility-or-fallback-layers.md) | 不保留兼容层、回退层与跨版本迁移链 | Accepted | 资源加载、存档、配置 |
| [ADR-006](ADR-006-resource-first-data-and-data-keys.md) | 新结构化数据优先 Resource，存量字典走 DataKeys | Accepted | 数据模型、配置 |
| [ADR-007](ADR-007-autoload-boundary.md) | 保留 Autoload 注册基线，新增必须评审（当前 11 个） | Accepted | 全局状态、生命周期 |
| [ADR-008](ADR-008-type-based-directories-with-feature-subdirectories.md) | 保留类型分层目录，新功能按功能子目录聚合 | Accepted | 项目结构 |
| [ADR-009](ADR-009-build-time-visual-asset-pipeline.md) | 视觉资源构建期生成，运行时只读类型资源 | Superseded by ADR-020 | 历史资产管线决策 |
| [ADR-010](ADR-010-spine-runtime-boundary.md) | Spine 保持骨骼运行时，不烘焙为 SpriteFrames | Accepted | 角色特效、平台库 |
| [ADR-011](ADR-011-public-repository-asset-boundary.md) | 公开仓库排除第三方素材，代码 MIT | Accepted | 许可证、发布 |
| [ADR-012](ADR-012-zero-error-zero-warning-quality-gates.md) | 零错误零警告与八维门禁为合并门槛 | Accepted | 质量流程 |
| [ADR-013](ADR-013-tool-guaranteed-path-migration.md) | `source/` 内路径迁移只走 `rename_path.py` | Accepted | 重命名、引用同步 |
| [ADR-014](ADR-014-three-way-semantic-merge-for-version-migration.md) | 版本迁移使用三方语义合并，禁止整包覆盖 | Accepted | 版本迁移 |
| [ADR-015](ADR-015-documentation-layering-and-single-source-of-truth.md) | 文档分层，`status.md` 为状态单一事实源 | Accepted | 文档维护 |
| [ADR-016](ADR-016-display-canvas-window-and-hud-baseline.md) | 1280×800 画布、1600×1000 窗口与桌面 HUD 基线 | Accepted | 显示、HUD、多分辨率 |
| [ADR-017](ADR-017-local-coop-profile-isolation.md) | 本地双人使用独立档案实例与槽位路由 | Accepted；§5 长期策略由 ADR-021 替代并已迁移 | 隔离/共享规则继续有效；16-5 已删除全局视图交换 |
| [ADR-018](ADR-018-runtime-resource-cache-prewarm-and-pooling.md) | 运行期缓存、分阶段预热与对象池 | Accepted | 性能、加载 |
| [ADR-019](ADR-019-test-fixtures-outside-production-source.md) | 测试探针与夹具不进入生产源码 | Accepted | 测试、发布 |
| [ADR-020](ADR-020-typed-visual-assets-and-streaming-lifecycle.md) | 类型化视觉资产、显式后端与流式生命周期 | Accepted | 三层契约、请求回收、导出闭包 |
| [ADR-021](ADR-021-project-wide-target-architecture.md) | Godot 原生场景组合与项目总体目标架构 | Accepted（目标） | 总体所有权/生命周期；局部替代 ADR-017 §5 的长期 UI 交换策略，保留 ADR-020 |
| [ADR-022](ADR-022-atlas-metadata-view-and-path-identity.md) | AtlasMetadata 只读 View、路径身份与失败语义 | Accepted | 运行时 View、`.data` 边界、路径例外、迁移与失败处理 |
| [ADR-023](ADR-023-level-layout-data-contract.md) | 关卡布局走构建期生成的 Resource，绞杀式迁移脚本内数据表 | **Proposed** | 关卡数据载体、`BaseLevel` 扩展点默认实现、生成器与迁移批次 |

### 2.1 常见决策检索

| 问题 | 对应 ADR |
|:---|:---|
| 新代码该遵循什么场景/Resource/Autoload 规则？ | [ADR-003](ADR-003-modern-godot-design-with-legacy-exceptions.md) |
| 文件、目录、节点、字典键怎么命名？ | [ADR-004](ADR-004-naming-contract-and-frozen-whitelist.md) |
| 能否保留旧路径、旧清单、旧存档的兼容分支？ | [ADR-005](ADR-005-no-compatibility-or-fallback-layers.md) |
| 新配置/数据放字典还是 Resource？ | [ADR-006](ADR-006-resource-first-data-and-data-keys.md) |
| 能否新增 Autoload？ | [ADR-007](ADR-007-autoload-boundary.md) |
| 新功能目录放哪里？ | [ADR-008](ADR-008-type-based-directories-with-feature-subdirectories.md) |
| 动画帧、图集、Spine 如何生产与加载？ | [ADR-020](ADR-020-typed-visual-assets-and-streaming-lifecycle.md)、[ADR-010](ADR-010-spine-runtime-boundary.md) |
| 提交前必须跑哪些门禁？ | [ADR-012](ADR-012-zero-error-zero-warning-quality-gates.md) |
| 版本迁移能否整包覆盖？ | [ADR-014](ADR-014-three-way-semantic-merge-for-version-migration.md) |
| 本地双人数据为什么不是第二个 Autoload？ | [ADR-017](ADR-017-local-coop-profile-isolation.md) |
| 项目总体目标、状态所有权和后续架构治理以什么为准？ | [ADR-021](ADR-021-project-wide-target-architecture.md)；视觉资源子契约仍见 ADR-020 |
| AtlasMetadata 运行时如何读取、为什么没有 UID？ | [ADR-022](ADR-022-atlas-metadata-view-and-path-identity.md)；矩阵见 [`../reference/atlas_metadata_schema.md`](../reference/atlas_metadata_schema.md) |

---

## 3. 维护规则

1. 新增 ADR 使用 `ADR-<三位编号>-<英文短名>.md`，编号不复用；
2. 已接受的 ADR 不直接改写结论；需要变更时新增 ADR，并在旧文档中标注 `Superseded by ADR-xxx`；
3. 每条决策必须能追溯到规范、代码或归档；禁止把个人偏好写成项目决策；
4. 新增/修改 ADR 后同步本索引与 [`../README.md`](../README.md) 的文档入口；
5. ADR 不记录本地路径、密钥、二进制位置或临时迁移台账。

---

## 4. 相关入口

- [`../reference/architecture.md`](../reference/architecture.md)：当前运行时架构与遗留边界
- [`../standards/target_architecture_contract.md`](../standards/target_architecture_contract.md)：项目总体目标与子系统契约，不是完成声明
- [`../reference/acceptance.md`](../reference/acceptance.md)：验收命令、判据与阈值
- [`../reference/status.md`](../reference/status.md)：版本、规模与验证状态
- [`../standards/README.md`](../standards/README.md)：活跃规范索引
- [`../guides/migration_playbook.md`](../guides/migration_playbook.md)：版本迁移方法
- [`../../AGENTS.md`](../../AGENTS.md)：工程摘要与红线
