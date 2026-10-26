extends BaseMonster
class_name FireAncestorOrb

const ROOT := "res://Art/monster/swf_png/3056"
const SOURCE_FPS := 30.0
const SOURCE_LIFETIME := 72.0
const DAMAGE_INTERVAL := 0.5
const SOURCE_FRAME_HOLD := 4
const FRAME_PADDING := 1
const SWF_MATTE_ALPHA_MAX := 2.5 / 255.0
const SWF_MATTE_RGB_MAX := 0.5 / 255.0
const ACTIONS := {
	&"wait": ["idle", 1, true],
	&"walk": ["walk", 32, true],
	&"hurt": ["idle", 1, true],
	&"death": ["dead", 1, false],
	&"hit1": ["attack1", 32, true],
}

static var _frames_cache: SpriteFrames
static var _premultiplied_material: CanvasItemMaterial

@export var monster_kind := 3056

var _runtime_config: Dictionary = {}
var _elapsed := 0.0
var _damage_elapsed := 0.0
var _damage_enabled := false
var _reenable_damage_next_frame := false
var _death_started := false


func _ready() -> void:
	_runtime_config = _resolve_runtime_config()
	_configure_monster()
	_build_animations()
	super._ready()
	hit_name = "hit1"
	is_attacking = true
	mr_player.play(&"hit1")
	_set_damage_enabled(true)


func _resolve_runtime_config() -> Dictionary:
	var level_node := get_level_node()
	if level_node != null and level_node.has_method("get_level_monster_config"):
		var config: Variant = level_node.call("get_level_monster_config", monster_kind)
		if config is Dictionary and not config.is_empty():
			return (config as Dictionary).duplicate(true)
	push_error("FireAncestorOrb requires level monster config entry 3056")
	return {}


func _configure_monster() -> void:
	var config := _runtime_config
	my_mr_name = str(config.get("name", "Fire Ancestor Orb"))
	level = int(config.get("level", 1))
	attack_in = int(config.get("attack", 1))
	max_hp = int(config.get("hp", 1))
	hp = max_hp
	def = int(config.get("def", 0))
	mdef = int(config.get("mdef", 0))
	crit = int(config.get("crit", 0))
	miss = int(config.get("miss", 0))
	htarget = int(config.get("hit", 0))
	toughness = float(config.get("toughness", 0.0))
	crit_reduce = int(config.get("crit_reduce", 0))
	ar = int(config.get("armor_break", 0))
	sp = int(config.get("magic_break", 0))
	speed = float(config.get("speed", 25.0))
	mysee = int(config.get("sight", 1200))
	attack_range = roundi(float(config.get("range", 98.0)))
	attack_desire = int(config.get("attack_desire", 100))
	add_exp = int(config.get("exp", 0))
	fall_coin = int(config.get("coin", 0))
	fall_pro = float(config.get("drop_rate", 0.0))
	fall_list = Array(config.get("drop_list", [])).duplicate(true)
	independent_fall_list = Array(config.get("independent_drop_list", [])).duplicate(true)
	is_boss = false
	super_armor_active = true
	cannot_attract = true
	no_grav = false
	is_fly = false
	obj_attack_dict.clear()
	var attacks: Dictionary = config.get("attacks", {})
	var attack: Dictionary = attacks.get("hit1", {})
	obj_attack_dict["hit1"] = {
		"power": roundi(float(attack_in) * float(attack.get("multiplier", 0.5))),
		"hurtBack": Array(attack.get("hurt_back", [0.0, 0.0])).duplicate(),
		"attackKind": str(attack.get("kind", "physics")),
		"HitProtect": int(attack.get("protect", 0)),
	}


func monster_info_base_attack() -> int:
	return int(_runtime_config.get("attack", attack_in))


func monster_info_attack_values_include_difficulty() -> bool:
	return false


func is_control_immune() -> bool:
	return true


static func prewarm_frames() -> void:
	_get_frames()
	var tree := Engine.get_main_loop() as SceneTree
	if tree != null:
		await tree.process_frame


