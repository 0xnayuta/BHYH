extends EastContinentMonster

signal skill_projectile_spawned(sequence: String, projectile: WutaiMinghaiProjectile)

const CLOUD_PROJECTILE := preload("res://Script/monster/palace_boss_projectile.gd")
const CLOUD_FRAMES_RES := "res://Art/monster/cloud_boss/model_3352/cloud_boss_frames.tres"
var _cloud_view: AtlasMetadataView = null
var _dash_active := false
var _flight_y := 300.0
var _skill_cursor := 0
var _regen_elapsed := 0.0


func _metadata_path() -> String:
	return "res://Art/monster/cloud_boss/model_3352/metadata.tres"


func _standard_body_frames_path() -> String:
	return CLOUD_FRAMES_RES


func _resolve_runtime_config() -> Dictionary:
	var config := super._resolve_runtime_config()
	_cloud_view = AtlasMetadataStore.view_for(_metadata_path())
	config["is_flying"] = true
	config["attacks"] = {
		"hit1": {"multiplier": 0.25, "kind": "physics", "source_target_move": [120, 42], "protect": 1112},
		"hit2": {"multiplier": 0.167, "kind": "magic", "source_target_move": [32, 42], "protect": 667},
		"hit3": {"multiplier": 0.25, "kind": "magic", "source_target_move": [32, 42], "protect": 667}
	}
	return config


func _ready() -> void:
	super._ready()
	_fixed_flight_height_ready = false
	collision_mask = 0
	_flight_y = global_position.y
	_keep_in_view()


func _visual_offset(action: StringName) -> Vector2:
	if _cloud_view == null:
		return Vector2.ZERO
	var sequence := str(_config["animations"][action][0])
	var center := _cloud_view.geometry_center(StringName(sequence))
	return Vector2(-center.x if mr_ani.flip_h else center.x, center.y)


func _configure_entity_collision_boxes() -> void:
	var shape := RectangleShape2D.new()
	shape.size = Vector2(180, 220)
	hurt_box.shape = shape
	hurt_box.position = Vector2(0, -100)


func _physics_process(delta: float) -> void:
	_fixed_flight_height_ready = false
	no_grav = true
	velocity.y = 0.0
	super._physics_process(delta)
	if not death():
		_keep_in_view()
		_regen_elapsed += delta
		if _regen_elapsed >= 1.0:
			_regen_elapsed -= 1.0

			cure_hp(146316)


func _keep_in_view() -> void:
	var inverse := get_viewport().get_canvas_transform().affine_inverse()
	var view := Rect2(
		inverse * Vector2.ZERO, get_viewport_rect().size / get_viewport().get_canvas_transform().get_scale()
	)
	global_position.x = clampf(global_position.x, view.position.x + 175.0, view.end.x - 175.0)
	_flight_y = clampf(_flight_y, view.position.y + 305.0, view.end.y - 90.0)
	global_position.y = _flight_y


func have_target() -> void:
	if is_attacking or death():
		velocity = Vector2.ZERO
		return
	var target := RoleProp.get_nearest_monster_target_position(global_position)
	monster_direction = target.x >= global_position.x
	to_hero()
	velocity.x = signf(target.x - global_position.x) * 1200.0
	mr_player.play(&"Fly")


func is_control_immune() -> bool:
	return true


func reduce_hp(value: int):
	return 0 if _dash_active else super.reduce_hp(value)


func hurt_reduce_hp(value, target):
	return 0 if _dash_active else super.hurt_reduce_hp(value, target)


func reduce_pet_hp(value: int, kind: String) -> int:
	return 0 if _dash_active else super.reduce_pet_hp(value, kind)


func _enable_attack_box(_action: StringName = &"") -> void:
	_disable_attack_box()


func _sync_attack_collision(_force: bool = false) -> void:
	_disable_attack_box()


func attack_target() -> void:
	if death() or is_attacking:
		return
	var attacks := _reachable_official_attacks()
	if attacks.is_empty():
		have_target()
		return
	var action := attacks[_skill_cursor % attacks.size()]
	_skill_cursor += 1
	_attack_serial += 1
	var serial := _attack_serial
	_active_attack_name = action
	hit_name = str(action)
	is_attacking = true
	velocity = Vector2.ZERO
	_play_frames(action)
	mr_player.play(action)
	_cast_source_skill(action, serial)
	await mr_player.animation_finished
	if not death() and serial == _attack_serial and not _dash_active:
		is_attacking = false
		mr_player.play(&"wait")


