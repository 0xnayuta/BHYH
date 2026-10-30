extends BaseHero
class_name Role2Hero

const JHSJ_AWAKEN_EFFECT := preload("res://Scene/hero/role_special_effect_slim/jhsj_awaken_effect.tscn")

var zhw_list: Array = []
var current_zhw_summon: Node2D = null
var jhsj_awaken_effect: Node2D = null

var shield_effect = null
var bingyu_effects: Array[Node2D] = []

var smb_hold_timer: float = 0.0
var smb_ready_for_second_press: bool = false

var tjgl_effect: Node2D = null
@onready var shield_bar: ProgressBar = $ShieldBar
@onready var hurt_box = $base_damagebox/HurtBox/HurtBox
var interv: int
var shallow_list: Array
var jhsj_1
var jhsj_2
var sgq
var smpox
var myhc


func _ready() -> void:
	super._ready()
	super.on_eqchange()
	role_2_handler()

	if not is_in_group("Player"):
		add_to_group("Player")

	_ensure_bingyu_action()
	call_deferred("_prewarm_role2_skill_effects")


func _prewarm_role2_skill_effects() -> void:
	if ClassDB.class_exists("SpineSprite"):
		JHSJAwakenEffect.preload_effect_data()
	if Global._equipped_role_skill_names().has("zfjg"):
		Global.preload_scene_path("res://Scene/hero/role_special_effect_slim/zfjg_zh.tscn")
		Global.preload_scene_path("res://Scene/monster/monster_zhw/monster_143_zhw.tscn")


func role_2_handler():
	RoleProp.role1_sxbj = 0
	RoleProp.role1_s_xxx = 0
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
	var level_11 = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能11"][DataKeys.LEVEL]
	self.obj_attack_dict["hit1"] = {
		"power": RoleProp.roleprop.power * randf_range(0.9, 1.1),
		"hurtBack": [4, -6],
		"attackKind": "magic",
		"HitInterv": 1,
		"WSValue": randi_range(2, 4)
	}
	self.obj_attack_dict["blb"] = {
		"power": RoleProp.roleprop.power * (1.0 + (level_1 * 0.05)),
		"hurtBack": [25, -10],
		"attackKind": "magic",
		"WSValue": randi_range(15, 18)
	}
	self.obj_attack_dict["xbz"] = {
		"power": RoleProp.roleprop.power * (0.75 + (level_2 * 0.075)),
		"hurtBack": [8, -13],
		"attackKind": "magic",
		"WSValue": randi_range(10, 12),
		"addeffect":
		{
			"Name": "Ice",
			"AddTime": 1 + level_10 * 0.1,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"DeBuff": true
		}
	}
	self.obj_attack_dict["shy"] = {"power": 0, "hurtBack": [0, 0], "attackKind": "magic"}
	self.obj_attack_dict["tjgl"] = {"power": 0, "hurtBack": [0, 0], "attackKind": "magic"}
	self.obj_attack_dict["jgz"] = {"power": 0, "hurtBack": [0, 0], "attackKind": "magic"}
	self.obj_attack_dict["smb"] = {
		"power": RoleProp.roleprop.power * (6.0 + level_5 * 2.2) + RoleProp.roleprop.SMp * (0.4 + level_5 * 0.3),
		"hurtBack": [3, -8],
		"attackKind": "magic",
		"WSValue": randi_range(35, 45),
		"addeffect":
		{
			"Name": "Ice",
			"AddTime": 2 + level_10 * 0.1,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "",
			"DeBuff": true
		}
	}
	self.obj_attack_dict["sgq"] = {
		"power": RoleProp.roleprop.power * (0.15 + (level_6 * 0.02)),
		"hurtBack": [3, -8],
		"attackKind": "magic",
		"WSValue": 1,
	}
	self.obj_attack_dict["jhsj"] = {
		"power": RoleProp.roleprop.power * (0.8 + (level_9 * 0.1)),
		"hurtBack": [3, -8],
		"attackKind": "magic",
		"WSValue": randi_range(10, 15),
	}
	self.obj_attack_dict["myhc"] = {"power": 0, "hurtBack": [0, 0], "attackKind": "magic"}
	self.obj_attack_dict["by"] = {
		"power":
		(RoleProp.roleprop.power * (2.0 + level_11 * 1.6) + RoleProp.roleprop.SMp * (0.13 + level_11 * 0.1)) * 0.32,
		"hurtBack": [1, -2],
		"attackKind": "magic",
		"WSValue": 3
	}
	self.obj_attack_dict["zfjg"] = {"power": 0, "hurtBack": [0, 0], "attackKind": "magic"}


