# BHYH 当前候选迭代

> **状态**：**Phase 22、Phase 23 已完成并归档**（2026-11-03）；**Phase 24 已完成**（24-0 面板契约盘点、24-1 `PetAttributePages` 拆分、24-2 `CoopPanelHost` 宿主分离、24-3 阵法升级命令、24-4 阶段验收）；**Phase 25-0 行为与验证映射、Phase 25-1 自动战斗控制器、Phase 25-2 法宝展示实例、Phase 25-3 Boss 保护状态、Phase 25-4 受击与来源归属加固与 Phase 25-5 阶段验收已完成，Phase 25 已关闭**；**Phase 27-0 Theme/字体盘点与表面色守卫、Phase 27-1 Token 单一来源与生成/校验已完成（2026-11-05）**；Phase 27-2~27-7 已规划、未启动。**Phase 26 平台与发布验证长期暂缓**，不阻塞 Phase 27。
> **版本**：6.9；不改变玩法数值、动画时序、输入映射或存档格式；Phase 27 的字体/色值变化必须逐批截图与控件几何验收，不静默改变显示基线。
> **当前基线**：[`global_runtime_inventory.md`](../reference/global_runtime_inventory.md)（Phase 22-1）、[`architecture.md`](../reference/architecture.md)、[`status.md`](../reference/status.md)、[`acceptance.md`](../reference/acceptance.md)。
> **编号说明**：Phase 22~27 为本轮新增候选，承接 Phase 21；已归档的 Phase 30~33 不重开，也不把历史归档改写成新计划。

---

## 1. 已完成阶段（归档）

- **Phase 22 Global 状态与入口契约**：已完成并归档；详细批次、字段迁移与验证记录见 [`iteration_22_global_state_boundary.md`](../archive/iteration_22_global_state_boundary.md)。
- **Phase 23 关卡、宠物与档案数据边界**：已完成并关闭；八族生成只经 `PetLevelController`，`PlayerData` 宠物域只读 View/命令已建立；详细批次见 [`iteration_23_pet_domain_boundary.md`](../archive/iteration_23_pet_domain_boundary.md)，当前调用面见 [`pet_level_boundary_matrix.md`](../reference/pet_level_boundary_matrix.md) 与 [`pet_domain_contract.md`](../reference/pet_domain_contract.md)。

---

## 2. Phase 24：UI 与成长命令边界

**目标**：让面板成为“显式操作者 + 数据视图 + 命令”的界面层，成长操作统一为可回滚命令；不重做整套 UI。
**前置**：Phase 23 的宠物生成与宠物域视图至少完成首批；否则先处理 Phase 23。
**非目标**：不换 Theme、不改布局/显示基线、不启用全局 Theme、不一次性重写全部面板。

### 24-0 面板契约清单（已完成）

- 产出 [`ui_panel_contract_matrix.md`](../reference/ui_panel_contract_matrix.md)：`LocalCoop` 五个入口、`pet_interface` 子区域、LDL 成长面板与只读信息面板；
- 盘点结果：面板显式操作者由 `LocalCoop.data_for/props_for` 解析；`hud_panel_boundary` 已在 24-4 扩展为面板目录扫描并识别 `_data()`/嵌套修改/槽位档案别名写档；旧路径按 [`ui_panel_contract_matrix.md`](../reference/ui_panel_contract_matrix.md) §4.3 登记；
- 已具备回滚的路径：宠物出战/休息/成长果、LDL 强化/神铸/淬骨/合成/打造、主动技能升级；
- 待命令化：宠物被动/技能/装备/批量出售、法宝强化、LDL 分解/镶嵌/一键合成、背包昵称与坐骑培养；宠物阵法已在 24-3 完成；
- **24-1 首个拆分对象**：`PetAttributePages`（只读属性区域，无保存副作用）；
- **24-3 首个成长命令**：宠物阵法升级（已于 24-3 命令化；此前为 `_data()["宠物阵法等级"]` 直写、材料先扣、保存失败不回滚）；
- 本批次只改文档，未修改 `source/`。

