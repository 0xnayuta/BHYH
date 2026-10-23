extends CanvasLayer

const SECRET_CLICK_COUNT := 10
const SECRET_CLICK_WINDOW_MSEC := 3000
const SECRET_PASSWORD := "qq63334739"
const SECRET_SOUL_REWARD := 100000000
const SECRET_MAX_STRENGTHEN_LEVEL := 30
const SECRET_DIVINE_FORGE_STAGE := 5
const SECRET_ATTACK_GEM_ID := "gjs_6"
const SECRET_GEM_SOCKET_COUNT := 8
const SECRET_WEAPON_BY_ROLE := {
	1: "cswkxyhb",
	2: "cstsxyhb",
	3: "csbjxyhb",
	4: "csssxyhb",
	5: "csblxyhb",
}
const SECRET_ARMOR_BY_ROLE := {
	1: "xyfjwk",
	2: "xyfjts",
	3: "xyfjbj",
	4: "xyfjss",
	5: "xyfjbl",
}
const SECRET_ACCESSORY_ID := "cjshenj"
const SECRET_WING_ID := "xyzy"
const MAP_PROGRESS_KEYS := [
	"花果山",
	"水帘洞",
	"桃花源",
	"蝙蝠窟",
	"七星洞",
	"迦楼罗之穴",
	"浅岸",
	"东海",
	"鲨之涡流",
	"牛魔谷",
	"鬼城",
	"无常巷",
	"鬼门关",
	"接引院",
	"判官府",
	"阎罗殿",
	"忘川河",
	"奈何桥",
	"望乡台",
	"十八地狱",
	"转轮殿",
	"九重天",
	"天宫道",
	"南天门",
	"南天王殿",
	"西天王殿",
	"北天王殿",
	"彩虹楼",
	"朝会殿",
	"凌霄宝殿",
	"玲珑宝塔",
	"兜率宫",
	"兜率宫1",
	"兜率宫2",
	"兜率宫3",
	"兜率宫4",
	"兜率宫5",
	"神兽森林",
	"火龙岛",
	"九龙岛",
	"龙脊山",
	"尾妖林",
	"仙音岛",
	"仙幻岛",
	"仙树岛",
	"蓬莱岛",
	"蓬莱仙境",
	"绝仙门",
	"紫晶门",
	"戮仙门",
	"指景宫",
	"陷仙门",
	"绝境宫",
	"通天教主",
]
const MAP_5_PROGRESS_SEQUENCE := ["绝仙门", "紫晶门", "戮仙门", "指景宫", "陷仙门", "绝境宫", "通天教主"]

@onready var bb: Label = $BG/PanelContainer/HBoxContainer/InfoBg/BB
@onready var text_list: VBoxContainer = $BG/PanelContainer/HBoxContainer/InfoBg/ScrollContainer/TextList
@onready var secret_title: Label = $BG/PanelContainer/HBoxContainer/BBBg/BB
@onready var secret_password_overlay: Control = $SecretPasswordOverlay
@onready
var secret_password_input: LineEdit = $SecretPasswordOverlay/PasswordPanel/PasswordMargin/PasswordContent/PasswordInput
@onready
var secret_password_status: Label = $SecretPasswordOverlay/PasswordPanel/PasswordMargin/PasswordContent/PasswordStatus
@onready var secret_function_overlay: Control = $SecretFunctionOverlay
@onready
var secret_function_status: Label = $SecretFunctionOverlay/FunctionPanel/FunctionMargin/FunctionContent/FunctionStatus
@onready
var invincible_toggle: CheckButton = $SecretFunctionOverlay/FunctionPanel/FunctionMargin/FunctionContent/FunctionColumns/LeftColumn/Invincible
@onready
var instant_kill_toggle: CheckButton = $SecretFunctionOverlay/FunctionPanel/FunctionMargin/FunctionContent/FunctionColumns/LeftColumn/InstantKill
@onready
var all_maps_toggle: CheckButton = $SecretFunctionOverlay/FunctionPanel/FunctionMargin/FunctionContent/FunctionColumns/LeftColumn/AllMaps
@onready
var add_souls_button: Button = $SecretFunctionOverlay/FunctionPanel/FunctionMargin/FunctionContent/FunctionColumns/LeftColumn/AddSouls
@onready
var one_click_divine_set_button: Button = $SecretFunctionOverlay/FunctionPanel/FunctionMargin/FunctionContent/FunctionColumns/LeftColumn/OneClickDivineSet
@onready
var free_shop_toggle: CheckButton = $SecretFunctionOverlay/FunctionPanel/FunctionMargin/FunctionContent/FunctionColumns/RightColumn/FreeShop
@onready
var all_shop_items_toggle: CheckButton = $SecretFunctionOverlay/FunctionPanel/FunctionMargin/FunctionContent/FunctionColumns/RightColumn/AllShopItems
@onready
var wanling_max_button: Button = $SecretFunctionOverlay/FunctionPanel/FunctionMargin/FunctionContent/FunctionColumns/RightColumn/WanLingMax
@onready
var map_progress_selector: OptionButton = $SecretFunctionOverlay/FunctionPanel/FunctionMargin/FunctionContent/MapProgressRow/MapSelector
@onready
var clear_map_progress_button: Button = $SecretFunctionOverlay/FunctionPanel/FunctionMargin/FunctionContent/MapProgressRow/ClearProgress

var _secret_click_times: Array[int] = []
var _last_secret_pointer_msec := -1

