# BHYH 当前候选迭代

> **状态**：**Phase 22、Phase 23 已完成并归档**（2026-11-03）；当前候选为 **Phase 24**，**24-0 面板契约盘点与 24-1 `PetAttributePages` 拆分已完成**，24-2~24-4 未启动；Phase 25~26 已规划。
> **版本**：6.9；不改变玩法数值、动画时序、输入映射、存档格式或显示基线。
> **当前基线**：[`global_runtime_inventory.md`](../reference/global_runtime_inventory.md)（Phase 22-1）、[`architecture.md`](../reference/architecture.md)、[`status.md`](../reference/status.md)、[`acceptance.md`](../reference/acceptance.md)。
> **编号说明**：Phase 22~26 为本轮新增候选，承接 Phase 21；已归档的 Phase 30~33 不重开，也不把历史归档改写成新计划。

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
- 盘点结果：面板显式操作者由 `LocalCoop.data_for/props_for` 解析；`hud_panel_boundary` 仅覆盖部分文件，`_data()[...]`、嵌套字典与 `data_for_slot(...).player_data[...]` 仍可绕过；
- 已具备回滚的路径：宠物出战/休息/成长果、LDL 强化/神铸/淬骨/合成/打造、主动技能升级；
- 待命令化：宠物阵法/被动/技能/装备/批量出售、法宝强化、LDL 分解/镶嵌/一键合成、背包昵称与坐骑培养；
- **24-1 首个拆分对象**：`PetAttributePages`（只读属性区域，无保存副作用）；
- **24-3 首个成长命令**：宠物阵法升级（当前 `_data()["宠物阵法等级"]` 直写、材料先扣、保存失败不回滚）；
- 本批次只改文档，未修改 `source/`。

### 24-1 `pet_interface` 分段拆分（已完成）

- 新增 `pet_attribute_pages.gd` 并挂到既有 `PetAttributePages` 节点：子控制器持有 2 页定义、10 行绑定、分页按钮与显示文本；
- 父面板只注入分页按钮和显示值 `Callable`，保留当前宠物、装备加成、数值计算与页面协调；子控制器不读取 `PlayerData`、不保存、不写档；
- 删除父面板的 `pet_attribute_page`、行/标签/按钮数组及旧分页回调，保留 `_refresh_pet_attribute_page` 作为委托入口；
- 未改布局、Theme、数值规则或存档格式；`PetAttributePages` 节点仍使用原场景行与按钮；
- 验证：`check_all --godot-bin` **9/9**（32.39s）、`health_check` **775 脚本 0/0/0**、`archive` **332/332**（11.02s，含控制器、真实按钮切页与显示值）、`scene` **17/17**（166.43s）、`coop` **33/33**（196.98s，含 2P 宠物面板操作者与切页）、全量 **128/128 + SKIP 5**（311.1s，无重试）。

### 24-2 `LocalCoop` 面板宿主分离

- 保留 `LocalCoop` 的槽位/账本/输入会话职责；
- 把双人面板宿主、窗口切换与关闭生命周期迁到 UI 侧普通节点/服务；
- 保持 `push_windows()`/`pop_windows()` 语义与 ESC 关闭一层规则；
- 验证双人面板、切档、退出与临时 UI 清理。

### 24-3 成长命令试点

- 选择一个域（锻造、背包或宠物成长）建立“校验 → 快照 → 提交 → 保存 → 失败恢复”命令；
- UI 只发命令并显示结果，不直接拼档路径或写 `player_data`；
- 共用现有 `EquipmentService` 模式与共享账本规则，不引入通用事务框架；
- 验证失败无部分扣费、无重复领取、面板状态可恢复。

### 24-4 阶段验收

- `coop_probe_runner`、`scene_probe_runner`、相关 UI 场景与全量回归；
- 检查临时 UI 登记、快照互斥、返回/关闭/切档；
- 出口：至少一个面板与一个成长域完成命令化，且无表现层直接写档。

---

## 3. Phase 25：战斗实体行为切片

**目标**：在不改变战斗数值与时序的前提下，把 `BaseHero`/`BaseMonster` 中可独立生命周期的行为移出。
**前置**：Phase 22 的伤害/状态所有权稳定；建议在 Phase 24 之后再启动，避免 UI 与实体同时迁移。
**非目标**：不引入 ECS、不重排继承、不一次性拆完 `BaseHero`/`BaseMonster`、不改碰撞层与动作时序。

