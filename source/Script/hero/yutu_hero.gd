extends BaseHero
class_name YutuHero

const EFFECT := preload("res://Scene/hero/role_7/yutu_skill_effect.tscn")
const MOON_MARK := preload("res://Script/hero/yutu_moon_mark.gd")
const MARK_STRIKE := preload("res://Scene/hero/role_7/yutu_mark_strike.tscn")
const STANDARD_HURT_ANIMATION_LENGTH := 0.45
const STANDARD_HURT_PLAYBACK_SPEED := 2.0

const OFFICIAL_SPEED_SCALE := 3.0

const OFFICIAL_GRAVITY := 110.0 * OFFICIAL_SPEED_SCALE * OFFICIAL_SPEED_SCALE
var _events: Array = []
var _clock := 0.0
var _action_end := 0.0
var _active_id := ""
var _active_level := 1
var _motion := Vector2.ZERO
var _motion_until := 0.0
var _gravity_until := 0.0
var _combo := 0
var potion_charge := 0.0
var _heal_remaining := 0.0
var _heal_clock := 0.0
var _heal_level := 1
var moon_attack_bonus := 0.0
var _moon_until := 0.0
var _potion_label: Label
var _dance_hits: Dictionary = {}


func on_yutu_damage_dealt(target: BaseMonster, source: Node) -> void:
	if is_death or not is_inside_tree() or not is_instance_valid(target) or target.death() or target.is_death:
		return
	var level := int(PlayerData.player_data.get("技能学习", {}).get("技能11", {}).get("等级", 0))
	var attack_data: Variant = source.get("hit_dic")
	if (
		level <= 0
		or (
			attack_data is Dictionary
			and (bool(attack_data.get("yutu_mark_proc", false)) or bool(attack_data.get("yutu_poison_damage", false)))
		)
	):
		return
	if source is BaseBuff and str(source.buff_info.get("Name", "")) in ["poision", "Voodoo"]:
		return
	var mark_name := "YutuMoonMark_" + str(get_instance_id())
	var mark := target.get_node_or_null(mark_name)
	if mark == null:
		mark = Node2D.new()
		mark.set_script(MOON_MARK)
		mark.name = mark_name
		mark.set("source", weakref(self))
		target.add_child(mark)
	var mark_count := (
		2
		if source is YutuSkillEffect and source.moon_wheel_awakened and source.skill_id in ["1112030", "1112031"]
		else 1
	)
	for _index in range(mark_count):
		if mark.call("add_mark"):
			_spawn_mark_strike.call_deferred(weakref(target), level, float(RoleProp.roleprop.power))


func _spawn_mark_strike(target_ref: WeakRef, level: int, power: float) -> void:
	var target: BaseMonster = target_ref.get_ref()
	if (
		is_death
		or not is_inside_tree()
		or not is_instance_valid(bullet)
		or not is_instance_valid(target)
		or not target.is_inside_tree()
		or target.death()
		or target.is_death
	):
		return
	var strike: Node = MARK_STRIKE.instantiate()
	strike.set("player", self)
	strike.set("skill_level", level)
	(
		strike
		. set(
			"hit_dic",
			{
				"power": YutuSkillData.passive_damage(level, power),
				"hurtBack": [0, 0],
				"attackKind": "physics",
				"WSValue": 0,
				"yutu_mark_proc": true,
			}
		)
	)
	bullet.add_child(strike)
	strike.call("launch", target)


func _ready() -> void:
	role_body.load_set("default")
	_build_animations()
	super._ready()
	on_eqchange()
	add_to_group("Player")
	for key: String in YutuSkillData.KEYS:
		role1_skill_inter[key] = 0.0
		role1_skill_max_inter[key] = 0.0
	role_action_player.play("wait")
	_potion_label = Label.new()
	_potion_label.text = "药剂已满"
	_potion_label.position = Vector2(-32, -165)
	_potion_label.add_theme_color_override("font_color", Color(0.65, 1.0, 0.55))
	_potion_label.add_theme_font_size_override("font_size", 16)
	add_child(_potion_label)
	_potion_label.hide()


