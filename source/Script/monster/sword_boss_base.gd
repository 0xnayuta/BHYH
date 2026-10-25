extends BaseMonster
class_name SwordBossBase

const SOURCE_FPS := 24.0
const MAX_SKILL_FRAMES := 36
const ATLAS_DIR := "atlas"
const ATLAS_METADATA := "metadata.tres"
const SWORD_BOSS_PRELOAD_CONFIG := {
	951:
	{
		"root": "res://Art/monster/game_3_monster/sword_boss/zhuxian",
	},
	952:
	{
		"root": "res://Art/monster/game_3_monster/sword_boss/xianxian",
	},
	953:
	{
		"root": "res://Art/monster/game_3_monster/sword_boss/luxian",
	},
	954:
	{
		"root": "res://Art/monster/game_3_monster/sword_boss/juexian",
	},
}

static var _sprite_frames_cache: Dictionary = {}
static var _prewarming_boss_ids: Dictionary = {}
static var _prewarm_generation := 0


static func clear_prewarmed_sword_boss_frames() -> void:
	_prewarm_generation += 1
	_sprite_frames_cache.clear()
	_prewarming_boss_ids.clear()


var sword_name := "诛仙剑"
var sword_root := ""
var sword_drop := "zxjp"
var sword_hp := 2400000
var sword_power_1 := 1200
var sword_power_2 := 1500
var sword_power_3 := 1800
var sword_material_soul := "zxjh"
var _skill_busy := false
var _streamed_skill_effect: StreamedPngEffect
var _death_cleanup_started := false


func _ready() -> void:
	_configure_sword_boss()
	_apply_sword_boss_stats()
	_build_sword_frames()
	_build_sword_animations()
	super._ready()
	skill_1_cd = randi_range(3, 5)
	skill_2_cd = randi_range(5, 7)
	skill_3_cd = randi_range(8, 10)


func _configure_sword_boss() -> void:
	pass


func _apply_sword_boss_stats() -> void:
	is_boss = true
	cannot_attract = true
	set_meta("allow_role_special_control", true)
	my_mr_name = sword_name
	var role_level := 65
	if RoleProp.baseroleprop != null:
		role_level = int(RoleProp.baseroleprop.Level)
	level = max(65, role_level + 3)
	max_hp = sword_hp
	hp = max_hp
	attack_in = 60
	def = 560
	mdef = 560
	crit = 300
	miss = 100
	lucky = 50
	htarget = 500
	toughness = 30
	ar = 400
	sp = 400
	crit_reduce = 15
	speed = 10
	mysee = 1000
	attack_range = 230
	attack_desire = 300
	behit_calmtime = 0.12
	self_rhp = 0
	add_exp = 4500
	fall_coin = 2400
	fall_pro = 0.15
	fall_list = [
		{"name": sword_drop, "value": 1},
	]
	independent_fall_list = []
	fall_stone_pro = 0.0
	fall_stone = []
	obj_attack_dict["hit1"] = {"power": sword_power_1, "hurtBack": [-8, -2], "attackKind": "physics", "HitProtect": 8}
	obj_attack_dict["hit2"] = {"power": sword_power_2, "hurtBack": [-10, -4], "attackKind": "magic", "HitProtect": 8}
	obj_attack_dict["hit3"] = {
		"power": sword_power_3,
		"hurtBack": [-14, -6],
		"attackKind": "magic",
		"HitProtect": 8,
		"addeffect": {"Name": "stun", "AddTime": 1.0, "AttackKind": "magic", "probability": 0.35}
	}


func _build_sword_frames() -> void:
	var cache_key := sword_root + "|body"
	if _sprite_frames_cache.has(cache_key):
		mr_ani.sprite_frames = _sprite_frames_cache[cache_key] as SpriteFrames
		mr_ani.animation = &"idle"
		mr_ani.centered = true
		return
	var frames := SpriteFrames.new()
	if frames.has_animation(&"default"):
		frames.remove_animation(&"default")
	for anim_name in ["idle", "walk", "hurt", "death", "hit1", "hit2", "hit3"]:
		frames.add_animation(StringName(anim_name))
		frames.set_animation_loop(StringName(anim_name), anim_name in ["idle", "walk"])
		frames.set_animation_speed(StringName(anim_name), SOURCE_FPS)
		if anim_name.begins_with("hit"):
			frames.add_frame(StringName(anim_name), null)
			continue
		var frame_entries := _get_atlas_animation_entries(sword_root, anim_name, false)
		for entry in frame_entries:
			var texture := _make_atlas_texture(sword_root, entry)
			if texture != null:
				texture.get_rid()
				frames.add_frame(StringName(anim_name), texture)

	_sprite_frames_cache[cache_key] = frames
	mr_ani.sprite_frames = frames
	mr_ani.animation = &"idle"
	mr_ani.centered = true


