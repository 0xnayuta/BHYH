# BHYH 当前候选迭代

> **状态**：**Phase 22 已完成并收口**（2026-11-02）；**Phase 23-0 调查、Phase 23-1 龟族抽取、Phase 23-2 首批 `PetTiger`、共享槽位边界批次、`PetDragon`、`PetPhoenix`、`PetRabbit`、`PetMouse`、`PetNeat` 与 `PetYinTiger` 迁移完成**（2026-11-03），八族全部完成；**Phase 23-3 关卡结算单一提交已完成**。Phase 24~26 已规划。
> **版本**：6.9；不改变玩法数值、动画时序、输入映射、存档格式或显示基线。
> **当前基线**：[`global_runtime_inventory.md`](../reference/global_runtime_inventory.md)（Phase 22-1）、[`architecture.md`](../reference/architecture.md)、[`status.md`](../reference/status.md)、[`acceptance.md`](../reference/acceptance.md)。
> **编号说明**：Phase 22~26 为本轮新增候选，承接 Phase 21；已归档的 Phase 30~33 不重开，也不把历史归档改写成新计划。

---

## 1. Phase 22：Global 状态与入口契约

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

---

## 2. Phase 23：关卡、宠物与档案数据边界

**目标**：先抽出 `BaseLevel` 中最明确的边界泄漏，再建立 `PlayerData` 的域视图试点。
**前置**：Phase 22 已完成并收口；不要求 22-3E 的 26 个服务指针继续搬迁。
**非目标**：不重写 `BaseLevel` 阶段状态机、不重写 `PlayerData`、不改变宠物数值/进化/出战规则。

### 23-0 调用面与首批宠物族选型（已完成）

- 盘点 `BaseLevel` 中宠物生成、归一化、进化、技能、场景路径与槽位解析函数；
- 选择一个调用面清晰、现有探针覆盖充分的宠物族作为首批，不按文件行数选；
- 输出 [`pet_level_boundary_matrix.md`](../reference/pet_level_boundary_matrix.md)：函数/字段迁移表、调用方清单、首批验收关卡与失败路径。

**结果**：当前 8 个宠物族、30 个召唤场景；`BaseLevel` 有 73 个宠物相关函数，并与 `BaseMonster`/`PetInterface` 存在 22/19 个重名规则。首批选择 **`PetTurtle`（龟布系）**：4 阶规则标准，且 `coop_probe_runner` 已直接覆盖龟族 P1/P2 经验、槽位、生命加成与 HUD 死亡态。23-1 采用 `PetLevelController` + `PetTurtleFamily`，龟族分支不得保留双实现；其余 7 族在 23-2 逐族迁移。已确认的 2P 预热、2P 升级写回、凤凰别名、寅虎预热门禁与法宝复活槽位风险登记在同页，修复放入对应实现批次。

### 23-1 首批宠物生成/进化抽取（已完成）

- 新增 `pet_level_controller.gd` 与 `pet_turtle_family.gd`（`RefCounted`，不新增 Autoload）；
- `BaseLevel` 删除龟族 7 个规则函数与龟族生成分支，改为控制器生成/恢复；
- `_canonicalize_active_pet_data`、`_pet_active_name` 的龟族识别与归一化统一走 `PetTurtleFamily`，并显式传入当前槽位档案；
- `BaseMonster` 删除龟族重复进化，现有各族进化与成长写入改为显式接收 `profile`，修复 P2 升级写回 1P；
- `PetInterface` 龟族出战/进化复用同一规则；`PlayerData` 的载入补全保留到 23-4；
- 验证：`check_all` 9/9、`pet-runtime` PASS、档案 297/297、场景 17/17、协作 26/26（新增 P2 写回断言）、`level_1` 四阶段 PASS、全量 128/128 + 5 SKIP（298.8s，默认 auto 并发）；临时探针覆盖死亡抑制与复活。

