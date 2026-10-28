extends Node
class_name BaseRoleProperties

var PlayerData: PlayerDataStore:
	get:
		var coop := get_node_or_null("/root/LocalCoop")
		if coop == null:
			return get_node("/root/PlayerData")
		return self if self == coop.data_for_slot(1) else coop.data_for(self)
var RoleProp: BaseRoleProperties:
	get:
		var coop := get_node_or_null("/root/LocalCoop")
		if coop == null:
			return get_node("/root/RoleProp")
		if self == get_node("/root/RoleProp"):
			return self
		return self if self == coop.props_for_slot(1) else coop.props_for(self)

const BODY_TRAINING_DATA = preload("res://Script/data/body_training_data.gd")

var directon: bool
var source_player
var roleprop = {}
var baseroleprop = {}
var equprop = {}
var pasl_prop = {}
var wq_bs_prop = {}
var fj_bs_prop = {}
var sp_bs_prop = {}
var cb_bs_prop = {}
var sz_bs_prop = {}
var tx_bs_prop = {}
var role_pos_x
var role_pos
var role_pos_y
var _monster_attack_targets: Array[Node2D] = []
var slz_level: int
var hytj_level: int
var lys_level: int
var lyfb_level: int
var hmz_level: int
var ws_value: int
var max_ws_value = 100
var is_ws_state = false
var ws_up_power = 1
var wq_prop = {}
var fj_prop = {}
var sp_prop = {}
var sz_prop = {}
var tx_prop = {}
var cb_prop = {}
var fb_prop = {}
var role1_sxbj: float
var role1_s_xxx: float
var current_hp: int = 1
var current_mp: int = 1
var pet_life_bonus: int = 0
var pet_attack_bonus: int = 0
var pet_defense_bonus: int = 0
var pet_magic_defense_bonus: int = 0
var pet_mana_bonus: int = 0
var _equipment_signature := 0
var _static_prop_signature := 0
var _cached_pellet_props: Array = []
var _cached_zf_props: Dictionary = {}
var _cached_sword_props: Dictionary = {}
var _cached_body_props: Dictionary = {}
var _cached_wanling_props: Dictionary = {}
var _cached_mount_props: Dictionary = {}
var pellet_props = {
	"1品丹":
	{
		"生命": 100,
		"魔法": 10,
		"攻击": 10,
		"暴击": 1,
		"幸运": 1,
		"回魔": 0.4,
	},
	"2品丹":
	{
		"生命": 150,
		"魔法": 15,
		"攻击": 15,
		"暴击": 1,
		"幸运": 1,
		"回魔": 0.4,
	},
	"3品丹":
	{
		"生命": 200,
		"魔法": 40,
		"攻击": 20,
		"暴击": 1,
		"幸运": 1,
		"回魔": 0.4,
	},
	"4品丹":
	{
		"生命": 250,
		"魔法": 55,
		"攻击": 25,
		"暴击": 1,
		"幸运": 1,
		"回魔": 0.4,
	},
	"5品丹":
	{
		"生命": 300,
		"魔法": 70,
		"攻击": 30,
		"暴击": 2,
		"幸运": 2,
		"回魔": 0.4,
	},
}
var zhen_fa_props = {
	"森罗阵":
	{
		"1": {"Type": "物防", "Value": 1},
		"2": {"Type": "暴击", "Value": 1},
		"3": {"Type": "魔防", "Value": 1},
	},
	"落魄阵":
	{
		"1": {"Type": "魔法", "Value": 15},
		"2": {"Type": "攻击", "Value": 5},
		"3": {"Type": "幸运", "Value": 1},
	},
	"腾蛇阵":
	{
		"1": {"Type": "生命", "Value": 75},
		"2": {"Type": "攻击", "Value": 10},
		"3": {"Type": "破甲", "Value": 2},
		"4": {"Type": "破魔", "Value": 2},
	},
	"太清阵":
	{
		"1": {"Type": "生命", "Value": 75},
		"2": {"Type": "攻击", "Value": 10},
		"3": {"Type": "暴击", "Value": 1},
		"4": {"Type": "幸运", "Value": 1},
	},
}


func register_monster_attack_target(target: Node2D) -> void:
	if target != null and is_instance_valid(target) and not _monster_attack_targets.has(target):
		_monster_attack_targets.append(target)


func unregister_monster_attack_target(target: Node2D) -> void:
	_monster_attack_targets.erase(target)


func get_nearest_monster_target_position(origin: Vector2) -> Vector2:
	var nearest_position := Vector2.ZERO
	if is_instance_valid(source_player) and source_player is Node2D:
		nearest_position = (source_player as Node2D).global_position
	elif role_pos is Vector2:
		nearest_position = role_pos
	elif role_pos_x != null and role_pos_y != null:
		nearest_position = Vector2(float(role_pos_x), float(role_pos_y))

	if LocalCoop.is_enabled():
		var hero: Node2D = LocalCoop.nearest_player(origin)
		if hero != null:
			nearest_position = hero.global_position
	var nearest_distance := origin.distance_squared_to(nearest_position)
	for index in range(_monster_attack_targets.size() - 1, -1, -1):
		var target := _monster_attack_targets[index]
		if target == null or not is_instance_valid(target) or not target.is_inside_tree() or int(target.get("hp")) <= 0:
			_monster_attack_targets.remove_at(index)
			continue
		var target_position := target.global_position
		var target_distance := origin.distance_squared_to(target_position)
		if target_distance < nearest_distance:
			nearest_position = target_position
			nearest_distance = target_distance
	return nearest_position


func get_zf_loc_prop(Name, loc):
	var level = int(PlayerData.player_data[Name][str(loc)]["Level"])
	var dic = zhen_fa_props[Name]
	var prop = int(dic[str(loc)]["Value"]) * level
	return prop


func get_next_level_prop(Name, loc):
	var level = int(PlayerData.player_data[Name][str(loc)]["Level"]) + 1
	var dic = zhen_fa_props[Name]
	var prop = int(dic[str(loc)]["Value"]) * level
	return prop


func get_zf_prop(Name):
	match Name:
		"生命":
			return get_zf_loc_prop("太清阵", 1) + get_zf_loc_prop("腾蛇阵", 1)
		"魔法":
			return get_zf_loc_prop("落魄阵", 1)
		"攻击":
			return get_zf_loc_prop("太清阵", 2) + get_zf_loc_prop("腾蛇阵", 2) + get_zf_loc_prop("落魄阵", 2)
		"物防":
			return get_zf_loc_prop("森罗阵", 1)
		"魔防":
			return get_zf_loc_prop("森罗阵", 3)
		"暴击":
			return get_zf_loc_prop("森罗阵", 2) + get_zf_loc_prop("太清阵", 3)
		"幸运":
			return get_zf_loc_prop("太清阵", 4) + get_zf_loc_prop("落魄阵", 3)
		"破甲":
			return get_zf_loc_prop("腾蛇阵", 3)
		"破魔":
			return get_zf_loc_prop("腾蛇阵", 4)
	return 0


