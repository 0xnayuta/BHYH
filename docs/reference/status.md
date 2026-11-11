# 当前工程状态 (Status)

> **定位**：当前内容版本、最近一次完整工作区验证与未验证边界的单一事实源。阶段完成状态只见 [`../roadmap/roadmap.md`](../roadmap/roadmap.md)；逐批证据只见 [`../archive/README.md`](../archive/README.md)。
> **最后更新**：2026-11-11。最近一次工作区全量回归与隔离发布包验证见下表；发布包装及目标设备验证边界见第 3 节。

## 1. 当前内容基线

| 项目 | 当前事实 |
|:---|:---|
| 内容版本 | **7.4** |
| 完成阶段 | 顺序与归档状态见 [`../roadmap/roadmap.md`](../roadmap/roadmap.md) |
| 工程配置 | `source/project.godot`；当前运行架构见 [`architecture.md`](architecture.md) |
| 质量门禁判据 | [`acceptance.md`](acceptance.md) |

## 2. 最近一次发布相关验证

以下结果来自 2026-11-11 的完整工作区与隔离 Windows release 验证；发布包装在已打开的编辑器占用 MCP 端口时失败，隔离导出和实际包探针另行通过，不将该包装记为通过。

| 验证 | 记录结果 |
|:---|:---|
| `check_all --godot-bin --health-full` | 9/9 PASS；首轮因并发关卡夹具与中断残留文件失败，清理后重跑通过 |
| `scene_probe_runner` | 32/32 PASS，含关卡入口信息面板与弹体动画/方向 |
| `coop_probe_runner` | 38/38 PASS，无 SKIP |
| `level_regression_all --jobs 12` | 129/129 PASS + 6 SKIP；`level_dsg_4` 首轮有 3 条 RID/material 错误，串行重试通过 |
| `level_1` | 引擎夹具和正式 release EXE 各 4 阶段 PASS；两者均 0 ERROR / 0 WARNING |
| 命名与白名单终审、文档审计 | PASS；命名违规 0、白名单未登记/失效条目 0、文档断链 0 |
| 正式 release PCK | 5,233 条必需路径存在；68,437 条排除资源及其导入产物不可达；隔离导出日志 0 ERROR / 0 WARNING |

`level_info` 是非战斗信息面板，首次全量回归将它误当战斗关卡；修正分类后由关卡入口探针在档案会话上下文验证。首次优化导出的原始错误日志已清理，不能恢复逐行诊断；本次独立发现并修复旧弹体字段名和精简场景缺失动画引用，不能据此断定旧日志全部根因。

2026-11-09 及更早的完成批次见 [`../archive/iteration_35_38_content_backport.md`](../archive/iteration_35_38_content_backport.md)、[`../archive/iteration_39_scene_script_layout.md`](../archive/iteration_39_scene_script_layout.md) 与 [`../archive/validation_history_2026.md`](../archive/validation_history_2026.md)。

## 3. 当前未验证边界

- **发布**：已在隔离 Windows release 构建上验证 headless 四阶段、预载与切关，以及 PCK 双向闭包。用户报告已在目标 Windows 设备运行正式 EXE，未发现明显问题；具体操作范围、性能指标与日志未提供。`export_release.py` 直接针对打开的工程导出时，`godot-mcp` 端口冲突导致失败；隔离副本的独立端口导出通过。完整操作流程、目标设备 VRAM 和首帧性能仍未验证；发行 PCK 内的全部关卡未逐一运行。
- **平台**：Spine GDExtension 只入库 Windows x86_64；最低硬件配置未声明，其他平台延期/未验证。决策见 [ADR-010](../decisions/ADR-010-spine-runtime-boundary.md) 与 [ADR-027](../decisions/ADR-027-platform-commitment-and-verification-device.md)。
- **外部服务**：云存档服务端、训练和成就闭环依赖外部能力，不据本地内容回植宣称已完成。
- **公开仓库**：第三方美术、音乐、字体和精灵表不入库；公开 clone 缺素材提示属于预期。
- **待复核风险**：`get_meta(key, null)` 的调用点清单见 [`../issues/known-issues.md`](../issues/known-issues.md)；缺失资产见 [`../standards/missing_assets_registry.md`](../standards/missing_assets_registry.md)。

## 4. 维护边界

本页只记录当前内容基线、最近一次完整验证与仍未验证的边界。详细门禁命令和通过判据以 [`acceptance.md`](acceptance.md) 为准；实现架构以 [`architecture.md`](architecture.md) 为准；阶段顺序以 [`../roadmap/roadmap.md`](../roadmap/roadmap.md) 为准。