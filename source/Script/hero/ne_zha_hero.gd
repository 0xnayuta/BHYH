extends BaseHero
class_name NeZhaHero

const MOUNT_RIDER_ANIMATION: StringName = &"skill4"
const MOUNT_RIDER_FRAME := 14
const MOUNT_RIDER_CANVAS_SIZE := Vector2i(1024, 1024)

const EFFECT_SCENE_PATH := "res://Scene/hero/role_6/ne_zha_skill_effect.tscn"
const YINYANG_EFFECT_SCENE_PATH := "res://Scene/hero/role_6/ne_zha_yin_yang_effect.tscn"
const OFFICIAL_PARTS_TRANSPARENT := preload("res://Art/hero_picture/role_6/official_parts_trial/transparent.tres")
const OFFICIAL_ACTION_SOUNDS := {
	&"hit1": "attack_1",
	&"hit2": "attack_2",
	&"hit3": "attack_3",
	&"hit4": "attack_4",
	&"hit5": "jump_attack",
	&"skill1": "effect_1",
	&"skill1_air": "effect_11",
	&"skill2": "effect_2",
	&"skill3": "effect_3",
	&"skill4": "effect_4",
	&"skill5": "effect_5",
	&"skill5_enhanced": "effect_51",
}


func _get_body_frames(equipment_id: String) -> SpriteFrames:
	return NeZhaEquipmentVisuals.get_body_frames(equipment_id)


func _get_weapon_frames(equipment_id: String) -> SpriteFrames:
	return NeZhaEquipmentVisuals.get_weapon_frames(equipment_id)


func get_mount_rider_textures() -> Dictionary:
	var body_frames := _get_body_frames(_body_equipment_id)
	var body_front_frames := NeZhaEquipmentVisuals.get_body_front_frames(_body_equipment_id)
	if body_frames == null or body_front_frames == null:
		return {
			"body": body_sprite.texture if is_instance_valid(body_sprite) else null,
			"body_front": role_body_front.texture if is_instance_valid(role_body_front) else null,
		}
	var body_animation := _resolve_equipment_animation(body_frames, MOUNT_RIDER_ANIMATION)
	var front_animation := _resolve_equipment_animation(body_front_frames, MOUNT_RIDER_ANIMATION)
	var body_frame := clampi(MOUNT_RIDER_FRAME, 0, maxi(0, body_frames.get_frame_count(body_animation) - 1))
	var front_frame := clampi(MOUNT_RIDER_FRAME, 0, maxi(0, body_front_frames.get_frame_count(front_animation) - 1))
	return {
		"body": _build_mount_rider_canvas(body_frames.get_frame_texture(body_animation, body_frame)),
		"body_front": _build_mount_rider_canvas(body_front_frames.get_frame_texture(front_animation, front_frame)),
	}


func _play_official_action_sound(animation_name: StringName) -> void:
	var sound_name := str(OFFICIAL_ACTION_SOUNDS.get(animation_name, ""))
	if sound_name == "":
		return
	Global.get_audio_runtime().add_sound(self, "res://Music/hero/role_6/" + sound_name + ".mp3")


func _build_mount_rider_canvas(source_texture: Texture2D) -> Texture2D:
	if source_texture == null:
		return null
	var source_image := source_texture.get_image()
	if source_image == null or source_image.is_empty():
		return source_texture
	if source_image.get_format() != Image.FORMAT_RGBA8:
		source_image.convert(Image.FORMAT_RGBA8)
	var logical_canvas := Image.create_empty(
		MOUNT_RIDER_CANVAS_SIZE.x, MOUNT_RIDER_CANVAS_SIZE.y, false, Image.FORMAT_RGBA8
	)
	logical_canvas.fill(Color.TRANSPARENT)
	var source_size := source_image.get_size()
	var destination := Vector2i.ZERO
	if source_texture is AtlasTexture:
		var atlas_texture := source_texture as AtlasTexture
		destination = Vector2i(roundi(atlas_texture.margin.position.x), roundi(atlas_texture.margin.position.y))
	else:
		destination = Vector2i(
			(MOUNT_RIDER_CANVAS_SIZE.x - source_size.x) / 2, (MOUNT_RIDER_CANVAS_SIZE.y - source_size.y) / 2
		)
	logical_canvas.blit_rect(source_image, Rect2i(Vector2i.ZERO, source_size), destination)

	var project_viewport_width := float(
		ProjectSettings.get_setting("display/window/size/viewport_width", MOUNT_RIDER_CANVAS_SIZE.x)
	)
	var render_scale := float(MOUNT_RIDER_CANVAS_SIZE.x) / maxf(project_viewport_width, 1.0)
	var rendered_size := Vector2i(
		roundi(MOUNT_RIDER_CANVAS_SIZE.x * render_scale), roundi(MOUNT_RIDER_CANVAS_SIZE.y * render_scale)
	)
	logical_canvas.resize(rendered_size.x, rendered_size.y, Image.INTERPOLATE_CUBIC)
	var canvas := Image.create_empty(MOUNT_RIDER_CANVAS_SIZE.x, MOUNT_RIDER_CANVAS_SIZE.y, false, Image.FORMAT_RGBA8)
	canvas.fill(Color.TRANSPARENT)
	canvas.blit_rect(logical_canvas, Rect2i(Vector2i.ZERO, rendered_size), Vector2i(0, -1))
	return ImageTexture.create_from_image(canvas)


const SKILL_JIULONG := "nz_jlsh"
const SKILL_DASH := "nz_fhcc"
const SKILL_WHEEL := "nz_hlqg"
const SKILL_LOTUS := "nz_hlhs"
const SKILL_SPEAR := "nz_lblc"
const SKILL_YINYANG := "nz_yysj"
const SKILL_INPUT_ACTIONS := [&"slz", &"lys", &"lyfb", &"hmz", &"hytj"]
const SKILL_KEY_SLOTS := ["Y", "U", "I", "O", "L"]

const DASH_SPEED := 600.0
const DASH_DURATION := 20.0 / 30.0
const SPEAR_MOVE_NONE := 0
const SPEAR_MOVE_NORMAL := 1
const SPEAR_MOVE_ENHANCED := 2
const OFFICIAL_MOVE_SPEED_SCALE := 3.0

const WINGS_BASE_POSITION := Vector2(26, -93)
const WINGS_BASE_ROTATION := 0.0
const WINGS_RUN_POSITION := Vector2(8, -99)
const WINGS_RUN_ROTATION := -0.261799
const WINGS_HURT_POSITION := Vector2(38, -85)
const WINGS_HURT_ROTATION := 0.261799

const SPEAR_TARGET_DEFENSE_REDUCTION := 0.5
const YINYANG_INTERVAL := 0.267
const YINYANG_AWAKEN_INTERVAL := 0.12
const YINYANG_AWAKEN_MAX_ANGLE := PI * 2.0 / 15.0
const YINYANG_AWAKEN_SWEEP_STEP := 0.2
const YINYANG_SECOND_SWORD_DELAY := 4.0 / 30.0
const YINYANG_UPPER_SWORD_OFFSETS := [Vector2(-60, -105), Vector2(-20, -66)]
const YINYANG_UPPER_LAUNCH_OFFSETS := [Vector2(-100, -105), Vector2(-60, -66)]
const YINYANG_LOWER_SWORD_OFFSETS := [Vector2(-50, -20), Vector2(-90, -50)]
const YINYANG_LOWER_LAUNCH_OFFSETS := [Vector2(-90, -20), Vector2(-130, -50)]
const YINYANG_MP_VALUES := [
	8,
	10,
	13,
	15,
	16,
	19,
	20,
	24,
	27,
	29,
	34,
	39,
	45,
	51,
	57,
	60,
	67,
	74,
	82,
	90,
	99,
	103,
	112,
	121,
	131,
	141,
	151,
	156,
	167,
	179
]
const STANDARD_HURT_ANIMATION_LENGTH := 0.45
const STANDARD_HURT_PLAYBACK_SPEED := 2.0

