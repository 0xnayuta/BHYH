extends BaseMonster
class_name LiuShaRiverBoss

const SOURCE_FPS := 24.0

const DASH_SCALE := 15.0

const GXP_GRAVITY_SCALE := 2.5
const BODY_ROOT := "res://Art/monster/liu_sha_river"
const ORIGINAL_EFFECT_ROOT := BODY_ROOT + "/original_effects"
const ORIGINAL_ROLE1_EFFECT_ROOT := ORIGINAL_EFFECT_ROOT + "/role_1"
const ORIGINAL_ROLE2_EFFECT_ROOT := ORIGINAL_EFFECT_ROOT + "/role_2"
const ORIGINAL_MONSTER172_EFFECT_ROOT := ORIGINAL_EFFECT_ROOT + "/monster_172"
const SHADOW_SCRIPT := preload("res://Script/monster/liu_sha_river_shadow.gd")

const SKILL_CD := {
	31: {"initial": 2.0, "repeat": 4.0, "special": 4.0, "teleport": 1.0},
	34: {"initial": 2.0, "repeat": 6.0, "special": 4.0, "teleport": 1.0},
	192: {"skill1_initial": 6.0, "skill1_repeat": 9.0, "skill2_initial": 8.0, "skill2_repeat": 12.0},
}

const SHADOW_LIFETIME := {31: 8.0, 34: 3.0}

const MONKEY_SKILL_REACH := {
	"hit5": 210.0,
	"hit6": 100.0,
	"hit7": 280.0,
	"hit8": 170.0,
	"hit9": 350.0,
	"hit10": 620.0,
	"hit12": 620.0,
	"hit13": 270.0,
	"hit14": 150.0,
}
const HIT_INTERVALS := {
	31: {"hit2": 4, "hit5": 48},
	34: {"hit7": 4, "hit8": 3, "hit10_2": 5, "hit10_3": 5, "hit11_1": 5, "hit11_2": 5, "hit12": 5},
	192: {"hit3": 10},
}

const ACTIONS := {
	31:
	{
		"wait": ["wait", [2, 2, 2, 3, 2, 4, 2, 2, 2, 14], true],
		"walk": ["walk", [4, 4, 4, 4], true],
		"jump1": ["jump1", [1], false],
		"jump2": ["jump2", [2, 2, 2, 2, 2], true],
		"jump3": ["jump3", [1], false],
		"hurt": ["hurt", [8], false],
		"death": ["hurt", [24], false],
		"hit1": ["hit1", [2, 4, 12], false],
		"hit3": ["hit3", [2, 10, 2, 40], false],
		"hit4_1": ["hit4_1", [2, 2], false],
		"hit4_2": ["hit4_2", [2, 2, 6], false],
		"hit5": ["hit5", [10, 2, 15], false],
		"hit6": ["hit6", [2, 2, 20], false],
		"hit7": ["hit7", [2, 2, 10], false],
		"hit8": ["hit8", [30], false],
		"hit9": ["hit9", [55], false],
	},
	34:
	{
		"wait": ["wait", [2, 2, 2, 3, 2, 4, 5, 5], true],
		"walk": ["walk", [4, 4, 4, 4], true],
		"jump1": ["jump1", [1], false],
		"jump2": ["jump2", [2, 2, 2, 2, 2], true],
		"jump3": ["jump3", [1], false],
		"hurt": ["hurt", [8], false],
		"death": ["hurt", [24], false],
		"hit1": ["hit1", [2, 2, 1, 1, 3], false],
		"hit3": ["hit3", [1, 1, 1, 1, 5], false],
		"hit4": ["hit4", [1, 1, 1, 1, 12], false],
		"hit5": ["hit5", [2, 2, 1, 1, 10], false],
		"hit6": ["hit6", [2, 2, 1, 6], false],
		"hit7": ["hit7", [15], false],
		"hit8": ["hit8", [2, 3, 2, 3], false],
		"hit9": ["hit9", [10], false],
		"hit10": ["hit10", [100], false],
		"hit11_1": ["hit11_1", [35], false],
		"hit11_2": ["hit11_2", [35], false],
		"hit12": ["hit12", [17], false],
		"hit13": ["hit13", [10], false],
		"hit14": ["hit14", [2, 12, 16], false],
	},
	192:
	{
		"wait": ["wait", [2, 2, 2, 3, 2, 4], true],
		"walk": ["walk", [4, 4, 4, 4], true],
		"hurt": ["hurt", [8], false],
		"death": ["death", [2, 2, 2, 2, 10], false],
		"hit1": ["hit1", [2, 2, 2, 1, 1, 1, 10], false],
		"hit2": ["hit2", [2, 2, 2, 1, 1, 1, 10], false],
		"hit3": ["hit3", [2, 2], false],
	},
}

const BODY_POSITIONS := {
	31: Vector2(-15, -54),
	34: Vector2(-5, -70),
	192: Vector2(-2, -87),
}

const SOURCE_BODY_OFFSETS := {31: Vector2(-15, 0), 34: Vector2(-5, -15), 192: Vector2(-2, -30)}
const SOURCE_ORIGIN_OFFSETS := {31: Vector2(0, -54), 34: Vector2(0, -55), 192: Vector2(0, -57)}

const ATTACK_EVENTS := {
	31:
	{
		"hit1": [[6.0 / SOURCE_FPS, "hit1"]],
		"hit3": [[12.0 / SOURCE_FPS, "hit3"]],
		"hit4_2": [[4.0 / SOURCE_FPS, "hit4_2"]],
		"hit5": [[12.0 / SOURCE_FPS, "hit5"]],
		"hit6": [[4.0 / SOURCE_FPS, "hit6"]],
		"hit7": [[4.0 / SOURCE_FPS, "hit7"]],
		"hit8": [[0.0, "hit8"]],
		"hit9": [[0.0, "hit9_1"], [10.0 / SOURCE_FPS, "hit9_2"]],
	},
	34:
	{
		"hit1": [[4.0 / SOURCE_FPS, "hit1"]],
		"hit3": [[0.0, "hit3"]],
		"hit4": [[0.0, "hit4"]],
		"hit5": [[4.0 / SOURCE_FPS, "hit5"]],
		"hit6": [[2.0 / SOURCE_FPS, "hit6"]],
		"hit7": [[0.0, "hit7"]],
		"hit8": [[0.0, "hit8"]],
		"hit9": [[0.0, "hit9"]],
		"hit10": [[0.0, "hit10_1"], [5.0 / SOURCE_FPS, "hit10_2"]],
		"hit11_1": [[0.0, "hit11_1"]],
		"hit11_2": [[0.0, "hit11_2"]],
		"hit12": [[0.0, "hit12_1"], [16.0 / SOURCE_FPS, "hit12_2"]],
		"hit14": [[0.0, "hit14_1"], [14.0 / SOURCE_FPS, "hit14_2"]],
	},
	192:
	{
		"hit1": [[6.0 / SOURCE_FPS, "hit1"]],
		"hit2": [[6.0 / SOURCE_FPS, "hit2"]],
		"hit3": [[2.0 / SOURCE_FPS, "hit3"]],
	},
}

