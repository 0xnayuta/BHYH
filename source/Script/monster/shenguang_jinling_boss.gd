extends BaseMonster
class_name ShenguangJinlingBoss

const EFFECT_SCRIPT := preload("res://Script/monster/shenguang_boss_effect.gd")
const ROOT := "res://Art/monster/swf_png/3021"
const SOURCE_FPS := 30.0
const BASE_ATTACK := 32000
const MONSTER_KIND := 3021
const LEVEL_MONSTER_OFFSET := Vector2(0, 110)
const BODY_GROUND_OFFSET := Vector2(0, 50)
const BODY_ACTIONS := {
	&"appear": {"folder": "appear", "frames": 55, "offset": Vector2(2.15, -240.75), "loop": false},
	&"death": {"folder": "death", "frames": 55, "offset": Vector2(2.15, -240.75), "loop": false},
	&"wait": {"folder": "idle", "frames": 60, "offset": Vector2(2.0, -240.75), "loop": true},
	&"skill1": {"folder": "wing_left", "frames": 65, "offset": Vector2(1.1, -241.05), "loop": false},
	&"skill2": {"folder": "wing_right", "frames": 65, "offset": Vector2(1.1, -241.05), "loop": false},
	&"skill3": {"folder": "effect3", "frames": 70, "offset": Vector2(2.15, -240.75), "loop": false},
	&"skill4": {"folder": "effect3", "frames": 70, "offset": Vector2(2.15, -240.75), "loop": false},
}
const EFFECT_DATA := {
	"feather":
	{
		"frames": 15,
		"offset": Vector2(0.9, -9.8),
		"size": Vector2(69, 25.5),
		"shape_offset": Vector2(12.0, -8.75),
		"loop": true
	},
	"stake1":
	{
		"frames": 10,
		"offset": Vector2(0.9, -78.2),
		"size": Vector2(77, 232.95),
		"shape_offset": Vector2(-1.0, -98.975),
		"loop": false
	},
	"stake2":
	{
		"frames": 10,
		"offset": Vector2(1.3, -62.8),
		"size": Vector2(79, 143.95),
		"shape_offset": Vector2(2.0, -50.475),
		"loop": false
	},
	"stake3":
	{
		"frames": 10,
		"offset": Vector2(0.45, -62.1),
		"size": Vector2(72, 135.95),
		"shape_offset": Vector2(1.5, -48.475),
		"loop": false
	},
	"poison":
	{
		"frames": 20,
		"offset": Vector2(-0.5, -14.0),
		"size": Vector2(93, 61),
		"shape_offset": Vector2(3.0, -12.0),
		"loop": true
	},
}
const FEATHER_OFFSETS := {
	-1: [Vector2(-180, -255), Vector2(-165, -225), Vector2(-132, -189), Vector2(-90, -166)],
	1: [Vector2(180, -255), Vector2(165, -225), Vector2(132, -189), Vector2(90, -166)],
}
const STAKE_SLOT_X := [-255.0, -85.0, 85.0, 255.0]

static var _frames_cache: SpriteFrames

static var _effect_frames_cache: Dictionary = {}

var _busy := true
var _dead_started := false
var _appearance_complete := false
var _fixed_position := Vector2.ZERO
var _next_global_action_msec := 0
var _skill_ready_msec := {1: 0, 2: 0, 3: 0, 4: 0}
var _stake_slots := [false, false, false, false]
var _runtime_config: Dictionary = {}


func _ready() -> void:
	_runtime_config = _resolve_runtime_config()
	_configure_boss()
	_build_animations()
	super._ready()
	_apply_ground_alignment()
	_fixed_position = position
	_enforce_fixed_state()
	call_deferred("_run_appearance")


func _apply_ground_alignment() -> void:
	position += LEVEL_MONSTER_OFFSET
	monster_dir.position += BODY_GROUND_OFFSET
	base_damage_box.position += BODY_GROUND_OFFSET
	pz.position += BODY_GROUND_OFFSET


