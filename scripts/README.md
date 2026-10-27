# 脚本工具链 (Scripts)

本目录是工程级自动化工具链。所有脚本以仓库根为基准解析路径，默认工程目录为 `source/`，默认报告目录为 `docs/reports/`。

---

## 1. 环境要求

| 依赖 | 说明 |
|:---|:---|
| Python | 3.10+（当前验证 3.14） |
| `gdlint` / `gdformat` | gdtoolkit 4.5.0；`check_all.py` 与 `format_all.py` 依赖 |
| Godot 4.7.2 | 引擎编译、关卡回归、双人探针需要；通过 `--godot-bin` / `--godot` 或 `GODOT_BIN` 指定，或放在 `PATH` 中 |
| `rg`（ripgrep） | `asset_reference_audit.py` 使用 |

脚本不内置本地 Godot 绝对路径，也不应把本地二进制、解密沙盒或临时目录写入代码与文档。

---

## 2. 门禁拓扑

```text
check_all.py
├── normalize_eol.py
├── format_all.py
├── gdlint（外部）
├── health_check.py
├── contract_gate.py
│   ├── contract_scan.py
│   ├── convert_atlas_metadata.py --check / --self-test
│   ├── convert_frame_sequences.py --check
│   ├── convert_monster_frames.py --check
│   ├── convert_liu_sha_frames.py --check
│   ├── convert_monster_action_views.py --check
│   ├── convert_level_preload_catalog.py --check
│   ├── png_stream_audit.py
│   ├── runtime_frames_audit.py
│   └── whitelist_audit.py
├── naming_audit.py --all
├── runtime_reference_audit.py
└── resource_path_audit.py

level_regression_all.py
└── level_test_runner.py（每个关卡实例）

coop_probe_runner.py
└── coop_probes/coop_probe_matrix.gd（执行期复制到工程根）

scene_probe_runner.py
└── scene_probes/constellation_probe.tscn/.gd（--scene 启动，执行期复制到工程根）

frame_sequence_pack_probe.py（发布前，独立执行，不在 check_all 中）
└── Godot --export-pack → 最小空工程挂载 PCK → FileAccess 逐条判定
```

说明：

- `check_all.py` 是日常总门禁；它不运行关卡回归、双人探针、星座场景探针或人工迁移工具；
- `contract_gate.py` 的独立子命令并发执行，再按固定顺序汇总输出；
- `level_regression_all.py` 依赖 `level_test_runner.py`；
- `coop_probe_runner.py` 依赖 `coop_probes/` 下的 GDScript 测试规格；
- `scene_probe_runner.py` 依赖 `scene_probes/` 下的场景规格，使用 `--scene` 启动完整项目生命周期。

---

## 3. 脚本矩阵

### 3.1 总门禁

| 脚本 | 作用 | 主要产物 |
|:---|:---|:---|
| `check_all.py` | 八维总门禁；支持 `--skip-engine`、`--skip-contract`、`--skip-naming`、`--skip-runtime`、`--skip-resource`、`--godot-bin`、`--fix`、`--no-cache`、`--jobs` | 终端仪表板 |

### 3.2 自动门禁子脚本

