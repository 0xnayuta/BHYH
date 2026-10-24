extends BaseHero
class_name Role3Hero
const BA_DI_QIAN_KUN_EFFECT = preload("res://Script/hero/ba_di_qian_kun_effect.gd")
const STREAMING_ROLE_BULLET = preload("res://Script/hero/streaming_role_bullet.gd")
const BDQK_ACTION_SPEED := 1.4
const BDQK_ACTION_LENGTH := 0.7
const SPECIAL_EFFECT_FRAMES_RES := "res://Art/hero_picture/role_3/runtime_atlas/role_3_special_effects/role_3_special_effects.tres"
const ATLAS_SPECIAL_EFFECTS := [&"Role3SpecialEffect1", &"Role3SpecialEffect16"]
const DGQ_ROLL_SPEED := 900.0
const DGQ_NORMAL_ROLL_SPEED := 600.0
const DGQ_SPIKE_INTERVAL := 0.12
const DGQ_SPIKE_ANGLE_STEP := 30.0
const SD_SKILL_ID := "sd"
const SD_AWAKEN_MP_INTERVAL := 5.0
const SKILL_INPUT_ACTIONS := [&"slz", &"lys", &"lyfb", &"hmz", &"hytj"]
@onready var hurt_box = $base_damagebox/HurtBox/HurtBox
@onready var role3_special_effect: AnimatedSprite2D = $Action/SpecialEffect
var interv: int
var my_sd: Array[RoleSpecialEffect] = []
var syzq = []
var s_yzq
@onready var tmczx: Node2D = $TMCZX
static var _special_effect_frames: SpriteFrames = null
var _dgq_spike_elapsed := 0.0
var _dgq_spike_angle := 0.0
var _sd_awaken_enabled := false
var _sd_awaken_mp_elapsed := 0.0
var _sd_toggle_locked := false
var _sd_awaken_effect: RoleSpecialEffect = null


func _ready() -> void:
	super._ready()
	add_to_group("Player")
	super.on_eqchange()
	role_3()
	_prepare_bdqk_action()
	BA_DI_QIAN_KUN_EFFECT.prewarm_frames()
	STREAMING_ROLE_BULLET.prewarm_bullet_frames("Role3Bullet2")
	_patch_special_effect_frames()


func get_skill(skill_name):
	if str(skill_name) == SD_SKILL_ID and _sd_toggle_locked:
		return
	if str(skill_name) == SD_SKILL_ID and _is_sd_awaken_active() and _sd_awaken_enabled:
		_disable_sd_awaken()
		_sd_toggle_locked = true
		return
	super.get_skill(skill_name)


func _is_auto_battle_skill_active(skill_id: String) -> bool:
	return skill_id == SD_SKILL_ID and _sd_awaken_enabled


