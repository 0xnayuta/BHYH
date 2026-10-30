class_name MagicWeaponRuntime
extends Node

## 法宝/召唤运行时：持有每个槽位当前法宝召唤物，负责创建、替换与清理。
## 由 Global 作为普通子节点持有，不是 Autoload；
## 业务代码通过 Global.add_magic_weapon / get_magic_summon_for / set_magic_summon_for 访问。
## 场景路径表仍归 Global（MAGIC_WEAPON_SCENE_PATHS），双人归属以显式槽位为准，不回落 1P。

var _host: Node = null
var current_magic_summon: Node = null
var secondary_magic_summon: Node = null


func setup(host: Node) -> void:
	_host = host


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
	var scene_path := str(_host.get_magic_weapon_scene_path(weapon_name))
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
