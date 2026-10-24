extends Node2D
const FULLSCREEN_DESIGN_SIZE := Vector2(940, 590)
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
	Global.is_in_ldl = true
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
		Global.add_message_show(Global.windows, "通关南天门后开启镶嵌功能！", 1.5, Vector2(470, 285))


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
	Global.is_in_ldl = false
	queue_free()


func add_qh_jm():
	MLdl.current_mode = "强化"
	if strength == null:
		strength = Global.add_strength(bg_2, Vector2(-315, -205))
		MemoryClass.save_game(Global.cd_path)
		strength.remove_infomation()


func remove_qh_jm():
	if strength != null:
		strength.remove_infomation()
		MemoryClass.save_game(Global.cd_path)
		strength.queue_free()


func add_hc_jm():
	MLdl.current_mode = "合成"
	if synthesis == null:
		synthesis = Global.add_synthesis(bg_2, Vector2(-315, -205))


func remove_hc_jm():
	if synthesis != null:
		synthesis.remove_infomation()
		MemoryClass.save_game(Global.cd_path)
		synthesis.queue_free()


func add_xq_jm():
	MLdl.current_mode = "镶嵌"
	if mosaic == null:
		mosaic = Global.add_mosaic_instance(bg_2, Vector2(-315, -205))


func remove_xq_jm():
	if mosaic != null:
		mosaic.remove_infomation()
		MemoryClass.save_game(Global.cd_path)
		mosaic.queue_free()


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
	if decompose == null:
		decompose = Global.add_decompose_instance(bg_2, Vector2(-305, -200))


func remove_fj_jm():
	if decompose != null:
		decompose.remove_infomation()
		MemoryClass.save_game(Global.cd_path)
		decompose.queue_free()


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
	if forge == null:
		forge = Global.add_forges(bg_2, Vector2(-340, -200))


func remove_dz_jm():
	if forge != null:
		forge.remove_infomation()
		MemoryClass.save_game(Global.cd_path)
		forge.queue_free()


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
	if divine_forge == null:
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
	if bone_forge != null:
		return
	var scene := preload("res://Scene/ldl/bone_forge.tscn")
	bone_forge = scene.instantiate()
	bg_2.add_child(bone_forge)
	bone_forge.position = Vector2(-315, -205)
	bone_forge.remove_infomation()


func remove_cg_jm() -> void:
	if is_instance_valid(bone_forge):
		bone_forge.remove_infomation()
		bone_forge.queue_free()
	bone_forge = null


func remove_sz_jm() -> void:
	if is_instance_valid(divine_forge):
		divine_forge.remove_infomation()
		MemoryClass.save_game(Global.cd_path)
		divine_forge.queue_free()
	divine_forge = null


func add_onekey_jm():
	if one_key_syn == null:
		var scene = preload("res://Scene/ldl/one_key_synthesis.tscn")
		one_key_syn = scene.instantiate()
		bg_2.add_child(one_key_syn)
		one_key_syn.position = Vector2(-315, -205)


func remove_onekey_jm():
	if one_key_syn != null:
		one_key_syn.queue_free()
		one_key_syn = null
