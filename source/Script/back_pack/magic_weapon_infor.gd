extends Node2D

## 显式操作者：按所在面板的槽位解析数据与属性，不依赖全局 1P/2P 视图交换。
var PlayerData: PlayerDataStore:
	get:
		return LocalCoop.data_for(self) as PlayerDataStore
var RoleProp: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self) as BaseRoleProperties

@onready var lh_bar: TextureProgressBar = $BG/Content/bg_2/lh_bar
@onready var lh_value: Label = $BG/Content/bg_2/lh_bar/lh_value
@onready var m_level: Label = $BG/Content/bg_2/m_level
@onready var m_czl: Label = $BG/Content/bg_2/m_czl
@onready var m_wx: Label = $BG/Content/bg_2/m_wx
@onready var m_hp: Label = $BG/Content/bg_2/m_Hp
@onready var m_mp: Label = $BG/Content/bg_2/m_Mp
@onready var m_power: Label = $BG/Content/bg_2/m_Power
@onready var m_def: Label = $BG/Content/bg_2/m_Def
@onready var m_m_def: Label = $BG/Content/bg_2/m_MDef
@onready var _name: Label = $BG/Content/Name_
@onready var icon: Sprite2D = $BG/Content/Icon
@onready var icon_player: AnimationPlayer = $BG/Content/IconPlayer
@onready var magic_weapon_skill_title: Label = $BG/Content/MagicWeaponSkillTitle
@onready var magic_weapon_skill: Label = $BG/Content/ScrollContainer/VBoxContainer/MagicWeaponSkill
@onready var pa_title: Label = $BG/Content/ScrollContainer/VBoxContainer/PsTitle
@onready var magic_weapon_skill_2: Label = $BG/Content/ScrollContainer/VBoxContainer/MagicWeaponSkill2
@onready var _icon: Sprite2D = $BG/Content/Icon_
@onready var content: Node2D = $BG/Content
@onready var empty_state: Label = $BG/EmptyState

const PREVIEW_ICONS := {
	"tjbg": "res://Art/magic_weapon/skill_icon/tjbg.png",
	"zcld": "res://Art/magic_weapon/skill_icon/zcld.png",
	"dshl": "res://Art/magic_weapon/skill_icon/dshl.png",
	"dhqf": "res://Art/magic_weapon/skill_icon/dhqf.png",
	"tsgj": "res://Art/magic_weapon/skill_icon/wjgz.png",
	"bsyj": "res://Art/magic_weapon/skill_icon/bsyj.png",
	"lsys": "res://Art/magic_weapon/skill_icon/lsys.png",
	"xhmt": "res://Art/magic_weapon/skill_icon/xhmt.png",
	"kyl": "res://Art/magic_weapon/skill_icon/kyl.png",
	"xhhl": "res://Art/magic_weapon/skill_icon/xhhl.png",
	"qyj": "res://Art/magic_weapon/skill_icon/qyj.png",
	"zjfyd": "res://Art/magic_weapon/skill_icon/zjfyd.png",
	"zjhl": "res://Art/magic_weapon/skill_icon/zjhl.png",
	"yjp": "res://Art/magic_weapon/skill_icon/yjp.png",
	"yx": "res://Art/magic_weapon/skill_icon/yx.png",
	"qlsword": "res://Art/magic_weapon/skill_icon/qlsword.png",
	"dzyl": "res://Art/magic_weapon/skill_icon/dzyl.png",
	"469000004": "res://Art/magic_weapon/skill_icon/469000004.png",
	"469000011": "res://Art/magic_weapon/skill_icon/469000011.png",
	"zlwdah": "res://Art/magic_weapon/skill_icon/zlwdah.png",
	"sqzlw": "res://Art/magic_weapon/skill_icon/zlwdah.png",
	"nmwdnh": "res://Art/magic_weapon/skill_icon/nmwdnh.png",
	"sqnmwdnh": "res://Art/magic_weapon/skill_icon/nmwdnh.png",
	"xianyjp": "res://Art/magic_weapon/skill_icon/xianyjp.png",
	"yyzlj": "res://Art/magic_weapon/skill_icon/yyzlj.png",
	"ywhl": "res://Art/magic_weapon/skill_icon/ywhl.png",
	"zhyx": "res://Art/magic_weapon/skill_icon/zhyx.png",
	"bjs": "res://Art/magic_weapon/skill_icon/bjs.png",
	"sxyg": "res://Art/magic_weapon/skill_icon/sxyg.png",
	"dkhl": "res://Art/magic_weapon/skill_icon/dkhl.png",
	"yyb": "res://Art/magic_weapon/skill_icon/yyb.png",
	"hehua": "res://Art/magic_weapon/skill_icon/hehua.png",
}