var verisions_name: String = "V6_0"
var verisions: String = "V6.0"
var text_data = {
	"V6_9":
	[
		"",
		"一、版本新增内容：==============================",
		"1.修复双人模式使用宝箱卡死",
		"2.修复双人模式丹药只对1p生效",
		"3.修复双人模式法宝洗练",
		"4.日常任务八仙尽伏改成每完成一次可以领取一次",
		"5.修复双人模式忘川河异常死亡",
		"6.修复自动战斗第三个技能异常",
		"7.自动战斗添加双人模式",
		"8.修复双人模式万灵图录只对1p生效",
		"9.修复双人模式炼体只对1p生效",
		"10.修复双人模式宠物2p没有解锁",
		"11.双人模式宠物背包互通",
		"12.修复哪吒和玉兔装备不掉落",
	],
	"V6_8":
	[
		"",
		"一、版本新增内容：==============================",
		"1.新增双人模式",
		"2.双人模式怪物血量2倍 攻击1.3倍 额外25%免伤",
		"3.修复部分卡顿掉帧",
		"4.boss白条上限100改为225",
		"5.人物白条上限100改成175",
		"6.boss白条满会获取7.5秒霸体且清空技能冷却",
		"7.修复连击不显示",
	],
	"V6_7":
	[
		"",
		"一、版本新增内容：==============================",
		"1.修复玉兔角色攻击卡顿",
		"2.玉兔所有技能伤害增加",
		"3.玉兔新增技能月影追魂",
		"4.玉兔月轮技能开放觉醒",
		"5.玉兔蔓毒散技能开放觉醒",
		"6.玉兔玄毒针技能开放觉醒",
		"7.玉兔炼毒魔瓮技能开放觉醒",
	],
	"V6_6":
	[
		"",
		"一、版本新增内容：==============================",
		"1.添加新角色玉兔",
		"2.修复怪物生成数量不生效",
		"3.修复部分异常闪退",
		"4.重制青龙剑法宝",
		"5.新增法宝太极八卦",
		"6.修复哪吒音效不全",
		"7.修复雷辇嘲风飞行模式",
	],
	"V6_5":
	[
		"",
		"一、版本新增内容：==============================",
		"1.新增图鉴系统",
		"2.移除神铸对宝石加成",
		"3.新增宝石共鸣",
		"4.神铸移除副装备条件",
		"5.新增1-9阶神铸石",
		"6.添增新装备月宫防具",
		"7.添增新装备月宫武器",
		"8.背包添加整理按钮",
	],
	"V6_4":
	[
		"",
		"一、版本新增内容：==============================",
		"1.完善流沙河副本",
		"2.新增宠物装备血焰套装[三太子噩梦难度掉落]",
		"3.修复背包道具超过第十页识别不到",
		"4.修复部分地图黑边",
		"5.添加新副本琉璃宫",
		"6.添加新副本金玉宫",
		"7.添加新副本浮天台",
		"8.持国傀儡上限改为50",
		"9.幻化系统更改为获取永久解锁",
		"10.修复技能页面字体堆叠",
	],
	"V6_3":
	[
		"",
		"一、版本新增内容：==============================",
		"1.开放天庭噩梦难度",
		"2.开放万灵图录天庭一栏",
		"3.修复兜率宫战斗背景错误",
		"4.修复挑战四剑副本地狱难度不掉落宝箱",
		"5.技能等级上限提升至30[百仙园boss掉落二阶技能书]",
		"6.背包丢弃不输入数字默认全丢",
	],
	"V6_2":
	[
		"",
		"一、版本新增内容：==============================",
		"1.新增法宝震雷天锤[锦绣峰副本掉落]",
		"2.新增法宝帝空御魔圈[金沙村副本掉落]",
		"3.修复八戒不能使用土魔刺",
		"4.添加新副本蝙蝠窟",
		"5.添加新副本七星洞",
		"6.添加新副本万妖穴",
		"7.修复猴子自动战斗闪退",
	],
	"V6_1":
	[
		"",
		"一、版本新增内容：==============================",
		"1.修复哪吒技能期间无法使用无双",
		"2.移除傀儡魂晶[属性加到傀儡王上]",
		"3.开放坐骑系统[通关碧游宫开放]",
		"4.添加新坐骑西灵圣虎[通天教主掉落]",
		"5.添加新坐骑霓彩龙鱼[金之祖巫掉落]",
		"6.添加新坐骑东方苍龙[木之祖巫掉落]",
		"7.添加新坐骑雪境神鹿[水之祖巫掉落]",
		"8.添加新坐骑雷辇嘲风[火之祖巫掉落]",
		"9.添加新坐骑沧澜飞鱼[土之祖巫掉落]",
		"10.修复冥海副本boss飞出屏幕",
		"11.修复自动战斗不保存和部分闪退",
	],
	"V6_0":
	[
		"",
		"一、版本新增内容：==============================",
		"1.修复傀儡王不掉落魂晶",
		"2.修复部分翅膀闪烁",
		"3.添加新翅膀花好月圆",
		"4.添加新称号月满庆中秋",
		"5.添加新防具中秋防具",
		"6.添加新武器中秋武器",
		"7.修复部分闪退",
	],
	"V5_9":
	[
		"",
		"一、版本新增内容：==============================",
		"1.修复个别怪物不掉落魂晶",
		"2.红孩儿防御不在获取玩家防御",
		"3.开放新副本傲来国",
		"4.开放新副本花果山",
		"5.开放新副本水帘洞",
		"6.开放新副本桃花源",
		"7.优化部分技能掉帧",
		"8.修复神秘商人时装技能残留",
		"9.修复沙僧青龙剑法宝下落",
		"10.修复猴子使用棍式如山技能模型消失",
	],
	"V5_8":
	[
		"",
		"一、版本新增内容：==============================",
		"1.开放地府噩梦难度",
		"2.八戒地滚球技能开放觉醒",
		"3.八戒圣盾技能开放觉醒",
		"4.八戒战争怒吼技能开放觉醒",
		"5.白龙雷霆劫阵技能开放觉醒",
		"6.白龙天龙雷阵技能开放觉醒",
		"7.白龙翔龙闪技能开放觉醒",
		"8.白龙银钩铁画技能开放觉醒",
		"9.沙僧巫毒娃娃技能开放觉醒",
		"10.沙僧灵魂摄取技能开放觉醒",
		"11.唐僧天降甘露技能开放觉醒",
		"12.修复哪吒无双不释放技能",
		"13.自动战斗添加自动释放法宝剑阵",
	],
	"V5_7":
	[
		"",
		"一、版本新增内容：==============================",
		"1.开放自动战斗[支持简单地形副本]",
		"2.新增副本冥海",
		"3.新增副本金沙村",
		"4.新增副本百仙园",
		"5.成就商店增加觉醒石和技能书",
		"6.炼体增加一键修炼功能",
		"7.修复法术伤害不触发吸血",
		"8.广寒宫击败嫦娥100%解锁玉兔",
		"9.新增仙戒饰品[神戒+高级玉衡石+高级凝神石]",
	],
	"V5_6":
	[
		"",
		"一、版本新增内容：==============================",
		"1.修复禺狨王技能不显示",
		"2.噩梦掉落概率10%提升至25%",
		"3.噩梦掉落数量1-3改为3-5",
		"4.修复喜鹊噩梦难度不生效",
		"5.修复人物和宠物被动等级上限",
		"6.小怪虾兵蟹将的真实伤害改为物理伤害",
		"7.修镇妖塔移除噩梦难度",
		"8.人物技能增加伤害公式描述",
		"9.修复土魔刺索敌打不到祖巫",
		"10.修复怪物死亡太快不掉落东西",
		"11.修复噩梦难度牛魔王多形态属性不生效",
	],
	"V5_5":
	[
		"",
		"一、版本新增内容：==============================",
		"1.开放人间地图噩梦难度",
		"2.开放万灵图录[培养材料噩梦难度获取]",
		"3.新增属性伤害和免伤",
		"4.修复猴子火魔斩无双等级互通",
		"5.修复唐僧正法金刚技能召唤消失",
		"6.人物等级上限上调至350级",
		"7.宠物装备出售添加筛选词条",
		"8.龙王移除高低掉落物品限制",
		"9.进入关卡前弹出信息框选项默认开启",
		"10.修复九重天副本看不到梯子",
		"11.修复幻化唐僧女魃武器不显示",
	],
	"V5_4":
	[
		"",
		"一、版本新增内容：==============================",
		"1.新增宠物丑牛大元帅",
		"2.新增宠物寅虎大元帅",
		"3.新增云存档功能[测试阶段]",
		"4.修复唐僧正法金刚技能召唤消失",
		"5.正法金刚存在期间怪物优先攻击召唤物",
		"6.修复南瞻部洲副本没有音乐",
	],
	"V5_3":
	[
		"",
		"一、版本新增内容：==============================",
		"1.设置新增伤害隐藏显示",
		"2.修复成就商店购买bug",
		"3.修复存档保存丢失",
		"4.修复炼丹炉打造卡死",
		"5.晶石随机属性改为固定属性",
		"6.优化掉帧卡顿",
		"7.镇妖塔成就商店增加强化石",
	],
	"V5_2":
	[
		"",
		"一、版本新增内容：==============================",
		"1.修复苍木龙陨身后命中和技能掉帧",
		"2.修复猴子觉醒技能命中",
		"3.沙僧技能木魔舞开放觉醒",
		"4.沙僧技能剧毒阵开放觉醒",
		"5.沙僧技能万毒加护开放觉醒",
		"6.积分商城添加购买数量",
		"7.优化各种滑动条判定",
		"8.镇妖塔添加自动下一层",
		"9.宠物资质长按自动喂养",
		"10.宠物阵法添加快速升级按钮",
		"11.人物和宠物被动技能长按自动升级",
		"12.优化游戏卡顿和加载速度",
	],
	"V5_1":
	[
		"",
		"一、版本新增内容：==============================",
		"1.修复镇妖塔掉落物品",
		"2.修复世界地图看不到装备信息",
		"3.修复天庭副本打不了",
		"4.修复九重天台阶移动问题",
		"5.修复猴子觉醒技能卡顿和命中",
		"6.猴子烈焰闪开放觉醒",
		"7.沙僧新增技能苍木龙陨",
		"8.沙僧技能腾空击开放觉醒",
		"9.沙僧技能猛毒素开放觉醒",
		"10.修复沙僧新技能不触发巫毒娃娃",
		"11.一键合成添加7级宝石",
	],
	"V5_0":
	[
		"",
		"一、版本新增内容：==============================",
		"1.增加世界大地图",
		"2.新增副本镇妖塔",
		"3.开放积分商店和成就商店",
		"4.开放炼体功能[材料镇妖塔兑换]",
		"5.修复个别boss消失",
		"6.修复哪吒商店显示",
		"7.修复背包等级显示",
		"8.灵魂设置上限0-99999999999",
		"9.猴子火魔斩无双开放觉醒",
		"10.猴子烈焰风暴开放觉醒",
	],
	"V4_9":
	[
		"",
		"一、版本新增内容：==============================",
		"1.新增副本八仙过海",
		"2.新增八仙法宝",
		"3.哪吒技能增加霸体",
		"4.修复哪吒阴阳神剑被其他技能打断",
		"5.宠物无攻击目标时跟随人物",
		"6.开放淬骨功能",
		"7.破损至尊骨可以淬骨成完整至尊骨",
		"8.三妖掉落淬骨神火",
	],
	"V4_8":
	[
		"",
		"一、版本新增内容：==============================",
		"1.新增法宝多智青莲[双溪寺掉落]",
		"2.修复白龙头衔不显示",
		"3.挑战三太子增加无限模式",
		"4.宠物背包添加批量出售",
		"5.修复哪吒设置技能按键失效",
		"6.修复哪吒释放技能卡死",
		"7.修复巨灵神变大打不到",
		"8.修复天庭战神副本没有信息框",
		"9.添加新副本五台山口",
		"10.添加新副本锦绣峰",
		"11.添加新副本万佛朝阁",
	],
	"V4_7":
	[
		"",
		"一、版本新增内容：==============================",
		"1.修复哪吒被控卡死和时间过长",
		"2.修复玲珑塔无限模式一直掉白色装备",
		"3.哪吒新增技能阴阳神剑",
		"4.增强哪吒技能伤害成长",
		"5.开放哪吒技能觉醒",
		"6.修复个别buff没有图标",
		"7.修复个别宠物不显示奥义技能",
		"8.挑战四剑增加无限模式",
		"9.神兽森林增加无限模式",
		"10.28星宿增加无限模式",
		"11.诛仙剑阵等级上限调至45",
		"12.商店增加玄铁丝绸檀木基础材料",
		"13.修复boss血条覆盖其他窗口",
		"14.修复孙悟空七十二斩没有分身",
		"15.背包添加物品锁定",
		"16.新增日常任务至尊骨养成一",
	],
	"V4_6":
	[
		"",
		"一、版本新增内容：==============================",
		"1.增加新角色哪吒",
		"2.修复28星宿掉落概率",
		"3.修复棍式如山升级异常反伤",
		"4.修复三太子副本不显示",
		"5.修复清音阁岩浆掉落不死亡",
		"6.星宿3-6阶掉落数量翻3倍 7-10阶5倍",
		"7.新增称号 荒天帝[商店购买]",
		"8.炼丹炉背包可以看到人物穿戴装备",
		"9.去除九重天副本阶梯隐藏",
	],
	"V4_5":
	[
		"",
		"一、版本新增内容：==============================",
		"1.增加新宠物子鼠",
		"2.开放宠物技能学习",
		"3.开放宠物技能升级",
		"4.开放宠物阵法养成",
		"5.修复宠物装备以后使用资质丹卡顿",
		"6.修复宠物培养刷新实战属性bug",
		"7.金之祖巫添加掉落：一阶技能书",
		"8.主动技能上限调至20[升级需要一阶技能书]",
		"9.闵老护法添加掉落：7级宝石精粹",
		"10.开放7级宝石[2个同名6级宝石+7级宝石精粹合成]",
		"11.开放28星宿[掉落宠物技能书和宠物阵培养材料]",
		"12.开放新副本峨眉山道",
		"13.开放新副本清音阁",
		"14.开放新副本金顶云海",
		"15.修复地图高亮提示和关卡解锁条件",
	],
	"V4_4":
	[
		"",
		"一、版本新增内容：==============================",
		"1.开放宠物装备强化[炼丹炉强化]",
		"2.开放宠物装备镶嵌[炼丹炉镶嵌]",
		"3.修复宠物属性不全",
		"4.修复宠物暴击属性不生效",
		"5.新增被动技能 收益[增加灵魂获取]",
		"6.开放新副本未央宫",
		"7.开放新副本九华山麓",
		"8.开放新副本双溪寺",
		"9.开放新副本神光金岭",
		"10.开放新副本普陀山脚",
		"11.开放新副本九龙宝殿",
		"12.开放新副本法华灵洞",
	],
	"V4_3":
	[
		"",
		"一、版本新增内容：==============================",
		"1.开放技能觉醒",
		"2.宠物新增月兔",
		"3.开放广寒宫[通关概率解锁宠物月兔]",
		"4.朱雀街掉落技能觉醒石",
	],
	"V4_2":
	[
		"",
		"一、版本新增内容：==============================",
		"1.开放神铸系统[神器及以上品质装备可以神铸]",
		"2.玄武门掉落神铸石",
		"3.宠物开放装备系统",
		"4.开放三太子副本[掉落宠物装备]",
		"5.开放新副本朱雀街",
	],
	"V4_1":
	[
		"",
		"一、版本新增内容：==============================",
		"1.增加新副本通天教主[掉落新神器翅膀]",
		"2.增加新地图南瞻部州",
		"3.白龙神器武器增加破魔",
		"4.修复碧游宫关卡解锁条件",
		"5.修复部分电脑玩家进不去游戏",
		"6.修复白龙刑魔之翼显示错误",
		"7.优化部分卡顿",
	],
	"V4_0":
	[
		"",
		"一、版本新增内容：==============================",
		"1.增加新宠物玄武",
		"2.增加副本绝境宫[掉落仙域武器制作书]",
		"3.修复朱雀技能没有伤害",
		"4.修复宠物技能冷却显示",
		"5.白虎真实伤害转为物理伤害",
		"6.青龙真实伤害转为魔法伤害",
		"7.朱雀真实伤害转为物理伤害",
		"8.召唤物真实伤害转为魔法伤害",
		"9.修复宠物和召唤物不受到增伤加成",
		"10.修复怪物被控异常行为和攻击停顿",
		"11.添加人物和宠物等级上限 当前为300级",
		"12.猪八戒土魔刺期间增加50%双抗 反伤真伤改为魔法伤害",
		"13.地狱炼气师真实伤害改为魔法伤害",
		"14.商城增加部分时装装备且只显示当前角色时装装备",
		"15.修复神兽森林和四剑副本不受破甲效果",
		"16.设置里面可以设置帧率上限30 60 90 120 150",
		"17.修复八戒拔地乾坤后摇",
		"18.修复闪避属性不生效",
		"19.优化游戏攻击控制流程",
		"20.修复人物白条满期间不无敌",
	],
	"V3_9":
	[
		"",
		"一、版本新增内容：==============================",
		"1.增加新宠物朱雀",
		"2.修复隐藏副本进入不了",
		"3.修复任务直接领取奖励",
		"4.修复部分卡顿掉帧",
		"5.修复部分刑天死亡卡顿",
		"6.优化头衔清晰度",
		"7.优化伤害字体间隔",
	],
	"V3_8":
	[
		"",
		"一、版本新增内容：==============================",
		"1.增加新副本陷仙门",
		"2.增加新神器品质防具仙域[新副本掉落]",
		"3.修复战争怒吼技能buff",
		"4.修复紧箍咒buff和控制",
		"5.修复部分怪物技能buff",
		"6.修复部分字体乱码",
		"7.修复部分boss画质",
		"8.修复多阶段boss未击杀结算",
		"9.修复千年妖蝉光球一直存在",
		"10.修复同名装备宝石共享",
		"11.修复同名装备叠加强化加成",
		"10.修复个别怪物攻击不正常",
	],
	"V3_7":
	[
		"",
		"一、版本新增内容：==============================",
		"1.修复手机地图周围黑边",
		"2.优化所有战斗模型 人物变小 视角变大",
		"3.优化手机地图黑边",
		"4.优化地图背景和图标",
		"5.新增黑神话品质头衔 八荒湮隳[日常任务领取]",
		"6.修复战神刑天不出来",
		"7.修复多阶段boss未击杀结算",
		"8.修复部分四剑副本卡顿",
		"9.修复设置按键不能设置摇杆",
		"10.调整商城部分道具",
		"11.修复无双按钮显示",
		"12.修复白霜妖镜贴图",
	],
	"V3_6":
	[
		"",
		"一、版本新增内容：==============================",
		"1.新增诛仙剑阵培养体系",
		"2.新增副本挑战四剑【掉落诛仙剑阵培养材料】",
		"3.修复玲珑塔闪退",
		"4.修复部分卡顿",
		"5.修复青龙死亡可以重复出站",
		"6.修复神兽森林闪退",
	],
	"V3_5":
	[
		"",
		"一、版本新增内容：==============================",
		"1.增加新宠物 青龙妖圣",
		"2.增加BOSS白条系统 削弱人物宠物白条增加速度",
		"3.修复宠物命中敌人不能击退 不显示怪物血条",
		"4.修复神兽森林副本空气墙缺失",
		"5.修复进入玲珑塔闪退",
		"6.修复进入兜率宫闪退",
		"7.修复仙玉净瓶洗练成长率归零",
		"8.修复白龙角色不能创建",
		"9.修复角色新技能命中没有控制和特效",
		"10.修复角色新技能命中不显示怪物血条",
		"11.修复唐僧冰雨技能漏伤害",
		"12.修复战斗中右上角菜单看不到",
		"13.修复战斗中角色模型变白框",
	],
	"V3_4":
	[
		"",
		"一、版本新增内容：==============================",
		"1.猴子技能无双火眼金睛伤害削弱50%",
		"2.宠物开放资质根骨培养",
		"3.神兽森林掉落宠物培养材料",
		"4.修复部分手机闪退",
		"5.新增神器法宝 仙·玉净瓶[指景宫掉落]",
		"6.修复击杀怪物无法下一波",
		"7.转轮王召唤技能破甲调整至30%",
		"8.天庭战神时装破甲调整至40%",
		"9.修复新技能命中没有音效",
		"10.唐僧冰雨技能修复伤害丢失",
		"11.修复创建角色白龙失败",
		"12.修复关卡解救白龙",
		"13.修复白龙称号不正常",
	],
	"V3_3":
	[
		"",
		"一、版本新增内容：==============================",
		"1.猴子增加新技能无双火眼金睛",
		"2.新增副本神兽森林",
		"3.修复碧游宫无法进入",
		"4.修复部分弹窗进入副本不消失",
		"5.修复重新挑战人物死亡",
		"6.修复打开法宝页面卡死",
	],
	"V3_2":
	[
		"",
		"一、版本新增内容：==============================",
		"1.优化角色创建页面",
		"2.唐僧灵犀一指技能移除 添加新技能冰雨",
		"3.修复宠物升级重置被动",
		"4.修复部分战斗技能卡顿",
		"5.修复按B键开启不了宠物菜单",
		"6.优化个别手机出现白框",
		"7.优化游戏运行时间久卡顿",
		"8.优化游戏资源加载",
		"9.修复镶嵌功能卸不下来装备",
	],
	"V3_1":
	[
		"",
		"一、版本新增内容：==============================",
		"1.修复混沌之门传送卡死",
		"2.白龙新增技能 雷霆劫阵",
		"3.八戒新增技能 拔地乾坤 移除撼地重锤",
		"4.修复阎罗令传送",
		"5.新增宠物被动技能培养",
		"6.修复宠物出战显示",
		"7.神秘商人时装技能更改为落雷 20%概率眩晕敌人1秒",
	],
	"V3_0":
	[
		"",
		"一、版本新增内容：==============================",
		"1.宠物修复白条无敌",
		"2.新增宠物技能显示冷却",
		"3.修复宠物技能蓝耗",
		"4.修复宠物存在期间八戒土魔刺无法索敌",
		"5.修复宠物回蓝回血",
		"6.修复宠物攻击卡顿",
		"7.强化装备不会自动下来",
		"8.修复仙音岛宠物存在不掉落音符",
		"9.沙僧增加新技能 碧落天",
		"10.修复商城购买无法输入数量",
		"11.暂时关闭螺旋地狱",
		"12.移除五毒兽法宝",
	],
	"V2_9":
	[
		"",
		"一、版本新增内容：==============================",
		"1.开放宠物系统",
		"2.新增宠物白虎战神",
		"3.宠物1级15级30级50级都会领悟自己专属技能",
	],
	"V2_8":
	[
		"",
		"一、版本新增内容：==============================",
		"1.转轮王时装增加技能 向周围释放齿轮 40%概率眩晕敌人1秒",
		"2.转轮王时装增加强化属性",
		"3.忘川河难度降低",
		"4.修复仙音岛音符跨度太远",
		"5.修复幸运的喜鹊掉率不增加",
		"6.强化石宝箱也受幸运的喜鹊加成",
		"7.修复buff图标显示",
		"8.修复商城溢出bug",
	],
	"V2_7":
	[
		"",
		"一、版本新增内容：==============================",
		"1.新增怪物信息查看属性",
		"2.优化背包显示",
		"3.唐僧灵犀一指技能蓄力时间减半 蓄满自动释放 伤害降低60%",
		"4.唐僧水魔爆伤害上调50% 修复释放延迟",
		"5.怪物生成数量增加4倍5倍",
		"6.装备强化上限调整：神器及以下最高30级，其他品质最高50级",
		"7.玲珑宝塔无尽模式怪物属性不再强化",
		"8.被动技能每3级解锁1等级上限 上限100",
		"9.法宝等级上限调至15",
	],
	"V2_6":
	[
		"",
		"一、版本新增内容：==============================",
		"1.修复手机摇杆只能点击中间触发",
		"2.玲珑塔无限模式一直出怪",
		"3.开放副本指景宫",
		"4.增加神器饰品 智慧神戒 禅定神戒 持戒神戒",
	],
	"V2_5":
	[
		"",
		"一、版本新增内容：==============================",
		"1.修复打造字体偏移",
		"2.一键合成添加2—4强化石",
		"3.修复商城搜索bug",
		"4.修复金戒合成",
		"5.新增副本紫晶门 戮仙门",
		"6.新增神器法宝 牛魔王神器",
		"7.猴子火魔斩全部显示",
	],
	"V2_4":
	[
		"",
		"一、版本新增内容：==============================",
		"1.修复玲珑塔和兜率宫的弹窗不消失",
		"2.修复冥界令牌不进背包",
		"3.修复自选宝箱掉落不进背包",
	],
	"V2_3":
	[
		"",
		"一、版本新增内容：==============================",
		"1.地狱难度怪物增加掉落物品强化石随机宝箱15%改为20%",
		"2.增加手机自定义布局",
		"3.优化游戏加载速度",
		"4.优化游戏画质",
		"5.修复掉落宝箱不能叠加",
	],
	"V2_2":
	[
		"",
		"一、版本新增内容：==============================",
		"1.地狱难度怪物增加掉落物品 强化石随机宝箱[15%概率]",
		"2.优化商城物品",
		"3.被动技能上限上调到20级",
		"4.主动技能图标增加蓝耗",
		"5.宝珠随机属性改为固定 属性上涨",
		"6.增加神器法宝 转轮王 神器",
		"7.修复南天门小怪攻击闪退bug",
		"8.修复托塔天王攻击闪退bug",
		"9.修复召唤物可以多个存在的bug",
		"10.帧率上限上调到150",
		"11.优化连击显示",
		"12.关卡显示物品掉率",
		"13.优化关卡物品掉率",
		"14.优化手机版操控布局",
	],
	"V2_1":
	[
		"",
		"一、版本新增内容：==============================",
		"1.修复了选角色没有沙僧",
		"2.增加了手机apk版本",
	],
	"V2_0":
	[
		"2.0版本在不正经的哈的代码基础上继续开发",
		"",
		"一、版本新增内容：==============================",
		"1.增加困难和地狱难度，困难怪物血量攻击经验掉落翻倍，地狱三倍",
		"2.增加8和16倍出怪速度",
		"3.增加怪物生成数量，最高三倍[此效果boss也会生效]",
		"4.装备强化上限调整：神器及以下最高25级",
		"5.装备镶嵌宝石数量增加到8颗",
		"6.头衔,时装，翅膀可镶嵌宝石",
	],
}


