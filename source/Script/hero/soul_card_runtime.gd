## 7.4 魂卡/精英系统；由 7.4 反编译参考按当前 API、命名与路径适配。
extends Node2D

const DATA := preload("res://Script/data/soul_card_data.gd")
const EFFECT := preload("res://Script/hero/soul_card_effect.gd")
const BOSS_VISUAL = preload("res://Script/hero/soul_card_boss_visual.gd")
var shield_visual: Node2D
var hero: BaseHero
var props: Node
var slots: Array = []
var stars: Dictionary = {}
var bonds: Dictionary = {}
var cooldowns: Dictionary = {}
var counts: Dictionary = {}
var marks: Dictionary = {}
var set_seen: Dictionary = {}
var clock = 0.0
var next_attack = 0.0
var skill_was_active = false
var skill_serial = 0
var last_skill_hit = -1
var shield = 0
var shield_until = 0.0
var guard_until = 0.0
var defense_until = 0.0
var domain_until = 0.0
var followup = false
var prey: WeakRef
var last_attacker: WeakRef
var recent_target: WeakRef
var effects_cast = 0
var hits_processed = 0
var target_frame = -1
var cached_targets: Array[BaseMonster] = []
var cleanup_at = 2.0
var followup_after = 0


func setup(player: BaseHero) -> void:
	hero = player
	stars.clear()
	bonds.clear()
	props = LocalCoop.props_for(hero)
	var profile: Dictionary = LocalCoop.data_for(hero).player_data
	slots = DATA.equipped(profile)
	for id in slots:
		if id != "":
			stars[id] = int(DATA.record(profile, id).star)
	for bond in DATA.active_bonds(slots):
		bonds[bond.id] = true
	set_physics_process(not stars.is_empty())


func targets() -> Array[BaseMonster]:
	var frame = Engine.get_physics_frames()
	if target_frame == frame:
		return cached_targets
	target_frame = frame
	var level = get_tree().current_scene as BaseLevel
	if level == null:
		return []
	var result: Array[BaseMonster] = []
	for enemy in level.get_active_monsters():
		if (
			not enemy.death()
			and not enemy.is_death
			and not enemy.get_meta("is_summon", false)
			and not enemy.get_meta("pet_tiger_unit", false)
		):
			result.append(enemy)
	cached_targets = result
	return cached_targets


func nearest() -> BaseMonster:
	var best: BaseMonster
	var distance = INF
	for enemy in targets():
		if not is_instance_valid(enemy) or enemy.death():
			continue
		var test = hero.global_position.distance_squared_to(enemy.global_position)
		if test < distance:
			distance = test
			best = enemy
	return best


func _physics_process(delta: float) -> void:
	if not is_instance_valid(hero) or hero.is_death:
		return
	clock += delta
	if clock >= cleanup_at:
		cleanup_at = clock + 2.0
		for key in marks.keys():
			var ref: WeakRef = marks[key].ref
			if not is_instance_valid(ref.get_ref()) or ref.get_ref().death():
				marks.erase(key)
	if shield > 0 and clock >= shield_until:
		shield = 0
	var active: bool = hero.is_using_skills
	if active and not skill_was_active:
		skill_serial += 1
		_skill_cast()
	skill_was_active = active
	if stars.has("dwtw") and ready_for("dwtw"):
		give_shield(0.15)
		cooldowns.dwtw = clock + 10.0
		_record_set("dwtw", nearest())
	_sync_shield_visual()


func ready_for(key: String) -> bool:
	return clock >= float(cooldowns.get(key, 0.0))


func has_bond(key: String) -> bool:
	return bool(bonds.get(key, false))


func on_damage_dealt(enemy: BaseMonster, source: Node, critical: bool) -> void:
	if not is_instance_valid(enemy) or not is_instance_valid(source) or not is_instance_valid(hero) or hero.is_death:
		return
	if (
		source.get_meta("soul_card_damage", false)
		or source.get_meta("sword_array_damage", false)
		or source is BaseBuff
		or source is BaseMagicWeapon
		or source is MgHit
	):
		return
	if not (source is BaseHero or source is RoleBullet or source is RoleBullet1 or source is Role1Shallow):
		return

	call_deferred(
		"_process_damage_dealt", enemy.get_instance_id(), critical, hero.is_using_skills or not source is BaseHero
	)


