extends Control

const ROLE_SKILLS := {
	"角色1": ["slz", "hytj", "lys", "lyfb", "hmz", "hmz_ws", "zz", "qsez", "jdy", "hyjj", "sx", "gsrs", "hyjj_ws"],
	"角色2": ["blb", "xbz", "shy", "tjgl", "smb", "sgq", "myhc", "jgz", "jhsj", "sjt", "by", "zfjg"],
	"角色3": ["ssp", "dj", "dgq", "zznh", "tmc", "sd", "jsp", "xgq", "syzq", "rj", "bdqk"],
	"角色4": ["qlj", "dcj", "wdzt", "tkj", "mmw", "jdz", "lhsq", "zq", "wdww", "mds", "bylt", "cmly"],
	"角色5": ["xyq", "slq", "blq", "fhf", "cxq", "llrd", "lljy", "ygth", "tllz", "yyb", "ltjz"],
	"角色6": ["nz_jlsh", "nz_fhcc", "nz_hlqg", "nz_hlhs", "nz_lblc", "nz_yysj"],
	"角色7": YutuSkillData.KEYS,
}

const SKILL_NAMES := {
	"yt_mds": "蔓毒散",
	"yt_tyy": "兔影跃",
	"yt_xdz": "玄毒针",
	"yt_hyl": "回元露",
	"yt_ldmw": "炼毒魔瓮",
	"yt_fyz": "飞月斩",
	"yt_xyyy": "星移月影",
	"yt_yl": "月轮",
	"yt_ygj": "月光诀",
	"yt_ymw": "月魔舞",
	"slz": "升龙斩",
	"hytj": "火炎突击",
	"lys": "烈焰闪",
	"lyfb": "烈焰风暴",
	"hmz": "火魔斩",
	"hmz_ws": "火魔斩无双",
	"zz": "重斩",
	"qsez": "七十二斩",
	"jdy": "筋斗云",
	"hyjj": "火眼金睛",
	"gsrs": "棍式如山",
	"hyjj_ws": "无双火眼金睛",
	"blb": "冰龙波",
	"xbz": "玄冰阵",
	"shy": "水幻影",
	"tjgl": "天降甘露",
	"smb": "水魔爆",
	"myhc": "沐浴回春",
	"jgz": "紧箍咒",
	"jhsj": "九环圣经",
	"by": "冰雨",
	"zfjg": "正法金刚",
	"ssp": "碎石破",
	"dj": "盾击",
	"dgq": "地滚球",
	"zznh": "战争怒吼",
	"tmc": "土魔刺",
	"sd": "圣盾",
	"jsp": "巨石破",
	"xgq": "旋滚球",
	"syzq": "圣域之墙",
	"bdqk": "拔地乾坤",
	"qlj": "强力击",
	"dcj": "多重击",
	"wdzt": "万毒加护",
	"tkj": "腾空击",
	"mmw": "木魔舞",
	"jdz": "剧毒阵",
	"lhsq": "灵魂摄取",
	"zq": "瘴气",
	"wdww": "巫毒娃娃",
	"bylt": "碧落天",
	"cmly": "苍木龙陨",
	"xyq": "心眼枪",
	"slq": "升龙枪",
	"blq": "奔雷枪",
	"fhf": "覆海翻",
	"cxq": "穿心枪",
	"llrd": "雷龙入地",
	"lljy": "雷龙极影",
	"ygth": "银钩铁画",
	"tllz": "天龙雷阵",
	"ltjz": "雷霆劫阵",
	"nz_jlsh": "九龙神火",
	"nz_fhcc": "风火冲刺",
	"nz_hlqg": "火轮切割",
	"nz_hlhs": "火莲化身",
	"nz_lblc": "六臂连刺",
	"nz_yysj": "阴阳神剑",
}

const PASSIVE_SKILLS := ["sx", "sjt", "rj", "mds", "yyb", YutuSkillData.PASSIVE_KEY]

@onready var wushuang_check: CheckButton = $Panel/Content/Options/Wushuang
@onready var retry_check: CheckButton = $Panel/Content/Options/Retry
@onready var skill_only_check: CheckButton = $Panel/Content/Options/SkillOnly
@onready var magic_weapon_check: CheckButton = $Panel/Content/Options/MagicWeapon
@onready var sword_array_check: CheckButton = $Panel/Content/Options/SwordArray
@onready var skill_option: OptionButton = $Panel/Content/SkillPicker/SkillOption
@onready var selected_list: VBoxContainer = $Panel/Content/SelectedScroll/SelectedList
@onready var role_label: Label = $Panel/Content/RoleLabel
@onready var hint_label: Label = $Panel/Content/Hint

