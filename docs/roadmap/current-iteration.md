# BHYH 当前候选迭代

> **状态**：**Phase 38 7.4 内容回植（38-0、38-1、38-2 完成，38-3 待启动）**。Phase 37 的 7.3 内容回植与 37-6 缺口修复已完成（37-0~37-6；L3 已通过；PCK/release 暂缓）；Phase 36 的 7.2 L3 收口已完成、待发布验证；Phase 35 的 7.1 L3 收口已完成、待发布验证；Phase 22 / 23 / 24 / 25 / 27 已完成并归档；Phase 34 7.0 内容回植已完成、待发布验证；Phase 26 平台与发布验证长期暂缓；7.3/7.4 PCK/release 暂缓。
> **版本**：7.3 内容基线；7.4 回植进行中（38-0/38-1/38-2 完成），尚未升级版本标记。
> **当前基线**：[`global_runtime_inventory.md`](../reference/global_runtime_inventory.md)、[`architecture.md`](../reference/architecture.md)、[`status.md`](../reference/status.md)、[`acceptance.md`](../reference/acceptance.md)。
> **历史指针**：归档文档中的 `current-iteration.md §1.2` 指向本页“跨阶段不变量”；`§4`、`§5C`、`§5D` 指向已迁移的批次记录，完整内容见 [`../archive/README.md`](../archive/README.md)。

---

## 1. 当前状态与边界

### 1.1 已完成阶段（归档）

| 阶段 | 状态 | 归档 |
|:---|:---|:---|
| Phase 22 `Global` 状态与入口契约 | 完成并归档 | [`iteration_22_global_state_boundary.md`](../archive/iteration_22_global_state_boundary.md) |
| Phase 23 关卡、宠物与档案数据边界 | 完成并归档 | [`iteration_23_pet_domain_boundary.md`](../archive/iteration_23_pet_domain_boundary.md) |
| Phase 24 UI 与成长命令边界 | 完成并关闭 | [`iteration_24_ui_growth_boundaries.md`](../archive/iteration_24_ui_growth_boundaries.md) |
| Phase 25 战斗实体行为切片 | 完成并关闭 | [`iteration_25_combat_behavior.md`](../archive/iteration_25_combat_behavior.md) |
| Phase 27 Theme 与字体契约收敛 | 完成并关闭 | [`iteration_27_theme_font_convergence.md`](../archive/iteration_27_theme_font_convergence.md) |
| Phase 26 平台与发布验证 | 长期暂缓 | 见 §2 |

阶段产物与当前契约：

- 宠物调用面：[`pet_level_boundary_matrix.md`](../reference/pet_level_boundary_matrix.md)；宠物域 View/命令：[`pet_domain_contract.md`](../reference/pet_domain_contract.md)；
- 面板操作者/命令/保存边界：[`ui_panel_contract_matrix.md`](../reference/ui_panel_contract_matrix.md)；
- 战斗行为与探针映射：[`combat_behavior_matrix.md`](../reference/combat_behavior_matrix.md)；
- Theme/字体事实：[`theme_font_inventory.md`](../reference/theme_font_inventory.md)、[`ui_theme_contract.md`](../reference/ui_theme_contract.md)、[`typography_tokens.md`](../reference/typography_tokens.md)。

### 1.2 跨阶段不变量

1. 不夹带玩法变更：数值、时序、掉落、输入映射与存档格式不在架构/文档批次中改变。
2. 不新增 Autoload、不新增 `Global` 业务字段、不新增 `add` 系门面；新增能力先证明普通节点/`RefCounted`/`Resource`/静态工具不足。
3. 定义与实例分离：静态定义走 Resource/Catalog；玩家档案保持加密 JSON、`DataKeys` 与 `ensure_*`；不把 `PlayerData.player_data` 整体 Resource 化。
4. 失败显式：缺资源、无来源、保存失败、加载失败、过期回调必须报告给拥有者；不默认 1P、不猜旧路径、不静默成功。
5. 回滚通过版本控制，不保留永久双实现、兼容 facade 或双写路径。

### 1.3 Phase 35 7.1 内容回植（完成，L3 已收口）