| 脚本 | 作用 | 产物 |
|:---|:---|:---|
| `normalize_eol.py` | 全工程 LF/CRLF 归一化；增量缓存 | `.godot/eol_cache.json` |
| `format_all.py` | `gdformat` 批量校验/格式化；mtime/size 缓存 | `.godot/format_cache.json` |
| `health_check.py` | 场景引用拓扑、Autoload、死代码、Headless 编译、GDScript 静态分析 warning 门禁 | `docs/reports/dead_code_audit.md` |
| `contract_gate.py` | 契约域总门禁：契约扫描、Atlas、FrameSequence 内容/依赖、PNG 流 guard、白名单 | 子脚本报告 |
| `contract_scan.py` | 资源路径、NodePath、反射、动画轨道、字典键、运行时 manifest 六类契约 | `docs/reports/contract_audit.md/.json` |
| `naming_audit.py` | 目录/文件 `snake_case` 门禁；默认检查 Git 新增文件，`--all` 全量 | 终端结果 |
| `naming_compliance_audit.py` | 全工程命名合规终审四张表；**不在 `check_all.py` 中**，用于人工全量复核 | `docs/reports/naming_compliance_audit.md/.json` |
| `whitelist_audit.py` | 白名单冻结、未登记项与失效项校验 | `docs/reports/whitelist_freeze_audit.md/.json` |
| `png_stream_audit.py` | 冻结 allowlist；已迁移消费者旧数组/目录扫描/编号探测回归检查 | 终端结果 |
| `runtime_frames_audit.py` | 运行时 `SpriteFrames.new()` 集合与允许清单守恒；新增/失效/空理由失败 | `scripts/runtime_frames_allowlist.json` |
| `runtime_reference_audit.py` | `@onready` NodePath 与 `Global.<method>()` 静态引用 | 终端 / `--json` |
| `resource_path_audit.py` | 静态 `res://` 路径逐级大小写、动态格式路径、Spine atlas 页名、`add_role_bullet` / `add_role_special_effect` 动态工厂目标 | 终端 / `--json` |
| `convert_atlas_metadata.py` | `manifest.json` → `metadata.tres` 构建期转换与校验 | 同目录 `metadata.tres` |
| `convert_monster_action_views.py` | 既有 `play` 帧资源或连续 PNG → 动作视图（帧子集 + 逐帧 duration + loop/speed），按 `scripts/monster_action_views.json` 登记；`--check` 逐字比较 | `monster_130/212/215/*_action_frames.tres`、宠物寅虎 stage 资源（私有素材） |
| `convert_liu_sha_frames.py` | 流沙河 Boss/分身 `ACTIONS` 动作表 → 按 boss_kind 拆分的构建期 SpriteFrames（逐帧 duration、确定性 UID）；`--check` 逐字比较 | `source/Art/monster/liu_sha_river/**/liu_sha_*_frames.tres`（私有素材） |
| `convert_monster_frames.py` | 怪物 `AtlasMetadata.sequences` → 既有 `*_frames.tres`；按 `monster_action_maps.json` 追加动作别名（复用 `AtlasTexture` 子资源）并修正 loop；`--check` 校验动画名集合、帧数、页闭包、region/margin、确定性 UID 与全局 UID 冲突；`--all` 只补缺失/语义不一致/别名/loop/speed；支持旧 `animations` schema、null 计时帧与 `TARGET_OVERRIDES` 目标推导；`--rewrite` 只补 UID 头；`--emit` 输出规范格式到指定目录 | 既有 `source/Art/monster/**/*_frames.tres`（私有素材） |
| `convert_level_preload_catalog.py` | 关卡脚本刷怪表 / 出生点 / 怪物弹体名 + `monster_dynamic_paths.json` → `LevelPreloadCatalog.tres` 与 `level_preload_export_dependencies.json`；`--check` 同时校验两份输出并进入总门禁 | `source/Script/data/level_preload_catalog.tres`、`source/Art/frame_sequences/level_preload_export_dependencies.json`（私有素材构建产物） |

### 3.3 人工审计与迁移工具

| 脚本 | 作用 | 状态 |
|:---|:---|:---|
| `asset_reference_audit.py` | 单遍 `rg` 扫描旧资产基名引用 | **手动**；不在自动门禁中 |
| `classify_texture_aliases.py` | 只读分类 6.8 纹理别名：键/目标存在性、代码与资源文本引用、通用基名复核；`--check` 校验每条目标存在并进入契约门禁；分类报告不删除条目 | `--check` 自动门禁；完整报告产物 `docs/reports/texture_alias_classification.*` |

### 3.4 回归与测试

