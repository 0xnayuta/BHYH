extends BaseMonster
var is_show: bool = true
var show_count: int = randi_range(300, 480)
var hide_count: int = randi_range(300, 480)


func monster_109():
	self.is_boss = false
	self.my_mr_name = "隐匿童子"
	self.attack_in = 90
	self.level = 50
	self.max_hp = 15000
	self.hp = self.max_hp
	self.def = 150
	self.mdef = 150
	self.crit = 20
	self.miss = 20
	self.lucky = 0
	self.htarget = 20
	self.toughness = 20
	self.ar = 25
	self.sp = 25
	self.crit_reduce = 0
	self.speed = 11
	self.mysee = 500
	self.attack_range = 165
	self.attack_desire = 80
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 220
	self.fall_coin = 220
	self.obj_attack_dict["hit1"] = {
		"power": 500,
		"hurtBack": [-4, -9],
		"attackKind": "magic",
		"HitProtect": 10,
	}
	self.fall_pro = 0.4
	self.fall_list = [
		{"name": "shougong", "value": randi_range(1, 2)},
	]
	self.fall_stone_pro = 0.28
	self.fall_stone = [
		{"name": "ziyanyujin", "value": randi_range(1, 5)},
	]


func _ready() -> void:
	super._ready()
	monster_109()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if is_show:
		show_count -= 1
		if show_count <= 0:
			show_count = randi_range(300, 480)
			var tween = get_tree().create_tween()
			tween.tween_property(self, "modulate", Color(1, 1, 1, 0.2), 1)
			is_show = false
	else:
		hide_count -= 1
		if hide_count <= 0:
			hide_count = randi_range(300, 480)
			var tween = get_tree().create_tween()
			tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 1)
			is_show = true


func _on_hit_box_area_entered(area: Area2D) -> Node2D:
	var buff_target = super._on_hit_box_area_entered(area)

	if is_instance_valid(buff_target) and buff_target.has_method("reduce_mp"):
		if RoleProp and RoleProp.roleprop:
			var mp_reduce = int(RoleProp.roleprop.SMp * 0.05 + 30)
			buff_target.reduce_mp(mp_reduce)
			print("对目标 %s 扣除蓝量：%d" % [buff_target.name, mp_reduce])

	if not is_show and is_instance_valid(buff_target):
		var buff_node: Node = null
		if "buff" in buff_target and buff_target.buff != null:
			buff_node = buff_target.buff
		elif buff_target.has_node("Buff"):
			buff_node = buff_target.get_node("Buff")
		elif buff_target.has_node("buff"):
			buff_node = buff_target.get_node("buff")
		if buff_node != null:
			(
				Global
				. add_buff(
					buff_node,
					{
						"Name": "Scary",
						"AddTime": 3,
						"reduce_interval": 0,
						"value": 0,
						"AttackKind": "",
						"CanAdd": false,
						"DeBuff": true,
					}
				)
			)
			print("对目标 %s 添加恐惧Buff，持续3秒" % buff_target.name)

	return buff_target


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if is_show:
		super._on_hurt_box_area_entered(area)
