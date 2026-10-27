# BHYH 运行时架构 (Architecture)

> **状态**：活跃参考文档（2026-10-25 重写）。
>
> **定位**：描述 `source/` 当前**实际运行**的工程结构、启动与场景流、对象模型、数据与资源分层、UI/输入边界，以及遗留结构与现代化模块的分界。
>
> **不在本文范围**：具体编码规范以 [`../standards/`](../standards/README.md) 为准；验收命令与通过判据见 [`acceptance.md`](acceptance.md)；版本、规模与历史验证结果以 [`status.md`](status.md) 为单一事实源。
>
> **事实口径**：本文按代码与工程配置取证，不把规划目标写成现状。标注「目标」或「未落地」的条目尚未在代码中实现。

---

## 1. 系统总览

### 1.1 工程边界

仓库只保留一个活跃 Godot 工程：

```text
BHYH/
├── source/                 # 唯一活跃工程（project.godot 在此）
├── docs/                   # 规范、参考、决策、路线、指南、归档
└── scripts/                # 门禁、审计、回归、构建期转换器
```

- 业务改动只进入 `source/`；
- `source/addons/` 是第三方插件，非插件维护任务不修改；
- 第三方素材目录 `source/Art/`、`Music/`、`Font/`、`Spritesheet/` 不进入公开仓库；
- 迁移工具、解密沙盒与本地二进制路径不进入仓库。

### 1.2 运行基线

| 项目 | 当前值 | 证据 |
|:---|:---|:---|
| 引擎 | Godot **4.7.2** | `source/project.godot`、`docs/reference/status.md` |
| 语言 | GDScript 2.0，优先静态类型 | `docs/standards/godot_design_standard.md` |
| 主场景 | `res://Scene/other_scene/load_scene.tscn` | `source/project.godot` |
| 渲染后端 | 默认 `mobile`；Web 使用 `forward_plus` | `source/project.godot` `[rendering]` |
| 设计画布 / 默认窗口 | **1280×800 / 1600×1000**（16:10，1.25×） | `source/project.godot` `[display]` |
| 拉伸策略 | `canvas_items` + `expand` | `source/project.godot` |
| 最大 FPS | 150（`run/max_fps`） | `source/project.godot` |
| Autoload | **13**：12 个业务单例 + 1 个编辑器调试桥 | `source/project.godot` `[autoload]` |
| 输入动作 | 集中定义于 `source/project.godot`；数量以配置为准 | `source/project.godot` `[input]` |
| 2D 物理层 | 具名层；名称与数量以 `source/project.godot` 为准 | `source/project.godot` `[layer_names]` |
| 场景树分组 | `Player`、`Monster` | `source/project.godot` `[global_group]` |

### 1.3 分层视图

```mermaid
flowchart TD
    P["表现层<br/>Scene/、HUD、面板、特效"] --> O["会话与编排层<br/>Global、LocalCoop、MemoryClass"]
    O --> D["领域层<br/>BaseHero、BaseMonster、BaseLevel、BaseMagicWeapon"]
    D --> S["状态层<br/>PlayerData、RoleProp、MainSet、DataKeys"]
    S --> R["资源层<br/>SpriteFrames、AtlasMetadata、Spine、缓存/池"]
    R --> E["引擎与平台<br/>Godot 4.7.2、Spine GDExtension、文件系统"]
```

这是**运行时职责分层**，不是目录分层。当前目录仍按 `Scene/`、`Script/`、`Art/` 类型划分；新功能在同一顶层目录下按功能子目录聚合。

---

## 2. Autoload 与全局状态

### 2.1 注册顺序与职责

Autoload 按 `project.godot` 中的顺序初始化：

| # | 名称 | 脚本 | 职责 | 备注 |
|:---:|:---|:---|:---|:---|
| 1 | `BaseHit` | `base_hit.gd` | 上一次命中的数值、类型与击退向量中转 | 纯数据单例 |
| 2 | `RoleProp` | `Script/base/base_role_properies.gd` | 角色属性聚合器的单例形态 | 同时提供 `BaseRoleProperties` 类型 |
| 3 | `PlayerData` | `Script/memory_class/player_data.gd` | 存档数据仓库与 `ensure_*` 补全 | `class_name PlayerDataStore` |
| 4 | `MemoryClass` | `Script/memory_class/memory_class.gd` | 本地存档加密读写、备份、后台保存、设置文件 | 本地存档 IO 主入口；云存档导入/导出在归档界面单独加密读写 |
| 5 | `MainSet` | `Script/memory_class/main_set.gd` | 全局设置字典、帧率策略、主菜单背景解锁 | `set_data` |
| 6 | `AE` | `all_equipment.gd` | 装备数值门面，懒加载大体量装备表 | 无业务依赖 |
| 7 | `MLdl` | `Script/ldl/main_ldl.gd` | 锻造台 UI 会话状态 | 无业务依赖 |
| 8 | `PaSkill` | `passive_skills.gd` | 被动技能数值表与灵魂收益 | 读取 `PlayerData`、`RoleProp` |
| 9 | `MainMusic` | `main_music.gd` | 主菜单 BGM 单实例 | 读取 `MainSet`、`Global` |
| 10 | `Signals` | `signals.gd` | 全局确认框信号 `choose_pressed` | 唯一全局信号路由 |
| 11 | `Global` | `global.gd` | 场景切换、UI 工厂、资源缓存、对象池、异步预载、部分业务判定 | 遗留上帝对象 |
| 12 | `LocalCoop` | `Script/coop/local_coop.gd` | 本地双人会话、2P 数据/属性/输入/面板 | 最后注册的业务单例 |
| 13 | `MCPGameBridge` | `addons/godot_mcp/game_bridge/mcp_game_bridge.gd` | 编辑器调试桥 | 无 `*` 前缀，非业务 |

### 2.2 依赖与初始化约束

- `MemoryClass`、`PaSkill`、`MainMusic`、`Global`、`LocalCoop` 之间存在读取依赖；新增 Autoload 必须说明初始化顺序。
- `Global`、`PlayerData`、`BaseRoleProperties` 对 `LocalCoop` 使用 `get_node_or_null("/root/LocalCoop")` 探测，避免“声明在最后”导致的启动期空引用。
- `LocalCoop` 通过 `class_name` 反查 `BaseHero` / `BaseLevel`，用于槽位归属解析；这是当前双人模型的关键耦合点。
- 新代码访问角色状态时，应使用 `BaseObject` 暴露的 `PlayerData`、`RoleProp`、`PlayerInput`，或 `BaseRole` 暴露的 `PlayerData`、`RoleProp`。这些属性内部经 `LocalCoop` 路由，不能假定永远是 1P。

