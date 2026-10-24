extends BaseObject
class_name BaseMonster

const NIGHTMARE_DIFFICULTY := 3
const NIGHTMARE_HEALTH_BONUS := 20000000
const NIGHTMARE_ATTACK_BONUS := 40000
const NIGHTMARE_DEFENSE_BONUS := 5000
const NIGHTMARE_HIT_BONUS := 2000
const NIGHTMARE_LEVEL_BONUS := 300
const NIGHTMARE_DAMAGE_BONUS := 0.3
const NIGHTMARE_DAMAGE_REDUCTION := 0.3
const UNDERWORLD_NIGHTMARE_HEALTH_BONUS := 40000000
const UNDERWORLD_NIGHTMARE_ATTACK_BONUS := 60000
const UNDERWORLD_NIGHTMARE_DEFENSE_BONUS := 9000
const UNDERWORLD_NIGHTMARE_DAMAGE_BONUS := 0.6
const UNDERWORLD_NIGHTMARE_DAMAGE_REDUCTION := 0.6
const HEAVEN_NIGHTMARE_HEALTH_BONUS := 100000000
const HEAVEN_NIGHTMARE_ATTACK_BONUS := 100000
const HEAVEN_NIGHTMARE_DEFENSE_BONUS := 13000
const HEAVEN_NIGHTMARE_PENETRATION_BONUS := 21000
const HEAVEN_NIGHTMARE_DAMAGE_BONUS := 1.0
const HEAVEN_NIGHTMARE_DAMAGE_REDUCTION := 1.0
const UNDERWORLD_NIGHTMARE_LEVEL_PATHS := [
	"res://Scene/level/level_nmg.tscn",
	"res://Scene/level/level_bgmj.tscn",
	"res://Scene/level/level_11.tscn",
	"res://Scene/level/level_12.tscn",
	"res://Scene/level/level_13.tscn",
	"res://Scene/level/level_14.tscn",
	"res://Scene/level/level_15.tscn",
	"res://Scene/level/level_16.tscn",
	"res://Scene/level/level_17.tscn",
	"res://Scene/level/level_18.tscn",
	"res://Scene/level/level_19.tscn",
	"res://Scene/level/level_21.tscn",
]
const HEAVEN_NIGHTMARE_LEVEL_PATHS := [
	"res://Scene/level/level_23.tscn",
	"res://Scene/level/level_24.tscn",
	"res://Scene/level/level_25.tscn",
	"res://Scene/level/level_26.tscn",
	"res://Scene/level/level_27.tscn",
	"res://Scene/level/level_28.tscn",
	"res://Scene/level/level_29.tscn",
	"res://Scene/level/level_30.tscn",
	"res://Scene/level/level_pty.tscn",
	"res://Scene/level/level_ymj.tscn",
	"res://Scene/level/level_dtwd.tscn",
	"res://Scene/level/level_llbt.tscn",
	"res://Scene/level/level_dsg_1.tscn",
	"res://Scene/level/level_dsg_2.tscn",
	"res://Scene/level/level_dsg_3.tscn",
	"res://Scene/level/level_dsg_4.tscn",
	"res://Scene/level/level_dsg_5.tscn",
	"兜率宫",
]
const HUMAN_SOUL_CRYSTAL_ITEM_PREFIX := "human_soul_crystal_"
const UNDERWORLD_SOUL_CRYSTAL_ITEM_PREFIX := "underworld_soul_crystal_"
const HEAVEN_SOUL_CRYSTAL_ITEM_PREFIX := "heaven_soul_crystal_"
const HUMAN_NIGHTMARE_NO_DROP_MONSTER_IDS := [19]
const UNDERWORLD_NIGHTMARE_SOUL_CRYSTAL_MONSTER_IDS := [
	26,
	27,
	28,
	29,
	30,
	31,
	32,
	33,
	34,
	37,
	39,
	40,
	41,
	43,
	48,
	49,
	51,
	52,
	53,
	54,
	55,
	56,
	57,
	58,
]
const HEAVEN_NIGHTMARE_SOUL_CRYSTAL_MONSTER_IDS := [
	74,
	75,
	76,
	77,
	78,
	79,
	80,
	81,
	82,
	83,
	84,
	85,
	86,
	87,
	88,
	89,
	90,
	91,
	92,
	93,
	94,
	95,
	96,
	97,
	98,
	99,
	100,
	101,
	102,
	103,
	104,
	105,
	106,
	107,
	108,
	109,
	110,
	111,
	112,
	113,
	114,
	134,
	135,
	136,
	137,
]

@onready var buff: Node = $Buff
var islljy: bool
var lpzzs: float
var tqzbs: float
var _last_monster_formation := ""
var _last_monster_formation_level: int = -1
var _lhhj_drop_disabled := false
var tszzs: float
var lpzjs: float
var no_grav: bool
var rndi_count: int = randi_range(0, 100)
var get_player: BaseHero

var get_summon: SummonBaseMonster
var c_hange_clam_count: float
var hurt_special_effect: Node2D
var is_smart_monster: bool
var is_bt
var damage_bonus: float = 0.0
var damage_reduction: float = 0.0:
	get:
		return damage_reduction + (0.25 if LocalCoop.is_enabled() else 0.0)
var _coop_health_scaled := false

var is_scary: bool
var hurt_bl: float = 1
var is_death: bool = false
var defe_reduce: float
var _max = 2
var _current = 0
var super_armor_active: bool
var is_bounds = false
var smart_hit_count: int
var smart_wait_count: int
var no_target: bool
var is_indestructible: bool
var llrdzs: float
var ran_1 = randf_range(0, 1)
var ran_2 = randf_range(0, 1)
var ran_3 = randf_range(0, 1)
var ran_4 = randf_range(0, 1)
var is_immobilize: bool = false
var is_blood_fix: bool = false
var life_mana_lock: bool = false
var level: int
var def: int
var ebol: float
var mdef: int
var lucky: int
var crit: int
var miss: int
var is_speed_down: bool
var attack_range: int
var attack_desire: int
var mysee: int
var skill_1_cd: int = 10
var skill_2_cd: int
var skill_3_cd: int
var skill_4_cd: int
var skill_5_cd: int
var skill_6_cd: int
var skill_7_cd: int
var skill_8_cd: int
var state
var ran_num: int = randi_range(10, 100)
var speed
var behit_calmtime: float
var htarget: int
var toughness: float = 0.0
var hurt_received: int
var crit_reduce: int
var ar: int
var sp: int
var bullet_1
var bullet_2
var bullet_3
var is_stun = false
var is_sleep = false
var attack_in: int
var has_target = false
var count = 0
var is_defe_reduce: bool
var add_exp: int
var self_rhp: int
var is_boss = false
var therapeutic_effects: float
var fall_coin
var my_mr_name

enum FallMode { NORMAL, TREASURE_BOX }

var current_fall_mode: FallMode = FallMode.NORMAL

var enable_treasure_box: bool = false

var treasure_box_item: String = ""


static func is_underworld_nightmare_path(level_path: String) -> bool:
	return level_path in UNDERWORLD_NIGHTMARE_LEVEL_PATHS


static func is_heaven_nightmare_path(level_path: String) -> bool:
	return level_path in HEAVEN_NIGHTMARE_LEVEL_PATHS


static func uses_heaven_nightmare_attributes(level_path: String) -> bool:
	return is_heaven_nightmare_path(level_path) or level_path == "res://Scene/level/level_stz.tscn"


func update_fall_mode():
	if enable_treasure_box and MainSet.set_data.has("BossTreasureBoxMode") and MainSet.set_data["BossTreasureBoxMode"]:
		current_fall_mode = FallMode.TREASURE_BOX

		if treasure_box_item != "":
			fall_list = [{"name": treasure_box_item, "value": 1}]
		else:
			current_fall_mode = FallMode.NORMAL
			push_warning("Boss 启用了宝箱模式但没有设置 treasure_box_item，降级为普通掉落")
	else:
		current_fall_mode = FallMode.NORMAL
		pass


var fall_pro: float
var fall_stone_pro: float
var fall_list = []
var independent_fall_list = []
var fall_stone = []

var is_fall = false
var is_fall_medi = false
var hd: int
var max_hd: int
var boss_max_protect: float = 225.0:
	set(_value):
		boss_max_protect = 225.0
var boss_current_protect: float = 0.0
var boss_protect_active: bool = false
var boss_protect_time_left: float = 0.0
const BOSS_PROTECT_DURATION: float = 3.5
const WHITE_BAR_ARMOR_DURATION: float = 7.5
var white_bar_armor_time_left: float = 0.0
const BOSS_PROTECT_GAIN_MIN: int = 1
const BOSS_PROTECT_GAIN_MAX: int = 3
const BOSS_PROTECT_IDLE_DECAY: float = 6.0
const BOSS_PROTECT_IDLE_DELAY_MSEC: int = 1000
var boss_protect_last_hit_msec: int = 0
var spawn_damage_protection_until_msec: int = 0
var total_hit: int
var total_hurt: int
var add_buff
var is_quiescent = false
var ws_hd = false
var lj_count: int = 0
var is_enter_hit_box
var rush_speed: float = 0.0
var hit_target
var get_target
var _is_set: bool
var init_speed
var is_jgz: bool
var jgz_bl: float = 1
var jgz_count: int
var is_zznh: bool = false
var zznh_bl: float = 1.0
var zznh_defense_reduction: float = 0.0

var my_blood
var cannot_attract: bool
var is_lpz: bool
var is_llrd: bool
@onready var bullet: Node = $Bullet
@onready var hit_box: CollisionShape2D = $BaseDamageBox/HitBox/HitBox
@onready var hurt_box: CollisionShape2D = $BaseDamageBox/HurtBox/HurtBox
@onready var damage_text: Node2D = $damage_text
@onready var base_damage_box: Node2D = $BaseDamageBox
@onready var pz: CollisionShape2D = $pz
@onready var mr_player: AnimationPlayer = $mr_player
@onready var mr_ani: AnimatedSprite2D = $MonsterDir/mr_ani
@onready var monster_dir: Node2D = $MonsterDir
@onready var remove_hurt_bl: Timer = $RemoveHurtBL

var level_cache_valid: bool = false

var llrd_count: int = 0
var run_hit_active: bool
var run_hit_count: int = 0
var monster_direction: bool = false
var hit_text
var is_fly = false
enum State {
	OTHER,
	DEATH,
	IS_TOP,
	IS_UNDER,
}
var hit_name
var monster_blood_bar: MrBloodBar
var onset: bool
var base_level: Node
var should_in_sky: bool
var _ai_tick_offset: int = randi_range(0, 7)
var _friendly_knockback_generation: int = 0
var _control_movement_locked: bool = false
var _control_movement_tweens: Array = []
var _hurt_reaction_active: bool = false
var _hurt_reaction_generation: int = 0


func apply_tower_monster_config(config: Dictionary) -> void:
	if config.is_empty():
		return
	set_meta("tower_config", config.duplicate(true))
	set_health_without_coop(int(config.get("hp", get_health_without_coop())))
	var tower_attack := int(config.get("attack", 0))
	def = int(config.get("def", def))
	mdef = int(config.get("mdef", mdef))
	crit = int(config.get("crit", crit))
	miss = int(config.get("miss", miss))
	htarget = int(config.get("hit", htarget))
	ar = int(config.get("armor_break", ar))
	sp = int(config.get("magic_break", sp))
	if bool(config.get("nightmare", false)):
		damage_bonus = NIGHTMARE_DAMAGE_BONUS
		damage_reduction = NIGHTMARE_DAMAGE_REDUCTION
		level += NIGHTMARE_LEVEL_BONUS
		lucky *= 3
		toughness *= 3.0
		crit_reduce *= 3
		self_rhp *= 3

	for attack_name in obj_attack_dict:
		var attack_data: Variant = obj_attack_dict[attack_name]
		if attack_data is Dictionary and (attack_data as Dictionary).has("power"):
			(attack_data as Dictionary)["power"] = tower_attack


func set_gra():
	gravity = -980


func can_set_gra():
	return not no_grav and not islljy and not should_in_sky


func _ready() -> void:
	self.max_hp = self.max_hp + randi_range(0, 1)
	self.hp = self.hp + randi_range(0, 1)
	if is_node_ready():
		_apply_coop_health_scaling()
	$CalmHit.start(c_hange_clam_count)

	if is_fly:
		if mr_player.has_animation("Fly_wait"):
			mr_player.play("Fly_wait")
		elif mr_player.has_animation("fly_wait"):
			mr_player.play("fly_wait")
		elif mr_player.has_animation("Fly"):
			mr_player.play("Fly")
		elif mr_player.has_animation("fly"):
			mr_player.play("fly")
		else:
			try_play_default_animation()
	else:
		try_play_default_animation()

	$BaseDamageBox/HitBox/HitBox.disabled = true

	if MainSet.set_data["NoShowMonsterBody"] == false:
		monster_dir.visible = false


func _exit_tree() -> void:
	_clear_visual_resources(self)


func _clear_visual_resources(node: Node) -> void:
	if node is AnimatedSprite2D:
		var animated_sprite := node as AnimatedSprite2D
		animated_sprite.stop()
		animated_sprite.sprite_frames = null
	elif node is Sprite2D:
		var sprite := node as Sprite2D
		sprite.texture = null
	for child in node.get_children():
		_clear_visual_resources(child)


func try_play_default_animation():
	if mr_player.has_animation("wait"):
		mr_player.play("wait")
	elif mr_player.has_animation("idle"):
		mr_player.play("idle")
	elif mr_player.get_animation_list().size() > 0:
		var anim_list = mr_player.get_animation_list()
		mr_player.play(anim_list[0])
	else:
		print("⚠️ 怪物 ", name, " 没有任何动画")


func get_level_node() -> Node:
	if level_cache_valid and is_instance_valid(base_level):
		return base_level

	if not is_inside_tree():
		return null

	var tree = get_tree()
	if not tree:
		base_level = self
		level_cache_valid = true
		return base_level

	var node = get_parent()
	while node:
		if node is BaseLevel:
			base_level = node
			level_cache_valid = true
			return base_level
		node = node.get_parent()

	var base_levels = tree.get_nodes_in_group("BaseLevel")
	if base_levels.size() > 0:
		base_level = base_levels[0]
		level_cache_valid = true
		return base_level

	var scene_root = tree.current_scene
	if scene_root and scene_root.has_node("BaseLevel"):
		base_level = scene_root.get_node("BaseLevel")
		level_cache_valid = true
		return base_level

	var all_nodes = tree.get_nodes_in_group("level_container")
	if all_nodes.size() > 0:
		base_level = all_nodes[0]
		level_cache_valid = true
		return base_level

	base_level = tree.current_scene
	if not base_level:
		base_level = self
	level_cache_valid = true
	return base_level


func invalidate_level_cache():
	level_cache_valid = false


func _physics_process(delta: float) -> void:
	if is_queued_for_deletion() or not is_inside_tree():
		return
	_process_boss_protect(delta)
	_enforce_control_immunity_state()
	_process_pet_tiger_sxhz_air_hold()
	if can_set_gra():
		gravity = -980
	else:
		gravity = 0
	if islljy and hp > 0:
		mr_player.play("hurt")
	if llrd_count > 0:
		llrd_count -= 1
		llrdzs = 1.3
	else:
		llrdzs = 1
	jsfzsy()

	var level_node = get_level_node()
	if not _lhhj_drop_disabled and level_node is Lhhj:
		_lhhj_drop_disabled = true
		fall_coin = 0
		if fall_list is Array:
			fall_list.clear()
		fall_pro = 0
		fall_stone_pro = 0
		add_exp = 0
		if fall_stone is Array:
			fall_stone.clear()

	wd_hurt()

	if MainSet.set_data["MonsterBloodSHow"]:
		if is_boss:
			if my_blood == null:
				var parent_node = level_node.monster_blood
				my_blood = Global.add_boss_blood_instance(parent_node, self)

	if self.position.x <= 0:
		self.position.x = 100

	if self.position.y >= 800 and get_meta("allow_position_y_over_800", false) != true:
		self.position.y = 400
	if not _is_set:
		if MainSet.set_data["Difficult"] > 0 and not has_meta("tower_floor"):
			difficult()
		init_speed = speed
		_is_set = true
	check_add_buff()
	_recover_interrupted_combat_state()
	_enforce_control_immunity_state()
	if MainSet.set_data["NoShowMonsterBody"] == false:
		monster_dir.visible = false
	if monster_dir.scale.x == 1:
		monster_direction = false
	else:
		monster_direction = true
	get_player = Global.get_player
	count += 1
	if death():
		state = State.DEATH
		if has_meta("tower_floor") and not get_meta("death_drops_settled", false):
			settle_death_drops()
	else:
		state = State.OTHER
	if not is_on_floor() and not is_fly:
		velocity.y -= gravity * delta
	match state:
		State.DEATH:
			state_death()
	if MainSet.set_data["MonsterLittleBlood"] and MainSet.set_data["NoShowMonsterBody"]:
		little_blood_bar_control()
	if self.hp > 0 and not is_limit_buff() and not _hurt_reaction_active and _should_run_ai_this_frame():
		ai_think()
	if is_movement_locked_by_control():
		interrupt_movement_for_control()
	elif is_scary:
		if not is_be_attacking:
			when_scary()
	check_hp()
	if not is_queued_for_deletion() and is_inside_tree():
		move_and_slide()