func _build_animations() -> void:
	mr_ani.sprite_frames = _get_frames()
	if ResourceLoader.exists(ROOT.path_join("atlas/swf_png_3056_frames.tres")):
		mr_ani.material = null
	else:
		mr_ani.material = _get_premultiplied_material()
	mr_ani.centered = true
	mr_ani.position = Vector2(0.0, -86.0)
	mr_ani.flip_h = false
	if mr_player.has_animation_library(&""):
		mr_player.remove_animation_library(&"")
	var library := AnimationLibrary.new()
	for action_name: StringName in ACTIONS:
		var action_data: Array = ACTIONS[action_name]
		var animation := Animation.new()
		animation.length = maxf(float(action_data[1]) / SOURCE_FPS, 0.05)
		animation.loop_mode = Animation.LOOP_LINEAR if bool(action_data[2]) else Animation.LOOP_NONE
		_add_method_key(animation, 0.0, &"_play_frames", [action_name])
		if action_name == &"death":
			_add_method_key(animation, animation.length - 0.001, &"settle_death_drops_and_free")
		library.add_animation(action_name, animation)
	mr_player.add_animation_library(&"", library)


static func _load_standard_frames() -> SpriteFrames:
	var frames_path := ROOT.path_join("atlas/swf_png_3056_frames.tres")
	if not ResourceLoader.exists(frames_path):
		return null
	return load(frames_path) as SpriteFrames


static func _get_frames() -> SpriteFrames:
	if _frames_cache != null:
		return _frames_cache
	var standard := _load_standard_frames()
	if standard != null:
		_frames_cache = standard
		return standard
	return null


static func _remove_swf_matte(image: Image) -> void:
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pixel := image.get_pixel(x, y)
			if (
				pixel.a > 0.0
				and pixel.a <= SWF_MATTE_ALPHA_MAX
				and pixel.r <= SWF_MATTE_RGB_MAX
				and pixel.g <= SWF_MATTE_RGB_MAX
				and pixel.b <= SWF_MATTE_RGB_MAX
			):
				image.set_pixel(x, y, Color.TRANSPARENT)


static func _get_premultiplied_material() -> CanvasItemMaterial:
	if _premultiplied_material == null:
		_premultiplied_material = CanvasItemMaterial.new()
		_premultiplied_material.blend_mode = CanvasItemMaterial.BLEND_MODE_PREMULT_ALPHA
	return _premultiplied_material


func _add_method_key(animation: Animation, time: float, method_name: StringName, args: Array = []) -> void:
	var track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track, NodePath("."))
	animation.track_insert_key(
		track, clampf(time, 0.0, maxf(animation.length - 0.001, 0.0)), {"method": method_name, "args": args}
	)


func _play_frames(action_name: StringName) -> void:
	mr_ani.visible = true
	mr_ani.play(action_name)


func ai_think() -> void:
	pass


func _physics_process(delta: float) -> void:
	var source_target_x := global_position.x
	var source_move_speed := 0.0
	if not death():
		if _reenable_damage_next_frame:
			_reenable_damage_next_frame = false
			_set_damage_enabled(true)
		_elapsed += delta
		_damage_elapsed += delta
		if _damage_elapsed >= DAMAGE_INTERVAL:
			_damage_elapsed -= DAMAGE_INTERVAL
			_set_damage_enabled(false)
			_reenable_damage_next_frame = true
		source_move_speed = -speed * 10.0
		source_target_x += source_move_speed * delta
		velocity.x = 0.0
	super._physics_process(delta)
	if not death():
		global_position.x = source_target_x
		velocity.x = source_move_speed
	super_armor_active = true
	cannot_attract = true
	monster_dir.scale.x = 1.0
	base_damage_box.scale.x = 1.0
	if not death() and _elapsed >= SOURCE_LIFETIME:
		hp = 0


func _set_damage_enabled(enabled: bool) -> void:
	if hit_box == null or (enabled and death()):
		return
	_damage_enabled = enabled
	if not enabled:
		hit_box.set_deferred("disabled", true)
	else:
		hit_box.set_deferred("disabled", false)


func state_hurt() -> void:
	pass


func _interrupt_attack_state_on_hit() -> void:
	pass


func state_death() -> void:
	if _death_started:
		return
	_death_started = true
	_set_damage_enabled(false)
	velocity = Vector2.ZERO
	is_attacking = false
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)
	if pz != null:
		pz.set_deferred("disabled", true)
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	super.state_death()
