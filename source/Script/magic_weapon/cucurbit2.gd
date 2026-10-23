extends BaseMagicWeapon
class_name Cucurbit2
var add_time: float
var add_bl: float = 1


func _physics_process(delta: float) -> void:
	self.fb_level = PlayerData.get_most_level("xhhl") + 1
	need_mp = 50 + self.fb_level * 5
	if PlayerData.check_have_wx("xhhl", "木"):
		add_time = self.fb_level * 0.1 + 3
	else:
		add_time = 3

	super._physics_process(delta)
	if not is_use:
		mg_player.play("wait")


func show_skill():
	mg_player.play("hit")
	await mg_player.animation_finished
	use_over()


func use_over():
	self.usecd = 5
	fb_cd = 1
	is_use = false
	skill_cd.start(5)


func move_monster_and_add_buff():
	var level_father = player.get_parent().get_parent()
	if not level_father is BaseLevel:
		return
	var monster_list = level_father.monster.get_children()
	for i in monster_list:
		if i != null:
			if i is BaseMonster:
				if i.is_control_immune() or i.cannot_attract:
					continue
				var tween = i.create_control_movement_tween()
				tween.tween_property(i, "position", player.position + Vector2(0, -50), 0.5)
				i.hurt_bl = add_bl
				i.remove_hurt_bl.start(add_time)

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
