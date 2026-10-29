extends Node2D
const DIGIT_ADVANCE := 20

@onready var show_player: AnimationPlayer = $ShowPlayer
@onready var number: HBoxContainer = $Midlle/Number

var damage_value: int
var type: String
var is_set: bool = false
var is_crit: bool
var target: BaseObject
var _recycled: bool = false
var _digit_nodes: Array[TextureRect] = []


func setup(value, type_, crit: bool, tar) -> void:
	damage_value = int(value)
	type = str(type_)
	is_crit = crit
	target = tar
	_recycled = false
	visible = true
	modulate.a = 1.0
	z_index = 100
	_hide_digit_nodes()
	number.add_theme_constant_override("separation", 0)
	call_deferred("_start")


func change_number():
	if target != null and not is_instance_valid(target):
		target = null
	var loc_2 = str(damage_value)
	var loc_1 = loc_2.split("")
	var digit_index := 0
	var widest_texture := 0
	for i in loc_1:
		var digit := _get_digit_node(digit_index)
		if digit == null:
			return
		digit_index += 1
		digit.visible = true
		digit.target = target if is_instance_valid(target) else null
		digit.is_crit = is_crit
		digit.type = type
		digit.need_number = int(i)
		digit.changepic(type, int(i), is_crit)
		if digit.texture != null:
			widest_texture = maxi(widest_texture, digit.texture.get_width())
	if widest_texture > 0:
		number.add_theme_constant_override("separation", DIGIT_ADVANCE - widest_texture)


func _get_digit_node(index: int) -> TextureRect:
	if index < _digit_nodes.size():
		return _digit_nodes[index]
	var digit = Global.add_damage_number(number, 0, type, is_crit, target if is_instance_valid(target) else null)
	if digit == null:
		return null
	digit.set_physics_process(false)
	_digit_nodes.append(digit)
	return digit


func _hide_digit_nodes() -> void:
	for digit in _digit_nodes:
		if digit != null and is_instance_valid(digit):
			digit.visible = false
			digit.target = null


func _ready() -> void:
	pass


func prepare_for_pool() -> void:
	_recycled = true
	visible = false
	target = null
	type = "physics"
	is_crit = false
	show_player.stop()
	for digit_index in range(10):
		_get_digit_node(digit_index)
	_hide_digit_nodes()


func _start() -> void:
	if _recycled:
		return
	change_number()
	if target != null:
		if target is BaseHero:
			if is_crit:
				show_player.play("Crit")
			else:
				show_player.play("physics")
		else:
			show_player.play("physics")


func recycle() -> void:
	if _recycled:
		return
	_recycled = true
	if Global != null and Global.has_method("recycle_damage_text"):
		Global.recycle_damage_text(self)
	else:
		queue_free()
