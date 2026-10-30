class_name ProjectileFactory
extends Node

## 角色/怪物弹体场景工厂：Role4 弹体、通用弹体、角色 slim 弹体、法宝弹体与基础丹药。
## 由 Global 作为普通子节点持有，不是 Autoload；
## 缓存槽位与迁移前的 Global.role4_bullet/new_bullet/role_bullet_1/monster65_bullet 一致。
## 来源写入仍由 Global._assign_attack_source 统一处理，避免两套归属规则。

const ROLE4_BULLET_SCENE_PATH := "res://Scene/hero/role_4/role4_bullet.tscn"
const NEW_BULLET_SCENE_PATH := "res://Scene/hero/bullet_bullet.tscn"
const ROLE_BULLET_1_SCENE_PATH := "res://Scene/hero/role_bullet_1.tscn"
const MONSTER65_BULLET_SCENE_PATH := "res://Scene/monster/monster65bullet.tscn"
const BASIC_PELLET_SCENE_PATH := "res://Scene/pellet/basic_pellet.tscn"
const ROLE_BULLET_SLIM_DIR := "res://Scene/hero/role_bullet_slim"
const STREAMING_ROLE_BULLET_PATH := "res://Scene/hero/streaming_role_bullet.tscn"
const ROLE3_BULLET3_SLIM_PATH := "res://Scene/hero/role3_bullet3_slim.tscn"
const ADD_WEAPON_BULLET_PATHS := {
	"CloudSwordBullet": "res://Scene/magic_weapon/hit_bullet_lazy/cloud_sword_bullet.tscn",
	"CucurFire_1": "res://Scene/magic_weapon/hit_bullet_lazy/cucur_fire_1.tscn",
	"CucurFire_2": "res://Scene/magic_weapon/hit_bullet_lazy/cucur_fire_2.tscn",
	"GhostDollBullet_1": "res://Scene/magic_weapon/hit_bullet_lazy/ghost_doll_bullet_1.tscn",
	"GhostDollBullet_2": "res://Scene/magic_weapon/hit_bullet_lazy/ghost_doll_bullet_2.tscn",
	"GhostDollBullet_3": "res://Scene/magic_weapon/hit_bullet_lazy/ghost_doll_bullet_3.tscn",
	"MagicUmbrellaBullet": "res://Scene/magic_weapon/hit_bullet_lazy/magic_umbrella_bullet.tscn",
	"PurpleGlodCucurbitBullet": "res://Scene/magic_weapon/hit_bullet_lazy/purple_glod_cucurbit_bullet.tscn",
	"SwordBullet": "res://Scene/magic_weapon/hit_bullet_lazy/sword_bullet.tscn",
	"wdsfBullet1": "res://Scene/magic_weapon/hit_bullet_lazy/wdsf_bullet1.tscn",
	"wdsfBullet2": "res://Scene/magic_weapon/hit_bullet_lazy/wdsf_bullet2.tscn",
	"wdsfBullet3": "res://Scene/magic_weapon/hit_bullet_lazy/wdsf_bullet3.tscn",
	"wdshBullet1": "res://Scene/magic_weapon/hit_bullet_lazy/wdsh_bullet1.tscn",
	"wdshBullet2": "res://Scene/magic_weapon/hit_bullet_lazy/wdsh_bullet2.tscn",
	"wdshBullet2_1": "res://Scene/magic_weapon/hit_bullet_lazy/wdsh_bullet2_1.tscn",
	"wdslBullet1": "res://Scene/magic_weapon/hit_bullet_lazy/wdsl_bullet1.tscn",
	"wdslBullet2": "res://Scene/magic_weapon/hit_bullet_lazy/wdsl_bullet2.tscn",
	"wdstBullet1": "res://Scene/magic_weapon/hit_bullet_lazy/wdst_bullet1.tscn",
	"wdstBullet2": "res://Scene/magic_weapon/hit_bullet_lazy/wdst_bullet2.tscn",
	"wdstBullet3": "res://Scene/magic_weapon/hit_bullet_lazy/wdst_bullet3.tscn",
}

var _host = null
var _role4_bullet_scene: PackedScene = null
var _new_bullet_scene: PackedScene = null
var _role_bullet_1_scene: PackedScene = null
var _monster65_bullet_scene: PackedScene = null
var _basic_pellet_scene: PackedScene = null


func setup(host: Node) -> void:
	_host = host


func clear_scene_caches() -> void:
	_role4_bullet_scene = null
	_new_bullet_scene = null
	_role_bullet_1_scene = null
	_monster65_bullet_scene = null
	_basic_pellet_scene = null


func get_role4_bullet_scene() -> PackedScene:
	if _role4_bullet_scene == null:
		_role4_bullet_scene = _host.load_cached_scene(ROLE4_BULLET_SCENE_PATH)
	return _role4_bullet_scene


