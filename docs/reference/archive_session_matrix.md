# 档案会话、持久化与玩家槽位调用面矩阵（Phase 16-1）

> **状态**：Phase 16-1 只读调查完成（2026-10-28）；2026-10-29 已实施 Phase 16-2A 全部 118 处、16-2B 会话身份与保存顺序、16-2C 角色范围/损坏档校验、16-2D 补全边界与 16-3 档案会话上下文。本页记录**当前实现事实**与失败边界，未实施的 16-4/16-5/16-6 目标不写成已实现。
>
> **调查基线**：`f7f7a2c`（2026-10-28 Phase 15 归档 / Phase 16 规划）；2026-10-29 更新 16-2A 五个批次与 16-2C 实施结果。仓库只有一个活跃工程 `source/`。
>
> **方法**：以 `source/**/*.gd`、`source/project.godot` 与当前 Markdown 为唯一事实源，使用静态扫描（`grep` 等价的正则统计）与关键函数逐行阅读。下文计数是**静态行数/出现次数**，可能包含条件分支、重复调用与暂时不可达路径，不等同于运行期次数；口径在每张表标题处注明。
>
> **范围**：`MemoryClass` 的档案读写与后台保存、`Global` 的档案身份与会话字段、`PlayerData` 的档案字典写入、`LocalCoop` 的槽位与面板视图交换、存档界面的云存档与删档路径。战斗数值、掉落规则、素材质量与 Phase 15 已收口的场景/缓存/池生命周期不在本页范围。

---

## 1. 结论摘要

1. **存档文件只有一个写入边界，入口收敛为三层**：`MemoryClass.request_save`（**116 处 / 59 文件**，统一入口）、`MemoryClass.save_game`（**仅持久化边界内部 1 处委托**，业务侧 0 处）与 `MemoryClass.safe_write_archive`（3 处外部调用，全部在存档界面）。除这两个入口外，全仓没有第三处写**档案路径** `user://MyAr_*.json` 的代码；云存档的临时 ZIP 与加密分片由存档界面自行写入 `user://cloud_save_upload|import`，不进入本地档案命名空间。`request_background_save` 仅 `base_monster.gd` 1 处调用。
2. **保存点已全部收口**：16-2A 前 118 处 / 60 文件 / 109 函数；经首批 17 处、第二批 58 处（`back_pack` 25、`skill` 18、`ldl` 15）、第三批 19 处（`main_menu`）、第四批 11 处（`level`）与收尾批次 13 处迁移后，业务侧 `save_game` 调用为 **0**；仅 `MemoryClass.request_save` 内部保留 1 处 `save_game(archive_path)` 委托。地图页 `_ready`、关卡结算与全部业务面板均改为提交保存请求。
3. **保存结果判读仍不足**：16-2A 前仅 5/118 处检查返回值；这 5 处已全部迁移到 `request_save`。收尾后仅 4 处判读 `request_save` 返回值（`choose_player`、`forge`、`victory._save_completed_level`、`level_llbt`），其余 UI 丢弃 `bool`。`last_save_error` 与 `describe_save_error()` 已提供可读原因，`choose_player`/`forge` 已接入；其余面板反馈留给 16-5。
4. **档案身份已收口到唯一写入口**：`Global.set_cd_path()` 是唯一写入点（原 3 处直接赋值已迁移），赋值时先 `flush_pending_saves()` 再递增 `_archive_identity_epoch`；`Global.cd_path` 现为 40 行 / 42 次出现 / 22 个文件，9 处经 `get_cd_path()`/`set_cd_path()`，3 处格式守卫、1 处 `find`、1 处 `split`，其余为空值守卫。
5. **保存与读档身份/顺序已可校验（16-2B）**：`save_game` 在快照前后各校验一次「路径的档案号 + `_archive_identity_epoch`」；后台任务携带入队时的 epoch，切档后到达的旧任务被丢弃，不写盘也不更新元数据。`Global.set_cd_path` 在切换前 flush 待写队列。`last_save_error` / `describe_save_error()` 提供程序化与可读失败原因。
6. **补全失败会阻止保存（16-2D）**：`_prepare_primary_player_save_data` 按固定 19 步执行补全，随后用 `_normalization_postcondition_error()` 校验容器、宠物、坐骑、被动、剑阵、万灵、已获取装备与等级；任一不满足即拒绝写入，不再"补全异常但保存成功"。补全顺序调整为 `enforce_level_caps` 最后，新建宠物立即执行自身规范化，保证首次保存即幂等。
7. **`load_game` 使用合并而非替换**：`_player.merge(archive_data, true)` 只覆盖存档中存在的键；未回主菜单连续读取两个档案会残留上一档的进度键。当前依赖 `main_menu._ready()` 的 `remove_play_data()` 清空来兜底。
8. **直接数据写入 141 行 / 44 个文件**（`=` 129 行 / 39 文件 + `+=` 12 行 / 7 文件），另有 1 处 `erase`；`PlayerData.player_data` 共 1,288 行引用、119 个文件、1,335 次出现。按业务域以关卡进度 58、宠物 32 为主，6 个文件跨域写入。
9. **规范化补全入口 21 个**（20 个 `ensure_*`/`normalize_*`/`migrate_*` + `enforce_level_caps`）；保存侧执行 19 个步骤（16-2D 后统一为固定清单，`enforce_level_caps` 最后执行）；读档侧另行维护 17 个调用，两侧仍不完全对称。补全返回值多为 `void`/“是否新增”，不能表达失败，因此保存侧改用**后置条件**判定（见 §8.4）。
10. **槽位 API 已有单一入口，但使用率极低**：`slot_for` 20 次 / 7 文件、`data_for` 19 次 / 19 文件、`data_for_slot` 5 次 / 3 文件、`props_for` 22 次 / 20 文件、`pet_profile_for` 16 次 / 1 文件、`pet_meta_key` 32 次 / 5 文件、`input_for` 2 次 / 2 文件；`canonical_profile_for_slot` 仅 3 次、`props_for_slot` 仅 1 次（均在 `BaseRoleProperties` 内部）。
11. **面板仍整体依赖全局视图交换**：20 个面板目录脚本共 354 处直接读 `PlayerData.player_data`，没有任何槽位感知；`suspend/resume_player_view` 共 8 处调用（6 处在本类、2 处在 `MemoryClass`）+ 2 处定义。`Global.get_player` 仍有 19 次 / 10 个文件引用，混合 1P 假设。
12. **档案会话已成为唯一上下文（16-3）**：`Global._archive_session`（`ArchiveSession` 只读值对象）持有档案号、角色、路径与会话代次；`is_archive_session_active()`/`get_archive_session_path()`/`get_archive_session_archive_number()`/`get_archive_session_role_id()` 是唯一查询面。业务侧不再出现 `cd_path` 引用，也不再用 `contains("Ar_")` 推断会话状态；`request_save`、`request_background_save` 与关卡入口在无会话时一律拒绝。
13. **角色范围已统一为 1..7**：本地校验、云上传/导入收集与运行时共用 `MemoryClass.is_valid_role_id`；`0/8/非数值` 一律拒绝，玉兔档可上传/导入。

---

## 2. 数据三分类与不变量

### 2.1 三类数据

| 类别 | 载体 | 生命周期 | 所有者 | 写入边界 |
|:---|:---|:---|:---|:---|
| **静态定义/配置表** | `DataKeys`、`MOUNT_TEMPLATES`、`PET_*` 常量、`initialized_data`、`AtlasMetadata`/`LevelPreloadCatalog` 等 Resource | 构建期或进程常量 | 模块自身 | 不得写入；运行时只读 |
| **档案传输格式** | `user://MyAr_<n>.json`（加密 JSON，单行或多行合并）、`.bak`、`.tmp` | 跨会话持久 | `MemoryClass` | `request_save`（委托）、`save_game`、`safe_write_archive`、`request_background_save` |
| **实例状态** | `PlayerData.player_data`、`LocalCoop.secondary_data.player_data`、`_primary_runtime_data`、`BaseRoleProperties` | 进程内 | `PlayerData` / `LocalCoop` | 业务按域写入；16-4 收口槽位查询 |

### 2.2 本阶段不变量