static func _get_atlas_metadata(root: String) -> Dictionary:
	return AtlasMetadataStore.data_for(root.path_join(ATLAS_DIR).path_join(ATLAS_METADATA))


static func _get_atlas_animation_entries(root: String, anim_name: String, sample_effect: bool) -> Array:
	var manifest := _get_atlas_metadata(root)
	var animations: Dictionary = manifest.get("animations", {})
	var entries: Array = animations.get(anim_name, [])
	if not sample_effect or entries.size() <= MAX_SKILL_FRAMES:
		return entries.duplicate()
	var sampled: Array = []
	for i in range(MAX_SKILL_FRAMES):
		var index := int(round(float(i) * float(entries.size() - 1) / float(MAX_SKILL_FRAMES - 1)))
		sampled.append(entries[index])
	return sampled


static func _get_atlas_page_path(root: String, entry: Dictionary) -> String:
	var manifest := _get_atlas_metadata(root)
	var pages: Array = manifest.get("pages", [])
	var page_index := int(entry.get("page", -1))
	if page_index < 0 or page_index >= pages.size():
		return ""
	return root.path_join(ATLAS_DIR).path_join(str(pages[page_index]))


static func _get_atlas_region(entry: Dictionary) -> Rect2:
	var values: Array = entry.get("region", [])
	if values.size() != 4:
		return Rect2()
	return Rect2(float(values[0]), float(values[1]), float(values[2]), float(values[3]))


static func _make_atlas_texture(root: String, entry: Dictionary) -> AtlasTexture:
	var page_path := _get_atlas_page_path(root, entry)
	var region := _get_atlas_region(entry)
	if page_path == "" or region.size.x <= 0.0 or region.size.y <= 0.0:
		return null
	var page_texture := ResourceLoader.load(page_path, "Texture2D", ResourceLoader.CACHE_MODE_REUSE) as Texture2D
	if page_texture == null:
		return null
	var texture := AtlasTexture.new()
	texture.atlas = page_texture
	texture.region = region
	texture.filter_clip = true
	return texture


static func prewarm_sword_boss_frames_async(boss_ids: Array = [951, 952, 953, 954]) -> void:
	var generation := _prewarm_generation
	var tree := Engine.get_main_loop() as SceneTree
	var built_this_frame := 0
	var per_frame := 6 if OS.has_feature("mobile") else 14
	for boss_id_value in boss_ids:
		var boss_id := int(boss_id_value)
		if not SWORD_BOSS_PRELOAD_CONFIG.has(boss_id):
			continue
		if _prewarming_boss_ids.has(boss_id):
			continue
		var config: Dictionary = SWORD_BOSS_PRELOAD_CONFIG[boss_id]
		var root := str(config.get("root", ""))
		var cache_key := root + "|body"
		if _sprite_frames_cache.has(cache_key):
			continue
		_prewarming_boss_ids[boss_id] = true
		var frames := SpriteFrames.new()
		if frames.has_animation(&"default"):
			frames.remove_animation(&"default")
		for anim_name in ["idle", "walk", "hurt", "death", "hit1", "hit2", "hit3"]:
			frames.add_animation(StringName(anim_name))
			frames.set_animation_loop(StringName(anim_name), anim_name in ["idle", "walk"])
			frames.set_animation_speed(StringName(anim_name), SOURCE_FPS)
			if str(anim_name).begins_with("hit"):
				frames.add_frame(StringName(anim_name), null)
				continue
			for entry in _get_atlas_animation_entries(root, anim_name, false):
				var texture := _make_atlas_texture(root, entry)
				if texture != null:
					texture.get_rid()
					frames.add_frame(StringName(anim_name), texture)
				built_this_frame += 1
				if tree != null and built_this_frame >= per_frame:
					built_this_frame = 0
					await tree.process_frame
					if generation != _prewarm_generation:
						_prewarming_boss_ids.erase(boss_id)
						return
		if generation != _prewarm_generation:
			_prewarming_boss_ids.erase(boss_id)
			return
		_sprite_frames_cache[cache_key] = frames
		_prewarming_boss_ids.erase(boss_id)