func _process_damage_dealt(enemy_id: int, critical: bool, skill_attack: bool) -> void:
	var enemy = instance_from_id(enemy_id) as BaseMonster
	if not is_instance_valid(enemy) or enemy.is_queued_for_deletion() or not is_instance_valid(hero) or hero.is_death:
		return
	recent_target = weakref(enemy)
	if clock < next_attack:
		return
	next_attack = clock + 0.3
	hits_processed += 1
	counts.hits = int(counts.get("hits", 0)) + 1
	counts.judge_hits = int(counts.get("judge_hits", 0)) + 1
	if critical:
		counts.crits = int(counts.get("crits", 0)) + 1
	var skill_hit = skill_attack and last_skill_hit != skill_serial
	if skill_hit:
		last_skill_hit = skill_serial
		_skill_hit(enemy)
	for id in ["qly", "sfe", "hwc", "jmw", "pmw", "gmtw"]:
		if stars.has(id) and ready_for(id) and randf() < 0.25:
			trigger(id, enemy)
	if stars.has("jls") and int(counts.hits) >= 8 and ready_for("jls"):
		counts.hits = 0
		trigger("jls", enemy)
	if stars.has("stw") and int(counts.get("crits", 0)) >= 5 and ready_for("stw"):
		counts.crits = 0
		trigger("stw", enemy)
	if stars.has("pg") and int(counts.judge_hits) % (3 if clock < domain_until else 6) == 0 and ready_for("pg_mark"):
		cooldowns.pg_mark = clock + 1.0
		var layers = int(mark_value(enemy, "judge")) + 1
		mark(enemy, "judge", 120.0, layers)
		if layers >= 3:
			mark(enemy, "judge", 0.0, 0)
			trigger("pg", enemy)
	if (
		stars.has("ylw")
		and ready_for("ylw")
		and (float(enemy.hp) / maxf(1.0, enemy.max_hp) < 0.35 or (has_bond("judgment") and marked(enemy, "death")))
	):
		trigger("ylw", enemy)


func _skill_cast() -> void:
	counts.skills = int(counts.get("skills", 0)) + 1
	var enemy = nearest()
	if stars.has("nz") and ready_for("nz"):
		trigger("nz", enemy)
	if stars.has("lw") and ready_for("lw"):
		trigger("lw", enemy)
	if stars.has("cgtw") and ready_for("cgtw"):
		trigger("cgtw", enemy)
		if not followup:
			followup = true
			followup_after = skill_serial + 1
	if stars.has("zztw") and int(counts.skills) % 3 == 0 and ready_for("zztw"):
		trigger("zztw", enemy)


func _skill_hit(enemy: BaseMonster) -> void:
	if stars.has("bwc") and ready_for("bwc"):
		trigger("bwc", enemy)
	if stars.has("cgtw") and followup and skill_serial >= followup_after and ready_for("cgtw_follow"):
		followup = false
		cooldowns.cgtw_follow = clock + 0.5
		spawn("cgtw", enemy, 4.0, "magic", "sound", "burst", 140.0)


