extends Node

## 通用工具静态类与角色贴图运行时探针（由 scripts/scene_probe_runner.py 复制到工程根目录执行）。
## 验证 NodeUtils 的祖先/向量语义、ItemUtils 的品质前缀清理与随机条目形状，
## 以及 RoleVisualRuntime 的角色贴图加载与同槽位旧贴图释放。

const RESULT_PREFIX := "UTILS_PROBE_RESULT="
const TEARDOWN_MARKER := "UTILS_PROBE_TEARDOWN"
const ROLE_BODY_EMPTY := "res://Art/hero_picture/role_1_all_equipment/role_1_body_empty.png"
const ROLE_BODY_BSXJ := "res://Art/hero_picture/role_1_all_equipment/role_1_body_bsxj.png"
const ROLE_EQ_EMPTY := "res://Art/hero_picture/role_1_all_equipment/role_1_eq_empty.png"

var _failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var checks: Dictionary = {}

	# 祖先链：层级、0 层、越界与空输入。
	var root := Node2D.new()
	root.name = "UtilsRoot"
	add_child(root)
	var middle := Node2D.new()
	root.add_child(middle)
	var leaf := Node2D.new()
	middle.add_child(leaf)
	checks["ancestor_two"] = NodeUtils.ancestor(leaf, 2) == root
	checks["ancestor_zero"] = NodeUtils.ancestor(leaf, 0) == leaf
	checks["ancestor_out_of_range"] = NodeUtils.ancestor(leaf, 10) == null
	checks["ancestor_null"] = NodeUtils.ancestor(null, 1) == null

	# 方向向量：归一化与历史语义（任一轴为 0 返回零向量）。
	var origin := Node2D.new()
	origin.position = Vector2.ZERO
	add_child(origin)
	var diagonal := Node2D.new()
	diagonal.position = Vector2(3, 4)
	add_child(diagonal)
	var vertical := Node2D.new()
	vertical.position = Vector2(0, 5)
	add_child(vertical)
	checks["position_between_unit"] = NodeUtils.position_between(origin, diagonal).is_equal_approx(
		Vector2(0.6, 0.8)
	)
	checks["position_between_axis_zero"] = (
		NodeUtils.position_between(origin, vertical) == Vector2.ZERO
	)
	checks["position_between_null"] = NodeUtils.position_between(origin, null) == Vector2.ZERO
	checks["distance_diagonal"] = is_equal_approx(NodeUtils.distance_between(origin, diagonal), 5.0)
	checks["distance_axis"] = is_equal_approx(NodeUtils.distance_between(origin, vertical), 5.0)
	checks["distance_null"] = is_equal_approx(NodeUtils.distance_between(origin, null), 0.0)

	# 品质前缀清理：真实装备 ID 与仙羽身体名映射。
	checks["clean_quality_prefix"] = ItemUtils.clean_fashion_name("shenqismsrsz") == "smsrsz"
	checks["clean_xianyu_body"] = ItemUtils.clean_fashion_name("xyfjwk") == "wkxysz"
	checks["clean_untouched"] = ItemUtils.clean_fashion_name("wkxysz") == "wkxysz"

	# 随机条目：形状、总次数守恒、零值条目被剔除。
	var entries := ItemUtils.random_item_entries(["probe_a", "probe_b"], 50, 1)
	var total_value := 0
	var shape_ok := true
	var source_ok := true
	for entry in entries:
		var entry_dict := entry as Dictionary
		if entry_dict == null or not entry.has_all(["Name", "Value", "Prop", "WX", "strength_value"]):
			shape_ok = false
			continue
		total_value += int(entry_dict["Value"])
		if str(entry_dict["Name"]) not in ["probe_a", "probe_b"]:
			source_ok = false
		if int(entry_dict["Value"]) <= 0:
			shape_ok = false
	checks["entries_shape"] = shape_ok and entries.size() > 0
	checks["entries_total"] = total_value == 50
	checks["entries_source"] = source_ok

	# 五行组合：个数正确、元素取自五行、互不重复、越界返回空。
	var elements: Array = ItemUtils.FIVE_ELEMENTS
	var set_one := ItemUtils.random_element_set(1)
	var set_three := ItemUtils.random_element_set(3)
	var set_four := ItemUtils.random_element_set(4)
	var set_all := ItemUtils.random_element_set(5)
	var set_zero := ItemUtils.random_element_set(0)
	var set_invalid := ItemUtils.random_element_set(99)
	checks["element_set_sizes"] = (
		set_one.size() == 1
		and set_three.size() == 3
		and set_four.size() == 4
		and set_all.size() == 5
	)
	checks["element_set_full"] = set_all == elements
	checks["element_set_invalid_empty"] = set_invalid.is_empty()
	checks["element_set_weighted_range"] = set_zero.size() >= 1 and set_zero.size() <= 3
	var distinct_ok := true
	for candidate_set in [set_one, set_three, set_four, set_all, set_zero]:
		var seen := {}
		for element in candidate_set:
			if str(element) not in elements or seen.has(element):
				distinct_ok = false
			seen[element] = true
	checks["element_set_distinct_in_domain"] = distinct_ok

	# 角色贴图：同一槽位连续换贴图时释放上一张，缓存只保留当前一张。
	var role_visual := Global.get_role_visual_runtime()
	checks["role_runtime_present"] = role_visual != null
	checks["role_id_in_range"] = role_visual.current_role_id() >= 1 and role_visual.current_role_id() <= 7
	var body_first: Texture2D = Global.load_role1_body("Empty", 1)
	checks["role_body_loaded"] = body_first != null
	checks["role_body_cached"] = Global.is_resource_cached(ROLE_BODY_EMPTY)
	var body_second: Texture2D = Global.load_role1_body("bsxj", 1)
	checks["role_body_switched"] = body_second != null and body_second != body_first
	checks["role_body_previous_released"] = not Global.is_resource_cached(ROLE_BODY_EMPTY)
	checks["role_body_current_cached"] = Global.is_resource_cached(ROLE_BODY_BSXJ)
	var equipment: Texture2D = Global.load_role1_eq("Empty", 1)
	checks["role_equipment_loaded"] = equipment != null
	checks["role_equipment_cached"] = Global.is_resource_cached(ROLE_EQ_EMPTY)

	role_visual.reset()
	Global.release_cached_texture(ROLE_BODY_BSXJ)
	Global.release_cached_texture(ROLE_EQ_EMPTY)
	checks["role_cache_released"] = (
		not Global.is_resource_cached(ROLE_BODY_BSXJ) and not Global.is_resource_cached(ROLE_EQ_EMPTY)
	)
	for node in [leaf, middle, root, vertical, diagonal, origin]:
		if is_instance_valid(node):
			node.queue_free()

	for check_name in checks:
		if not bool(checks[check_name]):
			_failures.append(str(check_name))
	var payload := {"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": checks}
	print(RESULT_PREFIX + JSON.stringify(payload))
	print(TEARDOWN_MARKER)
	get_tree().quit(0 if _failures.is_empty() else 1)
