# BHYH 当前候选迭代

> **状态**：Phase 18~20 综合收尾已完成并归档（见 [`iteration_18_20_comprehensive_closeout.md`](../archive/iteration_18_20_comprehensive_closeout.md)）；当前候选为 **Phase 21 独立立项与平台发布验证**，承接 Phase 20 未启动项（20-1A/20-1C/20-1D、20-2A/2B/2C）与连续工厂族工作。**21-3A/21-3B/21-3C/21-3D/21-3E/21-3F、21-4A 与 21-4B 已完成**；21-1A/21-1B/21-1C、21-2 与剩余 22 个工厂族入口未启动。
> **版本**：6.9；不新增玩法、任务与掉落，不改变数值、动画时序、输入映射、存档格式、本地双人共享规则或显示基线。
> **职责**：本页只展开当前候选；Phase 18~20 的结论、验证与延期去向见归档页，Phase 13~17 见 [`archive/README.md`](../archive/README.md)。
> **依据**：[`总体目标契约`](../standards/target_architecture_contract.md)、[`godot_design_standard.md`](../standards/godot_design_standard.md)、[`autoload_boundary_matrix.md`](../reference/autoload_boundary_matrix.md)、[`runtime_frames_exceptions.md`](../reference/runtime_frames_exceptions.md)、[`acceptance.md`](../reference/acceptance.md)、[`status.md`](../reference/status.md)。

## 1. 阶段边界与决策

### 1.1 目标

1. 对 Phase 13/19 登记的独立项目做采用/延期/拒绝决策并落地可验证部分；
2. 在真实目标设备上记录平台与发布证据，不用 headless 或单平台结果替代；
3. 继续按族收口 `Global` 剩余 `add_*` 工厂，保持不新增 Autoload、不新增全局回落；
4. 关闭 19-3A 登记的资源转换器扩展与 `weiyang_palace_boss` 符号层缺陷（21-4A/21-4B 已完成）。

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
| 静态守卫 | `contract_scan.py` 20 类；`check_all` 八维；契约 ERROR=0、WARNING ≤ 预算 |
| 运行时夹具 | 按 `acceptance.md` 的 L2 档位执行；探针清单由各 runner 维护，历史结果见 `status.md` |
| 资源闭包 | 19-3C 的 PCK 快照只在资源未变化时有效；资源变更后必须重跑 |

矩阵计数口径见各参考页；本页不复制历史数字。

## 2. Phase 21-1：独立立项（承接 20-1A/20-1C/20-1D）

**目标**：每项给出采用/延期/拒绝结论、owner 与前置条件；采用项落地并有验收。

1. **21-1A Spine 跨平台（承接 20-1A）**：确定目标平台、Spine 运行时版本与许可证；补二进制/`.gdextension` 并做目标平台加载验收。未确认平台前只允许决策草案，不写成已支持。
2. **21-1B `_bundled` 历史场景（承接 20-1C）**：先取证实际格式（不以文件名搜索结果宣布不存在）；评估转换、UID/导入缓存与回归范围后决定转换或拒绝。
3. **21-1C 类型化 Atlas accessor（承接 20-1D）**：基于 Phase 14 消费清单评审 typed schema；不改变视觉结果，不重开 `data_for`/`validate_path`/`clear_cache` 入口。

**必须验证**：每项有结论与 owner；采用项在目标平台/真实资源上验证；不把 Windows 或 headless 结果当跨平台通过。

## 3. Phase 21-2：平台与发布验证（承接 20-2A/2B/2C）

**目标**：把资源闭包与目标设备验证分开记录。

1. **21-2A 目标平台矩阵**：确认目标平台、渲染后端与最低设备；
2. **21-2B VRAM/首帧/战斗负载**：在真实设备测量并记录基线；
3. **21-2C release 包**：重跑 PCK/启动/代表关卡冒烟；资源变化后不沿用旧包结论。

**必须验证**：目标设备数据可复现；release 包能启动并进入代表关卡；日志干净；未测平台明确标注。

## 4. Phase 21-3：`Global` 工厂族收口（连续工作）

**目标**：把剩余 22 个 `add_*` 按功能族迁入既有工厂或新族，保持薄转发与公开入口。

1. **21-3A 锻造/分解族（完成，2026-10-30）**：`add_forge_help`、`add_forges`、`add_decompose_help`、`add_decompose_instance` 迁入 `ForgeFactory`；`add_forge_box` 全仓 0 调用方，随 `forge_box` 槽位删除；
2. **21-3B 角色/怪物弹体族（完成，2026-10-30）**：7 个弹体入口迁入 `ProjectileFactory`，slim/streaming 路径解析与法宝弹体路径表迁入；来源写入仍经 `Global._assign_attack_source`；
3. **21-3C 效果族（完成，2026-10-30）**：6 个效果入口迁入 `EffectFactory`，灵魄加成仍由 `PaSkill` 计算；
4. **21-3D 菜单/设置族（完成，2026-10-30）**：`add_game_set`、`add_skill_key_set`、`add_music_set`、`add_ldl`、`add_gm_infor`、`add_learn_skill` 迁入 `MenuPanelFactory`；`add_set_menu` 全仓 0 调用方，随槽位删除；`add_skill_select` 已是 `BackpackFactory` 薄转发；顺带修复 `add_gm_infor` 在 `CanvasLayer` 上写 `z_index` 的运行时错误；
5. **21-3E buff 族（完成，2026-10-30）**：`add_buffinfor` 并入 `PopupFactory`，`add_buff_icon` 并入 `CombatPresentationFactory`；`add_buff`/`add_buff_info`/`add_buff_icon_text`/`add_magp_infor` 已是既有薄转发；
6. **21-3E 关卡场景族（续，完成，2026-10-30）**：`add_stage`、`add_z_lw_stage`、`add_zztw_trap`、`add_dsg_choose` 迁入 `LevelSceneFactory`；
7. **21-3F 展示文本与技能面板族（完成，2026-10-30）**：新增 `ShowTextFactory`（字体文本/任务标题/评分）与 `SkillPanelFactory`（角色/变身技能面板、法宝说明）；`add_star`、`add_role_magic_need` 全仓 0 调用方，随槽位删除；技能面板预热改调 `prime_skill_scenes()`；
8. 其余 22 个 `add_*` 按 `autoload_boundary_matrix.md` §8 候选清单继续，不建总工厂、不新增 Autoload。

