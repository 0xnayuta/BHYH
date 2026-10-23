extends BaseMagicWeapon
class_name QlSword

const PLATFORM := preload("res://Scene/magic_weapon/qinglong_sword_platform.tscn")
const BODY_TEXTURE := "res://Art/magic_weapon/magic_weapon_qlsword/official/magic_big_sword_bmd.png"
const FLOOR_DURATION := 30.0
const COOLDOWN := 30.0

var floor_instance: QinglongSwordPlatform
var _follow_elapsed := 0.0
var _follow_tween: Tween


func _ready() -> void:
	need_mp = 30
	hitbox.disabled = true
	hit_box.monitoring = false
	hit_box.monitorable = false
	var sheet := Global.get_cached_texture(BODY_TEXTURE)
	var frames := SpriteFrames.new()
	for index in range(2):
		var action: StringName = &"wait" if index == 0 else &"hit"
		var texture := AtlasTexture.new()
		texture.atlas = sheet
		texture.region = Rect2(0, index * 150, 100, 150)
		frames.add_animation(action)
		frames.add_frame(action, texture)
	mg_action.sprite_frames = frames
	mg_action.animation = &"wait"
	mg_action.scale = Vector2.ONE
	mg_action.offset = Vector2.ZERO
	mg_action.position = Vector2(0, 120)


func set_magic_weapon_player(hero) -> void:
	super.set_magic_weapon_player(hero)
	if is_instance_valid(player):
		global_position = player.global_position + Vector2(-100 if player.player_dir else 100, -180)
		fix_hero()


func enough_mp() -> bool:
	return is_instance_valid(player) and int(RoleProp.roleprop.get("Mp", 0)) >= need_mp


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player) or player.is_queued_for_deletion() or player.death():
		_remove_floor()
		visible = false
		is_use = false
		return
	if not skill_cd.is_stopped() and is_instance_valid(mg_cd_pic):
		mg_cd_pic.max_time = usecd
	visible = skill_cd.is_stopped()
	if is_use and is_canuse:
		use_skill()
	_follow_elapsed += delta
	if _follow_elapsed >= 0.5:
		_follow_elapsed = fmod(_follow_elapsed, 0.5)
		fix_hero()


func fix_hero() -> void:
	if not is_instance_valid(player):
		return
	self_dir = player.player_dir
	scale.x = -1.0 if self_dir else 1.0
	var offset := Vector2(-100.0 if self_dir else 100.0, -180.0)
	if _follow_tween != null and _follow_tween.is_valid():
		_follow_tween.kill()
	_follow_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_follow_tween.tween_property(self, "global_position", player.global_position + offset, 0.5)


func show_skill() -> void:
	if not is_instance_valid(player):
		is_use = false
		return
	_remove_floor()
	floor_instance = PLATFORM.instantiate() as QinglongSwordPlatform
	floor_instance.player = player
	floor_instance.duration = FLOOR_DURATION
	floor_instance.position = get_parent().to_local(QinglongSwordPlatform.get_source_origin(player) + Vector2(0, 70))
	get_parent().add_child(floor_instance)
	mg_action.animation = &"hit"
	use_over()


func use_over() -> void:
	usecd = COOLDOWN
	is_use = false
	is_canuse = false
	fb_cd = 1
	visible = false
	skill_cd.start(usecd)


func _on_skill_cd_timeout() -> void:
	super._on_skill_cd_timeout()
	mg_action.animation = &"wait"
	visible = is_instance_valid(player)


func _remove_floor() -> void:
	if is_instance_valid(floor_instance) and not floor_instance.is_queued_for_deletion():
		floor_instance.queue_free()
	floor_instance = null


func is_floor_active() -> bool:
	return is_instance_valid(floor_instance) and not floor_instance.is_queued_for_deletion()


func get_floor_remaining_time() -> float:
	return floor_instance.remaining_time if is_floor_active() else 0.0


func _exit_tree() -> void:
	_remove_floor()
	if _follow_tween != null and _follow_tween.is_valid():
		_follow_tween.kill()
