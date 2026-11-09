# 项目文档索引

本目录按“参考 / 决策 / 路线 / 指南 / 规范 / 审计 / 报告 / 归档”分层。版本与阶段状态分别以 [`reference/status.md`](reference/status.md) 与 [`roadmap/roadmap.md`](roadmap/roadmap.md) 为准；当前活跃候选为 Phase 39（Scene/Script 目录收敛，未启动），Phase 35–38、28、29 已归档，Phase 26 长期暂缓。唯一活跃工程位于仓库根目录的 `source/`。

历史阶段报告与逐文件台账不进入活跃文档；已完成阶段保留在 [`archive/`](archive/README.md)。本页只做目录导航，具体清单由各子目录索引维护。

## 1. 目录分层

| 目录 | 定位 | 维护方式 |
|:---|:---|:---|
| [`reference/`](reference/README.md) | 当前状态、架构、验收与当前契约 | 人工维护 |
| [`standards/`](standards/README.md) | 活跃规范，约束代码、场景与资产 | 人工维护 |
| [`decisions/`](decisions/README.md) | 架构决策记录（ADR） | 人工维护；已接受结论不直接改写 |
| [`roadmap/`](roadmap/README.md) | 长期路线与当前候选 | 人工维护 |
| [`guides/`](guides/README.md) | 开发、构建、验证与迁移操作 | 人工维护 |
| [`issues/known-issues.md`](issues/known-issues.md) | 已知问题与待验证风险 | 人工维护 |
| [`audit/`](audit/README.md) | 人工代码质量审计模板与报告 | 只读档案 |
| [`reports/`](reports/README.md) | 脚本生成的机器报告 | 按需生成，不入库 |
| [`archive/`](archive/README.md) | 已完成阶段的长期参考 | 归档后只读 |

## 2. 文档规则

1. **单一事实源**：状态以 [`reference/status.md`](reference/status.md) 为准；架构以 [`reference/architecture.md`](reference/architecture.md) 为准；验收以 [`reference/acceptance.md`](reference/acceptance.md) 为准；字体/Theme 使用边界以 [`standards/ui_typography_contract.md`](standards/ui_typography_contract.md) 为准；决策以 [`decisions/`](decisions/README.md) 为准。
2. **活跃文档不承载阶段流水账**：批次实施、历史计数、截图与逐项验证移入 `archive/`，当前页只保留仍生效的契约、失败边界和必要入口。
3. **索引分层**：根 README、docs README 只保留入口；完整文件清单由各子目录索引维护，避免同一移动同步多处。
4. **报告不手改**：`reports/` 由脚本覆盖；结论写入 `status.md`。
5. **链接可验证**：移动文档后必须更新相对链接；`scripts/docs_audit.py` 负责检查。
6. **审计免改**：`audit/` 的历史报告和模板按审计规则维护，不在普通文档整理中改写；模板版本升级单独记录。
7. **归档只追加**：新归档只在 [`archive/README.md`](archive/README.md) 追加索引，不改既有归档正文。

## 3. 机器报告

`reports/` 中的文件由脚本生成，随时可能被覆盖，不纳入版本历史。常用命令：

```bash
python scripts/check_all.py --skip-engine
python scripts/contract_scan.py --project-dir source --fail-on-error
python scripts/level_regression_all.py
```

报告与脚本的对应关系见 [`reports/README.md`](reports/README.md) 与 [`../scripts/README.md`](../scripts/README.md)。

## 4. 归档

已完成且仍有长期参考价值的内容进入 [`archive/`](archive/README.md)。归档不接收机器报告、临时台账、旧路径映射或本地绝对路径。
