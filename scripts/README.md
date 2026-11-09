# 脚本工具链 (Scripts)

本目录是工程级自动化工具链。所有脚本以仓库根为基准解析路径，默认工程目录为 `source/`，默认报告目录为 `docs/reports/`。

## 1. 环境要求

| 依赖 | 说明 |
|:---|:---|
| Python | 3.10+ |
| `gdlint` / `gdformat` | gdtoolkit；`check_all.py` 与 `format_all.py` 依赖 |
| Godot 4.7.2 | 引擎编译、关卡回归、探针与资源转换需要；通过 `--godot` / `--godot-bin` / `GODOT_BIN` 指定 |
| `rg`（ripgrep） | `asset_reference_audit.py` 使用 |

脚本不内置本地 Godot 绝对路径，也不把本地二进制、解密沙盒或临时目录写入代码与文档。

## 2. 门禁拓扑

```text
check_all.py
├── normalize_eol.py / format_all.py / gdlint
├── health_check.py
├── contract_gate.py
│   ├── contract_scan.py（类别以注册为准）
│   ├── convert_atlas_metadata.py --check / --self-test
│   ├── convert_frame_sequences.py --check
│   ├── convert_monster_frames.py --check
│   ├── convert_numbered_frames.py --all --check
│   ├── convert_sheet_frames.py --check
│   ├── convert_liu_sha_frames.py --check
│   ├── convert_monster_action_views.py --check
│   ├── convert_level_preload_catalog.py --check
│   ├── convert_level_layout_catalog.py --check
│   ├── level_layout_migration_audit.py --fail-on-error
│   ├── convert_external_monster_catalog.py --check
│   ├── convert_equipment_catalog.py --check
│   ├── equipment_data_audit.py --check
│   ├── png_stream_audit.py / runtime_frames_audit.py
│   ├── export_raw_manifest.py --check
│   ├── theme_override_audit.py / font_coverage_audit.py / font_role_audit.py / theme_token_audit.py / whitelist_audit.py
├── naming_audit.py --all
├── runtime_reference_audit.py
├── resource_path_audit.py
└── verify_dragonbones_factories.py

level_regression_all.py → level_test_runner.py
coop_probe_runner.py → coop_probes/
scene_probe_runner.py → scene_probes/
archive_probe_runner.py → archive_probes/（隔离临时 user://）
frame_sequence_pack_probe.py（发布前独立执行）
```

门禁名称、参数与判据以 [`acceptance.md`](../docs/reference/acceptance.md) 为单一文档事实源；`contract_scan.py` 的类别与数量以脚本注册为准，不在本页复制清单。

## 3. 工具目录

### 3.1 总门禁

| 脚本 | 作用 |
|:---|:---|
| `check_all.py` | 总门禁；支持 `--skip-engine`、`--skip-contract`、`--skip-naming`、`--skip-runtime`、`--skip-resource`、`--fast`、`--fix`、`--no-cache`、`--jobs`、`--godot-bin` |

### 3.2 静态与契约门禁

| 脚本 | 作用 |
|:---|:---|
| `normalize_eol.py` | LF/CRLF 归一化与增量缓存 |
| `format_all.py` | `gdformat` 校验/格式化 |
| `health_check.py` | 场景引用、Autoload、死代码、Headless 编译与静态 warning |
| `contract_gate.py` | 契约扫描、资源转换校验、PNG guard、Theme/字体/表面色与白名单子门禁 |
| `contract_scan.py` | 资源路径、NodePath、反射、动画轨道、字典键与运行边界扫描；含 Global 表面基线、全局信号基线、被动属性边界与宠物被动边界；`--self-test` 覆盖正负样本 |
| `naming_audit.py` | 目录/文件 `snake_case`；`Scene/` 根级 `.tscn`、`Script/` 根级 `.gd`、`Scene/` 下 `.gd` 报 ERROR；`--all` 全量 |
| `naming_compliance_audit.py` | 全量命名终审；人工执行，不在日常 `check_all` 内 |
| `whitelist_audit.py` | 白名单冻结、未登记与失效项 |
| `png_stream_audit.py` | StreamedPngEffect allowlist 与旧数组/目录/编号探测回归 |
| `runtime_frames_audit.py` | 运行时 `SpriteFrames.new()` 与 allowlist 守恒 |
| `theme_override_audit.py` | 场景直接 Theme 属性、动画轨道、直接字体与动态调用/文件上限基线 |
| `font_coverage_audit.py` | 静态场景/动态样本 CJK 覆盖；检查 Theme 字体文件 ≤6、未引用 Theme 字体资源与字体文件可读性；样本见 `font_dynamic_samples.json` |
| `font_role_audit.py` | UI 字体角色语义门禁：有效字体归类、角色包装与 fallback、脚本/场景直接字体、宋体残留与字号例外基线；`--write` 生成 `font_role_baseline.json` |
| `ui_text_punctuation_audit.py` | 报告式扫描 `.gd`/`.tscn` 中文自然语言 ASCII 标点；排除日志、数学公式、`@export_enum`、路径与编号标记；默认 report-only，`--fail-on-findings` 可阻断，支持 `--self-test` |
| `theme_token_audit.py` | 检查新变体/改写值是否使用 token 字号、描边、颜色与 Button 基类；基线见 `theme_token_baseline.json` |
| `theme_variant_audit.py` | Phase 27-4 语义基类、冻结变体、Theme 属性/StyleBox 上限与独立变体重复签名门禁；冻结清单见 `theme_legacy_variants.json` |
| `ui_dynamic_theme_audit.py` | Phase 27-7 全 `source/**/*.gd`（排除 addons/.godot）`add_theme_*` 跨行分类、静态角色/解析错误/总计数不增长门禁；`--self-test` 覆盖跨行正负样本；基线见 `ui_dynamic_theme_baseline.json` |
| `font_retirement_manifest.json` | Phase 27-7/P2.1 字体角色、已删除/替换字体、已退役 Theme 资源与私有保留资产边界 |
| `ui_surface_token_audit.py` | 扫描自绘 StyleBox 与 `main_menu` 裸色；基线见 `ui_surface_token_baseline.json`；支持 `--self-test` |
| `runtime_reference_audit.py` | `@onready` NodePath 与 `Global.<method>()` 静态引用 |
| `resource_path_audit.py` | `res://` 路径大小写、动态格式路径与工厂目标 |
| `verify_dragonbones_factories.py` | `.dbfactory` 独立子进程加载与坏资源二分定位 |
| `asset_library_catalog.py` | 从私有素材库生成 ZMWS 资产库存与消费矩阵；`--check` 校验已提交矩阵；策略见 `asset_library_policy.json` |
| `icon_alpha_audit.py` | Report-only 扫描 `source/Art/hero_picture/role_*/equipment.json` 引用图标，报告不透明黑色底板；默认不阻断，`--strict` 可返回非零；公开 clone 缺素材时扫描 0 项并正常退出 |

