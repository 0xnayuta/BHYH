# BHYH 当前候选迭代

> **状态**：Phase 18~20 已归档；Phase 21 全部可执行项完成（21-1A/1B/1C、21-2C、21-3A~J、21-4A/4B），21-2A 最低设备确认与 21-2B 暂缓；Phase 31-0A/31-1 已完成，31-0B 评估后拒绝；**Phase 30-1~30-4 已完成并归档**（[归档页](../archive/iteration_30_level_layout_data_contract.md)）；**当前候选为 Phase 32 UI Theme 契约与 Phase 33 装备数据契约，均未启动**。依赖已满足，推荐先执行 32-0/32-1。平台决策见 [`spine_platform_baseline.md`](../reference/spine_platform_baseline.md)，现代化差距见 [`modernization_gap_matrix.md`](../reference/modernization_gap_matrix.md)。
> **版本**：6.9；不新增玩法、任务与掉落，不改变数值、动画时序、输入映射、存档格式、本地双人共享规则或显示基线。
> **职责**：本页只展开当前候选；Phase 18~20 的结论、验证与延期去向见归档页，Phase 13~17 见 [`archive/README.md`](../archive/README.md)。
> **依据**：[`总体目标契约`](../standards/target_architecture_contract.md)、[`godot_design_standard.md`](../standards/godot_design_standard.md)、[`autoload_boundary_matrix.md`](../reference/autoload_boundary_matrix.md)、[`runtime_frames_exceptions.md`](../reference/runtime_frames_exceptions.md)、[`acceptance.md`](../reference/acceptance.md)、[`status.md`](../reference/status.md)。

## 1. 阶段边界与决策

### 1.1 Phase 21/31 已完成边界

1. 完成 21-1A 的目标平台、Spine 运行时版本与许可证决策，并在选定平台完成加载验收；未确认平台前只写决策草案，不宣称跨平台支持；
2. 在真实目标设备上记录平台与发布证据，不用 headless 或单平台结果替代；
3. 保持 21-3 收口后的 `Global` 工厂边界：`add_*` 全部为族工厂薄转发，不新增全局入口、Autoload 或回落；仅按新需求评审；
4. 保持 21-4A/4B 已完成的资源转换与符号层修复结论，不重开已拒绝的 `pet_tiger_boss_base` 转换。

### 1.2 Phase 21 不在本阶段

- 不重写 `base_hero`/`base_monster`/`base_through_level` 继承结构；
- 不改变伤害公式、Buff 数值、掉落、关卡时序、输入映射、物理层、存档格式或共享规则；
- 不把 `PlayerData.player_data` 整体改成 Resource；
- 不做全仓目录搬迁或全仓 `get_node` 替换；
- 不重新打开 Phase 18~20 已关闭的归属、命令、档案顺序与守卫结论。

### 1.3 基线与不变量

| 项 | 事实 |
|:---|:---|
| Autoload | 11 个（10 业务 + 1 编辑器调试桥）；`Global` 以普通子节点与 `RunContext` 承载运行职责，清单见 [`architecture.md`](../reference/architecture.md) §2.4 |
| `Global` 规模 | 不在此复制行数、函数与入口计数；当前规模与薄转发统计以 [`status.md`](../reference/status.md) 为准 |
| 静态守卫 | `contract_scan.py` 20 类；`check_all` 九维；契约 ERROR=0、WARNING ≤ 预算 |
| 运行时夹具 | 按 `acceptance.md` 的 L2 档位执行；探针清单由各 runner 维护，历史结果见 `status.md` |
| 资源闭包 | 19-3C 的 PCK 快照只在资源未变化时有效；资源变更后必须重跑 |

矩阵计数口径见各参考页；本页不复制历史数字。

### 1.4 当前候选（Phase 32/33）

- **Phase 32**：把 6,830 处静态场景内联样式收敛到 Theme 与类型变体；先做 `game_set` 单面板试点，截图与控件几何对照通过后再分批；
- **Phase 33**：把 `all_equipment_data.gd` 的 1,035 条装备定义迁出为 Resource Catalog，规则/随机/玩家实例分离，逐字段保持语义；
- **顺序**：先 32-0/32-1；32-1 后可启动 33-0/33-1 数据层；33-3 消费方迁移等待 32-2 覆盖对应面板；
- **共同边界**：不改玩法数值、掉落、输入映射、存档格式与显示基线；不以统计归零替代行为验收。

## 2. Phase 21-1：独立立项（承接 20-1A/20-1C/20-1D）

**目标**：每项给出采用/延期/拒绝结论、owner 与前置条件；采用项落地并有验收。owner 采用**角色责任**，公开仓库不绑定个人姓名；实际人员由项目维护者在内部指派，角色或前置变化时同步修改本节。