func _build_animations() -> void:
	var library := AnimationLibrary.new()
	for key: String in role_body.animation_names:
		var animation := Animation.new()
		var count: int = role_body.get_frame_count(key)
		animation.length = STANDARD_HURT_ANIMATION_LENGTH if key == "hurt" else maxf(count / 30.0, 1.0 / 30.0)
		if key in ["wait", "run", "drop"]:
			animation.loop_mode = Animation.LOOP_LINEAR
		var track := animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track, NodePath("Action/RoleBody:pose_key"))
		animation.value_track_set_update_mode(track, Animation.UPDATE_DISCRETE)
		for frame in range(count):
			var frame_time := (
				float(frame) * STANDARD_HURT_ANIMATION_LENGTH / float(count - 1)
				if key == "hurt" and count > 1
				else frame / 30.0
			)
			animation.track_insert_key(track, frame_time, key + ":" + str(frame))
		var speed_track := animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(speed_track, NodePath("RolePlayer:speed_scale"))
		animation.value_track_set_update_mode(speed_track, Animation.UPDATE_CONTINUOUS)
		animation.track_insert_key(speed_track, 0.0, STANDARD_HURT_PLAYBACK_SPEED if key == "hurt" else 1.0)
		library.add_animation(key, animation)
	for key: StringName in role_action_player.get_animation_library_list():
		role_action_player.remove_animation_library(key)
	role_action_player.add_animation_library(&"", library)


func change_body(_equipment) -> void:
	role_body.set_equipment(str(_equipment), role_body.weapon_equipment)
	preload("res://Script/hero/moon_palace_clothes_effect.gd").sync(role_body, str(_equipment), true)


func change_eq(_equipment) -> void:
	role_body.set_equipment(role_body.body_equipment, str(_equipment))


func ws_skill() -> bool:
	if RoleProp.is_ws_state or is_death:
		return false
	RoleProp.is_ws_state = true
	return super.ws_skill()


func get_need_mp(skill_name, next_level):
	var index := YutuSkillData.KEYS.find(str(skill_name))
	if index < 0:
		return 0
	return YutuSkillData.mp(str(skill_name), int(get_skill_level(index + 1)) + (1 if next_level else 0))


func get_skill_display_mp(skill_name: String) -> int:
	return int(get_need_mp(skill_name, false))


func get_skill(skill_name):
	var key := str(skill_name)
	var index := YutuSkillData.KEYS.find(key)
	if (
		index < 0
		or not is_inside_tree()
		or is_death
		or is_silent
		or is_be_attacking
		or is_using_skills
		or not no_limit_buff()
	):
		return
	if get_skill_level(index + 1) < 1 or float(role1_skill_inter.get(key, 0.0)) > 0.0:
		return
	var level_node := get_parent().get_parent()
	if level_node is Level17 or level_node is Level22:
		return
	var cost := int(get_need_mp(key, false))
	if RoleProp.roleprop.Mp < cost:
		return
	RoleProp.roleprop.Mp -= cost
	role1_skill_inter[key] = 1.8
	_active_level = clampi(int(get_skill_level(index + 1)), 1, 30)
	_active_id = YutuSkillData.IDS[index]
	if _active_id == "1112050":
		_dance_hits = {}
	_events = JSON.parse_string(str(YutuSkillData.row(_active_id).get("param", "[]")))
	_clock = 0.0
	_motion_until = 0.0
	_gravity_until = 0.0
	is_attacking = true
	is_using_skills = true
	super_armor_active = true
	get_action = key
	velocity.x = 0.0
	var animation: String = YutuSkillData.ACTIONS[index]
	if key == "yt_ygj":
		for effect in bullet.get_children():
			if effect is YutuSkillEffect and effect.skill_id == "1112040":
				effect.queue_free()
	if key == "yt_ldmw" and PlayerInput.is_physical_key_pressed(KEY_W):
		_active_id = "1111051"
		_events = JSON.parse_string(str(YutuSkillData.row(_active_id).get("param", "[]")))
	if key == "yt_fyz" and PlayerInput.is_action_pressed("down"):
		animation = "skill1_down"
		_active_id = "1112011"
		_events = JSON.parse_string(str(YutuSkillData.row(_active_id).get("param", "[]")))
	role_action_player.play(animation)
	_events.sort_custom(
		func(a: Dictionary, b: Dictionary) -> bool: return int(a.get("shootFrame", 0)) < int(b.get("shootFrame", 0))
	)
	_action_end = role_action_player.get_animation(animation).length

	for event: Dictionary in _events:
		_action_end = maxf(
			_action_end,
			(
				float(event.get("shootFrame", 0)) / 30.0
				+ (float(event.get("shootTime", 0)) / 1000.0 if event.get("type") in ["move", "gravity"] else 0.04)
			)
		)
	_sound("effect_" + str(index % 5 + 1), "toxin" if index < 5 else "blade")
	if key == "yt_hyl":
		_use_potion()
	_tick_events()


