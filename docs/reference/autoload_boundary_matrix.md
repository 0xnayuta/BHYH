# Autoload 与 Global 拆分边界矩阵（Phase 20-1B）

> **状态**：2026-10-30 完成 20-1B 决策。本页只记录当前边界、逐项结论与迁移顺序，**不代表拆分已实施**；本轮未修改运行代码，未新增或移除 Autoload。
> **范围**：`source/project.godot` 的 13 个注册项：12 个业务单例 + `MCPGameBridge` 编辑器调试桥；重点为 `global.gd` 的职责切分。
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
| 20-1B `global.gd` + 13 Autoload | **采用边界清单，延期实施** | 本页；只决策，不大拆 |
| 20-1C `_bundled` 历史场景 | 未启动 | 需私有素材、UID/导入缓存与格式取证 |
| 20-1D 类型化 Atlas accessor | 未启动 | 依赖 19-3B 的 41 项未迁移图集范围 |

## 2. 量化基线

### 2.1 `global.gd` 规模

| 指标 | 数值 | 说明 |
|:---|:---|:---|
| 行数 | **6,041** | `source/global.gd` |
| 顶层函数 | **360** | 含私有函数；`add_*` 工厂 **124** 个 |
| 顶层变量 | **295** | 含运行状态、缓存、UI 引用与跨帧标记 |
| 顶层常量 | **76** | 含场景路径表、弹体路径表、怪物别名与特效脚本预载 |
| 信号 | **2** | `combo_milestone_reached`、`sound_settings_changed` |

### 2.2 调用面

静态扫描 `source/**/*.gd` 中的 `Global.<member>`：

| 指标 | 数值 |
|:---|:---|
| 引用文件 | **427** |
| 直接调用点 | **3,372** |
| 不同成员 | **273** |
| 外部直接写入 | **494** 次，涉及 **64** 个变量 |

包含 `scripts/**/*.gd` 探针时，引用文件 **432**、调用点 **3,586**、成员 **298**；诊断 API 的消费者主要在探针，不在生产路径。

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

Owner 口径：当前仓库为单人维护，owner 默认为项目维护者；表中“战斗/法宝”“UI/双人”等是批次审查责任域，不虚构人员姓名。

| # | Autoload | 当前职责 | 决策 | 证据与边界 | Owner / 前置条件 |
|:---:|:---|:---|:---|:---|:---|
| 1 | `BaseHit` | 上一次命中数值、类型与击退向量中转 | **删除候选（拒绝作为服务）** | 仅 `hit_bullet.gd` 的 4 处重置写入；全仓无读取、无场景/动态引用 | 战斗/法宝；静态复核后删除 Autoload 与 4 行写入，见试点 P1 |
| 2 | `RoleProp` | `BaseRoleProperties` 单例形态与启动回退 | **保留，延期迁移** | 大量文本引用是实例属性；真正的根回退位于 `BaseRoleProperties` / `PlayerDataStore` 的 getter | 角色/存档；先证明 `LocalCoop` 在启动与无槽位路径始终可用，再移除根回退 |
| 3 | `PlayerData` | 1P 档案数据仓库与补全 | **保留（1P 档案仓库）** | 菜单/地图可直接读取；新代码应走 `BaseObject.PlayerData`、`BaseRole.PlayerData` 或 `LocalCoop.data_for()` | 存档/1P UI；禁止新增直接 Autoload 读写；数据 schema 拆分延期 |
| 4 | `MemoryClass` | 本地存档加密读写、备份、后台保存、设置文件 | **保留（持久化边界）** | 230 处/72 文件；已有后台保存、补全、失败反馈与快照互斥 | 存档；不把存档 IO 搬进 `Global`，不再增加第二套保存入口 |
| 5 | `MainSet` | 设置字典、帧率、主菜单背景解锁 | **保留（设置）** | 393 处/65 文件；跨场景且自管设置 | 设置/UI；类型化设置 Resource 可作为后续独立项 |
| 6 | `AE` | 装备数值门面，懒加载装备表 | **保留（装备目录）** | 321 处/48 文件；无业务依赖 | 装备；不新增字段；静态 Resource 化单独立项 |
| 7 | `MLdl` | 锻造台 UI 会话状态 | **迁移候选（场景状态）** | 105 处/6 文件；仅 `qh_list`、`current_mode` | 锻造 UI；迁移到锻造台场景/面板持有状态，需面板开关与切档验证 |
| 8 | `PaSkill` | 被动技能数值表与灵魂收益 | **保留（被动数值）** | 52 处/8 文件；纯查表 | 被动/成长；不新增全局状态；静态化单独立项 |
| 9 | `MainMusic` | 主菜单 BGM 单实例 | **合并候选（音频运行时）** | 27 处/13 文件；自身又调用 `Global.add_bgm`，所有权重复 | 音频；并入 `AudioRuntime` 后删除，需 BGM 同曲/切曲/退出验证 |
| 10 | `Signals` | 全局确认框信号 | **保留，禁止新增全局信号** | 11 处/9 文件；`choose_pressed` 会清空旧连接 | UI；选择框迁移到显式信号后删除，需确认框流程验证 |
| 11 | `Global` | 场景流、UI 工厂、缓存、池、预载、音频、运行状态 | **拆分（本页边界）** | 6,041 行、360 函数、427 文件/3,372 调用、494 次外部写入 | 项目维护者（架构）；按第 4~5 节分波推进 |
| 12 | `LocalCoop` | 本地双人会话、槽位数据/属性/输入/面板 | **保留（双人会话）** | 285 处/78 文件；Phase 16/17 已建立槽位与面板边界 | 双人；不建第二组 Autoload；继续由显式槽位 API 服务 |
| 13 | `MCPGameBridge` | 编辑器调试桥 | **保留（调试桥，不计业务）** | 业务 `MCPGameBridge.` 引用为 0；`_ready` 在 `EngineDebugger.is_active()` 为假时退出 | 工具链；20-2 release 时验证 addon 路径、调试器门控与导出行为 |

