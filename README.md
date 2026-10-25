# 造梦西游八荒湮隳（BHYH）

《造梦西游八荒湮隳》的 Godot 4 现代化重构工程。仓库采用 **单一活跃工程 + 文档 + 工具链** 结构，当前内容版本为 **6.9**。

> **公开仓库范围**：本仓库为代码、场景与工具链快照，不包含第三方美术、音乐、字体与控制器图标。`source/Art/`、`source/Music/`、`source/Font/`、`source/Spritesheet/` 及其 `.import` 已由 `.gitignore` 排除。公开 clone 无法直接运行，Godot 会报告缺失资源；请勿使用 `git add -f` 绕过忽略规则。本地运行请自行准备合法授权素材并放入这些目录。

---

## 1. 当前状态

| 项目 | 值 |
|:---|:---|
| 当前版本 | **6.9**（6.5.0.0 基线 + 6.6 / 6.7 / 6.8 / 6.9 回植） |
| 引擎 | Godot **4.7.2**（默认 `mobile`；Web 使用 `forward_plus`） |
| 工程根 | `source/` |
| 语言与架构 | GDScript 2.0、场景/Resource 分层、构建期资源管线 |
| 规模 | 以 [`docs/reference/status.md`](docs/reference/status.md) 为单一事实源 |
| Autoload | 13 个注册项（12 个业务单例 + 1 个编辑器调试桥；新增需评审） |
| 素材边界 | 公开仓库不含第三方素材；完整验收使用本地合法素材工作区 |

完整版本谱系、目录职责与验证状态见 [`docs/reference/status.md`](docs/reference/status.md)。

---

## 2. 目录结构

```text
.
├── source/                 # 唯一活跃 Godot 工程
│   ├── Scene/              # 场景（.tscn）
│   ├── Script/             # GDScript 业务逻辑
│   ├── Art/                # 贴图、图集、Spine、特效
│   ├── Music/              # MP3 / WAV
│   ├── Font/               # TTF / TTC
│   ├── Shader/             # .gdshader
│   ├── Spritesheet/        # 精灵表
│   ├── addons/             # godot_mcp 等插件（非维护任务不改）
│   ├── bin/                # Spine GDExtension
│   └── project.godot       # Godot 工程配置
├── docs/                   # 分层文档（见 docs/README.md）
├── scripts/                # 质量门禁、审计、回归与迁移工具（见 scripts/README.md）
├── .omp/skills/            # 项目本地 agent skills（仅技能目录入库）
├── .editorconfig           # UTF-8 / Tab / LF
├── .gdlintrc               # gdlint 规则
├── .gitattributes          # LF 归一化与二进制保护
└── .gitignore              # 缓存、导出产物与临时夹具
```

文档只保留当前规范与未来路线；原始迁移资料不进入仓库，可复用的迁移方法见 [`docs/guides/migration_playbook.md`](docs/guides/migration_playbook.md)。

---

## 3. 快速开始

```bash
# 1. 用 Godot 4.7.2 打开工程
#    项目文件: source/project.godot

# 2. 首次运行或资源变更后重建导入缓存
godot --headless --path source --import

# 3. 运行游戏（编辑器或命令行）
godot --path source
```

工程要求：Godot 4.7.2、Windows x86_64（Spine GDExtension 当前仅入库 Windows 构建）。

---

## 4. 质量流水线

### 4.1 静态门禁（无需 Godot）

```bash
python scripts/check_all.py --skip-engine
```

覆盖：LF 行尾、`gdformat`、`gdlint`、字面量契约、命名门禁、NodePath/Global 运行时引用、资源路径大小写与动态路径工厂。

### 4.2 全量门禁（需要 Godot）

```bash
python scripts/check_all.py --godot-bin "<Godot 4.7.2 可执行文件>"
```

### 4.3 常用单维命令

