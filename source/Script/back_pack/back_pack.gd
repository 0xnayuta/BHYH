extends Node2D

@onready var ldl_class = preload("res://Script/ldl/ldl.gd")

@onready var message_text: Label = $background/infomation/message_text
@onready var hp: Label = $background/infomation/hp
@onready var mp: Label = $background/infomation/mp
@onready var att: Label = $background/infomation/att
@onready var lucky: Label = $background/infomation/lucky
@onready var def: Label = $background/infomation/def
@onready var mdef: Label = $background/infomation/mdef
@onready var crit: Label = $background/infomation/crit
@onready var miss: Label = $background/infomation/miss
@onready var ehp: Label = $background/infomation/ehp
@onready var show_backpack: Button = $background/show_backpack
@onready var emp: Label = $background/infomation/emp
@onready var first: TextureButton = $background/infomation/first
@onready var second: TextureButton = $background/infomation/second
@onready var exp_bar: TextureProgressBar = $background/infomation/exp_bar
@onready var wings: AnimatedSprite2D = $background/Wings

@onready var exp_text: Label = $background/infomation/exp_bar/exp_text
@onready var backpack: Node2D = $backpack
@onready var wq: Button = $background/infomation/equ_/HBoxContainer/wq
@onready var fj: Button = $background/infomation/equ_/HBoxContainer/fj
@onready var sp: Button = $background/infomation/equ_/VBoxContainer/sp
@onready var fb: Button = $background/infomation/equ_/VBoxContainer/fb
@onready var zdl: Label = $background/Zdlnc/zdl
@onready var name_1: LineEdit = $background/Zdlnc/name
@onready var role_body = $background/RoleBody
@onready var role_eq = $background/RoleEquipment
@onready var number_1: TextureRect = $background/infomation/leve_background/Level_Show/Number_1
@onready var number_2: TextureRect = $background/infomation/leve_background/Level_Show/Number_2
@onready var tx: Button = $background/infomation/tx
@onready var sz: Button = $background/infomation/sz
@onready var cb: Button = $background/infomation/cb
@onready var wing_show: Label = $background/infomation/WingsShow/WingShow
@onready var head_show: Label = $background/infomation/HeadShow/HeadShow
@onready var wings_show_button: Button = $background/infomation/WingsShow
@onready var head_show_button: Button = $background/infomation/HeadShow

var add_equ_box
var back_pack_jm
var message
var current_pro_page: int = 1
var show_back_pack = true
var _last_equipped_snapshot: Array = []
var _last_preview_snapshot: Array = []
var _props_refresh_timer: float = 0.0


func _ready() -> void:
	init_show_wing_tx_button()
	match int(PlayerData.player_data["Myself"]):
		1:
			$background/Player.play("wait")
		2:
			$background/Player.play("wait2")
		3:
			$background/Player.play("wait3")
		4:
			$background/Player.play("wait4")
		5:
			$background/Player.play("wait5")
	Global.is_in_ldl = false
	MemoryClass.main_dq()
	if int(MemoryClass.get_cd_number()) <= 6:
		name_1.text = str(MainSet.set_data["name" + str(MemoryClass.get_cd_number())])
	else:
		name_1.text = str(MainSet.set_data["其他存档"][str(MemoryClass.get_cd_number())]["name"])
	$background/gy.self_modulate = Color(1, 1, 1, 1)
	get_level()
	set_backpack_properies()


func _physics_process(_delta: float) -> void:
	if not is_visible_in_tree():
		return

	if PlayerData.player_data["翅膀显示"]:
		wings.modulate = Color(1, 1, 1, 1)
	else:
		wings.modulate = Color(1, 1, 1, 0)
	set_wings_offset()

	_props_refresh_timer += _delta
	if _props_refresh_timer >= 0.1:
		_props_refresh_timer = 0.0
		set_backpack_properies()
	if Global.box_count > 0:
		Global.box_count -= 1


