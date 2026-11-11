# BHYH 验收标准

> **职责**：定义当前脚本门禁、可复现运行夹具、通过阈值和按变更类型必须补充的验收。实际执行事实只记 [`status.md`](status.md)，阶段状态只记 [`../roadmap/roadmap.md`](../roadmap/roadmap.md)。命令注册依据 `scripts/check_all.py` 与 `scripts/contract_gate.py`，工具目录和参数索引见 [`../../scripts/README.md`](../../scripts/README.md)。
>
> 完整工作区含合法授权素材；公开 clone 可能缺少 `Art/`、`Music/`、`Font/`、`Spritesheet/`。资源扫描对缺失素材根的处理按各门禁实际范围；缺失资源提示不是通用豁免。

## 1. 验收档位

| 档位 | 适用 | 必需证据 |
|:---|:---|:---|
| **L0 静态门禁** | 无 Godot 的提交前检查 | `python scripts/check_all.py --skip-engine`；执行行尾、格式、核心 lint、契约/资源、命名、NodePath/Global 引用及资源路径维度。引擎与 DragonBones 两维被显式跳过，不能据此声称 L1 通过。 |
| **L1 引擎健康** | 改动 GDScript、场景、资源、输入或物理层 | `python scripts/check_all.py --godot-bin "<godot>"`；检查当前全部已注册维度。 |
| **L2 运行期** | 改动玩法、关卡、双人、HUD、场景流、存档或资源消费者 | L1 + 受影响的单关冒烟、双人探针、场景探针或档案夹具；正常逻辑、边界和失败路径均需覆盖。 |
| **L3 发布 / 发布依赖** | 发布、目标包依赖变更或全量收口 | L2 + 全量关卡回归、release 窗口冷启动/`WM_CLOSE` 退出探针、命名终审、文档索引/链接审计；改动导出依赖时执行相应实际 PCK 探针。 |

跳过门禁的开关只能用于明确的较低档位或定向诊断，不能把跳过维度计为完成的验证。

## 2. `check_all.py` 当前注册维度

标准运行包含下列维度；顺序就是脚本固定的汇总顺序。

| 维度 | 实际命令 | 通过判据 |
|:---:|:---|:---|
| 1 | `python scripts/normalize_eol.py source --dry-run` | stdout 含 `发现并清洗 CRLF 文件数: 0`。`--fix` 时，行尾维度以修复命令退出码 0 通过。 |
| 2 | `python scripts/format_all.py source --check` | 命令退出码 0，且 stdout 含 `所有代码完全符合代码格式规范`；`--fix` 格式修复以命令成功文本/退出码通过。GDScript 行宽为 **120**。 |
| 3 | `gdlint`（`check_all.py` 登记的核心脚本子集） | 退出码 0，stdout 含 `no problems found`；不是全仓 lint。 |
| 4 | `python scripts/health_check.py`（可透传 `--godot-bin`） | 退出码 0，且 stdout 含 `0 Parse Error`（或 `0 严重编译错误`）及 `0 处断裂引用`。Godot 编译子进程超时 **30 秒**。 |
| 5 | `python scripts/contract_gate.py` | 所有已注册子命令退出码 0；`docs/reports/contract_audit.json` 存在且 `ERROR=0`、`WARNING≤1050`。 |
| 6 | `python scripts/naming_audit.py --all` | 退出码 0。 |
| 7 | `python scripts/runtime_reference_audit.py` | 退出码 0；不得有无法解析的场景 NodePath 或未声明的 `Global` 方法引用。 |
| 8 | `python scripts/resource_path_audit.py --project source` | 退出码 0；静态资源大小写、可识别动态路径/Spine 页名与登记工厂目标符合规则。 |
| 9 | `python scripts/verify_dragonbones_factories.py`（可透传 `--godot`） | 退出码 0；登记工厂均完成加载验证。 |

