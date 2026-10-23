# BHYH Current Iteration

> **用途**：维护当前候选阶段、恢复条件与实施顺序；项目状态和长期阶段顺序以 [roadmap](roadmap.md) 为准。
>
> **当前状态**：**6.9-1 至 6.9-5 已完成**；6.9 整体待 6.9-6 场景与全量验收收口，尚未验收。当前内容版本仍为 **6.8**；下一批次为 6.9-6 场景/资产/验收。
>
> **归档口径**：6.6–6.8 的逐文件台账、原始验收记录和临时报告不进入本页。本页只维护 6.9 的范围、依赖、实施顺序与验收入口。

---

## 0. 参考入口

- 迁移方法与红线：[`../guides/migration_playbook.md`](../guides/migration_playbook.md)
- 当前工程状态与基线：[`../reference/status.md`](../reference/status.md)
- 命名与目录约束：[`../standards/naming_standard.md`](../standards/naming_standard.md)
- Godot 设计约束：[`../standards/godot_design_standard.md`](../standards/godot_design_standard.md)
- 机器报告目录：[`../reports/README.md`](../reports/README.md)

6.6–6.8 已作为 6.8 基线的一部分交付；本页不重放历史台账，也不把历史报告当作 6.9 已通过的证据。

---

## 1. 当前候选阶段：6.9 补丁回植

### 1.1 基线、目标与边界

**基线**：

- `base`：6.8 上游反编译参考脚本；
- `ours`：当前 `source/` 中已完成命名、类型、契约和运行时治理的 6.8 工程；
- `theirs`：6.9 参考反编译脚本与场景。

**目标**：按 6.9 公告修复 12 项双人、自动战斗、任务与掉落问题，同时保留当前工程的现代 GDScript 规范、节点命名、数据契约与资源 UID 策略。

**范围结论（预检后）**：

- 6.9 是**补丁型更新**，不是新的整包内容版本；
- 没有新增生产资源、生产场景或新角色内容；
- 生产代码差异集中在 **20 个脚本**与 **2 个场景**；
- 新增的 6 个 PCK 条目全部是测试探针及其 remap/scene，不作为生产脚本移植；
- `project.godot` 未出现在变更清单中，不整体覆盖；
- 当前 `source/` 在 6.9 验收完成前继续保持 6.8 状态。

**边界**：

1. 禁止把 6.9 反编译文本整文件覆盖到当前工程；
2. 以 6.8 上游为 `base`、当前工程为 `ours`、6.9 为 `theirs` 做三方语义合并；
3. 新文件、测试探针和场景改动必须按当前架构改写，不直接复制；
4. 只有新增或变化的生产文件才进入 `source/`；上游 `Test/`、`.remap`、`.uid_cache.bin` 和旧导入缓存不得进入生产工程；
5. 版本号、`status.md` 与路线图状态只在 6.9 验收通过后更新；
6. 本地二进制路径、解密沙盒、密钥和临时台账不写入仓库。

### 1.2 预检证据与范围

目标二进制已完成只读预检、PCK 目录解密校验与脚本反编译；反编译报告为 **940/940 成功，0 失败**。

| 项目 | 6.8 基线 | 6.9 目标 | 结论 |
|:---|:---:|:---:|:---|
| PCK 条目 | 40,144 | 40,150 | 净增 6 |
| 新增条目 | — | 6 | 全部为 `Test` 探针及 remap/scene |
| 删除条目 | — | 0 | 无生产文件删除 |
| 修改条目 | — | 24 | 21 个 `.gdc` + 2 个 `.scn` + 1 个 `uid_cache.bin` |
| 生产脚本修改 | — | 20 个 | 另 1 个 `.gdc` 为测试探针 |
| 生产场景修改 | — | 2 个 | `AutoBattleConfig`、`GameAnnouncement` |
| 新增生产资源 | — | 0 | 无新增美术、音频、字体或生产场景 |
| 目标引擎 | — | `4.7.stable.custom_build` | PCK 声明 4.7；当前编辑器 4.7.2，施工前复核兼容性 |

**变更主题**：6.9 公告列出的 12 项修复构成范围基线：

