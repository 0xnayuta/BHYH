# 玩法与表现调用面矩阵（Phase 17-1）

> **状态**：Phase 17-1 只读调查完成（2026-10-29）；17-2A 来源显式化、17-2B 池化复用清理、17-2C 归属回归、17-3 关卡阶段/结算、17-4 成长命令、17-5 HUD/输入/音频边界、17-6 模块 API/场景依赖治理与 17-7 边界守卫已实施（2026-10-29），Phase 17 已归档。§1~§11 保留 17-1 基线与失败边界，17-2A~17-7 的修复与剩余差距见 §12~§19。
>
> **调查基线**：Phase 16 归档后的 `4e4c311`（2026-10-29）；仓库只有一个活跃工程 `source/`。
>
> **方法**：以 `source/**/*.gd`、`source/*.gd`、`source/project.godot` 与 `source/Scene/**/*.tscn` 为唯一事实源，使用静态扫描（正则计数）与关键函数逐行阅读。下文计数是**静态行数/出现次数**，可能包含条件分支、重复调用与暂时不可达路径，不等同于运行期次数；口径在每张表标题处注明。
>
> **范围**：命中归属、弹体/召唤/法宝来源、对象池复用、关卡阶段与结算、成长系统提交、HUD/输入/音频表现、模块公开 API 与场景依赖。数值公式、动画帧率、掉落表、输入映射内容、存档格式与 Phase 16 已收口的档案/槽位边界不在本页改写范围。

---

## 1. 结论摘要

1. **伤害归属有唯一入口，但有 1P 兜底**：怪物受击统一进入 `BaseMonster.apply_role_hit`（`base_monster.gd:1659`），解析顺序为「显式 `source_player` → 载体字段/祖先 → `LocalCoop.owner_hero` → `RoleProp.source_player`」。前四级可归属到 2P；最后一级是全局别名，命中后无法区分槽位。
2. **归属字段分散在 6 类载体**：`BaseHero`、`RoleBullet`/`RoleBullet1`/`Role1Shallow`/`RolehmzBullet`、`BaseMagicWeapon`/`MagicWeaponHit`/`MgHit`、`SummonBaseMonster`、`MonsterBullet`、`BaseMonster`。英雄侧字段名为 `player`，召唤侧为 `summoner`/`player_reference`，怪物侧为 `get_player`，弹体还依赖祖先链与 `coop_damage_slot` 快照。
3. **`coop_damage_slot` 是唯一显式归属快照**：共 11 处 / 2 文件，只在 `BaseMonster.apply_role_hit` 与 `bind_role_damage_source` 中写入并在结束时恢复；`LocalCoop.slot_for` 优先读取该 meta（`local_coop.gd:426`）。
4. **`RoleProp.source_player` 仍是最大 1P 假设**：121 次 / 47 文件；每个 `BaseHero._ready` 都会覆盖它（`base_hero.gd:297`），2P 与 1P 的 `_ready` 顺序决定值；47 个文件中包含 5 个 `Scene` 表现脚本。
5. **`Global.get_player` 只指向 1P**：15 次 / 9 文件；只在 `Global.call_hero` 的 `player_slot == 1` 分支赋值（`global.gd:5258`），2P 永不写入。用于提示、怪物目标与 `dj_sell` 的全局状态写入。
6. **效果归属存在跨槽位读取**：吸血倍率取自全局 `RoleProp.roleprop`（`base_monster.gd:1867`，17-2A 已改为按出手者），腾蛇阵等级取自 1P `PlayerData`（`:1876`，17-2A 已改为按出手者），角色 5 被动等级取自 1P `PlayerData`（`:1886`，17-2A 已改为按出手者）；治疗/无双入账已使用实际 `source_player`。
7. **对象池只有 4 类**：`damage_text`/`mr_hurt`/`role_be_hit`/`sound_player`，上限 80/32/24/32（`global.gd:119-123`）。取出入口不重置节点；重置由各节点自己的 `setup()`/`recycle()` 完成。`damage_text` 另有 `prepare_for_pool()` 仅用于预热。
8. **关卡阶段由 `BaseLevel.current_stage` 单一持有，但写入面分散**：535 行 / 97 文件引用，31 行含声明（30 处赋值）；`BaseLevel` 8 处按角色 x 坐标推进，关卡子类/怪物脚本 22 处直接赋值。阶段推进、刷怪与出口判定都在 `BaseThroughLevel`，但子类可绕过。
9. **胜败切换有两套入口**：出口离开走 `_leave_level_from_exit`（`base_through_level.gd:1366`），死亡走 `BaseHero` 两个死亡分支（`base_hero.gd:716`、`:1680`）；两者都可能在 1.5s 等待后重复调用 `change_scene(defeat)`。
10. **关卡域保存点 10 处**：`victory` 1、`defeat` 3、`hdzm` 1、`level_17` 1、`level_bxgh` 1、`level_esbxx` 1、`level_llbt` 1、`level_zhen_yao_tower` 1。17-3 后结算保存经 `LevelSettlement` 判读；返回按钮不再重复保存，`defeat._on_lqjl_pressed` 已保存并持久领取标志。
11. **成长系统已有可参考的事务实现**：`forge.gd` 采用「快照 → 先加产物并检查 bool → 扣材料 → 保存 → 失败恢复」；其余商店/合成/神铸/淬骨/强化/技能仍为「先扣费/先提交，再产出」或无回滚。
12. **`PlayerData` 原语失败语义不一致**：`spend_soul`、`add_zb`、`add_fb` 返回 `bool`；`add_dj`、`add_xhp` 返回 `void` 且容量不足时静默丢弃。商店对可选堆叠物没有容量前置校验，扣费后可能拿不到道具。
13. **HUD 已显式注入玩家**：`RoleInformation` 为 P1/P2 分别设置 `role_p1.player`/`role_p2.player`（`role_information.gd:47-60`）；`BaseRole` 仍保留 `RoleProp.source_player` 兜底（`base_role.gd:82`、`:98`）；其 `_set_values` 直接读全局 `RoleProp`，P2 HUD 的血蓝/经验/无双因此仍显示 1P 值。
14. **输入与音频是表现层调用面**：`Input.is_action*` 63 行 / 20 文件；`CoopInput` 通过 `p2_` 前缀生成 2P 动作。`Global.add_sound` 138 次 / 34 文件，带 45ms 节流、每音效 4/8 与总声部 24/48 上限；`Global.add_bgm` 125 次 / 94 文件，每次实例化且不停止旧 BGM。
15. **模块公开 API 无清单**：`BaseHero` 128、`BaseMonster` 103、`SummonBaseMonster` 69、`PlayerData` 124、`Global` 265 个公开方法；基础类没有自定义信号，模块间以直接调用为主。节点访问共 699 处（`get_node` 168 + `get_node_or_null` 531），其中字面深层路径 279 处 / 66 文件，`/root` 34 处 / 13 文件。
16. **直接数据写入集中在关卡进度与菜单状态**：`PlayerData.player_data` 下标赋值 **145 行 / 42 文件**（含属性赋值 197 行 / 44 文件）；热点 `base_through_level.gd` 29、`game_announcement.gd` 14、`base_monster.gd` 13、`c_hange_clothes_jm.gd` 8、`zhen_yao_tower.gd` 8、`local_coop.gd` 6。按目录：`main_menu` 51、`base` 46、`level` 12、`back_pack` 8、`other_menu` 8、`coop` 6、`Scene` 5、`skill` 4。

---

## 2. 数据三分类与不变量

| 类别 | 载体 | 所有者 | 本阶段边界 |
|:---|:---|:---|:---|
| **静态定义** | `AE.all_equipment`、`DataKeys`、技能/材料表、关卡刷怪表、场景路径常量 | 各模块常量与 `Resource` | 只读；不得在运行时改写 |
| **实例状态** | `BaseLevel.current_stage`、`monster_group`、`BaseHero`/`BaseMonster` 字段、`LocalCoop` 槽位、`PlayerData.player_data` | `BaseLevel`、实体自身、`LocalCoop`、`PlayerData` | 本页只登记所有者/写入者；迁移按试点域闭环 |
| **表现资源** | 对象池节点、伤害文本、受击特效、音效、BGM、HUD 控件 | `Global` 与各场景脚本 | 表现层不得提交领域状态；池化必须清理旧状态 |

不变量：

- 不改变伤害公式、Buff 数值、掉落规则、关卡时序、输入映射内容与动画帧率；
- 不新增 Autoload，不重写 `base_hero`/`base_monster`/`base_through_level` 继承结构；
- 档案会话、共享账本、槽位查询与 `request_save` 边界沿用 Phase 16 结论；
- 一个职责迁移时同步迁移全部生产调用方，不保留永久 facade。

