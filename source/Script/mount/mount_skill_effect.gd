extends Node2D

## 显式操作者：按所在面板的槽位解析数据与属性，不依赖全局 1P/2P 视图交换。
var PlayerData: PlayerDataStore:
	get:
		return LocalCoop.data_for(self) as PlayerDataStore
var RoleProp: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self) as BaseRoleProperties

signal hit_landed(skill_id: String, target: BaseMonster, hit_time: float)

const MOUNT_CATALOG := preload("res://Script/mount/mount_catalog.gd")
const MOUNT_VISUAL := preload("res://Script/mount/mount_visual.gd")
const EFFECT_RUNTIME_ROOT := "res://Art/mount/runtime/effects"
const OFFICIAL_PHYSICS_SPEED_SCALE := 3.0

const ORIGINAL_EFFECTS := {
	"3106800": [{"asset": "effect4", "lifetime": 1.834, "damage": false}],
	"3108300":
	[
		{"asset": "aoyi_skill_1", "x": 400.0, "delay": 25.0 / 30.0, "lifetime": 2.667, "channel": "main"},
		{"asset": "aoyi_skill_2", "x": 400.0, "delay": 25.0 / 30.0, "lifetime": 2.667, "damage": false},
	],
	"3107700": [{"asset": "effect3_1", "origin": "target", "delay": 13.0 / 30.0, "lifetime": 1.0}],
	"3108000": [{"asset": "aoyi_skill_0", "x": -20.0, "y": -30.0, "follow": true, "lifetime": 5.5}],
	"3108100":
	[
		{
			"asset": "aoyi_skill_1",
			"origin": "viewport_left",
			"x": 500.0,
			"fixed_direction": 1.0,
			"lifetime": 2.467,
			"channel": "main",
			"absolute_z": 140
		},
		{
			"asset": "aoyi_skill_2",
			"origin": "viewport_left",
			"x": 500.0,
			"y": -50.0,
			"fixed_direction": 1.0,
			"lifetime": 2.467,
			"damage": false,
			"absolute_z": 5
		},
	],
	"3107300": [{"asset": "effect3_1", "follow": true, "delay": 1.0 / 30.0, "lifetime": 8.0}],
	"3105900":
	[
		{
			"asset": "effect1_1",
			"x": 70.0,
			"y": -45.0,
			"vx": 400.0,
			"delay": 10.0 / 30.0,
			"lifetime": 2.0,
			"stop_on_hit": true
		}
	],
	"3106100":
	[
		{
			"asset": "effect3_1",
			"y": -58.0,
			"vx": 400.0,
			"orient_to_velocity": true,
			"delay": 13.0 / 30.0,
			"lifetime": 10.0
		}
	],
	"3109200":
	[
		{
			"asset": "aoyi_skill_1",
			"origin": "viewport_center",
			"fit_viewport": true,
			"fixed_direction": 1.0,
			"delay": 14.0 / 30.0,
			"lifetime": 1.934
		}
	],
	"3109600":
	[
		{"asset": "aoyi_skill_1", "follow": true, "delay": 17.0 / 30.0, "lifetime": 10.0, "channel": "main"},
		{"asset": "aoyi_skill_2", "follow": true, "delay": 17.0 / 30.0, "lifetime": 10.0, "damage": false},
	],
	"3110800": [{"asset": "effect1_1", "x": 89.0, "y": -123.0, "delay": 20.0 / 30.0, "lifetime": 0.4}],
	"3110900": [{"asset": "effect2_2", "x": -23.0, "follow": true, "delay": 14.0 / 30.0, "lifetime": 0.4}],
	"3111200":
	[
		{"asset": "aoyi_skill_1", "follow": true, "delay": 6.0 / 30.0, "lifetime": 0.8, "channel": "main"},
		{"asset": "aoyi_skill_2", "follow": true, "delay": 6.0 / 30.0, "lifetime": 0.9, "damage": false},
	],
}

const HUIYUAN_PROJECTILE_VELOCITIES := [
	Vector2(-50, 150),
	Vector2(240, -120),
	Vector2(200, 10),
	Vector2(50, -200),
	Vector2(-240, -20),
	Vector2(-70, -200),
	Vector2(-220, 40),
	Vector2(100, 150),
	Vector2(-200, -110),
	Vector2(230, 110),
	Vector2(-210, 150),
	Vector2(150, -200),
]
const HUIYUAN_PROJECTILE_FRAMES := [27, 29, 24, 25, 28, 27, 26, 30, 27, 26, 25, 28]
const HUIYUAN_PROJECTILE_ALONE := [true, true, true, true, true, true, true, true, false, false, false, false]

const WENYU_WATER_VISIBLE_BOTTOM_INSET := 64.0

var hero: BaseHero
var skill: Dictionary = {}
var combat: Dictionary = {}
var mount_id := ""
var direction_right := true
var elapsed := 0.0
var duration := 0.8
var _buff_power_rate := 0.0
var _buff_expires_msec := 0
var _buff_applied := false
var _lightning_targets: Dictionary = {}
var _visual_lifetime := 0.0
var _damage_lifetime := 0.0
var _channel_serial := 0
var _effect_visuals: Array[Dictionary] = []
var _damage_channels: Dictionary = {}


func setup(owner_hero: BaseHero, skill_data: Dictionary, active_mount_id: String) -> void:
	hero = owner_hero
	skill = skill_data.duplicate(true)
	mount_id = active_mount_id
	direction_right = bool(hero.player_dir)
	var skill_id := str(skill.get("id", ""))
	if skill_id == "mount_normal":
		combat = MOUNT_CATALOG.get_official_normal_combat(mount_id)
	else:
		combat = MOUNT_CATALOG.get_official_combat(skill_id)
	if combat.is_empty():
		combat = {
			"first": 0.0,
			"hits": 1,
			"interval": 0.0,
			"life": 0.8,
			"power": float(skill.get("power", 2.0)),
			"add": 0.0,
			"back": int(skill.get("hurt_back", 8)),
			"up": int(skill.get("hurt_up", -5)),
			"attack": "magic",
			"body": true,
		}
	duration = maxf(0.05, float(combat.get("first", 0.0)) + float(combat.get("life", 0.8)))
	if bool(combat.get("buff", false)) or str(skill.get("kind", "")) == "buff":
		duration = 6.05


