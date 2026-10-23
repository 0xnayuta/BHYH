extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var drop: bool
var my_name: String
var obj_attack_dict = {}
var hit_name


func _get_trap_power() -> float:
	if RoleProp == null or not (RoleProp.roleprop is Dictionary):
		return 0.0
	return float(RoleProp.roleprop.get("SHp", 0.0)) * 0.05


func _physics_process(delta: float) -> void:
	hit_name = my_name
	if obj_attack_dict.is_empty():
		obj_attack_dict = {
			"Trap1": {"power": 0.0, "hurtBack": [15, -15], "attackKind": "real"},
			"Trap2": {"power": 0.0, "hurtBack": [15, -15], "attackKind": "real"},
			"Trap3": {"power": 0.0, "hurtBack": [15, -15], "attackKind": "real"}
		}
	var trap_power: float = _get_trap_power()
	obj_attack_dict["Trap1"]["power"] = trap_power
	obj_attack_dict["Trap2"]["power"] = trap_power
	obj_attack_dict["Trap3"]["power"] = trap_power
	if my_name == "Trap1":
		if not drop:
			animation_player.play("Trap2")
	if my_name == "Trap3":
		animation_player.play("Trap3")


func _on_area_2d_area_entered(area: Area2D, _extra = null) -> void:
	if my_name == "Trap1":
		drop = true
		animation_player.play("Trap1")
		await animation_player.animation_finished
		animation_player.play("Trap2")
		drop = false


func _on_hit_box_area_entered(area: Area2D, _extra = null) -> void:
	var target = area.get_parent().get_parent()
	if target is BaseHero:
		target.reduce_hp(_get_trap_power(), self, self)
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
