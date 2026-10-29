extends Node2D

## 显式操作者：按所在面板的槽位解析数据与属性，不依赖全局 1P/2P 视图交换。
var PlayerData: PlayerDataStore:
	get:
		return LocalCoop.data_for(self) as PlayerDataStore
var RoleProp: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self) as BaseRoleProperties

var need_name: String
@onready var label: Label = $BG/Label

var name_list = {
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
	"lys": "烈焰闪",
	"hytj": "火炎突击",
	"lyfb": "烈焰风暴",
	"qsez": "七十二斩",
	"zz": "重斩",
	"hmz": "火魔斩",
	"hmz_ws": "火魔斩无双",
	"hyjj_ws": "无双火眼金睛",
	"jdy": "筋斗云",
	"hyjj": "火眼金睛",
	"gsrs": "棍式如山",
	"blb": "冰龙波",
	"xbz": "玄冰阵",
	"shy": "水幻影",
	"tjgl": "天降甘露",
	"smb": "水魔爆",
	"myhc": "沐浴回春",
	"sgq": "圣光球",
	"jhsj": "九环圣经",
	"jgz": "紧箍咒",
	"by": "冰雨",
	"zfjg": "正法金刚",
	"ssp": "碎石破",
	"dj": "盾击",
	"jsp": "巨石破",
	"sd": "圣盾",
	"dgq": "地滚球",
	"xgq": "旋滚球",
	"syzq": "圣域之墙",
	"tmc": "土魔刺",
	"zznh": "战争怒吼",
	"bdqk": "拔地乾坤",
	"bylt": "碧落天",
	"cmly": "苍木龙陨",
	"qlj": "强力击",
	"dcj": "多重击",
	"wdzt": "万毒加护",
	"tkj": "腾空击",
	"mmw": "木魔舞",
	"jdz": "剧毒阵",
	"lhsq": "灵魂摄取",
	"zq": "瘴气",
	"wdww": "巫毒娃娃",
	"xyq": "心眼枪",
	"blq": "奔雷枪",
	"slq": "升龙枪",
	"cxq": "穿心枪",
	"fhf": "覆海翻",
	"ygth": "银钩铁画",
	"tllz": "天龙雷阵",
	"lljy": "雷龙极影",
	"llrd": "雷龙入地",
	"ltjz": "雷霆劫阵",
	"nz_jlsh": "九龙神火",
	"nz_fhcc": "风火冲刺",
	"nz_hlqg": "火轮切割",
	"nz_hlhs": "火莲化身",
	"nz_lblc": "六臂连刺",
	"nz_yysj": "阴阳神剑",
}


func _physics_process(delta: float) -> void:
	label.text = "设置技能 “" + str(name_list[need_name]) + "” 按键"


func _bind_key(key_name: String) -> void:
	if not PlayerData.set_skill_key(key_name, need_name):
		Global.add_message_show(self, "存档保存失败：" + MemoryClass.describe_save_error(), 2.0, Vector2(470, 270))
		return
	queue_free()


func _on_y_pressed() -> void:
	_bind_key("Y")


func _on_u_pressed() -> void:
	_bind_key("U")


func _on_i_pressed() -> void:
	_bind_key("I")


func _on_o_pressed() -> void:
	_bind_key("O")


func _on_l_pressed() -> void:
	_bind_key("L")


func _on_close_pressed() -> void:
	queue_free()
