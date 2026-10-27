extends Control

enum PetPage { ATTRIBUTE, BACKPACK, DEVELOP }

const PET_LIST_KEY := "宠物列表"
const ACTIVE_PET_KEY := "出战宠物"
const PET_SHARED_PACK_KEY := "宠物背包"
const PET_RABBIT_UNLOCK_KEY := "月兔已解锁"
const PET_SKILL_PROGRESSION := preload("res://Script/pet/pet_skill_progression.gd")
const PET_LEARNED_SKILL_RUNTIME := preload("res://Script/pet/pet_life_bonus_runtime.gd")
const PET_LEARNED_SKILLS_KEY := "已学习技能"
const PET_FORMATION_MAX_LEVEL := 100
const PET_FORMATION_DEFINITIONS := [
	{"stat": "生命", "gain": 400, "stone": "zqjs", "core": "zqjh", "stone_name": "朱雀晶石", "core_name": "朱雀晶核"},
	{"stat": "攻击", "gain": 50, "stone": "zqjs", "core": "zqjh", "stone_name": "朱雀晶石", "core_name": "朱雀晶核"},
	{"stat": "暴击", "gain": 5, "stone": "zqjs", "core": "zqjh", "stone_name": "朱雀晶石", "core_name": "朱雀晶核"},
	{"stat": "幸运", "gain": 5, "stone": "zqjs", "core": "zqjh", "stone_name": "朱雀晶石", "core_name": "朱雀晶核"},
	{"stat": "破甲", "gain": 5, "stone": "xwjs", "core": "xwjh", "stone_name": "玄武晶石", "core_name": "玄武晶核"},
	{"stat": "破魔", "gain": 5, "stone": "xwjs", "core": "xwjh", "stone_name": "玄武晶石", "core_name": "玄武晶核"},
	{"stat": "闪避", "gain": 5, "stone": "xwjs", "core": "xwjh", "stone_name": "玄武晶石", "core_name": "玄武晶核"},
	{"stat": "物防", "gain": 25, "stone": "xwjs", "core": "xwjh", "stone_name": "玄武晶石", "core_name": "玄武晶核"},
	{"stat": "魔防", "gain": 25, "stone": "xwjs", "core": "xwjh", "stone_name": "玄武晶石", "core_name": "玄武晶核"},
]
const PET_LEARNABLE_SKILLS := [
	{
		"name": "生命加成",
		"book": "smjc_skill_book",
		"icon": "smjc",
		"description": "提升主人（技能等级×2%×宠物生命）的生命上限。\n持续：技能等级×10+20秒；冷却：30秒；不可叠加。"
	},
	{
		"name": "攻击加成",
		"book": "gjjc_skill_book",
		"icon": "gjjc",
		"description": "提升主人（技能等级×2%×宠物攻击）的攻击。\n持续：技能等级×10+20秒；冷却：30秒；不可叠加。"
	},
	{
		"name": "防御加成",
		"book": "fyjc_skill_book",
		"icon": "fyjc",
		"description": "提升主人（技能等级×2%×宠物物防）的物防，并提升主人（技能等级×2%×宠物魔防）的魔防。\n持续：技能等级×10+20秒；冷却：30秒；不可叠加。"
	},
	{"name": "魔法庇佑", "book": "mfby_skill_book", "icon": "mfby", "description": "常驻提升宠物（技能等级×2%×宠物魔法）的魔法。"},
	{
		"name": "嗜血狂爆",
		"book": "sxkb_skill_book",
		"icon": "sxkb",
		"description": "提升宠物（技能等级×2%×宠物暴击）的暴击。\n持续：技能等级×10+20秒；冷却：30秒。"
	},
	{
		"name": "法术能量",
		"book": "fsnl_skill_book",
		"icon": "fsnl",
		"description": "提升宠物（技能等级×2%）的技能伤害。\n持续：技能等级×10+20秒；冷却：30秒。"
	},
	{"name": "天生蛮力", "book": "tsml_skill_book", "icon": "tsml", "description": "常驻提升宠物（技能等级×2%×宠物攻击）的攻击。"},
	{
		"name": "自然守护",
		"book": "zrsh_skill_book",
		"icon": "zrsh",
		"description": "常驻提升宠物（技能等级×2%×宠物物防）的物防，并提升宠物（技能等级×2%×宠物魔防）的魔防。"
	},
	{"name": "生命祝福", "book": "smzf_skill_book", "icon": "smzf", "description": "常驻提升宠物（技能等级×2%×宠物生命）的生命。"},
	{
		"name": "魔法加成",
		"book": "mfjc_skill_book",
		"icon": "mfjc",
		"description": "提升主人（技能等级×2%×宠物魔法）的魔法。\n持续：技能等级×10+20秒；冷却：30秒；不可叠加。"
	}
]
const PET_ITEM_NAMES := ["生命丹", "魔法丹", "攻击丹", "暴击丹", "幸运丹", "回魔丹", "经验丹", "潜力丹"]
const PET_TIGER_STAGE_NAMES := {1: "虎丸", 2: "白灵虎", 3: "白虎将军", 4: "白虎战神"}
const PET_DRAGON_STAGE_NAMES := {1: "龙仔", 2: "绿英龙", 3: "青龙将军", 4: "青龙妖圣"}
const PET_TIGER_STAGE_SKILLS := {
	1: ["猛扑", "虎啸"],
	2: ["猛扑", "虎啸", "嗜血虎爪"],
	3: ["猛扑", "虎啸", "嗜血虎爪", "横扫千军", "奥义"],
	4: ["猛扑", "虎啸", "嗜血虎爪", "横扫千军", "奥义"]
}
const PET_DRAGON_STAGE_SKILLS := {
	1: ["分身"], 2: ["分身", "闪电冲刺"], 3: ["分身", "闪电冲刺", "雷霆万钧"], 4: ["分身", "闪电冲刺", "雷霆万钧", "青龙奥义"]
}
const PET_PHOENIX_STAGE_NAMES := {1: "雀蛋", 2: "炎皇雀", 3: "朱雀将军", 4: "朱雀女皇"}
const PET_PHOENIX_STAGE_SKILLS := {
	1: ["涅槃"], 2: ["涅槃", "不死火鸟"], 3: ["涅槃", "不死火鸟", "地火燎原"], 4: ["涅槃", "不死火鸟", "地火燎原", "朱雀奥义"]
}
const PET_TURTLE_STAGE_NAMES := {1: "龟布", 2: "墨玄龟", 3: "玄武将军", 4: "玄武大帝"}
const PET_TURTLE_STAGE_SKILLS := {
	1: ["水疗盾"], 2: ["水疗盾", "同心链接"], 3: ["水疗盾", "同心链接", "水湮八荒"], 4: ["水疗盾", "同心链接", "水湮八荒", "玄武奥义"]
}
const PET_RABBIT_STAGE_NAMES := {1: "月兔", 2: "疾风兔", 3: "寒冰玉兔", 4: "冰霜月神"}
const PET_RABBIT_STAGE_SKILLS := {1: ["月光"], 2: ["月光", "疾风"], 3: ["月光", "疾风", "冰陨"], 4: ["月光", "疾风", "冰陨", "月神奥义"]}
const PET_MOUSE_STAGE_NAMES := {1: "子鼠元帅", 2: "子鼠大元帅"}
const PET_MOUSE_LEVEL_SKILLS := {1: ["鼠窜"], 30: ["鼠窜", "回旋飞镖"], 50: ["鼠窜", "回旋飞镖", "子鼠奥义"]}
const PET_MOUSE_PREVIEW_OFFSET := Vector2(20, -25)
const PET_YIN_TIGER_STAGE_NAMES := {1: "寅虎元帅", 2: "寅虎元帅", 3: "寅虎元帅", 4: "寅虎大元帅"}
const PET_YIN_TIGER_STAGE_SKILLS := {1: ["虎啸"], 2: ["虎啸"], 3: ["虎啸"], 4: ["虎啸", "猛虎下山", "寅虎奥义"]}
const PET_YIN_TIGER_PREVIEW_OFFSET := Vector2(1, -23)

const PET_TIGER_PREVIEW_OFFSETS := {1: Vector2(12, -10), 2: Vector2(12, -10), 3: Vector2(20, -10), 4: Vector2(30, -15)}

const PET_RABBIT_PREVIEW_OFFSETS := {4: Vector2(-8.5, -59.5)}
const DEVELOP_MAX := 25
const DEVELOP_FRUIT_COST := 5
const DEVELOP_FRUIT_IDS := {"悟性": "wuxingguo", "根骨": "genguguo", "灵力": "lingliguo"}
const QUALITY_FEED_HOLD_DELAY := 2.0
const QUALITY_FEED_REPEAT_INTERVAL := 0.12
const POTENTIAL_MAX := 32
const STRENGTH_POINT_ITEM := "宠物强化石"
const STRENGTH_BUY_ITEM := "珍珠"
const PET_PASSIVE_KEYS := ["热血", "魔泉", "狂暴", "永恒", "辉煌", "敏锐"]
const PET_PASSIVE_EFFECT_NAMES := {"热血": "生命上限", "魔泉": "魔法上限", "狂暴": "暴击", "永恒": "回血", "辉煌": "回魔", "敏锐": "命中"}

const PET_SKILL_ICON_PATHS := {
	"生命加成": "res://Art/pet/skillicon/smjc.png",
	"攻击加成": "res://Art/pet/skillicon/gjjc.png",
	"防御加成": "res://Art/pet/skillicon/fyjc.png",
	"魔法庇佑": "res://Art/pet/skillicon/mfby.png",
	"嗜血狂爆": "res://Art/pet/skillicon/sxkb.png",
	"法术能量": "res://Art/pet/skillicon/fsnl.png",
	"天生蛮力": "res://Art/pet/skillicon/tsml.png",
	"自然守护": "res://Art/pet/skillicon/zrsh.png",
	"生命祝福": "res://Art/pet/skillicon/smzf.png",
	"魔法加成": "res://Art/pet/skillicon/mfjc.png",
	"猛扑": "res://Art/pet/skillicon/hy.png",
	"虎啸": "res://Art/pet/skillicon/hy.png",
	"嗜血虎爪": "res://Art/pet/skillicon/sxhz.png",
	"横扫千军": "res://Art/pet/skillicon/hsqj.png",
	"奥义": "res://Art/pet/skillicon/aoyi.png",
	"分身": "res://Art/pet/skillicon/fs.png",
	"闪电冲刺": "res://Art/pet/skillicon/sdcc.png",
	"雷霆万钧": "res://Art/pet/skillicon/ltwj.png",
	"青龙奥义": "res://Art/pet/skillicon/aoyi.png",
	"水疗盾": "res://Art/pet/skillicon/sld.png",
	"同心链接": "res://Art/pet/skillicon/txlj.png",
	"水湮八荒": "res://Art/pet/skillicon/sybh.png",
	"玄武奥义": "res://Art/pet/skillicon/aoyi.png",
	"月光": "res://Art/pet/skillicon/yg.png",
	"疾风": "res://Art/pet/skillicon/jf.png",
	"冰陨": "res://Art/pet/skillicon/bs.png",
	"月神奥义": "res://Art/pet/skillicon/aoyi.png",
	"鼠窜": "res://Art/pet/skillicon/sc.png",
	"回旋飞镖": "res://Art/pet/skillicon/hxfb.png",
	"子鼠奥义": "res://Art/pet/skillicon/aoyi.png",
	"蛮牛冲撞": "res://Art/pet/skillicon/mncz.png",
	"蛮力践踏": "res://Art/pet/skillicon/mljt.png",
	"丑牛奥义": "res://Art/pet/skillicon/cnaoyi.png",
	"猛虎下山": "res://Art/pet/skillicon/hsqj.png",
	"寅虎奥义": "res://Art/pet/skillicon/aoyi.png"
}
const PET_SKILL_SLOT_COUNT := 40
const PET_SKILL_SLOT_SIZE := 57
const PET_SKILL_SLOT_GAP := 8
const PET_SKILL_SLOT_FRAME := "res://Art/pet/pet_page_resources/pet_interfacev1270_id202_lossless_54x54.png"
const PET_EQUIPMENT_SLOT_FRAME := preload(
	"res://Art/pet/pet_page_resources/pet_interfacev1270_id202_lossless_54x54.png"
)
const PET_EQUIPMENT_STRENGTH_FONT := preload("res://Font/8_fz_cu_yuan_m03_s.ttf")
const PET_ATTRIBUTE_PAGES := [
	[
		["生命", "生命"],
		["魔法", "魔法"],
		["攻击", "攻击"],
		["物防", "物防"],
		["幸运", "幸运"],
		["魔防", "魔防"],
		["暴击", "暴击"],
		["闪避", "闪避"],
		["回血", "回血"],
		["回魔", "回魔"]
	],
	[["命中", "命中"], ["韧性", "韧性"], ["吸血", "吸血"], ["暴免", "暴免"], ["破甲", "破甲"], ["破魔", "破魔"]],
]
const PET_PACK_CAPACITY := 40
const PET_BACKPACK_SLOT_SCENE := preload("res://Scene/pet/pet_backpack_slot.tscn")
const PET_EQUIPMENT_SLOT_TYPES := ["zbst", "zbmz", "zbxz", "zbyf", "zbjn"]
const PET_EQUIPMENT_SLOT_LABELS := {"zbst": "技能", "zbmz": "衣服", "zbxz": "鞋子", "zbyf": "手套", "zbjn": "帽子"}
const PET_ITEM_STAT_ALIASES := {
	"生命": ["SHp"],
	"魔法": ["SMp"],
	"攻击": ["power"],
	"物防": ["Def"],
	"魔防": ["Mdef"],
	"暴击": ["Crit"],
	"闪避": ["Miss"],
	"命中": ["htarget"],
	"幸运": ["Lucky"],
	"回血": ["R_hp"],
	"回魔": ["R_mp"],
	"破甲": ["ar"],
	"破魔": ["sp"],
	"韧性": ["toughness"],
	"吸血": ["vampirism"],
	"暴免": ["CritReduce"]
}
const PET_ITEM_STAT_DISPLAY_NAMES := {
	"SHp": "生命",
	"SMp": "魔法",
	"power": "攻击",
	"Def": "物防",
	"Mdef": "魔防",
	"Crit": "暴击",
	"Miss": "闪避",
	"R_hp": "回血",
	"R_mp": "回魔",
	"htarget": "命中",
	"Lucky": "幸运",
	"toughness": "韧性",
	"ar": "破甲",
	"sp": "破魔",
	"vampirism": "吸血",
	"CritReduce": "暴免"
}
const PET_BATCH_SELL_STAT_OPTIONS := [
	"生命", "魔法", "攻击", "物防", "魔防", "暴击", "闪避", "幸运", "回血", "回魔", "命中", "破甲", "破魔", "韧性", "吸血", "暴免"
]
const PET_GENERIC_EQUIPMENT_ICON := preload("res://Art/pet/pet_page_resources/pet_interfacev1270_id267_jpeg3_64x64.png")
const PET_SKILL_MP_COSTS := {
	"猛扑": 0,
	"虎啸": 25,
	"嗜血虎爪": 30,
	"横扫千军": 35,
	"奥义": 45,
	"分身": 50,
	"闪电冲刺": 70,
	"雷霆万钧": 90,
	"青龙奥义": 100,
	"水疗盾": 50,
	"同心链接": 70,
	"水湮八荒": 90,
	"玄武奥义": 100,
	"月光": 0,
	"疾风": 70,
	"冰陨": 90,
	"月神奥义": 100,
	"鼠窜": 50,
	"回旋飞镖": 70,
	"子鼠奥义": 100,
	"蛮牛冲撞": 50,
	"蛮力践踏": 75,
	"丑牛奥义": 100,
	"猛虎下山": 70,
	"寅虎奥义": 100
}
const EMPTY_PET := {
	"名称": "空位",
	"等级": 1,
	"经验": 0,
	"下级经验": 100,
	"品质": "普通",
	"生命": 180,
	"生命上限": 180,
	"魔法": 90,
	"魔法上限": 90,
	"攻击": 28,
	"防御": 12,
	"魔防": 10,
	"暴击": 3,
	"闪避": 2,
	"幸运": 1,
	"回血": 1,
	"回魔": 1,
	"悟性": 0,
	"根骨": 0,
	"灵力": 0,
	"生命资质": 1000,
	"生命资质上限": 2000,
	"魔法资质": 1000,
	"魔法资质上限": 2000,
	"攻击资质": 1000,
	"攻击资质上限": 2000,
	"防御资质": 1000,
	"防御资质上限": 2000,
	"潜力": 12,
	"潜力上限": 12,
	"强化点": 0,
	"普通培养次数": 0,
	"超级培养次数": 0,
	"被动技能": {"热血": 0, "魔泉": 0, "狂暴": 0, "永恒": 0, "辉煌": 0, "敏锐": 0},
	"装备": {"zbst": {}, "zbmz": {}, "zbxz": {}, "zbyf": {}, "zbjn": {}},
	"出战": false
}
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
	"生命资质": 2300,
	"生命资质上限": 2500,
	"魔法资质": 1500,
	"魔法资质上限": 1800,
	"攻击资质": 3000,
	"攻击资质上限": 3000,
	"防御资质": 1600,
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

@onready var atebtn := get_node_or_null("atebtn") as BaseButton
@onready var eipbtn := get_node_or_null("eipbtn") as BaseButton
@onready var grmmc := get_node_or_null("grmmc") as BaseButton
@onready var releasebtn := get_node_or_null("releasebtn") as BaseButton
@onready var fightbtn := get_node_or_null("fightbtn") as BaseButton
@onready var restbtn := get_node_or_null("restbtn") as BaseButton
@onready var eatimbtn := get_node_or_null("eatimbtn") as BaseButton
@onready var czjnbtn := get_node_or_null("czjnbtn") as BaseButton
@onready var czsxbtn := get_node_or_null("czsxbtn") as BaseButton
@onready var close_button := get_node_or_null("btn_close") as BaseButton
@onready var next_page := get_node_or_null("nextPage") as BaseButton
@onready var pre_page := get_node_or_null("prePage") as BaseButton
@onready var txtname := get_node_or_null("txtname") as Label
@onready var tiger_level_text := get_node_or_null("TigerLevelText") as Label
@onready var tiger_quality_wx := get_node_or_null("PetAttributeShow/TigerQualityWx") as Label
@onready var tiger_quality_gg := get_node_or_null("PetAttributeShow/TigerQualityGg") as Label
@onready var tiger_quality_ll := get_node_or_null("PetAttributeShow/TigerQualityLl") as Label
@onready var listtxt := get_node_or_null("listtxt") as Label
@onready var qualitymc := get_node_or_null("qualitymc") as CanvasItem
@onready var leveltxt := get_node_or_null("leveltxt") as Label
@onready var expmc := get_node_or_null("expmc") as Label
@onready var hptxt := get_node_or_null("hptxt") as Label
@onready var mptxt := get_node_or_null("mptxt") as Label
@onready var deftxt := get_node_or_null("deftxt") as Label
@onready var atktxt := get_node_or_null("atktxt") as Label
@onready var exptxt := get_node_or_null("exptxt") as Label
@onready var speedtxt := get_node_or_null("speedtxt") as Label
@onready var eamptxt := get_node_or_null("eamptxt") as Label
@onready var mdeftxt := get_node_or_null("mdeftxt") as Label
@onready var crittxt := get_node_or_null("crittxt") as Label
@onready var misstxt := get_node_or_null("misstxt") as Label
@onready var eahptxt := get_node_or_null("eahptxt") as Label

@onready var pet_attribute_show := get_node_or_null("PetAttributeShow") as CanvasItem
@onready var pet_attribute_pages := get_node_or_null("PetAttributePages") as CanvasItem
@onready var learn_skill_button := get_node_or_null("PetAttributeShow/LearnSkillButton") as Button
@onready var pet_formation_button := get_node_or_null("PetAttributeShow/PetFormationButton") as Button
@onready var upgrade_skill_button := get_node_or_null("PetAttributeShow/UpgradeSkillButton") as Button
@onready var pet_skill_learn_popup := get_node_or_null("PetSkillLearnPopup") as Control
@onready var pet_skill_learn_close := get_node_or_null("PetSkillLearnPopup/Window/CloseButton") as BaseButton
@onready var pet_skill_learn_list := get_node_or_null("PetSkillLearnPopup/Window/SkillScroll/SkillList") as VBoxContainer
@onready var pet_skill_learn_template := (
	get_node_or_null("PetSkillLearnPopup/Window/SkillScroll/SkillList/LearnRowTemplate") as PanelContainer
)
@onready var pet_skill_upgrade_popup := get_node_or_null("PetSkillUpgradePopup") as Control
@onready var pet_skill_upgrade_window := get_node_or_null("PetSkillUpgradePopup/Window") as Control
@onready var pet_skill_upgrade_close := get_node_or_null("PetSkillUpgradePopup/Window/CloseButton") as BaseButton
@onready var pet_skill_upgrade_soul := get_node_or_null("PetSkillUpgradePopup/Window/SoulLabel") as Label
@onready
var pet_skill_upgrade_list := get_node_or_null("PetSkillUpgradePopup/Window/SkillScroll/SkillList") as VBoxContainer
@onready var pet_skill_upgrade_template := (
	get_node_or_null("PetSkillUpgradePopup/Window/SkillScroll/SkillList/SkillRowTemplate") as PanelContainer
)
@onready var pet_formation_popup := get_node_or_null("PetFormationPopup") as Control
@onready var pet_formation_close := get_node_or_null("PetFormationPopup/Window/CloseButton") as BaseButton
@onready var pet_formation_resources := get_node_or_null("PetFormationPopup/Window/Resources") as Label
@onready
var pet_formation_list := get_node_or_null("PetFormationPopup/Window/FormationScroll/FormationList") as VBoxContainer
@onready var pet_formation_template := (
	get_node_or_null("PetFormationPopup/Window/FormationScroll/FormationList/FormationRowTemplate") as PanelContainer
)
@onready var hpqualitytxt := get_node_or_null("PetAttributeShow/hpqualitytxt") as Label
@onready var mpqualitytxt := get_node_or_null("PetAttributeShow/mpqualitytxt") as Label
@onready var atkqualitytxt := get_node_or_null("PetAttributeShow/atkqualitytxt") as Label
@onready var defqualitytxt := get_node_or_null("PetAttributeShow/defqualitytxt") as Label
@onready var warpowertxt := get_node_or_null("PetAttributeShow/warpowertxt") as Label
@onready var perceptiontxt := get_node_or_null("PetAttributeShow/perceptiontxt") as Label
@onready var techniquetxt := get_node_or_null("PetAttributeShow/techniquetxt") as Label
@onready var lifetimetxt := get_node_or_null("PetAttributeShow/lifetimetxt") as Label
@onready var skilltxt := get_node_or_null("PetAttributeShow/skilltxt") as Label
@onready var wuxingvaluetxt := get_node_or_null("PetAttributeShow/wuxingvaluetxt") as Label
@onready var genguvaluetxt := get_node_or_null("PetAttributeShow/genguvaluetxt") as Label
@onready var linglivaluext := get_node_or_null("PetAttributeShow/linglivaluext") as Label
@onready var hpzizhitxt := get_node_or_null("PetAttributeShow/shape10_生命/hpzizhitxt") as Label
@onready var mpzizhitxt := get_node_or_null("PetAttributeShow/shape10_魔法/mpzizhitxt") as Label
@onready var atkzizhitxt := get_node_or_null("PetAttributeShow/shape10_攻击/atkzizhitxt") as Label
@onready var defzizhitxt := get_node_or_null("PetAttributeShow/shape10_防御/defzizhitxt") as Label
@onready var hpzizhibar := get_node_or_null("PetAttributeShow/shape10_生命/hpzizhibar") as TextureProgressBar
@onready var mpzizhibar := get_node_or_null("PetAttributeShow/shape10_魔法/mpzizhibar") as TextureProgressBar
@onready var atkzizhibar := get_node_or_null("PetAttributeShow/shape10_攻击/atkzizhibar") as TextureProgressBar
@onready var defzizhibar := get_node_or_null("PetAttributeShow/shape10_防御/defzizhibar") as TextureProgressBar
@onready var hpzizhibtn := get_node_or_null("PetAttributeShow/shape10_生命/hpzizhibtn") as BaseButton
@onready var mpzizhibtn := get_node_or_null("PetAttributeShow/shape10_魔法/mpzizhibtn") as BaseButton
@onready var atkzizhibtn := get_node_or_null("PetAttributeShow/shape10_攻击/atkzizhibtn") as BaseButton
@onready var defzizhibtn := get_node_or_null("PetAttributeShow/shape10_防御/defzizhibtn") as BaseButton
@onready var wuxingbtn := get_node_or_null("PetAttributeShow/shape10_悟性/mpzizhibtn") as BaseButton
@onready var gengubtn := get_node_or_null("PetAttributeShow/shape10_根骨/mpzizhibtn") as BaseButton
@onready var linglibtn := get_node_or_null("PetAttributeShow/shape10_灵力/mpzizhibtn") as BaseButton

@onready var pet_backpack_show := get_node_or_null("PetBackPackShow") as CanvasItem
@onready var pbpbtn := get_node_or_null("PetBackPackShow/pbpbtn") as BaseButton
@onready var pstrbtn := get_node_or_null("PetBackPackShow/pstrbtn") as BaseButton
@onready var zbst := get_node_or_null("PetBackPackShow/zbst") as BaseButton
@onready var zbmz := get_node_or_null("PetBackPackShow/zbmz") as BaseButton
@onready var zbxz := get_node_or_null("PetBackPackShow/zbxz") as BaseButton
@onready var zbyf := get_node_or_null("PetBackPackShow/zbyf") as BaseButton
@onready var zbjn := get_node_or_null("PetBackPackShow/zbjn") as BaseButton
@onready var pet_backpack_grid := get_node_or_null("PetBackPackShow/PetBackpackScroll/PetBackpackGrid") as GridContainer
@onready var pet_batch_sell_button := get_node_or_null("PetBackPackShow/PetBatchSellButton") as BaseButton
@onready var pet_strength_interface := get_node_or_null("PetBackPackShow/PetStrengthInterface") as CanvasItem
@onready var str_ntxt := get_node_or_null("PetBackPackShow/PetStrengthInterface/ntxt") as Label
@onready var str_atxt := get_node_or_null("PetBackPackShow/PetStrengthInterface/atxt") as Label
@onready var str_protxt := get_node_or_null("PetBackPackShow/PetStrengthInterface/protxt") as Label
@onready var str_ttxt := get_node_or_null("PetBackPackShow/PetStrengthInterface/ttxt") as Label
@onready var str_expmc := get_node_or_null("PetBackPackShow/PetStrengthInterface/expmc") as Label
@onready var str_dtxt := get_node_or_null("PetBackPackShow/PetStrengthInterface/dtxt") as Label
@onready var str_etxt := get_node_or_null("PetBackPackShow/PetStrengthInterface/etxt") as Label
@onready var buyqh := get_node_or_null("PetBackPackShow/PetStrengthInterface/buyqh") as BaseButton
@onready var strbtn := get_node_or_null("PetBackPackShow/PetStrengthInterface/strbtn") as BaseButton

