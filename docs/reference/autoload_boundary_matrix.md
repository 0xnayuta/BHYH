# Autoload 与 Global 拆分边界矩阵（Phase 20-1B）

> **状态**：2026-10-30 完成 20-1B 决策、试点 P1（删除 `BaseHit`）、P2（抽取 `RuntimeDiagnostics`）、W3 S2（抽取 `UiRuntime`）、W4（抽取 `AudioRuntime` 并合并 `MainMusic`）、W5 S4（抽取 `ResourceRuntime` 与 `SceneFlow`）、W6 S5（按功能族抽取 5 个场景工厂）、W7 S6/S9（抽取 `CombatPoolRuntime` 与 `MagicWeaponRuntime`）、W8 S7A/S7B（抽取 `RunContext` 并删除写多读零的运行状态字段）、W8 S7C（`LevelEntryRuntime` 与 `MonsterSpawnRuntime`）与 W8 S8（`NodeUtils`/`ItemUtils` 静态工具类、`RoleVisualRuntime`），并把四个无尽模式标志与 `selected_eight_immortal_id` 收进 `RunContext`。本页记录当前边界、逐项结论与迁移顺序。当前 `project.godot` 为 **11 个注册项：10 个业务单例 + `MCPGameBridge` 编辑器调试桥**；20-1B 决策时为 13。
> **范围**：`source/project.godot` 的 Autoload 注册项；重点为 `global.gd` 的职责切分。P1 删除 `BaseHit`；P2 迁出诊断；S2 迁出 UI 宿主；W4 迁出音频并把 `MainMusic` 合并进 `AudioRuntime`；S4 迁出场景/资源运行时；S5 迁出 5 个功能族工厂；S6/S9 迁出对象池与法宝/召唤；S7A/S7B 迁出关卡显示名、玲珑宝塔层数与战斗统计到 `RunContext`；S7C 迁出关卡进入编排与怪物生成；S8 迁出无状态工具与角色贴图加载（以上全部是 `Global` 的普通子节点、静态工具类或它持有的 `RefCounted`，不是 Autoload）。
> **事实快照**：2026-10-30 私有完整工作区，静态扫描 `source/**/*.gd` 755 个文件；`scripts/**/*.gd` 探针另行计数。数量是本次决策证据，不是长期 SLA。
> **依据**：[`目标架构契约`](../standards/target_architecture_contract.md) §3.2、[`Godot 设计规范`](../standards/godot_design_standard.md) §4、[`architecture.md`](architecture.md) §2、[`runtime_lifecycle_matrix.md`](runtime_lifecycle_matrix.md)、[`archive_session_matrix.md`](archive_session_matrix.md)、[`gameplay_module_matrix.md`](gameplay_module_matrix.md)、[`status.md`](status.md)。

## 1. 决策摘要

**结论：采用本页的拆分边界，延期实施。**

- 不设 Autoload 数量目标；不以“把 13 减到 N”作为完成标准。
- 不新增 Autoload。候选新归属优先使用 `RefCounted`、`Resource`、静态 `class_name` 工具类或场景节点；确需跨场景且自管生命周期时才重新评审。
- `global.gd` 不再接收新业务职责。新增字段、工厂、缓存或状态必须放在已有所有权边界内。
- 拆分按所有权闭环推进：迁移生产调用方、删除旧入口、同步守卫与验收；不保留永久兼容 facade。
- 当前 `Global` 仍是场景流、UI 工厂、资源缓存、对象池、音频与运行状态的组合根；先删死代码与低风险诊断，再拆叶子服务，最后处理高频工厂与运行状态。

Phase 20-1 其余切片保持未启动：

| 切片 | 本轮结论 | 说明 |
|:---|:---|:---|
| 20-1A Spine 跨平台 | 未启动 | 需先定目标平台、Spine 运行时版本与许可证；不在本页替其作结论 |
| 20-1B `global.gd` + Autoload | **采用边界清单；P1/P2/W3 S2/W4 已执行，其余延期** | 本页；决策时 13 个注册项，W4 后 11 个 |
| 20-1C `_bundled` 历史场景 | 未启动 | 需私有素材、UID/导入缓存与格式取证 |
| 20-1D 类型化 Atlas accessor | 未启动 | 依赖 19-3B 的 41 项未迁移图集范围 |

## 2. 量化基线

### 2.1 `global.gd` 规模

| 指标 | 决策时 | P2 后 | S2 后 | W4 后 | 说明 |
|:---|:---|:---|:---|:---|:---|
| 行数 | **6,041** | **5,775** | **5,563** | **3,971** | `source/global.gd`；W4 5,407 → W5 S4 4,971 → W6 S5 4,578 → W7 4,352 → W8 S7 4,275 → S8 4,111 → 20-3 4,053 → 怪物展示族 4,044 → 关卡提示族 4,015 → 阵法族 3,971 |
| 顶层函数 | **360** | **347** | **333** | **329** | 含私有函数；`add_*` 工厂仍为薄转发（S8/20-3 删除 11 个工具与死函数、S5 删除 `add_zhen_fa_ui`，新增 3 个工厂 getter） |
| 顶层变量 | **295** | **291** | **285** | **189** | 含运行状态、UI 引用与跨帧标记；缓存/池/召唤/统计/无尽模式/贴图/怪物展示/关卡提示/阵法场景槽位字段已迁出或删除 |
| 顶层常量 | **76** | **75** | **76** | **83** | 含场景路径表、弹体路径表、怪物别名与运行时/工厂脚本预载 |
| 信号 | **2** | **2** | **2** | **1** | `sound_settings_changed` 已迁至 `AudioRuntime`，仅余 `combo_milestone_reached` |

`RuntimeDiagnostics` 为 230 行、`UiRuntime` 为 274 行、`AudioRuntime` 为 233 行普通 `Node`，均由 `Global` 在 `_ready` 创建并持有；不计入 Autoload。`RunContext` 为 158 行 `RefCounted`，`LevelEntryRuntime` 116 行、`MonsterSpawnRuntime` 39 行、`RoleVisualRuntime` 104 行、`MonsterDisplayFactory` 60 行、`LevelHintFactory` 93 行、`ZhenFaFactory` 104 行普通 `Node`，`NodeUtils` 39 行、`ItemUtils` 95 行静态工具类，均由 `Global` 创建/持有或被静态调用。Autoload 从 13 降到 **11**。

### 2.2 调用面

静态扫描 `source/**/*.gd` 中的 `Global.<member>`：

| 指标 | 数值 |
|:---|:---|
| 引用文件 | **427** |
| 直接调用点 | **3,372** |
| 不同成员 | **273** |
| 外部直接写入 | **494** 次，涉及 **64** 个变量 |

以上调用面为 20-1B 决策时基线。P2/W3 S2/W4/W5 S4/W6 S5 已把诊断、UI 生命周期、音频、场景/资源运行时与五个场景工厂族迁出；生产代码当前为引用文件 **429**、调用点 **3,394**、成员 **266**（其中 `get_audio_runtime` 289、`get_ui_runtime` 185）。成员数下降来自 `add_bgm`/`add_sound`/`windows` 等入口删除，调用点上升来自访问器转发；`add_*` 工厂入口签名保持不变。

