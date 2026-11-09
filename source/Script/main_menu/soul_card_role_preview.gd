## 7.4 魂卡穿戴页角色预览；复用当前背包场景与角色预览组件。
extends Node2D

const BACKPACK_PATH := "res://Scene/back_pack/back_pack.tscn"
const PREVIEW := preload("res://Script/back_pack/ne_zha_backpack_preview.gd")
var PlayerData: PlayerDataStore:
	get:
		return LocalCoop.data_for(self) as PlayerDataStore
var role_id := 1


func _ready() -> void:
	role_id = clampi(int(PlayerData.player_data.get("Myself", 1)), 1, 8)
	var source_scene := load(BACKPACK_PATH) as PackedScene
	if source_scene == null:
		return
	var source = source_scene.instantiate()
	var background = Node2D.new()
	background.name = "background"
	add_child(background)
	var body_origin: Vector2 = source.get_node("background/RoleBody").position
	for effect_name in ["gy0", "gy"]:
		var effect: Node2D = source.get_node("background/" + effect_name).duplicate(0)
		effect.position -= body_origin
		background.add_child(effect)
		if effect is AnimatedSprite2D:
			effect.play("gy")
	var wing_source = source.get_node("background/Wings")
	var wings = wing_source.duplicate(Node.DUPLICATE_SCRIPTS)
	wings.position -= source.get_node("background/RoleBody").position
	background.add_child(wings)
	for node_name in ["RoleBody", "RoleEquipment", "RoleBodyFront"]:
		var sprite: Sprite2D = source.get_node("background/" + node_name).duplicate(0)
		sprite.position = Vector2.ZERO
		background.add_child(sprite)
	var player: AnimationPlayer = source.get_node("background/Player").duplicate(0)
	background.add_child(player)
	var native_preview = PREVIEW.new()
	native_preview.name = "EquipmentPreview"
	background.add_child(native_preview)
	var wing_id: String = native_preview._equipped_name(DataKeys.Slot.WINGS)
	wings.visible = wing_id != "Empty" and bool(PlayerData.player_data.get(DataKeys.WINGS_SHOW, true))
	if wings.visible and wings.sprite_frames.has_animation(wing_id):
		wings.play(wing_id)
	Global.configure_backpack_role_preview(self)
	if role_id <= 5:
		var body_id: String = str(
			PlayerData.player_data.get(DataKeys.Storage.TRANSMOG_LIST, {}).get(DataKeys.Slot.ARMOR, "")
		)
		if body_id == "":
			var costumes: Array = PlayerData.player_data.get(DataKeys.Slot.FASHION, [])
			var armor: Array = PlayerData.player_data.get(DataKeys.Slot.ARMOR, [])
			body_id = (
				str(costumes[0].get(DataKeys.Item.NAME, "Empty"))
				if not costumes.is_empty()
				else str(armor[0].get(DataKeys.Item.NAME, "Empty")) if not armor.is_empty() else "Empty"
			)
		body_id = ItemUtils.clean_fashion_name(body_id)
		background.get_node("RoleBody").texture = Global.load_role1_body(body_id, role_id)
		background.get_node("RoleEquipment").texture = Global.load_role1_eq(
			native_preview._equipped_name(DataKeys.Slot.WEAPON), role_id
		)
		player.play("wait" if role_id == 1 else "wait%d" % role_id)
		player.advance(0.0)

		var body: Sprite2D = background.get_node("RoleBody")
		if not has_visible_body(body):
			body.texture = Global.load_role1_body("Empty", role_id)
		body.visible = true
	source.free()


static func has_visible_body(body: Sprite2D) -> bool:
	if body.texture == null:
		return false
	var frame_size = body.texture.get_size() / Vector2(body.hframes, body.vframes)
	var frame_origin = Vector2(body.frame_coords) * frame_size
	return body.texture.get_image().get_region(Rect2i(frame_origin, frame_size)).get_used_rect().has_area()