### 2.3 边界

13 个 Autoload 是历史结构，登记为遗留例外：

- `global.gd` 不得继续扩张为新的业务数据仓库；
- 新增 Autoload 必须评审生命周期、依赖、清理方式与替代方案；
- 能用场景节点、`Resource`、静态函数或 `class_name` 工具类解决的，不新增 Autoload；
- 新功能不得以“方便访问”为理由塞进全局单例。

---

## 3. 启动、场景流转与加载管线

### 3.1 场景流转

```mermaid
flowchart TD
    A["load_scene.tscn<br/>主场景 / 加载页"] --> B["main_menu.tscn<br/>主菜单"]
    B --> C["read_archive_interface.tscn<br/>存档列表"]
    C -->|"空存档 / 新建"| D["choose_player.tscn<br/>选角 / 双人配置"]
    C -->|"已有存档"| E["map_0.tscn<br/>世界地图"]
    D --> E
    E --> F["map_1 … map_9_1<br/>区域地图"]
    F --> G["level_info.tscn<br/>关卡信息弹窗"]
    G -->|"挑战"| A
    A -->|"预载完成，覆盖式切换"| H["level_*.tscn<br/>BaseLevel 子类"]
    H -->|"清空阶段并进入出口"| I["victory.tscn"]
    H -->|"角色死亡（双人须全灭）"| J["defeat.tscn"]
    I -->|"返回地图 / 自动重战"| F
    J -->|"返回地图 / 自动重战"| F
    F -->|"返回主菜单"| B
```

要点：

- 冷启动时 `Global.target_scene` 为空，加载页回落到 `main_menu.tscn`。
- 主菜单“开始游戏”打开存档列表；空档进入选角/双人配置，已有档直接载入并进入 `map_0.tscn`；选角完成后建立双人会话并进入 `map_0.tscn`。
- 地图按钮调用 `Global.add_level_info(...)` 打开 `level_info.tscn`；挑战时通过 `Global.change_scene(target_stage_path)` 进入加载页。
- 关卡胜利/失败后返回地图；自动战斗可重战当前关卡。

### 3.2 `Global.change_scene` 与加载页

`Global.change_scene(target, force_loading_screen=false)` 是规范场景切换入口：

1. 若目标是“退出存档”场景，结束存档会话；
2. 清理临时 UI、UI 运行时缓存与关卡资源缓存；
3. 若目标是已预载且缓存的 `res://Scene/level/*`（`level_hdzm.tscn` 除外），直接 `change_scene_to_packed`；
4. 否则写入 `Global.target_scene`，切换到 `load_scene.tscn`。

加载页 `Scene/other_scene/load_scene.gd` 负责：

- 窗口策略：可用屏幕小于 1600×1000 时进入全屏；
- Android 首启完整性校验（仅 Android 且存在平台单例时）；
- 构建预载清单：目标场景、角色/宠物/剑阵/法宝、首波怪物、必要背景与音效；关卡怪物与弹体场景来自构建期 `LevelPreloadCatalog`；
- 线程化预载与分阶段预热：角色运行时清单 → 角色专属特效 → 剑阵 → 法宝 → 战斗命中资源 → 宠物 → 关卡怪物；
- 覆盖式切换：先实例化新场景并挂到根节点，等待就绪，再释放旧场景，避免加载黑屏；
- 战斗加载时输出 VRAM 基线日志，供性能回归对照。

**遗留旁路**：`Script/level/hdzm.gd` 仍直接调用 `get_tree().change_scene_to_file(...)`，绕过缓存与清理；新代码不得再走旁路。

### 3.3 关卡进入判定

- `Global.add_level_info` 记录 `Global.current_level`，并按 `MainSet.set_data["LevelInfo"]` 决定显示信息弹窗还是直进；
- 三太子、四剑、二十八星宿、八仙尽伏等特殊副本强制显示信息或模式对话框；
- 挑战按钮先校验模式选择，再调用 `Global.change_scene`；
- 部分特殊关卡使用 `force_loading_screen=true`，确保走加载页与资源预热。

---

## 4. 对象模型与战斗运行时

### 4.1 继承关系

```mermaid
classDiagram
    direction LR
    class CharacterBody2D
    class Node2D
    class Node
    class Area2D
    class Control
    class Sprite2D
    class StaticBody2D
    class AnimatedSprite2D

    class BaseObject {
        +PlayerData
        +RoleProp
        +PlayerInput
        +_physics_process()
        +set_data()
        +get_hurt()
    }
    class BaseHero
    class BaseMonster
    class SummonBaseMonster
    class BaseLevel
    class BaseMagicWeapon
    class BaseBuff
    class BaseRole
    class BaseRoleHitBox
    class Stage
    class StageNode

    CharacterBody2D <|-- BaseObject
    BaseObject <|-- BaseHero
    BaseObject <|-- BaseMonster
    BaseMonster <|-- SummonBaseMonster
    Node2D <|-- BaseLevel
    Node2D <|-- BaseMagicWeapon
    Node <|-- BaseBuff
    Control <|-- BaseRole
    Area2D <|-- BaseRoleHitBox
    Sprite2D <|-- Stage
    StaticBody2D <|-- StageNode
    note for BaseHero "包含 Role1Hero … YutuHero 等角色子类"
    note for BaseMonster "区域怪物、Boss 与召唤物子类"
    note for BaseLevel "关卡运行器子类"
    note for BaseMagicWeapon "法宝运行时子类"
```

### 4.2 核心类职责

