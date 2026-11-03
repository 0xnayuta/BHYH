# 当前工程状态 (Status)

> **定位**：当前版本、运行基线、门禁与已知边界的单一事实源。
> **最后更新**：2026-11-03。历史验证记录已归档到 [`../archive/validation_history_2026.md`](../archive/validation_history_2026.md)；本页只保留当前事实与最近基线。

---

## 1. 版本与运行基线

| 项目 | 值 |
|:---|:---|
| 工程标识 | **造梦西游八荒湮隳（BHYH）** |
| 当前内容版本 | **6.9**（6.5.0.0 基线 + 6.6 / 6.7 / 6.8 / 6.9 回植） |
| 引擎 | Godot **4.7.2**（默认 `mobile`；Web 使用 `forward_plus`） |
| 设计画布 / 默认窗口 | **1280×800 / 1600×1000**（16:10，1.25×；`canvas_items` + `expand`） |
| 主场景 | `res://Scene/other_scene/load_scene.tscn` |
| 工程根 | `source/` |
| Autoload | **11 个注册项**：10 个业务单例 + 1 个编辑器调试桥；注册与职责见 [`architecture.md`](architecture.md) §2 |
| 语言 | GDScript 2.0，优先静态类型 |

版本谱系与归档入口见 [`../archive/README.md`](../archive/README.md)。

---

## 2. 当前门禁与最近验证

门禁名称、命令与通过判据以 [`acceptance.md`](acceptance.md) 为准。

| 验证 | 结果 |
|:---|:---|
| `check_all --godot-bin` | **9/9 PASS**（2026-11-03 最新复跑 **32.78s**） |
| `health_check` | **772 脚本 0 Parse / 0 Error / 0 Warning** |
| `archive_probe_runner` | **303/303 PASS**（一次通过） |
| `scene_probe_runner` | **17/17 PASS**（157.89s，含 `pet-runtime`、`load-guard`） |
| `coop_probe_runner` | **33/33 PASS**（182.53s，含 `LocalCoopPetSlotProbe`、`LocalCoopPetDragonProbe`、`LocalCoopPetPhoenixProbe`、`LocalCoopPetRabbitProbe`、`LocalCoopPetMouseProbe`、`LocalCoopPetNeatProbe` 与 `LocalCoopPetYinTigerProbe`） |
| `level_1` 冒烟 | **PASS，4 阶段，0/0/0** |
| 全量关卡回归 | **PASS 128/128 + SKIP 5，FAIL 0**（最新 302.9s，默认 auto 并发，本轮无重试） |
| PCK 验证包 | **4,200/4,200 可达**；7,628,138,078 字节；sha256 `b0d6d3526256…` |

**边界**：PCK 为验证用 `all_resources` 包的路径闭包，不等于 release 加载、目标设备 VRAM、首帧耗时或最小发布包已验证。

### 最近完成