@onready var pet_develop_interface := get_node_or_null("PetDevelopInterface") as CanvasItem
@onready var qltxt := get_node_or_null("PetDevelopInterface/qltxt") as Label
@onready var wxbar := get_node_or_null("PetDevelopInterface/wxmc") as TextureProgressBar
@onready var wxtxt := get_node_or_null("PetDevelopInterface/wxtxt") as Label
@onready var ggbar := get_node_or_null("PetDevelopInterface/ggmc") as TextureProgressBar
@onready var ggtxt := get_node_or_null("PetDevelopInterface/ggtxt") as Label
@onready var llbar := get_node_or_null("PetDevelopInterface/llmc") as TextureProgressBar
@onready var lltxt := get_node_or_null("PetDevelopInterface/lltxt") as Label
@onready var qlbar := get_node_or_null("PetDevelopInterface/qlmc") as TextureProgressBar
@onready var qljxtxt := get_node_or_null("PetDevelopInterface/qljxtxt") as Label
@onready var wxplus := get_node_or_null("PetDevelopInterface/wxplus") as BaseButton
@onready var ggplus := get_node_or_null("PetDevelopInterface/ggplus") as BaseButton
@onready var llplus := get_node_or_null("PetDevelopInterface/llplus") as BaseButton
@onready var qplus := get_node_or_null("PetDevelopInterface/qplus") as BaseButton
@onready var sbtn := get_node_or_null("PetDevelopInterface/sbtn") as BaseButton
@onready var nbtn := get_node_or_null("PetDevelopInterface/nbtn") as BaseButton
@onready var ntxt := get_node_or_null("PetDevelopInterface/ntxt") as Label
@onready var etxt := get_node_or_null("PetDevelopInterface/etxt") as Label
@onready var dtxt := get_node_or_null("PetDevelopInterface/dtxt") as Label
@onready var pet_eat_immortality := get_node_or_null("PetDevelopInterface/PetEatImmortality") as CanvasItem
@onready var pet_eat_close := get_node_or_null("PetDevelopInterface/PetEatImmortality/btn_close") as BaseButton

@onready var give_up_this_pet := get_node_or_null("giveUpThisPet") as CanvasItem
@onready var give_up_okbtn := get_node_or_null("giveUpThisPet/okbtn") as BaseButton
@onready var give_up_nobtn := get_node_or_null("giveUpThisPet/nobtn") as BaseButton

var current_page: PetPage = PetPage.ATTRIBUTE
var current_pet_index: int = -1
var current_pack_index: int = 0
var pet_pack_slots: Array[PetBackpackSlot] = []
var pet_tiger_added_this_open: bool = false
var pet_list_scroll: ScrollContainer = null
var pet_list_dropdown: VBoxContainer = null
var _pet_touch_scrolls: Array[ScrollContainer] = []
var _pet_touch_scroll: ScrollContainer = null
var _pet_touch_last_y: float = 0.0
var pet_model_preview: AnimatedSprite2D = null
var _pet_skill_grid: Control = null
var pet_model_frames: SpriteFrames = null
var tiger_quality_labels: Dictionary = {}
var pet_passive_panel: PanelContainer = null
var pet_passive_level_labels: Dictionary = {}
var pet_passive_effect_labels: Dictionary = {}
var pet_passive_cost_labels: Dictionary = {}
var pet_passive_upgrade_buttons: Dictionary = {}
var pet_passive_limit_label: Label = null
var pet_passive_one_key_button: Button = null
var pet_action_menu: Control = null
var pet_property_popup: Node2D = null
var pet_equipment_slot_empty_style := StyleBoxEmpty.new()
var pet_equipment_slot_filled_style: StyleBoxTexture = null
var pet_attribute_page: int = 0
var pet_attribute_stat_rows: Array[Control] = []
var pet_attribute_stat_names: Array[Label] = []
var pet_attribute_stat_values: Array[Label] = []
var pet_attribute_page_buttons: Array[Button] = []
var pending_pet_sale: Dictionary = {}
var pet_batch_sell_confirm: Control = null
var pet_batch_sell_settings: Dictionary = {}
var pet_batch_sell_summary_label: Label = null
var pet_batch_sell_stat_buttons: Array[Button] = []
var pet_batch_sell_stat_menu: Control = null
var pet_batch_sell_stat_scroll: ScrollContainer = null
var pet_batch_sell_touch_start_y := 0.0
var pet_batch_sell_touch_dragged := false
var pet_skill_upgrade_success_tip: CanvasItem = null
var pet_formation_rows: Dictionary = {}
var _quality_feed_hold_button: BaseButton = null
var _quality_feed_hold_config: Dictionary = {}
var _quality_feed_hold_elapsed := 0.0
var _quality_feed_repeat_elapsed := 0.0
var _quality_feed_repeating := false
var _quality_feed_suppress_click := false
var _pet_passive_hold_button: BaseButton = null
var _pet_passive_hold_skill := ""
var _pet_passive_hold_elapsed := 0.0
var _pet_passive_repeat_elapsed := 0.0
var _pet_passive_repeating := false
var _pet_passive_suppress_click := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	current_pet_index = -1
	_ensure_pet_storage()
	_connect_button(close_button, queue_free)
	_connect_button(next_page, _next_pet)
	_connect_button(pre_page, _previous_pet)
	_connect_button(atebtn, ate_click)
	_connect_button(eipbtn, eip_click)
	_connect_button(grmmc, groom_click)
	_connect_button(releasebtn, release_click)

	_connect_button(restbtn, fight_click)
	_connect_button(fightbtn, rest_click)
	_connect_button(eatimbtn, eat_immor)
	_connect_button(czjnbtn, push_pet_skill)
	_connect_button(czsxbtn, push_pet_attribute)
	_connect_button(give_up_okbtn, ok_click)
	_connect_button(give_up_nobtn, no_click)
	_connect_button(pbpbtn, pet_backpack_click)
	_connect_button(pstrbtn, pet_strength_click)
	_connect_button(wxplus, wxplus_click)
	_connect_button(ggplus, ggplus_click)
	_connect_button(llplus, llplus_click)
	_connect_button(qplus, qplus_click)
	_connect_quality_feed_button(hpzizhibtn, "生命资质", "生命资质上限", "zizhiguo")
	_connect_quality_feed_button(mpzizhibtn, "魔法资质", "魔法资质上限", "zizhiguo")
	_connect_quality_feed_button(atkzizhibtn, "攻击资质", "攻击资质上限", "zizhiguo")
	_connect_quality_feed_button(defzizhibtn, "防御资质", "防御资质上限", "zizhiguo")
	_connect_button(wuxingbtn, _on_develop_fruit_pressed.bind("悟性"))
	_connect_button(gengubtn, _on_develop_fruit_pressed.bind("根骨"))
	_connect_button(linglibtn, _on_develop_fruit_pressed.bind("灵力"))
	_connect_button(sbtn, super_click)
	_connect_button(nbtn, aoyi_click)
	_connect_button(pet_eat_close, _close_eat_window)
	_connect_button(learn_skill_button, _on_learn_skill_pressed)
	_connect_button(pet_formation_button, _on_pet_formation_pressed)
	_connect_button(upgrade_skill_button, _on_upgrade_skill_pressed)
	_connect_button(pet_skill_learn_close, _close_pet_skill_learn_popup)
	_connect_button(pet_skill_upgrade_close, _close_pet_skill_upgrade_popup)
	_connect_button(pet_formation_close, _close_pet_formation_popup)
	_setup_pet_attribute_pages()
	_setup_pet_name_list()
	_setup_pet_model_preview()
	_setup_tiger_quality_preview()
	_setup_pet_passive_panel()
	_setup_pet_formation_popup()
	_setup_pet_backpack()
	_connect_button(pet_batch_sell_button, _on_pet_batch_sell_pressed)
	_connect_button(zbst, _on_pet_equipment_slot_pressed.bind("zbst"))
	_connect_button(zbmz, _on_pet_equipment_slot_pressed.bind("zbmz"))
	_connect_button(zbxz, _on_pet_equipment_slot_pressed.bind("zbxz"))
	_connect_button(zbyf, _on_pet_equipment_slot_pressed.bind("zbyf"))
	_connect_button(zbjn, _on_pet_equipment_slot_pressed.bind("zbjn"))
	_connect_pet_hover(zbst, _on_pet_equipment_mouse_entered.bind("zbst"), _on_pet_equipment_mouse_exited)
	_connect_pet_hover(zbmz, _on_pet_equipment_mouse_entered.bind("zbmz"), _on_pet_equipment_mouse_exited)
	_connect_pet_hover(zbxz, _on_pet_equipment_mouse_entered.bind("zbxz"), _on_pet_equipment_mouse_exited)
	_connect_pet_hover(zbyf, _on_pet_equipment_mouse_entered.bind("zbyf"), _on_pet_equipment_mouse_exited)
	_connect_pet_hover(zbjn, _on_pet_equipment_mouse_entered.bind("zbjn"), _on_pet_equipment_mouse_exited)
	_connect_button(strbtn, _on_strength_pressed)
	_connect_button(buyqh, _on_buy_strength_pressed)
	for i in range(1, 9):
		_connect_button(
			get_node_or_null("PetDevelopInterface/PetEatImmortality/mc%d" % i) as BaseButton,
			_on_eat_item_pressed.bind(i)
		)
	ate_click()
	_refresh_all()
	_register_pet_scrolls_in_tree(self)


func _input(event: InputEvent) -> void:
	if is_instance_valid(pet_batch_sell_stat_menu):
		var pointer_position := Vector2.ZERO
		var pointer_pressed := false
		if event is InputEventScreenTouch:
			pointer_position = event.position
			pointer_pressed = event.pressed
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			pointer_position = event.position
			pointer_pressed = event.pressed
		if pointer_pressed and not pet_batch_sell_stat_menu.get_global_rect().has_point(pointer_position):
			_close_pet_batch_sell_stat_menu()

	if event is InputEventScreenTouch:
		if event.pressed:
			_pet_touch_scroll = null
			for index in range(_pet_touch_scrolls.size() - 1, -1, -1):
				var scroll := _pet_touch_scrolls[index]
				if (
					is_instance_valid(scroll)
					and scroll.is_visible_in_tree()
					and scroll.get_global_rect().has_point(event.position)
				):
					_pet_touch_scroll = scroll
					break
			if _pet_touch_scroll != null:
				_pet_touch_last_y = event.position.y
				if _pet_touch_scroll == pet_batch_sell_stat_scroll:
					pet_batch_sell_touch_start_y = event.position.y
					pet_batch_sell_touch_dragged = false
		else:
			_pet_touch_scroll = null
	elif event is InputEventScreenDrag and _pet_touch_scroll != null and is_instance_valid(_pet_touch_scroll):
		var delta_y: float = event.position.y - _pet_touch_last_y
		if (
			_pet_touch_scroll == pet_batch_sell_stat_scroll
			and absf(event.position.y - pet_batch_sell_touch_start_y) >= 8.0
		):
			pet_batch_sell_touch_dragged = true
		_pet_touch_scroll.scroll_vertical = maxi(0, _pet_touch_scroll.scroll_vertical - roundi(delta_y))
		_pet_touch_last_y = event.position.y
		get_viewport().set_input_as_handled()


func _register_pet_scroll(scroll: ScrollContainer) -> void:
	if scroll == null or not is_instance_valid(scroll):
		return
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.scroll_deadzone = 8
	scroll.follow_focus = false
	if not _pet_touch_scrolls.has(scroll):
		_pet_touch_scrolls.append(scroll)


func _register_pet_scrolls_in_tree(node: Node) -> void:
	if node is ScrollContainer:
		_register_pet_scroll(node as ScrollContainer)
	for child in node.get_children():
		_register_pet_scrolls_in_tree(child)


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_pet_model_preview_layout()
		_center_pet_batch_sell_confirm()


func _process(delta: float) -> void:
	if is_instance_valid(pet_property_popup):
		_position_pet_property_popup_at_mouse()
	_process_quality_feed_hold(delta)
	_process_pet_passive_hold(delta)


func ate_click() -> void:
	current_page = PetPage.ATTRIBUTE
	_set_visible(pet_attribute_show, true)
	_set_visible(pet_backpack_show, false)
	_set_visible(pet_develop_interface, false)
	_set_tab_state(PetPage.ATTRIBUTE)
	_hide_sub_windows()
	_refresh_all()


func eip_click() -> void:
	_ensure_pet_storage()
	current_page = PetPage.BACKPACK
	_set_visible(pet_attribute_show, false)
	_set_visible(pet_backpack_show, true)
	_set_visible(pet_develop_interface, false)
	_set_tab_state(PetPage.BACKPACK)
	_hide_sub_windows()
	_refresh_all()


func groom_click() -> void:
	current_page = PetPage.DEVELOP
	_set_visible(pet_attribute_show, false)
	_set_visible(pet_backpack_show, false)
	_set_visible(pet_develop_interface, true)
	_set_tab_state(PetPage.DEVELOP)
	_hide_sub_windows()
	_refresh_all()


func release_click() -> void:
	var pet: Variant = _current_pet()
	if pet == null:
		_show_tip("当前没有宠物")
		return
	if pet is Dictionary and _is_pet_rabbit(pet):
		_show_tip("月兔为永久解锁宠物，无法放生")
		return
	_set_visible(give_up_this_pet, true)


func _select_tiger_pet_if_available() -> Dictionary:
	var pets := _pet_list()
	for i in pets.size():
		var item: Variant = pets[i]
		if item is Dictionary and _is_pet_tiger(item):
			current_pet_index = i
			return item
	return {}


func _pet_active_name(pet: Dictionary) -> String:
	var type_name := str(pet.get(DataKeys.TYPE, ""))
	if type_name == "PetNeat" or _is_pet_neat(pet):
		return "PetNeat"
	if type_name == "PetYinTiger" or _is_pet_yin_tiger(pet):
		return "PetYinTiger"
	if type_name == "PetMouse" or _is_pet_mouse(pet):
		return "PetMouse"
	if type_name == "PetRabbit" or _is_pet_rabbit(pet):
		return "PetRabbit"
	if type_name == "PetTurtle" or _is_pet_turtle(pet):
		return "PetTurtle"
	if _is_pet_phoenix(pet):
		return "PetPhoenix"
	if type_name == "PetTiger" or _is_pet_tiger(pet):
		return "PetTiger"
	if type_name == "PetDragon" or _is_pet_dragon(pet):
		return "PetDragon"
	return str(pet.get(DataKeys.ALT_NAME, ""))


func _clear_pet_active_state(pet: Dictionary) -> void:
	var data := _data()
	var active_key := _active_pet_key()
	var active_name := str(data.get(active_key, ""))
	var valid_names := [_pet_active_name(pet), str(pet.get(DataKeys.ALT_NAME, "")), str(pet.get(DataKeys.NAME, ""))]
	if _is_pet_tiger(pet):
		valid_names.append("PetTiger")
	if _is_pet_dragon(pet):
		valid_names.append("PetDragon")
	if _is_pet_phoenix(pet):
		valid_names.append("PetPhoenix")
	if _is_pet_turtle(pet):
		valid_names.append("PetTurtle")
	if _is_pet_rabbit(pet):
		valid_names.append("PetRabbit")
	if _is_pet_mouse(pet):
		valid_names.append("PetMouse")
	if _is_pet_neat(pet):
		valid_names.append("PetNeat")
	if _is_pet_yin_tiger(pet):
		valid_names.append("PetYinTiger")
	if active_name in valid_names or not bool(pet.get(DataKeys.DEPLOYED, false)):
		data[active_key] = ""
	data["出战宠物"] = str(data.get(active_key, ""))


func fight_click() -> void:
	var pet: Variant = _current_pet()
	if pet == null:
		_show_tip("当前没有宠物")
		return
	if not (pet is Dictionary):
		_show_tip("当前宠物不能出战")
		return
	_repair_phoenix_pet_data(pet)
	if _is_pet_mouse(pet):
		_normalize_pet_mouse_name(pet)
		_update_pet_mouse_evolution(pet)
	elif _is_pet_neat(pet):
		_normalize_pet_neat_name(pet)
		_update_pet_neat_evolution(pet)
	elif _is_pet_yin_tiger(pet):
		_normalize_pet_yin_tiger_name(pet)
		_update_pet_yin_tiger_evolution(pet)
	elif _is_pet_rabbit(pet):
		_normalize_pet_rabbit_name(pet)
		_update_pet_rabbit_evolution(pet)
	elif _is_pet_phoenix(pet):
		pet[DataKeys.TYPE] = "PetPhoenix"
		pet[DataKeys.ALT_NAME] = str(pet.get(DataKeys.ALT_NAME, pet.get(DataKeys.NAME, "雀蛋")))
		pet[DataKeys.NAME] = str(pet.get(DataKeys.ALT_NAME, pet.get(DataKeys.NAME, "雀蛋")))
		_normalize_pet_phoenix_name(pet)
		_update_pet_phoenix_evolution(pet)
	elif _is_pet_turtle(pet):
		_normalize_pet_turtle_name(pet)
		_update_pet_turtle_evolution(pet)
	elif _is_pet_tiger(pet):
		_normalize_pet_tiger_name(pet)
		_update_pet_tiger_evolution(pet)
	elif _is_pet_dragon(pet):
		_normalize_pet_dragon_name(pet)
		_update_pet_dragon_evolution(pet)
	else:
		_show_tip("当前宠物不能出战")
		return
	if _is_pet_dead_in_current_level(str(pet.get(DataKeys.ALT_NAME, ""))):
		_show_tip("宠物本局已死亡，不能再出战")
		pet[DataKeys.DEPLOYED] = false
		_clear_pet_active_state(pet)
		_refresh_all()
		return
	_recalculate_pet_growth_stats(pet, false)
	for item in _pet_list():
		if item is Dictionary:
			item[DataKeys.DEPLOYED] = false
	pet[DataKeys.DEPLOYED] = true
	var active_name := _pet_active_name(pet)
	_data()[_active_pet_key()] = active_name
	_data()["出战宠物"] = active_name
	_refresh_all()
	_despawn_active_pet_now()
	_spawn_active_pet_now()


func rest_click() -> void:
	var pet: Variant = _current_pet()
	if pet == null:
		_show_tip("当前没有宠物")
		return
	pet[DataKeys.DEPLOYED] = false
	_clear_pet_active_state(pet)
	_despawn_active_pet_now()
	_refresh_all()


func _next_pet() -> void:
	var pets := _pet_list()
	if pets.is_empty():
		return
	_close_pet_action_menu()
	_hide_pet_property_popup()
	current_pet_index = (current_pet_index + 1) % pets.size()
	current_pack_index = 0
	_refresh_all()


func _setup_pet_attribute_pages() -> void:
	pet_attribute_stat_rows.clear()
	pet_attribute_stat_names.clear()
	pet_attribute_stat_values.clear()
	pet_attribute_page_buttons.clear()
	for index in range(10):
		var row := get_node_or_null("PetAttributePages/StatRow%d" % (index + 1)) as Control
		var stat_name := get_node_or_null("PetAttributePages/StatRow%d/Name" % (index + 1)) as Label
		var stat_value := get_node_or_null("PetAttributePages/StatRow%d/Value" % (index + 1)) as Label
		if row == null or stat_name == null or stat_value == null:
			continue
		pet_attribute_stat_rows.append(row)
		pet_attribute_stat_names.append(stat_name)
		pet_attribute_stat_values.append(stat_value)
	for page_index in range(2):
		var page_button := get_node_or_null("PetStatPage%d" % (page_index + 1)) as Button
		if page_button == null:
			continue
		_connect_button(page_button, _on_pet_attribute_page_pressed.bind(page_index))
		pet_attribute_page_buttons.append(page_button)
	_update_pet_attribute_page_buttons()


func _on_pet_attribute_page_pressed(page_index: int) -> void:
	pet_attribute_page = clampi(page_index, 0, PET_ATTRIBUTE_PAGES.size() - 1)
	_refresh_pet_attribute_page(_current_pet())


func _setup_pet_formation_popup() -> void:
	pet_formation_rows.clear()
	if pet_formation_list == null or pet_formation_template == null:
		return
	for index in PET_FORMATION_DEFINITIONS.size():
		var definition: Dictionary = PET_FORMATION_DEFINITIONS[index]
		var row := pet_formation_template.duplicate() as PanelContainer
		row.name = "FormationRow_%d" % index
		row.visible = true
		pet_formation_list.add_child(row)
		var stat_name := str(definition["stat"])
		var upgrade_button := row.get_node_or_null("Content/UpgradeButton") as Button
		_connect_button(upgrade_button, _upgrade_pet_formation.bind(stat_name))
		var upgrade_ten_button := row.get_node_or_null("Content/UpgradeTenButton") as Button
		_connect_button(upgrade_ten_button, _upgrade_pet_formation_ten.bind(stat_name))
		pet_formation_rows[stat_name] = row


func _on_pet_formation_pressed() -> void:
	if not (_current_pet() is Dictionary):
		_show_tip("当前没有宠物")
		return
	_refresh_pet_formation_popup()
	_set_visible(pet_formation_popup, true)


func _close_pet_formation_popup() -> void:
	_set_visible(pet_formation_popup, false)


func _pet_formation_levels() -> Dictionary:
	if PlayerData != null and PlayerData.has_method("get_pet_formation_levels"):
		return PlayerData.get_pet_formation_levels()
	var levels_value: Variant = _data().get("宠物阵法等级", {})
	var levels: Dictionary = levels_value if levels_value is Dictionary else {}
	_data()["宠物阵法等级"] = levels
	return levels


func _pet_formation_definition(stat_name: String) -> Dictionary:
	for definition in PET_FORMATION_DEFINITIONS:
		if str(definition.get("stat", "")) == stat_name:
			return definition
	return {}


func _pet_formation_cost(level: int) -> Vector2i:
	var stone_cost := clampi(level, 0, PET_FORMATION_MAX_LEVEL) + 2
	return Vector2i(stone_cost, ceili(float(stone_cost) * 0.5))


func _pet_formation_stat_value(level: int, gain_per_level: int) -> int:
	if PlayerData != null and PlayerData.has_method("pet_formation_stat_value"):
		return int(PlayerData.pet_formation_stat_value(level, gain_per_level))
	var safe_level := clampi(level, 0, PET_FORMATION_MAX_LEVEL)
	return roundi(float(safe_level * gain_per_level) * (1.0 + float(floori(float(safe_level) / 10.0)) * 0.1))


func _refresh_pet_formation_popup() -> void:
	var levels := _pet_formation_levels()
	_set_label(
		pet_formation_resources,
		(
			"朱雀晶石 %d  晶核 %d    玄武晶石 %d  晶核 %d"
			% [_item_count("zqjs"), _item_count("zqjh"), _item_count("xwjs"), _item_count("xwjh")]
		)
	)
	for definition in PET_FORMATION_DEFINITIONS:
		var stat_name := str(definition["stat"])
		var row: PanelContainer = pet_formation_rows.get(stat_name) as PanelContainer
		if row == null:
			continue
		var level := clampi(int(levels.get(stat_name, 0)), 0, PET_FORMATION_MAX_LEVEL)
		var gain := int(definition["gain"])
		var cost := _pet_formation_cost(level)
		var current_value := _pet_formation_stat_value(level, gain)
		var next_value := _pet_formation_stat_value(mini(level + 1, PET_FORMATION_MAX_LEVEL), gain)
		_set_label(row.get_node_or_null("Content/Name") as Label, stat_name)
		_set_label(row.get_node_or_null("Content/Level") as Label, "Lv.%d/%d" % [level, PET_FORMATION_MAX_LEVEL])
		_set_label(
			row.get_node_or_null("Content/Effect") as Label,
			(
				"当前 +%d" % current_value
				if level >= PET_FORMATION_MAX_LEVEL
				else "当前 +%d  下级 +%d" % [current_value, next_value]
			)
		)
		_set_label(
			row.get_node_or_null("Content/Cost") as Label,
			(
				"已达等级上限"
				if level >= PET_FORMATION_MAX_LEVEL
				else "%s×%d\n%s×%d" % [str(definition["stone_name"]), cost.x, str(definition["core_name"]), cost.y]
			)
		)
		var upgrade_button := row.get_node_or_null("Content/UpgradeButton") as Button
		if upgrade_button != null:
			upgrade_button.disabled = level >= PET_FORMATION_MAX_LEVEL
			upgrade_button.text = "满级" if level >= PET_FORMATION_MAX_LEVEL else "升级"
		var upgrade_ten_button := row.get_node_or_null("Content/UpgradeTenButton") as Button
		if upgrade_ten_button != null:
			upgrade_ten_button.disabled = level >= PET_FORMATION_MAX_LEVEL
			upgrade_ten_button.text = "满级" if level >= PET_FORMATION_MAX_LEVEL else "升十级"


func _upgrade_pet_formation(stat_name: String) -> void:
	var definition := _pet_formation_definition(stat_name)
	if definition.is_empty():
		return
	if not _upgrade_pet_formation_once(stat_name):
		_show_pet_formation_upgrade_failure(stat_name)
		return
	var levels := _pet_formation_levels()
	var level := clampi(int(levels.get(stat_name, 0)), 0, PET_FORMATION_MAX_LEVEL)
	_refresh_pet_formation_popup()
	_show_tip("%s阵法升级至Lv.%d" % [stat_name, level])


func _upgrade_pet_formation_ten(stat_name: String) -> void:
	var upgraded_count := 0
	for _index in range(10):
		if not _upgrade_pet_formation_once(stat_name):
			break
		upgraded_count += 1
	if upgraded_count <= 0:
		_show_pet_formation_upgrade_failure(stat_name)
		return
	var levels := _pet_formation_levels()
	var level := clampi(int(levels.get(stat_name, 0)), 0, PET_FORMATION_MAX_LEVEL)
	_refresh_pet_formation_popup()
	_show_tip("%s阵法升级%d级，当前Lv.%d" % [stat_name, upgraded_count, level])


func _upgrade_pet_formation_once(stat_name: String) -> bool:
	var definition := _pet_formation_definition(stat_name)
	if definition.is_empty():
		return false
	var levels := _pet_formation_levels()
	var level := clampi(int(levels.get(stat_name, 0)), 0, PET_FORMATION_MAX_LEVEL)
	if level >= PET_FORMATION_MAX_LEVEL:
		return false
	var cost := _pet_formation_cost(level)
	var stone_id := str(definition["stone"])
	var core_id := str(definition["core"])
	if _item_count(stone_id) < cost.x or _item_count(core_id) < cost.y:
		return false
	PlayerData.remove_dj(stone_id, PlayerData.get_dj_page(stone_id), cost.x)
	PlayerData.remove_dj(core_id, PlayerData.get_dj_page(core_id), cost.y)
	levels[stat_name] = level + 1
	_refresh_current_pet()
	for pet_value in _pet_list():
		if pet_value is Dictionary and bool(pet_value.get(DataKeys.DEPLOYED, false)):
			_refresh_live_pet_passives(pet_value)
			break
	_save_pet_changes()
	return true


