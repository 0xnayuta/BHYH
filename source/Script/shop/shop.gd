extends Node2D

const SHOP_BASE_SIZE := Vector2(940.0, 591.0)
const SHOP_SHADOW_FADE := 55.0
const SHOP_CATEGORY_ALL := "全部"
const SHOP_CATEGORY_EQUIPMENT := "装备"
const SHOP_CATEGORY_ITEM := "道具"
const SHOP_CATEGORY_FASHION := "时装"
const SHOP_CATEGORY_WING := "翅膀"

@onready var bg_2: Sprite2D = $BG/BG2
@onready var page: Label = $BG/BG2/HBoxContainer/page
@onready var role: Label = $BG/BG2/bg_3/Role
@onready var line_edit: LineEdit = $BG/BG2/HBoxContainer2/LineEdit

var get_item_name: String = ""
var current_page: int = 1:
	set(vl):
		if current_page != vl:
			current_page = vl
			change_page()
var max_page: int = 1
var list_x = [-220, 0, 220, -220, 0, 220, -220, 0, 220]
var list_y = [-120, -120, -120, -20, -20, -20, 80, 80, 80]
var playe_id = int(PlayerData.player_data["Myself"])

var custom_shop_items = {
	"装备":
	[
		{"名字": "tpys", "灵魂": 2000000},
		{"名字": "qtds", "灵魂": 2000000},
		{"名字": "jldj", "灵魂": 2000000},
		{"名字": "lwstz", "灵魂": 2000000},
		{"名字": "jcz", "灵魂": 2000000},
		{"名字": "sqsryx", "灵魂": 2000000},
		{"名字": "sxyr", "灵魂": 1},
		{"名字": "htd", "灵魂": 6660000},
		{"名字": "zlwg", "灵魂": 1000000},
		{"名字": "jjwq", "灵魂": 1000000},
		{"名字": "jjfj", "灵魂": 1000000},
		{"名字": "lemhz", "灵魂": 1000000},
		{"名字": "lemhg", "灵魂": 1000000},
		{"名字": "wsleg", "灵魂": 1000000},
		{"名字": "wslej", "灵魂": 1000000},
		{"名字": "ysszg", "灵魂": 1000000},
		{"名字": "ysszj", "灵魂": 1000000},
		{"名字": "bthl", "灵魂": 1000000},
		{"名字": "lgdwc", "灵魂": 1000000},
		{"名字": "lgdwz", "灵魂": 1000000},
		{"名字": "nbz", "灵魂": 1000000},
		{"名字": "nbzh", "灵魂": 1000000},
		{"名字": "dmysz", "灵魂": 1000000},
		{"名字": "dmyszh", "灵魂": 1000000},
		{"名字": "psdx", "灵魂": 1},
		{"名字": "hhez", "灵魂": 1},
		{"名字": "lxhjq", "灵魂": 1},
		{"名字": "ssqb", "灵魂": 1000000},
		{"名字": "mlhfg", "灵魂": 1000000},
		{"名字": "mlhfz", "灵魂": 1000000},
	],
	"道具":
	[
		{"名字": "qhs_1", "灵魂": 3000},
		{"名字": "qhs_2", "灵魂": 8000},
		{"名字": "qhs_3", "灵魂": 20000},
		{"名字": "qhs_4", "灵魂": 40000},
		{"名字": "yll", "灵魂": 5000},
		{"名字": "xydxq", "灵魂": 5000},
		{"名字": "xys", "灵魂": 5000},
		{"名字": "mpyj", "灵魂": 5000},
		{"名字": "wxxls", "灵魂": 5000},
		{"名字": "czlxls", "灵魂": 5000},
		{"名字": "xuantie", "灵魂": 10},
		{"名字": "sichou", "灵魂": 10},
		{"名字": "tanmu", "灵魂": 10},
		{"名字": "ttlp", "灵魂": 5000},
		{"名字": "ttsl", "灵魂": 5000},
		{"名字": "tss", "灵魂": 50000},
		{"名字": "yhs", "灵魂": 50000},
		{"名字": "tlz", "灵魂": 50000},
		{"名字": "llz", "灵魂": 50000},
		{"名字": "flz", "灵魂": 50000},
		{"名字": "hlz", "灵魂": 50000},
		{"名字": "slz", "灵魂": 50000},
		{"名字": "gjjs_3", "灵魂": 50000},
		{"名字": "mfjs_3", "灵魂": 50000},
		{"名字": "smjs_3", "灵魂": 50000},
		{"名字": "bjs_6", "灵魂": 1000000},
		{"名字": "mzs_6", "灵魂": 1000000},
		{"名字": "pms_6", "灵魂": 1000000},
		{"名字": "wfs_6", "灵魂": 1000000},
		{"名字": "gjs_6", "灵魂": 1000000},
		{"名字": "mfs_6", "灵魂": 1000000},
		{"名字": "rxs_6", "灵魂": 1000000},
		{"名字": "sms_6", "灵魂": 1000000},
		{"名字": "bms_6", "灵魂": 1000000},
		{"名字": "hxs_6", "灵魂": 1000000},
		{"名字": "sbs_6", "灵魂": 1000000},
		{"名字": "pjs_6", "灵魂": 1000000},
		{"名字": "hms_6", "灵魂": 1000000},
		{"名字": "fls_6", "灵魂": 1000000},
		{"名字": "xys_6", "灵魂": 1000000},
	],
	"时装":
	[
		{"名字": "shenqizlwsz", "灵魂": 2000000},
		{"名字": "shenqinmwsz", "灵魂": 2000000},
		{"名字": "shenqismsrsz", "灵魂": 2000000},
		{"名字": "shenqittzssz", "灵魂": 2000000},
		{"名字": "xnsz", "灵魂": 100000},
		{"名字": "bjbsz", "灵魂": 100000},
		{"名字": "bjhowdg", "灵魂": 100000},
		{"名字": "bjhwdg", "灵魂": 100000},
		{"名字": "bjhzyf", "灵魂": 100000},
		{"名字": "bjmrz", "灵魂": 100000},
		{"名字": "blbsz", "灵魂": 100000},
		{"名字": "blhowdg", "灵魂": 100000},
		{"名字": "blhwdg", "灵魂": 100000},
		{"名字": "blhzyf", "灵魂": 100000},
		{"名字": "blmrz", "灵魂": 100000},
		{"名字": "ssbsz", "灵魂": 100000},
		{"名字": "sshowdg", "灵魂": 100000},
		{"名字": "ssxsz", "灵魂": 100000},
		{"名字": "sshzyf", "灵魂": 100000},
		{"名字": "ssmrz", "灵魂": 100000},
		{"名字": "tsbsz", "灵魂": 100000},
		{"名字": "tshowdg", "灵魂": 100000},
		{"名字": "tshwdg", "灵魂": 100000},
		{"名字": "tshzyf", "灵魂": 100000},
		{"名字": "tsmrz", "灵魂": 100000},
		{"名字": "wkbsz", "灵魂": 100000},
		{"名字": "wkhwdg", "灵魂": 100000},
		{"名字": "wklzyf", "灵魂": 100000},
		{"名字": "wkwdg", "灵魂": 100000},
		{"名字": "wkhzyf", "灵魂": 100000},
		{"名字": "wkmrz", "灵魂": 100000},
	],
	"翅膀":
	[
		{"名字": "xqzy", "灵魂": 20000},
		{"名字": "bszy", "灵魂": 20000},
		{"名字": "ymzy", "灵魂": 20000},
		{"名字": "wyzy", "灵魂": 40000},
		{"名字": "jmzy", "灵魂": 400000},
		{"名字": "ttzy", "灵魂": 600000},
		{"名字": "xtzy", "灵魂": 600000},
		{"名字": "xmzy", "灵魂": 1200000},
		{"名字": "ryzy", "灵魂": 2000000},
	],
}