func _physics_process(delta: float) -> void:
	if smb1 != null:
		smpox = smb1.position
	else:
		is_use_smb = false
		smb_ready_for_second_press = false

	if shield_bar:
		var max_shield = RoleProp.roleprop.SHp
		shield_bar.max_value = max_shield
		shield_bar.value = hd
		shield_bar.visible = (hd > 0)

	if shield_effect != null and hd <= 0:
		shield_effect.queue_free()
		shield_effect = null
	_update_tjgl_shield_timer()

	if self.is_in_sky:
		self.gravity = 0
		if is_use_smb:
			velocity.y = -160
		else:
			velocity.y = 0
	else:
		self.gravity = -980

	role_2_handler()
	super._physics_process(delta)

	if no_limit_buff():
		if (
			not is_riding_mount()
			and PlayerInput.is_action_pressed("normalhit")
			and not is_be_attacking
			and not is_using_skills
			and interv <= 0
		):
			do_normalhit_1()

		if smb1 != null:
			var smb_action_pressed = _is_smb_action_pressed()
			if not smb_action_pressed:
				smb_ready_for_second_press = true
			elif smb_ready_for_second_press and _is_smb_action_just_pressed():
				skill_smb2()


func _is_smb_action_pressed() -> bool:
	var action_map = {"Y": "slz", "U": "lys", "I": "lyfb", "O": "hmz", "L": "hytj"}
	for key_id in action_map:
		if (
			PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能键位"].get(key_id, "") == "smb"
			and PlayerInput.is_action_pressed(action_map[key_id])
		):
			return true
	return false


func _is_smb_action_just_pressed() -> bool:
	var action_map = {"Y": "slz", "U": "lys", "I": "lyfb", "O": "hmz", "L": "hytj"}
	for key_id in action_map:
		if (
			PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能键位"].get(key_id, "") == "smb"
			and PlayerInput.is_action_just_pressed(action_map[key_id])
		):
			return true
	return false


func do_normalhit_1():
	interv = obj_attack_dict["hit1"]["HitInterv"]
	super.get_hit_data("hit1")
	get_action = "hit1"
	is_can_move_attack_in_sky()
	is_attacking = true
	role_action_player.play("hit1")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	return


