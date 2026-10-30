extends Node2D
class_name MainSwordArrayWeapon

const SWORD_CONFIG := {
	"zhuxianjian":
	{
		"body": "res://Art/zhuxianjianzhen/sword_hover/sword1/sprites/DefineSprite_3_idle",
		"effect": "res://Art/zhuxianjianzhen/sword_hover/sword1/sprites/DefineSprite_18_effect1_1",
		"impact": "res://Art/zhuxianjianzhen/sword_hover/sword1/sprites/DefineSprite_32_ef_effect1",
		"scale": Vector2(0.95, 0.95),
		"effect_scale": Vector2(1.0, 1.0),
		"power_rate_base": 4.0,
		"power_rate_per_level": 0.3,
	},
	"xianxianjian":
	{
		"body": "res://Art/zhuxianjianzhen/sword_hover/sword2/sprites/DefineSprite_3_idle",
		"effect": "res://Art/zhuxianjianzhen/xianxianjian/sprites/DefineSprite_54_mc_effect2",
		"projectile": "res://Art/zhuxianjianzhen/sword_hover/sword2/sprites/DefineSprite_24_effect1_1",
		"impact": "res://Art/zhuxianjianzhen/sword_hover/sword2/sprites/DefineSprite_38_ef_effect1",
		"scale": Vector2(0.95, 0.95),
		"effect_scale": Vector2(1.0, 1.0),
		"effect_offset": Vector2(0, -280),
		"power_rate_base": 12.0,
		"power_rate_per_level": 0.8,
	},
	"sijianheyi":
	{
		"body": "res://Art/zhuxianjianzhen/sword_hover/sword3/sprites/DefineSprite_3_idle",
		"effect": "res://Art/zhuxianjianzhen/sijianguiyi/sprites/DefineSprite_101_mc_effect3",
		"projectile": "res://Art/zhuxianjianzhen/sword_hover/sword3/sprites/DefineSprite_48_effect1_1",
		"impact": "res://Art/zhuxianjianzhen/sword_hover/sword3/sprites/DefineSprite_62_ef_effect1",
		"scale": Vector2(0.95, 0.95),
		"effect_scale": Vector2(1.0, 1.0),
		"effect_offset": Vector2(0, -160),
		"power_rate_base": 6.0,
		"power_rate_per_level": 0.8,
	},
	"luxianjian":
	{
		"body": "res://Art/zhuxianjianzhen/sword_hover/sword4/sprites/DefineSprite_3_idle",
		"effect": "res://Art/zhuxianjianzhen/luxianjian/sprites/DefineSprite_38_effect3",
		"projectile": "res://Art/zhuxianjianzhen/sword_hover/sword4/sprites/DefineSprite_26_effect1_1",
		"impact": "res://Art/zhuxianjianzhen/sword_hover/sword4/sprites/DefineSprite_40_ef_effect1",
		"scale": Vector2(0.95, 0.95),
		"effect_scale": Vector2(1.0, 1.0),
		"power_rate_base": 3.0,
		"power_rate_per_level": 0.2,
	},
	"juexianjian":
	{
		"body": "res://Art/zhuxianjianzhen/sword_hover/sword5/sprites/DefineSprite_3_idle",
		"effect": "res://Art/zhuxianjianzhen/juexianjian/sprites/DefineSprite_38_effect3",
		"projectile": "res://Art/zhuxianjianzhen/sword_hover/sword5/sprites/DefineSprite_16_effect1_1",
		"impact": "res://Art/zhuxianjianzhen/sword_hover/sword5/sprites/DefineSprite_30_ef_effect1",
		"scale": Vector2(0.95, 0.95),
		"effect_scale": Vector2(1.0, 1.0),
		"effect_offset": Vector2.ZERO,
		"power_rate_base": 3.0,
		"power_rate_per_level": 0.2,
	},
}
const CAST_CD := 30.0
const HIT_RADIUS := 520.0
const IMPACT_RADIUS := 300.0
const FOLLOW_X := 160.0
const FOLLOW_Y := -175.0
const HOVER_FLOAT_AMPLITUDE := 3.0
const HOVER_FLOAT_SPEED := 5.0
const HOVER_Z_INDEX := 1001
const ZHUXIAN_HIT_DELAYS := [0.5, 1.25, 2.0]
const XIANXIAN_HIT_DELAY := 1.65
const LUXIAN_ROTATE_START_DELAY := 1.55
const LUXIAN_ROTATE_DURATION := 1.2
const LUXIAN_HIT_INTERVAL := 0.2
const LUXIAN_ADVANCE_DISTANCE := 260.0
const LUXIAN_HURT_BACK := [-4, -2]
const LUXIAN_STUN_TIME := 0.35
const JUEXIAN_FIELD_START_DELAY := 1.2
const JUEXIAN_FIELD_DURATION := 4.8
const JUEXIAN_HIT_INTERVAL := 0.4
const SIJIAN_FIELD_START_DELAY := 1.3
const SIJIAN_FIELD_DURATION := 3.6
const SIJIAN_HIT_INTERVAL := 0.3
const SIJIAN_HIT_RADIUS := 430.0
const SIJIAN_STUN_TIME := 1.0
const SWORD_ARRAY_DEFE_REDUCE_VALUE := 0.5
const SWORD_ARRAY_HIT_COLLISION_MASK := 1024 | 2048 | 16
const SWORD_ARRAY_HIT_BULLET_SCENE_PATH := "res://Scene/hero/sword_array_hit_bullet.tscn"
const SWORD_FRAMES_RES := "res://Art/zhuxianjianzhen/atlas/zhuxianjianzhen_effects.tres"

