extends TouchScreenButton

@onready var text_key: Label = $Key
@onready var pic_box: TextureProgressBar = $PicBox
@onready var time_text: Label = $TimeText

var resource_key: String = ""
var cur_size: float = 50.0
var skill_name: String = ""
var max_time: float = 0.0
var can_rest: bool = true
var text_str: String = ""
var is_set: bool = false
var is_no_click: bool = false
var is_click: bool = false
var _size: Vector2 = Vector2(70, 70)
var _offset: Vector2 = Vector2.ZERO
var set_key
var cur_level
var touch_scale: float = 1.0
var _mouse_pressed: bool = false
var _action_down: bool = false
var _ws_effect: AnimatedSprite2D
var _content_icon: Sprite2D
var _cooldown_time_left: float = 0.0
var _cooldown_max_time: float = 0.0
var _last_raw_skill_cd: float = 0.0
var mount_skill_slot: int = -1


func _ready() -> void:
	text_key.text = text_str
	cur_level = _find_level()
	_ensure_ws_effect()


func _input(event: InputEvent) -> void:
	if is_set or is_no_click and not _mouse_pressed:
		return

	var mouse_button := event as InputEventMouseButton
	if mouse_button != null and mouse_button.button_index == MOUSE_BUTTON_LEFT:
		if mouse_button.pressed and _can_press() and _contains_global_point(mouse_button.position):
			_mouse_pressed = true
			_press_button()
			get_viewport().set_input_as_handled()
		elif not mouse_button.pressed and _mouse_pressed:
			_mouse_pressed = false
			_release_button()
			get_viewport().set_input_as_handled()


func _physics_process(delta: float) -> void:
	if cur_level == null or not is_instance_valid(cur_level):
		cur_level = _find_level()

	_update_cooldown(delta)
	_update_ws_effect()

	if is_click:
		position = get_global_mouse_position() - _offset

	if texture_normal != null and not is_no_click:
		var side: float = min(_size.x, _size.y)
		if side <= 0:
			side = cur_size
		scale = Vector2(side / texture_normal.get_width(), side / texture_normal.get_height()) * touch_scale
		_layout_content_icon()


func set_button_texture(path: String) -> void:
	var texture := _load_texture(path, "res://Art/ui_2_5_9_0/key/p.png")
	texture_normal = texture
	texture_pressed = texture
	pic_box.texture_progress = texture
	_clear_content_icon()


func set_framed_icon(
	icon_path: String, frame_path: String = "res://Art/ui_2_5_9_0/key/p.png", icon_scale_ratio: float = 0.66
) -> void:
	var frame := _load_texture(frame_path, "res://Art/ui_2_5_9_0/key/p.png")
	var icon := _load_texture(icon_path, "")
	var texture := _make_framed_icon_texture(frame, icon, icon_scale_ratio)
	texture_normal = texture
	texture_pressed = texture
	pic_box.texture_progress = texture
	_clear_content_icon()


func _make_framed_icon_texture(frame: Texture2D, icon: Texture2D, icon_scale_ratio: float = 0.66) -> Texture2D:
	if frame == null:
		return icon
	var frame_image: Image = frame.get_image()
	if frame_image == null:
		return frame
	var result: Image = frame_image.duplicate()
	if icon != null:
		var icon_image: Image = icon.get_image()
		if icon_image != null:
			var frame_size: Vector2i = result.get_size()
			var target_side: int = int(min(frame_size.x, frame_size.y) * clamp(icon_scale_ratio, 0.1, 1.0))
			if target_side > 0:
				icon_image.convert(Image.FORMAT_RGBA8)
				icon_image.resize(target_side, target_side, Image.INTERPOLATE_LANCZOS)
				_apply_circle_alpha(icon_image)
				var dst := Vector2i(int((frame_size.x - target_side) * 0.5), int((frame_size.y - target_side) * 0.5))
				result.blend_rect(icon_image, Rect2i(Vector2i.ZERO, icon_image.get_size()), dst)
	return ImageTexture.create_from_image(result)


func _apply_circle_alpha(image: Image) -> void:
	var size: Vector2i = image.get_size()
	var center := Vector2((size.x - 1) * 0.5, (size.y - 1) * 0.5)
	var radius: float = min(size.x, size.y) * 0.5
	for y in range(size.y):
		for x in range(size.x):
			if Vector2(x, y).distance_to(center) > radius:
				var color := image.get_pixel(x, y)
				color.a = 0.0
				image.set_pixel(x, y, color)


func _load_texture(path: String, fallback_path: String) -> Texture2D:
	var texture: Texture2D = null
	if path != "":
		texture = load(path)
	if texture == null and fallback_path != "":
		texture = load(fallback_path)
	return texture


