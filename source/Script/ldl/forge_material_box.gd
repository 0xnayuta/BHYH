extends TextureRect

@onready var need_and_have: Label = $NeedAndHave
@onready var box: VBoxContainer = $Box

var item_name: String
var need_num: int


func _physics_process(delta: float) -> void:
	if need_num == 0:
		need_and_have.text = ""
	else:
		set_box()
		set_text()
	set_physics_process(false)


func set_text():
	if need_num != 0:
		if PlayerData.get_item_data(item_name) >= need_num:
			need_and_have.add_theme_color_override("font_color", "00ff00")
		else:
			need_and_have.add_theme_color_override("font_color", "ff0000")
		need_and_have.text = str(PlayerData.get_item_data(item_name)) + "/" + str(need_num)


func set_box():
	var item_box = Global.add_item_box(box, true, true, item_name, 0, 1, [], AE.all_equipment[item_name])
	if item_box == null or not is_instance_valid(item_box):
		return
	var icon_path := "res://Art/backpack/all_items/%s.png" % str(item_name)
	item_box.set("icon", ResourceLoader.load(icon_path) as Texture2D if ResourceLoader.exists(icon_path) else null)


func load_item_icon(_name):
	var abc = load("res://Art/backpack/all_items/" + str(_name) + ".png")
	return abc
