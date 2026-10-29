# BHYH 当前候选迭代

> **状态**：**Phase 17：玩法与表现模块边界；17-1 调用面矩阵已完成（2026-10-29，交付 [`gameplay_module_matrix.md`](../reference/gameplay_module_matrix.md)），17-2A 来源显式化、17-2B 池化复用清理、17-2C 归属回归与 17-3 关卡阶段与结算已完成（2026-10-29），17-4 成长系统命令边界、17-5 HUD/输入/音频表现、17-6 模块 API 与场景依赖、17-7 边界守卫未启动**。本页记录候选边界、阶段顺序与验收条件，不把未实施目标写成现状。
> **版本**：6.9；不新增玩法、任务与掉落，不改变数值、动画时序、输入映射、存档格式、本地双人共享规则或显示基线。
> **职责**：本页展开当前候选 Phase 17；Phase 16 已完成并归档，独立平台与内容回植项目统一见 [`roadmap.md`](roadmap.md)。
> **依据**：[`总体目标契约`](../standards/target_architecture_contract.md) §3、§5、§7、§10~§11；[`godot_design_standard.md`](../standards/godot_design_standard.md) §3.2~§3.4、§8；[`ADR-005`](../decisions/ADR-005-no-compatibility-or-fallback-layers.md)、[`ADR-006`](../decisions/ADR-006-resource-first-data-and-data-keys.md)、[`ADR-007`](../decisions/ADR-007-autoload-boundary.md)、[`ADR-017`](../decisions/ADR-017-local-coop-profile-isolation.md)、[`ADR-021`](../decisions/ADR-021-project-wide-target-architecture.md)；[`architecture.md`](../reference/architecture.md)、[`acceptance.md`](../reference/acceptance.md)、[`status.md`](../reference/status.md)、[`archive_session_matrix.md`](../reference/archive_session_matrix.md)。
> **历史**：[Phase 16 已归档](../archive/iteration_16_archive_session_slots.md)；[Phase 15](../archive/iteration_15_app_orchestration_lifecycle.md)、[Phase 14](../archive/iteration_14_atlas_metadata_boundary.md)、[Phase 13](../archive/iteration_13_visual_asset_contract.md) 与更早归档见 [`archive/README.md`](../archive/README.md)。

## 1. 阶段边界与决策

### 1.1 目标

收敛玩法与表现模块边界：让攻击/弹体/召唤/法宝的来源与归属、关卡阶段与结算、成长系统提交、HUD/输入/音频以及模块公开依赖各自有明确的所有者、正式入口和失败边界；保留现有玩法、数值、动画时序与显示基线。

- 根据热点与实际耦合选择试点，不为缩短基类而大拆继承；
- 攻击/弹体/召唤/法宝显式携带来源，池化复用清除旧状态；伤害、Buff、吸血与无双归属不漂移；
- 关卡阶段与胜败/重战提交保持唯一所有者；通关与保存不重复执行；
- HUD/面板使用只读查询与明确命令，输入与音频表现不拥有领域规则；
- 成长系统按实际域抽取命令：购买/锻造/学习/奖励先校验，再提交扣除与产出；保留共同账本与个体分配，验证失败无部分扣费、无重复领取，不引入通用事务框架；
- 模块公开 API、场景依赖与必要的功能子目录一起治理；深层路径只在受影响边界清理，不全仓替换；
- 不新增 Autoload；Autoload 增删/合并必须先评审；一个职责边界迁移时同步迁移全部生产调用方，删除旧入口，不保留永久 facade。

### 1.2 不在本阶段

- 不重写 `base_hero`/`base_monster`/`base_through_level` 的继承结构，不做“基类瘦身”作为目标；只在试点的调用面内拆分；
- 不改变伤害公式、Buff 数值、掉落规则、关卡时序、输入映射、物理层与动画帧率；
- 不引入通用事务框架、事件总线或第二套全局单例；成功/失败语义由各域命令显式返回；
- 不把整个 `PlayerData.player_data` 改成 Resource，不重做存档格式；档案会话与槽位边界沿用 Phase 16 结论；
- 不全仓替换 `get_node()`/绝对路径，不重排顶层目录；深层路径只清受试点影响的边界；
- 不新增玩法模块、任务、掉落或平台承诺；平台与发布验证按独立工作流推进。