func _show_pet_formation_upgrade_failure(stat_name: String) -> void:
	var definition := _pet_formation_definition(stat_name)
	if definition.is_empty():
		return
	var levels := _pet_formation_levels()
	var level := clampi(int(levels.get(stat_name, 0)), 0, PET_FORMATION_MAX_LEVEL)
	if level >= PET_FORMATION_MAX_LEVEL:
		_show_tip("%s阵法已满级" % stat_name)
		return
	var cost := _pet_formation_cost(level)
	_show_tip("需要%s×%d、%s×%d" % [str(definition["stone_name"]), cost.x, str(definition["core_name"]), cost.y])


func _on_learn_skill_pressed() -> void:
	var pet: Variant = _current_pet()
	if not (pet is Dictionary):
		_show_tip("当前没有宠物")
		return
	_refresh_pet_skill_learn_popup()
	_set_visible(pet_skill_learn_popup, true)


func _close_pet_skill_learn_popup() -> void:
	_set_visible(pet_skill_learn_popup, false)


func _refresh_pet_skill_learn_popup() -> void:
	if pet_skill_learn_list == null or pet_skill_learn_template == null:
		return
	var pet: Variant = _current_pet()
	var learned_skills: Array = _pet_skills(pet) if pet is Dictionary else []
	for child in pet_skill_learn_list.get_children():
		if child != pet_skill_learn_template:
			child.queue_free()
	for index in PET_LEARNABLE_SKILLS.size():
		var definition: Dictionary = PET_LEARNABLE_SKILLS[index]
		var skill_name := str(definition["name"])
		var book_id := str(definition["book"])
		var row := pet_skill_learn_template.duplicate() as PanelContainer
		row.name = "LearnRow_%d" % index
		row.visible = true
		pet_skill_learn_list.add_child(row)
		var icon := row.get_node_or_null("Content/Icon") as TextureRect
		var name_label := row.get_node_or_null("Content/Name") as Label
		var description_label := row.get_node_or_null("Content/Description") as Label
		var book_label := row.get_node_or_null("Content/BookCount") as Label
		var learn_button := row.get_node_or_null("Content/LearnButton") as Button
		if icon != null:
			icon.texture = load("res://Art/pet/skillicon/%s.png" % str(definition["icon"])) as Texture2D
		_set_label(name_label, skill_name)
		_set_label(description_label, str(definition["description"]))
		_set_label(book_label, "技能书：%d" % _item_count(book_id))
		if learn_button != null:
			var learned := learned_skills.has(skill_name)
			learn_button.text = "已学习" if learned else "学习"
			learn_button.disabled = learned
			_connect_button(learn_button, _learn_pet_skill.bind(skill_name, book_id))


func _learn_pet_skill(skill_name: String, book_id: String) -> void:
	var pet: Variant = _current_pet()
	if not (pet is Dictionary):
		_show_tip("当前没有宠物")
		return
	var skills := _pet_skills(pet)
	if skills.has(skill_name):
		_show_tip("该宠物已经学习%s" % skill_name)
		_refresh_pet_skill_learn_popup()
		return
	if _item_count(book_id) < 1:
		_show_tip("缺少%s技能书" % skill_name)
		return
	PlayerData.remove_dj(book_id, PlayerData.get_dj_page(book_id), 1)
	var learned_skills: Variant = pet.get(PET_LEARNED_SKILLS_KEY, [])
	if not (learned_skills is Array):
		learned_skills = []
	if not learned_skills.has(skill_name):
		learned_skills.append(skill_name)
	pet[PET_LEARNED_SKILLS_KEY] = learned_skills
	var stored_skills: Variant = pet.get("技能", [])
	if not (stored_skills is Array):
		stored_skills = []
	stored_skills.append(skill_name)
	pet["技能"] = stored_skills
	var levels := PET_SKILL_PROGRESSION.ensure_levels(pet)
	levels[skill_name] = 1
	_refresh_current_pet()
	_refresh_pet_skill_icons(pet)
	_refresh_pet_skill_learn_popup()
	_refresh_live_pet_passives(pet)
	_save_pet_changes()
	_show_tip("已学习%s" % skill_name)


func _on_upgrade_skill_pressed() -> void:
	var pet: Variant = _current_pet()
	if not (pet is Dictionary):
		_show_tip("当前没有宠物")
		return
	if _pet_skills(pet).is_empty():
		_show_tip("当前宠物还没有可升级技能")
		return
	PET_SKILL_PROGRESSION.ensure_levels(pet)
	_refresh_pet_skill_upgrade_popup()
	_set_visible(pet_skill_upgrade_popup, true)


func _close_pet_skill_upgrade_popup() -> void:
	_set_visible(pet_skill_upgrade_popup, false)


func _pet_skills(pet: Dictionary) -> Array:
	var raw_skills: Variant = pet.get("技能", [])
	var skills: Array = raw_skills.duplicate(true) if raw_skills is Array else []
	if skills.is_empty() and _is_pet_tiger(pet):
		skills = _pet_tiger_stage_skills(clampi(int(pet.get("阶段", 1)), 1, 4))
	elif skills.is_empty() and _is_pet_mouse(pet):
		skills = _pet_mouse_skills_for_level(int(pet.get(DataKeys.LEVEL, 1)))
	elif skills.is_empty() and _is_pet_yin_tiger(pet):
		skills = (PET_YIN_TIGER_STAGE_SKILLS[clampi(int(pet.get("阶段", 1)), 1, 4)] as Array).duplicate(true)
	if _is_pet_tiger(pet):
		skills.erase("猛扑")
	for learned_skill in _learned_pet_skills(pet):
		if not skills.has(learned_skill):
			skills.append(learned_skill)
	pet["技能"] = skills.duplicate(true)
	return skills


func _learned_pet_skills(pet: Dictionary) -> Array:
	var learned_skills: Array = []
	for source_key in [PET_LEARNED_SKILLS_KEY, "技能"]:
		var source: Variant = pet.get(source_key, [])
		if not (source is Array):
			continue
		for raw_skill in source:
			var skill_name := str(raw_skill)
			if not _learned_skill_book_id(skill_name).is_empty() and not learned_skills.has(skill_name):
				learned_skills.append(skill_name)
	var levels: Variant = pet.get(PET_SKILL_PROGRESSION.LEVELS_KEY, {})
	if levels is Dictionary:
		for raw_skill in levels.keys():
			var skill_name := str(raw_skill)
			if not _learned_skill_book_id(skill_name).is_empty() and not learned_skills.has(skill_name):
				learned_skills.append(skill_name)
	pet[PET_LEARNED_SKILLS_KEY] = learned_skills.duplicate(true)
	return learned_skills


func _learned_skill_book_id(skill_name: String) -> String:
	for definition in PET_LEARNABLE_SKILLS:
		if str(definition.get("name", "")) == skill_name:
			return str(definition.get("book", ""))
	return ""


func _learned_skill_upgrade_book_count(current_level: int) -> int:
	return clampi(current_level, 1, PET_SKILL_PROGRESSION.MAX_LEVEL) + 1


func _refresh_pet_skill_upgrade_popup() -> void:
	if pet_skill_upgrade_list == null or pet_skill_upgrade_template == null:
		return
	_set_label(pet_skill_upgrade_soul, "灵魂：%d" % PlayerData.get_soul())
	for child in pet_skill_upgrade_list.get_children():
		if child == pet_skill_upgrade_template:
			continue
		pet_skill_upgrade_list.remove_child(child)
		child.queue_free()
	var pet: Variant = _current_pet()
	if not (pet is Dictionary):
		return
	var skills := _pet_skills(pet)
	var levels := PET_SKILL_PROGRESSION.ensure_levels(pet)
	for index in skills.size():
		var skill_name := str(skills[index])
		var row := pet_skill_upgrade_template.duplicate() as PanelContainer
		if row == null:
			continue
		row.name = "SkillRow_%d" % index
		row.visible = true
		pet_skill_upgrade_list.add_child(row)
		var icon := row.get_node_or_null("Content/Icon") as TextureRect
		var name_label := row.get_node_or_null("Content/Name") as Label
		var mana_label := row.get_node_or_null("Content/Mana") as Label
		var level_label := row.get_node_or_null("Content/Level") as Label
		var need_label := row.get_node_or_null("Content/Need") as Label
		var upgrade_button := row.get_node_or_null("Content/UpgradeButton") as Button
		var level := clampi(int(levels.get(skill_name, 1)), 1, PET_SKILL_PROGRESSION.MAX_LEVEL)
		var icon_path := _pet_skill_icon_path(skill_name, pet)
		if icon != null:
			icon.texture = load(icon_path) as Texture2D if not icon_path.is_empty() else _create_placeholder_icon()
			if icon.texture == null:
				icon.texture = _create_placeholder_icon()
		_set_label(name_label, skill_name)
		_set_label(mana_label, "蓝耗：%d" % _pet_skill_mp_cost(skill_name, pet))
		_set_label(level_label, "Lv.%d" % level)
		var book_id := _learned_skill_book_id(skill_name)
		if level >= PET_SKILL_PROGRESSION.MAX_LEVEL:
			_set_label(need_label, "已满级")
		elif not book_id.is_empty():
			var need_books := _learned_skill_upgrade_book_count(level)
			_set_label(need_label, "技能书：%d/%d" % [_item_count(book_id), need_books])
		else:
			_set_label(need_label, "需：%d灵魂" % PET_SKILL_PROGRESSION.upgrade_cost(index, level))
		if upgrade_button != null:
			upgrade_button.disabled = level >= PET_SKILL_PROGRESSION.MAX_LEVEL
			_connect_button(upgrade_button, _on_pet_skill_upgrade_requested.bind(skill_name))


func _on_pet_skill_upgrade_requested(skill_name: String) -> void:
	_upgrade_pet_skill(skill_name)


func _upgrade_pet_skill(skill_name: String) -> void:
	var pet: Variant = _current_pet()
	if not (pet is Dictionary):
		_show_tip("当前没有宠物")
		return
	var skills := _pet_skills(pet)
	var skill_index := skills.find(skill_name)
	if skill_index < 0:
		_show_tip("该宠物还没有学习此技能")
		return
	var level := PET_SKILL_PROGRESSION.get_level(pet, skill_name)
	if level >= PET_SKILL_PROGRESSION.MAX_LEVEL:
		_show_tip("技能已经满级")
		return
	var levels := PET_SKILL_PROGRESSION.ensure_levels(pet)
	var book_id := _learned_skill_book_id(skill_name)
	if not book_id.is_empty():
		var need_books := _learned_skill_upgrade_book_count(level)
		if _item_count(book_id) < need_books:
			_show_tip("缺少%d本%s技能书" % [need_books, skill_name])
			return
		PlayerData.remove_dj(book_id, PlayerData.get_dj_page(book_id), need_books)
	else:
		var need_souls := PET_SKILL_PROGRESSION.upgrade_cost(skill_index, level)
		var souls: int = PlayerData.get_soul()
		if souls < need_souls:
			_show_tip("灵魂不足")
			return
		PlayerData.spend_soul(need_souls)
	levels[skill_name] = level + 1
	pet[PET_SKILL_PROGRESSION.LEVELS_KEY] = levels
	_refresh_current_pet()
	_refresh_pet_skill_upgrade_popup()
	_refresh_live_pet_passives(pet)
	_save_pet_changes()
	pet_skill_upgrade_success_tip = _add_tip("%s已升级至Lv.%d" % [skill_name, level + 1]) as CanvasItem
	if pet_skill_upgrade_success_tip != null:
		pet_skill_upgrade_success_tip.z_index = (
			(pet_skill_upgrade_popup.z_index if pet_skill_upgrade_popup != null else 500) + 200
		)


func _update_pet_attribute_page_buttons() -> void:
	for index in pet_attribute_page_buttons.size():
		var button := pet_attribute_page_buttons[index]
		var selected := index == pet_attribute_page
		button.disabled = false
		button.add_theme_color_override("font_color", Color("fff4bf") if selected else Color.WHITE)


func _refresh_pet_attribute_page(pet: Variant, equipment_bonus: Variant = null) -> void:
	_update_pet_attribute_page_buttons()
	var resolved_equipment_bonus: Variant = equipment_bonus
	if pet is Dictionary and not (resolved_equipment_bonus is Dictionary):
		resolved_equipment_bonus = _pet_equipment_bonuses(pet)
	var definitions: Array = PET_ATTRIBUTE_PAGES[pet_attribute_page]
	for index in pet_attribute_stat_rows.size():
		var has_stat := index < definitions.size()
		pet_attribute_stat_rows[index].visible = has_stat
		if not has_stat:
			continue
		var definition: Array = definitions[index]
		pet_attribute_stat_names[index].text = str(definition[0])
		pet_attribute_stat_values[index].text = _pet_attribute_display_value(
			pet, str(definition[1]), resolved_equipment_bonus
		)


func _pet_attribute_display_value(pet: Variant, stat_key: String, equipment_bonus: Variant = null) -> String:
	if not (pet is Dictionary):
		return "0"
	var pet_data := pet as Dictionary
	if stat_key == "生命" or stat_key == "魔法":
		var base_value := int(pet_data.get(stat_key, 0))
		var maximum := int(pet_data.get(stat_key + "上限", base_value))
		var equipment_value := _pet_stat(pet_data, stat_key, equipment_bonus) - base_value
		var passive_value := _pet_passive_value(pet_data, "热血" if stat_key == "生命" else "魔泉")
		var final_maximum := maximum + equipment_value + passive_value
		var learned_bonus := _learned_pet_self_stat_bonus(pet_data, stat_key, final_maximum)
		final_maximum += learned_bonus
		var current := (
			0 if base_value <= 0 else mini(base_value + equipment_value + passive_value + learned_bonus, final_maximum)
		)
		return "%d/%d" % [current, final_maximum]
	if stat_key == "吸血":
		var bonuses: Dictionary = equipment_bonus if equipment_bonus is Dictionary else _pet_equipment_bonuses(pet_data)
		var vampirism := float(pet_data.get("吸血", 0.0)) + float(bonuses.get("吸血", 0.0))
		return "%.2f%%" % (vampirism * 100.0)
	var value := _pet_final_stat(pet_data, stat_key, equipment_bonus)
	match stat_key:
		"幸运":
			return _pet_rating_display(value, 50.0)
		"物防", "魔防":
			return _pet_rating_display(value, 250.0)
		"暴击":
			return _pet_rating_display(value, 100.0)
		"闪避":
			return _pet_rating_display(value, 100.0)
	return str(value)


func _pet_rating_display(value: int, denominator: float) -> String:
	var rating := maxi(0, value)
	var percentage := float(rating) / (float(rating) + denominator) * 100.0 if rating > 0 else 0.0
	return "%d (%.2f%%)" % [value, percentage]


func _previous_pet() -> void:
	var pets := _pet_list()
	if pets.is_empty():
		return
	_close_pet_action_menu()
	_hide_pet_property_popup()
	current_pet_index = (current_pet_index - 1 + pets.size()) % pets.size()
	current_pack_index = 0
	_refresh_all()


func eat_immor() -> void:
	groom_click()
	_set_visible(pet_eat_immortality, true)


func push_pet_skill() -> void:
	var pet: Variant = _current_pet()
	if pet == null:
		return
	pet["技能重置次数"] = int(pet.get("技能重置次数", 0)) + 1
	_refresh_all()


func push_pet_attribute() -> void:
	var pet: Variant = _current_pet()
	if pet == null:
		return
	pet["属性重置次数"] = int(pet.get("属性重置次数", 0)) + 1
	pet["悟性"] = 0
	pet["根骨"] = 0
	pet["灵力"] = 0
	pet["潜力"] = int(pet.get("潜力上限", 12))
	_ensure_pet_growth_fields(pet)
	_recalculate_pet_growth_stats(pet, false)
	_refresh_all()


func ok_click() -> void:
	var pets := _pet_list()
	if current_pet_index >= 0 and current_pet_index < pets.size():
		if pets[current_pet_index] is Dictionary and _is_pet_rabbit(pets[current_pet_index]):
			_set_visible(give_up_this_pet, false)
			_show_tip("月兔为永久解锁宠物，无法放生")
			return
		pets.remove_at(current_pet_index)
	current_pet_index = clampi(current_pet_index, 0, max(0, pets.size() - 1))
	_set_visible(give_up_this_pet, false)
	_refresh_all()


func pet_backpack_click() -> void:
	_ensure_pet_storage()
	eip_click()
	_set_visible(pet_strength_interface, false)


func no_click() -> void:
	_set_visible(give_up_this_pet, false)


func pet_strength_click() -> void:
	_set_visible(pet_strength_interface, true)
	_refresh_strength()


func wxplus_click() -> void:
	_add_develop_point("悟性")


func ggplus_click() -> void:
	_add_develop_point("根骨")


func llplus_click() -> void:
	_add_develop_point("灵力")


func qplus_click() -> void:
	_add_potential_limit()


func super_click() -> void:
	_set_label(ntxt, "超进化")


func aoyi_click() -> void:
	_set_label(dtxt, "奥义")


func _close_eat_window() -> void:
	_set_visible(pet_eat_immortality, false)


func _on_eat_item_pressed(index: int) -> void:
	var pet: Variant = _current_pet()
	if pet == null:
		return
	if index == 7 and pet is Dictionary and int(pet.get(DataKeys.LEVEL, 1)) >= PlayerData.get_capped_player_level():
		_show_tip("宠物等级不能超过人物等级")
		return
	var item_name: String = PET_ITEM_NAMES[index - 1]
	var real_name := _find_existing_item_name(item_name, index)
	if real_name == "" or not _consume_item(real_name, 1):
		return
	match index:
		1:
			pet["生命上限"] = int(pet.get("生命上限", 0)) + 20
			pet[DataKeys.HP] = int(pet.get(DataKeys.HP, 0)) + 20
		2:
			pet["魔法上限"] = int(pet.get("魔法上限", 0)) + 10
			pet[DataKeys.MP] = int(pet.get(DataKeys.MP, 0)) + 10
		3:
			pet[DataKeys.ATTACK] = int(pet.get(DataKeys.ATTACK, 0)) + 3
		4:
			pet["暴击"] = int(pet.get("暴击", 0)) + 1
		5:
			pet["幸运"] = int(pet.get("幸运", 0)) + 1
		6:
			pet["回魔"] = int(pet.get("回魔", 0)) + 1
		7:
			_add_exp(pet, 100)
		8:
			pet["潜力"] = int(pet.get("潜力", 0)) + 1
	_refresh_all()


func _connect_quality_feed_button(
	button: BaseButton, quality_key: String, maximum_key: String, fruit_name: String
) -> void:
	if button == null:
		return
	button.pressed.connect(_on_quality_feed_button_pressed.bind(button, quality_key, maximum_key, fruit_name))
	button.button_down.connect(_on_quality_feed_button_down.bind(button, quality_key, maximum_key, fruit_name))
	button.button_up.connect(_on_quality_feed_button_up.bind(button))


func _on_quality_feed_button_down(
	button: BaseButton, quality_key: String, maximum_key: String, fruit_name: String
) -> void:
	_quality_feed_hold_button = button
	_quality_feed_hold_config = {
		"quality_key": quality_key,
		"maximum_key": maximum_key,
		"fruit_name": fruit_name,
	}
	_quality_feed_hold_elapsed = 0.0
	_quality_feed_repeat_elapsed = 0.0
	_quality_feed_repeating = false
	_quality_feed_suppress_click = false


func _on_quality_feed_button_up(button: BaseButton) -> void:
	if button == _quality_feed_hold_button:
		var was_repeating := _quality_feed_repeating
		_quality_feed_hold_button = null
		_quality_feed_hold_config.clear()
		_quality_feed_hold_elapsed = 0.0
		_quality_feed_repeat_elapsed = 0.0
		_quality_feed_repeating = false
		_quality_feed_suppress_click = was_repeating


func _on_quality_feed_button_pressed(
	_button: BaseButton, quality_key: String, maximum_key: String, fruit_name: String
) -> void:
	if _quality_feed_suppress_click:
		_quality_feed_suppress_click = false
		return
	_on_quality_fruit_pressed(quality_key, maximum_key, fruit_name)


func _process_quality_feed_hold(delta: float) -> void:
	if _quality_feed_hold_button == null or not is_instance_valid(_quality_feed_hold_button):
		return
	if _quality_feed_hold_button.disabled:
		_on_quality_feed_button_up(_quality_feed_hold_button)
		return
	_quality_feed_hold_elapsed += delta
	if not _quality_feed_repeating:
		if _quality_feed_hold_elapsed < QUALITY_FEED_HOLD_DELAY:
			return
		_quality_feed_repeating = true
		_quality_feed_suppress_click = true
		if not _feed_held_quality_fruit():
			_on_quality_feed_button_up(_quality_feed_hold_button)
		return
	_quality_feed_repeat_elapsed += delta
	if _quality_feed_repeat_elapsed < QUALITY_FEED_REPEAT_INTERVAL:
		return
	_quality_feed_repeat_elapsed = 0.0
	if not _feed_held_quality_fruit():
		_on_quality_feed_button_up(_quality_feed_hold_button)


func _feed_held_quality_fruit() -> bool:
	return _on_quality_fruit_pressed(
		str(_quality_feed_hold_config.get("quality_key", "")),
		str(_quality_feed_hold_config.get("maximum_key", "")),
		str(_quality_feed_hold_config.get("fruit_name", "")),
		false
	)


func _on_quality_fruit_pressed(
	quality_key: String, maximum_key: String, fruit_name: String, show_tip: bool = true
) -> bool:
	var pet: Variant = _current_pet()
	if not (pet is Dictionary):
		if show_tip:
			_show_tip("当前没有宠物")
		return false
	var current_value := int(pet.get(quality_key, 0))
	var maximum_value := int(pet.get(maximum_key, 0))
	if maximum_value <= 0 or current_value >= maximum_value:
		if show_tip:
			_show_tip("%s已达到上限" % quality_key)
		return false
	if not _consume_item(fruit_name, 1):
		if show_tip:
			_show_tip("缺少资质果")
		return false
	var added_value := mini(randi_range(10, 30), maximum_value - current_value)
	pet[quality_key] = current_value + added_value
	_ensure_pet_growth_fields(pet)
	_recalculate_pet_growth_stats(pet, false)
	_refresh_live_pet_passives(pet)
	if show_tip:
		_show_tip("%s +%d" % [quality_key, added_value])
	_refresh_all()
	return true


func _on_strength_pressed() -> void:
	var item: Variant = _current_strength_item()
	if item == null:
		return
	var pet: Variant = _current_pet()
	if not (pet is Dictionary):
		return
	var level := int(item.get(DataKeys.ENHANCE_LEVEL, 0))
	var max_level := PlayerData.get_equipment_strength_max_level(item)
	if level >= max_level:
		_show_tip("装备等级已达最高等级")
		return
	var cost := _strength_cost(level)
	if _strength_points() < cost:
		return
	_current_pet()["强化点"] = _strength_points() - cost
	item[DataKeys.ENHANCE_LEVEL] = level + 1
	_refresh_live_pet_passives(pet as Dictionary)
	_save_pet_changes()
	_refresh_all()


func _on_buy_strength_pressed() -> void:
	if not _consume_item(STRENGTH_BUY_ITEM, 1):
		return
	var pet: Variant = _current_pet()
	if pet == null:
		return
	pet["强化点"] = int(pet.get("强化点", 0)) + 1
	_refresh_all()


func _add_develop_point(key: String) -> void:
	_on_develop_fruit_pressed(key)


func _on_develop_fruit_pressed(key: String) -> void:
	var pet: Variant = _current_pet()
	if not (pet is Dictionary):
		_show_tip("当前没有宠物")
		return
	var current_value: int = clampi(int(pet.get(key, 0)), 0, DEVELOP_MAX)
	if current_value >= DEVELOP_MAX:
		_show_tip("%s已达到上限" % key)
		return
	var fruit_id: String = str(DEVELOP_FRUIT_IDS.get(key, ""))
	if fruit_id == "" or not _consume_item(fruit_id, DEVELOP_FRUIT_COST):
		_show_tip("缺少%s×%d" % [_develop_fruit_name(key), DEVELOP_FRUIT_COST])
		return
	pet[key] = current_value + 1
	if key == "悟性":
		_ensure_pet_growth_fields(pet)
		_recalculate_pet_growth_stats(pet, false)
	_refresh_live_pet_develop_effects(pet)
	_show_tip("%s +1" % key)
	_refresh_all()


func _develop_fruit_name(key: String) -> String:
	return str({"悟性": "悟性果", "根骨": "根骨果", "灵力": "灵力果"}.get(key, "对应果子"))


func _add_potential_limit() -> void:
	var pet: Variant = _current_pet()
	if pet == null or int(pet.get("潜力上限", 12)) >= POTENTIAL_MAX:
		return
	pet["潜力上限"] = int(pet.get("潜力上限", 12)) + 1
	pet["潜力"] = int(pet.get("潜力", 0)) + 1
	_refresh_all()


func _refresh_all() -> void:
	_refresh_current_pet()
	_refresh_pet_name_list(true)
	_refresh_develop()
	_refresh_pack()
	_refresh_strength()
	_update_pet_model_preview_layout()


