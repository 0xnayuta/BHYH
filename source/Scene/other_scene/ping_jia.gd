extends Node2D
@onready var texture_rect: TextureRect = $TextureRect

var num: int
var is_set: bool


func _physics_process(delta: float) -> void:
	if not is_set:
		texture_rect.texture = load_item_icon(num)
		$AnimationPlayer.play("show")
		is_set = true


func load_item_icon(_name):
	var abc = load("res://Art/level/challenge/ui_beizhan_pj_" + str(_name) + ".png")
	return abc
