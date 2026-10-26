extends MonsterBullet

const FRAME_DIR := "res://Art/monster/game_3_monster/monster_212/DefineSprite_49_Monster212Bullet4_2_Cropped"
const FRAME_COUNT := 15
const SOURCE_FPS := 24.0
const HIT_START_TIME := 0.08

static var _frames_cache: SpriteFrames

var _elapsed := 0.0


func _ready() -> void:
	set_meta("is_monster_bullet", true)
	_build_frames()
	bullet_ani.play("Monster212Bullet4")
	hit_box.monitoring = false
	hit_box.area_entered.connect(_on_hit_box_area_entered)
	queue_timer.timeout.connect(_on_queue_timer_timeout)
	queue_timer.start(0.75)


func _physics_process(delta: float) -> void:
	throw_count += 1
	_elapsed += delta
	get_prop()
	hit_box.monitoring = _elapsed >= HIT_START_TIME
	if throw_count > int(0.75 * 60.0):
		queue_free()


func _build_frames() -> void:
	bullet_ani.sprite_frames = _get_frames()
	bullet_ani.animation = &"Monster212Bullet4"
	bullet_ani.centered = true
	bullet_ani.position = Vector2(0, -95)


static func prewarm_frames() -> void:
	_get_frames()


static func clear_cached_frames() -> void:
	_frames_cache = null


static func _get_frames() -> SpriteFrames:
	if _frames_cache != null:
		return _frames_cache
	var frames_path := FRAME_DIR.path_join("monster212_bullet4_frames.tres")
	if not ResourceLoader.exists(frames_path):
		return null
	_frames_cache = load(frames_path) as SpriteFrames
	return _frames_cache
