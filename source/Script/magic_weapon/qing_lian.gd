extends BaseMagicWeapon
class_name QingLian

const IDLE_FRAMES_RES := "res://Art/magic_weapon/magic_weapon_qing_lian/idle_frames/qing_lian_idle_frames.tres"
const EFFECT_FRAMES_RES := "res://Art/magic_weapon/magic_weapon_qing_lian/ef_effect1_frames/qing_lian_effect_frames.tres"
const AURA_FRAMES_RES := "res://Art/magic_weapon/magic_weapon_qing_lian/aura_frames/qing_lian_aura_frames.tres"
@onready var special_effect: AnimatedSprite2D = $SpecialEffect
@onready var aura_effect: AnimatedSprite2D = $AuraEffect

var _previous_damage_reduction: float = 0.0
var _damage_reduction_applied := false
const ACTIVATION_DURATION: float = 14.0 / 30.0
const BUFF_DURATION: float = 10.0
const COOLDOWN_DURATION: float = 30.0
var _effect_token: int = 0
var _texture_bounds_cache: Dictionary = {}


func _ready() -> void:
	fb_level = clampi(PlayerData.get_most_level("dzyl"), 1, 10)
	var idle_frames := load(IDLE_FRAMES_RES) as SpriteFrames
	var effect_frames := load(EFFECT_FRAMES_RES) as SpriteFrames
	var aura_frames := load(AURA_FRAMES_RES) as SpriteFrames
	if idle_frames == null or effect_frames == null or aura_frames == null:
		push_error("青莲构建期帧资源缺失")
		return
	mg_action.sprite_frames = idle_frames
	special_effect.sprite_frames = effect_frames
	aura_effect.sprite_frames = aura_frames
	mg_action.play("wait")
	special_effect.visible = false
	aura_effect.visible = false


func _physics_process(delta: float) -> void:
	fb_level = clampi(PlayerData.get_most_level("dzyl"), 1, 10)
	need_mp = 50
	super._physics_process(delta)
	if is_use:
		_follow_hero_during_skill()
	else:
		mg_action.play("wait")
		mg_action.visible = skill_cd.is_stopped()
	if aura_effect.visible or special_effect.visible:
		_update_effect_positions()


func _follow_hero_during_skill() -> void:
	if player == null or not is_instance_valid(player):
		return

	var role_x = RoleProp.role_pos_x
	var role_y = RoleProp.role_pos_y
	var hero_position := player.position
	if role_x != null and role_y != null:
		hero_position = Vector2(float(role_x), float(role_y))

	if RoleProp.directon:
		scale.x = -1
		self_dir = true
		position = hero_position - Vector2(100, 180)
	else:
		scale.x = 1
		self_dir = false
		position = hero_position - Vector2(-100, 180)


func _update_effect_positions() -> void:
	var foot_global_position: Variant = _get_player_visible_foot_global_position()
	if foot_global_position != null and aura_effect.get_parent() == player:
		var frame_texture := aura_effect.sprite_frames.get_frame_texture("effect", aura_effect.frame)
		var frame_bottom_offset := _get_sprite_visible_bottom_offset(aura_effect, frame_texture)
		var foot_local_position: Vector2 = player.to_local(foot_global_position)
		aura_effect.position = foot_local_position - frame_bottom_offset
	special_effect.position = Vector2(0, -75)


func _get_player_visible_foot_global_position() -> Variant:
	if player == null or not is_instance_valid(player):
		return null
	var ground_position: Variant = _get_player_ground_global_position()
	if ground_position != null:
		return ground_position
	var visible_bottom: Variant = null
	for node_path in ["Action/RoleBody", "Action/RoleEquipment", "Action/RoleBodyFront"]:
		var sprite := player.get_node_or_null(node_path) as Sprite2D
		if sprite == null or not sprite.visible or sprite.texture == null:
			continue
		var sprite_bottom: Variant = _get_sprite_visible_bottom_global_position(sprite)
		if sprite_bottom != null and (visible_bottom == null or sprite_bottom.y > visible_bottom.y):
			visible_bottom = sprite_bottom
	return visible_bottom


