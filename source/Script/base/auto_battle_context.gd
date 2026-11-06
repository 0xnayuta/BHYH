class_name AutoBattleContext
extends RefCounted
## 自动战斗控制器与 BaseHero 的显式边界。
## 只做状态查询与受控命令，不持有节拍、目标缓存或技能游标；
## 控制器负责决策，BaseHero 保留实体、动作与公开战斗能力。

var _hero: BaseHero


func _init(hero: BaseHero) -> void:
	_hero = hero


func get_hero() -> BaseHero:
	return _hero


func is_enabled() -> bool:
	return MainSet.is_auto_battle_enabled()


func is_skill_only() -> bool:
	return bool(MainSet.set_data.get("AutoBattleSkillOnly", false))


func is_magic_weapon_enabled() -> bool:
	return bool(MainSet.set_data.get("AutoBattleMagicWeapon", false))


func is_sword_array_enabled() -> bool:
	return bool(MainSet.set_data.get("AutoBattleSwordArray", false))


func is_owner_queued_for_deletion() -> bool:
	return _hero.is_queued_for_deletion()


func is_dead() -> bool:
	return _hero.is_death


func has_current_scene() -> bool:
	if not _hero.is_inside_tree():
		return false
	var tree := _hero.get_tree()
	return tree != null and tree.current_scene != null


## 与原自动节拍相同的动作门禁：静默、施法、攻击或受击时暂停。
func is_action_blocked() -> bool:
	return _hero.is_silent or _hero.is_using_skills or _hero.is_attacking or _hero.is_be_attacking


## 控制类门禁：眩晕、冰冻、定身。
func is_control_blocked() -> bool:
	return _hero.is_stun or _hero.is_ice or _hero.is_immobilize


## 移动末段复检：只阻断攻击/施法，保持原实现顺序。
func is_combat_busy() -> bool:
	return _hero.is_attacking or _hero.is_be_attacking or _hero.is_using_skills


func is_auto_move_blocked() -> bool:
	return not _hero.no_limit_buff() or _hero.is_bound_to_the_ground


func is_on_floor() -> bool:
	return _hero.is_on_floor()


func is_facing_right() -> bool:
	return _hero.player_dir


func can_jump() -> bool:
	return (
		_hero.is_on_floor()
		and not _hero.is_bound_to_the_ground
		and not _hero.is_jump
		and not _hero.is_attacking
		and not _hero.is_be_attacking
		and not _hero.is_using_skills
	)


func get_position() -> Vector2:
	return _hero.global_position


func get_horizontal_distance(target: Node2D) -> float:
	return absf(target.global_position.x - _hero.global_position.x)


func get_vertical_distance(target: Node2D) -> float:
	return absf(target.global_position.y - _hero.global_position.y)


func get_auto_move_speed() -> float:
	return (
		float(_hero.walk_speed)
		* float(_hero.RoleProp.ws_up_power)
		* float(_hero.reverse_move_speed_multiplier)
		* float(_hero.mount_speed_multiplier)
	)


func set_velocity_x(value: float) -> void:
	_hero.velocity.x = value


func stop_horizontal() -> void:
	_hero.velocity.x = 0.0


func set_facing(direction: float) -> void:
	if direction > 0.0:
		_hero.action.scale.x = -1
		_hero.base_damagebox.scale.x = -1
		_hero.player_dir = true
	elif direction < 0.0:
		_hero.action.scale.x = 1
		_hero.base_damagebox.scale.x = 1
		_hero.player_dir = false


func set_idle() -> void:
	if _hero.get_action == "run":
		_hero.get_action = ""
	if _hero.is_on_floor() and not _hero.is_attacking and not _hero.is_using_skills:
		_hero._play_locomotion_animation(&"wait")


func play_run() -> void:
	if not _hero.is_on_floor():
		return
	_hero._play_locomotion_animation(&"run")
	_hero.get_action = "run"


func jump() -> void:
	_hero.jump(false)


func is_blocked_ahead(direction: float) -> bool:
	if not _hero.is_on_floor() or direction == 0.0:
		return false
	var has_obstacle_collision := false
	var has_slide_collision := false
	for index in range(_hero.get_slide_collision_count()):
		var collision: KinematicCollision2D = _hero.get_slide_collision(index)
		if collision == null:
			continue
		has_slide_collision = true
		var slide_collider: Variant = collision.get_collider()
		if slide_collider is Node and _find_monster(slide_collider as Node) != null:
			continue
		var normal: Vector2 = collision.get_normal()
		if direction > 0.0 and normal.x < -0.25:
			has_obstacle_collision = true
		if direction < 0.0 and normal.x > 0.25:
			has_obstacle_collision = true
	if has_obstacle_collision or (not has_slide_collision and _hero.is_on_wall()):
		return true

	var space_state: PhysicsDirectSpaceState2D = _hero.get_world_2d().direct_space_state
	if space_state == null:
		return false
	var ray_start: Vector2 = _hero.global_position + Vector2(0.0, -28.0)
	var ray_end: Vector2 = ray_start + Vector2(direction * 36.0, 0.0)
	var query := PhysicsRayQueryParameters2D.create(ray_start, ray_end, _hero.collision_mask, [_hero.get_rid()])
	var hit: Dictionary = space_state.intersect_ray(query)
	if hit.is_empty():
		return false
	var collider: Variant = hit.get("collider")
	if collider is Node:
		var monster := _find_monster(collider as Node)
		if monster != null:
			return false
	return true