### 1.3 当前事实与调查结果

| 边界 | 当前事实（2026-10-29 统计） | 本阶段取证要求 |
|:---|:---|:---|
| 命中/归属 | `coop_damage_slot` 11 处（`base_monster`/`local_coop`）；`Global.get_player` 15 次 / 9 文件；`source_player` 360 次 / 61 文件 | 17-1 枚举攻击者、弹体、召唤、法宝的来源字段与回退路径，标出仍假定 1P 的入口 |
| 攻击/弹体/召唤/法宝 | 153 个关卡场景、163 个关卡脚本；`role_bullet*.gd` 2 个；`Script/monster` 中 155 个文件涉及 bullet；`SummonBaseMonster` 子类 12 个；`BaseMagicWeapon` 相关 26 个 | 17-2 明确来源载体、池化复用清理与归属快照；补归属回归夹具 |
| 池化 | `Global._pool_data` 四类（`damage_text`/`mr_hurt`/`role_be_hit`/`sound_player`），上限 80/32/24/32 | 17-2 验证复用节点不携带上一次的来源与战斗状态 |
| 关卡阶段 | `current_stage` 535 行 / 97 文件；`base_through_level.gd` 1951 行；`victory.gd` 251 行、`defeat.gd` 178 行 | 17-3 枚举阶段推进、胜败判定、重战与结算保存的全部写入者 |
| 结算保存 | 关卡域 `request_save` 10 处；`victory` 1、`defeat` 3（经 `LevelSettlement`） | 17-3 验证通关/失败/重战每次只保存一次，失败不半提交 |
| 数据写入 | `PlayerData.player_data` 下标赋值 **145 行 / 42 文件**（含属性赋值 197 行 / 44 文件）；热点 `base_through_level` 29、`game_announcement` 14、`base_monster` 13；分布见 [`gameplay_module_matrix.md`](../reference/gameplay_module_matrix.md) §7.3 | 17-3/17-4 只迁移试点域的写入，不一次性全量改写 |
| 成长系统 | `Script/ldl` 16 个脚本、`Script/shop` 6 个、`Script/skill` 9 个；奖励结算涉及 `reward_interface` 等 2 个入口 | 17-4 枚举校验、扣除、产出的顺序与失败分支，找部分扣费/重复领取点 |
| HUD/输入/音频 | `base_role.gd` 1254 行；`Input.is_action` 63 行 / 20 文件；`Global.add_sound` 138 次 / 34 文件；`Global.add_bgm` 125 次 / 94 文件 | 17-5 区分只读展示、输入映射与表现副作用，禁止表现层提交领域状态 |
| 模块依赖 | `get_node`/`get_node_or_null` 共 699 处（168 + 531），字面深层路径 279 处 / 66 文件，`/root` 34 处 / 13 文件；无统一模块公开 API 清单 | 17-6 产出受影响模块的公开 API 与依赖方向；深层路径只清试点边界 |

Phase 17 的前置调查只确认现状，不把目标语义写成已实现。Phase 16 的档案会话、共享账本、槽位查询与契约门禁是**不变量**，任何变更需回到对应验收。

## 2. Phase 17-1：玩法与表现调用面矩阵（只读调查，已完成）

**目标**：在不改运行时代码的前提下，建立命中归属、关卡阶段/结算、成长提交、HUD/输入/音频与模块依赖的完整调用面，确定每个状态的所有者、写入者、失败边界与试点顺序。

### 2.1 调查内容