func get_level():
	var level_int = int(RoleProp.baseroleprop.Level)

	var level_str = str(level_int)
	var digit_count = level_str.length()

	if digit_count == 1:
		$background/infomation/leve_background/Level_Show.position = Vector2(-15, -15)
		number_1.texture = load("res://Art/all_number/level/level_" + level_str + ".png")
		number_1.visible = true
		number_2.visible = false
	elif digit_count == 2:
		$background/infomation/leve_background/Level_Show.position = Vector2(-35, -15)
		number_1.texture = load("res://Art/all_number/level/level_" + level_str[0] + ".png")
		number_2.texture = load("res://Art/all_number/level/level_" + level_str[1] + ".png")
		number_1.visible = true
		number_2.visible = true
	else:
		print("等级位数不支持: ", digit_count)

		$background/infomation/leve_background/Level_Show.position = Vector2(-15, -15)
		number_1.texture = load("res://Art/all_number/level/level_1.png")
		number_1.visible = true
		number_2.visible = false


func calculate_combat_power():
	var level_power = RoleProp.baseroleprop.Level * 15

	var passive_data = PlayerData.player_data["被动技能"]
	var passive_per_level = 15
	var rx_level = passive_data["热血"]
	var mq_level = passive_data["魔泉"]
	var kb_level = passive_data["狂暴"]
	var yh_level = passive_data["永恒"]
	var hh_level = passive_data["辉煌"]
	var mr_level = passive_data["敏锐"]
	var passive_power = (rx_level + mq_level + kb_level + yh_level + hh_level + mr_level) * passive_per_level

	var pill_power = 0
	var pellet_weight = {1: 5, 2: 8, 3: 12, 4: 18, 5: 25}
	var pellet_types = ["生命", "魔法", "攻击", "暴击", "幸运", "回魔"]
	for type_name in pellet_types:
		for grade in range(1, 6):
			var count = PlayerData.player_data.get(type_name + "丹" + str(grade), 0)
			pill_power += count * pellet_weight[grade]

	var fixed_power = level_power + passive_power + pill_power

	var power = RoleProp.roleprop.power
	var shp = RoleProp.roleprop.SHp
	var smp = RoleProp.roleprop.SMp
	var def_raw = RoleProp.roleprop.Def
	var mdef_raw = RoleProp.roleprop.Mdef
	var role_crit = RoleProp.roleprop.Crit
	var role_miss = RoleProp.roleprop.Miss
	var role_lucky = RoleProp.roleprop.Lucky
	var rhp = RoleProp.roleprop.R_hp
	var rmp = RoleProp.roleprop.R_mp
	var htarget = RoleProp.roleprop.htarget
	var toughness = RoleProp.roleprop.toughness
	var vampirism = RoleProp.roleprop.vampirism * 100
	var crit_reduce = RoleProp.roleprop.CritReduce
	var ar = RoleProp.roleprop.ar
	var break_magic = RoleProp.roleprop.sp

	var w_power = 1.0
	var w_shp = 0.1
	var w_smp = 0.05
	var w_def = 0.4
	var w_mdef = 0.4
	var w_crit = 0.8
	var w_miss = 0.7
	var w_lucky = 0.6
	var w_rhp = 2.0
	var w_rmp = 2.0
	var w_htarget = 0.5
	var w_toughness = 0.5
	var w_vamp = 3.0
	var w_cr = 0.6
	var w_ar = 0.7
	var w_sp = 0.7

	var role_id = int(PlayerData.player_data["Myself"])
	var mul_power = 1.0
	var mul_shp = 1.0
	var mul_smp = 1.0
	var mul_def = 1.0
	var mul_mdef = 1.0
	var mul_crit = 1.0
	var mul_miss = 1.0
	var mul_lucky = 1.0
	var mul_rhp = 1.0
	var mul_rmp = 1.0
	var mul_htarget = 1.0
	var mul_toughness = 1.0
	var mul_vamp = 1.0
	var mul_cr = 1.0
	var mul_ar = 1.0
	var mul_sp = 1.0

	match role_id:
		1:
			mul_power = 1.2
			mul_crit = 1.2
			mul_lucky = 1.2
			mul_shp = 0.9
			mul_def = 0.9
		2:
			mul_mdef = 1.2
			mul_rmp = 1.3
			mul_sp = 1.2
			mul_def = 0.9
		3:
			mul_shp = 1.3
			mul_def = 1.2
			mul_rhp = 1.3
			mul_cr = 1.2
			mul_power = 0.9
		4:
			mul_miss = 1.2
			mul_htarget = 1.2
			mul_ar = 1.2
			mul_mdef = 0.9
		5:
			mul_power = 1.0
			mul_crit = 1.0
			mul_miss = 1.0
			mul_shp = 1.0
			mul_def = 1.0
			mul_mdef = 1.0

	var attack_power = power * w_power * mul_power
	var survive_power = (
		shp * w_shp * mul_shp + smp * w_smp * mul_smp + def_raw * w_def * mul_def + mdef_raw * w_mdef * mul_mdef
	)
	var crit_power = role_crit * w_crit * mul_crit + role_miss * w_miss * mul_miss + role_lucky * w_lucky * mul_lucky
	var regen_power = rhp * w_rhp * mul_rhp + rmp * w_rmp * mul_rmp
	var adv_power = (
		htarget * w_htarget * mul_htarget
		+ toughness * w_toughness * mul_toughness
		+ vampirism * w_vamp * mul_vamp
		+ crit_reduce * w_cr * mul_cr
		+ ar * w_ar * mul_ar
		+ break_magic * w_sp * mul_sp
	)

	var total = fixed_power + attack_power + survive_power + crit_power + regen_power + adv_power
	return int(total)


