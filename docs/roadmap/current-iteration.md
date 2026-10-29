# BHYH 当前候选迭代

> **状态**：**Phase 17 已完成并归档；当前候选 Phase 18：玩法/表现遗留缺口收尾。18-1 双人归属与全局别名、18-2 成长与奖励命令、18-3 表现/路径/音频、18-4 档案/运行时/Atlas、18-5 守卫扩面与阶段收口均未启动**。本页只写当前事实与可执行切片，不把目标写成已实现。
> **版本**：6.9；不新增玩法、任务与掉落，不改变数值、动画时序、输入映射、存档格式、本地双人共享规则或显示基线。
> **职责**：本页展开 Phase 18；Phase 17 已归档到 [`iteration_17_gameplay_module_boundaries.md`](../archive/iteration_17_gameplay_module_boundaries.md)，Phase 16 见 [`iteration_16_archive_session_slots.md`](../archive/iteration_16_archive_session_slots.md)。
> **依据**：[`总体目标契约`](../standards/target_architecture_contract.md)、[`godot_design_standard.md`](../standards/godot_design_standard.md)、[`gameplay_module_matrix.md`](../reference/gameplay_module_matrix.md)、[`module_api_matrix.md`](../reference/module_api_matrix.md)、[`archive_session_matrix.md`](../reference/archive_session_matrix.md)、[`runtime_lifecycle_matrix.md`](../reference/runtime_lifecycle_matrix.md)、[`atlas_metadata_schema.md`](../reference/atlas_metadata_schema.md)、[`acceptance.md`](../reference/acceptance.md)、[`status.md`](../reference/status.md)。
> **历史**：Phase 17、16、15、14、13 归档见 [`archive/README.md`](../archive/README.md)。

## 1. 阶段边界与决策

### 1.1 目标

收尾 Phase 17 矩阵中仍未关闭的跨域缺口：1P/2P 归属别名、成长与奖励命令、表现层直接写入、试点路径、音频生命周期、档案/运行时/Atlas 遗留，以及把 17-7 的静态守卫扩到剩余域。每个切片必须有唯一所有者、正式入口、可判断失败语义。

- 先关“会写错档/发错奖/归属漂移”的缺口，再关只读路径与清理；
- 不把遗留缺口混成通用事务框架、事件总线或第二套全局单例；
- 试点域先读矩阵与现有探针，再改代码；每批删除被替代入口，不保留兼容 facade；
- 深层路径、静态缓存与档案 IO 只在登记边界内处理，不全仓替换。

### 1.2 不在本阶段

- 不重写 `base_hero`/`base_monster`/`base_through_level` 继承结构；
- 不改变伤害公式、Buff 数值、掉落、关卡时序、输入映射、物理层、存档格式或共享规则；
- 不新增平台承诺、发布验证或内容回植；
- 不把 `PlayerData.player_data` 整体改成 Resource，不重做档案格式；
- 不清理 Phase 18 未登记的模块与无关目录。

### 1.3 复核基线（2026-10-29）