func _ready() -> void:
	z_index = 140
	if hero == null or not is_instance_valid(hero):
		queue_free()
		return
	global_position = hero.global_position + Vector2(0.0, -65.0)
	if str(MOUNT_CATALOG.official_skill(str(skill.get("id", ""))).get("myBuff", "")) != "":
		_apply_buff()
		_buff_applied = true
	elif bool(combat.get("buff", false)) or str(skill.get("kind", "")) == "buff":
		_apply_buff()
		_buff_applied = true
	elif bool(combat.get("body", false)):
		_add_body_damage_channel("body", combat)
	_spawn_original_effects()


func _process(delta: float) -> void:
	if hero == null or not is_instance_valid(hero):
		queue_free()
		return
	elapsed += delta
	if not _buff_applied and (bool(combat.get("buff", false)) or str(skill.get("kind", "")) in ["buff"]):
		if elapsed >= (10.0 / 30.0 if str(skill.get("id", "")) in ["3111100", "3111600"] else 0.0):
			_buff_applied = true
			_apply_buff()
	if str(skill.get("kind", "")) in ["dash", "leap", "burst", "aura", "buff"]:
		global_position = hero.global_position + Vector2(0.0, -65.0)
	_update_original_effects(delta)
	_process_damage_channels()
	if elapsed >= maxf(duration, maxf(_visual_lifetime, _damage_lifetime)):
		queue_free()


func _spawn_original_effects() -> void:
	var skill_id := str(skill.get("id", ""))
	match skill_id:
		"3104400":
			_spawn_nian_meteors()
		"3105100":
			_spawn_qinglong_falling_ice()
		"3105200":
			_spawn_qinglong_ice_shots()
		"3105400":
			_spawn_qinglong_frost_rain()
		"3106700":
			_spawn_tiger_claws()
		"3107200":
			_spawn_wenyu_burst()
		"3107100":
			_spawn_wenyu_water_beam()
		"3107300":
			_spawn_wenyu_dash_visual()
		"3107400":
			_spawn_wenyu_star_rain()
		"3107800":
			_spawn_deer_snow_shots()
		"3109100":
			_spawn_huiyuan_projectiles()
		"3111000", "3111500":
			_spawn_chaofeng_orbiters()
		"3003800", "3111300", "3111400", "3111700":
			_spawn_official_parameter_effects()
		_:
			var specs_value: Variant = ORIGINAL_EFFECTS.get(skill_id, [])
			var specs: Array = specs_value if specs_value is Array else []
			for spec_value in specs:
				if spec_value is Dictionary:
					_spawn_effect_visual(spec_value)
	if (
		skill_id == "mount_normal"
		and mount_id == "1004700"
		and Time.get_ticks_msec() < int(hero.get_meta("mount_claw_lightning_until", 0))
	):
		_spawn_effect_visual(
			{
				"asset": "attack1_4",
				"follow": true,
				"delay": 9.0 / 30.0,
				"lifetime": 0.6,
				"damage_config": MOUNT_CATALOG.get_official_combat("3111101"),
				"channel": "claw_lightning",
			}
		)


func _spawn_official_parameter_effects() -> void:
	var raw: Dictionary = MOUNT_CATALOG.official_skill(str(skill.get("id", "")))
	var params: Variant = JSON.parse_string(str(raw.get("param", "")))
	if not params is Array:
		return
	for param_value in params:
		if not (param_value is Dictionary):
			continue
		var param: Dictionary = param_value
		if not param.has("assetLink"):
			continue
		var spec := {
			"asset": str(param.assetLink[0]),
			"x": float(param.get("x", 0)),
			"y": float(param.get("y", 0)),
			"delay": float(param.get("shootFrame", 0)) / 30.0,
			"lifetime": float(param.get("shootTime", 1000)) / 1000.0,
			"vx": float(param.get("shootSpeedX", 0)),
			"vy": float(param.get("shootSpeedY", 0)),
			"follow": str(param.get("type", "")) == "bulletFollwSelf",
			"absolute_z": int(param.get("layerIndex", 110)),
			"damage": str(skill.get("id", "")) != "3111700",
		}
		if str(skill.get("id", "")) == "3003800":
			spec["stop_on_hit"] = true
			spec["aim_on_release"] = true
			spec["vx"] = float(param.get("shootSpeedX", 0)) * 3.0
			spec["vy"] = float(param.get("shootSpeedY", 0)) * 3.0
			spec["loop_visual"] = true
		if str(skill.get("id", "")) in ["3111300", "3111400"]:
			spec["loop_visual"] = true
			spec["release_origin"] = true
			spec["precise_motion"] = true
			spec["alone"] = bool(int(param.get("alone", 0)))
		if str(skill.get("id", "")) == "3111300":
			spec["scale_vertical_bullet"] = bool(int(param.get("scaleVerticalBullet", 0)))
			spec["vx"] = float(param.get("shootSpeedX", 0)) * OFFICIAL_PHYSICS_SPEED_SCALE
			spec["vy"] = (float(skill.get("vertical_axis", 0.0)) * 200.0 * OFFICIAL_PHYSICS_SPEED_SCALE)
		if int(param.get("arrow", raw.get("arrow", 0))) == 1:
			spec["orient_to_velocity"] = true
		_spawn_effect_visual(spec)


func _spawn_wenyu_water_beam() -> void:
	var ground := _mount_origin()
	var target := _nearest_effect_target()
	var center_x := target.global_position.x if target != null else ground.x + (360.0 if direction_right else -360.0)
	for pillar_offset in [-190.0, 0.0, 190.0]:
		_spawn_effect_visual(
			{
				"asset": "effect1_1",
				"position": Vector2(center_x + pillar_offset, ground.y),
				"rotation": -PI / 2.0,
				"delay": 22.0 / 30.0,
				"lifetime": 1.1,
				"channel": "main",
				"collision_padding": 80.0,
				"align_bottom_y": ground.y + WENYU_WATER_VISIBLE_BOTTOM_INSET,
				"fixed_direction": 1.0,
			}
		)


func _spawn_wenyu_dash_visual() -> void:
	_spawn_effect_visual(
		{
			"asset": "res2",
			"runtime_root": "res://Art/mount/runtime/mounts",
			"follow": true,
			"delay": 1.0 / 30.0,
			"lifetime": 8.0,
			"damage": false,
			"direction_override": 1.0 if direction_right else -1.0,
		}
	)


