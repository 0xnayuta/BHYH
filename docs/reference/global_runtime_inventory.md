# Global 状态与入口清单

> **状态**：Phase 22 已收口（2026-11-02，22-1/22-2/22-3A/22-3B/22-3C/22-3D-1/22-3D-2/22-3E/22-4 完成）。当前规模为 **65 个字段、260 个公开函数**；删除与迁移清单见 §6，剩余字段所有者见 §2.10。
>
> **定位**：记录 `source/global.gd` 当前状态字段、公开入口、26 个普通子服务与迁移判定，作为 Phase 23 及后续阶段的基线。
>
> **事实源**：当前工作区的 `source/global.gd`、`source/project.godot` 与源码引用统计。数量是带日期的基线快照，不是长期 SLA；每个迁移批次开始前重新统计。
>
> **边界**：本文不是“Global 已完成拆分”的声明，也不授权删除仍有动态或字符串引用的入口。P0 只建立清单；行为变更必须进入对应批次并完成验收。

---

## 1. 盘点口径

| 指标 | 2026-11-02 基线 |
|:---|:---|
| `global.gd` 行数 | 3,087（22-1 基线 3,516；22-2/22-3A/22-3B/22-3C/22-3D-1/22-3D-2 共删除 429 行） |
| `var` 字段 | 65（22-1 基线 141；22-2 删除 10，22-3A 迁出 5，22-3B 删除 19，22-3C 迁移 11 + 删除 5，22-3D-1 迁出 5，22-3D-2 迁出/删除 21） |
| 公开函数（非 `_` 前缀） | 260（22-1 基线 273；22-2 删除 12，22-3D-1 删除 `check_combo_milestone`） |
| 其中 `add` 系工厂/门面 | 120（113 个带 `add_` 前缀，7 个历史无下划线命名） |
| `Global._ready()` 创建的普通子服务 | 26 |
| 仓库内 `Global.` 引用（含注释/字符串） | 约 3.1k 处，分布于 432 个脚本 |
| 字符串形式的 `/root/...` | 约 24 处；含注释、启动期单例回退与 `TouchControls` 查询，不能直接等价为 24 个业务违规 |

统计命令：

```bash
grep -nE '^(var|func) ' source/global.gd
grep -RIn '\bGlobal\.' source --include='*.gd' | wc -l
grep -RIn '"/root/' source --include='*.gd'
```

统计含注释与字符串，不能代替调用图。P0 的职责是建立可审计清单，最终删除仍需逐项引用确认。

---

## 2. 状态字段清单

字段为在 `source/global.gd` 中静态声明的 `var`；类型、默认值与写入口以源码为准。

### 2.1 云存档与账号（已迁出）

登录会话已迁入 `MemoryClass` 持有的 `CloudSession`（`RefCounted`），不新增 Autoload；`Global` 不再保留 `cloud_save_*` 或云认证冷却字段。

### 2.2 功能开关（1）

`_hidden_feature_flags`

**判定**：保留只读能力，或迁往 `MainSet`/配置边界。新增开关不得继续以裸全局字段扩张。

### 2.3 HUD、战斗表现与共享引用（15）

`all_buff_list`, `buff_list`, `choose_list`, `choose_ms`, `buff_box`, `mg_cd_pic`, `zhen_fa`, `lhhj_boss_list`, `bullet`, `damage_text`, `monster_be_hit`, `special_affect`, `role_bullet`, `fly_bullet`, `_chase_bullet`

**判定**：表现/HUD 状态候选。节点引用优先归 `UiRuntime`、`CombatPresentationFactory`、`ProjectileFactory` 或对应场景；共享定义若确为只读，改由 Resource/Catalog 或显式服务持有。`weapon_bullet_node` 已在 22-2 删除。

### 2.4 法宝实例槽位（已迁出）

19 个旧字段均已删除；`MagicWeaponRuntime` 是双槽位与法宝场景路径表的唯一所有者，负责创建、替换、预载与清理，`Global` 只保留稳定转发入口。

### 2.5 表现与一次性 UI 遗留（已迁出）

