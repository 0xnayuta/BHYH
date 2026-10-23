extends Game4ImportedLevel

const MINGHAI_BACKGROUND_FRAMES := "res://Art/level/game_4_level/runtime_atlas/level_62_background.tres"
const MINGHAI_BACKGROUND_SEAM_SHADER := preload("res://Shader/minghai_background_seam.gdshader")
const MINGHAI_TRIGGER_X := [0.0]
const MINGHAI_BIRTH_POINTS := [
	{
		"point": 1,
		"stage": 1,
		"monster": 3117,
		"position": Vector2(666, 144),
		"total": 1,
		"interval": 1.0,
		"face": 1,
		"after_spawn": 0,
		"after_dead": 0
	},
]

const LEVEL_62_MONSTER_DATA := {
	3117:
	{
		"name": "通天教主(穷奇版)",
		"level": 90,
		"hp": 45000000,
		"attack": 44000,
		"def": 8600,
		"mdef": 8600,
		"crit": 700,
		"miss": 490,
		"hit": 500,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 8500,
		"magic_break": 8500,
		"speed": 10.0,
		"min_range": 0.0,
		"range": 180.0,
		"sight": 1200.0,
		"attack_desire": 100,
		"exp": 0,
		"coin": 0,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": true,
		"max_protect": 240.0,
		"attacks":
		{
			"hit1": {"multiplier": 0.5, "hurt_back": [-5.0, -2.0], "kind": "physics", "protect": 6668},
			"hit2": {"multiplier": 1.0, "hurt_back": [-3.0, -1.0], "kind": "magic", "protect": 6668},
			"hit3": {"multiplier": 1.0, "hurt_back": [-4.0, -3.0], "kind": "magic", "protect": 6668},
		},
	},
}

@onready var _background_animation := get_node_or_null("back_ground/floor_2/bg12_1") as AnimatedSprite2D


func _ready() -> void:
	super._ready()
	if _role != null:
		_role.position = Vector2(31, 446)
		_role.set_meta("disable_down_drop", true)
	_setup_background_frames()


func _setup_background_frames() -> void:
	if _background_animation == null:
		return
	var frames := load(MINGHAI_BACKGROUND_FRAMES) as SpriteFrames
	if frames == null or not frames.has_animation("play"):
		return
	_background_animation.sprite_frames = frames
	var seam_material := ShaderMaterial.new()
	seam_material.shader = MINGHAI_BACKGROUND_SEAM_SHADER
	_background_animation.material = seam_material
	_background_animation.play("play")


func _stage_count() -> int:
	return 1


func _screen_starts() -> Array:
	return [0.0]


func _screen_rights() -> Array:
	return [1200.0]


func _stage_trigger_x() -> Array:
	return MINGHAI_TRIGGER_X


func _birth_points() -> Array:
	return MINGHAI_BIRTH_POINTS


func get_level_monster_config(monster_id: int) -> Dictionary:
	var config: Variant = LEVEL_62_MONSTER_DATA.get(monster_id, {})
	return (config as Dictionary).duplicate(true) if config is Dictionary else {}


func _level_number() -> int:
	return 62


func _on_fall_death_body_entered(body: Node2D) -> void:
	if body == _role:
		RoleProp.roleprop.Hp = 0