func _spawn_tiger_claws() -> void:
	for index in range(4):
		var delay := 0.231 + 0.8 * float(index)
		var target := _nearest_effect_target()
		var landing := _mount_origin() + Vector2(200.0 if direction_right else -200.0, 0.0)
		if target != null:
			landing = _target_foot(target)
		var start := landing + Vector2(0.0, -590.0)
		var velocity := Vector2(0.0, 450.0 * OFFICIAL_PHYSICS_SPEED_SCALE)
		_spawn_effect_visual(
			{
				"asset": "effect3_1",
				"position": start,
				"world_velocity": velocity,
				"delay": delay,
				"lifetime": 0.434,
				"alone": true,
				"collision_padding": 300.0,
			}
		)
		_spawn_effect_visual(
			{
				"asset": "effect3_2",
				"position": landing,
				"delay": delay + 0.434,
				"lifetime": 0.567,
				"damage": false,
			}
		)


func _spawn_nian_meteors() -> void:
	for index in range(7):
		var target := _nearest_effect_target()
		var view_top_left := _screen_to_world(Vector2.ZERO)
		var start := Vector2(view_top_left.x + randf_range(0.0, 1000.0), hero.global_position.y - 590.0)
		var aim := (
			_target_center(target)
			if target != null
			else hero.global_position + Vector2(300.0 if direction_right else -300.0, 0.0)
		)
		_spawn_effect_visual(
			{
				"asset": "effect3_1",
				"position": start,
				"world_velocity": _velocity_toward(start, aim, 300.0),
				"orient_to_velocity": true,
				"delay": 0.5 * float(index + 1),
				"lifetime": 1.5,
				"alone": true,
				"collision_padding": 200.0,
			}
		)


func _spawn_deer_snow_shots() -> void:
	for index in range(5):
		var delay := float(16 + index * 10) / 30.0
		var facing := 1.0 if direction_right else -1.0
		var start := hero.global_position + Vector2(133.0 * facing, -286.0)
		var target := _nearest_effect_target()
		var aim := _target_center(target) if target != null else start + Vector2(600.0 * facing, 100.0)
		_spawn_effect_visual(
			{
				"asset": "effect4_1",
				"position": start,
				"world_velocity": _velocity_toward(start, aim, 200.0),
				"orient_to_velocity": true,
				"delay": delay,
				"lifetime": 8.0,
				"alone": true,
				"stop_on_hit": true,
				"impact_asset": "effect4_2",
				"impact_lifetime": 0.5,
			}
		)


func _spawn_qinglong_falling_ice() -> void:
	var target := _nearest_effect_target()
	var target_center := _target_center(target) if target != null else hero.global_position + Vector2(200.0, 0.0)
	var start := Vector2(target_center.x, _screen_to_world(Vector2(0.0, -100.0)).y)
	_spawn_effect_visual(
		{
			"asset": "effect1_1",
			"position": start,
			"world_velocity": Vector2(0.0, 400.0),
			"orient_to_velocity": true,
			"delay": 16.0 / 30.0,
			"lifetime": 2.0,
			"channel": "main",
			"stop_on_hit": true,
			"impact_asset": "effect1_2",
			"impact_lifetime": 0.667,
		}
	)


func _spawn_qinglong_ice_shots() -> void:
	var delays := [25.0 / 30.0, 26.0 / 30.0, 26.0 / 30.0]
	var y_speeds := [0.0, -50.0, 50.0]
	for index in range(3):
		_spawn_effect_visual(
			{
				"asset": "effect2_1",
				"x": 381.0,
				"y": -54.0,
				"vx": 200.0,
				"vy": y_speeds[index],
				"orient_to_velocity": true,
				"delay": delays[index],
				"lifetime": 0.6,
				"alone": true,
				"stop_on_hit": true
			}
		)


func _spawn_qinglong_frost_rain() -> void:
	_spawn_random_falling_wave("effect4_1", "effect4_2")


func _spawn_wenyu_star_rain() -> void:
	_spawn_random_falling_wave("effect4_2", "effect4_3", true)


func _spawn_random_falling_wave(projectile_asset: String, impact_asset: String, collide_world := false) -> void:
	var facing := 1.0 if direction_right else -1.0
	for wave in range(10):
		var delay := 0.66 + 0.33 * float(wave)
		var view_top_left := _screen_to_world(Vector2.ZERO)
		for _projectile in range(3):
			var start := Vector2(
				view_top_left.x + randf_range(-200.0, 800.0) + (0.0 if direction_right else 310.0),
				view_top_left.y + randf_range(-120.0, 0.0)
			)
			var projectile_spec := {
				"asset": projectile_asset,
				"position": start,
				"world_velocity": Vector2(200.0 * facing, 400.0),
				"orient_to_velocity": true,
				"delay": delay,
				"lifetime": 10.0,
				"channel": "main",
				"stop_on_hit": true,
				"impact_asset": impact_asset,
				"impact_lifetime": 0.5,
			}
			if collide_world:
				projectile_spec["collide_world"] = true
				projectile_spec["world_collision_mask"] = 33
			_spawn_effect_visual(projectile_spec)


func _spawn_wenyu_burst() -> void:
	_spawn_effect_visual(
		{
			"asset": "effect2_1",
			"x": 156.0,
			"y": -66.0,
			"vx": 300.0,
			"delay": 27.0 / 30.0,
			"lifetime": 1.5,
			"alone": true,
			"stop_on_hit": true,
			"impact_asset": "effect2_2",
			"impact_lifetime": 0.5,
			"finish_delay": 0.1,
			"impact_share_channel": false,
			"collision_padding": 80.0,
			"impact_damage": true,
			"impact_wenyu_transition": true,
		}
	)


