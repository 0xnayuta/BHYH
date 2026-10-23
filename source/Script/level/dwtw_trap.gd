extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var hit_name
var _get_name
var is_hit: bool
var is_play
var total_hit = 0
var obj_attack_dict = {}
var player
var hit_count: int = 0


func _physics_process(delta: float) -> void:
	var parent_node = get_parent().get_parent()
	player = parent_node._role
	if not is_hit:
		hit_count = 0
		animation_player.play("wait")
	else:
		if hit_count % 240 == 0:
			animation_player.play("hit")
		hit_count += 1


func _on_hit_box_area_entered(area: Area2D) -> void:
	hit_name = "Trap_1"
	self.obj_attack_dict["Trap_1"] = {
		"power": int(RoleProp.roleprop.SHp * 0.05), "hurtBack": [15, -15], "attackKind": "real"
	}
	if player is BaseHero:
		(
			Global
			. add_buff(
				player.buff,
				{
					"Name": "speed_down",
					"AddTime": 2,
					"reduce_interval": 0,
					"value": 0.35,
					"AttackKind": "",
					"CanAdd": false,
					"DeBuff": true,
				},
			)
		)
	var target = area.get_parent().get_parent()
	if target is BaseHero:
		target.reduce_hp(obj_attack_dict[hit_name]["power"], self, self)
		if RoleProp.is_ws_state:
			return
		if target is Role3Hero:
			if target.is_sd_buff:
				return
		if target is Role3Hero:
			if target.is_t_mc:
				return
		target.state_behit()
		if randi_range(0, 100) < 50:
			target.attack_to_left(self, self)
		else:
			target.attack_to_right(self, self)


func _on_check_area_entered(area: Area2D) -> void:
	is_hit = true


func _on_check_area_exited(area: Area2D) -> void:
	is_hit = false