func get_main_sword_array_prop(Name):
	PlayerData.ensure_main_sword_array()
	var active := str(PlayerData.player_data.get("主线剑阵出战", ""))
	if active == "":
		return 0
	var total := 0
	if active == "sijianheyi":
		total += _get_single_main_sword_array_prop(Name, "zhuxianjian", _get_main_sword_array_level("zhuxianjian"))
		total += _get_single_main_sword_array_prop(Name, "xianxianjian", _get_main_sword_array_level("xianxianjian"))
		total += _get_single_main_sword_array_prop(Name, "luxianjian", _get_main_sword_array_level("luxianjian"))
		total += _get_single_main_sword_array_prop(Name, "juexianjian", _get_main_sword_array_level("juexianjian"))
		total += _get_sijianheyi_prop(Name, _get_main_sword_array_level("sijianheyi"))
		return total
	return _get_single_main_sword_array_prop(Name, active, _get_main_sword_array_level(active))


func _get_main_sword_array_level(sword_id: String) -> int:
	if PlayerData != null and PlayerData.has_method("get_main_sword_array_level"):
		return int(PlayerData.get_main_sword_array_level(sword_id))
	return 0


func _get_single_main_sword_array_prop(Name: String, sword_id: String, level: int) -> int:
	if level <= 0:
		return 0
	match sword_id:
		"zhuxianjian":
			if Name == "攻击":
				return level * 150
		"xianxianjian":
			if Name == "生命":
				return level * 500
		"luxianjian":
			if Name == "物防" or Name == "魔防":
				return level * 20
		"juexianjian":
			if Name == "魔法":
				return level * 400
	return 0


func _get_sijianheyi_prop(Name: String, level: int) -> int:
	if level <= 0:
		return 0
	match Name:
		"暴击":
			return level * 10
		"命中":
			return level * 10
		"闪避":
			return level * 5
		"幸运":
			return level * 5
	return 0


func _ready() -> void:
	baseroleprop = {
		"Level": 1,
		"SHp": 0,
		"Hp": 0,
		"SMp": 0,
		"Mp": 0,
		"power": 0,
		"Def": 0,
		"Mdef": 0,
		"Crit": 0,
		"Miss": 0,
		"R_hp": 0,
		"R_mp": 0,
		"vampirism": 0.0,
		"Lucky": 0,
		"toughness": 0,
		"htarget": 0,
		"CritReduce": 0,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"ar": 0,
		"sp": 0,
		"exp": 0,
		"max_exp": 0,
		"gxp_value": 0,
		"coin_num": 0
	}
	roleprop = {
		"SHp": 0,
		"Hp": 0,
		"SMp": 0,
		"Mp": 0,
		"power": 0,
		"Def": 0,
		"Mdef": 0,
		"Crit": 0,
		"Miss": 0,
		"R_hp": 0,
		"R_mp": 0,
		"vampirism": 0.0,
		"Lucky": 0,
		"toughness": 0,
		"htarget": 0,
		"CritReduce": 0,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"ar": 0,
		"sp": 0
	}
	equprop = {
		"SHp": 0,
		"SMp": 0,
		"power": 0,
		"Def": 0,
		"Mdef": 0,
		"Crit": 0,
		"Miss": 0,
		"R_hp": 0,
		"R_mp": 0,
		"vampirism": 0.0,
		"Lucky": 0,
		"toughness": 0,
		"htarget": 0,
		"CritReduce": 0,
		"ar": 0,
		"sp": 0
	}
	wq_prop = {
		"SHp": 0,
		"SMp": 0,
		"power": 0,
		"Def": 0,
		"Mdef": 0,
		"Crit": 0,
		"Miss": 0,
		"R_hp": 0,
		"R_mp": 0,
		"vampirism": 0.0,
		"Lucky": 0,
		"toughness": 0,
		"htarget": 0,
		"CritReduce": 0,
		"ar": 0,
		"sp": 0
	}
	fj_prop = {
		"SHp": 0,
		"SMp": 0,
		"power": 0,
		"Def": 0,
		"Mdef": 0,
		"Crit": 0,
		"Miss": 0,
		"R_hp": 0,
		"R_mp": 0,
		"vampirism": 0.0,
		"Lucky": 0,
		"toughness": 0,
		"htarget": 0,
		"CritReduce": 0,
		"ar": 0,
		"sp": 0
	}
	sp_prop = {
		"SHp": 0,
		"SMp": 0,
		"power": 0,
		"Def": 0,
		"Mdef": 0,
		"Crit": 0,
		"Miss": 0,
		"R_hp": 0,
		"R_mp": 0,
		"vampirism": 0.0,
		"Lucky": 0,
		"toughness": 0,
		"htarget": 0,
		"CritReduce": 0,
		"ar": 0,
		"sp": 0
	}
	fb_prop = {
		"SHp": 0,
		"SMp": 0,
		"power": 0,
		"Def": 0,
		"Mdef": 0,
		"Crit": 0,
		"Miss": 0,
		"R_hp": 0,
		"R_mp": 0,
		"vampirism": 0.0,
		"Lucky": 0,
		"toughness": 0,
		"htarget": 0,
		"CritReduce": 0,
		"ar": 0,
		"sp": 0
	}
	cb_prop = {
		"SHp": 0,
		"SMp": 0,
		"power": 0,
		"Def": 0,
		"Mdef": 0,
		"Crit": 0,
		"Miss": 0,
		"R_hp": 0,
		"R_mp": 0,
		"vampirism": 0.0,
		"Lucky": 0,
		"toughness": 0,
		"htarget": 0,
		"CritReduce": 0,
		"ar": 0,
		"sp": 0
	}
	tx_prop = {
		"SHp": 0,
		"SMp": 0,
		"power": 0,
		"Def": 0,
		"Mdef": 0,
		"Crit": 0,
		"Miss": 0,
		"R_hp": 0,
		"R_mp": 0,
		"vampirism": 0.0,
		"Lucky": 0,
		"toughness": 0,
		"htarget": 0,
		"CritReduce": 0,
		"ar": 0,
		"sp": 0
	}
	sz_prop = {
		"SHp": 0,
		"SMp": 0,
		"power": 0,
		"Def": 0,
		"Mdef": 0,
		"Crit": 0,
		"Miss": 0,
		"R_hp": 0,
		"R_mp": 0,
		"vampirism": 0.0,
		"Lucky": 0,
		"toughness": 0,
		"htarget": 0,
		"CritReduce": 0,
		"ar": 0,
		"sp": 0
	}
	pasl_prop = {
		"SHp": 0,
		"SMp": 0,
		"power": 0,
		"Def": 0,
		"Mdef": 0,
		"Crit": 0,
		"Miss": 0,
		"R_hp": 0,
		"R_mp": 0,
		"vampirism": 0.0,
		"Lucky": 0,
		"toughness": 0,
		"htarget": 0,
		"CritReduce": 0,
		"ar": 0,
		"sp": 0
	}
	wq_bs_prop = {
		"SHp": 0,
		"SMp": 0,
		"power": 0,
		"Def": 0,
		"Mdef": 0,
		"Crit": 0,
		"Miss": 0,
		"R_hp": 0,
		"R_mp": 0,
		"vampirism": 0,
		"Lucky": 0,
		"toughness": 0,
		"htarget": 0,
		"CritReduce": 0,
		"ar": 0,
		"sp": 0
	}
	fj_bs_prop = {
		"SHp": 0,
		"SMp": 0,
		"power": 0,
		"Def": 0,
		"Mdef": 0,
		"Crit": 0,
		"Miss": 0,
		"R_hp": 0,
		"R_mp": 0,
		"vampirism": 0,
		"Lucky": 0,
		"toughness": 0,
		"htarget": 0,
		"CritReduce": 0,
		"ar": 0,
		"sp": 0
	}
	sp_bs_prop = {
		"SHp": 0,
		"SMp": 0,
		"power": 0,
		"Def": 0,
		"Mdef": 0,
		"Crit": 0,
		"Miss": 0,
		"R_hp": 0,
		"R_mp": 0,
		"vampirism": 0,
		"Lucky": 0,
		"toughness": 0,
		"htarget": 0,
		"CritReduce": 0,
		"ar": 0,
		"sp": 0
	}


