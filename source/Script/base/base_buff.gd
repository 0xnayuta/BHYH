extends Node

class_name BaseBuff

@onready var buff_time: Timer = $BuffLastTime
@onready var buff_reduce_time: Timer = $BuffValueReduceTime
@onready var specialeffectaddtime: Timer = $SpecialEffectAddTime
@onready var one_second: Timer = $OneSecond

var last_time: float
var get_obj: BaseObject
var get_all_buff: Node
var buff_info = {
	"Name": "",
	"value": 0.0,
	"AddTime": 0.0,
	"reduce_interval": 0.0,
	"AttackKind": "",
	"SpecialEffectAddInterval": 0.0,
	"CanAdd": false
}
var ini_buff = {"Name": "", "value": 0.0, "AddTime": 0.0, "AttackKind": "", "CanRemove": false}
var need_remove: bool
var total_times: int = 1
var inter_time: float
var is_set: bool = false
var on_set: bool = false
var buff_effect_list = []
var buff_array = []
var old_position
var new_position
var ini_speed
var is_check: bool = false
var last_value: float
var _voodoo_visual: Node = null


func _physics_process(_delta: float) -> void:
	if not is_set:
		get_obj = get_parent().get_parent()
		get_all_buff = get_parent()
		if not get_obj is BaseMonster and not get_obj is BaseHero:
			self.queue_free()
			return

		var reduce_control_duration := false
		if get_obj is BaseHero and get_obj.has_method("_is_sd_control_reduction_active"):
			reduce_control_duration = bool(get_obj.call("_is_sd_control_reduction_active"))
		if (
			reduce_control_duration
			and (
				str(buff_info.get("Name", ""))
				in [
					"Ice",
					"stun",
					"EyeFix",
					"DeadLink",
					"Boundground",
					"silent",
					"Immobilize",
					"Scary",
					"hanxiangzisleep"
				]
			)
		):
			buff_info["AddTime"] = float(buff_info.get("AddTime", 0.0)) * 0.5

		last_value = buff_info["value"]
		last_time = buff_info["AddTime"]

		if (
			(get_obj is BaseHero or get_obj is BaseMonster)
			and get_obj.is_white_bar_control_immune()
			and (
				Global.is_monster_control_buff(buff_info.get("Name", ""))
				or buff_info.get("Name", "") == "hanxiangzisleep"
			)
		):
			self.queue_free()
			return
		if (
			get_obj is BaseMonster
			and get_obj.is_control_immune()
			and Global.is_monster_control_buff(buff_info.get("Name", ""))
		):
			self.queue_free()
			return

		if (
			buff_info.get("DeBuff", false)
			and get_obj.no_debuff
			and buff_info["Name"] != "jgz"
			and buff_info["Name"] != "zznh"
		):
			print("NoDeBuff免疫了负面效果: ", buff_info["Name"])
			self.queue_free()
			return

		set_value()
		add_buff_effect_first()
		start_buff()
		is_set = true

		if buff_info["Name"] == "lljybuff" and get_obj != null:
			get_obj.velocity.x = 0

	set_special_buff_time()


