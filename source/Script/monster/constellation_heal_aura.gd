extends Node2D
class_name ConstellationHealAura

const SOURCE_FPS := 24.0
const FRAME_ROOT := "res://Art/constellations/common/aura_green"
const FRAME_COUNT := 19
const MAX_SOURCE_TICKS := 15 * 24

var _source_monster: BaseMonster
var _spawn_position := Vector2.ZERO
var _heal_value := 0
var _start_ticks := 20
var _source_tick_count := 0
var _tick_accumulator := 0.0
var _speed := 4
var _state := 1
var _finished := false


func configure(source_monster: BaseMonster, spawn_position: Vector2, heal_value: int) -> void:
	_source_monster = source_monster
	_spawn_position = spawn_position
	_heal_value = maxi(heal_value, 0)
	_speed = randi_range(4, 5)


func _ready() -> void:
	set_as_top_level(true)
	global_position = _spawn_position
	var stream := StreamedPngEffect.new()
	stream.frame_paths = _frame_paths()
	stream.fps = SOURCE_FPS
	stream.loop_animation = true
	stream.auto_free = false
	add_child(stream)


func _physics_process(delta: float) -> void:
	if _finished or _state == 3:
		return
	_tick_accumulator += delta
	var tick_duration := 1.0 / SOURCE_FPS
	while _tick_accumulator >= tick_duration and not _finished and _state != 3:
		_tick_accumulator -= tick_duration
		_source_step()


func _source_step() -> void:
	if _source_monster == null or not is_instance_valid(_source_monster):
		_discard()
		return
	if _state == 1:
		if _start_ticks > 0:
			_start_ticks -= 1
		else:
			_start_up()
	elif _state == 2:
		var next_direction := global_position.direction_to(_source_monster.global_position)
		global_position += next_direction * float(_speed)
		_speed = mini(_speed + 2, 20)
		if global_position.distance_to(_source_monster.global_position) <= 10.0:
			_finish_and_heal()
			return
	_source_tick_count += 1
	if _source_tick_count > MAX_SOURCE_TICKS:
		_finish_and_heal()


func _start_up() -> void:
	_state = 3
	var rise := 50.0 - randf() * 20.0
	var tween := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position:y", global_position.y - rise, 1.0)
	tween.tween_callback(_start_move)


func _start_move() -> void:
	if not _finished:
		_state = 2


func _finish_and_heal() -> void:
	if _finished:
		return
	_finished = true
	if _source_monster != null and is_instance_valid(_source_monster):
		_source_monster.cure_hp(_heal_value)
	queue_free()


func _discard() -> void:
	if _finished:
		return
	_finished = true
	queue_free()


func _frame_paths() -> Array[String]:
	var paths: Array[String] = []
	for frame in range(1, FRAME_COUNT + 1):
		paths.append(FRAME_ROOT.path_join("%d.png" % frame))
	return paths
