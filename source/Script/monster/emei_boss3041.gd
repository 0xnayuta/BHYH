extends BaseMonster
class_name EmeiBoss3041

const PROJECTILE_SCRIPT := preload("res://Script/monster/nanhai_projectile.gd")
const ROOT := "res://Art/monster/swf_png/3041"
const SOURCE_FPS := 30.0
const AI_DELAY_MSEC := 1000

const SKILL1_BOX_SIZE := Vector2(162.0, 130.0)
const SKILL1_BOX_POSITION := Vector2(-81.0, -65.0)

const SKILL2_TRIGGER_FRAME := 25
const SKILL2_TRAVEL_DURATION := 1.0
const SKILL2_STONE_DURATION := 23.0 / SOURCE_FPS

const SKILL3_DASH_FRAME := 22
const SKILL3_DASH_DURATION := 0.3
const SKILL3_DASH_SPEED := 240.0
const SKILL3_BOX_SIZE := Vector2(290.0, 120.0)
const SKILL3_BOX_POSITION := Vector2(-175.0, -60.0)

signal skill2_sequence_completed

const ACTIONS := {
	&"wait": {"folder": "wait", "frames": 20, "offset": Vector2(0.8, -56.85), "loop": true},
	&"walk": {"folder": "walk", "frames": 16, "offset": Vector2(0.85, -54.7), "loop": true},
	&"hurt": {"folder": "hurt", "frames": 35, "offset": Vector2(-10.05, -60.35), "loop": false},
	&"death": {"folder": "death", "frames": 35, "offset": Vector2(-26.75, -56.1), "loop": false},
	&"skill1": {"folder": "effect1", "frames": 36, "offset": Vector2(24.45, -64.5), "loop": false},
	&"skill2": {"folder": "effect2", "frames": 110, "offset": Vector2(4.3, -30.9), "loop": false},
	&"skill3": {"folder": "effect3", "frames": 40, "offset": Vector2(17.9, -42.4), "loop": false},
}

const EFFECTS := {
	&"effect2_1": {"frames": 12, "offset": Vector2(6.0, -11.0)},
	&"effect2_2": {"frames": 23, "offset": Vector2(-5.3, -148.7)},
}

var monster_kind := 3041
static var _frames_cache: SpriteFrames

var _runtime_config: Dictionary = {}
var _busy := false
var _death_started := false
var _attack_serial := 0
var _skill_cycle := 0
var _next_attack_msec := 0
var _skill_direction := 1.0

var _skill2_sequence_active := false
var _skill2_travel: NanhaiProjectile
var _skill2_stone: NanhaiProjectile
var _skill3_dash_active := false
var _skill3_dash_time_left := 0.0


func _ready() -> void:
	_runtime_config = _resolve_runtime_config()
	if not _runtime_config.is_empty():
		_configure_boss(_runtime_config)
	_build_animations()
	super._ready()


func _resolve_runtime_config() -> Dictionary:
	var level_node := get_level_node()
	if level_node != null and level_node.has_method("get_level_monster_config"):
		var level_config: Variant = level_node.call("get_level_monster_config", monster_kind)
		if level_config is Dictionary and not level_config.is_empty():
			return (level_config as Dictionary).duplicate(true)
	push_error("EmeiBoss3041 requires level monster config for 3041")
	return {}


func _configure_boss(config: Dictionary = {}) -> void:
	if config.is_empty():
		config = _runtime_config
	if config.is_empty():
		return
	my_mr_name = str(config.get("name", "噬火毒蝎"))
	level = int(config["level"])
	attack_in = int(config["attack"])
	max_hp = int(config["hp"])
	hp = max_hp
	def = int(config["def"])
	mdef = int(config["mdef"])
	crit = int(config["crit"])
	miss = int(config["miss"])
	htarget = int(config["hit"])
	toughness = float(config["toughness"])
	crit_reduce = int(config["crit_reduce"])
	ar = int(config["armor_break"])
	sp = int(config["magic_break"])
	speed = float(config["speed"])
	mysee = int(config["sight"])
	attack_range = int(config["range"])
	attack_desire = int(config["attack_desire"])
	add_exp = int(config["exp"])
	fall_coin = int(config["coin"])
	fall_pro = float(config["drop_rate"])
	fall_list = Array(config["drop_list"]).duplicate(true)
	independent_fall_list = Array(config.get("independent_drop_list", [])).duplicate(true)
	is_boss = bool(config["is_boss"])
	boss_max_protect = float(config["max_protect"])
	obj_attack_dict.clear()
	var attacks: Dictionary = config["attacks"]
	for attack_name: String in attacks:
		obj_attack_dict[attack_name] = _attack_data(attacks[attack_name])