决策时包含 `scripts/**/*.gd` 探针的基线为引用文件 **432**、调用点 **3,586**、成员 **298**；P2 后探针改走 `Global.get_runtime_diagnostics()`，该计数不再代表当前诊断调用面。

高频 API：

| API | 调用点 | 文件 | 主要归属 |
|:---|---:|---:|:---|
| `add_message_show` | 409 | 81 | UI 工厂 |
| `add_bullet` | 300 | 96 | 战斗表现/弹体 |
| `windows` | 158 | 46 | UI 宿主状态 |
| `add_sound` | 138 | 34 | 音频 |
| `add_bgm` | 125 | 94 | 音频 |
| `llbt_level` | 119 | 19 | 运行状态 |
| `add_buff` | 108 | 66 | 战斗表现/buff |
| `current_level` | 106 | 101 | 运行状态 |
| `add_trap` | 103 | 3 | 战斗表现/陷阱 |
| `change_scene` | 100 | 48 | 场景流 |
| `get_ancestor` | 95 | 16 | 通用工具 |
| `add_special_effect` | 81 | 20 | 战斗表现 |
| `create_monster` | 65 | 51 | 战斗生成 |
| `add_level_info` | 61 | 11 | UI 工厂 |
| `add_role_bullet` | 36 | 8 | 战斗表现/弹体 |
| `call_fly_bullet` | 36 | 14 | 战斗表现/弹体 |

**关键事实**：`current_level` 有 106 次读取、94 次外部写入、101 个读取文件；`llbt_level` 有 119 次读取、21 次写入；`windows` 有 158 次读取、12 次写入。运行状态与 UI 宿主仍是全局可变上下文，不能直接搬进新单例。

### 2.3 `PlayerData` / `RoleProp` 计数口径

`PlayerData` 有 2,082 处、162 个文件的文本引用；`RoleProp` 有 1,903 处、263 个文件。它们**不能当作 Autoload 调用面**：

- 两者同时是 Autoload 名称和 `BaseObject` / `BaseRole` / `BaseRoleProperties` 的实例属性名；
- 大量引用是 `LocalCoop.data_for()` / `props_for()` 路由后的槽位实例；
- `monster_attr_data.gd` 等文件还包含 `RoleProp.roleprop` 形式的字符串表达式，不是直接执行路径。

因此，重命名或拆分会同时触动槽位路由与表达式数据；本轮结论是保留名称与回退路径，不做批量改名。

## 3. 逐项决策

Owner 口径：当前仓库为单人维护，owner 默认为项目维护者；表中“战斗/法宝”“UI/双人”等是批次审查责任域，不虚构人员姓名。表保留 20-1B 决策时的 13 项编号；`BaseHit` 与 `MainMusic` 已删除，当前 11 项。

| # | Autoload | 当前职责 | 决策 | 证据与边界 | Owner / 前置条件 |
|:---:|:---|:---|:---|:---|:---|
| 1 | `BaseHit` | 上一次命中数值、类型与击退向量中转 | **已删除（P1，2026-10-30）** | 原有 4 处重置写入、全仓无读取；已删除 Autoload 注册、`base_hit.gd`/`.uid`、`remove_infor()` 与 6 个动画方法键 | 战斗/法宝；P1 验收见第 6 节 |
| 2 | `RoleProp` | `BaseRoleProperties` 单例形态与启动回退 | **保留，延期迁移** | 大量文本引用是实例属性；真正的根回退位于 `BaseRoleProperties` / `PlayerDataStore` 的 getter | 角色/存档；先证明 `LocalCoop` 在启动与无槽位路径始终可用，再移除根回退 |
| 3 | `PlayerData` | 1P 档案数据仓库与补全 | **保留（1P 档案仓库）** | 菜单/地图可直接读取；新代码应走 `BaseObject.PlayerData`、`BaseRole.PlayerData` 或 `LocalCoop.data_for()` | 存档/1P UI；禁止新增直接 Autoload 读写；数据 schema 拆分延期 |
| 4 | `MemoryClass` | 本地存档加密读写、备份、后台保存、设置文件 | **保留（持久化边界）** | 230 处/72 文件；已有后台保存、补全、失败反馈与快照互斥 | 存档；不把存档 IO 搬进 `Global`，不再增加第二套保存入口 |
| 5 | `MainSet` | 设置字典、帧率、主菜单背景解锁 | **保留（设置）** | 393 处/65 文件；跨场景且自管设置 | 设置/UI；类型化设置 Resource 可作为后续独立项 |
| 6 | `AE` | 装备数值门面，懒加载装备表 | **保留（装备目录）** | 321 处/48 文件；无业务依赖 | 装备；不新增字段；静态 Resource 化单独立项 |
| 7 | `MLdl` | 锻造台 UI 会话状态 | **迁移候选（场景状态）** | 105 处/6 文件；仅 `qh_list`、`current_mode` | 锻造 UI；迁移到锻造台场景/面板持有状态，需面板开关与切档验证 |
| 8 | `PaSkill` | 被动技能数值表与灵魂收益 | **保留（被动数值）** | 52 处/8 文件；纯查表 | 被动/成长；不新增全局状态；静态化单独立项 |
| 9 | `MainMusic` | 主菜单 BGM 单实例 | **已删除（W4，2026-10-30）** | 原 27 处/13 文件、自身又调用 `Global.add_bgm`；现合并为 `AudioRuntime.add_main_menu_music()` / `remove_main_menu_music()` / `has_main_menu_music()`，Autoload 注册与 `main_music.gd` 已删除 | 音频；BGM 同曲/切曲/退出与主菜单切换已验证 |
| 10 | `Signals` | 全局确认框信号 | **保留，禁止新增全局信号** | 11 处/9 文件；`choose_pressed` 会清空旧连接 | UI；选择框迁移到显式信号后删除，需确认框流程验证 |
| 11 | `Global` | 场景流入口、UI 工厂入口、预载入口、运行状态 | **拆分（本页边界）** | 决策时 6,041 行/360 函数/427 文件/3,372 调用；W7 后 4,352 行/329 函数/228 变量，诊断、UI、音频、场景/资源运行时、5 族场景工厂、对象池与法宝召唤已移出 | 项目维护者（架构）；按第 4~5 节分波推进 |
| 12 | `LocalCoop` | 本地双人会话、槽位数据/属性/输入/面板 | **保留（双人会话）** | 285 处/78 文件；Phase 16/17 已建立槽位与面板边界 | 双人；不建第二组 Autoload；继续由显式槽位 API 服务 |
| 13 | `MCPGameBridge` | 编辑器调试桥 | **保留（调试桥，不计业务）** | 业务 `MCPGameBridge.` 引用为 0；`_ready` 在 `EngineDebugger.is_active()` 为假时退出 | 工具链；20-2 release 时验证 addon 路径、调试器门控与导出行为 |

## 4. `Global` 拆分边界