---

## 3. 总览矩阵

| 状态/能力 | 所有者 | 写入者 | 读取者 | 失效/清理事件 | 当前失败语义 |
|:---|:---|:---|:---|:---|:---|
| 攻击者/归属 | `BaseMonster.apply_role_hit`（伤害侧）；各载体自身字段（来源侧） | 攻击创建入口、命中解析、`coop_damage_slot` 快照 | 伤害、Buff、吸血、无双、掉落、HUD | 命中结束恢复字段；实体释放；槽位切换 | 缺失来源时回落 `RoleProp.source_player` → 1P；无告警 |
| 对象池实例 | `Global._pool_data` | `_take_pooled_node` / `_store_pooled_node` / 各 `recycle_*` | 伤害文本、受击特效、受击音效 | 归还前节点自清理；战斗结束；退出清理 | 取出不重置；容量满时新建；池上限满时 `queue_free` |
| 关卡阶段 | `BaseLevel.current_stage` | `BaseLevel._on_create_control_timeout`（8 处）；关卡子类/怪物脚本 22 处直接赋值；`monster_14501` 跨节点写 | 刷怪、HUD、相机、出口判定、怪物 AI | 关卡释放；重战；切场景 | 子类可绕过阶段表；无统一 `advance_stage()` 守卫 |
| 胜败/结算 | `BaseLevel._leave_level_from_exit`（胜）；`BaseHero` 死亡分支（败） | 出口输入/自动战斗、死亡等待、结算场景 `_ready` | HUD、地图、存档、重战 | 返回地图、重战、自动重试 | 重复 `change_scene`；保存 bool 被丢弃；奖励无回滚 |
| 成长提交 | 各域脚本（商店/锻造/强化/合成/技能/奖励） | 购买、锻造、学习、领取按钮 | 面板、背包、属性、存档 | 面板关闭、失败回滚、场景退出 | 扣费与产出顺序不一致；部分域无回滚 |
| HUD/表现 | `BaseRole`/`RoleInformation`、面板脚本 | 查询命令、显式 `player` 注入 | 玩家 | 面板关闭、场景退出 | `RoleProp.source_player` 兜底；表现场景可直接写档 |
| 模块 API | 各模块脚本 | 模块作者 | 调用方 | 重构/迁移 | 无公开清单；深层路径 279 处；基础类无信号 |

---

## 4. 攻击者与归属

### 4.1 载体、来源字段与创建入口

| 载体 | 类/文件 | 来源字段 | 创建入口（静态调用数） | 归属解析 |
|:---|:---|:---|:---|:---|
| 英雄近战 | `BaseHero` / `base_hero.gd` | 自身即来源 | 场景实例；`Global.call_hero` | 直接传入 `apply_role_hit` |
| 英雄弹体 | `RoleBullet`（4 个子类）、`RoleBullet1`、`Role1Shallow`、`RolehmzBullet` | `player` | `Global.add_role_bullet` 36、`add_role_bullet_1` 1、`add_role_bullet_1_safe` 2、`call_chase_bullet` 20、`call_fly_bullet` 36 | `player`；否则祖先 1~4 层；否则 `owner_hero`；否则 `RoleProp.source_player` |
| 法宝 | `BaseMagicWeapon`（24 个子类）、`MagicWeaponHit`、`MgHit` | `player` / `source_weapon` | `Global.add_magic_weapon` 2（均传 `self`；另有 4 处 `BaseHero.add_magic_weapon()` 本地包装） | 载体字段 → `owner_hero` → `RoleProp.source_player` |
| 召唤物 | `SummonBaseMonster`（5 个子类） | `summoner`、`player_reference`、meta `is_summon` | 4 处直接 `instantiate()` + `set_summon_properties` | `summoner` → `RoleProp.source_player` → 场景 `Hero` 下第一个 `BaseHero` |
| 怪物弹体 | `MonsterBullet`（17 个子类） | `my_father`、祖父节点、`RoleProp.source_player` | `Global.add_bullet` 300、`add_weapon_bullet` 22（武器弹体）、`add_special_effect_bullet` 12、`load_monster_bullet_scene` 2 | 怪物侧伤害目标是英雄；`my_father` 用于伤害加成 |
| 怪物 | `BaseMonster` | `get_player`（默认 `Global.get_player`） | 关卡刷怪表、召唤、分裂 | 受击时按 §4.2 解析 |

补充：

- `Global.add_new_bullet` 只有定义（`global.gd:3782`），无调用方；`add_role_bullet_1` 仅 1 处调用，`add_role_bullet_1_safe` 2 处。
- `Global.add_role_bullet` 只设置 `_name`/`hit_dic`/`direction`，不设置 `player`；`RoleBullet._physics_process` 首次运行时从祖先链回填 `player`。
- `Global.add_magic_weapon` 在 `source_player != null` 时设置 meta `coop_slot` 与 `player`（`global.gd:4706-4707`）；生产调用均传 `self`。
- `SummonBaseMonster` 的召唤弹体带 `is_summon_bullet` 与 `summoner` meta（`summon_base_monster.gd:1284-1287`）。

### 4.2 解析顺序与回退

`BaseMonster._get_damage_source_player`（`base_monster.gd:1827`）：

1. `target is BaseHero` → 直接返回；
2. `RoleBullet`/`RoleBullet1`/`Role1Shallow` → `player`/`Player`/`my_owner` → 祖先 4 层；
3. `BaseMagicWeapon` → `player`/`Player`；
4. `MagicWeaponHit` → 父节点 `BaseMagicWeapon.player`；
5. `MgHit` → `source_weapon.player`；
6. `LocalCoop.owner_hero(target)` → 沿持有者字段回溯；
7. 仍为空 → 返回 `null`，本次伤害被丢弃（`apply_role_hit` 直接返回 0）。17-2A 已删除原第 7 步的 `RoleProp.source_player` 回落。

`LocalCoop.slot_for`（`local_coop.gd:421`）的遗留解析顺序：

1. 全局别名 `PlayerData`/`RoleProp` → 1；
2. meta `coop_damage_slot`；
3. `BaseMonster.get_player.coop_slot`；
4. 祖先链 meta `coop_slot`；
5. `owner_hero()` 回溯 `BaseHero.coop_slot`；
6. `MyFather`/`owner_monster`/`source_monster` 回溯；
7. 脚本路径前缀（`back_pack`/`skill`/`other_scene`/`magic_weapon`）→ `ui_slot`；
8. 默认 1。

### 4.3 仍假定 1P 的入口（17-1 基线；17-2A 状态见 §12）

| ID | 位置 | 事实 | 影响 |
|:---|:---|:---|:---|
| GM-01 | `base_hero.gd:297` | 每个英雄 `_ready` 写 `RoleProp.source_player = self` | 2P 后加载会覆盖 1P；所有读全局别名的代码按最后加载者归属 |
| GM-02 | `global.gd:5258` | `Global.get_player` 仅在 `player_slot == 1` 时赋值 | 2P 目标、提示、`dj_sell` 永远拿到 1P |
| GM-03 | `base_monster.gd:1865`（17-1） | `_get_damage_source_player` 最后回落 `RoleProp.source_player`；**17-2A 已删除** | 无来源时伤害为 0，不再归 1P |
| GM-04 | `role_bullet.gd:165`、`:409` | `player` 由祖先链回填；觉醒效果再回落 `role_props.source_player`；**17-2A 已删除回落，根节点弹体显式传源** | 无来源弹体不再借用 1P |
| GM-05 | `summon_base_monster.gd:239` | `find_player_reference` 在 `summoner` 非英雄时回落全局别名，再取场景 `Hero` 第一个子节点 | 非英雄召唤（怪物/法宝）跟随 1P |
| GM-06 | `base_monster.gd:544` | 怪物生成后 `get_player = Global.get_player` | 未绑定来源的怪物默认 1P |
| GM-07 | `base_monster.gd:1867`、`:1876`、`:1886` | 吸血倍率读 `RoleProp.roleprop`；腾蛇阵等级读 1P `PlayerData`；角色 5 被动等级读 1P `PlayerData`；**17-2A 已改为 `LocalCoop.props_for/data_for(source_player)`** | 2P 使用自身吸血/技能等级 |
| GM-08 | `base_role.gd:82`、`:98`、`:202` | HUD 在 `player == null` 时回落 `RoleProp.source_player`；`_set_values` 直接读全局 `RoleProp` | 正常路径由 `RoleInformation` 注入；P2 血蓝/经验/无双仍显示 1P 值 |
| GM-09 | `dj_sell.gd:690`、`:945` | 面板用 `Global.get_player` 判空，随后写全局 `PlayerData`/`RoleProp` | 2P 操作时作用到 1P |
| GM-10 | `monster_bullet.gd:769`、`:2579` | 敌方弹体读取 `RoleProp.source_player` 决定效果/目标 | 2P 场景下目标可能落到 1P |

