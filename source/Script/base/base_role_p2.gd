extends "res://Script/base/base_role.gd"

@onready var touch_screen_button = $role_menu/grey/TouchScreenButton


func _ready() -> void:
	super._ready()
	if not OS.has_feature("android"):
		touch_screen_button.queue_free()
	grey.position = Vector2(82, 86)
	grey.rotation = 0.0
	grey.scale = Vector2.ONE
	buff_box.position.x = 100
	_layout_status_row(buff_box)
	_layout_pet_panel()


func _layout_pet_panel() -> void:
	if pet_panel == null:
		return
	pet_panel.anchor_left = 1.0
	pet_panel.anchor_right = 1.0
	pet_panel.offset_left = 0.0
	pet_panel.offset_right = 267.0
	pet_panel.pivot_offset = Vector2.ZERO
	pet_panel.scale.x = -absf(pet_panel.scale.x)
	for path: String in ["hp_bar", "mp_bar", "exp_bar", "TextureRect", "h_m_e_t", "SkillBox", "Buff_box"]:
		var control: Control = pet_panel.get_node(path)
		control.pivot_offset = Vector2(control.size.x * 0.5, 0)
		control.scale.x = -1.0
	for path: String in ["SkillBox", "Buff_box"]:
		var row: HBoxContainer = pet_panel.get_node(path)
		_layout_status_row(row)


func _layout_status_row(row: HBoxContainer) -> void:
	row.set_meta("coop_owner_offset_x", row.position.x)
	row.layout_direction = Control.LAYOUT_DIRECTION_RTL
	row.alignment = BoxContainer.ALIGNMENT_BEGIN
	var update_pivot := _update_status_row_pivot.bind(row)
	if not row.resized.is_connected(update_pivot):
		row.resized.connect(update_pivot)
	_update_status_row_pivot(row)


func _update_status_row_pivot(row: HBoxContainer) -> void:
	row.pivot_offset.x = row.size.x * 0.5
	row.position.x = float(row.get_meta("coop_owner_offset_x"))


func _load_skill_icons() -> void:
	super._load_skill_icons()
	for index in range(role_skill_slots.size()):
		for child in role_skill_slots[index].get_children():
			if child is Label and child.text in ["Y", "U", "I", "O", "L"]:
				child.text = ["3", "4", "5", "6", "8"][index]
