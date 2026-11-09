extends Node2D
@onready var message: Label = $Message
@onready var message_player: AnimationPlayer = $MessagePlayer
var show_text: String
var last_time: float = 1.0
var _started := false


func _ready() -> void:
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message.position = Vector2(-470, -61)


func _process(_delta: float) -> void:
	message.text = str(show_text)
	if _started:
		return
	_started = true
	_fade_out_after_delay()


func _fade_out_after_delay() -> void:
	if last_time > 0.0:
		await get_tree().create_timer(last_time).timeout
	if not is_inside_tree() or message_player == null:
		return
	if message_player.has_animation(&"message_show"):
		message_player.play(&"message_show")
	else:
		var tween := create_tween()
		tween.tween_property(message, "self_modulate:a", 0.0, 1.0)
		tween.tween_callback(queue_free)
