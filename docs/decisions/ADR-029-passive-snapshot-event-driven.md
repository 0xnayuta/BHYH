# ADR-029：被动属性快照改为档案变更事件驱动

- **状态**：Accepted
- **记录日期**：2026-11-09
- **影响范围**：被动技能数值、玩家属性聚合、双人槽位、Autoload 生命周期、契约门禁

## 背景

`PaSkill` 作为 Autoload 在 `_physics_process` 中每帧调用 `get_passive_skill_properties()`，读取 `PlayerData` 的 7 个被动等级并写 `RoleProp.pasl_prop` 的 6 个字段。双人模式还会创建第二个 `PaSkill` 实例（`LocalCoop.secondary_passives`），同样每帧执行。被动等级只有在升级、读档、切档或双人 link 时变化，稳态下每帧写入是纯重复开销；同时 `pasl_prop` 的写入者、刷新时机与档案生命周期没有显式契约。

## 决策

1. 删除 `PaSkill._physics_process` 与 `secondary_passives` 的轮询。
2. `PlayerData` 是被动等级的唯一业务写入者；新增 `signal passive_skills_changed`，在 `apply_passive_skill_upgrades()` 保存成功、`ensure_player_passive_skills()` 实际修正、档案载入完成后发出。
3. `PaSkill` 是 `RoleProp.pasl_prop` 的唯一写入者；`get_passive_skill_properties()` 由 `passive_skills_changed`、启动 `_ready()` 与双人显式刷新触发，并以 7 个等级 + 属性实例 id 做签名短路。
4. `MemoryClass.load_game()` 在档案合并与 `ensure_*` 后调用 `PlayerData.notify_passive_skills_changed()`；`LocalCoop` 连接同一信号只刷新 2P 槽位。
5. 被动技能键收敛到 `DataKeys.Skill.PASSIVE_*`；`PlayerData`、`PaSkill`、`bd_skill`、`back_pack` 不再散落裸中文键。宠物被动域保持独立语义。
6. `contract_scan.py` 新增 `passive_boundary` 类别：`PASSIVE_POLLING`、`PASSIVE_SNAPSHOT_WRITE`、`PASSIVE_DATA_WRITE`，并带正负样本自测。

## 后果

- 稳态不再每帧读取档案与写属性快照；刷新只发生在真实变更与生命周期边界。
- `pasl_prop` 的写入者与 `PlayerData` 的被动等级写入者均有明确所有者与门禁。
- 读档、升级、双人 link 与属性实例重建都有显式刷新路径；签名短路保证重复事件幂等。
- 新增被动技能或刷新入口时，必须同时更新 `passive_skill_contract.md`、门禁与验证矩阵。

## 备选方案

| 方案 | 未采用原因 |
|:---|:---|
| 保留每帧轮询，仅增加签名短路 | 仍保留常驻轮询与隐式刷新，未解决所有权问题 |
| 在 `BaseRoleProperties.get_last_prop()` 内按需调用 `PaSkill` | 属性聚合器反向依赖数值域，破坏依赖方向 |
| 仅在 UI 升级按钮后刷新 | 读档、切档、双人 link 等路径会漏刷新 |

## 证据

- `source/Script/skill/passive_skills.gd`
- `source/Script/memory_class/player_data.gd`、`source/Script/memory_class/memory_class.gd`
- `source/Script/coop/local_coop.gd`
- `source/Script/base/data_keys.gd`
- `scripts/contract_scan.py` `passive_boundary`
- [`../reference/passive_skill_contract.md`](../reference/passive_skill_contract.md)
