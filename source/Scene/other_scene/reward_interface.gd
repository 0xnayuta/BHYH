extends Node2D
@onready var item_grid_container: GridContainer = $Wkbg/ScrollContainer/ItemList
@onready var title: Label = $Wkbg/Title
@onready var pl: AnimationPlayer = $pl

var use_item_name
var use_num
var reward_items: Array = []
var claim_callable: Callable
var item_info = {"Name": "ryjgb", "Value": 4, "Prop": {}, "WX": [], "strength_value": 0}

var _reward_committed := false
var _reward_succeeded := false
var _box_tween: Tween


func _process(_delta: float) -> void:
	if _reward_committed:
		set_process(false)
		return
	_reward_committed = true
	var result: Dictionary = RewardGrantCommand.execute(
		reward_items,
		str(use_item_name) if use_item_name != null else "",
		int(use_num) if use_num != null else 0,
		claim_callable
	)
	if not bool(result.get("ok", false)):
		_reward_succeeded = false
		title.text = "奖励发放失败"
		if pl != null:
			pl.stop()
		_hide_reward_boxes()
		Global.add_message_show(self, str(result.get("message", "奖励发放失败")), 2.0, Vector2(470, 300))
	else:
		_reward_succeeded = true
	set_process(false)


func _physics_process(_delta: float) -> void:
	if _reward_committed and not _reward_succeeded:
		set_physics_process(false)
		return
	if use_item_name != null and use_num != null and AE.all_equipment.has(str(use_item_name)):
		title.text = "本次使用：" + str(AE.all_equipment[use_item_name][DataKeys.NAME]) + " * " + str(use_num)
	else:
		title.text = ""
	pl.play("pl")
	add_box()
	set_physics_process(false)


func add_box():
	if _reward_committed and not _reward_succeeded:
		return
	var tween: Tween = null
	for i in reward_items:
		var item_name = str(i.get("Name", ""))
		if not AE.all_equipment.has(item_name):
			continue
		var type = AE.all_equipment[item_name][DataKeys.TYPE]
		var value = i["Value"]
		var strength_value = i["strength_value"]
		var prop = i["Prop"]
		var _wx = i["WX"]
		var box = Global.add_reward_box(item_grid_container, item_name, value)
		if box == null:
			continue
		if tween == null:
			tween = create_tween()
			_box_tween = tween
		box.modulate = Color(1, 1, 1, 0)
		tween.tween_property(box, "modulate", Color(1, 1, 1, 1), 0.2)


func _hide_reward_boxes() -> void:
	item_grid_container.visible = false
	if _box_tween != null and _box_tween.is_valid():
		_box_tween.kill()
	_box_tween = null
	for child in item_grid_container.get_children():
		if child is CanvasItem:
			child.visible = false
		child.queue_free()


func _on_close_pressed() -> void:
	queue_free()
