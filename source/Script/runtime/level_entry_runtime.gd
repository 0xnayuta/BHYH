class_name LevelEntryRuntime
extends Node

## 关卡进入编排：关卡信息面板、直进分支、关卡掉落概率表与信息面板场景槽位。
## 由 Global 作为普通子节点持有，不是 Autoload；
## 业务侧仍经 Global.add_level_info / get_current_level_fall_pro / sync_level_drop_pro_data 正式入口访问。

const LEVEL_INFO_SCENE_PATH := "res://Scene/other_scene/level_info.tscn"
const FORCED_INFO_LEVEL_PATHS := [
	"res://Scene/level/level_stz.tscn",
	"res://Scene/level/level_esbxx.tscn",
	"res://Scene/level/level_tzsijian.tscn",
	"res://Scene/level/level_sssl.tscn",
	"res://Scene/level/level_bxgh.tscn",
]

var _host = null
var _level_info_scene: PackedScene = null
var _drop_pro_by_level: Dictionary = {}


func setup(host: Node) -> void:
	_host = host


## level_info.tscn 是常驻信息面板场景槽位，与迁移前的 Global.level_info 一样不随关卡清理。
func get_level_info_scene() -> PackedScene:
	if _level_info_scene == null:
		_level_info_scene = _host.load_cached_scene(LEVEL_INFO_SCENE_PATH)
	return _level_info_scene


func get_drop_pro_by_level() -> Dictionary:
	return _drop_pro_by_level


func sync_drop_pro_data(source: Dictionary) -> void:
	_drop_pro_by_level.clear()
	for level_name in source.keys():
		_drop_pro_by_level[level_name] = source[level_name].get("fall_pro", 0)


func get_current_level_fall_pro(default_pro: float) -> float:
	if _drop_pro_by_level.is_empty():
		var scene := get_level_info_scene()
		if scene != null:
			var probe := scene.instantiate()
			if probe != null:
				sync_drop_pro_data(probe.level_info)
				probe.queue_free()
	var level_name: String = _host.get_current_level_name()
	var base_pro := -1.0
	if level_name != "" and _drop_pro_by_level.has(level_name):
		base_pro = float(_drop_pro_by_level[level_name])
	var effective_pro := default_pro
	if base_pro >= 0.0:
		var diff := int(MainSet.set_data.get("Difficult", 0))
		var multipliers := [1.0, 2.0, 3.0, 3.0]
		diff = clampi(diff, 0, multipliers.size() - 1)
		effective_pro = base_pro * multipliers[diff] / 100.0
	if RoleProp.source_player != null and RoleProp.source_player.is_double_fall_pro:
		effective_pro *= 2.0
	return clampf(effective_pro, 0.0, 1.0)


func add_level_info(parent, level_name, position, target_path):
	if not _host.is_archive_session_active():
		_host.add_message_show(parent, "请先进入一个存档后再挑战关卡。", 1.5, Vector2(470, 300))
		return null
	_host.set_current_level_name(str(level_name))
	var show_level_info := bool(MainSet.set_data.get("LevelInfo", true))
	if str(target_path) in FORCED_INFO_LEVEL_PATHS:
		show_level_info = true
	_host.apply_level_entry_mode_reset(str(target_path))
	var scene := get_level_info_scene()
	if scene == null:
		return null
	if not show_level_info:
		var probe = scene.instantiate()
		if probe != null:
			probe.level_name = level_name
			probe.target_stage_path = target_path
			sync_drop_pro_data(probe.level_info)
			var nightmare_block_message := ""
			if probe.has_method("_get_nightmare_entry_block_message"):
				nightmare_block_message = str(probe.call("_get_nightmare_entry_block_message"))
			probe.free()
			if nightmare_block_message != "":
				_host.add_message_show(parent, nightmare_block_message, 1.5, Vector2(470, 300))
				return null
		return enter_level_without_info(parent, target_path)
	var target = _host.instance_scene(scene, parent)
	if target == null:
		return null
	sync_drop_pro_data(target.level_info)
	target.level_name = level_name
	target.target_stage_path = target_path
	if position == Vector2.ZERO or position == Vector2(0, 0):
		target.position = _host.viewport_center_for_parent(parent) - Vector2(470, 295)
	else:
		target.position = position
	_host.get_ui_runtime().register_transient_ui(target)
	return target


func enter_level_without_info(parent, target_path):
	if str(target_path).begins_with("res://Scene/level/") and not _host.is_archive_session_active():
		_host.add_message_show(parent, "请先进入一个存档后再挑战关卡。", 1.5, Vector2(470, 300))
		return null
	if target_path == "res://Scene/level/level_llbt.tscn":
		return _host.addllbt_challenge(parent, Vector2(0, 0))
	if not str(target_path).begins_with("res://"):
		return _host.add_dsg_choose(parent)
	_host.change_scene(target_path)
	return null
