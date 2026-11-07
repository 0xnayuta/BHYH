extends RefCounted

## 小龙女额外技能状态：潜行、龙魂、冲刺、投射物与持续伤害的运行时组合。

const BLADE := preload("res://Script/hero/longnv_flying_blade.gd")
const DOT := preload("res://Script/hero/longnv_damage_over_time.gd")
const SCREEN_STORM := preload("res://Script/hero/longnv_screen_storm.gd")
const PARTS := preload("res://Script/hero/longnv_official_parts.gd")

var hero
var stealth_left := 0.0
var stealth_bonus_left := 0.0
var reveal_grace := 0.0
var fury_left := 0.0
var soul_left := 0.0
var dodge_left := 0.0
var stealth_level := 1
var soul_level := 1
var stage := 0
var fired := 0
var visual_start := 0.0
var swept_position := Vector2.ZERO
var fury_visual: Sprite2D
var cast_power := 0.0


func tick(delta: float) -> void:
	var was_hidden := stealth_left > 0.0
	var had_fury := fury_left > 0.0
	stealth_left = maxf(0.0, stealth_left - delta)
	stealth_bonus_left = maxf(0.0, stealth_bonus_left - delta)
	fury_left = maxf(0.0, fury_left - delta)
	soul_left = maxf(0.0, soul_left - delta)
	dodge_left = maxf(0.0, dodge_left - delta)
	reveal_grace = maxf(0.0, reveal_grace - delta)
	if hero.is_death:
		stealth_left = 0.0
		stealth_bonus_left = 0.0
		fury_left = 0.0
		soul_left = 0.0
		dodge_left = 0.0
		reveal_grace = 0.0
	elif was_hidden and stealth_left <= 0.0:
		reveal_grace = 0.7
	hero.role_body.modulate.a = 0.25 if stealth_left > 0.0 else 1.0
	if had_fury and fury_left <= 0.0:
		hero.check_add_buff()
	if fury_left <= 0.0 and is_instance_valid(fury_visual):
		fury_visual.queue_free()
		fury_visual = null


func reveal() -> void:
	if stealth_left > 0.0:
		stealth_left = 0.0
		reveal_grace = 0.7
		hero.role_body.modulate.a = 1.0


func damage_multiplier() -> float:
	var multiplier := (
		1.0
		+ (0.1 + (stealth_level - 1) * 0.0025 if stealth_bonus_left > 0.0 else 0.0)
		+ (0.3 if fury_left > 0.0 else 0.0)
		+ (minf(0.3, floorf((soul_level + 1) / 2.0) * 0.008) if soul_left > 0.0 else 0.0)
	)
	if hero.is_skill_awakened("xln_lz") and hero._skill_index == 0:
		multiplier *= 2.0
	return multiplier


func reduction() -> float:
	return (
		(0.2 if stealth_bonus_left > 0.0 else 0.0)
		+ (0.3 if fury_left > 0.0 else 0.0)
		+ (minf(0.3, floorf((soul_level + 1) / 2.0) * 0.008) if soul_left > 0.0 else 0.0)
	)


func speed_multiplier() -> float:
	return (
		1.0
		+ (0.3 if stealth_left > 0.0 else 0.0)
		+ (0.4 if fury_left > 0.0 else 0.0)
		+ (0.3 if soul_left > 0.0 else 0.0)
	)


func start(index: int, level: int) -> void:
	stage = 0
	fired = 0
	visual_start = 0.0
	swept_position = hero.global_position
	cast_power = float(hero.call("_props").roleprop.power)
	match index:
		5:
			stealth_left = 10.0
			stealth_bonus_left = 10.0
			stealth_level = level
		9:
			fury_left = 10.0
			hero.check_add_buff()
			if is_instance_valid(fury_visual):
				fury_visual.queue_free()
			fury_visual = spawn_aura("effect9_buff", 10.0)
		10:
			dodge_left = 2.0
		18:
			soul_left = 8.0
			soul_level = level
	if index in [12, 15, 17]:
		hero.attack_visual.hide()
	if index in [6, 7, 13, 14, 16]:
		hero.attack_visual.hide()
	if index == 19:
		hero.attack_visual.hide()
		var storm = SCREEN_STORM.new()
		storm.source = weakref(hero)
		storm.damage = hero._cast_damage * damage_multiplier()
		hero._screen_layer.add_child(storm)
	hero.check_add_buff()


