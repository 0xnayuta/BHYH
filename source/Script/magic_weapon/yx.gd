extends BaseMagicWeapon
class_name Yx

var add_time: float
var add_bl: float = 1
var cooldown_time: float = 20

var original_body_color: Color = Color.WHITE
var original_equipment_color: Color = Color.WHITE
var is_colored: bool = false


func _physics_process(delta: float) -> void:
	self.fb_level = PlayerData.get_most_level("yx")
	need_mp = 50 + self.fb_level * 5

	add_time = 10
	cooldown_time = 20

	if PlayerData.check_have_wx("yx", "木"):
		add_time += self.fb_level * 0.25
		cooldown_time -= self.fb_level * 0.25
		if cooldown_time < add_time + 1:
			cooldown_time = add_time + 1

	super._physics_process(delta)
	if not is_use:
		mg_player.play("wait")


func show_skill():
	mg_player.play("hit")

	var base_level = self.fb_level
	var max_level = 10
	var percentage_rate = 0.2 + (0.3 * min(base_level, max_level) / max_level)

	if player != null:
		Global.add_buff(
			player.buff,
			{
				"Name": "yxbuff",
				"AddTime": add_time,
				"reduce_interval": 0,
				"value": percentage_rate,
				"AttackKind": "",
				"CanRemove": true,
				"CanAdd": false,
				"DeBuff": false
			}
		)

		var role_body = player.get_node_or_null("Action/RoleBody")
		var role_equipment = player.get_node_or_null("Action/RoleEquipment")

		if role_body and role_equipment:
			if not is_colored:
				original_body_color = role_body.modulate
				original_equipment_color = role_equipment.modulate

			var base_hsv_color = Color.from_hsv(0.78, 0.5, 1, 1)

			role_body.modulate = base_hsv_color
			role_equipment.modulate = base_hsv_color
			is_colored = true

			if player.has_meta("magic_pulse_tween"):
				var old_tween = player.get_meta("magic_pulse_tween")
				if old_tween:
					old_tween.kill()

			var restore_timer = get_tree().create_timer(add_time)
			restore_timer.timeout.connect(func(): _restore_role_colors(role_body, role_equipment))
		else:
			print("警告：找不到角色身体或装备节点")

	await mg_player.animation_finished
	use_over()


func _restore_role_colors(body_node, equipment_node):
	if body_node and equipment_node and is_colored:
		if player and player.has_meta("magic_pulse_tween"):
			var pulse_tween = player.get_meta("magic_pulse_tween")
			if pulse_tween:
				pulse_tween.kill()
			player.remove_meta("magic_pulse_tween")

		body_node.modulate = original_body_color
		equipment_node.modulate = original_equipment_color
		is_colored = false


func use_over():
	self.usecd = cooldown_time
	fb_cd = 1
	is_use = false
	skill_cd.start(cooldown_time)

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