`--skip-engine` 与 `--fast` 明确跳过维度 4、9；这是七个非引擎维度的运行配置，不是全维度门禁。其余支持的跳过参数为 `--skip-contract`、`--skip-naming`、`--skip-runtime`、`--skip-resource`。`--godot-bin` 传给引擎检查；`--dragonbones-full` 强制 DragonBones 全量；`--health-full` 强制引擎重编译；`--no-cache` 禁用适用缓存，`-j/--jobs` 调整并发（默认 **6**）。`--fix` 先串行修复行尾/格式，再并行执行只读门禁。

### 2.1 失败语义

- 行尾检查由 `check_all.py` 再看报告文本；正常检查必须出现 CRLF 数为零的文本。修复模式要求修复命令成功。
- 引擎检查默认 `WARNING_ALLOWLIST` 为空：Parse Error、`SCRIPT ERROR:` 或未豁免 GDScript warning 会使健康检查标记 failed；普通 `ERROR:` 行本身不属于该脚本编译失败条件。场景资源断裂写入报告，但 `check_all.py` 另要求健康输出明确包含 `0 处断裂引用`。
- `health_check.py` 在 Godot 不可用时可返回 `skipped` 且退出码为 0；其超时/内部 `error` 也不一定以非零码退出。`check_all.py` 还要求上述成功文本，所以无 Godot 时必须显式用 `--skip-engine`，不得把 skipped 当作 L1。
- 契约维度有两层条件：任一 `contract_gate.COMMANDS` 子命令非零即失败；其后还需报告存在、`ERROR=0` 且 `WARNING≤1050`。预算是上限，不得以扩大豁免或改成 WARNING 隐藏 ERROR。
- `check_all.py` 成功退出 `0`，任一启用维度失败退出 `1`；由运行配置跳过的维度会显示为 skipped/不运行，不构成相应档位证据。

## 3. `contract_gate.py` 当前子门禁

下列命令是 `scripts/contract_gate.py` 的实际 `COMMANDS` 注册。子命令按登记顺序汇总；`--jobs N` 限制并发数（正整数，默认不超过 8、CPU 数量和子命令数）。任一子命令非零即 gate 失败。

| 检查面 | 注册命令 |
|:---|:---|
| 契约扫描与负/正样本 | `python scripts/contract_scan.py --fail-on-error`<br>`python scripts/contract_scan.py --self-test` |
| Atlas Metadata | `python scripts/convert_atlas_metadata.py --check`<br>`python scripts/convert_atlas_metadata.py --self-test` |
| 构建帧/序列 | `python scripts/convert_frame_sequences.py --check`<br>`python scripts/convert_frame_sequences.py --self-test`<br>`python scripts/convert_monster_frames.py --check`<br>`python scripts/convert_numbered_frames.py --all --check`<br>`python scripts/convert_sheet_frames.py --check`<br>`python scripts/convert_liu_sha_frames.py --check`<br>`python scripts/convert_monster_action_views.py --check` |
| 关卡/怪物/装备 Catalog | `python scripts/convert_level_preload_catalog.py --check`<br>`python scripts/convert_level_layout_catalog.py --check`<br>`python scripts/level_layout_migration_audit.py --fail-on-error`<br>`python scripts/convert_external_monster_catalog.py --check`<br>`python scripts/convert_equipment_catalog.py --check` |
| 运行时帧与原始导出清单 | `python scripts/runtime_frames_audit.py --fail-on-error`<br>`python scripts/export_raw_manifest.py --check --allow-missing`<br>`python -m unittest discover -s scripts/tests -p test_export_asset_exclusions.py`<br>`python -m unittest discover -s scripts/tests -p test_export_diagnostics.py`<br>`python scripts/png_stream_audit.py --fail-on-error` |
| Theme、字体与表面 token | `python scripts/theme_override_audit.py --check`<br>`python scripts/convert_ui_theme_tokens.py --check`<br>`python scripts/theme_token_audit.py --check`<br>`python scripts/theme_variant_audit.py --check`<br>`python scripts/ui_dynamic_theme_audit.py --check`<br>`python scripts/font_coverage_audit.py --check`<br>`python scripts/font_role_audit.py --check`<br>`python scripts/ui_surface_token_audit.py --check`<br>`python scripts/ui_surface_token_audit.py --self-test` |
| 冻结豁免 | `python scripts/whitelist_audit.py --fail-on-error` |

