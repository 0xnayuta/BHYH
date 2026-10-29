# BHYH 当前候选迭代

> **状态**：**Phase 17 已完成并归档；当前候选为 Phase 18~20 综合收尾。18-1A/18-1B/18-1C/18-1D/18-2A/18-2B/18-2C/18-2D/18-2E/18-3A/18-3B/18-3C/18-3D/19-1A/19-1B/19-1C 已完成；19-2、19-3、19-4、20-1、20-2、20-3 未启动**。本页只写当前事实与可执行切片，不把目标写成已实现。
> **版本**：6.9；不新增玩法、任务与掉落，不改变数值、动画时序、输入映射、存档格式、本地双人共享规则或显示基线。
> **职责**：本页展开 Phase 18~20；Phase 17 已归档到 [`iteration_17_gameplay_module_boundaries.md`](../archive/iteration_17_gameplay_module_boundaries.md)，Phase 13~16 归档见 [`archive/README.md`](../archive/README.md)。
> **依据**：[`总体目标契约`](../standards/target_architecture_contract.md)、[`godot_design_standard.md`](../standards/godot_design_standard.md)、[`gameplay_module_matrix.md`](../reference/gameplay_module_matrix.md)、[`module_api_matrix.md`](../reference/module_api_matrix.md)、[`archive_session_matrix.md`](../reference/archive_session_matrix.md)、[`runtime_lifecycle_matrix.md`](../reference/runtime_lifecycle_matrix.md)、[`atlas_metadata_schema.md`](../reference/atlas_metadata_schema.md)、[`acceptance.md`](../reference/acceptance.md)、[`status.md`](../reference/status.md)。
> **历史**：Phase 13、14、15、16、17 归档见 [`archive/README.md`](../archive/README.md)。

## 1. 阶段边界与决策

### 1.1 目标

收尾 Phase 13~17 已登记但尚未关闭的跨阶段缺口：1P/2P 归属、成长/奖励/任务提交、保存反馈与进度、表现层与路径、音频/运行时清理、资源/Atlas 管线、独立项目与平台验证。每个切片必须有唯一所有者、正式入口与可判断失败语义。

- 先关“会写错档/发错奖/归属漂移”的正确性缺口，再关性能、资源与平台项；
- Phase 13/14/15/16 已归档结论保持不变；本阶段只处理矩阵登记为“后续/未迁移/部分修复/独立立项”的条目；
- 不引入通用事务框架、事件总线或第二套全局单例；
- 试点域先读矩阵与现有探针再改代码；每批删除被替代入口，不保留兼容 facade；
- 资源、平台与独立项目先决策后执行，不以 headless 或单平台结果替代目标平台验证。

### 1.2 不在本阶段

- 不重写 `base_hero`/`base_monster`/`base_through_level` 继承结构；
- 不改变伤害公式、Buff 数值、掉落、关卡时序、输入映射、物理层、存档格式或共享规则；
- 不新增玩法、任务、掉落、平台承诺或内容回植；
- 不把 `PlayerData.player_data` 整体改成 Resource；
- 不做全仓目录搬迁、全仓 `get_node` 替换或无证据的素材重制；
- Phase 13 的 `global.gd` 上帝对象、Spine 跨平台、`_bundled`、类型化 Atlas accessor 属于独立立项，本计划只做决策/验收，不顺手大拆。

### 1.3 全阶段缺口基线（2026-10-29 复核）