var role_key := "角色1"
var available_skills: Array[String] = []
var selected_skills: Array[String] = []
var selected_skill_counts: Array[int] = []
const DESIGN_SIZE := Vector2(940.0, 590.0)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_fit_to_window()
	if not get_viewport().size_changed.is_connected(_fit_to_window):
		get_viewport().size_changed.connect(_fit_to_window)
	role_key = _get_role_key()
	available_skills = _get_learned_skills()
	selected_skills = _load_selected_skills()
	wushuang_check.button_pressed = bool(MainSet.set_data.get("AutoBattleWushuang", false))
	retry_check.button_pressed = bool(MainSet.set_data.get("AutoBattleRetry", false))
	skill_only_check.button_pressed = bool(MainSet.set_data.get("AutoBattleSkillOnly", false))
	magic_weapon_check.button_pressed = bool(MainSet.set_data.get("AutoBattleMagicWeapon", false))
	sword_array_check.button_pressed = bool(MainSet.set_data.get("AutoBattleSwordArray", false))
	role_label.text = "当前角色：" + role_key
	_refresh_option()
	_refresh_selected()
	if available_skills.is_empty():
		hint_label.text = "当前角色没有已学习的主动技能"
	else:
		hint_label.text = "技能按添加顺序循环释放，冷却或蓝量不足时自动跳过"


func _fit_to_window() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var fit_scale: float = min(viewport_size.x / DESIGN_SIZE.x, viewport_size.y / DESIGN_SIZE.y)
	var content_size: Vector2 = DESIGN_SIZE * fit_scale
	scale = Vector2(fit_scale, fit_scale)
	position = (viewport_size - content_size) * 0.5


func _get_role_key() -> String:
	var role_id := int(PlayerData.player_data.get("Myself", 1))
	if role_id < 1 or role_id > 7:
		role_id = 1
	return "角色" + str(role_id)


func _get_skill_storage_index(index: int, skill_id: String) -> int:
	if role_key == "角色3" and skill_id == "bdqk":
		return 12
	if skill_id == "hmz_ws":
		return 12
	if skill_id == "hyjj_ws":
		return 13
	var hmz_index: int = int(ROLE_SKILLS[role_key].find("hmz_ws"))
	if role_key == "角色1" and hmz_index >= 0 and index > hmz_index:
		return index
	return index + 1


func _get_learned_skills() -> Array[String]:
	var result: Array[String] = []
	var skill_data_value: Variant = PlayerData.player_data.get(DataKeys.SKILL_LEARNED, {})
	if not skill_data_value is Dictionary:
		return result
	var skill_data: Dictionary = skill_data_value
	var skill_ids: Array = ROLE_SKILLS.get(role_key, [])
	for index in range(skill_ids.size()):
		var skill_id := str(skill_ids[index])
		if skill_id in PASSIVE_SKILLS:
			continue
		var storage_key := "技能" + str(_get_skill_storage_index(index, skill_id))
		var entry_value: Variant = skill_data.get(storage_key, {})
		if not entry_value is Dictionary:
			continue
		var entry: Dictionary = entry_value
		if int(entry.get("学习", 0)) > 0 or int(entry.get(DataKeys.LEVEL, 0)) > 0:
			result.append(skill_id)
	return result


func _load_selected_skills() -> Array[String]:
	var configured_value: Variant
	var by_role_value: Variant = MainSet.set_data.get("AutoBattleSkillsByRole", {})
	if by_role_value is Dictionary and (by_role_value as Dictionary).has(role_key):
		configured_value = (by_role_value as Dictionary).get(role_key, [])
	else:
		configured_value = MainSet.set_data.get("AutoBattleSkills", [])
	var result: Array[String] = []
	var counts: Array[int] = []
	if not configured_value is Array:
		selected_skill_counts = counts
		return result
	for value in configured_value:
		var skill_id := ""
		var count := 1
		if value is Dictionary:
			var skill_entry: Dictionary = value
			skill_id = str(skill_entry.get("id", skill_entry.get("skill_id", "")))
			count = clampi(int(skill_entry.get("count", 1)), 1, 99)
		else:
			skill_id = str(value)
		if skill_id in available_skills and skill_id not in result:
			result.append(skill_id)
			counts.append(count)
	selected_skill_counts = counts
	return result


func _refresh_option() -> void:
	skill_option.clear()
	for skill_id in available_skills:
		if skill_id in selected_skills:
			continue
		skill_option.add_item(_skill_name(skill_id))
		skill_option.set_item_metadata(skill_option.item_count - 1, skill_id)
	skill_option.disabled = skill_option.item_count == 0
	$Panel/Content/SkillPicker/Add.disabled = skill_option.disabled


