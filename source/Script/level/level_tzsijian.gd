extends BaseLevel

@onready var stop_1: CollisionShape2D = $wall/stop1
@onready var stop_5: CollisionShape2D = $wall/stop5
@onready var bg_base: Sprite2D = $BackGround/front/tzsijian_top

const BG_PARTS_ROOT := "res://Art/level/game_3_level/level_tzsijian/level_96/bg961_parts"
const BG_SOURCE_X := -20.0
const BG_SOURCE_FPS := 30.0
const BG_EXPORT_SCALE := 2.0
const BOSS_HP_TRIGGER := 0.7
const BASE_BOSS_CONCURRENT_LIMIT := 4
const BOSS_SPAWN_X_SPACING := 80.0
const ENDLESS_ROUND_DELAY := 0.5
const SWORD_BOSS_IDS := [951, 952, 953, 954]
const SWORD_BOSS_POSITIONS := {
	951: Vector2(500, 300),
	952: Vector2(700, 300),
	953: Vector2(900, 300),
	954: Vector2(1100, 300),
}
const BG_ANIMATIONS := {
	"role": {"dir": "role", "pos": Vector2(BG_SOURCE_X + 496.0, 222.65), "z": 2},
	"sword1": {"dir": "sword1", "pos": Vector2(BG_SOURCE_X + 147.1, 130.1), "z": 10},
	"sword2": {"dir": "sword2", "pos": Vector2(BG_SOURCE_X + 378.4, 129.65), "z": 10},
	"sword3": {"dir": "sword3", "pos": Vector2(BG_SOURCE_X + 608.6, 129.6), "z": 10},
	"sword4": {"dir": "sword4", "pos": Vector2(BG_SOURCE_X + 826.7, 129.55), "z": 10},
}
const BOSS_TO_BG_SWORD := {
	951: "sword1",
	952: "sword2",
	953: "sword3",
	954: "sword4",
}

var is_set := false
var _bg_anim_nodes: Array[Node] = []
var _bg_sword_nodes: Dictionary = {}
var _spawned_bosses: Dictionary = {}
var _queued_boss_ids: Dictionary = {}
var _preparing_boss_ids: Dictionary = {}
var _boss_count_multiplier := 1
var _endless_restart_pending := false