### 4.4 效果归属

| 效果 | 读取/写入位置 | 归属判定 | 失败/漂移点 |
|:---|:---|:---|:---|
| 伤害 | `apply_role_hit`（`base_monster.gd:1659`）→ `get_role_last_hurt` | 显式 `source_player` + `coop_damage_slot` 快照；暴击/护甲/等级按出手者（17-2C） | 来源为空 → 伤害 0 |
| Buff | `apply_role_hit` 内的 `Global.add_buff`、弹体 `addeffect` | Buff 挂在目标；来源只用于数值 | 来源不影响 Buff 所有 |
| 吸血 | `_apply_damage_vampirism`（`:1901`）→ `_get_vampirism_rate`（`:1867`） | 治疗给 `source_player`，倍率读该英雄属性（17-2A） | 无来源时不吸血 |
| 无双 | `cure_ws_value`（`:2581`） | `LocalCoop.props_for(source_player)` | 归属正确；入口在 `apply_role_hit` |
| 腾蛇阵 | `apply_role_hit`（`:1688`）→ `_get_tszz_level`（`:1876`） | 等级读 `LocalCoop.data_for(source_player)`，增伤写 `source_player.tszzs` | 2P 用自身等级（17-2A） |
| 角色 5 被动 | `role5_bullet`（`:1796`）→ `_get_role5_skill_level`（`:1886`） | 目标/治疗用 `get_player`，等级读 `LocalCoop.data_for(get_player)` | 2P 用自身技能等级（17-2A） |
| 掉落/结算 | `Global.total_*_hit`、`Global.most_lianji`（连击统计） | 全局聚合 | 统计不区分槽位；不属于结算入账 |

---

## 5. 对象池

### 5.1 四类池

| 池 | 上限 | 预热数量 | 取出入口 | 归还入口 | 复用前清理 |
|:---|:---|:---|:---|:---|:---|
| `damage_text` | 80 | 12 | `Global.add_damage_text` | `damage_text.recycle` → `Global.recycle_damage_text` | `setup()` 重置数值/类型/暴击/目标/透明度；`prepare_for_pool()` 仅预热 |
| `mr_hurt` | 32 | 16 | `Global.add_mr_hurt` | `monster_be_hit.recycle` → `Global.recycle_mr_hurt` | `_play_hurt_animation()` 重置可见/动画；`modulate` 在取出时置白 |
| `role_be_hit` | 24 | 16 | `Global` 受击效果入口 | `role_be_hit_effect.recycle` → `Global.recycle_role_be_hit` | `setup()` 重置帧/可见/颜色/翻转/速度 |
| `sound_player` | 32 | 6 | `Global.add_sound` | `_on_finished` → `Global.recycle_sound_player` | `setup()` 重置目标/流/音量；`finished` 时清空 |

### 5.2 取出/归还路径

```text
_take_pooled_node(pool, scene_path)       # 弹出有效节点，否则 instantiate
  └─ 不重置节点；不校验场景类型
_attach_pooled_node(node, parent)         # 先 remove_child 再 add_child
_store_pooled_node(node, pool, max_size)  # 超过上限直接 queue_free
  └─ 节点自身 recycle()/setup() 负责状态清理
_clear_runtime_pools()                    # 退出/重载：stop、stream=null、queue_free
```

- `add_damage_text` 另有 80 个活动节点上限与按物理帧重算（`global.gd:4171-4200`）；
- `add_sound` 有 45ms 同音效节流、同音效 4/8、总声部 24/48 上限（`global.gd:495-498`、`:4278`）；
- `add_mr_hurt` 按目标实例 55ms 节流（`global.gd:5332`）；
- 池根节点 `RuntimePool` 挂在 `Global` 下，随 `_clear_runtime_pools` 释放；
- 17-2B 后，四类池节点统一实现 `prepare_for_pool()`；`_store_pooled_node` 与 `_seed_runtime_pool` 调用该钩子，`_take_pooled_node` 不做重置。

### 5.3 残留状态与验证点

| ID | 事实 | 风险 | 17-2 验证 |
|:---|:---|:---|:---|
| GM-11 | `_take_pooled_node` 不调用 `prepare_for_pool`、不校验类型 | 节点未经过 `recycle()` 就回到池时携带旧文本/目标/动画 | 两轮复用后断言 `target`/`type`/`is_crit`/`visible` |
| GM-12 | `damage_text` 的 `target` 是 `BaseObject` 弱引用 | 目标释放后仍被旧节点引用 | 目标 `queue_free` 后复用一轮 |
| GM-13 | `mr_hurt` 的 `recycle()` 未清 `modulate` | 复用节点颜色由取出方重置；漏设时继承上一轮 | 连续受击两轮截图/属性 |
| GM-14 | `role_be_hit`/`sound_player` 依赖自身 `_recycled` 守卫 | 双重归还被忽略，但节点可能已被 `queue_free` | 连续调用 `recycle()` 两次 |
| GM-15 | 池内节点没有攻击者/来源字段 | 归属不因池化漂移；残留风险集中在显示状态 | 归属回归与池复用分开验证 |

---

## 6. 关卡阶段

### 6.1 所有者与写入者

- 所有者：`BaseLevel.current_stage`（`base_through_level.gd:37`），初值 0，合法阶段 1~4；
- 引用面：535 行 / 97 文件；
- 赋值点：31 行含声明（30 处赋值），`BaseLevel` 8 处 + 关卡子类/怪物脚本 22 处。

| 写入者 | 位置 | 方式 |
|:---|:---|:---|
| `BaseLevel._on_create_control_timeout` | `base_through_level.gd:1647` | 按 `_role.position.x` 阈值推进；普通/双子场景两套阈值 |
| `Level20` | `level_20.gd:24` | `_ready` 直接置 4 |
| `Level35` | `level_35.gd:231` | 直接置 2 |
| `Level46` | `level_46.gd:58`、`:99` | 置 1 / `BOSS_STAGE` |
| `Level47` | `level_47.gd:261` | 置 1 |
| `Level48` | `level_48.gd:471` | 置 `stage` 参数 |
| `Level59` | `level_59.gd:497` | 置 `stage` 参数 |
| `LevelBxgh` | `level_bxgh.gd:319` | 置 1 |
| `LevelEsbxx` | `level_esbxx.gd:210` | 置 1 |
| `LevelLhhj` | `level_lhhj.gd:64` | 置 1 |
| `LevelLlbt` | `level_llbt.gd:239`、`:248` | 置 1 |
| `LevelSssl` | `level_sssl.gd:137-151` | 按分支置 1~4 |
| `LevelZhenYaoTower` | `level_zhen_yao_tower.gd:342` | 置 1 |
| `NorthContinentLevel` | `north_continent_level.gd:203`、`:419` | `index + 1` / 重置 0 |
| `game4_imported_level` | `game4_imported_level.gd:195` | 置 `stage` 参数 |
| `monster_14501` | `monster_14501.gd:350` | 给 `next_boss.current_stage` 写 `+1`（跨节点写） |

### 6.2 推进与刷怪

| 能力 | 入口 | 行为 | 失败边界 |
|:---|:---|:---|:---|
| 阶段推进 | `_on_create_control_timeout` | x 阈值逐级 0→1→2→3→4；每次定时器触发也预载与刷怪 | 无统一 `advance_stage`；只前进不后退；瞬移时逐次触发补齐 |
| 刷怪前置 | `check_can_create(stage)` | 阶段 1~4、`monster_group` 有剩余、存活怪 < `6 * CreateMonsterCount` | 表缺失/坐标为空 → `push_error` 并清空该阶段 |
| 刷怪 | `level_create_monster(stage)` | 从 `monster_group`/`monster_position_x/y` 队首取一条并 `Global.create_monster` | 数组为空直接返回；不补位 |
| 资源预载 | `_request_stage_resource_preload(stage + 1)` | 预载下一阶段 | 阶段越界不预载 |
| 相机 | `change_mysee` | 按 `current_stage` 调 `max_right` | 子类可覆写 |
| 阶段完成 | `check_can_pass` | 当前阶段表空且存活怪 0 | 只对 1~4 有效 |
| 出口 | `check_can_exit`/`one_check_can_exit` | 当前阶段为最后阶段且清空 | `one_check_can_exit` 为快速路径 |
| 全部完成 | `always_can_pass` | 恒真，供特殊关卡覆写 | 子类可绕过清怪条件 |