func get_pellet_prop():
	var _hp: int = 0
	var _mp: int = 0
	var att: int = 0
	var crit: int = 0
	var lucky: int = 0
	var emp: float = 0
	for i in range(6):
		if i > 0:
			_hp += PlayerData.player_data["生命丹" + str(i)] * pellet_props[str(i) + "品丹"][DataKeys.HP]
			_mp += PlayerData.player_data["魔法丹" + str(i)] * pellet_props[str(i) + "品丹"][DataKeys.MP]
			att += PlayerData.player_data["攻击丹" + str(i)] * pellet_props[str(i) + "品丹"][DataKeys.ATTACK]
			crit += PlayerData.player_data["暴击丹" + str(i)] * pellet_props[str(i) + "品丹"]["暴击"]
			lucky += PlayerData.player_data["幸运丹" + str(i)] * pellet_props[str(i) + "品丹"]["幸运"]
			emp += PlayerData.player_data["回魔丹" + str(i)] * pellet_props[str(i) + "品丹"]["回魔"]
	return [_hp, _mp, att, crit, lucky, emp]


func _get_static_prop_signature() -> int:
	var values: Array = []
	for i in range(1, 6):
		values.append(PlayerData.player_data.get("生命丹" + str(i), 0))
		values.append(PlayerData.player_data.get("魔法丹" + str(i), 0))
		values.append(PlayerData.player_data.get("攻击丹" + str(i), 0))
		values.append(PlayerData.player_data.get("暴击丹" + str(i), 0))
		values.append(PlayerData.player_data.get("幸运丹" + str(i), 0))
		values.append(PlayerData.player_data.get("回魔丹" + str(i), 0))
	for formation_name in ["森罗阵", "落魂阵", "腾蛇阵", "太清阵"]:
		values.append(PlayerData.player_data.get(formation_name, {}))
	values.append(PlayerData.player_data.get("主线剑阵出战", ""))
	for sword_id in ["zhuxianjian", "xianxianjian", "luxianjian", "juexianjian", "sijianheyi"]:
		values.append(_get_main_sword_array_level(sword_id))
	var shared_data := _shared_attribute_data()
	values.append(shared_data.player_data.get("炼体", {}))
	values.append(shared_data.player_data.get(PlayerData.WANLING_CATALOG_LEVELS_KEY, {}))
	values.append(PlayerData.player_data.get(PlayerData.ACTIVE_MOUNT_KEY, ""))
	values.append(PlayerData.is_mount_system_unlocked())
	var active_mount := PlayerData.get_active_mount()
	values.append(active_mount.get(DataKeys.LEVEL, 0))
	return hash(values)


func _body_training_profile() -> String:
	return "p1"


func _shared_attribute_data() -> Node:
	var coop := get_node_or_null("/root/LocalCoop")
	if coop != null and coop.is_enabled():
		return coop.canonical_profile_for_slot(1)
	return PlayerData


func _refresh_static_prop_cache() -> void:
	var signature := _get_static_prop_signature()
	if signature == _static_prop_signature and not _cached_pellet_props.is_empty():
		return
	_static_prop_signature = signature
	_cached_pellet_props = get_pellet_prop()
	_cached_zf_props = {
		"生命": get_zf_prop("生命"),
		"魔法": get_zf_prop("魔法"),
		"攻击": get_zf_prop("攻击"),
		"暴击": get_zf_prop("暴击"),
		"幸运": get_zf_prop("幸运"),
		"物防": get_zf_prop("物防"),
		"魔防": get_zf_prop("魔防"),
		"破甲": get_zf_prop("破甲"),
		"破魔": get_zf_prop("破魔")
	}
	_cached_sword_props = {
		"生命": get_main_sword_array_prop("生命"),
		"魔法": get_main_sword_array_prop("魔法"),
		"攻击": get_main_sword_array_prop("攻击"),
		"暴击": get_main_sword_array_prop("暴击"),
		"幸运": get_main_sword_array_prop("幸运"),
		"物防": get_main_sword_array_prop("物防"),
		"魔防": get_main_sword_array_prop("魔防"),
		"闪避": get_main_sword_array_prop("闪避"),
		"命中": get_main_sword_array_prop("命中")
	}
	var shared_data := _shared_attribute_data()
	_cached_body_props = BODY_TRAINING_DATA.get_attribute_totals(
		shared_data.player_data.get("炼体", {}), _body_training_profile()
	)
	_cached_wanling_props = shared_data.get_wanling_attribute_totals()
	_cached_mount_props = PlayerData.get_active_mount_attribute_bonuses()


