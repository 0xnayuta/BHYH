class_name RoleVisualRuntime
extends Node

## 角色身体/装备静态贴图的加载与上一次贴图释放。
## 由 Global 作为普通子节点持有，不是 Autoload；
## 业务侧仍经 Global.load_role1_body / load_role1_eq 正式入口访问。

var _host = null
var _current_body_texture_path: String = ""
var _current_equipment_texture_path: String = ""


func setup(host: Node) -> void:
	_host = host


## 清空当前贴图槽位；缓存资源的释放仍由调用方按作用域处理。
func reset() -> void:
	_current_body_texture_path = ""
	_current_equipment_texture_path = ""


func load_body(_name, role_id: int = 0) -> Texture2D:
	var resolved_role_id := role_id
	if resolved_role_id <= 0:
		resolved_role_id = current_role_id()
	if resolved_role_id == 7:
		return load("res://Art/hero_picture/role_7/preview.png") as Texture2D
	if resolved_role_id == 6:
		var static_texture := static_preview_texture(NeZhaEquipmentVisuals.get_body_frames(str(_name)))
		if static_texture == null:
			push_warning("哪吒身体帧加载失败: " + str(_name))
		return static_texture
	var path := (
		"res://Art/hero_picture/role_"
		+ str(resolved_role_id)
		+ "_all_equipment/role_"
		+ str(resolved_role_id)
		+ "_body_"
		+ str(_name).to_lower()
		+ ".png"
	)
	var path_texture := _load_current_role_texture(path, true)
	if path_texture == null:
		push_warning("角色身体贴图加载失败: " + path)
	return path_texture


func load_equipment(_name, role_id: int = 0) -> Texture2D:
	var resolved_role_id := role_id
	if resolved_role_id <= 0:
		resolved_role_id = current_role_id()
	if resolved_role_id == 7:
		return load("res://Art/hero_picture/role_6/official_parts_trial/transparent.tres") as Texture2D
	if resolved_role_id == 6:
		var static_texture := static_preview_texture(NeZhaEquipmentVisuals.get_weapon_frames(str(_name)))
		if static_texture == null:
			push_warning("哪吒装备帧加载失败: " + str(_name))
		return static_texture
	var path := (
		"res://Art/hero_picture/role_"
		+ str(resolved_role_id)
		+ "_all_equipment/role_"
		+ str(resolved_role_id)
		+ "_eq_"
		+ str(_name).to_lower()
		+ ".png"
	)
	var path_texture := _load_current_role_texture(path, false)
	if path_texture == null:
		push_warning("角色装备贴图加载失败: " + path)
	return path_texture


func current_role_id() -> int:
	var role_id := int(PlayerData.player_data.get("Myself", 1))
	if role_id < 1 or role_id > 7:
		return 1
	return role_id


## 取缓存贴图并释放同槽位上一次贴图，避免连续换装累积常驻纹理。
func _load_current_role_texture(path: String, is_body: bool) -> Texture2D:
	var texture: Texture2D = _host.get_cached_texture(path)
	if texture == null:
		return null
	var previous_path := _current_body_texture_path if is_body else _current_equipment_texture_path
	if previous_path != "" and previous_path != path:
		_host.release_cached_texture(previous_path)
	if is_body:
		_current_body_texture_path = path
	else:
		_current_equipment_texture_path = path
	return texture


## 哪吒特效以 SpriteFrames 承载，静态预览取 wait 首帧。
static func static_preview_texture(frames: SpriteFrames) -> Texture2D:
	if frames == null or not frames.has_animation(&"wait"):
		return null
	if frames.get_frame_count(&"wait") <= 0:
		return null
	return frames.get_frame_texture(&"wait", 0)