### 6.3 胜败与出口切换

- 胜：`_physics_process` 在出口条件满足时 `preload_next(victory.tscn)` 并启用 `exit`/`exit_2`；玩家按 `Exit` 或 `p2_Exit`，或自动战斗开启时，调用 `_leave_level_from_exit`（`base_through_level.gd:1366`）。
- `_leave_level_from_exit` 先 `add_tg(level_stage)` 写入通关进度，再按关卡类型切换（`victory.tscn`、剧情场景或重战）。
- 败：`BaseHero` 两条死亡分支在 1.5s 后检查 `LocalCoop.all_players_dead()`，然后 `change_scene(defeat.tscn)`（`base_hero.gd:716`、`:1680`）。
- 自动重试：胜利场景 `_auto_rechallenge` 与失败场景 `_auto_rechallenge` 都调用带 `_is_rechallenging` 守卫的重战入口；关卡侧 `_restart_level_for_auto_battle` 直接保存并重载。

### 6.4 重复推进/切换候选

| ID | 事实 | 风险 |
|:---|:---|:---|
| GM-16 | 两个死亡分支各自 `await 1.5s` 后调用 `change_scene(defeat)` | 双人同时死亡可触发两次切换 |
| GM-17 | `change_scene` 无「切换中」早退守卫 | 出口/自动战斗/死亡路径并发时重复加载 |
| GM-18 | 子类/怪物 22 处直接写 `current_stage` | 绕过阶段表与完成判定，可能跳过 `monster_group` 清理 |
| GM-19 | `monster_14501` 跨节点写 `next_boss.current_stage` | 阶段所有权越界；Boss 自身状态可能未初始化 |
| GM-20 | `_on_create_control_timeout` 只前进不后退；`NorthContinentLevel` 可重置 0 | 重开/传送后阶段与已清怪物不一致 |

---

## 7. 胜败与结算

### 7.1 结算场景提交

| 场景/入口 | 写入 | 保存 | 守卫 | 失败语义 |
|:---|:---|:---|:---|:---|
| `victory.gd:_ready` | `PlayerData.player_data["关卡评价"]`、`MainSet` 一次性解锁标志、BGM/UI | `LevelSettlement._commit_settlement("level_victory")` | 每实例一次；待提交状态可重试 | 失败提示；待提交保留，返回/重战时重试 |
| `victory.gd:_on_return_map_pressed` | 清零无双 | 不重复保存；仅冲刷待提交 | `_begin_leave()` | 待提交失败则中止离开 |
| `victory.gd:_on_rechallenge_pressed` | 重置 HP/MP/无双 | 不重复保存；仅冲刷待提交 | `_begin_rechallenge()` | 待提交失败则中止重战 |
| `defeat.gd:_on_return_map_pressed` | 清零无双/死亡链 | 不保存 | `_begin_leave()` | 双击不重复切换 |
| `defeat.gd:_on_js_pressed` | `add_zb("xczg")` | `_request_settlement_save("level_defeat_reward")` | `_equipment_reward_claimed` + 已获取检查 | 失败回滚装备与获取记录 |
| `defeat.gd:_on_yjjj_pressed` | `zyforever = true` | `_request_settlement_save("level_defeat_reward")` | `_forever_refusal_committed` | 失败回滚标志 |
| `defeat.gd:_on_lqjl_pressed` | 7 种道具入包 | `_request_settlement_save("level_defeat_reward")` | 持久 `失败奖励已领取` + 整批校验 | 容量不足或保存失败整批回滚 |
| `defeat.gd:_on_jj_pressed` | 无 | 无 | 无 | 纯文本分支 |

### 7.2 关卡域保存点（10 处）

| # | 文件 | reason | 触发 | 守卫/顺序 |
|:---|:---|:---|:---|:---|
| 1 | `victory.gd:_ready` | `level_victory` | 胜利 `_ready` | `_commit_settlement` 判读并保留待提交 |
| 2 | `defeat.gd:_on_js_pressed` | `level_defeat_reward` | 接受黑暗力量 | 领取守卫 + 失败回滚 |
| 3 | `defeat.gd:_on_yjjj_pressed` | `level_defeat_reward` | 永久拒绝 | 提交守卫 + 失败回滚 |
| 4 | `defeat.gd:_on_lqjl_pressed` | `level_defeat_reward` | 领取 7 种道具 | 持久标志 + 整批发放 + 失败回滚 |
| 5 | `level_zhen_yao_tower.gd` | `tower_floor_advance` | 进入下一层 | 先保存，失败恢复层数/积分并停留 |
| 6 | `level_17.gd` | `level_17_gate` | 消耗 `bsz` 过门 | 保存失败返还 `bsz` |
| 7 | `level_bxgh.gd` | `level_bxgh_boss` | Boss 死亡 | `_boss_death_handled`；失败提示 |
| 8 | `level_esbxx.gd` | `level_esbxx_tier` | 星宿层进度变化 | `progress_changed`；失败提示 |
| 9 | `level_llbt.gd` | `level_auto_battle` | 自动战斗重开 | 调用方判读，失败停留 |
| 10 | `hdzm.gd` | `level_hdzm_challenge` | 挑战入口 | 先保存后切场景，失败回滚标志 |

全仓 `request_save` 当前 **111 处 / 59 文件**；胜败返回的 4 次冗余保存已移除。

### 7.3 直接数据写入（Phase 17 范围）

`PlayerData.player_data` 的静态赋值口径：

| 口径 | 行数 | 文件数 | 说明 |
|:---|:---|:---|:---|
| 下标赋值 `player_data[...] =` | 145 | 42 | Phase 16 归档记录为 141 行 / 44 文件（含 `+=` 与 `erase`）；口径不同，不直接做差 |
| 含属性赋值 `player_data.attr =` | 197 | 44 | 属性赋值多见于关卡进度键 |

| 文件 | 下标写入行 | 迁移归属 |
|:---|:---|:---|
| `base_through_level.gd` | 29 | 17-3：关卡进度；`add_tg` 一族 |
| `game_announcement.gd` | 14 | 不在 17 试点；公告/版本标志 |
| `base_monster.gd` | 13 | 17-2/17-3：怪物与掉落 |
| `c_hange_clothes_jm.gd` | 8 | 面板域；Phase 16 已审操作者 |
| `zhen_yao_tower.gd` | 8 | 17-3：镇妖塔进度 |
| `local_coop.gd` | 6 | Phase 16 边界，不重开 |
| `zhu_xian_sword_page.gd` | 5 | 面板域 |
| `level_zhen_yao_tower.gd` | 5 | 17-3：镇妖塔关卡进度 |
| `base_hero.gd` | 4 | 17-2/17-3 |
| `back_pack.gd` | 4 | 面板域 |

按目录分布：`main_menu` 51、`base` 46、`level` 12、`back_pack` 8、`other_menu` 8、`coop` 6、`Scene` 5、`skill` 4、`ldl` 1。17-3 只迁移 `base_through_level`/`level` 的进度写入；17-4 只迁移成长域已识别脚本；不以「把 145 行改成统一 API」为目标。

### 7.4 半提交/重复保存候选

| ID | 事实 | 风险 | 17-3 验证 |
|:---|:---|:---|:---|
| GM-21 | `victory._ready` 保存失败无提示 | 保存失败时本轮进度只在内存 | **已修**：`LevelSettlement` 提示并保留待提交，返回/重战重试 |
| GM-22 | `defeat` 奖励先发物品再保存，无回滚 | 保存失败时物品只在内存 | **已修**：保存失败回滚装备/道具/标志 |
| GM-23 | `defeat._on_lqjl_pressed` 不保存 | 重载后重复领取 | **已修**：持久 `失败奖励已领取` + 关闭前保存 |
| GM-24 | `victory`/`defeat` 返回按钮无重入守卫 | 双击触发两次 `change_scene` 与两次保存 | **已修**：`_begin_leave()`/`_begin_rechallenge()`；探针连续点击 |
| GM-25 | 两个死亡分支各自等待后切换 | 双人同时死亡可能重复切换 | 未改；`coop_probe_runner` 全灭用例仍为回归门禁 |
| GM-26 | `base_through_level.gd` 直接写 29 行关卡进度（含 `add_tg`） | 通关进度写入仍集中在该文件；保存由胜利或关卡分支提交 | 阶段推进已收敛；`add_tg` 写入未改，保存失败路径已收口 |

---

## 8. 成长提交