- 档案业务格式、字段语义、加密算法、稳定密钥、`.tmp`/`.bak` 原子替换与 `ensure_*` 补全策略不变；
- 共享项：装备/道具/消耗品/宠物背包、被动技能、主线剑阵、灵魂、炼体、万灵图录；个体项：等级/属性/技能/装备穿戴/宠物出战；划分不变；
- 不新增 Autoload；`LocalCoop` 仍为最后注册的业务单例（`source/project.godot` 第 24~38 行）；
- 迁移完成前保留现有视图交换与保存前挂起保护，不得先删保护再迁面板（16-5 明确）。

---

## 3. 状态/能力所有权矩阵

| 状态/能力 | 所有者 | 写入者 | 读取者 | 失效/清理事件 | 当前失败语义 |
|:---|:---|:---|:---|:---|:---|
| 档案文件 `MyAr_<n>.json` | `MemoryClass` | `request_save`（委托）、`save_game`、`request_background_save`、`safe_write_archive` | `load_game`、`peek_archive_data`、`read_archive_time`、存档界面 | 显式保存、切档前 `flush_pending_saves`、退出 flush | 写 `.tmp` → 回读校验 → 旧档转 `.bak` → 原子替换；任一步失败返回 `false`，不覆盖不可读档 |
| 档案备份 `.bak` / 临时 `.tmp` | `MemoryClass` | `_atomic_write_encrypted_dictionary` | `_read_encrypted_dictionary_with_backup` | 每次写入前删除旧临时件；替换成功保留上一版备份 | `.tmp` 残留清理失败即放弃写入；`.bak` 读取失败回退主文件 |
| 稳定密钥 `user://.save_key` | `MemoryClass` | `_ensure_stable_key` | `_load_stable_key`、兼容读取 | 首次保存创建；进程内缓存 | 读不到文件时回退内置 `keys`；写密钥失败仍返回内置密钥（不阻断保存） |
| 会话设置 `user://MainGame.json` | `MainSet` + `MemoryClass` | `main_bc`（74 处调用 / 28 文件） | `main_dq`（16 处调用 / 15 文件） | 设置变更、存档时间/名称回写、退出 flush | `main_bc` 返回 `bool`，74 处调用**全部忽略**；`save_game` 内失败只 `push_warning` |
| 档案元数据（名称/时间/`CdNum`/`其他存档`） | `MainSet.set_data` | `MemoryClass._set_archive_time`/`repair_archive_time`、`back_pack._on_name_text_changed`、`choose_player._update_archive_time`、存档界面增删槽 | 存档列表卡片、`base_hero` 名字显示、`back_pack` 名称栏 | 保存成功、删档、槽位增减 | 与档案文件非原子：文件写成功而元数据失败时只告警，读档时间会回退到文件 mtime |
| 档案身份 `Global.cd_path` | `Global` | **唯一写入口 `Global.set_cd_path()`**：存档卡片选择、主菜单 `_ready`、选角返回（均先 flush 待写队列再递增 `_archive_identity_epoch`） | 23 个文件（18 处经 `get_cd_path()`、3 处格式守卫、1 处 `find`/`split`，其余空值守卫） | 回主菜单、返回选角、切换档案 | 空字符串表示无档案；`save_game` 以「档案号 + epoch」拒绝过期回写；`last_save_error` 给出原因 |
| 档案会话 `archive_session_*` | `Global` | `begin_archive_session` / `end_archive_session` / `_exit_tree` | **仅 `Global` 内部**（预热、`release_ui_runtime_cache`） | 进入主菜单/选角（`is_archive_exit_scene`）、应用退出 | `end_archive_session` 无返回值；重复调用靠 `_archive_session_generation` 与 active 判断吸收 |
| 1P 档案 `PlayerData.player_data` | `PlayerData`（`PlayerDataStore`） | 44 个文件、141 行直接写入 + 少量 API 写入 | 119 个文件 | 读档 merge、`remove_play_data`、切档/退出 | 依赖 `ensure_*` 补全；无效数据靠 `_is_valid_player_archive_data` 拒绝保存 |
| 2P 档案 `LocalCoop.secondary_data` | `LocalCoop` | `create_secondary`、`load_profile`、`save_profile`、共享键回写 | 槽位感知调用方（`data_for_slot` 等） | `clear_runtime`、切档、`load_game` 开头 | 2P 不存在时 `data_for_slot(2)` 回落 1P；`is_enabled()` 要求 `本地双人.启用` |
| 共享账本 | `PlayerData` 共享键 + `LocalCoop._shared_soul` | `link_bags`、`_link_shared_pet_backpack`、`_link_shared_attribute_progression`、`normalize/set_shared_soul`、各共享域直接写入 | 面板、战斗、属性计算 | `link_bags`、`clear_runtime`、保存快照 | 合并冲突按 `maxi` / 追加；`save_profile` 剥离共享键；无冲突上报 |
| 面板数据视图 | `LocalCoop._view_swapped` + `_primary_*` | `suspend_player_view` / `resume_player_view` | 面板脚本（经全局 `PlayerData`/`RoleProp` 别名） | 面板关闭、切换、`clear_runtime`、保存快照 | 全局别名切换，非显式绑定；异常路径可能留下 2P 视图 |
| 云存档 ZIP 绑定 | `read_archive_interface` | `_write_cloud_encrypted_archive`（独立密钥，非 `MemoryClass`） | 上传/导入流程 | 上传临时目录清理、导入临时目录清理 | 导入写回统一走 `safe_write_archive`；`uid` 不匹配即拒绝 |

---

## 4. 存档文件与元数据写入面

### 4.1 `MemoryClass.save_game` 调用面

统计口径：`source/**/*.gd` 中包含 `MemoryClass.save_game(` 的业务物理行（排除 `save_game` 定义与 `request_save` 内部委托）。16-2A 收尾后为 **0 行**；全仓仅 `memory_class.request_save` 内部保留 1 处委托。`request_save` 共 116 处（见 4.2）。

| 分类 | 数量 | 说明 |
|:---|:---:|:---|
| `Script/main_menu`（地图页、面板、公告、选角） | 0 | 第三批 19 处全部迁移到 `request_save` |
| `Scene/other_scene` | 0 | 收尾批次已迁移（奖励界面、幻化箱） |
| `Script/base` | 0 | 收尾批次已迁移（`base_monster`、`base_role_properies`） |
| `Script/pet` / `Script/shop` | 0 / 0 | 收尾批次已迁移（宠物面板、商店购买） |
| `Script/memory_class` | 0 | `remove()` 的清档改为只写初始档，删除覆盖式 `save_game` |
| 其他（`monster_130`、`c_hange_clothes_jm`、`basic_task`） | 0 | 收尾批次已迁移（月兔解锁、换装、任务领奖） |
| **已迁移** `Script/back_pack` / `Script/skill` / `Script/ldl` | **0** | 第二批 58 处全部改为 `request_save` |
| **已迁移** `Script/main_menu` | **0** | 第三批 19 处全部改为 `request_save` |
| **已迁移** `Script/level` | **0** | 第四批 11 处全部改为 `request_save` |

按调用上下文：

| 上下文 | 数量 |
|:---|:---:|
| `_on_*_pressed` / `_on_*_toggled` / `_on_*_selected` 回调 | 0 |
| 场景 `_ready` | 0（11 个地图页已迁移到 `request_save`） |
| `_process` / `_physics_process` | 0（`reward_interface` 已改为单次 `request_save`） |
| 其他业务函数（升级、合成、挑战、结算、开箱等） | 0 |

### 4.2 `request_save` 统一入口（Phase 16-2A）

`MemoryClass.request_save(reason)` 在持久化边界内部解析 `Global.cd_path`（先 `strip_edges`），路径不合法时**在 flush 之前**返回 `false`；合法时委托 `save_game`，失败时输出带 `reason` 的 `push_warning`。业务侧不再拼路径、不再判断文件系统结果，写盘行为与 `save_game(Global.cd_path)` 一致。