| 边界 | 当前内容（证据） | 目标归属 | 决策与顺序 |
|:---|:---|:---|:---|
| S1 诊断/快照 | 调试性能浮层；`RuntimeDiagnostics` 的 `get_cache_scope_snapshot`、`get_level_resource_lease_snapshot`、`get_preloaded_scene_slot_snapshot`、运行时代次、后台保存/失败状态；探针通过 `Global.get_runtime_diagnostics()` 访问 | `RuntimeDiagnostics`（`Global` 的普通 `Node` 子节点） | **已拆（P2）**；`scripts/scene_probes`、`scripts/archive_probes` 已迁移；无 Autoload 新增 |
| S2 UI 宿主/运行时 | `UiRuntime` 持有 `windows`、popup 层、hover popup、`register_transient_ui` / `cleanup_transient_ui`、UI 实例登记与缓存；`LocalCoop` 使用 `push_windows` / `pop_windows` | `UiRuntime`（`Global` 的普通 `Node` 子节点） | **已拆（W3 S2）**；`add_*` 工厂仍留 `Global`，只迁移生命周期；无 Autoload 新增 |
| S3 音频 | `AudioRuntime` 持有 BGM 单实例、主菜单 BGM、SFX 声部/节流/上限与设置变化信号；`add_*` 音频入口统一为 `Global.get_audio_runtime()` | `AudioRuntime`（`Global` 的普通 `Node` 子节点） | **已拆（W4）**；`MainMusic` 已合并删除；无 Autoload 新增 |
| S4 场景/资源运行时 | `change_scene`（101 处）、缓存四表、单槽预载、线程预热、关卡租约、释放 | `SceneFlow` + `ResourceRuntime`（由 `Global` 组合持有） | **已拆（W5 S4）**；`Global.change_scene` 仍是唯一正式入口；无 Autoload 新增 |
| S5 UI 工厂 | 122 个 `add_*`；`add_message_show` 408、`add_bullet` 300、`add_trap` 103、`add_special_effect` 81、`add_buff` 68、`add_level_info` 61、`add_choose_item` 40 | 按功能族的场景工厂 | **部分已拆**：W6 S5 五族 41 个工厂 + W7 S6 战斗三入口 + S7C `add_level_info` + 怪物展示族（3 入口）+ 关卡提示族（5 入口）+ 阵法族（6 入口）；`Global` 现 120 个 `add_*`，**59 个为薄转发**，其余 61 个按族推进（见 §8 下一批候选）；不建总工厂 |
| S6 战斗表现 | `add_bullet`、`add_buff`、`add_trap`、`add_special_effect`、`add_damage_text`、`add_mr_hurt`、伤害数字/受击四池 | `CombatPresentationFactory` + `CombatPoolRuntime`（`Global` 组合持有） | **已拆（W7 S6）**：弹体/buff/陷阱/特效/伤害数字/受击/血条与对象池；`create_monster` 与生成服务按 S7 运行状态后续处理 |
| S7 运行状态 | `current_level`、`llbt_level`、13 个 `total_*` 统计、9 个 `is_*` 减益标志、关卡进入编排、怪物生成 | `RunContext`（`RefCounted`）+ `LevelEntryRuntime` + `MonsterSpawnRuntime`（`Global` 持有） | **已拆（W8 S7）**：关卡显示名、宝塔层数与 13 项战斗统计迁入 `RunContext`；9 个减益标志经证据确认写多读零后删除；`add_level_info`/`get_current_level_fall_pro`/`sync_level_drop_pro_data` 与非 res:// 直进分支迁入 `LevelEntryRuntime`，`create_monster`/路径解析迁入 `MonsterSpawnRuntime`；四个无尽模式标志与 `selected_eight_immortal_id` 收进 `RunContext`（整体赋值 API，同一时刻至多一个副本为真），`Global` 暴露 `is/set/clear_special_dungeon_endless` 与八仙选择读写 |
| S8 通用工具 | `get_ancestor` 95/16、`get_position_between`、`get_dis_betweem`、`get_clean_name`、物品计数、角色纹理加载 | `NodeUtils` / `ItemUtils` 静态类 + `RoleVisualRuntime` | **已拆（W8 S8）**：祖先/向量工具与品质名清理迁入静态类；随机物品条目迁入 `ItemUtils`；角色身体/装备贴图与同槽位旧贴图释放迁入 `RoleVisualRuntime`；`Global` 只保留 `load_role1_body`/`load_role1_eq` 薄转发 |
| S9 法宝/召唤 | `current_magic_summon`、`secondary_magic_summon`、`add_magic_weapon`、`get/set_magic_summon_for`、法宝预载 | `MagicWeaponRuntime`（场景/槽位持有） | **已拆（W7 S9）**；槽位归属以 `LocalCoop.slot_for` 为准，禁止回落 1P；场景路径表仍归 `Global` |

## 5. 迁移顺序

| 波次 | 范围 | Owner | 前置条件 | 验证 | 回滚 |
|:---|:---|:---|:---|:---|:---|
| W0 | 冻结：本页边界；不新增 `Global` 职责/字段 | 项目维护者 | 无 | 文档与链接检查；后续 20-3 守卫 | 文档回退 |
| W1 | 死代码/低风险：**`BaseHit` 已删除（P1）**；其余已确认 0 引用的 `add_*` 辅助待办 | 战斗/UI | P1 完成；其余静态扫描 `.gd`/`.tscn`/动态 `call` | P1：`health_check` 0/0、`level_1` PASS、`magic-weapons` 探针 PASS、场景加载探针 PASS、`check_all --godot-bin` 8/8 | 版本控制 |
| W2 | S1 诊断/快照：**已拆（P2）** | 资源/工具 | P2 完成 | `scene_probes` 3 项 PASS；`archive_probes` 289/289 PASS；`level_1` PASS；`check_all --godot-bin` 8/8 | 恢复 `Global` 旧方法并回退探针 |
| W3 | S2 UI 宿主/运行时：**已拆（W3 S2）** | UI/双人 | S2 完成 | `coop_probe_runner` 25/26 → 修复探针后重跑；`scene_probe_runner` 7/7 PASS；`archive_probe_runner` 289/289 PASS；`check_all --godot-bin` 8/8 | 恢复 `Global.windows` 字段并回退调用方 |
| W4 | S3 音频 + `MainMusic`：**已拆（W4）** | 音频 | W4 完成 | `archive_probes` 的 BGM/SFX 14 项 PASS（289/289 总）；主菜单 BGM 与关卡切曲、退出清理经档案探针；`scene_probe_runner` 7/7；`coop_probe_runner` 26/26；`check_all --godot-bin` 8/8 | 恢复 `MainMusic` 与 `Global.add_bgm/add_sound` |
| W5 | S4 场景/资源内部实现：**已拆（W5 S4）** | 资源/场景 | W5 完成 | `load_guard`、`level_resource_lease`、`level_selection` **7/7 PASS**；`archive_probes` 289/289；`coop_probes` 26/26；`level_1` PASS；`check_all --godot-bin` 8/8 | 保留 `Global.change_scene` 入口并回退两个运行时 |
| W6 | S5 UI 工厂，按功能族：**首批已拆（W6 S5）** | UI | W6 首批完成：五族 41 个工厂；`add_level_info`、`add_damage_text`、`add_mr_hurt`、`add_special_effect` 因依赖运行状态/对象池延期 | `ui-factories` 探针 59 项 PASS（含族归属、缓存持有、入口转发、工厂拒绝语义）；`scene_probe_runner` 8/8；`archive_probes` 289/289；`coop_probes` 26/26；`level_regression_all --changed-only` **128/128 PASS + 5 SKIP** | 按族回退 |
| W7 | S6 战斗表现 + S9 法宝/召唤：**已拆（W7 S6/S9）** | 战斗/法宝 | W7 完成 | `ui-factories` 探针 77 项 PASS（含池容量/节流/归还、法宝替换与清空）；`coop_probe_runner` **26/26**；`scene_probe_runner` **8/8**；`archive_probes` 289/289；`level_1` PASS；`level_regression_all --changed-only` 回归通过 | 恢复 `Global._pool_data` 与召唤字段 |
| W8 | S7 运行状态 + S8 通用工具：**已拆（S7A/S7B/S7C、S8）** | 玩法/关卡 | 运行状态 accessor、进入/生成归属、工具静态化完成 | `utils` 26 项 + `level-entry` 25 项 + `run-context` 18 项、全量 `level_regression_all` **128/128 + 5 SKIP**、档案探针 289/289、`level_1` | 版本控制（字段与静态化入口已删除，无只读一版） |

