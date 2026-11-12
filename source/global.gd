extends Node
const DataKeys := preload("res://Script/base/data_keys.gd")

const TARGET_MAX_FPS := 150
const AUDIO_RUNTIME_SCRIPT := preload("res://Script/runtime/audio_runtime.gd")
const UI_RUNTIME_SCRIPT := preload("res://Script/runtime/ui_runtime.gd")
const RUNTIME_DIAGNOSTICS_SCRIPT := preload("res://Script/runtime/runtime_diagnostics.gd")
const RESOURCE_RUNTIME_SCRIPT := preload("res://Script/runtime/resource_runtime.gd")
const SCENE_FLOW_SCRIPT := preload("res://Script/runtime/scene_flow.gd")
const POPUP_FACTORY_SCRIPT := preload("res://Script/runtime/popup_factory.gd")
const SHOP_FACTORY_SCRIPT := preload("res://Script/runtime/shop_factory.gd")
const BACKPACK_FACTORY_SCRIPT := preload("res://Script/runtime/backpack_factory.gd")
const REWARD_FACTORY_SCRIPT := preload("res://Script/runtime/reward_factory.gd")
const COMBAT_PRESENTATION_FACTORY_SCRIPT := preload("res://Script/runtime/combat_presentation_factory.gd")
const COMBAT_POOL_RUNTIME_SCRIPT := preload("res://Script/runtime/combat_pool_runtime.gd")
const MAGIC_WEAPON_RUNTIME_SCRIPT := preload("res://Script/runtime/magic_weapon_runtime.gd")
const LEVEL_ENTRY_RUNTIME_SCRIPT := preload("res://Script/runtime/level_entry_runtime.gd")
const MONSTER_SPAWN_RUNTIME_SCRIPT := preload("res://Script/runtime/monster_spawn_runtime.gd")
const ROLE_VISUAL_RUNTIME_SCRIPT := preload("res://Script/runtime/role_visual_runtime.gd")
const MONSTER_DISPLAY_FACTORY_SCRIPT := preload("res://Script/runtime/monster_display_factory.gd")
const LEVEL_HINT_FACTORY_SCRIPT := preload("res://Script/runtime/level_hint_factory.gd")
const ZHEN_FA_FACTORY_SCRIPT := preload("res://Script/runtime/zhen_fa_factory.gd")
const FORGE_FACTORY_SCRIPT := preload("res://Script/runtime/forge_factory.gd")
const PROJECTILE_FACTORY_SCRIPT := preload("res://Script/runtime/projectile_factory.gd")
const EFFECT_FACTORY_SCRIPT := preload("res://Script/runtime/effect_factory.gd")
const MENU_PANEL_FACTORY_SCRIPT := preload("res://Script/runtime/menu_panel_factory.gd")
const LEVEL_SCENE_FACTORY_SCRIPT := preload("res://Script/runtime/level_scene_factory.gd")
const SHOW_TEXT_FACTORY_SCRIPT := preload("res://Script/runtime/show_text_factory.gd")
const SKILL_PANEL_FACTORY_SCRIPT := preload("res://Script/runtime/skill_panel_factory.gd")
const MAP_OVERLAY_FACTORY_SCRIPT := preload("res://Script/runtime/map_overlay_factory.gd")
const WUSHUANG_HUOYAN_EFFECT_SCRIPT = preload("res://Script/hero/wu_shuang_huo_yan_jin_jing_effect.gd")
const BING_YU_EFFECT_SCRIPT = preload("res://Script/hero/bing_yu_effect.gd")
const BA_DI_QIAN_KUN_EFFECT_SCRIPT = preload("res://Script/hero/ba_di_qian_kun_effect.gd")
const BI_LUO_TIAN_EFFECT_SCRIPT = preload("res://Script/hero/bi_luo_tian_effect.gd")
const LEI_TING_JIE_ZHEN_EFFECT_SCRIPT = preload("res://Script/hero/lei_ting_jie_zhen_effect.gd")
const SMSR_SHENQI_LIGHTNING_EFFECT_SCRIPT = preload("res://Script/hero/smsr_shenqi_lightning_effect.gd")
const HMZ_AWAKEN_EFFECT_SCRIPT = preload("res://Script/hero/hmz_awaken_effect.gd")
const LYFB_AWAKEN_EFFECT_SCRIPT = preload("res://Script/hero/lyfb_awaken_effect.gd")
const JHSJ_AWAKEN_EFFECT_SCRIPT = preload("res://Script/hero/jhsj_awaken_effect.gd")
const CANG_MU_LONG_YUN_EFFECT_SCRIPT = preload("res://Script/hero/cang_mu_long_yun_effect.gd")
const ROLE4_POISON_ARRAY_AWAKEN_EFFECT_SCRIPT = preload("res://Script/hero/role4_poison_array_awaken_effect.gd")
const STREAMING_ROLE_BULLET_SCRIPT = preload("res://Script/hero/streaming_role_bullet.gd")
const MIRROR_SCRIPT = preload("res://Script/magic_weapon/mirror.gd")
const PET_TURTLE_BULLET_SCRIPT = preload("res://Script/pet/pet_turtle_bullet.gd")
const PET_RABBIT_BULLET_SCRIPT = preload("res://Script/pet/pet_rabbit_bullet.gd")
const PET_MOUSE_BULLET_SCRIPT = preload("res://Script/pet/pet_mouse_bullet.gd")
const PET_NEAT_BULLET_SCRIPT = preload("res://Script/pet/pet_neat_bullet.gd")
const PET_YIN_TIGER_BULLET_SCRIPT = preload("res://Script/pet/pet_yin_tiger_bullet.gd")
const MONSTER_CONTROL_BUFF_NAMES := [
	"Ice",
	"stun",
	"EyeFix",
	"DeadLink",
	"Boundground",
	"silent",
	"Immobilize",
	"blood_fix",
	"life_mana_lock",
	"Scary",
	"speed_down",
	"lljybuff",
	"ReverseMove",
]
const ZHENFA_ICON_PATHS := {
	"slz": "res://Art/zhenfa/senluozhen/slz.png",
	"lpz": "res://Art/zhenfa/luopozhen/lpz.png",
	"tsz": "res://Art/zhenfa/tengshezhen/tsz.png",
	"tqz": "res://Art/zhenfa/taiqingzhen/tqz.png",
}

const HIDDEN_FEATURE_INVINCIBLE := "invincible"
const HIDDEN_FEATURE_INSTANT_KILL := "instant_kill"
const HIDDEN_FEATURE_ALL_MAPS := "all_maps"
const HIDDEN_FEATURE_FREE_SHOP := "free_shop"
const HIDDEN_FEATURE_ALL_SHOP_ITEMS := "all_shop_items"

var _hidden_feature_flags: Dictionary = {
	HIDDEN_FEATURE_INVINCIBLE: false,
	HIDDEN_FEATURE_INSTANT_KILL: false,
	HIDDEN_FEATURE_ALL_MAPS: false,
	HIDDEN_FEATURE_FREE_SHOP: false,
	HIDDEN_FEATURE_ALL_SHOP_ITEMS: false,
}


func set_hidden_feature_enabled(feature_name: String, enabled: bool) -> void:
	if _hidden_feature_flags.has(feature_name):
		_hidden_feature_flags[feature_name] = enabled


func is_hidden_feature_enabled(feature_name: String) -> bool:
	return bool(_hidden_feature_flags.get(feature_name, false))


var all_buff_list = [
	"speed_down",
	"defe_reduce",
	"nlls",
	"Ice",
	"stun",
	"EyeFix",
	"DeadLink",
	"Boundground",
	"silent",
	"Immobilize",
	"blood_fix",
	"life_mana_lock",
	"Bleed",
	"poision",
	"Fire",
	"Scary",
	"SuperArmor",
	"Indestructible",
	"Indestructible1",
	"DoubleFallPro",
	"Voodoo",
	"PoisionBody",
	"slzbuff",
	"lpzbuff",
	"yxbuff",
	"tszbuff",
	"lljybuff",
	"no_debuff",
	"flls",
	"MagicDrain",
	"ReverseMove",
	"SanXianHuTi",
	"jgz",
	"zznh",
	"SMSRSZ_CD"
]

const COMBAT_HIT_DAMAGE_POOL_SIZE := 12
const COMBAT_HIT_EFFECT_POOL_SIZE := 16
const COMBAT_HIT_SOUND_POOL_SIZE := 6
var choose_ms: bool
var buff_box
var mg_cd_pic
var zhen_fa
var lhhj_boss_list = {}

const HIT_TEXT_PATH := "res://Scene/hittext/hit_text.tscn"
const DAMAGE_TEXT_PATH := "res://Scene/hittext/damage_text.tscn"
const MONSTER_BLOOD_PATH := "res://Scene/monster/monster_blood_bar.tscn"
const BOSS_BLOOD_PATH := "res://Scene/monster/boss_blood.tscn"
const MONSTER_BE_HIT_PATH := "res://Scene/monster/monster_be_hit.tscn"
const SPECIAL_AFFECT_SLIM_DIR := "res://Scene/base/special_affect_slim"
const ROLE_BE_HIT_EFFECT_PATH := "res://Scene/base/role_be_hit_effect.tscn"
const DAMAGE_NUMBER_PATH := "res://Scene/hittext/damage_number.tscn"
const MISS_EFFECT_PATH := "res://Scene/hittext/miss_effect.tscn"
const COMBO_PATH := "res://Scene/hittext/combo.tscn"
const COMBO_NUM_PATH := "res://Scene/hittext/combo_num.tscn"
const LIJI_PATH := "res://Scene/hittext/liji.tscn"
const MOMENT_TEXT_PATH := "res://Scene/hittext/moment_text.tscn"
const MESSAGE_SHOW_PATH := "res://Scene/hittext/message_show.tscn"
const BASE_BUFF_PATH := "res://Scene/base/base_buff.tscn"
const MONSTER_BULLET_SLIM_DIR := "res://Scene/monster/monster_bullet_slim"
const MONSTER_RESOURCE_ALIASES := {
	3178: 3159,
	3183: 3177,
	3126: 3119,
	3145: 3121,
	3146: 3122,
}
const MONSTER_ATLAS_LOCATIONS := {
	3019: "res://Art/monster/swf_png/3019",
	3035: "res://Art/monster/swf_png/3035",
	3037: "res://Art/monster/swf_png/3037",
	3040: "res://Art/monster/swf_png/3040",
	3041: "res://Art/monster/swf_png/3041",
}
const MONSTER_BULLET_PATH := "res://Scene/monster/monster65bullet.tscn"
const FLY_BULLET_PATH := "res://Scene/bullet/fly_bullet.tscn"
const FLY_BULLET_SLIM_DIR := "res://Scene/bullet/fly_bullet_slim"
const CHASE_BULLET_PATH := "res://Scene/bullet/chase_bullet.tscn"
const MONSTER_212_BULLET_SCRIPTS := [
	preload("res://Script/monster/monster212_bullet1.gd"),
	preload("res://Script/monster/monster212_bullet2.gd"),
	preload("res://Script/monster/monster212_bullet3.gd"),
	preload("res://Script/monster/monster212_bullet4.gd"),
]
const MONSTER_FRAME_CACHE_REGISTRY := preload("res://Script/monster/monster_frame_cache_registry.gd")


func _exit_tree() -> void:
	_shutting_down = true
	# 引擎在 RenderingServer 关闭后才释放自定义光标纹理，导致 CompressedTexture2D 析构晚于渲染服务器；
	# 退出清理前重置光标，让纹理在服务器存活时释放。
	Input.set_custom_mouse_cursor(null)
	_advance_runtime_generation()
	if _scene_flow != null:
		_scene_flow.clear_runtime_state()
	_archive_session_generation += 1
	_archive_session_prewarm_token += 1
	_archive_session = ArchiveSession.new()
	_archive_session_prewarm_in_progress = false
	_archive_session_prewarm_role_id = 0
	_prewarmed_role_id = 0
	_prewarmed_pet_signatures.clear()
	release_role_runtime_resources()
	clear_combat_runtime_cache()
	if _ui_runtime != null:
		_ui_runtime.release_ui_runtime_cache(true)
		_ui_runtime.clear_runtime_state()
	if _resource_runtime != null:
		_resource_runtime.shutdown_runtime_state()
	if _audio_runtime != null:
		_audio_runtime.clear_runtime_state()
	FrameSequenceStore.clear_cache()
	FrameTextureRequests.shutdown_process()


func _advance_runtime_generation() -> int:
	_runtime_generation += 1
	return _runtime_generation


func is_runtime_generation_current(generation: int) -> bool:
	return not _shutting_down and generation == _runtime_generation