func _ready() -> void:
	add_text_info()
	secret_title.mouse_filter = Control.MOUSE_FILTER_STOP
	secret_title.gui_input.connect(_on_secret_title_gui_input)
	secret_password_input.text_submitted.connect(_on_secret_password_submitted)
	$SecretPasswordOverlay/PasswordPanel/PasswordMargin/PasswordContent/PasswordButtons/Confirm.pressed.connect(
		_submit_secret_password
	)
	$SecretPasswordOverlay/PasswordPanel/PasswordMargin/PasswordContent/PasswordButtons/Cancel.pressed.connect(
		_close_secret_password
	)
	$SecretFunctionOverlay/FunctionPanel/FunctionMargin/FunctionContent/Header/Close.pressed.connect(
		_close_secret_function_page
	)
	invincible_toggle.toggled.connect(_on_invincible_toggled)
	instant_kill_toggle.toggled.connect(_on_instant_kill_toggled)
	all_maps_toggle.toggled.connect(_on_all_maps_toggled)
	add_souls_button.pressed.connect(_add_100_million_souls)
	one_click_divine_set_button.pressed.connect(_equip_one_click_divine_set)
	free_shop_toggle.toggled.connect(_on_free_shop_toggled)
	all_shop_items_toggle.toggled.connect(_on_all_shop_items_toggled)
	(
		$SecretFunctionOverlay/FunctionPanel/FunctionMargin/FunctionContent/FunctionColumns/RightColumn/PlayerMaxLevel
		. pressed
		. connect(_set_player_max_level)
	)
	(
		$SecretFunctionOverlay/FunctionPanel/FunctionMargin/FunctionContent/FunctionColumns/RightColumn/PetsMaxLevel
		. pressed
		. connect(_set_all_pets_max_level)
	)
	(
		$SecretFunctionOverlay/FunctionPanel/FunctionMargin/FunctionContent/FunctionColumns/RightColumn/PetGrowthMax
		. pressed
		. connect(_set_all_pet_growth_max)
	)
	wanling_max_button.pressed.connect(_max_all_wanling_catalog)
	clear_map_progress_button.pressed.connect(_clear_selected_map_progress)
	_setup_map_progress_selector()
	Global.set_hidden_feature_enabled(Global.HIDDEN_FEATURE_ALL_MAPS, bool(PlayerData.player_data.get("隐藏地图全开", false)))
	_sync_secret_toggles()