### 8.1 `PlayerData` 原语语义

| 原语 | 返回 | 不足/失败行为 | 调用方是否普遍判读 |
|:---|:---|:---|:---|
| `spend_soul(value)` | `bool` | 不足返回 `false`，不扣 | 否；多数先 `get_soul()` 预检 |
| `add_soul(value)` | `int` | 上限钳制 | 不适用 |
| `add_zb(name, level, data)` | `bool` | 装备页满返回 `false` | 打造/锻造判读；商店循环忽略 |
| `add_fb(name, level, wx, data)` | `bool` | 装备页满返回 `false` | 同上 |
| `add_dj(name, number)` | `bool` | 道具页满返回 `false`，不写入 | 17-4 起可判读 |
| `add_xhp(name, number)` | `bool` | 消耗品页满返回 `false`，不写入 | 17-4 起可判读 |
| `remove_dj(name, page, num)` | `Dictionary` | 页/数量不足时返回 0 数量 | 多数忽略 |
| `remove_xhp(name, page, num)` | `Dictionary` | 只处理指定页首个堆叠；不足时按可用数量截断 | 多数忽略 |

### 8.2 各域提交流程

| 域 | 入口 | 校验 | 扣除 | 产出 | 保存 | 回滚 |
|:---|:---|:---|:---|:---|:---|:---|
| 普通商店 | `shop_item.gd` `add_item_toplayer` → `ShopPurchaseCommand.execute` | 商品、灵魂、装备/宠物空位、道具/消耗品堆叠或空位 | `spend_soul` | 判读 `add_zb`/`add_fb`/`add_dj`/`add_xhp`/宠物装备 | 1 次 `shop_purchase` | **有**：1P/2P 快照，失败全量恢复 |
| 神秘商店 | `mystery_shop_item_box.gd:_on_purchase_pressed` → `execute_mystery` | 购买次数、灵魂、容量 | `spend_soul` + 次数减 1 | 按类型判读产出 | 1 次 `shop_mystery_purchase` | **有**：次数/物品/灵魂全量恢复 |
| 锻造（当前） | `forge.gd:558` `_on_froge_pressed` | 制作书、灵魂、材料、宝珠数据、装备类型 | `remove_all()` + `spend_soul` | 先 `add_zb`/`add_fb` 并判读 bool | 1 次，失败恢复 | **有**：`player_data` 快照 + `_restore_forge_state` |
| 锻造（遗留） | `forge.gd:497` `_on_froge_pressed_legacy` | 同上 | 先产出、后 `remove_all` + `spend_soul` | 忽略 bool | 无 | 无；**无调用方** |
| 神铸 | `divine_forge.gd:95` | 品质、阶段、石头数量 | `_consume_item_all_pages` 先扣 | 修改装备 `神铸阶段` | 1 次 | 无 |
| 淬骨 | `bone_forge.gd:108` | 神骨、阶段、神火数量 | 先扣 3 个神火 | 随机成功/失败；成功改属性 | 1 次 | 无（失败材料照扣，符合设计） |
| 强化 | `strength.gd:_on_qh_pressed` | 装备、上限、双材料、灵魂 | `spend_soul` + `remove_dj` ×2 | 等级 +1、属性刷新 | 仅成功 1 次 `ldl_strength` | **有**：保存失败恢复装备/灵魂/材料 |
| 合成 | `synthesis.gd:121` | 配方、灵魂 | `spend_soul` | `add_zb`/`add_dj`/`add_fb`（忽略失败） | 1 次 | 无 |
| 主动技能 | `zd_skill.gd:up_level` | 技能、等级、书/灵魂 | `_consume_skill_book` 或 `spend_soul` | 技能等级 +1 | 仅成功 1 次 `skill_refresh` | **有**：保存失败恢复书/灵魂/等级；失败路径不保存 |
| 被动技能 | `bd_skill.gd:up_level` / `_upgrade_all_passives` | 等级上限、灵魂 | `spend_soul` | 被动等级 +1 | 单次/一键各 1 次，仅成功 | **有**：保存失败恢复等级/灵魂 |
| 奖励发放 | `reward_interface.gd:12` `_process` | **无容量校验** | 可选使用物品 | 逐项 `add_*` | 1 次（首帧后） | 无 |
| 任务领取 | `basic_task.gd:458` `_on_lqjl_pressed` | 完成状态/已领取/日常 | 无 | `add_reward_info` 延迟发放 | 1 次，**先于发放** | 无 |

### 8.3 失败模式

| ID | 事实 | 风险 |
|:---|:---|:---|
| GM-27 | 商店对道具/消耗品不校验页容量；`add_dj`/`add_xhp` 静默失败 | **已修**：`ShopPurchaseCommand` 校验堆叠/空位，`add_dj/add_xhp` 返回 bool |
| GM-28 | 神秘商店扣费/次数后产出失败无回滚 | **已修**：`execute_mystery` 快照覆盖次数/物品/灵魂 |
| GM-29 | 强化在失败分支也 `request_save` | **已修**：仅成功保存 |
| GM-30 | 神铸/淬骨先扣材料后改装备；保存失败不回滚 | 未改；17-4 只覆盖强化/商店/技能 |
| GM-31 | 合成扣灵魂、清空放入列表后产出失败无回滚 | 未改；17-4 试点范围外 |
| GM-32 | 技能书/灵魂先扣再升级；`refresh_infor` 无视失败保存 | **已修**：主动/被动技能仅成功保存，失败恢复快照 |
| GM-33 | 奖励界面由表现场景直接发物品并保存 | 容量满时部分/全部丢失；无提示 |
| GM-34 | 任务领取先置已领取标志，再延迟发奖，并立即保存 | 保存调用先于奖励场景 `_process` 发奖；二次保存失败则奖励丢失 |
| GM-35 | `defeat._on_lqjl_pressed` 无保存 | 重进重复领取 |
| GM-36 | `forge._on_froge_pressed_legacy` 无调用方 | 死代码；迁移时删除或明确保留理由 |

---

## 9. HUD/输入/音频

### 9.1 HUD/面板

| 入口 | 读写 | 归属 | 事实 |
|:---|:---|:---|:---|
| `role_information.gd:37` | 注入 `player`/`player_p2` | 显式槽位 | P1/P2 HUD 各自注入；meta `coop_slot` 1/2 |
| `base_role.gd` `RoleProp` getter | 读注入 `player` / `LocalCoop.props_for` | 显式槽位 | P1/P2 HUD 按槽位读取；未注入时回落 `RoleProp.source_player` |
| `base_role.gd:_set_values` | 读槽位 `RoleProp` | 显式槽位 | HP/MP/经验/无双按注入 `player` 的槽位属性；不在绘制回调写档案 |
| `transmogtified_box.gd:_on_change_pressed` | 调 `PlayerData.change_transmog` | 面板命令 | 命令校验/快照/保存；失败恢复，不在回调直接写档案 |
| `reward_interface.gd:_process` | 调 `RewardGrantCommand.execute` | 面板命令 | 命令校验/快照/发放/保存；失败全量恢复（GM-33 已修） |
| `skill_icon.gd:5` | 经 `LocalCoop.data_for/props_for` 解析槽位；缺失时读 `/root/PlayerData`/`/root/RoleProp` | 面板查询 | 正常路径按槽位；回落为 1P Autoload |

### 9.2 输入

| 项 | 事实 |
|:---|:---|
| 基础动作 | `project.godot` `[input]` 共 24 个动作（含调试动作） |
| 2P 映射 | `CoopInput.action_name` 在 2P 时加 `p2_` 前缀（`coop_input.gd:9`）；`LocalCoop` 生成对应 action |
| 读取面 | `Input.is_action*` 63 行 / 20 文件；热点 `base_hero` 16、`role1` 9、`backpack` 6、`ne_zha_hero` 4 |
| 领域读取 | `base_through_level` 读 `Exit`/`p2_Exit` 决定离开关卡；`base_hero` 读技能/移动动作 |
| 边界 | 输入读取只作为条件；保存由出口/结算/进度函数显式调用（§7.2），未在输入读取行内写档 |

### 9.3 音频

| 项 | 事实 |
|:---|:---|
| 受击音效 | `Global.add_sound` 138 次 / 34 文件；池上限 32；45ms 节流；同音效 4/8、总声部 24/48 |
| BGM | `Global.add_bgm` 121 处；同一曲复用活动实例，切曲先 `stop()` 再释放；`stop_bgm()` 显式收口 |
| 热点 | `role_4` 20、`role_5` 19、`role1` 18、`role_3` 16、`role_2` 10 |
| 音量/开关 | `MainSet.set_data["MusicFB_2"]`、`RoleOrMonsterHit`；由 `game_set.gd` 写入 |
| 边界 | 音效是纯表现；`add_sound` 先查缓存再预留声部；池回收 `prepare_for_pool()` 停止并清流 |

