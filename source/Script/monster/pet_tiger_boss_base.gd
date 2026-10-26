extends BaseMonster
class_name PetTigerBossBase

@export var tiger_stage: int = 1

const SKILL_HY := "hy"
const SKILL_SXHZ := "sxhz"
const SKILL_HSQJ := "hsqj"
const SKILL_BHAOYI := "bhaoyi"
const TIGER_MODEL_FRAME_DIR := "res://Art/monster/pet_tiger_boss/model/frames"
const TIGER_FRAME_SPEED := 10.0
const TIGER_ACTIONS := [
	{},
	{
		"wait": [0, 6, true],
		"walk": [0, 6, true],
		"hurt": [1, 1, false],
		"death": [2, 4, false],
		"hit1": [3, 4, false],
		"hit2": [4, 4, false],
		"hit3_1": [3, 4, false],
		"hit3_2": [4, 4, false],
		"hit4": [4, 4, false],
		"hit5": [3, 4, false],
		"hit6": [4, 4, false],
	},
	{
		"wait": [0, 6, true],
		"walk": [1, 4, true],
		"hurt": [2, 1, false],
		"death": [3, 5, false],
		"hit1": [4, 4, false],
		"hit2": [5, 3, false],
		"hit3_1": [6, 3, false],
		"hit3_2": [6, 3, false],
		"hit4": [5, 3, false],
		"hit5": [4, 4, false],
		"hit6": [5, 3, false],
	},
	{
		"wait": [0, 6, true],
		"walk": [1, 4, true],
		"hurt": [2, 1, false],
		"death": [3, 5, false],
		"hit1": [4, 4, false],
		"hit2": [5, 4, false],
		"hit3_1": [6, 3, false],
		"hit3_2": [6, 3, false],
		"hit4": [7, 5, false],
		"hit5": [4, 4, false],
		"hit6": [5, 4, false],
	},
	{
		"wait": [0, 6, true],
		"walk": [1, 4, true],
		"hurt": [2, 1, false],
		"death": [3, 5, false],
		"hit1": [4, 4, false],
		"hit2": [4, 4, false],
		"hit3_1": [5, 3, false],
		"hit3_2": [5, 3, false],
		"hit4": [6, 5, false],
		"hit5": [7, 3, false],
		"hit6": [8, 6, false],
	},
]

var bhaoyi_running: bool = false


func setup_pet_tiger(stage: int) -> void:
	tiger_stage = clampi(stage, 1, 4)
	var stage_bl: float = 1.0 + float(tiger_stage - 1) * 0.28
	is_boss = true
	my_mr_name = ["一阶白虎", "二阶白虎", "三阶白虎", "四阶白虎"][tiger_stage - 1]
	attack_in = 65
	level = 40 + tiger_stage * 5
	max_hp = int((90000 + RoleProp.baseroleprop.Level * 3500) * stage_bl)
	hp = max_hp
	def = int((150 + RoleProp.baseroleprop.Level * 2) * stage_bl)
	mdef = def
	crit = 25 + tiger_stage * 8
	miss = 8 + tiger_stage * 4
	lucky = 30 + tiger_stage * 15
	htarget = 0
	toughness = tiger_stage * 10
	ar = 25 + tiger_stage * 5
	sp = ar
	crit_reduce = tiger_stage * 3
	speed = 12 + tiger_stage
	mysee = 520
	attack_range = 95
	attack_desire = 100
	behit_calmtime = 0.0
	self_rhp = int(max_hp * 0.0001)
	add_exp = 120 + tiger_stage * 40
	fall_coin = 120 + tiger_stage * 45
	var damage_bl: float = 1.0 + float(tiger_stage - 1) * 0.3
	obj_attack_dict["hit1"] = _attack_dic(int(attack_in * 2.2 * damage_bl), [-7, -8], "physics", 8)
	obj_attack_dict[SKILL_HY] = _attack_dic(int(attack_in * 6.3 * damage_bl), [-5, -4], "magic", 8)
	obj_attack_dict[SKILL_SXHZ] = _attack_dic(int(attack_in * damage_bl), [0, 0], "physics", 4)
	obj_attack_dict[SKILL_HSQJ] = _attack_dic(int(attack_in * 5.8 * damage_bl), [0, 0], "magic", 10)
	obj_attack_dict[SKILL_BHAOYI] = _attack_dic(int(attack_in * damage_bl), [-10, -10], "magic", 12)
	fall_pro = 0.35
	fall_list = []
	fall_stone_pro = 0.0
	fall_stone = []


