extends Node2D
class_name Transmogrified
const XIANYU_WING_PATH_FORMAT := "res://Art/hero_picture/wings/xyzy/role%d.tres"
const HUAHAO_WING_FRAME_DIR := "res://Art/hero_picture/wings/hhyq"
@onready var bg_2: Sprite2D = $BG/BG2
@onready var infor: Label = $BG/ChangePage/Infor
@onready var role_body: Sprite2D = $BG/Player/RoleBody
@onready var role_equipment: Sprite2D = $BG/Player/RoleEquipment
@onready var role_body_front: Sprite2D = $BG/Player/RoleBodyFront
@onready var wqq: Button = $BG/wqq
@onready var wq: Label = $BG/wqq/wq
@onready var fjj: Button = $BG/fjj
@onready var fj_2: Label = $BG/fjj/fj2
@onready var role: Label = $BG/Role
@onready var wings: AnimatedSprite2D = $BG/Player/Wings
@onready var cbb: Button = $BG/cbb
@onready var cb: Label = $BG/cbb/cb
@onready var box_list: GridContainer = $BG/BoxList
@onready var tx: AnimatedSprite2D = $BG/Player/Tx
@onready var collect_value: Label = $BG/CollectValue
var _wing_base_position := Vector2.ZERO
var _wing_base_rotation := 0.0
var _wing_base_scale := Vector2.ONE
var _wing_base_transform_initialized := false
var _special_wing_track_states: Array[Dictionary] = []
var _special_wing_tracks_disabled := false

var current_type: String = "全部":
	set(vl):
		current_type = vl
		currentpage = 1
		add_box()
var player_id = int(PlayerData.player_data["Myself"])
var currentpage: int = 1
var maxpage: int = 4
var _nezha_body_id := "Empty"
var _nezha_weapon_id := "Empty"
var _nezha_preview_elapsed := 0.0

const REMOVED_TRANSMOG_ITEM_IDS := [
	"wkjdyhwq",
	"wkjdyhyf",
	"tsjdyhwq",
	"tsjdyhyf",
	"bjjdyhwq",
	"bjjdyhyf",
	"ssjdyhwq",
	"ssjdyhyf",
	"bljdyhwq",
	"bljdyhyf",
	"putongsmsrsz",
	"youxiusmsrsz",
	"jingliangsmsrsz",
	"shishismsrsz",
	"xielingsmsrsz",
	"hunqismsrsz",
	"chuanshuosmsrsz"
]


func _is_transmog_item_visible(item_id: String) -> bool:
	return not REMOVED_TRANSMOG_ITEM_IDS.has(item_id)


