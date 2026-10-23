extends BaseMonster
class_name ShuangxiTempleMonster

const FPS := 30.0
const ROOT := "res://Art/monster/swf_png"
const CANG_ER_DASH_SPEED := 150.0
const CANG_ER_DASH_DURATION := 0.634
const BOSS_SKILL_3_DASH_SPEED := 72.0
const BOSS_SKILL_3_DASH_DURATION := 0.634
const BOSS_SKILL_RANGES := [750.0, 500.0, 200.0]
const DATA := {
	3010:
	{
		"name": "人形藤蔓",
		"attack": 30000,
		"hp": 5295000,
		"def": 1500,
		"speed": 8.5,
		"range": 125.0,
		"sight": 760.0,
		"cooldown": 1000,
		"boss": false,
		"hurt": 20,
		"death": 20,
		"walk": 18,
		"wait": 20,
		"attack_frames": 40,
		"attack_start": 15,
		"attack_end": 26,
		"mult": 0.5,
		"kind": "physics",
		"back": [-0.84, -2.8]
	},
	3011:
	{
		"name": "苍耳妖",
		"attack": 30000,
		"hp": 5295000,
		"def": 1500,
		"speed": 10.0,
		"range": 250.0,
		"sight": 760.0,
		"cooldown": 1000,
		"boss": false,
		"hurt": 22,
		"death": 22,
		"walk": 16,
		"wait": 20,
		"attack_frames": 43,
		"attack_start": 12,
		"attack_end": 30,
		"mult": 0.33,
		"kind": "physics",
		"back": [-3.0, -1.0]
	},
	3022:
	{
		"name": "苍耳妖",
		"attack": 30000,
		"hp": 5295000,
		"def": 1500,
		"speed": 10.0,
		"range": 250.0,
		"sight": 760.0,
		"cooldown": 1000,
		"boss": false,
		"hurt": 22,
		"death": 22,
		"walk": 16,
		"wait": 20,
		"attack_frames": 43,
		"attack_start": 12,
		"attack_end": 30,
		"mult": 0.33,
		"kind": "physics",
		"back": [-3.0, -1.0]
	},
	3020:
	{
		"name": "道明妖僧",
		"attack": 42000,
		"hp": 19000000,
		"def": 4900,
		"speed": 16.0,
		"range": 370.0,
		"sight": 1200.0,
		"cooldown": 1600,
		"boss": true,
		"hurt": 20,
		"death": 20,
		"walk": 16,
		"wait": 20,
		"attack_frames": 36,
		"attack_start": 16,
		"attack_end": 30,
		"mult": 1.5,
		"kind": "magic",
		"back": [-5.0, -2.0]
	},
}
const ACTIONS := {
	3010: {"wait": "wait", "walk": "walk", "hurt": "hurt", "death": "death", "attack": "attack1"},
	3011: {"wait": "wait", "walk": "walk", "hurt": "hurt", "death": "death", "attack": "attack1"},
	3022: {"wait": "wait", "walk": "walk", "hurt": "hurt", "death": "death", "attack": "attack1"},
	3020:
	{
		"wait": "wait",
		"walk": "walk",
		"hurt": "hurt",
		"death": "death",
		"skill1": "skill1",
		"skill2": "skill2",
		"skill3": "skill3"
	},
}
const VISUAL_OFFSETS := {
	3010:
	{
		&"wait": Vector2(4.825, -54.4),
		&"walk": Vector2(4.55, -56.05),
		&"hurt": Vector2(-32.075, -58.575),
		&"death": Vector2(-25.875, -35.45),
		&"attack": Vector2(47.6, -81.65)
	},
	3011:
	{
		&"wait": Vector2(4.725, -56.175),
		&"walk": Vector2(7.15, -55.3),
		&"hurt": Vector2(-33.075, -65.1),
		&"death": Vector2(-20.4, -28.95),
		&"attack": Vector2(31.2, -61.375)
	},
	3022:
	{
		&"wait": Vector2(4.725, -56.175),
		&"walk": Vector2(7.15, -55.3),
		&"hurt": Vector2(-33.075, -65.1),
		&"death": Vector2(-20.4, -28.95),
		&"attack": Vector2(31.2, -61.375)
	},
	3020:
	{
		&"wait": Vector2(-0.875, -52.225),
		&"walk": Vector2(1.8, -51.825),
		&"hurt": Vector2(-28.625, -52.45),
		&"death": Vector2(-25.1, -23.425),
		&"skill1": Vector2(-3.725, -59.275),
		&"skill2": Vector2(-11.85, -109.875),
		&"skill3": Vector2(28.75, -56.925)
	},
}
@export var monster_kind := 3010
static var _frames_cache: Dictionary = {}
var _busy := false
var _next_attack := 0
var _dead_started := false
var _boss_skill_index := -1
var _attack_motion_generation := 0
var _runtime_config: Dictionary = {}


