extends Node
class_name PlayerDataStore

var RoleProp: BaseRoleProperties:
	get:
		var coop := get_node_or_null("/root/LocalCoop")
		return coop.props_for(self) if coop != null else get_node("/root/RoleProp")

const MOUNT_CATALOG := preload("res://Script/mount/mount_catalog.gd")
const DataKeys := preload("res://Script/base/data_keys.gd")
const SOUL_MIN: int = 0
const SOUL_MAX: int = 99999999999

var all_equipment = ["ryjgb", "xhmj", "xhxh"]
var _check_zb_elapsed: float = 0.0
var _invalid_data_exit_started := false
const PET_LIST_KEY := "宠物列表"
const ACTIVE_PET_KEY := "出战宠物"
const PET_BACKPACK_KEY := "宠物背包"
const PET_FORMATION_LEVELS_KEY := "宠物阵法等级"
const MOUNT_LIST_KEY := "坐骑列表"
const ACTIVE_MOUNT_KEY := "出战坐骑"
const MOUNT_RIDING_KEY := "坐骑骑乘中"
const MOUNT_AUTO_RIDE_KEY := "坐骑自动骑乘"
const MOUNT_UNLOCKED_KEY := "已解锁"
const AVATAR_FRAME_KEY := "头像框"
const PET_RABBIT_UNLOCK_KEY := "月兔已解锁"
const PET_EQUIPMENT_MAX_STRENGTH_LEVEL := 50
const STANDARD_STRENGTH_QUALITIES := ["普通", "优秀", "精良", "史诗", "邪灵", "魂器", "传说", "神器"]
const PET_EQUIPMENT_RANDOM_STAT_COUNT := 4
const PET_EQUIPMENT_RANDOM_STAT_KEY := "随机属性"
const PET_EQUIPMENT_TEMPLATE_STAT_KEYS := [
	"SHp",
	"SMp",
	"power",
	"Def",
	"Mdef",
	"Crit",
	"Miss",
	"R_hp",
	"R_mp",
	"htarget",
	"Lucky",
	"toughness",
	"ar",
	"sp",
	"vampirism",
	"CritReduce"
]
const PET_EQUIPMENT_STAT_KEYS := [
	"生命",
	"魔法",
	"攻击",
	"防御",
	"魔防",
	"暴击",
	"闪避",
	"幸运",
	"回血",
	"回魔",
	"命中",
	"破甲",
	"破魔",
	"韧性",
	"吸血",
	"暴免",
]
const PET_EQUIPMENT_STAT_ALIASES := {
	"生命": ["生命", "生命上限", "血量", "生命值", "SHp", "shp", "HP", "hp"],
	"魔法": ["魔法", "魔法上限", "魔力", "蓝量", "法力", "SMp", "smp", "MP", "mp"],
	"攻击": ["攻击", "攻击力", "power", "Power"],
	"防御": ["防御", "物防", "物理防御", "Def", "def"],
	"魔防": ["魔防", "魔抗", "法防", "魔法防御", "Mdef", "mdef"],
	"暴击": ["暴击", "暴击率", "Crit", "crit"],
	"闪避": ["闪避", "Miss", "miss"],
	"幸运": ["幸运", "Lucky", "lucky"],
	"回血": ["回血", "生命恢复", "生命回复", "R_hp", "r_hp"],
	"回魔": ["回魔", "魔法恢复", "魔法回复", "R_mp", "r_mp"],
	"命中": ["命中", "命中率", "htarget", "htarget"],
	"破甲": ["破甲", "护甲穿透", "物理穿透", "ar", "AR"],
	"破魔": ["破魔", "魔法穿透", "法术穿透", "sp", "SP"],
	"韧性": ["韧性", "toughness", "toughness"],
	"吸血": ["吸血", "vampirism", "Vampirism"],
	"暴免": ["暴免", "暴击抵抗", "暴击减免", "CritReduce", "critreduce"],
}
const PET_FORMATION_DEFAULT_LEVELS := {
	"生命": 0,
	"攻击": 0,
	"暴击": 0,
	"幸运": 0,
	"破甲": 0,
	"破魔": 0,
	"闪避": 0,
	"物防": 0,
	"魔防": 0,
}
const PET_FORMATION_STAT_GAINS := {
	"生命": 400,
	"攻击": 50,
	"暴击": 5,
	"幸运": 5,
	"破甲": 5,
	"破魔": 5,
	"闪避": 5,
	"物防": 25,
	"魔防": 25,
}
const MOUNT_LEVEL_EXP := [
	110,
	170,
	230,
	330,
	490,
	700,
	980,
	1300,
	1800,
	2300,
	3000,
	3900,
	5000,
	6300,
	7700,
	9400,
	11300,
	13500,
	15900,
	18600,
]
const MOUNT_TEMPLATES := {
	"1002200":
	{
		"名称": "西灵圣虎",
		"描述": "西灵圣虎",
		"类型": 1,
		"生命": 1599,
		"攻击": 63,
		"物防": 11,
		"魔防": 11,
		"暴击": 10,
		"命中": 0,
		"闪避": 0,
		"幸运": 0,
		"回血": 0,
		"破魔": 0,
		"疲劳上限": 2400,
		"骑乘消耗": 40,
		"休息恢复": 10,
		"生命资质": 760,
		"生命资质上限": 1020,
		"攻击资质": 900,
		"攻击资质上限": 1200,
		"防御资质": 760,
		"防御资质上限": 1020
	},
	"1002700":
	{
		"名称": "雪境神鹿",
		"描述": "雪境神鹿",
		"类型": 1,
		"生命": 1980,
		"攻击": 67,
		"物防": 12,
		"魔防": 12,
		"暴击": 0,
		"命中": 0,
		"闪避": 0,
		"幸运": 11,
		"回血": 0,
		"破魔": 5,
		"疲劳上限": 2400,
		"骑乘消耗": 40,
		"休息恢复": 10,
		"生命资质": 940,
		"生命资质上限": 1260,
		"攻击资质": 950,
		"攻击资质上限": 1270,
		"防御资质": 830,
		"防御资质上限": 1110
	},
	"1002800":
	{
		"名称": "沧澜飞鱼",
		"描述": "沧澜飞鱼",
		"类型": 2,
		"生命": 1980,
		"攻击": 66,
		"物防": 12,
		"魔防": 12,
		"暴击": 5,
		"命中": 5,
		"闪避": 0,
		"幸运": 0,
		"回血": 0,
		"破魔": 5,
		"疲劳上限": 2400,
		"骑乘消耗": 40,
		"休息恢复": 10,
		"生命资质": 940,
		"生命资质上限": 1260,
		"攻击资质": 940,
		"攻击资质上限": 1260,
		"防御资质": 840,
		"防御资质上限": 1120
	},
	"1003500":
	{
		"名称": "霓彩龙鱼",
		"描述": "霓彩龙鱼",
		"类型": 1,
		"生命": 1746,
		"攻击": 66,
		"物防": 11,
		"魔防": 11,
		"暴击": 5,
		"命中": 0,
		"闪避": 0,
		"幸运": 5,
		"回血": 0,
		"破魔": 0,
		"疲劳上限": 2400,
		"骑乘消耗": 40,
		"休息恢复": 10,
		"生命资质": 830,
		"生命资质上限": 1110,
		"攻击资质": 940,
		"攻击资质上限": 1260,
		"防御资质": 800,
		"防御资质上限": 1070
	},
	"1003600":
	{
		"名称": "东方苍龙",
		"描述": "东方苍龙",
		"类型": 2,
		"生命": 1836,
		"攻击": 60,
		"物防": 12,
		"魔防": 12,
		"暴击": 0,
		"命中": 0,
		"闪避": 0,
		"幸运": 0,
		"回血": 0,
		"破魔": 5,
		"疲劳上限": 2000,
		"骑乘消耗": 40,
		"休息恢复": 10,
		"生命资质": 870,
		"生命资质上限": 1170,
		"攻击资质": 860,
		"攻击资质上限": 1150,
		"防御资质": 840,
		"防御资质上限": 1120
	},
	"1003900":
	{
		"名称": "远古年兽",
		"描述": "远古年兽",
		"类型": 1,
		"生命": 1631,
		"攻击": 54,
		"物防": 11,
		"魔防": 11,
		"暴击": 5,
		"命中": 0,
		"闪避": 0,
		"幸运": 0,
		"回血": 15,
		"破魔": 0,
		"疲劳上限": 2400,
		"骑乘消耗": 40,
		"休息恢复": 10,
		"生命资质": 780,
		"生命资质上限": 1040,
		"攻击资质": 780,
		"攻击资质上限": 1040,
		"防御资质": 780,
		"防御资质上限": 1040
	},
	"1004700":
	{
		"名称": "雷辇嘲风",
		"描述": "雷辇嘲风",
		"类型": 1,
		"生命": 1980,
		"攻击": 71,
		"物防": 11,
		"魔防": 11,
		"暴击": 0,
		"命中": 0,
		"闪避": 0,
		"幸运": 11,
		"回血": 0,
		"破魔": 5,
		"疲劳上限": 2400,
		"骑乘消耗": 40,
		"休息恢复": 10,
		"生命资质": 940,
		"生命资质上限": 1260,
		"攻击资质": 1010,
		"攻击资质上限": 1350,
		"防御资质": 860,
		"防御资质上限": 1150
	},
}
const MOUNT_UNLOCK_REQUIREMENTS := {
	"1002200": {"物品": "139300016", "数量": 1},
	"1002700": {"物品": "139300018", "数量": 1},
	"1002800": {"物品": "139300017", "数量": 1},
	"1003500": {"物品": "139300014V1", "数量": 1},
	"1003600": {"物品": "139300012", "数量": 1},
	"1004700": {"物品": "139300021", "数量": 1},
}
const PLAYER_MAX_LEVEL := 350
const MOUNT_MAX_LEVEL := PLAYER_MAX_LEVEL
const MOUNT_SKILL_MAX_LEVEL := 20
const MOUNT_QUALIFICATION_MAX := 2050
const MOUNT_QUALIFICATION_KEYS := ["生命资质", "攻击资质", "防御资质"]
const MAIN_SWORD_ARRAY_KEY := "主线剑阵出战"
const MAIN_SWORD_ARRAY_LEVEL_KEY := "主线剑阵等级"
const MAIN_SWORD_ARRAY_DEFAULT := ""
const MAIN_SWORD_ARRAY_IDS := ["", "zhuxianjian", "xianxianjian", "sijianheyi", "luxianjian", "juexianjian"]
const MAIN_SWORD_ARRAY_LEVEL_DEFAULT := {
	"zhuxianjian": 0,
	"xianxianjian": 0,
	"luxianjian": 0,
	"juexianjian": 0,
}
const WANLING_CATALOG_LEVELS_KEY := "万灵图录等级"
const WANLING_HUMAN_CATEGORY := "人间"
const WANLING_UNDERWORLD_CATEGORY := "地府"
const WANLING_HEAVEN_CATEGORY := "天庭"
const WANLING_HUMAN_MONSTER_IDS := [
	1,
	2,
	3,
	4,
	5,
	6,
	7,
	8,
	9,
	10,
	11,
	12,
	13,
	14,
	15,
	16,
	17,
	18,
	20,
	21,
	22,
	23,
	24,
]
const WANLING_HUMAN_BOSS_IDS := [4, 5, 6, 8, 11, 12, 18, 20, 22, 23, 24]
const WANLING_UNDERWORLD_MONSTER_IDS := [
	26,
	27,
	28,
	29,
	30,
	31,
	32,
	33,
	37,
	39,
	40,
	41,
	43,
	48,
	49,
	51,
	52,
	53,
	54,
	55,
	56,
	57,
	58,
]
const WANLING_UNDERWORLD_BOSS_IDS := [29, 30, 31, 32, 33, 37, 41, 43, 48, 49, 55, 56, 57]
const WANLING_HEAVEN_MONSTER_IDS := [
	74,
	75,
	76,
	77,
	78,
	79,
	80,
	81,
	82,
	83,
	84,
	85,
	86,
	87,
	88,
	89,
	90,
	91,
	92,
	93,
	94,
	95,
	96,
	97,
	98,
	99,
	100,
	101,
	102,
	103,
	104,
	105,
	106,
	107,
	108,
	109,
	110,
	111,
	112,
	113,
	114,
	134,
	135,
	136,
	137,
]
const WANLING_HEAVEN_BOSS_IDS := [
	77,
	78,
	79,
	83,
	84,
	85,
	89,
	91,
	93,
	96,
	100,
	101,
	102,
	103,
	107,
	108,
	110,
	112,
	114,
	134,
	136,
	137,
]
const WANLING_SMALL_MONSTER_LIMIT := 1000
const WANLING_BOSS_LIMIT := 50
const WANLING_HUMAN_MONSTER_EFFECTS := {
	1: {"SHp": 50.0},
	2: {"SHp": 50.0},
	3: {"Mdef": 4.0},
	4: {"power": 100.0},
	5: {"power": 100.0},
	6: {"Crit": 20.0},
	7: {"ar": 3.0, "sp": 3.0},
	8: {"power": 100.0},
	9: {"SHp": 100.0},
	10: {"power": 10.0},
	11: {"damage_bonus": 0.002},
	12: {"damage_bonus": 0.002},
	13: {"R_hp": 0.2, "R_mp": 0.2},
	14: {"power": 5.0},
	15: {"power": 5.0},
	16: {"power": 5.0},
	17: {"Def": 4.0},
	18: {"damage_reduction": 0.002},
	20: {"damage_reduction": 0.002},
	21: {"SMp": 25.0},
	22: {"damage_bonus": 0.002},
	23: {"damage_reduction": 0.002},
	24: {"vampirism": 0.0001},
}
const WANLING_UNDERWORLD_MONSTER_EFFECTS := {
	26: {"SHp": 50.0},
	27: {"SHp": 50.0},
	28: {"Mdef": 4.0},
	29: {"power": 100.0},
	30: {"power": 100.0},
	31: {"Crit": 20.0},
	32: {"ar": 100.0, "sp": 100.0},
	33: {"power": 100.0, "SHp": 100.0},
	37: {"power": 100.0},
	39: {"power": 5.0},
	40: {"power": 5.0},
	41: {"power": 100.0},
	43: {"Def": 80.0},
	48: {"damage_reduction": 0.002},
	49: {"SMp": 200.0},
	51: {"damage_bonus": 0.0001},
	52: {"damage_reduction": 0.0001},
	53: {"SHp": 100.0},
	54: {"SHp": 50.0},
	55: {"damage_bonus": 0.002},
	56: {"damage_reduction": 0.002},
	57: {"damage_bonus": 0.002},
	58: {"R_hp": 0.2, "R_mp": 0.2},
}
const WANLING_HEAVEN_MONSTER_EFFECTS := {
	74: {"SHp": 50.0},
	75: {"SHp": 50.0},
	76: {"Mdef": 1.0},
	77: {"power": 100.0},
	78: {"power": 100.0},
	79: {"Crit": 20.0},
	80: {"power": 5.0},
	81: {"Def": 2.0},
	82: {"ar": 3.0, "sp": 3.0},
	83: {"damage_bonus": 0.0016},
	84: {"damage_reduction": 0.0015},
	85: {"Def": 40.0},
	86: {"SHp": 50.0},
	87: {"SHp": 50.0},
	88: {"SHp": 100.0},
	89: {"power": 100.0},
	90: {"Mdef": 1.0},
	91: {"damage_bonus": 0.0016},
	92: {"ar": 3.0, "sp": 3.0},
	93: {"damage_reduction": 0.0015},
	94: {"power": 5.0},
	95: {"power": 5.0},
	96: {"vampirism": 0.0001},
	97: {"Def": 2.0},
	98: {"power": 5.0},
	99: {"Mdef": 2.0},
	100: {"power": 100.0},
	101: {"damage_bonus": 0.0016},
	102: {"Crit": 20.0},
	103: {"damage_reduction": 0.0015},
	104: {"SHp": 50.0},
	105: {"Mdef": 2.0},
	106: {"R_hp": 0.2, "R_mp": 0.2},
	107: {"power": 100.0},
	108: {"SMp": 200.0},
	109: {"SHp": 100.0},
	110: {"damage_bonus": 0.0016},
	111: {"SHp": 100.0},
	112: {"SMp": 200.0},
	113: {"damage_reduction": 0.0001},
	114: {"damage_bonus": 0.0016, "damage_reduction": 0.0015},
	134: {"power": 100.0},
	135: {"SHp": 50.0},
	136: {"SHp": 1000.0},
	137: {"Crit": 20.0},
}
const PLAYER_PASSIVE_SKILL_KEYS := ["热血", "魔泉", "狂暴", "永恒", "辉煌", "敏锐", "收益"]
const CONSTELLATION_PROGRESS_KEY := "ConstellationHighestDefeatedTier"
const MAP5_PROGRESSION_LEVELS := [
	"绝仙门",
	"紫晶门",
	"戮仙门",
	"指景宫",
	"陷仙门",
	"绝境宫",
	"通天教主",
]
const PET_TIGER_PET := {
	"名称": "虎丸",
	"类型": "PetTiger",
	"阶段": 1,
	"等级": 1,
	"经验": 0,
	"下级经验": 100,
	"品质": "神兽",
	"生命": 620,
	"生命上限": 620,
	"魔法": 180,
	"魔法上限": 180,
	"攻击": 65,
	"防御": 60,
	"魔防": 60,
	"暴击": 12,
	"闪避": 6,
	"幸运": 10,
	"回血": 2,
	"回魔": 1,
	"悟性": 0,
	"根骨": 0,
	"灵力": 0,
	"生命资质": 1000,
	"生命资质上限": 2500,
	"魔法资质": 1000,
	"魔法资质上限": 1800,
	"攻击资质": 1000,
	"攻击资质上限": 2500,
	"防御资质": 1000,
	"防御资质上限": 1800,
	"潜力": 24,
	"潜力上限": 24,
	"强化点": 0,
	"普通培养次数": 0,
	"超级培养次数": 0,
	"放生": false,
	"被动技能": {"热血": 0, "魔泉": 0, "狂暴": 0, "永恒": 0, "辉煌": 0, "敏锐": 0},
	"技能": ["猛扑", "虎啸"],
	"装备": {"zbst": {}, "zbmz": {}, "zbxz": {}, "zbyf": {}, "zbjn": {}},
	"出战": false
}
var initialized_data: Dictionary = {
	"玩家等级": 1,
	"玩家当前经验": 0,
	"装备列表":
	{
		"页码1": [],
		"页码2": [],
		"页码3": [],
		"页码4": [],
		"页码5": [],
		"页码6": [],
		"页码7": [],
		"页码8": [],
		"页码9": [],
		"页码10": [],
		"页码11": [],
		"页码12": [],
		"页码13": [],
		"页码14": [],
		"页码15": [],
		"页码16": [],
		"页码17": [],
		"页码18": [],
		"页码19": [],
		"页码20": []
	},
	"道具列表":
	{
		"页码1": [],
		"页码2": [],
		"页码3": [],
		"页码4": [],
		"页码5": [],
		"页码6": [],
		"页码7": [],
		"页码8": [],
		"页码9": [],
		"页码10": [],
		"页码11": [],
		"页码12": [],
		"页码13": [],
		"页码14": [],
		"页码15": [],
		"页码16": [],
		"页码17": [],
		"页码18": [],
		"页码19": [],
		"页码20": []
	},
	"消耗品列表":
	{
		"页码1": [],
		"页码2": [],
		"页码3": [],
		"页码4": [],
		"页码5": [],
		"页码6": [],
		"页码7": [],
		"页码8": [],
		"页码9": [],
		"页码10": [],
		"页码11": [],
		"页码12": [],
		"页码13": [],
		"页码14": [],
		"页码15": [],
		"页码16": [],
		"页码17": [],
		"页码18": [],
		"页码19": [],
		"页码20": []
	},
	"幻化列表": {"武器": "", "防具": "", "时装": "", "翅膀": "", "头衔": ""},
	"实战法宝": "",
	"武器": [],
	"防具": [],
	"饰品": [],
	"神骨": [],
	"炼体": {"p1": {}, "p2": {}},
	"翅膀": [],
	"头衔": [],
	"头像框": [],
	"时装": [],
	"法宝": [],
	"点券": 0,
	"宠物列表":
	[
		{
			"名字": "灵猴",
			"等级": 1,
			"经验": 0,
			"经验上限": 100,
			"品质": "普通",
			"生命": 180,
			"生命上限": 180,
			"魔法": 90,
			"魔法上限": 90,
			"攻击": 28,
			"物防": 12,
			"魔防": 10,
			"暴击": 3,
			"闪避": 2,
			"幸运": 1,
			"回血": 1,
			"回魔": 1,
			"悟性": 0,
			"根骨": 0,
			"灵力": 0,
			"潜力": 12,
			"潜力上限": 12,
			"强化点": 0,
			"技能重置次数": 0,
			"属性重置次数": 0,
			"被动技能": {"热血": 0, "魔泉": 0, "狂暴": 0, "永恒": 0, "辉煌": 0, "敏锐": 0},
			"装备": {"zbst": {}, "zbmz": {}, "zbxz": {}, "zbyf": {}, "zbjn": {}},
			"背包": [],
			"出战": false
		}
	],
	"宠物背包": [],
	"宠物阵法等级": {"生命": 0, "攻击": 0, "暴击": 0, "幸运": 0, "破甲": 0, "破魔": 0, "闪避": 0, "物防": 0, "魔防": 0},
	"出战宠物": "",
	"月兔已解锁": false,
	"关卡评价":
	{
		"花果山": 0,
		"水帘洞": 0,
		"桃花源": 0,
		"蝙蝠窟": 0,
		"七星洞": 0,
		"迦楼罗之穴": 0,
		"浅岸": 0,
		"东海": 0,
		"鲨之涡流": 0,
		"牛魔谷": 0,
		"火焰山": 0,
		"鬼城": 0,
		"无常巷": 0,
		"鬼门关": 0,
		"接引院": 0,
		"判官府": 0,
		"阎罗殿": 0,
		"忘川河": 0,
		"奈何桥": 0,
		"望乡台": 0,
		"十八地狱": 0,
		"转轮殿": 0,
		"螺旋地狱": 0,
		"九重天": 0,
		"天宫道": 0,
		"南天门": 0,
		"南天王殿": 0,
		"西天王殿": 0,
		"北天王殿": 0,
		"彩虹楼": 0,
		"朝会殿": 0,
		"凌霄宝殿": 0,
		"玲珑宝塔": 0,
		"兜率宫": 0,
		"火龙岛": 0,
		"九龙岛": 0,
		"龙脊山": 0,
		"尾妖林": 0,
		"仙音岛": 0,
		"仙幻岛": 0,
		"仙树岛": 0,
		"蓬莱岛": 0,
		"蓬莱仙境": 0,
		"绝仙门": 0,
		"陷仙门": 0,
		"戮仙门": 0,
		"紫晶门": 0,
		"指景宫": 0,
		"绝境宫": 0,
		"通天教主": 0,
		"罹乱浩劫": 0
	},
	"幻化拥有列表": [],
	"已获取装备列表": [],
	"可进入天庭": false,
	"可进入截教": false,
	"可进入碧游宫": false,
	"玲珑宝塔层数": 0,
	"兜率宫层数": 0,
	"花果山": 1,
	"水帘洞": 0,
	"桃花源": 0,
	"蝙蝠窟": 0,
	"七星洞": 0,
	"迦楼罗之穴": 0,
	"浅岸": 0,
	"东海": 0,
	"鲨之涡流": 0,
	"牛魔谷": 0,
	"zyforever": false,
	"地府": false,
	"地府噩梦": false,
	"天庭": false,
	"截教天镜": false,
	"碧游宫": false,
	"Map_num": 1,
	"HeavenMap_num": 3,
	"Map_variant": "",
	"鬼城": 1,
	"无常巷": 0,
	"鬼门关": 0,
	"接引院": 0,
	"判官府": 0,
	"阎罗殿": 0,
	"忘川河": 0,
	"奈何桥": 0,
	"望乡台": 0,
	"十八地狱": 0,
	"转轮殿": 0,
	"九重天": 0,
	"天宫道": 0,
	"南天门": 0,
	"南天王殿": 0,
	"西天王殿": 0,
	"北天王殿": 0,
	"彩虹楼": 0,
	"朝会殿": 0,
	"凌霄宝殿": 0,
	"玲珑宝塔": 0,
	"兜率宫": 0,
	"兜率宫1": 0,
	"兜率宫2": 0,
	"兜率宫3": 0,
	"兜率宫4": 0,
	"兜率宫5": 0,
	"神兽森林": 0,
	"火龙岛": 0,
	"九龙岛": 0,
	"龙脊山": 0,
	"尾妖林": 0,
	"仙音岛": 0,
	"仙幻岛": 0,
	"仙树岛": 0,
	"蓬莱岛": 0,
	"蓬莱仙境": 0,
	"coin_num": 0,
	"放入列表": {"物品1": [], "物品2": [], "物品3": []},
	"镶嵌列表": [],
	"分解列表": [],
	"Myself": 0,
	"购买次数": 0,
	"镇妖塔成就商店觉醒石已购次数": 0,
	"技能学习":
	{
		"技能1": {"学习": 0, "等级": 0},
		"技能2": {"学习": 0, "等级": 0},
		"技能3": {"学习": 0, "等级": 0},
		"技能4": {"学习": 0, "等级": 0},
		"技能5": {"学习": 0, "等级": 0},
		"技能6": {"学习": 0, "等级": 0},
		"技能7": {"学习": 0, "等级": 0},
		"技能8": {"学习": 0, "等级": 0},
		"技能9": {"学习": 0, "等级": 0},
		"技能10": {"学习": 0, "等级": 0},
		"技能11": {"学习": 0, "等级": 0},
		"技能12": {"学习": 0, "等级": 0},
		"技能13": {"学习": 0, "等级": 0},
		"技能键位": {"Y": "", "U": "", "I": "", "O": "", "L": ""}
	},
	"被动技能": {"热血": 0, "魔泉": 0, "狂暴": 0, "永恒": 0, "辉煌": 0, "敏锐": 0, "收益": 0},
	"翅膀显示": true,
	"头衔显示": true,
	"时装显示": true,
	"zubi": false,
	"截教": false,
	"新的旅途": false,
	"至尊骨养成一": false,
	"七魔尽伏": false,
	"十殿肃清": false,
	"成长礼包1": false,
	"成长礼包2": false,
	"成长礼包3": false,
	"成长礼包4": false,
	"天庭之证": false,
	"小有所藏": false,
	"业余收藏家": false,
	"专业收藏家": false,
	"痴迷收藏家": false,
	"强迫症收藏家": false,
	"骨灰级收藏家": false,
	"行走博物馆": false,
	"勇闯八荒": false,
	"初始Buff": [],
	"ieho": false,
	"猕猴王": 0,
	"水帘洞天": false,
	"禺狨王": 0,
	"桃花深谷": false,
	"蝙蝠石像": 0,
	"身陷蝙蝠窟": false,
	"狮驼王": 0,
	"密探七星洞": false,
	"鹏魔王": 0,
	"金翅大鹏": false,
	"龟丞相": 0,
	"东海浅岸": false,
	"蛟魔王": 0,
	"东海龙宫": false,
	"鲨魔王": 0,
	"嗜血鲨鱼涡流": false,
	"牛魔王·鬼": 0,
	"决战平天大圣": false,
	"魔·红孩儿": 0,
	"炽焰火焰山": false,
	"守夜人": 0,
	"诡异城镇": false,
	"黑无常": 0,
	"白无常": 0,
	"阴魂巷": false,
	"傀儡王": 0,
	"诡异石像": false,
	"秦广王": 0,
	"一殿阎罗": false,
	"判官": 0,
	"末日审判": false,
	"阎罗王": 0,
	"冥府阎罗殿": false,
	"宋帝王": 0,
	"凶险冥河": false,
	"夜叉": 0,
	"三生惘然": false,
	"孟婆": 0,
	"永别思乡岭": false,
	"转轮·真法": 0,
	"浩瀚星河": false,
	"刑天": 0,
	"十八层地狱": false,
	"楚江王": 0,
	"活大地狱": false,
	"龙王·低": 0,
	"龙王·高": 0,
	"水晶宫1": false,
	"水晶宫2": false,
	"白骨精·精": 0,
	"白骨精·妖": 0,
	"白骨精·魔": 0,
	"三打白骨精1": false,
	"三打白骨精2": false,
	"沙华": 0,
	"曼珠": 0,
	"彼岸双生": false,
	"青蛇": 0,
	"冥河蛇妖": false,
	"河童": 0,
	"诡异河童": false,
	"战神刑天": 0,
	"不灭战神": false,
	"无首神": false,
	"生命丹1": 0,
	"生命丹2": 0,
	"生命丹3": 0,
	"生命丹4": 0,
	"生命丹5": 0,
	"魔法丹1": 0,
	"魔法丹2": 0,
	"魔法丹3": 0,
	"魔法丹4": 0,
	"魔法丹5": 0,
	"攻击丹1": 0,
	"攻击丹2": 0,
	"攻击丹3": 0,
	"攻击丹4": 0,
	"攻击丹5": 0,
	"暴击丹1": 0,
	"暴击丹2": 0,
	"暴击丹3": 0,
	"暴击丹4": 0,
	"暴击丹5": 0,
	"幸运丹1": 0,
	"幸运丹2": 0,
	"幸运丹3": 0,
	"幸运丹4": 0,
	"幸运丹5": 0,
	"回魔丹1": 0,
	"回魔丹2": 0,
	"回魔丹3": 0,
	"回魔丹4": 0,
	"回魔丹5": 0,
	"特殊Buff": [],
	"宝珠列表": [],
	"MyTime": {},
	"MyId": 0,
	"已佩戴阵法": "",
	"主线剑阵出战": "",
	"主线剑阵等级": {"zhuxianjian": 0, "xianxianjian": 0, "luxianjian": 0, "juexianjian": 0},
	"拥有阵法": {},
	"落魄阵":
	{
		"1": {"Name": "幽", "Level": 0, "InName": "lpzyou"},
		"2": {"Name": "冥", "Level": 0, "InName": "lpzming"},
		"3": {"Name": "鬼", "Level": 0, "InName": "lpzgui"},
		"Level": 0
	},
	"森罗阵":
	{
		"1": {"Name": "天", "Level": 0, "InName": "lslztian"},
		"2": {"Name": "地", "Level": 0, "InName": "lslzdi"},
		"3": {"Name": "人", "Level": 0, "InName": "ren"},
		"Level": 0
	},
	"腾蛇阵":
	{
		"1": {"Name": "天枢", "Level": 0, "InName": "tsztianshu"},
		"2": {"Name": "天璇", "Level": 0, "InName": "tsztianxuan"},
		"3": {"Name": "天玑", "Level": 0, "InName": "tsztianji"},
		"4": {"Name": "天权", "Level": 0, "InName": "tsztianquan"},
		"Level": 0
	},
	"太清阵":
	{
		"1": {"Name": "青龙", "Level": 0, "InName": "tqzqinglong"},
		"2": {"Name": "白虎", "Level": 0, "InName": "tqzbaihu"},
		"3": {"Name": "朱雀", "Level": 0, "InName": "tqzzhuque"},
		"4": {"Name": "玄武", "Level": 0, "InName": "tqzxuanwu"},
		"Level": 0
	},
	"FileValue": 1.0,
	"FristJiejiao": true
}
var player_data: Dictionary = {
	"宠物背包": [],
	"宠物阵法等级": {"生命": 0, "攻击": 0, "暴击": 0, "幸运": 0, "破甲": 0, "破魔": 0, "闪避": 0, "物防": 0, "魔防": 0},
	"玩家等级": 1,
	"玩家当前经验": 0,
	"装备列表":
	{
		"页码1": [],
		"页码2": [],
		"页码3": [],
		"页码4": [],
		"页码5": [],
		"页码6": [],
		"页码7": [],
		"页码8": [],
		"页码9": [],
		"页码10": [],
		"页码11": [],
		"页码12": [],
		"页码13": [],
		"页码14": [],
		"页码15": [],
		"页码16": [],
		"页码17": [],
		"页码18": [],
		"页码19": [],
		"页码20": []
	},
	"道具列表":
	{
		"页码1": [],
		"页码2": [],
		"页码3": [],
		"页码4": [],
		"页码5": [],
		"页码6": [],
		"页码7": [],
		"页码8": [],
		"页码9": [],
		"页码10": [],
		"页码11": [],
		"页码12": [],
		"页码13": [],
		"页码14": [],
		"页码15": [],
		"页码16": [],
		"页码17": [],
		"页码18": [],
		"页码19": [],
		"页码20": []
	},
	"消耗品列表":
	{
		"页码1": [],
		"页码2": [],
		"页码3": [],
		"页码4": [],
		"页码5": [],
		"页码6": [],
		"页码7": [],
		"页码8": [],
		"页码9": [],
		"页码10": [],
		"页码11": [],
		"页码12": [],
		"页码13": [],
		"页码14": [],
		"页码15": [],
		"页码16": [],
		"页码17": [],
		"页码18": [],
		"页码19": [],
		"页码20": []
	},
	"幻化列表": {"武器": "", "防具": "", "时装": "", "翅膀": "", "头衔": ""},
	"实战法宝": "",
	"武器": [],
	"防具": [],
	"饰品": [],
	"神骨": [],
	"炼体": {"p1": {}, "p2": {}},
	"翅膀": [],
	"头衔": [],
	"头像框": [],
	"时装": [],
	"法宝": [],
	"点券": 0,
	"宠物列表":
	[
		{
			"名字": "灵猴",
			"等级": 1,
			"经验": 0,
			"经验上限": 100,
			"品质": "普通",
			"生命": 180,
			"生命上限": 180,
			"魔法": 90,
			"魔法上限": 90,
			"攻击": 28,
			"物防": 12,
			"魔防": 10,
			"暴击": 3,
			"闪避": 2,
			"幸运": 1,
			"回血": 1,
			"回魔": 1,
			"悟性": 0,
			"根骨": 0,
			"灵力": 0,
			"潜力": 12,
			"潜力上限": 12,
			"强化点": 0,
			"技能重置次数": 0,
			"属性重置次数": 0,
			"被动技能": {"热血": 0, "魔泉": 0, "狂暴": 0, "永恒": 0, "辉煌": 0, "敏锐": 0},
			"装备": {"zbst": {}, "zbmz": {}, "zbxz": {}, "zbyf": {}, "zbjn": {}},
			"背包": [],
			"出战": false
		}
	],
	"出战宠物": "",
	"月兔已解锁": false,
	"关卡评价":
	{
		"花果山": 0,
		"水帘洞": 0,
		"桃花源": 0,
		"蝙蝠窟": 0,
		"七星洞": 0,
		"迦楼罗之穴": 0,
		"浅岸": 0,
		"东海": 0,
		"鲨之涡流": 0,
		"牛魔谷": 0,
		"火焰山": 0,
		"鬼城": 0,
		"无常巷": 0,
		"鬼门关": 0,
		"接引院": 0,
		"判官府": 0,
		"阎罗殿": 0,
		"忘川河": 0,
		"奈何桥": 0,
		"望乡台": 0,
		"十八地狱": 0,
		"转轮殿": 0,
		"螺旋地狱": 0,
		"九重天": 0,
		"天宫道": 0,
		"南天门": 0,
		"南天王殿": 0,
		"西天王殿": 0,
		"北天王殿": 0,
		"彩虹楼": 0,
		"朝会殿": 0,
		"凌霄宝殿": 0,
		"玲珑宝塔": 0,
		"兜率宫": 0,
		"火龙岛": 0,
		"九龙岛": 0,
		"龙脊山": 0,
		"尾妖林": 0,
		"仙音岛": 0,
		"仙幻岛": 0,
		"仙树岛": 0,
		"蓬莱岛": 0,
		"蓬莱仙境": 0,
		"绝仙门": 0,
		"陷仙门": 0,
		"戮仙门": 0,
		"紫晶门": 0,
		"指景宫": 0,
		"绝境宫": 0,
		"通天教主": 0,
		"罹乱浩劫": 0
	},
	"幻化拥有列表": [],
	"已获取装备列表": [],
	"可进入天庭": false,
	"可进入截教": false,
	"可进入碧游宫": false,
	"玲珑宝塔层数": 0,
	"兜率宫层数": 0,
	"花果山": 1,
	"水帘洞": 0,
	"桃花源": 0,
	"蝙蝠窟": 0,
	"七星洞": 0,
	"迦楼罗之穴": 0,
	"浅岸": 0,
	"东海": 0,
	"鲨之涡流": 0,
	"牛魔谷": 0,
	"zyforever": false,
	"地府": false,
	"地府噩梦": false,
	"天庭": false,
	"截教天镜": false,
	"碧游宫": false,
	"Map_num": 1,
	"HeavenMap_num": 3,
	"Map_variant": "",
	"鬼城": 1,
	"无常巷": 0,
	"鬼门关": 0,
	"接引院": 0,
	"判官府": 0,
	"阎罗殿": 0,
	"忘川河": 0,
	"奈何桥": 0,
	"望乡台": 0,
	"十八地狱": 0,
	"转轮殿": 0,
	"九重天": 0,
	"天宫道": 0,
	"南天门": 0,
	"南天王殿": 0,
	"西天王殿": 0,
	"北天王殿": 0,
	"彩虹楼": 0,
	"朝会殿": 0,
	"凌霄宝殿": 0,
	"玲珑宝塔": 0,
	"兜率宫": 0,
	"兜率宫1": 0,
	"兜率宫2": 0,
	"兜率宫3": 0,
	"兜率宫4": 0,
	"兜率宫5": 0,
	"神兽森林": 0,
	"火龙岛": 0,
	"九龙岛": 0,
	"龙脊山": 0,
	"尾妖林": 0,
	"仙音岛": 0,
	"仙幻岛": 0,
	"仙树岛": 0,
	"蓬莱岛": 0,
	"蓬莱仙境": 0,
	"coin_num": 0,
	"放入列表": {"物品1": [], "物品2": [], "物品3": []},
	"镶嵌列表": [],
	"分解列表": [],
	"Myself": 0,
	"购买次数": 0,
	"镇妖塔成就商店觉醒石已购次数": 0,
	"技能学习":
	{
		"技能1": {"学习": 0, "等级": 0},
		"技能2": {"学习": 0, "等级": 0},
		"技能3": {"学习": 0, "等级": 0},
		"技能4": {"学习": 0, "等级": 0},
		"技能5": {"学习": 0, "等级": 0},
		"技能6": {"学习": 0, "等级": 0},
		"技能7": {"学习": 0, "等级": 0},
		"技能8": {"学习": 0, "等级": 0},
		"技能9": {"学习": 0, "等级": 0},
		"技能10": {"学习": 0, "等级": 0},
		"技能11": {"学习": 0, "等级": 0},
		"技能12": {"学习": 0, "等级": 0},
		"技能13": {"学习": 0, "等级": 0},
		"技能键位": {"Y": "", "U": "", "I": "", "O": "", "L": ""}
	},
	"被动技能": {"热血": 0, "魔泉": 0, "狂暴": 0, "永恒": 0, "辉煌": 0, "敏锐": 0, "收益": 0},
	"翅膀显示": true,
	"头衔显示": true,
	"时装显示": true,
	"zubi": false,
	"截教": false,
	"新的旅途": false,
	"至尊骨养成一": false,
	"七魔尽伏": false,
	"十殿肃清": false,
	"成长礼包1": false,
	"成长礼包2": false,
	"成长礼包3": false,
	"成长礼包4": false,
	"天庭之证": false,
	"小有所藏": false,
	"业余收藏家": false,
	"专业收藏家": false,
	"痴迷收藏家": false,
	"强迫症收藏家": false,
	"骨灰级收藏家": false,
	"行走博物馆": false,
	"勇闯八荒": false,
	"初始Buff": [],
	"ieho": false,
	"猕猴王": 0,
	"水帘洞天": false,
	"禺狨王": 0,
	"桃花深谷": false,
	"蝙蝠石像": 0,
	"身陷蝙蝠窟": false,
	"狮驼王": 0,
	"密探七星洞": false,
	"鹏魔王": 0,
	"金翅大鹏": false,
	"龟丞相": 0,
	"东海浅岸": false,
	"蛟魔王": 0,
	"东海龙宫": false,
	"鲨魔王": 0,
	"嗜血鲨鱼涡流": false,
	"牛魔王·鬼": 0,
	"决战平天大圣": false,
	"魔·红孩儿": 0,
	"炽焰火焰山": false,
	"守夜人": 0,
	"诡异城镇": false,
	"黑无常": 0,
	"白无常": 0,
	"阴魂巷": false,
	"傀儡王": 0,
	"诡异石像": false,
	"秦广王": 0,
	"一殿阎罗": false,
	"判官": 0,
	"末日审判": false,
	"阎罗王": 0,
	"冥府阎罗殿": false,
	"宋帝王": 0,
	"凶险冥河": false,
	"夜叉": 0,
	"三生惘然": false,
	"孟婆": 0,
	"永别思乡岭": false,
	"转轮·真法": 0,
	"浩瀚星河": false,
	"刑天": 0,
	"十八层地狱": false,
	"楚江王": 0,
	"活大地狱": false,
	"龙王·低": 0,
	"龙王·高": 0,
	"水晶宫1": false,
	"水晶宫2": false,
	"白骨精·精": 0,
	"白骨精·妖": 0,
	"白骨精·魔": 0,
	"三打白骨精1": false,
	"三打白骨精2": false,
	"沙华": 0,
	"曼珠": 0,
	"彼岸双生": false,
	"青蛇": 0,
	"冥河蛇妖": false,
	"河童": 0,
	"诡异河童": false,
	"战神刑天": 0,
	"不灭战神": false,
	"无首神": false,
	"生命丹1": 0,
	"生命丹2": 0,
	"生命丹3": 0,
	"生命丹4": 0,
	"生命丹5": 0,
	"魔法丹1": 0,
	"魔法丹2": 0,
	"魔法丹3": 0,
	"魔法丹4": 0,
	"魔法丹5": 0,
	"攻击丹1": 0,
	"攻击丹2": 0,
	"攻击丹3": 0,
	"攻击丹4": 0,
	"攻击丹5": 0,
	"暴击丹1": 0,
	"暴击丹2": 0,
	"暴击丹3": 0,
	"暴击丹4": 0,
	"暴击丹5": 0,
	"幸运丹1": 0,
	"幸运丹2": 0,
	"幸运丹3": 0,
	"幸运丹4": 0,
	"幸运丹5": 0,
	"回魔丹1": 0,
	"回魔丹2": 0,
	"回魔丹3": 0,
	"回魔丹4": 0,
	"回魔丹5": 0,
	"特殊Buff": [],
	"宝珠列表": [],
	"MyTime": {},
	"MyId": 0,
	"已佩戴阵法": "",
	"主线剑阵出战": "",
	"主线剑阵等级": {"zhuxianjian": 0, "xianxianjian": 0, "luxianjian": 0, "juexianjian": 0},
	"拥有阵法": {},
	"落魄阵":
	{
		"1": {"Name": "幽", "Level": 0, "InName": "lpzyou"},
		"2": {"Name": "冥", "Level": 0, "InName": "lpzming"},
		"3": {"Name": "鬼", "Level": 0, "InName": "lpzgui"},
		"Level": 0
	},
	"森罗阵":
	{
		"1": {"Name": "天", "Level": 0, "InName": "lslztian"},
		"2": {"Name": "地", "Level": 0, "InName": "lslzdi"},
		"3": {"Name": "人", "Level": 0, "InName": "ren"},
		"Level": 0
	},
	"腾蛇阵":
	{
		"1": {"Name": "天枢", "Level": 0, "InName": "tsztianshu"},
		"2": {"Name": "天璇", "Level": 0, "InName": "tsztianxuan"},
		"3": {"Name": "天玑", "Level": 0, "InName": "tsztianji"},
		"4": {"Name": "天权", "Level": 0, "InName": "tsztianquan"},
		"Level": 0
	},
	"太清阵":
	{
		"1": {"Name": "青龙", "Level": 0, "InName": "tqzqinglong"},
		"2": {"Name": "白虎", "Level": 0, "InName": "tqzbaihu"},
		"3": {"Name": "朱雀", "Level": 0, "InName": "tqzzhuque"},
		"4": {"Name": "玄武", "Level": 0, "InName": "tqzxuanwu"},
		"Level": 0
	},
	"FileValue": 1.0,
	"FristJiejiao": true
}

