# 玩法归属、结算与表现边界

> **职责**：回答战斗归属、战利品/结算、对象池和表现服务由谁提交；完整对象模型见 [`architecture.md`](architecture.md) §4，档案槽位与保存见 [`archive_session_matrix.md`](archive_session_matrix.md)，面板未闭合写入见 [`ui_panel_contract_matrix.md`](ui_panel_contract_matrix.md)。

## 战斗归属

- `BaseMonster.apply_role_hit(source_target, source_player, hit_data)` 是标准角色伤害入口。它要求有效攻击载体与实际 `BaseHero` 来源；无法解析来源时返回 0，不借用 1P。
- 入口拒绝死亡、生成保护及仍在激活期的 Boss 保护目标。有效命中按实际出手者槽位取属性，并在计算时暂绑 `get_target`、`get_player`、属性来源与 `coop_damage_slot`；同步结算后恢复旧上下文。新增弹体、召唤物和法宝必须传递/保留来源，不能依赖场景加载顺序。
- 双人运行时，伤害、吸血、Buff、无双和统计按 `LocalCoop` 的实际来源/槽位归属；无法解析的来源必须显式失败。部分旧调用直接 `state_hurt()` 或 `play_hit_effect()`，不等同于完整伤害/来源结算，特殊边界见 [`combat_behavior_matrix.md`](combat_behavior_matrix.md)。

## 关卡结算与掉落

- 胜利/失败场景继承 `LevelSettlement`。胜利进入时提交一次 `level_victory`；失败时保留待提交原因，离开或重战前必须再次保存，失败则留在当前结算场景。防重复进入由离开/重战锁保护。
- 失败场景的装备、拒绝奖励和领取奖励是各自的显式操作：先保存，失败时恢复该操作快照，成功后才标记已领取；操作仍可重试。它们不等同于胜利的统一待提交记录。
- `BaseMonster.settle_death_drops()` 持有单体掉落/精英卡/塔层结算，并先登记 `death_drops_settled` 再执行，避免死亡回调重复提交。保护控制器和表现层不得另行结算掉落。

## 池、UI、输入与音频

- `CombatPoolRuntime` 由 `Global` 持有，负责伤害数字、怪物/角色受击表现和音效播放器池。取出的节点不保证已按新使用场景初始化；消费者必须调用其 setup/播放入口，归还由 `prepare_for_pool()` 清理，池满则释放。场景切换不整体清池，档案结束/应用退出负责收尾。
- UI/HUD 是表现消费者，不拥有领域提交；面板操作者、关闭保存和未闭合写入风险只见 [`ui_panel_contract_matrix.md`](ui_panel_contract_matrix.md)。
- 战斗输入经角色的 `PlayerInput`/`CoopInput` 读取，P2 使用独立动作前缀；输入处理与档案写入分离。新增或迁移边界以 [`acceptance.md`](acceptance.md) 的静态规则为准。
- BGM/SFX 只经 `AudioRuntime` 的公开入口。父节点失效、音效被关闭/节流、资源或播放器场景缺失、声部不能分配时，`add_bgm`/`add_sound` 返回空值；调用方不得把它当成领域操作成功或自行创建旁路播放器。

| 失败边界 | 结果 |
|:---|:---|
| 无有效攻击来源 | 不造成角色伤害，不回落到 1P。 |
| 命中目标处于 Boss 激活保护 | 本次命中入口返回 0；白条剩余期只免控制，不再阻断伤害。 |
| 结算保存失败 | 胜利的待提交状态阻止离场/重战；失败奖励回滚单次操作并保留重试机会。 |
| 池场景创建失败或池对象未重置 | 工厂可返回空值；消费者不得复用未初始化节点或假报表现成功。 |
| 音频入口不可用 | 允许本次表现不播放；不创建业务侧播放器回退。 |

静态门禁范围与失败判据见 [`acceptance.md`](acceptance.md)。