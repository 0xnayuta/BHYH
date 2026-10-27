# 当前工程状态 (Status)

> 本文是工程版本、目录结构、规模与验证状态的单一事实源。
>
> 最后更新：2026-10-27（13-4 删除与发布清单归属迁移完成，入口收敛待确认）

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

## 3. 规模（2026-10-26 实测）

| 指标 | 数量 |
|:---|:---:|
| GDScript | **749**（业务 713：`Script/` 650 + 顶层 7 + `Scene/` 55 + `Art/` 1；插件 36） |
| 场景 `.tscn` | **1,137**（`Scene/` 1,136 + 插件 1） |
| 资源 `.tres` | **1,284**（`Art/**/*.sprites`、FrameSequence、角色与关卡预载清单） |
| PNG | **16,723**（16,702 小写 `.png` + 21 大写 `.PNG`） |
| `.import` | **17,005** |
| `.uid` | **782** |
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
| `python scripts/level_regression_all.py` | 全量关卡冒烟回归；默认 auto 并发（最高 12），`--jobs 4` 为稳定排障口径 |
| `python scripts/level_test_runner.py --godot <path> --level res://Scene/level/level_1.tscn` | 单关冒烟夹具 |
| `python scripts/coop_probe_runner.py --godot <path>` | LocalCoop 探针矩阵（用例清单由脚本维护） |
| `python scripts/scene_probe_runner.py --godot <path>` | 星座 Boss 运行时场景探针（`--scene` 完整生命周期） |
| `python scripts/convert_atlas_metadata.py --check` | Atlas manifest 与 `metadata.tres` 同步校验 |
| `python scripts/convert_monster_frames.py --check` | 怪物 `AtlasMetadata.sequences` 与既有 `*_frames.tres` 的帧几何、页闭包、动画名与 UID 校验 |

Godot 可执行文件通过 `--godot-bin` / `--godot` 或 `GODOT_BIN` 环境变量指定，不写入仓库。

报告由脚本按需生成到 `docs/reports/`，不提交历史报告；说明见 [`../reports/README.md`](../reports/README.md)。

---

## 5. 验证状态

> 以下为不同阶段的验证记录；历史行按当时基线保留。当前规模与最新静态复验见本页 §3 与下表首行。

