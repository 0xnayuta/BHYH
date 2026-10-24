extends Node2D
class_name LyfbAwakenEffect

var player_data: PlayerDataStore:
	get:
		return LocalCoop.data_for(self)
var role_props: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self)

const ATLAS_PATH := "res://Art/hero_picture/role_2/lyfb_awaken/runtime/HeroF_5012_skill.atlas"
const SKELETON_PATH := "res://Art/hero_picture/role_2/lyfb_awaken/runtime/HeroF_5012_skill07-gray.spine-json"
const RED_SKELETON_PATH := "res://Art/hero_picture/role_2/lyfb_awaken/runtime/HeroF_5012_skill07-red.spine-json"
const FALLBACK_TEXTURE_PATH := "res://Art/hero_picture/role_2/lyfb_awaken/runtime/hero_f_5012_skill.png"
const SPINE_SCALE := Vector2(0.2, 0.2)
const SPINE_DURATION := 1.05

const BLADE_HALF_SIZE := Vector2(620.0, 520.0)

const BLADE_HITS: Array[Dictionary] = [
	{"time": 0.0333, "bone": "xzf9"},
	{"time": 0.0667, "bone": "xzf10"},
	{"time": 0.2667, "bone": "xzf12"},
	{"time": 0.2667, "bone": "xzf13"},
	{"time": 0.3, "bone": "xzf14"},
	{"time": 0.4, "bone": "xzf15"},
	{"time": 0.4667, "bone": "xzf16"}
]

var owner_player: Node2D
var hit_data: Dictionary = {}
var face_right := true
var _spine: Variant = null
var _red_spine: Variant = null
var _fallback_sprites: Array[AnimatedSprite2D] = []
var _hit_bones: Dictionary = {}
static var _shared_data: Variant = null
static var _shared_red_data: Variant = null
static var _normal_material: CanvasItemMaterial
static var _additive_material: CanvasItemMaterial
static var _multiply_material: CanvasItemMaterial


func setup(player: Node2D, is_facing_right: bool, data: Dictionary = {}) -> void:
	owner_player = player
	face_right = is_facing_right
	hit_data = data.duplicate(true)
	_hit_bones.clear()


func _ready() -> void:
	if owner_player == null or not is_instance_valid(owner_player):
		queue_free()
		return
	global_position = owner_player.global_position
	if not await _spawn_spine_visual():
		_spawn_fallback_visual()
	_run_hits()
	_finish_after(SPINE_DURATION)


func _process(_delta: float) -> void:
	if owner_player == null or not is_instance_valid(owner_player):
		queue_free()
		return
	global_position = owner_player.global_position


func _spawn_spine_visual() -> bool:
	if not ClassDB.class_exists("SpineSkeletonDataResource") or not ClassDB.class_exists("SpineSprite"):
		push_error("LyfbAwakenEffect: Spine GDExtension is not loaded")
		return false
	if not _preload_spine_data():
		return false
	_spine = ClassDB.instantiate("SpineSprite")
	if _spine == null or not _spine.has_method("set_skeleton_data_res"):
		_spine = null
		return false
	_spine.scale = SPINE_SCALE
	scale.x = 1.0 if face_right else -1.0
	z_index = 99
	if _additive_material == null:
		_additive_material = CanvasItemMaterial.new()
		_additive_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_spine.z_index = 24
	add_child(_spine as Node)
	_spine.set_skeleton_data_res(_shared_data)
	_spine.set_normal_material(_normal_material)
	_spine.set_additive_material(_additive_material)
	_spine.set_screen_material(_additive_material)
	_spine.set_multiply_material(_multiply_material)
	if _shared_red_data != null:
		_red_spine = ClassDB.instantiate("SpineSprite")
		if _red_spine != null and _red_spine.has_method("set_skeleton_data_res"):
			_red_spine.scale = SPINE_SCALE
			_red_spine.z_index = 23
			add_child(_red_spine as Node)
			_red_spine.set_skeleton_data_res(_shared_red_data)
			_red_spine.set_normal_material(_normal_material)
			_red_spine.set_additive_material(_additive_material)
			_red_spine.set_screen_material(_additive_material)
			_red_spine.set_multiply_material(_multiply_material)
			var red_state: Variant = _red_spine.get_animation_state()
			if red_state == null:
				await get_tree().process_frame
				if _red_spine != null and is_instance_valid(_red_spine):
					red_state = _red_spine.get_animation_state()
			if red_state != null:
				red_state.set_animation("skill07", false, 0)
	var state: Variant = _spine.get_animation_state()
	if state == null:
		await get_tree().process_frame
		if _spine != null and is_instance_valid(_spine):
			state = _spine.get_animation_state()
	if state == null:
		_spine.queue_free()
		_spine = null
		return false
	state.set_animation("skill07", false, 0)
	_cache_hit_bones(_spine.get_skeleton())
	return true


