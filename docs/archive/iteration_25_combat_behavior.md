# Phase 25 归档：战斗实体行为切片

> **归档日期**：2026-11-06
> **状态**：Archived；25-0 ~ 25-5 全部完成，Phase 25 已关闭。
> **关联**：当前行为映射见 [`../reference/combat_behavior_matrix.md`](../reference/combat_behavior_matrix.md)；前置阶段见 [`iteration_24_ui_growth_boundaries.md`](iteration_24_ui_growth_boundaries.md)；基础边界见 [`iteration_22_global_state_boundary.md`](iteration_22_global_state_boundary.md)。
> **职责**：本页保存 Phase 25 的行为切片、探针覆盖、验收与回滚边界；当前契约不在此复制。

---

## 1. 阶段边界

**目标**：在不改变战斗数值与时序的前提下，把 `BaseHero`/`BaseMonster` 中可独立生命周期的行为移出。

**前置**：Phase 22 的伤害/状态所有权稳定；建议在 Phase 24 之后启动，避免 UI 与实体同时迁移。

**非目标**：

- 不引入 ECS；
- 不重排继承；
- 不一次性拆完 `BaseHero`/`BaseMonster`；
- 不改碰撞层与动作时序。

**切片顺序**：25-0 映射 → 25-1 自动战斗 → 25-2 法宝展示 → 25-3 Boss 保护 → 25-4 受击/来源 → 25-5 验收。

---

## 2. 25-0 行为与验证映射

- 产出 [`combat_behavior_matrix.md`](../reference/combat_behavior_matrix.md)：
  - `BaseHero` 自动战斗的状态、输入、生命周期与失败路径；
  - `BaseMonster` 受击反应、控制免疫、Boss 保护、死亡与掉落映射；
  - 现有探针覆盖与缺口。
- 自动战斗基线：6 个 `_auto_battle_*` 字段、20 个 `_auto_battle*` 方法；目标/技能/移动可由显式上下文迁出。
- 受击基线：`state_hurt` 37 个文件（含基类与覆写）、`play_hit_effect` 3 个文件。
- 必须保持的现状：
  - 1P/2P 共用运行时开关；
  - 按 `coop_slot` 读取技能配置；
  - 自动重试归 `BaseThroughLevel`/胜利/失败/玲珑塔；
  - 手动 `is_t_mc` 与法宝输入仍可绕过自动分支。
- 现有 `coop`/`scene`/全量回归没有直接驱动自动战斗或受击代次的探针；25-1/25-4 后续补齐。
- 本批次未修改 `source/`，未改变数值/时序/输入映射。

---

## 3. 控制器切片

### 25-1 自动战斗控制器

**迁出**：

- `AutoBattleContext`：显式开关/配置/目标/技能/冷却/MP/动作/移动查询与受控命令，不持有节拍或游标；
- `AutoBattleController`：目标缓存/筛选、技能游标/计数、0.22s 节拍、移动/朝向/障碍跳跃，以及自动法宝 → 剑阵 → 无双的调用顺序。

**保留**：

- `BaseHero` 实体根、`_physics_process` 顺序、`get_skill`/`use_fb`/`ws_skill` 等公开能力、输入视图与死亡/场景生命周期；
- `BaseHero` 删除 6 个自动战斗字段与 20 个旧方法，保留 `is_auto_battle_target_valid`/`is_auto_battle_skill_active` 公开钩子；
- 角色 3/4/哪吒覆写改为公开钩子，玉兔索敌改走公开目标校验；
- `BaseThroughLevel` 的自动重试/转场不在本批迁移。

**探针**：`LocalCoopAutoBattleProbe` 覆盖 P1/P2 槽位配置、目标缓存/移动、真实 `slz` 起手与计数、无双短路、关闭清理、暂停、死亡、场景退出。

**未定向覆盖**：障碍跳跃、自动重试转场、手动输入冲突。

### 25-2 法宝展示实例

**迁出**：

- `MagicWeaponPresentationController`：按槽位档案持有当前 `BaseMagicWeapon` 展示实例与 active name；
- 负责装备切换、默认回退、移除、英雄退出清理；`_physics_process` 每帧 `tick`，保持空选择 → 装备名变化 → 缺失补建的旧顺序。

**保留**：

