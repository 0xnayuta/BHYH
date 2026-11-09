## 7.4 魂卡/精英系统；由 7.4 反编译参考按当前 API、命名与路径适配。
extends Node

const DATA := preload("res://Script/data/soul_card_data.gd")
const ATTACK := preload("res://Script/level/elite_attack.gd")
var boss: BaseMonster
var level: BaseLevel
var id = ""
var tier = 0
var time_left = 3.0
var phase_two = false
var sequences = 0
var pending: Array[Dictionary] = []


func setup(owner_boss: BaseMonster, arena: BaseLevel, card_id: String, difficulty: int) -> void:
	boss = owner_boss
	level = arena
	id = card_id
	tier = difficulty


func _physics_process(delta: float) -> void:
	if not is_instance_valid(boss) or boss.death():
		pending.clear()
		return
	if not phase_two and tier >= 1 and float(boss.hp) / maxf(1.0, boss.max_hp) <= 0.5:
		phase_two = true
		time_left = minf(time_left, 1.0)
		level.call("show_elite_notice", "%s进入二阶段！注意地面预警" % DATA.CARDS[id].name)
	for index in range(pending.size() - 1, -1, -1):
		pending[index].delay -= delta
		if pending[index].delay <= 0.0:
			var action: Dictionary = pending[index]
			pending.remove_at(index)
			_emit(
				action.point,
				action.visual,
				action.radius,
				action.mult,
				action.get("direction", Vector2.ZERO),
				action.get("hazard", false)
			)
	time_left -= delta
	if time_left <= 0.0 and not boss.is_control_immune() and (boss.is_stun or boss.is_sleep or boss.is_ice):
		time_left = 0.3
	elif time_left <= 0.0:
		time_left = [7.0, 5.0, 4.0][tier] * (0.85 if phase_two else 1.0)
		use_signature()


func use_signature() -> void:
	var player = level.get_progression_player()
	if not is_instance_valid(player) or player.is_death:
		return
	sequences += 1
	var point: Vector2 = player.global_position + Vector2(0, -45)
	var origin: Vector2 = boss.global_position + Vector2(0, -45)
	var facing = (point - origin).normalized()
	match id:
		"qly":
			var visible_world: Rect2 = (
				level.get_viewport().get_canvas_transform().affine_inverse() * level.get_viewport().get_visible_rect()
			)
			var angle = deg_to_rad(-40.0 if boss.monster_direction else 40.0)
			var incoming = Vector2.DOWN.rotated(angle)
			for index in range(3 + tier):
				var landing = point + Vector2((index - (2.0 + tier) * 0.5) * 100.0, 0)
				var sky = (
					landing
					- incoming * ((landing.y - minf(visible_world.position.y - 180.0, landing.y - 1000.0)) / incoming.y)
				)
				queue_attack(index * 0.12, sky, "arrow", 28.0, 0.7, incoming)
		"pmw":
			for index in range(3 + tier):
				var spread: float = (index - (2.0 + tier) * 0.5) * 0.16
				queue_attack(
					0.15 * index, origin, "arrow" if id == "qly" else "wind", 28.0, 0.7, facing.rotated(spread)
				)
			queue_attack(0.8, point, "ring", 105.0, 1.0)
		"sfe", "cgtw":
			for index in range(2 + tier):
				queue_attack(index * 0.45, point + Vector2((index - 1) * 95, 0), "sound", 125.0, 0.8)
			queue_attack(1.3, point, "sound", 145.0, 0.35, Vector2.ZERO, true)
		"jls", "zztw":
			for index in range(2 + tier):
				queue_attack(
					index * 0.45,
					point + Vector2((index % 2) * 100 - 50, 0),
					"axe" if id == "jls" else "sword",
					95.0,
					1.1
				)
			if phase_two:
				for side in [-1.0, 1.0]:
					queue_attack(1.5, point + Vector2(side * 210.0, 0), "ring", 110.0, 0.8)
		"nz", "jmw":
			for side in [-1.0, 1.0] if phase_two else [1.0]:
				var from = Vector2(80.0 if side > 0 else 1120.0, point.y)
				queue_attack(0.0, from, "wind" if id == "nz" else "dragon", 50.0, 0.7, Vector2(side, 0))
			queue_attack(0.8, point, "ring", 110.0, 0.8)
		"hwc", "bwc", "pg", "ylw":
			var number = 2 + tier
			for index in range(number):
				queue_attack(
					index * 0.35,
					point + Vector2((index - (number - 1) * 0.5) * 150, 0),
					"judgment",
					90.0 if id != "ylw" else 150.0,
					1.0
				)
			if id in ["hwc", "ylw"]:
				queue_attack(1.2, point, "domain", 140.0, 0.3, Vector2.ZERO, true)
		"lw", "gmtw":
			queue_attack(0.0, point, "water", 115.0, 1.1)
			queue_attack(1.0, point, "water", 160.0, 0.35, Vector2.ZERO, true)
			if id == "gmtw":
				queue_attack(0.0, origin, "snake", 40.0, 0.7, facing)
		"stw":
			queue_attack(0.0, point, "ring", 170.0, 1.2)
			if phase_two:
				queue_attack(0.8, origin, "ring", 240.0, 0.9)
		"dwtw":
			for index in range(3 + tier):
				queue_attack(
					index * 0.2, Vector2(clampf(point.x + (index - 1) * 140, 90, 1110), point.y), "judgment", 75.0, 0.9
				)
	if tier == 2 and phase_two and sequences % 3 == 0:
		for x in [220.0, 600.0, 980.0]:
			queue_attack(1.8, Vector2(x, point.y), "judgment", 120.0, 1.2)


