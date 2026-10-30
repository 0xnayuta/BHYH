extends BaseHero
class_name Role1Hero

const WUSHUANG_HUOYAN_EFFECT = preload("res://Script/hero/wu_shuang_huo_yan_jin_jing_effect.gd")
const HMZ_AWAKEN_EFFECT = preload("res://Scene/hero/role_special_effect_slim/hmz_awaken_effect.tscn")
const HMZ_AWAKEN_EFFECT_SCRIPT = preload("res://Script/hero/hmz_awaken_effect.gd")
const LYFB_AWAKEN_EFFECT = preload("res://Scene/hero/role_special_effect_slim/lyfb_awaken_effect.tscn")
const LYFB_AWAKEN_EFFECT_SCRIPT = preload("res://Script/hero/lyfb_awaken_effect.gd")
const STREAMING_ROLE_BULLET = preload("res://Script/hero/streaming_role_bullet.gd")
var use_new_hmz: bool = false
var hmz_cooldown_key: String = "hmz"
var hmz_damage_level: int = 1
var hmz_ws_damage_level: int = 1
var use_hmz = false
@onready var hurt_box = $base_damagebox/HurtBox/HurtBox
@onready var lyfb_hit_shape: CollisionShape2D = $base_damagebox/HitBox/HitBox
@onready var lyfb_original_effect: AnimatedSprite2D = $Action/SpecialEffect
@onready var remove_w: Timer = $RemoveW

var is_invincible = false

var is_casting_skill = false

var is_using_hmz = false
var is_hmz_drop = false
var skill
var sky_active = false
var hyjj = []
var interv: int
var shallow_list: Array
var w_is_press: bool
const GSRS_ZZ_ACTION := &"gsrs_zz_action"


func get_gsrs_defense_reduction(adjusted_skill_level: int) -> float:
	return clampf(0.3 + (float(adjusted_skill_level) * 0.064), 0.0, 1.0)


func _ready():
	super._ready()
	add_to_group("Player")
	super.on_eqchange()

	use_new_hmz = false
	role_1()
	_prepare_hyjj_pose_animation()
	_prepare_gsrs_zz_action()


func _prepare_gsrs_zz_action() -> bool:
	if role_action_player.has_animation(GSRS_ZZ_ACTION):
		return true
	var gsrs_source := role_action_player.get_animation(&"gsrs")
	var zz_source := role_action_player.get_animation(&"zz")
	var library := role_action_player.get_animation_library(&"")
	if gsrs_source == null or zz_source == null or library == null:
		return false

	var animation := gsrs_source.duplicate(true) as Animation
	var character_prefixes := [
		"Action/RoleBody:",
		"Action/RoleEquipment:",
		"Action/Wings:",
	]

	for track_index in range(animation.get_track_count() - 1, -1, -1):
		var path := String(animation.track_get_path(track_index))
		for prefix in character_prefixes:
			if path.begins_with(prefix):
				animation.remove_track(track_index)
				break

	var time_scale := animation.length / zz_source.length
	for source_index in range(zz_source.get_track_count()):
		var source_path := String(zz_source.track_get_path(source_index))
		var is_character_track := false
		for prefix in character_prefixes:
			if source_path.begins_with(prefix):
				is_character_track = true
				break
		if not is_character_track:
			continue

		var target_index := animation.add_track(zz_source.track_get_type(source_index))
		animation.track_set_path(target_index, zz_source.track_get_path(source_index))
		animation.track_set_interpolation_type(target_index, zz_source.track_get_interpolation_type(source_index))
		for key_index in range(zz_source.track_get_key_count(source_index)):
			animation.track_insert_key(
				target_index,
				zz_source.track_get_key_time(source_index, key_index) * time_scale,
				zz_source.track_get_key_value(source_index, key_index),
				zz_source.track_get_key_transition(source_index, key_index)
			)

	animation.resource_name = String(GSRS_ZZ_ACTION)
	library.add_animation(GSRS_ZZ_ACTION, animation)
	return true


func set_hmz_version(is_new: bool):
	use_new_hmz = is_new


func set_hmz_cooldown_key(skill_name: String):
	hmz_cooldown_key = skill_name