func _configure_boss() -> void:
	if _runtime_config.is_empty():
		_runtime_config = _resolve_runtime_config()
	if _runtime_config.is_empty():
		return
	var config := _runtime_config
	my_mr_name = str(config.get("name", "金光孔雀"))
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
	no_grav = true
	is_fly = true
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
		"name": "木之祖巫",
		"level": 90,
		"hp": 22000000,
		"attack": BASE_ATTACK,
		"def": 5300,
		"mdef": 5300,
		"crit": 700,
		"miss": 160,
		"hit": 480,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 4200,
		"magic_break": 4200,
		"speed": 0.0,
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
			"hit2": {"multiplier": 0.5, "hurt_back": [-5, -2], "kind": "physics", "protect": 6668},
			"hit3": {"multiplier": 0.5, "hurt_back": [-1, -8], "kind": "physics", "protect": 6668},
			"hit4": {"multiplier": 0.5, "hurt_back": [0, 0], "kind": "magic", "protect": 6668},
		},
	}
	var level_node := get_level_node()
	if level_node != null and level_node.has_method("get_level_monster_config"):
		var level_config: Variant = level_node.call("get_level_monster_config", MONSTER_KIND)
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
	var frames_path := ROOT.path_join("atlas/swf_png_3021_frames.tres")
	if not ResourceLoader.exists(frames_path):
		return null
	var source := load(frames_path) as SpriteFrames
	if source == null:
		return null
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for action_name: StringName in BODY_ACTIONS:
		var info: Dictionary = BODY_ACTIONS[action_name]
		var sequence_name := StringName(str(info["folder"]))
		if not source.has_animation(sequence_name):
			return null
		frames.add_animation(action_name)
		frames.set_animation_speed(action_name, source.get_animation_speed(sequence_name))
		frames.set_animation_loop(action_name, bool(info["loop"]))
		for frame_index in range(source.get_frame_count(sequence_name)):
			frames.add_frame(action_name, source.get_frame_texture(sequence_name, frame_index))
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
	else:
		mr_ani.visible = false
	if mr_player.has_animation_library(&""):
		mr_player.remove_animation_library(&"")
	var library := AnimationLibrary.new()
	for action_name in BODY_ACTIONS:
		var info: Dictionary = BODY_ACTIONS[action_name]
		var animation := _make_body_animation(action_name, int(info["frames"]), bool(info["loop"]))
		match action_name:
			&"skill1", &"skill2":
				var side := -1 if action_name == &"skill1" else 1
				for feather_index in range(4):
					_add_method_key(
						animation, 1.0 + float(feather_index) * 0.1, &"_spawn_feather", [side, feather_index]
					)
			&"skill3":
				_add_method_key(animation, 0.01, &"_spawn_stake")
			&"skill4":
				_add_method_key(animation, 0.01, &"_spawn_poison_field")
			&"death":
				_add_method_key(animation, animation.length - 0.001, &"settle_death_drops_and_free")
		library.add_animation(action_name, animation)
	library.add_animation(&"walk", _make_body_animation(&"wait", 60, true))
	library.add_animation(&"hurt", _make_body_animation(&"wait", 6, false))
	mr_player.add_animation_library(&"", library)


func _make_body_animation(action_name: StringName, frame_count: int, looped: bool) -> Animation:
	var animation := Animation.new()
	animation.length = maxf(float(frame_count) / SOURCE_FPS, 0.05)
	animation.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
	_add_method_key(animation, 0.0, &"_play_body_action", [action_name])
	return animation


func _add_method_key(animation: Animation, time: float, method_name: StringName, args: Array = []) -> void:
	var track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track, NodePath("."))
	animation.track_insert_key(
		track, clampf(time, 0.0, animation.length - 0.001), {"method": method_name, "args": args}
	)