### 24-1 `pet_interface` 分段拆分（已完成）

- 新增 `pet_attribute_pages.gd` 并挂到既有 `PetAttributePages` 节点：子控制器持有 2 页定义、10 行绑定、分页按钮与显示文本；
- 父面板只注入分页按钮和显示值 `Callable`，保留当前宠物、装备加成、数值计算与页面协调；子控制器不读取 `PlayerData`、不保存、不写档；
- 删除父面板的 `pet_attribute_page`、行/标签/按钮数组及旧分页回调，保留 `_refresh_pet_attribute_page` 作为委托入口；
- 未改布局、Theme、数值规则或存档格式；`PetAttributePages` 节点仍使用原场景行与按钮；
- 验证：`check_all --godot-bin` **9/9**（32.39s）、`health_check` **775 脚本 0/0/0**、`archive` **332/332**（11.02s，含控制器、真实按钮切页与显示值）、`scene` **17/17**（166.43s）、`coop` **33/33**（196.98s，含 2P 宠物面板操作者与切页）、全量 **128/128 + SKIP 5**（311.1s，无重试）。

### 24-2 `CoopPanelHost` 宿主分离（已完成）

- 新增普通节点 `CoopPanelHost`，由 `LocalCoop` 持有；`PANEL_PATHS`、面板实例/图层、窗口栈、暂停、1P/2P 选择器、场景按钮、关闭保存与本地清理迁入宿主；
- `LocalCoop` 只保留槽位、共享账本、输入会话、`slot_for`/`data_for`/`props_for` 与 `ui_slot` 状态；`backpack.gd`、`map_0.gd` 与探针全部改走 `LocalCoop.panel_host`；
- 关闭仍经 `coop_panel_close` 保存；`on_scene_changed`/`clear` 释放面板、图层、会话按钮与悬停弹层，并恢复暂停/窗口栈；全局临时 UI 仍由 `UiRuntime`/`SceneFlow` 持有；
- 新增 `shared_ledger` 门禁的宿主文件约束：`coop_panel_host.gd` 必须保留 `open_panel` 快照互斥，`local_coop.gd` 只校验共享账本；
- 验证：`check_all --godot-bin` **9/9**（34.77s）、`health_check` **776 脚本 0/0/0**、`archive` **332/332**（11.06s）、`scene` **17/17**（157.58s）、`coop` **33/33**（182.96s，含宿主节点/无旧入口、P2 面板操作者、1P/2P 选择器、切页、快照互斥与 `clear` 清理）、全量 **128/128 + SKIP 5**（308.8s，无重试）。

### 24-3 成长命令试点（已完成）

- `PetDomainCommand.upgrade_formation(profile, stat_name, requested_count, save_request)` 校验等级与材料，按可负担级数计算总消耗；
- 一次快照后扣材料、写入 `宠物阵法等级`，调用 `MemoryClass.request_save_result("pet_formation", false)`；保存失败恢复完整档案；
- 双人会话以 1P 档案快照覆盖 1P/2P 与共享道具、灵魂，2P 操作失败同样恢复共享容器；
- `PetFormationPopup` 只读规则与材料计数并显示命令结果，阵法路径不再写 `_data()`；升十级改为一次命令提交；
- 验证：`archive` **344/344**（10.54s，含 1P/2P 成功、失败整批回滚、材料/灵魂恢复与单次保存）、`check_all` **9/9**（28.51s）、`health_check` **776 脚本 0/0/0**、`scene` **17/17**（167.51s）、`coop` **33/33**（191.91s）、`level_1` **4 阶段 PASS**（24.95s，0/0/0）、全量 **128/128 + SKIP 5**（311.4s，无重试）。

### 24-4 阶段验收（已完成）