func _refresh_preview_if_changed() -> void:
	var snapshot := [
		PlayerData.player_data.get(DataKeys.WEAPON, []),
		PlayerData.player_data.get(DataKeys.ARMOR, []),
		PlayerData.player_data.get(DataKeys.FASHION, []),
		PlayerData.player_data.get(DataKeys.WINGS, []),
		PlayerData.player_data.get(DataKeys.TRANSMOG_LIST, {}),
	]
	if snapshot == _last_preview_snapshot:
		return
	_last_preview_snapshot = snapshot.duplicate(true)
	on_eqchange()


func set_backpack_properies():
	zdl.text = str(calculate_combat_power())
	_refresh_preview_if_changed()
	set_icon()

	if current_pro_page == 1:
		message_text.text = "角色属性详情第一页"
		$background/infomation/hp/Hp_tt.text = "生命"
		$background/infomation/mp/Mp_tt.text = "魔法"
		$background/infomation/att/Att_tt.text = "攻击"
		$background/infomation/def/Def_tt.text = "物防"
		$background/infomation/lucky/Lucky_tt.text = "幸运"
		$background/infomation/mdef/Mdef_tt.text = "魔防"
		$background/infomation/crit/Crit_tt.text = "暴击"
		$background/infomation/miss/misstt.text = "闪避"
		$background/infomation/ehp/ehp_tt.text = "回血"
		$background/infomation/emp/emp_tt.text = "回魔"

		hp.text = str(int(RoleProp.roleprop.Hp)) + "/" + str(int(RoleProp.roleprop.SHp))
		mp.text = str(int(RoleProp.roleprop.Mp)) + "/" + str(int(RoleProp.roleprop.SMp))
		att.text = str(int(RoleProp.roleprop.power))

		ehp.text = "%.2f" % RoleProp.roleprop.R_hp
		emp.text = "%.2f" % RoleProp.roleprop.R_mp

		var def_raw = RoleProp.roleprop.Def
		var def_rate = snapped(def_raw / float(def_raw + 250), 0.001) * 100
		def.text = str(int(def_raw)) + " (" + ("%.2f" % def_rate) + "%)"

		var mdef_raw = RoleProp.roleprop.Mdef
		var mdef_rate = snapped(mdef_raw / float(mdef_raw + 250), 0.001) * 100
		mdef.text = str(int(mdef_raw)) + " (" + ("%.2f" % mdef_rate) + "%)"

		var crit_raw = RoleProp.roleprop.Crit
		var crit_rate = snapped(crit_raw / float(crit_raw + 100), 0.001) * 100
		crit.text = ("%.2f" % crit_raw) + " (" + ("%.2f" % crit_rate) + "%)"

		var miss_raw = RoleProp.roleprop.Miss
		var miss_rate = snapped(miss_raw / float(miss_raw + 100), 0.001) * 100
		miss.text = ("%.2f" % miss_raw) + " (" + ("%.2f" % miss_rate) + "%)"

		var lucky_raw = RoleProp.roleprop.Lucky
		var lucky_rate = snapped(lucky_raw / float(lucky_raw + 50), 0.001) * 100
		lucky.text = ("%.2f" % lucky_raw) + " (" + ("%.2f" % lucky_rate) + "%)"

	elif current_pro_page == 2:
		message_text.text = "角色属性详情第二页"
		$background/infomation/hp/Hp_tt.text = "命中"
		$background/infomation/mp/Mp_tt.text = "韧性"
		$background/infomation/att/Att_tt.text = "吸血"
		$background/infomation/def/Def_tt.text = "暴免"
		$background/infomation/lucky/Lucky_tt.text = "破甲"
		$background/infomation/mdef/Mdef_tt.text = "破魔"
		$background/infomation/crit/Crit_tt.text = ""
		$background/infomation/miss/misstt.text = ""
		$background/infomation/ehp/ehp_tt.text = ""
		$background/infomation/emp/emp_tt.text = ""

		hp.text = str(RoleProp.roleprop.htarget)
		mp.text = str(RoleProp.roleprop.toughness)

		att.text = "%.2f" % (RoleProp.roleprop.vampirism * 100) + "%"
		def.text = str(RoleProp.roleprop.CritReduce)
		lucky.text = str(RoleProp.roleprop.ar)
		mdef.text = str(RoleProp.roleprop.sp)
		ehp.text = ""
		emp.text = ""
		crit.text = ""
		miss.text = ""

	exp_bar.value = float(RoleProp.baseroleprop.exp) / RoleProp.baseroleprop.max_exp
	exp_text.text = str(RoleProp.baseroleprop.exp) + "/" + str(RoleProp.baseroleprop.max_exp)


