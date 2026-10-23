extends Node2D
@onready var lz_1: AnimatedSprite2D = $LZ_1
@onready var lz_2: AnimatedSprite2D = $LZ_2
@onready var lz_4: AnimatedSprite2D = $LZ_4
@onready var lz_3: AnimatedSprite2D = $LZ_3
@onready var lz_6: AnimatedSprite2D = $LZ_6
@onready var lz_5: AnimatedSprite2D = $LZ_5
@onready var lz_8: AnimatedSprite2D = $LZ_8
@onready var lz_7: AnimatedSprite2D = $LZ_7

var current_count: int = 8:
	set(value):
		current_count = value
		_on_round_change()
var speed: float = 1:
	set(value):
		speed = value
		set_speed()
var lunzi_list: Array = []


func _ready() -> void:
	lunzi_list = [lz_1, lz_2, lz_3, lz_4, lz_5, lz_6, lz_7, lz_8]


func _on_round_change():
	if current_count == 6:
		lz_1.visible = true
		lz_2.visible = true
		lz_3.visible = true
		lz_4.visible = true
		lz_5.visible = true
		lz_6.visible = true
		lz_7.visible = false
		lz_8.visible = false
	elif current_count == 5:
		lz_1.visible = true
		lz_2.visible = false
		lz_3.visible = true
		lz_4.visible = true
		lz_5.visible = true
		lz_6.visible = true
		lz_7.visible = false
		lz_8.visible = false
	elif current_count == 4:
		lz_1.visible = true
		lz_2.visible = false
		lz_3.visible = false
		lz_4.visible = true
		lz_5.visible = true
		lz_6.visible = true
		lz_7.visible = false
		lz_8.visible = false
	elif current_count == 3:
		lz_1.visible = true
		lz_2.visible = false
		lz_3.visible = false
		lz_4.visible = false
		lz_5.visible = true
		lz_6.visible = true
		lz_7.visible = false
		lz_8.visible = false
	elif current_count == 2:
		lz_1.visible = true
		lz_2.visible = false
		lz_3.visible = false
		lz_4.visible = false
		lz_5.visible = false
		lz_6.visible = true
		lz_7.visible = false
		lz_8.visible = false
	elif current_count == 1:
		lz_1.visible = true
		lz_2.visible = false
		lz_3.visible = false
		lz_4.visible = false
		lz_5.visible = false
		lz_6.visible = false
		lz_7.visible = false
		lz_8.visible = false
	elif current_count == 0:
		lz_1.visible = false
		lz_2.visible = false
		lz_3.visible = false
		lz_4.visible = false
		lz_5.visible = false
		lz_6.visible = false
		lz_7.visible = false
		lz_8.visible = false
	elif current_count == 7:
		lz_1.visible = true
		lz_2.visible = true
		lz_3.visible = true
		lz_4.visible = true
		lz_5.visible = true
		lz_6.visible = true
		lz_7.visible = true
		lz_8.visible = false
	elif current_count == 8:
		lz_1.visible = true
		lz_2.visible = true
		lz_3.visible = true
		lz_4.visible = true
		lz_5.visible = true
		lz_6.visible = true
		lz_7.visible = true
		lz_8.visible = true


func set_speed():
	var num: int = 0
	for i in lunzi_list:
		if speed != 1:
			i.speed_scale = i.speed_scale * speed
		else:
			i.speed_scale = 0.7
			num += 1