const RETIRED_WUDU_MAGIC_WEAPONS := ["wdsf", "wdsh", "wdst", "wdsl"]
const RETIRED_XIANYU_EQUIPMENT_MAP := {
	"wkxysz": "xyfjwk",
	"bjxysz": "xyfjbj",
	"blxyfj": "xyfjbl",
}


func normalize_soul() -> int:
	var coop := get_node_or_null("/root/LocalCoop")
	if coop != null and coop.shares_soul_with(self):
		return coop.normalize_shared_soul()
	var value: Variant = player_data.get("coin_num", SOUL_MIN)
	var normalized: int = clampi(int(value), SOUL_MIN, SOUL_MAX)
	player_data["coin_num"] = normalized
	return normalized


func get_soul() -> int:
	return normalize_soul()


func set_soul(value: int) -> int:
	var coop := get_node_or_null("/root/LocalCoop")
	if coop != null and coop.shares_soul_with(self):
		return coop.set_shared_soul(value)
	player_data["coin_num"] = clampi(value, SOUL_MIN, SOUL_MAX)
	return int(player_data["coin_num"])


func add_soul(value: int) -> int:
	if value <= 0:
		return get_soul()
	var current: int = get_soul()
	return set_soul(SOUL_MAX if value >= SOUL_MAX - current else current + value)


func spend_soul(value: int) -> bool:
	if value < 0 or get_soul() < value:
		return false
	set_soul(get_soul() - value)
	return true