func _cast_source_skill(action: StringName, serial: int) -> void:
	if action == &"hit1":
		await get_tree().create_timer(17.0 / SOURCE_FPS, false).timeout
		if not _late_attack_is_current(serial):
			return
		_dash_active = true
		hurt_box.set_deferred("disabled", true)
		var target := RoleProp.get_nearest_monster_target_position(global_position)
		_projectile(
			"effect1_1",
			action,
			global_position,
			global_position.direction_to(target) * 900.0,
			1.0,
			{
				"max_hits": 4,
				"damage_pulse_interval": 0.2,
				"poll_overlaps_on_damage_pulse": true,
				"finished_callback": Callable(self, "_finish_dash")
			}
		)
	elif action == &"hit2":
		_projectile(
			"effect2_1",
			action,
			global_position,
			Vector2.ZERO,
			4.0,
			{"follow_owner": true, "max_hits": 12, "damage_pulse_interval": 0.3, "poll_overlaps_on_damage_pulse": true}
		)
		for index in range(2):
			await get_tree().create_timer((20.0 if index == 0 else 17.0) / SOURCE_FPS, false).timeout
			if not _late_attack_is_current(serial):
				return
			var target := RoleProp.get_nearest_monster_target_position(global_position)
			_projectile(
				"effect2_2",
				action,
				target + Vector2(-200 if index == 0 else 200, 0),
				Vector2.ZERO,
				4.0,
				{"max_hits": 12, "damage_pulse_interval": 0.3, "poll_overlaps_on_damage_pulse": true}
			)
	else:
		for index in range(3):
			await get_tree().create_timer(0.462 if index == 0 else 0.891, false).timeout
			if not _late_attack_is_current(serial):
				return
			var target := RoleProp.get_nearest_monster_target_position(global_position)
			var facing := 1.0 if target.x >= global_position.x else -1.0
			var origin := global_position + Vector2(143.0 * facing, 3.0)
			_projectile(
				"effect3_1",
				action,
				origin,
				global_position.direction_to(target) * 720.0,
				1.5,
				{"max_hits": 2, "damage_pulse_interval": 0.2, "poll_overlaps_on_damage_pulse": true}
			)


func _projectile(
	sequence: String, action: StringName, origin: Vector2, motion: Vector2, duration: float, extra: Dictionary = {}
) -> WutaiMinghaiProjectile:
	var target := RoleProp.get_nearest_monster_target_position(global_position)
	var right := target.x >= origin.x
	var config := {
		"owner": self,
		"position": origin,
		"right": right,
		"visual_faces_right": right,
		"hit_name": str(action),
		"attack_data": _attack_entry(action),
		"skill_name": "CloudBoss_" + sequence,
		"visual_backend": WutaiMinghaiProjectile.VisualBackend.SPRITE_FRAMES,
		"frames_resource": CLOUD_FRAMES_RES,
		"frames_animation": sequence,
		"source_masks_metadata": _metadata_path(),
		"frame_fps": SOURCE_FPS,
		"velocity": motion,
		"lifetime": duration,
		"damage_duration": duration,
		"loop_visual": true,
		"expire_on_hit": false,
		"track_target": false,
		"orient_to_motion": not motion.is_zero_approx()
	}
	config.merge(extra, true)
	var projectile := CLOUD_PROJECTILE.new() as WutaiMinghaiProjectile
	if not projectile.configure(config):
		projectile.free()
		return null
	bullet.add_child(projectile)
	skill_projectile_spawned.emit(sequence, projectile)
	return projectile


func _finish_dash(endpoint: Vector2) -> void:
	_dash_active = false
	if not is_inside_tree() or death():
		return
	global_position = endpoint - Vector2(0, 50)
	_flight_y = global_position.y
	hurt_box.set_deferred("disabled", false)
	_keep_in_view()
	is_attacking = false
	mr_player.play(&"wait")

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
