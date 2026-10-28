extends Node2D
class_name BaseLevel
const PET_LIFE_BONUS_RUNTIME := preload("res://Script/pet/pet_life_bonus_runtime.gd")
const PET_SKILL_PROGRESSION := preload("res://Script/pet/pet_skill_progression.gd")
var is_two_scene

var bgm_node: Node = null
var bgm_changed_for_stage_4: bool = false

@onready var monster: Node2D = $Monster
@onready var hero: Node2D = $Hero
@onready var exit: AnimatedSprite2D = $exit
@onready var exit_2: CollisionShape2D = $exit/exit2/exit
@onready var fall_it = $fall_items
@onready var create_control: Timer = $create_control
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var lj_tt: Node2D = $CanvasLayer/lj_tt
@onready var end: ParallaxLayer = $BackGround/End
@onready var front: ParallaxLayer = $BackGround/front
@onready var floor_2: ParallaxLayer = $BackGround/floor_2
@onready var monster_blood: VBoxContainer = $CanvasLayer/MonsterBlood
@onready var create_1: Node2D = $Create_1
@onready var create_2: Node2D = $Create_2
@onready var create_3: Node2D = $Create_3
@onready var create_4: Node2D = $Create_4

var is_set_smooth
var mr: BaseMonster
var _role
var role_p2: BaseHero
var my_camera
var role_information
var level_stage
var can_exit = false
var _exit_players: Dictionary = {}
var _auto_exit_settling := false
var current_stage = 0
var back_target
var monster_group = {
	"stage_1": [],
	"stage_2": [],
	"stage_3": [],
	"stage_4": [],
}
var monster_position_x = {
	"stage_1": [],
	"stage_2": [],
	"stage_3": [],
	"stage_4": [],
}
var monster_position_y = {
	"stage_1": [],
	"stage_2": [],
	"stage_3": [],
	"stage_4": [],
}
var monster_array: Array = []
var can_create: bool
var mr_num = 0

var _active_monsters: Dictionary = {}
var _active_monster_index_ready := false
var _active_monster_version := 0
var _stage_preload_requested: Dictionary = {}

@onready var _green_detector: Area2D = $GreenDetector


func _ready() -> void:
	_initialize_active_monster_index()
	create_control.stop()
	if not self is Level20:
		RoleProp.ws_value = 0
	create_control.wait_time = float(MainSet.set_data.get("CreateMonsterSpeed", 0.3))
	MainMusic.remove_music()
	if not Global.is_show:
		var zm_player: AnimationPlayer = $CanvasLayer/zmPLAYER
		if zm_player.has_animation("gdzm"):
			zm_player.play("gdzm")
		Global.is_show = true
		pass
	Global.is_show = true
	Global.fb_cd = -10
	Global.last_level_path = str(self.scene_file_path)
	remove_all_records()
	Global.level_begin_time = Time.get_datetime_string_from_system(false, true)
	var role_id = int(PlayerData.player_data.get("Myself", 1))
	if role_id <= 0:
		role_id = 1
	_role = Global.call_hero("role_" + str(role_id), hero, Vector2(100, 340), false)
	if LocalCoop.is_enabled():
		LocalCoop.secondary_props.ws_value = 0
		role_p2 = Global.call_hero(
			"role_" + str(int(LocalCoop.secondary_data.player_data.Myself)), hero, Vector2(170, 340), false, 2
		)
		if role_p2 != null:
			role_p2.action.scale.x = -1
			role_p2.base_damagebox.scale.x = -1
			role_p2.set_meta("coop_slot", 2)
		LocalCoop.secondary_data.add_ini_buff()
	if role_information == null:
		role_information = Global.add_role_information(self, Vector2(0, 0))
		role_information.z_index = 10

	if _role != null:
		call_deferred("_spawn_active_pet_deferred")
		_role.action.scale.x = -1
		_role.base_damagebox.scale.x = -1
		my_camera = Global.add_camera(_role, Vector2(0, 0), 1200)
		my_camera.max_left = 0
		my_camera.max_top = 0
		my_camera.max_bottom = 590
		await get_tree().create_timer(0.1, false).timeout

		my_camera.limit_smoothed = true
		my_camera.position_smoothing_enabled = true
	PlayerData.add_ini_buff()

	call_deferred("_prepare_level_runtime_resources")

	if _green_detector:
		_green_detector.collision_layer = 16

		_green_detector.add_to_group("green_detector")
		print("[调试] GreenDetector 已设置：collision_layer=4，已加入 green_detector 组")
		print("[调试] GreenDetector 位置：", _green_detector.global_position)
	else:
		print("[错误] _green_detector 为 null，请检查场景中是否存在 GreenDetector 节点")


func _initialize_active_monster_index() -> void:
	if _active_monster_index_ready:
		return
	_active_monster_index_ready = true
	var tree := get_tree()
	if tree == null:
		return
	tree.node_added.connect(_on_level_node_added)
	tree.node_removed.connect(_on_level_node_removed)
	_index_monsters_recursive(self)


func _on_level_node_added(node: Node) -> void:
	if node is BaseMonster and is_ancestor_of(node):
		var id := node.get_instance_id()
		if not _active_monsters.has(id):
			_active_monsters[id] = node
			_active_monster_version += 1


func _on_level_node_removed(node: Node) -> void:
	if node is BaseMonster:
		var id := node.get_instance_id()
		if _active_monsters.erase(id):
			_active_monster_version += 1


func _index_monsters_recursive(node: Node) -> void:
	if node is BaseMonster:
		_active_monsters[node.get_instance_id()] = node
	for child in node.get_children():
		_index_monsters_recursive(child)


func get_active_monsters() -> Array[BaseMonster]:
	var result: Array[BaseMonster] = []
	var stale_ids: Array[int] = []
	for id_value in _active_monsters.keys():
		var node: Variant = _active_monsters[id_value]
		if node == null or not is_instance_valid(node) or not (node is BaseMonster):
			stale_ids.append(int(id_value))
			continue
		var monster_node := node as BaseMonster
		if not monster_node.is_inside_tree() or monster_node.is_queued_for_deletion():
			stale_ids.append(int(id_value))
			continue
		if monster_node.hp > 0:
			result.append(monster_node)
	for stale_id in stale_ids:
		_active_monsters.erase(stale_id)
	return result


func has_active_monster_index() -> bool:
	return _active_monster_index_ready


func get_active_monster_version() -> int:
	return _active_monster_version


func _is_active_pet_dead_this_level(pet_name: String = "", slot: int = 1) -> bool:
	if not bool(get_meta(LocalCoop.pet_meta_key("active_pet_dead_this_level", slot), false)):
		return false
	var aliases := _active_pet_dead_aliases(pet_name)
	var dead_pet_keys_value: Variant = get_meta(LocalCoop.pet_meta_key("active_pet_dead_keys", slot), [])
	if dead_pet_keys_value is Array:
		for alias in aliases:
			if dead_pet_keys_value.has(alias):
				return true
	var dead_type := str(get_meta(LocalCoop.pet_meta_key("active_pet_dead_type", slot), ""))
	if dead_type != "" and aliases.has(dead_type):
		return true
	var dead_name := str(get_meta(LocalCoop.pet_meta_key("active_pet_dead_name", slot), ""))
	var dead_display_name := str(get_meta(LocalCoop.pet_meta_key("active_pet_dead_display_name", slot), ""))
	return dead_name == "" or aliases.has(dead_name) or aliases.has(dead_display_name)


func _active_pet_dead_aliases(pet_name: String) -> Array[String]:
	var aliases: Array[String] = [pet_name]
	if pet_name == "PetNeat" or pet_name in ["丑牛", "丑牛元帅", "丑牛大元帅"]:
		aliases.append("PetNeat")
		aliases.append("丑牛元帅")
		aliases.append("丑牛大元帅")
	if pet_name == "PetYinTiger" or pet_name in ["寅虎", "银角虎", "寅虎元帅", "寅虎大元帅"]:
		aliases.append("PetYinTiger")
		aliases.append("寅虎元帅")
		aliases.append("寅虎大元帅")
	if pet_name == "PetMouse" or pet_name.begins_with("子鼠") or pet_name in ["子鼠元帅", "子鼠大元帅"]:
		aliases.append("PetMouse")
		for name in ["子鼠元帅", "子鼠大元帅"]:
			if not aliases.has(name):
				aliases.append(name)
	if pet_name == "PetRabbit" or pet_name in ["月兔", "疾风兔", "寒冰玉兔", "冰霜月神"]:
		aliases.append("PetRabbit")
		for name in ["月兔", "疾风兔", "寒冰玉兔", "冰霜月神"]:
			if not aliases.has(name):
				aliases.append(name)
	if pet_name == "PetTurtle" or pet_name.begins_with("玄武") or pet_name in ["龟布", "墨玄龟", "玄武将军", "玄武大帝"]:
		aliases.append("PetTurtle")
		for name in ["龟布", "墨玄龟", "玄武将军", "玄武大帝"]:
			if not aliases.has(name):
				aliases.append(name)
	if pet_name == "PetDragon" or pet_name.begins_with("辰龙") or pet_name in ["龙仔", "绿英龙", "青龙将军", "青龙妖圣"]:
		aliases.append("PetDragon")
		for name in ["龙仔", "绿英龙", "青龙将军", "青龙妖圣"]:
			if not aliases.has(name):
				aliases.append(name)
	if pet_name == "PetTiger" or pet_name in ["虎丸", "白灵虎", "白虎将军", "白虎战神", "白虎"]:
		aliases.append("PetTiger")
		for name in ["虎丸", "白灵虎", "白虎将军", "白虎战神", "白虎"]:
			if not aliases.has(name):
				aliases.append(name)
	return aliases


