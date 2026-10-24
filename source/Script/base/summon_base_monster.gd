extends BaseObject
class_name SummonBaseMonster

const BaseHero = preload("res://Script/base/base_hero.gd")

@onready var bullet: Node = $Bullet
@onready var hit_box: CollisionShape2D = $BaseDamageBox/HitBox/HitBox
@onready var hurt_box: CollisionShape2D = $BaseDamageBox/HurtBox/HurtBox
@onready var base_damage_box: Node2D = $BaseDamageBox
@onready var buff: Node = $Buff
@onready var mr_player: AnimationPlayer = $mr_player
@onready var monster_dir: Node2D = $MonsterDir
@onready var remove_hurt_bl: Timer = $RemoveHurtBL

var is_summon: bool = true
var summoner: Node = null
var summon_duration: float = 0.0
var duration_timer: float = 0.0
var despawn_effect_enabled: bool = true
var is_friendly: bool = true
var max_protect: float = 100.0
var current_protect: float = 0.0
var need_protect: bool = false
var need_remove_protect: bool = false
var protect_hold_time: float = 0.0

var current_target: BaseMonster = null
var has_target: bool = false
var all_monsters: Array = []
var target_search_timer: float = 0.0
var target_search_interval: float = 1.0
var player_reference: BaseHero = null
var _is_following_player_when_idle: bool = false
const PET_FOLLOW_START_DISTANCE := 300.0
const PET_FOLLOW_STOP_DISTANCE := 120.0

var return_to_player_distance: int = 1000
var return_timer: float = 0.0
var return_check_interval: float = 2.0

var skill_1_cd: float = 0.0
var skill_2_cd: float = 0.0
var skill_3_cd: float = 0.0
var skill_4_cd: float = 0.0
var skill_5_cd: float = 0.0
var skill_6_cd: float = 0.0

var round_list = []

var monster_blood_bar = null

var should_in_sky: bool = false
var is_sky: bool = false
var in_sky_timer: float = 0.0
var max_sky_time: float = 10.0

var count: int = 0
var ran_num: int = 0
var rndi_count: int = 0

var base_level: Node = null
var level_cache_valid: bool = false

enum State {
	IDLE,
	MOVE,
	ATTACK,
	HURT,
	DEATH,
	SKY,
}
var current_state: State = State.IDLE

var rush_speed: float = 0.0
var is_boss: bool = false
var my_mr_name: String = ""
var attack_in: int = 0
var level: int = 1
var def: int = 0
var mdef: int = 0
var crit: int = 0
var miss: int = 0
var lucky: int = 0
var htarget: int = 0
var toughness: int = 0
var ar: int = 0
var sp: int = 0
var crit_reduce: int = 0
var behit_calmtime: float = 0.0
var self_rhp: int = 0
var add_exp: int = 0
var fall_coin: int = 0
var ebol: float = 0.0
var speed: int = 10
var mysee: int = 500
var attack_range: int = 160
var attack_desire: int = 80

var islljy: bool = false
var is_lpz: bool = false
var lpzzs: float = 0.0
var tqzbs: float = 0.0
var llrdzs: float = 1.0
var llrd_count: int = 0
var jgz_bl: float = 1.0
var is_jgz: bool = false
var is_stun: bool = false
var is_sleep: bool = false
var is_immobilize: bool = false
var is_speed_down: bool = false
var is_scary: bool = false
var super_armor_active: bool = false
var is_indestructible: bool = false
var is_defe_reduce: bool = false
var defe_reduce: float = 0.0
var is_blood_fix: bool = false
var life_mana_lock: bool = false
var is_quiescent: bool = false
var is_death: bool = false
var hurt_bl: float = 1.0
var hit_name: String = ""
var monster_direction: bool = false
var get_player: Node = null

var hd: int = 0
var max_hd: int = 0
var is_bt: bool = false
var total_hurt: int = 0
var therapeutic_effects: float = 0.0
var lpzjs: float = 0.0
var is_fly: bool = false
var init_speed: int = 10

var no_grav: bool = false
var is_gxp: bool = false
var _gxp_base_speed: int = 0
var _gxp_serial: int = 0
const GXP_DAMAGE_MULTIPLIER: float = 2.0
const GXP_AFTERIMAGE_INTERVAL: float = 0.12


func turn_to_gxp(duration: int) -> void:
	_gxp_serial += 1
	var token := _gxp_serial
	if not is_gxp:
		is_gxp = true
		_gxp_base_speed = maxi(1, speed)
		_spawn_gxp_afterimage(token)
	speed = _gxp_base_speed * 2
	init_speed = _gxp_base_speed * 2
	get_tree().create_timer(maxi(duration, 1)).timeout.connect(_finish_gxp.bind(token), CONNECT_ONE_SHOT)


func get_gxp_damage_multiplier() -> float:
	return GXP_DAMAGE_MULTIPLIER if is_gxp else 1.0


