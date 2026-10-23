extends AnimatedSprite2D

const FRAMES := preload("res://Art/equipment_effects/moon_palace/yuegong.tres")
const BODY_IDS := ["ygfjwk", "ygfjts", "ygfjbj", "ygfjss", "ygfjbl", "ygfjnz", "341071601"]

const FOOT_ORIGINS := {
	"ygfjwk": Vector2(5.5, 75),
	"ygfjts": Vector2(22.5, 64),
	"ygfjbj": Vector2(-5.5, 59),
	"ygfjss": Vector2(21.5, 69),
	"ygfjbl": Vector2(33.5, 109),
	"ygfjnz": Vector2(0, 188),
	"341071601": Vector2(0, 188),
}
var body_sprite: Sprite2D
var equipment_id := ""
var combat := false


static func sync(body: Sprite2D, item_id: String, in_combat := false) -> void:
	if body == null:
		return
	var effect := body.get_node_or_null("MoonPalaceClothesEffect")
	if effect == null and not BODY_IDS.has(item_id):
		return
	if effect == null:
		effect = load("res://Script/hero/moon_palace_clothes_effect.gd").new()
		effect.name = "MoonPalaceClothesEffect"
		effect.body_sprite = body
		body.add_child(effect)
	effect.equipment_id = item_id

	effect.flip_h = item_id not in ["ygfjnz", "341071601"]
	effect.combat = in_combat
	effect.visible = BODY_IDS.has(item_id)
	effect._process(0.0)


func _ready() -> void:
	sprite_frames = FRAMES
	flip_h = true

	z_index = 1
	process_priority = 100
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	play(&"idle")


func _process(_delta: float) -> void:
	if not visible or body_sprite.texture == null:
		return
	var feet: Vector2 = FOOT_ORIGINS.get(equipment_id, Vector2.ZERO)
	position = body_sprite.offset + feet + Vector2(-3.5, -50.95)
	scale = Vector2(1.1, 1.1)


static func equipped_body() -> String:
	var data: Dictionary = PlayerData.player_data
	var appearance := str(data.get(DataKeys.TRANSMOG_LIST, {}).get(DataKeys.ARMOR, ""))
	if appearance != "":
		return appearance
	for slot in ["时装", "防具"]:
		var items: Array = data.get(slot, [])
		if not items.is_empty() and items[0] is Dictionary:
			return str(items[0].get(DataKeys.NAME, "Empty"))
	return "Empty"
