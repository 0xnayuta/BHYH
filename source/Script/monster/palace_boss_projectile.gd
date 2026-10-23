extends WutaiMinghaiProjectile

var source_masks: Dictionary = {}
var collide_terrain := false


func configure(config: Dictionary) -> void:
	collide_terrain = bool(config.get("collide_terrain", false))
	super.configure(config)


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


func _configure_atlas_visual(
	sequence_name: String, source_offset: Vector2, looped: bool, metadata_path: String = ""
) -> bool:
	var path := atlas_metadata if metadata_path.is_empty() else metadata_path
	var data := AtlasMetadataStore.data_for(path)
	source_masks = data.get("masks", {})
	var center: Array = data.get("geometry", {}).get(sequence_name, {}).get("center", [0.0, 0.0])
	return super._configure_atlas_visual(
		sequence_name, Vector2(float(center[0]), float(center[1])), looped, metadata_path
	)


func _sync_collision_to_visual_frame(force: bool = false) -> void:
	if not source_masks.has(atlas_sequence):
		super._sync_collision_to_visual_frame(force)
		return
	var masks: Array = source_masks[atlas_sequence]
	var frame := int(floor(_elapsed * frame_fps))
	frame = frame % masks.size() if loop_visual else mini(frame, masks.size() - 1)
	var mask: Array = masks[frame]
	_current_frame_has_visual = not mask.is_empty()
	if mask.is_empty():
		_apply_collision_geometry(Vector2.ONE, Vector2.ZERO)
		return
	_apply_collision_geometry(
		Vector2(float(mask[2]), float(mask[3])),
		Vector2(float(mask[0]) + float(mask[2]) * 0.5, float(mask[1]) + float(mask[3]) * 0.5)
	)
