extends "res://Script/back_pack/back_pack.gd"

const NICKNAME_KEY := "角色昵称"


func _ready() -> void:
	super._ready()
	var slot := int(get_meta("coop_slot", 1))
	var profile: Dictionary = LocalCoop.data_for_slot(slot).player_data
	if not profile.has(NICKNAME_KEY):
		profile[NICKNAME_KEY] = name_1.text if slot == 1 else ""
	name_1.text = str(profile[NICKNAME_KEY])
	super._physics_process(0.0)


func _on_name_text_changed(new_text: String) -> void:
	var slot := int(get_meta("coop_slot", 1))
	LocalCoop.data_for_slot(slot).player_data[NICKNAME_KEY] = new_text