- **范围锁定**：目标 7.1；7.2/7.3 分别独立立项，不混入本阶段。
- **35-0 完成**：7.0/7.1 清单差集（新增 34、修改 41、删除 0），7.1 反编译参考源码与 19 个变更/测试场景，逐文件台账生产未映射 0，资源差异 0。
- **35-1 完成**：`PlayerData` 宠物装备强化上限、`MainSet` 技能特效透明度、`RoleSkillOpacity`、`RoleAttackMechanism`、`BaseMonster` 的 `yyb` 觉醒眩晕/5 倍天雷，以及 `SkillDamageFormulaData` 文本。
- **35-2 完成**：Longnv 7.1 技能数据、觉醒冷却、冲刺窗口/无敌、分刃、暂停层与 `LongnvScreenStorm` 增频；新增 `longnv-71` 运行时规格探针。
- **35-3 完成**：`ContinentMonsterGrowth`、关卡机关 `RoleAttackMechanism`、9 个关卡场景的机关接入、Level 5/28/34/75、北俱芦洲怪物/地形、三太子受击入口、`map_7`/`map_8` 开放范围；新增 `longnv-mechanism` 运行时规格探针。
- **35-4 完成**：GameSet 技能透明度、V7.1 公告、自动战斗角色 8 名称、觉醒浮层小龙女/玉兔/白龙描述、`zd_skill` 角色 8 觉醒按钮与玉兔冲刺无敌；新增 `menu-ui-71` 运行时规格探针。
- **L3 收口完成**：全量场景 23/23、全量关卡 128/128 PASS + 5 SKIP、双人 37/37、档案 344/344、命名/白名单与构建资源同步通过；PCK/release 与最低配置/其他平台验证继续暂缓。
- **发布边界**：PCK/release 与最低配置/其他平台验证暂缓，待最终发布统一执行；当前版本标记仍以工程配置为准。

### 1.4 Phase 36 7.2 内容回植（完成，L3 已收口）

- **目标**：7.2 内容回植；base 为 7.1 反编译参考，ours 为当前 7.1 治理工程，theirs 为 7.2 反编译参考。
- **36-0 完成**：参考源码/场景与逐文件台账；989/989 脚本、8/8 变更场景文本化；生产未映射 0。
- **36-1 完成**：7.2 PCK 不含年兽原始 PNG；46 张图已从 ctex 解码为 RGBA8 PNG（非 VRAM 纹理）并归一化到 `source/Art/pet/pet_nian`；4 阶帧资源、21 JSON / 20 BIN、shader、`export_raw_roots` 已接入；原始数据清单 1033 文件；`xydxq` 7.2 描述已迁移到装备构建源。
- **36-2 完成**：6 个 PetNian 脚本 + 4 个召唤场景 + `FirstBatchAwakenArea` / `NeZhaAwakenWheel` 已按当前 API 适配；修复 `NeZhaOfficialParts.load_set` 切换部件集时的旧帧索引越界；新增 `pet-nian` 运行时探针，覆盖 1–4 阶场景、帧资源、parts 与效果。
- **36-3 完成**：新增 `PetNianFamily`；`PlayerData` 默认条目与 `ensure_pet_nian`、档案载入/规范化链、PetInterface 出战/升级/预览、BaseRole HUD 头像/技能/死亡别名、BaseThroughLevel/PetLevelController 生成与 2P 槽位、BaseMonster 经验成长、SummonBaseMonster 死亡持久化全部接入；`pet-nian` 探针扩展档案与 HUD，新增 `LocalCoopPetNianProbe`。
- **36-4 完成**：`NeZhaHero` 接入 `nz_hlqg` 双火轮（2× 伤害、8 秒/8 段、环绕后投掷）；`Role1` 重斩觉醒动作与三道地裂（2×/4×/8×、霸体）；`Role2` 玄冰阵五段冰刺与冰域（末段冰冻 2 秒）；`YutuHero` 月魔舞三月影（主体 1.5×、月影 0.7×、主体双倍月印）；`skill_awaken_popup` / `zd_skill` / `SkillDamageFormulaData` 接入四个新觉醒 ID 与说明；`awaken-72` 探针覆盖上述路径、一阶觉醒石与技能面板按钮。
- **36-5 完成**：`Global` 接入年兽出战预载（召唤场景/帧/头像，空子弹场景安全跳过）；`GameAnnouncement` 接入 V7.2 文案与版本按钮；`dj_sell` 喜鹊改为可叠加、上限 24 小时（含活动 Buff 刷新）；`Transmogrified` 补充沙僧幻化项并聚合翅膀/头衔；`Role_8` 昵称上移；新增 `menu-ui-72` 探针覆盖预载、公告、喜鹊、幻化与昵称。
- **36-6 完成**：L3 收口通过 `check_all` 9/9、`health_check --no-cache` 806 脚本 0/0/0、全量关卡回归 128/128 + 5 SKIP、场景探针 26/26、双人矩阵 38/38、档案探针 344/344、`level_1` 四阶段 0/0/0；原始数据/Atlas/帧序列同步校验通过。
- **后续批次**：无；Phase 36 已关闭，PCK/release 与最低配置/其他平台验证按用户决策暂缓。
- **边界**：7.2 生产脚本与场景差异已收口；`addons/bone_export/export_plugin.gd` 属第三方插件，按仓库边界不修改；`Script/Test` 仅作规格，不进入生产；PCK/release 实际导出与最低配置/其他平台 VRAM/首帧耗时未验证；7.3 已由 Phase 37 完成。

