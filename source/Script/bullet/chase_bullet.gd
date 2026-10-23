extends Node2D
class_name ChaseBullet
var _speed
var _time
var _name
var dir: bool

@onready var que: Timer = $que
@onready var chase_player: AnimationPlayer = $ChasePlayer
@onready var chase_ani = $Chaseani
var level = 0
var def = 0
var mdef = 0
var crit = 0
var miss = 0
var lucky = 0
var htarget = 0
var toughness = 0
var ar = 0
var sp = 0
var crit_reduce = 0
var att_list
var obj_attack_dict = {}
var hit_name
var total_hit = 0
var is_get = false
var is_set = false

var owner_monster: BaseMonster = null
var detection_timer: float = 0
var detection_interval: float = 0.15
var current_direction_x: float = 0
var dead_zone_size: float = 80.0

var velocity: Vector2:
	set(val):
		velocity = val

		if _name != "Monster1402Bullet2" and _name != "Monster1402Bullet3" and _name != "Monster1408Bullet2":
			rotation = velocity.angle()


func _ready():
	set_meta("is_monster_bullet", true)


func _physics_process(delta: float) -> void:
	get_prop()
	if not is_set:
		que.wait_time = float(_time)
		que.start()
		chase_player.play(_name)
		is_set = true

	if _name == "Monster1402Bullet2" or _name == "Monster1408Bullet2":
		update_bullet2_direction(delta)
		velocity = Vector2(current_direction_x * _speed, 0)
		global_position += velocity * delta

	elif _name == "Monster1402Bullet3":
		update_bullet3_direction(delta)
		velocity = Vector2(current_direction_x * _speed, 0)
		global_position += velocity * delta

	else:
		var desired_angle = (
			global_position
			. direction_to(
				Vector2(
					RoleProp.get_nearest_monster_target_position(global_position).x,
					RoleProp.get_nearest_monster_target_position(global_position).y
				)
			)
			. angle()
		)
		var cur_angle = lerp_angle(rotation, desired_angle, 0.05)
		velocity = Vector2.RIGHT.rotated(cur_angle) * _speed
		global_position += velocity * delta


func update_bullet2_direction(delta: float):
	detection_timer += delta

	if detection_timer >= detection_interval:
		var target_x = RoleProp.get_nearest_monster_target_position(global_position).x
		var current_x = global_position.x
		var distance_x = target_x - current_x

		if abs(distance_x) > dead_zone_size:
			current_direction_x = sign(distance_x)
		else:
			if abs(distance_x) < dead_zone_size * 0.3:
				current_direction_x = 0

		detection_timer = 0


func update_bullet3_direction(delta: float):
	if owner_monster == null:
		owner_monster = get_parent().get_parent()
		if not owner_monster is BaseMonster:
			owner_monster = null

	detection_timer += delta

	if detection_timer >= detection_interval:
		var target_x: float

		if owner_monster != null and is_instance_valid(owner_monster):
			target_x = owner_monster.global_position.x
		else:
			target_x = RoleProp.get_nearest_monster_target_position(global_position).x

		var current_x = global_position.x
		var distance_x = target_x - current_x

		if abs(distance_x) > dead_zone_size:
			current_direction_x = sign(distance_x)
		else:
			if abs(distance_x) < dead_zone_size * 0.3:
				current_direction_x = 0

		detection_timer = 0


func get_prop():
	var tt = get_parent().get_parent()
	if tt is BaseMonster:
		level = tt.level
		def = tt.def
		mdef = tt.mdef
		crit = tt.crit
		miss = tt.miss
		lucky = tt.lucky
		htarget = tt.htarget
		toughness = tt.toughness
		ar = tt.ar
		sp = tt.sp
		crit_reduce = tt.crit_reduce
		total_hit = tt.total_hit

		if _name == "Monster1402Bullet3" and owner_monster == null:
			owner_monster = tt

	if hit_name != "":
		self.obj_attack_dict[hit_name] = att_list


func _on_que_timeout() -> void:
	if _name != "Monster1402Bullet2" and _name != "Monster1402Bullet3" and _name != "Monster1408Bullet2":
		add_other_bullet()
		queue_free()


func _on_hit_box_area_entered(area: Area2D) -> void:
	var target = area.get_parent().get_parent()

	if obj_attack_dict[hit_name].has("addeffect"):
		Global.add_buff(target.buff, obj_attack_dict[hit_name]["addeffect"])

	if _name != "Monster1402Bullet2" and _name != "Monster1402Bullet3" and _name != "Monster1408Bullet2":
		add_other_bullet()
		queue_free()

	if _name == "Monster1402Bullet3" and owner_monster != null and target == owner_monster:
		return


func add_other_bullet():
	match _name:
		"Monster33Bullet":
			Global.add_bullet(
				"Monster33Bullet", get_parent(), false, 1, Vector2(self.position.x, self.position.y), hit_name, att_list
			)
		"Monster37Bullet":
			Global.add_bullet(
				"Monster37Bullet", get_parent(), false, 1, Vector2(self.position.x, self.position.y), hit_name, att_list
			)
			Global.add_bullet(
				"PoisionBullet", get_parent(), false, 1, Vector2(self.position.x, self.position.y), hit_name, att_list
			)
