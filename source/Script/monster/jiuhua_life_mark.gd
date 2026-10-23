extends Node
class_name JiuhuaLifeMark

const DURATION_SECONDS := 8.0
const MAX_CHILD_STACKS := 4
const DAMAGE_PER_STACK_ATTACK_MULTIPLIER := 1.1

var _target_ref: WeakRef
var _attack_power := 0
var _child_stack_count := 0
var _resolved := false
var _timer: Timer


func _init() -> void:
	name = "JiuhuaLifeMark"


func start(target: BaseHero, attack_power: int) -> void:
	_target_ref = weakref(target)
	_attack_power = maxi(attack_power, 0)
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.wait_time = DURATION_SECONDS
	add_child(_timer)
	_timer.timeout.connect(resolve)
	_timer.start()


func add_stack(attack_power: int) -> void:
	if _resolved or _child_stack_count >= MAX_CHILD_STACKS:
		return
	_child_stack_count += 1
	_attack_power = maxi(attack_power, 0)


func stack_count() -> int:
	return 1 + _child_stack_count


func time_left() -> float:
	return _timer.time_left if _timer != null else 0.0


func resolve() -> void:
	if _resolved:
		return
	_resolved = true
	var target := _target_ref.get_ref() as BaseHero if _target_ref != null else null
	if target != null and is_instance_valid(target):
		var damage := maxi(1, int(float(_attack_power) * DAMAGE_PER_STACK_ATTACK_MULTIPLIER * float(stack_count())))
		target.effect_reducehp(damage, "physics")
	queue_free()