1. **21-1A Spine 平台决策（完成：Windows-only，2026-10-31）**：目标平台定为 **Windows x86_64**；Spine 保持官方 **4.3 / Godot 4.7.2** 构建，已验证本地二进制与官方包逐字节一致，不进行版本升级；其它平台延期/未验证。**Owner**：项目维护者（平台/许可证决策）；项目维护者（构建/加载验证）。详见 [`spine_platform_baseline.md`](../reference/spine_platform_baseline.md)。
2. **21-1B `_bundled` 历史场景（完成，2026-10-31，拒绝转换）**：公共工程 1,136 个 `.tscn` 全部为 `[gd_scene format=3]` 文本，`git ls-files '*.scn'` 与 `RSRC` 二进制场景均为 0；私人素材仓无 `.scn`/`.tscn`。`source/.godot/exported/*.scn` 为被忽略的导出缓存，`_bundled` 只是缓存内部属性，不作为源场景转换。`Scene/` 1,135 个场景中仅 `load_scene.tscn` 头含 UID，1,134 个无头 UID（无重复）；文本场景按路径加载且门禁通过。转换范围为 0，关闭 20-1C。
3. **21-1C 类型化 Atlas accessor（完成，2026-10-31）**：复核六个直接消费者均只经 `AtlasMetadataView`；`animation_back_atlas_names`/`animation_front_atlas_names` 改为 `Array[String]`，其余字段已为值类型。不新增嵌套 typed Resource、不加 UID、不重开 `data_for`/`validate_path`/`clear_cache`；新增 `atlas-accessor` 合成 metadata 探针覆盖两类 schema、越界与失败语义。

**必须验证**：每项有结论与 owner；采用项在目标平台/真实资源上验证；不把 Windows 或 headless 结果当跨平台通过。

## 3. Phase 21-2：平台与发布验证（承接 20-2A/2B/2C）

**目标**：把资源闭包与目标设备验证分开记录。

1. **21-2A 目标平台矩阵（平台/后端已完成，最低设备确认暂缓）**：Windows x86_64 为唯一目标平台，渲染后端以工程默认 `mobile` 为准；Linux/macOS/Android/Web/iOS 全部延期/未验证；**最低设备未声明**，确认工作与 21-2B 一并暂缓；本批次不再有可执行项。**Owner**：项目维护者（发布）；详见 [`spine_platform_baseline.md`](../reference/spine_platform_baseline.md)。
2. **21-2B VRAM/首帧/战斗负载（暂缓）**：无 Linux/macOS 等目标设备；按当前决定，Windows 侧测量本轮也不做。**Owner**：项目维护者（发布/设备）；恢复条件为取得可复现目标设备。
3. **21-2C release 包（完成，2026-11-01）**：PCK/依赖闭包 **4,100/4,100 可达**（约 7.56 GB，验证用 `all_resources` 预设）；Windows release 验证包启动真实生产主场景并进入 `level_1`，报告 **ok=true**（3.762s），最终日志 **0 ERROR / 0 WARNING**。验证包使用临时冒烟驱动，已删除并恢复主场景。**Owner**：项目维护者（发布/构建）。

**必须验证**：目标设备数据可复现；release 包能启动并进入代表关卡；日志干净；未测平台明确标注。21-2B 暂缓期间，不得用 Windows 验证机或 headless 结果充当目标设备基线。

## 4. Phase 21-3：`Global` 工厂族收口（已完成）

**结果**：剩余 `add_*` 已按功能族迁入既有工厂或新族，保留薄转发与公开入口；当前无未迁移入口。

1. **21-3A 锻造/分解族（完成，2026-10-30）**：`add_forge_help`、`add_forges`、`add_decompose_help`、`add_decompose_instance` 迁入 `ForgeFactory`；`add_forge_box` 全仓 0 调用方，随 `forge_box` 槽位删除；
2. **21-3B 角色/怪物弹体族（完成，2026-10-30）**：7 个弹体入口迁入 `ProjectileFactory`，slim/streaming 路径解析与法宝弹体路径表迁入；来源写入仍经 `Global._assign_attack_source`；
3. **21-3C 效果族（完成，2026-10-30）**：6 个效果入口迁入 `EffectFactory`，灵魄加成仍由 `PaSkill` 计算；
4. **21-3D 菜单/设置族（完成，2026-10-30）**：`add_game_set`、`add_skill_key_set`、`add_music_set`、`add_ldl`、`add_gm_infor`、`add_learn_skill` 迁入 `MenuPanelFactory`；`add_set_menu` 全仓 0 调用方，随槽位删除；`add_skill_select` 已是 `BackpackFactory` 薄转发；顺带修复 `add_gm_infor` 在 `CanvasLayer` 上写 `z_index` 的运行时错误；
5. **21-3E buff 族（完成，2026-10-30）**：`add_buffinfor` 并入 `PopupFactory`，`add_buff_icon` 并入 `CombatPresentationFactory`；`add_buff`/`add_buff_info`/`add_buff_icon_text`/`add_magp_infor` 已是既有薄转发；
6. **21-3E 关卡场景族（续，完成，2026-10-30）**：`add_stage`、`add_z_lw_stage`、`add_zztw_trap`、`add_dsg_choose` 迁入 `LevelSceneFactory`；
7. **21-3F 展示文本与技能面板族（完成，2026-10-30）**：新增 `ShowTextFactory`（字体文本/任务标题/评分）与 `SkillPanelFactory`（角色/变身技能面板、法宝说明）；`add_star`、`add_role_magic_need` 全仓 0 调用方，随槽位删除；技能面板预热改调 `prime_skill_scenes()`；
8. **21-3G 场景/提示与地图浮层混合族（完成，2026-10-31）**：`add_some_monster_help`/`add_letter_for_player` 并入 `ShowTextFactory`；`add_mosaic_help`/`add_mosaic_instance` 并入 `MenuPanelFactory`；`add_cure_times_box`/`add_trans_box` 并入 `ShopFactory`；新增 `MapOverlayFactory` 接管 `add_hdzm`/`add_lsh`/`add_lxdy`（临时 UI 登记与窗口守卫保持）；
9. **21-3H 角色/选择面板族（完成，2026-10-31）**：`add_basic_ar_button`/`add_change_bg`/`add_cd_jm` 并入 `MenuPanelFactory`；`add_role_information`/`add_h_hjm` 并入 `BackpackFactory`；`add_role_button`、`add_choose_player`、`add_change_clothes_jm` 全仓 0 调用方，随槽位删除；
10. **21-3I 丹药与游戏公告（完成，2026-10-31）**：`add_basic_pellet` 并入 `ProjectileFactory`；`add_game_announcement` 并入 `PopupFactory`，保留临时 UI 登记与 `CanvasLayer/Node2D/Control` 定位语义；
11. **21-3J 浅攻与关卡相机（完成，2026-10-31）**：`add_role1_shallow`/`add_role2_shallow` 并入 `EffectFactory`（来源写入仍经 `Global._assign_attack_source`）；`add_camera` 并入 `LevelSceneFactory`，相机所有权定为关卡场景，由调用方挂到角色节点；
12. `Global.add_*` 已全部为族工厂薄转发；后续只按新需求评审，不继续扩张工厂。