1. 修复双人模式使用宝箱卡死；
2. 修复双人模式丹药只对 1P 生效；
3. 修复双人模式法宝洗练；
4. 日常任务“八仙尽伏”改为每完成一轮可领取一次；
5. 修复双人模式忘川河异常死亡；
6. 修复自动战斗第三个技能异常；
7. 自动战斗支持双人模式；
8. 修复双人模式万灵图录只对 1P 生效；
9. 修复双人模式炼体只对 1P 生效；
10. 修复双人模式宠物 2P 没有解锁；
11. 双人模式宠物背包互通；
12. 修复哪吒和玉兔装备不掉落。

> 公告是范围基线，不是实现证明。第 3、6 项没有独立的同名文件级 diff，施工时必须先用 2P 洗练与自动战斗第三技能场景复现根因，不能只根据公告文案推断修复点。

**生产文件映射**（上游路径 → 当前路径）：

| 功能域 | 6.9 上游文件 | 当前目标路径 |
|:---|:---|:---|
| 基础/任务 | `Global.gdc` | `source/global.gd` |
| 基础/任务 | `Script/MemoryClass/PlayerData.gdc` | `source/Script/memory_class/player_data.gd` |
| 基础/任务 | `Script/MemoryClass/main_set.gdc` | `source/Script/memory_class/main_set.gd` |
| 基础/任务 | `Script/Task/BasicTask.gdc` | `source/Script/task/basic_task.gd` |
| 基础/任务 | `Script/Task/TaskTitle.gdc` | `source/Script/task/task_title.gd` |
| 双人/角色 | `Script/Coop/LocalCoop.gdc` | `source/Script/coop/local_coop.gd` |
| 双人/角色 | `Script/Base/BaseRoleProperies.gdc` | `source/Script/base/base_role_properies.gd` |
| 双人/角色 | `Script/Pellet/BasicPellet.gdc` | `source/Script/pellet/basic_pellet.gd` |
| 双人/角色 | `Script/Monster/Monster_130.gdc` | `source/Script/monster/monster_130.gd` |
| 双人/角色 | `Script/Level/Level_17.gdc` | `source/Script/level/level_17.gd` |
| 双人/角色 | `Script/Level/Boat.gdc` | `source/Script/level/boat.gd` |
| 自动战斗 | `Scene/AutoBattleConfig.gdc` | `source/Scene/auto_battle_config.gd` |
| 自动战斗 | `Script/Base/BaseHero.gdc` | `source/Script/base/base_hero.gd` |
| 掉落/装备 | `Script/Data/YutuEquipmentData.gdc` | `source/Script/data/yutu_equipment_data.gd` |
| 掉落/装备 | `Scene/OtherScene/LevelInfo.gdc` | `source/Scene/other_scene/level_info.gd` |
| 掉落/装备 | `Script/Base/BaseMonster.gdc` | `source/Script/base/base_monster.gd` |
| 掉落/装备 | `Script/Monster/Monster_1404.gdc` | `source/Script/monster/monster_1404.gd` |
| 掉落/装备 | `Script/Monster/Monster_1406.gdc` | `source/Script/monster/monster_1406.gd` |
| 掉落/装备 | `Script/Monster/Monster_1407.gdc` | `source/Script/monster/monster_1407.gd` |
| 公告/UI | `Script/Main_menu/GameAnnouncement.gdc` | `source/Script/main_menu/game_announcement.gd` |
| 场景 | `AutoBattleConfig.scn` | `source/Scene/auto_battle_config.tscn` |
| 场景 | `GameAnnouncement.scn` | `source/Scene/main_menu/game_announcement.tscn` |

> **基线补齐**：6.9 变更清单不包含 `Level_bxgh.gdc`，但当前 6.8 移植基线缺少八仙尽伏的击败上报与任务进度链路；6.9-2 同时补回该基线调用，否则 6.9 的“每轮领取”没有可工作的进度来源。

**明确不移植**：

- `Script/Test/YutuEquipmentProbe.gd` 的上游改动；
- 新增的 `AllRoleEquipmentDropProbe`、`LocalCoopChestUseProbe` 及其 `.remap`/`.scn`；
- `godot/uid_cache.bin`、`.godot` 缓存、`.remap` 和旧导入产物；
- 6.9 反编译输出中的测试代码、调试输出和临时命名。

上述测试探针可以作为**一次性可执行规格**在仓库外复现，或在现有 `scripts/coop_probes/` 中按当前接口改写；不得直接复制进 `source/`。

### 1.3 实施顺序与任务

