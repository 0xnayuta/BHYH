# BHYH 当前候选迭代

> **状态**：**Phase 16：档案会话、持久化与玩家槽位；Phase 16-1 至 Phase 16-6 规划中，尚未启动**。本页记录候选边界、阶段顺序与验收条件，不把目标写成现状。
> **版本**：6.9；不新增玩法、任务与掉落，不改变数值、存档格式、本地双人共享规则或显示基线。
> **职责**：本页展开当前候选 Phase 16；Phase 17 的方向、启动依赖与独立平台项目统一见 [`roadmap.md`](roadmap.md)。
> **依据**：[`总体目标契约`](../standards/target_architecture_contract.md) §3、§5、§6、§10~§11；[`godot_design_standard.md`](../standards/godot_design_standard.md) §3.2~§3.4、§8；[`ADR-005`](../decisions/ADR-005-no-compatibility-or-fallback-layers.md)、[`ADR-006`](../decisions/ADR-006-resource-first-data-and-data-keys.md)、[`ADR-007`](../decisions/ADR-007-autoload-boundary.md)、[`ADR-017`](../decisions/ADR-017-local-coop-profile-isolation.md)、[`ADR-021`](../decisions/ADR-021-project-wide-target-architecture.md)；[`architecture.md`](../reference/architecture.md)、[`acceptance.md`](../reference/acceptance.md)、[`status.md`](../reference/status.md)。
> **历史**：[Phase 15 已归档](../archive/iteration_15_app_orchestration_lifecycle.md)；Phase 14 归档见 [`iteration_14_atlas_metadata_boundary.md`](../archive/iteration_14_atlas_metadata_boundary.md)；更早归档见 [`archive/README.md`](../archive/README.md)。

## 1. 阶段边界与决策

### 1.1 目标

收敛档案会话、持久化与玩家槽位：让档案读写、共享账本、1P/2P 个体状态与面板数据视图各自有明确的所有者、正式入口和失败边界；保留现有加密 JSON 格式、共享/个体业务语义与存档可靠性策略。

- 档案、共同账本与玩家槽位分别标明写入者；同一业务状态只有一个权威写入者；
- 存档 IO 只由明确边界执行：界面、战斗规则与奖励结算不拼档案路径、不直接写文件；
- 保存快照与工作线程隔离，回写结果校验会话身份与保存顺序；退出/切档处理未完成保存；
- 面板接收显式操作者与数据视图，不通过临时交换全局 1P/2P 对象获得权限；
- 一个职责边界迁移时同步迁移全部生产调用方，删除被替代的全局交换入口，运行中不能并存两套可写真源；
- 不新增 Autoload；Autoload 增删/合并必须先评审。

### 1.2 不在本阶段

- 不改存档业务格式、字段语义、加密算法、稳定密钥、`.tmp`/`.bak` 原子替换与 `ensure_*` 补全策略；确需改变则另立 ADR 与验收；
- 不把整个 `player_data` 改成 Resource，不做全量类型化重写；类型化按业务域另列批次；
- 不重构战斗继承、命中归属、技能/弹体业务规则；这些归 Phase 17；
- 不改变本地双人的共享项目与个体项目划分（装备/道具/消耗品/宠物背包、被动技能、主线剑阵、灵魂、炼体、万灵图录为共享；等级/属性/技能/装备穿戴/宠物出战为个体）；
- 不新增跨版本号迁移链，不迁移旧 `user://` 目录、旧任务键与旧配置（ADR-005）；
- 不修改素材、数值、动画时序、输入映射、物理层或 UI 视觉基线；不改动 Phase 15 已收口的场景/缓存/池/UI 生命周期语义。

### 1.3 当前事实与调查结果

