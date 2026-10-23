extends Node2D

var speed: int = 50
var max_position_x: int = 300
var direction: int = 1
var pd: bool = true
var currentposition: Vector2
var catch: bool = false
var player: BaseHero
var is_set: bool = false

var platform_texture: Texture2D
@onready var sprite: Sprite2D = $ZlwFloor


func _ready() -> void:
	if platform_texture != null:
		sprite.texture = platform_texture


func _physics_process(_delta: float) -> void:
	if not is_set:
		currentposition = position
		is_set = true
	self.position.x += direction * speed
	if pd:
		if position.x >= max_position_x:
			position = currentposition
	else:
		if position.x <= max_position_x:
			position = currentposition
	if catch:
		if player != null:
			player.position.x += direction * speed


func set_texture(texture: Texture2D) -> void:
	"动态设置贴图"
	if sprite != null:
		sprite.texture = texture
	platform_texture = texture


func _on_area_2d_body_entered(body: Node2D) -> void:
	catch = true
	if body is BaseHero:
		player = body


func _on_area_2d_body_exited(_body: Node2D) -> void:
	catch = false
