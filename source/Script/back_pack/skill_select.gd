extends Node2D

## 显式操作者：按所在面板的槽位解析数据与属性，不依赖全局 1P/2P 视图交换。
var PlayerData: PlayerDataStore:
	get:
		return LocalCoop.data_for(self) as PlayerDataStore
var RoleProp: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self) as BaseRoleProperties

@onready var skill_icon: Sprite2D = $BG/SkillIcon
@onready var wx_mu: Sprite2D = $BG/SkillIcon/MU
@onready var wp_name_label: Label = $BG/SkillIcon/Name_
@onready var skill_name: Label = $BG/SkillName
@onready var skill_level: Label = $BG/SkillName/Level
@onready var skill_infor: Label = $BG/Skill_Infor
@onready var choose_icon: Sprite2D = $BG/isChoose
@onready var choose_button = $BG/choose
@onready var no_have: Label = $BG/NoHave

const SKILL_INFO := {
	"tjbg":
	{
		"icon": "res://Art/magic_weapon/skill_icon/tjbg.png",
		"skill": "太极八卦",
		"desc": "6级解锁全场眩晕，消耗10魔法，冷却20秒。眩晕时间为法宝等级的一半，木属性翻倍。装备后每关可满血复活一次。"
	},
	"zcld": {"icon": "res://Art/magic_weapon/skill_icon/zcld.png", "skill": "招财进宝", "desc": "（被动技能）提升灵魂获取和掉宝率！随等级提高。"},
	"dshl":
	{"icon": "res://Art/magic_weapon/skill_icon/dshl.png", "skill": "烈焰火柱", "desc": "释放三道火柱，对范围内的敌人造成多段物理伤害（并令其灼烧）。"},
	"dhqf": {"icon": "res://Art/magic_weapon/skill_icon/dhqf.png", "skill": "士气鼓舞", "desc": "拥有【士气鼓舞】技能，回复少量血和蓝。"},
	"tsgj":
	{
		"icon": "res://Art/magic_weapon/skill_icon/wjgz.png",
		"skill": "万剑归宗",
		"desc": "召唤数把巨剑从天而降，造成多段魔法伤害（30%概率冰冻命中的目标）。"
	},
	"bsyj":
	{
		"icon": "res://Art/magic_weapon/skill_icon/bsyj.png",
		"skill": "邪灵寄生",
		"desc": "附身到怪物身上偷取生命并令其减速，一段时间后将偷取到的生命给予玩家。"
	},
	"lsys": {"icon": "res://Art/magic_weapon/skill_icon/lsys.png", "skill": "暴雨梨花", "desc": "散出漫天毒针，命中敌人后造成少量伤害并令其中毒。"},
	"xhmt":
	{"icon": "res://Art/magic_weapon/skill_icon/xhmt.png", "skill": "魔童连击", "desc": "清除低级负面效果，之后对目标进行多次打击，造成魔法伤害。"},
	"kyl": {"icon": "res://Art/magic_weapon/skill_icon/kyl.png", "skill": "沐露回春", "desc": "每秒为玩家恢复生命，期间免疫击退，持续10秒。"},
	"xhhl": {"icon": "res://Art/magic_weapon/skill_icon/xhhl.png", "skill": "万象天引", "desc": "将怪物吸引至玩家身边。"},
	"qyj":
	{"icon": "res://Art/magic_weapon/skill_icon/qyj.png", "skill": "戮天斩击", "desc": "释放剑阵，飞向当前生命最高的敌人，对受到伤害的目标施加破甲。"},
	"zjfyd":
	{
		"icon": "res://Art/magic_weapon/skill_icon/zjfyd.png",
		"skill": "不灭神盾",
		"desc": "拥有【不灭神盾】技能，使用后获得【不灭】Buff，一段时间内免疫高于当前生命的伤害。"
	},
	"zjhl":
	{
		"icon": "res://Art/magic_weapon/skill_icon/zjhl.png",
		"skill": "伏妖神火",
		"desc": "拥有【伏妖神火】技能，朝前方喷出火焰，造成物理伤害，并有10%概率施加一层灼烧。"
	},
	"wdsf":
	{"icon": "res://Art/magic_weapon/skill_icon/wds.png", "skill": "风卷毒澜", "desc": "拥有【风卷毒澜】技能，召唤持续增大的龙卷风，吸引敌人进入毒沼。"},
	"wdsh":
	{"icon": "res://Art/magic_weapon/skill_icon/wds.png", "skill": "烈焰焚爆", "desc": "拥有【烈焰焚爆】技能，持续喷射烈焰，灼烧并眩晕敌人。"},
	"wdst":
	{"icon": "res://Art/magic_weapon/skill_icon/wds.png", "skill": "地焚天星", "desc": "拥有【地焚天星】技能，召唤重山推开敌人，天星持续砸击。"},
	"wdsl":
	{
		"icon": "res://Art/magic_weapon/skill_icon/wds.png",
		"skill": "雷域玄盾",
		"desc": "拥有【雷域玄盾】技能，周身凝聚雷霆领域持续伤敌，同时生成护盾减免受到的伤害。"
	},
	"yjp": {"icon": "res://Art/magic_weapon/skill_icon/yjp.png", "skill": "伏妖神火", "desc": ""},
	"zlwdah": {"icon": "res://Art/magic_weapon/skill_icon/zlwdah.png", "skill": "召唤", "desc": "召唤转轮王一同作战。"},
	"sqzlw": {"icon": "res://Art/magic_weapon/skill_icon/zlwdah.png", "skill": "召唤", "desc": "召唤转轮王一同作战，属性为邪灵的2倍。"},
	"nmwdnh": {"icon": "res://Art/magic_weapon/skill_icon/nmwdnh.png", "skill": "召唤", "desc": "召唤牛魔王一同作战。"},
	"sqnmwdnh": {"icon": "res://Art/magic_weapon/skill_icon/nmwdnh.png", "skill": "召唤", "desc": "召唤牛魔王一同作战，属性为邪灵的2倍。"},
	"xianyjp":
	{"icon": "res://Art/magic_weapon/skill_icon/xianyjp.png", "skill": "召唤", "desc": "召唤观音助战。观音继承召唤时人物的全部属性。"},
	"yx":
	{"icon": "res://Art/magic_weapon/skill_icon/yx.png", "skill": "入魔", "desc": "扣除并失去一半生命值，攻击力与暴击率提高20%，持续一段时间。"},
	"qlsword": {"icon": "res://Art/magic_weapon/skill_icon/qlsword.png", "skill": "御剑飞行", "desc": "脚踏青龙剑，御剑飞行。"},
	"dzyl": {"icon": "res://Art/magic_weapon/skill_icon/dzyl.png", "skill": "护体圣莲", "desc": "减少受到的伤害并持续一段时间霸体。"},
	"469000004":
	{"icon": "res://Art/magic_weapon/skill_icon/469000004.png", "skill": "浩瀚雷音", "desc": "天锤敲击空气，对大范围怪物造成伤害并使其眩晕。"},
	"469000011":
	{
		"icon": "res://Art/magic_weapon/skill_icon/469000011.png",
		"skill": "御魔领域",
		"desc": "在原地创造隔绝所有伤害的空间，领域内怪物攻击无法命中，持续时间随法宝等级提升。"
	},
	"yyzlj": {"icon": "res://Art/magic_weapon/skill_icon/yyzlj.png", "skill": "阴阳斩龙剑", "desc": "召唤阴阳斩龙剑攻击敌人。"},
	"ywhl": {"icon": "res://Art/magic_weapon/skill_icon/ywhl.png", "skill": "药王葫芦", "desc": "使用后恢复生命值。"},
	"zhyx": {"icon": "res://Art/magic_weapon/skill_icon/zhyx.png", "skill": "镇魂玉箫", "desc": "吹奏玉箫，使敌人进入睡眠状态。"},
	"bjs": {"icon": "res://Art/magic_weapon/skill_icon/bjs.png", "skill": "玄风棕扇", "desc": "召唤玄风棕扇吹出强风攻击敌人。"},
	"sxyg": {"icon": "res://Art/magic_weapon/skill_icon/sxyg.png", "skill": "神行", "desc": "短时间提升移动速度。"},
	"dkhl": {"icon": "res://Art/magic_weapon/skill_icon/dkhl.png", "skill": "地魁花篮", "desc": "持续恢复生命和魔法。"},
	"yyb": {"icon": "res://Art/magic_weapon/skill_icon/yyb.png", "skill": "云阳板", "desc": "提升宠物战斗能力。"},
	"hehua": {"icon": "res://Art/magic_weapon/skill_icon/hehua.png", "skill": "慈心妙莲", "desc": "复活已阵亡的宠物。"},
}