func _spawn_fallback_visual() -> void:
	var texture := load(FALLBACK_TEXTURE_PATH) as Texture2D
	if texture == null:
		push_error("LyfbAwakenEffect: 无法加载兼容特效图集纹理: " + FALLBACK_TEXTURE_PATH)
		return
	scale.x = 1.0 if face_right else -1.0
	z_index = 99
	const FRAME_RECTS := [
		Rect2(503, 2005, 113, 38),
		Rect2(1878, 1976, 160, 67),
		Rect2(1783, 1839, 210, 71),
		Rect2(938, 1793, 220, 73),
		Rect2(512, 1724, 236, 78),
		Rect2(854, 1627, 230, 82),
		Rect2(1255, 1698, 238, 79),
		Rect2(1238, 1613, 218, 83),
		Rect2(750, 1722, 183, 80),
		Rect2(1838, 1758, 180, 79),
		Rect2(1160, 1791, 165, 75),
		Rect2(2, 1821, 167, 71),
		Rect2(1790, 1912, 169, 62),
		Rect2(167, 2022, 168, 21),
		Rect2(106, 2027, 59, 16),
		Rect2(2, 2030, 42, 13)
	]
	const BLADE_TRANSFORMS := [
		{"time": 0.0333, "position": Vector2(44.0, 32.6), "rotation": 8.71, "scale": Vector2(1.646, 1.646)},
		{"time": 0.0667, "position": Vector2(47.0, 36.3), "rotation": 160.27, "scale": Vector2(1.582, 1.582)},
		{"time": 0.2667, "position": Vector2(12.6, 27.5), "rotation": 9.89, "scale": Vector2(1.716, 1.716)},
		{"time": 0.2667, "position": Vector2(60.4, 27.7), "rotation": 9.61, "scale": Vector2(1.788, 1.788)},
		{"time": 0.3, "position": Vector2(7.6, 30.9), "rotation": -54.11, "scale": Vector2(-1.752, 1.752)},
		{"time": 0.4, "position": Vector2(57.1, 46.2), "rotation": -137.02, "scale": Vector2(-1.662, 1.662)},
		{"time": 0.4667, "position": Vector2(6.8, 26.0), "rotation": -8.96, "scale": Vector2(-1.0, 1.0)}
	]
	for blade_data in BLADE_TRANSFORMS:
		_spawn_fallback_blade_after(texture, FRAME_RECTS, blade_data)


func _spawn_fallback_blade_after(texture: Texture2D, frame_rects: Array, blade_data: Dictionary) -> void:
	var delay := float(blade_data["time"])
	if delay > 0.0:
		await get_tree().create_timer(delay, false).timeout
	if not is_inside_tree():
		return
	var frames := SpriteFrames.new()
	frames.add_animation("skill07")
	frames.set_animation_speed("skill07", 30.0)
	frames.set_animation_loop("skill07", false)
	for frame_rect in frame_rects:
		var atlas_texture := AtlasTexture.new()
		atlas_texture.atlas = texture
		atlas_texture.region = frame_rect
		frames.add_frame("skill07", atlas_texture)
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = frames
	sprite.animation = "skill07"
	sprite.position = blade_data["position"]
	sprite.rotation_degrees = float(blade_data["rotation"])
	var blade_scale: Vector2 = blade_data["scale"]
	sprite.scale = blade_scale * SPINE_SCALE
	sprite.z_index = 24
	sprite.material = _additive_material
	add_child(sprite)
	_fallback_sprites.append(sprite)
	sprite.play("skill07")


