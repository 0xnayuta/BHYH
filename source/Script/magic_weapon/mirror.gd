extends BaseMagicWeapon
class_name Mirror
var fix_target: BaseMonster
var follow_target: BaseObject
var blood_effect
var init_speed: int = 5
var speed: int = 5
var is_begin: bool
var fix_time: int = 960
var monster_list: Array = []
var total_hp: int = 0
var is_show_skill: bool
var velocity
var is_follow: bool
var _stream_sprite: Sprite2D
var _stream_time := 0.0
var _stream_frame := -1

const STREAM_FRAME_DIR := "res://Art/magic_weapon/bsyj_wait_smooth"
const STREAM_FRAME_OFFSETS := [
	Vector2(0.0, 1.0),
	Vector2(0.5, 1.0),
	Vector2(0.5, 1.0),
	Vector2(0.0, 1.5),
	Vector2(0.0, 1.0),
	Vector2(0.0, 1.0),
	Vector2(0.0, 1.5),
	Vector2(-0.5, 1.0),
	Vector2(-0.5, 1.5),
	Vector2(-0.5, 1.5),
	Vector2(0.0, 1.5),
	Vector2(0.0, 1.5),
	Vector2(0.0, 1.5),
	Vector2(0.0, 1.5),
	Vector2(-0.5, 2.0),
	Vector2(-1.0, 2.0),
	Vector2(-1.0, 2.0),
	Vector2(-1.5, 2.0),
	Vector2(-2.0, 2.5),
	Vector2(-2.0, 3.0),
	Vector2(-1.0, 3.0),
	Vector2(-1.0, 2.5),
	Vector2(-1.0, 2.5),
	Vector2(-1.0, 2.5),
	Vector2(-1.0, 2.5),
	Vector2(-1.5, 2.0),
	Vector2(-1.5, 2.0),
	Vector2(-1.5, 1.5),
	Vector2(-1.5, 1.5),
	Vector2(-2.0, -0.5),
	Vector2(-1.5, -1.5),
	Vector2(-1.5, -1.5),
	Vector2(-1.0, -2.5),
	Vector2(-1.5, -2.5),
	Vector2(-1.0, -3.5),
	Vector2(-1.5, -3.5),
	Vector2(-1.5, -5.0),
	Vector2(-1.0, -5.0),
	Vector2(-1.5, -6.0),
	Vector2(-1.5, -6.0),
	Vector2(0.0, -6.0),
	Vector2(-0.5, -6.0),
	Vector2(0.0, -5.5),
	Vector2(-0.5, -5.5),
	Vector2(0.5, -4.5),
	Vector2(0.0, -3.5),
	Vector2(0.0, -3.5),
	Vector2(0.5, -2.5),
	Vector2(0.5, -2.5),
	Vector2(0.5, -0.5),
	Vector2(1.5, -1.5),
	Vector2(1.5, -1.0),
	Vector2(1.5, -1.0),
	Vector2(1.5, 0.5),
	Vector2(1.5, 0.5),
	Vector2(1.5, 0.5),
	Vector2(1.5, 0.5),
	Vector2(2.0, 0.5),
	Vector2(1.0, 0.5),
	Vector2(1.5, -1.0),
	Vector2(2.5, -1.5),
	Vector2(2.0, -1.5),
	Vector2(2.5, -3.5),
	Vector2(2.5, -3.5),
	Vector2(2.0, -5.0),
	Vector2(2.0, -5.0),
	Vector2(2.5, -8.0),
	Vector2(2.0, -8.0),
	Vector2(2.0, -8.5),
	Vector2(1.5, -8.0),
	Vector2(2.5, -9.0),
	Vector2(2.5, -9.0),
	Vector2(2.0, -9.0),
	Vector2(2.0, -9.0),
	Vector2(1.5, -8.5),
	Vector2(1.0, -8.5),
	Vector2(1.0, -8.5),
	Vector2(1.0, -7.0),
	Vector2(0.5, -7.0),
	Vector2(0.5, -5.0),
	Vector2(1.5, -5.5),
	Vector2(1.0, -4.0),
	Vector2(0.5, -4.0),
	Vector2(0.0, -1.5),
	Vector2(0.0, -1.5),
	Vector2(0.0, -0.5),
	Vector2(-0.5, -0.5),
	Vector2(-1.0, 1.0),
	Vector2(-0.5, 1.0),
	Vector2(-0.5, 1.0),
	Vector2(-1.0, 2.0),
	Vector2(-0.5, 2.0),
	Vector2(-0.5, 1.5),
	Vector2(-0.5, 1.5),
	Vector2(-1.0, 1.0),
	Vector2(-1.0, 1.0),
	Vector2(-1.5, -1.0),
	Vector2(-1.5, -1.0),
	Vector2(-2.0, -3.0),
	Vector2(-2.0, -3.0),
	Vector2(-1.0, -4.5),
	Vector2(-1.0, -4.5),
	Vector2(-1.0, -6.5),
	Vector2(-1.5, -6.5),
	Vector2(-1.5, -7.0),
	Vector2(-1.5, -8.0),
	Vector2(-1.5, -8.0),
	Vector2(-1.0, -7.5),
	Vector2(-2.0, -7.5),
	Vector2(-1.5, -7.0),
	Vector2(-0.5, -7.0),
	Vector2(-1.0, -6.5),
	Vector2(-0.5, -6.5),
	Vector2(-0.5, -5.5),
	Vector2(-1.0, -5.5),
	Vector2(-0.5, -3.5),
	Vector2(-0.5, -3.5),
	Vector2(0.0, -1.0),
	Vector2(-0.5, -1.0),
	Vector2(0.0, -1.0)
]
static var _stream_frame_cache: Array[Texture2D] = []
static var _stream_warming := false
static var _stream_cache_generation := 0
var _monster_snapshot_version := -2
var _attack_signature := ""
const STREAM_FRAME_COUNT := 120
const STREAM_FPS := 24.0


