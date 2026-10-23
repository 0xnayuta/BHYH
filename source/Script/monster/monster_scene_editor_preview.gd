@tool
extends Node2D

const GAME4_MONSTER_ROOT := "res://Art/monster/swf_png"
const MODEL_ID_ALIASES := {
	3043: 3031,
	3044: 3030,
	3045: 3032,
	3046: 3028,
	3053: 3047,
	3054: 3038,
	3055: 3036,
	3064: 3039,
	3072: 3065,
	3073: 3067,
	3074: 3068,
	3075: 3066,
}
const FRAME_CANDIDATES := [
	"preview.png",
	"wait/1.png",
	"idle/1.png",
	"fly_wait/1.png",
	"stand/1.png",
	"appear/1.png",
	"DefineSprite_70_mc_appear/51.png",
	"1.png",
]
const IDLE_ACTIONS: Array[StringName] = [&"wait", &"idle", &"fly_wait", &"stand", &"appear"]

static var _model_roots_by_id: Dictionary = {}
static var _texture_cache: Dictionary = {}


func _ready() -> void:
	if not Engine.is_editor_hint():
		queue_free()
		return
	call_deferred("_rebuild_preview")


func _rebuild_preview() -> void:
	if not Engine.is_editor_hint() or not is_inside_tree():
		return
	for child in get_children():
		child.free()

	var monster := _monster_root()
	if monster == null:
		return
	var monster_id := _monster_id(monster)
	if monster_id <= 0:
		return
	var constants := _script_constants(monster)
	var model_id := _model_id(monster_id, constants)
	var texture := _preview_texture(model_id)
	if texture == null:
		push_warning("No editor preview frame found for Monster_%d (model %d)" % [monster_id, model_id])
		return

	var alignment := _preview_alignment(monster, monster_id, model_id, constants, texture)
	var sprite := Sprite2D.new()
	sprite.name = "Model"
	sprite.texture = texture
	sprite.position = alignment["position"]
	sprite.flip_h = alignment["flip_h"]
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(sprite)
	_add_composite_parts(constants)


func _monster_root() -> Node:
	var candidate := get_parent()
	while candidate != null:
		if candidate is CharacterBody2D and str(candidate.name).begins_with("Monster_"):
			return candidate
		candidate = candidate.get_parent()
	return null


func _monster_id(monster: Node) -> int:
	var scene_name := str(monster.name)
	if scene_name.begins_with("Monster_"):
		return scene_name.trim_prefix("Monster_").to_int()
	return 0


func _script_constants(monster: Node) -> Dictionary:
	var monster_script := monster.get_script() as Script
	return monster_script.get_script_constant_map() if monster_script != null else {}


func _model_id(monster_id: int, constants: Dictionary) -> int:
	var model_map_value: Variant = constants.get("MODEL_BY_ENTITY", {})
	if model_map_value is Dictionary:
		var model_map := model_map_value as Dictionary
		if model_map.has(monster_id):
			return int(model_map[monster_id])
	return int(MODEL_ID_ALIASES.get(monster_id, monster_id))


func _preview_texture(model_id: int) -> Texture2D:
	if _texture_cache.has(model_id):
		return _texture_cache[model_id] as Texture2D
	for root_path in _model_roots(model_id):
		for relative_path in FRAME_CANDIDATES:
			var frame_path := root_path.path_join(relative_path)
			if not ResourceLoader.exists(frame_path):
				continue
			var texture := ResourceLoader.load(frame_path) as Texture2D
			if texture != null:
				_texture_cache[model_id] = texture
				return texture
	return null


func _model_roots(model_id: int) -> Array[String]:
	if _model_roots_by_id.has(model_id):
		var cached: Array[String] = _model_roots_by_id[model_id]
		return cached
	var roots: Array[String] = []
	var direct_root := GAME4_MONSTER_ROOT.path_join(str(model_id))
	if DirAccess.dir_exists_absolute(direct_root):
		roots.append(direct_root)
	for category_name in DirAccess.get_directories_at(GAME4_MONSTER_ROOT):
		var candidate := GAME4_MONSTER_ROOT.path_join(category_name).path_join(str(model_id))
		if DirAccess.dir_exists_absolute(candidate):
			roots.append(candidate)
	_model_roots_by_id[model_id] = roots
	return roots