### 23-2 共享槽位边界（已完成）

- `Global.prewarm_active_pet_runtime_resources(slot)`、`get_active_pet_preload_data(slot)` 与 `get_active_pet_preload_paths(slot)` 按槽位解析；预热签名缓存按槽位隔离；
- `BaseLevel`、`PetLevelController` 与加载页按 1P/2P 遍历传槽位；`get_active_pet_preload_paths` 双槽并入加载清单；
- 慈心妙莲按持有者槽位读取死亡元数据、恢复对应槽位宠物并调用 `_spawn_active_pet(slot)`；`_active_pet` 查询按槽位过滤；
- 宠物装备加成经 `BaseObject.PlayerData` 槽位解析验证；未改宠物数值或装备规则；
- 验证：`coop_probe_runner` **27/27 PASS**（130.78s），新增 `LocalCoopPetSlotProbe` 覆盖 P1/P2 预载/路径/签名、P2 阵法装备加成与慈心妙莲槽位隔离。

### 23-2 `PetDragon` 迁移（已完成）

- 新增 `pet_dragon_family.gd`；`PetLevelController` 通过族规则表接管龟、虎、龙三族；
- `BaseLevel` 删除龙族 7 个规则函数与生成分支，龙族改由控制器生成；
- `BaseMonster` 删除龙族重复进化，升级调用改走 `PetDragonFamily.evolve`；成长分支使用族阶段名/技能；
- `PetInterface` 龙族检测、归一化、进化与活跃名复用族规则；`PlayerData` 载入补全保留到 23-4；
- 验证：`LocalCoopPetDragonProbe` 覆盖族规则、P2 升级写回与 `level_1` 双槽生成；`coop_probe_runner` **28/28 PASS**（165.15s）。

### 23-2 `PetPhoenix` 迁移（已完成）

- 新增 `pet_phoenix_family.gd`；`PetLevelController` 通过族规则表接管龟、虎、龙、凤四族；
- `BaseLevel` 删除凤凰族 7 个规则函数与生成分支，凤凰改由控制器生成；
- `BaseMonster` 删除凤凰重复进化，升级调用改走 `PetPhoenixFamily.evolve`；成长分支使用族阶段名/技能；
- `PetInterface` 凤凰检测、修复、归一化、进化与活跃名复用族规则；
- 补齐 `BaseLevel` 与 `PetInterface` 的凤凰死亡别名，覆盖 `雀蛋`、四阶名与 `朱雀幼灵`/`赤羽朱雀`/`朱雀神君`；
- `PlayerData` 载入补全保留到 23-4；
- 验证：`LocalCoopPetPhoenixProbe` 覆盖族规则、P2 升级写回、死亡别名与 `level_1` 双槽生成；`coop_probe_runner` **29/29 PASS**（148.65s）。

### 23-2 `PetRabbit` 迁移（已完成）

- 新增 `pet_rabbit_family.gd`；`PetLevelController` 通过族规则表接管龟、虎、龙、凤、兔五族；
- `BaseLevel` 删除月兔 6 个规则函数与生成分支，月兔改由控制器生成；
- `BaseMonster` 删除月兔重复进化，升级调用改走 `PetRabbitFamily.evolve`；成长分支使用族阶段名/技能；
- `PetInterface` 月兔检测、归一化、进化与活跃名复用族规则，保留永久解锁与不可放生逻辑；
- `BaseLevel` 与 `PetInterface` 的死亡别名改由 `PetRabbitFamily.append_death_aliases` 提供，覆盖 `月兔`/`疾风兔`/`寒冰玉兔`/`冰霜月神`；
- `PlayerData` 载入补全保留到 23-4；
- 验证：`LocalCoopPetRabbitProbe` 覆盖族规则、P2 升级写回、死亡别名与 `level_1` 双槽生成；`coop_probe_runner` **30/30 PASS**（164.29s）。