func _ensure_content_icon() -> void:
	if _content_icon != null:
		return
	_content_icon = Sprite2D.new()
	_content_icon.name = "ContentIcon"
	_content_icon.centered = true
	_content_icon.z_index = 1
	add_child(_content_icon)


func _clear_content_icon() -> void:
	if _content_icon != null:
		_content_icon.visible = false
		_content_icon.texture = null


func _layout_content_icon() -> void:
	if _content_icon == null or _content_icon.texture == null or texture_normal == null:
		return
	var base_size := texture_normal.get_size()
	var icon_size := _content_icon.texture.get_size()
	if base_size.x <= 0 or base_size.y <= 0 or icon_size.x <= 0 or icon_size.y <= 0:
		return
	var target_side: float = min(base_size.x, base_size.y) * 0.66
	var icon_scale: float = min(target_side / icon_size.x, target_side / icon_size.y)
	_content_icon.position = base_size * 0.5
	_content_icon.scale = Vector2(icon_scale, icon_scale)


func _find_level():
	var cur = get_tree().current_scene
	if _looks_like_level(cur):
		return cur
	return _search_level(get_tree().root)


func _search_level(node: Node):
	if _looks_like_level(node):
		return node
	for child in node.get_children():
		var found = _search_level(child)
		if found:
			return found
	return null


func _looks_like_level(node) -> bool:
	return node != null and node.get("role_") != null


func _update_cooldown(delta: float) -> void:
	if is_set:
		time_text.visible = false
		pic_box.visible = false
		return
	if _is_ws_key():
		time_text.visible = false
		pic_box.visible = false
		return
	pic_box.visible = true
	if _is_magic_weapon_key():
		_update_magic_weapon_cooldown()
	elif _is_main_sword_array_key():
		_update_main_sword_array_cooldown()
	else:
		_update_skill_cooldown(delta)


func _update_skill_cooldown(delta: float) -> void:
	if mount_skill_slot >= 0:
		var mount_runtime := _current_mount_runtime()
		if (
			mount_runtime != null
			and mount_runtime.has_method("is_riding_mount")
			and bool(mount_runtime.call("is_riding_mount"))
		):
			var remaining := maxf(0.0, float(mount_runtime.call("get_mount_skill_cooldown", mount_skill_slot)))
			var total := maxf(0.0, float(mount_runtime.call("get_mount_skill_cooldown_total", mount_skill_slot)))
			_cooldown_time_left = remaining
			_cooldown_max_time = total
			_last_raw_skill_cd = remaining
			_show_cooldown(remaining, total)
			return
		_show_cooldown(0.0, 0.0)
		return
	var raw_value: float = 0.0
	var skill_key := _real_skill_key(skill_name)
	if cur_level != null and cur_level.get("role_") != null:
		var cd_list = cur_level.get("role_").get("role1_skill_inter")
		if cd_list is Dictionary and cd_list.has(skill_key):
			raw_value = max(float(cd_list[skill_key]), 0.0)
	if raw_value > 0.0 and _last_raw_skill_cd <= 0.0:
		_cooldown_max_time = max(raw_value / 6.0, 0.1)
		_cooldown_time_left = _cooldown_max_time
	elif raw_value <= 0.0:
		_cooldown_time_left = 0.0
		_cooldown_max_time = 0.0
	_last_raw_skill_cd = raw_value
	if _cooldown_time_left > 0.0:
		_cooldown_time_left = max(_cooldown_time_left - delta, 0.0)
	_show_cooldown(_cooldown_time_left, _cooldown_max_time)


func _update_magic_weapon_cooldown() -> void:
	var remaining: float = 0.0
	var total: float = 0.0
	var player = _current_player()
	if player != null:
		var magic_weapon = player.get("mg_target")
		if magic_weapon != null and is_instance_valid(magic_weapon):
			total = max(float(magic_weapon.get("usecd")), 0.0)
			var timer = magic_weapon.get_node_or_null("SkillCD")
			if timer is Timer and not timer.is_stopped():
				remaining = max(timer.time_left, 0.0)
				if total <= 0.0:
					total = max(max(timer.wait_time, remaining), 0.1)
	_show_cooldown(remaining, total)


func _update_main_sword_array_cooldown() -> void:
	var remaining: float = 0.0
	var total: float = 0.0
	var player = _current_player()
	if player != null:
		var timer = player.get_node_or_null("ZhenFa")
		if timer is Timer and not timer.is_stopped():
			remaining = max(timer.time_left, 0.0)
			total = max(max(timer.wait_time, remaining), 0.1)
		else:
			var cd_value = player.get("zhen_fa_cd")
			if cd_value != null:
				remaining = max(float(cd_value), 0.0)
				if remaining > 0.0:
					total = max(remaining, 30.0)
	_show_cooldown(remaining, total)


