extends BaseMonster
class_name Monster138
var my_target: BaseMonster
var linked_targets: Array[BaseMonster] = []


func set_linked_targets(targets: Array[BaseMonster]) -> void:
	linked_targets.clear()
	for target in targets:
		if target != null and is_instance_valid(target) and not linked_targets.has(target):
			linked_targets.append(target)
	my_target = linked_targets[0] if not linked_targets.is_empty() else null


func transfer_linked_damage(damage: int) -> void:
	if damage <= 0:
		return
	if linked_targets.is_empty():
		_transfer_damage_to_target(my_target, damage)
		return
	for target in linked_targets:
		_transfer_damage_to_target(target, damage)


func _transfer_damage_to_target(target: BaseMonster, damage: int) -> void:
	if target == null or not is_instance_valid(target) or target.hp <= 0:
		return
	target.has_target = true
	target.reduce_hp(damage)


func _get_primary_target() -> BaseMonster:
	if my_target != null and is_instance_valid(my_target) and my_target.hp > 0:
		return my_target
	for target in linked_targets:
		if target != null and is_instance_valid(target) and target.hp > 0:
			my_target = target
			return target
	my_target = null
	return null


func monster_138():
	self.cannot_attract = true
	self.is_boss = false
	self.my_mr_name = "巫毒娃娃"
	self.attack_in = 90
	self.level = PlayerData.player_data[DataKeys.PLAYER_LEVEL]
	if self.max_hp == 0:
		self.max_hp = 100
		self.hp = self.max_hp

	else:
		self.hp = self.max_hp
	self.hp = self.max_hp
	self.def = 0
	self.mdef = 0
	self.crit = 0
	self.miss = 0
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 9
	self.mysee = 0
	self.attack_range = 0
	self.attack_desire = 0
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 0
	self.obj_attack_dict["hit1"] = {
		"power": 0,
		"hurtBack": [0, 0],
		"attackKind": "",
		"HitProtect": 0,
	}
	self.fall_pro = 0
	self.fall_list = []
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_138()


func _physics_process(delta: float) -> void:
	if hp <= 0:
		mr_player.play("death")
		return
	super._physics_process(delta)
	reset_pro()
	var primary_target := _get_primary_target()
	if primary_target == null:
		self.hp = -100
	else:
		if self.position.x >= primary_target.position.x:
			move_left()
		else:
			move_right()


func ai_think():
	pass


func _on_hurt_box_area_entered(area: Area2D) -> void:
	is_jgz = false
	has_target = true
	var source_player: BaseHero = _get_damage_source_player(area)
	if source_player == null or not is_instance_valid(source_player):
		return
	var source_target: Variant
	if area is BaseRoleHitBox or area is RolehmzBullet:
		source_target = source_player
	elif area is MagicWeaponHit:
		return
	elif area.get_parent() is Role1Shallow:
		source_target = area.get_parent()
	elif area is RoleBullet1:
		source_target = area
	elif area.get_parent().get_parent() is RoleBullet:
		source_target = area.get_parent().get_parent()
	else:
		return
	var old_target: Variant = get_target
	var damage_source_state := bind_role_damage_source(source_player)
	get_target = source_target
	var last_hurt = get_role_last_hurt(source_target) * RoleProp.ws_up_power
	last_hurt *= (0.8 + PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能9"][DataKeys.LEVEL] * 0.005)
	if last_hurt >= hp:
		last_hurt = hp
	hurt_received = last_hurt
	if source_player.is_dead_link:
		source_player.effect_reducehp(last_hurt, "real")
	cure_ws_value(source_player)
	hurt_reduce_hp(last_hurt, source_target)
	transfer_linked_damage(last_hurt)
	Global.total_role_hit += last_hurt
	if (
		source_target is BaseHero
		or source_target is MgHit
		or source_target is Role1Shallow
		or source_target is RoleBullet
	):
		match source_target.hit_dic["attackKind"]:
			"physics":
				Global.total_phy_hit += last_hurt
			"magic":
				Global.total_mag_hit += last_hurt
			"real":
				Global.total_real_hit += last_hurt
	if not is_miss and last_hurt > 0:
		if MainSet.set_data["MonsterLittleBlood"]:
			if monster_blood_bar == null:
				monster_blood_bar = Global.add_monster_blood(self, Vector2(-30, -90), hp / float(max_hp), hp)
		Global.add_sound(self, "res://Music/monster_hurt/6_beattack_by_role1.mp3")
		hurt_special_effect = Global.add_mr_hurt(pz, Vector2(0, 0))
	get_target = old_target
	unbind_role_damage_source(damage_source_state)


func reset_pro():
	var primary_target := _get_primary_target()
	if primary_target != null:
		self.toughness = primary_target.toughness
		self.def = primary_target.def
		self.mdef = primary_target.mdef
		self.crit_reduce = primary_target.crit_reduce
		self.miss = primary_target.miss


func cure_hp(value: int):
	pass


func _on_death_count_timeout() -> void:
	hp = -100


func wd_hurt():
	pass
