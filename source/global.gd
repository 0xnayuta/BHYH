extends Node
const DataKeys := preload("res://Script/base/data_keys.gd")

signal combo_milestone_reached(milestone: int)

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

var cloud_save_user_id := ""
var cloud_save_access_token := ""
var cloud_save_uid_md5 := ""
var cloud_save_account := ""
var cloud_auth_cooldown_until_msec := 0

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
var buff_list = []

const COMBAT_HIT_DAMAGE_POOL_SIZE := 12
const COMBAT_HIT_EFFECT_POOL_SIZE := 16
const COMBAT_HIT_SOUND_POOL_SIZE := 6
var choose_list = []
var choose_ms: bool
var buff_box
var mg_cd_pic
var zhen_fa
var lhhj_boss_list = {}

const BASIC_AR_BUTTON_PATH := "res://Scene/other_scene/bacis_ar_button.tscn"
const ADD_WEAPON_BULLET_PATHS := {
	"CloudSwordBullet": "res://Scene/magic_weapon/hit_bullet_lazy/cloud_sword_bullet.tscn",
	"CucurFire_1": "res://Scene/magic_weapon/hit_bullet_lazy/cucur_fire_1.tscn",
	"CucurFire_2": "res://Scene/magic_weapon/hit_bullet_lazy/cucur_fire_2.tscn",
	"GhostDollBullet_1": "res://Scene/magic_weapon/hit_bullet_lazy/ghost_doll_bullet_1.tscn",
	"GhostDollBullet_2": "res://Scene/magic_weapon/hit_bullet_lazy/ghost_doll_bullet_2.tscn",
	"GhostDollBullet_3": "res://Scene/magic_weapon/hit_bullet_lazy/ghost_doll_bullet_3.tscn",
	"MagicUmbrellaBullet": "res://Scene/magic_weapon/hit_bullet_lazy/magic_umbrella_bullet.tscn",
	"PurpleGlodCucurbitBullet": "res://Scene/magic_weapon/hit_bullet_lazy/purple_glod_cucurbit_bullet.tscn",
	"SwordBullet": "res://Scene/magic_weapon/hit_bullet_lazy/sword_bullet.tscn",
	"wdsfBullet1": "res://Scene/magic_weapon/hit_bullet_lazy/wdsf_bullet1.tscn",
	"wdsfBullet2": "res://Scene/magic_weapon/hit_bullet_lazy/wdsf_bullet2.tscn",
	"wdsfBullet3": "res://Scene/magic_weapon/hit_bullet_lazy/wdsf_bullet3.tscn",
	"wdshBullet1": "res://Scene/magic_weapon/hit_bullet_lazy/wdsh_bullet1.tscn",
	"wdshBullet2": "res://Scene/magic_weapon/hit_bullet_lazy/wdsh_bullet2.tscn",
	"wdshBullet2_1": "res://Scene/magic_weapon/hit_bullet_lazy/wdsh_bullet2_1.tscn",
	"wdslBullet1": "res://Scene/magic_weapon/hit_bullet_lazy/wdsl_bullet1.tscn",
	"wdslBullet2": "res://Scene/magic_weapon/hit_bullet_lazy/wdsl_bullet2.tscn",
	"wdstBullet1": "res://Scene/magic_weapon/hit_bullet_lazy/wdst_bullet1.tscn",
	"wdstBullet2": "res://Scene/magic_weapon/hit_bullet_lazy/wdst_bullet2.tscn",
	"wdstBullet3": "res://Scene/magic_weapon/hit_bullet_lazy/wdst_bullet3.tscn",
}
const MAGIC_WEAPON_SCENE_PATHS := {
	"zcld": "res://Scene/magic_weapon/zcld.tscn",
	"dshl": "res://Scene/magic_weapon/cucurbit.tscn",
	"dhqf": "res://Scene/magic_weapon/dhqf.tscn",
	"tsgj": "res://Scene/magic_weapon/sword.tscn",
	"bsyj": "res://Scene/magic_weapon/mirror.tscn",
	"lsys": "res://Scene/magic_weapon/magic_umbrella.tscn",
	"xhmt": "res://Scene/magic_weapon/ghost_doll.tscn",
	"xhhl": "res://Scene/magic_weapon/cucurbit2.tscn",
	"kyl": "res://Scene/magic_weapon/hybrofoline.tscn",
	"qyj": "res://Scene/magic_weapon/cloud_sword.tscn",
	"zjfyd": "res://Scene/magic_weapon/purple_gold_bell.tscn",
	"zjhl": "res://Scene/magic_weapon/purple_glod_cucurbit.tscn",
	"yjp": "res://Scene/magic_weapon/yujingping.tscn",
	"zlwdah": "res://Scene/magic_weapon/zlwdah.tscn",
	"sqzlw": "res://Scene/magic_weapon/sqzlw.tscn",
	"nmwdnh": "res://Scene/magic_weapon/nmwdnh.tscn",
	"sqnmwdnh": "res://Scene/magic_weapon/nmwdnh.tscn",
	"xianyjp": "res://Scene/magic_weapon/xian_yujingping.tscn",
	"yx": "res://Scene/magic_weapon/yx.tscn",
	"qlsword": "res://Scene/magic_weapon/qlsword.tscn",
	"tjbg": "res://Scene/magic_weapon/taiji_bagua.tscn",
	"dzyl": "res://Scene/magic_weapon/qing_lian.tscn",
	"469000004": "res://Scene/magic_weapon/zhen_lei_tian_chui.tscn",
	"469000011": "res://Scene/magic_weapon/di_kong_yu_mo_quan.tscn",
	"yyzlj": "res://Scene/magic_weapon/eight_immortal_yyzlj.tscn",
	"ywhl": "res://Scene/magic_weapon/eight_immortal_ywhl.tscn",
	"zhyx": "res://Scene/magic_weapon/eight_immortal_zhyx.tscn",
	"bjs": "res://Scene/magic_weapon/eight_immortal_bjs.tscn",
	"sxyg": "res://Scene/magic_weapon/eight_immortal_sxyg.tscn",
	"dkhl": "res://Scene/magic_weapon/eight_immortal_dkhl.tscn",
	"yyb": "res://Scene/magic_weapon/eight_immortal_yyb.tscn",
	"hehua": "res://Scene/magic_weapon/eight_immortal_hehua.tscn",
}
const HIT_TEXT_PATH := "res://Scene/hittext/hit_text.tscn"
const DAMAGE_TEXT_PATH := "res://Scene/hittext/damage_text.tscn"
const MONSTER_BLOOD_PATH := "res://Scene/monster_blood/monster_blood_bar.tscn"
const BOSS_BLOOD_PATH := "res://Scene/monster_blood/boss_blood.tscn"
const MONSTER_BE_HIT_PATH := "res://Scene/monster_damage/monster_be_hit.tscn"
const SPECIAL_AFFECT_SLIM_DIR := "res://Scene/base/special_affect_slim"
const ROLE_BE_HIT_EFFECT_PATH := "res://Scene/base/role_be_hit_effect.tscn"
const AURA_PATH := "res://Scene/other_scene/auras.tscn"
const BUFF_ICON_PATH := "res://Scene/other_scene/buff_icon.tscn"
const DAMAGE_NUMBER_PATH := "res://Scene/hittext/damage_number.tscn"
const MISS_EFFECT_PATH := "res://Scene/hittext/miss_effect.tscn"
const COMBO_PATH := "res://Scene/show_text/combo.tscn"
const COMBO_NUM_PATH := "res://Scene/show_text/combo_num.tscn"
const LIJI_PATH := "res://Scene/show_text/liji.tscn"
const MOMENT_TEXT_PATH := "res://Scene/show_text/moment_text.tscn"
const MESSAGE_SHOW_PATH := "res://Scene/show_text/message_show.tscn"
const BASE_BUFF_PATH := "res://Scene/base/base_buff.tscn"
const ROLE_BULLET_SLIM_DIR := "res://Scene/hero/role_bullet_slim"
const STREAMING_ROLE_BULLET_PATH := "res://Scene/hero/streaming_role_bullet.tscn"
const ROLE3_BULLET3_SLIM_PATH := "res://Scene/hero/role3_bullet3_slim.tscn"
const ROLE3_SD_SLIM_PATH := "res://Scene/hero/role3_sd_slim.tscn"
const ROLE3_ZZNH_SLIM_PATH := "res://Scene/hero/role3_zznh_slim.tscn"
const ROLE_SPECIAL_EFFECT_SLIM_DIR := "res://Scene/hero/role_special_effect_slim"
const TTZSSZ_BULLET_SLIM_PATH := "res://Scene/hero/ttzssz_bullet_slim.tscn"
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
var basic_ar_button = null
var weapon_bullet_node = null
var bullet = null
var damage_text = null
var monster_be_hit = null
var special_affect = null
var role_bullet = null
var fly_bullet = null
var _chase_bullet = null


func _exit_tree() -> void:
	_shutting_down = true
	_advance_runtime_generation()
	if _scene_flow != null:
		_scene_flow.clear_runtime_state()
	_archive_session_generation += 1
	_archive_session_prewarm_token += 1
	_archive_session = ArchiveSession.new()
	_archive_session_prewarm_in_progress = false
	_archive_session_prewarm_role_id = 0
	_prewarmed_role_id = 0
	_prewarmed_pet_signature = ""
	release_role_runtime_resources()
	clear_combat_runtime_cache()
	if _ui_runtime != null:
		_ui_runtime.release_ui_runtime_cache(true)
		_ui_runtime.clear_runtime_state()
	if _resource_runtime != null:
		_resource_runtime.clear_runtime_state()
	if _audio_runtime != null:
		_audio_runtime.clear_runtime_state()
	_pending_combo_milestones.clear()
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
	if MemoryClass != null and not MemoryClass.background_save_finished.is_connected(_on_background_save_finished):
		MemoryClass.background_save_finished.connect(_on_background_save_finished)
	if MemoryClass != null and not MemoryClass.save_failed.is_connected(_on_save_failed):
		MemoryClass.save_failed.connect(_on_save_failed)
	call_deferred("prewarm_permanent_small_ui_scenes")


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


var cloud_sword = null
var purple_gold_bell = null
var zcld = null
var cucurbit = null
var sword = null
var mirror = null
var ghost_doll = null
var dhqf = null
var magic_umbrella = null
var purple_glod_cucurbit = null
var hybrofoline = null
var yujingping = null
var zlwdah = null
var sqzlw = null
var nmwdnh = null
var xian_yujingping = null
var yx = null
var qlsword = null
var cucurbit2 = null

var _last_full_monster_bullet_name := ""
var _last_combo_value: int = 0
var is_frist: bool
var is_show: bool
var collect_num: int = 0
var player_be_hit_count: int = 0
var game_over: int = 1
var llbtwxms: bool = false
var llbtcgms: bool = true
var llbtbossms: bool
var box_count: int = 0
var llbt_level: int = 1

var infinite_level_multiplier: float = 0.0
var current_level: String
var selected_three_prince_id: int = 0
var selected_eight_immortal_id: int = 0
var selected_constellation_level: int = 1
var constellation_best_tier: Dictionary = {}
var level_drop_pro_data = {}
var level_begin_time = ""
var level_end_time = ""
var most_lianji: int = 0
var last_prop_hp: float
var total_role_hurt: int
var last_level_path: String
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