func _ready() -> void:
	_runtime_config = _resolve_runtime_config()
	_configure_monster()
	_build_visuals()
	_build_animations()
	super._ready()


func _configure_monster() -> void:
	if _runtime_config.is_empty():
		_runtime_config = _resolve_runtime_config()
	var d: Dictionary = _runtime_config
	my_mr_name = str(d.get("name", "怪物%d" % monster_kind))
	level = int(d.get("level", 90))
	attack_in = int(d["attack"])
	max_hp = int(d["hp"])
	hp = max_hp
	def = int(d["def"])
	mdef = int(d.get("mdef", def))
	speed = float(d["speed"])
	attack_range = int(d["range"])
	mysee = int(d["sight"])
	crit = int(d.get("crit", 0))
	miss = int(d.get("miss", 0))
	htarget = int(d.get("hit", 0))
	toughness = float(d.get("toughness", 0.0))
	crit_reduce = int(d.get("crit_reduce", 0))
	ar = int(d.get("armor_break", 0))
	sp = int(d.get("magic_break", 0))
	attack_desire = int(d.get("attack_desire", 100))
	add_exp = int(d.get("exp", 0))
	fall_coin = int(d.get("coin", 0))
	fall_pro = float(d.get("drop_rate", 0.0))
	fall_list = Array(d.get("drop_list", [])).duplicate(true)
	independent_fall_list = Array(d.get("independent_drop_list", [])).duplicate(true)
	is_boss = bool(d.get("is_boss", d.get("boss", false)))
	boss_max_protect = float(d.get("max_protect", 240.0 if is_boss else 100.0))
	obj_attack_dict.clear()
	var attacks: Dictionary = d.get("attacks", {})
	if attacks.is_empty():
		attacks["hit1"] = {
			"multiplier": d["mult"], "hurt_back": d["back"], "kind": d["kind"], "protect": 6668 if is_boss else 1112
		}
	for attack_name: String in attacks:
		var attack: Dictionary = attacks[attack_name]
		obj_attack_dict[attack_name] = {
			"power":
			(
				int(attack["power"])
				if attack.has("power")
				else int(float(attack_in) * float(attack.get("multiplier", 0.0)))
			),
			"hurtBack": Array(attack.get("hurt_back", [0, 0])).duplicate(),
			"attackKind": str(attack.get("kind", "physics")),
			"HitProtect": int(attack.get("protect", 0)),
		}


func monster_info_base_attack() -> int:
	return int(_runtime_config.get("attack", DATA.get(monster_kind, DATA[3011])["attack"]))


func _resolve_runtime_config() -> Dictionary:
	var base_kind := monster_kind if DATA.has(monster_kind) else 3011
	var config: Dictionary = DATA[base_kind].duplicate(true)
	var level_node := get_level_node()
	if level_node != null and level_node.has_method("get_level_monster_config"):
		var level_config: Variant = level_node.call("get_level_monster_config", monster_kind)
		if level_config is Dictionary and not level_config.is_empty():
			config.merge(level_config, true)
	return config


func monster_info_attack_values_include_difficulty() -> bool:
	return false


static func prewarm_frames(monster_kinds: Array) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	for kind_value in monster_kinds:
		var kind := int(kind_value)
		if not DATA.has(kind) or _frames_cache.has(kind):
			continue
		_frames_cache[kind] = _build_frames_for_kind(kind)
		if tree != null:
			await tree.process_frame


func _build_visuals() -> void:
	mr_ani.sprite_frames = _frames()
	mr_ani.flip_h = true
	mr_ani.position = _visual_offset(&"wait")
	mr_ani.play(&"wait")


