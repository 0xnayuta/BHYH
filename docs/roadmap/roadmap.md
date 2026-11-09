# BHYH 后续开发路线图

> **定位**：长期阶段顺序、阶段状态与独立项目的唯一来源；不保存批次实施流水账。
> **当前版本**：7.4 内容基线；**Phase 38 已完成（38-0~38-6；L3 已通过；PCK/release 暂缓）**。Phase 12~38 除 Phase 26 外均已完成、关闭或归档；Phase 21 的 21-2A 最低设备确认与 21-2B 平台测量暂缓；Phase 26 与 7.3/7.4 PCK/release 长期暂缓；**Phase 28 已完成（28-1、28-2、28-3），Phase 29 进行中（29-0、29-1、29-2A、29-2B、29-2C 完成）**。
> **依据**：[`target_architecture_contract.md`](../standards/target_architecture_contract.md)；当前实现见 [`architecture.md`](../reference/architecture.md)，验证事实见 [`status.md`](../reference/status.md)，门禁见 [`acceptance.md`](../reference/acceptance.md)。

## 1. 状态与文档边界

### 1.1 文档职责

| 文档 | 唯一职责 |
|:---|:---|
| 总体目标契约 | 长期职责、依赖方向、不变量与迁移约束 |
| 本页 | 阶段顺序、阶段状态、未启动阶段的职责与启动条件 |
| [`current-iteration.md`](current-iteration.md) | 当前候选；无活跃候选时明确写“无”，并保留恢复入口 |
| `architecture.md` / `status.md` | 实际实现 / 带日期的验证与当前边界 |
| [`../archive/README.md`](../archive/README.md) | 已完成阶段的实施记录与长期参考 |

### 1.2 阶段状态