### 23-2 `PetMouse` 迁移（已完成）

- 新增 `pet_mouse_family.gd`；`PetLevelController` 通过族规则表接管龟、虎、龙、凤、兔、鼠六族；
- `BaseLevel` 删除子鼠 7 个规则函数与生成分支，子鼠改由控制器生成；
- `BaseMonster` 删除子鼠重复进化，升级调用改走 `PetMouseFamily.evolve`；成长分支保留 50 级进阶与技能 CD 解锁；
- `PetInterface` 子鼠检测、归一化、进化、技能补全与活跃名复用族规则；
- `BaseLevel` 与 `PetInterface` 的死亡别名改由 `PetMouseFamily.append_death_aliases` 提供，覆盖 `子鼠元帅`/`子鼠大元帅`；
- `PlayerData` 载入补全保留到 23-4；
- 验证：`LocalCoopPetMouseProbe` 覆盖族规则、P2 升级写回、死亡别名与 `level_1` 双槽生成；`coop_probe_runner` **31/31 PASS**（179.34s）。

### 23-2 `PetNeat` 迁移（已完成）

- 新增 `pet_neat_family.gd`；`PetLevelController` 通过族规则表接管龟、虎、龙、凤、兔、鼠、牛七族；
- `BaseLevel` 删除丑牛 7 个规则函数与生成分支，丑牛改由控制器生成；
- `BaseMonster` 删除丑牛重复规则，升级循环新增 `PetNeatFamily.evolve`，修复升级不刷新阶段/技能；成长分支改用族规则；
- `PetInterface` 丑牛检测、归一化、进化与活跃名复用族规则；
- `BaseLevel` 与 `PetInterface` 的死亡别名改由 `PetNeatFamily.append_death_aliases` 提供，覆盖 `丑牛元帅`/`丑牛大元帅`；
- `PlayerData` 载入补全保留到 23-4；
- 验证：`LocalCoopPetNeatProbe` 覆盖族规则、P2 升级写回、死亡别名与 `level_1` 双槽生成；`coop_probe_runner` **32/32 PASS**（168.53s）。

### 23-2 `PetYinTiger` 迁移（已完成）

- 新增 `pet_yin_tiger_family.gd`；`PetLevelController` 接管八族，`BaseLevel` 移除最后的旧生成分派；
- `BaseLevel` 删除寅虎 7 个规则函数与旧生成分支，生成只走控制器；
- `BaseMonster` 升级循环与成长分支改用 `PetYinTigerFamily`；
- `PetInterface` 寅虎检测、技能补全、归一化、进化与活跃名复用族规则；
- `Global` 补齐寅虎预载识别、场景/帧/弹体/头像/技能图标路径与预热；
- `BaseLevel` 与 `PetInterface` 的死亡别名改由 `PetYinTigerFamily.append_death_aliases` 提供；
- `PlayerData` 载入补全保留到 23-4；
- 验证：`LocalCoopPetYinTigerProbe` 覆盖族规则、P2 升级写回、死亡别名、Global 预热与 `level_1` 双槽生成；`coop_probe_runner` **33/33 PASS**（182.53s）。

### 23-2 其余宠物族分批迁移（八族全部完成）

- 新增 `pet_tiger_family.gd`；`PetLevelController` 通过族规则表接管龟、虎两族；
- `BaseLevel` 删除虎族 7 个规则函数与生成分支，兔族阶段阈值改用通用 `_pet_stage_for_level`；
- `BaseMonster` 删除虎族重复进化，升级调用改走 `PetTigerFamily.evolve`；成长分支使用族阶段名/技能；
- `PetInterface` 虎族检测、归一化、进化与死亡别名复用同一规则；
- 验证：`check_all` 9/9、`pet-runtime` PASS、档案 297/297（首跑 1 个瞬态后重跑）、场景 17/17、协作 26/26（共享槽位批次后复跑为 27/27）、`level_1` 四阶段 PASS、全量 128/128 + 5 SKIP（292.1s，默认 auto）；临时探针覆盖 1P 虎族 2 阶生成与 P2 虎族写回。