1. 枚举攻击、弹体、召唤物与法宝的创建入口、来源字段（`player`/`source_player`/`get_player`/`coop_damage_slot`）与回退路径，标出仍假定 1P 的代码；
2. 枚举对象池的取出/归还入口、复用前清理项与残留状态（`damage_text_active`、来源、目标、暴击/闪避标记）；
3. 枚举关卡阶段的推进函数、`current_stage` 写入点、刷怪表/弹体表解析与阶段跳转条件；
4. 枚举胜败判定、重战入口、通关/失败结算与 `request_save` 调用，标出可能重复保存或半提交的分支；
5. 枚举成长系统（购买/锻造/学习/奖励）的校验、扣除、产出与失败回滚点，按业务域分类；
6. 枚举 HUD/面板的只读查询、输入映射与音频播放副作用，区分“展示”与“提交”；
7. 枚举试点模块的公开方法、信号与场景依赖，区分模块内部实现与对外契约；
8. 区分静态定义、实例状态与表现资源，禁止把只读 Catalog/配置误算为运行时状态。

### 2.2 交付矩阵（已完成）

交付 [`gameplay_module_matrix.md`](../reference/gameplay_module_matrix.md)。结论摘要：

| 状态/能力 | 所有者 | 写入者 | 读取者 | 失效/清理事件 | 当前失败语义 |
|:---|:---|:---|:---|:---|:---|
| 攻击者/归属 | `BaseMonster.apply_role_hit` + 载体字段 | 攻击创建入口、`coop_damage_slot` 快照 | 伤害、Buff、吸血、无双、掉落 | 命中结束恢复、实体释放 | 缺失来源回落 `RoleProp.source_player`（1P），无告警 |
| 对象池实例 | `Global._pool_data` | `_take/_store` + `recycle_*` | 伤害文本、受击、音效 | 节点 `setup/recycle`、退出清理 | 取出不重置；容量满新建/超限释放 |
| 关卡阶段 | `BaseLevel.current_stage` | `_on_create_control_timeout` + 子类/怪物 22 处直接赋值 | 刷怪、HUD、结算 | 关卡释放、重战 | 子类可绕过阶段表；无统一推进守卫 |
| 胜败/结算 | `BaseLevel._leave_level_from_exit` + 结算场景 | 出口/死亡/结算 `_ready` | HUD、地图、存档 | 返回地图、重战 | 重复切换；保存 bool 丢弃；奖励无回滚 |
| 成长提交 | 各域脚本 | 购买/锻造/学习/奖励 | 面板、背包、属性 | 面板关闭、失败回滚 | 扣费与产出顺序不一致；`forge` 之外无回滚 |
| HUD/表现 | `BaseRole`/`RoleInformation`、面板 | 显式 `player` 注入、命令 | 玩家 | 面板关闭、场景退出 | `RoleProp.source_player` 兜底；表现场景可写档 |
| 模块 API | 各模块脚本 | 模块作者 | 调用方 | 重构/迁移 | 无公开清单；深层路径 279 处；基础类无信号 |

### 2.3 出口（已完成 2026-10-29）

- [x] 每个试点边界都有所有者、写入者、失败处理与是否可能重复提交的记录；
- [x] 归属/阶段/成长写入按业务域分类，标出迁移候选与不迁移理由；
- [x] 对象池复用清理项与残留风险可验证；
- [x] 仅文档与只读报告，不改生产代码；结果进入 [`gameplay_module_matrix.md`](../reference/gameplay_module_matrix.md) 与 [`status.md`](../reference/status.md)。

**17-1 结论对 17-2 的前置**：`apply_role_hit` 的快照恢复已存在；17-2 的优先修复点是 `RoleProp.source_player` 兜底、吸血/腾蛇阵/角色 5 的 1P 读取，以及弹体在根节点创建时的来源缺失。详见矩阵 §4.3、§11.2。

## 3. Phase 17-2：命中与效果归属

**目标**：让攻击、弹体、召唤与法宝在创建时显式携带来源，伤害/Buff/吸血/无双归属只读该来源；池化复用前清除旧状态，归属不随复用漂移。

### 3.1 切片

