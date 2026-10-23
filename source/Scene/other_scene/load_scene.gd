extends CanvasLayer

const DEFAULT_TARGET_SCENE := "res://Scene/main_menu/main_menu.tscn"
const DEFAULT_WINDOW_SIZE := Vector2i(1600, 1000)
const MIN_VISIBLE_SECONDS := 0.0
const HDZM_LEVEL_SCENE := "res://Scene/level/level_hdzm.tscn"
const MAIN_SWORD_ARRAY_WEAPON_SCRIPT := preload("res://Script/magic_weapon/main_sword_array_weapon.gd")
const BADI_EFFECT_SCRIPT := preload("res://Script/hero/ba_di_qian_kun_effect.gd")
const HUOYAN_EFFECT_SCRIPT := preload("res://Script/hero/wu_shuang_huo_yan_jin_jing_effect.gd")
const HMZ_AWAKEN_EFFECT_SCRIPT := preload("res://Script/hero/hmz_awaken_effect.gd")
const LYFB_AWAKEN_EFFECT_SCRIPT := preload("res://Script/hero/lyfb_awaken_effect.gd")
const JHSJ_AWAKEN_EFFECT_SCRIPT := preload("res://Script/hero/jhsj_awaken_effect.gd")
const STREAMING_ROLE_BULLET_SCRIPT := preload("res://Script/hero/streaming_role_bullet.gd")
const MIRROR_SCRIPT := preload("res://Script/magic_weapon/mirror.gd")
const BILUO_EFFECT_SCRIPT := preload("res://Script/hero/bi_luo_tian_effect.gd")
const CANG_MU_LONG_YUN_EFFECT_SCRIPT := preload("res://Script/hero/cang_mu_long_yun_effect.gd")
const ROLE4_POISON_ARRAY_AWAKEN_EFFECT_SCRIPT := preload("res://Script/hero/role4_poison_array_awaken_effect.gd")
const BINGYU_EFFECT_SCRIPT := preload("res://Script/hero/bing_yu_effect.gd")
const LEITING_EFFECT_SCRIPT := preload("res://Script/hero/lei_ting_jie_zhen_effect.gd")
const SMSR_EFFECT_SCRIPT := preload("res://Script/hero/smsr_shenqi_lightning_effect.gd")
const PET_DRAGON_SUMMON_SCRIPT := preload("res://Script/pet/pet_dragon_summon_base.gd")
const PET_TURTLE_SUMMON_SCRIPT := preload("res://Script/pet/pet_turtle_summon_base.gd")
const PET_TURTLE_BULLET_SCRIPT := preload("res://Script/pet/pet_turtle_bullet.gd")
const TZSIJIAN_LEVEL_SCRIPT := preload("res://Script/level/level_tzsijian.gd")
const SWORD_BOSS_BASE_SCRIPT := preload("res://Script/monster/sword_boss_base.gd")
const MONSTER_BULLET_SCRIPT := preload("res://Script/monster/monster_bullet.gd")
const GUANYIN_SUMMON_SCRIPT := preload("res://Script/monster/monster_zhw/guanyin_summon.gd")
const GUANYIN_NORMAL_EFFECT_SCRIPT := preload("res://Script/monster/monster_zhw/guanyin_normal_attack_effect.gd")
const GUANYIN_SKILLA_EFFECT_SCRIPT := preload("res://Script/monster/monster_zhw/guanyin_skill_a_effect.gd")
const GUANYIN_SKILL2_EFFECT_SCRIPT := preload("res://Script/monster/monster_zhw/guanyin_skill2_effect.gd")
const TZSIJIAN_LEVEL_SCENE := "res://Scene/level/level_tzsijian.tscn"
const ZHENYAO_TOWER_LEVEL_SCENE := "res://Scene/level/level_zhen_yao_tower.tscn"
const WANFO_LEVEL_SCRIPT_PATH := "res://Script/level/level_61.gd"
const WANFO_RUNTIME_MONSTER_IDS := [3071, 3076, 3077, 3078, 3080, 3081, 3082]
const ZHENYAO_TOWER_LEVEL_SCRIPT := preload("res://Script/level/level_zhen_yao_tower.gd")
const TZSIJIAN_BG_ROOT := "res://Art/level/game_3_level/level_tzsijian/level_96/bg961_parts"
const TZSIJIAN_BOSS_IDS := [951, 952, 953, 954]

