# BHYH 当前候选迭代

> **状态**：**Phase 38 7.4 内容回植与 38-6 缺口修复完成（38-0~38-6；L3 已通过；PCK/release 暂缓）**。Phase 37 的 7.3 内容回植与 37-6 缺口修复已完成（37-0~37-6；L3 已通过；PCK/release 暂缓）；Phase 36 的 7.2 L3 收口已完成、待发布验证；Phase 35 的 7.1 L3 收口已完成、待发布验证；Phase 22 / 23 / 24 / 25 / 27 已完成并归档；Phase 34 7.0 内容回植已完成、待发布验证；Phase 26 平台与发布验证长期暂缓；7.3/7.4 PCK/release 暂缓。**当前候选 Phase 28 已登记，28-1 进行中；Phase 29 未启动。**
> **版本**：7.4 内容基线（38-0~38-6 完成，L3 已通过）；当前候选为 Phase 28 架构治理（28-1 进行中）。PCK/release 与最低配置/其他平台验证暂缓。
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

### 1.6 Phase 38 7.4 内容回植与 38-6 缺口修复（38-0~38-6 完成）

- **目标与基线**：7.4 内容回植；`base` 为 7.3 反编译参考，`ours` 为当前 7.3 治理工程，`theirs` 为 7.4 反编译参考。按 [`ADR-014`](../decisions/ADR-014-three-way-semantic-merge-for-version-migration.md) 做三方语义合并；禁止整包覆盖、直接 patch 反编译 diff、复制旧 `.ctex`/`.import`/缓存或上游 `Script/Test`。
- **38-0 完成**：目标 `八荒湮隳7.4.exe`，**2,382,869,864 字节**，SHA-256 `e6e3d1fdab8b34698ede59152f9a1a7bbea0bfba9210789e9027ca20799c0933`；`GDPC` v4 / engine 4.7.0 / flags `0x3` / `file_base` `0x70`；PCK 起始 `0x38D5C00`，目录偏移 `0x8A3BAA60`，`SGXZSIG1` 位于 PCK+`0x48`。7.4 复用 7.3 的静态 signer/mask 派生路径；目录明文计数 **40,571**、明文长度 **4,107,592**、目录 MD5 `bc036150d6adb9448966fca62b4be987`，完整解析剩余 **0**；全部 **40,571** 个文件块解密后 MD5 与大小通过，flags 全为 `1`，无 `SGXZC001` 压缩包装，存储/明文总量 **2,316,959,886** 字节。参考树已生成 **40,571** 个原始条目，**791/791** `.gdc` 反编译成功、**1,175/1,175** `.scn` 转文本成功；非场景 **39,396** 个文件按清单 size+MD5 复核通过，1,175 个 `.scn` 全部转为 `.tscn`；参考树、清单与台账保存在仓库外。PE 前缀与 7.3 不完全一致（首个差异 `0x350`），启动器/版本资源差异已记录。
- **38-0 台账结论**：7.3→7.4 新增 **296**、删除 **0**、原始修改 **21**（16 `.gdc` + 2 `.scn` + 1 `project.binary` + 2 cache）。语义生产变化：脚本 **34**（16 修改 + 18 新增，含 17 个 `.gdc` 与 1 个 `.gdshader`）、场景 **25**（2 修改 + 23 新增）、数据 **1**、资产 **183**、资源 **16**、重映射 **56**。内容域集中在魂卡系统、精英副本、启动加载/Android 完整性、V7.4 公告与 UI、Level 22 技能限制移除、Monster 77/78/139 精英逻辑。`project.binary` 显示 7.4 将主场景改为 `startup_loading.tscn`、boot splash 改为 `Art/set_menu/313.png`、新增 `AndroidIntegrity` Autoload、启用传感器；与当前“不新增 Autoload”和 `load_scene` 入口冲突，38-3 必须评审后接入，禁止整体覆盖 `project.godot`/`project.binary`。
- **38-1 资产接入完成**：7.4 新增资产 **183** 条（91 `.import` + 91 `.ctex` + 1 `.png`）与资源 **16** 条已按台账处置：**91** 个 `.ctex` 解码为源 PNG（`Art/soul_card/` 16、`Art/soul_card/elite/` 68、`Art/main_menu/map_0/` 5、`Art/monster/soul_crystal/` 2），**16** 个 `.res` 恢复为 `AtlasTexture` `.tres`（区域全部校验），未复制 `.ctex`/`.import`/`.res`/`.remap`；4 个上游 SVG 按钮图标按解码 PNG 接入，38-3 的 `Map_0` 引用改用 `.png`；boot splash `Art/set_menu/313.png` 与当前源像素一致（0/554,600 差异）；38-6d 已将该资源接入 `project.godot`。
- **38-1 校验完成**：91 个新 `.import` 全部由 Godot 重新生成，`source_file` 指向当前路径，无 `res://godot/imported/`；全工程 51,312 个 `.import` UID 重复 **0**。Atlas **4,015/4,015**、FrameSequence **288**、怪物帧 **152/152**、装备 **1,127**、关卡预载 **101**、原始数据清单 **1,033** 均无变化并通过同步检查；`check_all --godot-bin` **9/9**、`health_check --no-cache` **807 脚本 0/0/0**、`level_1` 冒烟 **4 阶段 0/0/0**。56 个 `.remap` 仅作映射证据：16 个 `.tres` 本批消费，17 个脚本与 23 个场景留待 38-2/38-3。
- **38-2 角色与技能完成**：新增 `SoulCardData`/`SoulCardRuntime`/`SoulCardEffect`/`SoulCardBossVisual`、`EliteAttack`/`EliteBossMechanics`/`EliteBossStats`/`Level_Elite`、`SoulCardPanelBase` 与 `Scene/level/level_elite.tscn`；按当前路径接入 **18** 个 EliteSoulCard 特效场景（标准节点格式 `.tscn`）与 **31** 个既有特效纹理（含 Monster 77/78/139、天王、龙王、判官等特效序列）。`BaseHero` 接入魂卡运行时挂载、伤害吸收与受击来源；`BaseRoleProperies` 合并魂卡属性与防御倍率；`BaseMonster` 接入精英控制免疫、死亡掉落回调、魂卡伤害回调与难度倍率跳过；`Monster_77/78/139` 接入精英分支；Longnv/NeZha/Yutu 与 `BaseHero.get_skill` 的 Level 22 技能限制移除。`RunContext` 新增精英副本选择状态并提供读写访问器，未新增 Autoload 或 `Global` 业务字段；`Global.CurrentLevel`/`GameOver` 改用现有 `get_current_level_name`/`set_current_level_name` 与 RunContext accessor。
- **38-2 验证**：`check_all --godot-bin` **9/9**、`health_check --no-cache` **816 脚本 0 Parse / 0 Error / 0 Warning**、`level_1` 四阶段 **0/0/0**、`level_1 --role 6/7/8` 四阶段 **0/0/0**、`level_elite` 通用冒烟 **PASS**（1 阶段，Boss 存活，0/0/0）；变更影响关卡回归 **129/129 PASS + 5 SKIP**（含 `level_elite` PASS，377.4s）；临时探针验证 SoulCardData 属性/1→5 星倍率、EliteBossStats 分档、精英 Boss 掉落奖励、qly 特效生成与护盾吸收，以及 sfe 精英攻击载体生成（2 个存活实例）。
- **38-3 系统、菜单/UI 与公告完成**：完成 `SoulCardPage`/`SoulCardLoadoutPage`/`SoulCardRolePreview`/`SoulCardSelectionGlow`/`SoulCardFoilPreview`、`EliteChallengePage` 与 `SoulCardPanelBase` 完整基类；新增 `Shader/soul_card.gdshader` 与 3 个 UI 场景；`Map_0` 接入魂卡/精英副本入口并改用 `wanling_catalog`/`soul_card`/`elite_entry`/`equipment_catalog` 四张 PNG 按钮；`GameAnnouncement` 增加 V7.4 公告与 `V0_55` 按钮；`set_menu`/`defeat` 增加精英副本返回主菜单条件；`load_scene` 支持 `startup_progress` 元数据；新增 `startup_loading` 首帧进度页并切换主场景。
- **38-3 验证**：`check_all --godot-bin` **9/9 PASS**（37.70s）、`health_check --no-cache` **823 脚本 0 Parse / 0 Error / 0 Warning**、`level_1` 四阶段 **0/0/0**、`level_elite` 通用冒烟 **PASS**（0/0/0）、变更影响回归 **129/129 PASS + 5 SKIP**（HEAD~3 无直接关卡映射，回退全量 356.4s）；临时 UI 探针验证 3 个页面可实例化、`Map_0` 两个新入口可打开对应页面、`GameAnnouncement` V7.4 按钮与内容切换成功；UI Theme 基线登记直接属性 **16**、动态主题 **386 处 / 45 文件**、静态角色 **0**、裸色 **0**。
- **AndroidIntegrity / 主场景边界**：不新增 `AndroidIntegrity` Autoload；保留 `load_scene` 既有内联首启 APK 签名校验；`startup_loading` 仅负责首帧进度并设置 `startup_progress`，不复制 `project.binary`；传感器设置在 38-6d 补齐，主场景由 `load_scene.tscn` 切换为 `startup_loading.tscn`；boot splash 在 38-6d 切到 `313.png` 并设置 stretch 5。
- **38-4 2P 与剩余脚本完成**：`coop_probe_runner` **38/38 PASS**（298.29s），覆盖相机/HUD/Buff/灵气/被动属性/技能键提示/面板操作者/槽位账本/输入隔离/全灭死亡/保存快照互斥；`SoulCardRuntime` 与 `BaseRoleProperies` 魂卡数据/属性走 `LocalCoop.data_for`/`props_for`，`BaseMonster` 魂卡伤害归属解析实际出手者；新 SoulCard/Elite/RolePreview 页面提供 `LocalCoop.data_for(self)` 的 `PlayerData` 属性并在 `coop_slot=2` 验证 secondary；`Map_0` 新菜单入口保持菜单级单操作者路径（与 7.4 一致）。
- **38-4 剩余脚本闭合**：`RoleSkillOpacity` 类型安全、`load_scene` startup progress/向下取整；AndroidIntegrity 在 38-6d 改为 Thread + `sgxz_apk_signature_valid` fallback、`Global.EliteChallengeSelection`→RunContext、`set_menu`/`defeat`/`GameAnnouncement`/`Map_0` 已完成；无未处置生产脚本/场景。
- **38-4 验证**：`check_all --godot-bin` **9/9 PASS**（42.77s）、`health_check` **823 脚本 0/0/0**、`level_1`/`level_elite` **0/0/0**、2P 页面操作者探针通过。
- **38-5 L3 收口完成**：`check_all --godot-bin` **9/9**（43.87s）、`health_check --no-cache` **823 脚本 0/0/0**、全量关卡回归 **129/129 + 5 SKIP**（351.3s）、`scene_probe_runner` **29/29**（隔离复跑 332.69s）、`coop_probe_runner` **38/38**（326.91s）、`archive_probe_runner` **344 检查 PASS**（23.39s）；命名/白名单 100%、Atlas **4,015**、FrameSequence **288**、怪物帧 **152**、装备 **1,127**、关卡预载 **101/154 场景**、原始数据清单 **1,033**、资源路径 **19,562/160**、文档链接 895/0 全部通过。
- **38-5 边界**：全量场景探针与回归/双人矩阵并发时曾出现一次 `level-selection` teardown 噪声；单探针与隔离全量复跑均 PASS，L3 采用隔离结果。PCK/release、最低配置与其他平台验证未执行。
- **38-6 缺口修复完成**：38-5 L3 后复核发现并修复以下缺口：
  - **38-6a**：`EliteBossMechanics` 写入 `EliteAttack.move_direction`；新增 `phase38-6a` 非 qly 精英 signature 探针，验证 sfe 攻击创建与方向。
  - **38-6b**：`heaven_soul_crystal_72/73` 图标从 `creature_codex` 切到 `soul_crystal`，重建 `equipment_catalog.tres`；装备数据审计通过。
  - **38-6c**：`BaseRoleProperies` 的魂卡签名与属性缓存改用槽位 profile；`EliteBossStats.apply` 增加 coop 参数并处理 `BaseMonster.damage_reduction` getter 的 0.25 叠加，双人精英预览与实际一致。
  - **38-6d**：启动画面切到 `313.png` 并设置 stretch mode 5；启用加速度/重力/陀螺仪；`load_scene` 完整性校验改为 Thread + `sgxz_apk_signature_valid` fallback，未新增 Autoload。
  - **38-6e**：新增 `phase38-6` 永久探针，覆盖 72/73 图标、2P 魂卡属性、双人精英属性、V7.4 公告与 Map_0 入口。
  - **38-6f**：`check_all --godot-bin` 9/9、`health_check` 823 脚本 0/0/0、全量关卡回归 129/129 + 5 SKIP、场景探针 31/31、双人 38/38、档案 344 检查通过；命名/白名单与文档链接通过。
  - **技术债边界**：`SoulCardData` 仍为 `RefCounted` 常量表，未按 ADR-006 转为 Resource；本批不扩大数据架构迁移，登记为后续数据架构批次候选。