func _spawn_huiyuan_projectiles() -> void:
	_spawn_effect_visual({"asset": "aoyi_skill_1", "delay": 8.0 / 30.0, "lifetime": 1.167, "channel": "main"})
	_spawn_effect_visual({"asset": "effect5", "delay": 8.0 / 30.0, "lifetime": 0.534, "damage": false})
	_spawn_effect_visual({"asset": "effect5_1", "delay": 0.8, "lifetime": 0.634, "damage": false})
	for index in range(HUIYUAN_PROJECTILE_VELOCITIES.size()):
		var velocity: Vector2 = HUIYUAN_PROJECTILE_VELOCITIES[index]
		_spawn_effect_visual(
			{
				"asset": "effect1_1",
				"x": 95.0,
				"y": -140.0,
				"vx": velocity.x,
				"vy": velocity.y,
				"orient_to_velocity": true,
				"delay": float(HUIYUAN_PROJECTILE_FRAMES[index]) / 30.0,
				"lifetime": 1.3,
				"alone": HUIYUAN_PROJECTILE_ALONE[index],
				"channel": "" if HUIYUAN_PROJECTILE_ALONE[index] else "main",
			}
		)


func _spawn_chaofeng_orbiters() -> void:
	var flying := mount_id == "1004800"
	for index in range(3):
		_spawn_effect_visual(
			{
				"asset": "effect3_1",
				"delay": 14.0 / 30.0,
				"lifetime": 4.0,
				"orbit": true,
				"orbit_angle": float(index) * 120.0,
				"orbit_follow": not flying,
				"origin": "target" if flying else "self",
				"orbit_radius_x": 150.0 if flying else 215.0,
				"orbit_radius_y": 42.0 if flying else 50.0,
				"orbit_period": 1.9 if flying else 1.7,
				"alone": true,
				"orbit_depth": true,
			}
		)


func _spawn_effect_visual(spec: Dictionary) -> void:
	var asset := str(spec.get("asset", ""))
	if asset == "":
		return
	var visual := MOUNT_VISUAL.new() as MountVisual
	add_child(visual)
	var visual_mount_id := "1003100" if mount_id == "1002200" else mount_id
	var visual_root := str(spec.get("runtime_root", EFFECT_RUNTIME_ROOT))
	if not visual.setup(visual_mount_id, asset, visual_root, true):
		visual.queue_free()
		return
	visual.force_loop = bool(spec.get("loop_visual", false))
	var target: BaseMonster = spec.get("target") as BaseMonster
	if target == null or not is_instance_valid(target):
		target = _nearest_effect_target()
	var origin := hero.global_position
	var origin_mode := str(spec.get("origin", "self"))
	if spec.has("position"):
		origin = spec.get("position", hero.global_position)
	elif origin_mode == "target" and target != null:
		origin = target.global_position
	elif origin_mode == "viewport_left":
		origin = Vector2(_screen_to_world(Vector2.ZERO).x, hero.global_position.y)
	elif origin_mode == "viewport_center":
		origin = _screen_to_world(get_viewport().get_visible_rect().size * 0.5)
	var facing := float(spec.get("direction_override", spec.get("fixed_direction", 1.0 if direction_right else -1.0)))
	var offset := Vector2(float(spec.get("x", 0.0)) * facing, float(spec.get("y", 0.0)))
	visual.global_position = origin + offset
	var velocity: Vector2 = spec.get(
		"world_velocity", Vector2(float(spec.get("vx", 0.0)) * facing, float(spec.get("vy", 0.0)))
	)
	var orient_to_velocity := bool(spec.get("orient_to_velocity", false)) and not velocity.is_zero_approx()
	visual.scale.x = 1.0 if orient_to_velocity else facing
	if bool(spec.get("scale_vertical_bullet", false)) and facing < 0.0:
		visual.scale.y = -1.0
	if bool(spec.get("fit_viewport", false)):
		var viewport_size := get_viewport().get_visible_rect().size
		var viewport_world_top_left := _screen_to_world(Vector2.ZERO)
		var viewport_world_bottom_right := _screen_to_world(viewport_size)
		var viewport_world_size := viewport_world_bottom_right - viewport_world_top_left
		visual.scale = Vector2(absf(viewport_world_size.x) / 940.0, absf(viewport_world_size.y) / 590.0)
	if orient_to_velocity:
		visual.rotation = velocity.angle()
	elif spec.has("rotation"):
		visual.rotation = float(spec.get("rotation", 0.0))
	var align_bottom_value: Variant = spec.get("align_bottom_y", null)
	if align_bottom_value != null:
		visual.process_priority = process_priority - 1
		_align_visual_bottom(visual, float(align_bottom_value))
	if spec.has("absolute_z"):
		visual.z_as_relative = false
		visual.z_index = int(spec.get("absolute_z", 0))
	var delay := maxf(0.0, float(spec.get("delay", combat.get("first", 0.0))))
	var lifetime := maxf(0.05, float(spec.get("lifetime", combat.get("life", 1.0))))
	var state := {
		"node": visual,
		"asset": asset,
		"runtime_root": visual_root,
		"velocity": velocity,
		"orient_to_velocity": orient_to_velocity,
		"offset": offset,
		"follow": bool(spec.get("follow", false)),
		"delay": delay,
		"lifetime": lifetime,
		"age": 0.0,
		"spawn_time": elapsed,
		"active": delay <= 0.0,
		"orbit": bool(spec.get("orbit", false)),
		"orbit_angle": float(spec.get("orbit_angle", 0.0)),
		"orbit_radius_x": float(spec.get("orbit_radius_x", 0.0)),
		"orbit_radius_y": float(spec.get("orbit_radius_y", 0.0)),
		"orbit_period": maxf(0.01, float(spec.get("orbit_period", 1.0))),
		"stop_on_hit": bool(spec.get("stop_on_hit", false)),
		"alone": bool(spec.get("alone", false)),
		"finish_delay": maxf(0.0, float(spec.get("finish_delay", 0.0))),
		"finish_requested": false,
		"finish_at": INF,
		"impact_asset": str(spec.get("impact_asset", "")),
		"impact_lifetime": float(spec.get("impact_lifetime", 0.5)),
		"impact_damage": bool(spec.get("impact_damage", true)),
		"impact_share_channel": bool(spec.get("impact_share_channel", true)),
		"impact_wenyu_transition": bool(spec.get("impact_wenyu_transition", false)),
		"impact_spawned": false,
		"sweep_hit_target": 0,
		"wenyu_transition": bool(spec.get("wenyu_transition", false)),
		"wenyu_transition_spawned": false,
		"wenyu_orbiters": bool(spec.get("wenyu_orbiters", false)),
		"orbiters_spawned": false,
		"collide_world": bool(spec.get("collide_world", false)),
		"world_collision_mask": int(spec.get("world_collision_mask", 0)),
		"collision_padding": float(spec.get("collision_padding", 42.0)),
		"align_bottom_y": align_bottom_value,
		"orbit_center": origin + offset,
		"orbit_follow": bool(spec.get("orbit_follow", false)),
		"seek_target": spec.get("seek_target"),
		"seek_step": 0,
		"aim_on_release": bool(spec.get("aim_on_release", false)),
		"release_origin": bool(spec.get("release_origin", false)),
		"precise_motion": bool(spec.get("precise_motion", false)),
		"orbit_depth": bool(spec.get("orbit_depth", false)),
	}
	visual.visible = delay <= 0.0
	visual.set_process(delay <= 0.0)

	_visual_lifetime = maxf(_visual_lifetime, elapsed + delay + lifetime)
	_effect_visuals.append(state)
	if bool(spec.get("damage", true)):
		var damage_config: Dictionary = spec.get("damage_config", combat)
		var channel_name := str(spec.get("channel", ""))
		var alone := bool(spec.get("alone", damage_config.get("alone", false)))
		if channel_name == "":
			channel_name = _next_channel_name() if alone else "main"
		state["channel"] = channel_name
		_add_visual_damage_channel(channel_name, state, damage_config)