func _refresh_selected() -> void:
	for child in selected_list.get_children():
		child.queue_free()
	for index in range(selected_skills.size()):
		var skill_id := selected_skills[index]
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 34)
		var label := Label.new()
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.text = str(index + 1) + ". " + _skill_name(skill_id)
		label.add_theme_font_size_override("font_size", 20)
		var count_label := Label.new()
		count_label.text = "释放次数"
		count_label.custom_minimum_size = Vector2(92, 30)
		count_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		count_label.add_theme_font_size_override("font_size", 17)
		var count_spin_box := SpinBox.new()
		count_spin_box.custom_minimum_size = Vector2(86, 32)
		count_spin_box.min_value = 1
		count_spin_box.max_value = 99
		count_spin_box.step = 1
		count_spin_box.value = selected_skill_counts[index] if index < selected_skill_counts.size() else 1
		count_spin_box.add_theme_font_size_override("font_size", 18)
		count_spin_box.value_changed.connect(_on_skill_count_changed.bind(index))
		var remove_button := Button.new()
		remove_button.text = "移除"
		remove_button.custom_minimum_size = Vector2(76, 30)
		remove_button.add_theme_font_size_override("font_size", 18)
		remove_button.pressed.connect(_remove_skill.bind(skill_id))
		row.add_child(label)
		row.add_child(count_label)
		row.add_child(count_spin_box)
		row.add_child(remove_button)
		selected_list.add_child(row)
	if selected_skills.is_empty():
		var empty_label := Label.new()
		empty_label.text = "暂未添加技能"
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.add_theme_font_size_override("font_size", 20)
		selected_list.add_child(empty_label)


func _skill_name(skill_id: String) -> String:
	return str(SKILL_NAMES.get(skill_id, skill_id))


func _on_add_pressed() -> void:
	var selected_index := skill_option.selected
	if selected_index < 0 or selected_index >= skill_option.item_count:
		return
	var skill_id := str(skill_option.get_item_metadata(selected_index))
	if skill_id == "" or skill_id in selected_skills:
		return
	selected_skills.append(skill_id)
	selected_skill_counts.append(1)
	_refresh_option()
	_refresh_selected()


func _remove_skill(skill_id: String) -> void:
	var index := selected_skills.find(skill_id)
	if index < 0:
		return
	selected_skills.remove_at(index)
	if index < selected_skill_counts.size():
		selected_skill_counts.remove_at(index)
	_refresh_option()
	_refresh_selected()


func _on_skill_count_changed(value: float, index: int) -> void:
	if index < 0 or index >= selected_skill_counts.size():
		return
	selected_skill_counts[index] = clampi(int(round(value)), 1, 99)


func _on_save_pressed() -> void:
	var by_role_value: Variant = MainSet.set_data.get("AutoBattleSkillsByRole", {})
	var by_role: Dictionary = by_role_value.duplicate(true) if by_role_value is Dictionary else {}
	var configured_skills: Array[Dictionary] = _get_configured_skill_entries()
	by_role[role_key] = configured_skills.duplicate(true)
	MainSet.set_data["AutoBattleSkillsByRole"] = by_role
	MainSet.set_data["AutoBattleSkills"] = configured_skills.duplicate(true)
	_store_option_settings()
	MainSet.set_auto_battle_enabled(true)
	MemoryClass.main_bc()
	queue_free()


func _store_option_settings() -> void:
	MainSet.set_data["AutoBattleWushuang"] = wushuang_check.button_pressed
	MainSet.set_data["AutoBattleRetry"] = retry_check.button_pressed
	MainSet.set_data["AutoBattleSkillOnly"] = skill_only_check.button_pressed
	MainSet.set_data["AutoBattleMagicWeapon"] = magic_weapon_check.button_pressed
	MainSet.set_data["AutoBattleSwordArray"] = sword_array_check.button_pressed


func _get_configured_skill_entries() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for index in range(selected_skills.size()):
		var count := 1
		if index < selected_skill_counts.size():
			count = clampi(selected_skill_counts[index], 1, 99)
		(
			result
			. append(
				{
					"id": selected_skills[index],
					"count": count,
				}
			)
		)
	return result


func _on_cancel_pressed() -> void:
	queue_free()


func _on_dimmer_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		queue_free()


func _exit_tree() -> void:
	if get_viewport().size_changed.is_connected(_fit_to_window):
		get_viewport().size_changed.disconnect(_fit_to_window)
