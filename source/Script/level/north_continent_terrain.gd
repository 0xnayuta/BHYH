extends "res://Script/level/game4_palace_terrain.gd"

var _moving: Array[Dictionary] = []
var _collapsing: Array[Dictionary] = []
var _source_objects: Array[Dictionary] = []
var _backgrounds: Dictionary = {}
var _void_floor: StaticBody2D
const VOID_FLOOR_RECT := Rect2(4300, 641, 2000, 38)
const VOID_ART_FLOOR_Y := 575.0
var _first_space_bodies: Array[Node] = []
var _darkness: CanvasModulate
var _portals: Array[Area2D] = []
var _background_copies: Array[Dictionary] = []


func configure(level: Game4EastLateLevel, number: int) -> void:
	_level = level
	source_data = level._north_data
	level.get_node("wall/floor").disabled = true
	level.get_node("wall/right_wall").disabled = true
	_death_y = float(source_data["height"]) + 100.0
	_bind_scene_nodes()
	for record: Dictionary in _source_objects:
		if record["type"] == "DragonItemEntity" and record.get("target") != null:
			record["target"].area_entered.connect(
				func(area):
					if area is BaseRoleHitBox or area is RoleBullet1 or area is RolehmzBullet or area is MagicWeaponHit:
						_break_dragon_statue(record)
			)
	if number == 80 and not level.hidden_original_room:
		set_maze_room(1)
	if number == 81:
		set_void_space(false)


func _physics_process(delta: float) -> void:
	_clock += delta
	var role = _level._role
	if not is_instance_valid(role):
		return
	var role_shape := role.get_node("pz") as CollisionShape2D
	var rect := role_shape.shape.get_rect()
	rect.position += role_shape.global_position - global_position
	for record: Dictionary in _moving:
		var period := float(record["period"])
		var phase := fmod(_clock, period * 2)
		record["body"].position = (
			record["home_position"] + record["speed"] * (phase if phase < period else period * 2 - phase)
		)
	for record: Dictionary in _collapsing:
		var surface: Rect2 = record["rect"]
		var standing: bool = (
			role.is_on_floor()
			and absf(rect.end.y - surface.position.y) < 8
			and rect.end.x > surface.position.x
			and rect.position.x < surface.end.x
		)
		if standing and float(record["stood"]) < 0:
			record["stood"] = _clock
		var delay := float(record["properties"].get("dieTime", "1000")) / 1000
		if float(record["stood"]) >= 0 and _clock - float(record["stood"]) >= delay and float(record["revive"]) < 0:
			record["revive"] = _clock + float(record["properties"].get("delayRevive", "2000")) / 1000
			record["body"].get_child(0).set_deferred("disabled", true)
			if record["sprite"] != null:
				record["sprite"].visible = false
		if float(record["revive"]) >= 0 and _clock >= float(record["revive"]):
			record["body"].get_child(0).set_deferred("disabled", false)
			if record["sprite"] != null:
				record["sprite"].visible = true
			record["stood"] = -1.0
			record["revive"] = -1.0
	for record: Dictionary in _source_objects:
		if _level.in_void_space:
			continue
		var box: Rect2 = record["rect"]
		var props: Dictionary = record["properties"]
		if (
			record["type"] == "DragonItemEntity"
			and float(record["revive_at"]) > 0
			and _clock >= float(record["revive_at"])
		):
			record["revive_at"] = 0.0
			record["sprite"].visible = true
			record["target"].set_deferred("monitoring", true)
		if record["type"] == "JITrigger" and box.intersects(rect) and not record["active"]:
			record["active"] = true
			for target: Dictionary in _source_objects:
				if target["properties"].get("triggerID", "") == props.get("trigger", "-1"):
					target["active"] = true
					target["start_at"] = _clock
		if (
			str(record["type"]).begins_with("Hurt")
			and box.intersects(rect)
			and _clock - float(record["last_hit"]) > 0.5
		):
			record["last_hit"] = _clock
			_damage_role(role, roundi(float(props.get("atk", "1200")) * 0.5), "magic")
		elif record["type"] == "StagePortTrigger" and box.intersects(rect):
			var camera := NorthOriginalData.numbers(props.get("stageRec", "0,0,1200,600"))
			_level.set_source_camera_rect(Rect2(float(camera[0]), float(camera[1]), float(camera[2]), float(camera[3])))
		elif props.get("groupType", "") == "sand" and box.intersects(rect) and role.is_on_floor():
			role.position.x -= 30.0 * delta
	if _darkness != null and _level.stage_number == 82:
		var night := false
		for record: Dictionary in _source_objects:
			if (
				record["type"] == "DayNightEntity"
				and record["active"]
				and absf(float(record["rect"].get_center().x) - role.position.x) < 650
			):
				night = fmod(_clock - float(record.get("start_at", 0)), 40.0) > 15.0
			if (
				record["type"] == "LightEntity"
				and _clock < float(record.get("lit_until", 0))
				and absf(float(record["rect"].get_center().x) - role.position.x) < 200
			):
				night = false
		_darkness.color = Color(0.35, 0.35, 0.5) if night else Color.WHITE
	if _level.stage_number == 80 and not _level.hidden_original_room:
		for portal in _portals:
			portal.visible = _level.maze_choices_ready()

		if Input.is_action_just_pressed("Exit"):
			for side in range(_portals.size()):
				if _portals[side].visible and _portals[side].overlaps_body(role):
					_level.enter_maze_gate(side)
					break
	if _level.stage_number != 85 and rect.end.y >= _death_y and not role.is_death:
		RoleProp.roleprop.Hp = 0
	for enemy in _level.monster.get_children():
		if enemy is BaseMonster:
			enemy.floor_max_angle = deg_to_rad(80)
			enemy.floor_snap_length = 18
			if _level.stage_number != 85 and enemy.position.y >= _death_y:
				enemy.hp = 0
	if _level.stage_number == 82:
		var clear: bool = _level.check_can_exit()
		for key in ["bg12", "bg12A"]:
			if _backgrounds.has(key):
				_backgrounds[key].visible = clear
		if _backgrounds.has("bg11"):
			_backgrounds["bg11"].visible = not clear


