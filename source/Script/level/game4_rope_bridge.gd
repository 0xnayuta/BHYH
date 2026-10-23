@tool
extends StaticBody2D

@export var end_offset := Vector2.ZERO
@export_range(1, 100, 1) var segment_count: int = 1
@export var segment_size := Vector2(32.0, 8.0)
@export var segment_texture: Texture2D
@export var visual_offset := Vector2.ZERO


func _ready() -> void:
	if get_node_or_null("Sprite01") != null and get_node_or_null("Collision01") != null:
		if not Engine.is_editor_hint():
			for child in get_children():
				if child is CollisionShape2D:
					child.one_way_collision = false
		return

	var segment_rotation := end_offset.angle()
	for index in range(segment_count):
		var progress := (float(index) + 0.5) / float(segment_count)
		var segment_position := end_offset * progress

		var sprite := Sprite2D.new()
		sprite.name = "Sprite%02d" % (index + 1)
		sprite.position = segment_position + visual_offset
		sprite.rotation = segment_rotation
		sprite.texture = segment_texture
		add_child(sprite)

		var shape := RectangleShape2D.new()
		shape.size = segment_size
		var collision := CollisionShape2D.new()
		collision.name = "Collision%02d" % (index + 1)
		collision.position = segment_position + Vector2(0.0, visual_offset.y + segment_size.y * 0.5)
		collision.rotation = segment_rotation
		collision.shape = shape
		collision.one_way_collision = false
		add_child(collision)