| 来源 | 已核实事实 | 归属 |
|:---|:---|:---|
| Phase 17 / 16 归属 | **18-1A 已修复** `wd_hurt`/觉醒；**18-1B 已删除** `Global.get_player`（原 13 引用 / 9 文件）；**18-1C 已修复** 无 owner 召唤不再回落 1P、`_apply_role_damage_vs_reduction` 读实际出手者 `damage_bonus`；**18-1D 已统一双人死亡提交**；剩余 `RoleProp.source_player` 回落登记为 HUD/UI/视图别名，不参与伤害归属 | 已关闭 |
| Phase 17 双人死亡 | 两个死亡分支各自等待后切换（GM-25），双人同时死亡可能重复切换 | 18-1 |
| Phase 17 成长 | **18-2A/18-2B 已修复神铸/淬骨/合成/任务奖励**：成长三域增加快照/保存判读/失败恢复，任务领取由 `RewardGrantCommand` 在保存快照内提交；`forge._on_froge_pressed_legacy` 已删除；`zd_skill` 等级/变体经 `PlayerData` 命令；2P 商店/奖励共享账本与重复购买无副作用已由档案/合作探针覆盖 | 18-2A/18-2C/18-2D |
| Phase 16 保存反馈 | **18-3D 已修复**：`request_save_result` 返回 `{ok, reason, error, message, path, notify}`，`last_save_outcome` 与 `save_failed` 信号让丢弃 bool 的调用也可观察；22 处自行提示调用传 `notify=false`，其余由 `Global` 兜底提示（1.5s 去重）；后台保存仍走独立串行/重试路径 | 18-3D 完成 |
| Phase 16 档案顺序 | **18-3A 已关闭 AS-14**：后台任务带 serial，`Global` 消费信号并记录失败；切档/退出先 flush。**18-3B 已评估 AS-08**：11 个地图页保留一次同步保存（当前地图唯一持久化点）；仅删除 `map_3` 无数据变更的重复保存 | 18-3A/18-3B 完成 |
| Phase 16 进度写入 | **18-3C 已修复 `add_tg` 写入面**：48 关/23 区域/导入 63~75/北俱芦洲动态键收敛到 `LevelProgressCommand` 数据表；`add_tg` 只写字典，不保存；非胜利转场新增单次 `level_progress_transition` 保存。地图页 `Map_num`、镇妖塔层/积分、GM 工具仍直接写 | 18-3C 完成 |
| Phase 17 表现/路径 | `pet_interface` 22 条、`base_role` 8 条深层字面路径；`skill_icon` 仍有 `/root` 回落；任务/宠物/技能等面板仍可能先置标志/直接写档 | 19-1 |
| Phase 17 音频 | `stop_bgm()` 无调用方；BGM 同曲跨父节点 pending 边界、音效节流表/活动计数清理未覆盖 | 19-2 |
| Phase 15 运行时 | `cleanup_transient_ui` 硬编码清单与 51 处显式调用（矩阵基线 18 文件）；模块局部静态帧缓存按 15-4E 保留 | 19-2 |
| Phase 14 Atlas | 112 个 metadata 未被 `AtlasMetadataStore` 规则触达；类型化 `.data` accessor 仍是独立立项 | 19-3/20-1 |
| Phase 13 资源 | 12 个运行时建帧冻结例外（9 怪物 + 3 非怪物）；`runtime_frames_allowlist` 只减不增；PCK 快照随资源变化需重跑 | 19-3 |
| Phase 13 独立项目 | `Spine` 跨平台运行时仅 Windows x86_64；`global.gd`+13 Autoload 上帝对象；`_bundled` 历史二进制场景；目标平台 VRAM/首帧/release 未测 | 20-1/20-2 |
| 守卫 | `phase17_boundary` 只覆盖结算、两个命令、两个表现文件、四试点路径预算；其他域未接入 | 20-3 |

矩阵计数口径见各参考页；本页不复制历史行数。Phase 16/17 的会话、槽位、保存请求、原子命令与已关闭项是**不变量**。

## 2. Phase 18：归属、成长与档案提交

### 2.1 Phase 18-1：双人归属与全局别名

**目标**：攻击/效果/提示读取按显式槽位或显式来源解析；不再因全局 1P 别名改变 2P 行为。

**切片**

