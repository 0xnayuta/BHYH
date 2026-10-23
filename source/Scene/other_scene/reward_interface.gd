extends Node2D
@onready var item_grid_container: GridContainer = $Wkbg/ScrollContainer/ItemList
@onready var title: Label = $Wkbg/Title
@onready var pl: AnimationPlayer = $pl

var use_item_name
var use_num
var reward_items: Array = []
var item_info = {"Name": "ryjgb", "Value": 4, "Prop": {}, "WX": [], "strength_value": 0}


func _process(delta: float) -> void:
	add_item_to_backpack()
	if use_item_name != null and use_num != null:
		_remove_used_item(use_item_name, use_num)
	MemoryClass.save_game(Global.cd_path)
	set_process(false)


func _physics_process(delta: float) -> void:
	if use_item_name != null and use_num != null:
		title.text = "本次使用：" + str(AE.all_equipment[use_item_name][DataKeys.NAME]) + " * " + str(use_num)
	else:
		title.text = ""
	pl.play("pl")
	add_box()
	set_physics_process(false)


func add_box():
	var tween = create_tween()
	for i in reward_items:
		var type = AE.all_equipment[i["Name"]][DataKeys.TYPE]
		var item_name = i["Name"]
		var value = i["Value"]
		var strength_value = i["strength_value"]
		var prop = i["Prop"]
		var _wx = i["WX"]
		var box = Global.add_reward_box(item_grid_container, item_name, value)
		box.modulate = Color(1, 1, 1, 0)
		tween.tween_property(box, "modulate", Color(1, 1, 1, 1), 0.2)


func _remove_used_item(item_name, use_num) -> void:
	if not AE.all_equipment.has(item_name):
		return
	var item_type = AE.all_equipment[item_name][DataKeys.TYPE]
	match item_type:
		"道具":
			PlayerData.remove_dj(item_name, PlayerData.get_dj_page(item_name), use_num)
		"消耗品":
			PlayerData.remove_xhp(item_name, PlayerData.get_xhp_page(item_name), use_num)


func add_item_to_backpack():
	for i in reward_items:
		var type = AE.all_equipment[i["Name"]][DataKeys.TYPE]
		var item_name = i["Name"]
		var value = i["Value"]
		var strength_value = i["strength_value"]
		var prop = i["Prop"]
		var _wx = i["WX"]
		if value <= 0:
			value = 1
		match type:
			"武器", "防具", "饰品", "神骨", "翅膀", "头衔", "时装":
				for u in range(value):
					PlayerData.add_zb(item_name, strength_value, prop)
			"法宝":
				for u in range(value):
					PlayerData.add_fb(item_name, strength_value, _wx, prop)
			"道具":
				PlayerData.add_dj(item_name, value)
			"消耗品":
				PlayerData.add_xhp(item_name, value)
	MemoryClass.save_game(Global.cd_path)


func _on_close_pressed() -> void:
	queue_free()
