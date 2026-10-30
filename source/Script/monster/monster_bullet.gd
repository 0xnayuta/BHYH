extends Node2D
class_name MonsterBullet
var _pet_tiger_hit_rect_shape: RectangleShape2D
@onready var bullet_player: AnimationPlayer = $BulletPlayer
@onready var bullet_ani: AnimatedSprite2D = $middle/BulletANI
@onready var hit_box: Area2D = $middle/HitBox
@onready var queue_timer: Timer = $queue_timer
@onready var is_throw_close: Timer = $IsThrowClose

var bounce_velocity: Vector2 = Vector2.ZERO
var is_exploding: bool = false
var monster1410_life_left: float = -1.0
static var active_1410_bullets: Array[Node] = []

var clone_spawned: bool = false

enum { do, remove }
enum RuntimeKind {
	NORMAL,
	MONSTER_5,
	PET_TIGER,
	PET_DRAGON,
	PET_PHOENIX,
	MONSTER_1410,
	MONSTER_90,
	MONSTER_101_2,
	MONSTER_1407_5,
}
var can_cure: bool
var is_throw: bool
var throw_count: int = 0
var level = 0
var def = 0
var mdef = 0
var crit = 0
var miss = 0
var lucky = 0
var htarget = 0
var toughness = 0
var ar = 0
var sp = 0
var crit_reduce = 0
var att_list
var obj_attack_dict = {}
var skill_name: String
var _runtime_skill_name: String = ""
var _runtime_kind: RuntimeKind = RuntimeKind.NORMAL
var state = do
var dir: bool
var speed: float
var bullet_name
var hit
var attack_kind
var hurt_back
var hit_name
var total_hit = 0
var show_monster71: bool
var fly_speed: float = 0
var count: int = 0
@onready var middle: Node2D = $middle
var is_set: bool
var player_position
var my_father: BaseMonster
var pet_tiger_layer_sprites: Array[Sprite2D] = []
var pet_tiger_last_frame: int = -1
var monster5_stream_sprite: Sprite2D
var monster5_stream_frame: int = -1
var monster5_stream_time: float = 0.0
var monster5_stream_texture: Texture2D
var monster5_stream_sheet: Texture2D
var monster5_stream_sheet_index: int = -1
var monster5_stream_uploaded_sheet_index: int = -1
var monster_atlas_frames_sprite: Sprite2D
var monster_atlas_frames: SpriteFrames
var monster_atlas_frames_animation: StringName = &""
var pet_phoenix_hold_last_elapsed: float = 0.0
static var pet_dragon_texture_cache: Dictionary = {}
static var pet_bullet_frames_cache: Dictionary = {}
static var pet_tiger_timeline_cache: Dictionary = {}
static var _pet_tiger_effects_frames: SpriteFrames = null
static var pet_phoenix_frames_cache: Dictionary = {}
static var _pet_phoenix_effects_frames: SpriteFrames = null
static var _pet_dragon_effects_frames: SpriteFrames = null
static var pet_phoenix_frame_used_rect_cache: Dictionary = {}
static var monster5_stream_image_cache: Dictionary = {}
static var _runtime_cache_generation := 0


static func clear_runtime_resource_caches() -> void:
	_runtime_cache_generation += 1
	pet_dragon_texture_cache.clear()
	pet_bullet_frames_cache.clear()
	pet_tiger_timeline_cache.clear()
	_pet_tiger_effects_frames = null
	pet_phoenix_frames_cache.clear()
	_pet_phoenix_effects_frames = null
	_pet_dragon_effects_frames = null
	pet_phoenix_frame_used_rect_cache.clear()
	monster5_stream_image_cache.clear()


const PET_TIGER_BULLET_FPS := 24.0
const PET_TIGER_EFFECTS_RES := "res://Art/monster/pet_tiger_boss/effects/pet_tiger_effects.tres"
const PET_TIGER_LAYER_ANIMATIONS: Dictionary[int, StringName] = {
	5: &"shape6_bitmap5",
	9: &"shape10_bitmap9",
	12: &"shape13_bitmap12",
	15: &"shape16_bitmap15",
	18: &"shape19_bitmap18",
	21: &"shape22_bitmap21",
	24: &"shape25_bitmap24",
	27: &"shape28_bitmap27",
	30: &"shape31_bitmap30",
	35: &"shape36_bitmap35",
	38: &"shape39_bitmap38",
	43: &"shape44_bitmap43",
	47: &"shape48_bitmap47",
	50: &"shape51_bitmap50",
	54: &"shape55_bitmap54",
	58: &"shape59_bitmap58",
	60: &"shape61_bitmap60",
	62: &"shape63_bitmap62",
	64: &"shape65_bitmap64",
	66: &"shape67_bitmap66",
	68: &"shape69_bitmap68",
	70: &"shape71_bitmap70",
	72: &"shape73_bitmap72",
	77: &"shape78_bitmap77",
}
const PET_DRAGON_EFFECTS_RES := "res://Art/pet/pet_dragon/effects/pet_dragon_effects.tres"
const PET_PHOENIX_EFFECTS_RES := "res://Art/pet/pet_phoenix/effects/pet_phoenix_effects.tres"
const PET_DRAGON_DASH_DAMAGE_INTERVAL_MS := 120
const PET_DRAGON_KNOCKBACK_LOCK_TIME := 0.16
const PET_DRAGON_ULTIMATE_OFFSETS := [
	Vector2(-6.5, 0.5),
	Vector2(-3.5, 0.5),
	Vector2(0.0, 0.5),
	Vector2(-0.5, 0.5),
	Vector2(-0.5, 0.5),
	Vector2(0.0, -0.5),
	Vector2(-0.5, -0.5),
	Vector2(-0.5, -0.5),
	Vector2(-0.5, -0.5),
	Vector2(-0.5, -0.5),
	Vector2(-2.0, -0.5),
	Vector2(-1.0, -0.5),
	Vector2(-2.0, -0.5),
	Vector2(0.0, -0.5),
	Vector2(-0.5, -0.5),
	Vector2(-6.5, 0.5),
	Vector2(-3.5, 0.5),
	Vector2(0.0, 0.5),
	Vector2(-0.5, 0.5),
	Vector2(-0.5, 0.5),
	Vector2(0.0, -0.5),
	Vector2(-0.5, -0.5),
	Vector2(-0.5, -0.5),
	Vector2(-0.5, -0.5),
	Vector2(-0.5, -0.5),
	Vector2(-2.0, -0.5),
	Vector2(-1.0, -0.5),
	Vector2(-2.0, -0.5),
	Vector2(0.0, -0.5),
	Vector2(-0.5, -0.5),
	Vector2(-6.5, 0.5),
	Vector2(-3.5, 0.5),
	Vector2(0.0, 0.5),
	Vector2(-0.5, 0.5),
	Vector2(-0.5, 0.5),
	Vector2(0.0, -0.5),
	Vector2(-0.5, -0.5),
	Vector2(-0.5, -0.5),
	Vector2(-0.5, -0.5),
	Vector2(-0.5, -0.5),
	Vector2(-2.0, -0.5),
	Vector2(-1.0, -0.5),
	Vector2(-2.0, -0.5),
	Vector2(0.0, -0.5),
	Vector2(-0.5, -0.5),
	Vector2(-6.5, 0.5),
	Vector2(-3.5, 0.5),
	Vector2(0.0, 0.5)
]


static func warm_pet_dragon_ultimate_frames() -> void:
	var tree := Engine.get_main_loop() as SceneTree
	var frames := _pet_dragon_effects()
	if frames == null:
		push_error("Pet dragon standard frames missing: " + PET_DRAGON_EFFECTS_RES)
		return
	# 终极帧来源为构建期 PetDragonBullet4Cropped 序列，运行时只按帧计数请求纹理。
	for frame_index in range(frames.get_frame_count(&"PetDragonBullet4Cropped")):
		var texture := frames.get_frame_texture(&"PetDragonBullet4Cropped", frame_index)
		if texture != null:
			pet_dragon_texture_cache[texture] = texture
		if tree != null:
			await tree.process_frame


const MONSTER5_BULLET_FPS := 25.0
const MONSTER5_BULLET_FRAME_COUNT := 40
const MONSTER5_BULLET_FRAME_SIZE := Vector2(1219, 609)
const MONSTER5_BULLET_DIR := "res://Art/monster/monster_5"
const MONSTER5_BULLET_SHEETS: Array[Texture2D] = [
	preload("res://Art/monster/monster_5/special_effect2_0.png"),
	preload("res://Art/monster/monster_5/special_effect2_1.png"),
	preload("res://Art/monster/monster_5/special_effect2_2.png"),
	preload("res://Art/monster/monster_5/special_effect2_3.png"),
	preload("res://Art/monster/monster_5/special_effect2_4.png"),
	preload("res://Art/monster/monster_5/special_effect2_5.png"),
	preload("res://Art/monster/monster_5/special_effect2_6.png"),
	preload("res://Art/monster/monster_5/special_effect2_7.png"),
	preload("res://Art/monster/monster_5/special_effect2_8.png"),
	preload("res://Art/monster/monster_5/special_effect2_9.png"),
	preload("res://Art/monster/monster_5/special_effect2_10.png"),
	preload("res://Art/monster/monster_5/special_effect2_11.png"),
]
const STANDARD_BULLET_FRAMES := {
	"Monster_61Bullet":
	[
		"res://Art/monster/monster_61_00/skill_3_effect_2/atlas/skill_3_effect_2_frames.tres",
		"Monster_61Bullet",
	],
	"Monster114Bullet3":
	[
		"res://Art/monster/game_3_special_effect/monster_5/atlas/monster_114_bullet_3/monster_114_bullet_3_frames.tres",
		"Monster114Bullet3",
	],
	"Monster18Bullet_2":
	[
		"res://Art/monster/monster_18/bullet/atlas/monster_18_bullet_2/monster_18_bullet_2_frames.tres",
		"Monster18Bullet_2",
	],
	"Monster103Bullet1":
	[
		"res://Art/monster/game_3_special_effect/monster_4/atlas/monster_103_bullet_1/monster_103_bullet_1_frames.tres",
		"Monster103Bullet1",
	],
	"Monster61Bullet3":
	[
		"res://Art/monster/monster_61/atlas/monster_61_bullet_3/monster_61_bullet_3_frames.tres",
		"Monster61bull3",
	],
}

var pet_dragon_dash_damage_until: Dictionary = {}
var pet_tiger_timeline: Array = []


func _exit_tree() -> void:
	if bullet_ani != null and is_instance_valid(bullet_ani):
		bullet_ani.stop()
		bullet_ani.sprite_frames = null
	if monster5_stream_sprite != null and is_instance_valid(monster5_stream_sprite):
		monster5_stream_sprite.texture = null
	monster5_stream_texture = null
	monster5_stream_sheet = null
	monster5_stream_sheet_index = -1
	monster5_stream_uploaded_sheet_index = -1
	if monster_atlas_frames_sprite != null and is_instance_valid(monster_atlas_frames_sprite):
		monster_atlas_frames_sprite.texture = null
	monster_atlas_frames_sprite = null
	monster_atlas_frames = null
	monster_atlas_frames_animation = &""
	for sprite in pet_tiger_layer_sprites:
		if is_instance_valid(sprite):
			sprite.texture = null
	pet_tiger_layer_sprites.clear()
	if active_1410_bullets.has(self):
		active_1410_bullets.erase(self)


func _ensure_timer_signals() -> void:
	if queue_timer != null and not queue_timer.timeout.is_connected(_on_queue_timer_timeout):
		queue_timer.timeout.connect(_on_queue_timer_timeout)
	if is_throw_close != null and not is_throw_close.timeout.is_connected(_on_is_throw_close_timeout):
		is_throw_close.timeout.connect(_on_is_throw_close_timeout)


func _get_cached_pet_tiger_timeline(_name: String) -> Array:
	if not pet_tiger_timeline_cache.has(_name):
		pet_tiger_timeline_cache[_name] = _pet_tiger_bullet_timeline(_name)
	return pet_tiger_timeline_cache[_name] as Array


func _get_cached_pet_bullet_frames(_name: String, frame_count: int, is_dragon: bool) -> SpriteFrames:
	var standard := _pet_dragon_effects() if is_dragon else _pet_tiger_effects()
	if standard != null and standard.has_animation(_name):
		return standard
	var cache_key := ("dragon:" if is_dragon else "tiger:") + _name
	if pet_bullet_frames_cache.has(cache_key):
		return pet_bullet_frames_cache[cache_key] as SpriteFrames
	if frame_count <= 0:
		push_error("Pet bullet standard frames missing and no declared timeline: " + _name)
		return null
	# 标准帧缺失时按已声明的时间轴长度生成纯计时 SpriteFrames；
	# 可见画面由图层timeline负责，本资源只提供帧时钟，不拼帧路径。
	var clock := SpriteFrames.new()
	clock.add_animation(_name)
	clock.set_animation_loop(_name, false)
	clock.set_animation_speed(_name, PET_TIGER_BULLET_FPS)
	for _frame_index in range(frame_count):
		clock.add_frame(_name, null)
	pet_bullet_frames_cache[cache_key] = clock
	return clock