func _refresh_current_pet() -> void:
	var pet: Variant = _current_pet()
	if pet == null:
		_set_label(txtname, "")
		if learn_skill_button != null:
			learn_skill_button.disabled = true
		if pet_formation_button != null:
			pet_formation_button.disabled = true
		if upgrade_skill_button != null:
			upgrade_skill_button.disabled = true
		for label in [
			leveltxt,
			expmc,
			hpqualitytxt,
			mpqualitytxt,
			atkqualitytxt,
			defqualitytxt,
			warpowertxt,
			perceptiontxt,
			techniquetxt,
			lifetimetxt
		]:
			_set_label(label, "0")
		for quality_label in [hpzizhitxt, mpzizhitxt, atkzizhitxt, defzizhitxt]:
			_set_label(quality_label, "0/0")
		for quality_bar in [hpzizhibar, mpzizhibar, atkzizhibar, defzizhibar]:
			_update_quality_bar(quality_bar, 0, 0)
		for quality_button in [hpzizhibtn, mpzizhibtn, atkzizhibtn, defzizhibtn, wuxingbtn, gengubtn, linglibtn]:
			if quality_button != null:
				quality_button.disabled = true
		if fightbtn != null:
			fightbtn.visible = false
			fightbtn.disabled = true
		if restbtn != null:
			restbtn.visible = false
			restbtn.disabled = true
		_refresh_pet_attribute_page(null)
		return
	if learn_skill_button != null:
		learn_skill_button.disabled = false
	if pet_formation_button != null:
		pet_formation_button.disabled = false
	if upgrade_skill_button != null:
		upgrade_skill_button.disabled = false
	for quality_button in [hpzizhibtn, mpzizhibtn, atkzizhibtn, defzizhibtn, wuxingbtn, gengubtn, linglibtn]:
		if quality_button != null:
			quality_button.disabled = false
	if pet is Dictionary:
		_repair_phoenix_pet_data(pet)
	if pet is Dictionary and _is_pet_mouse(pet):
		_normalize_pet_mouse_name(pet)
	elif pet is Dictionary and _is_pet_yin_tiger(pet):
		_normalize_pet_yin_tiger_name(pet)
	elif pet is Dictionary and _is_pet_phoenix(pet):
		_normalize_pet_phoenix_name(pet)
	elif pet is Dictionary and _is_pet_turtle(pet):
		_normalize_pet_turtle_name(pet)
	elif pet is Dictionary and _is_pet_tiger(pet):
		_normalize_pet_tiger_name(pet)
	elif pet is Dictionary and _is_pet_dragon(pet):
		_normalize_pet_dragon_name(pet)
	if pet is Dictionary:
		PET_SKILL_PROGRESSION.ensure_levels(pet)
	_set_label(txtname, str(pet.get(DataKeys.ALT_NAME, pet.get(DataKeys.NAME, "宠物"))))
	_refresh_pet_model_preview(pet)
	_refresh_tiger_quality_preview(pet)
	_set_label(leveltxt, str(int(pet.get(DataKeys.LEVEL, 1))))
	_set_label(tiger_level_text, str(int(pet.get(DataKeys.LEVEL, 1))))
	_set_label(expmc, "%d/%d" % [int(pet.get(DataKeys.EXP, 0)), int(pet.get("经验上限", 100))])
	var passive_hp := _pet_passive_value(pet, "热血")
	var passive_mp := _pet_passive_value(pet, "魔泉")
	var equipment_bonus := _pet_equipment_bonuses(pet)
	var equipment_hp := int(equipment_bonus.get(DataKeys.HP, 0))
	var equipment_mp := int(equipment_bonus.get(DataKeys.MP, 0))
	var base_hp := int(pet.get(DataKeys.HP, 0))
	var base_hp_max := int(pet.get("生命上限", base_hp))
	var base_mp := int(pet.get(DataKeys.MP, 0))
	var base_mp_max := int(pet.get("魔法上限", base_mp))
	var hp_max_before_skill := base_hp_max + equipment_hp + passive_hp
	var mp_max_before_skill := base_mp_max + equipment_mp + passive_mp
	var learned_hp_bonus := _learned_pet_self_stat_bonus(pet, "生命", hp_max_before_skill)
	var learned_mp_bonus := _learned_pet_self_stat_bonus(pet, "魔法", mp_max_before_skill)
	var final_hp_max := hp_max_before_skill + learned_hp_bonus
	var final_mp_max := mp_max_before_skill + learned_mp_bonus
	var final_hp: int = (
		0 if base_hp <= 0 else mini(base_hp + equipment_hp + passive_hp + learned_hp_bonus, final_hp_max)
	)
	var final_mp: int = (
		0 if base_mp <= 0 else mini(base_mp + equipment_mp + passive_mp + learned_mp_bonus, final_mp_max)
	)
	var hp_text := "%d/%d" % [final_hp, final_hp_max]
	var mp_text := "%d/%d" % [final_mp, final_mp_max]
	_set_label(hptxt, hp_text)
	_set_label(mptxt, mp_text)
	_set_label(atktxt, str(_pet_final_stat(pet, "攻击", equipment_bonus)))
	_set_label(deftxt, str(_pet_final_stat(pet, "物防", equipment_bonus)))
	_set_label(mdeftxt, str(_pet_stat(pet, "魔防", equipment_bonus)))
	_set_label(crittxt, _pet_rating_display(_pet_final_stat(pet, "暴击", equipment_bonus), 100.0))
	_set_label(misstxt, _pet_rating_display(_pet_stat(pet, "闪避", equipment_bonus), 100.0))
	_set_label(speedtxt, _pet_rating_display(_pet_stat(pet, "幸运", equipment_bonus), 50.0))
	_set_label(eahptxt, str(_pet_final_stat(pet, "回血", equipment_bonus)))
	_set_label(eamptxt, str(_pet_final_stat(pet, "回魔", equipment_bonus)))
	_set_label(hpqualitytxt, hp_text)
	_set_label(mpqualitytxt, mp_text)
	_set_label(atkqualitytxt, str(_pet_final_stat(pet, "攻击", equipment_bonus)))
	_set_label(defqualitytxt, str(_pet_final_stat(pet, "物防", equipment_bonus)))
	_set_label(hpzizhitxt, "%d/%d" % [int(pet.get("生命资质", 0)), int(pet.get("生命资质上限", 0))])
	_set_label(mpzizhitxt, "%d/%d" % [int(pet.get("魔法资质", 0)), int(pet.get("魔法资质上限", 0))])
	_set_label(atkzizhitxt, "%d/%d" % [int(pet.get("攻击资质", 0)), int(pet.get("攻击资质上限", 0))])
	_set_label(defzizhitxt, "%d/%d" % [int(pet.get("防御资质", 0)), int(pet.get("防御资质上限", 0))])
	_update_quality_bar(hpzizhibar, int(pet.get("生命资质", 0)), int(pet.get("生命资质上限", 0)))
	_update_quality_bar(mpzizhibar, int(pet.get("魔法资质", 0)), int(pet.get("魔法资质上限", 0)))
	_update_quality_bar(atkzizhibar, int(pet.get("攻击资质", 0)), int(pet.get("攻击资质上限", 0)))
	_update_quality_bar(defzizhibar, int(pet.get("防御资质", 0)), int(pet.get("防御资质上限", 0)))
	_set_label(warpowertxt, str(_pet_stat(pet, "魔防", equipment_bonus)))
	_set_label(perceptiontxt, _pet_rating_display(_pet_final_stat(pet, "暴击", equipment_bonus), 100.0))
	_set_label(techniquetxt, str(_pet_stat(pet, "幸运", equipment_bonus)))
	_set_label(lifetimetxt, hp_text)
	_refresh_pet_attribute_page(pet, equipment_bonus)
	_refresh_fight_button_state(pet)
	_refresh_pet_skill_icons(pet)


func _update_quality_bar(bar: TextureProgressBar, current_value: int, maximum_value: int) -> void:
	if bar == null:
		return
	bar.max_value = max(1, maximum_value)
	bar.value = clamp(current_value, 0, maximum_value) if maximum_value > 0 else 0


func _setup_pet_skill_icons() -> void:
	var container := get_node_or_null("PetAttributeShow/shape44_id43") as TextureRect
	if container == null:
		return
	var existing_scroll := container.get_node_or_null("PetSkillScroll") as ScrollContainer
	if existing_scroll != null:
		_register_pet_scroll(existing_scroll)
		_pet_skill_grid = existing_scroll.get_node_or_null("PetSkillGrid") as Control
		if _pet_skill_grid != null:
			existing_scroll.visible = true
			_pet_skill_grid.visible = true
			return
		existing_scroll.queue_free()
	var existing_grid := container.get_node_or_null("PetSkillGrid") as Control
	if existing_grid != null:
		_pet_skill_grid = existing_grid
		_pet_skill_grid.visible = true
		return
	var scroll := ScrollContainer.new()
	scroll.name = "PetSkillScroll"
	scroll.z_index = 5
	scroll.offset_left = 6
	scroll.offset_top = 20
	scroll.offset_right = container.size.x - 6
	scroll.offset_bottom = container.size.y - 6
	scroll.scroll_horizontal = false
	scroll.mouse_filter = Control.MOUSE_FILTER_PASS
	container.add_child(scroll)
	_register_pet_scroll(scroll)
	var inner := Control.new()
	inner.name = "PetSkillGrid"
	_pet_skill_grid = inner
	var cols := 4
	var rows := int(ceil(float(PET_SKILL_SLOT_COUNT) / cols))
	var total_w := cols * PET_SKILL_SLOT_SIZE + (cols - 1) * PET_SKILL_SLOT_GAP
	var total_h := rows * PET_SKILL_SLOT_SIZE + (rows - 1) * PET_SKILL_SLOT_GAP
	inner.custom_minimum_size = Vector2(total_w, total_h)
	var frame_tex := load(PET_SKILL_SLOT_FRAME) as Texture2D
	for row in range(rows):
		for col in range(cols):
			var i := row * cols + col
			var slot := Control.new()
			slot.name = "PetSkillSlot_%d" % i
			slot.offset_left = col * (PET_SKILL_SLOT_SIZE + PET_SKILL_SLOT_GAP)
			slot.offset_top = row * (PET_SKILL_SLOT_SIZE + PET_SKILL_SLOT_GAP)
			slot.offset_right = slot.offset_left + PET_SKILL_SLOT_SIZE
			slot.offset_bottom = slot.offset_top + PET_SKILL_SLOT_SIZE
			slot.mouse_filter = Control.MOUSE_FILTER_IGNORE

			var frame_slot := TextureRect.new()
			frame_slot.name = "Frame"
			frame_slot.offset_left = 1
			frame_slot.offset_top = 1
			frame_slot.offset_right = 55
			frame_slot.offset_bottom = 55
			frame_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
			if frame_tex != null:
				frame_slot.texture = frame_tex
			else:
				var bg_img := Image.create(PET_SKILL_SLOT_SIZE, PET_SKILL_SLOT_SIZE, false, Image.FORMAT_RGBA8)
				bg_img.fill(Color(0.1, 0.1, 0.15, 0.6))
				frame_slot.texture = ImageTexture.create_from_image(bg_img)
			slot.add_child(frame_slot)

			var icon_slot := TextureRect.new()
			icon_slot.name = "Icon"
			icon_slot.offset_left = 0
			icon_slot.offset_top = 0
			icon_slot.offset_right = PET_SKILL_SLOT_SIZE
			icon_slot.offset_bottom = PET_SKILL_SLOT_SIZE
			icon_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
			icon_slot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon_slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon_slot.visible = false
			slot.add_child(icon_slot)
			var mana_label := Label.new()
			mana_label.name = "ManaLabel"
			mana_label.z_index = 3
			mana_label.offset_left = 2
			mana_label.offset_top = 1
			mana_label.offset_right = 31
			mana_label.offset_bottom = 18
			mana_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			mana_label.add_theme_font_override("font", PET_EQUIPMENT_STRENGTH_FONT)
			mana_label.add_theme_font_size_override("font_size", 12)
			mana_label.add_theme_color_override("font_color", Color("63c7ff"))
			mana_label.add_theme_color_override("font_outline_color", Color.BLACK)
			mana_label.add_theme_constant_override("outline_size", 3)
			mana_label.visible = false
			slot.add_child(mana_label)
			var level_label := Label.new()
			level_label.name = "LevelLabel"
			level_label.z_index = 3
			level_label.offset_left = 23
			level_label.offset_top = 1
			level_label.offset_right = 55
			level_label.offset_bottom = 18
			level_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			level_label.add_theme_font_override("font", PET_EQUIPMENT_STRENGTH_FONT)
			level_label.add_theme_font_size_override("font_size", 11)
			level_label.add_theme_color_override("font_color", Color("fff4bf"))
			level_label.add_theme_color_override("font_outline_color", Color.BLACK)
			level_label.add_theme_constant_override("outline_size", 3)
			level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			level_label.visible = false
			slot.add_child(level_label)
			inner.add_child(slot)
	scroll.add_child(inner)


func _pet_skill_icon_path(skill_name: String, pet: Variant = null) -> String:
	match skill_name:
		"虎啸":
			if pet is Dictionary and _is_pet_yin_tiger(pet):
				return "res://Art/pet/skillicon/hx.png"

			return "res://Art/pet/skillicon/hy.png"
		"猛虎下山":
			return "res://Art/pet/skillicon/mhxs.png"
		"寅虎奥义":
			return "res://Art/pet/skillicon/yhaoyi.png"
		"涅槃":
			return "res://Art/pet/skillicon/np.png"
		"不死火鸟":
			return "res://Art/pet/skillicon/bshn.png"
		"地火燎原":
			return "res://Art/pet/skillicon/dhly.png"
		"朱雀奥义":
			return "res://Art/pet/skillicon/aoyi.png"
	return PET_SKILL_ICON_PATHS.get(skill_name, "")


func _pet_skill_base_mp_cost(skill_name: String) -> int:
	match skill_name:
		"涅槃":
			return 35
		"不死火鸟":
			return 45
		"地火燎原":
			return 65
		"朱雀奥义":
			return 90
	return int(PET_SKILL_MP_COSTS.get(skill_name, 0))


func _pet_skill_mp_cost(skill_name: String, pet: Variant = null) -> int:
	var base_cost := _pet_skill_base_mp_cost(skill_name)
	var resolved_pet: Variant = pet if pet is Dictionary else _current_pet()
	if not (resolved_pet is Dictionary):
		return base_cost
	var custom_raw: Variant = resolved_pet.get("技能蓝耗", {})
	if custom_raw is Dictionary and custom_raw.has(skill_name):
		return int(custom_raw.get(skill_name, base_cost))
	return PET_SKILL_PROGRESSION.mana_cost(base_cost, PET_SKILL_PROGRESSION.get_level(resolved_pet, skill_name))


func _create_placeholder_icon() -> ImageTexture:
	var img := Image.create(PET_SKILL_SLOT_SIZE, PET_SKILL_SLOT_SIZE, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.0, 0.0, 0.0, 0.0))
	var cx := PET_SKILL_SLOT_SIZE / 2
	var cy := PET_SKILL_SLOT_SIZE / 2
	var r := 18
	for dy in range(-r, r + 1):
		for dx in range(-r, r + 1):
			if dx * dx + dy * dy <= r * r:
				var px := cx + dx
				var py := cy + dy
				if px >= 0 and px < PET_SKILL_SLOT_SIZE and py >= 0 and py < PET_SKILL_SLOT_SIZE:
					img.set_pixel(px, py, Color(0.3, 0.3, 0.5, 0.5))
	return ImageTexture.create_from_image(img)


func _refresh_pet_skill_icons(pet: Dictionary) -> void:
	_setup_pet_skill_icons()
	if _pet_skill_grid == null:
		return
	var skills := _pet_skills(pet)
	var levels := PET_SKILL_PROGRESSION.ensure_levels(pet)
	for i in range(PET_SKILL_SLOT_COUNT):
		var slot := _pet_skill_grid.get_node_or_null("PetSkillSlot_%d" % i) as Control
		if slot == null:
			continue
		var icon := slot.get_node_or_null("Icon") as TextureRect
		var mana_label := slot.get_node_or_null("ManaLabel") as Label
		var level_label := slot.get_node_or_null("LevelLabel") as Label
		if icon == null:
			continue
		if i < skills.size():
			var skill_name := str(skills[i])
			var icon_path := _pet_skill_icon_path(skill_name, pet)
			icon.visible = true
			if icon_path.is_empty():
				icon.texture = _create_placeholder_icon()
				icon.modulate = Color(0.6, 0.6, 0.8, 1.0)
			else:
				var tex := load(icon_path) as Texture2D
				if tex != null:
					icon.texture = tex
					icon.modulate = Color(1, 1, 1, 1)
				else:
					icon.texture = _create_placeholder_icon()
					icon.modulate = Color(0.6, 0.6, 0.8, 1.0)
			_set_label(mana_label, str(_pet_skill_mp_cost(skill_name, pet)))
			_set_label(
				level_label, "Lv.%d" % clampi(int(levels.get(skill_name, 1)), 1, PET_SKILL_PROGRESSION.MAX_LEVEL)
			)
			if mana_label != null:
				mana_label.visible = true
			if level_label != null:
				level_label.visible = true
		else:
			icon.texture = null
			icon.visible = false
			if mana_label != null:
				mana_label.visible = false
			if level_label != null:
				level_label.visible = false


func _is_pet_dead_in_current_level(pet_name: String) -> bool:
	var level_node := _find_active_pet_spawn_node(get_tree().root)
	if level_node == null:
		return false
	var slot := LocalCoop.ui_slot
	if not bool(level_node.get_meta(LocalCoop.pet_meta_key("active_pet_dead_this_level", slot), false)):
		return false
	var aliases := _pet_dead_aliases(pet_name)
	var dead_pet_keys_value: Variant = level_node.get_meta(LocalCoop.pet_meta_key("active_pet_dead_keys", slot), [])
	if dead_pet_keys_value is Array:
		for alias in aliases:
			if dead_pet_keys_value.has(alias):
				return true
	var dead_type := str(level_node.get_meta(LocalCoop.pet_meta_key("active_pet_dead_type", slot), ""))
	if dead_type != "" and aliases.has(dead_type):
		return true
	var dead_name := str(level_node.get_meta(LocalCoop.pet_meta_key("active_pet_dead_name", slot), ""))
	var dead_display_name := str(level_node.get_meta(LocalCoop.pet_meta_key("active_pet_dead_display_name", slot), ""))
	return dead_name == "" or aliases.has(dead_name) or aliases.has(dead_display_name)


func _pet_dead_aliases(pet_name: String) -> Array[String]:
	var aliases: Array[String] = [pet_name]
	if pet_name == "PetNeat" or pet_name in ["丑牛", "丑牛元帅", "丑牛大元帅"]:
		aliases.append("PetNeat")
		aliases.append("丑牛元帅")
		aliases.append("丑牛大元帅")
	if pet_name == "PetMouse" or PET_MOUSE_STAGE_NAMES.values().has(pet_name):
		aliases.append("PetMouse")
		for name in PET_MOUSE_STAGE_NAMES.values():
			if not aliases.has(str(name)):
				aliases.append(str(name))
	if pet_name == "PetRabbit" or PET_RABBIT_STAGE_NAMES.values().has(pet_name):
		aliases.append("PetRabbit")
		for name in PET_RABBIT_STAGE_NAMES.values():
			if not aliases.has(str(name)):
				aliases.append(str(name))
	if pet_name == "PetTurtle" or pet_name.begins_with("玄武") or PET_TURTLE_STAGE_NAMES.values().has(pet_name):
		aliases.append("PetTurtle")
		for name in PET_TURTLE_STAGE_NAMES.values():
			if not aliases.has(str(name)):
				aliases.append(str(name))
	if pet_name == "PetDragon" or pet_name.begins_with("辰龙") or PET_DRAGON_STAGE_NAMES.values().has(pet_name):
		aliases.append("PetDragon")
		for name in PET_DRAGON_STAGE_NAMES.values():
			if not aliases.has(str(name)):
				aliases.append(str(name))
	if pet_name == "PetTiger" or pet_name == "白虎" or PET_TIGER_STAGE_NAMES.values().has(pet_name):
		aliases.append("PetTiger")
		aliases.append("白虎")
		for name in PET_TIGER_STAGE_NAMES.values():
			if not aliases.has(str(name)):
				aliases.append(str(name))
	return aliases


func _spawn_active_pet_now() -> void:
	var level_node := _find_active_pet_spawn_node(get_tree().root)
	if level_node != null:
		level_node.call_deferred("_spawn_active_pet", LocalCoop.ui_slot if LocalCoop.is_enabled() else 1)


func _despawn_active_pet_now() -> void:
	_despawn_active_pet_nodes(get_tree().root)


func _despawn_active_pet_nodes(node: Node) -> void:
	if node == null:
		return
	for child in node.get_children():
		_despawn_active_pet_nodes(child)
	if (
		(not LocalCoop.is_enabled() or int(node.get_meta("coop_slot", 1)) == LocalCoop.ui_slot)
		and (
			bool(node.get_meta("pet_tiger_unit", false))
			or bool(node.get_meta("pet_tiger_summon", false))
			or bool(node.get_meta("pet_dragon_unit", false))
			or bool(node.get_meta("pet_phoenix_unit", false))
			or bool(node.get_meta("pet_turtle_unit", false))
			or bool(node.get_meta("pet_rabbit_unit", false))
			or bool(node.get_meta("pet_mouse_unit", false))
			or bool(node.get_meta("pet_neat_unit", false))
			or bool(node.get_meta("pet_yin_tiger_unit", false))
		)
	):
		node.queue_free()


func _find_active_pet_spawn_node(node: Node) -> Node:
	if node == null:
		return null
	if node.has_method("_spawn_active_pet"):
		return node
	for child in node.get_children():
		var found := _find_active_pet_spawn_node(child)
		if found != null:
			return found
	return null


func _refresh_fight_button_state(pet: Dictionary) -> void:
	if fightbtn != null:
		fightbtn.visible = true
		fightbtn.disabled = false
	if restbtn != null:
		restbtn.visible = true
		restbtn.disabled = false


func _refresh_develop() -> void:
	var pet: Variant = _current_pet()
	if pet == null:
		return
	_set_label(qltxt, str(int(pet.get("潜力", 0))))
	_update_bar(wxbar, wxtxt, int(pet.get("悟性", 0)), DEVELOP_MAX)
	_update_bar(ggbar, ggtxt, int(pet.get("根骨", 0)), DEVELOP_MAX)
	_update_bar(llbar, lltxt, int(pet.get("灵力", 0)), DEVELOP_MAX)
	_update_bar(qlbar, qljxtxt, int(pet.get("潜力", 0)), max(1, int(pet.get("潜力上限", 12))))
	_set_label(ntxt, "技能重置：%d" % int(pet.get("技能重置次数", 0)))
	_set_label(etxt, "属性重置：%d" % int(pet.get("属性重置次数", 0)))
	_set_label(dtxt, "奥义：%s" % ("已激活" if bool(pet.get("奥义", false)) else "未激活"))
	_refresh_pet_passive_panel(pet)


func _setup_pet_passive_panel() -> void:
	if pet_develop_interface == null:
		return
	pet_passive_panel = pet_develop_interface.get_node_or_null("PetPassivePanel") as PanelContainer
	if pet_passive_panel != null:
		return
	pet_passive_panel = PanelContainer.new()
	pet_passive_panel.name = "PetPassivePanel"
	pet_passive_panel.position = Vector2(1, 10)
	pet_passive_panel.size = Vector2(300, 180)
	pet_passive_panel.z_index = 5
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.075, 0.045, 0.93)
	panel_style.border_color = Color(0.74, 0.54, 0.25, 0.95)
	panel_style.set_border_width_all(2)
	panel_style.corner_radius_top_left = 5
	panel_style.corner_radius_top_right = 5
	panel_style.corner_radius_bottom_left = 5
	panel_style.corner_radius_bottom_right = 5
	pet_passive_panel.add_theme_stylebox_override("panel", panel_style)
	pet_develop_interface.add_child(pet_passive_panel)
	if pet_eat_immortality != null:
		pet_eat_immortality.z_index = 20

	var root_box := VBoxContainer.new()
	root_box.add_theme_constant_override("separation", 1)
	pet_passive_panel.add_child(root_box)
	var title_row := HBoxContainer.new()
	root_box.add_child(title_row)
	var title := Label.new()
	title.text = "宠物被动技能"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_color_override("font_color", Color(1.0, 0.88, 0.48))
	title.add_theme_font_size_override("font_size", 15)
	title_row.add_child(title)
	pet_passive_limit_label = Label.new()
	pet_passive_limit_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	pet_passive_limit_label.add_theme_font_size_override("font_size", 12)
	title_row.add_child(pet_passive_limit_label)
	pet_passive_one_key_button = Button.new()
	pet_passive_one_key_button.name = "OneKeyUpgradeButton"
	pet_passive_one_key_button.text = "一键升级"
	pet_passive_one_key_button.custom_minimum_size = Vector2(65, 23)
	pet_passive_one_key_button.focus_mode = Control.FOCUS_NONE
	pet_passive_one_key_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	pet_passive_one_key_button.add_theme_font_size_override("font_size", 12)
	pet_passive_one_key_button.pressed.connect(_on_pet_passive_one_key_upgrade_pressed)
	title_row.add_child(pet_passive_one_key_button)

	for skill_name in PET_PASSIVE_KEYS:
		var row := HBoxContainer.new()
		row.custom_minimum_size.y = 27
		row.add_theme_constant_override("separation", 4)
		root_box.add_child(row)
		var name_label := Label.new()
		name_label.text = skill_name
		name_label.custom_minimum_size.x = 40
		name_label.add_theme_color_override("font_color", Color(1.0, 0.93, 0.72))
		row.add_child(name_label)
		var level_label := Label.new()
		level_label.custom_minimum_size.x = 48
		row.add_child(level_label)
		pet_passive_level_labels[skill_name] = level_label
		var effect_label := Label.new()
		effect_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		effect_label.clip_text = true
		effect_label.add_theme_font_size_override("font_size", 12)
		row.add_child(effect_label)
		pet_passive_effect_labels[skill_name] = effect_label
		var cost_label := Label.new()
		cost_label.custom_minimum_size.x = 58
		cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		cost_label.add_theme_font_size_override("font_size", 11)
		row.add_child(cost_label)
		pet_passive_cost_labels[skill_name] = cost_label
		var upgrade_button := Button.new()
		upgrade_button.text = "升级"
		upgrade_button.custom_minimum_size = Vector2(47, 23)
		upgrade_button.focus_mode = Control.FOCUS_NONE
		upgrade_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		upgrade_button.pressed.connect(_on_pet_passive_upgrade_pressed.bind(skill_name))
		upgrade_button.button_down.connect(_on_pet_passive_button_down.bind(upgrade_button, skill_name))
		upgrade_button.button_up.connect(_on_pet_passive_button_up.bind(upgrade_button))
		row.add_child(upgrade_button)
		pet_passive_upgrade_buttons[skill_name] = upgrade_button


func _pet_passive_levels(pet: Dictionary) -> Dictionary:
	if not pet.has("被动技能") or not (pet["被动技能"] is Dictionary):
		pet["被动技能"] = {}
	var levels: Dictionary = pet["被动技能"]
	for skill_name in PET_PASSIVE_KEYS:
		levels[skill_name] = max(0, int(levels.get(skill_name, 0)))
	return levels


func _pet_passive_max_level(pet: Dictionary) -> int:
	return PaSkill.get_unlocked_level(int(pet.get(DataKeys.LEVEL, 1)))


func _pet_passive_cost(level: int) -> int:
	return 5000 * (max(0, level) + 1)


func _refresh_pet_passive_panel(pet: Dictionary) -> void:
	if pet_passive_panel == null:
		_setup_pet_passive_panel()
	if pet_passive_panel == null:
		return
	var levels := _pet_passive_levels(pet)
	var max_level := _pet_passive_max_level(pet)
	if pet_passive_limit_label != null:
		pet_passive_limit_label.text = "上限：%d" % max_level
	if pet_passive_one_key_button != null:
		pet_passive_one_key_button.disabled = PET_PASSIVE_KEYS.all(
			func(skill_name): return int(levels.get(skill_name, 0)) >= max_level
		)
	for skill_name in PET_PASSIVE_KEYS:
		var level := int(levels.get(skill_name, 0))
		var at_cap := level >= max_level
		var current_value := int(PaSkill.get_value(skill_name, level))
		var next_value := int(PaSkill.get_value(skill_name, level + 1))
		var level_label := pet_passive_level_labels.get(skill_name) as Label
		var effect_label := pet_passive_effect_labels.get(skill_name) as Label
		var cost_label := pet_passive_cost_labels.get(skill_name) as Label
		var button := pet_passive_upgrade_buttons.get(skill_name) as Button
		if level_label != null:
			level_label.text = "Lv.%d" % level
		if effect_label != null:
			effect_label.text = (
				"%s +%d" % [PET_PASSIVE_EFFECT_NAMES[skill_name], current_value]
				if at_cap
				else "%s +%d → +%d" % [PET_PASSIVE_EFFECT_NAMES[skill_name], current_value, next_value]
			)
		if cost_label != null:
			cost_label.text = "已达上限" if at_cap else "%d魂" % _pet_passive_cost(level)
		if button != null:
			button.disabled = at_cap


func _on_pet_passive_upgrade_pressed(skill_name: String) -> void:
	if _pet_passive_suppress_click:
		_pet_passive_suppress_click = false
		return
	_upgrade_pet_passive(skill_name)