func _finish_after(duration: float) -> void:
	await get_tree().create_timer(duration, false).timeout
	if is_inside_tree():
		queue_free()


func _run_hits() -> void:
	var previous_time := 0.0
	for blade_hit in BLADE_HITS:
		var hit_time := float(blade_hit["time"])
		var wait_time := hit_time - previous_time
		if wait_time > 0.0:
			await get_tree().create_timer(wait_time, false).timeout
		if owner_player == null or not is_instance_valid(owner_player):
			return
		_apply_blade_damage(str(blade_hit["bone"]))
		previous_time = hit_time


func _apply_blade_damage(bone_name: String) -> void:
	if owner_player == null or not is_instance_valid(owner_player):
		return
	if hit_data.is_empty() and owner_player.hit_dic is Dictionary:
		hit_data = owner_player.hit_dic.duplicate(true)
	if hit_data.is_empty():
		return
	var hit_center := _get_blade_global_position(bone_name)
	var level := _find_level_node()
	if level != null and level.has_method("has_active_monster_index") and level.has_active_monster_index():
		for target in level.get_active_monsters():
			_damage_target_if_in_range(target, hit_center)
		return
	if level != null:
		var monster_container: Node = level.get("monster") as Node
		if monster_container != null:
			_damage_recursive(monster_container, hit_center)
			return
	var scene := get_tree().current_scene
	if scene != null:
		_damage_recursive(scene, hit_center)


func _find_level_node() -> Node:
	var node: Node = owner_player.get_parent() if owner_player != null else null
	while node != null:
		if node is BaseLevel or node.get("monster") is Node:
			return node
		node = node.get_parent()
	return get_tree().current_scene


func _damage_target_if_in_range(target: Variant, hit_center: Vector2) -> void:
	if target == null or not is_instance_valid(target) or not (target is BaseMonster):
		return
	var monster := target as BaseMonster
	if monster.hp <= 0 or monster.no_target or monster.is_boss_protecting():
		return
	var offset: Vector2 = monster.global_position + Vector2(0.0, -70.0) - hit_center
	if absf(offset.x) <= BLADE_HALF_SIZE.x and absf(offset.y) <= BLADE_HALF_SIZE.y:
		_apply_hit(monster)


func _get_blade_global_position(bone_name: String) -> Vector2:
	var blade_position := global_position
	if _spine != null and is_instance_valid(_spine) and _spine.has_method("get_skeleton"):
		var skeleton: Variant = _spine.get_skeleton()
		if skeleton != null:
			var bone: Variant = _hit_bones.get(bone_name)
			if bone == null and skeleton.has_method("find_bone"):
				bone = skeleton.find_bone(bone_name)
				if bone != null:
					_hit_bones[bone_name] = bone
			if bone != null and bone.has_method("get_global_transform"):
				if skeleton.has_method("update_world_transform"):
					skeleton.update_world_transform(0)

				blade_position = bone.get_global_transform().origin
	return blade_position


func _cache_hit_bones(skeleton: Variant) -> void:
	_hit_bones.clear()
	if skeleton == null or not skeleton.has_method("find_bone"):
		return
	for blade_hit in BLADE_HITS:
		var bone_name := str(blade_hit["bone"])
		var bone: Variant = skeleton.find_bone(bone_name)
		if bone != null:
			_hit_bones[bone_name] = bone


func _damage_recursive(node: Node, hit_center: Vector2) -> void:
	if node is BaseMonster:
		_damage_target_if_in_range(node, hit_center)
	for child in node.get_children():
		_damage_recursive(child, hit_center)


