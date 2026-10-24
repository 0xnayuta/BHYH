extends SummonBaseMonster
class_name GuanyinSummon

var inherited_role_properties: Dictionary = {}
var role_property_snapshot: Dictionary = {}
var inherited_base_properties: Dictionary = {}
var inherited_equipment_properties: Dictionary = {}
var inherited_passive_properties: Dictionary = {}
var inherited_weapon_properties: Dictionary = {}
var inherited_armor_properties: Dictionary = {}
var inherited_accessory_properties: Dictionary = {}
var inherited_robe_properties: Dictionary = {}
var inherited_avatar_properties: Dictionary = {}
var inherited_legend_properties: Dictionary = {}
var inherited_magic_weapon_properties: Dictionary = {}
var inherited_weapon_bonus_properties: Dictionary = {}
var inherited_armor_bonus_properties: Dictionary = {}
var inherited_accessory_bonus_properties: Dictionary = {}
var inherited_legend_bonus_properties: Dictionary = {}
var inherited_robe_bonus_properties: Dictionary = {}
var inherited_avatar_bonus_properties: Dictionary = {}
var max_mp: int = 0
var mp: int = 0
var r_mp: float = 0.0
var vampirism: float = 0.0

const SPINE_ATLAS_PATH := "res://Art/monster/guanyin_spine/skeleton.atlas"
const SPINE_SKELETON_PATH := "res://Art/monster/guanyin_spine/guanyin.spine-json"
const SKILL_2_EFFECT_SCENE := preload("res://Scene/monster/monster_zhw/guanyin_skill2_effect.tscn")
const SKILL_A_EFFECT_SCENE := preload("res://Scene/monster/monster_zhw/guanyin_skill_a_effect.tscn")

static var _shared_spine_data: Variant = null
static var _spine_load_failed: bool = false

@onready var summon_sprite: Variant = $MonsterDir/SpineVisual
var _current_animation: StringName = &""
var _action_serial: int = 0
var skill_a_cast_range: float = 315.0
var skill_b_cast_range: float = 315.0
const SKILL_A_FIXED_Y := 550.0
const GUANYIN_MOVE_SPEED := 32.0
const GUANYIN_FOLLOW_START_DISTANCE := 300.0
const GUANYIN_FOLLOW_STOP_DISTANCE := 120.0
var _is_following_player: bool = false


func _ready() -> void:
	_setup_spine_visual()
	add_to_group("friendly_summons")
	set_meta("magic_weapon_summon", true)
	set_meta("guanyin_summon", true)
	_play_spine(&"idle", true)


static func preload_spine_data() -> bool:
	return _get_shared_spine_data() != null


static func clear_cached_data() -> void:
	_shared_spine_data = null
	_spine_load_failed = false


static func _get_shared_spine_data() -> Variant:
	if _shared_spine_data != null:
		return _shared_spine_data
	if _spine_load_failed:
		return null
	if not ClassDB.class_exists("SpineSkeletonDataResource"):
		_spine_load_failed = true
		push_error("GuanyinSummon: Spine GDExtension is not loaded")
		return null
	var atlas := load(SPINE_ATLAS_PATH)
	if atlas == null:
		_spine_load_failed = true
		push_error("GuanyinSummon: 无法加载 Spine atlas: " + SPINE_ATLAS_PATH)
		return null
	var skeleton_file := load(SPINE_SKELETON_PATH)
	if skeleton_file == null:
		_spine_load_failed = true
		push_error("GuanyinSummon: 无法加载 Spine skeleton: " + SPINE_SKELETON_PATH)
		return null
	var skeleton_data: Variant = ClassDB.instantiate("SpineSkeletonDataResource")
	skeleton_data.set_atlas_res(atlas)
	skeleton_data.set_skeleton_file_res(skeleton_file)
	skeleton_data.update_skeleton_data()
	if not skeleton_data.is_skeleton_data_loaded():
		_spine_load_failed = true
		push_error("GuanyinSummon: Spine 骨骼数据解析失败")
		return null
	_shared_spine_data = skeleton_data
	return _shared_spine_data


