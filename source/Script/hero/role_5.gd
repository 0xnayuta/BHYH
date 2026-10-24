extends BaseHero
class_name Role5Hero
const LEI_TING_JIE_ZHEN_EFFECT = preload("res://Script/hero/lei_ting_jie_zhen_effect.gd")
const FHF_NORMAL_COOLDOWN := 9.0
const FHF_AWAKEN_COOLDOWN := FHF_NORMAL_COOLDOWN / 3.0
const FHF_PRE_END := 0.3
const FHF_ACTIVE_END := 0.5
const FHF_TIMING_REDUCTION := 3.0
const FHF_AWAKEN_ACTION := &"fhf_awaken"
const YGTH_AWAKEN_ACTION := &"ygth_awaken"
const YGTH_NORMAL_COOLDOWN := 14.0
const YGTH_AWAKEN_COOLDOWN := 4.8
const YGTH_AWAKEN_DAMAGE_MULTIPLIER := 3.0
const YGTH_AWAKEN_SCALE := Vector2(2.0, 2.0)

@onready var hurt_box = $base_damagebox/HurtBox/HurtBox

var interv: int
var in_sky: bool
var tllz
var can_move_in_sky: bool
var role5_eat_blood: float


func _ready() -> void:
	super._ready()
	_fix_dragon_prince_title_animation()

	add_to_group("Player")
	super.on_eqchange()
	role_5()
	_prepare_fhf_awaken_action()
	_prepare_ygth_awaken_action()
	_prepare_ltjz_action()


func _fix_dragon_prince_title_animation() -> void:
	var title_sprite := get_node_or_null("tx") as AnimatedSprite2D
	if title_sprite == null or title_sprite.sprite_frames == null:
		return
	var title_atlas := load("res://Art/all_tx/lwstz.png") as Texture2D
	if title_atlas == null:
		return

	var frames := title_sprite.sprite_frames
	if frames.has_animation(&"lwstz"):
		frames.clear(&"lwstz")
	else:
		frames.add_animation(&"lwstz")
	for frame_index in range(15):
		var frame_texture := AtlasTexture.new()
		frame_texture.atlas = title_atlas
		frame_texture.region = Rect2(float(frame_index % 6) * 208.0, float(frame_index / 6) * 80.0, 208.0, 80.0)
		frames.add_frame(&"lwstz", frame_texture)
	frames.set_animation_speed(&"lwstz", 15.0)
	frames.set_animation_loop(&"lwstz", true)
	_last_title_name = ""
	add_tx()


