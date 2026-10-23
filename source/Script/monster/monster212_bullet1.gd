extends MonsterBullet

const FRAME_DIR := "res://Art/monster/game_3_monster/monster_212/DefineSprite_92_Monster212Bullet1_Cropped"
const FRAME_COUNT := 15
const SOURCE_FPS := 24.0
const FLY_SPEED := 520.0

static var _frames_cache: SpriteFrames

var _move_direction := 1.0


func _ready() -> void:
	set_meta("is_monster_bullet", true)
	_build_frames()
	_move_direction = 1.0 if dir else -1.0
	middle.scale.x = -1 if dir else 1
	bullet_ani.play("Monster212Bullet1")
	hit_box.area_entered.connect(_on_hit_box_area_entered)
	queue_timer.timeout.connect(_on_queue_timer_timeout)
	queue_timer.start(1.5)


func _physics_process(delta: float) -> void:
	throw_count += 1
	get_prop()
	position.x += _move_direction * FLY_SPEED * maxf(speed, 0.1) * delta
	if throw_count > int(1.5 * 60.0):
		queue_free()


func _build_frames() -> void:
	bullet_ani.sprite_frames = _get_frames()
	bullet_ani.animation = &"Monster212Bullet1"
	bullet_ani.centered = true
	bullet_ani.position = Vector2.ZERO


static func prewarm_frames() -> void:
	_get_frames()


static func clear_cached_frames() -> void:
	_frames_cache = null


static func _get_frames() -> SpriteFrames:
	if _frames_cache != null:
		return _frames_cache
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	frames.add_animation(&"Monster212Bullet1")
	frames.set_animation_loop(&"Monster212Bullet1", true)
	frames.set_animation_speed(&"Monster212Bullet1", SOURCE_FPS)
	for index in range(1, FRAME_COUNT + 1):
		var texture := Global.get_cached_texture(FRAME_DIR.path_join(str(index) + ".png"))
		if texture != null:
			frames.add_frame(&"Monster212Bullet1", texture)
	_frames_cache = frames
	return _frames_cache