`is_frist`、`is_show` 已迁入 `UiRuntime` 的一次性消费状态；`box_count` 已迁入 `BackpackFactory` 的点击冷却；`_last_combo_value` 与 `_pending_combo_milestones` 已迁入 `CombatPoolRuntime` 的连击里程碑状态。`Global` 不再保留四类字段。

### 2.6 锻造、背包与瞬时面板状态（已迁出）

- `file_num` -> `MainSet.FILE_VALUE` 常量；
- `forge` -> `ForgeFactory` 活动面板；
- `is_in_ldl` -> `UiRuntime` Ldl 模式；
- `lj_times`、`lj_count` -> `CombatPoolRuntime` 连击计数与空闲窗口；
- `need_change_item` -> `ForgeFactory` 分解脏标记；
- `player_dir` -> `RunContext` 玩家朝向；
- `get_target`、`wait_time` 无消费者，删除；`fb_cd` 只写 -10/0 且恒为可用，删除。

### 2.7 档案、保存与运行代次（22）

`_prewarmed_role_id`, `_archive_session`, `_run_context`, `_archive_session_prewarm_in_progress`, `_archive_session_prewarm_role_id`, `_archive_session_prewarm_token`, `_archive_session_generation`, `_archive_identity_epoch`, `_cd_path`, `_background_save_last_serial`, `_background_save_last_success`, `_background_save_last_path`, `_background_save_failure_count`, `_save_failure_count`, `_save_failure_last`, `_save_failure_feedback_enabled`, `_suppress_save_failure_feedback`, `_save_failure_notify_msec`, `_save_failure_notify_key`, `_runtime_generation`, `_shutting_down`, `_prewarmed_pet_signatures`

**判定**：保留生命周期控制面。档案身份/代次继续归 `ArchiveSession` 与 `MemoryClass`；保存结果由显式状态/信号观察；`_archive_session` 与 `_run_context` 作为组合根持有的上下文引用保留，不把其内容重新暴露为全局字段。预热标记逐步归 `ResourceRuntime`。

### 2.8 普通子服务指针（26）

`_resource_runtime`, `_scene_flow`, `_popup_factory`, `_shop_factory`, `_backpack_factory`, `_reward_factory`, `_combat_factory`, `_combat_pool`, `_magic_weapon_runtime`, `_level_entry`, `_monster_spawn`, `_role_visual`, `_monster_display`, `_level_hint`, `_zhen_fa`, `_forge_factory`, `_projectile_factory`, `_effect_factory`, `_menu_panel_factory`, `_level_scene_factory`, `_show_text_factory`, `_skill_panel_factory`, `_map_overlay_factory`, `_audio_runtime`, `_ui_runtime`, `_runtime_diagnostics`

**判定**：全部是 26 个普通子服务的引用，保留在 `Global` 的组合根内；不得把服务内部字段重新搬回 `Global`。`_monsters_to_track` 已随 22-2 删除。

### 2.9 场景/UI 遗留引用（已迁出）

- `target_scene` -> `SceneFlow.target_scene`，加载页经 `get_target_scene` / `set_target_scene` 读取；
- `lhhjbutton`、`lhhjhelp`、`listbutton`、`lhhj`、`return_back_map` -> `MenuPanelFactory`；
- `fall_equ` -> `BackpackFactory.fall_item`；
- `nmw_hands` -> `MonsterDisplayFactory.create_hands`；
- `llbt_challenge` -> `LevelSceneFactory.add_llbt_challenge`；
- `sell_or_equ`、`sound` 无消费者，删除。

### 2.10 剩余字段复核（Phase 22-4）

| 组 | 数量 | 字段范围 | 所有者 | 保留理由 | 出口 |
|:---|:---:|:---|:---|:---|:---|
| 2.2 功能开关 | 1 | `_hidden_feature_flags` | `Global` | 隐藏功能总开关，当前读取/清理入口固定 | 专门功能开关服务出现时再迁移 |
| 2.3 HUD/战斗表现引用 | 15 | §2.3 列表全部 | `UiRuntime` / 场景工厂 / 场景上下文 | 均为表现/HUD 共享引用，消费者明确 | 无消费者时删除；新增写入禁止进入 `Global` |
| 2.7 档案/保存/运行代次 | 23 | §2.7 列表全部 | `MemoryClass` / `ArchiveSession` / `ResourceRuntime` | 生命周期控制面，服务于保存、退出与预热 | 随对应服务边界迁移；不重新暴露为业务字段 |
| 2.8 普通子服务指针 | 26 | §2.8 列表全部 | `Global` 组合根 | 组合根持有服务引用，非业务状态 | 保留；服务内部状态不得回流 |

