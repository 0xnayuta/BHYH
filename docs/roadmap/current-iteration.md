# BHYH 当前候选迭代

> **状态**：**Phase 37 7.3 内容回植（37-0 二进制/参考工程准备进行中）**。Phase 36 的 7.2 L3 收口已完成、待发布验证；Phase 35 的 7.1 L3 收口已完成、待发布验证；Phase 22 / 23 / 24 / 25 / 27 已完成并归档；Phase 34 7.0 内容回植已完成、待发布验证；Phase 26 平台与发布验证长期暂缓；7.3 PCK/release 暂缓。
> **版本**：7.2 内容基线；7.3 回植进行中，尚未升级版本标记。
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
- **L3 收口完成**：全量场景 23/23、全量关卡 128/128 PASS + 5 SKIP、双人 37/37、档案 344/344、命名/白名单与构建资源同步通过；PCK/release 与目标设备验证继续暂缓。
- **发布边界**：PCK/release 与目标设备验证暂缓，待最终发布统一执行；当前版本标记仍以工程配置为准。

### 1.4 Phase 36 7.2 内容回植（完成，L3 已收口）

- **目标**：7.2 内容回植；base 为 7.1 反编译参考，ours 为当前 7.1 治理工程，theirs 为 7.2 反编译参考。
- **36-0 完成**：参考源码/场景与逐文件台账；989/989 脚本、8/8 变更场景文本化；生产未映射 0。
- **36-1 完成**：7.2 PCK 不含年兽原始 PNG；46 张图已从 ctex 解码为 RGBA8 PNG（非 VRAM 纹理）并归一化到 `source/Art/pet/pet_nian`；4 阶帧资源、21 JSON / 20 BIN、shader、`export_raw_roots` 已接入；原始数据清单 1033 文件；`xydxq` 7.2 描述已迁移到装备构建源。
- **36-2 完成**：6 个 PetNian 脚本 + 4 个召唤场景 + `FirstBatchAwakenArea` / `NeZhaAwakenWheel` 已按当前 API 适配；修复 `NeZhaOfficialParts.load_set` 切换部件集时的旧帧索引越界；新增 `pet-nian` 运行时探针，覆盖 1–4 阶场景、帧资源、parts 与效果。
- **36-3 完成**：新增 `PetNianFamily`；`PlayerData` 默认条目与 `ensure_pet_nian`、档案载入/规范化链、PetInterface 出战/升级/预览、BaseRole HUD 头像/技能/死亡别名、BaseThroughLevel/PetLevelController 生成与 2P 槽位、BaseMonster 经验成长、SummonBaseMonster 死亡持久化全部接入；`pet-nian` 探针扩展档案与 HUD，新增 `LocalCoopPetNianProbe`。
- **36-4 完成**：`NeZhaHero` 接入 `nz_hlqg` 双火轮（2× 伤害、8 秒/8 段、环绕后投掷）；`Role1` 重斩觉醒动作与三道地裂（2×/4×/8×、霸体）；`Role2` 玄冰阵五段冰刺与冰域（末段冰冻 2 秒）；`YutuHero` 月魔舞三月影（主体 1.5×、月影 0.7×、主体双倍月印）；`skill_awaken_popup` / `zd_skill` / `SkillDamageFormulaData` 接入四个新觉醒 ID 与说明；`awaken-72` 探针覆盖上述路径、一阶觉醒石与技能面板按钮。
- **36-5 完成**：`Global` 接入年兽出战预载（召唤场景/帧/头像，空子弹场景安全跳过）；`GameAnnouncement` 接入 V7.2 文案与版本按钮；`dj_sell` 喜鹊改为可叠加、上限 24 小时（含活动 Buff 刷新）；`Transmogrified` 补充沙僧幻化项并聚合翅膀/头衔；`Role_8` 昵称上移；新增 `menu-ui-72` 探针覆盖预载、公告、喜鹊、幻化与昵称。
- **36-6 完成**：L3 收口通过 `check_all` 9/9、`health_check --no-cache` 806 脚本 0/0/0、全量关卡回归 128/128 + 5 SKIP、场景探针 26/26、双人矩阵 38/38、档案探针 344/344、`level_1` 四阶段 0/0/0；原始数据/Atlas/帧序列同步校验通过。
- **后续批次**：无；Phase 36 已关闭，PCK/release 与目标设备验证按用户决策暂缓。
- **边界**：7.2 生产脚本与场景差异已收口；`addons/bone_export/export_plugin.gd` 属第三方插件，按仓库边界不修改；`Script/Test` 仅作规格，不进入生产；PCK/release 实际导出与目标设备 VRAM/首帧耗时未验证；7.3 未立项。

### 1.5 Phase 37 7.3 内容回植（37-0 进行中）

- **目标**：7.3 内容回植；base 为 7.2 反编译参考，ours 为当前 7.2 治理工程，theirs 为 7.3 反编译参考。
- **37-0**：校验 7.3 二进制（SHA-256、PCK 偏移、条目/逐文件清单）；建立 `reference/7.3.0.0_source`；生成脚本/场景/资产参考；完成 7.2→7.3 差集与逐文件台账。7.3 使用新的 SGXZ 安全打包格式，必须先验证目录签名/解密路径，不得复用 7.2 的 HBXZ 假设。
- **37-1**：数据与资产（新增/变化 JSON/BIN、Atlas、FrameSequence、UI 文本），按当前转换器重建 Catalog 与导出清单。
- **37-2**：角色与技能内容（按 7.3 变更域拆分），每个功能域单独验证。
- **37-3**：系统、菜单/UI 与公告文本，逐项做三方语义合并。
- **37-4**：2P 相机/HUD/归属与剩余脚本/场景差异，最后接入侵入性系统。
- **37-5**：L3 收口；PCK/release 与目标设备验证按用户决策另行执行。
- **边界**：禁止整包覆盖、直接 patch 反编译 diff、复制旧 `.ctex`/`.import`/缓存；`addons/` 与上游 `Script/Test` 不直接进入生产；台账、解包目录与本地绝对路径不进入仓库；7.3 PCK/release 暂缓。

---

## 2. Phase 26：平台与发布验证（长期暂缓）

**状态**：长期暂缓；未启动，不阻塞后续阶段。
**目标**：把“路径闭包”“release 启动”“目标设备性能”“Spine 平台支持”分别证明。
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

**当前下一步**：完成 Phase 37-0 的 7.3 二进制校验、参考源码/场景生成与 7.2→7.3 逐文件台账；SGXZ 解密/签名路径未验证前不得进入生产批次。

- 当前架构：[`architecture.md`](../reference/architecture.md)
- Global 清单：[`global_runtime_inventory.md`](../reference/global_runtime_inventory.md)
- 验收标准：[`acceptance.md`](../reference/acceptance.md)
- 当前状态：[`status.md`](../reference/status.md)
- 长期路线：[`roadmap.md`](roadmap.md)
- 归档索引：[`../archive/README.md`](../archive/README.md)
- 已归档程序记录：[`program_21_33_closeout.md`](../archive/program_21_33_closeout.md)
