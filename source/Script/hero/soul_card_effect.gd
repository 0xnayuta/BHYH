## 7.4 魂卡/精英系统；由 7.4 反编译参考按当前 API、命名与路径适配。
extends RoleBullet1

const BOSS_VISUAL = preload("res://Script/hero/soul_card_boss_visual.gd")
var native_visual: Node2D
var visual_source = "qly"
var runtime: Node
var card_id = ""
var target: BaseMonster
var mode = "burst"
var shape = "ring"
var tint = Color("eac778")
var lifetime = 0.45
var interval = 0.5
var radius = 115.0
var age = 0.0
var next_pulse = 0.0
var hit_targets: Dictionary = {}
var struck = false
var start_position = Vector2.ZERO
var move_direction = Vector2.RIGHT
var projectile_speed = 650.0
var empowered = false
var scan_from = Vector2.ZERO
var scan_at = 0.0


func _init() -> void:
	var sprite = AnimatedSprite2D.new()
	sprite.name = "BulletAN"
	add_child(sprite)
	var animation = AnimationPlayer.new()
	animation.name = "BulletPlayer"
	add_child(animation)
	collision_layer = 0
	collision_mask = 0
	monitoring = false
	monitorable = false
	set_meta("soul_card_damage", true)


func _ready() -> void:
	z_index = 8
	is_set = true
	_name = "SoulCard"
	set_meta("skill_effect", true)
	native_visual = BOSS_VISUAL.create(visual_source, mode in ["field", "dot", "wheel", "projectile"])
	add_child(native_visual)
	if mode == "burst":
		lifetime = maxf(lifetime, float(native_visual.get_meta("native_duration", lifetime)))
	if is_instance_valid(player):
		start_position = global_position
		if is_instance_valid(target):
			move_direction = (target.global_position + Vector2(0, -45) - global_position).normalized()


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player) or player.is_death or not is_instance_valid(runtime):
		queue_free()
		return
	age += delta
	modulate.a = minf(1.0, maxf(0.0, (lifetime - age) * 5.0))
	if mode == "projectile":
		if scan_at <= 0.0:
			scan_from = global_position
		if shape == "arrow" and is_instance_valid(target) and not target.death():
			move_direction = (target.global_position + Vector2(0, -45) - global_position).normalized()
		global_position += move_direction * projectile_speed * delta
		rotation = move_direction.angle()
		if age < scan_at:
			return
		scan_at = age + 0.04
		for enemy in runtime.targets():
			if not is_instance_valid(enemy) or enemy.death():
				continue
			if hit_targets.has(enemy.get_instance_id()):
				continue
			var point: Vector2 = enemy.global_position + Vector2(0, -45)
			var closest = Geometry2D.get_closest_point_to_segment(point, scan_from, global_position)
			if point.distance_to(closest) <= maxf(32.0, radius * 0.75):
				_hit(enemy)
				hit_targets[enemy.get_instance_id()] = true
				if shape == "arrow" or shape == "snake":
					struck = true
					lifetime = minf(lifetime, age + 0.12)
					mode = "visual"
					break
		scan_from = global_position
	elif mode == "dot":
		if not is_instance_valid(target) or target.death():
			queue_free()
			return
		global_position = target.global_position + Vector2(0, -45)
		if age >= next_pulse:
			next_pulse += interval
			_hit(target)
	elif mode == "field" or mode == "wheel":
		if mode == "wheel":
			global_position.x += move_direction.x * 120.0 * delta
		if age >= next_pulse:
			next_pulse += interval
			for enemy in runtime.targets():
				if _within(enemy):
					_hit(enemy)
	elif mode == "burst" and not struck:
		struck = true
		for enemy in runtime.targets():
			if _within(enemy):
				_hit(enemy)
	if age >= lifetime:
		queue_free()


func _within(enemy: BaseMonster) -> bool:
	if not is_instance_valid(enemy) or enemy.death():
		return false
	var offset = enemy.global_position + Vector2(0, -45) - global_position
	return absf(offset.x) <= radius and absf(offset.y) <= 180.0


func _hit(enemy: BaseMonster) -> void:
	if not is_instance_valid(enemy) or enemy.death() or not is_instance_valid(runtime):
		return
	var amount = enemy.apply_role_hit(self, player)
	if amount > 0 and is_instance_valid(runtime):
		runtime.on_card_hit(card_id, enemy, shape, self)
