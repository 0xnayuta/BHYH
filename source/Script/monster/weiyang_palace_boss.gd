extends BaseMonster
class_name WeiyangPalaceBoss

const FPS := 30.0
const ROOT := "res://Art/monster/swf_png/3007"
const VISUAL_GROUND_OFFSET := Vector2(0.0, 80.0)
const BODY_POSITION := Vector2(-0.575, -203.0)
const IDLE_POSITION := Vector2(12.5, -306.95)
const FULL_SPRITE_POSITION := Vector2(-0.575, -221.725)
const VISUAL_Z_INDEX := -5
const SHOOT_TIMELINE_FRAME := 51
const PROJECTILE_SPEED := 120.0
const AXE_SUMMON_OFFSET := Vector2(-470.0, 20)
const LEFT_MOUTH_ORIGIN := Vector2(-195.45, -269.6)
const RIGHT_MOUTH_ORIGIN := Vector2(194.0, -272.1)
const MONSTER_KIND := 3007

static var _cache: SpriteFrames
static var _appear_cache: SpriteFrames

var _busy := true
var _ai_ready_msec := 0
var _decision_ready_msec := 0
var _skill_ready_msec := {
	&"hit1": 0,
	&"hit2": 0,
	&"hit3": 0,
}
var _dead_started := false
var _effect: AnimatedSprite2D
var _idle_layer: Sprite2D
var _mouth1: AnimatedSprite2D
var _mouth2: AnimatedSprite2D
var _eye1: AnimatedSprite2D
var _eye2: AnimatedSprite2D
var _eye3: AnimatedSprite2D
var _fixed_position := Vector2.ZERO
var _active_axe: WeiyangFlyingAxe
var _runtime_config: Dictionary = {}


func _ready() -> void:
	set_meta("counts_as_alive_for_stage_clear", true)
	_runtime_config = _resolve_runtime_config()
	_configure_monster()
	_build_animations()
	super._ready()
	monster_dir.visible = true

	monster_dir.z_index = VISUAL_Z_INDEX
	monster_dir.position += VISUAL_GROUND_OFFSET
	mr_ani.visible = false
	_fixed_position = position
	_build_normal_layers()
	_build_appear_layer()
	_set_normal_visuals(false)
	call_deferred("_play_original_appear")


func _configure_monster() -> void:
	if _runtime_config.is_empty():
		_runtime_config = _resolve_runtime_config()
	if _runtime_config.is_empty():
		return
	var config := _runtime_config
	my_mr_name = str(config.get("name", "金之祖巫"))
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
	add_exp = int(config["exp"])
	fall_coin = int(config["coin"])
	fall_pro = float(config.get("drop_rate", 0.0))
	fall_list = Array(config.get("drop_list", [])).duplicate(true)
	independent_fall_list = Array(config.get("independent_drop_list", [])).duplicate(true)
	is_boss = bool(config["is_boss"])
	boss_max_protect = float(config["max_protect"])
	no_grav = true
	super_armor_active = true
	cannot_attract = true
	obj_attack_dict.clear()
	var attacks: Dictionary = config["attacks"]
	for attack_name: String in attacks:
		var attack: Dictionary = attacks[attack_name]
		obj_attack_dict[attack_name] = {
			"power": int(float(attack_in) * float(attack["multiplier"])),
			"hurtBack": Array(attack["hurt_back"]).duplicate(),
			"attackKind": str(attack["kind"]),
			"HitProtect": int(attack["protect"]),
		}


func _resolve_runtime_config() -> Dictionary:
	var config := {
		"name": "金之祖巫",
		"level": 90,
		"hp": 18000000,
		"attack": 35000,
		"def": 4950,
		"mdef": 4950,
		"crit": 700,
		"miss": 150,
		"hit": 480,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 3300,
		"magic_break": 3300,
		"speed": 0.0,
		"range": 1200.0,
		"sight": 1200.0,
		"attack_desire": 100,
		"exp": 100,
		"coin": 280,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": true,
		"max_protect": 240.0,
		"attacks":
		{
			"hit1": {"multiplier": 1.5, "hurt_back": [-4, -2], "kind": "magic", "protect": 80},
			"hit2": {"multiplier": 1.5, "hurt_back": [-4, -2], "kind": "magic", "protect": 80},
			"hit3": {"multiplier": 1.0, "hurt_back": [-5, -2], "kind": "magic", "protect": 130},
		},
	}
	var level_node := get_level_node()
	if level_node != null and level_node.has_method("get_level_monster_config"):
		var level_config: Variant = level_node.call("get_level_monster_config", MONSTER_KIND)
		if level_config is Dictionary and not level_config.is_empty():
			config.merge(level_config, true)
	return config