**必须验证**：每次迁移删除被替代的槽位字段，保留同名薄转发；`ui-factories` 或对应运行时探针覆盖返回形状与缓存；战斗相关族追加 `level_1` 冒烟与全量回归。**21-3A~J 验证**：对应工厂探针通过（含清缓存重载、`CanvasLayer` 语义、buff 拒绝语义、运行期 UI 槽位复用与死入口断言）；`check_all --godot-bin` 8/8；`level_1` PASS；全量回归与夹具明细见 `status.md`。

## 5. Phase 21-4：资源转换器与建帧遗留

1. **21-4A 转换器扩展（完成，2026-10-30）**：扩展 `convert_numbered_frames.py` 支持多动作 profile（每动画可选 `count` 与裁剪规则）。
   - `eight_immortals_boss`：8 个 Boss × 7 状态迁移到 `body_actions/body_frames.tres`；166 hit2 裁 250×250、168 hit2 裁 250×200 在构建期固化；
   - `three_prince_boss`：木吒/金吒迁移到 `three_prince/{root}/body_frames.tres`；木吒 hit3 的 292×250 帧居中裁成 250×250；哪吒保持既有 atlas 资源；
   - `pet_tiger_boss_base`：**拒绝转换**。声明的 `model/frames/stage1~4/r*_c*.png` 在工作区 0 个文件；预构建 `pet_tiger_stage*_frames.tres` 只有 9 个动画，缺 `hit5`/`hit6`，不能作为替代。保留运行期构建并登记资产缺失；
   - `runtime_frames_allowlist` 移除八仙与木吒/金吒条目；新增 `action-frames` 探针 PASS；
2. **21-4B `weiyang_palace_boss` 符号层（完成，2026-10-30）**：路径修正为 `swf_png/3007/atlas/swf_png_3007_frames.tres`；嘴/眼符号层恢复（78/17/55 帧），初始帧 0/16/54、镜像正确，嘴部可推进到第 50 帧发射；新增 `weiyang-symbol` 探针 PASS。运行期复制保留在 allowlist，不新增条目。

**必须验证**：补资源项迁移后 `runtime_frames_allowlist` 只减不增；缺陷修正有前后帧与技能时序证据。

## 5A. Phase 30：关卡布局数据契约（已完成并归档）

Phase 30-1~30-4 已完成；完整设计、迁移批次、快照与验证记录见 [`iteration_30_level_layout_data_contract.md`](../archive/iteration_30_level_layout_data_contract.md)。当前仍有效的契约与逐项边界见 [`level_layout_contract.md`](../reference/level_layout_contract.md) 与 [`phase_30_4_script_decisions.md`](../reference/phase_30_4_script_decisions.md)。本页不再展开已完成阶段。

## 5B. Phase 31：引擎废弃 API 与局部现代化（已完成批次）

> **状态**：31-0A **已完成（2026-11-01）**；31-0B **评估后拒绝**（保留旧数字图）；31-1 **已完成（2026-11-01）**。不依赖 Phase 30。
> **依据**：[`modernization_gap_matrix.md`](../reference/modernization_gap_matrix.md) §3.1、§3.2。

### 31-0A 顺手包（已完成）

| 子项 | 现状（2026-11-01 实测） | 目标 |
|:---|:---|:---|
| A2 `TileMap` → `TileMapLayer` | 基类 1 个 `TileMap` 节点；**12 个关卡场景**覆盖 `layer_0/tile_data`；15 个覆盖 `tile_set`；106 个场景引用 `BackGround/floor_2`；无 `layer_1+` 属性；12 个文件 alternative 全为 0，source id 为 0（`level_5` 为 2） | 全仓 `type="TileMap"` 归零；格子坐标/源/图集/替代项逐格一致 |
| B4 `collision_layer` 具名化 | 脚本内裸整数 **30 处**：`0`×11、`1`×1、`2`×8、`4`×7、`16`×1、`32`×2 | 具名常量集中定义；裸整数归零且语义有调用点依据 |
| B5 `load_item_icon` 去重 | 定义 **19 处**（21 个文件 99 处调用）；至少 5 种兜底语义 | 共享解析器 + 分模式调用；`^func load_item_icon` 归零 |

