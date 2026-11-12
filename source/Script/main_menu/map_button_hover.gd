class_name MapButtonHover
extends RefCounted

## 地图左列按钮的统一悬停描边。复用关卡按钮着色器，不新增美术资源。
## 仅对缺少独立 hover 贴图的按钮启用；已有 hover 贴图的商城/公告保持原状。

const HOVER_SHADER: Shader = preload("res://Shader/level_button.gdshader")
const HOVER_COLOR: Color = UiColorTokens.TEXT_GOLD_AMBER
const HOVER_WIDTH := 2.0
const TWEEN_TIME := 0.12
const TWEEN_META := &"_map_hover_tween"


static func attach(button: Control, include_children: bool = false) -> void:
	if button == null or not is_instance_valid(button):
		return
	var material := ShaderMaterial.new()
	material.shader = HOVER_SHADER
	material.set_shader_parameter("line_color", HOVER_COLOR)
	material.set_shader_parameter("line_thickness", 0.0)
	_apply_material(button, material, include_children)
	button.set_meta(&"_map_hover_material", material)
	button.mouse_entered.connect(_on_mouse_entered.bind(button, material))
	button.mouse_exited.connect(_on_mouse_exited.bind(button, material))


static func _apply_material(root: CanvasItem, material: ShaderMaterial, include_children: bool) -> void:
	root.material = material
	if not include_children:
		return
	for child in root.get_children():
		if child is CanvasItem:
			(child as CanvasItem).material = material


static func _on_mouse_entered(button: Control, material: ShaderMaterial) -> void:
	_tween_thickness(button, material, HOVER_WIDTH)


static func _on_mouse_exited(button: Control, material: ShaderMaterial) -> void:
	_tween_thickness(button, material, 0.0)


static func _tween_thickness(button: Control, material: ShaderMaterial, target: float) -> void:
	if button.has_meta(TWEEN_META):
		var previous: Variant = button.get_meta(TWEEN_META)
		if previous is Tween and previous.is_valid():
			previous.kill()
	var tween := button.create_tween()
	button.set_meta(TWEEN_META, tween)
	tween.tween_property(material, "shader_parameter/line_thickness", target, TWEEN_TIME)
