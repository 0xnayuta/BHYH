# 项目文档索引

本目录按“参考、规范、决策、路线、指南、已知问题、审计、报告、归档”分层。本页说明导航与维护边界；完整文件清单由相应子目录 README 维护。

## 1. 目录分层

| 目录 | 定位 | 维护边界 |
|:---|:---|:---|
| [`reference/`](reference/README.md) | 当前实现、验证快照与有效契约 | 按各文档职责维护事实 |
| [`standards/`](standards/README.md) | 活跃规范 | 维护规范性要求 |
| [`decisions/`](decisions/README.md) | 架构决策记录（ADR） | 维护决策摘要与状态 |
| [`roadmap/`](roadmap/README.md) | 阶段状态与未立项候选 | 阶段状态只在 `roadmap.md` 维护 |
| [`guides/`](guides/README.md) | 可复用操作指南 | 维护可复用方法，不记单批台账 |
| [`issues/known-issues.md`](issues/known-issues.md) | 已知问题与待验证风险 | 维护风险边界与跟踪入口 |
| [`audit/`](audit/README.md) | 审计模板与历史报告 | 普通整理只读；模板升级单独维护 |
| [`reports/`](reports/README.md) | 脚本生成的机器报告 | 按需生成，不手工修改 |
| [`archive/`](archive/README.md) | 已完成阶段的长期参考 | 历史原貌只读；只追加索引 |

## 2. 维护边界

1. 当前内容与验证快照归 `reference/status.md`；阶段状态、未完成范围与恢复条件归 `roadmap/roadmap.md`；规范和 ADR 分别归 `standards/` 与 `decisions/`。
2. 根 README 与本页只保留导航；完整文件清单由各子目录索引维护。
3. 活跃文档不复制阶段流水、历史计数或逐项验证；完成工作与详细历史证据进入 `archive/`。
4. 移动或新增文档时同步相对链接及对应索引；`scripts/docs_audit.py` 检查链接与目录索引。

## 3. 报告与归档

- `reports/` 文件由脚本生成，随时可能被覆盖；不要手工修改。命令与脚本对应关系见 [`../scripts/README.md`](../scripts/README.md)，稳定结论更新到对应 reference 文档。
- 归档只收录仍有长期参考价值的已完成工作；不收机器报告、临时台账、旧路径映射或本地绝对路径。
- 归档正文保持历史原貌；新增归档后只在 [`archive/README.md`](archive/README.md) 追加索引。
