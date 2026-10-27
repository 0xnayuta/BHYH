extends WutaiMinghaiProjectile

## NorthBossProjectile 仍可在 configure 后写入 source_masks 覆盖；迁移期保留。
## 新代码优先使用 _metadata_view，不再读取 AtlasMetadata.data。
var source_masks: Dictionary = {}
var collide_terrain := false
var _metadata_view: AtlasMetadataView = null


func configure(config: Dictionary) -> bool:
	collide_terrain = bool(config.get("collide_terrain", false))
	source_masks.clear()
	_metadata_view = null
	var metadata_path := str(config.get("source_masks_metadata", ""))
	if not metadata_path.is_empty():
		_metadata_view = AtlasMetadataStore.view_for(metadata_path)
		if _metadata_view == null:
			return false
	return super.configure(config)


func _standard_visual_offset(animation: StringName, offset: Vector2) -> Vector2:
	if _metadata_view == null or not _metadata_view.has_geometry(animation):
		return offset
	return _metadata_view.geometry_center(animation)


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
	if source_masks.has(frames_animation):
		_sync_collision_from_overrides(force)
		return
	if _metadata_view != null and _metadata_view.has_mask_sequence(frames_animation):
		_sync_collision_from_view(force)
		return
	super._sync_collision_to_visual_frame(force)


func _sync_collision_from_overrides(force: bool) -> void:
	var masks_value: Variant = source_masks.get(frames_animation, null)
	if not masks_value is Array:
		super._sync_collision_to_visual_frame(force)
		return
	var masks: Array = masks_value as Array
	var frame := _displayed_visual_frame()
	if frame < 0 or masks.is_empty():
		super._sync_collision_to_visual_frame(force)
		return
	frame = clampi(frame, 0, masks.size() - 1)
	var mask_value: Variant = masks[frame]
	if not mask_value is Array:
		super._sync_collision_to_visual_frame(force)
		return
	var mask: Array = mask_value as Array
	_current_frame_has_visual = not mask.is_empty()
	if mask.size() < 4:
		_apply_collision_geometry(Vector2.ONE, Vector2.ZERO)
		return
	_apply_collision_geometry(
		Vector2(float(mask[2]), float(mask[3])),
		Vector2(float(mask[0]) + float(mask[2]) * 0.5, float(mask[1]) + float(mask[3]) * 0.5)
	)


func _sync_collision_from_view(force: bool) -> void:
	var frame_count := _metadata_view.mask_frame_count(frames_animation)
	var frame := _displayed_visual_frame()
	if frame < 0 or frame_count <= 0:
		super._sync_collision_to_visual_frame(force)
		return
	frame = clampi(frame, 0, frame_count - 1)
	if _metadata_view.mask_frame_is_empty(frames_animation, frame):
		_current_frame_has_visual = false
		_apply_collision_geometry(Vector2.ONE, Vector2.ZERO)
		return
	var mask := _metadata_view.mask_frame_rect(frames_animation, frame)
	_current_frame_has_visual = true
	_apply_collision_geometry(mask.size, mask.position + mask.size * 0.5)