func _sound(sound: String, bank: String = "blade") -> void:
	var path := "res://Music/hero/role_7/" + bank + "/" + sound + ".mp3"
	if ResourceLoader.exists(path):
		Global.get_audio_runtime().add_sound(self, path)


func _physics_process(delta: float) -> void:
	if not is_death:
		if get_skill_level(4) > 0:
			potion_charge = minf(1.0, potion_charge + delta / 20.0)
		_tick_healing(delta)
		_potion_label.visible = potion_charge >= 1.0
	if _moon_until > 0.0:
		_moon_until -= delta
		if _moon_until <= 0.0:
			moon_attack_bonus = 0.0
			RoleProp.get_last_prop()

	if _active_id != "":
		if is_death or is_be_attacking or not no_limit_buff():
			_finish_action()
		else:
			_clock += delta
			_tick_events()
			if _clock >= _action_end:
				_finish_action()
	var start := position
	var motion_active := _motion_until - _clock > 1e-05 and _active_id != ""
	var lock_gravity := _gravity_until > _clock and _active_id != ""
	if motion_active:
		velocity = _motion
	elif lock_gravity:
		velocity.y = 0.0
	if is_using_skills and not motion_active:
		velocity.x = PlayerInput.get_axis("move_left", "move_right") * walk_speed if _active_id == "1112050" else 0.0
	if (motion_active or lock_gravity) and not is_on_floor():
		velocity.y += gravity * delta
	super._physics_process(delta)
	if is_death:
		_finish_action()
		return

	if motion_active and absf(position.x - start.x) < absf(_motion.x * delta) * 0.5:
		var previous := velocity
		velocity = Vector2(_motion.x, 0)
		move_and_slide()
		velocity = previous
	if (
		not is_riding_mount()
		and no_limit_buff()
		and PlayerInput.is_action_pressed("normalhit")
		and not is_attacking
		and not is_be_attacking
		and not is_using_skills
	):
		_start_melee("hit" + str(_combo + 1) if is_on_floor() else "hit_air")


func _finish_action() -> void:
	if _motion_until > 0.0 or _gravity_until > 0.0:
		velocity = Vector2.ZERO
	_events.clear()
	_active_id = ""
	_motion_until = 0.0
	_gravity_until = 0.0
	super_armor_active = false
	is_using_skills = false
	is_attacking = false
	can_move_when_use_skill = false


func _prepare_hit_reaction() -> void:
	var knockback := velocity
	_finish_action()
	velocity = knockback


func _cancel_skill_for_control() -> void:
	if _active_id != "" or is_using_skills or is_attacking:
		_finish_action()


func _skill_super_armor_active() -> bool:
	return is_using_skills and not is_death