func _ready() -> void:
	Global.set_current_level_name("鎸戞垬鍥涘墤")
	Global.get_audio_runtime().add_bgm(self, "res://Music/level/10_bg4.mp3")
	self.is_two_scene = true
	self.level_stage = 10
	Global.game_over = 1
	super._ready()
	_setup_tzsijian_background()
	_boss_count_multiplier = clamp(int(MainSet.set_data.get("CreateMonsterCount", 1)), 1, 5)
	MainSet.set_data["CreateMonsterCount"] = _boss_count_multiplier
	monster_group = {
		"stage_1": [],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_x = {
		"stage_1": [],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_y = {
		"stage_1": [],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	_queue_sword_boss_wave(951)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if role_information != null and role_information.gogo != null:
		role_information.gogo.visible = false
	_update_sword_boss_sequence()


func _prepare_level_runtime_resources() -> void:
	await SwordBossBase.prewarm_sword_boss_frames_async([951])
	if create_control != null and is_instance_valid(create_control):
		create_control.start()


func _preload_level_resources() -> void:
	await SwordBossBase.prewarm_sword_boss_frames_async([951])


func _exit_tree() -> void:
	Global.clear_special_dungeon_endless()
	for bg_node in _bg_anim_nodes:
		if is_instance_valid(bg_node):
			if bg_node is StreamedPngEffect:
				bg_node.clear_texture()
			elif bg_node is AnimatedSprite2D:
				bg_node.sprite_frames = null
	_bg_anim_nodes.clear()
	_bg_sword_nodes.clear()
	_spawned_bosses.clear()
	_queued_boss_ids.clear()
	_preparing_boss_ids.clear()
	SwordBossBase.clear_prewarmed_sword_boss_frames()


func check_can_create(stage) -> bool:
	if int(stage) != 1:
		return false
	if not monster_group.has("stage_1"):
		return false
	return (
		monster_group["stage_1"].size() > 0
		and _get_alive_stage_monster_count() < BASE_BOSS_CONCURRENT_LIMIT * _boss_count_multiplier
	)


func level_create_monster(stage) -> void:
	if int(stage) != 1:
		return
	var stage_key := "stage_1"
	if monster_group[stage_key].is_empty():
		return
	var boss_id := int(monster_group[stage_key].pop_front())
	if not SWORD_BOSS_POSITIONS.has(boss_id):
		return
	var spawn_position: Vector2 = SWORD_BOSS_POSITIONS[boss_id]
	if monster_position_x[stage_key].size() > 0:
		spawn_position.x = float(monster_position_x[stage_key].pop_front())
	if monster_position_y[stage_key].size() > 0:
		spawn_position.y = float(monster_position_y[stage_key].pop_front())
	var target: Node = Global.create_monster(boss_id, monster, spawn_position)
	if target != null:
		if not _spawned_bosses.has(boss_id):
			_spawned_bosses[boss_id] = []
		var boss_list: Array = _spawned_bosses[boss_id]
		boss_list.append(target)
		_hide_bg_sword_for_boss(boss_id)
		can_create = false


func _setup_tzsijian_background() -> void:
	if bg_base != null:
		bg_base.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		bg_base.z_index = 0
	for node_name in BG_ANIMATIONS.keys():
		var info: Dictionary = BG_ANIMATIONS[node_name]
		var dir_name := str(info["dir"])
		var sprite := StreamedPngEffect.new()
		sprite.name = str(node_name)
		sprite.sequence = _background_sequence(dir_name)
		sprite.auto_free = false
		sprite.position = info["pos"]
		sprite.scale = Vector2.ONE / BG_EXPORT_SCALE
		sprite.z_index = int(info["z"])
		front.add_child(sprite)
		_bg_anim_nodes.append(sprite)
		if str(node_name).begins_with("sword"):
			_bg_sword_nodes[node_name] = sprite


static func _background_sequence(dir_name: String) -> FrameSequence:
	return FrameSequenceStore.get_sequence(StringName("tzsijian/bg/" + dir_name))


func _update_sword_boss_sequence() -> void:
	for index in range(SWORD_BOSS_IDS.size() - 1):
		var boss_id := int(SWORD_BOSS_IDS[index])
		var next_boss_id := int(SWORD_BOSS_IDS[index + 1])
		if _queued_boss_ids.has(next_boss_id):
			continue
		if _boss_wave_reached_trigger(boss_id):
			_queue_next_sword_boss(next_boss_id)


func _queue_next_sword_boss(boss_id: int) -> void:
	if _queued_boss_ids.has(boss_id) or _preparing_boss_ids.has(boss_id) or not SWORD_BOSS_POSITIONS.has(boss_id):
		return
	_prewarm_and_queue_sword_boss(boss_id)


func _prewarm_and_queue_sword_boss(boss_id: int) -> void:
	_preparing_boss_ids[boss_id] = true
	await SwordBossBase.prewarm_sword_boss_frames_async([boss_id])
	_preparing_boss_ids.erase(boss_id)
	if not is_inside_tree() or _queued_boss_ids.has(boss_id):
		return
	_queue_sword_boss_wave(boss_id)
	while current_stage == 1 and check_can_create(1):
		level_create_monster(1)


func _queue_sword_boss_wave(boss_id: int) -> void:
	_queued_boss_ids[boss_id] = true
	for index in range(_boss_count_multiplier):
		var spawn_position := _get_boss_spawn_position(boss_id, index)
		monster_group["stage_1"].append(boss_id)
		monster_position_x["stage_1"].append(spawn_position.x)
		monster_position_y["stage_1"].append(spawn_position.y)


func _get_boss_spawn_position(boss_id: int, index: int) -> Vector2:
	var base_position: Vector2 = SWORD_BOSS_POSITIONS[boss_id]
	var middle := float(_boss_count_multiplier - 1) * 0.5
	var position := base_position + Vector2((float(index) - middle) * BOSS_SPAWN_X_SPACING, 0.0)
	position.x = clampf(position.x, 180.0, 1120.0)
	if index % 2 == 1:
		position.y += 24.0
	return position


func _boss_wave_reached_trigger(boss_id: int) -> bool:
	var bosses: Array = _spawned_bosses.get(boss_id, [])
	for boss in bosses:
		if boss == null or not is_instance_valid(boss):
			continue
		if boss.max_hp <= 0:
			continue
		if float(boss.hp) / float(boss.max_hp) <= BOSS_HP_TRIGGER:
			return true
	return false


func _hide_bg_sword_for_boss(boss_id: int) -> void:
	var node_name := str(BOSS_TO_BG_SWORD.get(boss_id, ""))
	if node_name == "":
		return
	var sword_node = _bg_sword_nodes.get(node_name, null)
	if sword_node != null and is_instance_valid(sword_node):
		sword_node.visible = false


func one_check_can_exit():
	var round_cleared: bool = bool(super.one_check_can_exit())
	if not round_cleared or not _queued_boss_ids.has(954) or not _preparing_boss_ids.is_empty():
		return false
	if not Global.is_special_dungeon_endless("res://Scene/level/level_tzsijian.tscn"):
		return true
	if not _endless_restart_pending:
		_endless_restart_pending = true
		call_deferred("_restart_endless_round")
	return false


func _restart_endless_round() -> void:
	if not is_inside_tree() or not Global.is_special_dungeon_endless("res://Scene/level/level_tzsijian.tscn"):
		_endless_restart_pending = false
		return
	await get_tree().process_frame
	if not is_inside_tree() or not Global.is_special_dungeon_endless("res://Scene/level/level_tzsijian.tscn"):
		_endless_restart_pending = false
		return
	_trim_endless_round_loot()
	for stage_key in ["stage_1", "stage_2", "stage_3", "stage_4"]:
		monster_group[stage_key].clear()
		monster_position_x[stage_key].clear()
		monster_position_y[stage_key].clear()
	_spawned_bosses.clear()
	_queued_boss_ids.clear()
	_preparing_boss_ids.clear()
	await get_tree().create_timer(ENDLESS_ROUND_DELAY, false).timeout
	if not is_inside_tree() or not Global.is_special_dungeon_endless("res://Scene/level/level_tzsijian.tscn"):
		_endless_restart_pending = false
		return
	for sword_node in _bg_sword_nodes.values():
		if sword_node != null and is_instance_valid(sword_node):
			sword_node.visible = true
	can_exit = false
	exit.visible = false
	exit_2.disabled = true
	_queue_sword_boss_wave(951)
	while current_stage == 1 and check_can_create(1):
		level_create_monster(1)
	_endless_restart_pending = false


func _trim_endless_round_loot() -> void:
	if fall_it == null or not is_instance_valid(fall_it):
		return
	var loot_nodes: Array[Node] = []
	for child in fall_it.get_children():
		if child != null and is_instance_valid(child) and child.has_method("pick_up_items"):
			loot_nodes.append(child)
	const MAX_ENDLESS_LOOT := 24
	var remove_count := maxi(loot_nodes.size() - MAX_ENDLESS_LOOT, 0)
	for index in range(remove_count):
		var loot := loot_nodes[index]
		if loot != null and is_instance_valid(loot):
			loot.queue_free()


func set_through() -> void:
	if current_stage == 1:
		if not is_set:
			my_camera.limit_smoothed = false
			my_camera.position_smoothing_enabled = false
			is_set = true
		my_camera.max_left = 0
		my_camera.max_right = 1200
		stop_1.disabled = true
		stop_5.disabled = false