func _ready() -> void:
	mg_action.visible = false
	_stream_sprite = Sprite2D.new()
	_stream_sprite.name = "MirrorStreamSprite"
	add_child(_stream_sprite)
	_stream_sprite.scale = mg_action.scale
	_prewarm_stream_frames()
	_show_stream_frame(0)


func _exit_tree() -> void:
	if _stream_sprite != null:
		_stream_sprite.texture = null


func _get_active_monster_snapshot() -> Array:
	var level: Node = player.get_parent().get_parent() if player != null and player.get_parent() != null else null
	if level != null and level.has_method("has_active_monster_index") and level.has_active_monster_index():
		return level.get_active_monsters()
	if level != null and "monster" in level and level.monster != null:
		return level.monster.get_children()
	return []


func _physics_process(delta: float) -> void:
	var level: Node = player.get_parent().get_parent() if player != null and player.get_parent() != null else null
	var monster_version := (
		int(level.get_active_monster_version())
		if level != null and level.has_method("get_active_monster_version")
		else -1
	)
	if monster_version != _monster_snapshot_version:
		_monster_snapshot_version = monster_version
		monster_list = _get_active_monster_snapshot()
	self.fb_level = PlayerData.get_most_level("bsyj") + 1
	var has_wood: bool = bool(PlayerData.check_have_wx("bsyj", "木"))
	var attack_signature := "%d:%s:%d" % [self.fb_level, str(has_wood), int(RoleProp.roleprop.SHp)]
	if attack_signature != _attack_signature:
		_attack_signature = attack_signature
		obj_attack_dict["hit1"] = {
			"power":
			int(
				RoleProp.roleprop.SHp * ((0.16 + self.fb_level * 0.01) if has_wood else (0.08 + self.fb_level * 0.005))
			),
			"hurtBack": [0, 0],
			"attackKind": "real",
			"addeffect":
			{
				"Name": "speed_down",
				"AddTime": 1.0 if has_wood else 0.5,
				"reduce_interval": 0,
				"value": 0.3 if has_wood else 0.15,
				"AttackKind": "",
				"DeBuff": true
			}
		}
	need_mp = 25
	var a_2
	super._physics_process(delta)
	if follow_target != null:
		var target: Vector2
		if follow_target is BaseMonster:
			target = follow_target.position - Vector2(0, 140)
		elif follow_target is BaseHero:
			target = follow_target.position - Vector2(0, 70)
		velocity = position.direction_to(target) * speed
		self.position.x = self.position.x + velocity.x
		self.position.y = self.position.y + velocity.y
		if speed < 15:
			speed += 1
		a_2 = position.distance_to(target)
		if a_2 < 10:
			if follow_target == fix_target:
				is_begin = true
				follow_target = null
				speed = init_speed
			elif follow_target == player:
				use_over()
				player.f_bcure_hp(total_hp)
				total_hp = 0
			else:
				use_over()
				fix_time = 0

	if is_begin:
		if fix_target != null:
			self.position = fix_target.position - Vector2(0, 140)
			if fix_time % 60 == 0:
				add_special_effect()
				if fix_target == null or not fix_target is BaseMonster:
					fix_time = 0
				else:
					if fix_target != null and fix_target is BaseMonster:
						Global.add_buff(fix_target.buff, obj_attack_dict["hit1"]["addeffect"])
						total_hp += reduce_hp()
					else:
						fix_time = 0
		else:
			fix_time = 0

		if fix_time == 0:
			follow_target = player
			fix_target = null
			is_begin = false
		if fix_time > 0:
			fix_time -= 1
	_update_stream_sprite(delta)


