extends BaseLevel
@onready var stop_5: CollisionShape2D = $wall/stop5
@onready var stop_1: CollisionShape2D = $wall/stop1
@onready var stop_2: CollisionShape2D = $wall/stop2
@onready var stop_3: CollisionShape2D = $wall/stop3

@onready var check: Area2D = $Check
@onready var tp: Area2D = $Tp

var hurt_count: int = 0
var is_play: bool = false
var animation_played: bool = false
var can_through: bool = false


func _ready() -> void:
	Global.current_level = "天宫道"
	Global.add_bgm(self, "res://Music/level/floor1_3.mp3")
	self.level_stage = 22
	super._ready()

	$Check/check.disabled = false

	if has_node("Tp/tp"):
		$Tp/tp.disabled = true

	if $yun.has_animation("open"):
		$yun.connect("animation_finished", Callable(self, "_on_animation_finished"))

	monster_group = {
		"stage_1": [74, 75, 74, 75, 74, 75, 74, 75, 74, 75, 74, 75, 74, 75, 74, 75, 74, 75, 74, 75],
		"stage_2":
		[
			74,
			75,
			76,
			74,
			74,
			76,
			74,
			75,
			74,
			75,
			74,
			76,
			74,
			76,
			74,
			76,
			75,
			74,
			74,
			74,
			74,
			75,
			75,
			74,
			74,
			74,
			74,
			74
		],
		"stage_3":
		[
			74,
			75,
			76,
			74,
			74,
			76,
			74,
			75,
			74,
			75,
			74,
			76,
			74,
			76,
			74,
			76,
			75,
			74,
			74,
			74,
			74,
			75,
			75,
			74,
			74,
			74,
			74,
			74,
			76,
			76,
			76,
			76,
			76,
			76,
			76,
			76
		],
		"stage_4": [78, 77],
	}
	monster_position_x = {
		"stage_1":
		[250, 1000, 250, 1000, 250, 1000, 250, 1000, 250, 1000, 250, 1000, 250, 1000, 250, 1000, 250, 1000, 250, 1000],
		"stage_2":
		[
			1200,
			2150,
			1200,
			2150,
			1200,
			2150,
			1200,
			2150,
			1200,
			2150,
			1200,
			2150,
			1200,
			2150,
			1200,
			2150,
			1200,
			2150,
			1200,
			2150,
			1200,
			2150,
			1200,
			2150,
			1200,
			2150,
			1200,
			2150,
			1200,
			2150,
			1200,
			2150
		],
		"stage_3":
		[
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
			2350,
			3400,
		],
		"stage_4": [4450, 3600],
	}
	monster_position_y = {
		"stage_1":
		[
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475
		],
		"stage_2":
		[
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475
		],
		"stage_3":
		[
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475,
			475
		],
		"stage_4": [470, 470],
	}


func _physics_process(delta: float) -> void:
	if hurt_count >= 5 and not animation_played:
		if not is_play:
			if $yun.has_animation("open"):
				$yun.play("open")
				is_play = true

				$Check/check.disabled = true

	super._physics_process(delta)

	if can_through and Input.is_action_pressed("Exit"):
		_transport_to_hidden_level()

	if current_stage >= 1:
		if check_can_pass() and current_stage < 4:
			role_information.gogo.visible = true
		else:
			role_information.gogo.visible = false


func set_through():
	if current_stage == 1:
		if check_can_pass():
			stop_1.disabled = true
	elif current_stage == 2:
		if check_can_pass():
			stop_2.disabled = true
	elif current_stage == 3:
		if check_can_pass():
			stop_3.disabled = true
	elif current_stage == 4:
		my_camera.max_left = 3500
		stop_5.disabled = false


func _on_check_area_entered(area: Area2D) -> void:
	if not $Check/check.disabled:
		hurt_count += 1
		Global.add_mr_hurt($Check, Vector2(0, 0))


func _on_tp_body_entered(body: Node2D) -> void:
	if body is BaseHero:
		can_through = true
		Global.add_message_show(body, "按 W 传送", 1.5, Vector2(0, -200))


func _on_tp_body_exited(body: Node2D) -> void:
	if body is BaseHero:
		can_through = false


func _on_animation_finished(anim_name: String):
	if anim_name == "open":
		animation_played = true

		if has_node("Tp/tp"):
			$Tp/tp.disabled = false


func _transport_to_hidden_level():
	Global.change_scene("res://Scene/level/level_pty.tscn")