func spawn_aura(bank: String, duration: float) -> Sprite2D:
	var effect := Sprite2D.new()
	effect.set_script(PARTS)
	effect.offset = Vector2(0, -188)
	hero.action.add_child(effect)
	effect.scale = hero.role_body.scale
	effect.load_set(bank)
	var tween = effect.create_tween()
	tween.tween_method(
		func(t: float):
			if is_instance_valid(effect):
				effect.set_time("attack", t),
		0.0,
		duration,
		duration
	)
	tween.tween_callback(effect.queue_free)
	return effect


func update_cast(previous: float) -> void:
	var index: int = hero._skill_index
	var elapsed: float = hero._elapsed
	if index == 6 and stage == 0 and elapsed >= 0.7:
		change_stage("effect6_2", "effect6_2", 0.7)
	elif index == 7 and stage == 0 and elapsed >= 0.54:
		change_stage("effect7_2", "effect7_2", 0.54)
	elif index == 13 and stage == 0 and elapsed >= 0.2:
		change_stage("effect4_2", "ring_effect4_2", 0.2)
	elif index == 13 and stage == 1 and elapsed >= 1.0:
		change_stage("effect4_3", "", 1.0)
	elif index == 16 and stage == 0 and elapsed >= 0.23:
		change_stage("effect7_2", "", 0.23)
	if index == 11 and fired == 0 and elapsed >= 0.35:
		fired += 1
		projectile("ring_effect2_2", 650.0, 0.9, 0.0, Vector2(170, 150), 11)
	elif index == 12:
		while fired < 3 and elapsed >= 0.3 + 0.3 * fired:
			fired += 1
			projectile("ring_effect3", 700.0, 1.2, 0.0, Vector2(95, 95), 12)
	elif index == 15 and fired == 0 and elapsed >= 0.5:
		fired += 1
		projectile("ring_effect6", 450.0, 1.5, 0.5, Vector2(230, 190), 15, true)
	elif index == 14 and fired == 0 and elapsed >= 0.08 and hero.is_skill_awakened("xln_jyc"):
		fired += 1
		var blade = projectile("ring_effect6", 0.0, 1.0, 0.18, Vector2(460, 300), 14, false, Vector2(0, -65))
		blade.damage = hero._cast_damage * 3.0
		blade.visual.scale *= 2.0
	elif index == 17 and fired == 0 and elapsed >= 0.7:
		fired += 1
		projectile("ring_effect8_1", 0.0, 0.87, 0.2, Vector2(450, 250), 17, false, Vector2(150 * facing(), 0))


func change_stage(body: String, bank: String, start_time: float) -> void:
	stage += 1
	visual_start = start_time
	hero.role_action_player.play(body)
	if bank.is_empty():
		hero.attack_visual.hide()
	else:
		hero.attack_visual.load_set(bank)


func facing() -> float:
	return 1.0 if hero.player_dir else -1.0


func projectile(
	bank: String,
	speed: float,
	lifetime: float,
	repeat: float,
	size: Vector2,
	skill: int,
	carry := false,
	offset := Vector2.ZERO
):
	var blade = BLADE.new()
	blade.player = hero
	blade.direction = facing()
	var ammo_ratios := {11: 1.33, 12: 1.2, 15: 0.5, 17: 1.51}
	var ammo_ratio: float = ammo_ratios.get(skill, LongnvSkillData.RATIOS[skill])
	blade.damage = (
		(hero._cast_damage + cast_power * (ammo_ratio - float(LongnvSkillData.RATIOS[skill]))) * damage_multiplier()
	)
	blade.effect_bank = bank
	blade.speed = speed
	blade.lifetime = lifetime
	blade.repeat_interval = repeat
	blade.hit_size = size
	blade.hit_offset = Vector2(0, -65)
	blade.carry_enemies = carry
	blade.hit_override = {
		"longnv_skill": skill,
		"longnv_spin_direction": facing(),
		"hurtBack": [4 if skill == 12 else 0, 0],
		"attackKind": "magic" if skill == 17 else "physics",
	}
	hero.get_parent().add_child(blade)
	blade.global_position = hero.global_position + offset
	return blade


