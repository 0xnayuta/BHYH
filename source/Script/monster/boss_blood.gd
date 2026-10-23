extends TextureProgressBar
class_name BossBlood
@onready var boss_blood: TextureProgressBar = $"."
@onready var blood_under: TextureRect = $BloodUnder
@onready var monster_name: Label = $MonsterName
@onready var blood_value: Label = $BloodValue
@onready var blood_uder_bar: TextureProgressBar = $BloodUderBar
@onready var protect_bar: TextureProgressBar = $ProtectBar
@onready var role_protect: TextureProgressBar = $RoleProtect
@onready var protect_under: TextureRect = $ProtectBar/ProtectUnder
@onready var protect_name: Label = $ProtectBar/ProtectName
@onready var protect_value: Label = $ProtectBar/ProtectValue
@onready var buff_list: HBoxContainer = $BuffList

const BUFF_ICON_SCENE = preload("res://Scene/other_scene/buff_icon.tscn")
const YUTU_POISON_BUFFS := ["YutuWeakPoison", "YutuStrongPoison", "YutuWeakExtraPoison", "YutuStrongExtraPoison"]

var buff_icon_cache: Dictionary = {}
var _buff_info_by_name: Dictionary = {}
var _last_hp := -1
var _last_shp := -1
var _last_name := ""
var _last_delayed_ratio := -1.0
var _delay_tween: Tween

var get_obj: BaseMonster


func _layout_labels_for_normal_bar() -> void:
	monster_name.visible = true
	monster_name.z_index = 20
	monster_name.position = Vector2(-220, 4)
	monster_name.size = Vector2(255, 30)
	monster_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	monster_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	blood_value.visible = true
	blood_value.z_index = 20
	blood_value.position = Vector2(45, 4)
	blood_value.size = Vector2(295, 30)
	blood_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	blood_value.vertical_alignment = VERTICAL_ALIGNMENT_CENTER


var big_bar_hp_c_hange:
	set(vl):
		big_bar_hp_c_hange = vl
		on_hp_change(big_bar_hp_c_hange)


func _ready() -> void:
	_layout_labels_for_normal_bar()
	pre_create_buff_icons()


func _physics_process(delta: float) -> void:
	if get_obj == null or not is_instance_valid(get_obj):
		queue_free()
		return
	_collect_buff_info()
	_collect_armor_buff_info()
	var poison = get_obj.get_node_or_null("YutuPoison")
	if poison != null and not poison.is_queued_for_deletion():
		for info: Dictionary in poison.get_buff_info():
			_buff_info_by_name[str(info.Name)] = info
	for buff_name in Global.all_buff_list:
		set_buff_icon_info(buff_name)
	for buff_name: String in YUTU_POISON_BUFFS:
		set_buff_icon_info(buff_name)
	var hp := int(get_obj.hp)
	var shp := int(get_obj.max_hp)
	var display_name := str(get_obj.my_mr_name)
	if hp != _last_hp or shp != _last_shp:
		_last_hp = hp
		_last_shp = shp
		var ratio := float(hp) / maxf(float(shp), 1.0)
		boss_blood.value = ratio
		big_bar_hp_c_hange = ratio
		blood_value.text = " " + str(hp) + "/" + str(shp) + "(" + str(snapped(ratio, 0.001) * 100) + "%)"
	if display_name != _last_name:
		_last_name = display_name
		monster_name.text = display_name + " "
	protect_bar_control()


func on_hp_change(value_):
	if not MainSet.set_data["HpBarDelay"]:
		blood_uder_bar.value = 0
		return
	var ratio := float(value_)
	if is_equal_approx(ratio, _last_delayed_ratio):
		return
	_last_delayed_ratio = ratio
	if _delay_tween != null and _delay_tween.is_valid():
		_delay_tween.kill()
	_delay_tween = create_tween()
	_delay_tween.tween_property(blood_uder_bar, "value", ratio, 0.7)