@onready var melee_shape: CollisionShape2D = $base_damagebox/HitBox/HitBox
@onready var body_sprite: Sprite2D = $Action/RoleBody
@onready var role_body_front: Sprite2D = $Action/RoleBodyFront

var _lotus_enabled: bool = false
var _lotus_charge: int = 0
var _lotus_mp_elapsed: float = 0.0
var _lotus_heal_elapsed: float = 0.0
var _lotus_effect: NeZhaSkillEffect
var _lotus_toggle_locked: bool = false
var _lotus_awaken_stats_initialized := false
var _lotus_base_power := 0.0
var _lotus_last_power := 0.0
var _yinyang_enabled: bool = false
var _yinyang_elapsed: float = 0.0
var _yinyang_lower_branch: bool = false
var _yinyang_sweep_ratio: float = 0.0
var _yinyang_sweep_direction: float = 1.0
var _yinyang_toggle_effect: NeZhaYinYangEffect
var _yinyang_toggle_locked: bool = false
var _spear_energy: int = 0
var _skill_motion_velocity: Vector2 = Vector2.ZERO
var _skill_motion_remaining: float = 0.0
var _spear_move_mode: int = SPEAR_MOVE_NONE
var _enhanced_spear_target: Node2D
var _enhanced_direction_changed: bool = false
var _jiulong_ground_recovery: bool = false
var _skill_interrupt_generation: int = 0
var _enhanced_visual_hidden := false
var _enhanced_visual_state: Dictionary = {}
var _effect_scene: PackedScene
var _yinyang_effect_scene: PackedScene
var _body_equipment_id := "Empty"
var _weapon_equipment_id := "Empty"


func _ready() -> void:
	_load_official_layer(body_sprite, _body_equipment_id, "body", 0)
	_load_official_layer(role_body_front, _body_equipment_id, "body_front", 2)
	_load_official_layer(role_equipment, _weapon_equipment_id, "weapon", 1)
	_build_body_animations()
	_ensure_special_skills_in_normal_slots()
	super._ready()
	add_to_group("Player")
	for skill_name in [SKILL_JIULONG, SKILL_DASH, SKILL_WHEEL, SKILL_LOTUS, SKILL_SPEAR]:
		role1_skill_inter[skill_name] = 0.0
		role1_skill_max_inter[skill_name] = 0.0
	role1_skill_inter[SKILL_YINYANG] = 0.0
	role1_skill_max_inter[SKILL_YINYANG] = 0.0
	on_eqchange()
	_refresh_attack_data()
	role_action_player.play(&"wait")


func ws_skill() -> bool:
	if RoleProp.is_ws_state or is_death:
		return false

	RoleProp.is_ws_state = true
	var activated := super.ws_skill()
	if not activated:
		RoleProp.is_ws_state = false
		return false
	return true


func _get_effect_scene() -> PackedScene:
	if _effect_scene == null:
		_effect_scene = (
			ResourceLoader.load(EFFECT_SCENE_PATH, "PackedScene", ResourceLoader.CACHE_MODE_REUSE) as PackedScene
		)
	return _effect_scene


func _get_yinyang_effect_scene() -> PackedScene:
	if _yinyang_effect_scene == null:
		_yinyang_effect_scene = (
			ResourceLoader.load(YINYANG_EFFECT_SCENE_PATH, "PackedScene", ResourceLoader.CACHE_MODE_REUSE)
			as PackedScene
		)
	return _yinyang_effect_scene


func _ensure_special_skills_in_normal_slots() -> void:
	var skill_data_value: Variant = PlayerData.player_data.get(DataKeys.SKILL_LEARNED, {})
	if not skill_data_value is Dictionary:
		return
	var skill_data: Dictionary = skill_data_value
	var bindings_value: Variant = skill_data.get("技能键位", {})
	if not bindings_value is Dictionary:
		bindings_value = {"Y": "", "U": "", "I": "", "O": "", "L": ""}
		skill_data["技能键位"] = bindings_value
	var bindings: Dictionary = bindings_value

	for slot in SKILL_KEY_SLOTS:
		if str(bindings.get(slot, "")) != "":
			return
	_ensure_learned_skill_binding(bindings, skill_data, SKILL_LOTUS, 4, "O")
	_ensure_learned_skill_binding(bindings, skill_data, SKILL_SPEAR, 5, "L")


func _ensure_learned_skill_binding(
	bindings: Dictionary, skill_data: Dictionary, skill_name: String, skill_index: int, preferred_slot: String
) -> void:
	var level_data: Variant = skill_data.get("技能" + str(skill_index), {})
	if not level_data is Dictionary or int(level_data.get(DataKeys.LEVEL, 0)) <= 0:
		return
	if skill_name in bindings.values():
		return
	bindings[preferred_slot] = skill_name


func _physics_process(delta: float) -> void:
	if _lotus_enabled and _is_lotus_action_just_pressed():
		_disable_fire_lotus()
		_lotus_toggle_locked = true
	if _yinyang_enabled and _is_yinyang_action_just_pressed():
		_disable_yin_yang_sword()
		_yinyang_toggle_locked = true
	if _lotus_toggle_locked and not _is_any_skill_action_pressed():
		_lotus_toggle_locked = false
	if _yinyang_toggle_locked and not _is_any_skill_action_pressed():
		_yinyang_toggle_locked = false
	_process_fire_lotus(delta)
	_refresh_attack_data()
	_process_yin_yang_sword(delta)
	var motion_was_active := _skill_motion_remaining > 0.0
	var motion_velocity := _skill_motion_velocity
	var motion_start_x := global_position.x
	var skill_motion_ends := _apply_skill_motion(delta)
	_apply_spear_input()
	super._physics_process(delta)
	if motion_was_active and not is_zero_approx(motion_velocity.x):
		var expected_motion_x := motion_velocity.x * delta
		if absf(global_position.x - motion_start_x) < absf(expected_motion_x) * 0.5:
			velocity.x = motion_velocity.x
			move_and_slide()
	if _enhanced_visual_hidden:
		_apply_enhanced_visual_hidden()
	if skill_motion_ends:
		velocity = Vector2.ZERO
	if (
		not is_riding_mount()
		and no_limit_buff()
		and PlayerInput.is_action_pressed("normalhit")
		and not is_attacking
		and not is_be_attacking
		and not is_using_skills
	):
		if is_on_floor():
			match hit_count:
				0:
					do_normalhit_1()
				1:
					do_normalhit_2()
				2:
					do_normalhit_3()
				_:
					do_normalhit_4()
		else:
			do_normalhit_5()


