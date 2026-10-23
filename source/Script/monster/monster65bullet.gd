extends Node2D
var get_player: BaseHero
var add_count: int = 0
var att_list: Dictionary = {}
var hit_name: String = ""
var dir: bool = false
var skill_name: String = ""
var speed: float = 0.0
@onready var pler: AnimationPlayer = $Pler


func _ready():
	set_meta("is_monster_bullet", true)
	pler.play("wang")


func _physics_process(delta: float) -> void:
	if get_player != null:
		get_player.velocity.x = 0
		get_player.velocity.y = 0

	if add_count % 30 == 0:
		if get_player != null:
			(
				Global
				. add_buff(
					get_player.buff,
					{
						"Name": "speed_down",
						"AddTime": 2,
						"reduce_interval": 0,
						"value": 0.6,
						"AttackKind": "",
					}
				)
			)

			(
				Global
				. add_buff(
					get_player.buff,
					{
						"Name": "silent",
						"AddTime": 2,
						"reduce_interval": 0,
						"value": 0.3,
						"AttackKind": "",
						"CanAdd": false,
						"DeBuff": true,
					}
				)
			)
	add_count += 1


func _on_check_body_entered(body: Node2D) -> void:
	if body is BaseHero:
		get_player = body

		(
			Global
			. add_buff(
				body.buff,
				{
					"Name": "speed_down",
					"AddTime": 2,
					"reduce_interval": 0,
					"value": 0.6,
					"AttackKind": "",
				}
			)
		)

		(
			Global
			. add_buff(
				body.buff,
				{
					"Name": "silent",
					"AddTime": 2,
					"reduce_interval": 0,
					"value": 0.3,
					"AttackKind": "",
					"CanAdd": false,
					"DeBuff": true,
				}
			)
		)


func _on_check_body_exited(body: Node2D) -> void:
	get_player = null


func _on_hit_box_area_entered(area: Area2D) -> void:
	var target = area.get_parent().get_parent()
