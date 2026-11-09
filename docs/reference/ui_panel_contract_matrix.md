# UI 面板操作者、命令与保存边界矩阵

> **状态**：Phase 24-0 静态盘点、Phase 24-1 `PetAttributePages` 拆分与 Phase 24-2 `CoopPanelHost` 宿主分离已完成（2026-11-03）。本页记录当前代码事实与后续拆分判断。
> **范围**：`LocalCoop` 面板宿主、5 个协作面板入口、`pet_interface` 子区域、LDL 成长面板，以及关卡/怪物信息面板。
> **事实源**：`source/Script/coop/local_coop.gd`、`source/Script/pet/pet_interface.gd`、`source/Script/back_pack/*.gd`、`source/Script/skill/*.gd`、`source/Script/ldl/*.gd`、`source/Script/main_menu/mount_panel.gd`、`source/Script/level/level_info.gd`、`source/Scene/other_scene/monster_head_info.gd`、`scripts/contract_scan.py`。
> **非目标**：不改 Theme、布局、显示基线、存档格式、宠物数值或输入映射；不把本页当作实现完成证明。

---

## 1. 当前边界与判定口径

### 1.1 操作者

- 协作面板的正式操作者由 `LocalCoop.data_for(node)` / `props_for(node)` 解析；节点先按 `coop_slot`、祖先链、持有者回溯，再回退到 `ui_slot`。
- 面板脚本必须声明 `PlayerData: PlayerDataStore` / `RoleProp: BaseRoleProperties`，或从声明过的父脚本继承；`panel_operator` 门禁只检查这一层。
- 关卡/怪物信息面板（`level_info`、`monster_head_info`）仍直接使用全局 `PlayerData`/`RoleProp`；它们是只读信息层，不是协作面板，但 2P 下仍可能读到当前视图。

### 1.2 保存与快照

- 业务保存统一经 `MemoryClass.request_save*`；面板可调用 `Global.request_save_with_feedback` 获得失败提示。
- 面板打开期间 `LocalCoop.open_panel` 检查 `MemoryClass.is_save_snapshot_in_progress()`；快照生成时拒绝打开/切换。
- 面板关闭由宿主统一保存 `coop_panel_close`；关闭按钮只负责 `queue_free`，不直接写盘。
- UI 直接调用 `MemoryClass.save_game` / `safe_write_archive` / `load_game` 被 `hud_panel_boundary` 禁止；`_data()`/`data_for(_slot)(...).player_data` 的赋值、嵌套修改与别名写入同样受守卫约束，已登记的旧路径见 §4.3。

### 1.3 生命周期与临时 UI

- `CoopPanelHost.open_panel` 创建 `CanvasLayer`，写入 `coop_slot` meta，调用 `UiRuntime.push_windows(layer)`，实例化面板并用 `register_ui_runtime_instance` 登记缓存租约。
- `CoopPanelHost._on_panel_closed` 释放图层、`pop_windows()`、恢复暂停、重置 `ui_slot`、刷新账本/被动，并保存 `coop_panel_close`。
- ESC 由 `backpack.gd` 协调：若 `LocalCoop.has_panel()`，先关闭整个协作面板，再处理 HUD 窗口；面板内部弹窗不参与 ESC 分层。
- 工厂创建的提示/确认/地图覆盖等临时 UI 由 `UiRuntime.register_transient_ui` 登记；面板内直接 `add_child` 的局部浮层由面板自身释放。

---

## 2. `CoopPanelHost` 面板宿主

| 职责 | 当前入口/字段 | 说明 |
|:---|:---|:---|
| 面板类型表 | `CoopPanelHost.PANEL_PATHS` | `背包`、`技能`、`宠物`、`法宝`、`坐骑` 五个场景 |
| 打开 | `CoopPanelHost.open_panel(slot, type)` | 检查现有面板/切换中/是否启用/路径/快照；创建图层、阴影、选择器并暂停树 |
| 切换 | `_switch_panel` → `_replace_panel` | 保留类型，释放旧面板后按新槽位重建 |
| 关闭 | `CoopPanelHost.close_panel()` / `_on_panel_closed` | 关闭按钮仅 `queue_free`；宿主统一清理并保存 |
| 操作者 | `slot_for` / `data_for` / `props_for` / `data_for_slot` | 槽位查询；面板根和弹出层携带 `coop_slot` |
| 双人选择器 | `CoopPanelHost._add_player_selector` | 按面板类型放置 1P/2P 切换按钮，调用 `switch_panel` |
| 快照互斥 | `CoopPanelHost.open_panel` 中的 `is_save_snapshot_in_progress()` | 仅阻止打开；关闭保存仍由宿主发起 |
| 保存副作用 | `CoopPanelHost._on_panel_closed` 的 `coop_panel_close` | 面板内未即时保存的操作会在关闭时统一提交 |