var role_item_list = {
	"悟空":
	[
		"wkjdyhwq",
		"ptxzg",
		"whg",
		"jcbj",
		"qld",
		"ryjgb",
		"gtq",
		"tsyj",
		"gwj",
		"qtz",
		"nyd",
		"qybd",
		"zjbtg",
		"th",
		"qlg",
		"qs",
		"lemhg",
		"wkjdyhyf",
		"ptxzf",
		"dsyj",
		"xwj",
		"yhj",
		"bsxj",
		"xhmj",
		"dszk",
		"kys",
		"zjqj",
		"ey",
		"qlj",
		"lemhz",
		"wkhzyf",
		"wklzyf",
		"wkbsz",
		"wkhwdg",
		"wkwdg",
		"wkmrz",
		"putongttzssz",
		"youxiuttzssz",
		"jingliangttzssz",
		"shishittzssz",
		"xielingttzssz",
		"hunqittzssz",
		"chuanshuottzssz",
		"shenqittzssz",
		"putongnmwsz",
		"youxiunmwsz",
		"jingliangnmwsz",
		"shishinmwsz",
		"xielingnmwsz",
		"hunqinmwsz",
		"chuanshuonmwsz",
		"shenqinmwsz",
		"putongzlwsz",
		"youxiuzlwsz",
		"jingliangzlwsz",
		"shishizlwsz",
		"xielingzlwsz",
		"hunqizlwsz",
		"chuanshuozlwsz",
		"shenqizlwsz",
		"putongsmsrsz",
		"youxiusmsrsz",
		"jingliangsmsrsz",
		"shishismsrsz",
		"xielingsmsrsz",
		"hunqismsrsz",
		"chuanshuosmsrsz",
		"shenqismsrsz",
		"xnsz",
		"slshj",
		"slshg",
		"cswkxyhb",
		"xyfjwk",
		"dz",
		"zxstj",
		"pftyj",
		"pftyg",
		"jjwq",
		"jjfj",
		"ysszg",
		"ysszj",
		"bthl",
		"zlwg",
		"zdplg",
		"zdlj",
		"wslej",
		"wsleg",
		"zqfjwk",
		"zqwqwk",
		"ygfjwk",
		"ygwqwk"
	],
	"唐僧":
	[
		"ptsmz",
		"dsqz",
		"bhz",
		"jhcz",
		"bsyz",
		"xhxh",
		"lhz",
		"myz",
		"kyz",
		"hylz",
		"smz",
		"tc",
		"plz",
		"tsjdyhwq",
		"rc",
		"dmysz",
		"nbz",
		"tsjdyhyf",
		"ptjs",
		"bsp",
		"jcjs",
		"qlp",
		"lzp",
		"tsyp",
		"qcp",
		"jljs",
		"qyfp",
		"hljh",
		"cz",
		"plp",
		"dmyszh",
		"nbzh",
		"tshzyf",
		"tslzyf",
		"tsbsz",
		"tshowdg",
		"tshwdg",
		"tsmrz",
		"putongttzssz",
		"youxiuttzssz",
		"jingliangttzssz",
		"shishittzssz",
		"xielingttzssz",
		"hunqittzssz",
		"chuanshuottzssz",
		"shenqittzssz",
		"putongnmwsz",
		"youxiunmwsz",
		"jingliangnmwsz",
		"shishinmwsz",
		"xielingnmwsz",
		"hunqinmwsz",
		"chuanshuonmwsz",
		"shenqinmwsz",
		"putongzlwsz",
		"youxiuzlwsz",
		"jingliangzlwsz",
		"shishizlwsz",
		"xielingzlwsz",
		"hunqizlwsz",
		"chuanshuozlwsz",
		"shenqizlwsz",
		"putongsmsrsz",
		"youxiusmsrsz",
		"jingliangsmsrsz",
		"shishismsrsz",
		"xielingsmsrsz",
		"hunqismsrsz",
		"chuanshuosmsrsz",
		"shenqismsrsz",
		"zt",
		"sljs",
		"xyfjts",
		"slfmz",
		"cstsxyhb",
		"zqfjts",
		"zqwqts",
		"ygfjts",
		"ygwqts"
	],
	"八戒":
	[
		"bjjdyhwq",
		"ptdp",
		"jcjp",
		"wtp",
		"zhp",
		"jcdp",
		"gtb",
		"lcld",
		"ssc",
		"tpltp",
		"syc",
		"xhc",
		"zjksf",
		"tz",
		"ylf",
		"yt",
		"lgdwc",
		"bjjdyhyf",
		"ptcs",
		"dszy",
		"pxk",
		"jgj",
		"lcgy",
		"bszj",
		"xhymk",
		"tpzy",
		"hylk",
		"wsjg",
		"ry",
		"ylk",
		"lgdwz",
		"bjhzyf",
		"bjlzyf",
		"bjbsz",
		"bjhowdg",
		"bjhwdg",
		"bjmrz",
		"putongttzssz",
		"youxiuttzssz",
		"jingliangttzssz",
		"shishittzssz",
		"xielingttzssz",
		"hunqittzssz",
		"chuanshuottzssz",
		"shenqittzssz",
		"putongnmwsz",
		"youxiunmwsz",
		"jingliangnmwsz",
		"shishinmwsz",
		"xielingnmwsz",
		"hunqinmwsz",
		"chuanshuonmwsz",
		"shenqinmwsz",
		"putongzlwsz",
		"youxiuzlwsz",
		"jingliangzlwsz",
		"shishizlwsz",
		"xielingzlwsz",
		"hunqizlwsz",
		"chuanshuozlwsz",
		"shenqizlwsz",
		"putongsmsrsz",
		"youxiusmsrsz",
		"jingliangsmsrsz",
		"shishismsrsz",
		"xielingsmsrsz",
		"hunqismsrsz",
		"chuanshuosmsrsz",
		"shenqismsrsz",
		"jt",
		"sllyp",
		"slfk",
		"xyfjbj",
		"csbjxyhb",
		"zqfjbj",
		"zqwqbj",
		"ygfjbj",
		"ygwqbj"
	],
	"沙僧":
	[
		"ssjdyhwq",
		"ptyyc",
		"jmc",
		"jcmc",
		"hdc",
		"jlxmc",
		"bsbc",
		"gtc",
		"xhxc",
		"jlfyc",
		"shyc",
		"kyc",
		"hylc",
		"zjxmc",
		"ts",
		"jlc",
		"ll",
		"mlhfg",
		"ssjdyhyf",
		"ptcp",
		"dshp",
		"bxp",
		"jmy",
		"lchp",
		"bap",
		"jlfyj",
		"xhp",
		"jllm",
		"yj",
		"jlj",
		"mlhfz",
		"sshzyf",
		"sslzyf",
		"ssbsz",
		"ssqb",
		"ssxsz",
		"ssmrz",
		"putongttzssz",
		"youxiuttzssz",
		"jingliangttzssz",
		"shishittzssz",
		"xielingttzssz",
		"hunqittzssz",
		"chuanshuottzssz",
		"shenqittzssz",
		"putongnmwsz",
		"youxiunmwsz",
		"jingliangnmwsz",
		"shishinmwsz",
		"xielingnmwsz",
		"hunqinmwsz",
		"chuanshuonmwsz",
		"shenqinmwsz",
		"putongzlwsz",
		"youxiuzlwsz",
		"jingliangzlwsz",
		"shishizlwsz",
		"xielingzlwsz",
		"hunqizlwsz",
		"chuanshuozlwsz",
		"shenqizlwsz",
		"putongsmsrsz",
		"youxiusmsrsz",
		"jingliangsmsrsz",
		"shishismsrsz",
		"xielingsmsrsz",
		"hunqismsrsz",
		"chuanshuosmsrsz",
		"shenqismsrsz",
		"js",
		"xyfjss",
		"csssxyhb",
		"zqfjss",
		"zqwqss",
		"ygfjss",
		"ygwqss"
	],
	"白龙":
	[
		"bljdyhwq",
		"pttq",
		"dslq",
		"twq",
		"qthbq",
		"bshq",
		"mwq",
		"ylhq",
		"xyq",
		"qysq",
		"blmq",
		"tq",
		"tlq",
		"ld",
		"lxhjq",
		"bljdyhyf",
		"ptcf",
		"zhj",
		"jclj",
		"ttj",
		"ssj",
		"tsgp",
		"xhgp",
		"yljj",
		"xhj",
		"zjgp",
		"ze",
		"tlj",
		"hhez",
		"psdx",
		"blhzyf",
		"bllzyf",
		"blbsz",
		"blhowdg",
		"blhwdg",
		"blmrz",
		"putongttzssz",
		"youxiuttzssz",
		"jingliangttzssz",
		"shishittzssz",
		"xielingttzssz",
		"hunqittzssz",
		"chuanshuottzssz",
		"shenqittzssz",
		"putongnmwsz",
		"youxiunmwsz",
		"jingliangnmwsz",
		"shishinmwsz",
		"xielingnmwsz",
		"hunqinmwsz",
		"chuanshuonmwsz",
		"shenqinmwsz",
		"putongzlwsz",
		"youxiuzlwsz",
		"jingliangzlwsz",
		"shishizlwsz",
		"xielingzlwsz",
		"hunqizlwsz",
		"chuanshuozlwsz",
		"shenqizlwsz",
		"putongsmsrsz",
		"youxiusmsrsz",
		"jingliangsmsrsz",
		"shishismsrsz",
		"xielingsmsrsz",
		"hunqismsrsz",
		"chuanshuosmsrsz",
		"shenqismsrsz",
		"xyfjbl",
		"slhlq",
		"slcp",
		"tl",
		"csblxyhb",
		"zqfjbl",
		"zqwqbl",
		"ygfjbl",
		"ygwqbl"
	],
	"哪吒":
	[
		"nzhjq",
		"nzly",
		"210007001",
		"211007001",
		"210007002",
		"211007002",
		"220007001",
		"221007001",
		"220007002",
		"221007002",
		"230007001",
		"231007001",
		"230007002",
		"231007002",
		"230007003",
		"231007003",
		"230007004",
		"231007004",
		"240007001",
		"241007001",
		"240007002",
		"241007002",
		"240007003",
		"241007003",
		"240007004",
		"241007004",
		"240007005",
		"241007005",
		"341071301",
		"342071301",
		"zqfjnz",
		"zqwqnz",
		"ygfjnz",
		"ygwqnz"
	],
	"玉兔": preload("res://Script/data/yutu_equipment_data.gd").item_ids(),
	"翅膀": ["xqzy", "bszy", "jmzy", "xtzy", "ttzy", "xmzy", "ryzy", "wyzy", "xyzy", "hhyq"],
	"头衔":
	[
		"bhyh",
		"htd",
		"ymqzq",
		"xczg",
		"sxyr",
		"xysc",
		"yyscj",
		"zyscj",
		"cmscj",
		"qpzscj",
		"ghjscj",
		"xzbwg",
		"hhyx",
		"sjzs",
		"ptsryx",
		"yxsryx",
		"jlsryx",
		"sssryx",
		"xlsryx"
	],
}


