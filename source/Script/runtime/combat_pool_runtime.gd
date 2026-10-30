class_name CombatPoolRuntime
extends Node

## 战斗表现对象池：伤害数字、怪物受击、角色受击与命中音效的池化、
## 显示限流计数与清理。由 Global 作为普通子节点持有，不是 Autoload；
## 业务代码通过 Global 的同名入口（add_damage_text / recycle_* / can_show_sword_*）
## 使用，场景内部通过 Global.get_combat_pool() 归还节点。

const DAMAGE_TEXT_POOL_LIMIT := 80
const MR_HURT_POOL_LIMIT := 32
const ROLE_BE_HIT_POOL_LIMIT := 24
const SOUND_PLAYER_POOL_LIMIT := 32
const DAMAGE_TEXT_ACTIVE_LIMIT := 80
const MR_HURT_MIN_INTERVAL_MSEC := 55

const POOL_NAMES := ["damage_text", "mr_hurt", "role_be_hit", "sound_player"]

var _host: Node = null
var _pools: Dictionary = {"root": null, "damage_text": [], "mr_hurt": [], "role_be_hit": [], "sound_player": []}

## 伤害数字活跃计数：只在池化归还/树退出时递减，用于 80 条上限。
var _active_damage_texts: Dictionary = {}
var _damage_text_count: int = 0
var _damage_text_recount_frame: int = -1

## 怪物受击特效按父节点节流。
var _last_mr_hurt_msec: Dictionary = {}

## 剑阵伤害数字/命中特效按帧限流。
var _sword_damage_text_frame: int = -1
var _sword_damage_text_count: int = 0
var _sword_hit_effect_frame: int = -1
var _sword_hit_effect_count: int = 0


func setup(host: Node) -> void:
	_host = host


func get_pool_limit(pool_name: String) -> int:
	match pool_name:
		"damage_text":
			return DAMAGE_TEXT_POOL_LIMIT
		"mr_hurt":
			return MR_HURT_POOL_LIMIT
		"role_be_hit":
			return ROLE_BE_HIT_POOL_LIMIT
		"sound_player":
			return SOUND_PLAYER_POOL_LIMIT
	return 0


func get_pool_limits() -> Dictionary:
	return {
		"damage_text": DAMAGE_TEXT_POOL_LIMIT,
		"mr_hurt": MR_HURT_POOL_LIMIT,
		"role_be_hit": ROLE_BE_HIT_POOL_LIMIT,
		"sound_player": SOUND_PLAYER_POOL_LIMIT,
	}


func get_pool_size(pool_name: String) -> int:
	var pool: Variant = _pools.get(pool_name)
	return (pool as Array).size() if pool is Array else 0


func is_pool_root_valid() -> bool:
	var root: Variant = _pools.get("root")
	return root is Node and is_instance_valid(root)


func get_active_damage_text_count() -> int:
	return _damage_text_count


func get_pool_root() -> Node:
	var root: Variant = _pools.get("root")
	if root is Node and is_instance_valid(root) and not (root as Node).is_queued_for_deletion():
		return root as Node
	root = Node.new()
	(root as Node).name = "RuntimePool"
	_host.add_child(root)
	_pools["root"] = root
	return root as Node


## 取出不重置：池内节点在归还/预热时已由 prepare_for_pool() 清理，
## 调用方必须用新数据调用 setup() 或播放入口；场景类型校验由各池固定场景保证。
func take_pooled_node(pool_name: String, scene_path: String) -> Node:
	var pool: Array = _pools[pool_name]
	while pool.size() > 0:
		var node = pool.pop_back()
		if is_instance_valid(node) and not node.is_queued_for_deletion():
			return node
	var scene: PackedScene = _host.preload_scene_path(scene_path)
	if scene == null:
		return null
	return scene.instantiate()


func attach_pooled_node(node: Node, parent: Node) -> void:
	if node == null or parent == null:
		return
	var old_parent := node.get_parent()
	if old_parent != null:
		old_parent.remove_child(node)
	parent.add_child(node)


func store_pooled_node(node: Node, pool_name: String) -> void:
	if node == null or not is_instance_valid(node) or node.is_queued_for_deletion():
		return
	# 归还前统一清理：取出时不重置，调用方必须用新数据调用 setup()/播放入口。
	if node.has_method("prepare_for_pool"):
		node.call("prepare_for_pool")
	var old_parent := node.get_parent()
	if old_parent != null:
		old_parent.remove_child(node)
	var pool: Array = _pools[pool_name]
	if pool.size() >= get_pool_limit(pool_name):
		node.queue_free()
		return
	get_pool_root().add_child(node)
	pool.append(node)


func seed_pool(pool_name: String, scene: PackedScene, target_size: int) -> void:
	if scene == null:
		return
	var pool: Array = _pools[pool_name]
	while pool.size() < target_size:
		var node := scene.instantiate()
		if node == null:
			return
		get_pool_root().add_child(node)
		if node.has_method("prepare_for_pool"):
			node.call("prepare_for_pool")
		if node is CanvasItem:
			(node as CanvasItem).visible = false
		if node is AudioStreamPlayer:
			node.set_physics_process(false)
		pool.append(node)


