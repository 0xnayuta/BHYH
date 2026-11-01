# 关卡布局数据契约

> **定位**：定义「关卡结构化布局」在 BHYH 侧的数据载体、字段语义、构建期生成与运行时访问方式。Phase 30-1 已实施 `level_48` 试点；Phase 30-2 已接入原始 ZMWS 驱动器与外部怪物映射；30-3 收口完成：69 个脚本迁出布局（20 单屏 + 13 多阶段 + 36 个最小长度截断），6 个空数据表删除，10 个动态/非连续脚本登记例外；30-4 见 [`roadmap.md`](../roadmap/roadmap.md)。
> **决策依据**：[ADR-023](../decisions/ADR-023-level-layout-data-contract.md)（本契约的架构决策）、[ADR-006](../decisions/ADR-006-resource-first-data-and-data-keys.md)（Resource 优先）、[ADR-005](../decisions/ADR-005-no-compatibility-or-fallback-layers.md)（禁止兼容/回退层）。
> **范围**：关卡的结构化数据（出生点、分屏、刷怪触发与刷怪点、出口）。**不含**渲染层（已在关卡 `.tscn` 的 `Parallax2D`/`Sprite2D`）、碰撞层（已生成 `ZMWS_Ground` 静态节点）、战斗数值（走 `ZmwsConfig`）。

---

## 1. 术语

| 术语 | 含义 |
|:---|:---|
| 布局资源 | `LevelLayoutEntry` 类型的 `.tres`，一关一份；Phase 30-1 试点为 `level_48` |
| 阶段（stage） | 一次「锁屏 + 挡板 + 刷怪」的战斗单元；对应 ZMWS 的 `screen[N]` |
| 刷怪点（spawn point） | 一个具体的怪物出生位置与参数；对应 ZMWS `manCreater[<id>]` |
| 触发区（trigger） | 玩家进入后改变关卡状态的矩形；分「屏幕触发」与「刷怪触发」两类 |
| 挡板（wall） | 可开合的静态碰撞体；对应 ZMWS 的 `triggerWall` / `endOpenWall` |

---

## 2. 对象模型

```mermaid
classDiagram
    class LevelLayoutCatalog {
        +Dictionary~StringName,StringName~ layout_paths
        +layout_path(scene_path) StringName
    }
    class LevelLayoutEntry {
        +StringName level_id
        +Vector2 layout_size
        +PackedVector2Array player_birth_points
        +Array~LevelStageSpec~ stages
        +Rect2 exit_rect
        +StringName exit_open_when
    }
    class LevelStageSpec {
        +int index
        +Rect2 screen_rect
        +Rect2 trigger_rect
        +Rect2 spawn_trigger_rect
        +PackedStringArray close_walls
        +PackedStringArray open_walls
        +Array~LevelSpawnPoint~ spawn_points
    }
    class LevelSpawnPoint {
        +int point_id
        +Vector2 position
        +PackedInt32Array monster_ids
        +int count
        +float delay
        +float interval
        +int direction
        +int after_spawn
        +int after_dead
        +bool ignore_count_multiplier
    }
    class LevelLayoutStore {
        +layout(scene_path) LevelLayoutEntry
        +player_birth_points(scene_path) PackedVector2Array
        +spawn_point_dicts(scene_path) Array
        +stage_specs(scene_path) Array
    }
    LevelLayoutCatalog "1" --> "0..*" LevelLayoutEntry : 路径索引
    LevelLayoutEntry "1" --> "0..*" LevelStageSpec
    LevelStageSpec "1" --> "0..*" LevelSpawnPoint
    LevelLayoutStore ..> LevelLayoutCatalog : 只读加载
```

**分层原则**（照 `LevelPreload*` 范式）：

| 层 | 类型 | 职责 |
|:---|:---|:---|
| Entry / Spec / Point | `Resource` + `@export` | 结构化定义，可 Inspector 审查 |
| Catalog | `Resource` | 只存「场景路径 → 布局资源路径」，**不内联布局内容** |
| Store | `RefCounted` 静态入口 | 按需 `ResourceLoader.load` 单关布局，`CACHE_MODE_REUSE` |

---

## 3. 字段契约

### 3.1 `LevelLayoutCatalog`

| 字段 | 类型 | 语义 | 约束 |
|:---|:---|:---|:---|
| `layout_paths` | `Dictionary[StringName, StringName]` | 关卡场景 `res://` 路径 → 布局资源 `res://` 路径 | 仅已迁移关卡登记；未登记视为「沿用基类默认行为」 |