- Phase 23-3：复核 `LevelSettlement` 的胜败/重战/保存路径；胜利 `_ready` 只提交一次，返回/重战仅在 pending 时 flush，重复点击由 leaving/rechallenge 守卫拦截；失败场景各奖励动作一次保存、失败回滚，重复领取由本地/持久标记拦截。未改生产代码；补强档案探针的装备成功与永久拒绝成功/失败路径，`archive_probe_runner` **303/303 PASS**（11.21s），`check_all` 9/9（32.78s）；生产源码未变，沿用 Phase 23-2 末次 coop 33/33、scene 17/17、全量 128/128 + 5 SKIP。
- Phase 23-2 `PetYinTiger`：新增 `PetYinTigerFamily`；`PetLevelController` 接管八族，`BaseLevel` 移除最后的旧生成分派；`BaseMonster` 升级循环与成长分支改用族规则；`PetInterface` 复用族规则；`Global` 补齐寅虎预载识别、路径与预热；`BaseLevel`/`PetInterface` 死亡别名改由族规则提供；`PlayerData` 载入补全保留到 23-4。验证：`LocalCoopPetYinTigerProbe` 覆盖族规则、P2 升级写回、死亡别名、Global 预热与 `level_1` 双槽生成；`coop_probe_runner` **33/33 PASS**（182.53s），`scene_probe_runner` **17/17 PASS**（157.89s），档案 297/297，`level_1` 4 阶段 PASS，全量 128/128 + 5 SKIP（302.9s，无重试），`check_all` 9/9（35.96s），`health_check` 772 脚本 0/0/0。
- Phase 23-2 `PetNeat`：新增 `PetNeatFamily`；`PetLevelController` 接管龟、虎、龙、凤、兔、鼠、牛七族；`BaseLevel` 删除丑牛 7 个规则函数与生成分支；`BaseMonster` 升级循环新增 `PetNeatFamily.evolve`，修复升级不刷新阶段/技能；`PetInterface` 复用族规则；`BaseLevel`/`PetInterface` 死亡别名改由族规则提供；`PlayerData` 载入补全保留到 23-4。验证：`LocalCoopPetNeatProbe` 覆盖族规则、P2 升级写回、死亡别名与 `level_1` 双槽生成；`coop_probe_runner` **32/32 PASS**（168.53s），`scene_probe_runner` **17/17 PASS**（156.84s），档案 297/297，`level_1` 4 阶段 PASS，全量 128/128 + 5 SKIP（311.0s，无重试），`check_all` 9/9（33.95s），`health_check` 771 脚本 0/0/0。
- Phase 23-2 `PetMouse`：新增 `PetMouseFamily`；`PetLevelController` 接管龟、虎、龙、凤、兔、鼠六族；`BaseLevel` 删除子鼠 7 个规则函数与生成分支；`BaseMonster`/`PetInterface` 复用两阶、30/50 级技能、归一化、进化与活跃名；`BaseLevel`/`PetInterface` 死亡别名改由族规则提供；`PlayerData` 载入补全保留到 23-4。验证：`LocalCoopPetMouseProbe` 覆盖族规则、P2 升级写回、死亡别名与 `level_1` 双槽生成；`coop_probe_runner` **31/31 PASS**（179.34s），`scene_probe_runner` **17/17 PASS**（164.45s），档案 297/297（首跑 1 个瞬态后复跑通过），`level_1` 4 阶段 PASS，全量 128/128 + 5 SKIP（317.2s，`level_35` 一次瞬态重试通过），`check_all` 9/9（36.53s），`health_check` 770 脚本 0/0/0。
- Phase 23-2 `PetRabbit`：新增 `PetRabbitFamily`；`PetLevelController` 接管龟、虎、龙、凤、兔五族；`BaseLevel` 删除月兔 6 个规则函数与生成分支；`BaseMonster`/`PetInterface` 复用族阶段名、技能、归一化、进化与活跃名；`BaseLevel`/`PetInterface` 死亡别名改由族规则提供；保留永久解锁与不可放生逻辑；`PlayerData` 载入补全保留到 23-4。验证：`LocalCoopPetRabbitProbe` 覆盖族规则、P2 升级写回、死亡别名与 `level_1` 双槽生成；`coop_probe_runner` **30/30 PASS**（164.29s），`scene_probe_runner` **17/17 PASS**（163.52s），档案 297/297，`level_1` 4 阶段 PASS，全量 128/128 + 5 SKIP（303.3s，无重试），`check_all` 9/9（34.83s），`health_check` 769 脚本 0/0/0。
- Phase 23-2 `PetPhoenix`：新增 `PetPhoenixFamily`；`PetLevelController` 接管龟、虎、龙、凤四族；`BaseLevel` 删除凤凰族 7 个规则函数与生成分支；`BaseMonster`/`PetInterface` 复用族阶段名、技能、归一化、进化与活跃名；补齐 `BaseLevel`/`PetInterface` 凤凰死亡别名（四阶名与 `朱雀幼灵`/`赤羽朱雀`/`朱雀神君`）；`PlayerData` 载入补全保留到 23-4。验证：`coop_probe_runner` **29/29 PASS**（148.65s，新增 `LocalCoopPetPhoenixProbe` 覆盖族规则、P2 升级写回、死亡别名与 `level_1` 双槽生成）。
- Phase 23-2 `PetDragon`：新增 `PetDragonFamily`；`PetLevelController` 接管龟、虎、龙三族；`BaseLevel` 删除龙族 7 个规则函数与生成分支；`BaseMonster`/`PetInterface` 复用族阶段名、技能、归一化、进化与活跃名；`PlayerData` 载入补全保留到 23-4。验证：`coop_probe_runner` **28/28 PASS**（165.15s，新增 `LocalCoopPetDragonProbe` 覆盖族规则、P2 升级写回与 `level_1` 双槽生成）；`health_check` 767 脚本 0/0/0。
- Phase 23-2 共享槽位边界：`Global.prewarm_active_pet_runtime_resources(slot)`、`get_active_pet_preload_data(slot)` 与 `get_active_pet_preload_paths(slot)` 按槽位解析，预热签名按槽位缓存；`BaseLevel`、`PetLevelController` 与加载页双槽遍历传槽位；慈心妙莲按持有者槽位读写死亡元数据并重建对应槽位；宠物装备加成经 `BaseObject.PlayerData` 槽位解析验证。新增 `LocalCoopPetSlotProbe` 固化三条路径。验证：`coop_probe_runner` **27/27 PASS**（130.78s）；`health_check` 766 脚本 0/0/0；其余门禁见下表。
- Phase 23-2 首批 `PetTiger`：新增 `PetTigerFamily`，`PetLevelController` 通过族规则表接管龟、虎；`BaseLevel` 删除虎族 7 个规则函数与生成分支，兔族阶段改用通用 `_pet_stage_for_level`；`BaseMonster` 删除虎族重复进化，`PetInterface` 虎族检测/归一化/进化/死亡别名复用规则。验证：`check_all` 9/9、`health_check` 766 脚本 0/0/0、`pet-runtime` PASS、档案 297/297（首跑瞬态重跑）、场景 17/17、协作 26/26、`level_1` PASS、全量 128/128 + 5 SKIP（292.1s）；临时探针覆盖 1P 虎族 2 阶生成与 P2 虎族写回。
- Phase 23-1：新增 `PetLevelController` 与 `PetTurtleFamily`，`BaseLevel` 龟族生成/归一化/进化/路径/技能规则迁出；`BaseMonster` 删除龟族重复实现，现有各族进化与成长写入显式接收槽位档案，修复 P2 升级写回 1P；`PetInterface` 龟族逻辑复用同一规则。验证：`check_all` 9/9、`health_check` 765 脚本 0/0/0、`pet-runtime` PASS、档案 297/297、场景 17/17、协作 26/26（含新增 2P 写回断言）、`level_1` PASS、全量 128/128 + 5 SKIP（298.8s，默认 auto）；临时定向探针覆盖 1P/2P 龟族 2 阶生成、死亡抑制/复活与 P1/P2 活跃名隔离，已删除。
- Phase 23-0：完成 8 族、30 个召唤场景的 `BaseLevel` 宠物生成/归一化/进化/技能/路径/槽位调用面调查，产出 [`pet_level_boundary_matrix.md`](pet_level_boundary_matrix.md)；首批选择 `PetTurtle`，23-1 采用 `PetLevelController` + `PetTurtleFamily`。静态确认 2P 预热、凤凰别名、寅虎预热门禁与法宝复活槽位风险。验证：`pet-runtime` PASS，`coop_probe_runner` 26/26；未改 `source/`，23-1 未启动。
- Phase 22-4：新增 `contract_scan.py` 的 `global_surface_boundary` 规则与 `scripts/global_surface_baseline.json`，冻结 65 字段与 120 个 `add` 入口；`--self-test` 坏样本 2 / 好样本 4，`--fail-on-error` ERROR=0；剩余 65 字段已在 `global_runtime_inventory.md` §2.10 登记所有者、理由与出口。Phase 22 已收口。
- Phase 22-3D-2：§2.6/§2.9 共 21 个字段迁出或删除；`file_num` 收敛为 `MainSet.FILE_VALUE`，锻造/分解状态归 `ForgeFactory`，Ldl 模式归 `UiRuntime`，连击计数归 `CombatPoolRuntime`，玩家朝向归 `RunContext`，场景槽位归对应工厂与 `SceneFlow`。`check_all` 9/9、`ui-factories`/`run-context` 探针、档案 297/297、场景 17/17、协作 26/26、`level_1` PASS；全量回归未作为本批结论。
- Phase 22-3D-1：`is_frist`、`is_show` 迁入 `UiRuntime` 一次性消费；`box_count` 迁入 `BackpackFactory` 点击冷却；`_last_combo_value`、`_pending_combo_milestones` 与 `check_combo_milestone` 迁入 `CombatPoolRuntime`。`check_all` 9/9、`ui-factories` 探针、档案 297/297、场景 17/17、协作 26/26、`level_1` PASS；全量回归未作为本批结论。
- Phase 22-3C：关卡计时、`last_level_path`、最大连击、三太子/星宿选择、玲珑塔三种挑战模式、玩家受击计数与结算类型迁入 `RunContext`；删除 5 个无消费者或重复真源字段；星座进度只以 `PlayerData` 为真源。`run-context` 与 `level-selection` 探针、`check_all` 9/9、档案 297/297、场景 17/17、协作 26/26、`level_1` / `level_llbt` / `level_17` 冒烟 PASS；全量回归未作为本批结论。
- Phase 22-3B：19 个法宝实例字段确认零引用后删除；场景路径表、预载路径与 xianyjp 预热分派迁入 `MagicWeaponRuntime`；`magic-weapons` 探针、`check_all` 9/9、档案 297/297、场景 PASS、协作 26/26、`level_1` PASS；全量回归未作为本批结论。
- Phase 22-3A：云存档登录状态从 `Global` 迁入 `MemoryClass` 持有的 `CloudSession`；`Global.cloud_save_*` 与认证冷却字段已删除；`CloudSession` 逻辑探针、`check_all` 9/9、档案 297/297、场景 PASS、协作 26/26、`level_1` PASS；全量回归未作为本批结论。
- Phase 33：装备数据契约完成；旧 `all_equipment_data.gd`、`all_equipment.gd`、字典入口与 `AE` Autoload 已删除；运行时只加载 `equipment_catalog.tres`。
- 最新宠物预热门禁与寅虎动作帧修复：`convert_monster_action_views.py --check` **5/5**，`pet-runtime` 场景探针 PASS，全量场景探针 **17/17**、`coop_probe_runner` **26/26**、`level_1` PASS；完整记录见归档。
- AnimationMixer String 状态轨道警告修复：183 个场景、**412** 条单键 value track（`animation` 296 + `playing` 116）改为离散更新；新增 `contract_scan` 的 `ANIM_TRACK_STATE_CONTINUOUS` 规则与 `pet-runtime` 动画缓存探针；全量回归 **128/128 + SKIP 5**（304.5s，0/0/0）、场景探针 **17/17**、`check_all --godot-bin` **9/9**。
- 关卡回归瞬态修复：保留失败关首轮 `errors/stages/log`，过滤三类已验证 headless dummy renderer 噪声，阶段清场后等待物理帧再传送；全量回归 **128/128 + SKIP 5，302.07s，无重试**。
- Phase 31/32/33 的实施记录、Phase 30-4 决策页和 2026 验证历史已归档，不再占用当前参考页。
- 文档与工具链收敛：活跃 reference 页面只保留当前契约；`scripts/README` 补齐脚本索引；`docs_audit.py` 检查 **703 条链接 / 0 缺失 / 0 索引缺项**；未修改 `source/`。

---

## 3. 当前已知边界

1. **平台**：Spine GDExtension 当前仅入库 Windows x86_64；21-2A 最低设备确认与 21-2B 平台测量仍暂缓。
2. **发布**：现有 PCK 是验证包，不是最小发布包；release 启动、目标设备峰值 VRAM 与首帧耗时需单独设备实测。
3. **公开仓库**：不包含第三方素材；公开 clone 的缺失资源提示属于预期。
4. **存档**：加密 JSON、`.tmp`/`.bak` 原子写与当前格式补全不变；不引入跨版本迁移链。
5. **架构**：Autoload 与 `Global` 普通子节点运行时是遗留基线；新增需按 [`autoload_boundary_matrix.md`](autoload_boundary_matrix.md) 评审。
6. **文档**：历史验证只在归档中保留，当前页不复制逐批计数。

---

## 4. 目录与规模

工程根为 `source/`，目录职责见 [`architecture.md`](architecture.md) 与 [`../../README.md`](../../README.md)。具体脚本/场景/资源数量随迭代变化，不作为本页契约；需要时从当前工作区重新统计，不使用历史数字。