const SKILL_INFO := {
	"tjbg":
	{
		"title": "太极八卦",
		"desc": "6级解锁全场眩晕，消耗10魔法，冷却20秒。眩晕时间为法宝等级的一半，木属性翻倍。",
		"passive": "每关可满血复活一次，并获得2秒无敌；木属性额外恢复一半最大魔法。"
	},
	"zcld": {"title": "招财进宝好运来！", "desc": "无主动技能。", "passive": "提升灵魂获取和掉宝率！随等级提高。"},
	"dshl": {"title": "烈焰火柱", "desc": "释放三道火柱，对范围内的敌人造成多段物理伤害（并令其灼烧）。"},
	"dhqf": {"title": "士气鼓舞", "desc": "拥有【士气鼓舞】技能，回复少量血和蓝。"},
	"tsgj": {"title": "万剑归宗", "desc": "召唤数把巨剑从天而降，造成多段魔法伤害（30%概率冰冻命中的目标）。"},
	"bsyj": {"title": "邪灵寄生", "desc": "附身到怪物身上偷取生命并令其减速，一段时间后将偷取到的生命给予玩家。"},
	"lsys": {"title": "暴雨梨花", "desc": "散出漫天毒针，命中敌人后会造成少量伤害并令其中毒。"},
	"xhmt": {"title": "魔童连击邪灵净化", "desc": "清除低级负面效果，之后对目标进行多次打击，造成魔法伤害。"},
	"kyl": {"title": "沐露回春", "desc": "每秒为玩家恢复生命，期间免疫击退，持续10秒。"},
	"xhhl": {"title": "万象天引", "desc": "将怪物吸引至玩家身边。"},
	"qyj": {"title": "戮天斩击", "desc": "释放剑阵，飞向当前生命最高的敌人，对受到伤害的目标施加破甲。"},
	"zjfyd": {"title": "不灭神盾", "desc": "拥有【不灭神盾】技能，使用后获得【不灭】Buff，一段时间内免疫高于当前生命的伤害。"},
	"zjhl": {"title": "伏妖神火", "desc": "拥有【伏妖神火】技能，朝前方喷出火焰，造成物理伤害，并有10%概率施加一层灼烧。"},
	"yjp": {"title": "吸收", "desc": "吸取Boss技能，释放Boss战斗。"},
	"zlwdah": {"title": "召唤", "desc": "召唤转轮王。"},
	"sqzlw": {"title": "召唤", "desc": "召唤转轮王。"},
	"nmwdnh": {"title": "召唤", "desc": "召唤牛魔王。"},
	"sqnmwdnh": {"title": "召唤", "desc": "召唤牛魔王。"},
	"xianyjp": {"title": "召唤", "desc": "召唤观音助战。"},
	"yx": {"title": "入魔", "desc": "扣除并失去一半生命值，攻击力与暴击率提高50%，持续一段时间。"},
	"qlsword": {"title": "御剑飞行", "desc": "脚踏青龙剑，御剑飞行！"},
	"dzyl": {"title": "护体圣莲", "desc": "减少受到的伤害并持续一段时间霸体。"},
	"469000004": {"title": "浩瀚雷音", "desc": "天锤敲击空气，对大范围怪物造成伤害并使其眩晕，法宝等级越高眩晕时间越长。"},
	"469000011": {"title": "御魔领域", "desc": "在原地创造隔绝所有伤害的空间；进入领域后怪物攻击无法命中，离开立即失效，持续时间随法宝等级提升。"},
	"yyzlj": {"title": "阴阳斩龙剑", "desc": "召唤阴阳斩龙剑攻击敌人。"},
	"ywhl": {"title": "药王葫芦", "desc": "使用后恢复生命值。"},
	"zhyx": {"title": "镇魂玉箫", "desc": "吹奏玉箫，使敌人进入睡眠状态。"},
	"bjs": {"title": "玄风棕扇", "desc": "召唤玄风棕扇吹出强风攻击敌人。"},
	"sxyg": {"title": "神行", "desc": "短时间提升移动速度。"},
	"dkhl": {"title": "地魁花篮", "desc": "持续恢复生命和魔法。"},
	"yyb": {"title": "云阳板", "desc": "提升宠物战斗能力。"},
	"hehua": {"title": "慈心妙莲", "desc": "复活已阵亡的宠物。"},
}