func set_icon():
	var current_snapshot = [
		PlayerData.player_data.get(DataKeys.WEAPON, []),
		PlayerData.player_data.get(DataKeys.ARMOR, []),
		PlayerData.player_data.get("饰品", []),
		PlayerData.player_data.get(DataKeys.TITLE, []),
		PlayerData.player_data.get(DataKeys.FASHION, []),
		PlayerData.player_data.get(DataKeys.WINGS, []),
		PlayerData.player_data.get(DataKeys.MAGIC_WEAPON, [])
	]
	if current_snapshot == _last_equipped_snapshot:
		return
	_last_equipped_snapshot = current_snapshot.duplicate(true)
	if PlayerData.player_data[DataKeys.WEAPON].size() != 0:
		wq.get_item_name = PlayerData.player_data[DataKeys.WEAPON][0][DataKeys.NAME]
		wq.set_button_icon(load_item_icon(PlayerData.player_data[DataKeys.WEAPON][0][DataKeys.NAME]))
		wq.qh_level = PlayerData.player_data[DataKeys.WEAPON][0][DataKeys.ENHANCE_LEVEL]
		wq.eq_prop = PlayerData.player_data[DataKeys.WEAPON][0]["Data"]
	else:
		wq.set_button_icon(load_item_icon("wq"))
	if PlayerData.player_data[DataKeys.ARMOR].size() != 0:
		fj.get_item_name = PlayerData.player_data[DataKeys.ARMOR][0][DataKeys.NAME]
		fj.set_button_icon(load_item_icon(PlayerData.player_data[DataKeys.ARMOR][0][DataKeys.NAME]))
		fj.qh_level = PlayerData.player_data[DataKeys.ARMOR][0][DataKeys.ENHANCE_LEVEL]
		fj.eq_prop = PlayerData.player_data[DataKeys.ARMOR][0]["Data"]
	else:
		fj.set_button_icon(load_item_icon("fj"))
	if PlayerData.player_data["饰品"].size() != 0:
		sp.get_item_name = PlayerData.player_data["饰品"][0][DataKeys.NAME]
		sp.set_button_icon(load_item_icon(PlayerData.player_data["饰品"][0][DataKeys.NAME]))
		sp.qh_level = PlayerData.player_data["饰品"][0][DataKeys.ENHANCE_LEVEL]
		sp.eq_prop = PlayerData.player_data["饰品"][0]["Data"]
	else:
		sp.set_button_icon(load_item_icon("sp"))
	if PlayerData.player_data[DataKeys.TITLE].size() != 0:
		tx.get_item_name = PlayerData.player_data[DataKeys.TITLE][0][DataKeys.NAME]
		tx.set_button_icon(load_item_icon(PlayerData.player_data[DataKeys.TITLE][0][DataKeys.NAME]))
		tx.qh_level = PlayerData.player_data[DataKeys.TITLE][0][DataKeys.ENHANCE_LEVEL]
		tx.eq_prop = PlayerData.player_data[DataKeys.TITLE][0]["Data"]
	else:
		tx.set_button_icon(load_item_icon("tx"))
	if PlayerData.player_data[DataKeys.FASHION].size() != 0:
		sz.get_item_name = PlayerData.player_data[DataKeys.FASHION][0][DataKeys.NAME]
		sz.set_button_icon(load_item_icon(PlayerData.player_data[DataKeys.FASHION][0][DataKeys.NAME]))
		sz.qh_level = PlayerData.player_data[DataKeys.FASHION][0][DataKeys.ENHANCE_LEVEL]
		sz.eq_prop = PlayerData.player_data[DataKeys.FASHION][0]["Data"]
	else:
		sz.set_button_icon(load_item_icon("sz"))
	if PlayerData.player_data[DataKeys.WINGS].size() != 0:
		cb.get_item_name = PlayerData.player_data[DataKeys.WINGS][0][DataKeys.NAME]
		cb.set_button_icon(load_item_icon(PlayerData.player_data[DataKeys.WINGS][0][DataKeys.NAME]))
		cb.qh_level = PlayerData.player_data[DataKeys.WINGS][0][DataKeys.ENHANCE_LEVEL]
		cb.eq_prop = PlayerData.player_data[DataKeys.WINGS][0]["Data"]
	else:
		cb.set_button_icon(load_item_icon("cb"))
	if PlayerData.player_data[DataKeys.MAGIC_WEAPON].size() != 0:
		fb.get_item_name = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.NAME]
		fb.set_button_icon(load_item_icon(PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.NAME]))
		fb.qh_level = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.ENHANCE_LEVEL]
		fb.eq_prop = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0]["Data"]
		fb.wx = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.FIVE_ELEMENTS]
	else:
		fb.set_button_icon(load_item_icon("fb"))