@onready var sprite: AnimatedSprite2D = $Sprite2D

var player: Node2D
var sword_id: String = ""
var _follow_tick: int = 0
var _follow_tween: Tween
var _hover_elapsed := 0.0
var _sprite_base_position := Vector2.ZERO

static var _standard_sword_frames: SpriteFrames = null
static var _prewarmed_swords: Dictionary = {}
static var _sword_hit_bullet_scene: PackedScene = null


func _ready() -> void:
	z_as_relative = false
	z_index = HOVER_Z_INDEX
	scale.x = 1
	_sprite_base_position = sprite.position
	_apply_idle_animation()


func set_sword_id(value: String) -> void:
	sword_id = value
	if is_inside_tree():
		_apply_idle_animation()


func cast_skill() -> void:
	if sword_id == "" or not SWORD_CONFIG.has(sword_id):
		return
	if _get_sword_level() < 1:
		return
	if sword_id == "zhuxianjian":
		_run_zhuxian_skill()
		return
	if sword_id == "xianxianjian":
		_run_xianxian_skill()
		return
	if sword_id == "sijianheyi":
		_run_sijian_skill()
		return
	if sword_id == "luxianjian":
		_run_luxian_skill()
		return
	if sword_id == "juexianjian":
		_run_juexian_skill()
		return
	_run_sword_projectile()


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		queue_free()
		return
	_update_hover_float(delta)
	_follow_tick += 1
	if _follow_tick % 30 == 0:
		_fix_hero()
	sprite.flip_h = false


func _fix_hero() -> void:
	var target := _get_follow_position()
	scale.x = 1
	if _follow_tween != null and _follow_tween.is_valid():
		_follow_tween.kill()
	_follow_tween = get_tree().create_tween()
	_follow_tween.tween_property(self, "position", target, 0.5)


func _exit_tree() -> void:
	if sprite != null:
		sprite.sprite_frames = null
	clear_prewarmed_sword_resources()


func _update_hover_float(delta: float) -> void:
	_hover_elapsed += delta * HOVER_FLOAT_SPEED
	sprite.position = _sprite_base_position + Vector2(0, sin(_hover_elapsed) * HOVER_FLOAT_AMPLITUDE)


static func _get_standard_sword_frames() -> SpriteFrames:
	if _standard_sword_frames == null:
		_standard_sword_frames = load(SWORD_FRAMES_RES) as SpriteFrames
	return _standard_sword_frames


func _apply_idle_animation() -> void:
	if not SWORD_CONFIG.has(sword_id):
		visible = false
		return
	visible = true
	var config: Dictionary = SWORD_CONFIG[sword_id]
	var body_folder := str(config["body"])
	var standard_frames := _get_standard_sword_frames()
	if standard_frames == null:
		push_error("诛仙剑阵标准帧资源缺失")
		visible = false
		return
	if not standard_frames.has_animation(body_folder):
		push_error("诛仙剑阵标准帧缺少动画: %s" % body_folder)
		visible = false
		return
	sprite.sprite_frames = standard_frames
	sprite.scale = config.get("scale", Vector2(0.55, 0.55)) as Vector2
	sprite.play(StringName(body_folder))


