extends Node
const DataKeys := preload("res://Script/base/data_keys.gd")
const TEXTURE_ALIASES := preload("res://Script/monster/duplicate_texture_aliases.gd")

signal combo_milestone_reached(milestone: int)
signal sound_settings_changed

const TARGET_MAX_FPS := 150
const SHOW_DEBUG_PERF_OVERLAY := true
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
var _ui_popup_layer
var _active_hover_popup

var _pool_data = {"root": null, "damage_text": [], "mr_hurt": [], "role_be_hit": [], "sound_player": []}
const DAMAGE_TEXT_POOL_LIMIT := 80
const MR_HURT_POOL_LIMIT := 32
const ROLE_BE_HIT_POOL_LIMIT := 24
const SOUND_PLAYER_POOL_LIMIT := 32
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
const MONSTER_SCENE_ALIASES := {
	3043: 3031,
	3044: 3030,
	3045: 3032,
	3046: 3028,
	3053: 3047,
	3054: 3038,
	3055: 3036,
	3064: 3039,
	3072: 3065,
	3073: 3067,
	3074: 3068,
	3075: 3066,
	3178: 3159,
	3183: 3177,
	3126: 3119,
	3145: 3121,
	3146: 3122,
	3221: 3199,
	3226: 3198,
	3274: 3222,
	3275: 3198,
	3321: 3308,
	3322: 3309,
	3340: 3320,
	3341: 3308,
	3342: 3309,
}
var basic_ar_button = null
var weapon_bullet_node = null
var bullet = null
var hit_text = null
var damage_text = null
var monster_blood = null
var monster_be_hit = null
var special_affect = null
var damage_number = null
var miss_effect = null
var combo = null
var combo_num = null
var lj = null
var moment_texxt = null
var message_show = null
var role_bullet = null
var fly_bullet = null
var _chase_bullet = null


func _exit_tree() -> void:
	FrameSequenceStore.clear_cache()
	FrameTextureRequests.shutdown_process()


func _ready() -> void:
	if MainSet != null and MainSet.has_method("apply_frame_rate"):
		MainSet.apply_frame_rate()
	else:
		Engine.max_fps = TARGET_MAX_FPS
	if SHOW_DEBUG_PERF_OVERLAY:
		_create_debug_perf_overlay()
	call_deferred("prewarm_permanent_small_ui_scenes")


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

var _monster_scene_cache = {}
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
var cd_path: String = ""

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
var windows
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
var get_player
var need_change_item: bool = true
var player_dir

var _resource_cache = {}
var _sprite_frames_cache = {}
var _audio_cache = {}
var _texture_cache = {}
var _current_role_body_texture_path: String = ""
var _current_role_equipment_texture_path: String = ""
var _all_hero_skill_resources_preloaded: bool = false
var _prewarmed_role_id: int = 0
var archive_session_active: bool = false
var archive_session_role_id: int = 0
var _archive_session_prewarm_in_progress: bool = false
var _archive_session_generation: int = 0
var _ui_runtime_instance_paths: Dictionary = {}
var _ui_runtime_instance_counts: Dictionary = {}
const PERMANENT_SMALL_UI_SCENE_PATHS := [
	"res://Scene/back_pack/back_pack.tscn",
	"res://Scene/skill/learn_skill.tscn",
	"res://Scene/pet/pet_interface.tscn",
	"res://Scene/back_pack/magic_weapon_infor.tscn",
]
var _permanent_small_ui_scene_cache: Dictionary = {}
var _permanent_ui_prewarm_in_progress := false
var _permanent_ui_prewarmed := false
var _prewarmed_pet_signature: String = ""
var _level_resource_cache_paths: Dictionary = {}
var _level_runtime_warmed_scene_paths: Dictionary = {}
var _level_runtime_prewarmed_monster_ids: Dictionary = {}
var _last_sound_play_msec = {}
var _active_sound_players: Dictionary = {}
var _last_sfx_enabled := true
var _last_sfx_volume := INF
const MOBILE_SFX_VOICE_LIMIT := 24
const DESKTOP_SFX_VOICE_LIMIT := 48
const MOBILE_SFX_PER_SOUND_LIMIT := 4
const DESKTOP_SFX_PER_SOUND_LIMIT := 8
const COOP_DEBUG_TOP_MARGIN := 164.0
var _last_mr_hurt_msec = {}
var _pending_combo_milestones = {}
var _debug_perf_layer: CanvasLayer = null
var _debug_perf_label: Label = null
var _debug_perf_elapsed: float = 0.0
var _debug_perf_last_ticks_msec: int = 0
var _debug_perf_max_frame_ms: float = 0.0
var _sword_damage_text_frame: int = -1
var _sword_damage_text_count: int = 0
var _sword_hit_effect_frame: int = -1
var _sword_hit_effect_count: int = 0
var current_magic_summon: Node = null
var secondary_magic_summon: Node = null


func _get_pool_root() -> Node:
	var root = _pool_data.get("root")
	if root != null and is_instance_valid(root):
		return root
	root = Node.new()
	root.name = "RuntimePool"
	add_child(root)
	_pool_data["root"] = root
	return root


func _take_pooled_node(pool, scene_path: String) -> Node:
	while pool.size() > 0:
		var node = pool.pop_back()
		if is_instance_valid(node):
			return node
	var scene = preload_scene_path(scene_path)
	if scene == null:
		return null
	return scene.instantiate()


func _attach_pooled_node(node: Node, parent: Node) -> void:
	if node == null or parent == null:
		return
	var old_parent = node.get_parent()
	if old_parent != null:
		old_parent.remove_child(node)
	parent.add_child(node)


func _store_pooled_node(node: Node, pool: Array, max_size: int) -> void:
	var old_parent = node.get_parent()
	if old_parent != null:
		old_parent.remove_child(node)
	if pool.size() >= max_size:
		node.queue_free()
		return
	_get_pool_root().add_child(node)
	pool.append(node)