| 验证 | 结果 | 说明 |
|:---|:---|:---|
| 2026-10-25 3077 tornado 构建期帧迁移 | `convert_numbered_frames.py --all --check` **5/5 PASS**（tornado **7 帧 / duration 3.0**）；headless 验证 3077 普通 `Texture2D` 帧可视与碰撞 **PASS**，3117 `AtlasTexture` 回归 **PASS**；静态门禁 **7/7 PASS**；`health_check` **0 Parse / 0 Error / 0 Warning**；`level_1` 冒烟 **PASS** | 3077 `tornado` 改用独立 `tornado_frames.tres`，移除逐帧 `frame_root/frame_count`；弹道碰撞标准帧分支同时支持普通 `Texture2D` 的 `used_rect` 几何 |
| 2026-10-25 Wutai 弹道图集帧审计 | 83 个 swf_png 模型 / **588** 个序列全部能在伴随 `*_frames.tres` 中找到，缺失 **0**；Wutai 自动解析用例 3065/3069/3076/3078/3136 可视节点创建成功；3077 `tornado` 已由独立构建期帧资源接管；静态门禁 **7/7 PASS**；`health_check` **0 Parse / 0 Error / 0 Warning**；`level_1` 冒烟 **PASS** | `WutaiMinghaiProjectile` 对 swf_png 序列自动解析同目录构建期 frames 资源，仅在目标动画存在时启用；避免各 Boss 配置漏传 `frames_resource` 时回退到不存在的逐帧 PNG |
| 2026-10-25 五台明海 3117 弹道图集帧修复 | 静态门禁 **7/7 PASS**；`health_check` **0 Parse / 0 Error / 0 Warning**；`level_1` 冒烟 **PASS**；3117 `effect2_1` 弹道帧与可视节点创建成功，运行日志 **0 ERROR** | 3117 项目配置补入构建期 `frames_resource`；弹道改用 SpriteFrames 的 AtlasTexture 帧几何，不再访问不存在的逐帧 PNG |
| 2026-10-25 ESC 分层关闭与可变跳跃 | 静态门禁 **7/7 PASS**；`health_check` **0 Parse / 0 Error / 0 Warning**；`level_1` 冒烟 **PASS**；实机 ESC 逐层关闭 **通过**；设置“返回主菜单” **0 ERROR / 0 WARNING**；角色 6 点按/长按跳高 **89.4 / 153.3 px** | HUD 统一 ESC 分发与 `request_escape_close()` 子层契约；松开跳跃键按 0.7 保留上升速度；场景树退出时跳过暂停刷新，避免 `get_tree()` 空引用 |
| 2026-10-25 2D 角色泛光清理与装备槽提示修复 | 静态门禁 **7/7 PASS**；`health_check` **0 Parse / 0 Error / 0 Warning**；`level_1` 冒烟 **PASS**；角色 6 实际存档悬停五按钮 + A/D 后渲染错误 **0**；已装备武器提示框创建成功 | 删除 BaseHero / Role1 的 3D WorldEnvironment 泛光；装备槽提示改用图标文件名与 `get_item_name`/`eq_prop`，移除 `AllItems` 大小写路径解析 |
| 2026-10-25 哪吒背包预览修复 | 静态门禁 **7/7 PASS**；`health_check` **0 Parse / 0 Error / 0 Warning**；`level_1` 冒烟 **PASS**（0 ERROR / 0 WARNING）；角色 6/7 与角色 1 实机预览验证通过 | 恢复 `Global.load_role1_body/eq` 与 `configure_backpack_role_preview` 的角色 6 分派；背包旧预览改为 10Hz 脏检查，角色 6/7 由 `NeZhaPreview` 独占；无素材变更 |
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
| 2026-10-26 发布前 L2 固定验收 | `level_1` Stage 1~4 **PASS**（0/0）；`level_tzsijian` **PASS**（0/0）；`coop_probe_runner` **16/16 PASS / 0 SKIP / 0 FAIL**；`scene_probe_runner` **PASS**；日志均 **0 ERROR / 0 WARNING** | 固定三件套：`level_test_runner.py` + `coop_probe_runner.py` + `scene_probe_runner.py`；执行顺序与阻断规则写入 `docs/reference/acceptance.md` §6；报告由脚本生成，不提交 |
| 2026-10-26 星座运行时场景探针 | `scene_probe_runner.py` **PASS**：body **12/12**、body 流首帧 **PASS**、`skill1~4` 标准 SpriteFrames **PASS**、`skill2_3` FrameSequence 回退 **PASS**；日志 **0 ERROR / 0 WARNING**；八维门禁 **8/8**；`convert_frame_sequences.py --check` **455 序列 PASS** | 新增 `scripts/scene_probes/constellation_probe.{gd,tscn}` 与 `scripts/scene_probe_runner.py`；用 `--scene` 启动完整 Autoload 生命周期，避免 `--script` 的编译时序问题；探针执行期复制到 `source/`，结束后清理 |
| 2026-10-26 FrameSequence 全量迁移 | `convert_frame_sequences.py --check` **455 个序列 PASS**；四剑台背景 / 星座治疗 aura / 混沌 / 饕餮 / 流沙河 / 五台 3077 / 四剑阵 / 星座动态 body / 星座技能 / 五台弹道非 swf 探针 **PASS**；`level_tzsijian` 冒烟 **PASS**（0 ERROR / 0 WARNING）；八维门禁 **8/8**；health **709 脚本 0/0/0** | 新增 `FrameSequence`、`FrameSequenceCatalog`、`FrameSequenceStore` 与 `convert_frame_sequences.py`；`StreamedPngEffect` 只消费 `sequence`，旧数组字段删除；固定目录、四剑阵 AtlasMetadata、星座动态 body、星座技能与五台弹道非 swf 序列均由构建期 Catalog 驱动；无运行时目录扫描/路径数组 |
| 2026-10-26 FrameSequence 收口（基于 `00c3cf0` 的工作区） | 最终 `--check` **477 序列 / 2,831 条延迟纹理源闭包 PASS**；最终八维门禁 **8/8 PASS**；星座生产场景与共享请求/真实预热/末帧/跳帧/退出回收 **PASS**；LocalCoop **16/16 PASS** | 新增 `FrameTextureRequests` 去重租约与终态取回；Store/播放器接入 schema 校验；主视觉与 impact 显式后端，错误配置拒绝生成；八仙已有效果补入构建清单；生成 UID 与发布依赖 JSON，并接入契约门禁；不代表 PCK、release 或平台性能已验证 |
| 2026-10-26 收口代表关卡与反例 | `level_1`、`level_tzsijian`、`level_61`、`level_bxgh`、`level_73`、最终 `level_74` 冒烟 **PASS，0 ERROR / 0 WARNING**；错误动画、坏清单、异步请求失败按预期拒绝；失败请求取回后引擎状态归零；生成资源 UID 实际加载有效 | 负向样本的预期 ERROR 单列，不计作常规零错误通过；早期 level_74 在并行编辑时失败，冻结后复跑通过。新常量声明曾触发 debug 编译停在断点而超时，修复后最终完整门禁通过；不删除原失败证据 |
| 全角色运行资源清单 | 角色 1~7 静态 Catalog **PASS**；无技能/条件路径探针 **PASS**；角色 7 音频 **25 条**；角色 4/5 重型帧构建期化 **PASS**；`level_1` 冒烟 **PASS**（0 ERROR / 0 WARNING）；Godot `--debug` **0 warning** | 新增 `RoleRuntimeCatalog` 以 typed Dictionary + `preload` 静态注册全部清单，删除 Manifest 缺失回退与旧硬编码路径；条件字段改为 `Dictionary[String, PackedStringArray]`；角色 7 动态音频进入清单；`zlw_shenqi_gear_bullet.tscn` 改为 `BaseHero` 固定 `preload`；BiLuoTian cast/hit 与 LeiTingJieZhen formation/lightning 由 `convert_numbered_frames.py` 生成 4 个构建期 SpriteFrames，Manifest 改走 `conditional_sprite_frames_paths`，移除 175 条 PNG 路径与运行时建帧 |
| 引擎健康检查基线（2026-10-26 收口工作区） | 710 脚本；最终完整门禁引擎维度 PASS，0 Parse / 0 Error / 0 Warning；1,136 场景 0 断裂引用 | 本地完整素材工作区；不以 health_check 超时返回 0 冒充通过 |
| 2026-10-26 FrameSequence 身份模型 v2 | `convert_frame_sequences.py --check` **288 序列 / 2,812 条延迟纹理源闭包 PASS**；输出为 `asset_id` 键的 Catalog + 可读 slug 文件；陈旧输出清理 **477 → 0**；八维门禁 **8/8 PASS**；`level_1` Stage 1~4 **PASS**、`level_tzsijian` **PASS**、`scene_probe_runner` **PASS**、`coop_probe_runner` **16/16 PASS**；日志均 **0 ERROR / 0 WARNING** | 序列身份改为稳定 `asset_id`，删除 189 个策略复合 key 冗余（477→288）；`default_fps/default_loop/default_hold_last_frame/default_prefetch_frames` 只作默认值，`StreamedPngEffect.configure_playback()` 提供实例覆盖；转换器按 `asset_id` 派生可读文件名并校验唯一性、单目录单序列与陈旧输出；`--export-preset` 在验证用 `all_resources` 预设下声明覆盖 **3,101 条** |
| 2026-10-26 FrameSequence 发布包闭包 | `frame_sequence_pack_probe.py` **PASS**：PCK 内 **3,101 条依赖全部可达**（Catalog + 288 序列 + 2,812 延迟纹理）；约 2.74 GB | 验证用预设 `Windows Desktop (validation)`（`all_resources`）；Godot 挂载 PCK 后用 `ResourceLoader.exists()` 逐条判定，导出后 PNG 以 `.import` + `.ctex` 形式存在。PCK 为构建临时产物，sha256 随素材与构建变化，不写入本文作为稳定标识 |
| 双人探针基线 | 16 PASS / 0 SKIP / 0 FAIL | `scripts/coop_probe_runner.py` |
| 2026-10-26 Phase 13-1 失败语义与热路径 IO | 八维门禁 **8/8 PASS**；`health_check` 713 脚本 **0 Parse / 0 Error / 0 Warning**；`scene_probe_runner` **2/2 PASS**；`coop_probe_runner` **16/16 PASS**；`level_1` / `level_59` / `level_61` / `level_pty` / `level_bxgh` / `level_stz` 冒烟 **PASS**（0 ERROR / 0 WARNING） | `RoleRuntimeCatalog.get_manifest` 的 `assert` 改为 `push_error + null`，两个调用方中止预热；`AtlasMetadataStore` 三种失败可区分并新增 `validate_path()`；宠物弹体空帧占位改为显式 `null` 或按时间轴长度生成纯计时帧；删除 `monster_bullet` 的 `DirAccess` 扫描与 `range(601)` 编号探测，宠物龙/虎帧改由构建期 `SpriteFrames` 驱动；`hdzm.gd` 热路径 `load()` 改为 `preload`；`StreamingFrameEffect` 基类删除逐帧同步加载 |
| 2026-10-26 全量关卡回归（素材切换后） | `level_regression_all.py --jobs 4 --timeout 150`：**PASS 128 / 128 + SKIP 5，FAIL 0**，耗时 **732.2 秒** | 覆盖编号关 85 + 特殊关 48；SKIP 为 5 个非战斗场景（`bai_gu_level` / `boat` / `bsz` / `hdzm` / `jctfloor_1`），按既定口径计入通过。私有素材仓已推送的 FrameSequence 可读命名切换（288 新增 / 477 删除 / Catalog + 依赖清单）未引入断裂引用 |
| 2026-10-26 关卡预载 Catalog 迁移 | `convert_level_preload_catalog.py --check` **153 场景 / 101 关卡条目 / 17 弹体条目 PASS**（并入契约门禁）；八维门禁 **8/8 PASS**；`health_check` 713 脚本 **0 Parse / 0 Error / 0 Warning**；`level_1` / `level_46` / `level_59` / `level_61` / `level_pty` / `level_xhy` / `level_tzsijian` 冒烟 **PASS**（0 ERROR / 0 WARNING） | `load_scene.gd` 与 `global.gd` 删除运行时 `.gd`/`.tscn` 源文本正则解析，改读构建期 `LevelPreloadCatalog.tres`；数据收敛为 `first_wave_ids`（stage_1 优先级）与 `monster_ids`（完整覆盖，含 stage_5+）；删除无调用点的 `_prewarm_target_script_monsters`、`Global.preload_level_monster_resources` 及后台预载子系统；怪物弹体名改为磁盘真实大小写 |
| 2026-10-26 Phase 13-2A 怪物帧转换器 | `convert_monster_frames.py --check` **148 目标 / 40,222 帧 PASS**；8 个样本经 Godot 探针比对「生成 vs metadata vs 生产」**6,123 帧 0 差异**（含 loop/speed）；`--all` 幂等写入 **0**；契约门禁 **8/8 PASS**，其中 `monster_frames_check` 新增并通过 | 新增 `scripts/convert_monster_frames.py` 并接入 `contract_gate`；目标解析复用既有 `*_frames.tres`（同目录优先、`atlas*` 回退父目录），`pet_tiger_boss/atlas` 因 stage 聚合名显式跳过；148 个历史目标无 UID 头，`--check` 记为已评审例外，`--rewrite` 可补确定性 UID；`--emit` 供抽样探针使用，探针目录验证后删除 |
| 2026-10-26 关卡选择态探针 | `scene_probe_runner.py` 套件 **2/2 PASS**：星座 + 选择态；选择态覆盖 `level_bxgh` 8 个八仙/非法回退与 `level_stz` 3 个三太子/非法回退，13 项全 PASS；日志 **0 ERROR / 0 WARNING**（仅 headless dummy 纹理噪声豁免） | 新增 `scripts/scene_probes/level_selection_probe.{gd,tscn}`；断言 `monster_group["stage_1"]`、关卡自预载场景缓存与三太子背景可见性；`scene_probe_runner.py` 改为 `PROBES` 清单并支持 `--probe`；退出阶段按 `*_PROBE_TEARDOWN` 分区 |
| 2026-10-27 Phase 13-2B 怪物帧消费者切换（第一批） | `convert_monster_frames.py --check` **152/152 PASS**；Godot 探针覆盖 17 个动作映射目标与 4 个剑 Boss，别名帧实例共享、loop/speed **0 失败**；`health_check` 713 脚本 **0 Parse / 0 Error / 0 Warning**；静态门禁 **8/8 PASS**；全量关卡回归 **PASS 128/128 + SKIP 5，FAIL 0**（726.6s，level_dsg_5 重试后通过） | 27 个怪物脚本改为直接加载构建期帧资源，删除运行时 `SpriteFrames.new()` 重建与逐帧 PNG 回退；素材分 5 批：148 个资源补确定性 UID、动作别名、多模型别名、4 个剑 Boss 新资源、四头 Boss 头部别名。`SpriteFrames.new()` 文件数 **70→46**（怪物 **50→26**）；剩余 east/weiyang/tao_wu/裁剪与弹体脚本登记为下一批 |
| 2026-10-27 Phase 13-2B 弹体动作别名批次 | `convert_monster_frames.py --check` **152/152 PASS**；Godot 探针覆盖 3002/3004/3007/3020 的 fly/explode/fly1/fly2/arrow1/arrow2，帧数与 loop **0 失败**；`level_ymj` / `level_51` / `level_xwk` 冒烟 **PASS**（0 ERROR / 0 WARNING）；全量关卡回归 **PASS 128/128 + SKIP 5，FAIL 0**（681.0s） | 4 个弹体脚本改为直接加载帧资源；素材提交 `3d6e8893` 追加动作别名；`SpriteFrames.new()` 文件数 **46→42**（怪物 **26→22**）；剩余 east/weiyang/tao_wu/裁剪/无资源编号弹体登记为下一批 |
| 2026-10-27 Phase 13-2B 编号帧/loose/建帧门禁收口 | `convert_numbered_frames.py --all --check` **21/21 PASS**；Godot 探针 10/10 编号帧资源帧数/loop/fps **0 失败**；`level_ghg` / `level_66` / `level_1` 冒烟 **PASS**（0/0）；`runtime_frames_audit.py --fail-on-error` **34/34 一致**；契约门禁 **9/9 PASS**；`health_check` **0 Parse / 0 Error / 0 Warning**；全量关卡回归 **PASS 128/128 + SKIP 5，FAIL 0**（690.1s） | 新增 10 个编号帧弹体资源与 6 个东胜神洲 loose 特效资源；九华松针修正到 3009 图集 arrow 动画；east 建帧 2→1（仅剩动态配置标准动作重命名）；`SpriteFrames.new()` **42→34**（怪物 **22→14**）；新增 `runtime_frames_allowlist.json` 与防扩张门禁，负向样本 exit 1 |
| 2026-10-27 Phase 13-2B 流沙河/130-215/法宝 | `convert_liu_sha_frames.py --check` **5/5 PASS**；`convert_monster_action_views.py --check` **3/3 PASS**；`convert_numbered_frames.py --all --check` **28/28 PASS**；Godot 探针流沙河 5 资源、动作视图 3 资源、法宝 7 资源帧数/loop/fps/duration **0 失败**；`level_ghg` 冒烟 **PASS**（0/0）；契约门禁 **11/11**；`health_check` **0/0/0**；静态门禁 **8/8**；全量回归 **PASS 128/128 + SKIP 5，FAIL 0**（723.3s，level_58 重试通过） | 新增流沙河 5 个、130/212/215 动作视图 3 个、法宝 7 个构建期资源；8 个脚本删除运行时建帧；`SpriteFrames.new()` **34→27**，怪物 **14→9**（达到 ≤10 的怪物出口目标）；allowlist 同步删除 6 条 |
| 2026-10-27 Phase 13-2B 宠物弹体/寅虎 stage | `convert_numbered_frames.py --all --check` **47/47 PASS**；`convert_monster_action_views.py --check` **5/5 PASS**；Godot 探针 19 个宠物弹体 + 2 个 stage 资源帧数/loop/duration **0 失败**；契约门禁 **11/11**；`health_check` **0/0/0**；静态门禁 **8/8**；全量回归 **PASS 128/128 + SKIP 5，FAIL 0**（691.0s） | 四宠物弹体（mouse/rabbit/turtle/yin_tiger）与寅虎 stage1/2 改加载构建期资源；`SpriteFrames.new()` **27→21**（怪物 **9**、非怪物 **12**）；architecture §6.5 新增 9 个怪物文件的冻结裁定与判定标准；allowlist 21 条 |
| 2026-10-27 关卡回归并发优化 | 56 关基准：`--jobs 4` **204.8s**、`--jobs 8` **124.7s**、`--jobs 12` **98.1s**、`--warmup 1`+12 **120.5s**；全量 133 关：`--jobs 4` **690.0s** → auto（12）**275.7s**，**PASS 128/128 + SKIP 5，FAIL 0**（`level_lxdy1` 1 次瞬态，重试通过） | `level_regression_all.py` 默认并发改为 `min(12, max(4, CPU 核数))`；新增 `--warmup`（默认 0，实测无收益）；保留失败关卡串行重试；`--jobs 4` 仍为稳定排障口径 |
| 2026-10-27 关卡回归优化对比与最终方案 | 56 关：jobs4 **204.8s** → jobs8 **124.7s** → jobs12 **98.1s**；全量：jobs4 **690.0s** → auto（12）**275.7s**；预热+12 **120.5s**（无收益）；5 关/组进程复用 **146.8s**（更慢） | 最终采用单关进程 + auto 并发 12、`--warmup 0`、失败串行重试；进程复用已验证但回滚（每关加载屏/资源清理抵消启动节省）；日常 `--changed-only`，发布全量；`--jobs 4` 保留为稳定排障口径 |
| 2026-10-27 Phase 13-3 发布依赖闭包 | `convert_level_preload_catalog.py --check` PASS：199 怪物场景 / 24 动态场景 / 8 弹体 / 767 动态纹理；`frame_sequence_pack_probe.py --self-test` **4,100 条**；PCK **2,738,623,739 字节**，**4,100/4,100 可达**（sha256 `f87a631c73db…`；清单迁到公共路径后复跑）；全量回归 **PASS 128/128 + SKIP 5，FAIL 0**（273.1s）；`health_check` 713 脚本 **0/0/0**；`level_bxgh` / `level_stz` / `level_64` / `level_65` 冒烟 **0/0** | 新增公共路径 `source/Script/data/level_preload_export_dependencies.json` 与 Catalog 动态字段；删除 `global.gd` 两张动态表、`MONSTER_SCENE_ALIASES` 与追加函数（5419→5241 行，净减 178）；别名与动态来源迁入 `monster_dynamic_paths.json` 构建期展开；PCK 探针合并两份清单；13-3 完成 |

