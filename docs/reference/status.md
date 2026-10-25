# 当前工程状态 (Status)

> 本文是工程版本、目录结构、规模与验证状态的单一事实源。
>
> 最后更新：2026-10-25（bhyh-doc-sync 文档对齐与静态门禁复验）

---

## 1. 版本与引擎

| 项目 | 值 |
|:---|:---|
| 工程标识 | **造梦西游八荒湮隳（BHYH）** |
| 当前内容版本 | **6.9**（6.5.0.0 基线 + 6.6 / 6.7 / 6.8 / 6.9 回植） |
| `project.godot` 版本字段 | 未声明 `config/version` |
| 引擎 | Godot **4.7.2**（默认 `mobile`；Web 使用 `forward_plus`） |
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

## 3. 规模（2026-10-25 实测）

| 指标 | 数量 |
|:---|:---:|
| GDScript | **742**（业务 706：`Script/` 643 + 顶层 7 + `Scene/` 55 + `Art/` 1；插件 36） |
| 场景 `.tscn` | **1,137**（`Scene/` 1,136 + 插件 1） |
| 资源 `.tres` | **993**（主要为 `Art/**/*.sprites` 图集资源与角色运行清单） |
| PNG | **16,723**（16,702 小写 `.png` + 21 大写 `.PNG`） |
| `.import` | **17,005** |
| `.uid` | **775** |
| MP3 / WAV | **170 + 8**（大写 `.MP3`）/ **1** |
| 字体 | **13 TTF + 2 TTC** |
| Shader | **7** |
| Autoload | **13** |

> 仓库体积与本地素材、`.git`、导入缓存相关，不作为发布指标；公开仓库不包含第三方素材。

---

## 4. 质量门禁

| 命令 | 作用 |
|:---|:---|
| `python scripts/check_all.py` | 八维总门禁（行尾、格式、lint、引擎编译、契约、命名、运行时引用、资源路径） |
| `python scripts/check_all.py --skip-engine` | 无 Godot 环境时的静态门禁 |
| `python scripts/health_check.py --project source --godot-bin <path>` | 场景引用拓扑、死代码、Headless 编译与 GDScript warning 门禁 |
| `python scripts/level_regression_all.py --jobs 4 --timeout 90` | 全量关卡冒烟回归；8 并发仅用于快速回归 |
| `python scripts/level_test_runner.py --godot <path> --level res://Scene/level/level_1.tscn` | 单关冒烟夹具 |
| `python scripts/coop_probe_runner.py --godot <path>` | LocalCoop 探针矩阵（用例清单由脚本维护） |
| `python scripts/convert_atlas_metadata.py --check` | Atlas manifest 与 `metadata.tres` 同步校验 |

Godot 可执行文件通过 `--godot-bin` / `--godot` 或 `GODOT_BIN` 环境变量指定，不写入仓库。

报告由脚本按需生成到 `docs/reports/`，不提交历史报告；说明见 [`../reports/README.md`](../reports/README.md)。

---

## 5. 验证状态

> 以下为不同阶段的验证记录；历史行按当时基线保留。当前规模与最新静态复验见本页 §3 与下表首行。