const ATTACK_INFO := {
	31:
	{
		"hit1": [1.0, -2, -3, "magic"],
		"hit2": [0.3, -10, -1, "magic"],
		"hit3": [0.8, -7, -4, "magic"],
		"hit4": [5.0, -8, -3, "magic"],
		"hit5": [2.0, -15, -2, "magic"],
		"hit6": [1.0, -14, -25, "magic"],
		"hit7": [1.0, -15, 0, "magic"],
		"hit8": [1.0, -8, -2, "magic"],
		"hit9_1": [1.0, 0, -2, "magic"],
		"hit9_2": [1.0, -8, -2, "magic"],
	},
	34:
	{
		"hit1": [1.0, -2, -3, "physics"],
		"hit2": [1.0, -0.5, -3, "physics"],
		"hit3": [1.0, -0.5, -3, "physics"],
		"hit4": [1.0, -8, -3, "physics"],
		"hit5": [1.0, -15, -2, "physics"],
		"hit6": [2.0, -14, -25, "physics"],
		"hit7": [0.5, -15, 0, "magic"],
		"hit8": [1.2, -8, -2, "magic"],
		"hit9": [0.769, 0, -2, "magic"],
		"hit10_2": [0.5, -2, -2, "physics"],
		"hit10_3": [0.5, -10, 20, "magic"],
		"hit10_4": [2.0, -10, -15, "magic"],
		"hit11_1": [0.6, -20, 0, "magic"],
		"hit11_2": [0.6, 0, -25, "magic"],
		"hit12": [1.0, 0, 0, "magic"],
		"hit13": [0.24, 0, 0, "physics"],
		"hit14": [15.0, -20, 0, "physics"],
	},
	192:
	{
		"hit1": [4.0, -6, -5, "physics"],
		"hit2": [7.0, 1, 0, "magic"],
		"hit3": [5.0, -14, -5, "physics"],
	},
}

const EFFECT_INFO := {
	"role_1_bullet_1": [Vector2(144, 49), Vector2(57.4, 17.1)],
	"role_1_bullet_3": [Vector2(198, 197), Vector2(-5.8, 88.1)],
	"role_1_bullet_4": [Vector2(316, 58), Vector2(153.9, 19.1)],
	"role_1_bullet_5": [Vector2(305, 80), Vector2(112.9, 30.4)],
	"role_1_bullet_6": [Vector2(142, 193), Vector2(6.1, -83.5)],
	"role_1_bullet_7": [Vector2(289, 89), Vector2(142.8, 53.3)],
	"role_1_bullet_8": [Vector2(369, 158), Vector2(6.8, -27.2)],
	"role_1_bullet_9": [Vector2(225, 98), Vector2(112.5, 61.7)],
	"role_1_bullet_10_2": [Vector2(368, 231), Vector2(-36.8, -6.3)],
	"role_1_bullet_10_3": [Vector2(164, 237), Vector2(-86.8, 129.0)],
	"role_1_bullet_10_4": [Vector2(197, 178), Vector2(-10.0, -50.7)],
	"role_1_bullet_11_1": [Vector2(234, 155), Vector2(69.6, 101.3)],
	"role_1_bullet_11_2": [Vector2(210, 221), Vector2(-17.8, 59.5)],
	"role_1_bullet_12": [Vector2(190, 190), Vector2(0.0, 0.0)],
	"role_1_bullet_12_1_1": [Vector2(36, 38), Vector2(1.6, 4.4)],
	"role_1_bullet_12_1_2": [Vector2(133, 79), Vector2(66.6, 38.9)],
	"role_1_bullet_13": [Vector2(268, 273), Vector2(-17.0, 6.2)],
	"role_1_bullet_14_1": [Vector2(151, 151), Vector2(1.3, 1.3)],
	"role_1_bullet_14_2": [Vector2(194, 123), Vector2(96.5, 61.5)],
	"role_2_bullet_1": [Vector2(531, 41), Vector2(-203.5, 1.0)],
	"role_2_bullet_2": [Vector2(1032, 59), Vector2(-450.0, -0.5)],
	"role_2_bullet_3": [Vector2(404, 125), Vector2(-7.0, -6.7)],
	"role_2_bullet_4_1": [Vector2(174, 60), Vector2(81.8, 27.6)],
	"role_2_bullet_4_2": [Vector2(266, 431), Vector2(30.6, 179.1)],
	"role_2_bullet_5": [Vector2(141, 143), Vector2(95.5, 109.5)],
	"role_2_bullet_6": [Vector2(212, 244), Vector2(-0.5, -46.9)],
	"role_2_bullet_7": [Vector2(468, 105), Vector2(3.1, 11.0)],
	"role_2_bullet_8": [Vector2(482, 277), Vector2(-4.5, -24.5)],
	"role_2_bullet_9_1": [Vector2(91, 91), Vector2(-6.2, 12.5)],
	"role_2_bullet_9_2": [Vector2(300, 299), Vector2(150.0, 150.5)],
	"monster_172_bullet_1": [Vector2(665, 40), Vector2(-284.6, 0.0)],
	"monster_172_bullet_2": [Vector2(665, 40), Vector2(-284.6, 0.0)],
	"monster_172_bullet_3": [Vector2(665, 40), Vector2(-284.6, 0.0)],
}

const HIT_SIZE_CAP := Vector2(560.0, 340.0)


class AttackOrigin:
	extends Node2D
	var hit_name: String = ""
	var obj_attack_dict: Dictionary = {}


@export_enum("邪唐僧:31", "邪悟空:34", "邪后羿:192") var boss_kind := 31