**必须验证**：每次迁移删除被替代的槽位字段，保留同名薄转发；`ui-factories` 或对应运行时探针覆盖返回形状与缓存；战斗相关族追加 `level_1` 冒烟与全量回归。**21-3A~F 验证**：对应工厂探针通过（含清缓存重载、`CanvasLayer` 语义、buff 拒绝语义、运行期 UI 槽位复用与死入口断言）；`check_all --godot-bin` 8/8；`level_1` PASS；全量回归与夹具明细见 `status.md`。

## 5. Phase 21-4：资源转换器与建帧遗留

1. **21-4A 转换器扩展（完成，2026-10-30）**：扩展 `convert_numbered_frames.py` 支持多动作 profile（每动画可选 `count` 与裁剪规则）。
   - `eight_immortals_boss`：8 个 Boss × 7 状态迁移到 `body_actions/body_frames.tres`；166 hit2 裁 250×250、168 hit2 裁 250×200 在构建期固化；
   - `three_prince_boss`：木吒/金吒迁移到 `three_prince/{root}/body_frames.tres`；木吒 hit3 的 292×250 帧居中裁成 250×250；哪吒保持既有 atlas 资源；
   - `pet_tiger_boss_base`：**拒绝转换**。声明的 `model/frames/stage1~4/r*_c*.png` 在工作区 0 个文件；预构建 `pet_tiger_stage*_frames.tres` 只有 9 个动画，缺 `hit5`/`hit6`，不能作为替代。保留运行期构建并登记资产缺失；
   - `runtime_frames_allowlist` 移除八仙与木吒/金吒条目；新增 `action-frames` 探针 PASS；
2. **21-4B `weiyang_palace_boss` 符号层（完成，2026-10-30）**：路径修正为 `swf_png/3007/atlas/swf_png_3007_frames.tres`；嘴/眼符号层恢复（78/17/55 帧），初始帧 0/16/54、镜像正确，嘴部可推进到第 50 帧发射；新增 `weiyang-symbol` 探针 PASS。运行期复制保留在 allowlist，不新增条目。

**必须验证**：补资源项迁移后 `runtime_frames_allowlist` 只减不增；缺陷修正有前后帧与技能时序证据。

## 6. 推荐顺序与恢复

推荐顺序：**21-4（无外部依赖）→ 21-3（连续族化）→ 21-1（决策）→ 21-2（设备）**；21-1/21-2 依赖外部确认，可并行准备但不阻塞 21-3/21-4。

中断时从最近一个已验证切片恢复；失败回滚该逻辑阶段，不恢复被替代的全局 1P 回落、直接发奖、表现层写档、死代码或无证据的资源回退。阶段完成后归档本页并另立候选。

**恢复入口**：[`autoload_boundary_matrix.md`](../reference/autoload_boundary_matrix.md)、[`runtime_frames_exceptions.md`](../reference/runtime_frames_exceptions.md)、[`acceptance.md`](../reference/acceptance.md)、`scripts/contract_scan.py`、`scripts/archive_probe_runner.py`、`scripts/coop_probe_runner.py`、`scripts/scene_probe_runner.py`。

## 7. 验证矩阵

既有命令与档位以 [`acceptance.md`](../reference/acceptance.md) 为准，不在本页复制历史数字。

| 变更 | 必需证据 | 不必无差别执行 |
|:---|:---|:---|
| 21-1 独立立项 | 目标平台/格式取证；采用项的加载验收 | 不把决策草案写成已支持 |
| 21-2 平台/发布 | 目标设备 VRAM/首帧/负载；release 启动与代表关卡；PCK | headless 不作 VRAM 证据 |
| 21-3 工厂族 | 对应探针返回形状/缓存；`level_1` 冒烟；相关回归 | 只改转发不算完成 |
| 21-4 资源转换器 | 转换器 `--check`/`--self-test`；allowlist 只减不增；帧与时序证据 | 不重开构建器 |

## 8. 阶段出口

- 21-1 每项有采用/延期/拒绝结论与 owner；
- 21-2 有目标设备与日期，未测平台明确标注；
- 21-3 每族删除被替代槽位，守卫与探针覆盖；全仓 ERROR=0；
- 21-4 补资源项迁移完成或明确拒绝，缺陷有前后证据；
- 文档、矩阵、脚本索引与状态一致；阶段归档后建立下一候选。
