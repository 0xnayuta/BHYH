extends MarginContainer

## 显式操作者：按所在面板的槽位解析数据与属性，不依赖全局 1P/2P 视图交换。
var PlayerData: PlayerDataStore:
	get:
		return LocalCoop.data_for(self) as PlayerDataStore
var RoleProp: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self) as BaseRoleProperties

const SKILL_AWAKEN_NORMAL = preload("res://Art/skill/awaken/skill_awaken_normal.png")
const SKILL_AWAKEN_HOVER = preload("res://Art/skill/awaken/skill_awaken_hover.png")
const SKILL_AWAKEN_PRESSED = preload("res://Art/skill/awaken/skill_awaken_pressed.png")
const SKILL_AWAKEN_POPUP = preload("res://Scene/skill/skill_awaken_popup.tscn")

@onready var skill_11_label = $ScrollContainer/HBoxContainer/Sk_na/skill_11
@onready var ski_11_btn = $ScrollContainer/HBoxContainer/sk_pi/ski_11
@onready var skill_11_upbtn = $ScrollContainer/HBoxContainer/sk_lv/Skill_11
@onready var sk_11_level = $ScrollContainer/HBoxContainer/sk_le/sk_11
@onready var s_11_desc = $ScrollContainer/HBoxContainer/sk_ms/s_11

@onready var skill5_button: Button = $ScrollContainer/HBoxContainer/Sk_na/skill_5
@onready var hmz_version_menu: PopupMenu = $ScrollContainer/HBoxContainer/Sk_na/skill_5/hmz_version_menu

@onready var skill_1_le = $ScrollContainer/HBoxContainer/sk_le/sk_1
@onready var skill_2_le = $ScrollContainer/HBoxContainer/sk_le/sk_2
@onready var skill_3_le = $ScrollContainer/HBoxContainer/sk_le/sk_3
@onready var skill_4_le = $ScrollContainer/HBoxContainer/sk_le/sk_4
@onready var skill_5_le = $ScrollContainer/HBoxContainer/sk_le/sk_5

const MAX_SKILL_LEVEL := 30
const PASSIVE_SKILL_MAX_LEVEL := 10
const SKILL_BOOK_START_LEVEL := 10
const SKILL_BOOK_SECOND_START_LEVEL := 20
const SKILL_BOOK_ID := "1_jns"
const SKILL_BOOK_NAME := "一阶技能书"
const SKILL_BOOK_SECOND_ID := "2_jns"
const SKILL_BOOK_SECOND_NAME := "二阶技能书"
const PASSIVE_SKILLS := ["sx", "sjt", "rj", "mds", "yyb", YutuSkillData.PASSIVE_KEY]
var target_skill: int
var skill_info
var _skill_row_heights: Array[float] = []

var skill_variant_config = {}

var current_variant = {}

var skill_ids_by_role: Dictionary = {
	"角色1": ["slz", "hytj", "lys", "lyfb", "hmz", "hmz_ws", "zz", "qsez", "jdy", "hyjj", "sx", "gsrs", "hyjj_ws"],
	"角色2": ["blb", "xbz", "shy", "tjgl", "smb", "sgq", "myhc", "jgz", "jhsj", "sjt", "by", "zfjg"],
	"角色3": ["ssp", "dj", "dgq", "zznh", "tmc", "sd", "jsp", "xgq", "syzq", "rj", "bdqk"],
	"角色4": ["qlj", "dcj", "wdzt", "tkj", "mmw", "jdz", "lhsq", "zq", "wdww", "mds", "bylt", "cmly"],
	"角色5": ["xyq", "slq", "blq", "fhf", "cxq", "llrd", "lljy", "ygth", "tllz", "yyb", "ltjz"],
	"角色6": ["nz_jlsh", "nz_fhcc", "nz_hlqg", "nz_hlhs", "nz_lblc"]
}

var skill_name = {
	"角色1": ["升龙斩", "火炎突击", "烈焰闪", "烈焰风暴", "火魔斩", "火魔斩无双", "重斩", "七十二斩", "筋斗云", "火眼金睛", "嗜血", "棍式如山", "无双火眼金睛"],
	"角色2": ["冰龙波", "玄冰阵", "水幻影", "天降甘露", "水魔爆", "饥寒冰魂", "沐浴回春", "紧箍咒", "九环圣经", "水精通", "冰雨", "正法金刚"],
	"角色3": ["碎石破", "盾击", "地滚球", "战争怒吼", "土魔刺", "圣盾", "巨石破", "旋滚球", "圣域之墙", "刃甲", "拔地乾坤"],
	"角色4": ["强力击", "多重击", "万毒加护", "腾空击", "木魔舞", "剧毒阵", "灵魂摄取", "瘴气", "巫毒娃娃", "猛毒素", "碧落天", "苍木龙陨"],
	"角色5": ["心眼枪", "升龙枪", "奔雷枪", "翔龙闪", "穿心枪", "雷龙入地", "雷龙极影", "银钩铁画", "天龙雷阵", "阴阳双生", "雷霆劫阵"],
	"角色6": ["九龙神火", "风火冲刺", "火轮切割", "火莲化身", "六臂连刺"]
}

