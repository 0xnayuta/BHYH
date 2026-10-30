class_name CombatPresentationFactory
extends Node

## 战斗表现族的场景工厂：持有 buff、陷阱、弹体、伤害数字、命中文字、血条与
## Miss 特效的运行时场景缓存。由 Global 作为普通子节点持有，不是 Autoload；
## 业务代码仍通过 Global.add_* 正式入口调用。
## 池化工厂（add_damage_text / add_mr_hurt / add_special_effect 的 RoleBeHit 分支）
## 通过 Global.get_combat_pool() 取还节点；池状态由 CombatPoolRuntime 持有。

const BASE_BUFF_PATH := "res://Scene/base/base_buff.tscn"
const BUFF_ICON_PATH := "res://Scene/other_scene/buff_icon.tscn"
const TRAP_PATH := "res://Scene/level/trap.tscn"
const SPECIAL_EFFECT_BULLET_PATH := "res://Scene/hero/role_1/hmz_effect/special_effect_bullet.tscn"
const HIT_TEXT_PATH := "res://Scene/hittext/hit_text.tscn"
const DAMAGE_NUMBER_PATH := "res://Scene/hittext/damage_number.tscn"
const MONSTER_BLOOD_PATH := "res://Scene/monster_blood/monster_blood_bar.tscn"
const BOSS_BLOOD_PATH := "res://Scene/monster_blood/boss_blood.tscn"
const MISS_EFFECT_PATH := "res://Scene/hittext/miss_effect.tscn"
const DAMAGE_TEXT_PATH := "res://Scene/hittext/damage_text.tscn"
const MONSTER_BE_HIT_PATH := "res://Scene/monster_damage/monster_be_hit.tscn"
const ROLE_BE_HIT_EFFECT_PATH := "res://Scene/base/role_be_hit_effect.tscn"
const SPECIAL_AFFECT_SLIM_DIR := "res://Scene/base/special_affect_slim"

const UNIQUE_BUFF_NAMES := [
	"Ice",
	"stun",
	"EyeFix",
	"DeadLink",
	"Boundground",
	"silent",
	"Immobilize",
	"blood_fix",
	"life_mana_lock",
	"Scary",
	"SuperArmor",
	"DoubleFallPro",
	"PoisionBody",
	"no_debuff",
	"yxbuff",
	"HealOverTime",
	"MagicDrain",
	"ReverseMove",
	"jgz",
	"zznh",
	"speed_down",
	"defe_reduce",
	"nlls",
	"slzbuff",
	"lpzbuff",
	"tszbuff",
	"lljybuff",
	"PetLifeBonus",
	"PetAttackBonus",
	"PetDefenseBonus",
	"PetManaBonus",
]

var _host: Node = null
var _scenes: Dictionary = {}


func setup(host: Node) -> void:
	_host = host


func clear_scene_caches() -> void:
	_scenes.clear()


func _scene(path: String) -> PackedScene:
	var cached: Variant = _scenes.get(path)
	if cached is PackedScene:
		return cached as PackedScene
	var scene: PackedScene = _host.load_cached_scene(path)
	if scene != null:
		_scenes[path] = scene
	return scene


## 角色预载命中 hmz 技能时提前持有弹体场景；与 Global.add_special_effect_bullet 共用同一缓存。
func preload_special_effect_bullet() -> PackedScene:
	return _scene(SPECIAL_EFFECT_BULLET_PATH)


