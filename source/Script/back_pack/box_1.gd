extends Button

const SYNTHESIS_ALLOWED_TREASURES := [
	"yyzlj",
	"ywhl",
	"sxyg",
	"zhyx",
	"bjs",
	"yyb",
	"dkhl",
	"hehua",
]


## 法宝默认不能参与合成，但八仙/太极八卦材料按 6.6 语义例外放行。
static func is_synthesis_allowed(item_type: String, item_id: String) -> bool:
	return item_type != "法宝" or item_id in SYNTHESIS_ALLOWED_TREASURES


## 显式操作者：按所在面板的槽位解析数据与属性，不依赖全局 1P/2P 视图交换。
var PlayerData: PlayerDataStore:
	get:
		return LocalCoop.data_for(self) as PlayerDataStore
var RoleProp: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self) as BaseRoleProperties

var get_item_name: String
var get_type
var add_equ_box
var sell_box
var qh_level: int
var eq_prop = {}
var total_number: int
var current_page: int
var gl_po: Vector2
var is_in_ldl_gz = false
var is_in_shop = false
var wx = []
var is_in_hh = false
var is_in_hhgz = false
var get_tt
var hide_prop: bool
var forge_bzid: int
var is_choose: bool
var main_back
@onready var item_number: Label = $item_number
var is_in_ldl
var strength_source := "装备背包"
var strength_index := -1
var item_locked := false
@onready var lock_mark: Label = $lock_mark
var _refresh_elapsed := 0.0
var _refresh_primed := false
var _last_refresh_signature := ""


func _get_strength_max_level(item_name: String) -> int:
	return PlayerData.get_equipment_strength_max_level(eq_prop, item_name)


func _ready() -> void:
	set_process(false)
	is_in_ldl = Global.get_ui_runtime().is_ldl_mode_active()

	if strength_source == "宠物背包":
		get_type = "宠物装备"
		item_number.text = "+%d" % qh_level if qh_level > 0 else ""
	elif has_meta("level_fall_box") and str(get_meta("item_name", "")) != "":
		get_item_name = str(get_meta("item_name"))
	elif str(get_meta("item_name", "")) != "":
		get_item_name = str(get_meta("item_name"))
	elif icon != null and icon is Texture2D:
		var icon_name := icon.resource_path.get_file().get_basename()
		get_item_name = icon_name if icon_name != "" else "empty"
	else:
		get_item_name = "empty"


func _process(_delta: float) -> void:
	if add_equ_box == null or not is_instance_valid(add_equ_box):
		add_equ_box = null
		set_process(false)
		return
	var popup_parent: Node = add_equ_box.get_parent()
	if popup_parent == null:
		popup_parent = _get_window_parent()
	gl_po = Global.popup_position_for_parent(popup_parent, Vector2(25, 20))
	if add_equ_box.has_method("layout_at"):
		add_equ_box.call("layout_at", gl_po)
	else:
		add_equ_box.position = gl_po