### 3.1 `contract_scan.py` 注册类别与报告级别

下列类别名与当前 `ContractScanner.run_all_checks()` 注册一致；本节不把类别数或历史报告数量作为接口契约。

| 类别组 | 当前类别名 | 判定 |
|:---|:---|:---|
| 引用/字面量检查 | `resource_path`, `node_path`, `reflection`, `anim_track`, `dict_key` | 路径/节点/反射/动画规则命中大小写或符号失配时为 ERROR；无场景节点末段疑似大小写问题为 WARNING；未知反射方法为 INFO、未知信号为 WARNING；DataKeys 已登记的中文键为 WARNING、未登记的为 INFO。 |
| 运行时边界 | `runtime_manifest`, `atlas_boundary`, `preload_boundary`, `scene_entry`, `load_cache`, `pool_ui`, `run_state_boundary` | 禁止运行时解析 manifest、绕过 Atlas View/预载 Catalog/`Global.change_scene`/缓存交接边界，以及已退役状态/池/UI 私有入口；违规为 ERROR。 |
| 全局与数据所有权 | `global_surface`, `global_signal`, `archive_boundary`, `slot_boundary`, `panel_operator`, `shared_ledger` | 新增未登记 Global 表面/信号、绕过存档入口、硬编码 1P、缺少面板操作者或共享账本登记/快照互斥均为 ERROR。Global 表面登记源为 `scripts/global_surface_baseline.json`。 |
| 业务访问边界 | `audio_entry_boundary`, `hud_panel_boundary`, `phase17_boundary`, `input_boundary`, `passive_boundary`, `pet_passive_boundary` | 音频旁路、HUD/面板直接写档、结算/命令/表现边界、输入与写档混行、被动快照/宠物被动写入违规均为 ERROR。 |

资源路径大小写不符是 ERROR；指向带文件扩展名且非格式动态路径的缺失文件为 ERROR，不能确定为文件路径的缺失项为 WARNING。`--fail-on-error` 只因 ERROR 返回非零；WARNING/INFO 写入报告，但 WARNING 总量仍受 `check_all.py` 的 **1050** 棘轮上限约束。

`contract_scan.py --self-test` 只运行其已登记边界规则的好/坏样本，不执行全项目扫描、也不写全项目报告；它已包含在 contract gate 注册中。修改契约规则时，仍需确认相应类别的自测和全扫描均通过。白名单为 `schema_version=2`、`frozen=true` 的精确集合；磁盘登记与实际集合/冻结摘要必须一致，不能用新增豁免消除新违规。

### 3.2 UI / Theme 阈值

以下值是当前守卫的上限/契约，不是历史跑数：

| 门禁 | 通过规则 |
|:---|:---|
| `font_coverage_audit.py` | 静态与动态样本不能缺字；Theme 字体文件不超过 **6**；无未引用 Theme 字体资源，字体文件必须可读。 |
| `theme_variant_audit.py` | 冻结变体不得缺失、变体继承无环、引用 StyleBox 均存在；Theme 属性 ≤ **2,000**、StyleBox ≤ **36**、有效重复签名组 ≤ **10**。 |
| `theme_override_audit.py` | 与冻结基线相比，新增场景覆盖/静态属性/动画轨道/场景直接字体、动态主题调用总数/文件数/路径均失败。 |
| `ui_dynamic_theme_audit.py` | 静态角色覆盖必须为 **0**；调用总数、登记文件与单文件范围不得越过基线；解析失败为失败。 |
| `font_role_audit.py` | 字体角色/包装/fallback 与字号符合 token/基线；新增、失效或被改写的字号例外均失败。 |
| `theme_token_audit.py` / `ui_surface_token_audit.py` | 新增/改写 Theme 值只能使用已登记 token；自绘 StyleBox 与主菜单裸色不得超过冻结基线。 |

## 4. L1 引擎健康检查

