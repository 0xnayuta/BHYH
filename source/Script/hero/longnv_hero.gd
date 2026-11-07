extends BaseHero
class_name LongnvHero

## 小龙女（Role8）战斗角色；动作时间轴、双刃/圆刃形态与官方部件同步由本类持有。

const PARTS := preload("res://Script/hero/longnv_official_parts.gd")
const ATTACK_EFFECTS := {
	"hit1": "attack1",
	"hit2": "attack2",
	"hit3": "attack3",
	"hit4": "attack4",
	"hit5": "attack5",
	"hit_air": "jump_attack",
	"hit_run": "run_attack",
}
const WINGS_BASE_POSITION := Vector2(26, -93)
const WINGS_RUN_POSITION := Vector2(8, -99)
const WINGS_HURT_POSITION := Vector2(38, -85)

@onready var melee_area: Area2D = $base_damagebox/HitBox
@onready var melee_shape: CollisionShape2D = $base_damagebox/HitBox/HitBox

var _elapsed := 0.0
var _duration := 0.0
var _hit_at := 0.0
var _did_hit := false
var _active := false
var _combo := 0
var _combo_timeout := 0.0
var _skill_index := -1
var attack_visual: Sprite2D
var _hit_times: Array = []
var _hit_cursor := 0
var _stage := 0
var _blade: Node2D
var _spawned_blade := false
var _return_window := 0.0
var _return_key_released := false
var _screen_layer: CanvasLayer
var _launch_floor := 0.0
var _cast_damage := 0.0
var _pulse_targets: Dictionary = {}
var _last_damage_position := Vector2.ZERO
var _evading := false
var extra_skills = preload("res://Script/hero/longnv_extra_skills.gd").new()
var _storm_resources: Array[RefCounted] = []
var _storm_audio: AudioStream
var _storm_resources_prepared := false
var _combat_resources: Array[RefCounted] = []
var _secondary_invincible_left := 0.0
var _extra_blades: Array[Node] = []


func _coop() -> Node:
	return get_node_or_null("/root/LocalCoop")


func _ready() -> void:
	var coop := _coop()
	var data_store = coop.data_for(self) if coop != null else null
	if data_store != null and data_store.has_method("ensure_skill_data"):
		data_store.ensure_skill_data()
	else:
		PlayerData.ensure_skill_data()
	extra_skills.hero = self
	role_body.load_set("default")
	_build_animations()
	super._ready()
	on_eqchange()
	prepare_combat_resources()
	add_to_group("Player")
	for key: String in LongnvSkillData.KEYS:
		role1_skill_inter[key] = 0.0
		role1_skill_max_inter[key] = 0.0

	melee_area.monitorable = false
	attack_visual = Sprite2D.new()
	attack_visual.name = "OriginalAttackEffect"
	attack_visual.set_script(PARTS)
	attack_visual.offset = Vector2(0, -188)
	attack_visual.scale = role_body.scale
	attack_visual.z_index = 1
	attack_visual.hide()
	action.add_child(attack_visual)
	_screen_layer = CanvasLayer.new()
	_screen_layer.layer = 2
	add_child(_screen_layer)
	role_action_player.play("wait")


func _notification(what: int) -> void:
	if not is_instance_valid(_screen_layer):
		return
	if what == NOTIFICATION_PAUSED:
		_screen_layer.hide()
	elif what == NOTIFICATION_UNPAUSED:
		_screen_layer.show()


func _props() -> BaseRoleProperties:
	var coop := _coop()
	var props := coop.props_for(self) as BaseRoleProperties if coop != null else null
	return props if props != null else RoleProp


func _role_power() -> float:
	return float(_props().roleprop.power)


func _prepare_storm_resources() -> void:
	var root := "res://Art/hero_picture/role_8/official_parts/"
	var retained: Array[RefCounted] = []
	var banks := [
		["ring_effect10", root],
		["default", root + "ring/"],
		[LongnvEquipmentData.appearance(role_body.body_equipment, "防具"), root + "ring/"],
		[LongnvEquipmentData.appearance(role_body.weapon_equipment, "武器"), root + "ring/"],
	]
	for bank: Array in banks:
		var data: RefCounted = PARTS.DATA.get_set(str(bank[0]), str(bank[1]))
		if data != null and data not in retained:
			retained.append(data)
	_storm_resources = retained
	_storm_audio = Global.get_cached_audio("res://Music/hero/role_8/ring/effect10.mp3")
	_storm_resources_prepared = true
	extra_skills.SCREEN_STORM.prewarm_rendering(self)