1. **Phase 17-2A 来源显式化（已完成 2026-10-29）**：删除 `_get_damage_source_player` 的 `RoleProp.source_player` 回落；根节点/技能弹体与浅影显式携带来源；吸血、腾蛇阵与角色 5 等级改读实际出手者；详见 §3.4；
2. **Phase 17-2B 池化复用清理（已完成 2026-10-29）**：四类池节点统一 `prepare_for_pool()`，在归还/预热入口清理；`_take_pooled_node` 不重置；新增 `LocalCoopPoolReuseProbe`；详见 §3.5；
3. **Phase 17-2C 归属回归（已完成 2026-10-29）**：`get_role_last_hurt` 的暴击/护甲/等级改读实际出手者；新增 1P/2P 伤害数值分离断言；召唤非英雄来源优先回溯持有者；详见 §3.6；

### 3.2 必须验证

- 1P/2P 分别出手时，伤害、Buff、吸血与无双记到实际出手者；
- 弹体/召唤/法宝在命中、穿透、反弹与销毁路径上归属一致；
- 池化节点连续复用两轮后不携带上一轮来源与战斗标记；
- 试点外调用方行为不变；`coop_probe_runner` 全用例通过。

### 3.3 出口

- 试点路径的来源只有一个权威字段，归属计算只读该字段；
- 池化复用清理有单一入口与定向用例；
- 无新增第二套伤害/归属通道；数值与命中时序不变。

### 3.4 17-2A 实施记录（2026-10-29）

| 项 | 内容 |
|:---|:---|
| 来源解析 | `BaseMonster._get_damage_source_player` 删除全局别名回落；无来源命中返回 `null`，伤害为 0 |
| 攻击载体 | `Global._assign_attack_source` 统一写 `player` 与 meta `coop_slot`；`add_role_bullet`/`add_role_bullet_1`/`_safe`/`add_role1_shallow` 增加可选来源；根节点 `Role2Bullet7_tx`/`_1` 显式传 `player`；英雄召唤写 meta `coop_slot` |
| 效果归属 | 新增 `_get_vampirism_rate`/`_get_tszz_level`/`_get_role5_skill_level`，按 `LocalCoop.props_for/data_for(source_player)` 读取 |
| 夹具 | 新增 `LocalCoopAttributionSourcesProbe`：无源不回落、P2 普攻/技能/根节点弹体/法宝无双归属、P2 弹体 addeffect 落到目标、命中后来源字段恢复、召唤来源与槽位、吸血/腾蛇阵/角色 5 读 P2、P1/P2 交替不串、`damage_text` 池两轮复用清理 |
| 验证 | `coop_probe_runner` 19/19 PASS；`level_1` 冒烟 PASS；`level_regression_all --changed-only` 128/128 PASS + 5 SKIP（276.3s）；`check_all --godot-bin` 8/8 PASS |
| 残留 | `get_role_last_hurt` 的暴击/护甲/等级、`wd_hurt` 与 `SummonBaseMonster.find_player_reference` 仍读 1P，留给 17-2B/17-2C |

17-2A 只迁移归属入口与三类效果读取，不改伤害公式、命中时序、输入或存档格式。

### 3.5 17-2B 实施记录（2026-10-29）

| 项 | 内容 |
|:---|:---|
| 清理边界 | `_take_pooled_node` 不重置；`_store_pooled_node` 与 `_seed_runtime_pool` 调用 `prepare_for_pool()`；节点 `recycle()` 只做重入守卫并委托 |
| 池节点 | `damage_text`（原有钩子改为委托）、`mr_hurt`、`role_be_hit`、`sound_player` 全部实现 `prepare_for_pool()` |
| 夹具 | 新增 `LocalCoopPoolReuseProbe`：三类节点归还后不可见/停止/清空，再次取出同一节点并重新初始化 |
| 验证 | `coop_probe_runner` 20/20 PASS；`level_1` 冒烟 PASS；`level_regression_all --changed-only` 128/128 PASS + 5 SKIP（262.0s）；`check_all --godot-bin` 8/8 PASS |
| 理由 | 取出后必须用新数据调用 `setup()`；通用重置无法知道目标/文本/音量，统一清理放在池边界 |

### 3.6 17-2C 实施记录（2026-10-29）