static func _pet_tiger_effects() -> SpriteFrames:
	if _pet_tiger_effects_frames == null:
		_pet_tiger_effects_frames = load(PET_TIGER_EFFECTS_RES) as SpriteFrames
	return _pet_tiger_effects_frames


func _get_pet_tiger_layer_texture(layer_id: int) -> Texture2D:
	var effects := _pet_tiger_effects()
	if effects == null:
		return null
	var animation: StringName = PET_TIGER_LAYER_ANIMATIONS.get(layer_id, &"")
	if animation == &"" or not effects.has_animation(animation):
		return null
	return effects.get_frame_texture(animation, 0)


static func warm_monster5_stream_images() -> void:
	if _has_all_monster5_stream_images():
		return
	for sheet_index in range(12):
		var path := "%s/SpecialEffect2-%d.png" % [MONSTER5_BULLET_DIR, sheet_index]
		var texture := MONSTER5_BULLET_SHEETS[sheet_index]
		if texture != null:
			monster5_stream_image_cache[path] = texture


static func _has_all_monster5_stream_images() -> bool:
	for sheet_index in range(12):
		var path := "%s/SpecialEffect2-%d.png" % [MONSTER5_BULLET_DIR, sheet_index]
		if not monster5_stream_image_cache.has(path):
			return false
	return true


static func wait_for_monster5_stream_images() -> void:
	warm_monster5_stream_images()


static func warm_pet_dragon_textures(stage: int = 4) -> void:
	var tree := Engine.get_main_loop() as SceneTree
	if _pet_dragon_effects() != null:
		if tree != null:
			await tree.process_frame
		return
	stage = clampi(stage, 1, 4)
	# 帧来源由构建期 pet_dragon_effects.tres 提供，运行时只取帧纹理，不扫描目录。
	var frames := _pet_dragon_effects()
	if frames == null:
		push_error("Pet dragon standard frames missing: " + PET_DRAGON_EFFECTS_RES)
		return
	for effect_name in _pet_dragon_effect_names(stage):
		if not frames.has_animation(effect_name):
			continue
		for frame_index in range(frames.get_frame_count(effect_name)):
			var texture := frames.get_frame_texture(effect_name, frame_index)
			if texture != null:
				pet_dragon_texture_cache[texture] = texture
		if tree != null:
			await tree.process_frame


static func warm_pet_dragon_dash_textures() -> void:
	var frames := _pet_dragon_effects()
	if frames == null:
		push_error("Pet dragon standard frames missing: " + PET_DRAGON_EFFECTS_RES)
		return
	for frame_index in range(frames.get_frame_count(&"PetDragon2Bullet2")):
		var texture := frames.get_frame_texture(&"PetDragon2Bullet2", frame_index)
		if texture != null:
			pet_dragon_texture_cache[texture] = texture


static func _pet_dragon_clock_frame_count(_name: String) -> int:
	var frames := _pet_dragon_effects()
	if frames != null and frames.has_animation(_name):
		return frames.get_frame_count(_name)
	push_error("Pet dragon standard frames missing: " + _name)
	return 0


func _pet_tiger_layer(
	id_: int, x_: float, y_: float, sx_: float = 1.0, sy_: float = 1.0, rot_: float = 0.0
) -> Dictionary:
	return {"id": id_, "x": x_, "y": y_, "sx": sx_, "sy": sy_, "rot": rot_}


func _pet_tiger_bullet_timeline(_name: String) -> Array:
	match _name:
		"PetTiger1Bullet1":
			return [
				[_pet_tiger_layer(54, 0.0, 0.0)],
				[_pet_tiger_layer(54, -5.55, 0.15)],
				[_pet_tiger_layer(54, -11.05, 0.3)],
				[_pet_tiger_layer(54, -16.6, 0.45)],
				[_pet_tiger_layer(54, -22.15, 0.55)],
				[_pet_tiger_layer(54, -27.65, 0.7)],
				[_pet_tiger_layer(54, -33.2, 0.85)],
				[_pet_tiger_layer(54, -39.45, 1.0)],
				[_pet_tiger_layer(54, -45.7, 1.15)],
				[_pet_tiger_layer(54, -51.95, 1.3)],
				[],
				[],
				[],
				[],
				[]
			]
		"PetTiger1Bullet2":
			return [
				[_pet_tiger_layer(47, 64.45, -24.35)],
				[_pet_tiger_layer(47, 64.45, -24.35)],
				[_pet_tiger_layer(47, 65.55, 31.45, 0.7638, 0.7638, 0.2618)],
				[_pet_tiger_layer(47, 65.55, 31.45, 0.7638, 0.7638, 0.2618)],
				[_pet_tiger_layer(47, 54.9, 34.55, 0.6576, 0.6576, 0.2618)],
				[_pet_tiger_layer(47, 54.9, 34.55, 0.6576, 0.6576, 0.2618)],
				[_pet_tiger_layer(47, 42.35, 38.95, 0.6576, 0.6576, 0.2618), _pet_tiger_layer(50, 41.6, 42.95)],
				[_pet_tiger_layer(47, 42.35, 38.95, 0.6576, 0.6576, 0.2618), _pet_tiger_layer(50, 41.6, 42.95)],
				[_pet_tiger_layer(50, 32.35, 50.25, 0.806, 0.806)],
				[_pet_tiger_layer(50, 32.35, 50.25, 0.806, 0.806)],
				[_pet_tiger_layer(50, 6.8, 51.95, 0.7661, 0.7661)],
				[_pet_tiger_layer(50, 6.8, 51.95, 0.7661, 0.7661)],
				[],
				[],
				[],
				[],
				[],
				[],
				[],
				[]
			]
		"PetTiger2Bullet1":
			return [
				[_pet_tiger_layer(43, 0.0, 0.0)],
				[_pet_tiger_layer(43, 0.0, 0.0)],
				[_pet_tiger_layer(43, -0.15, 19.05, 0.851, 0.851, 0.0867)],
				[_pet_tiger_layer(43, -0.15, 19.05, 0.851, 0.851, 0.0867)],
				[_pet_tiger_layer(43, 0.0, 37.1, 0.7256, 0.7256, 0.2868)],
				[_pet_tiger_layer(43, 0.0, 37.1, 0.7256, 0.7256, 0.2868)],
				[],
				[],
				[],
				[]
			]
		"PetTiger2Bullet3_1":
			return [
				[_pet_tiger_layer(9, 1.75, 13.1, 0.72, 0.72)],
				[_pet_tiger_layer(12, 7.15, 6.05, 0.72, 0.72)],
				[_pet_tiger_layer(15, 1.75, 8.25, 0.72, 0.72)],
				[_pet_tiger_layer(18, 17.85, 5.55, 0.72, 0.72)],
				[_pet_tiger_layer(21, 9.05, -3.2, 0.72, 0.72)],
				[_pet_tiger_layer(24, 10.5, -2.45, 0.72, 0.72)],
				[_pet_tiger_layer(27, 2.7, -3.4, 0.72, 0.72)],
				[_pet_tiger_layer(30, -78.5, -44.0, 0.72, 0.72)],
				[_pet_tiger_layer(30, -80.0, -45.55, 0.72, 0.72)],
				[_pet_tiger_layer(35, -65.75, -77.2, 0.72, 0.72, -0.2618)],
				[_pet_tiger_layer(38, -90.35, -90.95, 0.72, 0.72, -0.1481)],
				[_pet_tiger_layer(38, -90.35, -90.95, 0.72, 0.72, -0.1481)],
				[],
				[],
				[],
				[],
				[],
				[],
				[],
				[]
			]
		"PetTiger2Bullet3_2":
			var frames: Array = []
			for i in range(30):
				frames.append([_pet_tiger_layer(5, 0.0, 0.0)])
			return frames
		"PetTiger3Bullet4_1":
			return [
				[_pet_tiger_layer(77, 30.95, 154.5, -1.0, -1.0, 1.9951)],
				[_pet_tiger_layer(77, 30.95, 154.35, -0.9987, -0.9987, 1.9949)],
				[_pet_tiger_layer(77, 30.95, 154.35, -0.9987, -0.9987, 1.9949)],
				[_pet_tiger_layer(77, 30.95, 154.35, -0.9987, -0.9987, 1.9949)],
				[_pet_tiger_layer(77, 30.95, 154.35, -0.9987, -0.9987, 1.9949)],
				[_pet_tiger_layer(77, 30.95, 154.35, -0.9987, -0.9987, 1.9949)],
				[_pet_tiger_layer(77, 30.95, 154.5, -1.0, -1.0, 1.9951)],
				[_pet_tiger_layer(77, 30.95, 154.35, -0.9987, -0.9987, 1.9949)],
				[_pet_tiger_layer(77, 30.95, 154.5, -1.0, -1.0, 1.9951)],
				[]
			]
		"PetTiger3Bullet4_2":
			return [
				[_pet_tiger_layer(58, -15.6, -73.45)],
				[_pet_tiger_layer(58, -15.6, -73.45)],
				[_pet_tiger_layer(58, -15.6, -73.45), _pet_tiger_layer(58, -113.5, -73.55)],
				[_pet_tiger_layer(60, -15.6, -73.45), _pet_tiger_layer(60, -113.5, -73.55)],
				[
					_pet_tiger_layer(60, -15.6, -73.45),
					_pet_tiger_layer(60, -113.5, -73.55),
					_pet_tiger_layer(60, -211.1, -73.15)
				],
				[
					_pet_tiger_layer(62, -15.6, -73.45),
					_pet_tiger_layer(62, -113.5, -73.55),
					_pet_tiger_layer(62, -211.1, -73.15)
				],
				[
					_pet_tiger_layer(62, -15.6, -73.45),
					_pet_tiger_layer(62, -113.5, -73.55),
					_pet_tiger_layer(62, -211.1, -73.15),
					_pet_tiger_layer(62, -313.65, -73.55)
				],
				[
					_pet_tiger_layer(64, -15.6, -73.45),
					_pet_tiger_layer(64, -113.5, -73.55),
					_pet_tiger_layer(64, -211.1, -73.15),
					_pet_tiger_layer(64, -313.65, -73.55)
				],
				[
					_pet_tiger_layer(64, -15.6, -73.45),
					_pet_tiger_layer(64, -113.5, -73.55),
					_pet_tiger_layer(64, -211.1, -73.15),
					_pet_tiger_layer(64, -313.65, -73.55),
					_pet_tiger_layer(64, -426.75, -73.15)
				],
				[
					_pet_tiger_layer(66, -15.6, -73.45),
					_pet_tiger_layer(66, -113.5, -73.55),
					_pet_tiger_layer(66, -211.1, -73.15),
					_pet_tiger_layer(66, -313.65, -73.55),
					_pet_tiger_layer(66, -426.75, -73.15)
				],
				[
					_pet_tiger_layer(66, -15.6, -73.45),
					_pet_tiger_layer(66, -113.5, -73.55),
					_pet_tiger_layer(66, -211.1, -73.15),
					_pet_tiger_layer(66, -313.65, -73.55),
					_pet_tiger_layer(66, -426.75, -73.15)
				],
				[
					_pet_tiger_layer(68, -15.6, -73.45),
					_pet_tiger_layer(68, -113.5, -73.55),
					_pet_tiger_layer(68, -211.1, -73.15),
					_pet_tiger_layer(68, -313.65, -73.55),
					_pet_tiger_layer(68, -426.75, -73.15)
				],
				[
					_pet_tiger_layer(70, -15.6, -73.45),
					_pet_tiger_layer(70, -113.5, -73.55),
					_pet_tiger_layer(70, -211.1, -73.15),
					_pet_tiger_layer(70, -313.65, -73.55),
					_pet_tiger_layer(70, -426.75, -73.15)
				],
				[
					_pet_tiger_layer(72, -15.6, -73.45),
					_pet_tiger_layer(72, -113.5, -73.55),
					_pet_tiger_layer(72, -211.1, -73.15),
					_pet_tiger_layer(72, -313.65, -73.55),
					_pet_tiger_layer(72, -426.75, -73.15)
				],
				[],
				[],
				[],
				[],
				[],
				[],
				[],
				[],
				[],
				[],
				[],
				[],
				[],
				[],
				[],
				[],
				[],
				[],
				[],
				[],
				[],
				[],
				[],
				[],
				[],
				[]
			]
		_:
			return []