func _spawn_gxp_afterimage(token: int) -> void:
	if token != _gxp_serial or not is_gxp or not is_inside_tree() or hp <= 0:
		return
	if is_instance_valid(monster_dir):
		var level_node := get_level_node()
		if level_node != null and level_node != self:
			spawn_ws_effect(monster_dir, get_parent())
	get_tree().create_timer(GXP_AFTERIMAGE_INTERVAL, false).timeout.connect(
		_spawn_gxp_afterimage.bind(token), CONNECT_ONE_SHOT
	)


func _finish_gxp(token: int) -> void:
	if token != _gxp_serial or not is_gxp:
		return
	cancel_gxp()


func cancel_gxp() -> void:
	if not is_gxp:
		return
	is_gxp = false
	speed = maxi(1, _gxp_base_speed)
	init_speed = speed


func _play_animation_if_exists(anim_name: String) -> bool:
	if mr_player.has_animation(anim_name):
		mr_player.play(anim_name)
		return true
	return false


func _get_gravity() -> float:
	return -980.0 if can_set_gravity() else 0.0


func _ready() -> void:
	randomize()
	ran_num = randi_range(0, 100)
	rndi_count = randi_range(0, 100)
	$CalmHit.start(1.0)

	if not has_node("Buff"):
		var buff_node = Node.new()
		buff_node.name = "Buff"
		add_child(buff_node)
		buff = buff_node

	initialize_monster_properties()
	init_speed = speed

	try_play_default_animation()
	base_damage_box.scale.x = 1
	monster_dir.scale.x = 1

	find_player_reference()
	setup_skills()
	current_state = State.IDLE


func try_play_default_animation() -> void:
	if is_fly:
		if (
			_play_animation_if_exists("Fly_wait")
			or _play_animation_if_exists("fly_wait")
			or _play_animation_if_exists("Fly")
			or _play_animation_if_exists("fly")
		):
			return
	try_play_fallback_animation()


func try_play_fallback_animation() -> void:
	if _play_animation_if_exists("wait") or _play_animation_if_exists("idle"):
		return
	var anim_list = mr_player.get_animation_list()
	if anim_list.size() > 0:
		mr_player.play(anim_list[0])


func find_player_reference() -> void:
	if is_instance_valid(summoner) and summoner is BaseHero:
		player_reference = summoner
		return
	if is_instance_valid(RoleProp.source_player):
		player_reference = RoleProp.source_player
		return
	var tree = get_tree()
	if not tree:
		return
	var current_scene = tree.current_scene
	if not current_scene or not current_scene.has_node("Hero"):
		return
	var hero_node = current_scene.get_node("Hero")
	if hero_node:
		for child in hero_node.get_children():
			if child is BaseHero:
				player_reference = child
				break


func follow_player_when_idle() -> void:
	if not is_instance_valid(player_reference):
		find_player_reference()
	if not is_instance_valid(player_reference):
		_is_following_player_when_idle = false
		stop_move()
		return
	var offset_x := player_reference.global_position.x - global_position.x
	var distance_x := absf(offset_x)
	if _is_following_player_when_idle and distance_x <= PET_FOLLOW_STOP_DISTANCE:
		_is_following_player_when_idle = false
	elif not _is_following_player_when_idle and distance_x > PET_FOLLOW_START_DISTANCE:
		_is_following_player_when_idle = true
	if not _is_following_player_when_idle:
		stop_move()
	elif offset_x > 0.0:
		move_right()
	else:
		move_left()


func _physics_process(delta: float) -> void:
	if is_instance_valid(player_reference) and player_reference.is_death:
		for pet_key in [
			"pet_tiger_unit",
			"pet_dragon_unit",
			"pet_phoenix_unit",
			"pet_turtle_unit",
			"pet_rabbit_unit",
			"pet_mouse_unit",
			"pet_neat_unit",
			"pet_yin_tiger_unit",
		]:
			if bool(get_meta(pet_key, false)):
				queue_free()
				return
	gravity = _get_gravity()
	handle_gravity_and_sky(delta)
	check_add_buff()
	update_timers(delta)

	llrdzs = 1.3 if llrd_count > 0 else 1.0
	if llrd_count > 0:
		llrd_count -= 1

	if target_search_timer >= target_search_interval:
		search_for_targets()
		target_search_timer = 0.0

	if return_timer >= return_check_interval and player_reference:
		check_return_to_player()
		return_timer = 0.0

	_process_pet_protect(delta)

	if summon_duration > 0:
		duration_timer += delta
		if duration_timer >= summon_duration:
			despawn()

	monster_direction = (monster_dir.scale.x == 1)

	if death():
		current_state = State.DEATH
	elif should_in_sky:
		current_state = State.SKY
	elif is_attacking:
		current_state = State.ATTACK
	elif is_be_attacking:
		current_state = State.HURT
	elif velocity.x != 0:
		current_state = State.MOVE
	else:
		current_state = State.IDLE

	match current_state:
		State.DEATH:
			process_death(delta)
		State.SKY:
			process_sky(delta)
		State.ATTACK:
			process_attack(delta)
		State.HURT:
			process_hurt(delta)
		State.MOVE:
			process_move(delta)
		State.IDLE:
			process_idle(delta)

	if not death() and not should_in_sky and not is_be_attacking and not is_attacking:
		if not is_limit_buff():
			ai_think()
		elif is_scary:
			when_scary()
		else:
			velocity.x = 0

	if not death():
		update_animation_and_direction()

	if MainSet.set_data.get("MonsterLittleBlood", false) and MainSet.set_data.get("NoShowMonsterBody", false):
		little_blood_bar_control()

	if not is_on_floor() and not is_fly and not should_in_sky:
		velocity.y -= gravity * delta

	move_and_slide()