- 确认 24-1 子区域拆分与 24-3 成长命令已接入；面板关闭/暂停/窗口栈与快照互斥沿用 24-2 结果；
- `hud_panel_boundary` 扩展到 `Script/back_pack/`、`Script/skill/`、`Script/ldl/` 与显式 HUD 文件，识别 `PlayerData.player_data`、`_data()`、`data_for(_slot)(...).player_data` 的赋值、嵌套访问修改、列表/字典变更和局部别名；
- 旧路径按 [`ui_panel_contract_matrix.md`](../reference/ui_panel_contract_matrix.md) §4.3 登记：11 个文件整文件例外 + `pet_interface` 7 行、`synthesis` 3 行、`coop_backpack` 2 行逐行例外；档案 IO 不豁免；
- 验证：`contract_scan --self-test` HUD **14 坏 / 13 好 PASS**，`check_all` **9/9**（33.99s），`archive` **344/344**（10.47s），`scene` **17/17**（170.36s），`coop` **33/33**（199.88s），`level_1` **4 阶段 PASS**（24.95s，0/0/0），全量 **128/128 + SKIP 5**（305.8s，无重试）；
- Phase 24 出口：至少一个面板子区域与一个成长域完成命令化；未登记的新增直接/间接写档由门禁拦截；已登记旧路径有明确文件/行与迁移说明。

---

## 3. Phase 25：战斗实体行为切片

**目标**：在不改变战斗数值与时序的前提下，把 `BaseHero`/`BaseMonster` 中可独立生命周期的行为移出。
**前置**：Phase 22 的伤害/状态所有权稳定；建议在 Phase 24 之后再启动，避免 UI 与实体同时迁移。
**非目标**：不引入 ECS、不重排继承、不一次性拆完 `BaseHero`/`BaseMonster`、不改碰撞层与动作时序。

### 25-0 行为与验证映射（已完成）

- 产出 [`combat_behavior_matrix.md`](../reference/combat_behavior_matrix.md)：`BaseHero` 自动战斗的状态/输入/生命周期/失败路径、`BaseMonster` 受击反应/控制免疫/Boss 保护/死亡映射、现有探针覆盖与缺口；
- 首批选择 **自动战斗**：6 个 `_auto_battle_*` 字段、20 个 `_auto_battle*` 方法，目标/技能/移动可由显式上下文迁出；受击反应有 37 个 `state_hurt` 文件（含基类与覆写）和 3 个 `play_hit_effect` 文件，已由 25-4 加固；
- 记录必须保持的现状：1P/2P 共用运行时开关、按 `coop_slot` 读技能配置、自动重试归 `BaseThroughLevel`/胜利/失败/玲珑塔、手动 `is_t_mc` 与法宝输入仍可能绕过自动分支；
- 现有 `coop`/`scene`/全量回归没有直接驱动自动战斗或受击代次的探针；25-1 已补 `LocalCoopAutoBattleProbe`，25-4 已补 `LocalCoopHitReactionProbe`；
- 本批次未修改 `source/`，未改变数值/时序/输入映射。

### 25-1 自动战斗控制器（已完成）

- 新增 `Script/base/auto_battle_context.gd`：显式开关/配置/目标/技能/冷却/MP/动作/移动查询与受控命令，不持有节拍或游标；
- 新增 `Script/base/auto_battle_controller.gd`：接管目标缓存/筛选、技能游标/计数、0.22s 节拍、移动/朝向/障碍跳跃，以及自动法宝→剑阵→无双调用顺序；
- `BaseHero` 删除 6 个自动战斗字段与 20 个旧方法，保留实体根、`get_skill`/`use_fb`/`ws_skill`、`is_auto_battle_target_valid` 与 `is_auto_battle_skill_active` 钩子；角色 3/4/哪吒覆写改为公开钩子，玉兔索敌改走公开目标校验；
- `LocalCoopAutoBattleProbe` 覆盖 P1/P2 槽位配置、目标缓存/移动、真实 `slz` 起手与计数、无双短路、关闭清理、暂停、死亡、场景退出；
- 未改数值/动作时序/输入映射/碰撞层；障碍跳跃、自动重试转场与手动输入冲突仍留待后续验证。