func push_eq_to_list():
	PlayerData.ensure_acquired_equipment_data()
	var list = []
	match int(PlayerData.player_data["Myself"]):
		1:
			list = role_item_list["悟空"]
			role_item_list[DataKeys.TITLE].push_back("qtds")
		2:
			list = role_item_list["唐僧"]
			role_item_list[DataKeys.TITLE].push_back("jcz")
		3:
			list = role_item_list["八戒"]
			role_item_list[DataKeys.TITLE].push_back("tpys")
		4:
			list = role_item_list["沙僧"]
			role_item_list[DataKeys.TITLE].push_back("jldj")
		5:
			list = role_item_list["白龙"]
			role_item_list[DataKeys.TITLE].push_back("lwstz")
		6:
			list = role_item_list["哪吒"]
		7:
			list = role_item_list["玉兔"].duplicate()
	for i in role_item_list[DataKeys.WINGS]:
		list.push_back(i)
	for i in role_item_list[DataKeys.TITLE]:
		list.push_back(i)
	for i in list:
		if not _is_transmog_item_visible(str(i)):
			continue
		if PlayerData.has_acquired_equipment(str(i)):
			if not PlayerData.player_data["幻化拥有列表"].has(i):
				PlayerData.player_data["幻化拥有列表"].push_back(i)