func _ensure_pet_tiger_layers(_count: int) -> void:
	while pet_tiger_layer_sprites.size() < _count:
		var sprite := Sprite2D.new()
		sprite.centered = false
		sprite.visible = false
		middle.add_child(sprite)
		pet_tiger_layer_sprites.append(sprite)


func _update_pet_tiger_layers() -> void:
	var timeline := pet_tiger_timeline
	if timeline.is_empty():
		return
	var frame_index: int = clampi(bullet_ani.frame, 0, timeline.size() - 1)
	if frame_index == pet_tiger_last_frame:
		return
	pet_tiger_last_frame = frame_index
	var layers: Array = timeline[frame_index]
	_ensure_pet_tiger_layers(layers.size())
	var visual_rect: Rect2 = Rect2()
	var has_visual_rect := false
	for i in range(pet_tiger_layer_sprites.size()):
		var sprite: Sprite2D = pet_tiger_layer_sprites[i]
		if i >= layers.size():
			sprite.visible = false
			continue
		var layer: Dictionary = layers[i]
		var texture: Texture2D = _get_pet_tiger_layer_texture(int(layer["id"]))
		sprite.texture = texture
		sprite.position = Vector2(float(layer["x"]), float(layer["y"]))
		sprite.scale = Vector2(float(layer["sx"]), float(layer["sy"]))
		sprite.rotation = float(layer["rot"])
		sprite.visible = texture != null
		if texture != null:
			var layer_rect: Rect2 = _pet_tiger_layer_rect(texture, sprite.position, sprite.scale, sprite.rotation)
			visual_rect = layer_rect if not has_visual_rect else visual_rect.merge(layer_rect)
			has_visual_rect = true
	_update_pet_tiger_hit_shape_from_rect(visual_rect, has_visual_rect)


func _pet_tiger_layer_rect(
	texture: Texture2D, layer_position: Vector2, layer_scale: Vector2, layer_rotation: float
) -> Rect2:
	var size: Vector2 = Vector2(
		float(texture.get_width()) * absf(layer_scale.x), float(texture.get_height()) * absf(layer_scale.y)
	)
	var points: Array[Vector2] = [Vector2.ZERO, Vector2(size.x, 0.0), Vector2(0.0, size.y), size]
	var rect: Rect2 = Rect2()
	var has_point := false
	for point in points:
		var transformed: Vector2 = layer_position + point.rotated(layer_rotation)
		if not has_point:
			rect = Rect2(transformed, Vector2.ZERO)
			has_point = true
		else:
			rect = rect.expand(transformed)
	return rect


func _update_pet_tiger_hit_shape_from_rect(visual_rect: Rect2, has_visual_rect: bool) -> void:
	var hit_shape: CollisionShape2D = hit_box.get_node_or_null("Hit_Box")
	if hit_shape == null or not has_visual_rect:
		return
	var rect: Rect2 = visual_rect.grow(6.0)
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	if _pet_tiger_hit_rect_shape == null:
		_pet_tiger_hit_rect_shape = RectangleShape2D.new()
	var shape: RectangleShape2D = _pet_tiger_hit_rect_shape
	shape.size = rect.size
	hit_shape.shape = shape
	hit_shape.position = rect.position + rect.size * 0.5


func _ready() -> void:
	_ensure_timer_signals()
	set_meta("is_monster_bullet", true)
	if skill_name == "Monster5Bullet":
		_setup_monster5_bullet()
		return
	if _is_pet_tiger_bullet(skill_name):
		_setup_pet_tiger_bullet(skill_name)
		return
	if _is_pet_dragon_bullet(skill_name):
		get_prop()
		_setup_pet_dragon_bullet(skill_name)
		return
	if _is_pet_phoenix_bullet(skill_name):
		_setup_pet_phoenix_bullet(skill_name)
		return
	if STANDARD_BULLET_FRAMES.has(skill_name):
		_setup_standard_bullet_frames()
	hit_name = hit_name

	if skill_name == "Monster1410Bullet1":
		var speed_mag = 500
		var direction = Vector2.RIGHT.rotated(rotation)
		bounce_velocity = direction * speed_mag

		bullet_player.speed_scale = 1.0
		_prepare_bullet_animation_material(skill_name)
		bullet_player.play(skill_name)

		monster1410_life_left = 10.0
		queue_timer.start(10.0)
		state = do

		active_1410_bullets.append(self)

		for bullet in active_1410_bullets:
			if bullet != self and is_instance_valid(bullet):
				bullet.redirect_to_player()

		tree_exited.connect(_on_1410_bullet_exited)
		return


func _physics_process(_delta: float) -> void:
	throw_count += 1
	if skill_name.is_empty():
		return
	if skill_name != _runtime_skill_name:
		_refresh_runtime_kind()
	match _runtime_kind:
		RuntimeKind.MONSTER_5:
			_physics_monster5_bullet(_delta)
			return
		RuntimeKind.PET_TIGER:
			_physics_pet_tiger_bullet(_delta)
			return
		RuntimeKind.PET_DRAGON:
			_physics_pet_dragon_bullet(_delta)
			return
		RuntimeKind.PET_PHOENIX:
			_physics_pet_phoenix_bullet(_delta)
			return
	if not is_set:
		player_position = RoleProp.get_nearest_monster_target_position(global_position)
		get_prop()
		is_set = true

	if _runtime_kind == RuntimeKind.MONSTER_1410:
		if monster1410_life_left > 0.0:
			monster1410_life_left -= _delta
			if monster1410_life_left <= 0.0:
				destroy_with_explosion()
				return
		move_with_reflection(bounce_velocity, _delta)
		if position.y > 2000 or position.y < -1000 or position.x < -1000 or position.x > 8000:
			destroy_with_explosion()
		return

	match state:
		do:
			do_action(skill_name)
		remove:
			pass

	if STANDARD_BULLET_FRAMES.has(skill_name):
		_sync_monster_atlas_visual()

	match _runtime_kind:
		RuntimeKind.MONSTER_90:
			self.position += NodeUtils.position_between(self, RoleProp.source_player) * fly_speed * 0.5
			fly_speed += 2
			if fly_speed >= 10:
				fly_speed = 10
		RuntimeKind.MONSTER_101_2:
			self.position += NodeUtils.position_between(self, RoleProp.source_player) * fly_speed * 0.5
			fly_speed += 0.1
			if fly_speed >= 5:
				fly_speed = 5
			if count % 240 == 0:
				move_player_toself()
			count += 1
		RuntimeKind.MONSTER_1407_5:
			var player = RoleProp.source_player
			if player and is_instance_valid(player):
				var distance = position.distance_to(player.position)
				var max_radius = 2000
				var min_radius = 25
				if distance < max_radius and distance > min_radius:
					var base_pull = 5
					var distance_factor = 1
					var pull_strength = (max_radius - distance) / max_radius
					pull_strength = clamp(pull_strength * base_pull, 0.5, base_pull * 1.5)
					var direction = (position - player.position).normalized()
					player.position += direction * pull_strength


func _refresh_runtime_kind() -> void:
	_runtime_skill_name = skill_name
	match skill_name:
		"Monster5Bullet":
			_runtime_kind = RuntimeKind.MONSTER_5
		"Monster1410Bullet1":
			_runtime_kind = RuntimeKind.MONSTER_1410
		"Monster90Bullet":
			_runtime_kind = RuntimeKind.MONSTER_90
		"Monster101Bullet2":
			_runtime_kind = RuntimeKind.MONSTER_101_2
		"Monster1407Bullet5":
			_runtime_kind = RuntimeKind.MONSTER_1407_5
		_:
			if _is_pet_tiger_bullet(skill_name):
				_runtime_kind = RuntimeKind.PET_TIGER
			elif _is_pet_dragon_bullet(skill_name):
				_runtime_kind = RuntimeKind.PET_DRAGON
			elif _is_pet_phoenix_bullet(skill_name):
				_runtime_kind = RuntimeKind.PET_PHOENIX
			else:
				_runtime_kind = RuntimeKind.NORMAL


func _setup_standard_bullet_frames() -> bool:
	var config: Array = STANDARD_BULLET_FRAMES.get(skill_name, [])
	if config.size() < 2:
		return false
	var frames := load(str(config[0])) as SpriteFrames
	var animation := StringName(str(config[1]))
	if frames == null or not frames.has_animation(animation):
		return false
	var sprite := Sprite2D.new()
	sprite.name = "MonsterAtlasFrames"
	sprite.centered = true
	sprite.texture_filter = bullet_ani.texture_filter
	sprite.modulate = bullet_ani.self_modulate
	sprite.flip_h = bullet_ani.flip_h
	sprite.texture = frames.get_frame_texture(animation, 0)
	bullet_ani.add_child(sprite)
	monster_atlas_frames_sprite = sprite
	monster_atlas_frames = frames
	monster_atlas_frames_animation = animation
	_sync_monster_atlas_visual()
	return true


func _sync_monster_atlas_visual() -> void:
	if monster_atlas_frames_sprite != null and is_instance_valid(monster_atlas_frames_sprite):
		if monster_atlas_frames == null:
			return
		var frame_count := monster_atlas_frames.get_frame_count(monster_atlas_frames_animation)
		if frame_count <= 0:
			return
		var frame := clampi(bullet_ani.frame, 0, frame_count - 1)
		monster_atlas_frames_sprite.position = bullet_ani.offset
		monster_atlas_frames_sprite.modulate = bullet_ani.self_modulate
		monster_atlas_frames_sprite.flip_h = bullet_ani.flip_h
		monster_atlas_frames_sprite.texture = monster_atlas_frames.get_frame_texture(
			monster_atlas_frames_animation, frame
		)
		return


func _is_pet_tiger_bullet(_name: String) -> bool:
	return (
		_name == "PetTiger1Bullet1"
		or _name == "PetTiger1Bullet2"
		or _name == "PetTiger2Bullet1"
		or _name == "PetTiger2Bullet3_1"
		or _name == "PetTiger2Bullet3_2"
		or _name == "PetTiger3Bullet4_1"
		or _name == "PetTiger3Bullet4_2"
	)


func _is_pet_dragon_bullet(_name: String) -> bool:
	return (
		_name == "PetDragon1Bullet1"
		or _name == "PetDragon2Bullet1"
		or _name == "PetDragon2Bullet2"
		or _name == "PetDragon3Bullet1"
		or _name == "PetDragon3Bullet3"
		or _name == "PetDragonBullet4"
	)


func _is_pet_phoenix_bullet(_name: String) -> bool:
	return _name.begins_with("PetPhoenix")


static func _get_pet_phoenix_frames(_name: String) -> SpriteFrames:
	if _pet_phoenix_effects_frames == null:
		_pet_phoenix_effects_frames = load(PET_PHOENIX_EFFECTS_RES) as SpriteFrames
	if _pet_phoenix_effects_frames != null and _pet_phoenix_effects_frames.has_animation(_name):
		return _pet_phoenix_effects_frames
	push_error("Pet phoenix standard frames missing: " + _name)
	return null


static func warm_pet_phoenix_frames(stage: int) -> void:
	for effect_name in _pet_phoenix_effect_names(stage):
		_get_pet_phoenix_frames(effect_name)


static func _pet_phoenix_effect_names(stage: int) -> Array[String]:
	var effect_names: Array[String] = [
		"PetPhoenix1Bullet1",
		"PetPhoenix1Bullet2_1",
		"PetPhoenix1Bullet2_2",
	]
	if stage >= 2:
		effect_names.append("PetPhoenix2Bullet3")
	if stage >= 3:
		effect_names.append("PetPhoenix3Bullet4")
	if stage >= 4:
		(
			effect_names
			. append_array(
				[
					"PetPhoenix4Bullet3_2",
					"PetPhoenix4Bullet5",
					"PetPhoenix4Bullet6",
				]
			)
		)
	return effect_names


static func _prewarm_pet_bullet_instances(bullet_scene: PackedScene, effect_names: Array[String]) -> void:
	if bullet_scene == null or effect_names.is_empty():
		return
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		return
	var warm_root := Node2D.new()
	warm_root.name = "PetBulletPrewarm"
	warm_root.process_mode = Node.PROCESS_MODE_DISABLED
	warm_root.z_index = -4096
	warm_root.position = tree.root.get_visible_rect().get_center()
	tree.root.add_child(warm_root)
	for effect_name in effect_names:
		var instance := bullet_scene.instantiate() as MonsterBullet
		if instance == null:
			continue
		instance.att_list = {"power": 0, "attackKind": "physical", "hurtBack": [0, 0]}
		instance.hit_name = "__prewarm__"
		instance.dir = false
		instance.skill_name = effect_name
		instance.speed = 1.0
		instance.process_mode = Node.PROCESS_MODE_DISABLED
		instance.modulate = Color(1.0, 1.0, 1.0, 0.001)
		instance.set_meta("pet_tiger_disabled", true)
		instance.set_meta("pet_dragon_disabled", true)
		instance.set_meta("pet_phoenix_disabled", true)
		var warm_hit_box := instance.get_node_or_null("middle/HitBox") as Area2D
		if warm_hit_box != null:
			warm_hit_box.collision_layer = 0
			warm_hit_box.collision_mask = 0
			warm_hit_box.monitoring = false
			warm_hit_box.monitorable = false
		warm_root.add_child(instance)
	await tree.process_frame
	await tree.process_frame
	if is_instance_valid(warm_root):
		warm_root.free()


