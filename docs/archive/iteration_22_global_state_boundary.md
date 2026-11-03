# Phase 22：Global 状态与入口契约（归档）

> **归档日期**：2026-11-03
> **状态**：Archived；Phase 22-1 ~ 22-4 已完成并收口。
> **关联**：[`current-iteration.md`](../roadmap/current-iteration.md)、[`roadmap.md`](../roadmap/roadmap.md)、[`global_runtime_inventory.md`](../reference/global_runtime_inventory.md)、[`architecture.md`](../reference/architecture.md)、[`status.md`](../reference/status.md)、[`acceptance.md`](../reference/acceptance.md)。

## 1. 阶段范围与结论

**目标**：把 `Global` 收敛为组合根、typed getter 与稳定窄入口；业务状态由明确服务/会话/关卡上下文拥有。
**非目标**：不减少 Autoload 数量、不搬迁目录、不重写场景流、不改变玩法行为、不把 UI/成长域一并重做。

### 22-1 Global 状态/入口基线（已完成）

- 产出 [`global_runtime_inventory.md`](../reference/global_runtime_inventory.md)：
  - 141 个 `var` 字段按云存档、表现、法宝、单局、瞬时面板、生命周期、服务指针、场景遗留与怪物追踪分组；
  - 273 个公开函数、120 个 `add` 系工厂入口；
  - 26 个普通子服务及 `RunContext`/`ArchiveSession` 的当前边界；
  - 每组给出保留/迁移/删除候选与 Phase 22-2 交接条件。
- 结论：`Global` 已具备组合根形态，但仍有业务状态与工厂门面；后续必须按所有权切片，不按字段数量一次性搬运。
- 验证：只读盘点；未改 `source/`，未声称新的运行验证。

### 22-2 引用确认与零引用清理（已完成）

**结果**：

- 完成全量静态引用、动态字符串、场景/资源引用确认；
- 删除 **10 个字段**、**12 个公开入口**及仅供调试追踪的私有回调；
- `global.gd` 从 **3,516 行降至 3,308 行**（-208 行）；
- 当前 **131 个字段、261 个公开函数、120 个 `add` 系入口**；
- 删除清单、保留项理由与 22-3 交接见 [`global_runtime_inventory.md`](../reference/global_runtime_inventory.md) §6。

**验收**：

- `check_all --skip-engine` **7/7 PASS**；
- `check_all --godot-bin` **9/9 PASS**；
- `archive_probe_runner` **297/297 PASS**；
- `scene_probe_runner` **PASS**；
- `coop_probe_runner` **26/26 PASS**；
- `level_1` 四阶段冒烟 **PASS**（0 ERROR / 0 WARNING）；
- 未改场景、资源、存档格式、输入映射或玩法数值；未新增永久测试。

### 22-3 状态迁移（22-3A/22-3B/22-3C/22-3D-1/22-3D-2/22-3E 完成）

每批只迁移一个所有权边界，迁移全部生产调用方后删除旧字段/入口。

**22-3A 结果**：`Global.cloud_save_*` 与认证冷却字段已删除；新增 `CloudSession`（`RefCounted`）由 `MemoryClass` 持有，`read_archive_interface.gd` 已迁移，生产消费引用为 0。验证：`check_all` 7/7、9/9，档案探针 297/297，场景探针 PASS，协作探针 26/26，`level_1` PASS，临时 `CloudSession` 逻辑探针 PASS。

**22-3B 结果**：19 个法宝实例字段经精确 `Global.<field>` 检查为零引用后删除；场景路径表、预载路径与 xianyjp 预热分派迁入 `MagicWeaponRuntime`；双槽位、创建/替换/清理语义不变。验证：`check_all` 7/7、9/9，`magic-weapons` 探针 PASS，档案 297/297，场景探针 PASS，协作 26/26，`level_1` PASS。

**22-3C 结果**：关卡计时、`last_level_path`、最大连击、三太子/星宿选择、玲珑塔三种挑战模式、玩家受击计数与结算类型迁入 `RunContext`；删除 5 个无消费者或重复真源字段；星座进度只以 `PlayerData` 为真源。验证：`check_all` 7/7、9/9，`run-context` 与 `level-selection` 探针 PASS，档案 297/297，场景 17/17，协作 26/26，`level_1` / `level_llbt` / `level_17` 冒烟 PASS。

