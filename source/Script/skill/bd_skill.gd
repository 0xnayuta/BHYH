extends MarginContainer

## 显式操作者：按所在面板的槽位解析数据与属性，不依赖全局 1P/2P 视图交换。
var PlayerData: PlayerDataStore:
	get:
		return LocalCoop.data_for(self) as PlayerDataStore
var RoleProp: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self) as BaseRoleProperties

@onready var c_name_1 = $HBoxContainer/Current_e/name_1
@onready var c_name_2 = $HBoxContainer/Current_e/name_2
@onready var c_name_3 = $HBoxContainer/Current_e/name_3
@onready var c_name_4 = $HBoxContainer/Current_e/name_4
@onready var c_name_5 = $HBoxContainer/Current_e/name_5
@onready var c_name_6 = $HBoxContainer/Current_e/name_6
@onready var c_name_7 = $HBoxContainer/Current_e/name_7
@onready var n_name_1 = $HBoxContainer/Next_e/name_1
@onready var n_name_2 = $HBoxContainer/Next_e/name_2
@onready var n_name_3 = $HBoxContainer/Next_e/name_3
@onready var n_name_4 = $HBoxContainer/Next_e/name_4
@onready var n_name_5 = $HBoxContainer/Next_e/name_5
@onready var n_name_6 = $HBoxContainer/Next_e/name_6
@onready var n_name_7 = $HBoxContainer/Next_e/name_7
@onready var l_name_1 = $HBoxContainer/NeedLh/name_1
@onready var l_name_2 = $HBoxContainer/NeedLh/name_2
@onready var l_name_3 = $HBoxContainer/NeedLh/name_3
@onready var l_name_4 = $HBoxContainer/NeedLh/name_4
@onready var l_name_5 = $HBoxContainer/NeedLh/name_5
@onready var l_name_6 = $HBoxContainer/NeedLh/name_6
@onready var l_name_7 = $HBoxContainer/NeedLh/name_7
@onready var one_key_upgrade_button := $HBoxContainer/Up_level/OneKeyUpgradeButton as Button

const TABLE_ROW_HEIGHT := 34.0
const PASSIVE_SKILL_NAMES := ["热血", "魔泉", "狂暴", "永恒", "辉煌", "敏锐", "收益"]
const TABLE_COLUMN_WIDTHS := {
	"Skill_Name": 100.0,
	"Current_e": 210.0,
	"Next_e": 210.0,
	"NeedLh": 120.0,
	"Up_level": 120.0,
}
const PASSIVE_HOLD_DELAY := 2.0
const PASSIVE_REPEAT_INTERVAL := 0.12
var _passive_hold_button: BaseButton = null
var _passive_hold_skill := ""
var _passive_hold_elapsed := 0.0
var _passive_repeat_elapsed := 0.0
var _passive_repeating := false
var _passive_suppress_click_skill := ""


func _ready() -> void:
	PlayerData.ensure_player_passive_skills()
	_apply_table_layout()
	for index in range(1, 8):
		var button := get_node_or_null("HBoxContainer/Up_level/up_%d" % index) as BaseButton
		if button != null:
			button.button_down.connect(_on_passive_button_down.bind(button, _passive_skill_name(index)))
			button.button_up.connect(_on_passive_button_up.bind(button))
	set_infor()


func _process(delta: float) -> void:
	if _passive_hold_button == null:
		return
	if not is_instance_valid(_passive_hold_button):
		_passive_hold_button = null
		_passive_hold_skill = ""
		return
	if _passive_hold_button.disabled:
		_on_passive_button_up(_passive_hold_button)
		return
	_passive_hold_elapsed += delta
	if not _passive_repeating:
		if _passive_hold_elapsed < PASSIVE_HOLD_DELAY:
			return
		_passive_repeating = true
		_passive_suppress_click_skill = _passive_hold_skill
		if not _upgrade_passive_for_hold(_passive_hold_skill):
			_on_passive_button_up(_passive_hold_button)
		return
	_passive_repeat_elapsed += delta
	if _passive_repeat_elapsed < PASSIVE_REPEAT_INTERVAL:
		return
	_passive_repeat_elapsed = 0.0
	if not _upgrade_passive_for_hold(_passive_hold_skill):
		_on_passive_button_up(_passive_hold_button)


func _passive_skill_name(index: int) -> String:
	return PASSIVE_SKILL_NAMES[index - 1]


func _on_passive_button_down(button: BaseButton, skill_name: String) -> void:
	_passive_hold_button = button
	_passive_hold_skill = skill_name
	_passive_hold_elapsed = 0.0
	_passive_repeat_elapsed = 0.0
	_passive_repeating = false
	_passive_suppress_click_skill = ""