const EXTRA_PRELOAD_PATHS := [
	"res://Art/pet/skillicon/hy.png",
	"res://Art/pet/skillicon/sxhz.png",
	"res://Art/pet/skillicon/hsqj.png",
	"res://Art/pet/skillicon/aoyi.png",
	"res://Art/pet/pet_tiger/model/pet_tiger_stage1_frames.tres",
	"res://Art/pet/pet_tiger/model/pet_tiger_stage2_frames.tres",
	"res://Art/pet/pet_tiger/model/pet_tiger_stage3_frames.tres",
	"res://Art/pet/pet_tiger/model/pet_tiger_stage4_frames.tres",
]

@onready var loading_bar: TextureProgressBar = $PanelContainer/loading_bar
@onready var loading_text: Label = $PanelContainer/loading_bar/loading_text
@onready var message_tips: Label = $bg/Tips

var _load_started := false
var _finishing := false
var _changing_scene := false
var _visible_since_msec := 0
var _pending_paths: Array[String] = []
var _queued_paths: Array[String] = []
var _request_limit := 2
var _total_paths := 0
var _completed_paths := 0
var _target_packed_scene: PackedScene = null
var _first_launch_integrity_required := false
var _first_launch_integrity_valid := true
var _battle_vram_baseline_bytes: int = -1
static var _integrity_verified_this_process := false
var tips_textlist = [
	"神秘商店中有概率出现强化石哦~~",
	"打不过关卡时，可以尝试回去强化装备。",
	"拾取装备时会自动判断背包是否已满。",
	"不同装备品质会用不同颜色显示。",
	"怪物攻击具有不同效果，请小心应对。",
	"宠物、技能和战斗资源会在进入存档时提前加载。",
]


func _ready() -> void:
	_apply_window_policy()
	MemoryClass.main_dq()
	if Global.target_scene == null or Global.target_scene == "":
		Global.target_scene = DEFAULT_TARGET_SCENE
	loading_bar.value = 0.0
	loading_text.text = "0%"
	message_tips.text = "Tips: " + str(tips_textlist[randi_range(0, tips_textlist.size() - 1)])
	_initialize_first_launch_integrity()
	_begin_load_after_first_frame()


func _apply_window_policy() -> void:
	if DisplayServer.get_name() == "headless":
		return
	var usable_rect := DisplayServer.screen_get_usable_rect()
	if usable_rect.size.x < DEFAULT_WINDOW_SIZE.x or usable_rect.size.y < DEFAULT_WINDOW_SIZE.y:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _initialize_first_launch_integrity() -> void:
	if not OS.has_feature("android") or _integrity_verified_this_process:
		return
	_first_launch_integrity_required = true
	_first_launch_integrity_valid = false
	if not Engine.has_singleton("ililililllliiil"):
		push_error("ililililllliiil unavailable")
		return
	var ililililllliiil = Engine.get_singleton("ililililllliiil")
	var check_result: Variant = ililililllliiil.call("ililillliiillil")
	_first_launch_integrity_valid = check_result is bool and bool(check_result)
	if not _first_launch_integrity_valid:
		return
	_integrity_verified_this_process = true


func _show_integrity_failure() -> void:
	loading_bar.value = 0.99
	loading_text.text = "99%"
	message_tips.text = "资源加载失败，请重新安装。"
	_load_started = false


func _begin_load_after_first_frame() -> void:
	await get_tree().process_frame
	# headless（无渲染循环）下 frame_post_draw 永不触发，会挂死加载流程
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
	_visible_since_msec = Time.get_ticks_msec()
	await _start_archive_preload()