func on_eqchange() -> void:
	super.on_eqchange()
	if _storm_resources_prepared:
		prepare_combat_resources()


func prepare_combat_resources() -> void:
	_prepare_storm_resources()
	var root := "res://Art/hero_picture/role_8/official_parts/"
	var retained: Array[RefCounted] = _storm_resources.duplicate()

	for form_root: String in [root, root + "ring/"]:
		for bank: String in [
			"default",
			LongnvEquipmentData.appearance(role_body.body_equipment, "防具"),
			LongnvEquipmentData.appearance(role_body.weapon_equipment, "武器"),
		]:
			var data: RefCounted = PARTS.DATA.get_set(bank, form_root)
			if data != null and data not in retained:
				retained.append(data)
	var banks: Array[String] = []
	for action_name: String in ATTACK_EFFECTS:
		var bank := str(ATTACK_EFFECTS[action_name])
		banks.append(bank)
		if action_name != "hit5":
			banks.append("ring_" + bank)
		for sound_root: String in ["res://Music/hero/role_8/", "res://Music/hero/role_8/ring/"]:
			var path := sound_root + bank + ".mp3"
			if ResourceLoader.exists(path):
				Global.get_cached_audio(path)
	var coop := _coop()
	var data_store = coop.data_for(self) if coop != null else null
	var profile_data: Dictionary = data_store.player_data if data_store != null else PlayerData.player_data
	var learned: Variant = profile_data.get(DataKeys.SKILL_LEARNED, {})
	var keymap: Dictionary = (learned as Dictionary).get(DataKeys.Skill.KEYMAP, {}) if learned is Dictionary else {}
	var equipped: Array = keymap.values()
	for key: String in equipped:
		var index := LongnvSkillData.KEYS.find(key)
		if index < 0:
			continue
		for bank: String in LongnvSkillData.effect_banks(index):
			if bank not in banks:
				banks.append(bank)
		var path := (
			"res://Music/hero/role_8/" + ("ring/" if index >= 10 else "") + str(LongnvSkillData.ACTIONS[index]) + ".mp3"
		)
		if ResourceLoader.exists(path):
			Global.get_cached_audio(path)
	for bank: String in banks:
		var data: RefCounted = PARTS.DATA.get_set(bank, root)
		if data != null and data not in retained:
			retained.append(data)

	_combat_resources = retained


func _build_animations() -> void:
	var library := AnimationLibrary.new()
	for key: String in role_body.animation_names:
		var animation := Animation.new()
		var count: int = role_body.get_frame_count(key)
		animation.length = 0.45 if key == "hurt" else maxf(count / 30.0, 1.0 / 30.0)
		if key in ["wait", "run", "walk", "drop"]:
			animation.loop_mode = Animation.LOOP_LINEAR
		var track := animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track, NodePath("Action/RoleBody:pose_key"))
		animation.value_track_set_update_mode(track, Animation.UPDATE_DISCRETE)
		for frame in range(count):
			var seconds := float(frame) * 0.45 / float(count - 1) if key == "hurt" and count > 1 else frame / 30.0
			animation.track_insert_key(track, seconds, key + ":" + str(frame))
		var speed_track := animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(speed_track, NodePath("RolePlayer:speed_scale"))
		animation.value_track_set_update_mode(speed_track, Animation.UPDATE_CONTINUOUS)
		animation.track_insert_key(speed_track, 0.0, 2.0 if key == "hurt" else 1.0)
		_add_wings_animation_tracks(animation, StringName(key))
		library.add_animation(key, animation)
	for key: StringName in role_action_player.get_animation_library_list():
		role_action_player.remove_animation_library(key)
	role_action_player.add_animation_library(&"", library)


