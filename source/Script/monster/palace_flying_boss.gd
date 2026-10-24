extends EastContinentMonster

signal skill_projectile_spawned(sequence: String, projectile: WutaiMinghaiProjectile)

const PALACE_PROJECTILE := preload("res://Script/monster/palace_boss_projectile.gd")
const SCOPES := {
	3323: [[0, 150, -125, 20], [0, 600, -150, 20], [0, 900, -600, 600], [0, 900, -600, 600]],
	3343: [[0, 160, -100, -20], [0, 900, -300, 300], [-85, 455, -300, 300], [205, 745, -300, 300], [0, 900, -300, 300]],
}
const MULTIPLIERS := {3323: [0.3, 0.2, 0.33, 0.67], 3343: [0.75, 0.67, 1.25, 1.25, 0.67]}
var _palace_data: Dictionary = {}
var _skill_cursor := 0
var _body_hit_count := 0
var _last_body_hit := -10000.0
var _palace_clock := 0.0
var _lightning_reverse := false
var _cast_direction := 1.0
var _cast_position := Vector2.ZERO
var _swallow_pending := false
var _ready_to_fight := false
var _palace_flight_y := 0.0
var _palace_flight_height_ready := false


func _metadata_path() -> String:
	return "res://Art/monster/palace_boss/%d/metadata.tres" % monster_kind


func _standard_body_frames_path() -> String:
	return "res://Art/monster/palace_boss/%d/palace_boss_%d_frames.tres" % [monster_kind, monster_kind]


func _resolve_runtime_config() -> Dictionary:
	var config := super._resolve_runtime_config()
	_palace_data = AtlasMetadataStore.data_for(_metadata_path())
	var animations: Dictionary = {
		&"wait": ["wait", true],
		&"walk": ["walk", true],
		&"Fly_wait": ["wait", true],
		&"Fly": ["walk", true],
		&"hurt": ["hurt", false],
		&"death": ["death", false]
	}
	var attacks: Dictionary = {}
	for index in range(SCOPES[monster_kind].size()):
		var key := "hit%d" % (index + 1)
		animations[StringName(key)] = [key, false]
		attacks[key] = {
			"multiplier": MULTIPLIERS[monster_kind][index],
			"kind": "magic" if index > 0 else "physics",
			"hurt_back": [0, 0],
			"source_target_move": [120, 60] if monster_kind == 3343 and index == 0 else [32, 42],
			"protect": 0
		}
	if monster_kind == 3343:
		animations[&"appear"] = ["appear", false]
		animations[&"hurt"] = ["wait", false]
	config["animations"] = animations
	config["attacks"] = attacks
	config["is_flying"] = true
	return config


func _ready() -> void:
	super._ready()
	(hit_box.get_parent() as Area2D).area_entered.connect(_on_palace_hit)
	_fixed_flight_height_ready = false
	_3323_skill_y_locked = false
	_ready_to_fight = true
	_keep_in_view()
	if monster_kind == 3343:
		_ready_to_fight = false
		_play_frames(&"appear")
		mr_player.play(&"appear")
		await get_tree().create_timer(mr_player.get_animation(&"appear").length, false).timeout
		if not death():
			_ready_to_fight = true
			if mr_player.current_animation == &"appear":
				mr_player.play(&"wait")


func ai_think() -> void:
	if not _ready_to_fight:
		return
	super.ai_think()


func _configure_entity_collision_boxes() -> void:
	var size := Vector2(160, 155) if monster_kind == 3323 else Vector2(340, 450)
	var center := Vector2(0, -70) if monster_kind == 3323 else Vector2(0, -240)
	var shape := RectangleShape2D.new()
	shape.size = size
	hurt_box.shape = shape
	hurt_box.position = center
	var body := RectangleShape2D.new()
	body.size = Vector2(50, 60)
	pz.shape = body
	pz.position = Vector2(0, -30)

	collision_mask = 0


func _visual_offset(animation_name: StringName) -> Vector2:
	var sequence := str(_config["animations"][animation_name][0])
	var center: Array = _palace_data["geometry"][sequence]["center"]
	return Vector2(-float(center[0]) if mr_ani.flip_h else float(center[0]), float(center[1]))