### 23-3 关卡结算单一提交（已完成）

- 复核 `LevelSettlement`、`victory`、`defeat` 与 `BaseLevel` 出口/重战路径；
- 结论：胜利场景 `_ready` 只提交一次 `level_victory`；返回/重战仅在有 pending 时 flush，重复点击由 `_is_leaving`/`_is_rechallenging` 拦截；
- 失败场景的道具、装备与永久拒绝奖励各自使用一次 `_request_settlement_save("level_defeat_reward")`，重复点击由本地/持久标记拦截，保存失败回滚本次奖励；
- 未改生产代码；补强 `archive_persistence_probe` 的装备成功、永久拒绝成功/失败路径；档案探针 **303/303 PASS**（11.21s），`check_all` **9/9 PASS**（32.78s）；
- 生产源码未变，沿用 Phase 23-2 末次 `coop` 33/33、`scene` 17/17、全量 128/128 + 5 SKIP 结果。

### 23-4 `PlayerData` 宠物域只读视图试点

- 选宠物域建立只读 View + 显式命令，覆盖读取、出战/休息、成长提交；
- `PlayerData` 继续承担加载、补全、保存聚合；不整体 Resource 化；
- 新代码不直接拼中文键；保留现有共享账本与槽位语义。

### 23-5 阶段验收

- `pet-runtime`、`scene_probe_runner`、`coop_probe_runner`、相关关卡与全量回归；
- 存档补全/失败、快照互斥、切档/退出路径按受影响范围执行；
- 出口：`BaseLevel` 宠物职责显著缩小；`PlayerData` 至少一个域有稳定只读边界。

---

## 3. Phase 24：UI 与成长命令边界

**目标**：让面板成为“显式操作者 + 数据视图 + 命令”的界面层，成长操作统一为可回滚命令；不重做整套 UI。
**前置**：Phase 23 的宠物生成与宠物域视图至少完成首批；否则先处理 Phase 23。
**非目标**：不换 Theme、不改布局/显示基线、不启用全局 Theme、不一次性重写全部面板。

### 24-0 面板契约清单

- 盘点 `pet_interface`、`monster_attr_data`、`level_info`、`LocalCoop` 面板宿主及关键成长面板；
- 为每个面板记录：打开者、`coop_slot`/操作者、注入的数据视图、关闭入口、临时 UI 登记、保存副作用；
- 选出首个拆分对象（优先 `pet_interface` 的一个可独立区域，不按文件大小整体拆）。

### 24-1 `pet_interface` 分段拆分

- 把一个属性/技能/进化区域拆为子场景或子控制器；
- 面板根保留协调职责，子区域不直接写档；
- 迁移全部调用方，删除重复节点路径与旧回调；
- 验证 P1/P2、打开/关闭、保存快照互斥与失败提示。

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

## 4. Phase 25：战斗实体行为切片

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

## 5. Phase 26：平台与发布验证

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

**当前下一步**：**Phase 23-4 `PlayerData` 宠物域只读视图**；Phase 23-2 八族与 Phase 23-3 结算已完成。
**当前不启动**：Phase 23-5。
**23-0/23-1/23-2 产物**：[`pet_level_boundary_matrix.md`](../reference/pet_level_boundary_matrix.md)

- 当前架构：[`architecture.md`](../reference/architecture.md)
- Global 清单：[`global_runtime_inventory.md`](../reference/global_runtime_inventory.md)
- 验收标准：[`acceptance.md`](../reference/acceptance.md)
- 当前状态：[`status.md`](../reference/status.md)
- 长期路线：[`roadmap.md`](roadmap.md)
- 已归档程序记录：[`program_21_33_closeout.md`](../archive/program_21_33_closeout.md)