var current_type = SHOP_CATEGORY_ALL:
	set(vl):
		get_item_name = ""
		if line_edit != null:
			line_edit.text = ""
		current_type = str(vl)
		current_page = 1
		change_page()

var total_item_list = []
var _custom_shop_item_types = {}
var shop_item_list = []
var _shop_shadow_rects := []
var _shop_shadow_shader: Shader


func _get_shop_shadow_shader() -> Shader:
	if _shop_shadow_shader != null:
		return _shop_shadow_shader
	_shop_shadow_shader = Shader.new()
	_shop_shadow_shader.code = "\nshader_type canvas_item;\nuniform int side = 0;\nuniform vec2 rect_size = vec2(1.0, 1.0);\nuniform float solid_px = 0.0;\nuniform float fade_px = 55.0;\nuniform float noise_strength_px = 10.0;\nuniform float noise_scale_px = 85.0;\nuniform float alpha_power = 1.45;\n\nfloat hash(vec2 p) {\n    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);\n}\n\nfloat noise(vec2 p) {\n    vec2 i = floor(p);\n    vec2 f = fract(p);\n    vec2 u = f * f * (3.0 - 2.0 * f);\n    float a = hash(i);\n    float b = hash(i + vec2(1.0, 0.0));\n    float c = hash(i + vec2(0.0, 1.0));\n    float d = hash(i + vec2(1.0, 1.0));\n    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);\n}\n\nvoid fragment() {\n    vec2 px = UV * rect_size;\n    float inward_px = px.y;\n    float edge_axis_px = px.x;\n    if (side == 1) {\n        inward_px = rect_size.y - px.y;\n        edge_axis_px = px.x;\n    } else if (side == 2) {\n        inward_px = px.x;\n        edge_axis_px = px.y;\n    } else if (side == 3) {\n        inward_px = rect_size.x - px.x;\n        edge_axis_px = px.y;\n    }\n    float n1 = noise(vec2(edge_axis_px / noise_scale_px, 0.37));\n    float n2 = noise(vec2(edge_axis_px / (noise_scale_px * 0.43), 8.91));\n    float wobble_px = ((n1 * 0.72 + n2 * 0.28) - 0.5) * noise_strength_px;\n    float fade_t = clamp((inward_px - solid_px + wobble_px) / max(fade_px, 1.0), 0.0, 1.0);\n    fade_t = smoothstep(0.0, 1.0, fade_t);\n    float alpha = pow(1.0 - fade_t, alpha_power) * 0.68;\n    COLOR = vec4(0.0, 0.0, 0.0, alpha);\n}\n"

	return _shop_shadow_shader