**拆分结果**：24-2 已把面板宿主生命周期迁入普通节点 `CoopPanelHost`；`LocalCoop` 保留槽位、共享账本、输入会话与 `slot_for`/`data_for`/`props_for`，生产调用方改走 `LocalCoop.panel_host`。

---

## 3. 协作面板清单

### 3.1 五个 `LocalCoop` 入口

| 面板 | 场景 | 操作者/视图 | 关闭 | 保存副作用 | 直接写入与风险 |
|:---|:---|:---|:---|:---|:---|
| 背包 | `Scene/back_pack/back_pack.tscn`，双人时 `coop_backpack.gd` 覆盖脚本 | `back_pack.gd` 显式 getter；`coop_backpack` 继承 | `_on_close_pressed` → `queue_free` | `back_pack_wings_show`、`back_pack_head_show`、`back_pack_sort`、`back_pack_*` 子面板；宿主 `coop_panel_close` | `coop_backpack._on_name_text_changed` 直接写 `LocalCoop.data_for_slot(slot).player_data["角色昵称"]`，无即时保存；`back_pack` 显示开关直接写字段但有保存失败回滚 |
| 技能 | `Scene/skill/learn_skill.tscn` | `learn_skill.gd` 显式 getter；子面板 `zd_skill`/`bd_skill` | `_on_close_pressed` → `queue_free`；`request_escape_close` 先关伤害公式浮层 | `skill_refresh`、`skill_passive_upgrade_all` 等；宿主 `coop_panel_close` | `zd_skill` 升级使用 `PlayerData.snapshot_state`/`restore_state`；`skill_key_set` 经 `PlayerData.set_skill_key`；`bd_skill` 经 `apply_passive_skill_upgrades` |
| 宠物 | `Scene/pet/pet_interface.tscn`；`backpack.gd` 也可独立打开 | `pet_interface.gd` 显式 getter；子区域见 §3.2 | `btn_close` → `queue_free`；子弹窗各有 close 按钮 | `pet_deploy`、`pet_rest`、`pet_growth`、`pet_formation`、`pet_passive_upgrade`、`pet_changes`；LocalCoop 入口另有 `coop_panel_close` | 见 §3.2；阵法已命令化；其余 `_data()` 间接写入与未回滚保存仍按 §3.2 登记 |
| 法宝 | `Scene/back_pack/magic_weapon_infor.tscn` | `magic_weapon_infor.gd` 显式 getter | `_on_close_pressed` → `queue_free` | `magic_weapon_enhance`（普通 `request_save`）；宿主 `coop_panel_close` | 直接写 `PlayerData.player_data[DataKeys.MAGIC_WEAPON]` 的强化等级/五行/成长率；保存失败不回滚 |
| 坐骑 | `Scene/main_menu/mount_panel.tscn`；`map_0.gd` 也可打开 | `mount_panel.gd` 显式 getter | `close.pressed` → `queue_free` | 面板内无 `request_save`；LocalCoop 入口依赖 `coop_panel_close`，主菜单入口依赖页面生命周期 | 通过 `PlayerData.set_active_mount`/`unlock_mount`/`upgrade_mount_*` 改档；`_train_mount` 先 `set_soul`、`add_mount_exp`，无即时保存/快照 |

### 3.2 `pet_interface` 子区域

