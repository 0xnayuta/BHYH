extends BaseMonster
class_name ThreePrinceBoss

const SOURCE_FPS := 24.0
const NEZHA_ROOT := "res://Art/monster/game_3_monster/three_prince/nezha"
const NEZHA_FRAMES_RES := "res://Art/monster/game_3_monster/three_prince/nezha/atlas/nezha_frames.tres"
const NEZHA_ATLAS_EFFECTS := ["effect_bullet1_a", "effect_bullet1_b", "effect_chase", "effect_guard"]
const BULLET_SCENE := preload("res://Scene/monster/monster_bullet_slim/three_prince_bullet.tscn")
const THREE_PRINCE_PET_DROP_CHANCE := 0.2
const NIGHTMARE_EQUIPMENT_REPLACEMENTS := {
	"llst": "xyst",
	"llzx": "xyzx",
	"llkj": "xykj",
	"lltk": "xytk",
}
const PRINCE_CONFIGS := [
	{
		"name": "哪吒",
		"root": "res://Art/monster/game_3_monster/three_prince/nezha",
		"visual_position": Vector2(-80, -75),
		"source_origin_offset": Vector2(0, -60),
		"frame_size": Vector2i(370, 300),
		"effect_offsets":
		{
			"effect_bullet1_a": Vector2(100.35, 110.5),
			"effect_bullet1_b": Vector2(13.35, 30.6),
			"effect_chase": Vector2(15.0, -2.0),
			"effect_wind": Vector2(-2.5, 0.0),
			"effect_guard": Vector2(-3.0, -58.0),
		},
		"attack_range": 180,
		"counts": {"idle": 6, "walk": 4, "hurt": 1, "death": 5, "hit1": 6, "hit2": 4, "hit3": 3, "hit4": 3},
		"holds":
		{
			"idle": [2, 2, 2, 3, 2, 4],
			"walk": [4, 4, 4, 4],
			"hurt": [8],
			"death": [2, 2, 2, 2, 10],
			"hit1": [2, 5, 2, 2, 2, 5],
			"hit2": [2, 2, 2, 10],
			"hit3": [2, 5, 10],
			"hit4": [2, 4, 10]
		},
	},
	{
		"name": "木吒",
		"root": "res://Art/monster/game_3_monster/three_prince/muzha",
		"visual_position": Vector2(-10, -80),
		"source_origin_offset": Vector2(0, -60),
		"frame_size": Vector2i(250, 250),
		"effect_offsets":
		{
			"effect_bullet1_a": Vector2(97.35, 77.0),
			"effect_bullet1_b": Vector2(70.1, 108.2),
			"effect_aura": Vector2(0.0, -19.0),
			"effect_target": Vector2(1.35, -1.6),
			"effect_spin": Vector2(-68.25, 1.75),
		},
		"attack_range": 200,
		"counts": {"idle": 6, "walk": 4, "hurt": 1, "death": 5, "hit1": 6, "hit2": 4, "hit3": 6, "hit4": 6},
		"holds":
		{
			"idle": [2, 2, 2, 3, 2, 4],
			"walk": [4, 4, 4, 4],
			"hurt": [8],
			"death": [2, 2, 2, 2, 10],
			"hit1": [2, 2, 7, 2, 2, 10],
			"hit2": [1, 1, 1, 120],
			"hit3": [2, 2, 2, 2, 2, 10],
			"hit4": [2, 2, 10, 2, 2, 10]
		},
	},
	{
		"name": "金吒",
		"root": "res://Art/monster/game_3_monster/three_prince/jinzha",
		"visual_position": Vector2(-30, -104),
		"source_origin_offset": Vector2(0, -54),
		"frame_size": Vector2i(300, 300),
		"effect_offsets":
		{
			"effect_bullet1": Vector2(-44.1, 86.5),
			"effect_guard": Vector2(2.25, -48.3),
			"effect_line": Vector2(3.8, -40.45),
			"effect_block": Vector2(54.0, 65.0),
		},
		"attack_range": 200,
		"counts": {"idle": 6, "walk": 4, "hurt": 1, "death": 5, "hit1": 4, "hit2": 3, "hit3": 4, "hit4": 1},
		"holds":
		{
			"idle": [2, 2, 2, 3, 2, 4],
			"walk": [4, 4, 4, 4],
			"hurt": [8],
			"death": [2, 2, 2, 2, 10],
			"hit1": [2, 2, 2, 10],
			"hit2": [5, 2, 10],
			"hit3": [2, 2, 2, 10],
			"hit4": [48]
		},
	},
]