static func _pet_tiger_effect_names(stage: int) -> Array[String]:
	var effect_names: Array[String] = [
		"PetTiger1Bullet1" if stage <= 1 else "PetTiger2Bullet1",
		"PetTiger1Bullet2",
	]
	if stage >= 2:
		effect_names.append_array(["PetTiger2Bullet3_1", "PetTiger2Bullet3_2"])
	if stage >= 3:
		effect_names.append_array(["PetTiger3Bullet4_1", "PetTiger3Bullet4_2"])
	return effect_names


static func _pet_dragon_effect_names(stage: int) -> Array[String]:
	stage = clampi(stage, 1, 4)
	var effect_names: Array[String] = [
		"PetDragon1Bullet1" if stage == 1 else "PetDragon2Bullet1" if stage == 2 else "PetDragon3Bullet1"
	]
	if stage >= 2:
		effect_names.append("PetDragon2Bullet2")
	if stage >= 3:
		effect_names.append("PetDragon3Bullet3")
	if stage >= 4:
		effect_names.append("PetDragonBullet4")
	return effect_names


static func prewarm_pet_tiger_runtime(stage: int, bullet_scene: PackedScene = null) -> void:
	var effect_names := _pet_tiger_effect_names(stage)
	var helper := MonsterBullet.new()
	var tree := Engine.get_main_loop() as SceneTree
	for effect_name in effect_names:
		helper._get_cached_pet_tiger_timeline(effect_name)
		helper._get_cached_pet_bullet_frames(
			effect_name, helper._get_cached_pet_tiger_timeline(effect_name).size(), false
		)
		if tree != null:
			await tree.process_frame
	helper.free()
	await _prewarm_pet_bullet_instances(bullet_scene, effect_names)


static func prewarm_pet_dragon_runtime(stage: int, bullet_scene: PackedScene = null) -> void:
	stage = clampi(stage, 1, 4)
	await warm_pet_dragon_textures(stage)
	if stage >= 4:
		await warm_pet_dragon_ultimate_frames()
	var effect_names := _pet_dragon_effect_names(stage)
	var helper := MonsterBullet.new()
	for effect_name in effect_names:
		helper._get_cached_pet_bullet_frames(
			effect_name, MonsterBullet._pet_dragon_clock_frame_count(effect_name), true
		)
	helper.free()
	await _prewarm_pet_bullet_instances(bullet_scene, effect_names)


static func prewarm_pet_phoenix_runtime(stage: int, bullet_scene: PackedScene = null) -> void:
	warm_pet_phoenix_frames(clampi(stage, 1, 4))
	var tree := Engine.get_main_loop() as SceneTree
	if tree != null:
		await tree.process_frame
	await _prewarm_pet_bullet_instances(bullet_scene, _pet_phoenix_effect_names(stage))


func _setup_pet_phoenix_hit_shape() -> void:
	var hit_shape: CollisionShape2D = hit_box.get_node_or_null("Hit_Box")
	if hit_shape == null:
		return
	var shape := RectangleShape2D.new()
	shape.size = _pet_phoenix_hit_shape_size()
	hit_shape.shape = shape
	hit_shape.position = _pet_phoenix_hit_shape_offset()


func _pet_phoenix_hit_shape_size() -> Vector2:
	if _is_pet_phoenix_visual_sweep_bullet():
		return Vector2(1, 1)
	return get_meta("pet_phoenix_hit_size", Vector2(180, 100)) as Vector2


func _pet_phoenix_hit_shape_offset() -> Vector2:
	if _is_pet_phoenix_visual_sweep_bullet():
		return Vector2.ZERO
	return Vector2.ZERO


func _is_pet_phoenix_visual_sweep_bullet() -> bool:
	return skill_name == "PetPhoenix2Bullet3" or skill_name == "PetPhoenix4Bullet6"


func _setup_pet_phoenix_bullet(_name: String) -> void:
	if dir == false:
		middle.scale.x = -1
	else:
		middle.scale.x = 1
	_setup_pet_phoenix_hit_shape()
	var frames := _get_pet_phoenix_frames(_name)
	if frames == null:
		queue_free()
		return
	var frame_count: int = frames.get_frame_count(_name)
	if frame_count <= 0:
		queue_free()
		return
	bullet_ani.sprite_frames = frames
	bullet_ani.animation = _name
	bullet_ani.position = Vector2.ZERO
	bullet_ani.scale = Vector2(1, 1)
	bullet_ani.self_modulate = Color(1, 1, 1, 1)
	bullet_ani.visible = true
	pet_phoenix_hold_last_elapsed = 0.0
	bullet_ani.play(_name)
	hit_box.monitoring = not bool(get_meta("pet_phoenix_disabled", false))
	if not bool(get_meta("pet_phoenix_hold_last", false)):
		queue_timer.start(float(frame_count) / PET_TIGER_BULLET_FPS + 0.02)
	state = do


func _physics_pet_phoenix_bullet(delta: float) -> void:
	_sync_follow_pet_phoenix_bullet(delta)
	if is_queued_for_deletion():
		return
	get_prop()
	hit_box.monitoring = not bool(get_meta("pet_phoenix_disabled", false))
	_process_pet_phoenix_hold_last(delta)
	if _is_pet_phoenix_visual_sweep_bullet():
		var visual_hit_rect: Rect2 = _pet_phoenix_current_visual_hit_rect()
		_update_pet_phoenix_visual_hit_shape(visual_hit_rect)
		_apply_pet_phoenix_sweep_damage(visual_hit_rect)
	else:
		_apply_pet_phoenix_overlap_damage()
	if bullet_ani.sprite_frames != null and bullet_ani.sprite_frames.has_animation(skill_name):
		var last_frame := bullet_ani.sprite_frames.get_frame_count(skill_name) - 1
		if bullet_ani.frame >= last_frame:
			if bool(get_meta("pet_phoenix_hold_last", false)):
				bullet_ani.pause()
				bullet_ani.set_frame_and_progress(last_frame, 0.0)
				return
			hit_box.monitoring = false


func _process_pet_phoenix_hold_last(delta: float) -> void:
	if not bool(get_meta("pet_phoenix_hold_last", false)):
		return
	if bullet_ani == null or bullet_ani.sprite_frames == null:
		return
	if not bullet_ani.sprite_frames.has_animation(skill_name):
		return
	var frame_count: int = bullet_ani.sprite_frames.get_frame_count(skill_name)
	if frame_count <= 0:
		return
	var last_frame: int = frame_count - 1
	var hold_time: float = float(frame_count - 1) / PET_TIGER_BULLET_FPS
	pet_phoenix_hold_last_elapsed += delta
	if pet_phoenix_hold_last_elapsed >= hold_time:
		bullet_ani.pause()
		bullet_ani.set_frame_and_progress(last_frame, 0.0)


func _apply_pet_phoenix_overlap_damage() -> void:
	if hit_box == null or bool(get_meta("pet_phoenix_disabled", false)):
		return
	var targets: Array[BaseMonster] = _collect_pet_phoenix_overlap_targets(null)
	if targets.is_empty():
		return
	_apply_pet_phoenix_summon_targets(targets)


func _collect_pet_phoenix_overlap_targets(primary_target: BaseMonster) -> Array[BaseMonster]:
	var targets: Array[BaseMonster] = []
	var seen: Dictionary = {}
	for area in hit_box.get_overlapping_areas():
		var target: Node = _get_hit_owner(area)
		_try_add_pet_phoenix_overlap_target(target, targets, seen)
	_try_add_pet_phoenix_overlap_target(primary_target, targets, seen)
	if targets.size() < 2 and (primary_target != null or skill_name == "PetPhoenix1Bullet1"):
		var hit_size: Vector2 = get_meta("pet_phoenix_hit_size", Vector2(180, 100))
		var radius: float = maxf(hit_size.x, hit_size.y) * 0.5
		var summon_owner: Node = get_meta("summoner", null)
		_collect_pet_phoenix_aoe_targets_near(global_position, radius, targets, seen, summon_owner)
	return targets


func _get_level_active_monster_candidates() -> Array:
	var tree := get_tree()
	if tree == null:
		return []
	var scene := tree.current_scene
	if scene != null and scene.has_method("has_active_monster_index") and scene.has_active_monster_index():
		return scene.get_active_monsters()
	return tree.get_nodes_in_group("monsters")


func _collect_pet_phoenix_aoe_targets_near(
	center: Vector2, radius: float, targets: Array[BaseMonster], seen: Dictionary, summon_owner: Node
) -> void:
	var tree: SceneTree = get_tree()
	if tree == null:
		return
	var group_nodes: Array = _get_level_active_monster_candidates()
	for node in group_nodes:
		_try_add_pet_phoenix_aoe_target_near(node, center, radius, targets, seen, summon_owner)
	var scene: Node = tree.current_scene
	if group_nodes.is_empty() and scene != null and scene.has_node("Monster"):
		_collect_pet_phoenix_aoe_targets_near_recursive(
			scene.get_node("Monster"), center, radius, targets, seen, summon_owner
		)


func _collect_pet_phoenix_aoe_targets_near_recursive(
	node: Node, center: Vector2, radius: float, targets: Array[BaseMonster], seen: Dictionary, summon_owner: Node
) -> void:
	if node == null:
		return
	_try_add_pet_phoenix_aoe_target_near(node, center, radius, targets, seen, summon_owner)
	for child in node.get_children():
		_collect_pet_phoenix_aoe_targets_near_recursive(child, center, radius, targets, seen, summon_owner)


func _try_add_pet_phoenix_aoe_target_near(
	node: Node, center: Vector2, radius: float, targets: Array[BaseMonster], seen: Dictionary, summon_owner: Node
) -> void:
	if not (node is BaseMonster):
		return
	var monster: BaseMonster = node as BaseMonster
	if monster.hp <= 0 or monster == summon_owner or monster.is_boss_protecting():
		return
	var instance_id: int = monster.get_instance_id()
	if seen.has(instance_id):
		return
	if monster.global_position.distance_to(center) > radius:
		return
	targets.append(monster)
	seen[instance_id] = true


func _try_add_pet_phoenix_overlap_target(target: Node, targets: Array[BaseMonster], seen: Dictionary) -> void:
	if not (target is BaseMonster):
		return
	var monster: BaseMonster = target as BaseMonster
	var summon_owner: Node = get_meta("summoner", null)
	if monster == summon_owner or monster.hp <= 0 or monster.is_boss_protecting():
		return
	var instance_id: int = monster.get_instance_id()
	if seen.has(instance_id):
		return
	targets.append(monster)
	seen[instance_id] = true


func _apply_pet_phoenix_sweep_damage(hit_rect: Rect2) -> void:
	if not _is_pet_phoenix_visual_sweep_bullet() or bool(get_meta("pet_phoenix_disabled", false)):
		return
	if hit_rect.size.x <= 0.0 or hit_rect.size.y <= 0.0:
		return
	if typeof(att_list) != TYPE_DICTIONARY:
		return
	var hit_data: Dictionary = att_list
	var damage: int = int(hit_data.get("power", 0))
	if damage <= 0:
		return
	var targets: Array[BaseMonster] = _collect_pet_phoenix_sweep_targets(hit_rect.grow(8.0))
	if targets.is_empty():
		return
	var hurt_back: Array = hit_data.get("hurtBack", [0, 0])
	var summon_owner: Node = get_meta("summoner", null)
	var attack_kind := str(hit_data.get("attackKind", "physics"))
	_deal_pet_phoenix_damage_repeated(targets, damage, summon_owner, hurt_back, attack_kind)


func _collect_pet_phoenix_sweep_targets(hit_rect: Rect2) -> Array[BaseMonster]:
	var targets: Array[BaseMonster] = []
	var seen: Dictionary = {}
	var summon_owner: Node = get_meta("summoner", null)
	if hit_rect.size.x <= 0.0 or hit_rect.size.y <= 0.0:
		return targets
	var tree: SceneTree = get_tree()
	if tree != null:
		var group_nodes: Array = _get_level_active_monster_candidates()
		for node in group_nodes:
			_try_add_pet_phoenix_sweep_target(node, targets, seen, summon_owner, hit_rect)
		var scene: Node = tree.current_scene
		if group_nodes.is_empty() and scene != null and scene.has_node("Monster"):
			_collect_pet_phoenix_sweep_targets_recursive(
				scene.get_node("Monster"), targets, seen, summon_owner, hit_rect
			)
	return targets