var _skill_busy := false
var _active_skill := ""
var _chain_skill := ""
var _skill_time := 0.0
var _skill1_cd := 0.0
var _skill2_cd := 0.0
var _body_frame_offsets: Dictionary = {}
var _body_foot_baseline := 0
var _shadows: Array = []
var _gxp_timer := 0.0
var _gxp_active := false
var _gxp_afterimage_timer := 0.0
var _hit13_resolved := false
var _skill_serial := 0
var _water_float_left := 0.0


func _ready() -> void:
	_configure_boss()
	_build_original_animations()
	super._ready()
	_skill1_cd = _initial_cooldown(1)
	_skill2_cd = _initial_cooldown(2)

	_gxp_timer = 10.0 if boss_kind != 192 else 0.0


func _exit_tree() -> void:
	for shadow in _shadows:
		if is_instance_valid(shadow):
			shadow.queue_free()
	_shadows.clear()


func _configure_boss() -> void:
	is_boss = true
	cannot_attract = true
	level = 55
	crit = 30
	miss = 18
	lucky = 20
	htarget = 40
	toughness = 20
	ar = 80
	sp = 80
	speed = 12
	mysee = 1000
	behit_calmtime = 0.08
	self_rhp = 0
	add_exp = 0
	fall_coin = 500
	fall_pro = 0.5
	fall_list = []
	fall_stone_pro = 0.0
	fall_stone = []
	attack_range = 250
	match boss_kind:
		31:
			my_mr_name = "邪·唐僧"
			fall_list = [{"name": "yxsp_1", "value": 1}]
			max_hp = 650000
			attack_in = 1100
			def = 350
			mdef = 450
			attack_desire = 80
		34:
			attack_range = 150
			my_mr_name = "邪·悟空"
			fall_list = [{"name": "yxsp_2", "value": 1}]
			max_hp = 800000
			attack_in = 1300
			def = 500
			mdef = 350
			attack_desire = 80
		192:
			my_mr_name = "邪·后羿"
			fall_list = [{"name": "yxsp_3", "value": 1}]
			max_hp = 1000000
			attack_in = 1500
			def = 450
			mdef = 450
			attack_desire = 70
	hp = max_hp
	_fill_attack_dictionary()


func _fill_attack_dictionary() -> void:
	obj_attack_dict.clear()
	var base_hurt := float(attack_in)
	var info: Dictionary = ATTACK_INFO[boss_kind]
	for key in info:
		var row: Array = info[key]
		obj_attack_dict[str(key)] = {
			"power": int(base_hurt * float(row[0])),
			"hurtBack": [float(row[1]), float(row[2])],
			"attackKind": str(row[3]),
			"HitProtect": 5,
		}


func _build_original_animations() -> void:
	var action_config: Dictionary = ACTIONS[boss_kind]
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	_body_frame_offsets.clear()
	_body_foot_baseline = 0
	for action_name_value in action_config:
		var action_name := str(action_name_value)
		var data: Array = action_config[action_name]
		var source_name := str(data[0])
		var holds: Array = data[1]
		frames.add_animation(action_name)
		frames.set_animation_loop(action_name, bool(data[2]))
		frames.set_animation_speed(action_name, SOURCE_FPS)
		var frame_offsets: Array[float] = []
		for index in range(holds.size()):
			var texture_path := _body_path(source_name, index + 1)
			var texture := ResourceLoader.load(texture_path, "Texture2D", ResourceLoader.CACHE_MODE_REUSE) as Texture2D
			if texture == null:
				push_error("流沙河 Boss 动作帧缺失: " + texture_path)
				continue
			frames.add_frame(action_name, texture, float(holds[index]))
			frame_offsets.append(0.0)
			if action_name == "wait" and index == 0:
				_body_foot_baseline = _texture_alpha_bottom(texture)
		_body_frame_offsets[action_name] = frame_offsets
	if _body_foot_baseline <= 0:
		_body_foot_baseline = 170
	mr_ani.sprite_frames = frames
	mr_ani.centered = true
	mr_ani.position = BODY_POSITIONS[boss_kind]
	if not mr_ani.frame_changed.is_connected(_on_body_frame_changed):
		mr_ani.frame_changed.connect(_on_body_frame_changed)
	_align_body_frame()

	if mr_player.has_animation_library(&""):
		mr_player.remove_animation_library(&"")
	var library := AnimationLibrary.new()
	for action_name_value in action_config:
		var action_name := str(action_name_value)
		var data: Array = action_config[action_name]
		var animation := _make_action_animation(action_name, data[1], bool(data[2]))
		library.add_animation(action_name, animation)
	mr_player.add_animation_library(&"", library)


func _body_path(action_name: String, frame_number: int) -> String:
	return "%s/monster_%d/%s/%d.png" % [BODY_ROOT, boss_kind, action_name, frame_number]


func _make_action_animation(action_name: String, holds: Array, looped: bool) -> Animation:
	var animation := Animation.new()
	animation.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
	var duration := 0.0
	for hold_value in holds:
		duration += float(hold_value) / SOURCE_FPS
	animation.length = maxf(duration, 0.05)

	if boss_kind == 31 and action_name == "hit4_1":
		animation.length = 0.5
	elif boss_kind == 34 and action_name == "hit11_1":
		animation.length = 1.0
	var method_track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(method_track, NodePath("."))
	animation.track_insert_key(method_track, 0.0, {"method": &"_play_body_action", "args": [action_name]})
	var attack_events: Array = ATTACK_EVENTS.get(boss_kind, {}).get(action_name, [])
	for event_index in range(attack_events.size()):
		var entry: Array = attack_events[event_index]
		var event_time := minf(float(entry[0]), animation.length - 0.001)
		animation.track_insert_key(
			method_track, event_time, {"method": &"_execute_attack_event", "args": [str(entry[1])]}
		)
	if action_name == "death":
		animation.track_insert_key(
			method_track, animation.length - 0.001, {"method": &"settle_death_drops_and_free", "args": []}
		)
	return animation


func _play_body_action(action_name: String) -> void:
	if mr_ani.sprite_frames != null and mr_ani.sprite_frames.has_animation(action_name):
		mr_ani.play(action_name)
		_align_body_frame()


func _on_body_frame_changed() -> void:
	_align_body_frame()


func _align_body_frame() -> void:
	mr_ani.offset = Vector2.ZERO
	mr_ani.position = BODY_POSITIONS[boss_kind]
	if boss_kind == 34 and mr_ani.animation == &"hit14":
		mr_ani.position.y -= 15.0