func role_5():
	PlayerData.ensure_skill_data()

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
	role5_eat_blood = level_10 * 0.05
	RoleProp.role1_sxbj = 0
	RoleProp.role1_s_xxx = 0
	self.obj_attack_dict["hit1"] = {
		"power": RoleProp.roleprop.power * randf_range(1, 1.2),
		"hurtBack": [1, 0],
		"attackKind": "physics",
		"HitInterv": 1,
		"WSValue": randi_range(3, 5)
	}
	self.obj_attack_dict["hit2"] = {
		"power": RoleProp.roleprop.power * randf_range(0.9, 1.1),
		"hurtBack": [1, 0],
		"attackKind": "physics",
		"HitInterv": 1,
		"WSValue": randi_range(3, 5)
	}
	self.obj_attack_dict["hit3"] = {
		"power": RoleProp.roleprop.power * randf_range(1, 1.2),
		"hurtBack": [1, 0],
		"attackKind": "physics",
		"HitInterv": 1,
		"WSValue": randi_range(3, 5)
	}
	self.obj_attack_dict["hit4"] = {
		"power": RoleProp.roleprop.power * randf_range(1.2, 1.4),
		"hurtBack": [2, -3],
		"attackKind": "physics",
		"HitInterv": 2,
		"WSValue": randi_range(3, 5)
	}
	self.obj_attack_dict["xyq"] = {
		"power": RoleProp.roleprop.power * (0.3 + (level_1 * 0.2)),
		"hurtBack": [1, -2],
		"attackKind": "physics",
		"WSValue": randi_range(6, 8)
	}
	self.obj_attack_dict["xyq_1"] = {
		"power": RoleProp.roleprop.power * (1.5 + (level_1 * 0.2)),
		"hurtBack": [25, -18],
		"attackKind": "physics",
		"WSValue": randi_range(6, 8)
	}
	self.obj_attack_dict["slq"] = {
		"power": RoleProp.roleprop.power * (2 + (level_2 * 0.12)),
		"hurtBack": [2, -40],
		"attackKind": "physics",
		"WSValue": randi_range(6, 8)
	}
	self.obj_attack_dict["blq"] = {
		"power": RoleProp.roleprop.power * (0.5 + (level_3 * 0.2)),
		"hurtBack": [30, -6],
		"attackKind": "magic",
		"WSValue": randi_range(6, 8)
	}
	self.obj_attack_dict["fhf"] = {
		"power": RoleProp.roleprop.power * (3 + (level_4 * 0.2)),
		"hurtBack": [-25, -25],
		"attackKind": "physics",
		"WSValue": randi_range(8, 10)
	}
	self.obj_attack_dict["cxq"] = {
		"power": RoleProp.roleprop.power * (0.5 + (level_5 * 0.02)),
		"hurtBack": [1, -6],
		"attackKind": "physics",
		"WSValue": randi_range(2, 4)
	}
	self.obj_attack_dict["cxq_2"] = {
		"power": 35 + RoleProp.roleprop.power * (1.5 + (level_5 * 0.02)),
		"hurtBack": [30, -18],
		"attackKind": "physics",
		"WSValue": randi_range(15, 20)
	}
	self.obj_attack_dict["llrd"] = {
		"power": RoleProp.roleprop.power * (3 + (level_6 * 0.2)),
		"hurtBack": [1, -1],
		"attackKind": "magic",
		"WSValue": randi_range(20, 25)
	}
	self.obj_attack_dict["lljy_1"] = {
		"power": 0,
		"hurtBack": [1, 0],
		"attackKind": "magic",
		"WSValue": 0,
		"addeffect":
		{
			"Name": "lljybuff",
			"AddTime": 1.2,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		}
	}
	self.obj_attack_dict["lljy"] = {
		"power": RoleProp.roleprop.power * (0.1 + (level_7 * 0.01)),
		"hurtBack": [1, -1],
		"attackKind": "magic",
		"WSValue": randi_range(8, 10)
	}
	self.obj_attack_dict["ygth"] = {
		"power": RoleProp.roleprop.power * (0.7 + (level_8 * 0.01)),
		"hurtBack": [1, -6],
		"attackKind": "physics",
		"WSValue": randi_range(8, 10)
	}
	self.obj_attack_dict["tllz"] = {
		"power": RoleProp.roleprop.power * (2.5 + (level_9 * 0.01)),
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"WSValue": randi_range(8, 10)
	}
	self.obj_attack_dict["ltjz"] = {
		"power": RoleProp.roleprop.power * (2.3 + (level_11 - 1) * 0.25),
		"hurtBack": [2, -5],
		"attackKind": "magic",
		"WSValue": randi_range(6, 9)
	}
	self.obj_attack_dict["yyb"] = {"power": 0, "hurtBack": [0, 0], "attackKind": "magic", "WSValue": 5}


func _physics_process(delta: float) -> void:
	role_5()
	if in_sky:
		gravity = 0
	else:
		gravity = -980.0
	if interv > 0:
		interv -= 1
	super._physics_process(delta)
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
				3:
					do_normalhit_4()
				4:
					do_normalhit_5()
	else:
		self.can_move_when_use_skill = false
		in_sky = false
		self.role5_bt = false


func do_normalhit_1():
	interv = obj_attack_dict["hit1"]["HitInterv"]
	super.get_hit_data("hit1")
	get_action = "hit1"
	velocity.x = 0
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


func do_normalhit_5():
	interv = obj_attack_dict["hit3"]["HitInterv"]
	get_action = "hit5"
	super.get_hit_data("hit3")
	is_can_move_attack_in_sky()
	is_attacking = true
	role_action_player.play("hit5")
	await role_action_player.animation_finished
	hit_count = 0
	is_attacking = false
	return


