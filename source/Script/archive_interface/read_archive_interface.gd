extends Node2D

var initialized_data = {}
@onready var cd_number: LineEdit = $background/cd_number
@onready var all_ar: GridContainer = $ScrollContainer/AllAr


func _ready() -> void:
	MemoryClass.main_dq()
	add_ar()


func get_need_box():
	return int(MainSet.set_data["CdNum"])


func remove_ar():
	for i in all_ar.get_children():
		all_ar.remove_child(i)
		i.queue_free()


func add_ar():
	remove_ar()
	for i in range(get_need_box()):
		Global.add_basic_ar_button(all_ar, i + 1)


func _on_close_pressed() -> void:
	queue_free()


func _on_delete_pressed() -> void:
	if int(cd_number.text) > get_need_box() or int(cd_number.text) <= 0:
		Global.add_message_show(self, "找不到存档" + str(cd_number.text) + "的信息，请确保正确输入了存档号！！", 1.5)
		return
	if cd_number.text == "":
		Global.add_message_show(self, "找不到存档信息，请确保正确输入了存档号！！", 1.5)
		return
	else:
		var dialog = Global.add_choose_text(self, Vector2(0, 0), "确定要删除存档" + str(cd_number.text) + "吗？\n（删除后无法恢复！）", 0)
		if dialog != null:
			dialog.confirmed.connect(_remove_save_data)


func _remove_save_data():
	remove_data()
	var archive_path: String = "user://MyAr_" + str(int(cd_number.text)) + ".json"
	if not MemoryClass.safe_write_archive(archive_path, initialized_data):
		Global.add_message_show(self, "存档重置失败，请重试", 1.5)
		return
	add_ar()
	Global.add_message_show(self, "存档" + cd_number.text + "已重置为初始状态！！", 1.5)


func remove_data():
	initialized_data = PlayerData.initialized_data.duplicate(true)
	MemoryClass.remove_main_data(int(cd_number.text))

	MemoryClass.main_bc()


func remove_main_data(Num: int):
	if Num <= 6:
		MainSet.set_data["name" + str(Num)] = ""
		MainSet.set_data["time" + str(Num)] = ""
	else:
		MainSet.set_data["其他存档"][str(Num)]["name"] = ""
		MainSet.set_data["其他存档"][str(Num)]["time"] = ""


func get_time():
	var date = Time.get_date_string_from_system()
	var _time = Time.get_time_string_from_system()
	var last_time = date + " " + _time
	return last_time


func _on_addcd_pressed() -> void:
	MainSet.set_data["CdNum"] += 1
	Global.add_message_show(self, "添加成功，不要添加过多，以防卡顿！！", 1.5)
	MemoryClass.main_bc()
	add_ar()


func _on_removecd_pressed() -> void:
	if MainSet.set_data["CdNum"] <= 6:
		Global.add_message_show(self, "最少保留6个存档格子！！！", 1.5)
		return
	MainSet.set_data["CdNum"] -= 1
	MemoryClass.main_bc()
	add_ar()