func show_skill():
	if _monster_snapshot_version < 0:
		monster_list = _get_active_monster_snapshot()
	is_follow = true
	is_show_skill = true
	fb_cd = 5
	var monster: BaseMonster = null
	var a_2 = 0
	var monster_2: BaseMonster = null
	var a_3
	var closest_dist = 5000
	while a_2 < monster_list.size():
		if monster_list[a_2] == null:
			use_over()
			return
		monster_2 = monster_list[a_2] as BaseMonster
		if monster_2 == null:
			a_2 += 1
			continue
		a_3 = Global.get_dis_betweem(player, monster_2)
		if a_3 <= closest_dist:
			closest_dist = a_3
		if monster_2 is Monster49 or monster_2 is Monster50:
			if not monster_2.is_stop:
				monster = monster_2
		else:
			monster = monster_2
		a_2 += 1
	if monster != null:
		mg_player.play("hit")
		fix_target = monster
		follow_target = fix_target
	if follow_target == null or fix_target == null:
		RoleProp.roleprop.Mp += need_mp
		use_over()
	is_show_skill = false


func use_over():
	is_follow = false
	is_show_skill = false
	is_begin = false
	fix_time = 60 * 16
	is_use = false
	fb_cd = 0
	self.usecd = 0
	skill_cd.start(1)
	follow_target = null
	is_begin = false
	speed = init_speed


func _on_check_monster_body_entered(body: Node2D) -> void:
	if body is BaseMonster:
		monster_list.push_back(body)


func reduce_hp():
	var hurt = int(obj_attack_dict["hit1"]["power"] / 15)
	fix_target.reduce_hp(hurt)
	return hurt


func check_monster_death():
	for i in monster_list:
		if i != null:
			if i is BaseMonster:
				if i.is_death:
					monster_list.erase(i)
			else:
				monster_list.erase(i)
		else:
			monster_list.erase(i)


func free() -> void:
	follow_target = null
	fix_target = null


func add_special_effect():
	Global.add_special_effect(self, Vector2(0, 45), "mirror_hp_steal", Vector2(1, 1), false, 1.0)


func _on_timer_timeout() -> void:
	if not is_begin:
		if follow_target == null and fix_target == null:
			use_over()


func _update_stream_sprite(delta: float) -> void:
	if _stream_sprite == null:
		return
	_stream_time = fmod(_stream_time + delta, float(STREAM_FRAME_COUNT) / STREAM_FPS)
	var frame_index := int(floor(_stream_time * STREAM_FPS)) % STREAM_FRAME_COUNT
	_stream_sprite.position = mg_action.position
	_stream_sprite.scale = mg_action.scale
	_stream_sprite.visible = visible
	_show_stream_frame(frame_index)


static func _prewarm_stream_frames() -> void:
	if _stream_warming or _has_all_stream_frames():
		return
	_stream_warming = true
	var generation := _stream_cache_generation
	var tree := Engine.get_main_loop() as SceneTree
	_stream_frame_cache.resize(STREAM_FRAME_COUNT)
	var batch_size := 2 if OS.has_feature("mobile") else 4
	for batch_start in range(0, STREAM_FRAME_COUNT, batch_size):
		var batch_end := mini(batch_start + batch_size, STREAM_FRAME_COUNT)
		for index in range(batch_start, batch_end):
			ResourceLoader.load_threaded_request(
				"%s/frame_%03d.png" % [STREAM_FRAME_DIR, index], "Texture2D", false, ResourceLoader.CACHE_MODE_REUSE
			)
		for index in range(batch_start, batch_end):
			var path := "%s/frame_%03d.png" % [STREAM_FRAME_DIR, index]
			while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				if tree == null:
					break
				await tree.process_frame
				if generation != _stream_cache_generation:
					_stream_warming = false
					return
			if ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_LOADED:
				_stream_frame_cache[index] = ResourceLoader.load_threaded_get(path) as Texture2D
	_stream_warming = false


static func prewarm_stream_frames() -> void:
	await _prewarm_stream_frames()


static func _has_all_stream_frames() -> bool:
	if _stream_frame_cache.size() != STREAM_FRAME_COUNT:
		return false
	for texture in _stream_frame_cache:
		if texture == null:
			return false
	return true


static func clear_cached_frames() -> void:
	_stream_cache_generation += 1
	_stream_warming = false
	_stream_frame_cache.clear()


func _show_stream_frame(frame_index: int) -> void:
	if frame_index == _stream_frame or _stream_sprite == null:
		return
	_stream_frame = frame_index
	var path := "%s/frame_%03d.png" % [STREAM_FRAME_DIR, frame_index]
	var texture: Texture2D = _stream_frame_cache[frame_index] if frame_index < _stream_frame_cache.size() else null
	if texture == null and ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_LOADED:
		texture = ResourceLoader.load_threaded_get(path) as Texture2D
	if texture == null:
		texture = ResourceLoader.load(path, "Texture2D", ResourceLoader.CACHE_MODE_REUSE) as Texture2D
	_stream_sprite.texture = texture
	var frame_offset: Vector2 = STREAM_FRAME_OFFSETS[frame_index]
	_stream_sprite.position = mg_action.position + frame_offset * mg_action.scale

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
