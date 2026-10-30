extends TextureRect
@onready var buff_bar: TextureProgressBar = $BuffBar
@onready var buff_time_label: Label = $BuffTime
@onready var buff_icon_remove: Timer = $BuffIconRemove
@onready var add_times: Label = $AddTimes

var buff_time: float
var buff_info
var buff_name: String = ""
var father_buff: Node = null
var total_times: int = 1
var last_hurt: float = 0.0
var data_list = {}
var parent_node
var _last_icon_name: String = ""
var _buff_count_elapsed: float = 0.0
var _cached_buff_count: int = 0
var _is_mouse_over: bool = false

const YUTU_POISON_ICON_PATHS := {
	"YutuWeakPoison": "yutu_weak_poison",
	"YutuStrongPoison": "yutu_strong_poison",
	"YutuWeakExtraPoison": "yutu_weak_extra_poison",
	"YutuStrongExtraPoison": "yutu_strong_extra_poison",
}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	buff_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	buff_time_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_times.mouse_filter = Control.MOUSE_FILTER_IGNORE


func start_duration(seconds: float) -> void:
	if not is_node_ready():
		await ready
	buff_icon_remove.start(seconds)


func _physics_process(_delta: float) -> void:
	var p_parent = Global.get_ancestor(self, 2)
	if parent_node != null:
		if p_parent != null and p_parent.get("get_obj") != null:
			parent_node = p_parent.get("get_obj")
		else:
			parent_node = RoleProp.source_player
	else:
		parent_node = RoleProp.source_player
	if data_list == {}:
		return
	var icon_name := str(data_list["Name"])
	buff_name = icon_name
	if _last_icon_name != icon_name:
		_last_icon_name = icon_name
		var icon_file := str(YUTU_POISON_ICON_PATHS.get(icon_name, icon_name.to_lower()))
		var icon_texture = Global.get_static_texture("res://Art/add_effect/buff_icon/" + icon_file + ".png")
		if icon_texture == null and icon_name == "PetLifeBonus":
			icon_texture = Global.get_static_texture("res://Art/pet/skillicon/smjc.png")
		if icon_texture == null and icon_name == "DoubleFallPro":
			icon_texture = Global.get_static_texture("res://Art/item_icon/xydxq.png")
		texture = icon_texture
		buff_bar.texture_progress = icon_texture
	if data_list["AddTime"] > 0:
		buff_time = data_list["AddTime"]
	if buff_bar.size != self.size:
		buff_bar.size = self.size
	_buff_count_elapsed += _delta
	if _buff_count_elapsed >= 0.2:
		_buff_count_elapsed = 0.0
		if data_list.has("HaveCount"):
			_cached_buff_count = int(data_list["HaveCount"])
		else:
			_cached_buff_count = get_buff_count()
	var count_text := str(_cached_buff_count) if _cached_buff_count > 1 else ""
	if add_times.text != count_text:
		add_times.text = count_text
	if not buff_time >= 99999:
		var time_left := float(data_list.get("TimeLeft", buff_icon_remove.time_left))
		buff_bar.value = time_left / float(buff_time)
		var remaining_text := str(snapped(time_left, 0.1))
		if buff_time_label.text != remaining_text:
			buff_time_label.text = remaining_text
	else:
		if buff_time_label.text != "永久":
			buff_time_label.text = "永久"
	_update_hover_popup()


func _on_buff_icon_remove_timeout() -> void:
	self.visible = false


func _update_hover_popup() -> void:
	var mouse_over := visible and get_global_rect().has_point(get_viewport().get_mouse_position())
	if mouse_over:
		_show_buff_info()
	elif _is_mouse_over:
		_hide_buff_info()
	_is_mouse_over = mouse_over


func _show_buff_info() -> void:
	if data_list == {}:
		return
	if buff_info == null or not is_instance_valid(buff_info):
		buff_info = Global.add_buffinfor(
			Global.get_ui_runtime().get_popup_layer(), Global.screen_popup_position(Vector2(18, 22)), data_list
		)
		if buff_info == null:
			return
		buff_info.parent_node = self
		buff_info.last_hurt = data_list.get("value", 0.0)
		buff_info.z_index = 4095
		buff_info.top_level = false
	else:
		Global.apply_popup_screen_layout(buff_info, Global.screen_popup_position(Vector2(18, 22)), Vector2(320, 120))
	if data_list.has("TimeLeft"):
		var popup_size: Vector2 = buff_info.get_combined_minimum_size().max(Vector2(320, 120))
		var screen := get_viewport_rect()
		var anchor := get_global_rect().end + Vector2(10, 10)
		buff_info.position = Vector2(
			clampf(anchor.x, 8.0, maxf(8.0, screen.end.x - popup_size.x - 8.0)),
			clampf(anchor.y, 8.0, maxf(8.0, screen.end.y - popup_size.y - 8.0))
		)


func _hide_buff_info() -> void:
	if buff_info != null and is_instance_valid(buff_info):
		buff_info.queue_free()
	buff_info = null


func _on_mouse_entered() -> void:
	_show_buff_info()


func _on_mouse_exited() -> void:
	_hide_buff_info()


func get_buff_count():
	var count: int = 0
	if parent_node != null and parent_node.get("buff") != null:
		var buff_parent: Node = parent_node.buff
		var buff_child_count: int = buff_parent.get_child_count()
		var buff_child_index := 0
		while buff_child_index < buff_child_count:
			var i = buff_parent.get_child(buff_child_index)
			buff_child_index += 1
			if i.buff_info["Name"] == data_list["Name"]:
				count += 1
	return count