### 25-2 法宝展示实例（已完成）

- 新增 `Script/base/magic_weapon_presentation_controller.gd`：按槽位档案持有当前 `BaseMagicWeapon` 展示实例与 active name，负责装备切换/默认回退/移除/英雄退出清理；
- `BaseHero` 删除 `mg_target`、`_active_magic_weapon_name`、`add_magic_weapon`、`null_szfb_case`、`on_szfb_change`、`check_remove_or_add_fb`，保留 `get_magic_weapon_target`/`get_active_magic_weapon_name` 只读入口与 `use_fb` 命令；
- `BaseMagicWeapon` 的 `is_use`/`is_canuse`/`fb_cd`/`usecd`/`skill_cd` 与 `Global`/`MagicWeaponRuntime` 的槽位召唤归属不变；`user_key` 冷却读取改走公开入口；
- 新增 `LocalCoopMagicPresentationProbe` 覆盖 P1/P2 实例隔离、槽位元数据、切换、默认回退、移除、`use_fb` 冷却与英雄退出清理；
- 未改法宝数值、冷却时长、伤害、场景路径或共享档案写入。

### 25-3 Boss 保护状态（已完成）

- 新增 `Script/base/boss_protection_controller.gd`：持有 Boss 保护累计值、激活态、保护/白条计时与最近受击时间；`_process_boss_protect` 与 `_add_boss_protect_from_hit` 改为委托；
- 激活时由 `BaseMonster` 接收事件并保持旧顺序：清白条控制 buff、刷新控制免疫、重置技能冷却、停水平速度、清 `is_be_attacking`、设置半透明；
- `boss_blood` 改为通过 `get_boss_current_protect`/`get_white_bar_armor_time_left` 读取；`east_continent_monster` 的保护覆盖改用 `is_boss_protecting()`；
- 掉落结算仍由 `BaseMonster.settle_death_drops` 的 `death_drops_settled` 单一提交与塔层回调负责，不迁入保护控制器；
- 新增 `LocalCoopBossProtectionProbe` 覆盖保护激活、白条超时、控制免疫、技能重置、掉落唯一结算与重复调用；
- 未改 Boss 阶段推进、伤害数值、保护阈值/时长、掉落规则或重战流程。

### 25-4 受击与来源归属加固（已完成）

- 新增 `Script/base/hit_reaction_controller.gd`：集中受击反应 `active`、`generation` 与显式来源快照；`BaseMonster._begin/_finish/_cancel_hurt_reaction` 委托控制器，各族直接读取状态的代码改用 `is_hurt_reaction_active()` / `get_hurt_reaction_generation()`；
- `apply_role_hit` 在进入受击反应时创建 `Snapshot`（实际来源目标、`BaseHero`、`hit_dic`），延迟回调可经 `get_hit_reaction_source_player()` 读取，不依赖已恢复的 `get_target`/`get_player`/`get_hit_data`；
- `play_hit_effect` 与 `tao_wu_boss` 延迟播放捕获当前代次，`_deferred_play_hurt_animation(expected_generation)` 拒绝过期代次，避免旧延迟动画覆盖新受击；
- `BaseMonster._exit_tree`/`BaseHero._exit_tree` 调用 `reset_hit_reaction_state()`，清活动反应、代次、`is_be_attacking`、待处理僵直与控制移动锁；不重置保护/白条；
- 新增 `LocalCoopHitReactionProbe` 覆盖零击退、连续受击代次、Boss/白条控免、`play_hit_effect` 竞争、P2 来源快照、无来源零伤害、英雄/怪物退出重置；召唤物、弹体、法宝与 1P/2P 来源沿用 `LocalCoopAttributionSourcesProbe`；
- 未改伤害数值、Boss 保护阈值/白条时长、动作时序、碰撞层或双人来源归属；特殊 `state_hurt` 分支（Monster114、无超级调用族、特殊 Boss 阶段）保留并由全量回归覆盖。