var skill_infor = {
	"角色1":
	[
		"奋力一击，将敌人击飞至空中，造成魔法伤害。",
		"短距离突刺，将敌人击退，并造成多段魔法伤害。",
		"以无法捕捉的速度快速冲刺，进入无法被命中状态并且造成多段伤害。",
		"快速旋转，震开或吸引周边敌人，造成多段魔法伤害",
		"冲向空中造成多段物理伤害，之后砸向地面造成魔法伤害，期间处于无法被命中状态。",
		"火魔斩无双：冲向空中造成多段物理伤害，之后砸向地面造成魔法伤害，期间处于无法被命中状态。",
		"蓄力后用力砸向地面造成伤害并且击退敌人。",
		"向前短距离冲刺，触碰到敌人后进行多次打击，概率打出残影，残影可以模仿角色部分技能（残影数量上限和伤害继承百分比取决于本技能等级）。",
		"腾云驾雾，快速冲，按W可以向上飞行。",
		"眼睛变红，之后在当前面朝方向优先出现的敌人身上召唤六丁神火，造成多次伤害（目标死亡时立即消失）。",
		"孙悟空被动获得一定的暴击和吸血效果。",
		"棍式如山！！",
		"无双火眼金睛：向面朝方向释放贯穿光束，对同一排所有敌人持续造成多段魔法伤害。"
	],
	"角色2":
	[
		"短暂延迟后释放一道冰龙冲击，造成击退效果。",
		"短暂引导后在前方召唤玄冰刺，（三段，每段都比上一段体积增大一部分），并击退敌人。",
		"释放一个幻影向前方移动，再次使用可以瞬移至幻影位置，幻影可以继承角色某些技能。",
		"短暂引导后恢复自身一定量生命（与角色生命上限有关，根据已损失生命治疗效果至多额外提升60%）",
		"召唤法阵向前移动，再次释放召唤光柱砸向地面，造成巨额伤害。",
		"召唤一个法球向前移动，移动过程中不断射出冰刺，对敌人造成魔法伤害和击退（击退方向可以通过玩家方向来控制）。",
		"为自身添加一个回血效果，每过一段时间恢复一定量的生命（与角色生命上限有关）。",
		"向前方召唤紧箍咒，将一定范围内的某些怪物聚集在中央，并且在一定时间内提高攻击的伤害，以及提高触发水精通概率。",
		"唐僧默念圣经，在自身周围召唤佛光，对附近的敌人造成伤害。",
		"学习后，玄冰阵和水魔爆获得概率冰冻效果，升级提高冰冻时长和冰冻概率。",
		"冰雨：召唤覆盖全屏的冰雨，雨滴依次落下造成范围魔法伤害，每次命中有25%概率冰冻敌人。",
		"召唤正法金刚协助战斗，金刚属性随角色攻击力与最大魔法值成长。",
	],
	"角色3":
	[
		"八戒用钉耙猛砸地面，从地面刺出多段突刺，对敌人造成伤害。",
		"幻化出盾牌，之后蓄力一击，造成显著的击退效果（可搭配刃甲的眩晕）",
		"自身化作土球向前翻滚；觉醒时翻滚速度加快并处于无法被命中状态，过程中从地滚球当前位置连续释放土魔刺尖刺，围绕自身旋转向周围造成伤害",
		"发出怒吼，吸引场上所有怪物至自身附近，并提高对其下一次的伤害。觉醒后，被吸取的敌人额外降低50%物理防御和魔法防御。",
		"八戒化身为一个尖刺魔球，处于魔球期间物理和魔法防御提高50%，受到攻击会以魔法伤害反弹给敌人，再次使用该技能会释放追踪尖刺，造成伤害。",
		"昂扬斗志，召唤圣盾加护，自身不会被击退，且每秒回复一定量的生命，持续一段时间。觉醒后可自动开启并切换关闭，期间受到的控制效果持续时间减半。",
		"在身旁召唤爆裂巨石，造成多段伤害（配合刃甲概率将敌人震晕一段时间）",
		"自身化作土球在附近区域旋转打击，造成多段物理伤害。",
		"召唤一个不断向前移动的墙壁，触碰到敌人后击退对方（可以搭配刃甲的眩晕，场上最多同时存在一堵圣域之墙）",
		"八戒获得刃甲加护，受到攻击有概率无视伤害并回复一定生命值，令部分技能获得眩晕效果，（回复概率，数值，眩晕概率，时间与该技能等级有关）",
		"挥出开天重击，前方爆发乾坤震波与烟尘火星，对范围内敌人造成多段物理伤害。",
	],
	"角色4":
	[
		"强力打飞前方怪物。",
		"对前方怪物造成多次打击",
		"获得毒雾加护，最终伤害减少，免疫部分击退，被攻击时，给攻击者施加一层”巫毒“，并小概率回复减伤部分的生命。",
		"冲向空中造成伤害。",
		"释放回旋镖在附近不停的移动，造成魔法伤害。",
		"原地释放一个毒阵，怪物进入毒阵会受到伤害，并被减速。",
		"伸出魔爪对前方怪物造成伤害，命中后恢复自身生命,根据已损失生命治疗效率至多提升30%。",
		"向前方释放瘴气",
		"释放一个傀儡娃娃向目标(当前生命最高单位)移动，打击娃娃目标也会受到伤害，升级提升传递比率及娃娃生命。",
		"令部分技能附带”巫毒“效果(每秒扣除生命)，叠加至7层时，将会引爆，造成巨额伤害。",
		"在角色身后召唤碧落法阵，并在前方连续引爆能量，对范围内敌人造成6段魔法伤害。",
		"召唤木龙攻击范围内敌人。"
	],
	"角色5":
	[
		"举起长枪不断挥舞，造成伤害，之后奋力一击击退目标。（期间无视击退）",
		"高高跃起并将目标击飞至空中。",
		"向前方冲刺，并击退敌人。（期间无视击退）。",
		"向前方瞬移一小段距离（期间不会被命中）。",
		"向前方快速刺击，期间可以左右移动，最后将敌人击退。（期间无视击退）",
		"高高跃起，然后向地面掷出雷枪引发天雷，造成伤害并将目标吸引至中心位置，令5秒内受伤提高30%。",
		"极速向前冲刺，对触碰到的所有敌人点穴（1.2s僵直），然后残影跟随，造成多段伤害，冲刺期间不会被击中。",
		"快速挥舞长枪，造成多次打击，最后一击召唤巨型银钩",
		"向前跃向空中，砸向地面，落地召唤雷阵不断造成伤害，进入雷阵的目标会被减速，持续10s（同时只能存在一个雷阵）。觉醒后，命中敌人降低50%物理防御和魔法防御，并在目标位置额外释放一个雷阵。",
		"白龙的部分攻击概率触发天雷（伤害和恢复生命取决于引发天雷攻击的伤害和本技能等级）。",
		"在头顶展开雷法阵，随后向前方引落连续雷电，对范围内敌人造成多段魔法伤害。觉醒后，会在距离最远的目标位置额外释放一个雷霆劫阵。"
	],
	"角色6":
	[
		"召唤九龙神火连续灼烧前方敌人；在空中使用时会下落并在落地时追加神火。",
		"驾驭风火轮向前冲刺，对沿途敌人造成三段物理伤害。",
		"先以火轮切割近身敌人，再召唤火轮环绕自身五秒持续攻击。",
		"开启火莲持续消耗魔法充能；生命低于九成时自动消耗能量恢复生命。",
		"以六臂连续突刺，最后砸地造成高额物理伤害。"
	]
}


func get_role_key() -> String:
	var role_id := int(PlayerData.player_data.get("Myself", 1))
	if role_id < 1 or role_id > 7:
		role_id = 1
	return "角色" + str(int(role_id))


func _ensure_nezha_yinyang_skill() -> void:
	var role_key := get_role_key()
	if not role_key.ends_with("6"):
		return
	var current_skills: Array = skill_ids_by_role[role_key]
	if "nz_yysj" in current_skills:
		return
	current_skills.append("nz_yysj")
	skill_name[role_key].append("阴阳神剑")
	skill_infor[role_key].append("开启后每隔0.27秒消耗魔法，向前方发射1把阴剑和1把阳剑。再次释放可关闭。")


