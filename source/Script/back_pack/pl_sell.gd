extends Control
@onready var pt: CheckBox = $MarginContainer/VBoxContainer/pt
@onready var yx: CheckBox = $MarginContainer/VBoxContainer/yx
@onready var jl: CheckBox = $MarginContainer/VBoxContainer/jl
@onready var ss: CheckBox = $MarginContainer/VBoxContainer/ss
@onready var cs: CheckBox = $MarginContainer/VBoxContainer/cs
@onready var hq: CheckBox = $MarginContainer/VBoxContainer/hq
@onready var xl: CheckBox = $MarginContainer/VBoxContainer/xl
@onready var sq: CheckBox = $MarginContainer/VBoxContainer/sq
@onready var hsh: CheckBox = $MarginContainer/VBoxContainer/hsh

var main_back
var sell_pz = []
var pt_is_choose = false
var yx_is_choose = false
var jl_is_choose = false
var ss_is_choose = false
var cs_is_choose = false
var hq_is_choose = false
var sq_is_choose = false
var xl_is_choose = false
var hsh_is_choose = false
var page: int
var message


func _is_divine_forged(item: Dictionary) -> bool:
	var data = item.get("Data", {})
	if not data is Dictionary:
		return false
	return int(data.get("神铸阶段", 0)) > 0


func _physics_process(_delta: float) -> void:
	page = int($MarginContainer/VBoxContainer/page_.text)
	setbutton_disabled()


func _on_qd_pressed() -> void:
	if page < 1 or page > 20:
		Global.add_message_show(get_parent(), "请正确输入目标页码！", 1.5, Vector2(-240, 150))
		return
	if sell_pz.size() <= 0:
		Global.add_message_show(get_parent(), "请至少勾选一种品质！！", 1.5, Vector2(-240, 150))
		return
	var coin_number: int = 0
	for u in range(15):
		for i in PlayerData.player_data[DataKeys.EQUIPMENT_LIST]["页码" + str(page)]:
			var type = AE.all_equipment[i[DataKeys.NAME]][DataKeys.TYPE]
			if type == "时装" or type == "法宝" or type == "头衔":
				continue
			if _is_divine_forged(i):
				continue
			if (
				bool(i.get("锁定", false))
				or (i.get("Data", {}) is Dictionary and bool((i.get("Data", {}) as Dictionary).get("锁定", false)))
			):
				continue
			var get_pz = AE.all_equipment[i[DataKeys.NAME]][DataKeys.QUALITY]
			var value = AE.all_equipment[i[DataKeys.NAME]]["售价"]
			var qh_level = i[DataKeys.ENHANCE_LEVEL]
			var bs_size = i["Data"][DataKeys.GEM].size()
			if sell_pz.has(get_pz) and qh_level == 0 and bs_size == 0:
				PlayerData.player_data[DataKeys.EQUIPMENT_LIST]["页码" + str(page)].erase(i)
				PlayerData.add_soul(value)
				coin_number += value
	if coin_number > 0:
		Global.add_message_show(get_parent(), "卖出成功！!获得：" + str(coin_number) + "灵魂。", 1.5, Vector2(-240, 150))
	MemoryClass.request_save("back_pack_sell")


func _on_pt_pressed() -> void:
	if not pt_is_choose:
		pt_is_choose = true
		sell_pz.push_back("普通")
	else:
		pt_is_choose = false
		sell_pz.erase("普通")


func _on_yx_pressed() -> void:
	if not yx_is_choose:
		yx_is_choose = true
		sell_pz.push_back("优秀")
	else:
		yx_is_choose = false
		sell_pz.erase("优秀")


func _on_jl_pressed() -> void:
	if not jl_is_choose:
		jl_is_choose = true
		sell_pz.push_back("精良")
	else:
		jl_is_choose = false
		sell_pz.erase("精良")


func _on_ss_pressed() -> void:
	if not ss_is_choose:
		ss_is_choose = true
		sell_pz.push_back("史诗")
	else:
		ss_is_choose = false
		sell_pz.erase("史诗")


