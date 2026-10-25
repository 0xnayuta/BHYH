extends BaseMonster

const PROJECTILE_SCRIPT := preload("res://Script/monster/wutai_minghai_projectile.gd")
const ROOT := "res://Art/monster/swf_png/3082"
const SOURCE_FPS := 30.0
const WALL_MOVE_DISTANCE := 200.0
const WALL_COLLISION_CENTER_Y := 500.0
const FIRST_ARROW_DELAY := 0.1
const ARROW_INTERVAL := 1.0
const ARROW_RELOAD_TIME := 5.0
const ARROW_Y_OFFSETS := [-86.0, -180.0, -264.0, -354.0]
const WALL_GROUND_SHIFT_Y := 125.975
const WALL_VISUAL_OFFSET := Vector2(-1.1, -71.0)
const WALL_PROJECTILE_HIT := "wall_hit1"
const WALL_FRAMES_RES := ROOT + "/wall/swf_png_3082_wall_frames.tres"
const ARROW_FRAMES_RES := ROOT + "/arrow/swf_png_3082_arrow_frames.tres"

@export var monster_kind := 3082

var _runtime_config: Dictionary = {}
var _body_visual: Node2D
var _arrow_visuals: Array[Node2D] = []
var _source_boss: BaseMonster
var _move_direction := 1.0
var _spawn_x := 0.0
var _configured := false
var _shooting := false
var _volley_serial := 0
var _next_volley_msec := 0
var _projectile_speed := 120.0
var _projectile_lifetime := 5.0


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
	if hit_box != null:
		hit_box.set_deferred("disabled", true)
	_sync_barrier_height()
	if _configured:
		_apply_direction()


func configure_earth_wall(source_boss: BaseMonster, direction: float) -> void:
	_source_boss = source_boss
	_move_direction = signf(direction)
	if is_zero_approx(_move_direction):
		_move_direction = 1.0
	_spawn_x = position.x
	_configured = true
	_next_volley_msec = Time.get_ticks_msec() + randi_range(6000, 12000)
	if is_node_ready():
		_apply_direction()


func _resolve_runtime_config() -> Dictionary:
	var level_node := get_level_node()
	if level_node != null and level_node.has_method("get_level_monster_config"):
		var config: Variant = level_node.call("get_level_monster_config", monster_kind)
		if config is Dictionary and not config.is_empty():
			return (config as Dictionary).duplicate(true)
	push_error("WutaiEarthWall3082 requires level monster config for 3082")
	return {}


func _configure_summon(config: Dictionary) -> void:
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
	add_exp = 0
	fall_coin = 0
	fall_pro = 0.0
	fall_list = []
	independent_fall_list = []
	is_boss = false
	boss_max_protect = float(config["max_protect"])
	_projectile_speed = float(config.get("projectile_speed", 120.0))
	_projectile_lifetime = float(config.get("projectile_lifetime", 5.0))
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
	ResourceLoader.load(WALL_FRAMES_RES, "SpriteFrames", ResourceLoader.CACHE_MODE_REUSE)
	ResourceLoader.load(ARROW_FRAMES_RES, "SpriteFrames", ResourceLoader.CACHE_MODE_REUSE)


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
	animation.track_insert_key(track, 0.0, {"method": &"_show_wall", "args": []})
	var library := AnimationLibrary.new()
	library.add_animation(&"wait", animation)
	mr_player.add_animation_library(&"", library)


func _show_wall() -> void:
	_clear_visuals()
	_body_visual = _create_visual(WALL_FRAMES_RES, &"wall", "wall", 15, WALL_VISUAL_OFFSET, true)
	for y_offset in ARROW_Y_OFFSETS:
		_arrow_visuals.append(
			_create_visual(
				ARROW_FRAMES_RES, &"arrow", "arrow", 1, Vector2(77.0, float(y_offset) + WALL_GROUND_SHIFT_Y), true
			)
		)
	_apply_direction()


func _create_visual(
	frames_path: String, animation: StringName, folder: String, _count: int, offset: Vector2, _looped: bool
) -> Node2D:
	var frames := load(frames_path) as SpriteFrames
	assert(frames != null and frames.has_animation(animation), "缺少构建期帧资源: " + frames_path)
	var sprite := AnimatedSprite2D.new()
	sprite.name = "WallFrames" if folder == "wall" else "ArrowFrames"
	sprite.sprite_frames = frames
	sprite.animation = animation
	var base_speed := frames.get_animation_speed(animation)
	if base_speed > 0.0:
		sprite.speed_scale = SOURCE_FPS / base_speed
	sprite.position = offset
	monster_dir.add_child(sprite)
	return sprite


func _apply_direction() -> void:
	if _body_visual != null and is_instance_valid(_body_visual):
		_set_visual_flip(_body_visual, _move_direction < 0.0)
		_body_visual.position.x = -1.1 * _move_direction
	for index in range(_arrow_visuals.size()):
		var arrow := _arrow_visuals[index]
		if arrow == null or not is_instance_valid(arrow):
			continue
		_set_visual_flip(arrow, _move_direction < 0.0)
		arrow.position = Vector2(77.0 * _move_direction, float(ARROW_Y_OFFSETS[index]) + WALL_GROUND_SHIFT_Y)
	monster_dir.scale.x = 1.0
	base_damage_box.scale.x = 1.0


