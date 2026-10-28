# BHYH 当前候选迭代

> **状态**：**Phase 15：应用编排与运行资源生命周期；Phase 15-1 调用面矩阵、Phase 15-2A 旁路收口、Phase 15-2B 入口契约、Phase 15-2C 加载页交接、Phase 15-3A 窄交接接口与 Phase 15-3B 关卡资源租约已完成，Phase 15-3C/15-3D 未启动**。本页记录候选边界、阶段顺序与验收条件，不把目标写成现状。
> **版本**：6.9；不新增玩法、任务与掉落，不改变数值、存档格式、本地双人共享规则或显示基线。
> **职责**：本页展开当前候选 Phase 15；Phase 16~17 的方向、启动依赖与独立平台项目统一见 [`roadmap.md`](roadmap.md)。
> **依据**：[`总体目标契约`](../standards/target_architecture_contract.md) §3、§5、§7、§10~§11；[`architecture.md`](../reference/architecture.md)、[`acceptance.md`](../reference/acceptance.md)、[`status.md`](../reference/status.md)。
> **历史**：[Phase 14 已归档](../archive/iteration_14_atlas_metadata_boundary.md)；Phase 13 及更早归档见 [`archive/README.md`](../archive/README.md)。

## 1. 阶段边界与决策

### 1.1 目标

收敛应用编排与运行资源生命周期：让场景切换、加载页、运行时缓存、对象池、临时 UI 与退出清理各自有明确的所有者、正式入口和失败边界；保持现有玩法、显示与资源身份。

- 场景流转只保留一个正式入口；加载页是入口的内部实现，不是第二个业务入口；
- 资源缓存与对象池按作用域和租约归属，不把 `Global` 字段机械搬入新的 Manager；
- 加载、切换、返回、重战、失败与退出都验证正常路径和中断路径；
- 迁移一个职责边界时同步迁移全部生产调用方，删除旧入口，不保留永久 facade；
- 不新增 Autoload、不预批新的全局服务；Autoload 增删/合并必须先评审。

### 1.2 不在本阶段

- 不重写 `player_data`、不改存档格式、档案会话与 1P/2P 槽位；这些属于 Phase 16；
- 不重构战斗继承、命中归属、技能/弹体业务规则；这些属于 Phase 17；
- 不把 `Global` 全量拆分、不把所有缓存统一成一种类型、不重排顶层目录；
- 不修改素材、数值、动画时序、输入映射、物理层或 UI 视觉基线；
- 不把“新建一个资源管理器”当作完成标准；没有调用方闭环与退出语义的抽象不算交付。

### 1.3 当前事实与调查结果

| 边界 | 当前事实 | 本阶段取证要求 |
|:---|:---|:---|
| 场景入口 | `Global.change_scene(target, force_loading_screen)` 是规范入口；`load_scene.tscn` 内部保留 `change_scene_to_file/packed` 兜底；`hdzm.gd` 的 4 处直接切换已迁入正式入口 | Phase 15-1 列出全部调用、调用者和差异；Phase 15-2A/15-2B 已完成入口与失败返回契约 |
| 加载页 | `load_scene.gd` 构建目标场景、角色、宠物、剑阵、法宝、怪物与关卡依赖；使用线程请求、槽位填充与覆盖式切换 | Phase 15-1/Phase 15-3 记录请求、缓存写入、完成与失败回调 |
| `Global` 职责 | 场景切换、UI 工厂、资源缓存、对象池、异步预载、部分业务判定与关卡上下文混合；当前有多个缓存字典和池集合 | Phase 15-1 按职责与生命周期拆分，不以文件行数或字段数量作为目标 |
| 资源交接 | 加载页通过 `Global.is_resource_cached`、`Global.get_cached_packed_scene` 与 `Global.handoff_loaded_resource` 交接缓存，不再接触私有字段/方法 | Phase 15-3 明确缓存所有者、允许的交接 API 与失败/取消语义 |
| 缓存与池 | `_resource_cache`、`_sprite_frames_cache`、`_audio_cache`、`_texture_cache`、怪物场景缓存、`_level_resource_lease` 租约，以及伤害文本/受击/音效等对象池 | Phase 15-3/Phase 15-4 建立作用域、容量依据、清理事件与观测入口 |
| UI 生命周期 | `Global` 维护运行时 UI 实例登记、永久小 UI 预载与按名称清理；`cleanup_transient_ui` 依赖硬编码节点名 | Phase 15-4 改用显式注册/释放或受控清理，并保留当前面板行为 |
| 退出与后台 | `Global._exit_tree` 仅收尾部分 FrameSequence/纹理请求；`clear_level_resource_cache`、`clear_combat_runtime_cache` 与档案会话生成号各自清理不同集合 | Phase 15-4 核对所有缓存/池/请求的退出与中断路径，消除过期回调写回 |
| 既有验收 | L2 固定套件与全量回归的档位见 [`acceptance.md`](../reference/acceptance.md)；历史结果只以 [`status.md`](../reference/status.md) 为准 | Phase 15-1 只读；Phase 15-2 至 Phase 15-4 按受影响边界触发运行验证 |