### 9.4 表现层提交领域状态点

| ID | 位置 | 事实 |
|:---|:---|:---|
| GM-37 | `reward_interface.gd:_process` | **17-5 已改为 `RewardGrantCommand`**；失败回滚 |
| GM-38 | `choose_item.gd` | 选择界面创建奖励场景后自身 `queue_free`；奖励提交已归命令 |
| GM-39 | `transmogtified_box.gd` | **17-5 已改为 `PlayerData.change_transmog`**；失败回滚 |
| GM-40 | `victory.gd:24` | 结算 UI 在 `_ready` 写评价/解锁标志 |
| GM-41 | `defeat.gd` 奖励分支 | **17-3 已迁入 `LevelSettlement` 命令边界**；失败回滚 |

上述点中，GM-39/GM-40 属于「面板命令」而非纯展示；17-5 的目标是区分只读展示与显式命令，不是禁止面板提交。

---

## 10. 模块 API 与场景依赖

### 10.1 公开面

| 模块 | 公开方法数 | 关键公开方法 | 调用方 |
|:---|:---|:---|:---|
| `BaseLevel`（`base_through_level.gd`） | 14 | `get_active_monsters`、`check_can_create/pass/exit`、`level_create_monster`、`change_mysee`、`add_tg`、`set_through` | 86 个关卡脚本 `extends BaseLevel`；HUD/怪物/相机 |
| `BaseHero` | 128 | 移动、攻击、技能、法宝、宠物、HUD 查询 | 输入、关卡、怪物、面板 |
| `BaseMonster` | 103 | 受击、AI、掉落、Buff、无双 | 关卡、弹体、召唤、技能 |
| `SummonBaseMonster` | 69 | `set_summon_properties`、目标搜索、伤害、跟随 | 法宝、英雄技能、宠物 |
| `BaseMagicWeapon` | 7 | `set_magic_weapon_player`、`get_attack_snapshot`、`use_skill` | 英雄、法宝子类 |
| `LocalCoop` | 35 | `slot_for`、`data_for`、`props_for`、`all_players_dead`、`open_panel` | 全局、面板、战斗 |
| `PlayerData` | 124 | 背包/灵魂/技能/任务/存档原语 | 全仓 |
| `Global` | 265 | 场景、资源、池、音效、实体工厂 | 全仓 |

- 基础类均无自定义 `signal`；模块间以直接方法调用为主，确认对话框使用 `Signals.choose_pressed`（11 处）。
- `BaseLevel.set_through()` 是空钩子（`base_through_level.gd:1517`），子类用于相机/出口扩展。
- `BaseMagicWeapon` 有 24 个子类；`RoleBullet` 4 个、`MonsterBullet` 17 个、`SummonBaseMonster` 5 个。

### 10.2 依赖方向与深层路径

| 项 | 事实 |
|:---|:---|
| 节点访问 | `get_node` 168 + `get_node_or_null` 531 = **699 处 / 144 文件** |
| 字面深层路径 | 17-1 基线 **279 处 / 66 文件**；17-6 四试点 159→30（`pet_interface` 117→22、`zd_skill` 26→0、`base_role` 12→8、`base_magic_weapon` 4→0）；未全仓复算 |
| `/root` 单例 | 17-1 基线 **34 处 / 13 文件**；17-6 删除 `base_role`/`base_magic_weapon` 的 `/root` 访问，改用 `LocalCoop` 槽位查询 |
| 场景规模 | 153 个关卡 `.tscn`、163 个关卡 `.gd`；86 个脚本直接 `extends BaseLevel` |
| 场景依赖 | 关卡场景固定 `Hero`/`Monster`/`CanvasLayer` 等节点；`BaseLevel` 用 `@onready` 直接取 |
| 通信 | 父调用子公开方法；子节点回写父级字段（如 `next_boss.current_stage`），无信号解耦 |

### 10.3 试点边界

| 批次 | 试点文件 | 理由 | 不迁移 |
|:---|:---|:---|:---|
| 17-2 | `role_bullet.gd`、`monster_bullet.gd`、`summon_base_monster.gd`、`base_magic_weapon.gd`、`base_monster._get_damage_source_player`/`apply_role_hit` | 归属字段集中，已有 `coop_damage_slot` 快照 | 不重写弹体/召唤继承 |
| 17-3 | `base_through_level.gd`、`victory.gd`、`defeat.gd`、`level_zhen_yao_tower.gd` | 阶段/结算所有者清晰，失败边界可枚举 | 不改关卡时序/数值 |
| 17-4 | `shop_item.gd`、`mystery_shop_item_box.gd`、`forge.gd`、`divine_forge.gd`、`bone_forge.gd`、`strength.gd`、`synthesis.gd`、`zd_skill.gd`、`bd_skill.gd`、`reward_interface.gd`、`basic_task.gd` | 已有 `forge` 参考事务；失败模式集中 | 不引入通用事务框架 |
| 17-5 | `base_role.gd`、`role_information.gd`、`reward_interface.gd`、`transmogtified_box.gd`、`Global.add_bgm`/`add_sound` | 表现层与命令边界可区分 | 不改输入映射/HUD 布局 |
| 17-6 | `pet_interface.gd`、`zd_skill.gd`、`base_role.gd`、`base_magic_weapon.gd` | 四文件 159 条深层字面路径，路径/依赖集中 | 不全仓替换 `get_node` |

---

## 11. 17-1 出口与 17-2 入口

### 11.1 出口检查

- [x] 攻击/弹体/召唤/法宝的创建入口、来源字段与回退路径已登记（§4）；
- [x] 对象池取出/归还/清理与残留状态已登记（§5）；
- [x] 关卡阶段推进、`current_stage` 写入点与完成判定已登记（§6）；
- [x] 胜败判定、重战、结算保存与重复保存/半提交候选已登记（§7）；
- [x] 成长系统校验/扣除/产出/保存/回滚已按域登记（§8）；
- [x] HUD/输入/音频的展示与提交已区分（§9）；
- [x] 试点模块公开方法、场景依赖与深层路径热点已登记（§10）；
- [x] 仅文档与静态调查，未修改生产代码、素材或 UID。

### 11.2 17-2 首先验证的断言

1. 弹体在英雄节点下与在场景根下两种创建方式，`player` 归属一致；
2. `apply_role_hit` 结束后 `get_player`/`coop_damage_slot`/`source_props.source_player` 全部恢复；
3. 2P 攻击时吸血/腾蛇阵/角色 5 被动使用 2P 数据，而不是 `RoleProp`/`PlayerData` 的 1P 值；
4. 召唤物在 `summoner` 为英雄/法宝/怪物三种来源时，`player_reference` 与 `slot_for` 一致；
5. 池化节点连续复用两轮后不携带上一轮目标/类型/暴击标记。

**下一入口**：17-2 命中与效果归属；本页作为调用面基线，17-2 实施后回填差异。

---

## 12. 17-2A 实施差异（2026-10-29）

### 12.1 已修改

| 位置 | 变更 | 结果 |
|:---|:---|:---|
| `base_monster.gd:_get_damage_source_player` | 删除 `RoleProp.source_player` 回落 | 无来源命中返回 `null`，`apply_role_hit` 返回 0；不再借用 1P |
| `base_monster.gd:_get_vampirism_rate` | 新增；读 `LocalCoop.props_for(source_player).roleprop.vampirism` | 吸血倍率按出手者 |
| `base_monster.gd:_get_tszz_level` | 新增；读 `LocalCoop.data_for(source_player).player_data["腾蛇阵"]["Level"]` | 腾蛇阵增伤按出手者 |
| `base_monster.gd:_get_role5_skill_level` | 新增；读 `LocalCoop.data_for(get_player)` 的技能 10 等级 | 角色 5 被动按出手者 |
| `global.gd:_assign_attack_source` | 新增；显式来源优先，否则 `LocalCoop.owner_hero(parent)`；写 `player` 与 meta `coop_slot` | 角色侧攻击载体统一来源 |
| `global.gd:add_role_bullet` | 增加可选 `source_player`；调用 `_assign_attack_source` | 根节点弹体由调用方传源 |
| `global.gd:add_role_bullet_1`/`_safe`/`add_role1_shallow` | 增加可选 `source_player` 并赋值 | 技能弹体/浅影来源显式 |
| `summon_base_monster.gd:set_summon_properties` | 英雄召唤时写 meta `coop_slot` | 召唤物槽位显式 |
| `role_bullet.gd` | 根节点 `Role2Bullet7_tx`/`_1` 传入 `player`；显式来源不被祖先覆盖；删除觉醒效果的 `role_props.source_player` 回落 | 根节点弹体归属稳定 |
| `role_bullet_1.gd` | `player` 仅在缺失时从祖先回填；浅影创建传入 `player` | 技能弹体不覆盖显式来源 |
| `role1_s_hallow.gd` | 新增 `player` 字段 | 浅影可被 `_get_damage_source_player` 解析 |

