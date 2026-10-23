extends MonsterBullet
class_name Tongtian3057Projectile

const FRAMES_RES := "res://Art/monster/tongtian_3057/atlas/tongtian_3057_frames.tres"
const FRAME_COUNT := 10
const SOURCE_FPS := 30.0
const SPRITE_OFFSET := Vector2(-21.4, 2.2)
const SOURCE_LIFETIME := 1.267

var spawn_global_position := Vector2.ZERO
var travel_velocity := Vector2.ZERO
var _visual_animation: AnimatedSprite2D


func _ready() -> void:
	set_as_top_level(true)
	global_position = spawn_global_position
	set_meta("is_monster_bullet", true)
	get_prop()
	bullet_ani.visible = false
	_setup_standard_visual()
	middle.scale.x = 1.0 if travel_velocity.x >= 0.0 else -1.0
	queue_timer.start(SOURCE_LIFETIME)


func _physics_process(delta: float) -> void:
	global_position += travel_velocity * delta


func _setup_standard_visual() -> bool:
	var frames := load(FRAMES_RES) as SpriteFrames
	var animation := &"skill_1_projectile"
	if frames == null or not frames.has_animation(animation):
		return false
	var overlay := AnimatedSprite2D.new()
	overlay.name = "VisualFrames"
	overlay.sprite_frames = frames
	overlay.animation = animation
	overlay.centered = true
	overlay.position = SPRITE_OFFSET
	var base_speed := frames.get_animation_speed(animation)
	if base_speed > 0.0:
		overlay.speed_scale = SOURCE_FPS / base_speed
	overlay.play(animation)
	middle.add_child(overlay)
	_visual_animation = overlay
	return true


func _exit_tree() -> void:
	if _visual_animation != null and is_instance_valid(_visual_animation):
		_visual_animation.stop()
		_visual_animation.sprite_frames = null
		_visual_animation = null