其余组：2.1/2.4/2.5/2.6/2.9 均为 0 字段。合计 **1 + 15 + 23 + 26 = 65**。

**机读守卫**：`scripts/contract_scan.py` 的 `global_surface_boundary` 规则读取 `scripts/global_surface_baseline.json`；新增 `Global` 字段或新增 `add` 系入口在 `--fail-on-error` 下为 ERROR。自测覆盖新增字段、新增入口、局部变量、注释与非 `Global` 文件。

---

## 3. 普通子服务与所有权

`source/project.godot` 当前有 **10 个注册项**：9 个业务单例 + `MCPGameBridge` 调试桥。以下 26 项是 `Global._ready()` 创建、挂到 `Global` 下的普通节点，**不是 Autoload**：

| 服务 | 当前职责 | 目标 |
|:---|:---|:---|
| `UiRuntime` | UI 宿主、弹层、hover、临时 UI 登记、UI 实例缓存与一次性欢迎/开场状态 | 保留；UI 生命周期的唯一服务入口 |
| `AudioRuntime` | BGM/SFX、声部仲裁与设置信号 | 保留；业务不直接创建 `AudioStreamPlayer` |
| `RuntimeDiagnostics` | 只读诊断与性能浮层 | 保留；只读，不成为业务状态写者 |
| `ResourceRuntime` | 场景/精灵帧/音频/纹理缓存、租约、预载单槽 | 保留；缓存/租约的唯一服务 |
| `SceneFlow` | 场景切换、请求代次、目标快照 | 保留；业务唯一正式切换入口 |
| `PopupFactory` | 通用弹窗/确认框场景槽位 | 保留；继续走 `UiRuntime` 登记 |
| `ShopFactory` | 商店场景槽位 | 保留 |
| `BackpackFactory` | 背包/装备/售卖场景槽位与背包格点击冷却 | 保留；背包 UI 状态所有者 |
| `RewardFactory` | 奖励展示/领取场景槽位 | 保留 |
| `CombatPresentationFactory` | 角色/怪物战斗表现场景槽位 | 保留；不拥有伤害真源 |
| `CombatPoolRuntime` | 伤害文本/受击/音效池与限流、连击里程碑去重/延迟派发 | 保留；消费者负责重置 |
| `MagicWeaponRuntime` | 法宝召唤物两槽位、场景路径表、创建/替换/预载/清理 | 保留；唯一所有者 |
| `LevelEntryRuntime` | 关卡信息面板、掉落表、进入编排 | 保留；迁入关卡选择/进入状态 |
| `MonsterSpawnRuntime` | 怪物 ID 解析与 `create_monster` | 保留 |
| `RoleVisualRuntime` | 角色身体/装备静态贴图与同槽释放 | 保留 |
| `MonsterDisplayFactory` | 怪物头像/Boss 信息/通用提示 | 保留 |
| `LevelHintFactory` | 掉落箱/道具箱/进入条件/回收/悬浮提示 | 保留 |
| `ZhenFaFactory` | 阵法说明/突破/阵眼等六个槽位 | 保留 |
| `ForgeFactory` | 锻造/分解说明与主面板 | 保留；吸收 `forge`/`fb_cd` 等瞬时状态 |
| `ProjectileFactory` | 角色/怪物/法宝弹体与丹药场景 | 保留；吸收节点引用 |
| `EffectFactory` | 灵魄/技能/Boss/无双/浅攻表现 | 保留 |
| `MenuPanelFactory` | 设置/技能键位/音乐/炼丹炉等菜单面板 | 保留 |
| `LevelSceneFactory` | 地板/陷阱/选关/相机场景 | 保留 |
| `ShowTextFactory` | 任务标题/评分/字体/帮助/信件 | 保留 |
| `SkillPanelFactory` | 技能/变身/法宝说明面板 | 保留 |
| `MapOverlayFactory` | 主菜单地图浮层 | 保留 |