func _add_wings_animation_tracks(animation: Animation, animation_name: StringName) -> void:
	var wing_position := WINGS_BASE_POSITION
	var wing_rotation := 0.0
	match animation_name:
		&"run":
			wing_position = WINGS_RUN_POSITION
		&"hurt":
			wing_position = WINGS_HURT_POSITION

	var position_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(position_track, NodePath("Action/Wings:position"))
	animation.value_track_set_update_mode(position_track, Animation.UPDATE_CONTINUOUS)
	animation.track_insert_key(position_track, 0.0, wing_position)

	var rotation_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(rotation_track, NodePath("Action/Wings:rotation"))
	animation.value_track_set_update_mode(rotation_track, Animation.UPDATE_CONTINUOUS)
	animation.track_insert_key(rotation_track, 0.0, wing_rotation)


func change_body(equipment) -> void:
	role_body.set_equipment(str(equipment), role_body.weapon_equipment)


func change_eq(equipment) -> void:
	role_body.set_equipment(role_body.body_equipment, str(equipment))


func ws_skill() -> bool:
	if RoleProp.is_ws_state or is_death:
		return false
	RoleProp.is_ws_state = true
	return super.ws_skill()


func _physics_process(delta: float) -> void:
	extra_skills.tick(delta)
	_secondary_invincible_left = maxf(0.0, _secondary_invincible_left - delta)
	_return_window = maxf(0.0, _return_window - delta)
	if _return_window > 0.0 and not _secondary_pressed(3):
		_return_key_released = true

	for index in [1, 3]:
		if _secondary_just_pressed(index):
			_use_secondary(index)
	if _active:
		if is_death or is_be_attacking or not no_limit_buff():
			_finish_action()
		else:
			var previous_elapsed := _elapsed
			_elapsed += delta
			if _skill_index >= 5:
				extra_skills.update_cast(previous_elapsed)
			if _skill_index == 1 and not _spawned_blade and _elapsed >= 0.21:
				_spawned_blade = true
				_launch_blade()
			if _skill_index == 2 and _stage == 0 and _elapsed >= 0.5:
				_stage = 1
				role_action_player.play("effect3_2")
				attack_visual.load_set("effect3_2")
			_update_attack_visual(_elapsed)
			if _skill_index in [2, 4] or _skill_index >= 5:
				_update_pulse_windows(previous_elapsed)
			else:
				while _hit_cursor < _hit_times.size() and _elapsed >= float(_hit_times[_hit_cursor]):
					_did_hit = true
					_apply_original_pulse(_hit_cursor)
					_hit_cursor += 1
			if _elapsed >= _duration:
				_finish_action()
	else:
		_combo_timeout = maxf(0.0, _combo_timeout - delta)
		if _combo_timeout == 0.0:
			_combo = 0
	if _active and _skill_index >= 5:
		extra_skills.move_cast(delta)
	var saved_walk_speed: int = walk_speed
	walk_speed = int(float(walk_speed) * extra_skills.speed_multiplier())
	super._physics_process(delta)
	walk_speed = saved_walk_speed
	if is_death:
		_finish_action()
		return
	if _active and _skill_index == 2:
		velocity.x = 0.0 if _stage == 0 else (550.0 if player_dir else -550.0)
		velocity.y = -300.0 if _stage == 0 else 550.0
		if _stage == 1 and global_position.y >= _launch_floor:
			global_position.y = _launch_floor
			velocity.y = 0.0
		move_and_slide()

		if _elapsed >= 0.55:
			_apply_original_pulse(1)
		_last_damage_position = global_position
	elif _active and _evading:
		velocity.x = -500.0 if player_dir else 500.0
		velocity.y = -100.0 if _elapsed < 0.3 else 100.0
		move_and_slide()
	if (
		not is_riding_mount()
		and no_limit_buff()
		and PlayerInput.is_action_pressed("normalhit")
		and not is_attacking
		and not is_be_attacking
		and not is_using_skills
	):
		_start_melee("hit" + str(_combo + 1) if is_on_floor() else "hit_air")