func set_hmz_damage_level(_level: int, skill_name: String = "hmz"):
	if skill_name == "hmz_ws":
		hmz_ws_damage_level = max(1, _level)
	else:
		hmz_damage_level = max(1, _level)
	refresh_hmz_damage_data(hmz_ws_damage_level if skill_name == "hmz_ws" else hmz_damage_level)


func refresh_hmz_damage_data(_level: int = -1):
	if _level < 1:
		_level = hmz_damage_level
	var level_5 = _level
	self.obj_attack_dict["hmz_1"] = {
		"power": RoleProp.roleprop.power * randf_range(1.02 + (level_5 * 0.15), 1.1 + (level_5 * 0.15)) * 0.65,
		"hurtBack": [2, -6],
		"attackKind": "physics",
		"WSValue": randi_range(6, 8)
	}
	self.obj_attack_dict["hmz-1"] = {
		"power": RoleProp.roleprop.power * randf_range(1.08 + (level_5 * 0.18), 1.16 + (level_5 * 0.18)),
		"hurtBack": [2, -6],
		"attackKind": "physics",
		"WSValue": randi_range(6, 8)
	}
	self.obj_attack_dict["hmz_2"] = {
		"power": RoleProp.roleprop.power * randf_range(1.02 + (level_5 * 0.15), 1.1 + (level_5 * 0.15)),
		"hurtBack": [22, 18],
		"attackKind": "magic",
		"WSValue": randi_range(6, 8)
	}
	self.obj_attack_dict["hmz_3"] = {
		"power": RoleProp.roleprop.power * randf_range(3.5 + (level_5 * 0.5), 3.8 + (level_5 * 0.5)),
		"hurtBack": [3, -28],
		"attackKind": "magic",
		"WSValue": randi_range(10, 15)
	}


func get_hmz_ws_hit_data(action_name: String = "hmz_3") -> Dictionary:
	var skill_data: Variant = PlayerData.player_data.get(DataKeys.SKILL_LEARNED, {})
	var ws_data: Variant = skill_data.get("技能12", {}) if skill_data is Dictionary else {}
	var ws_level := int(ws_data.get(DataKeys.LEVEL, 0)) + 1 if ws_data is Dictionary else 1
	set_hmz_damage_level(ws_level, "hmz_ws")
	var attack_data: Variant = obj_attack_dict.get(action_name, {})
	return attack_data.duplicate(true) if attack_data is Dictionary else {}