func targets(center: Vector2, size: Vector2) -> Array[BaseMonster]:
	var query := PhysicsShapeQueryParameters2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	query.shape = shape
	query.transform = Transform2D(0, center)
	query.collision_mask = 2064
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var result: Array[BaseMonster] = []
	for contact: Dictionary in hero.get_world_2d().direct_space_state.intersect_shape(query, 256):
		var enemy: Node = contact.collider
		while enemy != null and not enemy is BaseMonster:
			enemy = enemy.get_parent()
		if enemy is BaseMonster and enemy not in result and not enemy.is_death:
			result.append(enemy)
	return result


func is_dashing() -> bool:
	if not hero._active or hero.is_death:
		return false
	var elapsed: float = hero._elapsed
	match hero._skill_index:
		6:
			return elapsed >= 0.06 and elapsed < 0.72
		13:
			return elapsed >= 0.1 and elapsed < 0.82
		14:
			return elapsed >= 0.12 and elapsed < 0.7
	return false


func move_cast(delta: float) -> void:
	var index: int = hero._skill_index
	var elapsed: float = hero._elapsed
	var speed := 0.0
	var dash_progress := -1.0
	var dash_distance := 0.0
	var dash_duration := 0.0
	var dash_start := 0.0
	if index == 6 and elapsed >= 0.06 and elapsed < 0.72:
		dash_start = 0.06
		dash_duration = 0.66
		dash_distance = 520.0
	elif index == 14 and not hero.is_skill_awakened("xln_jyc") and elapsed >= 0.12 and elapsed < 0.7:
		dash_start = 0.12
		dash_duration = 0.58
		dash_distance = 280.0
	elif index == 13 and elapsed >= 0.1 and elapsed < 0.82:
		dash_start = 0.1
		dash_duration = 0.72
		dash_distance = 300.0
	elif index == 8:
		speed = hero.PlayerInput.get_axis("move_left", "move_right") * 200.0
	if dash_duration > 0.0:
		dash_progress = clampf((elapsed - dash_start) / dash_duration, 0.0, 1.0)
		speed = dash_distance * PI / (2.0 * dash_duration) * sin(PI * dash_progress) * facing()
	if index == 14 and hero.is_skill_awakened("xln_jyc"):
		speed = 0.0
	if index in [6, 13, 14]:
		hero.velocity.x = speed
	if index == 8 or index == 13:
		for enemy: BaseMonster in targets(hero.global_position + Vector2(0, -60), Vector2(600, 220)):
			if not enemy.is_control_immune() and not enemy.is_white_bar_control_immune():
				enemy.global_position.x = move_toward(
					enemy.global_position.x,
					hero.global_position.x + 50 * signf(enemy.global_position.x - hero.global_position.x),
					delta * 500.0
				)

	if index in [6, 14] and elapsed >= 0.3 and elapsed < 0.7:
		pulse(0)
	swept_position = hero.global_position