var choosejm_1
var choosejm_2
var choosejm_3
var choosejm_4
var _displayed_weapon_name: String = ""


func _ready() -> void:
	icon.texture = null
	_refresh_weapon_state()
	if _has_equipped_weapon():
		_refresh_weapon_visual_if_needed()


func _exit_tree() -> void:
	if icon != null:
		icon.texture = null


func _has_equipped_weapon() -> bool:
	return not PlayerData.player_data.get(DataKeys.MAGIC_WEAPON, []).is_empty()


func _refresh_weapon_state() -> bool:
	var has_weapon := _has_equipped_weapon()
	content.visible = has_weapon
	empty_state.visible = not has_weapon
	if not has_weapon:
		_clear_weapon_view()
	return has_weapon


func _clear_weapon_view() -> void:
	if _displayed_weapon_name == "" and icon.texture == null:
		return
	_displayed_weapon_name = ""
	icon_player.stop()
	icon.texture = null
	_icon.texture = null
	lh_bar.value = 0.0
	_name.text = ""
	lh_value.text = ""
	m_level.text = ""
	m_czl.text = ""
	m_wx.text = ""
	m_hp.text = ""
	m_mp.text = ""
	m_power.text = ""
	m_def.text = ""
	m_m_def.text = ""
	magic_weapon_skill_title.text = ""
	magic_weapon_skill.text = ""
	pa_title.text = ""
	magic_weapon_skill_2.text = ""


func _physics_process(_delta: float) -> void:
	if not _refresh_weapon_state():
		return
	_refresh_weapon_visual_if_needed()
	lh_bar.value = float(PlayerData.get_soul()) / float(get_need_lh())
	lh_value.text = str(PlayerData.get_soul()) + "/" + str(get_need_lh())
	var nn_name = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.NAME]
	var base_level := int(PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.ENHANCE_LEVEL])
	m_level.text = str(base_level + (1 if str(nn_name) == "tjbg" else 0))
	m_wx.text = str(get_wx())
	m_czl.text = "%.1f" % get_fb_pro(nn_name, "成长率")
	m_hp.text = "%.1f" % get_fb_pro(nn_name, "SHp")
	m_mp.text = "%.1f" % get_fb_pro(nn_name, "SMp")
	m_power.text = "%.1f" % get_fb_pro(nn_name, "power")
	m_def.text = "%.1f" % get_fb_pro(nn_name, "Def")
	m_m_def.text = "%.1f" % get_fb_pro(nn_name, "Mdef")


func _refresh_weapon_visual_if_needed() -> void:
	if not _has_equipped_weapon():
		return
	var nn_name := str(PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.NAME])
	if nn_name == _displayed_weapon_name:
		return
	_displayed_weapon_name = nn_name
	_name.text = str(AE.all_equipment[nn_name][DataKeys.NAME])
	set_skill_info(nn_name)
	_show_lazy_preview(nn_name)