**方法**：`layout_path(scene_path: String) -> StringName`，未登记返回 `&""`。

### 3.2 `LevelLayoutEntry`

| 字段 | 类型 | 单位 | 语义 |
|:---|:---|:---|:---|
| `level_id` | `StringName` | — | 稳定标识（snake_case，由场景路径派生） |
| `layout_size` | `Vector2` | px | 关卡逻辑尺寸（宽 × 高），用于 Y 轴换算与越界校验 |
| `player_birth_points` | `PackedVector2Array` | px | 玩家出生点（Godot 坐标，Y 向下）；索引 0 为 1P，1 为 2P；缺失索引沿用基类默认位置 |
| `stages` | `Array[LevelStageSpec]` | — | 阶段表，索引 0 对应 `current_stage == 1`；**长度可变，上限不设 4** |
| `exit_rect` | `Rect2` | px | 主出口触发区；`Rect2.position` 为左上角 |
| `exit_open_when` | `StringName` | — | 出口开启条件枚举，见 §3.5 |

**不变量**：
- `stages` 非空时，`stages[i].index == i + 1`；
- `stages.size()` 可达 30：实测源数据分屏数量分布为 1 屏 1,403 关、2 屏 59、3 屏 43、4 屏 50、5 屏 89、6 屏 20、7 屏 19、8 屏 2、9 屏 4、10 屏 14、11 屏 1、13 屏 1、**30 屏 3**；
- 现有 `monster_group` 的 `stage_1..stage_4` 固定结构**不足以承载**，必须改为可变长度；
- 所有矩形必须落在 `Rect2(Vector2.ZERO, layout_size)` 内，越界由生成器 `--check` 失败；终屏 `screen_rect` 允许零宽（如标准四阶段 `[4650,0,0,1000]`），其余矩形宽高为正；
- `player_birth_points` 为空时，关卡沿用现有出生行为。

### 3.3 `LevelStageSpec`

| 字段 | 类型 | 语义 | ZMWS 来源 |
|:---|:---|:---|:---|
| `index` | `int` | 阶段序号，从 1 开始 | `screen` 的键 |
| `screen_rect` | `Rect2` | 摄像机锁定范围 | `screen[N].x / width / height` |
| `trigger_rect` | `Rect2` | 进入该阶段（切屏）的触发区 | `triggers.screenTrigger[screen[N].trigger]` |
| `spawn_trigger_rect` | `Rect2` | 进入后开始刷怪的触发区 | `triggers.monsterTrigger[].x/y/w/h`（按 `screen` 字段匹配） |
| `close_walls` | `PackedStringArray` | 进入阶段时**关闭**的挡板节点名 | `screen[N].triggerWall` |
| `open_walls` | `PackedStringArray` | 该阶段清怪后**开启**的挡板节点名 | `screen[N].endOpenWall` |
| `spawn_points` | `Array[LevelSpawnPoint]` | 该阶段的刷怪点 | `monsterTrigger[].points` → `manCreater[<id>]` |

### 3.4 `LevelSpawnPoint`

| 字段 | 类型 | 单位 | 语义 | ZMWS 来源（`manCreater[<id>]`） |
|:---|:---|:---|:---|:---|
| `point_id` | `int` | — | 点位编号 | `id` |
| `position` | `Vector2` | px | 出生坐标（Godot 坐标） | `x`、`y`（Y 翻转） |
| `monster_ids` | `PackedInt32Array` | — | 可出生的怪物 id 列表；多元素表示随机 | `mIds`（单值）或 `RandomIds` |
| `count` | `int` | 个 | 本次刷怪数量 | `mNums` |
| `delay` | `float` | 秒 | 触发后首次出场延迟 | `delayTime` |
| `interval` | `float` | 秒 | 多只怪物之间的间隔 | `interval` |
| `direction` | `int` | — | 初始朝向：`-1` 左、`1` 右、`0` 不变 | `direction` 归一化（见下） |
| `after_spawn` | `int` | — | 前置点完成刷怪后才启动；0 表示无依赖 | BHYH 既有刷怪点依赖 |
| `after_dead` | `int` | — | 前置点全部死亡后才启动；0 表示无依赖 | BHYH 既有刷怪点依赖 |
| `ignore_count_multiplier` | `bool` | — | 不参与 `CreateMonsterCount` 复制 | BHYH 既有刷怪点语义 |