func _texture_alpha_bottom(texture: Texture2D) -> int:
	var image := texture.get_image()
	if image == null or image.is_empty():
		return 0
	for y in range(image.get_height() - 1, -1, -1):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.02:
				return y
	return 0


func _physics_process(delta: float) -> void:
	_water_float_left = maxf(0.0, _water_float_left - delta)
	_tick_cooldowns(delta)
	_tick_gxp(delta)
	_update_shadows(delta)
	_tick_skill_motion(delta)
	if _gxp_active and not is_on_floor() and can_set_gra():
		velocity.y += 980.0 * (GXP_GRAVITY_SCALE - 1.0) * delta
	super._physics_process(delta)
	if boss_kind == 34:
		mr_ani.visible = not (is_attacking and _active_skill == "hit9" and not death())

	if _gxp_active or boss_kind == 192:
		super_armor_active = true


func can_set_gra():
	if boss_kind == 31 and _water_float_left > 0.0:
		return false
	if boss_kind == 31 and is_attacking and _active_skill in ["hit3", "hit4_1", "hit4_2", "hit8", "hit9"]:
		return false
	return super.can_set_gra()


func _tick_cooldowns(delta: float) -> void:
	if _skill1_cd > 0.0:
		_skill1_cd -= delta
	if _skill2_cd > 0.0:
		_skill2_cd -= delta


func _initial_cooldown(slot: int) -> float:
	if boss_kind == 192:
		return SKILL_CD[192]["skill1_initial"] if slot == 1 else SKILL_CD[192]["skill2_initial"]
	return float(SKILL_CD[boss_kind]["initial"])


func _start_skill_cooldown(slot: int, action_name: String) -> void:
	if boss_kind == 192:
		if slot == 1:
			_skill1_cd = float(SKILL_CD[192]["skill1_repeat"])
		else:
			_skill2_cd = float(SKILL_CD[192]["skill2_repeat"])
		return
	var config: Dictionary = SKILL_CD[boss_kind]
	var value := float(config["repeat"])
	if boss_kind == 31 and action_name == "hit10":
		value = float(config["teleport"])
	elif boss_kind == 34 and action_name == "hit8" and not _shadows.is_empty():
		value = float(config["special"])
	elif boss_kind == 34 and action_name == "hit14" and not _shadows.is_empty():
		value = float(config["special"])
	_skill1_cd = value


func _tick_gxp(delta: float) -> void:
	if boss_kind == 192 or death():
		return
	if _gxp_timer > 0.0:
		_gxp_timer -= delta
		if _gxp_timer <= 0.0:
			_enter_gxp()
			_gxp_timer = 20.0
	if not _gxp_active:
		return
	_gxp_afterimage_timer -= delta
	if _gxp_afterimage_timer <= 0.0:
		_gxp_afterimage_timer = 4.0 / SOURCE_FPS
		if mr_ani != null and is_instance_valid(mr_ani):
			spawn_ws_effect(monster_dir, get_parent())


func _enter_gxp() -> void:
	if boss_kind == 192 or _gxp_active or death():
		return
	_gxp_active = true
	_gxp_afterimage_timer = 0.0
	super_armor_active = true
	speed = int(round(float(speed) * 1.5))
	init_speed = speed
	get_tree().create_timer(10.0, false).timeout.connect(_exit_gxp, CONNECT_ONE_SHOT)


func _exit_gxp() -> void:
	if not _gxp_active:
		return
	_gxp_active = false
	super_armor_active = false
	speed = maxi(1, int(round(float(speed) / 1.5)))
	init_speed = speed


func _update_shadows(delta: float) -> void:
	if _shadows.is_empty():
		return
	var alive: Array = []
	for shadow in _shadows:
		if is_instance_valid(shadow) and shadow.is_inside_tree():
			alive.append(shadow)
	_shadows = alive


func _tick_skill_motion(delta: float) -> void:
	if _active_skill == "" or not is_attacking:
		return
	_skill_time += delta
	match boss_kind:
		31:
			if _active_skill == "hit4_1":
				velocity.y = -4.0 * DASH_SCALE
		34:
			if _active_skill == "hit7":
				var progress := clampf(1.0 - _skill_time * SOURCE_FPS / 15.0, 0.0, 1.0)
				velocity.x = _facing() * 25.0 * DASH_SCALE * progress
			elif _active_skill == "hit13":
				_tick_hit13()
			elif _active_skill == "hit9":
				velocity.x = _facing() * 40.0 * DASH_SCALE


func _tick_hit13() -> void:
	velocity.x = _facing() * 30.0 * DASH_SCALE
	if _hit13_resolved:
		return
	var target_position := RoleProp.get_nearest_monster_target_position(global_position)
	if absf(target_position.x - global_position.x) > 110.0:
		return
	_hit13_resolved = true
	velocity.x = 0.0
	_spawn_effect("role_1_bullet_13", target_position, _faces_right(), "hit13")

	if randf() <= 0.18:
		_spawn_shadow_near_boss()


func ai_think() -> void:
	var target_position := RoleProp.get_nearest_monster_target_position(global_position)
	var distance := absf(target_position.x - global_position.x)
	if distance < mysee:
		has_target = true
	if is_limit_buff() or cannotchangestatewhenattorbeatt() or _skill_busy:
		return
	if not has_target:
		normal_state()
		return
	if distance <= 620.0:
		if _skill1_cd <= 0.0:
			var skill := _pick_skill(1, distance)
			if skill != "":
				_use_skill(skill, 1)
				return
		if boss_kind == 192 and _skill2_cd <= 0.0:
			_use_skill("hit3", 2)
			return
	if distance <= attack_range:
		stop_move()
		if count % int(SOURCE_FPS) == 0 and randi_range(0, 100) <= attack_desire:
			attack_target()
	else:
		have_target()