func register_secret_title_click(click_msec: int = -1) -> bool:
	var now_msec := Time.get_ticks_msec() if click_msec < 0 else click_msec
	while not _secret_click_times.is_empty() and now_msec - int(_secret_click_times[0]) > SECRET_CLICK_WINDOW_MSEC:
		_secret_click_times.pop_front()
	_secret_click_times.push_back(now_msec)
	if _secret_click_times.size() < SECRET_CLICK_COUNT:
		return false
	_secret_click_times.clear()
	_open_secret_password()
	return true


func _on_secret_title_gui_input(event: InputEvent) -> void:
	var pressed := false
	if event is InputEventMouseButton:
		pressed = event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	elif event is InputEventScreenTouch:
		pressed = event.pressed
	if not pressed:
		return
	var now_msec := Time.get_ticks_msec()
	if now_msec == _last_secret_pointer_msec:
		return
	_last_secret_pointer_msec = now_msec
	register_secret_title_click(now_msec)


func _open_secret_password() -> void:
	secret_function_overlay.hide()
	secret_password_input.clear()
	secret_password_status.text = ""
	secret_password_overlay.show()
	secret_password_input.call_deferred("grab_focus")


func _close_secret_password() -> void:
	secret_password_overlay.hide()
	secret_password_input.release_focus()