`health_check.py` 的实际命令由 `check_all.py` 组装；单独诊断可用：

```bash
python scripts/health_check.py --project source --godot-bin "<godot>"
```

它检查工程脚本编译/静态 warning、场景外部资源引用，并生成报告。健康通过要求没有 Parse Error / `SCRIPT ERROR:` / 未豁免 GDScript warning；全场景断裂引用另由 `check_all` 文本判据要求为零。死代码候选只进报告，不是通过阈值。此检查不把普通 `ERROR:` 行作为单独编译失败条件，运行期 0/0 应由下节夹具判定。

## 5. L2 运行期验收

涉及运行行为时，基线命令为：

```bash
python scripts/level_test_runner.py --godot "<godot>" --level res://Scene/level/level_1.tscn
python scripts/coop_probe_runner.py --godot "<godot>"
python scripts/scene_probe_runner.py --godot "<godot>"
```

`scene_probe_runner.py` 无 `--probe` 时依次执行 `PROBES` 全部注册项；单项定向复跑使用 `--probe <registered-key>`，各项默认 timeout 以 `ProbeSpec.timeout_seconds` 为准，`--timeout` 可覆盖。L2 的关卡、双人或资产特定变更还须增加受影响的目标关卡/探针；档案读写、身份、补全或保存边界改动须另跑 `archive_probe_runner.py`。

### 5.1 单关冒烟：`level_test_runner.py`

```bash
python scripts/level_test_runner.py --godot "<godot>" --level res://Scene/level/level_1.tscn
python scripts/level_test_runner.py --godot "<godot>" --level res://Scene/level/level_1.tscn --performance-sample-frames 300 --performance-warmup-frames 120
python scripts/level_test_runner.py --godot "<godot>" --level res://Scene/level/level_1.tscn --measure-load --render-window
```

| 参数/判据 | 当前行为 |
|:---|:---|
| 默认关卡/倍速/超时 | `level_1.tscn` / **3.0×** / **300 s**；Godot 通过 `--godot` 或 `GODOT_BIN` 指定。 |
| 加载守卫 | 等待目标关卡最多 **45,000 ms** 或 **20,000 帧**；主角稳定 **60 帧**后推进阶段断言。 |
| 通过条件 | 驱动 JSON 报告 `ok`，且报告前运行日志中的 `SCRIPT ERROR`、`ERROR:`、`WARNING:` 计数均为 0；退出码 0 通过，1 为失败，2 为夹具异常。 |
| headless 豁免 | 只剔除 dummy renderer 的 `Parameter "t" is null`、`Parameter "mem" is null` 与 `Initializing already initialized RID` 噪声（含缩进栈）；其他日志不可泛化豁免。 |
| 可选性能采样 | `--performance-sample-frames N` 默认关闭；warmup 默认 **120 帧**。`p95_ms≥8.0` 标记整段节流，`p50_ms<2.0` 时归为偶发；默认最多重跑 **1** 次并保留较低 p95。持续节流本身不判 FAIL，读数不可用于性能对照。 |
| HUD 压力场景 | `--performance-hud-full` 维持 **80** 个活跃伤害数字；须与帧采样一起使用，达不到上限为 FAIL。 |
| GPU 证据 | 默认 headless/dummy 渲染无实际绘制/GPU 呈现证据；`--render-window` 才走窗口渲染路径。该模式仍不是目标硬件性能基线。 |
| 加载测量 | `--measure-load` 单测加载阶段并提前结束；需 `--render-window` 才有可用 GPU 数据。报告的加载阶段/峰值字段见 `scripts/README.md`，不判定硬件 SLA。 |

性能报告是 runner 指定的诊断口径，不把一次测量升级成硬件 SLA。临时驱动资源、报告和日志位于 `source/` 并由 runner 清理。

### 5.2 关卡回归：`level_regression_all.py`

```bash
python scripts/level_regression_all.py
python scripts/level_regression_all.py --changed-only --diff-base HEAD~1
```