func role_3():
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
	self.obj_attack_dict["hit1"] = {
		"power": RoleProp.roleprop.power * randf_range(0.9, 1.1),
		"hurtBack": [3, -8],
		"attackKind": "physics",
		"HitInterv": 3,
		"WSValue": randi_range(5, 7),
	}
	self.obj_attack_dict["hit2"] = {
		"power": RoleProp.roleprop.power * randf_range(1, 1.2),
		"hurtBack": [3, -8],
		"attackKind": "physics",
		"HitInterv": 3,
		"WSValue": randi_range(5, 7),
	}
	self.obj_attack_dict["hit3"] = {
		"power": RoleProp.roleprop.power * randf_range(1, 1.3),
		"hurtBack": [3, -8],
		"attackKind": "physics",
		"HitInterv": 3,
		"WSValue": randi_range(5, 7),
	}
	self.obj_attack_dict["sd"] = {"power": 0, "hurtBack": [0, 0], "attackKind": ""}
	self.obj_attack_dict["zznh"] = {"power": 0, "hurtBack": [0, 0], "attackKind": ""}
	self.obj_attack_dict["dj"] = {
		"power": RoleProp.roleprop.power * (3 + level_2 * 0.3),
		"hurtBack": [25, -20],
		"attackKind": "physics",
		"WSValue": randi_range(25, 30),
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 3 + level_10 * 0.1,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"DeBuff": true
		}
	}
	self.obj_attack_dict["jsp"] = {
		"power": RoleProp.roleprop.power * (1.4 + level_7 * 0.1),
		"hurtBack": [4, -7],
		"attackKind": "physics",
		"WSValue": randi_range(5, 7),
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 0.5 + level_10 * 0.05,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"DeBuff": true
		}
	}
	self.obj_attack_dict["xgq"] = {
		"power": RoleProp.roleprop.power * (1.1 + level_8 * 0.1),
		"hurtBack": [1, -7],
		"attackKind": "physics",
		"WSValue": randi_range(18, 22),
	}
	self.obj_attack_dict["dgq"] = {
		"power": RoleProp.roleprop.power * (1.1 + level_3 * 0.1),
		"hurtBack": [10, 0],
		"attackKind": "physics",
		"WSValue": randi_range(15, 20),
	}
	self.obj_attack_dict["syzq"] = {
		"power": RoleProp.roleprop.power * (2 + level_9 * 0.2),
		"hurtBack": [20, 0],
		"attackKind": "physics",
		"WSValue": 100,
		"addeffect":
		{
			"Name": "stun",
			"AddTime": 2 + level_10 * 0.1,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"DeBuff": true
		}
	}
	self.obj_attack_dict["ssp"] = {
		"power": RoleProp.roleprop.SHp * (0.03 + level_1 * 0.05) + RoleProp.roleprop.power * (0.47 + level_1 * 0.05),
		"hurtBack": [15, -10],
		"attackKind": "physics",
		"WSValue": randi_range(15, 18),
	}
	self.obj_attack_dict["tmc"] = {
		"power": RoleProp.roleprop.SHp * (0.06 + 0.09 * level_5) + RoleProp.roleprop.power * (0.04 + 0.05 * level_5),
		"hurtBack": [0, -8],
		"attackKind": "magic",
		"WSValue": randi_range(5, 7),
	}
	var level_12 = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能12"][DataKeys.LEVEL] + 1
	self.obj_attack_dict["bdqk"] = {
		"power": RoleProp.roleprop.SHp * (0.16 + level_12 * 0.04) + RoleProp.roleprop.power * (0.7 + level_12 * 0.14),
		"hurtBack": [22, -16],
		"attackKind": "physics",
		"WSValue": randi_range(18, 24),
	}


func _physics_process(delta: float) -> void:
	if my_sd.size() > 3:
		if my_sd[0] != null:
			my_sd[0].queue_free()
		my_sd.remove_at(0)

	if self.is_t_mc:
		velocity.x = 0
		if is_on_floor():
			velocity.y = 0
	role_3()
	super._physics_process(delta)
	if _sd_toggle_locked and not _is_any_skill_action_pressed():
		_sd_toggle_locked = false
	if _sd_awaken_enabled and (is_death or not _is_sd_awaken_active()):
		_disable_sd_awaken()
	_process_sd_awaken(delta)
	_process_dgq_spikes(delta)
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
					do_normalhit_1()
				1:
					do_normalhit_2()
				2:
					do_normalhit_3()


func _patch_special_effect_frames() -> void:
	if role3_special_effect == null:
		return
	if _special_effect_frames == null:
		_special_effect_frames = load(SPECIAL_EFFECT_FRAMES_RES) as SpriteFrames
	if _special_effect_frames == null:
		return
	var base_frames := role3_special_effect.sprite_frames
	if base_frames == null:
		return
	var patched := base_frames.duplicate(true) as SpriteFrames
	for action in ATLAS_SPECIAL_EFFECTS:
		if not _special_effect_frames.has_animation(action):
			continue
		if not patched.has_animation(action):
			patched.add_animation(action)
		while patched.get_frame_count(action) > 0:
			patched.remove_frame(action, 0)
		for frame_index in _special_effect_frames.get_frame_count(action):
			patched.add_frame(action, _special_effect_frames.get_frame_texture(action, frame_index))
		patched.set_animation_loop(action, _special_effect_frames.get_animation_loop(action))
	role3_special_effect.sprite_frames = patched


func do_normalhit_1():
	interv = obj_attack_dict["hit1"]["HitInterv"]
	super.get_hit_data("hit1")
	get_action = "hit1"
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
	is_can_move_attack_in_sky()

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
	hit_count = 0
	is_attacking = false
	return