## 4. `Global` 拆分边界

| 边界 | 当前内容（证据） | 目标归属 | 决策与顺序 |
|:---|:---|:---|:---|
| S1 诊断/快照 | 调试性能浮层 6 个函数；`get_cache_scope_snapshot`、`get_level_resource_lease_snapshot`、`get_preloaded_scene_slot_snapshot`、后台保存/失败状态；生产调用少，探针依赖 | `RuntimeDiagnostics`（`RefCounted` 或调试场景节点） | **先拆**；迁移 `scripts/scene_probes`、`scripts/archive_probes`，不新增 Autoload |
| S2 UI 宿主/运行时 | `windows`（158 读/12 写）、`_ui_popup_layer`、`_active_hover_popup`、`register_transient_ui` / `cleanup_transient_ui`、UI 实例登记与缓存、弹窗定位 | `UiHost`（场景节点）+ `UiRuntime`（`RefCounted`） | 第二；`LocalCoop` 面板改为显式 push/pop 栈；工厂函数暂留 `Global`，只迁移生命周期 |
| S3 音频 | `add_bgm`（125/94）、`add_sound`（138/34）、`stop_bgm`、SFX 语音上限/池、`_physics_process` 中的设置监听；`MainMusic` 重复持有 BGM | `AudioRuntime`（`RefCounted` 或场景服务） | 第三；合并 `MainMusic`；迁移后删除 `Global.add_bgm/add_sound` 与 `_last_sfx_*` 状态 |
| S4 场景/资源运行时 | `change_scene`（100/48）、缓存四表、单槽预载、线程预热、关卡租约、释放；约 88 个函数、214 次外部调用 | `SceneFlow` + `ResourceRuntime`（由 `Global` 组合持有） | 第四；保留 `Global.change_scene` 作为正式入口，先抽内部实现；不新增 Autoload |
| S5 UI 工厂 | 124 个 `add_*`；`add_message_show` 409、`add_level_info` 61、`add_choose_item` 40 等；大量场景/父节点参数 | 按功能族的 `UiFactory` / 场景构建器 | 第五，按功能分批；每批迁移调用方并删除旧 `add_*`，不建一个总工厂 |
| S6 战斗表现 | `add_bullet` 300/96、`add_buff` 108/66、`add_trap` 103/3、`add_special_effect` 81/20、`create_monster` 65/51、伤害数字/受击/池 | `CombatPresentation` / `SpawnService`（场景服务） | 第六；按弹体、buff、伤害数字、生成分批；需战斗探针与关卡回归 |
| S7 运行状态 | `current_level` 106 读/94 写、`llbt_level` 119 读/21 写、`total_*`、`is_*` 减益标志、`windows` 之外的运行标记；64 个变量、494 次外部写入 | `RunContext`（`Resource`）或 `BaseLevel` 持有；槽位状态走 `LocalCoop` | **最后**；先把写入改为显式 accessor/关卡上下文，再删字段；禁止直接搬进新 Autoload |
| S8 通用工具 | `get_ancestor` 95/16、`get_position_between`、`get_dis_betweem`、`get_clean_name`、物品计数、角色纹理加载 | 静态 `class_name` 工具类 | 可与 S1 并行；无状态、低风险，逐函数迁移 |
| S9 法宝/召唤 | `current_magic_summon`、`secondary_magic_summon`、`add_magic_weapon`、`get/set_magic_summon_for`、法宝预载 | `MagicWeaponRuntime`（场景/槽位持有） | 与 S6 同波或之后；需双人法宝归属验证，禁止回落 1P |

## 5. 迁移顺序

