extends BaseObject
class_name Role6

const BaseMonster = preload("res://Script/base/base_monster.gd")
const BaseHero = preload("res://Script/base/base_hero.gd")

var monster_instance: BaseMonster
var monster_instance1: BaseHero

@onready var bullet: Node = $Bullet
@onready var hit_box: CollisionShape2D = $BaseDamageBox/HitBox/HitBox
@onready var hurt_box: CollisionShape2D = $BaseDamageBox/HurtBox/HurtBox
@onready var damage_text: Node2D = $damage_text
@onready var base_damage_box: Node2D = $BaseDamageBox
@onready var buff: Node = $Buff
@onready var pz: CollisionShape2D = $pz
@onready var mr_player: AnimationPlayer = $mr_player
@onready var mr_ani: AnimatedSprite2D = $MonsterDir/mr_ani
@onready var monster_dir: Node2D = $MonsterDir
@onready var remove_hurt_bl: Timer = $RemoveHurtBL

var is_sky = false
var is_friendly: bool = true
var current_target: BaseMonster = null
var monster_target_group: String = "monsters"
var player_reference: BaseHero = null
var force_collision_setup: bool = true

var monster_blood_bar = null
var my_blood = null

var has_target: bool = false
var count: int = 0
var is_quiescent: bool = false

var attack_range: int = 85
var mysee: int = 300
var speed: int = 11
var attack_desire: int = 90
var run_hit: bool = true
var run_hit_count: int = 90

var target_search_timer: float = 0.0
var target_search_interval: float = 1.0
var all_monsters: Array = []

var return_to_player_distance: int = 500
var return_timer: float = 0.0
var return_check_interval: float = 2.0

var move_timer: float = 0.0
var move_direction: int = 0
var move_duration: float = 2.0


func wd_hurt():
	pass


func _ready() -> void:
	max_hp = 90000
	hp = max_hp

	if not has_node("Buff"):
		var buff_node = Node.new()
		buff_node.name = "Buff"
		add_child(buff_node)
		buff = buff_node

	no_debuff = false

	initialize_monster_properties()

	mr_player.play("wait")

	base_damage_box.scale.x = 1
	monster_dir.scale.x = 1

	find_player_reference()

	move_direction = 0


func initialize_monster_properties():
	attack_range = 85
	mysee = 30000
	speed = 11
	attack_desire = 90
	run_hit = true
	run_hit_count = 90

	self.obj_attack_dict["hit1"] = {"power": 100000, "hurtBack": [-4, -9], "attackKind": "physics", "HitProtect": 15}


func find_player_reference():
	var tree = get_tree()
	if tree:
		var current_scene = tree.current_scene
		if current_scene and current_scene.has_node("Hero"):
			var hero_node = current_scene.get_node("Hero")
			if hero_node and hero_node.get_child_count() > 0:
				for child in hero_node.get_children():
					if child is BaseHero:
						player_reference = child
						break


func _physics_process(delta: float) -> void:
	if is_sky == true:
		gravity = 0
		velocity.y = 0
	else:
		gravity = -980.0

	if not is_on_floor():
		velocity.y -= gravity * delta

	count += 1

	target_search_timer += delta

	return_timer += delta

	move_timer += delta

	if target_search_timer >= target_search_interval:
		search_for_targets()
		target_search_timer = 0.0

	if return_timer >= return_check_interval and player_reference:
		check_return_to_player()
		return_timer = 0.0

	little_blood_bar_control()

	if not death() and not is_attacking:
		ai_think()

	if not death():
		if is_attacking:
			mr_player.play("hit1")
		elif is_be_attacking:
			pass
		elif velocity.x != 0:
			mr_player.play("walk")
		else:
			mr_player.play("wait")

		if velocity.x > 0:
			base_damage_box.scale.x = -1
			monster_dir.scale.x = -1
		elif velocity.x < 0:
			base_damage_box.scale.x = 1
			monster_dir.scale.x = 1

	wd_hurt()

	move_and_slide()

	RoleProp.role_pos_x = position.x
	RoleProp.role_pos_y = position.y
	RoleProp.role_pos = position

	if death():
		velocity.x = 0
		velocity.y = 0
		mr_player.play("death")

		call_deferred("_handle_death")


func search_for_targets():
	all_monsters.clear()

	var tree = get_tree()
	if tree:
		var current_scene = tree.current_scene
		var monster_nodes: Array = []
		if (
			current_scene != null
			and current_scene.has_method("has_active_monster_index")
			and current_scene.has_active_monster_index()
		):
			monster_nodes = current_scene.get_active_monsters()
		else:
			monster_nodes = tree.get_nodes_in_group("monsters")

		for monster in monster_nodes:
			if monster and monster != self and monster is BaseMonster:
				if monster.hp > 0:
					all_monsters.append(monster)

		if all_monsters.size() == 0:
			if current_scene and current_scene.has_node("Monster"):
				var monster_container = current_scene.get_node("Monster")
				if monster_container:
					for child in monster_container.get_children():
						if child and child is BaseMonster and child != self and child.hp > 0:
							all_monsters.append(child)

	if all_monsters.size() > 0:
		var closest_monster = null
		var closest_distance = INF

		for monster in all_monsters:
			var distance = position.distance_to(monster.position)
			if distance < closest_distance:
				closest_distance = distance
				closest_monster = monster

		current_target = closest_monster
		has_target = true
	else:
		current_target = null
		has_target = false

		stop_move()
		move_direction = 0


