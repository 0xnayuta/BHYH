extends CanvasLayer
var show_czzn: bool
var show_yxxq: bool
var show_yxgg: bool
var title: String
@onready var czzn: MarginContainer = %czzn
@onready var yxxq: MarginContainer = %yxxq
@onready var yxgg: MarginContainer = %yxgg
@onready var _title: Label = %title


func _ready() -> void:
	show_czzn = true
	show_yxxq = false
	show_yxgg = false
	_title.text = "操作指南"


func _physics_process(_delta: float) -> void:
	if show_czzn:
		_title.text = "操作指南"
		czzn.visible = true
	else:
		czzn.visible = false
	if show_yxgg:
		_title.text = "游戏公告"
		yxgg.visible = true
	else:
		yxgg.visible = false
	if show_yxxq:
		_title.text = "游戏详情"
		yxxq.visible = true
	else:
		yxxq.visible = false


func _on_czzn_pressed() -> void:
	Global.add_some_monster_help(self, Vector2(0, 0))
	return


func _on_yxxq_pressed() -> void:
	return


func _on_yxgg_pressed() -> void:
	return


func _on_close_pressed() -> void:
	queue_free()