func _setup_spine_visual() -> void:
	var skeleton_data: Variant = _get_shared_spine_data()
	if skeleton_data == null or summon_sprite == null or not summon_sprite.has_method("set_skeleton_data_res"):
		summon_sprite.visible = false
		return
	summon_sprite.set_skeleton_data_res(skeleton_data)
	summon_sprite.visible = true


func _play_spine(animation_name: StringName, loop: bool = true) -> Variant:
	if (
		summon_sprite == null
		or not summon_sprite.has_method("get_skeleton_data_res")
		or summon_sprite.get_skeleton_data_res() == null
	):
		return null
	if not summon_sprite.has_method("get_animation_state"):
		return null
	var animation_state: Variant = summon_sprite.get_animation_state()
	if animation_state == null:
		return null
	if loop and _current_animation == animation_name:
		return animation_state.get_track(0)
	_current_animation = animation_name
	return animation_state.set_animation(String(animation_name), loop, 0)


func _wait_for_track(track: Variant) -> void:
	if track == null:
		return
	var animation_duration := maxf(track.get_animation_end() - track.get_animation_start(), 0.1)
	var deadline_msec := Time.get_ticks_msec() + int((animation_duration + 0.5) * 1000.0)
	while is_instance_valid(self) and not track.is_complete():
		if Time.get_ticks_msec() >= deadline_msec:
			break
		await get_tree().process_frame


func apply_role_property_snapshot(snapshot: Dictionary) -> void:
	role_property_snapshot = snapshot.duplicate(true)
	inherited_role_properties = _copy_dictionary(snapshot.get("roleprop", {}))
	inherited_base_properties = _copy_dictionary(snapshot.get("baseroleprop", {}))
	inherited_equipment_properties = _copy_dictionary(snapshot.get("equprop", {}))
	inherited_passive_properties = _copy_dictionary(snapshot.get("pasl_prop", {}))
	inherited_weapon_properties = _copy_dictionary(snapshot.get("wq_prop", {}))
	inherited_armor_properties = _copy_dictionary(snapshot.get("fj_prop", {}))
	inherited_accessory_properties = _copy_dictionary(snapshot.get("sp_prop", {}))
	inherited_robe_properties = _copy_dictionary(snapshot.get("sz_prop", {}))
	inherited_avatar_properties = _copy_dictionary(snapshot.get("tx_prop", {}))
	inherited_legend_properties = _copy_dictionary(snapshot.get("cb_prop", {}))
	inherited_magic_weapon_properties = _copy_dictionary(snapshot.get("fb_prop", {}))
	inherited_weapon_bonus_properties = _copy_dictionary(snapshot.get("wq_bs_prop", snapshot.get("WqBs_prop", {})))
	inherited_armor_bonus_properties = _copy_dictionary(snapshot.get("fj_bs_prop", snapshot.get("FjBs_prop", {})))
	inherited_accessory_bonus_properties = _copy_dictionary(snapshot.get("sp_bs_prop", snapshot.get("SpBs_prop", {})))
	inherited_legend_bonus_properties = _copy_dictionary(snapshot.get("cb_bs_prop", snapshot.get("CbBs_prop", {})))
	inherited_robe_bonus_properties = _copy_dictionary(snapshot.get("SzBs_prop", {}))
	inherited_avatar_bonus_properties = _copy_dictionary(snapshot.get("TxBs_prop", {}))
	_apply_combat_properties()


func _copy_dictionary(value: Variant) -> Dictionary:
	return value.duplicate(true) if value is Dictionary else {}


func _number(key: String, fallback: float = 0.0) -> float:
	return float(inherited_role_properties.get(key, fallback))


