# Phase 24 归档：UI 与成长命令边界

> **归档日期**：2026-11-06
> **状态**：Archived；24-0 ~ 24-4 全部完成，Phase 24 已关闭。
> **关联**：当前面板边界见 [`../reference/ui_panel_contract_matrix.md`](../reference/ui_panel_contract_matrix.md)；宠物域契约见 [`../reference/pet_domain_contract.md`](../reference/pet_domain_contract.md)；前置阶段见 [`iteration_23_pet_domain_boundary.md`](iteration_23_pet_domain_boundary.md)。
> **职责**：本页保存 Phase 24 的目标、批次、验证与回滚边界；当前契约不在此复制。

---

## 1. 阶段边界

**目标**：让面板成为“显式操作者 + 数据视图 + 命令”的界面层，成长操作统一为可回滚命令；不重做整套 UI。

**前置**：Phase 23 的宠物生成与宠物域视图至少完成首批。

**非目标**：

- 不换 Theme、不改布局/显示基线、不启用全局 Theme；
- 不一次性重写全部面板；
- 不改变玩法数值、存档格式、输入映射或动画时序。

**批次顺序**：24-0 盘点 → 24-1 只读区域拆分 → 24-2 面板宿主分离 → 24-3 成长命令试点 → 24-4 阶段验收。

---

## 2. 批次记录

### 24-0 面板契约清单（只读调查）

- 产出 [`ui_panel_contract_matrix.md`](../reference/ui_panel_contract_matrix.md)：`LocalCoop` 五个入口、`pet_interface` 子区域、LDL 成长面板与只读信息面板；
- 面板显式操作者由 `LocalCoop.data_for/props_for` 解析；
- 已具备回滚的路径：宠物出战/休息/成长果、LDL 强化/神铸/淬骨/合成/打造、主动技能升级；
- 待命令化：宠物被动/技能/装备/批量出售、法宝强化、LDL 分解/镶嵌/一键合成、背包昵称与坐骑培养；
- 选定 24-1 首个拆分为 `PetAttributePages`，24-3 首个成长命令为宠物阵法升级；
- 本批次只改文档，未修改 `source/`。

### 24-1 `pet_interface` 分段拆分

- 新增 `pet_attribute_pages.gd` 并挂到既有 `PetAttributePages` 节点：子控制器持有 2 页定义、10 行绑定、分页按钮与显示文本；
- 父面板只注入分页按钮和显示值 `Callable`，保留当前宠物、装备加成、数值计算与页面协调；
- 子控制器不读取 `PlayerData`/`RoleProp`、不保存、不写档；
- 父面板删除重复状态与旧分页回调，`_refresh_pet_attribute_page` 仅作委托入口；
- 未改布局、Theme、数值规则或存档格式。

### 24-2 `CoopPanelHost` 宿主分离

- 新增普通节点 `CoopPanelHost`，由 `LocalCoop` 持有；`PANEL_PATHS`、面板实例/图层、窗口栈、暂停、1P/2P 选择器、场景按钮、关闭保存与本地清理迁入宿主；
- `LocalCoop` 只保留槽位、共享账本、输入会话、`slot_for`/`data_for`/`props_for` 与 `ui_slot` 状态；
- `backpack.gd`、`map_0.gd` 与探针全部改走 `LocalCoop.panel_host`；
- `push_windows()`/`pop_windows()` 嵌套语义与 ESC 先关协作面板规则保持；快照期间拒绝打开/切换；
- `clear`/场景切换释放面板、图层、会话按钮与悬停弹层，并恢复暂停与窗口栈；全局临时 UI 仍由 `UiRuntime`/`SceneFlow` 负责；
- `shared_ledger` 门禁拆分宿主快照互斥与 LocalCoop 账本约束。

### 24-3 成长命令试点：宠物阵法升级

- `PetDomainCommand.upgrade_formation(profile, stat_name, requested_count, save_request)` 先校验等级与材料，按可负担级数计算总消耗；
- 一次快照后扣材料、写入 `宠物阵法等级`，调用 `MemoryClass.request_save_result("pet_formation", false)`；保存失败恢复完整档案；
- 双人会话以 1P 档案快照覆盖 1P/2P 与共享道具、灵魂，2P 操作失败同样整批恢复；
- `PetFormationPopup` 只读规则与材料计数并显示命令结果，不再写 `_data()`；升十级改为一次命令提交。