func get_last_prop():
	if PlayerData.check_eq_zb("头衔", "xczg"):
		if source_player != null:
			for i in source_player.buff.get_children():
				if i.buff_info.has("DeBuff") and i.buff_info["DeBuff"]:
					i.queue_free()
	var is_sxyr: bool = bool(PlayerData.check_eq_zb("头衔", "sxyr"))
	if is_sxyr and source_player != null and not source_player.sxyr_cannot_cure:
		roleprop.SHp = 1
		roleprop.Hp = 1
		source_player.sxyr_cannot_cure = true
		for i in source_player.buff.get_children():
			if i.buff_info.has("DeBuff") and i.buff_info["DeBuff"]:
				i.queue_free()

	_refresh_static_prop_cache()
	var pellet: Array = _cached_pellet_props
	var zf_hp = _cached_zf_props[DataKeys.HP]
	var zf_mp = _cached_zf_props[DataKeys.MP]
	var zf_power = _cached_zf_props[DataKeys.ATTACK]
	var zf_crit = _cached_zf_props["暴击"]
	var zf_lucky = _cached_zf_props["幸运"]
	var zf_def = _cached_zf_props["物防"]
	var zf_mdef = _cached_zf_props["魔防"]
	var zf_ar = _cached_zf_props["破甲"]
	var zf_sp = _cached_zf_props["破魔"]
	var sword_hp = _cached_sword_props[DataKeys.HP]
	var sword_mp = _cached_sword_props[DataKeys.MP]
	var sword_power = _cached_sword_props[DataKeys.ATTACK]
	var sword_crit = _cached_sword_props["暴击"]
	var sword_lucky = _cached_sword_props["幸运"]
	var sword_def = _cached_sword_props["物防"]
	var sword_mdef = _cached_sword_props["魔防"]
	var sword_miss = _cached_sword_props["闪避"]
	var sword_hit = _cached_sword_props["命中"]
	var body_hp = int(_cached_body_props.get("hpMax", 0))
	var body_mp = int(_cached_body_props.get("mpMax", 0))
	var body_power = int(_cached_body_props.get("atk", 0))
	var body_def = int(_cached_body_props.get("phyDef", 0))
	var body_mdef = int(_cached_body_props.get("magicDef", 0))
	var wanling_hp = float(_cached_wanling_props.get("SHp", 0.0))
	var wanling_mp = float(_cached_wanling_props.get("SMp", 0.0))
	var wanling_power = float(_cached_wanling_props.get("power", 0.0))
	var wanling_def = float(_cached_wanling_props.get("Def", 0.0))
	var wanling_mdef = float(_cached_wanling_props.get("Mdef", 0.0))
	var wanling_crit = float(_cached_wanling_props.get("Crit", 0.0))
	var mount_hp = float(_cached_mount_props.get("SHp", 0.0))
	var mount_power = float(_cached_mount_props.get("power", 0.0))
	var mount_def = float(_cached_mount_props.get("Def", 0.0))
	var mount_mdef = float(_cached_mount_props.get("Mdef", 0.0))
	var mount_crit = float(_cached_mount_props.get("Crit", 0.0))
	if not is_sxyr:
		roleprop.SHp = maxi(
			1,
			int(
				(
					baseroleprop.SHp
					+ equprop.SHp
					+ pasl_prop.SHp
					+ pellet[0]
					+ zf_hp
					+ sword_hp
					+ body_hp
					+ pet_life_bonus
					+ wanling_hp
					+ mount_hp
				)
			)
		)
		if source_player != null:
			roleprop.SHp = maxi(
				1, int(round(float(roleprop.SHp) * (1.0 + maxf(0.0, source_player.temp_max_hp_bonus_rate))))
			)
	roleprop.SMp = (
		baseroleprop.SMp
		+ equprop.SMp
		+ pasl_prop.SMp
		+ pellet[1]
		+ zf_mp
		+ sword_mp
		+ body_mp
		+ pet_mana_bonus
		+ wanling_mp
	)
	var base_power = (
		baseroleprop.power
		+ equprop.power
		+ pasl_prop.power
		+ pellet[2]
		+ zf_power
		+ sword_power
		+ body_power
		+ pet_attack_bonus
		+ wanling_power
		+ mount_power
	)
	var base_crit = (
		baseroleprop.Crit
		+ equprop.Crit
		+ pasl_prop.Crit
		+ role1_sxbj
		+ pellet[3]
		+ zf_crit
		+ sword_crit
		+ wanling_crit
		+ float(_cached_mount_props.get("Crit", 0.0))
	)
	var base_lucky = (
		baseroleprop.Lucky
		+ equprop.Lucky
		+ pasl_prop.Lucky
		+ pellet[4]
		+ zf_lucky
		+ sword_lucky
		+ float(_cached_mount_props.get("Lucky", 0.0))
	)
	if source_player != null and source_player.is_yx_buff:
		roleprop.power = int(base_power * (1 + source_player.yx_buff_power_rate))
		roleprop.Crit = base_crit * (1 + source_player.yx_buff_crit_rate)
		roleprop.Lucky = int(base_lucky * (1 + source_player.yx_buff_lucky_rate))
	else:
		roleprop.power = base_power
		roleprop.Crit = base_crit
		roleprop.Lucky = base_lucky
	if source_player != null:
		roleprop.power = int(round(float(roleprop.power) * (1.0 + maxf(0.0, source_player.temp_power_bonus_rate))))
	if is_instance_valid(source_player) and source_player is YutuHero:
		roleprop.power += int(round(source_player.moon_attack_bonus))
	if is_instance_valid(source_player):
		var mount_runtime: Node = source_player.get_node_or_null("MountRuntime")
		if mount_runtime != null and mount_runtime.has_method("get_stat_bonus"):
			roleprop.power = int(
				round(
					(
						float(roleprop.power) * (1.0 + float(mount_runtime.call("get_stat_bonus", "power_rate")))
						+ float(mount_runtime.call("get_stat_bonus", "power_flat"))
					)
				)
			)
			var critical_bonus := float(mount_runtime.call("get_stat_bonus", "critical"))
			if critical_bonus > 0.0:
				var critical_chance := clampf(
					float(roleprop.Crit) / (float(roleprop.Crit) + 100.0) + critical_bonus, 0.0, 0.99
				)
				roleprop.Crit = 100.0 * critical_chance / (1.0 - critical_chance)
			roleprop.damage_bonus += float(mount_runtime.call("get_stat_bonus", "damage_bonus"))
			roleprop.damage_reduction += float(mount_runtime.call("get_stat_bonus", "damage_reduction"))
			roleprop.mount_hit_bonus = float(mount_runtime.call("get_stat_bonus", "hit"))
	roleprop.Def = (
		baseroleprop.Def
		+ equprop.Def
		+ pasl_prop.Def
		+ zf_def
		+ sword_def
		+ body_def
		+ pet_defense_bonus
		+ wanling_def
		+ mount_def
	)
	roleprop.Mdef = (
		baseroleprop.Mdef
		+ equprop.Mdef
		+ pasl_prop.Mdef
		+ zf_mdef
		+ sword_mdef
		+ body_mdef
		+ pet_magic_defense_bonus
		+ wanling_mdef
		+ mount_mdef
	)
	if source_player != null:
		roleprop.Def += source_player.temp_def_bonus
		roleprop.Mdef += source_player.temp_mdef_bonus
		if source_player.is_t_mc:
			roleprop.Def = int(round(float(roleprop.Def) * 1.5))
			roleprop.Mdef = int(round(float(roleprop.Mdef) * 1.5))
	roleprop.Miss = (
		baseroleprop.Miss + equprop.Miss + pasl_prop.Miss + sword_miss + float(_cached_mount_props.get("Miss", 0.0))
	)
	roleprop.R_hp = (
		baseroleprop.R_hp
		+ equprop.R_hp
		+ pasl_prop.R_hp
		+ float(_cached_wanling_props.get("R_hp", 0.0))
		+ float(_cached_mount_props.get("R_hp", 0.0))
	)
	roleprop.R_mp = (
		baseroleprop.R_mp + equprop.R_mp + pasl_prop.R_mp + pellet[5] + float(_cached_wanling_props.get("R_mp", 0.0))
	)
	roleprop.vampirism = (
		baseroleprop.vampirism
		+ equprop.vampirism
		+ pasl_prop.vampirism
		+ role1_s_xxx
		+ float(_cached_wanling_props.get("vampirism", 0.0))
	)
	roleprop.toughness = baseroleprop.toughness + equprop.toughness + pasl_prop.toughness
	roleprop.htarget = (
		baseroleprop.htarget
		+ equprop.htarget
		+ pasl_prop.htarget
		+ sword_hit
		+ float(_cached_mount_props.get("htarget", 0.0))
	)
	roleprop.CritReduce = baseroleprop.CritReduce + equprop.CritReduce + pasl_prop.CritReduce
	roleprop.damage_bonus = (
		float(baseroleprop.get("damage_bonus", 0.0)) + float(_cached_wanling_props.get("damage_bonus", 0.0))
	)
	roleprop.damage_reduction = (
		float(baseroleprop.get("damage_reduction", 0.0)) + float(_cached_wanling_props.get("damage_reduction", 0.0))
	)
	roleprop.ar = baseroleprop.ar + equprop.ar + pasl_prop.ar + zf_ar + float(_cached_wanling_props.get("ar", 0.0))
	roleprop.sp = (
		baseroleprop.sp
		+ equprop.sp
		+ pasl_prop.sp
		+ zf_sp
		+ float(_cached_wanling_props.get("sp", 0.0))
		+ float(_cached_mount_props.get("sp", 0.0))
	)


