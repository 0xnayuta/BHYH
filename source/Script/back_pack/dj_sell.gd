extends Control
const LOCK_BUTTON_ICON = preload("res://Art/backpack/dj_lock_button.png")
const UNLOCK_BUTTON_ICON = preload("res://Art/backpack/dj_unlock_button.png")

@onready var v_box_container: VBoxContainer = $MarginContainer2/MarginContainer/VBoxContainer
@onready var infor: Label = $MarginContainer2/MarginContainer/VBoxContainer/infor
@onready var sell_number: LineEdit = $MarginContainer2/MarginContainer/VBoxContainer/sell_number
@onready var use: TextureButton = $MarginContainer2/MarginContainer/VBoxContainer/use
@onready var sell: Button = $MarginContainer2/MarginContainer/VBoxContainer/sell
var choose_jm
var source_box: Node = null
var outside_click_enabled: bool = false

var my_name
var my_page
var be_number = 0
var is_set = false
var eq_prop = {}

@onready var lock_button: Button = $MarginContainer2/MarginContainer/VBoxContainer/lock


func _ready() -> void:
	call_deferred("_enable_outside_click")


func _enable_outside_click() -> void:
	outside_click_enabled = true


func _input(event: InputEvent) -> void:
	if not outside_click_enabled or not is_visible_in_tree():
		return
	var click_position := Vector2.ZERO
	if event is InputEventMouseButton:
		if not event.pressed or event.button_index != MOUSE_BUTTON_LEFT:
			return
		click_position = event.position
	elif event is InputEventScreenTouch:
		if not event.pressed:
			return
		click_position = event.position
	else:
		return
	if not _control_has_point($MarginContainer2, click_position) and not _control_has_point($close_btn, click_position):
		queue_free()


func _control_has_point(control: Control, screen_position: Vector2) -> bool:
	var local_position := control.get_global_transform_with_canvas().affine_inverse() * screen_position
	return Rect2(Vector2.ZERO, control.size).has_point(local_position)


func _physics_process(_delta: float) -> void:
	infor.text = "名字：" + str(AE.all_equipment[my_name][DataKeys.NAME])
	if AE.all_equipment[my_name][DataKeys.TYPE] == "道具" and is_set == false:
		use.disabled = true
		is_set = true
	be_number = int(sell_number.text)
	_refresh_lock_button()


func _get_inventory_entry() -> Dictionary:
	var list_name := "道具列表" if AE.all_equipment[my_name][DataKeys.TYPE] == "道具" else "消耗品列表"
	var pages: Variant = PlayerData.player_data.get(list_name, {})
	if not pages is Dictionary:
		return {}
	var items: Variant = pages.get("页码" + str(my_page), [])
	if not items is Array:
		return {}
	for item in items as Array:
		if item is Dictionary and str(item.get(DataKeys.NAME, "")) == str(my_name):
			return item as Dictionary
	return {}


func _is_locked() -> bool:
	return bool(_get_inventory_entry().get("锁定", false))


func _refresh_lock_button() -> void:
	if lock_button == null:
		return
	var locked := _is_locked()
	lock_button.icon = UNLOCK_BUTTON_ICON if locked else LOCK_BUTTON_ICON
	lock_button.tooltip_text = "解锁后才能出售" if locked else "锁定物品，禁止出售"
	if source_box != null and is_instance_valid(source_box):
		source_box.item_locked = locked


func _on_lock_pressed() -> void:
	var item := _get_inventory_entry()
	if item.is_empty():
		return
	item["锁定"] = not bool(item.get("锁定", false))
	MemoryClass.save_game(Global.cd_path)
	_refresh_lock_button()


func _on_close_pressed():
	queue_free()


func _on_sell_number_text_change_rejected(rejected_substring: String) -> void:
	be_number = int(rejected_substring)


func _get_sell_count() -> int:
	var requested_text := sell_number.text.strip_edges()
	if requested_text.is_empty():
		return maxi(0, int(_get_inventory_entry().get(DataKeys.COUNT, 0)))
	return maxi(0, int(requested_text))


