extends BaseMagicWeapon
class_name XianYujingping

const GUANYIN_SCENE_PATH := "res://Scene/monster/monster_zhw/guanyin_summon.tscn"
const SUMMON_MP_COST := 20
const SUMMON_COOLDOWN := 12.0

var guanyin_scene: PackedScene = null
var current_summon: Node = null
var _prewarm_done: bool = false


func _ready() -> void:
	guanyin_scene = load(GUANYIN_SCENE_PATH)

	_prewarm_scene()


func _prewarm_scene() -> void:
	if _prewarm_done or guanyin_scene == null:
		return

	GuanyinSummon.preload_spine_data()
	GuanyinNormalAttackEffect.preload_effect_data()
	GuanyinSkillAEffect.preload_effect_data()
	GuanyinSkill2Effect.preload_effect_data()
	_prewarm_done = true


func use_skill() -> void:
	if not enough_mp():
		is_use = false
		return
	RoleProp.roleprop.Mp -= SUMMON_MP_COST
	show_skill()


func show_skill() -> void:
	_summon_guanyin()
	mg_action.play("hit")
	usecd = SUMMON_COOLDOWN
	fb_cd = 1
	is_use = false
	skill_cd.start(SUMMON_COOLDOWN)


func _summon_guanyin() -> void:
	_clear_current_summon()
	if guanyin_scene == null:
		guanyin_scene = load(GUANYIN_SCENE_PATH)
	if guanyin_scene == null or get_tree().current_scene == null:
		return
	var summon := guanyin_scene.instantiate()
	if summon == null:
		return
	var hero := RoleProp.source_player as Node2D
	var spawn_position := global_position + Vector2(100, 0)
	if is_instance_valid(hero):
		spawn_position = hero.global_position + Vector2(120 if not RoleProp.directon else -120, 0)
	get_tree().current_scene.add_child(summon)
	summon.global_position = spawn_position
	if summon.has_method("apply_role_property_snapshot"):
		summon.apply_role_property_snapshot(_capture_role_property_snapshot())
	if summon.has_method("set_summon_properties"):
		summon.set_summon_properties(hero, 0.0)
	current_summon = summon
	current_player_magic_summon = summon
	summon.tree_exited.connect(_on_guanyin_tree_exited.bind(summon), CONNECT_ONE_SHOT)


func _capture_role_property_snapshot() -> Dictionary:
	return {
		"roleprop": RoleProp.roleprop.duplicate(true),
		"baseroleprop": RoleProp.baseroleprop.duplicate(true),
		"equprop": RoleProp.equprop.duplicate(true),
		"pasl_prop": RoleProp.pasl_prop.duplicate(true),
		"wq_bs_prop": RoleProp.wq_bs_prop.duplicate(true),
		"fj_bs_prop": RoleProp.fj_bs_prop.duplicate(true),
		"sp_bs_prop": RoleProp.sp_bs_prop.duplicate(true),
		"cb_bs_prop": RoleProp.cb_bs_prop.duplicate(true),
		"sz_bs_prop": RoleProp.sz_bs_prop.duplicate(true),
		"tx_bs_prop": RoleProp.tx_bs_prop.duplicate(true),
		"wq_prop": RoleProp.wq_prop.duplicate(true),
		"fj_prop": RoleProp.fj_prop.duplicate(true),
		"sp_prop": RoleProp.sp_prop.duplicate(true),
		"sz_prop": RoleProp.sz_prop.duplicate(true),
		"tx_prop": RoleProp.tx_prop.duplicate(true),
		"cb_prop": RoleProp.cb_prop.duplicate(true),
		"fb_prop": RoleProp.fb_prop.duplicate(true)
	}


func _clear_current_summon() -> void:
	if is_instance_valid(current_summon):
		current_summon.queue_free()
	if current_player_magic_summon == current_summon:
		current_player_magic_summon = null
	current_summon = null


func _on_guanyin_tree_exited(exited_summon: Node) -> void:
	if current_summon == exited_summon:
		current_summon = null
	if current_player_magic_summon == exited_summon:
		current_player_magic_summon = null


func _exit_tree() -> void:
	_clear_current_summon()

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
