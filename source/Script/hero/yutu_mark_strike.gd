extends "res://Script/hero/yutu_skill_effect.gd"

const FLIGHT_SPEED := 1100.0
var target_ref: WeakRef
var impacted := false
var _center_frame := -1
var _destination := Vector2.ZERO
var _contact_query := PhysicsShapeQueryParameters2D.new()


func _ready() -> void:
	bank = "blade"
	effect_name = "effect1_4"
	skill_id = YutuSkillData.PASSIVE_KEY
	super._ready()

	hit_box.collision_layer = 0
	hit_box.monitorable = false
	hit_box.monitoring = false
	_contact_query.collision_mask = hit_box.collision_mask
	_contact_query.collide_with_areas = true
	_contact_query.collide_with_bodies = false
	z_index = 20
	_center_visual()


func _center_visual() -> void:
	var frame: int = visual.get("frame_index")
	if frame == _center_frame:
		return
	_center_frame = frame
	var commands: PackedFloat32Array = visual.get("_poses")
	var regions: Array = visual.get("_regions")
	var offset: int = visual.get("_offset")
	var count: int = visual.get("_count")
	var bounds := Rect2()
	for index in range(count):
		var p := offset + index * 9
		var region: Rect2 = regions[int(commands[p])]
		var transform := Transform2D(
			Vector2(commands[p + 1], commands[p + 2]),
			Vector2(commands[p + 3], commands[p + 4]),
			Vector2(commands[p + 5], commands[p + 6])
		)
		var rect := transform * Rect2(Vector2.ZERO, region.size)
		bounds = rect if index == 0 else bounds.merge(rect)
	collion.disabled = count == 0 or hit_dic.is_empty()
	if count > 0:
		visual.position = -bounds.get_center()
		(collion.shape as RectangleShape2D).size = bounds.size
		collion.position = Vector2.ZERO


func launch(target: BaseMonster) -> void:
	target_ref = weakref(target)
	_destination = target.global_position + Vector2(0, -55)
	var canvas := get_viewport().get_canvas_transform()
	var screen := get_viewport_rect()
	var aim := canvas * (target.global_position + Vector2(0, -55))
	var side := -1.0 if player.player_dir else 1.0
	var start := Vector2(
		clampf(aim.x + side * 160.0, screen.position.x + 40.0, screen.end.x - 40.0), screen.position.y - 80.0
	)
	global_position = canvas.affine_inverse() * start
	_face_target()


func _face_target() -> void:
	middle.scale = Vector2.ONE
	middle.rotation = (_destination - global_position).angle() - PI / 2.0


func _physics_process(delta: float) -> void:
	var target: BaseMonster = target_ref.get_ref() if target_ref != null else null
	if not is_instance_valid(player) or player.is_death:
		queue_free()
		return
	elapsed += delta
	if impacted:
		visual.set_time(effect_name, elapsed)
		_center_visual()
		_apply_contacts()
		if elapsed >= 0.434:
			queue_free()
		return
	if is_instance_valid(target) and target.is_inside_tree() and not target.death() and not target.is_death:
		_destination = target.global_position + Vector2(0, -55)
	_face_target()
	global_position = global_position.move_toward(_destination, FLIGHT_SPEED * delta)

	visual.set_time(effect_name, fmod(elapsed, 0.5))
	_center_visual()
	_apply_contacts()
	if global_position.distance_to(_destination) <= 1.0:
		impacted = true
		elapsed = 0.0

		_hit_targets.clear()
		effect_name = "effect1_1"
		middle.rotation = 0.0
		visual.set_pose(effect_name, 0)
		_center_frame = -1
		_center_visual()
	elif elapsed >= 3.0:
		queue_free()


func _apply_contacts() -> void:
	if collion.disabled:
		return

	_contact_query.shape = collion.shape
	_contact_query.transform = collion.global_transform
	for contact: Dictionary in get_world_2d().direct_space_state.intersect_shape(_contact_query, 128):
		_on_hit_box_area_entered(contact.collider as Area2D)


func _on_hit_box_area_entered(area: Area2D) -> void:
	var target := _get_monster_from_hit_area(area)
	if target == null or _is_summon_or_pet_target(target) or target.death() or target.is_death or hit_dic.is_empty():
		return
	var id := target.get_instance_id()
	if _hit_targets.has(id):
		return
	_hit_targets[id] = true
	target.apply_role_hit(self, player)