func _spawn_active_pet_deferred() -> void:
	if _role == null:
		return
	for i in range(20):
		if _role.has_method("is_on_floor") and _role.is_on_floor():
			break
		await get_tree().physics_frame
	await _spawn_active_pet(1)
	if is_instance_valid(role_p2) and LocalCoop.is_enabled():
		await _spawn_active_pet(2)


func _spawn_active_pet(slot: int = 1) -> void:
	var source_player: BaseHero = role_p2 if slot == 2 else _role
	if not is_instance_valid(source_player) or bool(source_player.get("is_death")) or monster == null:
		return
	var PlayerData: Node = LocalCoop.data_for_slot(slot)
	var pet_data := _get_active_pet_data(PlayerData)
	if pet_data.is_empty():
		return
	PlayerData.clamp_pet_level_to_player(pet_data)
	var pet_name := _pet_active_name(pet_data)
	if _is_active_pet_dead_this_level(pet_name, slot):
		pet_data[DataKeys.DEPLOYED] = false
		if str(PlayerData.player_data.get(_active_pet_name_key(), "")) == pet_name:
			PlayerData.player_data[_active_pet_name_key()] = ""
			PlayerData.player_data["出战宠物"] = ""
		return
	if int(pet_data.get(DataKeys.HP, 0)) <= 0:
		var hp_max := int(pet_data.get("生命上限", 1))
		pet_data[DataKeys.HP] = hp_max
	if int(pet_data.get(DataKeys.MP, 0)) <= 0:
		var mp_max := int(pet_data.get("魔法上限", 1))
		pet_data[DataKeys.MP] = mp_max
	var learned_custom_skills: Array = PET_LIFE_BONUS_RUNTIME.learned_skill_names(pet_data)
	var learned_custom_levels: Dictionary = {}
	for learned_skill in learned_custom_skills:
		learned_custom_levels[str(learned_skill)] = PET_SKILL_PROGRESSION.get_level(pet_data, str(learned_skill))
	var pet_kind := _pet_active_name(pet_data)
	if (
		pet_kind != "PetTiger"
		and pet_kind != "PetDragon"
		and pet_kind != "PetPhoenix"
		and pet_kind != "PetTurtle"
		and pet_kind != "PetRabbit"
		and pet_kind != "PetMouse"
		and pet_kind != "PetNeat"
		and pet_kind != "PetYinTiger"
	):
		return
	if monster != null:
		for child in monster.get_children():
			if (
				child != null
				and not child.is_queued_for_deletion()
				and int(child.get_meta("coop_slot", 1)) == slot
				and (
					child.has_meta("pet_tiger_unit")
					or child.has_meta("pet_dragon_unit")
					or child.has_meta("pet_phoenix_unit")
					or child.has_meta("pet_turtle_unit")
					or child.has_meta("pet_rabbit_unit")
					or child.has_meta("pet_mouse_unit")
					or child.has_meta("pet_neat_unit")
					or child.has_meta("pet_yin_tiger_unit")
				)
			):
				return
	if pet_kind == "PetYinTiger":
		_normalize_pet_yin_tiger_spawn_data(pet_data)
		_recalculate_active_pet_growth_stats(pet_data)
		_restore_active_pet_for_level_start(pet_data)
		_update_pet_yin_tiger_evolution(pet_data)
	elif pet_kind == "PetTiger":
		_normalize_pet_tiger_spawn_data(pet_data)
		_recalculate_active_pet_growth_stats(pet_data)
		_restore_active_pet_for_level_start(pet_data)
		_update_pet_tiger_evolution(pet_data)
	elif pet_kind == "PetDragon":
		_normalize_pet_dragon_spawn_data(pet_data)
		_recalculate_active_pet_growth_stats(pet_data)
		_restore_active_pet_for_level_start(pet_data)
		_update_pet_dragon_evolution(pet_data)
	elif pet_kind == "PetPhoenix":
		_normalize_pet_phoenix_spawn_data(pet_data)
		_recalculate_active_pet_growth_stats(pet_data)
		_restore_active_pet_for_level_start(pet_data)
		_update_pet_phoenix_evolution(pet_data)
	elif pet_kind == "PetTurtle":
		_normalize_pet_turtle_spawn_data(pet_data)
		_recalculate_active_pet_growth_stats(pet_data)
		_restore_active_pet_for_level_start(pet_data)
		_update_pet_turtle_evolution(pet_data)
	elif pet_kind == "PetRabbit":
		_normalize_pet_rabbit_spawn_data(pet_data)
		_recalculate_active_pet_growth_stats(pet_data)
		_restore_active_pet_for_level_start(pet_data)
		_update_pet_rabbit_evolution(pet_data)
	elif pet_kind == "PetMouse":
		_normalize_pet_mouse_spawn_data(pet_data)
		_recalculate_active_pet_growth_stats(pet_data)
		_restore_active_pet_for_level_start(pet_data)
		_update_pet_mouse_evolution(pet_data)
	elif pet_kind == "PetNeat":
		_normalize_pet_neat_spawn_data(pet_data)
		_recalculate_active_pet_growth_stats(pet_data)
		_restore_active_pet_for_level_start(pet_data)
		_update_pet_neat_evolution(pet_data)
	if not learned_custom_skills.is_empty():
		var normalized_skills: Array = pet_data.get("技能", []) if pet_data.get("技能", []) is Array else []
		for learned_skill in learned_custom_skills:
			if not normalized_skills.has(learned_skill):
				normalized_skills.append(learned_skill)
		pet_data["技能"] = normalized_skills
		var normalized_levels := PET_SKILL_PROGRESSION.ensure_levels(pet_data)
		for learned_skill in learned_custom_levels:
			normalized_levels[learned_skill] = learned_custom_levels[learned_skill]
	var pet_stage: int = _active_pet_stage_from_data(pet_data)
	await Global.prewarm_active_pet_runtime_resources()
	var scene_path := (
		_pet_yin_tiger_scene_path(pet_stage)
		if pet_kind == "PetYinTiger"
		else (
			_pet_neat_scene_path(pet_stage)
			if pet_kind == "PetNeat"
			else (
				_pet_mouse_scene_path(pet_stage)
				if pet_kind == "PetMouse"
				else (
					_pet_tiger_scene_path(pet_stage)
					if pet_kind == "PetTiger"
					else (
						_pet_phoenix_scene_path(pet_stage)
						if pet_kind == "PetPhoenix"
						else (
							_pet_turtle_scene_path(pet_stage)
							if pet_kind == "PetTurtle"
							else (
								_pet_rabbit_scene_path(pet_stage)
								if pet_kind == "PetRabbit"
								else _pet_dragon_scene_path(pet_stage)
							)
						)
					)
				)
			)
		)
	)
	var scene := Global.preload_scene_path(scene_path)
	if scene == null:
		return
	if not is_instance_valid(source_player) or monster == null:
		return
	var pet = scene.instantiate()
	pet.set_meta("coop_slot", slot)
	if pet_kind == "PetYinTiger":
		pet.set_meta("pet_yin_tiger_unit", true)
	elif pet_kind == "PetTiger":
		pet.set_meta("pet_tiger_unit", true)
	elif pet_kind == "PetPhoenix":
		pet.set_meta("pet_phoenix_unit", true)
	elif pet_kind == "PetTurtle":
		pet.set_meta("pet_turtle_unit", true)
	elif pet_kind == "PetRabbit":
		pet.set_meta("pet_rabbit_unit", true)
	elif pet_kind == "PetMouse":
		pet.set_meta("pet_mouse_unit", true)
	elif pet_kind == "PetNeat":
		pet.set_meta("pet_neat_unit", true)
	else:
		pet.set_meta("pet_dragon_unit", true)
	pet.set_meta("is_summon", true)
	if pet.has_method("apply_pet_data"):
		pet.apply_pet_data(pet_data)
	if pet_kind == "PetDragon" and pet.has_method("setup_pet_dragon"):
		pet.setup_pet_dragon(pet_stage)
	if pet_kind == "PetPhoenix" and pet.has_method("setup_pet_phoenix"):
		pet.setup_pet_phoenix(pet_stage)
	if pet_kind == "PetTurtle" and pet.has_method("setup_pet_turtle"):
		pet.setup_pet_turtle(pet_stage)
	if pet_kind == "PetRabbit" and pet.has_method("setup_pet_turtle"):
		pet.setup_pet_turtle(pet_stage)
	if pet_kind == "PetMouse" and pet.has_method("setup_pet_turtle"):
		pet.setup_pet_turtle(pet_stage)
	if pet_kind == "PetNeat" and pet.has_method("setup_pet_turtle"):
		pet.setup_pet_turtle(pet_stage)
	if pet_kind == "PetYinTiger" and pet.has_method("setup_pet_turtle"):
		pet.setup_pet_turtle(pet_stage)
	monster.add_child(pet)

	if pet.has_method("apply_pet_data"):
		pet.call_deferred("apply_pet_data", pet_data)
	if not learned_custom_skills.is_empty():
		var life_bonus_runtime := PET_LIFE_BONUS_RUNTIME.new()
		life_bonus_runtime.name = "PetLearnedSkillRuntime"
		life_bonus_runtime.setup(pet_data)
		pet.add_child(life_bonus_runtime)
	set_meta(LocalCoop.pet_meta_key("active_pet_unit", slot), pet)
	var spawn_position: Vector2 = _active_pet_spawn_position(pet, source_player)
	_place_active_pet_near_role(pet, spawn_position)
	call_deferred("_place_active_pet_near_role", pet, spawn_position)
	if pet.has_method("set_summon_properties"):
		pet.call_deferred("set_summon_properties", source_player, 0.0)


func _pet_dragon_stage_for_level(level: int) -> int:
	if level >= 50:
		return 4
	if level >= 30:
		return 3
	if level >= 15:
		return 2
	return 1