**31-0A 出口（已验证）**：`type="TileMap"` 与 `layer_0/tile_data` 归零，12 关 23,561 个格子逐格一致；`collision_layer` 裸整数归零；`load_item_icon` 定义归零且 5 种图标语义探针一致；`check_all --godot-bin` **9/9 PASS**；8 个迁移关卡代表冒烟与 `level_1` PASS；全量回归 **128/128 PASS + 5 SKIP**（708.9s）。

**31-0A 不做**：不把 `TileMapLayer` 迁移顺带改成数据驱动地形；不把物理层重构为位运算工具类；不改变任何图标的兜底优先级。

### 31-0B 数字图 → BMFont（评估后拒绝）

- `Art/all_number` 引用 25 处 / 3 个文件（`back_pack.gd` 等级两位拼接、`backpack_level_display.gd` TextureRect 数字数组、`damage_number.gd` 伤害数字）；
- 现有 7 个 BMFont（`beishu`/`zhanlishuz`/`redf`/`bluef`/`green`/`fp1`/`fp2`）均与数字图不同源：等级图 47×50、可见内容 30×38；字体字形 16–30 px，最佳 `beishu` 归一化 alpha IoU 仅 **0.866**、颜色归一化差异 **0.988**；`zhanlishuz` IoU **0.616**；
- 伤害数字有 15 个样式目录（`cure`/`cure_mp`/`reduce_mp`/`lj`/`magic`/`magiccrit`/`monster/*`/`other_number`/`physics`/`physicscrit`/`real`/`realcrit`），现有字体只覆盖少数颜色，且正体/斜体、描边与填充样式不一致，没有等价字体；
- 临时 `Label + beishu` 运行渲染对照：字宽/步进（字体 20 vs 当前 24）与描边粗细不同，放大到 50 px 会损失清晰度；
- **结论：保留旧数字图，不替换**。如未来必须迁移，需从现有数字图生成同源 BMFont（构建期私有派生资源），不能直接使用 ZMWS BMFont；该路线不纳入 31-0B。

### 31-1 视差迁移（已完成）

- 89 个场景 **95 个 `ParallaxLayer`** + 1 个 `ParallaxBackground`（`base_through_level.tscn`）迁移完成；另有 8 个场景仅覆盖继承 `floor_2` 的 `position`，一并转成 `scroll_offset`，合计修改 **97 个场景文件**；
- 容器 `BackGround` 由 `ParallaxBackground` 改为 `CanvasLayer`（`layer = -100`、`follow_viewport_enabled = true`），每个层改为 `Parallax2D`；该组合经运行时 transform 对照与旧实现逐点一致；
- 语义映射：`motion_scale→scroll_scale`、`motion_mirroring→repeat_size`、`motion_offset→scroll_offset`；`position` 在 `Parallax2D` 会被进入树时覆盖，统一转为 `scroll_offset`；
- **验证**：89 个场景 × 4 个相机位置、**2,520 个节点** transform 对照；除 `level_2` 子像素（0.06–2.235 px）与 `level_4` 不可见 `stage` 外一致；7 个代表场景前后截图，3 个完全 0 差异，其余 4 个差异像素 ≤0.005%、最大通道差 ≤0.83；7 个代表关卡冒烟 PASS；全量回归 **128/128 PASS + 5 SKIP**（707.5s）。
- 已知例外：`level_4` 的 `stage` 是 `BackGround` 下唯一非 Parallax 子节点且 `visible=false`；`CanvasLayer.follow_viewport_enabled` 会改变其 transform，但当前不可见，截图无差异。

## 5C. Phase 32：UI Theme 契约（已规划，未启动）

> **状态**：未启动。依赖 Phase 30 已归档、Phase 31 已完成；本条是执行计划，不代表已改场景或已建 Theme。
> **依据**：[`modernization_gap_matrix.md`](../reference/modernization_gap_matrix.md) §3.2 B1、[`target_architecture_contract.md`](../standards/target_architecture_contract.md) §6。
> **目标**：把静态场景内联样式收敛为可复用 Theme 资源与 `theme_type_variation`，使字号/颜色/描边/按钮状态有统一来源；不以减少计数替代视觉与交互验收。

### 32.1 现状与问题（2026-11-01 基线）

| 项 | 实测 | 说明 |
|:---|:---:|:---|
| `theme_override_*` | **6,830 处** | 分布于 **135 个 `.tscn`**；无 `.gd` 直接使用 `theme_override_` |
| `Label` / `Button` 覆盖 | **3,921 / 2,380** | 合计 6,301 处，占静态覆盖约 92% |
| 属性分类 | colors 1,745 / styles 1,625 / constants 1,398 / fonts 1,056 / font_sizes 1,006 | 五类合计 6,830 |
| `FontFile` 场景引用 | **207 处** | 涉及 **12 个字体文件**；不同面板有不同字体族 |
| Theme 资源 | **1 个 `Theme` 类型的 `.tres`** | `backpack_action_theme.tres`，仅 2 个场景引用；`.theme` 扩展文件为 0 |
| `theme_type_variation` | **0 处** | 当前没有变体契约 |
| 脚本动态主题调用 | `add_theme_*` **383 处 / 39 个文件** | 属于运行时状态/数据驱动，不与静态场景迁移混算 |