func _should_run_ai_this_frame() -> bool:
	if has_target:
		return true
	var role_position_x = RoleProp.get_nearest_monster_target_position(global_position).x
	if role_position_x != null and absf(float(role_position_x) - position.x) < float(mysee):
		return true
	var parent := get_parent()
	if parent == null:
		return true
	var active_count := parent.get_child_count()
	var interval := 1
	if active_count >= 30:
		interval = 4
	elif active_count >= 18:
		interval = 3
	elif active_count >= 10:
		interval = 2
	if is_boss:
		interval = mini(interval, 2)
	if interval <= 1:
		return true
	return int(Engine.get_physics_frames() + _ai_tick_offset) % interval == 0


func is_limit_buff():
	if is_control_immune():
		return false
	return is_movement_locked_by_control() or is_scary


func is_movement_locked_by_control() -> bool:
	if is_control_immune():
		return false
	return is_ice or is_stun or is_immobilize or is_sleep or islljy or is_eye_fix


func interrupt_movement_for_control() -> void:
	if is_control_immune():
		return
	velocity.x = 0
	if is_fly:
		velocity.y = 0
	_kill_control_movement_tweens()
	if _control_movement_locked:
		return
	_control_movement_locked = true
	if mr_player == null:
		return
	var current_animation := String(mr_player.current_animation)
	if current_animation in ["walk", "walk_1", "walk_2", "run", "Fly", "fly"]:
		var idle_animations := (
			["Fly_wait", "fly_wait", "wait", "idle"] if is_fly else ["wait", "idle", "wait_1", "wait_2"]
		)
		for idle_animation in idle_animations:
			if mr_player.has_animation(idle_animation):
				mr_player.play(idle_animation)
				break


func extend_timed_hit_stun(stun_key: String, duration: float = 0.2) -> void:
	if is_control_immune():
		return
	var until_key := stun_key + "_until_msec"
	var pending_key := stun_key + "_release_pending"
	var until_msec := Time.get_ticks_msec() + int(maxf(duration, 0.0) * 1000.0)
	set_meta(until_key, maxi(int(get_meta(until_key, 0)), until_msec))
	is_be_attacking = true
	interrupt_movement_for_control()
	if bool(get_meta(pending_key, false)):
		return
	set_meta(pending_key, true)
	call_deferred("_release_timed_hit_stun", until_key, pending_key)


func _release_timed_hit_stun(until_key: String, pending_key: String) -> void:
	while is_inside_tree():
		var remaining_msec := int(get_meta(until_key, 0)) - Time.get_ticks_msec()
		if remaining_msec <= 0:
			break
		await get_tree().create_timer(float(remaining_msec) / 1000.0, false).timeout
	if has_meta(until_key):
		remove_meta(until_key)
	if has_meta(pending_key):
		remove_meta(pending_key)
	if not _hurt_reaction_active:
		is_be_attacking = false


func create_control_movement_tween() -> Tween:
	var movement_tween := create_tween()
	_control_movement_tweens.append(movement_tween)
	movement_tween.finished.connect(_forget_control_movement_tween.bind(movement_tween), CONNECT_ONE_SHOT)
	return movement_tween


func _forget_control_movement_tween(movement_tween: Tween) -> void:
	_control_movement_tweens.erase(movement_tween)


func _kill_control_movement_tweens() -> void:
	for movement_tween in _control_movement_tweens:
		if movement_tween != null and movement_tween.is_valid():
			movement_tween.kill()
	_control_movement_tweens.clear()


func _release_control_movement_lock() -> void:
	_control_movement_locked = false


func _movement_command_is_blocked() -> bool:
	return _control_movement_locked or is_movement_locked_by_control() or _hurt_reaction_active


func _recover_interrupted_combat_state() -> void:
	if is_limit_buff():
		return
	if _hurt_reaction_active:
		return
	if has_meta("pet_tiger_sxhz_hold_until"):
		return
	if has_meta("pet_summon_knockback_token"):
		var knockback_until := int(get_meta("pet_summon_knockback_until", 0))
		if Time.get_ticks_msec() < knockback_until:
			return
		_clear_friendly_knockback_lock(int(get_meta("pet_summon_knockback_token", -1)))
	var current_animation := String(mr_player.current_animation)
	var is_idle_animation := (
		current_animation
		in ["", "wait", "idle", "walk", "Fly", "Fly_wait", "wait_1", "wait_2", "walk_1", "walk_2", "Hands", "can_hurt"]
	)
	if not mr_player.is_playing() or is_idle_animation:
		is_attacking = false
		is_be_attacking = false
		is_using_skills = false
		if "_skill_busy" in self:
			set("_skill_busy", false)
		if "is_special_combo" in self:
			set("is_special_combo", false)


func _process_boss_protect(delta: float) -> void:
	white_bar_armor_time_left = maxf(0.0, white_bar_armor_time_left - delta)
	if not is_boss:
		boss_current_protect = 0.0
		boss_protect_active = false
		boss_protect_time_left = 0.0
		_set_boss_protect_transparent(false)
		return
	if boss_protect_active:
		_set_boss_protect_transparent(true)
		boss_protect_time_left = maxf(0.0, boss_protect_time_left - delta)
		boss_current_protect = boss_max_protect * boss_protect_time_left / BOSS_PROTECT_DURATION
		if boss_protect_time_left <= 0.0:
			boss_protect_active = false
			boss_current_protect = 0.0
			_set_boss_protect_transparent(false)
		return
	var since_last_hit := Time.get_ticks_msec() - boss_protect_last_hit_msec
	if since_last_hit > BOSS_PROTECT_IDLE_DELAY_MSEC:
		boss_current_protect = maxf(0.0, boss_current_protect - BOSS_PROTECT_IDLE_DECAY * delta)


func _add_boss_protect_from_hit(_source: Node) -> void:
	if not is_boss or boss_protect_active:
		return
	boss_protect_last_hit_msec = Time.get_ticks_msec()
	var gain := float(randi_range(BOSS_PROTECT_GAIN_MIN, BOSS_PROTECT_GAIN_MAX))
	boss_current_protect = minf(boss_max_protect, boss_current_protect + gain)
	if boss_current_protect >= boss_max_protect:
		boss_current_protect = boss_max_protect
		boss_protect_active = true
		boss_protect_time_left = BOSS_PROTECT_DURATION
		white_bar_armor_time_left = WHITE_BAR_ARMOR_DURATION
		Global.clear_white_bar_control_buffs(buff)
		_enforce_control_immunity_state()
		_reset_white_bar_skill_cooldowns()
		velocity.x = 0.0
		is_be_attacking = false
		_set_boss_protect_transparent(true)


func _set_boss_protect_transparent(active: bool) -> void:
	var body_color := modulate
	body_color.a = 0.5 if active else 1.0
	modulate = body_color


func is_boss_protecting() -> bool:
	return is_boss and boss_protect_active


func start_spawn_damage_protection(duration: float = 0.75) -> void:
	spawn_damage_protection_until_msec = maxi(
		spawn_damage_protection_until_msec, Time.get_ticks_msec() + int(maxf(duration, 0.0) * 1000.0)
	)


func is_spawn_damage_protected() -> bool:
	return Time.get_ticks_msec() < spawn_damage_protection_until_msec


func is_control_immune() -> bool:
	return super_armor_active or is_boss_protecting() or is_white_bar_control_immune()


func is_white_bar_control_immune() -> bool:
	return is_boss and white_bar_armor_time_left > 0.0


func _reset_white_bar_skill_cooldowns() -> void:
	for slot in range(1, 9):
		set("skill_%d_cd" % slot, 0)
	for property in get_property_list():
		var key := str(property.name)
		var value: Variant = get(key)
		if key in ["_skill_ready_msec", "_3182_skill_ready_msec"] and value is Dictionary:
			for skill_slot in value:
				value[skill_slot] = 0
		elif (
			key
			in [
				"_skill1_cd",
				"_skill2_cd",
				"summon_cooldown",
				"moonlight_cooldown",
				"_near_buff_cooldown",
				"_3179_blood_eye_ready_msec",
				"_3179_fire_dash_cooldown_until_msec",
				"_3182_phase_ready_msec",
				"_3182_global_ready_msec",
			]
		):
			set(key, 0)
	for path in ["Skill1Cooldown", "Skill2Cooldown", "Jumpcd"]:
		var timer := get_node_or_null(path) as Timer
		if timer != null:
			timer.stop()


func _enforce_control_immunity_state() -> void:
	if not is_control_immune():
		return
	if _hurt_reaction_active:
		_cancel_hurt_reaction()
	is_be_attacking = false
	is_stun = false
	is_immobilize = false
	is_ice = false
	is_sleep = false
	is_eye_fix = false
	is_dead_link = false
	is_blood_fix = false
	life_mana_lock = false
	is_scary = false
	islljy = false
	is_speed_down = false
	if is_white_bar_control_immune():
		Global.clear_white_bar_control_buffs(buff)
	is_reverse_move = false
	reverse_move_speed_multiplier = 1.0
	if init_speed != null:
		speed = init_speed
	_kill_control_movement_tweens()
	_release_control_movement_lock()


func _process_pet_tiger_sxhz_air_hold() -> void:
	if not has_meta("pet_tiger_sxhz_hold_until"):
		return
	if is_control_immune():
		_release_pet_tiger_sxhz_air_hold()
		velocity = Vector2.ZERO
		return
	var hold_until: int = int(get_meta("pet_tiger_sxhz_hold_until", 0))
	if Time.get_ticks_msec() < hold_until:
		if has_meta("pet_tiger_sxhz_hold_position"):
			global_position = get_meta("pet_tiger_sxhz_hold_position")
		no_grav = true
		is_stun = true
		is_be_attacking = true
		velocity = Vector2.ZERO
		return
	_release_pet_tiger_sxhz_air_hold()


func _release_pet_tiger_sxhz_air_hold() -> void:
	if has_meta("pet_tiger_sxhz_hold_token"):
		remove_meta("pet_tiger_sxhz_hold_token")
	if has_meta("pet_tiger_sxhz_hold_until"):
		remove_meta("pet_tiger_sxhz_hold_until")
	if has_meta("pet_tiger_sxhz_hold_position"):
		remove_meta("pet_tiger_sxhz_hold_position")
	_remove_pet_tiger_sxhz_stun_buff()
	no_grav = false
	should_in_sky = false
	is_be_attacking = false
	is_stun = false
	velocity.x = 0
	velocity.y = 520.0


func begin_friendly_knockback_lock(duration: float) -> void:
	if is_control_immune():
		return
	_friendly_knockback_generation += 1
	var knockback_token := _friendly_knockback_generation
	set_meta("pet_summon_knockback_token", knockback_token)
	set_meta("pet_summon_knockback_until", Time.get_ticks_msec() + int(maxf(0.0, duration) * 1000.0))
	is_be_attacking = true
	_release_friendly_knockback_lock_after(knockback_token, duration)


func _release_friendly_knockback_lock_after(knockback_token: int, duration: float) -> void:
	await get_tree().create_timer(maxf(0.0, duration), false).timeout
	_clear_friendly_knockback_lock(knockback_token)


func _clear_friendly_knockback_lock(knockback_token: int) -> void:
	if int(get_meta("pet_summon_knockback_token", -1)) != knockback_token:
		return
	remove_meta("pet_summon_knockback_token")
	if has_meta("pet_summon_knockback_until"):
		remove_meta("pet_summon_knockback_until")
	if not has_meta("pet_tiger_sxhz_hold_until"):
		is_be_attacking = false


func _remove_pet_tiger_sxhz_stun_buff() -> void:
	if buff == null:
		return
	for child in buff.get_children():
		if child == null:
			continue
		var info = child.get("buff_info")
		if info is Dictionary and str(info.get("Name", "")) == "stun" and bool(info.get("PetTigerSxhz", false)):
			buff.remove_child(child)
			child.queue_free()


func ai_think():
	var role_position_x = RoleProp.get_nearest_monster_target_position(global_position).x
	if role_position_x == null:
		return
	if abs(float(role_position_x) - position.x) < mysee:
		has_target = true
	if (
		not is_ice
		and not is_sleep
		and not is_stun
		and not cannotchangestatewhenattorbeatt()
		and not is_immobilize
		and not islljy
	):
		if has_target == false:
			normal_state()
		else:
			if is_smart_monster:
				if abs(position.x - float(role_position_x)) >= attack_range:
					if rndi_count < smart_wait_count:
						have_target()
					else:
						normal_state()
					if count % 90 == 0:
						if randi_range(0, 100) < smart_hit_count:
							attack_target()
				else:
					if rndi_count < 60:
						normal_state()
					else:
						stop_move()
					if count % 60 == 0:
						if randi_range(0, 100) < attack_desire:
							attack_target()
			else:
				if follow_hero():
					have_target()
					if run_hit_active:
						if count % run_hit_count == 0:
							if randi_range(0, 100) <= attack_desire:
								attack_target()
							else:
								if randi_range(0, 100) <= 20:
									stop_move()
								else:
									have_target()
				else:
					stop_move()
					if count % 60 == 0:
						if randi_range(0, 100) < attack_desire:
							attack_target()


func run_hit():
	if ran_num < 70:
		if position.x > RoleProp.get_nearest_monster_target_position(global_position).x + randi_range(-60, 60):
			move_left()
		elif position.x < RoleProp.get_nearest_monster_target_position(global_position).x - randi_range(-60, 60):
			move_right()
		else:
			stop_move()
	else:
		stop_move()


func follow_hero():
	return abs(position.x - RoleProp.get_nearest_monster_target_position(global_position).x) > attack_range


func to_hero():
	if RoleProp.get_nearest_monster_target_position(global_position).x > position.x:
		base_damage_box.scale.x = -1
		monster_dir.scale.x = -1
	else:
		base_damage_box.scale.x = 1
		monster_dir.scale.x = 1


func attack_target():
	if RoleProp.get_nearest_monster_target_position(global_position).x > position.x:
		base_damage_box.scale.x = -1
		monster_dir.scale.x = -1
	else:
		base_damage_box.scale.x = 1
		monster_dir.scale.x = 1
	hit_name = "hit1"
	if not is_fly:
		velocity.x = 0
	is_attacking = true
	mr_player.play("hit1")
	await mr_player.animation_finished
	is_attacking = false
	if not is_fly:
		stop_move()


func normal_state():
	if is_quiescent:
		return
	if is_fly:
		if ran_num < 95:
			if RoleProp.get_nearest_monster_target_position(global_position).y > position.y + randi_range(125, 245):
				move_down()
			elif RoleProp.get_nearest_monster_target_position(global_position).y < position.y + randi_range(15, 65):
				move_up()
		else:
			if ran_num < 50:
				move_down()
			else:
				move_up()
	if is_be_attacking:
		return

	if ran_num < 10:
		stop_move()
	elif ran_num >= 10 and ran_num <= 55:
		move_left()
	else:
		move_right()


func else_have_target():
	if is_quiescent:
		return
	if is_fly:
		if RoleProp.get_nearest_monster_target_position(global_position).y > position.y + randi_range(15, 85):
			move_up()
		elif RoleProp.get_nearest_monster_target_position(global_position).y < position.y - randi_range(15, 85):
			move_down()
	if RoleProp.get_nearest_monster_target_position(global_position).x > position.x + randi_range(65, 85):
		move_left()
	elif RoleProp.get_nearest_monster_target_position(global_position).x < position.x - randi_range(65, 85):
		move_right()
	else:
		stop_move()