| reason 前缀 | 数量 | 位置 |
|:---|:---:|:---|
| `map_enter` | 11 | `map_1`~`map_9_1` 的 `_ready` |
| `map_save` / `map_0_save` / `map_3_special` | 11 / 1 / 1 | 地图页手动保存、主城保存、特殊按钮同步 |
| `tower_floor_select` / `tower_data` / `zhu_xian_sword` / `wan_ling_catalog` / `game_announcement` / `body_training` | 6 | 真妖塔、主线剑阵、万灵图录、公告、挂机详情 |
| `level_*` | 11 | 失败/胜利界面返回与领奖、截教挑战、关卡门禁、八仙击杀、星座层数、镇妖塔推进 |
| `back_pack_*` / `magic_weapon_enhance` | 22 / 3 | 背包显示/整理/出售/丢弃/锁定/法宝选择与更换、宠物背包拾取、法宝强化 |
| `skill_*` | 18 | 被动升级、觉醒、键位、主动技能刷新与版本选择 |
| `ldl_*` | 15 | 强化、合成、锻造、神铸、淬骨、一键合成与面板重置 |
| `choose_player` / `forge` / `level_victory` / `level_auto_battle` / `auto_battle_retry` / `coop_panel_close` | 6 | 首批判读点、地图入口、2P 面板关闭 |
| `reward_interface` / `transmogrified_box` / `pet_backpack_drop` / `level_up` | 4 | 奖励入包、幻化箱、掉落后台失败兜底、升级 |
| `monster_unlock_pet_rabbit` / `change_clothes` / `pet_passive_upgrade` / `pet_changes` / `shop_cure_times` / `shop_mystery_purchase` / `task_claim_reward` | 7 | 收尾批次业务保存 |
| **合计** | **116** | 59 个文件 |

### 4.3 返回值处理

| 处理方式 | 处数 | 代表位置 |
|:---|:---:|:---|
| 判读 `request_save` 返回值 | 4 | `choose_player`、`forge`、`victory._save_completed_level`、`level_llbt`；`base_monster` 另有后台保存失败兜底 |
| 丢弃返回值 | 110 | 其余 UI/业务调用 |

结论：业务侧已无 `save_game` 直调，保存失败统一由 `request_save` 的 `push_warning` 暴露；多数 UI 仍不判读返回的 `bool`，用户可见失败提示留给 16-5。

### 4.4 保存前守卫与写放大

| 守卫写法 | 处数 |
|:---|:---:|
| 无局部守卫（直接调 `request_save`，路径由持久化边界解析） | 决定性多数 |
| `cd_path` 非空 / `contains("Ar_")` 业务守卫 | 少量（`map_3`、`zhu_xian_sword`、`body_training`、`level_esbxx`、`game_announcement` 等） |
| 后台保存前 `FileAccess.file_exists` 检查 | 0（`base_monster` 改由边界校验） |

- 11 个地图页在 `_ready` 中先写 `Map_num` 再保存；每次进入地图页都会产生一次完整档案序列化 + 加密写 + `MainGame.json` 写。
- `save_game` 自身在开头和 `safe_write_archive` 内各调用一次 `flush_pending_saves()`，即一次同步保存最多两次 flush 检查。
- `save_game` 成功后调用 `main_bc()` 回写元数据；`main_bc` 失败只告警，不回滚档案文件。

### 4.5 重置与多写路径

| 入口 | 行为 | 可达性 |
|:---|:---|:---|
| `MemoryClass.remove()` | `remove_data()` 清元数据 → `MainSet.xg = true` → `safe_write_archive(cd_path, initialized_data)` → **曾再调用 `save_game(cd_path)`** | 仅被 `PlayerData.removedata()` 调用；后者全仓无调用者（当前为死路径） |
| `MemoryClass.remove_play_data()` | `_player.clear()` + `merge(initialized_data)`，仅内存 | `main_menu._ready` 唯一调用 |
| `read_archive_interface._remove_save_data()` | 直接用 `initialized_data` 覆盖目标档，不经过 `_prepare_player_save_data` | 存档界面"删除/重置" |

`remove()` 的顺序是"写初始档 → 再保存当前数据"，第二次保存会把当前内存数据写回，覆盖刚写入的初始档，使"重置"退化为普通保存；当前为死路径，收尾批次处理。

### 4.6 `safe_write_archive` 与云存档

| 调用点 | 用途 | 数据来源 |
|:---|:---|:---|
| `read_archive_interface._prepare_cloud_upload_zip` | 首次上传时写入账号 `uid` 绑定 | `peek_archive_data` 读出的字典 |
| `read_archive_interface._import_cloud_save_zip` | 云导入写回本地档 | ZIP 解密后的字典 |
| `read_archive_interface._remove_save_data` | 删档重置为初始档 | `PlayerData.initialized_data` |
| `memory_class.save_game` | 同步保存 | `_prepare_player_save_data` 快照 |
| `memory_class.remove` | 异常档重置 | `initialized_data`（见 4.4） |

云存档使用独立密钥 `_cloud_archive_encryption_key()`（`zip 文件名 + 账号 + 用户 ID` 的 MD5），与本地 `keys`/`.save_key` 无关；导入后统一由 `safe_write_archive` 以本地密钥重写，因此不会把云密钥带进本地文件。

### 4.7 后台保存

| 项 | 事实 |
|:---|:---|
| 入口 | `request_background_save(path)`，仅 `base_monster.gd:1584` 调用 |
| 快照 | 与同步保存共用 `_prepare_player_save_data()`（含视图挂起/恢复与 2P profile 写入） |
| 队列 | `_pending_background_saves` 以 **path 为键**，同档重复请求覆盖为最新快照；任务携带 `generation`（`_archive_identity_epoch`）与快照，`_failed_background_saves` 保留失败快照 |
| 线程 | `_save_thread` 单线程，`_start_next_background_save()` 串行；同一时刻只有一个写任务 |
| 完成 | `_process` 轮询 `is_alive()`；`background_save_finished(path, success)` 信号**全仓无接收者**；完成时校验身份，切档后到达的旧任务直接丢弃（不写盘、不重试、不更新元数据） |
| flush | `flush_pending_saves()` 在 `save_game`、`safe_write_archive`、读档兼容读取、`_notification`（暂停/关窗）与 `_exit_tree` 调用；重入由 `_save_flush_in_progress` 拒绝 |
| 失败 | 失败任务进入 `_failed_background_saves`，下次 flush 重试；`_complete_background_save` 只 `push_error` |
| 缺口 | `background_save_finished` 仍无人消费；任务无保存序号，同档乱序覆盖由「单线程 + 同档覆盖」队列保证，尚未做跨队列排序 |

---

## 5. 档案身份 `Global.cd_path`

### 5.1 写点（唯一入口）

| 位置 | 写入值 | 场景 |
|:---|:---|:---|
| `bacis_ar_button._on_pressed` → `Global.set_cd_path("user://MyAr_<n>.json")` | 目标档案路径 | 点击存档卡片：先设路径再读档；`loaded` 才建立会话，缺档/空档进入创建模式，损坏/无效档提示并返回 |
| `main_menu._ready` → `Global.set_cd_path("")` | 空字符串 | 主菜单 `_ready`，同时 `remove_play_data()` 清空内存档 |
| `choose_player._on_return_main_menu_pressed` → `Global.set_cd_path("")` | 空字符串 | 选角界面"返回主菜单" |

`set_cd_path` 是唯一写入口：路径规范化（`strip_edges`）→ 不一致时 `MemoryClass.flush_pending_saves()` → 若存在会话则 `end_archive_session()` → 写入 `_cd_path` → `_archive_identity_epoch += 1` → `_advance_runtime_generation()`。返回值表示 flush 是否成功；身份切换本身始终生效。`_cd_path` 为私有字段，业务侧经 `get_archive_session_*` 查询。

### 5.2 读写点分类（13 行 / 5 个文件：私有字段 + 3 处路径写入 + 2 处边界比对）

| 用法 | 处数 | 说明 |
|:---|:---:|:---|
| `get_cd_path()` / `set_cd_path()` | 9 | 仅持久化边界与存档界面；业务侧 0 处 |
| 会话查询（`is_archive_session_active()` 等） | 24 | 地图页/训练/公告/剑阵/塔/万灵/星座/被动技能与关卡入口 |
| 空值 / `contains("Ar_")` / `find("Ar_")` | 0 | 16-3 全部删除 |
| `safe_write_archive` 参数 | 0 | `remove()` 改用 `get_archive_session_path()` |

### 5.3 身份纪元与过期回写

