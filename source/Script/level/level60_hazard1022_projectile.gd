extends Area2D

const PROJECTILE_TEXTURE := preload("res://Art/level/level_59_60_terrain/hazard_1022_projectile.png")
const HIT_BOX_SIZE := Vector2(40.0, 16.0)

var _spawn_global_position := Vector2.ZERO
var _motion_velocity := Vector2.ZERO
var _target: Node2D
var _damage := 0
var _lifetime := 5.0
var _elapsed := 0.0
var _hit_count := 0


func configure(
	spawn_global_position: Vector2, motion_velocity: Vector2, target: Node2D, damage: int, lifetime: float
) -> void:
	_spawn_global_position = spawn_global_position
	_motion_velocity = motion_velocity
	_target = target
	_damage = damage
	_lifetime = lifetime


func _ready() -> void:
	set_as_top_level(true)
	global_position = _spawn_global_position
	collision_layer = 0
	collision_mask = 18
	monitoring = true
	monitorable = false

	var sprite := Sprite2D.new()
	sprite.texture = PROJECTILE_TEXTURE
	sprite.flip_h = _motion_velocity.x < 0.0
	add_child(sprite)

	var collision_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = HIT_BOX_SIZE
	collision_shape.shape = rectangle
	add_child(collision_shape)

	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	var remaining := maxf(_lifetime - _elapsed, 0.0)
	global_position += _motion_velocity * minf(delta, remaining)
	_elapsed += delta
	if _elapsed >= _lifetime:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if _hit_count >= 1 or body != _target:
		return
	_hit_count = 1
	set_deferred("monitoring", false)
	if body.has_method("effect_reducehp"):
		body.call("effect_reducehp", _damage, "physics")
	else:
		RoleProp.roleprop.Hp = maxi(0, int(RoleProp.roleprop.Hp) - _damage)
	queue_free()