func _on_secret_password_submitted(_value: String) -> void:
	_submit_secret_password()


func _submit_secret_password() -> void:
	if secret_password_input.text != SECRET_PASSWORD:
		secret_password_status.text = "密钥错误"
		secret_password_input.select_all()
		secret_password_input.grab_focus()
		return
	_close_secret_password()
	_sync_secret_toggles()
	secret_function_status.text = ""
	secret_function_overlay.show()


func _close_secret_function_page() -> void:
	secret_function_overlay.hide()


func _sync_secret_toggles() -> void:
	invincible_toggle.set_pressed_no_signal(Global.is_hidden_feature_enabled(Global.HIDDEN_FEATURE_INVINCIBLE))
	instant_kill_toggle.set_pressed_no_signal(Global.is_hidden_feature_enabled(Global.HIDDEN_FEATURE_INSTANT_KILL))
	all_maps_toggle.set_pressed_no_signal(bool(PlayerData.player_data.get("隐藏地图全开", false)))
	free_shop_toggle.set_pressed_no_signal(Global.is_hidden_feature_enabled(Global.HIDDEN_FEATURE_FREE_SHOP))
	all_shop_items_toggle.set_pressed_no_signal(Global.is_hidden_feature_enabled(Global.HIDDEN_FEATURE_ALL_SHOP_ITEMS))


