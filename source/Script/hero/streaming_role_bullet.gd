extends RoleBullet
class_name StreamingRoleBullet

@onready var stream_visual: Sprite2D = $Middle/StreamVisual

static var _texture_caches: Dictionary = {}
static var _warming: Dictionary = {}
static var _cache_generation := 0


static func _paths_for(bullet_name: String) -> Array[String]:
	var paths: Array[String] = []
	if bullet_name == "TtzsszBullet":
		for index in range(23):
			paths.append("res://Art/hero_picture/ttzssz_bullet_cropped/%d.png" % (index + 1))
	elif bullet_name == "Role3Bullet2":
		for index in range(27):
			paths.append("res://Art/hero_picture/role_3/role_3_bullet_2_stream/%02d.png" % index)
	return paths


static func prewarm_bullet_frames(bullet_name: String) -> void:
	if bool(_warming.get(bullet_name, false)):
		return
	var paths := _paths_for(bullet_name)
	var cached: Array = _texture_caches.get(bullet_name, [])
	if cached.size() == paths.size():
		return
	_warming[bullet_name] = true
	var generation := _cache_generation
	var tree := Engine.get_main_loop() as SceneTree
	cached.clear()
	cached.resize(paths.size())
	var batch_size := 2 if OS.has_feature("mobile") else 4
	for batch_start in range(0, paths.size(), batch_size):
		var batch_end := mini(batch_start + batch_size, paths.size())
		for index in range(batch_start, batch_end):
			ResourceLoader.load_threaded_request(paths[index], "Texture2D", false, ResourceLoader.CACHE_MODE_REUSE)
		for index in range(batch_start, batch_end):
			var path := paths[index]
			while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				if tree == null:
					break
				await tree.process_frame
				if generation != _cache_generation:
					_warming.erase(bullet_name)
					return
			if ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_LOADED:
				cached[index] = ResourceLoader.load_threaded_get(path) as Texture2D
	_texture_caches[bullet_name] = cached
	_warming.erase(bullet_name)


static func clear_cached_frames() -> void:
	_cache_generation += 1
	_warming.clear()
	_texture_caches.clear()


var _frame_paths: Array[String] = []
var _frame_offsets: Array[Vector2] = []
var _frame_times: Array[float] = []
var _collision_times: Array[float] = []
var _collision_disabled: Array[bool] = []
var _collision_positions: Array[Vector2] = []
var _collision_scales: Array[Vector2] = []
var _life_time := 1.0
var _elapsed := 0.0
var _frame_index := -1
var _collision_index := -1
var _collision_position_index := -1
var _collision_scale_index := -1


func _physics_process(delta: float) -> void:
	if not is_set:
		_setup_streaming_bullet()
		is_set = true
	_elapsed += delta
	_update_stream_frame()
	_update_collision_tracks()
	if _elapsed >= _life_time:
		queue_free()


func _setup_streaming_bullet() -> void:
	if NodeUtils.ancestor(self, 2) is BaseHero:
		player = NodeUtils.ancestor(self, 2)
	elif NodeUtils.ancestor(self, 1) is BaseHero:
		player = NodeUtils.ancestor(self, 1)
	middle.scale.x = -1 if direction else 1
	bullet_player.visible = false
	var special_effect := get_node_or_null("Middle/SpecialEffect") as AnimatedSprite2D
	if special_effect != null:
		special_effect.visible = false
	if _name == "TtzsszBullet":
		_setup_ttzssz()
	elif _name == "Role3Bullet2":
		_setup_role3_bullet2()
	else:
		queue_free()
		return
	_elapsed = 0.0
	_frame_index = -1
	_collision_index = -1
	_collision_position_index = -1
	_collision_scale_index = -1
	_update_stream_frame()
	_update_collision_tracks()


func _setup_ttzssz() -> void:
	_life_time = 1.0
	stream_visual.self_modulate = Color(1, 1, 1, 1)
	stream_visual.scale = Vector2.ONE
	stream_visual.rotation = 0.0
	_frame_paths.clear()
	_frame_offsets.clear()
	_frame_times.clear()
	var original_size := Vector2(1005, 1011)
	var boxes := [
		Rect2(489, 6, 419, 931),
		Rect2(489, 99, 337, 756),
		Rect2(489, 193, 255, 579),
		Rect2(72, 160, 799, 829),
		Rect2(154, 242, 625, 642),
		Rect2(237, 325, 448, 453),
		Rect2(228, 317, 731, 647),
		Rect2(216, 246, 635, 653),
		Rect2(216, 246, 526, 652),
		Rect2(17, 70, 972, 828),
		Rect2(101, 111, 775, 787),
		Rect2(101, 111, 662, 787),
		Rect2(101, 111, 662, 787),
		Rect2(59, 15, 720, 836),
		Rect2(59, 15, 719, 836),
		Rect2(59, 15, 798, 836),
		Rect2(54, 15, 899, 725),
		Rect2(54, 15, 899, 725),
		Rect2(54, 16, 899, 724),
		Rect2(54, 360, 899, 380),
		Rect2(54, 360, 898, 380),
		Rect2(54, 360, 898, 379),
		Rect2(0, 0, 1, 1)
	]
	for i in range(boxes.size()):
		_frame_paths.append("res://Art/hero_picture/ttzssz_bullet_cropped/%d.png" % (i + 1))
		var box: Rect2 = boxes[i]
		_frame_offsets.append(box.position + box.size * 0.5 - original_size * 0.5)
		_frame_times.append(float(i) / 24.0)
	var circle := CircleShape2D.new()
	circle.radius = 176.071
	collion.shape = circle
	_collision_times = [0.0, 0.3, 0.6, 0.9]
	_collision_disabled = [false, true, false, true]
	_collision_positions = [Vector2.ZERO]
	_collision_scales = [Vector2.ONE]


