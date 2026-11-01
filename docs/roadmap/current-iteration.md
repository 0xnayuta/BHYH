# BHYH 当前候选迭代

> **状态**：Phase 18~20 已归档；**Phase 21 全部可执行项完成**（21-1A/1B/1C、21-2C、21-3A~J、21-4A/4B），21-2A 最低设备确认与 21-2B 暂缓。**Phase 31-0A 已完成**（TileMap→TileMapLayer、`collision_layer` 具名化、`load_item_icon` 去重）；**31-0B 评估后拒绝**（现有 BMFont 与数字图不同字体/分辨率，保留旧数字图）；**31-1 未启动**。Phase 30 设计完成但按 ADR-023 `Proposed` 暂缓。平台决策见 [`spine_platform_baseline.md`](../reference/spine_platform_baseline.md)，现代化差距见 [`modernization_gap_matrix.md`](../reference/modernization_gap_matrix.md)。
> **版本**：6.9；不新增玩法、任务与掉落，不改变数值、动画时序、输入映射、存档格式、本地双人共享规则或显示基线。
> **职责**：本页只展开当前候选；Phase 18~20 的结论、验证与延期去向见归档页，Phase 13~17 见 [`archive/README.md`](../archive/README.md)。
> **依据**：[`总体目标契约`](../standards/target_architecture_contract.md)、[`godot_design_standard.md`](../standards/godot_design_standard.md)、[`autoload_boundary_matrix.md`](../reference/autoload_boundary_matrix.md)、[`runtime_frames_exceptions.md`](../reference/runtime_frames_exceptions.md)、[`acceptance.md`](../reference/acceptance.md)、[`status.md`](../reference/status.md)。

## 1. 阶段边界与决策

### 1.1 目标

1. 完成 21-1A 的目标平台、Spine 运行时版本与许可证决策，并在选定平台完成加载验收；未确认平台前只写决策草案，不宣称跨平台支持；
2. 在真实目标设备上记录平台与发布证据，不用 headless 或单平台结果替代；
3. 保持 21-3 收口后的 `Global` 工厂边界：`add_*` 全部为族工厂薄转发，不新增全局入口、Autoload 或回落；仅按新需求评审；
4. 保持 21-4A/4B 已完成的资源转换与符号层修复结论，不重开已拒绝的 `pet_tiger_boss_base` 转换。

### 1.2 不在本阶段

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

## 5A. Phase 30：关卡布局数据契约（暂缓，设计完成）

> **状态**：30-0 设计已完成（[ADR-023](../decisions/ADR-023-level-layout-data-contract.md) `Proposed` + [`level_layout_contract.md`](../reference/level_layout_contract.md)）；30-1~30-4 **未启动**。本阶段不并入 Phase 21，也不并入 Phase 31。

**启动前提**：ADR-023 由 `Proposed` 转 `Accepted`；本页登记独立批次与出口；确认不改动任何现有玩法数值、时序、掉落与输入。

| 批次 | 内容 | 出口 |
|:---|:---|:---|
| 30-1 | `LevelLayoutEntry`/`LevelStageSpec`/`LevelSpawnPoint`/`LevelLayoutCatalog`/`LevelLayoutStore` 五件套；`scripts/convert_level_layout_catalog.py`（含 `--check`）；`BaseLevel` 五个扩展点改为「有布局资源读资源，未登记沿用现状」 | 1 个 ZMWS 关卡跑通出生/分屏/刷怪/过关；`check_all` 全维 PASS |
| 30-2 | 外部怪物 id → BHYH 怪物场景映射资源；20–30 个代表关卡端到端 | 这批关卡可进、可打、可通关；回归无新增失败 |
| 30-3 | 84 个硬编码 `monster_group` 脚本按批迁出，删除脚本内数据表 | `monster_group = {` 计数逐批下降；每批行为一致 |
| 30-4 | 55 个含玩法逻辑脚本保留，仅迁出结构化数据块；更新 `architecture.md` §4.3 与 `status.md` | 无遗留双数据源 |

**当前基线（2026-11-01 实测）**：BHYH 关卡场景 153 / 脚本 164；硬编码 `monster_group` 脚本 **84**；ZMWS 关卡场景 **1,701**；`source/Script` 内 `level_layout_*` 与 `convert_level_layout_catalog.py` **均不存在**。

**不做**：不改玩法数值与时序、不重写 `base_hero`/`base_monster` 继承、不把 `PlayerData.player_data` 整体 Resource 化、不保留已迁移关卡脚本内数据副本。

## 5B. Phase 31：引擎废弃 API 与局部现代化（当前批次）

> **状态**：31-0A **已完成（2026-11-01）**；31-0B **评估后拒绝**（保留旧数字图，2026-11-01）；31-1 未启动。不依赖 Phase 30。
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

### 31-1 视差迁移（未启动）

- 89 个场景 95 个 `ParallaxLayer` 节点 + 1 个 `ParallaxBackground`（`base_through_level.tscn`）；
- 语义映射 `motion_scale→scroll_scale`、`motion_mirroring→repeat_size`、`scroll_offset→screen_offset`；容器层消失，**不是文本替换**；
- 验收必须含逐场景截图对照与全量回归。

## 5C. Phase 32 / 33（候选，均未启动）

| 阶段 | 内容 | 启动前提 |
|:---|:---|:---|
| 32 UI Theme 契约 | `theme_override_*` **6,830 处**收敛到 Theme 资源 + `theme_type_variation`；先 1 个面板试点 | Phase 30 实施完成 |
| 33 装备数据契约 | `all_equipment_data.gd` **19,185 行**转 Resource + 构建期生成器；属性逐字段一致 | Phase 30 或 32 至少一个完成 |

两阶段与 Phase 31 一样：不改玩法数值、掉落、输入映射、存档格式与显示基线。


## 6. 推荐顺序与恢复

当前状态：**Phase 21 全部可执行项完成**；21-2A 最低设备确认与 21-2B 暂缓，恢复需目标设备。**Phase 31-0A 已完成；31-0B 评估后拒绝并保留旧数字图**；下一批次为 31-1，Phase 30（ADR-023 为 `Proposed`）与 Phase 32/33 未启动。资源再次变化后必须重跑 PCK，不沿用本轮 7.56 GB 验证包结论。

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
| 31-1 视差 | 89 个场景逐场景截图前后对照；全量回归 | 不做纯文本替换 |

## 8. 阶段出口

- 21-1 每项有采用/延期/拒绝结论与 owner（角色责任，不绑定个人姓名）；
- 21-2 有目标设备与日期，未测平台明确标注；21-2B 暂缓时必须保留该状态，不生成最低设备结论；
- 21-3 每族删除被替代槽位，守卫与探针覆盖；全仓 ERROR=0；
- 21-4 补资源项迁移完成或明确拒绝，缺陷有前后证据；
- 文档、矩阵、脚本索引与状态一致；阶段归档后建立下一候选。
- 31-0A 三项子项各自可独立回滚；任一子项未验证不得合并提交。

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
| Phase 31-1（89 场景视差迁移） | 下一批次（未启动） |
| Phase 30（ADR-023 关卡布局契约） | 暂缓（设计完成，`Proposed`） |
| Phase 32（UI Theme） | 未启动，依赖 Phase 30 |
| Phase 33（装备数据） | 未启动，依赖 Phase 30 或 32 |