func _pick_skill(slot: int, target_distance: float = -1.0) -> String:
	if boss_kind == 192:
		return "hit2" if slot == 1 else "hit3"
	if boss_kind == 31:
		var pool: Array = ["hit1", "hit4_1", "hit5", "hit7"]
		if _shadows.is_empty():
			pool.append("hit10")
			if randf() <= 0.5:
				pool.append("hit3")
				pool.append("hit9")
		else:
			pool = ["hit3", "hit9"]
		if hp <= max_hp / 2:
			pool.append("hit6")
			pool.append("hit8")
		return str(pool[randi_range(0, pool.size() - 1)])

	var monkey_pool: Array = ["hit5", "hit6", "hit7", "hit8", "hit9", "hit10", "hit12", "hit13", "hit14"]
	if not _shadows.is_empty():
		monkey_pool = ["hit8", "hit14"]
	if target_distance >= 0.0:
		monkey_pool = monkey_pool.filter(func(skill): return target_distance <= MONKEY_SKILL_REACH[skill])
	if monkey_pool.is_empty():
		return ""
	return str(monkey_pool[randi_range(0, monkey_pool.size() - 1)])


func _use_skill(action_name: String, cooldown_slot: int) -> void:
	if boss_kind == 34 and action_name in ["hit11_1", "hit11_2"]:
		return
	if _skill_busy or is_attacking:
		return

	if boss_kind == 31 and action_name == "hit10":
		to_hero()
		_skill_serial += 1
		_tang_teleport()
		_start_skill_cooldown(cooldown_slot, action_name)
		return
	if not mr_player.has_animation(action_name):
		return
	_skill_busy = true
	is_attacking = true
	velocity.x = 0.0
	to_hero()
	_skill_serial += 1
	_start_skill_cooldown(cooldown_slot, action_name)
	var current := action_name
	while current != "":
		_active_skill = current
		_skill_time = 0.0
		_hit13_resolved = false
		hit_name = current
		_on_skill_start(current)
		mr_player.play(current)
		var finished_action: StringName = await mr_player.animation_finished
		if finished_action != current:
			_chain_skill = ""
		if not is_inside_tree() or death():
			mr_ani.visible = true
			return
		current = _chain_skill
		_chain_skill = ""
	_active_skill = ""
	is_attacking = false
	_skill_busy = false
	mr_ani.visible = true
	stop_move()


func _on_skill_start(action_name: String) -> void:
	match action_name:
		"hit4_1":
			_chain_skill = "hit4_2"
		"hit11_1":
			_chain_skill = "hit11_2"
		"hit10":
			if boss_kind == 31:
				_tang_teleport()
		"hit3":
			if boss_kind == 31:
				_command_shadow("hit1")


func _execute_attack_event(event_name: String) -> void:
	if death():
		return
	hit_name = event_name
	match boss_kind:
		31:
			_execute_tang_event(event_name)
		34:
			_execute_monkey_event(event_name)
		192:
			_execute_archer_event(event_name)


func _execute_tang_event(event_name: String) -> void:
	var direction := _facing()
	match event_name:
		"hit1":
			var position := _world(Vector2(direction * 50.0, 10.0))
			var bullet := "role_2_bullet_1" if randf() <= 0.5 else "role_2_bullet_2"
			_spawn_effect(bullet, position, _faces_right(), "hit1" if bullet == "role_2_bullet_1" else "hit2")
		"hit3":
			var position := _world(Vector2(0.0, 10.0))
			_spawn_effect("role_2_bullet_3", position, _faces_right(), event_name)
		"hit4_2":
			var target := RoleProp.get_nearest_monster_target_position(global_position)
			_spawn_effect("role_2_bullet_4_2", Vector2(target.x, _ground_y(target) - 395.0), _faces_right(), "hit4")
			_water_float_left = 0.75
			velocity.y = 0.0
		"hit5":
			var position := _world(Vector2(direction * 175.0, -110.0))
			_spawn_effect("role_2_bullet_5", position, _faces_right(), event_name)
		"hit6":
			var position := _world(Vector2(0.0, -25.0))
			_spawn_visual_effect("role_2_bullet_6", position, _faces_right())
			_tang_lifesteal(position)
		"hit7":
			var position := _world(Vector2(direction * 210.0, 30.0))
			_spawn_visual_effect("role_2_bullet_7", position, _faces_right())
			_tang_pull(position, direction)
		"hit8":
			var position := _world(Vector2(-direction * 5.0, -60.0))
			_spawn_visual_effect("role_2_bullet_8", position, _faces_right())
			_command_shadow("hit3")
			_tang_heal(position)
		"hit9_1":
			var position := _world(Vector2(direction * 20.0, -20.0))
			_spawn_effect("role_2_bullet_9_1", position, _faces_right(), event_name)
			_command_shadow("hit4")
		"hit9_2":
			var position := _world(Vector2(direction * 150.0, -150.0))
			_spawn_effect("role_2_bullet_9_2", position, _faces_right(), event_name)


func _tang_lifesteal(origin: Vector2) -> void:
	var token := _skill_token()
	get_tree().create_timer(0.9, false).timeout.connect(_tang_lifesteal_resolve.bind(origin, token), CONNECT_ONE_SHOT)


func _tang_lifesteal_resolve(origin: Vector2, _token: int) -> void:
	if not is_inside_tree() or death():
		return
	if global_position.distance_to(origin) < 100.0:
		var entry: Dictionary = obj_attack_dict.get("hit6", {})
		_tang_regenerate(int(float(entry.get("power", 0)) * 0.5), 10)


func _tang_regenerate(value: int, ticks: int) -> void:
	if ticks <= 0 or not is_inside_tree() or death():
		return
	await get_tree().create_timer(1.0, false).timeout
	if not is_inside_tree() or death():
		return
	cure_hp(int(value * 1.5) if _gxp_active else value)
	_tang_regenerate(value, ticks - 1)


func _tang_heal(origin: Vector2) -> void:
	var token := _skill_token()
	get_tree().create_timer(1.2, false).timeout.connect(_tang_heal_resolve.bind(origin, token), CONNECT_ONE_SHOT)


func _tang_heal_resolve(origin: Vector2, _token: int) -> void:
	if not is_inside_tree() or death():
		return
	if global_position.distance_to(origin) <= 150.0:
		var entry: Dictionary = obj_attack_dict.get("hit8", {})
		var value := int(float(entry.get("power", 0)) * 3.0)
		if _gxp_active:
			value = int(value * 1.5)
		cure_hp(value)


func _tang_pull(origin: Vector2, direction: float) -> void:
	var player: Node2D = get_player as Node2D
	if player == null or not is_instance_valid(player):
		return
	if origin.distance_to(player.global_position) > 240.0:
		return
	var destination := _world(Vector2(direction * 200.0, -50.0))
	var tween := create_tween()
	tween.tween_property(player, "global_position", destination, 0.625)