func _setup_role3_bullet2() -> void:
	_life_time = 1.1
	stream_visual.self_modulate = Color(1, 1, 1, 1)
	stream_visual.scale = Vector2(0.3, 0.3)
	stream_visual.rotation = 0.0
	var meta := [
		[277, 89, 140.5, 160.5],
		[277, 111, 140.5, 149.5],
		[274, 142, 137.0, 134.0],
		[398, 149, 75.0, 137.5],
		[386, 213, 69.0, 105.5],
		[387, 214, 68.5, 106.0],
		[541, 218, -8.5, 108.0],
		[538, 300, -10.0, 67.0],
		[540, 300, -11.0, 67.0],
		[544, 393, -3.0, 20.5],
		[544, 393, -3.0, 20.5],
		[544, 393, -3.0, 20.5],
		[566, 435, 8.0, -0.5],
		[562, 415, 10.0, 9.5],
		[562, 415, 10.0, 9.5],
		[585, 302, 23.5, 66.0],
		[585, 302, 23.5, 66.0],
		[588, 211, 22.0, 111.5],
		[606, 272, 12.0, 80.0],
		[606, 272, 12.0, 80.0],
		[482, 272, -50.0, 80.0],
		[505, 299, -62.5, 67.5],
		[505, 299, -62.5, 67.5],
		[350, 299, -140.0, 67.5],
		[349, 275, -140.5, 72.5],
		[349, 275, -140.5, 72.5],
		[1, 1, -321.5, -217.5]
	]
	_frame_paths.clear()
	_frame_offsets.clear()
	_frame_times = [0.0, 1.2]
	for i in range(meta.size()):
		_frame_paths.append("res://Art/hero_picture/role_3/role_3_bullet_2_stream/%02d.png" % i)
		_frame_offsets.append(Vector2(float(meta[i][2]), float(meta[i][3])) + Vector2(0, -130))
	var shape := RectangleShape2D.new()
	shape.size = Vector2(53, 102.365)
	collion.shape = shape
	_collision_times = [0.0, 0.1, 0.2, 0.3, 0.4, 0.466667, 0.533333]
	_collision_disabled = [true, false, true, false, true, false, true]
	_collision_positions = [
		Vector2(41.38, -0.665),
		Vector2(31, -4),
		Vector2(16.0987, -12.6263),
		Vector2(-22.26, -21.5),
		Vector2(-56.79, -36.59)
	]
	_collision_scales = [Vector2(1, 0.545), Vector2(1.575, 0.665), Vector2(1.5, 0.855), Vector2(1.495, 1.17)]


func _update_stream_frame() -> void:
	if _frame_paths.is_empty():
		return
	var next_index := _frame_index
	if _name == "Role3Bullet2":
		next_index = clampi(int(floor((_elapsed / 1.2) * 26.0)), 0, _frame_paths.size() - 1)
	else:
		next_index = clampi(int(floor(_elapsed * 24.0)), 0, _frame_paths.size() - 1)
	if next_index == _frame_index:
		return
	_frame_index = next_index
	var cached: Array = _texture_caches.get(_name, [])
	var texture: Texture2D = cached[_frame_index] as Texture2D if _frame_index < cached.size() else null
	var path := _frame_paths[_frame_index]
	if texture == null and ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_LOADED:
		texture = ResourceLoader.load_threaded_get(path) as Texture2D
	if texture == null:
		texture = ResourceLoader.load(path, "Texture2D", ResourceLoader.CACHE_MODE_REUSE) as Texture2D
	stream_visual.texture = texture
	stream_visual.offset = _frame_offsets[_frame_index]


func _update_collision_tracks() -> void:
	for i in range(_collision_times.size()):
		if _elapsed >= float(_collision_times[i]):
			_collision_index = i
	if _collision_index >= 0 and _collision_index < _collision_disabled.size():
		collion.disabled = bool(_collision_disabled[_collision_index])
	for i in range(_collision_positions.size()):
		if _name == "TtzsszBullet" or _elapsed >= [0.0, 0.1, 0.2, 0.3, 0.4][mini(i, 4)]:
			_collision_position_index = i
	if _collision_position_index >= 0 and _collision_position_index < _collision_positions.size():
		collion.position = _collision_positions[_collision_position_index]
	for i in range(_collision_scales.size()):
		if _name == "TtzsszBullet" or _elapsed >= [0.0, 0.2, 0.3, 0.4][mini(i, 3)]:
			_collision_scale_index = i
	if _collision_scale_index >= 0 and _collision_scale_index < _collision_scales.size():
		collion.scale = _collision_scales[_collision_scale_index]


func _exit_tree() -> void:
	if stream_visual != null:
		stream_visual.texture = null
	super._exit_tree()