候选从 `Scene/level/` 当前场景名动态发现。默认单关 timeout **150 s**，外层子进程上限为 `timeout + 90 s`；失败关串行重试一次，并在报告保留首轮失败证据。`--changed-only` 无法映射的源码会保守回退全量；无变更的 changed-only 返回 0。`NON_BATTLE_SPECIALS` 中无 Hero 根节点的菜单、地图和信息面板报告为 SKIP，既定战斗关卡回归口径中 SKIP 计入通过；`level_info` 由 `scene_probe_runner.py --probe level-entry` 在档案会话上下文中验证，不由战斗关卡夹具直接启动。L2 改动仍须覆盖真正受影响的战斗路径。退出码：全部通过（含该类 SKIP）为 0；失败或筛选后无候选为 1；工程缺失或 git diff 失败为 2。

### 5.3 双人矩阵：`coop_probe_runner.py`

- `CASES` 是夹具用例事实源；runner 串行执行，单探针默认 timeout **180 s**，可用 `--timeout` 覆盖。
- 每个结果必须有可解析的最后一条 `COOP_MATRIX_RESULT=<json>`；缺失/无效结果或超时为 FAIL。
- `SCRIPT ERROR:` / `ERROR:` 行失败，唯一日志豁免为 `resources still in use at exit`；结果中的 `SKIP` 不能算 PASS。runner 进程退出 0 只表示没有 `FAIL`；L2 验收必须检查报告并确认所需用例没有未覆盖的 SKIP。

### 5.4 场景夹具与档案持久化

`scene_probe_runner.py` 对每个注册 `ProbeSpec` 使用完整工程生命周期启动临时场景。每项须产出有效 `*_PROBE_RESULT`，通过结果、要求的 teardown marker、引擎退出码以及无未登记 `SCRIPT ERROR` / `ERROR` / `WARNING`；缺少规格/工程或 Godot 为 2，任一探针失败/超时为 1。只忽略脚本明确列出的 `expected_noise`、dummy renderer `Parameter "t" is null` 和引擎退出的 RID/ObjectDB 清理噪声。不得按 marker 泛化豁免日志。

UI 作用域和炼丹界面改动另跑 `--probe ui-scope` 与 `--probe ldl-runtime`；分别覆盖真实资源预热、跨作用域释放、过期与失败请求，以及同帧页签切换、背包数据刷新和强化保存失败回滚。`ldl-runtime` 使用隔离临时 `user://`；指定的缺失资源失败样本只按唯一路径允许引擎诊断。

存档/身份/保存命令改动：

```bash
python scripts/archive_probe_runner.py --godot "<godot>"
```

该夹具使用隔离临时 `user://` 并运行真实档案写入路径；默认 timeout **120 s**。缺少结果、任一断言失败、隔离目录检查失败、未登记 ERROR/WARNING 或超时均不能通过；测试用的预期拒绝日志仅按脚本显式标记忽略。

## 6. 构建资源与发布包验收

AtlasMetadata、FrameSequence、编号帧、sheet 帧、怪物帧、关卡预载/布局、装备和外部怪物 Catalog 的源同步/结构检查由 §3 注册于 `contract_gate.py` 的 `--check` / `--fail-on-error` 子命令执行。哪吒预览转换器未在当前 gate 注册，涉及该输入/输出时须另跑：

```bash
python scripts/convert_nezha_preview_frames.py --check
```

当前 Windows 发布预设保留 `all_resources` 基线。`Scene/level/zmws/`、`Scene/level/zmws_playable/`、`Art/level/zmws/` 与未绑定的 ZMWS 资产库不进入发布包；源场景和私有素材保留供编辑器使用。背包图标、既有 Spine 资源和 `data/zmws_config/` 原始数据仍须保留。混合素材目录中的排除前缀只能命中 DragonBones 工厂目录；新增实际消费者或前缀误伤必须先调整发布策略，不能静默漏包。

源文件与生成清单一致，不能证明实际 PCK 闭包。涉及导出依赖或发布资源时另跑：