func pulse(pulse_index: int) -> void:
	var index: int = hero._skill_index
	if not hero._pulse_targets.has(pulse_index):
		hero._pulse_targets[pulse_index] = {}
	var seen: Dictionary = hero._pulse_targets[pulse_index]
	var center: Vector2 = hero.global_position + Vector2(0, -65)
	var size := Vector2(300, 170)
	var ratio := 1.0
	if index in [6, 14]:
		var travel: Vector2 = hero.global_position - swept_position
		center = (hero.global_position + swept_position) * 0.5 + Vector2(65 * facing(), -60)
		size = Vector2(230, 170) + travel.abs()
		if index == 6 and pulse_index == 1:
			ratio = 1.86 / 1.56
	elif index == 7:
		size = Vector2(750, 180)
	elif index in [8, 9, 13, 16, 18]:
		size = Vector2(480, 250)
	elif index == 17:
		return
	elif index == 19:
		var canvas: Transform2D = hero.get_viewport().get_canvas_transform()
		center = canvas.affine_inverse() * hero.get_viewport_rect().get_center()
		size = hero.get_viewport_rect().size / canvas.get_scale().abs()
	else:
		center.x += 65 * facing()
	hero.hit_original_area(
		center,
		size,
		hero._cast_damage * ratio * damage_multiplier(),
		seen,
		{"longnv_skill": index, "attackKind": "magic" if index >= 17 else "physics", "hurtBack": [0, 0]}
	)


func add_status(enemy: BaseMonster, status_name: String, duration: float, value := 0.0) -> void:
	(
		Global
		. add_buff(
			enemy.buff,
			{
				"Name": status_name,
				"AddTime": duration,
				"value": value,
				"CanAdd": false,
				"CanRemove": true,
				"DeBuff": true,
				"AttackKind": "real",
			}
		)
	)
	enemy.call_deferred("check_add_buff")


func on_hit(enemy: BaseMonster, index: int) -> void:
	match index:
		4:
			if hero.is_skill_awakened("xln_ly"):
				add_status(enemy, "stun", 2.0)
		3:
			var stacks: Dictionary = hero.get_meta("longnv_bleed_stacks", {})
			var target_id := enemy.get_instance_id()
			var count := int(stacks.get(target_id, 0)) + 1
			if hero.is_skill_awakened("xln_xr") and count >= 5:
				var burst: int = LongnvSkillData.bleed_damage(enemy, hero, 0.1)
				var previous_hit: Dictionary = hero.hit_dic
				hero.hit_dic = {"power": burst, "attackKind": "magic", "WSValue": 0}
				enemy.hurt_reduce_hp(maxi(1, burst), hero)
				hero.hit_dic = previous_hit
				count = 0
			stacks[target_id] = count
			hero.set_meta("longnv_bleed_stacks", stacks)
		6:
			add_status(enemy, "stun", 1.0)
			add_dot(enemy, "pierce", hero._cast_damage * 0.15 / 1.56, 0.0)
		7:
			if stage > 0 and not enemy.is_control_immune() and not enemy.is_white_bar_control_immune():
				enemy.global_position.x = (
					hero.global_position.x + 65 * signf(enemy.global_position.x - hero.global_position.x)
				)
			add_status(enemy, "stun", 2.0)
		9:
			add_status(enemy, "stun", 1.5)
		11, 13:
			add_status(enemy, "DefeReduce", 2.0 if index == 11 else 4.0, 0.3)
		14:
			add_status(enemy, "stun", 1.0)
		15:
			add_dot(enemy, "ring_bleed", 0.0, 0.02)
		16:
			add_status(enemy, "stun", 2.0)
		17:
			add_status(enemy, "Scary", 3.0)
			add_status(enemy, "speed_down", 5.0, 0.5)
		18:
			add_status(enemy, "stun", 2.0)
		19:
			add_status(enemy, "stun", 3.0)


func add_dot(enemy: BaseMonster, kind: String, dot_damage: float, life_ratio: float) -> void:
	var key := "LongnvDot_" + str(hero.get_instance_id()) + "_" + kind
	var dot = enemy.get_node_or_null(key)
	if dot == null:
		dot = DOT.new()
		dot.name = key
		dot.source = weakref(hero)
		dot.target = weakref(enemy)
		enemy.add_child(dot)
	dot.damage = dot_damage
	dot.current_life_ratio = life_ratio
	dot.ticks_left = 3