顺序为 **6.9-1 → 6.9-2 → 6.9-3 → 6.9-4 → 6.9-5 → 6.9-6**。每个子阶段只提交一个可编译、可回滚的原子批次；基础设施和共享 API 必须先于消费者。

**当前进度**：

| 批次 | 状态 | 说明 |
|:---|:---|:---|
| 6.9-1 参考映射 | 完成 | 临时台账，不进入仓库 |
| 6.9-2 基础数据/任务/设置 | 完成 | `ecb6137`、`1f2de22` |
| 6.9-3 掉落/装备 | 完成 | `4e3192e`、`3a666ee` |
| 6.9-4 双人共享运行时 | 完成 | `8897e28`、`3b3356c`、`0afabd4` |
| 6.9-5 自动战斗/UI/场景 | 完成 | `b3b088b`、`1e98c36` |
| 6.9-6 场景/验收收口 | 待开始 | 下一批次；最终验收 |

#### 6.9-1：参考工程与逐文件映射 [已完成]

- 固定 6.8/6.9 参考脚本、场景和 manifest，建立临时三方台账；
- 对 24 个修改条目逐项标记：生产脚本、生产场景、生成缓存、测试探针；
- 对 6 个新增条目标记为“测试专用”，不进入生产；
- 确认 20 个生产脚本在当前工程中的真实路径、类名、依赖和命名差异；
- 输出每个文件的处置结论：移植、适配、忽略、仅验收。

**出口**：所有变化文件都有处置结论；没有未映射的生产文件；测试探针不进入 `source/`。

**实施结果**：30 个新增/修改条目全部映射；20 个生产脚本与 2 个生产场景均有当前路径；6 个新增条目全部为测试专用；1 个 `uid_cache.bin` 标记为生成缓存；未发现未映射的生产文件。

#### 6.9-2：基础数据、任务与设置 [已完成]

- 补回当前 6.8 基线缺失的八仙尽伏日常链路：
  - `PlayerData`：日期进度、八位 Boss 击败去重、完成判定与领取入口；
  - `Level_bxgh`：Boss 死亡时记录当日击败并保存；
  - `BasicTask`：加入八仙尽伏任务条目与逐 Boss 进度展示；
  - `TaskTitle`：八仙尽伏按实际击败进度判定完成；
- 按 6.9 语义将“八仙尽伏”从一次性领取改为每完成一轮可再次领取；领取后清空本轮击败进度；
- `main_set`：补充自动战斗按槽位保存技能配置的键与默认值：
  - `AutoBattleSkillsBySlot`
  - `AutoBattlePlayerSlot`
- 对旧配置缺失新键的情况使用默认值，不引入新的存档迁移链；
- 保持当前 `DataKeys`、强类型访问和资源契约。

**出口**：单人与双人模式下任务可重复领取；旧配置读取不报错；自动战斗设置键可被后续批次消费。

**实施结果**：八仙尽伏链路与每轮领取语义已合入；自动战斗槽位默认键已合入；定向 headless 冒烟验证两轮领取与任务标题完成判定，七维门禁 7/7 通过。

#### 6.9-3：掉落、装备与关卡预览 [已完成]

- `YutuEquipmentData`：新增 `expand_drop_entries()`，对同一掉落项同时保留哪吒 ID 与玉兔映射 ID；保持输入数组不变、扩展幂等；移除仅按角色返回单一 ID 的旧路径；
- `Global.add_choose_item`：统一使用扩展后的掉落条目，不再按 `PlayerData.Myself == 7` 分支；
- `LevelInfo`：关卡预览始终列出哪吒与玉兔两套装备/制作书，不修改原始关卡表；
- `BaseMonster`：普通掉落与独立掉落都通过扩展列表抽取，避免只掉其中一个角色；
- `Monster_1404`、`Monster_1406`、`Monster_1407`：仙音岛/仙幻岛/仙树岛制作书不再绑定玉兔角色；
- 保留掉落概率、难度倍率、Boss 独立掉落和现有 `fall_item` 契约；
- 所有临时数组必须复制，不得原地修改源表。

**出口**：任意角色、单人或双人配置下，哪吒/玉兔装备与制作书均可正确预览、掉落、进入地面和进入选择框；重复调用不产生重复条目。

**实施结果**：扩展、选择框、关卡预览、普通/独立怪物掉落与三座仙岛制作书已统一；同时修正 `Global.CurrentLevel` 为实际属性 `current_level`，避免运行时空引用。仓库外等价探针覆盖两角色、三座仙岛、普通/独立掉落与源表不变，0 failures；七维门禁 7/7 通过。