### 1.5 Phase 37 7.3 内容回植与 37-6 缺口修复（完成，L3 已通过）

- **目标**：7.3 内容回植；base 为 7.2 反编译参考，ours 为当前 7.2 治理工程，theirs 为 7.3 反编译参考。
- **37-0**：7.3 二进制、SGXZ 解密和逐文件清单已校验；目录与全部 40,275 个文件块通过 MD5 校验；参考树已生成 774 个 `.gd` 与 1,152 个 `.tscn`；初版台账记录 49 个生产脚本修改、1 个新增生产脚本，生产脚本删除 0。
- **37-1**：数据/资产与截教接入完成；JSON/BIN/Atlas/FrameSequence 与 7.2 的生产内容无变化（仅缓存变化）；37 个上游新增图标已复核：36 个进入运行期引用闭包（16 个八级宝石/精粹、20 个截教魂晶），1 个无消费者 `1301` 按上游内容保留、不纳入运行期闭包；装备构建源新增 38 条定义并重建 Catalog。`WanLingJiejiaoData`、`BaseMonster` 属性/魂晶掉落、`LevelInfo` 预览和 `PlayerData` effects/consumption 已接入；资产引用闭包、Atlas/FrameSequence 与导出清单复核已完成。
- **37-2**：角色与技能内容完成；NeZha/Yutu 重叠伤害与月舞碰撞掩码、EastContinentMonster 3120 传送、Level 47–75 宝石精粹掉落/预览均已接入。
- **37-3**：系统、菜单/UI 与公告文本完成；万灵图录截教分栏、V7.3 公告、招财铃铛、仙戒神铸、分解返还、8 级宝石配方与天庭噩梦进度已接入。
- **37-4**：2P 相机/HUD/归属与剩余脚本/场景差异完成；`BaseBuff` 拥有者属性/数据、Buff 图标 HUD 归属与 `MonsterHeadInfo` 操作者已修正；2P 相机、灵气、HUD 与操作者探针收口。
- **37-5**：L3 收口完成（`check_all` 9/9、全量关卡 128/128 + 5 SKIP、coop 38/38、scene 26/26、archive 344/344、level_1 四阶段通过）；PCK/release 与最低配置/其他平台验证按用户决策另行执行。
- **37-6**：缺口修复完成；Level_77 出口初始隐藏、Role 8 装备权限、分解帮助文案与 `fixed_chance` 掉落语义已修复；新增 `phase37-6` 探针；L3 复跑 `check_all` 9/9、health 807 脚本 0/0/0、全量关卡 128/128 + 5 SKIP、scene 27/27、coop 38/38、archive 344/344、level_1 四阶段通过；资产矩阵已重生成。
- **边界**：禁止整包覆盖、直接 patch 反编译 diff、复制旧 `.ctex`/`.import`/缓存；`addons/` 与上游 `Script/Test` 不直接进入生产；台账、解包目录与本地绝对路径不进入仓库；7.3 PCK/release 暂缓。

### 1.6 Phase 38 7.4 内容回植（38-0、38-1、38-2 完成，38-3 待启动）

