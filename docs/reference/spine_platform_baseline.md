# Spine 平台基线（21-1A / 21-2A）

> **状态**：2026-10-31 决策确认；**Windows x86_64 先行，当前唯一承诺平台**。Spine 运行时保持官方 **4.3 / Godot 4.7.2** 构建，不进行版本升级；其它平台明确“延期/未验证”，不宣称可用。
> **范围**：Spine GDExtension、活动 Spine 资源版本、平台矩阵、许可证与 Windows 加载验收；不含 Spine 3.8 遗留资产的迁移决策，也不含 21-2B 设备测量。
> **依据**：[`ADR-010`](../decisions/ADR-010-spine-runtime-boundary.md)、[`current-iteration.md`](../roadmap/current-iteration.md) §2/§3、[`missing_assets_registry.md`](../standards/missing_assets_registry.md) §2、[`acceptance.md`](acceptance.md)。
> **Owner**：项目维护者（平台/许可证决策）；项目维护者（构建/加载验证）。

## 1. 决策摘要

| 决策 | 结论 |
|:---|:---|
| 目标平台 | **Windows x86_64**；Windows 10/11 64 位为当前平台范围 |
| 渲染后端 | 工程默认 `mobile`；以 `project.godot` 为准 |
| Spine 运行时 | **保持 4.3 / Godot 4.7.2 官方构建**，不升级 |
| 目标平台二进制 | Windows editor/debug/release x86_64 已入库，无需新增 |
| 其它平台 | Linux、macOS、Android、Web、iOS **延期/未验证**；不补库、不承诺 |
| 最低设备 | **未声明**；21-2A 最低设备确认与 21-2B 一并暂缓，未取得设备测量前不以当前验证机充当最低配置 |
| 21-2B | **暂缓**；Windows 侧测量也不在本轮执行 |
| 21-2C | PCK/依赖闭包已重跑；Windows release 启动与 `level_1` 冒烟已完成 |

**不把“Windows 可运行”写成“跨平台支持”。** `source/bin/spine_godot_extension.gdextension` 声明了多平台路径，但仓库实际只包含 Windows x86_64 动态库；声明文件存在不等于运行库已入库或已验证。

## 2. 运行时与资源基线

### 2.1 运行时事实

| 项 | 事实 |
|:---|:---|
| Spine 稳定线 | 4.3；本次查证时最新编辑器补丁为 **4.3.26**（2026-09-07）；未发现稳定 4.4 |
| 官方 Godot 构建 | 4.3 分支为 Godot **4.7.2-stable** 提供 GDExtension |
| 本地构建 | `source/bin/windows` 三个 DLL 与 `.gdextension` 与官方 `spine-godot-extension-4.3-4.7.2-stable.zip` **逐字节一致**（SHA-256 相同） |
| 官方包校验 | ZIP SHA-256：`1ab0512ccd26fb5bd1e2fb93305b1757e48f7eb88268c710b84cf9a26fbb8b15` |
| 版本策略 | Spine 运行时以 major.minor 分支匹配导出资产；补丁更新不改变 major.minor 兼容性。当前没有必要替换同一份官方构建 |

结论：**“升级到最新 Spine 运行时”当前是 no-op**。只有未来出现新的稳定 major/minor 分支，且所有 Spine 资产按匹配的 Spine Editor 重新导出后，才进入版本升级评估。

### 2.2 活动资源版本

当前活动 Spine JSON 为 **4.3.00**；`Art/hero_picture/role_2/jhsj_awaken/runtime/` 与其它已恢复资源按 4.3 加载。旧 3.8 资产不属于本决策；若未来需要，按 Spine Editor 的 major/minor 匹配规则单独迁移，不能用 4.3 运行时直接读取。

## 3. 平台矩阵（21-2A）

| 平台 / 架构 | 状态 | 渲染后端 | Spine 库 | 设备/验收 | 边界 |
|:---|:---|:---|:---|:---|:---|
| **Windows x86_64** | **当前目标平台** | `mobile` | 已入库：editor / template_debug / template_release | Windows 验证机已有运行基线；Spine 加载探针见 §4 | 最低设备未声明且确认暂缓；不承诺所有 Windows 设备 |
| Linux x86_64 | 延期、未验证 | 未确认 | 官方 4.3 包含库；仓库未入库 | 无 Linux 设备 | 不补库、不写支持声明；需要时再立项 |
| Linux arm64 / rv64 | 不承诺 | 未确认 | 官方 4.3 包未提供对应库；`.gdextension` 仅有路径声明 | 无设备 | 需要自定义构建，不能只复制路径 |
| macOS | 延期、未验证 | 未确认 | 官方包含 framework；仓库未入库 | 无 macOS 设备/CI | 需要 Apple 硬件与签名/分发验证 |
| Android arm64 / x86_64 | 延期、未验证 | 未确认 | 官方包含库；仓库未入库 | 无 Android 设备 | 需要触控、生命周期与设备性能验证 |
| Web（wasm32） | 延期、未验证 | `forward_plus` | 官方包含 threads/nothreads wasm；仓库未入库 | 无浏览器矩阵 | 不能把工程配置当 Web 已验收 |
| iOS（arm64） | 延期、未验证 | 未确认 | 官方包含 framework；仓库未入库 | 无 Apple 设备/CI | 需要 macOS/Xcode 与签名 |