func use_slq():
	self.role1_skill_inter["slq"] = 4.8
	velocity.x = 0
	get_action = "slq"
	is_using_skills = true
	super.get_hit_data("slq")
	is_attacking = true
	role_action_player.play("slq")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func use_cxq():
	self.role1_skill_inter["cxq"] = 14
	velocity.x = 0
	get_action = "cxq"
	is_using_skills = true
	super.get_hit_data("cxq")
	is_attacking = true
	role_action_player.play("cxq")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func use_blq():
	self.role1_skill_inter["blq"] = 6
	velocity.x = 0
	get_action = "blq"
	is_using_skills = true
	super.get_hit_data("blq")
	is_attacking = true
	role_action_player.play("blq")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func use_xyq():
	self.role1_skill_inter["xyq"] = 6
	velocity.x = 0
	get_action = "xyq"
	is_using_skills = true
	super.get_hit_data("xyq")
	is_attacking = true
	role_action_player.play("xyq")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func use_llrd():
	self.role1_skill_inter["llrd"] = 6
	velocity.x = 0
	get_action = "llrd"
	is_using_skills = true
	super.get_hit_data("llrd")
	is_attacking = true
	role_action_player.play("llrd")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func use_lljy():
	self.role1_skill_inter["lljy"] = 12
	velocity.x = 0
	get_action = "lljy_1"
	is_using_skills = true
	super.get_hit_data("lljy_1")
	is_attacking = true
	role_action_player.play("lljy")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func use_tllz():
	self.role1_skill_inter["tllz"] = 6
	velocity.x = 0
	get_action = "tllz"
	is_using_skills = true
	super.get_hit_data("tllz")
	is_attacking = true
	role_action_player.play("tllz")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func use_ygth():
	var awakened := _is_skill_awakened("ygth") and _is_skill_awaken_enabled("ygth")
	self.role1_skill_inter["ygth"] = YGTH_AWAKEN_COOLDOWN if awakened else YGTH_NORMAL_COOLDOWN
	velocity.x = 0
	get_action = "ygth"
	is_using_skills = true
	super.get_hit_data("ygth")
	is_attacking = true
	var action_name := YGTH_AWAKEN_ACTION if awakened and _prepare_ygth_awaken_action() else &"ygth"
	role_action_player.play(action_name)
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func _prepare_ygth_awaken_action() -> bool:
	var library := role_action_player.get_animation_library("")
	if library == null:
		return false
	if library.has_animation(YGTH_AWAKEN_ACTION):
		return true
	if library.get_animation(&"ygth") == null:
		return false

	var action := Animation.new()
	action.length = 0.6
	_add_ygth_value_track(
		action, NodePath("Action/RoleBody:frame"), [0.0, 0.1, 0.2, 0.3, 0.4], [120, 121, 122, 123, 124]
	)
	_add_ygth_value_track(
		action, NodePath("Action/RoleEquipment:frame"), [0.0, 0.1, 0.2, 0.3, 0.4], [120, 121, 122, 123, 124]
	)
	_add_ygth_value_track(action, NodePath("RolePlayer:speed_scale"), [0.0], [1.0], Animation.UPDATE_CONTINUOUS)
	_add_ygth_value_track(action, NodePath("base_damagebox/HitBox/HitBox:disabled"), [0.0], [true])
	_add_ygth_value_track(action, NodePath("base_damagebox/HurtBox/HurtBox:disabled"), [0.0], [false])
	_add_ygth_value_track(action, NodePath("Action/Wings:flip_h"), [0.0], [false])
	_add_ygth_value_track(action, NodePath("Action/Wings:visible"), [0.0], [true])
	_add_ygth_value_track(
		action,
		NodePath("Action/Wings:position"),
		[0.0, 0.1, 0.2, 0.3],
		[Vector2(55, -47), Vector2(57, -62), Vector2(57, -62), Vector2(3, -41)],
		Animation.UPDATE_CONTINUOUS
	)
	_add_ygth_value_track(
		action,
		NodePath("Action/Wings:rotation"),
		[0.0, 0.1, 0.2, 0.3],
		[0.286045, 0.286045, 0.286045, -0.542254],
		Animation.UPDATE_CONTINUOUS
	)
	_add_ygth_method_key(action, 0.0, &"role_5_skill_bt")
	_add_ygth_method_key(action, 0.0, &"remove_yspeed")
	_add_ygth_method_key(action, 0.0, &"in_the_sky")
	_add_ygth_method_key(action, 0.0, &"add_music", [16])
	_add_ygth_method_key(action, 0.05, &"call_ygth_awaken_bullet")
	_add_ygth_method_key(action, 0.2, &"call_ygth_awaken_bullet")
	_add_ygth_method_key(action, 0.35, &"call_ygth_awaken_bullet")
	_add_ygth_method_key(action, 0.59, &"role_5_skill_bt_over")
	_add_ygth_method_key(action, 0.59, &"no_in_the_sky")
	library.add_animation(YGTH_AWAKEN_ACTION, action)
	return true