func ensure_extra_skill_slots():
	var role_key := get_role_key()
	if role_key != "角色1" and role_key != "角色2" and role_key != "角色4":
		return
	var list_body = get_node_or_null("ScrollContainer/HBoxContainer")
	if list_body:
		var required_height := 1015.0 if role_key == "角色1" else 940.0
		list_body.custom_minimum_size = Vector2(
			max(list_body.custom_minimum_size.x, 760.0), max(list_body.custom_minimum_size.y, required_height)
		)
	_ensure_extra_node("ScrollContainer/HBoxContainer/Sk_na", "skill_11", "skill_12", 74.0)
	_ensure_extra_node("ScrollContainer/HBoxContainer/sk_pi", "ski_11", "ski_12", 74.0)
	_ensure_extra_node("ScrollContainer/HBoxContainer/sk_lv", "Skill_11", "Skill_12", 75.0)
	_ensure_extra_node("ScrollContainer/HBoxContainer/sk_le", "sk_11", "sk_12", 75.0)
	_ensure_extra_node("ScrollContainer/HBoxContainer/sk_ms", "s_11", "s_12", 76.0)
	if role_key == "角色1":
		_ensure_extra_node("ScrollContainer/HBoxContainer/Sk_na", "skill_12", "skill_13", 74.0)
		_ensure_extra_node("ScrollContainer/HBoxContainer/sk_pi", "ski_12", "ski_13", 74.0)
		_ensure_extra_node("ScrollContainer/HBoxContainer/sk_lv", "Skill_12", "Skill_13", 75.0)
		_ensure_extra_node("ScrollContainer/HBoxContainer/sk_le", "sk_12", "sk_13", 75.0)
		_ensure_extra_node("ScrollContainer/HBoxContainer/sk_ms", "s_12", "s_13", 76.0)
		_normalize_skill_rows(13)
	else:
		_normalize_skill_rows(12)


func _center_upgrade_controls(row_count: int) -> void:
	for i in range(1, row_count + 1):
		var upgrade_button = get_node_or_null("ScrollContainer/HBoxContainer/sk_lv/Skill_" + str(i))
		if upgrade_button == null:
			continue
		upgrade_button.offset_left = 296.0
		upgrade_button.offset_right = 339.0
		var need_label = upgrade_button.get_node_or_null("Need")
		if need_label != null:
			need_label.offset_left = -35.0
			need_label.offset_right = 77.0


func _resize_skill_columns(row_count: int) -> void:
	var upgrade_title = get_node_or_null("ScrollContainer/HBoxContainer/sk_lv/skill_uplevel")
	if upgrade_title != null:
		upgrade_title.offset_left = 246.0
		upgrade_title.offset_right = 394.0
		upgrade_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var level_title = get_node_or_null("ScrollContainer/HBoxContainer/sk_le/skill_level")
	if level_title != null:
		level_title.clip_text = true
		level_title.offset_left = 388.0
		level_title.offset_right = 494.0
		level_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	for i in range(1, row_count + 1):
		var level_label = get_node_or_null("ScrollContainer/HBoxContainer/sk_le/sk_" + str(i))
		if level_label != null:
			level_label.offset_left = 388.0
			level_label.offset_right = 494.0


func _ensure_extra_node(parent_path: String, source_name: String, new_name: String, y_offset: float):
	var parent = get_node_or_null(parent_path)
	if parent == null or parent.get_node_or_null(new_name) != null:
		return
	var source = parent.get_node_or_null(source_name)
	if source == null:
		return
	var extra = source.duplicate()
	extra.name = new_name
	if "text" in extra:
		extra.text = ""
	extra.position.y += y_offset
	extra.offset_top += y_offset
	extra.offset_bottom += y_offset
	parent.add_child(extra)
	if parent_path.ends_with("sk_lv"):
		var need = extra.get_node_or_null("Need")
		if need and "text" in need:
			need.text = ""


func _set_row_offsets(node, top: float, bottom: float):
	if node == null:
		return
	node.offset_top = top
	node.offset_bottom = bottom


func _normalize_skill_rows(row_count: int):
	for i in range(1, row_count + 1):
		var idx = i - 1
		_set_row_offsets(
			get_node_or_null("ScrollContainer/HBoxContainer/Sk_na/skill_" + str(i)),
			65.0 + 74.0 * idx,
			95.0 + 74.0 * idx
		)
		_set_row_offsets(
			get_node_or_null("ScrollContainer/HBoxContainer/sk_pi/ski_" + str(i)), 44.0 + 74.0 * idx, 110.0 + 74.0 * idx
		)
		_set_row_offsets(
			get_node_or_null("ScrollContainer/HBoxContainer/sk_lv/Skill_" + str(i)),
			65.0 + 74.0 * idx,
			88.0 + 74.0 * idx
		)
		_set_row_offsets(
			get_node_or_null("ScrollContainer/HBoxContainer/sk_le/sk_" + str(i)), 55.0 + 75.0 * idx, 93.0 + 75.0 * idx
		)
		_set_row_offsets(
			get_node_or_null("ScrollContainer/HBoxContainer/sk_ms/s_" + str(i)), 32.0 + 74.0 * idx, 123.0 + 74.0 * idx
		)


func get_level_storage_index(index: int) -> int:
	var role_skills: Array = skill_ids_by_role.get(get_role_key(), [])
	if get_role_key() == "角色3" and index >= 0 and index < role_skills.size() and role_skills[index] == "bdqk":
		return 12
	if index >= 0 and index < role_skills.size() and role_skills[index] == "hmz_ws":
		return 12
	if index >= 0 and index < role_skills.size() and role_skills[index] == "hyjj_ws":
		return 13
	var hmz_ws_idx: int = role_skills.find("hmz_ws")
	if get_role_key() == "角色1" and hmz_ws_idx != -1 and index > hmz_ws_idx:
		return index
	return index + 1


func get_skill_level_by_index(index: int) -> int:
	var storage_index = get_level_storage_index(index)
	return PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能" + str(storage_index)][DataKeys.LEVEL]


func get_skill_max_level(skill_internal: String) -> int:
	return MAX_SKILL_LEVEL if _uses_standard_upgrades(skill_internal) else PASSIVE_SKILL_MAX_LEVEL


func _uses_standard_upgrades(skill_internal: String) -> bool:
	return skill_internal not in PASSIVE_SKILLS or skill_internal == YutuSkillData.PASSIVE_KEY