| 类 | 文件 | 职责 | 生命周期要点 |
|:---|:---|:---|:---|
| `BaseObject` | `Script/base/base_object.gd` | 所有战斗单位的基类（`CharacterBody2D`）；提供槽位感知的 `PlayerData` / `RoleProp` / `PlayerInput` | 只做 HP 夹取与基础字段重置；具体移动/攻击在子类 |
| `BaseHero` | `Script/base/base_hero.gd` | 玩家角色：移动、普攻、技能、无双、法宝、剑阵、坐骑、时装、自动战斗 | `_ready` 绑定 `RoleProp.source_player`；`_exit_tree` 清理；死亡触发复活或失败 |
| `BaseMonster` | `Script/base/base_monster.gd` | 怪物与 Boss：受击、击退、掉落、阶段保护、难度 | 由关卡按阶段实例化；死亡结算掉落并计数 |
| `SummonBaseMonster` | `Script/base/summon_base_monster.gd` | 召唤物基类 | 由技能/宠物生成，归属通过 meta 与槽位解析 |
| `BaseLevel` | `Script/base/base_through_level.gd` | 关卡运行器：4 阶段刷怪表、相机边界、出口判定、通关记账、宠物/2P 生成 | `_ready` 生成角色/HUD/相机；`_physics_process` 推进阶段与出口 |
| `BaseMagicWeapon` | `Script/base/base_magic_weapon.gd` | 法宝运行时：跟随角色、MP 消耗、CD、`use_skill` 模板方法 | 由角色装备/法宝系统实例化 |
| `BaseBuff` | `Script/base/base_buff.gd` | Buff 载体：时长、减益、免疫、特效 | 首次处理时绑定目标；非战斗目标自释放 |
| `BaseRole` | `Script/base/base_role.gd` | **HUD**：头像、HP/MP/经验、无双槽、技能 CD、Buff、宠物面板 | `Control`，不是战斗体；由 HUD 容器实例化 |
| `BaseRoleHitBox` | `Script/base/base_role_hit_box.gd` | 纯标记类，用于识别“角色攻击判定” | 无成员；怪物受击侧据此判定来源 |
| `Stage` / `StageNode` | `Script/level/stage.gd`、`xyd_stage.gd` | 关卡台座/触发标记 | 由关卡场景或关卡脚本生成 |
| `SpecialAffect` | `Script/base/special_affect.gd` | 一次性特效播放器 | 无 `class_name`；播放后自释放，由 slim 场景引用 |

### 4.3 关卡状态机

`BaseLevel` 的默认契约：

- `monster_group` 与 `monster_position_x/y` 按 `stage_1`…`stage_4` 组织；
- `_stage_count()`、`_stage_trigger_x()`、`_screen_starts()`、`_screen_rights()` 提供给夹具与子类覆写；
- 角色越过触发点推进 `current_stage`，按阶段实例化怪物；
- 当前阶段刷怪表清空且场上无存活阶段怪物时开放出口；
- 通关调用 `add_tg(...)` 记录主线/副本进度；
- 自动战斗可按 `AutoBattleRetry` 存盘并重战。

`BaseLevel` 同时负责 2P 生成、活动宠物生成与关卡资源预热请求。新关卡应继承 `BaseLevel` 并复用阶段契约，不要复制一套独立的刷怪循环。

### 4.4 命中与归属

- 角色攻击 → 怪物受击区域；怪物攻击 → 角色受击区域；法宝使用独立层；
- 伤害来源通过 `LocalCoop` 的槽位解析确定实际出手者，不能默认取怪物当前 `get_player()`（通常为 1P）；
- 技能、弹道、法宝、召唤物与特殊怪物需要显式绑定/恢复伤害来源上下文；
- 双人模式下 P2 的无双、伤害统计、吸血与 Buff 归属必须与 P1 分离。

---

## 5. 数据与持久化

### 5.1 数据分层

| 层 | 载体 | 说明 |
|:---|:---|:---|
| 单局档案 | `PlayerData.player_data` | 巨型中文键字典：背包、装备、道具、等级经验、技能、宠物、坐骑、万灵、炼体、进度等 |
| 角色运行时属性 | `BaseRoleProperties` | `roleprop` 最终值 + `baseroleprop` 等级经验 + 各槽位加成 + `pasl_prop` |
| 会话设置 | `MainSet.set_data` | 音乐、画质、剧情跳过、自动战斗、难度、刷怪速度/数量、主菜单背景等 |
| 持久化 | `MemoryClass` | `user://MyAr_<n>.json` 加密档、`.bak`、`.tmp`、后台线程、`user://MainGame.json` 设置、`user://.save_key` 稳定密钥 |
| 契约常量 | `DataKeys` | 字典键的统一常量入口与安全访问器 |

### 5.2 `PlayerDataStore`

- `player_data` 是当前槽位档案的唯一内存副本（1P 由 `PlayerData` 持有，2P 由 `LocalCoop.secondary_data` 持有）；
- `initialized_data` 提供默认档；
- `ensure_*` 函数族在载入时补全缺失字段、规范化数据、清理已退役内容；
- `PlayerData` 的 `RoleProp` getter 经 `LocalCoop.props_for(self)` 解析，因此同一脚本可服务 1P/2P 两个实例；
- 新增字段应加入默认档与 `ensure_*` 补全逻辑；新结构化数据优先使用 `Resource` / `.tres`，不继续扩大裸字典。

### 5.3 存档读写

- `MemoryClass.load_game`：读取加密档 → 取 `.bak` 备份 → 合并到 `player_data` → 执行 `ensure_*` / 有限的数据规范化与退役清理 → 载入双人档案；
- `safe_write_archive`：写入 `.tmp` → 读取校验 → 备份旧档到 `.bak` → 原子替换；
- 后台保存使用线程队列，退出前 `flush_pending_saves`；
- 稳定密钥保存在 `user://.save_key`，兼容读取会依次尝试稳定密钥与历史密钥；
- **不建立按版本号递增的通用迁移链**：旧 `user://` 目录、旧任务键与旧配置不迁移；缺失的新字段用默认值补全，非法/不可读档明确失败，不回退到“猜测结构”；
- `load_game` 中允许存在**有限、幂等**的字段规范化/退役清理（例如道具存储迁移、已退役装备清理），但它们不是通用版本迁移框架，新增迁移必须评估幂等性与失败语义。

### 5.4 本地双人数据模型

`LocalCoop` 不复制 Autoload，而是为 2P 创建独立实例：