func have_target():
	if is_quiescent:
		return
	if is_fly:
		if RoleProp.get_nearest_monster_target_position(global_position).y > position.y + randi_range(125, 245):
			move_down()
		elif RoleProp.get_nearest_monster_target_position(global_position).y < position.y + randi_range(15, 45):
			move_up()
	if RoleProp.get_nearest_monster_target_position(global_position).x > position.x + randi_range(65, 85):
		move_right()
	elif RoleProp.get_nearest_monster_target_position(global_position).x < position.x - randi_range(65, 85):
		move_left()


func move_left():
	if _movement_command_is_blocked():
		if not _hurt_reaction_active:
			velocity.x = 0
		return
	base_damage_box.scale.x = 1
	monster_dir.scale.x = 1

	if is_scary:
		velocity.x = -speed * 15
	else:
		velocity.x = -speed * 10
	var movement_animation := "Fly" if is_fly else "walk"
	if mr_player.current_animation != movement_animation:
		mr_player.play(movement_animation)


func move_right():
	if _movement_command_is_blocked():
		if not _hurt_reaction_active:
			velocity.x = 0
		return
	base_damage_box.scale.x = -1
	monster_dir.scale.x = -1

	if is_scary:
		velocity.x = speed * 15
	else:
		velocity.x = speed * 10
	var movement_animation := "Fly" if is_fly else "walk"
	if mr_player.current_animation != movement_animation:
		mr_player.play(movement_animation)


func move_up():
	if _movement_command_is_blocked():
		if not _hurt_reaction_active:
			velocity.y = 0
		return
	velocity.y = -speed * randi_range(7, 9)
	if not is_fly:
		mr_player.play("walk")
	else:
		mr_player.play("Fly")


func move_down():
	if _movement_command_is_blocked():
		if not _hurt_reaction_active:
			velocity.y = 0
		return
	velocity.y = speed * randi_range(7, 9)
	if not is_fly:
		mr_player.play("walk")
	else:
		mr_player.play("Fly")


func stop_move():
	if _hurt_reaction_active:
		return
	velocity.x = 0
	var idle_animation := "Fly_wait" if is_fly else "wait"
	if mr_player.current_animation != idle_animation:
		mr_player.play(idle_animation)


func stop():
	if _hurt_reaction_active:
		return
	velocity.x = 0


func turn_towad_role():
	if RoleProp.get_nearest_monster_target_position(global_position).x < position.x:
		self.scale.x = 1

	else:
		mr_ani.flip_h = true


func state_hurt():
	if death() or is_death:
		return

	if is_control_immune():
		return

	if self is Monster114:
		if get_target.hit_dic["hurtBack"][0] != 0 or get_target.hit_dic["hurtBack"][1] != 0:
			var hurt_generation := _begin_hurt_reaction()
			is_be_attacking = true

			if mr_player.has_animation("hurt"):
				mr_player.play("hurt")
				await mr_player.animation_finished
			else:
				await get_tree().create_timer(0.2).timeout
			if hurt_generation != _hurt_reaction_generation or is_control_immune() or death() or is_death:
				return
			velocity.x = 0
			_finish_hurt_reaction(hurt_generation)
		return

	if get_target.hit_dic["hurtBack"][0] != 0 or get_target.hit_dic["hurtBack"][1] != 0:
		var hurt_generation := _begin_hurt_reaction()
		is_be_attacking = true
		velocity.x = 0
		if is_control_immune() or hurt_generation != _hurt_reaction_generation:
			return
		if not (is_quiescent or is_bt):
			be_hit_back(get_target)
		if mr_player.has_animation("hurt"):
			await get_tree().process_frame
			if hurt_generation != _hurt_reaction_generation or is_control_immune() or death() or is_death:
				return
			mr_player.play("hurt")
			await mr_player.animation_finished
		else:
			await get_tree().create_timer(0.2).timeout
		_finish_hurt_reaction(hurt_generation)


func _begin_hurt_reaction() -> int:
	_hurt_reaction_generation += 1
	_hurt_reaction_active = true
	_kill_control_movement_tweens()
	return _hurt_reaction_generation


func _finish_hurt_reaction(hurt_generation: int) -> void:
	if hurt_generation != _hurt_reaction_generation:
		return
	_hurt_reaction_active = false
	is_be_attacking = false


func _cancel_hurt_reaction() -> void:
	_hurt_reaction_generation += 1
	_hurt_reaction_active = false


func _deferred_hurt_animation():
	if is_control_immune():
		return
	if mr_player.has_animation("hurt"):
		mr_player.play("hurt")
		await mr_player.animation_finished

	if is_control_immune():
		return
	try_play_default_animation()


func little_blood_bar_control():
	if monster_blood_bar != null:
		var pet_hit_show := Time.get_ticks_msec() < int(get_meta("pet_hit_blood_until", 0))
		if not is_be_attacking and not pet_hit_show:
			monster_blood_bar.can_show = false
			monster_blood_bar.bar_value = float(hp) / float(max_hp)
			monster_blood_bar.bar_text = hp
		else:
			monster_blood_bar.bar_value = float(hp) / float(max_hp)
			monster_blood_bar.bar_text = hp
			monster_blood_bar.can_show = true


func set_hd(value, max_value):
	hd = value
	max_hd = max_value


func be_hit_back(target):
	if hd > 0:
		return
	if target == null:
		return
	if target is BaseHero:
		if not get_player.player_dir:
			attack_to_right(target.hit_dic["hurtBack"])
		else:
			attack_to_left(target.hit_dic["hurtBack"])
	elif target is BaseMagicWeapon:
		if not target.mg_action.flip_h:
			attack_to_right(target.hit_dic["hurtBack"])
		else:
			attack_to_left(target.hit_dic["hurtBack"])
	elif target is RoleBullet:
		if not target.direction:
			attack_to_right(target.hit_dic["hurtBack"])
		else:
			attack_to_left(target.hit_dic["hurtBack"])
	elif target is RoleBullet1:
		if not get_player.player_dir:
			attack_to_right(target.hit_dic["hurtBack"])
		else:
			attack_to_left(target.hit_dic["hurtBack"])

	elif target is MgHit:
		var bullet = target as MgHit
		var hero = null

		if bullet.source_weapon and bullet.source_weapon is BaseMagicWeapon:
			hero = bullet.source_weapon.player

		if hero == null:
			hero = get_player

		if hero and hero is BaseHero:
			if hero.player_dir:
				attack_to_right(bullet.hit_dic["hurtBack"])
			else:
				attack_to_left(bullet.hit_dic["hurtBack"])
		else:
			if bullet.source_weapon and bullet.source_weapon.mg_action.flip_h:
				attack_to_right(bullet.hit_dic["hurtBack"])
			else:
				attack_to_left(bullet.hit_dic["hurtBack"])
	else:
		return


func attack_to_right(list):
	if is_control_immune():
		return
	var sp_x = list[0]
	var sp_y = list[1]
	self.velocity.x = -sp_x * 30
	if not is_fly:
		self.velocity.y = sp_y * 15
	else:
		self.velocity.y = sp_y * 3


func attack_to_left(list):
	if is_control_immune():
		return
	var sp_x = list[0]
	var sp_y = list[1]
	self.velocity.x = sp_x * 30
	if not is_fly:
		self.velocity.y = sp_y * 15
	else:
		self.velocity.y = sp_y * 3


func state_death():
	if not bool(get_meta("counts_as_alive_for_stage_clear", false)):
		settle_death_drops()
	if get_meta("sssl_special_boss", false):
		if is_death:
			return
		velocity = Vector2.ZERO
		is_attacking = false
		is_using_skills = false
		_cancel_hurt_reaction()
		_kill_control_movement_tweens()
		is_be_attacking = false
		if hit_box != null and is_instance_valid(hit_box):
			hit_box.set_deferred("disabled", true)
		if hurt_box != null and is_instance_valid(hurt_box):
			hurt_box.set_deferred("disabled", true)
		set_exp()
		set_gxp()
		if not get_meta("sssl_kill_counted", false):
			set_meta("sssl_kill_counted", true)
			if PlayerData.player_data.has(my_mr_name) and not base_level is Lhhj:
				PlayerData.player_data[my_mr_name] += 1
		is_death = true
		mr_player.play("death")
		if not get_meta("sssl_death_cleanup_started", false):
			set_meta("sssl_death_cleanup_started", true)
			call_deferred("_finish_sssl_death")
		return
	set_exp()
	set_gxp()
	velocity.x = 0
	if not self is Monster32:
		mr_player.play("death")

		if not is_death:
			if PlayerData.player_data.has(my_mr_name):
				var current = PlayerData.player_data[my_mr_name]
				if self is Monster17 or self is Monster30 or self is Monster31 or self is Monster28:
					if is_boss:
						if not base_level is Lhhj:
							PlayerData.player_data[my_mr_name] += 1
				elif self is Monster49:
					pass
				else:
					if not base_level is Lhhj:
						PlayerData.player_data[my_mr_name] += 1
		is_death = true
		await mr_player.animation_finished
	else:
		if _current < _max:
			if not is_bounds:
				is_bounds = true
				mr_player.play("bounds")
				if PlayerData.player_data.has(my_mr_name):
					var current = PlayerData.player_data[my_mr_name]
					if not base_level is Lhhj:
						PlayerData.player_data[my_mr_name] += 1

				return
		else:
			mr_player.play("death")
			if not is_death:
				if PlayerData.player_data.has(my_mr_name):
					var current = PlayerData.player_data[my_mr_name]
					if not base_level is Lhhj:
						PlayerData.player_data[my_mr_name] += 1
			is_death = true
			await mr_player.animation_finished


func _finish_sssl_death() -> void:
	var death_length := 0.9
	if mr_player != null and is_instance_valid(mr_player):
		var death_animation := mr_player.get_animation(&"death")
		if death_animation != null:
			death_length = maxf(float(death_animation.length) + 0.08, 0.25)
	await get_tree().create_timer(death_length, false).timeout
	if is_instance_valid(self) and not is_queued_for_deletion():
		settle_death_drops_and_free()


func get_zcld_multiplier() -> float:
	if get_player != null and PlayerData.check_eq_zb("法宝", "zcld"):
		var level = get_player.zcld_level

		var bonus = 0.2 + level * 0.08

		return 1.0 + min(bonus, 1.0)
	return 1.0


func settle_death_drops_and_free() -> void:
	if is_queued_for_deletion():
		return
	settle_death_drops()
	queue_free()


func _is_tower_drop_context() -> bool:
	if has_meta("tower_floor"):
		return true
	var level_node: Node = get_level_node()
	return level_node != null and level_node.has_method("on_tower_monster_defeated")


func settle_death_drops() -> void:
	if get_meta("death_drops_settled", false):
		return
	set_meta("death_drops_settled", true)
	if _settle_nightmare_soul_drop():
		return

	if not _is_tower_drop_context():
		fall_items()
		fall_medicine()
		_spawn_fall_stone()
	var level_node = get_level_node()
	if has_meta("tower_floor") and level_node != null and level_node.has_method("on_tower_monster_defeated"):
		level_node.call("on_tower_monster_defeated", self)


func _settle_human_nightmare_soul_drop() -> bool:
	return _settle_nightmare_soul_drop()


func _settle_nightmare_soul_drop() -> bool:
	var difficulty := int(MainSet.set_data.get("Difficult", 0))
	if difficulty != NIGHTMARE_DIFFICULTY:
		return false
	var monster_id := _human_soul_crystal_monster_id()
	var item_id := ""
	var is_human_soul_crystal := monster_id >= 1 and monster_id <= 24
	if is_human_soul_crystal:
		if monster_id in HUMAN_NIGHTMARE_NO_DROP_MONSTER_IDS:
			set_meta("human_nightmare_soul_drop_settled", true)
			return true
		item_id = HUMAN_SOUL_CRYSTAL_ITEM_PREFIX + str(monster_id)
	elif _is_underworld_nightmare_level():
		set_meta("underworld_nightmare_soul_drop_settled", true)
		if monster_id not in UNDERWORLD_NIGHTMARE_SOUL_CRYSTAL_MONSTER_IDS:
			return true
		item_id = UNDERWORLD_SOUL_CRYSTAL_ITEM_PREFIX + str(monster_id)
	elif _is_heaven_nightmare_level():
		set_meta("heaven_nightmare_soul_drop_settled", true)
		if monster_id not in HEAVEN_NIGHTMARE_SOUL_CRYSTAL_MONSTER_IDS:
			return true
		item_id = HEAVEN_SOUL_CRYSTAL_ITEM_PREFIX + str(monster_id)
	else:
		return false
	if is_human_soul_crystal:
		set_meta("human_nightmare_soul_drop_settled", true)
	if has_meta("nightmare_soul_drop_settled"):
		return true
	set_meta("nightmare_soul_drop_settled", true)
	var soul_drop_chance := _get_human_nightmare_soul_drop_chance()
	if randf() >= soul_drop_chance:
		return true
	var level_node := get_level_node()
	if level_node == null:
		return true
	var fall_container: Variant = level_node.get("fall_it")
	if fall_container == null:
		return true
	Global.fall_item(fall_container, Vector2(position.x, position.y - 30), item_id, randi_range(3, 5))
	return true


func _is_underworld_nightmare_level() -> bool:
	if int(MainSet.set_data.get("Difficult", 0)) != NIGHTMARE_DIFFICULTY:
		return false
	var level_node := get_level_node()
	return level_node != null and is_underworld_nightmare_path(str(level_node.scene_file_path))


func _is_heaven_nightmare_level() -> bool:
	if int(MainSet.set_data.get("Difficult", 0)) != NIGHTMARE_DIFFICULTY:
		return false
	var level_node := get_level_node()
	return level_node != null and is_heaven_nightmare_path(str(level_node.scene_file_path))


func _get_human_nightmare_soul_drop_chance() -> float:
	var soul_drop_chance := 0.25
	if RoleProp.source_player != null and RoleProp.source_player.is_double_fall_pro:
		soul_drop_chance = clampf(soul_drop_chance * 2.0, 0.0, 1.0)
	return soul_drop_chance


func _human_soul_crystal_monster_id() -> int:
	var candidates: Array[String] = [str(scene_file_path), str(name)]
	var monster_script := get_script() as Script
	if monster_script != null:
		candidates.append(str(monster_script.resource_path))
	var id_pattern: RegEx = RegEx.create_from_string("(?:^|/)monster_?(\\d+)(?:\\.(?:tscn|gd))?$")
	for candidate in candidates:
		var match: RegExMatch = id_pattern.search(str(candidate).replace("\\", "/").to_lower())
		if match != null:
			return int(match.get_string(1))
	return 0


func fall_items():
	if _settle_nightmare_soul_drop():
		return
	if _is_tower_drop_context():
		return
	ran_1 = randf_range(0, 1)
	if fall_list.size() > 0 and is_fall == false:
		var available_drops: Array = YutuEquipmentData.expand_drop_entries(fall_list)
		var loc_4 = randi_range(0, available_drops.size() - 1)
		var loc_2 = available_drops[loc_4]["name"]
		var loc_3 = available_drops[loc_4]["value"]
		var effective_fall_pro = Global.get_current_level_fall_pro(float(fall_pro))

		if ran_1 <= effective_fall_pro:
			var level_node = get_level_node()
			Global.fall_item(level_node.fall_it, Vector2(self.position.x, self.position.y - 30), loc_2, loc_3)
			is_fall = true
	var direct_pet_drop_added := false
	for independent_drop in YutuEquipmentData.expand_drop_entries(independent_fall_list):
		var difficulty_index := clampi(int(MainSet.set_data.get("Difficult", 0)), 0, 3)
		var difficulty_multiplier: float = [1.0, 2.0, 3.0, 3.0][difficulty_index]
		var drop_chance := clampf(float(independent_drop.get("chance", 0.0)) * difficulty_multiplier, 0.0, 1.0)
		if RoleProp.source_player != null and RoleProp.source_player.is_double_fall_pro:
			drop_chance = clampf(drop_chance * 2.0, 0.0, 1.0)
		var independent_roll := randf()
		if independent_roll <= drop_chance:
			var minimum_value := int(independent_drop.get("min_value", independent_drop.get("value", 1)))
			var maximum_value := int(independent_drop.get("max_value", minimum_value))
			if maximum_value < minimum_value:
				var swap_value := minimum_value
				minimum_value = maximum_value
				maximum_value = swap_value
			var drop_value := randi_range(minimum_value, maximum_value)
			if bool(independent_drop.get("direct_to_pet_backpack", false)):
				direct_pet_drop_added = (
					_add_direct_pet_backpack_drop(independent_drop, drop_value) or direct_pet_drop_added
				)
				continue
			var independent_level_node = get_level_node()
			if independent_level_node != null:
				var spawn_offset_value: Variant = independent_drop.get("spawn_offset", Vector2.ZERO)
				var spawn_offset := spawn_offset_value as Vector2 if spawn_offset_value is Vector2 else Vector2.ZERO
				Global.fall_item(
					independent_level_node.fall_it,
					Vector2(self.position.x, self.position.y - 30) + spawn_offset,
					String(independent_drop.get("name", "")),
					drop_value
				)
	if direct_pet_drop_added:
		_save_direct_pet_backpack_drop()
	if int(MainSet.set_data.get("Difficult", 0)) == 2:
		var hell_box_fall_pro := 0.2
		if RoleProp.source_player != null and RoleProp.source_player.is_double_fall_pro:
			hell_box_fall_pro *= 2.0
		hell_box_fall_pro = clampf(hell_box_fall_pro, 0.0, 1.0)
		if randf_range(0, 1) <= hell_box_fall_pro:
			var hell_level_node = get_level_node()
			if hell_level_node != null:
				Global.fall_item(hell_level_node.fall_it, Vector2(self.position.x, self.position.y - 30), "qhsbx", 1)