**`direction` 归一化规则**（实测源数据 int 与字符串混用）：
- 先转 `int`（`"-1"` → `-1`、`"1.0"` → `1`）；
- 再取符号：`-5` → `-1`、`5` → `1`、`0` → `0`；
- 分布实测：`-1` 11,771、`1` 8,425、`"-1"` 2,765、`-5` 2,095、`"1"` 1,208、`"-5"` 740、`"-1.0"` 77、`"1.0"` 60。

**不变量**：
- `count >= 1`；`delay >= 0`；`interval >= 0`；
- `monster_ids` 非空；元素必须能在 `LevelPreloadCatalog.monster_scene_paths` 或 `monster_<id>.tscn` 解析，否则 `--check` 失败（缺失登记走 [`missing_assets_registry.md`](../standards/missing_assets_registry.md)）。

### 3.5 `exit_open_when` 枚举

| 值 | 语义 | ZMWS 来源 |
|:---|:---|:---|
| `&"stage_clear"` | 所有阶段清怪即可（默认） | 无对应字段时的兜底语义 |
| `&"boss_dead"` | 该阶段 Boss 死亡 | `Gateway[].howOpen_BossDead` |
| `&"mids_dead"` | 指定怪物全部死亡 | `Gateway[].howOpen_MidsDead` |
| `&"all_clear"` | 全部通关条件满足 | `Gateway[].howOpen_AllClear` |
| `&"auto"` | 进入即可用（无战斗） | `howEnter_auto` |

---

## 4. ZMWS → BHYH 字段映射

### 4.1 已映射（第一版）

| ZMWS 字段 | BHYH 字段 | 备注 |
|:---|:---|:---|
| `birth.<group>[].x/y/w/h` | `player_birth_points[]`（中心点） | 多组时按组序拼接 |
| `screen[N].x/width/height` | `stages[N-1].screen_rect` | |
| `screen[N].trigger` | 关联 `triggers.screenTrigger[<name>]` → `stages[N-1].trigger_rect` | |
| `screen[N].triggerWall[]` | `stages[N-1].close_walls` | 空字符串需过滤 |
| `screen[N].endOpenWall[]` | `stages[N-1].open_walls` | 同上 |
| `triggers.monsterTrigger[].screen` | 定位到对应 `stages[]` | |
| `triggers.monsterTrigger[].x/y/w/h` | `stages[].spawn_trigger_rect` | |
| `triggers.monsterTrigger[].points[]` | `stages[].spawn_points` 的筛选键 | |
| `triggers.manCreater[<id>]` | `LevelSpawnPoint` | §3.4 |
| `Gateway[].x/y/w/h` | `exit_rect` | 多出口时取 `howOpen_AllClear` 或首个，其余待议 |
| `Gateway[].howOpen_*` | `exit_open_when` | §3.5 |

### 4.2 明确不映射（第一版）

以下字段保留在 ZMWS 源中，**不进入**本契约。需要时按单独立项增量，不在迁移中顺手扩张。

| ZMWS 字段 | 出现次数 | 不映射原因 |
|:---|---:|:---|
| `manCreater[].phase` | 5,051 | 多阶段变身/换阶段行为，需战斗系统支持 |
| `createAfterPointDeadAll` | 12,254 | 依赖「点位全部死亡后」的顺序语义 |
| `RandomIds` / `RandomWeight` | 4,734 | 第一版 `monster_ids` 只取 `mIds`；权重待确认 |
| `isBoss` / `isElite` / `isSmallBoss` | 1,747 / 313 / 45 | 影响 AI 与掉落，属战斗域 |
| `BossAppearHint` / `BossKillHint` | 1,174 / 1,184 | 演出提示 |
| `effect`、`music` | 3,467 / 98 | 表现层，走关卡场景与音频域 |
| `camp`、`dropFinal`、`preSetPath`、`clearCallMonster` 等 | 数百 | 战斗与掉落域 |

### 4.3 坐标约定

- ZMWS 使用 Cocos 坐标：原点左下，Y 向上，`ground` 与 `monsterTrigger` 的 `(x, y)` 为**矩形左下角**；
- BHYH 使用 Godot 坐标：原点左上，Y 向下；
- 换算：`y_godot = layout_size.y - y_cocos`；矩形需先求角点再换算，写入 `Rect2` 时取左上角；
- 生成器负责换算，**运行时不再做 Y 翻转**，避免双重换算。

---

## 5. 构建期生成器

**脚本**：`scripts/convert_level_layout_catalog.py`（与 `convert_level_preload_catalog.py` 同族）