| 场景 | 行为 |
|:---|:---|
| 同步保存 | `save_game` 在快照前与快照后各校验一次「档案号 + epoch」；不一致返回 `stale_archive_identity`，不写盘 |
| 后台保存 | 任务记录入队 epoch；`_take_current_background_job()` 与 `_complete_background_save()` 校验，切档后到达的旧任务直接丢弃并 emit `background_save_finished(path, false)` |
| 切档/退档 | `Global.set_cd_path` 先 `flush_pending_saves()`，再递增 epoch 与运行时代次；旧档案的待写任务在身份仍有效时落盘 |
| 会话前置 | `request_save` / `request_background_save` 先要求 `is_archive_session_active()`；无会话返回 `no_archive_session`，不触碰磁盘 |
| 身份比对 | 路径按完整字符串比对（不再只比档案号），同号不同路径不会互相通过校验 |
| 失败原因 | `last_save_error` 取 `no_archive_session` / `invalid_archive_path` / `stale_archive_identity` / `normalize_failed:<键>` / `invalid_archive_data` / `write_failed`；`describe_save_error()` 返回中文可读文本 |

### 5.4 路径字符串进入业务逻辑的位置

| 位置 | 形态 | 风险 |
|:---|:---|:---|
| `MemoryClass.archive_number_from_path()` | 前缀 `user://MyAr_` + 后缀 `.json` + 正整数 | 唯一权威格式校验；不匹配返回 0 |
| `choose_player._archive_num()` | 调用上述解析函数 | 仅用于元数据时间回写；解析失败返回 0 并跳过 |
| `MemoryClass.get_cd_number()` | 返回会话档案号 `int`，无会话为 `0` | 消费者必须显式处理 0；不再回退到 1 号档 |
| `read_archive_interface._remove_save_data()` | `"user://MyAr_" + str(int(cd_number.text)) + ".json"` | 16-2B 已改为整数归一化后再拼接，非数字输入在入口被拒绝 |

---

## 6. 档案会话

### 6.1 字段与读写者

| 字段 | 声明 | 写点 | 读点 | 外部可见性 |
|:---|:---|:---|:---|:---|
| `_archive_session: ArchiveSession` | `global.gd` | `bind_archive_session`、`end_archive_session`、`set_cd_path`、`_exit_tree` | `Global` 内部预热/缓存释放；业务经查询方法 | 只读快照 |
| `_cd_path: String` | `global.gd` | 仅 `set_cd_path` | `Global` 内部与 `MemoryClass` 持久化边界 | 私有；业务禁用 |
| `_archive_session_generation: int` | `global.gd` | `bind`/`end`/`_exit_tree` | 预热协程与会话查询 | 经 `get_archive_session_generation()` |
| `_archive_session_prewarm_token` | `global.gd` | `begin`/`end`/`_exit_tree` | 取消中的旧协程认领校验 | 私有 |
| `_archive_identity_epoch: int` | `global.gd` | 仅 `set_cd_path` | 保存快照与后台任务 | 经 `get_archive_identity_epoch()` |
| `_runtime_generation: int` | `global.gd` | 场景切换、会话开始/结束、退出 | 异步资源写回 | 私有（Phase 15 已收口） |

`ArchiveSession`（`Script/memory_class/archive_session.gd`）字段只读：`generation`、`archive_number`、`role_id`、`archive_path`；`is_active()` 要求代次 > 0 且档案号 > 0 且路径非空。

### 6.2 触发点

| 事件 | 入口 | 说明 |
|:---|:---|:---|
| 读档成功 | `bacis_ar_button._on_pressed` → `await Global.begin_archive_session()` | `load_game` 返回 `loaded` 才建立；预热失败提示并停留 |
| 新建档完成 | `choose_player._on_qued_pressed` → `bind_archive_session()` → `request_save` → `await begin_archive_session()` | 先绑定会话才能保存；槽位无效或保存失败即返回 |
| 切换档案路径 | `Global.set_cd_path(path)` | 先 flush 待写任务，再 `end_archive_session()` 撤销旧会话，最后写路径并递增身份纪元 |
| 角色变化 | `bind_archive_session()` | 同一路径下 `Myself` 变化时重建会话（递增代次），保留档案号 |
| 退出档案 | `Global.change_scene` → `cleanup_transient_ui()` → `end_archive_session()` | 目标为 `main_menu.tscn` 或 `choose_player.tscn`；先让面板关闭保存走完再撤销会话 |
| 关卡入口 | `change_scene` / `add_level_info` / `_enter_level_without_info` | 无会话时拒绝并提示，不进入关卡 |
| 应用退出 | `Global._exit_tree` | 递增代次与预热令牌、清空会话对象，再释放缓存与池 |

`begin_archive_session(prewarm)` 内部先调用 `bind_archive_session()`，再按 `prewarm_token` + `_archive_session_generation` + `_runtime_generation` 三重校验预热结果；`prewarm=false` 只绑定会话，供无渲染入口与夹具使用。

### 6.3 未完成保存与切档/退出

| 路径 | 当前行为 |
|:---|:---|
| 切档（读另一档） | `Global.set_cd_path()` 先 `flush_pending_saves()`，再 `end_archive_session()` 撤销旧会话，最后写路径与 epoch；`load_game` 读档前的兼容读取也会 flush |
| 回主菜单 | `change_scene` 先 `cleanup_transient_ui()` 让面板关闭保存走完，再 `end_archive_session()`；主菜单 `_ready` 通过 `set_cd_path("")` flush 并切换身份。会话结束后的保存请求被拒绝（16-3），不再依赖 epoch 兜底 |
| 会话结束后的保存 | `request_save`/`request_background_save` 返回 `no_archive_session`，不写盘；面板已在会话结束前完成关闭保存 |
| 应用退出 | `MemoryClass._notification`（`WM_CLOSE_REQUEST`/`APPLICATION_PAUSED`）与 `_exit_tree` flush；`Global._exit_tree` 只管运行时缓存，不写档；退出时身份 epoch 未变，待写任务按原档案落盘 |
| 保存中退出 | `flush_pending_saves` 会等待线程完成；无超时、无失败上报给用户 |

---

## 7. `PlayerData.player_data` 直接写入按业务域

### 7.1 口径

| 指标 | 数值 |
|:---|:---:|
| 出现次数（含同一行多次） | 1,335 |
| 引用行数 | 1,288 |
| 引用文件数 | 119 |
| 直接赋值行（`=`，排除 `==`） | **129 行 / 39 个文件** |
| 复合赋值行（`+=`） | **12 行 / 7 个文件** |
| 删除（`player_data.erase`） | 1 行 / 1 文件 |
| 写入合计 | **141 行 / 44 个文件** |
| 比较行（`==`，不计入写入） | 27 行 |

> 上述写入均指向 `PlayerData.player_data` **当前绑定的字典**：2P 面板激活时该别名被换成 `LocalCoop.secondary_data.player_data`，同一行代码写入的是 2P 数据。因此这些计数不能理解为"只写 1P 档案"。

> 规划页早期口径 "156 行直接下标写入 / 40 个文件" 把 27 行 `==` 比较误计入赋值；本页以 141 行 / 44 文件为准（129 赋值 + 12 复合赋值 + 1 删除）。

### 7.2 域分布（按赋值键归类，129 行）

| 业务域 | 赋值行 | 文件数 | 主要文件 |
|:---|:---:|:---:|:---|
| 关卡进度/地图（`Map_num`、`HeavenMap_num`、区域通关键、塔层/积分） | 58 | 19 | `base_through_level` 11、`game_announcement` 9、`zhen_yao_tower` 7、`level_zhen_yao_tower` 5 |
| 宠物（`出战宠物`、`出战宠物_p2`） | 32 | 3 | `base_through_level` 18、`base_monster` 13、`eight_immortal_magic_weapon` 1 |
| 阵法/剑阵（`已佩戴阵法`、`主线剑阵出战`） | 9 | 4 | `zhu_xian_sword_page` 4、`zhen_fa_ui` 2、`base_hero` 2、`local_coop` 1 |
| 角色核心/货币（`Myself`、`FileValue`、等级、经验） | 6 | 4 | `dj_sell` 2、`game_announcement` 2、`bacis_ar_button`、`choose_player` |
| 背包/装备/法宝（`实战法宝`、槽位键、丹药计数键） | 6 | 5 | `base_hero` 2、`skill_select`、`bone_forge`、`game_announcement`、`basic_pellet` |
| 设置/外观开关（`翅膀显示`、`头衔显示`、`隐藏地图全开`） | 5 | 2 | `back_pack` 4、`game_announcement` 1 |
| 炼体/万灵（`炼体`、`万灵图录等级`） | 4 | 3 | `body_training_detail` 2、`body_training`、`game_announcement` |
| 技能/被动（`AWAKENED`、`AWAKENED_ENABLED`、技能数据键） | 4 | 2 | `skill_awaken_popup` 3、`zd_skill` 1 |
| 其他/杂项（`ieho`×2、`本地双人`） | 3 | 3 | `main_backpack`、`local_coop`、`player_data` |
| 商店（`TOWER_ACHIEVEMENT_PURCHASE_KEY`） | 1 | 1 | `zhen_yao_tower` |
| 任务（任务完成键） | 1 | 1 | `basic_task` |