func _physics_process(delta: float) -> void:
	_refresh_elapsed += delta
	if _refresh_primed and _refresh_elapsed < 0.1:
		return
	_refresh_primed = true
	_refresh_elapsed = 0.0
	lock_mark.visible = item_locked and get_item_name != "empty"

	if strength_source == "宠物背包":
		get_type = "宠物装备"
		item_number.text = "+%d" % qh_level if qh_level > 0 else ""
	elif has_meta("level_fall_box") and str(get_meta("item_name", "")) != "":
		get_item_name = str(get_meta("item_name"))
	elif str(get_meta("item_name", "")) != "":
		get_item_name = str(get_meta("item_name"))
	elif icon != null and icon is Texture2D:
		var icon_name := icon.resource_path.get_file().get_basename()
		get_item_name = icon_name if icon_name != "" else "empty"
	else:
		get_item_name = "empty"

	is_in_ldl = Global.get_ui_runtime().is_ldl_mode_active()

	var refresh_signature := (
		"%s|%s|%s|%s|%s"
		% [
			get_item_name,
			strength_source,
			qh_level,
			total_number,
			icon.resource_path if icon != null else "",
		]
	)
	if refresh_signature == _last_refresh_signature:
		return
	_last_refresh_signature = refresh_signature

	if strength_source == "宠物背包":
		get_type = "宠物装备"
		item_number.text = "+%d" % qh_level if qh_level > 0 else ""
	elif get_item_name != "empty":
		if EquipmentService.has(get_item_name):
			get_type = EquipmentService.data(get_item_name)[DataKeys.TYPE]
			match get_type:
				"武器":
					item_number.text = ""
				"防具":
					item_number.text = ""
				"饰品", "神骨":
					item_number.text = ""
				"法宝":
					item_number.text = ""
				"翅膀":
					item_number.text = ""
				"时装":
					item_number.text = ""
				"头衔":
					item_number.text = ""
				"道具":
					if total_number > 1:
						item_number.text = str(total_number)
					else:
						item_number.text = ""
				"消耗品":
					if total_number > 1:
						item_number.text = str(total_number)
					else:
						item_number.text = ""
		else:
			get_item_name = "empty"
			total_number = 0
			item_number.text = ""
	else:
		total_number = 0
		item_number.text = ""


func on_press_when_in_back():
	var _parent = NodeUtils.ancestor(self, 6)
	var position_vec = Global.popup_position_for_parent(_parent, Vector2(18, 18))
	var number = get_number()
	match get_type:
		"武器", "防具", "饰品", "神骨", "翅膀", "时装", "头衔", "法宝", "时装", "头衔", "翅膀":
			sell_box = Global.add_se_eq_jm(_parent, position_vec, get_item_name, current_page, number)
			_keep_click_menu_near_item(sell_box, _parent)
			sell_box.eq_prop = eq_prop
			sell_box.source_box = self
		"消耗品", "道具":
			var pp = Global.add_dj_sell(_parent, position_vec, get_item_name, current_page)
			_keep_click_menu_near_item(pp, _parent)
			pp.eq_prop = eq_prop
			pp.source_box = self


func _keep_click_menu_near_item(menu: Node, _parent: Node) -> void:
	if menu == null or not (menu is CanvasItem):
		return
	var estimated_size := Vector2(135, 95)
	var canvas_menu := menu as CanvasItem
	var menu_size := PopupLayout.resolved_size(canvas_menu, estimated_size)
	PopupLayout.place_screen(
		canvas_menu, get_viewport().get_mouse_position() + Vector2(18, 18), menu_size, PopupLayout.DEFAULT_MARGIN, true
	)


func on_press_when_strength():
	if bool(eq_prop.get("不可强化", false)) and get_item_name not in ["cjxianjie", "cdxianjie", "zhxianjie"]:
		var _parent = NodeUtils.ancestor(self, 7)
		Global.add_message_show(_parent, "该装备不可强化！", 1.5)
		return
	var get_tt = "宠物装备" if strength_source == "宠物背包" else EquipmentService.data(get_item_name)[DataKeys.TYPE]
	if get_tt != "道具" and get_tt != "消耗品" and get_tt != "法宝":
		var max_level = _get_strength_max_level(get_item_name)
		if qh_level < max_level:
			MLdl.qh_list[DataKeys.NAME] = get_item_name
			MLdl.qh_list[DataKeys.ENHANCE_LEVEL] = qh_level
			MLdl.qh_list["页码"] = current_page
			MLdl.qh_list["位置"] = strength_index if strength_index >= 0 else int(str(self.name).split("_")[1]) - 1
			MLdl.qh_list["来源"] = strength_source
			MLdl.qh_list["穿戴栏"] = str(get_meta("equipped_type", ""))
			MLdl.qh_list["Data"] = eq_prop
		else:
			var _parent = NodeUtils.ancestor(self, 7)
			Global.add_message_show(_parent, "装备等级已达最高等级！！无法继续强化！", 1.5)