func skill_blb():
	self.role1_skill_inter["blb"] = 2.4
	velocity.x = 0
	get_action = "blb"
	is_using_skills = true
	super.get_hit_data("blb")
	is_attacking = true
	role_action_player.play("blb")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func skill_xbz():
	self.role1_skill_inter["xbz"] = 1.2
	velocity.x = 0
	get_action = "xbz"
	is_using_skills = true
	super.get_hit_data("xbz")
	is_attacking = true
	if my_shallow != null:
		my_shallow.skill_name = "tjgl"
		my_shallow.should_use_skill = true
	role_action_player.play("xbz")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func skill_sgq():
	self.role1_skill_inter["sgq"] = 1.2
	velocity.x = 0
	get_action = "sgq"
	is_using_skills = true
	super.get_hit_data("sgq")
	is_attacking = true
	role_action_player.play("sgq")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func skill_jhsj():
	self.role1_skill_inter["jhsj"] = 2.4
	velocity.x = 0
	get_action = "jhsj"
	is_using_skills = true
	super.get_hit_data("jhsj")
	is_attacking = true
	if _is_skill_awakened("jhsj") and _is_skill_awaken_enabled("jhsj"):
		_spawn_jhsj_awaken_effect()
	if my_shallow != null:
		my_shallow.skill_name = "jhsj"
		my_shallow.should_use_skill = true
	role_action_player.play("jhsj")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func skill_tjgl():
	self.role1_skill_inter["tjgl"] = 4.8
	velocity.x = 0
	get_action = "tjgl"
	is_using_skills = true
	super.get_hit_data("tjgl")
	is_attacking = true
	if my_shallow != null:
		my_shallow.skill_name = "xbz"
		my_shallow.should_use_skill = true
	role_action_player.play("tjgl")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func skill_myhc():
	self.role1_skill_inter["myhc"] = 4.8
	velocity.x = 0
	get_action = "myhc"
	is_using_skills = true
	super.get_hit_data("myhc")
	is_attacking = true
	role_action_player.play("myhc")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func skill_shy():
	self.role1_skill_inter["shy"] = 2.4
	get_action = "shy"
	is_using_skills = true
	super.get_hit_data("shy")
	is_attacking = true
	role_action_player.play("shy")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func skill_jgz():
	self.role1_skill_inter["jgz"] = 2.4
	get_action = "jgz"
	is_using_skills = true
	super.get_hit_data("jgz")
	is_attacking = true
	role_action_player.play("jgz")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func skill_smb():
	is_use_smb = true
	smb_ready_for_second_press = false
	self.role1_skill_inter["smb"] = 1.2
	velocity.x = 0
	get_action = "smb"
	is_using_skills = true
	super.get_hit_data("smb")
	is_attacking = true
	role_action_player.play("smb_1")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func skill_smb2():
	is_use_smb = false
	smb_ready_for_second_press = false
	self.role1_skill_inter["smb"] = 1.2
	velocity.x = 0
	velocity.y = 0
	get_action = "smb"
	is_using_skills = true
	super.get_hit_data("smb")
	is_attacking = true
	role_action_player.play("smb_2")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func skill_by():
	is_use_smb = false
	self.role1_skill_inter["by"] = 6.0
	velocity.x = 0
	get_action = "by"
	is_using_skills = true
	is_attacking = true
	super.get_hit_data("by")
	var effect := BingYuEffect.new()
	effect.setup(self, obj_attack_dict["by"])
	get_tree().current_scene.add_child(effect)
	bingyu_effects.append(effect)
	effect.tree_exited.connect(_on_bingyu_effect_exited.bind(effect))
	_ensure_bingyu_action()
	role_action_player.play("by_action", -1.0, 3.0)
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func _ensure_bingyu_action() -> void:
	var bingyu_action: Animation
	if role_action_player.has_animation("by_action"):
		bingyu_action = role_action_player.get_animation("by_action")
	else:
		var source_animation := role_action_player.get_animation("tjgl")
		if source_animation == null:
			return
		bingyu_action = source_animation.duplicate(true) as Animation
		var default_library := role_action_player.get_animation_library("")
		if default_library != null:
			default_library.add_animation("by_action", bingyu_action)
	_strip_bingyu_action_sound(bingyu_action)


func _strip_bingyu_action_sound(animation: Animation) -> void:
	if animation == null:
		return
	for track_index in range(animation.get_track_count() - 1, -1, -1):
		if animation.track_get_path(track_index) == NodePath("RolePlayer:speed_scale"):
			animation.remove_track(track_index)
			continue
		if animation.track_get_type(track_index) != Animation.TYPE_METHOD:
			continue
		for key_index in range(animation.track_get_key_count(track_index) - 1, -1, -1):
			var method_data: Variant = animation.track_get_key_value(track_index, key_index)
			if method_data is Dictionary and str(method_data.get("method", "")).to_lower() == "addmusic":
				animation.track_remove_key(track_index, key_index)


func _on_bingyu_effect_exited(effect: Node) -> void:
	bingyu_effects.erase(effect)


