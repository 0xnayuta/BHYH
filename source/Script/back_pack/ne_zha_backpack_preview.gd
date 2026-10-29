extends Node

## 显式操作者：按所在面板的槽位解析数据与属性，不依赖全局 1P/2P 视图交换。
var PlayerData: PlayerDataStore:
	get:
		return LocalCoop.data_for(self) as PlayerDataStore
var RoleProp: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self) as BaseRoleProperties


func _get_body_frames(equipment_id: String) -> SpriteFrames:
	return NeZhaEquipmentVisuals.get_body_frames(equipment_id)


func _get_weapon_frames(equipment_id: String) -> SpriteFrames:
	return NeZhaEquipmentVisuals.get_weapon_frames(equipment_id)


func _get_body_front_frames(equipment_id: String) -> SpriteFrames:
	return NeZhaEquipmentVisuals.get_body_front_frames(equipment_id)


@onready var role_body: Sprite2D = get_node("../RoleBody")
@onready var role_equipment: Sprite2D = get_node("../RoleEquipment")
@onready var role_body_front: Sprite2D = get_node("../RoleBodyFront")

var _elapsed: float = 0.0


func _equipped_name(slot_name: String) -> String:
	var transmog_value: Variant = PlayerData.player_data.get(DataKeys.TRANSMOG_LIST, {}).get(slot_name, "")
	if str(transmog_value) != "":
		return str(transmog_value)
	var slot_value: Variant = PlayerData.player_data.get(slot_name, [])
	if slot_value is Array and not (slot_value as Array).is_empty():
		var item_value: Variant = (slot_value as Array)[0]
		if item_value is Dictionary:
			return str((item_value as Dictionary).get(DataKeys.NAME, "Empty"))
	return "Empty"


func _process(delta: float) -> void:
	var clothes_effect := preload("res://Script/hero/moon_palace_clothes_effect.gd")
	if int(PlayerData.player_data.get("Myself", 1)) == 7:
		_elapsed += delta
		preload("res://Script/hero/yutu_visuals.gd").preview(role_body, role_equipment, role_body_front, _elapsed)
		return
	if int(PlayerData.player_data.get("Myself", 1)) != 6:
		clothes_effect.sync(role_body, clothes_effect.equipped_body())
		return
	var body_id := _equipped_name("时装")
	if body_id == "Empty":
		body_id = _equipped_name("防具")
	var weapon_id := _equipped_name("武器")
	var body_frames := _get_body_frames(body_id)
	var body_front_frames := _get_body_front_frames(body_id)
	var weapon_frames := _get_weapon_frames(weapon_id)
	var frame_count := body_frames.get_frame_count(&"wait")
	if frame_count <= 0:
		return
	_elapsed += delta
	var frame_index := int(_elapsed * body_frames.get_animation_speed(&"wait")) % frame_count
	role_body.hframes = 1
	role_body.vframes = 1
	role_body.frame = 0
	role_body.texture = body_frames.get_frame_texture(&"wait", frame_index)
	role_body.scale = Vector2(-1.1, 1.1)
	role_body.offset = Vector2(5, -119)
	role_body.visible = true
	role_equipment.hframes = 1
	role_equipment.vframes = 1
	role_equipment.frame = 0
	role_equipment.texture = weapon_frames.get_frame_texture(&"wait", frame_index)
	role_equipment.scale = role_body.scale
	role_equipment.offset = role_body.offset
	role_equipment.visible = true
	role_body_front.hframes = 1
	role_body_front.vframes = 1
	role_body_front.frame = 0
	role_body_front.texture = body_front_frames.get_frame_texture(&"wait", frame_index)
	role_body_front.scale = role_body.scale
	role_body_front.offset = role_body.offset
	role_body_front.visible = true
	clothes_effect.sync(role_body, body_id)