func _tick_events() -> void:
	var pending: Array = []
	for event: Dictionary in _events:
		if float(event.get("shootFrame", 0)) / 30.0 <= _clock:
			if event.get("type") == "move":
				_motion = (
					Vector2(
						float(event.get("shootSpeedX", 0)) * (1.0 if player_dir else -1.0),
						float(event.get("shootSpeedY", 0))
					)
					* OFFICIAL_SPEED_SCALE
				)
				_motion_until = _clock + float(event.get("shootTime", 0)) / 1000.0
			elif event.get("type") == "gravity":
				_gravity_until = _clock + float(event.get("shootTime", 0)) / 1000.0
			elif event.get("type") == "addBuff" and "80270" in event.get("buffId_has_interval", []):
				refresh_moon_bonus(_active_level)
			elif str(event.get("type", "")).begins_with("bullet"):
				_spawn_event(event, _active_id, _active_level, global_position, _dance_hits)
		else:
			pending.append(event)
	_events = pending


func spawn_skill_events(id: String, level: int, world_position: Vector2) -> void:
	var entries: Variant = JSON.parse_string(str(YutuSkillData.row(id).get("param", "[]")))
	var dance_hits: Dictionary = {}
	if entries is Array:
		for event: Dictionary in entries:
			if str(event.get("type", "")).begins_with("bullet"):
				_spawn_event(event, id, level, world_position, dance_hits)


func _spawn_event(
	event: Dictionary, id: String, level: int, world_position: Vector2, dance_hits: Dictionary = {}
) -> void:
	var names: Array = event.get("assetLink", [])
	if names.is_empty() or not is_instance_valid(bullet):
		return
	var moon_target: BaseMonster
	if event.get("type") == "bulletLocate":
		moon_target = find_moon_target(world_position)
		world_position = moon_target.global_position if is_instance_valid(moon_target) else global_position
	var bank := "toxin" if id.begins_with("1111") else "blade"
	var damage_id := str(int(event.skillId)) if event.has("skillId") else id
	var needle_awakened: bool = (
		damage_id in ["1111030", "1111031"] and event.get("type") == "bullet" and is_needle_awaken_active()
	)
	if needle_awakened and not bool(event.get("yutu_needle_branch", false)):
		for angle: float in [
			-YutuSkillData.NEEDLE_AWAKEN_SPREAD_DEGREES, 0.0, YutuSkillData.NEEDLE_AWAKEN_SPREAD_DEGREES
		]:
			var needle_event := event.duplicate(true)
			var direction := Vector2(float(event.get("shootSpeedX", 0)), float(event.get("shootSpeedY", 0))).rotated(
				deg_to_rad(angle)
			)
			needle_event["shootSpeedX"] = direction.x
			needle_event["shootSpeedY"] = direction.y
			needle_event["shootTime"] = (
				float(event.get("shootTime", 600)) * YutuSkillData.NEEDLE_AWAKEN_RANGE_MULTIPLIER
			)
			needle_event["yutu_needle_branch"] = true
			_spawn_event(needle_event, id, level, world_position, dance_hits)
		return
	var hit := {
		"power": YutuSkillData.damage(damage_id, level, float(RoleProp.roleprop.power)),
		"hurtBack": [1, 0],
		"attackKind": "physics" if bank == "blade" else "magic",
		"WSValue": 4
	}
	if id == "melee":
		bank = "blade"
		hit.power = float(RoleProp.roleprop.power) * (1.5 if _combo == 0 else 1.1 if _combo == 4 else 1.0)
	for effect_name: String in names:
		var effect := EFFECT.instantiate() as YutuSkillEffect
		effect.player = self
		effect.direction = player_dir
		effect.bank = bank
		effect.effect_name = effect_name
		effect.skill_id = damage_id
		effect.skill_level = level
		effect.moon_wheel_awakened = (damage_id in ["1112030", "1112031"] and is_moon_wheel_awaken_active())
		effect.poison_needle_awakened = needle_awakened
		effect.poison_powder_awakened = damage_id == "1111010" and is_powder_awaken_active()
		effect.poison_jar_awakened = (
			damage_id in ["1111052", "1111053"]
			and (bool(event.get("yutu_jar_awakened", false)) or is_jar_awaken_active())
		)
		if effect.poison_jar_awakened:
			effect.jar_extra_explosions = int(
				event.get("yutu_jar_remaining", YutuSkillData.JAR_AWAKEN_EXTRA_EXPLOSIONS)
			)
		effect.dance_hits = dance_hits
		effect.event = event.duplicate(true)
		if is_instance_valid(moon_target):
			effect.locked_target = weakref(moon_target)
			effect.moon_has_target = true
		effect.lifetime = maxf(0.05, float(event.get("shootTime", 500)) / 1000.0)
		effect.follow = event.get("type") == "bulletFollwSelf"
		effect.follow_offset = Vector2(
			float(event.get("x", 0)) * (1.0 if player_dir else -1.0), float(event.get("y", 0))
		)
		effect.motion = Vector2(
			float(event.get("shootSpeedX", 0)) * (1.0 if player_dir else -1.0),
			float(event.get("shootSpeedY", event.get("onceSpeedY", 0)))
		)
		if event.has("onceSpeedY"):
			effect.motion.y = float(event.onceSpeedY)
		effect.motion *= OFFICIAL_SPEED_SCALE
		effect.gravity_acceleration = float(event.get("gravMassScale", 0)) * OFFICIAL_GRAVITY
		effect.next_skill = str(int(event.nextSkillId)) if event.has("nextSkillId") else ""
		if effect.next_skill == "1111252":
			effect.next_skill = "1111052"
		if effect.next_skill == "0":
			effect.next_skill = ""
		effect.hit_interval = float(YutuSkillData.row(id).get("attInterval", 0)) / 1000.0
		effect.hit_dic = hit.duplicate(true)

		if (
			(effect_name in ["effect3_", "effect3_1", "effect5_", "effect4_", "effect4_3"] and id != "1111010")
			or id == "1111040"
		):
			effect.hit_dic = {}
		if id == "1112040":
			effect.hit_dic = {}
		var layer_index := int(event.get("layerIndex", 210))
		effect.z_index = -1 if layer_index >= 0 and layer_index < 100 else 1
		bullet.add_child(effect)
		effect.global_position = world_position + effect.follow_offset