func set_value():
	if buff_info["Name"] == "speed_down":
		last_value = normalize_slow_ratio(last_value)
		for other in get_all_buff.get_children():
			if (
				other is BaseBuff
				and other != self
				and not other.is_queued_for_deletion()
				and other.buff_info.get("Name", "") == "speed_down"
			):
				last_value = maxf(last_value, normalize_slow_ratio(other.last_value))
				buff_info["AddTime"] = maxf(
					float(buff_info["AddTime"]),
					float(other.buff_time.time_left) if other.buff_time != null else float(other.last_time)
				)
				other.queue_free()
		return

	var is_special = buff_info["Name"] in ["jgz", "zznh"]
	var is_negative = (
		buff_info["Name"]
		in [
			"poision",
			"Fire",
			"Bleed",
			"stun",
			"Ice",
			"EyeFix",
			"DeadLink",
			"speed_down",
			"silent",
			"Boundground",
			"Immobilize",
			"Scary",
			"defe_reduce",
			"lljybuff",
			"flls",
			"nlls",
			"blood_fix",
			"Voodoo",
			"life_mana_lock",
			"MagicDrain",
			"ReverseMove",
			"hanxiangzisleep",
			"jgz",
			"zznh"
		]
	)

	if is_negative and not is_special:
		if get_obj == null:
			get_obj = get_parent().get_parent()

		if get_obj != null and (get_obj is BaseHero or get_obj is BaseMonster):
			if get_obj.no_debuff:
				print("NoDeBuff免疫负面效果: ", buff_info["Name"])

				call_deferred("queue_free")
				return

	for i in get_all_buff.get_children():
		if i != null:
			if i is BaseBuff:
				match buff_info["Name"]:
					"speed_down", "defe_reduce", "nlls", "slzbuff", "lpzbuff", "tszbuff":
						if i != self and i.buff_info["Name"] == buff_info["Name"]:
							if i.buff_info.has("CanAdd"):
								if i.buff_info["CanAdd"]:
									last_value += i.last_value
									i.queue_free()
								else:
									if i.last_value > last_value:
										last_value = i.last_value
							else:
								if i.last_value > last_value:
									last_value = i.last_value
					"Ice", "stun", "EyeFix", "DeadLink", "Boundground", "silent", "Immobilize", "blood_fix", "life_mana_lock", "Scary", "SuperArmor", "DoubleFallPro", "PoisionBody", "no_debuff", "yxbuff", "HealOverTime":
						if i != self and i.buff_info["Name"] == buff_info["Name"]:
							if i.buff_info.has("CanAdd"):
								if i.buff_info.has("CanAdd"):
									if i.buff_info["CanAdd"]:
										if (
											get_obj is BaseHero
											and (
												buff_info["Name"]
												in [
													"Ice",
													"stun",
													"EyeFix",
													"DeadLink",
													"Boundground",
													"Immobilize",
													"Scary"
												]
											)
										):
											var remaining_time: float = (
												float(i.buff_time.time_left)
												if i.buff_time != null
												else float(i.last_time)
											)
											buff_info["AddTime"] = maxf(float(buff_info["AddTime"]), remaining_time)
										else:
											buff_info["AddTime"] += i.last_time
										i.queue_free()


static func normalize_slow_ratio(value: float) -> float:
	return clampf(absf(value) / 100.0 if absf(value) > 1.0 else absf(value), 0.0, 1.0)


func apply_slow_speed() -> void:
	last_value = normalize_slow_ratio(last_value)
	var multiplier := 1.0 - last_value
	if get_obj is BaseMonster:
		get_obj.speed = get_obj.init_speed * multiplier
	elif get_obj is BaseHero:
		var base_speed: float = get_obj._fabao_jiasu_base_speed * 2 if get_obj.is_fabao_jiasu else 240
		get_obj.walk_speed = base_speed * multiplier