func ai_think():
	if not current_target or not is_instance_valid(current_target):
		idle_behavior()
		return

	if current_target.hp <= 0:
		has_target = false
		current_target = null
		idle_behavior()
		return

	var target_pos = current_target.position

	var distance_to_target = abs(position.x - target_pos.x)

	if distance_to_target < mysee:
		has_target = true

		if distance_to_target > attack_range:
			if target_pos.x > position.x:
				move_right()
			else:
				move_left()

			if run_hit and not is_be_attacking:
				if count % run_hit_count == 0:
					if randi_range(0, 100) <= attack_desire:
						attack_target()
		else:
			stop_move()

			if not is_be_attacking and count % 60 == 0:
				if randi_range(0, 100) < attack_desire:
					attack_target()
	else:
		has_target = false
		current_target = null
		idle_behavior()


func idle_behavior():
	"待机行为：没有目标时的逻辑"

	stop_move()

	if not is_be_attacking and not is_attacking:
		mr_player.play("wait")


func move_left():
	base_damage_box.scale.x = 1
	monster_dir.scale.x = 1
	velocity.x = -speed * 10
	move_direction = -1


func move_right():
	base_damage_box.scale.x = -1
	monster_dir.scale.x = -1
	velocity.x = speed * 10
	move_direction = 1


func stop_move():
	velocity.x = 0
	move_direction = 0


func attack_target():
	if not current_target or not is_instance_valid(current_target):
		return

	if current_target.position.x > position.x:
		base_damage_box.scale.x = -1
		monster_dir.scale.x = -1
	else:
		base_damage_box.scale.x = 1
		monster_dir.scale.x = 1

	is_attacking = true
	mr_player.play("hit1")

	await mr_player.animation_finished

	reset_attack_state()

	stop_move()


func check_return_to_player():
	"检查是否需要返回玩家身边"
	if not player_reference:
		return

	var distance_to_player = position.distance_to(player_reference.position)

	if distance_to_player > return_to_player_distance:
		return_to_player()


func return_to_player():
	"瞬移到玩家身边"
	if not player_reference:
		return

	var offset_x = 50 * (1 if randf() > 0.5 else -1)
	position.x = player_reference.position.x + offset_x
	position.y = player_reference.position.y

	reset_attack_state()

	current_target = null
	has_target = false


func little_blood_bar_control():
	if MainSet.set_data["MonsterLittleBlood"] and MainSet.set_data["NoShowMonsterBody"]:
		if monster_blood_bar == null and hp > 0:
			monster_blood_bar = Global.add_monster_blood(self, Vector2(-30, -90), hp / float(max_hp), hp)
		elif monster_blood_bar != null:
			if not is_be_attacking:
				monster_blood_bar.can_show = false
				monster_blood_bar.bar_value = float(hp) / float(max_hp)
				monster_blood_bar.bar_text = hp
			else:
				monster_blood_bar.bar_value = float(hp) / float(max_hp)
				monster_blood_bar.bar_text = hp
				monster_blood_bar.can_show = true

			if hp <= 0 and monster_blood_bar != null:
				monster_blood_bar.queue_free()
				monster_blood_bar = null


func death():
	return self.hp <= 0


func reduce_hp(value: int, target_boss, target_obj):
	if self.hp <= 0:
		return
	self.hp -= value

	is_be_attacking = true

	if value > 0:
		var level_node = get_parent().get_parent() as BaseLevel
		if level_node:
			var po = Vector2(self.position.x, self.position.y - 110)

			call_deferred("_show_damage_text", level_node, po, value, "physics", false)


func _show_damage_text(level_node, po: Vector2, value: int, type: String, is_crit: bool):
	Global.add_damage_text(level_node, po, value, type, is_crit, self)


func cure_hp(value: int = 0):
	if self.hp <= 0:
		return
	if self.hp + value >= self.max_hp:
		value = self.max_hp - self.hp
	self.hp += value
	if value > 0:
		var level_node = get_parent().get_parent() as BaseLevel
		if level_node:
			var po = Vector2(self.position.x, self.position.y - 110)

			call_deferred("_show_heal_text", level_node, po, value)
	return value


func _show_heal_text(level_node, po: Vector2, value: int):
	Global.add_damage_text(level_node, po, value, "cure", false, self)


func _on_hurt_box_area_entered(area: Area2D) -> void:
	is_be_attacking = true

	mr_player.play("hurt")

	call_deferred("_deferred_process_hurt", area)


func _deferred_process_hurt(area: Area2D):
	var last_hit = 10
	reduce_hp(last_hit, null, area)

	await get_tree().create_timer(0.2).timeout

	reset_attack_state()


func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.get_parent() and area.get_parent().get_parent():
		var target = area.get_parent().get_parent()

		if target is BaseMonster and target != self:
			var damage = 20
			if self.obj_attack_dict.has("hit1"):
				damage = self.obj_attack_dict["hit1"].get("power", 20)

			target.reduce_hp(damage)

			Global.get_audio_runtime().add_sound(self, "res://Music/monster_hurt/6_beattack_by_role1.mp3")


func _handle_death():
	if monster_blood_bar != null:
		monster_blood_bar.queue_free()
		monster_blood_bar = null

	await get_tree().create_timer(1.5).timeout
	queue_free()


func _exit_tree():
	if monster_blood_bar != null:
		monster_blood_bar.queue_free()


func reset_attack_state():
	"重置攻击和被攻击状态"
	is_be_attacking = false
	is_attacking = false

	if not death():
		if velocity.x != 0:
			mr_player.play("walk")
		else:
			mr_player.play("wait")