func is_moon_wheel_awaken_active() -> bool:
	var awaken_data: Variant = PlayerData.player_data.get(DataKeys.Skill.AWAKENED, {})
	if not awaken_data is Dictionary or not bool(awaken_data.get("yt_yl", false)):
		return false
	var enabled_data: Variant = PlayerData.player_data.get(DataKeys.Skill.AWAKENED_ENABLED, {})
	return not enabled_data is Dictionary or bool(enabled_data.get("yt_yl", true))


func is_needle_awaken_active() -> bool:
	var awaken_data: Variant = PlayerData.player_data.get(DataKeys.Skill.AWAKENED, {})
	if not awaken_data is Dictionary or not bool(awaken_data.get("yt_xdz", false)):
		return false
	var enabled_data: Variant = PlayerData.player_data.get(DataKeys.Skill.AWAKENED_ENABLED, {})
	return not enabled_data is Dictionary or bool(enabled_data.get("yt_xdz", true))


func is_powder_awaken_active() -> bool:
	var awaken_data: Variant = PlayerData.player_data.get(DataKeys.Skill.AWAKENED, {})
	if not awaken_data is Dictionary or not bool(awaken_data.get("yt_mds", false)):
		return false
	var enabled_data: Variant = PlayerData.player_data.get(DataKeys.Skill.AWAKENED_ENABLED, {})
	return not enabled_data is Dictionary or bool(enabled_data.get("yt_mds", true))


