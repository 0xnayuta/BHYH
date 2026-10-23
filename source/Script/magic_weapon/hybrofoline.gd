extends BaseMagicWeapon
class_name Hybrofoline
var is_cure: bool
var _hit_data := {"power": 0, "hurtBack": [5, -5], "attackKind": "physics"}


func _ready() -> void:
	obj_attack_dict["hit1"] = _hit_data


func _physics_process(delta: float) -> void:
	if is_cure:
		self.position = player.position - Vector2(0, 200)
	self.fb_level = PlayerData.get_most_level("kyl") + 1
	need_mp = 50 + self.fb_level * 5
	if PlayerData.check_have_wx("kyl", "木"):
		_hit_data["power"] = 100 + int(RoleProp.roleprop.SHp * (randf_range(0.02, 0.05)) + 0.02 * self.fb_level)
	else:
		_hit_data["power"] = 50 + int(RoleProp.roleprop.SHp * (randf_range(0.01, 0.02)) + 0.01 * self.fb_level)
	super._physics_process(delta)
	if not is_use:
		mg_player.play("wait")


func show_skill():
	mg_player.play("hit")
	await mg_player.animation_finished
	use_over()


func use_over():
	is_cure = false
	fb_cd = 1
	is_use = false
	self.usecd = 15
	skill_cd.start(15)


func cure():
	if player != null:
		player.cure_hp(obj_attack_dict["hit1"]["power"])


func add_super_armor():
	is_cure = true
	(
		Global
		. add_buff(
			player.buff,
			{
				"Name": "SuperArmor",
				"AddTime": 10,
				"reduce_interval": 0,
				"value": 0,
				"AttackKind": "",
			}
		)
	)

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