func load_item_icon(_name):
	var primary_path = "res://Art/backpack/all_items/" + str(_name) + ".png"
	if ResourceLoader.exists(primary_path):
		return load(primary_path)
	var fallback_path = "res://Art/backpack/" + str(_name) + ".png"
	if ResourceLoader.exists(fallback_path):
		return load(fallback_path)
	return null


func _on_first_pressed() -> void:
	current_pro_page = 1
	set_backpack_properies()


func _on_second_pressed() -> void:
	current_pro_page = 2
	set_backpack_properies()


func _on_close_pressed() -> void:
	queue_free()


func _on_show_backpack_pressed() -> void:
	if show_back_pack == false:
		show_back_pack = true
	elif show_back_pack == true:
		show_back_pack = false


func add_text(text, parent):
	if message == null:
		message = Global.add_basic_monment_info(backpack, text, get_global_mouse_position() + Vector2(90, 40))


func remove_text():
	if message != null:
		message.queue_free()


func _on_hp_mouse_entered() -> void:
	if current_pro_page == 1:
		add_text("生命：角色的健康力，归0后角色死亡。", hp)
	else:
		add_text("命中：与闪避以减法相抵扣。", hp)


func _on_hp_mouse_exited() -> void:
	remove_text()


func _on_mp_mouse_entered() -> void:
	if current_pro_page == 1:
		add_text("魔法：角色使用技能所需消耗的能量，低于需求则无法释放技能。", mp)
	else:
		add_text("韧性：与幸运以减法相抵扣。", mp)