func add_buff_effect_first():
	match buff_info["Name"]:
		"PetLifeBonus", "PetAttackBonus", "PetDefenseBonus", "PetManaBonus":
			refresh_pet_owner_bonus(maxi(0, int(last_value)))
		"jgz":
			pass
		"zznh":
			pass

		"SanXianHuTi":
			inter_time = buff_info.get("SpecialEffectAddInterval", 1.0)

			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, 0), "san_xian_hu_ti", Vector2(1, 1), false, 1)
			)

		"ReverseMove":
			inter_time = 1.0
			if get_obj is BaseHero:
				get_obj.is_reverse_move = true
				buff_effect_list.push_back(
					Global.add_special_effect(get_obj, Vector2(-20, -35), "reverse_move", Vector2(1, 1), false, 1)
				)
			else:
				self.queue_free()

		"MagicDrain":
			inter_time = 1.0
			if get_obj is BaseHero:
				var current_mp = RoleProp.roleprop.Mp
				buff_info["stored_mp"] = current_mp

				get_obj.reduce_mp(current_mp)
				print("MagicDrain触发 | 扣除魔法:", current_mp)

		"flls":
			inter_time = 1
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, 0), "flls", Vector2(1, 1), false, 1)
			)

		"life_mana_lock":
			inter_time = 1

			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, -50), "jinliao", Vector2(1.5, 1.5), false, 1)
			)

		"no_debuff":
			inter_time = 1.0

		"lljybuff":
			inter_time = 0.81

			get_obj.velocity.x = 0

		"lpzbuff":
			if get_obj is BaseMonster:
				var levellpz = PlayerData.player_data["落魄阵"]["Level"]
				get_obj.lpzjs = levellpz * 0.02
			elif get_obj is BaseHero:
				get_obj.xrbl = 1 - last_value
			inter_time = 0.5
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, 5), "lpzbuff", Vector2(1, 1), false, 1)
			)
		"tszbuff":
			if get_obj is BaseHero:
				var levellpz = PlayerData.player_data["腾蛇阵"]["Level"]
				get_obj.tszzs = levellpz * 0.015
			inter_time = 0.6
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, 5), "tszbuff", Vector2(1, 1), false, 1)
			)
		"Scary":
			inter_time = 1
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, -35), "scary", Vector2(1, 1), false, 1)
			)
		"Ice":
			inter_time = 1.29
			buff_effect_list.push_back(Global.add_bullet("bd", get_obj, false, 1, _ice_effect_offset(), "", ""))
		"blood_fix":
			inter_time = 1
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, 15), "three_eyes_fix", Vector2(1, 1), false, 1)
			)
		"life_mana_lock":
			inter_time = 1
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, -50), "jinliao", Vector2(1.5, 1.5), false, 1)
			)
		"defe_reduce":
			inter_time = 0.49
			if get_obj is BaseMonster:
				get_obj.defe_reduce = last_value
			elif get_obj is BaseHero:
				get_obj.defe_reduce = last_value
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(-5, -45), "defe_reduce", Vector2(1, 1), false, 1)
			)
		"Bleed":
			inter_time = 0.36
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, 25), "blood_reduce", Vector2(1, 1), false, 1)
			)
		"poision":
			inter_time = 1
			buff_effect_list.push_back(Global.add_bullet("poision", get_obj, false, 1, Vector2(-20, -55), "", ""))
			buff_effect_list.push_back(Global.add_bullet("posion_fire", get_obj, false, 1, Vector2(10, -40), "", ""))
		"Fire":
			inter_time = 0.81
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(10, 10), "fire", Vector2(1, 1), false, 1)
			)
		"stun":
			inter_time = 0.81
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, -50), "stun", Vector2(0.7, 0.7), false, 1)
			)
		"EyeFix":
			inter_time = 0.45
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, -35), "eye_fix", Vector2(1, 1), false, 1)
			)
		"DeadLink":
			inter_time = 1.39
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, 0), "dead_link_2", Vector2(1, 1), false, 1)
			)
		"nlls":
			inter_time = 1.01
			old_position = get_obj.position.x
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(40, 35), "nlls", Vector2(1, 1), false, 1)
			)
		"silent":
			inter_time = 0.99
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(40, -35), "silent", Vector2(1, 1), false, 1)
			)
		"Boundground":
			inter_time = 0.99
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(-5, 55), "ground_floor", Vector2(1, 1), false, 1)
			)
		"speed_down":
			inter_time = 0.61
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, 20), "speed_down", Vector2(1, 1), false, 1)
			)
			apply_slow_speed()
		"slzbuff":
			if get_obj is BaseHero:
				var levelslz = PlayerData.player_data["森罗阵"]["Level"]
				get_obj.slzjs2 = levelslz * 0.02
			inter_time = 0.875
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, 0), "slzbuff", Vector2(0.5, 1), false, 1)
			)
		"Immobilize":
			inter_time = 0.69
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, 0), "immobilize", Vector2(1, 1), false, 1)
			)
		"SuperArmor":
			pass
		"Indestructible":
			inter_time = 1
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, 0), "indestructible", Vector2(1, 1), false, 1)
			)
		"Indestructible1":
			inter_time = 1
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, 0), "indestructible1", Vector2(1, 1), false, 1)
			)
		"Voodoo":
			inter_time = 0.9
			_add_voodoo_visual_once()
		"DoubleFallPro":
			pass
		"PoisionBody":
			inter_time = 0.5
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, -10), "wdzt", Vector2(0.7, 0.7), false, 1)
			)
		"yxbuff":
			inter_time = 0.8

			if get_obj is BaseHero:
				var current_hp = RoleProp.roleprop.Hp
				var half_hp = int(current_hp * 0.5)
				get_obj.effect_reducehp(half_hp, "real")

				buff_effect_list.push_back(
					Global.add_special_effect(get_obj, Vector2(0, 0), "yxbuff", Vector2(1, 1), false, 1)
				)

		"HealOverTime":
			inter_time = buff_info.get("SpecialEffectAddInterval", 1.0)