### 25-5 阶段验收（已完成，Phase 25 关闭）

**结论**：Phase 25 的四个行为切片相互独立，战斗结果与 Phase 24-4 基线一致；阶段出口满足，Phase 25 关闭。

| 切片 | 独立边界 | 定向探针 |
|:---|:---|:---|
| 25-1 自动战斗 | `AutoBattleContext` + `AutoBattleController` 由 `BaseHero` 持有；不调用法宝/保护/受击控制器 | `LocalCoopAutoBattleProbe` |
| 25-2 法宝展示 | `MagicWeaponPresentationController` 由 `BaseHero` 持有；不拥有冷却、伤害或槽位召唤归属 | `LocalCoopMagicPresentationProbe` |
| 25-3 Boss 保护 | `BossProtectionController` 由 `BaseMonster` 持有；激活副作用与掉落结算仍由怪物基类提交 | `LocalCoopBossProtectionProbe` |
| 25-4 受击状态 | `HitReactionController` 由 `BaseMonster` 持有；特殊 `state_hurt` 分支保留自身动画 | `LocalCoopHitReactionProbe` |

**独立性证据**：四个控制器均为独立 `RefCounted` 脚本；生产引用只出现在各自拥有者 `BaseHero`/`BaseMonster` 与探针；控制器之间无互相调用。`LocalCoopAttributionSourcesProbe` 继续覆盖召唤物、弹体、法宝和 1P/2P 来源。

**基线一致性**：全量关卡保持 **128/128 PASS + 5 SKIP**（与 Phase 24-4 的 128/128 + 5 一致）；`level_1` 4 阶段通过且日志 0/0/0；`LocalCoopDamageStatsProbe` 与 `LocalCoopAttributionSourcesProbe` 通过；25-1~25-4 未改伤害数值、保护阈值/白条时长、动作时序、输入映射、碰撞层或存档格式。`coop` 由 33 项基线扩展为 37 项，原有用例全部保留并通过。

**验证**：`check_all --godot-bin` 9/9（32.75s）；`health_check` 781 脚本 0/0/0；`archive` 344/344（10.54s）；`scene` 17/17（153.38s）；`coop` 37/37（202.31s）；`level_1` 4 阶段（24.31s，0/0/0）；全量 128/128 + 5 SKIP（301.0s，无重试）；`docs_audit` 749 链接 0 缺失。

**命名终审**：`naming_compliance_audit.py --fail-on-error` 已通过；第三方 DragonBones 前缀登记与私有 `Data → data` 收敛完成，目录、文件、代码标识符均为 100%。该结果可作为 L3/release 命名终审证据，但不冒充目标设备性能与正式发布包裁剪验证。

---

## 4. Phase 26：平台与发布验证（长期暂缓）

**状态**：长期暂缓；未启动，不阻塞 Phase 27。
**目标**：把“路径闭包”“release 启动”“目标设备性能”“Spine 平台支持”分别证明。
**前置**：可与 Phase 23~25 并行做只读规划；涉及资源/导出变化时再与当前代码批次协调。
**非目标**：不把未验证平台写成支持，不用 PCK 可达替代 release，不用 headless 替代 HUD/VRAM。

### 26-0 平台支持矩阵

- 明确当前承诺平台、未验证平台与退出条件；
- 记录设备、OS、渲染后端、Spine 库、导出模板与许可证；
- Windows x86_64 先行；其它平台保持“延期/未验证”。

### 26-1 Windows release 启动与最小包

- 构建 release，验证冷启动、主菜单、存档列表、`level_1` 进入与退出；
- 区分离线验证包与最小发布包；记录实际包路径闭包与缺失资源；
- 失败必须显式，不以“全资源包可运行”替代发布结论。

### 26-2 目标设备性能

