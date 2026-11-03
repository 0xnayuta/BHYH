# Phase 23：关卡、宠物与档案数据边界（归档）

> **归档日期**：2026-11-03
> **状态**：Archived；Phase 23-0 ~ 23-5 已完成，阶段验收通过。
> **关联**：[`current-iteration.md`](../roadmap/current-iteration.md)、[`roadmap.md`](../roadmap/roadmap.md)、[`pet_level_boundary_matrix.md`](../reference/pet_level_boundary_matrix.md)、[`pet_domain_contract.md`](../reference/pet_domain_contract.md)、[`archive_session_matrix.md`](../reference/archive_session_matrix.md)、[`status.md`](../reference/status.md)、[`acceptance.md`](../reference/acceptance.md)。

## 1. 阶段范围与结论

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

### 23-4 `PlayerData` 宠物域只读视图试点（已完成）

- 新增 `PetDomainView`：`PlayerData.pet_domain_view()` 返回只读副本/标量，不暴露档案数组；
- 新增 `PetDomainCommand`：`deploy`、`rest`、`commit_growth`，保存失败恢复 `PlayerDataStore` 快照；
- `PetInterface` 的名称列表改用 View；出战/休息与成长果路径改走命令，保存 reason 分别为 `pet_deploy`、`pet_rest`、`pet_growth`；
- `PlayerData` 继续承担加载、补全、快照/恢复与保存聚合；未整体 Resource 化；
- 验证：档案探针 **328/328 PASS**（11.20s）、`check_all` **9/9**（33.45s）、`coop` **33/33**（176.83s）、`scene` **17/17**（153.51s）、`level_1` PASS、全量 **128/128 + 5 SKIP**（300.7s）；
- 契约见 [`pet_domain_contract.md`](../reference/pet_domain_contract.md)。

### 23-5 阶段验收（已完成，Phase 23 已关闭）

- **出口证据**：`BaseLevel` 宠物相关函数由基线 **73 个降至 16 个**；八族生成只经 `PetLevelController`，旧族分派已删除；
- `PlayerData` 宠物域已有 `PetDomainView` 只读边界与 `PetDomainCommand` 显式提交，契约见 [`pet_domain_contract.md`](../reference/pet_domain_contract.md)；
- **存档补全/失败**：`archive_probe_runner` 覆盖规范化幂等、后置条件失败阻断写入、同步/后台写失败、快照恢复与失败可观察；
- **快照互斥**：`LocalCoopPanelProbe` 覆盖快照期间拒绝打开面板、标志清理与恢复后重开；
- **切档/退出**：`identity_stale_write_rejected`、`identity_switch_flushed_old_archive`、`background_exit_flushed`、`session_ended_by_path_switch`、`session_reentry_*` 等通过；
- **运行期**：`pet-runtime`、场景 **17/17**、协作 **33/33**、档案 **328/328**、`level_1` 四阶段 PASS、全量 **128/128 + SKIP 5**；
- **门禁**：`check_all --godot-bin` **9/9**、`health_check` **774 脚本 0/0/0**；
- 首跑完整场景套件时 `level-selection` 出现一次引擎 `RID`/`mem` 瞬态（功能检查全为 true）；隔离复跑与完整复跑均通过，最终 **17/17**。
- 验收结论：Phase 23 出口满足；下一入口为 Phase 24-0 面板契约清单。
