extends Node2D
class_name ZLWShenqiGearBullet

var player_data: PlayerDataStore:
	get:
		return LocalCoop.data_for(self)
var role_props: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self)

@onready var bullet_player: AnimationPlayer = $BulletPlayer
@onready var bullet_ani: AnimatedSprite2D = $middle/BulletANI
@onready var middle: Node2D = $middle
@onready var hit_box: Area2D = $middle/HitBox
@onready var hit_shape: CollisionShape2D = $middle/HitBox/Hit_Box
@onready var queue_timer: Timer = $queue_timer

var hit_dic = {"power": 0, "hurtBack": [0, 0], "attackKind": "magic"}
var follow_target: Node2D
var initial_angle: float = 0.0
var life_time: float = 3.0
var start_radius: float = 92.0
var end_radius: float = 340.0
var orbit_speed: float = 1.85
var gear_scale: Vector2 = Vector2(1.35, 1.35)
var _life_elapsed: float = 0.0
var _orbit_angle: float = 0.0
var hit_interval: float = 0.5
var _hit_targets: Dictionary = {}
var _overlap_poll_elapsed: float = 0.0
const OVERLAP_POLL_INTERVAL := 0.1


func _ready() -> void:
	if hit_box != null:
		hit_box.collision_layer = 2
		hit_box.collision_mask = 2064
		hit_box.monitoring = true
		hit_box.monitorable = true
		hit_box.area_entered.connect(_on_hit_box_area_entered)
	if queue_timer != null:
		queue_timer.timeout.connect(_on_queue_timer_timeout)
		queue_timer.start(life_time)
	if bullet_player != null:
		bullet_player.stop()
		bullet_player.active = false
	_orbit_angle = initial_angle
	if middle != null:
		middle.scale = gear_scale
	if bullet_ani != null:
		bullet_ani.position = Vector2.ZERO
		bullet_ani.scale = Vector2.ONE
		bullet_ani.animation = "Monster142Bullet1"
		bullet_ani.play()
	if hit_shape != null:
		hit_shape.position = Vector2.ZERO
		var circle := CircleShape2D.new()
		circle.radius = 115.0
		hit_shape.shape = circle
		hit_shape.disabled = false


func _physics_process(delta: float) -> void:
	if not role_props.is_ws_state:
		queue_free()
		return
	_life_elapsed += delta
	var progress = clamp(_life_elapsed / life_time, 0.0, 1.0)
	var expand_progress = pow(progress, 0.55)
	_orbit_angle += orbit_speed * delta
	var radius = lerp(start_radius, end_radius, expand_progress)
	var offset = Vector2(cos(_orbit_angle), sin(_orbit_angle)) * radius
	if is_instance_valid(follow_target):
		global_position = follow_target.global_position + offset
	else:
		position += offset.normalized() * 80.0 * delta
	if middle != null:
		middle.scale = gear_scale
		middle.rotation += orbit_speed * delta
	_overlap_poll_elapsed += delta
	if _overlap_poll_elapsed >= OVERLAP_POLL_INTERVAL:
		_overlap_poll_elapsed = 0.0
		_process_overlapping_targets()


func _on_hit_box_area_entered(area: Area2D) -> void:
	_try_hit_area(area)


func _process_overlapping_targets() -> void:
	if hit_box == null:
		return
	for area in hit_box.get_overlapping_areas():
		_try_hit_area(area)


func _try_hit_area(area: Area2D) -> void:
	var target = _find_monster_from_area(area)
	if target == null:
		return
	_try_hurt_monster(target)


func _try_hurt_monster(target: BaseMonster) -> void:
	if target.is_boss_protecting():
		return
	var target_id = target.get_instance_id()
	var now := Time.get_ticks_msec()
	var last_hit = int(_hit_targets.get(target_id, -1000000))
	if now - last_hit < int(hit_interval * 1000.0):
		return
	_hit_targets[target_id] = now
	_hurt_monster(target)
	if target.is_boss_protecting():
		return
	if hit_dic.has("addeffect") and randi_range(1, 100) <= int(hit_dic.get("stun_chance", 100)):
		Global.add_buff(target.buff, hit_dic["addeffect"])


func _find_monster_from_area(area: Area2D) -> BaseMonster:
	var node: Node = area
	while node != null:
		if node is BaseMonster:
			return node
		node = node.get_parent()
	return null


func _hurt_monster(monster: BaseMonster) -> void:
	var hurt = int(hit_dic.get("power", 0))
	var attack_kind = str(hit_dic.get("attackKind", "magic"))
	var is_crit := false
	var crit_value = max(0, role_props.roleprop.Crit - monster.crit_reduce)
	var crit_rate = snapped(crit_value / float(crit_value + 100), 0.001)
	if randf_range(0, 1) <= crit_rate:
		var lucky_value = max(0, role_props.roleprop.Lucky - monster.toughness)
		var crit_power = 2 + snapped(lucky_value / float(lucky_value + 100), 0.001)
		hurt = int(hurt * crit_power)
		is_crit = true
		Global.total_crit_count += 1
	if attack_kind == "physics":
		var reduce = snapped(monster.def / float(monster.def + 100), 0.001)
		hurt = int(hurt * (1 - reduce))
	elif attack_kind == "magic":
		var reduce = snapped(monster.mdef / float(monster.mdef + 100), 0.001)
		hurt = int(hurt * (1 - reduce))
	if hurt <= 0:
		return
	hurt = int(monster.hd_reduce(hurt))
	if hurt <= 0:
		return
	monster.hp -= hurt
	monster.total_hurt += hurt
	Global.get_audio_runtime().add_sound(monster, "res://Music/monster_hurt/6_beattack_by_role1.mp3")
	Global.total_role_hit += hurt
	if attack_kind == "physics":
		Global.total_phy_hit += hurt
	elif attack_kind == "magic":
		Global.total_mag_hit += hurt
	else:
		Global.total_real_hit += hurt
	var level_node = monster.get_level_node()
	if level_node != null:
		Global.add_damage_text(
			level_node, Vector2(monster.position.x - 20, monster.position.y - 240), hurt, attack_kind, is_crit, monster
		)
	if not monster.monster_18_protect() and not monster.monster102_protect() and not monster.is_control_immune():
		monster.get_target = self
		monster.state_hurt()


func _on_queue_timer_timeout() -> void:
	queue_free()
