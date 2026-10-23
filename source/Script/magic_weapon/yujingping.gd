extends BaseMagicWeapon
class_name Yujingping


func _physics_process(delta: float) -> void:
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

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
