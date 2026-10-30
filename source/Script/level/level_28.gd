extends BaseLevel
@onready var stop_1: CollisionShape2D = $wall/stop1
@onready var stop_2: CollisionShape2D = $wall/stop2
@onready var stop_3: CollisionShape2D = $wall/stop3
@onready var light: Node2D = $jg/Light
@onready var light_2: Node2D = $jg/Light2
@onready var light_3: Node2D = $jg/Light3
@onready var light_4: Node2D = $jg/Light4
@onready var light_5: Node2D = $jg/Light5
@onready var a_nplayer: AnimationPlayer = $ANplayer
@onready var stop_5: CollisionShape2D = $wall/stop5

var is_play: bool
var light_id = [false, true, false, true, false]
const LIGHT_HIT_COOLDOWN_MS := 180
const LIGHT_HURT_BOX_SIZE := Vector2(180, 300)
var _light_hit_time: Dictionary = {}


func _ready() -> void:
	Global.current_level = "彩虹楼"
	Global.get_audio_runtime().add_bgm(self, "res://Music/level/floor_7_10.mp3")
	self.level_stage = 27
	super._ready()
	_setup_hidden_lights()
	monster_group = {
		"stage_1": [86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86],
		"stage_2":
		[
			86,
			86,
			86,
			87,
			87,
			87,
			88,
			88,
			88,
			87,
			86,
			88,
			88,
			86,
			87,
			87,
			87,
			86,
			86,
			88,
			88,
			86,
			87,
			86,
			88,
			88,
			88,
			88
		],
		"stage_3":
		[
			86,
			86,
			86,
			87,
			87,
			87,
			88,
			88,
			88,
			87,
			86,
			88,
			88,
			86,
			87,
			87,
			87,
			86,
			86,
			88,
			88,
			86,
			87,
			86,
			88,
			88,
			88,
			88,
			86,
			88,
			87,
			88,
			86,
			86,
			87,
			88
		],
		"stage_4": [89],
	}
	monster_position_x = {
		"stage_1": [50, 1000, 50, 1000, 50, 1000, 50, 1000, 50, 1000, 50, 1000, 50, 1000, 50, 1000, 50, 1000, 50, 1000],
		"stage_2":
		[
			1250,
			1550,
			1850,
			2150,
			1250,
			1550,
			1850,
			2150,
			1250,
			1550,
			1850,
			2150,
			1250,
			1550,
			1850,
			2150,
			1250,
			1550,
			1850,
			2150,
			1250,
			1550,
			1850,
			2150,
			1250,
			1550,
			1850,
			2150,
			1250,
			1550,
			1850,
			2150
		],
		"stage_3":
		[
			2550,
			3000,
			3450,
			2550,
			3000,
			3450,
			2550,
			3000,
			3450,
			2550,
			3000,
			3450,
			2550,
			3000,
			3450,
			2550,
			3000,
			3450,
			2550,
			3000,
			3450,
			2550,
			3000,
			3450,
			2550,
			3000,
			3450,
			2550,
			3000,
			3450,
			2550,
			3000,
			3450,
			2550,
			3000,
			3450,
			2550,
			3000
		],
		"stage_4": [4500],
	}
	monster_position_y = {
		"stage_1":
		[
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			195,
			255,
			195,
			255,
			185,
			255,
			185,
			255,
			185,
			255,
			185,
			255,
			185,
			255,
			435
		],
		"stage_2":
		[
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435,
			435
		],
		"stage_3":
		[
			185,
			235,
			95,
			185,
			235,
			95,
			185,
			235,
			95,
			185,
			235,
			95,
			185,
			235,
			95,
			185,
			235,
			95,
			185,
			235,
			95,
			185,
			235,
			95,
			185,
			235,
			95,
			185,
			235,
			95,
			185,
			235,
			95,
			185,
			235,
			95,
			185,
			235,
			95,
			185,
			235,
			95,
			185,
			235,
			95,
			185,
			235,
			95,
			185,
			235,
			95,
			185,
			235,
			95,
			185,
			235
		],
		"stage_4": [450],
	}


func _setup_hidden_lights() -> void:
	var lights := [light, light_2, light_3, light_4, light_5]
	for light_node in lights:
		if light_node == null:
			continue
		if light_node.has_method("configure_for_level"):
			light_node.call("configure_for_level", "Level_28")
		else:
			light_node.set("current_level", "Level_28")
		var area := light_node.get_node_or_null("Area2D") as Area2D
		if area == null:
			continue
		area.monitoring = true
		area.monitorable = true
		area.collision_layer = 0
		area.collision_mask = 2
		var shape := area.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if shape != null:
			shape.disabled = false
			var rect := shape.shape as RectangleShape2D
			if rect == null:
				rect = RectangleShape2D.new()
			else:
				rect = rect.duplicate() as RectangleShape2D
			rect.size = LIGHT_HURT_BOX_SIZE
			shape.shape = rect
		var light_callback := Callable(light_node, "_on_area_2d_area_entered")
		if area.area_entered.is_connected(light_callback):
			area.area_entered.disconnect(light_callback)
		var level_callback := Callable(self, "_on_hidden_light_area_entered").bind(light_node)
		if not area.area_entered.is_connected(level_callback):
			area.area_entered.connect(level_callback)


func _on_hidden_light_area_entered(area: Area2D, light_node: Node2D) -> void:
	if not _is_light_attack_area(area):
		return
	var light_id := light_node.get_instance_id()
	var now_time := Time.get_ticks_msec()
	if int(_light_hit_time.get(light_id, 0)) + LIGHT_HIT_COOLDOWN_MS > now_time:
		return
	_light_hit_time[light_id] = now_time
	light_node.set("is_light", not bool(light_node.get("is_light")))
	var light_area := light_node.get_node_or_null("Area2D") as Area2D
	if light_area != null:
		Global.add_mr_hurt(light_area, Vector2(0, 0))


func _is_light_attack_area(area: Area2D) -> bool:
	if area == null:
		return false
	if (int(area.collision_layer) & 2) != 0:
		return true
	var parent := area.get_parent()
	if parent != null:
		var parent_name := str(parent.name).to_lower()
		if "hit" in parent_name or "bullet" in parent_name or "attack" in parent_name:
			return true
	var area_name := str(area.name).to_lower()
	return "hit" in area_name or "bullet" in area_name or "attack" in area_name


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if light.is_light == light_id[0]:
		if light_2.is_light == light_id[1]:
			if light_3.is_light == light_id[2]:
				if light_4.is_light == light_id[3]:
					if light_5.is_light == light_id[4]:
						if not is_play:
							a_nplayer.play("floordown")
							is_play = true

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


func move_playerto_boss():
	var tween = create_tween()
	tween.tween_property(_role, "position", $Player.position, 1)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is BaseHero:
		Global.change_scene("res://Scene/level/level_dtwd.tscn")