func _on_cs_pressed() -> void:
	if not cs_is_choose:
		cs_is_choose = true
		sell_pz.push_back("传说")
	else:
		cs_is_choose = false
		sell_pz.erase("传说")


func _on_hq_pressed() -> void:
	if not hq_is_choose:
		hq_is_choose = true
		sell_pz.push_back("魂器")
	else:
		hq_is_choose = false
		sell_pz.erase("魂器")


func _on_xl_pressed() -> void:
	if not xl_is_choose:
		xl_is_choose = true
		sell_pz.push_back("邪灵")
	else:
		xl_is_choose = false
		sell_pz.erase("邪灵")


func _on_sq_pressed() -> void:
	if not sq_is_choose:
		sq_is_choose = true
		sell_pz.push_back("神器")
	else:
		sq_is_choose = false
		sell_pz.erase("神器")


func _on_hsh_pressed() -> void:
	if not hsh_is_choose:
		hsh_is_choose = true
		sell_pz.push_back("黑神话")
	else:
		hsh_is_choose = false
		sell_pz.erase("黑神话")


func add_text(text, parent):
	if message == null:
		message = Global.add_touch_text(parent, Vector2(100, -80), text)


func remove_text():
	if message != null:
		message.queue_free()


func _on_sell_all_pressed():
	if sell_pz.size() <= 0:
		Global.add_message_show(get_parent(), "请至少勾选一种品质！", 1.5, Vector2(-240, 150))
		return

	var coin_number: int = 0

	for page_idx in range(1, 21):
		var page_key = "页码" + str(page_idx)

		if not PlayerData.player_data[DataKeys.EQUIPMENT_LIST].has(page_key):
			continue

		var equip_list = PlayerData.player_data[DataKeys.EQUIPMENT_LIST][page_key]
		var i = equip_list.size() - 1
		while i >= 0:
			var item = equip_list[i]
			var item_name = item[DataKeys.NAME]

			var item_type = AE.all_equipment[item_name][DataKeys.TYPE]
			if item_type == "时装" or item_type == "法宝" or item_type == "头衔":
				i -= 1
				continue
			if _is_divine_forged(item):
				i -= 1
				continue
			if (
				bool(item.get("锁定", false))
				or (item.get("Data", {}) is Dictionary and bool((item.get("Data", {}) as Dictionary).get("锁定", false)))
			):
				i -= 1
				continue

			var quality = AE.all_equipment[item_name][DataKeys.QUALITY]
			var price = AE.all_equipment[item_name]["售价"]
			var qh_level = item[DataKeys.ENHANCE_LEVEL]
			var gem_count = item["Data"][DataKeys.GEM].size()

			if sell_pz.has(quality) && qh_level == 0 && gem_count == 0:
				PlayerData.record_acquired_equipment(str(item_name))
				equip_list.remove_at(i)
				PlayerData.add_soul(price)
				coin_number += price

			i -= 1

	if coin_number > 0:
		Global.add_message_show(get_parent(), "全部出售成功！获得：" + str(coin_number) + " 灵魂", 1.5, Vector2(-240, 150))
	else:
		Global.add_message_show(get_parent(), "没有可出售的装备", 1.5, Vector2(-240, 150))

	MemoryClass.request_save("back_pack_sell_all")


func _on_close_pressed() -> void:
	queue_free()


## ESC 分层关闭：只关闭批量出售面板。
func request_escape_close() -> bool:
	queue_free()
	return true


func setbutton_disabled():
	if not Global.choose_ms:
		pt.disabled = false
		yx.disabled = false
		jl.disabled = false
		ss.disabled = false
		xl.disabled = false
		hq.disabled = false
		cs.disabled = false
		sq.disabled = false
		hsh.disabled = false

	else:
		pt.disabled = true
		yx.disabled = true
		jl.disabled = true
		ss.disabled = true
		xl.disabled = true
		hq.disabled = true
		cs.disabled = true
		sq.disabled = true
		hsh.disabled = true