问题不是单纯的属性数量，而是：

1. 相同按钮/标题/正文样式在多个场景复制，修改全局字号或颜色必须逐场景编辑；
2. 字体与字号缺少层级，`Label`/`Button` 的变体没有名称与审查边界；
3. 现有 1 个 Theme 只覆盖背包按钮的一小部分，不能作为全工程主题；
4. 直接设置 `gui/theme/custom` 会改变未迁移面板，必须先试点、再分批、最后决定全局应用。

### 32.2 契约与边界

- **资源**：新增 `source/Scene/theme/bhyh_theme.tres` 作为候选基础 Theme；先审计现有 `backpack_action_theme.tres`，能复用则扩展并迁移其 2 个引用，不并行保留两套长期主题。
- **变体命名**：`theme_type_variation` 使用 `PascalCase`，例如 `TitleLabel`、`SettingLabel`、`BodyLabel`、`CaptionLabel`、`PrimaryButton`、`MenuButton`、`ToggleButton`、`DangerButton`；最终名单由 32-0 审计后固定并登记。
- **迁移范围**：只迁移静态 `.tscn` 中的 `theme_override_*`。脚本中的 `add_theme_*` 若表达品质色、血量或运行时状态，保留为动态例外；不得为了归零把数据驱动颜色写死进 Theme。
- **字体**：保留现有字体族与字形，不用单一默认字替换 12 个字体；Theme 变体携带精确字体、字号、描边和阴影值。
- **应用方式**：试点在面板的 Control 子树设置 `theme`，不在 `project.godot` 设置全局 `gui/theme/custom`；全局应用只能在覆盖率达到要求、且未迁移面板有明确豁免后评审。
- **显示基线**：保持 1280×800 设计画布、1600×1000 默认窗口、16:10、`canvas_items` + `expand` 与现有 HUD 布局；Theme 不改变控件尺寸、锚点或文本换行。

### 32.3 批次

| 批次 | 内容 | 出口 |
|:---|:---|:---|
| 32-0（规划） | 生成 135 场景/6,830 覆盖的基线清单；定型 Theme 路径、变体命名、例外规则与截图协议；新增 `docs/reference/ui_theme_contract.md`（实现时） | 基线可复现；命名与例外评审通过；不改运行场景 |
| 32-1（试点） | 选择 `main_menu/game_set.tscn`：**239 处覆盖**，Button 175、Label 56、HSlider 4、OptionButton 2；对 `Bg/BGColor` 子树与 `Bg/Return` 分别应用同一 Theme（该 10 处返回按钮不在 `BGColor` 子树），建立首批 Label/Button/Slider 变体 | 试点场景静态覆盖归零或仅余登记例外；控件几何、字体、字号、颜色与截图对照一致；设置开关/音量/选项交互 PASS；通过后才允许分批 |
| 32-2（分批） | 按样式族迁移，不按文件名扫描：① Label 密集面板；② Button 密集面板；③ 混合输入/列表面板；④ 其余 135 场景。每批先快照、再迁移、后删除未引用 subresource | 每批有前后对照与场景清单；未迁移场景不假装完成；`theme_override_*` 计数只减不增 |
| 32-3（控件补齐） | 覆盖 `OptionButton`、`CheckBox`、`CheckButton`、`LineEdit`、`HSlider`、`Panel`、`PanelContainer`、`TabBar`、`PopupMenu`、`ItemList` 等非 Label/Button 控件 | 这些控件有明确变体或登记例外；输入、焦点、禁用、悬停状态不漂移 |
| 32-4（收口） | 合并/退役旧 `backpack_action_theme.tres`；新增 `scripts/theme_override_audit.py` 与例外清单；评估是否设置全局 Theme；更新 architecture/status/索引 | 场景静态覆盖为 0 或全部登记；无新增未登记覆盖；全量 UI 回归与文档一致 |

### 32.4 分批策略与验收

1. **先易后难**：32-1 只选一个面板，验证 Theme 资源、变体命名、控件对照方法；试点不通过，不进入 32-2。
2. **两类面板优先**：Label 密集（如 `equipment_properies`、`level_info`、`game_information`、`pet_interface`、`basic_pellet`）先建立文本层级；Button 密集（如 `game_announcement`、`some_monster_help`、`zd_skill`、`zhen_yao_tower`、`set_menu`）再建立按钮状态族。
3. **混合面板后置**：`read_archive_interface`、`shop`、`pl_sell`、`lhhj` 等涉及 `LineEdit`/`CheckBox`/列表的面板，在 32-3 控件补齐后迁移。
4. **每批证据**：迁移前后截图（1280×800 与 1600×1000）、控件矩形/字体/字号/颜色转储、场景加载 0 ERROR / 0 WARNING、`scene_probe_runner` 相关用例；共享 HUD/关卡 UI 变更追加 `level_1` 冒烟与 changed-only 回归。
5. **不接受**：只改 `.tscn` 文本、不运行界面；用统一默认字替换字体导致字形变化；把 383 处动态主题调用强行归零；用截图只看一张静态状态而漏掉 hover/pressed/disabled/focus。
6. **阶段出口**：135 个场景全部迁移或登记例外；试点与每批有截图/几何对照；`check_all --godot-bin` 9/9；未迁移面板有明确列表；全局 Theme 若启用，必须有全 UI 回归证据。