```bash
python scripts/export_asset_exclusions.py --check
python scripts/convert_frame_sequences.py --check --export-preset
python scripts/frame_sequence_pack_probe.py --self-test
python scripts/frame_sequence_pack_probe.py --godot "<godot>" --preset "Windows Desktop (release)" --check-exclusions
python scripts/export_closure_probe.py --self-test
python scripts/export_closure_probe.py --godot "<godot>" --preset "Windows Desktop (release)"
python scripts/export_release.py --godot "<godot>" --preset "Windows Desktop (release)"
python scripts/export_release.py --godot "<godot>" --preset "Windows Desktop (release)" --output "<release output>"
python scripts/release_exe_level_runner.py --exe "<release exe>" --pck "<release pck>" --work-dir "<isolated output>"
python scripts/release_exe_window_probe.py --exe "<release exe>" --pck "<release pck>" --work-dir "<isolated output>"
```

`export_asset_exclusions.py --check` 校验预设一致性、指定目录和 DragonBones 工厂覆盖、混合目录误伤及可静态解析的生产引用；缺少私有素材返回 BLOCKED。它不证明动态拼接路径或实际包内容。`frame_sequence_pack_probe.py --check-exclusions` 在实际导出并挂载的 PCK 中检查必需路径存在、排除资源及其已登记导入产物不可达；`export_closure_probe.py` 检查插件写入数与原始 JSON/BIN 路径。导出必须同时生成产物、退出码为 0、日志无 SCRIPT ERROR / ERROR / WARNING；产物存在不能掩盖导出诊断。缺少导出模板/PCK、探针超时或结果协议无效为 BLOCKED（返回 2）；导出诊断、非零退出、缺少必需路径或意外包含排除资源为 FAIL（返回 1）。插件日志的 `files` 必须等于 `expected` 且 `missing=0`。`export_release.py` 运行上述预检及两种 PCK 探针，可选产出 release 可执行文件；它不代替冷启动、目标设备/平台加载、VRAM 或首帧实测。版本/当前平台结论另见 `status.md` 和 [`spine_platform_baseline.md`](spine_platform_baseline.md)。

`release_exe_level_runner.py` 使用官方 release EXE 与发行 PCK，在独立运行目录追加仅指向 `user://` 的测试 Autoload；不修改 EXE/PCK，也不覆盖 `res://` 资源。它验证启动场景、生产 Autoload、`level_1` 四阶段、结算预载及切关清理；引擎日志、报告和进程退出码均须通过。该探针使用内存测试状态、直接切关和强制清怪，不替代用户输入、结算流程或目标设备实测。

`release_exe_window_probe.py` 在 Windows 桌面会话直接启动同一发行包，不注入 override/Autoload；等待唯一可见窗口后发送 `WM_CLOSE`，验证真实窗口退出路径。通过判据为退出码 0、无 RID/ObjectDB/资源泄漏、无 `RenderingServer` 空单例错误、0 SCRIPT ERROR 与 0 ERROR/WARNING。Vulkan 驱动/加载器的窗口启动噪声按固定模式单独计数，不计为引擎诊断；其余告警不得豁免。非 Windows 或无法创建可见窗口返回 BLOCKED（2），headless 结果不能替代该路径。

## 7. 命名、文档与其他人工门禁

```bash
python scripts/naming_compliance_audit.py --fail-on-error
python scripts/docs_audit.py --check
python scripts/normalize_eol.py docs --dry-run
```

`check_all.py` 已执行 `naming_audit.py --all`；`naming_compliance_audit.py` 是覆盖目录、文件、标识符与白名单的独立终审。`docs_audit.py` 检查 Markdown 相对链接、文档目录索引和 `scripts/README.md` 工具索引；它不属于 `check_all`。脚本名称、职责及其余人工工具以 [`../../scripts/README.md`](../../scripts/README.md) 为准。

## 8. 按变更类型的验收矩阵

