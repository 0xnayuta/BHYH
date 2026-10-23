extends RefCounted
class_name CoopInput

var slot := 1
var session: Node


func action_name(action: StringName) -> StringName:
	return StringName("p2_" + str(action)) if slot == 2 and session.is_enabled() else action


func is_action_pressed(action: StringName, exact_match := false) -> bool:
	return Input.is_action_pressed(action_name(action), exact_match)


func is_action_just_pressed(action: StringName, exact_match := false) -> bool:
	return Input.is_action_just_pressed(action_name(action), exact_match)


func is_action_just_released(action: StringName, exact_match := false) -> bool:
	return Input.is_action_just_released(action_name(action), exact_match)


func get_axis(negative: StringName, positive: StringName) -> float:
	return Input.get_axis(action_name(negative), action_name(positive))


func is_physical_key_pressed(key: Key) -> bool:
	if slot != 2 or not session.is_enabled():
		return Input.is_physical_key_pressed(key)
	var replacements := {
		KEY_W: KEY_UP,
		KEY_A: KEY_LEFT,
		KEY_S: KEY_DOWN,
		KEY_D: KEY_RIGHT,
		KEY_J: KEY_KP_1,
		KEY_K: KEY_KP_2,
		KEY_Z: KEY_KP_DIVIDE,
	}
	return Input.is_physical_key_pressed(replacements.get(key, key))


func is_key_pressed(key: Key) -> bool:
	return is_physical_key_pressed(key)
