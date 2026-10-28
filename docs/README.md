# 项目文档索引

本目录按“参考 / 决策 / 路线 / 指南 / 规范 / 审计 / 报告 / 归档”分层。当前内容版本为 **6.9**，唯一活跃工程位于仓库根目录的 `source/`。

历史阶段报告与逐文件台账不再纳入仓库；可复用的迁移经验已蒸馏到 [`guides/migration_playbook.md`](guides/migration_playbook.md)。

---

## 1. 目录分层

| 目录 | 定位 | 维护方式 |
|:---|:---|:---|
| `reference/` | 当前状态、架构、验收与项目范围 | 人工维护 |
| `decisions/` | 架构决策记录（ADR） | 人工维护；已接受结论不直接改写 |
| `audit/` | 人工代码质量审计模板与报告 | 只读档案；历史报告不重写，新增按编号接续 |
| `roadmap/` | 路线图、当前迭代与后续规划 | 人工维护 |
| `guides/` | 开发、构建、验证与迁移操作指南 | 人工维护 |
| `standards/` | 活跃规范，约束当前代码、场景与资产 | 随工程演进人工维护 |
| `reports/` | 脚本生成的机器报告 | 由脚本按需生成，不提交历史报告 |
| `archive/` | 已完成但仍有长期参考价值的文档 | 归档后原则上只读；入口见 [`archive/README.md`](archive/README.md) |

### 按需增加

- `issues/`：出现正式已知问题清单时创建；
- `reference/` 下可继续增加项目范围文档。

---

## 2. 活跃文档

| 文档 | 内容 |
|:---|:---|
| [`reference/README.md`](reference/README.md) | 参考文档目录索引 |
| [`reference/architecture.md`](reference/architecture.md) | **运行时架构**：Autoload、场景流、对象模型、数据/资源分层与遗留边界 |
| [`reference/runtime_lifecycle_matrix.md`](reference/runtime_lifecycle_matrix.md) | **Phase 15 运行时调用面与所有权矩阵**：场景切换、加载页、缓存/池/UI、档案会话与退出清理的当前所有者及失败边界 |
| [`reference/atlas_metadata_schema.md`](reference/atlas_metadata_schema.md) | **Phase 14 矩阵与收口**：AtlasMetadata 生产者、源形态、消费者、View、守卫与失败边界 |
| [`reference/acceptance.md`](reference/acceptance.md) | **验收标准**：八维门禁、契约域、引擎健康、运行期夹具与阈值 |
| [`reference/status.md`](reference/status.md) | **当前状态单一事实源**：版本、目录、规模、门禁与验收基线 |
| [`decisions/README.md`](decisions/README.md) | **架构决策记录索引**：有效选择、历史决定及替代关系 |
| [`decisions/ADR-021-project-wide-target-architecture.md`](decisions/ADR-021-project-wide-target-architecture.md) | Godot 原生场景组合与总体目标选择；保留 ADR-020 视觉子契约，不宣称已实现 |
| [`decisions/ADR-022-atlas-metadata-view-and-path-identity.md`](decisions/ADR-022-atlas-metadata-view-and-path-identity.md) | AtlasMetadata 只读 View、路径身份例外与失败语义 |
| [`audit/README.md`](audit/README.md) | **审计档案索引**：模板、命名、只读与报告规则 |
| [`audit/AUDIT-000-audit-template.md`](audit/AUDIT-000-audit-template.md) | **只读审计模板**：10 个领域、12 个问题前缀、证据与问题总表 |
| [`roadmap/README.md`](roadmap/README.md) | 路线图目录索引 |
| [`roadmap/roadmap.md`](roadmap/roadmap.md) | **项目状态与长期阶段顺序的唯一来源**：当前状态、阶段路线、近期重点与独立立项 |
| [`roadmap/current-iteration.md`](roadmap/current-iteration.md) | **Phase 15 应用编排与运行资源生命周期**：Phase 15-1 调用面矩阵、Phase 15-2A 旁路收口、Phase 15-2B 入口契约、Phase 15-2C 加载页交接、Phase 15-3A 窄交接接口、Phase 15-3B 关卡资源租约、Phase 15-3C 失败/取消与 Phase 15-3D 预载清单边界、Phase 15-4A 缓存作用域、Phase 15-4B 对象池、Phase 15-4C 临时 UI 与 Phase 15-4D 退出与后台已完成，Phase 15-4E 未启动 |
| [`guides/README.md`](guides/README.md) | 操作指南目录索引 |
| [`guides/migration_playbook.md`](guides/migration_playbook.md) | 下一次版本迁移的方法、阶段与红线 |
| [`standards/README.md`](standards/README.md) | 规范目录索引、效力边界与修订流程 |
| [`standards/naming_standard.md`](standards/naming_standard.md) | 全工程命名规范与契约白皮书 |
| [`standards/godot_design_standard.md`](standards/godot_design_standard.md) | Godot 现代项目设计规范（场景、Resource、Autoload、结构） |
| [`standards/target_architecture_contract.md`](standards/target_architecture_contract.md) | **项目总体目标架构**：职责/依赖、应用/会话、战斗/关卡、数据/存档、UI/输入、视觉资源/平台与生命周期 |
| [`standards/naming_whitelist.md`](standards/naming_whitelist.md) | 命名白名单与机器导出冻结登记 |
| [`standards/missing_assets_registry.md`](standards/missing_assets_registry.md) | 缺失资产登记与恢复台账 |
| [`standards/spriteframes_generation_policy.md`](standards/spriteframes_generation_policy.md) | SpriteFrames 生成策略（FPS、循环命名、speed 语义） |

