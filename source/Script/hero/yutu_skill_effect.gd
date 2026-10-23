extends RoleBullet
class_name YutuSkillEffect

const PARTS := preload("res://Script/hero/yutu_official_parts.gd")
const POISON := preload("res://Script/hero/yutu_poison.gd")
static var _moon_dance_masks: Dictionary = {}
var bank := "blade"
var effect_name := ""
var skill_id := ""
var skill_level := 1
var event: Dictionary = {}
var lifetime := 0.5
var elapsed := 0.0
var pulse_elapsed := 0.0
var hit_interval := 0.0
var follow := false
var origin := Vector2.ZERO
var follow_offset := Vector2.ZERO
var motion := Vector2.ZERO
var gravity_acceleration := 0.0
var next_skill := ""
var visual: Node2D
var _ending := false
var _hit_targets: Dictionary = {}
var _moon_next_tick := 0.0
var locked_target: WeakRef
var moon_has_target := false
var _pull_targets: Dictionary = {}
var _dance_track: Array = []
var _dance_frame := -1
var _dance_active := false
var moon_wheel_awakened := false
var poison_needle_awakened := false
var poison_powder_awakened := false
var poison_jar_awakened := false
var jar_extra_explosions := 0
var _jar_repeat_spawned := false
var _wheel_scan_elapsed := 0.0
var _dance_pulse := -1
var dance_hits: Dictionary = {}
var _bounds_frame := -1


func _ready() -> void:
	top_level = true
	super._ready()
	visual = Sprite2D.new()
	visual.set_script(PARTS)
	visual.set("offset", Vector2(0, -188))
	middle.add_child(visual)
	visual.load_set(bank)
	visual.set_pose(effect_name, 0)
	middle.scale.x = 1.0 if direction else -1.0
	if poison_powder_awakened:
		middle.scale *= YutuSkillData.POWDER_AWAKEN_SCALE
	if int(event.get("arrow", 0)) == 1:
		var shoot_y := motion.y if poison_needle_awakened else float(event.get("shootSpeedY", 0))
		middle.rotation = atan2(shoot_y, absf(motion.x)) * (1.0 if direction else -1.0)
	var shape := RectangleShape2D.new()
	shape.size = Vector2(140, 110)
	collion.shape = shape
	collion.position = Vector2(0, -45)
	var moon_area := skill_id == "1112040" and effect_name == "effect4_2"
	collion.disabled = hit_dic.is_empty() and not moon_area
	if skill_id == "1112050":
		if _moon_dance_masks.is_empty():
			_moon_dance_masks = JSON.parse_string(
				FileAccess.get_file_as_string("res://Art/hero_picture/role_7/moon_dance_collision.json")
			)
		_dance_track = _moon_dance_masks.tracks.get(effect_name, [])
		collion.shape = ConvexPolygonShape2D.new()
		collion.position = Vector2.ZERO

		hit_box.monitorable = false
		hit_interval = 0.0
	if moon_area:
		hit_box.monitorable = false
		hit_interval = 0.0
	origin = global_position
	_update_bounds()


