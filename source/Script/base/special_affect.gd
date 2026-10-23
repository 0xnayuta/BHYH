extends AnimatedSprite2D
@onready var special_effect: AnimatedSprite2D = $"."
@onready var effect_player: AnimationPlayer = $SpecialAffect
enum { do, remove }
var effect_name: String
var state = do
var effect_dir: bool
var effect_speed: float
var _scale


func _physics_process(_delta: float) -> void:
	match state:
		do:
			do_action(effect_name)
		remove:
			pass


func do_action(_name):
	effect_player.speed_scale = effect_speed
	special_effect.flip_h = effect_dir
	special_effect.scale = _scale
	var target_anim: StringName = &""
	if effect_player.has_animation(_name):
		target_anim = StringName(_name)
	else:
		var anims := effect_player.get_animation_list()
		for a in anims:
			if a != &"RESET":
				target_anim = a
				break
	if target_anim != &"":
		effect_player.play(target_anim)
		await effect_player.animation_finished
	state = remove
	queue_free()
