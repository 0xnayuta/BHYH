extends Node2D
class_name BodyTrainingDetail

const DESIGN_SIZE := Vector2(940.0, 590.0)
const BODY_IDS := BodyTrainingData.BODY_IDS
const BODY_ICON_PATHS := [
	"res://Art/lianti/zodiac_1.png",
	"res://Art/lianti/zodiac_2.png",
	"res://Art/lianti/zodiac_3.png",
	"res://Art/lianti/zodiac_4.png",
	"res://Art/lianti/zodiac_5.png",
	"res://Art/lianti/zodiac_6.png",
	"res://Art/lianti/zodiac_7.png",
	"res://Art/lianti/zodiac_8.png",
	"res://Art/lianti/zodiac_9.png",
	"res://Art/lianti/zodiac_10.png",
	"res://Art/lianti/zodiac_11.png",
	"res://Art/lianti/zodiac_12.png",
]
const TRAINING_KEY := "炼体"

var selected_index := -1
var owner_page: Node = null
var body_data: Dictionary = {}
var message_layer: CanvasLayer = null

@onready var detail_icon: Sprite2D = $DetailIcon
@onready var detail_level: Label = $DetailLevel
@onready var detail_attribute: Label = $DetailAttribute
@onready var detail_attribute_next: Label = $DetailAttributeNext
@onready var detail_progress: Label = $DetailProgress
@onready var detail_material: Label = $DetailMaterial
@onready var detail_material_icon: Sprite2D = $DetailMaterialIcon


func _ready() -> void:
	z_index = 4096
	z_as_relative = false
	_fit_to_fullscreen()
	if not get_viewport().size_changed.is_connected(_fit_to_fullscreen):
		get_viewport().size_changed.connect(_fit_to_fullscreen)
	_ensure_body_data()
	if selected_index >= 0:
		_refresh()


func _exit_tree() -> void:
	if message_layer != null and is_instance_valid(message_layer):
		message_layer.queue_free()


func setup(page: Node, index: int) -> void:
	owner_page = page
	selected_index = index
	if is_node_ready():
		_ensure_body_data()
		_refresh()