**顺序理由**：先处理无行为或低行为风险的诊断/死代码，再迁移叶子服务（UI 宿主、音频），然后处理中心资源运行时，最后迁移高频工厂与运行状态。`Global._exit_tree` 与 `change_scene` 是资源释放和场景流的正式入口，迁移时必须保留其可观察清理语义，不能用“搬字段”代替所有权迁移。

## 6. 试点

P1、P2 均已执行；二者都不新增 Autoload。

### P1：删除 `BaseHit`（完成，2026-10-30）

- 已删除 `project.godot` 的 `BaseHit` 注册、`source/base_hit.gd` 与 `.uid`、`hit_bullet.gd` 的 `remove_infor()`，以及 4 个法宝弹体场景中 6 个 `remove_infor` 动画方法键；未改命中数值逻辑。
- 当前 Autoload 为 **12** 个（11 业务 + 1 调试桥）；P1 时 `global.gd` 未变。
- 验收：`health_check` 0 Parse / 0 Error / 0 Warning；`level_1` 冒烟 PASS（4 Stage，0/0/0）；`scene_probe_runner --probe magic-weapons` PASS；4 个改动场景的加载/实例化/方法轨道探针 PASS；`check_all --godot-bin` 8/8 PASS。
- Owner：战斗/法宝。

### P2：抽取 `RuntimeDiagnostics`（完成，2026-10-30）

- 新增 `source/Script/runtime/runtime_diagnostics.gd`（`class_name RuntimeDiagnostics`，230 行），由 `Global._ready` 创建并作为普通 `Node` 子节点持有，不注册 Autoload。
- 迁出：调试性能浮层、`get_runtime_generation`、后台保存/失败状态快照、缓存作用域/关卡租约/预载单槽快照，以及浮层与计时状态；后台保存/运行状态本身仍由 `Global` 持有。`Global` 从 6,041 行/360 函数/295 变量降到 5,775 行/347 函数/291 变量。
- 新入口：`Global.get_runtime_diagnostics()`；探针与调试面板通过该入口读取只读快照。
- 验收：`scene_probes` 的租约/加载守卫/关卡选择 3/3 PASS；`archive_probes` 289/289 PASS；`level_1` PASS（4 Stage，0/0/0）；临时调试浮层/快照探针 PASS；`check_all --godot-bin` 8/8 PASS。
- Owner：资源/工具。

### W3 S2：UI 宿主/运行时（完成，2026-10-30）

- 新增 `source/Script/runtime/ui_runtime.gd`（`class_name UiRuntime`，274 行），由 `Global._ready` 创建为普通 `Node` 子节点，不注册 Autoload。
- 迁出：`windows`、popup 层、hover popup、临时 UI 登记/清理、UI 实例登记/计数、UI 场景缓存释放；`LocalCoop` 面板改为 `push_windows()` / `pop_windows()`，删除 `_previous_windows`。
- `add_*` 工厂仍留 `Global`，生命周期调用改走 `_ui_runtime` / `Global.get_ui_runtime()`；`Global.windows`、`Global.get_ui_popup_layer()`、`Global.register_transient_ui()` 等旧入口删除。
- `Global` 进一步降到 5,563 行/333 函数/285 变量；`UiRuntime` 274 行。
- 验收：`scene_probe_runner` 7/7 PASS；`archive_probe_runner` 289/289 PASS；`coop_probe_runner` 26/26 PASS；`level_1` PASS；`check_all --godot-bin` 8/8 PASS。
- Owner：UI/双人。

### W4 S3：音频运行时（完成，2026-10-30）

- 新增 `source/Script/runtime/audio_runtime.gd`（`class_name AudioRuntime`），由 `Global._ready` 创建为普通 `Node` 子节点，不注册 Autoload。
- 迁出：`add_bgm` / `add_sound` / `stop_bgm` / `recycle_sound_player`、BGM 单实例、SFX 声部仲裁（45ms 节流、同音效 4/8、总声部 24/48）与 `sound_settings_changed` 信号；`Global._physics_process` 不再监听音效设置。
- 合并 `MainMusic`：删除 Autoload 注册与 `main_music.gd`，主菜单 BGM 改由 `AudioRuntime.add_main_menu_music()` / `remove_main_menu_music()` / `has_main_menu_music()` 管理。
- 调用方迁移：`Global.add_bgm` 125 处、`Global.add_sound` 138 处、`MainMusic.*` 27 处改为 `Global.get_audio_runtime()`；Autoload 从 12 降到 11。
- 验收：`archive_probe_runner` 的 BGM/SFX **14/14** PASS（同曲复用/异父重挂/切曲/退出停止/声部池/节流清理）；`scene_probe_runner` 7/7；`coop_probe_runner` 26/26；`level_1` PASS；`check_all --godot-bin` 8/8。
- Owner：音频。

### W5 S4：场景与资源运行时（完成，2026-10-30）