func _tang_teleport() -> void:
	_update_shadows(0.0)
	if _shadows.is_empty():
		_spawn_shadow(to_global(Vector2(0.0, -10.0)))
	else:
		var shadow = _shadows[0]
		if is_instance_valid(shadow):
			global_position = (shadow as Node2D).global_position
			shadow.queue_free()
		_shadows.clear()


func _ground_y(target: Vector2) -> float:
	var query := PhysicsRayQueryParameters2D.create(
		Vector2(target.x, target.y - 200.0), Vector2(target.x, target.y + 1600.0), 1, [get_rid()]
	)
	var result := get_world_2d().direct_space_state.intersect_ray(query)
	return float(result.position.y) if not result.is_empty() else target.y


func _execute_monkey_event(event_name: String) -> void:
	var direction := _facing()
	match event_name:
		"hit1":
			var position := _world(Vector2(direction * 120.0, 5.0))
			_spawn_effect("role_1_bullet_1", position, _faces_right(), event_name)
		"hit3":
			var position := _world(Vector2(direction * 30.0, -110.0))
			_spawn_effect("role_1_bullet_3", position, _faces_right(), event_name)
		"hit4":
			var position := _world(Vector2(direction * 160.0, -10.0))
			_spawn_effect("role_1_bullet_4", position, _faces_right(), event_name)
		"hit5":
			var position := _world(Vector2(direction * 165.0, -20.0))
			_spawn_effect("role_1_bullet_5", position, _faces_right(), event_name)
		"hit6":
			var position := _world(Vector2(direction * 30.0, 40.0))
			_spawn_effect("role_1_bullet_6", position, _faces_right(), event_name)
		"hit7":
			var position := _world(Vector2(direction * 175.0, -30.0))
			_spawn_effect("role_1_bullet_7", position, _faces_right(), event_name, 0.0, true)
		"hit8":
			var position := _world(Vector2(-direction * 20.0, 30.0))
			_spawn_effect("role_1_bullet_8", position, _faces_right(), event_name, 0.0, true)
			_command_shadow("hit1")
		"hit9":
			var position := _world(Vector2(direction * 120.0, -50.0))
			mr_ani.visible = false
			start_spawn_damage_protection(10.0 / SOURCE_FPS)
			_spawn_effect("role_1_bullet_9", position, _faces_right(), event_name, 0.0, true)
			velocity.x = direction * 40.0 * DASH_SCALE
		"hit10_1":
			velocity.x = direction * 28.0 * DASH_SCALE
			velocity.y = -35.0 * DASH_SCALE
		"hit10_2":
			_monkey_teleport_strike()
		"hit11_1":
			velocity.x = direction * 25.0 * DASH_SCALE
			var position := _world(Vector2(direction * 50.0, -50.0))
			_spawn_effect("role_1_bullet_11_1", position, _faces_right(), event_name)
		"hit11_2":
			velocity.x = 0.0
			velocity.y = -25.0 * DASH_SCALE
			var position := _world(Vector2(0.0, -50.0))
			_spawn_effect("role_1_bullet_11_2", position, _faces_right(), event_name)
		"hit12_1":
			_monkey_hit12_mark(direction)
		"hit12_2":
			_monkey_hit12_bomb()
		"hit14_1":
			var offset := 15.0 if direction < 0.0 else -15.0
			var position := _world(Vector2(0.0, -85.0))
			position.x += offset

			_spawn_visual_effect("role_1_bullet_14_1", position, _faces_right())
			_command_shadow("hit2")
		"hit14_2":
			var position := _world(Vector2(direction * 145.0, -60.0))

			_spawn_effect("role_1_bullet_14_2", position, _faces_right(), "hit14")
		"hit13":
			pass


func _monkey_teleport_strike() -> void:
	velocity.y = 0.0
	var origin := _world(Vector2(-10.0, 0.0))
	var target_position := RoleProp.get_nearest_monster_target_position(global_position)
	if origin.distance_to(target_position) < 100.0:
		_spawn_effect("role_1_bullet_10_2", origin, _faces_right(), "hit10_2")
		var token := _skill_token()
		get_tree().create_timer(1.9, false).timeout.connect(_monkey_ground_strike.bind(token), CONNECT_ONE_SHOT)
		return
	_monkey_ground_strike(_skill_token())


func _monkey_ground_strike(token: int) -> void:
	if token != _skill_token() or not is_inside_tree() or death():
		return
	_spawn_effect("role_1_bullet_10_3", _world(Vector2(0.0, -40.0)), _faces_right(), "hit10_3")
	velocity.x = _facing() * 40.0 * DASH_SCALE
	velocity.y = 40.0 * DASH_SCALE

	var strike_token := _skill_token()
	get_tree().create_timer(0.35, false).timeout.connect(_monkey_ground_slam.bind(strike_token), CONNECT_ONE_SHOT)


func _monkey_ground_slam(token: int) -> void:
	if token != _skill_token() or not is_inside_tree() or death():
		return
	if not is_on_floor():
		get_tree().create_timer(0.1, false).timeout.connect(_monkey_ground_slam.bind(token), CONNECT_ONE_SHOT)
		return
	_spawn_effect("role_1_bullet_10_4", _world(Vector2(0.0, 40.0)), _faces_right(), "hit10_4")
	velocity.x = 0.0


func _monkey_hit12_mark(direction: float) -> void:
	var first := _world(Vector2(21.0 if direction > 0.0 else -22.0, -10.0))
	_spawn_visual_effect("role_1_bullet_12_1_1", first, _faces_right())
	var second_x := -65.0 if direction > 0.0 else -55.0
	_spawn_visual_effect("role_1_bullet_12_1_2", _world(Vector2(second_x, 0.0)), _faces_right())


func _monkey_hit12_bomb() -> void:
	var target_position := RoleProp.get_nearest_monster_target_position(global_position)
	var direction := _facing()
	if direction > 0.0 and target_position.x < global_position.x:
		return
	if direction < 0.0 and target_position.x > global_position.x:
		return
	_monkey_hit12_boom(target_position, 3)


func _monkey_hit12_boom(position: Vector2, times: int) -> void:
	if times <= 0 or not is_inside_tree() or death():
		return
	_spawn_effect("role_1_bullet_12", position, _faces_right(), "hit12")
	var token := _skill_token()
	get_tree().create_timer(2.0, false).timeout.connect(
		_monkey_hit12_boom_later.bind(position, times - 1, token), CONNECT_ONE_SHOT
	)