func _prewarm_sword_frames(target_sword_id: String) -> void:
	prewarm_sword_frames(target_sword_id)


static func prewarm_active_sword_resources() -> void:
	prewarm_sword_frames(get_active_sword_id())


static func get_active_sword_preload_paths() -> Array[String]:
	return get_sword_hover_preload_paths(get_active_sword_id())


static func clear_prewarmed_sword_resources() -> void:
	_prewarmed_swords.clear()
	_sword_hit_bullet_scene = null


static func get_sword_hover_preload_paths(target_sword_id: String) -> Array[String]:
	var paths: Array[String] = []
	if SWORD_CONFIG.has(target_sword_id):
		paths.append(SWORD_FRAMES_RES)
	return paths


static func get_active_sword_id() -> String:
	if PlayerData == null:
		return ""
	if PlayerData.has_method("ensure_main_sword_array"):
		PlayerData.ensure_main_sword_array()
	var active := str(PlayerData.player_data.get("主线剑阵出战", ""))
	if active == "" or not SWORD_CONFIG.has(active):
		return ""
	if PlayerData.has_method("can_main_sword_array_battle") and not PlayerData.can_main_sword_array_battle(active):
		return ""
	return active


static func get_sword_preload_paths(target_sword_id: String) -> Array[String]:
	var paths: Array[String] = []
	if SWORD_CONFIG.has(target_sword_id):
		paths.append(SWORD_FRAMES_RES)
	return paths


static func prewarm_sword_frames(target_sword_id: String) -> void:
	if not SWORD_CONFIG.has(target_sword_id):
		return
	_prewarm_sword_hit_bullet_scene()
	_prewarmed_swords[target_sword_id] = true


static func _prewarm_sword_hit_bullet_scene() -> void:
	if _sword_hit_bullet_scene != null:
		return
	_sword_hit_bullet_scene = Global.preload_scene_path(SWORD_ARRAY_HIT_BULLET_SCENE_PATH)
	if _sword_hit_bullet_scene != null:
		Global._warm_scene_instance(_sword_hit_bullet_scene)


func _run_sword_projectile() -> void:
	var config: Dictionary = SWORD_CONFIG[sword_id]
	var parent := _get_effect_parent()
	if parent == null:
		return
	var player_dir := _get_player_direction()
	var target := _get_highest_hp_monster()
	var dir_x := -1.0 if player_dir else 1.0
	var start_pos := global_position + Vector2(dir_x * 30.0, 8.0)
	var end_pos := start_pos + Vector2(dir_x * 520.0, 0.0)
	if is_instance_valid(target):
		end_pos = target.global_position + Vector2(0, -45)

	var projectile = _make_effect_sprite(str(config["projectile"]))
	if projectile != null:
		parent.add_child(projectile)
		projectile.global_position = start_pos
		projectile.flip_h = player_dir
		projectile.scale = config.get("effect_scale", Vector2(0.8, 0.8)) as Vector2
		projectile.play()
		var fly_time := clampf(start_pos.distance_to(end_pos) / 1450.0, 0.18, 0.42)
		var tween := get_tree().create_tween()
		tween.tween_property(projectile, "global_position", end_pos, fly_time)
		await tween.finished
		if is_instance_valid(projectile):
			_free_effect_sprite(projectile)

	_spawn_impact_effect(end_pos)
	await _damage_sword_targets(end_pos)


func _spawn_impact_effect(at_position: Vector2) -> void:
	var config: Dictionary = SWORD_CONFIG[sword_id]
	var parent := _get_effect_parent()
	if parent == null:
		return
	var impact = _make_effect_sprite(str(config["impact"]))
	if impact == null:
		return
	parent.add_child(impact)
	impact.global_position = at_position
	impact.scale = config.get("effect_scale", Vector2(0.8, 0.8)) as Vector2
	impact.play()
	impact.animation_finished.connect(_free_effect_sprite.bind(impact))


func _make_effect_sprite(folder: String) -> AnimatedSprite2D:
	var standard_frames := _get_standard_sword_frames()
	if standard_frames == null or not standard_frames.has_animation(folder):
		push_error("诛仙剑阵标准帧缺少动画: %s" % folder)
		return null
	var animated := AnimatedSprite2D.new()
	animated.sprite_frames = standard_frames
	animated.animation = StringName(folder)
	animated.z_as_relative = false
	animated.z_index = 80
	animated.play(StringName(folder))
	return animated


