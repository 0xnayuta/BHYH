extends AnimatedSprite2D

const HUAHAO_WING_FRAME_DIR := "res://Art/hero_picture/wings/hhyq"
const XIANYU_WING_PATHS := {
	1: "res://Art/hero_picture/wings/xyzy/role1.tres",
	2: "res://Art/hero_picture/wings/xyzy/role2.tres",
	3: "res://Art/hero_picture/wings/xyzy/role3.tres",
	4: "res://Art/hero_picture/wings/xyzy/role4.tres",
	5: "res://Art/hero_picture/wings/xyzy/role5.tres",
	6: "res://Art/hero_picture/wings/xyzy/role6.tres",
}
const ROLE_SCRIPT_IDS := {
	"res://Script/hero/role1.gd": 1,
	"res://Script/hero/role_2.gd": 2,
	"res://Script/hero/role_3.gd": 3,
	"res://Script/hero/role_4.gd": 4,
	"res://Script/hero/role_5.gd": 5,
	"res://Script/hero/ne_zha_hero.gd": 6,
}


func _ready() -> void:
	if not animation_changed.is_connected(_on_animation_changed):
		animation_changed.connect(_on_animation_changed)
	if sprite_frames != null:
		sprite_frames = sprite_frames.duplicate(false)
	_ensure_xianyu_wing_animation()
	_ensure_huahao_wing_animation()
	_apply_preview_transform()


func _on_animation_changed() -> void:
	_apply_preview_transform()


func _physics_process(_delta: float) -> void:
	_apply_preview_transform()


func _process(_delta: float) -> void:
	_apply_preview_transform()


func _apply_preview_transform() -> void:
	flip_h = animation == &"xyzy" or animation == &"hhyq"
	z_index = 0
	match animation:
		&"xtzy", &"ttzy":
			scale = Vector2(1.6, 1.6)
			offset = Vector2.ZERO
		&"xqzy":
			scale = Vector2(1.2, 1.2)
			offset = Vector2(5, 15)
		&"jmzy":
			scale = Vector2(1.1, 1.1)
			offset = Vector2(20, 15)
		&"xmzy":
			scale = Vector2.ONE
			offset = Vector2(20, -15)
		&"bszy", &"wyzy":
			scale = Vector2.ONE
			offset = Vector2(15, 15)
		&"xyzy":
			scale = Vector2.ONE
			offset = Vector2.ZERO
		&"hhyq":
			scale = Vector2.ONE
			offset = Vector2(60, 0)
		_:
			scale = Vector2.ONE
			offset = Vector2(15, 15)


func _ensure_xianyu_wing_animation() -> void:
	if sprite_frames == null:
		return
	var source_frames := _get_role_frames()
	if source_frames == null or not source_frames.has_animation(&"xyzy"):
		return
	if sprite_frames.has_animation(&"xyzy"):
		sprite_frames.remove_animation(&"xyzy")
	sprite_frames.add_animation(&"xyzy")
	sprite_frames.set_animation_loop(&"xyzy", source_frames.get_animation_loop(&"xyzy"))
	sprite_frames.set_animation_speed(&"xyzy", source_frames.get_animation_speed(&"xyzy"))
	for frame_index in source_frames.get_frame_count(&"xyzy"):
		sprite_frames.add_frame(
			&"xyzy",
			source_frames.get_frame_texture(&"xyzy", frame_index),
			source_frames.get_frame_duration(&"xyzy", frame_index)
		)


func _ensure_huahao_wing_animation() -> void:
	if sprite_frames == null or sprite_frames.has_animation(&"hhyq"):
		return
	sprite_frames.add_animation(&"hhyq")
	sprite_frames.set_animation_loop(&"hhyq", true)
	sprite_frames.set_animation_speed(&"hhyq", 30.0)
	for frame_index in range(1, 41):
		var texture := load("%s/%d.png" % [HUAHAO_WING_FRAME_DIR, frame_index]) as Texture2D
		if texture != null:
			sprite_frames.add_frame(&"hhyq", texture)


func _get_role_frames() -> SpriteFrames:
	var backpack_root := get_parent().get_parent()
	var player = backpack_root.get("Player") if backpack_root != null else null
	var role_id := clampi(int(PlayerData.player_data.get("Myself", 1)), 1, 6)
	if player != null:
		var role_script := player.get_script() as Script
		if role_script != null:
			role_id = int(ROLE_SCRIPT_IDS.get(role_script.resource_path, role_id))
	return load(str(XIANYU_WING_PATHS[role_id])) as SpriteFrames