func _build_animations() -> void:
	if mr_player.has_animation_library(&""):
		mr_player.remove_animation_library(&"")
	var library := AnimationLibrary.new()
	var d: Dictionary = DATA.get(monster_kind, DATA[3011])
	for animation_name in [&"wait", &"walk", &"hurt", &"death"]:
		library.add_animation(
			animation_name,
			_make_animation(animation_name, int(d[animation_name]), animation_name in [&"wait", &"walk"])
		)
	if monster_kind != 3020:
		var attack := _make_animation(&"attack", int(d["attack_frames"]), false)
		var is_cang_er := monster_kind in [3011, 3022]
		var attack_start_frame := 22 if is_cang_er else int(d["attack_start"])
		_add_method_key(attack, float(attack_start_frame - 1) / FPS, &"_enable_attack")
		_add_method_key(attack, float(d["attack_end"]) / FPS, &"_disable_attack")
		if is_cang_er:
			_add_method_key(attack, float(22 - 1) / FPS, &"_start_cang_er_dash")
		library.add_animation(&"attack", attack)
	else:
		var skill_frames := {&"skill1": 34, &"skill2": 46, &"skill3": 36}
		for skill_name in [&"skill1", &"skill2", &"skill3"]:
			var skill := _make_animation(skill_name, skill_frames[skill_name], false)
			match skill_name:
				&"skill1":
					_add_method_key(skill, float(14 - 1) / FPS, &"_fire_boss_skill1")
				&"skill2":
					_add_method_key(skill, float(26 - 1) / FPS, &"_fire_boss_skill2")
				&"skill3":
					_add_method_key(skill, float(15 - 1) / FPS, &"_start_boss_skill3")
					_add_method_key(skill, float(30) / FPS, &"_disable_attack")
			library.add_animation(skill_name, skill)
	var death_animation: Animation = library.get_animation(&"death")
	_add_method_key(death_animation, death_animation.length - 0.001, &"settle_death_drops_and_free")
	mr_player.add_animation_library(&"", library)


func _make_animation(animation_name: StringName, frame_count: int, looped: bool) -> Animation:
	var animation := Animation.new()
	animation.length = maxf(float(frame_count) / FPS, 0.05)
	animation.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
	var track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track, NodePath("."))
	animation.track_insert_key(track, 0.0, {"method": &"_play_frames", "args": [animation_name]})
	return animation


func _add_method_key(animation: Animation, time: float, method_name: StringName) -> void:
	var track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track, NodePath("."))
	animation.track_insert_key(track, clampf(time, 0.0, animation.length - 0.001), {"method": method_name, "args": []})


func _play_frames(animation_name: StringName) -> void:
	mr_ani.position = _visual_offset(animation_name)
	mr_ani.play(animation_name)


func _visual_offset(animation_name: StringName) -> Vector2:
	var offsets: Dictionary = VISUAL_OFFSETS.get(monster_kind, VISUAL_OFFSETS[3011])
	var offset: Vector2 = offsets.get(animation_name, offsets[&"wait"])
	if mr_ani.flip_h:
		offset.x = -offset.x
	return offset


func _enable_attack() -> void:
	if hit_box != null:
		hit_box.set_deferred("disabled", false)


func _disable_attack() -> void:
	if hit_box != null:
		hit_box.set_deferred("disabled", true)


func _frames() -> SpriteFrames:
	if _frames_cache.has(monster_kind):
		return _frames_cache[monster_kind] as SpriteFrames
	_frames_cache[monster_kind] = _build_frames_for_kind(monster_kind)
	return _frames_cache[monster_kind] as SpriteFrames


static func _load_standard_frames(source_kind: int, names: Dictionary) -> SpriteFrames:
	var frames_path := ROOT.path_join(str(source_kind)).path_join("atlas").path_join(
		"swf_png_%d_frames.tres" % source_kind
	)
	if not ResourceLoader.exists(frames_path):
		return null
	var source := load(frames_path) as SpriteFrames
	if source == null:
		return null
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for key in names:
		var action_name := StringName(str(key))
		var sequence_name := StringName(str(names[key]))
		if not source.has_animation(sequence_name):
			return null
		frames.add_animation(action_name)
		frames.set_animation_speed(action_name, source.get_animation_speed(sequence_name))
		frames.set_animation_loop(action_name, action_name in [&"wait", &"walk"])
		for frame_index in range(source.get_frame_count(sequence_name)):
			frames.add_frame(action_name, source.get_frame_texture(sequence_name, frame_index))
	return frames


static func _build_frames_for_kind(kind: int) -> SpriteFrames:
	var source_kind := 3011 if kind == 3022 else kind
	var names: Dictionary = ACTIONS[source_kind]
	return _load_standard_frames(source_kind, names)