func get_current_role_list():
	var other_list = []
	match int(PlayerData.player_data["Myself"]):
		1:
			role.text = "悟空"
			for i in role_item_list["悟空"]:
				other_list.push_back(i)
		2:
			role.text = "唐僧"
			for i in role_item_list["唐僧"]:
				other_list.push_back(i)
		3:
			role.text = "八戒"
			for i in role_item_list["八戒"]:
				other_list.push_back(i)
		4:
			role.text = "沙僧"
			for i in role_item_list["沙僧"]:
				other_list.push_back(i)
		5:
			role.text = "白龙"
			for i in role_item_list["白龙"]:
				other_list.push_back(i)
		6:
			role.text = "哪吒"
			for i in role_item_list["哪吒"]:
				other_list.push_back(i)
		7:
			role.text = "玉兔"
			other_list.append_array(role_item_list["玉兔"])
	for index in range(other_list.size() - 1, -1, -1):
		if not _is_transmog_item_visible(str(other_list[index])):
			other_list.remove_at(index)
	return other_list


func get_current_type_list():
	var list = get_current_role_list()
	var new_list = []
	if current_type == "全部":
		return list
	for i in list:
		if AE.all_equipment.has(i) and AE.all_equipment[i][DataKeys.TYPE] == current_type:
			new_list.push_back(i)
	return new_list