- `secondary_data`：`PlayerDataStore` 实例，挂 `coop_slot=2`；
- `secondary_props`：`BaseRoleProperties` 实例；
- `secondary_passives`：被动技能实例；
- `inputs`：`CoopInput` 数组，自动注册 `p2_*` 输入动作；
- 存档格式：`player_data["本地双人"] = {版本, 启用, 2P: profile}`；
- 共享项：装备/道具/消耗品/宠物背包、被动技能、主线剑阵、灵魂、炼体、万灵图录；
- 归属解析：meta → 祖先 `coop_slot` → `owner_hero()` 反射 → 脚本路径前缀 → 默认 1；
- 面板：2P 打开背包/技能/宠物/法宝/坐骑时，临时交换 1P/2P 数据视图，关闭后恢复；
- 死亡判定：双人模式下只有全部玩家死亡才进入 `defeat`。

**新代码约束**：不得直接假定 `/root/PlayerData` 或 `/root/RoleProp` 是当前操作者；使用 `BaseObject` / `BaseRole` 的槽位感知属性，或显式调用 `LocalCoop.data_for` / `props_for` / `input_for`。

---

## 6. 资源层与视觉资产契约

> 完整目标架构、默认选型与迁移边界见 [`../standards/target_architecture_contract.md`](../standards/target_architecture_contract.md)。本节只记录当前运行时架构与已落地状态。

### 6.1 三层契约

| 层 | 职责 | 允许的产物 |
|:---|:---|:---|
| **构建层** | 确定性生成、schema/UID/依赖闭包检查 | 原生 `.tres`、独立发布依赖清单；导入配置 `.import` 与缓存分开 |
| **资源层** | 共享只读视觉数据与预热定义 | `SpriteFrames`、`Texture2D` / `AtlasTexture`、`FrameSequence`、`AtlasMetadata`、Spine 资源 |
| **运行时层** | 用 Godot 原生或受控第三方节点播放资源 | `AnimatedSprite2D`、`Sprite2D` / `TextureRect`、`SpineSprite`、流式帧播放器 |

三层之间只通过资源引用和明确 API 交互。运行时不得反向解析源文件，也不得根据目录猜测资源。

新增、重命名或恢复资源必须：

- 外部图片等源资源维护 `.import` 导入配置，`.godot/imported` 为可重建缓存；
- 原生 `.tres/.tscn` 使用资源头 UID；脚本/着色器按引擎规则维护伴生 `.uid`，不伪造 `.import`；
- 生成 FrameSequence/Catalog 已写确定性 UID，并做碰撞检查；
- Godot 导入后再验证实际加载，不能只复制导入缓存。

### 6.2 默认选型

| 内容类型 | 默认方案 | 运行时节点 |
|:---|:---|:---|
| 普通逐帧内容 | 构建期 `SpriteFrames` | `AnimatedSprite2D`，必要时配合 `AnimationPlayer` |
| 静态图、UI、单张特效 | `Texture2D` / `AtlasTexture` | `Sprite2D` / `TextureRect` |
| 现有 Spine 内容 | Spine 资源 | `SpineSprite`；新增原生骨骼可按目标契约评审 |
| 按需驻留序列 | 已落地 `FrameSequence` + 流式播放器 | `StreamedPngEffect` |
| 图集帧数据源 | `AtlasMetadata.tres` | 已有消费者仍含运行时转换，属于待收口边界 |

**合法例外**：

| 场景 | 处理 |
|:---|:---|
| 静态图像/UI | 直接 `Texture2D`，无需 SpriteFrames |
| 骨骼动画 | 保留 Spine，不转换 |
| 经实测超大、频繁复用的帧序列 | 使用 `FrameSequence` + 流式播放器，并记录显存/加载依据 |
| 舞台/关卡背景大图 | 直接纹理或 Streaming，不强制 SpriteFrames |

**不允许的“统一”**：

- 不把 Spine 动画烘焙成 SpriteFrames；
- 不把静态 PNG/UI 强行包装成 SpriteFrames；
- 不把所有超大序列一次性装入 SpriteFrames；
- 不新增万能播放器，把帧动画、Spine、流式加载混在同一个类中；
- 不为了兼容旧资产同时保留两套加载路径。

### 6.3 当前实现状态

已落地：

- `RoleRuntimeCatalog` + `RoleRuntimeResourceManifest`：静态预加载角色清单；资源缺失可在解析阶段暴露，清单查询断言仅是 debug 辅助，不冒充 release 失败处理；
- `AtlasMetadata` + `AtlasMetadataStore`：`manifest.json` 构建期生成 `metadata.tres`，运行时只读；`AtlasMetadataStore` 只接受 `metadata.tres`；
- 哪吒官方部件与 BiLuoTian / LeiTingJieZhen 重技能帧已迁移到构建期 `SpriteFrames`；
- Spine 资源保持 `.atlas` / `.spine-json` 由 Spine 运行时加载，不转 SpriteFrames。
- `FrameSequenceStore` 在接纳 Catalog 条目时校验 schema；`StreamedPngEffect` 再校验注入资源，错误时发出 `failed` 并拒绝播放；
- `FrameSequence` 的 `asset_id` 是内容身份，`default_fps/default_loop/default_hold_last_frame/default_prefetch_frames` 只是默认播放值；`FrameSequenceCatalog` 以 `asset_id` 为键；
- `StreamedPngEffect.configure_playback()` 允许实例覆盖 fps/loop/hold/prefetch，未设置时继承资源默认值；同一资产可被不同策略复用，不再为策略生成重复资源；
- `FrameSequenceStore.directory_asset_id()` 固定 `dir/<Art 相对路径>` 映射，批量目录资产在构建期与运行时使用同一确定性规则；
- `FrameTextureRequests` 对纹理请求去重并持有租约，播放器销毁后跨帧取回未完成请求结果；进程关闭由 `Global._exit_tree` 做最终收尾；
- `prewarm_sequence` 预热真实纹理并保持引用，关卡缓存清理释放预热租约；Catalog 元数据加载不再称为纹理预热；
- `WutaiMinghaiProjectile` 主视觉与 impact 显式声明 SpriteFrames/FrameSequence/NONE；FrameSequence 只接受 `frame_asset_id`/`impact_frame_asset_id`，声明错误不改走其它后端；
- `LevelPreloadCatalog` + `LevelPreloadStore`：关卡首波、完整怪物 ID 集合、怪物弹体场景、别名场景覆盖、动态纹理文件与额外场景由构建期生成；加载页不在运行时解析 `.gd` / `.tscn` 源文本，也不再扫描动态纹理目录或做 ID→ID 映射。

