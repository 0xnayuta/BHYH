extends BaseLevel
class_name Level17
@onready var text_2: Label = $CanvasLayer/text/text2


func _ready() -> void:
	Global.current_level = "忘川河"
	Global.player_be_hit_count = 0
	Global.get_audio_runtime().add_bgm(self, "res://Music/level/9_bg3.mp3")
	self.level_stage = 1
	super._ready()
	monster_group = {
		"stage_1": [],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_x = {
		"stage_1": [],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_y = {
		"stage_1": [],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}


func _physics_process(delta: float) -> void:
	text_2.text = str(Global.player_be_hit_count)
	super._physics_process(delta)
	if current_stage >= 1:
		if current_stage < 4:
			role_information.gogo.visible = true
		else:
			role_information.gogo.visible = false


func _on_hddy_body_entered(body: Node2D) -> void:
	if body is BaseHero:
		var profile: Node = LocalCoop.data_for(body) if LocalCoop.is_enabled() else PlayerData
		var props: Node = LocalCoop.props_for(body) if LocalCoop.is_enabled() else RoleProp
		if profile.get_item_data("bsz") > 0:
			profile.remove_dj("bsz", profile.get_dj_page("bsz"), 1)
			if not MemoryClass.request_save("level_17_gate", false):
				profile.add_dj("bsz", 1)
				Global.add_message_show(get_parent(), "存档保存失败，请重试", 2.0, Vector2(470, 300))
				return
			Global.change_scene("res://Scene/level/level_hddy.tscn")
		else:
			props.roleprop.Hp = 0
