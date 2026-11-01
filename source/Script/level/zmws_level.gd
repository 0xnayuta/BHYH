extends Game4ImportedLevel
class_name ZmwsLevel

## 原始 ZMWS 场景驱动器：把纯地图 Node2D 组合进 BHYH 关卡基类。
## 地图负责背景/地面/原始触发器节点；BaseLevel 负责出生、分屏、刷怪、HUD 与结算。
## 外部怪物 ID 只在这里经 ExternalMonsterStore 映射为 BHYH 怪物 ID。

@export var map_scene: PackedScene
@export var map_scene_path: String

var _map_instance: Node2D
var _wall_nodes: Dictionary = {}
var _applied_wall_stage: int = -1
var _unmapped_logged: Dictionary = {}


func _ready() -> void:
	_install_map()
	super._ready()


func _install_map() -> void:
	if map_scene == null:
		push_error("ZmwsLevel: map_scene 未设置")
		return
	_map_instance = map_scene.instantiate() as Node2D
	if _map_instance == null:
		push_error("ZmwsLevel: 原始地图根节点不是 Node2D")
		return
	add_child(_map_instance)
	move_child(_map_instance, 0)
	_map_instance.name = "ZmwsMap"
	# 原始地图背景整体置于角色/怪物之后；不修改其内部节点顺序。
	_map_instance.z_index = -10
	var ground := _map_instance.get_node_or_null("ZMWS_Ground") as StaticBody2D
	if ground != null:
		# 原始场景生成时地面使用导出层 16；BHYH 角色默认只与「环境」层 1 碰撞。
		ground.collision_layer = PhysicsLayers.ENVIRONMENT
		# 原始战斗挡板是静态 wall；默认关闭，布局 close_walls/open_walls 可按原名重新开合。
		for child in ground.get_children():
			if child is CollisionShape2D and child.get_meta("_zmws_tag", "") == "wall":
				var wall := child as CollisionShape2D
				wall.disabled = true
				var wall_name := str(wall.get_meta("_zmws_wall_name", wall.name))
				_wall_nodes[wall_name] = wall
	var background := get_node_or_null("BackGround") as CanvasLayer
	if background != null:
		background.visible = false
	_disable_base_wall_shapes()
	_place_exit_from_layout()


func _disable_base_wall_shapes() -> void:
	var wall := get_node_or_null("wall") as StaticBody2D
	if wall == null:
		return
	for child in wall.get_children():
		if child is CollisionShape2D:
			(child as CollisionShape2D).disabled = true


func _place_exit_from_layout() -> void:
	var layout := _layout_entry()
	var exit_node := get_node_or_null("exit") as Node2D
	if layout == null or exit_node == null:
		return
	exit_node.position = layout.exit_rect.position + layout.exit_rect.size * 0.5
	exit_node.visible = false


func _layout_scene_path() -> String:
	return map_scene_path


func _allows_deep_monster_positions() -> bool:
	# 原始 ZMWS 地图使用完整地图高度坐标，出生点可超过 BaseMonster 的 800 默认阈值。
	return true


func _runtime_monster_id(monster_id: int) -> int:
	var mapped := ExternalMonsterStore.monster_id(monster_id)
	if mapped <= 0 and not _unmapped_logged.has(monster_id):
		_unmapped_logged[monster_id] = true
		push_warning("ZMWS 怪物未映射: %d (%s)" % [monster_id, ExternalMonsterStore.source_name(monster_id)])
	return mapped


func _update_screen_bounds(delta: float = 0.0) -> void:
	super._update_screen_bounds(delta)
	_apply_stage_walls()
	if my_camera == null:
		return
	var layout := _layout_entry()
	if layout == null:
		return
	my_camera.max_top = 0.0
	my_camera.max_bottom = maxf(layout.layout_size.y, 1.0)


## 原始地图转换器可把 `triggerWall`/`endOpenWall` 的原名写入 `_zmws_wall_name`；
## 布局使用同名 close_walls/open_walls 时按阶段开合，找不到名称时保持默认关闭。
func _apply_stage_walls() -> void:
	var layout := _layout_entry()
	if layout == null or current_stage == _applied_wall_stage:
		return
	var stage := layout.stage_at(current_stage)
	if stage == null:
		return
	_applied_wall_stage = current_stage
	for close_name in stage.close_walls:
		var wall := _wall_nodes.get(str(close_name)) as CollisionShape2D
		if wall != null:
			wall.disabled = false
	for open_name in stage.open_walls:
		var open_wall := _wall_nodes.get(str(open_name)) as CollisionShape2D
		if open_wall != null:
			open_wall.disabled = true
