# Phase 18~20：综合收尾（归档）

> **归档日期**：2026-10-30
> **状态**：Archived；18-1 ~ 18-3、19-1 ~ 19-4、20-1B、20-3A/3B/3C 已完成；20-1A/20-1C/20-1D、20-2 承接至下一候选。
> **关联**：[`current-iteration.md`](../roadmap/current-iteration.md)、[`roadmap.md`](../roadmap/roadmap.md)、[`autoload_boundary_matrix.md`](../reference/autoload_boundary_matrix.md)、[`archive_session_matrix.md`](../reference/archive_session_matrix.md)、[`gameplay_module_matrix.md`](../reference/gameplay_module_matrix.md)、[`atlas_metadata_schema.md`](../reference/atlas_metadata_schema.md)、[`runtime_frames_exceptions.md`](../reference/runtime_frames_exceptions.md)、[`acceptance.md`](../reference/acceptance.md)、[`status.md`](../reference/status.md)。

## 1. 阶段结论

Phase 18~20 关闭了 Phase 13~17 登记的正确性缺口、运行时所有权与守卫扩面：

| 批次 | 结论 |
|:---|:---|
| 18-1 | 双人归属：`wd_hurt`/觉醒按 Role4 独立结算；删除 `Global.get_player`（13 引用/9 文件）；召唤无 owner 不回落 1P；减伤读实际出手者；双人全灭统一提交并去重 |
| 18-2 | 成长命令：神铸/淬骨/合成/任务/技能全部“校验→快照→扣除→产出→保存→回滚”；删除 `forge` 旧处理入口；2P 商店/奖励共享账本与重复购买无副作用 |
| 18-3 | 档案顺序：后台保存带 `serial` 并由 `Global` 单点消费；地图首帧保存保留（当前地图唯一持久化点）并删除 `map_3` 重复保存；`LevelProgressCommand` 收敛 48 关/23 区域/导入 63~75/北俱芦洲键，`add_tg` 只写字典；`request_save_result` 结构化返回 + `save_failed` 消费者 + 1.5s 去重 |
| 19-1 | 表现层命令化：任务/幻化/技能键位/觉醒改走 `PlayerData` 命令；宠物面板保存走 `request_save_with_feedback`；`pet_interface`/`base_role`/`skill_icon` 深层字面路径与 `/root` 回落清零；奖励失败隐藏并保留错误提示 |
| 19-2 | 音频与运行时：`end_archive_session` 停止 BGM；同曲跨父节点同步重挂；音效活动声部/节流表清理；`cleanup_transient_ui` 只处理显式登记；`MonsterFrameCacheRegistry` 统一档案退出清理 |
| 19-3 | 资源：12 个运行时建帧例外逐项结论（7 保留/4 补资源/1 删除回退），`tao_wu_boss` 回退删除，allowlist 12→11；112 个未触达 metadata 分类（41 未迁移/38 构建溯源/30 地图关卡/3 角色图集）；PCK 闭包 2,738,706,658 字节、4100/4100 可达 |
| 19-4 | 输入/HUD：18 个 `p2_*` 动作与物理键、视图互不串槽、禁用回落；键位即时应用/保存/恢复默认；HUD 全字段只读且帧前后档案快照一致；新增 `input_boundary` 守卫 |
| 20-1B | Autoload 拆分：注册项 13→11；`global.gd` 6,041→3,971 行、360→329 函数、295→189 变量；18 个普通子节点（10 个运行时节点 + 8 个场景工厂族）；`add_*` 120 个中 59 个为薄转发 |
| 20-3A | 守卫扩面：`contract_scan` 由 17 类增至 20 类，覆盖写档命令、运行状态、HUD/面板只读 7 域与音频入口；自测含坏/好样本 |
| 20-3B | 运行时夹具：探针日志门禁扫描完整输出并校验收尾标记；`ProbeSpec.expected_noise` 逐条登记；修复三处真实缺陷；补齐音频负向断言（无效父节点/空路径/重复停止） |
| 20-3C | 收口：L2 固定组合、全量回归、文档/矩阵/脚本索引同步与本页归档 |

## 2. 最终验证（2026-10-30）

| 项 | 结果 |
|:---|:---|
| `contract_scan.py --self-test` | **二十类边界全部通过** |
| `contract_scan.py --fail-on-error` | **ERROR=0**（含在 `check_all` 中执行） |
| `check_all.py --godot-bin` | **8/8 PASS** |
| `level_test_runner`（`level_1`） | **PASS**，0 ERROR / 0 WARNING |
| `coop_probe_runner` | **26/26 PASS** |
| `scene_probe_runner` | **11/11 PASS** |
| `archive_probe_runner` | **293/293 PASS**（含新增音频负向断言） |
| `level_regression_all`（全量） | **128/128 PASS + 5 SKIP**，289.0s |

## 3. 固化规则

1. `contract_scan.py` 的 20 类规则是当前静态边界基线：资源/节点/反射/动画/字典键/运行时 manifest/AtlasMetadata/关卡预载/场景入口/加载页缓存/池 UI/运行状态/档案/槽位/面板操作者/共享账本/音频入口/HUD 面板/Phase 17 边界/输入写入；
2. `Global` 只保留薄转发与跨域编排；新增职责进入对应运行时节点或工厂族，不回流到 `Global` 字段；
3. 探针日志门禁必须以完整输出为准，探针主动构造的失败日志逐条登记 `expected_noise`；
4. 表现层不直写档案、不直发奖励；成长/奖励/技能提交必须使用命令快照或结构化结果；
5. BGM/SFX 只经 `AudioRuntime` 公开入口，业务不得自建播放器或直读其私有状态。

## 4. 延期项与去向

| 项 | 去向 |
|:---|:---|
| 20-1A Spine 跨平台 | 下一候选；需目标平台、运行时版本与许可证决策 |
| 20-1C `_bundled` 历史场景 | 下一候选；需素材格式取证与 UID/导入缓存评估 |
| 20-1D 类型化 Atlas accessor | 下一候选；基于 Phase 14 消费清单评审 typed schema |
| 20-2A/2B/2C 平台与发布 | 下一候选；需真实设备 VRAM/首帧/release 包验证 |
| S5 剩余 61 个 `add_*` | 连续工作：锻造/分解、角色/怪物弹体、效果等族按 `autoload_boundary_matrix.md` §8 推进 |
| 19-3A 后续 | 3 个转换器扩展（八仙/虎 Boss/三太子多目录动作集）与 `weiyang_palace_boss` 符号层缺陷；见 [`runtime_frames_exceptions.md`](../reference/runtime_frames_exceptions.md) |

## 5. 恢复入口

[`current-iteration.md`](../roadmap/current-iteration.md)、[`autoload_boundary_matrix.md`](../reference/autoload_boundary_matrix.md)、[`acceptance.md`](../reference/acceptance.md)、[`status.md`](../reference/status.md)、`scripts/contract_scan.py`、`scripts/archive_probe_runner.py`、`scripts/coop_probe_runner.py`、`scripts/scene_probe_runner.py`。