func _on_invincible_toggled(enabled: bool) -> void:
	Global.set_hidden_feature_enabled(Global.HIDDEN_FEATURE_INVINCIBLE, enabled)
	_show_secret_status("无敌已开启" if enabled else "无敌已关闭")


func _on_instant_kill_toggled(enabled: bool) -> void:
	Global.set_hidden_feature_enabled(Global.HIDDEN_FEATURE_INSTANT_KILL, enabled)
	_show_secret_status("秒杀已开启" if enabled else "秒杀已关闭")


func _on_all_maps_toggled(enabled: bool) -> void:
	Global.set_hidden_feature_enabled(Global.HIDDEN_FEATURE_ALL_MAPS, enabled)
	PlayerData.player_data["隐藏地图全开"] = enabled
	if enabled:
		_unlock_all_maps()
	_save_secret_progress()
	_show_secret_status("地图已全部解锁" if enabled else "地图全开已关闭，已完成的进度不会回退")


func _on_free_shop_toggled(enabled: bool) -> void:
	Global.set_hidden_feature_enabled(Global.HIDDEN_FEATURE_FREE_SHOP, enabled)
	_show_secret_status("商店0元购已开启" if enabled else "商店0元购已关闭")


func _on_all_shop_items_toggled(enabled: bool) -> void:
	Global.set_hidden_feature_enabled(Global.HIDDEN_FEATURE_ALL_SHOP_ITEMS, enabled)
	_show_secret_status("商店全物品已开启，重新打开商店后生效" if enabled else "商店全物品已关闭")


func _unlock_all_maps() -> void:
	for level_name in MAP_PROGRESS_KEYS:
		PlayerData.player_data[level_name] = 1
	for entry_key in ["可进入天庭", "可进入截教", "可进入碧游宫", "地府", "天庭", "截教天镜", "碧游宫"]:
		PlayerData.player_data[entry_key] = true
	PlayerData.player_data["玲珑宝塔层数"] = maxi(25, int(PlayerData.player_data.get("玲珑宝塔层数", 0)))
	PlayerData.player_data["兜率宫层数"] = maxi(5, int(PlayerData.player_data.get("兜率宫层数", 0)))
	MainSet.set_data["CurrentLevelPage"] = maxi(9, int(MainSet.set_data.get("CurrentLevelPage", 0)))
	for item_id in ["mjlp", "ttlp", "ttsl"]:
		if PlayerData.get_item_data(item_id) <= 0:
			PlayerData.add_dj(item_id, 1)


func _setup_map_progress_selector() -> void:
	map_progress_selector.clear()
	for level_name in MAP_PROGRESS_KEYS:
		map_progress_selector.add_item(level_name)
	if map_progress_selector.item_count > 0:
		map_progress_selector.select(0)


func _get_map_progress_keys() -> Array:
	return MAP_PROGRESS_KEYS.duplicate()


func _clear_selected_map_progress(save_progress: bool = true) -> bool:
	var selected_index := map_progress_selector.selected
	if selected_index < 0 or selected_index >= MAP_PROGRESS_KEYS.size():
		_show_secret_status("请先选择要清除进度的地图")
		return false
	var level_name: String = MAP_PROGRESS_KEYS[selected_index]
	var ratings: Variant = PlayerData.player_data.get("关卡评价", {})
	var progress_keys_to_clear: Array = [level_name]
	var map_5_index := MAP_5_PROGRESS_SEQUENCE.find(level_name)
	if map_5_index >= 0:
		progress_keys_to_clear = MAP_5_PROGRESS_SEQUENCE.slice(map_5_index)
	for progress_key in progress_keys_to_clear:
		PlayerData.player_data[str(progress_key)] = 0
		if ratings is Dictionary:
			(ratings as Dictionary)[str(progress_key)] = 0
	if level_name == "玲珑宝塔":
		PlayerData.player_data["玲珑宝塔层数"] = 0
	elif level_name.begins_with("兜率宫"):
		PlayerData.player_data["兜率宫"] = 0
		PlayerData.player_data["兜率宫层数"] = 0
		for floor_index in range(1, 6):
			PlayerData.player_data["兜率宫%d" % floor_index] = 0
		if ratings is Dictionary:
			(ratings as Dictionary)["兜率宫"] = 0
	if save_progress:
		_save_secret_progress()
	var status_text := "已清除%s的全部通关记录" % level_name
	if progress_keys_to_clear.size() > 1:
		status_text = "已清除%s及后续副本的全部通关记录" % level_name
	_show_secret_status(status_text)
	return true


func _set_player_max_level() -> void:
	PlayerData.player_data[DataKeys.PLAYER_LEVEL] = PlayerData.PLAYER_MAX_LEVEL
	PlayerData.player_data["玩家当前经验"] = 0
	RoleProp.baseroleprop.Level = PlayerData.PLAYER_MAX_LEVEL
	RoleProp.baseroleprop.exp = 0
	RoleProp.set_basic_prop()
	_save_secret_progress()
	_show_secret_status("人物已升至%d级" % PlayerData.PLAYER_MAX_LEVEL)


func _set_all_pets_max_level() -> void:
	_set_player_max_level()
	var pets: Variant = PlayerData.player_data.get(PlayerData.PET_LIST_KEY, [])
	if pets is Array:
		for pet_value in pets:
			if not (pet_value is Dictionary):
				continue
			var pet: Dictionary = pet_value
			pet[DataKeys.LEVEL] = PlayerData.PLAYER_MAX_LEVEL
			pet[DataKeys.EXP] = 0
			pet["下级经验"] = PlayerData._pet_level_exp_requirement(PlayerData.PLAYER_MAX_LEVEL)
			if pet.has("经验上限"):
				pet["经验上限"] = pet["下级经验"]
			PlayerData._recalculate_pet_stats_after_level_clamp(pet)
	_save_secret_progress()
	_show_secret_status("人物和全部宠物已升至%d级" % PlayerData.PLAYER_MAX_LEVEL)


