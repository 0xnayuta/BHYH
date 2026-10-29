extends MonsterBullet

static var _frames_cache: SpriteFrames
var _move_speed := 80.0
var _has_hit := false


func set_source_shot_distance(distance: float) -> void:
	_move_speed = maxf(_move_speed, maxf(distance, 0.0) / 1.4)


func _ready() -> void:
	set_meta("is_monster_bullet", true)
	get_prop()
	bullet_ani.sprite_frames = _get_frames()
	bullet_ani.play(&"arrow")
	middle.scale.x = 1.0 if dir else -1.0
	hit_box.area_entered.connect(_on_arrow_area_entered)
	queue_timer.timeout.connect(_on_queue_timer_timeout)
	queue_timer.start(1.4)


func _physics_process(delta: float) -> void:
	global_position.x += (1.0 if dir else -1.0) * _move_speed * delta


func _on_arrow_area_entered(area: Area2D) -> void:
	if _has_hit:
		return
	_has_hit = true
	super._on_hit_box_area_entered(area)
	_move_speed = 0.0
	hit_box.set_deferred("monitoring", false)
	hit_box.set_deferred("monitorable", false)
	queue_timer.start(0.267)


static func _get_frames() -> SpriteFrames:
	if _frames_cache != null:
		return _frames_cache
	var frames_path := "res://Art/monster/swf_png/3009/atlas/swf_png_3009_frames.tres"
	if not ResourceLoader.exists(frames_path):
		return null
	_frames_cache = load(frames_path) as SpriteFrames
	return _frames_cache


# 19-2D：档案退出时释放模块静态帧/几何缓存，避免跨会话持有旧资源。
static func clear_cached_frames() -> void:
	_frames_cache = null