func _ready() -> void:
	if MainSet != null and MainSet.has_method("apply_frame_rate"):
		MainSet.apply_frame_rate()
	else:
		Engine.max_fps = TARGET_MAX_FPS
	_ui_runtime = UI_RUNTIME_SCRIPT.new()
	_ui_runtime.name = "UiRuntime"
	_ui_runtime.setup(self)
	add_child(_ui_runtime)
	_audio_runtime = AUDIO_RUNTIME_SCRIPT.new()
	_audio_runtime.name = "AudioRuntime"
	_audio_runtime.setup(self)
	add_child(_audio_runtime)
	_runtime_diagnostics = RUNTIME_DIAGNOSTICS_SCRIPT.new()
	_runtime_diagnostics.name = "RuntimeDiagnostics"
	_runtime_diagnostics.setup(self)
	add_child(_runtime_diagnostics)
	_resource_runtime = RESOURCE_RUNTIME_SCRIPT.new()
	_resource_runtime.name = "ResourceRuntime"
	_resource_runtime.setup(self)
	add_child(_resource_runtime)
	_scene_flow = SCENE_FLOW_SCRIPT.new()
	_scene_flow.name = "SceneFlow"
	_scene_flow.setup(self)
	add_child(_scene_flow)
	_popup_factory = POPUP_FACTORY_SCRIPT.new()
	_popup_factory.name = "PopupFactory"
	_popup_factory.setup(self)
	add_child(_popup_factory)
	_shop_factory = SHOP_FACTORY_SCRIPT.new()
	_shop_factory.name = "ShopFactory"
	_shop_factory.setup(self)
	add_child(_shop_factory)
	_backpack_factory = BACKPACK_FACTORY_SCRIPT.new()
	_backpack_factory.name = "BackpackFactory"
	_backpack_factory.setup(self)
	add_child(_backpack_factory)
	_reward_factory = REWARD_FACTORY_SCRIPT.new()
	_reward_factory.name = "RewardFactory"
	_reward_factory.setup(self)
	add_child(_reward_factory)
	_combat_factory = COMBAT_PRESENTATION_FACTORY_SCRIPT.new()
	_combat_factory.name = "CombatPresentationFactory"
	_combat_factory.setup(self)
	add_child(_combat_factory)
	_combat_pool = COMBAT_POOL_RUNTIME_SCRIPT.new()
	_combat_pool.name = "CombatPoolRuntime"
	_combat_pool.setup(self)
	add_child(_combat_pool)
	_magic_weapon_runtime = MAGIC_WEAPON_RUNTIME_SCRIPT.new()
	_magic_weapon_runtime.name = "MagicWeaponRuntime"
	_magic_weapon_runtime.setup(self)
	add_child(_magic_weapon_runtime)
	_level_entry = LEVEL_ENTRY_RUNTIME_SCRIPT.new()
	_level_entry.name = "LevelEntryRuntime"
	_level_entry.setup(self)
	add_child(_level_entry)
	_monster_spawn = MONSTER_SPAWN_RUNTIME_SCRIPT.new()
	_monster_spawn.name = "MonsterSpawnRuntime"
	_monster_spawn.setup(self)
	add_child(_monster_spawn)
	_role_visual = ROLE_VISUAL_RUNTIME_SCRIPT.new()
	_role_visual.name = "RoleVisualRuntime"
	_role_visual.setup(self)
	add_child(_role_visual)
	_monster_display = MONSTER_DISPLAY_FACTORY_SCRIPT.new()
	_monster_display.name = "MonsterDisplayFactory"
	_monster_display.setup(self)
	add_child(_monster_display)
	_level_hint = LEVEL_HINT_FACTORY_SCRIPT.new()
	_level_hint.name = "LevelHintFactory"
	_level_hint.setup(self)
	add_child(_level_hint)
	_zhen_fa = ZHEN_FA_FACTORY_SCRIPT.new()
	_zhen_fa.name = "ZhenFaFactory"
	_zhen_fa.setup(self)
	add_child(_zhen_fa)
	_forge_factory = FORGE_FACTORY_SCRIPT.new()
	_forge_factory.name = "ForgeFactory"
	_forge_factory.setup(self)
	add_child(_forge_factory)
	_projectile_factory = PROJECTILE_FACTORY_SCRIPT.new()
	_projectile_factory.name = "ProjectileFactory"
	_projectile_factory.setup(self)
	add_child(_projectile_factory)
	_effect_factory = EFFECT_FACTORY_SCRIPT.new()
	_effect_factory.name = "EffectFactory"
	_effect_factory.setup(self)
	add_child(_effect_factory)
	_menu_panel_factory = MENU_PANEL_FACTORY_SCRIPT.new()
	_menu_panel_factory.name = "MenuPanelFactory"
	_menu_panel_factory.setup(self)
	add_child(_menu_panel_factory)
	_level_scene_factory = LEVEL_SCENE_FACTORY_SCRIPT.new()
	_level_scene_factory.name = "LevelSceneFactory"
	_level_scene_factory.setup(self)
	add_child(_level_scene_factory)
	_show_text_factory = SHOW_TEXT_FACTORY_SCRIPT.new()
	_show_text_factory.name = "ShowTextFactory"
	_show_text_factory.setup(self)
	add_child(_show_text_factory)
	_skill_panel_factory = SKILL_PANEL_FACTORY_SCRIPT.new()
	_skill_panel_factory.name = "SkillPanelFactory"
	_skill_panel_factory.setup(self)
	add_child(_skill_panel_factory)
	_map_overlay_factory = MAP_OVERLAY_FACTORY_SCRIPT.new()
	_map_overlay_factory.name = "MapOverlayFactory"
	_map_overlay_factory.setup(self)
	add_child(_map_overlay_factory)
	if MemoryClass != null and not MemoryClass.background_save_finished.is_connected(_on_background_save_finished):
		MemoryClass.background_save_finished.connect(_on_background_save_finished)
	if MemoryClass != null and not MemoryClass.save_failed.is_connected(_on_save_failed):
		MemoryClass.save_failed.connect(_on_save_failed)


func get_runtime_diagnostics() -> RuntimeDiagnostics:
	return _runtime_diagnostics


func get_ui_runtime() -> UiRuntime:
	return _ui_runtime


func get_audio_runtime() -> AudioRuntime:
	return _audio_runtime


func get_resource_runtime() -> ResourceRuntime:
	return _resource_runtime


func get_scene_flow() -> SceneFlow:
	return _scene_flow


func get_popup_factory() -> PopupFactory:
	return _popup_factory


func get_shop_factory() -> ShopFactory:
	return _shop_factory


func get_backpack_factory() -> BackpackFactory:
	return _backpack_factory


func get_reward_factory() -> RewardFactory:
	return _reward_factory


func get_combat_factory() -> CombatPresentationFactory:
	return _combat_factory


func get_combat_pool() -> CombatPoolRuntime:
	return _combat_pool


func get_magic_weapon_runtime() -> MagicWeaponRuntime:
	return _magic_weapon_runtime


func get_level_entry_runtime() -> LevelEntryRuntime:
	return _level_entry


func get_monster_spawn_runtime() -> MonsterSpawnRuntime:
	return _monster_spawn


func get_role_visual_runtime() -> RoleVisualRuntime:
	return _role_visual


func get_monster_display_factory() -> MonsterDisplayFactory:
	return _monster_display


func get_level_hint_factory() -> LevelHintFactory:
	return _level_hint


func get_zhen_fa_factory() -> ZhenFaFactory:
	return _zhen_fa


func get_forge_factory() -> ForgeFactory:
	return _forge_factory


func get_projectile_factory() -> ProjectileFactory:
	return _projectile_factory


func get_effect_factory() -> EffectFactory:
	return _effect_factory


func get_menu_panel_factory() -> MenuPanelFactory:
	return _menu_panel_factory


func get_level_scene_factory() -> LevelSceneFactory:
	return _level_scene_factory


func get_show_text_factory() -> ShowTextFactory:
	return _show_text_factory


func get_skill_panel_factory() -> SkillPanelFactory:
	return _skill_panel_factory


func get_map_overlay_factory() -> MapOverlayFactory:
	return _map_overlay_factory


var _cd_path: String = ""


## 档案身份唯一写入口：切换档案时先 flush 待写任务，再结束旧会话并递增身份纪元。
## 返回 flush 是否成功；调用方可用返回值提示用户，但路径切换本身仍然生效。
func set_cd_path(path: String) -> bool:
	var next_path: String = str(path).strip_edges()
	if next_path == _cd_path:
		return true
	var flushed := true
	if MemoryClass != null and MemoryClass.has_method("flush_pending_saves"):
		flushed = bool(MemoryClass.flush_pending_saves())
	if is_archive_session_active():
		# 路径与会话不允许并存不同档案：切换路径即撤销旧会话上下文。
		end_archive_session()
	_cd_path = next_path
	# 身份纪元只随档案路径变化；会话开始/结束不应让同一档案的待写任务失效。
	_archive_identity_epoch += 1
	_advance_runtime_generation()
	return flushed


func get_cd_path() -> String:
	return _cd_path


func is_archive_session_active() -> bool:
	return _archive_session != null and _archive_session.is_active()


func get_archive_session_path() -> String:
	return _archive_session.get_archive_path() if is_archive_session_active() else ""


func get_archive_session_archive_number() -> int:
	return _archive_session.get_archive_number() if is_archive_session_active() else 0


func get_archive_session_role_id() -> int:
	return _archive_session.get_role_id() if is_archive_session_active() else 0


func get_archive_session_generation() -> int:
	return _archive_session_generation


## 档案身份纪元：仅在档案路径变更时递增，供保存快照与后台任务校验。
func get_archive_identity_epoch() -> int:
	return _archive_identity_epoch


## ---------------------------------------------------------------------------
## 运行上下文：关卡显示名、玲珑宝塔层数、选择、计时、导航、挑战模式与战斗统计的读写入口。
## 写入必须经 set_*/advance_*/record_* 或 RunContext 的统计方法；读取固定走 accessor。
## ---------------------------------------------------------------------------
func get_run_context() -> RunContext:
	return _run_context


func get_current_level_name() -> String:
	return _run_context.get_level_display_name()


func set_current_level_name(value: String) -> void:
	_run_context.set_level_display_name(value)


func get_tower_floor() -> int:
	return _run_context.get_tower_floor()


func set_tower_floor(value: int) -> void:
	_run_context.set_tower_floor(value)


func advance_tower_floor() -> void:
	_run_context.advance_tower_floor()


## 特殊副本无尽模式：同一时刻至多一个为真，写入走 RunContext 整体赋值。
func is_special_dungeon_endless(target_path: String) -> bool:
	return _run_context.is_special_dungeon_endless(target_path)


func set_special_dungeon_endless(target_path: String, enabled: bool) -> void:
	_run_context.set_special_dungeon_endless(target_path, enabled)


func clear_special_dungeon_endless() -> void:
	_run_context.clear_special_dungeon_endless()


func get_selected_eight_immortal_id() -> int:
	return _run_context.get_selected_eight_immortal_id()


func set_selected_eight_immortal_id(value: int) -> void:
	_run_context.set_selected_eight_immortal_id(value)


## 后台保存唯一消费者：记录最后完成序号与失败次数。
## 后台写入由 MemoryClass 自动重试，战斗内不弹 UI，避免瞬时失败误报；
## 失败仍通过 last_save_error、push_error 与本状态快照可观察。
func _on_background_save_finished(path: String, success: bool, serial: int) -> void:
	if serial <= 0 or serial < _background_save_last_serial:
		return
	_background_save_last_serial = serial
	_background_save_last_success = success
	_background_save_last_path = path
	# 切档后到达的旧任务是预期取消，不计入失败次数。
	if not success and MemoryClass.last_save_error != "stale_archive_identity":
		_background_save_failure_count += 1


## 同步保存失败兜底消费者：调用方已处理时 notify=false，不重复弹窗。
func _on_save_failed(reason: String, error: String, message: String, notify: bool) -> void:
	_save_failure_count += 1
	_save_failure_last = {"reason": reason, "error": error, "message": message}
	if not notify or not _save_failure_feedback_enabled or _suppress_save_failure_feedback:
		return
	if not is_inside_tree() or get_tree() == null:
		return
	var now := Time.get_ticks_msec()
	var key := error + ":" + message
	if key == _save_failure_notify_key and now - _save_failure_notify_msec < 1500:
		return
	_save_failure_notify_key = key
	_save_failure_notify_msec = now
	add_message_show(_ui_runtime.get_popup_layer(), message, 2.0)


func set_save_failure_feedback_enabled(enabled: bool) -> void:
	_save_failure_feedback_enabled = enabled


var _prewarmed_role_id: int = 0
var _archive_session: ArchiveSession = ArchiveSession.new()
var _run_context: RunContext = RunContext.new()
var _archive_session_prewarm_in_progress: bool = false
var _archive_session_prewarm_role_id: int = 0
var _archive_session_prewarm_token: int = 0
var _archive_session_generation: int = 0
var _archive_identity_epoch: int = 0
## 后台保存信号消费者状态：只做诊断与失败可观察，不弹出战斗内提示。
var _background_save_last_serial: int = 0
var _background_save_last_success: bool = true
var _background_save_last_path: String = ""
var _background_save_failure_count: int = 0
## 同步保存失败反馈：命令/面板自处理时用 notify=false 抑制兜底提示。
var _save_failure_count: int = 0
var _save_failure_last: Dictionary = {}
var _save_failure_feedback_enabled: bool = true
var _suppress_save_failure_feedback: bool = false
var _save_failure_notify_msec: int = 0
var _save_failure_notify_key: String = ""
var _runtime_generation: int = 0
var _shutting_down := false
var _prewarmed_pet_signatures: Dictionary = {}
var _resource_runtime: ResourceRuntime = null
var _scene_flow: SceneFlow = null
var _popup_factory: PopupFactory = null
var _shop_factory: ShopFactory = null
var _backpack_factory: BackpackFactory = null
var _reward_factory: RewardFactory = null
var _combat_factory: CombatPresentationFactory = null
var _combat_pool: CombatPoolRuntime = null
var _magic_weapon_runtime: MagicWeaponRuntime = null
var _level_entry: LevelEntryRuntime = null
var _monster_spawn: MonsterSpawnRuntime = null
var _role_visual: RoleVisualRuntime = null
var _monster_display: MonsterDisplayFactory = null
var _level_hint: LevelHintFactory = null
var _zhen_fa: ZhenFaFactory = null
var _forge_factory: ForgeFactory = null
var _projectile_factory: ProjectileFactory = null
var _effect_factory: EffectFactory = null
var _menu_panel_factory: MenuPanelFactory = null
var _level_scene_factory: LevelSceneFactory = null
var _show_text_factory: ShowTextFactory = null
var _skill_panel_factory: SkillPanelFactory = null
var _map_overlay_factory: MapOverlayFactory = null
var _audio_runtime: AudioRuntime = null
var _ui_runtime: UiRuntime = null
var _runtime_diagnostics: RuntimeDiagnostics = null


## 取出不重置：池内节点在归还/预热时已由 prepare_for_pool() 清理，
## 调用方必须用新数据调用 setup() 或播放入口；场景类型校验由各池固定场景保证。
func _take_pooled_node(pool_name: String, scene_path: String) -> Node:
	return _combat_pool.take_pooled_node(pool_name, scene_path)


func _attach_pooled_node(node: Node, parent: Node) -> void:
	_combat_pool.attach_pooled_node(node, parent)


func recycle_damage_text(node: Node) -> void:
	_combat_pool.recycle_damage_text(node)


func recycle_mr_hurt(node: Node) -> void:
	_combat_pool.recycle_mr_hurt(node)


func recycle_role_be_hit(node: Node) -> void:
	_combat_pool.recycle_role_be_hit(node)


func can_show_sword_damage_text() -> bool:
	return _combat_pool.can_show_sword_damage_text()


func can_show_sword_hit_effect() -> bool:
	return _combat_pool.can_show_sword_hit_effect()


func _load_scene(path: String) -> PackedScene:
	return _resource_runtime.load_scene(path)


func load_ui_scene(path: String) -> PackedScene:
	if not _ui_runtime.is_runtime_ui_scene_path(path):
		return load(path) as PackedScene
	return _resource_runtime.load_scene(path)


## 场景工厂的统一取景入口：命中永久 UI/资源缓存时复用，不再单独加载。
func load_cached_scene(path: String) -> PackedScene:
	return _resource_runtime.load_scene(path)


func prewarm_permanent_small_ui_scenes(generation: int = -1) -> bool:
	return await _resource_runtime.prewarm_permanent_small_ui_scenes(generation)


# 加载页只读查询：不暴露缓存字典，也不触发加载。
func is_resource_cached(path: String) -> bool:
	return _resource_runtime.is_resource_cached(path)


# 返回已缓存的场景；未命中或无效时返回 null，不写入缓存。
func get_cached_packed_scene(path: String) -> PackedScene:
	return _resource_runtime.get_cached_packed_scene(path)


# 加载页唯一写入口：按资源类型写入缓存；track_level 只登记本次加载拥有的路径。
func handoff_loaded_resource(path: String, resource: Resource, track_level: bool = false) -> bool:
	return _resource_runtime.handoff_loaded_resource(path, resource, track_level)


func get_cached_audio(path: String) -> AudioStream:
	return _resource_runtime.get_cached_audio(path)


func _standard_monster_frames_path(monster_id: int) -> String:
	# 预热直连预生成 SpriteFrames，不再在运行时解析 atlas manifest。
	var resolved_id := int(MONSTER_RESOURCE_ALIASES.get(monster_id, monster_id))
	if resolved_id == 3352:
		return "res://Art/monster/cloud_boss/model_3352/cloud_boss_frames.tres"
	if resolved_id in [3323, 3343]:
		return "res://Art/monster/palace_boss/%d/palace_boss_%d_frames.tres" % [resolved_id, resolved_id]
	var north_record := NorthOriginalData.monster_record(resolved_id)
	if not north_record.is_empty():
		var model := int(north_record.get("model", resolved_id))
		return "res://Art/monster/north_original/%d/north_original_%d_frames.tres" % [model, model]
	var model_root := str(MONSTER_ATLAS_LOCATIONS.get(resolved_id, "res://Art/monster/swf_png/%d" % resolved_id))
	return model_root.path_join("atlas/swf_png_%d_frames.tres" % resolved_id)