static var _body_frames_cache: Dictionary = {}

@export_enum("哪吒", "木吒", "金吒") var prince_kind: int = 0

var _config: Dictionary = {}
var _base_attack: int = 0
var _skill_busy: bool = false
var _guard_active: bool = false
var _guard_mode: StringName = &""
var _guard_generation: int = 0
var _is_clone: bool = false
var _regen_elapsed: float = 0.0


func _ready() -> void:
	_configure_monster()
	_is_clone = bool(get_meta("three_prince_clone", false))
	if _is_clone:
		is_boss = false
		my_mr_name = "木吒分身"
		hp = max_hp
		fall_pro = 0.0
		fall_list = []
		independent_fall_list = []
		fall_stone_pro = 0.0
		add_to_group("stz_muzha_clone")
	_build_body_frames()
	_build_animations()
	super._ready()
	_reset_initial_skill_cooldowns()
	if _is_clone:
		var life_timer := get_tree().create_timer(10.0, true)
		life_timer.timeout.connect(_remove_timed_clone)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if level <= 50 or hp <= 0:
		return
	_regen_elapsed += delta
	if _regen_elapsed >= 1.0:
		_regen_elapsed -= 1.0
		cure_hp(maxi(1, int(max_hp / 1000.0)))


func _reset_initial_skill_cooldowns() -> void:
	match prince_kind:
		0:
			skill_1_cd = randi_range(6, 12)
			skill_2_cd = randi_range(3, 8)
			skill_3_cd = randi_range(5, 14)
		1:
			skill_1_cd = randi_range(6, 15)
			skill_2_cd = 0
			skill_3_cd = randi_range(5, 15)
		2:
			skill_1_cd = randi_range(6, 15)
			skill_2_cd = randi_range(3, 8)
			skill_3_cd = 0