func _apply_combat_properties() -> void:
	if inherited_role_properties.is_empty():
		return
	max_hp = maxi(1, int(_number("SHp", 1.0)))
	hp = clampi(int(_number("Hp", max_hp)), 1, max_hp)
	max_mp = maxi(0, int(_number("SMp")))
	mp = clampi(int(_number("Mp", max_mp)), 0, max_mp)
	r_mp = _number("R_mp")
	vampirism = _number("vampirism")
	level = maxi(1, int(inherited_base_properties.get("Level", 1)))
	def = int(_number("Def"))
	mdef = int(_number("Mdef"))
	crit = int(_number("Crit"))
	miss = int(_number("Miss"))
	lucky = int(_number("Lucky"))
	htarget = int(_number("htarget"))
	toughness = int(_number("toughness"))
	crit_reduce = int(_number("CritReduce"))
	ar = int(_number("ar"))
	sp = int(_number("sp"))
	self_rhp = int(_number("R_hp"))
	my_mr_name = "观音"
	attack_in = 100
	attack_range = 105

	skill_a_cast_range = attack_range * 3.0
	skill_b_cast_range = attack_range * 3.0
	mysee = 99999
	init_speed = int(GUANYIN_MOVE_SPEED)
	speed = init_speed
	attack_desire = 100
	return_to_player_distance = 900
	var inherited_power := maxi(1, int(_number("power", 1.0)))
	obj_attack_dict = {
		"hit1": {"power": inherited_power, "hurtBack": [8, -2], "attackKind": "magic"},
		"skill_a": {"power": inherited_power * 12, "hurtBack": [5, -1], "attackKind": "magic"},
		"skill_b": {"power": inherited_power, "hurtBack": [10, -4], "attackKind": "magic"}
	}


func process_idle(_delta: float) -> void:
	pass


func ai_think() -> void:
	if not is_instance_valid(current_target) or current_target.hp <= 0:
		current_target = null
		has_target = false
		_follow_player_when_idle()
		return
	has_target = true
	var offset := current_target.global_position - global_position
	var horizontal_distance := absf(offset.x)

	if horizontal_distance > maxf(skill_a_cast_range, skill_b_cast_range):
		if offset.x > 0.0:
			move_right()
		else:
			move_left()
		return
	stop_move()
	try_use_skills()


func _follow_player_when_idle() -> void:
	if not is_instance_valid(player_reference):
		_is_following_player = false
		stop_move()
		return
	var offset_x := player_reference.global_position.x - global_position.x
	var distance_x := absf(offset_x)
	if _is_following_player and distance_x <= GUANYIN_FOLLOW_STOP_DISTANCE:
		_is_following_player = false
	elif not _is_following_player and distance_x > GUANYIN_FOLLOW_START_DISTANCE:
		_is_following_player = true
	if not _is_following_player:
		stop_move()
	elif offset_x > 0.0:
		move_right()
	else:
		move_left()


func _on_hit_box_area_entered(area: Area2D) -> void:
	if hit_name == "skill_a" or hit_name == "skill_b":
		return
	super(area)


func _on_hurt_box_area_entered(area: Area2D) -> void:
	var attacker: Node = null
	if area is BaseRoleHitBox or area is RolehmzBullet:
		attacker = LocalCoop.owner_hero(area)
	elif area.get_parent() is BaseMonster:
		attacker = area.get_parent()
	elif area.get_parent() != null and area.get_parent().get_parent() is BaseMonster:
		attacker = area.get_parent().get_parent()
	elif area.get_parent() is MonsterBullet:
		attacker = area.get_parent()
	elif area.get_parent() != null and area.get_parent().get_parent() is MonsterBullet:
		attacker = area.get_parent().get_parent()
	if not is_instance_valid(attacker):
		return
	var last_hurt := get_attacker_damage(attacker)
	if last_hurt <= 0 or _pet_protect_active():
		return

	reduce_hp(last_hurt, attacker)
	_add_pet_protect(_get_pet_protect_gain(attacker))


func setup_skills() -> void:
	skill_1_cd = 1.0
	skill_2_cd = 1.0
	skill_3_cd = 8.0


func try_use_skills() -> void:
	if not is_instance_valid(current_target) or is_attacking:
		return
	var offset := current_target.global_position - global_position

	if skill_3_cd <= 0.0 and absf(offset.x) <= skill_b_cast_range:
		_attack_with_animation("skill_b", 8.0)
	elif skill_2_cd <= 0.0 and absf(offset.x) <= skill_a_cast_range:
		_attack_with_animation("skill_a", 1.0)


func _animation_for_attack(attack_name: String) -> StringName:
	match attack_name:
		"skill_a":
			return &"skill_a_body"
		"skill_b":
			return &"skill_b"
	return &"idle"


