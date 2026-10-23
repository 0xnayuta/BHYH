extends BaseMagicWeapon
class_name PurpleGlodCucurbit
var _hit_data := {
	"power": 0,
	"hurtBack": [0, 0],
	"attackKind": "physics",
	"WSValue": 0,
	"addeffect": {"Name": "Fire", "AddTime": 5, "reduce_interval": 1, "value": 0, "AttackKind": "real", "CanAdd": true}
}


func _ready() -> void:
	obj_attack_dict["hit1"] = _hit_data


func _physics_process(delta: float) -> void:
	self.fb_level = PlayerData.get_most_level("zjhl")
	need_mp = 50 + self.fb_level * 12
	var power: int
	var player_power = RoleProp.roleprop.power
	if PlayerData.check_have_wx("zjhl", "木"):
		power = (
			int(player_power * randf_range(0.15, 0.2)) + int(player_power * (randf_range(0.08, 0.1) * self.fb_level))
		)
	else:
		power = (
			int(player_power * randf_range(0.08, 0.1)) + int(player_power * (randf_range(0.05, 0.07) * self.fb_level))
		)
	_hit_data["power"] = power
	_hit_data["WSValue"] = randi_range(15, 20)
	var add_effect: Dictionary = _hit_data["addeffect"]
	add_effect["value"] = int(RoleProp.roleprop.power * 0.1)
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
	if PlayerData.check_have_wx("zjhl", "木"):
		self.usecd = 12
		skill_cd.start(12)
	else:
		self.usecd = 1
		skill_cd.start(1)


func cucurbit_fire():
	var attack_data := get_attack_snapshot()
	if self.self_dir:
		Global.add_weapon_bullet(self, Vector2(-30, 10), "PurpleGlodCucurbitBullet", attack_data, self.self_dir, 10)
	else:
		Global.add_weapon_bullet(self, Vector2(-30, 10), "PurpleGlodCucurbitBullet", attack_data, !self.self_dir, 10)

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