func _configure_monster() -> void:
	prince_kind = clampi(prince_kind, 0, PRINCE_CONFIGS.size() - 1)
	_config = PRINCE_CONFIGS[prince_kind]
	is_boss = true
	cannot_attract = true
	set_meta("allow_role_special_control", true)
	my_mr_name = str(_config.get("name", "三太子"))
	var role_level := 50
	if RoleProp.baseroleprop != null:
		role_level = int(RoleProp.baseroleprop.Level)
	level = 50
	var level_group := ceili(float(level) / 10.0)
	max_hp = 7500000
	hp = max_hp
	_base_attack = 15000
	attack_in = 60
	def = 1700
	var source_magic_reduction := clampf(float(level) / 400.0, 0.0, 0.95)
	mdef = 1700
	crit = 20
	miss = 0
	lucky = 20
	htarget = 100
	toughness = 20
	ar = 1200
	sp = 1200
	crit_reduce = 10
	speed = 20
	mysee = 1000
	attack_range = int(_config["attack_range"])
	attack_desire = 100
	behit_calmtime = 0.1
	self_rhp = 0
	add_exp = 500
	fall_coin = level * 8
	fall_pro = 0.5
	fall_list = [{"name": "rls", "value": 1}]
	independent_fall_list = []
	match prince_kind:
		0:
			independent_fall_list = [
				{
					"name": "llst",
					"value": 1,
					"chance": THREE_PRINCE_PET_DROP_CHANCE,
				}
			]
		1:
			independent_fall_list = [
				{
					"name": "llzx",
					"value": 1,
					"chance": THREE_PRINCE_PET_DROP_CHANCE,
				}
			]
		2:
			independent_fall_list = [
				{
					"name": "llkj",
					"value": 1,
					"chance": THREE_PRINCE_PET_DROP_CHANCE,
				},
				{
					"name": "lltk",
					"value": 1,
					"chance": THREE_PRINCE_PET_DROP_CHANCE,
				},
			]
	if int(MainSet.set_data.get("Difficult", 0)) == NIGHTMARE_DIFFICULTY:
		for drop in independent_fall_list:
			drop["name"] = NIGHTMARE_EQUIPMENT_REPLACEMENTS.get(drop["name"], drop["name"])
	fall_stone_pro = 0.0
	fall_stone = []
	obj_attack_dict.clear()
	obj_attack_dict["hit1"] = {
		"power": _base_attack,
		"hurtBack": [-6, -5],
		"attackKind": "physics",
		"attackInterval": 999,
		"HitProtect": 8,
	}
	obj_attack_dict["hit2"] = {
		"power": _base_attack if prince_kind == 0 else int(_base_attack * 0.8),
		"hurtBack": [-3, 0],
		"attackKind": "physics",
		"attackInterval": 10,
		"HitProtect": 8,
	}
	obj_attack_dict["hit3"] = {
		"power": _base_attack * (2 if prince_kind < 2 else 1),
		"hurtBack": [-25, 0],
		"attackKind": "magic",
		"attackInterval": 999,
		"HitProtect": 8,
	}
	obj_attack_dict["hit4"] = {
		"power": 80 if prince_kind == 0 else _base_attack * 2,
		"hurtBack": [-25, 0],
		"attackKind": "magic",
		"attackInterval": 24 if prince_kind == 1 else 999,
		"HitProtect": 8,
	}
	if prince_kind == 2:
		var stack_effect := {
			"Name": "monster137buff",
			"AddTime": 7.0,
			"reduce_interval": 0.0,
			"value": 0.0,
			"AttackKind": "",
			"CanAdd": true,
			"DeBuff": true,
		}
		for attack_name in ["hit1", "hit2", "hit3", "hit4"]:
			obj_attack_dict[attack_name]["stz_stack_bonus"] = true
		obj_attack_dict["hit1"]["addeffect"] = stack_effect.duplicate(true)
		obj_attack_dict["hit3"]["addeffect"] = stack_effect.duplicate(true)


func monster_info_base_attack() -> int:
	if _base_attack <= 0:
		_configure_monster()
	return _base_attack


func _build_body_frames() -> void:
	var root := str(_config["root"])
	if _body_frames_cache.has(root):
		mr_ani.sprite_frames = _body_frames_cache[root] as SpriteFrames
		mr_ani.position = _config["visual_position"]
		mr_ani.animation = &"idle"
		return
	if root == NEZHA_ROOT:
		var atlas_frames := _get_nezha_frames()
		if atlas_frames != null:
			_body_frames_cache[root] = atlas_frames
			mr_ani.sprite_frames = atlas_frames
			mr_ani.position = _config["visual_position"]
			mr_ani.animation = &"idle"
			return
	var frames := SpriteFrames.new()
	if frames.has_animation(&"default"):
		frames.remove_animation(&"default")
	var counts: Dictionary = _config["counts"]
	var frame_size: Vector2i = _config["frame_size"]
	for animation_name in ["idle", "walk", "hurt", "death", "hit1", "hit2", "hit3", "hit4"]:
		var name_key := StringName(animation_name)
		frames.add_animation(name_key)
		frames.set_animation_loop(name_key, animation_name in ["idle", "walk"])
		frames.set_animation_speed(name_key, SOURCE_FPS)
		var action_root := root.path_join(animation_name)
		for frame_index in range(1, int(counts[animation_name]) + 1):
			var texture_path := action_root.path_join(str(frame_index) + ".png")
			var texture := Global.get_cached_texture(texture_path)
			if texture != null:
				if texture.get_width() > frame_size.x or texture.get_height() > frame_size.y:
					var clipped_texture := AtlasTexture.new()
					clipped_texture.atlas = texture

					var crop_origin := Vector2i(
						maxi(0, (texture.get_width() - frame_size.x) / 2),
						maxi(0, (texture.get_height() - frame_size.y) / 2)
					)
					clipped_texture.region = Rect2(Vector2(crop_origin), Vector2(frame_size))
					frames.add_frame(name_key, clipped_texture)
				else:
					frames.add_frame(name_key, texture)
	_body_frames_cache[root] = frames
	mr_ani.sprite_frames = frames
	mr_ani.position = _config["visual_position"]
	mr_ani.animation = &"idle"


