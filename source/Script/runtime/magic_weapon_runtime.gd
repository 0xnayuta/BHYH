class_name MagicWeaponRuntime
extends Node

## 法宝/召唤运行时：持有每个槽位当前法宝召唤物，负责场景路径、创建、替换、预载与清理。
## 由 Global 作为普通子节点持有，不是 Autoload；
## 业务代码通过 Global.add_magic_weapon / get_magic_summon_for / set_magic_summon_for 访问。
## 场景路径表与双槽位均归本运行时，双人归属以显式槽位为准，不回落 1P。

const MAGIC_WEAPON_SCENE_PATHS := {
	"zcld": "res://Scene/magic_weapon/zcld.tscn",
	"dshl": "res://Scene/magic_weapon/cucurbit.tscn",
	"dhqf": "res://Scene/magic_weapon/dhqf.tscn",
	"tsgj": "res://Scene/magic_weapon/sword.tscn",
	"bsyj": "res://Scene/magic_weapon/mirror.tscn",
	"lsys": "res://Scene/magic_weapon/magic_umbrella.tscn",
	"xhmt": "res://Scene/magic_weapon/ghost_doll.tscn",
	"xhhl": "res://Scene/magic_weapon/cucurbit2.tscn",
	"kyl": "res://Scene/magic_weapon/hybrofoline.tscn",
	"qyj": "res://Scene/magic_weapon/cloud_sword.tscn",
	"zjfyd": "res://Scene/magic_weapon/purple_gold_bell.tscn",
	"zjhl": "res://Scene/magic_weapon/purple_glod_cucurbit.tscn",
	"yjp": "res://Scene/magic_weapon/yujingping.tscn",
	"zlwdah": "res://Scene/magic_weapon/zlwdah.tscn",
	"sqzlw": "res://Scene/magic_weapon/sqzlw.tscn",
	"nmwdnh": "res://Scene/magic_weapon/nmwdnh.tscn",
	"sqnmwdnh": "res://Scene/magic_weapon/nmwdnh.tscn",
	"xianyjp": "res://Scene/magic_weapon/xian_yujingping.tscn",
	"yx": "res://Scene/magic_weapon/yx.tscn",
	"qlsword": "res://Scene/magic_weapon/qlsword.tscn",
	"tjbg": "res://Scene/magic_weapon/taiji_bagua.tscn",
	"dzyl": "res://Scene/magic_weapon/qing_lian.tscn",
	"469000004": "res://Scene/magic_weapon/zhen_lei_tian_chui.tscn",
	"469000011": "res://Scene/magic_weapon/di_kong_yu_mo_quan.tscn",
	"yyzlj": "res://Scene/magic_weapon/eight_immortal_yyzlj.tscn",
	"ywhl": "res://Scene/magic_weapon/eight_immortal_ywhl.tscn",
	"zhyx": "res://Scene/magic_weapon/eight_immortal_zhyx.tscn",
	"bjs": "res://Scene/magic_weapon/eight_immortal_bjs.tscn",
	"sxyg": "res://Scene/magic_weapon/eight_immortal_sxyg.tscn",
	"dkhl": "res://Scene/magic_weapon/eight_immortal_dkhl.tscn",
	"yyb": "res://Scene/magic_weapon/eight_immortal_yyb.tscn",
	"hehua": "res://Scene/magic_weapon/eight_immortal_hehua.tscn",
}

var _host: Node = null
var current_magic_summon: Node = null
var secondary_magic_summon: Node = null


func setup(host: Node) -> void:
	_host = host


func get_scene_path(weapon_name: String) -> String:
	return str(MAGIC_WEAPON_SCENE_PATHS.get(weapon_name, ""))


func get_preload_paths(weapon_name: String) -> Array[String]:
	var paths: Array[String] = []
	var scene_path := get_scene_path(weapon_name)
	if scene_path != "":
		paths.append(scene_path)
	if weapon_name == "xianyjp":
		(
			paths
			. append_array(
				[
					"res://Scene/monster/monster_zhw/guanyin_summon.tscn",
					"res://Art/monster/guanyin_spine/skeleton.atlas",
					"res://Art/monster/guanyin_spine/guanyin.spine-json",
				]
			)
		)
	return paths


func prewarm_runtime_resources(weapon_name: String) -> void:
	if weapon_name != "xianyjp":
		return
	GuanyinSummon.preload_spine_data()


func clear_runtime_state() -> void:
	if current_magic_summon != null and is_instance_valid(current_magic_summon):
		current_magic_summon.queue_free()
	current_magic_summon = null
	if is_instance_valid(secondary_magic_summon):
		secondary_magic_summon.queue_free()
	secondary_magic_summon = null


func add_magic_weapon(parent, weapon_name: String, position, source_player: BaseHero = null):
	if weapon_name in PlayerData.RETIRED_WUDU_MAGIC_WEAPONS:
		return null
	var previous_summon: Node = get_magic_summon_for(source_player)
	if is_instance_valid(previous_summon):
		previous_summon.queue_free()
		set_magic_summon_for(source_player, null)
	var scene_path := get_scene_path(weapon_name)
	if scene_path == "":
		return null
	var scene: PackedScene = _host.load_scene_uncached(scene_path)
	if scene == null:
		return null
	var target: Node = scene.instantiate()
	if source_player != null:
		target.set_meta("coop_slot", LocalCoop.slot_for(source_player))
		target.set("player", source_player)
	parent.add_child(target)
	if target:
		target.position = position
		if target.has_method("set_magic_weapon_name"):
			target.set_magic_weapon_name(weapon_name)
		set_magic_summon_for(source_player, target)
	return target


func get_magic_summon_for(player: Node) -> Node:
	var summon: Node = (
		secondary_magic_summon
		if is_instance_valid(player) and LocalCoop.slot_for(player) == 2
		else current_magic_summon
	)
	return summon if is_instance_valid(summon) else null


func set_magic_summon_for(player: Node, summon: Node) -> void:
	var slot := LocalCoop.slot_for(player) if is_instance_valid(player) else 1
	if slot == 2:
		secondary_magic_summon = summon
	else:
		current_magic_summon = summon
	if is_instance_valid(summon):
		summon.set_meta("coop_slot", slot)