func role_1():
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
	var level_11 = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能11"][DataKeys.LEVEL] + 1
	var level_12 = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能12"][DataKeys.LEVEL] + 1
	hmz_ws_damage_level = max(1, level_12)
	if level_10 == 0:
		RoleProp.role1_sxbj = 0
		RoleProp.role1_s_xxx = 0
	else:
		RoleProp.role1_sxbj = 4 + (level_10 - 1) * 1.6
		RoleProp.role1_s_xxx = 0.03 + (level_10 - 1) * 0.003
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
		"power": RoleProp.roleprop.power * randf_range(1, 1.2),
		"hurtBack": [2, 0],
		"attackKind": "physics",
		"HitInterv": 1,
		"WSValue": randi_range(3, 5)
	}
	self.obj_attack_dict["hit4"] = {
		"power": RoleProp.roleprop.power * randf_range(1.2, 1.4),
		"hurtBack": [6, -5],
		"attackKind": "physics",
		"HitInterv": 2,
		"WSValue": randi_range(3, 5)
	}
	self.obj_attack_dict["slz"] = {
		"power": RoleProp.roleprop.power * (2.5 + (level_1 * 0.12)),
		"hurtBack": [6.5, -42],
		"attackKind": "magic",
		"WSValue": randi_range(6, 8)
	}
	self.obj_attack_dict["hytj"] = {
		"power": RoleProp.roleprop.power * (0.25 + (level_2 * 0.02)),
		"hurtBack": [16, -6],
		"attackKind": "magic",
		"WSValue": randi_range(2, 4)
	}
	self.obj_attack_dict["lys"] = {
		"power": 35 + RoleProp.roleprop.power * (0.16 + (level_3 * 0.02)),
		"hurtBack": [1, 1],
		"attackKind": "magic",
		"WSValue": randi_range(15, 20)
	}
	self.obj_attack_dict["lyfb"] = {
		"power": RoleProp.roleprop.power * (0.7 + (level_4 * 0.2)),
		"hurtBack": [9, -5],
		"attackKind": "magic",
		"WSValue": randi_range(6, 8)
	}

	set_hmz_damage_level(level_5, "hmz")

	self.obj_attack_dict["zz"] = {
		"power": RoleProp.roleprop.power * (4 + (level_6 * 0.5)),
		"hurtBack": [19, 0],
		"attackKind": "physics",
		"WSValue": randi_range(15, 18)
	}
	self.obj_attack_dict["gsrs"] = {
		"power": RoleProp.roleprop.power * (4 + (level_11 * 0.5)),
		"hurtBack": [3, 0],
		"attackKind": "physics",
		"addeffect":
		{
			"Name": "defe_reduce",
			"AddTime": 8,
			"reduce_interval": 0,
			"value": get_gsrs_defense_reduction(level_11),
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		},
		"WSValue": randi_range(15, 18)
	}
	self.obj_attack_dict["qsez"] = {
		"power": RoleProp.roleprop.power * (0.07 + (level_7 * 0.02)),
		"hurtBack": [1, 1],
		"attackKind": "physics",
		"WSValue": randi_range(8, 10)
	}
	self.obj_attack_dict["jdy"] = {
		"power": RoleProp.roleprop.power * (0.4 + (level_8 * 0.07)),
		"hurtBack": [35, 0],
		"attackKind": "magic",
		"WSValue": randi_range(8, 10)
	}
	self.obj_attack_dict["jdy_2"] = {
		"power": RoleProp.roleprop.power * (0.4 + (level_8 * 0.07)),
		"hurtBack": [0, -45],
		"attackKind": "magic",
		"WSValue": randi_range(8, 10)
	}
	self.obj_attack_dict["hyjj"] = {
		"power": RoleProp.roleprop.power * (0.5 + (level_9 * 0.15)),
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"WSValue": randi_range(8, 10)
	}
	var level_13 = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能13"][DataKeys.LEVEL] + 1
	self.obj_attack_dict["hyjj_ws"] = {
		"power": RoleProp.roleprop.power * (0.6 + (level_13 * 0.12)),
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"WSValue": randi_range(3, 5)
	}


func _physics_process(delta: float) -> void:
	role_1()
	add_shallow()
	if use_hmz:
		velocity.x = 0
		velocity.y = -10
	if get_action == "hmz":
		hurt_box.disabled = true
	if is_using_hmz:
		gravity = 0
	elif is_hmz_drop:
		gravity = -2280
	else:
		gravity = -980
	if sky_active:
		velocity.y = -10
	super._physics_process(delta)
	if get_action == "lyfb" and _is_skill_awakened("lyfb") and _is_skill_awaken_enabled("lyfb"):
		lyfb_hit_shape.set_deferred("disabled", true)
	if no_limit_buff():
		if PlayerInput.is_action_pressed("Exit"):
			remove_w.start(0.2)
			w_is_press = true
		if w_is_press:
			if (
				not is_riding_mount()
				and PlayerInput.is_action_pressed("normalhit")
				and not is_be_attacking
				and not is_using_skills
				and interv <= 0
			):
				get_skill("slz")
				return
			elif PlayerInput.is_action_pressed("slz") and not is_be_attacking and not is_using_skills and interv <= 0:
				var skill_name = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能键位"]["Y"]
				if skill_name == "jdy":
					get_skill("jdy2")
					return
			elif PlayerInput.is_action_pressed("lys") and not is_be_attacking and not is_using_skills and interv <= 0:
				var skill_name = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能键位"]["U"]
				if skill_name == "jdy":
					get_skill("jdy2")
					return
			elif PlayerInput.is_action_pressed("lyfb") and not is_be_attacking and not is_using_skills and interv <= 0:
				var skill_name = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能键位"]["I"]
				if skill_name == "jdy":
					get_skill("jdy2")
					return
			elif PlayerInput.is_action_pressed("hmz") and not is_be_attacking and not is_using_skills and interv <= 0:
				var skill_name = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能键位"]["O"]
				if skill_name == "jdy":
					get_skill("jdy2")
					return
			elif PlayerInput.is_action_pressed("hytj") and not is_be_attacking and not is_using_skills and interv <= 0:
				var skill_name = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能键位"]["L"]
				if skill_name == "jdy":
					get_skill("jdy2")
					return
		else:
			if (
				not is_riding_mount()
				and PlayerInput.is_action_pressed("normalhit")
				and not is_be_attacking
				and not is_using_skills
				and interv <= 0
			):
				match hit_count:
					0:
						do_normalhit_1()
					1:
						do_normalhit_2()
					2:
						do_normalhit_3()
					3:
						do_normalhit_4()