func _next_channel_name() -> String:
	_channel_serial += 1
	return "projectile_%d" % _channel_serial


func _add_visual_damage_channel(channel_name: String, state: Dictionary, damage_config: Dictionary) -> void:
	var delay := float(state.get("spawn_time", 0.0)) + float(state.get("delay", 0.0))
	var end_time := delay + float(state.get("lifetime", 0.0))
	if _damage_channels.has(channel_name):
		var existing: Dictionary = _damage_channels[channel_name]
		(existing["visuals"] as Array).append(state)
		existing["start"] = minf(float(existing.get("start", delay)), delay)
		existing["end"] = maxf(float(existing.get("end", end_time)), end_time)
	else:
		_damage_channels[channel_name] = {
			"mode": "visual",
			"visuals": [state],
			"config": damage_config.duplicate(true),
			"start": delay,
			"end": end_time,
			"target_hits": {},
			"target_next": {},
		}
	_damage_lifetime = maxf(_damage_lifetime, end_time)


func _add_body_damage_channel(channel_name: String, damage_config: Dictionary) -> void:
	var start := maxf(0.0, float(damage_config.get("first", 0.0)))
	var end_time := start + maxf(0.05, float(damage_config.get("life", 0.5)))
	_damage_channels[channel_name] = {
		"mode": "body",
		"visuals": [],
		"config": damage_config.duplicate(true),
		"start": start,
		"end": end_time,
		"target_hits": {},
		"target_next": {},
	}
	_damage_lifetime = maxf(_damage_lifetime, end_time)


func _nearest_effect_target() -> BaseMonster:
	var nearest: BaseMonster = null
	var nearest_distance := INF
	for target_value in _collect_targets():
		if not _is_valid_target(target_value):
			continue
		var target := target_value as BaseMonster
		var distance := hero.global_position.distance_squared_to(target.global_position)
		if distance < nearest_distance:
			nearest = target
			nearest_distance = distance
	return nearest


