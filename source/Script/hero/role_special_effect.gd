extends Node2D
class_name RoleSpecialEffect

var player_data: PlayerDataStore:
	get:
		return LocalCoop.data_for(self)
var role_props: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self)
var owner_player: BaseHero = null

@onready var special_player: AnimationPlayer = $Middle/SpecialPlayer
@onready var middle: Node2D = $Middle
var skill_level: int = 1
var zznh_defense_reduction: float = 0.0
var role_list = []
var special_effect_name: String
var dir: bool
var is_set: bool
var myhccount: int
var monster_list = []
var cure_count: int = 0
var p_pl: BaseHero
var wiil_queue: bool
var _persistent_restart_queued := false
const JGZ_HALF_SIZE := Vector2(275.0, 175.0)
const JGZ_CENTER_OFFSET := Vector2(0.0, -29.0)


func _allows_role_special_control(target: Node) -> bool:
	return target != null and is_instance_valid(target) and bool(target.get_meta("allow_role_special_control", false))


func _is_summon_or_pet_target(target: Node) -> bool:
	if target == null or not is_instance_valid(target):
		return true
	if target.get_meta("pet_tiger_unit", false) or target.get_meta("is_summon", false):
		return true
	if target.has_method("get") and target.get("is_summon") == true:
		return true
	return false


func _can_control_monster(target: Node) -> bool:
	return (
		target is BaseMonster
		and is_instance_valid(target)
		and not target.is_control_immune()
		and not _is_summon_or_pet_target(target)
	)


func _exit_tree() -> void:
	var special_an := get_node_or_null("Middle/SpecialAN") as AnimatedSprite2D
	if special_an != null:
		special_an.sprite_frames = null


func _prepare_animation_material(animation_name: String) -> void:
	var special_an := get_node_or_null("Middle/SpecialAN") as CanvasItem
	if special_an == null or special_player == null or not special_player.has_animation(animation_name):
		return
	var animation := special_player.get_animation(animation_name)
	if animation == null:
		return
	for track_index in range(animation.get_track_count()):
		if animation.track_get_type(track_index) != Animation.TYPE_VALUE:
			continue
		if animation.track_get_path(track_index) != NodePath("SpecialAN:material"):
			continue
		if animation.track_get_key_count(track_index) <= 0:
			return
		var material = animation.track_get_key_value(track_index, 0)
		if material is Material:
			special_an.material = material
		return


func _physics_process(delta: float) -> void:
	if p_pl == null and get_parent() is BaseHero:
		p_pl = get_parent()
	cure_count += 1
	if not wiil_queue:
		if special_effect_name == "sd2":
			p_pl.is_sd_buff = true
	if not is_set:
		if dir:
			middle.scale.x = -1
		else:
			middle.scale.x = 1
		_prepare_animation_material(special_effect_name)
		special_player.play(special_effect_name)
		is_set = true

	if special_effect_name == "myhc":
		myhccount += 1
		if myhccount % 60 == 0:
			myhc_cure()

	if special_effect_name == "jgz":
		_apply_jgz_to_overlapping_bodies()
		for i in monster_list.duplicate():
			if not _can_control_monster(i):
				monster_list.erase(i)
				continue
			i.velocity.y = 0

	if special_effect_name == "zznh":
		var effect_owner: Node = p_pl if p_pl != null else get_parent()
		var monster_container: Node = effect_owner.get_parent().get_parent().monster
		var monster_count: int = monster_container.get_child_count()
		var monster_index := 0
		while monster_index < monster_count:
			var i = monster_container.get_child(monster_index)
			monster_index += 1
			if i != null:
				if _can_control_monster(i):
					i.velocity.y = 0

	if special_effect_name == "sd2":
		if cure_count % 60 == 0:
			role3_sd_cure()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is BaseHero:
		role_list.push_back(body)

	if special_effect_name == "jgz":
		_apply_jgz_to_monster(body)

	if special_effect_name == "zznh":
		if _can_control_monster(body):
			Global.add_buff(body.buff, _get_zznh_buff_info())


func _on_area_2d_body_exited(body: Node2D) -> void:
	if role_list.has(body):
		role_list.erase(body)


func _on_animation_player_animation_finished(anim_name: String):
	if anim_name == "tjgl":
		tjgl_cure()


func tjgl_cure():
	var player = get_parent().get_parent() as BaseHero

	var real_player = player
	if player is Role2Shallow and player.my_owner != null:
		real_player = player.my_owner

	for i in role_list:
		if i != null and is_instance_valid(i) and i is BaseHero:
			var level = player_data.player_data[DataKeys.SKILL_LEARNED]["技能4"][DataKeys.LEVEL] + 1
			var total_value = int(role_props.roleprop.SHp * 0.2)
			var cure_value = (
				0.6 * float(role_props.roleprop.SHp - role_props.roleprop.Hp) / float(role_props.roleprop.SHp) + 1
			)
			var heal_value = int(total_value * cure_value)
			var effective_heal = i.cure_hp(heal_value)

			if i == real_player and real_player is Role2Hero:
				var max_hp = role_props.roleprop.SHp
				var excess = heal_value - effective_heal
				if excess > 0:
					if real_player.shield_effect != null:
						real_player.shield_effect.queue_free()
					real_player.shield_effect = Global.add_role_special_effect(
						real_player, Vector2(0, 0), false, "tjgl_hd"
					)

					var old_hd = real_player.hd
					real_player.hd = min(real_player.hd + excess, max_hp)

					if real_player.shield_timer == null:
						real_player.shield_timer = Timer.new()
						real_player.add_child(real_player.shield_timer)
						real_player.shield_timer.one_shot = true
						real_player.shield_timer.connect("timeout", Callable(real_player, "_on_shield_timer_timeout"))
					real_player.refresh_tjgl_shield_timer()

					print("[护盾·唐僧] 水幻影天降甘露过量治疗 → 本体护盾 %d/%d" % [real_player.hd, max_hp])