func turn_to_wait():
	super.turn_to_wait()


func do_normalhit_1():
	interv = obj_attack_dict["hit1"]["HitInterv"]
	super.get_hit_data("hit1")
	get_action = "hit1"
	is_can_move_attack_in_sky()
	is_attacking = true
	role_action_player.play("hit1")
	await role_action_player.animation_finished
	turn_to_wait()
	hit_count = 1
	is_attacking = false
	return


func do_normalhit_2():
	interv = obj_attack_dict["hit2"]["HitInterv"]
	get_action = "hit2"
	super.get_hit_data("hit2")
	velocity.x = 0
	is_attacking = true
	role_action_player.play("hit2")
	await role_action_player.animation_finished
	hit_count = 2
	is_attacking = false
	return


func do_normalhit_3():
	interv = obj_attack_dict["hit3"]["HitInterv"]
	get_action = "hit3"
	super.get_hit_data("hit3")
	velocity.x = 0
	is_attacking = true
	role_action_player.play("hit3")
	await role_action_player.animation_finished
	hit_count = 3
	is_attacking = false
	return


func do_normalhit_4():
	interv = obj_attack_dict["hit4"]["HitInterv"]
	get_action = "hit4"
	super.get_hit_data("hit4")
	velocity.x = 0
	is_attacking = true
	role_action_player.play("hit4")
	await role_action_player.animation_finished
	hit_count = 0
	is_attacking = false
	return


func do_slz():
	self.role1_skill_inter["slz"] = 2.4
	get_action = "slz"
	is_using_skills = true
	super.get_hit_data("slz")
	is_attacking = true
	role_action_player.play("slz")
	Global.get_audio_runtime().add_sound(self, "res://Music/hero/17_role1_hit6.mp3")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func do_hytj():
	self.role1_skill_inter["hytj"] = 3.6
	velocity.x = 0
	if action.scale.x == -1:
		velocity.x += 570
	else:
		velocity.x -= 570
	get_action = "hytj"
	is_using_skills = true
	super.get_hit_data("hytj")
	is_attacking = true
	role_action_player.play("hytj")
	Global.get_audio_runtime().add_sound(self, "res://Music/hero/8_role1_hit6.mp3")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func do_lys():
	self.role1_skill_inter["lys"] = 2.8
	self.role1_skill_inter["hmz"] = 3.6
	velocity.x = 0
	if action.scale.x == -1:
		velocity.x += 1000
	else:
		velocity.x -= 1000
	var lys_awaken_up := (
		_is_skill_awakened("lys") and _is_skill_awaken_enabled("lys") and PlayerInput.is_action_pressed("Exit")
	)
	if lys_awaken_up:
		velocity.x = 0
		velocity.y = -1200

		$Action/SpecialEffect.global_rotation = PI / 2.0
		$base_damagebox/HitBox.global_rotation = PI / 2.0
	get_action = "lys"
	is_using_skills = true
	super.get_hit_data("lys")
	is_attacking = true
	role_action_player.play("lys")
	Global.get_audio_runtime().add_sound(self, "res://Music/hero/11_role1_hit7.mp3")
	await role_action_player.animation_finished
	if lys_awaken_up:
		$Action/SpecialEffect.rotation = 0.0
		$base_damagebox/HitBox.rotation = 0.0
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func do_lyfb():
	self.role1_skill_inter["lyfb"] = 3.2
	if is_on_floor():
		velocity.x = 0
	get_action = "lyfb"
	set_shallowaction("lyfb")
	is_using_skills = true
	super.get_hit_data("lyfb")
	var lyfb_awaken_active := _is_skill_awakened("lyfb") and _is_skill_awaken_enabled("lyfb")
	if lyfb_awaken_active:
		lyfb_original_effect.visible = false
		lyfb_hit_shape.set_deferred("disabled", true)
		var awaken_effect := LYFB_AWAKEN_EFFECT.instantiate()
		awaken_effect.setup(self, player_dir, hit_dic)
		awaken_effect.position = position
		get_parent().add_child(awaken_effect)
	is_attacking = true
	role_action_player.play("lyfb")
	Global.get_audio_runtime().add_sound(self, "res://Music/hero/1_role1_hit9.mp3")
	await role_action_player.animation_finished
	if lyfb_awaken_active:
		lyfb_original_effect.visible = true
		lyfb_hit_shape.set_deferred("disabled", false)
	turn_to_wait()
	is_attacking = false
	is_using_skills = false
	return


