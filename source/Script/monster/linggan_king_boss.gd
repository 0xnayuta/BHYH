extends BaseMonster
class_name LingganKingBoss

const PROJECTILE_SCRIPT := preload("res://Script/monster/nanhai_projectile.gd")
const ROOT := "res://Art/monster/swf_png/3033"
const SOURCE_FPS := 30.0
const BASE_ATTACK := 32000
const SKILL2_DASH_SPEED := 360.0
const SKILL2_DASH_DURATION := 1.5
const SKILL2_HIT_COUNT := 10
const SKILL2_HIT_INTERVAL := 0.15
const SKILL2_HIT_BOX_SIZE := Vector2(291.0, 192.0)
const SKILL2_HIT_BOX_POSITION := Vector2(0.0, -67.45)
const DEFAULT_HIT_BOX_SIZE := Vector2(127.0, 150.0)
const DEFAULT_HIT_BOX_POSITION := Vector2(-63.5, -75.0)
const SKILL4_LEAP_DURATION := 1.0

signal skill2_dash_completed
signal skill4_leap_completed

const ACTIONS := {
	&"wait": {"folder": "wait", "frames": 20, "offset": Vector2(11.9, -52.65), "loop": true},
	&"walk": {"folder": "walk", "frames": 16, "offset": Vector2(12.65, -54.4), "loop": true},
	&"hurt": {"folder": "hurt", "frames": 20, "offset": Vector2(-23.7, -64.0), "loop": false},
	&"death": {"folder": "death", "frames": 20, "offset": Vector2(-20.55, -37.15), "loop": false},
	&"skill1": {"folder": "effect1", "frames": 40, "offset": Vector2(61.3, -81.05), "loop": false},
	&"skill2": {"folder": "effect2", "frames": 43, "offset": Vector2(3.05, -67.45), "loop": false},
	&"skill3": {"folder": "effect3", "frames": 52, "offset": Vector2(1.8, -56.85), "loop": false},
	&"skill4": {"folder": "effect4", "frames": 100, "offset": Vector2.ZERO, "loop": false},
}

const EFFECTS := {
	"arrow1": {"frames": 8, "offset": Vector2(1.0, -1.5)},
	"arrow2": {"frames": 11, "offset": Vector2(4.55, -15.2)},
	"effect4_1": {"frames": 23, "offset": Vector2(2.7, -55.05)},
}

var monster_kind := 3033
static var _frames_cache: SpriteFrames

var _busy := false
var _death_started := false
var _attack_serial := 0
var _skill_cycle := 0
var _next_attack_msec := 0
var _skill2_dash_active := false
var _skill2_dash_time_left := 0.0
var _skill2_dash_direction := 0.0
var _skill4_leap_active := false
var _skill_direction := -1.0
var _runtime_config: Dictionary = {}


func _ready() -> void:
	_runtime_config = _resolve_runtime_config()
	_configure_boss()
	_build_animations()
	super._ready()


func _configure_boss() -> void:
	if _runtime_config.is_empty():
		_runtime_config = _resolve_runtime_config()
	if _runtime_config.is_empty():
		return
	var config := _runtime_config
	my_mr_name = str(config.get("name", "灵感大王"))
	level = int(config["level"])
	attack_in = int(config["attack"])
	max_hp = int(config["hp"])
	hp = max_hp
	def = int(config["def"])
	mdef = int(config["mdef"])
	crit = int(config["crit"])
	miss = int(config["miss"])
	htarget = int(config["hit"])
	toughness = float(config.get("toughness", 0.0))
	crit_reduce = int(config.get("crit_reduce", 0))
	ar = int(config["armor_break"])
	sp = int(config["magic_break"])
	speed = float(config["speed"])
	mysee = int(config["sight"])
	attack_range = int(config["range"])
	attack_desire = int(config["attack_desire"])
	add_exp = int(config.get("exp", 0))
	fall_coin = int(config.get("coin", 0))
	fall_pro = float(config.get("drop_rate", 0.0))
	fall_list = Array(config.get("drop_list", [])).duplicate(true)
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


func _resolve_runtime_config() -> Dictionary:
	var config := {
		"name": "灵感大王",
		"level": 90,
		"hp": 12000000,
		"attack": BASE_ATTACK,
		"def": 3200,
		"mdef": 3200,
		"crit": 700,
		"miss": 160,
		"hit": 480,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 3000,
		"magic_break": 3000,
		"speed": 5.0,
		"range": 999.0,
		"sight": 1200.0,
		"attack_desire": 100,
		"exp": 0,
		"coin": 0,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": true,
		"max_protect": 240.0,
		"attacks":
		{
			"hit1": {"multiplier": 0.5, "hurt_back": [-5, -2], "kind": "physics", "protect": 6668},
			"hit2": {"multiplier": 0.15, "hurt_back": [-3, -1], "kind": "physics", "protect": 6668},
			"hit3": {"multiplier": 1.0, "hurt_back": [-3, -2], "kind": "magic", "protect": 6668},
			"hit4": {"multiplier": 1.0, "hurt_back": [-5, -3], "kind": "physics", "protect": 6668},
		},
	}
	var level_node := get_level_node()
	if level_node != null and level_node.has_method("get_level_monster_config"):
		var level_config: Variant = level_node.call("get_level_monster_config", monster_kind)
		if level_config is Dictionary and not level_config.is_empty():
			config.merge(level_config, true)
	return config