func _collect_pet_phoenix_sweep_targets_recursive(
	node: Node, targets: Array[BaseMonster], seen: Dictionary, summon_owner: Node, hit_rect: Rect2
) -> void:
	if node == null:
		return
	_try_add_pet_phoenix_sweep_target(node, targets, seen, summon_owner, hit_rect)
	for child in node.get_children():
		_collect_pet_phoenix_sweep_targets_recursive(child, targets, seen, summon_owner, hit_rect)


func _try_add_pet_phoenix_sweep_target(
	node: Node, targets: Array[BaseMonster], seen: Dictionary, summon_owner: Node, hit_rect: Rect2
) -> void:
	if not (node is BaseMonster):
		return
	var monster: BaseMonster = node as BaseMonster
	if monster.hp <= 0 or monster == summon_owner:
		return
	var instance_id: int = monster.get_instance_id()
	if seen.has(instance_id):
		return
	if _pet_phoenix_has_hit_target(instance_id):
		return
	if not _pet_phoenix_target_intersects_visual_rect(monster, hit_rect):
		return
	targets.append(monster)
	seen[instance_id] = true


func _pet_phoenix_has_hit_target(instance_id: int) -> bool:
	if not _is_pet_phoenix_visual_sweep_bullet():
		return false
	var hit_targets: Dictionary = get_meta("pet_phoenix_hit_targets", {})
	return hit_targets.has(instance_id)


func _pet_phoenix_mark_hit_target(instance_id: int) -> void:
	if not _is_pet_phoenix_visual_sweep_bullet():
		return
	var hit_targets: Dictionary = get_meta("pet_phoenix_hit_targets", {})
	hit_targets[instance_id] = true
	set_meta("pet_phoenix_hit_targets", hit_targets)


func _pet_phoenix_target_intersects_visual_rect(monster: BaseMonster, hit_rect: Rect2) -> bool:
	if monster == null or hit_box == null:
		return false
	var hurt_shape := monster.get_node_or_null("BaseDamageBox/HurtBox/HurtBox") as CollisionShape2D
	if hurt_shape == null or hurt_shape.disabled or hurt_shape.shape == null:
		return hit_rect.has_point(hit_box.to_local(monster.global_position))
	var center: Vector2 = hit_box.to_local(hurt_shape.global_position)
	var shape_size := Vector2(36, 72)
	if hurt_shape.shape is RectangleShape2D:
		shape_size = (hurt_shape.shape as RectangleShape2D).size
	elif hurt_shape.shape is CircleShape2D:
		var radius := (hurt_shape.shape as CircleShape2D).radius
		shape_size = Vector2(radius * 2.0, radius * 2.0)
	elif hurt_shape.shape is CapsuleShape2D:
		var capsule := hurt_shape.shape as CapsuleShape2D
		shape_size = Vector2(capsule.radius * 2.0, capsule.height)
	shape_size *= Vector2(absf(hurt_shape.global_scale.x), absf(hurt_shape.global_scale.y))
	var target_rect := Rect2(center - shape_size * 0.5, shape_size).grow(4.0)
	return hit_rect.intersects(target_rect) or hit_rect.has_point(center)


func _update_pet_phoenix_visual_hit_shape(rect: Rect2) -> void:
	if not _is_pet_phoenix_visual_sweep_bullet() or hit_box == null:
		return
	var hit_shape := hit_box.get_node_or_null("Hit_Box") as CollisionShape2D
	if hit_shape == null:
		return
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		hit_shape.disabled = true
		return
	hit_shape.disabled = false
	var shape := hit_shape.shape as RectangleShape2D
	if shape == null:
		shape = RectangleShape2D.new()
		hit_shape.shape = shape
	shape.size = rect.size
	hit_shape.position = rect.position + rect.size * 0.5


func _pet_phoenix_current_visual_hit_rect() -> Rect2:
	if bullet_ani == null or bullet_ani.sprite_frames == null:
		return Rect2()
	if not bullet_ani.sprite_frames.has_animation(skill_name):
		return Rect2()
	var frame_count := bullet_ani.sprite_frames.get_frame_count(skill_name)
	if frame_count <= 0:
		return Rect2()
	var frame_index: int = clampi(bullet_ani.frame, 0, frame_count - 1)
	var texture := bullet_ani.sprite_frames.get_frame_texture(skill_name, frame_index)
	if texture == null:
		return Rect2()
	var used_rect: Rect2 = _pet_phoenix_texture_used_rect(skill_name, frame_index, texture)
	if used_rect.size.x <= 0.0 or used_rect.size.y <= 0.0:
		return Rect2()
	var texture_size := Vector2(float(texture.get_width()), float(texture.get_height()))
	var top_left := used_rect.position
	if bullet_ani.centered:
		top_left -= texture_size * 0.5
	top_left = bullet_ani.position + top_left * bullet_ani.scale
	var size := used_rect.size * Vector2(absf(bullet_ani.scale.x), absf(bullet_ani.scale.y))
	return Rect2(top_left, size)


func _pet_phoenix_texture_used_rect(anim_name: String, frame_index: int, texture: Texture2D) -> Rect2:
	var cache_key := anim_name + ":" + str(frame_index)
	if pet_phoenix_frame_used_rect_cache.has(cache_key):
		return pet_phoenix_frame_used_rect_cache[cache_key] as Rect2
	var image := texture.get_image()
	if image == null or image.is_empty():
		pet_phoenix_frame_used_rect_cache[cache_key] = Rect2()
		return Rect2()
	var used_rect_i := image.get_used_rect()
	var used_rect := Rect2(Vector2(used_rect_i.position), Vector2(used_rect_i.size))
	pet_phoenix_frame_used_rect_cache[cache_key] = used_rect
	return used_rect


func _sync_follow_pet_phoenix_bullet(delta: float) -> void:
	if has_meta("pet_phoenix_lifetime"):
		var left_time := float(get_meta("pet_phoenix_lifetime", 0.0)) - delta
		if left_time <= 0.0:
			queue_free()
			return
		set_meta("pet_phoenix_lifetime", left_time)
	if not bool(get_meta("pet_phoenix_follow_self", false)):
		return
	var source = get_meta("summoner", null)
	if source == null or not is_instance_valid(source):
		queue_free()
		return
	var follow_offset: Vector2 = get_meta("pet_phoenix_follow_offset", Vector2.ZERO)
	position = source.position + follow_offset
	var source_faces_left := bool(source.get("monster_direction"))
	if source_faces_left != dir:
		dir = source_faces_left
		if middle != null:
			middle.scale.x = 1.0 if dir else -1.0


func _apply_pet_phoenix_summon_hit(target: Node) -> void:
	if _is_pet_phoenix_visual_sweep_bullet():
		return
	if not (target is BaseMonster):
		return
	if get_meta("pet_phoenix_disabled", false):
		return
	if bool(get_meta("pet_phoenix_pending_overlap_hit", false)):
		return
	set_meta("pet_phoenix_pending_overlap_hit", true)
	set_meta("pet_phoenix_primary_target", target)
	call_deferred("_apply_pet_phoenix_pending_overlap_hit")


func _apply_pet_phoenix_pending_overlap_hit() -> void:
	set_meta("pet_phoenix_pending_overlap_hit", false)
	if get_meta("pet_phoenix_disabled", false):
		return
	var primary_target: BaseMonster = get_meta("pet_phoenix_primary_target", null) as BaseMonster
	var targets: Array[BaseMonster] = _collect_pet_phoenix_overlap_targets(primary_target)
	if targets.is_empty():
		return
	_apply_pet_phoenix_summon_targets(targets)


func _apply_pet_phoenix_summon_targets(targets: Array[BaseMonster]) -> void:
	if _is_pet_phoenix_visual_sweep_bullet():
		return
	if get_meta("pet_phoenix_disabled", false):
		return
	if typeof(att_list) != TYPE_DICTIONARY:
		return
	var hit_data: Dictionary = att_list
	var summon_owner: Node = get_meta("summoner", null)
	var damage := int(hit_data.get("power", 0))
	if damage <= 0:
		return
	var attack_kind := str(hit_data.get("attackKind", "physics"))
	var hurt_back: Array = hit_data.get("hurtBack", [0, 0])
	_deal_pet_phoenix_damage_repeated(targets, damage, summon_owner, hurt_back, attack_kind)
	set_meta("pet_phoenix_disabled", true)
	hit_box.set_deferred("monitoring", false)


func _deal_pet_phoenix_damage_repeated(
	targets: Array[BaseMonster], damage: int, summon_owner: Node, hurt_back: Array, attack_kind: String
) -> void:
	var damage_times: int = max(1, int(get_meta("pet_phoenix_damage_times", 1)))
	var damage_interval: float = maxf(0.0, float(get_meta("pet_phoenix_damage_interval", 0.14)))
	for hit_index in range(damage_times):
		if hit_index > 0 and damage_interval > 0.0:
			await get_tree().create_timer(damage_interval, false).timeout
			if not is_inside_tree():
				return
		_deal_pet_phoenix_damage(targets, damage, summon_owner, hurt_back, attack_kind)


func _deal_pet_phoenix_damage(
	targets: Array[BaseMonster], damage: int, summon_owner: Node, hurt_back: Array, attack_kind: String
) -> void:
	for aoe_target in targets:
		if not is_instance_valid(aoe_target) or aoe_target.hp <= 0:
			continue
		if aoe_target.is_boss_protecting():
			continue
		var resolved_damage := _pet_tiger_resolve_damage(aoe_target, damage, summon_owner, attack_kind)
		if resolved_damage <= 0:
			continue
		var hp_before_hit := int(aoe_target.hp)
		aoe_target.reduce_pet_hp(resolved_damage, attack_kind)
		var actual_damage := maxi(0, hp_before_hit - int(aoe_target.hp))
		if actual_damage > 0:
			_pet_phoenix_mark_hit_target(aoe_target.get_instance_id())
			_apply_pet_summon_knockback(aoe_target, summon_owner, hurt_back)
			if aoe_target.has_method("play_hit_effect"):
				aoe_target.play_hit_effect(self)


func _collect_pet_phoenix_aoe_targets(primary_target: BaseMonster) -> Array[BaseMonster]:
	var targets: Array[BaseMonster] = []
	var seen := {}
	var hit_size: Vector2 = get_meta("pet_phoenix_hit_size", Vector2(180, 100))
	var radius := maxf(hit_size.x, hit_size.y) * 0.5
	var summon_owner = get_meta("summoner", null)
	var tree := get_tree()
	if tree != null:
		var candidates := _get_level_active_monster_candidates()
		for node in candidates:
			_try_add_pet_phoenix_aoe_target(node, radius, targets, seen, summon_owner)
		var scene := tree.current_scene
		if candidates.is_empty() and scene != null and scene.has_node("Monster"):
			_collect_pet_phoenix_aoe_targets_recursive(scene.get_node("Monster"), radius, targets, seen, summon_owner)
	if (
		is_instance_valid(primary_target)
		and primary_target != summon_owner
		and primary_target.hp > 0
		and not targets.has(primary_target)
	):
		targets.append(primary_target)
	return targets


func _collect_pet_phoenix_aoe_targets_recursive(
	node: Node, radius: float, targets: Array[BaseMonster], seen: Dictionary, summon_owner
) -> void:
	if node == null:
		return
	_try_add_pet_phoenix_aoe_target(node, radius, targets, seen, summon_owner)
	for child in node.get_children():
		_collect_pet_phoenix_aoe_targets_recursive(child, radius, targets, seen, summon_owner)


func _try_add_pet_phoenix_aoe_target(
	node: Node, radius: float, targets: Array[BaseMonster], seen: Dictionary, summon_owner
) -> void:
	if not (node is BaseMonster):
		return
	var monster := node as BaseMonster
	if monster.hp <= 0 or monster == summon_owner:
		return
	var instance_id := monster.get_instance_id()
	if seen.has(instance_id):
		return
	if monster.global_position.distance_to(global_position) > radius:
		return
	targets.append(monster)
	seen[instance_id] = true


func _setup_pet_dragon_hit_shape(_name: String) -> void:
	var hit_shape: CollisionShape2D = hit_box.get_node_or_null("Hit_Box")
	if hit_shape == null:
		return
	var shape := CircleShape2D.new()
	shape.radius = _pet_dragon_hit_radius(_name)
	hit_shape.shape = shape
	hit_shape.position = _pet_dragon_hit_offset(_name)


func _pet_dragon_hit_radius(_name: String) -> float:
	match _name:
		"PetDragon1Bullet1":
			return 42.0
		"PetDragon2Bullet1":
			return 58.0
		"PetDragon2Bullet2":
			return 68.0
		"PetDragon3Bullet1":
			return 36.0
		"PetDragon3Bullet3":
			return 86.0
		"PetDragonBullet4":
			return 76.0
		_:
			return 60.0