func _build_body_animations() -> void:
	var current_animation := role_action_player.current_animation
	var was_playing := role_action_player.is_playing()
	var current_position := 0.0
	if current_animation != &"" and role_action_player.has_animation(current_animation):
		current_position = role_action_player.current_animation_position
		_set_equipment_textures_at(current_animation, current_position)
	role_action_player.stop()
	var library := AnimationLibrary.new()
	var animation_names: Variant = role_body.get("animation_names")
	if not animation_names is Array:
		animation_names = []
	for animation_name_value: Variant in animation_names:
		var animation_name := str(animation_name_value)
		var animation := Animation.new()
		var frame_count: int = role_body.call("get_frame_count", animation_name)
		animation.length = (
			STANDARD_HURT_ANIMATION_LENGTH if animation_name == "hurt" else maxf(float(frame_count) / 30.0, 1.0 / 30.0)
		)
		animation.loop_mode = (
			Animation.LOOP_LINEAR if animation_name in ["wait", "run", "drop"] else Animation.LOOP_NONE
		)
		for sprite: Sprite2D in [role_body, role_body_front, role_equipment]:
			var track := animation.add_track(Animation.TYPE_VALUE)
			animation.track_set_path(track, NodePath("Action/" + str(sprite.name) + ":pose_key"))
			animation.value_track_set_update_mode(track, Animation.UPDATE_DISCRETE)
			for frame_index in range(frame_count):
				animation.track_insert_key(
					track,
					_body_frame_time(StringName(animation_name), frame_index, frame_count),
					animation_name + ":" + str(frame_index)
				)
		var speed_track := animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(speed_track, NodePath("RolePlayer:speed_scale"))
		animation.value_track_set_update_mode(speed_track, Animation.UPDATE_CONTINUOUS)
		animation.track_insert_key(speed_track, 0.0, STANDARD_HURT_PLAYBACK_SPEED if animation_name == "hurt" else 1.0)
		_add_wings_animation_tracks(animation, StringName(animation_name))
		library.add_animation(animation_name, animation)
	for library_name in role_action_player.get_animation_library_list():
		role_action_player.remove_animation_library(library_name)
	role_action_player.add_animation_library(&"", library)
	role_action_player.clear_caches()
	if current_animation != &"" and role_action_player.has_animation(current_animation):
		role_action_player.play(current_animation)
		role_action_player.seek(current_position, true)
		if not was_playing:
			role_action_player.pause()


func _body_frame_time(animation_name: StringName, frame_index: int, frame_count: int) -> float:
	if animation_name != &"hurt" or frame_count <= 1:
		return float(frame_index) / 30.0
	return float(frame_index) * STANDARD_HURT_ANIMATION_LENGTH / float(frame_count - 1)


func _load_official_layer(sprite: Sprite2D, equipment_id: String, layer_name: String, layer_index: int) -> void:
	sprite.set("layer", layer_index)
	var set_name := NeZhaEquipmentVisuals.resolve_set(equipment_id, layer_name)
	if not sprite.call("load_set", set_name):
		push_error("哪吒官方部件无法加载：" + set_name)
	sprite.texture = OFFICIAL_PARTS_TRANSPARENT
	sprite.hframes = 1
	sprite.vframes = 1


func _set_equipment_textures_at(animation_name: StringName, position: float) -> void:
	for sprite: Sprite2D in [role_body, role_body_front, role_equipment]:
		var count: int = sprite.call("get_frame_count", str(animation_name))
		if count == 0:
			continue
		var frame := int(floor(position * 30.0))
		if animation_name == &"hurt":
			frame = int(floor(position * float(count - 1) / STANDARD_HURT_ANIMATION_LENGTH))
		sprite.call("set_pose", str(animation_name), clampi(frame, 0, count - 1))


func _resolve_equipment_animation(frames: SpriteFrames, animation_name: StringName) -> StringName:
	if frames.has_animation(animation_name) and frames.get_frame_count(animation_name) > 0:
		return animation_name
	var base_animation_name := String(animation_name).replace("_enhanced", "")
	if frames.has_animation(base_animation_name) and frames.get_frame_count(base_animation_name) > 0:
		return StringName(base_animation_name)
	return &"wait"


func _add_wings_animation_tracks(animation: Animation, animation_name: StringName) -> void:
	var wing_position := WINGS_BASE_POSITION
	var wing_rotation := WINGS_BASE_ROTATION
	match animation_name:
		&"run":
			wing_position = WINGS_RUN_POSITION
			wing_rotation = WINGS_RUN_ROTATION
		&"hurt":
			wing_position = WINGS_HURT_POSITION
			wing_rotation = WINGS_HURT_ROTATION

	var position_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(position_track, NodePath("Action/Wings:position"))
	animation.value_track_set_update_mode(position_track, Animation.UPDATE_CONTINUOUS)
	animation.track_insert_key(position_track, 0.0, wing_position)

	var rotation_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(rotation_track, NodePath("Action/Wings:rotation"))
	animation.value_track_set_update_mode(rotation_track, Animation.UPDATE_CONTINUOUS)
	animation.track_insert_key(rotation_track, 0.0, wing_rotation)


func _refresh_attack_data() -> void:
	var attack := float(RoleProp.roleprop.power)
	obj_attack_dict["hit1"] = _hit_data(attack, 1.0, 0.0, Vector2(1, 0))
	obj_attack_dict["hit2"] = _hit_data(attack, 1.0, 0.0, Vector2(1, 0))
	obj_attack_dict["hit3"] = _hit_data(attack, 1.1, 0.0, Vector2(1, 0))
	obj_attack_dict["hit4"] = _hit_data(attack, 1.4, 0.0, Vector2(2, -3))
	obj_attack_dict["hit5"] = _hit_data(attack, 1.15, 0.0, Vector2(1, -2))
	obj_attack_dict[SKILL_JIULONG] = _skill_hit_data(attack, 0.6706, 0.2, 1, Vector2(0, -20))
	obj_attack_dict[SKILL_DASH] = _skill_hit_data(attack, 0.8504, 0.26, 2, Vector2(8, -2))
	obj_attack_dict[SKILL_WHEEL] = _skill_hit_data(attack, 0.8504, 0.22, 3, Vector2(3, -2))
	obj_attack_dict[SKILL_SPEAR] = _skill_hit_data(attack, 1.0465, 0.35, 5, Vector2(6, -2))
	obj_attack_dict[SKILL_SPEAR + "_ground"] = _skill_hit_data(attack, 3.0368, 0.431, 5, Vector2(6, -2))
	obj_attack_dict[SKILL_SPEAR + "_target"] = _skill_hit_data(attack, 0.522, 0.32, 5, Vector2.ZERO)
	obj_attack_dict[SKILL_SPEAR + "_target"]["addeffect"] = {
		"Name": "defe_reduce",
		"AddTime": 8,
		"reduce_interval": 0,
		"value": SPEAR_TARGET_DEFENSE_REDUCTION,
		"AttackKind": "",
		"CanAdd": false,
		"CanRemove": false,
		"DeBuff": true,
	}
	obj_attack_dict[SKILL_YINYANG] = _skill_hit_data(attack, 0.8504, 0.2, 6, Vector2(0, -10))
	role_equipment.visible = true
	role_equipment.self_modulate = Color.WHITE


func _hit_data(attack: float, multiplier: float, flat_damage: float, knockback: Vector2) -> Dictionary:
	return {
		"power": attack * multiplier + flat_damage,
		"hurtBack": [knockback.x, knockback.y],
		"attackKind": "physics",
		"WSValue": 4,
	}


