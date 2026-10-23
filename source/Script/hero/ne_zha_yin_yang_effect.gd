extends NeZhaSkillEffect
class_name NeZhaYinYangEffect

const SWORD_ATLAS_PATH := "res://Art/hero_picture/role_6/effects/yin_yang_swords.png"
const AURA_ATLAS_PATH := "res://Art/hero_picture/role_6/effects/yin_yang_aura.png"
const LAUNCH_ATLAS_PATH := "res://Art/hero_picture/role_6/effects/yin_yang_launch.png"
const SWORD_REGIONS := {
	"yin": Rect2(0, 0, 154, 53),
	"yang": Rect2(154, 0, 154, 53),
}
const SWORD_OFFSET := Vector2(-3.0, 1.0)
const SWORD_LIFETIME := 0.7
const SWORD_TRAVEL_DISTANCE := 909.0

var effect_kind: String = "yin"
var sword_type: String = "yin"


func _init() -> void:
	effect_animation = &"yinYang_sword"


func _ready() -> void:
	bullet_player.sprite_frames = _build_sprite_frames()
	super._ready()
	match effect_kind:
		"aura_toggle", "aura_yin", "aura_yang":
			bullet_player.position = Vector2(5.0, -12.0)
		"launch_yin", "launch_yang":
			bullet_player.position = Vector2(48.0, 0.0)
		_:
			bullet_player.position = SWORD_OFFSET


func _build_sprite_frames() -> SpriteFrames:
	match effect_kind:
		"aura_toggle":
			return _build_aura_frames(0, 8, &"yinYang_aura_toggle", false)
		"aura_yin":
			return _build_aura_frames(0, 4, &"yinYang_aura_yin", false)
		"aura_yang":
			return _build_aura_frames(4, 4, &"yinYang_aura_yang", false)
		"launch_yin":
			return _build_launch_frames(0)
		"launch_yang":
			return _build_launch_frames(6)
		_:
			return _build_sword_frames()


func _build_sword_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	frames.add_animation(&"yinYang_sword")
	frames.set_animation_speed(&"yinYang_sword", 1.0)
	frames.set_animation_loop(&"yinYang_sword", false)
	var sword_atlas := ResourceLoader.load(SWORD_ATLAS_PATH, "Texture2D", ResourceLoader.CACHE_MODE_REUSE) as Texture2D
	if sword_atlas == null:
		return frames
	var atlas_frame := AtlasTexture.new()
	atlas_frame.atlas = sword_atlas
	atlas_frame.region = SWORD_REGIONS.get(sword_type, SWORD_REGIONS["yin"])
	frames.add_frame(&"yinYang_sword", atlas_frame)
	return frames


func _build_aura_frames(start_index: int, frame_count: int, animation_name: StringName, loop: bool) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, 30.0)
	frames.set_animation_loop(animation_name, loop)
	var aura_atlas := ResourceLoader.load(AURA_ATLAS_PATH, "Texture2D", ResourceLoader.CACHE_MODE_REUSE) as Texture2D
	if aura_atlas == null:
		return frames
	for local_index in range(frame_count):
		var index := start_index + local_index
		var atlas_frame := AtlasTexture.new()
		atlas_frame.atlas = aura_atlas
		atlas_frame.region = Rect2((index % 4) * 300, floori(float(index) / 4.0) * 150, 300, 150)
		frames.add_frame(animation_name, atlas_frame, 2.0)
	return frames


func _build_launch_frames(start_index: int) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	frames.add_animation(&"yinYang_launch")
	frames.set_animation_speed(&"yinYang_launch", 30.0)
	frames.set_animation_loop(&"yinYang_launch", false)
	var launch_atlas := (
		ResourceLoader.load(LAUNCH_ATLAS_PATH, "Texture2D", ResourceLoader.CACHE_MODE_REUSE) as Texture2D
	)
	if launch_atlas == null:
		return frames
	var durations := [1.0, 1.0, 2.0, 2.0, 2.0, 2.0]
	for local_index in range(6):
		var index := start_index + local_index
		var atlas_frame := AtlasTexture.new()
		atlas_frame.atlas = launch_atlas
		atlas_frame.region = Rect2((index % 3) * 256, floori(float(index) / 3.0) * 180, 256, 180)
		frames.add_frame(&"yinYang_launch", atlas_frame, durations[local_index])
	return frames


func configure_yin_yang(
	source: BaseHero,
	hit_data: Dictionary,
	facing_right: bool,
	sword_kind: String = "yin",
	trajectory_angle: float = 0.0
) -> void:
	effect_kind = sword_kind
	sword_type = sword_kind
	configure(source, &"yinYang_sword", hit_data, facing_right, SWORD_LIFETIME, 0.0, 1, Vector2(154, 53))
	var speed := SWORD_TRAVEL_DISTANCE / SWORD_LIFETIME
	var travel_direction := Vector2.from_angle(trajectory_angle)
	if not facing_right:
		travel_direction.x = -travel_direction.x
	move_velocity = travel_direction * speed
	rotation = trajectory_angle if facing_right else -trajectory_angle


func configure_aura(source: BaseHero, facing_right: bool, aura_kind: String) -> void:
	effect_kind = aura_kind
	var animation_name := &"yinYang_aura_toggle"
	var duration := 0.667
	if aura_kind == "aura_yin":
		animation_name = &"yinYang_aura_yin"
		duration = 0.267
	elif aura_kind == "aura_yang":
		animation_name = &"yinYang_aura_yang"
		duration = 0.267
	configure(source, animation_name, {}, facing_right, duration, 0.0, 1, Vector2.ZERO)
	follow_target = source
	follow_target_facing = true


func configure_launch(source: BaseHero, facing_right: bool, launch_kind: String, trajectory_angle: float = 0.0) -> void:
	effect_kind = launch_kind
	configure(source, &"yinYang_launch", {}, facing_right, 11.0 / 30.0, 0.0, 1, Vector2.ZERO)
	rotation = trajectory_angle if facing_right else -trajectory_angle