func skill_zfjg():
	var cd_time = 5
	self.role1_skill_inter["zfjg"] = cd_time
	velocity.x = 0
	get_action = "zfjg"
	is_using_skills = true
	super.get_hit_data("zfjg")
	is_attacking = true
	role_action_player.play("zfjg")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func _summon_zhw():
	var all_zhw = get_tree().get_nodes_in_group("Monster143zhw")
	if all_zhw.size() >= _get_zhw_summon_limit():
		return

	var summon_scene := Global.load_scene_uncached("res://Scene/monster/monster_zhw/monster_143_zhw.tscn")
	if summon_scene == null:
		return
	var summon_instance = summon_scene.instantiate()
	summon_instance.add_to_group("Monster143zhw")

	var summon_pos = global_position
	summon_pos.x += 100 if player_dir else -100
	summon_pos.y += -100 if player_dir else 100
	summon_instance.position = summon_pos

	summon_instance.my_summoner = self
	summon_instance.initialize_monster_properties()
	summon_instance.setup_skills()

	get_tree().current_scene.add_child(summon_instance)
	current_zhw_summon = summon_instance
	zhw_list.append(summon_instance)

	var timer = Timer.new()
	timer.one_shot = true
	timer.autostart = false
	add_child(timer)
	timer.timeout.connect(_on_single_zhw_timeout.bind(summon_instance, timer))
	timer.start(get_zfjg_duration())


func _get_zhw_summon_limit() -> int:
	return 5 if _is_skill_awakened("zfjg") and _is_skill_awaken_enabled("zfjg") else 2


func _on_single_zhw_timeout(zhw_instance, timer):
	if is_instance_valid(zhw_instance):
		_destroy_zhw(zhw_instance)
	zhw_list.erase(zhw_instance)
	if current_zhw_summon == zhw_instance:
		current_zhw_summon = null
	timer.queue_free()


func _destroy_zhw(target: Node2D):
	if not is_instance_valid(target):
		return
	RoleProp.unregister_monster_attack_target(target)
	target.mr_player.play("death")
	await target.mr_player.animation_finished
	if is_instance_valid(target):
		target.queue_free()


func _exit_tree():
	super._exit_tree()
	for zhw in zhw_list.duplicate():
		if is_instance_valid(zhw):
			zhw.queue_free()
	zhw_list.clear()
	current_zhw_summon = null
	for effect in bingyu_effects.duplicate():
		if effect != null and is_instance_valid(effect):
			effect.queue_free()
	bingyu_effects.clear()


func add_normal_hit_effect():
	var bullet_pos = Vector2()
	if player_dir:
		bullet_pos = Vector2(10, 15)
	else:
		bullet_pos = Vector2(-10, 15)
	Global.add_role_bullet(self.bullet, bullet_pos + position, player_dir, "Role2Bullet1", obj_attack_dict["hit1"])


func add_blb():
	if get_action == "by":
		return
	var bullet_pos = Vector2()
	if player_dir:
		bullet_pos = Vector2(15, 0)
	else:
		bullet_pos = Vector2(-15, 0)
	Global.add_role_bullet(self.bullet, bullet_pos + position, player_dir, "Role2Bullet2", obj_attack_dict["blb"])


func add_sgq():
	var bullet_pos = Vector2()
	if player_dir:
		bullet_pos = Vector2(35, -20)
	else:
		bullet_pos = Vector2(-35, -20)
	if sgq == null:
		sgq = Global.add_role_bullet(
			self.bullet, bullet_pos + position, player_dir, "Role2Bullet5", obj_attack_dict["sgq"]
		)
		sgq.scale = Vector2(2, 2)
	else:
		sgq.queue_free()
		sgq = Global.add_role_bullet(
			self.bullet, bullet_pos + position, player_dir, "Role2Bullet5", obj_attack_dict["sgq"]
		)
		sgq.scale = Vector2(2, 2)