| 项 | 内容 |
|:---|:---|
| 伤害属性 | `get_role_last_hurt` 增加可选 `source_player`；按 `get_player` → `_get_damage_source_player` → `RoleProp` 解析来源，暴击/护甲/魔抗/等级/幸运读 `LocalCoop.props_for(attack_source)` |
| 伤害数值 | 新增 `LocalCoopDamageStatsProbe`：P2 暴击/护甲穿透/等级压制分别与 P1 分离，1P 保持基线 |
| 召唤回落 | `find_player_reference` 在非英雄 `summoner` 时先 `LocalCoop.owner_hero(summoner)`，再回落全局别名；探针覆盖法宝持有召唤跟随 P2 |
| 评估未改 | `wd_hurt` 是每物理帧的全局环境检查，不绑定单次命中来源；2P 角色 4 毒伤语义需玩法决策，留 17-3/17-5 |
| 验证 | `coop_probe_runner` 21/21 PASS；`level_1` 冒烟 PASS；`level_regression_all --changed-only` 128/128 PASS + 2 SKIP（314.1s，`level_ghg` 瞬态重试通过）；`check_all --godot-bin` 8/8 PASS |

## 4. Phase 17-3：关卡阶段与结算所有权

**目标**：关卡阶段推进与胜败/重战提交保持唯一所有者；通关/失败只保存一次，失败不半提交。

### 4.1 切片

1. **Phase 17-3A 阶段状态（已完成 2026-10-29）**：`current_stage` 只经 `advance_stage()` 单调推进；基础关卡与 `game4_imported_level` 共用入口；
2. **Phase 17-3B 胜败与重战（已完成 2026-10-29）**：`LevelSettlement` 统一保存、离开、重战与失败提示；胜利/失败按钮加去重守卫，奖励保存失败回滚；
3. **Phase 17-3C 保存一次（已完成 2026-10-29）**：结算、返回与奖励收敛到 `LevelSettlement` 提交点；`lqjl` 增加持久领取标志与整批发放回滚；详见 §4.4。

### 4.2 必须验证

- 阶段推进只发生一次，跳阶段/重战/返回地图后不残留旧阶段；
- 通关与失败分别只保存一次，重复点击返回/重战不重复发奖；
- 结算保存失败时界面可感知，不伪报成功；
- `level_1` 冒烟与相关关卡回归通过。

### 4.3 出口

- 阶段、胜败与结算各有唯一所有者与正式入口；
- 结算保存与发奖顺序固定，失败可判断；
- 不改变关卡数值、刷怪表与通关条件。

### 4.4 17-3 实施记录（2026-10-29）

| 项 | 内容 |
|:---|:---|
| 阶段 | `base_through_level.advance_stage()` 拒绝回退/跳阶；基础关卡与 `game4_imported_level._start_stage()` 改用同一入口 |
| 结算基类 | `LevelSettlement` 持有保存提交、待提交重试、离开/重战守卫、失败提示与场景请求；`victory`/`defeat` 不再各自实现 |
| 胜利 | `_ready` 只提交一次；返回/重战不再额外保存；保存失败保留待提交，返回时重试，失败则中止离开 |
| 失败 | 返回不重复保存；`js`/`yjjj`/`lqjl` 各自守卫并判读保存；保存失败回滚装备/道具/标志 |
| `lqjl` | 整批发放 `PlayerData.add_dj_batch()`；新增持久标志 `失败奖励已领取`；重载/重进不再重复领取 |
| 关卡保存点 | 塔层、17 门、八仙 Boss、星宿层、玲珑塔与 hdzm 判读保存结果并提示；塔层/hdzm/17 门失败回滚 |
| 验证 | `archive_probe_runner` 118 项 PASS；`coop_probe_runner` 21/21 PASS；`level_1` 冒烟 PASS；`level_regression_all --changed-only` 128/128 PASS + 5 SKIP（282.7s）；`check_all --godot-bin` 8/8 PASS |

## 5. Phase 17-4：成长系统命令边界

**目标**：购买、锻造、学习与奖励按业务域提供显式命令：先校验，再提交扣除与产出；保留共同账本与个体分配，失败无部分扣费、无重复领取。

### 5.1 切片