func _pet_dragon_stage_name(stage: int) -> String:
	match clampi(stage, 1, 4):
		1:
			return "龙仔"
		2:
			return "绿英龙"
		3:
			return "青龙将军"
		_:
			return "青龙妖圣"


func _pet_dragon_stage_skills(stage: int) -> Array:
	match clampi(stage, 1, 4):
		1:
			return ["分身"]
		2:
			return ["分身", "闪电冲刺"]
		3:
			return ["分身", "闪电冲刺", "雷霆万钧"]
		_:
			return ["分身", "闪电冲刺", "雷霆万钧", "青龙奥义"]


func _normalize_pet_dragon_spawn_data(pet: Dictionary) -> void:
	var PlayerData: Node = LocalCoop.pet_profile_for(pet)
	pet[DataKeys.TYPE] = "PetDragon"
	if not pet.has(DataKeys.ALT_NAME):
		pet[DataKeys.ALT_NAME] = "龙仔"
	if not pet.has("阶段"):
		pet["阶段"] = 1
	if not pet.has(DataKeys.LEVEL):
		pet[DataKeys.LEVEL] = int(pet.get("阶段", 1))
	pet[DataKeys.DEPLOYED] = bool(pet.get(DataKeys.DEPLOYED, true))


func _update_pet_dragon_evolution(pet: Dictionary) -> void:
	var PlayerData: Node = LocalCoop.pet_profile_for(pet)
	if not _is_pet_dragon_data(pet):
		return
	_normalize_pet_dragon_spawn_data(pet)
	var stage := _pet_dragon_stage_for_level(int(pet.get(DataKeys.LEVEL, 1)))
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = _pet_dragon_stage_name(stage)
	pet[DataKeys.TYPE] = "PetDragon"
	pet["技能"] = _pet_dragon_stage_skills(stage)
	if _pet_is_fighting(pet):
		PlayerData.player_data[_active_pet_name_key()] = "PetDragon"
		PlayerData.player_data["出战宠物"] = "PetDragon"


func _pet_dragon_scene_path(stage: int) -> String:
	return "res://Scene/pet/pet_dragon_summon_%d.tscn" % clampi(stage, 1, 4)


func _is_pet_dragon_data(pet: Dictionary) -> bool:
	var pet_name := str(pet.get(DataKeys.ALT_NAME, ""))
	var pet_title := str(pet.get(DataKeys.NAME, ""))
	if _is_pet_phoenix_name(pet_name) or _is_pet_phoenix_name(pet_title):
		return false
	if str(pet.get(DataKeys.TYPE, "")) == "PetDragon":
		return true
	return pet_name.begins_with("辰龙") or pet_name in ["龙仔", "绿英龙", "青龙将军", "青龙妖圣"]


func _pet_turtle_stage_for_level(level: int) -> int:
	if level >= 50:
		return 4
	if level >= 30:
		return 3
	if level >= 15:
		return 2
	return 1


func _pet_turtle_stage_name(stage: int) -> String:
	match clampi(stage, 1, 4):
		1:
			return "龟布"
		2:
			return "墨玄龟"
		3:
			return "玄武将军"
		_:
			return "玄武大帝"


func _pet_turtle_stage_skills(stage: int) -> Array:
	match clampi(stage, 1, 4):
		1:
			return ["水疗盾"]
		2:
			return ["水疗盾", "同心链接"]
		3:
			return ["水疗盾", "同心链接", "水湮八荒"]
		_:
			return ["水疗盾", "同心链接", "水湮八荒", "玄武奥义"]


func _normalize_pet_turtle_spawn_data(pet: Dictionary) -> void:
	var PlayerData: Node = LocalCoop.pet_profile_for(pet)
	var keep_fighting := (
		bool(pet.get(DataKeys.DEPLOYED, false))
		or str(PlayerData.player_data.get(_active_pet_name_key(), "")) == "PetTurtle"
	)
	var stage := _pet_turtle_stage_for_level(int(pet.get(DataKeys.LEVEL, 1)))
	pet[DataKeys.TYPE] = "PetTurtle"
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = _pet_turtle_stage_name(stage)
	pet[DataKeys.NAME] = _pet_turtle_stage_name(stage)
	pet["技能"] = _pet_turtle_stage_skills(stage)
	pet["生命资质基础上限"] = 4000
	pet["魔法资质基础上限"] = 1800
	pet["攻击资质基础上限"] = 1500
	pet["防御资质基础上限"] = 4000
	pet[DataKeys.DEPLOYED] = keep_fighting


func _update_pet_turtle_evolution(pet: Dictionary) -> void:
	var PlayerData: Node = LocalCoop.pet_profile_for(pet)
	if not _is_pet_turtle_data(pet):
		return
	_normalize_pet_turtle_spawn_data(pet)
	if _pet_is_fighting(pet):
		PlayerData.player_data[_active_pet_name_key()] = "PetTurtle"
		PlayerData.player_data["出战宠物"] = "PetTurtle"


func _pet_turtle_scene_path(stage: int) -> String:
	return "res://Scene/pet/pet_turtle_summon_%d.tscn" % clampi(stage, 1, 4)


func _is_pet_turtle_data(pet: Dictionary) -> bool:
	if str(pet.get(DataKeys.TYPE, "")) == "PetTurtle":
		return true
	var pet_name := str(pet.get(DataKeys.ALT_NAME, pet.get(DataKeys.NAME, ""))).strip_edges()
	return pet_name.begins_with("玄武") or pet_name in ["龟布", "墨玄龟", "玄武将军", "玄武大帝"]


func _is_pet_rabbit_data(pet: Dictionary) -> bool:
	if str(pet.get(DataKeys.TYPE, "")) == "PetRabbit":
		return true
	var pet_name := str(pet.get(DataKeys.ALT_NAME, pet.get(DataKeys.NAME, ""))).strip_edges()
	return pet_name in ["月兔", "疾风兔", "寒冰玉兔", "冰霜月神"]


func _pet_rabbit_stage_name(stage: int) -> String:
	return ["", "月兔", "疾风兔", "寒冰玉兔", "冰霜月神"][clampi(stage, 1, 4)]


func _pet_rabbit_stage_skills(stage: int) -> Array:
	match clampi(stage, 1, 4):
		1:
			return ["月光"]
		2:
			return ["月光", "疾风"]
		3:
			return ["月光", "疾风", "冰陨"]
		_:
			return ["月光", "疾风", "冰陨", "月神奥义"]


func _normalize_pet_rabbit_spawn_data(pet: Dictionary) -> void:
	var PlayerData: Node = LocalCoop.pet_profile_for(pet)
	var keep_fighting := (
		bool(pet.get(DataKeys.DEPLOYED, false))
		or str(PlayerData.player_data.get(_active_pet_name_key(), "")) == "PetRabbit"
	)
	var stage := _pet_tiger_stage_for_level(int(pet.get(DataKeys.LEVEL, 1)))
	pet[DataKeys.TYPE] = "PetRabbit"
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = _pet_rabbit_stage_name(stage)
	pet[DataKeys.NAME] = _pet_rabbit_stage_name(stage)
	pet["技能"] = _pet_rabbit_stage_skills(stage)
	pet["生命资质基础上限"] = 2500
	pet["魔法资质基础上限"] = 3000
	pet["攻击资质基础上限"] = 2800
	pet["防御资质基础上限"] = 1800
	pet[DataKeys.DEPLOYED] = keep_fighting


func _update_pet_rabbit_evolution(pet: Dictionary) -> void:
	var PlayerData: Node = LocalCoop.pet_profile_for(pet)
	if not _is_pet_rabbit_data(pet):
		return
	_normalize_pet_rabbit_spawn_data(pet)
	if _pet_is_fighting(pet):
		PlayerData.player_data[_active_pet_name_key()] = "PetRabbit"
		PlayerData.player_data["出战宠物"] = "PetRabbit"


func _pet_rabbit_scene_path(stage: int) -> String:
	return "res://Scene/pet/pet_rabbit_summon_%d.tscn" % clampi(stage, 1, 4)


func _is_pet_mouse_data(pet: Dictionary) -> bool:
	if str(pet.get(DataKeys.TYPE, "")) == "PetMouse":
		return true
	var pet_name := str(pet.get(DataKeys.ALT_NAME, "")).strip_edges()
	var pet_title := str(pet.get(DataKeys.NAME, "")).strip_edges()
	return (
		pet_name.begins_with("子鼠")
		or pet_title.begins_with("子鼠")
		or pet_name in ["子鼠元帅", "子鼠大元帅"]
		or pet_title in ["子鼠元帅", "子鼠大元帅"]
	)


func _pet_mouse_stage_for_level(level: int) -> int:
	return 2 if level >= 50 else 1


func _pet_mouse_stage_name(stage: int) -> String:
	return "子鼠大元帅" if clampi(stage, 1, 2) == 2 else "子鼠元帅"


func _pet_mouse_skills_for_level(pet_level: int) -> Array:
	if pet_level >= 50:
		return ["鼠窜", "回旋飞镖", "子鼠奥义"]
	if pet_level >= 30:
		return ["鼠窜", "回旋飞镖"]
	return ["鼠窜"]


