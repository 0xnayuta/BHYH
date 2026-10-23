extends BaseMonster
class_name Monster30
var brother: Monster31


func monster_30(is_boss_):
	self.my_mr_name = "黑无常"
	if is_boss_:
		self.attack_in = 0
		self.level = 27
		self.max_hp = 20000
		self.hp = self.max_hp
		self.def = 150
		self.mdef = 150
		self.crit = 15
		self.miss = 10
		self.lucky = 0
		self.htarget = 10
		self.toughness = 0
		self.ar = 0
		self.sp = 0
		self.crit_reduce = 0
		self.speed = 8
		self.mysee = 300
		self.attack_range = 245
		self.attack_desire = 80
		self.behit_calmtime = 0.1
		self.self_rhp = 0
		self.add_exp = 360
		self.fall_coin = 200
		self.obj_attack_dict["hit1"] = {
			"power": 338,
			"hurtBack": [-4, -8],
			"attackKind": "physics",
			"addeffect":
			{
				"Name": "speed_down",
				"AddTime": 1.5,
				"CanAdd": false,
				"DeBuff": true,
				"reduce_interval": 0,
				"value": 0.5,
				"AttackKind": "",
			}
		}
		self.fall_pro = 0.5
		self.fall_list = [
			{"name": "yhj", "value": 0},
			{"name": "tsgl", "value": 0},
		]

		enable_treasure_box = true
		treasure_box_item = "hbwcbx"

		update_fall_mode()
		self.fall_stone_pro = 0
		self.fall_stone = []
	else:
		self.attack_in = 10
		self.level = 25
		self.max_hp = 3000
		self.hp = self.max_hp
		self.def = 150
		self.mdef = 150
		self.crit = 10
		self.miss = 8
		self.lucky = 0
		self.htarget = 10
		self.toughness = 0
		self.ar = 0
		self.sp = 0
		self.crit_reduce = 0
		self.speed = 7
		self.mysee = 300
		self.attack_range = 145
		self.attack_desire = 60
		self.behit_calmtime = 0.2
		self.self_rhp = 0
		self.add_exp = 70
		self.fall_coin = 27
		self.obj_attack_dict["hit1"] = {
			"power": 288,
			"hurtBack": [-4, -8],
			"attackKind": "physics",
			"addeffect":
			{
				"Name": "speed_down",
				"AddTime": 1.5,
				"CanAdd": false,
				"reduce_interval": 0,
				"value": 0.5,
				"AttackKind": "",
			}
		}
		self.fall_pro = 0.0
		self.fall_list = []
		self.fall_stone_pro = 0
		self.fall_stone = []


func _ready() -> void:
	super._ready()
	if get_parent().get_parent().name == "Level_12":
		is_boss = true
	else:
		is_boss = false
	monster_30(is_boss)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	get_death()


func ai_think():
	get_death()
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if follow_hero():
				have_target()
			elif count % 60 == 0:
				var rad = randi_range(0, 100)
				if rad <= attack_desire:
					attack_target()
			else:
				stop_move()


func get_monster_31():
	if self.is_boss:
		var tta = get_parent().get_children()
		for i in tta:
			if i is Monster31:
				brother = i
	return brother


func get_death():
	get_monster_31()
	if brother != null:
		if get_monster_31().is_boss:
			if get_monster_31().death():
				$call_bai.start(4)


func _on_call_bai_timeout() -> void:
	var par = get_parent()
	var white = Global.create_monster(31, par, Vector2(self.position.x, self.position.y))
	var base_level = get_parent().get_parent() as BaseLevel
	base_level.monster_array.push_back(white)
	$call_bai.stop()
