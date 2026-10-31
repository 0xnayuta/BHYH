extends SceneTree

## 全量地图关卡场景与其余图集验证探针
## 验证 1701 个关卡场景的抽样实例化以及 skill/effect/ui/diepng 纹理加载。

const LEVEL_SCENE_DIR := "res://Scene/level/zmws"
const SAMPLE_LEVELS := 25


func _init() -> void:
	print("[*] 开始全量关卡场景与新增图集抽样验证...")
	var h := DirAccess.open(LEVEL_SCENE_DIR)
	if h == null:
		print("FAIL 打不开关卡目录: ", LEVEL_SCENE_DIR)
		quit(1)
		return

	var scene_files: Array[String] = []
	for f in h.get_files():
		if f.ends_with(".tscn"):
			scene_files.append(f)
	scene_files.sort()

	print("[*] 发现关卡场景总数: ", scene_files.size())
	if scene_files.size() < 1600:
		print("FAIL 关卡场景总数过少: ", scene_files.size())
		quit(1)
		return

	# 1. 抽样测试关卡实例化
	var step := maxi(1, scene_files.size() / SAMPLE_LEVELS)
	var tested_levels := 0
	var total_sprites := 0
	var bad_textures := 0

	for i in range(0, scene_files.size(), step):
		var s_file := scene_files[i]
		var s_path := "%s/%s" % [LEVEL_SCENE_DIR, s_file]
		var packed := load(s_path) as PackedScene
		if not packed:
			print("FAIL 无法加载场景: ", s_path)
			quit(1)
			return

		var inst := packed.instantiate() as Node2D
		if not inst:
			print("FAIL 根节点不是 Node2D: ", s_path)
			quit(1)
			return

		var parallax_count := 0
		for child in inst.get_children():
			if child is Parallax2D:
				parallax_count += 1
				for sub in child.get_children():
					if sub is Sprite2D:
						total_sprites += 1
						var sp := sub as Sprite2D
						if sp.texture == null or sp.texture.get_width() <= 0:
							print("  [ERROR] ", s_file, " -> ", sp.name, " 纹理失效")
							bad_textures += 1

		if parallax_count == 0:
			print("FAIL 场景未包含 Parallax2D: ", s_path)
			inst.queue_free()
			quit(1)
			return

		inst.queue_free()
		tested_levels += 1

	print("[+] 关卡抽样验证: 抽检关卡=%d 验证图层总数=%d 异常纹理=%d" % [tested_levels, total_sprites, bad_textures])
	if bad_textures > 0:
		print("FAIL 存在异常纹理图层！")
		quit(1)
		return

	# 2. 抽样测试新增图集纹理
	var domains := [
		"res://Art/skill/all_skills",
		"res://Art/effect/all_effects",
		"res://Art/ui/module_res",
		"res://Art/diepng",
	]

	var total_atlas_tested := 0
	for dom in domains:
		var dh := DirAccess.open(dom)
		if dh == null:
			print("FAIL 找不到目录: ", dom)
			quit(1)
			return
		var pngs: Array[String] = []
		for f in dh.get_files():
			if f.ends_with(".png"):
				pngs.append(f)
		pngs.sort()
		var sub_tested := 0
		var sub_step := maxi(1, pngs.size() / 6)
		for j in range(0, pngs.size(), sub_step):
			var p := "%s/%s" % [dom, pngs[j]]
			var t := load(p) as Texture2D
			if t == null or t.get_width() <= 0:
				print("FAIL 无法加载纹理: ", p)
				quit(1)
				return
			sub_tested += 1
			total_atlas_tested += 1
		print("  域 %s 抽检 %d/%d 张纹理全部有效" % [dom.get_file(), sub_tested, pngs.size()])

	print("[SUCCESS] 全量地图关卡场景与图集纹理抽样验证全部 PASS！(抽测关卡 %d 个 / 抽测纹理 %d 张)" % [tested_levels, total_atlas_tested])
	quit(0)