| 波次 | 范围 | Owner | 前置条件 | 验证 | 回滚 |
|:---|:---|:---|:---|:---|:---|
| W0 | 冻结：本页边界；不新增 `Global` 职责/字段 | 项目维护者 | 无 | 文档与链接检查；后续 20-3 守卫 | 文档回退 |
| W1 | 死代码/低风险：删除 `BaseHit`；删除已确认 0 引用的 `add_*` 辅助 | 战斗/UI | 静态扫描 `.gd`/`.tscn`/动态 `call`；确认无读取 | `health_check`、`level_1`、法宝命中冒烟、`contract_scan` | 版本控制 |
| W2 | S1 诊断/快照 | 资源/工具 | 探针调用点清单 | `scene_probes` 的租约/加载守卫、`archive_probes` 保存状态 | 恢复快照 API |
| W3 | S2 UI 宿主/运行时 | UI/双人 | `LocalCoop` 面板 push/pop 语义；临时 UI 登记清单 | `coop_probe_runner`、`scene_probe_runner`、面板开关/暂停 | 恢复 `Global.windows` |
| W4 | S3 音频 + `MainMusic` | 音频 | BGM 同曲/切曲/退出用例；SFX 池上限 | 主菜单/关卡 BGM 切换、SFX 音量/开关、退出清理 | 恢复 `MainMusic` |
| W5 | S4 场景/资源内部实现 | 资源/场景 | 加载页窄 API、租约、单槽预载、代次检查 | `load_guard`、`level_resource_lease`、`level_1` 加载、相关回归 | 保留 `Global.change_scene` 入口 |
| W6 | S5 UI 工厂，按功能族 | UI | 每族调用方清单与场景探针 | 对应面板/商店/背包/奖励探针 + `level_regression_all --changed-only` | 按族回退 |
| W7 | S6 战斗表现 + S9 法宝/召唤 | 战斗/法宝 | 弹体/buff/伤害/生成/双人归属用例 | 战斗探针、`coop_probe_runner`、受影响关卡回归 | 按族回退 |
| W8 | S7 运行状态 | 玩法/关卡 | 64 个变量、494 次写入的 accessor 迁移完成 | 全量 `level_regression_all`、档案探针、结算/重战 | 保留旧字段只读一版后删除 |

**顺序理由**：先处理无行为或低行为风险的诊断/死代码，再迁移叶子服务（UI 宿主、音频），然后处理中心资源运行时，最后迁移高频工厂与运行状态。`Global._exit_tree` 与 `change_scene` 是资源释放和场景流的正式入口，迁移时必须保留其可观察清理语义，不能用“搬字段”代替所有权迁移。

## 6. 试点建议

本轮不执行代码；下一轮可从以下两个试点开始，二者都不新增 Autoload。

### P1：删除 `BaseHit`

- 现状：4 处写入全在 `source/Script/magic_weapon/hit_bullet.gd`，全仓无读取、无 `.tscn`/动态引用。
- 动作：删除 `project.godot` 的 `BaseHit` 注册与 4 行重置；不动命中数值逻辑。
- 验收：`health_check` 0/0；`level_1` 与法宝命中冒烟；`contract_scan`；确认 Autoload 数 13→12、无启动顺序回归。
- Owner：战斗/法宝。

### P2：抽取 `RuntimeDiagnostics`

- 现状：调试浮层与快照 API 生产调用少，探针依赖明确。
- 动作：新建 `RefCounted` 诊断服务；由 `Global` 或调试节点持有；迁移探针调用；删除 `Global` 中对应函数与调试状态。
- 验收：`scene_probes` 的 `load_guard` / `level_resource_lease`、`archive_probes` 的保存状态；`check_all`。
- Owner：资源/工具。

## 7. 守卫与验收

20-1B 决策本身的验收：

- 本页覆盖 13 个 Autoload，每项有结论、owner 与前置条件；
- 明确“不新增 Autoload、不设数量目标、不批量改名”的边界；
- 文档链接可达；`check_all --skip-engine` 通过；
- 本轮不改运行代码，因此不以引擎/关卡回归替代文档验收。

后续 20-3 可增加的静态守卫（不在本轮实现）：

1. `project.godot` 的 `[autoload]` 条目冻结；新增/删除必须有本页或新 ADR 记录；
2. `Global` 公开成员与 `add_*` 数量设基线，新增需评审；
3. 禁止新增 `Global.<var> =` 的跨场景直接写入；先加 accessor；
4. 禁止 `/root/PlayerData`、`/root/RoleProp` 回落到 1P；仅保留已登记 getter；
5. 禁止新代码以 `Global` 作为 UI/音频/战斗/运行状态的万能上下文；
6. `MCPGameBridge` 仅在 `EngineDebugger.is_active()` 下工作，release 导出验证归 20-2。

## 8. 拒绝项与未决项

- **拒绝**：为每个切面新增 Autoload；把 `Global` 拆成多个 Manager 后继续全局访问；把存档 IO 搬出 `MemoryClass`；批量重命名 `PlayerData` / `RoleProp`；在未迁移调用方时保留永久兼容 facade。
- **拒绝**：把 `Global.is_ice` 等写多读少的旧标志直接当作可删除死代码；`monster_12` / `monster_37` 仍有读取，删除会改变行为，需单独行为验证。
- **未决**：`RoleProp` 根回退的移除时机、`MLdl` 场景化、`MainMusic` 合并、`Signals` 退出、`PlayerData` schema 类型化、`Global` 运行状态 accessor 的具体形状；均在对应波次立项。
- **未启动**：20-1A、20-1C、20-1D；本页不替其作采用/拒绝结论。