### 32.5 风险与不做

- 风险最高的是视觉回归：同一字号在不同字体/描边/阴影下可能改变换行与控件占用；任何一批出现不可解释的像素/布局差异即回滚该批。
- 不新增主题切换功能，不改显示基线，不替换字体资产，不借 Theme 迁移重排面板布局。
- 不把动态品质色、血量色、奖励状态色搬入静态 Theme；这些继续由数据与脚本驱动，必要时建立少量状态变体。

## 5D. Phase 33：装备数据契约（已规划，未启动）

> **状态**：未启动。Phase 30/32 至少一个完成后启动；推荐 32-1 试点通过后先做 33-0/33-1，消费方迁移等待 Phase 32 覆盖对应面板。
> **依据**：[`modernization_gap_matrix.md`](../reference/modernization_gap_matrix.md) §3.2 B3、[ADR-006](../decisions/ADR-006-resource-first-data-and-data-keys.md)、[`target_architecture_contract.md`](../standards/target_architecture_contract.md) §5。
> **目标**：把 `all_equipment_data.gd` 中的静态装备定义迁出为强类型 Resource Catalog；保留现有装备规则、随机生成、玩家档案与掉落语义。不把 `PlayerData.player_data` 整体 Resource 化。

### 33.1 现状与问题（2026-11-01 基线）

| 项 | 实测 | 说明 |
|:---|:---:|:---|
| `all_equipment_data.gd` | **19,185 行** | 静态数据块 + 生成函数 + 装备规则混在同一脚本 |
| 运行时装备定义 | **1,035 条** | 数据块字面条目 + 玉兔 JSON、太极八卦、中秋/月宫、魂晶等生成项 |
| 字段 | **32 个** | 8 个通用字段（含可选图标）、16 个属性字段、`强化属性`、`宝石` 及 6 个扩展字段 |
| 属性字段覆盖 | 734–738 条/字段 | `SHp`/`SMp`/`power`/`Def`/`Mdef`/`Crit`/`Miss`/`R_hp`/`R_mp`/`vampirism`/`Lucky`/`toughness`/`htarget`/`CritReduce`/`ar`/`sp` |
| `强化属性` | 746 条 | 嵌套字典；含 `target` 等历史键，不能只按 16 属性列表裁剪 |
| `宝石` | 456 条 | 当前定义均为空数组；宝石实例属于玩家档案，不是静态定义 |
| 扩展字段 | `FBTYPE` 56、`成长率`/`五行` 各 33、`下一阶段` 1、`不可神铸` 3、`装备类型` 8 | 必须逐项保留 |
| 直接消费者 | **272 处 `AE.all_equipment`，48 个文件** | UI、商店、奖励、锻造、合成、分解、档案、掉落等 |
| 规则方法 | `get_last_equ_pro`、`get_fb_last_equ_pro`、神铸、宝石共鸣、`get_wx` 等 | 属于规则/随机，不是静态字段 |

关键事实：

- 数值类型不统一：部分属性是 int，部分为 float；`颜色` 是十六进制字符串；直接全部改成 `float` 会改变显示或比较语义。
- `tjbg` 的部分属性由 `randf_range` 生成；`get_wx` 运行时随机返回五行列表。静态 Resource 不能冻结这些值，否则改变玩法。
- `YutuEquipmentData` 从私有 `Art/hero_picture/role_7/equipment.json` 读取并合并定义；公开 clone 不包含该素材，生成 Catalog 必须提交，公开环境不能自行重建玉兔条目。
- `all_equipment.gd` 是 Autoload facade；`all_equipment_data.gd` 由它延迟加载。当前数据、规则和随机生成没有分层。

### 33.2 契约与数据模型

建议按“定义 / 规则 / 实例”三分：

1. **定义**：`EquipmentDefinition` Resource，只读。
   - 强类型核心字段：`id: StringName`、`name`、`origin`、`quality`、`color_hex`、`category`、`description`、`price`、`icon_path`、`equipment_type`、`fb_type`、`next_stage`、`growth_rate`、`element`、`forge_forbidden`。
   - 属性与扩展：`stats: Dictionary[StringName, Variant]`（16 个属性 + 已登记扩展键）与 `enhancement: Dictionary[StringName, Variant]`；保留 int/float 原类型，不静默转换。
   - `gem_slots: Array` 只承载定义期空槽位；宝石实例仍在玩家档案。
   - 不把 16 个属性分别写成 `float` 字段；混合 int/float 与历史键会使逐字段回归失真。字段白名单由生成器校验。
2. **Catalog / Store**：`EquipmentCatalog` 保存全部定义与 ID 索引；`EquipmentStore` 提供只读查询（`definition(id)`、`has(id)`、`ids()`、`by_category()`），不提供可写 `all_equipment` 字典。
3. **规则**：`EquipmentRules`/`EquipmentRoller` 承载 `get_last_equ_pro`、`get_fb_last_equ_pro`、神铸倍率、宝石共鸣、五行随机等；规则可以读取定义，但不把结果写回定义。
4. **实例**：`PlayerData` 中装备拥有状态、强化等级、宝石与槽位继续沿用当前 JSON 结构；不改变存档格式与槽位隔离。