func add_buff(parent, buff_info):
	if parent == null or not (buff_info is Dictionary):
		return null
	var target = parent.get_parent()
	if target != null and target.get("no_debuff") != null:
		if target.get("no_debuff"):
			if (
				buff_info.has("DeBuff")
				and buff_info["DeBuff"]
				and buff_info["Name"] != "jgz"
				and buff_info["Name"] != "zznh"
			):
				return null
	var new_name := str(buff_info.get("Name", ""))
	if new_name == "":
		return null
	if target is BaseMonster and target.is_control_immune() and _host.is_monster_control_buff(new_name):
		return null
	if (
		(target is BaseHero or target is BaseMonster)
		and target.is_white_bar_control_immune()
		and (_host.is_monster_control_buff(new_name) or new_name == "hanxiangzisleep")
	):
		return null
	var can_add := bool(buff_info.get("CanAdd", false)) and new_name != "speed_down"
	if not can_add and new_name in UNIQUE_BUFF_NAMES:
		var refresh: Dictionary = _refresh_existing_buff(parent, target, buff_info, new_name)
		if bool(refresh.get("handled", false)):
			return refresh.get("node")
	var node_instance = _host.instance_scene(_scene(BASE_BUFF_PATH), parent)
	if node_instance == null:
		return null
	if node_instance.has_method("start_buff"):
		var buff_instance = node_instance
		buff_instance.buff_info = buff_info.duplicate(true)
		if (
			target is BaseMonster
			and not target.is_control_immune()
			and new_name in ["Ice", "stun", "EyeFix", "Immobilize", "lljybuff"]
		):
			target.interrupt_movement_for_control()
		return buff_instance
	print("Invalid BaseBuff instance")
	node_instance.queue_free()
	return null


## 同名唯一 buff 的刷新/忽略判定。handled=true 表示已消费本次调用：
## node 非空为复用的已有实例，null 为按规则忽略。
func _refresh_existing_buff(parent, target, buff_info: Dictionary, new_name: String) -> Dictionary:
	for child in parent.get_children():
		var child_buff = child.get("buff_info")
		if not (child_buff is Dictionary) or str(child_buff.get("Name", "")) != new_name:
			continue
		if child.get("buff_time") == null:
			return {"handled": true, "node": null}
		child.buff_info = buff_info.duplicate(true)
		child.last_value = float(buff_info.get("value", 0.0))
		if new_name == "speed_down" and child.has_method("apply_slow_speed"):
			child.apply_slow_speed()
		child.last_time = float(buff_info.get("AddTime", 0.0))
		if child.buff_time != null:
			child.buff_time.start(float(buff_info.get("AddTime", 0.0)))
		if (
			new_name in ["PetLifeBonus", "PetAttackBonus", "PetDefenseBonus", "PetManaBonus"]
			and child.has_method("refresh_pet_owner_bonus")
		):
			child.refresh_pet_owner_bonus(maxi(0, int(buff_info.get("value", 0))))
		if (
			target is BaseMonster
			and not target.is_control_immune()
			and new_name in ["Ice", "stun", "EyeFix", "Immobilize", "lljybuff"]
		):
			target.interrupt_movement_for_control()
		return {"handled": true, "node": child}
	return {"handled": false, "node": null}


func add_trap(parent, _position, _name):
	var target = _host.instance_scene(_scene(TRAP_PATH), parent)
	if target == null:
		return null
	target.z_index = 99
	target._get_name = _name
	target.position = _position
	return target


func add_special_effect_bullet(parent, _position, _scale, _name, dir):
	var target = _host.instance_scene(preload_special_effect_bullet(), parent)
	if target == null:
		return null
	target.z_index = 99
	target.position = _position
	target._scale = _scale
	target.dire = dir
	target.action_name = _name
	return target


func add_bullet(bullet_name: String, parent, direction: bool, show_speed, position, _hit_name, list):
	var target = _host.instance_scene(_host.load_monster_bullet_scene(bullet_name), parent)
	if target == null:
		return null
	target.att_list = list
	target.hit_name = _hit_name
	target.position = position
	target.dir = direction
	target.skill_name = bullet_name
	target.speed = show_speed
	return target


func add_bullet_safe(bullet_name, parent, direction, show_speed, position, _hit_name, list):
	var bullet_scene = _host.load_monster_bullet_scene(str(bullet_name))
	if bullet_scene == null:
		return null
	var target = bullet_scene.instantiate()
	target.att_list = list
	target.hit_name = _hit_name
	if str(_hit_name) != "" and list is Dictionary:
		target.obj_attack_dict[_hit_name] = list
	target.position = position
	target.dir = direction
	target.skill_name = bullet_name
	target.speed = show_speed
	parent.call_deferred("add_child", target)
	return target


func add_hit_text(parent, _position, value, lx, crit, miss):
	var target = _host.instance_scene(_scene(HIT_TEXT_PATH), parent)
	if target == null:
		return null
	target.show_lx = str(lx)
	target.is_crit = crit
	target.is_miss = miss
	target.show_text = value
	target.position = _position
	return target