func myhc_cure():
	for i in role_list:
		if i != null and is_instance_valid(i):
			if i is BaseHero:
				var level = player_data.player_data[DataKeys.SKILL_LEARNED]["技能7"][DataKeys.LEVEL] + 1
				var value = int(role_props.roleprop.SHp * randf_range(0.04, 0.05))
				i.cure_hp(value)


func _apply_jgz_to_overlapping_bodies() -> void:
	var area := get_node_or_null("Middle/Area2D") as Area2D
	if area != null:
		for body in area.get_overlapping_bodies():
			_apply_jgz_to_monster(body)
	var center := global_position + JGZ_CENTER_OFFSET
	for monster in _get_level_monsters():
		if _is_inside_jgz_rect(monster, center):
			_apply_jgz_to_monster(monster)


func _apply_jgz_to_monster(body: Node) -> void:
	if not _can_control_monster(body):
		return
	body.velocity.y = 0
	if monster_list.has(body):
		return
	monster_list.push_back(body)
	Global.add_buff(
		body.buff,
		{
			"Name": "jgz",
			"AddTime": 5 + (skill_level - 1) * 0.5,
			"reduce_interval": 0,
			"value": skill_level,
			"AttackKind": "",
			"CanAdd": false,
			"DeBuff": true
		}
	)
	if body.cannot_attract and not _allows_role_special_control(body):
		return
	body.is_jgz = true
	var tween = body.create_control_movement_tween()
	tween.tween_property(body, "global_position", global_position + Vector2(0, -120), 0.625)


func _get_level_monsters() -> Array:
	var result := []
	var scene := get_tree().current_scene
	if scene == null:
		return result
	for node in scene.find_children("*", "BaseMonster", true, false):
		if node is BaseMonster:
			result.append(node)
	return result


func _is_inside_jgz_rect(monster: BaseMonster, center: Vector2) -> bool:
	if monster == null or not is_instance_valid(monster) or monster.hp <= 0:
		return false
	var delta := monster.global_position - center
	return absf(delta.x) <= JGZ_HALF_SIZE.x and absf(delta.y) <= JGZ_HALF_SIZE.y


func add_role_3_cure_effect():
	var _player = get_parent()
	_player.my_sd.push_back(Global.add_role_special_effect(_player, Vector2(0, -20), false, "sd2"))


func add_role2_cure_effect():
	var _player = get_parent()
	_player.my_sd.push_back(Global.add_role_special_effect(_player, Vector2(0, -20), false, "tjgl"))


func move_monster_to_player():
	var _player = get_parent()
	var m_list = _player.get_parent().get_parent().monster.get_children()
	var valid_monsters = []

	for i in m_list:
		if _can_control_monster(i) and (not i.cannot_attract or _allows_role_special_control(i)):
			valid_monsters.append(i)
			if special_effect_name == "zznh":
				Global.add_buff(i.buff, _get_zznh_buff_info())

	if valid_monsters.size() == 0:
		return

	for i in valid_monsters:
		i.is_jgz = true
		var tween = i.create_control_movement_tween()
		tween.tween_property(i, "position", _player.position + Vector2(0, -110), 0.45)


func _get_zznh_buff_info() -> Dictionary:
	return {
		"Name": "zznh",
		"AddTime": 8 + (skill_level - 1) * 0.5,
		"reduce_interval": 0,
		"value": skill_level,
		"defense_reduction": zznh_defense_reduction,
		"AttackKind": "",
		"CanAdd": false,
		"DeBuff": true
	}


func role3_sd_cure():
	var _player = get_parent()
	if _player is Role3Hero:
		var cur_level = player_data.player_data[DataKeys.SKILL_LEARNED]["技能6"][DataKeys.LEVEL] + 1
		var cure_value = int(6 + role_props.roleprop.SHp * (0.004 + cur_level * 0.001))
		_player.cure_hp(cure_value)


func role_3_remove_buff():
	if bool(get_meta("persistent_sd", false)):
		wiil_queue = false
		return
	wiil_queue = true
	var _player = get_parent()
	if _player is Role3Hero:
		_player.is_sd_buff = false


func finish_effect() -> void:
	if bool(get_meta("persistent_sd", false)) and special_effect_name == "sd2":
		if _persistent_restart_queued:
			return
		_persistent_restart_queued = true
		call_deferred("_restart_persistent_effect")
		return
	queue_free()


func _restart_persistent_effect() -> void:
	_persistent_restart_queued = false
	if not is_inside_tree() or is_queued_for_deletion():
		return
	cure_count = 0
	wiil_queue = false
	is_set = true
	var special_an := get_node_or_null("Middle/SpecialAN") as AnimatedSprite2D
	if special_an != null:
		special_an.frame = 0
	special_player.stop()
	special_player.play(special_effect_name)
	special_player.seek(0.0, true)