func _build_animations() -> void:
	mr_ani.sprite_frames = _get_frames()
	mr_ani.centered = true
	mr_ani.flip_h = false
	mr_ani.position = BODY_POSITION
	if mr_player.has_animation_library(&""):
		mr_player.remove_animation_library(&"")
	var library := AnimationLibrary.new()
	for animation_name in [&"wait", &"death"]:
		var animation := Animation.new()
		animation.length = 1.0 if animation_name == &"wait" else 2.05
		animation.loop_mode = Animation.LOOP_LINEAR if animation_name == &"wait" else Animation.LOOP_NONE
		var track := animation.add_track(Animation.TYPE_METHOD)
		animation.track_set_path(track, NodePath("."))
		animation.track_insert_key(track, 0.0, {"method": &"_play_frames", "args": [animation_name]})
		library.add_animation(animation_name, animation)
	mr_player.add_animation_library(&"", library)


func _build_normal_layers() -> void:
	_idle_layer = Sprite2D.new()
	_idle_layer.name = "mcIdle"
	_idle_layer.centered = true
	var frames := _get_frames()
	if frames != null and frames.has_animation(&"wait") and frames.get_frame_count(&"wait") > 0:
		_idle_layer.texture = frames.get_frame_texture(&"wait", 0)
	_idle_layer.position = IDLE_POSITION
	_idle_layer.z_index = 1
	monster_dir.add_child(_idle_layer)

	_mouth1 = _create_symbol_layer(
		"mcMouse1", &"mouth", "DefineSprite_28__1_fla.effect1_1_9", 78, Vector2(-238.75, -251.375), false, -1, 0, true
	)
	_mouth2 = _create_symbol_layer(
		"mcMouse2", &"mouth", "DefineSprite_28__1_fla.effect1_1_9", 78, Vector2(237.3, -253.875), true, -1, 0, true
	)
	_eye3 = _create_symbol_layer("mcEye3", &"eye", "DefineSprite_45", 17, Vector2(-1.725, -352.25), false, 2, 16, false)
	_eye1 = _create_symbol_layer(
		"mcEye1", &"eye", "DefineSprite_68", 55, Vector2(-167.1, -273.775), false, 3, 54, false
	)
	_eye2 = _create_symbol_layer("mcEye2", &"eye", "DefineSprite_68", 55, Vector2(169.1, -273.775), true, 4, 54, false)


func _build_appear_layer() -> void:
	_effect = AnimatedSprite2D.new()
	_effect.name = "mcAppear"
	_effect.centered = true
	_effect.flip_h = false
	_effect.position = FULL_SPRITE_POSITION
	_effect.sprite_frames = _get_appear_frames()
	_effect.visible = false
	monster_dir.add_child(_effect)


func _play_original_appear() -> void:
	if not is_instance_valid(_effect):
		_busy = false
		return
	_set_normal_visuals(false)
	_effect.visible = true
	_effect.frame = 0
	_effect.play(&"appear")
	await _effect.animation_finished
	if not is_instance_valid(self) or _dead_started or death():
		return
	_effect.visible = false
	_set_normal_visuals(true)
	mr_ani.play(&"wait")
	_busy = false
	_ai_ready_msec = Time.get_ticks_msec() + 2000
	_decision_ready_msec = _ai_ready_msec


static func _load_standard_frames() -> SpriteFrames:
	var frames_path := ROOT.path_join("atlas/swf_png_3007_frames.tres")
	if not ResourceLoader.exists(frames_path):
		return null
	return load(frames_path) as SpriteFrames


static func _load_standard_appear_frames() -> SpriteFrames:
	var frames_path := ROOT.path_join("atlas/swf_png_3007_frames.tres")
	if not ResourceLoader.exists(frames_path):
		return null
	return load(frames_path) as SpriteFrames


static func _get_frames() -> SpriteFrames:
	if _cache != null:
		return _cache
	var standard := _load_standard_frames()
	if standard != null:
		_cache = standard
		return standard
	return null