- 在目标设备记录首帧、战斗峰值 VRAM、加载时长、重复进出与退出；
- 至少覆盖一场战斗、一个 Boss、一次返回/重战；
- 结论写入 `status.md`，带设备、日期与未验证范围。

### 26-3 Spine 平台决策

- 复核 Windows 之外是否需要 Spine 扩展；没有设备/许可证/导出证据时保持延期；
- 不把 `.gdextension` 声明文件当作运行库已入库。

### 26-4 阶段验收

- 平台矩阵、release 启动记录、设备性能证据与发布包结论；
- 出口：支持平台有证据，未支持平台有明确原因；不新增未经证实的兼容承诺。

---

## 5. Phase 27：Theme 与字体契约收敛

**状态**：**27-0、27-1 已完成（2026-11-05）**；27-2~27-7 规划、未启动。
**目标**：把 618 个冻结变体从“逐控件复制字体/字号/颜色/StyleBox”收敛为“单一 token 源 + 语义基类 + 少数字体角色”；消除 Theme 与脚本双写、off-token 字号/颜色、未引用字体和静态动态覆盖，同时保持可验收的显示基线。
**前置**：Phase 32 的单一 Theme、P0 字体覆盖修正与 P2-1~P2-11 token 批次已完成；27-0 盘点见 [`theme_font_inventory.md`](../reference/theme_font_inventory.md)。
**非目标**：不重命名 618 个冻结变体；不一次性重做全部 UI；不改布局层级、输入映射、存档格式或动画时序；不删除未确认授权/回滚证据的私有字体；不以目录搬迁或变体数量作为完成标准。

### 27-0 现状盘点与守卫（已完成）

- 盘点 618 变体、3,218 属性、54 个子资源、108 个字体颜色值、31 种字号、13 个顶层字体文件（80.8 MB）与 385 处动态 `add_theme_*`；详见 [`theme_font_inventory.md`](../reference/theme_font_inventory.md)；
- 新增 `scripts/ui_surface_token_audit.py`：扫描自绘 `StyleBoxFlat` 的 `bg_color`/`border_color`/`shadow_color`，并禁止 `Script/main_menu` 出现裸色；`--self-test` 覆盖正负样本；
- `theme_token_audit.py` 与 `ui_surface_token_audit.py` 已接入 `contract_gate.py`；`ui_surface_token_baseline.json` 冻结迁移期 18 处（`coop_panel_host` 2、`pet_interface` 12、`learn_skill` 4）；
- P2-11 同步完成输入光标/选区与 main_menu 动态样式 token 化；
- 出口：专项审计通过，main_menu 裸色 0；不改显示基线。

### 27-1 Token 单一来源与生成/校验（已完成）

- 新增 `scripts/ui_theme_tokens.json`：登记 21 个文字 token、5 组表面 token、输入/受管 Theme 值、默认字体与 Theme token 审计集合；
- 新增 `scripts/convert_ui_theme_tokens.py`：`--write` 生成 `UiColorTokens`/`UiSurfaceTokens` 并回写 Theme 受管属性；`--check` 逐字比较生成结果；
- 当前受管 Theme 属性 10 项：默认字体、`TowerFloorInput` 光标/选区/占位、`ShopSearchInput` 光标/选区、`ArchiveLoginInput`/`ArchiveNumberInput` 光标/选区；
- `theme_token_audit.py` 的允许字号、描边、颜色与 Button 基类改从 token 源读取，不再在 Python 中重复定义；
- 漂移实测：手工把 `TowerFloorInput/colors/caret_color` 改为黑色，`--check` 精确报出文件/行并返回 1；`--write` 恢复后 0 漂移；
- 现有运行值不变；仅统一 `caret_color` 的 `1.0`/`1` 字面格式。
- 出口：生成结果与 token 源一致；`--check` 进入 `contract_gate.py`；受管 Theme 属性与脚本常量不再双写。

### 27-2 字号标尺收敛

