extends BaseMonster

const PROJECTILE_SCRIPT := preload("res://Script/monster/wutai_minghai_projectile.gd")
const ROOT := "res://Art/monster/swf_png/3077"
const TORNADO_FRAMES := ROOT + "/tornado/tornado_frames.tres"
const SOURCE_FPS := 30.0
const NEXT_FORM_ID := 3078
const SMALL_WIND_ID := 3080
const LARGE_WIND_ID := 3081
const SMALL_WIND_COOLDOWN_MSEC := 6000
const LARGE_WIND_COOLDOWN_MSEC := 24000
const TORNADO_COOLDOWN_MSEC := 6000

@export var monster_kind := 3077

static var _frames_cache: SpriteFrames

var _runtime_config: Dictionary = {}
var _body_stream: StreamedPngEffect
var _effect_streams: Array[StreamedPngEffect] = []
var _summons: Array[BaseMonster] = []
var _busy := false
var _death_started := false
var _transition_spawned := false
var _transition_attempted := false
var _attack_serial := 0
var _next_small_wind_msec := 0
var _next_large_wind_msec := 0
var _next_tornado_msec := 0
var _locked_tornado_position := Vector2.ZERO


func _ready() -> void:
	no_grav = true
	super_armor_active = true
	_runtime_config = _resolve_runtime_config()
	if not _runtime_config.is_empty():
		_configure_form(_runtime_config)
	_build_animations()
	super._ready()
	var first_skill_msec := Time.get_ticks_msec() + 1000
	_next_small_wind_msec = first_skill_msec
	_next_large_wind_msec = first_skill_msec
	_next_tornado_msec = first_skill_msec
	_enforce_source_direction()


func _resolve_runtime_config() -> Dictionary:
	var level_node := get_level_node()
	if level_node != null and level_node.has_method("get_level_monster_config"):
		var config: Variant = level_node.call("get_level_monster_config", monster_kind)
		if config is Dictionary and not config.is_empty():
			return (config as Dictionary).duplicate(true)
	push_error("WutaiEarthAncestor3077 requires level monster config for 3077")
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
	FrameSequenceStore.get_sequence(ROOT.path_join("idle"), SOURCE_FPS, true, false, 2)


static func prewarm_effects() -> void:
	if ResourceLoader.exists(TORNADO_FRAMES):
		ResourceLoader.load(TORNADO_FRAMES)
	prewarm_frames()
	for folder in ["eye12", "eye3", "skill1", "skill3"]:
		FrameSequenceStore.get_sequence(ROOT.path_join(folder), SOURCE_FPS, false, false, 2)


static func _load_standard_frames() -> SpriteFrames:
	var frames_path := ROOT.path_join("atlas/swf_png_3077_frames.tres")
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
	if source.has_animation(&"mc_dead"):
		frames.add_animation(&"death")
		frames.set_animation_speed(&"death", source.get_animation_speed(&"mc_dead"))
		frames.set_animation_loop(&"death", false)
		for frame_index in range(source.get_frame_count(&"mc_dead")):
			frames.add_frame(&"death", source.get_frame_texture(&"mc_dead", frame_index))
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
		mr_ani.position = Vector2(3.45, -140.65)
		mr_ani.play(&"idle")
	else:
		mr_ani.visible = false
	if mr_player.has_animation_library(&""):
		mr_player.remove_animation_library(&"")
	var library := AnimationLibrary.new()
	library.add_animation(&"wait", _make_animation(1.0 / SOURCE_FPS, true, &"_show_idle"))
	library.add_animation(&"skill1", _make_animation(27.0 / SOURCE_FPS, false, &"_begin_small_wind_skill"))

	var large_wind := _make_animation(1.001, false, &"_begin_large_wind_skill")
	_add_method_key(large_wind, 1.0, &"_spawn_large_wind")
	library.add_animation(&"skill2", large_wind)

	var tornado := _make_animation(1.321, false, &"_begin_tornado_skill")
	_add_method_key(tornado, 1.32, &"_spawn_locked_tornado")
	library.add_animation(&"skill3", tornado)

	var death_animation := _make_animation(10.0 / SOURCE_FPS, false, &"_begin_death_visual")
	_add_method_key(death_animation, death_animation.length - 0.001, &"_finish_phase_transition")
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
	var body_offset := Vector2(3.45, -140.65)
	if mr_ani.sprite_frames != null:
		mr_ani.visible = true
		mr_ani.position = body_offset
		mr_ani.play(&"idle")
		return
	if _body_stream == null or not is_instance_valid(_body_stream):
		_body_stream = _create_stream("idle", body_offset, true, false)
	_body_stream.position = body_offset
	_body_stream.visible = true


func _begin_small_wind_skill() -> void:
	_show_idle()
	_add_effect_stream("eye12", Vector2(-8.55, -124.25))
	_add_effect_stream("skill1", Vector2.ZERO)
	_spawn_wind(SMALL_WIND_ID, Vector2(550.0, 0.0), -1.0, 12.0)


func _begin_large_wind_skill() -> void:
	_show_idle()
	_add_effect_stream("eye12", Vector2(-8.55, -124.25))


func _spawn_large_wind() -> void:
	if not death():
		_spawn_wind(LARGE_WIND_ID, Vector2(-650.0, 0.0), 1.0, 24.0)


