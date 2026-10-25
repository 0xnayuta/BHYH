extends BaseMonster

const PROJECTILE_SCRIPT := preload("res://Script/monster/wutai_minghai_projectile.gd")
const ROOT_BASE := "res://Art/monster/swf_png"
const SOURCE_FPS := 30.0
const HIT_INTERVAL := 0.5

@export var monster_kind := 3080

var _runtime_config: Dictionary = {}
var _body_visual: Node2D
var _source_boss: BaseMonster
var _damage_area: WutaiMinghaiProjectile
var _move_direction := -1.0
var _lifetime := 12.0
var _remaining_time := 12.0
var _configured := false


func _ready() -> void:
	set_meta("is_summon", true)
	no_grav = true
	super_armor_active = true
	_runtime_config = _resolve_runtime_config()
	if not _runtime_config.is_empty():
		_configure_summon(_runtime_config)
	_build_animations()
	mr_ani.visible = false
	super._ready()
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)
	if pz != null:
		pz.set_deferred("disabled", true)
	if _configured:
		_activate_configured_wind()


func configure_earth_wind(source_boss: BaseMonster, direction: float, lifetime: float) -> void:
	_source_boss = source_boss
	_move_direction = signf(direction)
	if is_zero_approx(_move_direction):
		_move_direction = 1.0
	_lifetime = maxf(lifetime, 0.05)
	_remaining_time = _lifetime
	_configured = true
	if is_node_ready():
		_activate_configured_wind()


func _activate_configured_wind() -> void:
	_apply_direction()
	velocity = Vector2(speed * 10.0 * _move_direction, 0.0)
	_create_damage_area.call_deferred()


func _resolve_runtime_config() -> Dictionary:
	var level_node := get_level_node()
	if level_node != null and level_node.has_method("get_level_monster_config"):
		var config: Variant = level_node.call("get_level_monster_config", monster_kind)
		if config is Dictionary and not config.is_empty():
			return (config as Dictionary).duplicate(true)
	push_error("WutaiEarthWind requires level monster config for %d" % monster_kind)
	return {}


func _configure_summon(config: Dictionary) -> void:
	my_mr_name = str(config.get("name", "风之祖巫"))
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
	add_exp = 0
	fall_coin = 0
	fall_pro = 0.0
	fall_list = []
	independent_fall_list = []
	is_boss = false
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


static func prewarm_frames() -> void:
	for kind in [3080, 3081]:
		var frames_path := ROOT_BASE.path_join(str(kind)).path_join("attack").path_join(
			"swf_png_%d_wind_frames.tres" % kind
		)
		ResourceLoader.load(frames_path, "SpriteFrames", ResourceLoader.CACHE_MODE_REUSE)


static func prewarm_effects() -> void:
	prewarm_frames()


func _build_animations() -> void:
	if mr_player.has_animation_library(&""):
		mr_player.remove_animation_library(&"")
	var animation := Animation.new()
	animation.length = 15.0 / SOURCE_FPS
	animation.loop_mode = Animation.LOOP_LINEAR
	var track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track, NodePath("."))
	animation.track_insert_key(track, 0.0, {"method": &"_show_wind", "args": []})
	var library := AnimationLibrary.new()
	library.add_animation(&"wait", animation)
	mr_player.add_animation_library(&"", library)


func _show_wind() -> void:
	# wait 动画每 0.5s 循环一次；视觉本身已是循环风效，
	# 重复创建只会不断重置帧与分配节点，因此存在时仅同步方向。
	if _body_visual != null and is_instance_valid(_body_visual):
		_apply_direction()
		return
	var frames_path := _wind_frames_path()
	var frames := load(frames_path) as SpriteFrames
	assert(frames != null and frames.has_animation(&"wind"), "缺少构建期帧资源: " + frames_path)
	var sprite := AnimatedSprite2D.new()
	sprite.name = "WindFrames"
	sprite.sprite_frames = frames
	sprite.animation = &"wind"
	var base_speed := frames.get_animation_speed(&"wind")
	if base_speed > 0.0:
		sprite.speed_scale = SOURCE_FPS / base_speed
	sprite.position = _visual_offset()
	monster_dir.add_child(sprite)
	_body_visual = sprite
	_apply_direction()


func _wind_frames_path() -> String:
	return ROOT_BASE.path_join(str(monster_kind)).path_join("attack").path_join(
		"swf_png_%d_wind_frames.tres" % monster_kind
	)


func _visual_offset() -> Vector2:
	return Vector2(6.0, -48.05) if monster_kind == 3080 else Vector2(-7.0, -88.05)


func _collision_size() -> Vector2:
	return Vector2(165.0, 126.0) if monster_kind == 3080 else Vector2(168.0, 225.0)


func _apply_direction() -> void:
	monster_dir.scale.x = _move_direction
	base_damage_box.scale.x = 1.0


func _create_damage_area() -> void:
	if not _configured or death() or _damage_area != null:
		return
	if _source_boss == null or not is_instance_valid(_source_boss):
		queue_free()
		return
	var attack_data := _attack_entry(&"hit1")
	if attack_data.is_empty():
		return
	var projectile_hit_name := "earth_wind_%d" % monster_kind
	_source_boss.obj_attack_dict[projectile_hit_name] = attack_data.duplicate(true)
	var area := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	var offset := _visual_offset()
	offset.x *= _move_direction
	var configured := (
		area
		. configure(
			{
				"owner": _source_boss,
				"position": global_position,
				"right": _move_direction > 0.0,
				"hit_name": projectile_hit_name,
				"attack_data": attack_data,
				"skill_name": "EarthAncestorSmallWind" if monster_kind == 3080 else "EarthAncestorLargeWind",
				"visual_backend": WutaiMinghaiProjectile.VisualBackend.NONE,
				"follow_target": true,
				"target_node": self,
				"collision_size": _collision_size(),
				"collision_offset": offset,
				"lifetime": _lifetime,
				"damage_duration": _lifetime,
				"damage_pulse_interval": HIT_INTERVAL,
				"poll_overlaps_on_damage_pulse": true,
				"max_hits": ceili(_lifetime / HIT_INTERVAL) + 1,
				"expire_on_hit": false,
			}
		)
	)
	if not configured:
		area.free()
		return
	_source_boss.bullet.add_child(area)
	_damage_area = area


func _attack_entry(attack_name: StringName) -> Dictionary:
	var key := str(attack_name)
	if obj_attack_dict.has(key):
		return (obj_attack_dict[key] as Dictionary).duplicate(true)
	push_error("WutaiEarthWind level config is missing attack %s" % key)
	return {}


func ai_think() -> void:
	if _configured and not death():
		velocity = Vector2(speed * 10.0 * _move_direction, 0.0)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not _configured:
		velocity = Vector2.ZERO
		return
	if _source_boss == null or not is_instance_valid(_source_boss) or _source_boss.death():
		queue_free()
		return
	_remaining_time -= delta
	if _remaining_time <= 0.0:
		queue_free()


func is_control_immune() -> bool:
	return true


func state_hurt() -> void:
	pass


func state_death() -> void:
	queue_free()


func _clear_body_stream() -> void:
	if _body_visual != null and is_instance_valid(_body_visual):
		if _body_visual is StreamedPngEffect:
			(_body_visual as StreamedPngEffect).clear_texture()
		_body_visual.queue_free()
	_body_visual = null


func _exit_tree() -> void:
	if _damage_area != null and is_instance_valid(_damage_area):
		_damage_area.queue_free()
	_damage_area = null
	_clear_body_stream()