func on_press_when_divine_forge() -> void:
	var item_data: Dictionary = EquipmentService.data_or_empty(get_item_name)
	if item_data.is_empty() or not EquipmentService.rules().can_divine_forge(StringName(get_item_name), eq_prop):
		var _parent = NodeUtils.ancestor(self, 7)
		Global.add_message_show(_parent, "只有神器及以上品质的武器、防具和饰品可以神铸！", 1.5)
		return
	MLdl.qh_list[DataKeys.NAME] = get_item_name
	MLdl.qh_list[DataKeys.ENHANCE_LEVEL] = qh_level
	MLdl.qh_list["页码"] = _get_equipment_source_page()
	MLdl.qh_list["位置"] = _get_equipment_source_index()
	MLdl.qh_list["来源"] = strength_source
	MLdl.qh_list["穿戴栏"] = str(get_meta("equipped_type", ""))
	MLdl.qh_list["Data"] = eq_prop.duplicate(true)


func on_press_when_bone_forge() -> void:
	var item_data: Dictionary = EquipmentService.data_or_empty(get_item_name)
	var item_type := str(eq_prop.get(DataKeys.TYPE, item_data.get(DataKeys.TYPE, "")))
	var next_stage := str(eq_prop.get("下一阶段", item_data.get("下一阶段", "")))
	if item_data.is_empty() or item_type != "神骨" or next_stage == "":
		var _parent = NodeUtils.ancestor(self, 7)
		Global.add_message_show(_parent, "只有设置了下一阶段的神骨装备才可以淬骨！", 1.5)
		return
	MLdl.qh_list[DataKeys.NAME] = get_item_name
	MLdl.qh_list[DataKeys.ENHANCE_LEVEL] = qh_level
	MLdl.qh_list["页码"] = _get_equipment_source_page()
	MLdl.qh_list["位置"] = _get_equipment_source_index()
	MLdl.qh_list["来源"] = strength_source
	MLdl.qh_list["穿戴栏"] = str(get_meta("equipped_type", ""))
	MLdl.qh_list["Data"] = eq_prop.duplicate(true)


func _has_socketed_gems(data: Dictionary) -> bool:
	for key in data.keys():
		if str(key) != "宝石" and str(key) != "��ʯ":
			continue
		var gems = data[key]
		if gems is Array:
			for gem in gems:
				if str(gem) != "":
					return true
		elif gems is Dictionary:
			return gems.size() > 0
		elif gems != null and str(gems) != "":
			return true
	return false