## 当前档案会话的只读快照；未建立时返回 inactive 对象。
func get_archive_session() -> ArchiveSession:
	return _archive_session


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
	add_message_show(_ui_runtime.get_popup_layer(), message, 2.0, Vector2.ZERO)


func set_save_failure_feedback_enabled(enabled: bool) -> void:
	_save_failure_feedback_enabled = enabled


var total_role_hit: int
var total_cure_hp: int
var total_phy_hit: int
var total_mag_hit: int
var total_real_hit: int
var total_phy_hurt: int
var total_mag_hurt: int
var total_real_hurt: int
var total_hurt_count: int
var total_hit_count: int
var total_crit_count: int
var total_miss_count: int
var file_num = 1.201
var mytime
var player_pos_x
var zb_packisfull = false
var dj_packisfull = false
var xhp_packisfull = false
var forge
var fb_cd: int
var is_in_ldl
var get_target
var is_mpo
var is_ice
var is_poision
var is_fire
var is_speed_down
var is_stun
var is_bleed
var is_eye_fix
var is_dead_link
var lj_times: int
var lj_count: int

var remove_jq
var wait_time: float = 0.8
var need_change_item: bool = true
var player_dir

var _current_role_body_texture_path: String = ""
var _current_role_equipment_texture_path: String = ""
var _all_hero_skill_resources_preloaded: bool = false
var _prewarmed_role_id: int = 0
var _archive_session: ArchiveSession = ArchiveSession.new()
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
var _prewarmed_pet_signature: String = ""
var _resource_runtime: ResourceRuntime = null
var _scene_flow: SceneFlow = null
var _popup_factory: PopupFactory = null
var _shop_factory: ShopFactory = null
var _backpack_factory: BackpackFactory = null
var _reward_factory: RewardFactory = null
var _combat_factory: CombatPresentationFactory = null
var _combat_pool: CombatPoolRuntime = null
var _magic_weapon_runtime: MagicWeaponRuntime = null
var _pending_combo_milestones = {}
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


func _is_scene_resource_path(path: String) -> bool:
	return _resource_runtime.is_scene_resource_path(path)


func _is_valid_packed_scene(value: Variant) -> bool:
	return _resource_runtime.is_valid_packed_scene(value)


func load_ui_scene(path: String) -> PackedScene:
	if not _ui_runtime.is_runtime_ui_scene_path(path):
		return load(path) as PackedScene
	return _resource_runtime.load_scene(path)


## 场景工厂的统一取景入口：命中永久 UI/资源缓存时复用，不再单独加载。
func load_cached_scene(path: String) -> PackedScene:
	return _resource_runtime.load_scene(path)


func prewarm_permanent_small_ui_scenes(generation: int = -1) -> void:
	await _resource_runtime.prewarm_permanent_small_ui_scenes(generation)


func get_level_info_monster_ids(level_name: String) -> Array:
	if level_name == "":
		return []
	var level_info_scene: PackedScene = level_info as PackedScene
	if level_info_scene == null:
		level_info_scene = _load_scene("res://Scene/other_scene/level_info.tscn") as PackedScene
	if level_info_scene == null:
		return []
	var probe := level_info_scene.instantiate()
	if probe == null:
		return []
	var all_info: Variant = probe.get("level_info")
	if not all_info is Dictionary:
		probe.free()
		return []
	var current_level_info: Variant = (all_info as Dictionary).get(level_name, {})
	if not current_level_info is Dictionary:
		probe.free()
		return []
	var result: Array = []
	var monster_list: Variant = (current_level_info as Dictionary).get("monster_list", [])
	if monster_list is Array:
		for monster_entry_value in monster_list:
			if not monster_entry_value is Dictionary:
				continue
			var monster_entry: Dictionary = monster_entry_value
			var monster_id := int(monster_entry.get("ConfigId", 0))
			if monster_id <= 0:
				var scene_path := str(monster_entry.get("ScenePath", ""))
				var monster_file := scene_path.get_file().get_basename()
				if monster_file.begins_with("Monster_"):
					var monster_id_text := monster_file.trim_prefix("Monster_")
					if monster_id_text.is_valid_int():
						monster_id = int(monster_id_text)
			if monster_id > 0 and not result.has(monster_id):
				result.append(monster_id)
	probe.free()
	return result


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
		"res://Scene/skill/learn_skill.tscn",
		"res://Scene/skill/zd_skill.tscn",
		"res://Scene/skill/bd_skill.tscn",
	]
	var role_id := clampi(int(PlayerData.player_data.get("Myself", 1)), 1, 7)
	var role_skill_icons := {
		1: ["slz", "hytj", "lys", "lyfb", "hmz", "hmz_ws", "zz", "qsez", "jdy", "hyjj", "sx", "gsrs", "hyjj_ws"],
		2: ["blb", "xbz", "shy", "tjgl", "smb", "sgq", "myhc", "jgz", "jhsj", "sjt", "by", "zfjg"],
		3: ["ssp", "dj", "dgq", "zznh", "tmc", "sd", "jsp", "xgq", "syzq", "rj", "bdqk"],
		4: ["qlj", "dcj", "wdzt", "tkj", "mmw", "jdz", "lhsq", "zq", "wdww", "mds", "bylt", "cmly"],
		5: ["xyq", "slq", "blq", "fhf", "cxq", "llrd", "lljy", "ygth", "tllz", "yyb", "ltjz"],
		6: ["nz_jlsh", "nz_fhcc", "nz_hlqg", "nz_hlhs", "nz_lblc"],
		7: YutuSkillData.KEYS,
	}
	for icon_name in role_skill_icons[role_id]:
		paths.append("res://Art/skill/skill_icon/%s.png" % icon_name)
	await _preload_paths_threaded(paths, request_generation)
	if not is_runtime_generation_current(request_generation):
		return
	skill_learn = _resource_runtime.get_cached_packed_scene("res://Scene/skill/learn_skill.tscn")
	zd_skill = _resource_runtime.get_cached_packed_scene("res://Scene/skill/zd_skill.tscn")
	bd_skill = _resource_runtime.get_cached_packed_scene("res://Scene/skill/bd_skill.tscn")


func load_scene_uncached(path: String) -> PackedScene:
	return _resource_runtime.load_scene_uncached(path)


func load_level_monster_scene(path: String) -> PackedScene:
	return _resource_runtime.load_level_monster_scene(path)


func _monster_scene_path(monster_id: int) -> String:
	var override := LevelPreloadStore.monster_scene_path(monster_id)
	if not override.is_empty():
		return override
	return "res://Scene/monster/monster_%d.tscn" % monster_id


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
		var scene_path := _monster_scene_path(monster_id)
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
		var scene_path := _monster_scene_path(monster_id)
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
	_last_full_monster_bullet_name = bullet_name

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


func _get_threaded_preload_batch_size(request_count: int) -> int:
	return _resource_runtime.get_threaded_preload_batch_size(request_count)


func _warm_scene_paths_over_frames(paths: Array, per_frame: int = 2, generation: int = -1) -> void:
	await _resource_runtime.warm_scene_paths_over_frames(paths, per_frame, generation)


func _warm_audio_streams_over_frames(paths: Array, per_frame: int = 2, generation: int = -1) -> void:
	await _resource_runtime.warm_audio_streams_over_frames(paths, per_frame, generation)


func _warm_texture_rids_over_frames(paths: Array, per_frame: int = 6, generation: int = -1) -> void:
	await _resource_runtime.warm_texture_rids_over_frames(paths, per_frame, generation)


func _get_damage_number_texture_paths() -> Array:
	var result: Array = []
	var number_dirs: Array[String] = [
		"res://Art/all_number/cure/cure_",
		"res://Art/all_number/cure_mp/cure_mp_",
		"res://Art/all_number/reduce_mp/reduce_mp_",
		"res://Art/all_number/physics/physics_",
		"res://Art/all_number/physicscrit/physics_",
		"res://Art/all_number/magic/magic_",
		"res://Art/all_number/magic/physics_",
		"res://Art/all_number/magiccrit/magic_",
		"res://Art/all_number/real/real_",
		"res://Art/all_number/realcrit/real_",
		"res://Art/all_number/lj/lj_",
		"res://Art/all_number/monster/physics/physics_",
		"res://Art/all_number/monster/magic/magic_",
	]
	for prefix in number_dirs:
		for i in range(10):
			result.append(prefix + str(i) + ".png")
	return result


func preload_combat_hit_resources() -> void:
	var request_generation := _runtime_generation
	if not is_runtime_generation_current(request_generation):
		return
	preload_damage_number_textures()
	load_cached_scene(HIT_TEXT_PATH)
	var damage_scene := _cached_scene(&"damage_text", DAMAGE_TEXT_PATH)
	load_cached_scene(DAMAGE_NUMBER_PATH)
	load_cached_scene(MISS_EFFECT_PATH)
	var role_be_hit_scene := preload_scene_path(ROLE_BE_HIT_EFFECT_PATH)
	var monster_hit_scene := _cached_scene(&"monster_be_hit", MONSTER_BE_HIT_PATH)
	var monster_blood_scene := load_cached_scene(MONSTER_BLOOD_PATH)
	var sound_scene := preload_scene_path("res://Scene/all_sound/monster_be_hit.tscn")
	get_cached_audio("res://Music/monster_hurt/6_beattack_by_role1.mp3")
	get_cached_audio("res://Music/hero/9_beattack_by_role2.mp3")
	get_cached_audio("res://Music/hero/49_role1_be_attack.mp3")
	get_cached_audio("res://Music/hero/62_role2_be_attack.mp3")
	get_cached_audio("res://Music/hero/68_role3_be_attack.mp3")
	_seed_runtime_pool("damage_text", damage_scene, COMBAT_HIT_DAMAGE_POOL_SIZE)
	_seed_runtime_pool("mr_hurt", monster_hit_scene, COMBAT_HIT_EFFECT_POOL_SIZE)
	_seed_runtime_pool("role_be_hit", role_be_hit_scene, COMBAT_HIT_EFFECT_POOL_SIZE)
	_seed_runtime_pool("sound_player", sound_scene, COMBAT_HIT_SOUND_POOL_SIZE)
	await _prewarm_combat_hit_rendering(monster_blood_scene, request_generation)


func _seed_runtime_pool(pool_name: String, scene: PackedScene, target_size: int) -> void:
	_combat_pool.seed_pool(pool_name, scene, target_size)


func _prewarm_combat_hit_rendering(monster_blood_scene: PackedScene, generation: int = -1) -> void:
	var request_generation := _runtime_generation if generation < 0 else generation
	if not is_runtime_generation_current(request_generation):
		return
	var tree := get_tree()
	if tree == null:
		return
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

	await tree.process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
	if not is_runtime_generation_current(request_generation):
		if is_instance_valid(warm_root):
			warm_root.queue_free()
		return

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
	_prewarmed_pet_signature = ""
	_current_role_body_texture_path = ""
	_current_role_equipment_texture_path = ""

	damage_text = null
	monster_be_hit = null
	special_affect = null
	role_bullet = null
	fly_bullet = null
	_chase_bullet = null
	_combat_factory.clear_scene_caches()
	role4_bullet = null
	role_bullet_1 = null
	role1_shallow = null
	monster65_bullet = null
	role_special_effect = null
	role2_shallow = null
	smb_effect = null
	new_bullet = null
	_all_hero_skill_resources_preloaded = false
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
	var role_id := _current_role_id()
	if role_id < 1 or role_id > 7:
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
	await prewarm_permanent_small_ui_scenes(runtime_generation)
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


