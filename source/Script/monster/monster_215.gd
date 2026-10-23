extends BaseMonster

const FRAME_ROOT := "res://Art/monster/game_3_monster/monster_215"
const SOURCE_FPS := 30.0
const LITTLE_BLOOD_OFFSET := Vector2(-30, -190)

const SKILL_1_COOLDOWN_SECONDS := 0.5
const SKILL_2_COOLDOWN_SECONDS := 1.0
const SKILL_1_POWER := 9000
const SKILL_2_POWER := 12000

const ANIMATION_DATA := {
	&"wait": ["DefineSprite_9", 6, [2, 2, 2, 3, 2, 4], true],
	&"walk": ["DefineSprite_14", 4, [4, 4, 4, 4], true],
	&"hurt": ["DefineSprite_16", 1, [8], false],
	&"death": ["DefineSprite_23", 6, [2, 2, 2, 2, 2, 8], false],
	&"hit1": ["DefineSprite_27", 3, [3, 3, 10], false],
	&"hit2": ["DefineSprite_32", 4, [3, 3, 3, 10], false],
}

var _skill_busy := false

@onready var skill_1_cooldown: Timer = $Skill1Cooldown
@onready var skill_2_cooldown: Timer = $Skill2Cooldown


func _ready() -> void:
	_configure_boss()
	_build_animations()
	super._ready()
	skill_1_cooldown.start(SKILL_1_COOLDOWN_SECONDS)
	skill_2_cooldown.start(SKILL_2_COOLDOWN_SECONDS)


func _configure_boss() -> void:
	rush_speed = 180
	is_boss = true
	boss_max_protect = 240
	my_mr_name = "黑衣人"
	attack_in = 90
	level = 90
	max_hp = 15000000
	hp = max_hp
	self.def = 3700
	mdef = 3700
	crit = 0
	miss = 150
	lucky = 0
	htarget = 9999
	toughness = 0
	ar = 1000
	sp = 1000
	crit_reduce = 0
	speed = 25
	mysee = 1000

	attack_range = 150
	attack_desire = 100
	behit_calmtime = 0
	add_exp = 20
	fall_coin = 800
	fall_pro = 0.0
	fall_list = []
	self.independent_fall_list = [
		{"name": "cswkxyhbzzs", "value": 1, "chance": 0.1},
		{"name": "cstsxyhbzzs", "value": 1, "chance": 0.1},
		{"name": "csbjxyhbzzs", "value": 1, "chance": 0.1},
		{"name": "csssxyhbzzs", "value": 1, "chance": 0.1},
		{"name": "csblxyhbzzs", "value": 1, "chance": 0.1},
		{"name": "342071301zzs", "value": 1, "chance": 0.1},
	]
	obj_attack_dict["hit1"] = {
		"power": SKILL_1_POWER,
		"hurtBack": [-10, -5],
		"attackKind": "physics",
		"HitProtect": 99,
	}
	obj_attack_dict["hit2"] = {
		"power": SKILL_2_POWER,
		"hurtBack": [-8, -2],
		"attackKind": "magic",
		"HitProtect": 99,
	}


func _build_animations() -> void:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for anim_name: StringName in ANIMATION_DATA:
		var data: Array = ANIMATION_DATA[anim_name]
		frames.add_animation(anim_name)
		frames.set_animation_loop(anim_name, bool(data[3]))
		frames.set_animation_speed(anim_name, SOURCE_FPS)
		var durations: Array = data[2]
		var source := load(FRAME_ROOT.path_join("monster_215_%s_frames.tres" % anim_name)) as SpriteFrames
		if source == null or not source.has_animation(&"play"):
			push_error("Monster215 standard frames missing: " + str(anim_name))
			continue
		for index in range(source.get_frame_count(&"play")):
			if index < durations.size():
				frames.add_frame(anim_name, source.get_frame_texture(&"play", index), float(durations[index]))
	mr_ani.sprite_frames = frames
	mr_ani.centered = true

	mr_ani.position = Vector2(0, -64)

	if mr_player.has_animation_library(&""):
		mr_player.remove_animation_library(&"")
	var library := AnimationLibrary.new()
	library.add_animation(&"wait", _make_action(&"wait", true))
	library.add_animation(&"walk", _make_action(&"walk", true))
	library.add_animation(&"hurt", _make_action(&"hurt", false))
	var death_animation := _make_action(&"death", false)
	_add_method_key(death_animation, death_animation.length - 0.001, &"settle_death_drops_and_free")
	library.add_animation(&"death", death_animation)
	var hit1_animation := _make_action(&"hit1", false)
	_add_method_key(hit1_animation, 0.2, &"call_bullet_1")
	library.add_animation(&"hit1", hit1_animation)
	var hit2_animation := _make_action(&"hit2", false)
	_add_method_key(hit2_animation, 0.2, &"call_bullet_2")
	library.add_animation(&"hit2", hit2_animation)
	mr_player.add_animation_library(&"", library)