func _attack_with_animation(attack_name: String, cooldown: float) -> void:
	if not is_instance_valid(current_target):
		return
	_action_serial += 1
	var action_serial := _action_serial
	if current_target.global_position.x > global_position.x:
		base_damage_box.scale.x = -1.0
		monster_dir.scale.x = -1.0
	else:
		base_damage_box.scale.x = 1.0
		monster_dir.scale.x = 1.0
	velocity.x = 0.0
	hit_name = attack_name
	is_attacking = true
	match attack_name:
		"hit1":
			skill_1_cd = cooldown
		"skill_a":
			skill_2_cd = 1.0
		"skill_b":
			skill_3_cd = cooldown
	var hit_shape := $BaseDamageBox/HitBox/HitBox as CollisionShape2D
	var attack_track: Variant = _play_spine(_animation_for_attack(attack_name), false)
	if attack_name == "skill_a":
		hit_shape.set_deferred("disabled", true)
		_spawn_skill_a_sequence(action_serial)
	elif attack_name == "skill_b":
		hit_shape.set_deferred("disabled", true)
		_spawn_skill_2_sequence(action_serial)
	else:
		hit_shape.set_deferred("disabled", false)
		await get_tree().create_timer(0.2).timeout
		hit_shape.set_deferred("disabled", true)
	if action_serial != _action_serial or is_death:
		return
	await _wait_for_track(attack_track)
	if action_serial != _action_serial or is_death:
		return
	is_attacking = false
	hit_name = ""
	velocity.x = 0.0
	_play_spine(&"idle", true)


func _spawn_skill_a_sequence(action_serial: int) -> void:
	for cast_index in range(3):
		if not is_instance_valid(self) or is_death:
			return
		_spawn_skill_a_effect()
		if cast_index < 2:
			await get_tree().create_timer(0.25).timeout
			if action_serial != _action_serial or is_death:
				return


func _spawn_skill_a_effect() -> void:
	var effect := SKILL_A_EFFECT_SCENE.instantiate() as GuanyinSkillAEffect
	if effect == null:
		return
	var parent := get_parent()
	if parent == null:
		parent = get_tree().current_scene
	var attack_power := int(obj_attack_dict.get("hit1", {}).get("power", 1))
	var face_right := monster_dir.scale.x < 0.0
	effect.setup(self, attack_power, face_right)
	parent.add_child(effect)

	var target_x := current_target.global_position.x if is_instance_valid(current_target) else global_position.x
	effect.global_position = Vector2(target_x, SKILL_A_FIXED_Y)


func _spawn_skill_2_sequence(action_serial: int) -> void:
	for cast_index in range(3):
		if not is_instance_valid(self) or is_death:
			return
		_spawn_skill_2_effect()
		if cast_index < 2:
			await get_tree().create_timer(0.8).timeout
			if action_serial != _action_serial or is_death:
				return


func _spawn_skill_2_effect() -> void:
	var effect := SKILL_2_EFFECT_SCENE.instantiate() as GuanyinSkill2Effect
	if effect == null:
		return
	var parent := get_parent()
	if parent == null:
		parent = get_tree().current_scene
	var attack_power := int(obj_attack_dict.get("hit1", {}).get("power", 1))
	var face_right := monster_dir.scale.x < 0.0
	effect.setup(self, attack_power, face_right)
	parent.add_child(effect)
	effect.global_position = global_position


func update_animation_and_direction() -> void:
	if is_attacking or is_be_attacking or is_death:
		return
	if velocity.x != 0.0:
		_play_spine(&"move", true)
	else:
		_play_spine(&"idle", true)
	if velocity.x > 0.0:
		base_damage_box.scale.x = -1.0
		monster_dir.scale.x = -1.0
	elif velocity.x < 0.0:
		base_damage_box.scale.x = 1.0
		monster_dir.scale.x = 1.0


func stop_move() -> void:
	velocity.x = 0.0
	if not is_attacking and not is_be_attacking and not is_death:
		_play_spine(&"idle", true)


func process_death(_delta: float) -> void:
	if is_death or hp > 0:
		return
	is_death = true
	velocity = Vector2.ZERO
	$BaseDamageBox/HitBox/HitBox.set_deferred("disabled", true)
	$BaseDamageBox/HurtBox/HurtBox.set_deferred("disabled", true)
	var die_track: Variant = _play_spine(&"die", false)
	await _wait_for_track(die_track)
	queue_free()