func _physics_process(delta: float) -> void:
	_palace_clock += delta
	_fixed_flight_height_ready = false
	_3323_skill_y_locked = false
	no_grav = true
	velocity.y = 0.0
	super._physics_process(delta)
	if death():
		return
	if monster_kind == 3343 or is_attacking:
		velocity = Vector2.ZERO
	_keep_in_view()
	_sync_attack_collision()


func have_target() -> void:
	if not _ready_to_fight or is_attacking or death():
		velocity = Vector2.ZERO
		return
	var target := RoleProp.get_nearest_monster_target_position(global_position)
	monster_direction = target.x >= global_position.x
	monster_dir.scale.x = -1.0 if monster_direction else 1.0
	base_damage_box.scale.x = monster_dir.scale.x
	if monster_kind == 3323 and absf(target.x - global_position.x) > 240.0:
		velocity.x = signf(target.x - global_position.x) * 80.0
	else:
		velocity = Vector2.ZERO
	if not mr_player.current_animation.begins_with("hit"):
		mr_player.play(&"Fly" if not is_zero_approx(velocity.x) else &"Fly_wait")


func _enable_attack_box(_attack_name: StringName = &"") -> void:
	_disable_attack_box()


func _sync_attack_collision(_force: bool = false) -> void:
	if not is_attacking or _active_attack_name != &"hit1":
		_disable_attack_box()
		return
	var masks: Array = _palace_data["masks"]["hit1"]
	var mask: Array = masks[mini(mr_ani.frame, masks.size() - 1)]
	var interval := 0.267 if monster_kind == 3323 else 0.6
	var maximum := 5 if monster_kind == 3323 else 2
	if mask.is_empty() or _body_hit_count >= maximum or _palace_clock - _last_body_hit < interval:
		_disable_attack_box()
		return
	var shape := hit_box.shape as RectangleShape2D
	shape.size = Vector2(float(mask[2]), float(mask[3]))
	hit_box.position = Vector2(-(float(mask[0]) + float(mask[2]) * 0.5), float(mask[1]) + float(mask[3]) * 0.5)
	hit_name = "hit1"
	hit_box.set_deferred("disabled", false)


func _on_palace_hit(area: Area2D) -> void:
	if area.collision_layer & 128 or area.get_parent() is BaseHero:
		_body_hit_count += 1
		_last_body_hit = _palace_clock


func _reachable_official_attacks() -> Array[StringName]:
	var result: Array[StringName] = []
	var target := RoleProp.get_nearest_monster_target_position(global_position)
	monster_direction = target.x >= global_position.x
	for index in range(SCOPES[monster_kind].size()):
		if _official_in_skill_scope(target, SCOPES[monster_kind][index]):
			result.append(StringName("hit%d" % (index + 1)))
	return result


func attack_target() -> void:
	if not _ready_to_fight or is_attacking or death():
		return
	var attacks := _reachable_official_attacks()
	if attacks.is_empty():
		have_target()
		return
	var chosen := attacks[_skill_cursor % attacks.size()]
	_skill_cursor += 1
	_start_palace_attack(chosen)


func _start_palace_attack(action: StringName) -> void:
	_attack_serial += 1
	var serial := _attack_serial
	_active_attack_name = action
	is_attacking = true
	_body_hit_count = 0
	_last_body_hit = -10000.0
	velocity = Vector2.ZERO
	var target := RoleProp.get_nearest_monster_target_position(global_position)
	_cast_direction = 1.0 if target.x >= global_position.x else -1.0
	monster_direction = _cast_direction > 0.0
	monster_dir.scale.x = -_cast_direction
	base_damage_box.scale.x = -_cast_direction
	_cast_position = global_position
	_play_frames(action)
	mr_player.play(action)
	if monster_kind == 3323:
		_run_peng_skill(action, serial)
	else:
		_run_lightning_skill(action, serial)
	var duration := mr_player.get_animation(action).length
	if monster_kind == 3323 and action == &"hit3":
		duration = 0.4 + 1.0 + 11.0 / SOURCE_FPS
	await get_tree().create_timer(duration, false).timeout
	if not _late_attack_is_current(serial):
		return
	_3323_skill3_invincible = false
	hurt_box.set_deferred("disabled", false)
	is_attacking = false
	_active_attack_name = &""
	_disable_attack_box()
	mr_player.play(&"wait")