### 25-0 行为与验证映射

- 以 `BaseHero`、`BaseMonster`、关卡/协作战探针为输入，标记行为的状态、输入、生命周期、失败路径；
- 首批选择一个最有独立性的行为（建议自动战斗或受击反应），不按行数选；
- 输出：行为切片、调用方、验收场景与回滚边界。

### 25-1 自动战斗控制器

- 抽出目标选择、技能选择、移动/跳跃与重试策略；
- `BaseHero` 保留实体根与公开入口，控制器通过显式上下文查询目标/技能；
- 不改变自动战斗数值与动作时序；验证单双人、暂停、死亡与切关。

### 25-2 法宝/时装/翅膀表现切片

- 只迁移有独立生命周期的实例状态与播放协调；
- 保留 `BaseMagicWeapon` 与装备/法宝命令边界；不把表现状态写回共享资源；
- 验证法宝切换、冷却、死亡清理与双人槽位归属。

### 25-3 `BaseMonster` Boss 保护与掉落

- 把 Boss 保护/白条状态与掉落结算从主 AI/受击循环中分离；
- 保持阶段、死亡结算和奖励单一提交；
- 验证 Boss 阶段、控制免疫、掉落、重战与重复结算。

### 25-4 受击与来源归属加固

- 统一受击反应状态、来源快照与池化重置；
- 不默认 1P；无来源时保持零伤害语义；
- 验证双人、召唤物、弹体、法宝与延迟回调。

### 25-5 阶段验收

- 相关关卡、`coop_probe_runner`、战斗/场景探针与全量回归；
- 出口：至少两个行为切片独立，且战斗结果与现有基线一致。

---

## 4. Phase 26：平台与发布验证

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

## 5. 跨阶段纪律

1. **一个批次一个所有权边界**：迁移全部生产调用方，删除旧实现；回滚用版本控制，不用永久双实现。
2. **不新增 Autoload、不新增 `Global` 业务字段、不新增 `add` 系门面**；新增能力先证明普通节点/`RefCounted`/`Resource`/静态工具不足。
3. **定义与实例分离**：静态定义走 Resource/Catalog；玩家档案保持加密 JSON、`DataKeys` 与 `ensure_*`；不整体 Resource 化。
4. **不搬目录**：保留 `Scene`/`Script`/`Art` 类型顶层；功能在内部聚合；路径迁移走 `rename_path.py`。
5. **失败显式**：缺资源、无来源、保存失败、加载失败、过期回调必须报告给拥有者；不默认 1P、不猜旧路径、不静默成功。
6. **验收按变更矩阵**：静态门禁、相关探针、生产路径冒烟、全量回归、release/性能分别取证；不新增只验证 wiring 的永久测试。
7. **文档同步**：每批完成后更新 `architecture.md`、`status.md`、对应矩阵与 `global_runtime_inventory.md`；归档只在阶段结束后进行。

---

## 6. 当前恢复入口

**当前下一步**：**Phase 24-2 `LocalCoop` 面板宿主分离**；24-0/24-1 已完成。
**当前不启动**：Phase 25~26。
**23-0/23-1/23-2 产物**：[`pet_level_boundary_matrix.md`](../reference/pet_level_boundary_matrix.md)；**23-4/23-5 产物**：[`pet_domain_contract.md`](../reference/pet_domain_contract.md)、[`status.md`](../reference/status.md)；**24-0/24-1 产物**：[`ui_panel_contract_matrix.md`](../reference/ui_panel_contract_matrix.md)、`PetAttributePages` 子控制器

- 当前架构：[`architecture.md`](../reference/architecture.md)
- Global 清单：[`global_runtime_inventory.md`](../reference/global_runtime_inventory.md)
- 验收标准：[`acceptance.md`](../reference/acceptance.md)
- 当前状态：[`status.md`](../reference/status.md)
- 长期路线：[`roadmap.md`](roadmap.md)
- 已归档程序记录：[`program_21_33_closeout.md`](../archive/program_21_33_closeout.md)