func on_press_when_synthesis():
	if strength_source == "人物穿戴":
		var equipped_parent = NodeUtils.ancestor(self, 7)
		Global.add_message_show(equipped_parent, "请先将穿戴中的装备卸下后再进行合成！", 1.5)
		return

	if not is_in_ldl_gz:
		var _parent = NodeUtils.ancestor(self, 7)
		for i in PlayerData.player_data["放入列表"]:
			var mylist = PlayerData.player_data["放入列表"][i]
			if mylist.size() == 0:
				var get_tt = EquipmentService.data(get_item_name)[DataKeys.TYPE]
				if not is_synthesis_allowed(str(get_tt), str(get_item_name)):
					Global.add_message_show(_parent, "法宝无法参与合成！！！", 1.5)
					return
				if get_tt == "消耗品":
					Global.add_message_show(_parent, "消耗品无法参与合成！！！", 1.5)
					return
				PlayerData.player_data["放入列表"][i].push_back(str(get_item_name))
				PlayerData.player_data["放入列表"][i].push_back(PlayerData.get_dj_page(get_item_name))
				PlayerData.player_data["放入列表"][i].push_back(int(str(self.name).split("_")[1]) - 1)
				PlayerData.player_data["放入列表"][i].push_back(qh_level)
				PlayerData.player_data["放入列表"][i].push_back(eq_prop.duplicate(true))
				if (
					get_tt == "武器"
					or get_tt == "防具"
					or get_tt == "饰品"
					or get_tt == "翅膀"
					or get_tt == "时装"
					or get_tt == "头衔"
				):
					if _has_socketed_gems(eq_prop):
						PlayerData.player_data["放入列表"][i].clear()
						Global.add_message_show(_parent, "请先卸下该装备上的宝石！！！", 1.5)
						return
					else:
						PlayerData.remove_zb(_get_equipment_source_page(), _get_equipment_source_index())
						NodeUtils.ancestor(self, 6).set_box_data()
				elif get_tt == "道具" or get_tt == "消耗品":
					PlayerData.remove_dj(get_item_name, PlayerData.get_dj_page(get_item_name), 1)
					NodeUtils.ancestor(self, 6).set_box_data()
				elif get_tt == "法宝":
					PlayerData.player_data["放入列表"][i].push_back(wx.duplicate())
					PlayerData.remove_zb(_get_equipment_source_page(), _get_equipment_source_index())
					NodeUtils.ancestor(self, 6).set_box_data()
				return
	else:
		var num = str(self.name).split("_")[1]
		if int(num) > 3:
			return
		var list = PlayerData.player_data["放入列表"]["物品" + str(num)]
		if list.has(str(get_item_name)):
			var get_tt = EquipmentService.data(list[0])[DataKeys.TYPE]
			if get_tt == "武器" or get_tt == "防具" or get_tt == "饰品" or get_tt == "翅膀" or get_tt == "时装" or get_tt == "头衔":
				PlayerData.add_zb(get_item_name, list[3], eq_prop)
			elif get_tt == "道具":
				PlayerData.add_dj(list[0], 1)
			elif get_tt == "消耗品":
				PlayerData.add_xhp(list[0], 1)
			elif get_tt == "法宝":
				PlayerData.add_fb(list[0], list[3], list[5] if list.size() > 5 else [], list[4])
			PlayerData.player_data["放入列表"]["物品" + str(num)].clear()
			MemoryClass.request_save("back_pack_box_synthesis")
			return


func on_press_when_dz():
	var forge := Global.get_forge_factory().get_active_forge()
	if forge == null:
		return
	var item_data: Dictionary = EquipmentService.data_or_empty(str(get_item_name))
	if item_data.is_empty():
		return
	var type := str(item_data.get(DataKeys.TYPE, ""))
	var have := str(item_data.get("所属", ""))
	var item_name := str(item_data.get(DataKeys.NAME, ""))
	if type == "" or have == "" or item_name == "":
		Global.add_message_show(NodeUtils.ancestor(self, 7), "物品数据异常，无法参与打造！", 1.5)
		return
	var _parent = NodeUtils.ancestor(self, 7)
	if not is_in_ldl_gz:
		if type != "道具":
			Global.add_message_show(_parent, str(item_name) + "不可以参与打造！", 1.5)
			return
		if forge.zzs.get_children().size() <= 0:
			if have != "制作书":
				Global.add_message_show(_parent, "只有制作书可以参与打造！", 1.5)
				return
			else:
				forge.replace_book(get_item_name, qh_level, eq_prop)
		else:
			if have != "制作书":
				var count_baozhu = 0
				var count_jingshi = 0
				var jewels_value: Variant = PlayerData.player_data.get("宝珠列表", [])
				if not jewels_value is Array:
					Global.add_message_show(_parent, "宝珠数据异常，无法参与打造！", 1.5)
					return
				for item_value in jewels_value as Array:
					if not item_value is Dictionary:
						continue
					var item: Dictionary = item_value
					var jewel_name := str(item.get(DataKeys.NAME, ""))
					var jewel_data: Variant = EquipmentService.data_or_empty(jewel_name)
					if not jewel_data is Dictionary:
						continue
					var belong := str((jewel_data as Dictionary).get("所属", ""))
					if belong == "宝珠":
						count_baozhu += 1
					elif belong == "晶石":
						count_jingshi += 1

				if have == "宝珠" or have == "晶石":
					if count_baozhu + count_jingshi >= 4:
						Global.add_message_show(_parent, "最多4颗！", 1.5)
						return
				else:
					Global.add_message_show(_parent, "只能放入宝珠或晶石！", 1.5)
					return

				var bz_prop = {"名字": get_item_name, "强化等级": qh_level, "Data": eq_prop.duplicate(true)}
				PlayerData.player_data["宝珠列表"].push_back(bz_prop)
				forge.addbzpic()
				PlayerData.remove_dj(get_item_name, PlayerData.get_dj_page(get_item_name), 1)
				return
			else:
				forge.replace_book(get_item_name, qh_level, eq_prop)
	else:
		forge.remove_bspic(forge_bzid)