func ai_think() -> void:
	if _busy or death() or RoleProp.get_nearest_monster_target_position(global_position).x == null:
		return
	var distance := absf(float(RoleProp.get_nearest_monster_target_position(global_position).x) - position.x)
	has_target = distance <= float(mysee)
	if not has_target:
		stop_move()
		return
	to_hero()
	var next_attack_range := float(attack_range)
	if monster_kind == 3020:
		var skill_ranges: Array = _runtime_config.get("skill_ranges", BOSS_SKILL_RANGES)
		next_attack_range = float(skill_ranges[(_boss_skill_index + 1) % skill_ranges.size()])
	if Time.get_ticks_msec() < _next_attack:
		if distance > next_attack_range:
			have_target()
		else:
			stop_move()
		return
	if distance > next_attack_range:
		have_target()
		return
	_start_attack()


func _start_attack() -> void:
	_cancel_attack_motion()
	_busy = true
	is_attacking = true
	var action := &"attack"
	if monster_kind == 3020:
		_boss_skill_index = (_boss_skill_index + 1) % 3
		action = [&"skill1", &"skill2", &"skill3"][_boss_skill_index]
		hit_name = "hit%d" % (_boss_skill_index + 1)
	else:
		hit_name = "hit1"
	mr_player.play(action)
	await mr_player.animation_finished
	if death():
		return
	_cancel_attack_motion()
	_disable_attack()
	_busy = false
	is_attacking = false
	_next_attack = Time.get_ticks_msec() + int(_runtime_config["cooldown"])
	stop_move()


func state_hurt() -> void:
	if death() or _busy:
		return
	super.state_hurt()


func state_death() -> void:
	if _dead_started:
		return
	_dead_started = true
	_busy = false
	is_attacking = false
	if hit_box != null:
		hit_box.set_deferred("disabled", true)
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)
	_cancel_attack_motion()
	no_grav = false
	velocity = Vector2.ZERO
	mr_player.play(&"death")


func get_ice_effect_offset() -> Vector2:
	return Vector2(0, -79)


func _start_cang_er_dash() -> void:
	_start_attack_motion(CANG_ER_DASH_SPEED, CANG_ER_DASH_DURATION)


func _fire_boss_skill1() -> void:
	_spawn_boss_arrow(0)


func _fire_boss_skill2() -> void:
	_spawn_boss_arrow(1)


func _start_boss_skill3() -> void:
	_enable_attack()
	_start_attack_motion(BOSS_SKILL_3_DASH_SPEED, BOSS_SKILL_3_DASH_DURATION)


func _spawn_boss_arrow(skill_index: int) -> void:
	var facing := _attack_facing()
	var spawn_offset := Vector2(63.0 * facing, -29.0) if skill_index == 0 else Vector2(92.0 * facing, -37.0)
	var direction := Vector2(facing, 0.0)
	if skill_index == 0:
		var target_x := (
			float(RoleProp.get_nearest_monster_target_position(global_position).x)
			if RoleProp.get_nearest_monster_target_position(global_position).x != null
			else position.x + facing
		)
		var target_y := (
			float(RoleProp.get_nearest_monster_target_position(global_position).y)
			if RoleProp.get_nearest_monster_target_position(global_position).y != null
			else position.y
		)
		direction = Vector2(target_x, target_y) - position
		if direction.is_zero_approx():
			direction = Vector2(facing, 0.0)
	var arrow_name := "ShuangxiBossArrow%d" % (skill_index + 1)
	var arrow: Node = Global.add_bullet(
		arrow_name,
		bullet,
		direction.x >= 0.0,
		1.0,
		position + spawn_offset,
		"hit%d" % (skill_index + 1),
		obj_attack_dict["hit%d" % (skill_index + 1)]
	)
	if arrow != null and arrow.has_method("set_direction_vector"):
		arrow.set_direction_vector(direction.normalized(), 120.0 if skill_index == 0 else 80.0)


func _start_attack_motion(motion_speed: float, duration: float) -> void:
	_attack_motion_generation += 1
	var generation := _attack_motion_generation
	velocity.x = _attack_facing() * motion_speed
	await get_tree().create_timer(duration, false).timeout
	if generation == _attack_motion_generation and not death():
		velocity.x = 0.0


func _cancel_attack_motion() -> void:
	_attack_motion_generation += 1
	velocity.x = 0.0


func _attack_facing() -> float:
	return 1.0 if monster_dir.scale.x < 0.0 else -1.0