1. **18-1A `wd_hurt`/觉醒（已完成，2026-10-29）**：语义定为**每个 Role4 独立触发**；Voodoo 层记录 `source_player`，按来源分组计数、各自读取槽位档案/属性结算，只移除本来源层；1P 行为不变，2P 不再读 1P；探针 `LocalCoopRole4PoisonProbe` 覆盖 1P、2P、混合层与觉醒；`coop_probe_runner` 22/22 PASS，`level_1` 冒烟 PASS，`level_regression_all --changed-only` 128/128 PASS + 5 SKIP（271.9s），`check_all --godot-bin` 8/8 PASS；
2. **18-1B `Global.get_player`（已完成，2026-10-29）**：删除全局 1P 别名；`base_monster` 目标改 `LocalCoop.nearest_player`，`dj_sell` 改 `RoleProp.source_player`，`level_23/38` 提示改进入的 `body`，`monster_14501_wdww`/`weiyang_palace_boss` 改最近玩家，`monster_zhw*` 改 `player_reference`/最近玩家；全仓 `Global.get_player` 引用 0；`coop_probe_runner` 22/22 PASS，`level_1` 冒烟 PASS，`level_regression_all --changed-only` 128/128 PASS + 5 SKIP（354.3s，两关瞬态重试通过），`check_all --godot-bin` 8/8 PASS；
3. **18-1C 召唤与减伤（已完成，2026-10-29）**：`SummonBaseMonster.find_player_reference` 只认显式 `summoner`/owner，无 owner 返回 null，不再回落 1P 或场景首个英雄；`_apply_role_damage_vs_reduction` 通过 `hurt_reduce_hp`/毒爆上下文读取实际出手者 `damage_bonus`，不再读全局；剩余 `RoleProp.source_player` 仅存 HUD/UI/视图别名，登记不参与伤害；`LocalCoopDamageStatsProbe` 覆盖减伤 75 vs 125，归属探针覆盖无 owner 拒绝；
4. **18-1D 全灭提交（已完成，2026-10-29）**：两个 `BaseHero` 死亡分支统一调用 `LocalCoop.request_defeat_if_all_players_dead()`；`_defeat_requested` 去重，切换失败可重试，场景切换/清理时重置；新增 `LocalCoopAllDeadProbe` 覆盖单人/双人、重复请求与失败重试；`coop_probe_runner` 23/23 PASS，`level_1` 冒烟 PASS，`level_regression_all --changed-only` 128/128 PASS + 5 SKIP（261.0s），`check_all --godot-bin` 8/8 PASS；

**必须验证**：2P 角色 4 毒伤/觉醒不读 1P（18-1A）；`Global.get_player` 全仓引用为 0（18-1B）；无来源命中仍为 0；召唤无 owner 不借用 1P（18-1C）；双人全灭只请求一次结算（18-1D）。

**出口**：归属/减伤/召唤/全灭均有槽位或显式来源；未登记全局回落为 0。

### 2.2 Phase 18-2：成长、奖励与技能命令

**目标**：剩余成长/奖励域复用“校验→快照→扣除→产出→保存→回滚”；先置标志/先发奖的顺序全部消除。

**切片**

1. **18-2A 神铸/淬骨/合成（已完成，2026-10-29）**：三域增加 `PlayerData.snapshot_state`/`restore_state`、产出 bool 判读与仅成功保存；淬骨保留“失败也扣材料”设计并补用例；同时统一 `MLdl.qh_list`/装备 `Data` 键，档案探针新增 8 项成功/失败/回滚断言（总 163 项 PASS）；
2. **18-2B 任务奖励（已完成，2026-10-29）**：`basic_task` 不再先置已领取/直接保存；领取标记与八仙进度作为 `RewardGrantCommand` 的 `claim` 回调，在快照后、保存前提交，失败恢复；`reward_interface` 透传回调；档案探针新增普通任务重进/保存失败与八仙进度回滚用例，**155 项 PASS**；`level_1` 冒烟 PASS，`level_regression_all --changed-only` 128/128 PASS + 5 SKIP（322.7s，两关瞬态重试通过），`check_all --godot-bin` 8/8 PASS；
3. **18-2C 技能直写（已完成，2026-10-29）**：`zd_skill` 等级读写改用 `PlayerData.get_skill_level`/`set_skill_level`；变体改用 `PlayerData.select_skill_variant` 原子保存/回滚；删除旧直写；档案探针新增变体成功/重载/保存失败断言；
4. **18-2D 死代码与 2P（已完成，2026-10-29）**：删除 `forge._on_froge_pressed_legacy`；档案探针验证 2P 商店/奖励共享灵魂与背包各只记一次，重复购买失败无副作用；
5. **18-2E 保存反馈（已完成，2026-10-29）**：新增 `Global.request_save_with_feedback`；面板关闭、背包显示设置、物品锁定接入失败提示与状态回滚；奖励/商店已由命令结果提示；剩余 `request_save` 未迁移点按地图首帧 IO/低风险动作登记，归 18-3B/后续。最终验证：档案持久化 171 项 PASS，`coop_probe_runner` 23/23 PASS，`level_1` 冒烟 PASS，`level_regression_all --changed-only` 128/128 PASS + 5 SKIP（259.8s），`check_all --godot-bin` 8/8 PASS。