func get_skill_book_need(level: int) -> int:
	if level < SKILL_BOOK_START_LEVEL or level >= MAX_SKILL_LEVEL:
		return 0
	if level >= SKILL_BOOK_SECOND_START_LEVEL:
		return level - (SKILL_BOOK_SECOND_START_LEVEL - 1)
	return level - 9


func get_skill_book_id(level: int) -> String:
	return SKILL_BOOK_SECOND_ID if level >= SKILL_BOOK_SECOND_START_LEVEL else SKILL_BOOK_ID


func get_skill_book_name(level: int) -> String:
	return SKILL_BOOK_SECOND_NAME if level >= SKILL_BOOK_SECOND_START_LEVEL else SKILL_BOOK_NAME


func _consume_skill_book(level: int) -> bool:
	var book_need := get_skill_book_need(level)
	var book_id := get_skill_book_id(level)
	if book_need <= 0 or int(PlayerData.get_item_data(book_id)) < book_need:
		return false
	var book_page := int(PlayerData.get_dj_page(book_id))
	if book_page == 0:
		return false
	PlayerData.remove_dj(book_id, book_page, book_need)
	return true


func _ready() -> void:
	skill_ids_by_role["角色7"] = YutuSkillData.KEYS.duplicate()
	skill_ids_by_role["角色7"].append(YutuSkillData.PASSIVE_KEY)
	skill_name["角色7"] = YutuSkillData.NAMES.duplicate()
	skill_name["角色7"].append(YutuSkillData.PASSIVE_NAME)
	skill_infor["角色7"] = YutuSkillData.descriptions()
	skill_infor["角色7"].append(YutuSkillData.PASSIVE_DESCRIPTION)
	_ensure_nezha_yinyang_skill()
	ensure_extra_skill_slots()
	var role_key = get_role_key()
	if (
		role_key != "角色1"
		and role_key != "角色2"
		and role_key != "角色3"
		and role_key != "角色4"
		and role_key != "角色5"
		and role_key != "角色7"
	):
		skill_11_label.visible = false
		ski_11_btn.visible = false
		skill_11_upbtn.visible = false
		sk_11_level.visible = false
		s_11_desc.visible = false
	else:
		skill_11_label.visible = true
		ski_11_btn.visible = true
		skill_11_upbtn.visible = true
		sk_11_level.visible = true
		s_11_desc.visible = true

	_set_skill_slot_visibility(skill_ids_by_role.get(role_key, []).size())
	var max_slot = skill_ids_by_role.get(get_role_key(), []).size()
	for i in range(1, max_slot + 1):
		var ski_btn = get_node_or_null("ScrollContainer/HBoxContainer/sk_pi/ski_" + str(i))
		if ski_btn and ski_btn is Button:
			var ski_fn = "_on_ski_" + str(i) + "_pressed"
			var ski_cb = Callable(self, ski_fn)
			if not ski_btn.pressed.is_connected(ski_cb):
				ski_btn.pressed.connect(ski_cb)
			var me_fn = "_on_ski_" + str(i) + "_mouse_entered"
			var me_cb = Callable(self, me_fn)
			if not ski_btn.mouse_entered.is_connected(me_cb):
				ski_btn.mouse_entered.connect(me_cb)
			var mx_fn = "_on_ski_" + str(i) + "_mouse_exited"
			var mx_cb = Callable(self, mx_fn)
			if not ski_btn.mouse_exited.is_connected(mx_cb):
				ski_btn.mouse_exited.connect(mx_cb)
		var up_btn = get_node_or_null("ScrollContainer/HBoxContainer/sk_lv/Skill_" + str(i))
		if up_btn and up_btn is Button:
			var up_fn = "_on_skill_" + str(i) + "_pressed"
			var up_cb = Callable(self, up_fn)
			if not up_btn.pressed.is_connected(up_cb):
				up_btn.pressed.connect(up_cb)

	set_skill_icon()
	set_skill_mp_cost()
	set_skill_name()
	set_skill_level()
	set_skill_infor()
	set_skill_lh()
	var skill_count = skill_ids_by_role.get(role_key, []).size()
	_resize_skill_columns(skill_count)
	_center_upgrade_controls(skill_count)

	init_skill_variants()
	_setup_skill_awaken_buttons()
	call_deferred("_fit_skill_descriptions_to_grid")


func _set_skill_slot_visibility(skill_count: int) -> void:
	for index in range(1, 14):
		var should_show := index <= skill_count
		for node_path in [
			"ScrollContainer/HBoxContainer/Sk_na/skill_" + str(index),
			"ScrollContainer/HBoxContainer/sk_pi/ski_" + str(index),
			"ScrollContainer/HBoxContainer/sk_lv/Skill_" + str(index),
			"ScrollContainer/HBoxContainer/sk_le/sk_" + str(index),
			"ScrollContainer/HBoxContainer/sk_ms/s_" + str(index),
		]:
			var slot_node := get_node_or_null(node_path)
			if slot_node != null:
				slot_node.visible = should_show


func _fit_skill_descriptions_to_grid() -> void:
	var skill_count = skill_ids_by_role.get(get_role_key(), []).size()
	_skill_row_heights.clear()
	var row_top := 40.0
	for i in range(1, skill_count + 1):
		var description := get_node_or_null("ScrollContainer/HBoxContainer/sk_ms/s_" + str(i)) as Label
		if description == null:
			continue
		var row_height := maxf(96.0, ceilf(description.get_minimum_size().y) + 16.0)
		_skill_row_heights.append(row_height)
		var row_center := row_top + row_height / 2.0
		_set_row_offsets(description, row_top + 8.0, row_top + row_height - 8.0)
		_set_row_offsets(
			get_node_or_null("ScrollContainer/HBoxContainer/Sk_na/skill_" + str(i)),
			row_center - 15.0,
			row_center + 15.0
		)

		var icon_top := row_top + (row_height - 81.0) / 2.0
		_set_row_offsets(
			get_node_or_null("ScrollContainer/HBoxContainer/sk_pi/ski_" + str(i)), icon_top, icon_top + 66.0
		)
		_set_row_offsets(
			get_node_or_null("ScrollContainer/HBoxContainer/sk_lv/Skill_" + str(i)), row_center - 24.0, row_center - 1.0
		)
		_set_row_offsets(
			get_node_or_null("ScrollContainer/HBoxContainer/sk_le/sk_" + str(i)), row_center - 19.0, row_center + 19.0
		)
		row_top += row_height
	var list_body := $ScrollContainer/HBoxContainer as HBoxContainer
	list_body.custom_minimum_size.y = row_top
	$ScrollContainer/HBoxContainer/SkillGridBackdrop.queue_redraw()


func get_skill_row_heights() -> Array[float]:
	return _skill_row_heights