func _role_scene_path(role_id: int) -> String:
	return (
		{
			1: "res://Scene/hero/role_1/role1.tscn",
			2: "res://Scene/hero/role_2/role_2.tscn",
			3: "res://Scene/hero/role_3/role_3.tscn",
			4: "res://Scene/hero/role_4/role_4.tscn",
			5: "res://Scene/hero/role_5/role_5.tscn",
			6: "res://Scene/hero/role_6/role_6.tscn",
		}
		. get(role_id, "")
	)


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
		role_id = _current_role_id()
	var names := _current_visual_equipment_names()
	var paths: Array[String] = []
	if role_id == 7:
		return ["res://Art/hero_picture/role_7/official_parts/default/parts.png"]
	if role_id == 6:
		NeZhaEquipmentVisuals.get_body_frames(str(names.get("body", "Empty")))
		NeZhaEquipmentVisuals.get_body_front_frames(str(names.get("body", "Empty")))
		NeZhaEquipmentVisuals.get_weapon_frames(str(names.get("weapon", "Empty")))
		return paths
	var body_name: String = str(get_clean_name(str(names.get("body", "Empty")))).to_lower()
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
	_current_role_body_texture_path = ""
	_current_role_equipment_texture_path = ""
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
	role_bullet = null
	fly_bullet = null
	_chase_bullet = null
	role4_bullet = null
	role_bullet_1 = null
	role1_shallow = null
	role_special_effect = null
	role2_shallow = null
	smb_effect = null
	new_bullet = null


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


func preload_combat_misc_resources() -> void:
	var texture_paths: Array[String] = [
		"res://Art/add_effect/buff_icon/poision.png",
		"res://Art/add_effect/buff_icon/ice.png",
		"res://Art/add_effect/buff_icon/fire.png",
		"res://Art/add_effect/buff_icon/speed_down.png",
		"res://Art/add_effect/buff_icon/stun.png",
		"res://Art/add_effect/buff_icon/htsf.png",
		"res://Art/add_effect/buff_icon/bleed.png",
		"res://Art/add_effect/buff_icon/yxbuff.png",
	]
	for path in texture_paths:
		get_cached_texture(path)
	var scene_paths: Array[String] = [
		"res://Scene/monster/monster_zhw/monster_141_zhw.tscn",
		"res://Scene/monster/monster_zhw/monster_142_sqzlw.tscn",
		"res://Scene/monster/monster_zhw/monster_142_zhw.tscn",
		"res://Scene/monster/monster_14501.tscn",
		"res://Scene/monster/monster_14501_wdww.tscn",
		"res://Scene/monster/monster_146.tscn",
		"res://Scene/monster/monster_63.tscn",
	]


func preload_common_drop_textures() -> void:
	var drop_paths: Array[String] = [
		"res://Art/item_icon/zxbx_3.png",
		"res://Art/item_icon/peach.png",
		"res://Art/item_icon/bble.png",
		"res://Art/item_icon/radish.png",
		"res://Art/item_icon/qhsbx.png",
		"res://Art/backpack/all_items/empty.png",
	]
	for path in drop_paths:
		get_cached_texture(path)


func preload_damage_number_textures() -> void:
	var number_dirs: Array[String] = [
		"res://Art/all_number/cure/cure_",
		"res://Art/all_number/cure_mp/cure_mp_",
		"res://Art/all_number/reduce_mp/reduce_mp_",
		"res://Art/all_number/physics/physics_",
		"res://Art/all_number/physicscrit/physics_",
		"res://Art/all_number/magic/magic_",
		"res://Art/all_number/magic/physics_",
		"res://Art/all_number/magiccrit/magic_",
		"res://Art/all_number/real/real_",
		"res://Art/all_number/realcrit/real_",
		"res://Art/all_number/lj/lj_",
		"res://Art/all_number/monster/physics/physics_",
		"res://Art/all_number/monster/magic/magic_",
	]
	for prefix in number_dirs:
		for i in range(10):
			get_cached_texture(prefix + str(i) + ".png")


func preload_all_hero_skill_resources() -> void:
	if _all_hero_skill_resources_preloaded:
		return
	_all_hero_skill_resources_preloaded = true
	var scene_paths: Array[String] = [
		"res://Scene/hero/role_bullet_1.tscn",
		"res://Scene/hero/role1_s_hallow.tscn",
		"res://Scene/hero/role_1/hmz_effect/special_effect_bullet.tscn",
		"res://Scene/hero/role_1/hmz_effect/special_effect_bullet_1.tscn",
		"res://Scene/hero/role_1/ws_effect.tscn",
		"res://Scene/hero/role_2/smb_effect.tscn",
		"res://Scene/hero/role_4/role4_bullet.tscn",
		"res://Scene/bullet/fly_bullet.tscn",
		"res://Scene/bullet/chase_bullet.tscn",
	]
	for scene_path in scene_paths:
		var scene := preload_scene_path(scene_path)
		_warm_scene_instance(scene)
	var audio_paths: Array[String] = [
		"res://Music/hero/00_role1_gsrs.mp3",
		"res://Music/hero/1_role1_hit9.mp3",
		"res://Music/hero/11_role1_hit7.mp3",
		"res://Music/hero/11_role2_hit4.mp3",
		"res://Music/hero/17_role1_hit6.mp3",
		"res://Music/hero/18_role1_hit14.mp3",
		"res://Music/hero/26_role1_hit13_1.mp3",
		"res://Music/hero/27_role1_hit13_2.mp3",
		"res://Music/hero/32_role2_hit6.mp3",
		"res://Music/hero/35_role1_hit10_1.mp3",
		"res://Music/hero/36_role1_hit10_2.mp3",
		"res://Music/hero/37_role1_hit10_4.mp3",
		"res://Music/hero/38_role1_hit5.mp3",
		"res://Music/hero/39_role1_hit3_and_hit4.mp3",
		"res://Music/hero/39_role2_hit9.mp3",
		"res://Music/hero/40_role1_hit1_and_hit2.mp3",
		"res://Music/hero/40_role2_hit7.mp3",
		"res://Music/hero/42_role1_hit11.mp3",
		"res://Music/hero/44_role1_hit12_2.mp3",
		"res://Music/hero/45_role1_hit12_1.mp3",
		"res://Music/hero/49_role1_be_attack.mp3",
		"res://Music/hero/51_role2_hit10.mp3",
		"res://Music/hero/57_role2_hit8.mp3",
		"res://Music/hero/58_role2_hit1.mp3",
		"res://Music/hero/59_role1_dead.mp3",
		"res://Music/hero/59_role2_hit2.mp3",
		"res://Music/hero/60_role2_hit3.mp3",
		"res://Music/hero/62_role2_be_attack.mp3",
		"res://Music/hero/68_role3_be_attack.mp3",
		"res://Music/hero/69_role3_hit3.mp3",
		"res://Music/hero/70_role3_hit2.mp3",
		"res://Music/hero/71_role3_hit1.mp3",
		"res://Music/hero/72_role3_dead.mp3",
		"res://Music/hero/75_role2_dead.mp3",
		"res://Music/hero/8_role1_hit6.mp3",
		"res://Music/hero/9_beattack_by_role2.mp3",
		"res://Music/hero/effect8.mp3",
		"res://Music/hero/role_3/10_role3_hit8.mp3",
		"res://Music/hero/role_3/14_role3_hit7.mp3",
		"res://Music/hero/role_3/16_role3_hit5.mp3",
		"res://Music/hero/role_3/31_role3_hit6.mp3",
		"res://Music/hero/role_3/38_role3_hit9.mp3",
		"res://Music/hero/role_3/52_role3_hit12_2.mp3",
		"res://Music/hero/role_3/53_role3_hit4.mp3",
		"res://Music/hero/role_3/56_role3_hit10.mp3",
		"res://Music/hero/role_3/67_role3_hit11.mp3",
		"res://Music/hero/role_3/74_role3_hit12_1.mp3",
		"res://Music/hero/role_3/role3_skill_11.wav",
		"res://Music/hero/role_4/arrowdcj.mp3",
		"res://Music/hero/role_4/arrow_hit1.mp3",
		"res://Music/hero/role_4/arrow_hit2.mp3",
		"res://Music/hero/role_4/arrowmmw.mp3",
		"res://Music/hero/role_4/arrowqlj.mp3",
		"res://Music/hero/role_4/arrowtkj.mp3",
		"res://Music/hero/role_4/arrowzq.mp3",
		"res://Music/hero/role_4/effect6_repeat.mp3",
		"res://Music/hero/role_4/jdz.mp3",
		"res://Music/hero/role_4/lhsq.mp3",
		"res://Music/hero/role_4/mds.mp3",
		"res://Music/hero/role_4/shoveldcj.mp3",
		"res://Music/hero/role_4/shovel_hit1.mp3",
		"res://Music/hero/role_4/shovel_hit2.mp3",
		"res://Music/hero/role_4/shovel_hit3.mp3",
		"res://Music/hero/role_4/shovelmmw.mp3",
		"res://Music/hero/role_4/shovelqlj.mp3",
		"res://Music/hero/role_4/shovelzq.mp3",
		"res://Music/hero/role_4/wdww.mp3",
		"res://Music/hero/role_5/13_hurt_stand.mp3",
		"res://Music/hero/role_5/attack.mp3",
		"res://Music/hero/role_5/attack_repeat.mp3",
		"res://Music/hero/role_5/attack1.mp3",
		"res://Music/hero/role_5/attack2.mp3",
		"res://Music/hero/role_5/attack3.mp3",
		"res://Music/hero/role_5/attack4.mp3",
		"res://Music/hero/role_5/effect1_1.mp3",
		"res://Music/hero/role_5/effect1_2.mp3",
		"res://Music/hero/role_5/effect2.mp3",
		"res://Music/hero/role_5/effect3.mp3",
		"res://Music/hero/role_5/effect4.mp3",
		"res://Music/hero/role_5/effect6.mp3",
		"res://Music/hero/role_5/effect7_1.mp3",
		"res://Music/hero/role_5/effect7_2.mp3",
		"res://Music/hero/role_5/effect8_1.mp3",
		"res://Music/hero/role_5/effect8_2.mp3",
		"res://Music/hero/role_5/effect9_1.mp3",
		"res://Music/hero/role_5/effect9_2.mp3",
		"res://Music/hero/role_5/jump_attack.mp3",
		"res://Music/hero/smsrsz_bullet_xc.MP3",
	]
	for audio_path in audio_paths:
		get_cached_audio(audio_path)


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
	var manifest := RoleRuntimeCatalog.get_manifest(_current_role_id())
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
		role_id = _current_role_id()
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
	return clampi(int(PlayerData.player_data.get("Myself", 1)), 1, 7)


func _cached_scene(property_name: StringName, path: String) -> PackedScene:
	var scene = get(property_name) as PackedScene
	if scene == null:
		scene = _load_scene(path) as PackedScene
		set(property_name, scene)
	return scene