func get_cached_texture(path: String) -> Texture2D:
	return _resource_runtime.get_cached_texture(path)


func get_zhenfa_icon_path(zhenfa_name: String) -> String:
	return str(ZHENFA_ICON_PATHS.get(zhenfa_name, ""))


func get_zhenfa_icon(zhenfa_name: String) -> Texture2D:
	return get_static_texture(get_zhenfa_icon_path(zhenfa_name))


func get_static_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	var resolved_path := path
	if not ResourceLoader.exists(resolved_path):
		return null
	return ResourceLoader.load(resolved_path, "Texture2D", ResourceLoader.CACHE_MODE_REUSE) as Texture2D


func release_cached_texture(path: String) -> void:
	_resource_runtime.release_cached_texture(path)


func preload_scene_path(path: String) -> PackedScene:
	return _resource_runtime.load_scene(path)


func prewarm_skill_page_resources(generation: int = -1) -> void:
	var request_generation := _runtime_generation if generation < 0 else generation
	if not is_runtime_generation_current(request_generation):
		return
	var paths: Array = [
		"res://Scene/skill/zd_skill.tscn",
		"res://Scene/skill/bd_skill.tscn",
	]
	var role_id := clampi(int(PlayerData.player_data.get("Myself", 1)), 1, 8)
	var role_skill_icons := {
		1: ["slz", "hytj", "lys", "lyfb", "hmz", "hmz_ws", "zz", "qsez", "jdy", "hyjj", "sx", "gsrs", "hyjj_ws"],
		2: ["blb", "xbz", "shy", "tjgl", "smb", "sgq", "myhc", "jgz", "jhsj", "sjt", "by", "zfjg"],
		3: ["ssp", "dj", "dgq", "zznh", "tmc", "sd", "jsp", "xgq", "syzq", "rj", "bdqk"],
		4: ["qlj", "dcj", "wdzt", "tkj", "mmw", "jdz", "lhsq", "zq", "wdww", "mds", "bylt", "cmly"],
		5: ["xyq", "slq", "blq", "fhf", "cxq", "llrd", "lljy", "ygth", "tllz", "yyb", "ltjz"],
		6: ["nz_jlsh", "nz_fhcc", "nz_hlqg", "nz_hlhs", "nz_lblc"],
		7: YutuSkillData.KEYS,
		8: LongnvSkillData.KEYS,
	}
	for icon_name in role_skill_icons[role_id]:
		paths.append("res://Art/skill/skill_icon/%s.png" % icon_name)
	await _preload_paths_threaded(paths, request_generation)
	if not is_runtime_generation_current(request_generation):
		return
	_skill_panel_factory.prime_skill_scenes()


func load_scene_uncached(path: String) -> PackedScene:
	return _resource_runtime.load_scene_uncached(path)


func load_level_monster_scene(path: String) -> PackedScene:
	return _resource_runtime.load_level_monster_scene(path)


func preload_level_monster_scenes(monster_ids: Array) -> void:
	var request_generation := _runtime_generation
	if not is_runtime_generation_current(request_generation):
		return
	var scene_paths: Array = []
	var seen_paths := {}
	for monster_id_value in monster_ids:
		var monster_id := int(monster_id_value)
		if monster_id <= 0:
			continue
		var scene_path := _monster_spawn.monster_scene_path(monster_id)
		if scene_path.is_empty() or seen_paths.has(scene_path):
			continue
		seen_paths[scene_path] = true
		scene_paths.append(scene_path)
	if scene_paths.is_empty():
		return
	_track_level_scene_dependencies(scene_paths)
	await _preload_paths_threaded(scene_paths, request_generation)
	if not is_runtime_generation_current(request_generation):
		return
	for path_value in scene_paths:
		var path := str(path_value)
		var scene := _resource_runtime.get_cached_packed_scene(path)
		if scene is PackedScene:
			_resource_runtime.cache_monster_scene(path, scene)


func prewarm_monster_scene_paths(scene_paths: Array, generation: int = -1) -> void:
	var request_generation := _runtime_generation if generation < 0 else generation
	if not is_runtime_generation_current(request_generation):
		return
	var pending_paths: Array[String] = []
	for path_value in scene_paths:
		var path := str(path_value)
		if path == "" or _is_level_scene_warmed(path) or pending_paths.has(path):
			continue
		pending_paths.append(path)
	if pending_paths.is_empty():
		return
	_track_level_scene_dependencies(pending_paths)
	await _preload_paths_threaded(pending_paths, request_generation)
	if not is_runtime_generation_current(request_generation):
		return
	await _warm_scene_paths_over_frames(pending_paths, 1, request_generation)
	if not is_runtime_generation_current(request_generation):
		return
	for path in pending_paths:
		var scene := _resource_runtime.get_cached_packed_scene(path)
		if scene is PackedScene:
			_resource_runtime.cache_monster_scene(path, scene)
			_resource_runtime.mark_level_scene_warmed(path)


func preload_level_monster_runtime_resources(monster_ids: Array) -> void:
	var request_generation := _runtime_generation
	if not is_runtime_generation_current(request_generation):
		return
	var requested_monster_ids: Array = monster_ids.duplicate()

	var unique_monster_ids: Array = []
	var seen_monster_ids: Dictionary = {}
	for monster_id_value in requested_monster_ids:
		var monster_id := int(monster_id_value)
		if monster_id <= 0 or seen_monster_ids.has(monster_id) or _is_level_monster_prewarmed(monster_id):
			continue
		seen_monster_ids[monster_id] = true
		unique_monster_ids.append(monster_id)
	if unique_monster_ids.is_empty():
		return

	var texture_paths: Array = []
	var frames_visited: Dictionary = {}
	for monster_id in unique_monster_ids:
		_collect_texture_dependencies_recursive(
			_standard_monster_frames_path(monster_id), texture_paths, frames_visited
		)
	for monster_id_value in unique_monster_ids:
		for path_value in LevelPreloadStore.dynamic_monster_textures(int(monster_id_value)):
			_append_unique_preload_path(texture_paths, str(path_value))
	if not texture_paths.is_empty():
		var textures_per_frame := 2 if OS.has_feature("mobile") else 5
		if seen_monster_ids.has(3343):
			textures_per_frame = 1
		await preload_level_texture_paths(texture_paths, textures_per_frame, request_generation)
		if not is_runtime_generation_current(request_generation):
			return

	if seen_monster_ids.has(5):
		MonsterBullet.warm_monster5_stream_images()
	if seen_monster_ids.has(212):
		for bullet_script in MONSTER_212_BULLET_SCRIPTS:
			if not is_runtime_generation_current(request_generation):
				return
			bullet_script.prewarm_frames()
			var tree := get_tree()
			if tree == null:
				return
			await tree.process_frame
			if not is_runtime_generation_current(request_generation):
				return
	if seen_monster_ids.has(3077):
		var ancestor_script: Script = load("res://Script/monster/wutai_earth_ancestor3077.gd")
		await ancestor_script.prewarm_effects()
		if not is_runtime_generation_current(request_generation):
			return

	var tiger_stage := 0
	for monster_id in unique_monster_ids:
		if monster_id >= 1501 and monster_id <= 1504:
			tiger_stage = maxi(tiger_stage, monster_id - 1500)
	if tiger_stage > 0:
		await MonsterBullet.prewarm_pet_tiger_runtime(tiger_stage)
		if not is_runtime_generation_current(request_generation):
			return

	var monster_scene_paths: Array[String] = []
	for monster_id in unique_monster_ids:
		var scene_path := _monster_spawn.monster_scene_path(monster_id)
		if ResourceLoader.exists(scene_path) and not monster_scene_paths.has(scene_path):
			monster_scene_paths.append(scene_path)
	var bullet_scene_paths := _collect_monster_bullet_scene_paths(monster_scene_paths)
	for monster_id_value in unique_monster_ids:
		for scene_path_value in LevelPreloadStore.dynamic_monster_scenes(int(monster_id_value)):
			_append_unique_preload_path(bullet_scene_paths, str(scene_path_value))
	await prewarm_monster_bullet_scene_paths(bullet_scene_paths, request_generation)
	if not is_runtime_generation_current(request_generation):
		return
	await prewarm_monster_scene_paths(monster_scene_paths, request_generation)
	if not is_runtime_generation_current(request_generation):
		return

	for monster_id in unique_monster_ids:
		_mark_level_monster_prewarmed(monster_id)


func preload_level_texture_paths(texture_paths: Array, textures_per_frame: int = 5, generation: int = -1) -> void:
	var request_generation := _runtime_generation if generation < 0 else generation
	if not is_runtime_generation_current(request_generation):
		return
	var unique_paths: Array = []
	for path_value in texture_paths:
		var path := str(path_value)
		if path == "" or unique_paths.has(path):
			continue
		unique_paths.append(path)
		_track_level_resource(path)
	if unique_paths.is_empty():
		return
	await _preload_paths_threaded(unique_paths, request_generation)
	if not is_runtime_generation_current(request_generation):
		return
	await _warm_texture_rids_over_frames(unique_paths, maxi(1, textures_per_frame), request_generation)


func load_monster_bullet_scene(bullet_name: String) -> PackedScene:
	var slim_path := MONSTER_BULLET_SLIM_DIR.path_join(bullet_name + ".tscn")
	if ResourceLoader.exists(slim_path):
		return load_scene_uncached(slim_path)

	var fallback := load_scene_uncached(MONSTER_BULLET_PATH)
	if fallback != null:
		return fallback
	push_error("Missing MonsterBullet scene: %s" % bullet_name)
	return null


func load_fly_bullet_scene(bullet_name: String) -> PackedScene:
	var slim_path := FLY_BULLET_SLIM_DIR.path_join(bullet_name + ".tscn")
	if ResourceLoader.exists(slim_path):
		return load_scene_uncached(slim_path)
	return _cached_scene(&"fly_bullet", FLY_BULLET_PATH)


func _cache_threaded_resource(path: String, resource: Resource) -> void:
	_resource_runtime.cache_threaded_resource(path, resource)


func _preload_paths_threaded(paths: Array, generation: int = -1) -> void:
	await _resource_runtime.preload_paths_threaded(paths, generation)


func _warm_scene_paths_over_frames(paths: Array, per_frame: int = 2, generation: int = -1) -> void:
	await _resource_runtime.warm_scene_paths_over_frames(paths, per_frame, generation)


func _warm_audio_streams_over_frames(paths: Array, per_frame: int = 2, generation: int = -1) -> void:
	await _resource_runtime.warm_audio_streams_over_frames(paths, per_frame, generation)


func _warm_texture_rids_over_frames(paths: Array, per_frame: int = 6, generation: int = -1) -> void:
	await _resource_runtime.warm_texture_rids_over_frames(paths, per_frame, generation)


func preload_combat_hit_resources(phase_marks: Array = []) -> void:
	var request_generation := _runtime_generation
	if not is_runtime_generation_current(request_generation):
		return
	phase_marks.append({"stage": "hit resources begin", "msec": Time.get_ticks_msec()})
	phase_marks.append({"stage": "hit damage textures begin", "msec": Time.get_ticks_msec()})
	preload_damage_number_textures()
	phase_marks.append({"stage": "hit damage textures end", "msec": Time.get_ticks_msec()})
	phase_marks.append({"stage": "hit scenes begin", "msec": Time.get_ticks_msec()})
	load_cached_scene(HIT_TEXT_PATH)
	var damage_scene := _cached_scene(&"damage_text", DAMAGE_TEXT_PATH)
	load_cached_scene(DAMAGE_NUMBER_PATH)
	load_cached_scene(MISS_EFFECT_PATH)
	var role_be_hit_scene := preload_scene_path(ROLE_BE_HIT_EFFECT_PATH)
	var monster_hit_scene := _cached_scene(&"monster_be_hit", MONSTER_BE_HIT_PATH)
	var monster_blood_scene := load_cached_scene(MONSTER_BLOOD_PATH)
	var sound_scene := preload_scene_path("res://Scene/all_sound/monster_be_hit.tscn")
	phase_marks.append({"stage": "hit scenes end", "msec": Time.get_ticks_msec()})
	phase_marks.append({"stage": "hit audio begin", "msec": Time.get_ticks_msec()})
	get_cached_audio("res://Music/monster_hurt/6_beattack_by_role1.mp3")
	get_cached_audio("res://Music/hero/9_beattack_by_role2.mp3")
	get_cached_audio("res://Music/hero/49_role1_be_attack.mp3")
	get_cached_audio("res://Music/hero/62_role2_be_attack.mp3")
	get_cached_audio("res://Music/hero/68_role3_be_attack.mp3")
	phase_marks.append({"stage": "hit audio end", "msec": Time.get_ticks_msec()})
	phase_marks.append({"stage": "hit pool seed begin", "msec": Time.get_ticks_msec()})
	_seed_runtime_pool("damage_text", damage_scene, COMBAT_HIT_DAMAGE_POOL_SIZE)
	_seed_runtime_pool("mr_hurt", monster_hit_scene, COMBAT_HIT_EFFECT_POOL_SIZE)
	_seed_runtime_pool("role_be_hit", role_be_hit_scene, COMBAT_HIT_EFFECT_POOL_SIZE)
	_seed_runtime_pool("sound_player", sound_scene, COMBAT_HIT_SOUND_POOL_SIZE)
	phase_marks.append({"stage": "hit pool seed end", "msec": Time.get_ticks_msec()})
	await _prewarm_combat_hit_rendering(monster_blood_scene, request_generation, phase_marks)
	phase_marks.append({"stage": "hit resources end", "msec": Time.get_ticks_msec()})


func _seed_runtime_pool(pool_name: String, scene: PackedScene, target_size: int) -> void:
	_combat_pool.seed_pool(pool_name, scene, target_size)


