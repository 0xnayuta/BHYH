class_name ResourceRuntime
extends Node

## 场景/资源缓存、单次关卡租约、单槽预载与线程预热。
## 由 Global 作为普通子节点持有，不是 Autoload；
## 业务代码通过 Global 窄入口访问，生命周期由本运行时统一管理。

const PERMANENT_SMALL_UI_SCENE_PATHS := [
	"res://Scene/back_pack/back_pack.tscn",
	"res://Scene/skill/learn_skill.tscn",
	"res://Scene/pet/pet_interface.tscn",
	"res://Scene/back_pack/magic_weapon_infor.tscn",
]

var _host
var _resource_cache: Dictionary = {}
var _sprite_frames_cache: Dictionary = {}
var _audio_cache: Dictionary = {}
var _texture_cache: Dictionary = {}
var _monster_scene_cache: Dictionary = {}
var _permanent_small_ui_scene_cache: Dictionary = {}

var _permanent_ui_prewarm_in_progress := false
var _permanent_ui_prewarmed := false

## 关卡资源租约
var _level_resource_lease: Dictionary = {}
var _level_resource_lease_id: int = 0

## 单槽预载
var _preloaded_scene: PackedScene = null
var _preloaded_scene_path: String = ""
var _preloading_path: String = ""


func setup(host: Node) -> void:
	_host = host


func is_generation_current(generation: int) -> bool:
	if _host == null:
		return false
	return _host.is_runtime_generation_current(generation)


func get_runtime_generation() -> int:
	if _host == null:
		return 0
	return int(_host._runtime_generation)


# -----------------------------------------------------------------------------
# 缓存大小与诊断快照
# -----------------------------------------------------------------------------


func get_resource_cache_size() -> int:
	return _resource_cache.size()


func get_sprite_frames_cache_size() -> int:
	return _sprite_frames_cache.size()


func get_audio_cache_size() -> int:
	return _audio_cache.size()


func get_texture_cache_size() -> int:
	return _texture_cache.size()


func get_monster_scene_cache_size() -> int:
	return _monster_scene_cache.size()


func get_permanent_small_ui_scene_count() -> int:
	return _permanent_small_ui_scene_cache.size()


func is_permanent_ui_prewarm_in_progress() -> bool:
	return _permanent_ui_prewarm_in_progress


func is_permanent_ui_prewarmed() -> bool:
	return _permanent_ui_prewarmed


func clear_runtime_state() -> void:
	clear_preloaded_scene_slot()
	_resource_cache.clear()
	_sprite_frames_cache.clear()
	_audio_cache.clear()
	_texture_cache.clear()
	_monster_scene_cache.clear()
	_permanent_small_ui_scene_cache.clear()
	_level_resource_lease.clear()
	_level_resource_lease_id = 0
	_permanent_ui_prewarm_in_progress = false
	_permanent_ui_prewarmed = false


# -----------------------------------------------------------------------------
# 场景与基础资源加载
# -----------------------------------------------------------------------------


func is_scene_resource_path(path: String) -> bool:
	return path.ends_with(".tscn") or path.ends_with(".scn")


func is_valid_packed_scene(value: Variant) -> bool:
	if not is_instance_valid(value):
		return false
	return value is PackedScene


func load_scene(path: String) -> PackedScene:
	if not is_scene_resource_path(path):
		return null
	if _permanent_small_ui_scene_cache.has(path):
		var permanent_scene: Variant = _permanent_small_ui_scene_cache[path]
		if is_valid_packed_scene(permanent_scene):
			return permanent_scene
		_permanent_small_ui_scene_cache.erase(path)
	if _resource_cache.has(path) and not is_valid_packed_scene(_resource_cache[path]):
		_resource_cache.erase(path)
	if not _resource_cache.has(path):
		var is_runtime_ui := false
		if _host != null and _host.has_method("get_ui_runtime") and _host.get_ui_runtime() != null:
			is_runtime_ui = _host.get_ui_runtime().is_runtime_ui_scene_path(path)
		if is_runtime_ui:
			_resource_cache[path] = ResourceLoader.load(path, "PackedScene", ResourceLoader.CACHE_MODE_IGNORE_DEEP)
		else:
			_resource_cache[path] = ResourceLoader.load(path, "PackedScene", ResourceLoader.CACHE_MODE_REUSE)
	var cached_scene: Variant = _resource_cache.get(path)
	if not is_valid_packed_scene(cached_scene):
		return null
	if path in PERMANENT_SMALL_UI_SCENE_PATHS:
		_permanent_small_ui_scene_cache[path] = cached_scene
	return cached_scene as PackedScene


