extends BaseMonster

const PROJECTILE_SCRIPT := preload("res://Script/monster/wutai_minghai_projectile.gd")
const ROOT := "res://Art/monster/swf_png/3078"
const FRAMES := ROOT + "/atlas/swf_png_3078_frames.tres"
const SOURCE_FPS := 24.0
const WALL_ID := 3082
const WALL_OFFSET_X := 550.0
const INITIAL_AI_DELAY_MSEC := 2000
const FULL_HP_CLAW_COOLDOWN_MSEC := 9000
const HALF_HP_CLAW_COOLDOWN_MSEC := 6000
const CLAW_SPAWN_DELAY := 1.0
const CLAW_FRAME_COUNT := 156
const GROUND_BASELINE_Y := 138.925

@export var monster_kind := 3078

static var _frames_cache: SpriteFrames

var _runtime_config: Dictionary = {}
var _effect_streams: Array[StreamedPngEffect] = []
var _walls: Array[BaseMonster] = []
var _busy := false
var _death_started := false
var _death_finished := false
var _walls_spawned := false
var _attack_serial := 0
var _next_wall_msec := 0
var _next_claw_msec := 0
var _next_decision_msec := 0
var _locked_claw_position := Vector2.ZERO


func _ready() -> void:
	no_grav = true
	super_armor_active = true
	_runtime_config = _resolve_runtime_config()
	if not _runtime_config.is_empty():
		_configure_form(_runtime_config)
	_build_animations()
	super._ready()
	_next_wall_msec = Time.get_ticks_msec() + INITIAL_AI_DELAY_MSEC
	_next_claw_msec = 2147483647
	_next_decision_msec = _next_wall_msec
	_enforce_source_direction()


func _resolve_runtime_config() -> Dictionary:
	var level_node := get_level_node()
	if level_node != null and level_node.has_method("get_level_monster_config"):
		var config: Variant = level_node.call("get_level_monster_config", monster_kind)
		if config is Dictionary and not config.is_empty():
			return (config as Dictionary).duplicate(true)
	push_error("WutaiEarthAncestor3078 requires level monster config for 3078")
	return {}


func _configure_form(config: Dictionary) -> void:
	my_mr_name = str(config.get("name", "土之祖巫"))
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
	var attacks: Dictionary = config.get("attacks", {})
	for attack_name: String in attacks:
		var attack: Dictionary = attacks[attack_name]
		obj_attack_dict[attack_name] = {
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
	var frames_path := ROOT.path_join("atlas/swf_png_3078_frames.tres")
	if not ResourceLoader.exists(frames_path):
		return null
	var source := load(frames_path) as SpriteFrames
	if source == null or not source.has_animation(&"idle"):
		return null
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	frames.add_animation(&"idle")
	frames.set_animation_speed(&"idle", source.get_animation_speed(&"idle"))
	frames.set_animation_loop(&"idle", true)
	for frame_index in range(source.get_frame_count(&"idle")):
		frames.add_frame(&"idle", source.get_frame_texture(&"idle", frame_index))
	if source.has_animation(&"death"):
		frames.add_animation(&"death")
		frames.set_animation_speed(&"death", source.get_animation_speed(&"death"))
		frames.set_animation_loop(&"death", false)
		for frame_index in range(source.get_frame_count(&"death")):
			frames.add_frame(&"death", source.get_frame_texture(&"death", frame_index))
	return frames


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
		mr_ani.position = Vector2(-12.0, -130.575)
		mr_ani.play(&"idle")
	else:
		mr_ani.visible = false
	if mr_player.has_animation_library(&""):
		mr_player.remove_animation_library(&"")
	var library := AnimationLibrary.new()
	library.add_animation(&"wait", _make_animation(41.0 / SOURCE_FPS, true, &"_show_idle"))
	library.add_animation(&"skill1", _make_animation(0.05, false, &"_spawn_stone_walls"))

	var claw_skill := _make_animation(41.0 / SOURCE_FPS, false, &"_begin_claw_skill")
	_add_method_key(claw_skill, CLAW_SPAWN_DELAY, &"_spawn_locked_claw")
	library.add_animation(&"skill2", claw_skill)

	var death_animation := _make_animation(50.0 / SOURCE_FPS, false, &"_begin_death_visual")
	_add_method_key(death_animation, death_animation.length - 0.001, &"_finish_final_death")
	library.add_animation(&"death", death_animation)
	mr_player.add_animation_library(&"", library)


func _make_animation(length: float, looped: bool, start_method: StringName) -> Animation:
	var animation := Animation.new()
	animation.length = maxf(length, 0.05)
	animation.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
	_add_method_key(animation, 0.0, start_method)
	return animation


func _add_method_key(animation: Animation, time: float, method_name: StringName, args: Array = []) -> void:
	var track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track, NodePath("."))
	animation.track_insert_key(
		track, clampf(time, 0.0, maxf(animation.length - 0.001, 0.0)), {"method": method_name, "args": args}
	)