func _attack_data(attack: Dictionary) -> Dictionary:
	return {
		"power": roundi(float(attack_in) * float(attack["multiplier"])),
		"hurtBack": Array(attack["hurt_back"]).duplicate(),
		"attackKind": str(attack["kind"]),
		"HitProtect": int(attack["protect"]),
	}


func monster_info_base_attack() -> int:
	return int(_runtime_config.get("attack", attack_in))


func monster_info_attack_values_include_difficulty() -> bool:
	return false


static func prewarm_frames() -> void:
	_get_sprite_frames()


static func prewarm_effects() -> void:
	pass


static func _load_standard_frames() -> SpriteFrames:
	var frames_path := ROOT.path_join("atlas/swf_png_3041_frames.tres")
	if not ResourceLoader.exists(frames_path):
		return null
	return load(frames_path) as SpriteFrames


static func _get_sprite_frames() -> SpriteFrames:
	if _frames_cache != null:
		return _frames_cache
	var standard := _load_standard_frames()
	if standard != null:
		_frames_cache = standard
		return standard
	return null


func _build_animations() -> void:
	var frames := _get_sprite_frames()
	if frames != null:
		mr_ani.sprite_frames = frames
		mr_ani.centered = true
		mr_ani.visible = true
	else:
		mr_ani.visible = false
	if mr_player.has_animation_library(&""):
		mr_player.remove_animation_library(&"")
	var library := AnimationLibrary.new()
	for action_name: StringName in ACTIONS:
		var info: Dictionary = ACTIONS[action_name]
		var animation := _make_animation(action_name, int(info["frames"]), bool(info["loop"]))
		match action_name:
			&"skill2":
				_add_method_key(animation, _frame_time(SKILL2_TRIGGER_FRAME), &"_start_skill2_travel")
			&"skill3":
				_add_method_key(animation, _frame_time(SKILL3_DASH_FRAME), &"_start_skill3_dash")
			&"death":
				_add_method_key(animation, animation.length - 0.001, &"settle_death_drops_and_free")
		library.add_animation(action_name, animation)
	mr_player.add_animation_library(&"", library)


func _make_animation(action_name: StringName, frame_count: int, looped: bool) -> Animation:
	var animation := Animation.new()
	animation.length = maxf(float(frame_count) / SOURCE_FPS, 0.05)
	animation.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
	_add_method_key(animation, 0.0, &"_play_body_action", [action_name])
	return animation


func _add_method_key(animation: Animation, time: float, method_name: StringName, args: Array = []) -> void:
	var track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track, NodePath("."))
	animation.track_insert_key(
		track, clampf(time, 0.0, maxf(animation.length - 0.001, 0.0)), {"method": method_name, "args": args}
	)


func _frame_time(frame_number: int) -> float:
	return float(maxi(frame_number - 1, 0)) / SOURCE_FPS


func _play_body_action(action_name: StringName) -> void:
	var info: Dictionary = ACTIONS.get(action_name, ACTIONS[&"wait"])
	if mr_ani.sprite_frames != null:
		mr_ani.visible = true
		mr_ani.position = info["offset"]
		mr_ani.play(action_name)


