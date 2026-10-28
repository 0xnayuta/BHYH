# Phase 15 归档：应用编排与运行资源生命周期

> **归档日期**：2026-10-28
> **状态**：Archived
> **关联**：[Phase 16 当前计划](../roadmap/current-iteration.md)、[运行时生命周期矩阵](../reference/runtime_lifecycle_matrix.md)、[ADR-018](../decisions/ADR-018-runtime-resource-cache-prewarm-and-pooling.md)、[ADR-021](../decisions/ADR-021-project-wide-target-architecture.md)
>
> Phase 15 已完成：15-1、15-2A/15-2B/15-2C、15-3A/15-3B/15-3C/15-3D、15-4A/15-4B/15-4C/15-4D/15-4E 全部完成并验收。
> **版本**：6.9；未新增玩法、任务与掉落，未改变数值、存档格式、本地双人共享规则或显示基线。
> **职责**：本页保存 Phase 15 的边界、批次、验证与恢复记录；后续阶段方向统一见 [`roadmap.md`](../roadmap/roadmap.md)。
> **依据**：[`总体目标契约`](../standards/target_architecture_contract.md) §3、§5、§7、§10~§11；[`architecture.md`](../reference/architecture.md)、[`runtime_lifecycle_matrix.md`](../reference/runtime_lifecycle_matrix.md)、[`acceptance.md`](../reference/acceptance.md)、[`status.md`](../reference/status.md)。
> **历史**：[Phase 14](iteration_14_atlas_metadata_boundary.md) 已完成归档，历史不改写。

## 1. 阶段边界与决策

### 1.1 目标

收敛应用编排与运行资源生命周期：让场景切换、加载页、运行时缓存、对象池、临时 UI 与退出清理各自有明确的所有者、正式入口和失败边界；保持现有玩法、显示与资源身份。

- 场景流转只保留一个正式入口；加载页是入口的内部实现，不是第二个业务入口；
- 资源缓存与对象池按作用域和租约归属，不把 `Global` 字段机械搬入新的 Manager；
- 加载、切换、返回、重战、失败与退出都验证正常路径和中断路径；
- 迁移一个职责边界时同步迁移全部生产调用方，删除旧入口，不保留永久 facade；
- 不新增 Autoload、不预批新的全局服务；Autoload 增删/合并必须先评审。

### 1.2 不在本阶段

- 不重写 `player_data`、不改存档格式、档案会话与 1P/2P 槽位；这些归 Phase 16；
- 不重构战斗继承、命中归属、技能/弹体业务规则；这些归 Phase 17；
- 不把 `Global` 全量拆分、不把所有缓存统一成一种类型、不重排顶层目录；
- 不修改素材、数值、动画时序、输入映射、物理层或 UI 视觉基线；
- 不把“新建一个资源管理器”当作完成标准；没有调用方闭环与退出语义的抽象不算交付。

### 1.3 当前事实与调查结果

| 边界 | 归档时事实 | 取证结果 |
|:---|:---|:---|
| 场景入口 | `Global.change_scene(target, force_loading_screen)` 是唯一业务入口 | 139 处调用、49 个文件；业务低层切换 0；`hdzm.gd` 4 处旁路已迁入 |
| 加载页 | `load_scene.gd` 使用目标快照与请求代次；失败/取消不提交 | 2 处内部低层切换仅保留在 `global.gd` |
| 资源交接 | 加载页只使用 `is_resource_cached`、`get_cached_packed_scene`、`handoff_loaded_resource` | 加载页私有缓存访问 0 |
| 缓存与池 | 六个作用域（构建期只读/永久/关卡/战斗/UI/共享运行时）均有 owner 与清理事件 | `get_cache_scope_snapshot()` 可观测；池容量 80/32/24/32 |
| UI 生命周期 | 关键工厂显式登记关闭回调，其余保留名称兜底 | 51 处清理调用来自 18 个已登记文件 |
| 退出与后台 | `Global._exit_tree` 统一结束档案、角色/战斗/UI 缓存、池与纹理请求 | `_runtime_generation` 阻止过期异步写回 |
| 边界守卫 | `contract_scan.py` 十一类契约 | 场景入口/加载页缓存/池 UI 三类新增 ERROR 门禁 |