仍然存在（遗留）：

- 13-2B 已完成 54 个怪物脚本的消费者切换；运行时建帧仍有 **19** 个文件（怪物 **9** 个，其余 10 个非怪物），由
  `scripts/runtime_frames_audit.py` 与 `scripts/runtime_frames_allowlist.json`
  守恒：新增未登记文件、失效条目或空理由均失败，迁移后必须同步删除条目。
  怪物域已评审保留：
  - 动态配置：`east_continent_monster`（关卡配置 merge，仅剩标准动作重命名）；
  - 几何/图集裁剪：`three_prince_boss`、`eight_immortals_boss`、`weiyang_palace_boss` 符号层、`pet_tiger_boss_base`；
  - 单序列/子集：`nanhai_projectile`、`monster_130`/`monster_212`/`monster_215`（`play` 子集 + 逐帧 duration）；
  - 占位/兜底：`monster_bullet`（null 计时帧）、`tao_wu_boss`（单图占位）；
  - 资源缺失回退：`three_prince_bullet`；
  非怪物 **10** 个按域拆批（角色特效、法宝、宠物、关卡、工具），不纳入 13-2 怪物域：
  - `pet_neat_bullet`：`pet_neat_4_bullet_3` 需运行时蓝底抠图；构建期迁移需 22 张去底重复 PNG 与图像编解码步骤，收益低于素材重复成本，保留；
  - `lyfb_awaken_effect`：按效果数据 `frame_rects` 做 `AtlasTexture` 裁剪；
  - `ne_zha_yin_yang_effect`：图集裁剪/连续帧组合，区域由剑型与特效参数决定；
  - `level_59`：固定 `STONE_TEXTURES` 数组建帧，无路径扫描或逐帧 IO；
  - `user_key`：调试工具 UI 的固定图标序列，不进入游戏运行路径；
  - 剩余 5 个法宝见上方裁定。

### 6.5 13-2B 冻结裁定（怪物域 9 个）

判定标准：① 是否仍存在逐帧 PNG 路径拼接/扫描或磁盘 IO；② 帧是否已来自构建期资源；③ 是否依赖运行时不可静态化的配置/裁剪数据；④ 迁移收益是否大于双源漂移风险。9 个怪物文件的裁定结果：

| 文件 | 保留原因 | 风险/收益判断 |
|:---|:---|:---|
| `east_continent_monster` | 关卡 `get_level_monster_config` 可 merge，且存在 `Fly_wait/Fly` 动态键；帧已来自构建期资源，仅剩动作名重命名 | 构建期无法穷举关卡覆盖，双源漂移风险高 |
| `eight_immortals_boss` | 运行时 `AtlasTexture` 裁剪（monster166/168 头像） | 裁剪区域由运行时数据决定，非路径 IO |
| `monster_bullet` | 标准帧缺失时的 `null` 计时帧占位 | 无逐帧 IO；删除会让缺失资源时无时钟 |
| `nanhai_projectile` | 同一模型多动作均需 `play` 名，单一资源无法同时承载 | 单序列裁剪一行，迁移需改全部弹体配置 |
| `pet_tiger_boss_base` | 图集行列裁剪（虎宠 stage/action） | 裁剪行列由 stage 数据决定 |
| `tao_wu_boss` | 标准资源异常时单图兜底占位 | 不拼路径；保留防崩溃，不扩大 |
| `three_prince_boss` | 运行时 `AtlasTexture` 裁剪（部件/武器图层） | 裁剪区域由运行时数据决定 |
| `three_prince_bullet` | 有资源配置走资源，缺失才逐帧回退 | 弹体配置并非全部有图集，回退是最后一道 |
| `weiyang_palace_boss` | 符号层单序列裁剪，播放名与源序列不同 | 裁剪只影响符号层，不影响主体 |

结论：9 个文件均**不再包含逐帧 PNG 路径扫描或高频 IO**，帧已来自构建期资源；继续迁移需要把运行时裁剪/关卡覆盖数据复制到构建期，收益低于维护双源的成本。入口由 `runtime_frames_audit.py` 与 allowlist 冻结，新增扩张立即失败。
  剩余法宝已评审保留：`main_sword_array_weapon`（图集 metadata 建帧）、
  `eight_immortal_magic_weapon`/`qlsword`/`taiji_bagua`（图集裁剪）、
  `qing_lian`（调用方传入纹理数组）；
- `AtlasMetadata.data` 仍是 `Dictionary`，属于过渡类型边界。

### 6.4 构建期转换器

| 输入 | 工具 | 输出 | 校验 |
|:---|:---|:---|:---|
| 图集 `manifest.json` | `scripts/convert_atlas_metadata.py` | `AtlasMetadata.tres` | `--check` 逐字比较 + `source_frames` 帧数；`--self-test` 负向样本 |
| 哪吒 `preview_<layer>.json` + 图集 PNG | `scripts/convert_nezha_preview_frames.py` | 哪吒专用 `SpriteFrames.tres` | `--check` 存在性 + 内容一致性 + 源 schema |
| 连续编号 PNG 序列 | `scripts/convert_numbered_frames.py` | `SpriteFrames.tres` | `--all --check` 存在且未过期；覆盖 BiLuoTian/LeiTingJieZhen/3077 tornado、212/215/130 弹体、东胜神洲 loose 特效、两个法宝与宠物弹体 |
| 固定/按需驻留帧序列 | `scripts/convert_frame_sequences.py` | `FrameSequence.tres`（可读 slug 命名）+ Catalog + 发布依赖 JSON | `--check` 内容、schema、`asset_id` 唯一、单目录单序列、UID、路径闭包与陈旧输出；`--export-preset` 仅配置级覆盖 |
| 动作视图（`play` 子集或连续 PNG + duration） | `scripts/convert_monster_action_views.py` | `monster_130/212/215/*_action_frames.tres`、宠物寅虎 stage1/2 | `--check` 逐字比较；帧索引、逐帧 duration、loop/speed |
| 流沙河 `ACTIONS` 动作表 | `scripts/convert_liu_sha_frames.py` | 按 boss_kind 拆分的 `liu_sha_*_frames.tres` | `--check` 逐字比较；逐帧 duration 与确定性 UID |
| 怪物 `AtlasMetadata.sequences` + 动作映射 | `scripts/convert_monster_frames.py` | 既有 `Art/monster/**/*_frames.tres`（sequence + 动作别名） | `--check` 动画名集合、帧数、页路径闭包、`region`/`margin`、PNG 边界、确定性 UID 与全局 UID 冲突；`--all` 追加动作别名并修正 loop；`--rewrite` 只补 UID 头 |
| Spine `.atlas` + `.spine-json` | Spine 运行时导入 | Spine 资源 | 运行时 `loaded` 探针 |
| 关卡脚本刷怪表（`monster_group`、`"monster":`、`preload_level_monster_*`）、怪物脚本弹体名与 `monster_dynamic_paths.json` | `scripts/convert_level_preload_catalog.py` | `source/Script/data/level_preload_catalog.tres`（`LevelPreloadEntry`、弹体表、别名场景、动态纹理、额外场景）+ `source/Script/data/level_preload_export_dependencies.json` | `--check` 逐字比较 Catalog 与依赖清单；无法静态解析的条目输出到 stderr，由关卡自身预载；动态路径缺失/悬空直接失败 |