const RETIRED_XIANYU_REMOVE_IDS := ["wkxyszg", "bjxyszp", "blxywq"]
const RETIRED_CLASSIC_ORIGINAL_EQUIPMENT := [
	"wkjdyhwq",
	"wkjdyhyf",
	"tsjdyhwq",
	"tsjdyhyf",
	"bjjdyhwq",
	"bjjdyhyf",
	"ssjdyhwq",
	"ssjdyhyf",
	"bljdyhwq",
	"bljdyhyf"
]
const RETIRED_MERCHANT_FASHION_QUALITIES := [
	"putongsmsrsz", "youxiusmsrsz", "jingliangsmsrsz", "shishismsrsz", "xielingsmsrsz", "hunqismsrsz", "chuanshuosmsrsz"
]
const PET_DRAGON_STAGE_SKILLS := {
	1: ["分身"], 2: ["分身", "闪电冲刺"], 3: ["分身", "闪电冲刺", "雷霆万钧"], 4: ["分身", "闪电冲刺", "雷霆万钧", "青龙奥义"]
}
const PET_DRAGON_STAGE_NAMES := {1: "龙仔", 2: "绿英龙", 3: "青龙将军", 4: "青龙妖圣"}
const PET_TURTLE_STAGE_SKILLS := {
	1: ["水疗盾"], 2: ["水疗盾", "同心链接"], 3: ["水疗盾", "同心链接", "水湮八荒"], 4: ["水疗盾", "同心链接", "水湮八荒", "玄武奥义"]
}
const PET_TURTLE_STAGE_NAMES := {1: "龟布", 2: "墨玄龟", 3: "玄武将军", 4: "玄武大帝"}
const PET_RABBIT_STAGE_SKILLS := {1: ["月光"], 2: ["月光", "疾风"], 3: ["月光", "疾风", "冰陨"], 4: ["月光", "疾风", "冰陨", "月神奥义"]}
const PET_RABBIT_STAGE_NAMES := {1: "月兔", 2: "疾风兔", 3: "寒冰玉兔", 4: "冰霜月神"}
const PET_MOUSE_LEVEL_SKILLS := {1: ["鼠窜"], 30: ["鼠窜", "回旋飞镖"], 50: ["鼠窜", "回旋飞镖", "子鼠奥义"]}
const PET_MOUSE_STAGE_NAMES := {1: "子鼠元帅", 2: "子鼠大元帅"}
const PET_NEAT_STAGE_SKILLS := {1: ["蛮牛冲撞"], 2: ["蛮牛冲撞"], 3: ["蛮牛冲撞"], 4: ["蛮牛冲撞", "蛮力践踏", "丑牛奥义"]}
const PET_NEAT_STAGE_NAMES := {1: "丑牛元帅", 2: "丑牛元帅", 3: "丑牛元帅", 4: "丑牛大元帅"}
const PET_YIN_TIGER_STAGE_SKILLS := {1: ["虎啸"], 2: ["虎啸"], 3: ["虎啸"], 4: ["虎啸", "猛虎下山", "寅虎奥义"]}
const PET_YIN_TIGER_STAGE_NAMES := {1: "寅虎元帅", 2: "寅虎元帅", 3: "寅虎元帅", 4: "寅虎大元帅"}

const PET_PHOENIX_STAGE_SKILLS := {
	1: ["涅槃"], 2: ["涅槃", "不死火鸟"], 3: ["涅槃", "不死火鸟", "地火燎原"], 4: ["涅槃", "不死火鸟", "地火燎原", "朱雀奥义"]
}
const PET_PHOENIX_STAGE_NAMES := {1: "雀蛋", 2: "炎皇雀", 3: "朱雀将军", 4: "朱雀女皇"}

const PET_PHOENIX_PET := {
	"名称": "雀蛋",
	"类型": "PetPhoenix",
	"阶段": 1,
	"等级": 1,
	"经验": 0,
	"下级经验": 100,
	"品质": "神兽",
	"生命": 640,
	"生命上限": 640,
	"魔法": 220,
	"魔法上限": 220,
	"攻击": 70,
	"防御": 60,
	"物防": 60,
	"魔防": 62,
	"暴击": 12,
	"闪避": 6,
	"幸运": 10,
	"回血": 2,
	"回魔": 1,
	"悟性": 0,
	"根骨": 0,
	"灵力": 0,
	"生命资质": 1000,
	"生命资质上限": 2500,
	"生命资质基础上限": 2500,
	"魔法资质": 1000,
	"魔法资质上限": 1800,
	"魔法资质基础上限": 1800,
	"攻击资质": 1000,
	"攻击资质上限": 3000,
	"攻击资质基础上限": 3000,
	"防御资质": 1000,
	"防御资质上限": 1800,
	"防御资质基础上限": 1800,
	"潜力": 24,
	"潜力上限": 24,
	"强化点": 0,
	"普通培养次数": 0,
	"超级培养次数": 0,
	"放生": false,
	"被动技能": {"热血": 0, "魔泉": 0, "狂暴": 0, "永恒": 0, "辉煌": 0, "敏锐": 0},
	"技能": ["涅槃"],
	"装备": {"zbst": {}, "zbmz": {}, "zbxz": {}, "zbyf": {}, "zbjn": {}},
	"出战": false
}
const PET_DRAGON_PET := {
	"名称": "龙仔",
	"类型": "PetDragon",
	"阶段": 1,
	"等级": 1,
	"经验": 0,
	"下级经验": 100,
	"品质": "神兽",
	"生命": 660,
	"生命上限": 660,
	"魔法": 200,
	"魔法上限": 200,
	"攻击": 68,
	"防御": 62,
	"魔防": 62,
	"暴击": 12,
	"闪避": 6,
	"幸运": 10,
	"回血": 2,
	"回魔": 1,
	"悟性": 0,
	"根骨": 0,
	"灵力": 0,
	"生命资质": 1000,
	"生命资质上限": 2500,
	"生命资质基础上限": 2500,
	"魔法资质": 1000,
	"魔法资质上限": 1800,
	"魔法资质基础上限": 1800,
	"攻击资质": 1000,
	"攻击资质上限": 3000,
	"攻击资质基础上限": 3000,
	"防御资质": 1000,
	"防御资质上限": 1800,
	"防御资质基础上限": 1800,
	"潜力": 24,
	"潜力上限": 24,
	"强化点": 0,
	"普通培养次数": 0,
	"超级培养次数": 0,
	"放生": false,
	"被动技能": {"热血": 0, "魔泉": 0, "狂暴": 0, "永恒": 0, "辉煌": 0, "敏锐": 0},
	"技能": ["分身"],
	"装备": {"zbst": {}, "zbmz": {}, "zbxz": {}, "zbyf": {}, "zbjn": {}},
	"出战": false
}
const PET_TURTLE_PET := {
	"名称": "龟布",
	"名字": "龟布",
	"类型": "PetTurtle",
	"阶段": 1,
	"等级": 1,
	"经验": 0,
	"下级经验": 100,
	"品质": "神兽",
	"生命": 620,
	"生命上限": 620,
	"魔法": 180,
	"魔法上限": 180,
	"攻击": 65,
	"防御": 60,
	"物防": 60,
	"魔防": 60,
	"暴击": 12,
	"闪避": 6,
	"幸运": 10,
	"回血": 2,
	"回魔": 1,
	"悟性": 0,
	"根骨": 0,
	"灵力": 0,
	"生命资质": 1000,
	"生命资质上限": 4000,
	"生命资质基础上限": 4000,
	"魔法资质": 1000,
	"魔法资质上限": 1800,
	"魔法资质基础上限": 1800,
	"攻击资质": 1000,
	"攻击资质上限": 1500,
	"攻击资质基础上限": 1500,
	"防御资质": 1000,
	"防御资质上限": 4000,
	"防御资质基础上限": 4000,
	"潜力": 24,
	"潜力上限": 24,
	"强化点": 0,
	"普通培养次数": 0,
	"超级培养次数": 0,
	"放生": false,
	"被动技能": {"热血": 0, "魔泉": 0, "狂暴": 0, "永恒": 0, "辉煌": 0, "敏锐": 0},
	"技能": ["水疗盾"],
	"装备": {"zbst": {}, "zbmz": {}, "zbxz": {}, "zbyf": {}, "zbjn": {}},
	"出战": false
}
const PET_RABBIT_PET := {
	"名称": "月兔",
	"名字": "月兔",
	"类型": "PetRabbit",
	"阶段": 1,
	"等级": 1,
	"经验": 0,
	"下级经验": 100,
	"品质": "神兽",
	"生命": 620,
	"生命上限": 620,
	"魔法": 220,
	"魔法上限": 220,
	"攻击": 70,
	"防御": 58,
	"物防": 58,
	"魔防": 65,
	"暴击": 12,
	"闪避": 8,
	"幸运": 10,
	"回血": 2,
	"回魔": 2,
	"悟性": 0,
	"根骨": 0,
	"灵力": 0,
	"生命资质": 1000,
	"生命资质上限": 2500,
	"生命资质基础上限": 2500,
	"魔法资质": 1000,
	"魔法资质上限": 3000,
	"魔法资质基础上限": 3000,
	"攻击资质": 1000,
	"攻击资质上限": 2800,
	"攻击资质基础上限": 2800,
	"防御资质": 1000,
	"防御资质上限": 1800,
	"防御资质基础上限": 1800,
	"潜力": 24,
	"潜力上限": 24,
	"强化点": 0,
	"普通培养次数": 0,
	"超级培养次数": 0,
	"放生": false,
	"被动技能": {"热血": 0, "魔泉": 0, "狂暴": 0, "永恒": 0, "辉煌": 0, "敏锐": 0},
	"技能": ["月光"],
	"装备": {"zbst": {}, "zbmz": {}, "zbxz": {}, "zbyf": {}, "zbjn": {}},
	"出战": false
}
const PET_MOUSE_PET := {
	"名称": "子鼠元帅",
	"名字": "子鼠元帅",
	"类型": "PetMouse",
	"阶段": 1,
	"等级": 1,
	"经验": 0,
	"下级经验": 100,
	"品质": "神兽",
	"生命": 620,
	"生命上限": 620,
	"魔法": 180,
	"魔法上限": 180,
	"攻击": 65,
	"防御": 60,
	"物防": 60,
	"魔防": 60,
	"暴击": 12,
	"闪避": 6,
	"幸运": 10,
	"回血": 2,
	"回魔": 1,
	"悟性": 0,
	"根骨": 0,
	"灵力": 0,
	"生命资质": 1000,
	"生命资质上限": 2500,
	"生命资质基础上限": 2500,
	"魔法资质": 1000,
	"魔法资质上限": 1800,
	"魔法资质基础上限": 1800,
	"攻击资质": 1000,
	"攻击资质上限": 3000,
	"攻击资质基础上限": 3000,
	"防御资质": 1000,
	"防御资质上限": 1800,
	"防御资质基础上限": 1800,
	"潜力": 24,
	"潜力上限": 24,
	"强化点": 0,
	"普通培养次数": 0,
	"超级培养次数": 0,
	"放生": false,
	"被动技能": {"热血": 0, "魔泉": 0, "狂暴": 0, "永恒": 0, "辉煌": 0, "敏锐": 0},
	"技能": ["鼠窜"],
	"装备": {"zbst": {}, "zbmz": {}, "zbxz": {}, "zbyf": {}, "zbjn": {}},
	"出战": false
}
const PET_NEAT_PET := {
	"名称": "丑牛元帅",
	"名字": "丑牛元帅",
	"类型": "PetNeat",
	"阶段": 1,
	"等级": 1,
	"经验": 0,
	"下级经验": 100,
	"品质": "神兽",
	"生命": 680,
	"生命上限": 680,
	"魔法": 180,
	"魔法上限": 180,
	"攻击": 72,
	"防御": 64,
	"物防": 64,
	"魔防": 58,
	"暴击": 12,
	"闪避": 5,
	"幸运": 10,
	"回血": 2,
	"回魔": 1,
	"悟性": 0,
	"根骨": 0,
	"灵力": 0,
	"生命资质": 1000,
	"生命资质上限": 2800,
	"生命资质基础上限": 2800,
	"魔法资质": 1000,
	"魔法资质上限": 1800,
	"魔法资质基础上限": 1800,
	"攻击资质": 1000,
	"攻击资质上限": 3200,
	"攻击资质基础上限": 3200,
	"防御资质": 1000,
	"防御资质上限": 2200,
	"防御资质基础上限": 2200,
	"潜力": 24,
	"潜力上限": 24,
	"强化点": 0,
	"普通培养次数": 0,
	"超级培养次数": 0,
	"放生": false,
	"被动技能": {"热血": 0, "魔泉": 0, "狂暴": 0, "永恒": 0, "辉煌": 0, "敏锐": 0},
	"技能": ["蛮牛冲撞"],
	"装备": {"zbst": {}, "zbmz": {}, "zbxz": {}, "zbyf": {}, "zbjn": {}},
	"出战": false
}
const PET_YIN_TIGER_PET := {
	"名称": "寅虎元帅",
	"名字": "寅虎元帅",
	"类型": "PetYinTiger",
	"阶段": 1,
	"等级": 1,
	"经验": 0,
	"下级经验": 100,
	"品质": "神兽",
	"生命": 700,
	"生命上限": 700,
	"魔法": 220,
	"魔法上限": 220,
	"攻击": 76,
	"防御": 64,
	"物防": 64,
	"魔防": 64,
	"暴击": 14,
	"闪避": 7,
	"幸运": 10,
	"回血": 2,
	"回魔": 1,
	"悟性": 0,
	"根骨": 0,
	"灵力": 0,
	"生命资质": 1000,
	"生命资质上限": 2800,
	"生命资质基础上限": 2800,
	"魔法资质": 1000,
	"魔法资质上限": 2200,
	"魔法资质基础上限": 2200,
	"攻击资质": 1000,
	"攻击资质上限": 3200,
	"攻击资质基础上限": 3200,
	"防御资质": 1000,
	"防御资质上限": 2200,
	"防御资质基础上限": 2200,
	"潜力": 24,
	"潜力上限": 24,
	"强化点": 0,
	"普通培养次数": 0,
	"超级培养次数": 0,
	"放生": false,
	"被动技能": {"热血": 0, "魔泉": 0, "狂暴": 0, "永恒": 0, "辉煌": 0, "敏锐": 0},
	"技能": ["虎啸"],
	"装备": {"zbst": {}, "zbmz": {}, "zbxz": {}, "zbyf": {}, "zbjn": {}},
	"出战": false
}


func _ready() -> void:
	ensure_avatar_frame_slot()
	ensure_shengu_slot()
	ensure_player_passive_skills()
	ensure_skill_data()
	ensure_special_dungeon_progress()
	_remove_retired_wudu_magic_weapons()
	_remove_retired_classic_and_merchant_equipment()
	ensure_main_sword_array()
	ensure_wanling_catalog_data()
	ensure_mount_data()
	ensure_pet_tiger()
	ensure_pet_dragon()
	ensure_pet_phoenix()
	ensure_pet_turtle()
	ensure_pet_rabbit()
	ensure_pet_mouse()
	ensure_pet_neat()
	ensure_pet_yin_tiger()
	ensure_shared_pet_backpack()
	enforce_level_caps()


func _mount_default_data(mount_id: String) -> Dictionary:
	var template: Dictionary = (MOUNT_TEMPLATES.get(mount_id, {}) as Dictionary).duplicate(true)
	for qualification_key in MOUNT_QUALIFICATION_KEYS:
		template["%s上限" % qualification_key] = MOUNT_QUALIFICATION_MAX
		template[qualification_key] = clampi(int(template.get(qualification_key, 0)), 0, MOUNT_QUALIFICATION_MAX)
	template["ID"] = mount_id
	template[DataKeys.LEVEL] = 1
	template[DataKeys.EXP] = 0
	template["下级经验"] = mount_exp_for_level(1)
	template["疲劳"] = int(template.get("疲劳上限", 2400))
	template[DataKeys.DEPLOYED] = false
	template[MOUNT_UNLOCKED_KEY] = not MOUNT_UNLOCK_REQUIREMENTS.has(mount_id)
	template["图标"] = "res://Art/mount/icons/%s.png" % mount_id
	template["立绘"] = "res://Art/mount/portraits/%s.png" % mount_id
	template["技能"] = MOUNT_CATALOG.get_skills(mount_id)
	var skill_levels: Dictionary = {}
	for skill_value in template["技能"]:
		if skill_value is Dictionary:
			var skill_id := str((skill_value as Dictionary).get("id", ""))
			if skill_id != "":
				skill_levels[skill_id] = 1
	template["技能等级"] = skill_levels

	template["坐骑初始属性"] = {
		"生命": int(template.get(DataKeys.HP, 0)),
		"攻击": int(template.get(DataKeys.ATTACK, 0)),
		"物防": int(template.get("物防", 0)),
		"魔防": int(template.get("魔防", 0)),
		"回血": int(template.get("回血", 0)),
	}
	return template


func ensure_mount_data() -> Array:
	var mounts_value: Variant = player_data.get(MOUNT_LIST_KEY, [])
	var mounts: Array = mounts_value if mounts_value is Array else []
	var by_id: Dictionary = {}
	for mount_value in mounts:
		if mount_value is Dictionary:
			var mount: Dictionary = mount_value
			var mount_id := str(mount.get("ID", ""))
			if MOUNT_TEMPLATES.has(mount_id) and not by_id.has(mount_id):
				by_id[mount_id] = mount
	var mount_level_limit := get_mount_level_limit()
	for mount_id_value in MOUNT_TEMPLATES.keys():
		var mount_id := str(mount_id_value)
		var defaults := _mount_default_data(mount_id)
		var mount: Dictionary = by_id.get(mount_id, defaults)
		for key in defaults.keys():
			if not mount.has(key):
				mount[key] = defaults[key]
		if not (mount.get("坐骑初始属性", null) is Dictionary):
			mount["坐骑初始属性"] = (defaults.get("坐骑初始属性", {}) as Dictionary).duplicate(true)

		if mount_id == "1002200" and str(mount.get(DataKeys.ALT_NAME, "")) in ["", "白虎"]:
			mount[DataKeys.ALT_NAME] = "西灵圣虎"
			mount["描述"] = "西灵圣虎"
		mount["技能"] = MOUNT_CATALOG.get_skills(mount_id)
		var stored_skill_levels_value: Variant = mount.get("技能等级", {})
		var stored_skill_levels: Dictionary = (
			stored_skill_levels_value if stored_skill_levels_value is Dictionary else {}
		)
		var normalized_skill_levels: Dictionary = {}
		for skill_value in mount["技能"]:
			if not (skill_value is Dictionary):
				continue
			var skill_id := str((skill_value as Dictionary).get("id", ""))
			if skill_id != "":
				normalized_skill_levels[skill_id] = clampi(
					int(stored_skill_levels.get(skill_id, 1)), 1, MOUNT_SKILL_MAX_LEVEL
				)
		mount["技能等级"] = normalized_skill_levels
		for qualification_key in MOUNT_QUALIFICATION_KEYS:
			mount["%s上限" % qualification_key] = MOUNT_QUALIFICATION_MAX
			mount[qualification_key] = clampi(int(mount.get(qualification_key, 0)), 0, MOUNT_QUALIFICATION_MAX)
		mount[DataKeys.LEVEL] = clampi(int(mount.get(DataKeys.LEVEL, 1)), 1, mount_level_limit)
		mount[DataKeys.EXP] = maxi(0, int(mount.get(DataKeys.EXP, 0)))
		if int(mount[DataKeys.LEVEL]) >= mount_level_limit:
			mount[DataKeys.EXP] = 0
		mount["下级经验"] = mount_exp_for_level(int(mount[DataKeys.LEVEL]))
		mount["疲劳"] = clampi(int(mount.get("疲劳", mount.get("疲劳上限", 2400))), 0, int(mount.get("疲劳上限", 2400)))
		by_id[mount_id] = mount
	mounts.clear()
	for mount_id_value in MOUNT_TEMPLATES.keys():
		mounts.append(by_id[str(mount_id_value)])
	player_data[MOUNT_LIST_KEY] = mounts
	var active_id := str(player_data.get(ACTIVE_MOUNT_KEY, ""))
	if active_id != "":
		var active_mount_value: Variant = by_id.get(active_id, {})
		if (
			not (active_mount_value is Dictionary)
			or not bool((active_mount_value as Dictionary).get(MOUNT_UNLOCKED_KEY, false))
		):
			active_id = ""
	player_data[ACTIVE_MOUNT_KEY] = active_id
	player_data[MOUNT_RIDING_KEY] = bool(player_data.get(MOUNT_RIDING_KEY, false)) and active_id != ""
	player_data[MOUNT_AUTO_RIDE_KEY] = bool(player_data.get(MOUNT_AUTO_RIDE_KEY, false))
	for mount in mounts:
		mount[DataKeys.DEPLOYED] = str(mount.get("ID", "")) == active_id
	return mounts


func mount_exp_for_level(level: int) -> int:
	var normalized_level := maxi(1, level)
	if normalized_level <= MOUNT_LEVEL_EXP.size():
		return int(MOUNT_LEVEL_EXP[normalized_level - 1])
	return 18600 + (normalized_level - MOUNT_LEVEL_EXP.size()) * 3200


func get_mount_level_limit() -> int:
	return get_capped_player_level()


func is_mount_system_unlocked() -> bool:
	if int(player_data.get("通天教主", 0)) == 1:
		return true
	var coop := get_node_or_null("/root/LocalCoop")
	if (
		coop != null
		and coop.is_enabled()
		and self in [get_node("/root/PlayerData"), coop.data_for_slot(1), coop.data_for_slot(2)]
	):
		return int(coop.data_for_slot(1).player_data.get("通天教主", 0)) == 1
	return false


func get_mount_by_id(mount_id: String) -> Dictionary:
	for mount_value in ensure_mount_data():
		if mount_value is Dictionary and str(mount_value.get("ID", "")) == mount_id:
			return mount_value
	return {}


func _mount_has_skill(mount: Dictionary, skill_id: String) -> bool:
	var skills_value: Variant = mount.get("技能", [])
	if not (skills_value is Array):
		return false
	for skill_value in skills_value:
		if skill_value is Dictionary and str((skill_value as Dictionary).get("id", "")) == skill_id:
			return true
	return false


func get_mount_skill_level(mount_id: String, skill_id: String) -> int:
	var mount := get_mount_by_id(mount_id)
	if mount.is_empty() or not _mount_has_skill(mount, skill_id):
		return 0
	var levels_value: Variant = mount.get("技能等级", {})
	var levels: Dictionary = levels_value if levels_value is Dictionary else {}
	var level := clampi(int(levels.get(skill_id, 1)), 1, MOUNT_SKILL_MAX_LEVEL)
	levels[skill_id] = level
	mount["技能等级"] = levels
	return level


func get_mount_skill_damage_multiplier(mount_id: String, skill_id: String, level_override: int = -1) -> float:
	var combat := MOUNT_CATALOG.get_official_combat(skill_id)
	if combat.is_empty() or bool(combat.get("buff", false)):
		return 0.0
	var skill_level := (
		clampi(level_override, 1, MOUNT_SKILL_MAX_LEVEL)
		if level_override > 0
		else get_mount_skill_level(mount_id, skill_id)
	)
	if skill_level <= 0:
		return 0.0
	return float(combat.get("power", 0.0)) + float(combat.get("add", 0.0)) * float(skill_level)


func get_mount_skill_upgrade_cost(mount_id: String, skill_id: String) -> int:
	var skill_level := get_mount_skill_level(mount_id, skill_id)
	if skill_level <= 0 or skill_level >= MOUNT_SKILL_MAX_LEVEL:
		return 0
	return maxi(500, skill_level * 500)


func upgrade_mount_skill(mount_id: String, skill_id: String) -> bool:
	var mount := get_mount_by_id(mount_id)
	if mount.is_empty() or not bool(mount.get(MOUNT_UNLOCKED_KEY, false)) or not _mount_has_skill(mount, skill_id):
		return false
	var skill_level := get_mount_skill_level(mount_id, skill_id)
	if skill_level <= 0 or skill_level >= MOUNT_SKILL_MAX_LEVEL:
		return false
	var cost := get_mount_skill_upgrade_cost(mount_id, skill_id)
	if cost <= 0 or not spend_soul(cost):
		return false
	var levels_value: Variant = mount.get("技能等级", {})
	var levels: Dictionary = levels_value if levels_value is Dictionary else {}
	levels[skill_id] = skill_level + 1
	mount["技能等级"] = levels
	return true