func _setup_skill_awaken_buttons() -> void:
	var skill_list = skill_ids_by_role.get(get_role_key(), [])
	for skill_index in range(skill_list.size()):
		if get_role_key() == "角色7" and skill_list[skill_index] not in ["yt_mds", "yt_xdz", "yt_ldmw", "yt_yl"]:
			continue
		var icon_parent = get_node_or_null("ScrollContainer/HBoxContainer/sk_pi/ski_" + str(skill_index + 1))
		if icon_parent == null:
			continue

		var existing_button = icon_parent.get_node_or_null("AwakenButton")
		if existing_button != null:
			continue

		var awaken_button := TextureButton.new()
		awaken_button.name = "AwakenButton"
		awaken_button.texture_normal = SKILL_AWAKEN_NORMAL
		awaken_button.texture_hover = SKILL_AWAKEN_HOVER
		awaken_button.texture_pressed = SKILL_AWAKEN_PRESSED
		awaken_button.ignore_texture_size = true
		awaken_button.custom_minimum_size = Vector2(46, 45)
		awaken_button.anchor_left = 1.0
		awaken_button.anchor_top = 1.0
		awaken_button.anchor_right = 1.0
		awaken_button.anchor_bottom = 1.0

		awaken_button.offset_left = -46.0 * 2.0 / 3.0
		awaken_button.offset_top = -45.0 * 2.0 / 3.0
		awaken_button.offset_right = 46.0 / 3.0
		awaken_button.offset_bottom = 45.0 / 3.0
		awaken_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		awaken_button.focus_mode = Control.FOCUS_NONE
		awaken_button.z_index = 10
		awaken_button.tooltip_text = DataKeys.Skill.AWAKENED
		awaken_button.pressed.connect(_on_skill_awaken_pressed.bind(skill_index))
		icon_parent.add_child(awaken_button)


func _on_skill_awaken_pressed(skill_index: int) -> void:
	var window_root := _get_skill_window_root()
	var existing_popup := window_root.get_node_or_null("SkillAwakenPopup")
	if existing_popup != null:
		return

	var icon_button = get_node_or_null("ScrollContainer/HBoxContainer/sk_pi/ski_" + str(skill_index + 1))
	var name_label = get_node_or_null("ScrollContainer/HBoxContainer/Sk_na/skill_" + str(skill_index + 1))
	var skill_list = skill_ids_by_role.get(get_role_key(), [])
	var display_name := "技能"
	var display_icon: Texture2D = null
	if name_label != null:
		display_name = str(name_label.text)
	elif skill_index >= 0 and skill_index < skill_name.get(get_role_key(), []).size():
		display_name = str(skill_name[get_role_key()][skill_index])
	if icon_button != null:
		display_icon = icon_button.icon
	if display_icon == null and skill_index >= 0 and skill_index < skill_list.size():
		var icon_path := "res://Art/skill/skill_icon/" + str(skill_list[skill_index]) + ".png"
		if ResourceLoader.exists(icon_path):
			display_icon = load(icon_path)

	var popup = SKILL_AWAKEN_POPUP.instantiate()
	window_root.add_child(popup)
	var internal_skill_id := (
		str(skill_list[skill_index]) if skill_index >= 0 and skill_index < skill_list.size() else ""
	)
	popup.configure(display_name, display_icon, internal_skill_id)


func _get_skill_window_root() -> Node:
	var target: Node = self
	while target.get_parent() != null:
		if target.name == "Learn_Skill":
			return target
		target = target.get_parent()
	return get_tree().current_scene


func init_skill_variants():
	var role_key = get_role_key()

	var skill_list = skill_ids_by_role.get(role_key, [])
	for idx in range(skill_list.size()):
		var skill_internal = skill_list[idx]
		if skill_variant_config.has(skill_internal):
			var config = skill_variant_config[skill_internal]
			var data_key = config["data_key"]

			var variant_id = PlayerData.player_data.get(data_key, config["default"])
			current_variant[skill_internal] = variant_id

			update_skill_name_and_icon(idx + 1, skill_internal, variant_id)


func update_skill_name_and_icon(skill_num: int, skill_internal: String, variant_id: int):
	var config = skill_variant_config.get(skill_internal)
	if not config:
		return
	var variants = config["variants"]
	var variant = null
	for v in variants:
		if v["id"] == variant_id:
			variant = v
			break
	if not variant:
		return

	var name_node_path = "ScrollContainer/HBoxContainer/Sk_na/skill_" + str(skill_num)
	var name_node = get_node(name_node_path)
	if name_node:
		name_node.text = variant["display"]

	var icon_node_path = "ScrollContainer/HBoxContainer/sk_pi/ski_" + str(skill_num)
	var icon_node = get_node(icon_node_path)
	if icon_node and icon_node is Button:
		var icon_suffix = variant["icon_suffix"]
		var icon_name = skill_internal + icon_suffix
		var icon_path = "res://Art/skill/skill_icon/" + icon_name + ".png"
		if ResourceLoader.exists(icon_path):
			icon_node.set_button_icon(load(icon_path))
		else:
			var fallback_path = "res://Art/skill/skill_icon/" + skill_internal + ".png"
			icon_node.set_button_icon(load(fallback_path))


func setup_variant_menu(skill_num: int, skill_internal: String, config: Dictionary):
	if skill_num != 5:
		return

	hmz_version_menu.clear()
	var variants = config["variants"]
	for v in variants:
		hmz_version_menu.add_item(v["display"], v["id"])

	if not skill5_button.pressed.is_connected(_on_skill5_button_pressed):
		skill5_button.pressed.connect(_on_skill5_button_pressed)
	if not hmz_version_menu.id_pressed.is_connected(_on_hmz_version_selected):
		hmz_version_menu.id_pressed.connect(_on_hmz_version_selected)

	hmz_version_menu.set_meta("skill_internal", skill_internal)


func get_skill_name(Num):
	var role_key = get_role_key()
	var skill_list = skill_ids_by_role[role_key]
	if Num - 1 >= skill_list.size():
		return ""
	var skill_internal = skill_list[Num - 1]

	return skill_name[role_key][Num - 1]


func get_need_mp():
	var skill_name = get_skill_list_name(target_skill - 1)
	var old = _compute_mp_cost(skill_name, false)
	var new = _compute_mp_cost(skill_name, true)
	return [old, new]


func set_skill_icon():
	var role_key = get_role_key()
	var skill_list = skill_ids_by_role[role_key]
	for i in range(skill_list.size()):
		var target = get_node("ScrollContainer/HBoxContainer/sk_pi/ski_" + str(i + 1))
		var skill_nbname = skill_list[i]
		if skill_nbname == "hmz_ws":
			skill_nbname = "hmz_ws"
		target.set_button_icon(load("res://Art/skill/skill_icon/" + str(skill_nbname) + ".png"))