func set_maze_room(room: int) -> void:
	if _backgrounds.has("bg11"):
		_backgrounds["bg11"].visible = room == 8
	if _backgrounds.has("bg10"):
		_backgrounds["bg10"].visible = room != 8


func set_void_space(active: bool) -> void:
	for body in _first_space_bodies:
		for collision in body.get_children():
			if collision is CollisionShape2D or collision is CollisionPolygon2D:
				collision.set_deferred("disabled", active)
	for record: Dictionary in _source_objects:
		var body := record.get("body") as StaticBody2D
		if body == null:
			continue
		for collision in body.get_children():
			if collision is CollisionShape2D or collision is CollisionPolygon2D:
				if active:
					collision.set_meta("void_previous_disabled", collision.disabled)
					collision.set_deferred("disabled", true)
				elif collision.has_meta("void_previous_disabled"):
					collision.set_deferred("disabled", bool(collision.get_meta("void_previous_disabled")))
					collision.remove_meta("void_previous_disabled")
	_void_floor.get_child(0).set_deferred("disabled", not active)
	for key in _backgrounds:
		_backgrounds[key].visible = (key == "bg31") if active else (key != "bg31")


func void_landing_position(hero: BaseHero) -> Vector2:
	var collider := hero.get_node("pz") as CollisionShape2D
	var feet_offset := (
		collider.global_position.y
		+ collider.shape.get_rect().end.y * absf(collider.global_scale.y)
		- hero.global_position.y
	)
	var floor_rect := _scene_region(_void_floor.get_child(0))
	return Vector2(floor_rect.position.x + 100, floor_rect.position.y - feet_offset - 6)


func darken_for(seconds: float) -> void:
	if _darkness == null:
		return
	_darkness.color = Color(0.25, 0.25, 0.35)
	await get_tree().create_timer(seconds, false).timeout
	if is_instance_valid(_darkness):
		_darkness.color = Color.WHITE


func _break_dragon_statue(record: Dictionary) -> void:
	if float(record["revive_at"]) > 0:
		return
	record["revive_at"] = _clock + float(record["properties"].get("delayRevive", "21000")) / 1000
	record["sprite"].visible = false
	record["target"].set_deferred("monitoring", false)
	await get_tree().create_timer(0.5, false).timeout
	for light: Dictionary in _source_objects:
		if (
			light["type"] == "LightEntity"
			and light["properties"].get("triggerID", "") == record["properties"].get("dtrigger", "-1")
		):
			light["lit_until"] = _clock + float(light["properties"].get("lightTime", "20000")) / 1000
			var sprite: AnimatedSprite2D = light["sprite"]
			if sprite.sprite_frames.has_animation(&"attack1"):
				sprite.play(&"attack1")