### 12.2 仍保留的 1P 读取

| 位置 | 事实 | 后续 |
|:---|:---|:---|
| `base_monster.get_role_last_hurt` | **17-2C 已改为按 `get_player`/`_get_damage_source_player` 解析出手者属性**；无来源时才回落 `RoleProp` | 已修复 |
| `base_monster.wd_hurt`/`_is_mds_awaken_active` | 角色 4 毒伤/觉醒读全局 `RoleProp`/`PlayerData`；`wd_hurt` 是每物理帧环境检查，不绑定单次命中 | 17-3/17-5 按 2P 玩法语义处理 |
| `RoleProp.source_player` 由 `BaseHero._ready` 覆盖 | 仍是非归属路径（HUD/怪物提示）的全局别名 | 保留，Phase 17-5/17-6 处理 |
| `SummonBaseMonster.find_player_reference` | **17-2C 已优先 `LocalCoop.owner_hero(summoner)`**；无持有者时仍回落全局别名 | 部分修复 |
| `Global.get_player` | 仍只指向 1P | 17-5/17-6 |

### 12.3 回归

- 新增 `LocalCoopAttributionSourcesProbe`：无源命中不回落；P2 普攻/技能弹体/根节点弹体/法宝记 P2 无双且不动 P1；P2 弹体 `addeffect` 落到目标；命中后 `get_player`/`coop_damage_slot`/`source_props.source_player` 恢复；召唤 `owner_hero`/`slot_for`/meta/`_get_damage_source_player` 均为 P2；P1/P2 交替出手不串；吸血/腾蛇阵/角色 5 读取 P2 档案；`damage_text` 池连续复用两轮重置值/类型/暴击/目标。
- `coop_probe_runner` 全 19 例 PASS；`level_1` 冒烟 PASS（0 ERROR / 0 WARNING）；`level_regression_all --changed-only` 128/128 PASS + 5 SKIP（276.3s）；`check_all --godot-bin` 8/8 PASS。

---

## 13. 17-2B 池化复用清理（2026-10-29）

### 13.1 决策：清理放在归还/预热，不放在取出

| 位置 | 行为 |
|:---|:---|
| `_take_pooled_node` | **不重置**。池内节点已由归还/预热清理；取出后调用方必须用新数据调用 `setup()`/播放入口 |
| `_store_pooled_node` | 归还前调用 `prepare_for_pool()`；池满时直接释放 |
| `_seed_runtime_pool` | 新建预热节点后调用 `prepare_for_pool()` |
| 节点 `recycle()` | 只做重入守卫并委托 `Global.recycle_*`；具体状态清理在 `prepare_for_pool()` |

理由：取出后的节点必须接收新的文本/目标/动画/音量参数，通用 `_take` 重置无法知道该写什么；统一清理放在池边界可保证“池内存放的一定是干净节点”，且只有一份实现。

### 13.2 新增清理钩子

| 池 | 脚本 | `prepare_for_pool()` 清理项 |
|:---|:---|:---|
| `damage_text` | `Script/hittext/damage_text.gd` | 可见性、目标、类型、暴击、动画、数字节点（原有钩子，recycle 改为委托） |
| `mr_hurt` | `Scene/monster_damage/monster_be_hit.gd` | `_recycled`、可见性、动画停止 |
| `role_be_hit` | `Script/base/role_be_hit_effect.gd` | `_recycled`、停止、可见性 |
| `sound_player` | `Script/all_sound/monster_be_hit.gd` | `is_set`、停止、`stream`、`target`、物理处理 |

### 13.3 夹具

`LocalCoopPoolReuseProbe` 逐池断言：

- `mr_hurt`：取出活动、归还后不可见/停止、再次取出同一节点并重新播放；
- `role_be_hit`：取出播放、归还后停止/不可见、再次取出同一节点并重新播放；
- `sound_player`：取出播放、`_on_finished` 清空 target/stream、再次取出同一节点并绑定新 target；
- `damage_text`：由 `LocalCoopAttributionSourcesProbe` 覆盖两轮值/类型/暴击/目标重置。

### 13.4 剩余风险

- `_take_pooled_node` 不校验节点类型与场景路径；四类池各自固定场景，暂未出现交叉入池。
- `mr_hurt`/`sound_player` 的节流键与活动计数在归还后仍保留，但下一次取出会覆盖；不属于节点状态。
- 池复用清理不改变伤害/归属，17-2C 继续处理伤害数值的 1P 读取。

---

## 14. 17-2C 归属回归（2026-10-29）

### 14.1 伤害属性按出手者

`get_role_last_hurt(target, source_player = null)` 的来源解析顺序：

1. 显式 `source_player`；
2. `get_player`（命中期间由 `apply_role_hit`/`bind_role_damage_source` 设置）；
3. `_get_damage_source_player(target)`；
4. 仍为空 → `RoleProp` 兜底。

命中期间的 `miss`/`crit`/`ar`/`sp`/`Level`/`Lucky` 全部读 `LocalCoop.props_for(attack_source)`；`monster149` 与 `xr` 判定也改用同一 `attack_source`。

### 14.2 伤害数值分离断言

`LocalCoopDamageStatsProbe` 固定 `monster.level=1`、`def=100`、无减伤，设置 P1/P2 不同属性：

| 断言 | P1 | P2 | 结果 |
|:---|:---|:---|:---|
| 暴击 | `Crit=0` | `Crit=1000000000` | P1 100、P2 200；P2 `is_crit=true` |
| 护甲穿透 | `ar=0` | `ar=100` | P1 50、P2 100 |
| 等级压制 | `Level=1` | `Level=100` | P1 100、P2 110 |

说明：P2 `Crit` 经 `snapped(crit/(crit+100),0.001)` 达到 1.0，因此暴击断言确定；其余两项无随机分支。

### 14.3 召唤回落与 `wd_hurt`

- `SummonBaseMonster.find_player_reference`：非英雄 `summoner` 先 `LocalCoop.owner_hero(summoner)`，再回落 `RoleProp.source_player`，最后取场景 `Hero` 首个子节点；`LocalCoopAttributionSourcesProbe` 覆盖“法宝持有召唤跟随 P2”。
- `wd_hurt` 未改：它在 `BaseMonster._physics_process` 每帧检查全局 `RoleProp.source_player`/`PlayerData` 技能 10，不绑定单次命中；2P 角色 4 毒伤是持续环境效果，是否按每个 Role4 独立触发属于玩法决策，留 17-3/17-5。
- `_apply_role_damage_vs_reduction` 仍读全局 `RoleProp.damage_bonus`；本次未改，登记为残余 1P 读取。

### 14.4 回归

- `coop_probe_runner` 21/21 PASS；`level_1` 冒烟 PASS（0 ERROR / 0 WARNING）；`level_regression_all --changed-only` 128/128 PASS + 2 SKIP（314.1s，`level_ghg` 瞬态重试通过）；`check_all --godot-bin` 8/8 PASS。

---

## 15. 17-3 阶段与结算（2026-10-29）

### 15.1 阶段推进

`base_through_level.advance_stage(next_stage)` 是 `current_stage` 的唯一写入入口：只接受 `1..4` 且严格大于当前值；基础关卡按 x 阈值调用，`game4_imported_level._start_stage()` 复用同一入口。回退/跳阶请求直接返回 `false`。

### 15.2 结算所有权

`LevelSettlement`（`source/Script/level/level_settlement.gd`）持有：

- `_commit_settlement(reason)`：保存成功清空待提交；失败提示并保留待提交；
- `_flush_pending_settlement()`：返回/重战前重试；
- `_begin_leave()` / `_begin_rechallenge()`：按钮去重；
- `_request_settlement_save()` 与 `_request_scene_change()`：生产走 `MemoryClass`/`Global`，探针可注入。

`victory` 与 `defeat` 的返回不再各自保存；胜利 `_ready` 是唯一通关保存，失败奖励保存仅在三个奖励入口。

### 15.3 失败奖励

