extends Node2D
@onready var zhenfaname: Label = $BG/zhenfaname
@onready var zhenfaicon: TextureRect = $BG/zhenfaicon
@onready var zhen_fa_button_list: VBoxContainer = $BG/ZhenFaButton/ZhenFaButtonList
@onready var get_need: Label = $BG/GetNeed
@onready var use_button: Button = $BG/Use
@onready var cur_name: Label = $BG/CurrentEq/CurName
@onready var bg: Sprite2D = $BG
var infomation
var current_zhen_fa_name: String = "slz"
var current_use_type: String = "阵法详情"
var current_num: int = 1
var _last_use_button_state: Variant = null
var current_zf_list = {
	"slz": {"FangFa": "北方星宿1~3位掉落"},
	"lpz": {"FangFa": "北方星宿4~6位掉落"},
	"tsz": {"FangFa": "北方星宿第7位，南方星宿1~3掉落"},
	"tqz": {"FangFa": "南方星宿4~7位掉落"}
}


func _ready() -> void:
	var pd = str(PlayerData.player_data["已佩戴阵法"])
	match pd:
		"slz":
			cur_name.text = "森罗阵"
		"lpz":
			cur_name.text = "落魄阵"
		"tsz":
			cur_name.text = "腾蛇阵"
		"tqz":
			cur_name.text = "太清阵"
		"":
			cur_name.text = ""
	add_total_zhenfa_button()
	set_zhenfa_basic_info()
	set_right_info()
	add_zhenyan_button()


func _physics_process(delta: float) -> void:
	_refresh_use_button_icon()


func _refresh_use_button_icon() -> void:
	var is_equipped: bool = PlayerData.player_data["已佩戴阵法"] == current_zhen_fa_name
	if is_equipped == _last_use_button_state:
		return
	_last_use_button_state = is_equipped
	# 原 42/43 图标资源未随工程导出；按钮改用文本表达状态。
	use_button.text = "已装备" if is_equipped else "使用"
	use_button.icon = null


func add_zhenyan_button():
	var postion_list = [Vector2(120, 25), Vector2(210, 185), Vector2(40, 185)]
	match current_zhen_fa_name:
		"slz", "lpz":
			postion_list = [Vector2(120, 25), Vector2(210, 185), Vector2(40, 185)]
		"tsz", "tqz":
			postion_list = [Vector2(125, 25), Vector2(225, 125), Vector2(125, 210), Vector2(20, 125)]
	for i in zhenfaicon.get_children():
		if i != null:
			zhenfaicon.remove_child(i)
			i.queue_free()
	var num: int = 1
	for i in postion_list:
		Global.addzhenyanbutton(zhenfaicon, i, num, self)
		num += 1


func set_zhenfa_basic_info():
	zhenfaicon.texture = Global.get_zhenfa_icon(current_zhen_fa_name)
	get_need.text = "获得方式：" + str(current_zf_list[current_zhen_fa_name]["FangFa"])
	match current_zhen_fa_name:
		"slz":
			zhenfaname.text = "森罗阵"
			zhenfaname.add_theme_color_override("font_color", "8a00ff")
		"lpz":
			zhenfaname.text = "落魄阵"
			zhenfaname.add_theme_color_override("font_color", "8a00ff")
		"tsz":
			zhenfaname.text = "腾蛇阵"
			zhenfaname.add_theme_color_override("font_color", "ff8d00")
		"tqz":
			zhenfaname.text = "太清阵"
			zhenfaname.add_theme_color_override("font_color", "ff8d00")
	_refresh_use_button_icon()


func add_total_zhenfa_button():
	for i in current_zf_list:
		Global.add_zhenfalxbutton(zhen_fa_button_list, i, self)


func set_right_info():
	match current_use_type:
		"阵法详情":
			if infomation != null:
				infomation.queue_free()
			infomation = Global.add_zhen_fa_info(bg, Vector2(70, -120), self)
		"阵眼升级":
			if infomation != null:
				infomation.queue_free()
			infomation = Global.add_zhen_yan_cure_level(bg, Vector2(70, -120), self)
		"阵法突破":
			if infomation != null:
				infomation.queue_free()
			infomation = Global.add_zhen_fa_tu_po(bg, Vector2(70, -120), self)


func on_change_name():
	set_zhenfa_basic_info()
	set_right_info()


func _on_close_pressed() -> void:
	queue_free()


func _on_zfxq_pressed() -> void:
	current_use_type = "阵法详情"
	set_right_info()


func _on_zysj_pressed() -> void:
	current_use_type = "阵眼升级"
	set_right_info()


func _on_zftp_pressed() -> void:
	current_use_type = "阵法突破"
	set_right_info()


func _on_use_pressed() -> void:
	var name_str
	match current_zhen_fa_name:
		"slz":
			name_str = "森罗阵"
		"lpz":
			name_str = "落魄阵"
		"tsz":
			name_str = "腾蛇阵"
		"tqz":
			name_str = "太清阵"
		"":
			name_str = ""
	if PlayerData.player_data["已佩戴阵法"] == current_zhen_fa_name:
		PlayerData.player_data["已佩戴阵法"] = ""
		Global.add_message_show(Global.windows, "取消佩戴" + str(name_str) + "！！", 1.5, Vector2(500, 305))
	else:
		if PlayerData.player_data[name_str]["Level"] > 0:
			PlayerData.player_data["已佩戴阵法"] = current_zhen_fa_name
			Global.add_message_show(Global.windows, "佩戴" + str(name_str) + "！！", 1.5, Vector2(500, 305))
		else:
			Global.add_message_show(Global.windows, str(name_str) + "等级不足，无法激活！！", 1.5, Vector2(500, 305))
			return
	var pd = str(PlayerData.player_data["已佩戴阵法"])
	match pd:
		"slz":
			cur_name.text = "森罗阵"
		"lpz":
			cur_name.text = "落魄阵"
		"tsz":
			cur_name.text = "腾蛇阵"
		"tqz":
			cur_name.text = "太清阵"
		"":
			cur_name.text = ""


func _on_button_pressed() -> void:
	Global.add_zhen_fa_help(self, Vector2(0, 0))
