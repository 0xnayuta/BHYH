# 机器报告

本目录存放脚本按需生成的当前报告与本地分析记录。报告不是版本化历史；需要长期保留的结论写入 [`../reference/status.md`](../reference/status.md) 或对应归档，不手改生成物。

以下列出主要生成器及权威输出。JSON 用于机器判定或完整明细；Markdown 为可重建的人工摘要。全量回归与 changed-only 代表不同运行范围，不能互相替代。

| 生成器 | 产物 | 说明 |
|:---|:---|:---|
| `scripts/contract_scan.py` | `contract_audit.json`、`contract_audit.md` | JSON 保存全部 finding；Markdown 每类最多展示 40 条。 |
| `scripts/health_check.py` | `dead_code_audit.md` | 引擎/场景健康与死代码候选；候选必须人工复核，不是删除授权。 |
| `scripts/naming_compliance_audit.py` | `naming_compliance_audit.json`、`naming_compliance_audit.md` | JSON 是结构化明细；Markdown 是汇总。 |
| `scripts/whitelist_audit.py` | `whitelist_freeze_audit.json`、`whitelist_freeze_audit.md` | 冻结白名单摘要与错误；源登记在 `scripts/contract_whitelist.json`。 |
| `scripts/level_regression_all.py` | `level_regression_report.json/.md`（全量）、`level_regression_changed_report.json/.md`（changed-only） | 每次回归直接写入选中范围的结果。 |
| `scripts/coop_probe_runner.py` | `coop_probe_matrix_report.json/.md` | 包含运行范围、时间和逐用例状态。 |
| `scripts/scene_probe_runner.py` | `<report_stem>.json/.md` | 每个已运行探针独立报告；PASS JSON 不保存引擎输出尾部，失败报告保留尾部诊断。 |
| `scripts/archive_probe_runner.py` | `archive_persistence_probe_report.json` | 隔离存档探针的检查项、隔离状态、退出码与失败。 |
| `scripts/frame_sequence_pack_probe.py` | 仅传 `--report` 时输出指定 JSON 路径 | PCK 闭包证据：预设、依赖数、缺失项、包大小与 hash。 |
| `scripts/export_closure_probe.py` | 仅传 `--report` 时输出指定 JSON 路径 | 原始 JSON/BIN 的 PCK 闭包与导出插件计数。 |
| `scripts/verify_dragonbones_factories.py` | `dragonbones_factory_verify.json` | 独立子进程的工厂加载结果；增量缓存由 `.godot/` 管理。 |
| `scripts/docs_audit.py` | `docs_audit.json` | 文档链接、文档目录索引与脚本索引审计；不进入 `check_all`。 |
| `scripts/asset_library_catalog.py` | `zmws_asset_inventory.json`、[`../reference/zmws_asset_integration_matrix.md`](../reference/zmws_asset_integration_matrix.md) | `--check` 比较两个可重建生成物；本地资产根缺失时报告 SKIP。 |

单关 `scripts/level_test_runner.py` 通过 stdout 返回 JSON；临时驱动、报告和日志写入后清理，不生成长期 `docs/reports/` 文件。`convert_atlas_metadata.py --check` 直接比较构建输入/输出，不生成报告。