| 边界 | 当前事实 | 本阶段取证要求 |
|:---|:---|:---|
| 存档写入面 | `MemoryClass.save_game(path)` 有 **118 处调用、60 个文件**；`Global.cd_path` 有 **149 处引用、62 个文件**；`request_background_save` 仅 `base_monster.gd` 1 处调用 | 16-1 枚举全部写入者、调用场景、失败处理与重复保存风险 |
| 档案路径身份 | 唯一格式为 `user://MyAr_<n>.json`；路径字符串 `Global.cd_path` 是事实上的会话标识，没有独立会话对象 | 16-2/16-3 定义会话身份、保存顺序与过期写入拒绝 |
| 直接数据访问 | `PlayerData.player_data` 有 **1,288 行引用、119 个文件**，其中 **156 行直接下标写入、40 个文件** | 16-4/16-5 按业务域收口；不建立一次性全量重写前置 |
| 存档校验 | `_is_valid_player_archive_data` 只要求 `玩家等级`、`Myself` 与三个容器首页；云导入校验 `Myself` 为 **1..6**，运行时角色支持 **1..7**（含玉兔） | 16-2 记录该不一致并按现有实现评审，不在本阶段静默改格式 |
| 规范化补全 | `PlayerData` 有 **20 个 `ensure_*` / `normalize_*` / `migrate_*` 入口**，由 `_prepare_primary_player_save_data` 串行调用 | 16-2 明确幂等边界与失败可见性，禁止把补全失败当成功 |
| 后台保存 | `_save_thread` 单线程 + 待写队列 + 失败保留快照；`flush_pending_saves` 在 `_notification` 与 `_exit_tree` 调用 | 16-2 验证顺序、切档、退出与失败重试；不允许静默丢写 |
| 档案会话 | `archive_session_active`、`archive_session_role_id`、`_archive_session_generation`、`_runtime_generation` 由 `Global` 持有；退出场景仅 `main_menu.tscn` 与 `choose_player.tscn` | 16-3 定义会话上下文与存档身份校验，保留现有退出语义 |
| 双人槽位 | `LocalCoop` 提供 `slot_for`/`data_for`/`props_for`/`canonical_profile_for_slot`；`BAG_KEYS` 共享、`save_profile` 剥离共享键；槽位解析顺序 meta → 祖先 `coop_slot` → `owner_hero()` → 脚本前缀 → 1 | 16-4 校验共享/个体边界与冲突合并规则，保留业务语义 |
| 面板视图交换 | `LocalCoop.suspend_player_view`/`resume_player_view` 共 **8 处调用（另含 2 处定义）**；`open_panel` 按槽位 `_activate_slot_view`，关闭时恢复；保存前 `_prepare_player_save_data` 先挂起再抓快照 | 16-5 以显式操作者绑定替换，联动保存快照与全部受影响面板 |
| 既有验收 | L2 固定套件与全量回归档位见 [`acceptance.md`](../reference/acceptance.md)；双人矩阵见 `coop_probe_runner.py` 的 16 项用例 | 16-1 只读；16-2 起按受影响边界触发运行验证 |

Phase 16 的前置调查只确认现状，不把目标语义写成已实现。共享/个体规则、存档格式与可靠性策略是**不变量**，任何变更需另立 ADR。

## 2. Phase 16-1：档案、持久化与槽位调用面矩阵（只读调查）

**目标**：在不改运行时代码的前提下，建立存档读写、档案会话、玩家槽位与面板数据视图的完整调用面，确定每个状态的所有者、写入者、失败边界与迁移批次。

### 2.1 调查内容

1. 枚举 `MemoryClass.save_game`、`request_background_save`、`safe_write_archive`、`load_game`、`main_dq`、`main_bc` 的全部调用点、调用场景与返回值处理；
2. 枚举 `Global.cd_path` 的读写点，区分“设置档案身份”和“读取档案身份”两类用法；记录路径字符串进入业务逻辑的位置；
3. 枚举 `PlayerData.player_data` 的直接下标写入，按业务域（背包/装备、技能、宠物、坐骑、炼体、任务、商店、锻造、奖励、设置）分类，标出跨域写入与重复写入；
4. 枚举 `ensure_*`/`normalize_*`/`migrate_*` 的输入前提、幂等性与失败表现，确认保存路径是否可能把补全失败当成功；
5. 枚举档案会话字段的读取方、`begin_archive_session`/`end_archive_session` 的触发点、切档/退档/退出时的未完成保存；
6. 枚举 `LocalCoop` 槽位 API（`slot_for`、`data_for`、`props_for`、`canonical_profile_for_slot`、`pet_profile_for`）的生产调用方，区分已槽位感知与仍假定 1P 的代码；
7. 枚举 `suspend_player_view`/`resume_player_view` 的调用点、面板打开/关闭/切换/暂停/场景退出路径，以及保存快照与视图交换的互斥关系；
8. 区分“配置文件/静态定义”“档案传输格式”“实例状态”三类数据，禁止把静态 Resource 与玩家档案混为一谈。

### 2.2 交付矩阵

产出 `docs/reference/archive_session_matrix.md`（新建），至少包含：