#### 6.9-4：双人共享进度与运行时 [已完成]

- `LocalCoop`：
  - 扩展 `BAG_KEYS` 到宠物背包，并实现共享宠物背包合并；
  - 新增 `canonical_profile_for_slot()`，保证视图交换后 1P/2P 仍指向稳定档案；
  - 新增炼体/万灵图录共享合并，数值键取最大值、字典递归合并；
  - 新增丹药计数同步与双端属性刷新；
- `BaseRoleProperies`：炼体、万灵图录和共享属性读取改为通过 `LocalCoop` 的 canonical 档案；
- `BasicPellet`：丹药计数统一通过 `LocalCoop.increment_pellet_count()`，单人和双人共享同一入口；
- `Monster_130`：月兔解锁同时作用于 1P/2P，保留提示/存档；
- `Level_17`：忘川河消耗与死亡处理按当前玩家槽位读取档案/属性，死亡值使用合法边界；
- `Boat`：按所有存活玩家维护上船集合，不再只跟踪单个 `player`，离船/死亡/场景切换时清理。

**出口**：双人模式下丹药、炼体、万灵图录、宠物解锁、宠物背包、忘川河和船只行为均对两个槽位生效；视图交换、玩家死亡和重载后无悬挂引用或重复数据。

**实施结果**：共享宠物背包、炼体/万灵图录合并、canonical 档案、丹药双端计数、月兔双槽解锁、忘川河槽位处理与船只多玩家跟踪已合入。共享进度定向探针 0 failures；现有双人矩阵 15/15 PASS；Level 17 关卡冒烟 PASS；七维门禁 7/7 通过。

#### 6.9-5：自动战斗与 UI/场景 [已完成]

- `AutoBattleConfig`：
  - 增加 1P/2P 槽位选择与 `player_slot` 状态；
  - 角色、技能、已学技能和已选技能按槽位/角色读取；
  - 切换槽位或保存前先持久化当前技能配置，避免配置串槽；
  - 选项持久化到 `AutoBattlePlayerSlot`；
- `BaseHero`：
  - 自动战斗读取当前角色的 `LocalCoop` 档案与槽位技能；
  - 在进入技能/帧处理前增加 `is_inside_tree()` 与 `current_scene` 守卫，修复第三技能异常并避免场景切换期访问失效；
- `AutoBattleConfig.tscn`：按当前场景结构和命名增加 `PlayerSlot` 选项节点；
- `GameAnnouncement`：加入 V6.9 公告文本与版本按钮；
- `GameAnnouncement.tscn`：增加 V6.9 按钮并连接现有公告刷新逻辑；
- `Global`：宝箱选择、奖励框、文本提示等在暂停的双人 UI 中设置 `PROCESS_MODE_ALWAYS`，且仅在实例有效时设置；
- 场景改动先转换为可比较文本，再按当前 `.tscn` 节点命名和 UID 规则合入；禁止直接复制压缩场景。

**出口**：1P/2P 自动战斗均可保存并执行各自技能；第三技能不再异常；双人暂停状态下宝箱/奖励弹窗可完成且不提前解除暂停；公告能显示并切换到 V6.9。

**实施结果**：自动战斗槽位/技能配置、BaseHero 守卫、暂停弹窗和 V6.9 公告已合入。自动战斗槽位探针、UI 探针均 0 failures；双人矩阵 15/15 PASS；七维门禁 7/7 通过。

#### 6.9-6：场景、资产与验收收口

- 仅处理 6.9 实际变化的 2 个生产场景；没有新增生产资产；
- 检查新增/修改节点的 `PascalCase` 名称、`get_node` 引用大小写和 `%UniqueName`；
- 不复制 `uid_cache.bin`、`.remap` 或旧 `.import`；由 Godot 重新导入并生成 UID；
- 将 6.9 测试探针改写为仓库外临时规格，或在现有 `scripts/coop_probes/` 中增加等价用例；
- 所有临时探针、解包目录和逐文件台账在验收后移除，不进入提交。

**出口**：场景引用完整、UID 无重复、导入无缺失；临时产物已清理；验收矩阵全部有结果。

### 1.4 验证、失败处置与完成条件

**静态与引擎门禁**：

