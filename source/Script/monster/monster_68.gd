extends BaseMonster
class_name Monster68
var is_stick = false
var target_offset: Vector2
var stick_count: int = 0
var max_stick_count: int = randi_range(6, 8)
var current_stick_count: int = 0
var myfather: Monster67


func monster_67():
	self.is_boss = false
	self.my_mr_name = "水蛭"
	self.attack_in = 0
	self.level = RoleProp.baseroleprop.Level + 2
	self.max_hp = 3000
	self.hp = self.max_hp
	self.def = 120
	self.mdef = 120
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
	self.attack_range = 225
	self.attack_desire = 0
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 0
	self.obj_attack_dict["hit1"] = {
		"power": randi_range(100, 150), "hurtBack": [0, 0], "attackKind": "magic", "HitProtect": 0
	}
	self.fall_pro = 0
	self.fall_list = []
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	target_offset = Vector2(randi_range(-10, 10), randi_range(-15, 15))
	super._ready()
	monster_67()
	skill_1_cd = 0


func ai_think():
	if myfather == null:
		myfather = Global.create_monster(67, get_parent(), position)
	if is_stick:
		stick_count += 1
		$BaseDamageBox/HurtBox/HurtBox.disabled = true
		self.position = RoleProp.get_nearest_monster_target_position(global_position) + target_offset
		should_in_sky = true
		if stick_count % 60 == 0 and stick_count != 0:
			current_stick_count += 1
			if myfather != null:
				myfather.cure_hp(randi_range(1000, 1600))
			if get_player != null:
				get_player.effect_reducehp(obj_attack_dict["hit1"]["power"], obj_attack_dict["hit1"]["attackKind"])
				(
					Global
					. add_buff(
						get_player.buff,
						{
							"Name": "speed_down",
							"AddTime": 0.4,
							"reduce_interval": 0,
							"value": 0.3,
							"AttackKind": "",
							"DeBuff": true,
						}
					)
				)
		if current_stick_count > max_stick_count:
			current_stick_count = 0
			is_stick = false
		return
	should_in_sky = false
	if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt():
		if has_target == false:
			normal_state()
		else:
			if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attack_range:
				have_target()
			else:
				if count % 60 == 0:
					attack_target()
				else:
					stop_move()


func attack_target():
	to_hero()
	hit_name = "hit1"
	if monster_direction:
		velocity.x += 188
	else:
		velocity.x -= 188
	velocity.y = -400
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false
	stop_move()


func _on_hit_box_area_exited(_area: Area2D) -> void:
	is_stick = true
	super._on_hit_box_area_entered(_area)
