extends BaseLevel

const BOSS_ORDER: Array[int] = [163, 175, 165, 166, 168, 169, 174, 164]
const CAMERA_RIGHT_LIMIT := 1200.0

const LEVEL_BXGH_BOSS_DATA := {
	163:
	{
		"name": "魔·吕洞宾",
		"level": 65,
		"hp": 2400000,
		"attack": 60,
		"def": 560,
		"mdef": 560,
		"crit": 300,
		"miss": 100,
		"hit": 500,
		"toughness": 30.0,
		"crit_reduce": 15,
		"armor_break": 400,
		"magic_break": 400,
		"speed": 20.0,
		"sight": 1000,
		"range": 230,
		"attack_desire": 300,
		"behit_calmtime": 0.12,
		"exp": 4500,
		"coin": 2400,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": true,
		"max_protect": 100.0,
		"attacks":
		{
			"hit1": {"power": 1200, "hurt_back": [-8, -2], "kind": "physics", "protect": 8},
			"hit2": {"power": 1500, "hurt_back": [-10, -4], "kind": "magic", "protect": 8},
			"hit3": {"power": 1800, "hurt_back": [-14, -6], "kind": "magic", "protect": 8}
		}
	},
	164:
	{
		"name": "魔·铁拐李",
		"level": 65,
		"hp": 2400000,
		"attack": 60,
		"def": 560,
		"mdef": 560,
		"crit": 300,
		"miss": 100,
		"hit": 500,
		"toughness": 30.0,
		"crit_reduce": 15,
		"armor_break": 400,
		"magic_break": 400,
		"speed": 20.0,
		"sight": 1000,
		"range": 230,
		"attack_desire": 300,
		"behit_calmtime": 0.12,
		"exp": 4500,
		"coin": 2400,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": true,
		"max_protect": 100.0,
		"attacks":
		{
			"hit1": {"power": 1200, "hurt_back": [-8, -2], "kind": "physics", "protect": 8},
			"hit2": {"power": 1500, "hurt_back": [-10, -4], "kind": "magic", "protect": 8},
			"hit3": {"power": 1800, "hurt_back": [-14, -6], "kind": "magic", "protect": 8}
		}
	},
	165:
	{
		"name": "魔·韩湘子",
		"level": 65,
		"hp": 2400000,
		"attack": 60,
		"def": 560,
		"mdef": 560,
		"crit": 300,
		"miss": 100,
		"hit": 500,
		"toughness": 30.0,
		"crit_reduce": 15,
		"armor_break": 400,
		"magic_break": 400,
		"speed": 20.0,
		"sight": 1000,
		"range": 230,
		"attack_desire": 300,
		"behit_calmtime": 0.12,
		"exp": 4500,
		"coin": 2400,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": true,
		"max_protect": 100.0,
		"attacks":
		{
			"hit1": {"power": 1200, "hurt_back": [-8, -2], "kind": "physics", "protect": 8},
			"hit2": {"power": 1500, "hurt_back": [-10, -4], "kind": "magic", "protect": 8},
			"hit3": {"power": 1800, "hurt_back": [-14, -6], "kind": "magic", "protect": 8}
		}
	},
	166:
	{
		"name": "魔·汉钟离",
		"level": 65,
		"hp": 2400000,
		"attack": 60,
		"def": 560,
		"mdef": 560,
		"crit": 300,
		"miss": 100,
		"hit": 500,
		"toughness": 30.0,
		"crit_reduce": 15,
		"armor_break": 400,
		"magic_break": 400,
		"speed": 20.0,
		"sight": 1000,
		"range": 230,
		"attack_desire": 300,
		"behit_calmtime": 0.12,
		"exp": 4500,
		"coin": 2400,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": true,
		"max_protect": 100.0,
		"attacks":
		{
			"hit1": {"power": 1200, "hurt_back": [-8, -2], "kind": "physics", "protect": 8},
			"hit2": {"power": 1500, "hurt_back": [-10, -4], "kind": "magic", "protect": 8},
			"hit3": {"power": 1800, "hurt_back": [-14, -6], "kind": "magic", "protect": 8}
		}
	},
	168:
	{
		"name": "魔·张果老",
		"level": 65,
		"hp": 2400000,
		"attack": 60,
		"def": 560,
		"mdef": 560,
		"crit": 300,
		"miss": 100,
		"hit": 500,
		"toughness": 30.0,
		"crit_reduce": 15,
		"armor_break": 400,
		"magic_break": 400,
		"speed": 20.0,
		"sight": 1000,
		"range": 230,
		"attack_desire": 300,
		"behit_calmtime": 0.12,
		"exp": 4500,
		"coin": 2400,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": true,
		"max_protect": 100.0,
		"attacks":
		{
			"hit1": {"power": 1200, "hurt_back": [-8, -2], "kind": "physics", "protect": 8},
			"hit2": {"power": 1500, "hurt_back": [-10, -4], "kind": "magic", "protect": 8},
			"hit3": {"power": 1800, "hurt_back": [-14, -6], "kind": "magic", "protect": 8}
		}
	},
	169:
	{
		"name": "魔·蓝采和",
		"level": 65,
		"hp": 2400000,
		"attack": 60,
		"def": 560,
		"mdef": 560,
		"crit": 300,
		"miss": 100,
		"hit": 500,
		"toughness": 30.0,
		"crit_reduce": 15,
		"armor_break": 400,
		"magic_break": 400,
		"speed": 20.0,
		"sight": 1000,
		"range": 230,
		"attack_desire": 300,
		"behit_calmtime": 0.12,
		"exp": 4500,
		"coin": 2400,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": true,
		"max_protect": 100.0,
		"attacks":
		{
			"hit1": {"power": 1200, "hurt_back": [-8, -2], "kind": "physics", "protect": 8},
			"hit2": {"power": 0, "hurt_back": [-10, -4], "kind": "magic", "protect": 8},
			"hit3": {"power": 1800, "hurt_back": [-14, -6], "kind": "magic", "protect": 8}
		}
	},
	174:
	{
		"name": "魔·曹国舅",
		"level": 65,
		"hp": 2400000,
		"attack": 60,
		"def": 560,
		"mdef": 560,
		"crit": 300,
		"miss": 100,
		"hit": 500,
		"toughness": 30.0,
		"crit_reduce": 15,
		"armor_break": 400,
		"magic_break": 400,
		"speed": 20.0,
		"sight": 1000,
		"range": 230,
		"attack_desire": 300,
		"behit_calmtime": 0.12,
		"exp": 4500,
		"coin": 2400,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": true,
		"max_protect": 100.0,
		"attacks":
		{
			"hit1": {"power": 1200, "hurt_back": [-8, -2], "kind": "physics", "protect": 8},
			"hit2": {"power": 1500, "hurt_back": [-10, -4], "kind": "magic", "protect": 8},
			"hit3": {"power": 1800, "hurt_back": [-14, -6], "kind": "magic", "protect": 8}
		}
	},
	175:
	{
		"name": "魔·何仙姑",
		"level": 65,
		"hp": 2400000,
		"attack": 60,
		"def": 560,
		"mdef": 560,
		"crit": 300,
		"miss": 100,
		"hit": 500,
		"toughness": 30.0,
		"crit_reduce": 15,
		"armor_break": 400,
		"magic_break": 400,
		"speed": 20.0,
		"sight": 1000,
		"range": 230,
		"attack_desire": 300,
		"behit_calmtime": 0.12,
		"exp": 4500,
		"coin": 2400,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": true,
		"max_protect": 100.0,
		"attacks":
		{
			"hit1": {"power": 1200, "hurt_back": [-8, -2], "kind": "physics", "protect": 8},
			"hit2": {"power": 1500, "hurt_back": [-10, -4], "kind": "magic", "protect": 8},
			"hit3": {"power": 1800, "hurt_back": [-14, -6], "kind": "magic", "protect": 8}
		}
	},
}

