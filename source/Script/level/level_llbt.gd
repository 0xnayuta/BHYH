extends BaseLevel
@onready var stop_1: CollisionShape2D = $wall/stop1
@onready var level_text: Label = $LevelText
@onready var bbg: ColorRect = $bbg

@onready var lz_node: Node2D = $LZ
@onready var lzdz_sprite: AnimatedSprite2D = $LZ/LZDZ
@onready var lz_sprite: AnimatedSprite2D = $LZ/LZDZ/LZ
@onready var lz_area: Area2D = $LZ/Area2D
@onready var lz_collision: CollisionShape2D = $LZ/Area2D/CollisionShape2D
@onready var l_zdh: AnimationPlayer = $LZ/LZdh

var lz_mechanism_shown: bool = false
var lz_hit_count: int = 0
var lz_triggered: bool = false


func _ready() -> void:
	if PlayerData.has_method("ensure_special_dungeon_progress"):
		PlayerData.ensure_special_dungeon_progress()
	if Global.llbtwxms:
		Global.llbt_level = 25
		Global.infinite_level_multiplier = 0.0
		print("无限模式当前实际层数固定为: ", Global.llbt_level)
	var reached_level := int(PlayerData.player_data.get("玲珑宝塔层数", 0))
	if Global.llbt_level >= reached_level:
		if not Global.llbtwxms:
			PlayerData.player_data["玲珑宝塔层数"] = Global.llbt_level
	if Global.llbt_level == 24 or Global.llbt_level == 6 or Global.llbt_level == 12 or Global.llbt_level == 18:
		bbg.modulate = Color(1, 1, 1, 1)
	else:
		bbg.modulate = Color(1, 1, 1, 0)
	if Global.llbtwxms:
		Global.llbt_level = 25
		level_text.text = "∞"
		self.level_stage = 1
	else:
		level_text.text = str(Global.llbt_level)
		if Global.llbt_level == 24:
			self.level_stage = 30
	Global.current_level = "玲珑宝塔"
	Global.add_bgm(self, "res://Music/level/music_emsd.mp3")

	lz_node.visible = false
	lz_collision.disabled = true
	lz_area.monitoring = false

	if not lz_area.area_entered.is_connected(_on_lz_area_entered):
		lz_area.area_entered.connect(_on_lz_area_entered)
	print("LZ 机关初始化完成，信号已连接")
	monster_list()
	super._ready()
	set_through()
	if Global.llbtcgms:
		if Global.llbt_level != 1:
			RoleProp.roleprop.Hp = RoleProp.current_hp
			RoleProp.roleprop.Mp = RoleProp.current_mp


func show_lz_mechanism() -> void:
	if lz_mechanism_shown:
		return
	lz_mechanism_shown = true
	print("显示 LZ 机关，当前层数：", Global.llbt_level)

	var level = Global.llbt_level
	var lzdz_anim: String = ""
	var lz_anim: String = ""

	match level:
		6:
			lzdz_anim = "tlzdz"
			lz_anim = "tlz"
		12:
			lzdz_anim = "llzdz"
			lz_anim = "llz"
		18:
			lzdz_anim = "hlzdz"
			lz_anim = "hlz"
		24:
			lzdz_anim = "flzdz"
			lz_anim = "flz"
		_:
			return

	lzdz_sprite.play(lzdz_anim)
	lz_sprite.play(lz_anim)
	lz_node.visible = true

	lz_hit_count = 0
	lz_triggered = false
	lz_collision.disabled = false
	lz_area.monitoring = true
	print("碰撞层: ", lz_area.collision_layer, " 掩码: ", lz_area.collision_mask)
	print("碰撞形状 disabled: ", lz_collision.disabled)