func _pet_dragon_hit_offset(_name: String) -> Vector2:
	match _name:
		"PetDragon3Bullet3":
			return Vector2(0.0, 18.0)
		"PetDragonBullet4":
			return Vector2(0.0, -8.0)
		_:
			return Vector2.ZERO


func _pet_dragon_aoe_radius(_name: String) -> float:
	match _name:
		"PetDragon1Bullet1":
			return 92.0
		"PetDragon2Bullet1":
			return 120.0
		"PetDragon2Bullet2":
			return 150.0
		"PetDragon3Bullet1":
			return 110.0
		"PetDragon3Bullet3":
			return 210.0
		"PetDragonBullet4":
			return 190.0
		_:
			return max(90.0, _pet_dragon_hit_radius(_name) * 1.8)


func _setup_pet_dragon_bullet(_name: String) -> void:
	_apply_pet_dragon_direction(dir)
	_setup_pet_dragon_hit_shape(_name)
	var frames := _get_cached_pet_bullet_frames(_name, _pet_dragon_clock_frame_count(_name), true)
	if frames == null:
		queue_free()
		return
	bullet_ani.sprite_frames = frames
	bullet_ani.animation = _name
	bullet_ani.position = Vector2.ZERO
	bullet_ani.scale = Vector2(1, 1)
	bullet_ani.self_modulate = Color(1, 1, 1, 1)
	bullet_ani.play(_name)
	bullet_ani.visible = false
	pet_tiger_last_frame = -1
	_update_pet_dragon_layers()
	queue_timer.start(float(frames.get_frame_count(_name)) / PET_TIGER_BULLET_FPS + 0.02)
	state = do


static func _pet_dragon_effects() -> SpriteFrames:
	if _pet_dragon_effects_frames == null:
		_pet_dragon_effects_frames = load(PET_DRAGON_EFFECTS_RES) as SpriteFrames
	return _pet_dragon_effects_frames


static func _pet_dragon_effect_texture(_name: String, frame_: int) -> Texture2D:
	var frames := _pet_dragon_effects()
	if frames != null and frames.has_animation(_name):
		return frames.get_frame_texture(_name, frame_)
	return null


func _update_pet_dragon_layers() -> void:
	var frame_index: int = (
		clampi(bullet_ani.frame, 0, max(0, bullet_ani.sprite_frames.get_frame_count(skill_name) - 1))
		if bullet_ani.sprite_frames != null and bullet_ani.sprite_frames.has_animation(skill_name)
		else 0
	)
	if frame_index == pet_tiger_last_frame:
		return
	pet_tiger_last_frame = frame_index
	var animation: StringName = (
		&"PetDragonBullet4Cropped" if skill_name == "PetDragonBullet4" else StringName(skill_name)
	)
	var texture := _pet_dragon_effect_texture(animation, frame_index)
	if texture != null:
		_ensure_pet_tiger_layers(1)
		pet_tiger_layer_sprites[0].texture = texture
		pet_tiger_layer_sprites[0].centered = true
		var layer_position: Vector2 = (
			PET_DRAGON_ULTIMATE_OFFSETS[frame_index] as Vector2 if skill_name == "PetDragonBullet4" else Vector2.ZERO
		)
		if skill_name == "PetDragon1Bullet1":
			layer_position.x = -float(texture.get_width()) * 0.5
		if skill_name == "PetDragon3Bullet3":
			layer_position.y = -float(texture.get_height()) * 0.5
		pet_tiger_layer_sprites[0].position = layer_position
		pet_tiger_layer_sprites[0].visible = true


func _apply_pet_dragon_direction(face_left: bool) -> void:
	dir = face_left
	if middle != null:
		middle.scale.x = 1.0 if face_left else -1.0


func _sync_follow_pet_dragon_bullet() -> void:
	if skill_name != "PetDragon2Bullet2" and skill_name != "PetDragonBullet4":
		return
	var source = get_meta("summoner", null)
	if source == null or not is_instance_valid(source):
		queue_free()
		return

	var follow_offset: Vector2 = get_meta("pet_dragon_follow_offset", Vector2.ZERO)
	global_position = source.global_position + follow_offset
	var source_faces_left := bool(source.get("monster_direction"))
	if source_faces_left != dir:
		_apply_pet_dragon_direction(source_faces_left)


func _physics_pet_dragon_bullet(_delta: float) -> void:
	_sync_follow_pet_dragon_bullet()
	if is_queued_for_deletion():
		return
	get_prop()
	_update_pet_dragon_layers()
	if bullet_ani.sprite_frames != null and bullet_ani.sprite_frames.has_animation(skill_name):
		var is_dash := skill_name == "PetDragon2Bullet2"
		hit_box.monitoring = (
			not bool(get_meta("pet_dragon_disabled", false))
			and (is_dash or not bool(get_meta("pet_dragon_damage_applied", false)))
		)
		if is_dash:
			_apply_pet_dragon_dash_overlap_damage()


func _collect_pet_dragon_aoe_targets(primary_target: BaseMonster) -> Array[BaseMonster]:
	var targets: Array[BaseMonster] = []
	var radius := _pet_dragon_aoe_radius(skill_name)
	var summon_owner = get_meta("summoner", null)
	var tree := get_tree()
	if tree != null:
		var seen := {}
		var candidates := _get_level_active_monster_candidates()
		for node in candidates:
			_try_add_pet_dragon_aoe_target(node, radius, targets, seen, summon_owner)
		var scene := tree.current_scene
		if candidates.is_empty() and scene != null and scene.has_node("Monster"):
			_collect_pet_dragon_aoe_targets_recursive(scene.get_node("Monster"), radius, targets, seen, summon_owner)
	if (
		is_instance_valid(primary_target)
		and primary_target != summon_owner
		and primary_target.hp > 0
		and not targets.has(primary_target)
	):
		targets.append(primary_target)
	return targets


func _collect_pet_dragon_aoe_targets_recursive(
	node: Node, radius: float, targets: Array[BaseMonster], seen: Dictionary, summon_owner
) -> void:
	if node == null:
		return
	_try_add_pet_dragon_aoe_target(node, radius, targets, seen, summon_owner)
	for child in node.get_children():
		_collect_pet_dragon_aoe_targets_recursive(child, radius, targets, seen, summon_owner)


func _try_add_pet_dragon_aoe_target(
	node: Node, radius: float, targets: Array[BaseMonster], seen: Dictionary, summon_owner
) -> void:
	if not (node is BaseMonster):
		return
	var monster := node as BaseMonster
	if monster.hp <= 0 or monster == summon_owner:
		return
	var instance_id := monster.get_instance_id()
	if seen.has(instance_id):
		return
	if monster.global_position.distance_to(global_position) > radius:
		return
	targets.append(monster)
	seen[instance_id] = true


func _apply_pet_dragon_summon_hit(target: Node) -> void:
	if not (target is BaseMonster):
		return
	var summon_owner = get_meta("summoner", null)
	if target == summon_owner:
		return
	if get_meta("pet_dragon_disabled", false) or get_meta("pet_dragon_damage_applied", false):
		return
	var hit_data: Dictionary = att_list if typeof(att_list) == TYPE_DICTIONARY else {}
	if (
		hit_data.is_empty()
		and obj_attack_dict != null
		and typeof(obj_attack_dict) == TYPE_DICTIONARY
		and obj_attack_dict.has(hit_name)
	):
		hit_data = obj_attack_dict[hit_name]
	if hit_data.is_empty():
		return
	var damage := int(hit_data.get("power", 0))
	if damage <= 0:
		return
	var attack_kind := str(hit_data.get("attackKind", "physics"))
	var hurt_back: Array = hit_data.get("hurtBack", []) if hit_data.get("hurtBack", []) is Array else []
	if skill_name == "PetDragon2Bullet2":
		_apply_pet_dragon_dash_damage(target as BaseMonster, damage, summon_owner, hurt_back, attack_kind)
		return
	set_meta("pet_dragon_damage_applied", true)
	hit_box.set_deferred("monitoring", false)
	_deal_pet_dragon_damage(
		_collect_pet_dragon_aoe_targets(target as BaseMonster),
		damage,
		summon_owner,
		hurt_back if hit_name in ["hit1", "hit3"] else [],
		attack_kind
	)


func _apply_pet_dragon_dash_overlap_damage() -> void:
	if hit_box == null:
		return
	for area in hit_box.get_overlapping_areas():
		var target := _pet_dragon_target_from_hurt_area(area)
		if target != null:
			_apply_pet_dragon_summon_hit(target)


func _pet_dragon_target_from_hurt_area(area: Area2D) -> BaseMonster:
	if area == null:
		return null
	var parent := area.get_parent()
	var target := parent.get_parent() as BaseMonster if parent != null else null
	return target


func _apply_pet_dragon_dash_damage(
	target: BaseMonster, damage: int, summon_owner, hurt_back: Array, attack_kind: String
) -> void:
	if target == null or not is_instance_valid(target) or target.hp <= 0:
		return
	var target_id := target.get_instance_id()
	var now := Time.get_ticks_msec()
	if now < int(pet_dragon_dash_damage_until.get(target_id, 0)):
		return
	pet_dragon_dash_damage_until[target_id] = now + PET_DRAGON_DASH_DAMAGE_INTERVAL_MS
	_deal_pet_dragon_damage([target], damage, summon_owner, hurt_back, attack_kind)


func _deal_pet_dragon_damage(targets: Array, damage: int, summon_owner, hurt_back: Array, attack_kind: String) -> void:
	for aoe_target in targets:
		if not is_instance_valid(aoe_target) or aoe_target.hp <= 0:
			continue
		var resolved_damage := _pet_tiger_resolve_damage(aoe_target, damage, summon_owner, attack_kind)
		if resolved_damage <= 0:
			continue
		var hp_before_hit := int(aoe_target.hp)
		aoe_target.reduce_pet_hp(resolved_damage, attack_kind)
		var actual_damage := maxi(0, hp_before_hit - int(aoe_target.hp))
		if actual_damage > 0:
			_apply_pet_summon_knockback(aoe_target, summon_owner, hurt_back)
			if (
				summon_owner != null
				and is_instance_valid(summon_owner)
				and summon_owner.has_method("record_pet_dragon_damage")
			):
				summon_owner.record_pet_dragon_damage(actual_damage)
			if aoe_target.has_method("play_hit_effect"):
				aoe_target.play_hit_effect(self)


func _apply_pet_summon_knockback(target: BaseMonster, summon_owner, hurt_back: Array) -> void:
	if target == null or not is_instance_valid(target) or hurt_back.size() < 2:
		return
	if target.is_control_immune():
		return
	if int(hurt_back[0]) == 0 and int(hurt_back[1]) == 0:
		return
	var face_left := (
		bool(summon_owner.get("monster_direction"))
		if summon_owner != null and is_instance_valid(summon_owner)
		else false
	)
	target.begin_friendly_knockback_lock(PET_DRAGON_KNOCKBACK_LOCK_TIME)
	if face_left and target.has_method("attack_to_right"):
		target.attack_to_right(hurt_back)
	elif not face_left and target.has_method("attack_to_left"):
		target.attack_to_left(hurt_back)


func _setup_pet_tiger_hit_shape(_name: String) -> void:
	var hit_shape: CollisionShape2D = hit_box.get_node_or_null("Hit_Box")
	if hit_shape == null:
		return
	var shape := CircleShape2D.new()
	shape.radius = _pet_tiger_hit_radius(_name)
	hit_shape.shape = shape
	hit_shape.position = _pet_tiger_hit_offset(_name)


func _pet_tiger_hit_radius(_name: String) -> float:
	match _name:
		"PetTiger1Bullet1":
			return 42.0
		"PetTiger2Bullet1":
			return 58.0
		"PetTiger1Bullet2":
			return 68.0
		"PetTiger2Bullet3_1":
			return 36.0
		"PetTiger2Bullet3_2":
			return 86.0
		"PetTiger3Bullet4_1":
			return 1.0
		"PetTiger3Bullet4_2":
			return 76.0
		_:
			return 60.0


func _pet_tiger_hit_offset(_name: String) -> Vector2:
	match _name:
		"PetTiger2Bullet3_2":
			return Vector2(0.0, 18.0)
		"PetTiger3Bullet4_2":
			return Vector2(0.0, -8.0)
		_:
			return Vector2.ZERO


func _pet_tiger_aoe_radius(_name: String) -> float:
	match _name:
		"PetTiger1Bullet1":
			return 92.0
		"PetTiger2Bullet1":
			return 120.0
		"PetTiger1Bullet2":
			return 150.0
		"PetTiger2Bullet3_1":
			return 110.0
		"PetTiger2Bullet3_2":
			return 210.0
		"PetTiger3Bullet4_2":
			return 190.0
		_:
			return max(90.0, _pet_tiger_hit_radius(_name) * 1.8)