static func _get_nezha_frames() -> SpriteFrames:
	var frames := load(NEZHA_FRAMES_RES) as SpriteFrames
	if frames == null:
		return null
	if not frames.has_animation(&"hurt"):
		# manifest 不含 hurt 序列，沿用已有的直接 PNG 补齐。
		var hurt_texture := Global.get_cached_texture(NEZHA_ROOT.path_join("hurt/1.png"))
		frames.add_animation(&"hurt")
		frames.set_animation_loop(&"hurt", false)
		frames.set_animation_speed(&"hurt", SOURCE_FPS)
		if hurt_texture != null:
			frames.add_frame(&"hurt", hurt_texture)
	return frames


func _build_animations() -> void:
	if mr_player.has_animation_library(&""):
		mr_player.remove_animation_library(&"")
	var library := AnimationLibrary.new()
	var holds: Dictionary = _config["holds"]
	for action_name in ["idle", "walk", "hurt", "death", "hit1", "hit2", "hit3", "hit4"]:
		var animation := _make_action(StringName(action_name), holds[action_name], action_name in ["idle", "walk"])
		if action_name in ["hit1", "hit2", "hit3", "hit4"]:
			_add_prince_action_events(animation, action_name, holds[action_name])
		elif action_name == "death":
			_add_death_method(animation)
		var library_name := &"wait" if action_name == "idle" else StringName(action_name)
		library.add_animation(library_name, animation)
	mr_player.add_animation_library(&"", library)


func _make_action(sprite_animation: StringName, frame_holds: Array, looped: bool) -> Animation:
	var animation := Animation.new()
	animation.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
	var animation_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(animation_track, NodePath("MonsterDir/mr_ani:animation"))
	animation.value_track_set_update_mode(animation_track, Animation.UPDATE_DISCRETE)
	animation.track_insert_key(animation_track, 0.0, sprite_animation)
	var frame_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(frame_track, NodePath("MonsterDir/mr_ani:frame"))
	animation.value_track_set_update_mode(frame_track, Animation.UPDATE_DISCRETE)
	var elapsed := 0.0
	for frame_index in range(frame_holds.size()):
		animation.track_insert_key(frame_track, elapsed, frame_index)
		elapsed += float(frame_holds[frame_index]) / SOURCE_FPS
	animation.length = maxf(elapsed, 0.08)
	return animation


func _add_prince_action_events(animation: Animation, action_name: String, frame_holds: Array) -> void:
	var events: Array = []
	match prince_kind:
		0:
			match action_name:
				"hit1":
					events = [[_frame_start_time(frame_holds, 1), 0], [_frame_start_time(frame_holds, 3), 1]]
				"hit2":
					events = [[_frame_start_time(frame_holds, 3), 0]]
				"hit3":
					events = [[_frame_start_time(frame_holds, 1), 0]]
				"hit4":
					events = [[_frame_start_time(frame_holds, 2), 0]]
		1:
			match action_name:
				"hit1":
					events = [[_frame_start_time(frame_holds, 2), 0], [_frame_start_time(frame_holds, 5), 1]]
				"hit2":
					events = [[0.0, 0]]
					var shot_start := _frame_start_time(frame_holds, 3)
					for shot_index in range(5):
						events.append([shot_start + float(shot_index), shot_index + 1])
				"hit3":
					events = [[_frame_start_time(frame_holds, 5), 0]]
				"hit4":
					events = [[_frame_start_time(frame_holds, 2), 0], [_frame_start_time(frame_holds, 5), 1]]
		2:
			match action_name:
				"hit1":
					events = [[_frame_start_time(frame_holds, 3), 0]]
				"hit2":
					events = [[_frame_start_time(frame_holds, 2), 0]]
				"hit3":
					events = [[_frame_start_time(frame_holds, 3), 0]]
				"hit4":
					events = [[0.0, 0]]
	if events.is_empty():
		return
	var track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track, NodePath("."))
	for event in events:
		animation.track_insert_key(
			track,
			clampf(float(event[0]), 0.0, maxf(animation.length - 0.001, 0.0)),
			{"method": &"_perform_prince_attack", "args": [action_name, int(event[1])]}
		)