func _run_peng_skill(action: StringName, serial: int) -> void:
	if action == &"hit2":
		await get_tree().create_timer(19.0 / SOURCE_FPS, false).timeout
		if _late_attack_is_current(serial):
			_projectile(
				"effect2_1",
				action,
				_cast_position + Vector2(170 * _cast_direction, -78),
				Vector2(360 * _cast_direction, 0),
				1.5,
				{"max_hits": 5, "damage_pulse_interval": 0.3, "poll_overlaps_on_damage_pulse": true}
			)
	elif action == &"hit3":
		_3323_skill3_invincible = true
		hurt_box.set_deferred("disabled", true)
		await get_tree().create_timer(12.0 / SOURCE_FPS, false).timeout
		if not _late_attack_is_current(serial):
			return
		var origin := _cast_position + Vector2(0, -50)
		var target := RoleProp.get_nearest_monster_target_position(global_position)

		var projectile := _projectile(
			"effect3_1",
			action,
			origin,
			origin.direction_to(target) * 900,
			1.0,
			{
				"orient_to_motion": true,
				"max_hits": 3,
				"damage_pulse_interval": 0.2,
				"poll_overlaps_on_damage_pulse": true,
				"impact_atlas_metadata": _metadata_path(),
				"impact_atlas_sequence": "effect3_2",
				"impact_frames_resource": _standard_body_frames_path(),
				"impact_frames_animation": "effect3_2",
				"impact_frame_count": 11,
				"impact_duration": 11.0 / SOURCE_FPS,
				"finished_callback": Callable(self, "_finish_swallow")
			}
		)
		_swallow_pending = projectile != null
	elif action == &"hit4":
		await get_tree().create_timer(9.0 / SOURCE_FPS, false).timeout
		if not _late_attack_is_current(serial):
			return
		var start_angle := randf_range(0, PI * 0.5)
		for index in range(8):
			_projectile(
				"effect4_1",
				action,
				_cast_position,
				Vector2.from_angle(start_angle + index * PI / 4.0) * 540,
				1.5,
				{"orient_to_motion": true}
			)


func _finish_swallow(position: Vector2) -> void:
	if not is_inside_tree() or death():
		return
	_swallow_pending = false
	global_position = position - Vector2(0, 50)
	_palace_flight_y = global_position.y
	_keep_in_view()
	_3323_skill3_invincible = false
	hurt_box.set_deferred("disabled", false)


func _run_lightning_skill(action: StringName, serial: int) -> void:
	if action == &"hit2":
		var landing_offsets := [-125.0, -75.0, -25.0, 25.0, 75.0, 125.0]
		landing_offsets.shuffle()
		await get_tree().create_timer(0.759, false).timeout
		for index in range(3):
			if not is_inside_tree() or death():
				return
			for polarity in range(2):
				var offset := Vector2(130 if polarity == 0 else -146, -327)
				var target := RoleProp.get_nearest_monster_target_position(global_position)
				var facing := 1.0 if target.x >= _cast_position.x else -1.0
				var origin := _cast_position + Vector2(offset.x * facing, offset.y)

				var fall_time := (771.0 + sqrt(maxf(0.0, 771.0 * 771.0 + 2.0 * 990.0 * (target.y - origin.y)))) / 990.0
				var landing_x := target.x + float(landing_offsets[index + polarity * 3])
				_projectile(
					"effect2_%d" % (polarity + 1),
					action,
					origin,
					Vector2((landing_x - origin.x) / maxf(fall_time, 0.1), -771),
					maxf(fall_time, 2.0),
					{
						"acceleration": Vector2(0, 990),
						"orient_to_motion": true,
						"collide_terrain": true,
						"impact_atlas_metadata": _metadata_path(),
						"impact_atlas_sequence": "effect2_%d" % (polarity + 3),
						"impact_frames_resource": _standard_body_frames_path(),
						"impact_frames_animation": "effect2_%d" % (polarity + 3),
						"impact_frame_count": 12,
						"impact_duration": 0.4
					}
				)
			if index < 2:
				await get_tree().create_timer(0.165, false).timeout
	elif action in [&"hit3", &"hit4"]:
		await get_tree().create_timer(0.858, false).timeout
		if not _late_attack_is_current(serial):
			return
		var offset := Vector2(-68 if action == &"hit3" else 214, -234)
		var target := RoleProp.get_nearest_monster_target_position(global_position)
		var facing := 1.0 if target.x >= _cast_position.x else -1.0
		var origin := _cast_position + Vector2(offset.x * facing, offset.y)
		var vector := origin.direction_to(_target_hurt_rect(target).get_center())

		_projectile(
			"effect3_1" if action == &"hit3" else "effect4_1",
			action,
			origin,
			vector * (30.0 if action == &"hit3" else 18.0),
			0.434,
			{"orient_to_motion": true, "max_hits": 1}
		)
	elif action == &"hit5":
		_lightning_reverse = not _lightning_reverse
		var view := visible_battle_rect()
		await get_tree().create_timer(0.759, false).timeout
		for index in range(10):
			if not is_inside_tree() or death():
				return
			var x := 100.0 * (index + 1) if _lightning_reverse else 1100.0 - 100.0 * index
			_projectile(
				"effect5_1" if index % 2 == 0 else "effect5_2",
				action,
				Vector2(view.position.x + x / 1200.0 * view.size.x, _cast_position.y),
				Vector2.ZERO,
				27.0 / SOURCE_FPS
			)
			if index < 9:
				await get_tree().create_timer(0.33, false).timeout