- 新增 `source/Script/runtime/resource_runtime.gd`（`class_name ResourceRuntime`，750 行）与 `scene_flow.gd`（`class_name SceneFlow`，83 行），由 `Global._ready` 创建为普通 `Node` 子节点，不注册 Autoload。
- `ResourceRuntime` 接管：场景/精灵帧/音频/纹理四类缓存、怪物场景缓存、常驻小 UI 场景缓存、关卡资源租约、单槽预载、线程预载与分帧预热（scene/audio/texture）。
- `SceneFlow` 接管：场景切换流、请求代次守卫与 `target_scene`；`Global.target_scene` 改为属性转发，`load_scene.gd` 与其他调用方读写语义不变。
- 删除 `Global` 私有字段：`_resource_cache`、`_sprite_frames_cache`、`_audio_cache`、`_texture_cache`、`_monster_scene_cache`、`_permanent_small_ui_scene_cache`、`_level_resource_lease`、`_level_resource_lease_id`、`_preloaded_scene`、`_preloaded_scene_path`、`_preloading_path`、`_scene_request_generation`；`PERMANENT_SMALL_UI_SCENE_PATHS` 迁至 `ResourceRuntime`。
- 保留全部公开入口作为薄转发：`change_scene`、`preload_next`、`clear_preloaded_scene_slot`、`is_resource_cached`、`get_cached_packed_scene`、`handoff_loaded_resource`、`get_cached_audio`/`get_cached_texture`、`load_scene_uncached`、`load_cached_scene`、`begin_level_resource_lease`/`release_level_resource_lease`、`prewarm_*`。
- `runtime_diagnostics` 的缓存/租约/预载快照改读 `ResourceRuntime` 只读访问器；`ui_runtime` 的缓存释放改走 `ResourceRuntime` 窄 API，不再触碰宿主私有字段；`contract_scan` 的场景入口允许清单扩为 `SCENE_ENTRY_BOUNDARY_FILES`（`global.gd` + `Script/runtime/scene_flow.gd`）并补 SceneFlow 好样本。
- `Global` 5,407 → **4,971** 行；函数数与变量数不变（仅搬实现）。
- 验收：`health_check` 0 Parse / 0 Error / 0 Warning（722 脚本）；`scene_probe_runner` 7/7；`archive_probe_runner` 289/289；`coop_probe_runner` 26/26；`level_1` PASS（4 Stage，0/0/0）；`contract_scan --self-test` PASS 且 `--fail-on-error` ERROR=0；`check_all --godot-bin` 8/8。
- Owner：资源/场景。

### W6 S5：场景工厂功能族（完成首批，2026-10-30）

- 新增 5 个功能族工厂，均为 `Global` 的普通 `Node` 子节点（非 Autoload），各自持有本族的场景缓存字典：

| 工厂 | 行数 | 接管工厂 | 场景缓存 |
|:---|---:|:---|:---|
| `PopupFactory` | 135 | `add_message_show`、`add_buff_info`、`add_choose_text`、`add_moment_text`、`add_touch_text`、`add_lj`、`add_combo`、`add_combo_num` | message_show、choose_scene、moment_text、touch_text、liji、combo、combo_num |
| `ShopFactory` | 119 | `add_shop`、`add_shop_items`、`add_mystery_shop`、`add_choose_item`、`add_synthesis`、`add_strength`、`add_s_y_n_help` | shop、shop_item、mystery_shop、choose_item、synthesis、strength、s_yn_help |
| `BackpackFactory` | 173 | `add_back_pack`、`add_main_backpack`、`add_dj_infor`、`add_dj_sell`、`add_equ_propeties_box`、`add_se_eq_jm`、`add_pl_sell`、`add_magp_infor`、`add_use_magic_weapon`、`add_skill_select`、`add_buff_icon_text` | back_pack、main_backpack、dj_information、dj_sell、equipment_properies、sell_or_equ、pl_sell、magic_weapon_infor、use_magic_weapon、skill_select、buff |
| `RewardFactory` | 103 | `add_reward_info`、`add_reward_box`、`add_task_reward`、`add_basic_task`、`add_after_level_end` | reward_interface、reward_box_2、task_reward、basic_task、after_level_end |
| `CombatPresentationFactory` | 262 | `add_buff`、`add_trap`、`add_special_effect_bullet`、`add_bullet`、`add_bullet_safe`、`add_hit_text`、`add_damage_number`、`add_monster_blood`、`add_miss_effect`、`add_boss_blood_instance` | base_buff、trap、special_effect_bullet、hit_text、damage_number、monster_blood_bar、boss_blood、miss_effect |

- `Global` 侧的 41 个 `add_*` 保留同名签名，改为单行薄转发；36 个场景缓存成员变量删除；`preload_combat_hit_resources`、`add_buff_icon`、`add_aura`、`add_chase_bullet` 改调 `load_cached_scene(path)`，`_cached_scene(property_name, path)` 仅保留仍需成员变量的键。
- `special_effect_bullet` 缓存改为工厂持有：角色预载调用 `CombatPresentationFactory.preload_special_effect_bullet()`，`clear_combat_runtime_cache` 与 `release_role_runtime_resources` 调用 `clear_scene_caches()`。
- 顺带修正：`add_after_level_end` 原写 `z_index = 9999` 超出 `CanvasItem` 合法范围 [-4096, 4096]，赋值从未生效；删除该无效赋值，渲染顺序与历史一致。
- 延期项（不谎报为已完成）：`add_level_info` 依赖 `current_level`/无尽模式标志等运行状态，随 S7 一起迁移；`add_damage_text`、`add_mr_hurt`、`add_special_effect` 的 RoleBeHit 分支依赖对象池与限流状态，随 S6 一起迁移。
- `Global` 4,971 → **4,578** 行、变量 268 → **237**（`add_*` 计数 122，入口签名不变）。
- 新增探针 `scripts/scene_probes/ui_factory_probe.{gd,tscn}`（`ui-factories`），59 项检查覆盖族节点归属、工厂转发、缓存持有、`add_buff` 拒绝语义与清缓存后重取景。
- 验收：`scene_probe_runner` **8/8 PASS**；`archive_probe_runner` 289/289；`coop_probe_runner` 26/26；`level_1` PASS；`level_regression_all --changed-only` **128/128 PASS + 5 SKIP**；`contract_scan --self-test` PASS 且 `--fail-on-error` ERROR=0；`check_all --godot-bin` 8/8。
- Owner：UI。

### W7 S6/S9：战斗表现池化与法宝/召唤（完成，2026-10-30）