- **完成判定**：按 [`migration_playbook.md`](../guides/migration_playbook.md) Phase 2 出口逐项满足范围完整、语义完整、资产完整、双人完整、失败边界、证据可复核与文档一致；生产未映射 0，删除/数据表/场景属性/UI 文本均有处置结论；不以“路径存在”或“L3 通过”替代语义复核。
- **非目标与边界**：不夹带上游之外的玩法重设计、数值再平衡、存档格式变更、旧路径/旧后端/旧存档迁移链、Autoload/`Global` 扩张、目录大规模迁移、PCK/release 或平台验证；解包、密钥、参考树、逐文件台账与本地绝对路径只在仓库外；测试探针按 [`ADR-019`](../decisions/ADR-019-test-fixtures-outside-production-source.md) 放在 `scripts/`；`addons/` 非插件维护任务不修改。

### 1.7 Phase 28 全局通信与派生属性契约（28-1 进行中；28-2 未启动）

- **目标**：移除全局确认信号 `Signals`，把确认回调归打开者所有；把被动属性快照从每帧轮询改为档案变更事件驱动；为这两条边界建立单一写者与门禁。
- **入口**：全局确认面 `Script/base/signals.gd`、`Scene/show_text/choose_scene.gd`、`Script/runtime/popup_factory.gd`；被动数值面 `Script/skill/passive_skills.gd`、`Script/memory_class/player_data.gd`、`Script/coop/local_coop.gd`。
- **非目标**：不改玩法数值、存档格式、输入映射；不新增 Autoload；不迁移 `Scene/` 下其余脚本（归 Phase 29）；不处理 `global.gd` 的根目录位置。

