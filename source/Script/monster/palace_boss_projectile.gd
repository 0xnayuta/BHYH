extends WutaiMinghaiProjectile

var source_masks: Dictionary = {}
var collide_terrain := false
var _source_metadata: Dictionary = {}


func configure(config: Dictionary) -> bool:
	collide_terrain = bool(config.get("collide_terrain", false))
	var metadata_path := str(config.get("source_masks_metadata", ""))
	_source_metadata = AtlasMetadataStore.data_for(metadata_path) if not metadata_path.is_empty() else {}
	var masks_value: Variant = _source_metadata.get("masks", {})
	source_masks = (masks_value as Dictionary).duplicate() if masks_value is Dictionary else {}
	return super.configure(config)


func _standard_visual_offset(animation: StringName, offset: Vector2) -> Vector2:
	var geometry_value: Variant = _source_metadata.get("geometry", {})
	if not geometry_value is Dictionary:
		return offset
	var geometry: Dictionary = geometry_value as Dictionary
	var entry_value: Variant = geometry.get(String(animation), {})
	if not entry_value is Dictionary:
		return offset
	var center_value: Variant = (entry_value as Dictionary).get("center", [])
	if not center_value is Array:
		return offset
	var center: Array = center_value as Array
	if center.size() < 2:
		return offset
	return Vector2(float(center[0]), float(center[1]))


func _physics_process(delta: float) -> void:
	var previous := global_position
	super._physics_process(delta)
	if not collide_terrain or _finished or _impacting or motion_velocity.y <= 0:
		return
	var query := PhysicsRayQueryParameters2D.create(previous, global_position, 32)
	var collision := get_world_2d().direct_space_state.intersect_ray(query)
	if not collision.is_empty():
		global_position = collision["position"]
		_begin_impact()


func _finish() -> void:
	if not _finished and not _impacting and _has_impact_visual():
		_begin_impact()
		return
	super._finish()


func _sync_collision_to_visual_frame(force: bool = false) -> void:
	if not source_masks.has(frames_animation):
		super._sync_collision_to_visual_frame(force)
		return
	var masks: Array = source_masks[frames_animation]
	var frame := _displayed_visual_frame()
	if frame < 0 or masks.is_empty():
		super._sync_collision_to_visual_frame(force)
		return
	frame = clampi(frame, 0, masks.size() - 1)
	var mask: Array = masks[frame]
	_current_frame_has_visual = not mask.is_empty()
	if mask.size() < 4:
		_apply_collision_geometry(Vector2.ONE, Vector2.ZERO)
		return
	_apply_collision_geometry(
		Vector2(float(mask[2]), float(mask[3])),
		Vector2(float(mask[0]) + float(mask[2]) * 0.5, float(mask[1]) + float(mask[3]) * 0.5)
	)