func rush() -> void:
	velocity.x = 0
	velocity.x -= rush_speed if monster_direction else -rush_speed


func handle_gravity_and_sky(_delta: float) -> void:
	if is_sky or should_in_sky or is_fly:
		velocity.y = 0
	if should_in_sky:
		in_sky_timer += _delta
		if in_sky_timer >= max_sky_time:
			drop()


func update_timers(delta: float) -> void:
	count += 1
	skill_1_cd -= delta
	skill_2_cd -= delta
	skill_3_cd -= delta
	skill_4_cd -= delta
	skill_5_cd -= delta
	skill_6_cd -= delta
	target_search_timer += delta
	return_timer += delta
	if count % 60 == 0:
		ran_num = randi_range(0, 100)


func update_animation_and_direction() -> void:
	if is_attacking or is_be_attacking:
		return

	if velocity.x != 0:
		if is_fly:
			if not (_play_animation_if_exists("Fly") or _play_animation_if_exists("fly")):
				mr_player.play("walk")
		else:
			mr_player.play("walk")
	else:
		if is_fly:
			if not (_play_animation_if_exists("Fly_wait") or _play_animation_if_exists("fly_wait")):
				mr_player.play("wait")
		else:
			mr_player.play("wait")

	if velocity.x > 0:
		base_damage_box.scale.x = -1
		monster_dir.scale.x = -1
	elif velocity.x < 0:
		base_damage_box.scale.x = 1
		monster_dir.scale.x = 1


func check_add_buff() -> void:
	if not buff:
		return
	var not_ice = true
	var not_stun = true
	var not_sleep = true
	var not_immobilize = true
	var not_speed_down = true
	var not_scary = true
	var not_super_armor = true
	var not_indestructible = true
	var not_defe_reduce = true
	var not_is_blood_fix = true
	var not_life_mana_lock = true
	var not_lljy = true
	var not_lpz = true
	var not_no_de_buff = true

	var buff_child_count := buff.get_child_count()
	var buff_child_index := 0
	while buff_child_index < buff_child_count:
		var i = buff.get_child(buff_child_index)
		buff_child_index += 1
		if not i:
			continue
		var name = i.buff_info.get("Name", "")
		match name:
			"lljybuff":
				islljy = true
				not_lljy = false
			"no_debuff":
				no_debuff = true
				not_no_de_buff = false
			"lpzbuff":
				is_lpz = true
				not_lpz = false
			"Ice":
				is_ice = true
				not_ice = false
			"Indestructible":
				is_indestructible = true
				not_indestructible = false
			"defe_reduce":
				is_defe_reduce = true
				not_defe_reduce = false
			"SuperArmor":
				super_armor_active = true
				not_super_armor = false
			"DeadLink":
				is_dead_link = true
			"EyeFix":
				is_eye_fix = true
			"Immobilize":
				is_immobilize = true
				not_immobilize = false
			"stun":
				is_stun = true
				not_stun = false
			"speed_down":
				is_speed_down = true
				not_speed_down = false
			"blood_fix":
				is_blood_fix = true
				not_is_blood_fix = false
			"life_mana_lock":
				life_mana_lock = true
				not_life_mana_lock = false
			"Scary":
				is_scary = true
				not_scary = false

	if not_no_de_buff:
		no_debuff = false
	if not_lljy:
		islljy = false
	if not_lpz:
		is_lpz = false
		lpzjs = 0.0
	if not_indestructible:
		is_indestructible = false
	if not_defe_reduce:
		defe_reduce = 0.0
		is_defe_reduce = false
	if not_super_armor:
		super_armor_active = false
	if not_scary:
		is_scary = false
	if not_is_blood_fix:
		is_blood_fix = false
	if not_life_mana_lock:
		life_mana_lock = false
	if not_immobilize:
		is_immobilize = false
	if not_ice:
		is_ice = false
	if not_stun:
		is_stun = false
	if not_speed_down:
		is_speed_down = false
		speed = init_speed

	if buff_child_count == 0:
		is_speed_down = false
		speed = init_speed
		is_stun = false
		is_ice = false
		is_dead_link = false
		is_eye_fix = false


func can_set_gravity() -> bool:
	return not no_grav and not islljy and not should_in_sky


func is_limit_buff() -> bool:
	return is_ice or is_stun or is_immobilize or is_sleep or is_scary or islljy


func is_super_armor() -> bool:
	return super_armor_active or is_indestructible or is_dead_link