func trigger(id: String, enemy: BaseMonster) -> void:
	if not stars.has(id):
		return
	if not is_instance_valid(enemy):
		enemy = nearest()
	if enemy == null or enemy.death():
		return
	match id:
		"qly":
			cooldowns[id] = clock + 3.0
			var number = (5 if has_bond("ears") else 3) + (1 if int(stars[id]) >= 5 else 0)
			_fire_sky_arrows(enemy, number)
		"sfe":
			cooldowns[id] = clock + 4.0
			spawn(id, enemy, 8.0, "magic", "sound", "burst", 160.0)
		"jls":
			cooldowns[id] = clock + 5.0
			spawn(id, enemy, 16.0, "physics", "axe", "burst", 150.0)
		"nz":
			cooldowns[id] = clock + 6.0
			var wheel = spawn(id, enemy, 2.0, "magic", "wheel", "wheel", 95.0, 4.0 if int(stars[id]) >= 5 else 3.0, 0.5)
			wheel.global_position = hero.global_position + Vector2(50.0 if hero.player_dir else -50.0, -45.0)
			wheel.move_direction = Vector2.RIGHT if hero.player_dir else Vector2.LEFT
		"hwc":
			cooldowns[id] = clock + 4.0
			_apply_reaper(enemy)
		"bwc":
			cooldowns[id] = clock + 5.0
			spawn(id, enemy, 8.0, "magic", "chain", "burst", 175.0)
		"pg":
			spawn(id, enemy, 20.0, "magic", "judgment", "burst", 130.0)
		"ylw":
			cooldowns[id] = clock + 10.0
			spawn(id, enemy, 24.0, "magic", "judgment", "burst", 160.0)
			give_shield(0.1)
		"lw":
			cooldowns[id] = clock + 6.0
			spawn(id, enemy, 2.0, "magic", "water", "field", 170.0, 5.0 if int(stars[id]) >= 5 else 4.0, 1.0)
		"jmw":
			cooldowns[id] = clock + 4.0
			var dragon = spawn(id, enemy, 12.0, "magic", "dragon", "projectile", 65.0)
			if has_bond("dragons"):
				for water in get_tree().current_scene.get_children():
					if (
						water is EFFECT
						and water.card_id == "lw"
						and water.player == hero
						and absf(water.global_position.x - hero.global_position.x) < 650.0
					):
						for side in [-1.0, 1.0]:
							var wave = spawn("combo", enemy, 6.0, "magic", "wind", "projectile", 65.0, 0.45, 0.5, "lw")
							wave.move_direction = dragon.move_direction.rotated(side * 0.18)
							wave.global_position += Vector2(0, side * 26.0)
						break
		"stw":
			cooldowns[id] = clock + 5.0
			spawn(id, enemy, 14.0, "physics", "roar", "burst", 200.0)
		"pmw":
			cooldowns[id] = clock + 3.0
			if has_bond("hunt") and prey != null and is_instance_valid(prey.get_ref()) and not prey.get_ref().death():
				enemy = prey.get_ref()
				spawn(id, enemy, 13.0, "physics", "wind", "projectile", 65.0)
				prey = null
			else:
				spawn(id, enemy, 10.0, "physics", "wind", "projectile", 65.0)
		"zztw":
			cooldowns[id] = clock + 6.0
			spawn(id, enemy, 18.0, "physics", "sword", "burst", 165.0)
		"gmtw":
			cooldowns[id] = clock + 4.0
			spawn(id, enemy, 8.0, "magic", "snake", "projectile", 65.0)
		"cgtw":
			cooldowns[id] = clock + 5.0
			spawn(id, enemy, 8.0 * (1.5 if has_bond("guard") and shield > 0 else 1.0), "magic", "sound", "burst", 180.0)
	_record_set(id, enemy)


func _fire_sky_arrows(enemy: BaseMonster, number: int) -> void:
	var regions: Array = []
	for i in range(number):
		if i > 0:
			await get_tree().create_timer(0.12, false).timeout
		if not is_instance_valid(hero) or hero.is_death or not is_inside_tree():
			return
		if not is_instance_valid(enemy) or enemy.death():
			enemy = nearest()
		if enemy == null:
			return
		if regions.is_empty():
			regions = [0, 1, 2, 3, 4]
			regions.shuffle()
		var region: int = regions.pop_back()
		var visible_world: Rect2 = (
			get_viewport().get_canvas_transform().affine_inverse() * get_viewport().get_visible_rect()
		)
		var launch_x = visible_world.position.x + (float(region) + randf_range(0.15, 0.85)) * visible_world.size.x / 5.0
		var arrow = spawn("qly", enemy, 10.0, "physics", "arrow", "projectile", 50.0)
		arrow.global_position = Vector2(launch_x, visible_world.position.y - 180.0)
		arrow.projectile_speed = 1950.0
		arrow.lifetime = maxf(
			arrow.lifetime, arrow.global_position.distance_to(enemy.global_position) / arrow.projectile_speed + 0.6
		)
		arrow.move_direction = (enemy.global_position + Vector2(0, -45) - arrow.global_position).normalized()
		arrow.rotation = arrow.move_direction.angle()