func _begin_action(animation: String, damage: float, skill: int = -1) -> void:
	_active = true
	_elapsed = 0.0
	_did_hit = false
	_skill_index = skill
	_stage = 0
	_evading = false
	_spawned_blade = false
	_hit_cursor = 0
	_launch_floor = global_position.y
	_cast_damage = damage
	_pulse_targets.clear()
	_last_damage_position = global_position
	is_attacking = true
	is_using_skills = skill >= 0
	if skill == 4:
		check_add_buff()
	get_action = animation
	velocity.x = 0.0
	hit_dic = {
		"power": damage,
		"hurtBack": [1, -2 if skill == 1 else 0],
		"attackKind": "physics",
		"WSValue": 3,
	}
	obj_attack_dict[animation] = hit_dic.duplicate(true)
	_hit_data_needs_reset = true
	role_action_player.play(animation)
	var action_animation: Animation = role_action_player.get_animation(animation)
	_duration = action_animation.length if action_animation != null else 0.5
	_hit_at = minf(0.2, _duration * 0.4)
	var shape := RectangleShape2D.new()
	shape.size = (
		Vector2(290, 155)
		if skill == 0
		else Vector2(270, 115) if skill == 3 else Vector2(200, 135) if skill == 2 else Vector2(140, 85)
	)
	melee_shape.shape = shape
	melee_shape.position = Vector2(0, -72) if skill == 0 else Vector2(-60, -58)
	_hit_times = [_hit_at]
	if skill >= 0:
		_duration = float(LongnvSkillData.DURATIONS[skill])
		_hit_times = LongnvSkillData.HIT_TIMES[skill].duplicate()
		_hit_at = float(_hit_times[0]) if not _hit_times.is_empty() else 0.21
		if skill == 19:
			var ultimate_animation: Animation = role_action_player.get_animation(animation)
			_duration = ultimate_animation.length if ultimate_animation != null else _duration
			_hit_times.clear()
		if skill == 4 and is_skill_awakened("xln_ly"):
			_hit_times = [0.15, 0.25, 0.35, 0.45, 0.55, 0.65, 0.95, 1.05, 1.15]
			_duration = 1.3
		if skill == 14 and is_skill_awakened("xln_jyc"):
			_duration = 1.05
			_hit_times.clear()
	if attack_visual.get_parent() != action:
		attack_visual.reparent(action, false)
	attack_visual.position = Vector2.ZERO
	var bank := str(LongnvSkillData.EFFECTS[skill]) if skill >= 0 else str(ATTACK_EFFECTS.get(animation, ""))
	if skill < 0 and role_body.ring_form:
		bank = "ring_" + bank
	attack_visual.hide()
	if bank != "" and attack_visual.load_set(bank):
		if skill < 0:
			_duration = maxf(_duration, float(attack_visual.get_frame_count("attack")) / 30.0)
		var effect_frames: Array = attack_visual.get("_animations")["attack"]["frames"]
		for frame in effect_frames.size():
			if int(effect_frames[frame][1]) > 0:
				if skill < 0:
					_hit_at = maxf(_hit_at, (float(frame) + 0.01) / 30.0)
					_hit_times = [_hit_at]
				break
		if skill == 4:
			_duration = maxf(_duration, float(attack_visual.get_frame_count("attack")) / 30.0)
			attack_visual.reparent(_screen_layer, false)
		_update_attack_visual(0.0)
	if skill == 0 and is_skill_awakened("xln_lz"):
		for offset_y in [-70.0, 0.0, 70.0]:
			_launch_spinning_blade(offset_y)


func _update_attack_visual(seconds: float) -> void:
	if not is_instance_valid(attack_visual):
		return
	var count := int(attack_visual.get_frame_count("attack"))
	if count <= 0:
		attack_visual.hide()
		return
	var visual_seconds := seconds - 0.5 if _skill_index == 2 and _stage == 1 else seconds
	if _skill_index >= 5:
		visual_seconds = seconds - extra_skills.visual_start
	var animations: Dictionary = attack_visual.get("_animations")
	var looping := bool(animations.get("attack", {}).get("loop", false))
	attack_visual.visible = _active and role_body.visible and (looping or visual_seconds < float(count) / 30.0)

	if (
		_skill_index == 1
		or _evading
		or _skill_index in [12, 15, 16, 17, 19]
		or (_skill_index == 14 and is_skill_awakened("xln_jyc"))
		or (_skill_index == 6 and extra_skills.stage == 0)
		or (_skill_index == 13 and extra_skills.stage != 1)
	):
		attack_visual.hide()
	if attack_visual.visible:
		attack_visual.scale = role_body.scale
		if _skill_index == 4:
			var viewport_size := get_viewport_rect().size
			var fit := minf(viewport_size.x / 1208.0, viewport_size.y / 807.0)
			attack_visual.position = viewport_size * 0.5
			attack_visual.scale = Vector2(fit, fit)
		attack_visual.set_time("attack", visual_seconds)


