extends Control
@onready var background: TextureRect = $background
@onready var text_tt: Label = $background/text_tt
@onready var remove_player: AnimationPlayer = $remove_player
var show_text: String
var state = show
var last_time: float
enum {
	show,
	wait,
	remove,
}


func _physics_process(_delta: float) -> void:
	match state:
		show:
			_show_text()
		wait:
			_wait_then_remove()
		remove:
			_remove_self()


func _show_text():
	text_tt.text = show_text
	background.size.x = text_tt.size.x
	background.size.y = text_tt.size.y
	state = wait


func _wait_then_remove():
	await get_tree().create_timer(last_time).timeout
	state = remove


func _remove_self():
	background.position.y -= 1
	remove_player.play("_remove_self")
