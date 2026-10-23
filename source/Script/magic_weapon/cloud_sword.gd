extends BaseMagicWeapon
class_name CloudSword
var monster_list: Array = []
var _monster_refresh_elapsed: float = 0.0
var target: BaseMonster
var is_no_target: bool
var _hit_data := {
	"power": 0,
	"hurtBack": [0, -1],
	"attackKind": "magic",
	"addeffect":
	{"Name": "defe_reduce", "AddTime": 5, "reduce_interval": 0, "value": 0.0, "AttackKind": "", "DeBuff": true}
}


func _ready() -> void:
	obj_attack_dict["hit1"] = _hit_data


func _get_active_monster_snapshot() -> Array:
	var level: Node = player.get_parent().get_parent() if player != null and player.get_parent() != null else null
	if level != null and level.has_method("has_active_monster_index") and level.has_active_monster_index():
		return level.get_active_monsters()
	if level != null and "monster" in level and level.monster != null:
		return level.monster.get_children()
	return []


func _physics_process(delta: float) -> void:
	_monster_refresh_elapsed += delta
	if _monster_refresh_elapsed >= 0.1 or monster_list.is_empty():
		_monster_refresh_elapsed = 0.0
		monster_list = _get_active_monster_snapshot()
	self.fb_level = PlayerData.get_most_level("qyj") + 1
	need_mp = 80 + self.fb_level * 5
	var basic_hit
	basic_hit = self.fb_level * 0.07
	var add_effect: Dictionary = _hit_data["addeffect"]
	if PlayerData.check_have_wx("qyj", "木"):
		basic_hit = self.fb_level * 0.1
		_hit_data["power"] = 100 + int(RoleProp.roleprop.power * basic_hit)
		add_effect["value"] = 0.09 + (0.01 * fb_level)
	else:
		basic_hit = self.fb_level * 0.05
		_hit_data["power"] = 50 + int(RoleProp.roleprop.power * basic_hit)
		add_effect["value"] = 0.04 + (0.01 * fb_level)
	super._physics_process(delta)
	if not is_use:
		mg_player.play("wait")


func show_skill():
	target = get_monster()
	if target == null:
		use_over2()
		return
	mg_player.play("hit")
	await mg_player.animation_finished
	use_over()


func use_over():
	self.usecd = 15
	is_use = false
	fb_cd = 1
	skill_cd.start(self.usecd)


func use_over2():
	self.usecd = 0
	is_use = false
	fb_cd = 1
	RoleProp.roleprop.Mp += need_mp
	skill_cd.start(0.001)


func get_monster():
	var max_hp = 0
	var tt: BaseMonster
	if monster_list.size() <= 0:
		return null
	for i in monster_list:
		if i != null:
			if not i.no_target:
				if i is BaseMonster:
					if not i is Monster138:
						if i.hp >= max_hp:
							tt = i
							max_hp = i.hp
	return tt


func add_sword():
	if target != null:
		Global.add_weapon_bullet(
			$Bullet, target.position + Vector2(0, 30), "CloudSwordBullet", get_attack_snapshot(), mg_action.flip_h, 100
		)

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
