extends MonsterBullet

const FRAME_DIR := "res://Art/monster/game_3_monster/monster_212/DefineSprite_71_Monster212Bullet3"
const FRAME_COUNT := 28
const SOURCE_FPS := 24.0
const PULSE_TIMES := [0.08, 0.34, 0.6]
const PULSE_ACTIVE_TIME := 0.08

static var _frames_cache: SpriteFrames

@onready var hit_shape: CollisionShape2D = $middle/HitBox/Hit_Box

var _pulse_index := 0
var _elapsed := 0.0


func _ready() -> void:
	set_meta("is_monster_bullet", true)
	_build_frames()
	middle.scale.x = -1 if dir else 1
	bullet_ani.play("Monster212Bullet3")
	hit_box.monitoring = false
	hit_box.monitorable = false
	hit_shape.disabled = true
	hit_box.area_entered.connect(_on_hit_box_area_entered)
	queue_timer.timeout.connect(_on_queue_timer_timeout)
	queue_timer.start(1.25)


func _physics_process(delta: float) -> void:
	throw_count += 1
	_elapsed += delta
	get_prop()
	if _pulse_index < PULSE_TIMES.size() and _elapsed >= float(PULSE_TIMES[_pulse_index]):
		_fire_hit_pulse()
		_pulse_index += 1
	if throw_count > int(1.25 * 60.0):
		queue_free()


func _fire_hit_pulse() -> void:
	hit_box.monitorable = false
	hit_box.monitoring = false
	hit_shape.set_deferred("disabled", true)
	await get_tree().physics_frame
	if hit_box == null or hit_shape == null:
		return
	hit_box.monitorable = true
	hit_box.monitoring = true
	hit_shape.set_deferred("disabled", false)
	await get_tree().create_timer(PULSE_ACTIVE_TIME, false).timeout
	if hit_box == null or hit_shape == null:
		return
	hit_box.monitorable = false
	hit_box.monitoring = false
	hit_shape.set_deferred("disabled", true)


func _build_frames() -> void:
	bullet_ani.sprite_frames = _get_frames()
	bullet_ani.animation = &"Monster212Bullet3"
	bullet_ani.centered = false
	bullet_ani.position = Vector2(8, 7)


static func prewarm_frames() -> void:
	_get_frames()


static func clear_cached_frames() -> void:
	_frames_cache = null


static func _get_frames() -> SpriteFrames:
	if _frames_cache != null:
		return _frames_cache
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	frames.add_animation(&"Monster212Bullet3")
	frames.set_animation_loop(&"Monster212Bullet3", false)
	frames.set_animation_speed(&"Monster212Bullet3", SOURCE_FPS)
	for index in range(1, FRAME_COUNT + 1):
		var texture := Global.get_cached_texture(FRAME_DIR.path_join(str(index) + ".png"))
		if texture != null:
			frames.add_frame(&"Monster212Bullet3", texture)
	_frames_cache = frames
	return _frames_cache
