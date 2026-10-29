extends SummonBaseMonster
class_name Monster143zhw

const BODY_FRAMES_RES := "res://Art/monster/monster_143_zhw/atlas/monster_143_zhw_frames.tres"
static var _body_frames_resource: SpriteFrames = null

var _body_frames_sprite: Sprite2D
var _body_frames: SpriteFrames
var _body_frames_animation: StringName = &""
var _body_action: StringName = &""
@onready var body_animation: AnimatedSprite2D = $MonsterDir/mr_ani

var my_summoner: Role2Hero = null

var is_skill_1_active: bool = false
var is_skill_2_active: bool = false
var is_skill_3_active: bool = false
var is_skill_4_active: bool = false
var is_skill_5_active: bool = false
var is_skill_6_active: bool = false


func _ready():
	super._ready()
	add_to_group("Monster143zhw")
	set_meta("is_summon", true)
	RoleProp.register_monster_attack_target(self)
	_sync_body_visual()


func _exit_tree() -> void:
	RoleProp.unregister_monster_attack_target(self)
	super._exit_tree()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_sync_body_visual()


func _sync_body_visual() -> void:
	var action := body_animation.animation
	if action != _body_action:
		_replace_body_stream(action)
	if _body_frames_sprite != null and is_instance_valid(_body_frames_sprite):
		if _body_frames == null:
			return
		var frame_count := _body_frames.get_frame_count(_body_frames_animation)
		if frame_count <= 0:
			return
		var frame := clampi(body_animation.frame, 0, frame_count - 1)
		_body_frames_sprite.position = body_animation.offset
		_body_frames_sprite.modulate = body_animation.self_modulate
		_body_frames_sprite.flip_h = body_animation.flip_h
		_body_frames_sprite.texture = _body_frames.get_frame_texture(_body_frames_animation, frame)
		return


static func _get_body_frames_resource() -> SpriteFrames:
	if _body_frames_resource == null:
		_body_frames_resource = load(BODY_FRAMES_RES) as SpriteFrames
	return _body_frames_resource


func _setup_body_frames(action: StringName) -> bool:
	var frames := _get_body_frames_resource()
	if frames == null or not frames.has_animation(action):
		return false
	var sprite := Sprite2D.new()
	sprite.name = "BodyFrames"
	sprite.centered = true
	sprite.texture_filter = body_animation.texture_filter
	sprite.modulate = body_animation.self_modulate
	sprite.flip_h = body_animation.flip_h
	sprite.position = body_animation.offset
	sprite.texture = frames.get_frame_texture(action, 0)
	body_animation.add_child(sprite)
	_body_frames_sprite = sprite
	_body_frames = frames
	_body_frames_animation = action
	_sync_body_visual()
	return true


func _replace_body_stream(action: StringName) -> void:
	if _body_frames_sprite != null and is_instance_valid(_body_frames_sprite):
		_body_frames_sprite.texture = null
		_body_frames_sprite.queue_free()
	_body_frames_sprite = null
	_body_frames = null
	_body_frames_animation = &""
	_body_action = action
	_setup_body_frames(action)


func initialize_monster_properties():
	var owner_power := int(RoleProp.roleprop.power)

	max_hp = int(RoleProp.roleprop.SHp)
	hp = max_hp
	is_fly = true
	def = int(RoleProp.roleprop.Def)
	mdef = int(RoleProp.roleprop.Mdef)
	crit = int(RoleProp.roleprop.Crit)
	miss = int(RoleProp.roleprop.Miss)
	lucky = int(RoleProp.roleprop.Lucky)

	rush_speed = 600
	my_mr_name = "正法金刚"
	level = int(RoleProp.baseroleprop.Level)
	is_boss = true
	attack_in = 90
	toughness = int(RoleProp.roleprop.toughness)
	htarget = int(RoleProp.roleprop.htarget)
	ar = int(RoleProp.roleprop.ar)
	sp = int(RoleProp.roleprop.sp)
	crit_reduce = int(RoleProp.roleprop.CritReduce)
	behit_calmtime = 0
	self_rhp = int(RoleProp.roleprop.R_hp)
	ebol = 0

	attack_range = 350
	mysee = 99990
	speed = 20
	attack_desire = 80

	obj_attack_dict["hit1"] = {
		"power": owner_power * 2,
		"hurtBack": [-8, -10],
		"attackKind": "magic",
		"HitProtect": 0,
	}
	obj_attack_dict["hit2"] = {
		"power": owner_power * 4,
		"hurtBack": [-20, -10],
		"attackKind": "magic",
		"HitProtect": 0,
	}
	obj_attack_dict["hit3"] = {
		"power": owner_power * 6,
		"hurtBack": [-15, -10],
		"attackKind": "magic",
		"HitProtect": 0,
		"addeffect":
		{
			"Name": "defe_reduce",
			"AddTime": 20,
			"reduce_interval": 0,
			"value": 0.3,
			"AttackKind": "",
			"DeBuff": true,
			"CanRemove": false,
		}
	}


func setup_skills():
	skill_1_cd = 0
	skill_2_cd = 2
	skill_3_cd = 3


func ai_think():
	if current_target == null or not is_instance_valid(current_target) or current_target.hp <= 0:
		current_target = null
		has_target = false
		if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
			normal_state()
		return

	var distance = position.distance_to(current_target.position)
	has_target = true
	_to_monster()

	if is_ice or is_sleep or is_stun or cannotchangestatewhenattorbeatt():
		return

	if distance > 350:
		if skill_3_cd <= 0:
			do_hit_3()
		else:
			have_target()

	elif distance > 175:
		if skill_2_cd <= 0:
			stop_move()
			do_hit_2()
		else:
			have_target()

	else:
		stop_move()
		if skill_3_cd <= 0:
			do_hit_3()
		elif skill_2_cd <= 0:
			do_hit_2()
		elif skill_1_cd <= 0:
			do_hit_1()


func do_hit_1():
	if is_attacking or is_be_attacking or should_in_sky:
		return

	if current_target == null or position.distance_to(current_target.position) > 175:
		return

	skill_1_cd = randi_range(1, 3)
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_2():
	if is_attacking or is_be_attacking or should_in_sky:
		return

	if current_target == null or position.distance_to(current_target.position) > 350:
		return
	skill_2_cd = randi_range(5, 10)
	hit_name = "hit2"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_3():
	if is_attacking or is_be_attacking or should_in_sky:
		return

	if current_target == null or position.distance_to(current_target.position) > 600:
		return
	skill_3_cd = randi_range(8, 12)
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func _to_monster() -> void:
	if not is_instance_valid(current_target):
		return
	if current_target.position.x > position.x:
		base_damage_box.scale.x = -1
		monster_dir.scale.x = -1
	else:
		base_damage_box.scale.x = 1
		monster_dir.scale.x = 1


# 19-2D：档案退出时释放模块静态帧/几何缓存，避免跨会话持有旧资源。
static func clear_cached_frames() -> void:
	_body_frames_resource = null