func _prewarm_combat_hit_rendering(
	monster_blood_scene: PackedScene, generation: int = -1, phase_marks: Array = []
) -> void:
	var request_generation := _runtime_generation if generation < 0 else generation
	if not is_runtime_generation_current(request_generation):
		return
	var tree := get_tree()
	if tree == null:
		return
	phase_marks.append({"stage": "hit render setup begin", "msec": Time.get_ticks_msec()})
	var warm_root := Node2D.new()
	warm_root.name = "CombatHitPrewarm"
	warm_root.z_index = -4096
	warm_root.position = get_viewport().get_visible_rect().get_center()
	add_child(warm_root)

	var role_hit = _take_pooled_node("role_be_hit", ROLE_BE_HIT_EFFECT_PATH)
	if role_hit != null:
		_attach_pooled_node(role_hit, warm_root)
		role_hit.setup(Vector2.ONE, false, 1.0)
		role_hit.modulate.a = 0.001

	var damage_sample = _take_pooled_node("damage_text", DAMAGE_TEXT_PATH)
	if damage_sample != null:
		_attach_pooled_node(damage_sample, warm_root)
		damage_sample.setup(88888888, "physics", false, null)
		damage_sample.modulate.a = 0.001
		var damage_player := damage_sample.get_node_or_null("ShowPlayer") as AnimationPlayer
		if damage_player != null and damage_player.has_animation(&"physics"):
			damage_player.play(&"physics")

	var monster_hits: Array[Node] = []
	for animation_name in [&"hurt_1", &"hurt_2"]:
		var monster_hit = _take_pooled_node("mr_hurt", MONSTER_BE_HIT_PATH)
		if monster_hit == null:
			continue
		_attach_pooled_node(monster_hit, warm_root)
		monster_hit.visible = true
		monster_hit.modulate.a = 0.001
		var animation_player := monster_hit.get_node_or_null("AnimationPlayer") as AnimationPlayer
		if animation_player != null and animation_player.has_animation(animation_name):
			animation_player.play(animation_name)
		monster_hits.append(monster_hit)

	if monster_blood_scene != null:
		var blood_bar := monster_blood_scene.instantiate() as Node2D
		if blood_bar != null:
			blood_bar.process_mode = Node.PROCESS_MODE_DISABLED
			blood_bar.modulate.a = 0.001
			warm_root.add_child(blood_bar)
			var progress_bar := blood_bar.get_node_or_null("blood_bar") as TextureProgressBar
			var blood_label := blood_bar.get_node_or_null("blood_bar/blood_text") as Label
			if progress_bar != null:
				progress_bar.value = 0.75
			if blood_label != null:
				blood_label.text = "123456"

	for texture_path in [
		"res://Art/all_number/magic/physics_8.png",
		"res://Art/all_number/magic/magic_8.png",
		"res://Art/all_number/real/real_8.png",
	]:
		var digit_sprite := Sprite2D.new()
		digit_sprite.texture = get_cached_texture(texture_path)
		digit_sprite.modulate.a = 0.001
		warm_root.add_child(digit_sprite)

	var sound_players: Array[AudioStreamPlayer] = []
	for sound_path in [
		"res://Music/monster_hurt/6_beattack_by_role1.mp3",
		"res://Music/hero/9_beattack_by_role2.mp3",
	]:
		var sound_player = (
			_take_pooled_node("sound_player", "res://Scene/all_sound/monster_be_hit.tscn") as AudioStreamPlayer
		)
		if sound_player == null:
			continue
		_attach_pooled_node(sound_player, warm_root)
		sound_player.set_physics_process(false)
		sound_player.volume_db = -80.0
		sound_player.stream = get_cached_audio(sound_path)
		sound_player.play()
		sound_players.append(sound_player)

	phase_marks.append({"stage": "hit render setup end", "msec": Time.get_ticks_msec()})
	phase_marks.append({"stage": "hit render frame wait begin", "msec": Time.get_ticks_msec()})
	await tree.process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
	phase_marks.append({"stage": "hit render frame wait end", "msec": Time.get_ticks_msec()})
	if not is_runtime_generation_current(request_generation):
		if is_instance_valid(warm_root):
			warm_root.queue_free()
		return

	phase_marks.append({"stage": "hit render recycle begin", "msec": Time.get_ticks_msec()})
	if role_hit != null and is_instance_valid(role_hit):
		role_hit.modulate = Color.WHITE
		role_hit.recycle()
	if damage_sample != null and is_instance_valid(damage_sample):
		damage_sample.modulate = Color.WHITE
		damage_sample.recycle()
	for monster_hit in monster_hits:
		if monster_hit != null and is_instance_valid(monster_hit):
			monster_hit.modulate = Color.WHITE
			monster_hit.recycle()
	for sound_player in sound_players:
		if sound_player == null or not is_instance_valid(sound_player):
			continue
		sound_player.stop()
		sound_player.stream = null
		sound_player.set_physics_process(false)
		if not _combat_pool.is_pooled(sound_player, "sound_player"):
			_audio_runtime.recycle_sound_player(sound_player)
	if is_instance_valid(warm_root):
		warm_root.free()
	phase_marks.append({"stage": "hit render recycle end", "msec": Time.get_ticks_msec()})


func _warm_scene_instance(scene: PackedScene) -> void:
	_resource_runtime.warm_scene_instance(scene)


func clear_level_resource_cache() -> void:
	release_level_resource_lease()
	FrameSequenceStore.clear_cache()
	for bullet_script in MONSTER_212_BULLET_SCRIPTS:
		bullet_script.clear_cached_frames()


func release_map_visual_resources(root: Node) -> void:
	if root == null or not is_instance_valid(root):
		return
	for child in root.get_children():
		release_map_visual_resources(child)
	var sprite := root as Sprite2D
	if sprite != null:
		sprite.texture = null
	var texture_rect := root as TextureRect
	if texture_rect != null:
		texture_rect.texture = null
	var texture_button := root as TextureButton
	if texture_button != null:
		texture_button.texture_normal = null
		texture_button.texture_pressed = null
		texture_button.texture_hover = null
		texture_button.texture_disabled = null
		texture_button.texture_focused = null
	var progress_bar := root as TextureProgressBar
	if progress_bar != null:
		progress_bar.texture_under = null
		progress_bar.texture_progress = null
		progress_bar.texture_over = null
	var animated_sprite := root as AnimatedSprite2D
	if animated_sprite != null:
		animated_sprite.sprite_frames = null
	var nine_patch := root as NinePatchRect
	if nine_patch != null:
		nine_patch.texture = null


func clear_combat_runtime_cache() -> void:
	clear_level_resource_cache()
	_clear_runtime_pools()
	MONSTER_FRAME_CACHE_REGISTRY.clear_all()
	NeZhaEquipmentVisuals.clear_cached_frames()
	_prewarmed_role_id = 0
	_prewarmed_pet_signatures.clear()
	_role_visual.reset()

	_combat_factory.clear_scene_caches()
	_projectile_factory.clear_scene_caches()
	_effect_factory.clear_scene_caches()
	if _magic_weapon_runtime != null:
		_magic_weapon_runtime.clear_runtime_state()


func is_archive_exit_scene(scene_path: String) -> bool:
	return (
		scene_path
		in [
			"res://Scene/main_menu/main_menu.tscn",
			"res://Scene/main_menu/choose_player.tscn",
		]
	)


## 同步建立会话：校验当前路径与角色，路径或角色变化时递增会话代次。
## 不预热资源；需要预热的入口使用 begin_archive_session()。
func bind_archive_session() -> bool:
	var path: String = _cd_path.strip_edges()
	var archive_number := 0
	if MemoryClass != null:
		archive_number = MemoryClass.archive_number_from_path(path)
	if archive_number <= 0:
		# 前置条件不满足属正常调用结果：由调用方决定提示，不产生运行期告警。
		return false
	var role_id := _role_visual.current_role_id()
	if role_id < 1 or role_id > 8:
		return false
	if _archive_session.matches(path, role_id):
		return true
	if is_archive_session_active() and _archive_session.get_role_id() != role_id:
		release_role_runtime_resources()
	_archive_session_generation += 1
	_archive_session = ArchiveSession.new(_archive_session_generation, archive_number, role_id, path)
	_advance_runtime_generation()
	return true


## 建立会话并按需预热；prewarm=false 时只绑定会话（夹具与无渲染入口使用）。
func begin_archive_session(prewarm: bool = true) -> bool:
	if not bind_archive_session():
		return false
	if not prewarm:
		return true
	if _archive_session_prewarm_in_progress:
		if _archive_session_prewarm_role_id == _archive_session.get_role_id():
			return true
		# 等待进行中的预热结束，避免两个协程同时写缓存；最多等 600 帧。
		var waited := 0
		while _archive_session_prewarm_in_progress and waited < 600:
			if get_tree() == null:
				return false
			await get_tree().process_frame
			waited += 1
			if not is_archive_session_active():
				return false
		if not is_archive_session_active():
			return false
	if _archive_session_prewarm_role_id == _archive_session.get_role_id():
		return true
	_archive_session_prewarm_token += 1
	var prewarm_token := _archive_session_prewarm_token
	_archive_session_prewarm_in_progress = true
	_archive_session_prewarm_role_id = _archive_session.get_role_id()
	var generation := _archive_session_generation
	var role_id := _archive_session.get_role_id()
	var runtime_generation := _runtime_generation
	var ui_ready: bool = await prewarm_permanent_small_ui_scenes(runtime_generation)
	if not ui_ready:
		if _is_archive_session_current(generation, role_id, runtime_generation):
			push_warning("常用界面预热失败：" + _resource_runtime.get_permanent_ui_prewarm_error())
		_finish_archive_prewarm(prewarm_token)
		return false
	if not _is_archive_session_current(generation, role_id, runtime_generation):
		_finish_archive_prewarm(prewarm_token)
		return false
	await prewarm_skill_page_resources(runtime_generation)
	if not _is_archive_session_current(generation, role_id, runtime_generation):
		_finish_archive_prewarm(prewarm_token)
		return false
	await _prewarm_archive_role_resources(role_id, runtime_generation)
	if not _is_archive_session_current(generation, role_id, runtime_generation):
		_finish_archive_prewarm(prewarm_token)
		return false
	if prewarm_token == _archive_session_prewarm_token:
		_archive_session_prewarm_in_progress = false
		_archive_session_prewarm_role_id = role_id
	return true


func _is_archive_session_current(generation: int, role_id: int, runtime_generation: int) -> bool:
	return (
		generation == _archive_session_generation
		and is_archive_session_active()
		and _archive_session.get_role_id() == role_id
		and is_runtime_generation_current(runtime_generation)
	)


func _finish_archive_prewarm(prewarm_token: int) -> void:
	# 仅清理本次预热的标记，避免取消中的旧协程清掉新会话的预热状态。
	if prewarm_token != _archive_session_prewarm_token:
		return
	_archive_session_prewarm_in_progress = false
	_archive_session_prewarm_role_id = 0


func _prewarm_archive_role_resources(role_id: int, generation: int = -1) -> void:
	var request_generation := _runtime_generation if generation < 0 else generation
	if not is_runtime_generation_current(request_generation):
		return
	var role_paths: Array[String] = []
	role_paths.append_array(get_current_role_equipment_preload_paths(role_id))
	await _preload_paths_threaded(role_paths, request_generation)
	if not is_runtime_generation_current(request_generation):
		return
	await prewarm_current_role_runtime_resources(role_id, request_generation)


func _current_visual_equipment_names() -> Dictionary:
	var weapon_name := "Empty"
	var body_name := "Empty"
	var transmog: Variant = PlayerData.player_data.get(DataKeys.TRANSMOG_LIST, {})
	var weapon_transmog := str(transmog.get(DataKeys.WEAPON, "")) if transmog is Dictionary else ""
	var body_transmog := str(transmog.get(DataKeys.ARMOR, "")) if transmog is Dictionary else ""
	var weapons: Variant = PlayerData.player_data.get(DataKeys.WEAPON, [])
	var fashions: Variant = PlayerData.player_data.get(DataKeys.FASHION, [])
	var armors: Variant = PlayerData.player_data.get(DataKeys.ARMOR, [])
	if weapon_transmog != "":
		weapon_name = weapon_transmog
	elif weapons is Array and not weapons.is_empty() and weapons[0] is Dictionary:
		weapon_name = str((weapons[0] as Dictionary).get(DataKeys.NAME, "Empty"))
	if body_transmog != "":
		body_name = body_transmog
	elif fashions is Array and not fashions.is_empty() and fashions[0] is Dictionary:
		body_name = str((fashions[0] as Dictionary).get(DataKeys.NAME, "Empty"))
	elif armors is Array and not armors.is_empty() and armors[0] is Dictionary:
		body_name = str((armors[0] as Dictionary).get(DataKeys.NAME, "Empty"))
	return {"weapon": weapon_name, "body": body_name}


func get_current_role_equipment_preload_paths(role_id: int = 0) -> Array[String]:
	if role_id <= 0:
		role_id = _role_visual.current_role_id()
	var names := _current_visual_equipment_names()
	var paths: Array[String] = []
	if role_id == 7:
		return ["res://Art/hero_picture/role_7/official_parts/default/parts.png"]
	if role_id == 8:
		return [
			"res://Art/hero_picture/role_8/official_parts/default/parts.png",
			"res://Art/hero_picture/role_8/official_parts/ring/default/parts.png",
		]
	if role_id == 6:
		NeZhaEquipmentVisuals.get_body_frames(str(names.get("body", "Empty")))
		NeZhaEquipmentVisuals.get_body_front_frames(str(names.get("body", "Empty")))
		NeZhaEquipmentVisuals.get_weapon_frames(str(names.get("weapon", "Empty")))
		return paths
	var body_name: String = str(ItemUtils.clean_fashion_name(str(names.get("body", "Empty")))).to_lower()
	var weapon_name: String = str(names.get("weapon", "Empty")).to_lower()
	var body_path := "res://Art/hero_picture/role_%d_all_equipment/role_%d_body_%s.png" % [role_id, role_id, body_name]
	var weapon_path := (
		"res://Art/hero_picture/role_%d_all_equipment/role_%d_eq_%s.png" % [role_id, role_id, weapon_name]
	)
	if ResourceLoader.exists(body_path):
		paths.append(body_path)
	if ResourceLoader.exists(weapon_path):
		paths.append(weapon_path)
	return paths


func end_archive_session() -> void:
	_audio_runtime.stop_bgm()
	# 退出/切档前先落盘未决后台任务；flush 失败时任务仍留在重试队列。
	if MemoryClass != null and MemoryClass.has_method("flush_pending_saves"):
		MemoryClass.flush_pending_saves()
	_advance_runtime_generation()
	_resource_runtime.clear_ui_scope()
	if not is_archive_session_active():
		return
	_archive_session_generation += 1
	_archive_session_prewarm_token += 1
	_archive_session = ArchiveSession.new()
	_archive_session_prewarm_in_progress = false
	_archive_session_prewarm_role_id = 0
	clear_combat_runtime_cache()

	HMZ_AWAKEN_EFFECT_SCRIPT.clear_cached_data()
	LYFB_AWAKEN_EFFECT_SCRIPT.clear_cached_data()
	JHSJ_AWAKEN_EFFECT_SCRIPT.clear_cached_data()
	CANG_MU_LONG_YUN_EFFECT_SCRIPT.clear_cached_data()
	ROLE4_POISON_ARRAY_AWAKEN_EFFECT_SCRIPT.clear_cached_data()
	STREAMING_ROLE_BULLET_SCRIPT.clear_cached_frames()
	MIRROR_SCRIPT.clear_cached_frames()


func _clear_runtime_pools() -> void:
	if _combat_pool != null:
		_combat_pool.clear_runtime_pools()
	if _audio_runtime != null:
		_audio_runtime.release_active_sound_players()


func release_role_runtime_resources() -> void:
	_prewarmed_role_id = 0
	_role_visual.reset()
	NeZhaEquipmentVisuals.clear_cached_frames()
	WUSHUANG_HUOYAN_EFFECT_SCRIPT.clear_cached_frames()
	BING_YU_EFFECT_SCRIPT.clear_cached_data()
	BA_DI_QIAN_KUN_EFFECT_SCRIPT.clear_cached_frames()
	BI_LUO_TIAN_EFFECT_SCRIPT.clear_cached_frames()
	LEI_TING_JIE_ZHEN_EFFECT_SCRIPT.clear_cached_frames()
	SMSR_SHENQI_LIGHTNING_EFFECT_SCRIPT.clear_cached_frames()
	HMZ_AWAKEN_EFFECT_SCRIPT.clear_cached_data()
	LYFB_AWAKEN_EFFECT_SCRIPT.clear_cached_data()
	JHSJ_AWAKEN_EFFECT_SCRIPT.clear_cached_data()
	CANG_MU_LONG_YUN_EFFECT_SCRIPT.clear_cached_data()
	ROLE4_POISON_ARRAY_AWAKEN_EFFECT_SCRIPT.clear_cached_data()
	STREAMING_ROLE_BULLET_SCRIPT.clear_cached_frames()
	_resource_runtime.release_role_cached_resources()
	_combat_factory.clear_scene_caches()
	_projectile_factory.clear_scene_caches()
	_effect_factory.clear_scene_caches()