- 以 10/12/14/16/18/20/24/28/32/36 为常规标尺，40/50/76/100 仅战斗/数字；
- 将 111 个 off-token 变体按视觉类分批映射：17→16/18、25→24、30→28/32、22→20/24、35→32/36，其余 9/13/15/19/21/23/26/27/29/31/33/38 按最近 token 处理；
- 每批更新 `theme_token_baseline.json`，保留 1280×800 与 1600×1000 截图、控件几何和裁切检查；字号变化导致的布局变化必须显式记录，不静默接受；
- 出口：off-token 字号变体 **111→0**；`FONT_SIZES` 只保留最终标尺；无新增缺字/裁切。

### 27-3 颜色与 StyleBox 语义收敛

- 将 108 个字体颜色值、79 处 off-token 赋值按文字主/次/弱、金/橙/绿/红、描边/阴影收敛到语义 token；
- 将 54 个 StyleBox 子资源按面板/卡片/按钮/输入/列表角色合并；保留 `empty_button` 等高频共享资源，删除只服务单一变体的重复 StyleBox；
- 输入配色继续使用深底 `INPUT_CARET`/`INPUT_SELECTION` 与浅底暖黑/25% 选区；
- 出口：off-token 字体色赋值 **79→0**；StyleBox 子资源 **54→≤36** 且全部有语义名；截图无未批准色差。

### 27-4 变体层级与重复合并

- 保留 618 个变体名，但建立语义基类（正文、标题、强调、按钮、面板、输入、列表）；现有变体只声明差异；
- 优先合并 49 个重复签名组/239 个变体：45 个容器别名、41 个行布局别名、14 个 Margin、11 个 Grid 等；
- 变体名仍冻结；新增变体必须继承已登记基类，不得直接继承原生控件或复制整组属性；
- 出口：重复签名组 **49→≤10**（仅允许纯容器别名）；Theme 属性 **3,218→≤2,000**；所有变体名与场景引用保持不变。

### 27-5 字体族与资产收敛

- 目标 4 个运行字体角色 + 1 个 fallback：`body`、`ui`、`display`、`accent`；`font_wo`、`font_194`、`font_jin_qiao` 等低频族先映射后退役；
- Theme 引用字体资产 **10→≤6**；未引用字体 **0**；`Font/zmws` 与 `Font/zmws_bmfont` 只在确认无动态引用后归档/删除；
- 为保留字体补显式 fallback；在授权允许时做字符子集化，未授权则保留原文件并记录发布边界；
- 增加动态文本字体覆盖样本（公告、Boss 信息、怪物帮助、伤害数字），不把静态 0 缺字当作动态覆盖完成；
- 出口：Theme 字体体积与加载数下降并记录；静态/动态中文覆盖 0 缺字；授权与回滚证据齐全。

### 27-6 动态覆盖收敛

- 将 385 处 `add_theme_*` 分为“静态角色”与“数据驱动”：静态角色改回 Theme 变体并删除覆盖；数据驱动只允许取 `UiColorTokens`/`UiSurfaceTokens`；
- 保留 `hit_text` 26 条动画轨道为已接受例外；新增 `ui_dynamic_theme_audit.py` 或等价计数基线，禁止未登记的静态覆盖增长；
- 重点文件：`pet_interface`、`wan_ling_catalog_page`、`equipment_catalog_page`、`mount_panel`、`zhen_yao_tower`、`game_mode_select`、`coop_panel_host`、`learn_skill`；
- 出口：静态角色覆盖为 0；数据驱动覆盖全部 token 化并登记；动态覆盖总计数不再增长。

### 27-7 阶段验收

