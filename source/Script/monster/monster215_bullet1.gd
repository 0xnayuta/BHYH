extends MonsterBullet

const FRAME_DIR := "res://Art/monster/game_3_monster/monster_215/DefineSprite_50_Monster215Bullet1"
const FRAME_COUNT := 18
const SOURCE_FPS := 30.0

const FRAME_SIZE := Vector2(160, 164)
const SOURCE_ORIGIN := Vector2(54, 79)

static var _frames_cache: SpriteFrames


func _ready() -> void:
	set_meta("is_monster_bullet", true)
	get_prop()
	bullet_ani.sprite_frames = _get_frames()
	bullet_ani.animation = &"Monster215Bullet1"
	bullet_ani.centered = true
	bullet_ani.position = FRAME_SIZE * 0.5 - SOURCE_ORIGIN
	middle.scale.x = -1 if dir else 1
	bullet_ani.play()
	hit_box.area_entered.connect(_on_hit_box_area_entered)
	queue_timer.timeout.connect(_on_queue_timer_timeout)
	queue_timer.start(0.65)


func _physics_process(_delta: float) -> void:
	throw_count += 1
	get_prop()


static func _get_frames() -> SpriteFrames:
	if _frames_cache != null:
		return _frames_cache
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	frames.add_animation(&"Monster215Bullet1")
	frames.set_animation_loop(&"Monster215Bullet1", false)
	frames.set_animation_speed(&"Monster215Bullet1", SOURCE_FPS)
	for index in range(1, FRAME_COUNT + 1):
		var texture := Global.get_cached_texture(FRAME_DIR.path_join(str(index) + ".png"))
		if texture != null:
			frames.add_frame(&"Monster215Bullet1", texture)
	_frames_cache = frames
	return _frames_cache