func _fit_to_fullscreen() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var fit_scale: float = minf(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
	scale = Vector2(fit_scale, fit_scale)
	position = viewport_size * 0.5


func _ensure_body_data() -> void:
	body_data = BodyTrainingData.normalize_state(PlayerData.player_data.get(TRAINING_KEY, {}))
	PlayerData.player_data[TRAINING_KEY] = body_data


func _current_profile() -> Dictionary:
	var profile: Variant = body_data.get("p1", {})
	return profile if profile is Dictionary else {}


func _attribute_name(attribute: String) -> String:
	return {"hpMax": "生命", "mpMax": "魔法", "atk": "攻击", "def": "物防/魔防"}.get(attribute, attribute)


func _material_count(material_id: String) -> int:
	if PlayerData.has_method("get_item_data"):
		return int(PlayerData.get_item_data(material_id))
	return 0


func _refresh() -> void:
	if selected_index < 0 or selected_index >= BODY_IDS.size():
		return
	var body_id: int = BODY_IDS[selected_index]
	var config: Dictionary = BodyTrainingData.get_config(body_id)
	var entry: Dictionary = _current_profile().get(str(body_id), {})
	var level := int(entry.get("level", 0))
	var attribute := str(config.get("attributeT", ""))
	var max_level := int(config.get("levelMax", 25))
	detail_icon.texture = load(BODY_ICON_PATHS[selected_index]) as Texture2D
	detail_level.text = "等级%d" % level
	detail_attribute.text = "%s+%d" % [_attribute_name(attribute), BodyTrainingData.get_level_value(body_id, level)]
	detail_attribute_next.text = (
		"%s+%d" % [_attribute_name(attribute), BodyTrainingData.get_next_value(body_id, level)]
		if level < max_level
		else ""
	)
	var experience := int(entry.get("experience", 0))
	var exp_need := BodyTrainingData.get_train_requirement(int(config.get("expPos", 0)), level)
	detail_progress.text = "已满级" if level >= max_level else "%d/%d" % [experience, exp_need]
	var material_id := str(config.get("propId", ""))
	detail_material_icon.texture = load("res://Art/lianti/materials/%s.png" % material_id) as Texture2D
	detail_material.text = "%d/%d" % [_material_count(material_id), int(config.get("propNum", 1))]


func _train_once() -> int:
	if selected_index < 0 or selected_index >= BODY_IDS.size():
		return 0
	var body_id: int = BODY_IDS[selected_index]
	var config: Dictionary = BodyTrainingData.get_config(body_id)
	var profile := _current_profile()
	var key := str(body_id)
	var entry: Dictionary = profile.get(key, {})
	var level := int(entry.get("level", 0))
	var level_max := int(config.get("levelMax", 25))
	if level >= level_max:
		return 2
	var material_id := str(config.get("propId", ""))
	var material_need := int(config.get("propNum", 1))
	if _material_count(material_id) < material_need or not PlayerData.remove_item(material_id, material_need):
		return 0
	var exp_pos := int(config.get("expPos", 0))
	var exp_need := BodyTrainingData.get_train_requirement(exp_pos, level)
	var progress_gain := randi_range(25, 50)
	var experience := maxi(0, int(entry.get("experience", 0))) + progress_gain
	var leveled_up := experience >= exp_need
	if leveled_up:
		level += 1
		experience = 0
	entry["level"] = level
	entry["val"] = BodyTrainingData.get_level_value(body_id, level)
	entry["type"] = str(config.get("attributeT", ""))
	entry["experience"] = experience
	profile[key] = entry
	body_data["p1"] = profile
	PlayerData.player_data[TRAINING_KEY] = body_data
	return 1


func _finish_training_refresh() -> void:
	_save_if_possible()
	_refresh()
	if is_instance_valid(owner_page) and owner_page.has_method("refresh_from_detail"):
		owner_page.refresh_from_detail()


func _train() -> void:
	var result := _train_once()
	if result == 2:
		_show_message("该炼体已达最高等级")
		return
	if result == 0:
		_show_message("炼体材料不足")
		return
	_finish_training_refresh()
	_show_message("修炼成功")


func _train_all() -> void:
	var trained_count := 0
	while true:
		var result := _train_once()
		if result == 0 or result == 2:
			break
		trained_count += 1
	if trained_count == 0:
		_refresh()
		_show_message("炼体材料不足或已达最高等级")
		return
	_finish_training_refresh()
	_show_message("一键修炼完成，共修炼%d次" % trained_count)


func _on_train_button_pressed() -> void:
	_train()


func _on_train_all_button_pressed() -> void:
	_train_all()


func _on_close_pressed() -> void:
	queue_free()


func _ui_parent() -> Node:
	if Global.has_method("get_ui_popup_layer"):
		return Global.get_ui_popup_layer()
	if Global.windows != null:
		return Global.windows
	return get_parent() if get_parent() != null else self


func _show_message(message: String) -> void:
	var message_show: Node = Global.add_message_show(_ensure_message_layer(), message, 1.2, Vector2.ZERO) as Node
	if message_show is CanvasItem:
		message_show.z_index = 100000
		message_show.z_as_relative = false


func _ensure_message_layer() -> CanvasLayer:
	if message_layer != null and is_instance_valid(message_layer):
		return message_layer
	message_layer = CanvasLayer.new()
	message_layer.name = "BodyTrainingMessageLayer"
	message_layer.layer = 10000
	get_tree().root.add_child(message_layer)
	return message_layer


func _save_if_possible() -> void:
	if Global.is_archive_session_active():
		MemoryClass.request_save("body_training")
	else:
		MemoryClass.main_bc()
