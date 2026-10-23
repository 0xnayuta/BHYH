extends Node2D
class_name LiuShaRiverShadow

const SOURCE_FPS := 24.0
const SHADOW_ROOT := "res://Art/monster/liu_sha_river"

const ACTIONS := {
	31:
	{
		"walk": ["walk", [4, 4, 4, 4], true],
		"hit1": ["hit1", [2, 10, 2, 40], false],
		"hit2": ["hit2", [2, 2, 20], false],
		"hit3": ["hit3", [30], false],
		"hit4": ["hit4", [55], false],
	},
	34:
	{
		"walk": ["walk", [72, 72, 72, 72, 72], true],
		"hit1": ["hit1", [2, 3, 2, 3], false],
		"hit2": ["hit2", [2, 12, 16], false],
	},
}

const ATTACK_EVENTS := {
	31:
	{
		"hit1": [[12.0 / SOURCE_FPS, "hit3"]],
		"hit2": [[4.0 / SOURCE_FPS, "hit6"]],
		"hit3": [[10.0 / SOURCE_FPS, "hit8"]],
		"hit4": [[0.0, "hit9_1"], [10.0 / SOURCE_FPS, "hit9_2"]],
	},
	34:
	{
		"hit1": [[0.0, "hit8"]],
		"hit2": [[0.0, "hit14_1"], [14.0 / SOURCE_FPS, "hit14_2"]],
	},
}

var boss_kind := 31
var boss: Node = null
var facing_right := true

var _sprite: AnimatedSprite2D
var _life_left := 3.0
var _attacking := false
var _pending: Array = []


func setup(kind: int, owner_boss: Node, lifetime: float, foot_baseline: int) -> void:
	boss_kind = kind
	boss = owner_boss
	_life_left = lifetime
	if not ACTIONS.has(kind):
		queue_free()
		return
	_build_frames(foot_baseline)
	_sprite.play("walk")

	var walk_frames := _sprite.sprite_frames.get_frame_count("walk")
	if walk_frames > 1:
		_sprite.frame = randi_range(0, walk_frames - 1)


func _build_frames(_foot_baseline: int) -> void:
	_sprite = AnimatedSprite2D.new()
	_sprite.name = "ShadowBody"
	_sprite.centered = true
	_sprite.z_index = 4
	var folder := "shadow_%d" % (1 if boss_kind == 34 else 2)
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	var config: Dictionary = ACTIONS[boss_kind]
	for action_value in config:
		var action := str(action_value)
		var data: Array = config[action]
		var holds: Array = data[1]
		frames.add_animation(action)
		frames.set_animation_loop(action, bool(data[2]))
		frames.set_animation_speed(action, SOURCE_FPS)
		for index in range(holds.size()):
			var path := "%s/%s/%s/%d.png" % [SHADOW_ROOT, folder, action, index + 1]
			var texture := ResourceLoader.load(path, "Texture2D", ResourceLoader.CACHE_MODE_REUSE) as Texture2D
			if texture == null:
				push_error("流沙河分身帧缺失: " + path)
				continue
			frames.add_frame(action, texture, float(holds[index]))
	_sprite.sprite_frames = frames
	add_child(_sprite)

	var source_offset := Vector2(15 if facing_right else -15, -5)
	_sprite.position = LiuShaRiverBoss.SOURCE_ORIGIN_OFFSETS[boss_kind] + source_offset
	_sprite.flip_h = not facing_right


func _texture_alpha_bottom(texture: Texture2D) -> int:
	var image := texture.get_image()
	if image == null or image.is_empty():
		return 0
	for y in range(image.get_height() - 1, -1, -1):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.02:
				return y
	return 0


func _process(delta: float) -> void:
	if boss == null or not is_instance_valid(boss) or boss.death():
		queue_free()
		return
	if _life_left <= 0.0:
		return
	_life_left -= delta
	if _life_left <= 0.0:
		queue_free()


func play_attack(action: String) -> void:
	if _attacking or _sprite == null:
		return
	if not _sprite.sprite_frames.has_animation(action):
		return
	_attacking = true
	_pending = ATTACK_EVENTS.get(boss_kind, {}).get(action, []).duplicate()
	_sprite.play(action)
	var length := _animation_length(action)
	var token := get_instance_id()
	get_tree().create_timer(maxf(length, 0.05), false).timeout.connect(_finish_attack.bind(token), CONNECT_ONE_SHOT)
	for entry in _pending:
		var delay := float(entry[0])
		if delay <= 0.0:
			_emit_attack(str(entry[1]))
		else:
			get_tree().create_timer(delay, false).timeout.connect(_emit_attack.bind(str(entry[1])), CONNECT_ONE_SHOT)
	_pending.clear()


func _animation_length(action: String) -> float:
	var data: Array = ACTIONS[boss_kind][action]
	var holds: Array = data[1]
	var total := 0.0
	for hold_value in holds:
		total += float(hold_value)
	return total / SOURCE_FPS


func _emit_attack(event_name: String) -> void:
	if boss == null or not is_instance_valid(boss):
		return
	if not is_inside_tree():
		return
	var direction := 1.0 if facing_right else -1.0
	var offset := Vector2.ZERO
	match event_name:
		"hit3":
			offset = Vector2(0, 10)
		"hit6":
			offset = Vector2(0, -25)
		"hit8":
			offset = Vector2(-direction * 5, -60) if boss_kind == 31 else Vector2(-direction * 20, 30)
		"hit9_1":
			offset = Vector2(direction * 20, -20)
		"hit9_2":
			offset = Vector2(direction * 150, -150)
		"hit14_1":
			offset = Vector2(0, -85)
		"hit14_2":
			offset = Vector2(direction * 145, -60)
	boss.call(
		"spawn_shadow_attack",
		event_name,
		global_position + LiuShaRiverBoss.SOURCE_ORIGIN_OFFSETS[boss_kind] + offset,
		facing_right
	)


func _finish_attack(token: int) -> void:
	if token != get_instance_id() or not is_inside_tree():
		return
	_attacking = false
	queue_free()
