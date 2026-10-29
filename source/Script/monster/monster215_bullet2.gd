extends MonsterBullet

const FRAME_DIR := "res://Art/monster/game_3_monster/monster_215/DefineSprite_37_Monster215Bullet2"
const FRAME_COUNT := 25
const SOURCE_FPS := 30.0

const FRAME_SIZE := Vector2(755, 29)
const SOURCE_ORIGIN := Vector2(605, 6)
const HITBOX_ACTIVE_FRAMES := 15
const HITBOX_START_X := 68.5
const HITBOX_STEP_X := -43.2

static var _frames_cache: SpriteFrames

@onready var hit_shape: CollisionShape2D = $middle/HitBox/Hit_Box


func _ready() -> void:
	set_meta("is_monster_bullet", true)
	get_prop()
	bullet_ani.sprite_frames = _get_frames()
	bullet_ani.animation = &"Monster215Bullet2"
	bullet_ani.centered = true
	bullet_ani.position = FRAME_SIZE * 0.5 - SOURCE_ORIGIN
	middle.scale.x = -1 if dir else 1
	bullet_ani.play()
	_sync_hit_box()
	hit_box.area_entered.connect(_on_hit_box_area_entered)
	queue_timer.timeout.connect(_on_queue_timer_timeout)
	queue_timer.start(0.85)


func _physics_process(_delta: float) -> void:
	throw_count += 1
	get_prop()
	_sync_hit_box()


func _sync_hit_box() -> void:
	if hit_shape == null or bullet_ani == null:
		return
	var frame := bullet_ani.frame
	var active := frame >= 0 and frame < HITBOX_ACTIVE_FRAMES
	if active:
		hit_shape.position.x = HITBOX_START_X + float(frame) * HITBOX_STEP_X
	hit_shape.set_deferred("disabled", not active)


static func _get_frames() -> SpriteFrames:
	if _frames_cache != null:
		return _frames_cache
	var frames_path := FRAME_DIR.path_join("monster215_bullet2_frames.tres")
	if not ResourceLoader.exists(frames_path):
		return null
	_frames_cache = load(frames_path) as SpriteFrames
	return _frames_cache


# 19-2D：档案退出时释放模块静态帧/几何缓存，避免跨会话持有旧资源。
static func clear_cached_frames() -> void:
	_frames_cache = null
