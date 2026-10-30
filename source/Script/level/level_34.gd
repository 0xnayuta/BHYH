extends BaseLevel

@onready var stop_1: CollisionShape2D = $wall/stop1
@onready var stop_2: CollisionShape2D = $wall/stop2
@onready var stop_3: CollisionShape2D = $wall/stop3
@onready var stop_5: CollisionShape2D = $wall/stop5
var hurt_count: int = 0

@onready var jg: Node2D = $jg
@onready var light_1: Node2D = $jg/Light1
@onready var light_2: Node2D = $jg/Light2
@onready var light_3: Node2D = $jg/Light3
@onready var light_4: Node2D = $jg/Light4

@onready var check: Area2D = $Check

var is_play: bool = false
var lights_on: bool = false
var is_transporting: bool = false
const LIGHT_HIT_COOLDOWN_MS := 180
const LIGHT_HURT_BOX_SIZE := Vector2(180, 300)
var _light_hit_time: Dictionary = {}


func _ready() -> void:
	load("res://Scene/monster/monster_122.tscn")
	load("res://Scene/monster/monster_118.tscn")
	Global.set_current_level_name("尾妖林")
	Global.get_audio_runtime().add_bgm(self, "res://Music/level/34_bg5.mp3")
	self.level_stage = 39
	super._ready()

	$Check/check.disabled = true
	_setup_hidden_lights()

	monster_group = {
		"stage_1": [118, 118, 118, 118, 118, 118, 118, 118, 118, 122, 122, 122, 122, 122, 122, 122, 122, 122],
		"stage_2":
		[
			118,
			118,
			118,
			118,
			118,
			118,
			118,
			118,
			118,
			118,
			118,
			118,
			118,
			118,
			118,
			118,
			118,
			122,
			122,
			122,
			122,
			122,
			122,
			122,
			122,
			122,
			122,
			122,
			122,
			122,
			122,
			122,
			122
		],
		"stage_3":
		[
			118,
			118,
			118,
			118,
			118,
			118,
			118,
			118,
			118,
			118,
			118,
			118,
			118,
			118,
			118,
			118,
			118,
			118,
			118,
			118,
			122,
			122,
			122,
			122,
			122,
			122,
			122,
			122,
			122,
			122,
			122,
			122,
			122,
			122,
			122,
			122,
			122,
			122,
			122
		],
		"stage_4": [1403]
	}

	monster_position_x = {
		"stage_1":
		[350, 800, 350, 800, 350, 800, 100, 1000, 100, 1000, 100, 1000, 100, 1000, 100, 1000, 100, 1000, 100, 1000],
		"stage_2":
		[
			1350,
			1750,
			2150,
			1350,
			1750,
			2150,
			1350,
			1750,
			2150,
			1650,
			1420,
			1650,
			1400,
			1650,
			1420,
			1550,
			2000,
			1550,
			2000,
			1550,
			2000,
			1550,
			2000,
			1550,
			2000,
			1400,
			2000,
			1400,
			2000,
			1400,
			2000,
			1400,
			2000
		],
		"stage_3":
		[
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250,
			2850,
			3250
		],
		"stage_4": [4500, 4500, 4500, 4500, 4500, 4500, 4500, 4500, 4500, 4500, 4500, 4500],
	}

	monster_position_y = {
		"stage_1":
		[
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420
		],
		"stage_2":
		[
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			220,
			420,
			220,
			420,
			220,
			420,
			220,
			420,
			220,
			420,
			220,
			420,
			220,
			420,
			220,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420,
			420
		],
		"stage_3":
		[
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420,
			420,
			220,
			420,
			420,
			220,
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420,
			420,
			420,
			220,
			420
		],
		"stage_4": [450, 450, 450, 450, 450, 450, 450, 450, 450, 450],
	}


func _setup_hidden_lights() -> void:
	var lights := [light_1, light_2, light_3, light_4]
	for light_node in lights:
		if light_node == null:
			continue
		if light_node.has_method("configure_for_level"):
			light_node.call("configure_for_level", "Level_34")
		else:
			light_node.set("current_level", "Level_34")
			light_node.set("is_light", false)
			light_node.set("is_activated", false)
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
	if bool(light_node.get("is_light")):
		return
	light_node.set("is_activated", true)
	light_node.set("is_light", true)
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

	if not lights_on and not is_play and _check_lights_match():
		_on_all_lights_on()

	if current_stage >= 1:
		if check_can_pass() and current_stage < 4:
			role_information.gogo.visible = true
		else:
			role_information.gogo.visible = false


func _check_lights_match() -> bool:
	var lights = [light_1, light_2, light_3, light_4]

	for light in lights:
		if light == null or not light.is_light:
			return false

	return true


func _on_all_lights_on():
	is_play = true
	lights_on = true

	Global.add_message_show(self, "所有灯已点亮！", 2.5, Vector2(500, 300))

	$Check/check.disabled = false

	_trigger_special_effect()


func _trigger_special_effect():
	if stop_1:
		stop_1.disabled = true
	if stop_2:
		stop_2.disabled = true


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
		stop_3.disabled = true
		stop_5.disabled = false


func _on_check_area_entered(area: Area2D) -> void:
	if not $Check/check.disabled:
		hurt_count += 1
		Global.add_mr_hurt($Check, Vector2(0, 0))

		if hurt_count >= 3 and not is_transporting:
			is_transporting = true

			Global.add_message_show(self, "传送开启！", 1.5, Vector2(500, 200))

			call_deferred("_transport_to_hidden_level")


func _transport_to_hidden_level():
	Global.change_scene("res://Scene/level/level_34_1.tscn")