func _frame_start_time(frame_holds: Array, frame_index: int) -> float:
	var tick_count := 0
	for index in range(mini(frame_index, frame_holds.size())):
		tick_count += int(frame_holds[index])
	return float(tick_count) / SOURCE_FPS


func _add_death_method(animation: Animation) -> void:
	var track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track, NodePath("."))
	animation.track_insert_key(
		track, maxf(animation.length - 0.001, 0.0), {"method": &"settle_death_drops_and_free", "args": []}
	)


func ai_think() -> void:
	var role_x_value = RoleProp.get_nearest_monster_target_position(global_position).x
	if role_x_value == null:
		return
	var role_x := float(role_x_value)
	if absf(role_x - position.x) < float(mysee):
		has_target = true
	if is_limit_buff() or cannotchangestatewhenattorbeatt() or _skill_busy:
		return
	if not has_target:
		normal_state()
		return
	var distance := absf(role_x - position.x)
	match prince_kind:
		0:
			if distance <= 400.0 and skill_3_cd <= 0:
				_use_prince_action(&"hit4", 3, randi_range(5, 14))
				return
			if distance <= 400.0 and skill_2_cd <= 0:
				_use_prince_action(&"hit3", 2, randi_range(3, 8))
				return
			if distance <= 600.0 and skill_1_cd <= 0:
				_use_prince_action(&"hit2", 1, randi_range(6, 12))
				return
		1:
			if distance <= 400.0 and skill_3_cd <= 0:
				_use_prince_action(&"hit4", 3, randi_range(5, 15))
				return
			if distance <= 600.0 and skill_1_cd <= 0:
				_use_prince_action(&"hit2", 1, randi_range(6, 15))
				return
		2:
			if distance >= 300.0 and skill_3_cd <= 0 and _has_incoming_role_projectile():
				_use_prince_action(&"hit4", 3, randi_range(5, 15))
				return
			if distance <= 400.0 and skill_2_cd <= 0:
				_use_prince_action(&"hit3", 2, randi_range(3, 8))
				return
			if distance <= 600.0 and skill_1_cd <= 0:
				_use_prince_action(&"hit2", 1, randi_range(6, 15))
				return
	if distance > float(attack_range):
		have_target()
		return
	stop_move()
	if count % maxi(attack_in, 1) == 0:
		_use_prince_action(&"hit1", 0, 0)


func _use_prince_action(action_name: StringName, cooldown_slot: int, cooldown: int) -> void:
	if _skill_busy or death():
		return
	_skill_busy = true
	to_hero()
	hit_name = String(action_name)
	velocity.x = 0.0
	is_attacking = true
	match cooldown_slot:
		1:
			skill_1_cd = cooldown
		2:
			skill_2_cd = cooldown
		3:
			skill_3_cd = cooldown
	mr_player.play(action_name)
	await mr_player.animation_finished
	if death():
		return
	hit_box.disabled = true
	is_attacking = false
	_skill_busy = false
	stop_move()