func do_zz():
	self.role1_skill_inter["zz"] = 1.2
	velocity.x = 0
	get_action = "zz"
	set_shallowaction("zz")
	is_using_skills = true
	super.get_hit_data("zz")
	is_attacking = true

	role_action_player.play("zz")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false
	return


func do_gsrs():
	self.role1_skill_inter["gsrs"] = 1.2
	velocity.x = 0
	get_action = "gsrs"
	set_shallowaction("gsrs")
	is_using_skills = true
	super.get_hit_data("gsrs")
	is_attacking = true
	role_action_player.play(GSRS_ZZ_ACTION if _prepare_gsrs_zz_action() else &"gsrs")
	Global.get_audio_runtime().add_sound(self, "res://Music/hero/00_role1_gsrs.mp3")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false
	return


func do_wushuang_huoyan_jinjing():
	self.role1_skill_inter["hyjj_ws"] = 6.0
	velocity = Vector2.ZERO
	get_action = "hyjj"
	is_using_skills = true
	is_attacking = true
	_play_hyjj_pose_only()
	var effect := WUSHUANG_HUOYAN_EFFECT.new()
	effect.setup(self, player_dir, self.obj_attack_dict["hyjj_ws"])
	var level := get_parent().get_parent()
	if level != null:
		level.add_child(effect)
	else:
		add_child(effect)
	await get_tree().create_timer(1.77, false).timeout
	if is_inside_tree():
		turn_to_wait()
		is_attacking = false
		is_using_skills = false


func _play_hyjj_pose_only() -> void:
	const POSE_ANIMATION := &"hyjj_ws_pose"
	if _prepare_hyjj_pose_animation():
		role_action_player.play(POSE_ANIMATION)
	else:
		role_action_player.play(&"wait")


func _prepare_hyjj_pose_animation() -> bool:
	const POSE_ANIMATION := &"hyjj_ws_pose"
	if role_action_player.has_animation(POSE_ANIMATION):
		return true
	var source := role_action_player.get_animation(&"hyjj")
	var library := role_action_player.get_animation_library(&"")
	if source == null or library == null:
		return false
	var pose := source.duplicate(true) as Animation
	for track_index in range(pose.get_track_count() - 1, -1, -1):
		var track_path := String(pose.track_get_path(track_index))
		if not (
			track_path.begins_with("Action/RoleBody:")
			or track_path.begins_with("Action/RoleEquipment:")
			or track_path.begins_with("Action/Wings:")
		):
			pose.remove_track(track_index)
	library.add_animation(POSE_ANIMATION, pose)
	return true


func do_hyjj():
	self.role1_skill_inter["hyjj"] = 4.8
	velocity.x = 0
	get_action = "hyjj"
	is_using_skills = true
	super.get_hit_data("hyjj")
	is_attacking = true
	role_action_player.play("hyjj")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false
	return


func do_jdy():
	self.role1_skill_inter["jdy"] = 0
	is_jdy = true
	if action.scale.x == -1:
		velocity.x += 1000
	else:
		velocity.x -= 1000
	velocity.y = 0
	get_action = "jdy"
	is_using_skills = true
	super.get_hit_data("jdy")
	is_attacking = true
	role_action_player.play("jdy")
	is_using_skills = false
	await role_action_player.animation_finished

	turn_to_wait()

	is_attacking = false

	return


func do_jdy_2():
	self.role1_skill_inter["jdy"] = 2.4
	velocity.x = 0
	velocity.y = -1200

	velocity.x = 0
	get_action = "jdy"
	is_using_skills = true
	super.get_hit_data("jdy_2")
	is_attacking = true
	role_action_player.play("jdy_1")
	await role_action_player.animation_finished
	is_jdy = false
	turn_to_wait()
	is_attacking = false
	is_using_skills = false
	return