func _monkey_hit12_boom_later(position: Vector2, times: int, token: int) -> void:
	if not is_inside_tree() or death():
		return
	_monkey_hit12_boom(RoleProp.get_nearest_monster_target_position(global_position), times)


func _execute_archer_event(event_name: String) -> void:
	var direction := _facing()
	var facing_right := _faces_right()
	match event_name:
		"hit1":
			_spawn_effect("monster_172_bullet_1", _world(Vector2(direction * 50.0, 0.0)), facing_right, event_name)
		"hit2":
			var position := _world(Vector2(direction * 50.0, 0.0))
			for angle in [0.0, 30.0, 60.0]:
				_spawn_effect("monster_172_bullet_2", position, facing_right, event_name, angle)
		"hit3":
			var offset_y := (randf() - 0.5) * 50.0
			_spawn_effect("monster_172_bullet_3", _world(Vector2(direction * 50.0, offset_y)), facing_right, event_name)


func _spawn_shadow(world_position: Vector2) -> void:
	if not SHADOW_LIFETIME.has(boss_kind):
		return
	var shadow = SHADOW_SCRIPT.new()
	shadow.name = "LiuShaShadow"
	shadow.facing_right = _faces_right()
	get_parent().add_child(shadow)
	shadow.global_position = world_position
	shadow.setup(boss_kind, self, float(SHADOW_LIFETIME.get(boss_kind, 3.0)), _body_foot_baseline)
	_shadows.append(shadow)

	if boss_kind == 34:
		_skill1_cd = 1.5


func _spawn_shadow_near_boss() -> void:
	var offset_x := (randf() - 0.5) * 150.0
	_spawn_shadow(Vector2(global_position.x + offset_x, global_position.y))


func _command_shadow(action_name: String) -> void:
	for shadow in _shadows:
		if is_instance_valid(shadow):
			shadow.play_attack(action_name)


func spawn_shadow_attack(event_name: String, world_position: Vector2, facing_right: bool) -> void:
	if death():
		return
	match boss_kind:
		31:
			match event_name:
				"hit3":
					_spawn_effect("role_2_bullet_3", world_position, facing_right, "hit3")
				"hit6":
					_spawn_visual_effect("role_2_bullet_6", world_position, facing_right)
					_tang_lifesteal(world_position)
				"hit8":
					_spawn_visual_effect("role_2_bullet_8", world_position, facing_right)
					_tang_heal(world_position)
				"hit9_1":
					_spawn_effect("role_2_bullet_9_1", world_position, facing_right, "hit9_1")
				"hit9_2":
					_spawn_effect("role_2_bullet_9_2", world_position, facing_right, "hit9_2")
		34:
			match event_name:
				"hit8":
					_spawn_effect("role_1_bullet_8", world_position, facing_right, "hit8")
				"hit14_1":
					_spawn_visual_effect("role_1_bullet_14_1", world_position, facing_right)
				"hit14_2":
					_spawn_effect("role_1_bullet_14_2", world_position, facing_right, "hit14")


func _facing() -> float:
	return 1.0 if _faces_right() else -1.0


func _faces_right() -> bool:
	return monster_dir.scale.x < 0.0


func _world(local_offset: Vector2) -> Vector2:
	return to_global(SOURCE_ORIGIN_OFFSETS[boss_kind] + local_offset)


func _skill_token() -> int:
	return _skill_serial


func _effect_root(effect_name: String) -> String:
	if effect_name.begins_with("Role1") or effect_name.begins_with("role_1"):
		return ORIGINAL_ROLE1_EFFECT_ROOT
	if effect_name.begins_with("Role2") or effect_name.begins_with("role_2"):
		return ORIGINAL_ROLE2_EFFECT_ROOT
	return ORIGINAL_MONSTER172_EFFECT_ROOT


func _effect_sequence(effect_name: String) -> FrameSequence:
	var directory := _effect_root(effect_name).path_join(effect_name)
	return FrameSequenceStore.get_sequence(FrameSequenceStore.directory_asset_id(directory))


func _spawn_effect(
	effect_name: String,
	world_position: Vector2,
	facing_right: bool,
	hit_name_value: String,
	rotation_degrees: float = 0.0,
	follow_boss: bool = false
) -> void:
	var sequence := _effect_sequence(effect_name)
	if sequence == null:
		push_error("流沙河 Boss 特效资源缺失: " + effect_name)
		return
	var origin := _make_attack_origin(hit_name_value)
	origin.name = "LiuShaAttack_" + effect_name
	origin.top_level = not follow_boss
	origin.z_index = 6
	add_child(origin)
	origin.global_position = world_position
	var effect := StreamedPngEffect.new()
	effect.sequence = sequence
	effect.auto_free = false
	effect.flip_h = facing_right
	effect.registration_offset = _registration_offset(effect_name)
	origin.add_child(effect)
	var angle := -rotation_degrees if facing_right else rotation_degrees
	effect.rotation_degrees = angle
	_attach_hit_area(origin, effect_name, facing_right, hit_name_value, angle)
	var lifetime := maxf(0.2, float(sequence.count()) / SOURCE_FPS + 0.12)
	get_tree().create_timer(lifetime, false).timeout.connect(_free_holder.bind(weakref(origin)), CONNECT_ONE_SHOT)


func _spawn_visual_effect(effect_name: String, world_position: Vector2, facing_right: bool) -> void:
	var sequence := _effect_sequence(effect_name)
	if sequence == null:
		return
	var holder := Node2D.new()
	holder.name = "LiuShaVisual_" + effect_name
	holder.top_level = true
	holder.global_position = world_position
	holder.z_index = 5
	add_child(holder)
	var effect := StreamedPngEffect.new()
	effect.sequence = sequence
	effect.auto_free = false
	effect.flip_h = facing_right
	effect.registration_offset = _registration_offset(effect_name)
	holder.add_child(effect)
	var lifetime := maxf(0.2, float(sequence.count()) / SOURCE_FPS + 0.12)
	get_tree().create_timer(lifetime, false).timeout.connect(_free_holder.bind(weakref(holder)), CONNECT_ONE_SHOT)