func _start_archive_preload() -> void:
	if _is_battle_target_scene():
		_battle_vram_baseline_bytes = -1
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
		_log_battle_vram("battle loading page")
	if not _is_battle_target_scene():
		MAIN_SWORD_ARRAY_WEAPON_SCRIPT.clear_prewarmed_sword_resources()
		SWORD_BOSS_BASE_SCRIPT.clear_prewarmed_sword_boss_frames()
		TZSIJIAN_LEVEL_SCRIPT.clear_prewarmed_background_frames()
		MONSTER_BULLET_SCRIPT.clear_runtime_resource_caches()
		PET_DRAGON_SUMMON_SCRIPT.clear_cached_scenes()
		PET_TURTLE_SUMMON_SCRIPT.clear_cached_scenes()
		PET_TURTLE_BULLET_SCRIPT.clear_cached_frames()
	var paths := _build_archive_preload_paths()
	if _is_battle_target_scene():
		_log_battle_load_context(paths)
	_total_paths = max(paths.size(), 1)
	_completed_paths = 0
	_pending_paths.clear()
	_queued_paths.clear()
	_target_packed_scene = null
	_set_progress(0.0)
	for path in paths:
		_queued_paths.append(path)
	_request_limit = 2 if OS.has_feature("mobile") else 4
	_fill_preload_slots()
	_load_started = true
	if _pending_paths.is_empty() and _queued_paths.is_empty():
		_finish_loading()


func _process(_delta: float) -> void:
	if not _load_started or _changing_scene:
		return
	_poll_pending_paths()


func _build_archive_preload_paths() -> Array[String]:
	var unique := {}
	_append_preload_path(unique, Global.target_scene)
	if not _is_battle_target_scene():
		var light_paths: Array[String] = []
		for unique_path in unique.keys():
			light_paths.append(str(unique_path))
		return light_paths

	for extra_path in EXTRA_PRELOAD_PATHS:
		_append_preload_path(unique, str(extra_path))
	if str(Global.target_scene) == "res://Scene/level/level_esbxx.tscn":
		var constellation_level := clampi(int(Global.selected_constellation_level), 1, 14)
		_append_preload_path(unique, "res://Art/constellations/background/%d.png" % constellation_level)
	for role_path in Global.get_current_role_preload_paths():
		_append_preload_path(unique, role_path)
	for role_path in Global.get_current_role_heavy_effect_paths():
		_append_preload_path(unique, role_path)
	for pet_path in Global.get_active_pet_preload_paths():
		_append_preload_path(unique, pet_path)
	for sword_path in MAIN_SWORD_ARRAY_WEAPON_SCRIPT.get_active_sword_preload_paths():
		_append_preload_path(unique, sword_path)
	for monster_path in _get_target_first_wave_monster_scene_paths():
		_append_preload_path(unique, monster_path)
	var equipped_magic_weapon := str(PlayerData.player_data.get("实战法宝", ""))
	if equipped_magic_weapon == "" and PlayerData.player_data.get(DataKeys.MAGIC_WEAPON, []).size() > 0:
		equipped_magic_weapon = str(PlayerData.player_data[DataKeys.MAGIC_WEAPON][0].get(DataKeys.NAME, ""))
	for magic_weapon_path in Global.get_magic_weapon_preload_paths(equipped_magic_weapon):
		_append_preload_path(unique, magic_weapon_path)
	var result: Array[String] = []
	for result_path in unique.keys():
		result.append(str(result_path))
	return result


func _is_battle_target_scene() -> bool:
	var target_path := str(Global.target_scene)
	if (
		target_path
		in [
			"res://Scene/level/victory.tscn",
			"res://Scene/level/defeat.tscn",
		]
	):
		return false
	return target_path.begins_with("res://Scene/level/")


func _get_tzsijian_bg_preload_paths() -> Array[String]:
	var paths: Array[String] = [TZSIJIAN_BG_ROOT.path_join("base_4.png")]
	for dir_name in ["role", "sword1", "sword2", "sword3", "sword4"]:
		var dir_path := TZSIJIAN_BG_ROOT.path_join(dir_name)
		for file_name in DirAccess.get_files_at(dir_path):
			if file_name.get_extension().to_lower() == "png":
				paths.append(dir_path.path_join(file_name))
	return paths