# 为下一次关卡加载建立租约；目标场景只记录，不作为租约拥有的资源释放。
func begin_level_resource_lease(target_scene: String) -> int:
	return _resource_runtime.begin_level_resource_lease(target_scene)


# 只释放本租约登记的路径；永久 UI 和未登记路径保持原缓存。
func release_level_resource_lease(lease_id: int = -1) -> int:
	return _resource_runtime.release_level_resource_lease(lease_id)


func _is_level_scene_warmed(path: String) -> bool:
	return _resource_runtime.is_level_scene_warmed(path)


func _mark_level_scene_warmed(path: String) -> void:
	_resource_runtime.mark_level_scene_warmed(path)


func _is_level_monster_prewarmed(monster_id: int) -> bool:
	return _resource_runtime.is_level_monster_prewarmed(monster_id)


func _mark_level_monster_prewarmed(monster_id: int) -> void:
	_resource_runtime.mark_level_monster_prewarmed(monster_id)


func _track_level_resource(path: String) -> void:
	_resource_runtime.track_level_resource(path)


func _track_level_scene_dependencies(scene_paths: Array) -> void:
	_resource_runtime.track_level_scene_dependencies(scene_paths)


func _append_png_files_recursive(paths: Array, root_path: String) -> void:
	var added_before := paths.size()
	var directories := DirAccess.get_directories_at(root_path)
	for file_name in DirAccess.get_files_at(root_path):
		if file_name.get_extension().to_lower() == "png":
			var path := root_path.path_join(file_name)
			if not paths.has(path):
				paths.append(path)
	for directory_name in directories:
		_append_png_files_recursive(paths, root_path.path_join(directory_name))
	if paths.size() == added_before and directories.is_empty():
		_append_numbered_png_files(paths, root_path)


func _append_numbered_png_files(paths: Array, root_path: String) -> void:
	var missing_streak := 0
	var found_any := false
	for index in range(601):
		var path := root_path.path_join(str(index) + ".png")
		if ResourceLoader.exists(path):
			if not paths.has(path):
				paths.append(path)
			found_any = true
			missing_streak = 0
		elif found_any:
			missing_streak += 1
			if missing_streak >= 30:
				break


func _append_unique_preload_path(paths: Array, path: String) -> void:
	if path != "" and not paths.has(path):
		paths.append(path)


func _collect_scene_texture_dependencies(scene_paths: Array) -> Array:
	var texture_paths: Array = []
	var visited: Dictionary = {}
	for scene_path_value in scene_paths:
		_collect_texture_dependencies_recursive(str(scene_path_value), texture_paths, visited)
	return texture_paths


func _dependency_resource_path(dependency: String) -> String:
	return _resource_runtime.get_dependency_resource_path(dependency)


func _collect_texture_dependencies_recursive(resource_path: String, texture_paths: Array, visited: Dictionary) -> void:
	if resource_path == "" or visited.has(resource_path) or not ResourceLoader.exists(resource_path):
		return
	visited[resource_path] = true
	for dependency in ResourceLoader.get_dependencies(resource_path):
		var dependency_path := _dependency_resource_path(str(dependency))
		var extension := dependency_path.get_extension().to_lower()
		if extension in ["png", "jpg", "jpeg", "webp", "svg"]:
			_append_unique_preload_path(texture_paths, dependency_path)
		elif extension in ["tscn", "tres", "res"]:
			_collect_texture_dependencies_recursive(dependency_path, texture_paths, visited)


func _collect_monster_bullet_scene_paths(monster_scene_paths: Array) -> Array:
	var result: Array = []
	for monster_scene_path_value in monster_scene_paths:
		var monster_scene_path := str(monster_scene_path_value)
		for bullet_scene_path in LevelPreloadStore.bullet_scenes(monster_scene_path):
			_append_unique_preload_path(result, bullet_scene_path)
	return result


func prewarm_monster_bullet_scene_paths(scene_paths: Array, generation: int = -1) -> void:
	var request_generation := _runtime_generation if generation < 0 else generation
	if not is_runtime_generation_current(request_generation):
		return
	var pending_paths: Array[String] = []
	for path_value in scene_paths:
		var path := str(path_value)
		if path == "" or _is_level_scene_warmed(path) or pending_paths.has(path):
			continue
		pending_paths.append(path)
	if pending_paths.is_empty():
		return
	_track_level_scene_dependencies(pending_paths)
	await _preload_paths_threaded(pending_paths, request_generation)
	if not is_runtime_generation_current(request_generation):
		return
	var texture_paths: Array = []
	var priority_texture_paths: Array = []
	for scene_path in pending_paths:
		var scene_texture_paths := _collect_scene_texture_dependencies([scene_path])
		for texture_path in scene_texture_paths:
			_append_unique_preload_path(texture_paths, str(texture_path))
			_track_level_resource(str(texture_path))
		for index in range(mini(4, scene_texture_paths.size())):
			_append_unique_preload_path(priority_texture_paths, str(scene_texture_paths[index]))
	await _preload_paths_threaded(texture_paths, request_generation)
	if not is_runtime_generation_current(request_generation):
		return
	var textures_per_frame := 2 if OS.has_feature("mobile") else 5
	await _warm_texture_rids_over_frames(priority_texture_paths, textures_per_frame, request_generation)
	if not is_runtime_generation_current(request_generation):
		return
	await _warm_scene_paths_over_frames(pending_paths, 1, request_generation)
	if not is_runtime_generation_current(request_generation):
		return
	for path in pending_paths:
		var scene := _resource_runtime.get_cached_packed_scene(path)
		if scene is PackedScene:
			_mark_level_scene_warmed(path)


func preload_damage_number_textures() -> void:
	# 13 组按伤害类型分组；其中 reduce_mp 与 cure_mp、physics 与 magic/physics、
	# realcrit 与 real 的内容完全相同，按需加载即可，不进入首次预载。
	var number_dirs: Array[String] = [
		"res://Art/all_number/cure/cure_",
		"res://Art/all_number/cure_mp/cure_mp_",
		"res://Art/all_number/physicscrit/physics_",
		"res://Art/all_number/magic/magic_",
		"res://Art/all_number/magic/physics_",
		"res://Art/all_number/magiccrit/magic_",
		"res://Art/all_number/real/real_",
		"res://Art/all_number/lj/lj_",
		"res://Art/all_number/monster/physics/physics_",
		"res://Art/all_number/monster/magic/magic_",
	]
	for prefix in number_dirs:
		for i in range(10):
			get_cached_texture(prefix + str(i) + ".png")


func _equipped_role_skill_names() -> Array[String]:
	var skill_data: Variant = PlayerData.player_data.get(DataKeys.SKILL_LEARNED, {})
	var skill_keys: Variant = skill_data.get("技能键位", {}) if skill_data is Dictionary else {}
	var names: Array[String] = []
	if skill_keys is Dictionary:
		for value in (skill_keys as Dictionary).values():
			names.append(str(value))
	return names


func _append_numbered_resource_paths(
	paths: Array[String], path_format: String, count: int, start: int = 0, step: int = 1
) -> void:
	var index := start
	for unused in range(count):
		var path := path_format % index
		if ResourceLoader.exists(path):
			paths.append(path)
		index += step


func _append_role_runtime_paths(out: Array[String], paths: PackedStringArray) -> void:
	for path in paths:
		out.append(path)


func _append_conditional_paths(
	out: Array[String], entries: Dictionary[String, PackedStringArray], equipped_skills: Array[String]
) -> void:
	for skill in equipped_skills:
		if not entries.has(skill):
			continue
		for path in entries[skill]:
			if not out.has(path):
				out.append(path)


func _fashion_texture_paths() -> Array[String]:
	var paths: Array[String] = []
	var fashions: Variant = PlayerData.player_data.get(DataKeys.FASHION, [])
	if (
		fashions is Array
		and not fashions.is_empty()
		and str((fashions as Array)[0].get(DataKeys.NAME, "")) == "shenqismsrsz"
	):
		_append_numbered_resource_paths(paths, "res://Art/hero_picture/smsr_shenqi_lightning/lightning/d_%05d.png", 9)
		_append_numbered_resource_paths(
			paths, "res://Art/hero_picture/smsr_shenqi_lightning/hit_mesh/hit_%05d.png", 10, 0, 2
		)
	return paths


func prewarm_sprite_frames_paths(paths: Array[String], generation: int = -1) -> void:
	await _preload_paths_threaded(paths, generation)


func prewarm_texture_paths(paths: Array[String], generation: int = -1) -> void:
	await _preload_paths_threaded(paths, generation)


func get_current_role_preload_paths() -> Array[String]:
	var manifest := RoleRuntimeCatalog.get_manifest(_role_visual.current_role_id())
	if manifest == null:
		push_error("角色运行资源清单缺失，跳过预载路径收集")
		return []
	var runtime_paths: Array[String] = []
	var equipped_skills := _equipped_role_skill_names()
	_append_role_runtime_paths(runtime_paths, manifest.scene_paths)
	_append_role_runtime_paths(runtime_paths, manifest.sprite_frames_paths)
	_append_role_runtime_paths(runtime_paths, manifest.texture_paths)
	_append_role_runtime_paths(runtime_paths, manifest.audio_paths)
	_append_conditional_paths(runtime_paths, manifest.conditional_scene_paths, equipped_skills)
	_append_conditional_paths(runtime_paths, manifest.conditional_sprite_frames_paths, equipped_skills)
	runtime_paths.append_array(_fashion_texture_paths())
	return runtime_paths


func prewarm_current_role_runtime_resources(role_id: int = 0, generation: int = -1) -> void:
	var request_generation := _runtime_generation if generation < 0 else generation
	if not is_runtime_generation_current(request_generation):
		return
	if role_id <= 0:
		role_id = _role_visual.current_role_id()
	if _prewarmed_role_id == role_id:
		return
	if _prewarmed_role_id > 0:
		release_role_runtime_resources()
	var manifest := RoleRuntimeCatalog.get_manifest(role_id)
	if manifest == null:
		push_error("角色运行资源清单缺失，跳过角色资源预热: %d" % role_id)
		return
	var equipped_skills := _equipped_role_skill_names()
	var scene_paths: Array[String] = []
	var sprite_frames_paths: Array[String] = []
	var texture_paths: Array[String] = []
	var audio_paths: Array[String] = []
	_append_role_runtime_paths(scene_paths, manifest.scene_paths)
	_append_role_runtime_paths(sprite_frames_paths, manifest.sprite_frames_paths)
	_append_role_runtime_paths(texture_paths, manifest.texture_paths)
	_append_role_runtime_paths(audio_paths, manifest.audio_paths)
	_append_conditional_paths(scene_paths, manifest.conditional_scene_paths, equipped_skills)
	_append_conditional_paths(sprite_frames_paths, manifest.conditional_sprite_frames_paths, equipped_skills)
	texture_paths.append_array(_fashion_texture_paths())
	var preload_paths := scene_paths.duplicate()
	preload_paths.append_array(sprite_frames_paths)
	preload_paths.append_array(texture_paths)
	preload_paths.append_array(audio_paths)
	await _preload_paths_threaded(preload_paths, request_generation)
	if not is_runtime_generation_current(request_generation):
		return
	await _warm_scene_paths_over_frames(scene_paths, 1, request_generation)
	if not is_runtime_generation_current(request_generation):
		return
	await prewarm_sprite_frames_paths(sprite_frames_paths, request_generation)
	if not is_runtime_generation_current(request_generation):
		return
	await prewarm_texture_paths(texture_paths, request_generation)
	if not is_runtime_generation_current(request_generation):
		return
	await _warm_audio_streams_over_frames(audio_paths, 2, request_generation)
	if not is_runtime_generation_current(request_generation):
		return
	if role_id == 2 and equipped_skills.has("by"):
		BING_YU_EFFECT_SCRIPT.prewarm_frames()
		var tree := get_tree()
		if tree == null:
			return
		await tree.process_frame
		if not is_runtime_generation_current(request_generation):
			return
	if role_id == 1 and (equipped_skills.has("hmz") or equipped_skills.has("hmz_ws")):
		_combat_factory.preload_special_effect_bullet()
	var awakened: Dictionary = PlayerData.player_data.get(DataKeys.Skill.AWAKENED, {})
	var awaken_enabled: Dictionary = PlayerData.player_data.get(DataKeys.Skill.AWAKENED_ENABLED, {})
	if role_id == 1:
		if equipped_skills.has("lyfb") and bool(awakened.get("lyfb", false)) and bool(awaken_enabled.get("lyfb", true)):
			LYFB_AWAKEN_EFFECT_SCRIPT.preload_effect_data()
		if (
			equipped_skills.has("hmz_ws")
			and bool(awakened.get("hmz_ws", false))
			and bool(awaken_enabled.get("hmz_ws", true))
		):
			HMZ_AWAKEN_EFFECT_SCRIPT.preload_effect_data()
	elif role_id == 4:
		if equipped_skills.has("cmly"):
			CANG_MU_LONG_YUN_EFFECT_SCRIPT.preload_effect_data()
		if equipped_skills.has("bylt"):
			BI_LUO_TIAN_EFFECT_SCRIPT.prewarm_frames()
	if role_id == 5 and equipped_skills.has("ltjz"):
		LEI_TING_JIE_ZHEN_EFFECT_SCRIPT.prewarm_frames()
	if not is_runtime_generation_current(request_generation):
		return
	_prewarmed_role_id = role_id


func _role_id_from_runtime_node(role: Variant) -> int:
	if is_instance_valid(role) and role is Node:
		var role_script := (role as Node).get_script() as Script
		var script_path := role_script.resource_path if role_script != null else ""
		match script_path:
			"res://Script/hero/role1.gd":
				return 1
			"res://Script/hero/role_2.gd":
				return 2
			"res://Script/hero/role_3.gd":
				return 3
			"res://Script/hero/role_4.gd":
				return 4
			"res://Script/hero/role_5.gd":
				return 5
			"res://Script/hero/ne_zha_hero.gd":
				return 6
			"res://Script/hero/yutu_hero.gd":
				return 7
			"res://Script/hero/longnv_hero.gd":
				return 8
	return clampi(int(PlayerData.player_data.get("Myself", 1)), 1, 8)


func _cached_scene(property_name: StringName, path: String) -> PackedScene:
	var scene = get(property_name) as PackedScene
	if scene == null:
		scene = _load_scene(path) as PackedScene
		set(property_name, scene)
	return scene


func preload_next(path: String) -> void:
	_resource_runtime.preload_next(path)


func clear_preloaded_scene_slot() -> void:
	_resource_runtime.clear_preloaded_scene_slot()


func add_basic_ar_button(parent, Num):
	return _menu_panel_factory.add_basic_ar_button(parent, Num)


func add_zhen_fa_help(parent, position):
	return _zhen_fa.add_help(parent, position)


func add_zhen_fa_tu_po(parent, position, father):
	return _zhen_fa.add_tu_po(parent, position, father)


func add_zhen_yan_cure_level(parent, position, father):
	return _zhen_fa.add_cure_level(parent, position, father)


func addzhenyanbutton(parent, position, loc_num, father):
	return _zhen_fa.add_eye_button(parent, position, loc_num, father)


func add_zhen_fa_info(parent, position, father):
	return _zhen_fa.add_info(parent, position, father)


func add_zhenfalxbutton(parent, zhenfa_name, father):
	return _zhen_fa.add_lx_button(parent, zhenfa_name, father)