### 3.3 构建期转换

| 脚本 | 输出/校验 |
|:---|:---|
| `convert_atlas_metadata.py` | manifest → metadata；`--check` / `--self-test` |
| `convert_frame_sequences.py` | FrameSequence/Catalog/延迟纹理清单；`--check` / `--export-preset` |
| `convert_monster_frames.py` | 怪物帧资源与动作别名；`--check` |
| `convert_numbered_frames.py` | 编号 PNG 序列 → SpriteFrames；`--all --check` |
| `convert_sheet_frames.py` | sheet 网格 → SpriteFrames；`--check` |
| `convert_liu_sha_frames.py` | 流沙河动作表 → SpriteFrames；`--check` |
| `convert_monster_action_views.py` | 动作视图与相对 duration；`--check` |
| `convert_nezha_preview_frames.py` | 哪吒预览 JSON → SpriteFrames；`--check` |
| `convert_level_preload_catalog.py` | 关卡刷怪/弹体/动态路径 → Catalog 与发布依赖清单 |
| `convert_level_layout_catalog.py` | 布局源 → 单关布局与 Catalog |
| `level_layout_migration_audit.py` | 阻断布局与脚本数据表双源 |
| `convert_equipment_catalog.py` | 装备构建源 → `EquipmentCatalog` |
| `equipment_data_audit.py` | 装备字段、类型、随机规格审计 |
| `convert_external_monster_catalog.py` | 外部怪物 ID → BHYH 怪物 ID/场景 |
| `convert_ui_theme_tokens.py` | UI token JSON → `UiColorTokens`/`UiSurfaceTokens` 与 Theme 受管属性；`--write` / `--check` |
| `export_raw_manifest.py` | 原始数据根配置 → 精确导出清单；`--write` / `--check`，校验生产脚本字面量与插件配置 |

### 3.4 回归、探针与发布

| 脚本 | 作用 |
|:---|:---|
| `level_test_runner.py` | 单关冒烟夹具；沙盒、阶段断言、物理帧门?、日志门禁与自动清理；`--performance-sample-frames` / `--performance-warmup-frames` / `--performance-hud-full` 为可选 `Performance.TIME_PROCESS` 逐帧采样（mean/p50/p95）；`--performance-retries` 在 `p95>=8ms` 整段节流时重跑；`--render-window` 改用 `--windowed --disable-vsync` 走真实渲染路径采样（含 draw/呈现/同步），报告 `performance.render_window / vsync_mode / max_fps`；`--measure-load` 只测加载链路，输出分阶段耗时与加载期峰值 VRAM/对象数；`--loadout base|full` 控制沙盒装备组合（满配 = 寅虎 4 阶 + 法宝 xianyjp） |
| `level_regression_all.py` | 全量/变更影响关卡回归；失败串行重试并保留首轮失败证据；`--dry-run` 只打印计划 |
| `coop_probe_runner.py` | LocalCoop 探针矩阵 |
| `scene_probe_runner.py` | 场景级运行时探针套件 |
| `archive_probe_runner.py` | 档案持久化定向夹具；隔离临时 `user://` |
| `frame_sequence_pack_probe.py` | 实际导出 PCK 并在最小工程挂载校验路径闭包 |
| `export_closure_probe.py` | 原始数据清单 → 实际 PCK 挂载校验 JSON/BIN；插件日志计数与清单一致 |
| `export_release.py` | 发布前包装：清单预检 + PCK 闭包；可选 release 可执行导出 |
| `asset_reference_audit.py` | 单遍 `rg` 扫描旧资产基名；手动执行 |