func _ready() -> void:
	super._ready()
	setup_pet_tiger(tiger_stage)
	if hurt_box != null:
		hurt_box.disabled = false
	_setup_tiger_model_frames()
	if not mr_player.animation_started.is_connected(_on_tiger_animation_started):
		mr_player.animation_started.connect(_on_tiger_animation_started)
	_play_tiger_model_animation("wait")
	skill_1_cd = randi_range(2, 4)
	skill_2_cd = randi_range(4, 7)
	skill_3_cd = randi_range(7, 10)
	skill_4_cd = randi_range(12, 18)


func _setup_tiger_model_frames() -> void:
	var frames := SpriteFrames.new()
	var action_map: Dictionary = TIGER_ACTIONS[tiger_stage]
	for action_name in action_map.keys():
		var info: Array = action_map[action_name]
		var row: int = int(info[0])
		var frame_count: int = int(info[1])
		frames.add_animation(action_name)
		frames.set_animation_loop(action_name, bool(info[2]))
		frames.set_animation_speed(action_name, TIGER_FRAME_SPEED)
		for col in range(frame_count):
			var texture := _load_tiger_frame_texture(row, col)
			if texture != null:
				frames.add_frame(action_name, texture)
	mr_ani.sprite_frames = frames


func _load_tiger_frame_texture(row: int, col: int) -> Texture2D:
	var path := "%s/stage%d/r%d_c%d.png" % [TIGER_MODEL_FRAME_DIR, tiger_stage, row, col]
	var texture := Global.get_cached_texture(path)
	if texture == null:
		push_warning("Missing PetTiger frame: " + path)
		return null
	return texture


func _play_tiger_model_animation(animation_name: String) -> void:
	if mr_ani.sprite_frames != null and mr_ani.sprite_frames.has_animation(animation_name):
		mr_ani.play(animation_name)


func _wait_tiger_model_animation(animation_name: String) -> void:
	_play_tiger_model_animation(animation_name)
	if mr_ani.sprite_frames == null or not mr_ani.sprite_frames.has_animation(animation_name):
		await get_tree().create_timer(0.35, false).timeout
		return
	if mr_ani.sprite_frames.get_animation_loop(animation_name):
		await get_tree().create_timer(0.35, false).timeout
		return
	await mr_ani.animation_finished


func _on_tiger_animation_started(animation_name: StringName) -> void:
	_play_tiger_model_animation(String(animation_name))


func _attack_dic(power: int, hurt_back: Array, kind: String, protect: int) -> Dictionary:
	return {
		"power": power,
		"hurtBack": hurt_back,
		"attackKind": kind,
		"HitProtect": protect,
	}


func ai_think() -> void:
	if RoleProp.get_nearest_monster_target_position(global_position).x == null:
		normal_state()
		return
	if abs(float(RoleProp.get_nearest_monster_target_position(global_position).x) - position.x) < mysee:
		has_target = true
	if is_ice or is_sleep or is_stun or is_immobilize or cannotchangestatewhenattorbeatt() or bhaoyi_running:
		return
	if not has_target:
		normal_state()
		return
	var distance: float = abs(float(RoleProp.get_nearest_monster_target_position(global_position).x) - position.x)
	if tiger_stage >= 4 and skill_4_cd <= 0:
		do_bhaoyi()
		return
	if tiger_stage >= 3 and distance <= 450 and skill_3_cd <= 0:
		do_hsqj()
		return
	if tiger_stage >= 2 and distance <= 80 and skill_2_cd <= 0:
		do_sxhz()
		return
	if distance >= 50 and distance <= 100 and skill_1_cd <= 0:
		do_hy()
		return
	if distance > attack_range:
		have_target()
	else:
		stop_move()
		if count % 55 == 0 and randi_range(0, 100) < attack_desire:
			attack_target()