func _update_bounds() -> void:
	if skill_id == "1112050":
		var frame := int(elapsed * 30.0)
		if frame != _dance_frame:
			_dance_frame = frame

			var pulse := clampi(
				floori(float(frame - 2) * YutuSkillData.MOON_DANCE_HITS / 41.0), 0, YutuSkillData.MOON_DANCE_HITS - 1
			)
			if pulse != _dance_pulse:
				_dance_pulse = pulse
				_hit_targets.clear()
			var polygon: Array = _dance_track[frame] if frame < _dance_track.size() else []
			_dance_active = not polygon.is_empty()
			collion.disabled = not _dance_active
			if _dance_active:
				var points := PackedVector2Array()
				for point: Array in polygon:
					points.append(Vector2(float(point[0]), float(point[1])))
				(collion.shape as ConvexPolygonShape2D).points = points
		return
	if collion.disabled:
		return
	var current_frame: int = visual.get("frame_index")
	if current_frame == _bounds_frame:
		return
	_bounds_frame = current_frame

	var commands: PackedFloat32Array = visual.get("_poses")
	var regions: Array = visual.get("_regions")
	var offset: int = visual.get("_offset")
	var count: int = visual.get("_count")
	var bounds := Rect2()
	var found := false
	for p in range(offset, offset + count * 9, 9):
		var region: Rect2 = regions[int(commands[p])]
		var transform := Transform2D(
			Vector2(commands[p + 1], commands[p + 2]),
			Vector2(commands[p + 3], commands[p + 4]),
			Vector2(commands[p + 5], commands[p + 6])
		)
		var rect := transform * Rect2(Vector2.ZERO, region.size)
		bounds = bounds.merge(rect) if found else rect
		found = true
	if found and bounds.size.x > 0 and bounds.size.y > 0:
		(collion.shape as RectangleShape2D).size = bounds.size
		collion.position = bounds.get_center()


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player) or player.is_death:
		queue_free()
		return
	elapsed += delta
	pulse_elapsed += delta
	if (
		poison_jar_awakened
		and jar_extra_explosions > 0
		and not _jar_repeat_spawned
		and not _ending
		and elapsed >= YutuSkillData.JAR_AWAKEN_INTERVAL
	):
		_jar_repeat_spawned = true
		var repeat_event := event.duplicate(true)
		repeat_event["yutu_jar_awakened"] = true
		repeat_event["yutu_jar_remaining"] = jar_extra_explosions - 1
		player._spawn_event.call_deferred(repeat_event, skill_id, skill_level, global_position, {})
	if follow:
		direction = player.player_dir
		follow_offset.x = absf(follow_offset.x) * (1.0 if direction else -1.0)
		global_position = player.global_position + follow_offset
		middle.scale.x = 1.0 if direction else -1.0
	else:
		var previous_position := global_position
		motion.y += gravity_acceleration * delta
		position += motion * delta
		if int(event.get("arrow", 0)) == 1 and not motion.is_zero_approx():
			middle.rotation = atan2(motion.y, absf(motion.x)) * (1.0 if direction else -1.0)
		if bool(event.get("collideGroundBomb", 0)) or bool(event.get("collideWallBomb", 0)):
			var query := PhysicsRayQueryParameters2D.create(previous_position, global_position, 33)
			query.exclude = [player.get_rid()]
			var collision := get_world_2d().direct_space_state.intersect_ray(query)
			if not collision.is_empty():
				global_position = collision.position
				_finish()
				return
	if skill_id == "1112040" and effect_name in ["effect4_2", "effect4_3"]:
		var target: BaseMonster = locked_target.get_ref() if locked_target != null else null
		if not player._is_auto_battle_target_valid(target):
			target = player.find_moon_target(global_position)
			locked_target = weakref(target) if target != null else null
		if target != null:
			global_position = (
				global_position.move_toward(target.global_position, 300.0 * delta)
				if moon_has_target
				else target.global_position
			)
			moon_has_target = true
	visual.set_time(effect_name, elapsed)
	_update_bounds()
	if skill_id == "1112050" and _dance_active:
		for area: Area2D in hit_box.get_overlapping_areas():
			_on_hit_box_area_entered(area)
	if skill_id == "1112031":
		if moon_wheel_awakened:
			_wheel_scan_elapsed -= delta
			if _wheel_scan_elapsed <= 0.0:
				_wheel_scan_elapsed = 0.1
				_collect_awakened_wheel_targets()
		else:
			for area: Area2D in hit_box.get_overlapping_areas():
				var target := _get_monster_from_hit_area(area)
				if target != null and not target.cannot_attract:
					_pull_targets[target.get_instance_id()] = {"target": weakref(target), "until": elapsed + 1.034}
		var pull_speed := (
			float(YutuSkillData.buff_row("1710007", skill_level).get("attributeV1", "23"))
			* YutuHero.OFFICIAL_SPEED_SCALE
		)
		for key in _pull_targets.keys():
			var entry: Dictionary = _pull_targets[key]
			var target: BaseMonster = entry.target.get_ref()
			if (
				not is_instance_valid(target)
				or target.is_death
				or target.cannot_attract
				or elapsed > float(entry.until)
			):
				_pull_targets.erase(key)
				continue
			if moon_wheel_awakened:
				target.global_position = target.global_position.move_toward(global_position, pull_speed * delta)
			else:
				var toward := global_position - target.global_position
				var displacement := toward.normalized().x * pull_speed * delta
				target.global_position.x = move_toward(target.global_position.x, global_position.x, absf(displacement))
	if skill_id == "1112040" and effect_name == "effect4_2" and elapsed >= _moon_next_tick:
		_moon_next_tick = elapsed + 0.25
		_apply_moon_area()
	if hit_interval > 0.0 and pulse_elapsed >= hit_interval:
		pulse_elapsed = 0.0
		_hit_targets.clear()
		hit_box.set_deferred("monitorable", false)
		hit_box.set_deferred("monitoring", false)
		_rearm.call_deferred()
	if elapsed >= lifetime:
		_finish()


