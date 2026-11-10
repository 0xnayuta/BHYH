# 造梦西游八荒湮隳（BHYH）

《造梦西游八荒湮隳》的 Godot 现代化重构工程。仓库采用 **单一活跃工程 + 文档 + 工具链** 结构。

> **公开仓库范围**：本仓库为代码、场景与工具链快照，不包含第三方美术、音乐、字体与控制器图标。`source/Art/`、`source/Music/`、`source/Font/`、`source/Spritesheet/` 及其 `.import` 已由 `.gitignore` 排除。公开 clone 无法直接运行，Godot 会报告缺失资源；请勿使用 `git add -f` 绕过忽略规则。本地运行请自行准备合法授权素材。

## 1. 项目状态

当前版本、验证快照与未验证边界见 [`docs/reference/status.md`](docs/reference/status.md)；阶段状态和未完成范围见 [`docs/roadmap/roadmap.md`](docs/roadmap/roadmap.md)。

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

文档分层与导航边界见 [`docs/README.md`](docs/README.md)。

## 3. 快速开始

```bash
# 1. 用与工程基线一致的 Godot 打开工程
#    项目文件: source/project.godot

# 2. 首次运行或资源变更后重建导入缓存
godot --headless --path source --import

# 3. 运行游戏（编辑器或命令行）
godot --path source
```

## 4. 质量流水线

```bash
# 静态门禁（无 Godot）
python scripts/check_all.py --skip-engine

# 全量门禁（Godot 通过参数或 GODOT_BIN 指定）
python scripts/check_all.py --godot-bin "<Godot executable>"
```

常用单维命令、退出码与报告位置见 [`scripts/README.md`](scripts/README.md)；验收分层与阈值见 [`docs/reference/acceptance.md`](docs/reference/acceptance.md)。

## 5. 许可证

- 项目代码：MIT，见 [`LICENSE`](LICENSE)。
- `source/addons/godot_mcp/`：上游 MIT，见 [`source/addons/godot_mcp/LICENSE`](source/addons/godot_mcp/LICENSE)。
- `source/bin/` Spine 运行时：Spine Runtimes License，见 [`source/bin/SPINE_RUNTIMES_LICENSE.txt`](source/bin/SPINE_RUNTIMES_LICENSE.txt)。
- 公开仓库不包含 `source/Art/`、`source/Music/`、`source/Font/`、`source/Spritesheet/`，这些素材不在 MIT 覆盖范围内。
- 第三方组件总览见 [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md)。