func _on_mp_mouse_exited() -> void:
	remove_text()


func _on_att_mouse_entered() -> void:
	if current_pro_page == 1:
		add_text("攻击：角色造成一切伤害的基本来源。", att)
	else:
		add_text("吸血：造成直接伤害时，恢复该倍率×最终伤害的生命值。", att)


func _on_att_mouse_exited() -> void:
	remove_text()


func _on_lucky_mouse_entered() -> void:
	if current_pro_page == 1:
		add_text("幸运：提升角色造成暴击时的暴击伤害。", lucky)
	else:
		add_text("破甲：与物理防御以减法相抵扣。", lucky)


func _on_lucky_mouse_exited() -> void:
	remove_text()


func _on_def_mouse_entered() -> void:
	if current_pro_page == 1:
		add_text("物防：减免角色受到的物理伤害。", def)
	else:
		add_text("暴免：与暴击以减法相抵扣。", def)


func _on_def_mouse_exited() -> void:
	remove_text()


func _on_mdef_mouse_entered() -> void:
	if current_pro_page == 1:
		add_text("魔防：减免角色受到的魔法伤害。", mdef)
	else:
		add_text("破魔：与魔防以减法相抵扣。", mdef)


func _on_mdef_mouse_exited() -> void:
	remove_text()


func _on_crit_mouse_entered() -> void:
	if current_pro_page == 1:
		add_text("暴击：提升角色造成更高伤害的几率。", crit)
	else:
		pass


func _on_crit_mouse_exited() -> void:
	remove_text()


func _on_miss_mouse_entered() -> void:
	if current_pro_page == 1:
		add_text("闪避：提升角色无视伤害的几率（闪避时视为霸体效果）。", miss)
	else:
		pass


func _on_miss_mouse_exited() -> void:
	remove_text()


func _on_ehp_mouse_entered() -> void:
	if current_pro_page == 1:
		add_text("回血：角色每秒恢复该数值的生命。", ehp)
	else:
		pass


func _on_ehp_mouse_exited() -> void:
	remove_text()


func _on_emp_mouse_entered() -> void:
	if current_pro_page == 1:
		add_text("回魔：角色每秒恢复该数值的魔法。", emp)
	else:
		pass


func _on_emp_mouse_exited() -> void:
	remove_text()


func _on_name_text_changed(new_text: String) -> void:
	if int(MemoryClass.get_cd_number()) <= 6:
		MainSet.set_data["name" + str(MemoryClass.get_cd_number())] = new_text
	else:
		MainSet.set_data["其他存档"][str(MemoryClass.get_cd_number())]["name"] = new_text
	MemoryClass.main_bc()


func set_role_wings():
	var wings_list = PlayerData.player_data[DataKeys.WINGS]
	if wings_list.size() <= 0:
		wings.visible = false
		wings.play("empty")
		return
	var get_wings_name = wings_list[0][DataKeys.NAME]
	wings.play(get_wings_name)
	return


