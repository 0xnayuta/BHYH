extends Node2D
class_name ShenguangBossEffect

const SOURCE_FPS := 30.0

var owner_boss: BaseMonster
var effect_kind := "feather"
var hit_name := "hit1"
var skill_name := "ShenguangBossEffect"
var obj_attack_dict: Dictionary = {}
var frames: SpriteFrames
var animation_name: StringName = &"play"
var visual_offset := Vector2.ZERO
var collision_size := Vector2.ONE
var collision_offset := Vector2.ZERO
var motion_velocity := Vector2.ZERO
var lifetime := 2.0
var loop_animation := false
var hold_last_frame := false

var _visual: AnimatedSprite2D
var _middle: Node2D
var _finished := false


func _ready() -> void:
	if owner_boss == null or not is_instance_valid(owner_boss):
		queue_free()
		return
	obj_attack_dict = owner_boss.obj_attack_dict
	if frames == null or not frames.has_animation(animation_name):
		push_error("ShenguangBossEffect missing animation: " + String(animation_name))
		queue_free()
		return
	_build_visual()
	_middle = Node2D.new()
	_middle.name = "middle"
	add_child(_middle)
	if effect_kind == "poison":
		_run_poison_pulses()
	else:
		_create_attack_area(effect_kind == "feather")
	_expire_after(lifetime)


func _physics_process(delta: float) -> void:
	if effect_kind == "feather" and not _finished:
		position += motion_velocity * delta


func _build_visual() -> void:
	_visual = AnimatedSprite2D.new()
	_visual.name = "Visual"
	_visual.sprite_frames = frames
	_visual.animation = animation_name
	_visual.position = visual_offset
	_visual.z_index = 5
	if not motion_velocity.is_zero_approx():
		rotation = motion_velocity.angle()
	add_child(_visual)
	_visual.play(animation_name)
	if loop_animation:
		_visual.animation_finished.connect(_restart_loop)
	elif hold_last_frame:
		_visual.animation_finished.connect(_hold_last_frame)


func _restart_loop() -> void:
	if _finished or not loop_animation or _visual == null or not is_instance_valid(_visual):
		return
	_visual.play(animation_name)


func _hold_last_frame() -> void:
	if _visual == null or frames == null:
		return
	_visual.frame = maxi(0, frames.get_frame_count(animation_name) - 1)
	_visual.pause()


func _create_attack_area(disappear_on_hit: bool) -> void:
	if _middle == null or not is_instance_valid(_middle):
		return
	var area := Area2D.new()
	area.name = "HitBox"
	area.collision_layer = 4
	area.collision_mask = 896
	area.monitoring = true
	area.monitorable = true
	_middle.add_child(area)
	area.area_entered.connect(_on_attack_area_entered.bind(area, disappear_on_hit))

	var shape_node := CollisionShape2D.new()
	shape_node.name = "HitBox"
	shape_node.position = collision_offset
	var shape := RectangleShape2D.new()
	shape.size = collision_size
	shape_node.shape = shape
	area.add_child(shape_node)


func _on_attack_area_entered(hurt_area: Area2D, attack_area: Area2D, disappear_on_hit: bool) -> void:
	var role := _find_role_owner(hurt_area)
	if role == null:
		return
	if effect_kind == "poison" and owner_boss != null and owner_boss.has_method(&"apply_poison_buff"):
		owner_boss.call(&"apply_poison_buff", role)
	if effect_kind != "poison":
		attack_area.set_deferred("collision_layer", 0)
		attack_area.set_deferred("monitoring", false)
		if disappear_on_hit:
			call_deferred("queue_free")


func _find_role_owner(area: Area2D) -> BaseHero:
	var node: Node = area
	while node != null:
		if node is BaseHero:
			return node as BaseHero
		node = node.get_parent()
	return null


func _run_poison_pulses() -> void:
	for pulse_index in range(9):
		if _finished or owner_boss == null or not is_instance_valid(owner_boss) or owner_boss.death():
			return
		_create_poison_pulse()
		if pulse_index < 8:
			await get_tree().create_timer(1.0, false).timeout


func _create_poison_pulse() -> void:
	_create_attack_area(false)
	var area := _middle.get_child(_middle.get_child_count() - 1) as Area2D
	if area != null:
		_remove_pulse_area(area)


func _remove_pulse_area(area: Area2D) -> void:
	await get_tree().create_timer(0.1, false).timeout
	if area != null and is_instance_valid(area):
		area.queue_free()


func _expire_after(seconds: float) -> void:
	await get_tree().create_timer(maxf(seconds, 0.05), false).timeout
	if is_instance_valid(self):
		_finished = true
		queue_free()