## 2. Phase 15-1：调用面与所有权矩阵（已完成）

**目标**：在不改运行时代码的前提下，建立场景切换、加载、缓存、池、UI 和退出清理的完整调用面，确定每个资源/状态的所有者与生命周期。

### 2.1 调查内容

1. 枚举所有 `change_scene_to_file`、`change_scene_to_packed`、`Global.change_scene`、`target_scene` 写入点与加载页内部调用；
2. 枚举加载页读取/写入的缓存路径、线程请求、预载槽位、完成/失败回调与场景揭幕时序；
3. 枚举 `_resource_cache`、`_sprite_frames_cache`、`_audio_cache`、`_texture_cache`、怪物场景缓存、关卡路径集合、对象池、UI 实例登记与永久 UI 缓存的读写方；
4. 枚举 `clear_level_resource_cache`、`clear_combat_runtime_cache`、`end_archive_session`、`release_ui_runtime_cache`、`_exit_tree` 的调用方与失败路径；
5. 区分资源声明、构建数据、运行时缓存和业务状态，禁止把只读 Catalog/清单误算成缓存。

### 2.2 交付矩阵

完整调用点、所有者、写者、释放事件与失败边界见 [`runtime_lifecycle_matrix.md`](../reference/runtime_lifecycle_matrix.md)。

| 能力 | 所有者 | 允许调用方 | 释放/失效事件 | 结果 |
|:---|:---|:---|:---|:---|
| 场景目标选择 | `Global.target_scene` + `Global.change_scene` | 业务入口；加载页消费 | 切换完成/失败 | 空目标或缺失目标返回 `false`；快速路径同步写 `target_scene` |
| 线程预载 | `load_scene` 请求 + `Global` 缓存 | 加载页 | 完成、加载页释放 | 代次阻止旧回调写回 |
| 关卡资源租约 | `Global._level_resource_lease` | 加载页、关卡 | 每次切换/战斗清理 | 只释放本租约路径；永久 UI 与未登记路径保留 |
| 战斗对象池 | `Global._pool_data` | 战斗表现层 | 档案结束 | 关卡切换不清理；复用重置依赖消费者 |
| 临时 UI | `Global._transient_ui_instances` + 名称兜底 | UI 工厂/面板 | 关闭、切换、退出 | 注册实例优先关闭；未登记名称保留兜底 |

### 2.3 出口

- 每个实际调用点都有 owner、调用方、释放事件和失败行为；
- 直接旁路与加载页内部调用分开记录；
- 编排层缓存写入、线程回调与清理入口已登记；模块局部静态缓存作用域单独标出；
- 仅文档与只读报告，未改生产代码；结果见 [`runtime_lifecycle_matrix.md`](../reference/runtime_lifecycle_matrix.md)。

## 3. Phase 15-2：场景流转单入口（15-2A/15-2B/15-2C 已完成）

**目标**：保留一个正式场景切换入口，先清理业务旁路，再稳定加载页与调用方契约。

### 3.1 切片

1. **Phase 15-2A 旁路收口**：`hdzm.gd` 的 4 处直接 `change_scene_to_file` 迁入 `Global.change_scene`；业务代码不再保留裸切换；
2. **Phase 15-2B 入口契约**：`Global.change_scene` 校验空目标/非场景/缺失目标，拒绝时返回 `false` 且不清状态；快速路径同步写 `target_scene`；接受时返回引擎提交结果；
3. **Phase 15-2C 加载页交接**：加载页在 `_ready` 固定 `_target_scene` 与请求代次；预载/缓存/完成切换统一使用快照；旧代次不写缓存或切换；目标无法加载、实例化或加载后失效时保留加载页并显示失败。