static func _get_appear_frames() -> SpriteFrames:
	if _appear_cache != null:
		return _appear_cache
	var standard := _load_standard_appear_frames()
	if standard != null:
		_appear_cache = standard
		return standard
	return null


func _create_symbol_layer(
	layer_name: String,
	animation_name: StringName,
	directory: String,
	frame_count: int,
	layer_position: Vector2,
	mirrored: bool,
	layer_z_index: int,
	initial_frame: int,
	loops: bool
) -> AnimatedSprite2D:
	var layer := AnimatedSprite2D.new()
	layer.name = layer_name
	layer.centered = true
	layer.flip_h = mirrored
	layer.position = layer_position
	layer.z_index = layer_z_index
	var frames := _build_symbol_frames(animation_name, directory, frame_count, loops)
	layer.sprite_frames = frames
	if frames != null:
		layer.animation = animation_name
		layer.frame = clampi(initial_frame, 0, frame_count - 1)
	layer.pause()
	layer.visible = false
	monster_dir.add_child(layer)
	return layer


static func _build_symbol_frames(
	animation_name: StringName, directory: String, _frame_count: int, loops: bool
) -> SpriteFrames:
	var frames_path := ROOT.path_join("atlas/swf_png_3010_frames.tres")
	if ResourceLoader.exists(frames_path):
		var source := load(frames_path) as SpriteFrames
		if source != null and source.has_animation(StringName(directory)):
			var frames := SpriteFrames.new()
			frames.remove_animation(&"default")
			frames.add_animation(animation_name)
			frames.set_animation_loop(animation_name, loops)
			frames.set_animation_speed(animation_name, FPS)
			for i in range(source.get_frame_count(StringName(directory))):
				frames.add_frame(animation_name, source.get_frame_texture(StringName(directory), i))
			return frames
	return null


func _set_normal_visuals(show_visuals: bool) -> void:
	mr_ani.visible = show_visuals
	if is_instance_valid(_idle_layer):
		_idle_layer.visible = show_visuals
	for layer in [_mouth1, _mouth2, _eye1, _eye2, _eye3]:
		if is_instance_valid(layer):
			layer.visible = show_visuals


func _play_frames(animation_name: StringName) -> void:
	if animation_name == &"death":
		mr_ani.position = FULL_SPRITE_POSITION
	else:
		mr_ani.position = BODY_POSITION
	mr_ani.play(animation_name)


func ai_think() -> void:
	if _busy or _dead_started or death():
		return
	var now_msec := Time.get_ticks_msec()
	if now_msec < _ai_ready_msec or now_msec < _decision_ready_msec:
		return
	var target := _get_ai_target()
	if target == null:
		return
	var relative_x := target.position.x - position.x
	var shot_cooldown := 6000 if hp > max_hp * 0.5 else 4000
	var wait_seconds := randf_range(2.0, 4.0) if hp > max_hp * 0.5 else randf_range(1.0, 2.0)

	if relative_x >= -999.0 and relative_x <= 140.0 and now_msec >= int(_skill_ready_msec[&"hit2"]):
		_start_skill(&"hit2", target.position)
		_skill_ready_msec[&"hit2"] = now_msec + shot_cooldown
		_decision_ready_msec = now_msec + int(wait_seconds * 1000.0)
		return
	if relative_x >= -140.0 and relative_x <= 999.0 and now_msec >= int(_skill_ready_msec[&"hit1"]):
		_start_skill(&"hit1", target.position)
		_skill_ready_msec[&"hit1"] = now_msec + shot_cooldown
		_decision_ready_msec = now_msec + int(wait_seconds * 1000.0)
		return
	if (
		now_msec >= int(_skill_ready_msec[&"hit3"])
		and relative_x >= -999.0
		and relative_x <= 999.0
		and not _has_active_axe()
	):
		_start_skill(&"hit3", target.position)
		_skill_ready_msec[&"hit3"] = now_msec + 12000
		_decision_ready_msec = now_msec + int(randf_range(1.0, 2.0) * 1000.0)


func _get_ai_target() -> BaseHero:
	if get_player != null and is_instance_valid(get_player):
		return get_player
	if Global.get_player is BaseHero and is_instance_valid(Global.get_player):
		return Global.get_player as BaseHero
	return null