func set_skill_name():
	var role_key = get_role_key()
	var skill_name_list = skill_name[role_key]
	for i in range(skill_name_list.size()):
		var target = get_node("ScrollContainer/HBoxContainer/Sk_na/skill_" + str(i + 1))
		target.text = skill_name_list[i]


func set_skill_level():
	var role_key = get_role_key()
	var skill_list = skill_ids_by_role[role_key]
	for i in range(skill_list.size()):
		var target = get_node("ScrollContainer/HBoxContainer/sk_le/sk_" + str(i + 1))
		var skill_level = get_skill_level_by_index(i)
		target.text = "Lv:" + str(skill_level)


func set_skill_infor():
	var role_key = get_role_key()
	var skill_infor_list = skill_infor[role_key]
	for i in range(skill_infor_list.size()):
		var target = get_node("ScrollContainer/HBoxContainer/sk_ms/s_" + str(i + 1))
		target.text = skill_infor_list[i]


func set_skill_lh():
	var role_key = get_role_key()
	var skill_list = skill_ids_by_role[role_key]
	for i in range(skill_list.size()):
		var target = get_node_or_null("ScrollContainer/HBoxContainer/sk_lv/Skill_" + str(i + 1) + "/Need")
		if target == null:
			continue
		var skill_level = get_skill_level_by_index(i)

		if skill_level >= get_skill_max_level(str(skill_list[i])):
			target.text = "已满级"
		elif skill_list[i] not in PASSIVE_SKILLS and skill_level >= SKILL_BOOK_START_LEVEL:
			target.text = "需：" + get_skill_book_name(skill_level) + "x" + str(get_skill_book_need(skill_level))
		elif skill_list[i] in PASSIVE_SKILLS:
			var need = 500 + 500 * skill_level
			target.text = "需：" + str(need) + "灵魂"

		else:
			var need = 100 + (i * 300) + 500 * skill_level
			target.text = "需：" + str(need) + "灵魂"


func up_level():
	if target_skill <= 0:
		Global.add_message_show(self, "技能信息获取失败，无法升级！！", 1.5, Vector2(395, 180))
		return

	var role_key = get_role_key()
	var skill_list = skill_ids_by_role[role_key]
	var max_skill = skill_list.size()

	if (
		target_skill == 11
		&& role_key != "角色1"
		&& role_key != "角色2"
		&& role_key != "角色3"
		&& role_key != "角色4"
		and role_key != "角色5"
	):
		Global.add_message_show(self, "该角色无此技能！！", 1.5, Vector2(395, 180))
		return
	if target_skill > max_skill:
		Global.add_message_show(self, "技能不存在！！", 1.5, Vector2(395, 180))
		return

	var target_internal: String = str(skill_list[target_skill - 1])
	var target_storage_index = get_level_storage_index(target_skill - 1)
	var skill_entry: Dictionary = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能" + str(target_storage_index)]
	var level: int = int(skill_entry[DataKeys.LEVEL])

	if level >= get_skill_max_level(target_internal):
		Global.add_message_show(self, "技能已经满级！！", 1.5, Vector2(395, 180))
		return

	var snapshot: Dictionary = PlayerData.snapshot_state()
	if _uses_standard_upgrades(target_internal) and level >= SKILL_BOOK_START_LEVEL:
		var book_need := get_skill_book_need(level)
		if not _consume_skill_book(level):
			Global.add_message_show(
				self, get_skill_book_name(level) + "不足，需" + str(book_need) + "个！！", 1.5, Vector2(395, 180)
			)
			return
		skill_entry[DataKeys.LEVEL] = level + 1
	elif target_internal in PASSIVE_SKILLS:
		var need_level = skill10_xz(level)
		if RoleProp.baseroleprop["Level"] < need_level:
			Global.add_message_show(self, "等级不足，需达到：" + str(need_level) + "级！！", 1.5, Vector2(395, 180))
			return
		var need = 500 + 500 * level
		if not PlayerData.spend_soul(need):
			Global.add_message_show(self, "灵魂不足！！", 1.5, Vector2(395, 180))
			return
		skill_entry[DataKeys.LEVEL] = level + 1
	else:
		var i = target_skill - 1
		var need = 100 + (i * 300) + 500 * level
		if not PlayerData.spend_soul(need):
			Global.add_message_show(self, "灵魂不足！！", 1.5, Vector2(395, 180))
			return
		skill_entry[DataKeys.LEVEL] = level + 1

	if not refresh_infor():
		PlayerData.restore_state(snapshot)
		refresh_infor(false)
		Global.add_message_show(self, "存档保存失败，本次升级已撤销：%s" % MemoryClass.describe_save_error(), 2.0, Vector2(395, 180))


func refresh_infor(save_state: bool = true) -> bool:
	set_skill_level()
	set_skill_lh()
	set_skill_mp_cost()
	if not save_state:
		return true
	return MemoryClass.request_save("skill_refresh")


func skill10_xz(Level):
	Level = int(Level)
	match Level:
		0:
			return 0
		1:
			return 8
		2:
			return 14
		3:
			return 19
		4:
			return 24
		5:
			return 30
		6:
			return 33
		7:
			return 35
		8:
			return 37
		9:
			return 39
		10:
			return 45
	return 0


func get_skill_list_name(num):
	return skill_ids_by_role[get_role_key()][num]


func _on_skill_1_pressed() -> void:
	target_skill = 1
	_show_tip()


func _on_skill_2_pressed() -> void:
	target_skill = 2
	_show_tip()


func _on_skill_3_pressed() -> void:
	target_skill = 3
	_show_tip()


func _on_skill_4_pressed() -> void:
	target_skill = 4
	_show_tip()


func _on_skill_5_pressed() -> void:
	target_skill = 5
	_show_tip()


func _on_skill_6_pressed() -> void:
	target_skill = 6
	_show_tip()


func _on_skill_7_pressed() -> void:
	target_skill = 7
	_show_tip()


func _on_skill_8_pressed() -> void:
	target_skill = 8
	_show_tip()


func _on_skill_9_pressed() -> void:
	target_skill = 9
	_show_tip()


func _on_skill_10_pressed() -> void:
	target_skill = 10
	_show_tip()


func _on_skill_11_pressed() -> void:
	target_skill = 11
	_show_tip()


func _on_skill_12_pressed() -> void:
	target_skill = 12
	_show_tip()


func _on_skill_13_pressed() -> void:
	target_skill = 13
	_show_tip()