func load_scene_uncached(path: String) -> PackedScene:
	if path == "":
		return null
	if _resource_cache.has(path):
		return _resource_cache[path] as PackedScene
	var scene := ResourceLoader.load(path, "PackedScene", ResourceLoader.CACHE_MODE_REUSE) as PackedScene
	if scene != null:
		_resource_cache[path] = scene
		track_level_resource(path)
	return scene


func load_level_monster_scene(path: String) -> PackedScene:
	if path == "":
		return null
	if _monster_scene_cache.has(path):
		return _monster_scene_cache[path] as PackedScene
	var scene := load_scene(path)
	if scene != null:
		_monster_scene_cache[path] = scene
		track_level_resource(path)
	return scene


func cache_monster_scene(path: String, scene: PackedScene) -> void:
	if path != "" and scene != null:
		_monster_scene_cache[path] = scene


func prewarm_permanent_small_ui_scenes(generation: int = -1) -> void:
	if _permanent_ui_prewarm_in_progress or _permanent_ui_prewarmed:
		return
	var request_generation := get_runtime_generation() if generation < 0 else generation
	if not is_generation_current(request_generation):
		return
	_permanent_ui_prewarm_in_progress = true
	for scene_path in PERMANENT_SMALL_UI_SCENE_PATHS:
		if not is_generation_current(request_generation):
			_permanent_ui_prewarm_in_progress = false
			return
		if not _permanent_small_ui_scene_cache.has(scene_path):
			load_scene(scene_path)
		var tree := get_tree()
		if tree == null:
			_permanent_ui_prewarm_in_progress = false
			return
		await tree.process_frame
	_permanent_ui_prewarm_in_progress = false
	if not is_generation_current(request_generation):
		return
	_permanent_ui_prewarmed = true


# -----------------------------------------------------------------------------
# 缓存查询与交接
# -----------------------------------------------------------------------------


func is_resource_cached(path: String) -> bool:
	if path.is_empty():
		return false
	return (
		_resource_cache.has(path)
		or _sprite_frames_cache.has(path)
		or _audio_cache.has(path)
		or _texture_cache.has(path)
	)


func get_cached_packed_scene(path: String) -> PackedScene:
	if path.is_empty():
		return null
	var value: Variant = _resource_cache.get(path)
	if not is_valid_packed_scene(value):
		return null
	return value as PackedScene


func get_cached_sprite_frames(path: String) -> SpriteFrames:
	if path.is_empty():
		return null
	var value: Variant = _sprite_frames_cache.get(path)
	if value is SpriteFrames:
		return value as SpriteFrames
	var res_val: Variant = _resource_cache.get(path)
	if res_val is SpriteFrames:
		return res_val as SpriteFrames
	return null


func handoff_loaded_resource(path: String, resource: Resource, track_level: bool = false) -> bool:
	if path.is_empty() or resource == null:
		return false
	cache_threaded_resource(path, resource)
	if track_level:
		track_level_resource(path)
	return true


func get_cached_audio(path: String) -> AudioStream:
	var resolved_path := path
	if path.ends_with("/effect4.mp3") and not path.begins_with("res://Music/hero/role_7/"):
		resolved_path = path.replace("effect4.mp3", "effect3.mp3")
	if path == "":
		return null
	if not _audio_cache.has(path):
		_audio_cache[path] = load(resolved_path)
	return _audio_cache[path] as AudioStream