**22-3D-1 结果**：`is_frist`、`is_show` 迁入 `UiRuntime` 一次性消费；`box_count` 迁入 `BackpackFactory` 点击冷却；`_last_combo_value`、`_pending_combo_milestones` 与 `check_combo_milestone` 迁入 `CombatPoolRuntime`。验证：`check_all` 7/7、9/9，`ui-factories` 探针 PASS，档案 297/297，场景 17/17，协作 26/26，`level_1` PASS。

**22-3D-2 结果**：§2.6/§2.9 共 21 个字段迁出或删除；`file_num` 收敛为 `MainSet.FILE_VALUE`，锻造/分解状态归 `ForgeFactory`，Ldl 模式归 `UiRuntime`，连击计数归 `CombatPoolRuntime`，玩家朝向归 `RunContext`；场景槽位分别归 `MenuPanelFactory`、`LevelSceneFactory`、`BackpackFactory`、`MonsterDisplayFactory` 与 `SceneFlow`。验证：`check_all` 7/7、9/9，`ui-factories`/`run-context` 探针 PASS，档案 297/297，场景 17/17，协作 26/26，`level_1` PASS。

**22-3E 结果**：26 个普通子服务指针保留在 `Global` 组合根，不把服务内部状态搬回；无代码搬迁，已在剩余字段复核表中登记所有者与出口。

**22-4 结果**：新增 `global_surface_boundary` 契约规则，基线 `scripts/global_surface_baseline.json` 冻结 65 字段与 120 个 `add` 入口；新增未登记表面在 `--fail-on-error` 下为 ERROR。自测坏样本 2 / 好样本 4；全量契约 ERROR=0。

| 批次 | 范围 | 目标所有者 | 关键约束 |
|:---|:---|:---|:---|
| 22-3A | 云存档/账号字段与相关读取（已完成） | `MemoryClass` 持 `CloudSession` | 不新增 Autoload；保留失败与退出语义 |
| 22-3B | 法宝实例槽位与残留节点引用（已完成） | `MagicWeaponRuntime` | 两个槽位规则不变；创建/替换/预载/清理同批迁移 |
| 22-3C | 单局、关卡、选择与统计字段（已完成） | `RunContext` / `LevelEntryRuntime` | 单局状态、关卡选择与表现缓存分开；不改变关卡时序 |
| 22-3D-1 | 2.5 表现与一次性 UI 字段（已完成） | `UiRuntime` / `BackpackFactory` / `CombatPoolRuntime` | 一次性提示、背包冷却与连击里程碑不回到 `Global` |
| 22-3D-2 | 2.6 瞬时面板与 2.9 场景/UI 引用（已完成） | 对应工厂 / `UiRuntime` / `SceneFlow` | 临时 UI 必须登记；无消费者条目删除 |
| 22-3E | 服务指针与组合根（评估完成，保留） | `Global` 组合根 | 只整理引用，不把服务私有状态搬回 `Global` |
| 22-4 | 新增 Global 业务字段/add 入口守卫（已完成） | `contract_scan.py` + 基线 | `--self-test` 与 `--fail-on-error` 证据 |

**每批验收**：

- 旧字段/入口删除，调用方全部迁移；
- 正常、边界、失败、退出路径按 [`acceptance.md`](../reference/acceptance.md) 选取；
- 档案、场景、协作与相关关卡探针通过；不把 PCK 闭包当作本批行为验证。

### 22-4 守卫与阶段收口（已完成）

- 新增 `contract_scan.py` 的 Global 表面基线门禁与 `scripts/global_surface_baseline.json`；
- 自测覆盖新增字段、新增入口、局部变量、注释与非 `Global` 文件，坏样本 2 / 好样本 4；
- 剩余 65 字段已在 `global_runtime_inventory.md` §2.10 登记所有者、理由与出口；
- 阶段出口：`Global` 不再新增业务状态；服务/会话/关卡状态有单一写入者；相关矩阵与状态一致。