func get_new_bullet_scene() -> PackedScene:
	if _new_bullet_scene == null:
		_new_bullet_scene = _host.load_cached_scene(NEW_BULLET_SCENE_PATH)
	return _new_bullet_scene


func get_role_bullet_1_scene() -> PackedScene:
	if _role_bullet_1_scene == null:
		_role_bullet_1_scene = _host.load_cached_scene(ROLE_BULLET_1_SCENE_PATH)
	return _role_bullet_1_scene


func get_monster65_bullet_scene() -> PackedScene:
	if _monster65_bullet_scene == null:
		_monster65_bullet_scene = _host.load_cached_scene(MONSTER65_BULLET_SCENE_PATH)
	return _monster65_bullet_scene


func add_role4_bullet(parent, player, position: Vector2):
	var target = _host.instance_scene(get_role4_bullet_scene(), parent)
	if target == null:
		return null
	target.player = player
	target.position = position
	return target


func add_new_bullet(parent, position, dir, bullet_name, dic):
	var target = _host.instance_scene(get_new_bullet_scene(), parent)
	if target == null:
		return null
	target.position = position
	target._name = bullet_name
	target.hit_dic = dic
	target.direction = dir
	return target


func add_role_bullet(parent, position, dir, bullet_name, dic, source_player: BaseHero = null):
	var resolved_name := str(bullet_name)
	var scene = null
	if resolved_name in ["Role3Bullet2", "TtzsszBullet"]:
		scene = _host.load_scene_uncached(STREAMING_ROLE_BULLET_PATH)
	elif resolved_name == "Role3Bullet3":
		scene = _host.load_scene_uncached(ROLE3_BULLET3_SLIM_PATH)
	else:
		var slim_path := ROLE_BULLET_SLIM_DIR.path_join(_slim_filename(resolved_name))
		if not ResourceLoader.exists(slim_path):
			push_error("Missing slim role bullet scene: " + slim_path)
			return null
		scene = _host.load_scene_uncached(slim_path)
	var target = _host.instance_scene(scene, parent)
	if target == null:
		return null
	target.position = position
	target._name = bullet_name
	target.hit_dic = dic
	target.direction = dir
	_host._assign_attack_source(target, parent, source_player)
	return target


func add_role_bullet_1(parent, position, bullet_name, dic, source_player: BaseHero = null):
	var target = _host.instance_scene(get_role_bullet_1_scene(), parent)
	if target == null:
		return null
	target.position = position
	target._name = bullet_name
	target.hit_dic = dic
	_host._assign_attack_source(target, parent, source_player)
	return target


## 延迟挂载变体：先实例化并写入字段，再交给调用方场景挂载，避免在 signal 回调中重入。
func add_role_bullet_1_safe(parent, position, bullet_name, dic, source_player: BaseHero = null):
	var scene := get_role_bullet_1_scene()
	if scene == null:
		return null
	var target = scene.instantiate()
	if target == null:
		return null
	target.position = position
	target._name = bullet_name
	target.hit_dic = dic
	_host._assign_attack_source(target, parent, source_player)
	parent.call_deferred("add_child", target)
	return target


func get_basic_pellet_scene() -> PackedScene:
	if _basic_pellet_scene == null:
		_basic_pellet_scene = _host.load_cached_scene(BASIC_PELLET_SCENE_PATH)
	return _basic_pellet_scene


func add_basic_pellet(parent, position):
	var target = _host.instance_scene(get_basic_pellet_scene(), parent)
	if target == null:
		return null
	target.position = position
	return target


func add_monster65_bullet(parent, position):
	var target = _host.instance_scene(get_monster65_bullet_scene(), parent)
	if target == null:
		return null
	target.position = position
	return target


func add_weapon_bullet(parent, position, bullet_name, attack_list, dir, random_source):
	var scene_path := str(ADD_WEAPON_BULLET_PATHS.get(str(bullet_name), ""))
	if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
		push_error("Missing lazy weapon bullet scene for: " + str(bullet_name))
		return null
	var target = _host.instance_scene(_host.load_cached_scene(scene_path), parent)
	if target == null:
		return null
	target.obj_attack_dict = attack_list
	target.rnd = random_source
	target._name = bullet_name
	target.dir = dir
	target.position = position
	return target


func _slim_filename(bullet_name: String) -> String:
	var result := ""
	var length := bullet_name.length()
	for index in length:
		var character := bullet_name[index]
		if character >= "A" and character <= "Z":
			var previous := bullet_name[index - 1] if index > 0 else ""
			var next_character := bullet_name[index + 1] if index + 1 < length else ""
			var previous_breaks := (
				(previous >= "a" and previous <= "z")
				or (previous >= "0" and previous <= "9")
				or (previous >= "A" and previous <= "Z" and next_character >= "a" and next_character <= "z")
			)
			if previous_breaks:
				result += "_"
			result += character.to_lower()
		else:
			result += character
	return result + ".tscn"
