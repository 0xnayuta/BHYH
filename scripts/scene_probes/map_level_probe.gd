extends SceneTree

## 地图关卡场景探针：验证 ActivityRockland1 场景实例化、视差层与 Sprite2D 图层。
## 用法：godot --headless --path source --script res://_map_probe.gd

const SCENE_PATH := "res://Scene/level/zmws/activity_rockland_1.tscn"


func _init() -> void:
	if not ResourceLoader.exists(SCENE_PATH):
		print("FAIL 找不到关卡场景文件: ", SCENE_PATH)
		quit(1)
		return

	var packed := load(SCENE_PATH) as PackedScene
	if not packed:
		print("FAIL 无法加载 PackedScene: ", SCENE_PATH)
		quit(1)
		return

	var root_node := packed.instantiate() as Node2D
	if not root_node:
		print("FAIL 实例化失败，根节点不是 Node2D")
		quit(1)
		return

	print("[*] 根节点: ", root_node.name, " (", root_node.get_class(), ")")

	# 检查 Parallax2D 分组
	var parallax_nodes: Array[Parallax2D] = []
	for child in root_node.get_children():
		if child is Parallax2D:
			parallax_nodes.append(child as Parallax2D)

	print("[*] Parallax2D 容器节点数: ", parallax_nodes.size())
	if parallax_nodes.size() != 2:
		print("FAIL 期望 2 个 Parallax2D 节点，实际为 ", parallax_nodes.size())
		quit(1)
		return

	# 检查视差速度
	var p0 := parallax_nodes[0]
	var p1 := parallax_nodes[1]
	print("  P0: ", p0.name, " scroll_scale=", p0.scroll_scale)
	print("  P1: ", p1.name, " scroll_scale=", p1.scroll_scale)

	if not is_equal_approx(p0.scroll_scale.x, 0.9) or not is_equal_approx(p0.scroll_scale.y, 0.5):
		print("FAIL P0 视差速度不匹配: ", p0.scroll_scale)
		quit(1)
		return
	if not is_equal_approx(p1.scroll_scale.x, 1.0) or not is_equal_approx(p1.scroll_scale.y, 1.0):
		print("FAIL P1 视差速度不匹配: ", p1.scroll_scale)
		quit(1)
		return

	# 检查所有 Sprite2D 图层
	var sprites: Array[Sprite2D] = []
	for p in parallax_nodes:
		for sub in p.get_children():
			if sub is Sprite2D:
				sprites.append(sub as Sprite2D)

	print("[*] Sprite2D 渲染图层总数: ", sprites.size())
	if sprites.size() != 32:
		print("FAIL 期望 32 个 Sprite2D 图层，实际为 ", sprites.size())
		quit(1)
		return

	var bad_textures := 0
	for i in range(sprites.size()):
		var sp := sprites[i]
		var tex := sp.texture
		if tex == null:
			print("  [ERROR] 图层 ", sp.name, " texture 为空！")
			bad_textures += 1
		elif tex.get_width() <= 0 or tex.get_height() <= 0:
			print("  [ERROR] 图层 ", sp.name, " 纹理尺寸异常: ", tex.get_size())
			bad_textures += 1

	if bad_textures > 0:
		print("FAIL 存在 ", bad_textures, " 个损坏纹理图层！")
		quit(1)
		return

	# 检查背景 scale
	var bg_sp := sprites[0]
	print("  背景图层: ", bg_sp.name, " scale=", bg_sp.scale, " pos=", bg_sp.position, " tex_size=", bg_sp.texture.get_size())
	if not is_equal_approx(bg_sp.scale.x, 1.1) or not is_equal_approx(bg_sp.scale.y, 1.1):
		print("FAIL 背景缩放异常: ", bg_sp.scale)
		quit(1)
		return

	root_node.queue_free()
	print("[SUCCESS] 关卡地图验证全部通过！(Parallax2D 分组正常 / 32 图层渲染正常 / 纹理完备)")
	quit(0)