func get_cached_texture(path: String) -> Texture2D:
	var resolved_path := path
	if path.ends_with("/mp_poision.png"):
		resolved_path = path.replace("mp_poision.png", "poision.png")
	if path == "":
		return null
	if not _texture_cache.has(path) or _texture_cache[path] == null:
		var texture := load(resolved_path) as Texture2D
		if texture != null:
			_texture_cache[path] = texture
		else:
			_texture_cache.erase(path)
		return texture
	return _texture_cache[path] as Texture2D


func release_cached_texture(path: String) -> void:
	if path == "":
		return
	_texture_cache.erase(path)
	var resolved_path := path
	if resolved_path != path:
		_texture_cache.erase(resolved_path)


func cache_threaded_resource(path: String, resource: Resource) -> void:
	if resource == null:
		return
	if resource is PackedScene or path.ends_with(".tscn") or path.ends_with(".scn"):
		_resource_cache[path] = resource
	elif resource is SpriteFrames:
		_sprite_frames_cache[path] = resource
	elif resource is AudioStream:
		_audio_cache[path] = resource
	elif resource is Texture2D:
		_texture_cache[path] = resource
	else:
		_resource_cache[path] = resource


func release_role_cached_resources() -> void:
	_erase_cached_paths_by_prefix(_resource_cache, ["res://Art/hero_picture/", "res://Scene/hero/"])
	_erase_cached_paths_by_prefix(_sprite_frames_cache, ["res://Art/hero_picture/"])
	_erase_cached_paths_by_prefix(_texture_cache, ["res://Art/hero_picture/"])
	_erase_cached_paths_by_prefix(_audio_cache, ["res://Music/hero/"])


func is_permanent_small_ui_scene_path(path: String) -> bool:
	return path in PERMANENT_SMALL_UI_SCENE_PATHS


func get_cached_scene_paths() -> Array[String]:
	var result: Array[String] = []
	for path_value in _resource_cache.keys():
		result.append(str(path_value))
	return result


func erase_cached_scene(path: String) -> void:
	if path != "":
		_resource_cache.erase(path)


func erase_cached_texture_paths_by_prefix(prefixes: Array) -> void:
	_erase_cached_paths_by_prefix(_texture_cache, prefixes)


func clear_permanent_small_ui_scene_cache() -> void:
	_permanent_small_ui_scene_cache.clear()
	_permanent_ui_prewarmed = false
	_permanent_ui_prewarm_in_progress = false


func _erase_cached_paths_by_prefix(cache: Dictionary, prefixes: Array) -> void:
	for path_value in cache.keys():
		var path := str(path_value)
		for prefix in prefixes:
			if path.begins_with(str(prefix)):
				cache.erase(path)
				break


# -----------------------------------------------------------------------------
# 关卡资源租约
# -----------------------------------------------------------------------------


func begin_level_resource_lease(target_scene: String) -> int:
	release_level_resource_lease()
	_level_resource_lease_id += 1
	_level_resource_lease = {
		"id": _level_resource_lease_id,
		"target_scene": target_scene,
		"paths": {},
		"scene_paths": {},
		"monster_scene_paths": {},
		"bullet_scene_paths": {},
		"texture_paths": {},
		"audio_paths": {},
		"warmed_scene_paths": {},
		"prewarmed_monster_ids": {},
	}
	return _level_resource_lease_id