| 边界 | 当前事实 | 后续归属 |
|:---|:---|:---|
| 1P/2P 归属 | `Global.get_player` 16 处 / 10 文件；`wd_hurt`/`_is_mds_awaken_active` 读全局 `RoleProp`/`PlayerData`；`RoleProp.source_player` 仍是非归属路径全局别名 | 18-1 |
| 伤害/召唤 | `_apply_role_damage_vs_reduction` 仍读全局 `damage_bonus`；`SummonBaseMonster.find_player_reference` 对无持有者非英雄来源仍回落全局 | 18-1 |
| 双人死亡 | 两个死亡分支各自等待后切换（GM-25），未统一全灭提交 | 18-1 |
| 关卡进度写入 | `base_through_level.add_tg` 仍直接写 29 行进度键（GM-26），victory/分支保存顺序已收口但写入未抽取 | 18-4 |
| 成长命令 | 神铸/淬骨/合成/任务奖励未原子化；`forge._on_froge_pressed_legacy` 仅定义无调用；`zd_skill` 仍直接写技能等级/变体 | 18-2 |
| 奖励/商店 | 普通/神秘商店、强化、主动/被动技能已命令化；奖励界面已命令化；2P 打开商店的操作者与并发点击未验证 | 18-2 |
| 表现层 | 幻化/奖励已命令化；任务领取、部分面板仍可能先置标志/发奖后保存 | 18-2/18-3 |
| 路径 | 17-6 后四试点深层字面路径 159→30：`pet_interface` 22、`base_role` 8、`zd_skill` 0、`base_magic_weapon` 0 | 18-3 |
| 音频 | `stop_bgm()` 当前无调用方；BGM 跨父节点复用边界、音效节流表/活动计数清理未覆盖 | 18-3 |
| 档案/运行时 | `background_save_finished` 仅 emit、无消费者；任务保存序号/信号未收口；地图页 `_ready` 保存 IO 未评估；`cleanup_transient_ui` 硬编码清单与模块静态帧缓存仍保留 | 18-4 |
| Atlas | 112 个 metadata 未被 Store 触达；惰性 `atlas_metadata` 写入方与未使用常量仍为 Phase 14 遗留 | 18-4 |
| 守卫 | `phase17_boundary` 仅覆盖结算、两个命令、两个表现文件、四试点路径预算；其他面板/路径/运行时未接入 | 18-5 |

矩阵计数口径见各参考页；本页不复制历史行数。Phase 16/17 的会话、槽位、保存请求与已有关闭项是**不变量**。

## 2. Phase 18-1：双人归属与全局别名

**目标**：所有攻击/效果/提示读取按显式槽位或显式来源解析；不再因全局 1P 别名改变 2P 行为。

### 2.1 切片

1. **18-1A `wd_hurt`/觉醒**：决定角色 4 毒伤在 2P 的语义（每个 Role4 独立触发或仅 1P），从 `RoleProp`/`PlayerData` 改为按实际 Role4 槽位读取；补 1P/2P 毒伤用例；
2. **18-1B `Global.get_player`**：逐文件清理 16 处引用（`dj_sell`、`level_23`、`level_38`、`monster_14501_wdww`、`monster_zhw*`、`weiyang_palace_boss`、`base_monster` 等），改为目标/槽位/显式 owner；
3. **18-1C 召唤与减伤**：`find_player_reference` 无 owner 的非英雄来源明确拒绝或按槽位；`_apply_role_damage_vs_reduction` 改读出手者 `damage_bonus`；
4. **18-1D 全灭提交**：统一两个死亡分支的等待与场景提交，保证双人同时死亡只切一次；补 `coop_probe_runner` 全灭断言。

### 2.2 必须验证

- 2P 角色 4 毒伤/觉醒不读 1P 技能或属性；1P 行为不变；
- `Global.get_player` 试点文件调用为 0，或剩余项有登记且不影响 2P；无来源命中仍返回 0；
- 召唤无持有者时不借用 1P；减伤按出手者；
- 双人同时死亡只产生一次结算场景请求。

### 2.3 出口

- 归属/提示/召唤/减伤均有槽位或显式来源；
- 未登记 `Global.get_player` 与 `RoleProp.source_player` 回落为 0；
- 全灭提交唯一。

## 3. Phase 18-2：成长、奖励与任务命令

**目标**：剩余成长与奖励域复用 17-4 的“校验→快照→扣除→产出→保存→回滚”模式；先置标志/先发奖的顺序全部消除。

### 3.1 切片

1. **18-2A 神铸/淬骨/合成**：为 `divine_forge.gd`、`bone_forge.gd`、`synthesis.gd` 增加快照/恢复与保存判读；失败无部分扣材料；淬骨“失败也扣材料”作为明确设计保留并加注释/用例；
2. **18-2B 任务奖励**：修 `basic_task.gd` 先置已领取/立即保存、延迟发奖的顺序；改为奖励命令提交后置领取标志；补重进/保存失败用例；
3. **18-2C 技能直写**：`zd_skill` 的技能等级/变体直接 `PlayerData.player_data` 写入收敛到 `PlayerData` 技能命令；删除旧入口；
4. **18-2D 死代码与 2P**：删除 `forge._on_froge_pressed_legacy`；验证 2P 打开商店/奖励时操作者与共享账本一致；补并发/重复点击断言；
5. **18-2E 奖励表现**：确定奖励命令失败时是否隐藏奖励盒；保持“失败不发奖、错误可见”，不把表现反馈当成发放成功。