此外：

- `RunContext`（`RefCounted`）由 `Global` 持有，负责关卡显示名、宝塔层数、单局统计、特殊副本无尽模式、八仙选择与精英副本选择；**不是**第 27 个子服务。
- `ArchiveSession` 由 `Global` 持有，负责档案身份、档案号、路径与代次；业务查询会话，不直接写 `cd_path`。
- `CloudSession`（`RefCounted`）由 `MemoryClass` 持有，负责云存档登录凭证、UID 摘要、账号名与认证冷却；档案界面通过 `MemoryClass.get_cloud_session()` 使用，不新增 Autoload。

**保留原则**：`Global` 只保留组合、typed getter 与正式窄入口；服务内部状态由服务自身所有。新增能力若需要跨场景生命周期，先证明普通节点/`RefCounted`/`Resource` 不足，再按 Autoload 评审。

---

## 4. 公开入口清单

公开入口指非 `_` 前缀函数；内部回调、私有实现不在此列。完整公开符号列表见 §5，以下按职责给出稳定入口与迁移判定。

### 4.1 必须保持稳定的入口

| 入口 | 当前契约 | 处理 |
|:---|:---|:---|
| `change_scene(target, force_loading_screen := false, require_archive_session := true) -> bool` | 唯一业务场景切换入口 | 保留；禁止业务直接 `change_scene_to_*` |
| `get_scene_request_generation() -> int` / `is_scene_request_current(generation) -> bool` | 场景请求代次校验 | 保留；归 `SceneFlow` 语义 |
| `begin_level_resource_lease(target_scene) -> int` / `release_level_resource_lease(lease_id := -1) -> int` | 关卡资源租约 | 保留；归 `ResourceRuntime` |
| `is_resource_cached` / `get_cached_packed_scene` / `handoff_loaded_resource` | 加载页窄交接 | 保留；不得暴露私有缓存 |
| `request_save_with_feedback(reason, parent := null, failure_prefix := "保存失败：") -> bool` | 业务保存反馈入口 | 保留；内部委托 `MemoryClass.request_save_result` |
| `set_cd_path` / `get_archive_session...` / `begin_archive_session` / `end_archive_session` | 档案身份与会话 | 保留；`set_cd_path` 是唯一身份写入口 |
| `get_run_context()` / `get_current_level_name` / `set_current_level_name` / `get_tower_floor` / `set_tower_floor` | 单局上下文 | 保留；后续把残留字段迁入 `RunContext` |
| `get_*_runtime()` / `get_*_factory()` | 26 个服务的 typed getter | 保留；新代码优先使用服务 API |
| 资源窄入口（`preload_next`、`clear_preloaded_scene_slot`、`prewarm_*`、`load_*`） | 加载/预热/缓存 | 保留，但由 `ResourceRuntime` 实现；新增只加必要入口 |

### 4.2 工厂/UI 门面

`add` 系入口共 **120** 个（113 个 `add_` 前缀，7 个历史无下划线命名），均属于场景工厂或表现门面；`Global.add_` 调用约 **1,474** 处。原则：

- 现有正式入口可暂时保留，但内部实现继续归各工厂；
- 新代码优先 `Global.get_*_factory()`，不得新增 `Global.add_*`；
- 迁移一个工厂族时，同批迁移生产调用方并删除旧门面；
- 每次迁移必须覆盖临时 UI 登记、弹层、关闭回调和保存快照互斥。

完整的 `add` 系名称见 §5 的 UI/工厂分组；该清单是 Phase 22/24 的输入，不是新增入口的白名单。

### 4.3 兼容/遗留入口

`instance_scene`, `add_bullet`, `add_role_bullet_1_safe`, `add_bullet_safe`, `fall_item`, `remove_all_buff`, `remove_a_all_buff`, `check_wd`, `remove_wd` 等：

- 先确认生产调用方与生命周期；
- 有正式工厂/服务的，迁入后删除；
- 无调用方且无动态引用的，进入删除候选；
- 不因“名称看起来像旧代码”直接删除。