func _add_direct_pet_backpack_drop(drop: Dictionary, amount: int) -> bool:
	if not PlayerData.has_method("add_pet_backpack_item"):
		return false
	var item_id := str(drop.get("name", "")).strip_edges()
	if item_id == "":
		return false
	var data_value: Variant = drop.get("data", {})
	var data_override: Dictionary = data_value if data_value is Dictionary else {}
	return int(PlayerData.call("add_pet_backpack_item", item_id, amount, data_override)) > 0


func _save_direct_pet_backpack_drop() -> void:
	var save_path := str(Global.cd_path)
	if save_path != "" and save_path.contains("Ar_") and FileAccess.file_exists(save_path):
		if not MemoryClass.request_background_save(save_path):
			MemoryClass.save_game(save_path)


func fall_medicine():
	if _settle_nightmare_soul_drop():
		return
	if _is_tower_drop_context():
		return
	ran_2 = randf_range(0, 1)
	if PlayerData.check_eq_zb("头衔", "xczg"):
		ran_2 = 0
	if ran_2 < 0.15 and is_fall_medi == false:
		ran_3 = randf_range(0, 1)
		var rr = ran_3
		if rr < 0.4 and rr > 0:
			var level_node = get_level_node()
			Global.fall_item(level_node.fall_it, Vector2(self.position.x, self.position.y - 30), "radish", 0)
		elif rr < 0.8 and rr >= 0.4:
			var level_node = get_level_node()
			Global.fall_item(level_node.fall_it, Vector2(self.position.x, self.position.y - 30), "Bble", 0)
		else:
			var level_node = get_level_node()
			Global.fall_item(level_node.fall_it, Vector2(self.position.x, self.position.y - 30), "peach", 0)
		is_fall_medi = true


func _spawn_fall_stone():
	if _settle_nightmare_soul_drop():
		return
	if _is_tower_drop_context():
		return
	ran_4 = randf_range(0, 1)
	if PlayerData.check_eq_zb("头衔", "xczg"):
		fall_stone_pro = 100
	if fall_stone.size() > 0:
		var loc_1 = randi_range(0, fall_stone.size() - 1)
		var loc_2 = fall_stone[loc_1]["name"]
		var loc_3 = fall_stone[loc_1]["value"]
		if ran_4 <= float(fall_stone_pro):
			var level_node = get_level_node()
			Global.fall_item(level_node.fall_it, Vector2(self.position.x, self.position.y - 30), loc_2, loc_3)

	pass


func death():
	return hp <= 0


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if death() or is_death or is_spawn_damage_protected():
		return
	if is_boss and boss_protect_active:
		return
	if _is_summon_or_pet_hit_area(area):
		return

	var source_player: BaseHero = _get_damage_source_player(area)
	if source_player == null or not is_instance_valid(source_player):
		return
	var source_target: Variant
	if area is BaseRoleHitBox or area is RolehmzBullet:
		source_target = source_player
	elif area is MagicWeaponHit:
		source_target = area.get_parent()
	elif area.get_parent() is Role1Shallow:
		source_target = area.get_parent()
	elif area is RoleBullet1:
		source_target = area
	elif area.get_parent().get_parent() is RoleBullet:
		source_target = area.get_parent().get_parent()
	else:
		return
	apply_role_hit(source_target, source_player)


func apply_role_hit(source_target: Variant, source_player: BaseHero = null, hit_data: Dictionary = {}) -> int:
	if death() or is_death or is_spawn_damage_protected():
		return 0
	if is_boss and boss_protect_active:
		return 0
	if source_target == null or not is_instance_valid(source_target):
		return 0
	if source_player == null or not is_instance_valid(source_player):
		source_player = _get_damage_source_player(source_target)
	if source_player == null or not is_instance_valid(source_player):
		return 0

	var old_target: Variant = get_target
	var old_player: BaseHero = get_player
	var source_props: BaseRoleProperties = LocalCoop.props_for(source_player)
	var old_source_player: Variant = source_props.source_player
	var old_damage_slot: int = int(get_meta("coop_damage_slot", 0))
	set_meta("coop_damage_slot", LocalCoop.slot_for(source_player))
	var old_tszzs: float = source_player.tszzs
	var old_hit_data: Variant = source_target.get("hit_dic")
	if not hit_data.is_empty():
		source_target.set("hit_dic", hit_data.duplicate(true))

	get_target = source_target
	get_player = source_player
	source_props.source_player = source_player
	has_target = true
	Global.total_hit_count += 1
	if source_player.istsz:
		var tsz_level := int(PlayerData.player_data["腾蛇阵"]["Level"])
		source_player.tszzs = tsz_level * 0.015
	else:
		source_player.tszzs = 0.0

	var last_hurt := int(
		(
			float(get_role_last_hurt(source_target))
			* RoleProp.ws_up_power
			* jgz_bl
			* zznh_bl
			* hurt_bl
			* (1.0 + lpzzs)
			* (1.0 + source_player.tszzs)
			* llrdzs
		)
	)
	last_hurt = int(hurt_reduce_hp(last_hurt, source_target))
	hurt_received = last_hurt
	if source_player.is_dead_link:
		source_player.effect_reducehp(last_hurt, "real")
	cure_ws_value(source_player)
	add_lj(last_hurt)
	Global.total_role_hit += last_hurt
	role5_bullet(last_hurt, source_target)
	var attack_data: Variant = source_target.get("hit_dic")
	if attack_data is Dictionary:
		match str(attack_data.get("attackKind", "")):
			"physics":
				Global.total_phy_hit += last_hurt
			"magic":
				Global.total_mag_hit += last_hurt
			"real":
				Global.total_real_hit += last_hurt
	if last_hurt > 0 and not death() and not is_death:
		if MainSet.set_data["MonsterLittleBlood"]:
			if monster_blood_bar == null:
				monster_blood_bar = Global.add_monster_blood(self, Vector2(-30, -90), hp / float(max_hp), hp)
		if PlayerData.player_data["Myself"] != 2:
			Global.add_sound(self, "res://Music/monster_hurt/6_beattack_by_role1.mp3")
		else:
			Global.add_sound(self, "res://Music/hero/9_beattack_by_role2.mp3")
		if not monster_18_protect() and not monster102_protect() and not is_control_immune():
			_interrupt_attack_state_on_hit()
			state_hurt()
		hurt_special_effect = Global.add_mr_hurt(pz, Vector2(0, 0))

	get_target = old_target
	get_player = old_player
	source_player.tszzs = old_tszzs
	source_props.source_player = old_source_player
	if old_damage_slot == 0:
		remove_meta("coop_damage_slot")
	else:
		set_meta("coop_damage_slot", old_damage_slot)
	if not hit_data.is_empty():
		source_target.set("hit_dic", old_hit_data)
	return last_hurt


func bind_role_damage_source(source_player: BaseHero) -> Dictionary:
	"""把怪物的伤害/无双归属临时绑定到实际出手玩家，返回可恢复的上下文。"""
	if not is_instance_valid(source_player):
		return {}
	var source_props: BaseRoleProperties = LocalCoop.props_for(source_player)
	if not is_instance_valid(source_props):
		return {}
	var previous := {
		"player": get_player,
		"damage_slot": int(get_meta("coop_damage_slot", 0)),
		"props": source_props,
		"props_source": source_props.source_player,
	}
	get_player = source_player
	set_meta("coop_damage_slot", LocalCoop.slot_for(source_player))
	source_props.source_player = source_player
	return previous


func unbind_role_damage_source(previous: Dictionary) -> void:
	if previous.is_empty():
		return
	get_player = previous.get("player") as BaseHero
	var damage_slot := int(previous.get("damage_slot", 0))
	if damage_slot == 0:
		remove_meta("coop_damage_slot")
	else:
		set_meta("coop_damage_slot", damage_slot)
	var source_props: BaseRoleProperties = previous.get("props") as BaseRoleProperties
	if is_instance_valid(source_props):
		source_props.source_player = previous.get("props_source")


func _is_summon_or_pet_hit_area(area: Area2D) -> bool:
	if area == null or not is_instance_valid(area):
		return false
	var parent := area.get_parent()
	var owner := parent.get_parent() if parent != null else null
	if owner == null or not is_instance_valid(owner):
		return false
	if owner.get_meta("pet_tiger_unit", false) or owner.get_meta("is_summon", false):
		return true
	if owner.get_meta("is_summon_bullet", false) or owner.get_meta("pet_tiger_summon", false):
		return true
	if owner.has_method("get") and owner.get("is_summon") == true:
		return true
	return false


func role5_bullet(last_hurt, source_target = null):
	var passive_source = source_target if source_target != null else get_target
	if passive_source == null:
		return
	if passive_source is RoleBullet:
		if passive_source._name == "Role5Bullet6":
			return
	if passive_source is MgHit:
		return
	var s_level = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能10"][DataKeys.LEVEL]
	if s_level <= 0:
		return
	if get_player == null or last_hurt <= 0:
		return
	if not get_player is Role5Hero:
		return
	randomize()
	if randi_range(0, 100) > 15:
		return
	var hurt_value = int(last_hurt * 0.3 + (s_level * 0.02))
	Global.add_role_bullet(
		get_player.bullet,
		Vector2(position.x, position.y + 30),
		false,
		"Role5Bullet6",
		{"power": hurt_value, "hurtBack": [0, 0], "attackKind": "real", "WSValue": 5}
	)
	var bl = 1 + (s_level * 0.2)
	get_player.cure_hp(hurt_value * bl)


func _get_damage_source_player(target) -> BaseHero:
	if target is BaseHero:
		return target as BaseHero
	if target is RoleBullet or target is RoleBullet1 or target is Role1Shallow:
		for key: String in ["player", "Player", "my_owner"]:
			var bullet_player: Variant = target.get(key)
			if bullet_player is BaseHero and is_instance_valid(bullet_player):
				return bullet_player as BaseHero
		var parent_node: Node = target as Node
		for _index in range(4):
			if parent_node == null:
				break
			if parent_node is BaseHero:
				return parent_node as BaseHero
			parent_node = parent_node.get_parent()
	if target is BaseMagicWeapon:
		for key: String in ["player", "Player"]:
			var weapon_player: Variant = target.get(key)
			if weapon_player is BaseHero and is_instance_valid(weapon_player):
				return weapon_player as BaseHero
	if target is MagicWeaponHit:
		var weapon: Variant = target.get_parent()
		if weapon is BaseMagicWeapon:
			for key: String in ["player", "Player"]:
				var weapon_player: Variant = weapon.get(key)
				if weapon_player is BaseHero and is_instance_valid(weapon_player):
					return weapon_player as BaseHero
	if target is MgHit:
		var source_weapon: Variant = target.get("source_weapon")
		if source_weapon is BaseMagicWeapon:
			for key: String in ["player", "Player"]:
				var source_player: Variant = source_weapon.get(key)
				if source_player is BaseHero and is_instance_valid(source_player):
					return source_player as BaseHero
	var resolved: BaseHero = LocalCoop.owner_hero(target) if target is Node else null
	if resolved != null:
		return resolved
	var current_player: Variant = RoleProp.source_player
	if current_player is BaseHero and is_instance_valid(current_player):
		return current_player as BaseHero
	return null


func _apply_damage_vampirism(target, effective_damage: int) -> void:
	if effective_damage <= 0 or target == null:
		return
	var attack_data_value: Variant = target.get("hit_dic")
	if not attack_data_value is Dictionary:
		return
	var attack_data: Dictionary = attack_data_value
	var attack_kind := str(attack_data.get("attackKind", ""))
	if attack_kind not in ["physics", "magic", "real"]:
		return
	var source_player := _get_damage_source_player(target)
	if source_player == null or not is_instance_valid(source_player):
		return
	var vampirism_rate := maxf(0.0, float(RoleProp.roleprop.get("vampirism", 0.0)))
	if vampirism_rate <= 0.0:
		return
	var heal_value := maxi(1, int(float(effective_damage) * vampirism_rate))
	source_player.cure_hp(heal_value)


func get_role_last_hurt(target):
	is_crit = false
	is_miss = false
	var hurt = 0
	var miss = 0
	var crit = 0
	var last_def = 0
	var last_mdef = 0
	var cur_level: int = 0
	var lucky = 0
	var hurt_lx: String = "real"
	if (
		target is BaseHero
		or target is BaseMagicWeapon
		or target is RoleBullet1
		or target is RoleBullet
		or target is MgHit
		or target is Role1Shallow
	):
		miss = miss - RoleProp.roleprop.htarget
		crit = RoleProp.roleprop.Crit - crit_reduce
		last_def = def - RoleProp.roleprop.ar - _yutu_moon_defense_reduction()
		last_mdef = mdef - RoleProp.roleprop.sp
		cur_level = RoleProp.baseroleprop.Level
		lucky = RoleProp.roleprop.Lucky - toughness
	elif target is BaseBuff:
		miss = miss - RoleProp.roleprop.htarget
		crit = RoleProp.roleprop.Crit - crit_reduce
		last_def = def - RoleProp.roleprop.ar - _yutu_moon_defense_reduction()
		last_mdef = mdef - RoleProp.roleprop.sp
		cur_level = RoleProp.baseroleprop.Level
		lucky = RoleProp.roleprop.Lucky - toughness
	else:
		return 0

	if not target is BaseBuff:
		hurt = target.hit_dic["power"]
		hurt_lx = target.hit_dic["attackKind"]
	else:
		hurt = target.last_value
		hurt_lx = str(target.buff_info.get("AttackKind", ""))
	var source_player := RoleProp.source_player as BaseHero
	if source_player != null and is_instance_valid(source_player):
		var monster149_buff_until := int(source_player.get_meta("monster149_buff_until", 0))
		if monster149_buff_until > 0:
			if Time.get_ticks_msec() < monster149_buff_until:
				hurt = int(float(hurt) / 2.0)
			else:
				source_player.remove_meta("monster149_buff_until")
	if RoleProp.source_player.is_xr:
		hurt *= RoleProp.source_player.xrbl
	if miss <= 0:
		miss = 0
	else:
		var miss_bl = abs(level - cur_level) * 0.04
		if miss_bl >= 0.9:
			miss_bl = 0.9
		if level_suppression(cur_level):
			miss = miss * (1 + miss_bl)
		else:
			miss = miss * (1 - miss_bl)
	if crit <= 0:
		crit = 0
	else:
		var crit_bl = abs(level - cur_level) * 0.11
		if crit_bl >= 1:
			crit_bl = 1
		if level_suppression(cur_level):
			crit = crit * (1 - crit_bl)
		else:
			crit = crit * (1 + crit_bl)
	if last_def <= 0:
		last_def = 0
	if last_mdef <= 0:
		last_mdef = 0
	if is_defe_reduce:
		var defense_reduction := get_effective_defense_reduction()
		last_def *= 1.0 - defense_reduction
		last_mdef *= 1.0 - defense_reduction
	if lucky <= 0:
		lucky = 0
	else:
		var lucky_bl = abs(level - cur_level) * 0.07
		if lucky_bl >= 0.7:
			lucky_bl = 0.7
		if level_suppression(cur_level):
			lucky = lucky * (1 - lucky_bl)
		else:
			lucky = lucky * (1 + lucky_bl)
	var bl
	if level_suppression(cur_level):
		hurt = int(hurt * (1 - is_suppression_num(cur_level) * 0.05))
	else:
		hurt = int(hurt * (1 + not_suppression_num(cur_level) * 0.05))
	crit = snapped(crit / float(crit + 100), 0.001)
	miss = snapped(miss / float(miss + 70), 0.001)
	randomize()
	if randf_range(0, 1) <= miss:
		is_miss = true
		return 0
	if randf_range(0, 1) <= crit:
		bl = 2 + snapped(lucky / float(lucky + 100), 0.001) + tqzbs
		hurt = hurt * bl
		Global.total_crit_count += 1
		is_crit = true

	match hurt_lx:
		"physics":
			var damage_reduction_rate = snapped(last_def / float(last_def + 100), 0.001)
			hurt = int(hurt * (1 - damage_reduction_rate))
		"magic":
			var damage_reduction_rate = snapped(last_mdef / float(last_mdef + 100), 0.001)
			hurt = int(hurt * (1 - damage_reduction_rate))
	if is_indestructible:
		if hurt >= hp:
			return 0
	return hurt


