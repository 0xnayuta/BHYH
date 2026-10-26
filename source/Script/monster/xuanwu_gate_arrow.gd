extends MonsterBullet

const FRAME_ROOT := "res://Art/monster/swf_png/3004"
const FLY_FRAME_COUNT := 4
const EXPLODE_FRAME_COUNT := 14
const SOURCE_FPS := 30.0

static var _frames_cache: SpriteFrames
var _move_speed := 620.0
var _target_x := 0.0
var _is_exploding := false


func _ready() -> void:
	set_meta("is_monster_bullet", true)
	get_prop()
	bullet_ani.sprite_frames = _get_frames()
	bullet_ani.play(&"fly")

	middle.scale.x = 1 if dir else -1
	_target_x = global_position.x + (520.0 if dir else -520.0)
	if RoleProp.get_nearest_monster_target_position(global_position).x != null:
		_target_x = float(RoleProp.get_nearest_monster_target_position(global_position).x)
	var travel_distance := absf(_target_x - global_position.x)
	_move_speed = clampf(travel_distance / 0.7, 320.0, 900.0)
	hit_box.area_entered.connect(_on_fireball_area_entered)
	queue_timer.timeout.connect(_on_queue_timer_timeout)
	queue_timer.start(2.5)


func _physics_process(delta: float) -> void:
	if _is_exploding:
		return
	var direction_sign := 1.0 if dir else -1.0
	global_position.x += direction_sign * _move_speed * delta
	if (dir and global_position.x >= _target_x) or (not dir and global_position.x <= _target_x):
		_explode()


func _on_fireball_area_entered(area: Area2D) -> void:
	if _is_exploding:
		return
	super._on_hit_box_area_entered(area)
	_explode()


func _explode() -> void:
	if _is_exploding:
		return
	_is_exploding = true
	queue_timer.stop()
	var collision := hit_box.get_node_or_null("Hit_Box") as CollisionShape2D
	if collision != null:
		collision.set_deferred("disabled", true)
	bullet_ani.play(&"explode")
	await get_tree().physics_frame
	if collision != null and is_instance_valid(collision):
		var explosion_shape := RectangleShape2D.new()
		explosion_shape.size = Vector2(175, 135)
		collision.shape = explosion_shape
		collision.set_deferred("disabled", false)
	await bullet_ani.animation_finished
	queue_free()


static func _get_frames() -> SpriteFrames:
	if _frames_cache != null:
		return _frames_cache
	var frames_path := FRAME_ROOT.path_join("atlas/swf_png_3004_frames.tres")
	if not ResourceLoader.exists(frames_path):
		return null
	_frames_cache = load(frames_path) as SpriteFrames
	return _frames_cache
