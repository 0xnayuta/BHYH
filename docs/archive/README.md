# 文档归档 (Archive)

本目录保存已完成、不再活跃，但对未来开发仍有参考价值的文档。

---

## 1. 定位

`docs/` 的当前分工：

- `reference/`：当前状态、架构、验收与项目范围；
- `roadmap/`：路线图与当前迭代；
- `guides/`：操作与迁移指南；
- `standards/`：仍生效的规范；
- `reports/`：脚本按需生成的机器报告；
- `archive/`：**面向未来**的长期参考文档。

归档不是旧仓库历史的回收站。当前仓库不恢复旧路径映射、逐文件迁移台账、历史机器报告和版本专用临时脚本；可复用的迁移方法保留在 [`../guides/migration_playbook.md`](../guides/migration_playbook.md)。

---

## 2. 入库标准

文档满足以下条件时才进入归档：

- 已完成阶段的设计决策、兼容性结论、迁移经验或长期参考；
- 对后续版本、重构或问题排查仍有实际价值；
- 结论明确，且与当前活跃文档的关联可追溯；
- 不再需要作为规范每天维护，但删除会损失重要知识。

---

## 3. 不归档内容

- `docs/reports/` 中可重新生成的报告；
- 临时逐文件台账、原始日志、构建产物与测试快照；
- 本地二进制、解密沙盒、绝对路径、密钥与任何私有环境信息；
- 旧路径映射与仅用于解释历史路径的文档；
- 已被活跃规范完全替代、且没有额外决策价值的旧文档。

机器报告与临时证据应重新生成或保留在仓库外；需要长期保留的结论写入 [`../reference/status.md`](../reference/status.md) 或 `migration_playbook.md`。

---

## 4. 文件与命名

- 文件名使用 `snake_case.md`；本 `README.md` 为目录入口例外；
- 一个文件聚焦一个主题，避免把不同阶段的报告拼在一起；
- 归档文档使用相对链接，不写入本地绝对路径；
- 每份归档文档顶部注明：

```text
> **归档日期**：YYYY-MM-DD
> **状态**：Archived
> **关联**：当前仍有效的文档或版本
```

---

## 5. 归档流程

1. 确认文档已不再属于 `reference/`、`roadmap/`、`guides/`、`standards/` 或当前工具链说明；
2. 使用普通文件移动或 `git mv` 移入本目录，不使用 `scripts/rename_path.py`；
3. 更新 `docs/README.md`、`AGENTS.md` 或相关活跃文档中的链接；
4. 在本目录索引中登记；
5. 执行 Markdown 链接检查，确保活跃文档没有指向错误路径。

归档后原则上只读；如需修正事实，先补充修订说明，或将文档重新移回活跃目录后再修改。

---

## 6. 索引

已完成阶段的长期参考文档在此登记：