关卡预载数据契约：

- `first_wave_ids` 只包含 `stage_1`，用于加载页首波优先级；
- `monster_ids` 是完整覆盖集合，必须包含所有阶段（含 `stage_5` 及以后）与脚本内引用的怪物 ID；
- 不建立 `stage_2`…`stage_N` 的静态优先级分层：加载页在切换场景前等待 `monster_ids` 预载完成，关卡运行期由 `_request_stage_resource_preload(current_stage + 1)` 前向预取；
- 生成器拒绝 `stage>=5` 出生点怪物未进入 `monster_ids` 的输出。

规则：

- 通用输入格式使用通用工具；角色专用 schema 可使用角色专用适配器，但名称必须反映真实作用域；
- 转换器必须支持 `--check`，能验证内容时验证内容一致性；
- 构建产物必须可重复生成，生成顺序不得依赖运行时时序；
- 新增运行时目录扫描、运行时 manifest 解析或“文件不存在就回退旧路径”属于违规。

### 6.5 缓存、预热与对象池

`Global` 维护四类缓存：

- `_resource_cache`：`PackedScene` 与其他资源；
- `_sprite_frames_cache`：`SpriteFrames`；
- `_audio_cache`：`AudioStream`；
- `_texture_cache`：`Texture2D`。

配套机制：

- 加载页线程化预载，移动端并发槽位 2、桌面 4；
- 角色/宠物/法宝/怪物/战斗命中资源分阶段预热；
- 关卡级缓存按轨迹精确失效（`clear_level_resource_cache`），战斗缓存按前缀清理；
- 伤害数字、受击特效、音效播放器等使用有限容量对象池（具体上限见 `global.gd` 常量）；
- UI 场景使用 `CACHE_MODE_IGNORE_DEEP`，避免 UI 资源长期占用缓存；
- 战斗加载输出 `[Battle VRAM]` 日志，用于对比显存增量。

**新代码约束**：

- 不在 `_process` / `_physics_process` 中执行磁盘 IO、运行时 JSON 解析或高频 `load()`；
- 有限帧动画不得在首次释放技能时现场构建；
- 资源预热必须有明确的所有者与释放路径；
- 角色、怪物、特效的资源选择由 Manifest、Catalog 或 typed Resource 驱动。

### 6.6 资源迁移状态

已完成：

- 角色 1~7 的运行资源清单与静态 `RoleRuntimeCatalog`；
- 哪吒装备层构建期 `SpriteFrames`；
- BiLuoTian cast/hit 与 LeiTingJieZhen formation/lightning 构建期 `SpriteFrames`；
- `AtlasMetadata` 构建期转换与运行时只读加载；
- 角色 4/5 重型帧的构建期化与预热清单收敛；
- `FrameSequence`、Catalog、Store 与转换器已落地，序列数量以构建检查输出为准；消费者只注入 `sequence`，旧数组和目录扫描已删除；
- 身份模型 v2：序列按 `asset_id` 登记，播放策略改为实例覆盖；转换器按 `asset_id` 生成可读文件名，并清理自己拥有的陈旧输出；
- 五台 3082/3080/3081 删除流式回退，只使用构建期 `SpriteFrames`；
- 关卡发布依赖清单 `source/Script/data/level_preload_export_dependencies.json` 与资产侧 `source/Art/frame_sequences/frame_sequence_export_dependencies.json` 由 `frame_sequence_pack_probe.py` 合并验证；PCK 内 **4,100 条**依赖全部可达；
- 发布依赖清单按来源归属：`Art/frame_sequences/frame_sequence_export_dependencies.json` 由 FrameSequence Catalog 与图集页派生，属于素材侧构建产物，随私人素材仓版本化；`Script/data/level_preload_export_dependencies.json` 由公共关卡/怪物脚本与 `scripts/monster_dynamic_paths.json` 派生，属于代码侧构建产物，随公共仓版本化。两者都不在运行时加载，只在发布前 PCK 闭包验证时读取。
- 动态怪物纹理/场景表与 `MONSTER_SCENE_ALIASES` 已从 `global.gd` 迁出：别名与动态来源由 `scripts/monster_dynamic_paths.json` 在构建期展开进 Catalog 与依赖清单，运行时只读 Catalog。
- `duplicate_texture_aliases.gd` 已从 2,313 条收敛到 **360 条**；删除 932 条悬空映射与 1,021 条全量回归未命中的 Monster 域条目，保留 86 条静态引用与 274 条 UI/法宝/坐骑域条目。`TEXTURE_ALIASES.resolve` 只在 `Global._resolve_texture_path()` 一处调用；debug 下设置 `BHYH_TEXTURE_ALIAS_HITS_DIR` 时按进程写入命中统计。

待迁移：

| 项目 | 目标 |
|:---|:---|
| 魔法武器剩余 5 个运行时建帧 | 与 13-4 的编号帧/别名收敛合并评估；固定裁剪或调用方纹理数组保留为登记例外 |
| 非怪物角色特效/宠物/关卡运行时建帧 | 按域拆批；`level_59`、`user_key` 为合法例外 |
| `AtlasMetadata.data` 无类型字典 | 逐步提供 typed accessor 或 typed 子资源 |
| Spine 平台库 | 按目标平台补齐并验证 |