| 脚本 | 作用 | 产物 |
|:---|:---|:---|
| `level_regression_all.py` | 全量/变更影响关卡冒烟回归；`--dry-run` 仅打印计划 | `docs/reports/level_regression_*.{md,json}` |
| `level_test_runner.py` | 单关命令行冒烟夹具；沙盒、倍速、阶段断言、日志 0/0 门禁、自动清理 | 临时 `source/level_smoke_report_*.json` 与日志，运行后删除 |
| `coop_probe_runner.py` | LocalCoop 探针矩阵（用例清单由脚本维护） | `docs/reports/coop_probe_matrix_report.*` |
| `scene_probe_runner.py` | 场景探针套件：星座视觉后端/预热/请求回收，以及八仙与三太子选择态与自预载边界；发布前 L2 固定项之一 | `docs/reports/constellation_probe_report.*`、`docs/reports/level_selection_probe_report.*` |
| `convert_nezha_preview_frames.py` | 哪吒专用适配器：将 `official_parts_trial` 预览 JSON 转为构建期 SpriteFrames `.tres`；`--check` 校验输出存在且内容一致 | `source/Art/hero_picture/role_6/equipment_atlas/`（私有素材） |
| `convert_numbered_frames.py` | 通用连续编号 PNG 序列 → 构建期 SpriteFrames `.tres`；`--all` 生成 BiLuoTian/LeiTingJieZhen/Wutai 3077 tornado、212/215/130 编号帧弹体（10 个）、东胜神洲 loose 特效（6 个）、两个法宝（di_kong/zhen_lei 共 7 个）、宠物弹体（mouse/rabbit/turtle/yin_tiger 共 19 个）、闪电特效与关卡 46 背景（9 个），`--check` 校验存在且未过期 | 角色 4/5、3077 与弹体 `Art/.../*_frames.tres`（私有素材） |
| `convert_frame_sequences.py` | 固定/图集帧 → FrameSequence、Catalog、稳定 UID 与延迟纹理依赖 JSON；`asset_id` 为内容身份、`default_*` 为默认策略，输出按 `asset_id` 生成可读文件名并在生成时清理自己拥有的陈旧输出；`--check` 进契约门禁；`--export-preset [NAME]` 只读检查预设声明覆盖 | `source/Art/frame_sequences/`（私有素材） |
| `frame_sequence_pack_probe.py` | 发布包闭包探针：合并 `frame_sequence_export_dependencies.json` 与 `level_preload_export_dependencies.json`，实际 `--export-pack` 生成 PCK，在最小空工程中挂载并逐条验证 Catalog/序列/延迟纹理/怪物场景/弹体/动态纹理可达（含 `.remap`）；`--self-test` 只验证清单结构；`--manifest` 可覆盖清单 | 可选 `--report` JSON；缺模板、无 PCK 或无结果返回 2（BLOCKED），不记为通过 |
| `coop_probes/coop_probe_matrix.gd` | 探针矩阵 GDScript 测试规格 | 仅执行期复制到工程根，结束后清理 |

### 3.5 数据文件

| 文件 | 作用 |
|:---|:---|
| `contract_whitelist.json` | 命名/契约/机器导出白名单冻结清单；多个命名与契约脚本共用 |
| `png_stream_allowlist.json` | 允许使用 `StreamedPngEffect` 的文件清单 |
| `monster_action_maps.json` | 怪物构建期帧的动作映射：`metadata 相对路径 → {actions: action→sequence, loop: 动作循环声明}`；与脚本 `ACTIONS`/`MODEL_ACTIONS`/`DATA.animations` 对应 |
| `monster_action_views.json` | 怪物动作视图登记：输出路径 → `{action: {source, frames, durations?, loop, speed}}` |
| `monster_dynamic_paths.json` | 关卡预载的动态来源：`aliases`（怪物 ID → 场景 ID）、`textures`（动态纹理/目录）、`scenes`（额外弹体场景）；构建期展开进 Catalog 与发布依赖清单，运行时不再读取 |
| `runtime_frames_allowlist.json` | 允许运行时调用 `SpriteFrames.new()` 的文件与理由；由 `runtime_frames_audit.py` 守恒 |

