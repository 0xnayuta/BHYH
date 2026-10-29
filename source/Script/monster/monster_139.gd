extends BaseMonster
var show_box: bool = false
var big_body: bool = false
var can_move: bool = false
var can_attack: bool = false
var second_hurt: int
var all_hurt: int
var attack_active: bool
var attacking_count: int
var attack_time: int
var every_hurt: int
@onready var remove_all_hurt: Timer = $RemoveAllHurt
@onready var total_dam: Label = $HurtInfo/TotalDam
@onready var total_dam_2: Label = $HurtInfo/TotalDam2
@onready var total_dam_3: Label = $HurtInfo/TotalDam3

@onready var buttonlist: VBoxContainer = $buttonlist
@onready var bt: Button = $buttonlist/bt
@onready var bt_2: Button = $buttonlist/bt2
@onready var bt_3: Button = $buttonlist/bt3
var show_box_count: int = 0
var _last_all_hurt: int = -1
var _last_second_hurt: int = -1
var _last_every_hurt: int = -1
var _last_big_body := not big_body
var _last_can_move := not can_move
var _last_can_attack := not can_attack


func monster_139():
	self.is_boss = true
	self.my_mr_name = "草木皆兵"
	self.attack_in = 0
	self.level = 5
	self.max_hp = 5000000000
	self.hp = self.max_hp
	self.def = 100
	self.mdef = 100
	self.crit = 0
	self.miss = 0
	self.lucky = 0
	self.htarget = 0
	self.toughness = 0
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 0
	self.speed = 10
	self.mysee = 300
	self.attack_range = 145
	self.attack_desire = 70
	self.behit_calmtime = 0
	self.self_rhp = 0
	self.add_exp = 0
	self.fall_coin = 0
	self.obj_attack_dict["hit1"] = {
		"power": 1000,
		"hurtBack": [-3, -6],
		"attackKind": "physics",
		"HitProtect": 10,
	}
	self.fall_pro = 0
	self.fall_list = []
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready() -> void:
	super._ready()
	monster_139()


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("假人攻击"):
		if can_attack:
			can_attack = false
		else:
			can_attack = true
	if Input.is_action_just_pressed("假人霸体"):
		if big_body:
			big_body = false
		else:
			big_body = true
	if Input.is_action_just_pressed("假人移动"):
		if can_move:
			can_move = false
		else:
			can_move = true
	if attack_active:
		attacking_count += 1
		if attacking_count % 60 == 0:
			attack_time += 1
	if all_hurt != _last_all_hurt:
		_last_all_hurt = all_hurt
		if all_hurt > 0:
			total_dam.text = "累计受到伤害：" + str(all_hurt)
		else:
			total_dam.text = ""
	var current_second_hurt := int(all_hurt) / int(attack_time) if attack_time > 0 and all_hurt > 0 else 0
	if current_second_hurt != _last_second_hurt:
		_last_second_hurt = current_second_hurt
		second_hurt = current_second_hurt
		if second_hurt > 0:
			total_dam_2.text = "每秒受到伤害：" + str(second_hurt)
		else:
			total_dam_2.text = ""
	if every_hurt != _last_every_hurt:
		_last_every_hurt = every_hurt
		if every_hurt > 0:
			total_dam_3.text = "每一秒受到伤害：" + str(every_hurt)
		else:
			total_dam_3.text = ""
	if big_body != _last_big_body:
		_last_big_body = big_body
		bt.text = "当前不可击退，快捷键：Q" if big_body else "当前可以击退，快捷键：Q"
	if can_move != _last_can_move:
		_last_can_move = can_move
		bt_2.text = "当前可以移动，快捷键：R" if can_move else "当前不可移动，快捷键：R"
	if can_attack != _last_can_attack:
		_last_can_attack = can_attack
		bt_3.text = "当前可以攻击，快捷键：E" if can_attack else "当前不可攻击，快捷键：E"

	super._physics_process(delta)


func ai_think():
	if can_move:
		if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
			has_target = true
		if not is_ice and not is_sleep and not is_stun and not cannotchangestatewhenattorbeatt() and not is_immobilize:
			if has_target == false:
				normal_state()
			else:
				if abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) >= attack_range:
					have_target()
				else:
					stop_move()
					if can_attack:
						if count % 60 == 0:
							if randi_range(0, 100) < attack_desire:
								attack_target()
	else:
		if not is_be_attacking:
			stop_move()


func state_hurt():
	is_jgz = false
	if big_body:
		is_be_attacking = false
		return
	super.state_hurt()


func _on_buttonlist_mouse_entered() -> void:
	show_box = true


func _on_bt_pressed() -> void:
	if big_body:
		big_body = false
	else:
		big_body = true


func _on_bt_2_pressed() -> void:
	if can_move:
		can_move = false
	else:
		can_move = true


func _on_bt_3_pressed() -> void:
	if can_attack:
		can_attack = false
	else:
		can_attack = true


func _on_buttonlist_mouse_exited() -> void:
	show_box = false


func hurt_reduce_hp(value, target):
	attack_active = true
	var mds_source: BaseHero = null
	if target is BaseBuff and str(target.buff_info.get("Name", "")) == "Voodoo":
		mds_source = target.buff_info.get("source_player") as BaseHero
	var skip_mds_combo: bool = (
		target is BaseBuff and str(target.buff_info.get("Name", "")) == "Voodoo" and _is_mds_awaken_active(mds_source)
	)
	if value > 0:
		remove_all_hurt.start(4)
	if monster_18_protect():
		cure_hp(value * 1)
		return 0
	if monster102_protect():
		cure_hp(value)
		return 0
	if is_indestructible:
		if value >= hp:
			return 0
	if skip_mds_combo:
		set_meta("mds_awaken_skip_combo", true)
	var previous_bonus_source := _damage_bonus_source
	_damage_bonus_source = _get_damage_source_player(target)
	var last_value = hd_reduce(value)
	_damage_bonus_source = previous_bonus_source
	if skip_mds_combo:
		remove_meta("mds_awaken_skip_combo")
	hp -= last_value
	if not skip_mds_combo:
		total_hurt += last_value
	_apply_damage_vampirism(target, int(last_value))
	every_hurt += last_value
	all_hurt += last_value
	if last_value > 0:
		add_hurt_text(last_value, target)
	else:
		if is_miss:
			add_hurt_text(last_value, target)
	is_crit = false
	is_miss = false
	_notify_yutu_damage_dealt(int(last_value), target)
	return int(last_value)


func reduce_hp(value: int):
	attack_active = true
	if value > 0:
		remove_all_hurt.start(4)
	if monster_18_protect():
		cure_hp(value * 1)
		return 0
	if monster102_protect():
		cure_hp(value)
		return 0
	if is_indestructible:
		if value >= hp:
			return 0
	var last_value = hd_reduce(value)
	hp -= last_value
	if not bool(get_meta("mds_awaken_skip_combo", false)):
		total_hurt += last_value
	all_hurt += last_value
	every_hurt += last_value
	Global.total_role_hit += last_value
	Global.total_real_hit += last_value
	var pp = get_parent().get_parent()
	var po = Vector2(self.position.x - 20, self.position.y - 240)
	if last_value > 0:
		Global.add_damage_text(pp, po, last_value, "real", false, self)
	is_crit = false
	is_miss = false


func _on_remove_all_hurt_timeout() -> void:
	all_hurt = 0
	attack_time = 0
	attack_active = false
	attacking_count = 0


func _on_every_second_timeout() -> void:
	every_hurt = 0

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