func _show_lazy_preview(weapon_name: String) -> void:
	icon_player.stop()
	icon.texture = null
	var texture_path := str(PREVIEW_ICONS.get(weapon_name, ""))
	if texture_path == "":
		return
	icon.position = Vector2(-200, -75)
	icon.scale = Vector2(1.5, 1.5)
	icon.texture = _load_preview_texture(texture_path)


func _load_preview_texture(path: String) -> Texture2D:
	return Global.get_static_texture(path)


func _on_up_level_pressed() -> void:
	if not _has_equipped_weapon():
		return
	if PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.ENHANCE_LEVEL] < 15:
		if PlayerData.get_soul() >= get_need_lh():
			PlayerData.spend_soul(get_need_lh())
			PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.ENHANCE_LEVEL] += 1
			MemoryClass.request_save("magic_weapon_enhance")
		else:
			Global.add_message_show(self, "灵魂不足！！", 1.5, Vector2(0, 0))
			MemoryClass.request_save("magic_weapon_enhance")
	else:
		Global.add_message_show(self, "法宝已经满级了！", 1.5, Vector2(0, 0))
		MemoryClass.request_save("magic_weapon_enhance")


func set_skill_info(weapon_name: String = "") -> void:
	if not _has_equipped_weapon():
		return
	if weapon_name == "":
		weapon_name = str(PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.NAME])
	var info: Dictionary = SKILL_INFO.get(weapon_name, {})
	_icon.texture = Global.get_static_texture(str(PREVIEW_ICONS.get(weapon_name, "")))
	magic_weapon_skill_title.text = str(info.get("title", ""))
	magic_weapon_skill.text = str(info.get("desc", ""))
	pa_title.text = "被动技能"
	magic_weapon_skill_2.text = str(info.get("passive", "暂无"))


func _on_close_pressed() -> void:
	queue_free()


func get_need_lh() -> int:
	var current_level: int = 0
	if PlayerData.player_data[DataKeys.MAGIC_WEAPON].size() != 0:
		current_level = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.ENHANCE_LEVEL]
	return 1000 * int(pow(current_level + 1, 2))


func get_fb_pro(_name, need):
	if not _has_equipped_weapon():
		return 0.0
	var wx = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.FIVE_ELEMENTS]
	var _level = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.ENHANCE_LEVEL]
	var data = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0]["Data"]
	var infomation = AE.get_fb_last_equ_pro(_name, _level, wx, data)[need]
	return infomation


func get_wx() -> String:
	if not _has_equipped_weapon():
		return ""
	var wx = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.FIVE_ELEMENTS]
	var a = ""
	for i in wx:
		a = a + str(i)
	return a


func _on_szfb_pressed() -> void:
	if not _has_equipped_weapon():
		return
	Global.add_use_magic_weapon($".", Vector2(0, 0))


func _on_tips_pressed() -> void:
	Global.add_magic_help($".", Vector2(0, 0))


func low_wx() -> void:
	if not _has_equipped_weapon():
		return
	if PlayerData.get_item_data("wxxls") >= 1:
		PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.FIVE_ELEMENTS] = Global.get_wx(0)
		PlayerData.remove_dj("wxxls", PlayerData.get_dj_page("wxxls"), 1)
		Global.add_message_show(get_parent(), "法宝五行已重置！！", 1.5, Vector2(490, 280))
	else:
		Global.add_message_show(get_parent(), "五行洗炼石数量不足！", 1.5, Vector2(490, 280))


func high_wx() -> void:
	if not _has_equipped_weapon():
		return
	var wx_num = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.FIVE_ELEMENTS].size() * 5
	if PlayerData.get_item_data("wxxls") >= wx_num:
		match PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.FIVE_ELEMENTS].size():
			0:
				PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.FIVE_ELEMENTS] = Global.get_wx(0)
			1:
				PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.FIVE_ELEMENTS] = Global.get_wx(2)
			2:
				PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.FIVE_ELEMENTS] = Global.get_wx(3)
			3:
				PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.FIVE_ELEMENTS] = Global.get_wx(4)
			4:
				PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.FIVE_ELEMENTS] = Global.get_wx(5)
		PlayerData.remove_dj("wxxls", PlayerData.get_dj_page("wxxls"), wx_num)
		Global.add_message_show(get_parent(), "法宝五行已重置！！", 1.5, Vector2(490, 280))
	else:
		Global.add_message_show(get_parent(), "五行洗炼石数量不足！", 1.5, Vector2(490, 280))