func when_scary() -> void:
	if ran_num <= 20:
		stop_move()
	elif ran_num <= 60:
		move_left()
	else:
		move_right()


func get_attacker_damage(attacker: Node) -> int:
	var base_damage = 0
	var attack_kind = "physics"

	if attacker is BaseMonster or attacker is MonsterBullet:
		var hit_name_val = attacker.get("hit_name")
		var obj_dic = attacker.get("obj_attack_dict")
		if not (obj_dic is Dictionary) or obj_dic.is_empty():
			obj_dic = attacker.get("att_list")
		if hit_name_val and obj_dic is Dictionary:
			var hit_info = obj_dic.get(hit_name_val)
			if hit_info is Dictionary and hit_info.has("power"):
				base_damage = hit_info["power"]
				attack_kind = hit_info.get("attackKind", "physics")
			elif obj_dic.has("power"):
				base_damage = obj_dic["power"]
				attack_kind = obj_dic.get("attackKind", "physics")
			else:
				return 0
		else:
			return 0
	elif attacker is BaseHero or attacker is BaseMagicWeapon or attacker is RoleBullet:
		if attacker.has_method("get_hit_damage"):
			base_damage = attacker.get_hit_damage()
		elif "hit_dic" in attacker and attacker.hit_dic.has("power"):
			base_damage = attacker.hit_dic["power"]
			attack_kind = attacker.hit_dic.get("attackKind", "physics")
		else:
			return 0
	else:
		return 0

	var hostile: BaseMonster = attacker as BaseMonster
	if attacker is MonsterBullet:
		var bullet := attacker as MonsterBullet
		if is_instance_valid(bullet.my_father):
			hostile = bullet.my_father
	if hostile != null:
		base_damage = hostile.get_coop_attack_power(int(base_damage))
	var defense = def if attack_kind == "physics" else mdef
	var reduction = defense / float(defense + 100)
	var final_damage = int(base_damage * (1.0 - reduction))
	return max(1, final_damage)


func state_hurt(_attacker: Node) -> void:
	Global.add_special_effect(self, Vector2.ZERO, "RoleBeHit", Vector2.ONE, false, 1)
	Global.add_sound(self, "res://Music/monster_hurt/6_beattack_by_role1.mp3")


func calculate_attack_damage(target: BaseMonster, base_damage: int, attack_kind: String) -> int:
	if target == null or not is_instance_valid(target):
		return 0
	return target.resolve_friendly_damage(base_damage, attack_kind, self)


func deal_summon_damage(target: BaseMonster, base_damage: int, attack_kind: String = "magic") -> int:
	if target == null or not is_instance_valid(target) or target == self or target.hp <= 0:
		return 0
	var resolved_damage := calculate_attack_damage(target, base_damage, attack_kind)
	if resolved_damage <= 0:
		return 0
	return target.reduce_pet_hp(resolved_damage, attack_kind)


func process_idle(_delta: float) -> void:
	if not is_be_attacking and current_target:
		try_use_skills()


func process_move(_delta: float) -> void:
	pass


func process_attack(_delta: float) -> void:
	pass


func process_hurt(_delta: float) -> void:
	pass


func process_sky(_delta: float) -> void:
	velocity.x = 0
	velocity.y = 0


func process_death(_delta: float) -> void:
	velocity.x = 0
	velocity.y = 0
	mr_player.play("death")
	call_deferred("_handle_death")


func search_for_targets() -> void:
	all_monsters.clear()
	var tree = get_tree()
	if tree:
		var level_node: Node = get_level_node()
		if (
			level_node != null
			and level_node.has_method("has_active_monster_index")
			and level_node.has_active_monster_index()
		):
			for monster in level_node.get_active_monsters():
				_try_add_target(monster)
		else:
			for monster in tree.get_nodes_in_group("monsters"):
				_try_add_target(monster)
			if all_monsters.is_empty() and level_node != null and level_node.has_node("Monster"):
				_collect_targets_recursive(level_node.get_node("Monster"))
		if all_monsters.is_empty():
			var current_scene = tree.current_scene
			if current_scene and current_scene.has_node("Monster"):
				_collect_targets_recursive(current_scene.get_node("Monster"))
		if all_monsters.is_empty():
			_collect_targets_recursive(tree.root)

	if not all_monsters.is_empty():
		var closest = null
		var min_dist = INF
		for m in all_monsters:
			var d = position.distance_to(m.position)
			if d < min_dist:
				min_dist = d
				closest = m
		current_target = closest
		has_target = true
	else:
		current_target = null
		has_target = false
		stop_move()


func monster_is_summon(monster: BaseMonster) -> bool:
	return monster.get("is_summon") == true


func _try_add_target(monster: Node) -> void:
	if monster and monster != self and monster is BaseMonster and monster.hp > 0 and not monster_is_summon(monster):
		if not all_monsters.has(monster):
			all_monsters.append(monster)


func _collect_targets_recursive(node: Node) -> void:
	if node == null:
		return
	_try_add_target(node)
	for child in node.get_children():
		_collect_targets_recursive(child)


