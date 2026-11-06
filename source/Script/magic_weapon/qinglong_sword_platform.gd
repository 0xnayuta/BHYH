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
var _riding := false
var _dropping := false
var _drop_platforms: Array[PhysicsBody2D] = []


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
	_update_rider()
	if _riding:
		prepare_player_motion(delta)
		return
	_source_elapsed += delta
	while _source_elapsed >= 1.0 / SOURCE_FPS:
		_source_elapsed -= 1.0 / SOURCE_FPS
		_step_source()

	var origin := get_source_origin(player)
	if player.velocity.y >= 0.0 and absf(origin.x - global_position.x) <= 65.0:
		global_position.y = maxf(global_position.y, origin.y + SOURCE_OFFSET_Y)


func _update_rider() -> void:
	if _dropping:
		_ignore_contact_swords()
		var feet_y := get_source_origin(player).y + 60.0
		if not player.PlayerInput.is_action_pressed("down") and (_is_on_terrain() or feet_y < global_position.y - 12.0):
			_restore_drop_collisions()
			_dropping = false
		return
	for index in player.get_slide_collision_count():
		var contact := player.get_slide_collision(index)
		if contact.get_collider() == self and contact.get_normal().y < -0.5:
			_riding = true
			break
	if (
		_riding
		and player.PlayerInput.is_action_pressed("down")
		and not player.is_using_skills
		and not player.is_attacking
	):
		_dropping = true
		_riding = false
		_stop_follow_tweens()
		_ignore_drop_platform(self)
		_ignore_contact_swords()
	elif player.velocity.y < -1.0:
		_riding = false


func _is_on_terrain() -> bool:
	if not player.is_on_floor():
		return false
	for index in player.get_slide_collision_count():
		var contact := player.get_slide_collision(index)
		if not contact.get_collider() is QinglongSwordPlatform and contact.get_normal().y < -0.5:
			return true
	return false


func _ignore_contact_swords() -> void:
	for index in player.get_slide_collision_count():
		var collider := player.get_slide_collision(index).get_collider()
		if collider is QinglongSwordPlatform:
			_ignore_drop_platform(collider)


func _ignore_drop_platform(platform: PhysicsBody2D) -> void:
	if platform not in _drop_platforms:
		player.add_collision_exception_with(platform)
		_drop_platforms.append(platform)


func _restore_drop_collisions() -> void:
	if is_instance_valid(player):
		for platform in _drop_platforms:
			if is_instance_valid(platform):
				player.remove_collision_exception_with(platform)
	_drop_platforms.clear()


func prepare_player_motion(delta: float) -> void:
	if not _riding or _dropping:
		return
	if player.velocity.y < -1.0:
		_riding = false
		return
	_stop_follow_tweens()
	var origin := get_source_origin(player)
	global_position.x = origin.x + player.velocity.x * delta
	var target_y := origin.y + SOURCE_OFFSET_Y
	if absf(target_y - global_position.y) > 2.0:
		global_position.y = target_y
	sword.flip_h = player.player_dir
	sword.position.x = -2.75 if sword.flip_h else 2.75


func _stop_follow_tweens() -> void:
	for tween in [_x_tween, _y_tween]:
		if tween != null and tween.is_valid():
			tween.kill()


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
	_restore_drop_collisions()
	for tween in [_x_tween, _y_tween, _entry_tween]:
		if tween != null and tween.is_valid():
			tween.kill()
