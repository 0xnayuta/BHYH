extends BaseMagicWeapon
class_name ZhenLeiTianChui

const WEAPON_ID := "469000004"
const IDLE_FRAME_COUNT := 24
const EFFECT_FRAME_COUNT := 28
const FLASH_FRAME_COUNT := 14
const ANIMATION_SPEED := 30.0
const HIT_FRAMES: Array[int] = [9, 17, 25]
const HIT_RADIUS := 300.0
const EFFECT_FORWARD_OFFSET := 100.0
const EFFECT_VERTICAL_OFFSET := -43.0
const COOLDOWN_DURATION := 30.0
const BASE_POWER_RATE := 3.0
const LEVEL_POWER_RATE := 0.2
const BASE_STUN_DURATION := 2.0
const LEVEL_STUN_DURATION := 0.2

@onready var effect_anchor: Node2D = $EffectAnchor
@onready var thunder_effect: AnimatedSprite2D = $EffectAnchor/ThunderEffect
@onready var cast_flash: AnimatedSprite2D = $EffectAnchor/CastFlash

var _cast_token: int = 0


func _ready() -> void:
	fb_level = _get_weapon_level()
	need_mp = 50
	mg_action.sprite_frames = _build_frames(
		"wait", "res://Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/idle_frames/%d.png", IDLE_FRAME_COUNT, true
	)
	thunder_effect.sprite_frames = _build_frames(
		"effect",
		"res://Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/effect_frames/%d.png",
		EFFECT_FRAME_COUNT,
		false
	)
	cast_flash.sprite_frames = _build_frames(
		"flash", "res://Art/magic_weapon/magic_weapon_zhen_lei_tian_chui/flash_frames/%d.png", FLASH_FRAME_COUNT, false
	)
	effect_anchor.top_level = true
	thunder_effect.visible = false
	cast_flash.visible = false
	mg_action.play("wait")


func _physics_process(delta: float) -> void:
	fb_level = _get_weapon_level()
	need_mp = 50
	super._physics_process(delta)
	if not is_use:
		mg_action.visible = skill_cd.is_stopped()
		if mg_action.visible and not mg_action.is_playing():
			mg_action.play("wait")


func _build_frames(animation_name: String, path_pattern: String, frame_count: int, looped: bool) -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.add_animation(animation_name)
	frames.set_animation_loop(animation_name, looped)
	frames.set_animation_speed(animation_name, ANIMATION_SPEED)
	for frame_index in range(1, frame_count + 1):
		var texture := load(path_pattern % frame_index) as Texture2D
		if texture != null:
			frames.add_frame(animation_name, texture)
	return frames


func _get_weapon_level() -> int:
	return clampi(PlayerData.get_most_level(WEAPON_ID), 1, 10)


func show_skill() -> void:
	var casting_hero := _get_casting_hero()
	if casting_hero == null:
		use_over()
		return

	_cast_token += 1
	var current_token := _cast_token
	mg_action.stop()
	mg_action.visible = false
	_place_effect(casting_hero)
	_play_effects()

	var previous_frame := 1
	for hit_frame in HIT_FRAMES:
		await get_tree().create_timer(float(hit_frame - previous_frame) / ANIMATION_SPEED, false).timeout
		if not is_inside_tree() or current_token != _cast_token:
			return
		_apply_thunder_hit(casting_hero)
		previous_frame = hit_frame

	var remaining_duration := float(EFFECT_FRAME_COUNT - HIT_FRAMES[-1] + 1) / ANIMATION_SPEED
	await get_tree().create_timer(remaining_duration, false).timeout
	if is_inside_tree() and current_token == _cast_token:
		use_over()


func _get_casting_hero() -> BaseHero:
	var source_player: Variant = RoleProp.source_player
	if source_player is BaseHero and is_instance_valid(source_player):
		return source_player as BaseHero
	if player != null and is_instance_valid(player):
		return player
	return null


func _place_effect(casting_hero: BaseHero) -> void:
	var direction_sign := 1.0 if bool(RoleProp.directon) else -1.0
	effect_anchor.global_position = (
		casting_hero.global_position + Vector2(direction_sign * EFFECT_FORWARD_OFFSET, EFFECT_VERTICAL_OFFSET)
	)
	effect_anchor.scale = Vector2(direction_sign, 1.0)


func _play_effects() -> void:
	thunder_effect.visible = true
	thunder_effect.frame = 0
	thunder_effect.frame_progress = 0.0
	thunder_effect.play("effect")
	cast_flash.visible = true
	cast_flash.frame = 0
	cast_flash.frame_progress = 0.0
	cast_flash.play("flash")


func _apply_thunder_hit(casting_hero: BaseHero) -> void:
	if casting_hero == null or not is_instance_valid(casting_hero) or RoleProp.roleprop == null:
		return
	var hit_data := {
		"power": maxi(1, int(float(RoleProp.roleprop.get("power", 0)) * _get_power_rate())),
		"hurtBack": [5, -3],
		"attackKind": "magic",
		"WSValue": 4,
	}
	for target in _active_monsters(casting_hero):
		if not (target is BaseMonster) or not is_instance_valid(target):
			continue
		var monster := target as BaseMonster
		if int(monster.hp) <= 0:
			continue
		if monster.get("no_target") != null and bool(monster.get("no_target")):
			continue
		if monster.global_position.distance_to(effect_anchor.global_position) > HIT_RADIUS:
			continue
		var dealt_damage := monster.apply_role_hit(self, casting_hero, hit_data)
		if dealt_damage > 0:
			_apply_stun(monster)


func _get_power_rate() -> float:
	return BASE_POWER_RATE + LEVEL_POWER_RATE * float(_get_weapon_level())


func _get_stun_duration() -> float:
	return BASE_STUN_DURATION + LEVEL_STUN_DURATION * float(_get_weapon_level())


func _apply_stun(monster: BaseMonster) -> void:
	if monster == null or not is_instance_valid(monster) or monster.is_control_immune():
		return
	var buff_node: Node = monster.get_node_or_null("Buff")
	if buff_node == null:
		buff_node = monster.get("buff") as Node
	if buff_node == null:
		return
	(
		Global
		. add_buff(
			buff_node,
			{
				"Name": "stun",
				"AddTime": _get_stun_duration(),
				"reduce_interval": 0.0,
				"value": 0,
				"AttackKind": "magic",
				"CanAdd": false,
				"DeBuff": true,
			}
		)
	)


func _active_monsters(casting_hero: BaseHero) -> Array:
	if casting_hero == null or not is_instance_valid(casting_hero):
		return []
	var player_parent := casting_hero.get_parent()
	if player_parent == null or player_parent.get_parent() == null:
		return []
	var level := player_parent.get_parent()
	if level.has_method("get_active_monsters"):
		return level.get_active_monsters()
	var monster_parent: Node = level.get("monster") as Node
	return monster_parent.get_children() if monster_parent != null else []


func _clear_effects() -> void:
	thunder_effect.stop()
	thunder_effect.visible = false
	cast_flash.stop()
	cast_flash.visible = false


func use_over() -> void:
	_cast_token += 1
	_clear_effects()
	mg_action.visible = false
	is_use = false
	fb_cd = 1
	usecd = COOLDOWN_DURATION
	if PlayerData.check_have_wx(WEAPON_ID, "木"):
		usecd *= 0.8
	skill_cd.start(usecd)


func _exit_tree() -> void:
	_cast_token += 1

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
