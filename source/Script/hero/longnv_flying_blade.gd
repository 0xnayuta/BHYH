extends Node2D

## 小龙女飞行刃/环刃；命中检测由角色统一的 hit_original_area 执行。

var player: BaseHero
var direction := 1.0
var damage := 0.0
var elapsed := 0.0
var effect_bank := "effect2"
var speed := 800.0
var lifetime := 1.5
var repeat_interval := 0.0
var hit_size := Vector2(90, 40)
var hit_offset := Vector2.ZERO
var hit_override: Dictionary = {}
var _repeat_clock := 0.0
var targets: Dictionary = {}
var carry_enemies := false
var carried_targets: Dictionary = {}
var visual: Sprite2D


func _ready() -> void:
	visual = Sprite2D.new()
	visual.set_script(preload("res://Script/hero/longnv_official_parts.gd"))
	visual.offset = Vector2(0, -188)
	visual.scale = Vector2(direction, 1)
	add_child(visual)
	visual.load_set(effect_bank)


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player) or player.is_death:
		queue_free()
		return
	elapsed += delta

	var previous_position := global_position
	var distance := speed * delta
	global_position.x += direction * distance
	var travel := global_position - previous_position
	if carry_enemies:
		for id: int in carried_targets:
			var enemy = instance_from_id(id)
			if (
				is_instance_valid(enemy)
				and enemy is BaseMonster
				and not enemy.is_death
				and not enemy.is_control_immune()
				and not enemy.is_white_bar_control_immune()
			):
				enemy.global_position.x += travel.x
	var visual_time := elapsed
	if repeat_interval > 0.0:
		visual_time = fmod(elapsed, float(visual.get_frame_count("attack")) / 30.0)
		_repeat_clock += delta
		if _repeat_clock >= repeat_interval:
			_repeat_clock = fmod(_repeat_clock, repeat_interval)
			targets.clear()
	visual.set_time("attack", visual_time)
	player.call(
		"hit_original_area",
		(global_position + previous_position) * 0.5 + hit_offset,
		hit_size + travel.abs(),
		damage,
		targets,
		hit_override
	)
	if carry_enemies:
		carried_targets.merge(targets)
	if elapsed >= lifetime:
		queue_free()
