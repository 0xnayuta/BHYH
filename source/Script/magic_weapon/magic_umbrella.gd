extends BaseMagicWeapon
class_name MagicUmbrella
var stab_rotation_list = [-5, -5, -5, -5, -5, -5, -5, -5, -5, -5, 0, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5]
var bullet_spawn_positions = [
	150, 135, 120, 105, 90, 75, 60, 45, 30, 15, 0, -15, -30, -45, -60, -75, -90, -105, -120, -135, -150
]
var _hit_data := {
	"power": 0,
	"hurtBack": [5, -5],
	"attackKind": "real",
	"addeffect":
	{
		"Name": "poision",
		"AddTime": 5,
		"reduce_interval": 1,
		"value": 0,
		"AttackKind": "real",
		"CanAdd": true,
		"DeBuff": true
	}
}


func _ready() -> void:
	obj_attack_dict["hit1"] = _hit_data


func _physics_process(delta: float) -> void:
	self.fb_level = PlayerData.get_most_level("lsys") + 1
	need_mp = 30 + self.fb_level * 10
	_hit_data["power"] = 10 + 10 * self.fb_level
	var add_effect: Dictionary = _hit_data["addeffect"]
	if PlayerData.check_have_wx("lsys", "木"):
		add_effect["value"] = int(RoleProp.roleprop.power * (0.04 + 0.04 * self.fb_level))
	else:
		add_effect["value"] = int(RoleProp.roleprop.power * (0.04 + 0.01 * self.fb_level))
	super._physics_process(delta)
	if not is_use:
		mg_player.play("wait")


func show_skill():
	mg_player.play("hit")
	await mg_player.animation_finished
	use_over()


func use_over():
	fb_cd = 1
	is_use = false
	skill_cd.start(3)


func add_bullet():
	var attack_data := get_attack_snapshot()
	for i in range(21):
		var stab = Global.add_weapon_bullet(
			$Bullet,
			Vector2(self.position.x + bullet_spawn_positions[i], self.position.y),
			"MagicUmbrellaBullet",
			attack_data,
			mg_action.flip_h,
			100
		)
		stab.rotation_degrees = stab_rotation_list[i]
		stab.scale = Vector2(2, 2)


func tween_to_top():
	var po = self.position
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", player.position + Vector2(0, -400), 0.8)
	pass

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