func get_current_max_page():
	var current_list = get_current_type_list()
	if int(current_list.size()) % 6 == 0:
		return int(current_list.size() / 6)
	else:
		return int(current_list.size() / 6) + 1


func get_page_list():
	var current_list = get_current_type_list()
	var page_dic = {}
	for i in range(get_current_max_page()):
		page_dic["Page_" + str(i + 1)] = []
	var _loc_1: int = 1
	var num: int = 1
	var page_num: int = 1
	for i in current_list:
		if num < 6:
			num += 1
			page_dic["Page_" + str(page_num)].push_back(i)
		else:
			num = 1
			page_dic["Page_" + str(page_num)].push_back(i)
			page_num += 1

	return page_dic


func get_finish_item_num():
	var target_count: int = 0
	var list = []
	if current_type == "全部":
		for item_id in PlayerData.player_data["幻化拥有列表"]:
			if _is_transmog_item_visible(str(item_id)):
				target_count += 1
		return target_count
	for i in PlayerData.player_data["幻化拥有列表"]:
		if (
			_is_transmog_item_visible(str(i))
			and AE.all_equipment.has(i)
			and AE.all_equipment[i][DataKeys.TYPE] == current_type
		):
			list.push_back(i)
	return list.size()


func add_box():
	remove_box()
	var dic = get_page_list()
	if dic.size() > 0:
		for i in dic["Page_" + str(currentpage)]:
			Global.add_trans_box(box_list, i, self)


func remove_box():
	for i in box_list.get_children():
		i.queue_free()


func _set_box():
	if PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WEAPON] == "":
		wqq.get_item_name = "empty"
	else:
		wqq.get_item_name = PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WEAPON]
	if PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.ARMOR] == "":
		fjj.get_item_name = "empty"
	else:
		fjj.get_item_name = PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.ARMOR]
	if PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WINGS] == "":
		cbb.get_item_name = "empty"
	else:
		cbb.get_item_name = PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WINGS]
	if wqq.get_item_name == "empty":
		wqq.set_button_icon(load_item_icon("empty"))
		wq.visible = true
	else:
		wq.visible = false
		wqq.is_in_ldl_gz = true
		wqq.is_in_hh = true
		if PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WEAPON] == "":
			wqq.set_button_icon(load_item_icon("empty"))
			wqq.eq_prop = {}
		else:
			wqq.set_button_icon(load_item_icon(PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WEAPON]))
			wqq.eq_prop = AE.all_equipment[PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WEAPON]]
		wqq.qh_level = 0
		wqq.wx = []
	if fjj.get_item_name == "empty":
		fj_2.visible = true
		fjj.set_button_icon(load_item_icon("empty"))
	else:
		fj_2.visible = false
		fjj.is_in_ldl_gz = true
		fjj.is_in_hh = true
		if PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.ARMOR] == "":
			fjj.set_button_icon(load_item_icon("empty"))
			fjj.eq_prop = {}
		else:
			fjj.set_button_icon(load_item_icon(PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.ARMOR]))
			fjj.eq_prop = AE.all_equipment[PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.ARMOR]]
		fjj.qh_level = 0
		fjj.wx = []
	if cbb.get_item_name == "empty":
		cb.visible = true
		cbb.set_button_icon(load_item_icon("empty"))
	else:
		cb.visible = false
		cbb.is_in_ldl_gz = true
		cbb.is_in_hh = true
		if PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WINGS] == "":
			cbb.set_button_icon(load_item_icon("empty"))
			cbb.eq_prop = {}
		else:
			cbb.set_button_icon(load_item_icon(PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WINGS]))
			cbb.eq_prop = AE.all_equipment[PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WINGS]]
		cbb.qh_level = 0
		cbb.wx = []