func _get_tzsijian_boss_preload_paths() -> Array[String]:
	var paths: Array[String] = [
		"res://Scene/monster_blood/boss_blood.tscn",
	]
	for boss_id in TZSIJIAN_BOSS_IDS:
		paths.append("res://Scene/monster/monster_" + str(boss_id) + ".tscn")
	return paths


func _get_target_first_wave_monster_scene_paths() -> Array[String]:
	var paths: Array[String] = []
	var seen_ids := {}
	var monster_group := _target_script_monster_group()
	var first_wave: Variant = monster_group.get("stage_1", [])
	if first_wave is Array:
		for monster_id_value in first_wave:
			var monster_id := int(monster_id_value)
			if monster_id <= 0 or seen_ids.has(monster_id):
				continue
			seen_ids[monster_id] = true
			var scene_path := "res://Scene/monster/monster_%d.tscn" % monster_id
			if ResourceLoader.exists(scene_path):
				paths.append(scene_path)
	if str(Global.target_scene) == TZSIJIAN_LEVEL_SCENE:
		for special_path in ["res://Scene/monster/monster_951.tscn", "res://Scene/monster_blood/boss_blood.tscn"]:
			if ResourceLoader.exists(special_path) and not paths.has(special_path):
				paths.append(special_path)
	return paths


func _append_preload_path(unique: Dictionary, path: String) -> void:
	if path == "" or unique.has(path):
		return
	if ResourceLoader.exists(path):
		unique[path] = true


func _append_scene_dependency_paths(unique: Dictionary, scene_path: String) -> void:
	if scene_path == "":
		return
	var visited := {}
	_append_scene_dependency_paths_recursive(unique, scene_path, visited)


func _append_scene_dependency_paths_recursive(unique: Dictionary, resource_path: String, visited: Dictionary) -> void:
	if resource_path == "" or visited.has(resource_path) or not ResourceLoader.exists(resource_path):
		return
	visited[resource_path] = true
	for dependency in ResourceLoader.get_dependencies(resource_path):
		var dependency_path := _dependency_resource_path(str(dependency))
		if dependency_path.get_extension().to_lower() in ["png", "jpg", "jpeg", "webp", "svg", "tres", "res", "tscn"]:
			_append_preload_path(unique, dependency_path)
		if dependency_path.get_extension().to_lower() in ["tres", "res", "tscn"]:
			_append_scene_dependency_paths_recursive(unique, dependency_path, visited)


func _dependency_resource_path(dependency: String) -> String:
	var resource_path_start := dependency.find("res://")
	if resource_path_start >= 0:
		return dependency.substr(resource_path_start)
	return dependency


func _request_preload_path(path: String) -> void:
	if _is_cached(path):
		_completed_paths += 1
		_set_progress(float(_completed_paths) / float(_total_paths))
		return
	var uncached_target := _is_uncached_target_scene(path)
	var preload_type := "PackedScene" if uncached_target else ""
	var cache_mode := ResourceLoader.CACHE_MODE_IGNORE_DEEP if uncached_target else ResourceLoader.CACHE_MODE_REUSE
	var err := ResourceLoader.load_threaded_request(path, preload_type, false, cache_mode)
	if err == OK or err == ERR_BUSY:
		_pending_paths.append(path)
	else:
		var resource := load(path)
		_cache_resource(path, resource)
		_completed_paths += 1
		_set_progress(float(_completed_paths) / float(_total_paths))


func _fill_preload_slots() -> void:
	while _pending_paths.size() < _request_limit and not _queued_paths.is_empty():
		var path: String = str(_queued_paths.pop_front())
		_request_preload_path(path)