func _begin_tornado_skill() -> void:
	_show_idle()
	_add_effect_stream("eye3", Vector2(-8.75, -208.7))
	_add_effect_stream("skill3", Vector2.ZERO)
	_locked_tornado_position = global_position
	var role := get_player as Node2D
	if role != null and is_instance_valid(role):
		_locked_tornado_position = role.global_position
	elif (
		RoleProp.get_nearest_monster_target_position(global_position).x != null
		and RoleProp.get_nearest_monster_target_position(global_position).y != null
	):
		_locked_tornado_position = Vector2(
			float(RoleProp.get_nearest_monster_target_position(global_position).x),
			float(RoleProp.get_nearest_monster_target_position(global_position).y)
		)


func _spawn_locked_tornado() -> void:
	if death():
		return
	var attack_data := _attack_entry(&"hit3")
	if attack_data.is_empty():
		return
	var projectile := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	(
		projectile
		. configure(
			{
				"owner": self,
				"position": _locked_tornado_position,
				"right": true,
				"hit_name": "hit3",
				"attack_data": attack_data,
				"skill_name": "EarthAncestorTornado",
				"frames_resource": TORNADO_FRAMES,
				"frames_animation": "tornado",
				"atlas_sequence": "tornado",
				"frame_fps": SOURCE_FPS,
				"loop_visual": false,
				"visual_offset": Vector2(0.0, -136.0),
				"lifetime": 0.7,
				"damage_duration": 0.7,
				"damage_pulse_interval": 0.2,
				"max_hits": 2,
				"expire_on_hit": false,
			}
		)
	)
	bullet.add_child(projectile)


func _spawn_wind(monster_id: int, offset: Vector2, direction: float, lifetime: float) -> void:
	if get_parent() == null:
		return
	var wind := Global.create_monster(monster_id, get_parent(), position + offset)
	if not wind is BaseMonster:
		push_error("WutaiEarthAncestor3077 failed to create wind %d" % monster_id)
		return
	wind.set_meta("is_summon", true)
	if wind.has_method("configure_earth_wind"):
		wind.call("configure_earth_wind", self, direction, lifetime)
	_summons.append(wind)


func _add_effect_stream(folder: String, offset: Vector2) -> void:
	_effect_streams.append(_create_stream(folder, offset, false, true))


func _create_stream(folder: String, offset: Vector2, looped: bool, auto_free: bool) -> StreamedPngEffect:
	var stream := StreamedPngEffect.new()
	stream.sequence = FrameSequenceStore.get_sequence(ROOT.path_join(folder), SOURCE_FPS, looped, false, 2)
	stream.auto_free = auto_free
	stream.position = offset
	monster_dir.add_child(stream)
	return stream


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
	if now >= _next_small_wind_msec:
		_start_skill(1)
	elif now >= _next_large_wind_msec:
		_start_skill(2)
	elif now >= _next_tornado_msec:
		_start_skill(3)


func _start_skill(skill_index: int) -> void:
	_attack_serial += 1
	var serial := _attack_serial
	_busy = true
	is_attacking = true
	velocity = Vector2.ZERO
	mr_player.play(StringName("skill%d" % skill_index))
	await mr_player.animation_finished
	if not is_instance_valid(self) or death() or serial != _attack_serial:
		return
	var now := Time.get_ticks_msec()
	match skill_index:
		1:
			_next_small_wind_msec = now + SMALL_WIND_COOLDOWN_MSEC
		2:
			_next_large_wind_msec = now + LARGE_WIND_COOLDOWN_MSEC
		3:
			_next_tornado_msec = now + TORNADO_COOLDOWN_MSEC
	_busy = false
	is_attacking = false
	mr_player.play(&"wait")


func _attack_entry(attack_name: StringName) -> Dictionary:
	var key := str(attack_name)
	if obj_attack_dict.has(key):
		return (obj_attack_dict[key] as Dictionary).duplicate(true)
	push_error("WutaiEarthAncestor3077 level config is missing attack %s" % key)
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
	return not _transition_spawned


func state_death() -> void:
	if _death_started:
		return
	_death_started = true
	_transition_attempted = true
	var next_form := Global.create_monster(NEXT_FORM_ID, get_parent(), position + Vector2(0.0, -10.0))
	if not next_form is BaseMonster:
		push_error("WutaiEarthAncestor3077 failed to create third form 3078")
		return
	for metadata_name in [&"source_birth_point", &"source_stage"]:
		if has_meta(metadata_name):
			next_form.set_meta(metadata_name, get_meta(metadata_name))
	_transition_spawned = true
	_attack_serial += 1
	_busy = true
	is_attacking = false
	velocity = Vector2.ZERO
	_clear_summons()
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)
	if pz != null:
		pz.set_deferred("disabled", true)
	mr_player.play(&"death")


func _begin_death_visual() -> void:
	_clear_effect_streams()


func _finish_phase_transition() -> void:
	if _transition_spawned and not is_queued_for_deletion():
		queue_free()


func _clear_summons() -> void:
	for summon in _summons:
		if summon != null and is_instance_valid(summon):
			summon.queue_free()
	_summons.clear()


func _clear_effect_streams() -> void:
	for stream in _effect_streams:
		if stream != null and is_instance_valid(stream):
			stream.clear_texture()
			stream.queue_free()
	_effect_streams.clear()


func _clear_body_stream() -> void:
	if _body_stream != null and is_instance_valid(_body_stream):
		_body_stream.clear_texture()
		_body_stream.queue_free()
	_body_stream = null


func _exit_tree() -> void:
	_clear_effect_streams()
	_clear_body_stream()
