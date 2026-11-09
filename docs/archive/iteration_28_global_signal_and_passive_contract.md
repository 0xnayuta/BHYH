# Phase 28 全局通信与派生属性契约归档

> **归档日期**：2026-11-09
> **状态**：Archived
> **关联**：[`ADR-028`](../decisions/ADR-028-confirm-dialog-callback-ownership.md)、[`ADR-029`](../decisions/ADR-029-passive-snapshot-event-driven.md)、[`ADR-030`](../decisions/ADR-030-pet-passive-command-and-table.md)、[`../reference/passive_skill_contract.md`](../reference/passive_skill_contract.md)、[`../reference/pet_domain_contract.md`](../reference/pet_domain_contract.md)

## Phase 28 全局通信与派生属性契约（28-1、28-2、28-3 完成）

- **目标**：移除全局确认信号 `Signals`，把确认回调归打开者所有；把被动属性快照从每帧轮询改为档案变更事件驱动；为这两条边界建立单一写者与门禁。
- **入口**：全局确认面 `Script/base/signals.gd`、`Scene/show_text/choose_scene.gd`、`Script/runtime/popup_factory.gd`；被动数值面 `Script/skill/passive_skills.gd`、`Script/memory_class/player_data.gd`、`Script/coop/local_coop.gd`。
- **非目标**：不改玩法数值、存档格式、输入映射；不新增 Autoload；不迁移 `Scene/` 下其余脚本（归 Phase 29）；不处理 `global.gd` 的根目录位置。

#### 28-1 移除全局确认信号（完成）

- `choose_scene.gd` 增加 `confirmed`/`cancelled` 实例信号；确认与取消先发信号、再释放实例。
- 10 个 `connect_choose_box_signal` 调用点改为在 `Global.add_choose_text()` 返回值上连接；`decompose.gd` 的连接从 `_ready` 移到打开处。
- `PopupFactory` 维护活动确认框：新确认框打开时显式关闭旧实例，固化“最后打开者接管”的单确认框语义，不再依赖信号断开。
- 删除 `Script/base/signals.gd` 与伴生 `.uid`，从 `project.godot` 移除 `Signals` 注册项；Autoload 由 11 项降为 10 项（9 个业务单例 + `MCPGameBridge`）。
- 新增 ADR 记录“确认框回调归打开者所有”；更新 `autoload_boundary_matrix.md`、`architecture.md`、`global_runtime_inventory.md` 的注册项计数。
- 新增全局信号基线门禁：扫描 Autoload 脚本的 `signal` 声明，与基线比较，新增报 ERROR；删除 `Signals` 后基线为 `MemoryClass` 的 `background_save_finished` 与 `save_failed`。
- **出口**：10 条确认路径（存档删除、出售、分解、挑战、商店购买、技能升级等）确认/取消各执行一次；连续打开、暂停、场景切换释放正常；`check_all`、`health_check`、`scene_probe_runner`、`coop_probe_runner`、`level_1` 与变更影响回归通过；文档计数一致。

#### 28-2 被动属性快照事件化（完成）

- 删除 `passive_skills.gd` 的 `_physics_process` 轮询与 `LocalCoop.secondary_passives` 的轮询。
- `PlayerData` 增加 `passive_skills_changed` 信号；在 `apply_passive_skill_upgrades()` 成功、`ensure_player_passive_skills()` 实际修正、档案载入完成后发出。
- `PaSkill` 连接信号并保留启动刷新；`LocalCoop` 只刷新 2P 槽位；`get_passive_skill_properties()` 增加等级与属性实例签名短路。
- `DataKeys` 增加玩家被动技能键常量，替换 `PaSkill`、`PlayerData`、`bd_skill`、`back_pack` 中的裸中文键；宠物被动键保持独立域。
- 新增 `docs/reference/passive_skill_contract.md`；`contract_scan.py` 增加 `PASSIVE_SNAPSHOT_WRITE`、`PASSIVE_POLLING`、`PASSIVE_DATA_WRITE`。
- **出口**：新建档、读档、单技能/一键升级、保存失败回滚、双人 link/取消、切档、属性实例重建的验证矩阵全部通过；`check_all`、`health_check`、`coop_probe_runner`、档案探针与关卡回归通过。

#### 28-3 宠物被动成长命令与数值表契约（完成）

- **目标**：把宠物被动升级从 UI 直写改为 `PetDomainCommand` 命令，保存失败恢复等级与共享灵魂；提取玩家/宠物共用的只读数值表 `PassiveSkillTable`，消除宠物域对 `PaSkill` Autoload 的依赖；收敛宠物被动键并建立写入门禁。
- **入口**：`Script/pet/pet_interface.gd` 的 `_upgrade_pet_passive`/`_upgrade_all_pet_passives`/`_pet_passive_levels`；`Script/pet/pet_domain_command.gd`；4 个 `pet_*_summon_base.gd`；`Script/memory_class/player_data.gd` 的 `_normalize_pet_passives`。
- **非目标**：不改宠物数值、等级上限、费用公式、宠物列表/出战槽位规则；不改玩家 `pasl_prop` 刷新；不处理 Phase 29 目录。
- **28-3A 命令化与失败回滚**：新增 `PetDomainCommand.upgrade_passive()` 与 `upgrade_all_passives()`；快照用 `profile.snapshot_state()`（覆盖 1P/2P 与共享灵魂），保存失败 `restore_state()`；UI 只调用命令并在成功后刷新活体。
- **28-3B 数值表提取**：新增 `Script/skill/passive_skill_table.gd`（`class_name PassiveSkillTable`）；`PaSkill` 公开函数委托；宠物域 4 个召唤物、面板与命令改用静态表。
- **28-3C 键与门禁**：`PET_PASSIVE_KEYS`、默认宠物字典、`_normalize_pet_passives`、召唤物读取改用 `DataKeys.Skill.PASSIVE_*`；`contract_scan` 新增 `pet_passive_boundary` 与自测；更新 `pet_domain_contract.md`、`passive_skill_contract.md`、`acceptance.md`、`scripts/README.md`。
- **28-3D 验证**：单次/一键升级成功与保存失败回滚、满级/灵魂不足、1P/2P 快照作用域、读档/切档、活体宠物属性刷新、宠物背包共享不受影响；`check_all`、`health_check`、`contract_scan --self-test`、`archive_probe_runner`、`coop_probe_runner`、`level_1` 通过。
- **出口**：宠物被动升级保存失败不产生等级或灵魂变化；宠物域不再调用 `PaSkill`；UI 直写被门禁拦截。