---

## 3. 机器报告

`reports/` 中的文件由脚本生成，随时可能被覆盖，不纳入版本历史。需要长期保留的结论写入 [`reference/status.md`](reference/status.md)。

常用入口：

```bash
python scripts/check_all.py --skip-engine
python scripts/contract_scan.py --project-dir source --fail-on-error
python scripts/naming_compliance_audit.py --fail-on-error
python scripts/level_regression_all.py --jobs 4 --timeout 90
```

报告与生成脚本的对应关系见 [`reports/README.md`](reports/README.md)。

---

## 4. 归档

`archive/` 用于保存已完成、不再活跃、但对后续开发仍有参考价值的文档。

| 入口 | 内容 |
|:---|:---|
| [`archive/README.md`](archive/README.md) | 归档标准、命名约定、流程与索引 |
| [`archive/iteration_6_9_patch_backport.md`](archive/iteration_6_9_patch_backport.md) | 6.9 补丁回植的完整范围、实施与验收记录 |
| [`archive/iteration_12_display_hud.md`](archive/iteration_12_display_hud.md) | Phase 12 画布/相机/HUD 重构与多分辨率验收归档 |
| [`archive/iteration_13_visual_asset_contract.md`](archive/iteration_13_visual_asset_contract.md) | Phase 13 视觉资产契约收口与发布验证归档；保持历史原貌 |
| [`archive/iteration_14_atlas_metadata_boundary.md`](archive/iteration_14_atlas_metadata_boundary.md) | Phase 14 AtlasMetadata 类型化边界、View 迁移、守卫与验证归档 |

归档不接收机器报告、临时台账、旧路径映射和仅用于历史取证的原始材料；可复用的迁移方法见 [`guides/migration_playbook.md`](guides/migration_playbook.md)。

---

## 5. 维护约定

1. **规范优先**：代码、场景、资产改动必须先符合 `standards/`；
2. **报告不手改**：报告由脚本生成，结论写入 `reference/status.md`；
3. **文档分层**：当前事实放 `reference/`，计划放 `roadmap/`，操作步骤放 `guides/`，规范放 `standards/`；
4. **文档归档**：已完成且有长期价值的文档移入 `archive/`；不保留旧路径映射与历史阶段原始报告；
5. **状态单一事实源**：版本、规模与门禁结果统一维护在 `reference/status.md`；
6. **链接可验证**：移动文档后必须同步更新相对链接并重新检查；
7. **决策可追溯**：架构级、跨模块、长期有效的决定写入 `decisions/`；已接受结论不直接改写，变更通过新 ADR 记录；
8. **审计档案只读**：`audit/` 保存人工审计模板与报告，历史报告不重写；新审计按编号接续，机器报告仍只进入 `reports/`。