**必须验证**：材料/灵魂/次数不足不产生扣除、不写背包、不发奖（18-2A 已覆盖）；成功只扣一次、只发一次；保存失败恢复（18-2A/18-2B/18-2C 已覆盖）；任务重进不重复领取（18-2B 已覆盖）；2P 商店/奖励共享账本（18-2D 已覆盖）；剩余丢弃返回值有登记（18-2E）。

**出口**：试点成长/奖励/任务域单一命令；旧直写与死代码删除；失败可判断且无部分副作用。

### 2.3 Phase 18-3：档案顺序与关卡进度

**目标**：后台保存、任务保存、地图首帧保存与关卡进度写入有明确顺序与单一所有者。

**切片**

1. **18-3A 后台保存信号（已完成，2026-10-29）**：`background_save_finished` 增加 `serial`；`Global._on_background_save_finished` 为唯一消费者，记录最后序号/路径/成功态/失败次数，失败通过 `last_save_error`、`push_error` 与 `Global.get_background_save_status()` 可观察，不弹战斗内 UI；`end_archive_session`/`set_cd_path` 先 flush；档案探针新增序号单调、失败可观察、重试与退出 flush 用例（总 193 项 PASS）；`level_1` 冒烟 PASS；
2. **18-3B 地图首帧保存（已完成，2026-10-29）**：11 个地图页均在更新 `Map_num`/`HeavenMap_num` 后保存，是进入城市后的唯一持久化点，删除会丢失崩溃/立即退出时的当前地图，故保留同步语义；仅删除 `map_3._sync_special_button_layer` 的重复保存（只改 z-index、且在 `Map_num=3` 前）。稳态保存实测约 4.7ms；独立冷启动微基准首档密钥创建约 108ms（一次性），地图页保存通常复用已创建密钥；无证据表明城市首帧存在明显卡顿；档案探针 193 项 PASS，`level_1` 冒烟 PASS；
3. **18-3C 关卡进度（已完成，2026-10-29）**：新增 `LevelProgressCommand` 数据表，覆盖 1~48 关、23 个区域名、导入关卡 63~75 与北俱芦洲动态键；`base_through_level.add_tg`/`north_continent_level.add_tg` 只调用命令，删除 48 分支 match。`add_tg` 只写字典不保存；Level17/22、Level19 非胜利、Level20、Level10/21 剧情跳过关闭分支在转场前调用 `_commit_progress_before_transition` 单次保存，失败保持当前关卡并解除退出锁；胜利仍由 `victory._ready` 单次提交。档案探针新增 63 项进度表检查（总 256 项 PASS），场景探针新增 6 个特殊关卡分支，`level_progress_exit_probe` 6/6 PASS；`level_1` 冒烟 PASS，`level_regression_all --changed-only` 128/128 PASS + 5 SKIP（259.7s），`check_all --godot-bin` 8/8 PASS；
4. **18-3D 会话失败反馈（已完成，2026-10-29）**：`MemoryClass.request_save_result` 统一返回 `ok/reason/error/message/path/notify`，并写入 `last_save_outcome`；`save_failed` 信号由 `Global` 消费，`notify=false` 仅计数，其余在可见 UI 层提示且同错误 1.5s 去重；`Global.request_save_with_feedback` 内部抑制兜底后只提示一次。无会话/身份过期/非法路径/写失败均返回结构化错误；档案探针新增 11 项结果/信号/消费者断言（总 267 项 PASS）；`level_1` 冒烟 PASS，`level_regression_all --changed-only` 128/128 PASS + 5 SKIP（268.1s），`check_all --godot-bin` 8/8 PASS；