func _screen_to_world(screen_position: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * screen_position


func _velocity_toward(start: Vector2, destination: Vector2, speed: float) -> Vector2:
	var offset := destination - start
	return offset.normalized() * speed if offset.length_squared() > 0.0001 else Vector2.ZERO


func _update_original_effects(delta: float) -> void:
	var visual_count := _effect_visuals.size()
	for visual_index in range(visual_count):
		var visual_state: Dictionary = _effect_visuals[visual_index]
		var visual: MountVisual = visual_state.get("node") as MountVisual
		if visual == null or not is_instance_valid(visual):
			continue
		var previous_age := float(visual_state.get("age", 0.0))
		visual_state["age"] = previous_age + delta
		var age := float(visual_state["age"])
		var delay := float(visual_state.get("delay", 0.0))
		var lifetime := float(visual_state.get("lifetime", 1.0))
		if bool(visual_state.get("finish_requested", false)):
			if age + 0.0001 >= float(visual_state.get("finish_at", INF)):
				_complete_projectile_finish(visual_state)
			else:
				visual.visible = true
				visual.set_process(true)
			continue
		if not bool(visual_state.get("active", false)) and age >= delay:
			visual_state["active"] = true
			visual.visible = true
			visual.play(str(visual_state.get("asset", "")), true)
			visual.set_process(true)
			if bool(visual_state.get("release_origin", false)) or bool(visual_state.get("aim_on_release", false)):
				visual.global_position = hero.global_position + (visual_state.get("offset", Vector2.ZERO) as Vector2)
			if bool(visual_state.get("aim_on_release", false)):
				var aim_target := _nearest_effect_target()
				if aim_target != null:
					var old_velocity: Vector2 = visual_state.get("velocity", Vector2.ZERO)
					visual_state["velocity"] = _velocity_toward(
						visual.global_position, _target_center(aim_target), old_velocity.length()
					)
					if (
						bool(visual_state.get("orient_to_velocity", false))
						and not (visual_state["velocity"] as Vector2).is_zero_approx()
					):
						visual.rotation = (visual_state["velocity"] as Vector2).angle()
		var precise_motion := (
			bool(visual_state.get("aim_on_release", false)) or bool(visual_state.get("precise_motion", false))
		)
		var motion_delta := (
			maxf(0.0, minf(age, delay + lifetime) - maxf(previous_age, delay)) if precise_motion else delta
		)
		if precise_motion and age >= delay + lifetime and motion_delta > 0.0:
			visual.global_position += (visual_state.get("velocity", Vector2.ZERO) as Vector2) * motion_delta
		visual.visible = age >= delay and age < delay + lifetime
		if not visual.visible:
			if age >= delay + lifetime:
				if (
					str(visual_state.get("impact_asset", "")) != ""
					and not bool(visual_state.get("impact_spawned", false))
				):
					_finish_projectile_on_hit(visual_state)
				if (
					bool(visual_state.get("wenyu_orbiters", false))
					and not bool(visual_state.get("orbiters_spawned", false))
				):
					visual_state["orbiters_spawned"] = true
					_spawn_wenyu_orbiters(visual.global_position)
				visual.set_process(false)
			continue
		var active_age := age - delay
		var seek_target: Variant = visual_state.get("seek_target")
		var seek_step := mini(8, int(active_age / 0.776))
		if is_instance_valid(seek_target) and seek_step > int(visual_state.get("seek_step", 0)):
			visual_state["seek_step"] = seek_step
			visual.global_position = _target_center(seek_target)
		if (
			bool(visual_state.get("wenyu_transition", false))
			and not bool(visual_state.get("wenyu_transition_spawned", false))
			and active_age + 0.0001 >= 7.0 / 30.0
		):
			visual_state["wenyu_transition_spawned"] = true
			_spawn_effect_visual(
				{
					"asset": "mc_effect2_3",
					"position": visual.global_position,
					"lifetime": 16.0 / 30.0,
					"damage": false,
					"wenyu_orbiters": true,
				}
			)
		if bool(visual_state.get("orbit", false)):
			var angle := deg_to_rad(
				(
					float(visual_state.get("orbit_angle", 0.0))
					+ active_age / float(visual_state.get("orbit_period", 1.0)) * 360.0
				)
			)
			var orbit_center: Vector2 = visual_state.get("orbit_center", hero.global_position)
			if bool(visual_state.get("orbit_follow", false)):
				orbit_center = hero.global_position
			visual.global_position = (
				orbit_center
				+ Vector2(
					cos(angle) * float(visual_state.get("orbit_radius_x", 0.0)),
					sin(angle) * float(visual_state.get("orbit_radius_y", 0.0))
				)
			)
			if bool(visual_state.get("orbit_depth", false)):
				visual.z_as_relative = false
				visual.z_index = 9 if sin(angle) < 0.0 else 111
		elif bool(visual_state.get("follow", false)):
			var follow_offset: Vector2 = visual_state.get("offset", Vector2.ZERO)
			visual.global_position = hero.global_position + follow_offset
		else:
			var velocity: Vector2 = visual_state.get("velocity", Vector2.ZERO)
			var previous_position := visual.global_position
			visual.global_position += velocity * motion_delta
			if bool(visual_state.get("stop_on_hit", false)) and not velocity.is_zero_approx():
				var segment := visual.global_position - previous_position
				var segment_length_sq := segment.length_squared()
				if segment_length_sq > 0.0001:
					for target_value in _collect_targets():
						if not _is_valid_target(target_value):
							continue
						var target := target_value as BaseMonster
						var target_position := _target_center(target)
						var segment_t := clampf(
							(target_position - previous_position).dot(segment) / segment_length_sq, 0.0, 1.0
						)
						var closest := previous_position + segment * segment_t
						if closest.distance_to(target_position) <= float(visual_state.get("collision_padding", 42.0)):
							visual_state["sweep_hit_target"] = target.get_instance_id()
							break
			if bool(visual_state.get("collide_world", false)) and not velocity.is_zero_approx():
				var query := PhysicsRayQueryParameters2D.create(
					previous_position, visual.global_position, int(visual_state.get("world_collision_mask", 0))
				)
				query.exclude = [hero.get_rid()]
				var collision := get_world_2d().direct_space_state.intersect_ray(query)
				if not collision.is_empty() and not (collision.get("collider") is BaseMonster):
					visual.global_position = collision.get("position", visual.global_position)
					_finish_projectile_on_hit(visual_state)
		var align_bottom_value: Variant = visual_state.get("align_bottom_y", null)
		if align_bottom_value != null:
			_align_visual_bottom(visual, float(align_bottom_value))


func _process_damage_channels() -> void:
	var targets := _collect_targets()
	for channel_value in _damage_channels.values():
		if not (channel_value is Dictionary):
			continue
		var channel: Dictionary = channel_value
		if elapsed + 0.0001 < float(channel.get("start", 0.0)) or elapsed >= float(channel.get("end", 0.0)):
			continue
		var damage_config: Dictionary = channel.get("config", {})
		var max_hits := maxi(0, int(damage_config.get("hits", 1)))
		if max_hits == 0:
			continue
		var interval := maxf(0.0, float(damage_config.get("interval", 0.0)))
		var target_hits: Dictionary = channel.get("target_hits", {})
		var target_next: Dictionary = channel.get("target_next", {})
		for target_value in targets:
			if not _is_valid_target(target_value):
				continue
			var target := target_value as BaseMonster
			var collision_state := _channel_collision_state(channel, target)
			if collision_state.is_empty():
				continue
			var target_id := target.get_instance_id()
			var hit_count := int(target_hits.get(target_id, 0))
			if hit_count >= max_hits or elapsed + 0.0001 < float(target_next.get(target_id, 0.0)):
				continue
			_apply_hit(target, damage_config)
			target_hits[target_id] = hit_count + 1
			target_next[target_id] = elapsed + interval if interval > 0.0 else INF
			if bool(collision_state.get("stop_on_hit", false)):
				_finish_projectile_on_hit(collision_state)


func _channel_collision_state(channel: Dictionary, target: BaseMonster) -> Dictionary:
	if str(channel.get("mode", "body")) == "body":
		return {"body": true} if _target_inside_effect(target) else {}
	var visuals_value: Variant = channel.get("visuals", [])
	if not (visuals_value is Array):
		return {}
	for state_value in visuals_value:
		if not (state_value is Dictionary):
			continue
		var state: Dictionary = state_value
		var visual: MountVisual = state.get("node") as MountVisual
		if visual == null or not is_instance_valid(visual) or not visual.visible:
			continue
		if int(state.get("sweep_hit_target", 0)) == target.get_instance_id():
			return state
		var bounds := visual.get_current_visual_bounds()
		if bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
			continue
		if bounds.grow(float(state.get("collision_padding", 42.0))).has_point(visual.to_local(_target_center(target))):
			return state
	return {}


func _finish_projectile_on_hit(state: Dictionary) -> void:
	var visual: MountVisual = state.get("node") as MountVisual
	if visual == null or not is_instance_valid(visual):
		return
	if bool(state.get("finish_requested", false)) or bool(state.get("impact_spawned", false)):
		return
	var finish_delay := float(state.get("finish_delay", 0.0))
	if finish_delay > 0.0:
		state["finish_requested"] = true
		state["finish_at"] = float(state.get("age", 0.0)) + finish_delay
		state["velocity"] = Vector2.ZERO
		state["stop_on_hit"] = false
		visual.visible = true
		visual.set_process(true)
		return
	_complete_projectile_finish(state)


func _complete_projectile_finish(state: Dictionary) -> void:
	var visual: MountVisual = state.get("node") as MountVisual
	if visual == null or not is_instance_valid(visual):
		return
	state["finish_requested"] = false
	if not bool(state.get("impact_spawned", false)):
		state["impact_spawned"] = true
		var impact_asset := str(state.get("impact_asset", ""))
		if impact_asset != "":
			var impact_spec := {
				"asset": impact_asset,
				"position": visual.global_position,
				"delay": 0.0,
				"lifetime": float(state.get("impact_lifetime", 0.5)),
				"damage": bool(state.get("impact_damage", true)),
				"wenyu_transition": bool(state.get("impact_wenyu_transition", false)),
			}
			if bool(state.get("impact_share_channel", true)):
				impact_spec["channel"] = str(state.get("channel", "main"))
			else:
				impact_spec["alone"] = true
			_spawn_effect_visual(impact_spec)
	visual.visible = false
	visual.set_process(false)
	state["active"] = true
	state["lifetime"] = maxf(0.0, float(state.get("age", 0.0)) - float(state.get("delay", 0.0)))
	state["finished_at_elapsed"] = elapsed


func _spawn_wenyu_orbiters(center: Vector2) -> void:
	var orbiter_combat := combat.duplicate(true)
	orbiter_combat["hits"] = 3
	orbiter_combat["interval"] = 0.267
	orbiter_combat["life"] = 2.0
	orbiter_combat["alone"] = true
	for index in range(4):
		_spawn_effect_visual(
			{
				"asset": "effect2_3",
				"position": center,
				"delay": 0.0,
				"lifetime": 2.0,
				"orbit": true,
				"orbit_angle": float(index) * 90.0,
				"orbit_radius_x": 100.0,
				"orbit_radius_y": 100.0,
				"orbit_period": 1.2,
				"alone": true,
				"damage_config": orbiter_combat,
			}
		)


func _target_center(target: BaseMonster) -> Vector2:
	var collision := target.get_node_or_null("pz") as CollisionShape2D
	return collision.global_position if collision != null else target.global_position


func _target_foot(target: BaseMonster) -> Vector2:
	var collision := target.get_node_or_null("pz") as CollisionShape2D
	if collision == null or collision.shape == null:
		return target.global_position
	return _collision_bottom_global(target, collision)


func _mount_origin() -> Vector2:
	var collision := hero.get_node_or_null("pz") as CollisionShape2D
	if collision == null or collision.shape == null:
		return hero.global_position
	return _collision_bottom_global(hero, collision, true)


func _align_visual_bottom(visual: MountVisual, target_bottom_y: float) -> void:
	var bounds := visual.get_current_visual_bounds()
	if bounds.size.x <= 0.0 or bounds.size.y <= 0.0:
		return
	var current_bottom_y := _visual_bottom_y(visual, bounds)
	visual.global_position += Vector2(0.0, target_bottom_y - current_bottom_y)


func _visual_bottom_y(visual: Node2D, bounds: Rect2) -> float:
	var bottom_y := -INF
	for corner in [
		bounds.position,
		Vector2(bounds.end.x, bounds.position.y),
		bounds.end,
		Vector2(bounds.position.x, bounds.end.y),
	]:
		bottom_y = maxf(bottom_y, (visual.global_transform * corner).y)
	return bottom_y


func _collision_bottom_global(owner: Node2D, collision: CollisionShape2D, center_on_owner := false) -> Vector2:
	var half_extents := Vector2.ZERO
	if collision.shape is CapsuleShape2D:
		var capsule := collision.shape as CapsuleShape2D
		half_extents = Vector2(capsule.radius, capsule.height * 0.5)
	elif collision.shape is RectangleShape2D:
		half_extents = (collision.shape as RectangleShape2D).size * 0.5
	elif collision.shape is CircleShape2D:
		var radius := (collision.shape as CircleShape2D).radius
		half_extents = Vector2(radius, radius)
	else:
		return collision.global_position
	var collision_in_owner := owner.global_transform.affine_inverse() * collision.global_transform
	var transformed_half_height := (
		absf(collision_in_owner.x.y) * half_extents.x + absf(collision_in_owner.y.y) * half_extents.y
	)
	var local_x := 0.0 if center_on_owner else collision_in_owner.origin.x
	return owner.to_global(Vector2(local_x, collision_in_owner.origin.y + transformed_half_height))


func _collect_targets() -> Array:
	var level := _find_level_node()
	if level != null and level.has_method("has_active_monster_index") and level.has_active_monster_index():
		return level.get_active_monsters()
	return get_tree().get_nodes_in_group("monsters")


func _find_level_node() -> Node:
	var node: Node = hero
	while node != null:
		if node is BaseLevel:
			return node
		node = node.get_parent()
	return get_tree().current_scene


func _is_valid_target(target: Variant) -> bool:
	if target == null or not is_instance_valid(target) or not (target is BaseMonster):
		return false
	if target.hp <= 0 or target.no_target or target.is_boss_protecting():
		return false
	if target.get_meta("pet_tiger_unit", false) or target.get_meta("is_summon", false):
		return false
	return true


func _target_inside_effect(target: BaseMonster) -> bool:
	var offset := _target_center(target) - hero.global_position
	var direction := 1.0 if direction_right else -1.0
	var forward := offset.x * direction
	match str(skill.get("kind", "wave")):
		"dash", "leap", "claw":
			return forward >= -40.0 and forward <= 280.0 and absf(offset.y) <= 180.0
		"projectile", "wave":
			return forward >= -20.0 and forward <= 560.0 and absf(offset.y) <= 210.0
		"burst", "aura":
			return offset.length() <= 340.0
		"rain":
			return absf(offset.x) <= 480.0 and absf(offset.y) <= 330.0
		"ultimate":
			return absf(offset.x) <= 720.0 and absf(offset.y) <= 450.0
	return false


func _apply_hit(target: BaseMonster, hit_combat: Dictionary = {}) -> void:
	var active_combat := hit_combat if not hit_combat.is_empty() else combat
	var multiplier := float(active_combat.get("power", skill.get("power", 2.0)))
	multiplier += float(active_combat.get("add", 0.0)) * float(_get_official_skill_level())
	var role_prop := get_node_or_null("/root/RoleProp")
	var role_data_value: Variant = role_prop.get("roleprop") if role_prop != null else {}
	var role_data: Dictionary = role_data_value if role_data_value is Dictionary else {}
	var hit_data := {
		"power": int(float(role_data.get("power", 0)) * multiplier),
		"hurtBack":
		[
			MOUNT_CATALOG.to_runtime_knockback_x(active_combat.get("back", skill.get("hurt_back", 8))),
			MOUNT_CATALOG.to_runtime_knockback_y(active_combat.get("up", skill.get("hurt_up", -5))),
		],
		"attackKind": str(active_combat.get("attack", "magic")),
		"WSValue": int(skill.get("ws_value", 4)),
	}
	var damage := target.apply_role_hit(hero, hero, hit_data)
	if damage > 0 and str(skill.get("id", "")) == "3107300":
		var target_buff := target.get_node_or_null("Buff")
		if target_buff != null:
			Global.add_buff(
				target_buff, {"Name": "stun", "AddTime": 1.5, "ReduceInterval": 0, "value": 0, "DeBuff": true}
			)
	if damage > 0:
		_apply_official_target_buffs(target, str(skill.get("id", "")))
		var runtime := hero.get_node_or_null("MountRuntime")
		if runtime != null:
			if runtime.has_method("stop_skill_movement_on_hit"):
				runtime.call("stop_skill_movement_on_hit", str(skill.get("id", "")))
			if runtime.has_method("on_mount_hit"):
				runtime.call("on_mount_hit", str(skill.get("id", "")), target, _get_official_skill_level())
			if (
				str(skill.get("id", "")) in ["mount_normal", "3003800"]
				and not bool(active_combat.get("lightning", false))
				and not _lightning_targets.has(target.get_instance_id())
			):
				var lightning := bool(runtime.call("has_skill_buff", "9903101"))
				var flying_lightning := bool(runtime.call("has_skill_buff", "9903201"))
				if lightning or flying_lightning:
					_lightning_targets[target.get_instance_id()] = true
					var lightning_combat := MOUNT_CATALOG.get_official_combat(
						"3111601" if flying_lightning else "3111101"
					)
					lightning_combat["lightning"] = true
					_spawn_effect_visual(
						{
							"asset": "effect4_1" if flying_lightning else "attack1_4",
							"position": _target_center(target),
							"delay": 0.5 if flying_lightning else 0.0,
							"lifetime": 6.0 if flying_lightning else 0.6,
							"damage_config": lightning_combat,
							"alone": true,
							"seek_target": target if flying_lightning else null,
						}
					)
					if flying_lightning:
						_spawn_effect_visual(
							{
								"asset": "effect4_2",
								"position": _target_center(target),
								"delay": 0.5,
								"lifetime": 6.0,
								"damage": false,
								"seek_target": target,
							}
						)
		hit_landed.emit(str(skill.get("id", "")), target, elapsed)


func _apply_official_target_buffs(target: BaseMonster, skill_id: String) -> void:
	var raw: Dictionary = MOUNT_CATALOG.official_skill(skill_id)
	var holder := target.get_node_or_null("Buff")
	if holder == null:
		return
	for group_value in str(raw.get("buffId", "")).split(",", false):
		var buff: Dictionary = MOUNT_CATALOG.official_buff(group_value, _get_official_skill_level())
		var buff_name := ""
		var value := 0.0
		match int(buff.get("type", 0)):
			2, 29:
				buff_name = "stun"
			3:
				buff_name = "Immobilize"
			13:
				buff_name = "Ice"
			21:
				buff_name = "speed_down"
				value = absf(float(buff.get("attributeV1", "0")))
			8:
				if str(buff.get("attributeT", "")) == "phyDef":
					buff_name = "DefeReduce"
					value = absf(float(buff.get("attributeV1", "0")))
		if buff_name != "":
			(
				Global
				. add_buff(
					holder,
					{
						"Name": buff_name,
						"AddTime": float(buff.get("time", "0")) / 1000.0,
						"ReduceInterval": 0,
						"value": value,
						"DeBuff": true,
					}
				)
			)


func _get_official_skill_level() -> int:
	var mount_key := "1004700" if mount_id == "1004800" else mount_id
	var skill_key := str(skill.get("base_skill_id", skill.get("id", "")))
	var skill_level := PlayerData.get_mount_skill_level(mount_key, skill_key)
	return clampi(skill_level if skill_level > 0 else 1, 1, PlayerData.MOUNT_SKILL_MAX_LEVEL)


func _apply_buff() -> void:
	var runtime := hero.get_node_or_null("MountRuntime")
	if runtime != null and runtime.has_method("apply_official_skill_buff"):
		runtime.call("apply_official_skill_buff", str(skill.get("id", "")), _get_official_skill_level())
		return
	var skill_id := str(skill.get("id", ""))
	if skill_id != "3111100" and skill_id != "3107300":
		_buff_power_rate = clampf(float(skill.get("power", 1.25)) - 1.0, 0.15, 0.45)
		hero.temp_power_bonus_rate += _buff_power_rate
		var role_prop := get_node_or_null("/root/RoleProp")
		if role_prop != null and role_prop.has_method("get_last_prop"):
			role_prop.call("get_last_prop")
	if skill_id == "3111100":
		_buff_expires_msec = Time.get_ticks_msec() + 6000
		hero.set_meta("mount_claw_lightning_until", _buff_expires_msec)
	_remove_buff_later()


func _remove_buff_later() -> void:
	await get_tree().create_timer(6.0, false).timeout
	if hero != null and is_instance_valid(hero):
		if _buff_power_rate > 0.0:
			hero.temp_power_bonus_rate = maxf(0.0, hero.temp_power_bonus_rate - _buff_power_rate)
			var role_prop := get_node_or_null("/root/RoleProp")
			if role_prop != null and role_prop.has_method("get_last_prop"):
				role_prop.call("get_last_prop")
		if _buff_expires_msec > 0 and int(hero.get_meta("mount_claw_lightning_until", 0)) == _buff_expires_msec:
			hero.set_meta("mount_claw_lightning_until", 0)