### 33.3 构建源与生成器

- 新增构建源 `scripts/equipment_sources.json`（或等价、可审查的单文件源），由它生成 `source/Script/data/equipment_catalog.tres`；生成器 `scripts/convert_equipment_catalog.py` 提供 `--check`。
- 生成器合并：静态数据块、玉兔 `equipment.json`、中秋/月宫/魂晶等确定性生成项；对 `tjbg` 的随机字段只保留基础定义或明确的运行时生成入口，不把随机结果写死。
- `.tres` 与构建源同步由 `--check` 保证；运行时只加载 Resource，不解析 `.gd`/JSON 源文本。公开 clone 不含玉兔素材时，已提交 Catalog 仍可运行，但不能以公开环境重建全部条目。
- `all_equipment_data.gd` 在迁移期间作为对照源；33-4 删除，不能留下运行时第二份可写数据。
- Autoload `AE` 在迁移期间保留现有方法名作为过渡调用面；最终只保留正式 typed service，不保留 `all_equipment` 字典别名。若保留 `AE` 名称，它必须是正式装备服务入口，而不是兼容 facade。

### 33.4 批次

| 批次 | 内容 | 出口 |
|:---|:---|:---|
| 33-0（契约） | 定义 32 字段 schema、int/float 规则、扩展键白名单、随机例外；产出 `docs/reference/equipment_data_contract.md` 与字段审计脚本 | 1,035 条定义可枚举；未知字段/类型不静默通过 |
| 33-1（Catalog） | 新增 `EquipmentDefinition`、`EquipmentCatalog`、`EquipmentStore`、生成器与 `--check`；先不迁移消费者 | 生成 Catalog 与旧脚本逐 ID/逐字段一致；旧运行路径不变 |
| 33-2（规则） | 抽出 `EquipmentRules` 与随机五行/神铸/强化/宝石共鸣；保留现有调用名过渡 | 规则结果与旧实现对照；随机分布/边界不变；不写定义 |
| 33-3（消费方） | 按 48 个文件分四簇迁移：① UI/说明/背包；② 商店/奖励/掉落/关卡；③ 锻造/合成/分解/神铸；④ `PlayerData`/玉兔/坐骑。每簇删除 `AE.all_equipment` 直接访问 | 每簇 `AE.all_equipment` 归零；背包、商店、奖励、锻造、装备属性面板冒烟 PASS |
| 33-4（切换） | 删除 `all_equipment_data.gd` 与字典 getter/setter；`AE` 只保留 typed 查询与规则；更新 Autoload/索引 | 运行时不再加载 19k 行脚本；旧字典 API 归零；存档格式未变 |
| 33-5（收口） | 全量数值对比、L2/UI/关卡回归；新增 `equipment_data_audit.py` 守卫；资源加入发布闭包并重跑 PCK | 1,035 条逐字段一致；无重复/未知字段；日志 0/0；pack 路径可达 |

### 33.5 验证与风险

**必须验证**：

- 旧脚本与新 Catalog 的 **1,035 个 ID**、32 个字段、嵌套 `强化属性` 键、数组与数值类型逐字段一致；随机字段用范围/分布与行为用例验证，不伪造固定值；
- 生成器 `--check`、`equipment_data_audit.py`、`check_all --godot-bin` 9/9；
- 现有存档读取、装备穿戴/卸下、强化/神铸、宝石、合成/分解、商店购买、奖励领取、关卡掉落、玉兔装备映射与双人槽位；
- L2 `level_1`、`scene_probe_runner`、`coop_probe_runner`；相关 UI 冒烟；全量回归按变更矩阵执行；
- 新增 `equipment_catalog.tres` 后重跑发布闭包 PCK，不沿用旧 4,191 路径/7.56 GB 结论。

**边界**：

- 不改装备数值、掉落规则、随机范围、强化/神铸公式、存档格式或双人共享规则；
- 不把 `PlayerData.player_data` 整体 Resource 化，不把玩家实例状态写入 Catalog；
- 不为减少 19k 行而把规则搬进 Resource，也不保留第二份可写字典；
- 玉兔 JSON 的私有素材边界不能让公开 clone 伪造或重建数据。

**主要风险**：字段类型混合、`强化属性` 历史键、`tjbg` 随机字段、玉兔私有源、272 处字典访问。任一未逐项解释，不得宣称 Phase 33 完成。

## 5E. 推荐顺序

1. **先 32-0、32-1**：Theme 试点验证命名、截图与控件对照流程；试点不过不铺开。
2. **32-1 后可启动 33-0/33-1**：只做数据契约、Catalog 与生成器，不改消费者。
3. **32-2 覆盖装备/背包相关面板后，再做 33-3**：避免同一面板的场景样式与装备脚本同时改动。若并行，必须指定一个集成 owner，不能两个批次同时改同一场景/脚本。
4. **33-4/33-5 在 33-3 全簇通过后执行**；Phase 32 的全量 UI 验收可作为 Phase 33 的视觉回归基线，但不替代装备数值对比。

## 6. 推荐顺序与恢复