func on_press_whenfj():
	if strength_source == "人物穿戴":
		var equipped_parent = NodeUtils.ancestor(self, 7)
		Global.add_message_show(equipped_parent, "穿戴中的装备不能分解，请先卸下！", 1.5)
		return
	if not is_in_ldl_gz:
		var _parent = NodeUtils.ancestor(self, 7)
		var get_tt = EquipmentService.data(get_item_name)[DataKeys.TYPE]
		var base = EquipmentService.data(get_item_name)["所属"]
		var name_str
		if PlayerData.player_data[DataKeys.DECOMPOSE_LIST].size() != 0:
			name_str = PlayerData.player_data[DataKeys.DECOMPOSE_LIST][0][DataKeys.NAME]
			var cur_level = PlayerData.player_data[DataKeys.DECOMPOSE_LIST][0][DataKeys.ENHANCE_LEVEL]
			var data = PlayerData.player_data[DataKeys.DECOMPOSE_LIST][0]["Data"]
			get_tt = EquipmentService.data(name_str)[DataKeys.TYPE]
			match get_tt:
				"武器", "饰品", "防具":
					PlayerData.add_zb(name_str, cur_level, data)
					PlayerData.player_data[DataKeys.DECOMPOSE_LIST].clear()
				"道具":
					PlayerData.add_dj(name_str, 1)
					PlayerData.player_data[DataKeys.DECOMPOSE_LIST].clear()
		var get_tt2 = EquipmentService.data(get_item_name)[DataKeys.TYPE]
		match get_tt2:
			"法宝":
				Global.add_message_show(_parent, "法宝不可以分解！！", 1.5)
				return
			"消耗品":
				Global.add_message_show(_parent, "消耗品不可以分解！！", 1.5)
				return
			"翅膀":
				Global.add_message_show(_parent, "翅膀无不可以分解！！", 1.5)
				return
			"时装":
				Global.add_message_show(_parent, "时装不可以分解！！", 1.5)
				return
			"头衔":
				Global.add_message_show(_parent, "头衔不可以分解！！", 1.5)
				return
			"道具":
				PlayerData.player_data[DataKeys.DECOMPOSE_LIST].push_back(
					{"名字": get_item_name, "强化等级": qh_level, "Data": eq_prop.duplicate(true)}
				)
				PlayerData.remove_dj(get_item_name, current_page, 1)
			"武器", "防具", "饰品", "翅膀", "时装", "头衔":
				if _has_socketed_gems(eq_prop):
					Global.add_message_show(_parent, "请先卸下该装备上的宝石！！！", 1.5)
					return
				PlayerData.player_data[DataKeys.DECOMPOSE_LIST].push_back(
					{"名字": get_item_name, "强化等级": qh_level, "Data": eq_prop.duplicate(true)}
				)
				PlayerData.remove_zb(_get_equipment_source_page(), _get_equipment_source_index())
			"":
				Global.add_message_show(_parent, "错误？？！！", 1.5)
				return
	else:
		if PlayerData.player_data[DataKeys.DECOMPOSE_LIST].size() != 0:
			var name_str = PlayerData.player_data[DataKeys.DECOMPOSE_LIST][0][DataKeys.NAME]
			var cur_level = PlayerData.player_data[DataKeys.DECOMPOSE_LIST][0][DataKeys.ENHANCE_LEVEL]
			var data = PlayerData.player_data[DataKeys.DECOMPOSE_LIST][0]["Data"]
			get_tt = EquipmentService.data(name_str)[DataKeys.TYPE]
			match get_tt:
				"武器", "饰品", "防具":
					PlayerData.add_zb(name_str, cur_level, data)
					PlayerData.player_data[DataKeys.DECOMPOSE_LIST].clear()
				"道具":
					PlayerData.add_dj(name_str, 1)
					PlayerData.player_data[DataKeys.DECOMPOSE_LIST].clear()
		return