func _get_player_ground_global_position() -> Variant:
	var ground_shape := player.get_node_or_null("pz") as CollisionShape2D
	if ground_shape == null or ground_shape.shape == null:
		return null
	var shape_rect: Rect2 = ground_shape.shape.get_rect()
	return ground_shape.to_global(Vector2(0, shape_rect.end.y))


func _get_sprite_visible_bottom_global_position(sprite: Sprite2D) -> Variant:
	var texture_bounds := _get_sprite_frame_bounds(sprite)
	if texture_bounds.is_empty():
		return null
	var used_rect: Rect2 = texture_bounds["used_rect"]
	var canvas_origin: Vector2 = texture_bounds["canvas_origin"]
	var draw_rect := sprite.get_rect()
	var bottom_local := Vector2(
		draw_rect.position.x + canvas_origin.x + used_rect.position.x + used_rect.size.x * 0.5,
		draw_rect.position.y + canvas_origin.y + used_rect.position.y + used_rect.size.y
	)
	return sprite.to_global(bottom_local)


func _get_sprite_frame_bounds(sprite: Sprite2D) -> Dictionary:
	if sprite.texture is AtlasTexture:
		return _get_texture_bounds(sprite.texture)
	var texture := sprite.texture
	var cache_key := "%s:%d:%d:%d" % [texture.get_instance_id(), sprite.hframes, sprite.vframes, sprite.frame]
	if _texture_bounds_cache.has(cache_key):
		return _texture_bounds_cache[cache_key]
	var image := texture.get_image()
	if image == null:
		return {}
	var frame_width := image.get_width() / sprite.hframes
	var frame_height := image.get_height() / sprite.vframes
	var frame_column := sprite.frame % sprite.hframes
	var frame_row := sprite.frame / sprite.hframes
	var frame_image := image.get_region(
		Rect2i(frame_column * frame_width, frame_row * frame_height, frame_width, frame_height)
	)
	var used_rect := frame_image.get_used_rect()
	if used_rect.size == Vector2i.ZERO:
		return {}
	var bounds := {
		"used_rect": Rect2(used_rect),
		"canvas_size": Vector2(frame_width, frame_height),
		"canvas_origin": Vector2.ZERO,
	}
	_texture_bounds_cache[cache_key] = bounds
	return bounds


func _get_sprite_visible_bottom_offset(sprite: Node2D, texture: Texture2D) -> Vector2:
	if texture == null:
		return Vector2.ZERO
	var texture_bounds := _get_texture_bounds(texture, 128)
	if texture_bounds.is_empty():
		return Vector2.ZERO
	var used_rect: Rect2 = texture_bounds["used_rect"]
	var canvas_size: Vector2 = texture_bounds["canvas_size"]
	var canvas_origin: Vector2 = texture_bounds["canvas_origin"]
	var sprite_offset: Vector2 = sprite.get("offset")
	var bottom_local := (
		sprite_offset
		+ Vector2(
			-canvas_size.x * 0.5 + canvas_origin.x + used_rect.position.x + used_rect.size.x * 0.5,
			-canvas_size.y * 0.5 + canvas_origin.y + used_rect.position.y + used_rect.size.y
		)
	)
	return sprite.to_global(bottom_local) - sprite.global_position