func do_qsez():
	self.role1_skill_inter["qsez"] = 4.8
	velocity.x = 0
	if action.scale.x == -1:
		velocity.x += 1000
	else:
		velocity.x -= 1000
	get_action = "qsez"
	lyfb_calm = 0.8
	is_using_skills = true
	super.get_hit_data("qsez")
	is_attacking = true
	role_action_player.play("qsez")
	await role_action_player.animation_finished
	self.is_call = false
	is_jdy = false
	turn_to_wait()

	is_attacking = false
	is_using_skills = false
	return


func do_hmz_pro():
	if use_new_hmz:
		pass
		do_hmz_one()
	else:
		do_hmz_pro_old()


func do_hmz_one():
	role_body.self_modulate = Color(1, 1, 1, 0)
	role_eq.self_modulate = Color(1, 1, 1, 0)
	wings.self_modulate = Color(1, 1, 1, 0)
	tx.self_modulate = Color(1, 1, 1, 0)

	is_casting_skill = true
	is_using_skills = true

	velocity.x = 0
	velocity.y = 0
	role_action_player.play("hmz__")
	get_action = "hmz"
	is_attacking = true
	super.get_hit_data("hmz_1")

	Global.get_audio_runtime().add_sound(self, "res://Music/hero/36_role1_hit10_2.mp3")

	const FRONT_OFFSET = 100
	const UP_OFFSET = 100

	var abc
	if player_dir:
		abc = Global.add_special_effect_bullet(
			self.bullet,
			Vector2(position.x + FRONT_OFFSET, position.y - UP_OFFSET),
			Vector2(1.17, 1.17),
			"hmz_1",
			player_dir
		)
	else:
		abc = Global.add_special_effect_bullet(
			self.bullet,
			Vector2(position.x - FRONT_OFFSET, position.y - UP_OFFSET),
			Vector2(1.17, 1.17),
			"hmz_1",
			player_dir
		)
	abc.tt = self

	self.position = abc.position

	is_using_hmz = true
	is_hmz_drop = false

	if not is_inside_tree():
		cleanup_hmz_state()
		return

	var timer = get_tree().create_timer(1.44, false)
	await timer.timeout

	if not is_inside_tree():
		cleanup_hmz_state()
		return

	is_attacking = false
	hurt_box.disabled = true

	is_using_hmz = false
	is_hmz_drop = true

	velocity.y = 2000

	var fall_frames = 0
	while not is_on_floor():
		if not is_inside_tree():
			cleanup_hmz_state()
			return

		await get_tree().physics_frame
		fall_frames += 1

		if fall_frames > 300:
			break

	if not is_inside_tree():
		cleanup_hmz_state()
		return

	is_hmz_drop = false
	velocity.y = 0

	var short_timer = get_tree().create_timer(0.05)
	await short_timer.timeout

	if not is_inside_tree():
		return

	do_hmz_two()


func cleanup_hmz_state():
	hurt_box.disabled = need_protect
	is_using_skills = false
	is_attacking = false
	is_hmz_drop = false
	is_using_hmz = false
	is_invincible = false
	is_casting_skill = false
	_set_protect_visual(need_protect)
	if wings:
		wings.self_modulate = Color(1, 1, 1, 1)
	if tx:
		tx.self_modulate = Color(1, 1, 1, 1)
	turn_to_wait()


func do_hmz_flush():
	do_hmz_two()


