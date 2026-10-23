extends Node2D
var hit_count: int = 0
@onready var hurt_box: Area2D = $Hurt_box
@onready var show_bai_gu = $Show
@onready var check_area = $CheckIn/CheckIN
@onready var _await: Timer = $Await
var is_set = false
var is_can_in = false


func _ready() -> void:
	randomize()
	show_message()


func _on_hurt_box_area_entered(area: Area2D) -> void:
	hit_count += 1
	Global.add_mr_hurt(hurt_box, Vector2(0, 0))


func _physics_process(delta: float) -> void:
	if hit_count >= 5:
		if not is_set:
			show_bai_gu.play("Show")
	if is_can_in:
		if _await.is_stopped():
			_await.start(randi_range(4, 6))
	else:
		_await.stop()


func show_message():
	var hurt_box_list = [Vector2(0, 0), Vector2(-90, -65), Vector2(150, -40), Vector2(0, -110)]
	hurt_box.position = hurt_box_list[randi_range(0, 3)]
	check_area.disabled = true
	$BaiGu.visible = true
	$Hide.visible = true
	$Hurt_box/Hurt_.disabled = false


func show_and_hide_info():
	is_set = true
	check_area.disabled = false
	$BaiGu.visible = true
	$Hide.visible = false
	$Hurt_box/Hurt_.disabled = true


func _on_check_in_body_entered(body: Node2D) -> void:
	is_can_in = true


func _on_check_in_body_exited(body: Node2D) -> void:
	is_can_in = false


func _on_await_timeout() -> void:
	if is_can_in:
		_await.stop()
		Global.change_scene("res://Scene/level/level_bgmj.tscn")