var lhhjbutton = null
var mosaic_help = null
var cd_jm = null
var set_menu = null

var mycamera = null
var music_set = null
var target_scene: String:
	get:
		return _scene_flow.target_scene if _scene_flow != null else ""
	set(value):
		if _scene_flow != null:
			_scene_flow.target_scene = value

var four_swords_endless_mode: bool = false
var sss_lendless_mode: bool = false
var constellation_endless_mode: bool = false
var three_prince_endless_mode: bool = false


func preload_next(path: String) -> void:
	_resource_runtime.preload_next(path)


func clear_preloaded_scene_slot() -> void:
	_resource_runtime.clear_preloaded_scene_slot()


func _get_preloaded(path: String) -> PackedScene:
	return _resource_runtime.take_preloaded_scene(path)


var sell_or_equ = null
var fall_equ = null
var ldl = null
var game_information = null
var zd_skill = null
var skill_learn = null
var role_information = null
var zztwtrap = null
var bd_skill = null
var nmw_hands = null
var change_background = null
var ws_effect = null

var magic_help = null

var sound = null
var mosaic = null
var role4_bullet = null
var game_set = null
var skill_key_set = null
var role_bullet_1 = null
var role1_shallow = null
var change_clothes_jm = null
var h_hjm = null
var z_lw_stage = null
var buffinfor = null
var monster65_bullet = null
var choose_player = null
var role_special_effect = null
var role2_shallow = null
var smb_effect = null
var new_bullet = null
var role_magic_need = null
var game_need_know = null
var monster_head = null
var level_fall_box = null
var level_info = null
var pj = null
var help_thing = null
var hc_help = null
var stage = null
var decompose = null
var decompose_help = null
var task_title = null
var add_font = null
var game_announcement = null
var basic_pellet = null
var trans_box = null
var llbt_challenge = null
var forges = null
var forge_box = null
var forge_help = null
var basic_monment_info = null
var monster_info = null
var _hdzm = null
var _lsh = null
var _lxdy = null
var dsg_choose = null
var line = null
var cure_times_box = null
var letter_for_player = null
var some_monster_help = null
var lhhj = null
var listbutton = null
var lhhjhelp = null
var monster141_aura = null
var return_back_map = null
var zhenfalxbutton = null
var zhen_fa_info = null
var zhen_fa_ui = null
var ui_28 = null
var zhenyanbutton = null
var zhen_yan_cure_level = null
var zhen_fa_tu_po = null
var zhen_fa_help = null
var role_button = null
var star = null


func add_star(parent, type_id: int):
	if not star:
		star = _load_scene("res://Scene/other_scene/star.tscn")
	var target = instance_scene(star, parent)
	target.type = type_id
	return target


func add_role_button(parent, my_name, my_father):
	if not role_button:
		role_button = _load_scene("res://Scene/other_scene/role_button.tscn")
	var target = instance_scene(role_button, parent)
	target.my_name = my_name
	target.my_father = my_father
	return target


func add_basic_ar_button(parent, Num):
	var target = instance_scene(_cached_scene(&"basic_ar_button", BASIC_AR_BUTTON_PATH), parent)
	if target == null:
		return null
	target.archive_num = Num
	return target


func add_zhen_fa_help(parent, position):
	if not zhen_fa_help:
		zhen_fa_help = _load_scene("res://Scene/other_scene/zhen_fa_help.tscn")
	var target = instance_scene(zhen_fa_help, parent)
	target.position = position
	return target


func add_zhen_fa_tu_po(parent, position, father):
	if not zhen_fa_tu_po:
		zhen_fa_tu_po = _load_scene("res://Scene/other_scene/zhen_fa_tu_po.tscn")
	var target = instance_scene(zhen_fa_tu_po, parent)
	target.position = position
	target.father = father
	return target


func add_zhen_yan_cure_level(parent, position, father):
	if not zhen_yan_cure_level:
		zhen_yan_cure_level = _load_scene("res://Scene/other_scene/zhen_yan_cure_level.tscn")
	var target = instance_scene(zhen_yan_cure_level, parent)
	target.position = position
	target.father = father
	return target


func addzhenyanbutton(parent, position, loc_num, father):
	if not zhenyanbutton:
		zhenyanbutton = _load_scene("res://Scene/other_scene/zhenyanbutton.tscn")
	var target = instance_scene(zhenyanbutton, parent)
	target.position = position
	target.loc_num = loc_num
	target.father = father
	return target


func addui_28(parent, position):
	if not ui_28:
		ui_28 = _load_scene("res://Scene/other_scene/twenty_eight_constellations.tscn")
	var target = instance_scene(ui_28, parent)
	target.position = position
	_ui_runtime.register_transient_ui(target, &"_on_close_pressed")
	return target


func add_zhen_fa_ui(parent, position):
	if not zhen_fa_ui:
		zhen_fa_ui = _load_scene("res://Scene/other_scene/zhen_fa_ui.tscn")
	var target = instance_scene(zhen_fa_ui, parent)
	target.position = position
	return target


func add_zhen_fa_info(parent, position, father):
	if not zhen_fa_info:
		zhen_fa_info = _load_scene("res://Scene/other_scene/zhenfainfo.tscn")
	var target = instance_scene(zhen_fa_info, parent)
	target.position = position
	target.father = father
	return target


func add_zhenfalxbutton(parent, zhenfa_name, father):
	if not zhenfalxbutton:
		zhenfalxbutton = _load_scene("res://Scene/other_scene/zhenfalxbutton.tscn")
	var target = instance_scene(zhenfalxbutton, parent)
	target.zhenfa_name = zhenfa_name
	target.father = father
	return target


func addhdgqmap(parent, position):
	if not return_back_map:
		return_back_map = _load_scene("res://Scene/other_scene/return_back_map.tscn")
	var target = instance_scene(return_back_map, parent)
	target.position = position
	_ui_runtime.register_transient_ui(target, &"_on_close_pressed")
	return target


func add_monster141_aura(parent, _position, target_monster):
	if not monster141_aura:
		monster141_aura = _load_scene("res://Scene/other_scene/nmw_aura.tscn")
	var target = instance_scene(monster141_aura, parent)
	target.target_monster = target_monster
	target.position = _position
	return target


func addlhhjhelp(parent, position):
	if not lhhjhelp:
		lhhjhelp = _load_scene("res://Scene/other_scene/lhhj_help.tscn")
	var target = instance_scene(lhhjhelp, parent)
	target.position = position
	return target


func addlistbutton(parent, self_name, father, Num):
	if not listbutton:
		listbutton = _load_scene("res://Scene/other_scene/list_button.tscn")
	var target = instance_scene(listbutton, parent)
	target.self_name = self_name
	target.father = father
	target.num = Num
	return target


func addlhhj(parent, position):
	if not lhhj:
		lhhj = _load_scene("res://Scene/other_scene/lhhj.tscn")
	var target = instance_scene(lhhj, parent)
	target.scale = Vector2.ONE
	if position == Vector2.ZERO or position == Vector2(0, 0):
		target.position = viewport_center_for_parent(parent) - Vector2(461, 282)
	else:
		target.position = position
	_ui_runtime.register_transient_ui(target, &"_on_close_pressed")
	return target


func addlhhjbutton(parent, self_name, father):
	if not lhhjbutton:
		lhhjbutton = _load_scene("res://Scene/other_scene/lhhj_button.tscn")
	var target = instance_scene(lhhjbutton, parent)
	if not target:
		return null
	target.self_name = self_name
	target.father = father
	return target


func add_some_monster_help(parent, position):
	if not some_monster_help:
		some_monster_help = _load_scene("res://Scene/monster/some_monster_help.tscn")
	var target = instance_scene(some_monster_help, parent)
	target.position = position
	return target


func add_mosaic_help(parent, position):
	if not mosaic_help:
		mosaic_help = _load_scene("res://Scene/ldl/mosaic_help.tscn")
	var target = instance_scene(mosaic_help, parent)
	target.position = position
	return target


func add_letter_for_player(parent, position):
	if not letter_for_player:
		letter_for_player = _load_scene("res://Scene/other_scene/a_letter_for_all_players.tscn")
	var target = instance_scene(letter_for_player, parent)
	target.position = position
	return target


func add_cure_times_box(parent, position):
	if not cure_times_box:
		cure_times_box = _load_scene("res://Scene/shop/cure_times_box.tscn")
	var target = instance_scene(cure_times_box, parent)
	target.position = position
	return target


func add_mystery_shop(parent, position):
	return _shop_factory.add_mystery_shop(parent, position)


func add_trans_box(parent, _name, transmogrified):
	if not trans_box:
		trans_box = _load_scene("res://Scene/other_scene/transmogtified_box.tscn")
	var target = instance_scene(trans_box, parent)
	target.self_name = _name
	target.transmogrified = transmogrified
	return target


func add_role4_bullet(parent, Player, position: Vector2):
	if not role4_bullet:
		role4_bullet = _load_scene("res://Scene/hero/role_4/role4_bullet.tscn")
	var target = instance_scene(role4_bullet, parent)
	target.player = Player
	target.position = position
	return target


func add_line(parent, Monster, Type):
	if not line:
		line = _load_scene("res://Scene/level/line_effect.tscn")
	var target = instance_scene(line, parent)
	target.position = Vector2(0, 0)
	target.type = Type
	target.monster = Monster
	return target


func add_dsg_choose(parent):
	if not dsg_choose:
		dsg_choose = _load_scene("res://Scene/level/dsg_choose.tscn")
	var target = instance_scene(dsg_choose, parent)
	target.position = Vector2(0, 0)
	return target


func add_hdzm(parent, parent_node):
	if not _hdzm:
		_hdzm = _load_scene("res://Scene/level/hdzm.tscn")
	var target = instance_scene(_hdzm, parent)
	target.scale = Vector2.ONE
	target.position = viewport_center_for_parent(parent) - Vector2(493, 260)
	target.parent_node = parent_node
	_ui_runtime.register_transient_ui(target, &"_on_close_pressed")
	var guard_script = load("res://Script/level/hdzm_window_guard.gd")
	if guard_script != null:
		var guard = guard_script.new()
		get_tree().root.add_child(guard)
		guard.setup(target)
	return target


func add_lsh(parent, parent_node):
	if not _lsh:
		_lsh = _load_scene("res://Scene/other_scene/lsh.tscn")
	var target = instance_scene(_lsh, parent)
	target.scale = Vector2.ONE
	target.position = viewport_center_for_parent(parent) - Vector2(492, 254)
	_ui_runtime.register_transient_ui(target, &"_on_close_pressed")
	return target


func add_lxdy(parent, parent_node):
	if not _lxdy:
		_lxdy = _load_scene("res://Scene/other_scene/lxdy.tscn")
	var target = instance_scene(_lxdy, parent)
	target.scale = Vector2.ONE
	target.position = viewport_center_for_parent(parent) - Vector2(461, 282)
	_ui_runtime.register_transient_ui(target, &"_on_close_pressed")
	return target


func add_monster_info(parent, monster_name, position):
	if not monster_info:
		monster_info = _load_scene("res://Scene/monster/boss_info.tscn")
	var target = instance_scene(monster_info, parent)
	target.monster_name = monster_name
	target.position = position
	return target


