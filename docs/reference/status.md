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

以下结果来自 UI 加载优化之前的 2026-11-11 完整工作区与隔离 Windows release 验证；发布包装在已打开的编辑器占用 MCP 端口时失败，隔离导出和实际包探针另行通过，不将该包装记为通过。

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

### UI 加载优化定向验证

- 2026-11-11 同机对照：Godot 4.7.2、Windows x64、headless、隔离空档案，验证机 RX 6750 XT（驱动 32.0.21045.20006）、桌面 2560×1440；项目配置 Mobile 渲染、`max_fps=120`，headless 不产生 GPU 绘制。首次读档面板工厂约 425 → 9 ms、任务约 420 → 0.5 ms、炼丹炉约 1,343 → 4 ms、首次切合成约 831 → 7 ms；暂停菜单两次加载约 426/361 → 0.01/0.02 ms。25 格背包 100 次未变化刷新检查约 59 → 9 ms。该次优化后并行作用域准备约 546 ms（主菜单）、124 ms（地图）、111 ms（战斗）；后来已改串行，窗口复测见下方。以上是单次诊断，包含缓存和调度差异，不是用户可见首帧或 GPU 验收。
- 本轮 `check_all --godot-bin --health-full` 最终 9/9 PASS；此前两轮均因本批新增 GDScript 未格式化而失败，格式化后重跑通过。文档链接审计通过。
- 作用域探针覆盖缓存释放、过期请求、缺失资源失败与暂停；炼丹探针覆盖同帧切页、背包原地修改/同值新引用和强化保存失败回滚。隔离档案探针 344 项通过；首次运行因 Windows 默认编码解码失败，指定 UTF-8 后通过。
- 双人矩阵首轮 36/38：凤凰出现 headless `Parameter "t" is null`，对象池探针计时与真实节流时钟不一致；凤凰单项复核通过，池探针已改用单调时钟。第二轮 37/38：寅虎出现同一 headless 错误，单项复核通过；对象池探针通过。两次完整矩阵均不计为全通过。
- 命名终审首轮与协作夹具并行，临时脚本在扫描期间被删除而失败；独占重跑命名与白名单审计通过。与本次相关的双人面板、槽位账本、对象池 4 项定向探针通过。
- 2026-11-11 UI 优化后独立导出：首次隔离导出因导出环境未找到模板而失败；补齐模板路径后产物生成，但退出时有 4 ERROR / 1 WARNING，不能计通过。随后详细日志重导出退出码为 0，无 `ERROR:` / `WARNING:` 前缀诊断，但两次输出 `Failed to bind socket. Error: 3.`，原因未确认，不能称作无异常导出；两次 EXE/PCK 的 SHA-256 一致。官方 release 模板身份已核对，实际 PCK 挂载验证通过：1,033 条原始数据、4,200 条资源依赖存在，68,437 条排除路径及导入产物不可达。`export_release.py` 包装未在隔离工程执行，不能计为通过。
- 同机 Windows 窗口、Vulkan Mobile、1600×1000、隔离空档案，正式 release EXE 一次无截图插桩：加载页首绘至目标场景未被遮挡的首绘为主菜单 959 ms、地图 576 ms、`level_1` 894 ms；按进程帧观测的 archive/map/battle 作用域准备分别为 31/83/42 ms。主菜单从探针 Autoload 就绪到首绘为 1,129 ms，不含进程启动前段。
- 同次测量中，读档面板从工厂调用到首绘 29 ms、6 个空档槽位文字全部出现 32 ms；任务面板首绘 7 ms、18 个任务标题全部出现 49 ms；炼丹炉首绘 27 ms、切合成首绘 9 ms、暂停菜单首绘 9 ms。`frame_post_draw` 表示引擎完成视口更新，不是显示器物理呈现或输入延迟；每项只有单次样本。另行截图验证了首帧和完整内容；截图会增加耗时，未混入上述无截图值。
- release `level_1` 四阶段均通过，进程退出码 0，但出现 19 个 `ObjectDB` 泄漏警告，整项验收 FAIL。无注入探针的窗口冷启动后发送 `WM_CLOSE`，退出码 0，仍有 18 个零引用 `RefCounted` 泄漏；旧版 EXE 同条件为 2 个。窗口退出还报告纹理 RID 泄漏和 `RenderingServer::get_singleton() is null`，新旧版本均出现，其根因未确认。
- 最小对照与项目场景对照均支持 Godot 4.7.2 线程加载 `LoadToken` 缺陷：40 场景嵌套 `preload` 的同步加载和普通 `Thread` 各 3 次均无泄漏；`load_threaded_request` / `get` 各次泄漏 39 个零引用对象。独立加载 `ldl.tscn` 与 `load_scene.tscn` 时，线程加载分别泄漏 4 和 2 个；同步及普通线程对照均为 0。参见 Godot [#120661](https://github.com/godotengine/godot/issues/120661) 和未合并修复 [#121025](https://github.com/godotengine/godot/pull/121025)。这些证据不能证明正式 EXE 的每一个泄漏对象或额外纹理 RID 均由同一根因造成。
- 冷进程中并行预热互相依赖的炼丹场景曾发生加载等待并超时；当前串行预热的目标路径已返回 `SCOPE_READY=true`。

详细缓存所有权与场景交接见 [`runtime_lifecycle_matrix.md`](runtime_lifecycle_matrix.md)。

## 3. 当前未验证边界

- **发布**：UI 变更后已独立导出正式 EXE/PCK 并做包内闭包及窗口诊断，但退出泄漏未解决、`level_1` release 探针日志门禁失败；正式发布不得计为通过。真实输入到结算、物理屏幕呈现延迟、设备 VRAM 全路径和双人完整矩阵仍未验证。`export_release.py` 对打开的工程运行时曾因 `godot-mcp` 端口冲突失败。
- **平台**：Spine GDExtension 只入库 Windows x86_64；最低硬件配置未声明，其他平台延期/未验证。决策见 [ADR-010](../decisions/ADR-010-spine-runtime-boundary.md) 与 [ADR-027](../decisions/ADR-027-platform-commitment-and-verification-device.md)。
- **外部服务**：云存档服务端、训练和成就闭环依赖外部能力，不据本地内容回植宣称已完成。
- **公开仓库**：第三方美术、音乐、字体和精灵表不入库；公开 clone 缺素材提示属于预期。
- **待复核风险**：`get_meta(key, null)` 的调用点清单见 [`../issues/known-issues.md`](../issues/known-issues.md)；缺失资产见 [`../standards/missing_assets_registry.md`](../standards/missing_assets_registry.md)。

## 4. 维护边界

本页只记录当前内容基线、最近一次完整验证与仍未验证的边界。详细门禁命令和通过判据以 [`acceptance.md`](acceptance.md) 为准；实现架构以 [`architecture.md`](architecture.md) 为准；阶段顺序以 [`../roadmap/roadmap.md`](../roadmap/roadmap.md) 为准。