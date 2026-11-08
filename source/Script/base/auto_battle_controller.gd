class_name AutoBattleController
extends RefCounted
## 自动战斗状态机：目标缓存、技能游标/计数、节拍与移动/跳跃策略。
## 只通过 AutoBattleContext 查询和操作 BaseHero，不读取 UI/存档。

const INTERVAL := 0.22
const TARGET_SEARCH_INTERVAL := 0.15
const TARGET_SEARCH_RANGE := 1800.0
const ATTACK_RANGE := 260.0
const JUMP_COOLDOWN := 0.8
const MOVE_SPEED_SCALE := 1.0
const VERTICAL_ATTACK_RANGE := 220.0

var _context: AutoBattleContext
var _elapsed := 0.0
var _skill_cursor := 0
var _skill_cast_counts: Dictionary = {}
var _target: Variant = null
var _target_search_elapsed := 0.0
var _jump_elapsed := 0.0


func _init(context: AutoBattleContext) -> void:
	_context = context


func should_control_movement() -> bool:
	return _context.is_enabled() and not _context.is_skill_only()


func get_target() -> Variant:
	return _target


func get_skill_cursor() -> int:
	return _skill_cursor


func get_skill_cast_counts() -> Dictionary:
	return _skill_cast_counts.duplicate()


func get_elapsed() -> float:
	return _elapsed


## 每个物理帧推进计时器；与原 BaseHero 字段更新时机一致。
func advance_timers(delta: float) -> void:
	_target_search_elapsed += delta
	_jump_elapsed += delta


## 场景退出或重新初始化时清空运行态。
func reset() -> void:
	_target = null
	_skill_cast_counts.clear()
	_skill_cursor = 0
	_elapsed = 0.0
	_target_search_elapsed = 0.0
	_jump_elapsed = 0.0


func tick(delta: float) -> void:
	if _context.is_owner_queued_for_deletion():
		return
	if not _context.is_enabled():
		_elapsed = 0.0
		_target = null
		_target_search_elapsed = 0.0
		_skill_cursor = 0
		_skill_cast_counts.clear()
		return
	if _context.is_dead():
		return
	if not _context.has_current_scene():
		return
	_process_equipment()
	if _context.try_activate_wushuang():
		return
	if _context.is_action_blocked():
		return
	if _context.is_control_blocked():
		return
	_elapsed += delta
	if _elapsed < INTERVAL:
		return
	_elapsed = 0.0

	if not _context.is_skill_only():
		var target: Variant = get_target_for_tick()
		if target == null or not is_target_in_attack_range(target):
			return

	var skill_entries := _context.get_skill_entries()
	if skill_entries.is_empty():
		_skill_cursor = 0
		_skill_cast_counts.clear()
		return
	if _skill_cursor >= skill_entries.size():
		_skill_cursor = 0
	var configured_ids: Array[String] = []
	for entry in skill_entries:
		configured_ids.append(str(entry.get("id", "")))
	for skill_id in _skill_cast_counts.keys():
		if str(skill_id) not in configured_ids:
			_skill_cast_counts.erase(skill_id)
	for offset in range(skill_entries.size()):
		var index := (_skill_cursor + offset) % skill_entries.size()
		var entry: Dictionary = skill_entries[index]
		var skill_id := str(entry.get("id", ""))
		if _context.is_skill_active(skill_id):
			_skill_cast_counts.erase(skill_id)
			_skill_cursor = (index + 1) % skill_entries.size()
			continue
		if not _context.can_use_skill(skill_id):
			continue
		if not _context.cast_skill(skill_id):
			continue
		var cast_count := int(_skill_cast_counts.get(skill_id, 0)) + 1
		var required_count := maxi(1, int(entry.get("count", 1)))
		if cast_count >= required_count:
			_skill_cast_counts.erase(skill_id)
			_skill_cursor = (index + 1) % skill_entries.size()
		else:
			_skill_cast_counts[skill_id] = cast_count
			_skill_cursor = index
		return


