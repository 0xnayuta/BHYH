extends StaticBody2D
class_name QinglongSwordPlatform

const SOURCE_FPS := 24.0
const FOLLOW_X_DISTANCE := 30.0
const FOLLOW_Y_DISTANCE := 62.0
const SOURCE_OFFSET_Y := 70.0
const FOLLOW_X_TIME := 0.4
const FOLLOW_Y_TIME := 0.1

@onready var sword: Sprite2D = $Sword

var player: BaseHero
var duration := 30.0
var remaining_time := 30.0

var _source_elapsed := 0.0
var _x_tween: Tween
var _y_tween: Tween
var _entry_tween: Tween


static func get_source_origin(hero: BaseHero) -> Vector2:
	var collider := hero.get_node_or_null("pz") as CollisionShape2D
	if collider != null and collider.shape != null:
		return collider.to_global(Vector2(0, collider.shape.get_rect().end.y)) - Vector2(0, 60)
	return hero.global_position - Vector2(0, 60)


func _ready() -> void:
	remaining_time = duration
	sword.position.y -= 170.0
	_entry_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_entry_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_entry_tween.tween_property(sword, "position:y", 0.55, FOLLOW_Y_TIME)
	if is_instance_valid(player):
		sword.flip_h = player.player_dir
		sword.position.x = -2.75 if sword.flip_h else 2.75


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player) or player.is_queued_for_deletion() or player.death():
		queue_free()
		return
	if duration >= 0.0:
		remaining_time -= delta
		if remaining_time <= 0.0:
			queue_free()
			return
	_source_elapsed += delta
	while _source_elapsed >= 1.0 / SOURCE_FPS:
		_source_elapsed -= 1.0 / SOURCE_FPS
		_step_source()

	var origin := get_source_origin(player)
	if player.velocity.y >= 0.0 and absf(origin.x - global_position.x) <= 65.0:
		global_position.y = maxf(global_position.y, origin.y + SOURCE_OFFSET_Y)


func _step_source() -> void:
	var origin := get_source_origin(player)
	var offset := origin - global_position
	if absf(offset.x) > FOLLOW_X_DISTANCE:
		sword.flip_h = offset.x < 0.0
		sword.position.x = -2.75 if sword.flip_h else 2.75
		if _x_tween != null and _x_tween.is_valid():
			_x_tween.kill()
		_x_tween = _follow_axis("global_position:x", origin.x, FOLLOW_X_TIME)
	if absf(offset.y) > FOLLOW_Y_DISTANCE:
		if _y_tween != null and _y_tween.is_valid():
			_y_tween.kill()
		_y_tween = _follow_axis("global_position:y", origin.y + SOURCE_OFFSET_Y, FOLLOW_Y_TIME)


func _follow_axis(property: NodePath, target: float, time: float) -> Tween:
	var tween := create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, property, target, time)
	return tween


func _exit_tree() -> void:
	for tween in [_x_tween, _y_tween, _entry_tween]:
		if tween != null and tween.is_valid():
			tween.kill()