| 项 | 约定 |
|:---|:---|
| 输入 | `scripts/level_layout_sources.json`：既有导入关 `level_48` + 原始 ZMWS 代表关卡的构建期布局快照；原始 ZMWS JSON 只在构建期取证，不写入仓库、不作为运行时读取 |
| 输出 1 | 每关一个 `source/Script/data/level_layouts/<level_id>.tres` |
| 输出 2 | `source/Script/data/level_layout_catalog.tres`（只含路径索引） |
| 校验 | `--check`：schema 完整、矩形落在关卡范围内、`monster_ids` 非空、`stages[].index` 连续、点位 id 唯一、依赖点存在、场景存在 |
| 确定性 | 输出不依赖目录枚举顺序；`level_id` 由源清单显式给出；冲突必须失败 |
| 幂等 | 重复运行输出逐字节一致（以 CSV/`.tres` 字段排序保证） |

**生成失败语义**：任一关卡不满足不变量 → 该关卡不生成 + 退出码非 0 + 列出原因；**不生成占位布局**。

---

## 6. 运行时接入

### 6.1 `BaseLevel` 扩展点

现有方法保持签名不变，默认实现改为读布局资源：

| 方法 | Phase 30-1 实现 | 未登记关卡 |
|:---|:---|:---|
| `_stage_count() -> int` | 有布局资源时返回 `stages.size()` | 沿用 `monster_group` 统计 |
| `_stage_trigger_x() -> Array` | 有布局资源时由 `stages[].trigger_rect.position.x` 派生 | 沿用现有常量 |
| `_screen_starts() -> Array` | 由 `stages[].screen_rect.position.x` 派生 | 沿用现有常量 |
| `_screen_rights() -> Array` | 由 `stages[].screen_rect.end.x` 派生 | 沿用现有常量 |
| `_birth_points() -> Array` | 返回 `LevelLayoutStore.spawn_point_dicts()`（刷怪点字典） | 返回 `[]`（现有基类行为） |

**关键约束**：这些是**既有扩展点**，已被多个子类覆写调用（`game4_imported_level.gd`、`level_48.gd`、`level_59.gd`）。改默认实现不得改变方法签名与返回形状。玩家出生点不是 `_birth_points()`；`BaseLevel._player_spawn_position()` 读取 `LevelLayoutStore.player_birth_points()` 并保留原 `(100,340)/(170,340)` 兜底。

### 6.2 `LevelLayoutStore` API

```gdscript
class_name LevelLayoutStore
extends RefCounted

static func layout(scene_path: String) -> LevelLayoutEntry
static func player_birth_points(scene_path: String) -> PackedVector2Array
static func spawn_point_dicts(scene_path: String) -> Array
static func stage_specs(scene_path: String) -> Array[LevelStageSpec]
static func stage_count(scene_path: String) -> int
static func stage_trigger_x(scene_path: String) -> Array
static func screen_starts(scene_path: String) -> Array
static func screen_rights(scene_path: String) -> Array
static func clear_cache() -> void   # 仅供夹具
```

约定：
- 只读；玩家出生点与阶段快照返回副本；`spawn_point_dicts()` 的字典数组按场景缓存，调用方不得写入；
- 缺失登记返回空值，**不**在运行时扫描目录补齐；
- 加载失败 `push_error` 并返回空，由调用方决定拒绝进入或沿用默认。

### 6.3 刷怪调度

`LevelSpawnPoint` 只是**数据**；Phase 30-1 由既有 `Game4ImportedLevel` 点位状态机消费，保持 `create_control` 计时器、`after_spawn/after_dead` 顺序与 `count` 语义。未登记关卡仍走 `BaseLevel.level_create_monster()` 的平行数组路径。后续批次再把 `delay` / `interval` 统一到计时器，并删除平行数组。

**不改**：`Global.create_monster()` 入口、怪物场景解析、对象池、掉落与结算。

### 6.4 原始 ZMWS 驱动器

Phase 30-2 的 `ZmwsLevel`（继承 `Game4ImportedLevel`）负责把原始 `Scene/level/zmws/*.tscn` 组合进 BHYH 基类：

