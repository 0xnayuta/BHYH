extends TextureRect
@onready var items: Button = $Items
@onready var title: Label = $ScrollContainer/title

var total_num: int
var item_id: String


func _ready() -> void:
	items.is_in_hhgz = true
	items.is_in_ldl_gz = true

	items.qh_level = 0


func _physics_process(delta: float) -> void:
	items.eq_prop = AE.all_equipment[item_id]
	items.wx = []
	items.set_button_icon(load_item_icon(item_id))
	if total_num <= 1:
		total_num = 1
	var item_name = AE.all_equipment[item_id][DataKeys.NAME]
	match AE.all_equipment[item_id][DataKeys.TYPE]:
		"道具", "消耗品":
			if total_num == null:
				items.total_number = 1
			else:
				items.total_number = total_num
		"武器", "防具", "饰品", "神骨", "法宝", "时装", "头衔", "翅膀":
			items.total_number = 0
	title.text = str(item_name) + " * " + str(total_num)
	set_physics_process(false)


func load_item_icon(_name):
	var abc = load("res://Art/backpack/all_items/" + str(_name) + ".png")
	return abc