func add_damage_number(parent, value, type_: String, is_crit: bool, tar):
	if not bool(MainSet.set_data.get("ShowDamageText", true)):
		return null
	var target = _host.instance_scene(_scene(DAMAGE_NUMBER_PATH), parent)
	if target == null:
		return null
	if is_instance_valid(tar):
		target.target = tar
	else:
		target.target = null
	target.is_crit = is_crit
	target.type = type_
	target.need_number = value
	return target


func add_monster_blood(parent, _position, value, text):
	var target = _host.instance_scene(_scene(MONSTER_BLOOD_PATH), parent)
	if target == null:
		return null
	target.bar_value = value
	target.bar_text = text
	target.position = _position
	return target


func add_damage_text(parent, position, value, type_: String, is_crit: bool, tar):
	if not bool(MainSet.set_data.get("ShowDamageText", true)):
		return null
	var pool: CombatPoolRuntime = _host.get_combat_pool()
	if not pool.reserve_damage_text_slot():
		return null
	var target: Node = pool.take_pooled_node("damage_text", DAMAGE_TEXT_PATH)
	if target == null:
		pool.refund_damage_text_slot()
		return null
	pool.attach_pooled_node(target, parent)
	pool.track_damage_text(target)
	target.position = position
	if target.has_method("setup"):
		target.setup(value, type_, is_crit, tar)
	else:
		target.target = tar
		target.type = type_
		target.damage_value = value
		target.is_crit = is_crit
	return target


func add_mr_hurt(parent, _position):
	if parent == null:
		return null
	var pool: CombatPoolRuntime = _host.get_combat_pool()
	if pool.throttle_mr_hurt(parent):
		return null
	var target: Node = pool.take_pooled_node("mr_hurt", MONSTER_BE_HIT_PATH)
	if target == null:
		return null
	pool.attach_pooled_node(target, parent)
	target.modulate = Color.WHITE
	target.position = _position
	if target.has_method("_play_hurt_animation"):
		target._play_hurt_animation()
	return target


func add_special_effect(parent, _position, _name, _scale, direction, _speed):
	var effect_name := str(_name)
	if effect_name == "RoleBeHit" or effect_name == "role_be_hit":
		var pool: CombatPoolRuntime = _host.get_combat_pool()
		var role_hit: Node = pool.take_pooled_node("role_be_hit", ROLE_BE_HIT_EFFECT_PATH)
		if role_hit == null:
			return null
		pool.attach_pooled_node(role_hit, parent)
		role_hit.z_index = 99
		role_hit.position = _position
		role_hit.setup(_scale, direction, _speed)
		return role_hit
	var scene_path := SPECIAL_AFFECT_SLIM_DIR.path_join(effect_name + ".tscn")
	if not ResourceLoader.exists(scene_path):
		push_error("Missing slim special effect scene: " + scene_path)
		return null
	var target = _host.instance_scene(_scene(scene_path), parent)
	if target == null:
		return null
	target.z_index = 99
	target.effect_name = _name
	target._scale = _scale
	target.effect_speed = _speed
	target.effect_dir = direction
	target.position = _position
	return target


func add_buff_icon(parent, data):
	if parent == null or not is_instance_valid(parent) or parent.is_queued_for_deletion():
		return null
	var buff_scene := _scene(BUFF_ICON_PATH)
	if buff_scene == null:
		return null
	var target = buff_scene.instantiate()
	if target == null:
		return null
	parent.add_child(target)
	target.data_list = data
	var buff_name := str(data.get("Name", "")) if data is Dictionary else ""
	if not buff_name.is_empty():
		target.name = buff_name
		target.buff_name = buff_name
	return target


func add_miss_effect(parent, position):
	var target = _host.instance_scene(_scene(MISS_EFFECT_PATH), parent)
	if target == null:
		return null
	target.position = position
	return target


func add_boss_blood_instance(parent, Obj):
	var target = _host.instance_scene(_scene(BOSS_BLOOD_PATH), parent)
	if target == null:
		return null
	target.get_obj = Obj
	return target