func _apply_role_damage_vs_reduction(value: int) -> int:
	if value <= 0:
		return value
	var bonus := maxf(0.0, float(RoleProp.roleprop.get("damage_bonus", 0.0)))
	var reduction := maxf(0.0, damage_reduction)
	return int(float(value) * maxf(0.0, 1.0 + bonus - reduction))


func reduce_hp(value: int):
	if is_spawn_damage_protected():
		return 0
	if Global.is_hidden_feature_enabled(Global.HIDDEN_FEATURE_INSTANT_KILL) and value > 0:
		value = maxi(value, hp)
	if monster_18_protect():
		cure_hp(value * 1)
		return 0
	if monster102_protect():
		cure_hp(value)
		return 0
	if is_indestructible:
		if value >= hp:
			return 0
	var last_value = hd_reduce(value)
	hp -= last_value
	if not bool(get_meta("mds_awaken_skip_combo", false)):
		total_hurt += last_value
	Global.total_role_hit += last_value
	Global.total_real_hit += last_value
	var level_node = get_level_node()
	var po = Vector2(self.position.x - 20, self.position.y - 240)
	if last_value > 0:
		Global.add_damage_text(level_node, po, last_value, "real", false, self)
	is_crit = false
	is_miss = false


func reduce_pet_hp(value: int, attack_kind: String) -> int:
	if is_spawn_damage_protected():
		return 0
	if Global.is_hidden_feature_enabled(Global.HIDDEN_FEATURE_INSTANT_KILL) and value > 0:
		value = maxi(value, hp)
	if monster_18_protect():
		cure_hp(value)
		return 0
	if monster102_protect():
		cure_hp(value)
		return 0
	if is_indestructible and value >= hp:
		return 0
	var damage_kind := attack_kind if attack_kind in ["physics", "magic"] else "real"
	var last_value := int(hd_reduce(value))
	hp -= last_value
	total_hurt += last_value
	Global.total_role_hit += last_value
	match damage_kind:
		"physics":
			Global.total_phy_hit += last_value
		"magic":
			Global.total_mag_hit += last_value
		_:
			Global.total_real_hit += last_value
	if last_value > 0:
		var level_node := get_level_node()
		if level_node != null:
			var text_position := Vector2(position.x - 20, position.y - 240)
			Global.add_damage_text(level_node, text_position, last_value, damage_kind, is_crit, self)
	is_crit = false
	is_miss = false
	return last_value


func _yutu_moon_defense_reduction() -> float:
	if int(get_meta("yutu_moon_until", 0)) > Time.get_ticks_msec():
		return maxf(0.0, float(get_meta("yutu_moon_defense", 0.0)))
	return 0.0


func get_effective_defense_reduction() -> float:
	return clampf(maxf(defe_reduce, zznh_defense_reduction), 0.0, 1.0)


func resolve_friendly_damage(base_damage: int, attack_kind: String, attacker: Node = null) -> int:
	is_crit = false
	is_miss = false
	if base_damage <= 0:
		return 0
	var damage_source := attacker
	if damage_source != null and is_instance_valid(damage_source) and damage_source.has_meta("summoner"):
		var summon_owner: Variant = damage_source.get_meta("summoner", null)
		if summon_owner is Node and is_instance_valid(summon_owner):
			damage_source = summon_owner
	if (
		damage_source != null
		and is_instance_valid(damage_source)
		and damage_source.has_method("get_gxp_damage_multiplier")
	):
		var gxp_multiplier := maxf(1.0, float(damage_source.call("get_gxp_damage_multiplier")))
		base_damage = maxi(1, int(round(float(base_damage) * gxp_multiplier)))
	var owner_hit := (
		int(attacker.get("htarget"))
		if attacker != null and is_instance_valid(attacker) and "htarget" in attacker
		else 0
	)
	var target_miss := maxi(0, int(miss) - owner_hit)
	var miss_chance := float(target_miss) / float(target_miss + 70) if target_miss > 0 else 0.0
	if miss_chance > 0.0 and randf() < miss_chance:
		is_miss = true
		return 0
	var owner_crit := (
		int(attacker.get("crit")) if attacker != null and is_instance_valid(attacker) and "crit" in attacker else 0
	)
	var effective_crit := maxi(0, owner_crit - int(crit_reduce))
	var crit_chance := float(effective_crit) / (float(effective_crit) + 100.0) if effective_crit > 0 else 0.0
	var resolved_damage := base_damage
	if crit_chance > 0.0 and randf() < crit_chance:
		var owner_lucky := (
			int(attacker.get("lucky"))
			if attacker != null and is_instance_valid(attacker) and "lucky" in attacker
			else 0
		)
		var effective_lucky := maxi(0, owner_lucky - int(toughness))
		var crit_multiplier := (
			2.0 + float(effective_lucky) / (float(effective_lucky) + 100.0) if effective_lucky > 0 else 2.0
		)
		resolved_damage = int(float(base_damage) * crit_multiplier)
		is_crit = true
		Global.total_crit_count += 1
	if attack_kind in ["physics", "magic"]:
		var penetration_name := "ar" if attack_kind == "physics" else "sp"
		var penetration := (
			int(attacker.get(penetration_name))
			if attacker != null and is_instance_valid(attacker) and penetration_name in attacker
			else 0
		)
		var defense := int(def) if attack_kind == "physics" else int(mdef)
		defense = maxi(0, defense - penetration)
		if is_defe_reduce:
			defense = maxi(0, int(float(defense) * (1.0 - get_effective_defense_reduction())))
		var reduction: float = float(snapped(float(defense) / float(defense + 100), 0.001))
		resolved_damage = maxi(1, int(float(resolved_damage) * (1.0 - reduction)))
	resolved_damage = maxi(0, int(float(resolved_damage) * _get_friendly_damage_taken_multiplier()))
	return resolved_damage


func _get_friendly_damage_taken_multiplier() -> float:
	return maxf(0.0, jgz_bl * zznh_bl * hurt_bl * (1.0 + lpzzs) * llrdzs)


func receive_friendly_damage(base_damage: int, attack_kind: String, attacker: Node = null) -> int:
	var resolved_damage := resolve_friendly_damage(base_damage, attack_kind, attacker)
	if resolved_damage <= 0:
		return 0
	return reduce_pet_hp(resolved_damage, attack_kind)


func receive_reflected_damage(base_damage: int, attack_kind: String, penetration: int = 0) -> int:
	if base_damage <= 0:
		return 0
	var damage_kind := attack_kind if attack_kind in ["physics", "magic"] else "real"
	var resolved_damage := base_damage
	if damage_kind in ["physics", "magic"]:
		var defense := int(def) if damage_kind == "physics" else int(mdef)
		defense = maxi(0, defense - maxi(0, penetration))
		if is_defe_reduce:
			defense = maxi(0, int(float(defense) * (1.0 - get_effective_defense_reduction())))
		var reduction: float = float(snapped(float(defense) / float(defense + 100), 0.001))
		resolved_damage = maxi(1, int(float(resolved_damage) * (1.0 - reduction)))
	resolved_damage = maxi(0, int(float(resolved_damage) * _get_friendly_damage_taken_multiplier()))
	if resolved_damage <= 0:
		return 0
	return reduce_pet_hp(resolved_damage, damage_kind)


func hurt_reduce_hp(value, target):
	if death() or is_death or is_spawn_damage_protected():
		return 0
	var skip_mds_combo: bool = (
		value > 0
		and target is BaseBuff
		and str(target.buff_info.get("Name", "")) == "Voodoo"
		and _is_mds_awaken_active()
	)
	if Global.is_hidden_feature_enabled(Global.HIDDEN_FEATURE_INSTANT_KILL) and value > 0:
		value = maxi(int(value), hp)
	if monster_18_protect():
		cure_hp(value * 1)
		return 0
	if monster102_protect():
		cure_hp(value)
		return 0
	if is_indestructible:
		if value >= hp:
			return 0
	if skip_mds_combo:
		set_meta("mds_awaken_skip_combo", true)
	var last_value = hd_reduce(value)
	if skip_mds_combo:
		remove_meta("mds_awaken_skip_combo")
	hp -= last_value
	if not skip_mds_combo:
		total_hurt += last_value
	_apply_damage_vampirism(target, int(last_value))
	if last_value > 0:
		add_hurt_text(last_value, target)
	else:
		if is_miss:
			add_hurt_text(last_value, target)
	is_crit = false
	is_miss = false
	_notify_yutu_damage_dealt(int(last_value), target)
	return int(last_value)


func _notify_yutu_damage_dealt(value: int, target: Node) -> void:
	if value <= 0:
		return
	var source_player := _get_damage_source_player(target)
	if source_player != null and source_player.has_method("on_yutu_damage_dealt"):
		source_player.on_yutu_damage_dealt(self, target)


func add_hurt_text(value, target):
	if value <= 0 and not is_miss:
		return
	if target == null:
		return
	if target is Object and target.has_meta("sword_array_damage") and target.get_meta("sword_array_damage"):
		if not Global.can_show_sword_damage_text():
			return
	if (
		target is BaseHero
		or target is BaseMagicWeapon
		or target is RoleBullet1
		or target is RoleBullet
		or target is MgHit
		or target is Role1Shallow
	):
		var hurt_lx = target.hit_dic["attackKind"]
		if is_miss:
			var level_node = get_level_node()
			var po = Vector2(self.position.x - 20, self.position.y - 240)
			Global.add_miss_effect(level_node, po)
		else:
			var level_node = get_level_node()
			var po = Vector2(self.position.x - 20, self.position.y - 240)
			Global.add_damage_text(level_node, po, value, hurt_lx, is_crit, self)
	elif target is BaseBuff:
		var hurt_lx = str(target.buff_info.get("AttackKind", ""))
		var level_node = get_level_node()
		var po = Vector2(self.position.x - 20, self.position.y - 240)
		Global.add_damage_text(level_node, po, value, hurt_lx, is_crit, self)


func hd_reduce(value):
	value = _apply_role_damage_vs_reduction(int(value))
	if is_boss:
		if boss_protect_active:
			return 0
		if value > 0 and not bool(get_meta("mds_awaken_skip_combo", false)):
			_add_boss_protect_from_hit(null)
	var last_value
	if hd <= 0 or ws_hd:
		last_value = value
		return value
	if value >= hd:
		last_value = value - hd
	else:
		last_value = 0
	hd -= value
	return last_value


func cure_hp(value: int):
	if hp <= 0:
		return
	if is_blood_fix:
		return
	if life_mana_lock:
		return
	value = value * (1 + therapeutic_effects)
	if value + hp >= max_hp:
		value = max_hp - hp
	if value > 0:
		hp += value
		var level_node = get_level_node()
		var po = Vector2(self.position.x - 20, self.position.y - 240)
		Global.add_damage_text(level_node, po, value, "cure", false, self)


func remove_cd():
	if skill_1_cd >= 0:
		skill_1_cd -= 1
	if skill_2_cd >= 0:
		skill_2_cd -= 1
	if skill_3_cd >= 0:
		skill_3_cd -= 1
	if skill_4_cd >= 0:
		skill_4_cd -= 1
	if skill_5_cd >= 0:
		skill_5_cd -= 1
	if skill_6_cd >= 0:
		skill_6_cd -= 1
	if skill_7_cd >= 0:
		skill_7_cd -= 1
	if skill_8_cd >= 0:
		skill_8_cd -= 1


func _on_cd_remove_timeout() -> void:
	remove_cd()


func level_suppression(Level):
	return level - Level > 0


func is_suppression_num(Level):
	var num: int
	if level - Level > 2:
		num = 2
	else:
		num = level - Level
	return num


func not_suppression_num(Level):
	var num: int
	if Level - level > 2:
		num = 2
	else:
		num = Level - level
	return num


func _on_change_state_timeout() -> void:
	ran_num = randi_range(0, 100)


func do_hit_1():
	pass


func do_hit_2():
	pass


func do_hit_2_2():
	pass


func do_hit_3():
	pass


func do_hit_3_2():
	pass


func do_hit_4():
	pass


func do_hit_5():
	pass


func do_hit_6():
	pass


func _set_sprite_position(x: int, y: int):
	if mr_ani.flip_h == false:
		mr_ani.position.x = -x
	elif mr_ani.flip_h == true:
		mr_ani.position.x = x
	mr_ani.position.y = y


func cannotchangestatewhenattorbeatt():
	return is_attacking or is_be_attacking or _hurt_reaction_active


func _interrupt_attack_state_on_hit() -> void:
	if is_control_immune():
		return
	_cancel_hurt_reaction()
	is_attacking = false
	is_using_skills = false
	if "_skill_busy" in self:
		set("_skill_busy", false)
	if "is_special_combo" in self:
		set("is_special_combo", false)
	if not has_meta("pet_summon_knockback_token") and not has_meta("pet_tiger_sxhz_hold_until"):
		is_be_attacking = false


func check_hp():
	if hp >= max_hp:
		hp = max_hp
	if hp <= 0:
		hp = 0


func _on_spontaneous_recovery_timeout() -> void:
	if hp < max_hp and not death():
		cure_hp(self_rhp)


func get_hd(value: int, hit_bl: float, hurt_bl: float):
	var hd_1 = int(total_hit * hit_bl)
	var hd_2 = int(total_hurt * hurt_bl)
	var total_hd: int = hd_1 + hd_2 + value
	set_hd(total_hd, total_hd)
	total_hit = 0
	total_hurt = 0


func remove_hd():
	hd = 0
	max_hd = 0


func _on_hit_box_area_entered(area: Area2D) -> Node2D:
	is_enter_hit_box = true
	var buff_target: Node2D = null
	var rro = area.get_parent().get_parent()

	if self is Monster20:
		var abc: Monster20 = self
		if abc.low_hp():
			cure_hp(int((max_hp - hp) * 0.07))

	if rro == null:
		return buff_target

	var buff_node = null
	var methods_to_try = [
		func(): return rro.get_node("Buff") if rro.has_node("Buff") else null,
		func(): return rro.get("Buff") if rro.has("Buff") else null,
		func(): return rro.get_buff_node() if rro.has_method("get_buff_node") else null
	]

	for method in methods_to_try:
		buff_node = method.call()
		if buff_node != null:
			buff_target = rro
			break

	if obj_attack_dict != null and hit_name != null:
		if obj_attack_dict[hit_name].has("addeffect"):
			var addeffect = obj_attack_dict[hit_name]["addeffect"]
			if addeffect.size() != 0:
				if buff_node != null:
					var probability = 1.0
					if addeffect.has("probability"):
						probability = addeffect["probability"]

					if randf() <= probability:
						Global.add_buff(buff_node, addeffect)

	return buff_target


func add_lj(value):
	if value <= 0:
		return
	Global.lj_times += 1
	Global.check_combo_milestone(Global.lj_times)
	if Global.lj_times >= Global.most_lianji:
		Global.most_lianji = Global.lj_times
	var level_node = get_level_node()
	Global.add_combo(level_node.lj_tt, Global.lj_times, Vector2(0, 0))
	Global.lj_count = 0


