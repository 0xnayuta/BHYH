extends TextureRect
@onready var lpline: LineEdit = $LPDH/lpline
@onready var lhline: LineEdit = $LHDH/lhline
@onready var title_4: Label = $Title4
@onready var title_5: Label = $Title5
@onready var title_6: Label = $Title6

var lp_times: int = 0
var lh_times: int = 0
var total_times: int = 0
var lhdhvalue: int = 50000
const MAX_EXCHANGE_TIMES: int = 9999


func _get_max_lh_times() -> int:
	if lhdhvalue <= 0:
		return 0
	return min(int(PlayerData.get_soul() / lhdhvalue), MAX_EXCHANGE_TIMES)


func _set_lp_times(value: int) -> void:
	lp_times = clampi(value, 0, min(int(PlayerData.get_item_data("smlp")), MAX_EXCHANGE_TIMES))
	if lpline != null and lpline.text != str(lp_times):
		lpline.text = str(lp_times)


func _set_lh_times(value: int) -> void:
	lh_times = clampi(value, 0, _get_max_lh_times())
	if lhline != null and lhline.text != str(lh_times):
		lhline.text = str(lh_times)


func _physics_process(delta: float) -> void:
	total_times = lh_times + lp_times
	title_4.text = "令牌可兑换次数：" + str(lp_times)
	title_5.text = "灵魂可兑换次数：" + str(lh_times)
	title_6.text = "总次数：" + str(total_times)


func _on_lpline_text_changed(new_text: String) -> void:
	var clean_text := new_text.strip_edges()
	if clean_text == "":
		_set_lp_times(0)
		return
	_set_lp_times(int(clean_text))


func _on_min_pressed() -> void:
	_set_lp_times(1)


func _on_max_pressed() -> void:
	_set_lp_times(int(PlayerData.get_item_data("smlp")))


func _on_lhline_text_changed(new_text: String) -> void:
	var clean_text := new_text.strip_edges()
	if clean_text == "":
		_set_lh_times(0)
		return
	_set_lh_times(int(clean_text))


func _on_lhmin_pressed() -> void:
	_set_lh_times(1)


func _on_lhmax_pressed() -> void:
	_set_lh_times(_get_max_lh_times())


func _on_dh_pressed() -> void:
	_set_lp_times(lp_times)
	_set_lh_times(lh_times)
	total_times = lh_times + lp_times
	if total_times > 0:
		if int(PlayerData.get_item_data("smlp")) < lp_times:
			Global.add_message_show(Global.windows, "令牌不足！！", 1.5, Vector2(470, 300))
			return
		if lh_times > _get_max_lh_times():
			Global.add_message_show(Global.windows, "灵魂不足！！", 1.5, Vector2(470, 300))
			return
		PlayerData.remove_dj("smlp", PlayerData.get_dj_page("smlp"), lp_times)
		PlayerData.spend_soul(lhdhvalue * lh_times)
		PlayerData.player_data["购买次数"] += total_times
		MemoryClass.request_save("shop_cure_times")
		Global.add_message_show(Global.windows, "成功兑换" + str(total_times) + "次购买次数！！", 1.5, Vector2(470, 300))
	else:
		Global.add_message_show(Global.windows, "兑换次数为0！！", 1.5, Vector2(470, 300))


func _on_close_pressed() -> void:
	queue_free()