func addhdgqmap(parent, position):
	return _menu_panel_factory.add_return_back_map(parent, position)


func add_monster141_aura(parent, _position, target_monster):
	return _effect_factory.add_monster141_aura(parent, _position, target_monster)


func addlhhjhelp(parent, position):
	return _menu_panel_factory.add_lhhj_help(parent, position)


func addlistbutton(parent, self_name, father, Num):
	return _menu_panel_factory.add_list_button(parent, self_name, father, Num)


func addlhhj(parent, position):
	return _menu_panel_factory.add_lhhj(parent, position)


func addlhhjbutton(parent, self_name, father):
	return _menu_panel_factory.add_lhhj_button(parent, self_name, father)


func add_some_monster_help(parent, position):
	return _show_text_factory.add_some_monster_help(parent, position)


func add_mosaic_help(parent, position):
	return _menu_panel_factory.add_mosaic_help(parent, position)


func add_letter_for_player(parent, position):
	return _show_text_factory.add_letter_for_player(parent, position)


func add_cure_times_box(parent, position):
	return _shop_factory.add_cure_times_box(parent, position)


func add_mystery_shop(parent, position):
	return _shop_factory.add_mystery_shop(parent, position)


func add_trans_box(parent, _name, transmogrified):
	return _shop_factory.add_trans_box(parent, _name, transmogrified)


func add_role4_bullet(parent, Player, position: Vector2):
	return _projectile_factory.add_role4_bullet(parent, Player, position)


func add_line(parent, Monster, Type):
	return _effect_factory.add_line(parent, Monster, Type)


func add_dsg_choose(parent):
	return _level_scene_factory.add_dsg_choose(parent)


func add_hdzm(parent, parent_node):
	return _map_overlay_factory.add_hdzm(parent, parent_node)


func add_lsh(parent, parent_node):
	return _map_overlay_factory.add_lsh(parent, parent_node)


func add_lxdy(parent, parent_node):
	return _map_overlay_factory.add_lxdy(parent, parent_node)


func add_monster_info(parent, monster_name, position):
	return _monster_display.add_monster_info(parent, monster_name, position)


func add_basic_monment_info(parent, show_text, position):
	return _monster_display.add_basic_moment_info(parent, show_text, position)


func add_forge_help(parent, position):
	return _forge_factory.add_help(parent, position)


func add_forges(parent, position):
	return _forge_factory.add_forges(parent, position)


func addllbt_challenge(parent, position):
	return _level_scene_factory.add_llbt_challenge(parent, position)


func add_basic_pellet(parent, position):
	return _projectile_factory.add_basic_pellet(parent, position)


func add_game_announcement(parent, position):
	return _popup_factory.add_game_announcement(parent, position)


func add_font_instance(parent, show_text, font, font_size, font_color, out_line_size, out_line_color):
	return _show_text_factory.add_font_instance(
		parent, show_text, font, font_size, font_color, out_line_size, out_line_color
	)


func add_task_reward(parent, ItemName, total_num):
	return _reward_factory.add_task_reward(parent, ItemName, total_num)


func add_basic_task(parent, position):
	return _reward_factory.add_basic_task(parent, position)


func add_task_title(parent, task_type, task_name, my_father):
	return _show_text_factory.add_task_title(parent, task_type, task_name, my_father)


func configure_backpack_role_preview(page: Node, player: Variant = null) -> void:
	if page == null or not is_instance_valid(page):
		return
	var valid_player: Variant = player if is_instance_valid(player) else null
	var role_id := _role_id_from_runtime_node(valid_player)
	var role_body := page.get_node_or_null("background/RoleBody") as Sprite2D
	var role_equipment := page.get_node_or_null("background/RoleEquipment") as Sprite2D
	var role_body_front := page.get_node_or_null("background/RoleBodyFront") as Sprite2D
	if role_id == 7:
		preload("res://Script/hero/yutu_visuals.gd").preview(role_body, role_equipment, role_body_front, 0.0)
		return
	if role_id == 8:
		preload("res://Script/hero/longnv_visuals.gd").preview(role_body, role_equipment, role_body_front, 0.0)
		return
	if role_id == 6:
		if role_body != null:
			role_body.texture = RoleVisualRuntime.static_preview_texture(NeZhaEquipmentVisuals.get_body_frames("Empty"))
		if role_equipment != null:
			role_equipment.texture = RoleVisualRuntime.static_preview_texture(
				NeZhaEquipmentVisuals.get_weapon_frames("Empty")
			)
		return
	if role_body != null:
		var body_path := "res://Art/hero_picture/role_%d_all_equipment/role_%d_body_empty.png" % [role_id, role_id]
		if ResourceLoader.exists(body_path):
			role_body.texture = (
				ResourceLoader.load(body_path, "Texture2D", ResourceLoader.CACHE_MODE_IGNORE) as Texture2D
			)
	if role_equipment != null:
		var equipment_path := "res://Art/hero_picture/role_%d_all_equipment/role_%d_eq_empty.png" % [role_id, role_id]
		if ResourceLoader.exists(equipment_path):
			role_equipment.texture = (
				ResourceLoader.load(equipment_path, "Texture2D", ResourceLoader.CACHE_MODE_IGNORE) as Texture2D
			)


func screen_popup_position(offset := Vector2(25, 20)) -> Vector2:
	return get_viewport().get_mouse_position() + offset


func apply_popup_screen_layout(node: Node, position: Vector2, estimated_size := Vector2(240, 240)) -> void:
	if not (node is CanvasItem):
		return
	var canvas_item := node as CanvasItem
	var size := PopupLayout.resolved_size(canvas_item, estimated_size)
	PopupLayout.place_screen(canvas_item, position, size, PopupLayout.DEFAULT_MARGIN, true)


func popup_position_for_parent(parent_node: Node, offset := Vector2(25, 20)) -> Vector2:
	var mouse_pos = get_tree().get_root().get_mouse_position() + offset
	if parent_node is CanvasItem:
		return (parent_node as CanvasItem).get_global_transform().affine_inverse() * mouse_pos
	return mouse_pos


func viewport_center_for_parent(parent_node: Node) -> Vector2:
	var center = get_viewport().get_visible_rect().size * 0.5
	if parent_node is CanvasItem:
		return (parent_node as CanvasItem).get_global_transform().affine_inverse() * center
	return center


func add_reward_info(parent, position, list, use_item_name, use_num, claim_callable: Callable = Callable()):
	return _reward_factory.add_reward_info(parent, position, list, use_item_name, use_num, claim_callable)


func add_reward_box(parent, item_id, num):
	return _reward_factory.add_reward_box(parent, item_id, num)


func add_decompose_help(parent, position):
	return _forge_factory.add_decompose_help(parent, position)


func add_decompose_instance(parent, position):
	return _forge_factory.add_decompose(parent, position)


func add_zztw_trap(parent, Name, position):
	return _level_scene_factory.add_trap(parent, Name, position)


func add_stage(parent, stage_type: String, position: Vector2):
	return _level_scene_factory.add_stage(parent, stage_type, position)


func add_boss_blood_instance(parent, Obj):
	return _combat_factory.add_boss_blood_instance(parent, Obj)


func add_hc_help(parent, position):
	return _level_hint.add_hc_help(parent, position)


func add_help_thing(parent, position, item_info):
	return _level_hint.add_help_thing(parent, position, item_info)


func add_pj(parent, position, Num):
	return _show_text_factory.add_ping_jia(parent, position, Num)


func get_current_level_fall_pro(default_pro: float) -> float:
	return _level_entry.get_current_level_fall_pro(default_pro)


func sync_level_drop_pro_data(level_info: Dictionary) -> void:
	_level_entry.sync_drop_pro_data(level_info)


## 关卡进入前的模式复位：四个无尽模式标志与八仙选择。
## 标志仍归 Global 所有（关卡脚本直接读取），此处保持单一写入口。
func apply_level_entry_mode_reset(target_path: String) -> void:
	_run_context.set_special_dungeon_endless(target_path, false)
	if target_path == "res://Scene/level/level_bxgh.tscn":
		_run_context.set_selected_eight_immortal_id(0)


func add_level_info(parent, Name, position, path):
	return _level_entry.add_level_info(parent, Name, position, path)


func add_monster_head(parent, Name, is_boss, ScenePath := ""):
	return _monster_display.add_monster_head(parent, Name, is_boss, ScenePath)


func add_level_fall_box(parent, Inldl, Inhhgz, Name, qh_level, wx, EqProp):
	return _level_hint.add_level_fall_box(parent, Inldl, Inhhgz, Name, qh_level, wx, EqProp)


func add_item_box(parent, Inldl, Inhhgz, Name, qh_level, num, wx, EqProp):
	return _level_hint.add_item_box(parent, Inldl, Inhhgz, Name, qh_level, num, wx, EqProp)


func add_game_need_know(parent, position):
	return _level_hint.add_game_need_know(parent, position)


func add_new_bullet(parent, position, dir, _name, dic):
	return _projectile_factory.add_new_bullet(parent, position, dir, _name, dic)


func add_smb_effect(parent, position, dir):
	return _effect_factory.add_smb_effect(parent, position, dir)


func add_role2_shallow(parent, position, dir):
	return _effect_factory.add_role2_shallow(parent, position, dir)


func add_role_special_effect(parent, position, dir, _name):
	return _effect_factory.add_role_special_effect(parent, position, dir, _name)


## 角色侧攻击载体统一写来源：显式来源优先，其次沿父级持有者回溯。
## 根节点创建的弹体（如反弹爆炸）必须由调用方传入来源，不能再依赖全局 1P 别名。
func _assign_attack_source(target: Node, parent: Node, source_player: BaseHero = null) -> void:
	if target == null or not is_instance_valid(target):
		return
	var resolved: BaseHero = source_player
	if not is_instance_valid(resolved):
		resolved = LocalCoop.owner_hero(parent) as BaseHero
	if not is_instance_valid(resolved):
		return
	target.set("player", resolved)
	target.set_meta("coop_slot", LocalCoop.slot_for(resolved))


func add_role_bullet(parent, position, dir, _name, dic, source_player: BaseHero = null):
	return _projectile_factory.add_role_bullet(parent, position, dir, _name, dic, source_player)


func add_monster65_bullet(parent, _position):
	return _projectile_factory.add_monster65_bullet(parent, _position)


func add_aura(parent, _position, value_in, color_type = 0):
	return _effect_factory.add_aura(parent, _position, value_in, color_type)


func add_buffinfor(parent, _position, Data):
	return _popup_factory.add_buff_information(parent, _position, Data)


func add_buff_icon(parent, Data):
	return _combat_factory.add_buff_icon(parent, Data)


func is_monster_control_buff(buff_name: Variant) -> bool:
	return str(buff_name) in MONSTER_CONTROL_BUFF_NAMES


func clear_white_bar_control_buffs(container: Node) -> void:
	if not is_instance_valid(container):
		return
	for item in container.get_children():
		if (
			item is BaseBuff
			and not item.is_queued_for_deletion()
			and (
				is_monster_control_buff(item.buff_info.get("Name", ""))
				or item.buff_info.get("Name", "") == "hanxiangzisleep"
			)
		):
			item.set_physics_process(false)
			item.remove_buff()


func add_buff(parent, buff_info):
	return _combat_factory.add_buff(parent, buff_info)


func add_after_level_end(parent, position):
	return _reward_factory.add_after_level_end(parent, position)


func add_combo(parent, combo_num_, position):
	return _popup_factory.add_combo(parent, combo_num_, position)


func add_combo_num(parent, combo_num_):
	return _popup_factory.add_combo_num(parent, combo_num_)


func add_z_lw_stage(parent, position, speed, dir, max_num, pd):
	return _level_scene_factory.add_fly_stage(parent, position, speed, dir, max_num, pd)


func add_h_hjm(parent, position):
	return _backpack_factory.add_h_hjm(parent, position)


func add_miss_effect(parent, position):
	return _combat_factory.add_miss_effect(parent, position)


func add_damage_number(parent, value, type_: String, is_crit: bool, tar):
	return _combat_factory.add_damage_number(parent, value, type_, is_crit, tar)


func set_damage_text_enabled(enabled: bool) -> void:
	MainSet.set_data["ShowDamageText"] = enabled
	if enabled:
		return
	_combat_pool.release_all_damage_texts()


func add_damage_text(parent, position, value, type_: String, is_crit: bool, tar):
	return _combat_factory.add_damage_text(parent, position, value, type_, is_crit, tar)


func add_role1_shallow(parent, position, dir, int_action, source_player: BaseHero = null):
	return _effect_factory.add_role1_shallow(parent, position, dir, int_action, source_player)


func add_role_bullet_1(parent, position, _name, dic, source_player: BaseHero = null):
	return _projectile_factory.add_role_bullet_1(parent, position, _name, dic, source_player)


func add_skill_key_set(parent, position, _name):
	return _menu_panel_factory.add_skill_key_set(parent, position, _name)


func add_game_set(parent, position):
	return _menu_panel_factory.add_game_set(parent, position)


func add_mosaic_instance(parent, position):
	return _menu_panel_factory.add_mosaic_instance(parent, position)


func add_magic_help(parent, position):
	return _skill_panel_factory.add_magic_help(parent, position)


func add_use_magic_weapon(parent, position):
	return _backpack_factory.add_use_magic_weapon(parent, position)


func add_skill_select(parent, position, _name):
	return _backpack_factory.add_skill_select(parent, position, _name)


func add_weapon_bullet(parent, position, _name, list, dir, Rand):
	return _projectile_factory.add_weapon_bullet(parent, position, _name, list, dir, Rand)