func _on_lz_area_entered(area: Area2D) -> void:
	if lz_triggered:
		return

	lz_hit_count += 1
	print("攻击次数: ", lz_hit_count, "/3")

	Global.add_mr_hurt(lz_sprite, Vector2(0, 0))

	if lz_hit_count >= 3:
		lz_triggered = true
		lz_collision.set_deferred("disabled", true)
		lz_area.set_deferred("monitoring", false)

		var level = Global.llbt_level
		var anim_name: String = ""
		var item_name: String = ""
		match level:
			6:
				anim_name = "tlz"
				item_name = "tlz"
			12:
				anim_name = "llz"
				item_name = "llz"
			18:
				anim_name = "hlz"
				item_name = "hlz"
			24:
				anim_name = "flz"
				item_name = "flz"
			_:
				return

		l_zdh.play(anim_name)
		print("播放动画: ", anim_name, " 位置: ", lz_sprite.global_position)

		var drop_pos = lz_sprite.global_position + Vector2(0, 100)
		print("掉落位置: ", drop_pos)
		Global.fall_item(self.fall_it, drop_pos, item_name, 1)


func _physics_process(_delta: float) -> void:
	if my_camera != null and _green_detector != null:
		var cam = get_viewport().get_camera_2d()
		if cam:
			_green_detector.global_position = cam.get_screen_center_position()
	if current_stage >= 1:
		if not is_two_scene:
			if (
				monster_group["stage_2"].size() == 0
				and monster_group["stage_3"].size() == 0
				and monster_group["stage_4"].size() == 0
			):
				if one_check_can_exit():
					if Global.llbtwxms:
						_restart_infinite_monster_wave()
					else:
						exit.visible = true
						exit_2.disabled = false
						add_tg(level_stage)

						var level = Global.llbt_level
						if level in [6, 12, 18, 24]:
							show_lz_mechanism()
	if can_exit:
		RoleProp.current_hp = RoleProp.roleprop.Hp
		RoleProp.current_mp = RoleProp.roleprop.Mp
		if Input.is_action_just_pressed("Exit") or _is_auto_battle_enabled():
			_leave_level_from_exit()

	if _role == null:
		if my_camera != null:
			my_camera.queue_free()


func _restart_level_for_auto_battle() -> bool:
	if not MainSet.is_auto_battle_enabled():
		return false
	if not bool(MainSet.set_data.get("AutoBattleRetry", false)):
		return false
	if Global.last_level_path == "":
		return false
	_save_auto_battle_progress()
	RoleProp.set_full_hp()
	RoleProp.set_full_mp()
	RoleProp.current_hp = int(RoleProp.roleprop.Hp)
	RoleProp.current_mp = int(RoleProp.roleprop.Mp)
	RoleProp.ws_value = 0
	RoleProp.is_ws_state = false
	Global.is_dead_link = false
	Global.remove_all_buff()
	Global.change_scene(Global.last_level_path)
	return true


func _is_auto_battle_enabled() -> bool:
	return MainSet.is_auto_battle_enabled()


func _leave_level_from_exit() -> void:
	if _auto_exit_settling:
		return
	_auto_exit_settling = true
	await get_tree().create_timer(1.0).timeout
	if not is_inside_tree():
		return
	RoleProp.current_hp = RoleProp.roleprop.Hp
	RoleProp.current_mp = RoleProp.roleprop.Mp
	if Global.llbtbossms:
		if not _restart_level_for_auto_battle():
			Global.change_scene("res://Scene/level/victory.tscn")
	elif Global.llbtcgms:
		if Global.llbt_level == 24:
			if PlayerData.has_method("ensure_special_dungeon_progress"):
				PlayerData.ensure_special_dungeon_progress()
			PlayerData.player_data["玲珑宝塔层数"] = 25
			if not _restart_level_for_auto_battle():
				Global.change_scene("res://Scene/level/victory.tscn")
		else:
			if Global.llbt_level < 24:
				Global.llbt_level += 1
			_save_auto_battle_progress()
			Global.change_scene("res://Scene/level/level_llbt.tscn")
	elif Global.llbtwxms:
		_save_auto_battle_progress()
		Global.change_scene("res://Scene/level/level_llbt.tscn")


func _save_auto_battle_progress() -> bool:
	return MemoryClass.request_save("level_auto_battle")