| 状态/能力 | 所有者 | 写入者 | 读取者 | 失效/清理事件 | 当前失败语义 |
|:---|:---|:---|:---|:---|:---|
| 档案文件 `<n>.json` | `MemoryClass` | `save_game`、`request_background_save`、`safe_write_archive` | `load_game`、`peek_archive_data`、归档界面 | 显式保存、退出 flush | 失败返回 `false`；不覆盖不可读档 |
| 档案身份 `Global.cd_path` | `Global` | 建档/读档入口 | 全部保存调用方 | 切档、回主菜单 | 空字符串表示无档案；无独立会话校验 |
| 档案会话 | `Global` | `begin_archive_session`/`end_archive_session` | 预热、加载页、UI 缓存 | 进入主菜单/选角、应用退出 | 应用退出由 `_exit_tree` 清空 |
| 1P 档案 | `PlayerData`（`PlayerDataStore`） | 40 个文件的直接写入 | 119 个文件 | 读档、切档、退出 | 依赖 `ensure_*` 补全 |
| 2P 档案 | `LocalCoop.secondary_data` | `LocalCoop` 与共享键回写 | 槽位感知调用方 | `clear_runtime`、切档 | 视图交换期间由 `PlayerData` 别名代表 |
| 共享账本 | `PlayerData` 共享键 + `LocalCoop._shared_soul` | 双人合并逻辑 | 面板与战斗 | `link_bags`、`normalize_shared_soul` | 合并冲突按 `maxi` / 追加规则 |
| 面板数据视图 | `LocalCoop._view_swapped` | `suspend`/`resume_player_view` | 面板与保存快照 | 面板关闭、场景退出 | 全局别名切换，非显式绑定 |

### 2.3 出口

- 每个存档写入点都有调用场景、失败处理与是否可能重复保存的记录；
- 直接写入按业务域分类，标出迁移候选与不迁移理由；
- 视图交换的调用面完整，保存快照与面板生命周期的互斥关系可验证；
- 仅文档与只读报告，不改生产代码；结果进入 `docs/reference/archive_session_matrix.md` 与 `docs/reference/status.md`。

## 3. Phase 16-2：存档 IO 边界与保存顺序

**目标**：把存档读写收敛到单一持久化边界；保存失败、切档、退出与后台回写都有明确结果，不出现静默丢写或覆盖错误档。

### 3.1 切片

1. **Phase 16-2A 写入入口收口（规划）**：枚举并迁移 118 处 `save_game` 调用；业务侧只提交“请求保存”，不拼路径、不判断文件系统结果；路径只由持久化边界从当前档案身份解析；
2. **Phase 16-2B 会话身份与保存顺序（规划）**：保存请求携带档案身份与序号；快照生成后若档案身份变化，回写必须被拒绝；后台队列按档案分组，切档/退档前 flush 或明确失败；
3. **Phase 16-2C 失败语义与校验（规划）**：保存返回明确结果；`.tmp` 校验失败、`.bak` 恢复、不可读档拒绝、空档不覆盖原档均有定向用例；`_is_valid_player_archive_data` 的字段范围与云导入 `Myself` 范围不一致按现有实现评审后统一；
4. **Phase 16-2D 规范化补全边界（规划）**：`ensure_*`/`migrate_*` 保持幂等；补全失败必须阻止保存并返回原因，不允许“补全异常但写入成功”；不新增跨版本迁移链。

### 3.2 必须验证

- 当前格式存档的读取、保存、重载与备份恢复；
- 缺失字段补全、损坏档拒绝、空档不覆盖、`.tmp` 残留清理；
- 连续保存、切档、回主菜单、退出时未完成保存；
- 后台保存失败后的重试与退出 flush；
- 双人档案保存时共享键与个体键的写入结果。

### 3.3 出口

- 业务代码不直接拼接 `user://MyAr_*.json`，不直接调用底层写文件函数；
- 保存结果可判断，失败不伪报成功；
- 保存顺序与档案身份可校验，过期回写被拒绝；
- 现有加密、稳定密钥、原子写与备份语义保持不变。

## 4. Phase 16-3：档案会话上下文

**目标**：让“当前档案会话”成为显式上下文，而不是散落的路径字符串与全局布尔；会话开始/结束、角色切换与存档身份之间保持单一真源。

### 4.1 切片

1. **Phase 16-3A 会话身份（规划）**：为当前档案建立只读会话标识（档案编号/路径、角色、会话代次）；`Global.cd_path` 的字符串用法收窄为持久化边界内部表示；
2. **Phase 16-3B 会话生命周期（规划）**：`begin_archive_session` 与 `end_archive_session` 的触发条件、重复调用、角色变化与退出语义固定；会话结束撤销借用上下文，不残留上一档案的缓存与标记；
3. **Phase 16-3C 会话失败边界（规划）**：读档失败、档案不可读、会话未建立时禁止保存与进入关卡；加载页与场景入口返回明确失败，不进入半初始化状态。