func _free_effect_sprite(effect: Node) -> void:
	if effect == null or not is_instance_valid(effect):
		return
	if effect is AnimatedSprite2D:
		var animated_sprite := effect as AnimatedSprite2D
		animated_sprite.sprite_frames = null
	elif effect is Sprite2D:
		var sprite_node := effect as Sprite2D
		sprite_node.texture = null
	effect.queue_free()


func _get_effect_parent() -> Node:
	if is_inside_tree():
		var tree: SceneTree = get_tree()
		if tree.current_scene != null:
			return tree.current_scene
		return get_parent()
	return null


func _run_zhuxian_skill() -> void:
	var config: Dictionary = SWORD_CONFIG[sword_id]
	var parent := _get_effect_parent()
	if parent == null:
		return
	var target := _get_highest_hp_monster()
	var effect_pos := _get_zhuxian_effect_position(target)
	var effect = _make_effect_sprite(str(config["effect"]))
	if effect != null:
		parent.add_child(effect)
		effect.global_position = effect_pos
		effect.flip_h = _get_player_direction()
		effect.scale = config.get("effect_scale", Vector2.ONE) as Vector2
		effect.play()
		effect.animation_finished.connect(_free_effect_sprite.bind(effect))

	var previous_delay := 0.0
	for hit_delay in ZHUXIAN_HIT_DELAYS:
		if not await _wait_for_sword_seconds(float(hit_delay) - previous_delay):
			return
		previous_delay = float(hit_delay)
		if not is_inside_tree() or is_queued_for_deletion():
			return
		_spawn_impact_effect(effect_pos)
		await _damage_sword_targets(effect_pos)


func _run_xianxian_skill() -> void:
	var config: Dictionary = SWORD_CONFIG[sword_id]
	var parent := _get_effect_parent()
	if parent == null:
		return
	var target := _get_highest_hp_monster()
	var damage_pos := _get_zhuxian_effect_position(target)
	var effect_pos := damage_pos + (config.get("effect_offset", Vector2.ZERO) as Vector2)
	var player_dir := _get_player_direction()

	var effect = _make_effect_sprite(str(config["effect"]))
	if effect != null:
		parent.add_child(effect)
		effect.global_position = effect_pos
		effect.flip_h = player_dir
		effect.scale = config.get("effect_scale", Vector2.ONE) as Vector2
		effect.play()
		effect.animation_finished.connect(_free_effect_sprite.bind(effect))

	if not await _wait_for_sword_seconds(XIANXIAN_HIT_DELAY):
		return
	await _damage_sword_targets(damage_pos)


func _run_sijian_skill() -> void:
	var config: Dictionary = SWORD_CONFIG[sword_id]
	var parent := _get_effect_parent()
	if parent == null:
		return
	var target := _get_highest_hp_monster()
	var damage_pos := _get_zhuxian_effect_position(target)
	var effect_pos := damage_pos + (config.get("effect_offset", Vector2.ZERO) as Vector2)

	var field = _make_effect_sprite(str(config["effect"]))
	if field != null:
		parent.add_child(field)
		field.global_position = effect_pos
		field.scale = config.get("effect_scale", Vector2.ONE) as Vector2
		field.play()
		field.animation_finished.connect(_free_effect_sprite.bind(field))

	if not await _wait_for_sword_seconds(SIJIAN_FIELD_START_DELAY):
		return

	var elapsed := 0.0
	while elapsed <= SIJIAN_FIELD_DURATION + 0.01:
		if not is_inside_tree() or is_queued_for_deletion():
			return
		await _damage_sword_targets(damage_pos, [0, 0], true, SIJIAN_STUN_TIME, null, SIJIAN_HIT_RADIUS)
		if not await _wait_for_sword_seconds(SIJIAN_HIT_INTERVAL):
			return
		elapsed += SIJIAN_HIT_INTERVAL