func get_target_candidates() -> Array:
	var candidates: Array = []
	var current_scene := _hero.get_tree().current_scene
	if current_scene != null and current_scene.has_method("get_active_monsters"):
		var active_monsters: Variant = current_scene.call("get_active_monsters")
		if active_monsters is Array:
			candidates = active_monsters
	if candidates.is_empty():
		candidates = _hero.get_tree().get_nodes_in_group("monsters")
	return candidates


func is_target_valid(target: Variant) -> bool:
	return _hero.is_auto_battle_target_valid(target)


func get_skill_entries() -> Array[Dictionary]:
	var role_id := int(_hero.PlayerData.player_data.get("Myself", 1))
	if role_id < 1 or role_id > 8:
		role_id = 1
	var role_key := "角色" + str(role_id)
	var slot := int(_hero.get_meta("coop_slot", 1))
	var by_slot_value: Variant = MainSet.set_data.get("AutoBattleSkillsBySlot", {})
	if by_slot_value is Dictionary:
		var slot_skills: Variant = (by_slot_value as Dictionary).get(str(slot), {})
		if slot_skills is Dictionary and (slot_skills as Dictionary).has(role_key):
			return _normalize_skill_entries((slot_skills as Dictionary).get(role_key, []))
	var by_role_value: Variant = MainSet.set_data.get("AutoBattleSkillsByRole", {})
	if by_role_value is Dictionary and (by_role_value as Dictionary).has(role_key):
		var role_skills: Variant = (by_role_value as Dictionary).get(role_key, [])
		return _normalize_skill_entries(role_skills)
	var legacy_skills: Variant = MainSet.set_data.get("AutoBattleSkills", [])
	return _normalize_skill_entries(legacy_skills)


func _normalize_skill_entries(raw_value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not raw_value is Array:
		return result
	var seen: Dictionary = {}
	for value in raw_value:
		var skill_id := ""
		var count := 1
		if value is Dictionary:
			var entry: Dictionary = value
			skill_id = str(entry.get("id", entry.get("skill_id", "")))
			count = clampi(int(entry.get("count", 1)), 1, 99)
		else:
			skill_id = str(value)
		if skill_id == "" or seen.has(skill_id):
			continue
		seen[skill_id] = true
		result.append({"id": skill_id, "count": count})
	return result


func can_use_skill(skill_id: String) -> bool:
	if skill_id == "" or not _hero.role1_skill_inter.has(skill_id):
		return false
	if float(_hero.role1_skill_inter.get(skill_id, 0.0)) > 0.0:
		return false
	if not _hero.has_method("get_need_mp"):
		return false
	var need_mp := int(_hero.get_need_mp(skill_id, false))
	return int(_hero.RoleProp.roleprop.Mp) >= need_mp


func is_skill_active(skill_id: String) -> bool:
	return _hero.is_auto_battle_skill_active(skill_id)


## 调用 get_skill 并用冷却/MP/动作/施法态变化判断是否真正起手。
func cast_skill(skill_id: String) -> bool:
	if not _hero.is_inside_tree() or _hero.get_tree().current_scene == null:
		return false
	var mp_before := int(_hero.RoleProp.roleprop.Mp)
	var cooldown_before := float(_hero.role1_skill_inter.get(skill_id, 0.0))
	var action_before: String = str(_hero.get_action)
	var using_skill_before: bool = _hero.is_using_skills
	_hero.get_skill(skill_id)
	var cooldown_after := float(_hero.role1_skill_inter.get(skill_id, 0.0))
	return (
		cooldown_after > cooldown_before + 0.001
		or int(_hero.RoleProp.roleprop.Mp) < mp_before
		or _hero.is_using_skills != using_skill_before
		or _hero.get_action != action_before
	)


func try_use_magic_weapon() -> bool:
	var target: Variant = _hero.get_magic_weapon_target()
	if target == null or not is_instance_valid(target) or target.is_queued_for_deletion():
		return false
	if _is_magic_weapon_disabled_in_current_level():
		return false
	if bool(target.get("is_use")) or not bool(target.get("is_canuse")):
		return false
	if not target is GhostDoll and not _hero.no_limit_buff():
		return false
	_hero.use_fb()
	return bool(target.get("is_use"))


func _is_magic_weapon_disabled_in_current_level() -> bool:
	var scene_parent := _hero.get_parent()
	if scene_parent == null:
		return false
	var level := scene_parent.get_parent()
	return level is Level17 or level is Level22


func can_use_sword_array() -> bool:
	return _hero.zhen_fa_cd <= 0


func use_sword_array() -> bool:
	return _hero._try_use_main_sword_array()


func try_activate_wushuang() -> bool:
	if not bool(MainSet.set_data.get("AutoBattleWushuang", false)):
		return false
	if _hero.RoleProp.is_ws_state or _hero.RoleProp.ws_value < _hero.RoleProp.max_ws_value:
		return false
	if not _hero.ws_skill():
		return false
	_hero.RoleProp.is_ws_state = true
	return true


func _find_monster(node: Node) -> BaseMonster:
	var current := node
	var depth := 0
	while current != null and is_instance_valid(current) and depth < 8:
		if current is BaseMonster:
			return current as BaseMonster
		current = current.get_parent()
		depth += 1
	return null
