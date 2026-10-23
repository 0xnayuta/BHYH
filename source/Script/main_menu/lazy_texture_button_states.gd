extends RefCounted
class_name LazyTextureButtonStates

const HOVER_META := &"lazy_texture_hover_path"
const PRESSED_META := &"lazy_texture_pressed_path"


static func setup(root: Node) -> void:
	for child in root.find_children("*", "TextureButton", true, false):
		var button := child as TextureButton
		if not button.has_meta(HOVER_META) and not button.has_meta(PRESSED_META):
			continue
		button.mouse_entered.connect(_load_button_states.bind(button))
		button.focus_entered.connect(_load_button_states.bind(button))
		button.button_down.connect(_load_button_states.bind(button))


static func _load_button_states(button: TextureButton) -> void:
	if button.has_meta(HOVER_META) and button.texture_hover == null:
		button.texture_hover = _load_texture(str(button.get_meta(HOVER_META)))
	if button.has_meta(PRESSED_META) and button.texture_pressed == null:
		button.texture_pressed = _load_texture(str(button.get_meta(PRESSED_META)))


static func _load_texture(path: String) -> Texture2D:
	if path.is_empty() or not ResourceLoader.exists(path):
		push_error("Missing lazy button texture: " + path)
		return null
	return ResourceLoader.load(path, "Texture2D", ResourceLoader.CACHE_MODE_REUSE) as Texture2D
