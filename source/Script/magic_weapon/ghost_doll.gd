extends BaseMagicWeapon
class_name GhostDoll
var follow_target: BaseMonster
var monster_list = []
var _monster_refresh_elapsed: float = 0.0
var hit_times: int = 0
var max_times: int = 0
var is_begin: bool
var _hit_data := {"power": 0, "hurtBack": [1, -2], "attackKind": "magic"}


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
	self.fb_level = PlayerData.get_most_level("xhmt") + 1
	if PlayerData.check_have_wx("xhmt", "木"):
		_hit_data["power"] = int(25 + RoleProp.roleprop.power * (0.15 + (self.fb_level * 0.03)))
		max_times = 5 + int(self.fb_level / 3)
	else:
		_hit_data["power"] = int(12 + RoleProp.roleprop.power * (0.07 + (self.fb_level * 0.02)))
		max_times = 3 + int(self.fb_level / 3)
	need_mp = 25 + self.fb_level * 5
	super._physics_process(delta)
	if hit_times > 0:
		get_target()
		if follow_target != null:
			if not is_begin:
				var changepp: Vector2
				var tween = get_tree().create_tween()
				changepp = Vector2(0, 112)
				tween.tween_property(self, "position", follow_target.position - changepp, 0.25)
				is_begin = true
		else:
			use_over()
		if is_begin:
			mg_player.play("hit")
			await mg_player.animation_finished
			change_dir()
			is_begin = false
			get_target()
			if hit_times <= 0:
				use_over()


func change_dir():
	if follow_target != null:
		if follow_target is BaseMonster:
			if self.position.x > follow_target.position.x:
				scale.x = 1
				self.self_dir = false
			else:
				self.self_dir = true
				scale.x = -1


func show_skill():
	var a_1
	var monster: BaseMonster = null
	var a_2 = 0
	var monster_2: BaseMonster = null
	var a_3
	Global.remove_all_active_buffs()
	mg_player.play("Show")
	await mg_player.animation_finished
	a_1 = 5000
	a_2 = 0
	while a_2 < monster_list.size():
		if monster_list[a_2] != null and monster_list[a_2] is BaseMonster:
			monster_2 = monster_list[a_2]
		else:
			use_over()
			follow_target = null
			return null
		if monster_2 == null:
			use_over()
			follow_target = null
			return null
		if monster_2 is Monster138:
			a_2 += 1
			continue
		a_3 = Global.get_dis_betweem(player, monster_2)
		if a_3 <= a_1:
			a_1 = a_3
			if monster_2 is Monster48:
				if monster_2.change_body_flag:
					use_over()
					follow_target = null
					return null
			monster = monster_2
		a_2 += 1
	if monster != null:
		follow_target = monster
		fb_cd = 5
		hit_times = max_times
	change_dir()
	if follow_target == null:
		RoleProp.roleprop.Mp += need_mp
		use_over()


func get_target():
	var a_1
	var monster: BaseMonster = null
	var a_2 = 0
	var monster_2: BaseMonster = null
	var a_3
	a_1 = 1000
	a_2 = 0
	while a_2 < monster_list.size():
		if monster_list[a_2] != null and monster_list[a_2] is BaseMonster:
			monster_2 = monster_list[a_2]
		else:
			use_over()
			follow_target = null
			return null
		if monster_2 == null:
			use_over()
			follow_target = null
			return null
		if monster_2 is Monster138:
			a_2 += 1
			continue
		a_3 = Global.get_dis_betweem(player, monster_2)
		if a_3 <= a_1:
			a_1 = a_3
			if monster_2 is Monster48:
				if monster_2.change_body_flag:
					follow_target = null
					use_over()
					return null
			monster = monster_2
		a_2 += 1
	if monster != null:
		if not monster_2 is Monster138:
			follow_target = monster


func use_over():
	follow_target = null
	hit_times = 0
	is_begin = false
	is_use = false
	if PlayerData.check_have_wx("xhmt", "木"):
		self.usecd = 6
		skill_cd.start(6)
	else:
		self.usecd = 12
		skill_cd.start(12)
	self.visible = false


func reduce_times():
	hit_times -= 1


func ghost_bullet_1():
	var gh_1
	var attack_data := get_attack_snapshot()
	if self.self_dir:
		gh_1 = Global.add_weapon_bullet(self, Vector2(-60, 0), "GhostDollBullet_1", attack_data, self.self_dir, 100)
	else:
		gh_1 = Global.add_weapon_bullet(self, Vector2(-60, 0), "GhostDollBullet_1", attack_data, !self.self_dir, 100)


func ghost_bullet_2():
	var attack_data := get_attack_snapshot()
	if self.self_dir:
		Global.add_weapon_bullet(self, Vector2(-60, 0), "GhostDollBullet_2", attack_data, self.self_dir, 100)
	else:
		Global.add_weapon_bullet(self, Vector2(-60, 0), "GhostDollBullet_2", attack_data, !self.self_dir, 100)


func ghost_bullet_3():
	var attack_data := get_attack_snapshot()
	if self.self_dir:
		Global.add_weapon_bullet(self, Vector2(-60, 30), "GhostDollBullet_3", attack_data, !self.self_dir, 100)
	else:
		Global.add_weapon_bullet(self, Vector2(-60, 30), "GhostDollBullet_3", attack_data, self.self_dir, 100)


func _on_check_monster_body_entered(body: Node2D) -> void:
	pass


func free() -> void:
	follow_target = null


func _on_skill_cd_timeout() -> void:
	super._on_skill_cd_timeout()
	self.visible = true

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
