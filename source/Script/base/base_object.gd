extends CharacterBody2D
class_name BaseObject

var PlayerData: PlayerDataStore:
	get:
		return LocalCoop.data_for(self)
var RoleProp: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self)
var PlayerInput: CoopInput:
	get:
		return LocalCoop.input_for(self)

var is_reverse_move: bool = false
var reverse_move_speed_multiplier: float = 1.0

var no_debuff: bool = false

var walk_speed: int = 240
var run_speed: int
var gravity: float = -980.0
var direction: int
var obj_attack_dict: Dictionary
var jump_count: int = 0
var jump_power: float = -540.0
var hit_count: int = 0
var is_using_skills: bool = false
var is_attacking: bool = false
var is_be_attacking: bool = false
var max_hp: int
var hp: int
var is_crit: bool
var is_miss: bool
var is_ice: bool
var is_dead_link: bool
var is_eye_fix: bool


func spawn_ws_effect(visual_node: Node, parent_node: Node) -> void:
	if visual_node == null or not is_instance_valid(visual_node):
		return
	var ws_effect_scene = Global.preload_scene_path("res://Scene/hero/role_1/ws_effect.tscn")
	if ws_effect_scene == null:
		return
	var ws_effect = ws_effect_scene.instantiate()
	if ws_effect == null:
		return
	var visual_copy = visual_node.duplicate()
	if visual_copy == null:
		ws_effect.queue_free()
		return
	ws_effect.add_child(visual_copy)
	ws_effect.position = position
	if parent_node == null:
		ws_effect.queue_free()
		return
	parent_node.add_child(ws_effect)


func _physics_process(_delta: float) -> void:
	if hp >= max_hp:
		hp = max_hp
	if hp <= 0:
		hp = 0


func set_data():
	gravity = -980.0
	obj_attack_dict = {}
	jump_count = 0
	jump_power = -540.0


func get_hurt(hit_name):
	var hurt = obj_attack_dict[hit_name].power
	return hurt


func get_hurt_lx(hit_name):
	var hurt_kind = obj_attack_dict[hit_name].attackKind
	return hurt_kind


func check_fashion_and_add_fall_pro():
	if PlayerData.player_data[DataKeys.FASHION].size() <= 0:
		return 0.0
	else:
		if (
			PlayerData.check_fashion_clothes("wklzyf")
			or PlayerData.check_fashion_clothes("tslzyf")
			or PlayerData.check_fashion_clothes("bjlzyf")
			or PlayerData.check_fashion_clothes("sslzyf")
		):
			return 0.05
		if (
			PlayerData.check_fashion_clothes("wkhzyf")
			or PlayerData.check_fashion_clothes("tshzyf")
			or PlayerData.check_fashion_clothes("bjhzyf")
			or PlayerData.check_fashion_clothes("sshzyf")
		):
			return 0.08
	return 0