func is_jar_awaken_active() -> bool:
	var awaken_data: Variant = PlayerData.player_data.get(DataKeys.Skill.AWAKENED, {})
	if not awaken_data is Dictionary or not bool(awaken_data.get("yt_ldmw", false)):
		return false
	var enabled_data: Variant = PlayerData.player_data.get(DataKeys.Skill.AWAKENED_ENABLED, {})
	return not enabled_data is Dictionary or bool(enabled_data.get("yt_ldmw", true))


func find_moon_target(from: Vector2) -> BaseMonster:
	var candidates: Array = []
	var level := get_parent().get_parent()
	if level.has_method("get_active_monsters"):
		candidates = level.call("get_active_monsters")
	else:
		candidates = get_tree().get_nodes_in_group("monsters")
	var nearest: BaseMonster
	var distance := INF
	for candidate in candidates:
		if not _is_auto_battle_target_valid(candidate):
			continue
		var monster := candidate as BaseMonster
		if monster.is_boss:
			return monster
		var current_distance := from.distance_squared_to(monster.global_position)
		if current_distance < distance:
			distance = current_distance
			nearest = monster
	return nearest


func _start_melee(animation: String) -> void:
	_active_id = "melee"
	_active_level = 1
	_clock = 0.0
	is_attacking = true
	get_action = animation
	role_action_player.play(animation)
	_action_end = role_action_player.get_animation(animation).length
	var step := _combo + 1 if animation != "hit_air" else 1
	_events = [
		{
			"type": "bulletFollwSelf",
			"shootFrame": 6 if step == 5 else 4,
			"shootTime": 267 if step == 5 else 200,
			"assetLink": ["jumpAttack_1" if animation == "hit_air" else "attack1_" + str(step)],
			"layerIndex": 210
		}
	]
	_sound("attack_" + str(step) if animation != "hit_air" else "jump_attack")
	_combo = (_combo + 1) % 5 if animation != "hit_air" else 0


func do_normalhit_1() -> void:
	_start_melee("hit1")


func do_normalhit_2() -> void:
	_start_melee("hit2")


func do_normalhit_3() -> void:
	_start_melee("hit3")


func do_normalhit_4() -> void:
	_start_melee("hit4")


func do_normalhit_5() -> void:
	_start_melee("hit_air")


func refresh_moon_bonus(level: int) -> void:
	_moon_until = float(YutuSkillData.buff_row("80270", level).get("time", "8000")) / 1000.0
	var value := float(YutuSkillData.buff_row("80270", level).get("attributeV2", "15"))
	if not is_equal_approx(moon_attack_bonus, value):
		moon_attack_bonus = value
		RoleProp.get_last_prop()


func _use_potion() -> void:
	_heal_level = _active_level
	if potion_charge >= 1.0:
		var entry := YutuSkillData.buff_row("80231", _heal_level)
		cure_hp(
			(
				float(RoleProp.roleprop.power) * float(entry.get("attributeV1", "0.036"))
				+ float(entry.get("attributeV2", "68"))
			)
		)
		_potion_effect("heal_full")
		potion_charge = 0.0
		_heal_remaining = 0.0
	else:
		_heal_remaining = 8.0
		_heal_clock = 0.0
		_heal_once()


func _tick_healing(delta: float) -> void:
	if _heal_remaining <= 0.0:
		return
	_heal_remaining -= delta
	_heal_clock += delta
	if _heal_clock >= 2.0:
		_heal_clock -= 2.0
		_heal_once()


func _heal_once() -> void:
	var entry := YutuSkillData.buff_row("80230", _heal_level)
	cure_hp(
		(
			float(RoleProp.roleprop.power) * float(entry.get("attributeV1", "0.0072"))
			+ float(entry.get("attributeV2", "14"))
		)
	)
	_potion_effect("heal")


func _potion_effect(key: String) -> void:
	var effect := AnimatedSprite2D.new()
	effect.sprite_frames = preload("res://Art/hero_picture/role_7/buffs/yutu_buffs.tres")
	effect.position.y = -55.0
	add_child(effect)
	effect.animation_finished.connect(effect.queue_free, CONNECT_ONE_SHOT)
	effect.play(key)
