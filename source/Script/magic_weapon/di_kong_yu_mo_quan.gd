extends BaseMagicWeapon
class_name DiKongYuMoQuan

const WEAPON_ID := "469000011"
const IDLE_FRAME_COUNT := 24
const SPAWN_FRAME_COUNT := 6
const FIELD_FRAME_COUNT := 20
const FLASH_FRAME_COUNT := 14
const ACTIVATION_DURATION := 0.2
const BASE_FIELD_DURATION := 3.0
const LEVEL_DURATION_BONUS := 0.2
const COOLDOWN_DURATION := 30.0
const FIELD_SIZE := Vector2(283.0, 518.0)

@onready var field_anchor: Node2D = $FieldAnchor
@onready var spawn_effect: AnimatedSprite2D = $FieldAnchor/SpawnEffect
@onready var field_effect: AnimatedSprite2D = $FieldAnchor/FieldEffect
@onready var cast_flash: AnimatedSprite2D = $CastFlash

var _effect_token: int = 0
var _field_active := false
var _protection_applied := false
var _field_rect := Rect2()
var _visible_bottom_cache: Dictionary = {}


func _ready() -> void:
	fb_level = _get_official_level()
	need_mp = 50
	mg_action.sprite_frames = _build_frames(
		"wait",
		"res://Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/idle_frames/%d.png",
		IDLE_FRAME_COUNT,
		true,
		12.0
	)
	spawn_effect.sprite_frames = _build_frames(
		"spawn",
		"res://Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/spawn_frames/%d.png",
		SPAWN_FRAME_COUNT,
		false,
		30.0
	)
	field_effect.sprite_frames = _build_frames(
		"field",
		"res://Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/field_frames/%d.png",
		FIELD_FRAME_COUNT,
		true,
		30.0
	)
	cast_flash.sprite_frames = _build_frames(
		"flash",
		"res://Art/magic_weapon/magic_weapon_di_kong_yu_mo_quan/flash_frames/%d.png",
		FLASH_FRAME_COUNT,
		false,
		30.0
	)
	field_anchor.top_level = true
	spawn_effect.visible = false
	field_effect.visible = false
	cast_flash.visible = false
	mg_action.play("wait")


func _physics_process(delta: float) -> void:
	fb_level = _get_official_level()
	need_mp = 50
	super._physics_process(delta)
	if _field_active:
		_update_player_protection()
	if not is_use:
		mg_action.visible = skill_cd.is_stopped()
		if mg_action.visible and not mg_action.is_playing():
			mg_action.play("wait")


func _build_frames(
	animation_name: String, path_pattern: String, frame_count: int, looped: bool, speed: float
) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.add_animation(animation_name)
	frames.set_animation_loop(animation_name, looped)
	frames.set_animation_speed(animation_name, speed)
	for frame_index in range(1, frame_count + 1):
		var texture := load(path_pattern % frame_index) as Texture2D
		if texture != null:
			frames.add_frame(animation_name, texture)
	return frames


func _get_official_level() -> int:
	return clampi(PlayerData.get_most_level(WEAPON_ID), 1, 10)


func get_field_duration() -> float:
	return BASE_FIELD_DURATION + LEVEL_DURATION_BONUS * float(_get_official_level())


func show_skill() -> void:
	if player == null or not is_instance_valid(player):
		use_over()
		return

	_effect_token += 1
	var current_token := _effect_token
	mg_action.stop()
	mg_action.visible = false
	_place_fixed_field()
	_play_activation_effects()

	await get_tree().create_timer(ACTIVATION_DURATION, false).timeout
	if not is_inside_tree() or current_token != _effect_token:
		return

	spawn_effect.stop()
	spawn_effect.visible = false
	field_effect.visible = true
	field_effect.frame = 0
	field_effect.frame_progress = 0.0
	field_effect.play("field")
	_field_active = true
	_update_player_protection()

	await get_tree().create_timer(get_field_duration(), false).timeout
	if is_inside_tree() and current_token == _effect_token:
		use_over()


func _place_fixed_field() -> void:
	var ground_position := _get_player_ground_global_position()
	var field_bottom := _get_visible_bottom_center(field_effect, "field")
	var spawn_bottom := _get_visible_bottom_center(spawn_effect, "spawn")
	field_anchor.global_position = ground_position - field_bottom
	spawn_effect.position = field_bottom - spawn_bottom
	_field_rect = Rect2(field_anchor.global_position - FIELD_SIZE * 0.5, FIELD_SIZE)