var weapon_name: String = ""


func _ready() -> void:
	set_infor()


func _physics_process(_delta: float) -> void:
	check_i_schoose()


func set_infor() -> void:
	var info: Dictionary = SKILL_INFO.get(weapon_name, {})
	if info.is_empty():
		return
	skill_icon.texture = load(str(info["icon"]))
	wp_name_label.text = str(AE.all_equipment.get(weapon_name, {}).get(DataKeys.NAME, weapon_name))
	skill_name.text = str(info["skill"])
	skill_level.text = "Lv: " + str(PlayerData.get_most_level(weapon_name) + (1 if weapon_name == "tjbg" else 0))
	wx_mu.visible = PlayerData.check_have_wx(weapon_name, "木")
	skill_infor.text = str(info["desc"])


func check_i_schoose() -> void:
	if PlayerData.check_zb(weapon_name) != []:
		no_have.text = "已拥有"
		if PlayerData.player_data["实战法宝"] == weapon_name:
			choose_button.visible = false
			choose_button.disabled = true
			choose_icon.visible = true
		else:
			choose_button.visible = true
			choose_button.disabled = false
			choose_icon.visible = false
	else:
		no_have.text = "未拥有"
		choose_button.visible = true
		choose_button.disabled = true
		choose_icon.visible = false


func _on_choose_pressed() -> void:
	if Global.fb_cd <= 0:
		PlayerData.player_data["实战法宝"] = weapon_name
		MemoryClass.request_save("back_pack_magic_select")
	else:
		Global.add_message_show(get_parent().get_parent(), "当前法宝正在使用，无法更换！", 1.5, Vector2(0, 0))