### 3.2 验证

- 冷启动 → 主菜单 → 关卡；关卡 → 主菜单 → 再次进入；同一关卡返回/重战；强制加载页与缓存快速路径；
- 目标为空、目标缺失、重复切换、切换中退出；
- 旧场景释放、HUD 揭幕与首帧防黑屏语义不退化。

### 3.3 出口

- 业务代码不再直接调用 `change_scene_to_file/packed`；
- 加载页不再直接调用低层切换，只通过目标快照与请求代次交接；
- 调用方不依赖旧的延迟切换旁路。

## 4. Phase 15-3：加载页预载与资源交接（15-3A/15-3B/15-3C/15-3D 已完成）

**目标**：让加载页只负责“请求与编排”，资源缓存由明确所有者持有；切换、取消和失败不留下陈旧回调或跨关卡资源。

### 4.1 切片

1. **Phase 15-3A 交接 API**：加载页只使用 `Global.is_resource_cached`、`Global.get_cached_packed_scene` 与 `Global.handoff_loaded_resource`；不再读写 `_resource_cache` / `_audio_cache` / `_texture_cache`，也不调用 `_cache_threaded_resource` / `_track_level_resource`；
2. **Phase 15-3B 关卡资源租约**：`_level_resource_lease` 记录目标场景、租约 ID、拥有路径、场景/怪物/弹体/纹理/音频分类、已预热场景与已预热怪物 ID；`change_scene` 建立新租约，释放只处理本租约路径；`clear_combat_runtime_cache` 移除宽泛前缀删除；
3. **Phase 15-3C 失败与取消**：加载页固定目标与请求代次，路径失效时停止轮询与提交；新增 120 秒看门狗与 `application/run/load_timeout_msec` 覆盖；`_preloaded_scene` 单槽在失败、换目标与显式清理时释放；`ResourceLoader` 无公开取消 API，取消语义为丢弃后台结果；
4. **Phase 15-3D 预载清单边界**：`LevelPreloadStore` 与构建期 Catalog 保持只读；移除加载页 `DirAccess` 目录扫描、`ResourceLoader.get_dependencies` 递归清单解析与相关死函数；`contract_scan.py` 新增 `preload_boundary` 门禁与负向自测。

### 4.2 验证

- 预载成功、失败、超时/取消与目标切换；关卡缓存命中与未命中；
- 角色/宠物/剑阵/法宝/怪物/弹体依赖的交接；
- 退出加载页后后台请求不再写回；内存/纹理租约与重复进出不持续增长。

### 4.3 出口

- 缓存只有一个写入所有者；加载页只通过 `handoff_loaded_resource` 提交结果；
- 租约释放可枚举、可观测；旧租约 ID 被拒绝；
- 线程失败/取消不留下过期回调；加载失败不落入可玩场景或半初始化状态。

## 5. Phase 15-4：缓存、池、UI 与退出生命周期（15-4A/15-4B/15-4C/15-4D/15-4E 已完成）

**目标**：把缓存/池/UI 的作用域、清理入口和退出语义闭合；增加边界守卫后才标记 Phase 15 完成。

### 5.1 切片

