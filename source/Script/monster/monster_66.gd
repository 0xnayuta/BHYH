extends BaseMonster
@onready var _death: Timer = $Death
var is_drop = false


func monster_66():
	self.rush_speed = 600
	self.is_boss = false
	self.my_mr_name = "毒蜘蛛"
	self.attack_in = 10
	self.level = 90
	self.max_hp = 150000
	self.hp = self.max_hp
	self.def = 200
	self.mdef = 200
	self.crit = 0
	self.miss = 0
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 9
	self.mysee = 300
	self.attack_range = 110
	self.attack_desire = 70
	self.behit_calmtime = 0.2
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 0
	(
		Global
		. add_buff(
			self.buff,
			{
				"Name": "SuperArmor",
				"AddTime": 99999999999,
				"reduce_interval": 0,
				"value": 0,
				"AttackKind": "",
				"CanAdd": false,
				"DeBuff": false,
				"CanRemove": false,
			},
		)
	)
	self.obj_attack_dict["hit1"] = {
		"power": 400 + int(RoleProp.baseroleprop.Level * 8.6),
		"hurtBack": [-4, -9],
		"attackKind": "physics",
		"HitProtect": 25,
		"addeffect":
		{
			"Name": "poision",
			"AddTime": 3,
			"reduce_interval": 1,
			"DeBuff": true,
			"CanAdd": true,
			"value": 200,
			"AttackKind": "magic",
		}
	}
	self.fall_pro = 0
	self.fall_list = []
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_66()

	_death.start(randi_range(14, 20))


func to_hero():
	if RoleProp.get_nearest_monster_target_position(global_position).x > position.x:
		base_damage_box.scale.x = -1
		monster_dir.scale.x = -1
	else:
		base_damage_box.scale.x = 1
		monster_dir.scale.x = 1


func attack_target():
	to_hero()
	hit_name = "hit1"
	velocity.x = 0
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func _on_death_timeout() -> void:
	stop_move()
	is_attacking = true
	hit_name = "hit1"
	mr_player.play("zb")
	await mr_player.animation_finished

	for i in get_parent().get_children():
		if i is Monster65:
			i.cure_hp(i.max_hp * 0.005)
			break


func _on_hit_box_area_entered(area: Area2D) -> Node2D:
	var result = super._on_hit_box_area_entered(area)

	for i in get_parent().get_children():
		if i is Monster65:
			i.cure_hp(i.hp * 0.01)
	return result


func to_top():
	if _movement_command_is_blocked():
		return
	var po = Vector2(RoleProp.get_nearest_monster_target_position(global_position).x, 350)
	var tween = create_control_movement_tween()
	tween.tween_property(self, "position", po, 0.4)


func to_drop():
	if _movement_command_is_blocked():
		velocity.y = 0
		is_drop = false
		return
	velocity.y += 900

	await mr_player.animation_finished
	is_attacking = false
	is_drop = false