func get_active_pet_preload_data(slot: int = 1) -> Dictionary:
	var profile: Node = LocalCoop.data_for_slot(2 if slot == 2 else 1)
	if profile.has_method("ensure_pet_dragon"):
		profile.ensure_pet_dragon()
	if profile.has_method("ensure_pet_phoenix"):
		profile.ensure_pet_phoenix()
	if profile.has_method("ensure_pet_turtle"):
		profile.ensure_pet_turtle()
	if profile.has_method("ensure_pet_rabbit"):
		profile.ensure_pet_rabbit()
	if profile.has_method("ensure_pet_mouse"):
		profile.ensure_pet_mouse()
	if profile.has_method("ensure_pet_nian"):
		profile.ensure_pet_nian()
	if profile.has_method("ensure_pet_neat"):
		profile.ensure_pet_neat()
	if profile.has_method("ensure_pet_yin_tiger"):
		profile.ensure_pet_yin_tiger()
	var pets: Variant = profile.player_data.get(PlayerData.PET_LIST_KEY, [])
	if not (pets is Array):
		return {}
	var active_name := str(profile.player_data.get(PlayerData.ACTIVE_PET_KEY, ""))
	var selected_pet: Dictionary = {}
	var selected_type := ""
	for pet in pets:
		if not (pet is Dictionary) or not bool(pet.get(DataKeys.DEPLOYED, false)):
			continue
		var type_name := str(pet.get(DataKeys.TYPE, ""))
		var pet_name := str(pet.get(DataKeys.ALT_NAME, ""))
		if type_name == "PetNian":
			selected_pet = pet
			selected_type = "PetNian"
			break
		var is_dragon := (
			type_name == "PetDragon" or pet_name.begins_with("辰龙") or pet_name in ["龙仔", "绿英龙", "青龙将军", "青龙妖圣"]
		)
		var is_tiger := type_name == "PetTiger" or pet_name in ["虎丸", "白灵虎", "白虎将军", "白虎战神", "白虎"]
		var is_phoenix := (
			type_name == "PetPhoenix"
			or pet_name.begins_with("朱雀")
			or pet_name in ["雀蛋", "炎皇雀", "朱雀将军", "朱雀女皇", "朱雀幼灵", "赤羽朱雀", "朱雀神君"]
		)
		var is_turtle := (
			type_name == "PetTurtle" or pet_name.begins_with("玄武") or pet_name in ["龟布", "墨玄龟", "玄武将军", "玄武大帝"]
		)
		var is_rabbit := type_name == "PetRabbit" or pet_name in ["月兔", "疾风兔", "寒冰玉兔", "冰霜月神"]
		var is_mouse := type_name == "PetMouse" or pet_name.begins_with("子鼠") or pet_name in ["子鼠元帅", "子鼠大元帅"]
		var is_neat := type_name == "PetNeat" or pet_name in ["丑牛", "丑牛元帅", "丑牛大元帅"]
		var is_yin_tiger := type_name == "PetYinTiger" or pet_name in ["寅虎", "银角虎", "寅虎元帅", "寅虎大元帅"]
		if (
			not is_dragon
			and not is_tiger
			and not is_phoenix
			and not is_turtle
			and not is_rabbit
			and not is_mouse
			and not is_neat
			and not is_yin_tiger
		):
			continue
		var pet_type := (
			"PetYinTiger"
			if is_yin_tiger
			else (
				"PetNeat"
				if is_neat
				else (
					"PetMouse"
					if is_mouse
					else (
						"PetRabbit"
						if is_rabbit
						else (
							"PetTurtle"
							if is_turtle
							else "PetPhoenix" if is_phoenix else "PetDragon" if is_dragon else "PetTiger"
						)
					)
				)
			)
		)
		if selected_pet.is_empty():
			selected_pet = pet
			selected_type = pet_type
		if active_name == "" or active_name == pet_type or active_name == pet_name:
			selected_pet = pet
			selected_type = pet_type
			break
	if selected_pet.is_empty():
		return {}
	var stage := int(selected_pet.get("阶段", 0))
	var pet_level := int(selected_pet.get(DataKeys.LEVEL, 1))
	if selected_type == "PetMouse":
		stage = 2 if pet_level >= 50 else 1
	elif stage <= 0:
		stage = 4 if pet_level >= 50 else 3 if pet_level >= 30 else 2 if pet_level >= 15 else 1
	return {
		"type": selected_type,
		"stage": clampi(stage, 1, 2) if selected_type == "PetMouse" else clampi(stage, 1, 4),
		"level": pet_level,
	}


func get_active_pet_preload_paths(slot: int = 1) -> Array[String]:
	var pet_info := get_active_pet_preload_data(slot)
	var pet_type := str(pet_info.get("type", ""))
	if pet_type == "":
		return []
	var stage := (
		clampi(int(pet_info.get("stage", 1)), 1, 2)
		if pet_type == "PetMouse"
		else clampi(int(pet_info.get("stage", 1)), 1, 4)
	)
	var pet_level := int(pet_info.get("level", 1))
	if pet_type == "PetYinTiger":
		var source_stage := 2 if stage >= 4 else 1
		var yin_paths: Array[String] = [
			"res://Scene/pet/pet_yin_tiger_summon_%d.tscn" % stage,
			(
				"res://Art/pet/pet_yin_tiger/model/actions/stage%d/yin_tiger_stage%d_frames.tres"
				% [source_stage, source_stage]
			),
			"res://Scene/pet/pet_yin_tiger_bullet.tscn",
			"res://Art/pet/pet_yin_tiger/effects/pet_yin_tiger_1_bullet_1/pet_yin_tiger_1_bullet_1_frames.tres",
			"res://Art/pet/pet_yin_tiger/effects/pet_yin_tiger_1_bullet_2/pet_yin_tiger_1_bullet_2_frames.tres",
			"res://Art/pet/pet_yin_tiger/model/actions/stage%d/wait/1.png" % source_stage,
			"res://Art/pet/skillicon/hx.png",
		]
		if stage >= 4:
			yin_paths.append("res://Art/pet/skillicon/mhxs.png")
			yin_paths.append("res://Art/pet/skillicon/yhaoyi.png")
			yin_paths.append(
				"res://Art/pet/pet_yin_tiger/effects/pet_yin_tiger_1_bullet_3/pet_yin_tiger_1_bullet_3_frames.tres"
			)
		return yin_paths
	if pet_type == "PetNian":
		return [
			"res://Scene/pet/pet_nian_summon_%d.tscn" % stage,
			"res://Art/pet/pet_nian/model/pet_nian_stage%d_frames.tres" % stage,
			"res://Art/pet/pet_nian/icons/head%d.png" % stage,
		]
	if pet_type == "PetNeat":
		return (
			[
				"res://Scene/pet/pet_neat_summon_%d.tscn" % stage,
				"res://Art/pet/pet_neat/model/pet_neat_stage%d_frames.tres" % stage,
				"res://Scene/pet/pet_neat_bullet.tscn",
				"res://Art/pet/pet_neat/model/actions/stage%d/wait/tou_xiang.png" % stage,
				"res://Art/pet/skillicon/mncz.png",
			]
			+ (["res://Art/pet/skillicon/mljt.png"] if stage >= 3 else [])
			+ (["res://Art/pet/skillicon/cnaoyi.png"] if stage >= 4 else [])
		)
	if pet_type == "PetMouse":
		var mouse_paths: Array[String] = [
			"res://Scene/pet/pet_mouse_summon_%d.tscn" % stage,
			"res://Art/pet/pet_mouse/model/pet_mouse_stage%d_frames.tres" % stage,
			"res://Scene/pet/pet_mouse_bullet.tscn",
			"res://Art/pet/pet_mouse/model/actions/stage%d/wait/head.png" % stage,
			"res://Art/pet/skillicon/sc.png",
		]
		if pet_level >= 30:
			mouse_paths.append("res://Art/pet/skillicon/hxfb.png")
		if pet_level >= 50:
			mouse_paths.append("res://Art/pet/skillicon/aoyi.png")
		return mouse_paths
	if pet_type == "PetTiger":
		var tiger_paths: Array[String] = [
			"res://Scene/pet/pet_tiger_summon_%d.tscn" % stage,
			"res://Art/pet/pet_tiger/model/pet_tiger_stage%d_frames.tres" % stage,
			"res://Scene/pet/pet_tiger_bullet.tscn",
			"res://Art/pet/pet_tiger/model/actions/stage%d/wait/icon.png" % stage,
			"res://Art/pet/skillicon/hy.png",
		]
		if stage >= 2:
			tiger_paths.append("res://Art/pet/skillicon/sxhz.png")
		if stage >= 3:
			tiger_paths.append("res://Art/pet/skillicon/hsqj.png")
		if stage >= 4:
			tiger_paths.append("res://Art/pet/skillicon/aoyi.png")
		return tiger_paths
	if pet_type == "PetPhoenix":
		var phoenix_paths: Array[String] = [
			"res://Scene/pet/pet_phoenix_summon_%d.tscn" % stage,
			"res://Art/pet/pet_phoenix/model/pet_phoenix_stage%d_frames.tres" % stage,
			"res://Art/pet/pet_phoenix/model/actions/stage%d/wait/头像.png" % stage,
			"res://Art/pet/skillicon/np.png",
		]
		if stage >= 2:
			phoenix_paths.append("res://Art/pet/skillicon/bshn.png")
		if stage >= 3:
			phoenix_paths.append("res://Art/pet/skillicon/dhly.png")
		if stage >= 4:
			phoenix_paths.append("res://Art/pet/skillicon/aoyi.png")
		return phoenix_paths
	if pet_type == "PetTurtle":
		var turtle_paths: Array[String] = [
			"res://Scene/pet/pet_turtle_summon_%d.tscn" % stage,
			"res://Art/pet/pet_turtle/model/pet_turtle_stage%d_frames.tres" % stage,
			"res://Scene/pet/pet_turtle_bullet.tscn",
			"res://Art/pet/pet_turtle/model/actions/stage%d/wait/tou_xiang.png" % stage,
			"res://Art/pet/skillicon/sld.png",
		]
		if stage >= 2:
			turtle_paths.append("res://Art/pet/skillicon/txlj.png")
		if stage >= 3:
			turtle_paths.append("res://Art/pet/skillicon/sybh.png")
		if stage >= 4:
			turtle_paths.append("res://Art/pet/skillicon/aoyi.png")
		return turtle_paths
	if pet_type == "PetRabbit":
		var rabbit_paths: Array[String] = [
			"res://Scene/pet/pet_rabbit_summon_%d.tscn" % stage,
			"res://Art/pet/pet_rabbit/model/pet_rabbit_stage%d_frames.tres" % stage,
			"res://Scene/pet/pet_rabbit_bullet.tscn",
			"res://Art/pet/pet_rabbit/model/actions/stage%d/wait/tou_xiang.png" % stage,
			"res://Art/pet/skillicon/yg.png",
		]
		if stage >= 2:
			rabbit_paths.append("res://Art/pet/skillicon/jf.png")
		if stage >= 3:
			rabbit_paths.append("res://Art/pet/skillicon/bs.png")
		if stage >= 4:
			rabbit_paths.append("res://Art/pet/skillicon/aoyi.png")
		return rabbit_paths
	var paths: Array[String] = [
		"res://Scene/pet/pet_dragon_summon_%d.tscn" % stage,
		"res://Art/pet/pet_dragon/model/pet_dragon_stage%d_frames.tres" % stage,
		"res://Scene/pet/pet_dragon_bullet.tscn",
		"res://Art/pet/pet_dragon/model/actions/stage%d/wait/头像.png" % stage,
		"res://Art/pet/skillicon/fs.png",
	]
	if stage >= 2:
		paths.append("res://Art/pet/skillicon/sdcc.png")
	if stage >= 3:
		paths.append("res://Art/pet/skillicon/ltwj.png")
	if stage >= 4:
		paths.append("res://Art/pet/skillicon/aoyi.png")
	return paths


func _preload_sprite_frames_resource(path: String) -> void:
	var frames := _resource_runtime.get_cached_sprite_frames(path)
	if frames == null:
		frames = ResourceLoader.load(path, "SpriteFrames", ResourceLoader.CACHE_MODE_REUSE) as SpriteFrames
		if frames != null:
			_resource_runtime.cache_threaded_resource(path, frames)


func prewarm_active_pet_runtime_resources(slot: int = 1, phase_marks: Array = []) -> void:
	var request_generation := _runtime_generation
	if not is_runtime_generation_current(request_generation):
		return
	var safe_slot := 2 if slot == 2 else 1
	var pet_info := get_active_pet_preload_data(safe_slot)
	var pet_type := str(pet_info.get("type", ""))
	if pet_type == "":
		return
	var stage := (
		clampi(int(pet_info.get("stage", 1)), 1, 2)
		if pet_type == "PetMouse"
		else clampi(int(pet_info.get("stage", 1)), 1, 4)
	)
	var pet_level := int(pet_info.get("level", 1))
	var mouse_skill_tier := 50 if pet_level >= 50 else 30 if pet_level >= 30 else 1
	var pet_signature := (
		"%s:%d:%d" % [pet_type, stage, mouse_skill_tier] if pet_type == "PetMouse" else "%s:%d" % [pet_type, stage]
	)
	if pet_signature == str(_prewarmed_pet_signatures.get(safe_slot, "")):
		return
	var scene_path := ""
	var frames_path := ""
	var bullet_scene_path := ""
	if pet_type == "PetYinTiger":
		var source_stage := 2 if stage >= 4 else 1
		scene_path = "res://Scene/pet/pet_yin_tiger_summon_%d.tscn" % stage
		frames_path = (
			"res://Art/pet/pet_yin_tiger/model/actions/stage%d/yin_tiger_stage%d_frames.tres"
			% [source_stage, source_stage]
		)
		bullet_scene_path = "res://Scene/pet/pet_yin_tiger_bullet.tscn"
	elif pet_type == "PetNian":
		scene_path = "res://Scene/pet/pet_nian_summon_%d.tscn" % stage
		frames_path = "res://Art/pet/pet_nian/model/pet_nian_stage%d_frames.tres" % stage
	elif pet_type == "PetNeat":
		scene_path = "res://Scene/pet/pet_neat_summon_%d.tscn" % stage
		frames_path = "res://Art/pet/pet_neat/model/pet_neat_stage%d_frames.tres" % stage
		bullet_scene_path = "res://Scene/pet/pet_neat_bullet.tscn"
	elif pet_type == "PetMouse":
		scene_path = "res://Scene/pet/pet_mouse_summon_%d.tscn" % stage
		frames_path = "res://Art/pet/pet_mouse/model/pet_mouse_stage%d_frames.tres" % stage
		bullet_scene_path = "res://Scene/pet/pet_mouse_bullet.tscn"
	elif pet_type == "PetTiger":
		scene_path = "res://Scene/pet/pet_tiger_summon_%d.tscn" % stage
		frames_path = "res://Art/pet/pet_tiger/model/pet_tiger_stage%d_frames.tres" % stage
		bullet_scene_path = "res://Scene/pet/pet_tiger_bullet.tscn"
	elif pet_type == "PetPhoenix":
		scene_path = "res://Scene/pet/pet_phoenix_summon_%d.tscn" % stage
		frames_path = "res://Art/pet/pet_phoenix/model/pet_phoenix_stage%d_frames.tres" % stage
		bullet_scene_path = "res://Scene/pet/pet_tiger_bullet.tscn"
	elif pet_type == "PetTurtle":
		scene_path = "res://Scene/pet/pet_turtle_summon_%d.tscn" % stage
		frames_path = "res://Art/pet/pet_turtle/model/pet_turtle_stage%d_frames.tres" % stage
		bullet_scene_path = "res://Scene/pet/pet_turtle_bullet.tscn"
	elif pet_type == "PetRabbit":
		scene_path = "res://Scene/pet/pet_rabbit_summon_%d.tscn" % stage
		frames_path = "res://Art/pet/pet_rabbit/model/pet_rabbit_stage%d_frames.tres" % stage
		bullet_scene_path = "res://Scene/pet/pet_rabbit_bullet.tscn"
	else:
		scene_path = "res://Scene/pet/pet_dragon_summon_%d.tscn" % stage
		frames_path = "res://Art/pet/pet_dragon/model/pet_dragon_stage%d_frames.tres" % stage
		bullet_scene_path = "res://Scene/pet/pet_dragon_bullet.tscn"
	phase_marks.append({"stage": "pet summon scene begin", "msec": Time.get_ticks_msec()})
	# 线程预载已保证 PackedScene 缓存；宠物帧由下方专用预热覆盖，
	# 因此这里只确保缓存，不实例化整棵节点树（避免加载页同步节点构建）。
	preload_scene_path(scene_path)
	phase_marks.append({"stage": "pet summon scene end", "msec": Time.get_ticks_msec()})
	var bullet_scene: PackedScene = null
	if bullet_scene_path != "":
		phase_marks.append({"stage": "pet bullet scene begin", "msec": Time.get_ticks_msec()})
		bullet_scene = preload_scene_path(bullet_scene_path)
		phase_marks.append({"stage": "pet bullet scene end", "msec": Time.get_ticks_msec()})
	phase_marks.append({"stage": "pet sprite frames begin", "msec": Time.get_ticks_msec()})
	_preload_sprite_frames_resource(frames_path)
	phase_marks.append({"stage": "pet sprite frames end", "msec": Time.get_ticks_msec()})
	phase_marks.append({"stage": "pet bullet frames begin", "msec": Time.get_ticks_msec()})
	if pet_type == "PetNian":
		pass
	elif pet_type == "PetYinTiger":
		PET_YIN_TIGER_BULLET_SCRIPT.warm_pet_yin_tiger_frames(stage)
	elif pet_type == "PetNeat":
		PET_NEAT_BULLET_SCRIPT.warm_pet_neat_frames(stage)
	elif pet_type == "PetMouse":
		PET_MOUSE_BULLET_SCRIPT.warm_pet_mouse_frames(pet_level)
	elif pet_type == "PetTiger":
		await MonsterBullet.prewarm_pet_tiger_runtime(stage, bullet_scene)
	elif pet_type == "PetPhoenix":
		await MonsterBullet.prewarm_pet_phoenix_runtime(stage, bullet_scene)
	elif pet_type == "PetTurtle":
		await PET_TURTLE_BULLET_SCRIPT.prewarm_pet_turtle_runtime(stage, bullet_scene)
	elif pet_type == "PetRabbit":
		PET_RABBIT_BULLET_SCRIPT.warm_pet_rabbit_frames(stage)
	else:
		await MonsterBullet.prewarm_pet_dragon_runtime(stage, bullet_scene)
	phase_marks.append({"stage": "pet bullet frames end", "msec": Time.get_ticks_msec()})
	if not is_runtime_generation_current(request_generation):
		return
	_prewarmed_pet_signatures[safe_slot] = pet_signature