func _show_tip():
	Signals.connect_choose_box_signal(self, "up_level")

	var skill_name = get_skill_name(target_skill)
	var old_mp = 0
	var new_mp = 0
	var player = RoleProp.source_player

	if player:
		var mp_info = get_need_mp()
		old_mp = mp_info[0]
		new_mp = mp_info[1]
	else:
		var mp_info = get_need_mp()
		old_mp = mp_info[0]
		new_mp = mp_info[1]

	var tip = "确定要升级技能%s吗？ 魔耗：%s→%s" % [skill_name, old_mp, new_mp]
	var skill_list = skill_ids_by_role[get_role_key()]
	if target_skill > 0 and target_skill <= skill_list.size():
		var skill_internal: String = str(skill_list[target_skill - 1])
		var level: int = get_skill_level_by_index(target_skill - 1)
		if _uses_standard_upgrades(skill_internal) and level >= SKILL_BOOK_START_LEVEL and level < MAX_SKILL_LEVEL:
			var book_need := get_skill_book_need(level)
			var book_id := get_skill_book_id(level)
			tip += " 消耗：%sx%s（持有%s）" % [get_skill_book_name(level), book_need, PlayerData.get_item_data(book_id)]
	Global.add_choose_text(Global.get_ancestor(self, 4), Vector2(0, 0), tip, 0)


func _on_ski_1_pressed() -> void:
	_set_key(0)


func _on_ski_2_pressed() -> void:
	_set_key(1)


func _on_ski_3_pressed() -> void:
	_set_key(2)


func _on_ski_4_pressed() -> void:
	_set_key(3)


func _on_ski_5_pressed() -> void:
	_set_key(4)


func _on_ski_6_pressed() -> void:
	_set_key(5)


func _on_ski_7_pressed() -> void:
	_set_key(6)


func _on_ski_8_pressed() -> void:
	_set_key(7)


func _on_ski_9_pressed() -> void:
	_set_key(8)


func _on_ski_10_pressed() -> void:
	_set_key(9)


func _on_ski_11_pressed():
	var role_key = get_role_key()
	if (
		role_key == "角色1"
		or role_key == "角色2"
		or role_key == "角色3"
		or role_key == "角色4"
		or role_key == "角色5"
		or role_key == "角色7"
	):
		_set_key(10)
	else:
		Global.add_message_show(self, "该角色无此技能！！", 1.5, Vector2(395, 180))


func _on_ski_12_pressed() -> void:
	_set_key(11)


func _on_ski_13_pressed() -> void:
	_set_key(12)


func _set_key(index):
	var skill_list = skill_ids_by_role[get_role_key()]
	if index >= skill_list.size():
		Global.add_message_show(self, "该角色无此技能！！", 1.5, Vector2(395, 180))
		return
	if skill_list[index] in PASSIVE_SKILLS:
		Global.add_message_show(self, "被动技能不可以设置按键！！", 1.5, Vector2(395, 180))
		return
	var level = get_skill_level_by_index(index)
	if level == 0:
		Global.add_message_show(self, "先学习技能才能设置按键！！", 1.5, Vector2(395, 180))
		return
	var name = skill_list[index]
	Global.add_skill_key_set(self, Vector2(350, 140), name)


func _on_ski_1_mouse_entered() -> void:
	_show_mp(0)


func _on_ski_1_mouse_exited() -> void:
	_clear_info()


func _on_ski_2_mouse_entered() -> void:
	_show_mp(1)


func _on_ski_2_mouse_exited() -> void:
	_clear_info()


func _on_ski_3_mouse_entered() -> void:
	_show_mp(2)


func _on_ski_3_mouse_exited() -> void:
	_clear_info()


func _on_ski_4_mouse_entered() -> void:
	_show_mp(3)


func _on_ski_4_mouse_exited() -> void:
	_clear_info()


func _on_ski_5_mouse_entered() -> void:
	_show_mp(4)


func _on_ski_5_mouse_exited() -> void:
	_clear_info()


func _on_ski_6_mouse_entered() -> void:
	_show_mp(5)


func _on_ski_6_mouse_exited() -> void:
	_clear_info()


func _on_ski_7_mouse_entered() -> void:
	_show_mp(6)


func _on_ski_7_mouse_exited() -> void:
	_clear_info()


func _on_ski_8_mouse_entered() -> void:
	_show_mp(7)


func _on_ski_8_mouse_exited() -> void:
	_clear_info()


func _on_ski_9_mouse_entered() -> void:
	_show_mp(8)


func _on_ski_9_mouse_exited() -> void:
	_clear_info()


func _on_ski_10_mouse_entered() -> void:
	_show_mp(9)


func _on_ski_10_mouse_exited() -> void:
	_clear_info()


func _on_ski_11_mouse_entered():
	var role_key = get_role_key()
	if (
		role_key == "角色1"
		or role_key == "角色2"
		or role_key == "角色3"
		or role_key == "角色4"
		or role_key == "角色5"
		or role_key == "角色7"
	):
		_show_mp(10)


func _on_ski_11_mouse_exited() -> void:
	_clear_info()


func _on_ski_12_mouse_entered() -> void:
	_show_mp(11)


func _on_ski_12_mouse_exited() -> void:
	_clear_info()


func _on_ski_13_mouse_entered() -> void:
	_show_mp(12)


func _on_ski_13_mouse_exited() -> void:
	_clear_info()


func _show_mp(_index):
	_clear_info()


func _clear_info():
	if skill_info != null and is_instance_valid(skill_info):
		skill_info.queue_free()
	skill_info = null


func _on_skill5_button_pressed():
	var btn_rect = skill5_button.get_global_rect()
	hmz_version_menu.position = Vector2(btn_rect.position.x, btn_rect.end.y)
	hmz_version_menu.popup()


func _on_hmz_version_selected(id: int):
	var skill_internal = hmz_version_menu.get_meta("skill_internal", "hmz")
	var config = skill_variant_config.get(skill_internal)
	if not config:
		return
	var data_key = config["data_key"]
	var current_id = PlayerData.player_data.get(data_key, config["default"])
	if current_id == id:
		return

	PlayerData.player_data[data_key] = id
	MemoryClass.request_save("skill_variant_select")

	current_variant[skill_internal] = id

	update_skill_name_and_icon(5, skill_internal, id)

	notify_current_role1(skill_internal, id)


func notify_current_role1(skill_internal: String, variant_id: int):
	if skill_internal == "hmz":
		var is_new = variant_id == 1
		var tree = get_tree()
		if tree:
			var players = tree.get_nodes_in_group("Player")
			if players.size() > 0 and players[0].has_method("set_hmz_version"):
				players[0].set_hmz_version(is_new)