func _make_action(anim_name: StringName, looped: bool) -> Animation:
	var animation := Animation.new()
	animation.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
	var method_track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(method_track, NodePath("."))
	animation.track_insert_key(method_track, 0.0, {"method": &"_play_sprite_animation", "args": [anim_name]})
	var data: Array = ANIMATION_DATA[anim_name]
	var duration := 0.0
	for frame_duration in data[2]:
		duration += float(frame_duration) / SOURCE_FPS
	animation.length = maxf(duration, 0.05)
	return animation


func _play_sprite_animation(anim_name: StringName) -> void:
	mr_ani.play(anim_name)


func _add_method_key(animation: Animation, time: float, method_name: StringName) -> void:
	var method_track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(method_track, NodePath("."))
	animation.track_insert_key(
		method_track, clampf(time, 0.0, animation.length - 0.001), {"method": method_name, "args": []}
	)


func ai_think() -> void:
	if is_limit_buff():
		_skill_busy = false
		velocity.x = 0
		stop_move()
		return
	if cannotchangestatewhenattorbeatt() or _skill_busy:
		return
	var role_position_x = RoleProp.get_nearest_monster_target_position(global_position).x
	if role_position_x == null:
		has_target = false
		stop_move()
		return
	var distance := absf(float(role_position_x) - position.x)
	has_target = distance < mysee
	if not has_target:
		to_hero()
		stop_move()
		return
	if skill_2_cooldown.is_stopped() and distance < 500.0:
		_use_attack(&"hit2")
	elif distance > attack_range:
		have_target()
	elif skill_1_cooldown.is_stopped():
		_use_attack(&"hit1")
	else:
		stop_move()


func _use_attack(action: StringName) -> void:
	if is_attacking:
		return
	to_hero()
	hit_name = str(action)
	velocity.x = 0
	is_attacking = true
	_skill_busy = true
	mr_player.play(action)
	await mr_player.animation_finished
	if not is_instance_valid(self) or death():
		return
	is_attacking = false
	_skill_busy = false
	if action == &"hit1":
		skill_1_cooldown.start(SKILL_1_COOLDOWN_SECONDS)
	else:
		skill_2_cooldown.start(SKILL_2_COOLDOWN_SECONDS)
	stop_move()


func call_bullet_1() -> void:
	_sync_attack_power(&"hit1")
	var offset := Vector2(65, -55) if monster_direction else Vector2(-65, -55)
	Global.add_bullet(
		"Monster215Bullet1", bullet, monster_direction, 1.0, position + offset, "hit1", obj_attack_dict["hit1"]
	)


func call_bullet_2() -> void:
	_sync_attack_power(&"hit2")
	var direction_sign := 1.0 if monster_direction else -1.0
	for offset in [Vector2(150, 0), Vector2(170, -30), Vector2(150, -65)]:
		var directed_offset := Vector2(offset.x * direction_sign, offset.y)
		Global.add_bullet(
			"Monster215Bullet2",
			bullet,
			monster_direction,
			1.0,
			position + directed_offset,
			"hit2",
			obj_attack_dict["hit2"]
		)


func _sync_attack_power(action: StringName) -> void:
	var action_key := String(action)
	if has_meta("tower_config"):
		var tower_config: Dictionary = get_meta("tower_config", {})
		obj_attack_dict[action_key]["power"] = int(tower_config.get("attack", 0))
		return
	var base_power := SKILL_1_POWER if action == &"hit1" else SKILL_2_POWER
	var difficulty := int(MainSet.set_data.get("Difficult", 0))
	var multiplier := 1.0
	if difficulty == 1:
		multiplier = 2.0
	elif difficulty == 2:
		multiplier = 3.0
	elif difficulty == BaseMonster.NIGHTMARE_DIFFICULTY:
		multiplier = 3.0
	obj_attack_dict[action_key]["power"] = int(base_power * multiplier)
	if difficulty == BaseMonster.NIGHTMARE_DIFFICULTY:
		obj_attack_dict[action_key]["power"] += BaseMonster.NIGHTMARE_ATTACK_BONUS


func little_blood_bar_control():
	super.little_blood_bar_control()
	_move_little_blood_bar_to_head()


func _show_pet_hit_blood_bar() -> void:
	super._show_pet_hit_blood_bar()
	_move_little_blood_bar_to_head()


func _move_little_blood_bar_to_head() -> void:
	if monster_blood_bar != null:
		monster_blood_bar.position = LITTLE_BLOOD_OFFSET

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