func add_basic_monment_info(parent, show_text, position):
	if not basic_monment_info:
		basic_monment_info = _load_scene("res://Scene/other_scene/basic_monment_info.tscn")
	var target = instance_scene(basic_monment_info, parent)
	target.show_text = show_text
	target.position = position
	return target


func add_forge_help(parent, position):
	if not forge_help:
		forge_help = _load_scene("res://Scene/ldl/forge_help.tscn")
	var target = instance_scene(forge_help, parent)
	target.position = position
	return target


func add_forge_box(parent, Name, Num):
	if not forge_box:
		forge_box = _load_scene("res://Scene/ldl/forge_material_box.tscn")
	var target = instance_scene(forge_box, parent)
	target.item_name = Name
	target.need_num = Num
	return target


func add_forges(parent, position):
	if not forges:
		forges = _load_scene("res://Scene/ldl/forge.tscn")
	var target = instance_scene(forges, parent)
	target.position = position
	return target


func addllbt_challenge(parent, position):
	if not llbt_challenge:
		llbt_challenge = _load_scene("res://Scene/level/llbt_challenge.tscn")
	var target = instance_scene(llbt_challenge, parent)
	target.position = position
	return target


func add_basic_pellet(parent, position):
	if not basic_pellet:
		basic_pellet = _load_scene("res://Scene/pellet/basic_pellet.tscn")
	var target = instance_scene(basic_pellet, parent)
	target.position = position
	return target


func add_game_announcement(parent, position):
	if not game_announcement:
		game_announcement = _load_scene("res://Scene/main_menu/game_announcement.tscn")
	var target = instance_scene(game_announcement, parent)
	_ui_runtime.register_transient_ui(target, &"_on_close_pressed")
	if target is CanvasLayer:
		target.offset = position
	elif target is Node2D or target is Control:
		target.position = position
	return target


func add_font_instance(parent, show_text, font, font_size, font_color, out_line_size, out_line_color):
	if not add_font:
		add_font = _load_scene("res://Scene/show_text/message_info.tscn")
	var target = instance_scene(add_font, parent)
	if font == null:
		target.font = null
	else:
		target.font = load(font)
	target.show_text = show_text
	target.font_color = font_color
	target.out_line_size = out_line_size
	target.out_line_color = out_line_color
	target.font_size = font_size
	return target


func add_task_reward(parent, ItemName, total_num):
	return _reward_factory.add_task_reward(parent, ItemName, total_num)


func add_basic_task(parent, position):
	return _reward_factory.add_basic_task(parent, position)


func add_task_title(parent, task_type, task_name, my_father):
	if not task_title:
		task_title = _load_scene("res://Scene/task/task_title.tscn")
	var target = instance_scene(task_title, parent)
	target.task_name = task_name
	target.task_type = task_type
	target.my_father = my_father
	target.z_index = 99
	return target


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
	if role_id == 6:
		if role_body != null:
			role_body.texture = _ne_zha_static_preview_texture(NeZhaEquipmentVisuals.get_body_frames("Empty"))
		if role_equipment != null:
			role_equipment.texture = _ne_zha_static_preview_texture(NeZhaEquipmentVisuals.get_weapon_frames("Empty"))
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


func center_node_on_screen(node: Node, fallback_size := Vector2(940, 590)) -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	var size = fallback_size
	if node.has_method("get_rect"):
		size = node.get_rect().size
	if node is Node2D:
		(node as Node2D).position = (viewport_size - size) * 0.5


func popup_ui_scale() -> float:
	var viewport_size = get_viewport().get_visible_rect().size
	return min(viewport_size.x / 940.0, viewport_size.y / 590.0)


func apply_popup_screen_layout(node: Node, position: Vector2, estimated_size := Vector2(240, 240)) -> void:
	var viewport_size = get_viewport().get_visible_rect().size
	var final_pos = position
	if final_pos.x + estimated_size.x > viewport_size.x:
		final_pos.x = position.x - estimated_size.x - 50.0
	if final_pos.x < 0.0:
		final_pos.x = 8.0
	if final_pos.y < 0.0:
		final_pos.y = 8.0
	if node is Node2D:
		(node as Node2D).position = final_pos
	elif node is Control:
		(node as Control).position = final_pos


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
	if not decompose_help:
		decompose_help = _load_scene("res://Scene/ldl/decompose_help.tscn")
	var target = instance_scene(decompose_help, parent)
	target.position = position
	return target


func add_decompose_instance(parent, position):
	if not decompose:
		decompose = _load_scene("res://Scene/ldl/decompose.tscn")
	var target = instance_scene(decompose, parent)
	target.position = position
	return target


func add_zztw_trap(parent, Name, position):
	if not zztwtrap:
		zztwtrap = _load_scene("res://Scene/level/zztw_trap.tscn")
	var target = instance_scene(zztwtrap, parent)
	target.my_name = Name
	target.position = position
	return target


func add_stage(parent, stage_type: String, position: Vector2):
	if not stage:
		stage = _load_scene("res://Scene/level/jctfloor_1.tscn")
	var target = instance_scene(stage, parent)
	target.type = stage_type
	target.position = position
	return target


func add_boss_blood_instance(parent, Obj):
	return _combat_factory.add_boss_blood_instance(parent, Obj)


func add_hc_help(parent, position):
	if not hc_help:
		hc_help = _load_scene("res://Scene/other_scene/hc_help.tscn")
	var target = instance_scene(hc_help, parent)
	target.position = position
	return target


func add_help_thing(parent, position, item_info):
	if not help_thing:
		help_thing = _load_scene("res://Scene/other_scene/help_things.tscn")
	var target = instance_scene(help_thing, parent)
	target.item_info = item_info
	target.position = position
	return target


func add_pj(parent, position, Num):
	if not pj:
		pj = _load_scene("res://Scene/other_scene/ping_jia.tscn")
	var target = instance_scene(pj, parent)
	target.num = Num
	target.position = position
	return target


func get_current_level_fall_pro(default_pro: float) -> float:
	if level_drop_pro_data.is_empty():
		var level_info_scene = _load_scene("res://Scene/other_scene/level_info.tscn")
		if level_info_scene != null:
			var probe = level_info_scene.instantiate()
			if probe != null:
				sync_level_drop_pro_data(probe.level_info)
				probe.queue_free()
	var level_name = str(current_level)
	var base_pro = -1.0
	if level_name != "" and level_drop_pro_data.has(level_name):
		base_pro = float(level_drop_pro_data[level_name])
	var effective_pro = default_pro
	if base_pro >= 0.0:
		var diff = int(MainSet.set_data.get("Difficult", 0))
		var multipliers = [1.0, 2.0, 3.0, 3.0]
		diff = clampi(diff, 0, multipliers.size() - 1)
		effective_pro = base_pro * multipliers[diff] / 100.0
	if RoleProp.source_player != null and RoleProp.source_player.is_double_fall_pro:
		effective_pro *= 2.0
	return clampf(effective_pro, 0.0, 1.0)


func sync_level_drop_pro_data(level_info: Dictionary) -> void:
	level_drop_pro_data.clear()
	for level_name in level_info.keys():
		level_drop_pro_data[level_name] = level_info[level_name].get("fall_pro", 0)


func _enter_level_without_info(parent, path):
	if str(path).begins_with("res://Scene/level/") and not is_archive_session_active():
		add_message_show(parent, "请先进入一个存档后再挑战关卡。", 1.5, Vector2(470, 300))
		return null
	if path == "res://Scene/level/level_llbt.tscn":
		return addllbt_challenge(parent, Vector2(0, 0))
	if not str(path).begins_with("res://"):
		return add_dsg_choose(parent)
	change_scene(path)
	return null


func add_level_info(parent, Name, position, path):
	if not is_archive_session_active():
		add_message_show(parent, "请先进入一个存档后再挑战关卡。", 1.5, Vector2(470, 300))
		return null
	current_level = Name
	var show_level_info := bool(MainSet.set_data.get("LevelInfo", true))
	if (
		str(path)
		in [
			"res://Scene/level/level_stz.tscn",
			"res://Scene/level/level_esbxx.tscn",
			"res://Scene/level/level_tzsijian.tscn",
			"res://Scene/level/level_sssl.tscn",
			"res://Scene/level/level_bxgh.tscn"
		]
	):
		show_level_info = true
	if str(path) == "res://Scene/level/level_tzsijian.tscn":
		four_swords_endless_mode = false
	if str(path) == "res://Scene/level/level_stz.tscn":
		three_prince_endless_mode = false
	if str(path) == "res://Scene/level/level_sssl.tscn":
		sss_lendless_mode = false
	if str(path) == "res://Scene/level/level_esbxx.tscn":
		constellation_endless_mode = false
	if str(path) == "res://Scene/level/level_bxgh.tscn":
		selected_eight_immortal_id = 0
	if not level_info:
		level_info = _load_scene("res://Scene/other_scene/level_info.tscn")
	if not show_level_info:
		var probe = level_info.instantiate()
		if probe != null:
			probe.level_name = Name
			probe.target_stage_path = path
			sync_level_drop_pro_data(probe.level_info)
			var nightmare_block_message := ""
			if probe.has_method("_get_nightmare_entry_block_message"):
				nightmare_block_message = str(probe.call("_get_nightmare_entry_block_message"))
			probe.free()
			if nightmare_block_message != "":
				add_message_show(parent, nightmare_block_message, 1.5, Vector2(470, 300))
				return null
		return _enter_level_without_info(parent, path)
	var target = instance_scene(level_info, parent)
	if target == null:
		return null
	sync_level_drop_pro_data(target.level_info)
	target.level_name = Name
	target.target_stage_path = path
	if position == Vector2.ZERO or position == Vector2(0, 0):
		target.position = viewport_center_for_parent(parent) - Vector2(470, 295)
	else:
		target.position = position
	_ui_runtime.register_transient_ui(target)
	return target


func add_monster_head(parent, Name, is_boss, ScenePath := ""):
	if not monster_head:
		monster_head = _load_scene("res://Scene/other_scene/monster_head_info.tscn")
	var target = instance_scene(monster_head, parent)
	target.monster_name = Name
	target.is_boss = is_boss
	target.monster_scene_path = ScenePath
	return target


func add_level_fall_box(parent, Inldl, Inhhgz, Name, qh_level, wx, EqProp):
	if not level_fall_box:
		level_fall_box = _load_scene("res://Scene/back_pack/box_1.tscn")
	var target = instance_scene(level_fall_box, parent)
	target.is_in_ldl_gz = Inldl
	target.is_in_hhgz = Inhhgz
	target.qh_level = qh_level
	target.wx = wx
	target.eq_prop = EqProp
	target.get_item_name = Name
	target.set_meta("item_name", Name)
	target.set_meta("level_fall_box", true)
	return target


func add_item_box(parent, Inldl, Inhhgz, Name, qh_level, num, wx, EqProp):
	if not level_fall_box:
		level_fall_box = _load_scene("res://Scene/back_pack/box_1.tscn")
	var target = instance_scene(level_fall_box, parent)
	target.is_in_ldl_gz = Inldl
	target.is_in_hhgz = Inhhgz
	target.qh_level = qh_level
	target.total_number = num
	target.wx = wx
	target.eq_prop = EqProp
	target.get_item_name = Name
	target.set_meta("item_name", Name)
	return target