func _upgrade_all_pet_passives(pet: Dictionary) -> int:
	var levels := _pet_passive_levels(pet)
	var max_level := _pet_passive_max_level(pet)
	var upgraded_count := 0
	while true:
		var upgraded_this_round := false
		for skill_name in PET_PASSIVE_KEYS:
			var level := int(levels.get(skill_name, 0))
			if level >= max_level:
				continue
			var cost := _pet_passive_cost(level)
			if PlayerData.get_soul() < cost:
				continue
			PlayerData.spend_soul(cost)
			levels[skill_name] = level + 1
			upgraded_count += 1
			upgraded_this_round = true
		if not upgraded_this_round:
			break
	return upgraded_count


func _on_pet_passive_one_key_upgrade_pressed() -> void:
	var pet: Variant = _current_pet()
	if not (pet is Dictionary):
		_show_tip("当前没有宠物")
		return
	var upgraded_count := _upgrade_all_pet_passives(pet)
	if upgraded_count <= 0:
		_refresh_pet_passive_panel(pet)
		_show_tip("灵魂不足或已达当前宠物等级上限")
		return
	_refresh_live_pet_passives(pet)
	_refresh_current_pet()
	_refresh_pet_passive_panel(pet)
	_save_pet_changes()
	_show_tip("一键升级完成，共提升%d级" % upgraded_count)


func _on_pet_passive_button_down(button: BaseButton, skill_name: String) -> void:
	_pet_passive_hold_button = button
	_pet_passive_hold_skill = skill_name
	_pet_passive_hold_elapsed = 0.0
	_pet_passive_repeat_elapsed = 0.0
	_pet_passive_repeating = false
	_pet_passive_suppress_click = false


func _on_pet_passive_button_up(button: BaseButton) -> void:
	if button != _pet_passive_hold_button:
		return
	var was_repeating := _pet_passive_repeating
	_pet_passive_hold_button = null
	_pet_passive_hold_skill = ""
	_pet_passive_hold_elapsed = 0.0
	_pet_passive_repeat_elapsed = 0.0
	_pet_passive_repeating = false
	_pet_passive_suppress_click = was_repeating


func _process_pet_passive_hold(delta: float) -> void:
	if _pet_passive_hold_button == null:
		return
	if not is_instance_valid(_pet_passive_hold_button):
		_pet_passive_hold_button = null
		_pet_passive_hold_skill = ""
		return
	if _pet_passive_hold_button.disabled:
		_on_pet_passive_button_up(_pet_passive_hold_button)
		return
	_pet_passive_hold_elapsed += delta
	if not _pet_passive_repeating:
		if _pet_passive_hold_elapsed < QUALITY_FEED_HOLD_DELAY:
			return
		_pet_passive_repeating = true
		_pet_passive_suppress_click = true
		if not _upgrade_pet_passive(_pet_passive_hold_skill):
			_on_pet_passive_button_up(_pet_passive_hold_button)
		return
	_pet_passive_repeat_elapsed += delta
	if _pet_passive_repeat_elapsed < QUALITY_FEED_REPEAT_INTERVAL:
		return
	_pet_passive_repeat_elapsed = 0.0
	if not _upgrade_pet_passive(_pet_passive_hold_skill):
		_on_pet_passive_button_up(_pet_passive_hold_button)


func _upgrade_pet_passive(skill_name: String) -> bool:
	var pet: Variant = _current_pet()
	if not (pet is Dictionary) or not skill_name in PET_PASSIVE_KEYS:
		return false
	var levels := _pet_passive_levels(pet)
	var level := int(levels.get(skill_name, 0))
	if level >= _pet_passive_max_level(pet):
		_show_tip("已达到当前宠物等级上限")
		return false
	var cost := _pet_passive_cost(level)
	if PlayerData.get_soul() < cost:
		_show_tip("灵魂不足！")
		return false
	PlayerData.spend_soul(cost)
	levels[skill_name] = level + 1
	_refresh_live_pet_passives(pet)
	_refresh_current_pet()
	_refresh_pet_passive_panel(pet)
	if Global.cd_path != null and str(Global.cd_path) != "":
		MemoryClass.save_game(Global.cd_path)
	return true


func _refresh_live_pet_develop_effects(pet: Dictionary) -> void:
	if not _is_currently_active_pet(pet):
		return
	var tree := get_tree()
	if tree == null:
		return
	_refresh_live_pet_develop_effects_recursive(tree.root, pet)


func _is_currently_active_pet(pet: Dictionary) -> bool:
	if not bool(pet.get(DataKeys.DEPLOYED, false)):
		return false
	var active_name := str(_data().get(_active_pet_key(), "")).strip_edges()
	if active_name.is_empty():
		return false
	return (
		active_name == _pet_active_name(pet)
		or active_name == str(pet.get(DataKeys.ALT_NAME, "")).strip_edges()
		or active_name == str(pet.get(DataKeys.NAME, "")).strip_edges()
	)


func _live_pet_unit_matches(node: Node, pet: Dictionary) -> bool:
	match _pet_active_name(pet):
		"PetNeat":
			return bool(node.get_meta("pet_neat_unit", false))
		"PetMouse":
			return bool(node.get_meta("pet_mouse_unit", false))
		"PetRabbit":
			return bool(node.get_meta("pet_rabbit_unit", false))
		"PetTurtle":
			return (
				bool(node.get_meta("pet_turtle_unit", false))
				and not bool(node.get_meta("pet_rabbit_unit", false))
				and not bool(node.get_meta("pet_mouse_unit", false))
			)
		"PetNeat":
			return bool(node.get_meta("pet_neat_unit", false))
		"PetTiger":
			return bool(node.get_meta("pet_tiger_unit", false))
		"PetDragon":
			return bool(node.get_meta("pet_dragon_unit", false)) and not bool(node.get("is_dragon_clone"))
		"PetPhoenix":
			return bool(node.get_meta("pet_phoenix_unit", false))
		"PetYinTiger":
			return bool(node.get_meta("pet_yin_tiger_unit", false))
	return false


func _refresh_live_pet_develop_effects_recursive(node: Node, pet: Dictionary) -> bool:
	if node == null:
		return false
	if _live_pet_unit_matches(node, pet) and node.has_method("apply_pet_develop_effects"):
		node.call("apply_pet_develop_effects", pet)
		if node.has_method("apply_pet_data"):
			node.call("apply_pet_data", pet)
		return true
	for child in node.get_children():
		if _refresh_live_pet_develop_effects_recursive(child, pet):
			return true
	return false


func _refresh_live_pet_passives(pet: Dictionary) -> void:
	var tree := get_tree()
	if tree == null:
		return
	var spawn_node := _find_active_pet_spawn_node(tree.root)
	if spawn_node != null:
		var registered: Variant = spawn_node.get_meta(
			LocalCoop.pet_meta_key("active_pet_unit", LocalCoop.ui_slot), null
		)
		var registered_unit: Node = null
		if typeof(registered) == TYPE_OBJECT:
			registered_unit = registered as Node
		if (
			registered_unit != null
			and is_instance_valid(registered_unit)
			and _live_pet_unit_matches(registered_unit, pet)
		):
			if registered_unit.has_method("apply_pet_data"):
				registered_unit.call("apply_pet_data", pet)
			return
	if not _is_currently_active_pet(pet):
		return
	_refresh_live_pet_passives_recursive(tree.root, pet)


func _refresh_live_pet_passives_recursive(node: Node, pet: Dictionary) -> bool:
	if node == null:
		return false
	if _live_pet_unit_matches(node, pet) and node.has_method("apply_pet_data"):
		node.apply_pet_data(pet)
		var runtime := node.get_node_or_null("PetLearnedSkillRuntime")
		if runtime == null and not PET_LEARNED_SKILL_RUNTIME.learned_skill_names(pet).is_empty():
			runtime = PET_LEARNED_SKILL_RUNTIME.new()
			runtime.name = "PetLearnedSkillRuntime"
			runtime.setup(pet)
			node.add_child(runtime)
		elif runtime != null and runtime.has_method("refresh_after_pet_reset"):
			runtime.refresh_after_pet_reset(pet)
		return true
	for child in node.get_children():
		if _refresh_live_pet_passives_recursive(child, pet):
			return true
	return false


func _setup_pet_backpack() -> void:
	pet_pack_slots.clear()
	if pet_backpack_grid == null:
		return
	var index := 0
	for child in pet_backpack_grid.get_children():
		if child is PetBackpackSlot:
			var slot := child as PetBackpackSlot
			slot.slot_index = index
			if not slot.slot_pressed.is_connected(_on_pet_pack_slot_pressed):
				slot.slot_pressed.connect(_on_pet_pack_slot_pressed)
			_connect_pet_hover(slot, _on_pet_pack_slot_mouse_entered.bind(index), _on_pet_pack_slot_mouse_exited)
			pet_pack_slots.append(slot)
			index += 1


func _ensure_pet_pack_slot_count(item_count: int) -> void:
	if pet_backpack_grid == null:
		return
	var desired_count := maxi(PET_PACK_CAPACITY, item_count)
	var current_count := 0
	for child in pet_backpack_grid.get_children():
		if child is PetBackpackSlot:
			current_count += 1
	while current_count < desired_count:
		var slot := PET_BACKPACK_SLOT_SCENE.instantiate() as PetBackpackSlot
		if slot == null:
			break
		current_count += 1
		slot.name = "slot_%d" % current_count
		slot.set_meta("shared_pet_pack_overflow", true)
		pet_backpack_grid.add_child(slot)
	while current_count > desired_count:
		var last_slot: PetBackpackSlot = null
		for child in pet_backpack_grid.get_children():
			if child is PetBackpackSlot:
				last_slot = child as PetBackpackSlot
		if last_slot == null or not bool(last_slot.get_meta("shared_pet_pack_overflow", false)):
			break
		pet_backpack_grid.remove_child(last_slot)
		last_slot.queue_free()
		current_count -= 1
	var row_count := maxi(10, int(ceili(float(desired_count) / 4.0)))
	pet_backpack_grid.custom_minimum_size.y = float(
		row_count * (PET_SKILL_SLOT_SIZE + PET_SKILL_SLOT_GAP) - PET_SKILL_SLOT_GAP
	)
	if pet_pack_slots.size() != current_count:
		_setup_pet_backpack()


func _refresh_pack() -> void:
	var pet: Variant = _current_pet()
	var pack: Array = _pet_backpack()
	_ensure_pet_pack_slot_count(pack.size())
	for index in pet_pack_slots.size():
		var slot := pet_pack_slots[index]
		if index < pack.size() and pack[index] is Dictionary:
			var item := pack[index] as Dictionary
			slot.set_item(_pet_item_icon(item), _pet_item_tooltip(item), int(item.get(DataKeys.ENHANCE_LEVEL, 0)))
		else:
			slot.clear_item()
	_refresh_pet_equipment_slots(pet)


func _refresh_pet_equipment_slots(pet: Variant) -> void:
	var equipment: Dictionary = {}
	if pet is Dictionary and pet.get("装备", {}) is Dictionary:
		equipment = pet["装备"]
	for slot_type in PET_EQUIPMENT_SLOT_TYPES:
		var button := get_node_or_null("PetBackPackShow/%s" % slot_type) as Button
		if button == null:
			continue
		var item: Variant = equipment.get(slot_type, {})
		if item is Dictionary and not item.is_empty():
			_set_pet_equipment_slot_background(button, true)
			button.icon = _pet_item_icon(item)
			button.expand_icon = true
			_set_pet_equipment_strength_label(button, int(item.get(DataKeys.ENHANCE_LEVEL, 0)))
		else:
			_set_pet_equipment_slot_background(button, false)
			button.icon = null
			_set_pet_equipment_strength_label(button, 0)
		button.tooltip_text = ""


func _set_pet_equipment_strength_label(button: Button, strengthen_level: int) -> void:
	var label := button.get_node_or_null("StrengthLevel") as Label
	if label == null:
		label = Label.new()
		label.name = "StrengthLevel"
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		label.offset_left = 1.0
		label.offset_top = 1.0
		label.offset_right = -1.0
		label.offset_bottom = -1.0
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.add_theme_color_override("font_color", Color(1, 0.466667, 0, 1))
		label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		label.add_theme_constant_override("outline_size", 4)
		label.add_theme_font_override("font", PET_EQUIPMENT_STRENGTH_FONT)
		label.add_theme_font_size_override("font_size", 15)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		button.add_child(label)
	label.text = "+%d" % strengthen_level if strengthen_level > 0 else ""


func _set_pet_equipment_slot_background(button: Button, occupied: bool) -> void:
	if button == null:
		return
	var style: StyleBox = pet_equipment_slot_empty_style
	if occupied:
		if pet_equipment_slot_filled_style == null:
			pet_equipment_slot_filled_style = StyleBoxTexture.new()
			pet_equipment_slot_filled_style.texture = PET_EQUIPMENT_SLOT_FRAME
		style = pet_equipment_slot_filled_style
	for state in ["normal", "pressed", "hover", "disabled", "focus"]:
		button.add_theme_stylebox_override(state, style)


func _on_pet_pack_slot_pressed(index: int) -> void:
	_close_pet_action_menu()
	_hide_pet_property_popup()
	var pack: Array = _pet_backpack()
	if index < 0 or index >= pack.size() or not (pack[index] is Dictionary):
		return
	current_pack_index = index
	var item := pack[index] as Dictionary
	var slot_type := _pet_item_slot_type(item)
	if slot_type == "":
		_show_tip("该物品不是宠物装备")
		return
	_show_pet_action_menu(index, slot_type, item)


func _equip_pet_pack_item(index: int) -> bool:
	var pet: Variant = _current_pet()
	if not (pet is Dictionary):
		_show_tip("请先选择宠物")
		return false
	var pack: Array = _pet_backpack()
	if index < 0 or index >= pack.size() or not (pack[index] is Dictionary):
		return false
	var item := pack[index] as Dictionary
	var slot_type := _pet_item_slot_type(item)
	if slot_type == "":
		_show_tip("该物品不是宠物装备")
		return false
	var equipment := _ensure_pet_equipment_slots(pet)
	var old_item: Variant = equipment.get(slot_type, {})
	equipment[slot_type] = item
	pack.remove_at(index)
	if old_item is Dictionary and not old_item.is_empty():
		pack.append(old_item)
	current_pack_index = clampi(index, 0, maxi(0, pack.size() - 1))
	_finish_pet_equipment_change(pet, "已穿戴%s" % str(item.get(DataKeys.NAME, item.get(DataKeys.ALT_NAME, "宠物装备"))))
	return true


func _on_pet_equipment_slot_pressed(slot_type: String) -> void:
	_close_pet_action_menu()
	_hide_pet_property_popup()
	_unequip_pet_item(slot_type)


func _unequip_pet_item(slot_type: String) -> bool:
	var pet: Variant = _current_pet()
	if not (pet is Dictionary):
		return false
	var equipment := _ensure_pet_equipment_slots(pet)
	var item: Variant = equipment.get(slot_type, {})
	if not (item is Dictionary) or item.is_empty():
		return false
	var pack: Array = _pet_backpack()
	if pack.size() >= PET_PACK_CAPACITY:
		_show_tip("宠物背包已满")
		return false
	pack.append(item)
	equipment[slot_type] = {}
	current_pack_index = pack.size() - 1
	_finish_pet_equipment_change(pet, "已卸下%s" % str(item.get(DataKeys.NAME, item.get(DataKeys.ALT_NAME, "宠物装备"))))
	return true


func _finish_pet_equipment_change(pet: Dictionary, message: String) -> void:
	if bool(pet.get(DataKeys.DEPLOYED, false)):
		_refresh_live_pet_passives(pet)
	_refresh_all()
	_save_pet_changes()
	_show_tip(message)


func _show_pet_action_menu(index: int, slot_type: String, item: Dictionary, action_label := "装备") -> void:
	_close_pet_action_menu()
	var menu_scene := load("res://Scene/back_pack/sell_or_equ.tscn") as PackedScene
	if menu_scene == null:
		return
	var menu := menu_scene.instantiate() as Control
	if menu == null:
		return
	pet_action_menu = menu
	menu.show_behind_parent = false
	menu.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(menu)
	menu.z_index = 1000
	if menu.has_method("setup_pet_action"):
		menu.call("setup_pet_action", self, item, index, slot_type, action_label)
	_position_pet_click_menu(menu)


func _close_pet_action_menu() -> void:
	if is_instance_valid(pet_action_menu):
		pet_action_menu.queue_free()
	pet_action_menu = null


func pet_equip_from_popup(_source: Variant, index: int, slot_type: String, _action_label := "") -> bool:
	if index >= 0:
		return _equip_pet_pack_item(index)
	return _unequip_pet_item(slot_type)


func can_equip_pet_item() -> bool:
	return _current_pet() is Dictionary


func pet_sell_from_popup(_source: Variant, index: int, slot_type: String, _action_label := "") -> bool:
	var item := _pet_sale_item(index, slot_type)
	if item.is_empty():
		return false
	if _pet_item_has_socketed_gems(item):
		_show_tip("请先卸下该装备上的宝石！！")
		return false
	var price := _pet_item_sell_price(item)
	if price <= 0:
		_show_tip("该装备没有出售价格")
		return false
	var level := int(item.get(DataKeys.ENHANCE_LEVEL, 0))
	if level > 0:
		pending_pet_sale = {"index": index, "slot_type": slot_type, "item": item}
		_show_pet_batch_sell_confirm_text(
			"确定要卖出%s吗？\n（此装备已强化至+%d。）" % [_pet_item_name(item), level], Callable(self, "_confirm_pet_sale")
		)
		return true
	return _sell_pet_equipment_at(index, slot_type, item)


func _confirm_pet_sale() -> void:
	_close_pet_batch_sell_confirm()
	if pending_pet_sale.is_empty():
		return
	var sale := pending_pet_sale
	pending_pet_sale = {}
	var index := int(sale.get("index", -1))
	var slot_type := str(sale.get("slot_type", ""))
	var expected: Variant = sale.get("item", null)
	var current := _pet_sale_item(index, slot_type)
	if current.is_empty() or not is_same(current, expected):
		_show_tip("装备位置已变化，请重新选择")
		return
	if _pet_item_has_socketed_gems(current):
		_show_tip("请先卸下该装备上的宝石！！")
		return
	_sell_pet_equipment_at(index, slot_type, current)


func _pet_sale_item(index: int, slot_type: String) -> Dictionary:
	if index >= 0:
		var pack := _pet_backpack()
		if index >= pack.size() or not (pack[index] is Dictionary):
			return {}
		return pack[index] as Dictionary
	var pet: Variant = _current_pet()
	if not (pet is Dictionary):
		return {}
	var equipment := _ensure_pet_equipment_slots(pet)
	var item: Variant = equipment.get(slot_type, {})
	return item as Dictionary if item is Dictionary else {}


func _pet_item_has_socketed_gems(item: Dictionary) -> bool:
	var nested: Dictionary = item.get("Data", {}) if item.get("Data", {}) is Dictionary else {}
	for source in [item, nested]:
		for key in ["宝石", "鍓嶇煶"]:
			var gems: Variant = source.get(key, null)
			if gems is Array:
				for gem in gems:
					if str(gem).strip_edges() != "":
						return true
			elif gems is Dictionary and not (gems as Dictionary).is_empty():
				return true
			elif gems != null and str(gems).strip_edges() != "":
				return true
	return false


func _sell_pet_equipment_at(index: int, slot_type: String, expected_item: Dictionary) -> bool:
	var item := _pet_sale_item(index, slot_type)
	if item.is_empty() or not is_same(item, expected_item):
		return false
	var price := _pet_item_sell_price(item)
	if price <= 0:
		_show_tip("该装备没有出售价格")
		return false
	var pet: Variant = _current_pet()
	if index >= 0:
		_pet_backpack().remove_at(index)
	else:
		var pet_equipment := _ensure_pet_equipment_slots(pet)
		pet_equipment[slot_type] = {}
		if pet.get(DataKeys.DEPLOYED, false) == true:
			_refresh_live_pet_passives(pet)
	PlayerData.add_soul(price)
	current_pack_index = clampi(current_pack_index, 0, maxi(0, _pet_backpack().size() - 1))
	_refresh_all()
	_save_pet_changes()
	_show_tip("已出售%s，获得%d灵魂" % [_pet_item_name(item), price])
	return true


func _on_pet_batch_sell_pressed() -> void:
	if is_instance_valid(pet_batch_sell_confirm):
		return
	_show_pet_batch_sell_options()


func _default_pet_batch_sell_settings() -> Dictionary:
	return {
		"required_stats": ["", "", "", ""],
		"protect_strengthened": true,
		"protect_socketed": true,
		"protect_four_identical_stats": true,
	}


func _show_pet_batch_sell_options() -> void:
	pet_batch_sell_settings = _default_pet_batch_sell_settings()
	var popup := Control.new()
	popup.name = "PetBatchSellConfirm"
	popup.z_index = 700
	popup.process_mode = Node.PROCESS_MODE_ALWAYS
	popup.position = Vector2.ZERO
	popup.size = get_viewport().get_visible_rect().size
	popup.mouse_filter = Control.MOUSE_FILTER_STOP
	var popup_layer := Global.get_ui_popup_layer()
	if popup_layer == null:
		add_child(popup)
	else:
		popup_layer.add_child(popup)
	pet_batch_sell_confirm = popup

	var panel := Panel.new()
	panel.name = "Panel"
	panel.custom_minimum_size = Vector2(560, 500)
	panel.size = panel.custom_minimum_size
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_theme_stylebox_override("panel", _pet_batch_sell_panel_style())
	popup.add_child(panel)

	var title := Label.new()
	title.position = Vector2(24, 18)
	title.size = Vector2(512, 34)
	title.text = "批量出售宠物装备"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", PET_EQUIPMENT_STRENGTH_FONT)
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1, 0.956863, 0.74902))
	title.add_theme_color_override("font_outline_color", Color.BLACK)
	title.add_theme_constant_override("outline_size", 3)
	panel.add_child(title)

	var description := Label.new()
	description.position = Vector2(28, 58)
	description.size = Vector2(504, 42)
	description.text = "选择要保留的词条，装备必须同时满足所有已选择词条。\n未选择词条时，只按保护选项出售。锁定装备始终不会出售。"
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.add_theme_font_override("font", PET_EQUIPMENT_STRENGTH_FONT)
	description.add_theme_font_size_override("font_size", 14)
	description.add_theme_color_override("font_color", Color(1, 0.956863, 0.74902))
	description.add_theme_color_override("font_outline_color", Color.BLACK)
	description.add_theme_constant_override("outline_size", 2)
	panel.add_child(description)

	var required_stats: Array = pet_batch_sell_settings["required_stats"]
	for slot_index in range(4):
		var row_label := Label.new()
		row_label.position = Vector2(62, 112 + slot_index * 48)
		row_label.size = Vector2(112, 34)
		row_label.text = "保留词条%d" % (slot_index + 1)
		row_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row_label.add_theme_font_override("font", PET_EQUIPMENT_STRENGTH_FONT)
		row_label.add_theme_font_size_override("font_size", 16)
		row_label.add_theme_color_override("font_color", Color(1, 0.956863, 0.74902))
		row_label.add_theme_color_override("font_outline_color", Color.BLACK)
		row_label.add_theme_constant_override("outline_size", 2)
		panel.add_child(row_label)

		var option := Button.new()
		option.position = Vector2(185, 112 + slot_index * 48)
		option.size = Vector2(300, 34)
		option.custom_minimum_size = Vector2(300, 34)
		option.focus_mode = Control.FOCUS_NONE
		option.mouse_filter = Control.MOUSE_FILTER_STOP
		option.text = "不限"
		option.alignment = HORIZONTAL_ALIGNMENT_LEFT
		option.add_theme_font_override("font", PET_EQUIPMENT_STRENGTH_FONT)
		option.add_theme_font_size_override("font_size", 15)
		_style_pet_batch_sell_dropdown_button(option)
		option.pressed.connect(_open_pet_batch_sell_stat_menu.bind(panel, option, slot_index))
		panel.add_child(option)
		pet_batch_sell_stat_buttons.append(option)

	var strengthened_check := CheckButton.new()
	strengthened_check.position = Vector2(62, 315)
	strengthened_check.size = Vector2(210, 34)
	strengthened_check.text = "不出售强化装备"
	strengthened_check.button_pressed = true
	strengthened_check.focus_mode = Control.FOCUS_NONE
	strengthened_check.add_theme_font_override("font", PET_EQUIPMENT_STRENGTH_FONT)
	strengthened_check.add_theme_font_size_override("font_size", 15)
	strengthened_check.toggled.connect(_on_pet_batch_sell_protection_toggled.bind("protect_strengthened"))
	panel.add_child(strengthened_check)

	var socketed_check := CheckButton.new()
	socketed_check.position = Vector2(300, 315)
	socketed_check.size = Vector2(210, 34)
	socketed_check.text = "不出售镶嵌宝石装备"
	socketed_check.button_pressed = true
	socketed_check.focus_mode = Control.FOCUS_NONE
	socketed_check.add_theme_font_override("font", PET_EQUIPMENT_STRENGTH_FONT)
	socketed_check.add_theme_font_size_override("font_size", 15)
	socketed_check.toggled.connect(_on_pet_batch_sell_protection_toggled.bind("protect_socketed"))
	panel.add_child(socketed_check)

	var identical_stats_check := CheckButton.new()
	identical_stats_check.position = Vector2(170, 350)
	identical_stats_check.size = Vector2(220, 34)
	identical_stats_check.text = "不出售四条相同词条装备"
	identical_stats_check.button_pressed = true
	identical_stats_check.focus_mode = Control.FOCUS_NONE
	identical_stats_check.add_theme_font_override("font", PET_EQUIPMENT_STRENGTH_FONT)
	identical_stats_check.add_theme_font_size_override("font_size", 15)
	identical_stats_check.toggled.connect(_on_pet_batch_sell_protection_toggled.bind("protect_four_identical_stats"))
	panel.add_child(identical_stats_check)

	pet_batch_sell_summary_label = Label.new()
	pet_batch_sell_summary_label.position = Vector2(36, 389)
	pet_batch_sell_summary_label.size = Vector2(488, 36)
	pet_batch_sell_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pet_batch_sell_summary_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pet_batch_sell_summary_label.add_theme_font_override("font", PET_EQUIPMENT_STRENGTH_FONT)
	pet_batch_sell_summary_label.add_theme_font_size_override("font_size", 17)
	pet_batch_sell_summary_label.add_theme_color_override("font_color", Color(1, 0.956863, 0.74902))
	pet_batch_sell_summary_label.add_theme_color_override("font_outline_color", Color.BLACK)
	pet_batch_sell_summary_label.add_theme_constant_override("outline_size", 3)
	panel.add_child(pet_batch_sell_summary_label)

	var buttons := HBoxContainer.new()
	buttons.position = Vector2(135, 445)
	buttons.size = Vector2(290, 38)
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 32)
	panel.add_child(buttons)
	var confirm := Button.new()
	confirm.custom_minimum_size = Vector2(112, 36)
	confirm.mouse_filter = Control.MOUSE_FILTER_STOP
	confirm.process_mode = Node.PROCESS_MODE_ALWAYS
	confirm.text = "出售"
	_style_pet_batch_sell_button(confirm)
	confirm.pressed.connect(_confirm_pet_batch_sell)
	buttons.add_child(confirm)
	var cancel := Button.new()
	cancel.custom_minimum_size = Vector2(112, 36)
	cancel.mouse_filter = Control.MOUSE_FILTER_STOP
	cancel.process_mode = Node.PROCESS_MODE_ALWAYS
	cancel.text = "取消"
	_style_pet_batch_sell_button(cancel)
	cancel.pressed.connect(_close_pet_batch_sell_confirm)
	buttons.add_child(cancel)
	_update_pet_batch_sell_preview()
	call_deferred("_center_pet_batch_sell_confirm")