func skill_sd():
	self.role1_skill_inter["sd"] = 1.2

	get_action = "sd"
	is_using_skills = true
	super.get_hit_data("sd")
	is_attacking = true
	role_action_player.play("sd")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func skill_zznh():
	self.role1_skill_inter["zznh"] = 2

	get_action = "zznh"
	is_using_skills = true
	super.get_hit_data("zznh")
	is_attacking = true
	role_action_player.play("zznh")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func skill_dj():
	self.role1_skill_inter["dj"] = 1.2
	velocity.x = 0
	get_action = "dj"
	is_using_skills = true
	super.get_hit_data("dj")
	is_attacking = true
	role_action_player.play("dj")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func skill_jsp():
	self.role1_skill_inter["jsp"] = 6
	velocity.x = 0
	get_action = "jsp"
	is_using_skills = true
	super.get_hit_data("jsp")
	is_attacking = true
	role_action_player.play("jsp")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func skill_ssp():
	self.role1_skill_inter["ssp"] = 4.8
	velocity.x = 0
	get_action = "ssp"
	is_using_skills = true
	super.get_hit_data("ssp")
	is_attacking = true
	role_action_player.play("ssp")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func skill_xgq():
	self.role1_skill_inter["xgq"] = 6
	velocity.x = 0
	get_action = "xgq"
	is_using_skills = true
	super.get_hit_data("xgq")
	is_attacking = true
	role_action_player.play("xgq")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func skill_dgq():
	self.role1_skill_inter["dgq"] = 4.2
	velocity.x = 0
	get_action = "dgq"
	_dgq_spike_elapsed = 0.0
	_dgq_spike_angle = 0.0
	is_using_skills = true
	super.get_hit_data("dgq")
	is_attacking = true
	role_action_player.play("dgq")
	role_action_player.speed_scale = 2.8 if _is_dgq_awaken_active() else 2.0
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func skill_tmc():
	self.is_t_mc = true
	self.role1_skill_inter["tmc"] = 2.4
	velocity.x = 0
	get_action = "tmc"
	is_using_skills = true
	super.get_hit_data("tmc")
	is_attacking = true
	role_action_player.play("tmc")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func skill_tmc2():
	self.role1_skill_inter["tmc"] = 1.2
	velocity.x = 0
	get_action = "tmc"
	is_using_skills = true
	super.get_hit_data("tmc")
	is_attacking = true
	role_action_player.play("tmc2")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func skill_syzq():
	self.role1_skill_inter["syzq"] = 6
	velocity.x = 0
	get_action = "syzq"
	is_using_skills = true
	super.get_hit_data("syzq")
	is_attacking = true
	role_action_player.play("syzq")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func skill_bdqk():
	self.role1_skill_inter["bdqk"] = 3.0
	velocity.x = 0
	get_action = "bdqk"
	is_using_skills = true
	super.get_hit_data("bdqk")
	is_attacking = true
	_play_bdqk_action()
	var level = get_parent().get_parent()
	var effect = BA_DI_QIAN_KUN_EFFECT.new()
	effect.setup(self, player_dir, obj_attack_dict["bdqk"])
	level.add_child(effect)
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func _play_bdqk_action() -> void:
	const ACTION_NAME := &"bdqk_action"
	if _prepare_bdqk_action():
		role_action_player.speed_scale = BDQK_ACTION_SPEED
		role_action_player.play(ACTION_NAME)


func _prepare_bdqk_action() -> bool:
	const ACTION_NAME := &"bdqk_action"
	var library := role_action_player.get_animation_library("")
	if library == null:
		return false
	if library.has_animation(ACTION_NAME):
		var existing_action := library.get_animation(ACTION_NAME)
		if existing_action != null:
			_trim_bdqk_action(existing_action)
		return true
	var source := library.get_animation(&"ssp")
	if source == null:
		return false
	var action := source.duplicate(true) as Animation
	for track_index in range(action.get_track_count() - 1, -1, -1):
		var path := str(action.track_get_path(track_index))
		if path != "Action/RoleBody:frame" and path != "Action/RoleEquipment:frame":
			action.remove_track(track_index)
	_trim_bdqk_action(action)
	library.add_animation(ACTION_NAME, action)
	return true


func _trim_bdqk_action(action: Animation) -> void:
	action.length = BDQK_ACTION_LENGTH


func _on_inter_timeout() -> void:
	interv -= 1