### 7.3 跨域写入文件（6 个）

| 文件 | 涉及域 |
|:---|:---|
| `Script/main_menu/game_announcement.gd` | 关卡进度、背包、角色核心、炼体、设置、其他（GM 工具面，跨 6 域） |
| `Script/main_menu/zhen_yao_tower.gd` | 关卡进度、商店 |
| `Script/base/base_through_level.gd` | 关卡进度、宠物 |
| `Script/base/base_hero.gd` | 背包/装备、阵法/剑阵 |
| `Script/back_pack/dj_sell.gd` | 角色核心、其他 |
| `Script/coop/local_coop.gd` | 阵法/剑阵、其他（`本地双人`） |

### 7.4 迁移候选与不迁移理由

| 域 | 16-4/16-5 处置 | 理由 |
|:---|:---|:---|
| 宠物（32/3） | **优先迁移**到宠物域写入 API（单一出战设置入口） | `base_through_level` 与 `base_monster` 各自直接写同一键（前者经 `_active_pet_name_key()` 助手，仍解析为 `出战宠物`）；另有 `_p2` 后缀键，属于重复写入面 |
| 阵法/剑阵（9/4） | 迁移到共享账本入口 | 主线剑阵为共享项；面板、英雄同步、双人链接三处各自写 |
| 技能/被动（4/2） | 迁移到共享账本入口 | 被动技能为共享项，觉醒启停属于共享状态 |
| 炼体/万灵（4/3） | 保留直接写入，补共享账本查询 | 已有 `BODY_TRAINING_DATA.normalize_state` 与 `_merge_progression_dict` 归并；本阶段不重写 |
| 背包/装备/法宝（6/5） | 保留，改为槽位查询 | 共享容器由 `link_bags` 统一同步；`实战法宝` 属个体，需按槽位写 |
| 关卡进度（58/19） | **不迁移**（本阶段） | 分布在地图页与关卡脚本，改动面大于本阶段收益；只登记为后续域批次 |
| 设置/外观开关（5/2） | 不迁移 | 属于档案内的按角色显示偏好，不是 `MainSet` 全局设置；改名会改存档格式 |
| 其他/杂项（3/3） | 逐项评审 | `ieho`/`zyforever` 等为历史标记，清除需另立格式变更 |

### 7.5 重复写入与动态键

| 现象 | 事实 |
|:---|:---|
| 宠物出战重复写 | `base_through_level` 同时经 `_active_pet_name_key()` 与字面 `"出战宠物"` 写同一键（各 9 次，共 18 行）；`base_monster` 只写 `"出战宠物"`（13 行） |
| 击杀计数动态键 | `my_mr_name` 作为键 `+= 1`，12 行 / 7 个文件（`base_monster` 5、`monster_32` 2、其余各 1） |
| 地图页页码 | 12 个 `Map_num` 写入，其中 11 个在 `_ready`、1 个在镇妖塔选层回调，值来自页面常量 |
| 塔状态四键 | `TOWER_POINTS_KEY`/`TOWER_RUN_POINTS_KEY`/`TOWER_CURRENT_FLOOR_KEY`/`TOWER_MAX_FLOOR_KEY` 在 `zhen_yao_tower` 与 `level_zhen_yao_tower` 两侧各写一遍 |
| 昵称键 | `角色昵称` 只由 `coop_backpack` 经 `data_for_slot` 写入（槽位感知的正例） |

---

## 8. 规范化补全边界

### 8.1 入口清单（21 个）

| 类别 | 函数 | 返回 | 读档调用 | 保存调用 |
|:---|:---|:---|:---:|:---:|
| 灵魂 | `normalize_soul` | `int` | 是 | 是 |
| 背包/装备 | `ensure_acquired_equipment_data` | `void` | 是 | 是 |
| 背包/装备 | `ensure_shengu_slot` | `Array` | 是 | 否 |
| 背包/装备 | `ensure_avatar_frame_slot` | `Array` | 否 | 否（3 处 UI 调用） |
| 消耗品 | `migrate_consumables_from_dj_to_xhp` | `void` | 是 | 是 |
| 技能 | `ensure_player_passive_skills` | `void` | 是 | 是 |
| 技能 | `ensure_skill_data` | `void` | 否 | 否（`role_5.gd` 1 处调用） |
| 法宝 | `_remove_retired_wudu_magic_weapons` | `void` | 是 | 是 |
| 副本进度 | `ensure_special_dungeon_progress` | `void` | 是（`has_method`） | 是（`has_method`） |
| 剑阵 | `ensure_main_sword_array` | `void` | 否 | 是（`has_method`） |
| 万灵 | `ensure_wanling_catalog_data` | `Dictionary` | 否 | 是（`has_method`） |
| 坐骑 | `ensure_mount_data` | `Array` | 是（`has_method`） | 是（`has_method`） |
| 等级 | `enforce_level_caps` | `void` | 是 | 是 |
| 宠物 | `ensure_pet_tiger` / `dragon` / `turtle` / `rabbit` / `phoenix` | `bool` | 是 | 是 |
| 宠物 | `ensure_pet_neat` / `yin_tiger` | `bool` | 是（`has_method`） | 是（`has_method`） |
| 宠物 | `ensure_pet_mouse` | `bool` | **否** | **否**（`global.gd`、`base_through_level` 各 1 处；另在 `PlayerData._ready` 启动补全中调用） |
| 宠物 | `ensure_shared_pet_backpack` | `Array` | 是（`has_method`） | 是（`has_method`） |

### 8.2 启动期补全

`PlayerData._ready()`（Autoload 启动）对默认档案执行 20 次补全/清理调用：`ensure_avatar_frame_slot`、`ensure_shengu_slot`、`ensure_player_passive_skills`、`ensure_skill_data`、`ensure_special_dungeon_progress`、`_remove_retired_wudu_magic_weapons`、`_remove_retired_classic_and_merchant_equipment`、`ensure_main_sword_array`、`ensure_wanling_catalog_data`、`ensure_mount_data`、五种宠物 `ensure_pet_*`（含 mouse）、`ensure_pet_neat`、`ensure_pet_yin_tiger`、`ensure_shared_pet_backpack`、`enforce_level_caps`。`normalize_soul` 与 `migrate_consumables_from_dj_to_xhp` 不在启动清单内，只在读档/保存或 `_process` 触发。

因此"补全"实际有三个执行面：进程启动（默认档）、读档（合并后）、保存（快照前）；三份清单互不相同。

### 8.3 两侧清单不对称

- 读档独有：`ensure_shengu_slot`；
- 保存独有：`ensure_main_sword_array`、`ensure_wanling_catalog_data`；
- 读档与保存都不调用：`ensure_avatar_frame_slot`、`ensure_skill_data`、`ensure_pet_mouse`（仅启动补全/其他模块调用）；
- `load_game` 在合并后调用 `LocalCoop.load_profile()`，而 `load_profile` 自身又调用 `ensure_main_sword_array`/`ensure_player_passive_skills`，形成一次重复补全；
- 保存侧自 16-2D 起使用**固定 19 步清单**（`_normalization_steps()`），`enforce_level_caps` 最后执行；读档侧在 16-3 改为「先 `remove_play_data()` 重置内存档再合并」，不再依赖主菜单兜底。

### 8.4 失败可见性