func get_mount_unlock_requirement(mount_id: String) -> Dictionary:
	var requirement_value: Variant = MOUNT_UNLOCK_REQUIREMENTS.get(mount_id, {})
	return (requirement_value as Dictionary).duplicate(true) if requirement_value is Dictionary else {}


func is_mount_unlocked(mount_id: String) -> bool:
	var mount := get_mount_by_id(mount_id)
	return not mount.is_empty() and bool(mount.get(MOUNT_UNLOCKED_KEY, false))


func get_inventory_item_count(item_id: String) -> int:
	var total := 0
	for list_key in ["消耗品列表", "道具列表"]:
		var pages_value: Variant = player_data.get(list_key, {})
		if not (pages_value is Dictionary):
			continue
		for page_value in (pages_value as Dictionary).values():
			if not (page_value is Array):
				continue
			for item_value in page_value:
				if item_value is Dictionary and str((item_value as Dictionary).get(DataKeys.NAME, "")) == item_id:
					total += int((item_value as Dictionary).get(DataKeys.COUNT, 0))
	return total


func unlock_mount(mount_id: String) -> bool:
	var mount := get_mount_by_id(mount_id)
	if mount.is_empty():
		return false
	if bool(mount.get(MOUNT_UNLOCKED_KEY, false)):
		return true
	var requirement := get_mount_unlock_requirement(mount_id)
	var item_id := str(requirement.get("物品", ""))
	var count := maxi(1, int(requirement.get(DataKeys.COUNT, 1)))
	if item_id == "" or get_inventory_item_count(item_id) < count:
		return false
	if not remove_item(item_id, count):
		return false
	mount[MOUNT_UNLOCKED_KEY] = true
	return true


func upgrade_mount_random_qualification(mount_id: String) -> Dictionary:
	var mount := get_mount_by_id(mount_id)
	if mount.is_empty() or not bool(mount.get(MOUNT_UNLOCKED_KEY, false)):
		return {"success": false, "reason": "locked"}
	var requirement := get_mount_unlock_requirement(mount_id)
	var item_id := str(requirement.get("物品", ""))
	if item_id == "":
		return {"success": false, "reason": "material_missing"}
	var available_qualifications: Array[String] = []
	for qualification_key in MOUNT_QUALIFICATION_KEYS:
		if int(mount.get(qualification_key, 0)) < MOUNT_QUALIFICATION_MAX:
			available_qualifications.append(qualification_key)
	if available_qualifications.is_empty():
		return {"success": false, "reason": "max", "item_id": item_id}
	if get_inventory_item_count(item_id) < 1:
		return {"success": false, "reason": "material_missing", "item_id": item_id}
	if not remove_item(item_id, 1):
		return {"success": false, "reason": "material_missing", "item_id": item_id}
	var qualification_key := available_qualifications[randi_range(0, available_qualifications.size() - 1)]
	var old_value := int(mount.get(qualification_key, 0))
	var rolled_gain := randi_range(100, 150)
	var new_value := mini(MOUNT_QUALIFICATION_MAX, old_value + rolled_gain)
	mount[qualification_key] = new_value
	mount["%s上限" % qualification_key] = MOUNT_QUALIFICATION_MAX
	_recalculate_mount_stats(mount)
	return {
		"success": true,
		"stat": qualification_key,
		"gain": new_value - old_value,
		"rolled_gain": rolled_gain,
		"value": new_value,
		"item_id": item_id,
	}


func get_active_mount() -> Dictionary:
	var active_id := str(player_data.get(ACTIVE_MOUNT_KEY, ""))
	if active_id == "":
		return {}
	var mount := get_mount_by_id(active_id)
	return mount if bool(mount.get(MOUNT_UNLOCKED_KEY, false)) else {}


func set_active_mount(mount_id: String) -> bool:
	ensure_mount_data()
	if mount_id != "":
		var mount := get_mount_by_id(mount_id)
		if mount.is_empty() or not bool(mount.get(MOUNT_UNLOCKED_KEY, false)):
			return false
	player_data[ACTIVE_MOUNT_KEY] = mount_id
	if mount_id == "":
		player_data[MOUNT_RIDING_KEY] = false
	for mount_value in player_data[MOUNT_LIST_KEY]:
		if mount_value is Dictionary:
			mount_value[DataKeys.DEPLOYED] = str(mount_value.get("ID", "")) == mount_id
	return true


func set_mount_riding(enabled: bool) -> bool:
	var mount := get_active_mount()
	var can_ride := enabled and is_mount_system_unlocked() and not mount.is_empty() and int(mount.get("疲劳", 0)) > 0
	player_data[MOUNT_RIDING_KEY] = can_ride
	return can_ride


func set_mount_auto_ride(enabled: bool) -> void:
	ensure_mount_data()
	player_data[MOUNT_AUTO_RIDE_KEY] = enabled


func add_mount_exp(mount_id: String, amount: int) -> int:
	var mount := get_mount_by_id(mount_id)
	if mount.is_empty() or not bool(mount.get(MOUNT_UNLOCKED_KEY, false)) or amount <= 0:
		return int(mount.get(DataKeys.LEVEL, 0))
	var level_limit := get_mount_level_limit()
	if int(mount.get(DataKeys.LEVEL, 1)) >= level_limit:
		mount[DataKeys.EXP] = 0
		mount["下级经验"] = mount_exp_for_level(int(mount.get(DataKeys.LEVEL, 1)))
		return int(mount.get(DataKeys.LEVEL, 1))
	mount[DataKeys.EXP] = int(mount.get(DataKeys.EXP, 0)) + amount
	while int(mount.get(DataKeys.LEVEL, 1)) < level_limit:
		var need := mount_exp_for_level(int(mount[DataKeys.LEVEL]))
		if int(mount[DataKeys.EXP]) < need:
			break
		mount[DataKeys.EXP] = int(mount[DataKeys.EXP]) - need
		mount[DataKeys.LEVEL] = int(mount[DataKeys.LEVEL]) + 1
	if int(mount.get(DataKeys.LEVEL, 1)) >= level_limit:
		mount[DataKeys.EXP] = 0
	mount["下级经验"] = mount_exp_for_level(int(mount[DataKeys.LEVEL]))
	_recalculate_mount_stats(mount)
	return int(mount[DataKeys.LEVEL])


func upgrade_mount_to_level_limit(mount_id: String) -> Dictionary:
	var mount := get_mount_by_id(mount_id)
	if mount.is_empty() or not bool(mount.get(MOUNT_UNLOCKED_KEY, false)):
		return {"success": false, "reason": "locked"}
	var old_level := int(mount.get(DataKeys.LEVEL, 1))
	var level_limit := get_mount_level_limit()
	if old_level >= level_limit:
		return {"success": false, "reason": "max", "level": old_level}
	var target_level := old_level
	var total_cost := 0
	var available_soul := get_soul()
	while target_level < level_limit:
		var level_cost := maxi(500, target_level * 500)
		if total_cost + level_cost > available_soul:
			break
		total_cost += level_cost
		target_level += 1
	if target_level == old_level:
		return {
			"success": false,
			"reason": "soul",
			"level": old_level,
			"need": maxi(500, old_level * 500),
		}
	if not spend_soul(total_cost):
		return {"success": false, "reason": "soul", "level": old_level}
	mount[DataKeys.LEVEL] = target_level
	mount[DataKeys.EXP] = 0
	mount["下级经验"] = mount_exp_for_level(target_level)
	_recalculate_mount_stats(mount)
	return {
		"success": true,
		"old_level": old_level,
		"level": target_level,
		"cost": total_cost,
		"reached_limit": target_level >= level_limit,
	}


func _recalculate_mount_stats(mount: Dictionary) -> void:
	var base_value: Variant = mount.get("坐骑初始属性", {})
	var base: Dictionary = base_value if base_value is Dictionary else {}
	var level_count := maxi(0, int(mount.get(DataKeys.LEVEL, 1)) - 1)
	var life_quality := float(mount.get("生命资质", 0))
	var attack_quality := float(mount.get("攻击资质", 0))
	var defense_quality := float(mount.get("防御资质", 0))
	mount[DataKeys.HP] = int(
		round(float(base.get(DataKeys.HP, mount.get(DataKeys.HP, 0))) + level_count * life_quality * 1.67415)
	)
	mount[DataKeys.ATTACK] = int(
		round(float(base.get(DataKeys.ATTACK, mount.get(DataKeys.ATTACK, 0))) + level_count * attack_quality * 0.058305)
	)
	mount["物防"] = int(round(float(base.get("物防", mount.get("物防", 0))) + level_count * defense_quality * 0.004679))
	mount["魔防"] = int(round(float(base.get("魔防", mount.get("魔防", 0))) + level_count * defense_quality * 0.004679))
	mount["回血"] = int(round(float(base.get("回血", mount.get("回血", 0))) + level_count * life_quality * 0.0068))


func get_active_mount_attribute_bonuses() -> Dictionary:
	if not is_mount_system_unlocked():
		return {}
	var mount := get_active_mount()
	if mount.is_empty():
		return {}

	return {
		"SHp": int(mount.get(DataKeys.HP, 0)),
		"power": int(mount.get(DataKeys.ATTACK, 0)),
		"Def": int(mount.get("物防", 0)),
		"Mdef": int(mount.get("魔防", 0)),
		"Crit": int(mount.get("暴击", 0)),
		"Miss": int(mount.get("闪避", 0)),
		"Lucky": int(mount.get("幸运", 0)),
		"htarget": int(mount.get("命中", 0)),
		"R_hp": int(mount.get("回血", 0)),
		"sp": int(mount.get("破魔", 0)),
	}


func ensure_avatar_frame_slot() -> Array:
	if not (player_data.get(AVATAR_FRAME_KEY, null) is Array):
		player_data[AVATAR_FRAME_KEY] = []
	return player_data[AVATAR_FRAME_KEY]


func ensure_shengu_slot() -> Array:
	if not (player_data.get("神骨", null) is Array):
		player_data["神骨"] = []
	return player_data["神骨"]


func ensure_player_passive_skills() -> void:
	var passive_value: Variant = player_data.get("被动技能", {})
	if not (passive_value is Dictionary):
		passive_value = {}
		player_data["被动技能"] = passive_value
	var passive_levels: Dictionary = passive_value
	for skill_name in PLAYER_PASSIVE_SKILL_KEYS:
		passive_levels[skill_name] = max(0, int(passive_levels.get(skill_name, 0)))


func ensure_wanling_catalog_data() -> Dictionary:
	var catalog_value: Variant = player_data.get(WANLING_CATALOG_LEVELS_KEY, {})
	var catalog: Dictionary = catalog_value if catalog_value is Dictionary else {}
	var human_value: Variant = catalog.get(WANLING_HUMAN_CATEGORY, {})
	var human_levels: Dictionary = human_value if human_value is Dictionary else {}
	for monster_id in WANLING_HUMAN_MONSTER_IDS:
		var monster_key := str(int(monster_id))
		var legacy_key := "human_%d" % int(monster_id)
		human_levels[monster_key] = clampi(
			int(human_levels.get(monster_key, catalog.get(legacy_key, 0))),
			0,
			get_wanling_human_consume_limit(int(monster_id))
		)
	catalog[WANLING_HUMAN_CATEGORY] = human_levels
	var underworld_value: Variant = catalog.get(WANLING_UNDERWORLD_CATEGORY, {})
	var underworld_levels: Dictionary = underworld_value if underworld_value is Dictionary else {}
	underworld_levels.erase("34")
	for monster_id in WANLING_UNDERWORLD_MONSTER_IDS:
		var underworld_key := str(int(monster_id))
		underworld_levels[underworld_key] = clampi(
			int(underworld_levels.get(underworld_key, 0)), 0, get_wanling_underworld_consume_limit(int(monster_id))
		)
	catalog[WANLING_UNDERWORLD_CATEGORY] = underworld_levels
	var heaven_value: Variant = catalog.get(WANLING_HEAVEN_CATEGORY, {})
	var heaven_levels: Dictionary = heaven_value if heaven_value is Dictionary else {}
	for monster_id in WANLING_HEAVEN_MONSTER_IDS:
		var heaven_key := str(int(monster_id))
		heaven_levels[heaven_key] = clampi(
			int(heaven_levels.get(heaven_key, 0)), 0, get_wanling_heaven_consume_limit(int(monster_id))
		)
	catalog[WANLING_HEAVEN_CATEGORY] = heaven_levels
	player_data[WANLING_CATALOG_LEVELS_KEY] = catalog
	return catalog


func get_wanling_human_level(monster_id: int) -> int:
	if not WANLING_HUMAN_MONSTER_IDS.has(monster_id):
		return 0
	var catalog := ensure_wanling_catalog_data()
	var human_levels: Dictionary = catalog[WANLING_HUMAN_CATEGORY]
	return max(0, int(human_levels.get(str(monster_id), 0)))


func get_wanling_human_consumed_count(monster_id: int) -> int:
	return get_wanling_human_level(monster_id)


func get_wanling_human_consume_limit(monster_id: int) -> int:
	if not WANLING_HUMAN_MONSTER_IDS.has(monster_id):
		return 0
	return WANLING_BOSS_LIMIT if WANLING_HUMAN_BOSS_IDS.has(monster_id) else WANLING_SMALL_MONSTER_LIMIT


func get_wanling_soul_crystal_count(monster_id: int) -> int:
	if not WANLING_HUMAN_MONSTER_IDS.has(monster_id):
		return 0
	var item_id := "human_soul_crystal_%d" % monster_id
	var inventory_value: Variant = player_data.get(DataKeys.ITEM_LIST, {})
	if not (inventory_value is Dictionary):
		return 0
	var total := 0
	for page_value in (inventory_value as Dictionary).values():
		if not (page_value is Array):
			continue
		for item_value in page_value:
			if item_value is Dictionary and str(item_value.get(DataKeys.NAME, "")) == item_id:
				total += max(0, int(item_value.get(DataKeys.COUNT, 0)))
	return total


func consume_all_wanling_human_crystals(monster_id: int) -> int:
	if not WANLING_HUMAN_MONSTER_IDS.has(monster_id):
		return 0
	var consumed_count := get_wanling_human_consumed_count(monster_id)
	var remaining := get_wanling_human_consume_limit(monster_id) - consumed_count
	var consume_count := mini(get_wanling_soul_crystal_count(monster_id), remaining)
	if consume_count <= 0:
		return 0
	var item_id := "human_soul_crystal_%d" % monster_id
	if not remove_item(item_id, consume_count):
		return 0
	var catalog := ensure_wanling_catalog_data()
	var human_levels: Dictionary = catalog[WANLING_HUMAN_CATEGORY]
	human_levels[str(monster_id)] = consumed_count + consume_count
	return consume_count


func get_wanling_underworld_level(monster_id: int) -> int:
	if not WANLING_UNDERWORLD_MONSTER_IDS.has(monster_id):
		return 0
	var catalog := ensure_wanling_catalog_data()
	var underworld_levels: Dictionary = catalog[WANLING_UNDERWORLD_CATEGORY]
	return max(0, int(underworld_levels.get(str(monster_id), 0)))


func get_wanling_underworld_consumed_count(monster_id: int) -> int:
	return get_wanling_underworld_level(monster_id)


func get_wanling_underworld_consume_limit(monster_id: int) -> int:
	if not WANLING_UNDERWORLD_MONSTER_IDS.has(monster_id):
		return 0
	return WANLING_BOSS_LIMIT if WANLING_UNDERWORLD_BOSS_IDS.has(monster_id) else WANLING_SMALL_MONSTER_LIMIT


func get_wanling_underworld_soul_crystal_count(monster_id: int) -> int:
	if not WANLING_UNDERWORLD_MONSTER_IDS.has(monster_id):
		return 0
	var item_id := "underworld_soul_crystal_%d" % monster_id
	var inventory_value: Variant = player_data.get(DataKeys.ITEM_LIST, {})
	if not (inventory_value is Dictionary):
		return 0
	var total := 0
	for page_value in (inventory_value as Dictionary).values():
		if not (page_value is Array):
			continue
		for item_value in page_value:
			if item_value is Dictionary and str(item_value.get(DataKeys.NAME, "")) == item_id:
				total += max(0, int(item_value.get(DataKeys.COUNT, 0)))
	return total


func consume_all_wanling_underworld_crystals(monster_id: int) -> int:
	if not WANLING_UNDERWORLD_MONSTER_IDS.has(monster_id):
		return 0
	var consumed_count := get_wanling_underworld_consumed_count(monster_id)
	var remaining := get_wanling_underworld_consume_limit(monster_id) - consumed_count
	var consume_count := mini(get_wanling_underworld_soul_crystal_count(monster_id), remaining)
	if consume_count <= 0:
		return 0
	var item_id := "underworld_soul_crystal_%d" % monster_id
	if not remove_item(item_id, consume_count):
		return 0
	var catalog := ensure_wanling_catalog_data()
	var underworld_levels: Dictionary = catalog[WANLING_UNDERWORLD_CATEGORY]
	underworld_levels[str(monster_id)] = consumed_count + consume_count
	return consume_count


func get_wanling_heaven_level(monster_id: int) -> int:
	if not WANLING_HEAVEN_MONSTER_IDS.has(monster_id):
		return 0
	var catalog := ensure_wanling_catalog_data()
	var heaven_levels: Dictionary = catalog[WANLING_HEAVEN_CATEGORY]
	return max(0, int(heaven_levels.get(str(monster_id), 0)))


func get_wanling_heaven_consumed_count(monster_id: int) -> int:
	return get_wanling_heaven_level(monster_id)


func get_wanling_heaven_consume_limit(monster_id: int) -> int:
	if not WANLING_HEAVEN_MONSTER_IDS.has(monster_id):
		return 0
	return WANLING_BOSS_LIMIT if WANLING_HEAVEN_BOSS_IDS.has(monster_id) else WANLING_SMALL_MONSTER_LIMIT


func get_wanling_heaven_soul_crystal_count(monster_id: int) -> int:
	if not WANLING_HEAVEN_MONSTER_IDS.has(monster_id):
		return 0
	var item_id := "heaven_soul_crystal_%d" % monster_id
	var inventory_value: Variant = player_data.get(DataKeys.ITEM_LIST, {})
	if not (inventory_value is Dictionary):
		return 0
	var total := 0
	for page_value in (inventory_value as Dictionary).values():
		if not (page_value is Array):
			continue
		for item_value in page_value:
			if item_value is Dictionary and str(item_value.get(DataKeys.NAME, "")) == item_id:
				total += max(0, int(item_value.get(DataKeys.COUNT, 0)))
	return total


func consume_all_wanling_heaven_crystals(monster_id: int) -> int:
	if not WANLING_HEAVEN_MONSTER_IDS.has(monster_id):
		return 0
	var consumed_count := get_wanling_heaven_consumed_count(monster_id)
	var remaining := get_wanling_heaven_consume_limit(monster_id) - consumed_count
	var consume_count := mini(get_wanling_heaven_soul_crystal_count(monster_id), remaining)
	if consume_count <= 0:
		return 0
	var item_id := "heaven_soul_crystal_%d" % monster_id
	if not remove_item(item_id, consume_count):
		return 0
	var catalog := ensure_wanling_catalog_data()
	var heaven_levels: Dictionary = catalog[WANLING_HEAVEN_CATEGORY]
	heaven_levels[str(monster_id)] = consumed_count + consume_count
	return consume_count


func get_wanling_attribute_totals() -> Dictionary:
	var totals := {
		"SHp": 0.0,
		"SMp": 0.0,
		"power": 0.0,
		"Def": 0.0,
		"Mdef": 0.0,
		"Crit": 0.0,
		"ar": 0.0,
		"sp": 0.0,
		"R_hp": 0.0,
		"R_mp": 0.0,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"vampirism": 0.0,
	}
	for monster_id in WANLING_HUMAN_MONSTER_IDS:
		var consumed_count := get_wanling_human_consumed_count(int(monster_id))
		var effects_value: Variant = WANLING_HUMAN_MONSTER_EFFECTS.get(monster_id, {})
		if consumed_count <= 0 or not (effects_value is Dictionary):
			continue
		for attribute_name in effects_value as Dictionary:
			totals[attribute_name] = (
				float(totals.get(attribute_name, 0.0)) + float(effects_value[attribute_name]) * consumed_count
			)
	for monster_id in WANLING_UNDERWORLD_MONSTER_IDS:
		var consumed_count := get_wanling_underworld_consumed_count(int(monster_id))
		var effects_value: Variant = WANLING_UNDERWORLD_MONSTER_EFFECTS.get(monster_id, {})
		if consumed_count <= 0 or not (effects_value is Dictionary):
			continue
		for attribute_name in effects_value as Dictionary:
			totals[attribute_name] = (
				float(totals.get(attribute_name, 0.0)) + float(effects_value[attribute_name]) * consumed_count
			)
	for monster_id in WANLING_HEAVEN_MONSTER_IDS:
		var consumed_count := get_wanling_heaven_consumed_count(int(monster_id))
		var effects_value: Variant = WANLING_HEAVEN_MONSTER_EFFECTS.get(monster_id, {})
		if consumed_count <= 0 or not (effects_value is Dictionary):
			continue
		for attribute_name in effects_value as Dictionary:
			totals[attribute_name] = (
				float(totals.get(attribute_name, 0.0)) + float(effects_value[attribute_name]) * consumed_count
			)
	return totals


func ensure_shared_pet_backpack() -> Array:
	if not (player_data.get(PET_BACKPACK_KEY, null) is Array):
		player_data[PET_BACKPACK_KEY] = []
	var shared: Array = player_data[PET_BACKPACK_KEY]
	var shared_index := 0
	while shared_index < shared.size():
		if _is_retired_test_pet_equipment(shared[shared_index]):
			shared.remove_at(shared_index)
			continue
		_ensure_pet_equipment_random_stats(shared[shared_index])
		shared_index += 1

	var pets: Variant = player_data.get(PET_LIST_KEY, [])
	if pets is Array:
		for pet_value in pets:
			if not (pet_value is Dictionary):
				continue
			var pet: Dictionary = pet_value
			var old_pack: Variant = pet.get("背包", [])
			if old_pack is Array:
				for item_value in old_pack:
					if not (item_value is Dictionary):
						continue
					if _is_retired_test_pet_equipment(item_value):
						continue
					var migrated_item := (item_value as Dictionary).duplicate(true)
					_ensure_pet_equipment_random_stats(migrated_item)
					shared.append(migrated_item)
			pet.erase("背包")
			pet.erase("宠物背包已初始化")
			var equipment_value: Variant = pet.get("装备", {})
			if equipment_value is Dictionary:
				var equipment: Dictionary = equipment_value
				for equipment_key in equipment.keys():
					var equipped_value: Variant = equipment[equipment_key]
					if _is_retired_test_pet_equipment(equipped_value):
						equipment[equipment_key] = {}
						continue
					_ensure_pet_equipment_random_stats(equipped_value)

	return shared


