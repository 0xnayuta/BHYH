extends BaseMagicWeapon
class_name TaijiBagua

const MODEL_FRAMES_RES := "res://Art/magic_weapon/taiji_bagua/magic_bagua_frames.tres"
const EFFECT_FRAMES_RES := "res://Art/magic_weapon/taiji_bagua/effect/taiji_bagua_effect_frames.tres"
const SKILL_LEVEL := 6
const COOLDOWN := 20.0
const MONSTER_52_SCRIPT := preload("res://Script/monster/monster_52.gd")

var _effect: AnimatedSprite2D
var _effect_frames: SpriteFrames


func _ready() -> void:
	need_mp = 10
	hitbox.disabled = true
	hit_box.monitoring = false
	hit_box.monitorable = false
	var model_frames := load(MODEL_FRAMES_RES) as SpriteFrames
	var effect_frames := load(EFFECT_FRAMES_RES) as SpriteFrames
	if model_frames == null or effect_frames == null:
		push_error("太极八卦构建期帧资源缺失")
		return
	mg_action.sprite_frames = model_frames
	mg_action.animation = &"wait"
	mg_action.position = Vector2.ZERO
	_effect_frames = effect_frames


func get_skill_level() -> int:
	return PlayerData.get_most_level("tjbg") + 1


func enough_mp() -> bool:
	return (
		is_instance_valid(player)
		and get_skill_level() >= SKILL_LEVEL
		and int(RoleProp.roleprop.get("Mp", 0)) >= need_mp
	)


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player) or player.is_queued_for_deletion():
		is_use = false
		visible = false
		return
	fb_level = get_skill_level()
	super._physics_process(delta)


func show_skill() -> void:
	if not is_instance_valid(player) or get_skill_level() < SKILL_LEVEL:
		is_use = false
		return
	var duration := float(get_skill_level()) / 2.0
	if PlayerData.check_have_wx("tjbg", "木"):
		duration *= 2.0
	for monster in _active_monsters():
		if (
			not monster is BaseMonster
			or not is_instance_valid(monster)
			or monster.is_queued_for_deletion()
			or monster.death()
		):
			continue
		if (
			monster is SummonBaseMonster
			or monster is Monster48
			or monster is Monster50
			or monster is Monster51
			or monster.get_script() == MONSTER_52_SCRIPT
			or monster.no_target
			or monster.is_control_immune()
		):
			continue
		(
			Global
			. add_buff(
				monster.get_node_or_null("Buff"),
				{
					"Name": "stun",
					"AddTime": duration,
					"ReduceInterval": 0.0,
					"value": 0.0,
					"AttackKind": "",
					"DeBuff": true,
					"CanRemove": false,
				}
			)
		)
	_show_effect()
	mg_action.animation = &"hit"
	use_over()


func _active_monsters() -> Array:
	var level := get_parent()
	if level.has_method("get_active_monsters"):
		return level.get_active_monsters()
	var monsters = level.get("monster")
	if monsters != null and is_instance_valid(monsters):
		return monsters.get_children()
	return []


func _show_effect() -> void:
	if is_instance_valid(_effect):
		_effect.queue_free()
	_effect = AnimatedSprite2D.new()
	_effect.sprite_frames = _effect_frames
	_effect.centered = false
	_effect.position = get_parent().to_local(
		QinglongSwordPlatform.get_source_origin(player) + Vector2(-247.95, 40.0 - 135.6)
	)
	_effect.z_index = player.z_index - 1
	get_parent().add_child(_effect)
	_effect.animation_finished.connect(_effect.queue_free, CONNECT_ONE_SHOT)
	_effect.play()


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


func _exit_tree() -> void:
	if is_instance_valid(_effect):
		_effect.queue_free()