func _poll_pending_paths() -> void:
	var changed := false
	var i := _pending_paths.size() - 1
	while i >= 0:
		var path := _pending_paths[i]
		var status := ResourceLoader.load_threaded_get_status(path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var resource := ResourceLoader.load_threaded_get(path)
			_cache_resource(path, resource)
			_pending_paths.remove_at(i)
			_completed_paths += 1
			changed = true
		elif status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			print("preload failed: ", path)
			_pending_paths.remove_at(i)
			_completed_paths += 1
			changed = true
		i -= 1
	if changed:
		_set_progress(float(_completed_paths) / float(_total_paths))
	_fill_preload_slots()
	if _pending_paths.is_empty() and _queued_paths.is_empty():
		_finish_loading()


func _cache_resource(path: String, resource: Resource) -> void:
	if resource == null:
		return
	if path == Global.target_scene and resource is PackedScene:
		_target_packed_scene = resource as PackedScene
		return
	if Global.has_method("_cache_threaded_resource"):
		Global._cache_threaded_resource(path, resource)
		if _is_battle_target_scene():
			Global._track_level_resource(path)


func _is_cached(path: String) -> bool:
	return Global._resource_cache.has(path) or Global._audio_cache.has(path) or Global._texture_cache.has(path)


func _is_uncached_target_scene(path: String) -> bool:
	return path == str(Global.target_scene) and path.ends_with(".tscn")


func _set_progress(value: float) -> void:
	value = clampf(value, 0.0, 1.0)
	if not _finishing:
		value = minf(value, 0.9)
	loading_bar.value = maxf(float(loading_bar.value), value)
	loading_text.text = str(int(round(value * 100.0))) + "%"


func _log_battle_vram(stage: String) -> void:
	var current_bytes: int = int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED))
	if _battle_vram_baseline_bytes < 0:
		_battle_vram_baseline_bytes = current_bytes
	var delta_bytes: int = current_bytes - _battle_vram_baseline_bytes
	var current_mb: float = float(current_bytes) / 1024.0 / 1024.0
	var delta_mb: float = float(delta_bytes) / 1024.0 / 1024.0
	print("[Battle VRAM] ", stage, " current=", snapped(current_mb, 0.1), " MiB delta=", snapped(delta_mb, 0.1), " MiB")


func _log_battle_load_context(paths: Array[String]) -> void:
	var role_id := int(PlayerData.player_data.get("Myself", 1))
	var magic_weapon := str(PlayerData.player_data.get("实战法宝", ""))
	var pet_info: Dictionary = Global.get_active_pet_preload_data()
	print(
		"[Battle VRAM] target=",
		str(Global.target_scene),
		" role=",
		role_id,
		" role_paths=",
		Global.get_current_role_preload_paths().size(),
		" pet=",
		str(pet_info.get("type", "")),
		" magic_weapon=",
		magic_weapon,
		" archive_paths=",
		paths.size()
	)
	var map_scene_paths: Array[String] = []
	for path_value in paths:
		var path := str(path_value)
		if path.contains("/Scene/Main_menu/Map_") or path.contains("/Art/main_game/"):
			map_scene_paths.append(path)
	print("[Battle VRAM] map_paths=", map_scene_paths)