func _skill_hit_data(
	attack: float, base_multiplier: float, level_multiplier: float, skill_index: int, knockback: Vector2
) -> Dictionary:
	var level := clampi(int(get_skill_level(skill_index)), 1, 20)
	return _hit_data(attack, base_multiplier + level_multiplier * level, 0.0, knockback)


func do_normalhit_1() -> void:
	await _play_melee(&"hit1", "hit1", &"attack1_0", 4, 2, 1)


func do_normalhit_2() -> void:
	await _play_melee(&"hit2", "hit2", &"attack1_1", 3, 2, 2)


func do_normalhit_3() -> void:
	await _play_melee(&"hit3", "hit3", &"attack1_2", 4, 2, 3)


func do_normalhit_4() -> void:
	await _play_melee(&"hit4", "hit4", &"attack1_3", 8, 3, 0)


func do_normalhit_5() -> void:
	await _play_melee(&"hit5", "hit5", &"jumpAttack_0", 4, 3, 0)


func _play_melee(
	animation_name: StringName,
	hit_key: String,
	effect_name: StringName,
	start_frame: int,
	_active_frames: int,
	next_combo: int
) -> void:
	velocity.x = 0.0
	is_attacking = true
	get_action = hit_key
	get_hit_data(hit_key)
	role_action_player.play(animation_name)
	_play_official_action_sound(animation_name)
	await _wait_frames(start_frame)
	if not is_inside_tree() or is_death:
		return
	var effect := _spawn_effect(
		effect_name, obj_attack_dict[hit_key], -1.0, 0.0, 1, Vector2.ZERO, Vector2.ZERO, true, true
	)
	effect.follow_target = self
	effect.bullet_player.animation_finished.connect(effect.queue_free, CONNECT_ONE_SHOT)
	await role_action_player.animation_finished
	if is_inside_tree() and not is_death:
		hit_count = next_combo
		is_attacking = false


func _sync_melee_shape_to_effect(effect: NeZhaSkillEffect) -> void:
	if not is_instance_valid(effect):
		return
	var effect_rectangle := effect.collion.shape as RectangleShape2D
	var melee_rectangle := melee_shape.shape as RectangleShape2D
	if effect_rectangle == null or melee_rectangle == null:
		return
	if not melee_rectangle.resource_local_to_scene:
		melee_rectangle = melee_rectangle.duplicate() as RectangleShape2D
		melee_rectangle.resource_local_to_scene = true
		melee_shape.shape = melee_rectangle
	melee_rectangle.size = effect_rectangle.size
	melee_shape.position = Vector2(-effect.collion.position.x, effect.collion.position.y)
	melee_shape.set_deferred("disabled", false)


func _disable_melee_shape() -> void:
	melee_shape.set_deferred("disabled", true)


func _scaled_skill_mp(base_cost: int, skill_index: int, next_level: bool = false, high_growth: bool = false) -> int:
	var skill_level := maxi(1, int(get_skill_level(skill_index)))
	var growth_level := skill_level if next_level else skill_level - 1
	var growth_rate := 3 if high_growth else 2
	return base_cost + ((3 + growth_rate * growth_level) * growth_level)


func _get_lotus_mp_per_second(next_level: bool = false) -> int:
	return _scaled_skill_mp(8, 4, next_level)


func _get_yinyang_mp_per_volley(next_level: bool = false) -> int:
	var level := maxi(1, int(get_skill_level(6))) + (1 if next_level else 0)
	return YINYANG_MP_VALUES[clampi(level - 1, 0, YINYANG_MP_VALUES.size() - 1)]


func get_need_mp(skill_name, next_level):
	var use_next_level: bool = next_level == true
	match str(skill_name):
		SKILL_JIULONG:
			return _scaled_skill_mp(13, 1, use_next_level)
		SKILL_DASH:
			return _scaled_skill_mp(19, 2, use_next_level)
		SKILL_WHEEL:
			return _scaled_skill_mp(28, 3, use_next_level)
		SKILL_LOTUS:
			return 0
		SKILL_SPEAR:
			return _scaled_skill_mp(66, 5, use_next_level, true)
		SKILL_YINYANG:
			return _get_yinyang_mp_per_volley(use_next_level)
	return 0


func get_skill_display_mp(skill_name: String) -> int:
	if skill_name == SKILL_LOTUS:
		return _get_lotus_mp_per_second()
	return int(get_need_mp(skill_name, false))


func get_skill(skill_name):
	var name := str(skill_name)
	if not is_inside_tree() or is_queued_for_deletion():
		return
	var scene_parent := get_parent()
	if scene_parent == null or not is_instance_valid(scene_parent):
		return
	var level := scene_parent.get_parent()
	if level == null or not is_instance_valid(level) or level.is_queued_for_deletion():
		return
	if level is Level17 or level is Level22:
		return
	if name == SKILL_YINYANG and _yinyang_toggle_locked:
		return
	if name == SKILL_YINYANG and _yinyang_enabled:
		_disable_yin_yang_sword()
		_yinyang_toggle_locked = true
		return
	if name == SKILL_LOTUS and _lotus_toggle_locked:
		return
	if is_silent or name == "" or is_using_skills or is_be_attacking or is_death:
		return
	if not role1_skill_inter.has(name) or role1_skill_inter[name] > 0.0:
		return
	var mp_cost := int(get_need_mp(name, false))
	if RoleProp.roleprop.Mp < mp_cost:
		return
	if name != SKILL_YINYANG:
		RoleProp.roleprop.Mp -= mp_cost

	role1_skill_inter[name] = 1.8
	if name == SKILL_LOTUS:
		_lotus_toggle_locked = true
	elif name == SKILL_YINYANG:
		_yinyang_toggle_locked = true
	match name:
		SKILL_JIULONG:
			_use_jiulong_fire()
		SKILL_DASH:
			_use_fire_dash()
		SKILL_WHEEL:
			_use_fire_wheel()
		SKILL_LOTUS:
			_use_fire_lotus()
		SKILL_SPEAR:
			_use_six_arm_spear()
		SKILL_YINYANG:
			_use_yin_yang_sword()


func _begin_skill(animation_name: StringName, hit_key: String) -> int:
	_skill_interrupt_generation += 1
	_jiulong_ground_recovery = false
	velocity.x = 0.0
	super_armor_active = true
	is_using_skills = true
	is_attacking = true
	get_action = hit_key
	role_action_player.play(animation_name)
	if hit_key != SKILL_YINYANG:
		_play_official_action_sound(animation_name)
	return _skill_interrupt_generation


func _finish_skill(skill_generation: int = -1) -> void:
	if skill_generation >= 0 and skill_generation != _skill_interrupt_generation:
		return
	melee_shape.set_deferred("disabled", true)
	_restore_enhanced_visuals()
	body_sprite.visible = true
	_skill_motion_remaining = 0.0
	_skill_motion_velocity = Vector2.ZERO
	_spear_move_mode = SPEAR_MOVE_NONE
	_enhanced_spear_target = null
	_enhanced_direction_changed = false
	velocity.x = 0.0
	super_armor_active = false
	if not is_death:
		is_attacking = false
		is_using_skills = false


func _is_skill_execution_current(skill_generation: int, hit_key: String) -> bool:
	return (
		is_inside_tree()
		and not is_death
		and skill_generation == _skill_interrupt_generation
		and is_using_skills
		and get_action == hit_key
	)


