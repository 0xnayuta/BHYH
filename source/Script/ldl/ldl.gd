extends Node2D

## 显式操作者：按所在面板的槽位解析数据与属性，不依赖全局 1P/2P 视图交换。
var PlayerData: PlayerDataStore:
	get:
		return LocalCoop.data_for(self) as PlayerDataStore
var RoleProp: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self) as BaseRoleProperties

const FULLSCREEN_DESIGN_SIZE := Vector2(940, 590)
const STRENGTH_SCENE_PATH := "res://Scene/ldl/strength.tscn"
const SYNTHESIS_SCENE_PATH := "res://Scene/ldl/synthesis.tscn"
const MOSAIC_SCENE_PATH := "res://Scene/ldl/mosaic.tscn"
const DECOMPOSE_SCENE_PATH := "res://Scene/ldl/decompose.tscn"
const FORGE_SCENE_PATH := "res://Scene/ldl/forge.tscn"
@onready var bg: Sprite2D = $bg
@onready var bg_2: Sprite2D = $bg/bg2
@onready var main_backpack: Control = $Main_Backpack
@onready var lh: Label = $bg/bg2/lh

var synthesis: Synthesis
var strength: Strength
var mosaic: Mosaic
var decompose: Decompose
var forge: Forge
var one_key_syn: OneKeySynthesis
var divine_forge: DivineForge
var bone_forge: Node


func _physics_process(_delta: float) -> void:
	lh.text = str(PlayerData.get_soul())


func _fit_to_fullscreen() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var fit_scale = min(viewport_size.x / FULLSCREEN_DESIGN_SIZE.x, viewport_size.y / FULLSCREEN_DESIGN_SIZE.y)
	scale = Vector2(fit_scale, fit_scale)
	position = (viewport_size - FULLSCREEN_DESIGN_SIZE * fit_scale) * 0.5


func _ready() -> void:
	_fit_to_fullscreen()
	if not get_viewport().size_changed.is_connected(_fit_to_fullscreen):
		get_viewport().size_changed.connect(_fit_to_fullscreen)
	Global.get_ui_runtime().set_ldl_mode_active(true)
	# ldl 可能经 Global.instance_scene 的 deferred add_child 入树；ldl 的 NOTIFICATION_READY
	# 在子节点 ready 传播之后才发出（Godot Node::_propagate_ready 先递减 blocked 再发 READY），
	# 此时 bg_2 的 blocked 已为 0，默认页可安全同步挂载。
	add_qh_jm()


func _on_hc_pressed() -> void:
	MLdl.current_mode = "合成"
	remove_xq_jm()
	remove_qh_jm()
	remove_fj_jm()
	remove_dz_jm()
	remove_sz_jm()
	remove_cg_jm()
	remove_onekey_jm()
	add_hc_jm()


func _on_qh_pressed() -> void:
	MLdl.current_mode = "强化"
	remove_xq_jm()
	remove_hc_jm()
	remove_fj_jm()
	remove_dz_jm()
	remove_sz_jm()
	remove_cg_jm()
	remove_onekey_jm()
	add_qh_jm()


func _on_xq_pressed() -> void:
	if PlayerData.player_data["南天王殿"] == 1:
		MLdl.current_mode = "镶嵌"
		remove_qh_jm()
		remove_hc_jm()
		remove_fj_jm()
		remove_dz_jm()
		remove_sz_jm()
		remove_cg_jm()
		remove_onekey_jm()
		add_xq_jm()
	else:
		Global.add_message_show(Global.get_ui_runtime().windows, "通关南天门后开启镶嵌功能！", 1.5)


func _on_return_pressed() -> void:
	MLdl.current_mode = "强化"
	remove_qh_jm()
	remove_hc_jm()
	remove_xq_jm()
	remove_fj_jm()
	remove_dz_jm()
	remove_sz_jm()
	remove_cg_jm()
	remove_onekey_jm()
	Global.get_ui_runtime().set_ldl_mode_active(false)
	queue_free()


## 面板引用可复用判定：已释放或同帧已排队删除的旧节点都不能再被调用或复用。
func _panel_alive(panel: Node) -> bool:
	return is_instance_valid(panel) and not panel.is_queued_for_deletion()


## 同步创建并挂载页面，等价于 Global.instance_scene + 各 Global.add_* 工厂的
## 父节点校验、实例登记、文本居中与定位语义，只是不做延迟 add_child。
## 延迟入树会让同帧切换在 remove_infomation 前访问未初始化的 @onready 成员，
## 且 PlayerData 的槽位祖先链尚未建立；同步入树消除这段空窗。
func _add_ldl_panel(scene_path: String, panel_position: Vector2) -> Node2D:
	if is_queued_for_deletion():
		return null
	if bg_2 == null or not is_instance_valid(bg_2) or bg_2.is_queued_for_deletion():
		return null
	var scene: PackedScene = Global.load_cached_scene(scene_path)
	if scene == null:
		push_error("ldl 面板场景加载失败：%s" % scene_path)
		return null
	var panel := scene.instantiate() as Node2D
	if panel == null:
		push_error("ldl 面板实例化失败：%s" % scene_path)
		return null
	Global.get_ui_runtime().register_ui_runtime_instance(panel, str(scene.resource_path))
	Global.center_popup_texts(panel)
	panel.position = panel_position
	bg_2.add_child(panel)
	return panel


func add_qh_jm():
	MLdl.current_mode = "强化"
	if _panel_alive(strength):
		return
	strength = _add_ldl_panel(STRENGTH_SCENE_PATH, Vector2(-315, -205)) as Strength
	if _panel_alive(strength):
		# 打开面板即清空旧选择；remove_infomation 已在这步状态变化之后同步存档，
		# 父级不再额外请求一次内容完全相同的存档。
		strength.remove_infomation()