**必须验证**：后台保存失败可观察，任务奖励不因信号顺序丢失（18-3A 已覆盖）；地图保存不造成明显首帧卡顿或明确保留理由（18-3B 已覆盖，保留理由为当前地图唯一持久化点）；`add_tg` 写入单一所有者，非胜利分支也保存一次（18-3C 已覆盖）；无会话/身份过期/写失败不再静默 `false`（18-3D 已覆盖）。

**出口**：档案/进度顺序固定；保留的首帧保存有 owner/理由；无静默失败。

## 3. Phase 19：表现、运行时与资源管线

### 3.1 Phase 19-1：表现层与路径

**目标**：表现层只读查询/命令；试点深层路径与 `/root` 回落继续收口。

**切片**

1. **19-1A 面板扫描（已完成，2026-10-29）**：任务领取改用 `PlayerData.claim_task`；幻化穿戴/卸下改用 `change_transmog`，拥有列表改用 `record_transmog_owned`；技能键位改用 `set_skill_key`，觉醒/启停改用 `awaken_skill`/`set_skill_awakened_enabled`，被动技能改用 `apply_passive_skill_upgrades`；宠物面板存档改走 `Global.request_save_with_feedback`。目标目录不再有直接 `PlayerData.player_data` 赋值或直接 `MemoryClass.request_save`；`reward_grant_command` 与 `zd_skill.refresh_infor` 作为合法命令入口保留。档案探针 275 项 PASS；`level_1` 冒烟 PASS，`level_regression_all --changed-only` 128/128 PASS + 5 SKIP（267.7s），`check_all --godot-bin` 8/8 PASS；
2. **19-1B 路径（已完成，2026-10-29）**：`pet_interface` 动态行先取 `Content` 再取直接子节点，深层字面路径 22→0；`base_role` 宠物 HUD 先取各 bar/PanelContainer 再取子节点，8→0；`skill_icon.gd` 删除 `/root` 回落，直接 `LocalCoop.data_for/props_for`；`contract_scan` 将三文件深层预算收紧到 0，并把 `skill_icon` 加入 `/root` 禁入与移除 root 白名单；档案探针 275 项 PASS，`coop_probe_runner` 23/23 PASS，`level_1` 冒烟 PASS，`level_regression_all --changed-only` 128/128 PASS + 5 SKIP（273.6s），`check_all --godot-bin` 8/8 PASS；
3. **19-1C 奖励表现（已完成，2026-10-30）**：`RewardGrantCommand` 失败时 `reward_interface` 隐藏并释放奖励盒、标题改为“奖励发放失败”、错误提示保留；成功时奖励盒保留。空奖励/无有效奖励不再创建空 Tween；档案探针新增成功保留、失败隐藏、失败不发奖断言（总 280 项 PASS）；`level_1` 冒烟 PASS，`level_regression_all --changed-only` 128/128 PASS + 5 SKIP（262.5s），`check_all --godot-bin` 8/8 PASS；

**必须验证**：绘制/回调无档案写入（19-1A 已覆盖目标面板）；路径不超预算，`/root` 回落为零或登记；奖励失败不显示成功假象。

**出口**：表现层无直接领域写入；路径预算与矩阵一致。

### 3.2 Phase 19-2：音频与运行时清理

**目标**：音频与临时 UI/静态缓存在切换、退出、复用边界可预测。

**切片**

1. **19-2A BGM**：在场景/档案退出调用 `stop_bgm()` 或定义明确停止策略；处理同曲跨父节点 pending 边界；
2. **19-2B 音效池**：复核节流表、活动计数、池满/回收后的旧流与音量设置；
3. **19-2C 临时 UI**：处理 `cleanup_transient_ui` 硬编码清单与显式调用（矩阵 51/18 基线）；未登记节点登记或明确保留；
4. **19-2D 静态帧缓存**：处理模块局部静态帧缓存（Phase 15-4E 保留项）；退出/切档后不读取旧缓存。

**必须验证**：BGM 同曲复用、切曲停旧、退出停止；音效池无旧流；切档/退出无 UI 注册残留；静态缓存有清理/保留结论。

