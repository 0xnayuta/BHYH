extends Node2D
class_name Role1Shallow
var direction: int
var action: String
var iniaction: int
var player: BaseHero
var is_set = false
var is_attacking = false
var dir: int
var is_get = false
@onready var role_1_shallow: Area2D = $Role1Shallow
@onready var role_action: Sprite2D = $RoleAction
@onready var role_player: AnimationPlayer = $RolePlayer
@onready var wait: Timer = $wait
var hit_dic = {"power": 0, "hurtBack": [0, 0], "attackKind": "real"}


func _physics_process(_delta: float) -> void:
	self.scale.x = direction
	if not is_set:
		role_action.set_frame(iniaction)
		wait.start(2.5)
		role_player.play("wait")
		is_set = true
	if action == "zz" and not is_attacking:
		do_hit_1()
	elif action == "lyfb" and not is_attacking:
		do_hit_2()
	elif action == "hmz__" and not is_attacking:
		do_hit_3()


func do_hit_1():
	is_attacking = true
	role_player.play("zz")
	await role_player.animation_finished


func do_hit_2():
	is_attacking = true
	role_player.play("lyfb")
	await role_player.animation_finished


func do_hit_3():
	is_attacking = true
	role_player.play("hmz__")
	await role_player.animation_finished


func _on_wait_timeout() -> void:
	queue_free()


func add_music(idx):
	match idx:
		0:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/1_role1_hit9.mp3")
		1:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/39_role1_hit3_and_hit4.mp3")
		2:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/38_role1_hit5.mp3")
		3:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/18_role1_hit14.mp3")
		4:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/45_role1_hit12_1.mp3")
		5:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/42_role1_hit11.mp3")
		6:
			Global.get_audio_runtime().add_sound(self, "res://Music/hero/26_role1_hit13_1.mp3")
