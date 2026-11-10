# 宠物档案 View 与 Command 契约

> **职责**：定义 `PlayerDataStore` 上宠物只读视图、显式写命令及其失败/回滚语义。关卡宠物生命周期与族规则见 [`architecture.md`](architecture.md) §4.2–4.3；Phase 23 迁移证据见 [`../archive/iteration_23_pet_domain_boundary.md`](../archive/iteration_23_pet_domain_boundary.md)。

## 所有者

- `PlayerDataStore.pet_domain_view()` 创建绑定当前档案的 `PetDomainView`；View 不保存、不补全、不写档。
- `PetDomainCommand` 的操作目标始终是调用者显式传入的 `PlayerDataStore` 和宠物索引，不从全局视图推断操作对象。双人共享状态的失败恢复会通过 1P `PlayerData` 快照共享账本；这只用于完整回滚，不用于选择 P1/P2 目标。
- 档案加载/`ensure_pet_*` 仍归 `PlayerDataStore`；关卡生成/族规则归 `PetLevelController` 与 `Pet*Family`，见架构链接。本页不重复其生命周期或数值规则。

## 只读 View

公开查询：`is_valid()`、`is_empty()`、`pet_count()`、`active_name()`、`active_index()`、`pets()`、`pet_at(index)`、`find_index(name)`、`is_deployed(index)`。

- `pets()`、`pet_at()` 返回深副本；修改结果不改变档案。当前 View 没有 `active_pet()` API。
- `active_index()` 通过宠物 `TYPE`、别名或显示名匹配活跃名；没有匹配返回 `-1`。`find_index()` 匹配同一组名称字段。
- 无效 Store、无效/非数组宠物列表和越界/非字典条目分别表现为空列表、`-1`、空字典或 `false`，不返回可写档案条目。

## 显式命令

| 命令 | 提交与失败语义 |
|:---|:---|
| `deploy(profile, index, active_name)` | 清理其他宠物的出战标记并设置活跃名；`active_name` 由调用方按族规则归一化。资料缺失/空名失败；无状态变化返回 `changed=false`、不保存；保存失败恢复档案快照。 |
| `rest(profile, index)` | 清出战标记；若该宠物当前活跃则清活跃名。无变化不保存；保存失败恢复快照。 |
| `commit_growth(profile, index, apply, reason)` | 对快照中的目标执行回调，再统一保存；无效回调、回调取消/返回失败或保存失败均恢复快照。 |
| `upgrade_formation(profile, stat, requested_count)` | 校验定义/上限/材料，按可负担级数升级并一次保存；材料扣除不完整或保存失败时恢复档案及共享账本。 |
| `upgrade_passive(profile, index, skill)` / `upgrade_all_passives(profile, index)` | 校验宠物等级上限和共享灵魂；单次或批量各保存一次，失败整笔回滚档案与共享灵魂。无可升级时失败且不扣费。 |

保存由 `MemoryClass.request_save_result()` 聚合。命令返回 `{ok, changed, ...}` 或 `{ok:false, message}`；`save_request` Callable 只用于注入保存结果，不是生产保存入口。阵法规则/费用由命令持有，UI 显示其返回值。

## 不在本契约中的写入

宠物技能学习/升级、喂养/资质/强化点、宠物装备与出售尚未全部经过上述命令，也不保证统一的操作级快照回滚；当前面板直写和保存失败风险见 [`ui_panel_contract_matrix.md`](ui_panel_contract_matrix.md)。玩家被动等级与 `pasl_prop` 快照由 [`passive_skill_contract.md`](passive_skill_contract.md) 约束。