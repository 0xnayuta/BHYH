extends Node2D
@onready var item_list = $BG/ItemList
var _list = []
var current_choose: int = -1
var is_set = false
var _name: String
var _page: int


func _physics_process(_delta: float) -> void:
	if not is_set:
		_add_item()
		is_set = true


func _add_item():
	for i in _list.size():
		item_list.add_item(get_item_name(i), load_item_icon(get_item(i)), true)


func get_item(idx):
	var _name_value
	_name_value = _list[idx][DataKeys.NAME]
	return _name_value


func get_item_name(idx):
	var _name_value
	_name_value = _list[idx][DataKeys.NAME]
	var name_text = AE.all_equipment[_name_value][DataKeys.NAME]
	var lx = AE.all_equipment[_name_value][DataKeys.TYPE]
	var get_num = get_item_num(idx)
	var wxx = get_wx_text(idx)

	match lx:
		"武器", "防具", "饰品":
			if get_num > 0:
				name_text = name_text + " (+" + str(get_num) + ")"
		"法宝":
			if wxx != "":
				if get_num > 0:
					name_text = name_text + " (+" + str(get_num) + ")" + "(" + str(wxx) + ")"
				else:
					name_text = name_text + str(wxx)
			else:
				if get_num > 0:
					name_text = name_text + " (+" + str(get_num) + ")"
				else:
					name_text = name_text
		"道具", "消耗品":
			if get_num > 0:
				name_text = name_text + " * " + str(get_num) + "个"
	return name_text


func get_wx_text(idx):
	var get_xx
	get_xx = _list[idx][DataKeys.FIVE_ELEMENTS]
	var wx: String = ""
	if get_xx.size() > 0:
		if get_xx.size() == 1:
			wx = str(get_xx[0])
		else:
			for i in get_xx:
				wx = wx + str(i)
	return wx


func get_wx(idx):
	var _roll_element
	_roll_element = _list[idx][DataKeys.FIVE_ELEMENTS]
	if _roll_element.size() == 0:
		_roll_element = _roll_element()
	return _roll_element


func get_item_num(idx):
	var _num = _list[idx]["num"]
	return _num


func load_item_icon(_name_value):
	var abc = load("res://Art/backpack/all_items/" + str(_name_value) + ".png")
	return abc


func _on_item_list_item_selected(index: int) -> void:
	current_choose = int(index)


func _on_qd_pressed() -> void:
	if current_choose >= 0:
		var names
		names = _list[current_choose][DataKeys.NAME]
		var lx = AE.all_equipment[names][DataKeys.TYPE]
		var get_num = get_item_num(current_choose)
		var _roll_element = get_wx(current_choose)
		var list = [{"Name": names, "Value": get_num, "Prop": {}, "WX": Global.get_wx(0), "strength_value": 0}]
		Global.add_reward_info(Global.get_ancestor(self, 1), Vector2(0, 0), list, _name, 1)

	queue_free()


func _roll_element():
	randomize()
	var wx = {"金": false, "木": false, "水": false, "火": false, "土": false}
	var rr = randi_range(0, 100)
	if rr <= 10:
		var wx_lst = ["金", "木", "水", "火", "土"]
		var aa = randi_range(0, 4)
		var wx_1 = wx_lst[aa]
		wx_lst.erase(wx_1)
		var bb = randi_range(0, 3)
		var wx_2 = wx_lst[bb]
		wx_lst.erase(wx_2)
		var cc = randi_range(0, 2)
		var wx_3 = wx_lst[cc]
		wx[wx_1] = true
		wx[wx_2] = true
		wx[wx_3] = true
		var new_list = []
		for i in wx:
			if wx[i]:
				new_list.push_back(i)
		return new_list
	elif rr > 10 and rr < 30:
		var wx_lst = ["金", "木", "水", "火", "土"]
		var aa = randi_range(0, 4)
		var wx_1 = wx_lst[aa]
		wx_lst.erase(wx_1)
		var bb = randi_range(0, 3)
		var wx_2 = wx_lst[bb]
		wx[wx_1] = true
		wx[wx_2] = true
		var new_list = []
		for i in wx:
			if wx[i]:
				new_list.push_back(i)
		return new_list
	else:
		var new_list = []
		var wx_lst = ["金", "木", "水", "火", "土"]
		var aa = randi_range(0, 4)
		new_list.push_back(wx_lst[aa])
		return new_list


func _on_qx_pressed() -> void:
	queue_free()


func _on_close_pressed() -> void:
	queue_free()