- **目标与基线**：7.4 内容回植；`base` 为 7.3 反编译参考，`ours` 为当前 7.3 治理工程，`theirs` 为 7.4 反编译参考。按 [`ADR-014`](../decisions/ADR-014-three-way-semantic-merge-for-version-migration.md) 做三方语义合并；禁止整包覆盖、直接 patch 反编译 diff、复制旧 `.ctex`/`.import`/缓存或上游 `Script/Test`。
- **38-0 完成**：目标 `八荒湮隳7.4.exe`，**2,382,869,864 字节**，SHA-256 `e6e3d1fdab8b34698ede59152f9a1a7bbea0bfba9210789e9027ca20799c0933`；`GDPC` v4 / engine 4.7.0 / flags `0x3` / `file_base` `0x70`；PCK 起始 `0x38D5C00`，目录偏移 `0x8A3BAA60`，`SGXZSIG1` 位于 PCK+`0x48`。7.4 复用 7.3 的静态 signer/mask 派生路径；目录明文计数 **40,571**、明文长度 **4,107,592**、目录 MD5 `bc036150d6adb9448966fca62b4be987`，完整解析剩余 **0**；全部 **40,571** 个文件块解密后 MD5 与大小通过，flags 全为 `1`，无 `SGXZC001` 压缩包装，存储/明文总量 **2,316,959,886** 字节。参考树已生成 **40,571** 个原始条目，**791/791** `.gdc` 反编译成功、**1,175/1,175** `.scn` 转文本成功；非场景 **39,396** 个文件按清单 size+MD5 复核通过，1,175 个 `.scn` 全部转为 `.tscn`；参考树、清单与台账保存在仓库外。PE 前缀与 7.3 不完全一致（首个差异 `0x350`），启动器/版本资源差异已记录。
- **38-0 台账结论**：7.3→7.4 新增 **296**、删除 **0**、原始修改 **21**（16 `.gdc` + 2 `.scn` + 1 `project.binary` + 2 cache）。语义生产变化：脚本 **34**（16 修改 + 18 新增，含 17 个 `.gdc` 与 1 个 `.gdshader`）、场景 **25**（2 修改 + 23 新增）、数据 **1**、资产 **183**、资源 **16**、重映射 **56**。内容域集中在魂卡系统、精英副本、启动加载/Android 完整性、V7.4 公告与 UI、Level 22 技能限制移除、Monster 77/78/139 精英逻辑。`project.binary` 显示 7.4 将主场景改为 `startup_loading.tscn`、boot splash 改为 `Art/set_menu/313.png`、新增 `AndroidIntegrity` Autoload、启用传感器；与当前“不新增 Autoload”和 `load_scene` 入口冲突，38-3 必须评审后接入，禁止整体覆盖 `project.godot`/`project.binary`。
- **38-1 资产接入完成**：7.4 新增资产 **183** 条（91 `.import` + 91 `.ctex` + 1 `.png`）与资源 **16** 条已按台账处置：**91** 个 `.ctex` 解码为源 PNG（`Art/soul_card/` 16、`Art/soul_card/elite/` 68、`Art/main_menu/map_0/` 5、`Art/monster/soul_crystal/` 2），**16** 个 `.res` 恢复为 `AtlasTexture` `.tres`（区域全部校验），未复制 `.ctex`/`.import`/`.res`/`.remap`；4 个上游 SVG 按钮图标按解码 PNG 接入，38-3 的 `Map_0` 引用改用 `.png`；boot splash `Art/set_menu/313.png` 与当前源像素一致（0/554,600 差异），保留当前文件。
- **38-1 校验完成**：91 个新 `.import` 全部由 Godot 重新生成，`source_file` 指向当前路径，无 `res://godot/imported/`；全工程 51,312 个 `.import` UID 重复 **0**。Atlas **4,015/4,015**、FrameSequence **288**、怪物帧 **152/152**、装备 **1,127**、关卡预载 **101**、原始数据清单 **1,033** 均无变化并通过同步检查；`check_all --godot-bin` **9/9**、`health_check --no-cache` **807 脚本 0/0/0**、`level_1` 冒烟 **4 阶段 0/0/0**。56 个 `.remap` 仅作映射证据：16 个 `.tres` 本批消费，17 个脚本与 23 个场景留待 38-2/38-3。
- **38-2 角色与技能完成**：新增 `SoulCardData`/`SoulCardRuntime`/`SoulCardEffect`/`SoulCardBossVisual`、`EliteAttack`/`EliteBossMechanics`/`EliteBossStats`/`Level_Elite`、`SoulCardPanelBase` 与 `Scene/level/level_elite.tscn`；按当前路径接入 **18** 个 EliteSoulCard 特效场景（标准节点格式 `.tscn`）与 **31** 个既有特效纹理（含 Monster 77/78/139、天王、龙王、判官等特效序列）。`BaseHero` 接入魂卡运行时挂载、伤害吸收与受击来源；`BaseRoleProperies` 合并魂卡属性与防御倍率；`BaseMonster` 接入精英控制免疫、死亡掉落回调、魂卡伤害回调与难度倍率跳过；`Monster_77/78/139` 接入精英分支；Longnv/NeZha/Yutu 与 `BaseHero.get_skill` 的 Level 22 技能限制移除。`RunContext` 新增精英副本选择状态并提供读写访问器，未新增 Autoload 或 `Global` 业务字段；`Global.CurrentLevel`/`GameOver` 改用现有 `get_current_level_name`/`set_current_level_name` 与 RunContext accessor。
- **38-2 验证**：`check_all --godot-bin` **9/9**、`health_check --no-cache` **816 脚本 0 Parse / 0 Error / 0 Warning**、`level_1` 四阶段 **0/0/0**、`level_1 --role 6/7/8` 四阶段 **0/0/0**、`level_elite` 通用冒烟 **PASS**（1 阶段，Boss 存活，0/0/0）；变更影响关卡回归 **129/129 PASS + 5 SKIP**（含 `level_elite` PASS，377.4s）；临时探针验证 SoulCardData 属性/1→5 星倍率、EliteBossStats 分档、精英 Boss 掉落奖励、qly 特效生成与护盾吸收，以及 sfe 精英攻击载体生成（2 个存活实例）。
- **38-3 系统、菜单/UI 与公告**：逐项三方语义合并；在现有最小 `SoulCardPanelBase` 上完成 `SoulCardPage`/`SoulCardLoadoutPage`/`SoulCardRolePreview`/`SoulCardSelectionGlow`/`SoulCardFoilPreview`、`EliteChallengePage`，并补 `Map_0`、`GameAnnouncement`、`set_menu`、`defeat`、`load_scene`/`startup_loading` 与剩余 4 个 UI/启动场景；`AndroidIntegrity` Autoload 与主场景切换先做边界评审，优先以普通节点/局部组件满足当前“不新增 Autoload”约束；帮助文本、版本公告、tooltip 与实际数值/规则一致；新增 UI 遵循 [`ui_typography_contract.md`](../standards/ui_typography_contract.md) 与 Theme token；按 [`ADR-005`](../decisions/ADR-005-no-compatibility-or-fallback-layers.md) 与 [`ADR-006`](../decisions/ADR-006-resource-first-data-and-data-keys.md) 不保留兼容/回退双轨，不新增 Autoload、`Global` 业务字段或 `add` 系门面。
- **38-4 2P 与剩余脚本/场景**：最后接入侵入性系统；按 [`ADR-017`](../decisions/ADR-017-local-coop-profile-isolation.md) 与 [`ADR-021`](../decisions/ADR-021-project-wide-target-architecture.md) 逐项核对相机、HUD/Buff、灵气、被动属性、技能键提示、面板操作者、槽位回写、死亡/退出与保存快照互斥；剩余脚本/场景差异按台账收口。
- **38-5 L3 收口**：按 [`acceptance.md`](../reference/acceptance.md) 执行 `check_all --godot-bin` 9/9、`health_check --no-cache` 0/0/0、全量关卡回归、`scene_probe_runner`、`coop_probe_runner`、`archive_probe_runner`、`level_1` 四阶段、命名/白名单、文档链接与构建资源同步；PCK/release 与最低配置/其他平台验证按用户决策另行执行。版本标识与 `status.md`/`roadmap.md` 只在证据完成并经用户确认后更新。
- **38-6 语义复核与缺口修复（按需）**：复核 Role 1–8 分支、装备权限、场景默认可见性/碰撞层、`fixed_chance`/难度倍率/双倍掉落、帮助文本/公告/tooltip；38-5 发现缺口时先补台账与复现，再修复并复跑同一门禁；无缺口则不启用该批次。
- **完成判定**：按 [`migration_playbook.md`](../guides/migration_playbook.md) Phase 2 出口逐项满足范围完整、语义完整、资产完整、双人完整、失败边界、证据可复核与文档一致；生产未映射 0，删除/数据表/场景属性/UI 文本均有处置结论；不以“路径存在”或“L3 通过”替代语义复核。
- **非目标与边界**：不夹带上游之外的玩法重设计、数值再平衡、存档格式变更、旧路径/旧后端/旧存档迁移链、Autoload/`Global` 扩张、目录大规模迁移、PCK/release 或平台验证；解包、密钥、参考树、逐文件台账与本地绝对路径只在仓库外；测试探针按 [`ADR-019`](../decisions/ADR-019-test-fixtures-outside-production-source.md) 放在 `scripts/`；`addons/` 非插件维护任务不修改。