func _run_luxian_skill() -> void:
	var config: Dictionary = SWORD_CONFIG[sword_id]
	var parent := _get_effect_parent()
	if parent == null:
		return
	var player_dir := _get_player_direction()
	var dir_x := 1.0 if player_dir else -1.0
	var knockback_dir := not player_dir
	var start_pos := global_position + Vector2(dir_x * 20.0, 0.0)
	var end_pos := start_pos + Vector2(dir_x * LUXIAN_ADVANCE_DISTANCE, 0)

	var effect = _make_effect_sprite(str(config["effect"]))
	if effect != null:
		parent.add_child(effect)
		effect.global_position = start_pos
		effect.flip_h = knockback_dir
		effect.scale = config.get("effect_scale", Vector2.ONE) as Vector2
		effect.play()
		effect.animation_finished.connect(_free_effect_sprite.bind(effect))

	if not await _wait_for_sword_seconds(LUXIAN_ROTATE_START_DELAY):
		return

	if is_instance_valid(effect):
		var tween := get_tree().create_tween()
		tween.tween_property(effect, "global_position", end_pos, LUXIAN_ROTATE_DURATION)

	var elapsed := 0.0
	while elapsed <= LUXIAN_ROTATE_DURATION + 0.01:
		if not is_inside_tree() or is_queued_for_deletion():
			return
		var hit_pos := start_pos.lerp(end_pos, clampf(elapsed / LUXIAN_ROTATE_DURATION, 0.0, 1.0))
		await _damage_sword_targets(hit_pos, LUXIAN_HURT_BACK, true, LUXIAN_STUN_TIME, knockback_dir)
		if not await _wait_for_sword_seconds(LUXIAN_HIT_INTERVAL):
			return
		elapsed += LUXIAN_HIT_INTERVAL


func _run_juexian_skill() -> void:
	var config: Dictionary = SWORD_CONFIG[sword_id]
	var parent := _get_effect_parent()
	if parent == null:
		return
	var target := _get_highest_hp_monster()
	var damage_pos := _get_zhuxian_effect_position(target)
	var effect_pos := damage_pos + (config.get("effect_offset", Vector2.ZERO) as Vector2)

	var effect = _make_effect_sprite(str(config["effect"]))
	if effect != null:
		parent.add_child(effect)
		effect.global_position = effect_pos
		effect.scale = config.get("effect_scale", Vector2.ONE) as Vector2
		effect.play()
		effect.animation_finished.connect(_free_effect_sprite.bind(effect))

	if not await _wait_for_sword_seconds(JUEXIAN_FIELD_START_DELAY):
		return

	var elapsed := 0.0
	while elapsed <= JUEXIAN_FIELD_DURATION + 0.01:
		if not is_inside_tree() or is_queued_for_deletion():
			return
		await _damage_sword_targets(damage_pos, [0, 0])
		if not await _wait_for_sword_seconds(JUEXIAN_HIT_INTERVAL):
			return
		elapsed += JUEXIAN_HIT_INTERVAL


func _get_zhuxian_effect_position(target: BaseMonster) -> Vector2:
	if is_instance_valid(target):
		return target.global_position + Vector2(0, -45)
	var dir_x := -1.0 if _get_player_direction() else 1.0
	return player.global_position + Vector2(dir_x * 300.0, -80.0)


func _get_player_direction() -> bool:
	return bool(_runtime_role_props().directon)


func _get_follow_origin() -> Vector2:
	var props: Node = _runtime_role_props()
	if props.role_pos_x is int or props.role_pos_x is float:
		if props.role_pos_y is int or props.role_pos_y is float:
			return Vector2(float(props.role_pos_x), float(props.role_pos_y))
	if is_instance_valid(player):
		return player.position
	return position


func _get_follow_position() -> Vector2:
	var origin := _get_follow_origin()
	if _get_player_direction():
		return origin - Vector2(FOLLOW_X, -FOLLOW_Y)
	return origin - Vector2(-FOLLOW_X, -FOLLOW_Y)


func _damage_sword_targets(
	center: Vector2,
	hurt_back: Array = [4, -2],
	add_short_stun: bool = false,
	stun_time: float = 0.0,
	direction = null,
	hit_radius: float = IMPACT_RADIUS
) -> void:
	if player == null or not is_instance_valid(player):
		return
	var hit_dic := {
		"power": int(int(_runtime_role_props().roleprop.get("power", 0)) * _get_power_rate()),
		"hurtBack": hurt_back,
		"attackKind": "magic",
		"WSValue": 4,
		"defe_reduce": SWORD_ARRAY_DEFE_REDUCE_VALUE,
	}
	if add_short_stun:
		hit_dic["addeffect"] = {
			"Name": "stun",
			"AddTime": stun_time,
			"reduce_interval": 0,
			"value": 0,
			"AttackKind": "magic",
			"CanAdd": false,
			"DeBuff": true,
		}
		hit_dic["stun_chance"] = 100
	var hit_bullet := _spawn_sword_hit_bullet(
		center, hit_radius, hit_dic, _get_player_direction() if direction == null else bool(direction)
	)
	if hit_bullet == null:
		return
	if not await _wait_for_sword_physics_frame():
		if is_instance_valid(hit_bullet):
			hit_bullet.queue_free()
		return
	if not await _wait_for_sword_physics_frame():
		if is_instance_valid(hit_bullet):
			hit_bullet.queue_free()
		return
	if hit_bullet != null and is_instance_valid(hit_bullet):
		hit_bullet.queue_free()