func _on_buff_last_time_timeout() -> void:
	match buff_info["Name"]:
		"ReverseMove":
			if get_obj is BaseHero:
				get_obj.reverse_move_speed_multiplier = 1.0
				get_obj.is_reverse_move = false

		"MagicDrain":
			if get_obj is BaseHero:
				var stored_mp = buff_info.get("stored_mp", 0)

				RoleProp.roleprop.Mp += stored_mp

				if RoleProp.roleprop.Mp > RoleProp.roleprop.SMp:
					RoleProp.roleprop.Mp = RoleProp.roleprop.SMp
				print("MagicDrain结束 | 返还魔法:", stored_mp, " | 当前魔法:", RoleProp.roleprop.Mp)

	if str(buff_info.get("AttackKind", "")) == "SpecialBuff_1":
		for i in PlayerData.player_data["初始Buff"]:
			if i["Name"] == buff_info["Name"]:
				PlayerData.player_data["初始Buff"].erase(i)

	if buff_info["AddTime"] < 99999:
		remove_buff()


func _on_buff_value_reduce_time_timeout() -> void:
	match buff_info["Name"]:
		"Ice", "stun", "EyeFix", "DeadLink", "speed_down", "Boundground", "silent", "Immobilize", "Scary", "SuperArmor", "Indestructible", "Indestructible1":
			return
		"defe_reduce", "DoubleFallPro", "slzbuff", "lpzbuff", "tszbuff", "tszbuff", "yxbuff", "MagicDrain":
			return

		"SanXianHuTi":
			return

		"ReverseMove":
			return

		"lljybuff":
			get_obj.velocity.x = 0
			return

		"Bleed", "poision", "Fire", "Voodoo", "hanxiangzisleep":
			if get_obj is BaseHero:
				get_obj.effect_reducehp(last_value, str(buff_info.get("AttackKind", "")))
			elif get_obj is BaseMonster:
				if last_value > 0:
					if buff_info["Name"] == "hanxiangzisleep":
						get_obj.reduce_pet_hp(int(last_value), "real")
					else:
						var hurt = get_obj.get_role_last_hurt(self)
						get_obj.hurt_reduce_hp(hurt, self)

		"flls":
			if get_obj is BaseHero:
				var current_mp = RoleProp.roleprop.Mp
				var reduce_amount = current_mp * 0.1
				reduce_amount = round(reduce_amount)
				if reduce_amount < 1 and current_mp > 0:
					reduce_amount = 1
				print("flls触发 | 当前MP:", current_mp, " | 减少:", reduce_amount, " | 减少后:", current_mp - reduce_amount)
				get_obj.reduce_mp(int(reduce_amount))

		"HealOverTime":
			if get_obj is BaseHero:
				var max_hp = RoleProp.roleprop.SHp
				var heal_amount = int(max_hp * last_value)
				get_obj.effect_reducehp(-heal_amount, "cure")
			elif get_obj is BaseMonster:
				var max_hp = get_obj.max_hp
				var heal_amount = int(max_hp * last_value)
				get_obj.cure_hp(heal_amount)

		"nlls":
			new_position = get_obj.position.x
			if get_obj is BaseHero:
				var get_value_hp = int(abs(new_position - old_position) * last_value * 0.3)
				var get_value_mp = int(abs(new_position - old_position) * last_value * 0.3)
				get_obj.effect_reducehp(get_value_hp, "real")
				RoleProp.roleprop.Mp -= get_value_mp
			elif get_obj is BaseMonster:
				var get_value_hp = abs(new_position - old_position) * last_value
				get_obj.reduce_hp(get_value_hp)
			old_position = get_obj.position.x