---

## 2. Phase 26：平台与发布验证（长期暂缓）

**状态**：长期暂缓；未启动，不阻塞后续阶段。Windows-only 验证口径见 [`ADR-027`](../decisions/ADR-027-platform-commitment-and-verification-device.md)。
**目标**：把“路径闭包”“release 启动”“验证机性能基线”“Spine 平台支持”分别证明。
**前置**：可做只读规划；涉及资源/导出变化时再与当前代码批次协调。
**非目标**：不把未验证平台写成支持，不用 PCK 可达替代 release，不用 headless 替代 HUD/VRAM。

### 26-0 平台支持矩阵

- 明确当前承诺平台、未验证平台与退出条件；
- 记录设备、OS、渲染后端、Spine 库、导出模板与许可证；
- Windows x86_64 先行；其它平台保持“延期/未验证”。

### 26-1 Windows release 启动与最小包

- 构建 release，验证冷启动、主菜单、存档列表、`level_1` 进入与退出；
- 区分离线验证包与最小发布包；记录实际包路径闭包与缺失资源；
- 失败必须显式，不以“全资源包可运行”替代发布结论。

### 26-2 验证机性能基线

- 在验证机记录首帧、战斗峰值 VRAM、加载时长、重复进出与退出；固定机器、驱动、渲染后端、分辨率与 `max_fps`，只做同机对照（ADR-027）；
- 至少覆盖一场战斗、一个 Boss、一次返回/重战；
- 结论写入 `status.md`，带设备、日期与未验证范围。

