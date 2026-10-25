extends Node2D

@onready var bg: Sprite2D = $BG
@onready var page_infor: Label = $BG/HBoxContainer/PageInfor

var infor_list = []
var current_page: int = 1
var max_page: int = 0
var position_list = [Vector2(0, -110), Vector2(0, 10), Vector2(0, 130)]

const MAGIC_WEAPON_IDS := [
	"zcld",
	"dshl",
	"dhqf",
	"tsgj",
	"bsyj",
	"lsys",
	"xhmt",
	"kyl",
	"xhhl",
	"qyj",
	"zjfyd",
	"zjhl",
	"yjp",
	"zlwdah",
	"nmwdnh",
	"yx",
	"qlsword",
	"sqzlw",
	"sqnmwdnh",
	"xianyjp",
	"dzyl",
	"469000004",
	"469000011",
	"yyzlj",
	"ywhl",
	"zhyx",
	"bjs",
	"sxyg",
	"dkhl",
	"yyb",
	"hehua",
	"tjbg"
]

const MAGIC_WEAPON_MAX_GROWTH := {
	"zcld": 0.8,
	"dshl": 1.0,
	"dhqf": 1.0,
	"tsgj": 1.4,
	"bsyj": 1.4,
	"lsys": 1.6,
	"xhmt": 1.8,
	"kyl": 2.0,
	"xhhl": 2.2,
	"qyj": 2.4,
	"yyzlj": 2.4,
	"ywhl": 2.4,
	"zhyx": 2.4,
	"bjs": 2.4,
	"sxyg": 2.4,
	"dkhl": 2.4,
	"yyb": 2.4,
	"hehua": 2.4,
	"zjfyd": 2.5,
	"zjhl": 2.5,
	"yjp": 2.5,
	"zlwdah": 2.7,
	"nmwdnh": 2.7,
	"yx": 2.7,
	"qlsword": 2.7,
	"sqzlw": 3.2,
	"sqnmwdnh": 3.2,
	"xianyjp": 5.2,
	"dzyl": 6.2,
	"469000004": 6.8,
	"469000011": 7.2,
	"tjbg": 3.0
}

var fbinfor: Dictionary = {}


func _ready():
	var sorted_ids: Array = MAGIC_WEAPON_IDS.duplicate()
	sorted_ids.sort_custom(
		func(a: String, b: String) -> bool:
			var growth_a := float(MAGIC_WEAPON_MAX_GROWTH.get(a, INF))
			var growth_b := float(MAGIC_WEAPON_MAX_GROWTH.get(b, INF))
			if is_equal_approx(growth_a, growth_b):
				return MAGIC_WEAPON_IDS.find(a) < MAGIC_WEAPON_IDS.find(b)
			return growth_a < growth_b
	)
	for index in range(sorted_ids.size()):
		var page_key := "page_%d" % (int(index / 3) + 1)
		if not fbinfor.has(page_key):
			fbinfor[page_key] = []
		fbinfor[page_key].append(sorted_ids[index])
	max_page = fbinfor.size()
	add_infor()


func _physics_process(_delta: float) -> void:
	page_infor.text = str(current_page) + "/" + str(max_page)


func add_infor():
	var page_key = "page_" + str(current_page)
	if not fbinfor.has(page_key):
		return
	var page_items: Array = fbinfor[page_key]
	for i in page_items.size():
		var infor = Global.add_skill_select(bg, position_list[i], page_items[i])
		infor_list.push_back(infor)


func remove_infor():
	for i in infor_list:
		i.queue_free()
	infor_list.clear()


func _on_last_pressed() -> void:
	if current_page > 1:
		current_page -= 1
		remove_infor()
		add_infor()


func _on_next_pressed() -> void:
	if current_page < max_page:
		current_page += 1
		remove_infor()
		add_infor()


func _on_close_pressed() -> void:
	queue_free()


## ESC 分层关闭：只关闭法宝技能选择层。
func request_escape_close() -> bool:
	queue_free()
	return true