func protect_bar_control():
	if get_obj == null or not get_obj.is_boss:
		if protect_bar.visible:
			protect_bar.visible = false
		if role_protect.visible:
			role_protect.visible = false
		return
	var max_white_bar := maxf(get_obj.boss_max_protect, 1.0)
	if not role_protect.visible:
		role_protect.visible = true
	if not is_equal_approx(role_protect.max_value, max_white_bar):
		role_protect.max_value = max_white_bar
	var white_bar_value := clampf(get_obj.boss_current_protect, 0.0, max_white_bar)
	if not is_equal_approx(role_protect.value, white_bar_value):
		role_protect.value = white_bar_value
	var max_shield := maxf(float(get_obj.max_hd), 1.0)
	var current_shield := clampf(float(get_obj.hd), 0.0, max_shield)
	var has_shield := get_obj.max_hd > 0 and get_obj.hd > 0
	if protect_bar.visible != has_shield:
		protect_bar.visible = has_shield
	var shield_ratio := current_shield / max_shield
	if not is_equal_approx(protect_bar.value, shield_ratio):
		protect_bar.value = shield_ratio
	var shield_text := "护盾：" + str(get_obj.hd)
	if protect_value.text != shield_text:
		protect_value.text = shield_text


func _collect_buff_info() -> void:
	_buff_info_by_name.clear()
	if get_obj == null or get_obj.buff == null:
		_add_flag_buff_info("defe_reduce", bool(get_obj.get("is_defe_reduce")), float(get_obj.get("defe_reduce")))
		_add_flag_buff_info("stun", bool(get_obj.get("is_stun")), 0.0)
		return
	var buff_parent: Node = get_obj.buff
	var child_count: int = buff_parent.get_child_count()
	var child_index := 0
	while child_index < child_count:
		var buff_node = buff_parent.get_child(child_index)
		child_index += 1
		if buff_node == null or not is_instance_valid(buff_node):
			continue
		var buff_data_variant = buff_node.get("buff_info")
		if not buff_data_variant is Dictionary:
			continue
		var buff_data: Dictionary = buff_data_variant
		var buff_name := str(buff_data.get("Name", ""))
		if not buff_icon_cache.has(buff_name):
			continue
		var buff_info: Dictionary
		if _buff_info_by_name.has(buff_name):
			buff_info = _buff_info_by_name[buff_name]
		else:
			buff_info = {
				"Name": buff_name,
				"value": 0.0,
				"AddTime": 0.0,
				"reduce_interval": 0.0,
				"AttackKind": "",
				"HaveCount": 0,
			}
			_buff_info_by_name[buff_name] = buff_info
		buff_info["HaveCount"] += 1
		var value = buff_data.get("value", 0.0)
		if buff_data.has("CanAdd") and bool(buff_data.get("CanAdd", false)):
			buff_info["value"] += value
		else:
			buff_info["value"] = value
		buff_info["reduce_interval"] = buff_data.get("reduce_interval", 0.0)
		buff_info["AttackKind"] = buff_data.get("AttackKind", "")
		buff_info["AddTime"] = buff_data.get("AddTime", 0.0)
		if buff_name == "SuperArmor":
			var buff_time: Variant = buff_node.get("buff_time")
			var remaining := float(buff_time.time_left) if buff_time is Timer else float(buff_info["AddTime"])
			buff_info["TimeLeft"] = maxf(float(buff_info.get("TimeLeft", 0.0)), remaining)
		var is_check := bool(buff_node.get("is_check"))
		if not is_check:
			var buff_icon = buff_icon_cache[buff_name]
			if buff_icon.has_node("BuffIconRemove"):
				var timer_node = buff_icon.get_node("BuffIconRemove")
				if timer_node is Timer:
					timer_node.start(buff_info["AddTime"])
			elif buff_icon.has_method("start_timer"):
				buff_icon.start_timer(buff_info["AddTime"])
			buff_node.set("is_check", true)
	_add_flag_buff_info("defe_reduce", bool(get_obj.get("is_defe_reduce")), float(get_obj.get("defe_reduce")))
	_add_flag_buff_info("stun", bool(get_obj.get("is_stun")), 0.0)