func _on_special_effect_add_time_timeout() -> void:
	match buff_info["Name"]:
		"jgz":
			pass
		"zznh":
			pass
		"SanXianHuTi":
			inter_time = buff_info.get("SpecialEffectAddInterval", 1.0)

			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, 0), "san_xian_hu_ti", Vector2(1, 1), false, 1)
			)

		"ReverseMove":
			inter_time = 1.0
			if get_obj is BaseHero:
				buff_effect_list.push_back(
					Global.add_special_effect(get_obj, Vector2(-20, -35), "reverse_move", Vector2(1, 1), false, 1)
				)
				pass

		"MagicDrain":
			pass

		"flls":
			inter_time = 1
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, 0), "flls", Vector2(1, 1), false, 1)
			)

		"tszbuff":
			inter_time = 0.6
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, 5), "tszbuff", Vector2(1, 1), false, 1)
			)
		"lpzbuff":
			inter_time = 0.5
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, 5), "lpzbuff", Vector2(1, 1), false, 1)
			)
		"Ice":
			buff_effect_list.push_back(Global.add_bullet("bd", get_obj, false, 1, _ice_effect_offset(), "", ""))
		"blood_fix":
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, 15), "three_eyes_fix2", Vector2(1, 1), false, 1)
			)
		"life_mana_lock":
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, -50), "jinliao", Vector2(1.5, 1.5), false, 1)
			)
		"Bleed":
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, 25), "blood_reduce", Vector2(1, 1), false, 1)
			)
		"poision":
			buff_effect_list.push_back(Global.add_bullet("posion_fire", get_obj, false, 1, Vector2(10, -40), "", ""))
		"Fire":
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(10, 10), "fire", Vector2(1, 1), false, 1)
			)
		"stun":
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, -50), "stun", Vector2(0.7, 0.7), false, 1)
			)
		"EyeFix":
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, -35), "eye_fix", Vector2(1, 1), false, 1)
			)
		"DeadLink":
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, 0), "dead_link_2", Vector2(1, 1), false, 1)
			)
		"nlls":
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(40, 35), "nlls", Vector2(1, 1), false, 1)
			)
		"speed_down":
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, 20), "speed_down", Vector2(1, 1), false, 1)
			)
		"silent":
			inter_time = 1.01
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(40, -35), "silent", Vector2(1, 1), false, 1)
			)
		"Boundground":
			inter_time = 1.01
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(-5, 55), "ground_floor", Vector2(1, 1), false, 1)
			)
		"Immobilize":
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, 0), "immobilize", Vector2(1, 1), false, 1)
			)
		"Scary":
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, -35), "scary", Vector2(1, 1), false, 1)
			)
		"defe_reduce":
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(-5, -45), "defe_reduce", Vector2(1, 1), false, 1)
			)
		"SuperArmor":
			pass
		"Indestructible":
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, 0), "indestructible", Vector2(1, 1), false, 1)
			)
		"Indestructible1":
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, 0), "indestructible1", Vector2(1, 1), false, 1)
			)
		"DoubleFallPro":
			pass
		"Voodoo":
			_add_voodoo_visual_once()
		"PoisionBody":
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, -10), "wdzt", Vector2(0.7, 0.7), false, 1)
			)
		"slzbuff":
			inter_time = 0.875
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, 0), "slzbuff", Vector2(0.5, 1), false, 1)
			)
		"yxbuff":
			inter_time = 0.8
			buff_effect_list.push_back(
				Global.add_special_effect(get_obj, Vector2(0, 0), "yxbuff", Vector2(1, 1), false, 1)
			)

		"HealOverTime":
			pass


func _ice_effect_offset() -> Vector2:
	if get_obj != null and get_obj.has_method(&"get_ice_effect_offset"):
		var custom_offset: Variant = get_obj.call(&"get_ice_effect_offset")
		if custom_offset is Vector2:
			return custom_offset
	return Vector2(0, 10)