func _perform_prince_attack(action_name: String, event_phase: int = 0) -> void:
	if death():
		return

	var facing := 1.0 if _faces_right() else -1.0
	match prince_kind:
		0:
			match action_name:
				"hit1":
					if event_phase == 0:
						_spawn_effect("effect_bullet1_a", 10, "hit1", Vector2(facing * 190.0, -135.0), 0.45, 72.0)
					else:
						_spawn_effect("effect_bullet1_b", 10, "hit1", Vector2(facing * 100.0, -40.0), 0.45, 72.0)
				"hit2":
					_spawn_effect(
						"effect_chase",
						36,
						"hit2",
						Vector2(facing * 160.0, 0.0),
						1.5,
						78.0,
						Vector2.ZERO,
						false,
						0.0,
						Vector2.ONE,
						true,
						"",
						1,
						SOURCE_FPS,
						true
					)
				"hit3":
					_spawn_aimed_effect(
						"effect_wind", 1, "hit3", Vector2(-facing * 25.0, 75.0), 4.0, 72.0, 120.0, 576.0
					)
					_spawn_aimed_effect("effect_wind", 1, "hit3", Vector2(facing * 25.0, 55.0), 4.0, 72.0, 72.0, 576.0)
				"hit4":
					_start_guard("effect_guard", 103, 103.0 / SOURCE_FPS, &"heal", 1.0, Vector2(0.0, 40.0))
		1:
			match action_name:
				"hit1":
					if event_phase == 0:
						_spawn_effect("effect_bullet1_a", 10, "hit1", Vector2(facing * 160.0, -85.0), 0.45, 70.0)
					else:
						_spawn_effect("effect_bullet1_b", 11, "hit1", Vector2(facing * 165.0, -150.0), 0.5, 76.0)
				"hit2":
					if event_phase == 0:
						_spawn_effect(
							"effect_aura",
							10,
							"hit2",
							Vector2.ZERO,
							5.125,
							105.0,
							Vector2.ZERO,
							false,
							0.0,
							Vector2.ONE,
							true,
							"",
							1,
							SOURCE_FPS,
							true,
							true
						)
					else:
						_spawn_aimed_effect("effect_target", 1, "hit2", Vector2.ZERO, 3.0, 52.0, 72.0, 576.0)
				"hit3":
					if not _is_clone:
						_spawn_muzha_clone()
				"hit4":
					_spawn_effect("effect_spin", 91, "hit4", Vector2.ZERO, 3.0, 175.0)
		2:
			match action_name:
				"hit1":
					_spawn_effect("effect_bullet1", 15, "hit1", Vector2(facing * 190.0, -115.0), 0.65, 76.0)
				"hit2":
					_start_guard("effect_guard", 27, 5.0, &"reflect", 1.0, Vector2.ZERO)
				"hit3":
					_spawn_jinzha_lines(facing)
				"hit4":
					_start_guard("effect_block", 1, 2.0, &"fortify", 0.1, Vector2(facing * 90.0, -80.0))


func _spawn_effect(
	effect_dir: String,
	effect_frames: int,
	attack_name: String,
	local_offset: Vector2,
	duration: float,
	radius: float,
	_velocity: Vector2 = Vector2.ZERO,
	track: bool = false,
	tracking_speed: float = 0.0,
	_scale: Vector2 = Vector2.ONE,
	damage: bool = true,
	frame_format_: String = "",
	frame_start_index_: int = 1,
	frame_fps_: float = SOURCE_FPS,
	follow_owner_: bool = false,
	loop_visual_: bool = false,
	max_distance_: float = 0.0
) -> ThreePrinceBullet:
	if bullet == null or not is_instance_valid(bullet):
		return null
	var effect := BULLET_SCENE.instantiate() as ThreePrinceBullet
	if effect == null:
		return null
	effect.frame_root = str(_config["root"]).path_join(effect_dir)
	if prince_kind == 0 and effect_dir in NEZHA_ATLAS_EFFECTS:
		effect.frames_resource_path = NEZHA_FRAMES_RES
		effect.frames_animation = StringName(effect_dir)
	effect.frame_path_format = frame_format_
	effect.frame_start_index = frame_start_index_
	effect.frame_count = effect_frames
	effect.frame_fps = frame_fps_
	effect.life_time = duration
	effect.hit_delay = 0.08
	effect.hit_duration = maxf(duration - 0.16, 0.1)
	effect.hit_radius = radius
	effect.visual_scale = _scale
	var effect_offsets: Dictionary = _config["effect_offsets"]
	var configured_offset: Variant = effect_offsets.get(effect_dir, Vector2.ZERO)
	if configured_offset is Vector2:
		effect.visual_offset = configured_offset
	effect.move_velocity = _velocity
	effect.max_distance = max_distance_
	effect.track_target = track
	effect.track_speed = tracking_speed
	effect.damage_enabled = damage
	effect.follow_owner = follow_owner_
	var resolved_offset := _resolve_source_offset(local_offset)
	effect.follow_owner_offset = resolved_offset
	effect.loop_visual = loop_visual_
	effect.additive_blend = prince_kind == 0 and effect_dir in ["effect_wind", "effect_guard"]
	effect.att_list = obj_attack_dict.get(attack_name, {})
	if effect.att_list is Dictionary:
		effect.attack_interval_frames = maxi(int(effect.att_list.get("attackInterval", 0)), 0)
	effect.hit_name = attack_name
	effect.skill_name = "STZ_%s_%s" % [str(_config.get("name", "三太子")), effect_dir]
	effect.dir = _faces_right()
	bullet.add_child(effect)

	effect.global_position = global_position + resolved_offset
	return effect


