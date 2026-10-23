extends "res://Script/monster/palace_boss_projectile.gd"

var bounce := false
var bounds := Rect2()
var shadow_callback := Callable()
var _shadow_contact := 0.0
var source_impact := Callable()


func configure(config: Dictionary) -> void:
	if config.has("gravity"):
		config = config.duplicate()
		config["acceleration"] = Vector2(0, float(config["gravity"]))
	bounce = bool(config.get("bounce", false))
	bounds = config.get("bounds", Rect2())
	shadow_callback = config.get("shadow_callback", Callable())
	source_impact = config.get("source_impact", Callable())
	super.configure(config)


func _begin_impact() -> void:
	if _impacting or _finished:
		return
	super._begin_impact()

	if source_impact.is_valid():
		source_impact.call(global_position)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not _finished and shadow_callback.is_valid() and is_instance_valid(owner_monster):
		var level := owner_monster.get_level_node()
		var hero: BaseHero = level._role if level is NorthContinentLevel else null
		if is_instance_valid(hero) and not hero.is_death:
			var collider := hero.get_node("pz") as CollisionShape2D
			var hero_rect := collider.shape.get_rect()
			hero_rect.position += collider.global_position
			var shadow_rect := Rect2(global_position - Vector2(75, 27.5), Vector2(150, 55))
			_shadow_contact = _shadow_contact + delta if hero_rect.intersects(shadow_rect) else 0.0
			if _shadow_contact >= 0.5:
				shadow_callback.call(global_position)
				_finish()
	if not bounce or _finished:
		return
	if global_position.x < bounds.position.x or global_position.x > bounds.end.x:
		motion_velocity.x *= -1
		global_position.x = clampf(global_position.x, bounds.position.x, bounds.end.x)
	if global_position.y < bounds.position.y or global_position.y > bounds.end.y:
		motion_velocity.y *= -1
		global_position.y = clampf(global_position.y, bounds.position.y, bounds.end.y)