**出口**：音频与运行时清理有明确 owner 与保留清单。

### 3.3 Phase 19-3：资源与 Atlas

**目标**：关闭 Phase 13/14 可验证的资源管线遗留；不重做构建器。

**切片**

1. **19-3A 运行时建帧例外**：逐项复核 12 个冻结例外（9 怪物 + 3 非怪物），给出“保留/补资源/删除回退”结论；`runtime_frames_allowlist` 只减不增；
2. **19-3B Atlas 未触达 metadata**：分类 112 个未被 `AtlasMetadataStore` 触达的 metadata（构建/溯源/地图/角色图集/未迁移代码）；有消费证据的建访问清单，无证据不误删；
3. **19-3C PCK/资源闭包**：资源变化后重跑 Catalog/PCK 闭包；记录当前字节数与可达数，不沿用历史快照。

**必须验证**：每个例外有结论；Atlas 分类有证据；PCK 闭包全可达；资源变化触发重跑。

**出口**：资源例外/Atlas 清单可审计；不新增未登记运行时建帧。

### 3.4 Phase 19-4：输入与 HUD

**目标**：验证输入隔离与 HUD 只读，不改变映射/布局。

**切片**

1. **19-4A 输入隔离**：`coop_probe_runner`/场景探针覆盖 1P/2P `p2_*`、键位修改即时生效与恢复默认；
2. **19-4B HUD 只读**：确认 P1/P2 HP/MP/经验/无双/宠物来自槽位查询，暂停/切档/面板开关后无监听或写入残留；
3. **19-4C 输入写入守卫**：静态扫描输入读取行不得出现 `PlayerData`/`request_save`；例外登记。

**必须验证**：1P/2P 不串槽；HUD 不写档；切档/退出无残留监听。

**出口**：输入与 HUD 边界有测试与静态守卫；显示基线不变。

## 4. Phase 20：独立项目、平台与收口

### 4.1 Phase 20-1：Phase 13 独立立项处置

**目标**：对 Phase 13 归档中的独立项目做采用/延期/拒绝决策，不直接大拆。

**切片**

1. **20-1A Spine 跨平台**：确定目标平台、Spine 运行时版本与许可证；补二进制/`.gdextension` 并做目标平台加载验收；
2. **20-1B `global.gd` + 13 Autoload**：产出拆分边界清单与迁移顺序；本阶段只决策/试点，不顺手全拆；
3. **20-1C `_bundled` 历史场景**：单独立项评估转换、UID/导入缓存与回归；
4. **20-1D 类型化 Atlas accessor**：基于 Phase 14 消费清单评估 typed schema；不改变视觉结果。

**必须验证**：每项有采用/延期/拒绝结论、owner 与前置条件；不把 Windows/headless 当跨平台通过。

**出口**：独立项目有明确去向；未启动项不阻塞 Phase 18/19。

### 4.2 Phase 20-2：平台与发布验证

**目标**：把资源闭包与目标设备验证分开记录，不把 headless 当 VRAM/发布证据。

**切片**

1. **20-2A 目标平台矩阵**：确认目标平台、渲染后端与最低设备；
2. **20-2B VRAM/首帧/战斗负载**：在真实设备测量；记录基线；
3. **20-2C release 包**：重跑 PCK/启动/关卡冒烟；资源变化后不沿用旧包结论。

**必须验证**：目标设备数据可复现；release 包能启动并进入代表关卡；日志干净。

**出口**：平台/发布结论有设备与日期；未测平台明确标注。

### 4.3 Phase 20-3：守卫扩面与阶段收口

**目标**：把 17-7 静态守卫扩到 18/19 改动域，完成验证与归档。

**切片**

1. **20-3A 守卫扩面**：为 `basic_task`、`divine_forge`、`bone_forge`、`synthesis`、`skill_icon`、`pet_interface`、`base_role`、音频入口登记规则；保存一次/命令快照/表现层不写档/路径预算按域配置；
2. **20-3B 运行时夹具**：把 `archive_probe_runner`、`coop_probe_runner`、场景探针的关键用例纳入验收矩阵；补失败/负向断言；
3. **20-3C 收口**：`check_all --godot-bin`、L2、相关关卡回归、`contract_scan --self-test`；更新 `status.md`、矩阵、脚本索引与归档。

