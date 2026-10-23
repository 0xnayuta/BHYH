extends RefCounted

const PARTS := preload("res://Script/hero/yutu_official_parts.gd")
const TRANSPARENT := preload("res://Art/hero_picture/role_6/official_parts_trial/transparent.tres")


static func preview(
	body: Sprite2D, weapon: Sprite2D, front: Sprite2D, seconds: float, offset_y: float = -135.0
) -> void:
	if body == null:
		return
	if body.get_script() != PARTS:
		body.set_script(PARTS)
		body.call("load_set", "default")
	body.hframes = 1
	body.vframes = 1
	body.frame = 0
	body.texture = TRANSPARENT
	body.offset = Vector2(0, offset_y)
	body.scale = Vector2(-1.1, 1.1)
	body.visible = true
	var body_id := preload("res://Script/hero/moon_palace_clothes_effect.gd").equipped_body()
	var weapon_id := str(PlayerData.player_data.get("幻化列表", {}).get("武器", ""))
	var equipped: Array = PlayerData.player_data.get("武器", [])
	if weapon_id == "" and not equipped.is_empty():
		weapon_id = str(equipped[0].get("名字", "Empty"))
	if body.get("body_equipment") != body_id or body.get("weapon_equipment") != weapon_id:
		body.call("set_equipment", body_id, weapon_id)
	preload("res://Script/hero/moon_palace_clothes_effect.gd").sync(body, body_id)
	body.call("set_time", "wait", seconds)
	if weapon != null:
		weapon.visible = false
	if front != null:
		front.visible = false