func do_hmz_two():
	await get_tree().physics_frame
	self.role1_skill_inter[hmz_cooldown_key] = 4.8

	get_action = "hmz"
	is_attacking = true
	Global.get_audio_runtime().add_sound(self, "res://Music/hero/37_role1_hit10_4.mp3")

	velocity = Vector2.ZERO

	var original_position = position
	position.y -= 0

	super.get_hit_data("hmz_3")

	var sc_x
	var sc_y
	var shake_power
	var shake_time

	if RoleProp.is_ws_state:
		shake_time = 6
		shake_power = 40
		sc_x = 2.2
		sc_y = 3.2
	else:
		shake_time = 5
		shake_power = 30
		sc_x = 1.5
		sc_y = 2.2

	var hmz_awaken_active: bool = (
		_is_skill_awakened("hmz_ws")
		and _is_skill_awaken_enabled("hmz_ws")
		and (hmz_cooldown_key == "hmz_ws" or RoleProp.is_ws_state)
	)
	if hmz_awaken_active:
		var effect_parent: Node = get_parent()
		var awaken_effect := HMZ_AWAKEN_EFFECT.instantiate()
		awaken_effect.setup(self, player_dir, hit_dic)
		awaken_effect.position = position
		effect_parent.add_child(awaken_effect)
	else:
		var abc
		if player_dir:
			abc = Global.add_special_effect_bullet(
				self.bullet, Vector2(position.x + 0, position.y), Vector2(sc_x, sc_y), "hmz_2", player_dir
			)
		else:
			abc = Global.add_special_effect_bullet(
				self.bullet, Vector2(position.x - 0, position.y), Vector2(sc_x, sc_y), "hmz_2", player_dir
			)
		abc.tt = self

	var baselevel = get_parent().get_parent() as BaseLevel
	baselevel._shake_screen(shake_power, shake_time, 0.01)

	await get_tree().create_timer(0.3, false).timeout

	position = original_position

	cleanup_hmz_state()


func _is_skill_awakened(skill_id: String) -> bool:
	var awaken_data: Variant = PlayerData.player_data.get(DataKeys.Skill.AWAKENED, {})
	return awaken_data is Dictionary and bool(awaken_data.get(skill_id, false))


func _is_skill_awaken_enabled(skill_id: String) -> bool:
	var enabled_data: Variant = PlayerData.player_data.get(DataKeys.Skill.AWAKENED_ENABLED, {})
	if not enabled_data is Dictionary or not enabled_data.has(skill_id):
		return true
	return bool(enabled_data.get(skill_id, false))


func do_hmz_pro_old():
	role_body.self_modulate = Color(1, 1, 1, 0)
	role_eq.self_modulate = Color(1, 1, 1, 0)
	velocity.x = 0
	velocity.y = 0
	role_action_player.play("hmz__")
	get_action = "hmz"
	is_using_skills = true
	is_using_hmz = true
	Global.get_audio_runtime().add_sound(self, "res://Music/hero/35_role1_hit10_1.mp3")
	var abc
	var x = 0
	if player_dir:
		abc = Global.add_special_effect_bullet(
			self.bullet, Vector2(position.x + 25, position.y - 80), Vector2(1.15, 1.15), "hmz_pro", !player_dir
		)
		if position.x < abc.position.x + 70:
			velocity.x = 470
		else:
			velocity.x = 0
		if position.y > abc.position.y - 300:
			velocity.y = -850
		else:
			velocity.y = 0
	else:
		abc = Global.add_special_effect_bullet(
			self.bullet, Vector2(position.x - 25, position.y - 80), Vector2(1.15, 1.15), "hmz_pro", !player_dir
		)
		if position.x > abc.position.x - 70:
			velocity.x = -470
		else:
			velocity.x = 0
		if position.y > abc.position.y - 300:
			velocity.y = -850
		else:
			velocity.y = 0
	abc.tt = self

	await get_tree().create_timer(0.26, false).timeout
	if abc != null:
		while abc.is_can_hit == false:
			await get_tree().create_timer(0.01, false).timeout
			x += 1
			if x > 0:
				do_hmz_flush_old()
				return
	do_hmz_one_old()


func do_hmz_one_old():
	velocity.x = 0
	velocity.y = 0
	role_action_player.play("hmz__")
	get_action = "hmz"
	is_attacking = true
	super.get_hit_data("hmz-1")
	Global.get_audio_runtime().add_sound(self, "res://Music/hero/36_role1_hit10_2.mp3")
	role_action_player.play("hmz__")
	var abc
	if player_dir:
		abc = Global.add_special_effect_bullet(
			self.bullet, Vector2(position.x - 25, position.y + 45), Vector2(1.17, 1.17), "hmz-1", player_dir
		)
	else:
		abc = Global.add_special_effect_bullet(
			self.bullet, Vector2(position.x + 25, position.y + 45), Vector2(1.17, 1.17), "hmz-1", player_dir
		)
	abc.tt = self
	await get_tree().create_timer(1.44, false).timeout
	do_hmz_flush_old()