func clamp_blade_teleport_position(destination: Vector2) -> Vector2:
	var canvas := get_viewport().get_canvas_transform()
	var screen := canvas * destination
	var rect := get_viewport_rect()
	var margin := Vector2(60, 120) * canvas.get_scale().abs()
	margin.x = minf(margin.x, rect.size.x * 0.25)
	margin.y = minf(margin.y, rect.size.y * 0.4)
	screen.x = clampf(screen.x, rect.position.x + margin.x, rect.end.x - margin.x)
	screen.y = clampf(screen.y, rect.position.y + margin.y, rect.end.y - minf(8.0, rect.size.y * 0.1))
	return canvas.affine_inverse() * screen


func _launch_blade() -> void:
	if is_instance_valid(_blade):
		_blade.queue_free()
	var blade = preload("res://Script/hero/longnv_flying_blade.gd").new()
	blade.player = self
	blade.direction = 1.0 if player_dir else -1.0
	blade.damage = _cast_damage
	get_parent().add_child(blade)
	blade.global_position = global_position + Vector2(40 if player_dir else -40, -45)
	_blade = blade
	if is_skill_awakened("xln_tk"):
		for offset_y in [-90.0, 90.0]:
			var split_blade = preload("res://Script/hero/longnv_flying_blade.gd").new()
			split_blade.player = self
			split_blade.direction = _blade.direction
			split_blade.damage = _cast_damage
			get_parent().add_child(split_blade)
			split_blade.global_position = _blade.global_position + Vector2(0, offset_y)
			_extra_blades.append(split_blade)


func _launch_spinning_blade(offset_y: float = 0.0) -> void:
	var blade = preload("res://Script/hero/longnv_flying_blade.gd").new()
	blade.player = self
	blade.direction = 1.0 if player_dir else -1.0
	blade.damage = _cast_damage
	blade.effect_bank = "effect1"
	blade.speed = 500.0
	blade.lifetime = 0.9
	blade.repeat_interval = 0.2
	blade.hit_size = Vector2(200, 135)
	blade.hit_offset = Vector2(0, -65)
	blade.hit_override = {"hurtBack": [6, -2], "longnv_spin_direction": blade.direction}
	get_parent().add_child(blade)
	blade.global_position = global_position + Vector2(40 if player_dir else -40, offset_y)


func is_skill_awakened(skill_id: String) -> bool:
	var coop := _coop()
	var data_store = coop.data_for(self) if coop != null else null
	var profile_data: Dictionary = data_store.player_data if data_store != null else PlayerData.player_data
	var data: Variant = profile_data.get(DataKeys.Skill.AWAKENED, {})
	if not data is Dictionary or not bool((data as Dictionary).get(skill_id, false)):
		return false
	var enabled: Variant = profile_data.get(DataKeys.Skill.AWAKENED_ENABLED, {})
	return (
		not enabled is Dictionary
		or not (enabled as Dictionary).has(skill_id)
		or bool((enabled as Dictionary).get(skill_id, true))
	)


func _skill_keymap_slot(slot: int) -> String:
	var coop := _coop()
	var data_store = coop.data_for(self) if coop != null else null
	var profile_data: Dictionary = data_store.player_data if data_store != null else PlayerData.player_data
	var learned: Variant = profile_data.get(DataKeys.SKILL_LEARNED, {})
	if not learned is Dictionary:
		return ""
	var keymap: Variant = (learned as Dictionary).get(DataKeys.Skill.KEYMAP, {})
	if not keymap is Dictionary:
		return ""
	return str((keymap as Dictionary).get(["Y", "U", "I", "O", "L"][slot], ""))


