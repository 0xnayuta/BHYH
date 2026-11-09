## 7.4 魂卡/精英系统；由 7.4 反编译参考按当前 API、命名与路径适配。
extends Node2D

const BOSS_VISUAL = preload("res://Script/hero/soul_card_boss_visual.gd")
var native_visual: Node2D
var card_id = "qly"
var activated = false
var boss: BaseMonster
var hit_name = "elite_attack"
var obj_attack_dict: Dictionary = {}
var visual = "ring"
var tint = Color("ed835e")
var warning = 0.8
var duration = 0.4
var radius = 100.0
var tick = 1.0
var age = 0.0
var next_hit = 0.0
var direction_ = Vector2.ZERO
var previous_position = Vector2.ZERO
var hits: Dictionary = {}
var is_hazard = false


func _ready() -> void:
	z_index = 6
	next_hit = warning
	previous_position = global_position
	native_visual = BOSS_VISUAL.create(card_id, false)
	add_child(native_visual)
	native_visual.modulate.a = 0.3
	var native_player = native_visual.get_node("NativeAnimation") as AnimationPlayer
	native_player.play("effect")
	native_player.seek(0.0, true)
	native_player.pause()
	if direction_ != Vector2.ZERO:
		rotation = direction_.angle()
	duration = float(native_visual.get_meta("native_duration", duration))


func _physics_process(delta: float) -> void:
	if not is_instance_valid(boss) or boss.death():
		queue_free()
		return
	age += delta
	if age >= warning:
		if not activated:
			activated = true
			native_visual.modulate.a = 1.0
			var animation = native_visual.get_node_or_null("NativeAnimation") as AnimationPlayer
			if animation != null:
				animation.play("effect")
				animation.seek(0.0, true)
		var before = global_position
		global_position += direction_ * 450.0 * delta
		for actor in get_parent().hero.get_children():
			if not actor is BaseHero or actor.is_death or actor.need_protect:
				continue
			var key = actor.get_instance_id()
			if age < float(hits.get(key, warning)):
				continue
			var point: Vector2 = actor.global_position + Vector2(0, -45)
			var closest = Geometry2D.get_closest_point_to_segment(point, before, global_position)
			var touched = (
				point.distance_to(closest) <= radius
				if direction_ != Vector2.ZERO
				else absf(point.x - global_position.x) <= radius and absf(point.y - global_position.y) < 170.0
			)
			if touched:
				hits[key] = age + tick
				var amount: int = actor.get_monster_last_hurt(boss, self)
				actor.reduce_hp(amount, boss, self)
	if age >= warning + duration:
		queue_free()
