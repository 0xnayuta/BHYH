# 造梦西游八荒湮隳（BHYH）

《造梦西游八荒湮隳》的 Godot 4 现代化重构工程。仓库采用 **单一活跃工程 + 文档 + 工具链** 结构；版本与阶段状态以 [`docs/reference/status.md`](docs/reference/status.md) 与 [`docs/roadmap/roadmap.md`](docs/roadmap/roadmap.md) 为准。

> **公开仓库范围**：本仓库为代码、场景与工具链快照，不包含第三方美术、音乐、字体与控制器图标。`source/Art/`、`source/Music/`、`source/Font/`、`source/Spritesheet/` 及其 `.import` 已由 `.gitignore` 排除。公开 clone 无法直接运行，Godot 会报告缺失资源；请勿使用 `git add -f` 绕过忽略规则。本地运行请自行准备合法授权素材。

## 1. 当前状态

| 项目 | 值 |
|:---|:---|
| 当前版本 | 以 [`docs/reference/status.md`](docs/reference/status.md) 为准 |
| 引擎 | Godot 4.x；确切版本与渲染后端以 `source/project.godot` 为准 |
| 工程根 | `source/` |
| 语言与架构 | GDScript 2.0、场景/Resource 分层、构建期资源管线 |
| 规模 | 以 [`docs/reference/status.md`](docs/reference/status.md) 为单一事实源 |
| Autoload | 注册项以 `source/project.godot` 为准；新增需评审 |
| 素材边界 | 公开仓库不含第三方素材；完整验收使用本地合法素材工作区 |

当前阶段与验证状态见 [`docs/reference/status.md`](docs/reference/status.md)；长期路线见 [`docs/roadmap/roadmap.md`](docs/roadmap/roadmap.md)。

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
├── scripts/                # 质量门禁、审计、回归与构建工具（见 scripts/README.md）
└── .omp/skills/            # 项目本地 agent skills
```

文档只保留当前规范与未来路线；已完成阶段的原始记录进入 [`docs/archive/`](docs/archive/README.md)。

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

## 4. 质量流水线

```bash
# 静态门禁（无 Godot）
python scripts/check_all.py --skip-engine

# 全量门禁（Godot 通过参数或 GODOT_BIN 指定）
python scripts/check_all.py --godot-bin "<Godot 4.7.2 可执行文件>"
```

常用单维命令、退出码与报告位置见 [`scripts/README.md`](scripts/README.md)；验收分层与阈值见 [`docs/reference/acceptance.md`](docs/reference/acceptance.md)。

## 5. 文档入口

| 入口 | 内容 |
|:---|:---|
| [`docs/README.md`](docs/README.md) | 文档分层与子目录索引 |
| [`docs/reference/architecture.md`](docs/reference/architecture.md) | 当前运行时架构与遗留边界 |
| [`docs/reference/status.md`](docs/reference/status.md) | 当前状态、门禁与已知边界 |
| [`docs/reference/acceptance.md`](docs/reference/acceptance.md) | 验收分层、命令与变更矩阵 |
| [`docs/standards/README.md`](docs/standards/README.md) | 活跃规范索引，含 UI 字体角色与 Theme 使用边界 |
| [`docs/roadmap/roadmap.md`](docs/roadmap/roadmap.md) | 长期阶段顺序与近期重点 |
| [`docs/decisions/README.md`](docs/decisions/README.md) | ADR 索引 |
| [`docs/archive/README.md`](docs/archive/README.md) | 已完成阶段归档入口 |

## 6. 工程原则

1. **零错误零警告**：编辑器加载与实机运行日志保持 0 ERROR / 0 WARNING。
2. **单一活跃工程**：业务改动仅进入 `source/`；`addons/` 仅在插件维护任务中修改。
3. **资产规范**：外部源素材维护 `.import`；原生 `.tscn/.tres` 使用资源头 UID，脚本按机制维护 `.uid`；命名遵守 `docs/standards/`。
4. **路径迁移唯一入口**：`source/` 内的文件/目录重命名必须使用 `scripts/rename_path.py`。
5. **门禁先行**：提交前至少通过静态门禁；涉及运行时改动必须执行 Godot 健康检查或关卡冒烟。
6. **总体架构**：Godot 原生场景组合、显式依赖与单一状态写入者；不以全仓搬迁、单例数量或文件行数作为完成标准。

## 7. 许可证

- 项目代码：MIT，见 [`LICENSE`](LICENSE)。
- `source/addons/godot_mcp/`：上游 MIT，见 [`source/addons/godot_mcp/LICENSE`](source/addons/godot_mcp/LICENSE)。
- `source/bin/` Spine 运行时：Spine Runtimes License，见 [`source/bin/SPINE_RUNTIMES_LICENSE.txt`](source/bin/SPINE_RUNTIMES_LICENSE.txt)。
- 公开仓库不包含 `source/Art/`、`source/Music/`、`source/Font/`、`source/Spritesheet/`，这些素材不在 MIT 覆盖范围内。
- 第三方组件总览见 [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md)。