---

## 4. `coop_probes/` 与 `scene_probes/` 说明

`coop_probes/` 不是生产业务代码，而是双人模式的可执行测试规格。

`coop_probe_matrix.gd`：

- 继承 `SceneTree`，通过 `--case` 运行单个探针；
- 覆盖核心状态、玩法、技能切换、怪物数值、面板、性能、宠物、共享魂、按键、被动、剑/坐骑与创建 UI；
- `coop_probe_runner.py` 将其复制到 `source/_coop_probe_matrix.gd`，逐个启动 Godot，收集结果后清理。

该目录只服务于回归测试，不应移入 `source/`，也不应加入日常生产构建。

`scene_probes/` 存放场景级运行时探针（`constellation_probe`、`level_selection_probe`）。`scene_probe_runner.py` 按 `PROBES` 清单把 `.gd` 与 `.tscn` 复制到工程根目录，用 `--scene` 启动；不使用 `--script`，因为自定义 `SceneTree` 会在 Autoload 全局标识注册前编译入口依赖，无法可靠验证生产启动顺序。执行后自动清理临时文件；`--probe` 可只运行其中一项。

---

## 5. 常用命令

```bash
# 静态门禁（无 Godot）
python scripts/check_all.py --skip-engine

# 全量门禁（Godot 通过参数或 GODOT_BIN 指定）
python scripts/check_all.py --godot-bin "<godot>"

# 格式化
python scripts/format_all.py source --check
python scripts/format_all.py source

# 全量命名复核
python scripts/naming_audit.py --root source --all
python scripts/naming_compliance_audit.py --fail-on-error

# 资源路径大小写与动态工厂复核
python scripts/resource_path_audit.py --project source

# 单关冒烟
python scripts/level_test_runner.py --godot "<godot>" --level res://Scene/level/level_1.tscn

# 关卡回归（默认 auto：min(12, max(4, CPU 核数))；--jobs 4 为稳定排障口径）
python scripts/level_regression_all.py
python scripts/level_regression_all.py --jobs 4 --timeout 90
python scripts/level_regression_all.py --changed-only --diff-base HEAD

# 双人探针
python scripts/coop_probe_runner.py --godot "<godot>"

# 场景探针套件（星座 + 关卡选择态）
python scripts/scene_probe_runner.py --godot "<godot>"

# FrameSequence 发布包闭包（需导出模板）
python scripts/frame_sequence_pack_probe.py --self-test
python scripts/frame_sequence_pack_probe.py --godot "<godot>"
```

---

## 6. 性能与缓存

- `check_all.py` 使用线程池并发执行各维度；
- `normalize_eol.py` 与 `format_all.py` 使用 `.godot/` 下的增量缓存；
- `contract_gate.py` 的内部子命令已并发执行；
- `health_check.py` 与关卡回归的主要成本是 Godot 启动与场景加载，优先保证稳定性；
- 全量静态门禁当前约数秒级；不要为了微秒级收益增加重复扫描或复杂缓存。

---

## 7. 约定

1. **路径基准**：脚本以自身位置推导仓库根；`check_all.py` 启动时切换到仓库根。
2. **默认工程**：`source/`；不存在时立即返回退出码 2，不静默扫描 0 文件。
3. **报告位置**：机器报告统一写入 `docs/reports/`；历史报告与迁移台账不进入仓库。
4. **退出码**：`0` 通过；`1` 发现违规/失败；`2` 参数或路径错误；`3` 仅 `asset_reference_audit.py --fail-on-match`。
5. **报告不手改**：报告由脚本覆盖；结论性内容写入 `docs/reference/status.md`。
6. **迁移工具边界**：版本专用的解密、重建、场景恢复工具不进入日常工具链；仅保留当前构建期需要的 `convert_atlas_metadata.py`。
7. **测试夹具边界**：`coop_probes/` 与关卡夹具只用于验证，不进入生产源码。