---

## 5. 公开符号附录

以下按 `source/global.gd` 的公开函数定义顺序分组；每行是完整组名。`_` 前缀函数不在清单中；`var` 字段见 §2。

### 5.1 功能开关与代次

```text
set_hidden_feature_enabled, is_hidden_feature_enabled
is_runtime_generation_current
```

### 5.2 服务 getter（26）

```text
get_runtime_diagnostics, get_ui_runtime, get_audio_runtime, get_resource_runtime,
get_scene_flow, get_popup_factory, get_shop_factory, get_backpack_factory,
get_reward_factory, get_combat_factory, get_combat_pool, get_magic_weapon_runtime,
get_level_entry_runtime, get_monster_spawn_runtime, get_role_visual_runtime,
get_monster_display_factory, get_level_hint_factory, get_zhen_fa_factory,
get_forge_factory, get_projectile_factory, get_effect_factory,
get_menu_panel_factory, get_level_scene_factory, get_show_text_factory,
get_skill_panel_factory, get_map_overlay_factory
```

### 5.3 档案、保存、运行上下文

```text
set_cd_path, get_cd_path, get_archive_session, is_archive_session_active,
get_archive_session_path, get_archive_session_archive_number,
get_archive_session_role_id, get_archive_session_generation,
get_archive_identity_epoch, get_run_context, get_current_level_name,
set_current_level_name, get_tower_floor, set_tower_floor, advance_tower_floor,
is_special_dungeon_endless, set_special_dungeon_endless,
clear_special_dungeon_endless, get_selected_eight_immortal_id,
set_selected_eight_immortal_id, set_save_failure_feedback_enabled
```

### 5.4 资源、池、缓存与预热

```text
recycle_damage_text, recycle_mr_hurt, recycle_role_be_hit,
can_show_sword_damage_text, can_show_sword_hit_effect, load_ui_scene,
load_cached_scene, prewarm_permanent_small_ui_scenes,
is_resource_cached, get_cached_packed_scene,
handoff_loaded_resource, get_cached_audio, get_cached_texture,
get_zhenfa_icon_path, get_zhenfa_icon, get_static_texture,
release_cached_texture, preload_scene_path, prewarm_skill_page_resources,
load_scene_uncached, load_level_monster_scene, preload_level_monster_scenes,
prewarm_monster_scene_paths, preload_level_monster_runtime_resources,
preload_level_texture_paths, load_monster_bullet_scene, load_fly_bullet_scene,
preload_combat_hit_resources, clear_level_resource_cache,
release_map_visual_resources, clear_combat_runtime_cache
```

### 5.5 档案/角色资源生命周期

```text
is_archive_exit_scene, bind_archive_session, begin_archive_session,
get_current_role_equipment_preload_paths, end_archive_session,
release_role_runtime_resources, begin_level_resource_lease,
release_level_resource_lease, prewarm_monster_bullet_scene_paths,
preload_damage_number_textures,
prewarm_sprite_frames_paths, prewarm_texture_paths,
get_current_role_preload_paths, prewarm_current_role_runtime_resources,
preload_next, clear_preloaded_scene_slot
```

### 5.6 UI/工厂第一批

```text
add_basic_ar_button, add_zhen_fa_help, add_zhen_fa_tu_po,
add_zhen_yan_cure_level, addzhenyanbutton, add_zhen_fa_info,
add_zhenfalxbutton, addhdgqmap, add_monster141_aura, addlhhjhelp,
addlistbutton, addlhhj, addlhhjbutton, add_some_monster_help,
add_mosaic_help, add_letter_for_player, add_cure_times_box,
add_mystery_shop, add_trans_box, add_role4_bullet, add_line,
add_dsg_choose, add_hdzm, add_lsh, add_lxdy, add_monster_info,
add_basic_monment_info, add_forge_help, add_forges,
addllbt_challenge, add_basic_pellet, add_game_announcement,
add_font_instance, add_task_reward, add_basic_task,
add_task_title, configure_backpack_role_preview, screen_popup_position
```

### 5.7 UI/工厂与关卡提示第二批