func _ready() -> void:
	player_id = int(PlayerData.player_data.get("Myself", 1))
	if wings.sprite_frames != null:
		wings.sprite_frames = wings.sprite_frames.duplicate(true)
	_wing_base_position = wings.position
	_wing_base_rotation = wings.rotation
	_wing_base_scale = wings.scale
	_wing_base_transform_initialized = true
	_ensure_title_preview_animations()
	push_eq_to_list()
	maxpage = get_current_max_page()
	match player_id:
		1:
			$BG/Player/Playerplay.play("Wait")
			role_item_list[DataKeys.TITLE].push_back("qtds")
		2:
			$BG/Player/Playerplay.play("Wait2")
			role_item_list[DataKeys.TITLE].push_back("jcz")
		3:
			$BG/Player/Playerplay.play("Wait3")
			role_item_list[DataKeys.TITLE].push_back("tpys")
		4:
			$BG/Player/Playerplay.play("wait4")
			role_item_list[DataKeys.TITLE].push_back("jldj")
		5:
			$BG/Player/Playerplay.play("wait5")
			role_item_list[DataKeys.TITLE].push_back("lwstz")
	infor.text = str(currentpage) + "/" + str(maxpage)
	on_eqchange()
	add_box()


func _physics_process(_delta: float) -> void:
	if player_id == 7:
		role.text = "玉兔"
		_nezha_preview_elapsed += _delta
		preload("res://Script/hero/yutu_visuals.gd").preview(
			role_body, role_equipment, role_body_front, _nezha_preview_elapsed, -115.0
		)
	if player_id == 6:
		_update_nezha_preview(_delta)
	set_wings_offset()
	var target_count = get_finish_item_num()
	maxpage = get_current_max_page()
	infor.text = str(currentpage) + "/" + str(maxpage)

	collect_value.text = (
		str(current_type) + "收集进度：(" + str(target_count) + "/" + str(get_current_type_list().size()) + ")"
	)


func _on_close_pressed() -> void:
	queue_free()


## ESC 分层关闭：只关闭幻化窗口。
func request_escape_close() -> bool:
	queue_free()
	return true


func _on_last_pressed() -> void:
	if currentpage > 1:
		currentpage -= 1
		add_box()


func _on_next_pressed() -> void:
	if currentpage < maxpage:
		currentpage += 1
		add_box()


func on_eqchange():
	var wq: String
	var fj: String

	if PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WEAPON] == "":
		if PlayerData.player_data[DataKeys.WEAPON].size() == 0:
			wq = "Empty"
		else:
			wq = str(PlayerData.player_data[DataKeys.WEAPON][0][DataKeys.NAME])
	else:
		wq = str(PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WEAPON])
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

	if wings_list == "xyzy":
		_ensure_xianyu_wing_animation()
	elif wings_list == "hhyq":
		_ensure_huahao_wing_animation()
	_set_special_preview_tracks(wings_list == "xyzy" or wings_list == "hhyq")
	wings.flip_h = wings_list == "xyzy" or wings_list == "hhyq"
	wings.z_index = 0
	wings.play(wings_list)
	change_tx()
	_set_box()