func _projectile(
	sequence: String, action: StringName, origin: Vector2, motion: Vector2, duration: float, extra: Dictionary = {}
) -> WutaiMinghaiProjectile:
	var projectile := PALACE_PROJECTILE.new() as WutaiMinghaiProjectile
	var config := {
		"owner": self,
		"position": origin,
		"right": _cast_direction > 0,
		"visual_faces_right": true,
		"hit_name": str(action),
		"attack_data": _attack_entry(action),
		"skill_name": "PalaceBoss%d_%s" % [monster_kind, sequence],
		"atlas_metadata": _metadata_path(),
		"atlas_sequence": sequence,
		"frames_resource": _standard_body_frames_path(),
		"frames_animation": sequence,
		"frame_fps": SOURCE_FPS,
		"velocity": motion,
		"lifetime": duration,
		"damage_duration": duration,
		"loop_visual": not motion.is_zero_approx(),
		"expire_on_hit": false,
		"max_hits": 1,
		"track_target": false
	}
	config.merge(extra, true)

	if bool(config.get("orient_to_motion", false)):
		config["visual_faces_right"] = config["right"]
	projectile.configure(config)
	bullet.add_child(projectile)
	skill_projectile_spawned.emit(sequence, projectile)
	return projectile


func visible_battle_rect() -> Rect2:
	var viewport := get_viewport()
	var inverse := viewport.get_canvas_transform().affine_inverse()
	var top_left := inverse * Vector2.ZERO
	var bottom_right := inverse * viewport.get_visible_rect().size
	return Rect2(top_left, bottom_right - top_left)


func _keep_in_view() -> void:
	var view := visible_battle_rect()
	var idle: Dictionary = _palace_data["geometry"]["wait"]
	var size: Array = idle["size"]
	var origin: Array = idle["origin"]
	var fit := minf(1.0, minf((view.size.y - 32.0) / float(size[1]), (view.size.x - 80.0) / float(size[0])))
	scale = Vector2.ONE * maxf(fit, 0.25)
	var left_extent := -float(origin[0]) * scale.x
	var right_extent := (float(origin[0]) + float(size[0])) * scale.x
	if monster_direction:
		var old_left := left_extent
		left_extent = right_extent
		right_extent = old_left
	global_position.x = clampf(global_position.x, view.position.x + left_extent + 16, view.end.x - right_extent - 16)
	var minimum_y := view.position.y - float(origin[1]) * scale.y + 16
	var maximum_y := view.end.y - (float(origin[1]) + float(size[1])) * scale.y - 16
	if not _palace_flight_height_ready:
		_palace_flight_y = global_position.y
		_palace_flight_height_ready = true

	_palace_flight_y = clampf(_palace_flight_y, minimum_y, maximum_y)
	global_position.y = _palace_flight_y