func _play_body_action(action_name: StringName) -> void:
	var info: Dictionary = BODY_ACTIONS.get(action_name, BODY_ACTIONS[&"wait"])
	if mr_ani.sprite_frames != null:
		mr_ani.visible = true
		mr_ani.position = info["offset"]
		mr_ani.play(action_name)


static func _effect_frames(effect_name: String) -> SpriteFrames:
	if _effect_frames_cache.has(effect_name):
		return _effect_frames_cache[effect_name] as SpriteFrames
	var frames := _get_sprite_frames()
	_effect_frames_cache[effect_name] = frames
	return frames


func _run_appearance() -> void:
	_busy = true
	is_attacking = true
	mr_player.play(&"appear")
	await mr_player.animation_finished
	if death():
		return
	mr_player.play(&"wait")
	await get_tree().create_timer(2.0, false).timeout
	if death():
		return
	_busy = false
	is_attacking = false
	_appearance_complete = true
	var now := Time.get_ticks_msec()
	for skill_index in range(1, 5):
		_skill_ready_msec[skill_index] = now


func ai_think() -> void:
	if (
		not _appearance_complete
		or _busy
		or death()
		or RoleProp.get_nearest_monster_target_position(global_position).x == null
	):
		return
	var distance := absf(float(RoleProp.get_nearest_monster_target_position(global_position).x) - position.x)
	has_target = distance <= float(mysee)
	if not has_target:
		return
	var now := Time.get_ticks_msec()
	if now < _next_global_action_msec:
		return
	var available: Array[int] = []
	var wing_skill := 1 if float(RoleProp.get_nearest_monster_target_position(global_position).x) < position.x else 2
	if now >= int(_skill_ready_msec[wing_skill]):
		available.append(wing_skill)
	if now >= int(_skill_ready_msec[3]):
		available.append(3)
	if hp <= max_hp * 0.5 and now >= int(_skill_ready_msec[4]):
		available.append(4)
	if available.is_empty():
		return
	_start_skill(int(available.pick_random()))


func _start_skill(skill_index: int) -> void:
	if _busy or death():
		return
	_busy = true
	is_attacking = true
	velocity = Vector2.ZERO
	hit_name = "hit%d" % skill_index
	var now := Time.get_ticks_msec()
	match skill_index:
		1, 2:
			_skill_ready_msec[skill_index] = now + (8000 if hp <= max_hp * 0.5 else 9000)
		3:
			_skill_ready_msec[3] = now + 3000
		4:
			_skill_ready_msec[4] = now + 9000
	mr_player.play(StringName("skill%d" % skill_index))
	await mr_player.animation_finished
	if death():
		return
	mr_player.play(&"wait")
	_busy = false
	is_attacking = false
	_next_global_action_msec = Time.get_ticks_msec()
	if skill_index in [1, 2]:
		_next_global_action_msec += randi_range(2000, 4000)


func _spawn_feather(side: int, feather_index: int) -> void:
	if death() or feather_index < 0 or feather_index >= 4:
		return
	var horizontal_speed := float(side * 10 * (4 - feather_index) * 3)
	var _velocity := Vector2(horizontal_speed, 150.0)
	_spawn_effect(
		"feather",
		FEATHER_OFFSETS[side][feather_index] + BODY_GROUND_OFFSET,
		"hit1" if side < 0 else "hit2",
		_velocity,
		2.0,
		false
	)


func _spawn_stake() -> void:
	if death():
		return
	var free_slots: Array[int] = []
	for slot_index in range(_stake_slots.size()):
		if not bool(_stake_slots[slot_index]):
			free_slots.append(slot_index)
	if free_slots.is_empty():
		return
	var slot_index: int = int(free_slots.pick_random())
	_stake_slots[slot_index] = true
	var stake_kind := "stake%d" % randi_range(1, 3)
	var effect := _spawn_effect(stake_kind, Vector2(STAKE_SLOT_X[slot_index], 58), "hit3", Vector2.ZERO, 10.0, true)
	if effect != null:
		effect.tree_exited.connect(_release_stake_slot.bind(slot_index), CONNECT_ONE_SHOT)