func _set_special_preview_tracks(disabled: bool) -> void:
	var player_animation: AnimationPlayer = $BG/Player/Playerplay
	if player_animation == null or disabled == _special_wing_tracks_disabled:
		return
	if disabled:
		_special_wing_track_states.clear()
		for library_name in player_animation.get_animation_library_list():
			var library: AnimationLibrary = player_animation.get_animation_library(library_name)
			if library == null:
				continue
			for animation_name in library.get_animation_list():
				var animation: Animation = library.get_animation(animation_name)
				if animation == null:
					continue
				for track_index in animation.get_track_count():
					var path := str(animation.track_get_path(track_index))
					if not (
						path.ends_with("Wings:position")
						or path.ends_with("Wings:offset")
						or path.ends_with("Wings:rotation")
						or path.ends_with("Wings:flip_h")
					):
						continue
					_special_wing_track_states.append(
						{
							"animation": animation,
							"track_index": track_index,
							"enabled": animation.track_is_enabled(track_index)
						}
					)
					animation.track_set_enabled(track_index, false)
		_special_wing_tracks_disabled = true
		return
	for state in _special_wing_track_states:
		var animation: Animation = state.get("animation")
		if animation != null:
			animation.track_set_enabled(int(state.get("track_index", -1)), bool(state.get("enabled", true)))
	_special_wing_track_states.clear()
	_special_wing_tracks_disabled = false


func change_body(_name):
	preload("res://Script/hero/moon_palace_clothes_effect.gd").sync(role_body, str(_name))
	if player_id == 6:
		_nezha_body_id = str(_name)
		return
	role_body.texture = Global.load_role1_body(_name)


func change_eq(_name):
	if player_id == 6:
		_nezha_weapon_id = str(_name)
		return
	role_equipment.texture = Global.load_role1_eq(_name)


func _update_nezha_preview(delta: float) -> void:
	var body_frames := NeZhaEquipmentVisuals.get_body_frames(_nezha_body_id)
	var body_front_frames := NeZhaEquipmentVisuals.get_body_front_frames(_nezha_body_id)
	var weapon_frames := NeZhaEquipmentVisuals.get_weapon_frames(_nezha_weapon_id)
	var frame_count := body_frames.get_frame_count(&"wait")
	if frame_count <= 0:
		return
	_nezha_preview_elapsed += delta
	var frame_index := int(_nezha_preview_elapsed * body_frames.get_animation_speed(&"wait")) % frame_count
	role_body.hframes = 1
	role_body.vframes = 1
	role_body.frame = 0
	role_body.texture = body_frames.get_frame_texture(&"wait", frame_index)
	role_body.scale = Vector2(-1.1, 1.1)
	role_body.offset = Vector2(5, -119)
	role_equipment.hframes = 1
	role_equipment.vframes = 1
	role_equipment.frame = 0
	role_equipment.texture = weapon_frames.get_frame_texture(&"wait", frame_index)
	role_equipment.scale = role_body.scale
	role_equipment.offset = role_body.offset
	role_body_front.hframes = 1
	role_body_front.vframes = 1
	role_body_front.frame = 0
	role_body_front.texture = body_front_frames.get_frame_texture(&"wait", frame_index)
	role_body_front.scale = role_body.scale
	role_body_front.offset = role_body.offset


func load_item_icon(_name):
	var abc = load("res://Art/backpack/all_items/" + str(_name) + ".png")
	return abc


func _ensure_xianyu_wing_animation() -> void:
	if wings.sprite_frames == null:
		return
	player_id = int(PlayerData.player_data.get("Myself", 1))
	var source_frames := load(XIANYU_WING_PATH_FORMAT % clampi(player_id, 1, 6)) as SpriteFrames
	if source_frames == null or not source_frames.has_animation(&"xyzy"):
		return
	if wings.sprite_frames.has_animation(&"xyzy"):
		wings.sprite_frames.remove_animation(&"xyzy")
	wings.sprite_frames.add_animation(&"xyzy")
	wings.sprite_frames.set_animation_loop(&"xyzy", source_frames.get_animation_loop(&"xyzy"))
	wings.sprite_frames.set_animation_speed(&"xyzy", source_frames.get_animation_speed(&"xyzy"))
	for frame_index in source_frames.get_frame_count(&"xyzy"):
		wings.sprite_frames.add_frame(
			&"xyzy",
			source_frames.get_frame_texture(&"xyzy", frame_index),
			source_frames.get_frame_duration(&"xyzy", frame_index)
		)