1. **Phase 15-4A 缓存作用域**：定义构建期只读、永久、关卡、战斗、UI、共享运行时六个作用域；每类登记所有者、容量/驻留依据、清理事件与观测键；新增 `Global.get_cache_scope_snapshot()`；
2. **Phase 15-4B 对象池**：确认 `RuntimePool` 池根属于 `Global`，跨关卡/重战保留、档案结束清空；容量 80/32/24/32、预置 12/16/16/6；池满释放，排队删除节点不复用；消费者 `setup`/`recycle` 重置；退出清空活动音效映射；
3. **Phase 15-4C 临时 UI**：新增 `_transient_ui_instances` 与 `register_transient_ui(node, close_method, scene_path)`；基础任务、神秘商店与游戏公告工厂显式登记关闭回调，其余未登记 UI 保留名称兜底；`cleanup_transient_ui` 先关闭登记实例再清理，永久小 UI 路径跳过，递归清理有 active 守卫；
4. **Phase 15-4D 退出与后台**：新增 `_runtime_generation` 与 `is_runtime_generation_current`；`change_scene`、档案会话开始/结束与 `_exit_tree` 递增代次；角色/关卡/纹理/UI 预热在写回前检查代次，过期结果丢弃；`Global._exit_tree` 统一清理档案、角色/战斗/UI 缓存、对象池、预载槽与纹理请求；`FrameTextureRequests` 在 `_closing` 后停止轮询；HTTPRequest 退出取消；`map_6` 至 `map_9_1` 补齐地图视觉释放；
5. **Phase 15-4E 边界守卫**：`contract_scan.py` 新增 `scene_entry`、`load_cache`、`pool_ui` 三类 ERROR 门禁；`change_scene_to_*` 仅 `global.gd` 豁免，加载页禁止私有缓存/租约访问，池/UI 清理仅 Global 与 18 个已登记 UI 调用方；新增正负样本并同步 `scripts/README.md`、`acceptance.md` 为十一类契约。

### 5.2 验证

- L2 固定套件与全量回归按 [`acceptance.md`](../reference/acceptance.md) 执行；
- 冷启动、返回、重战、关卡间切换与退出重复执行；
- UI 关闭/切换/退出无残留，池复用无旧状态；
- 后台请求在退出/切换后不写回；
- 静态守卫正负样本通过，且不全仓误报。

### 5.3 出口

- 所有缓存/池/UI 均有所有者、作用域、清理事件与失败语义；
- 不再存在业务侧直接切换旁路或加载页写私有缓存；
- 旧字段/入口/清理路径与生产调用方同步删除；
- 文档、架构、验收、状态与脚本索引一致。

## 6. 验证矩阵与已执行证据

既有命令与档位以 [`acceptance.md`](../reference/acceptance.md) 为准；本页只记录 Phase 15 实际执行结果。

| Phase/变更 | 必需证据 | 已执行结果 |
|:---|:---|:---|
| 15-1 调用面矩阵 | 全量引用、owner/清理/失败表、链接与格式 | 矩阵完成；未触发引擎/回归 |
| 15-2A/15-2B 入口契约 | `hdzm.gd` 旁路清零；空/缺失目标拒绝；快速路径目标一致 | `level_1` 与关卡选择探针通过 |
| 15-2C 加载页交接 | 目标快照、重复切换、失败不提交 | `level_1`、关卡选择探针、全量回归通过 |
| 15-3A 交接 API | 加载页私有字段/方法访问为 0 | 静态门禁 + 关卡选择探针通过 |
| 15-3B 关卡资源租约 | 租约分类、按租约释放、共享缓存保留、旧 ID 拒绝 | `level-resource-lease` 探针 PASS |
| 15-3C 失败与取消 | 失败/取消/超时/换目标；单槽清理 | `load-guard` 探针 PASS |
| 15-3D 预载清单边界 | 加载页无目录扫描/清单解析 | `contract_scan --self-test` 4/4 + 3/3 |
| 15-4A 缓存作用域 | 六类 owner/容量/清理/观测 | `get_cache_scope_snapshot` + 探针 PASS |
| 15-4B 对象池 | 池根/容量/复用重置/退出清理 | 租约探针 + 全量回归 PASS |
| 15-4C 临时 UI | 显式登记/关闭回调/永久 UI 跳过 | `load-guard` + L2 PASS |
| 15-4D 退出与后台 | 过期异步不写回；退出统一清理 | 租约探针代次检查 + 单关冒烟 PASS |
| 15-4E 边界守卫 | 三类门禁正负样本与全仓零 ERROR | `--self-test` 全部通过；`--fail-on-error` ERROR=0 |