func _secondary_pressed(index: int) -> bool:
	var actions := ["slz", "lys", "lyfb", "hmz", "hytj"]
	for slot in range(5):
		if _skill_keymap_slot(slot) == LongnvSkillData.KEYS[index]:
			if PlayerInput.is_action_pressed(actions[slot]):
				return true
	return false


func _secondary_just_pressed(index: int) -> bool:
	var actions := ["slz", "lys", "lyfb", "hmz", "hytj"]
	for slot in range(5):
		if _skill_keymap_slot(slot) == LongnvSkillData.KEYS[index]:
			if PlayerInput.is_action_just_pressed(actions[slot]):
				return true
	return false


func _use_secondary(index: int) -> bool:
	if is_death or is_be_attacking or not no_limit_buff():
		return false
	if index == 1 and is_instance_valid(_blade) and (not _active or (_skill_index == 1 and _elapsed >= 0.48)):
		global_position = clamp_blade_teleport_position(_blade.global_position + Vector2(0, 45))
		_blade.queue_free()
		_blade = null
		_set_ring_form(false)
		_begin_action("effect2_2", LongnvSkillData.damage(1, int(get_skill_level(2)), _role_power()), 1)
		if is_skill_awakened("xln_tk"):
			_cast_damage *= 5.0
			hit_dic["power"] = _cast_damage
			_secondary_invincible_left = 1.0
		_spawned_blade = true
		_duration = 0.45
		_hit_times = [0.16]
		attack_visual.load_set("effect2_2")
		_skill_index = -1
		is_using_skills = true
		return true
	if (
		index == 3
		and _return_window > 0.0
		and _return_key_released
		and (not _active or (_skill_index == 3 and not _evading and _elapsed >= 0.33))
	):
		_return_window = 0.0
		_set_ring_form(false)
		_begin_action("effect4_2", 0.0, 3)
		_evading = true
		_duration = 0.6
		_hit_times = []
		attack_visual.hide()
		return true
	return false


func _update_pulse_windows(previous_elapsed: float) -> void:
	for pulse in range(_hit_times.size()):
		var start := float(_hit_times[pulse])
		var end := float(_hit_times[pulse + 1]) if pulse + 1 < _hit_times.size() else _duration
		if _skill_index == 2 and pulse == 0:
			end = 0.5
		if _elapsed >= start and previous_elapsed < end:
			_did_hit = true
			_apply_original_pulse(pulse)


func _apply_original_pulse(pulse: int) -> void:
	if _skill_index >= 5:
		extra_skills.pulse(pulse)
		return
	if not _pulse_targets.has(pulse):
		_pulse_targets[pulse] = {}
	var targets: Dictionary = _pulse_targets[pulse]
	if _skill_index == 4:
		var canvas_inverse := get_viewport().get_canvas_transform().affine_inverse()
		var view := get_viewport_rect()
		var center := canvas_inverse * view.get_center()
		var size := view.size / get_viewport().get_canvas_transform().get_scale().abs()
		hit_original_area(
			center,
			size,
			_cast_damage * (LongnvSkillData.ULTIMATE_SLASH_WEIGHT if pulse < 6 else 1.0),
			targets,
			{"longnv_skill": 4, "attackKind": "magic", "hurtBack": [0, 0]}
		)
	elif _skill_index == 2 and pulse == 1:
		var travel := global_position - _last_damage_position
		var center := (global_position + _last_damage_position) * 0.5 + Vector2(100 if player_dir else -100, -45)
		hit_original_area(
			center, Vector2(345, 195) + travel.abs(), _cast_damage * LongnvSkillData.DESCENT_WEIGHT, targets
		)
	elif _skill_index == 2:
		hit_original_area(
			melee_shape.global_position, (melee_shape.shape as RectangleShape2D).size, _cast_damage, targets
		)
	else:
		_apply_melee_hit()


func _apply_melee_hit() -> void:
	hit_original_area(
		melee_shape.global_position, (melee_shape.shape as RectangleShape2D).size, float(hit_dic.get("power", 0.0)), {}
	)