```bash
python scripts/check_all.py --skip-engine
python scripts/check_all.py --godot-bin <godot>
python scripts/health_check.py --project source --godot-bin <godot>
python scripts/level_regression_all.py --jobs 4 --timeout 90
python scripts/level_test_runner.py --godot <godot> --level res://Scene/level/level_1.tscn
python scripts/coop_probe_runner.py --godot <godot>
python scripts/convert_atlas_metadata.py --check
```

**定向验收矩阵**：

| 场景 | 必须验证 |
|:---|:---|
| 双人宝箱 | 2P 打开背包/宝箱、暂停状态、奖励窗口、消耗品只扣一次、关闭后暂停状态正确恢复 |
| 丹药 | 1P/2P 分别服用 1–5 品丹药，计数、属性刷新和界面显示同步 |
| 法宝洗练 | 2P 洗练使用 2P 档案，不写回 1P；视图交换后仍正确 |
| 八仙尽伏 | 完成一轮后可领取，领取后本轮进度重置，可继续下一轮 |
| 忘川河 | 1P/2P 进入、死亡、扣道具与场景切换无异常 |
| 自动战斗 | 1P/2P 各自的第三技能、技能槽、保存/重载与暂停状态 |
| 万灵/炼体 | 双人共享或 canonical 属性读取符合设计，1P/2P 均生效 |
| 宠物 | 2P 解锁月兔；宠物背包双端可见、合并与保存 |
| 装备掉落 | 哪吒/玉兔装备与制作书在预览、普通掉落、独立掉落、地面物品和选择框中均正确 |
| 公告/场景 | V6.9 公告按钮、AutoBattleConfig 槽位控件、节点路径和 UI 缩放 |

**验收标准**：

- 七维门禁全部通过；
- 完整本地素材工作区 0 ERROR / 0 WARNING；
- 关卡回归通过，或 changed-only 覆盖等价；
- 双人探针矩阵全部 PASS；新增 6.9 定向用例全部 PASS；
- 所有 20 个生产脚本和 2 个场景都有处置结论；
- 没有上游测试脚本、缓存、临时探针或旧路径映射进入提交；
- 验收后再更新 `reference/status.md`、`roadmap.md` 与版本标识。

**失败处置**：

- 某个修复的根因无法用 6.9 diff 解释时，先补最小复现，不以公告文案代替证据；
- 三方冲突按当前架构和产品行为裁决，不机械选择 `ours`/`theirs`；
- 共享状态、暂停处理和场景生命周期属于高风险路径，失败时回退整个逻辑批次，不保留新旧双路径；
- 需要新增生产 API 时先评审依赖面，不在修复批次中顺带扩张架构。

### 1.5 完成条件

6.9 记为完成必须同时满足：

1. 20 个生产脚本与 2 个生产场景全部按当前架构合入；
2. 12 项公告修复均有可复现的行为证据；
3. 静态门禁、引擎健康检查、关卡回归、双人探针和 Atlas 校验通过；
4. `source/` 无临时探针、缓存、旧 `.import` 或未映射文件；
5. `reference/status.md` 更新为 6.9 基线，且路线图/当前迭代状态同步；
6. 未执行或未认证的边界明确记录，不把规划、反编译成功或单测通过当作全量验收。

---

## 2. 后续候选阶段（暂缓）

6.9 完成前不启动新的内容版本迁移。之后按 [roadmap](roadmap.md) 的技术债与设计规范方向推进，优先顺序由用户确认：

- `global.gd` 与字典数据向 Resource/服务/强类型入口拆分；
- 13 个 Autoload 的耦合评估与新增准入；
- `_bundled` 场景转原生文本场景；
- 深层节点路径与旧导入结构的专项治理；
- Godot 设计规范在新代码中的持续落地。

这些项目独立排期，不与 6.9 补丁修复混在同一提交。

---

## 3. 恢复规则

- 本页是 **6.9 规划与实施入口**，不是完成记录；本轮只完成预检与规划，未启动实现。
- 6.9 实施须由用户明确确认后开始；不得因反编译成功、门禁通过或时间推移自动进入实施。
- 6.9 未通过验收前，当前内容版本保持 6.8，`source/` 不声明 6.9。
- 恢复实施时，先复核 6.9 目标二进制、PCK 布局、反编译输出和当前工程门禁；任一前置不成立则暂停。
- 本地二进制、解密沙盒、密钥、临时路径与逐文件台账不进入仓库。