func _style_pet_batch_sell_dropdown_button(button: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.12, 0.055, 0.025, 1)
	normal.border_color = Color(0.22, 0.12, 0.06, 1)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(3)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.23, 0.11, 0.05, 1)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_color_override("font_color", Color(1, 0.956863, 0.74902))
	button.add_theme_color_override("font_hover_color", Color.WHITE)


func _open_pet_batch_sell_stat_menu(panel: Panel, option: Button, slot_index: int) -> void:
	_close_pet_batch_sell_stat_menu()
	if panel == null or option == null or not is_instance_valid(panel) or not is_instance_valid(option):
		return
	var menu := Panel.new()
	menu.name = "PetBatchSellStatMenu"
	menu.z_index = 100
	menu.mouse_filter = Control.MOUSE_FILTER_STOP
	menu.position = option.position + Vector2(0, option.size.y)
	menu.size = Vector2(option.size.x, 300)
	menu.add_theme_stylebox_override("panel", _pet_batch_sell_dropdown_panel_style())
	menu.position.y = clampf(menu.position.y, 8.0, panel.size.y - menu.size.y - 8.0)
	panel.add_child(menu)
	pet_batch_sell_stat_menu = menu

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(3, 3)
	scroll.size = menu.size - Vector2(6, 6)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	menu.add_child(scroll)
	pet_batch_sell_stat_scroll = scroll
	_register_pet_scroll(scroll)
	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 2)
	scroll.add_child(list)
	var selected_stats: Array = pet_batch_sell_settings.get("required_stats", ["", "", "", ""])
	var current_name := (
		str(selected_stats[slot_index]) if slot_index >= 0 and slot_index < selected_stats.size() else ""
	)
	var choices: Array[String] = ["不限"]
	for stat_name in PET_BATCH_SELL_STAT_OPTIONS:
		choices.append(str(stat_name))
	for choice_index in range(choices.size()):
		var choice_button := Button.new()
		choice_button.custom_minimum_size = Vector2(285, 29)
		choice_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		choice_button.focus_mode = Control.FOCUS_NONE
		choice_button.mouse_filter = Control.MOUSE_FILTER_STOP
		choice_button.text = choices[choice_index]
		choice_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		choice_button.add_theme_font_override("font", PET_EQUIPMENT_STRENGTH_FONT)
		choice_button.add_theme_font_size_override("font_size", 14)
		_style_pet_batch_sell_dropdown_button(choice_button)
		choice_button.button_pressed = (
			choices[choice_index] == current_name or (choice_index == 0 and current_name == "")
		)
		choice_button.pressed.connect(_on_pet_batch_sell_custom_stat_selected.bind(choice_index, slot_index))
		list.add_child(choice_button)


func _pet_batch_sell_dropdown_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.16, 0.075, 0.035, 1)
	style.border_color = Color(0.878431, 0.662745, 0.294118, 1)
	style.set_border_width_all(2)
	style.set_corner_radius_all(3)
	return style


func _on_pet_batch_sell_custom_stat_selected(selected_id: int, slot_index: int) -> void:
	if pet_batch_sell_touch_dragged:
		call_deferred("_reset_pet_batch_sell_touch_dragged")
		return
	_on_pet_batch_sell_stat_selected(selected_id, slot_index)
	_close_pet_batch_sell_stat_menu()


func _reset_pet_batch_sell_touch_dragged() -> void:
	pet_batch_sell_touch_dragged = false


func _close_pet_batch_sell_stat_menu() -> void:
	if is_instance_valid(pet_batch_sell_stat_scroll):
		_pet_touch_scrolls.erase(pet_batch_sell_stat_scroll)
		if _pet_touch_scroll == pet_batch_sell_stat_scroll:
			_pet_touch_scroll = null
	pet_batch_sell_stat_scroll = null
	pet_batch_sell_touch_dragged = false
	if is_instance_valid(pet_batch_sell_stat_menu):
		pet_batch_sell_stat_menu.queue_free()
	pet_batch_sell_stat_menu = null


func _on_pet_batch_sell_stat_selected(selected_id: int, slot_index: int) -> void:
	var required_stats: Array = pet_batch_sell_settings.get("required_stats", ["", "", "", ""])
	if slot_index < 0 or slot_index >= required_stats.size():
		return
	required_stats[slot_index] = "" if selected_id <= 0 else str(PET_BATCH_SELL_STAT_OPTIONS[selected_id - 1])
	pet_batch_sell_settings["required_stats"] = required_stats
	if (
		slot_index >= 0
		and slot_index < pet_batch_sell_stat_buttons.size()
		and is_instance_valid(pet_batch_sell_stat_buttons[slot_index])
	):
		pet_batch_sell_stat_buttons[slot_index].text = (
			"不限" if selected_id <= 0 else str(PET_BATCH_SELL_STAT_OPTIONS[selected_id - 1])
		)
	_update_pet_batch_sell_preview()


func _on_pet_batch_sell_protection_toggled(enabled: bool, setting_name: String) -> void:
	pet_batch_sell_settings[setting_name] = enabled
	_update_pet_batch_sell_preview()


func _update_pet_batch_sell_preview() -> void:
	if not is_instance_valid(pet_batch_sell_summary_label):
		return
	var count := 0
	var total_price := 0
	for item in _pet_backpack():
		if item is Dictionary and _pet_batch_sell_eligible(item as Dictionary, pet_batch_sell_settings):
			count += 1
			total_price += _pet_item_sell_price(item as Dictionary)
	pet_batch_sell_summary_label.text = "预计出售：%d件，获得约%d灵魂" % [count, total_price]


func _show_pet_batch_sell_confirm(eligible_count: int) -> void:
	_show_pet_batch_sell_confirm_text(
		"确定批量出售%d件宠物装备吗？\n（已锁定、强化、镶嵌宝石的装备不会出售。）" % eligible_count, Callable(self, "_confirm_pet_batch_sell")
	)


func _show_pet_batch_sell_confirm_text(confirm_text: String, confirm_callback: Callable) -> void:
	if is_instance_valid(pet_batch_sell_confirm):
		return
	var popup := Control.new()
	popup.name = "PetBatchSellConfirm"
	popup.z_index = 700
	popup.process_mode = Node.PROCESS_MODE_ALWAYS
	popup.position = Vector2.ZERO
	popup.size = get_viewport().get_visible_rect().size
	popup.mouse_filter = Control.MOUSE_FILTER_STOP
	var popup_layer := Global.get_ui_popup_layer()
	if popup_layer == null:
		add_child(popup)
	else:
		popup_layer.add_child(popup)
	pet_batch_sell_confirm = popup

	var panel := Panel.new()
	panel.name = "Panel"
	panel.custom_minimum_size = Vector2(390, 190)
	panel.size = panel.custom_minimum_size
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_theme_stylebox_override("panel", _pet_batch_sell_panel_style())
	popup.add_child(panel)

	var text := Label.new()
	text.position = Vector2(22, 24)
	text.size = Vector2(346, 86)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text.add_theme_font_override("font", PET_EQUIPMENT_STRENGTH_FONT)
	text.add_theme_font_size_override("font_size", 16)
	text.add_theme_color_override("font_color", Color(1, 0.956863, 0.74902))
	text.add_theme_color_override("font_outline_color", Color.BLACK)
	text.add_theme_constant_override("outline_size", 3)
	text.text = confirm_text
	panel.add_child(text)

	var buttons := HBoxContainer.new()
	buttons.position = Vector2(70, 135)
	buttons.size = Vector2(250, 38)
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 32)
	panel.add_child(buttons)
	var confirm := Button.new()
	confirm.custom_minimum_size = Vector2(92, 34)
	confirm.mouse_filter = Control.MOUSE_FILTER_STOP
	confirm.process_mode = Node.PROCESS_MODE_ALWAYS
	confirm.text = "确定"
	_style_pet_batch_sell_button(confirm)
	confirm.pressed.connect(confirm_callback)
	buttons.add_child(confirm)
	var cancel := Button.new()
	cancel.custom_minimum_size = Vector2(92, 34)
	cancel.mouse_filter = Control.MOUSE_FILTER_STOP
	cancel.process_mode = Node.PROCESS_MODE_ALWAYS
	cancel.text = "取消"
	_style_pet_batch_sell_button(cancel)
	cancel.pressed.connect(_close_pet_batch_sell_confirm)
	buttons.add_child(cancel)
	call_deferred("_center_pet_batch_sell_confirm")


func _center_pet_batch_sell_confirm() -> void:
	if not is_instance_valid(pet_batch_sell_confirm):
		return
	var panel := pet_batch_sell_confirm.get_node_or_null("Panel") as Panel
	if panel == null:
		return

	var viewport_size := get_viewport().get_visible_rect().size
	pet_batch_sell_confirm.position = Vector2.ZERO
	pet_batch_sell_confirm.size = viewport_size
	panel.position = (viewport_size - panel.size) * 0.5


func _pet_batch_sell_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.25, 0.12, 0.045, 1)
	style.border_color = Color(0.878431, 0.662745, 0.294118, 1)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	return style


func _style_pet_batch_sell_button(button: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.415686, 0.203922, 0.0705882, 1)
	normal.border_color = Color(0.878431, 0.662745, 0.294118, 1)
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(3)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.552941, 0.298039, 0.0784314, 1)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_font_override("font", PET_EQUIPMENT_STRENGTH_FONT)
	button.add_theme_font_size_override("font_size", 14)


func _close_pet_batch_sell_confirm() -> void:
	_close_pet_batch_sell_stat_menu()
	if is_instance_valid(pet_batch_sell_confirm):
		pet_batch_sell_confirm.queue_free()
	pet_batch_sell_confirm = null
	pet_batch_sell_summary_label = null
	pet_batch_sell_stat_buttons.clear()
	pet_batch_sell_settings = {}


func _confirm_pet_batch_sell() -> void:
	var settings := pet_batch_sell_settings.duplicate(true)
	_close_pet_batch_sell_confirm()
	var pack := _pet_backpack()
	var total_price := 0
	var sold_count := 0
	for index in range(pack.size() - 1, -1, -1):
		var item: Variant = pack[index]
		if not (item is Dictionary) or not _pet_batch_sell_eligible(item as Dictionary, settings):
			continue
		total_price += _pet_item_sell_price(item)
		pack.remove_at(index)
		sold_count += 1
	if sold_count <= 0:
		_show_tip("没有可批量出售的宠物装备")
		return
	PlayerData.add_soul(total_price)
	current_pack_index = clampi(current_pack_index, 0, maxi(0, pack.size() - 1))
	_refresh_all()
	_save_pet_changes()
	_show_tip("批量出售%d件装备，获得%d灵魂" % [sold_count, total_price])


func _pet_batch_sell_eligible(item: Dictionary, settings: Dictionary = {}) -> bool:
	if bool(item.get("锁定", false)):
		return false
	var nested: Variant = item.get("Data", {})
	if nested is Dictionary and bool(nested.get("锁定", false)):
		return false
	var protect_strengthened := bool(settings.get("protect_strengthened", true))
	if protect_strengthened and int(item.get(DataKeys.ENHANCE_LEVEL, 0)) > 0:
		return false
	var protect_socketed := bool(settings.get("protect_socketed", true))
	if protect_socketed and _pet_item_has_socketed_gems(item):
		return false
	var protect_four_identical_stats := bool(settings.get("protect_four_identical_stats", true))
	if protect_four_identical_stats and _pet_has_four_identical_random_stats(item):
		return false
	var required_stats: Variant = settings.get("required_stats", [])
	if required_stats is Array:
		var selected_stats := required_stats as Array
		var has_selected_stats := false
		for selected_value in selected_stats:
			var selected_name := str(selected_value).strip_edges()
			if selected_name != "" and selected_name != "不限":
				has_selected_stats = true
				break

		if has_selected_stats and _pet_item_matches_required_stats(item, selected_stats):
			return false
	return _pet_item_slot_type(item) != ""


func _pet_item_matches_required_stats(item: Dictionary, required_stats: Array) -> bool:
	var required_counts: Dictionary = {}
	for required_value in required_stats:
		var required_name := str(required_value).strip_edges()
		if required_name == "" or required_name == "不限":
			continue
		required_counts[required_name] = int(required_counts.get(required_name, 0)) + 1
	if required_counts.is_empty():
		return true

	var actual_counts: Dictionary = {}
	for random_value in _pet_item_random_stats(item):
		if not (random_value is Dictionary):
			continue
		var actual_name := _pet_random_stat_display_name(random_value as Dictionary)
		if actual_name != "":
			actual_counts[actual_name] = int(actual_counts.get(actual_name, 0)) + 1
	for required_name in required_counts.keys():
		if int(actual_counts.get(required_name, 0)) < int(required_counts[required_name]):
			return false
	return true


func _pet_random_stat_display_name(random_stat: Dictionary) -> String:
	var raw_name := (
		str(random_stat.get("属性", random_stat.get("属性名", random_stat.get("stat", random_stat.get("key", "")))))
		. strip_edges()
	)
	if raw_name == "":
		return ""
	if PET_ITEM_STAT_DISPLAY_NAMES.has(raw_name):
		return str(PET_ITEM_STAT_DISPLAY_NAMES[raw_name])
	for display_name in PET_ITEM_STAT_ALIASES.keys():
		if raw_name == str(display_name) or raw_name in PET_ITEM_STAT_ALIASES[display_name]:
			return str(display_name)
	return raw_name


func _pet_has_four_identical_random_stats(item: Dictionary) -> bool:
	var stats := _pet_item_random_stats(item)
	if stats.size() < 4:
		return false
	var counts: Dictionary = {}
	for stat in stats:
		if not (stat is Dictionary):
			continue
		var key := str(stat.get("属性", stat.get("属性名", stat.get("stat", stat.get("key", ""))))).strip_edges()
		if key == "":
			continue
		counts[key] = int(counts.get(key, 0)) + 1
		if int(counts[key]) >= 4:
			return true
	return false


func _pet_item_sell_price(item: Dictionary) -> int:
	var data: Dictionary = item.get("Data", {}) if item.get("Data", {}) is Dictionary else {}
	for source in [item, data]:
		for key in ["售价", "出售价格", "price", "sell_price"]:
			if source.has(key):
				var configured_price := maxi(0, int(source.get(key, 0)))
				if configured_price > 0:
					return configured_price
	var item_name := _pet_item_name(item)
	if AE != null and AE.all_equipment.has(item_name):
		var equipment_price := maxi(0, int(AE.all_equipment[item_name].get("售价", 0)))
		if equipment_price > 0:
			return equipment_price
	return 20


func _position_pet_click_menu(popup: Control) -> void:
	if popup == null:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	var estimated_size := popup.size
	if estimated_size.x <= 0.0 or estimated_size.y <= 0.0:
		estimated_size = Vector2(135, 95)
	var mouse_pos := get_tree().get_root().get_mouse_position()
	var screen_pos := mouse_pos + Vector2(18, 18)
	if screen_pos.x + estimated_size.x > viewport_size.x:
		screen_pos.x = mouse_pos.x - estimated_size.x - 18.0
	if screen_pos.y + estimated_size.y > viewport_size.y:
		screen_pos.y = viewport_size.y - estimated_size.y - 8.0
	if screen_pos.x < 8.0:
		screen_pos.x = 8.0
	if screen_pos.y < 8.0:
		screen_pos.y = 8.0
	popup.position = get_global_transform().affine_inverse() * screen_pos


func _connect_pet_hover(control: Control, entered: Callable, exited: Callable) -> void:
	if control == null:
		return
	if not control.mouse_entered.is_connected(entered):
		control.mouse_entered.connect(entered)
	if not control.mouse_exited.is_connected(exited):
		control.mouse_exited.connect(exited)


func _on_pet_pack_slot_mouse_entered(index: int) -> void:
	if is_instance_valid(pet_action_menu):
		return
	var pack: Array = _pet_backpack()
	if index < 0 or index >= pack.size() or not (pack[index] is Dictionary):
		return
	_show_pet_item_properties(pack[index] as Dictionary, pet_pack_slots[index])


func _on_pet_pack_slot_mouse_exited() -> void:
	_hide_pet_property_popup()


func _on_pet_equipment_mouse_entered(slot_type: String) -> void:
	if is_instance_valid(pet_action_menu):
		return
	var pet: Variant = _current_pet()
	if not (pet is Dictionary):
		return
	var equipment: Dictionary = _ensure_pet_equipment_slots(pet)
	var item: Variant = equipment.get(slot_type, {})
	if item is Dictionary and not item.is_empty():
		_show_pet_item_properties(item as Dictionary, get_node_or_null("PetBackPackShow/%s" % slot_type) as Control)


func _on_pet_equipment_mouse_exited() -> void:
	_hide_pet_property_popup()


func _show_pet_item_properties(item: Dictionary, _anchor: Control) -> void:
	if is_instance_valid(pet_action_menu):
		return
	_hide_pet_property_popup()
	var popup_scene := load("res://Scene/back_pack/equipment_properies.tscn") as PackedScene
	if popup_scene == null:
		return
	var popup := popup_scene.instantiate() as Node2D
	if popup == null:
		return
	popup.name = "PetEquipmentProperties"
	if popup.has_method("setup_pet_equipment"):
		popup.call("setup_pet_equipment", item, _pet_item_sell_price(item))
	add_child(popup)
	popup.z_index = 1100
	pet_property_popup = popup
	_position_pet_property_popup_at_mouse()


func _position_pet_property_popup_at_mouse() -> void:
	if not is_instance_valid(pet_property_popup):
		return
	var viewport_size := get_viewport().get_visible_rect().size
	var mouse_pos := get_tree().get_root().get_mouse_position()
	var estimated_size := Vector2(215, 240)
	var background := pet_property_popup.get_node_or_null("ColorRect") as ColorRect
	if background != null and background.size.y > 0.0:
		estimated_size = background.size
	estimated_size.y = minf(estimated_size.y, viewport_size.y - 16.0)
	var screen_pos := mouse_pos + Vector2(25, 20)
	if screen_pos.x + estimated_size.x > viewport_size.x:
		screen_pos.x = mouse_pos.x - estimated_size.x - 25.0
	if screen_pos.y + estimated_size.y > viewport_size.y:
		screen_pos.y = viewport_size.y - estimated_size.y - 8.0
	screen_pos.x = maxf(8.0, screen_pos.x)
	screen_pos.y = maxf(8.0, screen_pos.y)
	pet_property_popup.position = get_global_transform().affine_inverse() * screen_pos


func _hide_pet_property_popup() -> void:
	if is_instance_valid(pet_property_popup):
		pet_property_popup.queue_free()
	pet_property_popup = null


func _ensure_pet_equipment_slots(pet: Dictionary) -> Dictionary:
	if not (pet.get("装备", {}) is Dictionary):
		pet["装备"] = {}
	var equipment: Dictionary = pet["装备"]
	for slot_type in PET_EQUIPMENT_SLOT_TYPES:
		if not (equipment.get(slot_type, {}) is Dictionary):
			equipment[slot_type] = {}
	return equipment


func _pet_item_slot_type(item: Dictionary) -> String:
	var data: Dictionary = item.get("Data", {}) if item.get("Data", {}) is Dictionary else {}
	var raw_type := (
		str(item.get(DataKeys.TYPE, item.get("装备类型", data.get(DataKeys.TYPE, data.get("装备类型", ""))))).strip_edges()
	)
	var normalized := raw_type.to_lower()
	if normalized in PET_EQUIPMENT_SLOT_TYPES:
		return normalized
	return str({"技能": "zbst", "衣服": "zbmz", "鞋子": "zbxz", "手套": "zbyf", "帽子": "zbjn"}.get(raw_type, ""))


func _pet_item_icon(item: Dictionary) -> Texture2D:
	var data: Dictionary = item.get("Data", {}) if item.get("Data", {}) is Dictionary else {}
	for source in [item, data]:
		for key in ["图标", "图标路径", "icon", "Icon"]:
			var icon_path := str(source.get(key, "")).strip_edges()
			if icon_path == "":
				continue
			if not icon_path.begins_with("res://"):
				icon_path = "res://Art/backpack/all_items/%s" % icon_path
				if icon_path.get_extension() == "":
					icon_path += ".png"
			if ResourceLoader.exists(icon_path):
				var explicit_icon := load(icon_path) as Texture2D
				if explicit_icon != null:
					return explicit_icon
	var item_name := (
		str(
			item.get(
				DataKeys.NAME, item.get(DataKeys.ALT_NAME, data.get(DataKeys.NAME, data.get(DataKeys.ALT_NAME, "")))
			)
		)
		. strip_edges()
	)
	if item_name != "":
		var item_path := "res://Art/backpack/all_items/%s.png" % item_name
		if ResourceLoader.exists(item_path):
			var named_icon := load(item_path) as Texture2D
			if named_icon != null:
				return named_icon
	return PET_GENERIC_EQUIPMENT_ICON


func _pet_item_name(item: Dictionary) -> String:
	var data: Dictionary = item.get("Data", {}) if item.get("Data", {}) is Dictionary else {}
	return (
		str(
			item.get(
				DataKeys.NAME, item.get(DataKeys.ALT_NAME, data.get(DataKeys.NAME, data.get(DataKeys.ALT_NAME, "宠物装备")))
			)
		)
		. strip_edges()
	)


func _pet_item_tooltip(item: Dictionary) -> String:
	var data: Dictionary = item.get("Data", {}) if item.get("Data", {}) is Dictionary else {}
	var item_name := str(
		item.get(
			DataKeys.NAME, item.get(DataKeys.ALT_NAME, data.get(DataKeys.NAME, data.get(DataKeys.ALT_NAME, "宠物装备")))
		)
	)
	var lines: Array[String] = [item_name]
	var quality := str(item.get(DataKeys.QUALITY, data.get(DataKeys.QUALITY, ""))).strip_edges()
	if quality != "":
		lines.append("品质：%s" % quality)
	var slot_type := _pet_item_slot_type(item)
	if slot_type != "":
		lines.append(str(PET_EQUIPMENT_SLOT_LABELS.get(slot_type, "宠物装备")))
	var level := int(item.get(DataKeys.ENHANCE_LEVEL, 0))
	if level > 0:
		lines.append("强化 +%d" % level)
	for stat_name in [
		"生命",
		"生命上限",
		"魔法",
		"魔法上限",
		"攻击",
		"防御",
		"物防",
		"魔防",
		"暴击",
		"闪避",
		"命中",
		"幸运",
		"回血",
		"回魔",
		"破甲",
		"破魔",
		"韧性",
		"吸血",
		"暴免"
	]:
		var value := _pet_item_base_stat(item, stat_name)
		if value != 0:
			lines.append("%s +%d" % [stat_name, value])
	var is_pet_equipment := (
		str(item.get("所属", data.get("所属", ""))) == "宠物装备"
		or str(data.get(DataKeys.TYPE, "")) == "宠物装备"
		or item.has("随机属性")
	)
	if is_pet_equipment:
		var random_stats := _pet_item_random_stats(item)
		if random_stats.is_empty():
			lines.append("随机属性：拾取时生成4条（属性可重复）")
		else:
			lines.append("随机属性：")
			for random_value in random_stats:
				if not (random_value is Dictionary):
					continue
				var random_stat: Dictionary = random_value
				var stat_key := str(
					random_stat.get("属性", random_stat.get("属性名", random_stat.get("stat", random_stat.get("key", ""))))
				)
				var stat_name := str(PET_ITEM_STAT_DISPLAY_NAMES.get(stat_key, stat_key))
				var base_value := _pet_item_number_value(
					random_stat.get("数值", random_stat.get("基础值", random_stat.get("value", 0)))
				)
				var strengthen_per_level := _pet_item_number_value(
					random_stat.get(DataKeys.ENHANCE_PROP, random_stat.get("强化值", random_stat.get("strength", 0)))
				)
				var random_line := "  %s +%s" % [stat_name, _pet_item_number_text(base_value)]
				if not is_zero_approx(strengthen_per_level):
					random_line += "（强化 +%s/级" % _pet_item_number_text(strengthen_per_level)
					if level > 0:
						random_line += "，当前 +%s" % _pet_item_number_text(strengthen_per_level * float(level))
					random_line += "）"
				lines.append(random_line)
	var strengthen_data: Variant = item.get(DataKeys.ENHANCE_PROP, data.get(DataKeys.ENHANCE_PROP, {}))
	if strengthen_data is Dictionary and not (strengthen_data as Dictionary).is_empty():
		lines.append("强化属性：")
		for key in (strengthen_data as Dictionary).keys():
			var strengthen_value: Variant = (strengthen_data as Dictionary).get(key, 0)
			if typeof(strengthen_value) == TYPE_INT or typeof(strengthen_value) == TYPE_FLOAT:
				lines.append("  %s +%s" % [str(key), str(strengthen_value)])
	var price := _pet_item_sell_price(item)
	if price > 0:
		lines.append("售价：%d 灵魂" % price)
	return "\n".join(lines)


func _pet_item_random_stats(item: Dictionary) -> Array:
	for source_value in [item, item.get("Data", {})]:
		if not (source_value is Dictionary):
			continue
		var source: Dictionary = source_value
		for key in ["随机属性", "RandomStats", "random_stats"]:
			var value: Variant = source.get(key, null)
			if value is Array:
				return value as Array
	return []


func _pet_item_number_value(value: Variant) -> float:
	if typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT:
		return float(value)
	if value is String and (value as String).strip_edges().is_valid_float():
		return float(value)
	return 0.0


func _pet_item_number_text(value: float) -> String:
	if is_equal_approx(value, round(value)):
		return str(int(round(value)))
	return str(snappedf(value, 0.01))


func _pet_item_base_stat(item: Dictionary, key: String) -> int:
	var data: Dictionary = item.get("Data", {}) if item.get("Data", {}) is Dictionary else {}
	if item.has(key):
		return int(item.get(key, 0))
	if data.has(key):
		return int(data.get(key, 0))
	var aliases: Array = PET_ITEM_STAT_ALIASES.get(key, [])
	for alias in aliases:
		if item.has(alias):
			return int(item.get(alias, 0))
		if data.has(alias):
			return int(data.get(alias, 0))
	return 0


func _save_pet_changes() -> void:
	var save_path := str(Global.cd_path)
	if save_path != "" and save_path.contains("Ar_") and FileAccess.file_exists(save_path):
		MemoryClass.save_game(save_path)


