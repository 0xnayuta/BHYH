extends Node2D
var idle = true
var value: int
@onready var chekc: CollisionShape2D = $Check/Chekc

var speed: float = 0
var tween
var target_monster: Monster141


func _ready() -> void:
	self.modulate = Color(1, 1, 1, 0)


func _physics_process(delta: float) -> void:
	if idle:
		tween = create_tween().set_parallel(true)
		tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 1.5)
		tween.tween_property(self, "position", position + Vector2(0, -randi_range(20, 40)), 0.4)
		await get_tree().create_timer(0.6, false).timeout
		idle = false
	if not idle:
		self.position += NodeUtils.position_between(self, target_monster) * speed * 0.5
		chekc.disabled = false
		if target_monster == null:
			self.queue_free()
		speed += 0.2
		if speed >= 20:
			speed = 20


func _on_check_body_entered(body: Node2D) -> void:
	if body is Monster141:
		var cure_value = int(body.max_hp - body.hp) * 0.03
		body.cure_hp(cure_value)
		queue_free()
