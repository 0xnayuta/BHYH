extends Button

@onready var pd: Label = $pd
var real_name
var zhenfa_name: String
var father
var _last_icon_name: String = ""


func _physics_process(delta: float) -> void:
	if zhenfa_name != _last_icon_name:
		_last_icon_name = zhenfa_name
		self.icon = Global.get_zhenfa_icon(zhenfa_name)


func _on_pressed() -> void:
	match zhenfa_name:
		"slz":
			real_name = "森罗阵"
		"lpz":
			real_name = "落魄阵"
		"tsz":
			real_name = "腾蛇阵"
		"tqz":
			real_name = "太清阵"
	var list = PlayerData.player_data[real_name]
	var num: int = 0
	for i in list:
		if typeof(list[i]) == TYPE_DICTIONARY:
			num += 1
	if father != null:
		father.current_zhen_fa_name = zhenfa_name
		if father.current_num > num:
			father.current_num = 1
		father.on_change_name()
		father.add_zhenyan_button()
