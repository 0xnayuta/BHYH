extends SceneTree

## 关卡碰撞与触发器探针
## 验证 ZMWS 关卡场景的 ground 碰撞体、Gateway / 触发器 Area2D 与出生点 Marker2D。

const LEVEL_SCENE_DIR := "res://Scene/level/zmws"
const SAMPLE := 20


func _init() -> void:
	var h := DirAccess.open(LEVEL_SCENE_DIR)
	if h == null:
		print("FAIL 打不开关卡目录")
		quit(1)
		return
	var files: Array[String] = []
	for f in h.get_files():
		if f.ends_with(".tscn"):
			files.append(f)
	files.sort()

	var step := maxi(1, files.size() / SAMPLE)
	var checked := 0
	var total_ground := 0
	var total_polygon := 0
	var total_area := 0
	var total_birth := 0
	var bad := 0

	for i in range(0, files.size(), step):
		var packed := load("%s/%s" % [LEVEL_SCENE_DIR, files[i]]) as PackedScene
		if packed == null:
			bad += 1
			continue
		var inst := packed.instantiate()
		var ground_body := inst.get_node_or_null("ZMWS_Ground")
		if ground_body != null:
			if not (ground_body is StaticBody2D):
				print("FAIL ZMWS_Ground 不是 StaticBody2D: ", files[i])
				bad += 1
			else:
				if int(ground_body.collision_layer) != 16:
					print("FAIL 碰撞层异常: ", files[i], " -> ", ground_body.collision_layer)
					bad += 1
				for c in ground_body.get_children():
					if c is CollisionShape2D:
						var shape := (c as CollisionShape2D).shape
						if shape == null:
							print("FAIL 碰撞形状为空: ", files[i], " / ", c.name)
							bad += 1
						else:
							total_ground += 1
					elif c is CollisionPolygon2D:
						total_polygon += 1
		for group_name in ["ZMWS_Gateway", "ZMWS_MonsterTrigger", "ZMWS_ScreenTrigger"]:
			var g := inst.get_node_or_null(group_name)
			if g != null:
				for area in g.get_children():
					if area is Area2D:
						total_area += 1
		var birth := inst.get_node_or_null("ZMWS_Birth")
		if birth != null:
			for m in birth.get_children():
				if m is Marker2D:
					total_birth += 1
		inst.free()
		checked += 1

	print("[+] 抽检关卡=%d" % checked)
	print("[+] CollisionShape2D(矩形地面): %d / CollisionPolygon2D(斜坡): %d" % [total_ground, total_polygon])
	print("[+] Gateway/触发器 Area2D: %d / 出生点 Marker2D: %d" % [total_area, total_birth])
	if bad > 0:
		print("FAIL 存在 %d 处异常" % bad)
		quit(1)
		return
	print("[SUCCESS] 关卡碰撞与触发器验证 PASS！")
	quit(0)