func _add_ygth_value_track(
	action: Animation,
	path: NodePath,
	times: Array,
	values: Array,
	update_mode: Animation.UpdateMode = Animation.UPDATE_DISCRETE
) -> void:
	var track_index := action.add_track(Animation.TYPE_VALUE)
	action.track_set_path(track_index, path)
	action.value_track_set_update_mode(track_index, update_mode)
	for key_index in range(mini(times.size(), values.size())):
		action.track_insert_key(track_index, float(times[key_index]), values[key_index])


func _add_ygth_method_key(action: Animation, time: float, method_name: StringName, args: Array = []) -> void:
	var track_index := action.add_track(Animation.TYPE_METHOD)
	action.track_set_path(track_index, NodePath("."))
	action.track_insert_key(track_index, time, {"method": method_name, "args": args})


func use_fhf():
	var awakened := _is_skill_awakened("fhf") and _is_skill_awaken_enabled("fhf")
	self.role1_skill_inter["fhf"] = FHF_AWAKEN_COOLDOWN if awakened else FHF_NORMAL_COOLDOWN
	velocity.x = 0
	get_action = "fhf"
	is_using_skills = true
	super.get_hit_data("fhf")
	is_attacking = true
	var action_name := FHF_AWAKEN_ACTION if awakened and _prepare_fhf_awaken_action() else &"fhf"
	role_action_player.play(action_name)
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func _prepare_fhf_awaken_action() -> bool:
	var library := role_action_player.get_animation_library("")
	if library == null:
		return false
	if library.has_animation(FHF_AWAKEN_ACTION):
		return true
	var source := library.get_animation(&"fhf")
	if source == null:
		return false
	var action := source.duplicate(true) as Animation
	for track_index in range(action.get_track_count()):
		for key_index in range(action.track_get_key_count(track_index)):
			var key_time := action.track_get_key_time(track_index, key_index)
			action.track_set_key_time(track_index, key_index, _remap_fhf_awaken_time(key_time))
	action.length = _remap_fhf_awaken_time(source.length)
	library.add_animation(FHF_AWAKEN_ACTION, action)
	return true


func _remap_fhf_awaken_time(time: float) -> float:
	if time <= FHF_PRE_END:
		return time / FHF_TIMING_REDUCTION
	if time <= FHF_ACTIVE_END:
		return FHF_PRE_END / FHF_TIMING_REDUCTION + (time - FHF_PRE_END)
	var shortened_pre := FHF_PRE_END / FHF_TIMING_REDUCTION
	var active_duration := FHF_ACTIVE_END - FHF_PRE_END
	return shortened_pre + active_duration + (time - FHF_ACTIVE_END) / FHF_TIMING_REDUCTION


func use_ltjz():
	self.role1_skill_inter["ltjz"] = 6.0
	velocity.x = 0
	get_action = "ltjz"
	is_using_skills = true
	is_attacking = true
	_play_ltjz_action()
	var level = get_parent().get_parent()
	var effect = LEI_TING_JIE_ZHEN_EFFECT.new()
	effect.setup(self, player_dir, obj_attack_dict["ltjz"])
	level.add_child(effect)
	if _is_skill_awakened("ltjz") and _is_skill_awaken_enabled("ltjz"):
		var farthest_target := _get_farthest_ltjz_target()
		if farthest_target != null:
			var extra_effect = LEI_TING_JIE_ZHEN_EFFECT.new()
			extra_effect.setup_at_target(self, player_dir, obj_attack_dict["ltjz"], farthest_target.global_position)
			level.add_child(extra_effect)
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func _get_farthest_ltjz_target() -> BaseMonster:
	var level_node := get_parent().get_parent()
	if level_node == null:
		return null
	var monster_container := level_node.get("monster") as Node
	if monster_container == null:
		return null
	var farthest_target: BaseMonster = null
	var farthest_distance := -1.0
	for candidate in monster_container.get_children():
		if not candidate is BaseMonster:
			continue
		var monster := candidate as BaseMonster
		if not is_instance_valid(monster) or monster.hp <= 0 or monster.is_death or monster.no_target:
			continue
		if monster.is_boss_protecting() or _is_summon_or_pet_target(monster):
			continue
		var distance := global_position.distance_squared_to(monster.global_position)
		if distance > farthest_distance:
			farthest_distance = distance
			farthest_target = monster
	return farthest_target