func _spawn_aimed_effect(
	effect_dir: String,
	effect_frames: int,
	attack_name: String,
	local_offset: Vector2,
	duration: float,
	radius: float,
	launch_speed: float,
	acceleration: float
) -> void:
	var start_position := global_position + _resolve_source_offset(local_offset)
	var target_position := start_position + Vector2((1.0 if _faces_right() else -1.0) * 500.0, 0.0)
	if RoleProp.source_player != null and is_instance_valid(RoleProp.source_player):
		target_position = RoleProp.source_player.global_position + Vector2(0.0, -55.0)
	var aim_direction := start_position.direction_to(target_position)
	if aim_direction == Vector2.ZERO:
		aim_direction = Vector2(1.0 if _faces_right() else -1.0, 0.0)
	var effect := _spawn_effect(
		effect_dir,
		effect_frames,
		attack_name,
		local_offset,
		duration,
		radius,
		aim_direction * launch_speed,
		false,
		0.0,
		Vector2.ONE,
		true,
		"",
		1,
		SOURCE_FPS,
		false,
		false,
		1000.0
	)
	if effect != null:
		effect.move_acceleration = aim_direction * acceleration


func _start_guard(
	effect_dir: String,
	effect_frames: int,
	duration: float,
	guard_mode: StringName,
	damage_multiplier: float,
	local_offset: Vector2
) -> void:
	var attack_name := "hit4" if guard_mode != &"reflect" else "hit2"
	var loop_visual := duration > float(effect_frames) / SOURCE_FPS + 0.05
	_spawn_effect(
		effect_dir,
		effect_frames,
		attack_name,
		local_offset,
		duration,
		1.0,
		Vector2.ZERO,
		false,
		0.0,
		Vector2.ONE,
		false,
		"",
		1,
		SOURCE_FPS,
		true,
		loop_visual
	)
	_guard_generation += 1
	var generation := _guard_generation
	_guard_active = true
	_guard_mode = guard_mode
	super_armor_active = guard_mode == &"fortify"
	hurt_bl = damage_multiplier
	await get_tree().create_timer(duration, true).timeout
	if is_instance_valid(self) and generation == _guard_generation:
		_guard_active = false
		_guard_mode = &""
		super_armor_active = false
		hurt_bl = 1.0


func _spawn_muzha_clone() -> void:
	var active_monster_count := 0
	if get_parent() != null:
		for child in get_parent().get_children():
			if child is BaseMonster and not child.death() and not child.is_queued_for_deletion():
				active_monster_count += 1
	if active_monster_count >= 5:
		return
	var packed := load("res://Scene/monster/monster_4402.tscn") as PackedScene
	if packed == null or get_parent() == null:
		return
	var clone := packed.instantiate() as BaseMonster
	if clone == null:
		return
	clone.set_meta("three_prince_clone", true)
	get_parent().add_child(clone)
	clone.global_position = global_position + Vector2(0.0, -100.0)


func _spawn_jinzha_lines(facing: float) -> void:
	for line_index in range(6):
		var offset_x := facing * (45.0 + float(line_index) * 90.0)
		_spawn_effect(
			"effect_line", 17, "hit3", Vector2(offset_x, 50.0), 0.9, 62.0, Vector2.ZERO, false, 0.0, Vector2(0.9, 0.9)
		)


func _resolve_source_offset(local_offset: Vector2) -> Vector2:
	var origin_offset: Variant = _config.get("source_origin_offset", Vector2.ZERO)
	if origin_offset is Vector2:
		return local_offset + origin_offset
	return local_offset