func _normalize_pet_mouse_spawn_data(pet: Dictionary) -> void:
	var PlayerData: Node = LocalCoop.pet_profile_for(pet)
	var active_name := str(PlayerData.player_data.get(_active_pet_name_key(), ""))
	var keep_fighting := (
		bool(pet.get(DataKeys.DEPLOYED, false)) or active_name == "PetMouse" or active_name in ["子鼠元帅", "子鼠大元帅"]
	)
	var stage := _pet_mouse_stage_for_level(int(pet.get(DataKeys.LEVEL, 1)))
	pet[DataKeys.TYPE] = "PetMouse"
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = _pet_mouse_stage_name(stage)
	pet[DataKeys.NAME] = _pet_mouse_stage_name(stage)
	pet["技能"] = _pet_mouse_skills_for_level(int(pet.get(DataKeys.LEVEL, 1)))
	pet["生命资质基础上限"] = 2500
	pet["魔法资质基础上限"] = 1800
	pet["攻击资质基础上限"] = 3000
	pet["防御资质基础上限"] = 1800
	pet[DataKeys.DEPLOYED] = keep_fighting


func _update_pet_mouse_evolution(pet: Dictionary) -> void:
	var PlayerData: Node = LocalCoop.pet_profile_for(pet)
	if not _is_pet_mouse_data(pet):
		return
	_normalize_pet_mouse_spawn_data(pet)
	if _pet_is_fighting(pet):
		PlayerData.player_data[_active_pet_name_key()] = "PetMouse"
		PlayerData.player_data["出战宠物"] = "PetMouse"


func _pet_mouse_scene_path(stage: int) -> String:
	return "res://Scene/pet/pet_mouse_summon_%d.tscn" % clampi(stage, 1, 2)


func _is_pet_neat_data(pet: Dictionary) -> bool:
	if str(pet.get(DataKeys.TYPE, "")) == "PetNeat":
		return true
	var name := str(pet.get(DataKeys.ALT_NAME, pet.get(DataKeys.NAME, ""))).strip_edges()
	return name in ["丑牛", "丑牛元帅", "丑牛大元帅"]


func _pet_neat_stage_for_level(level: int) -> int:
	return 4 if level >= 50 else 3 if level >= 30 else 2 if level >= 15 else 1


func _pet_neat_stage_name(stage: int) -> String:
	return "丑牛大元帅" if clampi(stage, 1, 4) == 4 else "丑牛元帅"


func _pet_neat_stage_skills(stage: int) -> Array:
	match clampi(stage, 1, 4):
		3:
			return ["蛮牛冲撞", "蛮力践踏"]
		4:
			return ["蛮牛冲撞", "蛮力践踏", "丑牛奥义"]
		_:
			return ["蛮牛冲撞"]


func _normalize_pet_neat_spawn_data(pet: Dictionary) -> void:
	var PlayerData: Node = LocalCoop.pet_profile_for(pet)
	var active_name := str(PlayerData.player_data.get(_active_pet_name_key(), ""))
	var keep_fighting := (
		bool(pet.get(DataKeys.DEPLOYED, false)) or active_name == "PetNeat" or active_name in ["丑牛", "丑牛元帅", "丑牛大元帅"]
	)
	var stage := _pet_neat_stage_for_level(int(pet.get(DataKeys.LEVEL, 1)))
	pet[DataKeys.TYPE] = "PetNeat"
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = _pet_neat_stage_name(stage)
	pet[DataKeys.NAME] = _pet_neat_stage_name(stage)
	pet["技能"] = _pet_neat_stage_skills(stage)
	pet[DataKeys.DEPLOYED] = keep_fighting


func _update_pet_neat_evolution(pet: Dictionary) -> void:
	var PlayerData: Node = LocalCoop.pet_profile_for(pet)
	if not _is_pet_neat_data(pet):
		return
	_normalize_pet_neat_spawn_data(pet)
	if _pet_is_fighting(pet):
		PlayerData.player_data[_active_pet_name_key()] = "PetNeat"
		PlayerData.player_data["出战宠物"] = "PetNeat"


func _pet_neat_scene_path(stage: int) -> String:
	return "res://Scene/pet/pet_neat_summon_%d.tscn" % clampi(stage, 1, 4)


func _is_pet_yin_tiger_data(pet: Dictionary) -> bool:
	if str(pet.get(DataKeys.TYPE, "")) == "PetYinTiger":
		return true
	var pet_name := str(pet.get(DataKeys.ALT_NAME, pet.get(DataKeys.NAME, ""))).strip_edges()
	return pet_name in ["寅虎", "银角虎", "寅虎元帅", "寅虎大元帅"]


func _pet_yin_tiger_stage_for_level(level: int) -> int:
	return 4 if level >= 50 else 3 if level >= 30 else 2 if level >= 15 else 1


func _pet_yin_tiger_stage_name(stage: int) -> String:
	return "寅虎大元帅" if clampi(stage, 1, 4) == 4 else "寅虎元帅"


func _pet_yin_tiger_stage_skills(stage: int) -> Array:
	return ["虎啸"] if clampi(stage, 1, 4) < 4 else ["虎啸", "猛虎下山", "寅虎奥义"]


func _normalize_pet_yin_tiger_spawn_data(pet: Dictionary) -> void:
	var PlayerData: Node = LocalCoop.pet_profile_for(pet)
	var active_name := str(PlayerData.player_data.get(_active_pet_name_key(), ""))
	var keep_fighting := (
		bool(pet.get(DataKeys.DEPLOYED, false))
		or active_name == "PetYinTiger"
		or active_name in ["寅虎", "银角虎", "寅虎元帅", "寅虎大元帅"]
	)
	var stage := _pet_yin_tiger_stage_for_level(int(pet.get(DataKeys.LEVEL, 1)))
	pet[DataKeys.TYPE] = "PetYinTiger"
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = _pet_yin_tiger_stage_name(stage)
	pet[DataKeys.NAME] = pet[DataKeys.ALT_NAME]
	pet["技能"] = _pet_yin_tiger_stage_skills(stage)
	pet["生命资质基础上限"] = 2800
	pet["魔法资质基础上限"] = 2200
	pet["攻击资质基础上限"] = 3200
	pet["防御资质基础上限"] = 2200
	pet[DataKeys.DEPLOYED] = keep_fighting


func _update_pet_yin_tiger_evolution(pet: Dictionary) -> void:
	var PlayerData: Node = LocalCoop.pet_profile_for(pet)
	if not _is_pet_yin_tiger_data(pet):
		return
	_normalize_pet_yin_tiger_spawn_data(pet)
	if _pet_is_fighting(pet):
		PlayerData.player_data[_active_pet_name_key()] = "PetYinTiger"
		PlayerData.player_data["出战宠物"] = "PetYinTiger"


func _pet_yin_tiger_scene_path(stage: int) -> String:
	return "res://Scene/pet/pet_yin_tiger_summon_%d.tscn" % clampi(stage, 1, 4)


func _pet_tiger_stage_for_level(level: int) -> int:
	if level >= 50:
		return 4
	if level >= 30:
		return 3
	if level >= 15:
		return 2
	return 1


func _pet_tiger_stage_name(stage: int) -> String:
	match clampi(stage, 1, 4):
		1:
			return "虎丸"
		2:
			return "白灵虎"
		3:
			return "白虎将军"
		_:
			return "白虎战神"


func _pet_tiger_stage_skills(stage: int) -> Array:
	match clampi(stage, 1, 4):
		1:
			return ["猛扑", "虎啸"]
		2:
			return ["猛扑", "虎啸", "嗜血虎爪"]
		_:
			return ["猛扑", "虎啸", "嗜血虎爪", "横扫千军"]


func _normalize_pet_tiger_spawn_data(pet: Dictionary) -> void:
	var PlayerData: Node = LocalCoop.pet_profile_for(pet)
	pet[DataKeys.TYPE] = "PetTiger"
	if not pet.has(DataKeys.ALT_NAME):
		pet[DataKeys.ALT_NAME] = "虎丸"
	if not pet.has("阶段"):
		pet["阶段"] = 1
	if not pet.has(DataKeys.LEVEL):
		pet[DataKeys.LEVEL] = int(pet.get("阶段", 1))
	pet[DataKeys.DEPLOYED] = bool(pet.get(DataKeys.DEPLOYED, true))


func _ensure_pet_growth_fields_for_spawn(pet: Dictionary) -> void:
	pet["悟性"] = clampi(int(pet.get("悟性", 0)), 0, 25)
	pet["根骨"] = clampi(int(pet.get("根骨", 0)), 0, 25)
	pet["灵力"] = clampi(int(pet.get("灵力", 0)), 0, 25)
	if not pet.has("生命资质"):
		pet["生命资质"] = 1000
	if not pet.has("生命资质上限"):
		pet["生命资质上限"] = 2000
	if not pet.has("魔法资质"):
		pet["魔法资质"] = 1000
	if not pet.has("魔法资质上限"):
		pet["魔法资质上限"] = 2000
	if not pet.has("攻击资质"):
		pet["攻击资质"] = 1000
	if not pet.has("攻击资质上限"):
		pet["攻击资质上限"] = 2000
	if not pet.has("防御资质"):
		pet["防御资质"] = 1000
	if not pet.has("防御资质上限"):
		pet["防御资质上限"] = 2000
	var wisdom_bonus: int = int(pet.get("悟性", 0)) * 100
	for quality_name in ["生命", "魔法", "攻击", "防御"]:
		var maximum_key: String = "%s资质上限" % quality_name
		var base_key: String = "%s资质基础上限" % quality_name
		if not pet.has(base_key):
			pet[base_key] = int(pet.get(maximum_key, 2000))
		pet[maximum_key] = max(0, int(pet.get(base_key, 2000))) + wisdom_bonus
	pet["生命资质"] = clampi(int(pet.get("生命资质", 1000)), 0, int(pet.get("生命资质上限", 2000)))
	pet["魔法资质"] = clampi(int(pet.get("魔法资质", 1000)), 0, int(pet.get("魔法资质上限", 2000)))
	pet["攻击资质"] = clampi(int(pet.get("攻击资质", 1000)), 0, int(pet.get("攻击资质上限", 2000)))
	pet["防御资质"] = clampi(int(pet.get("防御资质", 1000)), 0, int(pet.get("防御资质上限", 2000)))


