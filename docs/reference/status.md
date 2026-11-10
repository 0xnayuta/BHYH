# 当前工程状态 (Status)

> **定位**：当前内容版本、最近一次完整工作区验证与未验证边界的单一事实源。阶段完成状态只见 [`../roadmap/roadmap.md`](../roadmap/roadmap.md)；逐批证据只见 [`../archive/README.md`](../archive/README.md)。
> **最后更新**：2026-11-10。表内最近一次完整 L3 证据为 2026-11-09；本次文档整理未重跑引擎门禁。

## 1. 当前内容基线

| 项目 | 当前事实 |
|:---|:---|
| 内容版本 | **7.4** |
| 完成阶段 | 顺序与归档状态见 [`../roadmap/roadmap.md`](../roadmap/roadmap.md) |
| 工程配置 | `source/project.godot`；当前运行架构见 [`architecture.md`](architecture.md) |
| 质量门禁判据 | [`acceptance.md`](acceptance.md) |

## 2. 最近一次完整 L3 验证

以下结果摘自 2026-11-09 最近一次完整 L3 记录；本次文档整理未重跑这些命令。

| 验证 | 记录结果 |
|:---|:---|
| `check_all --godot-bin` | 9/9 PASS |
| `health_check --no-cache` | 823 个脚本；0 Parse / 0 Error / 0 Warning |
| `scene_probe_runner` | 31/31 PASS |
| `archive_probe_runner` | 344 项通过 |
| `coop_probe_runner` | 38/38 PASS |
| `level_regression_all --jobs 12` | 129/129 PASS + 5 SKIP |
| `level_1` | 4 阶段 PASS；0 ERROR / 0 WARNING |
| 相关资源同步与命名审计 | Phase 38-6 L3 记录通过；详细审计结果由对应脚本生成 |

完整批次结果见 [`../archive/iteration_35_38_content_backport.md`](../archive/iteration_35_38_content_backport.md) 和 [`../archive/iteration_39_scene_script_layout.md`](../archive/iteration_39_scene_script_layout.md)。更早的验证历史见 [`../archive/validation_history_2026.md`](../archive/validation_history_2026.md)。

## 3. 当前未验证边界

- **发布**：7.4 正式 release/PCK 未重新构建并验收；旧版本验证包的路径闭包不代替 7.4 release 验证。
- **平台**：Spine GDExtension 只入库 Windows x86_64；最低硬件配置未声明，其他平台延期/未验证。决策见 [ADR-010](../decisions/ADR-010-spine-runtime-boundary.md) 与 [ADR-027](../decisions/ADR-027-platform-commitment-and-verification-device.md)。
- **外部服务**：云存档服务端、训练和成就闭环依赖外部能力，不据本地内容回植宣称已完成。
- **公开仓库**：第三方美术、音乐、字体和精灵表不入库；公开 clone 缺素材提示属于预期。
- **待复核风险**：`get_meta(key, null)` 的调用点清单见 [`../issues/known-issues.md`](../issues/known-issues.md)；缺失资产见 [`../standards/missing_assets_registry.md`](../standards/missing_assets_registry.md)。

## 4. 维护边界

本页只记录当前内容基线、最近一次完整验证与仍未验证的边界。详细门禁命令和通过判据以 [`acceptance.md`](acceptance.md) 为准；实现架构以 [`architecture.md`](architecture.md) 为准；阶段顺序以 [`../roadmap/roadmap.md`](../roadmap/roadmap.md) 为准。