func _cancel_skill_for_control() -> void:
	if super_armor_active:
		return
	if (
		not is_using_skills
		and not is_attacking
		and _skill_motion_remaining <= 0.0
		and _spear_move_mode == SPEAR_MOVE_NONE
		and not _enhanced_visual_hidden
	):
		return
	_skill_interrupt_generation += 1
	_jiulong_ground_recovery = false
	_finish_skill()
	get_action = ""
	velocity = Vector2.ZERO


func _skill_super_armor_active() -> bool:
	return is_using_skills and not is_death


func _use_jiulong_fire() -> void:
	var interrupt_generation := _begin_skill(&"skill1", SKILL_JIULONG)
	_add_spear_energy(15)
	velocity.y = jump_power
	_spawn_effect(&"effect1_2", obj_attack_dict[SKILL_JIULONG], 0.4, 0.166, 3, Vector2.ZERO, Vector2.ZERO, true, true)
	await _wait_frames(6)
	if interrupt_generation != _skill_interrupt_generation or not is_inside_tree() or is_death:
		return
	velocity.y = -210.0
	_start_skill_motion(Vector2(0.0, -210.0), 11.0 / 30.0)
	await _wait_frames(11)
	if interrupt_generation != _skill_interrupt_generation or not is_inside_tree() or is_death:
		return
	_jiulong_ground_recovery = true
	is_attacking = false
	is_using_skills = false
	super_armor_active = false
	await _wait_frames(3)
	if interrupt_generation == _skill_interrupt_generation:
		_jiulong_ground_recovery = false


func _use_fire_dash() -> void:
	var skill_generation := _begin_skill(&"skill2", SKILL_DASH)
	_add_spear_energy(15)
	await _wait_frames(4)
	if not _is_skill_execution_current(skill_generation, SKILL_DASH):
		return
	_start_skill_motion(Vector2(DASH_SPEED if player_dir else -DASH_SPEED, 0.0), DASH_DURATION)
	var dash_effect := _spawn_effect(
		&"effect2_2", obj_attack_dict[SKILL_DASH], DASH_DURATION, 0.2, 3, Vector2(240, 95), Vector2.ZERO, true
	)
	dash_effect.z_index = z_index - 1
	await role_action_player.animation_finished
	if _is_skill_execution_current(skill_generation, SKILL_DASH):
		_finish_skill(skill_generation)


func _use_fire_wheel() -> void:
	var skill_generation := _begin_skill(&"skill3", SKILL_WHEEL)
	_add_spear_energy(15)
	await _wait_frames(2)
	if not _is_skill_execution_current(skill_generation, SKILL_WHEEL):
		return
	_spawn_effect(&"effect3_0", obj_attack_dict[SKILL_WHEEL], 0.4, 1.0, 1, Vector2(150, 75), Vector2.ZERO, true)
	await _wait_frames(6)
	if not _is_skill_execution_current(skill_generation, SKILL_WHEEL):
		return
	var wheel := _spawn_effect(&"effect3_1", obj_attack_dict[SKILL_WHEEL], 5.0, 1.0, 5, Vector2.ZERO)
	wheel.orbit_target = self
	wheel.orbit_radii = Vector2(250, 25)
	wheel.orbit_offset = Vector2(0, -50)
	wheel.orbit_angle = 1.5 * PI
	wheel.orbit_speed = TAU
	await role_action_player.animation_finished
	if _is_skill_execution_current(skill_generation, SKILL_WHEEL):
		_finish_skill(skill_generation)


func _use_yin_yang_sword() -> void:
	var skill_generation := _begin_skill(&"skill3", SKILL_YINYANG)
	_add_spear_energy(15)
	_yinyang_enabled = true
	_yinyang_elapsed = 0.0
	_yinyang_lower_branch = false
	_yinyang_sweep_ratio = 0.0
	_yinyang_sweep_direction = 1.0
	_spawn_yinyang_aura("aura_toggle")
	await role_action_player.animation_finished
	if _is_skill_execution_current(skill_generation, SKILL_YINYANG):
		_finish_skill(skill_generation)


func _process_yin_yang_sword(delta: float) -> void:
	if not _yinyang_enabled:
		return
	if is_death:
		_disable_yin_yang_sword()
		return

	if is_be_attacking:
		return
	_yinyang_elapsed += delta
	var interval := YINYANG_AWAKEN_INTERVAL if _is_yinyang_awaken_active() else YINYANG_INTERVAL
	if _yinyang_elapsed < interval:
		return
	_yinyang_elapsed -= interval
	var mp_cost := int(get_need_mp(SKILL_YINYANG, false))
	if RoleProp.roleprop.Mp < mp_cost:
		_disable_yin_yang_sword()
		return
	RoleProp.roleprop.Mp -= mp_cost
	_spawn_yin_yang_pair()


func _spawn_yin_yang_pair() -> void:
	var sword_offsets: Array
	var launch_offsets: Array
	var trajectory_angle := 0.0
	var lower_branch := _yinyang_lower_branch
	if _is_yinyang_awaken_active():
		var sweep_ratio := _yinyang_sweep_ratio
		sword_offsets = [
			lerp(YINYANG_LOWER_SWORD_OFFSETS[0], YINYANG_UPPER_SWORD_OFFSETS[0], sweep_ratio),
			lerp(YINYANG_LOWER_SWORD_OFFSETS[1], YINYANG_UPPER_SWORD_OFFSETS[1], sweep_ratio),
		]
		launch_offsets = [
			lerp(YINYANG_LOWER_LAUNCH_OFFSETS[0], YINYANG_UPPER_LAUNCH_OFFSETS[0], sweep_ratio),
			lerp(YINYANG_LOWER_LAUNCH_OFFSETS[1], YINYANG_UPPER_LAUNCH_OFFSETS[1], sweep_ratio),
		]
		trajectory_angle = -YINYANG_AWAKEN_MAX_ANGLE * sweep_ratio
		lower_branch = sweep_ratio < 0.5
		_advance_yinyang_awaken_sweep()
	else:
		sword_offsets = YINYANG_LOWER_SWORD_OFFSETS if lower_branch else YINYANG_UPPER_SWORD_OFFSETS
		launch_offsets = YINYANG_LOWER_LAUNCH_OFFSETS if lower_branch else YINYANG_UPPER_LAUNCH_OFFSETS
		_yinyang_lower_branch = not lower_branch
	_spawn_yinyang_aura("aura_yang" if lower_branch else "aura_yin")
	_spawn_yin_yang_launch(launch_offsets[0], "launch_yin", true, trajectory_angle)
	_spawn_yin_yang_sword(sword_offsets[0], "yin", true, trajectory_angle)
	_spawn_delayed_yin_yang_sword(sword_offsets[1], launch_offsets[1], trajectory_angle)


func _advance_yinyang_awaken_sweep() -> void:
	_yinyang_sweep_ratio += YINYANG_AWAKEN_SWEEP_STEP * _yinyang_sweep_direction
	if _yinyang_sweep_ratio >= 1.0:
		_yinyang_sweep_ratio = 1.0
		_yinyang_sweep_direction = -1.0
	elif _yinyang_sweep_ratio <= 0.0:
		_yinyang_sweep_ratio = 0.0
		_yinyang_sweep_direction = 1.0