| 变更类型 | 必需门禁 / 追加证据 | 不构成通过 |
|:---|:---|:---|
| 文档 | `docs_audit.py --check`、`normalize_eol.py docs --dry-run`；同步职责索引和相对链接 | 只改正文但留断链/索引遗漏；将本次未运行写成 PASS |
| 纯 GDScript | L1；触及生产行为时追加受影响场景/单关 smoke 或定向 probe | 只运行 lint；无引擎 L0 冒充 L1 |
| 场景 / 节点 / 动画轨道 | L1；相关关卡冒烟、实际 NodePath 与动画轨道绑定 | 只编译，不走生产场景；绕过门禁的直接场景切换 |
| 美术 / 音频 / 字体 | L1 与实际 Godot 导入/加载；对应构建转换 `--check`；相关关卡或消费者探针 | 只检查路径字符串/文件存在，未加载实际资源；headless 性能数字当 GPU 证据 |
| 输入 / 物理层 | L1；P1/P2 的真实输入路径与碰撞/关卡行为；涉及双人时跑完整 coop 矩阵 | 只改 `project.godot` 不验证生效行为；只测 P1 |
| 档案、会话或保存入口 | L1 + `archive_probe_runner.py`；当前/新档、缺字段、损坏/备份、失败回滚、切档/退出身份边界 | 只测新档成功保存；无会话/写入失败无断言 |
| 双人槽位 / 共享账本 / 面板操作者 | L1 + coop 矩阵和受影响面板运行路径；核对 `slot_snapshot`、`shared_keys` 与显式 `coop_slot` | 只测 1P；把 SKIP 当通过；引入全局 1P/2P 视图交换或漏登记共享键 |
| 宠物 View / 命令 / 关卡生成 | L1 + 相应 `pet-runtime` / `pet-nian` 场景探针和槽位/保存路径；失败时检查档案及共享资源回滚 | 只检查编译；将其他宠物 UI 写入错误地宣称已全部命令化 |
| UI / HUD / 显示 / Theme | L1 + 受影响 UI 场景；桌面 16:10、16:9、21:9 与 P1/P2 截图；触控布局单独覆盖 | 单分辨率截图、未检查 HUD/安全边界；绕过 Theme token/baseline |
| 关卡 / 玩法 / 战斗来源 | L1 + 受影响关卡 `level_test_runner.py` 与 changed-only 回归；覆盖阶段推进、刷怪、出口、奖励/结算一次 | 只测首阶段；延迟弹体/召唤/法宝来源默认落到 1P |
| 场景流 / 缓存 / 池 / 异步 | L1 + `scene_probe_runner.py` 的 `load-guard` / `level-resource-lease` 和冷启动/返回/重战路径 | 只移字段或清缓存；不覆盖过期请求、提前退出、所有者外误删 |
| 资源构建/边界规则 | L1（含 gate/self-test）+ 对应源转换 `--check`；改导出依赖时实际 PCK 探针 | 只检查产物存在或预设声明，不校验内容/PCK；BLOCKED 记为通过 |
| Release / 完整验收 | L3：全量 `level_regression_all.py`、`release_exe_level_runner.py`、`release_exe_window_probe.py`、命名终审、docs 索引检查；实际受影响 PCK 与 release 运行路径 | changed-only 替代发布全量；其他平台/设备/分辨率被默认推定通过 |

## 9. 证据与失败处置

1. 保留原失败命令、首个错误、报告与复现条件；重跑不能覆盖首轮证据。
2. 区分源码/数据/资源/门禁/环境问题。不得通过删除检查、扩大豁免、把错误降级或加入兼容回退来得到绿灯。
3. 修复后重跑同一门禁及受影响生产路径；跨档案、槽位、暂停与异步生命周期的失败须覆盖相应边界。
4. 未执行的平台、硬件、分辨率、导出包或 probe 明确标为未验证；计划不属于验证事实。
5. 验证结论只写 `status.md`；`docs/reports/` 是工具产物，不手工修改或用历史报告替代当前运行。

不构成验收证据：仅代码审阅/静态类型检查、仅编译、单个成功样本覆盖失败路径、未说明的跳过项、source 清单/导出预设声明代替实际包测试，或缺少目标布局/场景上下文的截图。
