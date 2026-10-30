class_name AudioRuntime
extends Node

## BGM 单实例与 SFX 声部管理。
## 由 Global 作为普通子节点持有，不是 Autoload；资源缓存与对象池仍归 Global。

const MOBILE_SFX_VOICE_LIMIT := 24
const DESKTOP_SFX_VOICE_LIMIT := 48
const MOBILE_SFX_PER_SOUND_LIMIT := 4
const DESKTOP_SFX_PER_SOUND_LIMIT := 8

## 音效设置变化：`monster_be_hit` 等声部消费者监听本信号。
signal sound_settings_changed

const BGM_SCENE_PATH := "res://Scene/all_sound/bgm.tscn"
const SFX_SCENE_PATH := "res://Scene/all_sound/monster_be_hit.tscn"
const MAIN_MENU_MUSIC := {
	1: "res://Music/main_scene_music/zmxy_1_bgm.mp3",
	2: "res://Music/main_scene_music/zmxy_2_bgm.mp3",
	3: "res://Music/main_scene_music/44_begin.mp3",
	4: "res://Music/main_scene_music/zmxy4bg.mp3",
}

var _host
var _bgm_scene: PackedScene = null
var _active_bgm_instance: Node = null
var _main_menu_music: Node = null
var _last_sound_play_msec: Dictionary = {}
var _active_sound_players: Dictionary = {}
var _last_sfx_enabled := true
var _last_sfx_volume := INF


func setup(host: Node) -> void:
	_host = host


func _physics_process(_delta: float) -> void:
	var sfx_enabled := bool(MainSet.set_data.get("RoleOrMonsterHit", true))
	var sfx_volume := float(MainSet.set_data.get("MusicFB_2", 0.0))
	if sfx_enabled == _last_sfx_enabled and is_equal_approx(sfx_volume, _last_sfx_volume):
		return
	_last_sfx_enabled = sfx_enabled
	_last_sfx_volume = sfx_volume
	sound_settings_changed.emit()


func add_bgm(parent: Node, target_: Variant):
	if not is_instance_valid(parent) or parent.is_queued_for_deletion():
		return null
	var bgm_key := str(target_)
	if (
		_active_bgm_instance != null
		and (not is_instance_valid(_active_bgm_instance) or _active_bgm_instance.is_queued_for_deletion())
	):
		_active_bgm_instance = null
	if _active_bgm_instance != null:
		if str(_active_bgm_instance.get("target")) == bgm_key:
			if _active_bgm_instance.get_parent() != parent:
				_host._attach_pooled_node(_active_bgm_instance, parent)
				_resume_bgm_after_reparent(_active_bgm_instance)
			return _active_bgm_instance
		if _active_bgm_instance is AudioStreamPlayer:
			(_active_bgm_instance as AudioStreamPlayer).stop()
		_active_bgm_instance.queue_free()
		_active_bgm_instance = null
	if _bgm_scene == null:
		_bgm_scene = _host._load_scene(BGM_SCENE_PATH)
	if _bgm_scene == null:
		return null
	var target = _bgm_scene.instantiate()
	if target == null:
		return null
	# 同步挂载，避免同曲在 deferred add_child 前被第二个父节点复用而挂错父节点。
	target.target = target_
	parent.add_child(target)
	_active_bgm_instance = target
	return target


func _resume_bgm_after_reparent(node: Node) -> void:
	if not (node is AudioStreamPlayer):
		return
	var player := node as AudioStreamPlayer
	if not bool(MainSet.set_data.get("BackGroundMusic", true)):
		return
	if player.stream != null and not player.playing and not player.stream_paused:
		player.play()


func stop_bgm() -> void:
	if not is_instance_valid(_active_bgm_instance):
		_active_bgm_instance = null
		return
	var target := _active_bgm_instance
	_active_bgm_instance = null
	if target is AudioStreamPlayer:
		(target as AudioStreamPlayer).stop()
	target.queue_free()


func has_active_bgm() -> bool:
	return _active_bgm_instance != null and is_instance_valid(_active_bgm_instance)


func add_sound(parent: Node, target_: Variant, priority: int = 0):
	if not is_instance_valid(parent) or parent.is_queued_for_deletion():
		return null
	if not bool(MainSet.set_data.get("RoleOrMonsterHit", true)):
		return null
	var now_msec := Time.get_ticks_msec()
	var sound_key := str(target_)
	var last_msec := int(_last_sound_play_msec.get(sound_key, -45))
	if now_msec - last_msec < 45:
		return null
	if _host.get_cached_audio(sound_key) == null:
		return null
	if not _reserve_sound_voice(sound_key, priority):
		return null
	var target = _host._take_pooled_node(_host._pool_data["sound_player"], SFX_SCENE_PATH)
	if target == null:
		return null
	_last_sound_play_msec[sound_key] = now_msec
	_host._attach_pooled_node(target, parent)
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


func recycle_sound_player(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	_active_sound_players.erase(node.get_instance_id())
	if not _host._pool_data["sound_player"].has(node):
		_host._store_pooled_node(node, _host._pool_data["sound_player"], _host.SOUND_PLAYER_POOL_LIMIT)


func release_active_sound_players() -> void:
	for entry_value in _active_sound_players.values():
		if not (entry_value is Dictionary):
			continue
		var node: Variant = (entry_value as Dictionary).get("node")
		if not (node is Node) or not is_instance_valid(node):
			continue
		if node is AudioStreamPlayer:
			(node as AudioStreamPlayer).stop()
			(node as AudioStreamPlayer).stream = null
		(node as Node).queue_free()
	_active_sound_players.clear()
	_last_sound_play_msec.clear()


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


## 主菜单 BGM：原 MainMusic 单例的职责，随 MainSet 音乐选项切换。
func add_main_menu_music() -> void:
	var music_id := int(MainSet.set_data.get("music", 1))
	var music_path: String = MAIN_MENU_MUSIC.get(music_id, "")
	if music_path == "":
		return
	remove_main_menu_music()
	_main_menu_music = add_bgm(self, music_path)


func remove_main_menu_music() -> void:
	if _main_menu_music != null and is_instance_valid(_main_menu_music):
		_main_menu_music.queue_free()
	_main_menu_music = null


func has_main_menu_music() -> bool:
	return _main_menu_music != null and is_instance_valid(_main_menu_music)


func clear_runtime_state() -> void:
	release_active_sound_players()
	stop_bgm()
	remove_main_menu_music()


func get_snapshot() -> Dictionary:
	return {
		"active_bgm": has_active_bgm(),
		"main_menu_music": has_main_menu_music(),
		"active_sound_players": _active_sound_players.size(),
		"sfx_throttle_entries": _last_sound_play_msec.size(),
	}