func attack_target() -> void:
	to_hero()
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	_play_attack_animation("hit1", Callable(self, "call_hit_1_bullet"))
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hy() -> void:
	to_hero()
	skill_1_cd = randi_range(5, 7)
	hit_name = SKILL_HY
	velocity.x = 0
	is_attacking = true
	_play_attack_animation("hit2", Callable(self, "call_hy_bullet"))
	await mr_player.animation_finished
	is_attacking = false


func do_sxhz() -> void:
	to_hero()
	skill_2_cd = randi_range(8, 11)
	hit_name = SKILL_SXHZ
	velocity.x = 0
	is_attacking = true
	_play_attack_animation("hit3_1", Callable(self, "call_sxhz_hit"))
	await mr_player.animation_finished
	_play_attack_animation("hit3_2", Callable(self, "call_sxhz_hit"))
	await mr_player.animation_finished
	cure_hp(max(1, int(max_hp * 0.025)))
	is_attacking = false


func do_hsqj() -> void:
	to_hero()
	skill_3_cd = randi_range(10, 13)
	hit_name = SKILL_HSQJ
	velocity.x = 0
	is_attacking = true
	_play_attack_animation("hit4", Callable(self, "call_hsqj_bullet"))
	await mr_player.animation_finished
	is_attacking = false


func do_bhaoyi() -> void:
	if get_player == null:
		return
	bhaoyi_running = true
	_clear_tiger_skill_cooldowns()
	hit_name = SKILL_HSQJ
	velocity.x = 0
	is_attacking = true
	_to_target_side()
	_play_attack_animation("hit4", Callable(self, "call_hsqj_bullet"))
	await mr_player.animation_finished
	await get_tree().create_timer(0.12, false).timeout
	_to_target_side()
	_play_attack_animation("hit4", Callable(self, "call_hsqj_bullet"))
	await mr_player.animation_finished
	skill_4_cd = randi_range(20, 26)
	is_attacking = false
	bhaoyi_running = false


func _clear_tiger_skill_cooldowns() -> void:
	skill_1_cd = 0
	skill_2_cd = 0
	skill_3_cd = 0
	skill_4_cd = 0
	skill_5_cd = 0
	skill_6_cd = 0
	skill_7_cd = 0
	skill_8_cd = 0


func _to_target_side() -> void:
	if get_player == null:
		return
	var side := -1
	if randi_range(0, 1) == 1:
		side = 1
	position.x = RoleProp.get_nearest_monster_target_position(global_position).x + 70 * side
	position.y = RoleProp.get_nearest_monster_target_position(global_position).y
	to_hero()


func _play_attack_animation(animation_name: String, fallback_call: Callable) -> void:
	_play_tiger_model_animation(animation_name)
	if mr_player.has_animation(animation_name):
		mr_player.play(animation_name)
	else:
		fallback_call.call()
	await _wait_tiger_model_animation(animation_name)


func call_hit_1_bullet() -> void:
	var offset: Vector2 = _front_offset(
		_stage_value(60.0, 120.0, 130.0, 130.0), _stage_value(-25.0, -80.0, -70.0, -70.0)
	)
	var bullet_name := "PetTiger1Bullet1" if tiger_stage == 1 else "PetTiger2Bullet1"
	Global.add_bullet(bullet_name, bullet, monster_direction, 1.0, position + offset, "hit1", obj_attack_dict["hit1"])


func call_hy_bullet() -> void:
	var offset: Vector2 = _front_offset(_stage_value(150.0, 190.0, 190.0, 190.0), -80.0)
	Global.add_bullet(
		"PetTiger1Bullet2", bullet, monster_direction, 1.0, position + offset, SKILL_HY, obj_attack_dict[SKILL_HY]
	)


func call_sxhz_hit() -> void:
	var main_offset: Vector2 = _front_offset(50.0, _stage_value(-45.0, -45.0, -45.0, -65.0))
	var air_stun_offset: Vector2 = _front_offset(200.0, -200.0)
	var air_stun_position := position + air_stun_offset
	Global.add_bullet(
		"PetTiger2Bullet3_1",
		bullet,
		monster_direction,
		1.0,
		position + main_offset,
		SKILL_SXHZ,
		obj_attack_dict[SKILL_SXHZ]
	)
	Global.add_bullet(
		"PetTiger2Bullet3_2", bullet, monster_direction, 1.0, air_stun_position, SKILL_SXHZ, obj_attack_dict[SKILL_SXHZ]
	)
	_apply_sxhz_air_stun(air_stun_position)