| 区域 | 关键入口 | 数据/操作者 | 保存与回滚 | 直接写入结论 |
|:---|:---|:---|:---|:---|
| 宠物列表/状态 | `_refresh_pet_name_list`、`fight_click`、`rest_click` | `PetDomainView` + `PetDomainCommand`；`PlayerData` getter | `pet_deploy`/`pet_rest` 快照回滚 | 列表读取已走 View；出战/休息已命令化，可作为边界基线 |
| 属性页 | `pet_attribute_pages.gd`（既有 `PetAttributePages` 节点）；父面板注入显示值 `Callable` | 子控制器不读取 `PlayerData`/`RoleProp`；父面板持有操作者 | 无保存 | **24-1 已拆分**；子控制器只做分页/行绑定/文本显示，无直接写档 |
| 培养/食用/资质 | `PetDevelopInterface`、`_on_eat_item_pressed`、`_on_quality_fruit_pressed`、`_on_buy_strength_pressed` | 当前宠物字典、共享宠物背包 | 资质/食用/购买强化点无即时保存，依赖关闭时 `coop_panel_close` | 直接修改宠物字典和共享背包；关闭保存失败没有按操作回滚 |
| 被动技能 | `_upgrade_pet_passive`、`_on_pet_passive_one_key_upgrade_pressed` | 当前宠物字典 + `PlayerData` 灵魂 | `pet_passive_upgrade`，无快照 | 先扣灵魂、改等级，保存失败只返回 `false`，未恢复；后续命令化候选 |
| 技能学习/升级 | `_learn_pet_skill`、`_upgrade_pet_skill` | 当前宠物字典 + 技能书/灵魂 | `pet_changes`，无快照 | 先扣书/灵魂、改技能，保存失败不回滚 |
| 阵法 | `PetFormationPopup`、`_upgrade_pet_formation_once` | `PetDomainCommand.upgrade_formation` + `PlayerData` 显式 getter | `pet_formation`；快照 → 扣材料与升级 → 保存失败恢复 | **24-3 已命令化**；UI 只读等级/材料并显示结果，阵法路径不再写 `_data()` |
| 宠物背包/装备/批量出售 | `_equip_pet_pack_item`、`_unequip_pet_item`、`_sell_pet_equipment_at`、批量出售 | 共享宠物背包 + 当前宠物装备 | `pet_changes`，无快照 | 直接增删共享数组/装备、加灵魂；保存失败不回滚 |
| 关闭 | `btn_close`、子弹窗 close | 面板根协调 | 宿主 `coop_panel_close` | 关闭保存不能替代操作级回滚 |

### 3.3 LDL 成长面板

| 面板 | 操作者 | 保存 reason | 回滚/风险 |
|:---|:---|:---|:---|
| `Ldl` 根 | `ldl.gd` 显式 getter | `ldl_strength_panel`、`ldl_synthesis_panel`、`ldl_mosaic_panel`、`ldl_decompose_panel`、`ldl_forge_panel`、`ldl_divine_panel` | 面板切换时保存；`MemoryClass.request_save` 结果未统一反馈 |
| `Strength` | 显式 getter | `ldl_strength`、`ldl_strength_remove` | `snapshot_state`/`restore_state`；保存失败恢复 |
| `DivineForge` | 继承 `Strength` | `ldl_divine_forge` | 快照回滚 |
| `BoneForge` | 继承 `DivineForge` | `ldl_bone_forge` | 快照回滚；失败仍消耗神火是已登记设计 |
| `Synthesis` | 显式 getter | `ldl_synthesis`、`ldl_synthesis_remove` | 快照回滚；配方校验 |
| `Forge` | 显式 getter | `forge`、`ldl_forge_remove` | 手动 `player_data.duplicate(true)` 快照/恢复 |
| `Decompose` | 显式 getter | 无独立保存调用 | 直接清空 `分解列表`、加装备/道具；动作级保存与回滚缺失，依赖面板切换/关闭 |
| `Mosaic` | 显式 getter | 无独立保存调用 | `restore_mosaic_equipment` + 直接清空 `镶嵌列表`；动作级保存不完整 |
| `OneKeySynthesis` | 显式 getter | `ldl_one_key_synthesis` | 先扣材料再加丹药；无快照回滚 |

### 3.4 只读信息面板

| 面板/数据 | 入口 | 操作者 | 保存 | 结论 |
|:---|:---|:---|:---|:---|
| `LevelInfo` | `LevelEntryRuntime.add_level_info`，`Scene/other_scene/level_info.tscn` | 直接全局 `PlayerData` | 无 | 只读关卡信息；不进入协作面板槽位体系 |
| `MonsterHeadInfo` + `MonsterAttrData` | HUD/怪物头像 | 直接全局 `PlayerData`/`RoleProp`；`MonsterAttrData` 是 `RefCounted` 数据表 | 无 | 只读属性悬浮层；不保存、不创建面板宿主 |

