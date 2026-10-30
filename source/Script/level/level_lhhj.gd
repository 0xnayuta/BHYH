extends BaseLevel
class_name Lhhj

const GAME4_LEVEL_CONFIG_SCRIPT_PATH_BY_MONSTER := {
	3001: "res://Script/level/level_47.gd",
	3003: "res://Script/level/level_47.gd",
	3004: "res://Script/level/level_47.gd",
	3005: "res://Script/level/level_47.gd",
	3002: "res://Script/level/level_48.gd",
	3006: "res://Script/level/level_48.gd",
	3007: "res://Script/level/level_49.gd",
	3008: "res://Script/level/level_50.gd",
	3009: "res://Script/level/level_50.gd",
	3019: "res://Script/level/level_50.gd",
	3010: "res://Script/level/level_51.gd",
	3011: "res://Script/level/level_51.gd",
	3020: "res://Script/level/level_51.gd",
	3021: "res://Script/level/level_52.gd",
	3031: "res://Script/level/level_53.gd",
	3033: "res://Script/level/level_53.gd",
	3049: "res://Script/level/level_53.gd",
	3028: "res://Script/level/level_54.gd",
	3032: "res://Script/level/level_54.gd",
	3034: "res://Script/level/level_54.gd",
	3030: "res://Script/level/level_55.gd",
	3035: "res://Script/level/level_55.gd",
	3038: "res://Script/level/level_56.gd",
	3040: "res://Script/level/level_56.gd",
	3047: "res://Script/level/level_56.gd",
	3036: "res://Script/level/level_57.gd",
	3037: "res://Script/level/level_57.gd",
	3039: "res://Script/level/level_57.gd",
	3041: "res://Script/level/level_57.gd",
	3042: "res://Script/level/level_58.gd",
	3056: "res://Script/level/level_58.gd",
	3065: "res://Script/level/level_59.gd",
	3066: "res://Script/level/level_59.gd",
	3068: "res://Script/level/level_59.gd",
	3069: "res://Script/level/level_59.gd",
	3067: "res://Script/level/level_60.gd",
	3070: "res://Script/level/level_60.gd",
	3071: "res://Script/level/level_61.gd",
	3076: "res://Script/level/level_61.gd",
	3077: "res://Script/level/level_61.gd",
	3078: "res://Script/level/level_61.gd",
	3080: "res://Script/level/level_61.gd",
	3081: "res://Script/level/level_61.gd",
	3082: "res://Script/level/level_61.gd",
	3117: "res://Script/level/level_62.gd",
}

var is_cc = false
var is_set: bool
var _monsters_settled_in_tree: bool = false
var _game4_level_config_providers: Dictionary = {}


func _ready() -> void:
	Global.set_current_level_name("")
	Global.get_audio_runtime().add_bgm(self, "res://Music/level/szzw.mp3")

	self.level_stage = 1
	super._ready()
	current_stage = 1
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


func get_level_monster_config(monster_id: int) -> Dictionary:
	var script_path := str(GAME4_LEVEL_CONFIG_SCRIPT_PATH_BY_MONSTER.get(monster_id, ""))
	if script_path == "":
		return {}
	var provider: Node = _game4_level_config_providers.get(script_path) as Node
	if provider == null:
		var source := ResourceLoader.load(script_path, "GDScript", ResourceLoader.CACHE_MODE_REUSE) as Script
		var instance: Variant = source.new() if source != null else null
		if not instance is Node:
			return {}
		provider = instance as Node
		_game4_level_config_providers[script_path] = provider
	if provider.has_method("get_level_monster_config"):
		var value: Variant = provider.call("get_level_monster_config", monster_id)
		if value is Dictionary and not (value as Dictionary).is_empty():
			return (value as Dictionary).duplicate(true)
	return {}


func _exit_tree() -> void:
	for provider_value in _game4_level_config_providers.values():
		var provider := provider_value as Node
		if provider != null and is_instance_valid(provider):
			provider.free()
	_game4_level_config_providers.clear()


func _physics_process(delta: float) -> void:
	role_information.gogo.visible = false
	if not is_set:
		var monster_parent: Node2D = self.monster if self.monster != null else self
		for u in Global.lhhj_boss_list:
			var i = Global.lhhj_boss_list[u]
			var id = i["Num"]
			var local = Vector2(1100, 400)
			if id == 33 or id == 24 or id == 56:
				local = Vector2(700, 390)
			var spawned_monster := Global.create_monster(int(i["Num"]), monster_parent, local) as BaseMonster
			if spawned_monster == null:
				continue
			if i["Name"] != null and str(i["Name"]) != "":
				spawned_monster.my_mr_name = str(i["Name"])
			if int(i["Level"]) > 0:
				spawned_monster.level = i["Level"]
			if int(i["SHp"]) > 0:
				spawned_monster.max_hp = i["SHp"]
				spawned_monster.hp = spawned_monster.max_hp
			if int(i["def"]) > 0:
				spawned_monster.def = i["def"]
			if int(i["mdef"]) > 0:
				spawned_monster.mdef = i["mdef"]
			if int(i["crit"]) > 0:
				spawned_monster.crit = i["crit"]
			if int(i["miss"]) > 0:
				spawned_monster.miss = i["miss"]
			if int(i["lucky"]) > 0:
				spawned_monster.lucky = i["lucky"]
			if int(i["htarget"]) > 0:
				spawned_monster.htarget = i["htarget"]
			if int(i["toughness"]) > 0:
				spawned_monster.toughness = i["toughness"]
			if int(i["crit_reduce"]) > 0:
				spawned_monster.crit_reduce = i["crit_reduce"]
			if int(i["ar"]) > 0:
				spawned_monster.ar = i["ar"]
			if int(i["sp"]) > 0:
				spawned_monster.sp = i["sp"]
			if int(i["speed"]) > 0:
				spawned_monster.speed = i["speed"]
			if int(i["self_rhp"]) > 0:
				spawned_monster.self_rhp = i["self_rhp"]
			if float(i["ebol"]) > 0:
				spawned_monster.ebol = i["ebol"]
			spawned_monster.fall_list = []
			spawned_monster.add_exp = 0
			spawned_monster.fall_coin = 0
			spawned_monster.fall_pro = 0
			spawned_monster.fall_stone_pro = 0
			spawned_monster.fall_stone = []
			if int(i["power"]) > 0:
				for z in spawned_monster.obj_attack_dict:
					if spawned_monster.obj_attack_dict[z].has("power"):
						spawned_monster.obj_attack_dict[z]["power"] = i["power"]
		is_set = true
	if not is_cc:
		if _role.position.x >= 600:
			create_control.wait_time = 3
			create_control.start()
			is_cc = true
			role_information.gogo.visible = false
		else:
			create_control.wait_time = 3
			create_control.start()
	if is_set and not _monsters_settled_in_tree:
		if _get_alive_stage_monster_count() > 0:
			_monsters_settled_in_tree = true
	super._physics_process(delta)
	my_camera.max_right = 1400

	if current_stage >= 1:
		if check_can_pass() and current_stage < 1:
			role_information.gogo.visible = true
		else:
			role_information.gogo.visible = false


func one_check_can_exit() -> bool:
	if not is_set or not _monsters_settled_in_tree:
		return false
	return _get_alive_stage_monster_count() == 0


func check_can_exit() -> bool:
	return one_check_can_exit()


func check_can_pass() -> bool:
	return one_check_can_exit()