func _compute_mp_cost(skill_name: String, next_level: bool = false) -> int:
	if skill_name in YutuSkillData.KEYS:
		var index := YutuSkillData.KEYS.find(skill_name)
		return YutuSkillData.mp(skill_name, int(get_skill_level_by_index(index)) + (1 if next_level else 0))
	var passive_list = PASSIVE_SKILLS
	if skill_name in passive_list:
		return 0
	var role_key = get_role_key()
	var skill_list = skill_ids_by_role.get(role_key, [])
	var skill_index = -1
	for idx in range(skill_list.size()):
		if skill_list[idx] == skill_name:
			skill_index = idx
			break
	if skill_index < 0:
		return 0
	var stored_level = get_skill_level_by_index(skill_index)
	var level = stored_level if next_level else (stored_level - 1)
	if level < 0:
		level = 0
	match skill_name:
		"slz":
			return 10 + ((3 + 2 * level) * level)
		"hytj":
			return 8 + ((3 + 2 * level) * level)
		"lys":
			return 12 + ((4 + 2 * level) * level)
		"lyfb":
			return 35 + ((6 + 2 * level) * level)
		"hmz":
			return 35 + ((3 + 3 * level) * level)
		"hmz_ws":
			return 35 + ((3 + 3 * level) * level)
		"hyjj_ws":
			return 45 + ((4 + 3 * level) * level)
		"zz":
			return 12 + ((4 + 2 * level) * level)
		"gsrs":
			return 12 + ((4 + 2 * level) * level)
		"qsez":
			return 10 + ((8 + 2 * level) * level)
		"jdy":
			return 10 + ((8 + 2 * level) * level)
		"hyjj":
			return 22 + ((8 + 2 * level) * level)
		"blb":
			return 15 + ((3 + 2 * level) * level)
		"xbz":
			return 25 + ((3 + 2 * level) * level)
		"tjgl":
			return 35 + ((3 + 2 * level) * level)
		"shy":
			return 30 + ((3 + 2 * level) * level)
		"smb":
			return 60 + ((3 + 3 * level) * level)
		"myhc":
			return 35 + ((3 + 2 * level) * level)
		"sgq":
			return 40 + ((3 + 3 * level) * level)
		"jgz":
			return 40 + ((3 + 3 * level) * level)
		"jhsj":
			return 60 + ((3 + 3 * level) * level)
		"by":
			return 55 + ((3 + 3 * level) * level)
		"zfjg":
			return 80 + ((3 + 3 * level) * level)
		"ssp":
			return 10 + ((2 + 2 * level) * level)
		"dj":
			return 10 + ((3 + 2 * level) * level)
		"dgq":
			return 15 + ((3 + 2 * level) * level)
		"jsp":
			return 20 + ((3 + 2 * level) * level)
		"sd":
			return 15 + ((3 + 2 * level) * level)
		"xgq":
			return 25 + ((3 + 2 * level) * level)
		"syzq":
			return 30 + ((3 + 2 * level) * level)
		"tmc":
			return 35 + ((3 + 3 * level) * level)
		"zznh":
			return 40 + ((3 + 3 * level) * level)
		"bdqk":
			return 60 + ((3 + 3 * level) * level)
		"qlj":
			return 5 + ((3 + 2 * level) * level)
		"dcj":
			return 10 + ((3 + 2 * level) * level)
		"wdzt":
			return 15 + ((3 + 2 * level) * level)
		"tkj":
			return 15 + ((3 + 2 * level) * level)
		"mmw":
			return 20 + ((3 + 2 * level) * level)
		"jdz":
			return 25 + ((3 + 2 * level) * level)
		"lhsq":
			return 30 + ((3 + 2 * level) * level)
		"zq":
			return 35 + ((3 + 3 * level) * level)
		"wdww":
			return 40 + ((3 + 3 * level) * level)
		"bylt":
			return 55 + ((3 + 3 * level) * level)
		"cmly":
			return 55 + ((3 + 3 * level) * level)
		"slq":
			return 5 + ((3 + 2 * level) * level)
		"blq":
			return 10 + ((3 + 2 * level) * level)
		"cxq":
			return 15 + ((3 + 2 * level) * level)
		"llrd":
			return 20 + ((3 + 2 * level) * level)
		"lljy":
			return 30 + ((3 + 2 * level) * level)
		"tllz":
			return 40 + ((3 + 3 * level) * level)
		"ygth":
			return 10 + ((3 + 2 * level) * level)
		"xyq":
			return 15 + ((3 + 2 * level) * level)
		"fhf":
			return 20 + ((3 + 2 * level) * level)
		"ltjz":
			return 50 + ((3 + 3 * level) * level)
		"nz_jlsh":
			return 13 + ((3 + 2 * level) * level)
		"nz_fhcc":
			return 19 + ((3 + 2 * level) * level)
		"nz_hlqg":
			return 28 + ((3 + 2 * level) * level)
		"nz_hlhs":
			return 8 + ((3 + 2 * level) * level)
		"nz_lblc":
			return 66 + ((3 + 3 * level) * level)
		"nz_yysj":
			return NeZhaHero.YINYANG_MP_VALUES[clampi(level, 0, NeZhaHero.YINYANG_MP_VALUES.size() - 1)]
	return 0


func set_skill_mp_cost():
	var role_key = get_role_key()
	var skill_list = skill_ids_by_role[role_key]
	for i in range(skill_list.size()):
		var icon_btn = get_node("ScrollContainer/HBoxContainer/sk_pi/ski_" + str(i + 1))
		if not icon_btn:
			continue

		var old_label = icon_btn.get_node_or_null("mp_cost")
		if old_label:
			icon_btn.remove_child(old_label)
			old_label.queue_free()

		var skill_internal = skill_list[i]
		var mp_cost = 0
		if skill_internal == "sx":
			mp_cost = 0
		elif skill_internal == "sjt":
			mp_cost = 0
		elif skill_internal == "rj":
			mp_cost = 0
		elif skill_internal == "mds":
			mp_cost = 0
		elif skill_internal == "yyb":
			mp_cost = 0
		else:
			mp_cost = _compute_mp_cost(skill_internal)

		var mp_label = Label.new()
		mp_label.name = "mp_cost"
		mp_label.text = str(mp_cost)

		mp_label.add_theme_font_size_override("font_size", 12)
		mp_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		mp_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		mp_label.add_theme_constant_override("outline_size", 3)

		mp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		mp_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		mp_label.position = Vector2(0, 0)
		mp_label.size = Vector2(40, 20)

		icon_btn.add_child(mp_label)