1. **Phase 17-4A 命令盘点（规划）**：按域列出校验、扣除、产出与保存调用，标出跨域写入与重复领取点；
2. **Phase 17-4B 单域试点（规划）**：选择一个域（优先锻造或商店）实现 `校验 → 扣除 → 产出 → 提交` 的单一命令，失败在扣除前返回；
3. **Phase 17-4C 共享/个体分配（规划）**：购买与奖励明确写入共享账本或个体槽位，复用 `LocalCoop.shared_keys()` 与槽位查询，不新增第二组写入者；
4. **Phase 17-4D 失败用例（规划）**：余额不足、背包满、材料不足、重复领取与并发点击各有一条用例，断言无部分扣费。

### 5.2 必须验证

- 校验失败不产生扣除、不写背包、不发奖；
- 成功提交只扣一次、只发一次，重进面板/重开界面不重复领取；
- 共享与个体分配与 Phase 16 结论一致；
- 面板关闭保存与命令提交不互相覆盖。

### 5.3 出口

- 试点域只有一个提交命令，校验与产出顺序固定；
- 失败路径可判断且无副作用；
- 不引入通用事务框架、不改变数值与掉落概率。

## 6. Phase 17-5：HUD/输入/音频表现边界

**目标**：HUD 与面板只读查询并发送明确命令；输入映射与音频表现不拥有领域规则，不直接提交成长或关卡状态。

### 6.1 切片

1. **Phase 17-5A 只读 HUD（规划）**：HUD 数值来自只读查询/快照，不在绘制回调写档案或推进关卡；
2. **Phase 17-5B 输入边界（规划）**：输入只产生意图（移动/技能/面板），业务判定留在领域入口；`p2_*` 映射保持集中登记；
3. **Phase 17-5C 音频表现（规划）**：音效播放归表现层，不携带存档/结算提交；池化音效复用前停止并清空流。

### 6.2 必须验证

- HUD 在暂停、切档、面板开关与场景退出后不残留监听或写入；
- 1P/2P 输入互不串槽，键位修改即时生效且可恢复默认；
- 音效复用不重叠播放、不残留旧流；关闭面板后音频停止策略一致。

### 6.3 出口

- 表现层只读查询与命令调用，不直接写领域状态；
- 输入与音频无新增全局单例，设置仍由既有 `MainSet`/`Music` 承载；
- 显示基线与动画时序不变。

## 7. Phase 17-6：模块 API 与场景依赖治理

**目标**：为受影响模块建立公开 API 与依赖方向清单；深层路径只在试点边界清理，不进行全仓替换。

### 7.1 切片

1. **Phase 17-6A API 清单（规划）**：列出试点模块的公开方法、信号、必需场景与外部依赖，区分稳定契约与内部实现；
2. **Phase 17-6B 依赖方向（规划）**：禁止表现层反向控制领域层、禁止模块直接访问其他模块私有字段；跨模块调用经公开方法；
3. **Phase 17-6C 路径清理（规划）**：只清理试点边界内的深层 `get_node()`/绝对路径，补命名与契约门禁。

### 7.2 必须验证

- 试点模块的公开 API 清单与调用方一致，无未登记的外部入口；
- 迁移后场景加载、依赖注入与既有玩法回归通过；
- 不新增跨模块私有访问；深层路径在试点外零改动。

### 7.3 出口

- 试点模块有可评审的公开 API 与依赖方向；
- 被替代的入口与调用方同批删除，不保留 facade；
- 不重排顶层目录、不搬迁无关模块。

## 8. Phase 17-7：边界守卫与阶段收口

**目标**：把本阶段新增边界纳入静态审计与回归套件，阻断新的未登记归属、重复结算与表现层写入。

### 8.1 切片

1. **Phase 17-7A 静态守卫（规划）**：扩展 `contract_scan.py`，新增试点域规则（禁止未登记归属来源回退、禁止 UI 回调直接发奖/推进阶段、禁止表现层写档案）；规则与正负样本登记到 `scripts/README.md` 与 `acceptance.md`；
2. **Phase 17-7B 清理与索引（规划）**：删除被替代入口与惰性字段，同步 `architecture.md`、`gameplay_module_matrix.md`、`acceptance.md`、`status.md` 与脚本索引；
3. **Phase 17-7C 阶段验收（规划）**：L2 固定套件（含 `coop_probe_runner`）、相关关卡回归、`check_all --godot-bin`、`health_check` 与契约自测；需要时补 release 重验。

