extends BaseHero
class_name Role4Hero
const BI_LUO_TIAN_EFFECT = preload("res://Script/hero/bi_luo_tian_effect.gd")
const CANG_MU_LONG_YUN_EFFECT = preload("res://Script/hero/cang_mu_long_yun_effect.gd")
const ROLE4_POISON_ARRAY_AWAKEN_EFFECT = preload("res://Script/hero/role4_poison_array_awaken_effect.gd")
const WDZT_SKILL_ID := "wdzt"
const WDZT_AWAKEN_MP_INTERVAL := 5.0
const WDWW_AWAKEN_TARGET_LIMIT := 4
const LHSQ_AWAKEN_BONUS_PER_STACK := 0.2
const LHSQ_AWAKEN_MAX_STACKS := 5
const LHSQ_AWAKEN_DURATION := 10.0
const SKILL_INPUT_ACTIONS := [&"slz", &"lys", &"lyfb", &"hmz", &"hytj"]
var wdww: Monster138
@onready var hurt_box = $base_damagebox/HurtBox/HurtBox
var interv: int
var is_fly: bool
var jdz
var tkj_awaken_mode: int = 0
var _wdzt_awaken_enabled := false
var _wdzt_awaken_mp_elapsed := 0.0
var _wdzt_toggle_locked := false
var lhsq_awaken_stacks: int = 0
var lhsq_awaken_time_left: float = 0.0


func _ready() -> void:
	super._ready()

	add_to_group("Player")
	super.on_eqchange()
	role_4()


func _exit_tree() -> void:
	temp_max_hp_bonus_rate = 0.0
	temp_power_bonus_rate = 0.0
	if RoleProp.source_player == self:
		RoleProp.get_last_prop()
		RoleProp.check_hp()
	super._exit_tree()


func ws_skill() -> bool:
	if RoleProp.is_ws_state:
		return false
	RoleProp.is_ws_state = true
	var activated := super.ws_skill()
	if not activated:
		RoleProp.is_ws_state = false
	return activated


func get_skill(skill_name):
	if str(skill_name) == WDZT_SKILL_ID and _wdzt_toggle_locked:
		return
	if str(skill_name) == WDZT_SKILL_ID and _is_wdzt_awaken_active() and _wdzt_awaken_enabled:
		_disable_wdzt_awaken()
		_wdzt_toggle_locked = true
		return
	super.get_skill(skill_name)


func _is_auto_battle_skill_active(skill_id: String) -> bool:
	return skill_id == WDZT_SKILL_ID and _wdzt_awaken_enabled