func _apply_hit(target: BaseMonster) -> void:
	if target == null or not is_instance_valid(target) or target.hp <= 0:
		return
	var damage_source_state := target.bind_role_damage_source(owner_player as BaseHero)
	var old_hit_data: Dictionary = owner_player.hit_dic
	var old_target: Variant = target.get_target
	var old_miss: int = target.miss
	var old_source_player: Variant = role_props.source_player
	var old_tszzs: float = owner_player.tszzs

	var awakening_hit_data := hit_data.duplicate(true)
	var skill_level := int(player_data.player_data[DataKeys.SKILL_LEARNED]["技能4"][DataKeys.LEVEL]) + 1
	awakening_hit_data["power"] = role_props.roleprop.power * (1.8 + skill_level * 0.25)
	owner_player.hit_dic = awakening_hit_data
	target.get_target = owner_player
	target.has_target = true

	target.miss = 0

	role_props.source_player = owner_player
	if owner_player.istsz:
		var tsz_level := int(player_data.player_data["腾蛇阵"]["Level"])
		owner_player.tszzs = tsz_level * 0.015
	else:
		owner_player.tszzs = 0.0
	var damage_scale := float(target.llrdzs)
	if is_nan(damage_scale) or is_inf(damage_scale) or damage_scale <= 0.0:
		damage_scale = 1.0
	var damage := int(
		(
			float(target.get_role_last_hurt(owner_player))
			* role_props.ws_up_power
			* target.jgz_bl
			* target.zznh_bl
			* target.hurt_bl
			* (1.0 + target.lpzzs)
			* (1.0 + owner_player.tszzs)
			* damage_scale
		)
	)
	target.hurt_received = damage
	target.cure_ws_value(owner_player as BaseHero)
	target.hurt_reduce_hp(damage, owner_player)
	if damage > 0:
		target.add_lj(damage)
		Global.total_role_hit += damage
		if str(hit_data.get("attackKind", "")) == "magic":
			Global.total_mag_hit += damage
		Global.add_sound(target, "res://Music/monster_hurt/6_beattack_by_role1.mp3")
		if not target.is_miss and not target.is_boss_protecting():
			target.hurt_special_effect = Global.add_mr_hurt(target.pz, Vector2.ZERO)
		target.role5_bullet(damage, owner_player)
	target.get_target = old_target
	target.miss = old_miss
	owner_player.hit_dic = old_hit_data
	owner_player.tszzs = old_tszzs
	target.unbind_role_damage_source(damage_source_state)
	role_props.source_player = old_source_player


static func preload_effect_data() -> bool:
	if _shared_data != null:
		return true
	var atlas := load(ATLAS_PATH)
	var skeleton_file := load(SKELETON_PATH)
	if atlas == null:
		push_error("LyfbAwakenEffect: 无法加载 Spine atlas: " + ATLAS_PATH)
		return false
	if skeleton_file == null:
		push_error("LyfbAwakenEffect: 无法加载 Spine skeleton: " + SKELETON_PATH)
		return false
	var skeleton_data: Variant = ClassDB.instantiate("SpineSkeletonDataResource")
	if skeleton_data == null:
		return false
	skeleton_data.set_atlas_res(atlas)
	skeleton_data.set_skeleton_file_res(skeleton_file)
	skeleton_data.update_skeleton_data()
	if not skeleton_data.is_skeleton_data_loaded():
		push_error("LyfbAwakenEffect: Spine 骨骼数据解析失败: " + SKELETON_PATH)
		return false
	_shared_data = skeleton_data
	var red_skeleton_file := load(RED_SKELETON_PATH)
	if red_skeleton_file != null:
		var red_skeleton_data: Variant = ClassDB.instantiate("SpineSkeletonDataResource")
		if red_skeleton_data != null:
			red_skeleton_data.set_atlas_res(atlas)
			red_skeleton_data.set_skeleton_file_res(red_skeleton_file)
			red_skeleton_data.update_skeleton_data()
			if red_skeleton_data.is_skeleton_data_loaded():
				_shared_red_data = red_skeleton_data
	_normal_material = CanvasItemMaterial.new()
	_normal_material.blend_mode = CanvasItemMaterial.BLEND_MODE_MIX
	_additive_material = CanvasItemMaterial.new()
	_additive_material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_multiply_material = CanvasItemMaterial.new()
	_multiply_material.blend_mode = CanvasItemMaterial.BLEND_MODE_MUL
	return true


static func clear_cached_data() -> void:
	_shared_data = null
	_shared_red_data = null
	_normal_material = null
	_additive_material = null
	_multiply_material = null


static func _preload_spine_data() -> bool:
	return preload_effect_data()