func spawn(
	id: String,
	enemy: BaseMonster,
	multiplier: float,
	kind: String,
	visual: String,
	mode_: String,
	range_: float,
	duration: float = 0.45,
	tick: float = 0.5,
	source_id: String = ""
):
	assert(id != "combo" or source_id != "", "Bond effects require a participating Boss source")
	var effect = EFFECT.new()
	effect.runtime = self
	effect.player = hero
	effect.card_id = id
	effect.visual_source = (
		("dwtw_reflect" if id == "dwtw" and mode_ == "projectile" else id) if id != "combo" else source_id
	)
	effect.target = enemy
	effect.mode = mode_
	effect.shape = visual
	effect.radius = range_ * (1.25 if int(stars.get(id, 0)) >= 5 else 1.0)
	effect.lifetime = 1.8 if mode_ == "projectile" else duration
	effect.interval = tick
	effect.next_pulse = tick if mode_ in ["field", "wheel", "dot"] else 0.0
	var damage_star = int(stars.get(source_id if id == "combo" else id, 1))
	var damage_mult = DATA.skill_multiplier(damage_star) * (1.5 if clock < guard_until else 1.0)
	effect.hit_dic = {
		"power": maxi(1, int(float(props.roleprop.power) * maxf(10.0, multiplier) * damage_mult)),
		"attackKind": kind,
		"hurtBack": [0, 0],
		"WSValue": 0
	}
	var colors = [Color("ffcb65"), Color("bb8df2"), Color("65d9f2"), Color("9ee6ad")]
	effect.tint = colors[int(DATA.CARDS.get(id, {}).get("group", 0))]
	get_tree().current_scene.add_child(effect)
	effect.global_position = (
		hero.global_position + Vector2(0, -45)
		if mode_ == "projectile"
		else (
			enemy.global_position + Vector2(0, -45)
			if is_instance_valid(enemy)
			else hero.global_position + Vector2(0, -45)
		)
	)
	if mode_ == "projectile" and is_instance_valid(enemy):
		effect.move_direction = (enemy.global_position + Vector2(0, -45) - effect.global_position).normalized()
	effects_cast += 1
	return effect


func mark(enemy: BaseMonster, key: String, duration: float, value: float = 1.0) -> void:
	var instance = enemy.get_instance_id()
	if not marks.has(instance):
		marks[instance] = {"ref": weakref(enemy)}
	marks[instance][key] = {"until": clock + duration, "value": value}


func marked(enemy: BaseMonster, key: String) -> bool:
	return mark_value(enemy, key) > 0.0


func mark_value(enemy: BaseMonster, key: String) -> float:
	var entry: Dictionary = marks.get(enemy.get_instance_id(), {}).get(key, {})
	return float(entry.get("value", 0.0)) if float(entry.get("until", 0.0)) > clock else 0.0


func _apply_reaper(enemy: BaseMonster) -> void:
	mark(enemy, "reaper", 4.0)
	var dot = spawn("hwc", enemy, 2.0, "magic", "curse", "dot", 60.0, 4.05, 1.0)
	dot.set_meta("reaper_target", enemy.get_instance_id())