### 3.2 必须验证

- 材料/灵魂/次数不足不产生扣除、不写背包、不发奖；
- 成功只扣一次、只发一次；保存失败恢复；
- 任务奖励重进不重复领取，保存失败不静默丢奖；
- 技能升级/变体与 Phase 17-4 的主动/被动技能保存语义一致；
- 2P 操作者与 Phase 16 槽位结论一致。

### 3.3 出口

- 试点成长/奖励域各有单一提交命令；
- 旧直接写入与死代码删除；
- 失败路径可判断且无部分副作用。

## 4. Phase 18-3：表现层、路径与音频遗留

**目标**：表现层只读/命令；清完试点深层路径；音频生命周期在切换、清理与复用边界可预测。

### 4.1 切片

1. **18-3A 面板扫描**：按矩阵 §9.4 逐个检查任务/奖励/幻化/宠物/技能面板，禁止 `_process`/`_physics_process`/按钮回调直接写 `PlayerData.player_data` 或直接 `request_save`；合法命令保留；
2. **18-3B 路径**：`pet_interface` 22 条、`base_role` 8 条深层路径按场景唯一名或模块访问器继续清理；`skill_icon.gd` 的 `/root` 回落迁移到 `LocalCoop`；路径预算同步收紧；
3. **18-3C 音频**：在场景/档案退出调用 `stop_bgm()` 或定义明确停止策略；处理同曲跨父节点 pending 边界；清理音效节流表/活动计数与模块静态缓存；
4. **18-3D 输入**：用 `coop_probe_runner`/场景探针覆盖 `p2_*` 隔离、键位修改即时生效与恢复默认；无新增输入写入。

### 4.2 必须验证

- 面板绘制回调无档案写入；命令失败有提示；
- 试点路径数量不超过新预算，`/root` 回落为零或登记；
- BGM 同曲复用、切曲停旧、退出停止；音效池无旧流；
- 1P/2P 输入不串槽。

### 4.3 出口

- 表现层无直接领域写入；
- 路径预算与矩阵一致；
- 音频在切场景/退出/复用边界确定。

## 5. Phase 18-4：档案、运行时与 Atlas 遗留

**目标**：关闭 Phase 15/16/14 矩阵中仍有长期价值的运行时缺口，不重开已归档阶段。

### 5.1 切片

1. **18-4A 后台保存信号**：决定 `background_save_finished` 的消费者（UI 反馈/日志/失败重试）；任务保存序号与信号顺序收口；
2. **18-4B 保存 IO 复核**：评估地图页 `_ready` 即保存（AS-08）的必要性与首帧 IO；只在有证据时合并，不改变保存语义；
3. **18-4C 运行时清理**：处理 `cleanup_transient_ui` 硬编码清单/51 处调用与模块静态帧缓存；补退出/切档/面板残留用例；
4. **18-4D Atlas 遗留**：分类 112 个未被 Store 触达 metadata、惰性 `atlas_metadata` 写入方与未使用常量；只处理有消费证据的条目，不重开构建器；
5. **18-4E 关卡进度**：将 `base_through_level.add_tg` 的进度键写入收敛到单一进度命令/数据表，核对胜利与非胜利分支的保存一次；补通关/重战/退出用例。

### 5.2 必须验证

- 后台保存失败可观察，任务奖励不因信号顺序丢失；
- `add_tg` 进度写入单一所有者，非胜利分支也保存一次；
- 地图保存不造成明显首帧卡顿，或明确保留理由；
- 切档/退出后无 UI 注册残留、无旧帧缓存被读取；
- Atlas 条目分类有依据，未消费者不误删。