### 3.5 迁移与共用模块

| 脚本 | 作用 |
|:---|:---|
| `rename_path.py` | `source/` 内原子重命名、引用同步与失败回滚；文档移动不要使用 |
| `tool_common.py` | runner 共用 `ROOT`/`SOURCE`/`REPORT_DIR`、Godot 解析与 JSON 报告写入 |
| `docs_audit.py` | 文档相对链接、目录索引与脚本索引审计；不进入 `check_all` 维度 |
| `equipment_data_schema.py` | 装备构建源白名单、类型与随机规格校验（供生成器/审计导入） |

### 3.6 素材维护

| 脚本 | 作用 |
|:---|:---|
| `fix_ogg_vorbis_comments.py` | 修复 Ogg Vorbis comment 中缺少 `=` 的条目；等长改写并重算页 CRC，音频包与页布局不变；`--check` 只检查。 |

## 4. 数据文件

| 文件 | 作用 |
|:---|:---|
| `contract_whitelist.json` | 命名/契约/机器导出白名单 |
| `png_stream_allowlist.json` | StreamedPngEffect 允许文件 |
| `runtime_frames_allowlist.json` | 运行时 `SpriteFrames.new()` 允许文件 |
| `global_surface_baseline.json` | Phase 22 收口后的 Global 字段与 add 系入口冻结基线 |
| `theme_override_baseline.json` | Theme 直接属性/动画轨道场景级上限 |
| `font_role_baseline.json` | 字体角色字号存量例外；只允许收紧，不允许新增未登记例外 |
| `ui_theme_tokens.json` | 字号、语义色、字体角色、Theme 受管属性与 Theme token 审计集合的单一来源 |
| `theme_token_baseline.json` | Theme 变体字号/描边/颜色/Button 基类的迁移期冻结基线 |
| `ui_surface_token_baseline.json` | 自绘 StyleBox 与 `main_menu` 裸色的迁移期冻结基线 |
| `monster_action_maps.json` / `monster_action_views.json` | 怪物动作与视图构建源 |
| `level_layout_sources.json` / `level_layout_data_exceptions.json` | 关卡布局构建源与 10 个动态/非连续例外 |
| `equipment_sources.json` | 装备/物品构建源；由 `convert_equipment_catalog.py` 生成 Catalog |
| `monster_dynamic_paths.json` | 关卡预载动态怪物/纹理/额外场景来源 |
| `export_raw_roots.json` | FileAccess JSON/BIN 的根目录、扩展名与消费者；生成 `source/Script/data/export_raw_dependencies.json` |

## 5. 常用命令

```bash
# 静态门禁
python scripts/check_all.py --skip-engine

# 全量门禁
python scripts/check_all.py --godot-bin "<godot>"

# 单关与回归
python scripts/level_test_runner.py --godot "<godot>" --level res://Scene/level/level_1.tscn
python scripts/level_regression_all.py
python scripts/level_regression_all.py --jobs 4 --timeout 90  # 稳定排障口径
python scripts/level_regression_all.py --changed-only --diff-base HEAD

# 运行期探针
python scripts/coop_probe_runner.py --godot "<godot>"
python scripts/scene_probe_runner.py --godot "<godot>"
python scripts/archive_probe_runner.py --godot "<godot>"

# 契约自测与发布闭包
python scripts/contract_scan.py --self-test
python scripts/frame_sequence_pack_probe.py --self-test
python scripts/frame_sequence_pack_probe.py --godot "<godot>"
python scripts/export_raw_manifest.py --check
python scripts/export_closure_probe.py --self-test
python scripts/export_closure_probe.py --godot "<godot>" --preset "Windows Desktop (release)"
```

## 6. 约定

1. **路径基准**：脚本以自身位置推导仓库根；`check_all.py` 启动时切换到仓库根。
2. **默认工程**：`source/`；不存在时返回退出码 2，不静默扫描 0 文件。
3. **报告位置**：机器报告统一写入 `docs/reports/`；不手改、不提交历史报告。
4. **退出码**：`0` 通过；`1` 发现违规/失败；`2` 参数、路径或环境错误；`3` 仅 `asset_reference_audit.py --fail-on-match`。
5. **共享逻辑**：runner 的根路径、Godot 解析与 JSON 报告写入使用 `tool_common.py`；不要复制新副本。
6. **测试夹具**：`coop_probes/`、`scene_probes/`、`archive_probes/` 只用于验证，不进入生产源码。
7. **文档一致性**：`scripts/docs_audit.py` 校验脚本索引/链接；不把它计入 `check_all` 维度。