Phase 15 收口证据（2026-10-28）：`check_all --godot-bin` **8/8 PASS**；`health_check` **0 Parse / 0 Error / 0 Warning**；`scene_probe_runner` 完整套件 **6/6 PASS**（星座 4.24s / 选择态 15.32s / 租约 3.01s / 加载守卫 4.80s / 法宝 7.07s / 角色技能 4.11s）；changed-only 关卡回归 **PASS 128/128 + SKIP 1，FAIL 0**（696.7s，`level_58` 28.29s）；`contract_scan --self-test` 全部通过（预载 4/4+3/3、场景入口 3/3+3/3、加载页缓存 3/3+2/2、池/UI 清理 4/4+4/4）；`contract_scan --fail-on-error` ERROR=0。

`level_58` 并发加载预算实测（1/2/4/6/8 并发，每组全通过）：加载 3.724 / 3.826~3.837 / 4.096~4.100 / 4.911~4.957 / 5.391~5.565s，墙钟 27.4 / 28.65 / 29.58 / 31.71 / 34.67s。根因为 `fire_ancestor_boss.gd` 在加载线程内 `preload` 含 `@tool` 预览脚本的 `monster_3056.tscn`，已改为运行时按需加载；未调整 45s 夹具阈值。未执行 release 重验与切换中退出验证。

## 7. 实施批次与提交

| 批次 | 提交 |
|:---|:---|
| 15-2A/15-2B 入口收口 | `0345b45` fix(scene): 收口 hdzm 场景切换并固定入口契约 |
| 15-2C 加载页交接 | `de8b92b` fix(scene): 收束加载页目标快照与失败交接 |
| 15-3A 窄交接 | `29a22c5` refactor(scene): 收束加载页缓存交接接口 |
| 15-3B 资源租约 | `70222d3` refactor(scene): 按关卡租约释放运行时资源 |
| 15-3C 失败取消 | `bbac43d` fix(scene): 收口加载失败取消与预载单槽 |
| 15-3D 清单边界 | `c2ddcc4` refactor(preload): 移除加载页目录扫描与清单解析 |
| 15-4A 缓存作用域 | `b08c539` refactor(cache): 定义缓存作用域与观测快照 |
| 15-4B 对象池 | `5c74328` refactor(pool): 收口对象池作用域与复用守卫 |
| 15-4C 临时 UI | `7579369` refactor(ui): 收口临时 UI 登记与关闭回调 |
| 15-4D 退出与后台 | `68d3c90` refactor(runtime): 收口退出清理与异步代次 |
| 15-4E 边界守卫 | `eee1494` feat(guard): 增加应用编排边界门禁并收口 level_58 加载 |

## 8. 阶段出口与恢复

- 所有实际场景流转走正式入口；加载页内部实现与业务旁路已分离；
- 缓存、池、UI 与后台请求有明确所有者、作用域和退出语义；
- 正常、边界、失败、取消、重复进入退出均有验证证据；
- 旧入口与兼容分支删除，不保留永久 facade；
- 文档、ADR、脚本索引与状态一致；长期结论保留在 `reference/`，历史实施细节归档到本页。

中断时从 Phase 15-1 所有权矩阵和最近一个已验证切片恢复；失败回滚该逻辑阶段，不恢复旧旁路或旧缓存写入路径。Phase 15 已全部完成，本页只作历史记录。

**恢复入口**：[运行时生命周期矩阵](../reference/runtime_lifecycle_matrix.md)、[`architecture.md`](../reference/architecture.md) 的场景/缓存章节、[`acceptance.md`](../reference/acceptance.md) 的 L2 档位。

**下一候选**：Phase 16 档案会话、持久化与玩家槽位；后续 Phase 17 玩法/表现边界。平台与发布验证按独立工作流推进，不等待本阶段。