func monster_18_protect():
	if self is Monster18:
		if self.monster_direction == Global.player_dir:
			if self.monster_direction == false:
				Global.add_special_effect(self, Vector2(0, 5), "protect", Vector2(1.1, 1.1), false, 1)
			else:
				Global.add_special_effect(self, Vector2(0, 5), "protect", Vector2(1.1, 1.1), false, 1)
			return true
	return false


func _on_hit_box_area_exited(_area: Area2D) -> void:
	if self is Monster43:
		if skill_1_cd > 0:
			skill_1_cd -= 3
		if hit_name == "csjq":
			cure_hp(self.obj_attack_dict["csjq"]["power"] * 25 + int((max_hp - hp) * 0.07))
			self.skill_3_cd = 0


func rush():
	if _movement_command_is_blocked():
		if not _hurt_reaction_active:
			velocity.x = 0
		return
	velocity.x = 0
	if self.monster_direction:
		velocity.x += rush_speed
	else:
		velocity.x -= rush_speed


func gg_pl():
	if get_player == null:
		var top = get_parent().get_parent()
		var role_jd = top.get_node("Hero")
		var _role = role_jd.get_children()
		for i in _role:
			if i is BaseHero:
				get_player = i


func move_player_to_boss(movetime):
	var tween = create_tween()
	tween.tween_property(get_player, "position", self.position, movetime)


func move_playerto_boss(target: Node2D, movetime: float):
	var final_target: Node2D = null

	if target != null and is_instance_valid(target) and target is Node2D:
		final_target = target

	elif get_player != null and is_instance_valid(get_player) and get_player is Node2D:
		final_target = get_player

	if final_target == null:
		print("无有效移动目标（无buff_target且玩家节点无效），跳过位移")
		return

	var tween = create_tween()

	var target_pos = Vector2(self.position)
	tween.tween_property(final_target, "position", target_pos, movetime)


func cure_ws_value(source_player: BaseHero = null) -> void:
	var ws_props: BaseRoleProperties = (
		LocalCoop.props_for(source_player) if is_instance_valid(source_player) else RoleProp
	)
	if not is_instance_valid(ws_props) or ws_props.is_ws_state:
		return
	var gain := 2
	if get_target != null and is_instance_valid(get_target):
		var hit_data: Variant = get_target.get("hit_dic")
		if hit_data is Dictionary and (hit_data as Dictionary).has("WSValue"):
			gain = int((hit_data as Dictionary)["WSValue"])
	ws_props.ws_value += gain


func shake(strength, times, interv):
	var baselevel = get_parent().get_parent() as BaseLevel
	baselevel._shake_screen(strength, times, interv)


func add_ws_effect(Object_):
	var level_node = get_level_node()
	spawn_ws_effect(Object_, level_node)


func check_add_buff():
	var not_jgz = true
	var not_zznh = true
	var not_ice = true
	var not_dl = true
	var not_eyefix = true
	var not_stun = true
	var not_sppeddown = true
	var not_silent = true
	var not_bound_floor = true
	var not_immobilize = true
	var not_is_blood_fix = true
	var not_life_mana_lock = true
	var not_defe_reduce = true
	var not_scary = true
	var not_super_armor = true
	var not_indestructible = true
	var not_lpz = true
	var not_lljy = true
	var not_no_de_buff = true
	if self.buff == null:
		return

	var buff_child_count := self.buff.get_child_count()
	var buff_child_index := 0
	while buff_child_index < buff_child_count:
		var i = self.buff.get_child(buff_child_index)
		buff_child_index += 1
		if i != null:
			var buff_info: Dictionary = i.buff_info
			match str(buff_info["Name"]):
				"zznh":
					is_zznh = true
					not_zznh = false
					var skill_level = buff_info.get("value", 1)
					zznh_bl = 1.1 + (skill_level - 1) * 0.1
					zznh_defense_reduction = float(buff_info.get("defense_reduction", 0.0))
					if zznh_defense_reduction > 0.0:
						is_defe_reduce = true
						not_defe_reduce = false
				"jgz":
					is_jgz = true
					not_jgz = false
					var skill_level = buff_info.get("value", 1)
					jgz_bl = 1.2 + (skill_level - 1) * 0.1
				"lljybuff":
					islljy = true
					not_lljy = false
				"no_debuff":
					no_debuff = true
					not_no_de_buff = false
				"lpzbuff":
					is_lpz = true
					not_lpz = false
				"Ice":
					is_ice = true
					not_ice = false
				"Indestructible":
					is_indestructible = true
					not_indestructible = false
				"defe_reduce":
					is_defe_reduce = true
					defe_reduce = float(buff_info.get("value", i.last_value))
					not_defe_reduce = false
				"SuperArmor":
					super_armor_active = true
					not_super_armor = false
				"DeadLink":
					is_dead_link = true
					not_dl = false
				"EyeFix":
					is_eye_fix = true
					not_eyefix = false
				"Immobilize":
					is_immobilize = true
					not_immobilize = false
				"stun":
					is_stun = true
					not_stun = false
				"speed_down":
					is_speed_down = true
					not_sppeddown = false
				"blood_fix":
					is_blood_fix = true
					not_is_blood_fix = false
				"life_mana_lock":
					life_mana_lock = true
					not_life_mana_lock = false
				"Scary":
					is_scary = true
					not_scary = false

	if not_zznh:
		is_zznh = false
		zznh_bl = 1.0
		zznh_defense_reduction = 0.0

	if not_jgz:
		is_jgz = false
		jgz_bl = 1
	if not_no_de_buff:
		no_debuff = false
	if not_lljy:
		islljy = false
	if not_lpz:
		is_lpz = false
		lpzjs = 0
	if not_indestructible:
		is_indestructible = false
	if not_defe_reduce:
		defe_reduce = 0
		is_defe_reduce = false
	if not_super_armor:
		super_armor_active = false
	if not_scary:
		is_scary = false
	if not_is_blood_fix:
		is_blood_fix = false
	if not_life_mana_lock:
		life_mana_lock = false
	if not_immobilize:
		is_immobilize = false
	if not_ice:
		is_ice = false
	if not_dl:
		is_dead_link = false
	if not_eyefix:
		is_eye_fix = false
	if not_stun:
		is_stun = false
	if not_sppeddown:
		is_speed_down = false
		speed = init_speed
	if buff_child_count == 0:
		is_speed_down = false
		speed = init_speed
		is_stun = false
		is_eye_fix = false
		is_ice = false
		is_dead_link = false

	if is_movement_locked_by_control():
		interrupt_movement_for_control()
	else:
		_release_control_movement_lock()


func get_health_without_coop() -> int:
	return int(max_hp / 2) if _coop_health_scaled else max_hp


func set_health_without_coop(max_health: int) -> void:
	max_hp = max_health
	hp = max_health
	_coop_health_scaled = false
	if is_node_ready():
		_apply_coop_health_scaling()


func _apply_coop_health_scaling() -> void:
	if _coop_health_scaled or not LocalCoop.is_enabled():
		return
	max_hp *= 2
	hp *= 2
	_coop_health_scaled = true


func get_coop_attack_power(value: int) -> int:
	return int(float(value) * 1.3) if LocalCoop.is_enabled() else value


func change_hd_cure_hp(zhl):
	cure_hp(int(hd * zhl))
	remove_hd()
	pass


func difficult():
	var mult := 1.0
	var difficulty := int(MainSet.set_data.get("Difficult", 0))
	if difficulty == 1:
		mult = 2.0
	elif difficulty == 2 or difficulty == NIGHTMARE_DIFFICULTY:
		mult = 3.0
	else:
		return

	var underworld_nightmare := false
	var heaven_nightmare := false
	var attack_bonus := NIGHTMARE_ATTACK_BONUS
	if difficulty == NIGHTMARE_DIFFICULTY:
		var level_node := get_level_node()
		if level_node != null:
			var level_path := str(level_node.scene_file_path)
			underworld_nightmare = is_underworld_nightmare_path(level_path)
			heaven_nightmare = uses_heaven_nightmare_attributes(level_path)
		attack_bonus = (
			HEAVEN_NIGHTMARE_ATTACK_BONUS
			if heaven_nightmare
			else UNDERWORLD_NIGHTMARE_ATTACK_BONUS if underworld_nightmare else NIGHTMARE_ATTACK_BONUS
		)

	self.max_hp = int(self.max_hp * mult)
	if difficulty == NIGHTMARE_DIFFICULTY:
		var health_bonus := (
			HEAVEN_NIGHTMARE_HEALTH_BONUS
			if heaven_nightmare
			else UNDERWORLD_NIGHTMARE_HEALTH_BONUS if underworld_nightmare else NIGHTMARE_HEALTH_BONUS
		)
		var defense_bonus := (
			HEAVEN_NIGHTMARE_DEFENSE_BONUS
			if heaven_nightmare
			else UNDERWORLD_NIGHTMARE_DEFENSE_BONUS if underworld_nightmare else NIGHTMARE_DEFENSE_BONUS
		)
		var penetration_bonus := HEAVEN_NIGHTMARE_PENETRATION_BONUS if heaven_nightmare else defense_bonus
		damage_bonus = (
			HEAVEN_NIGHTMARE_DAMAGE_BONUS
			if heaven_nightmare
			else UNDERWORLD_NIGHTMARE_DAMAGE_BONUS if underworld_nightmare else NIGHTMARE_DAMAGE_BONUS
		)
		damage_reduction = (
			HEAVEN_NIGHTMARE_DAMAGE_REDUCTION
			if heaven_nightmare
			else UNDERWORLD_NIGHTMARE_DAMAGE_REDUCTION if underworld_nightmare else NIGHTMARE_DAMAGE_REDUCTION
		)
		self.max_hp += health_bonus
		self.level += NIGHTMARE_LEVEL_BONUS
		self.def = self.def * 3 + defense_bonus
		self.mdef = self.mdef * 3 + defense_bonus
		self.ar = self.ar * 3 + penetration_bonus
		self.sp = self.sp * 3 + penetration_bonus
		self.crit *= 3
		self.miss *= 3
		self.lucky *= 3
		self.htarget = self.htarget * 3 + NIGHTMARE_HIT_BONUS
		self.toughness *= 3.0
		self.crit_reduce *= 3
		self.self_rhp *= 3
	self.hp = self.max_hp
	self.fall_coin = int((0 if self.fall_coin == null else self.fall_coin) * mult)
	self.add_exp = int((0 if self.add_exp == null else self.add_exp) * mult)
	if self.fall_pro > 0:
		self.fall_pro = self.fall_pro * mult

	for attack_name in self.obj_attack_dict:
		if obj_attack_dict[attack_name].has("power"):
			obj_attack_dict[attack_name]["power"] = int(obj_attack_dict[attack_name]["power"] * mult)
			if difficulty == NIGHTMARE_DIFFICULTY:
				obj_attack_dict[attack_name]["power"] += attack_bonus


func movetoplayer():
	if _movement_command_is_blocked():
		return
	self.position = RoleProp.get_nearest_monster_target_position(global_position)


func set_full_hp():
	hp = max_hp


func _on_calm_hit_timeout() -> void:
	rndi_count = randi_range(0, 100)


func _on_remove_hurt_bl_timeout() -> void:
	hurt_bl = 1


func add_monster_death_effect():
	Global.add_special_effect(self, Vector2(0, 0), "monster_death", Vector2(1, 1), false, 1)


func when_scary():
	if ran_num <= 20:
		stop_move()
	elif ran_num > 20 and ran_num <= 60:
		move_left()
	else:
		move_right()
	pass


func monster102_protect():
	if self is Monster102:
		if self.my_child != null:
			return true
	return false


func set_gxp():
	if _is_tower_drop_context():
		return
	if fall_coin > 0:
		var original_coin = fall_coin
		var final_coin = fall_coin
		var mult = 1.0
		var has_zcld = false
		var zcld_level = 0

		if get_player != null and PlayerData.check_eq_zb("法宝", "zcld"):
			has_zcld = true
			zcld_level = get_player.zcld_level
			mult = get_zcld_multiplier()
			final_coin = int(final_coin * mult)

		var level_node = get_level_node()
		var piles = randi_range(1, 4)
		var total_coins = 0

		for i in range(piles):
			var pp = position + Vector2(randi_range(-15, 15), randi_range(-15, 15))

			var rnd = randf()
			var color_type = 0
			if rnd < 0.7:
				color_type = 0
			elif rnd < 0.8:
				color_type = 1
			elif rnd < 0.9:
				color_type = 2
			else:
				color_type = 3

			Global.add_aura(level_node.fall_it, pp, final_coin, color_type)
			total_coins += final_coin

		print("[金币] 怪物: ", my_mr_name, " 堆数: ", piles, " 每堆: ", final_coin, " 总计: ", total_coins)

		fall_coin = 0


func set_exp():
	if add_exp <= 0:
		return
	var exp_value: int = add_exp
	var primary_props: BaseRoleProperties = get_node("/root/RoleProp")
	if primary_props.baseroleprop.Level < int(PlayerData.PLAYER_MAX_LEVEL):
		primary_props.cure_exp(exp_value)
	_cure_active_pet_exp(exp_value, 1)
	if LocalCoop.is_enabled():
		LocalCoop.secondary_props.cure_exp(exp_value)
		_cure_active_pet_exp(exp_value, 2)
	add_exp = 0


func _cure_active_pet_exp(value: int, slot: int = 1) -> void:
	if value <= 0:
		return
	var profile: Node = LocalCoop.data_for_slot(slot)
	var pet: Dictionary = _active_pet_data_for_exp(slot)
	if pet.is_empty():
		return
	var player_level: int = int(profile.get_capped_player_level())
	profile.clamp_pet_level_to_player(pet, player_level)
	_ensure_pet_growth_fields(pet)
	pet["下级经验"] = _pet_next_exp_requirement(int(pet.get(DataKeys.LEVEL, 1)))
	if int(pet.get(DataKeys.LEVEL, 1)) >= player_level:
		pet[DataKeys.EXP] = 0
		return
	pet[DataKeys.EXP] = int(pet.get(DataKeys.EXP, 0)) + value
	var old_pet_level := int(pet.get(DataKeys.LEVEL, 1))
	var old_stage: int = int(pet.get("阶段", 1))
	var level_up_count: int = 0
	var growth := {"hp": 0, "mp": 0, "attack": 0, "defense": 0, "hp_recover": 0, "mp_recover": 0}
	while (
		int(pet.get(DataKeys.LEVEL, 1)) < player_level
		and int(pet.get(DataKeys.EXP, 0)) >= max(1, int(pet.get("下级经验", 100)))
	):
		var next_exp: int = max(1, int(pet.get("下级经验", 100)))
		pet[DataKeys.EXP] = int(pet.get(DataKeys.EXP, 0)) - next_exp
		pet[DataKeys.LEVEL] = int(pet.get(DataKeys.LEVEL, 1)) + 1
		pet["下级经验"] = _pet_next_exp_requirement(int(pet.get(DataKeys.LEVEL, 1)))
		var level_growth := _apply_pet_level_growth(pet)
		_update_pet_tiger_evolution(pet)
		_update_pet_dragon_evolution(pet)
		_update_pet_phoenix_evolution(pet)
		_update_pet_turtle_evolution(pet)
		_update_pet_rabbit_evolution(pet)
		_update_pet_mouse_evolution(pet)
		_update_pet_yin_tiger_evolution(pet)
		for key in growth.keys():
			growth[key] = int(growth[key]) + int(level_growth.get(key, 0))
		level_up_count += 1
	if int(pet.get(DataKeys.LEVEL, 1)) >= player_level:
		pet[DataKeys.EXP] = 0
	if level_up_count > 0:
		if _active_pet_unit_can_restore(slot):
			_restore_pet_to_peak(pet)
		_apply_active_pet_unit_growth(level_up_count, growth, pet, old_stage, old_pet_level, slot)


func _pet_next_exp_requirement(pet_level: int) -> int:
	return max(1, int(ceil(float(_role_level_exp_requirement(pet_level)) * 0.6)))