func set_through():
	if my_camera != null and is_instance_valid(my_camera):
		my_camera.max_right = 1500


func _restart_infinite_monster_wave() -> void:
	Global.llbt_level = 25
	Global.infinite_level_multiplier = 0.0
	monster_list()
	current_stage = 1
	can_exit = false
	exit.visible = false
	exit_2.disabled = true
	print("无限模式刷新小怪波次，当前实际层数固定为: ", Global.llbt_level)


func _on_create_control_timeout() -> void:
	if _role != null:
		current_stage = 1

	if check_can_create(current_stage):
		level_create_monster(current_stage)


func monster_list():
	if Global.llbtwxms:
		monster_group = {
			"stage_1":
			[
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99,
				97,
				98,
				99
			],
			"stage_2": [],
			"stage_3": [],
			"stage_4": [],
		}
		monster_position_x = {
			"stage_1":
			[
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
				250,
				500,
				750,
			],
			"stage_2": [],
			"stage_3": [],
			"stage_4": [],
		}
		monster_position_y = {
			"stage_1":
			[
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
				220,
				420,
				420,
				220
			],
			"stage_2": [],
			"stage_3": [],
			"stage_4": [],
		}
		return
	match Global.llbt_level:
		6:
			monster_group = {
				"stage_1": [100],
				"stage_2": [],
				"stage_3": [],
				"stage_4": [],
			}
			monster_position_x = {
				"stage_1": [850],
				"stage_2": [],
				"stage_3": [],
				"stage_4": [],
			}
			monster_position_y = {
				"stage_1": [425],
				"stage_2": [],
				"stage_3": [],
				"stage_4": [],
			}
			return
		12:
			monster_group = {
				"stage_1": [101],
				"stage_2": [],
				"stage_3": [],
				"stage_4": [],
			}
			monster_position_x = {
				"stage_1": [850],
				"stage_2": [],
				"stage_3": [],
				"stage_4": [],
			}
			monster_position_y = {
				"stage_1": [425],
				"stage_2": [],
				"stage_3": [],
				"stage_4": [],
			}
			return
		18:
			monster_group = {
				"stage_1": [102],
				"stage_2": [],
				"stage_3": [],
				"stage_4": [],
			}
			monster_position_x = {
				"stage_1": [850],
				"stage_2": [],
				"stage_3": [],
				"stage_4": [],
			}
			monster_position_y = {
				"stage_1": [425],
				"stage_2": [],
				"stage_3": [],
				"stage_4": [],
			}
			return
		24:
			monster_group = {
				"stage_1": [103],
				"stage_2": [],
				"stage_3": [],
				"stage_4": [],
			}
			monster_position_x = {
				"stage_1": [850],
				"stage_2": [],
				"stage_3": [],
				"stage_4": [],
			}
			monster_position_y = {
				"stage_1": [425],
				"stage_2": [],
				"stage_3": [],
				"stage_4": [],
			}
			return

	monster_group = {
		"stage_1":
		[
			97,
			98,
			99,
			97,
			98,
			99,
			97,
			98,
			99,
			97,
			98,
			99,
			97,
			98,
			99,
			97,
			98,
			99,
			97,
			98,
			99,
			97,
			98,
			99,
			97,
			98,
			99,
			97,
			98,
			99,
			97,
			98,
			99,
			97,
			98,
			99,
			97,
			98,
			99,
			97,
			98,
			99,
			97,
			98,
			99,
			97,
			98,
			99,
			97,
			98,
			99,
			97,
			98,
			99,
			97,
			98,
			99,
			97,
			98,
			99,
			97,
			98,
			99,
			97,
			98,
			99,
			97,
			98,
			99,
			97,
			98,
			99,
			97,
			98,
			99,
		],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_x = {
		"stage_1":
		[
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
			250,
			500,
			750,
		],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
	monster_position_y = {
		"stage_1":
		[
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
			220,
			420,
			420,
			220
		],
		"stage_2": [],
		"stage_3": [],
		"stage_4": [],
	}