func hit_original_area(
	center: Vector2, size: Vector2, damage: float, hit_targets: Dictionary, hit_override: Dictionary = {}
) -> void:
	var query := PhysicsShapeQueryParameters2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	query.shape = shape
	query.transform = Transform2D(0, center)
	query.collision_mask = 3088
	query.collide_with_areas = true
	query.collide_with_bodies = false
	for contact: Dictionary in get_world_2d().direct_space_state.intersect_shape(query, 256):
		var target: Node = contact.collider
		while target != null and not target is BaseMonster and not target.has_method("receive_role_area_hit"):
			target = target.get_parent()
		if (
			target != null
			and target.has_method("receive_role_area_hit")
			and not hit_targets.has(target.get_instance_id())
		):
			if damage > 0.0:
				hit_targets[target.get_instance_id()] = true
				target.receive_role_area_hit(melee_area)
			continue
		if target is BaseMonster and not hit_targets.has(target.get_instance_id()):
			hit_targets[target.get_instance_id()] = true
			var hit := {
				"power": damage,
				"hurtBack": [1, -8 if _skill_index == 2 and _stage == 0 else 0],
				"attackKind": "physics",
				"WSValue": 3,
			}
			hit.merge(hit_override, true)
			if not hit_override.has("longnv_skill"):
				hit.power = float(hit.power) * extra_skills.damage_multiplier()
			var dealt: int = target.apply_role_hit(self, self, hit)
			if dealt > 0 and hit_override.has("longnv_skill"):
				extra_skills.on_hit(target, int(hit_override.longnv_skill))
			if _skill_index == 3 and damage > 0.0 and hit_override.is_empty():
				(
					Global
					. add_buff(
						target.buff,
						{
							"Name": "Bleed",
							"AddTime": LongnvSkillData.BLEED_DURATION,
							"ReduceInterval": LongnvSkillData.BLEED_INTERVAL,
							"value": LongnvSkillData.BLEED_RATIO,
							"CanAdd": false,
							"CanRemove": true,
							"AttackKind": "magic",
							"DeBuff": true,
							"longnv_bleed_source": weakref(self),
						}
					)
				)
				target.call_deferred("check_add_buff")
				if is_skill_awakened("xln_xr"):
					extra_skills.on_hit(target, 3)


func _start_melee(animation: String) -> void:
	if _active or is_death:
		return
	extra_skills.reveal()
	var ratios := {
		"hit1": 0.6,
		"hit2": 0.7,
		"hit3": 0.9,
		"hit4": 0.6,
		"hit5": 1.2,
		"hit_air": 1.1,
		"hit_run": 1.1,
	}
	_begin_action(animation, _role_power() * float(ratios.get(animation, 1.0)))
	if animation == "hit4":
		_hit_times = [0.1, 0.3]
		_hit_at = 0.1
		_duration = maxf(_duration, 0.3)
	_sound("jump_attack" if animation == "hit_air" else "attack" + animation.trim_prefix("hit"))
	_combo = (_combo + 1) % (4 if role_body.ring_form else 5) if animation != "hit_air" else 0
	_combo_timeout = 0.8


func _finish_action() -> void:
	var was_ultimate := _skill_index in [4, 16, 19]
	var was_active := _active
	_active = false
	if is_instance_valid(attack_visual):
		attack_visual.hide()
	_skill_index = -1
	_evading = false
	is_attacking = false
	is_using_skills = false
	for blade in _extra_blades:
		if is_instance_valid(blade):
			blade.queue_free()
	_extra_blades.clear()
	if was_ultimate:
		check_add_buff()
	if was_active and not is_death and not is_be_attacking:
		get_action = ""
		role_action_player.play("wait" if is_on_floor() else "drop")


func _skill_super_armor_active() -> bool:
	return (
		not is_death
		and (
			extra_skills.fury_left > 0.0
			or extra_skills.is_dashing()
			or (_active and _skill_index in [4, 16, 19] and is_using_skills)
		)
	)


func is_white_bar_control_immune() -> bool:
	return super.is_white_bar_control_immune() or (_active and _skill_index == 16 and not is_death)


func is_dikong_field_invincible() -> bool:
	return (
		super.is_dikong_field_invincible()
		or extra_skills.reveal_grace > 0.0
		or extra_skills.is_dashing()
		or _secondary_invincible_left > 0.0
	)