func role_4():
	RoleProp.role1_sxbj = 0
	RoleProp.role1_s_xxx = 0

	if not is_in_group("Player"):
		add_to_group("Player")
	var level_1 = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能1"][DataKeys.LEVEL] + 1
	var level_2 = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能2"][DataKeys.LEVEL] + 1
	var level_3 = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能3"][DataKeys.LEVEL] + 1
	var level_4 = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能4"][DataKeys.LEVEL] + 1
	var level_5 = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能5"][DataKeys.LEVEL] + 1
	var level_6 = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能6"][DataKeys.LEVEL] + 1
	var level_7 = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能7"][DataKeys.LEVEL] + 1
	var level_8 = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能8"][DataKeys.LEVEL] + 1
	var level_9 = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能9"][DataKeys.LEVEL] + 1
	var level_10 = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能10"][DataKeys.LEVEL]
	var level_11 = max(1, int(PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能11"][DataKeys.LEVEL]))
	var level_12 = max(1, int(PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能12"][DataKeys.LEVEL]))
	self.obj_attack_dict["hit1"] = {
		"power": RoleProp.roleprop.power * randf_range(1, 1.2),
		"hurtBack": [2, 0],
		"attackKind": "physics",
		"HitInterv": 1,
		"WSValue": randi_range(3, 5)
	}
	self.obj_attack_dict["hit2"] = {
		"power": RoleProp.roleprop.power * randf_range(0.9, 1.1),
		"hurtBack": [2, 0],
		"attackKind": "physics",
		"HitInterv": 1,
		"WSValue": randi_range(3, 5)
	}
	self.obj_attack_dict["hit3"] = {
		"power": RoleProp.roleprop.power * randf_range(0.9, 1.1),
		"hurtBack": [2, -2],
		"attackKind": "physics",
		"HitInterv": 1,
		"WSValue": randi_range(3, 5)
	}
	self.obj_attack_dict["qlj"] = {
		"power": RoleProp.roleprop.power * (2.5 + (level_1 * 0.4)),
		"hurtBack": [20, -8],
		"attackKind": "physics",
		"WSValue": randi_range(30, 34)
	}
	self.obj_attack_dict["dcj"] = {
		"power": RoleProp.roleprop.power * (0.6 + (level_2 * 0.3)),
		"hurtBack": [8, -6],
		"attackKind": "magic",
		"WSValue": randi_range(12, 15)
	}
	self.obj_attack_dict["tkj"] = {
		"power": 35 + RoleProp.roleprop.power * (3 + (level_4 * 0.5)),
		"hurtBack": [1, -45],
		"attackKind": "physics",
		"WSValue": randi_range(15, 20)
	}
	var mmw_attack := {
		"power": RoleProp.roleprop.power * (2 + (level_5 * 0.2)),
		"hurtBack": [-4, -2],
		"attackKind": "magic",
		"WSValue": randi_range(10, 12)
	}
	if (
		_is_skill_awakened("mmw")
		and _is_skill_awaken_enabled("mmw")
		and PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能10"][DataKeys.LEVEL] > 0
	):
		mmw_attack["addeffect"] = {
			"Name": "Voodoo",
			"AddTime": 5,
			"reduce_interval": 1,
			"value": int(RoleProp.roleprop.power * 0.1),
			"CanAdd": true,
			"AttackKind": "real",
			"DeBuff": true
		}
	self.obj_attack_dict["mmw"] = mmw_attack
	self.obj_attack_dict["bylt"] = {
		"power": RoleProp.roleprop.power * (1.8 + (level_11 - 1) * 0.25),
		"hurtBack": [2, -3],
		"attackKind": "magic",
		"WSValue": 4
	}
	self.obj_attack_dict["cmly"] = {
		"power": RoleProp.roleprop.power * (1.8 + (level_12 - 1) * 0.25),
		"hurtBack": [2, -3],
		"attackKind": "magic",
		"WSValue": 4
	}
	if PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能10"][DataKeys.LEVEL] > 0:
		self.obj_attack_dict["jdz"] = {
			"power": RoleProp.roleprop.power * (1.5 + (level_6 * 0.1)),
			"hurtBack": [0, 0],
			"attackKind": "magic",
			"WSValue": randi_range(6, 8),
			"addeffect":
			{
				"Name": "Voodoo",
				"AddTime": 5,
				"reduce_interval": 1,
				"value": int(RoleProp.roleprop.power * 0.1),
				"CanAdd": true,
				"AttackKind": "real",
				"DeBuff": true
			}
		}
		self.obj_attack_dict["zq"] = {
			"power": RoleProp.roleprop.power * (0.7 + (level_8 * 0.2)),
			"hurtBack": [2, -6],
			"attackKind": "magic",
			"WSValue": randi_range(8, 10),
			"addeffect":
			{
				"Name": "Voodoo",
				"AddTime": 5,
				"reduce_interval": 1,
				"value": int(RoleProp.roleprop.power * 0.1),
				"CanAdd": true,
				"AttackKind": "real",
				"DeBuff": true
			}
		}
		self.obj_attack_dict["lhsq"] = {
			"power": RoleProp.roleprop.power * (1.35 + (level_7 * 0.1)),
			"hurtBack": [-12, -6],
			"attackKind": "magic",
			"WSValue": randi_range(8, 10),
			"addeffect":
			{
				"Name": "Voodoo",
				"AddTime": 5,
				"reduce_interval": 1,
				"value": int(RoleProp.roleprop.power * 0.1),
				"CanAdd": true,
				"AttackKind": "real",
				"DeBuff": true
			}
		}
	else:
		self.obj_attack_dict["jdz"] = {
			"power": RoleProp.roleprop.power * (1 + (level_6 * 0.1)),
			"hurtBack": [0, 0],
			"attackKind": "magic",
			"WSValue": randi_range(6, 8),
		}
		self.obj_attack_dict["zq"] = {
			"power": RoleProp.roleprop.power * (1 + (level_8 * 0.1)),
			"hurtBack": [2, -6],
			"attackKind": "magic",
			"WSValue": randi_range(8, 10),
		}
		self.obj_attack_dict["lhsq"] = {
			"power": RoleProp.roleprop.power * (1.35 + (level_7 * 0.1)),
			"hurtBack": [-12, -6],
			"attackKind": "magic",
			"WSValue": randi_range(8, 10),
		}


func _physics_process(delta: float) -> void:
	if is_fly:
		gravity = 0
	else:
		gravity = -980.0
	role_4()
	super._physics_process(delta)
	if _wdzt_toggle_locked and not _is_any_skill_action_pressed():
		_wdzt_toggle_locked = false
	_process_wdzt_awaken(delta)
	_process_lhsq_awaken(delta)
	if no_limit_buff():
		if (
			not is_riding_mount()
			and PlayerInput.is_action_pressed("normalhit")
			and not is_be_attacking
			and not is_using_skills
			and interv <= 0
		):
			match hit_count:
				0:
					shovel_hit_1()
				1:
					shovel_hit_2()
				2:
					shovel_hit_3()


func shovel_hit_1():
	super.get_hit_data("hit1")
	get_action = "hit1"
	velocity.x = 0
	is_attacking = true
	role_action_player.play("hit1_1")
	await role_action_player.animation_finished
	turn_to_wait()
	hit_count = 1
	is_attacking = false
	return


func shovel_hit_2():
	super.get_hit_data("hit2")
	get_action = "hit2"
	is_can_move_attack_in_sky()
	is_attacking = true
	role_action_player.play("hit2_1")
	await role_action_player.animation_finished
	turn_to_wait()
	hit_count = 2
	is_attacking = false
	return


func shovel_hit_3():
	super.get_hit_data("hit3")
	get_action = "hit3"
	if player_dir:
		velocity.x = 180
	else:
		velocity.x = -180
	is_attacking = true
	role_action_player.play("hit3_1")
	await role_action_player.animation_finished
	turn_to_wait()
	hit_count = 0
	is_attacking = false
	return


func shovel_qlj():
	self.role1_skill_inter["qlj"] = 4.8
	velocity.x = 0
	get_action = "qlj"
	is_using_skills = true
	super.get_hit_data("qlj")
	is_attacking = true
	role_action_player.play("qlj_1")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func shovel_dcj():
	self.role1_skill_inter["dcj"] = 4.8
	velocity.x = 0
	get_action = "dcj"
	is_using_skills = true
	super.get_hit_data("dcj")
	is_attacking = true
	role_action_player.play("dcj_1")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func shovel_tkj():
	self.role1_skill_inter["tkj"] = 2.4
	var tkj_awakened: bool = _is_skill_awakened("tkj") and _is_skill_awaken_enabled("tkj")
	tkj_awaken_mode = 2 if tkj_awakened and PlayerInput.is_action_pressed("Exit") else (1 if tkj_awakened else 0)
	if tkj_awaken_mode == 1:
		velocity.x = 600.0 if player_dir else -600.0
		velocity.y = 0.0
		$Action/SpecialEffect1.global_rotation = -PI / 2.0
		$base_damagebox/HitBox.global_rotation = -PI / 2.0
	elif tkj_awaken_mode == 2:
		velocity = Vector2(0.0, -600.0)
		$Action/SpecialEffect1.rotation = 0.0
		$base_damagebox/HitBox.rotation = 0.0
	get_action = "tkj"
	is_using_skills = true
	super.get_hit_data("tkj")
	if tkj_awaken_mode != 0:
		hit_dic = hit_dic.duplicate(true)
		hit_dic["hurtBack"] = [0, 0]
	is_attacking = true
	role_action_player.play("tkj_1")
	await role_action_player.animation_finished
	if tkj_awaken_mode != 0:
		velocity = Vector2.ZERO
		$Action/SpecialEffect1.rotation = 0.0
		$base_damagebox/HitBox.rotation = 0.0
	tkj_awaken_mode = 0
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func shovel_mmw():
	self.role1_skill_inter["mmw"] = 3
	velocity.x = 0
	get_action = "mmw"
	is_using_skills = true
	super.get_hit_data("mmw")
	is_attacking = true
	role_action_player.play("mmw_1")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func shovel_zq():
	self.role1_skill_inter["zq"] = 4.8
	velocity.x = 0
	get_action = "zq"
	is_using_skills = true
	super.get_hit_data("zq")
	is_attacking = true
	role_action_player.play("zq_1")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func shovel_wdww():
	self.role1_skill_inter["wdww"] = 4.8
	if is_on_floor():
		velocity.x = 0
	get_action = "wdww"
	is_using_skills = true
	is_attacking = true
	role_action_player.play("wdww_2")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func shovel_bylt():
	self.role1_skill_inter["bylt"] = 6.0
	velocity.x = 0
	get_action = "bylt"
	is_using_skills = true
	is_attacking = true
	role_action_player.play("jdz")
	var level = get_parent().get_parent()
	var effect = BI_LUO_TIAN_EFFECT.new()
	effect.setup(self, player_dir, obj_attack_dict["bylt"])
	level.add_child(effect)
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func shovel_cmly():
	self.role1_skill_inter["cmly"] = 3.0
	velocity.x = 0
	get_action = "cmly"
	is_using_skills = true
	is_attacking = true
	role_action_player.speed_scale = 1.0
	role_action_player.play("jdz")
	var level = get_parent().get_parent()
	var effect = CANG_MU_LONG_YUN_EFFECT.new()
	effect.setup(self, player_dir, obj_attack_dict["cmly"])
	level.add_child(effect)
	await get_tree().create_timer(0.5, false).timeout
	if role_action_player.current_animation == "jdz":
		role_action_player.stop()
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func shovel_mbyj():
	self.role1_skill_inter["lhsq"] = 4.8
	velocity.x = 0
	get_action = "lhsq"
	is_using_skills = true
	super.get_hit_data("lhsq")
	is_attacking = true
	role_action_player.play("mbyj")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func shovel_jdz():
	self.role1_skill_inter["jdz"] = 6
	velocity.x = 0
	get_action = "jdz"
	is_using_skills = true
	super.get_hit_data("jdz")
	is_attacking = true
	role_action_player.play("jdz")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func shovel_wdzt():
	self.role1_skill_inter["wdzt"] = 4
	if is_on_floor():
		velocity.x = 0
	get_action = "wdzt"
	is_using_skills = true
	is_attacking = true
	if _is_wdzt_awaken_active():
		_wdzt_awaken_enabled = true
		_wdzt_awaken_mp_elapsed = 0.0
		_wdzt_toggle_locked = true
	role_action_player.play("wdzt")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func add_shovel_effect_1():
	var bullet_pos = Vector2()
	if player_dir:
		bullet_pos = Vector2(35, 0)
	else:
		bullet_pos = Vector2(-35, 0)
	Global.add_role_bullet(self.bullet, bullet_pos + position, !player_dir, "Role4Bullet3", obj_attack_dict["mmw"])
	if _is_skill_awakened("mmw") and _is_skill_awaken_enabled("mmw"):
		Global.add_role_bullet(self.bullet, bullet_pos + position, player_dir, "Role4Bullet3", obj_attack_dict["mmw"])


func addmbyj():
	Global.add_role4_bullet(self.bullet, self, position)


func call_wdww():
	var bullet_pos: Vector2
	if player_dir:
		bullet_pos = Vector2(30, -30)
	else:
		bullet_pos = Vector2(-30, -30)
	if wdww != null:
		wdww.queue_free()
	var target_limit := (
		WDWW_AWAKEN_TARGET_LIMIT if _is_skill_awakened("wdww") and _is_skill_awaken_enabled("wdww") else 1
	)
	var targets := _get_wdww_targets(target_limit)
	if targets.is_empty():
		return
	var target: BaseMonster = targets[0]
	wdww = Global.create_monster(138, get_parent().get_parent().monster, position + bullet_pos) as Monster138
	if wdww == null:
		return
	wdww.max_hp = target.max_hp * (0.25 + PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能9"][DataKeys.LEVEL] * 0.02)
	wdww.hp = wdww.max_hp
	wdww.set_linked_targets(targets)


func call_jdz():
	if get_action == "bylt" or get_action == "cmly":
		return
	if jdz != null:
		jdz.queue_free()
	jdz = Global.add_role_bullet(self.bullet, position + Vector2(0, 30), false, "Role4Bullet6", obj_attack_dict["jdz"])
	if jdz != null:
		jdz.start_auto_free(10)
		if _is_skill_awakened("jdz") and _is_skill_awaken_enabled("jdz"):
			var level = get_parent().get_parent()
			var effect := ROLE4_POISON_ARRAY_AWAKEN_EFFECT.new()
			effect.setup(self, player_dir, obj_attack_dict["jdz"], jdz)
			level.add_child(effect)


func add_wdzt():
	for i in buff.get_children():
		if i != null:
			if i.buff_info["Name"] == "PoisionBody":
				i.queue_free()
	(
		Global
		. add_buff(
			self.buff,
			{
				"Name": "PoisionBody",
				"AddTime": 99999 if _wdzt_awaken_enabled and _is_wdzt_awaken_active() else 6,
				"reduce_interval": 0,
				"value": 0,
				"CanAdd": false,
				"CanRemove": false,
				"AttackKind": "",
			}
		)
	)


func _process_wdzt_awaken(delta: float) -> void:
	if not _wdzt_awaken_enabled:
		return
	if is_death or not _is_wdzt_awaken_active():
		_disable_wdzt_awaken()
		return
	_wdzt_awaken_mp_elapsed += delta
	if _wdzt_awaken_mp_elapsed < WDZT_AWAKEN_MP_INTERVAL:
		return
	_wdzt_awaken_mp_elapsed -= WDZT_AWAKEN_MP_INTERVAL
	var mp_cost := int(get_need_mp(WDZT_SKILL_ID, false))
	if RoleProp.roleprop.Mp < mp_cost:
		_disable_wdzt_awaken()
		return
	reduce_mp(mp_cost)


func _disable_wdzt_awaken() -> void:
	if not _wdzt_awaken_enabled:
		return
	_wdzt_awaken_enabled = false
	_wdzt_awaken_mp_elapsed = 0.0
	for child in buff.get_children():
		if (
			child != null
			and child.get("buff_info") is Dictionary
			and str(child.buff_info.get("Name", "")) == "PoisionBody"
		):
			child.queue_free()
	is_wdzt = false


func _is_wdzt_awaken_active() -> bool:
	return _is_skill_awakened(WDZT_SKILL_ID) and _is_skill_awaken_enabled(WDZT_SKILL_ID)


func _add_lhsq_awaken_stack() -> void:
	if not _is_lhsq_awaken_active():
		return
	lhsq_awaken_time_left = LHSQ_AWAKEN_DURATION
	if lhsq_awaken_stacks >= LHSQ_AWAKEN_MAX_STACKS:
		return
	var old_max_hp := int(RoleProp.roleprop.SHp)
	lhsq_awaken_stacks += 1
	_refresh_lhsq_awaken_stats()
	RoleProp.roleprop.Hp += maxi(0, int(RoleProp.roleprop.SHp) - old_max_hp)
	RoleProp.check_hp()


func _process_lhsq_awaken(delta: float) -> void:
	if lhsq_awaken_stacks <= 0:
		return
	if is_death or not _is_lhsq_awaken_active():
		_clear_lhsq_awaken_bonus()
		return
	lhsq_awaken_time_left = maxf(0.0, lhsq_awaken_time_left - delta)
	if lhsq_awaken_time_left <= 0.0:
		_clear_lhsq_awaken_bonus()


func _refresh_lhsq_awaken_stats() -> void:
	var bonus_rate := float(lhsq_awaken_stacks) * LHSQ_AWAKEN_BONUS_PER_STACK
	temp_max_hp_bonus_rate = bonus_rate
	temp_power_bonus_rate = bonus_rate
	RoleProp.get_last_prop()


func _clear_lhsq_awaken_bonus() -> void:
	lhsq_awaken_stacks = 0
	lhsq_awaken_time_left = 0.0
	temp_max_hp_bonus_rate = 0.0
	temp_power_bonus_rate = 0.0
	RoleProp.get_last_prop()
	RoleProp.check_hp()


func _is_lhsq_awaken_active() -> bool:
	return _is_skill_awakened("lhsq") and _is_skill_awaken_enabled("lhsq")


func _is_any_skill_action_pressed() -> bool:
	for action_name in SKILL_INPUT_ACTIONS:
		if PlayerInput.is_action_pressed(action_name):
			return true
	return false


func get_monster():
	var targets := _get_wdww_targets(1)
	return targets[0] if not targets.is_empty() else null


func _get_wdww_targets(limit: int) -> Array[BaseMonster]:
	var targets: Array[BaseMonster] = []
	var monster_list = get_parent().get_parent().monster.get_children()
	for i in monster_list:
		if not _is_valid_wdww_target(i):
			continue
		targets.append(i as BaseMonster)
	targets.sort_custom(_sort_wdww_targets_by_hp)
	if targets.size() > limit:
		targets.resize(limit)
	return targets


func _sort_wdww_targets_by_hp(left: BaseMonster, right: BaseMonster) -> bool:
	return left.hp > right.hp


func _is_valid_wdww_target(target: Node) -> bool:
	if not _is_valid_role4_skill_target(target):
		return false
	if target is Monster138 or target is Monster133:
		return false
	if target is Monster49 or target is Monster50:
		return not target.is_stop
	return true


func _is_valid_role4_skill_target(target: Node) -> bool:
	if target == null:
		return false
	if not is_instance_valid(target):
		return false
	if not (target is BaseMonster):
		return false
	if target.hp <= 0:
		return false
	if target.no_target:
		return false
	if target.get_meta("pet_tiger_unit", false) or target.get_meta("is_summon", false):
		return false
	return true


func add_music(num: int):
	match int(num):
		1:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/role_4/shovel_hit1.mp3")
		2:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/role_4/shovel_hit2.mp3")
		3:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/role_4/shovel_hit3.mp3")
		4:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/role_4/arrow_hit1.mp3")
		5:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/role_4/arrow_hit2.mp3")
		6:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/role_4/shovelqlj.mp3")
		7:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/role_4/arrowqlj.mp3")
		8:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/role_4/shoveldcj.mp3")
		9:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/role_4/arrowdcj.mp3")
		10:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/role_4/shovelmmw.mp3")
		11:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/role_4/arrowmmw.mp3")
		12:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/role_4/shovelzq.mp3")
		13:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/role_4/arrowzq.mp3")
		14:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/role_4/arrowtkj.mp3")
		15:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/role_4/jdz.mp3")
		16:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/role_4/lhsq.mp3")
		17:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/role_4/mds.mp3")
		18:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/role_4/wdww.mp3")
		19:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/role_4/effect6_repeat.mp3")


func _on_nor_mal_hit_interv_timeout() -> void:
	interv -= 1


func to_top():
	if player_dir:
		velocity = Vector2(-750, -800)
	else:
		velocity = Vector2(750, -800)


func remove_speed():
	velocity = Vector2(0, 0)


func rush():
	if player_dir:
		velocity.x = 600
	else:
		velocity.x = -600


func fly_top():
	if tkj_awaken_mode == 1:
		velocity.y = 0.0
		return
	if tkj_awaken_mode == 2:
		velocity = Vector2(0.0, -600.0)
		return
	velocity.y = 0
	velocity.y = -600


func to_top_2():
	is_fly = true
	if player_dir:
		velocity = Vector2(0, -1800)
	else:
		velocity = Vector2(0, -1800)


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if is_death or need_protect:
		return
	is_in_sky = false
	c_ure_cure_count = 0
	cure_value = 1
	idle_count = 0

	Global.get_run_context().count_hurt()
	var target = area.get_parent().get_parent()
	var monster_target: BaseMonster
	monster_target = check_monster(area)
	if target == null or monster_target == null:
		return
	if target.obj_attack_dict.size() == 0:
		return
	if monster_target is Monster47:
		Global.player_be_hit_count += 1
	var last_hit = get_monster_last_hurt(monster_target, target) * (1 - slzjs) * (1 - slzjs2)
	if monster_target != null:
		if monster_target.is_lpz:
			var levellpz = PlayerData.player_data["落魄阵"]["Level"]
			monster_target.lpzjs = levellpz * 0.01
			last_hit *= (1 - monster_target.lpzjs)
	var total_cure_monster = int(monster_target.ebol * last_hit)
	monster_target.cure_hp(total_cure_monster)
	if self.is_wdzt:
		var reduec_hurt = int(
			last_hit * (0.7 - PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能3"][DataKeys.LEVEL] * 0.02)
		)
		var cure_hurt = last_hit - reduec_hurt
		last_hit = reduec_hurt
		if randi_range(0, 100) < 20:
			cure_hp(cure_hurt)
	if monster_target != null:
		monster_target.total_hit += last_hit
		if monster_target is Monster141:
			effect_reducehp(int(RoleProp.roleprop.SHp * 0.01), "real")
			Global.add_monster141_aura(self.bullet, self.position, monster_target)
		if self.is_wdzt:
			if Global.check_wd(monster_target, self) < 7:
				Global.add_buff(
					monster_target.buff,
					{
						"Name": "Voodoo",
						"AddTime": 5,
						"reduce_interval": 1,
						"value": int(RoleProp.roleprop.power * 0.1),
						"CanAdd": true,
						"CanRemove": false,
						"AttackKind": "real",
						"DeBuff": true,
						"source_player": self
					}
				)
	Global.get_run_context().add_damage_taken(int(last_hit))
	if not is_miss:
		Global.get_audio_runtime().add_sound(self, "res://Music/hero/68_role3_be_attack.mp3")
		Global.add_mr_hurt(pz, Vector2(5, -20))
		if not is_t_mc:
			_add_role_protect(randi_range(3, 7))
	if is_miss or RoleProp.is_ws_state or super_armor_active or is_wdzt or need_protect:
		is_be_attacking = false
	else:
		be_hit_back(monster_target, target)
		_queue_hit_stiff(monster_target, target)
		state_behit()
	reduce_hp(last_hit, monster_target, target)


func _prepare_hit_reaction() -> void:
	is_fly = false


func fall():
	is_fly = false


func _on_hit_box_area_entered(area: Area2D) -> void:
	if get_action == "lhsq":
		var mm = area.get_parent().get_parent()
		var cure_value: float = 1
		cure_value += 0.3 * float(RoleProp.roleprop.SHp - RoleProp.roleprop.Hp) / float(RoleProp.roleprop.SHp)
		if mm is BaseMonster and not _is_summon_or_pet_target(mm):
			var cure_power = (
				obj_attack_dict["lhsq"]["power"]
				* (0.2 + (PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能7"][DataKeys.LEVEL]) * 0.03)
				* cure_value
			)
			cure_hp(cure_power)
			_add_lhsq_awaken_stack()
	if obj_attack_dict.has(get_action):
		if obj_attack_dict[get_action].has("addeffect"):
			var monster = area.get_parent().get_parent()
			if monster != null:
				if monster is BaseMonster and not _is_summon_or_pet_target(monster):
					var effect: Dictionary = obj_attack_dict[get_action]["addeffect"]
					if str(effect.get("Name", "")) == "Voodoo":
						if Global.check_wd(monster, self) < 7:
							var sourced_effect := effect.duplicate(true)
							sourced_effect["source_player"] = self
							Global.add_buff(monster.buff, sourced_effect)
					else:
						Global.add_buff(monster.buff, effect)


func _is_skill_awakened(skill_id: String) -> bool:
	var awaken_data: Variant = PlayerData.player_data.get(DataKeys.Skill.AWAKENED, {})
	return awaken_data is Dictionary and bool(awaken_data.get(skill_id, false))


func _is_skill_awaken_enabled(skill_id: String) -> bool:
	var enabled_data: Variant = PlayerData.player_data.get(DataKeys.Skill.AWAKENED_ENABLED, {})
	if not enabled_data is Dictionary or not enabled_data.has(skill_id):
		return true
	return bool(enabled_data.get(skill_id, false))