- `BaseHero` 删除 `mg_target`、`_active_magic_weapon_name`、`add_magic_weapon`、`null_szfb_case`、`on_szfb_change`、`check_remove_or_add_fb`，保留 `get_magic_weapon_target`/`get_active_magic_weapon_name` 只读入口与 `use_fb` 命令；
- `BaseMagicWeapon` 的 `is_use`/`is_canuse`/`fb_cd`/`usecd`/`skill_cd`、伤害与 `Global`/`MagicWeaponRuntime` 槽位归属不变；
- `user_key` 冷却读取改走公开入口。

**探针**：`LocalCoopMagicPresentationProbe` 覆盖 P1/P2 实例/槽位、切换、默认/退役回退、移除、`use_fb` 冷却与英雄退出清理。

**未覆盖**：HUD 实际绘制、所有法宝子类、完整死亡动画窗口。

### 25-3 Boss 保护状态

**迁出**：

- `BossProtectionController`：Boss 保护累计值、激活态、保护/白条计时与最近受击时间；
- `_process_boss_protect` 与 `_add_boss_protect_from_hit` 改为委托。

**保留**：

- 激活副作用仍由 `BaseMonster` 按旧顺序执行：清白条控制 buff、刷新控制免疫、重置技能冷却、停水平速度、清 `is_be_attacking`、设置半透明；
- `boss_blood` 改读 getter；`east_continent_monster` 覆盖改用 `is_boss_protecting()`；
- `settle_death_drops` 的 `death_drops_settled` 单一提交与塔层回调保持不变，不迁入保护控制器。

**探针**：`LocalCoopBossProtectionProbe` 覆盖保护激活、白条超时、控制免疫、技能重置、掉落唯一结算与重复调用。

**验收阈值**：Boss 连续受击至 **225** 触发保护；保护 **4.1s** 后结束，白条再持续 **4.0s** 后控免结束。

**未覆盖**：真实 Boss 血量/UI 绘制、所有 Boss 子类、完整死亡动画。

### 25-4 受击与来源归属加固

**迁出**：

- `HitReactionController`：受击反应 `active`、`generation` 与显式来源快照；
- `BaseMonster._begin/_finish/_cancel_hurt_reaction` 委托控制器；各族直接读取状态改用 `is_hurt_reaction_active()` / `get_hurt_reaction_generation()`。

**保留与加固**：

- `apply_role_hit` 进入受击反应时创建 `Snapshot`（实际来源目标、`BaseHero`、`hit_dic`），延迟回调经 `get_hit_reaction_source_player()` 读取，不依赖已恢复的临时字段；
- `play_hit_effect` 与 `tao_wu_boss` 捕获代次，`_deferred_play_hurt_animation(expected_generation)` 拒绝过期动画；
- `BaseMonster`/`BaseHero._exit_tree` 调用 `reset_hit_reaction_state()`，清活动反应、代次、`is_be_attacking`、待处理僵直与控制移动锁；不重置保护/白条；
- 特殊 `state_hurt` 分支保留。

**探针**：`LocalCoopHitReactionProbe` 覆盖零击退、连续受击代次、Boss/白条控免、`play_hit_effect` 竞争、P2 来源快照、无来源零伤害、生成/死亡早退、英雄/怪物退出重置；召唤物、弹体、法宝与 1P/2P 来源沿用 `LocalCoopAttributionSourcesProbe`。

**未覆盖**：37 个 `state_hurt` 特殊分支的逐帧动画，由全量回归补充。

---

## 4. 验证汇总

| 批次 | 验证结果 |
|:---|:---|
| 25-1 | `check_all` **9/9**（35.06s）；`health_check` **778 脚本 0/0/0**；`scene` **17/17**（158.41s）；`coop` **34/34**（188.69s）；`level_1` **4 阶段**（25.71s，0/0/0）；全量 **128/128 + 5 SKIP**（309.6s，无重试） |
| 25-2 | `check_all` **9/9**（34.82s）；`health_check` **779 脚本 0/0/0**；`scene` **17/17**（157.35s）；`coop` **35/35**（193.75s）；`level_1` **4 阶段**（24.68s，0/0/0）；全量 **128/128 + 5 SKIP**（306.1s，无重试） |
| 25-3 | `check_all` **9/9**（33.73s）；`health_check` **780 脚本 0/0/0**；`scene` **17/17**（157.65s）；`coop` **36/36**（203.57s）；`level_1` **4 阶段**（25.01s，0/0/0）；全量 **128/128 + 5 SKIP**（307.6s，无重试） |
| 25-4 | `check_all` **9/9**（32.88s）；`health_check` **781 脚本 0/0/0**；`scene` **17/17**（155.63s）；`coop` **37/37**（202.31s）；`level_1` **4 阶段**（25.07s，0/0/0）；全量 **128/128 + 5 SKIP**（301.0s，无重试） |
| 25-5 | `check_all` **9/9**（32.75s）；`health_check` **781 脚本 0/0/0**；`archive` **344/344**（10.54s）；`scene` **17/17**（153.38s）；`coop` **37/37**（202.31s）；`level_1` **4 阶段**（24.31s，0/0/0）；全量 **128/128 + 5 SKIP**（301.0s，无重试）；`docs_audit` **749 链接 / 0 缺失** |