func on_card_hit(id: String, enemy: BaseMonster, visual: String, effect: Node) -> void:
	if not is_instance_valid(enemy) or enemy.death():
		return
	match id:
		"qly":
			prey = weakref(enemy)
			if has_bond("ears") and marked(enemy, "echo") and ready_for("ears"):
				cooldowns.ears = clock + 2.9
				spawn("combo", enemy, 6.0, "magic", "sound", "burst", 120.0, 0.45, 0.5, "sfe")
		"sfe":
			mark(enemy, "echo", 4.0)
		"jls":
			knock(enemy, 100.0)
			if has_bond("army") and ready_for("army"):
				for wheel in get_tree().current_scene.get_children():
					if (
						wheel is EFFECT
						and wheel.card_id == "nz"
						and wheel.player == hero
						and absf(wheel.global_position.x - enemy.global_position.x) < wheel.radius
					):
						cooldowns.army = clock + 4.9
						spawn("combo", enemy, 10.0, "magic", "ring", "burst", 150.0, 0.45, 0.5, "nz")
						if not wheel.empowered:
							wheel.lifetime += 1.0
							wheel.empowered = true
						break
			if has_bond("fortress"):
				shield = mini(int(float(props.roleprop.SHp) * 0.15), shield + int(float(props.roleprop.SHp) * 0.05))
				shield_until = maxf(shield_until, clock + 6.0)
		"bwc":
			pull(enemy, effect.global_position)
			if has_bond("reaper") and marked(enemy, "reaper") and ready_for("reaper"):
				cooldowns.reaper = clock + 6.0
				var remaining = 0
				for dot in get_tree().current_scene.get_children():
					if dot is EFFECT and dot.player == hero and dot.card_id == "hwc" and dot.target == enemy:
						remaining += maxi(0, int(floor(dot.lifetime - dot.age)))
						dot.queue_free()
				if remaining > 0:
					spawn("combo", enemy, 10.0 * remaining, "magic", "judgment", "burst", 80.0, 0.45, 0.5, "hwc")
				_apply_reaper(enemy)
		"pg":
			if has_bond("judgment"):
				mark(enemy, "death", 6.0)
		"lw":
			mark(enemy, "wet", 2.0)
		"jmw":
			if (
				has_bond("dragons")
				and marked(enemy, "wet")
				and not effect.get_meta("water_burst_" + str(enemy.get_instance_id()), false)
			):
				effect.set_meta("water_burst_" + str(enemy.get_instance_id()), true)
				spawn("combo", enemy, 8.0, "magic", "judgment", "burst", 100.0, 0.45, 0.5, "lw")
		"stw":
			stun(enemy, 1.0)
			mark(enemy, "rift", 4.0)
			_wind_water(enemy)
		"pmw":
			if has_bond("beasts") and marked(enemy, "rift") and not effect.get_meta("split", false):
				effect.set_meta("split", true)
				var others = targets().duplicate()
				others.erase(enemy)
				for i in range(mini(2, others.size())):
					spawn("combo", others[i], 5.0, "physics", "arrow", "projectile", 50.0, 0.45, 0.5, "pmw").global_position = (
						effect.global_position
					)
			_wind_water(enemy)
		"zztw":
			if has_bond("swords") and marked(enemy, "snake"):
				for side in [-1, 1]:
					var sword = spawn("combo", enemy, 6.0, "physics", "sword", "burst", 100.0, 0.45, 0.5, "zztw")
					sword.global_position.x += side * 45.0
		"gmtw":
			mark(enemy, "snake", 4.0)
			if has_bond("water_snake") and marked(enemy, "wet"):
				for other in targets():
					if other != enemy and other.global_position.distance_to(enemy.global_position) <= 200.0:
						mark(other, "snake", 4.0)
						spawn("combo", other, 4.0, "magic", "ring", "burst", 50.0, 0.45, 0.5, "gmtw")
		"cgtw":
			if has_bond("echo") and marked(enemy, "echo") and ready_for("echo"):
				cooldowns.echo = clock + 0.5
				var echo = spawn("combo", enemy, 4.0, "magic", "sound", "field", 140.0, 0.6, 0.5, "cgtw")
				echo.next_pulse = 0.5
	if has_bond("underworld") and id != "combo":
		counts.soul_hits = int(counts.get("soul_hits", 0)) + 1
		if int(counts.soul_hits) >= 12 and ready_for("underworld"):
			counts.soul_hits = 0
			cooldowns.underworld = clock + 15.0
			domain_until = clock + 4.0
			spawn("combo", enemy, 3.0, "magic", "domain", "field", 220.0, 4.05, 1.0, "ylw")
			give_shield(0.1)