func on_press_when_xq():
	if not is_in_ldl_gz:
		var _parent = NodeUtils.ancestor(self, 7)
		if strength_source == "宠物背包":
			if PlayerData.player_data[DataKeys.INLAY_LIST].size() != 0:
				Global.add_message_show(_parent, "请先将镶嵌格子内装备卸下！！", 1.5)
				return
			if not PlayerData.take_pet_equipment_for_mosaic(strength_index, eq_prop, get_item_name):
				Global.add_message_show(_parent, "宠物装备位置已变化，请重新选择！！", 1.5)
			return
		var get_tt = EquipmentService.data(get_item_name)[DataKeys.TYPE]
		var base = EquipmentService.data(get_item_name)["所属"]
		if PlayerData.player_data[DataKeys.INLAY_LIST].size() == 0:
			match get_tt:
				"法宝":
					Global.add_message_show(_parent, "法宝不可以镶嵌宝石！！", 1.5)
					return
				"消耗品":
					Global.add_message_show(_parent, "不可放入消耗品！！", 1.5)
					return

				"道具":
					if base == "宝石":
						if PlayerData.player_data[DataKeys.INLAY_LIST].size() == 0:
							Global.add_message_show(_parent, "请先放入装备！！", 1.5)
					else:
						Global.add_message_show(_parent, "该道具不可用于镶嵌！！", 1.5)

				"武器", "防具", "饰品", "神骨", "翅膀", "时装", "头衔":
					if strength_source == "人物穿戴":
						var equipped_slot := str(get_meta("equipped_type", ""))
						var taken_equipment: Dictionary = PlayerData.take_equipped_equipment_for_mosaic(
							equipped_slot, get_item_name, eq_prop
						)
						if taken_equipment.is_empty():
							Global.add_message_show(_parent, "穿戴装备位置已变化，请重新选择！", 1.5)
							return
					else:
						PlayerData.player_data[DataKeys.INLAY_LIST].push_back(
							{"名字": get_item_name, "强化等级": qh_level, "Data": eq_prop.duplicate(true)}
						)
						PlayerData.remove_zb(_get_equipment_source_page(), _get_equipment_source_index())
					NodeUtils.ancestor(self, 6).set_box_data()

				"":
					Global.add_message_show(_parent, "错误？？！！", 1.5)
					return
		else:
			var data = PlayerData.player_data[DataKeys.INLAY_LIST][0]["Data"]
			match get_tt:
				"法宝":
					Global.add_message_show(_parent, "法宝不可以镶嵌宝石！！", 1.5)
					return
				"消耗品":
					Global.add_message_show(_parent, "不可放入消耗品！！", 1.5)
					return
				"道具":
					if base == "宝石":
						if data[DataKeys.GEM].size() < get_max_bs():
							if data[DataKeys.GEM].size() != 0:
								PlayerData.player_data[DataKeys.INLAY_LIST][0]["Data"][DataKeys.GEM].push_back(
									get_item_name
								)
								PlayerData.remove_dj(get_item_name, current_page, 1)
							else:
								PlayerData.player_data[DataKeys.INLAY_LIST][0]["Data"][DataKeys.GEM].push_back(
									get_item_name
								)
								PlayerData.remove_dj(get_item_name, current_page, 1)

						else:
							Global.add_message_show(_parent, "最多镶嵌" + str(get_max_bs()) + "个宝石！！", 1.5)
							return
					else:
						Global.add_message_show(_parent, "该道具不可用于镶嵌！！", 1.5)
						return
				"武器", "防具", "饰品", "神骨", "翅膀", "时装", "头衔":
					Global.add_message_show(_parent, "请先将镶嵌格子内装备卸下！！", 1.5)
					return
				"":
					Global.add_message_show(_parent, "错误？？！！", 1.5)
					return
	else:
		if PlayerData.player_data[DataKeys.INLAY_LIST].size() != 0:
			if strength_source == "宠物背包":
				PlayerData.restore_mosaic_equipment()
				return
			var get_tt = EquipmentService.data(get_item_name)[DataKeys.TYPE]
			match get_tt:
				"武器", "饰品", "防具", "神骨", "翅膀", "时装", "头衔":
					PlayerData.restore_mosaic_equipment()
				"道具":
					PlayerData.player_data[DataKeys.INLAY_LIST][0]["Data"][DataKeys.GEM].erase(get_item_name)
					PlayerData.add_dj(get_item_name, 1)
				"":
					pass
		return