#### 28-1 移除全局确认信号（进行中）

- `choose_scene.gd` 增加 `confirmed`/`cancelled` 实例信号；确认与取消先发信号、再释放实例。
- 10 个 `connect_choose_box_signal` 调用点改为在 `Global.add_choose_text()` 返回值上连接；`decompose.gd` 的连接从 `_ready` 移到打开处。
- `PopupFactory` 维护活动确认框：新确认框打开时显式关闭旧实例，固化“最后打开者接管”的单确认框语义，不再依赖信号断开。
- 删除 `Script/base/signals.gd` 与伴生 `.uid`，从 `project.godot` 移除 `Signals` 注册项；Autoload 由 11 项降为 10 项（9 个业务单例 + `MCPGameBridge`）。
- 新增 ADR 记录“确认框回调归打开者所有”；更新 `autoload_boundary_matrix.md`、`architecture.md`、`global_runtime_inventory.md` 的注册项计数。
- 新增全局信号基线门禁：扫描 Autoload 脚本的 `signal` 声明，与基线比较，新增报 ERROR；删除 `Signals` 后基线为 `MemoryClass` 的 `background_save_finished` 与 `save_failed`。
- **出口**：10 条确认路径（存档删除、出售、分解、挑战、商店购买、技能升级等）确认/取消各执行一次；连续打开、暂停、场景切换释放正常；`check_all`、`health_check`、`scene_probe_runner`、`coop_probe_runner`、`level_1` 与变更影响回归通过；文档计数一致。