- 原始地图作为根节点下第一个子节点，`z_index=-10`；基础 `BackGround` 隐藏；
- `ZMWS_Ground` 改到 `PhysicsLayers.ENVIRONMENT`（角色默认碰撞层），并禁用原始静态 `wall`；分屏边界由 `BaseLevel` 按布局 screen_rect 创建；
- 玩家出生点以布局 `player_birth_points` 为准，原始地图 `Marker2D` 仅作视觉/调试参考；出口位置由 `exit_rect` 设置；
- `_runtime_monster_id()` 通过 `ExternalMonsterStore` 把外部 ID 转成 BHYH 怪物 ID；未映射 ID 只警告一次并拒绝生成，不静默替换；
- `_layout_scene_path()` 返回原始地图路径，因此布局 Catalog 以 `res://Scene/level/zmws/*.tscn` 为键；
- 包装场景位于 `source/Scene/level/zmws_playable/*.tscn`，通过 `map_scene` / `map_scene_path` 关联原始地图。

外部映射当前只做**精确中文名**匹配（`source/Data/zmws_config/monster.json` 的 name ↔ BHYH 怪物脚本的 `my_mr_name`）；重复名称取最小 BHYH ID；未匹配项不猜测。

---

## 7. 迁移纪律

1. **不保留双份**：关卡迁移后删除脚本内布局常量/数据表（`monster_group`、`monster_position_x/y`、`BIRTH_POINTS` 或对应 `SCREEN_*`）；不保留 deprecated 别名（ADR-005）。
2. **不建回退层**：布局资源缺失 ≠ 回退到脚本表；只表示该关卡「尚未迁移」，其脚本仍是唯一数据源。迁移完成即删除脚本表，二者不同时存在。
3. **按批验收**：每批迁移后跑 `level_regression_all.py`，与原行为对照；差异必须归因。
4. **不夹带玩法变更**：数值、时序、掉落、输入一律不动（`current-iteration.md` §1.2）。
5. **生成器入库、产物入库**：生成器与 `.tres` 同批提交；`.tres` 若体积超阈值需评估 LFS。

---

## 7.1 Phase 30-1/30-2/30-3 实施记录（2026-11-01）

- 新增 `LevelLayoutEntry` / `LevelStageSpec` / `LevelSpawnPoint` / `LevelLayoutCatalog` / `LevelLayoutStore`；
- 新增 `scripts/convert_level_layout_catalog.py` 与构建源 `scripts/level_layout_sources.json`；
- 迁移 `level_48`（朱雀街，ZMWS 导入关）：删除脚本内 `STAGE_COUNT` / `SCREEN_*` / `STAGE_TRIGGER_X` / `BIRTH_POINTS` 与五个扩展点覆写；
- `check_all` 契约门禁新增 `level_layout_catalog_check`；预载生成器从布局源合并阶段怪物，`level_48` 预载条目保持 `3001/3002/3004/3006`；
- `level_48` 冒烟 Stage 1–5 全部 PASS（22.7s，日志 0 ERROR / 0 WARNING）；全量关卡回归 **128/128 PASS + 5 SKIP**（709.5s）。
- Phase 30-2：`ExternalMonsterCatalog`/`Store` 512 条精确/唯一归一化名称映射；`ZmwsLevel` 原始场景驱动器；20 个 `zmws_playable` 包装关卡；20/20 Stage 全 PASS、20/20 `can_pass=True`，0 ERROR / 0 WARNING；全量回归 **128/128 PASS + 5 SKIP**（731.4s）。
- Phase 30-3 收口批：迁移 69 个数据容器脚本（首批 20 个单屏：`level_38_1`、`level_bgmj`、`level_lxdy1~5`、`level_nmg`、`level_sdwfb`、`level_sjg`、`level_tzhy`、`level_xbj`、`level_xss`、`level_xtqfb`、`level_ghg`、`level_hdgqnmg`、`level_hdgqzld`、`level_hdzm`、`level_42`、`level_44`）；`BaseLevel` 新增布局刷怪表展开，`Game4ImportedLevel` 明确不重复填充；新增 `level_layout_migration_audit.py` 阻断「布局资源 + 脚本数据表」双源；第二批迁移 13 个多阶段脚本（`level_1~8`、`level_10`、`level_21`、`level_45`、`level_dtwd`、`level_hddy`），按既有 fallback 分屏/触发矩形生成 2/4 阶段布局，允许终屏零宽 screen_rect；第三批迁移 10 个长度不一致脚本（`level_12~16`、`level_18`、`level_9`、`level_35`、`level_40`、`level_eighteenth_hell`），第四批迁移 12 个剩余四阶段脚本（`level_19`、`level_23~33`），第五批迁移 10 个四阶段脚本（`level_34`、`level_38`、`level_39`、`level_41`、`level_43`、`level_dsg_1~5`），收口批迁移 4 个（`level_11`、`level_47`、`level_pty`、`level_ymj`）；均按 `_align_monster_spawn_tables()` 的 min(ids,x,y) 截断后生成，多余坐标不进入资源；删除 6 个空数据表；剩余 10 个动态/非连续数据表登记 `level_layout_data_exceptions.json`，`monster_group = {` 从 85 降至 10（全部为例外）。
- Phase 30-4：85 个原数据容器脚本逐项复核；55 个逻辑脚本与 30 个标准/空表脚本的保留/迁出结论见 [`phase_30_4_script_decisions.md`](phase_30_4_script_decisions.md)；10 个例外由 `level_layout_data_exceptions.json` 守恒。