const EIGHT_IMMORTAL_DROP_DATA := {
	163: [{"name": "yyzlj", "value": 0, "chance": 0.1}],
	175: [{"name": "hehua", "value": 0, "chance": 0.1}],
	165: [{"name": "zhyx", "value": 0, "chance": 0.1}],
	166: [{"name": "bjs", "value": 0, "chance": 0.1}],
	168: [{"name": "sxyg", "value": 0, "chance": 0.1}],
	169: [{"name": "dkhl", "value": 0, "chance": 0.1}],
	174: [{"name": "yyb", "value": 0, "chance": 0.1}],
	164: [{"name": "ywhl", "value": 0, "chance": 0.1}],
}

@onready var left_wall: CollisionShape2D = $wall/left_wall
@onready var right_wall: CollisionShape2D = $wall/right_wall
@onready var stage_501_boat: LevelBXGHBoat = $stage501Boat

var selected_boss_id: int = BOSS_ORDER[0]
var _boss_node: BaseMonster
var _boss_death_handled := false


func _ready() -> void:
	selected_boss_id = int(Global.selected_eight_immortal_id)
	if selected_boss_id not in BOSS_ORDER:
		selected_boss_id = BOSS_ORDER[0]
	monster_group = {
		"stage_1": [selected_boss_id],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_x = {
		"stage_1": [599],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_y = {
		"stage_1": [0],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	_align_boss_spawn_height()
	Global.current_level = "八仙过海"
	Global.game_over = 1
	level_stage = 0
	current_stage = 1
	is_two_scene = false
	Global.get_audio_runtime().add_bgm(self, "res://Music/level/bgm_normal.mp3")
	super._ready()
	if _role != null:
		_role.set_meta("disable_down_drop", true)
	exit.visible = false
	exit_2.disabled = true


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if my_camera != null:
		my_camera.max_left = 0
		my_camera.max_right = CAMERA_RIGHT_LIMIT
	if role_information != null and role_information.gogo != null:
		role_information.gogo.visible = one_check_can_exit()
	if _boss_is_dead():
		_handle_boss_death()


func _preload_level_resources() -> void:
	await Global.preload_level_monster_runtime_resources([selected_boss_id])


func get_level_monster_config(monster_id: int) -> Dictionary:
	var config: Variant = LEVEL_BXGH_BOSS_DATA.get(monster_id, {})
	var result := (config as Dictionary).duplicate(true) if config is Dictionary else {}
	if EIGHT_IMMORTAL_DROP_DATA.has(monster_id):
		result["independent_drop_list"] = EIGHT_IMMORTAL_DROP_DATA[monster_id].duplicate(true)
	return result


func _align_boss_spawn_height() -> void:
	if stage_501_boat == null or monster == null:
		return
	var collision := stage_501_boat.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision == null or collision.shape == null:
		return
	var boat_floor_y := collision.global_position.y - collision.shape.get_rect().size.y * 0.5
	monster_position_y["stage_1"][0] = boat_floor_y - _get_boss_floor_offset() - monster.global_position.y


func _get_boss_floor_offset() -> float:
	var boss_scene := load("res://Scene/monster/monster_%d.tscn" % selected_boss_id) as PackedScene
	if boss_scene == null:
		return 0.0
	var preview := boss_scene.instantiate()
	var pz_node := preview.get_node_or_null("pz") as CollisionShape2D
	var offset := 0.0
	if pz_node != null and pz_node.shape != null:
		offset = pz_node.position.y + pz_node.shape.get_rect().size.y * 0.5
	preview.free()
	return offset


func _on_create_control_timeout() -> void:
	if check_can_create(1):
		level_create_monster(1)
		_boss_node = mr as BaseMonster


func _has_pending_boss_node() -> bool:
	for child in monster.get_children():
		if child is BaseMonster and not child.is_queued_for_deletion():
			return true
	return false


func _boss_is_dead() -> bool:
	if _boss_node != null and is_instance_valid(_boss_node):
		return _boss_node.hp <= 0
	for child in monster.get_children():
		if child is BaseMonster and not child.is_queued_for_deletion() and child.hp <= 0:
			return true
	return false


func _handle_boss_death() -> void:
	if _boss_death_handled:
		return
	_boss_death_handled = true
	PlayerData.record_eight_immortal_daily_defeat(selected_boss_id)
	if not MemoryClass.request_save("level_bxgh_boss", false):
		Global.add_message_show(get_parent(), "存档保存失败，请重试", 2.0, Vector2(470, 300))
	if stage_501_boat != null:
		stage_501_boat.set_static()

		if exit != null:
			var configured_exit_y := exit.global_position.y
			exit.global_position = Vector2(stage_501_boat.global_position.x, configured_exit_y)
			exit.visible = true
		if exit_2 != null:
			exit_2.disabled = false


func _on_fall_death_body_entered(body: Node2D) -> void:
	if (body == _role or body is BaseHero) and RoleProp.roleprop != null:
		RoleProp.roleprop.Hp = 0
	elif body is BaseMonster and is_instance_valid(body):
		(body as BaseMonster).hp = 0


func set_through() -> void:
	if left_wall != null:
		left_wall.disabled = false
	if right_wall != null:
		right_wall.disabled = false


func one_check_can_exit() -> bool:
	return monster_group["stage_1"].is_empty() and not _has_pending_boss_node()


func check_can_exit() -> bool:
	return one_check_can_exit()