func _is_skill_awakened(skill_id: String) -> bool:
	var awaken_data: Variant = PlayerData.player_data.get(DataKeys.Skill.AWAKENED, {})
	return awaken_data is Dictionary and bool(awaken_data.get(skill_id, false))


func _is_skill_awaken_enabled(skill_id: String) -> bool:
	var enabled_data: Variant = PlayerData.player_data.get(DataKeys.Skill.AWAKENED_ENABLED, {})
	if not enabled_data is Dictionary or not enabled_data.has(skill_id):
		return true
	return bool(enabled_data.get(skill_id, false))


func _play_ltjz_action() -> void:
	const ACTION_NAME := &"ltjz_action"
	if not _prepare_ltjz_action():
		return
	role_action_player.play(ACTION_NAME)
	role_action_player.seek(0.6, true)


func _prepare_ltjz_action() -> bool:
	const ACTION_NAME := &"ltjz_action"
	var library := role_action_player.get_animation_library("")
	if library == null:
		return false
	if library.has_animation(ACTION_NAME):
		return true
	var source := library.get_animation(&"tllz")
	if source == null:
		return false
	var action := source.duplicate(true) as Animation

	for track_index in range(action.get_track_count() - 1, -1, -1):
		var path := str(action.track_get_path(track_index))
		if path != "Action/RoleBody:frame" and path != "Action/RoleEquipment:frame":
			action.remove_track(track_index)
	library.add_animation(ACTION_NAME, action)
	return true


func slq_fly():
	velocity.x = 0
	velocity.y = 0
	var bullet_pos = Vector2()
	if player_dir:
		bullet_pos = Vector2(100, -150)
	else:
		bullet_pos = Vector2(-100, -150)
	var slq = Global.add_role_bullet(
		self.bullet, bullet_pos + position, player_dir, "Role5Bullet1", obj_attack_dict["slq"]
	)
	slq.scale = Vector2(1.4, 1.6)
	velocity.y = -600


func remove_xspeed():
	velocity.x = 0


func role_rush():
	if player_dir:
		velocity.x = 800
	else:
		velocity.x = -800


func role_rush_2():
	if player_dir:
		velocity.x = 90
	else:
		velocity.x = -90


func role_rush_4():
	if player_dir:
		velocity.x = 600
	else:
		velocity.x = -600


func role_rush_3():
	if player_dir:
		velocity.x = 1500
	else:
		velocity.x = -1500


func role_rush_5():
	if player_dir:
		velocity.x = 2000
	else:
		velocity.x = -2000


func up_down_speed():
	velocity.y = 2000


func remove_yspeed():
	velocity.y = 0


func skill_move():
	self.can_move_when_use_skill = true


func skill_move_over():
	self.can_move_when_use_skill = false


func role_5_skill_bt():
	self.role5_bt = true


func role_5_skill_bt_over():
	self.role5_bt = false


func tween_to_top():
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(self.position.x, self.position.y - 200), 0.1)


func in_the_sky():
	in_sky = true


func no_in_the_sky():
	in_sky = false


func changecxq_hit():
	super.get_hit_data("cxq_2")


func changexyq_hit():
	super.get_hit_data("xyq_1")


func call_bullet_2():
	var bullet_pos: Vector2
	if player_dir:
		bullet_pos = Vector2(260, 180)
	else:
		bullet_pos = Vector2(-260, 180)
	var llrd = Global.add_role_bullet(
		self.bullet, bullet_pos + position, false, "Role5Bullet2", obj_attack_dict["llrd"]
	)
	llrd.scale = Vector2(1.5, 1.5)