func add_xbz():
	var bullet_spawn_positions = [Vector2(-80, -15)]
	var scale_list = [Vector2(1, 1), Vector2(1.3, 1.3), Vector2(1.5, 1.5)]
	if !player_dir:
		bullet_spawn_positions = [Vector2(-80, -15), Vector2(-175, -20), Vector2(-275, -25)]
	else:
		bullet_spawn_positions = [Vector2(80, -15), Vector2(175, -20), Vector2(275, -25)]
	for i in bullet_spawn_positions.size():
		var xbz = Global.add_role_bullet(
			self.bullet, bullet_spawn_positions[i] + position, player_dir, "Role2Bullet3", obj_attack_dict["xbz"]
		)
		xbz.scale = scale_list[i]
		await get_tree().create_timer(0.2, false).timeout


func add_smb_1():
	if !player_dir:
		smb1 = Global.add_smb_effect(self.bullet, position + Vector2(-100, 25), player_dir)
	else:
		smb1 = Global.add_smb_effect(self.bullet, position + Vector2(100, 25), player_dir)


func add_zfjg():
	Global.add_role_special_effect(self.bullet, position + Vector2(0, 0), false, "zfjg_zh")
	_summon_zhw()


func add_smb_2():
	Global.add_role_bullet(self.bullet, smpox + Vector2(0, -180), player_dir, "Role2Bullet4", obj_attack_dict["smb"])
	if _is_skill_awakened("smb") and _is_skill_awaken_enabled("smb"):
		_spawn_smb_awaken_extra_bursts(smpox, player_dir)


func _spawn_smb_awaken_extra_bursts(origin: Vector2, direction: bool) -> void:
	var roll := randf()
	var extra_count := 2 if roll < 0.2 else (1 if roll < 0.7 else 0)
	for burst_index in range(extra_count):
		await get_tree().create_timer(0.18 * float(burst_index + 1), false).timeout
		if not is_instance_valid(self) or is_death:
			return
		Global.add_role_bullet(
			self.bullet, origin + Vector2(0, -180), direction, "Role2Bullet4", obj_attack_dict["smb"]
		)


func add_shallow():
	if my_shallow == null:
		my_shallow = Global.add_role2_shallow(self.bullet, position, player_dir)
		my_shallow.my_owner = self
	else:
		if not my_shallow.should_use_skill:
			position = my_shallow.position
			my_shallow.queue_free()


func self_cure():
	var level = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能4"][DataKeys.LEVEL] + 1
	var total_value = int(RoleProp.roleprop.SHp * 0.2 + level * 0.02)
	cure_value = 0.6 * float(RoleProp.roleprop.SHp - RoleProp.roleprop.Hp) / float(RoleProp.roleprop.SHp) + 1
	var value = int(total_value * cure_hp_value)
	cure_hp(value)


func add_tjgl():
	if get_action == "by":
		return
	tjgl_effect = Global.add_role_special_effect(self.bullet, position + Vector2(0, -35), false, "tjgl")
	tjgl_effect.show_behind_parent = true


func add_myhc():
	if myhc != null:
		myhc.queue_free()
		myhc = Global.add_role_special_effect(self, Vector2(0, -30), false, "myhc")
	else:
		myhc = Global.add_role_special_effect(self, Vector2(0, -30), false, "myhc")


func add_jgz():
	var effect
	if !player_dir:
		effect = Global.add_role_special_effect(self.bullet, position + Vector2(-300, 0), false, "jgz")
	else:
		effect = Global.add_role_special_effect(self.bullet, position + Vector2(300, 0), false, "jgz")

	if effect:
		var skill_level = get_skill_level(8)
		effect.skill_level = skill_level


func add_jhsj():
	if !player_dir:
		jhsj_1 = Global.add_role_special_effect(self, Vector2(-20, -15), player_dir, "jhsj")
	else:
		jhsj_1 = Global.add_role_special_effect(self, Vector2(20, -15), player_dir, "jhsj")