func _collect_pet_tiger_aoe_targets(primary_target: BaseMonster) -> Array:
	var targets: Array = []
	if primary_target == null or not is_instance_valid(primary_target):
		return targets
	var radius := _pet_tiger_aoe_radius(skill_name)
	var tree := get_tree()
	if tree == null:
		targets.append(primary_target)
		return targets
	var seen := {}
	var candidates := _get_level_active_monster_candidates()
	for monster in candidates:
		_try_add_pet_tiger_aoe_target(monster, primary_target, radius, targets, seen)
	var current_scene := tree.current_scene
	if candidates.is_empty() and current_scene != null and current_scene.has_node("Monster"):
		_collect_pet_tiger_aoe_targets_recursive(
			current_scene.get_node("Monster"), primary_target, radius, targets, seen
		)
	if not seen.has(primary_target.get_instance_id()):
		targets.append(primary_target)
	return targets


func _collect_pet_tiger_aoe_targets_recursive(
	node: Node, primary_target: BaseMonster, radius: float, targets: Array, seen: Dictionary
) -> void:
	if node == null:
		return
	_try_add_pet_tiger_aoe_target(node, primary_target, radius, targets, seen)
	for child in node.get_children():
		_collect_pet_tiger_aoe_targets_recursive(child, primary_target, radius, targets, seen)


func _try_add_pet_tiger_aoe_target(
	node: Node, primary_target: BaseMonster, radius: float, targets: Array, seen: Dictionary
) -> void:
	if not (node is BaseMonster):
		return
	if node.hp <= 0:
		return
	var instance_id := node.get_instance_id()
	if seen.has(instance_id):
		return
	if node.global_position.distance_to(primary_target.global_position) > radius:
		return
	targets.append(node)
	seen[instance_id] = true


func _setup_monster5_bullet() -> void:
	if dir == false:
		middle.scale.x = 1
	else:
		middle.scale.x = -1
	if bullet_ani != null:
		bullet_ani.visible = false
		bullet_ani.stop()
		bullet_ani.sprite_frames = null
	monster5_stream_sprite = Sprite2D.new()
	monster5_stream_sprite.name = "Monster5StreamSprite"
	monster5_stream_sprite.position = Vector2(0, -260)
	monster5_stream_sprite.region_enabled = true
	middle.add_child(monster5_stream_sprite)
	var hit_shape := $middle/HitBox/Hit_Box as CollisionShape2D
	if hit_shape != null:
		var rect_shape := RectangleShape2D.new()
		rect_shape.size = Vector2(844, 541.001)
		hit_shape.shape = rect_shape
		hit_shape.position = Vector2(21, -248)
		hit_shape.rotation = 0.0
		hit_shape.disabled = true
	monster5_stream_frame = -1
	monster5_stream_time = 0.0
	get_prop()
	_update_monster5_stream_frame(0)
	state = do


func _physics_monster5_bullet(delta: float) -> void:
	get_prop()
	monster5_stream_time += delta * max(speed, 0.01)
	var frame_index := int(floor(monster5_stream_time * MONSTER5_BULLET_FPS))
	if frame_index >= MONSTER5_BULLET_FRAME_COUNT:
		queue_free()
		return
	_update_monster5_stream_frame(frame_index)


func _update_monster5_stream_frame(frame_index: int) -> void:
	if frame_index == monster5_stream_frame:
		return
	monster5_stream_frame = frame_index
	if frame_index >= MONSTER5_BULLET_FRAME_COUNT - 1:
		if monster5_stream_sprite != null:
			monster5_stream_sprite.texture = null
		monster5_stream_texture = null
	else:
		var sheet_index := _monster5_stream_sheet_index(frame_index)
		var row_index := _monster5_stream_row_index(frame_index)
		if _load_monster5_stream_sheet(sheet_index):
			if monster5_stream_texture != monster5_stream_sheet:
				monster5_stream_texture = monster5_stream_sheet
				monster5_stream_uploaded_sheet_index = sheet_index
				if monster5_stream_sprite != null:
					monster5_stream_sprite.texture = monster5_stream_texture
			if monster5_stream_sprite != null:
				monster5_stream_sprite.region_rect = Rect2(
					Vector2(0, row_index * MONSTER5_BULLET_FRAME_SIZE.y), MONSTER5_BULLET_FRAME_SIZE
				)
	var hit_shape := $middle/HitBox/Hit_Box as CollisionShape2D
	if hit_shape != null:
		hit_shape.disabled = frame_index < 10 or frame_index % 2 == 0


func _load_monster5_stream_sheet(sheet_index: int) -> bool:
	if monster5_stream_sheet_index == sheet_index and monster5_stream_sheet != null:
		return true
	monster5_stream_sheet_index = sheet_index
	var path := "%s/SpecialEffect2-%d.png" % [MONSTER5_BULLET_DIR, sheet_index]
	if monster5_stream_image_cache.has(path):
		monster5_stream_sheet = monster5_stream_image_cache[path] as Texture2D
	else:
		monster5_stream_sheet = null
	return monster5_stream_sheet != null


func _monster5_stream_sheet_index(frame_index: int) -> int:
	if frame_index <= 5:
		return 0
	if frame_index <= 10:
		return 1
	if frame_index <= 37:
		return 2 + int((frame_index - 11) / 3)
	return 11


func _monster5_stream_row_index(frame_index: int) -> int:
	if frame_index <= 5:
		return int(frame_index / 2)
	if frame_index == 6:
		return 0
	if frame_index <= 9:
		return 1
	if frame_index == 10:
		return 2
	if frame_index <= 37:
		return int((frame_index - 11) % 3)
	return 0


func _setup_pet_tiger_bullet(_name: String) -> void:
	if dir == false:
		middle.scale.x = -1
	else:
		middle.scale.x = 1
	_setup_pet_tiger_hit_shape(_name)
	pet_tiger_timeline = _get_cached_pet_tiger_timeline(_name)
	var frames := _get_cached_pet_bullet_frames(_name, pet_tiger_timeline.size(), false)
	if frames == null:
		queue_free()
		return
	bullet_ani.sprite_frames = frames
	bullet_ani.animation = _name
	bullet_ani.position = Vector2.ZERO
	bullet_ani.scale = Vector2(1, 1)
	bullet_ani.self_modulate = Color(1, 1, 1, 1)
	bullet_ani.play(_name)
	bullet_ani.visible = false
	pet_tiger_last_frame = -1
	_update_pet_tiger_layers()
	queue_timer.start(float(frames.get_frame_count(_name)) / PET_TIGER_BULLET_FPS + 0.02)
	state = do


func _physics_pet_tiger_bullet(delta: float) -> void:
	get_prop()
	_update_pet_tiger_layers()
	if bullet_ani.sprite_frames != null and bullet_ani.sprite_frames.has_animation(skill_name):
		var timeline := pet_tiger_timeline
		var has_visible_frame := false
		if not timeline.is_empty():
			var frame_index: int = clampi(bullet_ani.frame, 0, timeline.size() - 1)
			has_visible_frame = not Array(timeline[frame_index]).is_empty()
		hit_box.monitoring = has_visible_frame and not bool(get_meta("pet_tiger_disabled", false))
	if throw_count > int(PET_TIGER_BULLET_FPS * 2.0):
		queue_free()


func do_action(_name):
	if String(_name).is_empty():
		return
	if not bullet_player.has_animation(_name):
		return
	if dir == false:
		middle.scale.x = 1
	else:
		middle.scale.x = -1
	bullet_player.speed_scale = speed
	_prepare_bullet_animation_material(_name)
	bullet_player.play(_name)

	if _name == "Monster1410Bullet1":
		return

	if (
		_name != "Monster55Bullet"
		or _name != "Monster58Bullet"
		or _name != "Monster101Bullet2"
		or _name != "Monster100Bullet"
	):
		await bullet_player.animation_finished
		state = remove


func _apply_pet_tiger_id60_six_hit(role: Node) -> void:
	if skill_name != "PetTiger3Bullet4_2" or hit_name != "hsqj":
		return
	if has_meta("pet_tiger_id60_six_hit_started"):
		return
	if role == null or not is_instance_valid(role):
		return
	if not role.has_method("effect_reducehp"):
		return
	var owner := my_father
	if owner == null and get_parent() != null and get_parent().get_parent() is BaseMonster:
		owner = get_parent().get_parent()
	var hit_data = att_list
	if owner != null and owner.obj_attack_dict != null and owner.obj_attack_dict.has(hit_name):
		hit_data = owner.obj_attack_dict[hit_name]
	if typeof(hit_data) != TYPE_DICTIONARY or not hit_data.has("power"):
		return
	var attack_kind := "magic"
	if hit_data.has("attackKind"):
		attack_kind = String(hit_data["attackKind"])
	var damage_per_hit := int(hit_data["power"])
	if damage_per_hit <= 0:
		return
	set_meta("pet_tiger_id60_six_hit_started", true)
	hit_box.set_deferred("monitoring", false)
	for i in range(6):
		if role == null or not is_instance_valid(role):
			return
		role.effect_reducehp(damage_per_hit, attack_kind)
		if i < 5:
			await get_tree().create_timer(0.08, false).timeout


func _pet_tiger_resolve_damage(target: BaseMonster, base_damage: int, summon_owner, attack_kind: String) -> int:
	if target == null or base_damage <= 0:
		return 0
	var owner: Node = (
		summon_owner as Node if typeof(summon_owner) == TYPE_OBJECT and is_instance_valid(summon_owner) else null
	)
	return target.resolve_friendly_damage(base_damage, attack_kind, owner)


func _apply_pet_tiger_summon_hit(target: Node) -> void:
	if not (target is BaseMonster):
		return
	if get_meta("pet_tiger_disabled", false):
		return
	if obj_attack_dict == null or typeof(obj_attack_dict) != TYPE_DICTIONARY or not obj_attack_dict.has(hit_name):
		return
	var hit_data: Dictionary = obj_attack_dict[hit_name]
	var attack_kind := str(hit_data.get("attackKind", "physics"))
	var summon_owner = get_meta("summoner", null)
	var targets := _collect_pet_tiger_aoe_targets(target)
	if skill_name == "PetTiger3Bullet4_2" and hit_name == "hsqj":
		if get_meta("pet_tiger_summon_id60_started", false):
			return
		set_meta("pet_tiger_summon_id60_started", true)
		var damage_per_hit := int(hit_data.get("power", 0))
		for i in range(6):
			var has_live_target := false
			for aoe_target in targets:
				if not is_instance_valid(aoe_target) or aoe_target.hp <= 0:
					continue
				if aoe_target.is_boss_protecting():
					continue
				has_live_target = true
				var resolved_damage := _pet_tiger_resolve_damage(aoe_target, damage_per_hit, summon_owner, attack_kind)
				if resolved_damage <= 0:
					continue
				var hp_before_hit := int(aoe_target.hp)
				aoe_target.reduce_pet_hp(resolved_damage, attack_kind)
				var actual_damage := maxi(0, hp_before_hit - int(aoe_target.hp))
				if actual_damage > 0:
					_apply_pet_summon_knockback(aoe_target, summon_owner, hit_data.get("hurtBack", []))
					if aoe_target.has_method("play_hit_effect"):
						aoe_target.play_hit_effect(self)
			if not has_live_target:
				return
			if i < 5:
				await get_tree().create_timer(0.08, false).timeout
		return
	var damage := int(hit_data.get("power", 0))
	if hit_name == "sxhz":
		var hit_list := [damage, damage * 7, damage * 12]
		for aoe_target in targets:
			if not is_instance_valid(aoe_target) or aoe_target.hp <= 0:
				continue
			if aoe_target.is_boss_protecting():
				continue
			var sxhz_damage_until: int = int(aoe_target.get_meta("pet_tiger_sxhz_damage_until", 0))
			if Time.get_ticks_msec() < sxhz_damage_until:
				continue
			aoe_target.set_meta("pet_tiger_sxhz_damage_until", Time.get_ticks_msec() + 500)
			_hold_pet_tiger_sxhz_target(aoe_target, 3.0)
			for i in range(hit_list.size()):
				if not is_instance_valid(aoe_target) or aoe_target.hp <= 0:
					break
				var hit_damage: int = _pet_tiger_resolve_damage(
					aoe_target, max(1, int(hit_list[i])), summon_owner, attack_kind
				)
				if hit_damage <= 0:
					continue
				var hp_before_hit := int(aoe_target.hp)
				aoe_target.reduce_pet_hp(hit_damage, attack_kind)
				var actual_damage := maxi(0, hp_before_hit - int(aoe_target.hp))
				if actual_damage > 0:
					if aoe_target.has_method("play_hit_effect"):
						aoe_target.play_hit_effect(self)
					_cure_pet_tiger_summoner(summon_owner, actual_damage)
				if i < hit_list.size() - 1:
					await get_tree().create_timer(0.08, false).timeout
		return
	var normal_damage: int = max(1, damage)
	for aoe_target in targets:
		if not is_instance_valid(aoe_target) or aoe_target.hp <= 0:
			continue
		var resolved_damage := _pet_tiger_resolve_damage(aoe_target, normal_damage, summon_owner, attack_kind)
		if resolved_damage <= 0:
			continue
		var hp_before_hit := int(aoe_target.hp)
		aoe_target.reduce_pet_hp(resolved_damage, attack_kind)
		var actual_damage := maxi(0, hp_before_hit - int(aoe_target.hp))
		if actual_damage > 0 and hit_name in ["hit1", "hy"]:
			_apply_pet_summon_knockback(aoe_target, summon_owner, hit_data.get("hurtBack", []))
		if actual_damage > 0 and aoe_target.has_method("play_hit_effect"):
			aoe_target.play_hit_effect(self)