func _collect_armor_buff_info() -> void:
	if not get_obj.is_boss or not get_obj.is_control_immune():
		return
	var armor_time: float = get_obj.white_bar_armor_time_left
	var info: Dictionary = _buff_info_by_name.get("SuperArmor", {})
	if info.is_empty():
		info = {
			"Name": "SuperArmor",
			"value": 0.0,
			"HaveCount": 1,
			"AddTime": get_obj.WHITE_BAR_ARMOR_DURATION if armor_time > 0.0 else 99999.0,
			"TimeLeft": armor_time if armor_time > 0.0 else 99999.0,
			"reduce_interval": 0.0,
			"AttackKind": "",
		}
	elif armor_time > 0.0:
		info["AddTime"] = maxf(float(info["AddTime"]), get_obj.WHITE_BAR_ARMOR_DURATION)
		info["TimeLeft"] = maxf(float(info.get("TimeLeft", 0.0)), armor_time)
	info["ImmuneAllControl"] = true
	_buff_info_by_name["SuperArmor"] = info


func _add_flag_buff_info(buff_name: String, is_active: bool, value: float) -> void:
	if not is_active or _buff_info_by_name.has(buff_name) or not buff_icon_cache.has(buff_name):
		return
	_buff_info_by_name[buff_name] = {
		"Name": buff_name,
		"value": value,
		"AddTime": 1.0,
		"reduce_interval": 0.0,
		"AttackKind": "",
		"HaveCount": 1,
	}
	var buff_icon = buff_icon_cache[buff_name]
	if buff_icon.has_node("BuffIconRemove"):
		var timer_node = buff_icon.get_node("BuffIconRemove")
		if timer_node is Timer:
			timer_node.start(1.0)
	elif buff_icon.has_method("start_timer"):
		buff_icon.start_timer(1.0)


func set_buff_icon_info(Name: String):
	var buff_icon = get_or_create_buff_icon(Name)
	if buff_icon == null:
		return
	var is_have := _buff_info_by_name.has(Name)
	if buff_icon.visible != is_have:
		buff_icon.visible = is_have
		if not is_have and (Name in YUTU_POISON_BUFFS or Name == "SuperArmor"):
			buff_icon._on_mouse_exited()
	if is_have:
		var buff_info: Dictionary = _buff_info_by_name[Name]
		buff_icon.data_list = buff_info.duplicate()
	if buff_icon.is_physics_processing() != is_have:
		buff_icon.set_physics_process(is_have)


func get_or_create_buff_icon(buff_name: String) -> Control:
	if buff_icon_cache.has(buff_name):
		return buff_icon_cache[buff_name]

	var existing_node = buff_list.get_node_or_null(buff_name)
	if existing_node:
		buff_icon_cache[buff_name] = existing_node
		return existing_node

	if BUFF_ICON_SCENE:
		var new_buff_icon = BUFF_ICON_SCENE.instantiate()
		new_buff_icon.name = buff_name

		new_buff_icon.custom_minimum_size = Vector2(40, 40)

		buff_list.add_child(new_buff_icon)

		new_buff_icon.visible = false
		new_buff_icon.set_physics_process(false)

		buff_icon_cache[buff_name] = new_buff_icon

		return new_buff_icon
	else:
		print_debug("无法加载 buff_icon 场景：", buff_name)
		return null


func pre_create_buff_icons():
	"预创建所有 buff 图标（可选）"
	for buff_name in Global.all_buff_list:
		get_or_create_buff_icon(buff_name)


func _exit_tree() -> void:
	for buff_name in buff_icon_cache.keys():
		var buff_icon = buff_icon_cache[buff_name]
		if is_instance_valid(buff_icon):
			buff_icon.queue_free()
	buff_icon_cache.clear()