func _role_level_exp_requirement(level: int) -> int:
	var max_exp_list := [
		140, 160, 180, 200, 220, 300, 400, 500, 600, 700, 800, 900, 1200, 1400, 1600, 2000, 2400, 3000, 4000, 5000
	]
	var safe_level: int = max(1, level)
	if safe_level < 20:
		return int(max_exp_list[safe_level - 1])
	return 5000 + 5000 * (safe_level - 19)


func _ensure_pet_growth_fields(pet: Dictionary) -> void:
	pet["悟性"] = clampi(int(pet.get("悟性", 0)), 0, 25)
	pet["根骨"] = clampi(int(pet.get("根骨", 0)), 0, 25)
	pet["灵力"] = clampi(int(pet.get("灵力", 0)), 0, 25)
	if not pet.has("生命资质"):
		pet["生命资质"] = 1000
	if not pet.has("生命资质上限"):
		pet["生命资质上限"] = 2000
	if not pet.has("魔法资质"):
		pet["魔法资质"] = 1000
	if not pet.has("魔法资质上限"):
		pet["魔法资质上限"] = 2000
	if not pet.has("攻击资质"):
		pet["攻击资质"] = 1000
	if not pet.has("攻击资质上限"):
		pet["攻击资质上限"] = 2000
	if not pet.has("防御资质"):
		pet["防御资质"] = 1000
	if not pet.has("防御资质上限"):
		pet["防御资质上限"] = 2000
	var wisdom_bonus: int = int(pet.get("悟性", 0)) * 100
	for quality_name in ["生命", "魔法", "攻击", "防御"]:
		var maximum_key: String = "%s资质上限" % quality_name
		var base_key: String = "%s资质基础上限" % quality_name
		if not pet.has(base_key):
			pet[base_key] = int(pet.get(maximum_key, 2000))
		pet[maximum_key] = max(0, int(pet.get(base_key, 2000))) + wisdom_bonus
	pet["生命资质"] = clampi(int(pet.get("生命资质", 1000)), 0, int(pet.get("生命资质上限", 2000)))
	pet["魔法资质"] = clampi(int(pet.get("魔法资质", 1000)), 0, int(pet.get("魔法资质上限", 2000)))
	pet["攻击资质"] = clampi(int(pet.get("攻击资质", 1000)), 0, int(pet.get("攻击资质上限", 2000)))
	pet["防御资质"] = clampi(int(pet.get("防御资质", 1000)), 0, int(pet.get("防御资质上限", 2000)))


func _apply_pet_level_growth(pet: Dictionary) -> Dictionary:
	return _recalculate_pet_growth_stats(pet, true)


func _recalculate_pet_growth_stats(pet: Dictionary, restore_peak: bool = false) -> Dictionary:
	_ensure_pet_growth_fields(pet)
	var old_hp_max: int = int(pet.get("生命上限", 620))
	var old_mp_max: int = int(pet.get("魔法上限", 180))
	var old_attack: int = int(pet.get(DataKeys.ATTACK, 65))
	var old_defense: int = int(pet.get(DataKeys.DEFENSE, 60))
	var level_count: int = max(0, int(pet.get(DataKeys.LEVEL, 1)) - 1)
	var hp_gain: int = int(round(float(pet.get("生命资质", 1000)) * 0.09))
	var mp_gain: int = int(round(float(pet.get("魔法资质", 1000)) * 0.04))
	var attack_gain: int = int(round(float(pet.get("攻击资质", 1000)) * 0.02))
	var defense_gain: int = int(round(float(pet.get("防御资质", 1000)) * 0.007))
	var hp_recover_gain: int = int(round(float(pet.get("生命资质", 1000)) * 0.001))
	var mp_recover_gain: int = int(round(float(pet.get("魔法资质", 1000)) * 0.001))
	var new_hp_max: int = 620 + level_count * hp_gain
	var new_mp_max: int = 180 + level_count * mp_gain
	pet["生命上限"] = new_hp_max
	pet["魔法上限"] = new_mp_max
	pet[DataKeys.ATTACK] = 65 + level_count * attack_gain
	pet[DataKeys.DEFENSE] = 60 + level_count * defense_gain
	pet["物防"] = int(pet.get(DataKeys.DEFENSE, 0))
	pet["防"] = int(pet.get(DataKeys.DEFENSE, 0))
	pet["魔抗"] = int(pet.get(DataKeys.DEFENSE, 0))
	pet["魔防"] = int(pet.get(DataKeys.DEFENSE, 0))
	pet["回血"] = 2 + level_count * hp_recover_gain
	pet["回魔"] = 1 + level_count * mp_recover_gain
	if restore_peak:
		pet[DataKeys.HP] = new_hp_max
		pet[DataKeys.MP] = new_mp_max
	else:
		pet[DataKeys.HP] = clampi(int(pet.get(DataKeys.HP, new_hp_max)), 0, new_hp_max)
		pet[DataKeys.MP] = clampi(int(pet.get(DataKeys.MP, new_mp_max)), 0, new_mp_max)
	return {
		"hp": new_hp_max - old_hp_max,
		"mp": new_mp_max - old_mp_max,
		"attack": int(pet.get(DataKeys.ATTACK, 0)) - old_attack,
		"defense": int(pet.get(DataKeys.DEFENSE, 0)) - old_defense,
		"hp_recover": 0,
		"mp_recover": 0
	}


func _active_pet_unit_can_restore(slot: int = 1) -> bool:
	var unit: Node = _active_pet_unit_for_exp(get_tree().root, slot)
	if unit == null:
		return true
	if unit.is_queued_for_deletion():
		return false
	if unit.get("hp") != null and int(unit.get("hp")) <= 0:
		return false
	return true


func _restore_pet_to_peak(pet: Dictionary) -> void:
	pet[DataKeys.HP] = int(pet.get("生命上限", pet.get(DataKeys.HP, 0)))
	pet[DataKeys.MP] = int(pet.get("魔法上限", pet.get(DataKeys.MP, 0)))


func _pet_tiger_stage_for_level(level: int) -> int:
	if level >= 50:
		return 4
	if level >= 30:
		return 3
	if level >= 15:
		return 2
	return 1


func _pet_tiger_stage_name(stage: int) -> String:
	match clampi(stage, 1, 4):
		1:
			return "虎丸"
		2:
			return "白灵虎"
		3:
			return "白虎将军"
		_:
			return "白虎战神"


func _pet_tiger_stage_skills(stage: int) -> Array:
	match clampi(stage, 1, 4):
		1:
			return ["猛扑", "虎啸"]
		2:
			return ["猛扑", "虎啸", "嗜血虎爪"]
		_:
			return ["猛扑", "虎啸", "嗜血虎爪", "横扫千军"]


func _update_pet_tiger_evolution(pet: Dictionary) -> void:
	if (
		str(pet.get(DataKeys.TYPE, "")) != "PetTiger"
		and not ["虎丸", "白灵虎", "白虎将军", "白虎战神"].has(str(pet.get(DataKeys.ALT_NAME, "")))
	):
		return
	var stage := _pet_tiger_stage_for_level(int(pet.get(DataKeys.LEVEL, 1)))
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = _pet_tiger_stage_name(stage)
	pet[DataKeys.TYPE] = "PetTiger"
	pet["技能"] = _pet_tiger_stage_skills(stage)
	if bool(pet.get(DataKeys.DEPLOYED, false)):
		PlayerData.player_data["出战宠物"] = str(pet.get(DataKeys.ALT_NAME, ""))


func _update_pet_dragon_evolution(pet: Dictionary) -> void:
	var pet_name := str(pet.get(DataKeys.ALT_NAME, ""))
	if (
		str(pet.get(DataKeys.TYPE, "")) != "PetDragon"
		and not pet_name.begins_with("辰龙")
		and pet_name not in ["龙仔", "绿英龙", "青龙将军", "青龙妖圣"]
	):
		return
	var pet_level := int(pet.get(DataKeys.LEVEL, 1))
	var stage := 4 if pet_level >= 50 else 3 if pet_level >= 30 else 2 if pet_level >= 15 else 1
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = ["", "龙仔", "绿英龙", "青龙将军", "青龙妖圣"][stage]
	pet[DataKeys.TYPE] = "PetDragon"
	pet["技能"] = _pet_dragon_stage_skills(stage)
	if bool(pet.get(DataKeys.DEPLOYED, false)):
		PlayerData.player_data["出战宠物"] = str(pet.get(DataKeys.ALT_NAME, ""))


func _pet_dragon_stage_skills(stage: int) -> Array:
	match clampi(stage, 1, 4):
		1:
			return ["分身"]
		2:
			return ["分身", "闪电冲刺"]
		3:
			return ["分身", "闪电冲刺", "雷霆万钧"]
		_:
			return ["分身", "闪电冲刺", "雷霆万钧", "青龙奥义"]


func _update_pet_turtle_evolution(pet: Dictionary) -> void:
	var pet_name := str(pet.get(DataKeys.ALT_NAME, pet.get(DataKeys.NAME, "")))
	if (
		str(pet.get(DataKeys.TYPE, "")) != "PetTurtle"
		and not pet_name.begins_with("玄武")
		and pet_name not in ["龟布", "墨玄龟", "玄武将军", "玄武大帝"]
	):
		return
	var pet_level := int(pet.get(DataKeys.LEVEL, 1))
	var stage := 4 if pet_level >= 50 else 3 if pet_level >= 30 else 2 if pet_level >= 15 else 1
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = ["", "龟布", "墨玄龟", "玄武将军", "玄武大帝"][stage]
	pet[DataKeys.NAME] = pet[DataKeys.ALT_NAME]
	pet[DataKeys.TYPE] = "PetTurtle"
	pet["技能"] = _pet_turtle_stage_skills(stage)
	if bool(pet.get(DataKeys.DEPLOYED, false)):
		PlayerData.player_data["出战宠物"] = "PetTurtle"


func _pet_turtle_stage_skills(stage: int) -> Array:
	match clampi(stage, 1, 4):
		1:
			return ["水疗盾"]
		2:
			return ["水疗盾", "同心链接"]
		3:
			return ["水疗盾", "同心链接", "水湮八荒"]
		_:
			return ["水疗盾", "同心链接", "水湮八荒", "玄武奥义"]


func _update_pet_rabbit_evolution(pet: Dictionary) -> void:
	var pet_name := str(pet.get(DataKeys.ALT_NAME, pet.get(DataKeys.NAME, "")))
	if str(pet.get(DataKeys.TYPE, "")) != "PetRabbit" and pet_name not in ["月兔", "疾风兔", "寒冰玉兔", "冰霜月神"]:
		return
	var stage := _pet_stage_for_level(int(pet.get(DataKeys.LEVEL, 1)))
	pet[DataKeys.TYPE] = "PetRabbit"
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = ["", "月兔", "疾风兔", "寒冰玉兔", "冰霜月神"][stage]
	pet[DataKeys.NAME] = pet[DataKeys.ALT_NAME]
	pet["技能"] = _pet_rabbit_stage_skills(stage)
	if bool(pet.get(DataKeys.DEPLOYED, false)):
		PlayerData.player_data["出战宠物"] = "PetRabbit"


func _pet_rabbit_stage_skills(stage: int) -> Array:
	match clampi(stage, 1, 4):
		1:
			return ["月光"]
		2:
			return ["月光", "疾风"]
		3:
			return ["月光", "疾风", "冰陨"]
		_:
			return ["月光", "疾风", "冰陨", "月神奥义"]


func _is_pet_mouse_data(pet: Dictionary) -> bool:
	if str(pet.get(DataKeys.TYPE, "")) == "PetMouse":
		return true
	var pet_name := str(pet.get(DataKeys.ALT_NAME, "")).strip_edges()
	var pet_title := str(pet.get(DataKeys.NAME, "")).strip_edges()
	return (
		pet_name.begins_with("子鼠")
		or pet_title.begins_with("子鼠")
		or pet_name in ["子鼠元帅", "子鼠大元帅"]
		or pet_title in ["子鼠元帅", "子鼠大元帅"]
	)


func _is_pet_neat_data(pet: Dictionary) -> bool:
	if str(pet.get(DataKeys.TYPE, "")) == "PetNeat":
		return true
	var pet_name := str(pet.get(DataKeys.ALT_NAME, "")).strip_edges()
	var pet_title := str(pet.get(DataKeys.NAME, "")).strip_edges()
	return pet_name in ["丑牛", "丑牛元帅", "丑牛大元帅"] or pet_title in ["丑牛", "丑牛元帅", "丑牛大元帅"]


func _is_pet_yin_tiger_data(pet: Dictionary) -> bool:
	if str(pet.get(DataKeys.TYPE, "")) == "PetYinTiger":
		return true
	var pet_name := str(pet.get(DataKeys.ALT_NAME, "")).strip_edges()
	var pet_title := str(pet.get(DataKeys.NAME, "")).strip_edges()
	return pet_name in ["寅虎", "银角虎", "寅虎元帅", "寅虎大元帅"] or pet_title in ["寅虎", "银角虎", "寅虎元帅", "寅虎大元帅"]


func _pet_yin_tiger_stage_for_level(level: int) -> int:
	return 4 if level >= 50 else 3 if level >= 30 else 2 if level >= 15 else 1


func _pet_yin_tiger_stage_name(stage: int) -> String:
	return "寅虎大元帅" if clampi(stage, 1, 4) == 4 else "寅虎元帅"


func _pet_yin_tiger_stage_skills(stage: int) -> Array:
	return ["虎啸"] if clampi(stage, 1, 4) < 4 else ["虎啸", "猛虎下山", "寅虎奥义"]


func _update_pet_yin_tiger_evolution(pet: Dictionary) -> void:
	if not _is_pet_yin_tiger_data(pet):
		return
	var stage := _pet_yin_tiger_stage_for_level(int(pet.get(DataKeys.LEVEL, 1)))
	pet[DataKeys.TYPE] = "PetYinTiger"
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = _pet_yin_tiger_stage_name(stage)
	pet[DataKeys.NAME] = pet[DataKeys.ALT_NAME]
	pet["技能"] = _pet_yin_tiger_stage_skills(stage)
	if bool(pet.get(DataKeys.DEPLOYED, false)):
		PlayerData.player_data["出战宠物"] = "PetYinTiger"


func _pet_mouse_stage_for_level(pet_level: int) -> int:
	return 2 if pet_level >= 50 else 1


func _pet_mouse_skills_for_level(pet_level: int) -> Array:
	if pet_level >= 50:
		return ["鼠窜", "回旋飞镖", "子鼠奥义"]
	if pet_level >= 30:
		return ["鼠窜", "回旋飞镖"]
	return ["鼠窜"]


func _update_pet_mouse_evolution(pet: Dictionary) -> void:
	if not _is_pet_mouse_data(pet):
		return
	var pet_level := int(pet.get(DataKeys.LEVEL, 1))
	var stage := _pet_mouse_stage_for_level(pet_level)
	var stage_name := "子鼠大元帅" if stage == 2 else "子鼠元帅"
	pet[DataKeys.TYPE] = "PetMouse"
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = stage_name
	pet[DataKeys.NAME] = stage_name
	pet["技能"] = _pet_mouse_skills_for_level(pet_level)
	if bool(pet.get(DataKeys.DEPLOYED, false)):
		PlayerData.player_data["出战宠物"] = "PetMouse"


func _update_pet_phoenix_evolution(pet: Dictionary) -> void:
	var pet_name := str(pet.get(DataKeys.ALT_NAME, pet.get(DataKeys.NAME, "")))
	if (
		str(pet.get(DataKeys.TYPE, "")) != "PetPhoenix"
		and not pet_name.begins_with("朱雀")
		and pet_name not in ["雀蛋", "炎皇雀", "朱雀将军", "朱雀女皇", "朱雀幼灵", "赤羽朱雀", "朱雀神君"]
	):
		return
	var pet_level := int(pet.get(DataKeys.LEVEL, 1))
	var stage := 4 if pet_level >= 50 else 3 if pet_level >= 30 else 2 if pet_level >= 15 else 1
	pet["阶段"] = stage
	pet[DataKeys.ALT_NAME] = ["", "雀蛋", "炎皇雀", "朱雀将军", "朱雀女皇"][stage]
	pet[DataKeys.NAME] = pet[DataKeys.ALT_NAME]
	pet[DataKeys.TYPE] = "PetPhoenix"
	pet["技能"] = _pet_phoenix_stage_skills(stage)
	if bool(pet.get(DataKeys.DEPLOYED, false)):
		PlayerData.player_data["出战宠物"] = "PetPhoenix"