func _on_sell_pressed() -> void:
	if _is_locked():
		Global.add_message_show(Global.get_ui_popup_layer(), "该物品已锁定，请先解锁后再出售！", 1.5, Vector2.ZERO)
		return
	be_number = _get_sell_count()
	var type = AE.all_equipment[my_name][DataKeys.TYPE]
	match type:
		"道具":
			var get_list = PlayerData.remove_dj(my_name, my_page, be_number)
			if be_number > 0 and int(get_list["获得灵魂"]) > 0:
				var _name = AE.all_equipment[my_name][DataKeys.NAME]
				var parent = get_parent().get_parent().get_parent()
				Global.add_message_show(
					parent,
					"丢弃：" + str(get_list["卖出数量"]) + "个" + str(_name) + "。  获得：" + str(get_list["获得灵魂"]) + "灵魂。",
					1.5,
					Vector2(480, 280)
				)
			PlayerData.zl_dj()
			MemoryClass.save_game(Global.cd_path)
			queue_free()
		"消耗品":
			var get_list = PlayerData.remove_xhp(my_name, my_page, be_number)
			if be_number > 0 and int(get_list["获得灵魂"]) > 0:
				var _name = AE.all_equipment[my_name][DataKeys.NAME]
				var parent = get_parent().get_parent().get_parent()
				Global.add_message_show(
					parent,
					"丢弃：" + str(get_list["卖出数量"]) + "个" + str(_name) + "。  获得：" + str(get_list["获得灵魂"]) + "灵魂。",
					1.5,
					Vector2(480, 280)
				)
			PlayerData.zl_xhp()
			MemoryClass.save_game(Global.cd_path)
			queue_free()


func _on_use_pressed() -> void:
	if be_number <= 1:
		be_number = 1

	if be_number >= PlayerData.get_xhp_data(my_name):
		be_number = PlayerData.get_xhp_data(my_name)
	use_xhp()


func _on_panel_mouse_exited() -> void:
	queue_free()


func use_mpyj():
	for i in PlayerData.player_data[DataKeys.SKILL_LEARNED]:
		if PlayerData.player_data[DataKeys.SKILL_LEARNED][i].has(DataKeys.LEVEL):
			if PlayerData.player_data[DataKeys.SKILL_LEARNED][i][DataKeys.LEVEL] > 1:
				PlayerData.player_data[DataKeys.SKILL_LEARNED][i][DataKeys.LEVEL] = 1
	PlayerData.remove_xhp(my_name, my_page, 1)
	var parent = get_parent().get_parent().get_parent()
	Global.add_message_show(parent, "技能等级已重置！。", 1.5, Vector2(450, 300))
	queue_free()