func _build_sword_animations() -> void:
	if mr_player.has_animation_library(&""):
		mr_player.remove_animation_library(&"")
	var library := AnimationLibrary.new()
	library.add_animation(&"wait", _make_action(&"idle", true))
	library.add_animation(&"walk", _make_action(&"walk", true))
	library.add_animation(&"hurt", _make_action(&"hurt", false))

	var death_animation := _make_action(&"death", false)
	library.add_animation(&"death", death_animation)

	var hit1_animation := _make_action(&"hit1", false)
	_add_hitbox_window(hit1_animation, 0.18, 0.58)
	library.add_animation(&"hit1", hit1_animation)

	var hit2_animation := _make_action(&"hit2", false)
	_add_hitbox_window(hit2_animation, 0.16, 0.72)
	library.add_animation(&"hit2", hit2_animation)

	var hit3_animation := _make_action(&"hit3", false)
	_add_hitbox_window(hit3_animation, 0.2, 0.92)
	library.add_animation(&"hit3", hit3_animation)

	mr_player.add_animation_library(&"", library)


func _make_action(sprite_anim: StringName, looped: bool) -> Animation:
	var animation := Animation.new()
	animation.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
	var animation_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(animation_track, NodePath("MonsterDir/mr_ani:animation"))
	animation.value_track_set_update_mode(animation_track, Animation.UPDATE_DISCRETE)
	animation.track_insert_key(animation_track, 0.0, sprite_anim)

	var frame_count := _get_sword_action_frame_count(sprite_anim)
	var frame_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(frame_track, NodePath("MonsterDir/mr_ani:frame"))
	animation.value_track_set_update_mode(frame_track, Animation.UPDATE_DISCRETE)
	if String(sprite_anim).begins_with("hit"):
		var method_track := animation.add_track(Animation.TYPE_METHOD)
		animation.track_set_path(method_track, NodePath("."))
		animation.track_insert_key(
			method_track, 0.0, {"method": &"_start_streamed_sword_skill", "args": [String(sprite_anim)]}
		)
		animation.track_insert_key(
			method_track,
			maxf(float(frame_count) / SOURCE_FPS - 0.001, 0.0),
			{"method": &"_stop_streamed_sword_skill", "args": []}
		)
	else:
		for frame_index in range(frame_count):
			animation.track_insert_key(frame_track, float(frame_index) / SOURCE_FPS, frame_index)
	animation.length = maxf(float(frame_count) / SOURCE_FPS, 0.08)
	return animation


func _get_sword_action_frame_count(sprite_anim: StringName) -> int:
	if String(sprite_anim).begins_with("hit"):
		var sequence := _sword_skill_sequence(String(sprite_anim))
		return maxi(1, sequence.count())
	if mr_ani.sprite_frames != null and mr_ani.sprite_frames.has_animation(sprite_anim):
		return maxi(1, mr_ani.sprite_frames.get_frame_count(sprite_anim))
	return 1


func _sword_skill_sequence(anim_name: String) -> FrameSequence:
	return FrameSequenceStore.get_sequence(
		"sword/%s/%s" % [sword_root.get_file(), anim_name], SOURCE_FPS, false, false, 2
	)


func _start_streamed_sword_skill(anim_name: String) -> void:
	_stop_streamed_sword_skill()
	var sequence := _sword_skill_sequence(anim_name)
	if sequence.count() == 0:
		return
	_streamed_skill_effect = StreamedPngEffect.new()
	_streamed_skill_effect.sequence = sequence
	_streamed_skill_effect.z_index = mr_ani.z_index + 1
	_streamed_skill_effect.position = mr_ani.position
	_streamed_skill_effect.finished.connect(_on_streamed_sword_skill_finished)
	monster_dir.add_child(_streamed_skill_effect)
	mr_ani.visible = false


func _stop_streamed_sword_skill() -> void:
	if _streamed_skill_effect != null and is_instance_valid(_streamed_skill_effect):
		_streamed_skill_effect.clear_texture()
		_streamed_skill_effect.queue_free()
	_streamed_skill_effect = null
	if mr_ani != null and is_instance_valid(mr_ani):
		mr_ani.visible = true


func _on_streamed_sword_skill_finished() -> void:
	_streamed_skill_effect = null
	if mr_ani != null and is_instance_valid(mr_ani):
		mr_ani.visible = true


func _add_hitbox_window(animation: Animation, start_time: float, end_time: float) -> void:
	var hitbox_track := animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(hitbox_track, NodePath("BaseDamageBox/HitBox/HitBox:disabled"))
	animation.value_track_set_update_mode(hitbox_track, Animation.UPDATE_DISCRETE)
	animation.track_insert_key(hitbox_track, 0.0, true)
	animation.track_insert_key(hitbox_track, minf(start_time, animation.length - 0.001), false)
	animation.track_insert_key(hitbox_track, minf(end_time, animation.length - 0.001), true)