func _preview_alignment(
	monster: Node, monster_id: int, model_id: int, constants: Dictionary, texture: Texture2D
) -> Dictionary:
	var visual_offset: Variant = _visual_offset(constants.get("VISUAL_OFFSETS"), monster_id, model_id)
	if visual_offset != null:
		var mirrored_offset := visual_offset as Vector2
		mirrored_offset.x = -mirrored_offset.x
		return {"position": mirrored_offset, "flip_h": true}

	var action_offset: Variant = _action_offset(constants.get("ACTIONS"), monster_id, model_id)
	if action_offset != null:
		return {"position": action_offset as Vector2, "flip_h": false}

	for position_name in [&"BODY_POSITION", &"IDLE_POSITION"]:
		var position_value: Variant = constants.get(position_name)
		if position_value is Vector2:
			return {"position": position_value as Vector2, "flip_h": false}

	var animated_sprite := monster.get_node_or_null("MonsterDir/mr_ani") as AnimatedSprite2D
	if animated_sprite != null and animated_sprite.position != Vector2.ZERO:
		return {"position": animated_sprite.position, "flip_h": animated_sprite.flip_h}
	return {"position": Vector2(0.0, -float(texture.get_height()) * 0.5), "flip_h": false}


func _visual_offset(value: Variant, monster_id: int, model_id: int) -> Variant:
	if not value is Dictionary:
		return null
	var offsets := value as Dictionary
	for id in [monster_id, model_id]:
		var nested: Variant = offsets.get(id)
		if nested is Dictionary:
			var result: Variant = _idle_offset(nested as Dictionary)
			if result != null:
				return result
	return _idle_offset(offsets)


func _action_offset(value: Variant, monster_id: int, model_id: int) -> Variant:
	if not value is Dictionary:
		return null
	var actions := value as Dictionary
	for id in [monster_id, model_id]:
		var nested: Variant = actions.get(id)
		if nested is Dictionary:
			actions = nested as Dictionary
			break
	for action_name in IDLE_ACTIONS:
		var action_value: Variant = actions.get(action_name)
		if action_value is Dictionary:
			var offset_value: Variant = (action_value as Dictionary).get("offset")
			if offset_value is Vector2:
				return offset_value
	return null


func _idle_offset(offsets: Dictionary) -> Variant:
	for action_name in IDLE_ACTIONS:
		var offset_value: Variant = offsets.get(action_name)
		if offset_value is Vector2:
			return offset_value
	return null


func _add_composite_parts(constants: Dictionary) -> void:
	var roots_value: Variant = constants.get("HEAD_ROOTS")
	var offsets_value: Variant = constants.get("HEAD_OFFSETS")
	var actions_value: Variant = constants.get("HEAD_ACTIONS")
	if not roots_value is Array or not offsets_value is Array or not actions_value is Dictionary:
		return
	var roots := roots_value as Array
	var offsets := offsets_value as Array
	var wait_action_value: Variant = (actions_value as Dictionary).get(&"wait")
	if not wait_action_value is Dictionary:
		return
	var folder := str((wait_action_value as Dictionary).get("folder", "idle"))
	for part_index in range(mini(roots.size(), offsets.size())):
		var part_offsets_value: Variant = offsets[part_index]
		if not part_offsets_value is Dictionary:
			continue
		var part_position: Variant = (part_offsets_value as Dictionary).get(&"wait")
		if not part_position is Vector2:
			continue
		var frame_path := str(roots[part_index]).path_join(folder).path_join("1.png")
		if not ResourceLoader.exists(frame_path):
			continue
		var texture := ResourceLoader.load(frame_path) as Texture2D
		if texture == null:
			continue
		var sprite := Sprite2D.new()
		sprite.name = "ModelPart%d" % (part_index + 1)
		sprite.texture = texture
		sprite.position = part_position as Vector2
		sprite.z_index = -1
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		add_child(sprite)