func call_hsqj_bullet() -> void:
	var disabled_offset: Vector2 = _front_offset(85.0, -130.0)
	var hit_offset: Vector2 = _front_offset(105.0, -2.0)
	var mark_position := position + disabled_offset
	var visual_bullet = Global.add_bullet(
		"PetTiger3Bullet4_1", bullet, monster_direction, 1.0, mark_position, SKILL_HSQJ, obj_attack_dict[SKILL_HSQJ]
	)
	if visual_bullet != null:
		visual_bullet.set_meta("pet_tiger_disabled", true)
	Global.add_bullet(
		"PetTiger3Bullet4_2",
		bullet,
		monster_direction,
		1.0,
		position + hit_offset,
		SKILL_HSQJ,
		obj_attack_dict[SKILL_HSQJ]
	)


func _apply_sxhz_air_stun(air_stun_position: Vector2) -> void:
	var target: Node = get_player
	if target == null or not is_instance_valid(target):
		return
	if not (target is Node2D):
		return
	var stun_time := 3.0
	if "buff" in target and target.buff != null:
		Global.add_buff(
			target.buff,
			{
				"Name": "stun",
				"AddTime": stun_time,
				"reduce_interval": 0,
				"value": 0,
				"AttackKind": "",
				"DeBuff": true,
				"CanRemove": false
			}
		)
	var lock_token := Time.get_ticks_msec()
	target.set_meta("pet_tiger_sxhz_air_stun_token", lock_token)
	_keep_sxhz_target_in_air(target, air_stun_position, stun_time, lock_token)
	_apply_sxhz_three_hit_lifesteal(target)


func _apply_sxhz_three_hit_lifesteal(target: Node) -> void:
	if target == null or not is_instance_valid(target):
		return
	if not target.has_method("effect_reducehp"):
		return
	if not obj_attack_dict.has(SKILL_SXHZ):
		return
	var hit_data: Dictionary = obj_attack_dict[SKILL_SXHZ]
	var attack_kind := "physics"
	if hit_data.has("attackKind"):
		attack_kind = String(hit_data["attackKind"])
	var base_power := int(hit_data.get("power", 0))
	if base_power <= 0:
		return
	for i in range(2):
		if target == null or not is_instance_valid(target):
			return
		var multiplier := 12 if i == 1 else 7
		var damage := base_power * multiplier
		target.effect_reducehp(damage, attack_kind)
		cure_hp(damage)
		if i < 1:
			await get_tree().create_timer(0.08, false).timeout


func _keep_sxhz_target_in_air(target: Node, air_stun_position: Vector2, stun_time: float, lock_token: int) -> void:
	var elapsed := 0.0
	while elapsed < stun_time:
		if target == null or not is_instance_valid(target):
			return
		if (
			not target.has_meta("pet_tiger_sxhz_air_stun_token")
			or int(target.get_meta("pet_tiger_sxhz_air_stun_token")) != lock_token
		):
			return
		(target as Node2D).global_position = air_stun_position
		if target is CharacterBody2D:
			(target as CharacterBody2D).velocity = Vector2.ZERO
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	if (
		target != null
		and is_instance_valid(target)
		and target.has_meta("pet_tiger_sxhz_air_stun_token")
		and int(target.get_meta("pet_tiger_sxhz_air_stun_token")) == lock_token
	):
		target.remove_meta("pet_tiger_sxhz_air_stun_token")


func call_bhaoyi_hit() -> void:
	var dic: Dictionary = obj_attack_dict[SKILL_BHAOYI].duplicate(true)
	dic["power"] = int(dic["power"] * 1.3)
	var offset: Vector2 = _front_offset(130.0, -70.0)
	Global.add_bullet("PetTiger2Bullet1", bullet, monster_direction, 1.25, position + offset, SKILL_BHAOYI, dic)


func _front_offset(x: float, y: float) -> Vector2:
	if monster_direction:
		return Vector2(x, y)
	return Vector2(-x, y)


func _stage_value(stage1: float, stage2: float, stage3: float, stage4: float) -> float:
	match tiger_stage:
		1:
			return stage1
		2:
			return stage2
		3:
			return stage3
		_:
			return stage4