func _ensure_huahao_wing_animation() -> void:
	if wings.sprite_frames == null or wings.sprite_frames.has_animation(&"hhyq"):
		return
	wings.sprite_frames.add_animation(&"hhyq")
	wings.sprite_frames.set_animation_loop(&"hhyq", true)
	wings.sprite_frames.set_animation_speed(&"hhyq", 30.0)
	for frame_index in range(1, 41):
		var texture := load("%s/%d.png" % [HUAHAO_WING_FRAME_DIR, frame_index]) as Texture2D
		if texture != null:
			wings.sprite_frames.add_frame(&"hhyq", texture)


func _ensure_title_preview_animations() -> void:
	_ensure_title_preview_animation("bhyh", "res://Art/all_tx/bhyh.png")
	_ensure_title_preview_animation("htd", "res://Art/all_tx/htd.png")
	_ensure_title_preview_animation("ymqzq", "res://Art/all_tx/ymqzq.png")


func _ensure_title_preview_animation(title_name: String, texture_path: String) -> void:
	if tx.sprite_frames.has_animation(StringName(title_name)):
		return
	var title_texture := load(texture_path) as Texture2D
	if title_texture == null:
		return
	var animation_name := StringName(title_name)
	tx.sprite_frames.add_animation(animation_name)
	tx.sprite_frames.set_animation_loop(animation_name, true)
	tx.sprite_frames.set_animation_speed(animation_name, 15.0)
	for row in range(4):
		for column in range(4):
			var frame_texture := AtlasTexture.new()
			frame_texture.atlas = title_texture
			frame_texture.region = Rect2(column * 208, row * 124, 208, 124)
			tx.sprite_frames.add_frame(animation_name, frame_texture)


func _play_title_preview(title_name: String) -> void:
	tx.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tx.scale = Vector2.ONE * (0.75 if title_name == "bhyh" else 0.85)
	tx.play(title_name)


func change_tx():
	if PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.TITLE] == "":
		if PlayerData.player_data[DataKeys.TITLE].size() == 0:
			tx.play("Empty")
		else:
			var mz = PlayerData.player_data[DataKeys.TITLE][0][DataKeys.NAME]
			_play_title_preview(mz)
	else:
		_play_title_preview(PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.TITLE])


func _on_total_pressed() -> void:
	current_type = "全部"


func _on_wq_pressed() -> void:
	current_type = "武器"


func _on_fj_pressed() -> void:
	current_type = "防具"


func _on_cb_pressed() -> void:
	current_type = "翅膀"


func _on_sz_pressed() -> void:
	current_type = "时装"


func _on_tx_pressed() -> void:
	current_type = "头衔"


func set_wings_offset():
	var current_wings_name: String
	if PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WINGS] == "":
		if PlayerData.player_data[DataKeys.WINGS].size() == 0:
			current_wings_name = "empty"
		else:
			current_wings_name = PlayerData.player_data[DataKeys.WINGS][0][DataKeys.NAME]
	else:
		current_wings_name = PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WINGS]
	if player_id == 2:
		wings.position = Vector2(41, -4)
	elif _wing_base_transform_initialized:
		wings.position = _wing_base_position
		wings.rotation = _wing_base_rotation
		wings.scale = _wing_base_scale
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
		"xyzy":
			wings.offset = Vector2.ZERO
			wings.scale = Vector2.ONE
		"hhyq":
			wings.offset = Vector2(60, 0)
			wings.scale = Vector2.ONE