```bash
python scripts/format_all.py source --check
python scripts/normalize_eol.py source --dry-run
python scripts/health_check.py --project source --godot-bin "<godot>"
python scripts/contract_scan.py --project-dir source --fail-on-error
python scripts/naming_audit.py --root source --all
python scripts/resource_path_audit.py --project source
python scripts/level_regression_all.py --jobs 4 --timeout 90
python scripts/level_test_runner.py --godot "<godot>" --level res://Scene/level/level_1.tscn
python scripts/coop_probe_runner.py --godot "<godot>"
```

脚本职责、退出码与报告位置见 [`scripts/README.md`](scripts/README.md)。

---

## 5. 文档

| 入口 | 内容 |
|:---|:---|
| [`docs/README.md`](docs/README.md) | 文档分层与完整索引 |
| [`docs/reference/architecture.md`](docs/reference/architecture.md) | 运行时架构：Autoload、场景流、对象模型、数据/资源分层与遗留边界 |
| [`docs/reference/acceptance.md`](docs/reference/acceptance.md) | 验收标准：八维门禁、契约域、引擎健康、运行期夹具与阈值 |
| [`docs/reference/status.md`](docs/reference/status.md) | 当前版本、规模、门禁与验证状态 |
| [`docs/decisions/README.md`](docs/decisions/README.md) | 架构决策记录（ADR）索引 |
| [`docs/audit/README.md`](docs/audit/README.md) | 审计档案索引与只读模板入口 |
| [`docs/audit/AUDIT-000-audit-template.md`](docs/audit/AUDIT-000-audit-template.md) | 代码质量审计模板（10 个领域、12 个问题前缀） |
| [`docs/roadmap/roadmap.md`](docs/roadmap/roadmap.md) | 当前版本之后的开发路线 |
| [`docs/guides/migration_playbook.md`](docs/guides/migration_playbook.md) | 版本迁移方法、阶段与红线 |
| [`docs/standards/README.md`](docs/standards/README.md) | 规范目录索引与修订流程 |
| [`docs/standards/naming_standard.md`](docs/standards/naming_standard.md) | 命名规范与契约白皮书 |
| [`docs/standards/godot_design_standard.md`](docs/standards/godot_design_standard.md) | Godot 现代项目设计规范（场景、Resource、Autoload、结构） |
| [`docs/standards/naming_whitelist.md`](docs/standards/naming_whitelist.md) | 命名白名单与冻结登记 |
| [`docs/reports/README.md`](docs/reports/README.md) | 机器报告目录（按需生成） |
| [`docs/archive/README.md`](docs/archive/README.md) | 长期参考文档归档规则与索引 |

---

## 6. 工程原则

1. **零错误零警告**：编辑器加载与实机运行日志必须保持 0 ERROR / 0 WARNING。
2. **单一活跃工程**：所有业务改动仅进入 `source/`；`addons/` 仅在插件维护任务中修改。
3. **资产规范**：新增资源必须带 `.import`、全局唯一 UID，并符合 `docs/standards/` 的命名规则。
4. **路径迁移唯一入口**：`source/` 内的文件/目录重命名必须使用 `scripts/rename_path.py`。
5. **门禁先行**：提交前至少通过静态门禁；涉及运行时改动必须执行 Godot 健康检查或关卡冒烟。

---

## 7. 许可证

- 项目代码：MIT，见 [`LICENSE`](LICENSE)。
- `source/addons/godot_mcp/`：上游 MIT，见 [`source/addons/godot_mcp/LICENSE`](source/addons/godot_mcp/LICENSE)。
- `source/bin/` Spine 运行时：Spine Runtimes License，见 [`source/bin/SPINE_RUNTIMES_LICENSE.txt`](source/bin/SPINE_RUNTIMES_LICENSE.txt)。
- 公开仓库不包含 `source/Art/`、`source/Music/`、`source/Font/`、`source/Spritesheet/`，这些素材不在 MIT 覆盖范围内。
- 第三方组件总览见 [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md)。