- 通过 `check_all --godot-bin`、`theme_override_audit`、`theme_token_audit`、`ui_surface_token_audit`、`font_coverage_audit`、动态字体样本与全量关卡回归；
- 1280×800 / 1600×1000 代表菜单、面板、输入、公告、HUD 截图与控件几何对照；
- 更新 [`theme_font_inventory.md`](../reference/theme_font_inventory.md)、[`typography_tokens.md`](../reference/typography_tokens.md)、[`ui_theme_contract.md`](../reference/ui_theme_contract.md)、[`status.md`](../reference/status.md) 与 [`roadmap.md`](roadmap.md)；
- 出口：off-token 字号/颜色为 0；Theme 属性 ≤2,000；重复组 ≤10；字体资产 ≤6；静态动态覆盖 0；0 ERROR / 0 WARNING；显示基线差异均有截图批准记录。

---

## 6. 跨阶段纪律

1. **一个批次一个所有权边界**：迁移全部生产调用方，删除旧实现；回滚用版本控制，不用永久双实现。
2. **不新增 Autoload、不新增 `Global` 业务字段、不新增 `add` 系门面**；新增能力先证明普通节点/`RefCounted`/`Resource`/静态工具不足。
3. **定义与实例分离**：静态定义走 Resource/Catalog；玩家档案保持加密 JSON、`DataKeys` 与 `ensure_*`；不整体 Resource 化。
4. **不搬目录**：保留 `Scene`/`Script`/`Art` 类型顶层；功能在内部聚合；路径迁移走 `rename_path.py`。
5. **失败显式**：缺资源、无来源、保存失败、加载失败、过期回调必须报告给拥有者；不默认 1P、不猜旧路径、不静默成功。
6. **验收按变更矩阵**：静态门禁、相关探针、生产路径冒烟、全量回归、release/性能分别取证；不新增只验证 wiring 的永久测试。
7. **文档同步**：每批完成后更新 `architecture.md`、`status.md`、对应矩阵与 `global_runtime_inventory.md`；归档只在阶段结束后进行。

---

## 7. 当前恢复入口

**当前下一步**：**Phase 27-2 字号标尺收敛**（27-0、27-1 已完成；先以 token 源为唯一值来源，再分批处理 111 个 off-token 字号）。
**Phase 26**：平台与发布验证长期暂缓；重新启动需要平台矩阵、设备、导出条件与 release 证据同时明确。
**Phase 27-0/27-1 产物**：[`theme_font_inventory.md`](../reference/theme_font_inventory.md)、`scripts/ui_surface_token_audit.py`、`scripts/ui_surface_token_baseline.json`、`scripts/ui_theme_tokens.json`、`scripts/convert_ui_theme_tokens.py`。
**23-0/23-1/23-2 产物**：[`pet_level_boundary_matrix.md`](../reference/pet_level_boundary_matrix.md)；**23-4/23-5 产物**：[`pet_domain_contract.md`](../reference/pet_domain_contract.md)、[`status.md`](../reference/status.md)；**24-0/24-1/24-2/24-3/24-4 产物**：[`ui_panel_contract_matrix.md`](../reference/ui_panel_contract_matrix.md)、`PetAttributePages` 子控制器、`CoopPanelHost`、`PetDomainCommand.upgrade_formation`、`hud_panel_boundary` 间接写档守卫；**25-0~25-5 产物**：[`combat_behavior_matrix.md`](../reference/combat_behavior_matrix.md)、`AutoBattleContext`、`AutoBattleController`、`MagicWeaponPresentationController`、`BossProtectionController`、`HitReactionController`、`LocalCoopAutoBattleProbe`、`LocalCoopMagicPresentationProbe`、`LocalCoopBossProtectionProbe`、`LocalCoopHitReactionProbe`

- 当前架构：[`architecture.md`](../reference/architecture.md)
- Global 清单：[`global_runtime_inventory.md`](../reference/global_runtime_inventory.md)
- 验收标准：[`acceptance.md`](../reference/acceptance.md)
- 当前状态：[`status.md`](../reference/status.md)
- 长期路线：[`roadmap.md`](roadmap.md)
- 已归档程序记录：[`program_21_33_closeout.md`](../archive/program_21_33_closeout.md)