func _spawn_delayed_yin_yang_sword(
	sword_offset: Vector2, launch_offset: Vector2, trajectory_angle: float = 0.0
) -> void:
	await get_tree().create_timer(YINYANG_SECOND_SWORD_DELAY).timeout
	if not is_inside_tree() or is_death:
		return
	_spawn_yin_yang_launch(launch_offset, "launch_yang", false, trajectory_angle)
	_spawn_yin_yang_sword(sword_offset, "yang", false, trajectory_angle)


func _spawn_yin_yang_sword(
	local_offset: Vector2, sword_type: String, front_layer: bool, trajectory_angle: float = 0.0
) -> void:
	var effect_scene := _get_yinyang_effect_scene()
	if effect_scene == null:
		return
	var effect := effect_scene.instantiate() as NeZhaYinYangEffect
	effect.configure_yin_yang(self, obj_attack_dict[SKILL_YINYANG], player_dir, sword_type, trajectory_angle)
	effect.use_visual_collision = true
	effect.z_index = z_index + 1 if front_layer else z_index - 1
	var level := get_parent().get_parent()
	level.add_child(effect)
	effect.global_position = (
		global_position + Vector2(local_offset.x if player_dir else -local_offset.x, local_offset.y)
	)


func _spawn_yin_yang_launch(
	local_offset: Vector2, launch_kind: String, front_layer: bool, trajectory_angle: float = 0.0
) -> void:
	var effect_scene := _get_yinyang_effect_scene()
	if effect_scene == null:
		return
	var effect := effect_scene.instantiate() as NeZhaYinYangEffect
	effect.configure_launch(self, player_dir, launch_kind, trajectory_angle)
	effect.z_index = z_index + 1 if front_layer else z_index - 1
	var level := get_parent().get_parent()
	level.add_child(effect)
	effect.global_position = (
		global_position + Vector2(local_offset.x if player_dir else -local_offset.x, local_offset.y)
	)


func _spawn_yinyang_aura(aura_kind: String) -> void:
	var effect_scene := _get_yinyang_effect_scene()
	if effect_scene == null:
		return
	var aura := effect_scene.instantiate() as NeZhaYinYangEffect
	aura.configure_aura(self, player_dir, aura_kind)
	aura.z_index = z_index - 1
	var level := get_parent().get_parent()
	level.add_child(aura)
	aura.global_position = global_position
	if aura_kind == "aura_toggle":
		_yinyang_toggle_effect = aura


func _disable_yin_yang_sword() -> void:
	_yinyang_enabled = false
	_yinyang_elapsed = 0.0
	if is_instance_valid(_yinyang_toggle_effect):
		_yinyang_toggle_effect.queue_free()
		_yinyang_toggle_effect = null
	if is_inside_tree() and not is_death:
		_spawn_yinyang_aura("aura_toggle")
	if is_using_skills and get_action == SKILL_YINYANG:
		_finish_skill()


func _use_fire_lotus() -> void:
	if is_instance_valid(_lotus_effect) and _lotus_enabled:
		_disable_fire_lotus()
		return
	var skill_generation := _begin_skill(&"skill4", SKILL_LOTUS)
	_lotus_enabled = true
	await _wait_frames(1)
	if not _is_skill_execution_current(skill_generation, SKILL_LOTUS):
		_disable_fire_lotus()
		return
	_spawn_effect(&"effect4_0", {}, 0.467, 0.0, 1, Vector2.ZERO, Vector2.ZERO, true)
	if not is_instance_valid(_lotus_effect):
		_lotus_effect = _spawn_effect(&"charge0", {}, -1.0, 0.0, 1, Vector2.ZERO, Vector2(-100, -150))
		_lotus_effect.follow_target_facing = true
		_lotus_effect.mirror_like_player = true
	_lotus_effect.z_index = z_index - 1
	await role_action_player.animation_finished
	if _is_skill_execution_current(skill_generation, SKILL_LOTUS):
		_finish_skill(skill_generation)


func _process_fire_lotus(delta: float) -> void:
	if _lotus_enabled and _lotus_charge < 5:
		_lotus_mp_elapsed += delta
		if _lotus_mp_elapsed >= 1.0:
			_lotus_mp_elapsed -= 1.0
			var lotus_mp_cost := _get_lotus_mp_per_second()
			if RoleProp.roleprop.Mp >= lotus_mp_cost:
				RoleProp.roleprop.Mp -= lotus_mp_cost
				_lotus_charge = mini(5, _lotus_charge + 1)
				_update_lotus_visual()
	elif _lotus_charge >= 5:
		_lotus_mp_elapsed = 0.0
	var lotus_awakened := _is_skill_awakened(SKILL_LOTUS) and _is_skill_awaken_enabled(SKILL_LOTUS)
	_update_lotus_awaken_bonuses(lotus_awakened)
	var heal_threshold := 0.7 if lotus_awakened else 0.9
	if (
		RoleProp.roleprop.SHp > 0
		and float(RoleProp.roleprop.Hp) / float(RoleProp.roleprop.SHp) < heal_threshold
		and _lotus_charge > 0
	):
		_lotus_heal_elapsed += delta
		if _lotus_heal_elapsed >= 0.3:
			_lotus_heal_elapsed -= 0.3
			_lotus_charge -= 1
			var lotus_skill_level := maxi(1, int(get_skill_level(4)))
			cure_hp(int(float(RoleProp.roleprop.power) * 0.02 * lotus_skill_level + 8.0))
			_update_lotus_visual(true)
	else:
		_lotus_heal_elapsed = 0.0
	_update_lotus_awaken_bonuses(lotus_awakened)


func _update_lotus_awaken_bonuses(awakened: bool) -> void:
	var current_power := float(RoleProp.roleprop.power)
	if not _lotus_awaken_stats_initialized or not is_equal_approx(current_power, _lotus_last_power):
		_lotus_base_power = current_power
		_lotus_awaken_stats_initialized = true
	var charge := float(_lotus_charge) if awakened else 0.0
	var lotus_skill_level := float(clampi(int(get_skill_level(4)), 1, 20))
	RoleProp.roleprop.power = int(round(_lotus_base_power * (1.0 + charge * lotus_skill_level * 0.01)))
	_lotus_last_power = float(RoleProp.roleprop.power)


func _update_lotus_visual(consuming: bool = false) -> void:
	if is_instance_valid(_lotus_effect):
		var prefix := "consume" if consuming else "charge"
		var animation_name := StringName(prefix + str(_lotus_charge))
		var followup_name := (
			&"charge0" if consuming and _lotus_charge == 0 else StringName(prefix + str(_lotus_charge) + "-xunhuan")
		)
		_lotus_effect.play_with_followup(animation_name, followup_name)