| 验证 | 结果 | 说明 |
|:---|:---|:---|
| 2026-10-25 文档同步基线 | 静态门禁 **7/7 PASS** | `scripts/check_all.py --skip-engine`；未重跑引擎编译、关卡回归与双人探针 |
| 结构整理后静态门禁 | **7/7 PASS** | `scripts/check_all.py --skip-engine` |
| Atlas 元数据 | **379/379 同步** | `scripts/convert_atlas_metadata.py --check` |
| 6.9 完整工作区验收基线 | 七维门禁 7/7；关卡回归 **128/128 PASS + 5 SKIP**；双人矩阵 **15/15 PASS**；Atlas **379/379** | 本地完整素材工作区；6.9 定向探针 0 failures |
| Phase 12-1 显示基线 | 七维门禁 **7/7 PASS**；关卡回归 **128/128 PASS + 5 SKIP**；705 脚本 0 Error / 0 Warning | 1280×800 画布、1600×1000 窗口、相机缩放 1.3559；16:10 截图无底部灰带 |
| Phase 12-2 HUD/FOV 基线 | 七维门禁 **7/7 PASS**；`level_1` 冒烟 **PASS**；日志 0 ERROR / 0 WARNING | HP/MP 24/12、按钮底边距 96、技能栏 x24 贴底；无双文字方向已修正；相机 1.2 + 纵向取景偏移；1280×800 / 1600×1000 / 1830×1126 / 1920×1200 截图通过 |
| Phase 12-3 多分辨率验收 | 七维门禁 **7/7 PASS**；关卡回归 **128/128 PASS + 5 SKIP**；双人矩阵 **15/15 PASS**；Atlas **379/379** | 16:10 / 16:9 / 21:9 共 8 组分辨率通过；P1/P2 技能栏正常方向；21:9 无右侧灰边；归档见 [`../archive/iteration_12_display_hud.md`](../archive/iteration_12_display_hud.md) |
| Phase 12 HUD 微调 | 七维门禁 **7/7 PASS**；`level_1` 冒烟 **PASS**（0 ERROR / 0 WARNING）；双人矩阵 **15/15 PASS** | 单/双人五按钮统一底部居中（54×54、底边距 4），移除菜单按钮与收展；技能栏基尺寸 364×134 ×0.85（实际 309.4×113.9），P1 左/底 0、P2 右/底 0；P2 技能标签为小键盘 3/4/5/6/8（镜像视觉 8/6/5/4/3）；无双圆盘 P1 x=85、P2 x=82 对齐；FPS/显存双人顶部偏移 164；2P 唐僧身体/装备贴图按 2P 存档角色加载；1600×1000 单/双人截图通过 |
| Spine Atlas 页名修复 | 全量 `.atlas` 页名与实际 PNG 文件名逐字匹配 **0 mismatch**；jhsj / lyfb 预加载 **PASS** | 修复 `role_2/jhsj_awaken`、`role_2/lyfb_awaken`、`role_4/cang_mu_long_yun` 共 9 个页名：`HeroF_*` → 实际 `hero_f_*`；atlas 声明尺寸与 PNG 实测尺寸一致 |
| P2 普攻与子弹路径修复 | P2 小键盘 1 实机探针 **PASS**（子弹子节点 0→1，无属性错误）；七维门禁 **7/7 PASS**；`level_1` 冒烟 **PASS**（0 ERROR / 0 WARNING） | `BaseHero` 暴露的是 `bullet`，清理全部 `self.Bullet` / `player.Bullet` 等大小写错误；`Global.add_role_bullet` 将语义名规范为 slim 场景文件名（如 `Role2Bullet1` → `role2_bullet1.tscn`），避免普攻进入第二步时缺场景 |
| 命名大小写专项复核 | 七维门禁 **7/7 PASS**；运行时引用 **0**；命名终审 **0 违规**；`level_info` 关卡配置探针 **PASS** | 修复地图 `Level_*`→`level_*`、返回地图 `Map_*`→`map_*`；统一 `level_info`、`load_scene`、`monster_head_info`、`base_monster` 的 `Monster_` 文件名解析；修复 `base_hero` `/Level/` 与 light 场景路径判断；删除 SSSL 遗留帧路径表 |
| 资源路径门禁基线 | `check_all.py` **8/8 PASS**；资源路径静态 8386 / 动态 165 / atlas 32 / 工厂 43；负向探针 **4/4 拦截** | `resource_path_audit.py` 覆盖静态路径大小写、动态格式路径、Spine atlas 页名、`add_role_bullet` / `add_role_special_effect` 工厂目标；Art 缺失时自动跳过素材路径 |
| 法宝面板空态统一 | 八维门禁 **8/8 PASS**；单/双人空态探针 **PASS**；`level_1` 冒烟 **PASS**（0 ERROR / 0 WARNING） | `magic_weapon_infor` 增加 `Content` / `EmptyState`；无已装备法宝时仍打开面板，只隐藏内容区，保留背景、关闭按钮、帮助与 1P/2P 页签；P1/P2 按当前视图分别读取法宝数据；空态操作按钮隐藏并带函数级防御 |
| GDScript 静态警告清零 | Godot `--debug` warning **53→0**；八维门禁 **8/8 PASS**；`level_1` / `level_34_1` / `level_52` / `level_58` 冒烟 **PASS**；LocalCoop 矩阵 **15/15 PASS** | 修复 4 类局部作用域命名、异步接口重复、跨脚本私有状态与 53 处存量 warning；`health_check.py` 增加 warning code 解析与白名单外失败门禁 |
| 双人 P1/P2 攻击归属修复 | LocalCoop 矩阵 **16/16 PASS**；新增无双归属探针覆盖 P2 近战/弹道/显式 owner；Godot `--debug` **0 warning** | 伤害来源统一由 `LocalCoop` 实际出手者解析；`cure_ws_value` 接受显式玩家 owner；P2 弹道、法宝、技能效果、特殊怪物覆盖与黄 aura 不再把无双/伤害记到 P1；P2 无双同步衰减 |
| 哪吒启动 PackedScene 契约修复 | Nezha 预热探针 **PASS**；转换器 `--check` **39 套 / 117 个内容一致**；Godot `--debug` **0 warning**；场景加载路径仅接受 `.tscn` / `.scn` | 根因是显示层预热列表曾混入 3 个 SpriteFrames `.tres`；场景预热仅保留场景路径，`_load_scene` 强制 `PackedScene` 类型，非场景路径返回 null 而不再触发返回值类型错误 |
| 全角色运行资源清单 | 角色 1~7 静态 Catalog **PASS**；无技能/条件路径探针 **PASS**；角色 7 音频 **25 条**；角色 4/5 重型帧构建期化 **PASS**；`level_1` 冒烟 **PASS**（0 ERROR / 0 WARNING）；Godot `--debug` **0 warning** | 新增 `RoleRuntimeCatalog` 以 typed Dictionary + `preload` 静态注册全部清单，删除 Manifest 缺失回退与旧硬编码路径；条件字段改为 `Dictionary[String, PackedStringArray]`；角色 7 动态音频进入清单；`zlw_shenqi_gear_bullet.tscn` 改为 `BaseHero` 固定 `preload`；BiLuoTian cast/hit 与 LeiTingJieZhen formation/lightning 由 `convert_numbered_frames.py` 生成 4 个构建期 SpriteFrames，Manifest 改走 `conditional_sprite_frames_paths`，移除 175 条 PNG 路径与运行时建帧 |
| 引擎健康检查基线 | 706 脚本 0 Parse / 0 Error / 0 Warning;1,136 场景 0 断裂引用 | 本地完整素材工作区 |
| 双人探针基线 | 16 PASS / 0 SKIP / 0 FAIL | `scripts/coop_probe_runner.py` |