func remove_qh_jm():
	if not _panel_alive(strength):
		strength = null
		return
	# remove_infomation 内的同步存档发生在选择清空之后，父级不再重复请求。
	strength.remove_infomation()
	strength.queue_free()
	strength = null


func add_hc_jm():
	MLdl.current_mode = "合成"
	if _panel_alive(synthesis):
		return
	synthesis = _add_ldl_panel(SYNTHESIS_SCENE_PATH, Vector2(-315, -205)) as Synthesis


func remove_hc_jm():
	if not _panel_alive(synthesis):
		synthesis = null
		return
	synthesis.remove_infomation()
	synthesis.queue_free()
	synthesis = null


func add_xq_jm():
	MLdl.current_mode = "镶嵌"
	if _panel_alive(mosaic):
		return
	mosaic = _add_ldl_panel(MOSAIC_SCENE_PATH, Vector2(-315, -205)) as Mosaic


func remove_xq_jm():
	if not _panel_alive(mosaic):
		mosaic = null
		return
	mosaic.remove_infomation()
	MemoryClass.request_save("ldl_mosaic_panel")
	mosaic.queue_free()
	mosaic = null


func _on_hh_pressed() -> void:
	remove_qh_jm()
	remove_hc_jm()
	remove_xq_jm()
	remove_fj_jm()
	remove_dz_jm()
	remove_sz_jm()
	remove_cg_jm()
	remove_onekey_jm()
	Global.add_h_hjm(self, Vector2(0, 0))


func _on_fj_pressed() -> void:
	MLdl.current_mode = "分解"
	remove_qh_jm()
	remove_hc_jm()
	remove_xq_jm()
	remove_dz_jm()
	remove_sz_jm()
	remove_cg_jm()
	remove_onekey_jm()
	add_fj_jm()


func add_fj_jm():
	MLdl.current_mode = "分解"
	if _panel_alive(decompose):
		return
	decompose = _add_ldl_panel(DECOMPOSE_SCENE_PATH, Vector2(-305, -200)) as Decompose


func remove_fj_jm():
	if not _panel_alive(decompose):
		decompose = null
		return
	decompose.remove_infomation()
	MemoryClass.request_save("ldl_decompose_panel")
	decompose.queue_free()
	decompose = null


func _on_dz_pressed() -> void:
	MLdl.current_mode = "打造"
	remove_qh_jm()
	remove_hc_jm()
	remove_xq_jm()
	remove_fj_jm()
	remove_sz_jm()
	remove_cg_jm()
	remove_onekey_jm()
	add_dz_jm()


func add_dz_jm():
	MLdl.current_mode = "打造"
	if _panel_alive(forge):
		return
	forge = _add_ldl_panel(FORGE_SCENE_PATH, Vector2(-340, -200)) as Forge


func remove_dz_jm():
	if not _panel_alive(forge):
		forge = null
		return
	forge.remove_infomation()
	MemoryClass.request_save("ldl_forge_panel")
	forge.queue_free()
	forge = null


func _on_yjdy_pressed() -> void:
	MLdl.current_mode = "一键合成"
	remove_qh_jm()
	remove_hc_jm()
	remove_xq_jm()
	remove_fj_jm()
	remove_dz_jm()
	remove_sz_jm()
	remove_cg_jm()
	add_onekey_jm()


func _on_sz_pressed() -> void:
	MLdl.current_mode = "神铸"
	remove_qh_jm()
	remove_hc_jm()
	remove_xq_jm()
	remove_fj_jm()
	remove_dz_jm()
	remove_onekey_jm()
	remove_cg_jm()
	add_sz_jm()


func add_sz_jm() -> void:
	MLdl.current_mode = "神铸"
	if _panel_alive(divine_forge):
		return
	var scene := preload("res://Scene/ldl/divine_forge.tscn")
	divine_forge = scene.instantiate()
	bg_2.add_child(divine_forge)
	divine_forge.position = Vector2(-315, -205)
	divine_forge.remove_infomation()


func _on_cg_pressed() -> void:
	MLdl.current_mode = "淬骨"
	remove_qh_jm()
	remove_hc_jm()
	remove_xq_jm()
	remove_fj_jm()
	remove_dz_jm()
	remove_sz_jm()
	remove_onekey_jm()
	main_backpack.current_fl = 0
	main_backpack.current_page = 1
	main_backpack.set_box_data()
	add_cg_jm()


func add_cg_jm() -> void:
	if _panel_alive(bone_forge):
		return
	var scene := preload("res://Scene/ldl/bone_forge.tscn")
	bone_forge = scene.instantiate()
	bg_2.add_child(bone_forge)
	bone_forge.position = Vector2(-315, -205)
	bone_forge.remove_infomation()


func remove_cg_jm() -> void:
	if not _panel_alive(bone_forge):
		bone_forge = null
		return
	bone_forge.remove_infomation()
	bone_forge.queue_free()
	bone_forge = null


func remove_sz_jm() -> void:
	if not _panel_alive(divine_forge):
		divine_forge = null
		return
	divine_forge.remove_infomation()
	MemoryClass.request_save("ldl_divine_panel")
	divine_forge.queue_free()
	divine_forge = null


func add_onekey_jm():
	if _panel_alive(one_key_syn):
		return
	var scene = preload("res://Scene/ldl/one_key_synthesis.tscn")
	one_key_syn = scene.instantiate()
	bg_2.add_child(one_key_syn)
	one_key_syn.position = Vector2(-315, -205)


func remove_onekey_jm():
	if not _panel_alive(one_key_syn):
		one_key_syn = null
		return
	one_key_syn.queue_free()
	one_key_syn = null
