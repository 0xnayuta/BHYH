extends BaseMagicWeapon
class_name PurpleGoldBell
var _hit_data := {"power": 0.0, "hurtBack": [5, -5], "attackKind": "physics"}


func _ready() -> void:
	obj_attack_dict["hit1"] = _hit_data


func _physics_process(delta: float) -> void:
	self.fb_level = PlayerData.get_most_level("zjfyd") + 1
	need_mp = 50 + self.fb_level * 15
	if PlayerData.check_have_wx("zjfyd", "木"):
		_hit_data["power"] = 5 + (fb_level - 1) * 0.5
	else:
		_hit_data["power"] = 2.5 + (fb_level - 1) * 0.25
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
	self.usecd = 30
	skill_cd.start(30)


func add_super_armor():
	(
		Global
		. add_buff(
			player.buff,
			{
				"Name": "Indestructible1",
				"AddTime": obj_attack_dict["hit1"]["power"],
				"reduce_interval": 0,
				"value": 0,
				"AttackKind": "",
				"CanRemove": false,
			}
		)
	)

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