Phase 15-1 已完成调用面与所有权矩阵，边界事实不视为已经修复；后续阶段据此决定哪些职责保留在 `Global`、哪些需要独立所有者。

## 2. Phase 15-1：调用面与所有权矩阵（已完成）

**目标**：在不改运行时代码的前提下，建立场景切换、加载、缓存、池、UI 和退出清理的完整调用面，确定每个资源/状态的所有者与生命周期。

### 2.1 调查内容

1. 枚举所有 `change_scene_to_file`、`change_scene_to_packed`、`Global.change_scene`、`target_scene` 写入点与加载页内部调用；
2. 枚举加载页读取/写入的缓存路径、线程请求、预载槽位、完成/失败回调与场景揭幕时序；
3. 枚举 `_resource_cache`、`_sprite_frames_cache`、`_audio_cache`、`_texture_cache`、怪物场景缓存、关卡路径集合、对象池、UI 实例登记与永久 UI 缓存的读写方；
4. 枚举 `clear_level_resource_cache`、`clear_combat_runtime_cache`、`end_archive_session`、`release_ui_runtime_cache`、`_exit_tree` 的调用方与失败路径；
5. 区分资源声明、构建数据、运行时缓存和业务状态，禁止把只读 Catalog/清单误算成缓存。

### 2.2 交付矩阵

完整调用点、当前所有者、写者、释放事件与失败边界见 [`runtime_lifecycle_matrix.md`](../reference/runtime_lifecycle_matrix.md)。本阶段只确认现状，不把目标语义写成已实现。

| 能力 | 当前所有者 | 允许调用方 | 释放/失效事件 | 当前失败语义 |
|:---|:---|:---|:---|:---|
| 场景目标选择 | `Global.target_scene` + `Global.change_scene` | 业务入口；加载页消费 | 切换完成/失败 | 空目标或缺失目标返回 `false`；快速路径同步写 `target_scene` |
| 线程预载 | `load_scene` 请求 + `Global` 缓存 | 加载页 | 完成、加载页释放 | 失败继续进度，无显式取消 |
| 关卡资源租约 | `Global._level_resource_lease` | 加载页、关卡 | 每次切换/战斗清理，只释放本租约 | 未登记路径与永久 UI 保留；目标场景不登记 |
| 战斗对象池 | `Global._pool_data` | 战斗表现层 | 档案结束 | 关卡切换不清理；复用重置依赖消费者 |
| 临时 UI | `Global` 注册表 + 硬编码清理 | UI 工厂/面板 | 关闭、切换、退出 | 按名称清理，可能误删同名节点 |

### 2.3 出口

- 每个实际调用点都有 owner、调用方、释放事件和失败行为；
- 直接旁路与加载页内部调用分开记录；
- 编排层缓存写入、线程回调与清理入口已登记；模块局部静态缓存的作用域边界单独标出；
- 仅文档与只读报告，不改生产代码；结果见 [`runtime_lifecycle_matrix.md`](../reference/runtime_lifecycle_matrix.md)。
- 当前矩阵确认：正式入口 139 处静态调用/49 个文件；`hdzm.gd` 4 处旁路已迁入；业务低层切换为 0；加载页内部兜底 2 处；`_deferred_change_scene` 已删除。

## 3. Phase 15-2：场景流转单入口（15-2A/15-2B/15-2C 已完成）

**目标**：保留一个正式场景切换入口，先清理业务旁路，再稳定加载页与调用方契约。

### 3.1 切片

