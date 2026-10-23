extends Node2D

const RecipeData = preload("res://Script/ldl/recipe_data.gd")

@onready var page: Label = $BG/ChangePage/Page
var message

var positon_list = [Vector2(0, -10), Vector2(0, 45), Vector2(0, 100), Vector2(0, 155)]

var z_bl_ist = []
var d_jl_ist = []
var f_bl_ist = []
var s_zl_ist = []
var total_list = []

var l_zb_list = {}
var l_dj_list = {}
var l_fb_list = {}
var l_sz_list = {}
var l_total_list = {}

var total_page: int
var zb_page: int
var dj_page: int
var fb_page: int
var sz_page: int

var current_page: int = 1:
	set(vl):
		current_page = vl
		add_help_items()

var max_page: int

var current_type: int = 0:
	set(vl):
		current_type = vl
		on_current_type_change()

var item_list = []


func _ready():
	for recipe in RecipeData.RECIPES:
		var type = AE.all_equipment[recipe["result"]][DataKeys.TYPE]
		var display_recipe = {
			"cl_1": recipe["materials"][0],
			"cl_2": recipe["materials"][1],
			"cl_3": recipe["materials"][2],
			"scw": recipe["result"]
		}
		total_list.append(display_recipe)
		match type:
			"武器", "防具", "饰品", "头衔":
				z_bl_ist.append(display_recipe)
			"道具", "消耗品":
				d_jl_ist.append(display_recipe)
			"法宝":
				f_bl_ist.append(display_recipe)
			"时装":
				s_zl_ist.append(display_recipe)

	build_page_dicts()

	total_page = get_page(total_list)
	zb_page = get_page(z_bl_ist)
	dj_page = get_page(d_jl_ist)
	fb_page = get_page(f_bl_ist)
	sz_page = get_page(s_zl_ist)

	add_help_items()


func _physics_process(delta):
	match current_type:
		0:
			max_page = total_page
		1:
			max_page = zb_page
		2:
			max_page = dj_page
		3:
			max_page = fb_page
		4:
			max_page = sz_page
	page.text = str(current_page) + "/" + str(max_page)


func build_page_dicts():
	l_total_list = build_page_dict(total_list)
	l_zb_list = build_page_dict(z_bl_ist)
	l_dj_list = build_page_dict(d_jl_ist)
	l_fb_list = build_page_dict(f_bl_ist)
	l_sz_list = build_page_dict(s_zl_ist)


func build_page_dict(list: Array) -> Dictionary:
	var page_dict = {}
	var pages = ceil(list.size() / 4.0)
	for i in range(pages):
		page_dict["page" + str(i + 1)] = []
	for i in range(list.size()):
		var page_idx = floor(i / 4) + 1
		page_dict["page" + str(page_idx)].append(list[i])
	return page_dict


func get_page(list: Array) -> int:
	return ceil(list.size() / 4.0)


func on_current_type_change():
	current_page = 1
	add_help_items()


func add_help_items():
	remove_item()
	var target_count = 0
	var target_dict
	match current_type:
		0:
			target_dict = l_total_list
		1:
			target_dict = l_zb_list
		2:
			target_dict = l_dj_list
		3:
			target_dict = l_fb_list
		4:
			target_dict = l_sz_list
	if target_dict.has("page" + str(current_page)):
		for recipe in target_dict["page" + str(current_page)]:
			item_list.append(Global.add_help_thing(self, positon_list[target_count], recipe))
			target_count += 1


func remove_item():
	for i in item_list:
		if i != null:
			i.queue_free()
	item_list.clear()


func _on_last_pressed():
	if current_page > 1:
		current_page -= 1


func _on_next_pressed():
	if current_page < max_page:
		current_page += 1


func _on_total_pressed():
	current_type = 0


func _on_zb_pressed():
	current_type = 1


func _on_dj_pressed():
	current_type = 2


func _on_fb_pressed():
	current_type = 3


func _on_sz_pressed():
	current_type = 4


func _on_close_pressed():
	queue_free()


func add_text(text, parent):
	if message == null:
		message = Global.add_basic_monment_info(parent, text, get_global_mouse_position() + Vector2(40, 40))


func remove_text():
	if message != null:
		message.queue_free()


func _on_other_help_mouse_entered():
	add_text("同类型的装备均可以参与法宝合成！", get_parent())


func _on_other_help_mouse_exited():
	remove_text()