### 24-4 阶段验收

- 确认 `PetAttributePages` 子区域拆分与 `PetDomainCommand.upgrade_formation` 已接入；
- `hud_panel_boundary` 扩展到 `Script/back_pack/`、`Script/skill/`、`Script/ldl/` 与显式 HUD 文件，识别 `PlayerData.player_data`、`_data()`、`data_for(_slot)(...).player_data` 的赋值、嵌套访问修改、列表/字典变更和局部别名；
- 旧路径按 [`ui_panel_contract_matrix.md`](../reference/ui_panel_contract_matrix.md) §4.3 登记：11 个文件整文件例外 + `pet_interface` 7 行、`synthesis` 3 行、`coop_backpack` 2 行逐行例外；档案 IO 不豁免；
- `contract_scan --self-test` HUD **14 坏 / 13 好 PASS**。

---

## 3. 验证汇总

| 批次 | 验证结果 |
|:---|:---|
| 24-1 | `check_all` **9/9**（32.39s）；`health_check` **775 脚本 0/0/0**；`archive` **332/332**（11.02s，含控制器、真实按钮切页与显示值）；`scene` **17/17**（166.43s）；`coop` **33/33**（196.98s，含 2P 面板操作者与切页）；全量 **128/128 + 5 SKIP**（311.1s，无重试） |
| 24-2 | `check_all` **9/9**（34.77s）；`health_check` **776 脚本 0/0/0**；`archive` **332/332**（11.06s）；`scene` **17/17**（157.58s）；`coop` **33/33**（182.96s，含宿主节点/无旧入口、P2 面板操作者、1P/2P 选择器、切页、快照互斥与 `clear` 清理）；全量 **128/128 + 5 SKIP**（308.8s，无重试） |
| 24-3 | `check_all` **9/9**（28.51s）；`health_check` **776 脚本 0/0/0**；`archive` **344/344**（10.54s，含 1P/2P 成功、失败整批回滚、材料/灵魂恢复与单次保存）；`scene` **17/17**（167.51s）；`coop` **33/33**（191.91s）；`level_1` **4 阶段 PASS**（24.95s，0/0/0）；全量 **128/128 + 5 SKIP**（311.4s，无重试） |
| 24-4 | `check_all` **9/9**（33.99s）；`archive` **344/344**（10.47s）；`scene` **17/17**（170.36s）；`coop` **33/33**（199.88s）；`level_1` **4 阶段 PASS**（24.95s，0/0/0）；全量 **128/128 + 5 SKIP**（305.8s，无重试） |

---

## 4. 出口与回滚边界

**阶段出口**：

- 至少一个面板子区域（`PetAttributePages`）与一个成长域（宠物阵法升级）完成命令化；
- 未登记的新增直接/间接写档由门禁拦截；
- 已登记旧路径有明确文件/行与迁移说明。

**回滚边界**：

- 回滚通过版本控制，不保留双实现、兼容 facade 或旧写档路径；
- `CoopPanelHost` 不移回 `LocalCoop`；`PetDomainCommand` 不回落为面板直写；
- 未完成的面板/成长命令（宠物被动/技能/装备、法宝强化、LDL 分解/镶嵌/一键合成、背包昵称、坐骑培养）保持登记状态，后续按同一命令/快照模式处理。

---

## 5. 关联文档

- [`../reference/ui_panel_contract_matrix.md`](../reference/ui_panel_contract_matrix.md)：当前操作者、保存、宿主与写档边界
- [`../reference/pet_domain_contract.md`](../reference/pet_domain_contract.md)：宠物域只读 View 与命令
- [`iteration_23_pet_domain_boundary.md`](iteration_23_pet_domain_boundary.md)：Phase 23 宠物域边界
- [`../decisions/ADR-017-local-coop-profile-isolation.md`](../decisions/ADR-017-local-coop-profile-isolation.md)：双人档案隔离
- [`../reference/status.md`](../reference/status.md)：当前门禁与验证基线