func add_music(idx):
	match idx:
		0:
			Global.add_sound(self, "res://Music/hero/71_role3_hit1.mp3")
		1:
			Global.add_sound(self, "res://Music/hero/70_role3_hit2.mp3")
		2:
			Global.add_sound(self, "res://Music/hero/69_role3_hit3.mp3")
		3:
			Global.add_sound(self, "res://Music/hero/role_3/16_role3_hit5.mp3")
		4:
			Global.add_sound(self, "res://Music/hero/role_3/10_role3_hit8.mp3")
		5:
			Global.add_sound(self, "res://Music/hero/role_3/14_role3_hit7.mp3")
		6:
			Global.add_sound(self, "res://Music/hero/role_3/31_role3_hit6.mp3")
		7:
			Global.add_sound(self, "res://Music/hero/role_3/38_role3_hit9.mp3")
		8:
			Global.add_sound(self, "res://Music/hero/role_3/53_role3_hit4.mp3")
		9:
			Global.add_sound(self, "res://Music/hero/role_3/56_role3_hit10.mp3")
		10:
			Global.add_sound(self, "res://Music/hero/role_3/67_role3_hit11.mp3")
		11:
			Global.add_sound(self, "res://Music/hero/role_3/74_role3_hit12_1.mp3")
		12:
			Global.add_sound(self, "res://Music/hero/role_3/14_role3_hit7.mp3")
		13:
			Global.add_sound(self, "res://Music/hero/role_3/52_role3_hit12_2.mp3")
		14:
			Global.add_sound(self, "res://Music/hero/72_role3_dead.mp3")
		15:
			Global.add_sound(self, "res://Music/hero/role_3/role3_skill_11.wav")
			pass


func add_sd():
	if _is_sd_awaken_active():
		_sd_awaken_enabled = true
		_sd_awaken_mp_elapsed = 0.0
		_sd_toggle_locked = true
		if _sd_awaken_effect == null or not is_instance_valid(_sd_awaken_effect):
			_sd_awaken_effect = Global.add_role_special_effect(self, Vector2(0, -20), false, "sd2")
			if _sd_awaken_effect != null and is_instance_valid(_sd_awaken_effect):
				_sd_awaken_effect.set_meta("persistent_sd", true)
		return
	Global.add_role_special_effect(self, Vector2(0, 0), false, "sd")


func add_zznh():
	var skill_level = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能4"][DataKeys.LEVEL] + 1
	var effect = Global.add_role_special_effect(
		self, Vector2(30, -30) if player_dir else Vector2(-30, -30), false, "zznh"
	)
	effect.skill_level = skill_level
	effect.zznh_defense_reduction = 0.5 if _is_skill_awakened("zznh") and _is_skill_awaken_enabled("zznh") else 0.0


func _on_hit_box_area_entered(area: Area2D) -> void:
	var target = area.get_parent().get_parent()
	if target is BaseMonster:
		if _is_summon_or_pet_target(target):
			return
		if PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能10"][DataKeys.LEVEL] <= 0:
			return
		if get_action == "dj":
			if randi_range(0, 100) > 10 + PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能10"][DataKeys.LEVEL] * 1:
				return
		elif get_action == "jsp":
			if randi_range(0, 100) > PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能10"][DataKeys.LEVEL] * 0.4:
				return
		elif get_action == "syzq":
			if randi_range(0, 100) > 8 + PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能10"][DataKeys.LEVEL] * 0.5:
				return
		else:
			return
		if hit_dic.has("addeffect"):
			Global.add_buff(target.buff, hit_dic["addeffect"])


func call_syzq():
	var pp
	if player_dir:
		pp = Vector2(64, -70) + position
	else:
		pp = Vector2(-64, -70) + position
	Global.add_role_bullet(self.bullet, pp, player_dir, "Role3Bullet1", obj_attack_dict["syzq"])


func add_ssp():
	var bullet_spawn_positions = []
	var scale_list = [Vector2(1, 1), Vector2(1.6, 1.6), Vector2(2, 2), Vector2(2.5, 2.5)]
	if !player_dir:
		bullet_spawn_positions = [Vector2(-70, 15), Vector2(-160, 10), Vector2(-270, 0), Vector2(-400, -10)]
	else:
		bullet_spawn_positions = [Vector2(70, 15), Vector2(160, 10), Vector2(270, 0), Vector2(400, -10)]
	for i in bullet_spawn_positions.size():
		var xbz = Global.add_role_bullet(
			self.bullet, bullet_spawn_positions[i] + position, player_dir, "Role3Bullet2", obj_attack_dict["ssp"]
		)
		xbz.scale = scale_list[i]
		await get_tree().create_timer(0.2, false).timeout