func get_prewarmed_pet_signature(slot: int = 1) -> String:
	return str(_prewarmed_pet_signatures.get(2 if slot == 2 else 1, ""))


func get_magic_weapon_scene_path(weapon_name: String) -> String:
	return _magic_weapon_runtime.get_scene_path(weapon_name)


func get_magic_weapon_preload_paths(_name) -> Array[String]:
	return _magic_weapon_runtime.get_preload_paths(str(_name))


func prewarm_magic_weapon_runtime_resources(_name, phase_marks: Array = []) -> void:
	_magic_weapon_runtime.prewarm_runtime_resources(str(_name), phase_marks)


func prepare_magic_weapon_resources(_name) -> void:
	var scene_path := _magic_weapon_runtime.get_scene_path(str(_name))
	if scene_path == "" or _resource_runtime.is_resource_cached(scene_path):
		return
	await _resource_runtime.preload_paths_threaded([scene_path])


func add_magic_weapon(parent, _name, position, source_player: BaseHero = null):
	return _magic_weapon_runtime.add_magic_weapon(parent, str(_name), position, source_player)


func get_magic_summon_for(player: Node) -> Node:
	return _magic_weapon_runtime.get_magic_summon_for(player)


func set_magic_summon_for(player: Node, summon: Node) -> void:
	_magic_weapon_runtime.set_magic_summon_for(player, summon)


func add_message_show(parent_node, need_text: String, time: float):
	return _popup_factory.add_message_show(parent_node, need_text, time)


func add_anchored_message_show(parent_node, need_text: String, time: float, anchor: Vector2):
	return _popup_factory.add_anchored_message_show(parent_node, need_text, time, anchor)


## 统一保存反馈：失败时在可见 UI 层提示，并返回 false 供调用方回滚。
func request_save_with_feedback(reason: String, parent: Node = null, failure_prefix: String = "保存失败：") -> bool:
	_suppress_save_failure_feedback = true
	var outcome := MemoryClass.request_save_result(reason, false)
	_suppress_save_failure_feedback = false
	if bool(outcome.get("ok", false)):
		return true
	var target: Node = parent if is_instance_valid(parent) else _ui_runtime.get_popup_layer()
	add_message_show(target, failure_prefix + str(outcome.get("message", "")), 2.0)
	return false


func add_ws_effect(parent):
	return _effect_factory.add_ws_effect(parent)


func add_choose_item(parent, position, list, _name, page):
	return _shop_factory.add_choose_item(parent, position, list, _name, page)


func add_s_y_n_help(parent, position):
	return _shop_factory.add_s_y_n_help(parent, position)


func add_shop(parent, position):
	return _shop_factory.add_shop(parent, position)


func add_shop_items(parent, position, _name: String, need_):
	return _shop_factory.add_shop_items(parent, position, _name, need_)


func add_magp_infor(parent, position):
	return _backpack_factory.add_magp_infor(parent, position)


func add_synthesis(parent, position):
	return _shop_factory.add_synthesis(parent, position)


func add_change_bg(parent, position):
	return _menu_panel_factory.add_change_bg(parent, position)


func add_strength(parent, position):
	return _shop_factory.add_strength(parent, position)


func create_hands(parent, direction, position):
	return _monster_display.create_hands(parent, direction, position)


func call_chase_bullet(parent, _name, speed, time: float, dir, position, hit_name, dic):
	var target = instance_scene(load_cached_scene(CHASE_BULLET_PATH), parent)
	if target == null:
		print("Error: failed to instantiate chase_bullet_, check resource path")
		return null
	if target.has_node("Chaseani"):
		target.chase_ani = target.get_node("Chaseani")
	if target.chase_ani:
		target.chase_ani.flip_h = dir
	else:
		print("警告: ChaseBullet 场景缺少 chase_ani 节点")
	target._name = _name
	target._speed = speed
	target._time = time
	target.position = position
	target.att_list = dic
	target.hit_name = hit_name
	return target


func call_fly_bullet(parent, _name, dir, position, distance, speed, hit_name, dic):
	var target = instance_scene(load_fly_bullet_scene(str(_name)), parent)
	if target == null:
		return null
	target._name = _name
	target._speed = speed
	target._direction = dir
	target.distance = distance
	target.position = position
	target.att_list = dic
	target.hit_name = hit_name
	return target


func add_lj(parent, _position):
	return _popup_factory.add_lj(parent, _position)


func add_trap(parent, _position, _name):
	return _combat_factory.add_trap(parent, _position, _name)


func add_buff_info(parent, _position, message_text: String):
	return _popup_factory.add_buff_info(parent, _position, message_text)


func add_buff_icon_text(parent, text_):
	return _backpack_factory.add_buff_icon_text(parent, text_)


func add_special_effect(parent, _position, _name, _scale, direction, _speed):
	return _combat_factory.add_special_effect(parent, _position, _name, _scale, direction, _speed)


func add_choose_text(parent, _position, text_, calm_time):
	return _popup_factory.add_choose_text(parent, _position, text_, calm_time)


func add_special_effect_bullet(parent, _position, _scale, _name, dir):
	return _combat_factory.add_special_effect_bullet(parent, _position, _scale, _name, dir)


func add_role_information(parent, position):
	return _backpack_factory.add_role_information(parent, position)


func add_learn_skill(parent, position):
	return _menu_panel_factory.add_learn_skill(parent, position)


func add_zd_skillscene(parent, position):
	return _skill_panel_factory.add_zd_skill(parent, position)


func add_bd_skillscene(parent, position):
	return _skill_panel_factory.add_bd_skill(parent, position)


func add_gm_infor(parent, position):
	return _menu_panel_factory.add_gm_infor(parent, position)


func add_ldl(parent, position):
	return _menu_panel_factory.add_ldl(parent, position)


func add_pl_sell(parent, position):
	return _backpack_factory.add_pl_sell(parent, position)


func fall_item(parent, position, _name, value_):
	return _backpack_factory.fall_item(parent, position, _name, value_)


func add_dj_infor(parent, position, _name):
	return _backpack_factory.add_dj_infor(parent, position, _name)


func close_backpack_click_menus(parent: Node = null) -> void:
	var roots := []
	if parent != null:
		roots.append(parent)
	var current_scene = get_tree().current_scene
	if current_scene != null and current_scene != parent:
		roots.append(current_scene)
	if get_tree().root != null:
		roots.append(get_tree().root)
	for root in roots:
		_close_backpack_click_menus_in(root)


func _close_backpack_click_menus_in(root: Node) -> void:
	if root == null:
		return
	for child in root.get_children():
		if child == null:
			continue
		if child.name == "dj_sell" or child.name == "sell_or_equ":
			child.free()
			continue
		_close_backpack_click_menus_in(child)


func add_dj_sell(parent, position, _name, _page):
	return _backpack_factory.add_dj_sell(parent, position, _name, _page)


func add_equ_propeties_box(parent, position, _name, qh_level, wx, Data):
	return _backpack_factory.add_equ_propeties_box(parent, position, _name, qh_level, wx, Data)


func add_se_eq_jm(parent, position, _name, _page, _number):
	return _backpack_factory.add_se_eq_jm(parent, position, _name, _page, _number)


func add_main_backpack(parent, position):
	return _backpack_factory.add_main_backpack(parent, position)


func change_scene(target, force_loading_screen: bool = false, require_archive_session: bool = true) -> bool:
	return _scene_flow.change_scene(target, force_loading_screen, require_archive_session)


func _is_valid_scene_change_target(target_path: String) -> bool:
	return _scene_flow.is_valid_scene_change_target(target_path)


func get_scene_request_generation() -> int:
	return _scene_flow.get_scene_request_generation()


func is_scene_request_current(generation: int) -> bool:
	return _scene_flow.is_scene_request_current(generation)


func add_music_set(parent, position):
	return _menu_panel_factory.add_music_set(parent, position)


func add_camera(parent, position, right):
	return _level_scene_factory.add_camera(parent, position, right)


func call_hero(who: String, parent, position: Vector2, _dir: bool, player_slot: int = 1):
	var clean_who = who.replace(".0", "").replace(".", "")
	var scene_paths = {
		"role_1": "res://Scene/hero/role_1/role1.tscn",
		"role_2": "res://Scene/hero/role_2/role_2.tscn",
		"role_3": "res://Scene/hero/role_3/role_3.tscn",
		"role_4": "res://Scene/hero/role_4/role_4.tscn",
		"role_5": "res://Scene/hero/role_5/role_5.tscn",
		"role_6": "res://Scene/hero/role_6/role_6.tscn",
		"role_7": "res://Scene/hero/role_7/role_7.tscn",
		"role_8": "res://Scene/hero/role_8/role_8.tscn"
	}
	if not scene_paths.has(clean_who):
		push_error("Unknown hero type: " + who + " (cleaned to: " + clean_who + ")")
		return null
	var scene_resource = load(scene_paths[clean_who])
	if scene_resource:
		var target = scene_resource.instantiate()
		if target:
			target.set_meta("coop_slot", player_slot)
			parent.add_child(target)
			target.position = position
			return target
	push_error("Failed to create hero: " + clean_who)
	return null


func add_cd_jm(parent, position):
	return _menu_panel_factory.add_cd_jm(parent, position)


func add_moment_text(parent, position, text, last_time):
	return _popup_factory.add_moment_text(parent, position, text, last_time)


func add_touch_text(parent, position, text):
	return _popup_factory.add_touch_text(parent, position, text)


func add_back_pack(parent, position):
	return _backpack_factory.add_back_pack(parent, position)


func create_monster(M_id: int, parent, _position: Vector2) -> BaseMonster:
	return _monster_spawn.create_monster(M_id, parent, _position)


func add_hit_text(parent, _position, value, lx, crit, miss):
	return _combat_factory.add_hit_text(parent, _position, value, lx, crit, miss)


func add_monster_blood(parent, _position, value, text):
	return _combat_factory.add_monster_blood(parent, _position, value, text)


func add_mr_hurt(parent, _position):
	return _combat_factory.add_mr_hurt(parent, _position)


func left_align_popup_texts(root: Node) -> void:
	if root == null:
		return
	if root is Label:
		var label := root as Label
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	elif root is Button:
		var button := root as Button
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	for child in root.get_children():
		left_align_popup_texts(child)


func prepare_hover_info_popup(target: Node, use_top_level := false) -> void:
	if target == null:
		return
	target.z_index = 4095
	if target is CanvasItem:
		(target as CanvasItem).z_as_relative = false
	if use_top_level and target is CanvasItem:
		(target as CanvasItem).top_level = target.get_parent() != _ui_runtime.get_popup_layer()
	if target is Control:
		(target as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	left_align_popup_texts(target)
	if use_top_level:
		_ui_runtime.register_hover_popup(target)


func center_popup_texts(root: Node) -> void:
	if root == null:
		return
	if root is Label:
		var label := root as Label
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	elif root is Button:
		var button := root as Button
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	for child in root.get_children():
		center_popup_texts(child)


func add_role_bullet_1_safe(parent, position, _name, dic, source_player: BaseHero = null):
	return _projectile_factory.add_role_bullet_1_safe(parent, position, _name, dic, source_player)


func add_bullet_safe(bullet_name, parent, direction, show_speed, position, _hit_name, list):
	return _combat_factory.add_bullet_safe(bullet_name, parent, direction, show_speed, position, _hit_name, list)


func instance_scene(target_scene_, parent):
	if target_scene_ == null:
		push_error("instance_scene got null scene")
		return null
	if parent == null or not is_instance_valid(parent):
		push_error("instance_scene got null or invalid parent for scene: %s" % target_scene_.resource_path)
		return null
	if parent.is_queued_for_deletion():
		# 场景切换/阶段清理期间，延迟创建的子弹可能晚于父节点释放到达；
		# 这是可安全丢弃的竞态，不应制造 ERROR 噪声。
		return null
	var target = target_scene_.instantiate()
	if target == null:
		return null
	_ui_runtime.register_ui_runtime_instance(target, str(target_scene_.resource_path))
	parent.call_deferred("add_child", target)
	center_popup_texts(target)
	return target


func add_bullet(bullet_name: String, parent, direction: bool, show_speed, position, _hit_name, list):
	return _combat_factory.add_bullet(bullet_name, parent, direction, show_speed, position, _hit_name, list)


func _physics_process(_delta: float) -> void:
	_combat_pool.tick_combo_window()


func load_role1_body(_name, role_id: int = 0) -> Texture2D:
	return _role_visual.load_body(_name, role_id)


func load_role1_eq(_name, role_id: int = 0) -> Texture2D:
	return _role_visual.load_equipment(_name, role_id)


func remove_all_buff():
	RoleProp.ws_value = 0


func remove_all_active_buffs():
	for i in RoleProp.source_player.buff.get_children():
		if i != null:
			if i.buff_info["AddTime"] < 999:
				if i.buff_info.has("CanRemove"):
					if i.buff_info["CanRemove"]:
						i.queue_free()
				else:
					i.queue_free()


func remove_a_all_buff():
	for i in RoleProp.source_player.buff.get_children():
		if i != null:
			match i.buff_info["Name"]:
				"DoubleFallPro":
					continue
			i.queue_free()


## 统计 Voodoo 层；传入 source_player 时只统计该 Role4 施加的层。
func check_wd(OBJ, source_player: BaseHero = null) -> int:
	var count: int = 0
	for i in OBJ.buff.get_children():
		if i == null or i.is_queued_for_deletion():
			continue
		if str(i.buff_info.get("Name", "")) != "Voodoo":
			continue
		if source_player == null or i.buff_info.get("source_player") == source_player:
			count += 1
	return count


## 移除 Voodoo 层；传入 source_player 时只移除该来源，保留队友层。
func remove_wd(OBJ, source_player: BaseHero = null) -> void:
	for i in OBJ.buff.get_children():
		if i == null or i.is_queued_for_deletion():
			continue
		if str(i.buff_info.get("Name", "")) != "Voodoo":
			continue
		if source_player == null or i.buff_info.get("source_player") == source_player:
			i.queue_free()