func _refresh_strength() -> void:
	var item: Variant = _current_strength_item()
	if item == null:
		_set_label(str_ntxt, "未选择宠物装备")
		_set_label(str_protxt, "0/0")
		_set_label(str_ttxt, "需要强化点：0")
		_set_label(str_atxt, "已有强化点：%d" % _strength_points())
		_set_label(str_expmc, "已有珍珠：%d" % _item_count(STRENGTH_BUY_ITEM))
		return
	var level := int(item.get(DataKeys.ENHANCE_LEVEL, 0))
	var max_level := PlayerData.get_equipment_strength_max_level(item)
	_set_label(str_ntxt, "%s（+%d）" % [str(item.get(DataKeys.NAME, "宠物装备")), level])
	_set_label(str_protxt, "%d/%d" % [level, max_level])
	_set_label(str_ttxt, "已达强化上限" if level >= max_level else "需要强化点：%d" % _strength_cost(level))
	_set_label(str_atxt, "已有强化点：%d" % _strength_points())
	_set_label(str_expmc, "已有珍珠：%d" % _item_count(STRENGTH_BUY_ITEM))


func _current_pet():
	var pets := _pet_list()
	if pets.is_empty() or current_pet_index < 0 or current_pet_index >= pets.size():
		return null
	return pets[current_pet_index]


func _current_strength_item():
	var pack: Array = _pet_backpack()
	if pack.is_empty():
		return null
	current_pack_index = clampi(current_pack_index, 0, pack.size() - 1)
	return pack[current_pack_index]


func _strength_points() -> int:
	var pet: Variant = _current_pet()
	return 0 if pet == null else int(pet.get("强化点", 0))


func _strength_cost(level: int) -> int:
	return max(1, level + 1)


func _pet_skill_text(pet: Dictionary) -> String:
	var skills: Variant = pet.get("技能", [])
	if skills is Array:
		var names: Array[String] = []
		for skill in skills:
			if skill is Dictionary:
				names.append(str(skill.get(DataKeys.NAME, skill.get(DataKeys.ALT_NAME, ""))))
			else:
				names.append(str(skill))
		return "、".join(names) if not names.is_empty() else "无"
	if str(skills) == "":
		return "无"
	return str(skills)


func _pet_passive_value(pet: Dictionary, skill_name: String) -> int:
	var levels := _pet_passive_levels(pet)
	return int(PaSkill.get_value(skill_name, int(levels.get(skill_name, 0))))


func _pet_final_stat(pet: Dictionary, key: String, equipment_bonus: Variant = null) -> int:
	var value := _pet_stat(pet, key, equipment_bonus)
	match key:
		"暴击":
			value += _pet_passive_value(pet, "狂暴")
		"回血":
			value += _pet_passive_value(pet, "永恒")
		"回魔":
			value += _pet_passive_value(pet, "辉煌")
		"命中":
			value += _pet_passive_value(pet, "敏锐")
	value += _learned_pet_self_stat_bonus(pet, key, value)
	return value


func _learned_pet_self_stat_bonus(pet: Dictionary, key: String, base_value: int) -> int:
	var skill_name := ""
	match key:
		"生命":
			skill_name = "生命祝福"
		"魔法":
			skill_name = "魔法庇佑"
		"攻击":
			skill_name = "天生蛮力"
		"暴击":
			skill_name = "嗜血狂爆"
		"物防", "防", "防御", "魔防", "魔抗":
			skill_name = "自然守护"
	if skill_name.is_empty() or not _learned_pet_skills(pet).has(skill_name):
		return 0
	var skill_level := PET_SKILL_PROGRESSION.get_level(pet, skill_name)
	if skill_name == "嗜血狂爆":
		return PET_LEARNED_SKILL_RUNTIME.active_scaled_bonus(base_value, skill_level, int(pet.get("根骨", 0)))
	return PET_LEARNED_SKILL_RUNTIME.scaled_bonus(base_value, skill_level)


func _pet_equipment_bonuses(pet: Dictionary) -> Dictionary:
	if PlayerData != null and PlayerData.has_method("get_pet_equipment_bonuses"):
		return PlayerData.get_pet_equipment_bonuses(pet)
	return {}


func _pet_stat(pet: Dictionary, key: String, equipment_bonus: Variant = null) -> int:
	var stat_key := key
	if key == "防" or key == "物防":
		stat_key = "防御"
	var value := int(pet.get(stat_key, pet.get(key, 0)))
	var bonuses: Dictionary = equipment_bonus if equipment_bonus is Dictionary else _pet_equipment_bonuses(pet)
	value += int(bonuses.get(stat_key, bonuses.get(key, 0)))
	return value


func _item_matches(item: Dictionary, item_id: String) -> bool:
	if str(item.get(DataKeys.NAME, "")) == item_id or str(item.get(DataKeys.ALT_NAME, "")) == item_id:
		return true
	var item_data: Variant = item.get("Data", {})
	return item_data is Dictionary and str(item_data.get(DataKeys.NAME, "")) == item_id


func _item_count(name: String) -> int:
	var total := 0
	for list_key in ["消耗品列表", "道具列表"]:
		var pages = _data().get(list_key, {})
		if pages is Dictionary:
			for page_key in pages.keys():
				for item in pages[page_key]:
					if item is Dictionary and _item_matches(item, name):
						total += int(item.get(DataKeys.COUNT, 0))
	return total


func _consume_item(name: String, amount: int) -> bool:
	for list_key in ["消耗品列表", "道具列表"]:
		var pages = _data().get(list_key, {})
		if not (pages is Dictionary):
			continue
		for page_key in pages.keys():
			var page: Array = pages[page_key]
			var i := 0
			while i < page.size():
				var item: Variant = page[i]
				if item is Dictionary and _item_matches(item, name) and int(item.get(DataKeys.COUNT, 0)) >= amount:
					item[DataKeys.COUNT] = int(item.get(DataKeys.COUNT, 0)) - amount
					if int(item.get(DataKeys.COUNT, 0)) <= 0:
						page.remove_at(i)
					return true
				i += 1
	return false


func _find_existing_item_name(base_name: String, index: int) -> String:
	for candidate in [base_name, "%s%d" % [base_name, index], "%s1" % base_name]:
		if _item_count(candidate) > 0:
			return candidate
	return ""


func _add_exp(pet: Dictionary, amount: int) -> void:
	var player_level := PlayerData.get_capped_player_level()
	PlayerData.clamp_pet_level_to_player(pet, player_level)
	_ensure_pet_growth_fields(pet)
	pet["下级经验"] = _pet_next_exp_requirement(int(pet.get(DataKeys.LEVEL, 1)))
	if int(pet.get(DataKeys.LEVEL, 1)) >= player_level:
		pet[DataKeys.EXP] = 0
		return
	pet[DataKeys.EXP] = int(pet.get(DataKeys.EXP, 0)) + amount
	while (
		int(pet.get(DataKeys.LEVEL, 1)) < player_level
		and int(pet.get(DataKeys.EXP, 0)) >= max(1, int(pet.get("下级经验", 100)))
	):
		var next_exp: int = max(1, int(pet.get("下级经验", 100)))
		pet[DataKeys.EXP] = int(pet.get(DataKeys.EXP, 0)) - next_exp
		pet[DataKeys.LEVEL] = int(pet.get(DataKeys.LEVEL, 1)) + 1
		pet["下级经验"] = _pet_next_exp_requirement(int(pet.get(DataKeys.LEVEL, 1)))
		_apply_pet_level_growth(pet)
	if int(pet.get(DataKeys.LEVEL, 1)) >= player_level:
		pet[DataKeys.EXP] = 0
	if _is_pet_mouse(pet):
		_update_pet_mouse_evolution(pet)
	elif _is_pet_neat(pet):
		_update_pet_neat_evolution(pet)
	elif _is_pet_rabbit(pet):
		_update_pet_rabbit_evolution(pet)
	elif _is_pet_phoenix(pet):
		_update_pet_phoenix_evolution(pet)
	elif _is_pet_turtle(pet):
		_update_pet_turtle_evolution(pet)
	elif _is_pet_tiger(pet):
		_update_pet_tiger_evolution(pet)
	elif _is_pet_yin_tiger(pet):
		_update_pet_yin_tiger_evolution(pet)
	elif _is_pet_dragon(pet):
		_update_pet_dragon_evolution(pet)
	if bool(pet.get(DataKeys.DEPLOYED, false)):
		_refresh_live_pet_passives(pet)


func _ensure_pet_storage() -> void:
	if PlayerData.has_method("ensure_pet_tiger"):
		PlayerData.ensure_pet_tiger()
	if PlayerData.has_method("ensure_pet_dragon"):
		PlayerData.ensure_pet_dragon()
	if PlayerData.has_method("ensure_pet_phoenix"):
		PlayerData.ensure_pet_phoenix()
	if PlayerData.has_method("ensure_pet_turtle"):
		PlayerData.ensure_pet_turtle()
	if PlayerData.has_method("ensure_pet_rabbit"):
		PlayerData.ensure_pet_rabbit()
	if PlayerData.has_method("ensure_pet_mouse"):
		PlayerData.ensure_pet_mouse()
	if PlayerData.has_method("ensure_pet_neat"):
		PlayerData.ensure_pet_neat()
	if PlayerData.has_method("ensure_pet_yin_tiger"):
		PlayerData.ensure_pet_yin_tiger()
	var data := _data()
	var pet_key := _pet_list_key()
	var active_key := _active_pet_key()
	if not (data.get(pet_key, []) is Array):
		data[pet_key] = []
	var pets: Array = data[pet_key]
	_ensure_pet_tiger(pets)
	_ensure_pet_phoenix(pets)
	_ensure_pet_turtle(pets)
	_ensure_pet_rabbit(pets)
	_ensure_pet_mouse(pets)
	_ensure_pet_neat(pets)
	_ensure_pet_yin_tiger(pets)
	data[PET_LIST_KEY] = pets
	for i in pets.size():
		if pets[i] is Dictionary:
			_repair_phoenix_pet_data(pets[i])
			if _is_pet_mouse(pets[i]):
				_normalize_pet_mouse_name(pets[i])
			elif _is_pet_neat(pets[i]):
				_normalize_pet_neat_name(pets[i])
			elif _is_pet_turtle(pets[i]):
				_normalize_pet_turtle_name(pets[i])
			_normalize_pet(pets[i])
		else:
			pets[i] = PET_TIGER_PET.duplicate(true) if pets.is_empty() else EMPTY_PET.duplicate(true)
	_pet_backpack()
	if pets.is_empty() or current_pet_index >= pets.size():
		current_pet_index = -1
	if not data.has(active_key):
		data[active_key] = ""
	data[ACTIVE_PET_KEY] = data.get(active_key, "")


func _pet_next_exp_requirement(pet_level: int) -> int:
	return max(1, int(ceil(float(_role_level_exp_requirement(pet_level)) * 0.6)))


func _role_level_exp_requirement(level: int) -> int:
	var max_exp_list := [
		140, 160, 180, 200, 220, 300, 400, 500, 600, 700, 800, 900, 1200, 1400, 1600, 2000, 2400, 3000, 4000, 5000
	]
	var safe_level: int = max(1, level)
	if safe_level < 20:
		return int(max_exp_list[safe_level - 1])
	return 5000 + 5000 * (safe_level - 19)


func _ensure_pet_growth_fields(pet: Dictionary) -> void:
	pet["悟性"] = clampi(int(pet.get("悟性", 0)), 0, DEVELOP_MAX)
	pet["根骨"] = clampi(int(pet.get("根骨", 0)), 0, DEVELOP_MAX)
	pet["灵力"] = clampi(int(pet.get("灵力", 0)), 0, DEVELOP_MAX)
	if not pet.has("生命资质"):
		pet["生命资质"] = 1000
	if not pet.has("生命资质上限"):
		pet["生命资质上限"] = 2000
	if not pet.has("魔法资质"):
		pet["魔法资质"] = 1000
	if not pet.has("魔法资质上限"):
		pet["魔法资质上限"] = 2000
	if not pet.has("攻击资质"):
		pet["攻击资质"] = 1000
	if not pet.has("攻击资质上限"):
		pet["攻击资质上限"] = 2000
	if not pet.has("防御资质"):
		pet["防御资质"] = 1000
	if not pet.has("防御资质上限"):
		pet["防御资质上限"] = 2000
	var wisdom_bonus: int = int(pet.get("悟性", 0)) * 100
	for quality_name in ["生命", "魔法", "攻击", "防御"]:
		var maximum_key: String = "%s资质上限" % quality_name
		var base_key: String = "%s资质基础上限" % quality_name
		if not pet.has(base_key):
			pet[base_key] = int(pet.get(maximum_key, 2000))
		pet[maximum_key] = max(0, int(pet.get(base_key, 2000))) + wisdom_bonus
	pet["生命资质"] = clampi(int(pet.get("生命资质", 1000)), 0, int(pet.get("生命资质上限", 2000)))
	pet["魔法资质"] = clampi(int(pet.get("魔法资质", 1000)), 0, int(pet.get("魔法资质上限", 2000)))
	pet["攻击资质"] = clampi(int(pet.get("攻击资质", 1000)), 0, int(pet.get("攻击资质上限", 2000)))
	pet["防御资质"] = clampi(int(pet.get("防御资质", 1000)), 0, int(pet.get("防御资质上限", 2000)))


func _apply_pet_level_growth(pet: Dictionary) -> void:
	_recalculate_pet_growth_stats(pet, true)


func _recalculate_pet_growth_stats(pet: Dictionary, restore_peak: bool = false) -> void:
	_ensure_pet_growth_fields(pet)
	var old_hp_max: int = int(pet.get("生命上限", 620))
	var old_mp_max: int = int(pet.get("魔法上限", 180))
	var old_attack: int = int(pet.get(DataKeys.ATTACK, 65))
	var old_defense: int = int(pet.get(DataKeys.DEFENSE, 60))
	var level_count: int = max(0, int(pet.get(DataKeys.LEVEL, 1)) - 1)
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
	pet["物防"] = int(pet.get(DataKeys.DEFENSE, 0))
	pet["防"] = int(pet.get(DataKeys.DEFENSE, 0))
	pet["魔抗"] = int(pet.get(DataKeys.DEFENSE, 0))
	pet["魔防"] = int(pet.get(DataKeys.DEFENSE, 0))
	pet["回血"] = 2 + level_count * hp_recover_gain
	pet["回魔"] = 1 + level_count * mp_recover_gain
	if restore_peak:
		pet[DataKeys.HP] = new_hp_max
		pet[DataKeys.MP] = new_mp_max
	else:
		var current_hp: int = int(pet.get(DataKeys.HP, new_hp_max))
		var current_mp: int = int(pet.get(DataKeys.MP, new_mp_max))
		pet[DataKeys.HP] = new_hp_max if current_hp <= 0 else clampi(current_hp, 0, new_hp_max)
		pet[DataKeys.MP] = new_mp_max if current_mp <= 0 else clampi(current_mp, 0, new_mp_max)


func _ensure_pet_tiger(pets: Array) -> bool:
	for pet in pets:
		if pet is Dictionary and _is_pet_tiger(pet):
			_normalize_pet_tiger_name(pet)
			return false
	var tiger_data := (
		PlayerData.PET_TIGER_PET.duplicate(true) if "PET_TIGER_PET" in PlayerData else PET_TIGER_PET.duplicate(true)
	)
	pets.append(tiger_data)
	return true


func _ensure_pet_phoenix(pets: Array) -> bool:
	for pet in pets:
		if pet is Dictionary and _is_pet_phoenix(pet):
			_normalize_pet_phoenix_name(pet)
			return false
	var phoenix_data := PlayerData.PET_PHOENIX_PET.duplicate(true) if "PET_PHOENIX_PET" in PlayerData else {}
	if phoenix_data.is_empty():
		phoenix_data = {"名称": "雀蛋", "类型": "PetPhoenix", "阶段": 1, "等级": 1, "技能": ["涅槃"], "出战": false}
	pets.append(phoenix_data)
	return true


func _ensure_pet_turtle(pets: Array) -> bool:
	for pet in pets:
		if pet is Dictionary and _is_pet_turtle(pet):
			_normalize_pet_turtle_name(pet)
			return false
	var turtle_data := (
		PlayerData.PET_TURTLE_PET.duplicate(true) if "PET_TURTLE_PET" in PlayerData else PET_TURTLE_PET.duplicate(true)
	)
	pets.append(turtle_data)
	return true


func _ensure_pet_rabbit(pets: Array) -> bool:
	for pet in pets:
		if pet is Dictionary and _is_pet_rabbit(pet):
			_normalize_pet_rabbit_name(pet)
			return false
	if not bool(_data().get(PET_RABBIT_UNLOCK_KEY, false)):
		return false
	var rabbit_data := (
		PlayerData.PET_RABBIT_PET.duplicate(true) if "PET_RABBIT_PET" in PlayerData else PET_RABBIT_PET.duplicate(true)
	)
	pets.append(rabbit_data)
	return true


func _ensure_pet_mouse(pets: Array) -> bool:
	for pet in pets:
		if pet is Dictionary and _is_pet_mouse(pet):
			_normalize_pet_mouse_name(pet)
			return false
	var mouse_data := (
		PlayerData.PET_MOUSE_PET.duplicate(true) if "PET_MOUSE_PET" in PlayerData else PET_MOUSE_PET.duplicate(true)
	)
	pets.append(mouse_data)
	return true


func _ensure_pet_neat(pets: Array) -> bool:
	for pet in pets:
		if pet is Dictionary and _is_pet_neat(pet):
			_normalize_pet_neat_name(pet)
			return false
	var neat_data := (
		PlayerData.PET_NEAT_PET.duplicate(true) if "PET_NEAT_PET" in PlayerData else PET_NEAT_PET.duplicate(true)
	)
	pets.append(neat_data)
	return true


func _ensure_pet_yin_tiger(pets: Array) -> bool:
	for pet in pets:
		if pet is Dictionary and _is_pet_yin_tiger(pet):
			_normalize_pet_yin_tiger_name(pet)
			return false
	var yin_tiger_data := (
		PlayerData.PET_YIN_TIGER_PET.duplicate(true)
		if "PET_YIN_TIGER_PET" in PlayerData
		else PET_YIN_TIGER_PET.duplicate(true)
	)
	pets.append(yin_tiger_data)
	return true


func _is_pet_tiger(pet: Dictionary) -> bool:
	if str(pet.get(DataKeys.TYPE, "")) == "PetTiger":
		return true
	var name := str(pet.get(DataKeys.ALT_NAME, ""))
	return name == "虎丸" or name == "白灵虎" or name == "白虎将军" or name == "白虎战神" or name == "白虎"


func _is_pet_dragon(pet: Dictionary) -> bool:
	var pet_name := str(pet.get(DataKeys.ALT_NAME, ""))
	var pet_title := str(pet.get(DataKeys.NAME, ""))
	if _is_pet_phoenix_name(pet_name) or _is_pet_phoenix_name(pet_title):
		return false
	return (
		str(pet.get(DataKeys.TYPE, "")) == "PetDragon"
		or pet_name.begins_with("辰龙")
		or PET_DRAGON_STAGE_NAMES.values().has(pet_name)
	)


func _is_pet_turtle(pet: Dictionary) -> bool:
	if str(pet.get(DataKeys.TYPE, "")) == "PetTurtle":
		return true
	var pet_name := str(pet.get(DataKeys.ALT_NAME, pet.get(DataKeys.NAME, ""))).strip_edges()
	return pet_name.begins_with("玄武") or PET_TURTLE_STAGE_NAMES.values().has(pet_name)


func _is_pet_rabbit(pet: Dictionary) -> bool:
	if str(pet.get(DataKeys.TYPE, "")) == "PetRabbit":
		return true
	var pet_name := str(pet.get(DataKeys.ALT_NAME, pet.get(DataKeys.NAME, ""))).strip_edges()
	return PET_RABBIT_STAGE_NAMES.values().has(pet_name)


func _is_pet_mouse(pet: Dictionary) -> bool:
	if str(pet.get(DataKeys.TYPE, "")) == "PetMouse":
		return true
	var pet_name := str(pet.get(DataKeys.ALT_NAME, "")).strip_edges()
	var pet_title := str(pet.get(DataKeys.NAME, "")).strip_edges()
	return (
		pet_name.begins_with("子鼠")
		or pet_title.begins_with("子鼠")
		or PET_MOUSE_STAGE_NAMES.values().has(pet_name)
		or PET_MOUSE_STAGE_NAMES.values().has(pet_title)
	)


func _is_pet_neat(pet: Dictionary) -> bool:
	if str(pet.get(DataKeys.TYPE, "")) == "PetNeat":
		return true
	var pet_name := str(pet.get(DataKeys.ALT_NAME, "")).strip_edges()
	var pet_title := str(pet.get(DataKeys.NAME, "")).strip_edges()
	return pet_name in ["丑牛", "丑牛元帅", "丑牛大元帅"] or pet_title in ["丑牛", "丑牛元帅", "丑牛大元帅"]


func _is_pet_yin_tiger(pet: Dictionary) -> bool:
	if str(pet.get(DataKeys.TYPE, "")) == "PetYinTiger":
		return true
	var pet_name := str(pet.get(DataKeys.ALT_NAME, "")).strip_edges()
	var pet_title := str(pet.get(DataKeys.NAME, "")).strip_edges()
	return (
		PET_YIN_TIGER_STAGE_NAMES.values().has(pet_name)
		or PET_YIN_TIGER_STAGE_NAMES.values().has(pet_title)
		or pet_name in ["寅虎", "银角虎"]
		or pet_title in ["寅虎", "银角虎"]
	)


func _normalize_pet_neat_name(pet: Dictionary) -> void:
	if not _is_pet_neat(pet):
		return
	var base := (
		PlayerData.PET_NEAT_PET.duplicate(true) if "PET_NEAT_PET" in PlayerData else PET_NEAT_PET.duplicate(true)
	)
	for key in base.keys():
		if not pet.has(key):
			pet[key] = base[key].duplicate(true) if base[key] is Dictionary or base[key] is Array else base[key]
	var level := int(pet.get(DataKeys.LEVEL, 1))
	var stage := 4 if level >= 50 else 3 if level >= 30 else 2 if level >= 15 else 1
	pet[DataKeys.TYPE] = "PetNeat"
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = ["", "丑牛元帅", "丑牛元帅", "丑牛元帅", "丑牛大元帅"][stage]
	pet[DataKeys.NAME] = pet[DataKeys.ALT_NAME]
	pet["技能"] = [["蛮牛冲撞"], ["蛮牛冲撞"], ["蛮牛冲撞"], ["蛮牛冲撞", "蛮力践踏", "丑牛奥义"]][stage - 1]


func _update_pet_neat_evolution(pet: Dictionary) -> void:
	_normalize_pet_neat_name(pet)
	if bool(pet.get(DataKeys.DEPLOYED, false)):
		_data()[_active_pet_key()] = "PetNeat"


func _normalize_pet_yin_tiger_name(pet: Dictionary) -> void:
	if not _is_pet_yin_tiger(pet):
		return
	var base := (
		PlayerData.PET_YIN_TIGER_PET.duplicate(true)
		if "PET_YIN_TIGER_PET" in PlayerData
		else PET_YIN_TIGER_PET.duplicate(true)
	)
	for key in base.keys():
		if not pet.has(key):
			pet[key] = base[key].duplicate(true) if base[key] is Dictionary or base[key] is Array else base[key]
	var level := int(pet.get(DataKeys.LEVEL, 1))
	var stage := 4 if level >= 50 else 3 if level >= 30 else 2 if level >= 15 else 1
	pet[DataKeys.TYPE] = "PetYinTiger"
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = str(PET_YIN_TIGER_STAGE_NAMES[stage])
	pet[DataKeys.NAME] = pet[DataKeys.ALT_NAME]
	pet["技能"] = (PET_YIN_TIGER_STAGE_SKILLS[stage] as Array).duplicate(true)


func _update_pet_yin_tiger_evolution(pet: Dictionary) -> void:
	_normalize_pet_yin_tiger_name(pet)
	if bool(pet.get(DataKeys.DEPLOYED, false)):
		_data()[_active_pet_key()] = "PetYinTiger"


func _is_pet_phoenix(pet: Dictionary) -> bool:
	var pet_name := str(pet.get(DataKeys.ALT_NAME, ""))
	var pet_title := str(pet.get(DataKeys.NAME, ""))
	var type_name := str(pet.get(DataKeys.TYPE, ""))
	return type_name == "PetPhoenix" or _is_pet_phoenix_name(pet_name) or _is_pet_phoenix_name(pet_title)


func _is_pet_phoenix_name(pet_name: String) -> bool:
	var clean_name := pet_name.strip_edges()
	return (
		clean_name.begins_with("朱雀")
		or clean_name in ["雀蛋", "炎皇雀", "朱雀将军", "朱雀女皇", "朱雀幼灵", "赤羽朱雀", "朱雀神君"]
		or PET_PHOENIX_STAGE_NAMES.values().has(clean_name)
	)


func _repair_phoenix_pet_data(pet: Dictionary) -> void:
	var name_value := str(pet.get(DataKeys.ALT_NAME, ""))
	var title_value := str(pet.get(DataKeys.NAME, ""))
	if (
		not _is_pet_phoenix_name(name_value)
		and not _is_pet_phoenix_name(title_value)
		and str(pet.get(DataKeys.TYPE, "")) != "PetPhoenix"
	):
		return
	var keep_fighting := (
		bool(pet.get(DataKeys.DEPLOYED, false)) or str(_data().get(_active_pet_key(), "")) == "PetPhoenix"
	)
	var level := int(pet.get(DataKeys.LEVEL, 1))
	var level_stage: int = 4 if level >= 50 else 3 if level >= 30 else 2 if level >= 15 else 1
	var stage: int = maxi(clampi(int(pet.get("阶段", 1)), 1, 4), level_stage)
	pet[DataKeys.TYPE] = "PetPhoenix"
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = str(PET_PHOENIX_STAGE_NAMES[stage])
	pet[DataKeys.NAME] = str(PET_PHOENIX_STAGE_NAMES[stage])
	pet["技能"] = _pet_phoenix_stage_skills(stage)
	pet[DataKeys.DEPLOYED] = keep_fighting


func _normalize_pet_dragon_name(pet: Dictionary) -> void:
	if not _is_pet_dragon(pet):
		return
	var base := (
		PlayerData.PET_DRAGON_PET.duplicate(true) if "PET_DRAGON_PET" in PlayerData else PET_DRAGON_PET.duplicate(true)
	)
	for key in base.keys():
		if not pet.has(key):
			pet[key] = base[key].duplicate(true) if base[key] is Dictionary or base[key] is Array else base[key]
	pet[DataKeys.TYPE] = "PetDragon"
	pet["阶段"] = clampi(int(pet.get("阶段", 1)), 1, 4)
	pet[DataKeys.ALT_NAME] = str(PET_DRAGON_STAGE_NAMES[pet["阶段"]])
	pet["悟性"] = clampi(int(pet.get("悟性", 0)), 0, DEVELOP_MAX)
	pet["根骨"] = clampi(int(pet.get("根骨", 0)), 0, DEVELOP_MAX)
	pet["灵力"] = clampi(int(pet.get("灵力", 0)), 0, DEVELOP_MAX)
	pet["生命资质基础上限"] = 2500
	pet["魔法资质基础上限"] = 1800
	pet["攻击资质基础上限"] = 3000
	pet["防御资质基础上限"] = 1800
	_ensure_pet_growth_fields(pet)
	pet["技能"] = _pet_dragon_stage_skills(int(pet["阶段"]))


