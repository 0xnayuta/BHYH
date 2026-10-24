extends Node2D

enum ColorType { WHITE, YELLOW, BLUE, RED }

var idle = true
var value: int = 0
var _collected := false
var color_type: ColorType = ColorType.WHITE

@onready var check: CollisionShape2D = $Check/Check
var speed: float = 0
var tween


func _ready() -> void:
	match color_type:
		ColorType.WHITE:
			self.modulate = Color(1, 1, 1, 0)
		ColorType.YELLOW:
			self.modulate = Color(1, 1, 0, 0)
		ColorType.BLUE:
			self.modulate = Color(0, 0.5, 1, 0)
		ColorType.RED:
			self.modulate = Color(1, 0.2, 0.2, 0)


func _physics_process(delta: float) -> void:
	if idle:
		tween = create_tween().set_parallel(true)
		match color_type:
			ColorType.WHITE:
				tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 1.5)
			ColorType.YELLOW:
				tween.tween_property(self, "modulate", Color(1, 1, 0, 1), 1.5)
			ColorType.BLUE:
				tween.tween_property(self, "modulate", Color(0, 0.5, 1, 1), 1.5)
			ColorType.RED:
				tween.tween_property(self, "modulate", Color(1, 0.2, 0.2, 1), 1.5)
		tween.tween_property(self, "position", position + Vector2(0, -randi_range(20, 40)), 0.4)
		await get_tree().create_timer(0.6, false).timeout
		idle = false

	if not idle:
		self.position += Global.get_position_between(self, RoleProp.source_player) * speed * 0.5
		check.disabled = false
		speed += 0.2
		if speed >= 20:
			speed = 20


func _on_check_body_entered(body: Node2D) -> void:
	if body is BaseHero and not _collected:
		_collected = true
		var hero = body as BaseHero

		PlayerData.add_soul(value)

		match color_type:
			ColorType.YELLOW:
				hero.RoleProp.ws_value += 5
			ColorType.BLUE:
				hero.cure_mp(10)
			ColorType.RED:
				hero.cure_hp(10)
			_:
				pass

		queue_free()