func _on_passive_button_up(button: BaseButton) -> void:
	if button != _passive_hold_button:
		return
	var was_repeating := _passive_repeating
	var released_skill := _passive_hold_skill
	_passive_hold_button = null
	_passive_hold_skill = ""
	_passive_hold_elapsed = 0.0
	_passive_repeat_elapsed = 0.0
	_passive_repeating = false
	if was_repeating:
		_passive_suppress_click_skill = released_skill


func _upgrade_passive_for_hold(skill_name: String) -> bool:
	return up_level(skill_name)


func _apply_table_layout() -> void:
	$HBoxContainer.add_theme_constant_override("separation", 0)
	for column_name in TABLE_COLUMN_WIDTHS.keys():
		var column = $HBoxContainer.get_node_or_null(str(column_name))
		if column == null:
			continue
		column.custom_minimum_size.x = TABLE_COLUMN_WIDTHS[column_name]
		column.add_theme_constant_override("separation", 0)
		for child in column.get_children():
			if child is Control:
				child.custom_minimum_size.y = TABLE_ROW_HEIGHT
				child.size_flags_vertical = Control.SIZE_SHRINK_CENTER


func get_current_max_level() -> int:
	var role_level = int(PlayerData.player_data.get(DataKeys.PLAYER_LEVEL, RoleProp.baseroleprop.get("Level", 1)))
	return PaSkill.get_unlocked_level(role_level)


func set_infor():
	var target = PlayerData.player_data["被动技能"]
	if target["热血"] != 0:
		c_name_1.text = "生命上限增加至 " + str(PaSkill.get_value("热血", int(target["热血"])))
	else:
		c_name_1.text = ""
	if target["魔泉"] != 0:
		c_name_2.text = "魔法上限增加至 " + str(PaSkill.get_value("魔泉", int(target["魔泉"])))
	else:
		c_name_2.text = ""
	if target["狂暴"] != 0:
		c_name_3.text = "暴击增加至 " + str(PaSkill.get_value("狂暴", int(target["狂暴"])))
	else:
		c_name_3.text = ""
	if target["永恒"] != 0:
		c_name_4.text = "回血增加至 " + str(PaSkill.get_value("永恒", int(target["永恒"])))
	else:
		c_name_4.text = ""
	if target["辉煌"] != 0:
		c_name_5.text = "回魔增加至 " + str(PaSkill.get_value("辉煌", int(target["辉煌"])))
	else:
		c_name_5.text = ""
	if target["敏锐"] != 0:
		c_name_6.text = "命中增加至 " + str(PaSkill.get_value("敏锐", int(target["敏锐"])))
	else:
		c_name_6.text = ""
	if target["收益"] != 0:
		c_name_7.text = "杀怪灵魂获取 +" + str(PaSkill.get_value("收益", int(target["收益"]))) + "%"
	else:
		c_name_7.text = ""

	if target["热血"] < get_current_max_level():
		n_name_1.text = "生命上限增加至 " + str(PaSkill.get_value("热血", int(target["热血"]) + 1))
	else:
		n_name_1.text = "已达到当前等级上限"
	if target["魔泉"] < get_current_max_level():
		n_name_2.text = "魔法上限增加至 " + str(PaSkill.get_value("魔泉", int(target["魔泉"]) + 1))
	else:
		n_name_2.text = "已达到当前等级上限"
	if target["狂暴"] < get_current_max_level():
		n_name_3.text = "暴击增加至 " + str(PaSkill.get_value("狂暴", int(target["狂暴"]) + 1))
	else:
		n_name_3.text = "已达到当前等级上限"
	if target["永恒"] < get_current_max_level():
		n_name_4.text = "回血增加至 " + str(PaSkill.get_value("永恒", int(target["永恒"]) + 1))
	else:
		n_name_4.text = "已达到当前等级上限"
	if target["辉煌"] < get_current_max_level():
		n_name_5.text = "回魔增加至 " + str(PaSkill.get_value("辉煌", int(target["辉煌"]) + 1))
	else:
		n_name_5.text = "已达到当前等级上限"
	if target["敏锐"] < get_current_max_level():
		n_name_6.text = "命中增加至 " + str(PaSkill.get_value("敏锐", int(target["敏锐"]) + 1))
	else:
		n_name_6.text = "已达到当前等级上限"
	if target["收益"] < get_current_max_level():
		n_name_7.text = "杀怪灵魂获取 +" + str(PaSkill.get_value("收益", int(target["收益"]) + 1)) + "%"
	else:
		n_name_7.text = "已达到当前等级上限"

	l_name_1.text = str(PaSkill.get_lh("热血"))
	l_name_2.text = str(PaSkill.get_lh("魔泉"))
	l_name_3.text = str(PaSkill.get_lh("狂暴"))
	l_name_4.text = str(PaSkill.get_lh("永恒"))
	l_name_5.text = str(PaSkill.get_lh("辉煌"))
	l_name_6.text = str(PaSkill.get_lh("敏锐"))
	l_name_7.text = str(PaSkill.get_lh("收益"))
	if one_key_upgrade_button != null:
		var max_level := get_current_max_level()
		one_key_upgrade_button.disabled = PASSIVE_SKILL_NAMES.all(
			func(skill_name): return int(target.get(skill_name, 0)) >= max_level
		)


