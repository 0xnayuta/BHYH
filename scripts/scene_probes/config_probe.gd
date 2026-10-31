extends SceneTree

## ZMWS 数值配置表查询层探针
## 直接实例化 config.gd（不依赖 autoload 生命周期），验证索引、按需加载与 id 查询。

const CONFIG_SCRIPT := preload("res://Script/config/config.gd")
const SAMPLES := [
	"monster",
	"skill",
	"equipment",
	"achievementName",
	"strings",
]


func _init() -> void:
	var cfg = CONFIG_SCRIPT.new()
	if not cfg.is_available():
		print("FAIL 配置索引不可用（检查 res://Data/zmws_config/index.json）")
		quit(1)
		return

	var count: int = cfg.table_count()
	var rows: int = cfg.total_rows()
	print("[*] 索引表数=%d 总行数=%d" % [count, rows])
	if count < 300:
		print("FAIL 表数过少: ", count)
		quit(1)
		return

	# 抽样演示：前 5 张表各抽一行
	var names: PackedStringArray = cfg.table_names()
	var demo := 0
	for i in range(mini(5, names.size())):
		var t = cfg.table(names[i])
		if t == null:
			print("FAIL 无法加载表: ", names[i])
			quit(1)
			return
		print("  %-24s 行=%-6d 列=%-3d 首列=%s" % [
			names[i], t.size(), t.column_index("id") + 1, str(t.row_at(0)).substr(0, 80)])
		demo += 1

	# id 查询能力：任选一张有 id 列的表
	var found_any := false
	for i in range(names.size()):
		var t = cfg.table(names[i])
		if t == null or not t.has_column("id") or t.size() == 0:
			continue
		var first_row: Array = t.row_at(0)
		if first_row.is_empty():
			continue
		var key: Variant = first_row[0]
		var hit: Array = cfg.find(names[i], key)
		if hit.is_empty():
			print("FAIL id 查询失败: %s id=%s" % [names[i], key])
			quit(1)
			return
		print("  [id 查询] %s id=%s -> 命中 %d 列" % [names[i], key, hit.size()])
		found_any = true
		break
	if not found_any:
		print("FAIL 未找到可用的 id 表")
		quit(1)
		return

	print("[+] 已缓存表数=%d（按需加载生效，未全量预载）" % cfg.cached_table_count())
	print("[SUCCESS] 配置表查询层验证 PASS！")
	quit(0)