func _cleanup_shop_shadow_rects() -> void:
	var names = ["ShopShadowTop", "ShopShadowBottom", "ShopShadowLeft", "ShopShadowRight"]
	var p = get_parent()
	if p != null:
		for child in p.get_children():
			if child != null and child.name in names:
				child.queue_free()
	for rect in _shop_shadow_rects:
		if rect != null and is_instance_valid(rect):
			rect.queue_free()
	_shop_shadow_rects.clear()


func _exit_tree() -> void:
	_cleanup_shop_shadow_rects()


func _ensure_shop_shadow_rects() -> void:
	if _shop_shadow_rects.size() > 0:
		return
	_cleanup_shop_shadow_rects()
	for i in range(4):
		var rect := ColorRect.new()
		rect.name = ["ShopShadowTop", "ShopShadowBottom", "ShopShadowLeft", "ShopShadowRight"][i]
		rect.color = Color.WHITE
		rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		rect.z_index = 1000
		var material := ShaderMaterial.new()
		material.shader = _get_shop_shadow_shader()
		material.set_shader_parameter("side", i)
		rect.material = material
		get_parent().add_child(rect)
		_shop_shadow_rects.append(rect)


func _set_shadow_rect(index: int, _pos: Vector2, _size: Vector2, solid_px_: float, fade_px_: float) -> void:
	var rect: ColorRect = _shop_shadow_rects[index]
	rect.position = _pos
	rect.size = Vector2(max(_size.x, 0.0), max(_size.y, 0.0))
	rect.visible = rect.size.x > 0.5 and rect.size.y > 0.5
	if rect.material is ShaderMaterial:
		(rect.material as ShaderMaterial).set_shader_parameter("rect_size", rect.size)
		(rect.material as ShaderMaterial).set_shader_parameter("solid_px", max(solid_px_, 0.0))
		(rect.material as ShaderMaterial).set_shader_parameter("fade_px", max(fade_px_, 1.0))


func _layout_fullscreen() -> void:
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var fit_scale = min(viewport_size.x / SHOP_BASE_SIZE.x, viewport_size.y / SHOP_BASE_SIZE.y)
	var shop_size = SHOP_BASE_SIZE * fit_scale
	scale = Vector2(fit_scale, fit_scale)
	position = (viewport_size - shop_size) * 0.5
	_cleanup_shop_shadow_rects()


func _read_custom_item_name(item: Dictionary) -> String:
	return str(item.get(DataKeys.NAME, item.get("id", item.get("name", ""))))