func add_game_need_know(parent, position):
	if not game_need_know:
		game_need_know = _load_scene("res://Scene/other_scene/game_need_know.tscn")
	var target = instance_scene(game_need_know, parent)
	target.position = position
	return target


func add_role_magic_need(parent, position, _name, old, new):
	if not role_magic_need:
		role_magic_need = _load_scene("res://Scene/skill/role_magic_need.tscn")
	var target = instance_scene(role_magic_need, parent)
	target.position = position
	target.skill_name = _name
	target.current_need = old
	target.next_need = new
	return target


func add_new_bullet(parent, position, dir, _name, dic):
	if not new_bullet:
		new_bullet = _load_scene("res://Scene/hero/bullet_bullet.tscn")
	var target = instance_scene(new_bullet, parent)
	target.position = position
	target._name = _name
	target.hit_dic = dic
	target.direction = dir
	return target


func add_smb_effect(parent, position, dir):
	if not smb_effect:
		smb_effect = _load_scene("res://Scene/hero/role_2/smb_effect.tscn")
	var target = instance_scene(smb_effect, parent)
	target.position = position
	target.dir = dir
	return target


func add_role2_shallow(parent, position, dir):
	if not role2_shallow:
		role2_shallow = _load_scene("res://Scene/base/role2shallow.tscn")
	var target = instance_scene(role2_shallow, parent)
	target.position = position
	target.dir = dir
	return target


func add_role_special_effect(parent, position, dir, _name):
	var effect_name := str(_name)
	var scene = null
	if effect_name in ["sd", "sd2"]:
		scene = load_scene_uncached(ROLE3_SD_SLIM_PATH)
	elif effect_name == "zznh":
		scene = load_scene_uncached(ROLE3_ZZNH_SLIM_PATH)
	else:
		var slim_path := ROLE_SPECIAL_EFFECT_SLIM_DIR.path_join(effect_name + ".tscn")
		scene = load_scene_uncached(slim_path) if ResourceLoader.exists(slim_path) else null
	if scene == null:
		if not role_special_effect:
			role_special_effect = _load_scene("res://Scene/hero/role_special_effect.tscn")
		scene = role_special_effect
	var target = instance_scene(scene, parent)
	target.position = position
	target.special_effect_name = _name
	target.dir = dir
	return target


func _role_bullet_slim_filename(bullet_name: String) -> String:
	var result := ""
	var length := bullet_name.length()
	for index in length:
		var character := bullet_name[index]
		if character >= "A" and character <= "Z":
			var previous := bullet_name[index - 1] if index > 0 else ""
			var next_character := bullet_name[index + 1] if index + 1 < length else ""
			var previous_breaks := (
				(previous >= "a" and previous <= "z")
				or (previous >= "0" and previous <= "9")
				or (previous >= "A" and previous <= "Z" and next_character >= "a" and next_character <= "z")
			)
			if previous_breaks:
				result += "_"
			result += character.to_lower()
		else:
			result += character
	return result + ".tscn"


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
	var bullet_name := str(_name)
	var scene = null
	if bullet_name in ["Role3Bullet2", "TtzsszBullet"]:
		scene = load_scene_uncached(STREAMING_ROLE_BULLET_PATH)
	elif bullet_name == "Role3Bullet3":
		scene = load_scene_uncached(ROLE3_BULLET3_SLIM_PATH)
	else:
		var slim_path := ROLE_BULLET_SLIM_DIR.path_join(_role_bullet_slim_filename(bullet_name))
		if not ResourceLoader.exists(slim_path):
			push_error("Missing slim role bullet scene: " + slim_path)
			return null
		scene = load_scene_uncached(slim_path)
	var target = instance_scene(scene, parent)
	if target == null:
		return
	target.position = position
	target._name = _name
	target.hit_dic = dic
	target.direction = dir
	_assign_attack_source(target, parent, source_player)
	return target


func add_choose_player(parent, _position):
	if not choose_player:
		choose_player = _load_scene("res://Scene/main_menu/choose_player.tscn")
	var target = instance_scene(choose_player, parent)
	target.position = _position
	return target


func add_monster65_bullet(parent, _position):
	if not monster65_bullet:
		monster65_bullet = _load_scene("res://Scene/monster/monster65bullet.tscn")
	var target = instance_scene(monster65_bullet, parent)
	target.position = _position
	return target


func add_aura(parent, _position, value_in, color_type = 0):
	var target = instance_scene(load_cached_scene(AURA_PATH), parent)
	if target == null:
		return null
	target.value = PaSkill.apply_soul_gain_bonus(int(value_in))
	target.set_meta("base_soul_value", int(value_in))
	target.color_type = color_type
	target.position = _position
	return target


func add_buffinfor(parent, _position, Data):
	if not buffinfor:
		buffinfor = _load_scene("res://Scene/other_scene/buff_information.tscn")
	var target = instance_scene(buffinfor, parent)
	target.data_list = Data
	apply_popup_screen_layout(target, _position, Vector2(320, 120))
	prepare_hover_info_popup(target, true)
	return target


func add_buff_icon(parent, Data):
	if parent == null or not is_instance_valid(parent) or parent.is_queued_for_deletion():
		return null
	var buff_scene := load_cached_scene(BUFF_ICON_PATH)
	if buff_scene == null:
		return null
	var target = buff_scene.instantiate()
	if target == null:
		return null
	parent.add_child(target)
	target.data_list = Data
	var buff_name := str(Data.get("Name", "")) if Data is Dictionary else ""
	if not buff_name.is_empty():
		target.name = buff_name
		target.buff_name = buff_name
	return target


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
	if not z_lw_stage:
		z_lw_stage = _load_scene("res://Scene/level/zlw_fly_floor.tscn")
	var target = instance_scene(z_lw_stage, parent)
	target.position = position
	target.direction = dir
	target.speed = speed
	target.max_position_x = max_num
	target.pd = pd
	return target


func add_h_hjm(parent, position):
	if not h_hjm:
		h_hjm = _load_scene("res://Scene/other_scene/transmogrified.tscn")
	var target = instance_scene(h_hjm, parent)
	target.position = position
	return target


func add_change_clothes_jm(parent, position, _name, transmogrified):
	if not change_clothes_jm:
		change_clothes_jm = _load_scene("res://Scene/other_scene/c_hange_clothes_jm.tscn")
	var target = instance_scene(change_clothes_jm, parent)
	target.position = position
	target.self_name = _name
	target.transmogrified = transmogrified
	return target


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
	if not role1_shallow:
		role1_shallow = _load_scene("res://Scene/hero/role1_s_hallow.tscn")
	var target = instance_scene(role1_shallow, parent)
	target.position = position
	target.iniaction = int_action
	target.direction = dir
	_assign_attack_source(target, parent, source_player)
	return target


func add_role_bullet_1(parent, position, _name, dic, source_player: BaseHero = null):
	if not role_bullet_1:
		role_bullet_1 = _load_scene("res://Scene/hero/role_bullet_1.tscn")
	var target = instance_scene(role_bullet_1, parent)
	target.position = position
	target._name = _name
	target.hit_dic = dic
	_assign_attack_source(target, parent, source_player)
	return target


func add_skill_key_set(parent, position, _name):
	if not skill_key_set:
		skill_key_set = _load_scene("res://Scene/skill/skill_key_set.tscn")
	var target = instance_scene(skill_key_set, parent)
	target.position = position
	target.need_name = _name
	return target


func add_game_set(parent, position):
	if not game_set:
		game_set = _load_scene("res://Scene/main_menu/game_set.tscn")
	var target = instance_scene(game_set, parent)
	if target == null:
		return null
	_ui_runtime.register_transient_ui(target, &"_on_return_pressed")
	var design_size := Vector2(942, 589)
	var viewport_size = get_viewport().get_visible_rect().size
	var fit_scale = min(viewport_size.x / design_size.x, viewport_size.y / design_size.y)
	if target is Node2D:
		target.scale = Vector2(fit_scale, fit_scale)
		target.position = viewport_center_for_parent(parent) - design_size * fit_scale * 0.5
	else:
		target.position = position
	return target


func add_mosaic_instance(parent, position):
	if not mosaic:
		mosaic = _load_scene("res://Scene/ldl/mosaic.tscn")
	var target = instance_scene(mosaic, parent)
	target.position = position
	return target


func add_magic_help(parent, position):
	if not magic_help:
		magic_help = _load_scene("res://Scene/magic_weapon/magic_help.tscn")
	var target = instance_scene(magic_help, parent)
	target.z_index = 99
	target.position = position
	return target


func _get_viewport_center_position() -> Vector2:
	return get_viewport().get_visible_rect().size * 0.5


func add_use_magic_weapon(parent, position):
	return _backpack_factory.add_use_magic_weapon(parent, position)


func add_skill_select(parent, position, _name):
	return _backpack_factory.add_skill_select(parent, position, _name)


func add_weapon_bullet(parent, position, _name, list, dir, Rand):
	var scene_path := str(ADD_WEAPON_BULLET_PATHS.get(str(_name), ""))
	if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
		push_error("Missing lazy weapon bullet scene for: " + str(_name))
		return null
	var cache_key := StringName("add_weapon_bullet_" + str(_name))
	var target = instance_scene(_cached_scene(cache_key, scene_path), parent)
	if target == null:
		return null
	target.obj_attack_dict = list
	target.rnd = Rand
	target._name = _name
	target.dir = dir
	target.position = position
	return target