func call_bullet_3():
	var lljy = Global.add_role_bullet(self.bullet, position, player_dir, "Role5Bullet3", obj_attack_dict["lljy"])


func call_bullet_4():
	if tllz != null:
		tllz.queue_free()
	tllz = Global.add_role_bullet(
		self.bullet, position - Vector2(0, 20), false, "Role5Bullet4", obj_attack_dict["tllz"]
	)
	tllz.scale = Vector2(1.4, 1.4)


func call_bullet_5():
	Global.add_role_bullet(self.bullet, position, !player_dir, "Role5Bullet5", obj_attack_dict["ygth"])


func call_ygth_awaken_bullet():
	var awaken_hit_data: Dictionary = obj_attack_dict["ygth"].duplicate(true)
	awaken_hit_data["power"] = float(awaken_hit_data.get("power", 0.0)) * YGTH_AWAKEN_DAMAGE_MULTIPLIER
	var awaken_hurt_back: Array = awaken_hit_data.get("hurtBack", [0, 0]).duplicate()
	if not awaken_hurt_back.is_empty():
		awaken_hurt_back[0] = -int(awaken_hurt_back[0])
		awaken_hit_data["hurtBack"] = awaken_hurt_back
	var hook := (
		Global.add_role_bullet(self.bullet, position, !player_dir, "Role5Bullet5", awaken_hit_data) as RoleBullet
	)
	if hook == null:
		return
	hook.scale = YGTH_AWAKEN_SCALE
	hook.set_meta("ygth_awakened", true)
	hook.set_meta("ygth_damage_multiplier", YGTH_AWAKEN_DAMAGE_MULTIPLIER)


func add_music(idx: int):
	match idx:
		0:
			Global.add_sound(self, "res://Music/hero/role_5/attack1.mp3")
		1:
			Global.add_sound(self, "res://Music/hero/role_5/attack2.mp3")
		2:
			Global.add_sound(self, "res://Music/hero/role_5/attack3.mp3")
		3:
			Global.add_sound(self, "res://Music/hero/role_5/attack4.mp3")
		4:
			Global.add_sound(self, "res://Music/hero/role_5/jump_attack.mp3")
		5:
			Global.add_sound(self, "res://Music/hero/role_5/effect3.mp3")
		6:
			Global.add_sound(self, "res://Music/hero/role_5/effect4.mp3")
		7:
			Global.add_sound(self, "res://Music/hero/role_5/effect2.mp3")
		8:
			Global.add_sound(self, "res://Music/hero/role_5/effect1_1.mp3")
		9:
			Global.add_sound(self, "res://Music/hero/role_5/effect1_2.mp3")
		10:
			Global.add_sound(self, "res://Music/hero/role_5/effect6.mp3")
		11:
			Global.add_sound(self, "res://Music/hero/role_5/effect8_1.mp3")
		12:
			Global.add_sound(self, "res://Music/hero/role_5/effect8_2.mp3")
		13:
			Global.add_sound(self, "res://Music/hero/role_5/effect9_1.mp3")
		14:
			Global.add_sound(self, "res://Music/hero/role_5/effect9_2.mp3")
		15:
			Global.add_sound(self, "res://Music/hero/role_5/effect7_1.mp3")
		16:
			Global.add_sound(self, "res://Music/hero/role_5/effect7_2.mp3")
		17:
			Global.add_sound(self, "res://Music/hero/role_5/attack.mp3")
		18:
			Global.add_sound(self, "res://Music/hero/role_5/13_hurt_stand.mp3")


func _prepare_hit_reaction() -> void:
	self.can_move_when_use_skill = false
	in_sky = false
	self.role5_bt = false
	is_in_sky = false


func _on_hit_box_area_entered(area: Area2D) -> void:
	if obj_attack_dict.has(get_action):
		if obj_attack_dict[get_action].has("addeffect"):
			var monster = area.get_parent().get_parent()
			if monster != null:
				if monster is BaseMonster and not _is_summon_or_pet_target(monster):
					Global.add_buff(monster.buff, obj_attack_dict[get_action]["addeffect"])

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