func add_buff_icon():
	if get_obj is BaseHero:
		if Global.buff_box == null:
			return
		var icon = null
		for existing_icon in Global.buff_box.get_children():
			if (
				str(existing_icon.name) == str(buff_info["Name"])
				or str(existing_icon.get("buff_name")) == str(buff_info["Name"])
			):
				icon = existing_icon
				break
		if icon == null:
			icon = Global.add_buff_icon(Global.buff_box, buff_info)
		if icon == null:
			return
		icon.father_buff = self
		icon.total_times = total_times
		icon.last_hurt = last_value
		icon.data_list = buff_info.duplicate(true)
		icon.visible = true
		icon.start_duration(float(buff_info.get("AddTime", 0.0)))
	elif get_obj is BaseMonster:
		if get_obj.my_blood != null:
			for i in get_obj.my_blood.buff_list.get_children():
				if i.buff_name == buff_info["Name"]:
					i.queue_free()
			var icon = Global.add_buff_icon(get_obj.my_blood.buff_list, buff_info)
			icon.father_buff = self
			icon.total_times = total_times
			icon.last_hurt = last_value


func remove_buff():
	_clear_pet_owner_bonus()

	if buff_info["Name"] == "ReverseMove" and get_obj is BaseHero:
		if ini_speed != null:
			get_obj.walk_speed = ini_speed

	for i in buff_effect_list:
		if is_instance_valid(i):
			i.queue_free()
	self.queue_free()


func _exit_tree() -> void:
	for effect in buff_effect_list:
		if is_instance_valid(effect):
			effect.queue_free()
	buff_effect_list.clear()
	if get_obj != null and is_instance_valid(get_obj):
		if get_obj.has_meta("voodoo_effect_owner") and get_obj.get_meta("voodoo_effect_owner") == self:
			get_obj.remove_meta("voodoo_effect_owner")
			if get_obj.has_meta("voodoo_effect_visual"):
				get_obj.remove_meta("voodoo_effect_visual")
	_clear_pet_owner_bonus()


func _add_voodoo_visual_once() -> void:
	if get_obj == null or not is_instance_valid(get_obj):
		return
	var existing: Variant = get_obj.get_meta("voodoo_effect_visual", null)
	var visual_active: bool = is_instance_valid(existing) and not existing.is_queued_for_deletion()
	if visual_active:
		return
	var effect: Node = Global.add_special_effect(get_obj, Vector2(0, -35), "voodoo", Vector2(1, 1), false, 1) as Node
	if effect == null:
		return
	_voodoo_visual = effect
	buff_effect_list.push_back(effect)
	get_obj.set_meta("voodoo_effect_owner", self)
	get_obj.set_meta("voodoo_effect_visual", effect)


func refresh_pet_owner_bonus(value: int) -> void:
	var bonus := maxi(0, value)
	match str(buff_info.get("Name", "")):
		"PetLifeBonus":
			var old_life := int(RoleProp.pet_life_bonus)
			RoleProp.pet_life_bonus = bonus
			RoleProp.roleprop.Hp = int(RoleProp.roleprop.get("Hp", 0)) + maxi(0, bonus - old_life)
		"PetAttackBonus":
			RoleProp.pet_attack_bonus = bonus
		"PetDefenseBonus":
			RoleProp.pet_defense_bonus = bonus
			RoleProp.pet_magic_defense_bonus = maxi(0, int(buff_info.get("magic_value", bonus)))
		"PetManaBonus":
			var old_mana := int(RoleProp.pet_mana_bonus)
			RoleProp.pet_mana_bonus = bonus
			RoleProp.roleprop.Mp = int(RoleProp.roleprop.get("Mp", 0)) + maxi(0, bonus - old_mana)
		_:
			return
	add_buff_icon()


func _clear_pet_owner_bonus() -> void:
	match str(buff_info.get("Name", "")):
		"PetLifeBonus":
			RoleProp.pet_life_bonus = 0
		"PetAttackBonus":
			RoleProp.pet_attack_bonus = 0
		"PetDefenseBonus":
			RoleProp.pet_defense_bonus = 0
			RoleProp.pet_magic_defense_bonus = 0
		"PetManaBonus":
			RoleProp.pet_mana_bonus = 0


func start_buff():
	buff_time.start(float(buff_info["AddTime"]))
	if buff_info.has("reduce_interval"):
		buff_reduce_time.start(float(buff_info["reduce_interval"]))
	specialeffectaddtime.start(inter_time)


func set_special_buff_time():
	if PlayerData.player_data["初始Buff"].size() <= 0:
		return
	for i in PlayerData.player_data["初始Buff"]:
		if i["Name"] == buff_info["Name"]:
			i["AddTime"] = buff_time.time_left


func _on_one_second_timeout() -> void:
	pass