func get_active_pet_preload_data() -> Dictionary:
	if PlayerData.has_method("ensure_pet_dragon"):
		PlayerData.ensure_pet_dragon()
	if PlayerData.has_method("ensure_pet_phoenix"):
		PlayerData.ensure_pet_phoenix()
	if PlayerData.has_method("ensure_pet_turtle"):
		PlayerData.ensure_pet_turtle()
	if PlayerData.has_method("ensure_pet_rabbit"):
		PlayerData.ensure_pet_rabbit()
	if PlayerData.has_method("ensure_pet_mouse"):
		PlayerData.ensure_pet_mouse()
	if PlayerData.has_method("ensure_pet_neat"):
		PlayerData.ensure_pet_neat()
	var pets: Variant = PlayerData.player_data.get(PlayerData.PET_LIST_KEY, [])
	if not (pets is Array):
		return {}
	var active_name := str(PlayerData.player_data.get(PlayerData.ACTIVE_PET_KEY, ""))
	var selected_pet: Dictionary = {}
	var selected_type := ""
	for pet in pets:
		if not (pet is Dictionary) or not bool(pet.get(DataKeys.DEPLOYED, false)):
			continue
		var type_name := str(pet.get(DataKeys.TYPE, ""))
		var pet_name := str(pet.get(DataKeys.ALT_NAME, ""))
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
		if (
			not is_dragon
			and not is_tiger
			and not is_phoenix
			and not is_turtle
			and not is_rabbit
			and not is_mouse
			and not is_neat
		):
			continue
		var pet_type := (
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


func get_active_pet_preload_paths() -> Array[String]:
	var pet_info := get_active_pet_preload_data()
	var pet_type := str(pet_info.get("type", ""))
	if pet_type == "":
		return []
	var stage := (
		clampi(int(pet_info.get("stage", 1)), 1, 2)
		if pet_type == "PetMouse"
		else clampi(int(pet_info.get("stage", 1)), 1, 4)
	)
	var pet_level := int(pet_info.get("level", 1))
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


func prewarm_active_pet_runtime_resources() -> void:
	var request_generation := _runtime_generation
	if not is_runtime_generation_current(request_generation):
		return
	var pet_info := get_active_pet_preload_data()
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
	if pet_signature == _prewarmed_pet_signature:
		return
	var scene_path := ""
	var frames_path := ""
	var bullet_scene_path := ""
	if pet_type == "PetNeat":
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
	_warm_scene_instance(preload_scene_path(scene_path))
	var bullet_scene := preload_scene_path(bullet_scene_path)
	_warm_scene_instance(bullet_scene)
	_preload_sprite_frames_resource(frames_path)
	if pet_type == "PetNeat":
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
	if not is_runtime_generation_current(request_generation):
		return
	_prewarmed_pet_signature = pet_signature


func get_magic_weapon_scene_path(weapon_name: String) -> String:
	return str(MAGIC_WEAPON_SCENE_PATHS.get(weapon_name, ""))


func get_magic_weapon_preload_paths(_name) -> Array[String]:
	var weapon_name := str(_name)
	var paths: Array[String] = []
	var scene_path := str(MAGIC_WEAPON_SCENE_PATHS.get(weapon_name, ""))
	if scene_path != "":
		paths.append(scene_path)
	if weapon_name == "xianyjp":
		(
			paths
			. append_array(
				[
					"res://Scene/monster/monster_zhw/guanyin_summon.tscn",
					"res://Art/monster/guanyin_spine/skeleton.atlas",
					"res://Art/monster/guanyin_spine/guanyin.spine-json",
				]
			)
		)
	return paths


func prewarm_magic_weapon_runtime_resources(_name) -> void:
	if str(_name) != "xianyjp":
		return
	GuanyinSummon.preload_spine_data()


func prepare_magic_weapon_resources(_name) -> void:
	var scene_path := str(MAGIC_WEAPON_SCENE_PATHS.get(str(_name), ""))
	if scene_path == "" or _resource_runtime.is_resource_cached(scene_path):
		return
	await _resource_runtime.preload_paths_threaded([scene_path])


func add_magic_weapon(parent, _name, position, source_player: BaseHero = null):
	return _magic_weapon_runtime.add_magic_weapon(parent, str(_name), position, source_player)


func get_magic_summon_for(player: Node) -> Node:
	return _magic_weapon_runtime.get_magic_summon_for(player)


func set_magic_summon_for(player: Node, summon: Node) -> void:
	_magic_weapon_runtime.set_magic_summon_for(player, summon)


func add_message_show(parent_node, need_text: String, time: float, target_pos: Vector2):
	return _popup_factory.add_message_show(parent_node, need_text, time, target_pos)


## 统一保存反馈：失败时在可见 UI 层提示，并返回 false 供调用方回滚。
func request_save_with_feedback(reason: String, parent: Node = null, failure_prefix: String = "保存失败：") -> bool:
	_suppress_save_failure_feedback = true
	var outcome := MemoryClass.request_save_result(reason, false)
	_suppress_save_failure_feedback = false
	if bool(outcome.get("ok", false)):
		return true
	var target: Node = parent if is_instance_valid(parent) else _ui_runtime.get_popup_layer()
	add_message_show(target, failure_prefix + str(outcome.get("message", "")), 2.0, Vector2.ZERO)
	return false


func add_ws_effect(parent):
	if not ws_effect:
		ws_effect = _load_scene("res://Scene/hero/role_1/ws_effect.tscn")
	var target = instance_scene(ws_effect, parent)
	return target


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
	if not change_background:
		change_background = _load_scene("res://Scene/other_scene/change_back_ground.tscn")
	var target = instance_scene(change_background, parent)
	if target is CanvasLayer:
		target.offset = position
	elif target != null:
		target.position = position
	return target


func add_strength(parent, position):
	return _shop_factory.add_strength(parent, position)


func create_hands(parent, direction, position):
	if not nmw_hands:
		nmw_hands = _load_scene("res://Scene/monster/monster_25.tscn")
	var target = instance_scene(nmw_hands, parent)
	if target == null:
		return null
	target.position = position
	var mr_ani_node = target.get_node_or_null("MonsterDir/mr_ani")
	if mr_ani_node:
		mr_ani_node.flip_h = direction
	return target


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
	if not role_information:
		role_information = _load_scene("res://Scene/level/role_information.tscn")
	if role_information == null or parent == null or not is_instance_valid(parent):
		return null
	var target = role_information.instantiate()
	if target == null:
		return null
	parent.add_child(target)
	target.z_index = 99
	target.position = position
	buff_box = target.buff_box
	return target


func add_learn_skill(parent, position):
	if not skill_learn:
		skill_learn = _load_scene("res://Scene/skill/learn_skill.tscn")
	var target = instance_scene(skill_learn, parent)
	target.z_index = 99
	target.position = position
	_ui_runtime.register_transient_ui(target, &"_on_close_pressed")
	return target


func add_zd_skillscene(parent, position):
	if not zd_skill:
		zd_skill = _load_scene("res://Scene/skill/zd_skill.tscn")
	var target = instance_scene(zd_skill, parent)
	target.z_index = 99
	target.position = position
	return target


func add_bd_skillscene(parent, position):
	if not bd_skill:
		bd_skill = _load_scene("res://Scene/skill/bd_skill.tscn")
	var target = instance_scene(bd_skill, parent)
	target.z_index = 99
	target.position = position
	return target


func add_gm_infor(parent, position):
	if not game_information:
		game_information = _load_scene("res://Scene/main_menu/game_information.tscn")
	var target = instance_scene(game_information, parent)
	target.z_index = 99
	target.position = position
	return target


func add_ldl(parent, position):
	if not ldl:
		ldl = _load_scene("res://Scene/ldl/ldl.tscn")
	var target = instance_scene(ldl, parent)
	target.z_index = 99
	target.position = position
	_ui_runtime.register_transient_ui(target, &"_on_return_pressed")
	return target


func add_pl_sell(parent, position):
	return _backpack_factory.add_pl_sell(parent, position)


func fall_item(parent, position, _name, value_):
	_name = preload("res://Script/data/yutu_equipment_data.gd").role_drop(str(_name))
	if not fall_equ:
		fall_equ = _load_scene("res://Scene/back_pack/equipment_fall.tscn")
	var target = instance_scene(fall_equ, parent)
	target.position = position
	target.item_name = _name
	target._num = value_
	return target


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


func get_ancestor(self_, times):
	var i = 0
	while i < times:
		self_ = self_.get_parent()
		i = i + 1
	return self_


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
	if not music_set:
		music_set = _load_scene("res://Scene/other_scene/choose_music.tscn")
	var target = instance_scene(music_set, parent)
	target.position = position
	return target


func add_camera(parent, position, right):
	if not mycamera:
		mycamera = _load_scene("res://Scene/level/camera.tscn")
	var target = instance_scene(mycamera, parent)
	target.position = position
	target.max_right = right
	return target


func call_hero(who: String, parent, position: Vector2, _dir: bool, player_slot: int = 1):
	var clean_who = who.replace(".0", "").replace(".", "")
	var scene_paths = {
		"role_1": "res://Scene/hero/role_1/role1.tscn",
		"role_2": "res://Scene/hero/role_2/role_2.tscn",
		"role_3": "res://Scene/hero/role_3/role_3.tscn",
		"role_4": "res://Scene/hero/role_4/role_4.tscn",
		"role_5": "res://Scene/hero/role_5/role_5.tscn",
		"role_6": "res://Scene/hero/role_6/role_6.tscn",
		"role_7": "res://Scene/hero/role_7/role_7.tscn"
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


func add_set_menu(parent, position):
	if not set_menu:
		set_menu = _load_scene("res://Scene/set_menu.tscn")
	var target = instance_scene(set_menu, parent)
	target.position = position
	return target


func add_cd_jm(parent, position):
	if not cd_jm:
		cd_jm = _load_scene("res://Scene/archive_interface/read_archive_interface.tscn")
	var target = instance_scene(cd_jm, parent)
	target.position = position
	return target


func add_moment_text(parent, position, text, last_time):
	return _popup_factory.add_moment_text(parent, position, text, last_time)


func add_touch_text(parent, position, text):
	return _popup_factory.add_touch_text(parent, position, text)


func add_back_pack(parent, position):
	return _backpack_factory.add_back_pack(parent, position)


func create_monster(M_id: int, parent, _position: Vector2) -> BaseMonster:
	var path := _monster_scene_path(M_id)
	var scene = load_level_monster_scene(path)
	if scene:
		var target := instance_scene(scene, parent) as BaseMonster
		if target == null:
			return null
		if path != "res://Scene/monster/monster_%d.tscn" % M_id:
			target.name = "Monster_%d" % M_id

			target.set_meta("source_monster_id", M_id)
		target.position = _position
		return target
	return null


func add_hit_text(parent, _position, value, lx, crit, miss):
	return _combat_factory.add_hit_text(parent, _position, value, lx, crit, miss)


func add_monster_blood(parent, _position, value, text):
	return _combat_factory.add_monster_blood(parent, _position, value, text)


func add_mr_hurt(parent, _position):
	return _combat_factory.add_mr_hurt(parent, _position)


func promote_popup_without_moving(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	var in_popup_layer := node.get_parent() == _ui_runtime.get_popup_layer()
	if node is Control:
		var control := node as Control
		var old_position := control.global_position
		control.z_index = 9999
		control.z_as_relative = false
		control.top_level = not in_popup_layer
		control.global_position = old_position
	elif node is Node2D:
		var node_2d := node as Node2D
		var old_transform: Transform2D = node_2d.global_transform
		node_2d.z_index = 9999
		node_2d.z_as_relative = false
		node_2d.top_level = not in_popup_layer
		node_2d.global_transform = old_transform
	elif node is CanvasItem:
		var canvas_item := node as CanvasItem
		canvas_item.z_index = 9999
		canvas_item.z_as_relative = false
		canvas_item.top_level = not in_popup_layer


func set_popup_screen_position(node: Node, screen_position: Vector2) -> void:
	if node == null or not is_instance_valid(node):
		return
	if node is Control:
		(node as Control).global_position = screen_position
	elif node is Node2D:
		(node as Node2D).global_position = screen_position
	elif node is CanvasItem:
		(node as CanvasItem).global_transform.origin = screen_position


func promote_popup_to_global_layer_without_moving(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	var popup_layer := _ui_runtime.get_popup_layer()
	if popup_layer == null or not is_instance_valid(popup_layer):
		promote_popup_without_moving(node)
		return
	var screen_pos := Vector2.ZERO
	if node is Control:
		screen_pos = (node as Control).global_position
	elif node is Node2D:
		screen_pos = (node as Node2D).global_position
	elif node is CanvasItem:
		screen_pos = (node as CanvasItem).get_global_transform().origin
	var old_parent := node.get_parent()
	if old_parent != popup_layer:
		if old_parent != null:
			old_parent.remove_child(node)
		popup_layer.add_child(node)
	set_popup_screen_position(node, screen_pos)
	promote_popup_without_moving(node)
	if node is CanvasItem:
		(node as CanvasItem).visible = true


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


func instance_scene_safe(target_scene_, parent):
	var target = target_scene_.instantiate()
	parent.call_deferred("add_child", target)
	center_popup_texts(target)
	return target


func add_role_bullet_1_safe(parent, position, _name, dic, source_player: BaseHero = null):
	if not role_bullet_1:
		role_bullet_1 = _load_scene("res://Scene/hero/role_bullet_1.tscn")
	var target = role_bullet_1.instantiate()
	target.position = position
	target._name = _name
	target.hit_dic = dic
	_assign_attack_source(target, parent, source_player)
	parent.call_deferred("add_child", target)
	return target


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


func main_remove_child(parent, node_name):
	parent.remove_child(get_node(node_name))


func _physics_process(_delta: float) -> void:
	if MainSet.set_data.has("FileValue"):
		if float(MainSet.set_data["FileValue"]) < float(file_num):
			MainSet.set_data["FileValue"] = file_num
	if box_count > 0:
		box_count -= 1
	lj_count += 1
	if lj_count > 100:
		lj_count = 0
		lj_times = 0
		check_combo_milestone(lj_times)


func check_combo_milestone(current_combo: int):
	if current_combo == 0:
		_last_combo_value = 0
		_pending_combo_milestones.clear()
		return
	if current_combo % 40 == 0 and _last_combo_value % 40 != 0:
		if not _pending_combo_milestones.has(current_combo):
			_pending_combo_milestones[current_combo] = true
			call_deferred("_emit_combo_milestone_deferred", current_combo)
	_last_combo_value = current_combo


func _emit_combo_milestone_deferred(current_combo: int) -> void:
	var tree := get_tree()
	if tree == null:
		return
	await tree.process_frame
	if not is_inside_tree():
		return
	_pending_combo_milestones.erase(current_combo)
	combo_milestone_reached.emit(current_combo)


func get_position_between(Ob_1, Ob_2):
	if Ob_1 == null or Ob_2 == null:
		return Vector2(0, 0)
	var pp_1 = Ob_2.position.x - Ob_1.position.x
	var pp_2 = Ob_2.position.y - Ob_1.position.y
	if pp_1 == 0 or pp_2 == 0:
		return Vector2(0, 0)
	var pp_3 = sqrt(pp_1 * pp_1 + pp_2 * pp_2)
	var pp_4: Vector2 = Vector2(pp_1 / pp_3, pp_2 / pp_3)
	return pp_4


func get_dis_betweem(Ob_1, Ob_2):
	if Ob_1 == null or Ob_2 == null:
		return 0
	var pp_1 = Ob_2.position.x - Ob_1.position.x
	var pp_2 = Ob_2.position.y - Ob_1.position.y
	var pp_3 = sqrt(pp_1 * pp_1 + pp_2 * pp_2)
	return pp_3


func _ne_zha_static_preview_texture(frames: SpriteFrames) -> Texture2D:
	if frames == null or not frames.has_animation(&"wait"):
		return null
	if frames.get_frame_count(&"wait") <= 0:
		return null
	return frames.get_frame_texture(&"wait", 0)


func load_role1_body(_name, role_id: int = 0) -> Texture2D:
	var resolved_role_id := role_id
	if resolved_role_id <= 0:
		resolved_role_id = _current_role_id()
	if resolved_role_id == 7:
		return load("res://Art/hero_picture/role_7/preview.png") as Texture2D
	if resolved_role_id == 6:
		var static_texture := _ne_zha_static_preview_texture(NeZhaEquipmentVisuals.get_body_frames(str(_name)))
		if static_texture == null:
			push_warning("哪吒身体帧加载失败: " + str(_name))
		return static_texture
	var path := (
		"res://Art/hero_picture/role_"
		+ str(resolved_role_id)
		+ "_all_equipment/role_"
		+ str(resolved_role_id)
		+ "_body_"
		+ str(_name).to_lower()
		+ ".png"
	)
	var path_texture := _load_current_role_texture(path, true)
	if path_texture == null:
		push_warning("角色身体贴图加载失败: " + path)
	return path_texture


func load_role1_eq(_name, role_id: int = 0) -> Texture2D:
	var resolved_role_id := role_id
	if resolved_role_id <= 0:
		resolved_role_id = _current_role_id()
	if resolved_role_id == 7:
		return load("res://Art/hero_picture/role_6/official_parts_trial/transparent.tres") as Texture2D
	if resolved_role_id == 6:
		var static_texture := _ne_zha_static_preview_texture(NeZhaEquipmentVisuals.get_weapon_frames(str(_name)))
		if static_texture == null:
			push_warning("哪吒装备帧加载失败: " + str(_name))
		return static_texture
	var path := (
		"res://Art/hero_picture/role_"
		+ str(resolved_role_id)
		+ "_all_equipment/role_"
		+ str(resolved_role_id)
		+ "_eq_"
		+ str(_name).to_lower()
		+ ".png"
	)
	var path_texture := _load_current_role_texture(path, false)
	if path_texture == null:
		push_warning("角色装备贴图加载失败: " + path)
	return path_texture


func _load_current_role_texture(path: String, is_body: bool) -> Texture2D:
	var texture := get_cached_texture(path)
	if texture == null:
		return null
	var previous_path := _current_role_body_texture_path if is_body else _current_role_equipment_texture_path
	if previous_path != "" and previous_path != path:
		_resource_runtime.release_cached_texture(previous_path)
	if is_body:
		_current_role_body_texture_path = path
	else:
		_current_role_equipment_texture_path = path
	return texture


func _current_role_id() -> int:
	var role_id := int(PlayerData.player_data.get("Myself", 1))
	if role_id < 1 or role_id > 7:
		return 1
	return role_id


func get_wx(num):
	var all_wx = ["金", "木", "水", "火", "土"]
	match num:
		0:
			var rr = randi_range(0, 100)
			if rr <= 4:
				return get_random_wx(3, all_wx)
			elif rr > 4 and rr < 10:
				return get_random_wx(2, all_wx)
			else:
				return get_random_wx(1, all_wx)
		1:
			return get_random_wx(1, all_wx)
		2:
			return get_random_wx(2, all_wx)
		3:
			return get_random_wx(3, all_wx)
		4:
			var temp_list = all_wx.duplicate()
			var remove_index = randi_range(0, temp_list.size() - 1)
			temp_list.remove_at(remove_index)
			return temp_list
		5:
			return all_wx
		_:
			return []


func get_random_wx(count, source_list):
	var result = []
	var temp_list = source_list.duplicate()
	for i in range(count):
		if temp_list.size() == 0:
			break
		var random_index = randi_range(0, temp_list.size() - 1)
		result.append(temp_list[random_index])
		temp_list.remove_at(random_index)
	return result


func check_dir_between_two_obj(Player, Monster):
	if Player.position.x >= Monster.position.x:
		if not Player.player_dir:
			return true
	elif Player.position.x < Monster.position.x:
		if Player.player_dir:
			return true
	return false


func remove_all_buff():
	Global.is_mpo = false
	Global.is_ice = false
	Global.is_poision = false
	Global.is_fire = false
	Global.is_speed_down = false
	Global.is_stun = false
	Global.is_bleed = false
	Global.is_eye_fix = false
	Global.is_dead_link = false
	RoleProp.ws_value = 0


func load_item_icon(_name):
	var abc = load("res://Art/backpack/all_items/" + str(_name).to_lower() + ".png")
	return abc


func add_all_item_num(list, Num, NumRange):
	randomize()
	var dic = {}
	for i in list:
		dic[i] = {"Name": i, "Num": 0}
	for i in range(Num):
		var item_name = list[randi_range(0, list.size() - 1)]
		dic[item_name]["Num"] += NumRange
	var list_temp = []
	for i in dic:
		if int(dic[i]["Num"]) == 0:
			list_temp.push_back(i)
	for i in list_temp:
		dic.erase(i)
	for i in dic:
		var num = dic[i]["Num"]
		PlayerData.add_dj(i, num)
	return dic


func get_all_item_num(list, Num, NumRange):
	randomize()
	var dic = {}
	for i in list:
		dic[i] = {"Name": i, "Num": 0}
	for i in range(Num):
		var item_name = list[randi_range(0, list.size() - 1)]
		dic[item_name]["Num"] += NumRange
	var list_temp = []
	for i in dic:
		if int(dic[i]["Num"]) == 0:
			list_temp.push_back(i)
	for i in list_temp:
		dic.erase(i)
	for i in dic:
		var item_name = i
		var num = dic[i]["Num"]
		dic[i] = {"Name": item_name, "Value": num, "Prop": {}, "WX": [], "strength_value": 0}
	var ll = []
	for i in dic:
		ll.push_back(dic[i])
	return ll


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


func on_fresh():
	var dic = Time.get_datetime_dict_from_system()
	var my_dic = PlayerData.player_data["MyTime"]
	if my_dic == {}:
		return
	if int(dic["year"]) < int(my_dic["year"]):
		return false
	elif int(dic["year"]) > int(my_dic["year"]):
		return true
	else:
		if int(dic["month"]) < int(my_dic["month"]):
			return false
		elif int(dic["month"]) > int(my_dic["month"]):
			return true
		else:
			if int(dic["day"]) < int(my_dic["day"]):
				return false
			elif int(dic["day"]) > int(my_dic["day"]):
				return true
			else:
				return false


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


func get_clean_name(Name: String):
	var xianyu_body_name_map := {
		"xyfjwk": "wkxysz",
		"xyfjts": "tsxysz",
		"xyfjbj": "bjxysz",
		"xyfjss": "ssxysz",
		"xyfjbl": "blxyfj",
	}
	if xianyu_body_name_map.has(Name):
		return xianyu_body_name_map[Name]
	if Name.get_slice("shishi", 1) != Name:
		return Name.get_slice("shishi", 1)
	elif Name.get_slice("youxiu", 1) != Name:
		return Name.get_slice("youxiu", 1)
	elif Name.get_slice("jingliang", 1) != Name:
		return Name.get_slice("jingliang", 1)
	elif Name.get_slice("putong", 1) != Name:
		return Name.get_slice("putong", 1)
	elif Name.get_slice("xieling", 1) != Name:
		return Name.get_slice("xieling", 1)
	elif Name.get_slice("hunqi", 1) != Name:
		return Name.get_slice("hunqi", 1)
	elif Name.get_slice("chuanshuo", 1) != Name:
		return Name.get_slice("chuanshuo", 1)
	elif Name.get_slice("shenqi", 1) != Name:
		return Name.get_slice("shenqi", 1)
	return Name


func normal_face_player(OBJ, dir, Player):
	if dir:
		OBJ.look_at(Player.position)
	else:
		OBJ.look_at(Player.position)
		OBJ.bullet_ani.flip_v = true


var _monsters_to_track = []


func track_monster(monster: Node):
	if not monster.tree_exited.is_connected(_on_monster_exited.bind(monster)):
		monster.tree_exited.connect(_on_monster_exited.bind(monster))
	_monsters_to_track.append(monster)


func _on_monster_exited(monster: Node):
	print("[Global monitor] Monster deleted: ", monster)
	print_stack()
	print("  delete frame: ", Engine.get_process_frames())

# ==============================================================================
# Phase 6-3: 现代 GDScript 规范 snake_case 双轨兼容函数入口
# ==============================================================================