| 2026-10-27 Phase 13-4 纹理别名删除 | 2,313 → **1,381**；删除 **932**（917 无引用 + 15 仅通用基名）；1 条目标修正为 `Art/monster/monster_66_1/skill1.png`；`classify_texture_aliases.py --check` PASS；契约门禁 **12/12**；`check_all` **8/8**；`health_check` 713 脚本 **0/0/0**；全量回归 **PASS 128/128 + SKIP 5**（283.0s，`level_tzsijian` 1 次瞬态重试通过）；`level_1` / coop **16/16** / scene **2/2** | 新增 `texture_alias_targets` 契约门禁；入口收敛未执行；未修改素材；15 条弱引用均为 `preview.png` / `1.png` / `parts.png` 通用基名，父目录无引用 |

> 公开 clone 缺少第三方素材，不能直接复现完整验收；缺失资源提示属于预期。

---

## 6. 已知边界

1. 当前仓库已建立本地 Git 提交历史；尚未推送远端，工作区由本地完整备份保障。
2. 当前构建期转换器为 `scripts/convert_atlas_metadata.py`、`convert_frame_sequences.py`、`convert_monster_frames.py`、`convert_level_preload_catalog.py`、`convert_liu_sha_frames.py` 与 `convert_monster_action_views.py`；上述 `--check` 由 `scripts/contract_gate.py` 调用，`convert_numbered_frames.py` 按资源变更单独执行。`frame_sequence_pack_probe.py` 依赖导出模板，发布前单独执行，不进入日常门禁。
3. 版本专用的解密、重建、场景恢复工具不进入当前仓库；后续迁移前必须重新验证目标二进制格式。
4. 13 个 Autoload、`global.gd` 大体量全局状态、字典/JSON 数据与类型分层目录按遗留结构保留；新增代码不得继续扩张。
5. 高并发全量回归存在偶发的 Godot 启动瞬态（12 并发实测 `level_lxdy1` 1 次，重试通过）；`--jobs 4` 为稳定排障口径。进程复用（同进程多关）已验证但未采用：加载屏/资源清理抵消启动节省，5 关/组实测更慢。
6. 按项目原则不做向前兼容：旧 `user://` 存档目录、旧任务键与旧配置均不迁移；存档密钥前缀已修正为 `zmxybhyh`。
7. Phase 12 已验证 1280×800 窗口模式；Steam Deck 全屏与 Android 实机未在当前硬件环境运行，移动端分支仅做代码路径与静态检查。
8. 21:9 使用 `BackGround/End` 的 1440px `motion_mirroring` 消除默认清屏色；部分静态背景可能存在轻微镜像接缝，后续可通过美术资源加宽优化。
9. 全量关卡清单完成功能回归；21:9 视觉抽检覆盖 `level_1`、`level_10`、`level_22`、`level_59`，未对全部关卡逐帧截图。
10. 已入库仅用于验证的 `source/export_presets.cfg`（单预设、`all_resources`），其 `[preset.0.options]` 必须至少包含一个合法键：Godot 的 `ConfigFile` 不会把无键 section 计入 `get_sections()`，空 section 仍会触发 `Cannot get keys from nonexistent section "preset.0.options"`。当前使用默认键 `custom_template/debug=""`，不改变导出行为。并新增 `scripts/frame_sequence_pack_probe.py`；2026-10-26 实测 PCK 内 3,101 条 FrameSequence 依赖全部可达。导出包内 PNG 以 `.import` 与 `.ctex` 形式存在，判定必须走 `ResourceLoader.exists()` 而非 `FileAccess`。**仍未验证**：release 失败语义、目标设备 VRAM、首帧耗时与实际加载路径下的运行时表现；该预设不是发布裁剪策略。
11. FrameSequence 已完成 `asset_id` 与实例播放策略分离；不再保留 FPS/loop/hold/prefetch 复合 key，也无双 key 兼容层。旧版生成的哈希命名文件已由转换器清理。
12. `--import` 出现已打开编辑器占用 godot-mcp 端口的环境 ERROR；不视为零错误导入。正式游戏场景探针、代表关卡和最终编译门禁分别验证，不把导入退出码 0 等同完整验收。