func clear_runtime_pools() -> void:
	for pool_name in POOL_NAMES:
		var pool: Array = _pools[pool_name]
		for node_value in pool:
			var node := node_value as Node
			if node == null or not is_instance_valid(node):
				continue
			if node is AudioStreamPlayer:
				(node as AudioStreamPlayer).stop()
				(node as AudioStreamPlayer).stream = null
			node.queue_free()
		pool.clear()
	var pool_root: Variant = _pools.get("root")
	if pool_root is Node and is_instance_valid(pool_root):
		(pool_root as Node).queue_free()
	_pools["root"] = null
	_active_damage_texts.clear()
	_damage_text_count = 0
	_last_mr_hurt_msec.clear()


# -----------------------------------------------------------------------------
# 归还入口：由场景脚本经 Global 调用
# -----------------------------------------------------------------------------


func recycle_damage_text(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	release_damage_text_count(node)
	store_pooled_node(node, "damage_text")


func recycle_mr_hurt(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	store_pooled_node(node, "mr_hurt")


func recycle_role_be_hit(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	store_pooled_node(node, "role_be_hit")


# -----------------------------------------------------------------------------
# 伤害数字活跃计数
# -----------------------------------------------------------------------------


## 预留一条伤害数字配额；超过上限时按物理帧重算一次，仍然超限则拒绝。
func reserve_damage_text_slot() -> bool:
	if _damage_text_count < DAMAGE_TEXT_ACTIVE_LIMIT:
		_damage_text_count += 1
		return true
	if _damage_text_recount_frame != Engine.get_physics_frames():
		recount_active_damage_texts()
	if _damage_text_count < DAMAGE_TEXT_ACTIVE_LIMIT:
		_damage_text_count += 1
		return true
	return false


## 取节点失败时退回已预留的配额。
func refund_damage_text_slot() -> void:
	_damage_text_count -= 1
	if _damage_text_count < 0:
		_damage_text_count = 0


func is_pooled(node: Node, pool_name: String) -> bool:
	var pool: Variant = _pools.get(pool_name)
	if not (pool is Array) or node == null:
		return false
	return (pool as Array).has(node)


func track_damage_text(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	node.set_meta("damage_text_active", true)
	_active_damage_texts[node.get_instance_id()] = node
	var exit_callback := _on_damage_text_tree_exited.bind(node)
	if not node.tree_exited.is_connected(exit_callback):
		node.tree_exited.connect(exit_callback)


func release_damage_text_count(node: Node) -> void:
	if node == null or not is_instance_valid(node):
		return
	_active_damage_texts.erase(node.get_instance_id())
	if bool(node.get_meta("damage_text_active", false)):
		node.set_meta("damage_text_active", false)
		_damage_text_count -= 1
		if _damage_text_count < 0:
			_damage_text_count = 0


func recount_active_damage_texts() -> void:
	_damage_text_recount_frame = Engine.get_physics_frames()
	for instance_id in _active_damage_texts.keys():
		var node: Variant = _active_damage_texts[instance_id]
		if node == null or not is_instance_valid(node) or not bool(node.get_meta("damage_text_active", false)):
			_active_damage_texts.erase(instance_id)
	_damage_text_count = _active_damage_texts.size()


func release_all_damage_texts() -> void:
	for node_value in _active_damage_texts.values():
		if not is_instance_valid(node_value):
			continue
		var node: Node = node_value as Node
		if node == null:
			continue
		if node.has_method("recycle"):
			node.call("recycle")
		else:
			release_damage_text_count(node)
			node.queue_free()
	_active_damage_texts.clear()
	_damage_text_count = 0


func _on_damage_text_tree_exited(node: Node) -> void:
	release_damage_text_count(node)


# -----------------------------------------------------------------------------
# 怪物受击节流与剑阵显示限流
# -----------------------------------------------------------------------------


## 同一父节点的受击特效最小间隔；返回 true 表示本次应跳过。
func throttle_mr_hurt(parent: Node) -> bool:
	var now_msec := Time.get_ticks_msec()
	var key := str(parent.get_instance_id())
	var last_msec := int(_last_mr_hurt_msec.get(key, 0))
	if now_msec - last_msec < MR_HURT_MIN_INTERVAL_MSEC:
		return true
	_last_mr_hurt_msec[key] = now_msec
	return false


func can_show_sword_damage_text() -> bool:
	var frame := int(Engine.get_process_frames())
	if _sword_damage_text_frame != frame:
		_sword_damage_text_frame = frame
		_sword_damage_text_count = 0
	var limit := 3 if OS.has_feature("mobile") else 6
	if _sword_damage_text_count >= limit:
		return false
	_sword_damage_text_count += 1
	return true


func can_show_sword_hit_effect() -> bool:
	var frame := int(Engine.get_process_frames())
	if _sword_hit_effect_frame != frame:
		_sword_hit_effect_frame = frame
		_sword_hit_effect_count = 0
	var limit := 2 if OS.has_feature("mobile") else 4
	if _sword_hit_effect_count >= limit:
		return false
	_sword_hit_effect_count += 1
	return true


func get_scope_snapshot() -> Dictionary:
	var pool_sizes: Dictionary = {}
	for pool_name in POOL_NAMES:
		pool_sizes[pool_name] = get_pool_size(pool_name)
	return {
		"pool_sizes": pool_sizes,
		"pool_limits": get_pool_limits(),
		"pool_root_valid": is_pool_root_valid(),
		"active_damage_texts": _active_damage_texts.size(),
	}
