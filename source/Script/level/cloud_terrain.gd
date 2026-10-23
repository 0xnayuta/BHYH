extends "res://Script/level/game4_palace_terrain.gd"

var screen_templates: Array[int] = [1]
var _moving: Array[Dictionary] = []
var _collapsing: Array[Dictionary] = []


func configure(level: Game4EastLateLevel, _number: int) -> void:
	_level = level
	source_data = JSON.parse_string(FileAccess.get_file_as_string(ASSET_ROOT + "level_75.json"))
	level.get_node("wall/floor").disabled = true
	_bind_scene_nodes()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not is_instance_valid(_level._role):
		return
	var hero: BaseHero = _level._role
	var shape := hero.get_node("pz") as CollisionShape2D
	var hero_rect := shape.shape.get_rect()
	hero_rect.position += shape.global_position - global_position
	for moving: Dictionary in _moving:
		var period := float(moving["period"])
		var phase := fposmod(_clock, period * 2.0)
		var distance := phase if phase <= period else period * 2.0 - phase
		moving["body"].position = (moving["home_position"] as Vector2) + (moving["speed"] as Vector2) * distance
	for cloud: Dictionary in _collapsing:
		if float(cloud["revive_at"]) >= 0.0:
			if _clock >= float(cloud["revive_at"]):
				cloud["shape"].set_deferred("disabled", false)
				cloud["sprite"].position = cloud["idle_position"]
				cloud["sprite"].play("default")
				cloud["collapse_at"] = -1.0
				cloud["revive_at"] = -1.0
			continue
		if float(cloud["collapse_at"]) >= 0.0:
			if _clock >= float(cloud["collapse_at"]):
				cloud["shape"].set_deferred("disabled", true)
				cloud["sprite"].position = (cloud["idle_position"] as Vector2) + (cloud["dead_offset"] as Vector2)
				cloud["sprite"].play("dead")
				cloud["revive_at"] = _clock + float(cloud["revive_delay"])
			continue
		var rect: Rect2 = cloud["rect"]
		if (
			hero.is_on_floor()
			and hero_rect.end.x > rect.position.x
			and hero_rect.position.x < rect.end.x
			and absf(hero_rect.end.y - rect.position.y) < 6.0
		):
			cloud["collapse_at"] = _clock + float(cloud["die_delay"])