func _release_stake_slot(slot_index: int) -> void:
	if slot_index >= 0 and slot_index < _stake_slots.size():
		_stake_slots[slot_index] = false


func _spawn_poison_field() -> void:
	if death():
		return
	for step in range(7):
		_spawn_effect("poison", Vector2(float(step * 120), 45), "hit4", Vector2.ZERO, 9.0, false)
		_spawn_effect("poison", Vector2(float(-step * 120), 45), "hit4", Vector2.ZERO, 9.0, false)


func _spawn_effect(
	effect_name: String, local_position: Vector2, attack_name: String, motion: Vector2, lifetime: float, hold_last: bool
) -> ShenguangBossEffect:
	var info: Dictionary = EFFECT_DATA[effect_name]
	var effect := EFFECT_SCRIPT.new() as ShenguangBossEffect
	if effect == null:
		return null
	effect.owner_boss = self
	effect.effect_kind = effect_name
	effect.hit_name = attack_name
	effect.frames = _effect_frames(effect_name)
	effect.visual_offset = info["offset"]
	effect.collision_size = info["size"]
	effect.collision_offset = info["shape_offset"]
	effect.motion_velocity = motion
	effect.lifetime = lifetime
	effect.loop_animation = bool(info["loop"])
	effect.hold_last_frame = hold_last
	effect.position = local_position
	add_child(effect)
	return effect


func apply_poison_buff(role: BaseHero) -> void:
	if role == null or not is_instance_valid(role) or role.buff == null:
		return
	var now := Time.get_ticks_msec()
	var active_expirations: Array[int] = []
	var stored_expirations: Variant = role.get_meta("shenguang_poison_expirations", [])
	if stored_expirations is Array:
		for expiration_value in stored_expirations:
			var expiration := int(expiration_value)
			if expiration > now:
				active_expirations.append(expiration)
	if active_expirations.size() >= 10:
		role.set_meta("shenguang_poison_expirations", active_expirations)
		return
	var added_buff: Variant = (
		Global
		. add_buff(
			role.buff,
			{
				"Name": "poision",
				"AddTime": 10.0,
				"reduce_interval": 1.0,
				"value": maxi(1, int(RoleProp.roleprop.SHp * 0.005)),
				"AttackKind": "magic",
				"CanAdd": true,
				"DeBuff": true,
				"CanRemove": false,
				"ShenguangPoison": true,
			}
		)
	)
	if added_buff != null:
		active_expirations.append(now + 10000)
		role.set_meta("shenguang_poison_expirations", active_expirations)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_enforce_fixed_state()
	var paused_by_control := hp > 0 and is_movement_locked_by_control()
	if mr_player != null:
		mr_player.speed_scale = 0.0 if paused_by_control else 1.0


func _enforce_fixed_state() -> void:
	velocity = Vector2.ZERO
	if _fixed_position != Vector2.ZERO:
		position = _fixed_position
	no_grav = true
	is_fly = true
	cannot_attract = true
	monster_dir.scale.x = 1.0
	base_damage_box.scale.x = 1.0


func state_hurt() -> void:
	velocity = Vector2.ZERO


func state_death() -> void:
	if _dead_started:
		return
	_dead_started = true
	_busy = true
	is_attacking = false
	velocity = Vector2.ZERO
	if hit_box != null:
		hit_box.set_deferred("disabled", true)
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)
	for child in get_children():
		if child is ShenguangBossEffect and child.effect_kind == "poison":
			child.queue_free()
	mr_player.speed_scale = 1.0
	mr_player.play(&"death")


func get_ice_effect_offset() -> Vector2:
	return Vector2(0, 87) + BODY_GROUND_OFFSET
