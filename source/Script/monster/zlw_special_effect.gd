extends Node2D
@onready var lunzi_4: AnimatedSprite2D = $Lunzi_4
@onready var lunzi_3: AnimatedSprite2D = $Lunzi_3
@onready var lunzi_1: AnimatedSprite2D = $Lunzi_1
@onready var lunzi_2: AnimatedSprite2D = $Lunzi_2
@onready var lunzi_5: AnimatedSprite2D = $Lunzi_5
@onready var lunzi_6: AnimatedSprite2D = $Lunzi_6

var current_count: int = 6:
	set(value):
		current_count = value
		_on_round_change()
var state: bool = false:
	set(value):
		state = value
		change_position()
var speed: float = 1:
	set(value):
		speed = value
		set_speed()
var round_position_1 = [
	Vector2(0, 0), Vector2(0, 0), Vector2(35, 0), Vector2(60, 0), Vector2(35, -100), Vector2(60, 60)
]
var round_position_2 = [
	Vector2(0, -90), Vector2(0, -90), Vector2(50, -85), Vector2(-45, -135), Vector2(65, -130), Vector2(35, -160)
]
var lunzi_list: Array = []


func _ready() -> void:
	lunzi_list = [lunzi_1, lunzi_2, lunzi_3, lunzi_4, lunzi_5, lunzi_6]


func _on_round_change():
	if current_count == 6:
		lunzi_1.visible = true
		lunzi_2.visible = true
		lunzi_3.visible = true
		lunzi_4.visible = true
		lunzi_5.visible = true
		lunzi_6.visible = true
	elif current_count == 5:
		lunzi_1.visible = true
		lunzi_2.visible = false
		lunzi_3.visible = true
		lunzi_4.visible = true
		lunzi_5.visible = true
		lunzi_6.visible = true
	elif current_count == 4:
		lunzi_1.visible = true
		lunzi_2.visible = false
		lunzi_3.visible = false
		lunzi_4.visible = true
		lunzi_5.visible = true
		lunzi_6.visible = true
	elif current_count == 3:
		lunzi_1.visible = true
		lunzi_2.visible = false
		lunzi_3.visible = false
		lunzi_4.visible = false
		lunzi_5.visible = true
		lunzi_6.visible = true
	elif current_count == 2:
		lunzi_1.visible = true
		lunzi_2.visible = false
		lunzi_3.visible = false
		lunzi_4.visible = false
		lunzi_5.visible = false
		lunzi_6.visible = true
	elif current_count == 1:
		lunzi_1.visible = true
		lunzi_2.visible = false
		lunzi_3.visible = false
		lunzi_4.visible = false
		lunzi_5.visible = false
		lunzi_6.visible = false
	elif current_count == 0:
		lunzi_1.visible = false
		lunzi_2.visible = false
		lunzi_3.visible = false
		lunzi_4.visible = false
		lunzi_5.visible = false
		lunzi_6.visible = false


func change_position():
	var count: int = 0
	var list: Array
	if state:
		list = round_position_1
	else:
		list = round_position_2
	for i in lunzi_list:
		i.position = list[count]
		count += 1


func set_speed():
	var num: int = 0
	var speed_list = [-0.8, 1.5, 1.2, -1.4, 1.8, 3]
	for i in lunzi_list:
		if speed != 1:
			i.speed_scale = i.speed_scale * speed
		else:
			i.speed_scale = speed_list[num]
			num += 1