func _show_idle() -> void:
	_clear_effect_streams()
	var body_offset := Vector2(-12.0, -130.575)
	if mr_ani.sprite_frames != null:
		mr_ani.visible = true
		mr_ani.position = body_offset
		mr_ani.play(&"idle")


func _begin_claw_skill() -> void:
	_show_idle()
	_locked_claw_position = global_position
	var role := get_player as Node2D
	if role != null and is_instance_valid(role):
		_locked_claw_position = Vector2(role.global_position.x, global_position.y + GROUND_BASELINE_Y)
	elif RoleProp.get_nearest_monster_target_position(global_position).x != null:
		_locked_claw_position = Vector2(
			float(RoleProp.get_nearest_monster_target_position(global_position).x),
			global_position.y + GROUND_BASELINE_Y
		)


func _spawn_locked_claw() -> void:
	if death():
		return
	var attack_data := _attack_entry(&"hit2")
	if attack_data.is_empty():
		return
	var claw := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	var configured := (
		claw
		. configure(
			{
				"owner": self,
				"position": _locked_claw_position,
				"right": true,
				"hit_name": "hit2",
				"attack_data": attack_data,
				"skill_name": "EarthAncestorStoneClaw",
				"visual_backend": WutaiMinghaiProjectile.VisualBackend.SPRITE_FRAMES,
				"frames_resource": FRAMES,
				"frames_animation": "claw",
				"frame_count": CLAW_FRAME_COUNT,
				"frame_fps": SOURCE_FPS,
				"loop_visual": false,
				"visual_offset": Vector2(7.0, -34.5),
				"lifetime": float(CLAW_FRAME_COUNT) / SOURCE_FPS,
				"damage_duration": float(CLAW_FRAME_COUNT) / SOURCE_FPS,
				"max_hits": 1,
				"expire_on_hit": false,
				"hit_callback": Callable(self, "_on_claw_hit"),
			}
		)
	)
	if not configured:
		claw.free()
		return
	bullet.add_child(claw)


func _on_claw_hit(_projectile: Node, role: BaseHero) -> void:
	if role == null or not is_instance_valid(role) or role.buff == null:
		return
	for buff_name in ["Immobilize", "silent"]:
		(
			Global
			. add_buff(
				role.buff,
				{
					"Name": buff_name,
					"AddTime": 5,
					"reduce_interval": 0,
					"value": 0,
					"AttackKind": "",
					"CanAdd": false,
					"DeBuff": true,
				}
			)
		)


func _spawn_stone_walls() -> void:
	if _walls_spawned or death() or get_parent() == null:
		return
	_walls_spawned = true
	for wall_data in [
		{"offset": -WALL_OFFSET_X, "direction": 1.0},
		{"offset": WALL_OFFSET_X, "direction": -1.0},
	]:
		var wall := Global.create_monster(WALL_ID, get_parent(), position + Vector2(float(wall_data["offset"]), 0.0))
		if not wall is BaseMonster:
			push_error("WutaiEarthAncestor3078 failed to create stone wall 3082")
			continue
		wall.set_meta("is_summon", true)
		if wall.has_method("configure_earth_wall"):
			wall.call("configure_earth_wall", self, float(wall_data["direction"]))
		_walls.append(wall)
	_enforce_source_direction()