func add_tmc():
	var max_count: int = 10
	if RoleProp.is_ws_state:
		max_count = 20
	var target_count: int = 0
	var tween = create_tween().set_parallel(true)
	while target_count < max_count:
		var new_rotation = 360 / max_count
		new_rotation = new_rotation * target_count
		var stab_position = Vector2(
			self.position.x + sin(float(new_rotation) * PI / 180) * 100,
			self.position.y - 15 - cos(float(new_rotation) * PI / 180) * 100
		)
		var stab = Global.add_role_bullet(self.bullet, stab_position, false, "Role3Bullet3", obj_attack_dict["tmc"])
		stab.rotation_degrees = new_rotation - 90
		stab.modulate = Color(1, 1, 1, 0)
		tween.tween_property(stab, "modulate", Color(1, 1, 1, 1), 0.6)
		target_count += 1

	pass


func _process_dgq_spikes(delta: float) -> void:
	if not _is_dgq_awaken_active() or get_action != "dgq" or not is_using_skills:
		return
	_dgq_spike_elapsed += delta
	while _dgq_spike_elapsed >= DGQ_SPIKE_INTERVAL:
		_dgq_spike_elapsed -= DGQ_SPIKE_INTERVAL
		_spawn_dgq_spike()


func _spawn_dgq_spike() -> void:
	var spike_position := position + Vector2(0.0, -15.0)
	var spike: Node = Global.add_role_bullet(self.bullet, spike_position, false, "Role3Bullet3", obj_attack_dict["tmc"])
	if spike != null and is_instance_valid(spike):
		spike.rotation_degrees = _dgq_spike_angle - 90.0
	_dgq_spike_angle = fmod(_dgq_spike_angle + DGQ_SPIKE_ANGLE_STEP, 360.0)


func rush():
	var roll_speed: float = DGQ_ROLL_SPEED if _is_dgq_awaken_active() else DGQ_NORMAL_ROLL_SPEED
	if player_dir:
		velocity.x += roll_speed
	else:
		velocity.x -= roll_speed


func removetmc():
	self.is_t_mc = false


func _disable_sd_awaken() -> void:
	_sd_awaken_enabled = false
	_sd_awaken_mp_elapsed = 0.0
	is_sd_buff = false
	if _sd_awaken_effect != null and is_instance_valid(_sd_awaken_effect):
		_sd_awaken_effect.queue_free()
	_sd_awaken_effect = null


func _process_sd_awaken(delta: float) -> void:
	if not _sd_awaken_enabled:
		return
	_sd_awaken_mp_elapsed += delta
	if _sd_awaken_mp_elapsed < SD_AWAKEN_MP_INTERVAL:
		return
	_sd_awaken_mp_elapsed -= SD_AWAKEN_MP_INTERVAL
	var mp_cost := int(get_need_mp(SD_SKILL_ID, false))
	if RoleProp.roleprop.Mp < mp_cost:
		_disable_sd_awaken()
		return
	reduce_mp(mp_cost)


func _is_sd_awaken_active() -> bool:
	return _is_skill_awakened(SD_SKILL_ID) and _is_skill_awaken_enabled(SD_SKILL_ID)


func _is_sd_control_reduction_active() -> bool:
	return _sd_awaken_enabled and _is_sd_awaken_active()


func _is_any_skill_action_pressed() -> bool:
	for action_name in SKILL_INPUT_ACTIONS:
		if PlayerInput.is_action_pressed(action_name):
			return true
	return false


func _is_skill_awakened(skill_id: String) -> bool:
	var awaken_data: Variant = PlayerData.player_data.get(DataKeys.Skill.AWAKENED, {})
	return awaken_data is Dictionary and bool(awaken_data.get(skill_id, false))


func _is_skill_awaken_enabled(skill_id: String) -> bool:
	var enabled_data: Variant = PlayerData.player_data.get(DataKeys.Skill.AWAKENED_ENABLED, {})
	if not enabled_data is Dictionary or not enabled_data.has(skill_id):
		return true
	return bool(enabled_data.get(skill_id, false))


func _is_dgq_awaken_active() -> bool:
	return _is_skill_awakened("dgq") and _is_skill_awaken_enabled("dgq")
