extends TextureRect
@onready var skillicon: TextureRect = $skillicon
@onready var pic_box: TextureProgressBar = $PicBox
@onready var last_time: Timer = $LastTime
@onready var time_text: Label = $TimeText

var skill_name: String
var max_time: float
var iszhenfa: bool
var _last_icon_key := ""


func _physics_process(delta: float) -> void:
	if skill_name != null and skill_name != "":
		var icon_key := str(skill_name) + ":" + str(iszhenfa)
		if _last_icon_key != icon_key:
			_last_icon_key = icon_key
			var icon_texture: Texture2D = (
				Global.get_zhenfa_icon(str(skill_name))
				if iszhenfa
				else Global.get_static_texture("res://Art/magic_weapon/skill_icon/" + str(skill_name) + ".png")
			)
			skillicon.texture = icon_texture
			pic_box.texture_progress = icon_texture
		if max_time > 0:
			if last_time.is_stopped():
				last_time.start(max_time)
	if last_time.time_left <= 0:
		time_text.visible = false
		pic_box.value = 0
	else:
		time_text.visible = true
		if last_time.time_left > 1:
			time_text.text = str(snapped(last_time.time_left, 1))
		else:
			time_text.text = str(snapped(last_time.time_left, 0.1))
		pic_box.value = last_time.time_left / float(max_time)


func _on_last_time_timeout() -> void:
	max_time = 0


func _on_mouse_entered() -> void:
	pass