func ai_think() -> void:
	if not is_instance_valid(current_target) or current_target.hp <= 0:
		current_target = null
		stop_move()
		return
	var distance = abs(position.x - current_target.position.x)
	if distance < mysee:
		has_target = true
		if distance > attack_range:
			if current_target.position.x > position.x:
				move_right()
			else:
				move_left()
			if not is_be_attacking:
				try_use_skills()
		else:
			stop_move()
			if not is_be_attacking:
				try_use_skills()
	else:
		current_target = null
		has_target = false
		stop_move()


func try_use_skills() -> void:
	if should_in_sky:
		return
	if randi_range(0, 100) >= attack_desire:
		return
	if skill_1_cd <= 0:
		do_hit_1()
	elif skill_2_cd <= 0:
		do_hit_2()
	elif skill_3_cd <= 0:
		do_hit_3()
	elif skill_4_cd <= 0:
		do_hit_4()
	elif skill_5_cd <= 0:
		do_hit_5()
	elif skill_6_cd <= 0:
		do_hit_6()


func move_left() -> void:
	base_damage_box.scale.x = 1
	monster_dir.scale.x = 1
	velocity.x = -speed * 10
	play_move_animation()


func move_right() -> void:
	base_damage_box.scale.x = -1
	monster_dir.scale.x = -1
	velocity.x = speed * 10
	play_move_animation()


func move_up() -> void:
	velocity.y = -speed * 8
	play_move_animation()


func move_down() -> void:
	velocity.y = speed * 8
	play_move_animation()


func play_move_animation() -> void:
	if is_fly:
		if not (_play_animation_if_exists("Fly") or _play_animation_if_exists("fly")):
			mr_player.play("walk")
	else:
		mr_player.play("walk")


func to_monster() -> void:
	if not is_instance_valid(current_target):
		return
	if current_target.position.x > position.x:
		base_damage_box.scale.x = 1
		monster_dir.scale.x = 1
	else:
		base_damage_box.scale.x = -1
		monster_dir.scale.x = -1


func normal_state() -> void:
	if is_quiescent or is_be_attacking:
		return
	if is_fly:
		if ran_num < 95:
			if RoleProp.role_pos_y > position.y + randi_range(125, 245):
				move_down()
			elif RoleProp.role_pos_y < position.y + randi_range(15, 65):
				move_up()
		else:
			if ran_num < 50:
				move_down()
			else:
				move_up()
	if ran_num < 10:
		stop_move()
	elif ran_num <= 55:
		move_left()
	else:
		move_right()


func have_target() -> void:
	if is_quiescent or is_be_attacking:
		return
	if is_fly:
		if current_target.position.y > position.y + randi_range(125, 245):
			move_down()
		elif current_target.position.y < position.y + randi_range(15, 45):
			move_up()
	if current_target.position.x > position.x + randi_range(65, 85):
		move_right()
	elif current_target.position.x < position.x - randi_range(65, 85):
		move_left()


func cannotchangestatewhenattorbeatt() -> bool:
	return is_attacking or is_be_attacking


func stop_move() -> void:
	velocity.x = 0
	if is_fly:
		if not (_play_animation_if_exists("Fly_wait") or _play_animation_if_exists("fly_wait")):
			mr_player.play("wait")
	else:
		mr_player.play("wait")


func do_hit_1() -> void:
	pass


func do_hit_2() -> void:
	pass


func do_hit_3() -> void:
	pass


func do_hit_4() -> void:
	pass


func do_hit_5() -> void:
	pass


func do_hit_6() -> void:
	pass


func check_return_to_player() -> void:
	if not player_reference:
		return
	if global_position.distance_to(player_reference.global_position) > return_to_player_distance:
		return_to_player()
		return_timer = -0.5


func return_to_player() -> void:
	if not player_reference:
		return
	var offset_x = 100 * (1 if randf() > 0.5 else -1)
	var offset_y = -50
	global_position = player_reference.global_position + Vector2(offset_x, offset_y)
	velocity = Vector2.ZERO
	reset_attack_state()
	current_target = null
	has_target = false


func reset_attack_state() -> void:
	is_be_attacking = false
	is_attacking = false
	if death() or should_in_sky:
		return
	if velocity.x != 0:
		if is_fly:
			if not (_play_animation_if_exists("Fly") or _play_animation_if_exists("fly")):
				mr_player.play("walk")
		else:
			mr_player.play("walk")
	else:
		if is_fly:
			if not (_play_animation_if_exists("Fly_wait") or _play_animation_if_exists("fly_wait")):
				mr_player.play("wait")
		else:
			mr_player.play("wait")