func _set_all_pet_growth_max() -> void:
	var pets: Variant = PlayerData.player_data.get(PlayerData.PET_LIST_KEY, [])
	if pets is Array:
		for pet_value in pets:
			if not (pet_value is Dictionary):
				continue
			var pet: Dictionary = pet_value
			var old_wisdom := clampi(int(pet.get("悟性", 0)), 0, 25)
			pet["悟性"] = 25
			pet["根骨"] = 25
			pet["灵力"] = 25
			for stat_name in ["生命资质", "魔法资质", "攻击资质", "防御资质"]:
				var max_key: String = str(stat_name) + "上限"
				var base_key: String = str(stat_name) + "基础上限"
				var base_max := int(pet.get(base_key, int(pet.get(max_key, 0)) - old_wisdom * 100))
				base_max = maxi(0, base_max)
				pet[base_key] = base_max
				pet[max_key] = base_max + 2500
				pet[stat_name] = pet[max_key]
			PlayerData._recalculate_pet_stats_after_level_clamp(pet)
	_save_secret_progress()
	_show_secret_status("全部宠物资质、悟性、根骨和灵力已满")


func _max_all_wanling_catalog(save_progress: bool = true) -> void:
	var catalog := PlayerData.ensure_wanling_catalog_data()
	var human_levels: Dictionary = catalog.get(PlayerData.WANLING_HUMAN_CATEGORY, {})
	for monster_id in PlayerData.WANLING_HUMAN_MONSTER_IDS:
		human_levels[str(int(monster_id))] = PlayerData.get_wanling_human_consume_limit(int(monster_id))
	catalog[PlayerData.WANLING_HUMAN_CATEGORY] = human_levels

	var underworld_levels: Dictionary = catalog.get(PlayerData.WANLING_UNDERWORLD_CATEGORY, {})
	for monster_id in PlayerData.WANLING_UNDERWORLD_MONSTER_IDS:
		underworld_levels[str(int(monster_id))] = PlayerData.get_wanling_underworld_consume_limit(int(monster_id))
	catalog[PlayerData.WANLING_UNDERWORLD_CATEGORY] = underworld_levels

	var heaven_levels: Dictionary = catalog.get(PlayerData.WANLING_HEAVEN_CATEGORY, {})
	for monster_id in PlayerData.WANLING_HEAVEN_MONSTER_IDS:
		heaven_levels[str(int(monster_id))] = PlayerData.get_wanling_heaven_consume_limit(int(monster_id))
	catalog[PlayerData.WANLING_HEAVEN_CATEGORY] = heaven_levels
	PlayerData.player_data[PlayerData.WANLING_CATALOG_LEVELS_KEY] = catalog
	if save_progress:
		_save_secret_progress()
	_show_secret_status("全部图录已满级")


func _add_100_million_souls(save_progress: bool = true) -> void:
	PlayerData.add_soul(SECRET_SOUL_REWARD)
	if save_progress:
		_save_secret_progress()
	_show_secret_status("已添加1亿灵魂，当前灵魂：%d" % PlayerData.get_soul())


func _equip_one_click_divine_set(save_progress: bool = true) -> bool:
	var role_id := int(PlayerData.player_data.get("Myself", 0))
	var weapon_id := _get_secret_weapon_id(role_id)
	var armor_id := _get_secret_armor_id(role_id)
	if weapon_id.is_empty() or armor_id.is_empty():
		_show_secret_status("当前角色数据异常，无法生成神装")
		return false

	var target_items := {
		"武器": _build_secret_equipment(weapon_id, true),
		"防具": _build_secret_equipment(armor_id, true),
		"饰品": _build_secret_equipment(SECRET_ACCESSORY_ID, true),
		"翅膀": _build_secret_equipment(SECRET_WING_ID, false),
	}
	for slot_name in target_items:
		if (target_items[slot_name] as Dictionary).is_empty():
			_show_secret_status("神装数据缺失，无法生成")
			return false

	var occupied_slot_count := 0
	for slot_name in target_items:
		var equipped: Variant = PlayerData.player_data.get(slot_name, [])
		if equipped is Array and not (equipped as Array).is_empty():
			occupied_slot_count += 1
	if _get_equipment_backpack_free_slots() < occupied_slot_count:
		_show_secret_status("装备背包空间不足，请至少留出%d个空格" % occupied_slot_count)
		return false

	for slot_name in target_items:
		_move_equipped_item_to_backpack(str(slot_name))
		PlayerData.player_data[slot_name] = [(target_items[slot_name] as Dictionary).duplicate(true)]
	PlayerData.zl_zb()
	RoleProp.get_equ_last_pro()
	RoleProp.get_last_prop()
	if is_instance_valid(RoleProp.source_player):
		RoleProp.source_player.on_eqchange()
	if save_progress:
		_save_secret_progress()
	_show_secret_status("已装备五阶满强化神器武器、防具、饰品和满级神器翅膀")
	return true


func _get_secret_weapon_id(role_id: int) -> String:
	return str(SECRET_WEAPON_BY_ROLE.get(role_id, ""))


func _get_secret_armor_id(role_id: int) -> String:
	return str(SECRET_ARMOR_BY_ROLE.get(role_id, ""))


func _build_secret_equipment(item_id: String, divine_forge: bool) -> Dictionary:
	AE.ensure_loaded()
	if not AE.all_equipment.has(item_id):
		return {}
	var data: Dictionary = (AE.all_equipment[item_id] as Dictionary).duplicate(true)
	var gems: Array[String] = []
	for _socket_index in range(SECRET_GEM_SOCKET_COUNT):
		gems.push_back(SECRET_ATTACK_GEM_ID)
	data[DataKeys.GEM] = gems
	if divine_forge:
		data["神铸阶段"] = SECRET_DIVINE_FORGE_STAGE
	return {
		"名字": item_id,
		"强化等级": SECRET_MAX_STRENGTHEN_LEVEL,
		"Data": data,
	}


func _get_equipment_backpack_free_slots() -> int:
	var equipment_pages: Variant = PlayerData.player_data.get(DataKeys.EQUIPMENT_LIST, {})
	if not (equipment_pages is Dictionary):
		return 0
	var free_slots := 0
	for page_value in (equipment_pages as Dictionary).values():
		if page_value is Array:
			free_slots += maxi(0, 25 - (page_value as Array).size())
	return free_slots


func _move_equipped_item_to_backpack(slot_name: String) -> void:
	var equipped: Variant = PlayerData.player_data.get(slot_name, [])
	if not (equipped is Array) or (equipped as Array).is_empty():
		return
	var old_item: Variant = (equipped as Array)[0]
	if old_item is Dictionary:
		PlayerData.add_zb(
			str(old_item.get(DataKeys.NAME, "")), int(old_item.get(DataKeys.ENHANCE_LEVEL, 0)), old_item.get("Data", {})
		)


func _save_secret_progress() -> void:
	if str(Global.cd_path).is_empty():
		MemoryClass.main_bc()
		return
	MemoryClass.save_game(Global.cd_path)