| 文档 | 主题 | 归档日期 |
|:---|:---|:---|
| [`iteration_6_9_patch_backport.md`](iteration_6_9_patch_backport.md) | 6.9 补丁回植：范围、文件映射、实施批次与验收结果 | 2026-10-23 |
| [`iteration_12_display_hud.md`](iteration_12_display_hud.md) | Phase 12 画布、相机与 HUD 重构：多分辨率验收、双人探针、已知边界，以及原计划与实施顺序存档 | 2026-10-24 |
| [`iteration_13_visual_asset_contract.md`](iteration_13_visual_asset_contract.md) | Phase 13 视觉资产契约收口：阶段回顾、运行时建帧例外、发布闭包、兼容层治理、冻结项与后续顺序 | 2026-10-27 |
| [`iteration_30_level_layout_data_contract.md`](iteration_30_level_layout_data_contract.md) | Phase 30 阶段结果与批次摘要（30-0~30-4：五件套、ZMWS 驱动、脚本迁出、例外登记、边界复核与发布闭包）；完整实施记录见同阶段归档 | 2026-11-01 |
| [`iteration_18_20_comprehensive_closeout.md`](iteration_18_20_comprehensive_closeout.md) | Phase 18~20 综合收尾：归属/成长/档案顺序、表现与运行时清理、资源/Atlas 与输入/HUD、Autoload 拆分、守卫扩面、20-3C 收口与延期去向 | 2026-10-30 |
| [`iteration_17_gameplay_module_boundaries.md`](iteration_17_gameplay_module_boundaries.md) | Phase 17 阶段结论（17-1~17-7）、最终验证、静态守卫与 Phase 18 交接缺口；完整调用面矩阵见同阶段快照 | 2026-10-29 |
| [`iteration_14_atlas_metadata_boundary.md`](iteration_14_atlas_metadata_boundary.md) | Phase 14 AtlasMetadata 类型化数据边界：生产者/消费者矩阵、View 迁移、边界守卫、验证与恢复 | 2026-10-28 |
| [`iteration_15_app_orchestration_lifecycle.md`](iteration_15_app_orchestration_lifecycle.md) | Phase 15 阶段计划与结论（场景入口、加载页交接、资源租约、缓存/池/UI、退出与后台、验证与恢复）；完整调用面矩阵见同阶段快照 | 2026-10-28 |
| [`iteration_16_archive_session_slots.md`](iteration_16_archive_session_slots.md) | Phase 16 阶段计划与结论（调用面、保存 IO 与身份、会话上下文、共享账本、面板显式操作者、契约门禁、验证与恢复）；完整调用面矩阵见同阶段快照 | 2026-10-29 |
| [`iteration_15_runtime_lifecycle_matrix.md`](iteration_15_runtime_lifecycle_matrix.md) | Phase 15-1 完整调用面与所有权矩阵快照；阶段计划/结论见同阶段记录 | 2026-11-02 |
| [`iteration_16_archive_session_matrix.md`](iteration_16_archive_session_matrix.md) | Phase 16-1 完整档案会话与槽位调用面矩阵快照；阶段计划/结论见同阶段记录 | 2026-11-02 |
| [`iteration_17_18_gameplay_module_matrix.md`](iteration_17_18_gameplay_module_matrix.md) | Phase 17-1/18 完整玩法与表现调用面矩阵快照；阶段结论见同阶段记录 | 2026-11-02 |
| [`iteration_20_autoload_boundary_matrix.md`](iteration_20_autoload_boundary_matrix.md) | Phase 20 Autoload 拆分与迁移实施记录快照 | 2026-11-02 |
| [`iteration_30_level_layout_contract.md`](iteration_30_level_layout_contract.md) | Phase 30 完整实施记录（对象模型、字段契约、ZMWS 映射、生成器、迁移与验证）；阶段结果见同阶段摘要 | 2026-11-02 |
| [`phase_30_4_script_decisions.md`](phase_30_4_script_decisions.md) | Phase 30-4 数据容器脚本逐项决策（归档移动） | 2026-11-02 |
| [`iteration_31_33_modernization_gap_matrix.md`](iteration_31_33_modernization_gap_matrix.md) | Phase 31~33 现代化差距调查快照 | 2026-11-02 |
| [`iteration_32_ui_theme.md`](iteration_32_ui_theme.md) | Phase 32 UI Theme 完整批次与验证记录快照 | 2026-11-02 |
| [`iteration_33_equipment_data_contract.md`](iteration_33_equipment_data_contract.md) | Phase 33 装备数据契约完整批次与验证记录快照 | 2026-11-02 |
| [`iteration_22_global_state_boundary.md`](iteration_22_global_state_boundary.md) | Phase 22 Global 状态与入口契约：字段/入口清理、状态迁移、Global 表面守卫与验证记录 | 2026-11-03 |
| [`iteration_23_pet_domain_boundary.md`](iteration_23_pet_domain_boundary.md) | Phase 23 关卡、宠物与档案数据边界：八族迁移、结算复核、宠物域 View/命令与阶段验收 | 2026-11-03 |
| [`program_21_33_closeout.md`](program_21_33_closeout.md) | Phase 21、30~33 程序收口记录；Phase 22~27 见各阶段归档 | 2026-11-02 |
| [`validation_history_2026.md`](validation_history_2026.md) | 2026 年逐批验证记录；前段内含 2026-11-02 旧 status 快照，当前事实以 reference/status.md 为准 | 2026-11-02 |
| [`iteration_24_ui_growth_boundaries.md`](iteration_24_ui_growth_boundaries.md) | Phase 24 UI 与成长命令边界：面板契约盘点、`PetAttributePages` 拆分、`CoopPanelHost` 宿主、阵法升级命令与阶段验收 | 2026-11-06 |
| [`iteration_25_combat_behavior.md`](iteration_25_combat_behavior.md) | Phase 25 战斗实体行为切片：自动战斗、法宝展示、Boss 保护、受击/来源控制器、探针覆盖与阶段验收 | 2026-11-06 |
| [`iteration_27_theme_font_convergence.md`](iteration_27_theme_font_convergence.md) | Phase 27 Theme 与字体契约收敛：token 源、字号/颜色、变体层级、字体资产、动态覆盖与验收 | 2026-11-06 |
| [`iteration_35_38_content_backport.md`](iteration_35_38_content_backport.md) | Phase 35–38 7.1–7.4 内容回植：范围、三方语义合并、批次、L3 收口、发布边界与缺口修复 | 2026-11-09 |
| [`iteration_28_global_signal_and_passive_contract.md`](iteration_28_global_signal_and_passive_contract.md) | Phase 28 全局确认信号移除、被动属性快照事件化与宠物被动命令/共享数值表 | 2026-11-09 |
| [`iteration_29_scene_script_relocation.md`](iteration_29_scene_script_relocation.md) | Phase 29 `Scene/` 脚本落位：规范、56 文件迁移清单、29-1~29-4 批次与门禁 | 2026-11-09 |
| [`iteration_39_scene_script_layout.md`](iteration_39_scene_script_layout.md) | Phase 39 根级清零、`other_scene` 拆分、文本/怪物/魂卡场景合并、大型目录与 shader 保留决策、最终验收 | 2026-11-10 |
| [`iteration_37c2cf8_meta_lookup_fix.md`](iteration_37c2cf8_meta_lookup_fix.md) | `get_meta(key, null)` 同心链接缺键修复与复现证据 | 2026-11-10 |
| [`iteration_34_7_0_content_backport.md`](iteration_34_7_0_content_backport.md) | Phase 34 7.0 内容回植与未验证发布边界 | 2026-11-10 |
| [`ui_runtime_fixes_2026_11_04_06.md`](ui_runtime_fixes_2026_11_04_06.md) | 2026-11-04 至 2026-11-06 UI、字体与运行时维护快照 | 2026-11-10 |

