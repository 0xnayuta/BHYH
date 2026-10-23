extends MonsterBullet

const EFFECT_FPS := 24.0
const EFFECT_ROOT := "res://Art/monster/game_3_monster/monster_130/effects"
const PET_RABBIT_EFFECT_ROOT := "res://Art/pet/pet_rabbit/effects"
const EFFECT_COUNTS := {
	"monster_130_bullet_1": 11,
	"monster_130_bullet_2": 30,
	"monster_130_bullet_3": 30,
	"monster_130_bullet_4": 14,
}
const EFFECT_OFFSETS := {
	"monster_130_bullet_1": Vector2.ZERO,
	"monster_130_bullet_2": Vector2(9.0, -20.5),
	"monster_130_bullet_3": Vector2.ZERO,
	"monster_130_bullet_4": Vector2.ZERO,
}

static var _frames_cache: Dictionary = {}
var _elapsed := 0.0
var _gaze_applied := false


func _ready() -> void:
	set_meta("is_monster_bullet", true)
	get_prop()
	var frames := _get_effect_frames(skill_name)
	if frames.get_frame_count(skill_name) <= 0:
		queue_free()
		return
	bullet_ani.sprite_frames = frames
	bullet_ani.animation = skill_name
	bullet_ani.position = EFFECT_OFFSETS.get(skill_name, Vector2.ZERO)
	bullet_ani.play(skill_name)
	middle.scale.x = 1.0 if dir else -1.0
	_configure_hit_box()


static func _get_effect_frames(effect_name: String) -> SpriteFrames:
	if _frames_cache.has(effect_name):
		return _frames_cache[effect_name] as SpriteFrames
	var frames := SpriteFrames.new()
	frames.add_animation(effect_name)
	frames.set_animation_speed(effect_name, EFFECT_FPS)
	frames.set_animation_loop(effect_name, false)
	var count := int(EFFECT_COUNTS.get(effect_name, 0))
	var root := PET_RABBIT_EFFECT_ROOT if effect_name == "monster_130_bullet_2" else EFFECT_ROOT
	for frame_index in range(1, count + 1):
		var texture_path := root.path_join(effect_name).path_join(str(frame_index) + ".png")
		var texture := load(texture_path) as Texture2D
		if texture != null:
			frames.add_frame(effect_name, texture)
	_frames_cache[effect_name] = frames
	return frames


func _configure_hit_box() -> void:
	var hit_shape := get_node_or_null("middle/HitBox/Hit_Box") as CollisionShape2D
	if hit_shape == null:
		return
	if skill_name == "monster_130_bullet_1":
		var slash_shape := RectangleShape2D.new()
		slash_shape.size = Vector2(430, 55)
		hit_shape.shape = slash_shape
		hit_shape.disabled = false
		hit_box.monitoring = true
	elif skill_name == "monster_130_bullet_2":
		var moon_shape := RectangleShape2D.new()
		moon_shape.size = Vector2(120, 220)
		hit_shape.shape = moon_shape
		hit_shape.disabled = false
		hit_box.monitoring = true
	else:
		hit_shape.disabled = true
		hit_box.monitoring = false


func _physics_process(delta: float) -> void:
	_elapsed += delta
	var hit_shape := get_node_or_null("middle/HitBox/Hit_Box") as CollisionShape2D
	if hit_shape != null:
		if skill_name == "monster_130_bullet_1" and _elapsed >= 0.28:
			hit_shape.set_deferred("disabled", true)
		elif skill_name == "monster_130_bullet_2" and _elapsed >= 0.42:
			hit_shape.set_deferred("disabled", true)

	var lifetime := float(EFFECT_COUNTS.get(skill_name, 1)) / EFFECT_FPS + 0.05
	if skill_name == "monster_130_bullet_3":
		lifetime = float(get_meta("monster130_gaze_lifetime", lifetime))
		if not _gaze_applied and _elapsed >= lifetime:
			_gaze_applied = true
			if my_father != null and is_instance_valid(my_father) and my_father.has_method("_apply_gaze_control"):
				my_father.call("_apply_gaze_control")
			queue_free()
	elif _elapsed >= lifetime:
		queue_free()
