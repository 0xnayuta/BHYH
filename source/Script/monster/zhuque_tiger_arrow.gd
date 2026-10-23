extends MonsterBullet

const FRAME_ROOT := "res://Art/monster/swf_png/3002/arrow"
const FRAME_COUNT := 8
const SOURCE_FPS := 30.0

static var _frames_cache: SpriteFrames
var _move_speed := 650.0


func _ready() -> void:
	set_meta("is_monster_bullet", true)
	get_prop()
	bullet_ani.sprite_frames = _get_frames()
	bullet_ani.play(&"fly")
	middle.scale.x = 1.0 if dir else -1.0
	hit_box.area_entered.connect(_on_arrow_area_entered)
	queue_timer.timeout.connect(_on_queue_timer_timeout)
	queue_timer.start(2.5)


func _physics_process(delta: float) -> void:
	global_position.x += (1.0 if dir else -1.0) * _move_speed * delta


func _on_arrow_area_entered(area: Area2D) -> void:
	super._on_hit_box_area_entered(area)
	queue_free()


static func _get_frames() -> SpriteFrames:
	if _frames_cache != null:
		return _frames_cache
	var frames_path := "res://Art/monster/swf_png/3002/atlas/swf_png_3002_frames.tres"
	if ResourceLoader.exists(frames_path):
		var source := load(frames_path) as SpriteFrames
		if source != null and source.has_animation(&"arrow"):
			var frames := SpriteFrames.new()
			frames.remove_animation(&"default")
			frames.add_animation(&"fly")
			frames.set_animation_loop(&"fly", true)
			frames.set_animation_speed(&"fly", source.get_animation_speed(&"arrow"))
			for i in range(source.get_frame_count(&"arrow")):
				frames.add_frame(&"fly", source.get_frame_texture(&"arrow", i))
			_frames_cache = frames
			return frames
	return null