func get_total_damage_reduction() -> float:
	return super.get_total_damage_reduction() + extra_skills.reduction()


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if extra_skills.is_dashing():
		is_miss = true
		return
	var props := _props()
	var before: float = props.roleprop.Hp
	super._on_hurt_box_area_entered(area)
	if float(props.roleprop.Hp) < before:
		extra_skills.reveal()


func is_monster_targetable() -> bool:
	return not is_death and extra_skills.stealth_left <= 0.0


func effect_reducehp(value, atkKind):
	if extra_skills.is_dashing():
		is_miss = true
		return
	var props := _props()
	var before: float = props.roleprop.Hp
	super.effect_reducehp(value, atkKind)
	if float(props.roleprop.Hp) < before:
		extra_skills.reveal()


func get_monster_last_hurt(target_boss, target_obj):
	if extra_skills.is_dashing():
		is_miss = true
		return 0
	var damage = super.get_monster_last_hurt(target_boss, target_obj)
	if extra_skills.dodge_left > 0.0 and randf() < 0.5:
		is_miss = true
		return 0
	return damage


func _set_ring_form(enabled: bool) -> void:
	if role_body.ring_form == enabled:
		return
	role_body.set_ring_form(enabled)
	_combo = 0
	_build_animations()
	role_action_player.play("wait")


func _prepare_hit_reaction() -> void:
	_return_window = 0.0
	_finish_action()


func _cancel_skill_for_control() -> void:
	_return_window = 0.0
	_finish_action()


func get_need_mp(skill_name, next_level):
	var index := LongnvSkillData.KEYS.find(str(skill_name))
	if index < 0:
		return 0
	return LongnvSkillData.mp(str(skill_name), int(get_skill_level(index + 1)) + (1 if next_level else 0))


func get_skill_level(num):
	var coop := _coop()
	var data_store = coop.data_for(self) if coop != null else null
	var data: Dictionary = data_store.player_data if data_store != null else PlayerData.player_data
	var learned: Variant = data.get(DataKeys.SKILL_LEARNED, {})
	if not learned is Dictionary:
		return 0
	var entry: Variant = (learned as Dictionary).get("技能" + str(num), {})
	return int((entry as Dictionary).get(DataKeys.LEVEL, 0)) if entry is Dictionary else 0


func get_skill_display_mp(skill_name: String) -> int:
	return int(get_need_mp(skill_name, false))


func get_skill(skill_name):
	var key := str(skill_name)
	var index := LongnvSkillData.KEYS.find(key)
	if (
		index < 0
		or not is_inside_tree()
		or is_death
		or is_silent
		or _active
		or is_be_attacking
		or not no_limit_buff()
		or is_riding_mount()
	):
		return
	var level := int(get_skill_level(index + 1))
	if level < 1 or float(role1_skill_inter.get(key, 0.0)) > 0.0:
		return
	var level_node := get_parent().get_parent()
	if level_node is Level17 or level_node is Level22:
		return
	var cost := int(get_need_mp(key, false))
	var props := _props()
	if props.roleprop.Mp < cost:
		return
	props.roleprop.Mp -= cost
	var cooldown: float = (
		0.5 if index == 14 and is_skill_awakened("xln_jyc") else float(LongnvSkillData.COOLDOWNS[index])
	)
	role1_skill_inter[key] = cooldown
	role1_skill_max_inter[key] = cooldown
	extra_skills.reveal()
	_set_ring_form(index >= 10)
	_begin_action(
		LongnvSkillData.ACTIONS[index], LongnvSkillData.damage(index, level, float(props.roleprop.power)), index
	)
	if index >= 5:
		extra_skills.start(index, level)
	if index == 0:
		_launch_spinning_blade()
	if index == 3:
		_return_key_released = false
		_return_window = 1.47
	_sound(LongnvSkillData.ACTIONS[index])


func _sound(key: String) -> void:
	var path := "res://Music/hero/role_8/" + ("ring/" if role_body.ring_form else "") + key + ".mp3"
	if ResourceLoader.exists(path):
		Global.get_audio_runtime().add_sound(self, path)


func do_normalhit_1() -> void:
	_start_melee("hit1")


func do_normalhit_2() -> void:
	_start_melee("hit2")


func do_normalhit_3() -> void:
	_start_melee("hit3")


func do_normalhit_4() -> void:
	_start_melee("hit4")
