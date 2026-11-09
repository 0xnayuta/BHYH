extends Node2D
const AFTER_LEVEL_DESIGN_SIZE := Vector2(954.0, 548.0)


func _fit_to_window() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var fit_scale = min(
		1.0, min(viewport_size.x / AFTER_LEVEL_DESIGN_SIZE.x, viewport_size.y / AFTER_LEVEL_DESIGN_SIZE.y)
	)
	scale = Vector2(fit_scale, fit_scale)
	position = viewport_size * 0.5 - Vector2(477.0, 274.0) * fit_scale


@onready var total_hit_count: Label = $HBoxContainer/VBoxContainer/TotalHitCount
@onready var total_hit: Label = $HBoxContainer/VBoxContainer/TotalHit
@onready var totalphyhit: Label = $HBoxContainer/VBoxContainer/Totalphyhit
@onready var totalmaghit: Label = $HBoxContainer/VBoxContainer/Totalmaghit
@onready var total_real_hit: Label = $HBoxContainer/VBoxContainer/TotalRealHit
@onready var total_crit_count: Label = $HBoxContainer/VBoxContainer/TotalCritCount
@onready var total_hurt_count: Label = $HBoxContainer/VBoxContainer2/TotalHurtCount
@onready var total_hurt: Label = $HBoxContainer/VBoxContainer2/TotalHurt
@onready var total_phy_hurt: Label = $HBoxContainer/VBoxContainer2/TotalPhyHurt
@onready var total_mag_hurt: Label = $HBoxContainer/VBoxContainer2/TotalMagHurt
@onready var total_real_hurt: Label = $HBoxContainer/VBoxContainer2/TotalRealHurt
@onready var total_miss_count: Label = $HBoxContainer/VBoxContainer2/TotalMissCount
@onready var total_cure: Label = $HBoxContainer/VBoxContainer3/TotalCure


func _ready() -> void:
	_fit_to_window()
	if not get_viewport().size_changed.is_connected(_fit_to_window):
		get_viewport().size_changed.connect(_fit_to_window)
	total_cure.text = "累计治疗数值：" + str(Global.get_run_context().healing)
	total_hurt.text = "累计受到伤害：" + str(Global.get_run_context().damage_taken)
	total_hit_count.text = "累计攻击次数：" + str(Global.get_run_context().hit_count)
	total_hurt_count.text = "累计受伤次数：" + str(Global.get_run_context().hurt_count)
	total_phy_hurt.text = "累计受到物伤：" + str(Global.get_run_context().physical_taken)
	total_mag_hurt.text = "累计受到魔伤：" + str(Global.get_run_context().magic_taken)
	total_real_hurt.text = "累计受到真伤：" + str(Global.get_run_context().real_taken)
	total_hit.text = "累计造成伤害：" + str(Global.get_run_context().damage_dealt)
	totalphyhit.text = "累计造成物伤：" + str(Global.get_run_context().physical_dealt)
	totalmaghit.text = "累计造成魔伤：" + str(Global.get_run_context().magic_dealt)
	total_real_hit.text = "累计造成真伤：" + str(Global.get_run_context().real_dealt)
	total_crit_count.text = "累计暴击次数：" + str(Global.get_run_context().crit_count)
	total_miss_count.text = "累计闪避次数：" + str(Global.get_run_context().miss_count)


func _on_glose_pressed() -> void:
	queue_free()


func _exit_tree() -> void:
	if get_viewport().size_changed.is_connected(_fit_to_window):
		get_viewport().size_changed.disconnect(_fit_to_window)