func set_basic_prop():
	baseroleprop.Level = clampi(int(baseroleprop.Level), 1, int(PlayerData.PLAYER_MAX_LEVEL))
	var max_exp_list = [
		140, 160, 180, 200, 220, 300, 400, 500, 600, 700, 800, 900, 1200, 1400, 1600, 2000, 2400, 3000, 4000, 5000
	]
	match int(PlayerData.player_data["Myself"]):
		1, 7:
			baseroleprop.SHp = 80 + 50 * (baseroleprop.Level - 1)
			baseroleprop.SMp = 50 + 15 * (baseroleprop.Level - 1)
			baseroleprop.power = 8 + 4 * (baseroleprop.Level - 1)
			baseroleprop.Def = 10 + 1 * (baseroleprop.Level - 1)
			baseroleprop.Mdef = 10 + 1 * (baseroleprop.Level - 1)
		2:
			baseroleprop.SHp = 50 + 30 * (baseroleprop.Level - 1)
			baseroleprop.SMp = 100 + 30 * (baseroleprop.Level - 1)
			baseroleprop.power = 15 + 6 * (baseroleprop.Level - 1)
			baseroleprop.Def = 10 + 1 * (baseroleprop.Level - 1)
			baseroleprop.Mdef = 10 + 1 * (baseroleprop.Level - 1)
		3:
			baseroleprop.SHp = 120 + 60 * (baseroleprop.Level - 1)
			baseroleprop.SMp = 25 + 10 * (baseroleprop.Level - 1)
			baseroleprop.power = 15 + 4 * (baseroleprop.Level - 1)
			baseroleprop.Def = 15 + 1 * (baseroleprop.Level - 1)
			baseroleprop.Mdef = 15 + 1 * (baseroleprop.Level - 1)
		4:
			baseroleprop.SHp = 70 + 40 * (baseroleprop.Level - 1)
			baseroleprop.SMp = 70 + 20 * (baseroleprop.Level - 1)
			baseroleprop.power = 15 + 4 * (baseroleprop.Level - 1)
			baseroleprop.Def = 5 + 1 * (baseroleprop.Level - 1)
			baseroleprop.Mdef = 5 + 1 * (baseroleprop.Level - 1)
		5:
			baseroleprop.SHp = 80 + 40 * (baseroleprop.Level - 1)
			baseroleprop.SMp = 50 + 20 * (baseroleprop.Level - 1)
			baseroleprop.power = 10 + 4 * (baseroleprop.Level - 1)
			baseroleprop.Def = 8 + 1 * (baseroleprop.Level - 1)
			baseroleprop.Mdef = 8 + 1 * (baseroleprop.Level - 1)
		6:
			baseroleprop.SHp = 80 + 50 * (baseroleprop.Level - 1)
			baseroleprop.SMp = 50 + 15 * (baseroleprop.Level - 1)
			baseroleprop.power = 8 + 4 * (baseroleprop.Level - 1)
			baseroleprop.Def = 10 + 1 * (baseroleprop.Level - 1)
			baseroleprop.Mdef = 10 + 1 * (baseroleprop.Level - 1)
	if baseroleprop.Level < 20:
		baseroleprop.max_exp = max_exp_list[baseroleprop.Level - 1]
	else:
		baseroleprop.max_exp = 5000 + 5000 * (baseroleprop.Level - 19)
	get_last_prop()
	set_full_hp()
	set_full_mp()


func set_full_hp():
	roleprop.Hp = roleprop.SHp


func set_full_mp():
	roleprop.Mp = roleprop.SMp


