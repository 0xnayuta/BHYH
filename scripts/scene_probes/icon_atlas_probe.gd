extends SceneTree

## 图标图集探针：验证 ZMWS 导出的独立 PNG 能被 load() 取到且是 Texture2D。
## 用法：godot --headless --path source --script res://scripts/scene_probes/icon_atlas_probe.gd

const SAMPLE_COUNT := 12


func _init() -> void:
	var dir := "res://Art/backpack/all_items"
	var files: Array[String] = []
	var handle := DirAccess.open(dir)
	if handle == null:
		print("FAIL 打不开 ", dir)
		quit(1)
		return
	for name in handle.get_files():
		if name.ends_with(".png"):
			files.append(name.get_basename())
	files.sort()
	if files.is_empty():
		print("FAIL ", dir, " 下没有 png")
		quit(1)
		return

	var step := maxi(1, files.size() / SAMPLE_COUNT)
	var ok := 0
	var bad := 0
	for i in range(0, files.size(), step):
		var stem := files[i]
		var path := "%s/%s.png" % [dir, stem]
		if not ResourceLoader.exists(path):
			print("MISS ", path)
			bad += 1
			continue
		var res: Resource = load(path)
		if res is Texture2D:
			ok += 1
		else:
			print("BAD  ", stem, " -> ", res)
			bad += 1

	print("扫描文件数=", files.size(), " 抽样=", ok + bad, " 可加载=", ok, " 失败=", bad)
	print("RESULT ", "PASS" if bad == 0 else "FAIL")
	quit(0 if bad == 0 else 1)
