# 架构决策记录索引（ADR）

本目录记录架构决策。`Accepted` 表示决策仍有效，不代表迁移已完成；被替代的决定在状态列标明。

## 决策索引

| 编号 | 决策摘要 | 状态 |
|:---|:---|:---:|
| [ADR-001](ADR-001-single-active-godot-project.md) | 只保留一个活跃 Godot 工程 | Accepted |
| [ADR-002](ADR-002-godot-4-7-2-and-gdscript-baseline.md) | Godot 4.7.2 与 GDScript 2.0 基线 | Accepted |
| [ADR-003](ADR-003-modern-godot-design-with-legacy-exceptions.md) | 新代码遵循现代 Godot 设计，登记遗留例外 | Accepted |
| [ADR-004](ADR-004-naming-contract-and-frozen-whitelist.md) | 全工程命名契约与冻结白名单 | Accepted |
| [ADR-005](ADR-005-no-compatibility-or-fallback-layers.md) | 不保留兼容、回退或跨版本迁移层 | Accepted |
| [ADR-006](ADR-006-resource-first-data-and-data-keys.md) | 结构化数据优先 Resource；存量字典使用 DataKeys | Accepted |
| [ADR-007](ADR-007-autoload-boundary.md) | 限定 Autoload 边界，新增须评审 | Accepted |
| [ADR-008](ADR-008-type-based-directories-with-feature-subdirectories.md) | 保留类型分层，新功能按功能子目录组织 | Accepted |
| [ADR-009](ADR-009-build-time-visual-asset-pipeline.md) | 视觉资源构建期生成 | Superseded by ADR-020 |
| [ADR-010](ADR-010-spine-runtime-boundary.md) | Spine 保持骨骼运行时，不烘焙为 SpriteFrames | Accepted |
| [ADR-011](ADR-011-public-repository-asset-boundary.md) | 公开仓库排除第三方素材；项目代码采用 MIT | Accepted |
| [ADR-012](ADR-012-zero-error-zero-warning-quality-gates.md) | 零错误/零警告质量门禁历史基线 | Accepted; 扩展见 ADR-024 |
| [ADR-013](ADR-013-tool-guaranteed-path-migration.md) | `source/` 路径迁移使用 `rename_path.py` | Accepted |
| [ADR-014](ADR-014-three-way-semantic-merge-for-version-migration.md) | 版本迁移采用三方语义合并，禁止整包覆盖 | Accepted |
| [ADR-015](ADR-015-documentation-layering-and-single-source-of-truth.md) | 文档分层与单一事实源 | Accepted |
| [ADR-016](ADR-016-display-canvas-window-and-hud-baseline.md) | 画布、窗口和桌面 HUD 基线 | Accepted |
| [ADR-017](ADR-017-local-coop-profile-isolation.md) | 本地双人档案隔离与槽位路由 | Accepted; §5 由 ADR-021 替代 |
| [ADR-018](ADR-018-runtime-resource-cache-prewarm-and-pooling.md) | 运行期缓存、分阶段预热与对象池 | Accepted |
| [ADR-019](ADR-019-test-fixtures-outside-production-source.md) | 测试夹具与探针不进入生产源码 | Accepted |
| [ADR-020](ADR-020-typed-visual-assets-and-streaming-lifecycle.md) | 类型化视觉资产、显式后端与流式生命周期 | Accepted |
| [ADR-021](ADR-021-project-wide-target-architecture.md) | 项目总体目标架构与所有权/生命周期边界 | Accepted |
| [ADR-022](ADR-022-atlas-metadata-view-and-path-identity.md) | AtlasMetadata 只读 View、路径身份与失败语义 | Accepted |
| [ADR-023](ADR-023-level-layout-data-contract.md) | 关卡布局采用构建期生成的 Resource | Accepted |
| [ADR-024](ADR-024-check-all-nine-gate-dimensions.md) | `check_all` 九维门禁及维度清单治理 | Accepted |
| [ADR-025](ADR-025-raw-data-export-closure.md) | 原始数据导出闭包与实际 PCK 验证 | Accepted |
| [ADR-026](ADR-026-ui-font-theme-role-contract.md) | UI 字体角色与 Theme 使用边界 | Accepted |
| [ADR-027](ADR-027-platform-commitment-and-verification-device.md) | 平台承诺与验收设备边界；未完成验证项见 roadmap §2 | Accepted |
| [ADR-028](ADR-028-confirm-dialog-callback-ownership.md) | 确认框回调由打开者持有 | Accepted |
| [ADR-029](ADR-029-passive-snapshot-event-driven.md) | 被动属性快照由档案变更事件驱动 | Accepted |
| [ADR-030](ADR-030-pet-passive-command-and-table.md) | 宠物被动成长命令与共享数值表 | Accepted |
| [ADR-031](ADR-031-scene-script-relocation.md) | 场景不承载 GDScript；脚本统一归 `Script/<domain>/` | Accepted |

## 索引规则

- 新 ADR 使用 `ADR-<三位编号>-<英文短名>.md`，编号不复用；新增文件须同步本表。
- 不静默改写已接受的结论；决策变化新增 ADR，并在旧 ADR 标注替代关系。
- 本表只维护文件链接、简短决策摘要与状态；实施细节和当前实现归其各自权威文档。