func _physics_process(_delta: float) -> void:
	if ws_value >= max_ws_value:
		ws_value = max_ws_value

	if ws_value <= 0:
		is_ws_state = false
		ws_value = 0
	if is_ws_state == true:
		ws_up_power = 1.5
	else:
		ws_up_power = 1
	check_hp()
	check_mp()
	var equipment_signature := hash(
		[
			PlayerData.player_data.get(DataKeys.WEAPON, []),
			PlayerData.player_data.get(DataKeys.ARMOR, []),
			PlayerData.player_data.get("饰品", []),
			PlayerData.player_data.get(DataKeys.FASHION, []),
			PlayerData.player_data.get("神骨", []),
			PlayerData.player_data.get(DataKeys.TITLE, []),
			PlayerData.player_data.get(DataKeys.WINGS, []),
			PlayerData.player_data.get(DataKeys.MAGIC_WEAPON, [])
		]
	)
	if equipment_signature != _equipment_signature:
		_equipment_signature = equipment_signature
		get_equ_last_pro()
	get_last_prop()


func check_hp():
	roleprop.SHp = maxi(1, int(roleprop.SHp))
	if roleprop.Hp >= roleprop.SHp:
		roleprop.Hp = roleprop.SHp
	if roleprop.Hp <= 0:
		roleprop.Hp = 0


func check_mp():
	if roleprop.Mp >= roleprop.SMp:
		roleprop.Mp = roleprop.SMp
	if roleprop.Mp <= 0:
		roleprop.Mp = 0


func up_level():
	if baseroleprop.Level >= int(PlayerData.PLAYER_MAX_LEVEL):
		baseroleprop.Level = int(PlayerData.PLAYER_MAX_LEVEL)
		baseroleprop.exp = 0
		PlayerData.player_data.玩家等级 = baseroleprop.Level
		PlayerData.player_data.玩家当前经验 = 0
		return
	if baseroleprop.exp >= baseroleprop.max_exp:
		if baseroleprop.Level < int(PlayerData.PLAYER_MAX_LEVEL):
			cure_level()


func get_equ_properies():
	if PlayerData.player_data[DataKeys.WEAPON].size() != 0:
		var _name = PlayerData.player_data[DataKeys.WEAPON][0][DataKeys.NAME]
		var qh_level = PlayerData.player_data[DataKeys.WEAPON][0][DataKeys.ENHANCE_LEVEL]
		var data = PlayerData.player_data[DataKeys.WEAPON][0]["Data"]
		var wq_list: Dictionary = AE.get_divine_forge_properties(_name, qh_level, data)
		for i in wq_list.size():
			var loc_1 = wq_list.keys()[i]
			if wq_prop.has(loc_1):
				wq_prop[loc_1] = wq_list[loc_1]
	else:
		remove_wq_pro()

	if PlayerData.player_data[DataKeys.ARMOR].size() != 0:
		var _name = PlayerData.player_data[DataKeys.ARMOR][0][DataKeys.NAME]
		var qh_level = PlayerData.player_data[DataKeys.ARMOR][0][DataKeys.ENHANCE_LEVEL]
		var data = PlayerData.player_data[DataKeys.ARMOR][0]["Data"]
		var fj_list: Dictionary = AE.get_divine_forge_properties(_name, qh_level, data)
		for i in fj_list.size():
			var loc_1 = fj_list.keys()[i]
			if fj_prop.has(loc_1):
				fj_prop[loc_1] = fj_list[loc_1]
	else:
		remove_fj_pro()

	if PlayerData.player_data["饰品"].size() != 0:
		var _name = PlayerData.player_data["饰品"][0][DataKeys.NAME]
		var qh_level = PlayerData.player_data["饰品"][0][DataKeys.ENHANCE_LEVEL]
		var data = PlayerData.player_data["饰品"][0]["Data"]
		var sp_list: Dictionary = AE.get_divine_forge_properties(_name, qh_level, data)
		for i in sp_list.size():
			var loc_1 = sp_list.keys()[i]
			if sp_prop.has(loc_1):
				sp_prop[loc_1] = sp_list[loc_1]
	else:
		remove_sp_pro()

	if PlayerData.player_data[DataKeys.FASHION].size() != 0:
		var _name = PlayerData.player_data[DataKeys.FASHION][0][DataKeys.NAME]
		var qh_level = PlayerData.player_data[DataKeys.FASHION][0][DataKeys.ENHANCE_LEVEL]
		var data = PlayerData.player_data[DataKeys.FASHION][0]["Data"]
		var sz_list = AE.get_last_equ_pro(_name, qh_level, data)
		for i in sz_list.size():
			var loc_1 = sz_list.keys()[i]
			if sz_prop.has(loc_1):
				sz_prop[loc_1] = sz_list[loc_1]
	else:
		remove_sz_pro()

	if PlayerData.player_data[DataKeys.TITLE].size() != 0:
		var _name = PlayerData.player_data[DataKeys.TITLE][0][DataKeys.NAME]
		var qh_level = PlayerData.player_data[DataKeys.TITLE][0][DataKeys.ENHANCE_LEVEL]
		var data = PlayerData.player_data[DataKeys.TITLE][0]["Data"]
		var tx_list = AE.get_last_equ_pro(_name, qh_level, data)
		for i in tx_list.size():
			var loc_1 = tx_list.keys()[i]
			if tx_prop.has(loc_1):
				tx_prop[loc_1] = tx_list[loc_1]
	else:
		remove_tx_pro()

	if PlayerData.player_data[DataKeys.WINGS].size() != 0:
		var _name = PlayerData.player_data[DataKeys.WINGS][0][DataKeys.NAME]
		var qh_level = PlayerData.player_data[DataKeys.WINGS][0][DataKeys.ENHANCE_LEVEL]
		var data = PlayerData.player_data[DataKeys.WINGS][0]["Data"]
		var cb_list = AE.get_last_equ_pro(_name, qh_level, data)
		for i in cb_list.size():
			var loc_1 = cb_list.keys()[i]
			if cb_prop.has(loc_1):
				cb_prop[loc_1] = cb_list[loc_1]
	else:
		remove_cb_pro()

	if PlayerData.player_data[DataKeys.MAGIC_WEAPON].size() != 0:
		var _name = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.NAME]
		var qh_level = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.ENHANCE_LEVEL]
		var wxlist = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.FIVE_ELEMENTS]
		var data = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0]["Data"]
		var fb_list = AE.get_fb_last_equ_pro(_name, qh_level, wxlist, data)
		for i in fb_list.size():
			var loc_1 = fb_list.keys()[i]
			if fb_prop.has(loc_1):
				fb_prop[loc_1] = fb_list[loc_1]
	else:
		remove_fb_pro()

	get_bs_wq_properties()
	get_bs_fj_properties()
	get_bs_sp_properties()
	get_bs_cb_properties()
	get_bs_sz_properties()
	get_bs_tx_properties()


