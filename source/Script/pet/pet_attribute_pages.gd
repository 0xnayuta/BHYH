class_name PetAttributePages
extends Control

## 宠物属性分页视图：只绑定行、分页和显示文本。
## 数据由父面板通过 Callable 提供；本控制器不读取 PlayerData、不保存、不修改档案。

const PAGE_DEFINITIONS := [
	[
		["生命", "生命"],
		["魔法", "魔法"],
		["攻击", "攻击"],
		["物防", "物防"],
		["幸运", "幸运"],
		["魔防", "魔防"],
		["暴击", "暴击"],
		["闪避", "闪避"],
		["回血", "回血"],
		["回魔", "回魔"],
	],
	[["命中", "命中"], ["韧性", "韧性"], ["吸血", "吸血"], ["暴免", "暴免"], ["破甲", "破甲"], ["破魔", "破魔"]],
]

var page_index: int = 0
var _rows: Array[Control] = []
var _name_labels: Array[Label] = []
var _value_labels: Array[Label] = []
var _page_buttons: Array[Button] = []
var _value_provider := Callable()
var _last_pet: Variant = null
var _last_equipment_bonus: Variant = null


func _ready() -> void:
	_collect_rows()


## 由面板根注入分页按钮与显示值提供者；子控制器不持有操作者。
func setup(page_buttons: Array[Button], value_provider: Callable) -> void:
	_page_buttons = page_buttons
	_value_provider = value_provider
	for index in _page_buttons.size():
		var button: Button = _page_buttons[index]
		if button == null:
			continue
		var callback := _on_page_pressed.bind(index)
		if not button.pressed.is_connected(callback):
			button.pressed.connect(callback)
	_update_page_buttons()


func refresh(pet: Variant, equipment_bonus: Variant = null) -> void:
	_last_pet = pet
	_last_equipment_bonus = equipment_bonus
	_render()


func select_page(index: int) -> void:
	page_index = clampi(index, 0, PAGE_DEFINITIONS.size() - 1)
	_update_page_buttons()
	_render()


func _collect_rows() -> void:
	_rows.clear()
	_name_labels.clear()
	_value_labels.clear()
	for index in range(10):
		var row_number := index + 1
		_rows.append(get_node_or_null("StatRow%d" % row_number) as Control)
		_name_labels.append(get_node_or_null("StatRow%d/Name" % row_number) as Label)
		_value_labels.append(get_node_or_null("StatRow%d/Value" % row_number) as Label)


func _on_page_pressed(index: int) -> void:
	select_page(index)


func _update_page_buttons() -> void:
	for index in _page_buttons.size():
		var button: Button = _page_buttons[index]
		if button == null:
			continue
		var selected := index == page_index
		button.disabled = false
		button.add_theme_color_override(
			"font_color", UiColorTokens.TEXT_GOLD_LIGHT if selected else UiColorTokens.TEXT_PRIMARY
		)


func _render() -> void:
	var definitions: Array = PAGE_DEFINITIONS[clampi(page_index, 0, PAGE_DEFINITIONS.size() - 1)]
	for index in _rows.size():
		var row: Control = _rows[index]
		var has_stat := index < definitions.size()
		if row != null:
			row.visible = has_stat
		if not has_stat:
			continue
		var definition: Array = definitions[index]
		var name_label: Label = _name_labels[index]
		if name_label != null:
			name_label.text = str(definition[0])
		var value_label: Label = _value_labels[index]
		if value_label == null:
			continue
		var value := "0"
		if _value_provider.is_valid():
			value = str(_value_provider.call(_last_pet, str(definition[1]), _last_equipment_bonus))
		value_label.text = value
