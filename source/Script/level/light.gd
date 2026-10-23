extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var is_light: bool = false
var current_level: String = ""
var is_activated: bool = false


func _ready() -> void:
	var scene_path = get_tree().current_scene.scene_file_path if get_tree().current_scene else ""

	if "Level_28" in scene_path:
		configure_for_level("Level_28")
	elif "Level_34" in scene_path:
		configure_for_level("Level_34")
	else:
		configure_for_level("default")


func configure_for_level(level_id: String) -> void:
	current_level = level_id
	match current_level:
		"Level_28":
			visible = true
			modulate = Color.WHITE
			print("Light: 当前在Level_28，使用双动画模式")
		"Level_34":
			print("Light: 当前在Level_34，使用单动画模式")
			_set_initial_state_for_level34()
		_:
			visible = true
			modulate = Color.WHITE
			print("Light: 当前在未知关卡，使用默认模式")


func _set_initial_state_for_level34() -> void:
	is_light = false
	is_activated = false

	modulate = Color(1.0, 1.0, 1.0, 0.0)

	animation_player.stop()


func _physics_process(delta: float) -> void:
	match current_level:
		"Level_28":
			_update_level_28_animation()
		"Level_34":
			_update_level_34_animation()
		_:
			_update_default_animation()


func _update_level_28_animation() -> void:
	if is_light:
		if animation_player.has_animation("Light2"):
			animation_player.play("Light2")
		else:
			animation_player.play("RESET")
	else:
		if animation_player.has_animation("Light1"):
			animation_player.play("Light1")
		else:
			animation_player.play("RESET")


func _update_level_34_animation() -> void:
	if is_activated and is_light:
		visible = true
		modulate = Color(1.0, 1.0, 1.0, 1.0)

		if animation_player.has_animation("Light3"):
			animation_player.play("Light3")
		else:
			print("警告: Level_34的灯没有找到light3动画")
	else:
		modulate = Color(1.0, 1.0, 1.0, 0.0)
		animation_player.stop()


func _update_default_animation() -> void:
	if is_light:
		animation_player.play("Light2")
	else:
		animation_player.play("Light1")


func _on_area_2d_area_entered(area: Area2D) -> void:
	if current_level == "Level_28":
		is_light = not is_light
		Global.add_mr_hurt($Area2D, Vector2(0, 0))
		print("Level_28: 灯状态切换为: ", is_light)

	elif current_level == "Level_34":
		if not is_activated:
			if _is_attack_area(area):
				is_activated = true
				is_light = true
				Global.add_mr_hurt($Area2D, Vector2(0, 0))
				print("Level_34: 灯被攻击点亮")
			else:
				print("Level_34: 灯需要被攻击才能点亮")


func _is_attack_area(area: Area2D) -> bool:
	if area.is_in_group("attack") or area.is_in_group("bullet") or area.is_in_group("player_attack"):
		return true

	var parent = area.get_parent()
	if parent:
		if parent.is_in_group("player") or parent.is_in_group("player_weapon"):
			return true
		if "attack" in parent.name.to_lower() or "bullet" in parent.name.to_lower():
			return true

	return true