| 问题 | 事实（16-2D 后） |
|:---|:---|
| 返回值语义 | `ensure_pet_*` 返回"是否新增"，不是"是否成功"；因此保存侧不依赖返回值，改用后置条件判定 |
| 静默跳过 | `_run_normalization_step()` 在方法缺失时记录 `normalize_failed:<步骤>` 并阻止保存，`has_method` 守卫不再静默通过 |
| 补全失败当成功 | `_normalization_postcondition_error()` 校验容器、宠物（含等级不超玩家）、宠物背包、坐骑、被动技能全键、剑阵等级、万灵图录、已获取装备与玩家等级；任一不满足即拒绝写入，并设置 `last_save_error=normalize_failed:<键>` |
| 幂等性 | 已修复两处非幂等：新建宠物只做 `_normalize_pet_passives` 而未执行自身规范化，导致第二次保存才补齐 `名字`/资质上限；`enforce_level_caps` 原先在 `ensure_pet_*` 之前执行，导致新建宠物首次保存未被钳制。现改为创建即规范化 + 等级钳制最后执行，夹具 `normalize_idempotent` 逐键比对两次快照 |
| 异常中断 | 补全步骤抛错会中断 `_prepare_primary_player_save_data` 并返回 `{}`，`save_game` 返回 `false`；`last_save_error`/`describe_save_error()` 可用于 UI |

---

## 9. 玩家槽位调用面

### 9.1 `LocalCoop` API 生产调用（不含本类内部）

| API | 外部调用 | 文件 | 说明 |
|:---|:---:|:---:|:---|
| `slot_for(node)` | 20 | 7 | 战斗伤害归属、背包/技能/宠物/法宝按钮、宠物单位、坐骑按键 |
| `data_for(node)` | 19 | 19 | 主要被 `BaseObject.PlayerData` getter 与各类特效/弹体使用 |
| `data_for_slot(slot)` | 5 | 3 | `base_monster`、`base_through_level`、`coop_backpack` |
| `props_for(node)` | 22 | 20 | `BaseObject.RoleProp`/`BaseRoleProperties.RoleProp` 与战斗基类 |
| `props_for_slot(slot)` | 1 | 1 | `BaseRoleProperties.RoleProp` getter |
| `canonical_profile_for_slot(slot)` | 3 | 2 | `BaseRoleProperties._shared_attribute_data`、`monster_130` 双槽奖励 |
| `pet_profile_for(pet)` | 16 | 1 | 全部在 `base_through_level` 的宠物生成/进化规范化 |
| `pet_meta_key(key, slot)` | 32 | 5 | 关卡层宠物单位 meta 键 |
| `input_for(node)` | 2 | 2 | `BaseObject.PlayerInput` 与角色输入绑定 |
| `is_enabled()` | 36 | 15 | 双人开关判断 |
| `increment_pellet_count` | 1 | 1 | 丹药计数 |
| `living_players` / `all_players_dead` | 8 / 4 文件；2 / 1 文件 | — | 战斗目标与失败判定 |

### 9.2 已槽位感知与仍假定 1P

| 类别 | 文件数 | `PlayerData.player_data` 引用 | 说明 |
|:---|:---:|:---:|:---|
| 有槽位/`coop_slot` 感知的面板目录脚本 | 3（含 `local_coop` 自身） | 19 | `local_coop.gd`（17）、`main_sword_array_weapon.gd`（1）、`pet_interface.gd`（1） |
| 无任何槽位感知的面板目录脚本 | **20** | **354** | `back_pack.gd` 81、`sell_or_equ.gd` 59、`transmogrified.gd` 46、`box_1.gd` 36、`wq.gd` 36、`magic_weapon_infor.gd` 24 等 |

`Global.get_player` 仍有 **19 次 / 10 个文件**引用（`dj_sell` 5、`local_coop` 4、`weiyang_palace_boss` 3、其余各 1），其中 `dj_sell` 的 Buff/回血逻辑直接使用"当前全局玩家"。

结论：槽位 API 已存在且被战斗侧使用，但**面板侧整体依赖"把 2P 数据临时换进 `PlayerData` 全局别名"**，这是 16-5 的主要迁移面。

---

## 10. 面板视图交换与保存互斥

### 10.1 全部调用点

| 位置 | 调用 | 触发场景 |
|:---|:---|:---|
| `local_coop.gd:317`（`clear_runtime`） | `suspend_player_view()` | 释放 2P 运行时前恢复 1P 视图 |
| `local_coop.gd:583`（`_activate_slot_view`，slot==2） | `resume_player_view()` | 打开 2P 面板 |
| `local_coop.gd:585`（`_activate_slot_view`，slot==1） | `suspend_player_view()` | 打开 1P 面板 |
| `local_coop.gd:676`（`_replace_panel`） | `suspend_player_view()` | 面板内切槽前恢复 1P |
| `local_coop.gd:680`（`_replace_panel`） | `resume_player_view()` | 切到 2P 后换入 2P 视图 |
| `local_coop.gd:691`（`_on_panel_closed`） | `suspend_player_view()` | 关闭面板恢复 1P |
| `memory_class.gd:267`（`_prepare_player_save_data`） | `suspend_player_view()` | 保存快照前恢复 1P 视图 |
| `memory_class.gd:273`（`_prepare_player_save_data`） | `resume_player_view()` | 快照后恢复原视图（仅当此前发生交换） |
| 定义 | `local_coop.gd:705` / `:719` | — |

### 10.2 面板生命周期时序

```text
open_panel(slot, type)
  -> ui_slot = slot
  -> _activate_slot_view(slot) : slot==2 时 resume_player_view()
  -> 加载面板场景，set_meta("coop_slot", slot)，注册 UI 运行时实例
_switch_panel(slot) -> _replace_panel(slot)
  -> 释放旧面板 -> suspend -> link_bags -> ui_slot = slot -> slot==2 时 resume -> 重建面板
close_panel() -> queue_free -> _on_panel_closed
  -> 释放层、恢复 Global.windows -> suspend -> link_bags -> refresh_passive_skills
  -> 恢复暂停态 -> MemoryClass.request_save("coop_panel_close")（路径失效时在 flush 前返回）
```

### 10.3 互斥现状

| 断言 | 当前事实 |
|:---|:---|
| 保存快照期间不处于 2P 视图 | 成立：`_prepare_player_save_data` 先 suspend，再取快照 |
| 快照生成期间禁止面板切换 | **无显式锁**；仅因快照全程同步（无 `await`）才未被插入 |
| 面板关闭即保存 | 成立，但前提是 `cd_path != ""` |
| 场景切换时面板关闭顺序 | `change_scene` 先 `end_archive_session()` 再 `cleanup_transient_ui()`；面板 `_on_panel_closed` 的保存落在会话结束之后 |
| 异常退出恢复视图 | `clear_runtime` 会 suspend；面板随场景释放时由 `tree_exited` → `_on_panel_closed` 触发（`LocalCoop` 为 Autoload，`is_inside_tree()` 恒为真）。2P 面板登记在 `_ui_runtime_instances`，不在 `cleanup_transient_ui` 的临时 UI 注册表 |
| 快照失败 | `_prepare_primary_player_save_data` 返回 `{}` 时跳过 `save_profile`/`link_bags`，但仍恢复视图；本次不写入 2P profile |

---

## 11. 失败边界与风险登记

> 编号供 16-2~16-6 引用；已实施项在行内标注，未标注项仍为当前事实。