func release_level_resource_lease(lease_id: int = -1) -> int:
	if _level_resource_lease.is_empty():
		return 0
	if lease_id >= 0 and int(_level_resource_lease.get("id", 0)) != lease_id:
		return 0
	var target_scene := str(_level_resource_lease.get("target_scene", ""))
	var paths: Dictionary = _level_resource_lease.get("paths", {})
	var released := 0
	for path_value in paths.keys():
		var path := str(path_value)
		if path.is_empty() or path == target_scene:
			continue
		if path in PERMANENT_SMALL_UI_SCENE_PATHS or _permanent_small_ui_scene_cache.has(path):
			continue
		_resource_cache.erase(path)
		_sprite_frames_cache.erase(path)
		_texture_cache.erase(path)
		_audio_cache.erase(path)
		_monster_scene_cache.erase(path)
		released += 1
	_level_resource_lease = {}
	return released


func is_level_scene_warmed(path: String) -> bool:
	if _level_resource_lease.is_empty():
		return false
	var warmed: Dictionary = _level_resource_lease.get("warmed_scene_paths", {})
	return warmed.has(path)


func mark_level_scene_warmed(path: String) -> void:
	if _level_resource_lease.is_empty():
		return
	var warmed: Dictionary = _level_resource_lease.get("warmed_scene_paths", {})
	warmed[path] = true


func is_level_monster_prewarmed(monster_id: int) -> bool:
	if _level_resource_lease.is_empty():
		return false
	var prewarmed: Dictionary = _level_resource_lease.get("prewarmed_monster_ids", {})
	return prewarmed.has(monster_id)


func mark_level_monster_prewarmed(monster_id: int) -> void:
	if _level_resource_lease.is_empty():
		return
	var prewarmed: Dictionary = _level_resource_lease.get("prewarmed_monster_ids", {})
	prewarmed[monster_id] = true


func track_level_resource(path: String) -> void:
	if path.is_empty() or _level_resource_lease.is_empty():
		return
	var target_scene := str(_level_resource_lease.get("target_scene", ""))
	if path == target_scene:
		return
	var paths: Dictionary = _level_resource_lease.get("paths", {})
	paths[path] = true
	var extension := path.get_extension().to_lower()
	if extension in ["tscn", "scn"]:
		var scene_paths: Dictionary = _level_resource_lease.get("scene_paths", {})
		scene_paths[path] = true
		if path.begins_with("res://Scene/monster/") or path.begins_with("res://Scene/bullet/"):
			var monster_scene_paths: Dictionary = _level_resource_lease.get("monster_scene_paths", {})
			monster_scene_paths[path] = true
			if (
				path.begins_with("res://Scene/bullet/")
				or path.contains("/monster_bullet")
				or path.get_file().to_lower().contains("bullet")
			):
				var bullet_scene_paths: Dictionary = _level_resource_lease.get("bullet_scene_paths", {})
				bullet_scene_paths[path] = true
	elif extension in ["png", "jpg", "jpeg", "webp", "svg"]:
		var texture_paths: Dictionary = _level_resource_lease.get("texture_paths", {})
		texture_paths[path] = true
	elif extension in ["mp3", "ogg", "wav"]:
		var audio_paths: Dictionary = _level_resource_lease.get("audio_paths", {})
		audio_paths[path] = true


func get_dependency_resource_path(dependency: String) -> String:
	var resource_path_start := dependency.find("res://")
	if resource_path_start >= 0:
		return dependency.substr(resource_path_start)
	return dependency


func track_level_scene_dependencies(scene_paths: Array) -> void:
	for scene_path_value in scene_paths:
		var scene_path := str(scene_path_value)
		track_level_resource(scene_path)
		for dependency in ResourceLoader.get_dependencies(scene_path):
			var dependency_path := get_dependency_resource_path(str(dependency))
			track_level_resource(dependency_path)