- 新增 `source/Script/runtime/combat_pool_runtime.gd`（`class_name CombatPoolRuntime`，322 行）：持有 `damage_text`/`mr_hurt`/`role_be_hit`/`sound_player` 四池、池根、伤害数字活跃计数（80 上限，按物理帧重算）、怪物受击 55ms 节流、剑阵伤害数字与命中特效按帧限流，以及 `seed_pool` / `clear_runtime_pools` / `recycle_*` / 作用域快照。
- 新增 `source/Script/runtime/magic_weapon_runtime.gd`（`class_name MagicWeaponRuntime`，70 行）：持有两个槽位的当前法宝召唤物、创建/替换/清理；槽位归属走 `LocalCoop.slot_for`，禁止回落 1P。场景路径表仍归 `Global`（`MAGIC_WEAPON_SCENE_PATHS` + 新增只读查询 `get_magic_weapon_scene_path`）。
- `CombatPresentationFactory` 追加池化工厂：`add_damage_text`、`add_mr_hurt`、`add_special_effect`（含 RoleBeHit 池分支与特殊效果 slim 场景缓存）。`Global` 侧 3 个 `add_*` 与 `set_damage_text_enabled` 保留签名转发。
- `Global` 删除：`_pool_data`、`DAMAGE_TEXT_POOL_LIMIT`/`MR_HURT_POOL_LIMIT`/`ROLE_BE_HIT_POOL_LIMIT`/`SOUND_PLAYER_POOL_LIMIT`、`_active_damage_texts`、`_damage_text_count`、`_damage_text_recount_frame`、`_last_mr_hurt_msec`、`_sword_*` 四个限流字段、`current_magic_summon`、`secondary_magic_summon`。池操作与归还入口转为 `_combat_pool` 薄转发（19 处）。
- `AudioRuntime` 的 SFX 池改用 `Global.get_combat_pool()`；`runtime_diagnostics` 的战斗作用域快照改读池运行时快照；`level_resource_lease_probe` 的池断言改用新 API（容量/单次入池/清理后池根失效）。
- `Global` 4,578 → **4,352 行、237 → 228 变量**；同时删除迁走后无调用方的 6 个私有转发（`_get_pool_root`、`_store_pooled_node`、`_release_damage_text_count`、`_on_damage_text_tree_exited`、`_recount_active_damage_texts`、`_on_damage_text_freed`）。
- 验收：`health_check` 0 Parse / 0 Error / 0 Warning；`scene_probe_runner` **8/8**（`ui-factories` 扩到 **77 项**，含池容量/节流/归还、法宝替换与清空）；`archive_probe_runner` 289/289；`coop_probe_runner` **26/26**；`level_1` PASS（4 Stage，0/0/0）；`level_regression_all --changed-only` **128/128 PASS + 5 SKIP**；`contract_scan --self-test` PASS 且 `--fail-on-error` ERROR=0；`check_all --godot-bin` 8/8。
- Owner：战斗/法宝。

### W8 S7A/S7B：运行状态 accessor 与 RunContext（完成，2026-10-30）

- 新增 `source/Script/runtime/run_context.gd`（`class_name RunContext`，113 行 `RefCounted`）：持有 `level_display_name`、`tower_floor` 与 13 项战斗统计；写入只经 `set_level_display_name`/`set_tower_floor`/`advance_tower_floor`/`add_damage_dealt`/`add_damage_dealt_by_type`/`add_damage_taken`/`add_damage_taken_by_type`/`add_healing`/`count_hit`/`count_hurt`/`count_crit`/`count_miss`/`reset_combat_stats`。
- `Global` 新增 6 个 accessor：`get_run_context`、`get_current_level_name`、`set_current_level_name`、`get_tower_floor`、`set_tower_floor`、`advance_tower_floor`；`Global` 侧不再持有 `current_level`、`llbt_level` 与 13 个 `total_*` 字段。
- 调用面迁移：`Global.current_level` 写 94 处、读 12 处 → accessor；`Global.llbt_level` 写 21 处、读 59 处 → accessor；`Global.total_*` 写 66 处、读 13 处 → `RunContext` 方法/字段；`BaseLevel.remove_all_records` 的 13 行清零改为一行 `reset_combat_stats()`。
- 统计口径保持不变：总量与分类型仍是两条独立累计路径（迁移前的 `total_role_hurt` 与 `total_phy_hurt` 等分桶各自独立），未合并、未重排；未知伤害类型静默忽略，与迁移前 if/elif 链一致。
- `monster_attr_data.gd` 的 36 处 `Global.llbt_level` 是属性面板公式**文本令牌**而非属性引用；`monster_head_info.gd` 的匹配与替换按令牌处理，仅真实读取改为 `Global.get_tower_floor()`，令牌处加注释说明。
- 删除 9 个减益标志、116 处 `Global.is_* = false` 复位写与两处恒量读取分支（证据见 §8）。
- 新增探针 `scripts/scene_probes/run_context_probe.{gd,tscn}`（`run-context`，18 项）：统计总量与分类型互不串桶、未知类型忽略、计数器、层数写/自增/共享、关卡名往返、结算面板 `after_level_end` 读取同一上下文、重置与恢复。
- 验收：`health_check` 0 Parse / 0 Error / 0 Warning；`scene_probe_runner` **9/9**；`archive_probe_runner` 289/289；`coop_probe_runner` **26/26**；`level_1` PASS（0/0/0）；全量 `level_regression_all` **128/128 PASS + 5 SKIP**（277.1s）；`check_all --godot-bin` 8/8。
- Owner：玩法/关卡。

### W8 S7C：关卡进入与怪物生成归属（完成，2026-10-30）

- 新增 `source/Script/runtime/level_entry_runtime.gd`（`class_name LevelEntryRuntime`，116 行）：持有 `level_info.tscn` 常驻场景槽位与关卡掉落概率表；接管 `add_level_info`、`enter_level_without_info`、`get_current_level_fall_pro`、`sync_drop_pro_data`。`Global` 保留 `add_level_info`/`get_current_level_fall_pro`/`sync_level_drop_pro_data` 同名薄转发与 `get_level_entry_runtime()`。
- 新增 `source/Script/runtime/monster_spawn_runtime.gd`（`class_name MonsterSpawnRuntime`，39 行）：怪物 ID → 场景路径（预载覆盖表优先）与 `create_monster`；`preload_level_monster_scenes` 等预载路径解析改调运行时。`Global` 保留 `create_monster` 薄转发与 `get_monster_spawn_runtime()`。
- `Global` 删除 `level_info` 场景槽位、`level_drop_pro_data`、`_enter_level_without_info`、`_monster_scene_path`；`get_level_info_monster_ids` 改用运行时场景槽位。
- 无尽模式复位：四个标志与 `selected_eight_immortal_id` 仍归 `Global`（关卡脚本直接读取），复位收敛为 `Global.apply_level_entry_mode_reset(target_path)`，由 `LevelEntryRuntime` 调用，避免把全局标志的控制流留在进入编排里。
- 修正：`add_level_info` 在 `level_info.tscn` 加载失败时由 `.instantiate()` 空引用崩溃改为提前返回 `null`；正常素材路径行为不变。
- 新增探针 `scripts/scene_probes/level_entry_probe.{gd,tscn}`（`level-entry`，24 项）：无会话拒绝与直进守卫、信息面板创建/名称/目标路径/临时 UI 登记、设置关闭时非 res:// 目标落到兜率宫选择面板、强制信息面板关卡、掉落概率表与难度系数、模式复位五个标志、默认与别名怪物生成的命名/元数据/坐标。
- 验收：`check_all --godot-bin` 8/8；`scene_probe_runner` **10/10**；`level_1` 冒烟 PASS；全量 `level_regression_all` 128/128 PASS + 5 SKIP；`archive_probe_runner` 289/289；`coop_probe_runner` 26/26。
- Owner：玩法/关卡。

### W8 S7 收尾与 S8：无尽模式收口与通用工具静态化（完成，2026-10-30）

