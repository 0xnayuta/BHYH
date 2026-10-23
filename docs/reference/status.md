# 当前工程状态 (Status)

> 本文是工程版本、目录结构、规模与验证状态的单一事实源。
>
> 最后更新：2026-10-23（Phase 12-1 显示基线完成后）

---

## 1. 版本与引擎

| 项目 | 值 |
|:---|:---|
| 工程标识 | **造梦西游八荒湮隳（BHYH）** |
| 当前内容版本 | **6.9**（6.5.0.0 基线 + 6.6 / 6.7 / 6.8 / 6.9 回植） |
| `project.godot` 版本字段 | 未声明 `config/version` |
| 引擎 | Godot **4.7.2**（Forward Mobile / gl_compatibility） |
| 设计画布 / 默认窗口 | **1280×800 / 1600×1000**（16:10，1.25×；`canvas_items` + `expand`） |
| 主场景 | `res://Scene/other_scene/load_scene.tscn` |
| 工程根 | `source/`（可直接用 Godot 打开 `source/project.godot`） |

版本谱系：

| 版本 | 内容 |
|:---|:---|
| 6.5.0.0 | 反编译基线 + 现代化治理（命名、契约、资产、门禁） |
| 6.6 | 玉兔角色、青龙剑重制、太极八卦、哪吒官方部件与音效、雷辇嘲风飞行 |
| 6.7 | 玉兔数值/卡顿修复、月影追魂、四项觉醒、缓存与战斗预热优化 |
| 6.8 | 双人模式、Boss/人物白条上限、7.5 秒霸体、连击显示、卡顿修复 |
| 6.9 | 双人宝箱/丹药/法宝/忘川河/宠物/炼体/万灵修复、自动战斗双人、八仙尽伏每轮领取、哪吒/玉兔掉落统一 |

后续版本迁移的方法与红线见 [`../guides/migration_playbook.md`](../guides/migration_playbook.md)。

---

## 2. 目录结构

```text
source/                     # 唯一活跃 Godot 工程
├── Scene/                  # 场景（.tscn）
├── Script/                 # GDScript 业务逻辑（.gd）
├── Art/                    # PNG、图集、Spine、特效资源
├── Music/                  # MP3 / WAV
├── Font/                   # TTF / TTC
├── Shader/                 # .gdshader
├── Spritesheet/            # 精灵表
├── addons/                 # godot_mcp 等第三方插件（非维护任务不改）
├── bin/                    # Spine GDExtension（Windows x86_64）
└── project.godot           # 工程配置（13 个 Autoload）

docs/                       # 文档（见 docs/README.md）
scripts/                    # 门禁、审计、回归与构建工具（见 scripts/README.md）
```

---

## 3. 规模（2026-10-23 实测）

| 指标 | 数量 |
|:---|:---:|
| GDScript | **741**（业务 705：`Script/` 642 + 顶层 7 + 场景内嵌 56；插件 36） |
| 场景 `.tscn` | **1,137**（`Scene/` 1,136 + 插件 1） |
| 资源 `.tres` | **979**（主要为 `Art/**/*.sprites` 图集资源） |
| PNG | **16,709**（另有 21 个大写 `.PNG`，合计 16,730） |
| `.import` | **17,003** |
| `.uid` | **751** |
| MP3 / WAV | **170 + 8**（大写 `.MP3`）/ **1** |
| 字体 | **13 TTF + 2 TTC** |
| Shader | **8** |
| Autoload | **13** |
| 仓库体积 | 约 **3.1 GB**（`Art/` 约 3.0 GB） |

---

## 4. 质量门禁

| 命令 | 作用 |
|:---|:---|
| `python scripts/check_all.py` | 七维总门禁（行尾、格式、lint、引擎编译、契约、命名、运行时引用） |
| `python scripts/check_all.py --skip-engine` | 无 Godot 环境时的静态门禁 |
| `python scripts/health_check.py --project source --godot-bin <path>` | 场景引用拓扑、死代码与 Headless 编译 |
| `python scripts/level_regression_all.py --jobs 4 --timeout 90` | 全量关卡冒烟回归；8 并发仅用于快速回归 |
| `python scripts/level_test_runner.py --godot <path> --level res://Scene/level/level_1.tscn` | 单关冒烟夹具 |
| `python scripts/coop_probe_runner.py --godot <path>` | 双人模式 15 探针矩阵 |
| `python scripts/convert_atlas_metadata.py --check` | Atlas manifest 与 `metadata.tres` 同步校验 |

Godot 可执行文件通过 `--godot-bin` / `--godot` 或 `GODOT_BIN` 环境变量指定，不写入仓库。

报告由脚本按需生成到 `docs/reports/`，不提交历史报告；说明见 [`../reports/README.md`](../reports/README.md)。

---

## 5. 验证状态

| 验证 | 结果 | 说明 |
|:---|:---|:---|
| 结构整理后静态门禁 | **7/7 PASS** | `scripts/check_all.py --skip-engine` |
| Atlas 元数据 | **379/379 同步** | `scripts/convert_atlas_metadata.py --check` |
| 6.9 完整工作区验收基线 | 七维门禁 7/7；关卡回归 **128/128 PASS + 5 SKIP**；双人矩阵 **15/15 PASS**；Atlas **379/379** | 本地完整素材工作区；6.9 定向探针 0 failures |
| Phase 12-1 显示基线 | 七维门禁 **7/7 PASS**；关卡回归 **128/128 PASS + 5 SKIP**；705 脚本 0 Error / 0 Warning | 1280×800 画布、1600×1000 窗口、相机缩放 1.3559；16:10 截图无底部灰带 |
| 引擎健康检查基线 | 705 脚本 0 Parse / 0 Error / 0 Warning；1,136 场景 0 断裂引用 | 本地完整素材工作区 |
| 双人探针基线 | 15 PASS / 0 SKIP / 0 FAIL | `scripts/coop_probe_runner.py` |

> 公开 clone 缺少第三方素材，不能直接复现完整验收；缺失资源提示属于预期。

---

## 6. 已知边界

1. 当前仓库已建立本地 Git 提交历史；尚未推送远端，工作区由本地完整备份保障。
2. `scripts/convert_atlas_metadata.py` 是当前构建期转换器，由 `scripts/contract_gate.py` 调用。
3. 版本专用的解密、重建、场景恢复工具不进入当前仓库；后续迁移前必须重新验证目标二进制格式。
4. 13 个 Autoload、`global.gd` 大体量全局状态、字典/JSON 数据与类型分层目录按遗留结构保留；新增代码不得继续扩张。
5. 8 并发全量回归存在偶发的 Godot 启动瞬态；稳定复跑建议 `--jobs 4`。
6. 按项目原则不做向前兼容：旧 `user://` 存档目录、旧任务键与旧配置均不迁移；存档密钥前缀已修正为 `zmxybhyh`。