func _show_cooldown(remaining: float, total: float) -> void:
	if remaining <= 0.0:
		time_text.visible = false
		pic_box.value = 0
		return
	time_text.visible = true
	time_text.text = _format_cooldown_text(remaining)
	pic_box.value = clamp(remaining / max(total, 0.1), 0.0, 1.0)


func _format_cooldown_text(value: float) -> String:
	if value > 1.0:
		return str(snapped(value, 1.0))
	return str(snapped(value, 0.1))


func _is_magic_weapon_key() -> bool:
	return _action_name() == "MagicWeapon" or text_str == "H"


func _is_main_sword_array_key() -> bool:
	return _action_name() == "MDS" or text_str == "P"


func _current_player():
	if cur_level != null and cur_level.get("role_") != null:
		return cur_level.get("role_")
	return RoleProp.source_player


func _current_mount_runtime() -> Node:
	var player = _current_player()
	if player == null or not is_instance_valid(player):
		return null
	return player.get_node_or_null("MountRuntime")


func _real_skill_key(skill_name: String) -> String:
	return skill_name


func _is_ws_key() -> bool:
	var action_name := _action_name()
	return action_name == "无双" or action_name == "鏃犲弻"


func _ensure_ws_effect() -> void:
	if not _is_ws_key() or _ws_effect != null:
		return
	_ws_effect = AnimatedSprite2D.new()
	_ws_effect.name = "max_ws"
	_ws_effect.centered = false
	_ws_effect.position = Vector2(-3.5, -2.5)
	_ws_effect.z_index = 2
	_ws_effect.sprite_frames = _make_ws_sprite_frames()
	_ws_effect.animation = &"max_ws"
	_ws_effect.play("max_ws")
	_ws_effect.visible = false
	add_child(_ws_effect)


func _make_ws_sprite_frames() -> SpriteFrames:
	var frames: SpriteFrames = SpriteFrames.new()
	frames.add_animation("max_ws")
	frames.set_animation_loop("max_ws", true)
	frames.set_animation_speed("max_ws", 10.0)
	var paths: Array[String] = [
		"res://Art/role_info_icon/418.png",
		"res://Art/role_info_icon/420.png",
		"res://Art/role_info_icon/422.png",
		"res://Art/role_info_icon/424.png",
		"res://Art/role_info_icon/426.png",
		"res://Art/role_info_icon/428.png",
		"res://Art/role_info_icon/430.png",
		"res://Art/role_info_icon/432.png",
	]
	for path in paths:
		var texture: Texture2D = load(path) as Texture2D
		if texture != null:
			frames.add_frame("max_ws", texture)
	return frames


func _update_ws_effect() -> void:
	if _ws_effect == null:
		_ensure_ws_effect()
	if _ws_effect == null:
		return
	var max_ws_value: float = max(float(RoleProp.max_ws_value), 1.0)
	var current_ws_value: float = float(RoleProp.ws_value)
	var is_full: bool = current_ws_value >= max_ws_value and not bool(RoleProp.is_ws_state) and not is_set
	_ws_effect.visible = is_full


func _on_button_button_down() -> void:
	if is_set:
		_offset = get_global_mouse_position() - position
		is_click = true


func _on_button_button_up() -> void:
	if is_set:
		is_click = false


func _on_button_pressed() -> void:
	if set_key:
		set_key.cur_node = self


func _on_pressed() -> void:
	_press_button()


func _on_released() -> void:
	_mouse_pressed = false
	_release_button()


func _press_button() -> void:
	if not _can_press():
		return
	if not is_no_click:
		scale *= 1.1
		is_no_click = true
	if not _action_down:
		_press_action()
		_action_down = true


func _release_button() -> void:
	if is_no_click:
		scale /= 1.1
		is_no_click = false
	if _action_down:
		_release_action()
		_action_down = false


func _can_press() -> bool:
	return not is_set and not _action_name().is_empty()


func _contains_global_point(point: Vector2) -> bool:
	if texture_normal == null:
		return false
	return Rect2(Vector2.ZERO, texture_normal.get_size()).has_point(to_local(point))


func _action_name() -> String:
	return str(action)


func _press_action() -> void:
	var action_name := _action_name()
	if action_name == "MountToggle":
		var mount_runtime := _current_mount_runtime()
		if mount_runtime != null and mount_runtime.has_method("toggle_riding"):
			mount_runtime.call("toggle_riding")
		return
	if InputMap.has_action(action_name):
		Input.action_press(action_name)


func _release_action() -> void:
	var action_name := _action_name()
	if InputMap.has_action(action_name):
		Input.action_release(action_name)


func _exit_tree() -> void:
	if _action_down:
		_release_action()