func _upgrade_all_passives() -> int:
	PlayerData.ensure_player_passive_skills()
	var target: Dictionary = PlayerData.player_data["被动技能"]
	var max_level := get_current_max_level()
	var levels := {}
	for skill_name in PASSIVE_SKILL_NAMES:
		levels[skill_name] = int(target.get(skill_name, 0))
	var built := _build_passive_upgrade_plan(PASSIVE_SKILL_NAMES, levels, max_level, PlayerData.get_soul())
	var plan: Array = built["plan"]
	if plan.is_empty():
		return 0
	if not PlayerData.apply_passive_skill_upgrades(plan, int(built["total"]), "skill_passive_upgrade_all"):
		return -1
	return plan.size()


func _build_passive_upgrade_plan(
	skill_names: Array, starting_levels: Dictionary, max_level: int, budget: int
) -> Dictionary:
	var plan: Array = []
	var levels := starting_levels.duplicate(true)
	var total_cost := 0
	var upgraded := true
	while upgraded:
		upgraded = false
		for skill_name in skill_names:
			var level := int(levels.get(skill_name, 0))
			if level >= max_level:
				continue
			var cost := PaSkill.get_lh_for_level(str(skill_name), level)
			if total_cost + cost > budget:
				continue
			total_cost += cost
			levels[skill_name] = level + 1
			plan.append({"name": str(skill_name), "level": level + 1})
			upgraded = true
	return {"plan": plan, "total": total_cost}


func _on_one_key_upgrade_pressed() -> void:
	var upgraded_count := _upgrade_all_passives()
	set_infor()
	if upgraded_count < 0:
		Global.add_moment_text(get_parent(), Vector2.ZERO, "存档保存失败，本次升级已撤销", 1)
		return
	if upgraded_count == 0:
		Global.add_moment_text(get_parent(), Vector2.ZERO, "灵魂不足或已达当前等级上限", 1)
		return
	Global.add_moment_text(get_parent(), Vector2.ZERO, "一键升级完成，共提升%d级" % upgraded_count, 1)


func up_level(_name) -> bool:
	PlayerData.ensure_player_passive_skills()
	var target: Dictionary = PlayerData.player_data["被动技能"]
	var level := int(target.get(_name, 0))
	var max_level := get_current_max_level()
	if level >= max_level:
		Global.add_moment_text(get_parent(), Vector2(0, 0), "已经无法再升级了！！", 1)
		return false
	var cost := PaSkill.get_lh_for_level(str(_name), level)
	if PlayerData.get_soul() < cost:
		Global.add_moment_text(get_parent(), Vector2(0, 0), "灵魂不足！！", 1)
		return false
	var plan := [{"name": str(_name), "level": level + 1}]
	if not PlayerData.apply_passive_skill_upgrades(plan, cost):
		set_infor()
		Global.add_moment_text(get_parent(), Vector2(0, 0), "存档保存失败，本次升级已撤销：%s" % MemoryClass.describe_save_error(), 1)
		return false
	set_infor()
	return true


func _on_up_1_pressed() -> void:
	if _passive_suppress_click_skill == "热血":
		_passive_suppress_click_skill = ""
		return
	up_level("热血")


func _on_up_2_pressed() -> void:
	if _passive_suppress_click_skill == "魔泉":
		_passive_suppress_click_skill = ""
		return
	up_level("魔泉")


func _on_up_3_pressed() -> void:
	if _passive_suppress_click_skill == "狂暴":
		_passive_suppress_click_skill = ""
		return
	up_level("狂暴")


func _on_up_4_pressed() -> void:
	if _passive_suppress_click_skill == "永恒":
		_passive_suppress_click_skill = ""
		return
	up_level("永恒")


func _on_up_5_pressed() -> void:
	if _passive_suppress_click_skill == "辉煌":
		_passive_suppress_click_skill = ""
		return
	up_level("辉煌")


func _on_up_6_pressed() -> void:
	if _passive_suppress_click_skill == "敏锐":
		_passive_suppress_click_skill = ""
		return
	up_level("敏锐")


func _on_up_7_pressed() -> void:
	if _passive_suppress_click_skill == "收益":
		_passive_suppress_click_skill = ""
		return
	up_level("收益")