| 编号 | 事实 | 影响 | 交接 |
|:---|:---|:---|:---|
| AS-01 | **已修复（16-3）**：`load_game` 返回 `{ok, status, archive_number, message}`；`status` 区分 `loaded`/`missing`/`empty`/`unreadable`/`invalid`/`invalid_path`，无档与空档不再返回成功 | 调用方可直接判读状态并给出文案 | 16-3 完成 |
| AS-02 | **已修复（16-3）**：`load_game` 在合并前调用 `remove_play_data()` 重置内存档，同进程连续读两档不再残留上一档键 | 读档结果与进程历史无关 | 16-3 完成 |
| AS-03 | **已修复（16-3）**：`bacis_ar_button` 按 `load_game` 的 `status` 分支；非空但不可读/无效时提示并返回，缺档/空档才进入创建模式；会话仅在读档成功且预热完成后建立 | 不可读档不再残留可保存身份 | 16-3 完成 |
| AS-04 | **已修复（16-2C）**：本地 `_is_valid_player_archive_data` 现校验 `Myself` 1..7；非空非法档在 `load_game` 合并前被拒绝 | 越界文件不再被当作可玩档案读取 | 16-2C 完成 |
| AS-05 | **已修复（16-2C）**：云收集/导入与本地校验共用 `MemoryClass.is_valid_role_id`（1..7） | 玉兔档可上传/导入；0/8/非数值拒绝 | 16-2C 完成 |
| AS-06 | **已修复入口（16-2A 完成）**：业务侧无 `save_game` 直调；4 处判读 `request_save`，其余 112 处丢弃 | UI 失败仍无提示，属 16-5 面板反馈范围 | 16-2A 完成 |
| AS-07 | **已修复入口（16-2A 完成）**：116 处全部由 `request_save` 统一解析与空档拒绝；残留 `cd_path` 守卫仅作业务前置判断 | 无档时静默 `false`；UI 无反馈 | 16-2A 完成 |
| AS-08 | 11 个地图页 `_ready` 即保存 | 每次进城一次完整加密写 + 设置写；首帧 IO 放大 | 16-2 |
| AS-09 | **已修复（16-2A 收尾）**：删除 `remove()` 末尾覆盖初始档的 `save_game`，重置只写初始档；入口仍为死路径 | 重置不再退化为普通保存 | 16-2A 完成 |
| AS-10 | 面板内保存依赖同步 suspend/resume | 若 `_prepare_player_save_data` 将来引入 `await`，2P 面板视图会停留在 1P；16-2B 已在其后校验身份 epoch，可拦截跨档写入 | 16-5 |
| AS-11 | **已解除（16-2B）**：保存身份改用 `_archive_identity_epoch`（仅路径变化时递增），退出场景 `end_archive_session()` 不再使面板关闭保存失效 | 面板关闭仍可写入同一档案 | 16-2B 完成 |
| AS-12 | **已修复（16-2B）**：`_remove_save_data` 先 `int(cd_number.text)` 归一化再拼路径，入口已校验正整数范围 | 不会命中非预期路径 | 16-2B 完成 |
| AS-13 | **已修复（16-2D 保存侧 / 16-3 读档侧）**：19 步补全改为固定清单，方法缺失即失败；补全后执行后置条件校验，失败拒绝写入并给出 `normalize_failed:<键>`；读档改为先重置再合并 | 保存与读档都不再把补全失败当成功 | 16-3 完成 |
| AS-14 | **部分修复（16-2B）**：任务增加 `generation`（身份 epoch），切档后到达的任务被丢弃；切档前 `set_cd_path` 先 flush。信号仍无接收者 | 旧任务不再回写；失败仍靠日志与 `last_save_error` | 16-2B 完成；信号消费留给 16-5 |
| AS-15 | **已修复（16-3）**：`ArchiveSession` 提供档案号/角色/路径/代次；业务侧 0 处引用 `cd_path`，保存与关卡入口统一读会话 | 会话是唯一权威表示 | 16-3 完成 |
| AS-16 | 20 个面板脚本 354 处直接读 `PlayerData`，无槽位感知 | 2P 面板必须依赖全局视图交换 | 16-5 |
| AS-17 | `Global.get_player` 19 次 / 10 文件，语义混合 | 部分战斗/回血逻辑默认 1P | 16-4 |
| AS-18 | **已修复（16-3）**：`get_cd_number()` 返回 `int`，无会话时为 `0`；`base_hero`/`back_pack` 对 0 显式处理，`remove_main_data` 拒绝非正档号 | 无档操作不再落到 1 号档 | 16-3 完成 |

---

## 12. 与后续批次的交接

| 批次 | 本页提供的输入 |
|:---|:---|
| 16-2 存档 IO 边界 | 116 处 `request_save`、业务 `save_game` 归零（附录 A）、返回值处理分布、`safe_write_archive` 3 处外部调用、后台队列事实、元数据 `main_bc` 74 处；AS-04/AS-05 已修复，AS-06/AS-07 部分修复，AS-08/AS-09/AS-12~AS-14 待办 |
| 16-3 会话上下文 | **已完成**：`ArchiveSession` 会话对象、`bind_archive_session`/`begin_archive_session(prewarm)`/`end_archive_session`、`load_game` 显式状态、无会话拒绝保存与关卡入口；AS-01/02/03/13/15/18 关闭 |
| 16-4 槽位与共享账本 | 槽位 API 调用表、20 个未槽位感知面板、`Global.get_player` 19 处、域分布与迁移候选、AS-16/AS-17 |
| 16-5 面板与快照 | 8 处视图交换调用、面板生命周期时序、互斥缺口、AS-10/AS-11/AS-16 |
| 16-6 边界守卫 | 可直接转成规则的静态特征：`contains("Ar_")`、`user://MyAr_` 拼接、`save_game`/`safe_write_archive` 调用方白名单、`suspend/resume_player_view` 调用点、`PlayerData.player_data[` 写入点登记 |

---

## 13. 取证与复现

本轮只读调查使用以下等价命令（PowerShell/Git Bash 均可）：

```bash
# 保存点
grep -rn "MemoryClass.save_game(" source --include='*.gd'
# 路径身份
grep -rn "Global.cd_path" source --include='*.gd'
# 直接写入（排除比较）
grep -rnE 'PlayerData\.player_data\[[^]]*\]\s*(=|\+=)(?!=)' source --include='*.gd'
# 会话
grep -rn "archive_session" source --include='*.gd'
# 槽位与视图交换
grep -rnE "LocalCoop\.(slot_for|data_for|data_for_slot|props_for|props_for_slot|canonical_profile_for_slot|pet_profile_for|pet_meta_key|input_for)\(" source --include='*.gd'
grep -rn "suspend_player_view\|resume_player_view" source --include='*.gd'
```

统计脚本以"物理行计数"为准；同一行多次出现只计一次（除特别注明"出现次数"的 `cd_path` 与 `player_data` 总量）。临时统计文件未入库。

---

## 14. Phase 16-1 出口核对

- [x] `save_game`、`request_background_save`、`safe_write_archive`、`load_game`、`main_dq`、`main_bc` 的全部调用点、调用场景与返回值处理已登记；
- [x] `Global.cd_path` 的 3 个写点与 132 次读取出现（129 行）已分类，路径字符串进入业务逻辑的位置已列出；
- [x] `PlayerData.player_data` 直接写入按 11 个业务域分类，跨域文件与重复写入已标出，迁移候选与不迁移理由已给出；
- [x] 21 个 `ensure_*`/`normalize_*`/`migrate_*`/`enforce_*` 入口的读档/保存调用与失败可见性已记录；
- [x] 档案会话字段、`begin_archive_session`/`end_archive_session` 触发点、切档/退出未完成保存已记录；
- [x] `LocalCoop` 槽位 API 的生产调用方已区分"已槽位感知"与"仍假定 1P"；
- [x] `suspend_player_view`/`resume_player_view` 的 8 处调用、面板打开/关闭/切换/暂停/退出路径与保存快照互斥关系已记录；
- [x] 静态定义、档案传输格式与实例状态已分开；
- [x] 仅文档与只读报告，未修改生产代码；结果进入本页与 [`status.md`](status.md)。

**下一入口**：Phase 16-1 完成；16-2 存档 IO 边界与保存顺序见 [`current-iteration.md`](../roadmap/current-iteration.md)。

---

## 15. 16-2A 实施记录（2026-10-29）

