extends Node2D
@onready var behitplayer: AnimatedSprite2D = $behitplayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var _recycled: bool = false


func _ready() -> void:
	pass


func _play_hurt_animation():
	_recycled = false
	visible = true
	if randi_range(0, 100) < 50:
		animation_player.play("hurt_1")
	else:
		animation_player.play("hurt_2")


func prepare_for_pool() -> void:
	_recycled = true
	visible = false
	if animation_player != null:
		animation_player.stop()


func recycle():
	if _recycled:
		return
	_recycled = true
	if Global != null and Global.has_method("recycle_mr_hurt"):
		Global.recycle_mr_hurt(self)
	else:
		queue_free()


func _recycle_after_hit():
	recycle()