func _pet_phoenix_stage_skills(stage: int) -> Array:
	match clampi(stage, 1, 4):
		1:
			return ["涅槃"]
		2:
			return ["涅槃", "不死火鸟"]
		3:
			return ["涅槃", "不死火鸟", "地火燎原"]
		_:
			return ["涅槃", "不死火鸟", "地火燎原", "朱雀奥义"]


func _apply_active_pet_unit_growth(
	level_up_count: int, growth: Dictionary, pet: Dictionary, old_stage: int, old_pet_level: int, slot: int = 1
) -> void:
	var unit: Node = _active_pet_unit_for_exp(get_tree().root, slot)
	if unit == null:
		return
	if unit.is_queued_for_deletion():
		return
	if unit.get("hp") != null and int(unit.get("hp")) <= 0:
		return
	var unit_level_value = unit.get("level")
	var unit_level := int(unit_level_value) if unit_level_value != null else 1
	var is_mouse_unit := bool(unit.get_meta("pet_mouse_unit", false)) or _is_pet_mouse_data(pet)
	var is_neat_unit := bool(unit.get_meta("pet_neat_unit", false)) or _is_pet_neat_data(pet)
	var is_yin_tiger_unit := bool(unit.get_meta("pet_yin_tiger_unit", false)) or _is_pet_yin_tiger_data(pet)
	var level_stage := (
		_pet_mouse_stage_for_level(int(pet.get(DataKeys.LEVEL, unit_level)))
		if is_mouse_unit
		else _pet_stage_for_level(int(pet.get(DataKeys.LEVEL, unit_level)))
	)
	var new_stage: int = level_stage if is_mouse_unit else max(int(pet.get("阶段", old_stage)), level_stage)
	if is_mouse_unit:
		var mouse_name := "子鼠大元帅" if new_stage == 2 else "子鼠元帅"
		pet[DataKeys.TYPE] = "PetMouse"
		pet["阶段"] = new_stage
		pet[DataKeys.ALT_NAME] = mouse_name
		pet[DataKeys.NAME] = mouse_name
		pet["技能"] = _pet_mouse_skills_for_level(int(pet.get(DataKeys.LEVEL, unit_level)))
		PlayerData.player_data["出战宠物"] = "PetMouse"
	elif is_neat_unit:
		var neat_stage := _pet_stage_for_level(int(pet.get(DataKeys.LEVEL, unit_level)))
		pet[DataKeys.TYPE] = "PetNeat"
		pet["阶段"] = neat_stage
		pet[DataKeys.ALT_NAME] = "丑牛大元帅" if neat_stage == 4 else "丑牛元帅"
		pet[DataKeys.NAME] = pet[DataKeys.ALT_NAME]
		pet["技能"] = ["蛮牛冲撞"] if neat_stage < 4 else ["蛮牛冲撞", "蛮力践踏", "丑牛奥义"]
		PlayerData.player_data["出战宠物"] = "PetNeat"
	elif is_yin_tiger_unit:
		var yin_stage := _pet_yin_tiger_stage_for_level(int(pet.get(DataKeys.LEVEL, unit_level)))
		pet[DataKeys.TYPE] = "PetYinTiger"
		pet["阶段"] = yin_stage
		pet[DataKeys.ALT_NAME] = _pet_yin_tiger_stage_name(yin_stage)
		pet[DataKeys.NAME] = pet[DataKeys.ALT_NAME]
		pet["技能"] = _pet_yin_tiger_stage_skills(yin_stage)
		PlayerData.player_data["出战宠物"] = "PetYinTiger"
	elif new_stage != int(pet.get("阶段", old_stage)):
		pet["阶段"] = new_stage
		if bool(unit.get_meta("pet_phoenix_unit", false)):
			pet[DataKeys.TYPE] = "PetPhoenix"
			pet[DataKeys.ALT_NAME] = ["", "雀蛋", "炎皇雀", "朱雀将军", "朱雀女皇"][new_stage]
			pet[DataKeys.NAME] = pet[DataKeys.ALT_NAME]
			pet["技能"] = _pet_phoenix_stage_skills(new_stage)
			PlayerData.player_data["出战宠物"] = "PetPhoenix"
		elif bool(unit.get_meta("pet_turtle_unit", false)):
			pet[DataKeys.TYPE] = "PetTurtle"
			pet[DataKeys.ALT_NAME] = ["", "龟布", "墨玄龟", "玄武将军", "玄武大帝"][new_stage]
			pet[DataKeys.NAME] = pet[DataKeys.ALT_NAME]
			pet["技能"] = _pet_turtle_stage_skills(new_stage)
			PlayerData.player_data["出战宠物"] = "PetTurtle"
		elif bool(unit.get_meta("pet_rabbit_unit", false)):
			pet[DataKeys.TYPE] = "PetRabbit"
			pet[DataKeys.ALT_NAME] = ["", "月兔", "疾风兔", "寒冰玉兔", "冰霜月神"][new_stage]
			pet[DataKeys.NAME] = pet[DataKeys.ALT_NAME]
			pet["技能"] = _pet_rabbit_stage_skills(new_stage)
			PlayerData.player_data["出战宠物"] = "PetRabbit"
		elif bool(unit.get_meta("pet_dragon_unit", false)):
			pet[DataKeys.TYPE] = "PetDragon"
			pet[DataKeys.ALT_NAME] = ["", "龙仔", "绿英龙", "青龙将军", "青龙妖圣"][new_stage]
			pet["技能"] = _pet_dragon_stage_skills(new_stage)
		elif bool(unit.get_meta("pet_tiger_unit", false)):
			pet[DataKeys.TYPE] = "PetTiger"
			pet[DataKeys.ALT_NAME] = _pet_tiger_stage_name(new_stage)
			pet["技能"] = _pet_tiger_stage_skills(new_stage)
	if new_stage != old_stage and unit.has_method("apply_pet_data"):
		unit.call("apply_pet_data", pet)
		if is_mouse_unit:
			_unlock_pet_mouse_level_skill_cooldowns(unit, old_pet_level, int(pet.get(DataKeys.LEVEL, old_pet_level)))
			return
		if is_neat_unit:
			return
		if is_yin_tiger_unit:
			return
	if new_stage != old_stage and unit.has_method("setup_pet_tiger"):
		unit.set("阶段", new_stage)
		if unit.get("tiger_stage") != null:
			unit.set("tiger_stage", new_stage)
		unit.call("setup_pet_tiger", new_stage)
		if unit.has_method("_apply_tiger_stage_scene_layout"):
			unit.call("_apply_tiger_stage_scene_layout")
		elif unit.has_method("_setup_tiger_model_frames"):
			unit.call("_setup_tiger_model_frames")
		return
	if new_stage != old_stage and unit.has_method("setup_pet_dragon"):
		unit.set("阶段", new_stage)
		if unit.get("dragon_stage") != null:
			unit.set("dragon_stage", new_stage)
		unit.call("setup_pet_dragon", new_stage)
		if unit.has_method("_apply_dragon_stage_scene_layout"):
			unit.call("_apply_dragon_stage_scene_layout")
		elif unit.has_method("_setup_dragon_model_frames"):
			unit.call("_setup_dragon_model_frames")
		return
	if new_stage != old_stage and unit.has_method("setup_pet_phoenix"):
		if unit.get("phoenix_stage") != null:
			unit.set("phoenix_stage", new_stage)
		unit.call("setup_pet_phoenix", new_stage)
		if unit.has_method("_apply_phoenix_stage_scene_layout"):
			unit.call("_apply_phoenix_stage_scene_layout")
		elif unit.has_method("_setup_phoenix_model_frames"):
			unit.call("_setup_phoenix_model_frames")
		return
	if new_stage != old_stage and unit.has_method("setup_pet_turtle"):
		if unit.get("turtle_stage") != null:
			unit.set("turtle_stage", new_stage)
		unit.call("setup_pet_turtle", new_stage)
		if unit.has_method("_apply_turtle_stage_scene_layout"):
			unit.call("_apply_turtle_stage_scene_layout")
		elif unit.has_method("_setup_turtle_model_frames"):
			unit.call("_setup_turtle_model_frames")
		return

	if unit.has_method("apply_pet_data"):
		unit.call("apply_pet_data", pet)
		if is_mouse_unit:
			_unlock_pet_mouse_level_skill_cooldowns(unit, old_pet_level, int(pet.get(DataKeys.LEVEL, old_pet_level)))
		return

	if unit.get("level") != null:
		unit.set("level", int(pet.get(DataKeys.LEVEL, int(unit.get("level")) + level_up_count)))
	if unit.get("max_hp") != null:
		unit.set("max_hp", int(pet.get("生命上限", int(unit.get("max_hp")) + int(growth.get("hp", 0)))))
	if unit.get("hp") != null:
		unit.set("hp", int(pet.get(DataKeys.HP, pet.get("生命上限", int(unit.get("hp")) + int(growth.get("hp", 0))))))
	if unit.get("attack_in") != null:
		unit.set("attack_in", int(pet.get(DataKeys.ATTACK, int(unit.get("attack_in")) + int(growth.get("attack", 0)))))
	if unit.get("def") != null:
		unit.set("def", int(pet.get(DataKeys.DEFENSE, int(unit.get("def")) + int(growth.get("defense", 0)))))
	if unit.get("mdef") != null:
		unit.set(
			"mdef", int(pet.get("魔抗", pet.get(DataKeys.DEFENSE, int(unit.get("mdef")) + int(growth.get("defense", 0)))))
		)


func _unlock_pet_mouse_level_skill_cooldowns(unit: Node, old_pet_level: int, new_pet_level: int) -> void:
	if old_pet_level < 30 and new_pet_level >= 30 and unit.get("skill_2_cd") != null:
		unit.set("skill_2_cd", 0.0)
	if old_pet_level < 50 and new_pet_level >= 50 and unit.get("skill_3_cd") != null:
		unit.set("skill_3_cd", 0.0)


func _pet_stage_for_level(pet_level: int) -> int:
	if pet_level >= 50:
		return 4
	if pet_level >= 30:
		return 3
	if pet_level >= 15:
		return 2
	return 1


func _active_pet_unit_for_exp(node: Node, slot: int = 1) -> Node:
	if node == null:
		return null
	if node == get_tree().root:
		var level_node: Node = get_tree().current_scene
		if level_node is BaseLevel:
			var registered: Variant = level_node.get_meta(LocalCoop.pet_meta_key("active_pet_unit", slot), null)
			if is_instance_valid(registered):
				return registered
	if node.has_meta("coop_slot") and LocalCoop.slot_for(node) != slot:
		return null
	if bool(node.get_meta("pet_tiger_unit", false)):
		return node
	if bool(node.get_meta("pet_dragon_unit", false)) and not bool(node.get("is_dragon_clone")):
		return node
	if bool(node.get_meta("pet_phoenix_unit", false)):
		return node
	if bool(node.get_meta("pet_turtle_unit", false)):
		return node
	if bool(node.get_meta("pet_rabbit_unit", false)):
		return node
	if bool(node.get_meta("pet_mouse_unit", false)):
		return node
	if bool(node.get_meta("pet_neat_unit", false)):
		return node
	if bool(node.get_meta("pet_yin_tiger_unit", false)):
		return node
	for child in node.get_children():
		var found := _active_pet_unit_for_exp(child, slot)
		if found != null:
			return found
	return null


func _active_pet_data_for_exp(slot: int = 1) -> Dictionary:
	var data: Dictionary = LocalCoop.data_for_slot(slot).player_data
	var pets: Variant = data.get("宠物列表", [])
	if not (pets is Array):
		return {}
	var active_name := str(data.get("出战宠物", ""))
	var first_active_pet: Dictionary = {}
	for pet in pets:
		if not (pet is Dictionary) or not bool(pet.get(DataKeys.DEPLOYED, false)):
			continue
		if first_active_pet.is_empty():
			first_active_pet = pet
		if active_name != "" and _pet_matches_active_name(pet, active_name):
			return pet
	if active_name != "":
		for pet in pets:
			if pet is Dictionary and _pet_matches_active_name(pet, active_name):
				pet[DataKeys.DEPLOYED] = true
				return pet
	return first_active_pet


func _pet_matches_active_name(pet: Dictionary, active_name: String) -> bool:
	if active_name == "":
		return false
	var pet_name := str(pet.get(DataKeys.ALT_NAME, ""))
	var pet_title := str(pet.get(DataKeys.NAME, ""))
	var pet_type := str(pet.get(DataKeys.TYPE, ""))
	return pet_name == active_name or pet_title == active_name or pet_type == active_name


func check_player_have_debuff(target):
	if get_player == null:
		return
	for i in get_player.buff.get_children():
		if i != null:
			if i.buff_info["Name"] == target:
				return true
	return false


func wd_hurt():
	if RoleProp.source_player is Role4Hero:
		if PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能10"][DataKeys.LEVEL] > 0:
			var voodoo_counts = Global.check_wd(self)
			if voodoo_counts >= 7:
				var skill_level = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能10"][DataKeys.LEVEL]
				var power = int(RoleProp.roleprop.power) * (0.5 + skill_level * 0.05)
				var skill_power = int(voodoo_counts * power)
				if skill_power > 0:
					Global.add_sound(self, "res://Music/hero/role_4/mds.mp3")
					Global.add_special_effect(self, Vector2(0, -25), "mds", Vector2(1, 1), false, 1)
					if _is_mds_awaken_active():
						set_meta("mds_awaken_skip_combo", true)
					reduce_hp(skill_power)
					if has_meta("mds_awaken_skip_combo"):
						remove_meta("mds_awaken_skip_combo")
				Global.remove_wd(self)


func _is_mds_awaken_active() -> bool:
	if not RoleProp.source_player is Role4Hero:
		return false
	var awaken_data: Variant = PlayerData.player_data.get(DataKeys.Skill.AWAKENED, {})
	var enabled_data: Variant = PlayerData.player_data.get(DataKeys.Skill.AWAKENED_ENABLED, {})
	var awakened := awaken_data is Dictionary and bool(awaken_data.get("mds", false))
	var enabled := not enabled_data is Dictionary or bool(enabled_data.get("mds", true))
	return awakened and enabled


func jsfzsy():
	var formation_name := str(PlayerData.player_data["已佩戴阵法"])
	var formation_level := 0
	if formation_name == "lpz":
		formation_level = int(PlayerData.player_data["落魄阵"]["Level"])
	elif formation_name == "tqz":
		formation_level = int(PlayerData.player_data["太清阵"]["Level"])
	if formation_name == _last_monster_formation and formation_level == _last_monster_formation_level:
		return
	_last_monster_formation = formation_name
	_last_monster_formation_level = formation_level
	if formation_name == "lpz":
		var levellpz = formation_level
		lpzzs = levellpz * 0.01
	else:
		lpzzs = 0
	if formation_name == "tqz":
		var leveltqz = formation_level
		tqzbs = leveltqz * 0.01
	else:
		tqzbs = 0


func play_hit_effect(attacker = null):
	if not is_control_immune():
		_interrupt_attack_state_on_hit()
	_show_pet_hit_blood_bar()
	Global.add_special_effect(self, Vector2(0, 0), "RoleBeHit", Vector2(1, 1), false, 1)

	if PlayerData.player_data["Myself"] != 2:
		Global.add_sound(self, "res://Music/monster_hurt/6_beattack_by_role1.mp3")
	else:
		Global.add_sound(self, "res://Music/hero/9_beattack_by_role2.mp3")

	if not death() and not is_control_immune() and mr_player.has_animation("hurt"):
		call_deferred("_deferred_play_hurt_animation")


func _show_pet_hit_blood_bar() -> void:
	if not MainSet.set_data.get("MonsterLittleBlood", false) or hp <= 0:
		return
	if monster_blood_bar == null:
		monster_blood_bar = Global.add_monster_blood(self, Vector2(-30, -90), hp / float(max_hp), hp)
	if monster_blood_bar == null:
		return
	monster_blood_bar.bar_value = float(hp) / float(max_hp)
	monster_blood_bar.bar_text = hp
	monster_blood_bar.can_show = true
	set_meta("pet_hit_blood_until", Time.get_ticks_msec() + 260)


func _deferred_play_hurt_animation():
	if not is_instance_valid(self) or death() or is_control_immune():
		return
	if mr_player.is_playing():
		mr_player.stop()
	mr_player.play("hurt")

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