func do_hmz_flush_old():
	velocity.y = 0
	velocity.x = 0
	role_action_player.play("hmz__")
	get_action = "hmz"
	is_attacking = true
	is_using_hmz = false
	is_hmz_drop = true
	super.get_hit_data("hmz_2")
	var abc
	if player_dir == false:
		velocity.x = -walk_speed * 2.7
	else:
		velocity.x = walk_speed * 2.7
	if player_dir:
		abc = Global.add_special_effect_bullet(
			self.bullet, Vector2(position.x + 65, position.y + 90), Vector2(1.1, 1.1), "hmz_flush", !player_dir
		)
	else:
		abc = Global.add_special_effect_bullet(
			self.bullet, Vector2(position.x - 65, position.y + 90), Vector2(1.1, 1.1), "hmz_flush", !player_dir
		)
	abc.tt = self
	role_action_player.play("hmz__")
	await get_tree().create_timer(0.06, false).timeout
	while velocity.y != 0:
		await get_tree().create_timer(0.01, false).timeout
	do_hmz_two_old()


func do_hmz_two_old():
	self.role1_skill_inter[hmz_cooldown_key] = 4.8
	role_action_player.play("hmz__")
	get_action = "hmz"
	is_attacking = true
	Global.get_audio_runtime().add_sound(self, "res://Music/hero/37_role1_hit10_4.mp3")
	velocity.x = 0
	velocity.y = 0
	super.get_hit_data("hmz_3")
	var abc
	var sc_x
	var sc_y
	var shake_power
	var shake_time
	if RoleProp.is_ws_state:
		shake_time = 6
		shake_power = 40
		sc_x = 2.2
		sc_y = 3.2
	else:
		shake_time = 5
		shake_power = 30
		sc_x = 1.5
		sc_y = 2.2
	if player_dir:
		abc = Global.add_special_effect_bullet(
			self.bullet, Vector2(position.x + 0, position.y), Vector2(sc_x, sc_y), "hmz-2", player_dir
		)
	else:
		abc = Global.add_special_effect_bullet(
			self.bullet, Vector2(position.x - 0, position.y), Vector2(sc_x, sc_y), "hmz-2", player_dir
		)
	abc.tt = self

	var baselevel = get_parent().get_parent() as BaseLevel
	baselevel._shake_screen(shake_power, shake_time, 0.01)
	await get_tree().create_timer(0.35, false).timeout
	is_using_skills = false
	is_attacking = false
	is_hmz_drop = false
	_set_protect_visual(need_protect)

	role_action_player.play("hmz__")
	turn_to_wait()


func state_behit():
	super.state_behit()


func fly():
	sky_active = true


func reset():
	sky_active = false
	gravity = -980.0


func add_music(idx):
	match idx:
		0:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/40_role1_hit1_and_hit2.mp3")
		1:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/39_role1_hit3_and_hit4.mp3")
		2:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/38_role1_hit5.mp3")
		3:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/18_role1_hit14.mp3")
		4:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/45_role1_hit12_1.mp3")
		5:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/42_role1_hit11.mp3")
		6:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/26_role1_hit13_1.mp3")
		7:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/59_role1_dead.mp3")


func call_hyjj():
	for i in hyjj:
		if i == null:
			hyjj.erase(i)
	if hyjj.size() < 3:
		hyjj.push_back(Global.add_role_bullet_1(self.bullet, Vector2(100, 0), "hyjj", self.obj_attack_dict["hyjj"]))


func add_shallow():
	var pp = self.get_parent()
	shallow_list = pp.get_children()


func set_shallowaction(action_: String):
	var power = (
		self.obj_attack_dict[action_]["power"]
		* (0.7 + (PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能7"][DataKeys.LEVEL] + 1) * 0.03)
	)
	if shallow_list.size() != 0:
		for i in shallow_list:
			if i != null:
				if i is Role1Shallow:
					i.action = action_
					i.hit_dic = self.obj_attack_dict[action_]
					i.hit_dic["power"] = power


func _on_nor_mal_hit_interv_timeout() -> void:
	interv -= 1


func _on_remove_w_timeout() -> void:
	w_is_press = false


func remove_speed():
	velocity.x = 0