func queue_attack(
	delay: float,
	point: Vector2,
	visual: String,
	radius: float,
	mult: float,
	direction_: Vector2 = Vector2.ZERO,
	hazard: bool = false
) -> void:
	pending.append(
		{
			"delay": delay,
			"point": point,
			"visual": visual,
			"radius": radius,
			"mult": mult,
			"direction": direction_,
			"hazard": hazard
		}
	)


func _emit(point: Vector2, visual: String, radius_: float, mult: float, direction_: Vector2, hazard: bool) -> void:
	if id == "qly" and visual == "arrow":
		var hit_data: Dictionary = boss.obj_attack_dict["hit3"].duplicate(true)
		hit_data.power = int(float(hit_data.power) * mult)
		var arrow = Global.add_bullet(
			"Monster77Bullet3", boss.bullet, boss.monster_direction, 6, Vector2.ZERO, "hit3", hit_data
		)
		if arrow != null:
			arrow.global_position = point
			arrow.rotation = direction_.angle() - PI * 0.5
		return
	var attack = ATTACK.new()
	attack.boss = boss
	attack.card_id = id
	attack.visual = visual
	attack.radius = radius_
	attack.move_direction = direction_
	attack.is_hazard = hazard
	attack.warning = 1.0 if direction_ == Vector2.ZERO else 0.65
	attack.duration = 3.0 if hazard else 2.8 if direction_ != Vector2.ZERO else 0.35
	attack.tick = 0.75 if hazard else 10.0
	var power = 1
	for key in boss.obj_attack_dict:
		var value: Variant = boss.obj_attack_dict[key]
		if value is Dictionary:
			var candidate = int(value.get("power", 0))
			if candidate >= power and value.has("attackKind"):
				power = candidate
				attack.hit_name = str(key)
	var kind = str(boss.obj_attack_dict.get(attack.hit_name, {}).get("attackKind", "magic"))
	attack.obj_attack_dict = {attack.hit_name: {"power": int(power * mult), "attackKind": kind, "hurtBack": [0, 0]}}
	level.add_child(attack)
	attack.global_position = point