func _wait_for_sword_seconds(seconds: float) -> bool:
	if not is_inside_tree() or is_queued_for_deletion():
		return false
	var tree: SceneTree = get_tree()
	if tree == null:
		return false
	await tree.create_timer(maxf(seconds, 0.0), false).timeout
	return is_inside_tree() and not is_queued_for_deletion()


func _wait_for_sword_physics_frame() -> bool:
	if not is_inside_tree() or is_queued_for_deletion():
		return false
	var tree: SceneTree = get_tree()
	if tree == null:
		return false
	await tree.physics_frame
	return is_inside_tree() and not is_queued_for_deletion()


func _spawn_sword_hit_bullet(center: Vector2, hit_radius: float, hit_dic: Dictionary, direction: bool) -> RoleBullet:
	var parent := _get_effect_parent()
	if parent == null:
		return null
	if _sword_hit_bullet_scene == null:
		_prewarm_sword_hit_bullet_scene()
	if _sword_hit_bullet_scene == null:
		return null
	var bullet := _sword_hit_bullet_scene.instantiate() as RoleBullet
	if bullet == null:
		return null
	parent.add_child(bullet)
	bullet.global_position = center
	bullet._name = "SwordArrayHit"
	bullet.hit_dic = hit_dic
	bullet.direction = direction
	bullet.set_meta("sword_array_damage", true)
	bullet.visible = false
	bullet.is_set = true
	bullet.set_physics_process(false)
	var hit_box := bullet.get_node_or_null("Middle/HitBox") as Area2D
	var shape := bullet.get_node_or_null("Middle/HitBox/Collion") as CollisionShape2D
	if hit_box != null:
		hit_box.collision_layer = 2
		hit_box.collision_mask = SWORD_ARRAY_HIT_COLLISION_MASK
		hit_box.monitoring = true
		hit_box.monitorable = true
	if shape != null:
		var circle := CircleShape2D.new()
		circle.radius = hit_radius
		shape.shape = circle
		shape.position = Vector2.ZERO
		shape.disabled = false
	return bullet


func _collect_sword_hit_area_monsters(hit_area: Area2D) -> Dictionary:
	var hit_monsters := {}
	for area in hit_area.get_overlapping_areas():
		var monster := _monster_from_hurt_area(area)
		if monster == null or hit_monsters.has(monster):
			continue
		hit_monsters[monster] = true
	for body in hit_area.get_overlapping_bodies():
		if body is BaseMonster and not hit_monsters.has(body):
			hit_monsters[body] = true
	return hit_monsters


func _collect_sword_distance_monsters(center: Vector2, hit_radius: float) -> Dictionary:
	var hit_monsters := {}
	var monster_parent := _get_monster_parent()
	if monster_parent == null:
		return hit_monsters
	for monster in monster_parent.get_children():
		if not is_instance_valid(monster) or not (monster is BaseMonster):
			continue
		if monster.global_position.distance_to(center) <= hit_radius:
			hit_monsters[monster] = true
	return hit_monsters


func _create_sword_hit_area(center: Vector2, hit_radius: float) -> Area2D:
	var parent := _get_effect_parent()
	if parent == null:
		return null
	var area := Area2D.new()
	area.name = "SwordArrayHitArea"
	area.collision_layer = 2
	area.collision_mask = 3140
	area.monitoring = true
	area.monitorable = true
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = hit_radius
	shape.shape = circle
	area.add_child(shape)
	parent.add_child(area)
	area.global_position = center
	return area


func _monster_from_hurt_area(area: Area2D) -> BaseMonster:
	if area == null or not is_instance_valid(area):
		return null
	var node: Node = area
	for i in range(4):
		if node == null:
			return null
		if node is BaseMonster:
			return node as BaseMonster
		node = node.get_parent()
	return null


