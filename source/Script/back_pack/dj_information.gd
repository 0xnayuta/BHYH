extends Control

## 显式操作者：按所在面板的槽位解析数据与属性，不依赖全局 1P/2P 视图交换。
var PlayerData: PlayerDataStore:
	get:
		return LocalCoop.data_for(self) as PlayerDataStore
var RoleProp: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self) as BaseRoleProperties

@onready var title: Label = $MarginContainer/MarginContainer/VBoxContainer/title
@onready var color_rect: ColorRect = $ColorRect

@onready var _name: Label = $MarginContainer/MarginContainer/VBoxContainer/name
@onready var lx: Label = $MarginContainer/MarginContainer/VBoxContainer/lx
@onready var pz: Label = $MarginContainer/MarginContainer/VBoxContainer/pz
@onready var ms: Label = $MarginContainer/MarginContainer/VBoxContainer/VBoxContainer/ms
@onready var sl: Label = $MarginContainer/MarginContainer/VBoxContainer/sl
@onready var sj: Label = $MarginContainer/MarginContainer/VBoxContainer/VBoxContainer/sj
var my_name
var is_set = false


func _get_display_name():
	var name1 = my_name
	return name1


func _ready() -> void:
	self.modulate = Color(1, 1, 1, 0)


func _physics_process(_delta: float) -> void:
	color_rect.size = $MarginContainer.size
	if get_parent().get_script() != null and get_parent().get_script().resource_path.ends_with("BackPack.gdc"):
		if self.position.y + color_rect.size.y >= 320:
			self.position.y = 320 - color_rect.size.y
	elif get_parent() == Global.get_ui_runtime().windows:
		var viewport_size := get_viewport().get_visible_rect().size
		if self.position.y + color_rect.size.y >= viewport_size.y:
			self.position.y = viewport_size.y - color_rect.size.y - 8.0
		if self.position.x + color_rect.size.x >= viewport_size.x:
			self.position.x = get_tree().get_root().get_mouse_position().x - color_rect.size.x - 25.0
		if self.position.x < 8.0:
			self.position.x = 8.0
		if self.position.y < 8.0:
			self.position.y = 8.0
	if is_set == false:
		create_tween().tween_property(self, "modulate", Color(1, 1, 1, 1), 0.2)
		set_color()
		_name.text = "名称：" + str(AE.all_equipment[_get_display_name()][DataKeys.NAME])
		lx.text = "类型：" + str(AE.all_equipment[_get_display_name()][DataKeys.TYPE])
		pz.text = "品质：" + str(AE.all_equipment[_get_display_name()][DataKeys.QUALITY])
		if str(AE.all_equipment[_get_display_name()][DataKeys.TYPE]) == "消耗品":
			sl.text = "拥有：" + str(PlayerData.get_xhp_data(_get_display_name())) + " 个"
		else:
			sl.text = "拥有：" + str(PlayerData.get_item_data(_get_display_name())) + " 个"
		ms.text = "描述：" + str(AE.all_equipment[_get_display_name()]["描述"])
		sj.text = "售价：" + str(AE.all_equipment[_get_display_name()]["售价"]) + "灵魂。"
		is_set = true


func set_color():
	if str(AE.all_equipment[_get_display_name()].get(DataKeys.QUALITY, "")) == "黑神话":
		_apply_black_myth_text_style(_name)
		_apply_black_myth_text_style(pz)
		return
	_name.add_theme_color_override("font_color", AE.all_equipment[_get_display_name()]["颜色"])
	pz.add_theme_color_override("font_color", AE.all_equipment[_get_display_name()]["颜色"])


func _apply_black_myth_text_style(label: Label) -> void:
	label.add_theme_color_override("font_color", Color(0.6, 0.0, 0.0, 1.0))
