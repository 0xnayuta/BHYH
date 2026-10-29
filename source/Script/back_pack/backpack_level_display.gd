extends Node2D

## 显式操作者：按所在面板的槽位解析数据与属性，不依赖全局 1P/2P 视图交换。
var PlayerData: PlayerDataStore:
	get:
		return LocalCoop.data_for(self) as PlayerDataStore
var RoleProp: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self) as BaseRoleProperties

const DIGIT_TEXTURES := [
	preload("res://Art/all_number/level/level_0.png"),
	preload("res://Art/all_number/level/level_1.png"),
	preload("res://Art/all_number/level/level_2.png"),
	preload("res://Art/all_number/level/level_3.png"),
	preload("res://Art/all_number/level/level_4.png"),
	preload("res://Art/all_number/level/level_5.png"),
	preload("res://Art/all_number/level/level_6.png"),
	preload("res://Art/all_number/level/level_7.png"),
	preload("res://Art/all_number/level/level_8.png"),
	preload("res://Art/all_number/level/level_9.png"),
]
const DIGIT_SIZE := Vector2(47.0, 50.0)
const DIGIT_SEPARATION := -23.0
const DIGIT_ALPHA_BOUNDS := [
	Rect2(8.0, 6.0, 30.0, 38.0),
	Rect2(10.0, 7.0, 20.0, 36.0),
	Rect2(7.0, 6.0, 30.0, 37.0),
	Rect2(7.0, 6.0, 29.0, 38.0),
	Rect2(7.0, 6.0, 30.0, 37.0),
	Rect2(7.0, 7.0, 31.0, 37.0),
	Rect2(7.0, 6.0, 29.0, 38.0),
	Rect2(8.0, 7.0, 31.0, 36.0),
	Rect2(7.0, 6.0, 30.0, 38.0),
	Rect2(9.0, 6.0, 29.0, 38.0),
]

@onready var digit_nodes: Array[TextureRect] = [$Number_1, $Number_2, $Number_3]


func _ready() -> void:
	process_priority = 100
	_refresh_level()


func _process(_delta: float) -> void:
	_refresh_level()


func _refresh_level() -> void:
	position = Vector2.ZERO
	var level_text := str(clampi(int(PlayerData.player_data.get(DataKeys.PLAYER_LEVEL, 1)), 1, 999))
	var step: float = DIGIT_SIZE.x + DIGIT_SEPARATION
	var background := get_parent() as Sprite2D
	var max_width: float = 83.0
	var max_height: float = 59.0
	if background != null and background.texture != null:
		max_width = background.texture.get_width()
		max_height = background.texture.get_height()

	var visual_left := INF
	var visual_top := INF
	var visual_right := -INF
	var visual_bottom := -INF
	for index in level_text.length():
		var bounds: Rect2 = DIGIT_ALPHA_BOUNDS[int(level_text[index])]
		var canvas_x: float = step * index
		visual_left = minf(visual_left, canvas_x + bounds.position.x)
		visual_top = minf(visual_top, bounds.position.y)
		visual_right = maxf(visual_right, canvas_x + bounds.end.x)
		visual_bottom = maxf(visual_bottom, bounds.end.y)

	var visual_size := Vector2(visual_right - visual_left, visual_bottom - visual_top)
	var fit_scale: float = minf(1.0, minf(max_width / visual_size.x, max_height / visual_size.y))
	var visual_center := Vector2((visual_left + visual_right) * 0.5, (visual_top + visual_bottom) * 0.5)
	for index in digit_nodes.size():
		var digit_node := digit_nodes[index]
		if index >= level_text.length():
			digit_node.visible = false
			continue
		digit_node.texture = DIGIT_TEXTURES[int(level_text[index])]
		digit_node.position = (Vector2(step * index, 0.0) - visual_center) * fit_scale
		digit_node.size = DIGIT_SIZE
		digit_node.scale = Vector2.ONE * fit_scale
		digit_node.visible = true