func czl() -> void:
	if not _has_equipped_weapon():
		return
	if PlayerData.get_item_data("czlxls") >= 1:
		PlayerData.player_data[DataKeys.MAGIC_WEAPON][0]["Data"]["成长率"] = magic_weapon_czl(
			PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.NAME]
		)
		PlayerData.remove_dj("czlxls", PlayerData.get_dj_page("czlxls"), 1)
		Global.add_message_show(get_parent(), "法宝成长已重置！！", 1.5, Vector2(490, 280))
	else:
		Global.add_message_show(get_parent(), "成长率洗炼石数量不足！", 1.5, Vector2(490, 280))


func _on_wxxl_pressed() -> void:
	if not _has_equipped_weapon():
		return
	Signals.connect_choose_box_signal(self, "low_wx")
	Global.add_choose_text(get_parent(), Vector2(0, 0), "确定要使用1颗五行洗炼石洗炼法宝的五行吗？", 0)


func _on_gjwx_pressed() -> void:
	if not _has_equipped_weapon():
		return
	Signals.connect_choose_box_signal(self, "high_wx")
	var wx_num = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.FIVE_ELEMENTS].size() * 5
	Global.add_choose_text(get_parent(), Vector2(0, 0), "确定要使用" + str(wx_num) + "颗五行洗炼石高级洗炼一次法宝的五行吗？", 0)


func _on_czlxl_pressed() -> void:
	if not _has_equipped_weapon():
		return
	Signals.connect_choose_box_signal(self, "czl")
	Global.add_choose_text(get_parent(), Vector2(0, 0), "确定要使用1颗成长率洗炼石洗炼法宝的成长率吗？", 0)


func magic_weapon_czl(_name):
	if _name == "tjbg":
		return 3.0
	randomize()
	match _name:
		"zcld":
			return snapped(randf_range(0.5, 0.8), 0.1)
		"dshl":
			return snapped(randf_range(0.6, 1), 0.1)
		"dhqf":
			return snapped(randf_range(0.6, 1), 0.1)
		"tsgj":
			return snapped(randf_range(0.8, 1.4), 0.1)
		"jcld":
			return snapped(randf_range(1, 1.8), 0.1)
		"bsyj":
			return snapped(randf_range(0.8, 1.4), 0.1)
		"lsys":
			return snapped(randf_range(1, 1.6), 0.1)
		"xhmt":
			return snapped(randf_range(1.2, 1.8), 0.1)
		"xhhl":
			return snapped(randf_range(1.6, 2.2), 0.1)
		"kyl":
			return snapped(randf_range(1.4, 2), 0.1)
		"qyj":
			return snapped(randf_range(1.8, 2.4), 0.1)
		"zjfyd":
			return snapped(randf_range(2, 2.5), 0.1)
		"zjhl":
			return snapped(randf_range(2, 2.5), 0.1)
		"yjp":
			return snapped(randf_range(2, 2.6), 0.1)
		"zlwdah":
			return snapped(randf_range(2.2, 2.7), 0.1)
		"sqzlw":
			return 3.2
		"sqnmwdnh":
			return 3.2
		"nmwdnh":
			return snapped(randf_range(2.2, 2.7), 0.1)
		"dzyl":
			return snapped(randf_range(1.1, 2.3), 0.1)
		"469000004":
			return 6.8
		"469000011":
			return 7.2
		"yx":
			return snapped(randf_range(2.2, 2.7), 0.1)
		"qlsword":
			return snapped(randf_range(2.3, 2.7), 0.1)
		"yyzlj", "ywhl", "zhyx", "bjs", "sxyg", "dkhl", "yyb", "hehua":
			return 2.4
	if _name == "xianyjp":
		return 5.2
	return 0