| 阶段 | 状态 | 入口 |
|:---|:---|:---|
| Phase 12 显示/HUD | 完成、归档 | [`iteration_12_display_hud.md`](../archive/iteration_12_display_hud.md) |
| Phase 13 视觉资产契约 | 完成、归档 | [`iteration_13_visual_asset_contract.md`](../archive/iteration_13_visual_asset_contract.md) |
| Phase 14 AtlasMetadata 类型化边界 | 完成、归档 | [`iteration_14_atlas_metadata_boundary.md`](../archive/iteration_14_atlas_metadata_boundary.md)；当前契约 [`atlas_metadata_schema.md`](../reference/atlas_metadata_schema.md) |
| Phase 15 应用编排与运行资源生命周期 | 完成、归档 | [`iteration_15_app_orchestration_lifecycle.md`](../archive/iteration_15_app_orchestration_lifecycle.md)；当前边界 [`runtime_lifecycle_matrix.md`](../reference/runtime_lifecycle_matrix.md) |
| Phase 16 档案会话、持久化与玩家槽位 | 完成、归档 | [`iteration_16_archive_session_slots.md`](../archive/iteration_16_archive_session_slots.md)；当前边界 [`archive_session_matrix.md`](../reference/archive_session_matrix.md) |
| Phase 17 玩法与表现模块边界 | 完成、归档 | [`iteration_17_gameplay_module_boundaries.md`](../archive/iteration_17_gameplay_module_boundaries.md)；当前边界 [`gameplay_module_matrix.md`](../reference/gameplay_module_matrix.md) |
| Phase 18~20 综合收尾 | 完成、归档 | [`iteration_18_20_comprehensive_closeout.md`](../archive/iteration_18_20_comprehensive_closeout.md) |
| Phase 21 独立立项与平台发布 | 完成；21-2A 最低设备确认与 21-2B 平台测量暂缓 | [`spine_platform_baseline.md`](../reference/spine_platform_baseline.md)；暂缓边界见 [`status.md`](../reference/status.md) |
| Phase 22 `Global` 状态与入口契约 | 完成、归档 | [`iteration_22_global_state_boundary.md`](../archive/iteration_22_global_state_boundary.md)；当前清单 [`global_runtime_inventory.md`](../reference/global_runtime_inventory.md) |
| Phase 23 关卡、宠物与档案数据边界 | 完成、归档 | [`iteration_23_pet_domain_boundary.md`](../archive/iteration_23_pet_domain_boundary.md)；当前契约 [`pet_domain_contract.md`](../reference/pet_domain_contract.md) |
| Phase 24 UI 与成长命令边界 | 完成、关闭 | [`iteration_24_ui_growth_boundaries.md`](../archive/iteration_24_ui_growth_boundaries.md)；当前边界 [`ui_panel_contract_matrix.md`](../reference/ui_panel_contract_matrix.md) |
| Phase 25 战斗实体行为切片 | 完成、关闭 | [`iteration_25_combat_behavior.md`](../archive/iteration_25_combat_behavior.md)；当前映射 [`combat_behavior_matrix.md`](../reference/combat_behavior_matrix.md) |
| Phase 26 平台与发布验证 | **长期暂缓；未启动** | §3 与 [`current-iteration.md`](current-iteration.md) §2 |
| Phase 27 Theme 与字体契约收敛 | 完成、关闭 | [`iteration_27_theme_font_convergence.md`](../archive/iteration_27_theme_font_convergence.md)；当前事实 [`theme_font_inventory.md`](../reference/theme_font_inventory.md) |
| Phase 30 关卡布局数据契约 | 完成、归档 | [`iteration_30_level_layout_data_contract.md`](../archive/iteration_30_level_layout_data_contract.md)；当前契约 [`level_layout_contract.md`](../reference/level_layout_contract.md) |
| Phase 31 引擎废弃 API 与局部现代化 | 完成、归档 | [`iteration_31_33_modernization_gap_matrix.md`](../archive/iteration_31_33_modernization_gap_matrix.md) |
| Phase 32 UI Theme 契约 | 完成、归档 | [`iteration_32_ui_theme.md`](../archive/iteration_32_ui_theme.md)；当前契约 [`ui_theme_contract.md`](../reference/ui_theme_contract.md) |
| Phase 33 装备数据契约 | 完成、归档 | [`iteration_33_equipment_data_contract.md`](../archive/iteration_33_equipment_data_contract.md)；当前契约 [`equipment_data_contract.md`](../reference/equipment_data_contract.md) |
| Phase 34 7.0 内容回植 | 完成、待发布验证 | [`status.md`](../reference/status.md)；角色 8、2P、UI 与系统修复见状态页 |
| Phase 35 7.1 内容回植 | 完成、待发布验证 | [`status.md`](../reference/status.md)；L3 收口完成，PCK/release 暂缓 |
| Phase 36 7.2 内容回植 | 完成、待发布验证 | [`status.md`](../reference/status.md)；L3 收口完成，PCK/release 暂缓 |
| Phase 37 7.3 内容回植 | **完成（37-0~37-6；L3 通过；PCK/release 暂缓）** | [`current-iteration.md`](current-iteration.md)；目标 7.3，PCK/release 暂缓 |
| Phase 38 7.4 内容回植 | **完成（38-0~38-6；L3 通过；PCK/release 暂缓）** | [`current-iteration.md`](current-iteration.md)；目标 7.4，PCK/release 暂缓 |
| Phase 28 全局通信与派生属性契约 | **完成（28-1、28-2、28-3）** | [`current-iteration.md`](current-iteration.md) §1.7；移除 `Signals`、玩家与宠物被动契约 |
| Phase 29 `Scene/` 脚本落位 | **进行中（29-0、29-1、29-2A、29-2B、29-2C 完成；29-3 未启动）** | [`current-iteration.md`](current-iteration.md) §1.8；56 个场景脚本归 `Script/<domain>/` |

**编号边界**：Phase 22~29 为本轮新增候选（Phase 28/29 于 2026-11-09 登记），不重开已归档的 Phase 30~33；历史归档保持原貌。已完成阶段的批次、截图、计数与逐项验证只在归档中保留。

## 2. 总体架构工作流

方向是 Godot 原生场景组合的模块化架构，而不是资产格式、类层次或目录外观统一。

| 工作流 | 目标契约 | 收敛结果 |
|:---|:---|:---|
| 应用编排 | 目标契约 §2~§3、§4.3 | 有唯一切换入口，装配/输入交接/清理明确，异步结果不写入过期场景 |
| 档案与双人会话 | §3、§5 | 档案、共同账本、玩家槽位分离；保存与 UI 不依赖全局视图交换 |
| 战斗与关卡 | §4 | 来源与结算单一真源，继承稳定、组合按需，保留已验收行为 |
| 数据与资源 | §5、§7 | 静态 Resource、可变状态、JSON 编解码分离；AtlasMetadata 是有限试点 |
| UI/输入/音频 | §6 | 显式操作者、命令/查询、分层输入与完整退出，不把业务塞入界面 |
| 构建/发布/平台 | §7.5、§8、§11 | 确定性、依赖闭包、实际包加载与平台性能分别证明 |
| 模块/目录 | §9 | 保留类型顶层，在内部功能聚合；仅有收益证据才迁移路径 |

### 2.1 依赖与顺序

