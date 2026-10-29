class_name DataKeys
extends RefCounted
## ZMXYBHYH 领域数据字典键契约类 (Phase 6-4 / Phase 7-3)
##
## 本类集中定义全工程核心字典键的强类型常量契约，
## 彻底收敛早期直接使用硬编码中文字符串传参的弱类型风险，
## 为业务代码提供 IDE 代码自动补全、编译期强类型引用与安全访问器。

# ==============================================================================
# 1. 结构化领域命名空间
# ==============================================================================


## 装备与物品元数据契约
class Item:
	const NAME = "名字"
	const ALT_NAME = "名称"
	const TYPE = "类型"
	const QUALITY = "品质"
	const DESC = "描述"
	const SOURCE = "来源"
	const BELONG = "所属"
	const COUNT = "数量"
	const ENHANCE_LEVEL = "强化等级"
	const ENHANCE_PROP = "强化属性"
	const FIVE_ELEMENTS = "五行"
	const INLAY_LIST = "镶嵌列表"
	const LOCK = "锁定"


## 装备槽位契约
class Slot:
	const WEAPON = "武器"
	const ARMOR = "防具"
	const ACCESSORY = "饰品"
	const FASHION = "时装"
	const MAGIC_WEAPON = "法宝"
	const WINGS = "翅膀"
	const TITLE = "头衔"
	const GEM = "宝石"


## 背包与仓库容器契约
class Storage:
	const EQUIPMENT_LIST = "装备列表"
	const ITEM_LIST = "道具列表"
	const CONSUMABLE_LIST = "消耗品列表"
	const TRANSMOG_LIST = "幻化列表"
	const TRANSMOG_OWNED = "幻化拥有列表"
	const WEAR_BAR = "穿戴栏"
	const DECOMPOSE_LIST = "分解列表"
	const PUT_IN_LIST = "放入列表"


## 角色核心属性与数值成长契约
class Attr:
	const LEVEL = "等级"
	const PLAYER_LEVEL = "玩家等级"
	const EXP = "经验"
	const NEXT_EXP = "下级经验"
	const HP = "生命"
	const MAX_HP = "生命上限"
	const MP = "魔法"
	const MAX_MP = "魔法上限"
	const ATTACK = "攻击"
	const DEFENSE = "防御"
	const MDEF = "魔防"
	const CRIT = "暴击"
	const LUCKY = "幸运"
	const HP_RECOVERY = "回血"
	const MP_RECOVERY = "回魔"


## 宠物与资质培养契约
class Pet:
	const ACTIVE_PET = "出战宠物"
	const DEPLOYED = "出战"
	const STAGE = "阶段"
	const SAVVY = "悟性"
	const BONE = "根骨"
	const SPIRIT = "灵力"
	const HP_TALENT = "生命资质"
	const MP_TALENT = "魔法资质"
	const ATK_TALENT = "攻击资质"
	const DEF_TALENT = "防御资质"
	const HP_TALENT_MAX = "生命资质上限"
	const MP_TALENT_MAX = "魔法资质上限"
	const ATK_TALENT_MAX = "攻击资质上限"
	const DEF_TALENT_MAX = "防御资质上限"


## 技能与热键映射契约
class Skill:
	const LEARNED = "技能学习"
	const SKILL = "技能"
	const PASSIVE = "被动技能"
	const KEYMAP = "技能键位"
	const SKILL_10 = "技能10"
	const AWAKENED = "技能觉醒"
	const AWAKENED_ENABLED = "技能觉醒启用"


## 日常任务与跨日进度契约
class Settlement:
	const DEFEAT_REWARD_CLAIMED = "失败奖励已领取"


const ACQUIRED_EQUIPMENT_LIST = "已获取装备列表"


class Daily:
	const EIGHT_IMMORTAL_TASK = "八仙尽伏"
	const EIGHT_IMMORTAL_PROGRESS = "八仙日常"
	const DATE = "日期"
	const DEFEATED = "击败"
	const CLAIMED = "已领取"


# ==============================================================================
# 2. 扁平高频快捷常量 (供全局直接快速访问: DataKeys.NAME)
# ==============================================================================

const NAME = "名字"
const ALT_NAME = "名称"
const TYPE = "类型"
const QUALITY = "品质"
const LEVEL = "等级"
const PLAYER_LEVEL = "玩家等级"
const COUNT = "数量"
const WEAPON = "武器"
const ARMOR = "防具"
const ACCESSORY = "饰品"
const FASHION = "时装"
const MAGIC_WEAPON = "法宝"
const WINGS = "翅膀"
const TITLE = "头衔"
const GEM = "宝石"
const DEPLOYED = "出战"
const EQUIPMENT_LIST = "装备列表"
const ITEM_LIST = "道具列表"
const DEFEAT_REWARD_CLAIMED = "失败奖励已领取"
const CONSUMABLE_LIST = "消耗品列表"
const TRANSMOG_LIST = "幻化列表"
const ENHANCE_LEVEL = "强化等级"
const ENHANCE_PROP = "强化属性"
const FIVE_ELEMENTS = "五行"
const INLAY_LIST = "镶嵌列表"
const DECOMPOSE_LIST = "分解列表"
const SKILL_LEARNED = "技能学习"
const HP = "生命"
const MP = "魔法"
const ATTACK = "攻击"
const DEFENSE = "防御"
const EXP = "经验"

# ==============================================================================
# 3. 契约安全访问与校验工具函数
# ==============================================================================


## 安全读取字符串名称
static func safe_name(data: Dictionary, default_val: String = "") -> String:
	return str(data.get(NAME, default_val))


## 安全读取类型
static func safe_type(data: Dictionary, default_val: String = "") -> String:
	return str(data.get(TYPE, default_val))


## 安全读取等级
static func safe_level(data: Dictionary, default_val: int = 1) -> int:
	return int(data.get(LEVEL, default_val))


## 安全读取强化等级
static func safe_enhance_level(data: Dictionary, default_val: int = 0) -> int:
	return int(data.get(ENHANCE_LEVEL, default_val))