func _use_six_arm_spear() -> void:
	if (_is_skill_awakened("nz_lblc") and _is_skill_awaken_enabled("nz_lblc")) or _spear_energy >= 100:
		_spear_energy = 0
		await _use_six_arm_spear_enhanced()
		return
	_add_spear_energy(60)
	var skill_generation := _begin_skill(&"skill5", SKILL_SPEAR)
	_spear_move_mode = SPEAR_MOVE_NORMAL
	await _wait_frames(5)
	if not _is_skill_execution_current(skill_generation, SKILL_SPEAR):
		return
	_spawn_effect(
		&"effect5_2", obj_attack_dict[SKILL_SPEAR], 0.567, 0.134, 3, Vector2(260, 130), Vector2.ZERO, true, true
	)
	await _wait_frames(16)
	if not _is_skill_execution_current(skill_generation, SKILL_SPEAR):
		return
	_spawn_effect(&"effect5_3", obj_attack_dict[SKILL_SPEAR], 0.134, 1.0, 1, Vector2(220, 130))
	await _wait_frames(1)
	if not _is_skill_execution_current(skill_generation, SKILL_SPEAR):
		return
	_start_skill_motion(Vector2(0.0, -900.0), 6.0 / 30.0)
	await _wait_frames(6)
	if not _is_skill_execution_current(skill_generation, SKILL_SPEAR):
		return
	_start_skill_motion(Vector2(600.0 if player_dir else -600.0, 870.0), 5.0 / 30.0)
	await _wait_frames(3)
	if not _is_skill_execution_current(skill_generation, SKILL_SPEAR):
		return
	_spawn_effect(
		&"effect5_4", obj_attack_dict[SKILL_SPEAR + "_ground"], 0.4, 1.0, 1, Vector2(320, 150), Vector2.ZERO, true, true
	)
	await role_action_player.animation_finished
	if _is_skill_execution_current(skill_generation, SKILL_SPEAR):
		_finish_skill(skill_generation)


func _use_six_arm_spear_enhanced() -> void:
	var skill_generation := _begin_skill(&"skill5_enhanced", SKILL_SPEAR)
	_hide_enhanced_visuals()
	_spear_move_mode = SPEAR_MOVE_ENHANCED
	var move_direction := 1.0 if player_dir else -1.0
	_start_skill_motion(Vector2(move_direction * OFFICIAL_MOVE_SPEED_SCALE, 0.0), 0.4)
	_spawn_effect(&"effect5_5", obj_attack_dict[SKILL_SPEAR], 0.833, 0.0, 1, Vector2.ZERO, Vector2.ZERO, true, true)
	await _wait_frames(7)
	if not _is_skill_execution_current(skill_generation, SKILL_SPEAR):
		return
	_enhanced_spear_target = _find_nearest_active_monster()
	var enhanced_effect := _spawn_effect(
		&"effect5_8",
		obj_attack_dict[SKILL_SPEAR + "_target"],
		1.367,
		0.366,
		4,
		Vector2(2, 2),
		Vector2.ZERO,
		false,
		true
	)
	enhanced_effect.global_position = global_position + Vector2(100.0 if player_dir else -100.0, -10.0)
	if is_instance_valid(_enhanced_spear_target):
		enhanced_effect.global_position = (
			_enhanced_spear_target.global_position + Vector2(100.0 if player_dir else -100.0, -10.0)
		)
	enhanced_effect.z_index = z_index - 10
	await _wait_frames(7)
	if not _is_skill_execution_current(skill_generation, SKILL_SPEAR):
		return
	move_direction = 1.0 if player_dir else -1.0
	_start_skill_motion(Vector2(move_direction * 300.0 * OFFICIAL_MOVE_SPEED_SCALE, 0.0), 0.3)
	_spawn_effect(
		&"effect5_6", obj_attack_dict[SKILL_SPEAR], 0.367, 1.0, 1, Vector2(220, 130), Vector2.ZERO, true, false
	)
	await _wait_frames(10)
	if not _is_skill_execution_current(skill_generation, SKILL_SPEAR):
		return
	await _wait_frames(1)
	if not _is_skill_execution_current(skill_generation, SKILL_SPEAR):
		return
	_spawn_effect(&"effect5_5_1", obj_attack_dict[SKILL_SPEAR], 0.7, 0.0, 1, Vector2.ZERO, Vector2.ZERO, true, true)
	await _wait_frames(1)
	if not _is_skill_execution_current(skill_generation, SKILL_SPEAR):
		return
	move_direction = 1.0 if player_dir else -1.0
	_start_skill_motion(Vector2(move_direction * OFFICIAL_MOVE_SPEED_SCALE, 0.0), 0.3)
	await _wait_frames(7)
	if not _is_skill_execution_current(skill_generation, SKILL_SPEAR):
		return
	_spawn_effect(
		&"effect5_7", obj_attack_dict[SKILL_SPEAR + "_ground"], 0.434, 1.0, 1, Vector2.ZERO, Vector2.ZERO, true, true
	)
	await role_action_player.animation_finished
	if _is_skill_execution_current(skill_generation, SKILL_SPEAR):
		_finish_skill(skill_generation)


func _add_spear_energy(amount: int) -> void:
	_spear_energy = mini(100, _spear_energy + amount)


func _start_skill_motion(motion_velocity: Vector2, duration: float) -> void:
	_skill_motion_velocity = motion_velocity
	_skill_motion_remaining = duration


func _apply_skill_motion(delta: float) -> bool:
	if _skill_motion_remaining <= 0.0:
		return false
	velocity = _skill_motion_velocity
	if velocity.y != 0.0 and not is_on_floor():
		velocity.y += gravity * delta
	_skill_motion_remaining = maxf(0.0, _skill_motion_remaining - delta)
	return _skill_motion_remaining <= 0.0


func _apply_spear_input() -> void:
	if _spear_move_mode == SPEAR_MOVE_NONE or not is_using_skills:
		return
	if _spear_move_mode == SPEAR_MOVE_ENHANCED and not _enhanced_direction_changed:
		var enhanced_frame := int(floor(role_action_player.current_animation_position * 30.0))
		if enhanced_frame >= 24:
			_enhanced_direction_changed = true
			var target := _find_nearest_active_monster()
			if is_instance_valid(target) and not is_zero_approx(target.global_position.x - global_position.x):
				_set_spear_facing(target.global_position.x >= global_position.x)
	var direction := PlayerInput.get_axis("move_left", "move_right")
	if is_reverse_move:
		direction = -direction
	if is_zero_approx(direction):
		return
	var frame_index := int(floor(role_action_player.current_animation_position * 30.0))
	var wants_right := direction > 0.0
	if wants_right != player_dir:
		var can_turn := frame_index >= 23 and frame_index <= 30
		if _spear_move_mode == SPEAR_MOVE_ENHANCED:
			can_turn = frame_index >= 25 and frame_index <= 33
		if not can_turn:
			return
		_set_spear_facing(wants_right)
	velocity.x = direction * walk_speed * RoleProp.ws_up_power * reverse_move_speed_multiplier


func _set_spear_facing(face_right: bool) -> void:
	player_dir = face_right
	action.scale.x = -1.0 if face_right else 1.0
	base_damagebox.scale.x = -1.0 if face_right else 1.0


func _find_nearest_active_monster() -> Node2D:
	var candidates: Array = []
	var level := get_parent().get_parent()
	if level != null and level.has_method("get_active_monsters"):
		candidates = level.call("get_active_monsters")
	else:
		candidates = get_tree().get_nodes_in_group("monsters")
	var nearest: Node2D
	var nearest_distance := INF
	for candidate in candidates:
		if not is_instance_valid(candidate) or not candidate is BaseMonster or candidate.hp <= 0:
			continue
		var distance := global_position.distance_squared_to(candidate.global_position)
		if distance < nearest_distance:
			nearest = candidate
			nearest_distance = distance
	return nearest


func _is_skill_awakened(skill_id: String) -> bool:
	var awaken_data: Variant = PlayerData.player_data.get(DataKeys.Skill.AWAKENED, {})
	return awaken_data is Dictionary and bool(awaken_data.get(skill_id, false))


