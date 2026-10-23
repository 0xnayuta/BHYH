extends BaseMagicWeapon
class_name Sword
var bl = 30
var _hit_data := {
	"power": 0,
	"hurtBack": [8, -5],
	"attackKind": "magic",
	"addeffect": {"Name": "Ice", "AddTime": 0.0, "reduce_interval": 0, "value": 0, "AttackKind": "", "DeBuff": true}
}


func _ready() -> void:
	obj_attack_dict["hit1"] = _hit_data


func _physics_process(delta: float) -> void:
	need_mp = 30 + 10 * self.fb_level
	self.fb_level = PlayerData.get_most_level("tsgj") + 1
	var add_effect: Dictionary = _hit_data["addeffect"]
	if PlayerData.check_have_wx("tsgj", "木"):
		_hit_data["power"] = 100 + int(RoleProp.roleprop.power * randf_range(0.28, 0.35)) + 50 * self.fb_level
		add_effect["AddTime"] = 3 + 0.18 * self.fb_level
	else:
		_hit_data["power"] = 100 + int(RoleProp.roleprop.power * randf_range(0.15, 0.2)) + 100 * self.fb_level
		add_effect["AddTime"] = 1 + 0.18 * self.fb_level
	super._physics_process(delta)


func show_skill():
	fb_cd = 3
	mg_player.play("hit")
	await mg_player.animation_finished
	use_over()


func use_over():
	is_use = false
	self.usecd = 15
	skill_cd.start(15)


func add_sword():
	var attack_data := get_attack_snapshot()
	Global.add_weapon_bullet($Bullet, Vector2(self.position.x, 0), "SwordBullet", attack_data, mg_action.flip_h, bl)
	Global.add_weapon_bullet(
		$Bullet, Vector2(self.position.x - 100, 0), "SwordBullet", attack_data, mg_action.flip_h, bl
	)
	Global.add_weapon_bullet(
		$Bullet, Vector2(self.position.x + 100, 0), "SwordBullet", attack_data, mg_action.flip_h, bl
	)
	await get_tree().create_timer(0.1, false).timeout
	attack_data = get_attack_snapshot()
	Global.add_weapon_bullet(
		$Bullet, Vector2(self.position.x - 200, 0), "SwordBullet", attack_data, mg_action.flip_h, bl
	)
	Global.add_weapon_bullet(
		$Bullet, Vector2(self.position.x + 200, 0), "SwordBullet", attack_data, mg_action.flip_h, bl
	)
	await get_tree().create_timer(0.1, false).timeout
	attack_data = get_attack_snapshot()
	Global.add_weapon_bullet(
		$Bullet, Vector2(self.position.x - 300, 0), "SwordBullet", attack_data, mg_action.flip_h, bl
	)
	Global.add_weapon_bullet(
		$Bullet, Vector2(self.position.x + 300, 0), "SwordBullet", attack_data, mg_action.flip_h, bl
	)
	await get_tree().create_timer(0.1, false).timeout
	attack_data = get_attack_snapshot()
	Global.add_weapon_bullet(
		$Bullet, Vector2(self.position.x - 400, 0), "SwordBullet", attack_data, mg_action.flip_h, bl
	)
	Global.add_weapon_bullet(
		$Bullet, Vector2(self.position.x + 400, 0), "SwordBullet", attack_data, mg_action.flip_h, bl
	)

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