func ai_think() -> void:
	velocity = Vector2.ZERO
	if (
		_busy
		or death()
		or _runtime_config.is_empty()
		or RoleProp.get_nearest_monster_target_position(global_position).x == null
	):
		return
	has_target = (
		absf(float(RoleProp.get_nearest_monster_target_position(global_position).x) - position.x) <= float(mysee)
	)
	if not has_target:
		return
	var now := Time.get_ticks_msec()
	if now < _next_decision_msec:
		return
	if not _walls_spawned:
		if now >= _next_wall_msec:
			_start_skill(1)
		return
	if now >= _next_claw_msec:
		_start_skill(2)


func _start_skill(skill_index: int) -> void:
	_attack_serial += 1
	var serial := _attack_serial
	_busy = true
	is_attacking = true
	velocity = Vector2.ZERO
	if skill_index == 2:
		_next_claw_msec = Time.get_ticks_msec() + _current_claw_cooldown_msec()
	mr_player.play(StringName("skill%d" % skill_index))
	await mr_player.animation_finished
	if not is_instance_valid(self) or death() or serial != _attack_serial:
		return
	var now := Time.get_ticks_msec()
	if skill_index == 1:
		_next_claw_msec = now + randi_range(3000, 6000)
		_next_decision_msec = _next_claw_msec
	elif hp > max_hp * 0.5:
		_next_decision_msec = now + randi_range(3000, 6000)
	else:
		_next_decision_msec = now + randi_range(2000, 4000)
	_busy = false
	is_attacking = false
	mr_player.play(&"wait")


func _current_claw_cooldown_msec() -> int:
	return FULL_HP_CLAW_COOLDOWN_MSEC if hp > max_hp * 0.5 else HALF_HP_CLAW_COOLDOWN_MSEC


func _attack_entry(attack_name: StringName) -> Dictionary:
	var key := str(attack_name)
	if obj_attack_dict.has(key):
		return (obj_attack_dict[key] as Dictionary).duplicate(true)
	push_error("WutaiEarthAncestor3078 level config is missing attack %s" % key)
	return {}


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_enforce_source_direction()


func _enforce_source_direction() -> void:
	monster_dir.scale.x = -1.0
	base_damage_box.scale.x = 1.0
	velocity = Vector2.ZERO


func is_control_immune() -> bool:
	return true


func state_hurt() -> void:
	pass


func _interrupt_attack_state_on_hit() -> void:
	pass


func _enforce_control_immunity_state() -> void:
	super._enforce_control_immunity_state()
	if _hurt_reaction_active:
		_cancel_hurt_reaction()


func is_alive_for_stage_clear() -> bool:
	return not _death_finished


func state_death() -> void:
	if _death_started:
		return
	_death_started = true
	_attack_serial += 1
	_busy = true
	is_attacking = false
	velocity = Vector2.ZERO
	_clear_walls()
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)
	if pz != null:
		pz.set_deferred("disabled", true)
	super.state_death()


func _begin_death_visual() -> void:
	_clear_effect_streams()
	if mr_ani.sprite_frames != null and mr_ani.sprite_frames.has_animation(&"death"):
		mr_ani.visible = true
		mr_ani.position = Vector2(-12.0, -127.575)
		mr_ani.play(&"death")


func _finish_final_death() -> void:
	if _death_finished:
		return
	_death_finished = true
	settle_death_drops_and_free()


func _clear_walls() -> void:
	for wall in _walls:
		if wall != null and is_instance_valid(wall):
			wall.queue_free()
	_walls.clear()


func _clear_effect_streams() -> void:
	for stream in _effect_streams:
		if stream != null and is_instance_valid(stream):
			stream.clear_texture()
			stream.queue_free()
	_effect_streams.clear()


func _exit_tree() -> void:
	_clear_walls()
	_clear_effect_streams()