func _finish_loading() -> void:
	if _finishing or _changing_scene:
		return
	_finishing = true
	var equipped_magic_weapon := str(PlayerData.player_data.get("实战法宝", ""))
	if equipped_magic_weapon == "" and PlayerData.player_data.get(DataKeys.MAGIC_WEAPON, []).size() > 0:
		equipped_magic_weapon = str(PlayerData.player_data[DataKeys.MAGIC_WEAPON][0].get(DataKeys.NAME, ""))
	var is_battle_target := _is_battle_target_scene()
	var needs_magic_weapon_prewarm := is_battle_target and equipped_magic_weapon in ["xianyjp", "bsyj"]
	var role_id := int(PlayerData.player_data.get("Myself", 1))
	var skill_keys: Variant = PlayerData.player_data.get(DataKeys.SKILL_LEARNED, {}).get("技能键位", {})
	var equipped_skills: Array = skill_keys.values() if skill_keys is Dictionary else []
	if is_battle_target:
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
		_log_battle_vram("archive preload queue")
		loading_text.text = "正在准备角色技能资源..."
		_set_progress(0.91)
		await Global.prewarm_current_role_runtime_resources(role_id)
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
		_log_battle_vram("role runtime resources")
		if role_id == 1:
			if equipped_skills.has("hmz_ws") and _is_skill_awaken_active("hmz_ws"):
				HMZ_AWAKEN_EFFECT_SCRIPT.preload_effect_data()
			if equipped_skills.has("lyfb") and _is_skill_awaken_active("lyfb"):
				LYFB_AWAKEN_EFFECT_SCRIPT.preload_effect_data()
			if equipped_skills.has("hyjj_ws"):
				await HUOYAN_EFFECT_SCRIPT.prewarm_frames()
			if _has_active_ttzssz_fashion():
				await STREAMING_ROLE_BULLET_SCRIPT.prewarm_bullet_frames("TtzsszBullet")
		elif role_id == 2:
			JHSJ_AWAKEN_EFFECT_SCRIPT.preload_effect_data()
		elif role_id == 3:
			await BADI_EFFECT_SCRIPT.prewarm_frames()
			await STREAMING_ROLE_BULLET_SCRIPT.prewarm_bullet_frames("Role3Bullet2")
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
		_log_battle_vram("role-specific before sword array")
		await MAIN_SWORD_ARRAY_WEAPON_SCRIPT.prewarm_active_sword_resources_async()
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
		_log_battle_vram("role-specific and sword array")
		_set_progress(0.92)
		await get_tree().process_frame
	if needs_magic_weapon_prewarm:
		loading_text.text = "正在准备战斗资源..."
		_set_progress(0.93)
		await get_tree().process_frame
	if needs_magic_weapon_prewarm:
		if equipped_magic_weapon == "bsyj":
			await MIRROR_SCRIPT.prewarm_stream_frames()
		else:
			Global.prewarm_magic_weapon_runtime_resources(equipped_magic_weapon)
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
		_log_battle_vram("magic weapon")
		_set_progress(0.94)
		await get_tree().process_frame
	if is_battle_target:
		await Global.preload_combat_hit_resources()
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
		_log_battle_vram("combat hit resources")
		await get_tree().process_frame
		await Global.prewarm_active_pet_runtime_resources()
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
		_log_battle_vram("active pet")
		await get_tree().process_frame
		if role_id == 4:
			if equipped_skills.has("bylt"):
				BILUO_EFFECT_SCRIPT.prewarm_frames()
				await get_tree().process_frame
			if equipped_skills.has("cmly"):
				CANG_MU_LONG_YUN_EFFECT_SCRIPT._preload_effect_data()
				await get_tree().process_frame
		elif role_id == 5 and equipped_skills.has("ltjz"):
			LEITING_EFFECT_SCRIPT.prewarm_frames()
			await get_tree().process_frame
		var fashions: Variant = PlayerData.player_data.get(DataKeys.FASHION, [])
		if fashions is Array and not fashions.is_empty() and str(fashions[0].get(DataKeys.NAME, "")) == "shenqismsrsz":
			SMSR_EFFECT_SCRIPT.prewarm_frames()
			await get_tree().process_frame
		loading_text.text = "正在准备副本怪物资源..."
		_set_progress(0.94)
		await _prewarm_target_level_resources()
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
		_log_battle_vram("target level monsters")
		_set_progress(0.98)
		await get_tree().process_frame
	_set_progress(0.99)
	if _first_launch_integrity_required and not _first_launch_integrity_valid:
		_show_integrity_failure()
		return
	_set_progress(1.0)
	var elapsed_seconds := float(Time.get_ticks_msec() - _visible_since_msec) / 1000.0

	var minimum_visible_seconds := 0.5 if str(Global.target_scene) == HDZM_LEVEL_SCENE else MIN_VISIBLE_SECONDS
	var remaining_seconds := maxf(minimum_visible_seconds - elapsed_seconds, 0.0)
	if remaining_seconds > 0.0:
		await get_tree().create_timer(remaining_seconds, true, false, true).timeout
	await get_tree().process_frame
	if _target_packed_scene != null:
		_change_to_packed_scene(_target_packed_scene)
	else:
		var cached = Global._resource_cache.get(Global.target_scene, null)
		if cached is PackedScene:
			_change_to_packed_scene(cached)
		else:
			_change_to_target_scene_file()


