extends Node

## 显式操作者：按所在面板的槽位解析数据与属性，不依赖全局 1P/2P 视图交换。
var PlayerData: PlayerDataStore:
	get:
		return LocalCoop.data_for(self) as PlayerDataStore
var RoleProp: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self) as BaseRoleProperties

@onready var information := get_parent().get_node_or_null("background/infomation")
var _secondary_page := false


func _ready() -> void:
	process_physics_priority = 1000
	if information == null:
		return
	var first_button := information.get_node_or_null("first") as BaseButton
	var second_button := information.get_node_or_null("second") as BaseButton
	if first_button != null:
		first_button.pressed.connect(_show_primary_page, CONNECT_DEFERRED)
	if second_button != null:
		second_button.pressed.connect(_show_secondary_page, CONNECT_DEFERRED)


func _physics_process(_delta: float) -> void:
	if information == null:
		return
	if _secondary_page:
		_update_percentage_attributes()
	for node_name in ["lucky", "crit", "miss"]:
		var label := information.get_node_or_null(node_name) as Label
		if label != null:
			label.text = _integer_rating_text(label.text)


func _integer_rating_text(value: String) -> String:
	var bracket_index := value.find(" (")
	if bracket_index <= 0:
		return value
	var rating_text := value.substr(0, bracket_index)
	if not rating_text.is_valid_float():
		return value
	return "%d%s" % [int(round(float(rating_text))), value.substr(bracket_index)]


func _show_primary_page() -> void:
	_secondary_page = false


func _show_secondary_page() -> void:
	_secondary_page = true
	_update_percentage_attributes()


func _update_percentage_attributes() -> void:
	_set_percentage_attribute("crit", "Crit_tt", "伤害", float(RoleProp.roleprop.get("damage_bonus", 0.0)))
	_set_percentage_attribute("miss", "misstt", "免伤", _get_effective_damage_reduction())


func _get_effective_damage_reduction() -> float:
	var permanent_reduction := maxf(0.0, float(RoleProp.roleprop.get("damage_reduction", 0.0)))
	var temporary_reduction := 0.0
	var source_player: Variant = RoleProp.source_player
	if source_player != null and is_instance_valid(source_player):
		var player := source_player as BaseHero
		if player != null:
			temporary_reduction = maxf(0.0, player.wdsl_damage_reduction)
	return permanent_reduction + temporary_reduction


func _set_percentage_attribute(node_name: String, title_name: String, title: String, value: float) -> void:
	var value_label := information.get_node_or_null(node_name) as Label
	if value_label == null:
		return
	value_label.text = "%.2f%%" % (value * 100.0)
	var title_label := value_label.get_node_or_null(title_name) as Label
	if title_label != null:
		title_label.text = title