### 4.2 必须验证

- 冷启动 → 读档 → 主菜单 → 关卡 → 返回 → 重战；
- 切档（档案 A → 档案 B）与角色变化；
- 档案不可读/损坏/为空时的拒绝路径；
- 会话结束（回主菜单/选角）后再次进入同一档案；
- 应用退出时会话清理与未完成保存。

### 4.3 出口

- 当前档案会话只有一个权威表示，禁止并列的路径字符串与布尔标志各自判定；
- 会话代次可观测，供保存与异步回调校验；
- 会话失败返回明确结果，不进入可玩场景；
- 不新增 Autoload，不改变存档格式。

## 5. Phase 16-4：玩家槽位与共享账本

**目标**：把 1P/2P 的数据、属性与共享账本边界固定为显式槽位查询；保留现有共享/个体业务语义与合并规则。

### 5.1 切片

1. **Phase 16-4A 槽位查询收口（规划）**：`LocalCoop.slot_for`/`data_for`/`props_for`/`canonical_profile_for_slot` 成为业务读取的唯一入口；清除仍假定 `/root/PlayerData` 即当前操作者的新增代码路径；
2. **Phase 16-4B 共享账本（规划）**：装备/道具/消耗品/宠物背包、被动技能、主线剑阵、灵魂、炼体、万灵图录的共享写入只经共享账本入口；`link_bags`、`normalize_shared_soul`、`_merge_progression_dict` 的合并规则保持并补定向用例；
3. **Phase 16-4C 个体状态（规划）**：等级/属性/技能/装备穿戴/宠物出战的个体写入按槽位归属；`save_profile` 继续剥离共享键，禁止 2P 档案携带共享副本；
4. **Phase 16-4D 槽位解析与遗留路径（规划）**：`meta → 祖先 coop_slot → owner_hero() → 脚本路径前缀 → 默认 1` 的解析顺序保留并记录为遗留边界；新增代码不得依赖脚本路径前缀推断。

### 5.2 必须验证

- 1P/2P 独立：等级、属性、技能、装备、宠物出战互不串槽；
- 共享：背包、灵魂、炼体、万灵图录、被动技能、主线剑阵一致且只扣一次；
- 伤害/无双/吸血/宠物归属解析实际出手者；
- 切档与 `clear_runtime` 后不残留上一会话槽位；
- `coop_probe_runner` 全用例通过。

### 5.3 出口

- 共享项与个体项各有唯一写入者，运行中不存在两套可写真源；
- 槽位查询可枚举、可验证，新增代码不假定 1P；
- 共享/个体业务语义与数值不变；
- 不复制 Autoload、不新增第二组全局单例。

## 6. Phase 16-5：面板显式操作者与保存快照互斥

**目标**：以显式操作者/数据视图替换全局 1P/2P 视图交换；面板关闭、暂停、切档与保存快照期间保持数据一致。

### 6.1 切片

1. **Phase 16-5A 面板操作者绑定（规划）**：面板由打开者传入槽位、数据视图与容器依赖；面板不再通过 `PlayerData` 全局别名读取当前操作者；
2. **Phase 16-5B 视图交换收口（规划）**：`suspend_player_view`/`resume_player_view` 的调用点随面板迁移同步删除；迁移完成前保留现有交换与保存前挂起保护，不得先移除；
3. **Phase 16-5C 保存快照互斥（规划）**：保存快照生成期间禁止面板切换视图；快照与视图交换的互斥由单一入口保证；关闭/暂停/场景退出时恢复焦点、输入占用与连接；
4. **Phase 16-5D ESC 与生命周期（规划）**：复用 `request_escape_close() -> bool` 与关卡 HUD 分发；面板关闭只关闭一层，不重复释放；面板释放后不残留信号与全局窗口引用。

### 6.2 必须验证

- 1P/2P 分别打开背包/技能/宠物/法宝/坐骑面板，读写归属正确；
- 面板内保存、面板切换、暂停、ESC 关闭、场景退出；
- 保存快照期间打开/关闭面板不产生串档；
- 关闭后焦点、输入与 `Global.windows` 恢复；
- `coop_probe_runner` 的面板、共享灵魂、技能键位、剑阵/坐骑、创建 UI 与无双归属用例通过。