func get_lease_snapshot() -> Dictionary:
	if _level_resource_lease.is_empty():
		return {
			"active": false,
			"id": 0,
			"target_scene": "",
			"owned_path_count": 0,
			"owned_paths": [],
			"scene_paths": [],
			"monster_scene_paths": [],
			"bullet_scene_paths": [],
			"texture_paths": [],
			"audio_paths": [],
			"warmed_scene_paths": [],
			"prewarmed_monster_ids": [],
		}
	return {
		"active": true,
		"id": int(_level_resource_lease.get("id", 0)),
		"target_scene": str(_level_resource_lease.get("target_scene", "")),
		"owned_path_count": (_level_resource_lease.get("paths", {}) as Dictionary).size(),
		"owned_paths": _lease_path_list(_level_resource_lease.get("paths", {})),
		"scene_paths": _lease_path_list(_level_resource_lease.get("scene_paths", {})),
		"monster_scene_paths": _lease_path_list(_level_resource_lease.get("monster_scene_paths", {})),
		"bullet_scene_paths": _lease_path_list(_level_resource_lease.get("bullet_scene_paths", {})),
		"texture_paths": _lease_path_list(_level_resource_lease.get("texture_paths", {})),
		"audio_paths": _lease_path_list(_level_resource_lease.get("audio_paths", {})),
		"warmed_scene_paths": _lease_path_list(_level_resource_lease.get("warmed_scene_paths", {})),
		"prewarmed_monster_ids": _lease_int_list(_level_resource_lease.get("prewarmed_monster_ids", {})),
	}


func _lease_path_list(value: Variant) -> Array:
	var result: Array = []
	if value is Dictionary:
		for path_value in (value as Dictionary).keys():
			result.append(str(path_value))
	result.sort()
	return result


func _lease_int_list(value: Variant) -> Array:
	var result: Array = []
	if value is Dictionary:
		for int_value in (value as Dictionary).keys():
			result.append(int(int_value))
	result.sort()
	return result


# -----------------------------------------------------------------------------
# 单槽预载
# -----------------------------------------------------------------------------


func preload_next(path: String) -> void:
	if path == "" or (_preloaded_scene != null and _preloaded_scene_path == path):
		return
	if _preloading_path == path:
		var existing_status := ResourceLoader.load_threaded_get_status(path)
		if (
			existing_status == ResourceLoader.THREAD_LOAD_FAILED
			or existing_status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
		):
			clear_preloaded_scene_slot()
		else:
			return
	clear_preloaded_scene_slot()
	if not ResourceLoader.exists(path):
		return
	if _resource_cache.has(path):
		var cached: Variant = _resource_cache[path]
		if cached is PackedScene:
			_preloaded_scene = cached as PackedScene
			_preloaded_scene_path = path
			return
	_preloading_path = path
	var err := ResourceLoader.load_threaded_request(path)
	if err != OK and err != ERR_BUSY:
		clear_preloaded_scene_slot()


func clear_preloaded_scene_slot() -> void:
	_preloaded_scene = null
	_preloaded_scene_path = ""
	_preloading_path = ""


