extends BaseMonster

const ROOT := "res://Art/monster/swf_png/3071"
const FRAMES_RES := ROOT + "/atlas/swf_png_3071_frames.tres"
const SOURCE_FPS := 30.0
const GUARDIAN_ID := 3076
const NEXT_FORM_ID := 3077
const GUARDIAN_OFFSETS := [Vector2(-325.0, -100.0), Vector2(325.0, -100.0)]

const ACTIONS := {
	&"wait": {"folder": "idle", "frames": 1, "offset": Vector2(5.0, -130.45), "loop": true},
	&"death": {"folder": "death", "frames": 50, "offset": Vector2(4.5, -130.45), "loop": false},
}

@export var monster_kind := 3071

var _runtime_config: Dictionary = {}
var _body_sprite: AnimatedSprite2D
var _guardians: Array[BaseMonster] = []
var _spawn_completed := false
var _death_started := false
var _transition_spawned := false
var _transition_attempted := false
var _prewarm_requested := false


func _ready() -> void:
	super_armor_active = true
	no_grav = true
	_runtime_config = _resolve_runtime_config()
	if not _runtime_config.is_empty():
		_configure_ancestor(_runtime_config)
	_build_animations()
	mr_ani.visible = false
	super._ready()
	_spawn_guardians.call_deferred()
	_prewarm_followup_resources.call_deferred()


func _resolve_runtime_config() -> Dictionary:
	var level_node := get_level_node()
	if level_node != null and level_node.has_method("get_level_monster_config"):
		var config: Variant = level_node.call("get_level_monster_config", monster_kind)
		if config is Dictionary and not config.is_empty():
			return (config as Dictionary).duplicate(true)
	push_error("WutaiEarthAncestor3071 requires level monster config for 3071")
	return {}


func _configure_ancestor(config: Dictionary) -> void:
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


func _configure_boss(config: Dictionary = {}) -> void:
	if config.is_empty():
		config = _runtime_config
	if not config.is_empty():
		_configure_ancestor(config)


func monster_info_base_attack() -> int:
	return int(_runtime_config.get("attack", attack_in))


func monster_info_attack_values_include_difficulty() -> bool:
	return false


static func prewarm_frames() -> void:
	if ResourceLoader.exists(FRAMES_RES):
		load(FRAMES_RES)


static func prewarm_effects() -> void:
	pass


func _build_animations() -> void:
	if mr_player.has_animation_library(&""):
		mr_player.remove_animation_library(&"")
	var library := AnimationLibrary.new()
	for action_name: StringName in ACTIONS:
		var info: Dictionary = ACTIONS[action_name]
		var animation := Animation.new()
		animation.length = maxf(float(info["frames"]) / SOURCE_FPS, 0.05)
		animation.loop_mode = Animation.LOOP_LINEAR if bool(info["loop"]) else Animation.LOOP_NONE
		_add_method_key(animation, 0.0, &"_play_body_action", [action_name])
		if action_name == &"death":
			_add_method_key(animation, animation.length - 0.001, &"_finish_phase_transition")
		library.add_animation(action_name, animation)
	mr_player.add_animation_library(&"", library)


func _add_method_key(animation: Animation, time: float, method_name: StringName, args: Array = []) -> void:
	var track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track, NodePath("."))
	animation.track_insert_key(
		track, clampf(time, 0.0, maxf(animation.length - 0.001, 0.0)), {"method": method_name, "args": args}
	)


func _play_body_action(action_name: StringName) -> void:
	_clear_body_stream()
	var info: Dictionary = ACTIONS.get(action_name, ACTIONS[&"wait"])
	var animation := StringName(str(info["folder"]))
	if ResourceLoader.exists(FRAMES_RES):
		var frames := load(FRAMES_RES) as SpriteFrames
		if frames != null and frames.has_animation(animation):
			var sprite := AnimatedSprite2D.new()
			sprite.name = "BodyFrames"
			sprite.sprite_frames = frames
			sprite.animation = animation
			var base_speed := frames.get_animation_speed(animation)
			if base_speed > 0.0:
				sprite.speed_scale = SOURCE_FPS / base_speed
			sprite.position = info["offset"]
			monster_dir.add_child(sprite)
			_body_sprite = sprite
			return


func _spawn_guardians() -> void:
	if _spawn_completed or _death_started or get_parent() == null:
		return
	_spawn_completed = true
	for offset in GUARDIAN_OFFSETS:
		var guardian := Global.create_monster(GUARDIAN_ID, get_parent(), position + offset)
		if guardian is BaseMonster:
			guardian.set_meta("earth_ancestor_guardian", true)
			_guardians.append(guardian)
		else:
			push_error("WutaiEarthAncestor3071 failed to create guardian 3076")


func _prewarm_followup_resources() -> void:
	if _prewarm_requested:
		return
	_prewarm_requested = true
	await (
		Global
		. preload_level_monster_runtime_resources(
			[
				3076,
				3077,
				3078,
				3080,
				3081,
				3082,
			]
		)
	)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _transition_spawned or _transition_attempted or not _spawn_completed:
		return
	if _guardians.size() == GUARDIAN_OFFSETS.size() and _guardians_are_dead():
		_begin_guardian_transition()


func _guardians_are_dead() -> bool:
	for guardian in _guardians:
		if guardian != null and is_instance_valid(guardian) and not guardian.death():
			return false
	return true


func _begin_guardian_transition() -> void:
	if _transition_spawned or _transition_attempted or get_parent() == null:
		return
	_transition_attempted = true
	var next_form := Global.create_monster(NEXT_FORM_ID, get_parent(), position)
	if not next_form is BaseMonster:
		push_error("WutaiEarthAncestor3071 failed to create second form 3077")
		return
	_copy_stage_metadata(next_form)
	_transition_spawned = true
	_death_started = true
	hp = 0
	velocity = Vector2.ZERO
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)
	mr_player.play(&"death")


func _copy_stage_metadata(next_form: BaseMonster) -> void:
	for metadata_name in [&"source_birth_point", &"source_stage"]:
		if has_meta(metadata_name):
			next_form.set_meta(metadata_name, get_meta(metadata_name))


func is_alive_for_stage_clear() -> bool:
	return not _transition_spawned


func ai_think() -> void:
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


func state_death() -> void:
	if _death_started:
		return
	if _spawn_completed and _guardians.size() == GUARDIAN_OFFSETS.size() and _guardians_are_dead():
		_begin_guardian_transition()
	else:
		hp = maxi(hp, 1)


func _finish_phase_transition() -> void:
	if _transition_spawned and not is_queued_for_deletion():
		queue_free()


func _clear_body_stream() -> void:
	if _body_sprite != null and is_instance_valid(_body_sprite):
		_body_sprite.queue_free()
	_body_sprite = null


func _exit_tree() -> void:
	_clear_body_stream()
