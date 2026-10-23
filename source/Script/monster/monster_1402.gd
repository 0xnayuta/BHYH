extends BaseMonster

var should_fly: bool
var is_call: bool
var onset_eatblood: bool
var remove_blood: bool

var summoned_monsters: Array = []
var can_summon: bool = true
var summon_cooldown: float = 0
const SUMMON_COOLDOWN_TIME: float = 30.0


func monster_1402():
	self.rush_speed = 450
	self.is_boss = true
	self.my_mr_name = "狻猊圣者·杨森"
	self.attack_in = 100
	self.level = 56
	self.max_hp = 750000
	self.hp = self.max_hp
	self.def = 440
	self.mdef = 440
	self.crit = 20
	self.miss = 40
	self.lucky = 50
	self.htarget = 85
	self.toughness = 10
	self.ar = 70
	self.sp = 70
	self.crit_reduce = 8
	self.speed = 14
	self.mysee = 550
	self.attack_range = 375
	self.attack_desire = 80
	self.behit_calmtime = 0.16
	self.self_rhp = 0
	self.add_exp = 3000
	self.fall_coin = 1200
	self.ebol = 0

	self.obj_attack_dict["hit1"] = {
		"power": 600,
		"hurtBack": [15, -12],
		"attackKind": "physics",
		"HitProtect": 10,
	}

	self.obj_attack_dict["hit2"] = {
		"power": 550,
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"HitProtect": 15,
		"addeffect":
		{
			"Name": "speed_down",
			"AddTime": 3,
			"reduce_interval": 0.0,
			"value": 0.5,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		},
	}

	self.obj_attack_dict["hit3"] = {
		"power": 550,
		"hurtBack": [0, 0],
		"attackKind": "magic",
		"HitProtect": 15,
		"addeffect":
		{
			"Name": "life_mana_lock",
			"AddTime": 4,
			"reduce_interval": 0.0,
			"value": 0.0,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true,
		},
	}

	self.fall_pro = 0.5
	self.fall_list = [
		{"name": "slyszzs", "value": 1},
		{"name": "slfkzzs", "value": 1},
		{"name": "241007005zzs", "value": 1},
	]
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_1402()
	skill_1_cd = 2
	skill_2_cd = 5
	skill_3_cd = 8
	summon_cooldown = 10


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if summon_cooldown > 0:
		summon_cooldown -= delta
		if summon_cooldown < 0:
			summon_cooldown = 0

	cleanup_dead_summoned_monsters()


func cleanup_dead_summoned_monsters():
	for i in range(summoned_monsters.size() - 1, -1, -1):
		var monster = summoned_monsters[i]
		if not is_instance_valid(monster) or monster.hp <= 0:
			summoned_monsters.remove_at(i)


func ai_think():
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if not has_target:
			normal_state()
		else:
			var distance = abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x)
			if distance >= attack_range:
				have_target()
				if can_summon and summoned_monsters.size() == 0 and summon_cooldown <= 0 and distance > 200:
					do_summon_skill()
				elif skill_3_cd <= 0 and distance > 200:
					do_hit_3()
				elif skill_1_cd <= 0:
					do_hit_1()
			else:
				stop_move()
				var random_choice = randi_range(1, 100)
				if can_summon and summoned_monsters.size() == 0 and summon_cooldown <= 0 and random_choice <= 20:
					do_summon_skill()
				elif skill_3_cd <= 0 and random_choice <= 30:
					do_hit_3()
				elif skill_1_cd <= 0:
					do_hit_1()


func do_summon_skill():
	super.to_hero()
	summon_cooldown = SUMMON_COOLDOWN_TIME
	hit_name = "summon"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit2")
	await get_tree().create_timer(0.5, false).timeout

	summon_enhanced_monsters()
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func summon_enhanced_monsters():
	if not can_summon or summoned_monsters.size() > 0:
		return

	var summon_positions = [Vector2(-400, 0), Vector2(-200, 0), Vector2(0, 0), Vector2(200, 0), Vector2(400, 0)]

	for i in range(5):
		var summon_pos = self.position + summon_positions[i]
		var enhanced_monster = Global.create_monster(122, get_parent(), summon_pos)

		if enhanced_monster != null:
			enhance_monster_122(enhanced_monster)
			summoned_monsters.append(enhanced_monster)

	can_summon = false
	summon_cooldown = SUMMON_COOLDOWN_TIME


func enhance_monster_122(monster):
	if monster.has_method("monster_120"):
		monster.max_hp = 45000 * 10
		monster.hp = monster.max_hp
		monster.crit = min(28 * 10, 100)
		monster.lucky = min(40 * 10, 100)
		monster.sp = 65 * 10
		monster.my_mr_name = "强化·妖风炼气师"
		monster.add_exp = 100 * 5
		monster.fall_coin = 30 * 10


func do_hit_1():
	super.to_hero()
	skill_1_cd = 2
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func do_hit_3():
	super.to_hero()
	skill_3_cd = randi_range(15, 20)
	hit_name = "hit3"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit3")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func call_bullet_2():
	var po = Vector2(RoleProp.get_nearest_monster_target_position(global_position).x, 300)
	await get_tree().create_timer(0.5, false).timeout

	var ly = Global.call_chase_bullet(
		self.bullet, "Monster1402Bullet2", 250, 10.0, false, po, "hit3", self.obj_attack_dict["hit2"]
	)
	ly.scale = Vector2(1.2, 1.2)


func call_bullet_3():
	var po = Vector2(self.position.x, 300)
	await get_tree().create_timer(2, false).timeout

	var ly = Global.call_chase_bullet(
		self.bullet, "Monster1402Bullet3", 250, 10.0, false, po, "hit3", self.obj_attack_dict["hit3"]
	)
	ly.scale = Vector2(2.5, 2)
	ly.owner_monster = self

	var heal_buff = {
		"Name": "HealOverTime",
		"value": 0.01,
		"AddTime": 5.0,
		"reduce_interval": 1.0,
		"AttackKind": "cure",
		"CanAdd": false
	}
	Global.add_buff(self.buff, heal_buff)


func _exit_tree() -> void:
	super._exit_tree()
	for monster in summoned_monsters:
		if is_instance_valid(monster):
			monster.hp = 1
			monster.queue_free()
	summoned_monsters.clear()

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
