class_name RewardFactory
extends Node

## 奖励与任务族的场景工厂：持有奖励面板、奖励宝箱、任务奖励、任务面板与
## 关卡结算面板的运行时场景缓存。由 Global 作为普通子节点持有，不是 Autoload；
## 业务代码仍通过 Global.add_* 正式入口调用。

const REWARD_INFO_PATH := "res://Scene/other_scene/reward_interface.tscn"
const REWARD_BOX_PATH := "res://Scene/other_scene/reward_box_2.tscn"
const TASK_REWARD_PATH := "res://Scene/task/task_reward.tscn"
const BASIC_TASK_PATH := "res://Scene/task/basic_task.tscn"
const AFTER_LEVEL_END_PATH := "res://Scene/other_scene/after_level_end.tscn"

var _host: Node = null
var _scenes: Dictionary = {}


func setup(host: Node) -> void:
	_host = host


func clear_scene_caches() -> void:
	_scenes.clear()


## 目标节点可能尚未进入场景树（instance_scene 走延迟 add_child），
## 暂停判定统一取宿主树，语义与拆分前的 get_tree() 一致。
func _is_tree_paused() -> bool:
	var tree := _host.get_tree()
	return tree != null and tree.paused


func _scene(path: String) -> PackedScene:
	var cached: Variant = _scenes.get(path)
	if cached is PackedScene:
		return cached as PackedScene
	var scene: PackedScene = _host.load_cached_scene(path)
	if scene != null:
		_scenes[path] = scene
	return scene


func add_reward_info(parent, position, list, use_item_name, use_num, claim_callable: Callable = Callable()):
	var target = _host.instance_scene(_scene(REWARD_INFO_PATH), parent)
	if target == null:
		return null
	if position == Vector2.ZERO:
		target.position = _host.viewport_center_for_parent(parent) - Vector2(478, 210)
	else:
		target.position = position
	target.use_num = use_num
	target.use_item_name = use_item_name
	target.reward_items = list
	target.claim_callable = claim_callable
	target.z_index = 99
	_host.get_ui_runtime().register_transient_ui(target, &"_on_close_pressed")
	return target


func add_reward_box(parent, item_id, num):
	var target = _host.instance_scene(_scene(REWARD_BOX_PATH), parent)
	if target == null:
		return null
	target.item_id = item_id
	target.num = num
	if is_instance_valid(target) and _is_tree_paused():
		target.process_mode = Node.PROCESS_MODE_ALWAYS
	return target


func add_task_reward(parent, ItemName, total_num):
	var target = _host.instance_scene(_scene(TASK_REWARD_PATH), parent)
	if target == null:
		return null
	target.item_id = ItemName
	target.total_num = total_num
	target.z_index = 99
	return target


func add_basic_task(parent, position):
	var target = _host.instance_scene(_scene(BASIC_TASK_PATH), parent)
	if target == null:
		return null
	_host.get_ui_runtime().register_transient_ui(target, &"_on_close_pressed")
	if position == Vector2.ZERO or position == Vector2(0, 0):
		target.position = _host.viewport_center_for_parent(parent) - Vector2(470, 295)
	else:
		target.position = position
	return target


func add_after_level_end(parent, position):
	var target = _host.instance_scene(_scene(AFTER_LEVEL_END_PATH), parent)
	if target == null:
		return null
	# 原实现写 z_index = 9999 超出 CanvasItem 合法范围 [-4096, 4096]，赋值从未生效；
	# 这里去掉无效赋值，保持实际渲染顺序与历史一致。
	target.top_level = true
	if position != Vector2.ZERO and position != Vector2(0, 0):
		target.position = position
	return target