func monster_info_base_attack() -> int:
	return int(_runtime_config.get("attack", BASE_ATTACK))


func monster_info_attack_values_include_difficulty() -> bool:
	return false


static func prewarm_frames() -> void:
	_get_sprite_frames()


static func prewarm_effects() -> void:
	pass


static func _load_standard_frames() -> SpriteFrames:
	var frames_path := ROOT.path_join("atlas/swf_png_3033_frames.tres")
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
			&"skill1":
				_add_attack_pulse(animation, 14, &"hit1", 0.18)
				_add_attack_pulse(animation, 34, &"hit1", 0.18)
			&"skill2":
				_add_method_key(animation, _frame_time(9), &"_start_heavy_hammer_dash")
			&"skill3":
				_add_method_key(animation, _frame_time(31), &"_fire_water_ball")
			&"skill4":
				_add_method_key(animation, 0.0, &"_start_fish_leap")
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


func _add_attack_pulse(animation: Animation, frame_number: int, attack_name: StringName, duration: float) -> void:
	_add_method_key(animation, _frame_time(frame_number), &"_enable_attack_box", [attack_name])
	_add_method_key(
		animation, minf(_frame_time(frame_number) + duration, animation.length - 0.001), &"_disable_attack_box"
	)


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
		mr_ani.position = _mirrored_offset(info["offset"])
		mr_ani.play(action_name)


func _mirrored_offset(source_offset: Vector2) -> Vector2:
	var result := source_offset
	if monster_dir.scale.x < 0.0:
		result.x = -result.x
	return result


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
		have_target()
		return
	_start_skill(skill_index)


func _next_usable_skill(distance: float) -> int:
	for step in range(4):
		var candidate := ((_skill_cycle + step) % 4) + 1
		match candidate:
			1:
				if distance <= 127.0:
					return candidate
			2:
				if distance <= 720.0:
					return candidate
			3:
				if distance >= 60.0 and distance <= 999.0:
					return candidate
			4:
				return candidate
	return 0


func _start_skill(skill_index: int) -> void:
	_attack_serial += 1
	var serial := _attack_serial
	_skill_cycle = skill_index % 4
	_busy = true
	is_attacking = true
	velocity = Vector2.ZERO
	_face_role()
	hit_name = "hit%d" % skill_index
	mr_player.play(StringName("skill%d" % skill_index))
	if skill_index == 4:
		await skill4_leap_completed
	else:
		await mr_player.animation_finished
	if not is_instance_valid(self) or death() or serial != _attack_serial:
		return
	if skill_index == 2 and _skill2_dash_active:
		await skill2_dash_completed
		if not is_instance_valid(self) or death() or serial != _attack_serial:
			return
	_disable_attack_box()
	_busy = false
	is_attacking = false
	_next_attack_msec = Time.get_ticks_msec() + 1000
	mr_player.play(&"wait")


func _enable_attack_box(attack_name: StringName) -> void:
	hit_name = str(attack_name)
	if hit_box != null:
		hit_box.set_deferred("disabled", false)


func _disable_attack_box() -> void:
	if hit_box != null:
		hit_box.set_deferred("disabled", true)


func _start_heavy_hammer_dash() -> void:
	if death() or _skill2_dash_active:
		return
	_skill2_dash_active = true
	_skill2_dash_time_left = SKILL2_DASH_DURATION
	_skill2_dash_direction = _facing_sign()
	_set_skill2_hit_box(true)
	velocity.x = SKILL2_DASH_SPEED * _skill2_dash_direction
	_run_skill2_hit_pulses(_attack_serial)


func _run_skill2_hit_pulses(serial: int) -> void:
	var next_pulse_msec := Time.get_ticks_msec()
	for pulse_index in range(SKILL2_HIT_COUNT):
		if death() or serial != _attack_serial or not _skill2_dash_active:
			return
		_enable_attack_box(&"hit2")
		await get_tree().physics_frame
		await get_tree().physics_frame
		if not is_instance_valid(self) or serial != _attack_serial:
			return
		_disable_attack_box()
		if pulse_index + 1 < SKILL2_HIT_COUNT:
			next_pulse_msec += roundi(SKILL2_HIT_INTERVAL * 1000.0)
			var delay := maxf(float(next_pulse_msec - Time.get_ticks_msec()) / 1000.0, 0.0)
			if delay > 0.0:
				await get_tree().create_timer(delay).timeout


func _finish_skill2_dash() -> void:
	_skill2_dash_active = false
	_skill2_dash_time_left = 0.0
	velocity.x = 0.0
	_disable_attack_box()
	_set_skill2_hit_box(false)
	skill2_dash_completed.emit()


