extends Node2D

@export var all_images: Array[Texture2D] = []

var all_texture_rects: Array[TextureRect] = []
var node_opacities: Array[float] = []

const MIN_NUM: int = 1
const MAX_NUM: int = 7


func _ready():
	batch_get_texture_rects()
	init_opacities()


func batch_get_texture_rects():
	var sprite_node = $Sprite2D
	if not sprite_node:
		push_error("找不到Sprite2D节点！请检查场景结构。")
		return

	all_texture_rects.clear()
	for node_num in range(MIN_NUM, MAX_NUM + 1):
		var node_name = "yf" + str(node_num)
		var rect_node = sprite_node.get_node(node_name)
		if rect_node and rect_node is TextureRect:
			all_texture_rects.append(rect_node)
		else:
			push_warning("未找到TextureRect节点：" + node_name)


func init_opacities():
	node_opacities.clear()
	for i in range(MAX_NUM):
		node_opacities.append(1.0)


func assign_image_to_rect(rect_num: int, image_num: int):
	if rect_num < MIN_NUM or rect_num > MAX_NUM:
		push_error("节点编号越界！节点编号必须在" + str(MIN_NUM) + "-" + str(MAX_NUM) + "之间")
		return

	if image_num < MIN_NUM or image_num > MAX_NUM:
		push_error("图片编号越界！图片编号必须在" + str(MIN_NUM) + "-" + str(MAX_NUM) + "之间")
		return

	if all_images.size() < MAX_NUM:
		push_error("图片数组未填充完整！当前仅挂载" + str(all_images.size()) + "张图片，需要7张")
		return

	if all_texture_rects.size() < MAX_NUM:
		push_error("TextureRect节点数量不足！请先调用batch_get_texture_rects()")
		return

	var rect_index: int = rect_num - 1
	var image_index: int = image_num - 1

	all_texture_rects[rect_index].texture = all_images[image_index]
	set_node_opacity(rect_num, 1.0)


func set_node_opacity(rect_num: int, opacity: float):
	if rect_num < MIN_NUM or rect_num > MAX_NUM:
		return

	var rect_index: int = rect_num - 1
	if rect_index >= 0 and rect_index < all_texture_rects.size():
		all_texture_rects[rect_index].modulate = Color(1.0, 1.0, 1.0, opacity)
		node_opacities[rect_index] = opacity


func reset_all_opacities():
	for i in range(all_texture_rects.size()):
		all_texture_rects[i].modulate = Color(1.0, 1.0, 1.0, 1.0)
		node_opacities[i] = 1.0


func get_node_opacity(rect_num: int) -> float:
	if rect_num < MIN_NUM or rect_num > MAX_NUM:
		return 1.0

	var rect_index: int = rect_num - 1
	if rect_index >= 0 and rect_index < node_opacities.size():
		return node_opacities[rect_index]
	return 1.0


func get_current_image_sequence() -> Array[int]:
	var sequence: Array[int] = []
	for rect in all_texture_rects:
		if rect.texture:
			var image_index = all_images.find(rect.texture)
			if image_index != -1:
				sequence.append(image_index + 1)
			else:
				sequence.append(-1)
		else:
			sequence.append(-1)
	return sequence