func get_bs_wq_properties():
	for property_name in wq_bs_prop:
		wq_bs_prop[property_name] = 0
	if PlayerData.player_data[DataKeys.WEAPON].size() != 0:
		var equipment: Dictionary = PlayerData.player_data[DataKeys.WEAPON][0]
		var gem_properties: Dictionary = AE.get_divine_forge_gem_properties(
			str(equipment[DataKeys.NAME]), equipment["Data"]
		)
		for property_name in wq_bs_prop:
			wq_bs_prop[property_name] = gem_properties.get(property_name, 0)


func get_bs_fj_properties():
	for property_name in fj_bs_prop:
		fj_bs_prop[property_name] = 0
	if PlayerData.player_data[DataKeys.ARMOR].size() != 0:
		var equipment: Dictionary = PlayerData.player_data[DataKeys.ARMOR][0]
		var gem_properties: Dictionary = AE.get_divine_forge_gem_properties(
			str(equipment[DataKeys.NAME]), equipment["Data"]
		)
		for property_name in fj_bs_prop:
			fj_bs_prop[property_name] = gem_properties.get(property_name, 0)


func get_bs_sp_properties():
	for property_name in sp_bs_prop:
		sp_bs_prop[property_name] = 0
	if PlayerData.player_data["饰品"].size() != 0:
		var equipment: Dictionary = PlayerData.player_data["饰品"][0]
		var gem_properties: Dictionary = AE.get_divine_forge_gem_properties(
			str(equipment[DataKeys.NAME]), equipment["Data"]
		)
		for property_name in sp_bs_prop:
			sp_bs_prop[property_name] = gem_properties.get(property_name, 0)


func get_bs_cb_properties():
	_set_slot_gem_properties("翅膀", cb_bs_prop)


func get_bs_sz_properties():
	_set_slot_gem_properties("时装", sz_bs_prop)


func get_bs_tx_properties():
	_set_slot_gem_properties("头衔", tx_bs_prop)


func _set_slot_gem_properties(slot_name: String, properties: Dictionary) -> void:
	for property_name in AE.prop_list_name:
		properties[property_name] = 0
	var equipped: Array = PlayerData.player_data.get(slot_name, [])
	if equipped.is_empty():
		return
	var equipment: Dictionary = equipped[0]
	var gem_properties := AE.get_divine_forge_gem_properties(
		str(equipment.get(DataKeys.NAME, "")), equipment.get("Data", {})
	)
	for property_name in properties:
		properties[property_name] = gem_properties.get(property_name, 0)


func get_equ_last_pro():
	get_equ_properies()
	var shengu_properties: Dictionary = {}
	var equipped_shengu: Array = PlayerData.ensure_shengu_slot()
	if not equipped_shengu.is_empty() and equipped_shengu[0] is Dictionary:
		var item: Dictionary = equipped_shengu[0]
		shengu_properties = AE.get_divine_forge_properties(
			str(item.get(DataKeys.NAME, "")), int(item.get(DataKeys.ENHANCE_LEVEL, 0)), item.get("Data", {}), true
		)
	for i in equprop.keys():
		equprop[i] = (
			wq_prop[i]
			+ fj_prop[i]
			+ sp_prop[i]
			+ fb_prop[i]
			+ wq_bs_prop[i]
			+ fj_bs_prop[i]
			+ sp_bs_prop[i]
			+ cb_bs_prop[i]
			+ sz_bs_prop[i]
			+ tx_bs_prop[i]
			+ tx_prop[i]
			+ sz_prop[i]
			+ cb_prop[i]
			+ shengu_properties.get(i, 0)
		)


func remove_wq_pro():
	wq_prop.SHp = 0
	wq_prop.SMp = 0
	wq_prop.power = 0
	wq_prop.Def = 0
	wq_prop.Mdef = 0
	wq_prop.Crit = 0
	wq_prop.Miss = 0
	wq_prop.R_hp = 0
	wq_prop.R_mp = 0
	wq_prop.vampirism = 0
	wq_prop.Lucky = 0
	wq_prop.toughness = 0
	wq_prop.htarget = 0
	wq_prop.CritReduce = 0
	wq_prop.ar = 0
	wq_prop.sp = 0
	pass


func remove_fj_pro():
	fj_prop.SHp = 0
	fj_prop.SMp = 0
	fj_prop.power = 0
	fj_prop.Def = 0
	fj_prop.Mdef = 0
	fj_prop.Crit = 0
	fj_prop.Miss = 0
	fj_prop.R_hp = 0
	fj_prop.R_mp = 0
	fj_prop.vampirism = 0
	fj_prop.Lucky = 0
	fj_prop.toughness = 0
	fj_prop.htarget = 0
	fj_prop.CritReduce = 0
	fj_prop.ar = 0
	fj_prop.sp = 0
	pass


func remove_sp_pro():
	sp_prop.SHp = 0
	sp_prop.SMp = 0
	sp_prop.power = 0
	sp_prop.Def = 0
	sp_prop.Mdef = 0
	sp_prop.Crit = 0
	sp_prop.Miss = 0
	sp_prop.R_hp = 0
	sp_prop.R_mp = 0
	sp_prop.vampirism = 0
	sp_prop.Lucky = 0
	sp_prop.toughness = 0
	sp_prop.htarget = 0
	sp_prop.CritReduce = 0
	sp_prop.ar = 0
	sp_prop.sp = 0
	pass


func remove_fb_pro():
	fb_prop.SHp = 0
	fb_prop.SMp = 0
	fb_prop.power = 0
	fb_prop.Def = 0
	fb_prop.Mdef = 0
	fb_prop.Crit = 0
	fb_prop.Miss = 0
	fb_prop.R_hp = 0
	fb_prop.R_mp = 0
	fb_prop.vampirism = 0
	fb_prop.Lucky = 0
	fb_prop.toughness = 0
	fb_prop.htarget = 0
	fb_prop.CritReduce = 0
	fb_prop.ar = 0
	fb_prop.sp = 0


func remove_cb_pro():
	cb_prop.SHp = 0
	cb_prop.SMp = 0
	cb_prop.power = 0
	cb_prop.Def = 0
	cb_prop.Mdef = 0
	cb_prop.Crit = 0
	cb_prop.Miss = 0
	cb_prop.R_hp = 0
	cb_prop.R_mp = 0
	cb_prop.vampirism = 0
	cb_prop.Lucky = 0
	cb_prop.toughness = 0
	cb_prop.htarget = 0
	cb_prop.CritReduce = 0
	cb_prop.ar = 0
	cb_prop.sp = 0