func _get_texture_bounds(texture: Texture2D, alpha_threshold: int = 1) -> Dictionary:
	var cache_key := "%d:%d" % [texture.get_instance_id(), alpha_threshold]
	if _texture_bounds_cache.has(cache_key):
		return _texture_bounds_cache[cache_key]
	var image: Image
	var canvas_size := texture.get_size()
	var canvas_origin := Vector2.ZERO
	if texture is AtlasTexture:
		var atlas_texture := texture as AtlasTexture
		if atlas_texture.atlas == null:
			return {}
		image = atlas_texture.atlas.get_image().get_region(Rect2i(atlas_texture.region))
		canvas_size = atlas_texture.region.size + atlas_texture.margin.size
		canvas_origin = atlas_texture.margin.position
	else:
		image = texture.get_image()
	if image == null:
		return {}
	var used_rect := _get_alpha_threshold_rect(image, alpha_threshold)
	if used_rect.size == Vector2i.ZERO:
		return {}
	var bounds := {
		"used_rect": Rect2(used_rect),
		"canvas_size": canvas_size,
		"canvas_origin": canvas_origin,
	}
	_texture_bounds_cache[cache_key] = bounds
	return bounds


func _get_alpha_threshold_rect(image: Image, alpha_threshold: int) -> Rect2i:
	var min_x := image.get_width()
	var min_y := image.get_height()
	var max_x := -1
	var max_y := -1
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a * 255.0 < float(alpha_threshold):
				continue
			min_x = mini(min_x, x)
			min_y = mini(min_y, y)
			max_x = maxi(max_x, x)
			max_y = maxi(max_y, y)
	if max_x < min_x or max_y < min_y:
		return Rect2i()
	return Rect2i(min_x, min_y, max_x - min_x + 1, max_y - min_y + 1)


func show_skill() -> void:
	if player == null or not is_instance_valid(player):
		use_over()
		return
	_previous_damage_reduction = player.wdsl_damage_reduction
	player.wdsl_damage_reduction += 0.5
	_damage_reduction_applied = true
	(
		Global
		. add_buff(
			player.buff,
			{
				"Name": "SuperArmor",
				"AddTime": BUFF_DURATION,
				"reduce_interval": 0,
				"value": 0,
				"AttackKind": "",
				"CanRemove": false,
			}
		)
	)
	_effect_token += 1
	var effect_token := _effect_token
	mg_action.stop()
	mg_action.visible = false
	_show_skill_effect()
	await get_tree().create_timer(ACTIVATION_DURATION, false).timeout
	if is_inside_tree() and effect_token == _effect_token:
		use_over()
	await get_tree().create_timer(BUFF_DURATION - ACTIVATION_DURATION, false).timeout
	if is_inside_tree() and effect_token == _effect_token:
		_clear_skill_effect()


func _show_skill_effect() -> void:
	if player == null or not is_instance_valid(player):
		return
	if special_effect.get_parent() != player:
		special_effect.reparent(player, false)
	if aura_effect.get_parent() != player:
		aura_effect.reparent(player, false)
	special_effect.position = Vector2(0, -75)
	special_effect.z_index = 6
	special_effect.visible = true
	special_effect.stop()
	special_effect.frame = 0
	special_effect.frame_progress = 0.0
	special_effect.play("effect")
	aura_effect.frame = 0
	aura_effect.frame_progress = 0.0
	aura_effect.z_index = 2
	aura_effect.visible = true
	aura_effect.play("effect")
	_update_effect_positions()


func _clear_skill_effect() -> void:
	if _damage_reduction_applied and player != null and is_instance_valid(player):
		player.wdsl_damage_reduction = _previous_damage_reduction
	_damage_reduction_applied = false
	special_effect.stop()
	special_effect.visible = false
	aura_effect.stop()
	aura_effect.visible = false
	if special_effect.get_parent() != self:
		special_effect.reparent(self, false)
	if aura_effect.get_parent() != self:
		aura_effect.reparent(self, false)
	special_effect.position = Vector2(0, 105)
	special_effect.z_index = 0
	aura_effect.position = Vector2(0, 105)
	aura_effect.z_index = -2


func use_over() -> void:
	mg_action.visible = false
	is_use = false
	fb_cd = 1
	usecd = COOLDOWN_DURATION
	if PlayerData.check_have_wx("dzyl", "木"):
		usecd *= 0.8
	skill_cd.start(usecd)

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