```text
apply_popup_screen_layout,
popup_position_for_parent, viewport_center_for_parent, add_reward_info,
add_reward_box, add_decompose_help, add_decompose_instance,
add_zztw_trap, add_stage, add_boss_blood_instance, add_hc_help,
add_help_thing, add_pj, get_current_level_fall_pro,
sync_level_drop_pro_data, apply_level_entry_mode_reset,
add_level_info, add_monster_head, add_level_fall_box, add_item_box,
add_game_need_know, add_new_bullet, add_smb_effect,
add_role2_shallow, add_role_special_effect, add_role_bullet,
add_monster65_bullet, add_aura, add_buffinfor, add_buff_icon,
is_monster_control_buff, clear_white_bar_control_buffs, add_buff,
add_after_level_end, add_combo, add_combo_num, add_z_lw_stage,
add_h_hjm, add_miss_effect, add_damage_number,
set_damage_text_enabled, add_damage_text, add_role1_shallow,
add_role_bullet_1, add_skill_key_set, add_game_set,
add_mosaic_instance, add_magic_help, add_use_magic_weapon,
add_skill_select, add_weapon_bullet, get_active_pet_preload_data
```

### 5.8 宠物、法宝与场景入口

```text
get_active_pet_preload_paths, prewarm_active_pet_runtime_resources,
get_magic_weapon_scene_path, get_magic_weapon_preload_paths,
prewarm_magic_weapon_runtime_resources, prepare_magic_weapon_resources,
add_magic_weapon, get_magic_summon_for, set_magic_summon_for,
add_message_show, request_save_with_feedback, add_ws_effect,
add_choose_item, add_s_y_n_help, add_shop, add_shop_items,
add_magp_infor, add_synthesis, add_change_bg, add_strength,
create_hands, call_chase_bullet, call_fly_bullet, add_lj,
add_trap, add_buff_info, add_buff_icon_text, add_special_effect,
add_choose_text, add_special_effect_bullet, add_role_information,
add_learn_skill, add_zd_skillscene, add_bd_skillscene,
add_gm_infor, add_ldl, add_pl_sell, fall_item, add_dj_infor,
close_backpack_click_menus, add_dj_sell, add_equ_propeties_box,
add_se_eq_jm, add_main_backpack, change_scene
```

### 5.9 场景/战斗/提示第三批

```text
get_scene_request_generation, is_scene_request_current, add_music_set,
add_camera, call_hero, add_cd_jm, add_moment_text, add_touch_text,
add_back_pack, create_monster, add_hit_text, add_monster_blood,
add_mr_hurt, left_align_popup_texts,
prepare_hover_info_popup, center_popup_texts,
add_role_bullet_1_safe, add_bullet_safe, instance_scene, add_bullet,
load_role1_body, load_role1_eq, remove_all_buff, remove_all_active_buffs,
remove_a_all_buff, check_wd, remove_wd
```

---

## 6. 批次记录

Phase 22-2~22-4 的逐批删除项、迁移字段与验证见 [`../archive/iteration_22_global_state_boundary.md`](../archive/iteration_22_global_state_boundary.md)。

收口结果：`Global` 从 141 字段、273 公开函数收敛到 **65 字段、260 公开函数**；业务状态按 `RunContext`、`ArchiveSession`、`MemoryClass`、`UiRuntime`、`CombatPoolRuntime`、场景工厂与 `SceneFlow` 分域；未新增 Autoload。后续不再把已迁移状态回流 `Global`。

---

## 7. 相关文档

- [`architecture.md`](architecture.md)：当前运行时架构与 `Global` 服务说明
- [`autoload_boundary_matrix.md`](autoload_boundary_matrix.md)：11 个 Autoload 处置与 `Global` 边界
- [`runtime_lifecycle_matrix.md`](runtime_lifecycle_matrix.md)：缓存、租约、退出与失败边界
- [`archive_session_matrix.md`](archive_session_matrix.md)：保存、会话、槽位与失败边界
- [`../roadmap/current-iteration.md`](../roadmap/current-iteration.md)：Phase 22 当前批次与后续阶段
- [`../standards/target_architecture_contract.md`](../standards/target_architecture_contract.md)：状态所有权与迁移纪律