func _make_attack_origin(hit_name_value: String) -> AttackOrigin:
	var origin := AttackOrigin.new()
	origin.hit_name = hit_name_value
	if obj_attack_dict.has(hit_name_value):
		origin.obj_attack_dict = {hit_name_value: obj_attack_dict[hit_name_value]}
	return origin


func _attach_hit_area(
	origin: AttackOrigin, effect_name: String, facing_right: bool, hit_name_value: String, angle_degrees: float = 0.0
) -> void:
	var info: Array = EFFECT_INFO.get(effect_name, [Vector2(160, 160), Vector2.ZERO])
	var size: Vector2 = info[0]
	var center: Vector2 = info[1]

	if (
		effect_name != "role_2_bullet_4_2"
		and not effect_name.begins_with("Monster172Bullet")
		and not effect_name.begins_with("monster_172_bullet")
	):
		size = Vector2(minf(size.x, HIT_SIZE_CAP.x), minf(size.y, HIT_SIZE_CAP.y))
	var offset := Vector2(-center.x if facing_right else center.x, center.y)
	var area := Area2D.new()
	area.name = "HitBox"
	area.collision_layer = 4
	area.collision_mask = 896
	area.monitoring = true
	area.monitorable = false
	area.position = offset.rotated(deg_to_rad(angle_degrees))
	area.rotation_degrees = angle_degrees

	var damage_box := Node2D.new()
	damage_box.name = "BaseDamageBox"
	origin.add_child(damage_box)
	damage_box.add_child(area)
	var shape_node := CollisionShape2D.new()
	shape_node.name = "HitBox"
	var shape := RectangleShape2D.new()
	shape.size = size
	shape_node.shape = shape
	area.add_child(shape_node)
	area.area_entered.connect(_on_attack_area_entered.bind(area, hit_name_value))
	get_tree().create_timer(0.001, false).timeout.connect(
		_apply_existing_overlaps.bind(area, hit_name_value), CONNECT_ONE_SHOT
	)
	if HIT_INTERVALS[boss_kind].has(hit_name_value):
		var timer := Timer.new()
		timer.wait_time = float(HIT_INTERVALS[boss_kind][hit_name_value]) / SOURCE_FPS
		area.add_child(timer)
		timer.timeout.connect(_apply_existing_overlaps.bind(area, hit_name_value))
		timer.start()


func _apply_existing_overlaps(area: Area2D, hit_name_value: String) -> void:
	if not is_instance_valid(area):
		return
	for body in area.get_overlapping_areas():
		_on_attack_area_entered(body, area, hit_name_value)


func _on_attack_area_entered(hurt_area: Area2D, attack_area: Area2D, hit_name_value: String) -> void:
	if not is_instance_valid(hurt_area) or not is_instance_valid(attack_area):
		return
	var target := hurt_area.get_parent().get_parent()
	if target == null or not target.has_method("_on_hurt_box_area_entered"):
		return
	if target == self or target is BaseMonster:
		return
	var target_id := target.get_instance_id()
	var hit_targets: Dictionary = attack_area.get_meta("hit_targets", {})
	var elapsed := Time.get_ticks_msec()
	var interval := int(HIT_INTERVALS[boss_kind].get(hit_name_value, 0))
	if (
		hit_targets.has(target_id)
		and (interval == 0 or elapsed - int(hit_targets[target_id]) < interval * 1000.0 / SOURCE_FPS)
	):
		return
	hit_targets[target_id] = elapsed
	attack_area.set_meta("hit_targets", hit_targets)
	target.call("_on_hurt_box_area_entered", attack_area)


func _free_holder(holder_ref: WeakRef) -> void:
	var holder := holder_ref.get_ref() as Node2D
	if holder != null and is_instance_valid(holder):
		for child in holder.get_children():
			if child is StreamedPngEffect:
				(child as StreamedPngEffect).clear_texture()
		holder.queue_free()


func _registration_offset(effect_name: String) -> Vector2:
	match effect_name:
		"monster_172_bullet_1", "monster_172_bullet_2", "monster_172_bullet_3":
			return Vector2(-284.6, 0.0)
		"role_1_bullet_1":
			return Vector2(57.9, 16.6)
		"role_1_bullet_3":
			return Vector2(-5.3, 87.58)
		"role_1_bullet_4":
			return Vector2(152.85, 18.12)
		"role_1_bullet_5":
			return Vector2(115.88, 29.42)
		"role_1_bullet_6":
			return Vector2(6.6, -83.0)
		"role_1_bullet_7":
			return Vector2(143.33, 53.85)
		"role_1_bullet_8":
			return Vector2(6.85, -26.65)
		"role_1_bullet_9":
			return Vector2(112.5, 61.65)
		"role_1_bullet_10_2":
			return Vector2(-36.28, -5.83)
		"role_1_bullet_10_3":
			return Vector2(-60.25, 122.53)
		"role_1_bullet_10_4":
			return Vector2(-1.53, -50.22)
		"role_1_bullet_11_1":
			return Vector2(69.1, 115.28)
		"role_1_bullet_11_2":
			return Vector2(-17.83, 59.0)
		"role_1_bullet_12":
			return Vector2(0.0, 0.0)
		"role_1_bullet_12_1_1":
			return Vector2(3.12, 5.4)
		"role_1_bullet_12_1_2":
			return Vector2(74.6, 38.9)
		"role_1_bullet_13":
			return Vector2(9.0, 0.65)
		"role_1_bullet_14_1":
			return Vector2(0.85, 0.85)
		"role_1_bullet_14_2":
			return Vector2(97.02, 62.45)
		"role_2_bullet_1":
			return Vector2(-203.98, 0.0)
		"role_2_bullet_2":
			return Vector2(-449.98, 0.0)
		"role_2_bullet_3":
			return Vector2(-4.5, 1.85)
		"role_2_bullet_4_1":
			return Vector2(81.85, 25.12)
		"role_2_bullet_4_2":
			return Vector2(31.12, 179.6)
		"role_2_bullet_5":
			return Vector2(100.0, 100.0)
		"role_2_bullet_6":
			return Vector2(-0.03, -46.38)
		"role_2_bullet_7":
			return Vector2(3.08, 10.48)
		"role_2_bullet_8":
			return Vector2(-4.5, -24.5)
		"role_2_bullet_9_1":
			return Vector2(-6.2, 11.95)
		"role_2_bullet_9_2":
			return Vector2(150.0, 150.0)
		_:
			return Vector2.ZERO
