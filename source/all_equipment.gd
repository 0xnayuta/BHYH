extends Node

const DATA_SCRIPT := "res://Script/data/all_equipment_data.gd"

var prop_list_name = [
	"SHp",
	"SMp",
	"power",
	"Def",
	"Mdef",
	"Crit",
	"Miss",
	"R_hp",
	"R_mp",
	"vampirism",
	"Lucky",
	"toughness",
	"htarget",
	"CritReduce",
	"ar",
	"sp"
]
var _data: Node

var all_equipment: Dictionary:
	get:
		return _get_data().all_equipment
	set(value):
		_get_data().all_equipment = value


func _ready() -> void:
	randomize()


func ensure_loaded() -> void:
	_get_data().ensure_loaded()


func all_equ() -> void:
	_get_data().all_equ()


func get_last_equ_pro(_name, qh_level, data):
	return _get_data().get_last_equ_pro(_name, qh_level, data)


func get_fb_last_equ_pro(_name, qh_level, wxlist, data):
	return _get_data().get_fb_last_equ_pro(_name, qh_level, wxlist, data)


func get_divine_forge_stage(data: Dictionary) -> int:
	return _get_data().get_divine_forge_stage(data)


func can_divine_forge(_name: String, data: Dictionary = {}) -> bool:
	return _get_data().can_divine_forge(_name, data)


func get_divine_forge_multiplier(_name: String, data: Dictionary) -> float:
	return _get_data().get_divine_forge_multiplier(_name, data)


func scale_divine_forge_value(value, _name: String, data: Dictionary):
	return _get_data().scale_divine_forge_value(value, _name, data)


func get_divine_forge_display_name(_name: String, data: Dictionary) -> String:
	return _get_data().get_divine_forge_display_name(_name, data)


func get_divine_forge_gem_properties(_name: String, data: Dictionary) -> Dictionary:
	return _get_data().get_divine_forge_gem_properties(_name, data)


func get_gem_resonance_level(data: Dictionary) -> int:
	return _get_data().get_gem_resonance_level(data)


func scale_gem_resonance_value(value, data: Dictionary):
	return _get_data().scale_gem_resonance_value(value, data)


func get_divine_forge_properties(_name: String, qh_level: int, data: Dictionary, include_gems := false) -> Dictionary:
	return _get_data().get_divine_forge_properties(_name, qh_level, data, include_gems)


func get_wx():
	return _get_data().get_wx()


func _exit_tree() -> void:
	if is_instance_valid(_data):
		_data.free()
		_data = null


func _get_data() -> Node:
	if _data == null:
		_data = load(DATA_SCRIPT).new()
	return _data