## 7. Retired reference paths

The following Phase 22/23 snapshots are retained under `docs/reference/` only as link targets for the archived reports; they are not active references. Current contracts are maintained in `reference/architecture.md`, `reference/autoload_boundary_matrix.md`, and `reference/pet_domain_contract.md`.

| Link target | Current/history source |
|:---|:---|
| [`../reference/global_runtime_inventory.md`](../reference/global_runtime_inventory.md) | Phase 22 archived record; current Global boundary: [`../reference/autoload_boundary_matrix.md`](../reference/autoload_boundary_matrix.md) and [`../reference/architecture.md`](../reference/architecture.md) |
| [`../reference/pet_level_boundary_matrix.md`](../reference/pet_level_boundary_matrix.md) | Phase 23 archived record; current pet ownership: [`../reference/architecture.md`](../reference/architecture.md) and [`../reference/pet_domain_contract.md`](../reference/pet_domain_contract.md) |
| [`iteration_22_global_runtime_inventory_snapshot.md`](iteration_22_global_runtime_inventory_snapshot.md) | Phase 22-1 Global 字段、公开入口及普通服务的完整历史快照 | 2026-11-10 |
| [`iteration_23_pet_level_boundary_matrix_snapshot.md`](iteration_23_pet_level_boundary_matrix_snapshot.md) | Phase 23 宠物关卡调用面、八族迁移、槽位边界与历史验证快照 | 2026-11-10 |
