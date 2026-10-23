extends TextureRect

var PlayerData: PlayerDataStore:
	get:
		var coop := get_node_or_null("/root/LocalCoop")
		return coop.data_for(self) if coop != null else get_node("/root/PlayerData")
var RoleProp: BaseRoleProperties:
	get:
		var coop := get_node_or_null("/root/LocalCoop")
		return coop.props_for(self) if coop != null else get_node("/root/RoleProp")

const MOUNT_CATALOG := preload("res://Script/mount/mount_catalog.gd")

@onready var pic_box: TextureProgressBar = $PicBox
@onready var time_text: Label = $TimeText
@onready var last_time: Timer = $LastTime
@onready var power_effect: Sprite2D = $PowerEffect
@onready var open_effect: Sprite2D = $OpenEffect
var can_rest: bool = true
var skill_name: String
var max_time
var mount_skill_slot: int = -1
var _loaded_icon_path: String = ""
var _open_effect_elapsed: float = 0.0

var _mp_label: Label = null


func get_icon_name(skill_name: String) -> String:
	if _current_role_id() == 1 and skill_name == "hmz_ws":
		return "hmz_ws"

	return skill_name


func get_real_skill_key(skill_name: String) -> String:
	return skill_name


func _current_role_id() -> int:
	return int(PlayerData.player_data.get("Myself", 1))


func _physics_process(delta: float) -> void:
	_update_nezha_effects(delta)
	if skill_name == null or skill_name == "" or skill_name == "Empty":
		if _loaded_icon_path != "":
			_loaded_icon_path = ""
			texture = null
			pic_box.texture_progress = null
		time_text.visible = false
		pic_box.value = 0
		return
	if RoleProp.source_player == null:
		return

	if mount_skill_slot >= 0:
		var mount_runtime := _current_mount_runtime()
		if (
			mount_runtime != null
			and mount_runtime.has_method("is_riding_mount")
			and bool(mount_runtime.call("is_riding_mount"))
		):
			var mount_skill: Dictionary = mount_runtime.call("get_mount_skill_for_slot", mount_skill_slot)
			var mount_skill_id := str(mount_skill.get("id", ""))
			_set_icon_path(MOUNT_CATALOG.get_icon_path(mount_skill_id))
			last_time.stop()
			can_rest = true
			_show_mount_cooldown(
				float(mount_runtime.call("get_mount_skill_cooldown", mount_skill_slot)),
				float(mount_runtime.call("get_mount_skill_cooldown_total", mount_skill_slot))
			)
			return
		_show_mount_cooldown(0.0, 0.0)
		return

	if skill_name != null and skill_name != "":
		var icon_name = get_icon_name(skill_name)
		var icon_path = "res://Art/skill/little_skill_icon/" + icon_name + ".png"
		var learning_icon_path: String = "res://Art/skill/skill_icon/" + str(icon_name) + ".png"
		if ResourceLoader.exists(learning_icon_path):
			icon_path = learning_icon_path
		_set_icon_path(icon_path)

		var real_key = get_real_skill_key(skill_name)
		var skill_inter = RoleProp.source_player.get("role1_skill_inter")
		if skill_inter == null or not skill_inter.has(real_key):
			return

		if can_rest:
			if skill_inter[real_key] > 0:
				if last_time.is_stopped():
					max_time = skill_inter[real_key] / float(6)
					can_rest = false
					last_time.start(max_time)

		if last_time.time_left <= 0:
			time_text.visible = false
			pic_box.value = 0
		else:
			time_text.visible = true
			if last_time.time_left > 1:
				time_text.text = str(snapped(last_time.time_left, 1))
			else:
				time_text.text = str(snapped(last_time.time_left, 0.1))
			pic_box.value = last_time.time_left / float(max_time)


func _set_icon_path(icon_path: String) -> void:
	if icon_path == _loaded_icon_path:
		return
	_loaded_icon_path = icon_path
	var icon_texture: Texture2D = Global.get_cached_texture(icon_path) if icon_path != "" else null
	texture = icon_texture
	pic_box.texture_progress = icon_texture


func _show_mount_cooldown(remaining_value: float, total_value: float) -> void:
	var remaining := maxf(0.0, remaining_value)
	var total := maxf(0.0, total_value)
	pic_box.value = remaining / total if total > 0.0 else 0.0
	time_text.visible = remaining > 0.0
	if remaining > 0.0:
		time_text.text = str(snapped(remaining, 1.0 if remaining > 1.0 else 0.1))


func _current_mount_runtime() -> Node:
	var player = RoleProp.source_player
	if player == null or not is_instance_valid(player):
		return null
	return player.get_node_or_null("MountRuntime")


func _update_nezha_effects(delta: float) -> void:
	var source_player = RoleProp.source_player
	var is_nezha := _current_role_id() == 6 and source_player is NeZhaHero
	var is_role4 := _current_role_id() == 4 and source_player is Role4Hero
	var is_role3 := _current_role_id() == 3 and source_player is Role3Hero
	var icon_scale: float = maxf(absf(scale.x), 0.001)
	var effect_scale := Vector2.ONE / icon_scale if is_nezha or is_role4 else Vector2.ONE
	power_effect.scale = effect_scale
	open_effect.scale = effect_scale
	power_effect.visible = is_nezha and skill_name == NeZhaHero.SKILL_SPEAR
	var is_open_skill := false
	if is_nezha:
		is_open_skill = (
			(skill_name == NeZhaHero.SKILL_LOTUS and bool(source_player.get("_lotus_enabled")))
			or (skill_name == NeZhaHero.SKILL_YINYANG and bool(source_player.get("_yinyang_enabled")))
		)
	elif is_role4:
		is_open_skill = skill_name == "wdzt" and bool(source_player.get("_wdzt_awaken_enabled"))
	elif is_role3:
		is_open_skill = skill_name == "sd" and bool(source_player.get("_sd_awaken_enabled"))
	open_effect.visible = is_open_skill
	if power_effect.visible:
		power_effect.frame = clampi(int(floor(float(source_player.get("_spear_energy")) / 100.0 * 10.0)), 0, 10)
	if open_effect.visible:
		_open_effect_elapsed = fmod(_open_effect_elapsed + delta, 1.0)
		open_effect.frame = clampi(int(floor(_open_effect_elapsed * 30.0)), 0, 29)
	else:
		_open_effect_elapsed = 0.0
		open_effect.frame = 0


func set_mp_display(mp_value: int):
	"Called by Role_information.gd to set the mp cost label."
	if _mp_label == null:
		_mp_label = Label.new()
		_mp_label.name = "MpCost"
		_mp_label.add_theme_font_size_override("font_size", 8)
		_mp_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		_mp_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		_mp_label.add_theme_constant_override("outline_size", 2)
		_mp_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		_mp_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		_mp_label.position = Vector2(0, 0)
		_mp_label.size = Vector2(40, 20)
		add_child(_mp_label)
	_mp_label.text = str(mp_value)
	_mp_label.visible = mp_value > 0 and skill_name != "" and skill_name != "Empty"


func _on_last_time_timeout() -> void:
	can_rest = true
