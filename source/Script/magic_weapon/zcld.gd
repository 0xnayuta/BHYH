extends BaseMagicWeapon
class_name Zcld

var is_zcld = true


func _ready():
	fb_level = PlayerData.get_most_level("zcld")


func _physics_process(delta: float) -> void:
	fb_level = PlayerData.get_most_level("zcld")
	super._physics_process(delta)
	if not is_use:
		mg_player.play("wait")


func use_skill():
	use_over()