| 项 | 结果 |
|:---|:---|
| 第二批范围 | `Script/back_pack` 25、`Script/skill` 18、`Script/ldl` 15，共 58 处；均为 1:1 替换为带 reason 的 `request_save`，未改动业务分支与写盘顺序 |
| 第二批验证 | 每段后运行档案夹具；back_pack 段另跑 `LocalCoopPanelProbe`，skill 段跑 `LocalCoopSkillKeysProbe`，ldl 段跑 `LocalCoopPanelProbe`；最终全量 `coop_probe_runner` **16/16 PASS** |
| 统一入口 | `MemoryClass.request_save(reason: String = "") -> bool`：`strip_edges` 后解析 `Global.cd_path`；路径非法时在 flush 前返回 `false`；合法时委托 `save_game`；失败输出 reason 告警 |
| 首批迁移 | 17 处：5 处判读点（`choose_player`、`forge`、`base_through_level`、`victory`、`level_llbt`）、11 个地图页 `_ready`、`LocalCoop._on_panel_closed`；`save_game` 余 101 处 |
| 第二批迁移 | 58 处：`Script/back_pack` 25、`Script/skill` 18、`Script/ldl` 15；全部改为带 reason 的 `request_save`；`save_game` 余 43 处 / 35 文件 / 41 函数 |
| 第三批迁移 | 19 处：`Script/main_menu` 全部保存点（地图页按钮 11、主城 1、特殊按钮 1、真妖塔 2、主线剑阵 1、万灵图录 1、公告 1、挂机详情 1）；`save_game` 余 24 处 / 18 文件 / 22 函数 |
| 第三批验证 | `level_selection` 场景探针 **PASS**（15.43~16.50s）；档案夹具新增 18 个主菜单真实处理器用例，总计 **52/52 PASS**；`LocalCoopCreationUIProbe`/`LocalCoopPanelProbe` **PASS**；全量 `coop_probe_runner` **16/16 PASS**；`level_1` 冒烟 **PASS**（0 ERROR / 0 WARNING） |
| `tower_floor_select` 验证 | 该处理器调用 `Global.change_scene` 切换关卡，无法在单场景夹具中安全执行；改用一次性场景脚本在真实 `current_scene` 下验证：`镇妖塔当前层数=1` 写入且加密档案 `存档时间` 刷新。临时脚本已删除 |
| 角色范围 | 新增 `MemoryClass.is_valid_role_id`（1..7，接受 int/float）；本地校验、云收集、云导入共用 |
| 读档拒绝 | 非空档案在合入 `player_data` 前执行 `_is_valid_player_archive_data`；结构或角色非法返回 `false` |
| 退出泄漏修复 | `AE`（`all_equipment.gd`）懒加载的 `_data` 在 `_exit_tree` 释放；此前每次退出泄漏 1 个 Node |
| 定向夹具 | 新增 `scripts/archive_probe_runner.py` + `scripts/archive_probes/archive_persistence_probe.gd`；隔离临时 `user://`，覆盖缺失/空/损坏档、`.bak` 恢复、`.tmp` 清理、角色 1/7/0/8、`request_save` 空档/成功/拒绝、空档不覆盖原档 |
| 首批夹具结果 | **27/27 PASS**；`level_1` 冒烟 **PASS**（23.05s，0 ERROR / 0 WARNING）；`LocalCoopPanelProbe` **PASS**；`check_all --skip-engine` **8/8 PASS**；`health_check` **0 Parse / 0 Error / 0 Warning** |
| 第二批夹具结果 | **34/34 PASS**：新增 `panel_backpack_wings_saved`、`panel_backpack_head_saved`、`panel_skill_key_saved`、`panel_strength_saved`、`panel_ldl_saved`、`panel_synthesis_saved` 与 `panel_seed_saved`，直接调用面板处理器并回读加密档案 |
| 第三批夹具结果 | **52/52 PASS**：新增 18 个主菜单用例（`map_0`、`map_1`~`map_9_1`、`map_3_special`、`tower_data`、`zhu_xian_sword`、`wan_ling_catalog`、`game_announcement`、`body_training`），实例化真实场景并调用保存处理器后回读加密档案 |
| 第四批迁移 | 11 处：`defeat` 4、`hdzm` 1、`level_17` 1、`level_bxgh` 1、`level_esbxx` 1、`level_zhen_yao_tower` 1、`victory` 2；`save_game` 余 13 处 / 11 文件 / 13 函数 |
| 收尾批次迁移 | 13 处：`reward_interface`、`transmogtified_box`、`base_monster`（后台失败兜底）、`base_role_properies`、`monster_130`、`c_hange_clothes_jm`、`pet_interface` 2、`cure_times_box`、`mystery_shop_item_box`、`basic_task`；`MemoryClass.remove()` 的覆盖式 `save_game` 直接删除 |
| 收尾重复保存处理 | `reward_interface` 的 `_process` 与 `add_item_to_backpack` 各保存一次，合并为 `_process` 单次；夹具 `batch_reward_item_granted_once` 断言纹章只入包 1 个 |
| 收尾验证 | 档案夹具 **56/56 PASS**（新增奖励入包单次发放、升级落盘）；`level_1` 冒烟 **PASS**；`coop_probe_runner` **16/16 PASS**；`check_all --skip-engine` **8/8 PASS**；`health_check` **0 Parse / 0 Error / 0 Warning** |
| 16-2B 身份与顺序 | 新增 `Global.set_cd_path()` 唯一写入口（3 处直接赋值迁移）与 `_archive_identity_epoch`；`save_game` 快照前后校验「档案号 + epoch」，失败返回 `stale_archive_identity`；后台任务携带 epoch，切档后旧任务丢弃；`set_cd_path` 切换前 flush；存档界面删档路径整数归一化 |
| 16-2B 失败可见性 | `MemoryClass.last_save_error` + `describe_save_error()`；`choose_player` 与 `forge` 展示具体失败原因 |
| 16-2D 补全边界 | 保存侧 19 步固定补全清单；`_normalization_postcondition_error()` 校验容器/宠物/背包/坐骑/被动/剑阵/万灵/已获取装备/等级；方法缺失或后置条件不满足即阻止写入。修复两处非幂等：新建宠物立即执行自身规范化；`enforce_level_caps` 移至补全最后 |
| 16-3 会话上下文 | 新增 `ArchiveSession` 只读值对象与 `bind_archive_session()`；`cd_path` 私有化，业务 0 引用；`load_game` 返回显式 `status`；无会话拒绝保存与关卡入口；`get_cd_number()` 返回 `int` |
| 16-3 验证 | 档案夹具 **101/101 PASS**（新增 `session_*` 20 项）；`level_1` 冒烟 **PASS**；`scene_probe_runner` **6/6 PASS**；`coop_probe_runner` **16/16 PASS**；`check_all --skip-engine` **8/8 PASS**；`health_check` **0 Parse / 0 Error / 0 Warning** |
| 16-2B/2D 验证 | 档案夹具 **71/71 PASS**（新增 `identity_*` 9 项、`normalize_*` 6 项）；`level_selection` **PASS**；`level_1` 冒烟 **PASS**（0 ERROR / 0 WARNING）；`coop_probe_runner` **16/16 PASS**；`check_all --skip-engine` **8/8 PASS**；`health_check` **0 Parse / 0 Error / 0 Warning** |
| `defeat` / `victory` 双写评估 | 两个调用点**互斥**：镇妖塔分支 `change_scene` 后保存并 `return`，末尾保存只在地图分支执行。每次点击只写一次，无需去重；原"同函数重复保存"描述已更正 |
| 第四批验证 | `level_1` 冒烟 **PASS**（0 ERROR / 0 WARNING）；档案夹具 **52/52 PASS**；`check_all --skip-engine` **8/8 PASS**；`health_check` **0 Parse / 0 Error / 0 Warning** |

**未完成**：16-4 玩家槽位与共享账本、16-5 面板显式操作者与保存快照互斥、16-6 边界守卫。16-2A~16-3 已收口：业务侧 `save_game` 调用为 0，`cd_path` 无业务引用。

---

## 附录 A：业务 `save_game` 调用点全表（16-2A 收尾后）

业务侧 `MemoryClass.save_game(...)` 调用为 **0**。全仓仅保留 `source/Script/memory_class/memory_class.gd` 中 `request_save` 内部的 1 处委托：

| 位置 | 说明 |
|:---|:---|
| `memory_class.request_save` | `if save_game(archive_path):` —— 持久化边界内部委托，非业务调用 |

历史迁移批次：

| 批次 | 范围 | 处数 |
|:---|:---|:---:|
| 首批 | 5 处判读点 + 11 个地图页 `_ready` + `LocalCoop._on_panel_closed` | 17 |
| 第二批 | `Script/back_pack` / `Script/skill` / `Script/ldl` | 58 |
| 第三批 | `Script/main_menu` | 19 |
| 第四批 | `Script/level` | 11 |
| 收尾批次 | `Scene/other_scene` 3、`base` 2、`pet` 2、`shop` 2、`monster`/`other_menu`/`task` 各 1、`memory_class.remove` 删除双写 | 13 |
| **合计** | 业务调用全部改为 `request_save` | **118** |

`request_save` 共 **116** 处 / 59 个文件。118 → 116 的差额来自收尾批次的两处合并/删除：`reward_interface` 原 `_process` 与 `add_item_to_backpack` 各保存一次，合并为 1 次；`MemoryClass.remove()` 末尾会覆盖初始档的 `save_game` 被删除，未替换为 `request_save`。