func recycle_damage_text(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	_release_damage_text_count(node)
	_store_pooled_node(node, _pool_data["damage_text"], DAMAGE_TEXT_POOL_LIMIT)


func _release_damage_text_count(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	_active_damage_texts.erase(node.get_instance_id())
	if bool(node.get_meta("damage_text_active", false)):
		node.set_meta("damage_text_active", false)
		_on_damage_text_freed()


func _on_damage_text_tree_exited(node: Node) -> void:
	_release_damage_text_count(node)


func recycle_mr_hurt(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	_store_pooled_node(node, _pool_data["mr_hurt"], MR_HURT_POOL_LIMIT)


func recycle_role_be_hit(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	_store_pooled_node(node, _pool_data["role_be_hit"], ROLE_BE_HIT_POOL_LIMIT)


func recycle_sound_player(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	_active_sound_players.erase(node.get_instance_id())
	if not _pool_data["sound_player"].has(node):
		_store_pooled_node(node, _pool_data["sound_player"], SOUND_PLAYER_POOL_LIMIT)


func _on_sound_player_tree_exiting(instance_id: int) -> void:
	_active_sound_players.erase(instance_id)


func _reserve_sound_voice(sound_key: String, priority: int) -> bool:
	var same_count := 0
	var total_victim: AudioStreamPlayer
	var same_victim: AudioStreamPlayer
	var total_priority := priority
	var same_priority := priority
	for id_value in _active_sound_players.keys():
		var entry: Dictionary = _active_sound_players[id_value]
		var node: Variant = entry.get("node")
		if not is_instance_valid(node) or not node.is_inside_tree() or node.is_queued_for_deletion():
			_active_sound_players.erase(id_value)
			continue
		var node_priority := int(entry["priority"])
		if node_priority < total_priority:
			total_priority = node_priority
			total_victim = node as AudioStreamPlayer
		if str(entry["key"]) == sound_key:
			same_count += 1
			if node_priority < same_priority:
				same_priority = node_priority
				same_victim = node as AudioStreamPlayer
	var mobile := OS.has_feature("mobile")
	var same_limit := MOBILE_SFX_PER_SOUND_LIMIT if mobile else DESKTOP_SFX_PER_SOUND_LIMIT
	var total_limit := MOBILE_SFX_VOICE_LIMIT if mobile else DESKTOP_SFX_VOICE_LIMIT
	var victim: AudioStreamPlayer
	if same_count >= same_limit:
		victim = same_victim
	elif _active_sound_players.size() >= total_limit:
		victim = total_victim
	else:
		return true
	if victim == null:
		return false
	victim.call("_on_finished")
	return true


func _create_debug_perf_overlay() -> void:
	if _debug_perf_layer != null and is_instance_valid(_debug_perf_layer):
		return
	_debug_perf_layer = CanvasLayer.new()
	_debug_perf_layer.name = "DebugPerfOverlay"
	_debug_perf_layer.layer = 4096
	add_child(_debug_perf_layer)
	_debug_perf_label = Label.new()
	_debug_perf_label.name = "DebugPerfLabel"
	_debug_perf_label.z_index = 4096
	_debug_perf_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_debug_perf_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_debug_perf_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_debug_perf_label.add_theme_font_size_override("font_size", 12)
	_debug_perf_label.add_theme_color_override("font_color", Color(0.1, 1.0, 0.25, 1.0))
	_debug_perf_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	_debug_perf_label.add_theme_constant_override("outline_size", 1)
	_debug_perf_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0))
	_debug_perf_label.add_theme_constant_override("shadow_offset_x", 0)
	_debug_perf_label.add_theme_constant_override("shadow_offset_y", 0)
	_debug_perf_layer.add_child(_debug_perf_label)
	_debug_perf_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_debug_perf_label.offset_left = -244.0
	_debug_perf_label.offset_top = 6.0
	_debug_perf_label.offset_right = -24.0
	_debug_perf_label.offset_bottom = 54.0
	_debug_perf_last_ticks_msec = Time.get_ticks_msec()
	_update_debug_perf_overlay()


func _format_debug_memory(bytes_value: int) -> String:
	var mb := float(bytes_value) / 1024.0 / 1024.0
	return str(snapped(mb, 0.1)) + " MB"


func _get_process_memory_from_proc_status() -> Dictionary:
	var result := {"rss": -1, "peak": -1, "source": ""}
	var file := FileAccess.open("/proc/self/status", FileAccess.READ)
	if file == null:
		file = FileAccess.open("/proc/" + str(OS.get_process_id()) + "/status", FileAccess.READ)
	if file == null:
		result["rss"] = OS.get_static_memory_usage()
		result["peak"] = OS.get_static_memory_peak_usage()
		result["source"] = "Godot"
		return result
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.begins_with("VmRSS:"):
			result["rss"] = _parse_proc_status_kb_line(line)
		elif line.begins_with("VmHWM:"):
			result["peak"] = _parse_proc_status_kb_line(line)
	if int(result["rss"]) >= 0:
		result["source"] = "真实"
	else:
		result["rss"] = OS.get_static_memory_usage()
		result["peak"] = OS.get_static_memory_peak_usage()
		result["source"] = "Godot"
	return result


func _parse_proc_status_kb_line(line: String) -> int:
	var parts := line.split(" ", false)
	for part in parts:
		if part.is_valid_int():
			return int(part) * 1024
	return -1


func _update_debug_perf_overlay() -> void:
	if _debug_perf_label == null or not is_instance_valid(_debug_perf_label):
		return
	var coop_node = get_node_or_null("/root/LocalCoop")
	var top_margin := 6.0
	if coop_node != null and coop_node.has_method("is_enabled") and coop_node.is_enabled():
		top_margin = COOP_DEBUG_TOP_MARGIN
	_debug_perf_label.offset_top = top_margin
	_debug_perf_label.offset_bottom = top_margin + 48.0
	var fps := Engine.get_frames_per_second()
	var render_total_mem := int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED))
	_debug_perf_label.text = "FPS: " + str(fps) + "\n显存: " + _format_debug_memory(render_total_mem)
	_debug_perf_max_frame_ms = 0.0


func _debug_count_live_monsters() -> int:
	var tree := get_tree()
	if tree == null or tree.current_scene == null:
		return 0
	var root := tree.current_scene
	var monster_root := root.get_node_or_null("Monster")
	if monster_root == null:
		return 0
	var count := 0
	for child in monster_root.get_children():
		if child is BaseMonster and not child.death():
			count += 1
	return count


func can_show_sword_damage_text() -> bool:
	var frame := int(Engine.get_process_frames())
	if _sword_damage_text_frame != frame:
		_sword_damage_text_frame = frame
		_sword_damage_text_count = 0
	var limit := 3 if OS.has_feature("mobile") else 6
	if _sword_damage_text_count >= limit:
		return false
	_sword_damage_text_count += 1
	return true


func can_show_sword_hit_effect() -> bool:
	var frame := int(Engine.get_process_frames())
	if _sword_hit_effect_frame != frame:
		_sword_hit_effect_frame = frame
		_sword_hit_effect_count = 0
	var limit := 2 if OS.has_feature("mobile") else 4
	if _sword_hit_effect_count >= limit:
		return false
	_sword_hit_effect_count += 1
	return true


func _load_scene(path: String) -> PackedScene:
	if not _is_scene_resource_path(path):
		return null
	if _permanent_small_ui_scene_cache.has(path):
		var permanent_scene: Variant = _permanent_small_ui_scene_cache[path]
		if _is_valid_packed_scene(permanent_scene):
			return permanent_scene
		_permanent_small_ui_scene_cache.erase(path)
	if _resource_cache.has(path) and not _is_valid_packed_scene(_resource_cache[path]):
		_resource_cache.erase(path)
	if not _resource_cache.has(path):
		if _is_runtime_ui_scene_path(path):
			_resource_cache[path] = ResourceLoader.load(path, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE_DEEP)
		else:
			_resource_cache[path] = ResourceLoader.load(path, "PackedScene", ResourceLoader.CACHE_MODE_REUSE)
	var cached_scene: Variant = _resource_cache.get(path)
	if not _is_valid_packed_scene(cached_scene):
		return null
	if path in PERMANENT_SMALL_UI_SCENE_PATHS:
		_permanent_small_ui_scene_cache[path] = cached_scene
	return cached_scene as PackedScene


func _is_scene_resource_path(path: String) -> bool:
	return path.ends_with(".tscn") or path.ends_with(".scn")


func _is_valid_packed_scene(value: Variant) -> bool:
	if not is_instance_valid(value):
		return false
	return value is PackedScene


func load_ui_scene(path: String) -> PackedScene:
	if not _is_runtime_ui_scene_path(path):
		return load(path) as PackedScene
	return _load_scene(path) as PackedScene


func prewarm_permanent_small_ui_scenes() -> void:
	if _permanent_ui_prewarm_in_progress or _permanent_ui_prewarmed:
		return
	_permanent_ui_prewarm_in_progress = true
	for scene_path in PERMANENT_SMALL_UI_SCENE_PATHS:
		if not _permanent_small_ui_scene_cache.has(scene_path):
			_load_scene(scene_path)
		await get_tree().process_frame
	_permanent_ui_prewarm_in_progress = false
	_permanent_ui_prewarmed = true


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


func get_cached_audio(path: String) -> AudioStream:
	var resolved_path := path
	if path.ends_with("/effect4.mp3") and not path.begins_with("res://Music/hero/role_7/"):
		resolved_path = path.replace("effect4.mp3", "effect3.mp3")
	if path == "":
		return null
	if not _audio_cache.has(path):
		_audio_cache[path] = load(resolved_path)
	return _audio_cache[path] as AudioStream


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
	var resolved_path := path
	if path.ends_with("/mp_poision.png"):
		resolved_path = path.replace("mp_poision.png", "poision.png")
	if path == "":
		return null
	resolved_path = TEXTURE_ALIASES.resolve(resolved_path)
	if not _texture_cache.has(path) or _texture_cache[path] == null:
		var texture := load(resolved_path) as Texture2D
		if texture != null:
			_texture_cache[path] = texture
		else:
			_texture_cache.erase(path)
		return texture
	return _texture_cache[path] as Texture2D


func get_zhenfa_icon_path(zhenfa_name: String) -> String:
	return str(ZHENFA_ICON_PATHS.get(zhenfa_name, ""))


func get_zhenfa_icon(zhenfa_name: String) -> Texture2D:
	return get_static_texture(get_zhenfa_icon_path(zhenfa_name))


func get_static_texture(path: String) -> Texture2D:
	if path.is_empty():
		return null
	var resolved_path := TEXTURE_ALIASES.resolve(path)
	if not ResourceLoader.exists(resolved_path):
		return null
	return ResourceLoader.load(resolved_path, "Texture2D", ResourceLoader.CACHE_MODE_REUSE) as Texture2D


func release_cached_texture(path: String) -> void:
	if path == "":
		return
	_texture_cache.erase(path)
	var resolved_path := path
	if resolved_path != path:
		_texture_cache.erase(resolved_path)


func preload_scene_path(path: String) -> PackedScene:
	return _load_scene(path) as PackedScene


func prewarm_skill_page_resources() -> void:
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
	await _preload_paths_threaded(paths)
	skill_learn = _resource_cache.get("res://Scene/skill/learn_skill.tscn") as PackedScene
	zd_skill = _resource_cache.get("res://Scene/skill/zd_skill.tscn") as PackedScene
	bd_skill = _resource_cache.get("res://Scene/skill/bd_skill.tscn") as PackedScene


func load_scene_uncached(path: String) -> PackedScene:
	if path == "":
		return null
	if _resource_cache.has(path):
		return _resource_cache[path] as PackedScene
	var scene := ResourceLoader.load(path, "PackedScene", ResourceLoader.CACHE_MODE_REUSE) as PackedScene
	if scene != null:
		_resource_cache[path] = scene
		_track_level_resource(path)
	return scene


func load_level_monster_scene(path: String) -> PackedScene:
	if path == "":
		return null
	if _monster_scene_cache.has(path):
		return _monster_scene_cache[path] as PackedScene
	var scene := _load_scene(path) as PackedScene
	if scene != null:
		_monster_scene_cache[path] = scene
		_track_level_resource(path)
	return scene


func _canonical_monster_scene_id(monster_id: int) -> int:
	return int(MONSTER_SCENE_ALIASES.get(monster_id, monster_id))


func _monster_scene_path(monster_id: int) -> String:
	return "res://Scene/monster/monster_%d.tscn" % _canonical_monster_scene_id(monster_id)


func preload_level_monster_scenes(monster_ids: Array) -> void:
	var scene_paths: Array = []
	var seen_ids := {}
	for monster_id_value in monster_ids:
		var monster_id := _canonical_monster_scene_id(int(monster_id_value))
		if monster_id <= 0 or seen_ids.has(monster_id):
			continue
		seen_ids[monster_id] = true
		scene_paths.append(_monster_scene_path(monster_id))
	if scene_paths.is_empty():
		return
	_track_level_scene_dependencies(scene_paths)
	await _preload_paths_threaded(scene_paths)
	for path_value in scene_paths:
		var path := str(path_value)
		var scene = _resource_cache.get(path)
		if scene is PackedScene:
			_monster_scene_cache[path] = scene


func prewarm_monster_scene_paths(scene_paths: Array) -> void:
	var pending_paths: Array[String] = []
	for path_value in scene_paths:
		var path := str(path_value)
		if path == "" or _level_runtime_warmed_scene_paths.has(path) or pending_paths.has(path):
			continue
		pending_paths.append(path)
	if pending_paths.is_empty():
		return
	_track_level_scene_dependencies(pending_paths)
	await _preload_paths_threaded(pending_paths)
	await _warm_scene_paths_over_frames(pending_paths, 1)
	for path in pending_paths:
		var scene = _resource_cache.get(path)
		if scene is PackedScene:
			_monster_scene_cache[path] = scene
			_level_runtime_warmed_scene_paths[path] = true


func preload_level_monster_runtime_resources(monster_ids: Array) -> void:
	var requested_monster_ids: Array = monster_ids.duplicate()

	var unique_monster_ids: Array = []
	var seen_monster_ids: Dictionary = {}
	for monster_id_value in requested_monster_ids:
		var monster_id := int(monster_id_value)
		if monster_id <= 0 or seen_monster_ids.has(monster_id) or _level_runtime_prewarmed_monster_ids.has(monster_id):
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
		var monster_id := _canonical_monster_scene_id(int(monster_id_value))
		for path_value in LevelPreloadStore.dynamic_monster_textures(monster_id):
			_append_unique_preload_path(texture_paths, str(path_value))
	if not texture_paths.is_empty():
		var textures_per_frame := 2 if OS.has_feature("mobile") else 5
		if seen_monster_ids.has(3343):
			textures_per_frame = 1
		await preload_level_texture_paths(texture_paths, textures_per_frame)

	if seen_monster_ids.has(5):
		MonsterBullet.warm_monster5_stream_images()
	if seen_monster_ids.has(212):
		for bullet_script in MONSTER_212_BULLET_SCRIPTS:
			bullet_script.prewarm_frames()
			await get_tree().process_frame
	if seen_monster_ids.has(3077):
		var ancestor_script: Script = load("res://Script/monster/wutai_earth_ancestor3077.gd")
		await ancestor_script.prewarm_effects()

	var tiger_stage := 0
	for monster_id in unique_monster_ids:
		if monster_id >= 1501 and monster_id <= 1504:
			tiger_stage = maxi(tiger_stage, monster_id - 1500)
	if tiger_stage > 0:
		await MonsterBullet.prewarm_pet_tiger_runtime(tiger_stage)

	var monster_scene_paths: Array[String] = []
	for monster_id in unique_monster_ids:
		var scene_path := _monster_scene_path(monster_id)
		if ResourceLoader.exists(scene_path) and not monster_scene_paths.has(scene_path):
			monster_scene_paths.append(scene_path)
	var bullet_scene_paths := _collect_monster_bullet_scene_paths(monster_scene_paths)
	for monster_id_value in unique_monster_ids:
		for scene_path_value in LevelPreloadStore.dynamic_monster_scenes(int(monster_id_value)):
			_append_unique_preload_path(bullet_scene_paths, str(scene_path_value))
	await prewarm_monster_bullet_scene_paths(bullet_scene_paths)
	await prewarm_monster_scene_paths(monster_scene_paths)

	for monster_id in unique_monster_ids:
		_level_runtime_prewarmed_monster_ids[monster_id] = true


func preload_level_texture_paths(texture_paths: Array, textures_per_frame: int = 5) -> void:
	var unique_paths: Array = []
	for path_value in texture_paths:
		var path := str(path_value)
		if path == "" or unique_paths.has(path):
			continue
		unique_paths.append(path)
		_track_level_resource(path)
	if unique_paths.is_empty():
		return
	await _preload_paths_threaded(unique_paths)
	await _warm_texture_rids_over_frames(unique_paths, maxi(1, textures_per_frame))


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
	if resource == null:
		return
	if resource is PackedScene or path.ends_with(".tscn"):
		_resource_cache[path] = resource
	elif resource is SpriteFrames:
		_sprite_frames_cache[path] = resource
	elif resource is AudioStream:
		_audio_cache[path] = resource
	elif resource is Texture2D:
		_texture_cache[path] = resource
	else:
		_resource_cache[path] = resource


func _preload_paths_threaded(paths: Array) -> void:
	var request_paths: Array[String] = []
	var seen_paths: Dictionary = {}
	for path_value in paths:
		var path := str(path_value)
		if path == "":
			continue
		if (
			_resource_cache.has(path)
			or _sprite_frames_cache.has(path)
			or _audio_cache.has(path)
			or _texture_cache.has(path)
		):
			continue
		if seen_paths.has(path):
			continue
		seen_paths[path] = true
		request_paths.append(path)

	var batch_size := _get_threaded_preload_batch_size(request_paths.size())
	var batch_start := 0
	while batch_start < request_paths.size():
		var pending: Array[String] = []
		var batch_end := mini(batch_start + batch_size, request_paths.size())
		for index in range(batch_start, batch_end):
			var path := request_paths[index]
			var err = ResourceLoader.load_threaded_request(path)
			if err == OK or err == ERR_BUSY:
				pending.append(path)
			else:
				var resource = load(path)
				_cache_threaded_resource(path, resource)
		while not pending.is_empty():
			var i := pending.size() - 1
			while i >= 0:
				var path := pending[i]
				var status = ResourceLoader.load_threaded_get_status(path)
				if status == ResourceLoader.THREAD_LOAD_LOADED:
					var resource = ResourceLoader.load_threaded_get(path)
					_cache_threaded_resource(path, resource)
					pending.remove_at(i)
				elif (
					status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
				):
					pending.remove_at(i)
				i -= 1
			if not pending.is_empty():
				await get_tree().process_frame
		batch_start = batch_end


func _get_threaded_preload_batch_size(request_count: int) -> int:
	if request_count <= 0:
		return 1
	return mini(request_count, 2 if OS.has_feature("mobile") else 4)


func _warm_scene_paths_over_frames(paths: Array, per_frame: int = 2) -> void:
	var warmed_this_frame := 0
	for path in paths:
		var scene_path := str(path)
		if not _is_scene_resource_path(scene_path):
			continue
		var scene = preload_scene_path(scene_path)
		if scene != null:
			_warm_scene_instance(scene)
			warmed_this_frame += 1
			if warmed_this_frame >= per_frame:
				warmed_this_frame = 0
				await get_tree().process_frame


func _release_warm_audio_players(players: Array[AudioStreamPlayer]) -> void:
	for player in players:
		if player == null or not is_instance_valid(player):
			continue
		player.stop()
		player.stream = null
		player.free()
	players.clear()


func _warm_audio_streams_over_frames(paths: Array, per_frame: int = 2) -> void:
	var players: Array[AudioStreamPlayer] = []
	var batch_size := maxi(1, per_frame)
	for path_value in paths:
		var stream := get_cached_audio(str(path_value))
		if stream == null:
			continue
		var player := AudioStreamPlayer.new()
		player.volume_db = -80.0
		player.stream = stream
		add_child(player)
		player.play()
		players.append(player)
		if players.size() >= batch_size:
			await get_tree().process_frame
			_release_warm_audio_players(players)
	if not players.is_empty():
		await get_tree().process_frame
		_release_warm_audio_players(players)


func _warm_texture_rids_over_frames(paths: Array, per_frame: int = 6) -> void:
	var warmed_this_frame := 0
	for path in paths:
		var texture := get_cached_texture(str(path))
		if texture == null:
			continue
		texture.get_rid()
		warmed_this_frame += 1
		if warmed_this_frame >= per_frame:
			warmed_this_frame = 0
			if DisplayServer.get_name() == "headless":
				await get_tree().process_frame
			else:
				await RenderingServer.frame_post_draw


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
	preload_damage_number_textures()
	_cached_scene(&"hit_text", HIT_TEXT_PATH)
	var damage_scene := _cached_scene(&"damage_text", DAMAGE_TEXT_PATH)
	_cached_scene(&"damage_number", DAMAGE_NUMBER_PATH)
	_cached_scene(&"miss_effect", MISS_EFFECT_PATH)
	var role_be_hit_scene := preload_scene_path(ROLE_BE_HIT_EFFECT_PATH)
	var monster_hit_scene := _cached_scene(&"monster_be_hit", MONSTER_BE_HIT_PATH)
	var monster_blood_scene := _cached_scene(&"monster_blood", MONSTER_BLOOD_PATH)
	var sound_scene := preload_scene_path("res://Scene/all_sound/monster_be_hit.tscn")
	get_cached_audio("res://Music/monster_hurt/6_beattack_by_role1.mp3")
	get_cached_audio("res://Music/hero/9_beattack_by_role2.mp3")
	get_cached_audio("res://Music/hero/49_role1_be_attack.mp3")
	get_cached_audio("res://Music/hero/62_role2_be_attack.mp3")
	get_cached_audio("res://Music/hero/68_role3_be_attack.mp3")
	_seed_runtime_pool("damage_text", damage_scene, COMBAT_HIT_DAMAGE_POOL_SIZE, &"prepare_for_pool")
	_seed_runtime_pool("mr_hurt", monster_hit_scene, COMBAT_HIT_EFFECT_POOL_SIZE)
	_seed_runtime_pool("role_be_hit", role_be_hit_scene, COMBAT_HIT_EFFECT_POOL_SIZE)
	_seed_runtime_pool("sound_player", sound_scene, COMBAT_HIT_SOUND_POOL_SIZE)
	await _prewarm_combat_hit_rendering(monster_blood_scene)


func _seed_runtime_pool(
	pool_name: String, scene: PackedScene, target_size: int, prepare_method: StringName = &""
) -> void:
	if scene == null:
		return
	var pool: Array = _pool_data[pool_name]
	while pool.size() < target_size:
		var node := scene.instantiate()
		if node == null:
			return
		_get_pool_root().add_child(node)
		if prepare_method != &"" and node.has_method(prepare_method):
			node.call(prepare_method)
		if node is CanvasItem:
			(node as CanvasItem).visible = false
		if node is AudioStreamPlayer:
			node.set_physics_process(false)
		pool.append(node)


func _prewarm_combat_hit_rendering(monster_blood_scene: PackedScene) -> void:
	var tree := get_tree()
	if tree == null:
		return
	var warm_root := Node2D.new()
	warm_root.name = "CombatHitPrewarm"
	warm_root.z_index = -4096
	warm_root.position = get_viewport().get_visible_rect().get_center()
	add_child(warm_root)

	var role_hit = _take_pooled_node(_pool_data["role_be_hit"], ROLE_BE_HIT_EFFECT_PATH)
	if role_hit != null:
		_attach_pooled_node(role_hit, warm_root)
		role_hit.setup(Vector2.ONE, false, 1.0)
		role_hit.modulate.a = 0.001

	var damage_sample = _take_pooled_node(_pool_data["damage_text"], DAMAGE_TEXT_PATH)
	if damage_sample != null:
		_attach_pooled_node(damage_sample, warm_root)
		damage_sample.setup(88888888, "physics", false, null)
		damage_sample.modulate.a = 0.001
		var damage_player := damage_sample.get_node_or_null("ShowPlayer") as AnimationPlayer
		if damage_player != null and damage_player.has_animation(&"physics"):
			damage_player.play(&"physics")

	var monster_hits: Array[Node] = []
	for animation_name in [&"hurt_1", &"hurt_2"]:
		var monster_hit = _take_pooled_node(_pool_data["mr_hurt"], MONSTER_BE_HIT_PATH)
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
			_take_pooled_node(_pool_data["sound_player"], "res://Scene/all_sound/monster_be_hit.tscn")
			as AudioStreamPlayer
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
		if not _pool_data["sound_player"].has(sound_player):
			recycle_sound_player(sound_player)
	if is_instance_valid(warm_root):
		warm_root.free()


func _warm_scene_instance(scene: PackedScene) -> void:
	if scene == null:
		return
	var node := scene.instantiate()
	if node != null:
		node.free()


func clear_level_resource_cache() -> void:
	FrameSequenceStore.clear_cache()
	for bullet_script in MONSTER_212_BULLET_SCRIPTS:
		bullet_script.clear_cached_frames()
	for path_value in _level_resource_cache_paths.keys():
		var path := str(path_value)
		_resource_cache.erase(path)
		_sprite_frames_cache.erase(path)
		_texture_cache.erase(path)
		_audio_cache.erase(path)
	_level_resource_cache_paths.clear()
	_level_runtime_warmed_scene_paths.clear()
	_level_runtime_prewarmed_monster_ids.clear()
	_monster_scene_cache.clear()


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
	NeZhaEquipmentVisuals.clear_cached_frames()
	_prewarmed_role_id = 0
	_prewarmed_pet_signature = ""
	_current_role_body_texture_path = ""
	_current_role_equipment_texture_path = ""
	var combat_prefixes := [
		"res://Art/hero_picture/",
		"res://Art/monster/",
		"res://Art/level/",
		"res://Art/pet/",
		"res://Art/magic_weapon/",
		"res://Art/zhuxianjianzhen/",
		"res://Art/add_effect/",
		"res://Art/all_number/",
		"res://Scene/hero/",
		"res://Scene/monster/",
		"res://Scene/magic_weapon/",
		"res://Scene/pet/",
	]
	_erase_cached_paths_by_prefix(_resource_cache, combat_prefixes)
	_erase_cached_paths_by_prefix(_sprite_frames_cache, combat_prefixes)
	_erase_cached_paths_by_prefix(_texture_cache, combat_prefixes)
	_erase_cached_paths_by_prefix(
		_audio_cache,
		[
			"res://Music/hero/",
			"res://Music/monster_hurt/",
			"res://Music/level/",
		]
	)

	hit_text = null
	damage_text = null
	monster_blood = null
	monster_be_hit = null
	special_affect = null
	damage_number = null
	miss_effect = null
	role_bullet = null
	fly_bullet = null
	_chase_bullet = null
	special_effect_bullet = null
	role4_bullet = null
	role_bullet_1 = null
	role1_shallow = null
	monster65_bullet = null
	role_special_effect = null
	role2_shallow = null
	smb_effect = null
	new_bullet = null
	boss_blood = null
	_all_hero_skill_resources_preloaded = false
	if current_magic_summon != null and is_instance_valid(current_magic_summon):
		current_magic_summon.queue_free()
	current_magic_summon = null
	if is_instance_valid(secondary_magic_summon):
		secondary_magic_summon.queue_free()
	secondary_magic_summon = null


func is_archive_exit_scene(scene_path: String) -> bool:
	return (
		scene_path
		in [
			"res://Scene/main_menu/main_menu.tscn",
			"res://Scene/main_menu/choose_player.tscn",
		]
	)


func begin_archive_session() -> void:
	var role_id := _current_role_id()
	if archive_session_active and archive_session_role_id == role_id:
		return
	if archive_session_active and archive_session_role_id != role_id:
		release_role_runtime_resources()
	archive_session_active = true
	archive_session_role_id = role_id
	_archive_session_generation += 1
	if _archive_session_prewarm_in_progress:
		call_deferred("begin_archive_session")
		return
	_archive_session_prewarm_in_progress = true
	var generation := _archive_session_generation
	await prewarm_permanent_small_ui_scenes()
	if generation != _archive_session_generation or not archive_session_active:
		_archive_session_prewarm_in_progress = false
		return
	await prewarm_skill_page_resources()
	if generation != _archive_session_generation or not archive_session_active:
		_archive_session_prewarm_in_progress = false
		return
	await _prewarm_archive_role_resources(role_id)
	if generation != _archive_session_generation or not archive_session_active:
		_archive_session_prewarm_in_progress = false
		return
	_archive_session_prewarm_in_progress = false


func _prewarm_archive_role_resources(role_id: int) -> void:
	var role_paths: Array[String] = []
	role_paths.append_array(get_current_role_equipment_preload_paths(role_id))
	await _preload_paths_threaded(role_paths)
	await prewarm_current_role_runtime_resources(role_id)


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
	if not archive_session_active and archive_session_role_id == 0:
		return
	_archive_session_generation += 1
	clear_combat_runtime_cache()

	HMZ_AWAKEN_EFFECT_SCRIPT.clear_cached_data()
	LYFB_AWAKEN_EFFECT_SCRIPT.clear_cached_data()
	JHSJ_AWAKEN_EFFECT_SCRIPT.clear_cached_data()
	CANG_MU_LONG_YUN_EFFECT_SCRIPT.clear_cached_data()
	ROLE4_POISON_ARRAY_AWAKEN_EFFECT_SCRIPT.clear_cached_data()
	STREAMING_ROLE_BULLET_SCRIPT.clear_cached_frames()
	MIRROR_SCRIPT.clear_cached_frames()
	archive_session_active = false
	archive_session_role_id = 0
	_archive_session_prewarm_in_progress = false


func _clear_runtime_pools() -> void:
	for pool_name in ["damage_text", "mr_hurt", "role_be_hit", "sound_player"]:
		var pool: Array = _pool_data[pool_name]
		for node_value in pool:
			var node := node_value as Node
			if node == null or not is_instance_valid(node):
				continue
			if node is AudioStreamPlayer:
				(node as AudioStreamPlayer).stop()
				(node as AudioStreamPlayer).stream = null
			node.queue_free()
		pool.clear()
	var pool_root := _pool_data.get("root") as Node
	if pool_root != null and is_instance_valid(pool_root):
		pool_root.queue_free()
	_pool_data["root"] = null
	_active_damage_texts.clear()
	_damage_text_count = 0


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
	_erase_cached_paths_by_prefix(_resource_cache, ["res://Art/hero_picture/", "res://Scene/hero/"])
	_erase_cached_paths_by_prefix(_sprite_frames_cache, ["res://Art/hero_picture/"])
	_erase_cached_paths_by_prefix(_texture_cache, ["res://Art/hero_picture/"])
	_erase_cached_paths_by_prefix(_audio_cache, ["res://Music/hero/"])
	special_effect_bullet = null
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


func _erase_cached_paths_by_prefix(cache: Dictionary, prefixes: Array) -> void:
	for path_value in cache.keys():
		var path := str(path_value)
		for prefix in prefixes:
			if path.begins_with(str(prefix)):
				cache.erase(path)
				break


func _track_level_resource(path: String) -> void:
	if path != "":
		_level_resource_cache_paths[path] = true


func _dependency_resource_path(dependency: String) -> String:
	var resource_path_start := dependency.find("res://")
	if resource_path_start >= 0:
		return dependency.substr(resource_path_start)
	return dependency


func _track_level_scene_dependencies(scene_paths: Array) -> void:
	for scene_path_value in scene_paths:
		var scene_path := str(scene_path_value)
		_track_level_resource(scene_path)
		for dependency in ResourceLoader.get_dependencies(scene_path):
			var dependency_path := _dependency_resource_path(str(dependency))
			_track_level_resource(dependency_path)


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


func prewarm_monster_bullet_scene_paths(scene_paths: Array) -> void:
	var pending_paths: Array[String] = []
	for path_value in scene_paths:
		var path := str(path_value)
		if path == "" or _level_runtime_warmed_scene_paths.has(path) or pending_paths.has(path):
			continue
		pending_paths.append(path)
	if pending_paths.is_empty():
		return
	_track_level_scene_dependencies(pending_paths)
	await _preload_paths_threaded(pending_paths)
	var texture_paths: Array = []
	var priority_texture_paths: Array = []
	for scene_path in pending_paths:
		var scene_texture_paths := _collect_scene_texture_dependencies([scene_path])
		for texture_path in scene_texture_paths:
			_append_unique_preload_path(texture_paths, str(texture_path))
			_track_level_resource(str(texture_path))
		for index in range(mini(4, scene_texture_paths.size())):
			_append_unique_preload_path(priority_texture_paths, str(scene_texture_paths[index]))
	await _preload_paths_threaded(texture_paths)
	var textures_per_frame := 2 if OS.has_feature("mobile") else 5
	await _warm_texture_rids_over_frames(priority_texture_paths, textures_per_frame)
	await _warm_scene_paths_over_frames(pending_paths, 1)
	for path in pending_paths:
		var scene = _resource_cache.get(path)
		if scene is PackedScene:
			_level_runtime_warmed_scene_paths[path] = true


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


func prewarm_sprite_frames_paths(paths: Array[String]) -> void:
	await _preload_paths_threaded(paths)


func prewarm_texture_paths(paths: Array[String]) -> void:
	await _preload_paths_threaded(paths)


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


func prewarm_current_role_runtime_resources(role_id: int = 0) -> void:
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
	await _preload_paths_threaded(preload_paths)
	await _warm_scene_paths_over_frames(scene_paths, 1)
	await prewarm_sprite_frames_paths(sprite_frames_paths)
	await prewarm_texture_paths(texture_paths)
	await _warm_audio_streams_over_frames(audio_paths, 2)
	if role_id == 2 and equipped_skills.has("by"):
		BING_YU_EFFECT_SCRIPT.prewarm_frames()
		await get_tree().process_frame
	if role_id == 1 and (equipped_skills.has("hmz") or equipped_skills.has("hmz_ws")) and not special_effect_bullet:
		special_effect_bullet = _load_scene("res://Scene/hero/role_1/hmz_effect/special_effect_bullet.tscn")
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
	elif role_id == 5 and equipped_skills.has("ltjz"):
		LEI_TING_JIE_ZHEN_EFFECT_SCRIPT.prewarm_frames()
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
var back_pack = null
var touch_text = null
var cd_jm = null
var set_menu = null

var mycamera = null
var music_set = null
var target_scene: String = ""
var four_swords_endless_mode: bool = false
var sss_lendless_mode: bool = false
var constellation_endless_mode: bool = false
var three_prince_endless_mode: bool = false

var _preloaded_scene: PackedScene = null
var _preloading_path: String = ""


func preload_next(path: String):
	"Start preloading a scene for instant transition later."
	if path == "" or _preloading_path == path:
		return
	if _resource_cache.has(path):
		_preloaded_scene = _resource_cache[path] as PackedScene
		_preloading_path = path
		return
	_preloading_path = path
	ResourceLoader.load_threaded_request(path)


func _get_preloaded(path: String) -> PackedScene:
	"Check if a preloaded scene is ready, return it or null."
	if _preloaded_scene != null and _preloaded_scene.resource_path == path:
		var ps = _preloaded_scene
		_preloaded_scene = null
		_preloading_path = ""
		return ps
	if _preloading_path == path:
		var status = ResourceLoader.load_threaded_get_status(path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var ps = ResourceLoader.load_threaded_get(path) as PackedScene
			_preloaded_scene = null
			_preloading_path = ""
			return ps
	return null


var main_backpack = null
var sell_or_equ = null
var equ_propeties_box = null
var dj_sell = null
var dj_infor = null
var fall_equ = null
var pl_sell = null
var ldl = null
var game_information = null
var zd_skill = null
var skill_learn = null
var role_information = null
var special_effect_bullet = null
var choose_text = null
var zztwtrap = null
var buff_icon = null
var trap = null
var bd_skill = null
var nmw_hands = null
var qh_jm = null
var change_background = null
var synthesis = null
var magp_infor = null
var shop_ttems = null
var s_hop = null
var ldl_help = null
var choose_item = null
var ws_effect = null

var skill_select = null
var use_magic_weapon = null
var magic_help = null

var sound = null
var mosaic = null
var bgm = null
var role4_bullet = null
var game_set = null
var skill_key_set = null
var role_bullet_1 = null
var role1_shallow = null
var change_clothes_jm = null
var h_hjm = null
var z_lw_stage = null
var after_level_end = null
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
var boss_blood = null
var stage = null
var decompose = null
var decompose_help = null
var reward_box = null
var reward_info = null
var task_title = null
var basic_task = null
var task_reward = null
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
var mystery_shop = null
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
	if not mystery_shop:
		mystery_shop = _load_scene("res://Scene/shop/mystery_shop.tscn")
	var target = instance_scene(mystery_shop, parent)
	if position == Vector2.ZERO or position == Vector2(0, 0):
		target.position = viewport_center_for_parent(parent) - Vector2(458, 293)
	else:
		target.position = position
	return target


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
	return target


func add_lxdy(parent, parent_node):
	if not _lxdy:
		_lxdy = _load_scene("res://Scene/other_scene/lxdy.tscn")
	var target = instance_scene(_lxdy, parent)
	target.scale = Vector2.ONE
	target.position = viewport_center_for_parent(parent) - Vector2(461, 282)
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
	if not task_reward:
		task_reward = _load_scene("res://Scene/task/task_reward.tscn")
	var target = instance_scene(task_reward, parent)
	target.item_id = ItemName
	target.total_num = total_num
	target.z_index = 99
	return target


func add_basic_task(parent, position):
	if not basic_task:
		basic_task = _load_scene("res://Scene/task/basic_task.tscn")
	var target = instance_scene(basic_task, parent)
	if position == Vector2.ZERO or position == Vector2(0, 0):
		target.position = viewport_center_for_parent(parent) - Vector2(470, 295)
	else:
		target.position = position
	return target


func add_task_title(parent, task_type, task_name, my_father):
	if not task_title:
		task_title = _load_scene("res://Scene/task/task_title.tscn")
	var target = instance_scene(task_title, parent)
	target.task_name = task_name
	target.task_type = task_type
	target.my_father = my_father
	target.z_index = 99
	return target


func get_ui_popup_layer() -> CanvasLayer:
	if _ui_popup_layer != null and is_instance_valid(_ui_popup_layer):
		return _ui_popup_layer
	_ui_popup_layer = CanvasLayer.new()
	_ui_popup_layer.name = "GlobalUiPopupLayer"
	_ui_popup_layer.layer = 4096
	get_tree().root.add_child(_ui_popup_layer)
	return _ui_popup_layer


func clear_hover_popup() -> void:
	if _active_hover_popup != null and is_instance_valid(_active_hover_popup):
		_active_hover_popup.queue_free()
	_active_hover_popup = null


func _cleanup_transient_ui_under(root: Node, names: Array) -> void:
	if root == null:
		return
	for child in root.get_children():
		if child == null or not is_instance_valid(child):
			continue
		_cleanup_transient_ui_under(child, names)
		if child.name in names:
			if child is CanvasItem:
				(child as CanvasItem).visible = false
			var child_parent := child.get_parent()
			if child_parent != null:
				child_parent.remove_child(child)
			child.queue_free()


func cleanup_transient_ui() -> void:
	clear_hover_popup()
	if _ui_popup_layer != null and is_instance_valid(_ui_popup_layer):
		for child in _ui_popup_layer.get_children():
			if child != null and is_instance_valid(child):
				child.queue_free()
	var names = [
		"MapShadowTop",
		"MapShadowBottom",
		"MapShadowLeft",
		"MapShadowRight",
		"ShopShadowTop",
		"ShopShadowBottom",
		"ShopShadowLeft",
		"ShopShadowRight",
		"LevelInfo",
		"level_info",
		"BasicTask",
		"Shop",
		"mystery_shop",
		"LDL",
		"ldl",
		"lxdy",
		"lsh",
		"lhhj",
		"LXDY",
		"LSH",
		"LHHJ",
		"Learn_skill",
		"HDZM",
		"return_back_map",
		"game_announcement",
		"GameSet",
		"RewardInterface",
		"Choose_item",
		"choose_scene",
		"message_show",
		"TwentyEightConstellations"
	]
	var scene_root = get_tree().current_scene
	if scene_root != null:
		_cleanup_transient_ui_under(scene_root, names)
	_cleanup_transient_ui_under(get_tree().root, names)


func register_ui_runtime_instance(node: Node, scene_path: String) -> void:
	if node == null or not is_instance_valid(node) or not _is_runtime_ui_scene_path(scene_path):
		return
	var instance_id := node.get_instance_id()
	if _ui_runtime_instance_paths.has(instance_id):
		return
	_ui_runtime_instance_paths[instance_id] = scene_path
	_ui_runtime_instance_counts[scene_path] = int(_ui_runtime_instance_counts.get(scene_path, 0)) + 1
	node.tree_exited.connect(_on_ui_runtime_instance_exited.bind(instance_id), CONNECT_ONE_SHOT)


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


func _on_ui_runtime_instance_exited(instance_id: int) -> void:
	if not _ui_runtime_instance_paths.has(instance_id):
		return
	var scene_path := str(_ui_runtime_instance_paths[instance_id])
	_ui_runtime_instance_paths.erase(instance_id)
	var remaining := maxi(0, int(_ui_runtime_instance_counts.get(scene_path, 1)) - 1)
	if remaining > 0:
		_ui_runtime_instance_counts[scene_path] = remaining
		return
	_ui_runtime_instance_counts.erase(scene_path)
	call_deferred("_release_ui_scene_cache_if_unused", scene_path)


func _release_ui_scene_cache_if_unused(scene_path: String) -> void:
	if int(_ui_runtime_instance_counts.get(scene_path, 0)) > 0:
		return
	if scene_path in PERMANENT_SMALL_UI_SCENE_PATHS:
		return
	_resource_cache.erase(scene_path)
	_clear_packed_scene_members_for_path(scene_path)
	_erase_cached_paths_by_prefix(_texture_cache, _ui_art_prefixes_for_scene(scene_path))


func release_ui_runtime_cache(release_permanent: bool = false) -> void:
	_ui_runtime_instance_paths.clear()
	_ui_runtime_instance_counts.clear()
	for path_value in _resource_cache.keys():
		var scene_path := str(path_value)
		if (
			_is_runtime_ui_scene_path(scene_path)
			and (release_permanent or scene_path not in PERMANENT_SMALL_UI_SCENE_PATHS)
		):
			_resource_cache.erase(scene_path)
	for property_info in get_property_list():
		var property_name := StringName(property_info.get("name", ""))
		var value: Variant = get(property_name)
		if (
			_is_valid_packed_scene(value)
			and _is_runtime_ui_scene_path((value as PackedScene).resource_path)
			and (release_permanent or (value as PackedScene).resource_path not in PERMANENT_SMALL_UI_SCENE_PATHS)
		):
			set(property_name, null)
	if release_permanent or not archive_session_active:
		_erase_cached_paths_by_prefix(
			_texture_cache,
			[
				"res://Art/backpack/",
				"res://Art/skill/",
				"res://Art/shop/",
				"res://Art/ldl/",
				"res://Art/pet/pet_page_resources/",
				"res://Art/main_menu/BodyTraining/",
				"res://Art/lianti/",
				"res://Art/zhenyaota/",
			]
		)
	if release_permanent:
		_permanent_small_ui_scene_cache.clear()
		_permanent_ui_prewarmed = false


func _clear_packed_scene_members_for_path(scene_path: String) -> void:
	for property_info in get_property_list():
		var property_name := StringName(property_info.get("name", ""))
		var value: Variant = get(property_name)
		if _is_valid_packed_scene(value) and (value as PackedScene).resource_path == scene_path:
			set(property_name, null)


func _is_runtime_ui_scene_path(scene_path: String) -> bool:
	if scene_path == "res://Scene/set_menu.tscn" or scene_path == "res://Scene/pet/pet_interface.tscn":
		return true
	for prefix in [
		"res://Scene/back_pack/",
		"res://Scene/skill/",
		"res://Scene/shop/",
		"res://Scene/ldl/",
		"res://Scene/task/",
		"res://Scene/pellet/",
		"res://Scene/archive_interface/",
	]:
		if scene_path.begins_with(prefix):
			return true
	return (
		scene_path
		in [
			"res://Scene/main_menu/body_training.tscn",
			"res://Scene/main_menu/body_training_detail.tscn",
			"res://Scene/main_menu/zhu_xian_sword_page.tscn",
			"res://Scene/main_menu/zhen_yao_tower.tscn",
			"res://Scene/main_menu/game_set.tscn",
			"res://Scene/main_menu/game_announcement.tscn",
			"res://Scene/main_menu/game_information.tscn",
			"res://Scene/other_scene/choose_music.tscn",
			"res://Scene/other_scene/twenty_eight_constellations.tscn",
			"res://Scene/other_scene/zhen_fa_ui.tscn",
			"res://Scene/other_scene/transmogtified_box.tscn",
			"res://Scene/other_scene/transmogrified.tscn",
			"res://Scene/other_scene/change_back_ground.tscn",
			"res://Scene/magic_weapon/magic_help.tscn",
		]
	)


func _ui_art_prefixes_for_scene(scene_path: String) -> Array:
	if scene_path.begins_with("res://Scene/skill/"):
		return ["res://Art/skill/"]
	if scene_path.begins_with("res://Scene/back_pack/"):
		return ["res://Art/backpack/"]
	if scene_path == "res://Scene/pet/pet_interface.tscn":
		return ["res://Art/pet/pet_page_resources/"]
	if scene_path.begins_with("res://Scene/ldl/"):
		return ["res://Art/ldl/"]
	if (
		scene_path == "res://Scene/main_menu/body_training.tscn"
		or scene_path == "res://Scene/main_menu/body_training_detail.tscn"
	):
		return ["res://Art/lianti/"]
	if scene_path == "res://Scene/main_menu/zhen_yao_tower.tscn":
		return ["res://Art/zhenyaota/"]
	return []


func register_hover_popup(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		clear_hover_popup()
		return
	if _active_hover_popup == node:
		return
	clear_hover_popup()
	_active_hover_popup = node


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


func add_reward_info(parent, position, list, use_item_name, use_num):
	if not reward_info:
		reward_info = _load_scene("res://Scene/other_scene/reward_interface.tscn")
	var target = instance_scene(reward_info, parent)
	if position == Vector2.ZERO:
		target.position = viewport_center_for_parent(parent) - Vector2(478, 210)
	else:
		target.position = position
	target.use_num = use_num
	target.use_item_name = use_item_name
	target.reward_items = list
	target.z_index = 99
	return target


func add_reward_box(parent, item_id, num):
	if not reward_box:
		reward_box = _load_scene("res://Scene/other_scene/reward_box_2.tscn")
	var target = instance_scene(reward_box, parent)
	target.item_id = item_id
	target.num = num
	if is_instance_valid(target) and get_tree().paused:
		target.process_mode = Node.PROCESS_MODE_ALWAYS
	return target


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
	if not boss_blood:
		boss_blood = _load_scene(BOSS_BLOOD_PATH)
	var target = instance_scene(boss_blood, parent)
	target.get_obj = Obj
	return target


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
	if path == "res://Scene/level/level_llbt.tscn":
		return addllbt_challenge(parent, Vector2(0, 0))
	if not str(path).begins_with("res://"):
		return add_dsg_choose(parent)
	change_scene(path)
	return null


func add_level_info(parent, Name, position, path):
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


func add_role_bullet(parent, position, dir, _name, dic):
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
	var target = instance_scene(_cached_scene(&"aura_", AURA_PATH), parent)
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
	var buff_scene := _cached_scene(&"buff_icon_", BUFF_ICON_PATH)
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
	if parent == null or not (buff_info is Dictionary):
		return null
	var target = parent.get_parent()
	if target != null and target.get("no_debuff") != null:
		if target.get("no_debuff"):
			if (
				buff_info.has("DeBuff")
				and buff_info["DeBuff"]
				and buff_info["Name"] != "jgz"
				and buff_info["Name"] != "zznh"
			):
				return null
	var new_name := str(buff_info.get("Name", ""))
	if new_name == "":
		return null
	if target is BaseMonster and target.is_control_immune() and is_monster_control_buff(new_name):
		return null
	if (
		(target is BaseHero or target is BaseMonster)
		and target.is_white_bar_control_immune()
		and (is_monster_control_buff(new_name) or new_name == "hanxiangzisleep")
	):
		return null
	var unique_buff_names := [
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
		"SuperArmor",
		"DoubleFallPro",
		"PoisionBody",
		"no_debuff",
		"yxbuff",
		"HealOverTime",
		"MagicDrain",
		"ReverseMove",
		"jgz",
		"zznh",
		"speed_down",
		"defe_reduce",
		"nlls",
		"slzbuff",
		"lpzbuff",
		"tszbuff",
		"lljybuff",
		"PetLifeBonus",
		"PetAttackBonus",
		"PetDefenseBonus",
		"PetManaBonus"
	]
	var can_add := bool(buff_info.get("CanAdd", false)) and new_name != "speed_down"
	if not can_add and new_name in unique_buff_names:
		for child in parent.get_children():
			var child_buff = child.get("buff_info")
			if child_buff is Dictionary and str(child_buff.get("Name", "")) == new_name:
				if child.get("buff_time") != null:
					child.buff_info = buff_info.duplicate(true)
					child.last_value = float(buff_info.get("value", 0.0))
					if new_name == "speed_down" and child.has_method("apply_slow_speed"):
						child.apply_slow_speed()
					child.last_time = float(buff_info.get("AddTime", 0.0))
					if child.buff_time != null:
						child.buff_time.start(float(buff_info.get("AddTime", 0.0)))
					if (
						new_name in ["PetLifeBonus", "PetAttackBonus", "PetDefenseBonus", "PetManaBonus"]
						and child.has_method("refresh_pet_owner_bonus")
					):
						child.refresh_pet_owner_bonus(maxi(0, int(buff_info.get("value", 0))))
					if (
						target is BaseMonster
						and not target.is_control_immune()
						and new_name in ["Ice", "stun", "EyeFix", "Immobilize", "lljybuff"]
					):
						target.interrupt_movement_for_control()
					return child
				return null
	var node_instance = instance_scene(_cached_scene(&"base_buff_", BASE_BUFF_PATH), parent)
	if node_instance == null:
		return null
	if node_instance.has_method("start_buff"):
		var buff_instance = node_instance
		buff_instance.buff_info = buff_info.duplicate(true)
		if (
			target is BaseMonster
			and not target.is_control_immune()
			and new_name in ["Ice", "stun", "EyeFix", "Immobilize", "lljybuff"]
		):
			target.interrupt_movement_for_control()
		return buff_instance
	else:
		print("Invalid BaseBuff instance")
		node_instance.queue_free()
		return null


func add_after_level_end(parent, position):
	if not after_level_end:
		after_level_end = _load_scene("res://Scene/other_scene/after_level_end.tscn")
	var target = instance_scene(after_level_end, parent)
	target.z_index = 9999
	target.top_level = true
	if position != Vector2.ZERO and position != Vector2(0, 0):
		target.position = position
	return target


func add_combo(parent, combo_num_, position):
	for child in parent.get_children():
		if child is Node2D and child.has_method(&"set_combo_num"):
			child.set_combo_num(combo_num_)
			child.position = position
			return child
	var combo_scene = _cached_scene(&"combo", COMBO_PATH)
	if combo_scene == null:
		return null
	var target = combo_scene.instantiate()
	if target == null:
		return null
	parent.add_child(target)
	target.position = position
	if target.has_method(&"set_combo_num"):
		target.set_combo_num(combo_num_)
	else:
		target.combo_num = combo_num_
	return target


func add_combo_num(parent, combo_num_):
	var target = instance_scene(_cached_scene(&"combo_num", COMBO_NUM_PATH), parent)
	if target == null:
		return null
	target.combo_num = combo_num_
	return target


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
	var target = instance_scene(_cached_scene(&"miss_effect", MISS_EFFECT_PATH), parent)
	if target == null:
		return null
	target.position = position
	return target


func add_damage_number(parent, value, type_: String, is_crit: bool, tar):
	if not bool(MainSet.set_data.get("ShowDamageText", true)):
		return null

	var target = instance_scene(_cached_scene(&"damage_number", DAMAGE_NUMBER_PATH), parent)
	if target == null:
		return null
	if is_instance_valid(tar):
		target.target = tar
	else:
		target.target = null
	target.is_crit = is_crit
	target.type = type_
	target.need_number = value
	return target


func set_damage_text_enabled(enabled: bool) -> void:
	MainSet.set_data["ShowDamageText"] = enabled
	if enabled:
		return
	var active_nodes: Array = _active_damage_texts.values()
	for node_value in active_nodes:
		if not is_instance_valid(node_value):
			continue
		var node: Node = node_value as Node
		if node == null:
			continue
		if node.has_method("recycle"):
			node.call("recycle")
		else:
			_release_damage_text_count(node)
			node.queue_free()


var _damage_text_count: int = 0
var _active_damage_texts: Dictionary = {}
var _damage_text_recount_frame: int = -1


func add_damage_text(parent, position, value, type_: String, is_crit: bool, tar):
	if not bool(MainSet.set_data.get("ShowDamageText", true)):
		return null
	if _damage_text_count >= 80:
		if _damage_text_recount_frame != Engine.get_physics_frames():
			_recount_active_damage_texts()
		if _damage_text_count >= 80:
			return null
	_damage_text_count += 1
	var target = _take_pooled_node(_pool_data["damage_text"], DAMAGE_TEXT_PATH)
	if target == null:
		_on_damage_text_freed()
		return null
	_attach_pooled_node(target, parent)
	target.set_meta("damage_text_active", true)
	_active_damage_texts[target.get_instance_id()] = target
	var exit_callback := _on_damage_text_tree_exited.bind(target)
	if not target.tree_exited.is_connected(exit_callback):
		target.tree_exited.connect(exit_callback)
	target.position = position
	if target.has_method("setup"):
		target.setup(value, type_, is_crit, tar)
	else:
		target.target = tar
		target.type = type_
		target.damage_value = value
		target.is_crit = is_crit
	return target


func _recount_active_damage_texts() -> void:
	_damage_text_recount_frame = Engine.get_physics_frames()
	for instance_id in _active_damage_texts.keys():
		var node = _active_damage_texts[instance_id]
		if node == null or not is_instance_valid(node) or not bool(node.get_meta("damage_text_active", false)):
			_active_damage_texts.erase(instance_id)
	_damage_text_count = _active_damage_texts.size()


func _on_damage_text_freed():
	_damage_text_count -= 1
	if _damage_text_count < 0:
		_damage_text_count = 0


func add_role1_shallow(parent, position, dir, int_action):
	if not role1_shallow:
		role1_shallow = _load_scene("res://Scene/hero/role1_s_hallow.tscn")
	var target = instance_scene(role1_shallow, parent)
	target.position = position
	target.iniaction = int_action
	target.direction = dir
	return target


func add_role_bullet_1(parent, position, _name, dic):
	if not role_bullet_1:
		role_bullet_1 = _load_scene("res://Scene/hero/role_bullet_1.tscn")
	var target = instance_scene(role_bullet_1, parent)
	target.position = position
	target._name = _name
	target.hit_dic = dic
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
	var design_size := Vector2(942, 589)
	var viewport_size = get_viewport().get_visible_rect().size
	var fit_scale = min(viewport_size.x / design_size.x, viewport_size.y / design_size.y)
	if target is Node2D:
		target.scale = Vector2(fit_scale, fit_scale)
		target.position = viewport_center_for_parent(parent) - design_size * fit_scale * 0.5
	else:
		target.position = position
	return target


func add_bgm(parent, target_):
	if not bgm:
		bgm = _load_scene("res://Scene/all_sound/bgm.tscn")
	var target = instance_scene(bgm, parent)
	target.target = target_
	return target


func add_mosaic_instance(parent, position):
	if not mosaic:
		mosaic = _load_scene("res://Scene/ldl/mosaic.tscn")
	var target = instance_scene(mosaic, parent)
	target.position = position
	return target


func add_sound(parent, target_, priority: int = 0):
	if not is_instance_valid(parent) or parent.is_queued_for_deletion():
		return null
	if not bool(MainSet.set_data.get("RoleOrMonsterHit", true)):
		return null
	var now_msec := Time.get_ticks_msec()
	var sound_key := str(target_)
	var last_msec := int(_last_sound_play_msec.get(sound_key, -45))
	if now_msec - last_msec < 45:
		return null
	if not _reserve_sound_voice(sound_key, priority):
		return null
	if get_cached_audio(sound_key) == null:
		return null
	var target = _take_pooled_node(_pool_data["sound_player"], "res://Scene/all_sound/monster_be_hit.tscn")
	if target == null:
		return null
	_last_sound_play_msec[sound_key] = now_msec
	_attach_pooled_node(target, parent)
	var instance_id: int = target.get_instance_id()
	var exit_callback := _on_sound_player_tree_exiting.bind(instance_id)
	if not target.tree_exiting.is_connected(exit_callback):
		target.tree_exiting.connect(exit_callback)
	_active_sound_players[instance_id] = {"node": target, "key": sound_key, "priority": priority}
	if target.has_method("setup"):
		target.setup(target_)
	else:
		target.target = target_
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
	if not use_magic_weapon:
		use_magic_weapon = _load_scene("res://Scene/back_pack/use_magic_weapon.tscn")
	var target = instance_scene(use_magic_weapon, parent)
	target.z_index = 99
	target.position = position
	return target


func add_skill_select(parent, position, _name):
	if not skill_select:
		skill_select = _load_scene("res://Scene/back_pack/skill_select.tscn")
	var target = instance_scene(skill_select, parent)
	if target == null:
		return null
	target.weapon_name = str(_name)
	target.position = position
	return target


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
	var frames := _resource_cache.get(path) as SpriteFrames
	if frames == null:
		frames = ResourceLoader.load(path, "SpriteFrames", ResourceLoader.CACHE_MODE_REUSE) as SpriteFrames
		if frames != null:
			_resource_cache[path] = frames


func prewarm_active_pet_runtime_resources() -> void:
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
	_prewarmed_pet_signature = pet_signature


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
	if scene_path == "" or _resource_cache.has(scene_path):
		return
	await _preload_paths_threaded([scene_path])


func add_magic_weapon(parent, _name, position, source_player: BaseHero = null):
	var weapon_name := str(_name)
	if weapon_name in PlayerData.RETIRED_WUDU_MAGIC_WEAPONS:
		return null
	var previous_summon: Node = get_magic_summon_for(source_player)
	if is_instance_valid(previous_summon):
		previous_summon.queue_free()
		set_magic_summon_for(source_player, null)
	var scene_path := str(MAGIC_WEAPON_SCENE_PATHS.get(weapon_name, ""))
	if scene_path == "":
		return null
	var scene := load_scene_uncached(scene_path)
	if scene == null:
		return null
	var target := scene.instantiate()
	if source_player != null:
		target.set_meta("coop_slot", LocalCoop.slot_for(source_player))
		target.set("player", source_player)
	parent.add_child(target)
	if target:
		target.position = position
		if target.has_method("set_magic_weapon_name"):
			target.set_magic_weapon_name(weapon_name)
		set_magic_summon_for(source_player, target)
	return target


func get_magic_summon_for(player: Node) -> Node:
	var summon: Node = (
		secondary_magic_summon
		if is_instance_valid(player) and LocalCoop.slot_for(player) == 2
		else current_magic_summon
	)
	return summon if is_instance_valid(summon) else null


func set_magic_summon_for(player: Node, summon: Node) -> void:
	var slot := LocalCoop.slot_for(player) if is_instance_valid(player) else 1
	if slot == 2:
		secondary_magic_summon = summon
	else:
		current_magic_summon = summon
	if is_instance_valid(summon):
		summon.set_meta("coop_slot", slot)


func add_message_show(parent_node, need_text: String, time: float, target_pos: Vector2):
	var target = instance_scene(_cached_scene(&"message_show", MESSAGE_SHOW_PATH), parent_node)
	if target == null:
		return null
	target.z_index = 999
	if target_pos == Vector2.ZERO or target_pos == Vector2(470, 300):
		target.position = viewport_center_for_parent(parent_node)
	else:
		target.position = target_pos
	target.show_text = need_text
	target.last_time = time
	center_popup_texts(target)
	return target


func add_ws_effect(parent):
	if not ws_effect:
		ws_effect = _load_scene("res://Scene/hero/role_1/ws_effect.tscn")
	var target = instance_scene(ws_effect, parent)
	return target


func add_choose_item(parent, position, list, _name, page):
	list = preload("res://Script/data/yutu_equipment_data.gd").expand_drop_entries(list, "名字")
	if not choose_item:
		choose_item = _load_scene("res://Scene/shop/choose_item.tscn")
	var target = instance_scene(choose_item, parent)
	target._name = _name
	target.page = page
	target._list = list
	target.z_index = 99
	if position == Vector2.ZERO or position == Vector2(460, 260):
		target.position = viewport_center_for_parent(parent)
	else:
		target.position = position
	if is_instance_valid(target) and get_tree().paused:
		target.process_mode = Node.PROCESS_MODE_ALWAYS
	return target


func add_s_y_n_help(parent, position):
	if not ldl_help:
		ldl_help = _load_scene("res://Scene/ldl/s_yn_help.tscn")
	var target = instance_scene(ldl_help, parent)
	target.z_index = 99
	target.position = position
	return target


func add_shop(parent, position):
	if not s_hop:
		s_hop = _load_scene("res://Scene/shop/shop.tscn")
	var target = instance_scene(s_hop, parent)
	target.z_index = 99
	target.position = position
	return target


func add_shop_items(parent, position, _name: String, need_):
	if not shop_ttems:
		shop_ttems = _load_scene("res://Scene/shop/shop_item.tscn")
	var target = instance_scene(shop_ttems, parent)
	target.position = position
	target._item_name = _name
	target.need_lh = int(need_)
	return target


func add_magp_infor(parent, position):
	if not magp_infor:
		magp_infor = _load_scene("res://Scene/back_pack/magic_weapon_infor.tscn")
	var target = instance_scene(magp_infor, parent)
	target.position = position
	return target


func add_synthesis(parent, position):
	if not synthesis:
		synthesis = _load_scene("res://Scene/ldl/synthesis.tscn")
	var target = instance_scene(synthesis, parent)
	target.position = position
	return target


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
	if not qh_jm:
		qh_jm = _load_scene("res://Scene/ldl/strength.tscn")
	var target = instance_scene(qh_jm, parent)
	target.position = position
	return target


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
	var target = instance_scene(_cached_scene(&"chase_bullet_", CHASE_BULLET_PATH), parent)
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
	var target = instance_scene(_cached_scene(&"lj", LIJI_PATH), parent)
	if target == null:
		return null
	target.z_index = 99
	target.position = _position
	return target


func add_trap(parent, _position, _name):
	if not trap:
		trap = _load_scene("res://Scene/level/trap.tscn")
	var target = instance_scene(trap, parent)
	target.z_index = 99
	target._get_name = _name
	target.position = _position
	return target


func add_buff_info(parent, _position, message_text: String):
	return add_message_show(parent, message_text, 1.5, _position)


func add_buff_icon_text(parent, text_):
	if not buff_icon:
		buff_icon = _load_scene("res://Scene/back_pack/buff.tscn")
	var target = instance_scene(buff_icon, parent)
	target.z_index = 99
	target._texture = text_
	return target


func add_special_effect(parent, _position, _name, _scale, direction, _speed):
	var effect_name := str(_name)
	if effect_name == "RoleBeHit" or effect_name == "role_be_hit":
		var role_hit = _take_pooled_node(_pool_data["role_be_hit"], ROLE_BE_HIT_EFFECT_PATH)
		if role_hit == null:
			return null
		_attach_pooled_node(role_hit, parent)
		role_hit.z_index = 99
		role_hit.position = _position
		role_hit.setup(_scale, direction, _speed)
		return role_hit
	var scene_path := SPECIAL_AFFECT_SLIM_DIR.path_join(effect_name + ".tscn")
	if not ResourceLoader.exists(scene_path):
		push_error("Missing slim special effect scene: " + scene_path)
		return null
	var target = instance_scene(_cached_scene(StringName("SpecialAffect_" + effect_name), scene_path), parent)
	if target == null:
		return null
	target.z_index = 99
	target.effect_name = _name
	target._scale = _scale
	target.effect_speed = _speed
	target.effect_dir = direction
	target.position = _position
	return target


func add_choose_text(parent, _position, text_, calm_time):
	if not choose_text:
		choose_text = _load_scene("res://Scene/show_text/choose_scene.tscn")
	var target = instance_scene(choose_text, parent)
	target.z_index = 99
	target.position = _position
	target.my_text = text_
	target.calm_time = calm_time
	if is_instance_valid(target) and get_tree().paused:
		target.process_mode = Node.PROCESS_MODE_ALWAYS
	return target


func add_special_effect_bullet(parent, _position, _scale, _name, dir):
	if not special_effect_bullet:
		special_effect_bullet = _load_scene("res://Scene/hero/role_1/hmz_effect/special_effect_bullet.tscn")
	var target = instance_scene(special_effect_bullet, parent)
	target.z_index = 99
	target.position = _position
	target._scale = _scale
	target.dire = dir
	target.action_name = _name
	return target


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
	return target


func add_pl_sell(parent, position):
	if not pl_sell:
		pl_sell = _load_scene("res://Scene/back_pack/pl_sell.tscn")
	var target = instance_scene(pl_sell, parent)
	target.z_index = 99
	target.position = position
	return target


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
	if not dj_infor:
		dj_infor = _load_scene("res://Scene/back_pack/dj_information.tscn")
	var target = instance_scene(dj_infor, parent)
	target.my_name = _name
	target.z_index = 99
	target.position = position
	left_align_popup_texts(target)
	return target


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
	close_backpack_click_menus(parent)
	if not dj_sell:
		dj_sell = _load_scene("res://Scene/back_pack/dj_sell.tscn")
	var target = instance_scene(dj_sell, parent)
	target.my_page = _page
	target.my_name = _name
	target.z_index = 99
	target.position = position
	return target


func get_ancestor(self_, times):
	var i = 0
	while i < times:
		self_ = self_.get_parent()
		i = i + 1
	return self_


func add_equ_propeties_box(parent, position, _name, qh_level, wx, Data):
	if not equ_propeties_box:
		equ_propeties_box = _load_scene("res://Scene/back_pack/equipment_properies.tscn")
	var target = instance_scene(equ_propeties_box, parent)
	target.z_index = 199
	var item_data: Dictionary = Data.duplicate(true) if Data is Dictionary else {}
	var template: Dictionary = AE.all_equipment.get(str(_name), {})
	if item_data.is_empty() and str(template.get("所属", "")) == "宠物装备":
		item_data = template.duplicate(true)
	var item_type := str(item_data.get(DataKeys.TYPE, template.get(DataKeys.TYPE, "")))
	var belongs_to := str(item_data.get("所属", template.get("所属", "")))
	if (item_type == "宠物装备" or belongs_to == "宠物装备") and target.has_method("setup_pet_equipment"):
		var slot_type := str(item_data.get("装备类型", template.get("装备类型", ""))).strip_edges()
		var pet_instance := {
			"名字": str(item_data.get(DataKeys.NAME, template.get(DataKeys.NAME, _name))),
			"强化等级": int(qh_level),
			"类型": slot_type,
			"装备类型": slot_type,
			"Data": item_data,
		}
		if item_data.has("随机属性") and item_data["随机属性"] is Array:
			pet_instance["随机属性"] = (item_data["随机属性"] as Array).duplicate(true)
		target.call("setup_pet_equipment", pet_instance, maxi(0, int(item_data.get("售价", template.get("售价", 0)))))
	else:
		target.qh_level = qh_level
		target.nam = _name
		target.wx = wx
		target.eq_prop = Data
	target.position = position
	left_align_popup_texts(target)
	return target


func add_se_eq_jm(parent, position, _name, _page, _number):
	close_backpack_click_menus(parent)
	if not sell_or_equ:
		sell_or_equ = _load_scene("res://Scene/back_pack/sell_or_equ.tscn")
	var target = instance_scene(sell_or_equ, parent)
	target.page = _page
	target.number = _number
	target._get_name = _name
	target.z_index = 99
	target.position = position
	return target


func add_main_backpack(parent, position):
	if not main_backpack:
		main_backpack = _load_scene("res://Scene/back_pack/main_backpack.tscn")
	var target = instance_scene(main_backpack, parent)
	target.position = position
	return target


func change_scene(target, force_loading_screen: bool = false):
	var target_path := str(target)
	var exiting_archive := is_archive_exit_scene(target_path)
	if exiting_archive:
		end_archive_session()
	cleanup_transient_ui()
	release_ui_runtime_cache(exiting_archive)

	clear_level_resource_cache()

	var cached = _get_preloaded(target_path)

	if (
		not force_loading_screen
		and cached != null
		and target_path.begins_with("res://Scene/level/")
		and target_path != "res://Scene/level/level_hdzm.tscn"
	):
		get_tree().change_scene_to_packed(cached)
		return

	target_scene = target_path
	get_tree().change_scene_to_file("res://Scene/other_scene/load_scene.tscn")


func _deferred_change_scene():
	get_tree().change_scene_to_file(target_scene)


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
			if player_slot == 1:
				get_player = target
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
	var target = instance_scene(_cached_scene(&"moment_texxt", MOMENT_TEXT_PATH), parent)
	if target == null:
		return null
	target.position = position
	target.show_text = text
	target.last_time = last_time
	target.z_index = 99
	return target


func add_touch_text(parent, position, text):
	if not touch_text:
		touch_text = _load_scene("res://Scene/show_text/touch_text.tscn")
	var target = instance_scene(touch_text, parent)
	target.position = position
	target.z_index = 99
	target.tt = text
	return target


func add_back_pack(parent, position):
	if not back_pack:
		back_pack = _load_scene("res://Scene/back_pack/back_pack.tscn")
	var target = instance_scene(back_pack, parent)
	configure_backpack_role_preview(target)
	target.position = position - Vector2(481, 297)
	target.z_index = 10
	return target


func create_monster(M_id: int, parent, _position: Vector2) -> BaseMonster:
	var scene_id := _canonical_monster_scene_id(M_id)
	var path := _monster_scene_path(scene_id)
	var scene = load_level_monster_scene(path)
	if scene:
		var target := instance_scene(scene, parent) as BaseMonster
		if target == null:
			return null
		if scene_id != M_id:
			target.name = "Monster_%d" % M_id

			target.set_meta("source_monster_id", M_id)
		target.position = _position
		return target
	return null


func add_hit_text(parent, _position, value, lx, crit, miss):
	var target = instance_scene(_cached_scene(&"hit_text", HIT_TEXT_PATH), parent)
	if target == null:
		return null
	target.show_lx = str(lx)
	target.is_crit = crit
	target.is_miss = miss
	target.show_text = value
	target.position = _position
	return target


func add_monster_blood(parent, _position, value, text):
	var target = instance_scene(_cached_scene(&"monster_blood", MONSTER_BLOOD_PATH), parent)
	if target == null:
		return null
	target.bar_value = value
	target.bar_text = text
	target.position = _position
	return target


func add_mr_hurt(parent, _position):
	if parent == null:
		return null
	var now_msec := Time.get_ticks_msec()
	var key := str(parent.get_instance_id())
	var last_msec := int(_last_mr_hurt_msec.get(key, 0))
	if now_msec - last_msec < 55:
		return null
	_last_mr_hurt_msec[key] = now_msec
	var target = _take_pooled_node(_pool_data["mr_hurt"], MONSTER_BE_HIT_PATH)
	if target == null:
		return null
	_attach_pooled_node(target, parent)
	target.modulate = Color.WHITE
	target.position = _position
	if target.has_method("_play_hurt_animation"):
		target._play_hurt_animation()
	return target


func promote_popup_without_moving(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	var in_popup_layer := node.get_parent() == get_ui_popup_layer()
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
	var popup_layer := get_ui_popup_layer()
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
		(target as CanvasItem).top_level = target.get_parent() != get_ui_popup_layer()
	if target is Control:
		(target as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	left_align_popup_texts(target)
	if use_top_level:
		register_hover_popup(target)


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


func add_role_bullet_1_safe(parent, position, _name, dic):
	if not role_bullet_1:
		role_bullet_1 = _load_scene("res://Scene/hero/role_bullet_1.tscn")
	var target = role_bullet_1.instantiate()
	target.position = position
	target._name = _name
	target.hit_dic = dic
	parent.call_deferred("add_child", target)
	return target


func add_bullet_safe(bullet_name, parent, direction, show_speed, position, _hit_name, list):
	var bullet_scene = load_monster_bullet_scene(str(bullet_name))
	if bullet_scene == null:
		return null
	var target = bullet_scene.instantiate()
	target.att_list = list
	target.hit_name = _hit_name
	if str(_hit_name) != "" and list is Dictionary:
		target.obj_attack_dict[_hit_name] = list
	target.position = position
	target.dir = direction
	target.skill_name = bullet_name
	target.speed = show_speed
	parent.call_deferred("add_child", target)
	return target


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
	register_ui_runtime_instance(target, str(target_scene_.resource_path))
	parent.call_deferred("add_child", target)
	center_popup_texts(target)
	return target


func add_bullet(bullet_name: String, parent, direction: bool, show_speed, position, _hit_name, list):
	var target = instance_scene(load_monster_bullet_scene(bullet_name), parent)
	if target == null:
		return null
	target.att_list = list
	target.hit_name = _hit_name
	target.position = position
	target.dir = direction
	target.skill_name = bullet_name
	target.speed = show_speed
	return target


func main_remove_child(parent, node_name):
	parent.remove_child(get_node(node_name))


func _physics_process(_delta: float) -> void:
	var sfx_enabled := bool(MainSet.set_data.get("RoleOrMonsterHit", true))
	var sfx_volume := float(MainSet.set_data.get("MusicFB_2", 0.0))
	if sfx_enabled != _last_sfx_enabled or not is_equal_approx(sfx_volume, _last_sfx_volume):
		_last_sfx_enabled = sfx_enabled
		_last_sfx_volume = sfx_volume
		sound_settings_changed.emit()
	if _debug_perf_label != null and is_instance_valid(_debug_perf_label):
		var now_msec := Time.get_ticks_msec()
		if _debug_perf_last_ticks_msec > 0:
			_debug_perf_max_frame_ms = maxf(_debug_perf_max_frame_ms, float(now_msec - _debug_perf_last_ticks_msec))
		_debug_perf_last_ticks_msec = now_msec
		_debug_perf_elapsed += _delta
		if _debug_perf_elapsed >= 1.0:
			_debug_perf_elapsed = 0.0
			_update_debug_perf_overlay()
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
	await get_tree().process_frame
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
		_texture_cache.erase(previous_path)
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


func check_wd(OBJ):
	var count: int = 0
	for i in OBJ.buff.get_children():
		if i != null:
			if i.buff_info["Name"] == "Voodoo":
				count += 1
	return count


func remove_wd(OBJ):
	for i in OBJ.buff.get_children():
		if i != null:
			if i.buff_info["Name"] == "Voodoo":
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