当前状态：**Phase 21 全部可执行项完成**；21-2A 最低设备确认与 21-2B 暂缓，恢复需目标设备。**Phase 31-0A 已完成；31-0B 评估后拒绝并保留旧数字图；31-1 已完成**。**Phase 30-1/30-2/30-3/30-4 已完成并归档**；Phase 32/33 的依赖已满足，当前候选见 §5C/§5D，推荐先做 32-0/32-1。资源再次变化后必须重跑 PCK，不沿用 Phase 30 的 7.56 GB 验证包结论。

中断时从最近一个已验证切片恢复；失败回滚该逻辑阶段，不恢复被替代的全局 1P 回落、直接发奖、表现层写档、死代码或无证据的资源回退。阶段完成后归档本页并另立候选。

**恢复入口**：[`spine_platform_baseline.md`](../reference/spine_platform_baseline.md)、[`autoload_boundary_matrix.md`](../reference/autoload_boundary_matrix.md)、[`runtime_frames_exceptions.md`](../reference/runtime_frames_exceptions.md)、[`acceptance.md`](../reference/acceptance.md)、`scripts/contract_scan.py`、`scripts/archive_probe_runner.py`、`scripts/coop_probe_runner.py`、`scripts/scene_probe_runner.py`。

## 7. 验证矩阵

既有命令与档位以 [`acceptance.md`](../reference/acceptance.md) 为准，不在本页复制历史数字。

| 变更 | 必需证据 | 不必无差别执行 |
|:---|:---|:---|
| 21-1 独立立项 | 目标平台/格式取证；采用项的加载验收 | 不把决策草案写成已支持 |
| 21-2 平台/发布 | 目标设备 VRAM/首帧/负载；release 启动与代表关卡；PCK | headless 不作 VRAM 证据 |
| 21-3 工厂族 | 对应探针返回形状/缓存；`level_1` 冒烟；相关回归 | 只改转发不算完成 |
| 21-4 资源转换器 | 转换器 `--check`/`--self-test`；allowlist 只减不增；帧与时序证据 | 不重开构建器 |
| 31-0A 废弃 API/常量/去重 | `check_all` 9/9；12 个 TileMap 覆盖关卡与 `level_1` 冒烟；changed-only 回归；图标行为对照 | 不以静态计数代替运行验证 |
| 31-0B 数字图 | 3 个消费文件截图/布局对照；不达标则保留旧实现并登记 | 不为归零强行替换 |
| 31-1 视差 | 89 场景 × 4 相机 2,520 节点 transform 对照；7 个代表场景截图前后对照；全量回归 | 不做纯文本替换 |
| 32 Theme | 135 场景基线；试点/每批控件矩形/字体/字号/颜色转储与截图；脚本动态主题例外清单；相关 UI 探针与回归 | 不只改文本、不以计数代替视觉验收 |
| 33 装备数据 | 生成器 `--check`；1,035 条逐字段类型/值对比；消费方分簇；L2/UI/关卡回归；资源变更后 PCK | 不改存档格式、不冻结随机字段 |

## 8. 阶段出口

- 21-1 每项有采用/延期/拒绝结论与 owner（角色责任，不绑定个人姓名）；
- 21-2 有目标设备与日期，未测平台明确标注；21-2B 暂缓时必须保留该状态，不生成最低设备结论；
- 21-3 每族删除被替代槽位，守卫与探针覆盖；全仓 ERROR=0；
- 21-4 补资源项迁移完成或明确拒绝，缺陷有前后证据；
- 文档、矩阵、脚本索引与状态一致；阶段归档后建立下一候选。
- 31-0A 三项子项各自可独立回滚；任一子项未验证不得合并提交。
- 32 试点通过后才分批；135 个场景全部迁移或登记例外；截图/几何对照与相关 UI 回归完成；
- 33 定义/规则/实例分层完成；1,035 条逐字段一致，旧字典 API 归零，存档与掉落语义不变。

## 9. 当前剩余项（2026-11-01）

| 项 | 状态 |
|:---|:---|
| 21-1A、21-1B、21-1C | 完成 |
| 21-2A 平台/后端 | 完成；**最低设备确认暂缓**（与 21-2B 同口径） |
| 21-2B | **暂缓**（无目标设备；Windows 侧测量本轮不做） |
| 21-2C PCK/release 启动/`level_1` 冒烟 | 完成 |
| 21-3A~21-3J、21-4A/21-4B | 完成 |

按“暂缓项不计入未完成”的口径：**Phase 21 实际未完成 0 项**；剩余项全部为暂缓——21-2A 的最低设备确认与 21-2B。阶段出口中的“21-2 有目标设备与日期”在暂缓解除前不能勾选。

### 9.1 后续批次状态

| 批次 | 状态 |
|:---|:---|
| Phase 31-0A（TileMap/物理层/图标去重） | **完成（2026-11-01）** |
| Phase 31-0B（数字图→BMFont） | **评估后拒绝（保留旧数字图，2026-11-01）** |
| Phase 31-1（89 场景视差迁移） | **完成（2026-11-01）** |
| Phase 30（ADR-023 关卡布局契约） | **已完成并归档**（[归档页](../archive/iteration_30_level_layout_data_contract.md)）；30-3 含 10 个登记例外 |
| Phase 32（UI Theme） | **已规划，未启动**；依赖已满足；先 32-0/32-1 |
| Phase 33（装备数据） | **已规划，未启动**；建议 32-1 后启动 33-0/33-1，消费方等待 32-2 覆盖对应面板 |
