class_name BossProtectionController
extends RefCounted
## Boss 保护/白条状态机：累计受击、激活、衰减、白条控免计时。
## 只持有数值与计时；控制清理、技能冷却重置与视觉透明由 BaseMonster 接收激活事件后执行。

const PROTECT_DURATION := 3.5
const WHITE_BAR_DURATION := 7.5
const GAIN_MIN := 1
const GAIN_MAX := 3
const IDLE_DECAY := 6.0
const IDLE_DELAY_MSEC := 1000

var _monster: BaseMonster
var _current: float = 0.0
var _active: bool = false
var _time_left: float = 0.0
var _white_bar_time_left: float = 0.0
var _last_hit_msec: int = 0


func _init(monster: BaseMonster) -> void:
	_monster = monster


func tick(delta: float) -> void:
	_white_bar_time_left = maxf(0.0, _white_bar_time_left - delta)
	if not _monster.is_boss:
		clear()
		_monster.set_boss_protect_transparent(false)
		return
	if _active:
		_monster.set_boss_protect_transparent(true)
		_time_left = maxf(0.0, _time_left - delta)
		_current = _monster.boss_max_protect * _time_left / PROTECT_DURATION
		if _time_left <= 0.0:
			_active = false
			_current = 0.0
			_monster.set_boss_protect_transparent(false)
		return
	var since_last_hit := Time.get_ticks_msec() - _last_hit_msec
	if since_last_hit > IDLE_DELAY_MSEC:
		_current = maxf(0.0, _current - IDLE_DECAY * delta)


## 累计一次有效受击；返回 true 表示本次达到上限并进入保护。
func add_hit() -> bool:
	if not _monster.is_boss or _active:
		return false
	_last_hit_msec = Time.get_ticks_msec()
	_current = minf(_monster.boss_max_protect, _current + float(randi_range(GAIN_MIN, GAIN_MAX)))
	if _current < _monster.boss_max_protect:
		return false
	_current = _monster.boss_max_protect
	_active = true
	_time_left = PROTECT_DURATION
	_white_bar_time_left = WHITE_BAR_DURATION
	return true


func clear() -> void:
	_current = 0.0
	_active = false
	_time_left = 0.0
	_white_bar_time_left = 0.0
	_last_hit_msec = 0


func is_active() -> bool:
	return _monster.is_boss and _active


func is_white_bar_control_immune() -> bool:
	return _monster.is_boss and _white_bar_time_left > 0.0


func get_current() -> float:
	return _current


func get_white_bar_time_left() -> float:
	return _white_bar_time_left