#### 28-2 被动属性快照事件化（未启动）

- 删除 `passive_skills.gd` 的 `_physics_process` 轮询与 `LocalCoop.secondary_passives` 的轮询。
- `PlayerData` 增加 `passive_skills_changed` 信号；在 `apply_passive_skill_upgrades()` 成功、`ensure_player_passive_skills()` 实际修正、档案载入完成后发出。
- `PaSkill` 连接信号并保留启动刷新；`LocalCoop` 只刷新 2P 槽位；`get_passive_skill_properties()` 增加等级与属性实例签名短路。
- `DataKeys` 增加玩家被动技能键常量，替换 `PaSkill`、`PlayerData`、`bd_skill`、`back_pack` 中的裸中文键；宠物被动键保持独立域。
- 新增 `docs/reference/passive_skill_contract.md`；`contract_scan.py` 增加 `PASSIVE_SNAPSHOT_WRITE`、`PASSIVE_POLLING`、`PASSIVE_DATA_WRITE`。
- **出口**：新建档、读档、单技能/一键升级、保存失败回滚、双人 link/取消、切档、属性实例重建的验证矩阵全部通过；`check_all`、`health_check`、`coop_probe_runner`、档案探针与关卡回归通过。

### 1.8 Phase 29 `Scene/` 脚本落位（未启动）