func _start_skill(skill_name: StringName, locked_target_position: Vector2) -> void:
	hit_name = str(skill_name)
	match skill_name:
		&"hit1":
			_play_mouth(_mouth1)
			_restart_eye(_eye1)
			_shoot_on_mouth_frame(_mouth1, 1, locked_target_position)
		&"hit2":
			_play_mouth(_mouth2)
			_restart_eye(_eye2)
			_shoot_on_mouth_frame(_mouth2, 2, locked_target_position)
		&"hit3":
			_restart_eye(_eye3)
			_spawn_original_axe()


func _play_mouth(mouth: AnimatedSprite2D) -> void:
	if mouth == null or not is_instance_valid(mouth):
		return
	mouth.frame = 0
	mouth.play(&"mouth")


func _restart_eye(eye: AnimatedSprite2D) -> void:
	if eye == null or not is_instance_valid(eye):
		return
	eye.frame = 0
	eye.play(&"eye")


func _shoot_on_mouth_frame(mouth: AnimatedSprite2D, side: int, locked_target_position: Vector2) -> void:
	if mouth == null or not is_instance_valid(mouth):
		return
	var fire_frame := SHOOT_TIMELINE_FRAME - 1
	while is_instance_valid(mouth) and mouth.frame < fire_frame:
		await mouth.frame_changed
	if not is_instance_valid(self) or not is_instance_valid(mouth) or _dead_started or death():
		return
	_emit_dragon_projectile(side, locked_target_position)


func _emit_dragon_projectile(side: int, locked_target_position: Vector2) -> void:
	var mouth_offset := LEFT_MOUTH_ORIGIN if side == 1 else RIGHT_MOUTH_ORIGIN
	var mouth_world_position := monster_dir.to_global(mouth_offset)
	var aim_direction := mouth_world_position.direction_to(locked_target_position)
	if aim_direction.is_zero_approx():
		aim_direction = Vector2.RIGHT
	var projectile = Global.add_bullet(
		"WeiyangBossBullet1", bullet, true, 1.0, mouth_world_position, "hit%d" % side, obj_attack_dict["hit%d" % side]
	)
	if projectile != null and projectile.has_method("configure_trajectory"):
		projectile.configure_trajectory(aim_direction * PROJECTILE_SPEED, 5.0)


func _spawn_original_axe() -> void:
	if _has_active_axe():
		return
	var created := Global.create_monster(3012, get_parent(), position + AXE_SUMMON_OFFSET)
	if created is WeiyangFlyingAxe:
		_active_axe = created as WeiyangFlyingAxe
		_active_axe.source_boss = self


func _has_active_axe() -> bool:
	return _active_axe != null and is_instance_valid(_active_axe) and not _active_axe.removed


func _physics_process(delta: float) -> void:
	if not _dead_started:
		_enforce_original_fixed_state()
	super._physics_process(delta)
	if _dead_started:
		return
	_enforce_original_fixed_state()


func _enforce_original_fixed_state() -> void:
	if has_method(&"_kill_control_movement_tweens"):
		call(&"_kill_control_movement_tweens")
	velocity = Vector2.ZERO
	position = _fixed_position
	monster_dir.scale.x = 1.0
	base_damage_box.scale.x = 1.0
	super_armor_active = true
	cannot_attract = true
	no_grav = true


func to_walk() -> void:
	velocity = Vector2.ZERO


func is_control_immune() -> bool:
	return true


func state_death() -> void:
	if _dead_started:
		return
	_dead_started = true
	_busy = true
	_despawn_active_axe()
	velocity = Vector2.ZERO
	no_grav = true
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)
	if hit_box != null:
		hit_box.set_deferred("disabled", true)
	settle_death_drops()
	if is_instance_valid(_effect):
		_effect.stop()
		_effect.visible = false
	_set_normal_visuals(false)
	mr_ani.visible = true
	mr_ani.position = FULL_SPRITE_POSITION
	mr_player.speed_scale = 1.0
	mr_player.play(&"death")
	await mr_player.animation_finished
	if is_instance_valid(self):
		settle_death_drops_and_free()


func _despawn_active_axe() -> void:
	if _active_axe == null:
		return
	if is_instance_valid(_active_axe) and _active_axe.has_method("remove_from_battle"):
		_active_axe.remove_from_battle()
	_active_axe = null


func monster_info_base_attack() -> int:
	return int(_runtime_config.get("attack", attack_in))


func monster_info_attack_values_include_difficulty() -> bool:
	return false