func _process_equipment() -> void:
	if _context.is_magic_weapon_enabled():
		_context.try_use_magic_weapon()
	if _context.is_sword_array_enabled() and _context.can_use_sword_array():
		_context.use_sword_array()


## 移动分支在 noarmal_control 中每物理帧调用；保持原判断顺序。
func process_movement() -> void:
	if not _context.is_enabled():
		return
	if _context.is_skill_only():
		_target = null
		_context.stop_horizontal()
		_context.set_idle()
		return
	if _context.is_action_blocked():
		_context.stop_horizontal()
		return
	if _context.is_auto_move_blocked():
		_context.stop_horizontal()
		return

	var target: Variant = get_target_for_tick()
	if not _context.is_target_valid(target):
		target = null
	var direction := 1.0
	if target != null and not is_target_in_attack_range(target):
		var horizontal_delta: float = float(target.global_position.x - _context.get_position().x)
		if absf(horizontal_delta) > 12.0:
			direction = signf(horizontal_delta)
		elif target.global_position.y < _context.get_position().y - 50.0:
			direction = 1.0 if _context.is_facing_right() else -1.0
		else:
			_context.stop_horizontal()
			_context.set_idle()
			return
	elif target != null:
		var target_delta_x: float = float(target.global_position.x - _context.get_position().x)
		if absf(target_delta_x) > 8.0:
			_context.set_facing(signf(target_delta_x))
		_context.stop_horizontal()
		_context.set_idle()
		return
	else:
		direction = 1.0

	_context.set_facing(direction)
	if _context.is_blocked_ahead(direction):
		_jump_if_blocked()
	if _context.is_combat_busy():
		_context.stop_horizontal()
		return
	_context.set_velocity_x(direction * _context.get_auto_move_speed() * MOVE_SPEED_SCALE)
	_context.play_run()


func get_target_for_tick() -> Variant:
	if (
		is_instance_valid(_target)
		and _context.is_target_valid(_target)
		and _target_search_elapsed < TARGET_SEARCH_INTERVAL
	):
		return _target
	_target_search_elapsed = 0.0
	_target = null
	var candidates := _context.get_target_candidates()
	var best_target: Variant = null
	var best_score := INF
	for candidate in candidates:
		if not _context.is_target_valid(candidate):
			continue
		var monster := candidate as BaseMonster
		if monster == null:
			continue
		var horizontal_distance := _context.get_horizontal_distance(monster)
		var vertical_distance := _context.get_vertical_distance(monster)
		if horizontal_distance > TARGET_SEARCH_RANGE:
			continue
		var score := horizontal_distance + vertical_distance * 0.35
		if score < best_score:
			best_score = score
			best_target = monster
	_target = best_target
	return _target


func is_target_in_attack_range(target: Variant) -> bool:
	if not _context.is_target_valid(target):
		return false
	var monster := target as BaseMonster
	if monster == null:
		return false
	return (
		_context.get_horizontal_distance(monster) <= get_attack_range()
		and _context.get_vertical_distance(monster) <= VERTICAL_ATTACK_RANGE
	)


func get_attack_range() -> float:
	var range_value := ATTACK_RANGE
	for skill_entry in _context.get_skill_entries():
		var skill_id := str(skill_entry.get("id", ""))
		if skill_id in ["hyjj", "hyjj_ws", "nz_yysj"]:
			range_value = maxf(range_value, 420.0)
		elif skill_id in ["lyfb", "hmz", "hmz_ws", "smb", "by", "cmly", "tllz", "ltjz"]:
			range_value = maxf(range_value, 320.0)
	return range_value


func _jump_if_blocked() -> void:
	if _jump_elapsed < JUMP_COOLDOWN:
		return
	if not _context.can_jump():
		return
	_jump_elapsed = 0.0
	_context.jump()