func _ensure_pet_equipment_random_stats(value: Variant) -> void:
	if not (value is Dictionary):
		return
	var item: Dictionary = value
	var data_value: Variant = item.get("Data", {})
	var data: Dictionary = data_value if data_value is Dictionary else {}
	var belongs_to := str(item.get("所属", data.get("所属", ""))).strip_edges()
	var data_type := str(data.get(DataKeys.TYPE, "")).strip_edges()
	if belongs_to != "宠物装备" and data_type != "宠物装备":
		return

	var existing_value: Variant = item.get(PET_EQUIPMENT_RANDOM_STAT_KEY, null)
	if not (existing_value is Array):
		existing_value = data.get(PET_EQUIPMENT_RANDOM_STAT_KEY, null)
		if existing_value is Array:
			item[PET_EQUIPMENT_RANDOM_STAT_KEY] = (existing_value as Array).duplicate(true)
	var random_stats: Array = (
		item.get(PET_EQUIPMENT_RANDOM_STAT_KEY, []) if item.get(PET_EQUIPMENT_RANDOM_STAT_KEY, []) is Array else []
	)
	if random_stats.size() >= PET_EQUIPMENT_RANDOM_STAT_COUNT:
		return

	var generated_source := data.duplicate(true)
	for key in item.keys():
		if key == "Data" or key == PET_EQUIPMENT_RANDOM_STAT_KEY:
			continue
		if not generated_source.has(key):
			generated_source[key] = item[key]
	var generated := _generate_pet_equipment_random_stats(generated_source)
	if generated.is_empty():
		return
	for generated_value in generated:
		if random_stats.size() >= PET_EQUIPMENT_RANDOM_STAT_COUNT:
			break
		random_stats.append(generated_value)
	item[PET_EQUIPMENT_RANDOM_STAT_KEY] = random_stats


func add_pet_backpack_item(item_id: String, amount: int = 1, data_override: Dictionary = {}) -> int:
	if amount <= 0:
		return 0
	var item_data: Dictionary = data_override.duplicate(true)
	if item_data.is_empty():
		if AE == null or not AE.all_equipment.has(item_id):
			return 0
		item_data = AE.all_equipment[item_id].duplicate(true)
	if item_data.is_empty():
		return 0

	var item_name := str(item_data.get(DataKeys.NAME, item_data.get(DataKeys.ALT_NAME, item_id))).strip_edges()
	if item_name == "":
		item_name = item_id
	var slot_type := str(item_data.get("装备类型", item_data.get(DataKeys.TYPE, ""))).strip_edges()
	if slot_type == "宠物装备":
		slot_type = str(item_data.get("装备类型", "")).strip_edges()
	if slot_type == "":
		return 0

	var shared := ensure_shared_pet_backpack()
	for _index in range(amount):
		var random_stats := _generate_pet_equipment_random_stats(item_data)
		(
			shared
			. append(
				{
					"名字": item_name,
					"强化等级": 0,
					"类型": slot_type,
					PET_EQUIPMENT_RANDOM_STAT_KEY: random_stats,
					"Data": item_data.duplicate(true),
				}
			)
		)
	return amount


func get_equipment_strength_max_level(item: Dictionary = {}, item_id: String = "") -> int:
	var nested: Dictionary = item.get("Data", {}) if item.get("Data", {}) is Dictionary else {}
	var resolved_item_id := item_id.strip_edges()
	if resolved_item_id == "":
		resolved_item_id = (
			str(item.get("ID", item.get("id", item.get(DataKeys.NAME, item.get(DataKeys.ALT_NAME, ""))))).strip_edges()
		)
	if (
		bool(item.get("不可强化", nested.get("不可强化", false)))
		and resolved_item_id not in ["cjxianjie", "cdxianjie", "zhxianjie"]
	):
		return 0
	var quality := str(item.get(DataKeys.QUALITY, nested.get(DataKeys.QUALITY, ""))).strip_edges()
	if quality == "" and AE != null and AE.all_equipment.has(resolved_item_id):
		quality = str(AE.all_equipment[resolved_item_id].get(DataKeys.QUALITY, "")).strip_edges()
	if quality == "" or STANDARD_STRENGTH_QUALITIES.has(quality):
		return 30
	return PET_EQUIPMENT_MAX_STRENGTH_LEVEL


func _generate_pet_equipment_random_stats(item_data: Dictionary) -> Array:
	var strengthen_value: Variant = item_data.get(DataKeys.ENHANCE_PROP, {})
	var strengthen: Dictionary = strengthen_value if strengthen_value is Dictionary else {}
	var candidates: Array[String] = []
	for stat_key in PET_EQUIPMENT_TEMPLATE_STAT_KEYS:
		var key := str(stat_key)
		var base_value := _pet_equipment_numeric_value(item_data.get(key, 0))
		var strengthen_stat_value := _pet_equipment_numeric_value(strengthen.get(key, 0))
		if not is_zero_approx(base_value) or not is_zero_approx(strengthen_stat_value):
			candidates.append(key)
	if candidates.is_empty():
		return []

	var random_stats: Array = []
	for _index in range(PET_EQUIPMENT_RANDOM_STAT_COUNT):
		var stat_key := candidates[randi_range(0, candidates.size() - 1)]
		(
			random_stats
			. append(
				{
					"属性": stat_key,
					"数值": _pet_equipment_numeric_value(item_data.get(stat_key, 0)),
					"强化属性": _pet_equipment_numeric_value(strengthen.get(stat_key, 0)),
				}
			)
		)
	return random_stats


func _pet_equipment_numeric_value(value: Variant) -> float:
	if typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT:
		return float(value)
	if value is String and (value as String).strip_edges().is_valid_float():
		return float(value)
	return 0.0


func get_pet_equipment_stat(pet: Dictionary, stat_name: String) -> int:
	var canonical := _pet_equipment_canonical_stat_key(stat_name)
	if canonical == "":
		return 0
	var equipment_value: Variant = pet.get("装备", {})
	if not (equipment_value is Dictionary):
		return 0
	var aliases: Array = PET_EQUIPMENT_STAT_ALIASES.get(canonical, [canonical])
	var total := 0.0
	for item_value in (equipment_value as Dictionary).values():
		if not (item_value is Dictionary) or (item_value as Dictionary).is_empty():
			continue
		total += _pet_equipment_item_stat(item_value as Dictionary, aliases)
	return int(round(total))


func get_pet_equipment_bonuses(pet: Dictionary) -> Dictionary:
	var totals: Dictionary = {}
	for canonical in PET_EQUIPMENT_STAT_KEYS:
		totals[canonical] = 0.0
	var equipment_value: Variant = pet.get("装备", {})
	if equipment_value is Dictionary:
		for item_value in (equipment_value as Dictionary).values():
			if not (item_value is Dictionary) or (item_value as Dictionary).is_empty():
				continue
			_accumulate_pet_equipment_item_bonuses(totals, item_value as Dictionary)
	var formation_bonuses := get_pet_formation_bonuses()
	for canonical in PET_EQUIPMENT_STAT_KEYS:
		totals[canonical] = float(totals.get(canonical, 0.0)) + float(formation_bonuses.get(canonical, 0))

	var bonuses: Dictionary = {}
	for canonical in PET_EQUIPMENT_STAT_KEYS:
		var value := int(round(float(totals.get(canonical, 0.0))))
		bonuses[canonical] = value
		var aliases: Array = PET_EQUIPMENT_STAT_ALIASES.get(canonical, [])
		for alias in aliases:
			if not bonuses.has(alias):
				bonuses[alias] = value
	return bonuses


func get_pet_formation_levels() -> Dictionary:
	var levels_value: Variant = player_data.get(PET_FORMATION_LEVELS_KEY, {})
	var levels: Dictionary = levels_value if levels_value is Dictionary else {}
	for stat_name in PET_FORMATION_DEFAULT_LEVELS:
		levels[stat_name] = clampi(int(levels.get(stat_name, 0)), 0, 100)
	player_data[PET_FORMATION_LEVELS_KEY] = levels
	return levels


func get_pet_formation_bonuses() -> Dictionary:
	var levels := get_pet_formation_levels()
	var bonuses: Dictionary = {}
	for stat_name in PET_FORMATION_STAT_GAINS:
		var canonical: String = "防御" if str(stat_name) == "物防" else str(stat_name)
		bonuses[canonical] = (
			int(bonuses.get(canonical, 0))
			+ pet_formation_stat_value(int(levels.get(stat_name, 0)), int(PET_FORMATION_STAT_GAINS[stat_name]))
		)
	return bonuses


func pet_formation_stat_value(level: int, gain_per_level: int) -> int:
	var safe_level := clampi(level, 0, 100)
	var milestone_multiplier := 1.0 + float(floori(float(safe_level) / 10.0)) * 0.1
	return roundi(float(safe_level * gain_per_level) * milestone_multiplier)


func _accumulate_pet_equipment_item_bonuses(totals: Dictionary, item: Dictionary) -> void:
	var nested_value: Variant = item.get("Data", {})
	var nested: Dictionary = nested_value if nested_value is Dictionary else {}
	var sources: Array = [item, nested]
	var level := _pet_equipment_level_from_sources(sources)
	var random_stats := _pet_equipment_random_stats_from_sources(sources)
	var gem_properties := _pet_equipment_gem_properties([nested, item])
	for canonical in PET_EQUIPMENT_STAT_KEYS:
		var aliases: Array = PET_EQUIPMENT_STAT_ALIASES.get(canonical, [canonical])
		var item_total := _pet_equipment_number_from_sources(sources, aliases)
		item_total += _pet_equipment_strength_from_sources(sources, aliases) * level
		item_total += _pet_equipment_random_stat_total(random_stats, aliases, level)
		item_total += _pet_equipment_number_from_sources([gem_properties], aliases)
		totals[canonical] = float(totals.get(canonical, 0.0)) + item_total


func _pet_equipment_canonical_stat_key(stat_name: String) -> String:
	var requested := stat_name.strip_edges()
	if requested == "":
		return ""
	for canonical in PET_EQUIPMENT_STAT_KEYS:
		if str(canonical).to_lower() == requested.to_lower():
			return str(canonical)
		var aliases: Array = PET_EQUIPMENT_STAT_ALIASES.get(canonical, [])
		for alias in aliases:
			if str(alias).to_lower() == requested.to_lower():
				return str(canonical)
	return ""


func _pet_equipment_item_stat(item: Dictionary, aliases: Array) -> float:
	var nested_value: Variant = item.get("Data", {})
	var nested: Dictionary = {}
	if nested_value is Dictionary:
		nested = nested_value
	var sources: Array = [item, nested]
	var base_value := _pet_equipment_number_from_sources(sources, aliases)
	var strengthen_value := _pet_equipment_strength_from_sources(sources, aliases)
	var level := _pet_equipment_level_from_sources(sources)
	var random_value := _pet_equipment_random_stat_total(
		_pet_equipment_random_stats_from_sources(sources), aliases, level
	)
	var gem_value := _pet_equipment_gem_stat([nested, item], aliases)
	return base_value + strengthen_value * level + random_value + gem_value


func _pet_equipment_gem_stat(sources: Array, aliases: Array) -> float:
	var gem_properties := _pet_equipment_gem_properties(sources)
	return _pet_equipment_number_from_sources([gem_properties], aliases)


func _pet_equipment_gem_properties(sources: Array) -> Dictionary:
	for source_value in sources:
		if not (source_value is Dictionary):
			continue
		var source: Dictionary = source_value
		if not (source.get(DataKeys.GEM, null) is Array):
			continue
		return AE.get_divine_forge_gem_properties("", source)
	return {}


func take_pet_equipment_for_mosaic(index: int, expected_item: Variant, item_id: String) -> bool:
	var mosaic_value: Variant = player_data.get(DataKeys.INLAY_LIST, [])
	if not (mosaic_value is Array) or not (mosaic_value as Array).is_empty():
		return false
	var shared := ensure_shared_pet_backpack()
	if index < 0 or index >= shared.size():
		return false
	var item_value: Variant = shared[index]
	if not (item_value is Dictionary) or not is_same(item_value, expected_item):
		return false
	var item: Dictionary = item_value
	var data_value: Variant = item.get("Data", null)
	if not (data_value is Dictionary):
		item["Data"] = {}
	var data: Dictionary = item["Data"]
	if not data.has(DataKeys.GEM) or not (data[DataKeys.GEM] is Array):
		data[DataKeys.GEM] = []
	(
		(mosaic_value as Array)
		. push_back(
			{
				"名字": item_id,
				"强化等级": int(item.get(DataKeys.ENHANCE_LEVEL, 0)),
				"Data": data,
				"来源": "宠物背包",
				"位置": index,
				"宠物装备": item,
			}
		)
	)
	shared.remove_at(index)
	return true


func take_equipped_equipment_for_mosaic(
	slot_type: String, expected_name: String, _expected_data: Dictionary
) -> Dictionary:
	var mosaic_value: Variant = player_data.get(DataKeys.INLAY_LIST, [])
	if not (mosaic_value is Array) or not (mosaic_value as Array).is_empty():
		return {}
	if slot_type == "":
		return {}
	var equipped_value: Variant = player_data.get(slot_type, [])
	if not (equipped_value is Array) or (equipped_value as Array).is_empty():
		return {}
	var equipped: Array = equipped_value
	var item_value: Variant = equipped[0]
	if not (item_value is Dictionary):
		return {}
	var item: Dictionary = item_value
	if str(item.get(DataKeys.NAME, "")) != expected_name:
		return {}

	var data: Dictionary = {}
	var data_value: Variant = item.get("Data", {})
	if data_value is Dictionary:
		data = (data_value as Dictionary).duplicate(true)
	if not data.has(DataKeys.GEM) or not (data[DataKeys.GEM] is Array):
		data[DataKeys.GEM] = []
	var stored_item: Dictionary = item.duplicate(true)
	stored_item["Data"] = data
	(
		(mosaic_value as Array)
		. push_back(
			{
				"名字": expected_name,
				"强化等级": int(item.get(DataKeys.ENHANCE_LEVEL, 0)),
				"Data": data,
				"来源": "人物穿戴",
				"位置": 0,
				"穿戴栏": slot_type,
				"穿戴装备": stored_item,
			}
		)
	)
	equipped.clear()
	RoleProp.get_equ_last_pro()
	RoleProp.get_last_prop()
	if is_instance_valid(RoleProp.source_player):
		RoleProp.source_player.on_eqchange()
	return stored_item


func restore_mosaic_equipment() -> bool:
	var mosaic_value: Variant = player_data.get(DataKeys.INLAY_LIST, [])
	if not (mosaic_value is Array) or (mosaic_value as Array).is_empty():
		return false
	var mosaic_list: Array = mosaic_value
	var selected_value: Variant = mosaic_list[0]
	if not (selected_value is Dictionary):
		mosaic_list.clear()
		return false
	var selected: Dictionary = selected_value
	if str(selected.get("来源", "装备背包")) == "宠物背包":
		var item_value: Variant = selected.get("宠物装备", {})
		if item_value is Dictionary:
			var item: Dictionary = item_value
			var data_value: Variant = selected.get("Data", {})
			if data_value is Dictionary:
				item["Data"] = data_value
			item[DataKeys.ENHANCE_LEVEL] = int(
				selected.get(DataKeys.ENHANCE_LEVEL, item.get(DataKeys.ENHANCE_LEVEL, 0))
			)
			var shared := ensure_shared_pet_backpack()
			var already_returned := false
			for shared_item in shared:
				if is_same(shared_item, item):
					already_returned = true
					break
			if not already_returned:
				var original_index := clampi(int(selected.get("位置", shared.size())), 0, shared.size())
				shared.insert(original_index, item)
	elif str(selected.get("来源", "装备背包")) == "人物穿戴":
		var slot_type := str(selected.get("穿戴栏", ""))
		var restored_item: Dictionary = {}
		var item_value: Variant = selected.get("穿戴装备", {})
		if item_value is Dictionary:
			restored_item = (item_value as Dictionary).duplicate(true)
		restored_item[DataKeys.NAME] = str(selected.get(DataKeys.NAME, restored_item.get(DataKeys.NAME, "")))
		restored_item[DataKeys.ENHANCE_LEVEL] = int(
			selected.get(DataKeys.ENHANCE_LEVEL, restored_item.get(DataKeys.ENHANCE_LEVEL, 0))
		)
		var data_value: Variant = selected.get("Data", restored_item.get("Data", {}))
		restored_item["Data"] = (data_value as Dictionary).duplicate(true) if data_value is Dictionary else {}
		if slot_type != "":
			if not player_data.has(slot_type) or not (player_data[slot_type] is Array):
				player_data[slot_type] = []
			var equipped: Array = player_data[slot_type]
			if equipped.is_empty():
				equipped.push_back(restored_item)
			elif (
				equipped[0] is Dictionary
				and str(equipped[0].get(DataKeys.NAME, "")) == str(restored_item.get(DataKeys.NAME, ""))
			):
				equipped[0] = restored_item
			else:
				add_zb(
					str(restored_item.get(DataKeys.NAME, "")),
					int(restored_item.get(DataKeys.ENHANCE_LEVEL, 0)),
					restored_item.get("Data", {})
				)
		else:
			add_zb(
				str(restored_item.get(DataKeys.NAME, "")),
				int(restored_item.get(DataKeys.ENHANCE_LEVEL, 0)),
				restored_item.get("Data", {})
			)
		RoleProp.get_equ_last_pro()
		RoleProp.get_last_prop()
		if is_instance_valid(RoleProp.source_player):
			RoleProp.source_player.on_eqchange()
	else:
		add_zb(
			str(selected.get(DataKeys.NAME, "")), int(selected.get(DataKeys.ENHANCE_LEVEL, 0)), selected.get("Data", {})
		)
	mosaic_list.clear()
	return true


func _pet_equipment_random_stats_from_sources(sources: Array) -> Array:
	for source_value in sources:
		if not (source_value is Dictionary):
			continue
		var source: Dictionary = source_value
		for key in [PET_EQUIPMENT_RANDOM_STAT_KEY, "RandomStats", "random_stats"]:
			var random_value: Variant = source.get(key, null)
			if random_value is Array:
				return random_value as Array
	return []


func _pet_equipment_random_stat_total(random_stats: Array, aliases: Array, level: int) -> float:
	var total := 0.0
	for random_value in random_stats:
		if not (random_value is Dictionary):
			continue
		var random_stat: Dictionary = random_value
		var stat_key := str(
			random_stat.get("属性", random_stat.get("属性名", random_stat.get("stat", random_stat.get("key", ""))))
		)
		if not _pet_equipment_key_matches_aliases(stat_key, aliases):
			continue
		var base_value := _pet_equipment_numeric_value(
			random_stat.get("数值", random_stat.get("基础值", random_stat.get("value", random_stat.get("base", 0))))
		)
		var strengthen_value := _pet_equipment_numeric_value(
			random_stat.get(DataKeys.ENHANCE_PROP, random_stat.get("强化值", random_stat.get("strength", 0)))
		)
		total += base_value + strengthen_value * level
	return total


func _pet_equipment_key_matches_aliases(stat_key: String, aliases: Array) -> bool:
	if stat_key.strip_edges() == "":
		return false
	for alias in aliases:
		if str(alias).to_lower() == stat_key.to_lower():
			return true
	return false


func _pet_equipment_number_from_sources(sources: Array, aliases: Array) -> float:
	for source_value in sources:
		if not (source_value is Dictionary):
			continue
		var source: Dictionary = source_value
		for alias in aliases:
			if not source.has(alias):
				continue
			var value: Variant = source.get(alias, 0)
			if typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT:
				return float(value)
			if value is String and (value as String).strip_edges().is_valid_float():
				return float(value)
	return 0.0


func _pet_equipment_strength_from_sources(sources: Array, aliases: Array) -> float:
	for source_value in sources:
		if not (source_value is Dictionary):
			continue
		var source: Dictionary = source_value
		var strengthen_value: Variant = source.get(DataKeys.ENHANCE_PROP, {})
		if not (strengthen_value is Dictionary):
			continue
		var value := _pet_equipment_number_from_sources([strengthen_value], aliases)
		if not is_zero_approx(value):
			return value
	return 0.0


func _pet_equipment_level_from_sources(sources: Array) -> int:
	var item: Dictionary = sources[0] if not sources.is_empty() and sources[0] is Dictionary else {}
	var max_level := get_equipment_strength_max_level(item)
	for source_value in sources:
		if not (source_value is Dictionary):
			continue
		var source: Dictionary = source_value
		for key in ["强化等级", "强化级别", "强化"]:
			if not source.has(key):
				continue
			var value: Variant = source.get(key, 0)
			var level := int(value) if typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT else 0
			if value is String and (value as String).strip_edges().is_valid_int():
				level = int(value)
			return clampi(level, 0, max_level)
	return 0


func _is_retired_test_pet_equipment(value: Variant) -> bool:
	if not (value is Dictionary):
		return false
	var item: Dictionary = value
	var data_value: Variant = item.get("Data", {})
	var data: Dictionary = data_value if data_value is Dictionary else {}
	return (
		str(
			item.get(
				DataKeys.NAME, item.get(DataKeys.ALT_NAME, data.get(DataKeys.NAME, data.get(DataKeys.ALT_NAME, "")))
			)
		)
		== "宠物护符"
	)


func get_capped_player_level() -> int:
	return clampi(int(player_data.get(DataKeys.PLAYER_LEVEL, 1)), 1, PLAYER_MAX_LEVEL)


func enforce_level_caps() -> void:
	var player_level := get_capped_player_level()
	player_data[DataKeys.PLAYER_LEVEL] = player_level
	player_data["玩家当前经验"] = 0 if player_level >= PLAYER_MAX_LEVEL else max(0, int(player_data.get("玩家当前经验", 0)))
	var pets_value: Variant = player_data.get(PET_LIST_KEY, [])
	if not (pets_value is Array):
		return
	for pet_value in pets_value:
		if pet_value is Dictionary:
			clamp_pet_level_to_player(pet_value, player_level)


func clamp_pet_level_to_player(pet: Dictionary, player_level: int = -1) -> bool:
	var level_limit := get_capped_player_level() if player_level < 1 else clampi(player_level, 1, PLAYER_MAX_LEVEL)
	var previous_level := int(pet.get(DataKeys.LEVEL, 1))
	var pet_level := clampi(previous_level, 1, level_limit)
	pet[DataKeys.LEVEL] = pet_level
	var next_exp := _pet_level_exp_requirement(pet_level)
	pet["下级经验"] = next_exp
	if pet.has("经验上限"):
		pet["经验上限"] = next_exp
	if pet_level >= level_limit:
		pet[DataKeys.EXP] = 0
	else:
		pet[DataKeys.EXP] = max(0, int(pet.get(DataKeys.EXP, 0)))
	if pet_level != previous_level:
		_recalculate_pet_stats_after_level_clamp(pet)
		return true
	return false


func _pet_level_exp_requirement(level: int) -> int:
	var max_exp_list := [
		140, 160, 180, 200, 220, 300, 400, 500, 600, 700, 800, 900, 1200, 1400, 1600, 2000, 2400, 3000, 4000, 5000
	]
	var safe_level: int = maxi(1, level)
	var role_exp: int = int(max_exp_list[safe_level - 1]) if safe_level < 20 else 5000 + 5000 * (safe_level - 19)
	return max(1, int(ceil(float(role_exp) * 0.6)))