func _is_skill_awaken_active(skill_id: String) -> bool:
	var awaken_data: Variant = PlayerData.player_data.get(DataKeys.Skill.AWAKENED, {})
	if not awaken_data is Dictionary or not bool(awaken_data.get(skill_id, false)):
		return false
	var enabled_data: Variant = PlayerData.player_data.get(DataKeys.Skill.AWAKENED_ENABLED, {})
	if not enabled_data is Dictionary or not enabled_data.has(skill_id):
		return true
	return bool(enabled_data.get(skill_id, false))


func _has_active_ttzssz_fashion() -> bool:
	var fashions: Variant = PlayerData.player_data.get(DataKeys.FASHION, [])
	if not fashions is Array or (fashions as Array).is_empty():
		return false
	var fashion: Variant = (fashions as Array)[0]
	if not fashion is Dictionary:
		return false
	return (
		Global.get_clean_name(str((fashion as Dictionary).get(DataKeys.NAME, ""))) == "ttzssz"
		and str((fashion as Dictionary).get(DataKeys.NAME, "")) != "putongttzssz"
	)


func _prewarm_target_level_resources() -> void:
	if str(Global.target_scene) == ZHENYAO_TOWER_LEVEL_SCENE:
		var floor_number := maxi(1, int(PlayerData.player_data.get("镇妖塔当前层数", 1)))
		await Global.preload_level_monster_runtime_resources(
			ZHENYAO_TOWER_LEVEL_SCRIPT.get_floor_monster_ids(floor_number)
		)
		return

	var monster_ids: Array = []
	var extra_scene_paths: Array[String] = []
	for monster_id in _get_target_level_monster_ids():
		if not monster_ids.has(monster_id):
			monster_ids.append(monster_id)
	for scene_path in _get_target_first_wave_monster_scene_paths():
		var file_name := scene_path.get_file()
		var monster_id_text := file_name.get_basename().trim_prefix("Monster_")
		if not (file_name.begins_with("Monster_") and monster_id_text.is_valid_int()):
			extra_scene_paths.append(scene_path)
	await Global.preload_level_monster_runtime_resources(monster_ids)
	await Global.prewarm_monster_scene_paths(extra_scene_paths)


func _get_target_level_monster_ids() -> Array:
	var result: Array = []
	var monster_group := _target_script_monster_group()
	for stage_key in ["stage_1", "stage_2", "stage_3", "stage_4"]:
		var stage_ids: Variant = monster_group.get(stage_key, [])
		if stage_ids is Array:
			for monster_id_value in stage_ids:
				var monster_id := int(monster_id_value)
				if monster_id > 0 and not result.has(monster_id):
					result.append(monster_id)

	var script_path := _target_level_script_path()
	if script_path == "":
		return result
	var file := FileAccess.open(script_path, FileAccess.READ)
	if file == null:
		return result
	var source := file.get_as_text()
	file.close()
	var monster_regex := RegEx.new()
	if monster_regex.compile('\\"monster\\"\\s*:\\s*(\\d+)') != OK:
		return result
	for match_result in monster_regex.search_all(source):
		var monster_id := int(match_result.get_string(1))
		if monster_id > 0 and not result.has(monster_id):
			result.append(monster_id)

	if script_path == WANFO_LEVEL_SCRIPT_PATH:
		for monster_id in WANFO_RUNTIME_MONSTER_IDS:
			if not result.has(monster_id):
				result.append(monster_id)
	return result


func _prewarm_target_script_monsters() -> void:
	var monster_group := _target_script_monster_group()
	var has_monsters := false
	for stage_key in ["stage_1", "stage_2", "stage_3", "stage_4"]:
		if monster_group.get(stage_key, []).size() > 0:
			has_monsters = true
			break
	if has_monsters:
		await Global.preload_level_monster_resources(monster_group)