func little_blood_bar_control() -> void:
	if not (MainSet.set_data.get("MonsterLittleBlood", false) and MainSet.set_data.get("NoShowMonsterBody", false)):
		return
	if monster_blood_bar == null and hp > 0:
		monster_blood_bar = Global.add_monster_blood(self, Vector2(-30, -90), hp / float(max_hp), hp)
	elif monster_blood_bar:
		if not is_be_attacking:
			monster_blood_bar.can_show = false
		else:
			monster_blood_bar.can_show = true
		monster_blood_bar.bar_value = float(hp) / float(max_hp)
		monster_blood_bar.bar_text = hp
		if hp <= 0:
			monster_blood_bar.queue_free()
			monster_blood_bar = null


func death() -> bool:
	return hp <= 0


func reduce_hp(value: int, _attacker = null) -> void:
	if _pet_protect_active():
		return
	if is_indestructible and value >= hp:
		return
	hp -= value
	total_hurt += value
	if value > 0:
		var level_node = get_level_node()
		if level_node:
			Global.add_damage_text(level_node, Vector2(position.x, position.y - 110), value, "physics", false, self)


func cure_hp(value: int = 0) -> int:
	if hp <= 0 or is_blood_fix or life_mana_lock:
		return 0
	value = int(value * (1 + therapeutic_effects))
	if hp + value >= max_hp:
		value = max_hp - hp
	hp += value
	if value > 0:
		var level_node = get_level_node()
		if level_node:
			call_deferred("_show_heal_text", level_node, Vector2(position.x, position.y - 110), value)
	return value


func _show_heal_text(level_node, po: Vector2, value: int) -> void:
	Global.add_damage_text(level_node, po, value, "cure", false, self)


func _on_hurt_box_area_entered(area: Area2D) -> void:
	var attacker = null
	if area is BaseRoleHitBox or area is RolehmzBullet:
		attacker = LocalCoop.owner_hero(area)
	elif area.get_parent() is BaseMonster:
		attacker = area.get_parent()
	elif area.get_parent().get_parent() is BaseMonster:
		attacker = area.get_parent().get_parent()
	elif area.get_parent() is MonsterBullet:
		attacker = area.get_parent()
	elif area.get_parent().get_parent() is MonsterBullet:
		attacker = area.get_parent().get_parent()
	else:
		return
	if not is_instance_valid(attacker):
		return
	var last_hurt = get_attacker_damage(attacker)
	if last_hurt <= 0:
		return
	if _pet_protect_active():
		return
	if is_attacking:
		hp -= last_hurt
		if hp <= 0:
			hp = 0
			death()
		else:
			var level_node = get_level_node()
			if level_node:
				Global.add_damage_text(
					level_node, Vector2(position.x, position.y - 110), last_hurt, "physics", false, self
				)
	else:
		reduce_hp(last_hurt, attacker)
		if not is_super_armor():
			state_hurt(attacker)
	_add_pet_protect(_get_pet_protect_gain(attacker))


func _on_hit_box_area_entered(area: Area2D) -> void:
	if not (is_attacking and hit_name != ""):
		return

	var parent = area.get_parent()
	var target_node = parent.get_parent() if parent else null

	if not target_node or not (target_node is BaseMonster) or target_node == self:
		return

	var hit_data: Dictionary = obj_attack_dict.get(hit_name, {}) if obj_attack_dict.has(hit_name) else {}
	var damage := int(hit_data.get("power", 500))
	var attack_kind := str(hit_data.get("attackKind", "magic"))
	if deal_summon_damage(target_node, damage, attack_kind) <= 0:
		return
	target_node.play_hit_effect(self)
	apply_knockback(target_node)
	if obj_attack_dict.has(hit_name) and obj_attack_dict[hit_name].has("addeffect"):
		_apply_attack_effect(target_node, obj_attack_dict[hit_name]["addeffect"])


func _apply_attack_effect(target: BaseMonster, effect: Dictionary) -> void:
	if not is_instance_valid(target) or target.hp <= 0:
		return
	if not target.has_node("Buff"):
		var buff_node = Node.new()
		buff_node.name = "Buff"
		target.add_child(buff_node)
	Global.add_buff(target.get_node("Buff"), effect)


func _on_summon_bullet_hit(area: Area2D, bullet_instance) -> void:
	var parent = area.get_parent()
	var target = parent.get_parent() if parent else null

	if not target or not (target is BaseMonster) or target == self:
		return

	var attack_name = bullet_instance.get("hit_name")
	if not obj_attack_dict.has(attack_name):
		return

	var hit_data: Dictionary = obj_attack_dict[attack_name]
	var damage := int(hit_data.get("power", 0))
	var attack_kind := str(hit_data.get("attackKind", "magic"))
	if deal_summon_damage(target, damage, attack_kind) <= 0:
		return
	target.play_hit_effect(self)
	apply_knockback(target)
	if obj_attack_dict[attack_name].has("addeffect"):
		_apply_attack_effect(target, obj_attack_dict[attack_name]["addeffect"])


func apply_knockback(target: BaseMonster) -> void:
	if not is_instance_valid(target):
		return
	if target.is_control_immune() or target.get("is_indestructible") == true:
		return
	var hurt_back = obj_attack_dict.get(hit_name, {}).get("hurtBack", [0, 0]) if hit_name else [0, 0]
	var knockback_x = hurt_back[0]
	var knockback_y = hurt_back[1]

	if monster_dir.scale.x == -1:
		target.velocity.x = -knockback_x * 10
	else:
		target.velocity.x = knockback_x * 10
	target.velocity.y = knockback_y * 5