func _recalculate_pet_stats_after_level_clamp(pet: Dictionary) -> void:
	var level_count: int = maxi(0, int(pet.get(DataKeys.LEVEL, 1)) - 1)
	var hp_gain: int = int(round(float(pet.get("生命资质", 1000)) * 0.09))
	var mp_gain: int = int(round(float(pet.get("魔法资质", 1000)) * 0.04))
	var attack_gain: int = int(round(float(pet.get("攻击资质", 1000)) * 0.02))
	var defense_gain: int = int(round(float(pet.get("防御资质", 1000)) * 0.007))
	var hp_recover_gain: int = int(round(float(pet.get("生命资质", 1000)) * 0.001))
	var mp_recover_gain: int = int(round(float(pet.get("魔法资质", 1000)) * 0.001))
	var new_hp_max: int = 620 + level_count * hp_gain
	var new_mp_max: int = 180 + level_count * mp_gain
	pet["生命上限"] = new_hp_max
	pet["魔法上限"] = new_mp_max
	pet[DataKeys.ATTACK] = 65 + level_count * attack_gain
	pet[DataKeys.DEFENSE] = 60 + level_count * defense_gain
	pet["物防"] = int(pet[DataKeys.DEFENSE])
	pet["防"] = int(pet[DataKeys.DEFENSE])
	pet["魔抗"] = int(pet[DataKeys.DEFENSE])
	pet["魔防"] = int(pet[DataKeys.DEFENSE])
	pet["回血"] = 2 + level_count * hp_recover_gain
	pet["回魔"] = 1 + level_count * mp_recover_gain
	pet[DataKeys.HP] = (
		new_hp_max
		if int(pet.get(DataKeys.HP, new_hp_max)) <= 0
		else clampi(int(pet.get(DataKeys.HP, new_hp_max)), 0, new_hp_max)
	)
	pet[DataKeys.MP] = (
		new_mp_max
		if int(pet.get(DataKeys.MP, new_mp_max)) <= 0
		else clampi(int(pet.get(DataKeys.MP, new_mp_max)), 0, new_mp_max)
	)


func ensure_main_sword_array() -> void:
	var coop := get_node_or_null("/root/LocalCoop")
	if coop != null and coop.is_enabled():
		coop.link_main_sword_array()
	if not player_data.has(MAIN_SWORD_ARRAY_KEY):
		player_data[MAIN_SWORD_ARRAY_KEY] = MAIN_SWORD_ARRAY_DEFAULT
	if not player_data.has(MAIN_SWORD_ARRAY_LEVEL_KEY) or not (player_data[MAIN_SWORD_ARRAY_LEVEL_KEY] is Dictionary):
		player_data[MAIN_SWORD_ARRAY_LEVEL_KEY] = MAIN_SWORD_ARRAY_LEVEL_DEFAULT.duplicate(true)
	var levels: Dictionary = player_data[MAIN_SWORD_ARRAY_LEVEL_KEY]
	for sword_id in MAIN_SWORD_ARRAY_LEVEL_DEFAULT.keys():
		if not levels.has(sword_id):
			levels[sword_id] = 0
		levels[sword_id] = max(0, int(levels[sword_id]))
	var active := str(player_data.get(MAIN_SWORD_ARRAY_KEY, ""))
	var active_level := 0
	if active == "sijianheyi":
		active_level = min(
			int(levels.get("zhuxianjian", 0)),
			int(levels.get("xianxianjian", 0)),
			int(levels.get("luxianjian", 0)),
			int(levels.get("juexianjian", 0))
		)
	elif levels.has(active):
		active_level = int(levels.get(active, 0))
	if not MAIN_SWORD_ARRAY_IDS.has(active) or (active != "" and active_level < 1):
		player_data[MAIN_SWORD_ARRAY_KEY] = MAIN_SWORD_ARRAY_DEFAULT


func get_main_sword_array_level(sword_id: String) -> int:
	ensure_main_sword_array()
	var levels: Dictionary = player_data[MAIN_SWORD_ARRAY_LEVEL_KEY]
	if sword_id == "sijianheyi":
		return min(
			int(levels.get("zhuxianjian", 0)),
			int(levels.get("xianxianjian", 0)),
			int(levels.get("luxianjian", 0)),
			int(levels.get("juexianjian", 0))
		)
	return int(levels.get(sword_id, 0))


func can_main_sword_array_battle(sword_id: String) -> bool:
	if sword_id == "" or not MAIN_SWORD_ARRAY_IDS.has(sword_id):
		return false
	return get_main_sword_array_level(sword_id) >= 1


func ensure_skill_data() -> void:
	var skill_data: Variant = player_data.get(DataKeys.SKILL_LEARNED, {})
	if not (skill_data is Dictionary):
		skill_data = {}
		player_data[DataKeys.SKILL_LEARNED] = skill_data
	for skill_number in range(1, 14):
		var skill_key := "技能" + str(skill_number)
		if not skill_data.has(skill_key) or not (skill_data[skill_key] is Dictionary):
			skill_data[skill_key] = {"学习": 0, "等级": 0}
		else:
			if not skill_data[skill_key].has("学习"):
				skill_data[skill_key]["学习"] = 0
			if not skill_data[skill_key].has(DataKeys.LEVEL):
				skill_data[skill_key][DataKeys.LEVEL] = 0
	if not skill_data.has("技能键位") or not (skill_data["技能键位"] is Dictionary):
		skill_data["技能键位"] = {"Y": "", "U": "", "I": "", "O": "", "L": ""}


func ensure_special_dungeon_progress() -> void:
	var defaults := {
		"玲珑宝塔": 0,
		"玲珑宝塔层数": 0,
		"兜率宫": 0,
		"兜率宫层数": 0,
		"兜率宫1": 0,
		"兜率宫2": 0,
		"兜率宫3": 0,
		"兜率宫4": 0,
		"兜率宫5": 0,
		"地府噩梦": false,
	}
	for key in defaults.keys():
		if not player_data.has(key):
			player_data[key] = defaults[key]
	if not (player_data.get("关卡评价", {}) is Dictionary):
		player_data["关卡评价"] = {}
	for key in ["玲珑宝塔", "兜率宫"]:
		if not player_data["关卡评价"].has(key):
			player_data["关卡评价"][key] = 0

	var constellation_value: Variant = player_data.get(CONSTELLATION_PROGRESS_KEY, {})
	var constellation_progress: Dictionary = constellation_value if constellation_value is Dictionary else {}
	for constellation_level in range(1, 15):
		var constellation_key := str(constellation_level)
		constellation_progress[constellation_key] = clampi(int(constellation_progress.get(constellation_key, 0)), 0, 10)
	player_data[CONSTELLATION_PROGRESS_KEY] = constellation_progress

	var level_ratings: Dictionary = player_data["关卡评价"]
	var highest_cleared_index := -1
	for index in range(MAP5_PROGRESSION_LEVELS.size()):
		var level_name: String = MAP5_PROGRESSION_LEVELS[index]
		if not player_data.has(level_name):
			player_data[level_name] = 0
		if int(player_data.get(level_name, 0)) > 0 or int(level_ratings.get(level_name, 0)) > 0:
			highest_cleared_index = index
	for index in range(highest_cleared_index + 1):
		player_data[MAP5_PROGRESSION_LEVELS[index]] = 1


func get_constellation_highest_defeated_tier(constellation_level: int) -> int:
	ensure_special_dungeon_progress()
	var progress: Dictionary = player_data[CONSTELLATION_PROGRESS_KEY]
	return clampi(int(progress.get(str(clampi(constellation_level, 1, 14)), 0)), 0, 10)


func record_constellation_defeated_tier(constellation_level: int, tier: int) -> bool:
	ensure_special_dungeon_progress()
	var progress: Dictionary = player_data[CONSTELLATION_PROGRESS_KEY]
	var key := str(clampi(constellation_level, 1, 14))
	var previous := clampi(int(progress.get(key, 0)), 0, 10)
	var updated := maxi(previous, clampi(tier, 0, 10))
	progress[key] = updated
	return updated > previous


func _remove_retired_wudu_magic_weapons() -> void:
	if str(player_data.get("实战法宝", "")) in RETIRED_WUDU_MAGIC_WEAPONS:
		player_data["实战法宝"] = ""
	if player_data.get(DataKeys.MAGIC_WEAPON, []) is Array:
		for index in range(player_data[DataKeys.MAGIC_WEAPON].size() - 1, -1, -1):
			var item = player_data[DataKeys.MAGIC_WEAPON][index]
			if item is Dictionary and str(item.get(DataKeys.NAME, "")) in RETIRED_WUDU_MAGIC_WEAPONS:
				player_data[DataKeys.MAGIC_WEAPON].remove_at(index)
	var equipment_pages = player_data.get(DataKeys.EQUIPMENT_LIST, {})
	if equipment_pages is Dictionary:
		for page in equipment_pages.values():
			if not (page is Array):
				continue
			for index in range(page.size() - 1, -1, -1):
				var item = page[index]
				if item is Dictionary and str(item.get(DataKeys.NAME, "")) in RETIRED_WUDU_MAGIC_WEAPONS:
					page.remove_at(index)
	_migrate_retired_xianyu_equipment()


func _is_removed_equipment_id(item_id: String) -> bool:
	return RETIRED_CLASSIC_ORIGINAL_EQUIPMENT.has(item_id) or RETIRED_MERCHANT_FASHION_QUALITIES.has(item_id)


func _remove_retired_classic_and_merchant_equipment() -> void:
	for slot_name in ["武器", "防具", "饰品", "翅膀", "头衔", "时装", "法宝"]:
		var slot_items = player_data.get(slot_name, [])
		if slot_items is Array:
			_remove_retired_equipment_items(slot_items)

	var equipment_pages = player_data.get(DataKeys.EQUIPMENT_LIST, {})
	if equipment_pages is Dictionary:
		for page in equipment_pages.values():
			if page is Array:
				_remove_retired_equipment_items(page)

	var transmog = player_data.get(DataKeys.TRANSMOG_LIST, {})
	if transmog is Dictionary:
		for key in transmog.keys():
			if _is_removed_equipment_id(str(transmog[key])):
				transmog[key] = ""

	var owned = player_data.get("幻化拥有列表", [])
	if owned is Array:
		for index in range(owned.size() - 1, -1, -1):
			if _is_removed_equipment_id(str(owned[index])):
				owned.remove_at(index)


func _remove_retired_equipment_items(items: Array) -> void:
	for index in range(items.size() - 1, -1, -1):
		var item = items[index]
		if item is Dictionary and _is_removed_equipment_id(str(item.get(DataKeys.NAME, ""))):
			items.remove_at(index)


func _migrate_retired_xianyu_equipment() -> void:
	_migrate_retired_xianyu_transmog()
	for slot_name in ["武器", "防具", "饰品", "翅膀", "头衔", "时装", "法宝"]:
		var slot_items = player_data.get(slot_name, [])
		if slot_items is Array:
			_migrate_retired_xianyu_item_array(slot_items)
	var equipment_pages = player_data.get(DataKeys.EQUIPMENT_LIST, {})
	if equipment_pages is Dictionary:
		for page in equipment_pages.values():
			if page is Array:
				_migrate_retired_xianyu_item_array(page)


func _migrate_retired_xianyu_transmog() -> void:
	var transmog = player_data.get(DataKeys.TRANSMOG_LIST, {})
	if transmog is Dictionary:
		for key in transmog.keys():
			var old_id := str(transmog[key])
			if RETIRED_XIANYU_EQUIPMENT_MAP.has(old_id):
				transmog[key] = RETIRED_XIANYU_EQUIPMENT_MAP[old_id]
			elif old_id in RETIRED_XIANYU_REMOVE_IDS:
				transmog[key] = ""
	var owned = player_data.get("幻化拥有列表", [])
	if owned is Array:
		for index in range(owned.size() - 1, -1, -1):
			var old_id := str(owned[index])
			if RETIRED_XIANYU_EQUIPMENT_MAP.has(old_id):
				var new_id = RETIRED_XIANYU_EQUIPMENT_MAP[old_id]
				if owned.has(new_id):
					owned.remove_at(index)
				else:
					owned[index] = new_id
			elif old_id in RETIRED_XIANYU_REMOVE_IDS:
				owned.remove_at(index)


func _migrate_retired_xianyu_item_array(items: Array) -> void:
	for index in range(items.size() - 1, -1, -1):
		var item = items[index]
		if not (item is Dictionary):
			continue
		var old_id := str(item.get(DataKeys.NAME, ""))
		if old_id in RETIRED_XIANYU_REMOVE_IDS:
			items.remove_at(index)
		elif RETIRED_XIANYU_EQUIPMENT_MAP.has(old_id):
			_replace_retired_xianyu_item_data(item, RETIRED_XIANYU_EQUIPMENT_MAP[old_id])


func _replace_retired_xianyu_item_data(item: Dictionary, new_id: String) -> void:
	if not AE.all_equipment.has(new_id):
		return
	var old_data = item.get("Data", {})
	var new_data = AE.all_equipment[new_id].duplicate(true)
	if old_data is Dictionary and old_data.has(DataKeys.GEM):
		new_data[DataKeys.GEM] = old_data[DataKeys.GEM].duplicate(true)
	item[DataKeys.NAME] = new_id
	item["Data"] = new_data


func ensure_pet_tiger() -> bool:
	if not (player_data.get(PET_LIST_KEY, []) is Array):
		player_data[PET_LIST_KEY] = []
	var pets: Array = player_data[PET_LIST_KEY]
	var has_tiger := false
	for pet in pets:
		if not (pet is Dictionary):
			continue
		_normalize_pet_passives(pet)
		if _is_pet_tiger(pet):
			_normalize_pet_tiger(pet)
			has_tiger = true
	if not has_tiger:
		var tiger := PET_TIGER_PET.duplicate(true)
		_normalize_pet_passives(tiger)
		pets.append(tiger)
	if not player_data.has(ACTIVE_PET_KEY):
		player_data[ACTIVE_PET_KEY] = ""
	return not has_tiger


func _normalize_pet_passives(pet: Dictionary) -> void:
	if not pet.has("被动技能") or not (pet["被动技能"] is Dictionary):
		pet["被动技能"] = {}
	var levels: Dictionary = pet["被动技能"]
	for skill_name in ["热血", "魔泉", "狂暴", "永恒", "辉煌", "敏锐"]:
		levels[skill_name] = max(0, int(levels.get(skill_name, 0)))


func _is_pet_tiger(pet: Dictionary) -> bool:
	if str(pet.get(DataKeys.TYPE, "")) == "PetTiger":
		return true
	var name := str(pet.get(DataKeys.ALT_NAME, ""))
	return name == "虎丸" or name == "白灵虎" or name == "白虎将军" or name == "白虎战神" or name == "白虎"


func _normalize_pet_tiger(pet: Dictionary) -> void:
	var tiger_data := PET_TIGER_PET.duplicate(true)
	var keep_fighting := bool(pet.get(DataKeys.DEPLOYED, false))
	for key in tiger_data.keys():
		if not pet.has(key):
			pet[key] = (
				tiger_data[key].duplicate(true)
				if tiger_data[key] is Dictionary or tiger_data[key] is Array
				else tiger_data[key]
			)
	pet["悟性"] = clampi(int(pet.get("悟性", 0)), 0, 25)
	pet["根骨"] = clampi(int(pet.get("根骨", 0)), 0, 25)
	pet["灵力"] = clampi(int(pet.get("灵力", 0)), 0, 25)
	var wisdom_bonus: int = int(pet["悟性"]) * 100
	pet["生命资质基础上限"] = 2500
	pet["魔法资质基础上限"] = 1800
	pet["攻击资质基础上限"] = 2500
	pet["防御资质基础上限"] = 1800
	pet["生命资质上限"] = 2500 + wisdom_bonus
	pet["魔法资质上限"] = 1800 + wisdom_bonus
	pet["攻击资质上限"] = 2500 + wisdom_bonus
	pet["防御资质上限"] = 1800 + wisdom_bonus
	pet["生命资质"] = clampi(int(pet.get("生命资质", 1000)), 0, int(pet["生命资质上限"]))
	pet["魔法资质"] = clampi(int(pet.get("魔法资质", 1000)), 0, int(pet["魔法资质上限"]))
	pet["攻击资质"] = clampi(int(pet.get("攻击资质", 1000)), 0, int(pet["攻击资质上限"]))
	pet["防御资质"] = clampi(int(pet.get("防御资质", 1000)), 0, int(pet["防御资质上限"]))
	pet[DataKeys.TYPE] = "PetTiger"
	pet[DataKeys.DEPLOYED] = keep_fighting


func ensure_pet_dragon() -> bool:
	if not (player_data.get(PET_LIST_KEY, []) is Array):
		player_data[PET_LIST_KEY] = []
	var pets: Array = player_data[PET_LIST_KEY]
	var has_dragon := false
	for pet in pets:
		if not (pet is Dictionary):
			continue
		_normalize_pet_passives(pet)
		if _is_pet_dragon(pet):
			_normalize_pet_dragon(pet)
			has_dragon = true
	if not has_dragon:
		var dragon := PET_DRAGON_PET.duplicate(true)
		_normalize_pet_passives(dragon)
		pets.append(dragon)
	if not player_data.has(ACTIVE_PET_KEY):
		player_data[ACTIVE_PET_KEY] = ""
	return not has_dragon


func _is_pet_dragon(pet: Dictionary) -> bool:
	var pet_name := str(pet.get(DataKeys.ALT_NAME, ""))
	var pet_title := str(pet.get(DataKeys.NAME, ""))
	if _is_pet_phoenix_name(pet_name) or _is_pet_phoenix_name(pet_title):
		return false
	if str(pet.get(DataKeys.TYPE, "")) == "PetDragon":
		return true
	return pet_name.begins_with("辰龙") or PET_DRAGON_STAGE_NAMES.values().has(pet_name)


func _normalize_pet_dragon(pet: Dictionary) -> void:
	var dragon_data := PET_DRAGON_PET.duplicate(true)
	var keep_fighting := bool(pet.get(DataKeys.DEPLOYED, false))
	for key in dragon_data.keys():
		if not pet.has(key):
			pet[key] = (
				dragon_data[key].duplicate(true)
				if dragon_data[key] is Dictionary or dragon_data[key] is Array
				else dragon_data[key]
			)
	pet["悟性"] = clampi(int(pet.get("悟性", 0)), 0, 25)
	pet["根骨"] = clampi(int(pet.get("根骨", 0)), 0, 25)
	pet["灵力"] = clampi(int(pet.get("灵力", 0)), 0, 25)
	var wisdom_bonus := int(pet["悟性"]) * 100
	pet["生命资质基础上限"] = 2500
	pet["魔法资质基础上限"] = 1800
	pet["攻击资质基础上限"] = 3000
	pet["防御资质基础上限"] = 1800
	pet["生命资质上限"] = 2500 + wisdom_bonus
	pet["魔法资质上限"] = 1800 + wisdom_bonus
	pet["攻击资质上限"] = 3000 + wisdom_bonus
	pet["防御资质上限"] = 1800 + wisdom_bonus
	pet[DataKeys.TYPE] = "PetDragon"
	var dragon_level := int(pet.get(DataKeys.LEVEL, 1))
	var dragon_stage := 4 if dragon_level >= 50 else 3 if dragon_level >= 30 else 2 if dragon_level >= 15 else 1
	pet["阶段"] = dragon_stage
	pet[DataKeys.ALT_NAME] = str(PET_DRAGON_STAGE_NAMES[dragon_stage])
	pet["技能"] = (PET_DRAGON_STAGE_SKILLS.get(dragon_stage, []) as Array).duplicate(true)
	if bool(pet.get(DataKeys.DEPLOYED, false)):
		var active_name := str(player_data.get(ACTIVE_PET_KEY, ""))
		if active_name == "" or active_name == "PetDragon" or PET_DRAGON_STAGE_NAMES.values().has(active_name):
			player_data[ACTIVE_PET_KEY] = "PetDragon"
	if not PET_DRAGON_STAGE_NAMES.values().has(str(pet.get(DataKeys.ALT_NAME, ""))):
		pet[DataKeys.ALT_NAME] = str(dragon_data.get(DataKeys.ALT_NAME, "龙仔"))
	pet[DataKeys.DEPLOYED] = keep_fighting or bool(pet.get(DataKeys.DEPLOYED, false))


func ensure_pet_turtle() -> bool:
	if not (player_data.get(PET_LIST_KEY, []) is Array):
		player_data[PET_LIST_KEY] = []
	var pets: Array = player_data[PET_LIST_KEY]
	var has_turtle := false
	for pet in pets:
		if not (pet is Dictionary):
			continue
		_normalize_pet_passives(pet)
		if _is_pet_turtle(pet):
			_normalize_pet_turtle(pet)
			has_turtle = true
	if not has_turtle:
		var turtle := PET_TURTLE_PET.duplicate(true)
		_normalize_pet_passives(turtle)
		pets.append(turtle)
	if not player_data.has(ACTIVE_PET_KEY):
		player_data[ACTIVE_PET_KEY] = ""
	return not has_turtle


func _is_pet_turtle(pet: Dictionary) -> bool:
	if str(pet.get(DataKeys.TYPE, "")) == "PetTurtle":
		return true
	var pet_name := str(pet.get(DataKeys.ALT_NAME, pet.get(DataKeys.NAME, ""))).strip_edges()
	return PET_TURTLE_STAGE_NAMES.values().has(pet_name) or pet_name.begins_with("玄武")


func _normalize_pet_turtle(pet: Dictionary) -> void:
	var turtle_data := PET_TURTLE_PET.duplicate(true)
	var keep_fighting := (
		bool(pet.get(DataKeys.DEPLOYED, false)) or str(player_data.get(ACTIVE_PET_KEY, "")) == "PetTurtle"
	)
	for key in turtle_data.keys():
		if not pet.has(key):
			pet[key] = (
				turtle_data[key].duplicate(true)
				if turtle_data[key] is Dictionary or turtle_data[key] is Array
				else turtle_data[key]
			)
	pet["悟性"] = clampi(int(pet.get("悟性", 0)), 0, 25)
	pet["根骨"] = clampi(int(pet.get("根骨", 0)), 0, 25)
	pet["灵力"] = clampi(int(pet.get("灵力", 0)), 0, 25)
	var wisdom_bonus := int(pet["悟性"]) * 100
	pet["生命资质基础上限"] = 4000
	pet["魔法资质基础上限"] = 1800
	pet["攻击资质基础上限"] = 1500
	pet["防御资质基础上限"] = 4000
	pet["生命资质上限"] = 4000 + wisdom_bonus
	pet["魔法资质上限"] = 1800 + wisdom_bonus
	pet["攻击资质上限"] = 1500 + wisdom_bonus
	pet["防御资质上限"] = 4000 + wisdom_bonus
	pet["生命资质"] = clampi(int(pet.get("生命资质", 1000)), 0, int(pet["生命资质上限"]))
	pet["魔法资质"] = clampi(int(pet.get("魔法资质", 1000)), 0, int(pet["魔法资质上限"]))
	pet["攻击资质"] = clampi(int(pet.get("攻击资质", 1000)), 0, int(pet["攻击资质上限"]))
	pet["防御资质"] = clampi(int(pet.get("防御资质", 1000)), 0, int(pet["防御资质上限"]))
	var turtle_level := int(pet.get(DataKeys.LEVEL, 1))
	var stage := 4 if turtle_level >= 50 else 3 if turtle_level >= 30 else 2 if turtle_level >= 15 else 1
	pet[DataKeys.TYPE] = "PetTurtle"
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = str(PET_TURTLE_STAGE_NAMES[stage])
	pet[DataKeys.NAME] = str(PET_TURTLE_STAGE_NAMES[stage])
	pet["技能"] = (PET_TURTLE_STAGE_SKILLS[stage] as Array).duplicate(true)
	pet[DataKeys.DEPLOYED] = keep_fighting
	if keep_fighting:
		player_data[ACTIVE_PET_KEY] = "PetTurtle"