## 8. 验收标准

| 维度 | 判据 |
|:---|:---|
| 契约完整性 | `--check` 对 90 个登记布局全部通过，0 失败；外部怪物 `--check` 512 条通过 |
| 生成确定性 | 连续两次生成结果逐字节一致 |
| 运行时接入 | `level_48` Stage 1–5 PASS；20 个原始 ZMWS 包装关卡 Stage 全 PASS 且 `can_pass=True`；收口批后 69 个已迁移关卡 Stage PASS |
| 行为等价 | 全量 `level_regression_all.py` **128/128 PASS + 5 SKIP**（710.9s）；原始驱动批次 20/20 PASS |
| 静态门禁 | `check_all.py` 全维 PASS；`contract_scan.py` ERROR=0；布局迁移双源 + 例外清单审计 PASS |
| 无回退 | 已迁移关卡脚本不再有布局常量/五个覆写；预载 Catalog 仍含完整怪物集合 |

---

## 9. 已确认事实与剩余未决项

### 9.1 已用实测消解的疑问

| 编号 | 原疑问 | 实测结论 | 处置 |
|:---|:---|:---|:---|
| U2 | `direction` 的 `-5` 如何归一 | int 与字符串混用，`-5` 有 2,835 条 | **已定规则**：先转 int 再取符号，见 §3.4 |
| U6 | `stages` 是否可能超过 4 | 是，最多 **30 屏（3 关）**；5 屏以上共 153 关 | **已定**：`stages` 为可变长度数组，现有 `stage_1..4` 固定结构必须改造 |

### 9.2 剩余未决项

| 编号 | 问题 | 实测规模 | 待确认方 | 第一版临时处置 |
|:---|:---|:---|:---|:---|
| U1 | 多 `Gateway` 时主出口如何选 | 0 出口 482 关、1 出口 1,007 关、2 出口 95 关、最多 **32 出口 1 关** | 玩法侧 | 取 `exit_open_when` 最先满足者；多个同条件时取**首个**，其余登记不实现 |
| U3 | `RandomIds`/`RandomWeight` 是否并入第一版 | 4,734 条点位带随机权重 | 玩法侧 | 第一版不使用；`monster_ids` 只取 `mIds` |
| U4 | 布局资源体积是否入 LFS | 预计 20–35 MB / 1,708 个文件 | 发布侧 | 先普通 Git；单文件超 1 MB 时评估 LFS |
| U5 | 挡板节点命名如何对齐 | ZMWS 用中文名（`战斗挡板1`），BHYH 用 `stop1`/`wall` | 场景侧 | 原始驱动器禁用原始静态 `wall`，用布局 screen 边界驱动挡板；中文名到节点映射留到后续批次 |
| U7 | 外部怪物名称变体/随机组 | 外部源 1,659 个名称；当前精确 + 唯一归一化映射 512 条 | 玩法侧 | 不模糊匹配；未映射 ID 只警告一次并拒绝生成，后续批次再补显式别名 |
| U8 | 原始地图 `triggerWall`/`endOpenWall` 的节点级开合 | 原始场景导出未保留中文名到节点的直接映射；当前转换场景只有 `Ground_*_wall` | 场景侧 | `ZmwsLevel` 已支持按 `_zmws_wall_name` 或节点名匹配布局 close/open；当前转换地图无该元数据，静态墙保持默认关闭，后续转换补充原名 |
| U9 | 动态/非连续数据表 | 10 个脚本：`level_20`、`level_34_1`、`level_36`、`level_37`、`level_46`、`level_llbt`、`level_sssl`、`level_stz`、`level_bxgh`、`liu_sha_river_boss_level` | 关卡/玩法侧 | 保留脚本表并登记 [`level_layout_data_exceptions.json`](../../scripts/level_layout_data_exceptions.json)，迁移审计校验精确集合与理由；后续按单关需求评估 |