### 26-3 Spine 平台决策

- 复核 Windows 之外是否需要 Spine 扩展；没有设备/许可证/导出证据时保持延期；
- 不把 `.gdextension` 声明文件当作运行库已入库。

### 26-4 阶段验收

- 平台矩阵、release 启动记录、设备性能证据与发布包结论；
- 出口：支持平台有证据，未支持平台有明确原因；不新增未经证实的兼容承诺。

**恢复条件**：平台矩阵、设备、导出条件与 release 证据同时明确。

---

## 3. 启动新阶段的条件

1. 先在 [`roadmap.md`](roadmap.md) 登记阶段目标、依赖、边界与验收要求，不把未实现目标写成本页现状。
2. 进入候选前补齐调用面、所有权边界、原子迁移批次与可执行验收。
3. 一个批次一个所有权边界：迁移全部生产调用方，删除旧实现。
4. 验收按变更矩阵：静态门禁、相关探针、生产路径冒烟、全量回归、release/性能分别取证；不新增只验证 wiring 的永久测试。
5. 文档同步：每批完成后更新 `architecture.md`、`status.md`、对应矩阵与 `global_runtime_inventory.md`；归档只在阶段结束后进行。
6. 完整跨阶段纪律见 [`roadmap.md`](roadmap.md) §5。

---

## 4. 当前恢复入口

**当前下一步**：执行 Phase 38-3（系统、菜单/UI 与公告）：在现有最小 `SoulCardPanelBase` 上完成 `SoulCardPage`/`SoulCardLoadoutPage`/`EliteChallengePage` 与角色预览、选中光效、闪卡预览；接入 `Map_0`、`GameAnnouncement`、`set_menu`、`defeat`、`load_scene`/`startup_loading` 与剩余 4 个 UI/启动场景；`AndroidIntegrity` Autoload 与主场景切换先做边界评审，优先以普通节点/局部组件满足当前“不新增 Autoload”约束，禁止整体覆盖 `project.godot`/`project.binary`。PCK/release 与最低配置/其他平台验证按用户决策另行执行，恢复前先按 [`acceptance.md`](../reference/acceptance.md) 与 [`status.md`](../reference/status.md) 的发布边界复核。

- 当前架构：[`architecture.md`](../reference/architecture.md)
- Global 清单：[`global_runtime_inventory.md`](../reference/global_runtime_inventory.md)
- 验收标准：[`acceptance.md`](../reference/acceptance.md)
- 当前状态：[`status.md`](../reference/status.md)
- 长期路线：[`roadmap.md`](roadmap.md)
- 归档索引：[`../archive/README.md`](../archive/README.md)
- 已归档程序记录：[`program_21_33_closeout.md`](../archive/program_21_33_closeout.md)
