extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var dir: bool
var should_death: bool


func _ready() -> void:
	animation_player.play("smb")


func _physics_process(delta: float) -> void:
	if should_death:
		self.queue_free()
	if dir:
		self.position.x += 7
	else:
		self.position.x -= 7