func on_eqchange():
	# 角色 6/7 的装备预览由 NeZhaPreview 独占；父级只更新翅膀。
	var role_id := int(PlayerData.player_data.get("Myself", 1))
	var wq: String
	var fj: String

	if PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WEAPON] == "":
		if PlayerData.player_data[DataKeys.WEAPON].size() == 0:
			wq = "Empty"
		else:
			wq = str(PlayerData.player_data[DataKeys.WEAPON][0][DataKeys.NAME])
	else:
		wq = str(PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WEAPON])
	if role_id >= 1 and role_id <= 5:
		change_eq(wq)
	if PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.ARMOR] == "":
		if PlayerData.player_data[DataKeys.FASHION].size() == 0:
			if PlayerData.player_data[DataKeys.ARMOR].size() == 0:
				fj = "Empty"
			else:
				fj = str(PlayerData.player_data[DataKeys.ARMOR][0][DataKeys.NAME])
		else:
			fj = str(PlayerData.player_data[DataKeys.FASHION][0][DataKeys.NAME])
	else:
		fj = str(PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.ARMOR])
	fj = Global.get_clean_name(fj)
	if role_id >= 1 and role_id <= 5:
		change_body(fj)
	var wings_list

	if PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WINGS] == "":
		if PlayerData.player_data[DataKeys.WINGS].size() == 0:
			wings.visible = false
			wings_list = "empty"
		else:
			wings.visible = true
			wings_list = PlayerData.player_data[DataKeys.WINGS][0][DataKeys.NAME]
	else:
		wings.visible = true
		wings_list = PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WINGS]
	$background/Wings.play(wings_list)


func change_body(_name):
	role_body.texture = Global.load_role1_body(_name)


func change_eq(_name):
	role_eq.texture = Global.load_role1_eq(_name)


func init_show_wing_tx_button():
	if PlayerData.player_data["翅膀显示"]:
		wings_show_button.set_button_icon(load("res://Art/backpack/is_choose.png"))
		wing_show.text = "显示"
	else:
		wing_show.text = "不显示"
		wings_show_button.set_button_icon(load("res://Art/backpack/no_choose.png"))
	if PlayerData.player_data["头衔显示"]:
		head_show.text = "显示"
		head_show_button.set_button_icon(load("res://Art/backpack/is_choose.png"))
	else:
		head_show.text = "不显示"
		head_show_button.set_button_icon(load("res://Art/backpack/no_choose.png"))


func _on_wings_show_pressed() -> void:
	if PlayerData.player_data["翅膀显示"]:
		PlayerData.player_data["翅膀显示"] = false
		MemoryClass.request_save("back_pack_wings_show")
		wings_show_button.set_button_icon(load("res://Art/backpack/no_choose.png"))
		wing_show.text = "不显示"
	else:
		PlayerData.player_data["翅膀显示"] = true
		MemoryClass.request_save("back_pack_wings_show")
		wing_show.text = "显示"
		wings_show_button.set_button_icon(load("res://Art/backpack/is_choose.png"))


func _on_head_show_pressed() -> void:
	if PlayerData.player_data["头衔显示"]:
		head_show_button.set_button_icon(load("res://Art/backpack/no_choose.png"))
		PlayerData.player_data["头衔显示"] = false
		MemoryClass.request_save("back_pack_head_show")
		head_show.text = "不显示"

	else:
		head_show_button.set_button_icon(load("res://Art/backpack/is_choose.png"))
		PlayerData.player_data["头衔显示"] = true
		MemoryClass.request_save("back_pack_head_show")
		head_show.text = "显示"


func set_wings_offset():
	var current_wings_name: String

	if PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WINGS] == "":
		if PlayerData.player_data[DataKeys.WINGS].size() == 0:
			current_wings_name = "empty"
		else:
			current_wings_name = PlayerData.player_data[DataKeys.WINGS][0][DataKeys.NAME]
	else:
		current_wings_name = PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WINGS]
	match current_wings_name:
		"xtzy", "ttzy":
			wings.offset = Vector2(0, 0)
			wings.scale = Vector2(1.6, 1.6)
		"xqzy":
			wings.offset = Vector2(5, 15)
			wings.scale = Vector2(1.2, 1.2)
		"jmzy":
			wings.offset = Vector2(20, 15)
			wings.scale = Vector2(1.1, 1.1)
		"xmzy":
			wings.offset = Vector2(20, -15)
			wings.scale = Vector2(1, 1)
		"bszy":
			wings.offset = Vector2(15, 15)
			wings.scale = Vector2(1, 1)


func _on_hh_pressed() -> void:
	var new_scene = Global.add_h_hjm(self, Vector2(-428, -270))

	if new_scene != null:
		new_scene.z_index = 100