func _read_custom_item_price(item: Dictionary) -> int:
	if item.has("灵魂"):
		return int(item["灵魂"])
	if item.has("price"):
		return int(item["price"])
	if item.has("cost"):
		return int(item["cost"])
	var item_name := _read_custom_item_name(item)
	if AE.all_equipment.has(item_name):
		return get_price_by_quality(str(AE.all_equipment[item_name].get(DataKeys.QUALITY, "")))
	return 0


func _normalize_custom_shop_item(item: Dictionary, category: String) -> Dictionary:
	var item_name := _read_custom_item_name(item)
	if item_name == "":
		return {}
	if not AE.all_equipment.has(item_name):
		push_warning("商店商品不存在: " + item_name)
		return {}
	_custom_shop_item_types[item_name] = category
	return {"id": item_name, "price": _read_custom_item_price(item)}


func _load_custom_shop_items() -> void:
	total_item_list.clear()
	_custom_shop_item_types.clear()
	for category in [SHOP_CATEGORY_EQUIPMENT, SHOP_CATEGORY_ITEM, SHOP_CATEGORY_FASHION, SHOP_CATEGORY_WING]:
		for item in custom_shop_items.get(category, []):
			if item is Dictionary:
				var normalized := _normalize_custom_shop_item(item, category)
				if normalized.size() > 0:
					total_item_list.push_back(normalized)
	if Global.is_hidden_feature_enabled(Global.HIDDEN_FEATURE_ALL_SHOP_ITEMS):
		_append_all_equipment_items()


func _append_all_equipment_items() -> void:
	var existing_ids := {}
	for item in total_item_list:
		if item is Dictionary:
			existing_ids[_shop_item_id(item)] = true
	var item_ids: Array = AE.all_equipment.keys()
	item_ids.sort()
	for item_id_value in item_ids:
		var item_id := str(item_id_value)
		if existing_ids.has(item_id):
			continue
		var item_data: Variant = AE.all_equipment.get(item_id, {})
		if not (item_data is Dictionary):
			continue
		var category := _shop_category_for_type(str(item_data.get(DataKeys.TYPE, "")))
		if category == "":
			continue
		_custom_shop_item_types[item_id] = category
		total_item_list.push_back(
			{"id": item_id, "price": get_price_by_quality(str(item_data.get(DataKeys.QUALITY, "")))}
		)


func _shop_category_for_type(item_type: String) -> String:
	match item_type:
		"道具", "消耗品":
			return SHOP_CATEGORY_ITEM
		"时装":
			return SHOP_CATEGORY_FASHION
		"翅膀":
			return SHOP_CATEGORY_WING
		"武器", "防具", "饰品", "头衔", "法宝", "宠物装备":
			return SHOP_CATEGORY_EQUIPMENT
		_:
			return ""


func _shop_item_id(item: Dictionary) -> String:
	return str(item.get("id", item.get(DataKeys.NAME, "")))


func _shop_item_price(item: Dictionary) -> int:
	if Global.is_hidden_feature_enabled(Global.HIDDEN_FEATURE_FREE_SHOP):
		return 0
	return int(item.get("price", item.get("灵魂", 0)))


func _current_role_owner_name() -> String:
	match playe_id:
		1:
			return "悟空"
		2:
			return "唐僧"
		3:
			return "八戒"
		4:
			return "沙僧"
		5:
			return "白龙"
		6:
			return "哪吒"
		7:
			return "玉兔"
		_:
			return ""


func _is_fashion_for_current_role(item_id: String) -> bool:
	var item_data: Dictionary = AE.all_equipment[item_id]
	var owner := str(item_data.get("所属", "")).strip_edges()
	return owner == "通用" or owner == _current_role_owner_name()


func _is_shop_item_for_current_role(item_id: String) -> bool:
	if Global.is_hidden_feature_enabled(Global.HIDDEN_FEATURE_ALL_SHOP_ITEMS):
		return true
	return _is_fashion_for_current_role(item_id)


func _ready() -> void:
	_layout_fullscreen()
	if not get_viewport().size_changed.is_connected(_layout_fullscreen):
		get_viewport().size_changed.connect(_layout_fullscreen)
	playe_id = int(PlayerData.player_data["Myself"])
	_load_custom_shop_items()
	set_role_name()
	page.text = str(current_page) + "/" + str(max_page)
	add_shop_item()
	if not line_edit.text_changed.is_connected(_on_line_edit_text_changed):
		line_edit.text_changed.connect(_on_line_edit_text_changed)


