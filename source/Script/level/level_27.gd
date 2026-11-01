extends BaseLevel
@onready var stop_1: CollisionShape2D = $wall/stop1
@onready var stop_2: CollisionShape2D = $wall/stop2
@onready var stop_3: CollisionShape2D = $wall/stop3
@onready var door_check: Area2D = $DoorCheck
@onready var stop_5: CollisionShape2D = $wall/stop5

var hit_count: int = 0
var is_open: bool
var can_through: bool


func _ready() -> void:
	Global.set_current_level_name("北天王殿")
	bgm_node = Global.get_audio_runtime().add_bgm(self, "res://Music/level/sdtw.MP3")
	self.level_stage = 26
	super._ready()


func _physics_process(delta: float) -> void:
	if hit_count >= 5:
		if not is_open:
			$mm.play("open")
			is_open = true
	super._physics_process(delta)
	if can_through:
		if Input.is_action_pressed("Exit"):
			Global.change_scene("res://Scene/level/level_ymj.tscn")
	if current_stage >= 1:
		if check_can_pass() and current_stage < 4:
			role_information.gogo.visible = true
		else:
			role_information.gogo.visible = false


func set_through():
	if current_stage == 1:
		if check_can_pass():
			stop_1.disabled = true
	elif current_stage == 2:
		if check_can_pass():
			stop_2.disabled = true
	elif current_stage == 3:
		if check_can_pass():
			stop_3.disabled = true
	elif current_stage == 4:
		my_camera.max_left = 3500
		stop_5.disabled = false

		if not bgm_changed_for_stage_4:
			bgm_changed_for_stage_4 = true

			if bgm_node != null:
				bgm_node.queue_free()
				bgm_node = null

			bgm_node = Global.get_audio_runtime().add_bgm(self, "res://Music/level/twdboss.MP3")


func _on_door_check_area_entered(area: Area2D) -> void:
	hit_count += 1
	Global.add_mr_hurt(door_check, Vector2(0, 0))


func _on_csm_body_entered(body: Node2D) -> void:
	if body is BaseHero:
		can_through = true


func _on_csm_body_exited(body: Node2D) -> void:
	can_through = false
