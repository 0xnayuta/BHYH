# 机器报告

本目录用于存放门禁、契约扫描、命名审计和关卡回归脚本生成的报告。

- 报告由脚本按需生成，不提交历史报告；
- 不要手工修改报告；需要保留的结论写入 [`../reference/status.md`](../reference/status.md)；
- 报告路径由各脚本的默认参数决定，常用命令见 [`../README.md`](../README.md)。

主要生成器：

| 脚本 | 报告 |
|:---|:---|
| `scripts/contract_scan.py` | `contract_audit.md` / `.json` |
| `scripts/health_check.py` | `dead_code_audit.md` |
| `scripts/naming_compliance_audit.py` | `naming_compliance_audit.md` / `.json` |
| `scripts/whitelist_audit.py` | `whitelist_freeze_audit.md` / `.json` |
| `scripts/level_regression_all.py` | `level_regression_*.md` / `.json` |
| `scripts/coop_probe_runner.py` | `coop_probe_matrix_report.md` / `.json` |
| `scripts/scene_probe_runner.py` | `constellation_probe_report.md` / `.json` |
| `scripts/frame_sequence_pack_probe.py` | `frame_sequence_pack_report.json`（仅 `--report` 时） |

Atlas 同步校验由 `scripts/convert_atlas_metadata.py --check` 直接执行，不生成报告文件。