func get_price_by_quality(quality: String) -> int:
	match quality:
		"普通":
			return 5000
		"优秀":
			return 10000
		"精良":
			return 20000
		"史诗":
			return 40000
		"邪灵":
			return 160000
		"魂器":
			return 320000
		"传说":
			return 640000
		"神器":
			return 1280000
		_:
			return 5000


func _is_shop_item_visible(item) -> bool:
	if not item is Dictionary:
		return false
	var item_id := _shop_item_id(item)
	if item_id == "" or not AE.all_equipment.has(item_id):
		return false
	var item_category := str(_custom_shop_item_types.get(item_id, ""))
	if current_type == SHOP_CATEGORY_ALL:
		if item_category == SHOP_CATEGORY_FASHION or item_category == SHOP_CATEGORY_EQUIPMENT:
			return _is_shop_item_for_current_role(item_id)
		return true
	if item_category != current_type:
		return false
	if current_type == SHOP_CATEGORY_FASHION or current_type == SHOP_CATEGORY_EQUIPMENT:
		return _is_shop_item_for_current_role(item_id)
	return true


func set_current_page_type_items():
	var get_target_list = []
	if get_item_name != "":
		var keyword = get_item_name.strip_edges().to_lower()
		for item in total_item_list:
			if _is_shop_item_visible(item):
				var item_id := _shop_item_id(item)
				var item_name = str(AE.all_equipment[item_id].get(DataKeys.NAME, item_id)).to_lower()
				if keyword in item_name:
					get_target_list.append(item)
	else:
		for item in total_item_list:
			if _is_shop_item_visible(item):
				get_target_list.append(item)

	var total = get_target_list.size()
	var max_page = max(1, int(ceil(total / 9.0)))
	max_page = max_page

	var my_list = {}
	for p in range(max_page):
		my_list["Page_" + str(p + 1)] = []

	var page_idx = 1
	for item in get_target_list:
		var page_key = "Page_" + str(page_idx)
		if my_list[page_key].size() < 9:
			my_list[page_key].append(item)
		else:
			page_idx += 1
			my_list["Page_" + str(page_idx)].append(item)

	return my_list


func _physics_process(_delta: float) -> void:
	page.text = str(current_page) + "/" + str(max_page)
	$BG/lh_bg/lh_.text = str(PlayerData.get_soul())


func set_role_name():
	match playe_id:
		1:
			role.text = "角色：悟空"
		2:
			role.text = "角色：唐僧"
		3:
			role.text = "角色：八戒"
		4:
			role.text = "角色：沙僧"
		5:
			role.text = "角色：白龙"
		6:
			role.text = "角色：哪吒"
		7:
			role.text = "角色：玉兔"


func _on_last_pressed() -> void:
	if current_page > 1:
		current_page -= 1
		page.text = str(current_page) + "/" + str(max_page)


func _on_next_pressed() -> void:
	if current_page < max_page:
		current_page += 1
		page.text = str(current_page) + "/" + str(max_page)


func change_page():
	for i in shop_item_list:
		if i != null and is_instance_valid(i):
			i.queue_free()
	shop_item_list.clear()
	add_shop_item()


func add_shop_item():
	var page_items = set_current_page_type_items()
	var key = "Page_" + str(current_page)
	if page_items.has(key):
		var items = page_items[key]
		var idx = 0
		for item in items:
			var pos = Vector2(list_x[idx], list_y[idx])
			var target = Global.add_shop_items($BG/BG2, pos, _shop_item_id(item), _shop_item_price(item))
			if target != null:
				shop_item_list.append(target)
			idx += 1


func _on_close_pressed() -> void:
	queue_free()


func _on_charge_pressed() -> void:
	Global.add_message_show(Global.get_ui_runtime().windows, "充值渠道已关闭，无法充值，请使用灵魂购买商品。", 1.5, Vector2(485, 295))


func _on_total_pressed() -> void:
	current_type = SHOP_CATEGORY_ALL


func _on_zb_pressed() -> void:
	current_type = SHOP_CATEGORY_EQUIPMENT


func _on_dj_pressed() -> void:
	current_type = SHOP_CATEGORY_ITEM


func _on_sz_pressed() -> void:
	current_type = SHOP_CATEGORY_FASHION


func _on_cb_pressed() -> void:
	current_type = SHOP_CATEGORY_WING


func _on_line_edit_text_changed(new_text: String) -> void:
	get_item_name = new_text


func _on_qd_pressed() -> void:
	current_page = 1
	change_page()