func ai_think() -> void:
	if _busy or death() or RoleProp.get_nearest_monster_target_position(global_position).x == null:
		return
	var distance := absf(float(RoleProp.get_nearest_monster_target_position(global_position).x) - position.x)
	has_target = distance <= float(mysee)
	if not has_target:
		stop_move()
		return
	_face_role()
	if Time.get_ticks_msec() < _next_attack_msec:
		stop_move()
		return
	var skill_index := _next_usable_skill(distance)
	if skill_index == 0:
		_move_toward_role()
		return
	_start_skill(skill_index)


func _next_usable_skill(distance: float) -> int:
	for step in range(3):
		var candidate := ((_skill_cycle + step) % 3) + 1
		match candidate:
			1:
				if distance <= 162.0:
					return candidate
			2:
				if distance >= 160.0 and distance <= 720.0:
					return candidate
			3:
				if distance >= 30.0 and distance <= 320.0:
					return candidate
	return 0


func _start_skill(skill_index: int) -> void:
	_attack_serial += 1
	var serial := _attack_serial
	_skill_cycle = skill_index % 3
	_busy = true
	is_attacking = true
	velocity = Vector2.ZERO
	_face_role()
	hit_name = "hit%d" % skill_index
	_disable_attack_box()
	if skill_index == 1:
		_set_attack_box(SKILL1_BOX_SIZE, SKILL1_BOX_POSITION)
		_enable_attack_box()
	if skill_index == 2:
		_skill2_sequence_active = true
	mr_player.play(StringName("skill%d" % skill_index))
	if skill_index == 2:
		await skill2_sequence_completed
	else:
		await mr_player.animation_finished
	if not is_instance_valid(self) or death() or serial != _attack_serial:
		return
	if _skill3_dash_active:
		_finish_skill3_dash()
	_disable_attack_box()
	_busy = false
	is_attacking = false
	velocity.x = 0.0
	_next_attack_msec = Time.get_ticks_msec() + AI_DELAY_MSEC
	mr_player.play(&"wait")


func _start_skill2_travel() -> void:
	if death() or not _skill2_sequence_active or _skill2_travel != null:
		return
	var target_x := global_position.x + 440.0 * _skill_direction
	if RoleProp.get_nearest_monster_target_position(global_position).x != null:
		target_x = float(RoleProp.get_nearest_monster_target_position(global_position).x)
	_skill2_travel = _spawn_projectile(
		{
			"position": global_position,
			"right": _skill_direction > 0.0,
			"hit_name": "hit2",
			"attack_data": _attack_entry(&"hit2"),
			"skill_name": "Emei3041Burrow",
			"frame_root": ROOT.path_join("effect2_1"),
			"frame_count": int(EFFECTS[&"effect2_1"]["frames"]),
			"loop_visual": true,
			"visual_offset": EFFECTS[&"effect2_1"]["offset"],
			"velocity": Vector2((target_x - global_position.x) / SKILL2_TRAVEL_DURATION, 0.0),
			"collision_size": Vector2(210.0, 60.0),
			"collision_offset": Vector2(0.0, -20.0),
			"lifetime": SKILL2_TRAVEL_DURATION,
			"damage_duration": SKILL2_TRAVEL_DURATION,
			"max_hits": 1,
			"expire_on_hit": false,
			"finished_callback": Callable(self, "_finish_skill2_travel"),
		}
	)


func _finish_skill2_travel(end_position: Vector2) -> void:
	_skill2_travel = null
	if death() or not _skill2_sequence_active:
		return
	global_position = end_position + Vector2(0.0, -50.0)
	mr_ani.visible = false
	_skill2_stone = _spawn_projectile(
		{
			"position": end_position,
			"right": _skill_direction > 0.0,
			"hit_name": "hit2_2",
			"attack_data": _attack_entry(&"hit2_2"),
			"skill_name": "Emei3041FireStone",
			"frame_root": ROOT.path_join("effect2_2"),
			"frame_count": int(EFFECTS[&"effect2_2"]["frames"]),
			"loop_visual": false,
			"visual_offset": EFFECTS[&"effect2_2"]["offset"],
			"collision_size": Vector2(120.0, 180.0),
			"collision_offset": Vector2(0.0, -90.0),
			"lifetime": SKILL2_STONE_DURATION,
			"damage_duration": SKILL2_STONE_DURATION,
			"max_hits": 1,
			"expire_on_hit": false,
			"finished_callback": Callable(self, "_finish_skill2_stone"),
		}
	)


