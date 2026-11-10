# 战斗实体控制器与行为边界

> **职责**：说明自动战斗、法宝展示、Boss 保护和受击反应在当前实现中的状态所有者及不可省略的行为边界。伤害归属、结算、池和音频见 [`gameplay_module_matrix.md`](gameplay_module_matrix.md)；对象模型见 [`architecture.md`](architecture.md) §4.2、§4.4。当前候选见 [`../roadmap/current-iteration.md`](../roadmap/current-iteration.md)，验证事实只见 [`status.md`](status.md)，验收要求只见 [`acceptance.md`](acceptance.md)。Phase 25 实施证据见 [`../archive/iteration_25_combat_behavior.md`](../archive/iteration_25_combat_behavior.md)。

## 自动战斗

- 每个 `BaseHero` 持有一份 `AutoBattleContext` 和 `AutoBattleController`；控制器管理目标缓存、技能游标/计数、自动节拍与移动，查询/命令通过 context 回到角色。它不拥有档案保存、重战或切场景。
- 自动开关为全局设置；技能配置按英雄槽位读取，优先槽位覆盖，其次角色配置，最后旧配置。`AutoBattlePlayerSlot` 只表示设置界面的编辑对象，不是运行时启用开关。
- 当前目标只接受有效、存活且在树内的 `BaseMonster`，排除 `no_target`、召唤/宠物和待释放对象；按 0.15s 搜索节拍更新，搜索半径 1800。默认攻击范围 260、垂直范围 220；特定远程技能可把横向范围扩至 320/420。
- 每 0.22s 尝试一轮技能；冷却/MP 不足跳过，只有冷却、MP、动作或施法状态变化才计入成功起手。空配置清游标/计数。仅技能模式清目标并停水平移动。
- 自动动作顺序仍为自动法宝、剑阵、无双，再检查普通施法/控制门禁。无有效目标时，非仅技能移动没有停止策略，会朝右推进到碰撞/其他门禁；关掉自动会清目标和技能计数，但不重置跳跃计时器。
- 启用自动移动时，`noarmal_control()` 在该分支返回，不执行其后的手动移动、技能和跳跃输入；但外层法宝输入仍单独读取，角色 3 的 `is_t_mc` 分支也保留手动技能键路径。不能宣称所有手动输入冲突已隔离。
- 英雄退出调用 `reset()` 清目标、技能状态与计时器。新英雄重新读取仍为真的全局开关，不继承旧目标。

## 法宝展示实例

- 每个英雄的 `MagicWeaponPresentationController` 只管理该槽位当前装备的 `BaseMagicWeapon` 展示实例；冷却、技能与伤害仍归 `BaseMagicWeapon`。法宝清单为空则释放实例；`实战法宝` 为空时选第一件并写回该槽位档案，退役项清空。
- 创建要求父节点、返回实例类型与 `set_magic_weapon_player` 能力有效；任一条件失败都不保留坏实例，后续同步可重试。英雄退出清理展示实例；`Global`/`MagicWeaponRuntime` 仍拥有召唤物槽位。

## Boss 保护与白条

- 每个 `BaseMonster` 的 `BossProtectionController` 管累计值、激活时长和白条计时；`BaseMonster` 执行激活副作用并拥有血量、技能、死亡与掉落。`boss_max_protect` 固定为 225；有效命中每次累积 1–3，静置 1s 后以 6/s 衰减。
- 达上限进入 3.5s 伤害保护并开启 7.5s 白条控制免疫。激活期伤害入口早退为 0；保护结束后白条仍免疫控制，但允许伤害。激活清控制、重置相关技能冷却、停水平速度并半透明；退出时清保护状态。
- 控制免疫还包括超级护甲/精英卡。免疫会取消当前受击代次、清控制和控制位移；不要把“免控制”误写成“免伤害”（只有 Boss 激活保护入口拒绝伤害）。

## 受击反应

- `HitReactionController` 仅管理怪物的活动标志、代次和来源快照。标准 `apply_role_hit()` 在有效伤害后捕获攻击者/载体/`hit_dic`，恢复同步伤害上下文；异步动画完成只允许匹配代次的回调清理当前反应。
- `hurtBack` 为零时，伤害和攻击中断仍可发生，但不进入普通受击动画/击退代次；`is_quiescent`/`is_bt` 跳过击退；`Monster114` 保留不击退的专用流程；无 `hurt` 动画时用 0.2s 回退。控制免疫、死亡和生成保护会抑制相应反应。
- `play_hit_effect()` 是表现型路径，不等同于完整伤害结算；延迟动画按受击代次检查，旧回调不得覆盖新反应。`BaseHero` 自己的受击僵直有独立 generation/待处理队列，退出重置它们，但不重置保护/白条状态。
- 部分弹体/召唤物和怪物子类仍直接调用或覆写 `state_hurt()`；这些路径可保留各自阶段、免控和动画时序，不会因此自动获得 `apply_role_hit()` 的来源解析、伤害校验或快照。新增标准角色伤害应走完整入口；不要把专用覆写描述成全部迁入统一状态机。