func _hold_pet_tiger_sxhz_target(target: Node, duration: float) -> void:
	if target == null or not is_instance_valid(target):
		return
	if not (target is BaseMonster):
		return
	if target.is_control_immune():
		return
	var hold_position: Vector2 = global_position
	var hold_token: int = Time.get_ticks_msec()
	target.set_meta("pet_tiger_sxhz_hold_token", hold_token)
	target.set_meta("pet_tiger_sxhz_hold_until", Time.get_ticks_msec() + int(duration * 1000.0))
	target.set_meta("pet_tiger_sxhz_hold_position", hold_position)
	target.set("global_position", hold_position)
	if "no_grav" in target:
		target.no_grav = true
	if "is_stun" in target:
		target.is_stun = true
	if "is_be_attacking" in target:
		target.is_be_attacking = true
	if "velocity" in target:
		target.velocity = Vector2.ZERO
	if target.has_node("mr"):
		var player = target.get_node_or_null("mr")
		if (
			player != null
			and player.has_method("has_animation")
			and player.has_animation("hurt")
			and player.has_method("play")
		):
			player.play("hurt")
	if target.has_node("Buff"):
		var stun_effect = {
			"Name": "stun",
			"AddTime": duration,
			"reduce_interval": 1,
			"value": 0,
			"AttackKind": "",
			"DeBuff": true,
			"CanRemove": false,
			"PetTigerSxhz": true
		}
		Global.add_buff(target.get_node("Buff"), stun_effect)


func _cure_pet_tiger_summoner(summon_owner, value: int) -> void:
	if value <= 0:
		return
	if summon_owner != null and is_instance_valid(summon_owner) and summon_owner.has_method("cure_hp"):
		summon_owner.cure_hp(value)


func _on_hit_box_area_entered(area: Area2D) -> void:
	var target = _get_hit_owner(area)

	if skill_name == "Monster1410Bullet1" and bullet_player.current_animation == "Monster1410Bullet1_1":
		if target == RoleProp.source_player or (target and target.is_in_group("players")):
			var stun_effect = {
				"Name": "stun",
				"AddTime": 2,
				"reduce_interval": 0,
				"value": 0,
				"AttackKind": "",
				"DeBuff": true,
				"CanRemove": false
			}
			Global.add_buff(target.buff, stun_effect)
			if not clone_spawned and my_father and my_father.has_method("spawn_clone"):
				clone_spawned = true
				my_father.call_deferred("spawn_clone")

	if get_parent().get_parent() is Monster85:
		get_parent().get_parent().hit_count += 1

	var role = target
	if not role:
		return
	if role is BaseMonster:
		if get_meta("pet_tiger_summon", false):
			_apply_pet_tiger_summon_hit(role)
		elif get_meta("pet_dragon_summon", false):
			_apply_pet_dragon_summon_hit(role)
		elif get_meta("pet_phoenix_summon", false):
			_apply_pet_phoenix_summon_hit(role)
		return
	_apply_pet_tiger_id60_six_hit(role)
	if skill_name == "PetTiger3Bullet4_2" and hit_name == "hsqj":
		return
	if not ("buff" in role):
		return

	var applied_add_effect := false
	if obj_attack_dict != null and typeof(obj_attack_dict) == TYPE_DICTIONARY:
		if obj_attack_dict.has(hit_name):
			var hit_data = obj_attack_dict[hit_name]

			if typeof(hit_data) == TYPE_DICTIONARY and hit_data.has("addeffect"):
				var effect = hit_data["addeffect"]
				if skill_name == "Monster83Bullet":
					if randi_range(0, 100) < 65:
						Global.add_buff(role.buff, effect)
				else:
					Global.add_buff(role.buff, effect)
				applied_add_effect = true
	if skill_name == "Monster118Bullet2" and not applied_add_effect:
		Global.add_buff(
			role.buff,
			{
				"Name": "poision",
				"AddTime": 5,
				"CanAdd": true,
				"DeBuff": true,
				"CanRemove": false,
				"reduce_interval": 0,
				"value": 900,
				"AttackKind": "magic"
			}
		)

	if skill_name == "Monster90Bullet":
		queue_free()


func _get_hit_owner(area: Area2D) -> Node:
	var node: Node = area
	while node != null:
		if node is BaseHero or node is BaseMonster:
			return node
		node = node.get_parent()
	return null


func get_prop():
	self.obj_attack_dict[hit_name] = att_list


func _prepare_bullet_animation_material(animation_name: String) -> void:
	if bullet_ani == null or bullet_player == null or not bullet_player.has_animation(animation_name):
		return
	var animation := bullet_player.get_animation(animation_name)
	if animation == null:
		return
	for track_index in range(animation.get_track_count()):
		if animation.track_get_type(track_index) != Animation.TYPE_VALUE:
			continue
		if animation.track_get_path(track_index) != NodePath("middle/BulletANI:material"):
			continue
		if animation.track_get_key_count(track_index) <= 0:
			return
		var material = animation.track_get_key_value(track_index, 0)
		if material is Material:
			bullet_ani.material = material
		return


func call_monster_56_bullet():
	state = remove
	bullet_player.speed_scale = 1.8
	_prepare_bullet_animation_material("Monster56Bullet")
	bullet_player.play("Monster56Bullet")
	await bullet_player.animation_finished


func shake(strength, times, interv):
	var baselevel = get_parent().get_parent().get_parent().get_parent() as BaseLevel
	baselevel._shake_screen(strength, times, interv)


func monster_70_bullet_2():
	if get_parent().get_parent() is BaseMonster:
		var po = Vector2()
		if not dir:
			po = Vector2(-168, 140)
		else:
			po = Vector2(168, 140)
		if show_monster71:
			Global.add_bullet(
				"monster_70_bullet_2",
				get_parent().get_parent().bullet,
				dir,
				1,
				po + position,
				hit_name,
				obj_attack_dict
			)


func move_player_toself():
	var tween = create_tween()
	tween.tween_property(RoleProp.source_player, "position", position, 0.6)


func tween_to_player():
	await get_tree().create_timer(0.2, false).timeout
	var desired_angle
	desired_angle = position.angle_to_point(RoleProp.source_player.position)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "rotation", desired_angle, 0.2)


func call_monster_114_bullet():
	var _bullet = Global.add_bullet(
		"Monster114Bullet2",
		get_parent().get_parent().bullet,
		false,
		2,
		Vector2(9, -120) + position,
		hit_name,
		obj_attack_dict
	)
	_bullet.look_at(RoleProp.get_nearest_monster_target_position(_bullet.global_position))


func _on_hit_box_body_entered(body: Node2D) -> void:
	if skill_name == "Monster1410Bullet1":
		return

	if skill_name == "Monster110Bullet":
		if throw_count > 60:
			if body is BaseMonster:
				if body is Monster110:
					body.cure_hp(body.max_hp * 0.05)
					body.skill_1_cd = 0
					self.queue_free()
	if skill_name == "Monster142Bullet1":
		if can_cure:
			if body is BaseMonster:
				if body is Monster142:
					body.cure_hp(body.max_hp * 0.1)
					body.skill_1_cd = 0


func call_monster_137_bullet_2():
	var _bullet = Global.add_bullet(
		"Monster137Bullet2",
		get_parent().get_parent().bullet,
		false,
		0.5,
		Vector2(self.position.x, 500),
		hit_name,
		obj_attack_dict
	)


func look_at_player():
	if has_meta("is_summon_bullet") and get_meta("is_summon_bullet") == true:
		var tree = get_tree()
		if tree:
			var all_monsters = []
			var monster_nodes: Array = _get_level_active_monster_candidates()

			for monster in monster_nodes:
				if monster and monster is BaseMonster:
					if monster.hp > 0:
						all_monsters.append(monster)

			if all_monsters.size() == 0:
				var current_scene = tree.current_scene
				if current_scene and current_scene.has_node("Monster"):
					var monster_container = current_scene.get_node("Monster")
					if monster_container:
						for child in monster_container.get_children():
							if child and child is BaseMonster and child.hp > 0:
								all_monsters.append(child)

			if all_monsters.size() > 0:
				var closest_monster = null
				var closest_distance = INF
				for monster in all_monsters:
					var distance = position.distance_to(monster.position)
					if distance < closest_distance:
						closest_distance = distance
						closest_monster = monster

				if closest_monster:
					self.look_at(closest_monster.position)
					return

	self.look_at(RoleProp.source_player.position)


func can_curee():
	can_cure = true


func add_round_shallow():
	if is_throw:
		var effect_scene := load("res://Scene/hero/role_1/ws_effect.tscn") as PackedScene
		if effect_scene == null:
			return
		var ws_effect = effect_scene.instantiate()
		ws_effect.add_child(bullet_ani.duplicate())
		ws_effect.live_time = 0.4
		ws_effect.color = Color(1, 1, 1, 0.8)
		ws_effect.set("position", get("position"))
		get_parent().add_child(ws_effect)


func _on_queue_timer_timeout() -> void:
	if skill_name == "Monster1410Bullet1":
		destroy_with_explosion()
	else:
		queue_free()


func _on_is_throw_close_timeout() -> void:
	is_throw = false


func move_with_reflection(velocity: Vector2, delta: float):
	var space_state = get_world_2d().direct_space_state
	var target_pos = position + velocity * delta

	var query = PhysicsRayQueryParameters2D.new()
	query.from = position
	query.to = target_pos
	query.collision_mask = 1
	query.exclude = [self]

	var result = space_state.intersect_ray(query)

	if result:
		var normal = result.normal
		var hit_point = result.position

		var new_velocity = velocity.bounce(normal)

		position = hit_point

		bounce_velocity = new_velocity

		position += bounce_velocity.normalized() * 2
	else:
		position = target_pos


func destroy_with_explosion():
	if is_exploding:
		return
	is_exploding = true
	monster1410_life_left = -1.0
	if active_1410_bullets.has(self):
		active_1410_bullets.erase(self)

	bounce_velocity = Vector2.ZERO

	if bullet_player != null and bullet_player.has_animation("Monster1410Bullet1_1"):
		_prepare_bullet_animation_material("Monster1410Bullet1_1")
		bullet_player.play("Monster1410Bullet1_1")
		await get_tree().create_timer(0.45, false).timeout
	queue_free()


func redirect_to_player():
	if not is_inside_tree():
		return
	var player = RoleProp.source_player
	if player and is_instance_valid(player):
		var new_dir = (player.global_position - global_position).normalized()
		var speed = bounce_velocity.length()
		bounce_velocity = new_dir * speed

		look_at(player.global_position)


func _on_1410_bullet_exited():
	var idx = active_1410_bullets.find(self)
	if idx != -1:
		active_1410_bullets.remove_at(idx)


static func get_active_1410_bullet_count() -> int:
	for index in range(active_1410_bullets.size() - 1, -1, -1):
		var bullet = active_1410_bullets[index]
		if not is_instance_valid(bullet):
			active_1410_bullets.remove_at(index)
	return active_1410_bullets.size()


static func clear_all_1410_bullets() -> void:
	var bullets_snapshot = active_1410_bullets.duplicate()
	active_1410_bullets.clear()
	for bullet in bullets_snapshot:
		if is_instance_valid(bullet):
			bullet.queue_free()


static func explode_all_1410():
	var bullets_snapshot = active_1410_bullets.duplicate()
	for bullet in bullets_snapshot:
		_handle_bullet_explode(bullet)


static func _handle_bullet_explode(bullet):
	if not is_instance_valid(bullet) or bullet.is_exploding:
		return
	bullet.redirect_to_player()
	await bullet.get_tree().create_timer(1.0).timeout
	if is_instance_valid(bullet) and not bullet.is_exploding:
		bullet.destroy_with_explosion()
