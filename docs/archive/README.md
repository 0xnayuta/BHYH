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
| [`iteration_14_atlas_metadata_boundary.md`](iteration_14_atlas_metadata_boundary.md) | Phase 14 AtlasMetadata 类型化数据边界：生产者/消费者矩阵、View 迁移、边界守卫、验证与恢复 | 2026-10-28 |
| [`iteration_15_app_orchestration_lifecycle.md`](iteration_15_app_orchestration_lifecycle.md) | Phase 15 应用编排与运行资源生命周期：场景入口、加载页交接、资源租约、缓存/池/UI、退出与后台、边界守卫、验证与恢复 | 2026-10-28 |
| [`iteration_16_archive_session_slots.md`](iteration_16_archive_session_slots.md) | Phase 16 档案会话、持久化与玩家槽位：调用面矩阵、保存 IO 与身份、会话上下文、共享账本、面板显式操作者、契约门禁、验证与恢复 | 2026-10-29 |