func take_preloaded_scene(path: String) -> PackedScene:
	if _preloaded_scene != null:
		if _preloaded_scene_path == path:
			var ps = _preloaded_scene
			clear_preloaded_scene_slot()
			return ps
		_preloaded_scene = null
		_preloaded_scene_path = ""
	if _preloading_path == path:
		var status = ResourceLoader.load_threaded_get_status(path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var ps = ResourceLoader.load_threaded_get(path) as PackedScene
			clear_preloaded_scene_slot()
			return ps
		if status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			clear_preloaded_scene_slot()
	return null


func get_preloaded_slot_snapshot() -> Dictionary:
	return {
		"path": _preloading_path,
		"ready_path": _preloaded_scene_path,
		"ready": _preloaded_scene != null,
	}


# -----------------------------------------------------------------------------
# 线程预载与分帧预热
# -----------------------------------------------------------------------------


func preload_paths_threaded(paths: Array, generation: int = -1) -> void:
	var request_generation := get_runtime_generation() if generation < 0 else generation
	if not is_generation_current(request_generation):
		return
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

	var batch_size := get_threaded_preload_batch_size(request_paths.size())
	var batch_start := 0
	while batch_start < request_paths.size():
		if not is_generation_current(request_generation):
			return
		var pending: Array[String] = []
		var batch_end := mini(batch_start + batch_size, request_paths.size())
		for index in range(batch_start, batch_end):
			var path := request_paths[index]
			var err = ResourceLoader.load_threaded_request(path)
			if err == OK or err == ERR_BUSY:
				pending.append(path)
			else:
				var resource = load(path)
				cache_threaded_resource(path, resource)
		while not pending.is_empty():
			var i := pending.size() - 1
			while i >= 0:
				var path := pending[i]
				var status = ResourceLoader.load_threaded_get_status(path)
				if status == ResourceLoader.THREAD_LOAD_LOADED:
					if not is_generation_current(request_generation):
						return
					var resource = ResourceLoader.load_threaded_get(path)
					cache_threaded_resource(path, resource)
					pending.remove_at(i)
				elif (
					status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE
				):
					pending.remove_at(i)
				i -= 1
			if not pending.is_empty():
				var tree := get_tree()
				if tree == null:
					return
				await tree.process_frame
				if not is_generation_current(request_generation):
					return
		batch_start = batch_end


func get_threaded_preload_batch_size(request_count: int) -> int:
	if request_count <= 0:
		return 1
	return mini(request_count, 2 if OS.has_feature("mobile") else 4)


func warm_scene_paths_over_frames(paths: Array, per_frame: int = 2, generation: int = -1) -> void:
	var request_generation := get_runtime_generation() if generation < 0 else generation
	if not is_generation_current(request_generation):
		return
	var warmed_this_frame := 0
	for path in paths:
		if not is_generation_current(request_generation):
			return
		var scene_path := str(path)
		if not is_scene_resource_path(scene_path):
			continue
		var scene = load_scene(scene_path)
		if scene != null:
			warm_scene_instance(scene)
			warmed_this_frame += 1
			if warmed_this_frame >= per_frame:
				warmed_this_frame = 0
				var tree := get_tree()
				if tree == null:
					return
				await tree.process_frame
				if not is_generation_current(request_generation):
					return


func warm_scene_instance(scene: PackedScene) -> void:
	if scene == null:
		return
	var node := scene.instantiate()
	if node != null:
		node.free()


func _release_warm_audio_players(players: Array[AudioStreamPlayer]) -> void:
	for player in players:
		if player == null or not is_instance_valid(player):
			continue
		player.stop()
		player.stream = null
		player.free()
	players.clear()


func warm_audio_streams_over_frames(paths: Array, per_frame: int = 2, generation: int = -1) -> void:
	var request_generation := get_runtime_generation() if generation < 0 else generation
	if not is_generation_current(request_generation):
		return
	var players: Array[AudioStreamPlayer] = []
	var batch_size := maxi(1, per_frame)
	for path_value in paths:
		if not is_generation_current(request_generation):
			_release_warm_audio_players(players)
			return
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
			var tree := get_tree()
			if tree == null:
				_release_warm_audio_players(players)
				return
			await tree.process_frame
			_release_warm_audio_players(players)
			if not is_generation_current(request_generation):
				return
	if not players.is_empty():
		var tree := get_tree()
		if tree == null:
			_release_warm_audio_players(players)
			return
		await tree.process_frame
		_release_warm_audio_players(players)


func warm_texture_rids_over_frames(paths: Array, per_frame: int = 6, generation: int = -1) -> void:
	var request_generation := get_runtime_generation() if generation < 0 else generation
	if not is_generation_current(request_generation):
		return
	var warmed_this_frame := 0
	for path in paths:
		if not is_generation_current(request_generation):
			return
		var texture := get_cached_texture(str(path))
		if texture == null:
			continue
		texture.get_rid()
		warmed_this_frame += 1
		if warmed_this_frame >= per_frame:
			warmed_this_frame = 0
			if DisplayServer.get_name() == "headless":
				var tree := get_tree()
				if tree == null:
					return
				await tree.process_frame
			else:
				await RenderingServer.frame_post_draw
			if not is_generation_current(request_generation):
				return