func ensure_pet_rabbit() -> bool:
	if not (player_data.get(PET_LIST_KEY, []) is Array):
		player_data[PET_LIST_KEY] = []
	var pets: Array = player_data[PET_LIST_KEY]
	var found := false
	for pet in pets:
		if pet is Dictionary and _is_pet_rabbit(pet):
			_normalize_pet_passives(pet)
			_normalize_pet_rabbit(pet)
			found = true

	if found:
		player_data[PET_RABBIT_UNLOCK_KEY] = true
	elif bool(player_data.get(PET_RABBIT_UNLOCK_KEY, false)):
		var rabbit := PET_RABBIT_PET.duplicate(true)
		_normalize_pet_passives(rabbit)
		pets.append(rabbit)
	if not player_data.has(ACTIVE_PET_KEY):
		player_data[ACTIVE_PET_KEY] = ""
	return not found and bool(player_data.get(PET_RABBIT_UNLOCK_KEY, false))


func is_pet_rabbit_unlocked() -> bool:
	if bool(player_data.get(PET_RABBIT_UNLOCK_KEY, false)):
		return true
	var pets_value: Variant = player_data.get(PET_LIST_KEY, [])
	if pets_value is Array:
		for pet_value in pets_value:
			if pet_value is Dictionary and _is_pet_rabbit(pet_value):
				player_data[PET_RABBIT_UNLOCK_KEY] = true
				return true
	return false


func unlock_pet_rabbit() -> bool:
	if is_pet_rabbit_unlocked():
		ensure_pet_rabbit()
		return false
	player_data[PET_RABBIT_UNLOCK_KEY] = true
	ensure_pet_rabbit()
	return true


func _is_pet_rabbit(pet: Dictionary) -> bool:
	if str(pet.get(DataKeys.TYPE, "")) == "PetRabbit":
		return true
	var pet_name := str(pet.get(DataKeys.ALT_NAME, pet.get(DataKeys.NAME, ""))).strip_edges()
	return PET_RABBIT_STAGE_NAMES.values().has(pet_name)


func _normalize_pet_rabbit(pet: Dictionary) -> void:
	var base := PET_RABBIT_PET.duplicate(true)
	var keep_fighting := (
		bool(pet.get(DataKeys.DEPLOYED, false)) or str(player_data.get(ACTIVE_PET_KEY, "")) == "PetRabbit"
	)
	for key in base.keys():
		if not pet.has(key):
			pet[key] = base[key].duplicate(true) if base[key] is Dictionary or base[key] is Array else base[key]
	pet["悟性"] = clampi(int(pet.get("悟性", 0)), 0, 25)
	pet["根骨"] = clampi(int(pet.get("根骨", 0)), 0, 25)
	pet["灵力"] = clampi(int(pet.get("灵力", 0)), 0, 25)
	var wisdom_bonus := int(pet["悟性"]) * 100
	pet["生命资质基础上限"] = 2500
	pet["魔法资质基础上限"] = 3000
	pet["攻击资质基础上限"] = 2800
	pet["防御资质基础上限"] = 1800
	for key in ["生命资质", "魔法资质", "攻击资质", "防御资质"]:
		var base_max := int(pet[str(key) + "基础上限"])
		pet[str(key) + "上限"] = base_max + wisdom_bonus
		pet[key] = clampi(int(pet.get(key, 1000)), 0, int(pet[str(key) + "上限"]))
	var pet_level := int(pet.get(DataKeys.LEVEL, 1))
	var stage := 4 if pet_level >= 50 else 3 if pet_level >= 30 else 2 if pet_level >= 15 else 1
	pet[DataKeys.TYPE] = "PetRabbit"
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = str(PET_RABBIT_STAGE_NAMES[stage])
	pet[DataKeys.NAME] = str(PET_RABBIT_STAGE_NAMES[stage])
	pet["技能"] = (PET_RABBIT_STAGE_SKILLS[stage] as Array).duplicate(true)
	pet[DataKeys.DEPLOYED] = keep_fighting
	if keep_fighting:
		player_data[ACTIVE_PET_KEY] = "PetRabbit"


func ensure_pet_mouse() -> bool:
	if not (player_data.get(PET_LIST_KEY, []) is Array):
		player_data[PET_LIST_KEY] = []
	var pets: Array = player_data[PET_LIST_KEY]
	var found := false
	for pet in pets:
		if not (pet is Dictionary):
			continue
		_normalize_pet_passives(pet)
		if _is_pet_mouse(pet):
			_normalize_pet_mouse(pet)
			found = true
	if not found:
		var mouse := PET_MOUSE_PET.duplicate(true)
		_normalize_pet_passives(mouse)
		pets.append(mouse)
	if not player_data.has(ACTIVE_PET_KEY):
		player_data[ACTIVE_PET_KEY] = ""
	return not found


func _is_pet_mouse(pet: Dictionary) -> bool:
	if str(pet.get(DataKeys.TYPE, "")) == "PetMouse":
		return true
	var pet_name := str(pet.get(DataKeys.ALT_NAME, "")).strip_edges()
	var pet_title := str(pet.get(DataKeys.NAME, "")).strip_edges()
	return PET_MOUSE_STAGE_NAMES.values().has(pet_name) or PET_MOUSE_STAGE_NAMES.values().has(pet_title)


func _normalize_pet_mouse(pet: Dictionary) -> void:
	var base := PET_MOUSE_PET.duplicate(true)
	var active_name := str(player_data.get(ACTIVE_PET_KEY, ""))
	var keep_fighting := (
		bool(pet.get(DataKeys.DEPLOYED, false))
		or active_name == "PetMouse"
		or PET_MOUSE_STAGE_NAMES.values().has(active_name)
	)
	for key in base.keys():
		if not pet.has(key):
			pet[key] = base[key].duplicate(true) if base[key] is Dictionary or base[key] is Array else base[key]
	pet["悟性"] = clampi(int(pet.get("悟性", 0)), 0, 25)
	pet["根骨"] = clampi(int(pet.get("根骨", 0)), 0, 25)
	pet["灵力"] = clampi(int(pet.get("灵力", 0)), 0, 25)
	var wisdom_bonus := int(pet["悟性"]) * 100
	pet["生命资质基础上限"] = 2500
	pet["魔法资质基础上限"] = 1800
	pet["攻击资质基础上限"] = 3000
	pet["防御资质基础上限"] = 1800
	for key in ["生命资质", "魔法资质", "攻击资质", "防御资质"]:
		var base_max := int(pet[str(key) + "基础上限"])
		pet[str(key) + "上限"] = base_max + wisdom_bonus
		pet[key] = clampi(int(pet.get(key, 1000)), 0, int(pet[str(key) + "上限"]))
	var pet_level := int(pet.get(DataKeys.LEVEL, 1))
	var stage := 2 if pet_level >= 50 else 1
	pet[DataKeys.TYPE] = "PetMouse"
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = str(PET_MOUSE_STAGE_NAMES[stage])
	pet[DataKeys.NAME] = str(PET_MOUSE_STAGE_NAMES[stage])
	pet["技能"] = _pet_mouse_skills_for_level(pet_level)
	pet[DataKeys.DEPLOYED] = keep_fighting
	if keep_fighting:
		player_data[ACTIVE_PET_KEY] = "PetMouse"


func _pet_mouse_skills_for_level(pet_level: int) -> Array:
	var unlock_level := 50 if pet_level >= 50 else 30 if pet_level >= 30 else 1
	return (PET_MOUSE_LEVEL_SKILLS[unlock_level] as Array).duplicate(true)


func ensure_pet_neat() -> bool:
	if not (player_data.get(PET_LIST_KEY, []) is Array):
		player_data[PET_LIST_KEY] = []
	var pets: Array = player_data[PET_LIST_KEY]
	var found := false
	for pet in pets:
		if not (pet is Dictionary):
			continue
		_normalize_pet_passives(pet)
		if _is_pet_neat(pet):
			_normalize_pet_neat(pet)
			found = true
	if not found:
		var neat := PET_NEAT_PET.duplicate(true)
		_normalize_pet_passives(neat)
		pets.append(neat)
	if not player_data.has(ACTIVE_PET_KEY):
		player_data[ACTIVE_PET_KEY] = ""
	return not found


func ensure_pet_yin_tiger() -> bool:
	if not (player_data.get(PET_LIST_KEY, []) is Array):
		player_data[PET_LIST_KEY] = []
	var pets: Array = player_data[PET_LIST_KEY]
	var found := false
	for pet in pets:
		if not (pet is Dictionary):
			continue
		_normalize_pet_passives(pet)
		if _is_pet_yin_tiger(pet):
			_normalize_pet_yin_tiger(pet)
			found = true
	if not found:
		var yin_tiger := PET_YIN_TIGER_PET.duplicate(true)
		_normalize_pet_passives(yin_tiger)
		pets.append(yin_tiger)
	if not player_data.has(ACTIVE_PET_KEY):
		player_data[ACTIVE_PET_KEY] = ""
	return not found


func _is_pet_yin_tiger(pet: Dictionary) -> bool:
	if str(pet.get(DataKeys.TYPE, "")) == "PetYinTiger":
		return true
	var name := str(pet.get(DataKeys.ALT_NAME, pet.get(DataKeys.NAME, ""))).strip_edges()
	return PET_YIN_TIGER_STAGE_NAMES.values().has(name) or name in ["寅虎", "银角虎"]


func _normalize_pet_yin_tiger(pet: Dictionary) -> void:
	var base := PET_YIN_TIGER_PET.duplicate(true)
	var active_name := str(player_data.get(ACTIVE_PET_KEY, ""))
	var keep_fighting := (
		bool(pet.get(DataKeys.DEPLOYED, false))
		or active_name == "PetYinTiger"
		or PET_YIN_TIGER_STAGE_NAMES.values().has(active_name)
	)
	for key in base.keys():
		if not pet.has(key):
			pet[key] = base[key].duplicate(true) if base[key] is Dictionary or base[key] is Array else base[key]
	pet["悟性"] = clampi(int(pet.get("悟性", 0)), 0, 25)
	pet["根骨"] = clampi(int(pet.get("根骨", 0)), 0, 25)
	pet["灵力"] = clampi(int(pet.get("灵力", 0)), 0, 25)
	var wisdom_bonus := int(pet["悟性"]) * 100
	for quality_name in ["生命", "魔法", "攻击", "防御"]:
		var base_key := "%s资质基础上限" % quality_name
		var max_key := "%s资质上限" % quality_name
		var quality_key := "%s资质" % quality_name
		pet[base_key] = int(base.get(base_key, pet.get(base_key, 2000)))
		pet[max_key] = int(pet[base_key]) + wisdom_bonus
		pet[quality_key] = clampi(int(pet.get(quality_key, 1000)), 0, int(pet[max_key]))
	var pet_level := int(pet.get(DataKeys.LEVEL, 1))
	var stage := 4 if pet_level >= 50 else 3 if pet_level >= 30 else 2 if pet_level >= 15 else 1
	pet[DataKeys.TYPE] = "PetYinTiger"
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = str(PET_YIN_TIGER_STAGE_NAMES[stage])
	pet[DataKeys.NAME] = str(PET_YIN_TIGER_STAGE_NAMES[stage])
	pet["技能"] = (PET_YIN_TIGER_STAGE_SKILLS[stage] as Array).duplicate(true)
	pet[DataKeys.DEPLOYED] = keep_fighting
	if keep_fighting:
		player_data[ACTIVE_PET_KEY] = "PetYinTiger"


func _is_pet_neat(pet: Dictionary) -> bool:
	if str(pet.get(DataKeys.TYPE, "")) == "PetNeat":
		return true
	var name := str(pet.get(DataKeys.ALT_NAME, pet.get(DataKeys.NAME, ""))).strip_edges()
	return name in PET_NEAT_STAGE_NAMES.values() or name in ["丑牛", "丑牛元帅", "丑牛大元帅"]


func _normalize_pet_neat(pet: Dictionary) -> void:
	var base := PET_NEAT_PET.duplicate(true)
	var active_name := str(player_data.get(ACTIVE_PET_KEY, ""))
	var keep_fighting := (
		bool(pet.get(DataKeys.DEPLOYED, false))
		or active_name == "PetNeat"
		or active_name in PET_NEAT_STAGE_NAMES.values()
	)
	for key in base.keys():
		if not pet.has(key):
			pet[key] = base[key].duplicate(true) if base[key] is Dictionary or base[key] is Array else base[key]
	var level := int(pet.get(DataKeys.LEVEL, 1))
	var stage := 4 if level >= 50 else 3 if level >= 30 else 2 if level >= 15 else 1
	pet[DataKeys.TYPE] = "PetNeat"
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = PET_NEAT_STAGE_NAMES[stage]
	pet[DataKeys.NAME] = PET_NEAT_STAGE_NAMES[stage]
	pet["技能"] = (PET_NEAT_STAGE_SKILLS[stage] as Array).duplicate(true)
	pet[DataKeys.DEPLOYED] = keep_fighting
	if keep_fighting:
		player_data[ACTIVE_PET_KEY] = "PetNeat"


func ensure_pet_phoenix() -> bool:
	if not (player_data.get(PET_LIST_KEY, []) is Array):
		player_data[PET_LIST_KEY] = []
	var pets: Array = player_data[PET_LIST_KEY]
	var has_phoenix := false
	for pet in pets:
		if not (pet is Dictionary):
			continue
		_normalize_pet_passives(pet)
		if _is_pet_phoenix(pet):
			_normalize_pet_phoenix(pet)
			has_phoenix = true
	if not has_phoenix:
		var phoenix := PET_PHOENIX_PET.duplicate(true)
		_normalize_pet_passives(phoenix)
		pets.append(phoenix)
	if not player_data.has(ACTIVE_PET_KEY):
		player_data[ACTIVE_PET_KEY] = ""
	return not has_phoenix


func _is_pet_phoenix(pet: Dictionary) -> bool:
	if str(pet.get(DataKeys.TYPE, "")) == "PetPhoenix":
		return true
	var pet_name := str(pet.get(DataKeys.ALT_NAME, ""))
	var pet_title := str(pet.get(DataKeys.NAME, ""))
	return _is_pet_phoenix_name(pet_name) or _is_pet_phoenix_name(pet_title)


func _is_pet_phoenix_name(pet_name: String) -> bool:
	var clean_name := pet_name.strip_edges()
	return (
		clean_name.begins_with("朱雀")
		or clean_name in ["雀蛋", "炎皇雀", "朱雀将军", "朱雀女皇", "朱雀幼灵", "赤羽朱雀", "朱雀神君"]
		or PET_PHOENIX_STAGE_NAMES.values().has(clean_name)
	)


func _normalize_pet_phoenix(pet: Dictionary) -> void:
	var phoenix_data := PET_PHOENIX_PET.duplicate(true)
	var keep_fighting := (
		bool(pet.get(DataKeys.DEPLOYED, false)) or str(player_data.get(ACTIVE_PET_KEY, "")) == "PetPhoenix"
	)
	for key in phoenix_data.keys():
		if not pet.has(key):
			pet[key] = (
				phoenix_data[key].duplicate(true)
				if phoenix_data[key] is Dictionary or phoenix_data[key] is Array
				else phoenix_data[key]
			)
	pet["悟性"] = clampi(int(pet.get("悟性", 0)), 0, 25)
	pet["根骨"] = clampi(int(pet.get("根骨", 0)), 0, 25)
	pet["灵力"] = clampi(int(pet.get("灵力", 0)), 0, 25)
	var wisdom_bonus := int(pet["悟性"]) * 100
	pet["生命资质基础上限"] = 2500
	pet["魔法资质基础上限"] = 1800
	pet["攻击资质基础上限"] = 3000
	pet["防御资质基础上限"] = 1800
	pet["生命资质上限"] = 2500 + wisdom_bonus
	pet["魔法资质上限"] = 1800 + wisdom_bonus
	pet["攻击资质上限"] = 3000 + wisdom_bonus
	pet["防御资质上限"] = 1800 + wisdom_bonus
	pet[DataKeys.TYPE] = "PetPhoenix"
	var phoenix_level := int(pet.get(DataKeys.LEVEL, 1))
	var phoenix_stage := 4 if phoenix_level >= 50 else 3 if phoenix_level >= 30 else 2 if phoenix_level >= 15 else 1
	pet["阶段"] = phoenix_stage
	pet[DataKeys.ALT_NAME] = str(PET_PHOENIX_STAGE_NAMES[phoenix_stage])
	pet[DataKeys.NAME] = str(PET_PHOENIX_STAGE_NAMES[phoenix_stage])
	pet["技能"] = (PET_PHOENIX_STAGE_SKILLS.get(phoenix_stage, []) as Array).duplicate(true)
	pet[DataKeys.DEPLOYED] = keep_fighting
	if keep_fighting:
		player_data[ACTIVE_PET_KEY] = "PetPhoenix"


var syn_list = {
	"放入列表": {"物品1": [], "物品2": [], "物品3": []},
}


func get_total_zb_list():
	var list = []
	for i in range(player_data[DataKeys.EQUIPMENT_LIST].size()):
		var u = i + 1
		for z in player_data[DataKeys.EQUIPMENT_LIST]["页码" + str(u)]:
			list.push_back(z)
	return list


func record_acquired_equipment(item_id: String) -> void:
	if not AE.all_equipment.has(item_id) or _is_removed_equipment_id(item_id):
		return
	if str(AE.all_equipment[item_id].get(DataKeys.TYPE, "")) not in ["武器", "防具", "时装", "翅膀", "头衔"]:
		return
	var acquired_value: Variant = player_data.get("已获取装备列表", [])
	var acquired: Array = acquired_value if acquired_value is Array else []
	if not acquired.has(item_id):
		acquired.push_back(item_id)
	player_data["已获取装备列表"] = acquired


func ensure_acquired_equipment_data() -> void:
	if not (player_data.get("已获取装备列表", null) is Array):
		player_data["已获取装备列表"] = []
	for item in get_total_zb_list():
		if item is Dictionary:
			record_acquired_equipment(str(item.get(DataKeys.NAME, "")))
	for slot in ["武器", "防具", "时装", "翅膀", "头衔"]:
		for item in player_data.get(slot, []):
			if item is Dictionary:
				record_acquired_equipment(str(item.get(DataKeys.NAME, "")))
	var owned_value: Variant = player_data.get("幻化拥有列表", [])
	if owned_value is Array:
		for item_id in owned_value:
			record_acquired_equipment(str(item_id))
	else:
		player_data["幻化拥有列表"] = []
	var transmog_value: Variant = player_data.get(DataKeys.TRANSMOG_LIST, {})
	if transmog_value is Dictionary:
		for item_id in transmog_value.values():
			record_acquired_equipment(str(item_id))


func has_acquired_equipment(item_id: String) -> bool:
	return player_data.get("已获取装备列表", []).has(item_id) or player_data.get("幻化拥有列表", []).has(item_id)


func add_zb(_name, qh_level, data) -> bool:
	var equipment_id := str(_name)
	if equipment_id == "" or _is_removed_equipment_id(equipment_id):
		return false
	if not AE.all_equipment.has(equipment_id):
		return false

	var page_number: int = int(check_can_use_page("装备列表"))
	if page_number == 0:
		return false
	if data.is_empty():
		data = (AE.all_equipment[equipment_id] as Dictionary).duplicate(true)
	player_data[DataKeys.EQUIPMENT_LIST]["页码" + str(page_number)].push_back(
		{"名字": equipment_id, "强化等级": qh_level, "Data": data}
	)
	record_acquired_equipment(equipment_id)
	return true


func add_fb(_name, qh_level, wx, data) -> bool:
	var equipment_id := str(_name)
	if equipment_id == "" or equipment_id in RETIRED_WUDU_MAGIC_WEAPONS:
		return false
	if not AE.all_equipment.has(equipment_id):
		return false

	var page_number: int = int(check_can_use_page("装备列表"))
	if page_number == 0:
		return false
	if data.is_empty():
		data = (AE.all_equipment[equipment_id] as Dictionary).duplicate(true)
	player_data[DataKeys.EQUIPMENT_LIST]["页码" + str(page_number)].push_back(
		{"名字": equipment_id, "强化等级": qh_level, "五行": wx, "Data": data}
	)
	return true


func remove_zb(page: int, local: int) -> Dictionary:
	if page <= 0:
		return {}
	var page_key: String = "页码" + str(page)
	var pages: Variant = player_data.get(DataKeys.EQUIPMENT_LIST, {})
	if not pages is Dictionary or not pages.has(page_key):
		return {}
	var page_items: Variant = pages.get(page_key, [])
	if not page_items is Array or local >= page_items.size():
		return {}
	var item: Dictionary = page_items[local]
	var _name = item.get(DataKeys.NAME, "")
	record_acquired_equipment(str(_name))
	var qh_level = item.get(DataKeys.ENHANCE_LEVEL, 0)
	var data = item.get("Data", {})
	var wx = item.get(DataKeys.FIVE_ELEMENTS, [])
	var result_item: Dictionary = {"名字": _name, "强化等级": qh_level, "五行": wx, "Data": data}
	page_items.remove_at(local)
	return result_item


func get_zb_data(page: int, local: int) -> Dictionary:
	var page_key: String = "页码" + str(page)
	var pages: Variant = player_data.get(DataKeys.EQUIPMENT_LIST, {})
	if not pages is Dictionary or not pages.has(page_key):
		return {}
	var page_items: Variant = pages.get(page_key, [])
	if not page_items is Array or local >= page_items.size():
		return {}
	var item: Dictionary = page_items[local]
	var _name = item.get(DataKeys.NAME, "")
	var qh_level = item.get(DataKeys.ENHANCE_LEVEL, 0)
	var data = item.get("Data", {})
	var wx = item.get(DataKeys.FIVE_ELEMENTS, [])
	return {"名字": _name, "强化等级": qh_level, "五行": wx, "Data": data}


func organize_backpack() -> bool:
	var organized: Dictionary = {}
	for list_key in ["装备列表", "道具列表", "消耗品列表"]:
		var pages: Variant = player_data.get(list_key, {})
		if not pages is Dictionary:
			return false
		var items: Array = []
		for page_number in range(1, 21):
			var page: Variant = pages.get("页码%d" % page_number, [])
			if not page is Array:
				return false
			for item in page:
				if not item is Dictionary:
					return false
				items.append(item)
		if items.size() > 500:
			return false
		if list_key == "装备列表":
			items.sort_custom(_backpack_item_before)
		else:
			items.sort_custom(_backpack_material_before)
		var sorted_pages: Dictionary = {}
		for page_number in range(1, 21):
			var first := (page_number - 1) * 25
			sorted_pages["页码%d" % page_number] = (
				items.slice(first, mini(first + 25, items.size())) if first < items.size() else []
			)
		organized[list_key] = sorted_pages
	for list_key in organized:
		player_data[list_key] = organized[list_key]
	return true


func _backpack_material_group(item: Dictionary) -> Array:
	var item_id := str(item.get(DataKeys.NAME, ""))
	var template: Dictionary = AE.all_equipment.get(item_id, {})
	var item_name := str(template.get(DataKeys.NAME, item_id))
	var group := str(template.get("所属", ""))
	var family := item_name
	var tier := 0
	var tier_pattern := RegEx.new()
	tier_pattern.compile("^([0-9一二三四五六七八九十]+)[级阶品]")
	var match_result := tier_pattern.search(family)
	if match_result != null:
		var tier_text := match_result.get_string(1)
		var chinese_tiers := ["", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]
		tier = int(tier_text) if tier_text.is_valid_int() else chinese_tiers.find(tier_text)
		family = family.substr(match_result.get_end())
	else:
		for prefix in ["初级", "低级", "中级", "高级", "顶级"]:
			if family.begins_with(prefix):
				tier = ["初级", "低级", "中级", "高级", "顶级"].find(prefix) + 1
				family = family.trim_prefix(prefix)
				break

	if group == "星宿掉落":
		family = family.substr(0, 2)
	elif family.contains("残片·"):
		family = family.get_slice("·", 0)
	return [group, family, tier, item_name, item_id]