func _is_skill_awaken_enabled(skill_id: String) -> bool:
	var enabled_data: Variant = PlayerData.player_data.get(DataKeys.Skill.AWAKENED_ENABLED, {})
	if not enabled_data is Dictionary:
		return true
	if not enabled_data.has(skill_id):
		return true
	return bool(enabled_data.get(skill_id, false))


func _is_yinyang_awaken_active() -> bool:
	return _is_skill_awakened(SKILL_YINYANG) and _is_skill_awaken_enabled(SKILL_YINYANG)


func _is_auto_battle_skill_active(skill_id: String) -> bool:
	if skill_id == SKILL_YINYANG:
		return _yinyang_enabled
	if skill_id == SKILL_LOTUS:
		return _lotus_enabled
	return false


func _disable_fire_lotus() -> void:
	_lotus_enabled = false
	_lotus_mp_elapsed = 0.0


func check_can_wait():
	if _jiulong_ground_recovery:
		return false
	return super.check_can_wait()


func _is_any_skill_action_pressed() -> bool:
	for action_name in SKILL_INPUT_ACTIONS:
		if PlayerInput.is_action_pressed(action_name):
			return true
	return false


func _is_lotus_action_just_pressed() -> bool:
	var skill_data: Variant = PlayerData.player_data.get(DataKeys.SKILL_LEARNED, {})
	if not skill_data is Dictionary:
		return false
	var skill_bindings: Variant = skill_data.get("技能键位", {})
	if not skill_bindings is Dictionary:
		return false
	for index in range(mini(SKILL_INPUT_ACTIONS.size(), SKILL_KEY_SLOTS.size())):
		if (
			PlayerInput.is_action_just_pressed(SKILL_INPUT_ACTIONS[index])
			and str(skill_bindings.get(SKILL_KEY_SLOTS[index], "")) == SKILL_LOTUS
		):
			return true
	return false


func _is_yinyang_action_just_pressed() -> bool:
	var skill_data: Variant = PlayerData.player_data.get(DataKeys.SKILL_LEARNED, {})
	if not skill_data is Dictionary:
		return false
	var skill_bindings: Variant = skill_data.get("技能键位", {})
	if not skill_bindings is Dictionary:
		return false
	for index in range(mini(SKILL_INPUT_ACTIONS.size(), SKILL_KEY_SLOTS.size())):
		if (
			PlayerInput.is_action_just_pressed(SKILL_INPUT_ACTIONS[index])
			and str(skill_bindings.get(SKILL_KEY_SLOTS[index], "")) == SKILL_YINYANG
		):
			return true
	return false


func _spawn_effect(
	animation_name: StringName,
	hit_data: Dictionary,
	duration: float,
	interval: float,
	pulses: int,
	shape_size: Vector2,
	local_offset: Vector2 = Vector2.ZERO,
	follow_self: bool = false,
	visual_collision: bool = false
) -> NeZhaSkillEffect:
	var effect_scene := _get_effect_scene()
	if effect_scene == null:
		return null
	var effect := effect_scene.instantiate() as NeZhaSkillEffect
	effect.configure(self, animation_name, hit_data, player_dir, duration, interval, pulses, shape_size)
	effect.use_visual_collision = visual_collision
	var level := get_parent().get_parent()
	level.add_child(effect)
	effect.global_position = (
		global_position + Vector2(local_offset.x if player_dir else -local_offset.x, local_offset.y)
	)
	if duration < 0.0 or follow_self:
		effect.follow_target = self
		effect.follow_offset = local_offset
		effect.follow_target_facing = follow_self
	return effect


func _exit_tree() -> void:
	if is_instance_valid(_lotus_effect):
		_lotus_effect.queue_free()
	if is_instance_valid(_yinyang_toggle_effect):
		_yinyang_toggle_effect.queue_free()
	super._exit_tree()


func _wait_frames(frame_count: int) -> void:
	await get_tree().create_timer(float(frame_count) / 30.0).timeout


func _prepare_hit_reaction() -> void:
	_skill_interrupt_generation += 1
	_jiulong_ground_recovery = false
	var movement_velocity_x := velocity.x
	_finish_skill()
	velocity.x = movement_velocity_x


func _set_protect_visual(active: bool) -> void:
	super._set_protect_visual(active)
	if is_instance_valid(role_body_front):
		role_body_front.self_modulate = Color(1, 1, 1, 0.5 if active else 1.0)


func _hide_enhanced_visuals() -> void:
	if _enhanced_visual_hidden:
		return
	_enhanced_visual_state = {
		"role_body_visible": body_sprite.visible,
		"role_body_modulate": body_sprite.self_modulate,
		"role_body_front_visible": role_body_front.visible,
		"role_body_front_modulate": role_body_front.self_modulate,
		"role_equipment_visible": role_equipment.visible,
		"role_equipment_modulate": role_equipment.self_modulate,
		"wings_visible": wings.visible,
		"wings_modulate": wings.self_modulate,
		"tx_visible": tx.visible,
		"tx_modulate": tx.self_modulate,
	}
	_enhanced_visual_hidden = true
	_apply_enhanced_visual_hidden()


func _apply_enhanced_visual_hidden() -> void:
	body_sprite.visible = false
	role_body.self_modulate = Color(1, 1, 1, 0)
	role_body_front.visible = false
	role_body_front.self_modulate = Color(1, 1, 1, 0)
	role_equipment.visible = false
	role_equipment.self_modulate = Color(1, 1, 1, 0)
	wings.visible = false
	wings.self_modulate = Color(1, 1, 1, 0)
	tx.visible = false
	tx.self_modulate = Color(1, 1, 1, 0)


func _restore_enhanced_visuals() -> void:
	if not _enhanced_visual_hidden:
		return
	role_body.visible = bool(_enhanced_visual_state.get("role_body_visible", true))
	role_body.self_modulate = _enhanced_visual_state.get("role_body_modulate", Color.WHITE)
	role_body_front.visible = bool(_enhanced_visual_state.get("role_body_front_visible", true))
	role_body_front.self_modulate = _enhanced_visual_state.get("role_body_front_modulate", Color.WHITE)
	role_equipment.visible = bool(_enhanced_visual_state.get("role_equipment_visible", true))
	role_equipment.self_modulate = _enhanced_visual_state.get("role_equipment_modulate", Color.WHITE)
	wings.visible = bool(_enhanced_visual_state.get("wings_visible", true))
	wings.self_modulate = _enhanced_visual_state.get("wings_modulate", Color.WHITE)
	tx.visible = bool(_enhanced_visual_state.get("tx_visible", true))
	tx.self_modulate = _enhanced_visual_state.get("tx_modulate", Color.WHITE)
	_enhanced_visual_state.clear()
	_enhanced_visual_hidden = false


func change_body(_name) -> void:
	_body_equipment_id = str(_name)
	preload("res://Script/hero/moon_palace_clothes_effect.gd").sync(role_body, _body_equipment_id, true)
	_load_official_layer(body_sprite, _body_equipment_id, "body", 0)
	_load_official_layer(role_body_front, _body_equipment_id, "body_front", 2)
	_build_body_animations()


func change_eq(_name) -> void:
	_weapon_equipment_id = str(_name)
	_load_official_layer(role_equipment, _weapon_equipment_id, "weapon", 1)
	_build_body_animations()