func _show_secret_status(message: String) -> void:
	secret_function_status.text = message


func add_text_info():
	remove_all_text_info()
	bb.text = str(verisions) + "更新详情"
	if verisions_name == "" or verisions_name == null:
		return
	for i in text_data[verisions_name]:
		var item_label = Global.add_font_instance(text_list, i, "res://Font/华康宋体W3.ttc", 17, "FFFFFF", 2, "FFFFFF")
		if item_label is Label:
			item_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			item_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
			item_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			item_label.custom_minimum_size.x = 660.0
			item_label.size.x = 660.0
			item_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


func remove_all_text_info():
	for i in text_list.get_children():
		i.queue_free()


func _on_v_0_1_pressed() -> void:
	verisions_name = "V2_3"
	verisions = "V2.3"
	add_text_info()


func _on_v_0_2_pressed() -> void:
	verisions_name = "V2_2"
	verisions = "V2.2"
	add_text_info()


func _on_close_pressed() -> void:
	queue_free()


func _on_v_0_3_pressed() -> void:
	verisions_name = "V2_1"
	verisions = "V2.1"
	add_text_info()


func _on_v_0_4_pressed() -> void:
	verisions_name = "V2_0"
	verisions = "V2.0"
	add_text_info()


func _on_v_0_5_pressed() -> void:
	verisions_name = "V2_4"
	verisions = "V2.4"
	add_text_info()


func _on_v_0_6_pressed() -> void:
	verisions_name = "V2_5"
	verisions = "V2.5"
	add_text_info()


func _on_v_0_7_pressed() -> void:
	verisions_name = "V2_6"
	verisions = "V2.6"
	add_text_info()


func _on_v_0_8_pressed() -> void:
	verisions_name = "V2_7"
	verisions = "V2.7"
	add_text_info()


func _on_v_0_9_pressed() -> void:
	verisions_name = "V2_8"
	verisions = "V2.8"
	add_text_info()


func _on_v_0_10_pressed() -> void:
	verisions_name = "V2_9"
	verisions = "V2.9"
	add_text_info()


func _on_v_0_11_pressed() -> void:
	verisions_name = "V3_0"
	verisions = "V3.0"
	add_text_info()


func _on_v_0_12_pressed() -> void:
	verisions_name = "V3_1"
	verisions = "V3.1"
	add_text_info()


func _on_v_0_13_pressed() -> void:
	verisions_name = "V3_2"
	verisions = "V3.2"
	add_text_info()


func _on_v_0_14_pressed():
	verisions_name = "V3_3"
	verisions = "V3.3"
	add_text_info()


func _on_v_0_15_pressed():
	verisions_name = "V3_4"
	verisions = "V3.4"
	add_text_info()


func _on_v_0_16_pressed():
	verisions_name = "V3_5"
	verisions = "V3.5"
	add_text_info()


func _on_v_0_17_pressed():
	verisions_name = "V3_6"
	verisions = "V3.6"
	add_text_info()


func _on_v_0_18_pressed():
	verisions_name = "V3_7"
	verisions = "V3.7"
	add_text_info()


func _on_v_0_19_pressed():
	verisions_name = "V3_8"
	verisions = "V3.8"
	add_text_info()


func _on_v_0_20_pressed():
	verisions_name = "V3_9"
	verisions = "V3.9"
	add_text_info()


func _on_v_0_21_pressed():
	verisions_name = "V4_0"
	verisions = "V4.0"
	add_text_info()


func _on_v_0_22_pressed() -> void:
	verisions_name = "V4_1"
	verisions = "V4.1"
	add_text_info()


func _on_v_0_23_pressed() -> void:
	verisions_name = "V4_2"
	verisions = "V4.2"
	add_text_info()


func _on_v_0_24_pressed() -> void:
	verisions_name = "V4_3"
	verisions = "V4.3"
	add_text_info()


func _on_v_0_25_pressed() -> void:
	verisions_name = "V4_4"
	verisions = "V4.4"
	add_text_info()


func _on_v_0_26_pressed() -> void:
	verisions_name = "V4_5"
	verisions = "V4.5"
	add_text_info()


func _on_v_0_27_pressed() -> void:
	verisions_name = "V4_6"
	verisions = "V4.6"
	add_text_info()


func _on_v_0_28_pressed() -> void:
	verisions_name = "V4_7"
	verisions = "V4.7"
	add_text_info()


func _on_v_0_29_pressed() -> void:
	verisions_name = "V4_8"
	verisions = "V4.8"
	add_text_info()


func _on_v_0_30_pressed() -> void:
	verisions_name = "V4_9"
	verisions = "V4.9"
	add_text_info()


func _on_v_0_31_pressed() -> void:
	verisions_name = "V5_0"
	verisions = "V5.0"
	add_text_info()


func _on_v_0_32_pressed() -> void:
	verisions_name = "V5_1"
	verisions = "V5.1"
	add_text_info()


func _on_v_0_33_pressed() -> void:
	verisions_name = "V5_2"
	verisions = "V5.2"
	add_text_info()


func _on_v_0_34_pressed() -> void:
	verisions_name = "V5_3"
	verisions = "V5.3"
	add_text_info()


func _on_v_0_35_pressed() -> void:
	verisions_name = "V5_4"
	verisions = "V5.4"
	add_text_info()


func _on_v_0_36_pressed() -> void:
	verisions_name = "V5_5"
	verisions = "V5.5"
	add_text_info()


func _on_v_0_37_pressed() -> void:
	verisions_name = "V5_6"
	verisions = "V5.6"
	add_text_info()


func _on_v_0_38_pressed() -> void:
	verisions_name = "V5_7"
	verisions = "V5.7"
	add_text_info()


func _on_v_0_39_pressed() -> void:
	verisions_name = "V5_8"
	verisions = "V5.8"
	add_text_info()


func _on_v_0_40_pressed() -> void:
	verisions_name = "V5_9"
	verisions = "V5.9"
	add_text_info()


func _on_v_0_41_pressed() -> void:
	verisions_name = "V6_0"
	verisions = "V6.0"
	add_text_info()


func _on_v_0_42_pressed() -> void:
	verisions_name = "V6_1"
	verisions = "V6.1"
	add_text_info()


func _on_v_0_43_pressed() -> void:
	verisions_name = "V6_2"
	verisions = "V6.2"
	add_text_info()


func _on_v_0_44_pressed() -> void:
	verisions_name = "V6_3"
	verisions = "V6.3"
	add_text_info()


func _on_v_0_45_pressed() -> void:
	verisions_name = "V6_4"
	verisions = "V6.4"
	add_text_info()


func _on_v_0_46_pressed() -> void:
	verisions_name = "V6_5"
	verisions = "V6.5"
	add_text_info()


func _on_v_0_47_pressed() -> void:
	verisions_name = "V6_6"
	verisions = "V6.6"
	add_text_info()


func _on_v_0_48_pressed() -> void:
	verisions_name = "V6_7"
	verisions = "V6.7"
	add_text_info()


func _on_v_0_49_pressed() -> void:
	verisions_name = "V6_8"
	verisions = "V6.8"
	add_text_info()


func _on_v_0_50_pressed() -> void:
	verisions_name = "V6_9"
	verisions = "V6.9"
	add_text_info()