- **目标**：统一 GDScript 落位规则为“`Scene/` 不存放 `.gd`，全部归 `Script/<domain>/`”，迁移当前 56 个场景脚本。
- **入口**：`source/Scene/` 下 56 个 `.gd`；[`naming_standard.md`](../standards/naming_standard.md) §1.2、§2.1；`scripts/naming_audit.py`。
- **非目标**：不改脚本行为；不搬 `Scene/` 下的 `.tscn`/`.tres`；不新建顶层类型目录；不处理 `global.gd`。

#### 29-0 规范与清单（未启动）

- 更新 `naming_standard.md`：`Scene/` 承载场景树与预制体，`.gd` 一律归 `Script/<domain>/`。
- 产出 56 个文件的逐文件目标路径清单，检查同名冲突与场景引用。
- 新增或修订目录落位 ADR，同步 `architecture.md` 的目录说明。

#### 29-1 应用编排与档案（未启动）

- `load_scene.gd`、`startup_loading.gd`、`userload.gd`、`auto_battle_config.gd` → `Script/runtime/`。
- `bacis_ar_button.gd` → `Script/archive_interface/`。

#### 29-2 菜单、关卡、奖励、阵法与怪物（未启动）

- 菜单、帮助、结算、角色选择 → `Script/main_menu/`、`Script/other_menu/`、`Script/level/`。
- 奖励与幻化 → `Script/other_menu/`；阵法与技能图标 → `Script/skill/`。
- 怪物、血条、受击、Buff、光环 → `Script/monster/`；怪物数据 → `Script/data/`。

#### 29-3 文本表现与角色特效（未启动）

- `choose_scene.gd` → `Script/runtime/`；`combo`、`message`、`moment_text`、`touch_text`、`liji` → `Script/hittext/`。
- `special_effect_bullet.gd` → `Script/hero/`。

#### 29-4 门禁启用（未启动）

- `naming_audit.py` 增加 `source/Scene/**/*.gd` 报 ERROR 的规则；清理路径变化产生的白名单旧条目。
- **出口**：`Scene/` 下 `.gd` 为 0；`check_all`、`health_check`、`scene_probe_runner`、相关关卡回归通过；`docs_audit` 0 缺失链接。

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

**当前下一步**：执行 Phase 28-1 移除全局确认信号（进行中）；28-1 收口后进入 28-2 被动属性快照事件化。Phase 29 `Scene/` 脚本落位在 Phase 28 收口后启动。PCK/release、最低配置与其他平台验证按用户决策另行执行；恢复前先按 [`acceptance.md`](../reference/acceptance.md) 与 [`status.md`](../reference/status.md) 的发布边界复核。

- 当前架构：[`architecture.md`](../reference/architecture.md)
- Global 清单：[`global_runtime_inventory.md`](../reference/global_runtime_inventory.md)
- 验收标准：[`acceptance.md`](../reference/acceptance.md)
- 当前状态：[`status.md`](../reference/status.md)
- 长期路线：[`roadmap.md`](roadmap.md)
- 归档索引：[`../archive/README.md`](../archive/README.md)
- 已归档程序记录：[`program_21_33_closeout.md`](../archive/program_21_33_closeout.md)