> 公开 clone 缺少第三方素材，不能直接复现完整验收；缺失资源提示属于预期。

---

## 6. 已知边界

1. 当前仓库已建立本地 Git 提交历史；尚未推送远端，工作区由本地完整备份保障。
2. `scripts/convert_atlas_metadata.py` 是当前构建期转换器，由 `scripts/contract_gate.py` 调用。
3. 版本专用的解密、重建、场景恢复工具不进入当前仓库；后续迁移前必须重新验证目标二进制格式。
4. 13 个 Autoload、`global.gd` 大体量全局状态、字典/JSON 数据与类型分层目录按遗留结构保留；新增代码不得继续扩张。
5. 8 并发全量回归存在偶发的 Godot 启动瞬态；稳定复跑建议 `--jobs 4`。
6. 按项目原则不做向前兼容：旧 `user://` 存档目录、旧任务键与旧配置均不迁移；存档密钥前缀已修正为 `zmxybhyh`。
7. Phase 12 已验证 1280×800 窗口模式；Steam Deck 全屏与 Android 实机未在当前硬件环境运行，移动端分支仅做代码路径与静态检查。
8. 21:9 使用 `BackGround/End` 的 1440px `motion_mirroring` 消除默认清屏色；部分静态背景可能存在轻微镜像接缝，后续可通过美术资源加宽优化。
9. 全量关卡清单完成功能回归；21:9 视觉抽检覆盖 `level_1`、`level_10`、`level_22`、`level_59`，未对全部关卡逐帧截图。
