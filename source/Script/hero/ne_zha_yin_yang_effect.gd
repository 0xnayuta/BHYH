extends NeZhaSkillEffect
class_name NeZhaYinYangEffect

const SWORD_YIN_FRAMES_PATH := "res://Art/hero_picture/role_6/effects/nezha_yin_yang_sword_yin_frames.tres"
const SWORD_YANG_FRAMES_PATH := "res://Art/hero_picture/role_6/effects/nezha_yin_yang_sword_yang_frames.tres"
const AURA_FRAMES_PATH := "res://Art/hero_picture/role_6/effects/nezha_yin_yang_aura_frames.tres"
const LAUNCH_YIN_FRAMES_PATH := "res://Art/hero_picture/role_6/effects/nezha_yin_yang_launch_yin_frames.tres"
const LAUNCH_YANG_FRAMES_PATH := "res://Art/hero_picture/role_6/effects/nezha_yin_yang_launch_yang_frames.tres"
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
		"aura_toggle", "aura_yin", "aura_yang":
			return _load_frames(AURA_FRAMES_PATH)
		"launch_yin":
			return _load_frames(LAUNCH_YIN_FRAMES_PATH)
		"launch_yang":
			return _load_frames(LAUNCH_YANG_FRAMES_PATH)
		_:
			return _load_frames(SWORD_YIN_FRAMES_PATH if sword_type == "yin" else SWORD_YANG_FRAMES_PATH)


func _load_frames(path: String) -> SpriteFrames:
	var frames := load(path) as SpriteFrames
	if frames == null:
		push_error("NeZhaYinYangEffect: 构建期帧资源缺失: " + path)
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