### 8.2 必须验证

- 静态守卫正负样本通过，全仓无新增误报；
- 试点域未登记归属回退、重复结算与表现层写入为 0；
- 双人矩阵、相关关卡回归与全量门禁通过；
- 文档、矩阵、验收、状态与脚本索引一致。

### 8.3 出口

- 玩法/表现边界均有 owner、正式入口与失败语义；
- 不再存在未登记的归属回退、重复发奖或表现层直接写档；
- 旧入口与兼容分支删除；
- Phase 17 完成后归档本页，再建立下一候选计划。

## 9. 验证矩阵

既有命令与档位以 [`acceptance.md`](../reference/acceptance.md) 为准，不在本页复制历史数字。

| Phase/变更 | 必需证据 | 不必无差别执行 |
|:---|:---|:---|
| Phase 17-1 调用面矩阵 | 全量引用、owner/写入者/失败表、链接与格式；结果见 `gameplay_module_matrix.md` | 引擎、关卡回归不因只读调查复跑 |
| Phase 17-2 命中归属 | `coop_probe_runner` 归属用例（普攻/技能/弹体/召唤/法宝）、池化复用两轮断言、1P/2P 伤害数值分离、相关关卡冒烟；17-2A/2B/2C 分别由 `LocalCoopAttributionSourcesProbe`/`LocalCoopPoolReuseProbe`/`LocalCoopDamageStatsProbe` 覆盖 | 只测 1P 或只改 `base_monster` 不算完成 |
| Phase 17-3 阶段与结算 | `archive_probe_runner` 的胜败/重战/奖励/保存失败用例（118 项）、`level_1` 冒烟、变更关卡回归 | 只改结算 UI 或只改基类都不算完成 |
| Phase 17-4 成长命令 | 校验失败无扣除、成功只提交一次、重复领取与并发点击用例；共享/个体分配 | 不要求引入通用事务框架 |
| Phase 17-5 HUD/输入/音频 | 暂停/切档/面板/退出后的监听与残留；1P/2P 输入隔离；音效复用 | 只改 HUD 绘制或只改输入映射都不算完成 |
| Phase 17-6 模块 API | 公开 API 清单、依赖方向、试点边界路径清理与场景加载回归 | 不做全仓路径替换 |
| Phase 17-7 边界守卫 | 静态守卫正负样本、全仓零 ERROR、L2、相关回归 | 包路径/导出无变化时不强制重导 release |

## 10. 阶段出口与恢复

- 归属、阶段与结算、成长提交、表现层与模块 API 均有唯一所有者与明确失败语义；
- 来源缺失时行为明确，不静默回退到 1P；池化复用不携带旧状态；
- 通关/失败/重战只提交一次，失败不半提交；
- 表现层不直接写领域状态，输入与音频不拥有领域规则；
- 旧入口与兼容分支删除，不保留永久 facade；
- 文档、ADR、脚本索引与状态一致；需要长期保留的结论进入 `reference/`，历史实施细节归档。

中断时从 Phase 17-1 的调用面矩阵与最近一个已验证切片恢复；失败回滚该逻辑阶段，不恢复被替代的归属回退、重复结算或表现层写入路径。Phase 17 完成后归档本页，再建立下一候选计划。

**恢复入口**：`gameplay_module_matrix.md`、[`architecture.md`](../reference/architecture.md) 的战斗/关卡/UI 章节、[`acceptance.md`](../reference/acceptance.md) 的 L2 档位、[`archive_session_matrix.md`](../reference/archive_session_matrix.md) 的档案/槽位结论、`scripts/coop_probe_runner.py` 的 18 项用例。

**下一候选顺序**：Phase 17 玩法/表现边界 → 面板保存反馈与 `background_save_finished` 消费 → 平台与发布验证按独立工作流推进。平台目标未验证前不得宣传可用。