func _get_sword_level() -> int:
	var data: Node = LocalCoop.data_for(self)
	if data.has_method("get_main_sword_array_level"):
		return int(data.get_main_sword_array_level(sword_id))
	return 0


func _get_power_rate() -> float:
	var config: Dictionary = SWORD_CONFIG.get(sword_id, {})
	return (
		float(config.get("power_rate_base", 0.0))
		+ float(config.get("power_rate_per_level", 0.0)) * float(_get_sword_level())
	)


func _get_highest_hp_monster() -> BaseMonster:
	var monster_parent := _get_monster_parent()
	if monster_parent == null:
		return null
	var best: BaseMonster = null
	var best_hp := -1
	for monster in monster_parent.get_children():
		if not is_instance_valid(monster) or not (monster is BaseMonster):
			continue
		if monster.get("no_target") != null and monster.no_target:
			continue
		if int(monster.hp) <= 0:
			continue
		if int(monster.hp) > best_hp:
			best = monster
			best_hp = int(monster.hp)
	return best


func _get_monster_parent() -> Node:
	if player == null or not is_instance_valid(player):
		return null
	var player_parent := player.get_parent()
	if player_parent == null or player_parent.get_parent() == null:
		return null
	return player_parent.get_parent().get("monster") as Node


func _add_defe_reduce(monster: BaseMonster) -> void:
	if monster == null or not is_instance_valid(monster) or monster.buff == null:
		return
	(
		Global
		. add_buff(
			monster.buff,
			{
				"Name": "defe_reduce",
				"AddTime": 8,
				"reduce_interval": 0,
				"value": SWORD_ARRAY_DEFE_REDUCE_VALUE,
				"AttackKind": "",
				"DeBuff": true,
			}
		)
	)


func _add_short_stun(monster: BaseMonster, stun_time: float) -> void:
	if stun_time <= 0.0 or monster == null or not is_instance_valid(monster) or monster.buff == null:
		return
	(
		Global
		. add_buff(
			monster.buff,
			{
				"Name": "stun",
				"AddTime": stun_time,
				"reduce_interval": 0,
				"value": 0,
				"AttackKind": "",
				"CanAdd": false,
				"DeBuff": true,
			}
		)
	)


func _apply_sword_hit_feedback(monster: BaseMonster, value: int, source: RoleBullet) -> void:
	if value <= 0 or monster == null or not is_instance_valid(monster):
		return
	if MainSet.set_data["MonsterLittleBlood"]:
		if monster.monster_blood_bar == null:
			monster.monster_blood_bar = Global.add_monster_blood(
				monster, Vector2(-30, -90), monster.hp / float(monster.max_hp), monster.hp
			)
	monster.role5_bullet(value, source)
	Global.get_audio_runtime().add_sound(monster, "res://Music/monster_hurt/6_beattack_by_role1.mp3")
	if (
		not monster.is_miss
		and not monster.is_boss_protecting()
		and (not bool(source.get_meta("sword_array_damage", false)) or Global.can_show_sword_hit_effect())
	):
		monster.hurt_special_effect = Global.add_mr_hurt(monster.pz, Vector2(0, 0))


func _play_sword_hurt_animation(monster: BaseMonster) -> void:
	if monster == null or not is_instance_valid(monster):
		return
	if monster.monster_18_protect() or monster.monster102_protect() or monster.is_control_immune():
		return
	monster.set_meta("sword_array_hit_token", Time.get_ticks_msec())
	monster.is_be_attacking = true
	monster.interrupt_movement_for_control()
	if monster.mr_player != null and monster.mr_player.has_animation("hurt"):
		monster.mr_player.play("hurt")
	call_deferred("_release_sword_hurt_animation", monster, int(monster.get_meta("sword_array_hit_token")))


func _release_sword_hurt_animation(monster: BaseMonster, token: int) -> void:
	if not await _wait_for_sword_seconds(0.2):
		return
	if monster == null or not is_instance_valid(monster):
		return
	if int(monster.get_meta("sword_array_hit_token", 0)) != token:
		return
	monster.is_be_attacking = false


func _apply_role_attack_control(monster: BaseMonster, source: RoleBullet) -> void:
	if monster == null or not is_instance_valid(monster) or player == null or not is_instance_valid(player):
		return
	if monster.is_control_immune():
		return
	var old_target = monster.get_target
	monster.get_target = source
	monster.state_hurt()
	monster.get_target = old_target


func _runtime_role_props() -> Node:
	return LocalCoop.props_for(self)