迁移顺序：固定目录、四剑阵技能、星座动态 body、星座技能与五台弹道非 swf 序列已完成 → 怪物帧消费者与关卡发布依赖已构建期化 → 下一批评估剩余法宝/角色特效运行时建帧 → 再收敛 `AtlasMetadata` 类型边界 → 最后处理平台与第三方运行库。

---

## 7. UI、HUD 与输入

### 7.1 UI 组织

- 战斗 HUD 容器为 `Scene/level/role_information.tscn` / `Script/level/role_information.gd`，加入 `RoleInformation` 组；
- HUD 由两个 `BaseRole` 实例组成（P1 / P2），负责 HP/MP/经验、无双、技能 CD、Buff、宠物；
- 桌面布局：底部居中 5 按钮（54×54，间距 5，底边距 4），左下无双圆盘与 Y/U/I/O/L 技能槽；双人 P2 镜像贴右；
- 移动端保留右上角/触控布局，使用虚拟摇杆与自动隐藏策略；
- 场景加载完成后调用 `reveal_after_scene_loaded()`，避免覆盖式切换期间 HUD 提前显示。

弹窗与面板：

- 由 `Global.add_*` 工厂延迟实例化，挂到 `Global.windows` 或 `GlobalUiPopupLayer`；
- `Global.windows` 由当前场景设置；`LocalCoop` 打开 2P 面板时临时替换并恢复；
- 确认框统一通过 `Signals.choose_pressed` 回调；
- 新 UI 优先场景组合、`@export` 注入与 `%UniqueName`，不新增跨场景深层 `get_node()`。

### 7.2 输入

- 输入动作集中定义于 `project.godot`，数量以实际配置为准；
- 双人输入由 `LocalCoop._ready()` 动态注册 `p2_*`，键位表见 `P2_KEYS`；
- 业务代码通过 `CoopInput`（`PlayerInput` 属性）读取，`slot == 2` 时自动加 `p2_` 前缀；
- 代码不得散落裸按键字符串；新增动作必须写入 `project.godot` 并说明平台影响。

### 7.3 物理层

`project.godot` 使用具名 2D 物理层：

| 层 | 名称 | 层 | 名称 |
|:---:|:---|:---:|:---|
| 1 | 环境 | 10 | 陷阱检测 |
| 2 | 角色 | 11 | 法宝 |
| 3 | 怪物 | 12 | 角色攻击检测怪物受伤 |
| 4 | 吸血 | 13 | 蝙蝠石像检测陷阱 |
| 5 | 出口 | 14 | 牛魔四专用 |
| 6 | 台阶 | 15 | 汪汪检测地面 |
| 7 | 火魔斩检测范围 | 16 | 汪汪检测墙壁 |
| 8 | 怪物攻击范围检测玩家受伤；蝙蝠吸血 | 17 | 汪汪检测可跳跃墙壁 |
| 9 | 陷阱 |  |  |

新代码必须使用具名层或集中常量，不新增无注释的裸整数掩码。现有基础场景的 mask 分配属于遗留实现，重构前先逐场景核对。

---

## 8. 子系统索引

| 子系统 | 位置 | 职责 | 代表文件 |
|:---|:---|:---|:---|
| 角色 | `Script/hero/`、`Scene/hero/` | `BaseHero` 子类、角色专属特效、时装/翅膀/剑阵 | `role1.gd`、`role_2.gd`、`ne_zha_hero.gd`、`yutu_hero.gd` |
| 怪物 | `Script/monster/` | `BaseMonster` 子类、Boss、召唤物、区域怪物 | `constellation_boss.gd`、`east_continent_monster.gd`、`sword_boss_base.gd` |
| 关卡 | `Script/level/`、`Scene/level/` | `BaseLevel` 子类、HUD、相机、特殊副本 | `level_1.gd`、`level_tzsijian.gd`、`level_zhen_yao_tower.gd`、`victory.gd` |
| 法宝 | `Script/magic_weapon/` | `BaseMagicWeapon` 子类、场景映射、技能效果 | `main_sword_array_weapon.gd`、`mirror.gd`、`taiji_bagua.gd` |
| 技能 | `Script/skill/` | 主动技能、学习、键位、觉醒 | `zd_skill.gd`、`learn_skill.gd`、`skill_key_set.gd` |
| 宠物 | `Script/pet/`、`Scene/pet/` | 多类宠物、进化、技能、宠物背包 | `pet_interface.gd`、`pet_*_summon_base.gd` |
| 坐骑 | `Script/mount/` | 坐骑运行时、图鉴、技能效果 | `mount_runtime.gd`、`mount_catalog.gd` |
| 丹药 | `Script/pellet/` | 丹药属性缓存与消耗 | `basic_pellet.gd` |
| 锻造 | `Script/ldl/` | 强化、合成、镶嵌、分解、打造、神铸、淬骨 | `ldl.gd`、`strength.gd`、`divine_forge.gd` |
| 背包 | `Script/back_pack/`、`Script/backpack.gd` | 背包、装备、售卖、法宝信息 | `main_backpack.gd`、`magic_weapon_infor.gd` |
| 地图/主菜单 | `Script/main_menu/` | 世界地图、区域地图、设置、公告、坐骑面板 | `main_menu.gd`、`map_0.gd`…`map_9_1.gd` |
| 存档界面 | `Script/archive_interface/` | 存档列表、云存档、删档 | `read_archive_interface.gd` |
| 任务 | `Script/task/` | 任务面板与奖励 | `basic_task.gd`、`task_reward.gd` |
| 商店 | `Script/shop/` | 商店、神秘商店、购买确认 | `shop.gd`、`mystery_shop.gd` |
| 伤害文本 | `Script/hittext/` | 伤害数字/文字/Miss，走对象池 | `damage_number.gd`、`damage_text.gd` |
| 子弹 | `Script/bullet/`、`Scene/bullet/` | 直线/追踪弹与 slim 场景 | `fly_bullet.gd`、`chase_bullet.gd` |
| 音频 | `Script/all_sound/`、`main_music.gd` | BGM 单实例、命中音效池 | `bgm.gd`、`monster_be_hit.gd` |
| 特殊玩法 | `Script/other_menu/`、`Scene/other_scene/` | 幻化、换装、阵法、星宿、玲珑宝塔 | `transmogrified.gd`、`zhen_fa_ui.gd` |
| 工具/输入 | `Script/tools/` | 虚拟摇杆、按键设置、场景 viewport | `set_com.gd`、`user_key.gd` |