func _persist_active_pet_death() -> void:
	var is_tiger := bool(get_meta("pet_tiger_unit", false))
	var is_dragon := bool(get_meta("pet_dragon_unit", false)) and not bool(get("is_dragon_clone"))
	var is_phoenix := bool(get_meta("pet_phoenix_unit", false))
	var is_rabbit := bool(get_meta("pet_rabbit_unit", false))
	var is_mouse := bool(get_meta("pet_mouse_unit", false))
	var is_neat := bool(get_meta("pet_neat_unit", false))
	var is_yin_tiger := bool(get_meta("pet_yin_tiger_unit", false))
	var is_turtle := bool(get_meta("pet_turtle_unit", false)) and not is_rabbit and not is_mouse
	if (
		not is_tiger
		and not is_dragon
		and not is_phoenix
		and not is_turtle
		and not is_rabbit
		and not is_mouse
		and not is_neat
		and not is_yin_tiger
	):
		return
	var level_node := get_level_node()
	if level_node == null:
		return
	var pet_type := (
		"PetYinTiger"
		if is_yin_tiger
		else (
			"PetNeat"
			if is_neat
			else (
				"PetMouse"
				if is_mouse
				else (
					"PetRabbit"
					if is_rabbit
					else (
						"PetTurtle"
						if is_turtle
						else "PetTiger" if is_tiger else "PetPhoenix" if is_phoenix else "PetDragon"
					)
				)
			)
		)
	)
	var pet_display_name := ""
	var data_value: Variant = get("pet_data")
	if data_value is Dictionary:
		data_value[DataKeys.HP] = 0
		pet_display_name = str(data_value.get(DataKeys.ALT_NAME, ""))
	if pet_display_name == "":
		pet_display_name = str(PlayerData.player_data.get("出战宠物", ""))
	var slot := LocalCoop.slot_for(self)
	var dead_pet_keys_value: Variant = level_node.get_meta(LocalCoop.pet_meta_key("active_pet_dead_keys", slot), [])
	var dead_pet_keys: Array = dead_pet_keys_value.duplicate() if dead_pet_keys_value is Array else []
	for dead_key in [pet_type, pet_display_name]:
		if dead_key != "" and not dead_pet_keys.has(dead_key):
			dead_pet_keys.append(dead_key)
	level_node.set_meta(LocalCoop.pet_meta_key("active_pet_dead_keys", slot), dead_pet_keys)
	level_node.set_meta(LocalCoop.pet_meta_key("active_pet_dead_this_level", slot), true)
	level_node.set_meta(LocalCoop.pet_meta_key("active_pet_dead_name", slot), pet_type)
	level_node.set_meta(LocalCoop.pet_meta_key("active_pet_dead_type", slot), pet_type)
	level_node.set_meta(LocalCoop.pet_meta_key("active_pet_dead_display_name", slot), pet_display_name)


func _handle_death() -> void:
	_persist_active_pet_death()
	if monster_blood_bar:
		monster_blood_bar.queue_free()
		monster_blood_bar = null
	await get_tree().create_timer(1.5).timeout
	queue_free()


func _exit_tree() -> void:
	_clear_visual_resources(self)
	if monster_blood_bar:
		monster_blood_bar.queue_free()
	for i in round_list:
		if is_instance_valid(i):
			i.queue_free()
	round_list.clear()


func _clear_visual_resources(node: Node) -> void:
	if node is AnimatedSprite2D:
		var animated_sprite := node as AnimatedSprite2D
		animated_sprite.stop()
		animated_sprite.sprite_frames = null
	elif node is Sprite2D:
		var sprite := node as Sprite2D
		sprite.texture = null
	for child in node.get_children():
		_clear_visual_resources(child)


func _get_pet_protect_gain(_attacker: Node) -> int:
	return randi_range(3, 7)


func _pet_protect_active() -> bool:
	return need_protect or current_protect >= max_protect


func _add_pet_protect(value: int) -> void:
	if value <= 0 or hp <= 0 or need_protect:
		return
	current_protect = clampf(current_protect + float(value), 0.0, max_protect)
	if current_protect >= max_protect:
		current_protect = max_protect
		need_protect = true
		need_remove_protect = true
		protect_hold_time = randf_range(3.0, 4.0)
		if hurt_box != null:
			hurt_box.set_deferred("disabled", true)
		modulate = Color(1, 1, 1, 0.5)


func _clear_pet_protect() -> void:
	need_protect = false
	need_remove_protect = false
	protect_hold_time = 0.0
	current_protect = 0.0
	if hurt_box != null:
		hurt_box.set_deferred("disabled", false)
	modulate = Color(1, 1, 1, 1)