| 工作流 | 当前状态 |
|:---|:---|
| 应用编排 / 档案 / 玩法模块（Phase 15→16→17） | 已完成；退出/资源所有权与槽位边界稳定 |
| `Global` → 宠物 → UI/成长 → 战斗实体（Phase 22→23→24→25） | 已完成；行为与命令边界已关闭 |
| 数据/资源（Phase 14、30、33） | 已完成；构建源、Catalog 与发布闭包已验证 |
| UI Theme / 字体（Phase 32 → 27） | 已完成；token 源、语义基类与字体角色已收口 |
| 平台/发布（Phase 21、26） | 21 可执行项完成；26 长期暂缓 |
| 全局通信 / 派生属性 / 脚本落位（Phase 28→29） | Phase 28 已完成；Phase 29 进行中（29-0、29-1、29-2A、29-2B、29-2C 完成） |

约束：

- 这是已完成顺序，不是新的实施队列；后续阶段按真实调用、共享状态与验证条件重新确认。
- 独立清单调查与只读设计可提前；平台工作可独立推进。
- 不预先决定精确服务类名、组件数量、Autoload 目标数量或全局目录布局；进入候选阶段前补调用面、边界、原子迁移批次与可执行验收。

## 3. Phase 26：平台与发布验证（长期暂缓）

**目标**：把“路径闭包”“release 启动”“验证机性能基线”“Spine 平台支持”分别证明。

**前置**：可做只读规划；涉及资源/导出变化时再与当前代码批次协调。

**非目标**：不把未验证平台写成支持，不用 PCK 可达替代 release，不用 headless 替代 HUD/VRAM。

| 批次 | 范围 |
|:---|:---|
| 26-0 平台支持矩阵 | 承诺/未验证平台与退出条件；设备、OS、渲染后端、Spine 库、导出模板与许可证；Windows x86_64 先行 |
| 26-1 Windows release 启动与最小包 | 冷启动、主菜单、存档列表、`level_1` 进入与退出；区分离线验证包与最小发布包；失败显式 |
| 26-2 验证机性能基线 | 首帧、战斗峰值 VRAM、加载时长、重复进出与退出；至少一场战斗、一个 Boss、一次返回/重战；固定验证机与渲染元数据，只做同机对照（ADR-027） |
| 26-3 Spine 平台决策 | Windows 之外是否有设备/许可证/导出证据；不把 `.gdextension` 声明当作运行库已入库 |
| 26-4 阶段验收 | 平台矩阵、release 记录、性能证据与发布包结论；未支持平台有明确原因 |

**恢复条件**：平台矩阵、设备、导出条件与 release 证据同时明确。

## 4. 独立平台与内容工作

### 4.1 Spine 与目标平台

先明确目标平台，再核对 Godot/Spine 运行库、许可证、扩展二进制、导出能力与设备验证；未验证平台不得宣传可用。不把 macOS/Linux/Android/Web 全部补齐写成默认承诺。

Windows release 的已有验证见 [`status.md`](../reference/status.md)。后续战斗负载、峰值驻留、首帧和重复进出需要验证机实测；最低配置与其他平台未验证（ADR-027）；PCK 路径可达不代替加载与性能。

### 4.2 内容回植

只有目标版本、合法来源与范围确认后才进入活动批次；按三方语义合并接入当前总体架构，不恢复旧路径/旧后端/旧存档迁移链。

7.0 回植已完成角色 8 小龙女、2P、角色选择/技能页/自动战斗、背包/幻化/翅膀/坐骑与 7.0 系统修复；当前验证与边界见 [`status.md`](../reference/status.md)。7.0 release PCK、全量关卡回归与外部云存档服务差异不在本轮 gameplay 收口内。

Phase 35 已完成 7.1 回植与 L3 收口：参考工程/台账、基础数据/攻击区域、Longnv/技能、关卡/北俱芦洲/场景、菜单/UI/剩余脚本均已落地；PCK/release 与最低配置/其他平台验证待最终发布统一执行。7.2 已于 Phase 36 完成，7.3 已于 Phase 37 完成。

Phase 36 已完成 7.2 内容回植与 L3 收口：年兽宠物、首批觉醒、V7.2 公告、喜鹊叠加、幻化与昵称等生产差异均已接入；PCK/release 与最低配置/其他平台验证继续暂缓，7.3 已于 Phase 37 完成。

Phase 37 已完成 7.3 内容回植与 37-6 缺口修复：二进制/SGXZ、参考源码/场景、数据资产、角色/技能、系统/UI、2P、语义缺口与 L3 均已收口；PCK/release 与最低配置/其他平台验证继续暂缓。