---

## 9. 遗留结构与现代化分界

### 9.1 遗留例外（不得继续扩张）

| 项目 | 现状 | 约束 |
|:---|:---|:---|
| 13 个 Autoload、`Global` 上帝对象 | 大型遗留单例，承担场景、UI、缓存、池、预载与业务判定 | 新功能不得继续堆积；拆分为独立立项 |
| 中文裸字典键业务数据 | `player_data` / `initialized_data` 大量中文键 | 新增键必须走 `DataKeys`；新结构化数据优先 Resource |
| 脚本内静态数据表 | `level_info`、`all_equipment_data`、怪物路径表 | 新增数据不复制此模式 |
| 运行时 `SpriteFrames.new()` | 多个脚本仍存在运行时建帧 | 有限帧改为构建期资源；超大序列走目标流式方案 |
| 场景切换旁路 | `hdzm.gd` 直接 `change_scene_to_file` | 新代码只走 `Global.change_scene` |
| 按硬编码节点名清理 UI | `Global.cleanup_transient_ui` | 新增 UI 必须注册/释放自身资源 |
| `AtlasMetadata.data: Dictionary` | 图集元数据弱类型 | 逐步提供 typed accessor，不扩大无类型面 |
| 深层 `get_node()` / 绝对路径 | 存量场景与脚本 | 新代码禁止；重构时同步清理 |

> 已登记在 [`missing_assets_registry.md`](../standards/missing_assets_registry.md) 的缺失资产回退（文本回退、atlas manifest 回退）属于**历史遗留例外**，不是新增回退的依据；资源恢复后必须移除对应回退并重新验收。

### 9.2 已现代化（新代码应复用）

| 模块 | 机制 |
|:---|:---|
| 角色运行资源清单 | `RoleRuntimeCatalog` + `RoleRuntimeResourceManifest`，`preload` 静态注册，缺失即失败 |
| 图集元数据 | `AtlasMetadata` + `AtlasMetadataStore`，构建期生成、运行时只读 |
| 字典键契约 | `DataKeys` 命名空间与安全访问器 |
| 构建期动画资源 | `convert_numbered_frames.py`、`convert_frame_sequences.py`、`convert_monster_frames.py`、`convert_nezha_preview_frames.py` |
| 流式帧序列 | `FrameSequence` + `FrameSequenceCatalog` + `FrameSequenceStore`，构建期生成、运行时只读 |
| 关卡预载清单 | `LevelPreloadCatalog` + `LevelPreloadStore`，构建期从关卡脚本生成，运行时只读 |
| 双人会话 | `LocalCoop` 独立数据/属性/输入实例与槽位路由 |
| 资源加载 | 四类缓存、线程预载、精确失效、对象池 |
| 场景切换 | 加载页预载 + 覆盖式切换 + VRAM 观测 |
| 存档 | 加密 JSON、`.tmp`/`.bak` 原子写、后台保存、稳定密钥 |
| 质量门禁 | `check_all.py` 八维 + 运行期夹具，详见验收文档 |

### 9.3 文档与代码的已知差异

以下差异在写文档或验收时必须显式承认，不能按旧文档宣称：

1. **`FrameSequence` 已落地**：类型、Catalog、转换器、固定目录、四剑阵技能、星座动态 body、星座技能与五台弹道非 swf 序列均已迁移；`StreamedPngEffect` 只消费 `FrameSequence`。资产身份为 `asset_id`，播放策略由实例覆盖，不再是复合 key。
2. **Autoload 数量**：共 13 个注册项，其中 12 个是业务单例，`MCPGameBridge` 是调试桥；说“13 个业务 Autoload”不准确。
3. **门禁维度**：`check_all.py` 当前是八维；历史记录中的“七维门禁”是 `--skip-engine`（或 `--fast`）口径。
4. **双人探针**：用例清单由 `coop_probe_runner.py` 维护；历史文档中的旧基线不代表当前用例数量。
5. **规模数字**：具体规模以 [`status.md`](status.md) 的当前快照为准；本文不复制脚本、场景与资源数量。
6. **渲染后端**：`project.godot` 默认 `mobile`、Web `forward_plus`；以工程配置为准，不要沿用旧文档中的渲染后端名称。

---

## 10. 架构变更流程

1. 先修改本文与相关 `docs/standards/`，明确适用范围、约束强度与退出计划；
2. 架构级、跨模块、长期有效的决定写入 [`../decisions/`](../decisions/README.md)；已接受结论不直接改写，变更通过新 ADR 记录；
3. 再修改代码、场景与资源；
4. 运行 [`acceptance.md`](acceptance.md) 中对应档位的门禁；
5. 更新 [`status.md`](status.md) 的验证记录与已知边界；
6. 禁止用新的兼容分支、回退分支或双加载路径绕过契约；
7. 大规模迁移必须单独立项，不混入普通功能提交。

---

## 11. 关联文档

- [`acceptance.md`](acceptance.md)：验收分层、门禁命令、阈值与变更矩阵
- [`status.md`](status.md)：版本、规模与验证状态单一事实源
- [`../decisions/README.md`](../decisions/README.md)：已做出的架构决策记录（ADR）
- [`../audit/README.md`](../audit/README.md)：人工代码质量审计模板与报告
- [`../standards/godot_design_standard.md`](../standards/godot_design_standard.md)：场景、Resource、Autoload 与项目结构规范
- [`../standards/naming_standard.md`](../standards/naming_standard.md)：命名与契约白皮书
- [`../standards/naming_whitelist.md`](../standards/naming_whitelist.md)：机器导出与数字 ID 冻结登记
- [`../standards/spriteframes_generation_policy.md`](../standards/spriteframes_generation_policy.md)：SpriteFrames 生成策略
- [`../standards/missing_assets_registry.md`](../standards/missing_assets_registry.md)：缺失资产与恢复台账
- [`../guides/migration_playbook.md`](../guides/migration_playbook.md)：版本迁移方法与红线
- [`../../scripts/README.md`](../../scripts/README.md)：门禁、审计与回归工具索引