func _backpack_material_before(a: Dictionary, b: Dictionary) -> bool:
	var a_group := _backpack_material_group(a)
	var b_group := _backpack_material_group(b)
	for index in range(a_group.size()):
		if a_group[index] != b_group[index]:
			return a_group[index] < b_group[index]
	return false


func _backpack_item_before(a: Dictionary, b: Dictionary) -> bool:
	var quality_order := ["普通", "优秀", "精良", "史诗", "邪灵", "魂器", "传说", "神器", "玄冥", "黑神话", "无敌"]
	var a_id := str(a.get(DataKeys.NAME, ""))
	var b_id := str(b.get(DataKeys.NAME, ""))
	var a_template: Dictionary = AE.all_equipment.get(a_id, {})
	var b_template: Dictionary = AE.all_equipment.get(b_id, {})
	var a_data: Dictionary = a.get("Data", {}) if a.get("Data", {}) is Dictionary else {}
	var b_data: Dictionary = b.get("Data", {}) if b.get("Data", {}) is Dictionary else {}
	var a_rank := quality_order.find(str(a_data.get(DataKeys.QUALITY, a_template.get(DataKeys.QUALITY, ""))))
	var b_rank := quality_order.find(str(b_data.get(DataKeys.QUALITY, b_template.get(DataKeys.QUALITY, ""))))
	if a_rank != b_rank:
		return a_rank < b_rank
	var a_type := str(a_data.get(DataKeys.TYPE, a_template.get(DataKeys.TYPE, "")))
	var b_type := str(b_data.get(DataKeys.TYPE, b_template.get(DataKeys.TYPE, "")))
	if a_type != b_type:
		return a_type < b_type
	var a_name := str(a_template.get(DataKeys.NAME, a_id))
	var b_name := str(b_template.get(DataKeys.NAME, b_id))
	if a_name != b_name:
		return a_name < b_name
	if a_id != b_id:
		return a_id < b_id
	if int(a_data.get("神铸阶段", 0)) != int(b_data.get("神铸阶段", 0)):
		return int(a_data.get("神铸阶段", 0)) > int(b_data.get("神铸阶段", 0))
	return int(a.get(DataKeys.ENHANCE_LEVEL, 0)) > int(b.get(DataKeys.ENHANCE_LEVEL, 0))


func zl_zb():
	var list = []
	for i in range(player_data[DataKeys.EQUIPMENT_LIST].size()):
		var u = i + 1
		for z in player_data[DataKeys.EQUIPMENT_LIST]["页码" + str(u)]:
			list.push_back(z)
		player_data[DataKeys.EQUIPMENT_LIST]["页码" + str(u)].clear()
	for i in list:
		var lx = AE.all_equipment[i.名字][DataKeys.TYPE]
		if lx != "法宝":
			add_zb(i.名字, i.强化等级, i.Data)
		else:
			add_fb(i.名字, i.强化等级, i.五行, i.Data)


func check_eq_zb(Type, need_):
	if Type == "法宝":
		return player_data["实战法宝"] == need_

	var list = player_data[Type]
	if list.size() != 0:
		var _name = list[0][DataKeys.NAME]
		return str(_name) == str(need_)
	return false


func check_zb(need_: String) -> Array:
	var list: Array = []
	var get_infor: Array = []
	var zb_pages: Variant = player_data.get(DataKeys.EQUIPMENT_LIST, {})
	if zb_pages is Dictionary:
		for i in range(zb_pages.size()):
			var page_items: Variant = zb_pages.get("页码" + str(i + 1), [])
			if page_items is Array:
				for z in page_items:
					list.push_back(z)
	for slot_name in ["武器", "防具", "饰品", "法宝", "时装", "头衔", "翅膀"]:
		var slot_items: Variant = player_data.get(slot_name, [])
		if slot_items is Array and slot_items.size() > 0:
			list.push_back(slot_items[0])
	var shengu: Array = ensure_shengu_slot()
	if shengu.size() > 0:
		list.push_back(shengu[0])
	for item in list:
		if item is Dictionary and str(item.get(DataKeys.NAME, "")) == need_:
			get_infor.push_back({"data": item})
	return get_infor


func check_have_zb(need_: String) -> Array:
	var found: Array = check_zb(need_)
	if found.size() > 0:
		return [true, found.size()]
	return [false, 0]


func check_have_wx(need_, wx):
	var list = check_zb(need_)
	var new_list = []
	if list == []:
		return false
	else:
		for i in list:
			var get_data = i["data"]
			var get_wx = get_data[DataKeys.FIVE_ELEMENTS]
			if get_wx.has(wx):
				return true
	return false


func get_all_item():
	var list = []
	for i in range(player_data[DataKeys.EQUIPMENT_LIST].size()):
		var u = i + 1
		for z in player_data[DataKeys.EQUIPMENT_LIST]["页码" + str(u)]:
			list.push_back(z)

	if player_data[DataKeys.WEAPON].size() != 0:
		list.push_back(player_data[DataKeys.WEAPON][0])
	if player_data[DataKeys.ARMOR].size() != 0:
		list.push_back(player_data[DataKeys.ARMOR][0])
	if player_data["饰品"].size() != 0:
		list.push_back(player_data["饰品"][0])
	if player_data[DataKeys.MAGIC_WEAPON].size() != 0:
		list.push_back(player_data[DataKeys.MAGIC_WEAPON][0])
	if player_data[DataKeys.FASHION].size() != 0:
		list.push_back(player_data[DataKeys.FASHION][0])
	if player_data[DataKeys.TITLE].size() != 0:
		list.push_back(player_data[DataKeys.TITLE][0])
	if player_data[DataKeys.WINGS].size() != 0:
		list.push_back(player_data[DataKeys.WINGS][0])
	return list


func check_wx_num():
	var list = get_all_item()
	if list == []:
		return false
	else:
		for i in list:
			var get_data = i["Data"]
			var get_wx

			if get_data[DataKeys.TYPE] == "法宝":
				get_wx = get_data[DataKeys.FIVE_ELEMENTS]

	return false


func get_most_level(need_):
	var level_list = []
	if PlayerData.check_zb(need_).size() != 0:
		for i in PlayerData.check_zb(need_):
			var get_data = i["data"]
			var get_level = get_data[DataKeys.ENHANCE_LEVEL]
			level_list.push_back(get_level)
		level_list.sort()
		level_list.reverse()
		return level_list[0]
	return 0


func get_item_data(need_name):
	if need_name == "empty":
		return 0
	var _is_empty = true
	var get_number: int
	var x = 1
	for i in player_data[DataKeys.ITEM_LIST]:
		if player_data[DataKeys.ITEM_LIST][i].size() == 0:
			continue
		else:
			_is_empty = false
			break
	if _is_empty == true:
		return 0
	while x <= player_data[DataKeys.ITEM_LIST].size():
		for i in player_data[DataKeys.ITEM_LIST]["页码" + str(x)]:
			if i[DataKeys.NAME] == need_name:
				get_number = i[DataKeys.COUNT]
				return get_number
		x += 1
	return 0


func get_xhp_data(need_name):
	if need_name == "empty":
		return 0
	var _is_empty = true
	var get_number: int
	var x = 1
	for i in player_data[DataKeys.CONSUMABLE_LIST]:
		if player_data[DataKeys.CONSUMABLE_LIST][i].size() == 0:
			continue
		else:
			_is_empty = false
			break
	if _is_empty == true:
		return 0
	while x <= player_data[DataKeys.CONSUMABLE_LIST].size():
		for i in player_data[DataKeys.CONSUMABLE_LIST]["页码" + str(x)]:
			if i[DataKeys.NAME] == need_name:
				get_number = i[DataKeys.COUNT]
				return get_number
		x += 1
	return 0


func get_dj_page(need_name):
	if need_name == "empty":
		return 0
	for page_num in range(1, player_data[DataKeys.ITEM_LIST].size() + 1):
		for u in player_data[DataKeys.ITEM_LIST]["页码" + str(page_num)]:
			if u[DataKeys.NAME] == need_name:
				return page_num
	return 0


func get_total_dj_list():
	var list = []
	for i in range(player_data[DataKeys.ITEM_LIST].size()):
		var u = i + 1
		for z in player_data[DataKeys.ITEM_LIST]["页码" + str(u)]:
			list.push_back(z)
	return list


func add_dj(_name, number, locked := false):
	if number <= 0:
		return
	if not AE.all_equipment.has(_name):
		return

	var existing_page = get_dj_page(_name)
	if existing_page != 0:
		var existing_list = player_data[DataKeys.ITEM_LIST]["页码" + str(existing_page)]
		for i in existing_list:
			if _name == i[DataKeys.NAME]:
				i[DataKeys.COUNT] += number
				i["锁定"] = bool(i.get("锁定", false)) or bool(locked)
				return

	var usable_page = check_can_use_page("道具列表")
	if usable_page == 0:
		return

	var data = AE.all_equipment[_name]
	player_data[DataKeys.ITEM_LIST]["页码" + str(usable_page)].push_back(
		{"名字": _name, "数量": number, "Data": data, "锁定": bool(locked)}
	)


func zl_dj():
	var list = []
	for i in range(player_data[DataKeys.ITEM_LIST].size()):
		var u = i + 1
		for z in player_data[DataKeys.ITEM_LIST]["页码" + str(u)]:
			list.push_back(z)
		player_data[DataKeys.ITEM_LIST]["页码" + str(u)].clear()
	for i in list:
		add_dj(i.名字, i.数量, bool(i.get("锁定", false)))


func zl_xhp():
	var list = []
	for i in range(player_data[DataKeys.CONSUMABLE_LIST].size()):
		var u = i + 1
		for z in player_data[DataKeys.CONSUMABLE_LIST]["页码" + str(u)]:
			list.push_back(z)
		player_data[DataKeys.CONSUMABLE_LIST]["页码" + str(u)].clear()
	for i in list:
		add_xhp(i.名字, i.数量, bool(i.get("锁定", false)))


func remove_dj(_name, page, num):
	if num <= 0:
		return
	if page == 0:
		return
	var _get_name = ""
	var x = -1
	var all_coin: int
	while _name != _get_name:
		x += 1
		if x > player_data[DataKeys.ITEM_LIST]["页码" + str(page)].size() - 1:
			return {"名字": _name, "数量": 0, "获得灵魂": 0, "卖出数量": 0}
		_get_name = player_data[DataKeys.ITEM_LIST]["页码" + str(page)][x][DataKeys.NAME]
	if player_data[DataKeys.ITEM_LIST]["页码" + str(page)][x][DataKeys.COUNT] <= num:
		num = player_data[DataKeys.ITEM_LIST]["页码" + str(page)][x][DataKeys.COUNT]
	var last_num = player_data[DataKeys.ITEM_LIST]["页码" + str(page)][x][DataKeys.COUNT] - num

	player_data[DataKeys.ITEM_LIST]["页码" + str(page)][x][DataKeys.COUNT] -= num
	if last_num <= 0:
		player_data[DataKeys.ITEM_LIST]["页码" + str(page)].remove_at(x)
	if not Global.is_in_ldl:
		all_coin = AE.all_equipment[_name]["售价"] * num
		add_soul(all_coin)
	var list = {"名字": _name, "数量": last_num, "获得灵魂": all_coin, "卖出数量": num}
	return list


func remove_item(item_name: String, count: int) -> bool:
	var remaining = count

	for page_key in player_data[DataKeys.CONSUMABLE_LIST].keys():
		var page = player_data[DataKeys.CONSUMABLE_LIST][page_key]
		var i = 0
		while i < page.size() and remaining > 0:
			if page[i][DataKeys.NAME] == item_name:
				var have = page[i][DataKeys.COUNT]
				if have >= remaining:
					page[i][DataKeys.COUNT] -= remaining
					remaining = 0
					if page[i][DataKeys.COUNT] == 0:
						page.remove_at(i)

						continue
					else:
						break
				else:
					remaining -= have
					page.remove_at(i)
					continue
			i += 1
		if remaining == 0:
			break

	if remaining > 0:
		for page_key in player_data[DataKeys.ITEM_LIST].keys():
			var page = player_data[DataKeys.ITEM_LIST][page_key]
			var i = 0
			while i < page.size() and remaining > 0:
				if page[i][DataKeys.NAME] == item_name:
					var have = page[i][DataKeys.COUNT]
					if have >= remaining:
						page[i][DataKeys.COUNT] -= remaining
						remaining = 0
						if page[i][DataKeys.COUNT] == 0:
							page.remove_at(i)
							continue
						else:
							break
					else:
						remaining -= have
						page.remove_at(i)
						continue
				i += 1
			if remaining == 0:
				break

	return remaining == 0


func get_total_xhp_list():
	var list = []
	for i in range(player_data[DataKeys.CONSUMABLE_LIST].size()):
		var u = i + 1
		for z in player_data[DataKeys.CONSUMABLE_LIST]["页码" + str(u)]:
			list.push_back(z)
	return list


func add_xhp(_name: String, number: int, locked := false) -> void:
	if number <= 0:
		return

	var page_num = get_xhp_page(_name)
	if page_num != 0:
		var list = player_data[DataKeys.CONSUMABLE_LIST]["页码" + str(page_num)]
		for i in list:
			if i[DataKeys.NAME] == _name:
				i[DataKeys.COUNT] += number
				i["锁定"] = bool(i.get("锁定", false)) or bool(locked)
				return

	var new_page = check_can_use_page("消耗品列表")
	if new_page == 0:
		return
	player_data[DataKeys.CONSUMABLE_LIST]["页码" + str(new_page)].push_back(
		{"名字": _name, "数量": number, "锁定": bool(locked)}
	)


func get_xhp_page(need_name):
	if need_name == "empty":
		return 0
	for page_num in range(1, player_data[DataKeys.CONSUMABLE_LIST].size() + 1):
		for u in player_data[DataKeys.CONSUMABLE_LIST]["页码" + str(page_num)]:
			if u[DataKeys.NAME] == need_name:
				return page_num
	return 0


func remove_xhp(_name, page, num):
	if num <= 0:
		return
	var _get_name = ""
	var x = -1
	var all_coin: int
	while _name != _get_name:
		x += 1
		_get_name = player_data[DataKeys.CONSUMABLE_LIST]["页码" + str(page)][x][DataKeys.NAME]
	if player_data[DataKeys.CONSUMABLE_LIST]["页码" + str(page)][x][DataKeys.COUNT] <= num:
		num = player_data[DataKeys.CONSUMABLE_LIST]["页码" + str(page)][x][DataKeys.COUNT]
	var last_num = player_data[DataKeys.CONSUMABLE_LIST]["页码" + str(page)][x][DataKeys.COUNT] - num
	player_data[DataKeys.CONSUMABLE_LIST]["页码" + str(page)][x][DataKeys.COUNT] -= num
	if last_num <= 0:
		player_data[DataKeys.CONSUMABLE_LIST]["页码" + str(page)].remove_at(x)
	if not Global.is_in_ldl:
		all_coin = AE.all_equipment[_name]["售价"] * num
		add_soul(all_coin)
	var list = {"名字": _name, "数量": last_num, "获得灵魂": all_coin, "卖出数量": num}
	return list


func migrate_consumables_from_dj_to_xhp() -> void:
	var move_list := []
	for page_key in player_data[DataKeys.ITEM_LIST]:
		var page = player_data[DataKeys.ITEM_LIST][page_key]
		var x: int = int(page.size()) - 1
		while x >= 0:
			var item = page[x]
			if item.has(DataKeys.NAME):
				var item_name = item[DataKeys.NAME]
				if AE.all_equipment.has(item_name) and AE.all_equipment[item_name][DataKeys.TYPE] == "消耗品":
					var item_num = int(item[DataKeys.COUNT]) if item.has(DataKeys.COUNT) else 1
					page.remove_at(x)
					move_list.push_back({"名字": item_name, "数量": item_num, "锁定": bool(item.get("锁定", false))})
			x -= 1
	for item in move_list:
		add_xhp(item[DataKeys.NAME], int(item[DataKeys.COUNT]), bool(item.get("锁定", false)))


func check_can_use_page(target):
	for i in range(player_data[target].size()):
		var u = i + 1
		if player_data[target]["页码" + str(u)].size() < 25:
			return u
	return 0


func check_fashion_clothes(NeedName: String):
	if player_data[DataKeys.FASHION].size() <= 0:
		return false
	if PlayerData.player_data[DataKeys.FASHION][0][DataKeys.NAME] == NeedName:
		return true
	return false


func _process(_delta: float) -> void:
	normalize_soul()
	_check_zb_elapsed += _delta
	if _check_zb_elapsed < 0.5:
		return
	_check_zb_elapsed = 0.0

	if not player_data[DataKeys.SKILL_LEARNED].has("技能11"):
		player_data[DataKeys.SKILL_LEARNED]["技能11"] = {"学习": 0, "等级": 0}
	if not player_data[DataKeys.SKILL_LEARNED].has("技能12"):
		player_data[DataKeys.SKILL_LEARNED]["技能12"] = {"学习": 0, "等级": 0}
	if not player_data[DataKeys.SKILL_LEARNED].has("技能13"):
		player_data[DataKeys.SKILL_LEARNED]["技能13"] = {"学习": 0, "等级": 0}
	var skill_keys: Variant = player_data[DataKeys.SKILL_LEARNED].get("技能键位", {})
	if skill_keys is Dictionary:
		for key_name in skill_keys.keys():
			if str(skill_keys[key_name]) == "hdzc":
				skill_keys[key_name] = ""
			elif str(skill_keys[key_name]) == "lxyz":
				skill_keys[key_name] = "by"

	if MainSet.set_data.has("FileValue"):
		if Global != null and float(MainSet.set_data["FileValue"]) < float(Global.file_num):
			MainSet.set_data["FileValue"] = Global.file_num

	if MainSet.set_data["xg"] and not _invalid_data_exit_started:
		_invalid_data_exit_started = true
		if Global != null:
			Global.add_message_show(Global.windows, "数据不正常哦，我退出啦~", 4, Vector2(485, 295))
		await get_tree().create_timer(2, false).timeout
		get_tree().quit()

	if PlayerData.check_eq_zb("头衔", "xczg"):
		PlayerData.player_data["ieho"] = true

	if player_data["实战法宝"] != "":
		if check_zb(player_data["实战法宝"]) == []:
			player_data["实战法宝"] = ""


func removedata():
	MemoryClass.remove()
	Global.change_scene("res://Scene/main_menu/main_menu.tscn")


func check_next_day():
	var dic = Time.get_datetime_dict_from_system()
	var my_dic = PlayerData.player_data["MyTime"]
	if my_dic == {}:
		return
	if int(dic["year"]) < int(my_dic["year"]):
		return false
	elif int(dic["year"]) > int(my_dic["year"]):
		return true
	else:
		if int(dic["month"]) < int(my_dic["month"]):
			return false
		elif int(dic["month"]) > int(my_dic["month"]):
			return true
		else:
			if int(dic["day"]) < int(my_dic["day"]):
				return false
			elif int(dic["day"]) > int(my_dic["day"]):
				return true
			else:
				return false


const EIGHT_IMMORTAL_DAILY_IDS: Array[int] = [163, 175, 165, 166, 168, 169, 174, 164]


func get_eight_immortal_daily_progress() -> Dictionary:
	var today := Time.get_date_string_from_system()
	var progress_value: Variant = player_data.get(DataKeys.Daily.EIGHT_IMMORTAL_PROGRESS, {})
	if not progress_value is Dictionary or str((progress_value as Dictionary).get(DataKeys.Daily.DATE, "")) != today:
		progress_value = {
			DataKeys.Daily.DATE: today,
			DataKeys.Daily.DEFEATED: [],
			DataKeys.Daily.CLAIMED: false,
		}
		player_data[DataKeys.Daily.EIGHT_IMMORTAL_PROGRESS] = progress_value
	var progress: Dictionary = progress_value
	var defeated: Array[int] = []
	var saved_value: Variant = progress.get(DataKeys.Daily.DEFEATED, [])
	if saved_value is Array:
		for saved_id in saved_value:
			var boss_id := int(saved_id)
			if boss_id in EIGHT_IMMORTAL_DAILY_IDS and boss_id not in defeated:
				defeated.append(boss_id)
	progress[DataKeys.Daily.DEFEATED] = defeated
	return progress


func record_eight_immortal_daily_defeat(boss_id: int) -> void:
	if boss_id not in EIGHT_IMMORTAL_DAILY_IDS:
		return
	var progress := get_eight_immortal_daily_progress()
	var defeated: Array = progress.get(DataKeys.Daily.DEFEATED, [])
	if boss_id not in defeated:
		defeated.append(boss_id)
	progress[DataKeys.Daily.DEFEATED] = defeated


func is_eight_immortal_daily_complete() -> bool:
	var defeated: Array = get_eight_immortal_daily_progress().get(DataKeys.Daily.DEFEATED, [])
	for boss_id in EIGHT_IMMORTAL_DAILY_IDS:
		if boss_id not in defeated:
			return false
	return true


func claim_eight_immortal_daily() -> bool:
	var progress := get_eight_immortal_daily_progress()
	if not is_eight_immortal_daily_complete():
		return false
	# 6.9 起每完成一轮即可领取，领取后清空本轮击败进度。
	progress[DataKeys.Daily.CLAIMED] = false
	progress[DataKeys.Daily.DEFEATED] = []
	return true


func add_ini_buff():
	if player_data["初始Buff"].size() != 0:
		for i in player_data["初始Buff"]:
			Global.add_buff(RoleProp.source_player.buff, i)


func check_same_ini_buff(Need):
	if player_data["初始Buff"].size() != 0:
		for i in player_data["初始Buff"]:
			if i["Name"] == Need:
				return true

	return false


func check_pass(local):
	if bool(player_data.get("隐藏地图全开", false)):
		return true
	match local:
		"天庭":
			if player_data["转轮殿"] == 1 and get_item_data("ttlp") != 0 and player_data["天庭"]:
				return true
		"截教":
			if player_data[DataKeys.PLAYER_LEVEL] >= 50 and get_item_data("ttlp") != 0 and player_data["截教天镜"]:
				return true
		"碧游宫":
			if player_data[DataKeys.PLAYER_LEVEL] >= 60 and get_item_data("ttsl") != 0 and player_data["碧游宫"]:
				return true
	return false


# ==============================================================================
# Phase 6-4: DataKeys 强类型契约安全访问器
# ==============================================================================


## 获取玩家当前等级 (强类型契约)
func get_player_level() -> int:
	return int(player_data.get(DataKeys.PLAYER_LEVEL, 1))


## 获取玩家金币数 (强类型契约)
func get_coin_num() -> int:
	return int(player_data.get("coin_num", 0))


## 获取玩家当前生命值上限 (契约)
func get_player_max_hp() -> int:
	return int(player_data.get(DataKeys.Attr.MAX_HP, 0))


## 获取玩家当前魔法值上限 (契约)
func get_player_max_mp() -> int:
	return int(player_data.get(DataKeys.Attr.MAX_MP, 0))


## 获取指定装备容器列表 (强类型契约)
func get_container_list(container_name: String) -> Array:
	var list_val: Variant = player_data.get(container_name, [])
	return list_val as Array if list_val is Array else []
