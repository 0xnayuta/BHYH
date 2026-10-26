extends MonsterBullet

@export_range(1, 3) var effect_kind := 1
@export var frame_count := 6

const SOURCE_FPS := 30.0
const FRAME_ROOT := "res://Art/monster/swf_png/3007"
const FLY_ANIMATION := &"arrow1"
const END_ANIMATION := &"arrow2"
const HIT_CLEAR_DELAY := 0.3
const END_FRAME_COUNT := 19

enum ProjectileState {
	FLYING,
	HIT_WAIT,
	ENDING,
}

var _trajectory := Vector2.ZERO
var _life_seconds := 5.0
var _trajectory_configured := false
var _state := ProjectileState.FLYING


func configure_trajectory(projectile_velocity: Vector2, life_seconds: float) -> void:
	_trajectory = projectile_velocity
	_life_seconds = life_seconds
	_trajectory_configured = true
	rotation = _trajectory.angle()


func _ready() -> void:
	set_meta("is_monster_bullet", true)
	get_prop()
	bullet_ani.centered = true
	bullet_ani.flip_h = false
	middle.scale = Vector2.ONE
	if effect_kind == 1:
		_start_arrow1()
	else:
		_start_arrow2()
	if not hit_box.area_entered.is_connected(_on_effect_area_entered):
		hit_box.area_entered.connect(_on_effect_area_entered)
	if not queue_timer.timeout.is_connected(_on_queue_timer_timeout):
		queue_timer.timeout.connect(_on_queue_timer_timeout)


func _start_arrow1() -> void:
	bullet_ani.sprite_frames = _get_arrow_frames(FLY_ANIMATION, "DefineSprite_12_arrow1", frame_count, true)
	bullet_ani.play(FLY_ANIMATION)
	if not _trajectory_configured:
		_trajectory = Vector2.RIGHT * 120.0
		rotation = _trajectory.angle()
	queue_timer.start(_life_seconds)


func _start_arrow2() -> void:
	if _state == ProjectileState.ENDING:
		return
	_state = ProjectileState.ENDING
	_trajectory = Vector2.ZERO
	rotation = 0.0
	queue_timer.stop()
	_disable_hit_box()
	bullet_ani.sprite_frames = _get_arrow_frames(END_ANIMATION, "DefineSprite_21_arrow2", END_FRAME_COUNT, false)
	bullet_ani.frame = 0
	bullet_ani.play(END_ANIMATION)
	if not bullet_ani.animation_finished.is_connected(_on_arrow2_finished):
		bullet_ani.animation_finished.connect(_on_arrow2_finished, CONNECT_ONE_SHOT)


func _physics_process(delta: float) -> void:
	if _state == ProjectileState.FLYING:
		position += _trajectory * delta
		rotation = _trajectory.angle()


func _on_effect_area_entered(area: Area2D) -> void:
	if _state != ProjectileState.FLYING or _get_hit_owner(area) is not BaseHero:
		return
	super._on_hit_box_area_entered(area)
	_state = ProjectileState.HIT_WAIT
	_trajectory = Vector2.ZERO
	_disable_hit_box()
	queue_timer.start(HIT_CLEAR_DELAY)


func _on_queue_timer_timeout() -> void:
	if _state != ProjectileState.ENDING:
		_start_arrow2()


func _disable_hit_box() -> void:
	hit_box.set_deferred("monitoring", false)
	hit_box.set_deferred("monitorable", false)
	var hit_shape := hit_box.get_node_or_null("Hit_Box") as CollisionShape2D
	if hit_shape != null:
		hit_shape.set_deferred("disabled", true)


func _on_arrow2_finished() -> void:
	queue_free()


static func _get_arrow_frames(
	_animation_name: StringName, _directory: String, _count: int, _looped: bool
) -> SpriteFrames:
	var frames_path := FRAME_ROOT.path_join("atlas/swf_png_3007_frames.tres")
	if not ResourceLoader.exists(frames_path):
		return null
	return load(frames_path) as SpriteFrames