func _add_death_method(animation: Animation) -> void:
	var method_track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(method_track, NodePath("."))
	animation.track_insert_key(
		method_track, maxf(animation.length - 0.001, 0.0), {"method": &"settle_death_drops_and_free", "args": []}
	)


func ai_think() -> void:
	if abs(RoleProp.get_nearest_monster_target_position(global_position).x - position.x) < mysee:
		has_target = true
	if is_limit_buff() or cannotchangestatewhenattorbeatt() or _skill_busy:
		return
	if not has_target:
		normal_state()
		return
	var distance := absf(RoleProp.get_nearest_monster_target_position(global_position).x - position.x)
	if distance > attack_range:
		have_target()
		return
	stop_move()
	if skill_3_cd <= 0:
		_use_sword_skill(&"hit3", 9, "hit3")
	elif skill_2_cd <= 0:
		_use_sword_skill(&"hit2", 6, "hit2")
	elif skill_1_cd <= 0 or count % 50 == 0:
		_use_sword_skill(&"hit1", 4, "hit1")


func state_death() -> void:
	if is_death:
		return
	is_death = true

	set_meta("counts_as_alive_for_stage_clear", true)
	velocity = Vector2.ZERO
	is_attacking = false
	is_using_skills = false
	_skill_busy = false
	if hit_box != null and is_instance_valid(hit_box):
		hit_box.set_deferred("disabled", true)
	if hurt_box != null and is_instance_valid(hurt_box):
		hurt_box.set_deferred("disabled", true)
	_stop_streamed_sword_skill()
	set_exp()
	set_gxp()
	settle_death_drops()
	mr_player.play(&"death")
	if not _death_cleanup_started:
		_death_cleanup_started = true
		call_deferred("_finish_sword_death")


func _finish_sword_death() -> void:
	var death_frames := 1
	if is_instance_valid(mr_ani) and mr_ani.sprite_frames != null and mr_ani.sprite_frames.has_animation(&"death"):
		death_frames = maxi(1, mr_ani.sprite_frames.get_frame_count(&"death"))
	await get_tree().create_timer(float(death_frames) / SOURCE_FPS + 0.08, false).timeout
	if is_instance_valid(self) and not is_queued_for_deletion():
		set_meta("counts_as_alive_for_stage_clear", false)
		settle_death_drops_and_free()


func _use_sword_skill(animation_name: StringName, cooldown: int, hit_key: String) -> void:
	_skill_busy = true
	to_hero()
	hit_name = hit_key
	velocity.x = 0
	is_attacking = true
	match hit_key:
		"hit1":
			skill_1_cd = cooldown
		"hit2":
			skill_2_cd = cooldown
		"hit3":
			skill_3_cd = cooldown
	mr_player.play(animation_name)
	await mr_player.animation_finished
	_stop_streamed_sword_skill()
	if death():
		return
	hit_box.disabled = true
	is_attacking = false
	_skill_busy = false
	stop_move()


func fall_items() -> void:
	if _is_tower_drop_context():
		return
	randomize()
	var level_node := get_level_node()
	if level_node == null:
		return
	if not is_fall and randf() <= _scaled_sword_drop_chance(0.15):
		Global.fall_item(level_node.fall_it, Vector2(position.x, position.y - 30), sword_drop, 1)
		is_fall = true
	if not bool(get_meta("sword_soul_fall_settled", false)) and randf() <= _scaled_sword_drop_chance(0.2):
		set_meta("sword_soul_fall_settled", true)
		Global.fall_item(level_node.fall_it, Vector2(position.x + 28, position.y - 30), sword_material_soul, 1)

	if int(MainSet.set_data.get("Difficult", 0)) == 2:
		var hell_box_fall_pro := 0.2
		if RoleProp.source_player != null and RoleProp.source_player.is_double_fall_pro:
			hell_box_fall_pro *= 2.0
		hell_box_fall_pro = clampf(hell_box_fall_pro, 0.0, 1.0)
		if randf_range(0, 1) <= hell_box_fall_pro:
			Global.fall_item(level_node.fall_it, Vector2(position.x, position.y - 30), "qhsbx", 1)


func _scaled_sword_drop_chance(base_chance: float) -> float:
	var difficult := clampi(int(MainSet.set_data.get("Difficult", 0)), 0, 2)
	var multipliers := [1.0, 2.0, 3.0]
	var chance := base_chance * float(multipliers[difficult])
	if RoleProp.source_player != null and RoleProp.source_player.is_double_fall_pro:
		chance *= 2.0
	return clampf(chance, 0.0, 1.0)
