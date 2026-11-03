extends Node2D
class_name BaseLevel
const LEVEL_PROGRESS_COMMAND := preload("res://Script/base/level_progress_command.gd")
const PET_LEVEL_CONTROLLER := preload("res://Script/pet/pet_level_controller.gd")
const PET_TURTLE_FAMILY := preload("res://Script/pet/pet_turtle_family.gd")
const PET_TIGER_FAMILY := preload("res://Script/pet/pet_tiger_family.gd")
const PET_DRAGON_FAMILY := preload("res://Script/pet/pet_dragon_family.gd")
const PET_PHOENIX_FAMILY := preload("res://Script/pet/pet_phoenix_family.gd")
const PET_RABBIT_FAMILY := preload("res://Script/pet/pet_rabbit_family.gd")
const PET_MOUSE_FAMILY := preload("res://Script/pet/pet_mouse_family.gd")
const PET_NEAT_FAMILY := preload("res://Script/pet/pet_neat_family.gd")
const PET_LIFE_BONUS_RUNTIME := preload("res://Script/pet/pet_life_bonus_runtime.gd")
const PET_SKILL_PROGRESSION := preload("res://Script/pet/pet_skill_progression.gd")
var is_two_scene
var _pet_level_controller = PET_LEVEL_CONTROLLER.new()

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
@onready var end: Parallax2D = $BackGround/End
@onready var front: Parallax2D = $BackGround/front
@onready var floor_2: Parallax2D = $BackGround/floor_2
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
## 测试注入：关卡退出保存与转场；生产路径为空。
var progress_save_override: Callable
var exit_scene_change_override: Callable
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
	_load_layout_spawn_tables()
	_initialize_active_monster_index()
	create_control.stop()
	if not self is Level20:
		RoleProp.ws_value = 0
	create_control.wait_time = float(MainSet.set_data.get("CreateMonsterSpeed", 0.3))
	Global.get_audio_runtime().remove_main_menu_music()
	if Global.get_ui_runtime().consume_first_level_intro():
		var zm_player: AnimationPlayer = $CanvasLayer/zmPLAYER
		if zm_player.has_animation("gdzm"):
			zm_player.play("gdzm")
	Global.get_run_context().set_last_level_path(str(self.scene_file_path))
	remove_all_records()
	Global.get_run_context().begin_level_timing()
	var role_id = int(PlayerData.player_data.get("Myself", 1))
	if role_id <= 0:
		role_id = 1
	_role = Global.call_hero("role_" + str(role_id), hero, _player_spawn_position(1, Vector2(100, 340)), false)
	if LocalCoop.is_enabled():
		LocalCoop.secondary_props.ws_value = 0
		role_p2 = Global.call_hero(
			"role_" + str(int(LocalCoop.secondary_data.player_data.Myself)),
			hero,
			_player_spawn_position(2, Vector2(170, 340)),
			false,
			2
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
		_green_detector.collision_layer = PhysicsLayers.EXIT

		_green_detector.add_to_group("green_detector")
		print("[调试] GreenDetector 已设置：collision_layer=%d，已加入 green_detector 组" % PhysicsLayers.EXIT)
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
	PET_NEAT_FAMILY.append_death_aliases(aliases, pet_name)
	if pet_name == "PetYinTiger" or pet_name in ["寅虎", "银角虎", "寅虎元帅", "寅虎大元帅"]:
		aliases.append("PetYinTiger")
		aliases.append("寅虎元帅")
		aliases.append("寅虎大元帅")
	PET_MOUSE_FAMILY.append_death_aliases(aliases, pet_name)
	PET_RABBIT_FAMILY.append_death_aliases(aliases, pet_name)
	if pet_name == "PetTurtle" or pet_name.begins_with("玄武") or pet_name in ["龟布", "墨玄龟", "玄武将军", "玄武大帝"]:
		aliases.append("PetTurtle")
		for name in ["龟布", "墨玄龟", "玄武将军", "玄武大帝"]:
			if not aliases.has(name):
				aliases.append(name)
	if (
		pet_name == PET_DRAGON_FAMILY.KIND
		or pet_name.begins_with("辰龙")
		or PET_DRAGON_FAMILY.STAGE_NAMES.values().has(pet_name)
	):
		aliases.append(PET_DRAGON_FAMILY.KIND)
		for name in PET_DRAGON_FAMILY.STAGE_NAMES.values():
			if not aliases.has(str(name)):
				aliases.append(str(name))
	if pet_name == "PetTiger" or pet_name in ["虎丸", "白灵虎", "白虎将军", "白虎战神", "白虎"]:
		aliases.append("PetTiger")
		for name in ["虎丸", "白灵虎", "白虎将军", "白虎战神", "白虎"]:
			if not aliases.has(name):
				aliases.append(name)
	PET_PHOENIX_FAMILY.append_death_aliases(aliases, pet_name)
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
	if await _pet_level_controller.spawn_for_slot(self, slot, PlayerData, pet_data):
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
	if (
		pet_kind == PET_TURTLE_FAMILY.KIND
		or pet_kind == PET_TIGER_FAMILY.KIND
		or pet_kind == PET_DRAGON_FAMILY.KIND
		or pet_kind == PET_PHOENIX_FAMILY.KIND
		or pet_kind == PET_RABBIT_FAMILY.KIND
		or pet_kind == PET_MOUSE_FAMILY.KIND
		or pet_kind == PET_NEAT_FAMILY.KIND
	):
		return
	if pet_kind == "PetYinTiger":
		_normalize_pet_yin_tiger_spawn_data(pet_data)
		_recalculate_active_pet_growth_stats(pet_data)
		_restore_active_pet_for_level_start(pet_data)
		_update_pet_yin_tiger_evolution(pet_data)
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
	await Global.prewarm_active_pet_runtime_resources(slot)
	var scene_path := _pet_yin_tiger_scene_path(pet_stage) if pet_kind == "PetYinTiger" else ""
	if scene_path == "":
		return
	var scene := Global.preload_scene_path(scene_path)
	if scene == null:
		return
	if not is_instance_valid(source_player) or monster == null:
		return
	var pet = scene.instantiate()
	pet.set_meta("coop_slot", slot)
	if pet_kind == "PetYinTiger":
		pet.set_meta("pet_yin_tiger_unit", true)
	else:
		pet.set_meta("pet_dragon_unit", true)
	pet.set_meta("is_summon", true)
	if pet.has_method("apply_pet_data"):
		pet.apply_pet_data(pet_data)
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


func _pet_stage_for_level(pet_level: int) -> int:
	if pet_level >= 50:
		return 4
	if pet_level >= 30:
		return 3
	if pet_level >= 15:
		return 2
	return 1


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


func _active_pet_stage_from_data(pet: Dictionary) -> int:
	var stage := int(pet.get("阶段", pet.get("pet_stage", 0)))
	if stage <= 0:
		var pet_level := int(pet.get(DataKeys.LEVEL, 1))
		stage = 4 if pet_level >= 50 else 3 if pet_level >= 30 else 2 if pet_level >= 15 else 1
	return clampi(stage, 1, 4)


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
	if PET_NEAT_FAMILY.matches(pet):
		return PET_NEAT_FAMILY.KIND
	if type_name == "PetYinTiger" or _is_pet_yin_tiger_data(pet):
		return "PetYinTiger"
	if PET_MOUSE_FAMILY.matches(pet):
		return PET_MOUSE_FAMILY.KIND
	if PET_RABBIT_FAMILY.matches(pet):
		return PET_RABBIT_FAMILY.KIND
	if type_name == PET_TURTLE_FAMILY.KIND or PET_TURTLE_FAMILY.matches(pet):
		return PET_TURTLE_FAMILY.KIND
	if PET_PHOENIX_FAMILY.matches(pet):
		return PET_PHOENIX_FAMILY.KIND
	if type_name == PET_TIGER_FAMILY.KIND or PET_TIGER_FAMILY.matches(pet):
		return PET_TIGER_FAMILY.KIND
	if type_name == PET_DRAGON_FAMILY.KIND or PET_DRAGON_FAMILY.matches(pet):
		return PET_DRAGON_FAMILY.KIND
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


func _canonicalize_active_pet_data(data: Dictionary, pets: Array, active_name: String, profile: Node) -> String:
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
		if PET_MOUSE_FAMILY.matches(pet):
			mouse_pet = pet
			mouse_is_fighting = mouse_is_fighting or _pet_is_fighting(pet)
		elif PET_NEAT_FAMILY.matches(pet):
			neat_pet = pet
			neat_is_fighting = neat_is_fighting or _pet_is_fighting(pet)
		elif _is_pet_yin_tiger_data(pet):
			yin_tiger_pet = pet
			yin_tiger_is_fighting = yin_tiger_is_fighting or _pet_is_fighting(pet)
		elif PET_RABBIT_FAMILY.matches(pet):
			rabbit_pet = pet
			rabbit_is_fighting = rabbit_is_fighting or _pet_is_fighting(pet)
		elif PET_TURTLE_FAMILY.matches(pet):
			turtle_pet = pet
			turtle_is_fighting = turtle_is_fighting or _pet_is_fighting(pet)
		elif PET_PHOENIX_FAMILY.matches(pet):
			phoenix_pet = pet
			phoenix_is_fighting = phoenix_is_fighting or _pet_is_fighting(pet)
		elif PET_DRAGON_FAMILY.matches(pet):
			dragon_pet = pet
			dragon_is_fighting = dragon_is_fighting or _pet_is_fighting(pet)
		elif PET_TIGER_FAMILY.matches(pet):
			tiger_pet = pet
			tiger_is_fighting = tiger_is_fighting or _pet_is_fighting(pet)
	if (
		(active_name == PET_MOUSE_FAMILY.KIND or PET_MOUSE_FAMILY.matches({"名称": active_name}) or mouse_is_fighting)
		and not mouse_pet.is_empty()
	):
		PET_MOUSE_FAMILY.normalize_spawn(mouse_pet, profile)
		_set_only_active_pet(pets, mouse_pet, data, PET_MOUSE_FAMILY.KIND)
		return PET_MOUSE_FAMILY.KIND
	if (
		(active_name == PET_NEAT_FAMILY.KIND or PET_NEAT_FAMILY.matches({"名称": active_name}) or neat_is_fighting)
		and not neat_pet.is_empty()
	):
		PET_NEAT_FAMILY.normalize_spawn(neat_pet, profile)
		_set_only_active_pet(pets, neat_pet, data, PET_NEAT_FAMILY.KIND)
		return PET_NEAT_FAMILY.KIND
	if (
		(active_name == "PetYinTiger" or _is_pet_yin_tiger_data({"名称": active_name}) or yin_tiger_is_fighting)
		and not yin_tiger_pet.is_empty()
	):
		_normalize_pet_yin_tiger_spawn_data(yin_tiger_pet)
		_set_only_active_pet(pets, yin_tiger_pet, data, "PetYinTiger")
		return "PetYinTiger"
	if (
		(active_name == PET_RABBIT_FAMILY.KIND or PET_RABBIT_FAMILY.matches({"名称": active_name}) or rabbit_is_fighting)
		and not rabbit_pet.is_empty()
	):
		PET_RABBIT_FAMILY.normalize_spawn(rabbit_pet, profile)
		_set_only_active_pet(pets, rabbit_pet, data, PET_RABBIT_FAMILY.KIND)
		return PET_RABBIT_FAMILY.KIND
	if (
		(active_name == PET_TURTLE_FAMILY.KIND or PET_TURTLE_FAMILY.matches({"名称": active_name}) or turtle_is_fighting)
		and not turtle_pet.is_empty()
	):
		PET_TURTLE_FAMILY.normalize_spawn(turtle_pet, profile)
		_set_only_active_pet(pets, turtle_pet, data, PET_TURTLE_FAMILY.KIND)
		return PET_TURTLE_FAMILY.KIND
	if (
		(active_name == PET_PHOENIX_FAMILY.KIND or PET_PHOENIX_FAMILY.is_name(active_name) or phoenix_is_fighting)
		and not phoenix_pet.is_empty()
	):
		PET_PHOENIX_FAMILY.normalize_spawn(phoenix_pet, profile)
		_set_only_active_pet(pets, phoenix_pet, data, PET_PHOENIX_FAMILY.KIND)
		return PET_PHOENIX_FAMILY.KIND
	if (
		(active_name == PET_DRAGON_FAMILY.KIND or PET_DRAGON_FAMILY.matches({"名称": active_name}) or dragon_is_fighting)
		and not dragon_pet.is_empty()
	):
		PET_DRAGON_FAMILY.normalize_spawn(dragon_pet, profile)
		_set_only_active_pet(pets, dragon_pet, data, PET_DRAGON_FAMILY.KIND)
		return PET_DRAGON_FAMILY.KIND
	if (
		(active_name == PET_TIGER_FAMILY.KIND or PET_TIGER_FAMILY.matches({"名称": active_name}) or tiger_is_fighting)
		and not tiger_pet.is_empty()
	):
		PET_TIGER_FAMILY.normalize_spawn(tiger_pet, profile)
		_set_only_active_pet(pets, tiger_pet, data, PET_TIGER_FAMILY.KIND)
		return PET_TIGER_FAMILY.KIND
	return active_name


## 宠物数据必须由调用方按槽位提供档案；不再回落到 /root/PlayerData（隐含 1P）。
func _get_active_pet_data(profile: Node) -> Dictionary:
	if profile == null:
		return {}
	var PlayerData: Node = profile
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
	active_name = _canonicalize_active_pet_data(data, pets, active_name, profile)
	if active_name == PET_PHOENIX_FAMILY.KIND:
		for pet in pets:
			if not (pet is Dictionary):
				continue
			if PET_PHOENIX_FAMILY.matches(pet):
				for item in pets:
					if item is Dictionary:
						item[DataKeys.DEPLOYED] = false
				pet[DataKeys.DEPLOYED] = true
				PET_PHOENIX_FAMILY.normalize_spawn(pet, PlayerData)
				data[active_key] = PET_PHOENIX_FAMILY.KIND
				data["出战宠物"] = PET_PHOENIX_FAMILY.KIND
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
		if not _commit_progress_before_transition():
			return
		_change_scene_from_exit("res://Scene/level/level_sdwfb.tscn")
		return
	if self is Level22:
		if not _commit_progress_before_transition():
			return
		_change_scene_from_exit("res://Scene/level/level_xtqfb.tscn")
		return
	if self is Level10 or self is Level21:
		if _restart_level_for_auto_battle():
			return
		if MainSet.set_data["剧情跳过"]:
			_change_scene_from_exit("res://Scene/level/victory.tscn")
		else:
			if not _commit_progress_before_transition():
				return
			_change_scene_from_exit("res://Scene/main_menu/game_over_1.tscn")
	elif self is Level19:
		if self.canthro:
			if not _restart_level_for_auto_battle():
				_change_scene_from_exit("res://Scene/level/victory.tscn")
		else:
			if not _commit_progress_before_transition():
				return
			RoleProp.current_hp = RoleProp.roleprop.Hp
			RoleProp.current_mp = RoleProp.roleprop.Mp
			_change_scene_from_exit("res://Scene/level/level_20.tscn")
	elif self is Level20:
		if not _commit_progress_before_transition():
			return
		RoleProp.current_hp = RoleProp.roleprop.Hp
		RoleProp.current_mp = RoleProp.roleprop.Mp
		_change_scene_from_exit("res://Scene/level/level_20.tscn")
	else:
		if not _restart_level_for_auto_battle():
			_change_scene_from_exit("res://Scene/level/victory.tscn")


## 非胜利转场前的唯一保存点；失败保持当前关卡并解除退出锁，允许重试。
func _commit_progress_before_transition() -> bool:
	var saved: bool
	if progress_save_override.is_valid():
		saved = bool(progress_save_override.call("level_progress_transition"))
	else:
		saved = MemoryClass.request_save("level_progress_transition", false)
	if saved:
		return true
	Global.add_message_show(get_parent(), "存档保存失败，请重试", 2.0, Vector2(470, 300))
	_auto_exit_settling = false
	return false


func _change_scene_from_exit(path: String) -> void:
	if exit_scene_change_override.is_valid():
		exit_scene_change_override.call(path)
		return
	Global.change_scene(path)


func _restart_level_for_auto_battle() -> bool:
	if not MainSet.is_auto_battle_enabled():
		return false
	if not bool(MainSet.set_data.get("AutoBattleRetry", false)):
		return false
	if Global.get_run_context().get_last_level_path() == "":
		return false
	if not MemoryClass.request_save("auto_battle_retry", false):
		Global.add_message_show(get_parent(), "存档保存失败，请重试", 2.0, Vector2(470, 300))
		return false
	RoleProp.set_full_hp()
	RoleProp.set_full_mp()
	RoleProp.current_hp = int(RoleProp.roleprop.Hp)
	RoleProp.current_mp = int(RoleProp.roleprop.Mp)
	RoleProp.ws_value = 0
	RoleProp.is_ws_state = false
	Global.remove_all_buff()
	Global.change_scene(Global.get_run_context().get_last_level_path())
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


func advance_stage(next_stage: int) -> bool:
	# 阶段只允许单调前进；所有调用方共用同一入口，避免跳阶段或回退。
	var stage_limit := maxi(4, _stage_count())
	if next_stage < 1 or next_stage > stage_limit or next_stage <= current_stage:
		return false
	current_stage = next_stage
	return true


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
			if _role.position.x < 1600:
				advance_stage(1)
			if _role.position.x >= 1600 and _role.position.x < 2700:
				advance_stage(2)
			if _role.position.x >= 2700 and _role.position.x < 4000:
				advance_stage(3)
			if _role.position.x >= 4000:
				advance_stage(4)
		else:
			if _role.position.x < 1000:
				advance_stage(1)
			if _role.position.x >= 1300 and _role.position.x < 2700:
				advance_stage(2)
			if _role.position.x >= 2700 and _role.position.x < 4000:
				advance_stage(3)
			if _role.position.x >= 4000:
				advance_stage(4)

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
	var current_level_name := str(Global.get_current_level_name())
	var nightmare := int(MainSet.set_data.get("Difficult", 0)) == BaseMonster.NIGHTMARE_DIFFICULTY
	LEVEL_PROGRESS_COMMAND.apply(
		PlayerData.player_data, int(level), current_level_name, self is Game4ImportedLevel, nightmare
	)


func _shake_screen(strength: float, times: int, inte: float):
	if my_camera != null:
		my_camera.shake(strength, times, inte)


func remove_all_records():
	Global.get_run_context().reset_level_progress()


## ---------------------------------------------------------------------------
## 关卡阶段契约（Phase 10.5 / Phase 11 夹具与 CI 统一入口）
## 子类可覆盖；默认实现基于 BaseLevel 的 4 阶段状态机与 change_mysee 相机边界。
## ---------------------------------------------------------------------------
func _layout_scene_path() -> String:
	return str(scene_file_path)


func _layout_entry() -> LevelLayoutEntry:
	return LevelLayoutStore.layout(_layout_scene_path())


func _uses_layout_spawn_tables() -> bool:
	return true


## 标准 BaseLevel 关卡把布局刷怪点展开回既有三段并行数组。
## Game4ImportedLevel 仍由 `_configure_level_monsters()` 负责，避免重复填充。
func _load_layout_spawn_tables() -> void:
	if not _uses_layout_spawn_tables():
		return
	var layout := _layout_entry()
	if layout == null:
		return
	for stage_key in ["stage_1", "stage_2", "stage_3", "stage_4"]:
		monster_group[stage_key] = []
		monster_position_x[stage_key] = []
		monster_position_y[stage_key] = []
	for point in _birth_points():
		var stage_key := "stage_%d" % int(point["stage"])
		if not monster_group.has(stage_key):
			continue
		var spawn_position: Vector2 = point["position"]
		for _unit in range(maxi(int(point.get("total", 1)), 0)):
			monster_group[stage_key].append(int(point["monster"]))
			monster_position_x[stage_key].append(spawn_position.x)
			monster_position_y[stage_key].append(spawn_position.y)


func _player_spawn_position(slot: int, fallback: Vector2) -> Vector2:
	var births := LevelLayoutStore.player_birth_points(_layout_scene_path())
	if slot >= 1 and slot <= births.size():
		return births[slot - 1]
	return fallback


func _stage_count() -> int:
	var layout := _layout_entry()
	if layout != null and layout.stage_count() > 0:
		return layout.stage_count()
	var populated := 0
	for stage_index in range(1, 5):
		var stage_key := "stage_%d" % stage_index
		var stage_list: Variant = monster_group.get(stage_key, [])
		if stage_list is Array and not (stage_list as Array).is_empty():
			populated += 1
	return maxi(populated, 1)


func _stage_trigger_x() -> Array:
	var layout := _layout_entry()
	if layout != null:
		var triggers := LevelLayoutStore.stage_trigger_x(str(scene_file_path))
		if not triggers.is_empty():
			return triggers
	var fallback: Array = [0.0]
	if is_two_scene:
		fallback.append_array([1300.0, 2700.0, 4000.0])
	else:
		fallback.append_array([1600.0, 2700.0, 4000.0])
	return fallback.slice(0, _stage_count())


func _screen_starts() -> Array:
	var layout := _layout_entry()
	if layout != null:
		var starts := LevelLayoutStore.screen_starts(str(scene_file_path))
		if not starts.is_empty():
			return starts
	var fallback: Array = [0.0, 2250.0, 3550.0, 4650.0]
	return fallback.slice(0, _stage_count())


func _screen_rights() -> Array:
	var layout := _layout_entry()
	if layout != null:
		var rights := LevelLayoutStore.screen_rights(str(scene_file_path))
		if not rights.is_empty():
			return rights
	var fallback: Array = [2250.0, 3550.0, 4650.0, 4650.0]
	return fallback.slice(0, _stage_count())


func _birth_points() -> Array:
	# 兼容既有 Game4ImportedLevel 契约：这里返回刷怪点字典，不是玩家出生点。
	return LevelLayoutStore.spawn_point_dicts(_layout_scene_path())


func _stage_activate(_index: int) -> bool:
	# 可选契约：由关卡自身决定如何激活指定阶段（触发器/房间/剧情）。
	return false
