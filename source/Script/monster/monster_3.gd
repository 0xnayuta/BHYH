extends BaseMonster


func monster_3(is_boss_):
	self.my_mr_name = "大猩猩"
	if is_boss_:
		self.attack_in = 30
		self.level = 5
		self.max_hp = 300
		self.hp = self.max_hp
		self.def = 50
		self.mdef = 80
		self.crit = 5
		self.miss = 0
		self.lucky = 0
		self.htarget = 0
		self.toughness = 0
		self.ar = 0
		self.sp = 0
		self.crit_reduce = 0
		self.speed = 12
		self.mysee = 400
		self.attack_range = 135
		self.attack_desire = 100
		self.behit_calmtime = 0.1
		self.self_rhp = 0
		self.add_exp = 35
		self.fall_coin = 10
		self.obj_attack_dict["hit1"] = {"power": 65, "hurtBack": [-4, -9], "attackKind": "physics", "HitProtect": 8}
		self.fall_pro = 1
		self.fall_list = []
		self.fall_stone_pro = 0
		self.fall_stone = []
	else:
		self.attack_in = 10
		self.level = 10
		self.max_hp = 200
		self.hp = self.max_hp
		self.def = 50
		self.mdef = 50
		self.crit = 5
		self.miss = 0
		self.lucky = 0
		self.htarget = 0
		self.toughness = 0
		self.ar = 0
		self.sp = 0
		self.crit_reduce = 0
		self.speed = 10
		self.mysee = 300
		self.attack_range = 135
		self.attack_desire = 80
		self.behit_calmtime = 0.2
		self.self_rhp = 0
		self.add_exp = 10
		self.fall_coin = 2
		self.obj_attack_dict["hit1"] = {"power": 30, "hurtBack": [-4, -9], "attackKind": "physics", "HitProtect": 8}
		self.fall_pro = 0.18
		self.fall_list = [
			{"name": "ptxzg", "value": 0},
			{"name": "ptxzf", "value": 0},
			{"name": "ptsmz", "value": 0},
			{"name": "ptjs", "value": 0},
			{"name": "ptdp", "value": 0},
			{"name": "ptcs", "value": 0},
			{"name": "ptyyc", "value": 0},
			{"name": "ptcp", "value": 0},
			{"name": "nzhjq", "value": 0},
			{"name": "nzly", "value": 0},
		]
		self.fall_stone_pro = 0.0
		self.fall_stone = []


func _ready() -> void:
	super._ready()
	if get_parent().get_parent().name == "Level_1":
		is_boss = true
	else:
		is_boss = false
	monster_3(is_boss)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if is_boss:
		if (
			PlayerData.player_data[DataKeys.WEAPON].size() == 0
			and PlayerData.player_data[DataKeys.ARMOR].size() == 0
			and PlayerData.player_data["饰品"].size() == 0
			and PlayerData.player_data[DataKeys.MAGIC_WEAPON].size() == 0
		):
			if PlayerData.get_dj_page("ttlp1") != 0 and PlayerData.get_dj_page("ttlp2") != 0:
				if Global.total_hurt_count == 0 and PlayerData.player_data["天庭"]:
					self.fall_list = [
						{"name": "ttlp3", "value": 1},
					]