func use_xhp():
	match my_name:
		"yll":
			if PlayerData.player_data["望乡台"] == 1:
				PlayerData.remove_xhp(my_name, my_page, 1)
				Global.cleanup_transient_ui()
				Global.change_scene("res://Scene/level/level_eighteenth_hell.tscn")
				return
			else:
				var parent = get_parent().get_parent().get_parent()
				Global.add_message_show(parent, "需通关“奈何桥“！！。", 1.5, Vector2(450, 300))
		"mpyj":
			self.visible = false
			Signals.connect_choose_box_signal(self, "use_mpyj")
			choose_jm = Global.add_choose_text(
				Global.get_ancestor(self, 3), Vector2(0, 0), "确定使用孟婆药剂吗，所有高于1级的技能等级将清除为1（不返还灵魂）？", 0
			)
		"qhsbx":
			var a = Global.get_all_item_num(["qhs_1", "qhs_2", "qhs_3", "qhs_4"], be_number, randi_range(3, 4))
			Global.add_reward_info(Global.get_ancestor(self, 3), Vector2(0, 0), a, my_name, be_number)
			queue_free()
		"hhbx":
			var a = Global.get_all_item_num(
				[
					"qhs_1",
					"qhs_2",
					"qhs_3",
					"qhs_4",
					"bsz",
					"c",
					"ch",
					"t",
					"hshb",
					"lshb",
					"zshb",
					"yazfw",
					"yizfw",
					"fygwj",
					"jssp",
					"lssp",
					"qssp",
					"yll",
					"zxbx_1",
					"zxbx_2",
					"zxbx_3"
				],
				be_number,
				randi_range(1, 1)
			)
			Global.add_reward_info(Global.get_ancestor(self, 3), Vector2(0, 0), a, my_name, be_number)
			queue_free()

		"jsbx_1":
			var choice_item_list = [
				{"名字": "gjjs_1", "num": 6, "五行": []},
				{"名字": "smjs_1", "num": 6, "五行": []},
				{"名字": "mfjs_1", "num": 6, "五行": []},
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"jsbx_2":
			var choice_item_list = [
				{"名字": "gjjs_2", "num": 6, "五行": []},
				{"名字": "smjs_2", "num": 6, "五行": []},
				{"名字": "mfjs_2", "num": 6, "五行": []},
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"jsbx_3":
			var choice_item_list = [
				{"名字": "gjjs_3", "num": 6, "五行": []},
				{"名字": "smjs_3", "num": 6, "五行": []},
				{"名字": "mfjs_3", "num": 6, "五行": []},
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()

		"zxbx_1":
			var choice_item_list = [
				{"名字": "qhs_1", "num": 5, "五行": []},
				{"名字": "qhs_2", "num": 2, "五行": []},
				{"名字": "qhs_3", "num": 1, "五行": []},
				{"名字": "qhs_4", "num": 1, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"zxbx_2":
			var choice_item_list = [
				{"名字": "qld", "num": 0, "五行": []},
				{"名字": "hdc", "num": 0, "五行": []},
				{"名字": "bhz", "num": 0, "五行": []},
				{"名字": "zhp", "num": 0, "五行": []},
				{"名字": "twq", "num": 0, "五行": []},
				{"名字": "ryjgb", "num": 0, "五行": []},
				{"名字": "jcdp", "num": 0, "五行": []},
				{"名字": "jhcz", "num": 0, "五行": []},
				{"名字": "qxsh", "num": 0, "五行": []},
				{"名字": "jlxmc", "num": 0, "五行": []},
				{"名字": "qthbq", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"zxbx_3":
			var choice_item_list = [
				{"名字": "qld", "num": 0, "五行": []},
				{"名字": "hdc", "num": 0, "五行": []},
				{"名字": "bhz", "num": 0, "五行": []},
				{"名字": "zhp", "num": 0, "五行": []},
				{"名字": "twq", "num": 0, "五行": []},
				{"名字": "ryjgb", "num": 0, "五行": []},
				{"名字": "jcdp", "num": 0, "五行": []},
				{"名字": "jhcz", "num": 0, "五行": []},
				{"名字": "qxsh", "num": 0, "五行": []},
				{"名字": "jlxmc", "num": 0, "五行": []},
				{"名字": "qthbq", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"mhwbx":
			var choice_item_list = [
				{"名字": "dszy", "num": 0, "五行": []},
				{"名字": "dslq", "num": 0, "五行": []},
				{"名字": "dshp", "num": 0, "五行": []},
				{"名字": "dslj", "num": 0, "五行": []},
				{"名字": "210007001", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"yrwbx":
			var choice_item_list = [
				{"名字": "dsyj", "num": 0, "五行": []},
				{"名字": "dsqz", "num": 0, "五行": []},
				{"名字": "jmc", "num": 0, "五行": []},
				{"名字": "zhj", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"bfsxbx":
			var choice_item_list = [
				{"名字": "whg", "num": 0, "五行": []},
				{"名字": "wtp", "num": 0, "五行": []},
				{"名字": "bsp", "num": 0, "五行": []},
				{"名字": "211007001", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"stwbx":
			var choice_item_list = [
				{"名字": "jcjp", "num": 0, "五行": []},
				{"名字": "jcbj", "num": 0, "五行": []},
				{"名字": "jcmc", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"pmwbx":
			var choice_item_list = [
				{"名字": "jcjs", "num": 0, "五行": []},
				{"名字": "jcsz", "num": 0, "五行": []},
				{"名字": "jclj", "num": 0, "五行": []},
				{"名字": "210007002", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"jmwbx":
			var choice_item_list = [
				{"名字": "xwj", "num": 0, "五行": []},
				{"名字": "pxk", "num": 0, "五行": []},
				{"名字": "bxp", "num": 0, "五行": []},
				{"名字": "211007002", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"smwbx":
			var choice_item_list = [
				{"名字": "qlp", "num": 0, "五行": []}, {"名字": "zqj", "num": 0, "五行": []}, {"名字": "ttj", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()

		"hhebx":
			var choice_item_list = [{"名字": "jgj", "num": 0, "五行": []}, {"名字": "ssj", "num": 0, "五行": []}]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()

		"syrbx":
			var choice_item_list = [
				{"名字": "jmy", "num": 0, "五行": []},
				{"名字": "lzp", "num": 0, "五行": []},
				{"名字": "221007001", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()

		"hbwcbx":
			var choice_item_list = [{"名字": "yhj", "num": 0, "五行": []}, {"名字": "tsgl", "num": 0, "五行": []}]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"bgjbx1":
			var choice_item_list = [
				{"名字": "bsxj", "num": 0, "五行": []},
				{"名字": "bszj", "num": 0, "五行": []},
				{"名字": "bsyz", "num": 0, "五行": []},
				{"名字": "bsbc", "num": 0, "五行": []},
				{"名字": "bshq", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"bgjbx2":
			var choice_item_list = [
				{"名字": "bsxj", "num": 0, "五行": []},
				{"名字": "bszj", "num": 0, "五行": []},
				{"名字": "bsyz", "num": 0, "五行": []},
				{"名字": "bsbc", "num": 0, "五行": []},
				{"名字": "bshq", "num": 0, "五行": []},
				{"名字": "csgs", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"klwbx":
			var choice_item_list = [{"名字": "lcgy", "num": 0, "五行": []}, {"名字": "tsgp", "num": 0, "五行": []}]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"qgwbx":
			var choice_item_list = [
				{"名字": "tsyj", "num": 0, "五行": []},
				{"名字": "gtc", "num": 0, "五行": []},
				{"名字": "220007001", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"pgbx":
			var choice_item_list = [{"名字": "tsyp", "num": 0, "五行": []}, {"名字": "lcld", "num": 0, "五行": []}]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"ylwbx":
			var choice_item_list = [
				{"名字": "fygwj", "num": 0, "五行": []},
				{"名字": "lchp", "num": 0, "五行": []},
				{"名字": "221007002", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"ycbx":
			var choice_item_list = [
				{"名字": "lczh", "num": 0, "五行": []},
				{"名字": "xhmj", "num": 0, "五行": []},
				{"名字": "xhxc", "num": 0, "五行": []},
				{"名字": "220007002", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"mpbx":
			var choice_item_list = [
				{"名字": "xhgp", "num": 0, "五行": []},
				{"名字": "xhxh", "num": 0, "五行": []},
				{"名字": "xhymk", "num": 0, "五行": []},
				{"名字": "xhyk", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"zlwbx":
			var choice_item_list = [
				{"名字": "myz", "num": 0, "五行": []},
				{"名字": "nyd", "num": 0, "五行": []},
				{"名字": "syc", "num": 0, "五行": []},
				{"名字": "shyc", "num": 0, "五行": []},
				{"名字": "xyq", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"xtbx":
			var choice_item_list = [
				{"名字": "qtz", "num": 0, "五行": []},
				{"名字": "dszk", "num": 0, "五行": []},
				{"名字": "jljs", "num": 0, "五行": []},
				{"名字": "lhz", "num": 0, "五行": []},
				{"名字": "tpzy", "num": 0, "五行": []},
				{"名字": "tpltp", "num": 0, "五行": []},
				{"名字": "jlfyc", "num": 0, "五行": []},
				{"名字": "jlfyj", "num": 0, "五行": []},
				{"名字": "ylhq", "num": 0, "五行": []},
				{"名字": "yljj", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()

		"qlysfebx":
			var choice_item_list = [
				{"名字": "kyz", "num": 0, "五行": []},
				{"名字": "kyc", "num": 0, "五行": []},
				{"名字": "kys", "num": 0, "五行": []},
				{"名字": "xhz", "num": 0, "五行": []},
				{"名字": "231007001", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"jlsbx":
			var choice_item_list = [
				{"名字": "xhp", "num": 0, "五行": []},
				{"名字": "xhc", "num": 0, "五行": []},
				{"名字": "xhj", "num": 0, "五行": []},
				{"名字": "230007001", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"zztwbx":
			var choice_item_list = [
				{"名字": "qybd", "num": 0, "五行": []},
				{"名字": "qyfp", "num": 0, "五行": []},
				{"名字": "qysq", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"gmtwbx":
			var choice_item_list = [{"名字": "hylk", "num": 0, "五行": []}, {"名字": "qysz", "num": 0, "五行": []}]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"dwtwbx":
			var choice_item_list = [
				{"名字": "hylz", "num": 0, "五行": []},
				{"名字": "hylc", "num": 0, "五行": []},
				{"名字": "231007002", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"zzzbx":
			var choice_item_list = [
				{"名字": "zjqj", "num": 0, "五行": []},
				{"名字": "zjksf", "num": 0, "五行": []},
				{"名字": "zjgp", "num": 0, "五行": []},
				{"名字": "zjxmczzs", "num": 0, "五行": []},
				{"名字": "hljhzzs", "num": 0, "五行": []},
				{"名字": "230007002", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"yhbx":
			var choice_item_list = [
				{"名字": "jllm", "num": 0, "五行": []},
				{"名字": "smz", "num": 0, "五行": []},
				{"名字": "zjbtgzzs", "num": 0, "五行": []},
				{"名字": "wsjgzzs", "num": 0, "五行": []},
				{"名字": "blmqzzs", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"txsbx":
			var choice_item_list = [
				{"名字": "eyzzs", "num": 0, "五行": []},
				{"名字": "tzzzs", "num": 0, "五行": []},
				{"名字": "yjzzs", "num": 0, "五行": []},
				{"名字": "zezzs", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"lzzbx":
			var choice_item_list = [
				{"名字": "tczzs", "num": 0, "五行": []},
				{"名字": "czzzs", "num": 0, "五行": []},
				{"名字": "thzzs", "num": 0, "五行": []},
				{"名字": "tqzzs", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"nzbx":
			var choice_item_list = [
				{"名字": "rls", "num": 0, "五行": []},
				{"名字": "ryzzs", "num": 0, "五行": []},
				{"名字": "tszzs", "num": 0, "五行": []},
				{"名字": "230007003zzs", "num": 0, "五行": []},
				{"名字": "231007003zzs", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"qnjbx":
			var choice_item_list = [
				{"名字": "qljzzs", "num": 0, "五行": []},
				{"名字": "plpzzs", "num": 0, "五行": []},
				{"名字": "ylkzzs", "num": 0, "五行": []},
				{"名字": "jljzzs", "num": 0, "五行": []},
				{"名字": "tljzzs", "num": 0, "五行": []},
				{"名字": "231007004zzs", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"tbjxbx":
			var choice_item_list = [
				{"名字": "qlgzzs", "num": 0, "五行": []},
				{"名字": "plzzzs", "num": 0, "五行": []},
				{"名字": "ylfzzs", "num": 0, "五行": []},
				{"名字": "jlczzs", "num": 0, "五行": []},
				{"名字": "tlqzzs", "num": 0, "五行": []},
				{"名字": "230007004zzs", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()

		"xydxq":
			var parent = get_parent().get_parent().get_parent()
			if not PlayerData.check_same_ini_buff("DoubleFallPro"):
				PlayerData.remove_xhp(my_name, my_page, 1)
				PlayerData.player_data["初始Buff"].push_back(
					{
						"Name": "DoubleFallPro",
						"value": 0.0,
						"AddTime": 7200,
						"reduce_interval": 0.0,
						"AttackKind": "SpecialBuff_1",
						"CanRemove": false,
						"CanAdd": false,
						"DeBuff": false
					}
				)
				Global.add_message_show(parent, "获得两小时双倍掉率Buff，重进关卡生效。", 1.5, Vector2.ZERO)
			else:
				Global.add_message_show(parent, "当前已有双倍掉率Buff!!!。", 1.5, Vector2.ZERO)
			queue_free()

		"txd":
			var parent = get_parent().get_parent().get_parent()

			var target_buff_name = "life_mana_lock"

			if Global.get_player != null and Global.get_player.buff != null:
				var player = Global.get_player

				PlayerData.remove_xhp(my_name, my_page, 1)

				var buff_data = {
					"Name": target_buff_name,
					"value": 0.0,
					"AddTime": 10,
					"reduce_interval": 0.0,
					"AttackKind": "",
					"CanRemove": false,
					"CanAdd": false,
					"DeBuff": true
				}

				Global.add_buff(player.buff, buff_data)

				Global.add_message_show(parent, "获得特效：" + target_buff_name + "，持续10秒！", 1.5, Vector2(450, 300))
			else:
				Global.add_message_show(parent, "请在关卡中使用此道具！", 1.5, Vector2(450, 300))
				return

			queue_free()

		"szbx_1":
			var choice_item_list = [
				{"名字": "wklzyf", "num": 0, "五行": []},
				{"名字": "tslzyf", "num": 0, "五行": []},
				{"名字": "bjlzyf", "num": 0, "五行": []},
				{"名字": "sslzyf", "num": 0, "五行": []},
				{"名字": "bllzyf", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"szbx_2":
			var choice_item_list = [
				{"名字": "wkhzyf", "num": 0, "五行": []},
				{"名字": "tshzyf", "num": 0, "五行": []},
				{"名字": "bjhzyf", "num": 0, "五行": []},
				{"名字": "sshzyf", "num": 0, "五行": []},
				{"名字": "blhzyf", "num": 0, "五行": []}
			]
			Global.add_choose_item(
				Global.get_ancestor(get_parent(), 2), Vector2(460, 260), choice_item_list, my_name, my_page
			)
			queue_free()
		"bsd_1":
			var a = Global.get_all_item_num(
				[
					"sms_1",
					"fls_1",
					"gjs_1",
					"bjs_1",
					"sbs_1",
					"wfs_1",
					"mfs_1",
					"xys_1",
					"bms_1",
					"rxs_1",
					"pjs_1",
					"pms_1",
					"mzs_1",
					"hxs_1",
					"hms_1"
				],
				be_number,
				1
			)
			Global.add_reward_info(Global.get_ancestor(self, 3), Vector2(0, 0), a, my_name, be_number)
			queue_free()

		"bsd_2":
			var a = Global.get_all_item_num(
				[
					"sms_2",
					"fls_2",
					"gjs_2",
					"bjs_2",
					"sbs_2",
					"wfs_2",
					"mfs_2",
					"xys_2",
					"bms_2",
					"rxs_2",
					"pjs_2",
					"pms_2",
					"mzs_2",
					"hxs_2",
					"hms_2"
				],
				be_number,
				1
			)
			Global.add_reward_info(Global.get_ancestor(self, 3), Vector2(0, 0), a, my_name, be_number)
			queue_free()
		"bsd_3":
			var a = Global.get_all_item_num(
				[
					"sms_3",
					"fls_3",
					"gjs_3",
					"bjs_3",
					"sbs_3",
					"wfs_3",
					"mfs_3",
					"xys_3",
					"bms_3",
					"rxs_3",
					"pjs_3",
					"pms_3",
					"mzs_3",
					"hxs_3",
					"hms_3"
				],
				be_number,
				1
			)
			Global.add_reward_info(Global.get_ancestor(self, 3), Vector2(0, 0), a, my_name, be_number)
			queue_free()
		"bsd_4":
			var a = Global.get_all_item_num(
				[
					"sms_4",
					"fls_4",
					"gjs_4",
					"bjs_4",
					"sbs_4",
					"wfs_4",
					"mfs_4",
					"xys_4",
					"bms_4",
					"rxs_4",
					"pjs_4",
					"pms_4",
					"mzs_4",
					"hxs_4",
					"hms_4"
				],
				be_number,
				1
			)
			Global.add_reward_info(Global.get_ancestor(self, 3), Vector2(0, 0), a, my_name, be_number)
			queue_free()
		"bsd_5":
			var a = Global.get_all_item_num(
				[
					"sms_5",
					"fls_5",
					"gjs_5",
					"bjs_5",
					"sbs_5",
					"wfs_5",
					"mfs_5",
					"xys_5",
					"bms_5",
					"rxs_5",
					"pjs_5",
					"pms_5",
					"mzs_5",
					"hxs_5",
					"hms_5"
				],
				be_number,
				1
			)
			Global.add_reward_info(Global.get_ancestor(self, 3), Vector2(0, 0), a, my_name, be_number)
			queue_free()
		"xlhys":
			var parent = get_parent().get_parent().get_parent()
			PlayerData.add_soul(150000 * be_number)
			PlayerData.remove_xhp("xlhys", PlayerData.get_xhp_page("xlhys"), be_number)
			Global.add_message_show(
				parent, "使用" + str(be_number) + "个小灵魂药水获得" + str(be_number * 15) + "w灵魂。", 1.5, Vector2(450, 300)
			)
			MemoryClass.save_game(Global.cd_path)
			queue_free()
		"dlhys":
			var parent = get_parent().get_parent().get_parent()
			PlayerData.add_soul(600000 * be_number)
			PlayerData.remove_xhp("dlhys", PlayerData.get_xhp_page("dlhys"), be_number)
			Global.add_message_show(
				parent, "使用" + str(be_number) + "个大灵魂药水获得" + str(be_number * 60) + "w灵魂。", 1.5, Vector2(450, 300)
			)
			MemoryClass.save_game(Global.cd_path)
			queue_free()

		"djyys":
			var parent = get_parent().get_parent().get_parent()
			var player_level_cap := int(PlayerData.PLAYER_MAX_LEVEL)
			if int(PlayerData.player_data[DataKeys.PLAYER_LEVEL]) >= player_level_cap:
				PlayerData.enforce_level_caps()
				Global.add_message_show(parent, "人物等级已达到%d级上限。" % player_level_cap, 1.5, Vector2(450, 300))
				queue_free()
				return
			var exp_gain = 99999 * be_number

			PlayerData.player_data["玩家当前经验"] += exp_gain

			PlayerData.remove_xhp(my_name, PlayerData.get_xhp_page(my_name), be_number)

			var current_exp = PlayerData.player_data["玩家当前经验"]
			var current_level = PlayerData.player_data[DataKeys.PLAYER_LEVEL]

			var max_exp_list = [
				140,
				160,
				180,
				200,
				220,
				300,
				400,
				500,
				600,
				700,
				800,
				900,
				1200,
				1400,
				1600,
				2000,
				2400,
				3000,
				4000,
				5000
			]
			var get_max_exp = func(level):
				if level <= 19:
					return max_exp_list[level - 1]
				else:
					return 5000 + 5000 * (level - 19)

			var max_exp = get_max_exp.call(current_level)
			var level_up_count = 0

			while current_level < player_level_cap and current_exp >= max_exp:
				current_exp -= max_exp
				current_level += 1
				level_up_count += 1
				max_exp = get_max_exp.call(current_level)

			if current_level >= player_level_cap:
				current_level = player_level_cap
				current_exp = 0

			PlayerData.player_data["玩家当前经验"] = current_exp
			PlayerData.player_data[DataKeys.PLAYER_LEVEL] = current_level

			if RoleProp and RoleProp.baseroleprop:
				RoleProp.baseroleprop.Level = current_level
				RoleProp.baseroleprop.exp = current_exp
				RoleProp.baseroleprop.max_exp = max_exp
				RoleProp.set_basic_prop()
				if Global.get_player != null:
					RoleProp.roleprop.Hp = RoleProp.roleprop.SHp
					RoleProp.roleprop.Mp = RoleProp.roleprop.SMp

			var role_info = get_tree().get_first_node_in_group("RoleInformation")
			if role_info:
				role_info.exp_bar.value = float(current_exp) / max_exp
				role_info.exp_text.text = str(current_exp) + "/" + str(max_exp)
				role_info.role_level.text = str(current_level)
				if Global.get_player != null:
					role_info.hp_bar.value = float(RoleProp.roleprop.Hp) / RoleProp.roleprop.SHp
					role_info.hp_text.text = str(int(RoleProp.roleprop.Hp)) + "/" + str(int(RoleProp.roleprop.SHp))
					role_info.mp_bar.value = float(RoleProp.roleprop.Mp) / RoleProp.roleprop.SMp
					role_info.mp_text.text = str(int(RoleProp.roleprop.Mp)) + "/" + str(int(RoleProp.roleprop.SMp))

			var msg = "使用" + str(be_number) + "个大经验药水，获得" + str(exp_gain) + "经验！"
			msg += " 当前等级: " + str(current_level) + " 经验: " + str(current_exp) + "/" + str(max_exp)
			if level_up_count > 0:
				msg += " 连续升级: " + str(level_up_count) + "级！"
			Global.add_message_show(parent, msg, 3.0, Vector2(450, 300))
			MemoryClass.save_game(Global.cd_path)
			queue_free()
