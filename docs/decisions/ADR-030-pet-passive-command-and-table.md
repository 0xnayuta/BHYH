# ADR-030：宠物被动成长命令与共享数值表

- **状态**：Accepted
- **记录日期**：2026-11-09
- **影响范围**：宠物被动升级、灵魂扣费、保存失败回滚、玩家/宠物数值表、契约门禁

## 背景

宠物被动升级由 `PetInterface` 直接完成：`PlayerData.spend_soul()` 扣灵魂、`pet["被动技能"][skill] = level + 1` 写字典，然后请求保存；保存失败只返回 `false`，不回滚等级与灵魂。一键升级同样循环扣费、写等级，保存由 `_save_pet_changes()` 另行处理。与此同时，宠物面板与 4 个召唤物直接调用玩家 `PaSkill` Autoload 的 `get_value()`/`get_unlocked_level()`，把一个无状态数值规则绑定到玩家被动单例的生命周期上。宠物被动键与默认字典仍散落裸中文键。

## 决策

1. 新增 `PetDomainCommand.upgrade_passive()` 与 `upgrade_all_passives()`：
   - 校验宠物、技能键、等级上限与灵魂；
   - 用 `profile.snapshot_state()` 捕获 1P/2P 档案与共享灵魂；
   - 扣费、写等级后保存；失败 `restore_state()` 整批恢复；
   - 保存 reason 分别为 `pet_passive_upgrade` 与 `pet_passive_upgrade_all`。
2. `PetInterface` 的 `_upgrade_pet_passive()` 与一键升级改为调用命令；保存成功后才刷新活体宠物，失败只刷新显示并提示命令返回的失败原因。
3. `_pet_passive_levels()` 改为只读；缺失键返回 0，补全由 `PlayerData._normalize_pet_passives()` 负责。
4. 新增 `Script/skill/passive_skill_table.gd`（`class_name PassiveSkillTable`），承载玩家与宠物共用的只读等级→数值表、解锁等级与费用；`PaSkill` 公开函数委托给它，宠物域 4 个召唤物与面板改用静态表。
5. 宠物被动键统一使用 `DataKeys.Skill.PASSIVE_*`（6 项，不含“收益”）；默认宠物字典、`_normalize_pet_passives`、召唤物读取与面板显示同步收敛。
6. `contract_scan.py` 新增 `pet_passive_boundary`：非 `player_data.gd`/`pet_domain_command.gd` 写宠物被动字典报 `PET_PASSIVE_WRITE`；宠物 UI 未调用 `PetDomainCommand` 的被动命令报 `PET_PASSIVE_COMMAND`。

## 后果

- 宠物被动升级保存失败不再产生等级或灵魂变化；1P/2P 快照与共享灵魂同批恢复。
- 玩家与宠物共享同一套数值规则，但宠物域不再依赖 `PaSkill` Autoload。
- UI 只负责校验提示与刷新；写档案、扣费与保存回滚归命令层。
- 新增宠物被动或调整费用/上限时，必须更新 `PassiveSkillTable`、命令与门禁。

## 备选方案

| 方案 | 未采用原因 |
|:---|:---|
| 保留 UI 直写，仅在保存失败时手动回滚等级/灵魂 | 仍有两套写入路径，遗漏任一路径即资损 |
| 宠物复用玩家 `passive_skills_changed` 与 `pasl_prop` | 宠物被动不写玩家属性快照，事件语义会混淆 |
| 复制一份宠物专用数值表 | 玩家/宠物数值规则会分叉，产生第二套真源 |
| 继续直接调用 `PaSkill.get_value()` | 无状态规则被绑定到 Autoload 生命周期，测试与启动顺序脆弱 |

## 证据

- `source/Script/pet/pet_domain_command.gd`
- `source/Script/pet/pet_interface.gd`
- `source/Script/skill/passive_skill_table.gd`、`source/Script/skill/passive_skills.gd`
- `source/Script/memory_class/player_data.gd`
- `scripts/contract_scan.py` `pet_passive_boundary`
- [`../reference/pet_domain_contract.md`](../reference/pet_domain_contract.md)、[`../reference/passive_skill_contract.md`](../reference/passive_skill_contract.md)