### 5.3 出口

- 运行时/档案/Atlas 遗留每项有“修复/保留/删除”结论；
- 保留项有 owner、理由与门禁；
- 不重开 Phase 14/15/16 已归档范围。

## 6. Phase 18-5：守卫扩面与阶段收口

**目标**：把 17-7 的静态守卫从四试点扩到 Phase 18 改动域；完成验证与归档准备。

### 6.1 切片

1. **18-5A 守卫扩面**：为 `basic_task`、`divine_forge`、`bone_forge`、`synthesis`、`skill_icon`、`pet_interface`、`base_role`、音频入口登记规则；保存一次/命令快照/表现层不写档/路径预算按域配置；
2. **18-5B 运行时夹具**：将 `archive_probe_runner`、`coop_probe_runner` 的关键用例纳入验收矩阵；补失败样本与负向断言；
3. **18-5C 收口**：`check_all --godot-bin`、L2、相关关卡回归、`contract_scan --self-test`；更新 `status.md`、矩阵、脚本索引与归档。

### 6.2 必须验证

- 新增规则正负样本通过，无新增误报；
- 全仓零 ERROR/WARNING 与全量门禁；
- 双人矩阵、结算/成长/音频夹具、相关关卡回归；
- 文档、矩阵、验收与脚本索引一致。

### 6.3 出口

- Phase 18 缺口全部关闭或明确保留；
- 守卫覆盖 Phase 18 改动域；
- 阶段文档归档，另立下一候选。

## 7. 阶段顺序与恢复

推荐顺序：**18-1 → 18-2 → 18-3 → 18-4 → 18-5**。18-1 先消除会改变 2P 战斗行为的全局别名；18-2 再处理会写档/发奖的成长命令；18-3 处理表现与路径；18-4 处理运行时/Atlas；18-5 扩面守卫并收口。

中断时从最近一个已验证切片恢复；失败回滚该逻辑阶段，不恢复被替代的全局 1P 回落、直接发奖、表现层写档或死代码。Phase 18 完成后归档本页，再建立下一候选。

**恢复入口**：`gameplay_module_matrix.md`、`module_api_matrix.md`、`archive_session_matrix.md`、`runtime_lifecycle_matrix.md`、`atlas_metadata_schema.md`、`acceptance.md`、`scripts/coop_probe_runner.py`、`scripts/archive_probe_runner.py`。

## 8. 验证矩阵

既有命令与档位以 [`acceptance.md`](../reference/acceptance.md) 为准，不在本页复制历史数字。

| Phase/变更 | 必需证据 | 不必无差别执行 |
|:---|:---|:---|
| Phase 18-1 归属 | `coop_probe_runner` 2P 毒伤/觉醒/减伤/召唤/全灭用例，相关关卡冒烟 | 不重跑全量归属矩阵 |
| Phase 18-2 成长 | `archive_probe_runner` 神铸/淬骨/合成/任务/技能成功与失败回滚；2P 商店用例 | 不引入通用事务框架 |
| Phase 18-3 表现/路径/音频 | 面板扫描、路径预算、`stop_bgm`/音效池用例、`coop_probe_runner` 输入隔离 | 只改 HUD 或只改路径不算完成 |
| Phase 18-4 档案/运行时/Atlas | 后台保存信号、切档/退出残留、Atlas 分类报告；按变更触发 L2/回归 | 不重开已归档构建器 |
| Phase 18-5 守卫 | `contract_scan --self-test`、`check_all --godot-bin`、L2、相关回归 | 包路径/导出无变化时不强制 release 重验 |

## 9. 阶段出口

- 18-1~18-4 每项有修复/保留/删除结论与验证；
- 不再存在未登记的 1P 回落、表现层直接写档、成长半提交或重复领取；
- 守卫覆盖 Phase 18 改动域，全仓 ERROR=0；
- 文档、矩阵、脚本索引与状态一致；阶段归档后建立下一候选。

**下一候选**：Phase 18 收口后，按独立工作流处理平台/发布验证；不把未验证平台写成承诺。