### 6.3 出口

- 面板只使用显式操作者与数据视图，不依赖全局别名切换；
- 保存快照与面板视图互斥有单一入口与定向用例；
- 被替代的全局交换入口与调用方同批删除，不保留 facade；
- 现有双人玩法、共享规则与显示基线不变。

## 7. Phase 16-6：边界守卫与阶段收口

**目标**：把档案/槽位边界纳入静态审计，阻断新的直接写档、路径拼接与全局视图交换；阶段出口以门禁与运行证据共同确认。

### 7.1 切片

1. **Phase 16-6A 静态守卫（规划）**：扩展 `contract_scan.py`，新增档案边界类别（禁止业务拼接 `user://MyAr_`、禁止业务调用底层写文件函数、禁止新增 `PlayerData.player_data` 直接下标写入的登记外文件、禁止登记外 `suspend/resume_player_view` 调用）；规则与正负样本登记到 `scripts/README.md` 与 `acceptance.md`；
2. **Phase 16-6B 清理与索引（规划）**：删除被替代的旧入口与惰性字段；同步 `architecture.md`、`archive_session_matrix.md`、`acceptance.md`、`status.md` 与脚本索引；
3. **Phase 16-6C 阶段验收（规划）**：L2 固定套件（含 `coop_probe_runner` 全用例）、全量关卡回归、`check_all --godot-bin`、`health_check` 与契约自测；需要时补 release 重验。

### 7.2 必须验证

- 静态守卫正负样本通过，全仓无新增误报；
- 直接写档、路径拼接与未登记视图交换为 0；
- 双人矩阵与全量回归通过；
- 文档、矩阵、验收、状态与脚本索引一致。

### 7.3 出口

- 档案、共享账本与槽位边界均有 owner、正式入口与失败语义；
- 不再存在业务侧直接写档或运行中两套可写真源；
- 旧入口与兼容分支删除；
- Phase 16 完成后归档本页，再建立下一候选计划。

## 8. 验证矩阵

既有命令与档位以 [`acceptance.md`](../reference/acceptance.md) 为准，不在本页复制历史数字。

| Phase/变更 | 必需证据 | 不必无差别执行 |
|:---|:---|:---|
| Phase 16-1 调用面矩阵 | 全量引用、owner/写入者/失败表、链接与格式；结果见 `archive_session_matrix.md` | 引擎、关卡回归不因只读调查复跑 |
| Phase 16-2 存档 IO | 当前格式读写、缺字段补全、损坏档拒绝、备份恢复、保存顺序与退出 flush；定向存档夹具 | 只测新档或只编译不等于持久化正确 |
| Phase 16-3 会话上下文 | 切档、角色变化、不可读档拒绝、会话结束重入、退出清理 | 只改一个入口不覆盖全部读档路径 |
| Phase 16-4 槽位与共享账本 | `coop_probe_runner` 全部用例；共享/个体写入归属；切档后无残留 | 单测 1P 或只测 UI 不等于双人正确 |
| Phase 16-5 面板与快照 | 五类面板的 1P/2P 读写、保存快照互斥、ESC/暂停/退出、焦点恢复 | 只改 `LocalCoop` 或只改 UI 都不算完成 |
| Phase 16-6 边界守卫 | 静态守卫正负样本、全仓零 ERROR、L2、全量回归 | 包路径/导出无变化时不强制重导 release |

## 9. 阶段出口与恢复

- 档案、共同账本与玩家槽位均有唯一写入者与明确失败语义；
- 存档 IO 只由持久化边界执行，保存顺序与档案身份可校验；
- 面板使用显式操作者与数据视图，保存快照与视图互斥；
- 旧入口与兼容分支删除，不保留永久 facade；
- 文档、ADR、脚本索引与状态一致；需要长期保留的结论进入 `reference/`，历史实施细节归档。

中断时从 Phase 16-1 的调用面矩阵与最近一个已验证切片恢复；失败回滚该逻辑阶段，不恢复旧的全局视图交换或直接写档路径。Phase 16 完成后归档本页，再建立下一候选计划。

**恢复入口**：`archive_session_matrix.md`、[`architecture.md`](../reference/architecture.md) 的档案/双人章节、[`acceptance.md`](../reference/acceptance.md) 的 L2 档位、`scripts/coop_probe_runner.py` 的 16 项用例。

**下一候选顺序**：Phase 16 档案会话/持久化/槽位 → Phase 17 玩法/表现边界。平台与发布验证按独立工作流推进，不等待本阶段。