func _recalculate_active_pet_growth_stats(pet: Dictionary) -> void:
	_ensure_pet_growth_fields_for_spawn(pet)
	var level_count: int = max(0, int(pet.get(DataKeys.LEVEL, 1)) - 1)
	var hp_gain: int = int(round(float(pet.get("生命资质", 1000)) * 0.09))
	var mp_gain: int = int(round(float(pet.get("魔法资质", 1000)) * 0.04))
	var attack_gain: int = int(round(float(pet.get("攻击资质", 1000)) * 0.02))
	var defense_gain: int = int(round(float(pet.get("防御资质", 1000)) * 0.007))
	var hp_recover_gain: int = int(round(float(pet.get("生命资质", 1000)) * 0.001))
	var mp_recover_gain: int = int(round(float(pet.get("魔法资质", 1000)) * 0.001))
	var new_hp_max: int = 620 + level_count * hp_gain
	var new_mp_max: int = 180 + level_count * mp_gain
	pet["生命上限"] = new_hp_max
	pet["魔法上限"] = new_mp_max
	pet[DataKeys.ATTACK] = 65 + level_count * attack_gain
	pet[DataKeys.DEFENSE] = 60 + level_count * defense_gain
	pet["物防"] = int(pet.get(DataKeys.DEFENSE, 0))
	pet["防"] = int(pet.get(DataKeys.DEFENSE, 0))
	pet["魔抗"] = int(pet.get(DataKeys.DEFENSE, 0))
	pet["魔防"] = int(pet.get(DataKeys.DEFENSE, 0))
	pet["回血"] = 2 + level_count * hp_recover_gain
	pet["回魔"] = 1 + level_count * mp_recover_gain
	pet[DataKeys.HP] = (
		new_hp_max
		if int(pet.get(DataKeys.HP, new_hp_max)) <= 0
		else clampi(int(pet.get(DataKeys.HP, new_hp_max)), 0, new_hp_max)
	)
	pet[DataKeys.MP] = (
		new_mp_max
		if int(pet.get(DataKeys.MP, new_mp_max)) <= 0
		else clampi(int(pet.get(DataKeys.MP, new_mp_max)), 0, new_mp_max)
	)


func _restore_active_pet_for_level_start(pet: Dictionary) -> void:
	var hp_max: int = max(1, int(pet.get("生命上限", 1)))
	var mp_max: int = max(1, int(pet.get("魔法上限", 1)))
	pet[DataKeys.HP] = hp_max
	pet[DataKeys.MP] = mp_max


func _update_pet_tiger_evolution(pet: Dictionary) -> void:
	var PlayerData: Node = LocalCoop.pet_profile_for(pet)
	if not _is_pet_tiger_data(pet):
		return
	_normalize_pet_tiger_spawn_data(pet)
	var stage := _pet_tiger_stage_for_level(int(pet.get(DataKeys.LEVEL, 1)))
	pet["阶段"] = stage
	var stage_name := _pet_tiger_stage_name(stage)
	pet[DataKeys.ALT_NAME] = stage_name
	pet[DataKeys.TYPE] = "PetTiger"
	var stage_skills := _pet_tiger_stage_skills(stage)
	pet["技能"] = stage_skills
	if _pet_is_fighting(pet):
		PlayerData.player_data[_active_pet_name_key()] = "PetTiger"
		PlayerData.player_data["出战宠物"] = "PetTiger"


func _pet_tiger_scene_path(stage: int) -> String:
	return "res://Scene/pet/pet_tiger_summon_%d.tscn" % clampi(stage, 1, 4)


func _active_pet_stage_from_data(pet: Dictionary) -> int:
	if _is_pet_mouse_data(pet):
		return _pet_mouse_stage_for_level(int(pet.get(DataKeys.LEVEL, 1)))
	var stage := int(pet.get("阶段", pet.get("pet_stage", 0)))
	if stage <= 0:
		var pet_level := int(pet.get(DataKeys.LEVEL, 1))
		stage = 4 if pet_level >= 50 else 3 if pet_level >= 30 else 2 if pet_level >= 15 else 1
	return clampi(stage, 1, 4)


func _is_pet_phoenix_data(pet: Dictionary) -> bool:
	if str(pet.get(DataKeys.TYPE, "")) == "PetPhoenix":
		return true
	var pet_name := str(pet.get(DataKeys.ALT_NAME, ""))
	var pet_title := str(pet.get(DataKeys.NAME, ""))
	return _is_pet_phoenix_name(pet_name) or _is_pet_phoenix_name(pet_title)


func _is_pet_phoenix_name(pet_name: String) -> bool:
	var clean_name := pet_name.strip_edges()
	return clean_name.begins_with("朱雀") or clean_name in ["雀蛋", "炎皇雀", "朱雀将军", "朱雀女皇", "朱雀幼灵", "赤羽朱雀", "朱雀神君"]


func _normalize_pet_phoenix_spawn_data(pet: Dictionary) -> void:
	var PlayerData: Node = LocalCoop.pet_profile_for(pet)
	var keep_fighting := (
		bool(pet.get(DataKeys.DEPLOYED, false))
		or str(PlayerData.player_data.get(_active_pet_name_key(), "")) == "PetPhoenix"
	)
	var stage := clampi(int(pet.get("阶段", 1)), 1, 4)
	pet[DataKeys.TYPE] = "PetPhoenix"
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = _pet_phoenix_stage_name(stage)
	pet[DataKeys.NAME] = _pet_phoenix_stage_name(stage)
	pet["技能"] = _pet_phoenix_stage_skills(stage)
	pet[DataKeys.DEPLOYED] = keep_fighting


func _pet_phoenix_stage_for_level(level: int) -> int:
	if level >= 50:
		return 4
	if level >= 30:
		return 3
	if level >= 15:
		return 2
	return 1


func _pet_phoenix_stage_name(stage: int) -> String:
	match clampi(stage, 1, 4):
		1:
			return "雀蛋"
		2:
			return "炎皇雀"
		3:
			return "朱雀将军"
		_:
			return "朱雀女皇"


func _pet_phoenix_stage_skills(stage: int) -> Array:
	match clampi(stage, 1, 4):
		1:
			return ["涅槃"]
		2:
			return ["涅槃", "不死火鸟"]
		3:
			return ["涅槃", "不死火鸟", "地火燎原"]
		_:
			return ["涅槃", "不死火鸟", "地火燎原", "朱雀奥义"]


func _update_pet_phoenix_evolution(pet: Dictionary) -> void:
	var PlayerData: Node = LocalCoop.pet_profile_for(pet)
	if not _is_pet_phoenix_data(pet):
		return
	var level := int(pet.get(DataKeys.LEVEL, 1))
	var stage := _pet_phoenix_stage_for_level(level)
	pet[DataKeys.TYPE] = "PetPhoenix"
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = _pet_phoenix_stage_name(stage)
	pet[DataKeys.NAME] = _pet_phoenix_stage_name(stage)
	pet["技能"] = _pet_phoenix_stage_skills(stage)
	if _pet_is_fighting(pet):
		PlayerData.player_data[_active_pet_name_key()] = "PetPhoenix"
		PlayerData.player_data["出战宠物"] = "PetPhoenix"


func _pet_phoenix_scene_path(stage: int) -> String:
	return "res://Scene/pet/pet_phoenix_summon_%d.tscn" % clampi(stage, 1, 4)


func _active_pet_spawn_position(pet: Node, source_player: BaseHero = null) -> Vector2:
	var role: BaseHero = source_player if is_instance_valid(source_player) else _role
	var role_anchor: Vector2 = role.global_position
	var role_pz: Node = role.get_node_or_null("pz") if role != null and role.has_method("get_node_or_null") else null
	if role_pz is CollisionShape2D:
		role_anchor = _collision_shape_bottom_anchor(role_pz)
	elif role_pz is Node2D:
		role_anchor = role_pz.global_position
	var pet_anchor_offset: Vector2 = Vector2.ZERO
	if pet != null and pet.has_method("get_node_or_null"):
		var pet_pz: Node = pet.get_node_or_null("pz")
		if pet_pz is CollisionShape2D and pet is Node2D:
			pet_anchor_offset = _collision_shape_bottom_local_offset(pet_pz)
		elif pet_pz is Node2D and pet is Node2D:
			pet_anchor_offset = pet_pz.position
	return role_anchor - pet_anchor_offset


func _collision_shape_bottom_anchor(shape_node: CollisionShape2D) -> Vector2:
	return shape_node.to_global(_collision_shape_bottom_local_offset(shape_node))


func _collision_shape_bottom_local_offset(shape_node: CollisionShape2D) -> Vector2:
	var bottom_offset: float = 0.0
	if shape_node.shape is CapsuleShape2D:
		bottom_offset = (shape_node.shape as CapsuleShape2D).height * 0.5
	elif shape_node.shape is RectangleShape2D:
		bottom_offset = (shape_node.shape as RectangleShape2D).size.y * 0.5
	elif shape_node.shape is CircleShape2D:
		bottom_offset = (shape_node.shape as CircleShape2D).radius
	return shape_node.position + Vector2(0.0, bottom_offset)


func _place_active_pet_near_role(pet: Node, spawn_position: Vector2) -> void:
	if pet == null or not is_instance_valid(pet):
		return
	if pet is Node2D:
		pet.global_position = spawn_position
	if pet is CharacterBody2D:
		pet.velocity = Vector2.ZERO


func _active_pet_list_key() -> String:
	return str(PlayerData.PET_LIST_KEY) if "PET_LIST_KEY" in PlayerData else "宠物列表"


func _active_pet_name_key() -> String:
	return str(PlayerData.ACTIVE_PET_KEY) if "ACTIVE_PET_KEY" in PlayerData else "出战宠物"