func _target_script_monster_group() -> Dictionary:
	var result := {
		"stage_1": [],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	var script_path := _target_level_script_path()
	if script_path == "":
		return result
	var file := FileAccess.open(script_path, FileAccess.READ)
	if file == null:
		return result
	var source := file.get_as_text()
	var group_regex := RegEx.new()
	if group_regex.compile("monster_group\\s*=\\s*\\{([\\s\\S]*?)\\n\\s*\\}") != OK:
		return result
	var stage_regex := RegEx.new()
	if stage_regex.compile('"stage_([1-4])"\\s*:\\s*\\[([^\\]]*)\\]') != OK:
		return result
	var number_regex := RegEx.new()
	if number_regex.compile("\\d+") != OK:
		return result
	var has_declared_monsters := false
	for group_match in group_regex.search_all(source):
		for stage_match in stage_regex.search_all(group_match.get_string(1)):
			var stage_key := "stage_" + stage_match.get_string(1)
			var values := result[stage_key] as Array
			for number_match in number_regex.search_all(stage_match.get_string(2)):
				var monster_id := int(number_match.get_string())
				if monster_id > 0 and not values.has(monster_id):
					values.append(monster_id)
					has_declared_monsters = true
	var scene_regex := RegEx.new()
	if not has_declared_monsters and scene_regex.compile("Monster_([0-9]+)\\.tscn") == OK:
		var stage_1 := result["stage_1"] as Array
		for scene_match in scene_regex.search_all(source):
			var monster_id := int(scene_match.get_string(1))
			if monster_id > 0 and not stage_1.has(monster_id):
				stage_1.append(monster_id)
	return result


func _target_level_script_path() -> String:
	for dependency in ResourceLoader.get_dependencies(Global.target_scene):
		var dependency_path := _dependency_resource_path(str(dependency))
		if dependency_path.get_extension().to_lower() == "gd" and dependency_path.find("/Script/Level/") != -1:
			return dependency_path
	var scene_file := FileAccess.open(Global.target_scene, FileAccess.READ)
	if scene_file == null:
		return ""
	var scene_source := scene_file.get_as_text()
	var script_regex := RegEx.new()
	if script_regex.compile('path="([^"]+\\.gd)"') != OK:
		return ""
	for match_result in script_regex.search_all(scene_source):
		var path := match_result.get_string(1)
		if path.find("/Script/Level/") != -1:
			return path
	return ""


func _change_to_packed_scene(packed_scene: PackedScene) -> void:
	if _changing_scene:
		return
	_changing_scene = true
	await _covered_change_to_packed_scene(packed_scene)


func _change_to_target_scene_file() -> void:
	if _changing_scene:
		return
	_changing_scene = true
	var packed_scene: PackedScene
	if _is_uncached_target_scene(str(Global.target_scene)):
		packed_scene = (
			ResourceLoader.load(str(Global.target_scene), "PackedScene", ResourceLoader.CACHE_MODE_IGNORE_DEEP)
			as PackedScene
		)
	else:
		packed_scene = load(Global.target_scene) as PackedScene
	if packed_scene != null:
		await _covered_change_to_packed_scene(packed_scene)
	else:
		get_tree().change_scene_to_file(Global.target_scene)


func _covered_change_to_packed_scene(packed_scene: PackedScene) -> void:
	var tree := get_tree()
	if tree == null or packed_scene == null:
		return
	var old_scene := tree.current_scene
	var new_scene := packed_scene.instantiate()
	if new_scene == null:
		get_tree().change_scene_to_packed(packed_scene)
		return
	tree.root.add_child(new_scene)
	tree.current_scene = new_scene
	await tree.process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
	if _is_battle_target_scene():
		_log_battle_vram("level scene instantiated")
	await tree.process_frame
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
	if new_scene == null or not is_instance_valid(new_scene) or not new_scene.is_inside_tree():
		return
	var role_information := new_scene.get_tree().get_first_node_in_group("RoleInformation")
	if role_information != null and role_information.has_method("reveal_after_scene_loaded"):
		role_information.reveal_after_scene_loaded()
	if old_scene != null and is_instance_valid(old_scene) and old_scene != new_scene:
		old_scene.queue_free()


func _on_tips_change_timeout() -> void:
	randomize()
	var tips_count = randi_range(0, tips_textlist.size() - 1)
	message_tips.text = "Tips: " + str(tips_textlist[tips_count])
