extends Node
var my_main_music


func remove_music():
	if my_main_music != null:
		my_main_music.queue_free()


func add_music():
	if MainSet.set_data["music"] == 1:
		if my_main_music != null:
			my_main_music.queue_free()
		my_main_music = Global.add_bgm(self, "res://Music/main_scene_music/zmxy_1_bgm.mp3")
	elif MainSet.set_data["music"] == 2:
		if my_main_music != null:
			my_main_music.queue_free()
		my_main_music = Global.add_bgm(self, "res://Music/main_scene_music/zmxy_2_bgm.mp3")
	elif MainSet.set_data["music"] == 3:
		if my_main_music != null:
			my_main_music.queue_free()
		my_main_music = Global.add_bgm(self, "res://Music/main_scene_music/44_begin.mp3")
	elif MainSet.set_data["music"] == 4:
		if my_main_music != null:
			my_main_music.queue_free()
		my_main_music = Global.add_bgm(self, "res://Music/main_scene_music/zmxy4bg.mp3")