func _on_pressed() -> void:
	var _parent
	var backpack_factory := Global.get_backpack_factory()
	if backpack_factory.is_box_click_blocked():
		if is_in_ldl:
			_parent = NodeUtils.ancestor(self, 7)
		else:
			_parent = NodeUtils.ancestor(self, 6)
		if is_in_hh or is_in_shop or is_in_hhgz:
			return
		else:
			Global.add_message_show(_parent, "点击过快！！", 1.5)
		return
	else:
		backpack_factory.start_box_click_cooldown()
	if hide_prop:
		return
	if is_in_hh or is_in_shop or is_in_hhgz:
		return
	_close_equ_box()
	if get_item_name != "empty" and sell_box == null:
		if Global.get_ui_runtime().is_ldl_mode_active() == false:
			on_press_when_in_back()
		elif Global.get_ui_runtime().is_ldl_mode_active() == true:
			match MLdl.current_mode:
				"强化":
					on_press_when_strength()
				"神铸":
					on_press_when_divine_forge()
				"淬骨":
					on_press_when_bone_forge()
				"合成":
					on_press_when_synthesis()
				"镶嵌":
					on_press_when_xq()
				"分解":
					Global.get_forge_factory().mark_decompose_item_changed()
					on_press_whenfj()
				"打造":
					on_press_when_dz()
	MemoryClass.request_save("back_pack_box_action")


func _on_mouse_entered() -> void:
	if hide_prop:
		return
	if get_item_name != "empty" and add_equ_box == null:
		var tt = _get_window_parent()
		var pp = Global.popup_position_for_parent(tt, Vector2(25, 20))
		if eq_prop != null:
			add_equ_box = Global.add_equ_propeties_box(tt, pp, get_item_name, qh_level, wx, eq_prop)
			if strength_source == "宠物背包" and add_equ_box.has_method("setup_pet_equipment"):
				add_equ_box.call("setup_pet_equipment", eq_prop)
			add_equ_box.is_in_ldl_gz = is_in_ldl_gz
			add_equ_box.is_in_shop = is_in_shop
			set_process(true)


func _on_mouse_exited() -> void:
	_close_equ_box()


func _close_equ_box() -> void:
	if add_equ_box != null:
		if is_instance_valid(add_equ_box):
			add_equ_box.queue_free()
		add_equ_box = null
	set_process(false)


func get_number():
	var number = int(str(self.name).split("_")[1]) - 1
	return number


func _get_equipment_source_page() -> int:
	var source_page := int(get_meta("backpack_page", 0))
	return source_page if source_page > 0 else int(current_page)


func _get_equipment_source_index() -> int:
	var source_index := int(get_meta("backpack_index", -1))
	return source_index if source_index >= 0 else get_number()


func _get_window_parent():
	var last_parent
	if is_in_hh or is_in_hhgz or is_in_shop or is_in_ldl_gz or is_in_ldl:
		last_parent = Global.get_ui_runtime().windows
	else:
		last_parent = NodeUtils.ancestor(self, 7)
	return last_parent


func get_max_bs():
	if PlayerData.player_data[DataKeys.INLAY_LIST].size() == 0:
		return 0
	return 8