func _fire_water_ball() -> void:
	if death():
		return
	var facing := _facing_sign()
	var target_x := global_position.x + 500.0 * facing
	if RoleProp.get_nearest_monster_target_position(global_position).x != null:
		target_x = float(RoleProp.get_nearest_monster_target_position(global_position).x)
	var duration := 1.2
	_spawn_projectile(
		{
			"position": global_position + Vector2(65.0 * facing, -65.0),
			"right": facing > 0.0,
			"hit_name": "hit3",
			"attack_data": obj_attack_dict["hit3"],
			"skill_name": "LingganWaterBall",
			"frame_root": ROOT.path_join("arrow1"),
			"frame_count": int(EFFECTS["arrow1"]["frames"]),
			"visual_offset": EFFECTS["arrow1"]["offset"],
			"impact_frame_root": ROOT.path_join("arrow2"),
			"impact_frame_count": int(EFFECTS["arrow2"]["frames"]),
			"impact_visual_offset": EFFECTS["arrow2"]["offset"],
			"velocity": Vector2((target_x - global_position.x) / duration, -80.0),
			"acceleration": Vector2(0.0, 135.0),
			"orient_to_motion": true,
			"collision_size": Vector2(82.0, 82.0),
			"lifetime": duration,
			"damage_duration": duration,
		}
	)


func _start_fish_leap() -> void:
	if death():
		return
	_skill4_leap_active = true
	var facing := _facing_sign()
	var target := global_position + Vector2(260.0 * facing, -100.0)
	if RoleProp.get_nearest_monster_target_position(global_position).x != null:
		target.x = float(RoleProp.get_nearest_monster_target_position(global_position).x)
	if RoleProp.get_nearest_monster_target_position(global_position).y != null:
		target.y = float(RoleProp.get_nearest_monster_target_position(global_position).y) - 35.0
	var projectile := _spawn_projectile(
		{
			"position": global_position,
			"right": facing > 0.0,
			"hit_name": "hit4",
			"attack_data": obj_attack_dict["hit4"],
			"skill_name": "LingganFishLeap",
			"frame_root": ROOT.path_join("effect4_1"),
			"frame_count": int(EFFECTS["effect4_1"]["frames"]),
			"visual_offset": EFFECTS["effect4_1"]["offset"],
			"velocity": (target - global_position) / SKILL4_LEAP_DURATION,
			"collision_size": Vector2(120.0, 115.0),
			"collision_offset": Vector2(0.0, -50.0),
			"lifetime": SKILL4_LEAP_DURATION,
			"damage_duration": SKILL4_LEAP_DURATION,
			"expire_on_hit": false,
			"finished_callback": Callable(self, "_finish_fish_leap"),
		}
	)
	if projectile != null:
		mr_ani.visible = false


func _finish_fish_leap(end_position: Vector2) -> void:
	if not _skill4_leap_active:
		return
	_skill4_leap_active = false
	if not death():
		global_position = end_position
	mr_ani.visible = true
	skill4_leap_completed.emit()


func _spawn_projectile(config: Dictionary) -> NanhaiProjectile:
	var projectile := PROJECTILE_SCRIPT.new() as NanhaiProjectile
	config["owner"] = self
	projectile.configure(config)
	bullet.add_child(projectile)
	return projectile


func _facing_sign() -> float:
	return _skill_direction


func _face_role() -> void:
	if RoleProp.get_nearest_monster_target_position(global_position).x == null:
		return
	_skill_direction = (
		1.0 if float(RoleProp.get_nearest_monster_target_position(global_position).x) >= global_position.x else -1.0
	)
	monster_dir.scale.x = _skill_direction
	base_damage_box.scale.x = -_skill_direction


func _set_skill2_hit_box(active: bool) -> void:
	if hit_box == null:
		return
	var rectangle := hit_box.shape as RectangleShape2D
	if rectangle == null:
		return
	if active:
		rectangle.size = SKILL2_HIT_BOX_SIZE
		hit_box.position = SKILL2_HIT_BOX_POSITION
	else:
		rectangle.size = DEFAULT_HIT_BOX_SIZE
		hit_box.position = DEFAULT_HIT_BOX_POSITION


func _physics_process(delta: float) -> void:
	if _skill2_dash_active and not death():
		velocity.x = SKILL2_DASH_SPEED * _skill2_dash_direction
	super._physics_process(delta)
	if _skill2_dash_active:
		_skill2_dash_time_left -= delta
		if death() or _skill2_dash_time_left <= 0.0:
			_finish_skill2_dash()


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
	if _skill4_leap_active:
		_skill4_leap_active = false
		skill4_leap_completed.emit()
	_finish_skill2_dash()
	_disable_attack_box()
	no_grav = false
	velocity = Vector2.ZERO
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)
	super.state_death()


func get_ice_effect_offset() -> Vector2:
	return Vector2(0.0, -105.0)
