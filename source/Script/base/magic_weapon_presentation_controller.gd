class_name MagicWeaponPresentationController
extends RefCounted
## 当前装备法宝的展示实例生命周期。
## 只负责按槽位档案创建/替换/移除 BaseMagicWeapon 展示节点；
## 法宝命令、冷却、伤害与 BaseMagicWeapon 的播放逻辑仍归原所有者。

var _hero: BaseHero
var _target: BaseMagicWeapon
var _active_name := ""


func _init(hero: BaseHero) -> void:
	_hero = hero


func get_target() -> BaseMagicWeapon:
	if is_instance_valid(_target) and not _target.is_queued_for_deletion():
		return _target
	return null


func get_active_name() -> String:
	return _active_name


## 每物理帧同步一次，调用顺序与旧 BaseHero 的三个检查一致。
func tick() -> void:
	if not is_instance_valid(_hero) or _hero.is_queued_for_deletion():
		return
	handle_empty_selection()
	handle_changed_selection()
	ensure_selection()


func refresh() -> void:
	handle_empty_selection()
	handle_changed_selection()
	ensure_selection()


func clear() -> void:
	_release_target()


func handle_empty_selection() -> void:
	if str(_player_data().player_data.get("实战法宝", "")) != "":
		return
	_release_target()
	if not _weapon_list().is_empty():
		add_equipped()


func handle_changed_selection() -> void:
	var equipped := str(_player_data().player_data.get("实战法宝", ""))
	if get_target() == null or _active_name == equipped:
		return
	_release_target()
	if not _weapon_list().is_empty():
		add_equipped()


func ensure_selection() -> void:
	if _weapon_list().is_empty():
		_release_target()
		return
	if get_target() == null:
		add_equipped()


func add_equipped() -> void:
	if get_target() != null:
		return
	var weapons := _weapon_list()
	if weapons.is_empty():
		_release_target()
		return
	var equipped := str(_player_data().player_data.get("实战法宝", ""))
	if equipped in _hero.PlayerData.RETIRED_WUDU_MAGIC_WEAPONS:
		_player_data().player_data["实战法宝"] = ""
		equipped = ""
	if equipped == "":
		equipped = str((weapons[0] as Dictionary).get(DataKeys.NAME, ""))
		_player_data().player_data["实战法宝"] = equipped
	var parent := _hero.get_parent()
	if parent == null:
		return
	var level_parent := parent.get_parent()
	if level_parent == null or level_parent.is_queued_for_deletion():
		return
	var created: Node = Global.add_magic_weapon(level_parent, equipped, Vector2.ZERO, _hero)
	if created == null:
		_release_target()
		return
	if not created.has_method("set_magic_weapon_player"):
		created.queue_free()
		_release_target()
		return
	created.set_magic_weapon_player(_hero)
	var typed_target := created as BaseMagicWeapon
	if typed_target == null:
		created.queue_free()
		_release_target()
		return
	_target = typed_target
	_active_name = equipped


func _release_target() -> void:
	if is_instance_valid(_target) and not _target.is_queued_for_deletion():
		_target.queue_free()
	_target = null
	_active_name = ""


func _player_data() -> PlayerDataStore:
	return _hero.PlayerData


func _weapon_list() -> Array:
	var value: Variant = _player_data().player_data.get(DataKeys.MAGIC_WEAPON, [])
	return value if value is Array else []
