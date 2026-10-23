extends AnimatableBody2D

const SOURCE_SPEED := 10.0
const MAP_RIGHT := 4985.0
const SHIP_HALF_WIDTH := 600.0
const LAST_MOVING_STAGE := 3

@onready var role_contact: Area2D = $RoleContact

var _role_on_ship := false


func _ready() -> void:
	role_contact.body_entered.connect(_on_role_contact_entered)
	role_contact.body_exited.connect(_on_role_contact_exited)


func _physics_process(delta: float) -> void:
	if not _role_on_ship or not _can_move_in_current_screen():
		return
	position.x = minf(position.x + SOURCE_SPEED * delta, MAP_RIGHT - SHIP_HALF_WIDTH)


func _can_move_in_current_screen() -> bool:
	var level := get_parent()
	if level == null:
		return false
	return int(level.get("current_stage")) <= LAST_MOVING_STAGE


func _on_role_contact_entered(body: Node2D) -> void:
	if _is_level_role(body):
		_role_on_ship = true


func _on_role_contact_exited(body: Node2D) -> void:
	if _is_level_role(body):
		_role_on_ship = false


func _is_level_role(body: Node2D) -> bool:
	var level := get_parent()
	return level != null and body == level.get("role_")