---

## 5. 阶段验收

**结论**：四个行为切片相互独立，战斗结果与 Phase 24-4 基线一致；阶段出口满足，Phase 25 关闭。

| 切片 | 独立边界 | 定向探针 |
|:---|:---|:---|
| 25-1 自动战斗 | `AutoBattleContext` + `AutoBattleController` 由 `BaseHero` 持有；不调用法宝/保护/受击控制器 | `LocalCoopAutoBattleProbe` |
| 25-2 法宝展示 | `MagicWeaponPresentationController` 由 `BaseHero` 持有；不拥有冷却、伤害或槽位召唤归属 | `LocalCoopMagicPresentationProbe` |
| 25-3 Boss 保护 | `BossProtectionController` 由 `BaseMonster` 持有；激活副作用与掉落结算仍由怪物基类提交 | `LocalCoopBossProtectionProbe` |
| 25-4 受击状态 | `HitReactionController` 由 `BaseMonster` 持有；特殊 `state_hurt` 分支保留自身动画 | `LocalCoopHitReactionProbe` |

**独立性证据**：四个控制器均为独立 `RefCounted` 脚本；生产引用只出现在各自拥有者 `BaseHero`/`BaseMonster` 与探针；控制器之间无互相调用。

**基线一致性**：全量关卡保持 **128/128 PASS + 5 SKIP**；`level_1` 4 阶段 0/0/0；`LocalCoopDamageStatsProbe` 与 `LocalCoopAttributionSourcesProbe` 通过；`coop` 由 33 项扩展为 37 项，原有用例全部保留并通过。

**命名终审**：`naming_audit --all` 与 `whitelist_audit` 通过；`naming_compliance_audit --fail-on-error` 仍为 Phase 11-1 存量债务（目录 99.9679%、文件 99.9908%、代码 100%），未新增违规，不据此声明 L3/release 完成。

---

## 6. 回滚与实施边界

- 25-0 只新增矩阵与索引/状态文档，不改 `source/`。
- 25-1 保留 `MainSet` 配置键、`BaseHero` 公开入口、`BaseThroughLevel`/胜利/失败/玲珑塔的转场与保存职责；旧行为由版本控制回滚，不保留双实现。
- 25-2 `BaseMagicWeapon` 命令/冷却/伤害与 `Global`/`MagicWeaponRuntime` 槽位归属不变；控制器不读取 UI 或写共享资源。
- 25-3 只抽 Boss 保护/白条状态；阶段推进、伤害、保护阈值/时长、掉落结算与重战流程不变。
- 25-4 只统一受击状态/来源快照与退出重置；不改变伤害数值、Boss 保护阈值、白条时长、碰撞层或动作时序。
- 发现行为语义不明确时，先补探针和记录，再迁移；不以“代码更短”为迁移依据。

---

## 7. 关联文档

- [`../reference/combat_behavior_matrix.md`](../reference/combat_behavior_matrix.md)：当前行为状态、输入、生命周期与探针映射
- [`iteration_24_ui_growth_boundaries.md`](iteration_24_ui_growth_boundaries.md)：Phase 24 面板与成长命令边界
- [`iteration_22_global_state_boundary.md`](iteration_22_global_state_boundary.md)：`Global` 状态与入口收口
- [`../decisions/ADR-018-runtime-resource-cache-prewarm-and-pooling.md`](../decisions/ADR-018-runtime-resource-cache-prewarm-and-pooling.md)：对象池与运行期资源
- [`../reference/status.md`](../reference/status.md)：当前门禁与验证基线