- `RunContext` 增加四个特殊副本无尽模式标志与 `selected_eight_immortal_id`，写入只经 `set_special_dungeon_endless(target_path, enabled)`（整体赋值：enabled 时只有目标副本为真，其余清零）、`clear_special_dungeon_endless()` 与 `set_selected_eight_immortal_id()`；读取走 `is_special_dungeon_endless(target_path)`。`Global` 删除 5 个字段并暴露同名 accessor，`apply_level_entry_mode_reset` 委托运行时。
- `Global.level_info` 页面里原先四行逐个赋值合并为一次 `Global.set_special_dungeon_endless(str(target_stage_path), bool(endless_mode))`；两处四行清零合并为 `Global.clear_special_dungeon_endless()`；四个副本脚本改为 `is_special_dungeon_endless(自身场景路径)` 与 `clear_special_dungeon_endless()`。
- 新增 `source/Script/tools/node_utils.gd`（`class_name NodeUtils`，39 行静态）：`ancestor`、`position_between`、`distance_between`。`ancestor` 保持动态返回类型以兼容业务节点的成员访问；`position_between` 保留“任一轴为 0 返回零向量”的历史语义。
- 新增 `source/Script/tools/item_utils.gd`（`class_name ItemUtils`，53 行静态）：`clean_fashion_name`（品质前缀 + 仙羽身体名映射）与 `random_item_entries`（原 `get_all_item_num` 的抽取与条目形状）。
- 新增 `source/Script/runtime/role_visual_runtime.gd`（`class_name RoleVisualRuntime`，104 行）：角色身体/装备静态贴图加载、当前角色 ID 解析、哪吒 SpriteFrames 静态预览，以及同槽位上一张贴图的释放。`Global` 保留 `load_role1_body`/`load_role1_eq` 薄转发与 `get_role_visual_runtime()`，两处清理点改调 `reset()`。
- 删除：`Global.get_ancestor`/`get_position_between`/`get_dis_betweem`/`get_clean_name`/`get_all_item_num`/`_current_role_id`/`_ne_zha_static_preview_texture` 与两个贴图槽位字段；`load_item_icon`、`add_all_item_num` 全仓无调用方，一并删除。
- 调用面迁移：`get_ancestor` 95 处、`position_between` 5 处、`distance_between` 5 处、`clean_fashion_name` 7 处、`random_item_entries` 7 处、`load_role1_body`/`load_role1_eq` 各 3 处（保留转发）；无尽模式 33 处。
- 新增探针 `scripts/scene_probes/utils_probe.{gd,tscn}`（`utils`，26 项）：祖先链与越界/空输入、方向向量归一化与轴对齐历史语义、距离、品质前缀与仙羽映射、随机条目形状/总次数守恒/零值剔除、角色身体与装备贴图加载、同槽位旧贴图释放与缓存回收。`level-entry` 探针扩到 25 项，新增无尽模式同一时刻至多一个副本为真、切换副本清掉上一个、进入副本清空自身与八仙选择。
- 验收：`check_all --godot-bin` 8/8；`scene_probe_runner` **11/11**；`archive_probe_runner` 289/289；`coop_probe_runner` 26/26；`level_1` PASS（0/0/0）；全量 `level_regression_all` 128/128 PASS + 5 SKIP。
- Owner：玩法/关卡 + 通用工具。

### 20-3A + S5 怪物展示族：HUD 面板只读规则与怪物展示工厂（完成，2026-10-30）

- `contract_scan` 新增第 19 类 `hud_panel_boundary`：`skill_icon.gd`、`pet_interface.gd`、`base_role.gd` 三个 HUD/面板域文件禁止 `MemoryClass.save_game/safe_write_archive/load_game` 与 `PlayerData.player_data[...] =` / `.attr =` 直写；保存只允许 `Global.request_save_with_feedback` / `MemoryClass.request_save`。自测 5 坏样本 / 6 好样本（含只读比较、非目标文件、注释放行）。
- 规则对当前实现全是负向校验（现有三个文件已满足）；`bone_forge.gd:196` 的 `PlayerData.player_data[slot_type] = equipped` 属同类直写，本批未纳入（缺 `PlayerData` 写入口方法），已登记为 20-3A 剩余项。
- 新增 `source/Script/runtime/monster_display_factory.gd`（`class_name MonsterDisplayFactory`，60 行）：怪物头像属性面板、Boss 信息面板与通用提示文本三个常驻场景槽位；`add_monster_head`/`add_monster_info`/`add_basic_moment_info`。`Global` 删除 3 个场景槽位字段，保留同名薄转发与 `get_monster_display_factory()`。
- `ui-factories` 探针扩到 90 项：新增族节点归属、三入口返回形状（名称/Boss 标记/场景路径/坐标/文本）、同槽位第二次实例独立、三个场景进入缓存。
- 验收：`contract_scan --self-test` 全类通过、`--fail-on-error` ERROR=0；`check_all --godot-bin` 8/8；`scene_probe_runner` 11/11；`archive_probe_runner` 289/289；`coop_probe_runner` 26/26；`level_1` PASS；全量 `level_regression_all` 128/128 PASS + 5 SKIP。
- Owner：UI（面板域）+ 玩法（怪物展示）。

### 20-3A 剩余四域 + S5 关卡提示族：装备写入口与提示场景归属（完成，2026-10-30）

- 新增 `PlayerData.update_equipped_item(slot_type, item) -> bool`：强化/洗练后写回人物穿戴栏的唯一字典写入口；槽位为空或首件不是字典时返回 `false`。`bone_forge.gd` 改调该方法，删除 `PlayerData.player_data[slot_type] = equipped`。
- `hud_panel_boundary` 扩展为面板/命令面板只读域：新增 `basic_task.gd`、`divine_forge.gd`、`synthesis.gd`、`bone_forge.gd`。自测扩到 7 坏样本 / 8 好样本，新增“原地清空列表”与“提交保存请求”放行（列表方法调用不属字典直写）。
- 新增 `source/Script/runtime/level_hint_factory.gd`（`class_name LevelHintFactory`，93 行）：掉落箱、道具箱（与掉落箱共用 `box_1.tscn`，元数据不同）、进入条件提示、回收提示与物品悬浮提示；`Global` 删除 4 个场景槽位字段，保留 5 个同名薄转发与 `get_level_hint_factory()`。
- `ui-factories` 探针扩到 **107 项**：新增两族的族节点归属、返回形状（掉落箱标记/道具箱总数量/提示坐标/`item_info`）、共用场景不串元数据、四个场景进入缓存。
- 验收：`contract_scan --self-test` 全类通过、`--fail-on-error` ERROR=0；`check_all --godot-bin` 8/8；`scene_probe_runner` 11/11；`archive_probe_runner` 289/289；`coop_probe_runner` 26/26；`level_1` PASS；全量 `level_regression_all` 128/128 PASS + 5 SKIP。
- Owner：UI/锻造 + 玩法。

### 20-3A 音频入口 + S5 阵法族：最后空洞与第六族（完成，2026-10-30）