func _finish_skill2_stone(_end_position: Vector2) -> void:
	_skill2_stone = null
	if not _skill2_sequence_active:
		return
	_skill2_sequence_active = false
	skill2_sequence_completed.emit()


func _start_skill3_dash() -> void:
	if death() or not _busy:
		return
	_set_attack_box(SKILL3_BOX_SIZE, SKILL3_BOX_POSITION)
	hit_name = "hit3"
	_skill3_dash_active = true
	_skill3_dash_time_left = SKILL3_DASH_DURATION
	velocity.x = SKILL3_DASH_SPEED * _skill_direction
	_enable_attack_box()


func _finish_skill3_dash() -> void:
	_skill3_dash_active = false
	_skill3_dash_time_left = 0.0
	velocity.x = 0.0
	_disable_attack_box()


func _spawn_projectile(config: Dictionary) -> NanhaiProjectile:
	var projectile := PROJECTILE_SCRIPT.new() as NanhaiProjectile
	config["owner"] = self
	config["damage_enabled"] = not (config["attack_data"] as Dictionary).is_empty()
	projectile.configure(config)
	bullet.add_child(projectile)
	return projectile


func _attack_entry(attack_name: StringName) -> Dictionary:
	var attack_key := str(attack_name)
	if obj_attack_dict.has(attack_key):
		return (obj_attack_dict[attack_key] as Dictionary).duplicate(true)
	push_error("EmeiBoss3041 level config is missing attack %s" % attack_name)
	return {}


func _set_attack_box(box_size: Vector2, box_position: Vector2) -> void:
	if hit_box == null:
		return
	var rectangle := hit_box.shape as RectangleShape2D
	if rectangle == null:
		rectangle = RectangleShape2D.new()
		hit_box.shape = rectangle
	rectangle.size = box_size
	hit_box.position = box_position


func _enable_attack_box() -> void:
	if hit_box != null:
		hit_box.set_deferred("disabled", false)


func _disable_attack_box() -> void:
	if hit_box != null:
		hit_box.set_deferred("disabled", true)


func _face_role() -> void:
	if RoleProp.get_nearest_monster_target_position(global_position).x == null:
		return
	_skill_direction = (
		1.0 if float(RoleProp.get_nearest_monster_target_position(global_position).x) >= global_position.x else -1.0
	)
	monster_dir.scale.x = _skill_direction
	base_damage_box.scale.x = -_skill_direction


func _move_toward_role() -> void:
	_face_role()
	velocity.x = speed * 10.0 * _skill_direction
	mr_player.play(&"walk")


func _physics_process(delta: float) -> void:
	if _skill3_dash_active and not death():
		velocity.x = SKILL3_DASH_SPEED * _skill_direction
	super._physics_process(delta)
	if _skill3_dash_active:
		_skill3_dash_time_left -= delta
		if death() or _skill3_dash_time_left <= 0.0:
			_finish_skill3_dash()


func state_hurt() -> void:
	if death() or _busy:
		return
	super.state_hurt()


func _finish_hurt_reaction(hurt_generation: int) -> void:
	super._finish_hurt_reaction(hurt_generation)
	velocity.x = 0.0


func state_death() -> void:
	if _death_started:
		return
	_death_started = true
	_attack_serial += 1
	_busy = true
	_finish_skill3_dash()
	_disable_attack_box()
	if _skill2_sequence_active:
		_skill2_sequence_active = false
		skill2_sequence_completed.emit()
	if _skill2_travel != null and is_instance_valid(_skill2_travel):
		_skill2_travel.queue_free()
	if _skill2_stone != null and is_instance_valid(_skill2_stone):
		_skill2_stone.queue_free()
	_skill2_travel = null
	_skill2_stone = null
	no_grav = false
	velocity = Vector2.ZERO
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)
	super.state_death()
