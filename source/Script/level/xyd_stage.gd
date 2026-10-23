extends StaticBody2D
class_name StageNode

@export var stage_index: int = 1
@export var sprite_texture: Texture2D

signal player_entered(stage_index: int, body: Node2D)
signal player_exited(stage_index: int, body: Node2D)

@onready var sprite: Sprite2D = $Sprite
@onready var detection_area: Area2D = $DetectionArea


func _ready():
	if sprite_texture:
		sprite.texture = sprite_texture

	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)

	collision_layer = 32
	collision_mask = 0
	detection_area.collision_layer = 0
	detection_area.collision_mask = 2


func _on_detection_area_body_entered(body: Node2D):
	if is_base_hero_or_child(body):
		player_entered.emit(stage_index, body)


func _on_detection_area_body_exited(body: Node2D):
	if is_base_hero_or_child(body):
		player_exited.emit(stage_index, body)


func is_base_hero_or_child(body: Node2D) -> bool:
	if "BaseHero" in body.name:
		return true

	var path = str(body.get_path())
	if "BaseHero" in path:
		return true

	var parent = body.get_parent()
	if parent and "BaseHero" in parent.name:
		return true

	var current = body
	var depth = 0
	while current != null and depth < 10:
		if "BaseHero" in current.name:
			return true
		current = current.get_parent()
		depth += 1

	if body is CharacterBody2D:
		return true

	if body.is_in_group("Player") or body.is_in_group("player"):
		return true

	return false


func set_feedback_color(color: Color, duration: float = 0.5):
	sprite.modulate = color
	if duration > 0:
		var timer = get_tree().create_timer(duration)
		timer.timeout.connect(func(): sprite.modulate = Color.WHITE)


func set_puzzle_correct():
	set_feedback_color(Color(0.2, 1.0, 0.2, 1.0), 0.5)


func set_puzzle_wrong():
	set_feedback_color(Color(1.0, 0.2, 0.2, 1.0), 0.5)
	var original_position = position
	var tween = create_tween()
	tween.tween_property(self, "position", original_position + Vector2(5, 0), 0.05)
	tween.tween_property(self, "position", original_position + Vector2(-5, 0), 0.05)
	tween.tween_property(self, "position", original_position, 0.05)
