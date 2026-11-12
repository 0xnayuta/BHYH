extends Control
@onready var over_text: Label = $OVERTEXT
@onready var over_player = $Over
var text_1 = "第一系列——《七魔王篇》终了\n\n\n\n\n\n\n浩劫之际，决战牛魔谷\n\n经七日七夜，与平天魔王不分胜负\n\n昏黑之晨，魔露本态\n\n张牙舞爪，撕牙咧嘴\n\n三藏颂九环真经封其魂魄\n\n悟空以如意金箍棒直破魔心\n\n微风徐徐，乌黑散尽\n\n只见朝霞映天，大地初醒"

var text_2 = "第二系列——《十殿阎罗篇》终了\n\n\n\n\n\n\n浩劫之际，决战牛魔谷\n\n经七日七夜，与平天魔王不分胜负\n\n昏黑之晨，魔露本态\n\n张牙舞爪，撕牙咧嘴\n\n三藏颂九环真经封其魂魄\n\n悟空以如意金箍棒直破魔心\n\n微风徐徐，乌黑散尽\n\n只见朝霞映天，大地初醒"


func _ready() -> void:
	var game_over_variant := Global.get_run_context().get_game_over_variant()
	if game_over_variant == 1:
		over_text.text = text_1
		Global.get_audio_runtime().add_bgm(self, "res://Music/level/10_bg4.mp3")
		over_player.play("first_")
		await get_tree().create_timer(3, false).timeout
		over_player.play("second_")
		await get_tree().create_timer(3, false).timeout
		over_player.play("third")
		await get_tree().create_timer(3, false).timeout
		over_player.play("XY_1OVER")
		await over_player.animation_finished
		change_tomap()
	elif game_over_variant == 2:
		Global.get_audio_runtime().add_bgm(self, "res://Music/level/2_bg4.mp3")
		over_player.play("Over_1")


func _on_tiaoguo_pressed() -> void:
	change_tomap()


func _on_beisu_pressed() -> void:
	if int($beisu/beisu_l.text) > 0:
		over_player.speed_scale = int($beisu/beisu_l.text)
	else:
		Global.add_message_show(self, "请正确输入速度！！", 1.5)


func _on_bg_1_pressed() -> void:
	over_player.play("Over_2")


func change_tomap():
	Global.change_scene("res://Scene/level/victory.tscn")