func _set_visual_flip(node: Node2D, flip: bool) -> void:
	if node is AnimatedSprite2D:
		(node as AnimatedSprite2D).flip_h = flip
	elif node is StreamedPngEffect:
		(node as StreamedPngEffect).flip_h = flip


func ai_think() -> void:
	if not _configured or death():
		velocity = Vector2.ZERO
		return
	var target_x := _spawn_x + WALL_MOVE_DISTANCE * _move_direction
	var remaining := (target_x - position.x) * _move_direction
	if remaining > 0.0:
		velocity = Vector2(speed * 10.0 * _move_direction, 0.0)
	else:
		position.x = target_x
		velocity = Vector2.ZERO
	var now := Time.get_ticks_msec()
	if not _shooting and now >= _next_volley_msec:
		_begin_arrow_volley()


func _begin_arrow_volley() -> void:
	if _shooting or death():
		return
	_shooting = true
	_volley_serial += 1
	var serial := _volley_serial
	_next_volley_msec = Time.get_ticks_msec() + randi_range(6000, 12000)
	await get_tree().create_timer(FIRST_ARROW_DELAY, false).timeout
	for arrow_index in range(_arrow_visuals.size()):
		if not is_instance_valid(self) or death() or serial != _volley_serial:
			return
		var arrow := _arrow_visuals[arrow_index]
		if arrow != null and is_instance_valid(arrow):
			arrow.visible = false
		_fire_arrow(arrow_index)
		_restore_arrow_later(arrow_index, serial)
		if arrow_index < _arrow_visuals.size() - 1:
			await get_tree().create_timer(ARROW_INTERVAL, false).timeout
	if is_instance_valid(self) and serial == _volley_serial:
		_shooting = false


func _restore_arrow_later(arrow_index: int, serial: int) -> void:
	await get_tree().create_timer(ARROW_RELOAD_TIME, false).timeout
	if not is_instance_valid(self) or death() or serial != _volley_serial:
		return
	if arrow_index < 0 or arrow_index >= _arrow_visuals.size():
		return
	var arrow := _arrow_visuals[arrow_index]
	if arrow != null and is_instance_valid(arrow):
		arrow.visible = true


func _fire_arrow(arrow_index: int) -> void:
	if _source_boss == null or not is_instance_valid(_source_boss):
		return
	var attack_data := _attack_entry(&"hit1")
	if attack_data.is_empty():
		return
	_source_boss.obj_attack_dict[WALL_PROJECTILE_HIT] = attack_data.duplicate(true)
	var arrow := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	(
		arrow
		. configure(
			{
				"owner": _source_boss,
				"position":
				(
					global_position
					+ Vector2(77.0 * _move_direction, float(ARROW_Y_OFFSETS[arrow_index]) + WALL_GROUND_SHIFT_Y)
				),
				"right": _move_direction > 0.0,
				"hit_name": WALL_PROJECTILE_HIT,
				"attack_data": attack_data,
				"skill_name": "EarthAncestorStoneSpike",
				"frame_root": ROOT.path_join("arrow"),
				"frame_count": 1,
				"frames_resource": ARROW_FRAMES_RES,
				"frames_animation": "arrow",
				"loop_visual": true,
				"velocity": Vector2(_projectile_speed * _move_direction, 0.0),
				"lifetime": _projectile_lifetime,
				"damage_duration": _projectile_lifetime,
				"max_hits": 1,
				"expire_on_hit": true,
			}
		)
	)
	_source_boss.bullet.add_child(arrow)


func _attack_entry(attack_name: StringName) -> Dictionary:
	var key := str(attack_name)
	if obj_attack_dict.has(key):
		return (obj_attack_dict[key] as Dictionary).duplicate(true)
	push_error("WutaiEarthWall3082 level config is missing attack %s" % key)
	return {}


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_sync_barrier_height()
	if not _configured:
		velocity = Vector2.ZERO
		return
	if _source_boss == null or not is_instance_valid(_source_boss) or _source_boss.death():
		queue_free()


func _sync_barrier_height() -> void:
	if pz != null:
		pz.position = Vector2(0.0, WALL_COLLISION_CENTER_Y - global_position.y)


func is_control_immune() -> bool:
	return true


func state_hurt() -> void:
	pass


func state_death() -> void:
	queue_free()


func _clear_visuals() -> void:
	if _body_visual != null and is_instance_valid(_body_visual):
		_free_visual(_body_visual)
	_body_visual = null
	for arrow in _arrow_visuals:
		if arrow != null and is_instance_valid(arrow):
			_free_visual(arrow)
	_arrow_visuals.clear()


func _free_visual(node: Node2D) -> void:
	if node is StreamedPngEffect:
		(node as StreamedPngEffect).clear_texture()
	node.queue_free()


func _exit_tree() -> void:
	_volley_serial += 1
	_clear_visuals()