### 3.1 Windows 验证基线

已有 Windows release 基线（历史快照，不等同最低配置）：

- 验证机：AMD Radeon RX 6750 XT，Vulkan 1.4.315，Forward Mobile；
- `level_1` 150 FPS（引擎上限 150）；启动至首个可测帧代理约 **3.22s**；
- 专用 GPU 内存约 **713,916,416 B**；共享内存约 **103,546,880 B**；
- 正常关窗日志干净；`--quit-after` 的强制退出噪声不作为常规结论。

上述数字只描述该验证机；**峰值 VRAM、战斗负载、重复进出与最低设备仍未验证**。21-2B 暂缓期间，不以这些数字生成“最低配置”或“性能 SLA”。

21-2C 当前导出使用验证用 `all_resources` 预设，PCK 体积较 19-3C 的约 2.74 GB 增至约 7.56 GB；这只能证明当前依赖路径可达，**不是最小发布闭包**，也不能单独作为发布策略结论。

## 4. Spine 加载验收

Windows 侧验收使用现有场景探针与资源加载路径，不新增跨平台声明：

- `source/bin` 三个 Windows 动态库与官方 4.3 构建一致；
- 活动 Spine 源文件为 4.3；已恢复的 `.spine-json` 通过导入缓存加载；
- `scene_probe_runner --probe role-skills` **PASS**（4.63s），覆盖 `jhsj_awaken` 预加载与角色技能路径；

Windows release 验证构建（临时冒烟驱动，验证后已删除并恢复主场景）：

- 导出 exe 约 105 MB + PCK 约 7.1 GB；
- 启动后加载真实生产主场景 `load_scene.tscn` → `main_menu.tscn`，再切入 `level_1.tscn`；
- 报告 `ok=true`，生产主场景 `main_menu.tscn`，目标关卡 `level_1.tscn`，耗时约 **3.762s**；
- 最终退出日志 **0 ERROR / 0 WARNING**；Vulkan 1.4.315 / Forward Mobile / AMD Radeon RX 6750 XT。
- 这是验证包，不是最小发布包；不改变发布预设，也不代表峰值 VRAM 或跨平台性能。
- 资源路径审计继续校验 atlas 页名与 PNG 大小写；
- 任何 Spine 加载失败都必须显式失败，不以静态图或静默缺帧回退。

## 5. 许可证与再分发

- 运行时许可：**Spine Runtimes License Agreement**（`source/bin/SPINE_RUNTIMES_LICENSE.txt`）；
- 每个最终用户需自行获得 Spine Editor 许可证；再分发必须附带该许可证与版权声明；
- Spine 运行时许可证不授予 Spine 资产（skeleton、atlas、图片、音频）的使用权；
- 增加平台库不等于改变许可证；若未来补齐平台库，发布包仍必须携带 `THIRD_PARTY_NOTICES.md` 与许可证全文。

## 6. 批次结论

| 批次 | 结论 |
|:---|:---|
| 21-1A | **Windows-only 决策完成**；运行时保持 4.3 官方构建；Windows 二进制已具备；`role-skills` 加载探针 **PASS**（4.63s） |
| 21-2A | **平台/后端已确认**：Windows x86_64 为唯一目标，后端以工程默认 `mobile` 为准；其它平台全部延期/未验证；**最低设备确认与 21-2B 一并暂缓，本批次不再有可执行项** |
| 21-2B | **暂缓**：无 Linux/macOS 等设备；Windows 侧测量本轮也不做 |
| 21-2C | PCK/依赖闭包已重跑：**4,100/4,100 可达**，PCK **7,564,128,928 字节**，sha256 `fa5fdf29adbb…`，导出+校验约 **675s**；release 验证包启动真实生产主场景并进入 `level_1`，报告 **ok=true**（3.762s），最终日志 **0 ERROR / 0 WARNING** |

## 7. 不在本决策范围

- 不升级 Spine 运行时到未经证实的 major/minor 版本；
- 不补 Linux/macOS/Android/Web/iOS 二进制；
- 不处理 Spine 3.8 遗留资产（C1 另列）；
- 不声明最低设备、峰值 VRAM、战斗负载或跨平台性能；
- 不改变玩法数值、动画时序、输入映射或存档格式。

## 8. 复查条件

出现以下任一条件时重新评审本页：

1. 目标平台从 Windows-only 扩展；
2. Spine 发布新的稳定 major/minor 分支；
3. Godot 引擎升级导致 GDExtension 需要重建；
4. 21-2B 取得可复现目标设备数据；
5. Spine 资产版本或许可证发生变更。
