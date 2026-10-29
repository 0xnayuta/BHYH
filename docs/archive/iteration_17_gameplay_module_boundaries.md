# Phase 17：玩法与表现模块边界（归档）

> **归档日期**：2026-10-29
> **状态**：Archived；Phase 17-1 ~ 17-7 已完成，Phase 18 起为当前候选。
> **关联**：[`current-iteration.md`](../roadmap/current-iteration.md)、[`gameplay_module_matrix.md`](../reference/gameplay_module_matrix.md)、[`module_api_matrix.md`](../reference/module_api_matrix.md)、[`archive_session_matrix.md`](../reference/archive_session_matrix.md)、[`runtime_lifecycle_matrix.md`](../reference/runtime_lifecycle_matrix.md)、[`acceptance.md`](../reference/acceptance.md)、[`status.md`](../reference/status.md)。

## 1. 阶段结论

Phase 17 收敛了玩法与表现模块的所有权与失败边界：

| 批次 | 结论 |
|:---|:---|
| 17-1 | 建立调用面矩阵：攻击/弹体/召唤/法宝来源、对象池、阶段/结算、成长提交、HUD/输入/音频、模块依赖 |
| 17-2A/B/C | 来源显式化、池化复用清理、归属回归；伤害数值按出手者读取 |
| 17-3 | `current_stage` 单调入口；胜败/重战/保存一次；`lqjl` 持久领取与整批回滚 |
| 17-4 | 普通/神秘商店、强化、主动/被动技能的命令化与失败回滚；`PlayerData` 快照原语 |
| 17-5 | 幻化/奖励面板命令化；BGM 单实例与切曲停旧；音效池回收清流 |
| 17-6 | 四试点模块公开 API/依赖方向；深层字面路径 159→30 |
| 17-7 | 静态边界守卫：保存一次、命令快照、表现层不写档、试点路径预算；阶段归档 |

## 2. 最终验证

| 项 | 结果 |
|:---|:---|
| `archive_probe_runner` | **146 项 PASS** |
| `coop_probe_runner` | **21/21 PASS** |
| `level_1` 冒烟 | **PASS**，0 ERROR / 0 WARNING |
| `level_regression_all --changed-only` | **128/128 PASS + 5 SKIP**，265.7s |
| `check_all --godot-bin` | **8/8 PASS** |
| `contract_scan --self-test` | **PASS**，含 Phase 17 正负样本 |

## 3. 固化规则

`contract_scan.py` 新增 `phase17_boundary` 类别：

1. `victory.gd`/`defeat.gd` 必须 `extends LevelSettlement`，且不得直接 `MemoryClass.request_save`；
2. `ShopPurchaseCommand`/`RewardGrantCommand` 必须包含 `snapshot_state()` 与 `restore_state(`；
3. 幻化/奖励表现层禁止 `PlayerData.player_data[...] =`、属性赋值与直接 `request_save`；
4. `base_role`/`base_magic_weapon`/`pet_interface`/`zd_skill` 禁止新增 `"/root/"`；
5. 四试点深层字面路径预算：pet 22、zd 0、base_role 8、base_magic_weapon 0。

`contract_gate.py` 同时运行 `contract_scan --self-test`，正负样本见 `scripts/contract_scan.py`。

## 4. 交接给 Phase 18 的缺口

- 1P/2P 归属：`wd_hurt`/`_is_mds_awaken_active` 仍读全局；`Global.get_player` 仍有 16 处 / 10 文件；`RoleProp.source_player` 与召唤未持有者回落；`_apply_role_damage_vs_reduction` 读全局 `damage_bonus`。
- 成长域：神铸/淬骨/合成/任务奖励尚未原子化；`forge._on_froge_pressed_legacy` 仍为死代码；`zd_skill` 仍直接写 `PlayerData.player_data`；2P 打开商店的归属未验证。
- 表现/路径：`pet_interface` 22 条、`base_role` 8 条深层路径；`skill_icon` 仍有 `/root` 回落；`stop_bgm()` 暂无调用方；`transient_ui` 硬编码清单与模块静态帧缓存仍保留。
- 档案/运行时：`background_save_finished` 无消费者；任务保存顺序/信号未收口；地图页首帧保存 IO 未评估；`base_through_level.add_tg` 仍直接写 29 行进度键（GM-26）。
- Atlas：112 个 metadata 未被 Store 触达；惰性 `atlas_metadata` 写入方与未使用常量仍登记在 Phase 14 归档。
- 守卫扩面：当前只覆盖四个试点文件与结算/奖励命令，其他面板、路径与运行时边界尚未纳入同类静态/运行期守卫。

这些缺口已连同 Phase 13~16 遗留拆入 [`current-iteration.md`](../roadmap/current-iteration.md) 的 Phase 18-1 ~ 20-3。