1. **Phase 15-2A 旁路收口（已完成）**：`hdzm.gd` 的 4 处直接 `change_scene_to_file` 已迁入 `Global.change_scene`；业务代码不再保留裸切换。
2. **Phase 15-2B 入口契约（已完成）**：`Global.change_scene` 现在校验空目标/非场景/缺失目标，拒绝时返回 `false` 且不清理状态；快速路径同步写 `target_scene`；接受时返回引擎提交结果。加载页失败状态由 Phase 15-2C 保留；底层线程取消/失败聚合仍归 Phase 15-3。
3. **Phase 15-2C 加载页交接（已完成）**：加载页在 `_ready` 固定 `_target_scene` 与请求代次，预载/缓存/完成切换统一使用快照；旧代次不再写缓存或切换；目标无法加载、实例化或加载后失效时保留当前加载页并显示失败，不执行 `change_scene_to_*`。

### 3.2 必须验证

- 冷启动 → 主菜单 → 关卡；
- 关卡 → 主菜单 → 再次进入；
- 同一关卡返回/重战；
- 强制加载页与缓存快速路径；
- 目标为空、目标缺失、重复切换、切换中退出；
- 旧场景释放、HUD 揭幕与首帧防黑屏语义不退化。

### 3.3 出口

- 业务代码不再直接调用 `change_scene_to_file/packed`；
- 加载页不再直接调用 `change_scene_to_file/packed`，只通过目标快照与请求代次交接；
- 调用方不依赖旧的延迟切换旁路；
- 相关 L2/场景冒烟已通过；冷启动返回、重战、强制加载与切换中退出仍需补验。

**当前 15-2/15-3A/15-3B 证据**：`level_1` 冒烟 PASS（23.59s，0 ERROR / 0 WARNING）、`scene_probe_runner` 完整套件 PASS 5/5（选择态 15.11s、租约 2.91s、星座 4.71s、法宝 6.33s、角色技能 4.15s）、全量关卡回归 PASS 128/128 + SKIP 5（725.5s）；临时契约探针验证空/缺失目标拒绝、`target_scene` 未变、有效目标接受；重复切换探针验证最新目标获胜；目标加载后失效探针验证 current_scene 保留加载页且未提交失败目标。租约探针验证按租约释放、共享缓存保留、旧租约 ID 拒绝、重战清理与退出归档清理；连续切关探针验证真实关卡租约绑定目标；加载页私有缓存访问已清零。冷启动返回、重战、强制加载、切换中退出仍属 Phase 15-3C/后续运行验证。

## 4. Phase 15-3：加载页预载与资源交接（15-3A/15-3B 完成，15-3C/15-3D 未启动）

**目标**：让加载页只负责“请求与编排”，资源缓存由明确所有者持有；切换、取消和失败不留下陈旧回调或跨关卡资源。

### 4.1 切片

1. **Phase 15-3A 交接 API（已完成）**：加载页只使用 `Global.is_resource_cached`、`Global.get_cached_packed_scene` 与 `Global.handoff_loaded_resource`；不再直接读写 `_resource_cache` / `_audio_cache` / `_texture_cache`，也不调用 `_cache_threaded_resource` / `_track_level_resource`。
2. **Phase 15-3B 关卡资源租约（已完成）**：`_level_resource_lease` 记录目标场景、租约 ID、拥有路径、场景/怪物/弹体/纹理/音频分类、已预热场景与已预热怪物 ID；`change_scene` 建立新租约，释放只处理本租约路径，永久 UI 与未登记路径保留；`clear_combat_runtime_cache` 移除宽泛前缀删除。
3. **Phase 15-3C 失败与取消**：线程失败、目标切换、提前退出、重复请求和加载页销毁时，取消/使过期回调失效；失败不进入可玩场景。
4. **Phase 15-3D 预载清单边界**：`LevelPreloadStore` 与构建期 Catalog 保持只读；不在加载页重新扫描脚本、目录或解析 manifest。

### 4.2 必须验证

- 预载成功、失败、超时/取消与目标切换；
- 关卡缓存命中与未命中；
- 角色/宠物/剑阵/法宝/怪物/弹体依赖的交接；
- 退出加载页后后台请求不再写回；
- 内存/纹理租约与重复进出不持续增长。

### 4.3 出口

- 缓存只有一个写入所有者；加载页只通过 `handoff_loaded_resource` 提交结果；
- 租约释放可枚举、可观测（Phase 15-3B 已完成）：`get_level_resource_lease_snapshot` 返回分类快照；释放只删除本租约路径，旧租约 ID 被拒绝；
- 线程失败/取消不留下过期回调（Phase 15-3C）；
- 加载失败不落入可玩场景或半初始化状态。

