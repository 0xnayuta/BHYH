class_name LevelSettlement
extends Node2D

## 胜败结算的唯一提交边界：保存失败保留待提交状态，离开/重战先尝试提交。
## 测试可注入 save_request_override / scene_change_override，生产走 MemoryClass 与 Global。

var save_request_override: Callable
var scene_change_override: Callable
var _pending_save_reason: String = ""
var _is_leaving: bool = false
var _is_rechallenging: bool = false
var _save_failure_notified: bool = false


func _request_settlement_save(reason: String) -> bool:
	var saved: bool
	if save_request_override.is_valid():
		saved = bool(save_request_override.call(reason))
	else:
		saved = MemoryClass.request_save(reason, false)
	if saved:
		_save_failure_notified = false
	else:
		_notify_settlement_save_failure()
	return saved


func _commit_settlement(reason: String) -> bool:
	if _request_settlement_save(reason):
		_pending_save_reason = ""
		return true
	_pending_save_reason = reason
	return false


func _flush_pending_settlement() -> bool:
	if _pending_save_reason == "":
		return true
	return _commit_settlement(_pending_save_reason)


func _clear_pending_settlement() -> void:
	_pending_save_reason = ""


func _notify_settlement_save_failure() -> void:
	if _save_failure_notified:
		return
	_save_failure_notified = true
	Global.add_message_show(self, "存档保存失败，请重试", 2.0, Vector2(470, 300))


func _begin_leave() -> bool:
	if _is_leaving:
		return false
	_is_leaving = true
	return true


func _abort_leave() -> void:
	_is_leaving = false


func _begin_rechallenge() -> bool:
	if _is_rechallenging:
		return false
	_is_rechallenging = true
	return true


func _abort_rechallenge() -> void:
	_is_rechallenging = false


func _request_scene_change(path: String) -> bool:
	if scene_change_override.is_valid():
		return bool(scene_change_override.call(path))
	return Global.change_scene(path)


func _reset_role_state_for_rechallenge() -> void:
	RoleProp.set_full_hp()
	RoleProp.set_full_mp()
	RoleProp.current_hp = int(RoleProp.roleprop.Hp)
	RoleProp.current_mp = int(RoleProp.roleprop.Mp)
	RoleProp.ws_value = 0
	RoleProp.is_ws_state = false
	Global.is_dead_link = false