func _pet_active_name(pet: Dictionary) -> String:
	var type_name := str(pet.get(DataKeys.TYPE, ""))
	if type_name == "PetNeat" or _is_pet_neat_data(pet):
		return "PetNeat"
	if type_name == "PetYinTiger" or _is_pet_yin_tiger_data(pet):
		return "PetYinTiger"
	if type_name == "PetMouse" or _is_pet_mouse_data(pet):
		return "PetMouse"
	if type_name == "PetRabbit" or _is_pet_rabbit_data(pet):
		return "PetRabbit"
	if type_name == "PetTurtle" or _is_pet_turtle_data(pet):
		return "PetTurtle"
	if _is_pet_phoenix_data(pet):
		return "PetPhoenix"
	if type_name == "PetTiger" or _is_pet_tiger_data(pet):
		return "PetTiger"
	if type_name == "PetDragon" or _is_pet_dragon_data(pet):
		return "PetDragon"
	return str(pet.get(DataKeys.ALT_NAME, ""))


func _pet_is_fighting(pet: Dictionary) -> bool:
	return bool(pet.get(DataKeys.DEPLOYED, false))


func _set_only_active_pet(pets: Array, target_pet: Dictionary, data: Dictionary, active_name: String) -> void:
	for item in pets:
		if item is Dictionary:
			item[DataKeys.DEPLOYED] = false
	target_pet[DataKeys.DEPLOYED] = true
	data[_active_pet_name_key()] = active_name
	data["出战宠物"] = active_name


func _canonicalize_active_pet_data(data: Dictionary, pets: Array, active_name: String) -> String:
	var mouse_pet: Dictionary = {}
	var turtle_pet: Dictionary = {}
	var rabbit_pet: Dictionary = {}
	var phoenix_pet: Dictionary = {}
	var dragon_pet: Dictionary = {}
	var tiger_pet: Dictionary = {}
	var neat_pet: Dictionary = {}
	var yin_tiger_pet: Dictionary = {}
	var mouse_is_fighting := false
	var turtle_is_fighting := false
	var rabbit_is_fighting := false
	var phoenix_is_fighting := false
	var dragon_is_fighting := false
	var tiger_is_fighting := false
	var neat_is_fighting := false
	var yin_tiger_is_fighting := false
	for pet in pets:
		if not (pet is Dictionary):
			continue
		if _is_pet_mouse_data(pet):
			mouse_pet = pet
			mouse_is_fighting = mouse_is_fighting or _pet_is_fighting(pet)
		elif _is_pet_neat_data(pet):
			neat_pet = pet
			neat_is_fighting = neat_is_fighting or _pet_is_fighting(pet)
		elif _is_pet_yin_tiger_data(pet):
			yin_tiger_pet = pet
			yin_tiger_is_fighting = yin_tiger_is_fighting or _pet_is_fighting(pet)
		elif _is_pet_rabbit_data(pet):
			rabbit_pet = pet
			rabbit_is_fighting = rabbit_is_fighting or _pet_is_fighting(pet)
		elif _is_pet_turtle_data(pet):
			turtle_pet = pet
			turtle_is_fighting = turtle_is_fighting or _pet_is_fighting(pet)
		elif _is_pet_phoenix_data(pet):
			phoenix_pet = pet
			phoenix_is_fighting = phoenix_is_fighting or _pet_is_fighting(pet)
		elif _is_pet_dragon_data(pet):
			dragon_pet = pet
			dragon_is_fighting = dragon_is_fighting or _pet_is_fighting(pet)
		elif _is_pet_tiger_data(pet):
			tiger_pet = pet
			tiger_is_fighting = tiger_is_fighting or _pet_is_fighting(pet)
	if (
		(active_name == "PetMouse" or _is_pet_mouse_data({"名称": active_name}) or mouse_is_fighting)
		and not mouse_pet.is_empty()
	):
		_normalize_pet_mouse_spawn_data(mouse_pet)
		_set_only_active_pet(pets, mouse_pet, data, "PetMouse")
		return "PetMouse"
	if (
		(active_name == "PetNeat" or _is_pet_neat_data({"名称": active_name}) or neat_is_fighting)
		and not neat_pet.is_empty()
	):
		_normalize_pet_neat_spawn_data(neat_pet)
		_set_only_active_pet(pets, neat_pet, data, "PetNeat")
		return "PetNeat"
	if (
		(active_name == "PetYinTiger" or _is_pet_yin_tiger_data({"名称": active_name}) or yin_tiger_is_fighting)
		and not yin_tiger_pet.is_empty()
	):
		_normalize_pet_yin_tiger_spawn_data(yin_tiger_pet)
		_set_only_active_pet(pets, yin_tiger_pet, data, "PetYinTiger")
		return "PetYinTiger"
	if (
		(active_name == "PetRabbit" or _is_pet_rabbit_data({"名称": active_name}) or rabbit_is_fighting)
		and not rabbit_pet.is_empty()
	):
		_normalize_pet_rabbit_spawn_data(rabbit_pet)
		_set_only_active_pet(pets, rabbit_pet, data, "PetRabbit")
		return "PetRabbit"
	if (
		(active_name == "PetTurtle" or _is_pet_turtle_data({"名称": active_name}) or turtle_is_fighting)
		and not turtle_pet.is_empty()
	):
		_normalize_pet_turtle_spawn_data(turtle_pet)
		_set_only_active_pet(pets, turtle_pet, data, "PetTurtle")
		return "PetTurtle"
	if (
		(active_name == "PetPhoenix" or _is_pet_phoenix_name(active_name) or phoenix_is_fighting)
		and not phoenix_pet.is_empty()
	):
		_normalize_pet_phoenix_spawn_data(phoenix_pet)
		_set_only_active_pet(pets, phoenix_pet, data, "PetPhoenix")
		return "PetPhoenix"
	if (
		(active_name == "PetDragon" or _is_pet_dragon_data({"名称": active_name}) or dragon_is_fighting)
		and not dragon_pet.is_empty()
	):
		_normalize_pet_dragon_spawn_data(dragon_pet)
		_set_only_active_pet(pets, dragon_pet, data, "PetDragon")
		return "PetDragon"
	if (
		(active_name == "PetTiger" or _is_pet_tiger_data({"名称": active_name}) or tiger_is_fighting)
		and not tiger_pet.is_empty()
	):
		_normalize_pet_tiger_spawn_data(tiger_pet)
		_set_only_active_pet(pets, tiger_pet, data, "PetTiger")
		return "PetTiger"
	return active_name


func _is_pet_tiger_data(pet: Dictionary) -> bool:
	if str(pet.get(DataKeys.TYPE, "")) == "PetTiger":
		return true
	var name := str(pet.get(DataKeys.ALT_NAME, ""))
	return name == "虎丸" or name == "白灵虎" or name == "白虎将军" or name == "白虎战神" or name == "白虎"


func _get_active_pet_data(profile: Node = null) -> Dictionary:
	var PlayerData: Node = profile if profile != null else get_node("/root/PlayerData")
	if PlayerData.has_method("ensure_pet_tiger"):
		PlayerData.ensure_pet_tiger()
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
	if PlayerData.has_method("ensure_pet_yin_tiger"):
		PlayerData.ensure_pet_yin_tiger()
	var data: Dictionary = PlayerData.player_data
	var active_key := _active_pet_name_key()
	var active_name := str(data.get(active_key, data.get("出战宠物", "")))
	var pets: Variant = data.get(_active_pet_list_key(), data.get("宠物列表", []))
	if not (pets is Array):
		return {}
	active_name = _canonicalize_active_pet_data(data, pets, active_name)
	if active_name == "PetPhoenix":
		for pet in pets:
			if not (pet is Dictionary):
				continue
			if _is_pet_phoenix_data(pet):
				for item in pets:
					if item is Dictionary:
						item[DataKeys.DEPLOYED] = false
				pet[DataKeys.DEPLOYED] = true
				_normalize_pet_phoenix_spawn_data(pet)
				data[active_key] = "PetPhoenix"
				data["出战宠物"] = "PetPhoenix"
				return pet
	var first_active_pet: Dictionary = {}
	for pet in pets:
		if not (pet is Dictionary):
			continue
		var pet_name := _pet_active_name(pet)
		var matches_active_name := (
			active_name != "" and (pet_name == active_name or str(pet.get(DataKeys.ALT_NAME, "")) == active_name)
		)
		if not _pet_is_fighting(pet) and not matches_active_name:
			continue
		pet[DataKeys.DEPLOYED] = true
		if first_active_pet.is_empty():
			first_active_pet = pet
		if active_name == "" or pet_name == active_name or str(pet.get(DataKeys.ALT_NAME, "")) == active_name:
			return pet
	return first_active_pet


func _physics_process(_delta: float) -> void:
	if DisplayServer.get_name() != "headless" and my_camera != null and _green_detector != null:
		var cam = get_viewport().get_camera_2d()
		if cam:
			_green_detector.global_position = cam.get_screen_center_position()
	change_mysee()
	var exit_ready := false
	if current_stage >= 1:
		if not is_two_scene:
			if (
				monster_group["stage_2"].size() == 0
				and monster_group["stage_3"].size() == 0
				and monster_group["stage_4"].size() == 0
			):
				if one_check_can_exit():
					Global.preload_next("res://Scene/level/victory.tscn")
					exit.visible = true
					exit_2.disabled = false
					exit_ready = true
			else:
				if check_can_exit():
					Global.preload_next("res://Scene/level/victory.tscn")
					exit.visible = true
					exit_2.disabled = false
					exit_ready = true
		else:
			if (
				monster_group["stage_2"].size() == 0
				and monster_group["stage_3"].size() == 0
				and monster_group["stage_4"].size() == 0
			):
				if one_check_can_exit():
					Global.preload_next("res://Scene/level/victory.tscn")
					exit.visible = true
					exit_2.disabled = false
					exit_ready = true

	if (
		can_exit
		and (
			Input.is_action_just_pressed("Exit") or (LocalCoop.is_enabled() and Input.is_action_just_pressed("p2_Exit"))
		)
	):
		_leave_level_from_exit()
	elif _is_auto_battle_enabled() and exit_ready:
		_leave_level_from_exit()
	if _role == null:
		if my_camera != null:
			my_camera.queue_free()
	set_through()