func _process_pet_protect(delta: float) -> void:
	if current_protect > 0.0:
		if need_remove_protect:
			current_protect = max(0.0, current_protect - 1.0)
		else:
			current_protect = max(0.0, current_protect - 0.05)
	if need_protect:
		protect_hold_time -= delta
		if protect_hold_time <= 0.0:
			_clear_pet_protect()


func apply_stun_to_target(target: BaseMonster, duration: float = 3.0) -> void:
	if not is_instance_valid(target) or target.hp <= 0:
		return
	var stun_buff = {
		"Name": "stun",
		"AddTime": duration,
		"reduce_interval": 0,
		"value": 0,
		"AttackKind": "",
		"DeBuff": true,
		"CanRemove": false
	}
	if not target.has_node("Buff"):
		target.add_child(Node.new())
		target.get_node("Buff").name = "Buff"
	Global.add_buff(target.get_node("Buff"), stun_buff)


func apply_defense_reduce_to_target(target: BaseMonster, duration: float = 20.0, reduce_value: float = 1.0) -> void:
	if not is_instance_valid(target) or target.hp <= 0:
		return
	var defense_reduce_buff = {
		"Name": "defe_reduce",
		"AddTime": duration,
		"reduce_interval": 0,
		"value": reduce_value,
		"AttackKind": "",
		"DeBuff": true,
		"CanRemove": false
	}
	if not target.has_node("Buff"):
		target.add_child(Node.new())
		target.get_node("Buff").name = "Buff"
	Global.add_buff(target.get_node("Buff"), defense_reduce_buff)


func get_level_node() -> Node:
	if level_cache_valid and is_instance_valid(base_level):
		return base_level
	var tree = get_tree()
	if not tree:
		base_level = self
		level_cache_valid = true
		return base_level
	var node = get_parent()
	while node:
		if node is BaseLevel:
			base_level = node
			level_cache_valid = true
			return base_level
		node = node.get_parent()
	var base_levels = tree.get_nodes_in_group("BaseLevel")
	if not base_levels.is_empty():
		base_level = base_levels[0]
		level_cache_valid = true
		return base_level
	var scene_root = tree.current_scene
	if scene_root and scene_root.has_node("BaseLevel"):
		base_level = scene_root.get_node("BaseLevel")
		level_cache_valid = true
		return base_level
	var all_nodes = tree.get_nodes_in_group("level_container")
	if not all_nodes.is_empty():
		base_level = all_nodes[0]
		level_cache_valid = true
		return base_level
	base_level = tree.current_scene if tree.current_scene else self
	level_cache_valid = true
	return base_level


func invalidate_level_cache() -> void:
	level_cache_valid = false


func setup_bullet_collision(bullet_instance) -> Node:
	if bullet_instance and bullet_instance.has_node("middle/HitBox"):
		var hit_box_area = bullet_instance.get_node("middle/HitBox") as Area2D
		if hit_box_area:
			hit_box_area.collision_layer = 2
			hit_box_area.collision_mask = 2048
			bullet_instance.set_meta("is_summon_bullet", true)
			bullet_instance.set_meta("summoner", self)
			hit_box_area.connect("area_entered", Callable(self, "_on_summon_bullet_hit").bind(bullet_instance))
	return bullet_instance


func despawn() -> void:
	if despawn_effect_enabled:
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5)
		tween.tween_callback(queue_free)
	else:
		queue_free()


func set_summon_properties(summoner_node: Node, duration: float = 60.0) -> void:
	summoner = summoner_node
	summon_duration = duration
	is_friendly = true
	is_summon = true
	if summoner_node is BaseHero:
		player_reference = summoner_node
		var summoner_level = summoner_node.get("level")
		level = (
			int(summoner_level)
			if summoner_level != null
			else int(PlayerData.player_data.get(DataKeys.PLAYER_LEVEL, level))
		)
	else:
		find_player_reference()
		level = int(PlayerData.player_data.get(DataKeys.PLAYER_LEVEL, level))


func tween_to_top() -> void:
	should_in_sky = true
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(0, -250) + position, 0.2)


func tween_to_top_2() -> void:
	should_in_sky = true
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(position.x, 100), 1)


func drop() -> void:
	should_in_sky = false
	in_sky_timer = 0.0


func move_monster_to_boss(target_monster, movetime: float = 1.0) -> void:
	if is_instance_valid(target_monster):
		var tween = create_tween()
		tween.tween_property(target_monster, "position", position, movetime)


func attract_monsters(movetime: float = 1.0) -> void:
	var level_node = get_level_node()
	if level_node and level_node.has_node("Monster"):
		var monster_container = level_node.get_node("Monster")
		for monster in monster_container.get_children():
			if monster is BaseMonster and monster != self and monster.hp > 0:
				move_monster_to_boss(monster, movetime)


func initialize_monster_properties() -> void:
	pass


func setup_skills() -> void:
	pass


func get_attack_animations() -> Dictionary:
	return {}


func _on_calm_hit_timeout() -> void:
	rndi_count = randi_range(0, 100)


func _on_remove_hurt_bl_timeout() -> void:
	hurt_bl = 1.0

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