**必须验证**：守卫正负样本通过、无新增误报；全仓零 ERROR/WARNING；双人/档案/成长/音频/关卡回归；文档一致。

**出口**：Phase 18/19 缺口全部关闭或明确保留；守卫覆盖改动域；阶段归档。

## 5. 阶段顺序与恢复

推荐顺序：**18-1 → 18-2 → 18-3 → 19-1 → 19-2 → 19-3 → 19-4 → 20-1 → 20-2 → 20-3**。

- 18-1 先消除 2P 战斗归属；18-2/18-3 再修会写档/发奖/进度的正确性缺口；
- 19-1/19-2 处理表现与运行时；19-3 处理资源/Atlas；19-4 补输入/HUD 验证；
- 20-1 对独立项目做决策；20-2 单独做目标平台/发布验证；20-3 扩面守卫并收口。

中断时从最近一个已验证切片恢复；失败回滚该逻辑阶段，不恢复被替代的全局 1P 回落、直接发奖、表现层写档、死代码或无证据的资源回退。Phase 20 完成后归档本页，另立下一候选。

**恢复入口**：`gameplay_module_matrix.md`、`module_api_matrix.md`、`archive_session_matrix.md`、`runtime_lifecycle_matrix.md`、`atlas_metadata_schema.md`、`acceptance.md`、`scripts/coop_probe_runner.py`、`scripts/archive_probe_runner.py`、`scripts/scene_probe_runner.py`。

## 6. 验证矩阵

既有命令与档位以 [`acceptance.md`](../reference/acceptance.md) 为准，不在本页复制历史数字。

| Phase/变更 | 必需证据 | 不必无差别执行 |
|:---|:---|:---|
| Phase 18-1 归属 | `coop_probe_runner` 2P 毒伤/觉醒/减伤/召唤/全灭；相关关卡冒烟 | 不重跑全量归属矩阵 |
| Phase 18-2 成长/奖励 | `archive_probe_runner` 神铸/淬骨/合成/任务/技能成功与失败回滚；2P 商店/奖励；保存反馈 | 不引入通用事务框架 |
| Phase 18-3 档案/进度 | 后台保存/任务顺序/地图首帧/`add_tg` 用例；无会话/失败反馈；相关关卡回归 | 不重做存档格式 |
| Phase 19-1 表现/路径 | 面板扫描；路径预算；奖励失败表现；`check_all` 契约域 | 只改 UI 不算完成 |
| Phase 19-2 音频/运行时 | BGM 同曲/切曲/退出；音效池；临时 UI/静态缓存残留 | 只改音量不算完成 |
| Phase 19-3 资源/Atlas | 12 例外结论；112 metadata 分类；PCK/闭包重跑 | 不重开构建器 |
| Phase 19-4 输入/HUD | `coop_probe_runner` 输入隔离；HUD 只读；暂停/切档/退出残留 | 不改映射/布局 |
| Phase 20-1 独立项目 | 采用/延期/拒绝决策与 owner | 不顺手大拆 |
| Phase 20-2 平台/发布 | 目标设备 VRAM/首帧/负载；release 启动与代表关卡；PCK | headless 不作 VRAM 证据 |
| Phase 20-3 守卫 | `contract_scan --self-test`、`check_all --godot-bin`、L2、相关回归 | 包路径/导出无变化不强制 release 重验 |

## 7. 阶段出口

- Phase 18/19 每项有修复/保留/删除结论与验证；
- 不再存在未登记的 1P 回落、表现层直接写档、成长半提交、重复领取或静默保存失败；
- Phase 20 独立项目有明确去向，平台/发布结论有设备与日期；
- 守卫覆盖 Phase 18/19 改动域，全仓 ERROR=0；
- 文档、矩阵、脚本索引与状态一致；阶段归档后建立下一候选。

**下一候选**：Phase 20 收口后，按独立工作流处理平台/发布验证；不把未验证平台写成承诺。