func remove_sz_pro():
	sz_prop.SHp = 0
	sz_prop.SMp = 0
	sz_prop.power = 0
	sz_prop.Def = 0
	sz_prop.Mdef = 0
	sz_prop.Crit = 0
	sz_prop.Miss = 0
	sz_prop.R_hp = 0
	sz_prop.R_mp = 0
	sz_prop.vampirism = 0
	sz_prop.Lucky = 0
	sz_prop.toughness = 0
	sz_prop.htarget = 0
	sz_prop.CritReduce = 0
	sz_prop.ar = 0
	sz_prop.sp = 0


func remove_tx_pro():
	tx_prop.SHp = 0
	tx_prop.SMp = 0
	tx_prop.power = 0
	tx_prop.Def = 0
	tx_prop.Mdef = 0
	tx_prop.Crit = 0
	tx_prop.Miss = 0
	tx_prop.R_hp = 0
	tx_prop.R_mp = 0
	tx_prop.vampirism = 0
	tx_prop.Lucky = 0
	tx_prop.toughness = 0
	tx_prop.htarget = 0
	tx_prop.CritReduce = 0
	tx_prop.ar = 0
	tx_prop.sp = 0


func remove_wq_bs():
	wq_bs_prop.SHp = 0
	wq_bs_prop.SMp = 0
	wq_bs_prop.power = 0
	wq_bs_prop.Def = 0
	wq_bs_prop.Mdef = 0
	wq_bs_prop.Crit = 0
	wq_bs_prop.Miss = 0
	wq_bs_prop.R_hp = 0
	wq_bs_prop.R_mp = 0
	wq_bs_prop.vampirism = 0
	wq_bs_prop.Lucky = 0
	wq_bs_prop.toughness = 0
	wq_bs_prop.htarget = 0
	wq_bs_prop.CritReduce = 0
	wq_bs_prop.ar = 0
	wq_bs_prop.sp = 0


func remove_fj_bs():
	fj_bs_prop.SHp = 0
	fj_bs_prop.SMp = 0
	fj_bs_prop.power = 0
	fj_bs_prop.Def = 0
	fj_bs_prop.Mdef = 0
	fj_bs_prop.Crit = 0
	fj_bs_prop.Miss = 0
	fj_bs_prop.R_hp = 0
	fj_bs_prop.R_mp = 0
	fj_bs_prop.vampirism = 0
	fj_bs_prop.Lucky = 0
	fj_bs_prop.toughness = 0
	fj_bs_prop.htarget = 0
	fj_bs_prop.CritReduce = 0
	fj_bs_prop.ar = 0
	fj_bs_prop.sp = 0


func remove_sp_bs():
	sp_bs_prop.SHp = 0
	sp_bs_prop.SMp = 0
	sp_bs_prop.power = 0
	sp_bs_prop.Def = 0
	sp_bs_prop.Mdef = 0
	sp_bs_prop.Crit = 0
	sp_bs_prop.Miss = 0
	sp_bs_prop.R_hp = 0
	sp_bs_prop.R_mp = 0
	sp_bs_prop.vampirism = 0
	sp_bs_prop.Lucky = 0
	sp_bs_prop.toughness = 0
	sp_bs_prop.htarget = 0
	sp_bs_prop.CritReduce = 0
	sp_bs_prop.ar = 0
	sp_bs_prop.sp = 0


func remove_cb_bs():
	cb_bs_prop.SHp = 0
	cb_bs_prop.SMp = 0
	cb_bs_prop.power = 0
	cb_bs_prop.Def = 0
	cb_bs_prop.Mdef = 0
	cb_bs_prop.Crit = 0
	cb_bs_prop.Miss = 0
	cb_bs_prop.R_hp = 0
	cb_bs_prop.R_mp = 0
	cb_bs_prop.vampirism = 0
	cb_bs_prop.Lucky = 0
	cb_bs_prop.toughness = 0
	cb_bs_prop.htarget = 0
	cb_bs_prop.CritReduce = 0
	cb_bs_prop.ar = 0
	cb_bs_prop.sp = 0


func remove_sz_bs():
	sz_bs_prop.SHp = 0
	sz_bs_prop.SMp = 0
	sz_bs_prop.power = 0
	sz_bs_prop.Def = 0
	sz_bs_prop.Mdef = 0
	sz_bs_prop.Crit = 0
	sz_bs_prop.Miss = 0
	sz_bs_prop.R_hp = 0
	sz_bs_prop.R_mp = 0
	sz_bs_prop.vampirism = 0
	sz_bs_prop.Lucky = 0
	sz_bs_prop.toughness = 0
	sz_bs_prop.htarget = 0
	sz_bs_prop.CritReduce = 0
	sz_bs_prop.ar = 0
	sz_bs_prop.sp = 0


func remove_tx_bs():
	tx_bs_prop.SHp = 0
	tx_bs_prop.SMp = 0
	tx_bs_prop.power = 0
	tx_bs_prop.Def = 0
	tx_bs_prop.Mdef = 0
	tx_bs_prop.Crit = 0
	tx_bs_prop.Miss = 0
	tx_bs_prop.R_hp = 0
	tx_bs_prop.R_mp = 0
	tx_bs_prop.vampirism = 0
	tx_bs_prop.Lucky = 0
	tx_bs_prop.toughness = 0
	tx_bs_prop.htarget = 0
	tx_bs_prop.CritReduce = 0
	tx_bs_prop.ar = 0
	tx_bs_prop.sp = 0


func cure_exp(Exp: int):
	if baseroleprop.Level >= int(PlayerData.PLAYER_MAX_LEVEL):
		baseroleprop.Level = int(PlayerData.PLAYER_MAX_LEVEL)
		baseroleprop.exp = 0
		PlayerData.player_data.玩家等级 = baseroleprop.Level
		PlayerData.player_data.玩家当前经验 = 0
		return
	RoleProp.baseroleprop.exp += Exp
	PlayerData.player_data.玩家当前经验 = RoleProp.baseroleprop.exp


func cure_level():
	if baseroleprop.Level >= int(PlayerData.PLAYER_MAX_LEVEL):
		baseroleprop.Level = int(PlayerData.PLAYER_MAX_LEVEL)
		baseroleprop.exp = 0
		PlayerData.player_data.玩家等级 = baseroleprop.Level
		PlayerData.player_data.玩家当前经验 = 0
		return
	baseroleprop.Level = mini(baseroleprop.Level + 1, int(PlayerData.PLAYER_MAX_LEVEL))
	PlayerData.player_data.玩家等级 = baseroleprop.Level
	baseroleprop.exp = 0
	PlayerData.player_data.玩家当前经验 = 0
	MemoryClass.request_save("level_up")
	set_basic_prop()
