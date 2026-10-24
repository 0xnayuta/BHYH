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
│   ├── png_stream_audit.py
│   └── whitelist_audit.py
├── naming_audit.py --all
├── runtime_reference_audit.py
└── resource_path_audit.py

level_regression_all.py
└── level_test_runner.py（每个关卡实例）

coop_probe_runner.py
└── coop_probes/coop_probe_matrix.gd（执行期复制到工程根）
```

说明：

- `check_all.py` 是日常总门禁；它不运行关卡回归、双人探针或人工迁移工具；
- `contract_gate.py` 的独立子命令并发执行，再按固定顺序汇总输出；
- `level_regression_all.py` 依赖 `level_test_runner.py`；
- `coop_probe_runner.py` 依赖 `coop_probes/` 下的 GDScript 测试规格。

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
| `health_check.py` | 场景引用拓扑、Autoload、死代码、Headless 编译 | `docs/reports/dead_code_audit.md` |
| `contract_gate.py` | 契约域总门禁：契约扫描、Atlas 元数据、PNG 流、白名单 | 子脚本报告 |
| `contract_scan.py` | 资源路径、NodePath、反射、动画轨道、字典键、运行时 manifest 六类契约 | `docs/reports/contract_audit.md/.json` |
| `naming_audit.py` | 目录/文件 `snake_case` 门禁；默认检查 Git 新增文件，`--all` 全量 | 终端结果 |
| `naming_compliance_audit.py` | 全工程命名合规终审四张表；**不在 `check_all.py` 中**，用于人工全量复核 | `docs/reports/naming_compliance_audit.md/.json` |
| `whitelist_audit.py` | 白名单冻结、未登记项与失效项校验 | `docs/reports/whitelist_freeze_audit.md/.json` |
| `png_stream_audit.py` | 非 atlas 运行时 PNG 流 allowlist | 终端结果 |
| `runtime_reference_audit.py` | `@onready` NodePath 与 `Global.<method>()` 静态引用 | 终端 / `--json` |
| `resource_path_audit.py` | 静态 `res://` 路径逐级大小写、动态格式路径、Spine atlas 页名、`add_role_bullet` / `add_role_special_effect` 动态工厂目标 | 终端 / `--json` |
| `convert_atlas_metadata.py` | `manifest.json` → `metadata.tres` 构建期转换与校验 | 同目录 `metadata.tres` |

### 3.3 人工审计与迁移工具

| 脚本 | 作用 | 状态 |
|:---|:---|:---|
| `asset_reference_audit.py` | 单遍 `rg` 扫描旧资产基名引用 | **手动**；不在自动门禁中 |
| `rename_path.py` | `source/` 内原子重命名、引用同步、门禁联动与回滚 | 手动路径迁移唯一入口 |

### 3.4 回归与测试

| 脚本 | 作用 | 产物 |
|:---|:---|:---|
| `level_regression_all.py` | 全量/变更影响关卡冒烟回归；`--dry-run` 仅打印计划 | `docs/reports/level_regression_*.{md,json}` |
| `level_test_runner.py` | 单关命令行冒烟夹具；沙盒、倍速、阶段断言、日志 0/0 门禁、自动清理 | `docs/reports`（可选）/ 临时文件 |
| `coop_probe_runner.py` | LocalCoop 15 探针矩阵 | `docs/reports/coop_probe_matrix_report.*` |
| `coop_probes/coop_probe_matrix.gd` | 探针矩阵 GDScript 测试规格 | 仅执行期复制到工程根，结束后清理 |

### 3.5 数据文件

| 文件 | 作用 |
|:---|:---|
| `contract_whitelist.json` | 命名/契约/机器导出白名单冻结清单；多个命名与契约脚本共用 |
| `png_stream_allowlist.json` | 允许使用 `StreamedPngEffect` 的文件清单 |

---

## 4. `coop_probes/` 说明

`coop_probes/` 不是生产业务代码，而是双人模式的可执行测试规格。

`coop_probe_matrix.gd`：

- 继承 `SceneTree`，通过 `--case` 运行单个探针；
- 覆盖核心状态、玩法、技能切换、怪物数值、面板、性能、宠物、共享魂、按键、被动、剑/坐骑与创建 UI；
- `coop_probe_runner.py` 将其复制到 `source/_coop_probe_matrix.gd`，逐个启动 Godot，收集结果后清理。

该目录只服务于回归测试，不应移入 `source/`，也不应加入日常生产构建。

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

# 关卡回归（默认 4 并发；8 并发仅用于快速回归）
python scripts/level_regression_all.py --jobs 4 --timeout 90
python scripts/level_regression_all.py --changed-only --diff-base HEAD

# 双人探针
python scripts/coop_probe_runner.py --godot "<godot>"
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