## 5. Phase 15-4：缓存、池、UI 与退出生命周期（未启动）

**目标**：把缓存/池/UI 的作用域、清理入口和退出语义闭合；增加边界守卫后才标记 Phase 15 完成。

### 5.1 切片

1. **Phase 15-4A 缓存作用域**：按永久、关卡、战斗、UI、构建期只读资源分类；每类有所有者、容量/驻留依据、清理事件和观测入口。
2. **Phase 15-4B 对象池**：确认池根、容量上限、复用前重置、池作用域与关卡清理；避免跨关卡复用带旧 owner/计时/信号的节点。
3. **Phase 15-4C 临时 UI**：把 `cleanup_transient_ui` 的硬编码名称清理逐步替换为显式实例登记/关闭回调；保留永久小 UI 的预载边界。
4. **Phase 15-4D 退出与后台**：核对 `_exit_tree`、档案会话结束、关卡清理、纹理请求与所有异步回调；过期结果不得写回已结束的关卡或实例。
5. **Phase 15-4E 边界守卫**：扩展现有静态审计，阻断业务旁路 `change_scene_to_*`、加载页对私有缓存字段的直接访问、未登记的池/UI 清理入口；规则与自测登记到 `scripts/README.md` 与 `acceptance.md`。

### 5.2 必须验证

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

## 6. 验证矩阵

既有命令与档位以 [`acceptance.md`](../reference/acceptance.md) 为准，不在本页复制历史数字。

| Phase/变更 | 必需证据 | 不必无差别执行 |
|:---|:---|:---|
| Phase 15-1 调用面矩阵 | 全量引用、owner/清理/失败表、链接与格式；结果见 [`runtime_lifecycle_matrix.md`](../reference/runtime_lifecycle_matrix.md) | 引擎、关卡回归不因只读调查复跑 |
| Phase 15-2A/15-2B 入口契约 | `hdzm.gd` 旁路清零；空/缺失目标拒绝；快速路径目标一致；`level_1` 与关卡选择探针通过 | 不以单个 L1 场景替代所有入口 |
| Phase 15-2C 加载页交接 | 目标快照、重复切换、失败不提交目标、缓存代次守卫；`level_1`/关卡选择探针/全量回归通过 | 冷启动返回、重战、强制加载和切换中退出仍需按受影响入口补验 |
| Phase 15-3A 交接 API | 加载页私有字段/方法访问为 0；查询/提交/场景读取接口调用；`level_1` 与关卡选择探针 | 接口改名/转发本身不等于租约或取消完成 |
| Phase 15-3B 关卡资源租约 | 租约分类、按租约释放、共享缓存保留、旧租约 ID 拒绝；`level-resource-lease` 探针、`level_1` 与关卡选择探针 | 租约探针通过不等于线程取消完成 |
| Phase 15-3C 失败与取消 | 成功/失败/取消/提前退出；缓存写入与租约释放；相关关卡与 L2 | 只编译或只检查请求数不等于行为正确 |
| Phase 15-4 生命周期收口 | L2、全量回归、退出/重复进出、守卫正负样本、构建/引用/命名检查 | 包路径/导出无变化时不强制重导 release |
| 影响资源/输入/物理 | 实际运行路径与 release 触发条件 | 文档或只读矩阵不触发 release |

## 7. 阶段出口与恢复

- 所有实际场景流转走正式入口；加载页内部实现与业务旁路已分离；
- 缓存、池、UI 与后台请求有明确所有者、作用域和退出语义；
- 正常、边界、失败、取消、重复进入退出均有验证证据；
- 旧入口与兼容分支删除，不保留永久 facade；
- 文档、ADR、脚本索引与状态一致；需要长期保留的结论进入 `reference`，历史实施细节归档。

中断时从 Phase 15-1 所有权矩阵和最近一个已验证切片恢复；失败回滚该逻辑阶段，不恢复旧旁路或旧缓存写入路径。Phase 15 完成后归档本页，再建立下一候选计划。

**恢复入口**：[Phase 15-1 矩阵](../reference/runtime_lifecycle_matrix.md)、[`architecture.md`](../reference/architecture.md) 的场景/缓存章节、[`acceptance.md`](../reference/acceptance.md) 的 L2 档位。

**下一候选顺序**：Phase 16 档案会话/持久化/槽位 → Phase 17 玩法/表现边界。平台与发布验证按独立工作流推进，不等待本阶段。