- `contract_scan` 新增第 20 类 `audio_entry_boundary`：业务代码禁止 `AudioStreamPlayer.new(`、直引 `Scene/all_sound/` 场景与直读 `get_audio_runtime()` 的私有状态（`_active_bgm_instance`/`_active_sound_players`/`_last_sound_play_msec`/`_reserve_sound_voice`/`_pick_sound_victim`）；`Script/runtime/` 与 `global.gd` 放行。自测 4 坏样本 / 6 好样本（含 `Global.add_sound`、`AudioRuntime` 内部、`Global` 预热与注释放行）。该规则补上 Phase 17 登记的最后空洞。
- 新增 `source/Script/runtime/zhen_fa_factory.gd`（`class_name ZhenFaFactory`，104 行）：阵法说明、突破提示、阵眼疗伤等级、阵法信息、阵法类型按钮与阵眼按钮六个常驻场景槽位。`Global` 删除 6 个槽位字段、保留 6 个薄转发与 `get_zhen_fa_factory()`；`add_zhen_fa_ui` 全仓 0 调用方（含动态调用），随函数与槽位一并删除。
- `ui-factories` 探针扩到 **123 项**：新增阵法族六入口的返回形状（坐标/`father` 引用/阵法名/阵眼位号）与六个场景进入缓存。
- 验收：`contract_scan --self-test` 全 20 类通过、`--fail-on-error` ERROR=0；`check_all --godot-bin` 8/8；`scene_probe_runner` 11/11；`archive_probe_runner` 289/289；`coop_probe_runner` 26/26；`level_1` PASS；全量 `level_regression_all` 128/128 PASS + 5 SKIP。
- Owner：音频 + UI/阵法。

## 7. 守卫与验收

20-1B 决策本身的验收：

- 本页覆盖决策时 13 个 Autoload（当前 12 个；`BaseHit` 已删除），每项有结论、owner 与前置条件；
- 明确“不新增 Autoload、不设数量目标、不批量改名”的边界；
- 文档链接可达；`check_all --skip-engine` 通过；
- P1/P2 已按“迁移调用方、删除旧入口、同步探针”闭环；其余波次未执行。

后续 20-3 可增加的静态守卫（不在本轮实现）：

1. `project.godot` 的 `[autoload]` 条目冻结；新增/删除必须有本页或新 ADR 记录；
2. `Global` 公开成员与 `add_*` 数量设基线，新增需评审；
3. 禁止新增 `Global.<var> =` 的跨场景直接写入；先加 accessor；
4. 禁止 `/root/PlayerData`、`/root/RoleProp` 回落到 1P；仅保留已登记 getter；
5. 禁止新代码以 `Global` 作为 UI/音频/战斗/运行状态的万能上下文；
6. `MCPGameBridge` 仅在 `EngineDebugger.is_active()` 下工作，release 导出验证归 20-2。

## 8. 拒绝项与未决项

- **拒绝**：为每个切面新增 Autoload；把 `Global` 拆成多个 Manager 后继续全局访问；把存档 IO 搬出 `MemoryClass`；批量重命名 `PlayerData` / `RoleProp`；在未迁移调用方时保留永久兼容 facade。
- **已决（W8 S7A，2026-10-30 取证）**：`Global.is_ice`/`is_stun`/`is_mpo`/`is_poision`/`is_bleed`/`is_fire`/`is_speed_down`/`is_eye_fix`/`is_dead_link` 共 9 个减益标志在全仓只有 `= false` 写入（`grep` 全仓 `= true` 命中 0 处），仅 `monster_12`（`self_rhp`）与 `monster_37`（死亡链接 buff 守卫）各有一处读取，读取分支因此恒为常量。据此删除字段、116 处复位写与两处读取分支；`monster_12` 的 `self_rhp` 恒为 0、`monster_37` 恒加 buff，与删除前行为一致。证据与结论一并记录，不再作为拒绝项。
- **未决**：`RoleProp` 根回退的移除时机、`MLdl` 场景化、`Signals` 退出、`PlayerData` schema 类型化；均在对应波次立项。`Global` 运行状态 accessor 形状已在 W8 S7 定型。
- **已决（W8 S7C）**：`add_level_info`、`get_current_level_fall_pro`、`sync_level_drop_pro_data` 与非 res:// 直进分支迁入 `LevelEntryRuntime`；`create_monster` 与怪物路径解析迁入 `MonsterSpawnRuntime`；`Global` 保留同名薄转发与 `get_level_entry_runtime` / `get_monster_spawn_runtime`。四个无尽模式标志与 `selected_eight_immortal_id` 仍归 `Global`（关卡脚本直接读取），复位收敛为 `apply_level_entry_mode_reset()`，不谎报为已迁出。
- **已决（S5 怪物展示族）**：`add_monster_head`/`add_monster_info`/`add_basic_monment_info` 迁入 `MonsterDisplayFactory`（60 行，三个常驻场景槽位），`Global` 删除 `monster_head`/`monster_info`/`basic_monment_info` 三个场景槽位字段并保留同名薄转发与 `get_monster_display_factory()`；`add_boss_blood_instance` 早已在 `CombatPresentationFactory`。
- **已决（S5 关卡提示族）**：`add_level_fall_box`、`add_item_box`、`add_game_need_know`、`add_hc_help`、`add_help_thing` 迁入 `LevelHintFactory`（93 行，四个常驻场景槽位；掉落箱与道具箱共用 `box_1.tscn` 但元数据不同）；`Global` 删除 `level_fall_box`/`game_need_know`/`hc_help`/`help_thing` 四个槽位字段，保留同名薄转发与 `get_level_hint_factory()`。
- **已决（S5 阵法族）**：`add_zhen_fa_help`、`add_zhen_fa_tu_po`、`add_zhen_yan_cure_level`、`add_zhen_fa_info`、`add_zhenfalxbutton` 与同域的 `addzhenyanbutton` 迁入 `ZhenFaFactory`（104 行，六个常驻场景槽位）；`Global` 删除 6 个槽位字段并保留同名薄转发与 `get_zhen_fa_factory()`。`add_zhen_fa_ui` 全仓 0 调用方（含动态调用），随槽位一并删除。
- **未决（S5 剩余）**：`Global` 现有 120 个 `add_*`，其中 59 个已是族工厂的 4 行薄转发；其余 61 个仍持有场景槽位或实例化逻辑。按族推进，不一次性搬迁。下一批候选（按缓存归属价值排序，每批一族并各自补探针）：
  - 锻造/分解族：`add_forge_help`、`add_forge_box`、`add_forges`、`add_decompose_help`、`add_decompose_instance`。
- **已决（W8 S8 + 20-3 守卫批次）**：`get_ancestor`/`get_position_between`/`get_dis_betweem` 迁入 `NodeUtils.ancestor/position_between/distance_between`；`get_clean_name`、`get_all_item_num`、`get_wx` 迁入 `ItemUtils.clean_fashion_name/random_item_entries/random_element_set`（`get_random_wx` 降为 `ItemUtils` 私有）；`load_item_icon`、`add_all_item_num`、`check_dir_between_two_obj`、`normal_face_player` 全仓 0 调用方，直接删除；角色身体/装备贴图加载迁入 `RoleVisualRuntime`，`Global` 保留 `load_role1_body`/`load_role1_eq` 薄转发。运行状态字段直写与上述旧入口由 `contract_scan` 的 `run_state_boundary` 规则阻断。
- **已决**：`add_after_level_end` 的 `z_index = 9999` 属无效赋值（超出合法范围，从未生效），W6 S5 删除，不改渲染顺序。
- **未启动**：20-1A、20-1C、20-1D；本页不替其作采用/拒绝结论。