---

## 4. 直接写档与守卫缺口

### 4.1 已具备命令/回滚的路径

- 宠物出战、休息、成长果：`PetDomainCommand` 快照 + `pet_deploy`/`pet_rest`/`pet_growth`。
- 宠物阵法：`PetDomainCommand.upgrade_formation` 快照 + `pet_formation`；按可负担级数一次扣材料、升级与保存，失败恢复共享档案。
- LDL 强化、神铸、淬骨、合成、打造：`snapshot_state`/`restore_state` 或等价快照。
- 主动技能升级、被动技能批量升级、技能按键：`PlayerData` 命令 + 保存结果。
- 背包显示开关：写入后保存失败恢复原值。

### 4.2 需要后续命令化的路径

1. **宠物被动/技能学习/技能升级**：先扣灵魂或技能书，保存失败不回滚。
2. **宠物装备与批量出售**：直接改共享宠物背包、宠物装备与灵魂，保存失败不回滚。
3. **法宝强化/五行/成长率**：直接改 `PlayerData.player_data`，`request_save("magic_weapon_enhance")` 返回值未用于回滚。
4. **LDL 分解/镶嵌/一键合成**：动作级保存与回滚不完整，当前主要依赖面板切换或关闭保存。
5. **背包昵称**：`coop_backpack` 直接写 `player_data["角色昵称"]`，无即时保存；P1/P2 各自槽位虽正确，但失败不可观察。
6. **坐骑培养/解锁**：面板内无 `request_save`，依赖宿主关闭保存；失败无法按操作恢复。

### 4.3 现有守卫覆盖

- `panel_operator`：覆盖 `Script/back_pack/`、`Script/skill/`、`Script/pet/`、`Script/mount/`、`Script/ldl/`；只检查未声明操作者的 `PlayerData`/`RoleProp` 使用。`Script/main_menu/mount_panel.gd` 不在该目录集合内，虽然自身声明了操作者，但不由该门禁覆盖。
- `hud_panel_boundary`：扫描 `Script/back_pack/`、`Script/skill/`、`Script/ldl/` 与显式 HUD 文件；拦截档案 IO、`PlayerData.player_data` / `_data()` / `data_for(_slot)(...).player_data` 的赋值、嵌套访问修改、`.clear()/.erase()/.push_back()/.append()/.merge()/.remove_at()`，并识别以上根对象的局部别名。`contract_scan.py --self-test` 覆盖 14 个坏样本与 13 个好样本。
- **24-4 登记例外**（迁移前基线；新增文件/新增行不得直接复制）：
  - 整文件旧直写：`back_pack.gd`、`box_1.gd`、`dj_sell.gd`、`magic_weapon_infor.gd`、`main_backpack.gd`、`pl_sell.gd`、`sell_or_equ.gd`、`skill_select.gd`、`wq.gd`、`decompose.gd`、`mosaic.gd`；
  - 逐行旧直写：`pet_interface.gd` 的 7 条宠物列表/活跃槽位别名写回；`synthesis.gd` 的 3 条“放入列表”清空；`coop_backpack.gd` 的 2 条昵称写回；
  - 上述文件仍禁止 `MemoryClass.save_game` / `safe_write_archive` / `load_game`，档案 IO 不享受文件例外。
- 原先登记为“主要靠人工审计”的路径现分两类：`magic_weapon_infor`、`back_pack`、`main_backpack`、`decompose`、`mosaic` 已列入文件例外；`mount_panel`、`one_key_synthesis` 在扩展扫描下无直写，纳入自动守卫。后续命令化时逐项删除例外，不扩大豁免。

---

## 5. 批次记录

Phase 24 的 24-1 `PetAttributePages` 拆分、24-2 `CoopPanelHost` 宿主分离、24-3 阵法升级命令与 24-4 阶段验收见 [`../archive/iteration_24_ui_growth_boundaries.md`](../archive/iteration_24_ui_growth_boundaries.md)；本页只保留当前操作者、保存与写档边界。
