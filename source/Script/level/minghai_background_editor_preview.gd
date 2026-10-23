@tool
extends Node2D

const PREVIEW_TEXTURE := "res://Art/level/game_4_level/imported/pool/0cc682431ce0a30065cd5750497b07b22ce60b57520e35da57c11aa301522ce2.png"


func _ready() -> void:
	if not Engine.is_editor_hint():
		queue_free()
		return
	var preview := Sprite2D.new()
	preview.name = "Preview"
	preview.texture = load(PREVIEW_TEXTURE) as Texture2D
	preview.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(preview)