func _collect_awakened_wheel_targets() -> void:
	var level := get_tree().current_scene
	var candidates: Array = (
		level.call("get_active_monsters")
		if is_instance_valid(level) and level.has_method("get_active_monsters")
		else get_tree().get_nodes_in_group("monsters")
	)
	var screen := get_viewport_rect()
	for candidate in candidates:
		if not player._is_auto_battle_target_valid(candidate):
			continue
		var target := candidate as BaseMonster
		if target.cannot_attract:
			continue
		var screen_position := target.get_global_transform_with_canvas() * Vector2(0, -40)
		if screen.has_point(screen_position):
			_pull_targets[target.get_instance_id()] = {"target": weakref(target), "until": elapsed + 1.034}


func _rearm() -> void:
	await get_tree().physics_frame
	if is_inside_tree() and not _ending:
		hit_box.set_deferred("monitorable", true)
		hit_box.set_deferred("monitoring", true)


func _finish() -> void:
	if _ending:
		return
	_ending = true
	if next_skill != "" and is_instance_valid(player):
		player.spawn_skill_events.call_deferred(next_skill, skill_level, global_position)
	queue_free()


func _on_hit_box_area_entered(area: Area2D) -> void:
	if skill_id == "1112050" and not _dance_active:
		return
	var target := _get_monster_from_hit_area(area)
	if target == null or _is_summon_or_pet_target(target) or hit_dic.is_empty():
		return
	var id := target.get_instance_id()
	if _hit_targets.has(id):
		return
	if skill_id == "1112050":
		if int(dance_hits.get(id, -1)) == _dance_pulse:
			return
		dance_hits[id] = _dance_pulse
	_hit_targets[id] = true
	if skill_id == "1112050":
		target.apply_role_hit(self, player)
	if skill_id in ["1111010", "1111020", "1111030", "1111031", "1111052", "1111053"]:
		var status := target.get_node_or_null("YutuPoison")
		if status == null:
			status = Node2D.new()
			status.name = "YutuPoison"
			status.set_script(POISON)
			target.add_child(status)
		var strong := skill_id in ["1111030", "1111031"]
		if skill_id in ["1111052", "1111053"]:
			var count := 6 + _extra_stacks(target, 12, 6)
			if poison_jar_awakened:
				count *= 2
			status.amplify(count, float(hit_dic.power), skill_level)
		else:
			var count := 3 if strong else 6
			if skill_id == "1111010":
				count += _extra_stacks(target, 12, 6)
				if poison_powder_awakened:
					count *= 2
			elif strong:
				count += _extra_stacks(target, 6, 3)
				if poison_needle_awakened:
					count *= 2
			status.add_poison(player, strong, count, skill_level, float(hit_dic.power), skill_id)
	if bool(event.get("collideGroundBomb", 0)):
		_finish()


func _extra_stacks(target: BaseMonster, maximum: int, base: int) -> int:
	var critical := maxf(0.0, float(RoleProp.roleprop.Crit) - float(target.toughness))
	var chance := critical / (critical + 100.0)
	if randf() > chance:
		return 0
	var luck := (float(RoleProp.roleprop.Lucky) - float(target.toughness)) / 100.0 * base
	var amount := floori(luck)
	if randf() < absf(luck - floorf(luck)):
		amount += 1
	return clampi(base + amount, 0, maximum)


func _apply_moon_area() -> void:
	for area: Area2D in hit_box.get_overlapping_areas():
		var target := _get_monster_from_hit_area(area)
		if target == null or target.buff == null:
			continue
		var amount := absf(float(YutuSkillData.buff_row("80244", skill_level).get("attributeV2", "-15")))
		target.set_meta("yutu_moon_defense", amount)
		target.set_meta("yutu_moon_until", Time.get_ticks_msec() + 1188)