func _normalize_pet_turtle_name(pet: Dictionary) -> void:
	if not _is_pet_turtle(pet):
		return
	var base := (
		PlayerData.PET_TURTLE_PET.duplicate(true) if "PET_TURTLE_PET" in PlayerData else PET_TURTLE_PET.duplicate(true)
	)
	var keep_fighting := (
		bool(pet.get(DataKeys.DEPLOYED, false)) or str(_data().get(_active_pet_key(), "")) == "PetTurtle"
	)
	for key in base.keys():
		if not pet.has(key):
			pet[key] = base[key].duplicate(true) if base[key] is Dictionary or base[key] is Array else base[key]
	var level := int(pet.get(DataKeys.LEVEL, 1))
	var stage := 4 if level >= 50 else 3 if level >= 30 else 2 if level >= 15 else 1
	pet[DataKeys.TYPE] = "PetTurtle"
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = str(PET_TURTLE_STAGE_NAMES[stage])
	pet[DataKeys.NAME] = str(PET_TURTLE_STAGE_NAMES[stage])
	pet["生命资质基础上限"] = 4000
	pet["魔法资质基础上限"] = 1800
	pet["攻击资质基础上限"] = 1500
	pet["防御资质基础上限"] = 4000
	_ensure_pet_growth_fields(pet)
	pet["技能"] = _pet_turtle_stage_skills(stage)
	pet[DataKeys.DEPLOYED] = keep_fighting


func _normalize_pet_rabbit_name(pet: Dictionary) -> void:
	if not _is_pet_rabbit(pet):
		return
	var base := (
		PlayerData.PET_RABBIT_PET.duplicate(true) if "PET_RABBIT_PET" in PlayerData else PET_RABBIT_PET.duplicate(true)
	)
	var keep_fighting := (
		bool(pet.get(DataKeys.DEPLOYED, false)) or str(_data().get(_active_pet_key(), "")) == "PetRabbit"
	)
	for key in base.keys():
		if not pet.has(key):
			pet[key] = base[key].duplicate(true) if base[key] is Dictionary or base[key] is Array else base[key]
	var level := int(pet.get(DataKeys.LEVEL, 1))
	var stage := 4 if level >= 50 else 3 if level >= 30 else 2 if level >= 15 else 1
	pet[DataKeys.TYPE] = "PetRabbit"
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = str(PET_RABBIT_STAGE_NAMES[stage])
	pet[DataKeys.NAME] = str(PET_RABBIT_STAGE_NAMES[stage])
	pet["生命资质基础上限"] = 2500
	pet["魔法资质基础上限"] = 3000
	pet["攻击资质基础上限"] = 2800
	pet["防御资质基础上限"] = 1800
	_ensure_pet_growth_fields(pet)
	pet["技能"] = _pet_rabbit_stage_skills(stage)
	pet[DataKeys.DEPLOYED] = keep_fighting


func _normalize_pet_mouse_name(pet: Dictionary) -> void:
	if not _is_pet_mouse(pet):
		return
	var base := (
		PlayerData.PET_MOUSE_PET.duplicate(true) if "PET_MOUSE_PET" in PlayerData else PET_MOUSE_PET.duplicate(true)
	)
	var active_name := str(_data().get(_active_pet_key(), ""))
	var keep_fighting := (
		bool(pet.get(DataKeys.DEPLOYED, false))
		or active_name == "PetMouse"
		or PET_MOUSE_STAGE_NAMES.values().has(active_name)
	)
	for key in base.keys():
		if not pet.has(key):
			pet[key] = base[key].duplicate(true) if base[key] is Dictionary or base[key] is Array else base[key]
	pet["生命资质基础上限"] = 2500
	pet["魔法资质基础上限"] = 1800
	pet["攻击资质基础上限"] = 3000
	pet["防御资质基础上限"] = 1800
	_ensure_pet_growth_fields(pet)
	var stage := _pet_mouse_stage_for_level(int(pet.get(DataKeys.LEVEL, 1)))
	pet[DataKeys.TYPE] = "PetMouse"
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = str(PET_MOUSE_STAGE_NAMES[stage])
	pet[DataKeys.NAME] = str(PET_MOUSE_STAGE_NAMES[stage])
	pet["技能"] = _pet_mouse_skills_for_level(int(pet.get(DataKeys.LEVEL, 1)))
	pet[DataKeys.DEPLOYED] = keep_fighting


func _update_pet_mouse_evolution(pet: Dictionary) -> void:
	_normalize_pet_mouse_name(pet)
	if not _is_pet_mouse(pet):
		return
	var stage := _pet_mouse_stage_for_level(int(pet.get(DataKeys.LEVEL, 1)))
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = str(PET_MOUSE_STAGE_NAMES[stage])
	pet[DataKeys.NAME] = str(PET_MOUSE_STAGE_NAMES[stage])
	pet["技能"] = _pet_mouse_skills_for_level(int(pet.get(DataKeys.LEVEL, 1)))
	if bool(pet.get(DataKeys.DEPLOYED, false)):
		_data()[_active_pet_key()] = "PetMouse"


func _update_pet_rabbit_evolution(pet: Dictionary) -> void:
	_normalize_pet_rabbit_name(pet)
	var level := int(pet.get(DataKeys.LEVEL, 1))
	var stage := 4 if level >= 50 else 3 if level >= 30 else 2 if level >= 15 else 1
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = str(PET_RABBIT_STAGE_NAMES[stage])
	pet[DataKeys.NAME] = str(PET_RABBIT_STAGE_NAMES[stage])
	pet["技能"] = _pet_rabbit_stage_skills(stage)
	if bool(pet.get(DataKeys.DEPLOYED, false)):
		_data()[_active_pet_key()] = "PetRabbit"


func _update_pet_turtle_evolution(pet: Dictionary) -> void:
	_normalize_pet_turtle_name(pet)
	var level := int(pet.get(DataKeys.LEVEL, 1))
	var stage := 4 if level >= 50 else 3 if level >= 30 else 2 if level >= 15 else 1
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = str(PET_TURTLE_STAGE_NAMES[stage])
	pet[DataKeys.NAME] = str(PET_TURTLE_STAGE_NAMES[stage])
	pet["技能"] = _pet_turtle_stage_skills(stage)
	if bool(pet.get(DataKeys.DEPLOYED, false)):
		_data()[_active_pet_key()] = "PetTurtle"


func _update_pet_dragon_evolution(pet: Dictionary) -> void:
	_normalize_pet_dragon_name(pet)
	var level := int(pet.get(DataKeys.LEVEL, 1))
	pet["阶段"] = 4 if level >= 50 else 3 if level >= 30 else 2 if level >= 15 else 1
	pet[DataKeys.ALT_NAME] = str(PET_DRAGON_STAGE_NAMES[pet["阶段"]])
	pet["技能"] = _pet_dragon_stage_skills(int(pet["阶段"]))
	if bool(pet.get(DataKeys.DEPLOYED, false)):
		_data()[_active_pet_key()] = _pet_active_name(pet)


func _pet_tiger_stage_name(stage: int) -> String:
	return str(PET_TIGER_STAGE_NAMES.get(clampi(stage, 1, 4), "虎丸"))


func _pet_tiger_stage_for_level(level: int) -> int:
	if level >= 50:
		return 4
	if level >= 30:
		return 3
	if level >= 15:
		return 2
	return 1


func _pet_mouse_stage_for_level(level: int) -> int:
	return 2 if level >= 50 else 1


func _pet_tiger_stage_skills(stage: int) -> Array:
	return (PET_TIGER_STAGE_SKILLS.get(clampi(stage, 1, 4), []) as Array).duplicate(true)


func _pet_dragon_stage_skills(stage: int) -> Array:
	return (PET_DRAGON_STAGE_SKILLS.get(clampi(stage, 1, 4), []) as Array).duplicate(true)


func _pet_turtle_stage_skills(stage: int) -> Array:
	return (PET_TURTLE_STAGE_SKILLS.get(clampi(stage, 1, 4), []) as Array).duplicate(true)


func _pet_rabbit_stage_skills(stage: int) -> Array:
	return (PET_RABBIT_STAGE_SKILLS.get(clampi(stage, 1, 4), []) as Array).duplicate(true)


func _pet_mouse_skills_for_level(pet_level: int) -> Array:
	var unlock_level := 50 if pet_level >= 50 else 30 if pet_level >= 30 else 1
	return (PET_MOUSE_LEVEL_SKILLS[unlock_level] as Array).duplicate(true)


func _pet_phoenix_stage_skills(stage: int) -> Array:
	return (PET_PHOENIX_STAGE_SKILLS.get(clampi(stage, 1, 4), []) as Array).duplicate(true)


func _normalize_pet_phoenix_name(pet: Dictionary) -> void:
	if not _is_pet_phoenix(pet):
		return
	_repair_phoenix_pet_data(pet)
	var base := PlayerData.PET_PHOENIX_PET.duplicate(true) if "PET_PHOENIX_PET" in PlayerData else {}
	for key in base.keys():
		if not pet.has(key):
			pet[key] = base[key].duplicate(true) if base[key] is Dictionary or base[key] is Array else base[key]
	var level := int(pet.get(DataKeys.LEVEL, 1))
	var level_stage: int = 4 if level >= 50 else 3 if level >= 30 else 2 if level >= 15 else 1
	var stage: int = maxi(clampi(int(pet.get("阶段", 1)), 1, 4), level_stage)
	pet[DataKeys.TYPE] = "PetPhoenix"
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = str(PET_PHOENIX_STAGE_NAMES[stage])
	pet[DataKeys.NAME] = str(PET_PHOENIX_STAGE_NAMES[stage])
	var skills := _pet_phoenix_stage_skills(stage)
	pet["技能"] = skills.duplicate(true)


func _update_pet_phoenix_evolution(pet: Dictionary) -> void:
	_normalize_pet_phoenix_name(pet)
	var level := int(pet.get(DataKeys.LEVEL, 1))
	var stage := 4 if level >= 50 else 3 if level >= 30 else 2 if level >= 15 else 1
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = str(PET_PHOENIX_STAGE_NAMES[stage])
	pet[DataKeys.NAME] = str(PET_PHOENIX_STAGE_NAMES[stage])
	var skills := _pet_phoenix_stage_skills(stage)
	pet["技能"] = skills.duplicate(true)
	if bool(pet.get(DataKeys.DEPLOYED, false)):
		_data()[_active_pet_key()] = _pet_active_name(pet)


func _update_pet_tiger_evolution(pet: Dictionary) -> void:
	if not _is_pet_tiger(pet):
		return
	var stage := _pet_tiger_stage_for_level(int(pet.get(DataKeys.LEVEL, 1)))
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = _pet_tiger_stage_name(stage)
	pet[DataKeys.TYPE] = "PetTiger"
	pet["技能"] = _pet_tiger_stage_skills(stage)
	if bool(pet.get(DataKeys.DEPLOYED, false)):
		_data()[_active_pet_key()] = _pet_active_name(pet)


func _normalize_pet_tiger_name(pet: Dictionary) -> void:
	if not _is_pet_tiger(pet):
		return
	var keep_fighting := bool(pet.get(DataKeys.DEPLOYED, false))
	var tiger_data := (
		PlayerData.PET_TIGER_PET.duplicate(true) if "PET_TIGER_PET" in PlayerData else PET_TIGER_PET.duplicate(true)
	)
	for key in tiger_data.keys():
		if not pet.has(key):
			pet[key] = (
				tiger_data[key].duplicate(true)
				if tiger_data[key] is Dictionary or tiger_data[key] is Array
				else tiger_data[key]
			)
	pet["生命资质基础上限"] = 2500
	pet["魔法资质基础上限"] = 1800
	pet["攻击资质基础上限"] = 2500
	pet["防御资质基础上限"] = 1800
	_ensure_pet_growth_fields(pet)
	pet[DataKeys.TYPE] = "PetTiger"
	pet[DataKeys.DEPLOYED] = keep_fighting
	_recalculate_pet_growth_stats(pet, false)
	_update_pet_tiger_evolution(pet)


func _normalize_pet(pet: Dictionary) -> void:
	for key in EMPTY_PET.keys():
		if not pet.has(key):
			pet[key] = (
				EMPTY_PET[key].duplicate(true)
				if EMPTY_PET[key] is Dictionary or EMPTY_PET[key] is Array
				else EMPTY_PET[key]
			)
	_ensure_pet_growth_fields(pet)
	PlayerData.clamp_pet_level_to_player(pet)
	_pet_passive_levels(pet)
	pet["下级经验"] = _pet_next_exp_requirement(int(pet.get(DataKeys.LEVEL, 1)))
	_ensure_pet_equipment_slots(pet)
	PET_SKILL_PROGRESSION.ensure_levels(pet)


func _pet_list_key() -> String:
	return str(PlayerData.PET_LIST_KEY) if "PET_LIST_KEY" in PlayerData else PET_LIST_KEY


func _active_pet_key() -> String:
	return str(PlayerData.ACTIVE_PET_KEY) if "ACTIVE_PET_KEY" in PlayerData else ACTIVE_PET_KEY


func _data() -> Dictionary:
	return PlayerData.player_data


func _pet_backpack() -> Array:
	if PlayerData.has_method("ensure_shared_pet_backpack"):
		return PlayerData.ensure_shared_pet_backpack()
	var data := _data()
	if not (data.get(PET_SHARED_PACK_KEY, []) is Array):
		data[PET_SHARED_PACK_KEY] = []
	return data[PET_SHARED_PACK_KEY]


func _pet_list() -> Array:
	var data := _data()
	var key := _pet_list_key()
	if not (data.get(key, []) is Array):
		data[key] = []
	return data[key]


func _hide_sub_windows() -> void:
	_set_visible(pet_eat_immortality, false)
	_set_visible(pet_strength_interface, false)
	_set_visible(give_up_this_pet, false)
	_close_pet_action_menu()
	_hide_pet_property_popup()


func _set_visible(item: CanvasItem, value: bool) -> void:
	if item != null:
		item.visible = value


func _set_tab_state(page: int) -> void:
	if qualitymc != null:
		qualitymc.modulate = Color(1, 1, 1, 1.0 if page == PetPage.ATTRIBUTE else 0.55)
	if atebtn != null:
		atebtn.modulate = Color(1, 1, 1, 1.0 if page == PetPage.ATTRIBUTE else 0.75)
	if eipbtn != null:
		eipbtn.modulate = Color(1, 1, 1, 1.0 if page == PetPage.BACKPACK else 0.75)
	if grmmc != null:
		grmmc.modulate = Color(1, 1, 1, 1.0 if page == PetPage.DEVELOP else 0.75)


func _setup_tiger_quality_preview() -> void:
	tiger_quality_labels.clear()
	tiger_quality_wx = get_node_or_null("PetAttributeShow/TigerQualityWx") as Label
	tiger_quality_gg = get_node_or_null("PetAttributeShow/TigerQualityGg") as Label
	tiger_quality_ll = get_node_or_null("PetAttributeShow/TigerQualityLl") as Label
	if tiger_quality_wx == null:
		tiger_quality_wx = get_node_or_null("TigerQualityWx") as Label
	if tiger_quality_gg == null:
		tiger_quality_gg = get_node_or_null("TigerQualityGg") as Label
	if tiger_quality_ll == null:
		tiger_quality_ll = get_node_or_null("TigerQualityLl") as Label
	if tiger_quality_wx != null:
		tiger_quality_labels["TigerQualityWx"] = tiger_quality_wx
	if tiger_quality_gg != null:
		tiger_quality_labels["TigerQualityGg"] = tiger_quality_gg
	if tiger_quality_ll != null:
		tiger_quality_labels["TigerQualityLl"] = tiger_quality_ll
	for old_name in ["TigerQualityWx", "TigerQualityGg", "TigerQualityLl", "TigerQualityQl"]:
		var old_label := get_node_or_null(old_name) as Label
		if old_label != null and old_label.get_parent() != pet_attribute_show:
			old_label.visible = false
	var old_potential := get_node_or_null("PetAttributeShow/TigerQualityQl") as Label
	if old_potential != null:
		old_potential.visible = false


func _refresh_tiger_quality_preview(pet: Dictionary) -> void:
	if tiger_quality_labels.is_empty():
		_setup_tiger_quality_preview()
	var show_growth := (
		_is_pet_tiger(pet)
		or _is_pet_dragon(pet)
		or _is_pet_phoenix(pet)
		or _is_pet_turtle(pet)
		or _is_pet_rabbit(pet)
		or _is_pet_mouse(pet)
		or _is_pet_neat(pet)
		or _is_pet_yin_tiger(pet)
	)
	if tiger_quality_wx != null:
		tiger_quality_wx.visible = show_growth
		tiger_quality_wx.text = str(int(pet.get("悟性", 0)))
	if tiger_quality_gg != null:
		tiger_quality_gg.visible = show_growth
		tiger_quality_gg.text = str(int(pet.get("根骨", 0)))
	if tiger_quality_ll != null:
		tiger_quality_ll.visible = show_growth
		tiger_quality_ll.text = str(int(pet.get("灵力", 0)))


func _setup_pet_model_preview() -> void:
	if txtname == null:
		return
	pet_model_preview = get_node_or_null("PetModelPreview") as AnimatedSprite2D
	if pet_model_preview == null:
		pet_model_preview = AnimatedSprite2D.new()
		pet_model_preview.name = "PetModelPreview"
		pet_model_preview.top_level = true
		add_child(pet_model_preview)
	else:
		pet_model_preview.top_level = true
	pet_model_preview.scale = Vector2(0.805, 0.805)
	pet_model_preview.offset = Vector2.ZERO
	pet_model_preview.z_index = 21
	pet_model_preview.visible = false
	_update_pet_model_preview_layout()


func _update_pet_model_preview_layout() -> void:
	if pet_model_preview == null or txtname == null:
		return
	var name_center_x := txtname.global_position.x + txtname.size.x * 0.5
	var name_bottom_y := txtname.global_position.y + txtname.size.y
	pet_model_preview.position = Vector2(name_center_x, name_bottom_y + 72)


func _refresh_pet_model_preview(pet: Dictionary) -> void:
	if pet_model_preview == null:
		_setup_pet_model_preview()
	if pet_model_preview == null:
		return
	_update_pet_model_preview_layout()
	var stage := clampi(int(pet.get("阶段", 1)), 1, 4)
	pet_model_preview.offset = Vector2.ZERO
	var frames_path := ""
	if _is_pet_yin_tiger(pet):
		pet_model_preview.sprite_frames = _build_yin_tiger_preview_frames(stage)
		pet_model_preview.offset = PET_YIN_TIGER_PREVIEW_OFFSET
		pet_model_preview.animation = "wait"
		pet_model_preview.frame = 0
		pet_model_preview.frame_progress = 0.0
		pet_model_preview.play("wait")
		pet_model_preview.visible = pet_model_preview.sprite_frames != null
		return
	if _is_pet_mouse(pet):
		frames_path = "res://Art/pet/pet_mouse/model/pet_mouse_stage%d_frames.tres" % clampi(stage, 1, 2)
		pet_model_preview.offset = PET_MOUSE_PREVIEW_OFFSET
	elif _is_pet_neat(pet):
		frames_path = "res://Art/pet/pet_neat/model/pet_neat_stage%d_frames.tres" % stage
		pet_model_preview.offset = Vector2(10, -25) if stage < 4 else Vector2(10, -20)
	elif _is_pet_rabbit(pet):
		frames_path = "res://Art/pet/pet_rabbit/model/pet_rabbit_stage%d_frames.tres" % stage
		pet_model_preview.offset = PET_RABBIT_PREVIEW_OFFSETS.get(stage, Vector2.ZERO)
	elif _is_pet_phoenix(pet):
		frames_path = "res://Art/pet/pet_phoenix/model/pet_phoenix_stage%d_frames.tres" % stage
	elif _is_pet_turtle(pet):
		frames_path = "res://Art/pet/pet_turtle/model/pet_turtle_stage%d_frames.tres" % stage
	elif _is_pet_tiger(pet):
		frames_path = "res://Art/pet/pet_tiger/model/pet_tiger_stage%d_frames.tres" % stage
		pet_model_preview.offset = PET_TIGER_PREVIEW_OFFSETS.get(stage, Vector2.ZERO)
	elif _is_pet_dragon(pet):
		frames_path = "res://Art/pet/pet_dragon/model/pet_dragon_stage%d_frames.tres" % stage
	else:
		pet_model_preview.visible = false
		return
	var frames := load(frames_path) as SpriteFrames
	if frames == null or not frames.has_animation("wait"):
		pet_model_preview.visible = false
		return
	pet_model_preview.sprite_frames = frames
	pet_model_preview.animation = "wait"
	pet_model_preview.frame = 0
	pet_model_preview.frame_progress = 0.0
	pet_model_preview.play("wait")
	pet_model_preview.visible = true


func _build_yin_tiger_preview_frames(stage: int) -> SpriteFrames:
	var source_stage := 2 if stage >= 4 else 1
	var frames_path := (
		"res://Art/pet/pet_yin_tiger/model/actions/stage%d/yin_tiger_stage%d_frames.tres" % [source_stage, source_stage]
	)
	var frames := load(frames_path) as SpriteFrames
	if frames == null:
		push_error("Yin tiger preview frames missing: " + frames_path)
	return frames


func _setup_pet_name_list() -> void:
	if listtxt == null:
		return
	_set_label(listtxt, "宠物列表")
	listtxt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pet_list_scroll = get_node_or_null("PetNameScroll") as ScrollContainer
	if pet_list_scroll == null:
		pet_list_scroll = ScrollContainer.new()
		pet_list_scroll.name = "PetNameScroll"
		add_child(pet_list_scroll)
	pet_list_dropdown = pet_list_scroll.get_node_or_null("PetNameList") as VBoxContainer
	if pet_list_dropdown == null:
		pet_list_dropdown = VBoxContainer.new()
		pet_list_dropdown.name = "PetNameList"
		pet_list_scroll.add_child(pet_list_dropdown)
	pet_list_scroll.visible = true
	pet_list_scroll.top_level = false
	pet_list_scroll.position = listtxt.position + Vector2(3, listtxt.size.y + 7)
	pet_list_scroll.size = Vector2(102, 115)
	pet_list_scroll.z_index = 20
	pet_list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	pet_list_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_register_pet_scroll(pet_list_scroll)
	pet_list_dropdown.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pet_list_dropdown.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_refresh_pet_name_list(true)


func _refresh_pet_name_list(show_dropdown: bool = true) -> void:
	if listtxt == null or pet_list_scroll == null or pet_list_dropdown == null:
		return
	_set_label(listtxt, "宠物列表")
	pet_list_scroll.position = listtxt.position + Vector2(3, listtxt.size.y + 7)
	pet_list_scroll.size = Vector2(102, 115)
	for child in pet_list_dropdown.get_children():
		child.queue_free()
	var pets := _pet_list()
	if PlayerData.has_method("ensure_pet_dragon"):
		PlayerData.ensure_pet_dragon()
	if PlayerData.has_method("ensure_pet_phoenix"):
		PlayerData.ensure_pet_phoenix()
	if PlayerData.has_method("ensure_pet_turtle"):
		PlayerData.ensure_pet_turtle()
	if PlayerData.has_method("ensure_pet_rabbit"):
		PlayerData.ensure_pet_rabbit()
	if PlayerData.has_method("ensure_pet_mouse"):
		PlayerData.ensure_pet_mouse()
	if PlayerData.has_method("ensure_pet_neat"):
		PlayerData.ensure_pet_neat()
	pets = _pet_list()
	for i in pets.size():
		var pet: Variant = pets[i]
		if not (pet is Dictionary):
			continue
		if not (
			_is_pet_tiger(pet)
			or _is_pet_dragon(pet)
			or _is_pet_phoenix(pet)
			or _is_pet_turtle(pet)
			or _is_pet_rabbit(pet)
			or _is_pet_mouse(pet)
			or _is_pet_neat(pet)
			or _is_pet_yin_tiger(pet)
		):
			continue
		var row := Label.new()
		row.name = "PetName_%d" % i
		row.set_meta("pet_index", i)
		row.gui_input.connect(_on_pet_name_row_input.bind(row))
		var name := str(pet.get(DataKeys.ALT_NAME, pet.get(DataKeys.NAME, "宠物")))
		var active := (
			bool(pet.get(DataKeys.DEPLOYED, false)) or str(_data().get(_active_pet_key(), "")) == _pet_active_name(pet)
		)
		row.text = "%s(已出战)" % name if active else name
		row.custom_minimum_size = Vector2(96, 24)
		row.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.mouse_filter = Control.MOUSE_FILTER_STOP
		row.add_theme_color_override("font_color", Color(1, 0.95686275, 0.7490196, 1))
		row.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		row.add_theme_constant_override("outline_size", 3)
		row.add_theme_font_size_override("font_size", 13)
		pet_list_dropdown.add_child(row)
	pet_list_scroll.visible = show_dropdown and not pets.is_empty()


func _on_pet_name_row_input(event: InputEvent, row: Node) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var index := -1
		if row != null and row.has_meta("pet_index"):
			index = int(row.get_meta("pet_index"))
		call_deferred("_select_pet_from_list", index)


func _select_pet_from_list(index: int) -> void:
	var pets := _pet_list()
	if index < 0 or index >= pets.size():
		return
	_close_pet_action_menu()
	_hide_pet_property_popup()
	current_pet_index = index
	current_pack_index = 0
	_refresh_all()


func _connect_button(button: BaseButton, callback: Callable) -> void:
	if button != null and not button.pressed.is_connected(callback):
		button.pressed.connect(callback)


func _set_label(label: Label, value: String) -> void:
	if label != null:
		label.text = value


func _update_bar(bar: TextureProgressBar, label: Label, value: int, max_value: int) -> void:
	if bar != null:
		bar.max_value = max(1, max_value)
		bar.value = clamp(value, 0, max(1, max_value))
	_set_label(label, "%d/%d" % [clamp(value, 0, max(1, max_value)), max(1, max_value)])


func _show_tip(message: String) -> void:
	_add_tip(message)


func _add_tip(message: String) -> Control:
	if Global != null and Global.has_method("add_moment_text"):
		var viewport_center := get_viewport_rect().size * 0.5
		var local_center := get_global_transform_with_canvas().affine_inverse() * viewport_center
		var tip: Control = Global.add_moment_text(self, local_center, message, 1) as Control
		if tip != null:
			tip.z_index = maxi(700, tip.z_index)
			tip.set_anchors_preset(Control.PRESET_TOP_LEFT)
			tip.size = Vector2.ZERO
			tip.position = local_center
			var background := tip.get_node_or_null("background") as TextureRect
			var tip_label := tip.get_node_or_null("background/text_tt") as Label
			var tip_width := clampf(float(message.length() * 30 + 48), 220.0, 380.0)
			if background != null:
				background.offset_left = -tip_width * 0.5
				background.offset_right = tip_width * 0.5
			if tip_label != null:
				tip_label.offset_left = -tip_width * 0.5 + 8.0
				tip_label.offset_right = tip_width * 0.5 - 8.0
		return tip
	print(message)
	return null