func _is_auto_battle_enabled() -> bool:
	return MainSet.is_auto_battle_enabled()


func _leave_level_from_exit() -> void:
	if _auto_exit_settling:
		return
	_auto_exit_settling = true
	if _is_auto_battle_enabled():
		await get_tree().create_timer(1.0).timeout
	if not is_inside_tree():
		return
	if self is Level19:
		if self.canthro:
			add_tg(level_stage)
	else:
		add_tg(level_stage)
	if self is Level17:
		Global.change_scene("res://Scene/level/level_sdwfb.tscn")
		return
	if self is Level22:
		Global.change_scene("res://Scene/level/level_xtqfb.tscn")
		return
	if self is Level10 or self is Level21:
		if _restart_level_for_auto_battle():
			return
		if MainSet.set_data["剧情跳过"]:
			Global.change_scene("res://Scene/level/victory.tscn")
		else:
			Global.change_scene("res://Scene/main_menu/game_over_1.tscn")
	elif self is Level19:
		if self.canthro:
			if not _restart_level_for_auto_battle():
				Global.change_scene("res://Scene/level/victory.tscn")
		else:
			RoleProp.current_hp = RoleProp.roleprop.Hp
			RoleProp.current_mp = RoleProp.roleprop.Mp
			Global.change_scene("res://Scene/level/level_20.tscn")
	elif self is Level20:
		RoleProp.current_hp = RoleProp.roleprop.Hp
		RoleProp.current_mp = RoleProp.roleprop.Mp
		Global.change_scene("res://Scene/level/level_20.tscn")
	else:
		if not _restart_level_for_auto_battle():
			Global.change_scene("res://Scene/level/victory.tscn")


func _restart_level_for_auto_battle() -> bool:
	if not MainSet.is_auto_battle_enabled():
		return false
	if not bool(MainSet.set_data.get("AutoBattleRetry", false)):
		return false
	if Global.last_level_path == "":
		return false
	var archive_path := str(Global.cd_path).strip_edges()
	if archive_path == "":
		push_warning("自动重战保存失败：当前存档路径为空")
	elif not MemoryClass.save_game(archive_path):
		push_warning("自动重战保存失败：%s" % archive_path)
	RoleProp.set_full_hp()
	RoleProp.set_full_mp()
	RoleProp.current_hp = int(RoleProp.roleprop.Hp)
	RoleProp.current_mp = int(RoleProp.roleprop.Mp)
	RoleProp.ws_value = 0
	RoleProp.is_ws_state = false
	Global.is_dead_link = false
	Global.remove_all_buff()
	Global.change_scene(Global.last_level_path)
	return true


func _align_monster_spawn_tables() -> void:
	for stage_key in ["stage_1", "stage_2", "stage_3", "stage_4"]:
		if not monster_group.has(stage_key):
			monster_group[stage_key] = []
		if not monster_position_x.has(stage_key):
			monster_position_x[stage_key] = []
		if not monster_position_y.has(stage_key):
			monster_position_y[stage_key] = []
		var ids: Array = monster_group[stage_key]
		var pos_x: Array = monster_position_x[stage_key]
		var pos_y: Array = monster_position_y[stage_key]
		var keep := mini(ids.size(), mini(pos_x.size(), pos_y.size()))
		if keep < ids.size() or keep < pos_x.size() or keep < pos_y.size():
			print(
				"关卡刷怪表长度不一致，已对齐: %s ids=%d x=%d y=%d -> %d" % [stage_key, ids.size(), pos_x.size(), pos_y.size(), keep]
			)
		if keep < ids.size():
			monster_group[stage_key] = ids.slice(0, keep)
		if keep < pos_x.size():
			monster_position_x[stage_key] = pos_x.slice(0, keep)
		if keep < pos_y.size():
			monster_position_y[stage_key] = pos_y.slice(0, keep)


func _apply_monster_count_multiplier():
	_align_monster_spawn_tables()
	var count = clamp(int(MainSet.set_data.get("CreateMonsterCount", 1)), 1, 5)
	MainSet.set_data["CreateMonsterCount"] = count
	if count <= 1:
		return
	for stage_key in ["stage_1", "stage_2", "stage_3", "stage_4"]:
		if not monster_group.has(stage_key):
			continue
		var orig_ids = monster_group[stage_key].duplicate()
		var new_ids = []
		for ci in range(count):
			new_ids.append_array(orig_ids)
		monster_group[stage_key] = new_ids

		if monster_position_x.has(stage_key):
			var orig_x = monster_position_x[stage_key].duplicate()
			var new_x = []
			for ci in range(count):
				new_x.append_array(orig_x)
			monster_position_x[stage_key] = new_x

		if monster_position_y.has(stage_key):
			var orig_y = monster_position_y[stage_key].duplicate()
			var new_y = []
			for ci in range(count):
				new_y.append_array(orig_y)
			monster_position_y[stage_key] = new_y
	_align_monster_spawn_tables()


func _preload_level_resources() -> void:
	var level_monster_ids: Array = []
	for stage_key in ["stage_1", "stage_2", "stage_3", "stage_4"]:
		if monster_group.has(stage_key) and monster_group[stage_key] is Array:
			level_monster_ids.append_array(monster_group[stage_key])
	_stage_preload_requested[1] = true
	await Global.preload_level_monster_runtime_resources(level_monster_ids)


func _prepare_level_runtime_resources() -> void:
	_apply_monster_count_multiplier()
	await _preload_level_resources()
	if not is_inside_tree():
		return
	_request_stage_resource_preload(2)
	if create_control != null and is_instance_valid(create_control):
		create_control.start()


func _request_stage_resource_preload(stage: int) -> void:
	if stage < 1 or stage > 4 or _stage_preload_requested.has(stage):
		return
	_stage_preload_requested[stage] = true
	var stage_ids: Variant = monster_group.get("stage_%d" % stage, [])
	if not stage_ids is Array or stage_ids.is_empty():
		return
	call_deferred("_preload_stage_resources", stage_ids.duplicate())


func _preload_stage_resources(monster_ids: Array) -> void:
	await Global.preload_level_monster_runtime_resources(monster_ids)


func set_through():
	pass


func level_create_monster(stage):
	if stage < 1 or stage > 4:
		return

	var stage_key = "stage_" + str(stage)
	if (
		not monster_group.has(stage_key)
		or not monster_position_x.has(stage_key)
		or not monster_position_y.has(stage_key)
	):
		return
	if monster_group[stage_key].size() == 0:
		return
	if monster_position_x[stage_key].size() == 0 or monster_position_y[stage_key].size() == 0:
		push_error("关卡刷怪坐标表为空: %s" % stage_key)
		monster_group[stage_key].clear()
		return

	var mr_xh = monster_group[stage_key][0]
	var mr_loc_x = monster_position_x[stage_key][0]
	var mr_loc_y = monster_position_y[stage_key][0]
	monster_group[stage_key].remove_at(0)
	monster_position_x[stage_key].remove_at(0)
	monster_position_y[stage_key].remove_at(0)
	if mr_num <= monster_group[stage_key].size():
		mr = Global.create_monster(mr_xh, monster, Vector2(mr_loc_x, mr_loc_y))
		can_create = false


func change_mysee():
	if my_camera != null:
		if self is Level22:
			my_camera.max_right = 937
			return
		if current_stage >= 1:
			if self is Level17:
				if current_stage == 1:
					my_camera.max_right = 2250
				if current_stage == 2:
					my_camera.max_right = 3550
				if current_stage == 3:
					my_camera.max_right = 4650
			elif check_can_pass():
				if not is_two_scene:
					if current_stage == 1:
						my_camera.max_right = 2250
					if current_stage == 2:
						my_camera.max_right = 3550
					if current_stage == 3:
						my_camera.max_right = 4650
				else:
					if current_stage == 1:
						my_camera.max_right = 1870
					if current_stage == 2:
						pass


func check_monster_death():
	if monster_array != []:
		for i in monster_array:
			if i != null:
				if i is BaseMonster:
					if i.death():
						monster_array.erase(i)
				else:
					monster_array.erase(i)

			else:
				monster_array.erase(i)


func _is_stage_monster_node(node: Node) -> bool:
	if node == null or node.is_queued_for_deletion():
		return false
	if not node is BaseMonster:
		return false
	if (
		bool(node.get_meta("pet_tiger_unit", false))
		or bool(node.get_meta("pet_yin_tiger_unit", false))
		or bool(node.get_meta("pet_dragon_unit", false))
		or bool(node.get_meta("is_summon", false))
		or bool(node.get_meta("three_prince_clone", false))
	):
		return false
	if node.is_boss and node.death() and not bool(node.get_meta("death_drops_settled", false)):
		return true
	if bool(node.get_meta("counts_as_alive_for_stage_clear", false)):
		return true
	if node.has_method("is_alive_for_stage_clear") and bool(node.call("is_alive_for_stage_clear")):
		return true
	return not node.death()


func _get_alive_stage_monster_count() -> int:
	if monster == null:
		return 0
	var count := 0
	if _active_monster_index_ready:
		for node in _active_monsters.values():
			if (
				node != null
				and is_instance_valid(node)
				and node.get_parent() == monster
				and _is_stage_monster_node(node)
			):
				count += 1
		return count
	for child in monster.get_children():
		if _is_stage_monster_node(child):
			count += 1
	return count