func _is_skill_awakened(skill_id: String) -> bool:
	var awaken_data: Variant = PlayerData.player_data.get(DataKeys.Skill.AWAKENED, {})
	return awaken_data is Dictionary and bool(awaken_data.get(skill_id, false))


func _is_skill_awaken_enabled(skill_id: String) -> bool:
	var enabled_data: Variant = PlayerData.player_data.get(DataKeys.Skill.AWAKENED_ENABLED, {})
	if not enabled_data is Dictionary:
		return true
	if not enabled_data.has(skill_id):
		return true
	return bool(enabled_data.get(skill_id, false))


func _is_tjgl_awaken_active() -> bool:
	return _is_skill_awakened("tjgl") and _is_skill_awaken_enabled("tjgl")


func is_knockback_immune() -> bool:
	return super.is_knockback_immune() or (hd > 0 and _is_tjgl_awaken_active())


func refresh_tjgl_shield_timer() -> void:
	if shield_timer == null or hd <= 0:
		return
	if _is_tjgl_awaken_active():
		shield_timer.stop()
	else:
		shield_timer.start(15.0)


func _update_tjgl_shield_timer() -> void:
	if shield_timer == null or hd <= 0:
		return
	if _is_tjgl_awaken_active():
		if not shield_timer.is_stopped():
			shield_timer.stop()
	elif shield_timer.is_stopped():
		shield_timer.start(15.0)


func _spawn_jhsj_awaken_effect() -> void:
	if jhsj_awaken_effect != null and is_instance_valid(jhsj_awaken_effect):
		jhsj_awaken_effect.queue_free()
	var effect := JHSJ_AWAKEN_EFFECT.instantiate()
	jhsj_awaken_effect = effect
	var awaken_hit_data: Dictionary = obj_attack_dict["jhsj"].duplicate(true)
	var skill_level: int = int(get_skill_level(9))
	awaken_hit_data["power"] = RoleProp.roleprop.power * (15.0 + skill_level * 0.45)
	effect.setup(self, awaken_hit_data, player_dir)
	effect.position = position
	get_parent().add_child(effect)


func add_jhsj_2():
	var bullet_pos = Vector2.ZERO
	jhsj_2 = Global.add_role_bullet(self, bullet_pos, player_dir, "Role2Bullet6", obj_attack_dict["jhsj"])
	jhsj_2.show_behind_parent = true


func _on_normal_hit_reduce_timeout() -> void:
	interv -= 1


func add_music(num):
	match num:
		1:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/58_role2_hit1.mp3")
		2:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/59_role2_hit2.mp3")
		3:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/57_role2_hit8.mp3")
		4:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/60_role2_hit3.mp3")
		5:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/51_role2_hit10.mp3")
		6:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/11_role2_hit4.mp3")
		7:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/32_role2_hit6.mp3")
		8:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/40_role2_hit7.mp3")
		9:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/39_role2_hit9.mp3")
		10:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/75_role2_dead.mp3")


func add_shake(power, time, inter):
	var baselevel = get_parent().get_parent() as BaseLevel
	baselevel._shake_screen(power, time, inter)


func _prepare_hit_reaction() -> void:
	if tjgl_effect != null:
		tjgl_effect.queue_free()
		tjgl_effect = null
	if jhsj_1 != null:
		jhsj_1.queue_free()
	if jhsj_2 != null:
		jhsj_2.queue_free()

	is_use_smb = false
	if smb1 != null:
		smb1.should_death = true


func reset_smb():
	is_use_smb = false
	smb_ready_for_second_press = false


func emove_smb1():
	if smb1 != null:
		smb1.queue_free()
	pass


func removespeedy():
	velocity.y = 0


func _on_shield_timer_timeout():
	if hd > 0 and _is_tjgl_awaken_active():
		return
	if shield_effect != null:
		shield_effect.queue_free()
		shield_effect = null
	hd = 0


func get_zfjg_duration() -> float:
	var lv12 = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能12"][DataKeys.LEVEL]
	var base = 20.0
	var add = (40.0 - base) / 10.0
	return base + lv12 * add