func _get_visible_bottom_center(sprite: AnimatedSprite2D, animation_name: String) -> Vector2:
	if sprite.sprite_frames == null or sprite.sprite_frames.get_frame_count(animation_name) <= 0:
		return Vector2(0.0, FIELD_SIZE.y * 0.5)
	var texture := sprite.sprite_frames.get_frame_texture(animation_name, 0)
	if texture == null:
		return Vector2(0.0, FIELD_SIZE.y * 0.5)
	var cache_key := texture.get_instance_id()
	if _visible_bottom_cache.has(cache_key):
		return _visible_bottom_cache[cache_key]
	var image := texture.get_image()
	if image == null:
		return Vector2(0.0, texture.get_height() * 0.5)
	var used_rect := image.get_used_rect()
	if used_rect.size == Vector2i.ZERO:
		return Vector2(0.0, texture.get_height() * 0.5)
	var texture_size := texture.get_size()
	var bottom_center := Vector2(
		-texture_size.x * 0.5 + float(used_rect.position.x) + float(used_rect.size.x) * 0.5,
		-texture_size.y * 0.5 + float(used_rect.end.y)
	)
	_visible_bottom_cache[cache_key] = bottom_center
	return bottom_center


func _play_activation_effects() -> void:
	spawn_effect.visible = true
	spawn_effect.frame = 0
	spawn_effect.frame_progress = 0.0
	spawn_effect.play("spawn")
	cast_flash.visible = true
	cast_flash.frame = 0
	cast_flash.frame_progress = 0.0
	cast_flash.play("flash")


func _get_player_ground_global_position() -> Vector2:
	var ground_shape := player.get_node_or_null("pz") as CollisionShape2D
	if ground_shape != null and ground_shape.shape != null:
		var shape_rect: Rect2 = ground_shape.shape.get_rect()
		return ground_shape.to_global(Vector2(0.0, shape_rect.end.y))
	return player.global_position


func _get_player_body_global_rect() -> Rect2:
	var body_shape := player.get_node_or_null("pz") as CollisionShape2D
	if body_shape == null or body_shape.shape == null:
		return Rect2(player.global_position - Vector2(24.0, 48.0), Vector2(48.0, 96.0))

	var local_rect: Rect2 = body_shape.shape.get_rect()
	var points := [
		local_rect.position,
		Vector2(local_rect.end.x, local_rect.position.y),
		local_rect.end,
		Vector2(local_rect.position.x, local_rect.end.y),
	]
	var min_point := Vector2(INF, INF)
	var max_point := Vector2(-INF, -INF)
	for point: Vector2 in points:
		var global_point := body_shape.to_global(point)
		min_point.x = minf(min_point.x, global_point.x)
		min_point.y = minf(min_point.y, global_point.y)
		max_point.x = maxf(max_point.x, global_point.x)
		max_point.y = maxf(max_point.y, global_point.y)
	return Rect2(min_point, max_point - min_point)


func _update_player_protection() -> void:
	if player == null or not is_instance_valid(player):
		_set_player_protected(false)
		return
	_set_player_protected(_field_rect.intersects(_get_player_body_global_rect()))


func _set_player_protected(should_protect: bool) -> void:
	if should_protect == _protection_applied:
		return
	if player != null and is_instance_valid(player):
		if should_protect:
			player.add_dikong_field_invincibility()
			player.wdsl_damage_reduction += 1.0
		else:
			player.remove_dikong_field_invincibility()
			player.wdsl_damage_reduction = maxf(0.0, player.wdsl_damage_reduction - 1.0)
	_protection_applied = should_protect


func _clear_field_effects() -> void:
	_field_active = false
	_set_player_protected(false)
	spawn_effect.stop()
	spawn_effect.visible = false
	field_effect.stop()
	field_effect.visible = false
	cast_flash.stop()
	cast_flash.visible = false


func use_over() -> void:
	_effect_token += 1
	_clear_field_effects()
	mg_action.visible = false
	is_use = false
	fb_cd = 1
	usecd = COOLDOWN_DURATION
	if PlayerData.check_have_wx(WEAPON_ID, "木"):
		usecd *= 0.8
	skill_cd.start(usecd)


func _exit_tree() -> void:
	_effect_token += 1
	_field_active = false
	_set_player_protected(false)

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