func check_can_create(stage):
	if stage < 1 or stage > 4:
		return false

	var stage_key = "stage_" + str(stage)

	if not monster_group.has(stage_key):
		return false

	var count = clamp(int(MainSet.set_data.get("CreateMonsterCount", 1)), 1, 5)
	return _get_alive_stage_monster_count() < 6 * count and monster_group[stage_key].size() > 0


func _on_create_control_timeout() -> void:
	if _role != null:
		if not is_two_scene:
			if _role.position.x < 1600 and current_stage == 0:
				current_stage = 1
			if _role.position.x >= 1600 and _role.position.x < 2700 and current_stage == 1:
				current_stage = 2
			if _role.position.x >= 2700 and _role.position.x < 4000 and current_stage == 2:
				current_stage = 3
			if _role.position.x >= 4000 and current_stage == 3:
				current_stage = 4
		else:
			if _role.position.x < 1000 and current_stage == 0:
				current_stage = 1
			if _role.position.x >= 1300 and _role.position.x < 2700 and current_stage == 1:
				current_stage = 2
			if _role.position.x >= 2700 and _role.position.x < 4000 and current_stage == 2:
				current_stage = 3
			if _role.position.x >= 4000 and current_stage == 3:
				current_stage = 4

	if current_stage >= 1 and current_stage <= 4:
		_request_stage_resource_preload(current_stage + 1)
		if check_can_create(current_stage):
			level_create_monster(current_stage)


func check_can_pass():
	if current_stage < 1 or current_stage > 4:
		return false

	var stage_key = "stage_" + str(current_stage)

	if not monster_group.has(stage_key):
		return false

	return monster_group[stage_key].size() == 0 and _get_alive_stage_monster_count() == 0


func check_can_exit():
	var stage_count := _stage_count()
	if current_stage < 1 or current_stage > stage_count:
		return false

	var stage_key = "stage_" + str(current_stage)

	if not monster_group.has(stage_key):
		return false

	return (
		monster_group[stage_key].size() == 0 and current_stage == stage_count and _get_alive_stage_monster_count() == 0
	)


func one_check_can_exit():
	var stage_count := _stage_count()
	if current_stage < 1 or current_stage > stage_count:
		return false

	var stage_key = "stage_" + str(current_stage)

	if not monster_group.has(stage_key):
		return false

	return (
		monster_group[stage_key].size() == 0 and current_stage == stage_count and _get_alive_stage_monster_count() == 0
	)


func always_can_pass():
	return true


func _on_exit_2_body_entered(body: Node2D) -> void:
	if body is BaseHero:
		_exit_players[body.get_instance_id()] = true
		can_exit = true


func _on_exit_2_body_exited(body: Node2D) -> void:
	if body is BaseHero:
		_exit_players.erase(body.get_instance_id())
		can_exit = not _exit_players.is_empty()


func _on_timer_timeout() -> void:
	if role_information != null:
		_decay_ws_value(RoleProp)
	if LocalCoop.is_enabled():
		_decay_ws_value(LocalCoop.secondary_props)


func _decay_ws_value(props: BaseRoleProperties) -> void:
	if not is_instance_valid(props):
		return
	if not props.is_ws_state and props.ws_value < props.max_ws_value:
		props.ws_value -= 0.2
	if props.is_ws_state:
		props.ws_value -= 4


func add_tg(level):
	if self is Game4ImportedLevel and int(level) >= 63 and int(level) <= 75:
		PlayerData.player_data["东胜神州通关_%d" % int(level)] = 1
		if int(level) == 75:
			PlayerData.player_data["云川"] = 1
		return

	var progression_level_name := str(Global.current_level)
	if (
		progression_level_name
		in [
			"绝仙门",
			"紫晶门",
			"戮仙门",
			"指景宫",
			"陷仙门",
			"绝境宫",
			"通天教主",
			"玄武门",
			"朱雀街",
			"未央宫",
			"九华山麓",
			"双溪寺",
			"神光金岭",
			"普陀山脚",
			"九龙宝殿",
			"法华灵洞",
			"峨眉山道",
			"清音阁",
			"金顶云海",
			"五台山口",
			"锦绣峰",
			"万佛朝阁",
			"冥海",
		]
	):
		PlayerData.player_data[progression_level_name] = 1
		return
	match level:
		1:
			PlayerData.player_data.水帘洞 = 1
		2:
			PlayerData.player_data.桃花源 = 1
		3:
			PlayerData.player_data.蝙蝠窟 = 1
		4:
			PlayerData.player_data.七星洞 = 1
		5:
			PlayerData.player_data.迦楼罗之穴 = 1
		6:
			PlayerData.player_data.浅岸 = 1
		7:
			PlayerData.player_data.东海 = 1
		8:
			PlayerData.player_data.鲨之涡流 = 1
		9:
			PlayerData.player_data.牛魔谷 = 1
		10:
			PlayerData.player_data["地府"] = true
		11:
			PlayerData.player_data.无常巷 = 1
		12:
			PlayerData.player_data.鬼门关 = 1
		13:
			PlayerData.player_data.接引院 = 1
		14:
			PlayerData.player_data.判官府 = 1
		15:
			PlayerData.player_data.阎罗殿 = 1
		16:
			PlayerData.player_data.忘川河 = 1
		17:
			PlayerData.player_data.奈何桥 = 1
		18:
			PlayerData.player_data.望乡台 = 1
		19:
			PlayerData.player_data.转轮殿 = 1
		20:
			PlayerData.player_data["天庭"] = true
			if int(MainSet.set_data.get("Difficult", 0)) == BaseMonster.NIGHTMARE_DIFFICULTY:
				PlayerData.player_data["地府噩梦"] = true
		21:
			PlayerData.player_data.天宫道 = 1
		22:
			PlayerData.player_data.南天门 = 1
		23:
			PlayerData.player_data.南天王殿 = 1
		24:
			PlayerData.player_data.西天王殿 = 1
		25:
			PlayerData.player_data.北天王殿 = 1
		26:
			PlayerData.player_data.彩虹楼 = 1
		27:
			PlayerData.player_data.朝会殿 = 1
		28:
			PlayerData.player_data.凌霄宝殿 = 1
		29:
			PlayerData.player_data.玲珑宝塔 = 1
		30:
			PlayerData.player_data.兜率宫 = 1
		31:
			PlayerData.player_data.兜率宫1 = 1
		32:
			PlayerData.player_data.兜率宫2 = 1
		33:
			PlayerData.player_data.兜率宫3 = 1
		34:
			PlayerData.player_data.兜率宫4 = 1
		35:
			PlayerData.player_data["截教天镜"] = true

		36:
			PlayerData.player_data.火龙岛 = 1
		37:
			PlayerData.player_data.九龙岛 = 1
		38:
			PlayerData.player_data.龙脊山 = 1
		39:
			PlayerData.player_data.尾妖林 = 1
		40:
			PlayerData.player_data.仙音岛 = 1
		41:
			PlayerData.player_data.仙幻岛 = 1
		42:
			PlayerData.player_data.仙树岛 = 1
		43:
			PlayerData.player_data.蓬莱岛 = 1
		44:
			PlayerData.player_data.蓬莱仙境 = 1
		45:
			PlayerData.player_data["碧游宫"] = true
		46:
			PlayerData.player_data["陷仙门"] = 1
		47:
			PlayerData.player_data["绝境宫"] = 1
		48:
			PlayerData.player_data["通天教主"] = 1


func _shake_screen(strength: float, times: int, inte: float):
	if my_camera != null:
		my_camera.shake(strength, times, inte)


func remove_all_records():
	Global.level_begin_time = ""
	Global.most_lianji = 0
	Global.last_prop_hp = 0
	Global.total_role_hurt = 0
	Global.total_cure_hp = 0
	Global.total_phy_hit = 0
	Global.total_mag_hit = 0
	Global.total_real_hit = 0
	Global.total_phy_hurt = 0
	Global.total_mag_hurt = 0
	Global.total_real_hurt = 0
	Global.total_hurt_count = 0
	Global.total_hit_count = 0
	Global.total_role_hit = 0
	Global.total_crit_count = 0
	Global.total_miss_count = 0


## ---------------------------------------------------------------------------
## 关卡阶段契约（Phase 10.5 / Phase 11 夹具与 CI 统一入口）
## 子类可覆盖；默认实现基于 BaseLevel 的 4 阶段状态机与 change_mysee 相机边界。
## ---------------------------------------------------------------------------
func _stage_count() -> int:
	var populated := 0
	for stage_index in range(1, 5):
		var stage_key := "stage_%d" % stage_index
		var stage_list: Variant = monster_group.get(stage_key, [])
		if stage_list is Array and not (stage_list as Array).is_empty():
			populated += 1
	return maxi(populated, 1)


func _stage_trigger_x() -> Array:
	var triggers: Array = [0.0]
	if is_two_scene:
		triggers.append_array([1300.0, 2700.0, 4000.0])
	else:
		triggers.append_array([1600.0, 2700.0, 4000.0])
	return triggers.slice(0, _stage_count())


func _screen_starts() -> Array:
	var starts: Array = [0.0, 2250.0, 3550.0, 4650.0]
	return starts.slice(0, _stage_count())


func _screen_rights() -> Array:
	var rights: Array = [2250.0, 3550.0, 4650.0, 4650.0]
	return rights.slice(0, _stage_count())


func _birth_points() -> Array:
	return []


func _stage_activate(_index: int) -> bool:
	# 可选契约：由关卡自身决定如何激活指定阶段（触发器/房间/剧情）。
	return false