Phase 38 已立项 7.4 内容回植，38-0 已完成：7.4 目录与全部 **40,571** 个文件块 MD5/大小通过，参考树 **791/791** `.gdc` 与 **1,175/1,175** `.scn` 转换成功；7.3→7.4 新增 **296**、删除 **0**、语义生产变化为脚本 **34**、场景 **25**、数据 **1**、资产 **183**、资源 **16**、重映射 **56**。38-1 已完成数据与资产接入：**91** 个源 PNG、**16** 个 `AtlasTexture` `.tres` 与 boot splash（像素一致；38-6d 接入项目设置）已接入，未复制 `.ctex`/`.import`/`.res`/`.remap`；4 个 SVG 按钮按 PNG 接入；Atlas **4,015**、FrameSequence **288**、怪物帧 **152**、装备 **1,127**、关卡预载 **101**、原始数据清单 **1,033** 全部通过。38-2 已完成角色与技能脚本：SoulCardData/Runtime/Effect/BossVisual、EliteAttack/BossMechanics/BossStats/Level_Elite、SoulCardPanelBase、18 个魂卡特效场景与 31 个既有特效纹理已接入；BaseHero/BaseMonster/BaseRoleProperies、Monster 77/78/139 与 Level 22 技能限制已收口；`check_all` **9/9**、health **816 脚本 0/0/0**、`level_1` 与 `--role 6/7/8` **4 阶段 0/0/0**、`level_elite` 通用冒烟 **PASS**、变更影响关卡回归 **129/129 + 5 SKIP**（含 `level_elite`）。38-3 已完成系统/菜单/UI 与公告：SoulCardPage/LoadoutPage/RolePreview/SelectionGlow/FoilPreview、EliteChallengePage、Map_0 四 PNG 入口、GameAnnouncement V7.4、set_menu/defeat 精英返回、load_scene 启动进度、startup_loading 主场景；未新增 AndroidIntegrity Autoload，未启用传感器；`check_all` **9/9**、health **823 脚本 0/0/0**、`level_1`/`level_elite` 冒烟 **0/0/0**、变更影响回归 **129/129 + 5 SKIP**（回退全量 356.4s），UI 页面/入口/公告探针通过。38-4 已完成 2P 与剩余脚本闭合：`coop_probe_runner` **38/38 PASS**（298.29s），覆盖相机/HUD/Buff/灵气/被动/技能键/面板操作者/槽位/全灭死亡/快照互斥；魂卡运行时与属性走槽位入口，新 UI 页面提供 `LocalCoop.data_for(self)` 操作者，剩余脚本差异按台账闭合。38-5 L3 已完成；38-6 缺口修复完成：`check_all` **9/9**、health **823 0/0/0**、全量回归 **129/129 + 5 SKIP**（339.7s）、场景探针 **31/31**（340.68s）、双人 **38/38**、档案 **344 检查 PASS**、命名/白名单 100%；PCK/release 与最低配置/其他平台验证仍暂缓。

## 5. 跨阶段纪律与验收

1. 保持 Phase 13 登记例外的机读冻结；不在活跃路线复制会漂移的条目数或历史迁移台账。
2. 功能子目录不是第二套顶层；`source/` 路径迁移走 `rename_path.py`，同步引用/UID/导入/Catalog/发布清单。`_bundled` 必须按实际格式取证，不以文件名搜索结果宣布不存在。
3. 每批以一个职责与调用面闭环，迁移正式调用方、删除旧入口、验证正常/边界/失败/退出路径；回滚用版本控制，不保留永久双实现。
4. 静态、引擎、生产路径冒烟、相关回归、发布包与性能验证按 [`acceptance.md`](../reference/acceptance.md) 的变更矩阵触发；不要求每次文档或清单修改都做 release，也不以通用套件代替新增行为验证。
5. 架构目标与进度分开；当前决定由 [ADR-021](../decisions/ADR-021-project-wide-target-architecture.md) 解释，后续具体实现选择按需追加 ADR。归档和已接受 ADR 保留历史，不改写。

## 6. 关联文档

- [`current-iteration.md`](current-iteration.md)：当前候选与恢复入口
- [`../reference/status.md`](../reference/status.md)：当前验证与已知边界
- [`../reference/architecture.md`](../reference/architecture.md)：当前运行时架构
- [`../reference/acceptance.md`](../reference/acceptance.md)：验收分层与变更矩阵
- [`../archive/README.md`](../archive/README.md)：已完成阶段的实施记录