`PlayerData.add_dj_batch()` 先快照道具页，逐项发放后核对数量；任一失败恢复快照。`defeat._on_lqjl_pressed` 在保存失败时恢复道具页并把 `失败奖励已领取` 复位；`_ready` 读取该标志，重进后 `lq` 为真，不再发放。

### 15.4 验证

`archive_probe_runner` 118 项全部 PASS，覆盖：胜利保存一次、胜利返回/重战场景一次、保存失败后返回重试、失败领取一次、领取持久标志、返回一次、道具/装备保存失败回滚。`coop_probe_runner` 21/21 PASS；`level_1` 冒烟 PASS；`level_regression_all --changed-only` 128/128 PASS + 5 SKIP（282.7s）；`check_all --godot-bin` 8/8 PASS。

---

## 16. 17-4 成长命令（2026-10-29）

### 16.1 普通与神秘商店

- `ShopPurchaseCommand.execute(item_name, buy_num, unit_price)`：校验商品/容量/灵魂 → `PlayerData.snapshot_state()` → `spend_soul` → 逐项判读产出 → `request_save("shop_purchase")`；任一步失败 `restore_state()`。
- `execute_mystery(item_name, quantity, unit_price, level, wx)`：额外校验并扣减 `购买次数`，保存 reason 为 `shop_mystery_purchase`；快照同时覆盖次数。
- `PlayerData.add_dj/add_xhp` 改为返回 `bool`；`add_dj_batch` 继续整批回滚。
- `PlayerData.snapshot_state/restore_state` 同时保存 1P/2P `player_data`，恢复后 `LocalCoop.link_bags()` 并重设共享灵魂。

### 16.2 强化与技能

| 域 | 成功保存 | 失败回滚 | 失败路径 |
|:---|:---|:---|:---|
| 强化 | `ldl_strength` | 装备等级/灵魂/强化石快照 | 材料/灵魂不足直接返回，不保存 |
| 主动技能 | `skill_refresh` | 技能书/灵魂/等级快照 | 校验失败不保存；保存失败恢复并刷新 UI |
| 被动技能单个 | `skill_passive_upgrade` | 等级/灵魂快照 | 上限/灵魂不足不保存 |
| 被动技能一键 | `skill_passive_upgrade_all` | 全部等级/灵魂快照 | 保存失败返回 -1 并提示 |

### 16.3 验证

`archive_probe_runner` 137 项 PASS，覆盖：普通商店成功/余额不足/背包满/保存失败回滚、神秘商店成功/次数不足/保存失败回滚、强化成功/材料不足/保存失败回滚、主动技能成功/保存失败回滚、被动技能成功/保存失败回滚。`coop_probe_runner` 21/21 PASS；`level_1` 冒烟 PASS；`level_regression_all --changed-only` 128/128 PASS + 5 SKIP（344.9s）；`check_all --godot-bin` 8/8 PASS。

---

## 17. 17-5 HUD/输入/音频（2026-10-29）

### 17.1 表现层命令

- `transmogtified_box._on_change_pressed` 只负责按钮语义与提示；写入/保存由 `PlayerData.change_transmog(slot, item)` 完成。命令校验槽位与已解锁状态，失败恢复快照。
- `reward_interface._process` 只调用 `RewardGrantCommand.execute(reward_items, use_item, use_num)`；命令校验奖励与使用物、快照、发放、扣除使用物、保存，失败全量恢复。
- `BaseRole` 的 `RoleProp`/`PlayerData` getter 按注入 `player` 解析 `LocalCoop.props_for/data_for`；P1/P2 HUD 读取各自槽位，不写档案。

### 17.2 音频

- `Global.add_bgm` 维护 `_active_bgm_instance`：同曲同父复用；同曲异父重挂；切曲先停止旧实例再创建。`stop_bgm()` 提供显式收口。
- `Global.add_sound` 将缓存检查移到声部预留之前；无音频时不再驱逐已有声部。
- `monster_be_hit.prepare_for_pool()` 保持 `stop()` + `stream = null`，池回收不残留旧流。

### 17.3 验证

`archive_probe_runner` 145 项 PASS，新增：幻化命令成功/重载/保存失败回滚、奖励界面保存与单次发放、BGM 同曲复用/切曲停旧/停止清空、音效池播放与回收清流。`coop_probe_runner` 21/21 PASS；`level_1` 冒烟 PASS；`level_regression_all --changed-only` 128/128 PASS + 5 SKIP（282.9s）；`check_all --godot-bin` 8/8 PASS。

---

## 18. 17-6 模块 API 与场景依赖（2026-10-29）

### 18.1 公开 API

四个试点的公开方法、注入字段、场景节点与外部依赖见 [`module_api_matrix.md`](module_api_matrix.md)。摘要：

| 模块 | 稳定公开面 | 内部回调 |
|:---|:---|:---|
| `BaseRole` | `player`、`pet_panel`、`is_full_ws()`、`reveal_after_scene_loaded()` | `_set_values`/`_set_pet_values` 等渲染 |
| `BaseMagicWeapon` | `player`、`set_magic_weapon_player`、`get_attack_snapshot`、`use_skill`、`enough_mp`、`show_skill`、`fix_hero`、`use_over` | `_physics_process`、`_on_skill_cd_timeout` |
| `zd_skill` | `up_level`、`refresh_infor`、`init_skill_variants`、`update_skill_name_and_icon`、`setup_variant_menu` 与查询方法 | `_on_skill_*`/`_on_ski_*` 场景连接 |
| `pet_interface` | `*_click`/`eat_immor`/`push_pet_*` 等面板命令 | `_on_*`/`_feed_*`/`_refresh_*` |

### 18.2 依赖方向

- 父场景负责实例化与注入 `player`/`pet_panel`；模块不反向控制父级业务字段。
- 模块通过 `LocalCoop.data_for/props_for` 解析槽位；跨模块写经 `PlayerData` 命令。
- 禁止新增 `/root/<Autoload>`、HUD 绘制回调写档、跨模块私有字段/节点访问。

### 18.3 路径清理

| 文件 | 前 | 后 | 方式 |
|:---|:---:|:---:|:---|
| `pet_interface.gd` | 117 | 22 | `_pet_ui_node(root, child)` |
| `zd_skill.gd` | 26 | 0 | `SKILL_UI_ROOT` + 列/孙节点访问器 |
| `base_role.gd` | 12 | 8 | 删除 `/root`，改用 `LocalCoop` |
| `base_magic_weapon.gd` | 4 | 0 | 同上 |

剩余 30 条均为模块自身场景子节点，未改场景名或 `%UniqueName`。**未做全仓替换。**

### 18.4 验证

`archive_probe_runner` 146 项 PASS；`coop_probe_runner` 21/21 PASS；`level_1` 冒烟 PASS；`level_regression_all --changed-only` 128/128 PASS + 5 SKIP（265.7s）；`check_all --godot-bin` 8/8 PASS。

---

## 19. 17-7 边界守卫（2026-10-29）

### 19.1 固化规则

`scripts/contract_scan.py` 新增 `phase17_boundary` ERROR 规则：

1. `victory.gd`/`defeat.gd` 必须 `extends LevelSettlement`，且不得直接调用 `MemoryClass.request_save`；
2. `ShopPurchaseCommand`/`RewardGrantCommand` 必须包含 `snapshot_state()` 与 `restore_state(`；
3. 幻化/奖励表现层禁止 `PlayerData.player_data[...] =`、`PlayerData.player_data.attr =` 与直接 `request_save`；
4. `base_role`/`base_magic_weapon`/`pet_interface`/`zd_skill` 禁止 `"/root/"`；
5. 四试点深层字面路径预算：`pet_interface` 22、`zd_skill` 0、`base_role` 8、`base_magic_weapon` 0。

`contract_gate.py` 增加 `contract_scan --self-test`；自测覆盖正当样本、重复保存、缺快照、表现层写档、绝对路径与路径超预算负样本。`slot_boundary` 的 BaseRole `/root` 回落样本已转为负样本，策略与 17-6 一致。

### 19.2 验证

`contract_scan --fail-on-error` ERROR=0；`contract_scan --self-test` PASS；`archive_probe_runner` 146 项 PASS；`coop_probe_runner` 21/21 PASS；`level_1` 冒烟 PASS；`level_regression_all --changed-only` 128/128 PASS + 5 SKIP（265.7s）；`check_all --godot-bin` 8/8 PASS。

Phase 17 已归档到 [`iteration_17_gameplay_module_boundaries.md`](../archive/iteration_17_gameplay_module_boundaries.md)；剩余缺口进入 [`current-iteration.md`](../roadmap/current-iteration.md) 的 Phase 18-1~18-5。