func _faces_right() -> bool:
	return monster_dir != null and monster_dir.scale.x < 0.0


func _has_incoming_role_projectile() -> bool:
	if RoleProp.source_player == null or not is_instance_valid(RoleProp.source_player):
		return false
	var bullet_root: Node = RoleProp.source_player.get_node_or_null("Bullet")
	if bullet_root == null:
		return false
	return _has_nearby_projectile_recursive(bullet_root)


func _has_nearby_projectile_recursive(node: Node) -> bool:
	for child in node.get_children():
		if child is Node2D and global_position.distance_to((child as Node2D).global_position) <= 150.0:
			return true
		if _has_nearby_projectile_recursive(child):
			return true
	return false


func _remove_timed_clone() -> void:
	if _is_clone and is_instance_valid(self) and not is_queued_for_deletion():
		queue_free()


func _on_hurt_box_area_entered(area: Area2D) -> void:
	var incoming_kind: String = _get_incoming_attack_kind(area)
	var incoming_attacker: Node = _get_incoming_attacker(area)
	var hp_before := hp
	super._on_hurt_box_area_entered(area)
	var received_damage := maxi(hp_before - hp, 0)
	if (
		received_damage > 0
		and incoming_kind == "magic"
		and prince_kind == 1
		and not _is_clone
		and not death()
		and not _skill_busy
		and randi_range(0, 99) < 8
	):
		call_deferred("_use_prince_action", &"hit3", 2, randi_range(3, 8))
	if not _guard_active:
		return
	if _guard_mode == &"heal" and received_damage > 0:
		hp = mini(max_hp, hp_before + received_damage)
	elif _guard_mode == &"reflect" and incoming_kind == "magic" and received_damage > 0:
		if (
			incoming_attacker != null
			and is_instance_valid(incoming_attacker)
			and incoming_attacker.has_method("effect_reducehp")
		):
			incoming_attacker.effect_reducehp(received_damage, "real")


func _get_incoming_attack_source(area: Area2D) -> Node:
	if area == null or not is_instance_valid(area):
		return null
	if area is BaseRoleHitBox or area is RolehmzBullet:
		return get_player
	if area is MagicWeaponHit:
		return area.get_parent()
	var parent: Node = area.get_parent()
	if parent == null:
		return null
	if parent is Role1Shallow:
		return parent
	if area is RoleBullet1:
		return area
	var grand_parent: Node = parent.get_parent()
	if grand_parent is RoleBullet:
		return grand_parent
	return null


func _get_incoming_attack_kind(area: Area2D) -> String:
	var source: Node = _get_incoming_attack_source(area)
	if source == null or not is_instance_valid(source):
		return ""
	var hit_data: Variant = source.get("hit_dic")
	if hit_data is Dictionary:
		return str(hit_data.get("attackKind", ""))
	if source is BaseHero:
		var action_name: String = str(source.get("get_action"))
		var attack_data: Variant = source.obj_attack_dict.get(action_name, {})
		if attack_data is Dictionary:
			return str(attack_data.get("attackKind", ""))
	return ""


func _get_incoming_attacker(area: Area2D) -> Node:
	var source: Node = _get_incoming_attack_source(area)
	if source == null or not is_instance_valid(source):
		return get_player if get_player != null and is_instance_valid(get_player) else null
	if source is BaseHero:
		return source
	var player_value: Variant = source.get("Player")
	if player_value is BaseHero and is_instance_valid(player_value):
		return player_value
	var parent: Node = source
	var depth: int = 0
	while parent != null and depth < 8:
		if parent is BaseHero:
			return parent
		parent = parent.get_parent()
		depth += 1
	return get_player if get_player != null and is_instance_valid(get_player) else null


func _interrupt_attack_state_on_hit() -> void:
	if _guard_active and _guard_mode == &"heal":
		return
	super._interrupt_attack_state_on_hit()


func state_hurt() -> void:
	if _guard_active and _guard_mode == &"heal":
		return
	super.state_hurt()


func is_control_immune() -> bool:
	if _guard_active and _guard_mode == &"fortify":
		return true
	return super.is_control_immune()