func _wind_water(enemy: BaseMonster) -> void:
	if has_bond("kings") and marked(enemy, "wet") and ready_for("kings"):
		cooldowns.kings = clock + 4.0
		spawn("combo", enemy, 12.0, "magic", "water", "burst", 230.0, 0.45, 0.5, "lw")
		for other in targets():
			if other.global_position.distance_to(enemy.global_position) < 300.0:
				pull(other, enemy.global_position)


func _record_set(id: String, enemy: BaseMonster) -> void:
	set_seen[id] = true
	for group in DATA.SETS:
		if not has_bond(group.id) or group.id not in ["heaven", "guardians"] or not ready_for(group.id):
			continue
		var complete = true
		for member in group.cards:
			if not bool(set_seen.get(member, false)):
				complete = false
		if not complete:
			continue
		for member in group.cards:
			set_seen.erase(member)
		if group.id == "heaven":
			if is_instance_valid(enemy):
				cooldowns.heaven = clock + 15.0
				spawn("combo", enemy, 30.0, "magic", "judgment", "burst", 260.0, 0.45, 0.5, "jls")
		else:
			cooldowns.guardians = clock + 18.0
			guard_until = clock + 6.0
			shield = int(shield * 1.5)


func give_shield(rate: float) -> void:
	shield = maxi(shield, int(float(props.roleprop.SHp) * rate))
	shield_until = clock + 6.0


func absorb_damage(value: int) -> int:
	if value <= 0 or not is_instance_valid(hero):
		return value
	if shield > 0 and clock < shield_until:
		var absorbed = mini(shield, value)
		shield -= absorbed
		value -= absorbed
		if stars.has("dwtw") and ready_for("reflect"):
			cooldowns.reflect = clock + 1.0
			var enemy: BaseMonster = last_attacker.get_ref() if last_attacker != null else nearest()
			if is_instance_valid(enemy) and not enemy.death():
				spawn("dwtw", enemy, 6.0, "magic", "arrow", "projectile", 50.0)
		if shield == 0 and has_bond("guard"):
			defense_until = clock + 4.0
			var enemy = nearest()
			if enemy != null:
				var burst = spawn("combo", enemy, 8.0, "magic", "sound", "burst", 220.0, 0.45, 0.5, "cgtw")
				burst.global_position = hero.global_position + Vector2(0, -45)
	return value


func defense_multiplier() -> float:
	return 1.2 if clock < defense_until else 1.0


func knock(enemy: BaseMonster, distance: float) -> void:
	if enemy.is_boss or enemy.is_control_immune():
		return
	enemy.velocity.x = (1.0 if enemy.global_position.x >= hero.global_position.x else -1.0) * distance * 3.0


func pull(enemy: BaseMonster, point: Vector2) -> void:
	if enemy.is_boss or enemy.is_control_immune():
		return
	var tween = enemy.create_control_movement_tween()
	tween.tween_property(
		enemy,
		"global_position:x",
		clampf(point.x, enemy.global_position.x - 130.0, enemy.global_position.x + 130.0),
		0.2
	)


func stun(enemy: BaseMonster, duration: float) -> void:
	if enemy.is_boss or enemy.is_control_immune():
		return
	Global.add_buff(
		enemy.buff,
		{
			"Name": "stun",
			"AddTime": duration,
			"ReduceInterval": 0,
			"value": 0,
			"CanAdd": false,
			"CanRemove": true,
			"AttackKind": "",
			"DeBuff": true
		}
	)
	enemy.call_deferred("check_add_buff")


func _sync_shield_visual() -> void:
	var active = shield > 0 and clock < shield_until
	if active and not is_instance_valid(shield_visual):
		shield_visual = BOSS_VISUAL.create("shield", true)
		shield_visual.position = Vector2(0, -55)
		add_child(shield_visual)
	elif not active and is_instance_valid(shield_visual):
		shield_visual.queue_free()
