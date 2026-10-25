extends BaseObject
class_name BaseHero
var hd: int = 0
var shield_timer: Timer = null
var wdsl_damage_reduction: float = 0.0
var dikong_field_invincible_count: int = 0

var smsrsz_timer: Timer
const SMSR_SHENQI_LIGHTNING_EFFECT := preload("res://Script/hero/smsr_shenqi_lightning_effect.gd")
const ZLWSZ_GEAR_SCENE := preload("res://Scene/hero/zlw_shenqi_gear_bullet.tscn")
const MOUNT_RUNTIME_SCRIPT := preload("res://Script/mount/mount_runtime.gd")
const MAIN_SWORD_ARRAY_WEAPON_SCENE_PATH := "res://Scene/magic_weapon/main_sword_array_weapon.tscn"
const XIANYU_WING_PATHS := {
	"res://Script/hero/role1.gd": "res://Art/hero_picture/wings/xyzy/role1.tres",
	"res://Script/hero/role_2.gd": "res://Art/hero_picture/wings/xyzy/role2.tres",
	"res://Script/hero/role_3.gd": "res://Art/hero_picture/wings/xyzy/role3.tres",
	"res://Script/hero/role_4.gd": "res://Art/hero_picture/wings/xyzy/role4.tres",
	"res://Script/hero/role_5.gd": "res://Art/hero_picture/wings/xyzy/role5.tres",
	"res://Script/hero/ne_zha_hero.gd": "res://Art/hero_picture/wings/xyzy/role6.tres",
}
const HUAHAO_WING_FRAME_DIR := "res://Art/hero_picture/wings/hhyq"
var zlwsz_shenqi_timer: Timer
var zlwsz_shenqi_gears: Array = []
var zcld_level: int = 0
var has_smsrsz_fashion: bool = false
var current_fashion_quality: String = ""
var was_ws_state: bool = false
var _last_fashion_name := ""
var _last_fashion_power: int = -1
var _last_fashion_max_hp: int = -1
var _fashion_values_initialized := false
var _last_title_name := ""
var _last_archive_name := ""
var _last_hero_formation := ""
var _last_hero_formation_level: int = -1
var _last_wings_name := ""
var _active_magic_weapon_name := ""
var _wings_base_position := Vector2.ZERO
var _wings_base_offset := Vector2.ZERO
var _wings_base_rotation := 0.0
var _wings_base_scale := Vector2.ONE
var _wings_base_flip_h := false
var _wings_base_transform_initialized := false
var _static_wing_tracks_disabled := false
var _static_wing_track_states: Array[Dictionary] = []
var _xyzy_wing_flip_tracks_disabled := false
var _xyzy_wing_flip_track_states: Array[Dictionary] = []
var _sword_array_sync_elapsed := 0.0
var _auto_battle_elapsed := 0.0
var _auto_battle_skill_cursor := 0
var _auto_battle_skill_cast_counts: Dictionary = {}
var _auto_battle_target: Variant = null
var _auto_battle_target_search_elapsed := 0.0
var _auto_battle_jump_elapsed := 0.0
const AUTO_BATTLE_INTERVAL := 0.22
const AUTO_BATTLE_TARGET_SEARCH_INTERVAL := 0.15
const AUTO_BATTLE_TARGET_SEARCH_RANGE := 1800.0
const AUTO_BATTLE_ATTACK_RANGE := 260.0
const AUTO_BATTLE_JUMP_COOLDOWN := 0.8
const AUTO_BATTLE_MOVE_SPEED_SCALE := 1.0
## 松开跳跃键时保留的向上速度比例；越小点按跳得越低，长按不受影响。
const JUMP_RELEASE_SPEED_SCALE := 0.75

var temp_def_bonus: int = 0
var temp_mdef_bonus: int = 0
var temp_max_hp_bonus_rate: float = 0.0
var temp_power_bonus_rate: float = 0.0
var mount_speed_multiplier: float = 1.0
var islljy: bool = false
var is_yx_buff: bool = false
var yx_buff_power_rate: float = 0.0
var yx_buff_crit_rate: float = 0.0
var yx_buff_lucky_rate: float = 0.0

var is_magic_drain: bool = false
var stored_mp: int = 0
var is_san_xian_hu_ti_used: bool = false

@onready var zhen_fa: Timer = $ZhenFa
@onready var effect_body: Node2D = $Action/EffectBody

@onready var role_action_player: AnimationPlayer = $RolePlayer
@onready var base_damagebox: Node2D = $base_damagebox
@onready var damage_text: Node2D = $Damage_Text
@onready var pz: CollisionShape2D = $pz
@onready var action: Node2D = $Action
@onready var ws_timer = $WSTimer
@onready var magic_weapon: Node2D = $MagicWeapon
@onready var my_hurt_box = $base_damagebox/HurtBox/HurtBox
@onready var _name: Label = $Name_
@onready var role_body: Sprite2D = $Action/RoleBody
@onready var role_eq: Sprite2D = $Action/RoleEquipment
@onready var bullet = $Bullet
@onready var wings: AnimatedSprite2D = $Action/Wings
@onready var buff: Node = $Buff
@onready var role_equipment: Sprite2D = $Action/RoleEquipment
@onready var tx: AnimatedSprite2D = $tx
@onready var toukui: AnimatedSprite2D = $Action/EffectBody/toukui
@onready var jianjia: AnimatedSprite2D = $Action/EffectBody/jianjia
@onready var huwan: AnimatedSprite2D = $Action/EffectBody/huwan
@onready var shenti: AnimatedSprite2D = $Action/EffectBody/shenti
@onready var yaodai: AnimatedSprite2D = $Action/EffectBody/yaodai
@onready var xiabai: AnimatedSprite2D = $Action/EffectBody/xiabai
@onready var wuqi: AnimatedSprite2D = $Action/EffectBody/wuqi

var xrbl: float
var is_xr: bool
var tszzs: float
var role5_bt: bool
var can_move_when_use_skill: bool
var tszbsjm: float
var slzjs: float
var slzjs2: float
var zhen_fa_cd: float
var istsz: bool
var canglongremove: bool
var sxyr_cannot_cure: bool
var my_shallow: Role2Shallow
var is_double_fall_pro: bool
var is_indestructible: bool
var is_indestructible1: bool = false
var ran_num = randi_range(0, 100)
var onfloor: bool
var super_armor_active: bool
var is_scary: bool
var is_defe_reduce: bool
var is_death: bool = false
var _taiji_bagua_revived: bool = false
var _taiji_bagua_protection_until: int = 0
var defe_reduce: float
var new_position: float
var old_position: float
var old_is_check: bool
var is_t_mc: bool
var is_sd_buff: bool
var idle_count: int = 0
var is_in_sky: bool = false
var cure_value: float = 1
var is_use_smb = false
var c_ure_cure_count: int = 0
var is_silent: bool
var is_bound_to_the_ground: bool
var is_jdy: bool
var is_cure_hp: bool
var cure_hp_value: int
var skill_clam: float
var player_dir: bool = false
var is_fabao_jiasu: bool = false
var _fabao_jiasu_base_speed: int = 240
var max_protect: float = 175
const ROLE_PROTECT_DURATION: float = 3.5
const WHITE_BAR_ARMOR_DURATION: float = 7.5
var white_bar_armor_time_left: float = 0.0
var current_protect: float = 0.0
var mg_target
var main_sword_array_target: Node2D
var _last_main_sword_array_id: String = ""
var lyfb_calm: float
var slz_calm: float
var hmz_calm: float
var is_stun = false
var is_jump = false
var _jump_release_cut_armed: bool = false
var is_speed_down: bool
var get_action = "wait"
var is_immobilize = false
var need_protect = false
var need_remove_protect = false
var _hit_reaction_generation: int = 0
var _pending_hit_stiff_seconds: Array[float] = []
var is_blood_fix: bool = false
var life_mana_lock: bool = false
var is_wdzt: bool
var smb1
var isslz: bool

var hit_dic = {"power": 0, "hurtBack": [0, 0], "attackKind": "real"}
var role1_skill_inter = {
	"slz": 0,
	"hytj": 0,
	"lys": 0,
	"lyfb": 0,
	"hmz": 0,
	"hmz_ws": 0,
	"hyjj_ws": 0,
	"hyjj": 0,
	"jdy": 0,
	"qsez": 0,
	"zz": 0,
	"gsrs": 0,
	"jdy2": 0,
	"blb": 0,
	"xbz": 0,
	"shy": 0,
	"tjgl": 0,
	"smb": 0,
	"sgq": 0,
	"myhc": 0,
	"jhsj": 0,
	"jgz": 0,
	"by": 0,
	"zfjg": 0,
	"sd": 0,
	"ssp": 0,
	"jsp": 0,
	"dgq": 0,
	"xgq": 0,
	"tmc": 0,
	"syzq": 0,
	"dj": 0,
	"zznh": 0,
	"bdqk": 0,
	"qlj": 0,
	"dcj": 0,
	"wdzt": 0,
	"tkj": 0,
	"mmw": 0,
	"jdz": 0,
	"lhsq": 0,
	"zq": 0,
	"wdww": 0,
	"bylt": 0,
	"cmly": 0,
	"slq": 0,
	"blq": 0,
	"cxq": 0,
	"llrd": 0,
	"lljy": 0,
	"tllz": 0,
	"ygth": 0,
	"xyq": 0,
	"fhf": 0,
	"ltjz": 0
}
var role1_skill_max_inter = {
	"slz": 0,
	"hytj": 0,
	"lys": 0,
	"lyfb": 0,
	"hmz": 0,
	"hmz_ws": 0,
	"hyjj_ws": 0,
	"hyjj": 0,
	"jdy": 0,
	"qsez": 0,
	"zz": 0,
	"gsrs": 0,
	"blb": 0,
	"xbz": 0,
	"shy": 0,
	"tjgl": 0,
	"smb": 0,
	"sgq": 0,
	"myhc": 0,
	"jhsj": 0,
	"jgz": 0,
	"by": 0,
	"zfjg": 0,
	"sd": 0,
	"ssp": 0,
	"jsp": 0,
	"dgq": 0,
	"xgq": 0,
	"tmc": 0,
	"syzq": 0,
	"dj": 0,
	"zznh": 0,
	"bdqk": 0,
	"qlj": 0,
	"dcj": 0,
	"wdzt": 0,
	"tkj": 0,
	"mmw": 0,
	"jdz": 0,
	"lhsq": 0,
	"zq": 0,
	"wdww": 0,
	"bylt": 0,
	"cmly": 0,
	"slq": 0,
	"blq": 0,
	"cxq": 0,
	"llrd": 0,
	"lljy": 0,
	"tllz": 0,
	"ygth": 0,
	"xyq": 0,
	"fhf": 0,
	"ltjz": 0
}
var hit_name: String
var is_call = false
var _last_role_hit_effect_msec: int = 0


func _ready() -> void:
	RoleProp.source_player = self

	_capture_wings_base_transform()
	call_deferred("_scan_late_static_wing_tracks")

	walk_speed = 240
	PlayerData.enforce_level_caps()
	RoleProp.baseroleprop.Level = PlayerData.player_data.玩家等级
	RoleProp.baseroleprop.exp = PlayerData.player_data.玩家当前经验
	RoleProp.set_basic_prop()
	RoleProp.set_full_hp()
	RoleProp.set_full_mp()
	_ensure_title_animation("htd", "res://Art/all_tx/htd.png")
	_ensure_title_animation("ymqzq", "res://Art/all_tx/ymqzq.png")
	add_tx()
	call_deferred("_load_equipped_magic_weapon_deferred")
	call_deferred("_load_main_sword_array_weapon_deferred")
	call_deferred("_attach_mount_runtime")


func _attach_mount_runtime() -> void:
	var current_scene := get_tree().current_scene
	if current_scene == null or not str(current_scene.scene_file_path).contains("/level/"):
		return
	if get_node_or_null("MountRuntime") != null:
		return
	var mount_runtime := Node.new()
	mount_runtime.name = "MountRuntime"
	mount_runtime.set_script(MOUNT_RUNTIME_SCRIPT)
	add_child(mount_runtime)
	mount_runtime.call("setup", self)


func _exit_tree() -> void:
	if RoleProp.source_player == self:
		RoleProp.source_player = null
	set_process(false)
	set_physics_process(false)
	_auto_battle_target = null
	_auto_battle_skill_cast_counts.clear()
	_auto_battle_skill_cursor = 0
	_auto_battle_elapsed = 0.0
	_clear_visual_resources(self)


func fabao_jiasu() -> void:
	if is_fabao_jiasu:
		return
	is_fabao_jiasu = true
	_fabao_jiasu_base_speed = maxi(1, walk_speed)
	walk_speed = _fabao_jiasu_base_speed * 2


func reset_fabao_jiasu() -> void:
	if not is_fabao_jiasu:
		return
	is_fabao_jiasu = false
	walk_speed = maxi(1, _fabao_jiasu_base_speed)


func _clear_visual_resources(node: Node) -> void:
	if node is AnimatedSprite2D:
		var animated_sprite := node as AnimatedSprite2D
		animated_sprite.stop()
		animated_sprite.sprite_frames = null
	elif node is Sprite2D:
		var sprite := node as Sprite2D
		sprite.texture = null
	for child in node.get_children():
		_clear_visual_resources(child)


func _load_main_sword_array_weapon_deferred() -> void:
	var tree := get_tree()
	if tree == null:
		return
	await tree.process_frame
	await tree.process_frame
	if not is_inside_tree() or is_queued_for_deletion():
		return
	_sync_main_sword_array_weapon()


func _load_equipped_magic_weapon_deferred() -> void:
	var tree := get_tree()
	if tree == null:
		return
	await tree.process_frame
	await tree.process_frame
	if not is_inside_tree() or is_queued_for_deletion():
		return
	var equipped_weapon = PlayerData.player_data.get("实战法宝", "")
	if str(equipped_weapon) == "" and PlayerData.player_data.get(DataKeys.MAGIC_WEAPON, []).size() > 0:
		equipped_weapon = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0].get(DataKeys.NAME, "")
	await Global.prepare_magic_weapon_resources(equipped_weapon)
	if not is_inside_tree() or is_queued_for_deletion():
		return
	add_magic_weapon()


func _add_role_hit_effect_throttled() -> void:
	var now := Time.get_ticks_msec()
	if now - _last_role_hit_effect_msec < 55:
		return
	_last_role_hit_effect_msec = now
	Global.add_special_effect(self, Vector2(0, 0), "RoleBeHit", Vector2(1, 1), false, 1)


func null_szfb_case():
	if PlayerData.player_data["实战法宝"] == "":
		if mg_target != null:
			mg_target.queue_free()
		if PlayerData.player_data[DataKeys.MAGIC_WEAPON].size() != 0:
			add_magic_weapon()


func on_szfb_change():
	if is_instance_valid(mg_target) and _active_magic_weapon_name != str(PlayerData.player_data.get("实战法宝", "")):
		mg_target.queue_free()
		if PlayerData.player_data[DataKeys.MAGIC_WEAPON].size() != 0:
			add_magic_weapon()


func check_remove_or_add_fb():
	if PlayerData.player_data[DataKeys.MAGIC_WEAPON].size() == 0:
		if mg_target != null:
			mg_target.queue_free()
	else:
		if mg_target == null:
			add_magic_weapon()


func _sync_main_sword_array_weapon() -> void:
	if not is_inside_tree() or is_queued_for_deletion():
		return
	if PlayerData.has_method("ensure_main_sword_array"):
		PlayerData.ensure_main_sword_array()
	var active := str(PlayerData.player_data.get("主线剑阵出战", ""))
	if (
		active != ""
		and PlayerData.has_method("can_main_sword_array_battle")
		and not PlayerData.can_main_sword_array_battle(active)
	):
		PlayerData.player_data["主线剑阵出战"] = ""
		active = ""
	if active == "":
		_last_main_sword_array_id = ""
		if is_instance_valid(main_sword_array_target):
			main_sword_array_target.queue_free()
		main_sword_array_target = null
		return
	if is_instance_valid(main_sword_array_target):
		if _last_main_sword_array_id != active:
			main_sword_array_target.set_sword_id(active)
			_last_main_sword_array_id = active
		return
	var scene_parent := get_parent()
	if scene_parent == null or not is_instance_valid(scene_parent):
		return
	var parent := scene_parent.get_parent()
	if parent == null or not is_instance_valid(parent) or parent.is_queued_for_deletion():
		return
	var sword_array_scene := Global.load_scene_uncached(MAIN_SWORD_ARRAY_WEAPON_SCENE_PATH)
	if sword_array_scene == null:
		return
	main_sword_array_target = sword_array_scene.instantiate()
	main_sword_array_target.sword_id = active
	main_sword_array_target.player = self
	parent.add_child(main_sword_array_target)
	main_sword_array_target.position = position + (Vector2(-170, -190) if player_dir else Vector2(170, -190))
	_last_main_sword_array_id = active


func use_fb():
	if mg_target == null or not is_instance_valid(mg_target) or mg_target.is_queued_for_deletion():
		return
	if not mg_target.has_method("enough_mp"):
		return
	if bool(mg_target.call("enough_mp")) and bool(mg_target.get("is_canuse")):
		mg_target.set("is_use", true)


func ws_skill() -> bool:
	var fashion_list: Variant = PlayerData.player_data.get(DataKeys.FASHION, [])
	if not fashion_list is Array or fashion_list.is_empty():
		return true
	var fashion: Variant = fashion_list[0]
	if not fashion is Dictionary:
		return true
	var fashion_id := str(fashion.get(DataKeys.NAME, ""))
	var sz_name: String = str(Global.get_clean_name(fashion_id))
	var pz := fashion_id.split(sz_name)[0]
	if pz == "putong":
		return true
	match sz_name:
		"ttzssz":
			if not obj_attack_dict.has("ttzs"):
				return true
			add_ttzs_effect()
		"nmwsz":
			if not obj_attack_dict.has("nmw"):
				return true
			addnmw_effect()
		"zlwsz":
			if not obj_attack_dict.has("zlw"):
				return true
			addzlw_effect()
			if pz == "shenqi":
				startzlw_shenqi_effect()
		"smsrsz":
			if not obj_attack_dict.has("smsr"):
				return true
			if smsrsz_timer == null:
				smsrsz_timer = Timer.new()
				add_child(smsrsz_timer)
				smsrsz_timer.timeout.connect(_on_smsrsz_timer_timeout)
			if pz == "shenqi":
				addsmsr_shenqi_lightning_round()
			else:
				addsmsr_effect()
			smsrsz_timer.start(1.0)

			if pz == "shishi" or pz == "xieling":
				Global.add_buff(
					self.buff,
					{
						"Name": "no_debuff",
						"AddTime": 5.0,
						"reduce_interval": 0,
						"value": 0,
						"AttackKind": "",
						"CanRemove": true,
						"DeBuff": false,
						"CanAdd": false
					}
				)
			elif pz == "hunqi" or pz == "chuanshuo":
				for child in self.buff.get_children():
					if child is BaseBuff and child.buff_info.get("DeBuff", false):
						child.queue_free()

				Global.add_buff(
					self.buff,
					{
						"Name": "no_debuff",
						"AddTime": 5.0,
						"reduce_interval": 0,
						"value": 0,
						"AttackKind": "",
						"CanRemove": true,
						"DeBuff": false,
						"CanAdd": false
					}
				)
		_:
			return true
	return true


func _on_smsrsz_timer_timeout():
	if not RoleProp.is_ws_state:
		smsrsz_timer.stop()
		return
	if has_smsrsz_fashion and current_fashion_quality == "shenqi":
		addsmsr_shenqi_lightning_round()
	else:
		addsmsr_effect()


func _physics_process(delta: float) -> void:
	white_bar_armor_time_left = maxf(0.0, white_bar_armor_time_left - delta)
	_enforce_white_bar_control_immunity()
	_sword_array_sync_elapsed += delta
	_auto_battle_target_search_elapsed += delta
	_auto_battle_jump_elapsed += delta
	jsfzsy()
	use_zhen_fa()
	set_wings_offset()
	process_san_xian_hu_ti_effect()

	if islljy:
		velocity.x = 0

	if not sxyr_cannot_cure:
		if PlayerData.check_eq_zb("头衔", "sxyr"):
			sxyr_cannot_cure = true

	if not is_san_xian_hu_ti_used and PlayerData.check_eq_zb("饰品", "huayan"):
		var hp_percent = float(RoleProp.roleprop.Hp) / float(RoleProp.roleprop.SHp) * 100

		if hp_percent <= 20.0:
			is_san_xian_hu_ti_used = true

			var sxht_buff_info = {
				"Name": "SanXianHuTi",
				"value": 0.1,
				"AddTime": 20.0,
				"reduce_interval": 1.0,
				"AttackKind": "cure",
				"CanRemove": true,
				"CanAdd": false,
				"DeBuff": false,
				"SpecialEffectAddInterval": 1.0
			}
			Global.add_buff(self.buff, sxht_buff_info)

	for i in role1_skill_inter:
		if role1_skill_inter[i] > 0:
			role1_skill_inter[i] -= 0.1
	if MainSet.set_data["NotShowRoleBody"]:
		role_body.visible = false
		$Action/Wings.visible = false
		$Action/Wings.modulate = Color(1, 1, 1, 0)
	else:
		if not PlayerData.player_data["翅膀显示"]:
			$Action/Wings.visible = false
			$Action/Wings.modulate = Color(1, 1, 1, 0)

	if PlayerData.player_data["头衔显示"]:
		tx.visible = true
	else:
		tx.visible = false
	if MainSet.set_data["NotShowRoleEQ"]:
		role_equipment.visible = false
	if is_death:
		return
	_update_fashion_values_if_needed()
	_process_auto_battle(delta)
	add_tx()
	if RoleProp.ws_value >= RoleProp.max_ws_value:
		if PlayerInput.is_action_just_pressed("无双"):
			if not RoleProp.is_ws_state and ws_skill():
				RoleProp.is_ws_state = true
	if cure_value >= 4:
		cure_value = 4
	if is_on_floor():
		if not onfloor:
			new_position = self.position.y
			old_is_check = false

		onfloor = true
	if not is_on_floor():
		onfloor = false
	if not old_is_check:
		if velocity.y > 0:
			old_position = self.position.y
			old_is_check = true
	if velocity.y <= 0:
		old_is_check = false
	improve_self_recovery_when_idle()
	check_add_buff()

	if action.scale.x == -1:
		player_dir = true
	else:
		player_dir = false
	var archive_number := int(MemoryClass.get_cd_number())
	var archive_name: String
	if LocalCoop.is_enabled() and (PlayerData.player_data.has("角色昵称") or LocalCoop.slot_for(self) == 2):
		archive_name = str(PlayerData.player_data.get("角色昵称", ""))
	elif archive_number <= 6:
		archive_name = str(MainSet.set_data["name" + str(archive_number)])
	else:
		archive_name = str(MainSet.set_data["其他存档"][str(archive_number)]["name"])
	if archive_name != _last_archive_name:
		_last_archive_name = archive_name
		_name.text = archive_name

	self_protect()
	RoleProp.directon = player_dir
	null_szfb_case()
	on_szfb_change()
	check_remove_or_add_fb()
	if _sword_array_sync_elapsed >= 0.25:
		_sword_array_sync_elapsed = 0.0
		_sync_main_sword_array_weapon()

	if mg_target != null and "is_zcld" in mg_target and mg_target.is_zcld:
		zcld_level = mg_target.fb_level
	else:
		zcld_level = 0

	if RoleProp.is_ws_state:
		if ws_timer.is_stopped():
			ws_timer.start(0.1)

	if (
		PlayerInput.is_action_just_pressed("down")
		and not has_meta("disable_down_drop")
		and not is_using_skills
		and not is_attacking
	):
		set_collision_mask_value(6, false)
		await get_tree().create_timer(0.5).timeout
		set_collision_mask_value(6, true)

		if not is_using_skills and not is_attacking and not is_death:
			get_action = "down"
	if death() and not is_death:
		is_death = true
		LocalCoop.clear_player_buffs(self)
		is_ice = false
		is_stun = false
		is_immobilize = false
		is_scary = false
		velocity.x = 0
		velocity.y = 0
		get_action = "death"
		role_action_player.play("death")

		set_process_input(false)
		set_process_unhandled_input(false)
		await get_tree().create_timer(1.5).timeout
		if not LocalCoop.is_enabled() or LocalCoop.all_players_dead():
			Global.change_scene("res://Scene/level/defeat.tscn")
		return
	RoleProp.up_level()
	RoleProp.role_pos_x = position.x
	RoleProp.role_pos_y = position.y
	RoleProp.role_pos = position
	remove_hit_data()
	if not is_on_floor():
		if self is Role1Hero:
			hit_count = 0
		elif self is Role3Hero:
			hit_count = 1
		elif self is Role4Hero:
			hit_count = 1
		elif self is Role5Hero:
			hit_count = 4
		velocity.y -= gravity * delta
	if is_on_floor() and velocity.y == 0:
		jump_count = 0
		_jump_release_cut_armed = false
	if check_can_wait():
		_play_locomotion_animation(&"wait")
		get_action = "wait"

	if not no_limit_buff() and not is_death:
		is_in_sky = false
		if not is_t_mc:
			if not is_scary:
				velocity.x = 0
				role_action_player.play("hurt")
			else:
				if is_scary:
					when_scary()
	if PlayerInput.is_action_pressed("MagicWeapon"):
		if not get_parent().get_parent() is Level17 and not get_parent().get_parent() is Level22:
			if mg_target != null:
				if mg_target is GhostDoll:
					use_fb()
				else:
					if no_limit_buff():
						use_fb()
	if is_immobilize:
		velocity = Vector2(0, 0)
	if not no_limit_buff():
		if has_method("_cancel_skill_for_control"):
			call("_cancel_skill_for_control")
		is_using_skills = false
	var mount_runtime := get_node_or_null("MountRuntime")
	if mount_runtime != null and bool(mount_runtime.call("process_mounted_control", delta)):
		pass
	elif no_limit_buff():
		if is_t_mc:
			if self is Role3Hero:
				if PlayerInput.is_action_pressed("slz"):
					get_skill("tmc2")
				if PlayerInput.is_action_pressed("lys"):
					get_skill("tmc2")
				if PlayerInput.is_action_pressed("lyfb"):
					get_skill("tmc2")
				if PlayerInput.is_action_pressed("hmz"):
					get_skill("tmc2")
				if PlayerInput.is_action_pressed("hytj"):
					get_skill("tmc2")
			else:
				if can_normal_control():
					noarmal_control()
		else:
			if can_normal_control():
				noarmal_control()

	if was_ws_state and not RoleProp.is_ws_state and smsrsz_timer != null:
		smsrsz_timer.stop()

	was_ws_state = RoleProp.is_ws_state

	if int(get_meta("coop_slot", 1)) == 1:
		Global.player_dir = player_dir
	move_and_slide()


func _process(_delta: float) -> void:
	set_wings_offset()


func process_san_xian_hu_ti_effect():
	if buff == null:
		return

	var sxht_buff = null

	var buff_child_count := buff.get_child_count()
	var buff_child_index := 0
	while buff_child_index < buff_child_count:
		var i = buff.get_child(buff_child_index)
		buff_child_index += 1
		if i != null and i is BaseBuff and i.buff_info["Name"] == "SanXianHuTi":
			sxht_buff = i
			break

	if sxht_buff == null:
		return

	var buff_data = sxht_buff.buff_info
	var heal_rate = buff_data.get("value", 0.05)

	var frame_heal_rate = heal_rate / 30.0

	var max_hp = RoleProp.roleprop.SHp
	var max_mp = RoleProp.roleprop.SMp

	var heal_hp = max(1, int(max_hp * frame_heal_rate))
	var heal_mp = max(1, int(max_mp * frame_heal_rate))

	cure_hp(heal_hp)
	cure_mp(heal_mp)

	if RoleProp.roleprop.Hp >= max_hp and RoleProp.roleprop.Mp >= max_mp:
		sxht_buff.queue_free()


func can_normal_control():
	if not self is Role5Hero:
		if is_attacking == false and is_be_attacking == false and is_using_skills == false and not death():
			return true
	else:
		if can_move_when_use_skill:
			if not death():
				return true
		else:
			if is_attacking == false and is_be_attacking == false and is_using_skills == false and not death():
				return true
	return false


func noarmal_control():
	if is_use_smb:
		return

	if MainSet.is_auto_battle_enabled() and not _is_auto_battle_skill_only():
		_process_auto_battle_movement()
		return

	if not islljy:
		if not self is Role5Hero:
			nor_mal_move()
		else:
			if can_move_when_use_skill:
				var _direction = PlayerInput.get_axis("move_left", "move_right")

				if is_reverse_move:
					_direction = -_direction

				if _direction:
					velocity.x = _direction * walk_speed * 0.7 * reverse_move_speed_multiplier * mount_speed_multiplier
				else:
					velocity.x = move_toward(velocity.x, 0, walk_speed * 0.7 * reverse_move_speed_multiplier)
			else:
				nor_mal_move()

	if PlayerInput.is_action_just_pressed("jump"):
		if not is_bound_to_the_ground:
			jump()
	if PlayerInput.is_action_just_released("jump"):
		_cut_jump_on_release()
	if PlayerInput.is_action_pressed("slz") and not is_using_skills:
		var skill_name = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能键位"]["Y"]
		get_skill(skill_name)
	if PlayerInput.is_action_pressed("lys") and not is_using_skills:
		var skill_name = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能键位"]["U"]
		get_skill(skill_name)
	if PlayerInput.is_action_pressed("lyfb") and not is_using_skills:
		var skill_name = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能键位"]["I"]
		get_skill(skill_name)
	if PlayerInput.is_action_pressed("hmz") and not is_using_skills:
		var skill_name = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能键位"]["O"]
		get_skill(skill_name)
	if PlayerInput.is_action_pressed("hytj") and not is_using_skills:
		var skill_name = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能键位"]["L"]
		get_skill(skill_name)


func _process_auto_battle(delta: float) -> void:
	if is_queued_for_deletion():
		return
	if not MainSet.is_auto_battle_enabled():
		_auto_battle_elapsed = 0.0
		_auto_battle_target = null
		_auto_battle_target_search_elapsed = 0.0
		_auto_battle_skill_cursor = 0
		_auto_battle_skill_cast_counts.clear()
		return
	if is_death:
		return
	if not is_inside_tree() or get_tree().current_scene == null:
		return
	_process_auto_battle_equipment()
	if _try_auto_battle_wushuang():
		return
	if is_silent or is_using_skills or is_attacking or is_be_attacking:
		return
	if is_stun or is_ice or is_immobilize:
		return
	_auto_battle_elapsed += delta
	if _auto_battle_elapsed < AUTO_BATTLE_INTERVAL:
		return
	_auto_battle_elapsed = 0.0

	if not _is_auto_battle_skill_only():
		var target: Variant = _get_auto_battle_target()
		if target == null or not _is_auto_battle_target_in_attack_range(target):
			return

	var skill_entries := _get_auto_battle_skill_entries()
	if skill_entries.is_empty():
		_auto_battle_skill_cursor = 0
		_auto_battle_skill_cast_counts.clear()
		return
	if _auto_battle_skill_cursor >= skill_entries.size():
		_auto_battle_skill_cursor = 0
	var configured_ids: Array[String] = []
	for entry in skill_entries:
		configured_ids.append(str(entry.get("id", "")))
	for skill_id in _auto_battle_skill_cast_counts.keys():
		if str(skill_id) not in configured_ids:
			_auto_battle_skill_cast_counts.erase(skill_id)
	for offset in range(skill_entries.size()):
		var index := (_auto_battle_skill_cursor + offset) % skill_entries.size()
		var entry: Dictionary = skill_entries[index]
		var skill_id := str(entry.get("id", ""))
		if _is_auto_battle_skill_active(skill_id):
			_auto_battle_skill_cast_counts.erase(skill_id)
			_auto_battle_skill_cursor = (index + 1) % skill_entries.size()
			continue
		if not _can_auto_battle_use_skill(skill_id):
			continue
		var mp_before := int(RoleProp.roleprop.Mp)
		var cooldown_before := float(role1_skill_inter.get(skill_id, 0.0))
		var action_before: String = str(get_action)
		var using_skill_before := is_using_skills
		if not is_inside_tree() or get_tree().current_scene == null:
			return
		get_skill(skill_id)
		var cooldown_after := float(role1_skill_inter.get(skill_id, 0.0))
		var skill_cast_started := (
			cooldown_after > cooldown_before + 0.001
			or int(RoleProp.roleprop.Mp) < mp_before
			or is_using_skills != using_skill_before
			or get_action != action_before
		)
		if not skill_cast_started:
			continue
		var cast_count := int(_auto_battle_skill_cast_counts.get(skill_id, 0)) + 1
		var required_count := maxi(1, int(entry.get("count", 1)))
		if cast_count >= required_count:
			_auto_battle_skill_cast_counts.erase(skill_id)
			_auto_battle_skill_cursor = (index + 1) % skill_entries.size()
		else:
			_auto_battle_skill_cast_counts[skill_id] = cast_count
			_auto_battle_skill_cursor = index
		return


func _is_auto_battle_skill_only() -> bool:
	return bool(MainSet.set_data.get("AutoBattleSkillOnly", false))


func _process_auto_battle_equipment() -> void:
	if bool(MainSet.set_data.get("AutoBattleMagicWeapon", false)):
		_try_auto_battle_magic_weapon()
	if bool(MainSet.set_data.get("AutoBattleSwordArray", false)) and zhen_fa_cd <= 0:
		_try_use_main_sword_array()


func _try_auto_battle_magic_weapon() -> bool:
	if mg_target == null or not is_instance_valid(mg_target) or mg_target.is_queued_for_deletion():
		return false
	if _is_magic_weapon_disabled_in_current_level():
		return false
	if bool(mg_target.get("is_use")) or not bool(mg_target.get("is_canuse")):
		return false
	if not mg_target is GhostDoll and not no_limit_buff():
		return false
	use_fb()
	return bool(mg_target.get("is_use"))


func _is_magic_weapon_disabled_in_current_level() -> bool:
	var scene_parent := get_parent()
	if scene_parent == null:
		return false
	var level := scene_parent.get_parent()
	return level is Level17 or level is Level22


func _try_auto_battle_wushuang() -> bool:
	if not bool(MainSet.set_data.get("AutoBattleWushuang", false)):
		return false
	if RoleProp.is_ws_state or RoleProp.ws_value < RoleProp.max_ws_value:
		return false
	if not ws_skill():
		return false
	RoleProp.is_ws_state = true
	return true


func _get_auto_battle_target() -> Variant:
	if (
		is_instance_valid(_auto_battle_target)
		and _is_auto_battle_target_valid(_auto_battle_target)
		and _auto_battle_target_search_elapsed < AUTO_BATTLE_TARGET_SEARCH_INTERVAL
	):
		return _auto_battle_target

	_auto_battle_target_search_elapsed = 0.0
	_auto_battle_target = null
	var candidates: Array = []
	var current_scene := get_tree().current_scene
	if current_scene != null and current_scene.has_method("get_active_monsters"):
		var active_monsters: Variant = current_scene.call("get_active_monsters")
		if active_monsters is Array:
			candidates = active_monsters
	if candidates.is_empty():
		candidates = get_tree().get_nodes_in_group("monsters")

	var best_target: Variant = null
	var best_score := INF
	for candidate in candidates:
		if not _is_auto_battle_target_valid(candidate):
			continue
		var monster := candidate as BaseMonster
		if monster == null:
			continue
		var horizontal_distance := absf(monster.global_position.x - global_position.x)
		var vertical_distance := absf(monster.global_position.y - global_position.y)
		if horizontal_distance > AUTO_BATTLE_TARGET_SEARCH_RANGE:
			continue
		var score := horizontal_distance + vertical_distance * 0.35
		if score < best_score:
			best_score = score
			best_target = monster
	_auto_battle_target = best_target
	return _auto_battle_target


func _is_auto_battle_target_valid(target: Variant) -> bool:
	if target == null or not is_instance_valid(target) or not target is BaseMonster:
		return false
	var monster := target as BaseMonster
	if not monster.is_inside_tree() or monster.is_queued_for_deletion():
		return false
	if monster.hp <= 0 or monster.is_death or monster.no_target:
		return false
	if _is_summon_or_pet_target(monster):
		return false
	if monster.has_method("death") and bool(monster.call("death")):
		return false
	return true


func _get_auto_battle_attack_range() -> float:
	var range_value := AUTO_BATTLE_ATTACK_RANGE
	for skill_entry in _get_auto_battle_skill_entries():
		var skill_id := str(skill_entry.get("id", ""))
		if skill_id in ["hyjj", "hyjj_ws", "nz_yysj"]:
			range_value = maxf(range_value, 420.0)
		elif skill_id in ["lyfb", "hmz", "hmz_ws", "smb", "by", "cmly", "tllz", "ltjz"]:
			range_value = maxf(range_value, 320.0)
	return range_value


func _is_auto_battle_target_in_attack_range(target: Variant) -> bool:
	if not _is_auto_battle_target_valid(target):
		return false
	var monster := target as BaseMonster
	var horizontal_distance := absf(monster.global_position.x - global_position.x)
	var vertical_distance := absf(monster.global_position.y - global_position.y)
	return horizontal_distance <= _get_auto_battle_attack_range() and vertical_distance <= 220.0


func _process_auto_battle_movement() -> void:
	if not MainSet.is_auto_battle_enabled():
		return
	if _is_auto_battle_skill_only():
		_auto_battle_target = null
		velocity.x = 0.0
		_set_auto_battle_idle()
		return
	if is_death or is_silent or is_using_skills or is_attacking or is_be_attacking:
		velocity.x = 0.0
		return
	if not no_limit_buff() or is_bound_to_the_ground:
		velocity.x = 0.0
		return

	var target: Variant = _get_auto_battle_target()
	if not _is_auto_battle_target_valid(target):
		target = null
	var _direction := 1.0
	if target != null and not _is_auto_battle_target_in_attack_range(target):
		var horizontal_delta: float = float((target as BaseMonster).global_position.x - global_position.x)
		if absf(horizontal_delta) > 12.0:
			_direction = signf(horizontal_delta)
		elif target.global_position.y < global_position.y - 50.0:
			_direction = 1.0 if player_dir else -1.0
		else:
			velocity.x = 0.0
			_set_auto_battle_idle()
			return
	elif target != null:
		var target_delta_x: float = float((target as BaseMonster).global_position.x - global_position.x)
		if absf(target_delta_x) > 8.0:
			_set_auto_battle_facing(signf(target_delta_x))
		velocity.x = 0.0
		_set_auto_battle_idle()
		return
	else:
		_direction = 1.0

	_set_auto_battle_facing(_direction)
	if _auto_battle_is_blocked_ahead(_direction):
		_auto_battle_jump_if_blocked()
	if is_attacking or is_be_attacking or is_using_skills:
		velocity.x = 0.0
		return
	velocity.x = (
		_direction
		* walk_speed
		* RoleProp.ws_up_power
		* reverse_move_speed_multiplier
		* AUTO_BATTLE_MOVE_SPEED_SCALE
		* mount_speed_multiplier
	)
	if is_on_floor():
		_play_locomotion_animation(&"run")
		get_action = "run"


func _set_auto_battle_facing(_direction: float) -> void:
	if _direction > 0.0:
		action.scale.x = -1
		base_damagebox.scale.x = -1
		player_dir = true
	elif _direction < 0.0:
		action.scale.x = 1
		base_damagebox.scale.x = 1
		player_dir = false


func _set_auto_battle_idle() -> void:
	if get_action == "run":
		get_action = ""
	if is_on_floor() and not is_attacking and not is_using_skills:
		_play_locomotion_animation(&"wait")


func _auto_battle_is_blocked_ahead(_direction: float) -> bool:
	if not is_on_floor() or _direction == 0.0:
		return false
	var has_obstacle_collision := false
	var has_slide_collision := false
	for index in range(get_slide_collision_count()):
		var collision := get_slide_collision(index)
		if collision == null:
			continue
		has_slide_collision = true
		var slide_collider := collision.get_collider()
		if slide_collider is Node and _find_auto_battle_monster(slide_collider as Node) != null:
			continue
		var normal := collision.get_normal()
		if _direction > 0.0 and normal.x < -0.25:
			has_obstacle_collision = true
		if _direction < 0.0 and normal.x > 0.25:
			has_obstacle_collision = true
	if has_obstacle_collision or (not has_slide_collision and is_on_wall()):
		return true

	var space_state := get_world_2d().direct_space_state
	if space_state == null:
		return false
	var ray_start := global_position + Vector2(0.0, -28.0)
	var ray_end := ray_start + Vector2(_direction * 36.0, 0.0)
	var query := PhysicsRayQueryParameters2D.create(ray_start, ray_end, collision_mask, [get_rid()])
	var hit := space_state.intersect_ray(query)
	if hit.is_empty():
		return false
	var collider: Variant = hit.get("collider")
	if collider is Node:
		var monster := _find_auto_battle_monster(collider as Node)
		if monster != null:
			return false
	return true


func _find_auto_battle_monster(node: Node) -> BaseMonster:
	var current := node
	var depth := 0
	while current != null and is_instance_valid(current) and depth < 8:
		if current is BaseMonster:
			return current as BaseMonster
		current = current.get_parent()
		depth += 1
	return null


func _auto_battle_jump_if_blocked() -> void:
	if _auto_battle_jump_elapsed < AUTO_BATTLE_JUMP_COOLDOWN:
		return
	if not is_on_floor() or is_bound_to_the_ground or is_jump:
		return
	if is_attacking or is_be_attacking or is_using_skills:
		return
	_auto_battle_jump_elapsed = 0.0
	jump(false)


func _get_auto_battle_skills() -> Array:
	var result: Array = []
	for entry in _get_auto_battle_skill_entries():
		result.append(str(entry.get("id", "")))
	return result


func _get_auto_battle_skill_entries() -> Array[Dictionary]:
	var role_id := int(PlayerData.player_data.get("Myself", 1))
	if role_id < 1 or role_id > 7:
		role_id = 1
	var role_key := "角色" + str(role_id)
	var slot := int(get_meta("coop_slot", 1))
	var by_slot_value: Variant = MainSet.set_data.get("AutoBattleSkillsBySlot", {})
	if by_slot_value is Dictionary:
		var slot_skills: Variant = (by_slot_value as Dictionary).get(str(slot), {})
		if slot_skills is Dictionary and (slot_skills as Dictionary).has(role_key):
			return _normalize_auto_battle_skill_entries((slot_skills as Dictionary).get(role_key, []))
	var by_role_value: Variant = MainSet.set_data.get("AutoBattleSkillsByRole", {})
	if by_role_value is Dictionary and (by_role_value as Dictionary).has(role_key):
		var role_skills: Variant = (by_role_value as Dictionary).get(role_key, [])
		return _normalize_auto_battle_skill_entries(role_skills)
	var legacy_skills: Variant = MainSet.set_data.get("AutoBattleSkills", [])
	return _normalize_auto_battle_skill_entries(legacy_skills)


func _normalize_auto_battle_skill_entries(raw_value: Variant) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not raw_value is Array:
		return result
	var seen: Dictionary = {}
	for value in raw_value:
		var skill_id := ""
		var count := 1
		if value is Dictionary:
			var entry: Dictionary = value
			skill_id = str(entry.get("id", entry.get("skill_id", "")))
			count = clampi(int(entry.get("count", 1)), 1, 99)
		else:
			skill_id = str(value)
		if skill_id == "" or seen.has(skill_id):
			continue
		seen[skill_id] = true
		(
			result
			. append(
				{
					"id": skill_id,
					"count": count,
				}
			)
		)
	return result


func _can_auto_battle_use_skill(skill_id: String) -> bool:
	if skill_id == "" or not role1_skill_inter.has(skill_id):
		return false
	if float(role1_skill_inter.get(skill_id, 0.0)) > 0.0:
		return false
	if not has_method("get_need_mp"):
		return false
	var need_mp := int(get_need_mp(skill_id, false))
	return int(RoleProp.roleprop.Mp) >= need_mp


func _is_auto_battle_skill_active(_skill_id: String) -> bool:
	return false


func nor_mal_move():
	var _direction = PlayerInput.get_axis("move_left", "move_right")

	if is_reverse_move:
		_direction = -_direction

	if _direction > 0:
		if check_on_floor() and is_attacking == false and is_be_attacking == false and is_using_skills == false:
			_play_locomotion_animation(&"run")
			get_action = "run"
		action.scale.x = -1
		base_damagebox.scale.x = -1
	elif _direction < 0:
		if check_on_floor() and is_attacking == false and is_be_attacking == false and is_using_skills == false:
			_play_locomotion_animation(&"run")
			get_action = "run"
		action.scale.x = 1
		base_damagebox.scale.x = 1
	else:
		if get_action == "run":
			get_action = ""

	if _direction:
		velocity.x = (
			_direction * walk_speed * RoleProp.ws_up_power * reverse_move_speed_multiplier * mount_speed_multiplier
		)
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed * RoleProp.ws_up_power * reverse_move_speed_multiplier)


func no_limit_buff():
	return not is_ice and not is_stun and not is_eye_fix and not is_death and not is_immobilize and not is_scary


func is_riding_mount() -> bool:
	var runtime := get_node_or_null("MountRuntime")
	return runtime != null and runtime.has_method("is_riding_mount") and bool(runtime.call("is_riding_mount"))


func turn_to_wait():
	if not is_on_floor():
		_play_locomotion_animation(&"wait")


func do_normalhit_1():
	pass


func do_normalhit_2():
	pass


func do_normalhit_3():
	pass


func do_normalhit_4():
	pass


func do_slz():
	pass


func do_zz():
	pass


func do_gsrs():
	pass


func do_lys():
	pass


func do_lyfb():
	pass


func do_hmz_pro():
	pass


func do_hytj():
	pass


func do_hyjj():
	pass


func do_jdy_2():
	pass


func do_jdy():
	pass


func do_qsez():
	pass


func skill_blb():
	pass


func skill_tjgl():
	pass


func skill_xbz():
	pass


func skill_shy():
	pass


func skill_smb():
	pass


func skill_smb2():
	pass


func skill_by():
	pass


func skill_sgq():
	pass


func skill_myhc():
	pass


func skill_jgz():
	pass


func skill_jhsj():
	pass


func skill_sd():
	pass


func skill_zznh():
	pass


func skill_ssp():
	pass


func skill_jsp():
	pass


func skill_dgq():
	pass


func skill_xgq():
	pass


func skill_syzq():
	pass


func skill_dj():
	pass


func skill_tmc2():
	pass


func skill_tmc():
	pass


func skill_bdqk():
	pass


func shovel_qlj():
	pass


func shovel_dcj():
	pass


func shovel_tkj():
	pass


func shovel_mmw():
	pass


func shovel_zq():
	pass


func shovel_wdww():
	pass


func shovel_mbyj():
	pass


func shovel_jdz():
	pass


func shovel_wdzt():
	pass


func use_slq():
	pass


func use_cxq():
	pass


func use_blq():
	pass


func use_xyq():
	pass


func use_llrd():
	pass


func use_lljy():
	pass


func use_tllz():
	pass


func use_ygth():
	pass


func use_fhf():
	pass


func is_can_move_attack_in_sky():
	if is_on_floor() and is_attacking:
		velocity.x = 0


func check_on_floor():
	return velocity.y == 0


func _play_locomotion_animation(animation_name: StringName) -> void:
	if role_action_player == null or role_action_player.current_animation == animation_name:
		return
	role_action_player.play(animation_name)


func check_can_wait():
	return (
		velocity.x == 0
		and not is_attacking
		and not is_be_attacking
		and velocity.y == 0
		and not death()
		and get_action != "run"
		and not is_t_mc
	)


func check_canuse_some_skill():
	return not is_attacking and not is_be_attacking and velocity.y == 0 and not death()


func jump(allow_release_cut: bool = true):
	is_jump = true
	_jump_release_cut_armed = false
	if jump_count < 2 and is_attacking == false and is_be_attacking == false:
		velocity.y = jump_power
		_jump_release_cut_armed = allow_release_cut
		if jump_count == 0:
			jump_count = 1
			role_action_player.play("jump1")
			get_action = "jump1"
			await role_action_player.animation_finished
			role_action_player.play("drop")
			await role_action_player.animation_finished
		else:
			jump_count = 2
			role_action_player.play("jump2")
			get_action = "jump2"
			await role_action_player.animation_finished
			role_action_player.play("drop")
			await role_action_player.animation_finished
	is_jump = false


## 松开跳跃键时削减剩余上升速度，实现点按低跳、长按高跳。
func _cut_jump_on_release() -> void:
	if not _jump_release_cut_armed:
		return
	_jump_release_cut_armed = false
	if velocity.y >= 0.0 or is_on_floor() or is_bound_to_the_ground:
		return
	if is_attacking or is_be_attacking or is_using_skills:
		return
	velocity.y *= JUMP_RELEASE_SPEED_SCALE


func get_hit_data(_hit_name: String):
	hit_dic = obj_attack_dict[_hit_name]
	_hit_data_needs_reset = true


var _hit_data_needs_reset := false


func remove_hit_data():
	if not is_attacking and _hit_data_needs_reset:
		hit_dic = {"power": 0, "hurtBack": [0, 0], "attackKind": "real"}
		_hit_data_needs_reset = false


func _prepare_hit_reaction() -> void:
	pass


func _skill_super_armor_active() -> bool:
	return false


func _get_hit_stiff_animation_duration() -> float:
	return -1.0


func _cancel_hit_reaction() -> void:
	_hit_reaction_generation += 1
	is_be_attacking = false


func state_behit():
	var stiff_seconds := -1.0
	if not _pending_hit_stiff_seconds.is_empty():
		stiff_seconds = _pending_hit_stiff_seconds.pop_front()
	if need_protect or is_white_bar_control_immune() or is_knockback_immune():
		_cancel_hit_reaction()
		return
	if RoleProp.roleprop.Hp <= 0 or is_death:
		_cancel_hit_reaction()
		if RoleProp.roleprop.Hp <= 0 and not is_death:
			is_death = true
			Global.remove_a_all_buff()
			velocity.x = 0
			velocity.y = 0
			get_action = "death"
			role_action_player.play("death")
			await get_tree().create_timer(1.5).timeout
			if not LocalCoop.is_enabled() or LocalCoop.all_players_dead():
				Global.change_scene("res://Scene/level/defeat.tscn")
		return

	_prepare_hit_reaction()
	if need_protect:
		_cancel_hit_reaction()
		return

	_hit_reaction_generation += 1
	var reaction_generation := _hit_reaction_generation
	is_in_sky = false
	is_be_attacking = true
	is_using_skills = false

	await get_tree().process_frame

	if not is_instance_valid(self) or not is_instance_valid(role_action_player):
		return
	if need_protect or reaction_generation != _hit_reaction_generation:
		return

	role_action_player.stop()
	role_action_player.play("hurt")
	get_action = "hurt"

	if stiff_seconds >= 0.0:
		await get_tree().create_timer(stiff_seconds, false).timeout
	else:
		var hurt_duration := _get_hit_stiff_animation_duration()
		if hurt_duration < 0.0:
			hurt_duration = role_action_player.current_animation_length
		var playback_speed := maxf(absf(role_action_player.speed_scale), 0.001)
		await get_tree().create_timer(maxf(hurt_duration / playback_speed, 1.0 / 30.0), false).timeout

	if is_instance_valid(self) and reaction_generation == _hit_reaction_generation:
		is_be_attacking = false


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if is_dikong_field_invincible() or is_taiji_bagua_protected() or is_death or need_protect:
		return
	is_in_sky = false
	c_ure_cure_count = 0
	cure_value = 1
	idle_count = 0

	Global.total_hurt_count += 1
	var target = area.get_parent().get_parent()
	var monster_target: BaseMonster
	monster_target = check_monster(area)
	if target == null or monster_target == null:
		return
	if target.obj_attack_dict.size() == 0:
		return
	if str(target.get("skill_name")) == "Monster118Bullet2":
		Global.add_buff(
			self.buff,
			{
				"Name": "poision",
				"AddTime": 5,
				"CanAdd": true,
				"DeBuff": true,
				"CanRemove": false,
				"reduce_interval": 1,
				"value": 900,
				"AttackKind": "magic"
			}
		)
	if monster_target is Monster47:
		Global.player_be_hit_count += 1
	var last_hit = get_monster_last_hurt(monster_target, target) * (1 - slzjs) * (1 - slzjs2)

	if monster_target != null:
		if monster_target.is_lpz:
			var levellpz = PlayerData.player_data["落魄阵"]["Level"]
			monster_target.lpzjs = levellpz * 0.01
			last_hit *= (1 - monster_target.lpzjs)

	var total_cure_monster = int(monster_target.ebol * last_hit)
	monster_target.cure_hp(total_cure_monster)
	if self is Role3Hero and RoleProp.is_ws_state:
		last_hit = int(last_hit * 0.63)
	if monster_target != null:
		monster_target.total_hit += last_hit
		if monster_target is Monster141:
			effect_reducehp(int(RoleProp.roleprop.SHp * 0.01), "real")
			Global.add_monster141_aura(self.bullet, self.position, monster_target)
	Global.total_role_hurt += int(last_hit)
	if not is_miss:
		if self is Role1Hero:
			Global.add_sound(self, "res://Music/hero/49_role1_be_attack.mp3")
		elif self is Role2Hero:
			Global.add_sound(self, "res://Music/hero/62_role2_be_attack.mp3")
		elif self is Role5Hero:
			Global.add_sound(self, "res://Music/hero/role_5/13_hurt_stand.mp3")
		elif self is NeZhaHero:
			Global.add_sound(self, "res://Music/hero/role_6/hurt_stand.mp3")
		elif self is YutuHero:
			Global.add_sound(self, "res://Music/hero/role_7/blade/hurt_stand.mp3")
		else:
			Global.add_sound(self, "res://Music/hero/68_role3_be_attack.mp3")
		_add_role_hit_effect_throttled()
		if not is_t_mc:
			_add_role_protect(randi_range(3, 7))
	if self is Role3Hero:
		if randi_range(0, 100) <= 2 + PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能10"][DataKeys.LEVEL] * 0.5:
			var cur_level = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能10"][DataKeys.LEVEL]
			if cur_level > 0:
				if not get_parent().get_parent() is Level17 and not get_parent().get_parent() is Level22:
					cure_hp(RoleProp.roleprop.power * (0.5 + cur_level * 0.03))

	if self is Role1Hero or self is Role2Hero or self is Role4Hero or self is NeZhaHero or self is YutuHero:
		if is_miss or RoleProp.is_ws_state or super_armor_active or need_protect or is_knockback_immune():
			is_be_attacking = false
		else:
			be_hit_back(monster_target, target)
			_queue_hit_stiff(monster_target, target)
			call_deferred("state_behit")
	elif self is Role3Hero:
		if is_miss or is_sd_buff or is_t_mc or super_armor_active or need_protect:
			is_be_attacking = false
		else:
			be_hit_back(monster_target, target)
			_queue_hit_stiff(monster_target, target)
			call_deferred("state_behit")
	elif self is Role5Hero:
		if is_miss or RoleProp.is_ws_state or super_armor_active or role5_bt or need_protect:
			is_be_attacking = false
		else:
			be_hit_back(monster_target, target)
			_queue_hit_stiff(monster_target, target)
			call_deferred("state_behit")

	reduce_hp(last_hit, monster_target, target)


func reduce_hp(value: int, target_boss, target_obj):
	if is_dikong_field_invincible() or is_taiji_bagua_protected():
		return

	if is_miss:
		var miss_parent = get_parent().get_parent()
		var miss_position = Vector2(self.position.x, self.position.y - 110)
		Global.add_miss_effect(miss_parent, miss_position)
		is_crit = false
		is_miss = false
		return

	if Global.is_hidden_feature_enabled(Global.HIDDEN_FEATURE_INVINCIBLE):
		return

	var monster_damage_bonus: float = float(target_boss.damage_bonus) if target_boss is BaseMonster else 0.0
	value = _apply_damage_vs_reduction(value, monster_damage_bonus)

	if not canglongremove:
		if value >= RoleProp.roleprop.Hp:
			if PlayerData.check_eq_zb("饰品", "canglongjie"):
				(
					Global
					. add_buff(
						self.buff,
						{
							"Name": "Indestructible",
							"AddTime": 3,
							"reduce_interval": 0,
							"value": 0,
							"AttackKind": "",
							"CanRemove": false,
						}
					)
				)
				canglongremove = true
				return
	if RoleProp.roleprop.Hp <= 0:
		return
	if is_indestructible or is_indestructible1:
		if value >= RoleProp.roleprop.Hp:
			return

	c_ure_cure_count = 0
	cure_value = 1
	idle_count = 0

	if target_boss == null or target_obj == null:
		return

	if self is Role2Hero and hd > 0:
		var absorbed = min(hd, value)
		value -= absorbed
		hd -= absorbed
		print("[护盾·唐僧] 伤害吸收 %d，剩余护盾 %d" % [absorbed, hd])
		if value <= 0:
			return

	if value <= 0:
		return

	value = _apply_pet_turtle_damage_share(value)
	if value <= 0:
		return

	RoleProp.roleprop.Hp -= value

	var hit_name_value = target_obj.get("hit_name")
	if hit_name_value == null or typeof(target_boss.obj_attack_dict) != TYPE_DICTIONARY:
		return
	var attack_data = target_boss.obj_attack_dict.get(hit_name_value, {})
	if typeof(attack_data) != TYPE_DICTIONARY or not attack_data.has("attackKind"):
		return

	var at_kind = String(attack_data["attackKind"])
	if value > 0:
		var pp = get_parent().get_parent()
		var po = Vector2(self.position.x, self.position.y - 110)
		Global.add_damage_text(pp, po, value, at_kind, is_crit, self)
	is_crit = false
	is_miss = false


func effect_reducehp(value, atkKind):
	if is_dikong_field_invincible() or is_taiji_bagua_protected():
		return

	if Global.is_hidden_feature_enabled(Global.HIDDEN_FEATURE_INVINCIBLE):
		return

	if not canglongremove:
		if value >= RoleProp.roleprop.Hp:
			if PlayerData.check_eq_zb("饰品", "canglongjie"):
				(
					Global
					. add_buff(
						self.buff,
						{
							"Name": "Indestructible",
							"AddTime": 3,
							"reduce_interval": 0,
							"value": 0,
							"AttackKind": "",
							"CanRemove": false,
						}
					)
				)
				canglongremove = true
				return
	if RoleProp.roleprop.Hp <= 0:
		return
	if is_indestructible or is_indestructible1:
		if value >= RoleProp.roleprop.Hp:
			return

	c_ure_cure_count = 0
	cure_value = 1
	idle_count = 0

	if self is Role2Hero and hd > 0:
		var absorbed = min(hd, value)
		value -= absorbed
		hd -= absorbed
		print("[护盾·唐僧] 伤害吸收 %d，剩余护盾 %d" % [absorbed, hd])
		if value <= 0:
			return

	if value <= 0:
		return

	if atkKind == "physics":
		var reduce_rate = snapped(RoleProp.roleprop.Def / float(RoleProp.roleprop.Def + 250), 0.001)
		value = int(value * (1 - reduce_rate))
		Global.total_phy_hurt += value
	elif atkKind == "magic":
		var reduce_rate = snapped(RoleProp.roleprop.Mdef / float(RoleProp.roleprop.Mdef + 250), 0.001)
		value = int(value * (1 - reduce_rate))
		Global.total_mag_hurt += value
	elif atkKind == "real":
		Global.total_real_hurt += value

	value = _apply_damage_vs_reduction(value)

	value = _apply_pet_turtle_damage_share(value)
	if value <= 0:
		return

	RoleProp.roleprop.Hp -= value
	Global.total_role_hurt += int(value)

	if value > 0:
		var pp = get_parent().get_parent()
		var po = Vector2(self.position.x, self.position.y - 110)
		Global.add_damage_text(pp, po, value, atkKind, false, self)


func get_monster_last_hurt(target_boss, target_obj):
	is_crit = false
	is_miss = false
	if target_boss == null or target_obj == null:
		return 0
	var target = check_monster(target_boss) as BaseMonster
	if target == null:
		return 0
	var hit_name_value = target_obj.get("hit_name")
	if hit_name_value == null or String(hit_name_value).is_empty():
		return 0
	var attack_dictionary: Dictionary = {}
	var source_attack_dictionary: Variant = target_obj.get("obj_attack_dict")
	if source_attack_dictionary is Dictionary and (source_attack_dictionary as Dictionary).has(hit_name_value):
		attack_dictionary = source_attack_dictionary as Dictionary
	elif typeof(target_boss.obj_attack_dict) == TYPE_DICTIONARY:
		attack_dictionary = target_boss.obj_attack_dict
	if not attack_dictionary.has(hit_name_value):
		return 0
	var attack_data = attack_dictionary[hit_name_value]
	if typeof(attack_data) != TYPE_DICTIONARY:
		return 0
	if not attack_data.has("attackKind") or not attack_data.has("power"):
		return 0
	var level_inter = abs(target_boss.level - RoleProp.baseroleprop.Level)

	var lx = String(attack_data["attackKind"])
	var hurt = int(attack_data["power"])
	if bool(attack_data.get("stz_stack_bonus", false)) and buff != null:
		for buff_node in buff.get_children():
			if buff_node is BaseBuff and buff_node.is_set:
				var buff_info: Dictionary = buff_node.buff_info
				if str(buff_info.get("Name", "")) == "monster137buff":
					hurt += 100
	var miss = RoleProp.roleprop.Miss - target.htarget
	var crit = target.crit - RoleProp.roleprop.CritReduce
	var lucky = target.lucky - RoleProp.roleprop.toughness
	var last_def = RoleProp.roleprop.Def - target.ar
	var last_mdef = RoleProp.roleprop.Mdef - target.sp
	var crit_bl = level_inter * 0.07
	var lucky_bl = level_inter * 0.07
	var ini_hurt = hurt

	if miss <= 0:
		miss = 0
	if crit <= 0:
		crit = 0
	if last_def <= 0:
		last_def = 0
	if last_mdef <= 0:
		last_mdef = 0
	if is_defe_reduce:
		var defense_reduction := clampf(defe_reduce, 0.0, 1.0)
		last_def *= 1.0 - defense_reduction
		last_mdef *= 1.0 - defense_reduction
	if lucky <= 0:
		lucky = 0
	if crit_bl >= 1:
		crit_bl = 1
	if lucky_bl >= 0.7:
		lucky_bl = 0.7
	if target_boss.level - RoleProp.baseroleprop.Level < 0:
		crit = crit * (1 - crit_bl)
		lucky = lucky * (1 - lucky_bl)
		hurt = int(hurt * (1 - is_suppression_num(target_boss) * 0.05))
	else:
		crit = crit * (1 + crit_bl)
		lucky = lucky * (1 + lucky_bl)
		hurt = int(hurt * (1 + is_suppression_num(target_boss) * 0.05))
	var bl
	crit = snapped(crit / float(crit + 100), 0.001)
	miss = snapped(miss / float(miss + 100), 0.001)
	randomize()
	if randf_range(0, 1) <= miss:
		Global.total_miss_count += 1
		is_miss = true
		return 0
	if randf_range(0, 1) <= crit:
		bl = 2 + snapped(lucky / float(lucky + 50), 0.001) - tszbsjm
		hurt = hurt * bl
		is_crit = true
	if lx == "physics":
		var damage_reduction_rate = snapped(last_def / float(last_def + 250), 0.001)
		hurt = int(hurt * (1 - damage_reduction_rate))
		Global.total_phy_hurt += hurt
	elif lx == "magic":
		var damage_reduction_rate = snapped(last_mdef / float(last_mdef + 250), 0.001)
		hurt = int(hurt * (1 - damage_reduction_rate))
		Global.total_mag_hurt += hurt
	elif lx == "real":
		Global.total_real_hurt += hurt

	if is_indestructible or is_indestructible1:
		if hurt >= RoleProp.roleprop.Hp:
			return 0
	if self is Role3Hero:
		if is_t_mc:
			if hurt > 0:
				if target_boss != null:
					if target_boss is BaseMonster:
						var cur_level = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能5"][DataKeys.LEVEL] + 1
						var last_hurt = int(ini_hurt * (2 + cur_level * 0.2))
						target_boss.receive_reflected_damage(last_hurt, "magic", int(RoleProp.roleprop.sp))
	return hurt


func get_total_damage_reduction() -> float:
	var permanent_reduction := maxf(0.0, float(RoleProp.roleprop.get("damage_reduction", 0.0)))
	return permanent_reduction + maxf(0.0, wdsl_damage_reduction)


func add_dikong_field_invincibility() -> void:
	dikong_field_invincible_count += 1


func remove_dikong_field_invincibility() -> void:
	dikong_field_invincible_count = maxi(0, dikong_field_invincible_count - 1)


func is_dikong_field_invincible() -> bool:
	return dikong_field_invincible_count > 0


func _apply_damage_vs_reduction(value: int, attacker_damage_bonus: float = 0.0) -> int:
	if value <= 0:
		return value
	var multiplier := maxf(0.0, 1.0 + maxf(0.0, attacker_damage_bonus) - get_total_damage_reduction())
	return int(float(value) * multiplier)


func level_suppression(target):
	return target.level - RoleProp.baseroleprop.Level > 0


func is_suppression_num(target):
	var num: int = abs(target.level - RoleProp.baseroleprop.Level)
	if num > 5:
		num = 5
	return num


func not_suppression_num(target):
	var num: int
	if RoleProp.baseroleprop.Level - target.level > 2:
		num = 2
	else:
		num = RoleProp.baseroleprop.Level - target.level
	return num


func be_hit_back(target_boss, target_obj):
	if is_knockback_immune():
		return
	if not target_boss is BaseMonster:
		return
	if target_boss.has_method("get_knockback_velocity_for_target"):
		var custom_velocity: Variant = target_boss.call("get_knockback_velocity_for_target", target_obj, self)
		if custom_velocity is Vector2:
			var now_msec := Time.get_ticks_msec()
			var blocked_until: int = (
				int(get_meta("eight_immortals_knockback_until")) if has_meta("eight_immortals_knockback_until") else 0
			)
			if now_msec >= blocked_until:
				velocity = custom_velocity as Vector2
				set_meta("eight_immortals_knockback_until", now_msec + 120)
			return
	if target_boss.has_method("get_knockback_direction_for_target"):
		var custom_direction: Variant = target_boss.call("get_knockback_direction_for_target", target_obj, self)
		if custom_direction is int and int(custom_direction) != 0:
			if int(custom_direction) > 0:
				attack_to_right(target_boss, target_obj)
			else:
				attack_to_left(target_boss, target_obj)
			return
	if target_boss.monster_direction:
		attack_to_right(target_boss, target_obj)
	else:
		attack_to_left(target_boss, target_obj)


func is_knockback_immune() -> bool:
	return is_white_bar_control_immune()


func _get_monster_hurt_back(target_boss, target_obj) -> Array:
	if target_boss == null or target_obj == null:
		return []
	var hit_name_value = target_obj.get("hit_name")
	if hit_name_value == null or typeof(target_boss.obj_attack_dict) != TYPE_DICTIONARY:
		return []
	var attack_data = target_boss.obj_attack_dict.get(hit_name_value, {})
	if typeof(attack_data) != TYPE_DICTIONARY or not attack_data.has("hurtBack"):
		return []
	var hurt_back = attack_data["hurtBack"]
	if typeof(hurt_back) != TYPE_ARRAY or hurt_back.size() < 2:
		return []
	return hurt_back


func _get_source_target_move(target_boss, target_obj) -> Array:
	if target_boss == null or target_obj == null:
		return []
	var hit_name_value = target_obj.get("hit_name")
	if hit_name_value == null or typeof(target_boss.obj_attack_dict) != TYPE_DICTIONARY:
		return []
	var attack_data = target_boss.obj_attack_dict.get(hit_name_value, {})
	if typeof(attack_data) != TYPE_DICTIONARY:
		return []
	var source_move: Variant = attack_data.get("sourceTargetMove", null)
	if source_move is Vector2:
		return [source_move.x, source_move.y]
	if source_move is Array and source_move.size() >= 2:
		return [source_move[0], source_move[1]]
	return []


func _queue_hit_stiff(target_boss, target_obj) -> void:
	var stiff_seconds := -1.0
	if target_boss != null and target_obj != null:
		var hit_name_value = target_obj.get("hit_name")
		if hit_name_value != null and typeof(target_boss.obj_attack_dict) == TYPE_DICTIONARY:
			var attack_data = target_boss.obj_attack_dict.get(hit_name_value, {})
			if typeof(attack_data) == TYPE_DICTIONARY and attack_data.has("sourceStiffSeconds"):
				stiff_seconds = maxf(float(attack_data["sourceStiffSeconds"]), 0.0)
	_pending_hit_stiff_seconds.append(stiff_seconds)


func attack_to_right(target_boss, target_obj):
	var source_move := _get_source_target_move(target_boss, target_obj)
	if source_move.size() >= 2:
		self.velocity.x = absf(float(source_move[0]))
		self.velocity.y = -absf(float(source_move[1]))
		return
	var hurt_back := _get_monster_hurt_back(target_boss, target_obj)
	if hurt_back.is_empty():
		return
	self.velocity.x = -float(hurt_back[0]) * 25
	self.velocity.y = float(hurt_back[1]) * 15


func attack_to_left(target_boss, target_obj):
	var source_move := _get_source_target_move(target_boss, target_obj)
	if source_move.size() >= 2:
		self.velocity.x = -absf(float(source_move[0]))
		self.velocity.y = -absf(float(source_move[1]))
		return
	var hurt_back := _get_monster_hurt_back(target_boss, target_obj)
	if hurt_back.is_empty():
		return
	self.velocity.x = float(hurt_back[0]) * 25
	self.velocity.y = float(hurt_back[1]) * 15


func _on_skill_in_timeout() -> void:
	pass


func cure_mp(value: int = 0):
	if RoleProp.roleprop.Mp + value >= RoleProp.roleprop.SMp:
		value = RoleProp.roleprop.SMp - RoleProp.roleprop.Mp
	RoleProp.roleprop.Mp += value
	if value > 0:
		var pp = get_parent().get_parent()
		var po: Vector2
		if player_dir:
			po = Vector2(self.position.x - 50, self.position.y - 140)
		else:
			po = Vector2(self.position.x + 30, self.position.y - 140)
		Global.add_damage_text(pp, po, value, "CureMp", false, self)


func reduce_mp(value: int = 0):
	RoleProp.roleprop.Mp -= value
	if value > 0:
		var pp = get_parent().get_parent()
		var po: Vector2
		if player_dir:
			po = Vector2(self.position.x - 50, self.position.y - 140)
		else:
			po = Vector2(self.position.x + 30, self.position.y - 140)
		Global.add_damage_text(pp, po, value, "ReduceMp", false, self)


func cure_hp(value: int = 0):
	if sxyr_cannot_cure:
		return 0
	if RoleProp.roleprop.Hp <= 0:
		return 0
	if get_parent().get_parent() is Level17 or get_parent().get_parent() is Level22 or is_blood_fix or life_mana_lock:
		return 0

	var max_hp = RoleProp.roleprop.SHp
	var old_hp = RoleProp.roleprop.Hp
	var effective = min(value, max_hp - old_hp)
	var excess = value - effective

	RoleProp.roleprop.Hp += effective
	_apply_pet_turtle_link_heal(int(effective))
	is_cure_hp = true
	cure_hp_value = int(effective)
	Global.total_cure_hp += int(effective)

	var le = get_parent().get_parent() as BaseLevel
	for i in le.get_node("Monster").get_children():
		if i != null and i is Monster37:
			i.cure_hp(effective * 8)

	if effective > 0:
		var pp = get_parent().get_parent()
		var po: Vector2
		if player_dir:
			po = Vector2(self.position.x - 50, self.position.y - 140)
		else:
			po = Vector2(self.position.x + 30, self.position.y - 140)
		Global.add_damage_text(pp, po, effective, "cure", is_crit, self)

	return effective


func _pet_turtle_link_unit() -> Node:
	if not has_meta("pet_turtle_link_unit_ref"):
		return null
	var unit_ref = get_meta("pet_turtle_link_unit_ref")
	if not (unit_ref is WeakRef):
		return null
	var until_msec: int = int(get_meta("pet_turtle_link_until_msec")) if has_meta("pet_turtle_link_until_msec") else 0
	if Time.get_ticks_msec() >= until_msec:
		_clear_pet_turtle_link_meta()
		return null
	var unit_value = unit_ref.get_ref()
	if typeof(unit_value) != TYPE_OBJECT or not is_instance_valid(unit_value):
		_clear_pet_turtle_link_meta()
		return null
	var unit := unit_value as Node
	if unit == null or unit.is_queued_for_deletion():
		_clear_pet_turtle_link_meta()
		return null
	var unit_hp = unit.get("hp")
	if unit_hp == null or int(unit_hp) <= 0:
		_clear_pet_turtle_link_meta()
		return null
	return unit


func _apply_pet_turtle_damage_share(value: int) -> int:
	if value <= 0:
		return value
	var unit := _pet_turtle_link_unit()
	if unit == null or not unit.has_method("receive_linked_damage"):
		return value
	if not has_meta("pet_turtle_link_percent"):
		return value
	var percent := clampi(int(get_meta("pet_turtle_link_percent")), 0, 100)
	if percent <= 0:
		return value
	var requested_share := clampi(int(round(float(value) * float(percent) / 100.0)), 0, value)
	if requested_share <= 0:
		return value
	var actual_share := clampi(int(unit.call("receive_linked_damage", requested_share)), 0, requested_share)
	return maxi(0, value - actual_share)


func _apply_pet_turtle_link_heal(value: int) -> void:
	var skip_heal: bool = (
		bool(get_meta("pet_turtle_skip_link_heal")) if has_meta("pet_turtle_skip_link_heal") else false
	)
	if value <= 0 or skip_heal:
		return
	var unit := _pet_turtle_link_unit()
	if unit != null and unit.has_method("receive_linked_heal"):
		unit.call("receive_linked_heal", value)


func _clear_pet_turtle_link_meta() -> void:
	for key in ["pet_turtle_link_unit_ref", "pet_turtle_link_percent", "pet_turtle_link_until_msec"]:
		if has_meta(key):
			remove_meta(key)


func f_bcure_hp(value: int):
	if sxyr_cannot_cure:
		return
	if get_parent().get_parent() is Level17 or get_parent().get_parent() is Level22:
		return
	if RoleProp.roleprop.Hp + value >= RoleProp.roleprop.SHp:
		value = RoleProp.roleprop.SHp - RoleProp.roleprop.Hp
	RoleProp.roleprop.Hp += value
	if value > 0:
		var pp = get_parent().get_parent()
		var po: Vector2
		if player_dir:
			po = Vector2(self.position.x - 50, self.position.y - 140)
		else:
			po = Vector2(self.position.x + 30, self.position.y - 140)
		Global.add_damage_text(pp, po, value, "cure", is_crit, self)


func _on_spontaneous_recovery_timeout() -> void:
	ran_num = randi_range(0, 100)
	if RoleProp.roleprop.Hp <= 0:
		return
	if get_parent().get_parent() is Level17 or get_parent().get_parent() is Level22 or is_blood_fix or life_mana_lock:
		return
	if cure_value >= 4:
		cure_value = 4

	if RoleProp.roleprop.Hp < RoleProp.roleprop.SHp and RoleProp.roleprop.Hp > 0:
		if not sxyr_cannot_cure:
			Global.total_cure_hp += int(RoleProp.roleprop.R_hp * cure_value)
			RoleProp.roleprop.Hp += int(RoleProp.roleprop.R_hp * cure_value)

	if RoleProp.roleprop.Mp < RoleProp.roleprop.SMp:
		var has_magic_drain_buff = false
		if self.buff != null:
			for i in self.buff.get_children():
				if i != null and i.buff_info["Name"] == "MagicDrain":
					has_magic_drain_buff = true
					break

		if has_magic_drain_buff:
			pass
		else:
			RoleProp.roleprop.Mp += RoleProp.roleprop.R_mp

			is_magic_drain = false


func get_need_mp(skill_name, bool_):
	if not bool_:
		match skill_name:
			"slz":
				return 10 + ((3 + 2 * (get_skill_level(1) - 1)) * (get_skill_level(1) - 1))
			"hytj":
				return 8 + ((3 + 2 * (get_skill_level(2) - 1)) * (get_skill_level(2) - 1))
			"lys":
				return 12 + ((4 + 2 * (get_skill_level(3) - 1)) * (get_skill_level(3) - 1))
			"lyfb":
				return 35 + ((6 + 2 * (get_skill_level(4) - 1)) * (get_skill_level(4) - 1))
			"hmz":
				return 35 + ((3 + 3 * (get_skill_level(5) - 1)) * (get_skill_level(5) - 1))
			"hmz_ws":
				return 35 + ((3 + 3 * (get_skill_level(12) - 1)) * (get_skill_level(12) - 1))
			"hyjj_ws":
				return 45 + ((4 + 3 * (get_skill_level(13) - 1)) * (get_skill_level(13) - 1))
			"zz":
				return 12 + ((4 + 2 * (get_skill_level(6) - 1)) * (get_skill_level(6) - 1))
			"gsrs":
				return 12 + ((4 + 2 * (get_skill_level(11) - 1)) * (get_skill_level(11) - 1))
			"qsez":
				return 10 + ((8 + 2 * (get_skill_level(7) - 1)) * (get_skill_level(7) - 1))
			"jdy":
				return 10 + ((8 + 2 * (get_skill_level(8) - 1)) * (get_skill_level(8) - 1))
			"hyjj":
				return 22 + ((8 + 2 * (get_skill_level(9) - 1)) * (get_skill_level(9) - 1))
			"blb":
				return 15 + ((3 + 2 * (get_skill_level(1) - 1)) * (get_skill_level(1) - 1))
			"xbz":
				return 25 + ((3 + 2 * (get_skill_level(2) - 1)) * (get_skill_level(2) - 1))
			"tjgl":
				return 35 + ((3 + 2 * (get_skill_level(4) - 1)) * (get_skill_level(4) - 1))
			"shy":
				return 30 + ((3 + 2 * (get_skill_level(3) - 1)) * (get_skill_level(3) - 1))
			"smb":
				return 60 + ((3 + 3 * (get_skill_level(5) - 1)) * (get_skill_level(5) - 1))
			"myhc":
				return 35 + ((3 + 2 * (get_skill_level(7) - 1)) * (get_skill_level(7) - 1))
			"sgq":
				return 40 + ((3 + 3 * (get_skill_level(6) - 1)) * (get_skill_level(6) - 1))
			"jgz":
				return 40 + ((3 + 3 * (get_skill_level(8) - 1)) * (get_skill_level(8) - 1))
			"jhsj":
				return 60 + ((3 + 3 * (get_skill_level(9) - 1)) * (get_skill_level(9) - 1))
			"by":
				return 55 + ((3 + 3 * (get_skill_level(11) - 1)) * (get_skill_level(11) - 1))
			"zfjg":
				return 80 + ((3 + 3 * (get_skill_level(12) - 1)) * (get_skill_level(12) - 1))
			"ssp":
				return 10 + ((2 + 2 * (get_skill_level(1) - 1)) * (get_skill_level(1) - 1))
			"dj":
				return 10 + ((3 + 2 * (get_skill_level(2) - 1)) * (get_skill_level(2) - 1))
			"dgq":
				return 15 + ((3 + 2 * (get_skill_level(3) - 1)) * (get_skill_level(3) - 1))
			"zznh":
				return 10 + ((3 + 2 * (get_skill_level(4) - 1)) * (get_skill_level(4) - 1))
			"tmc":
				return 40 + ((3 + 2 * (get_skill_level(5) - 1)) * (get_skill_level(5) - 1))
			"sd":
				return 10 + ((3 + 2 * (get_skill_level(6) - 1)) * (get_skill_level(6) - 1))
			"jsp":
				return 20 + ((3 + 2 * (get_skill_level(7) - 1)) * (get_skill_level(7) - 1))
			"xgq":
				return 20 + ((3 + 2 * (get_skill_level(8) - 1)) * (get_skill_level(8) - 1))
			"syzq":
				return 20 + ((3 + 2 * (get_skill_level(9) - 1)) * (get_skill_level(9) - 1))
			"bdqk":
				return 50 + ((3 + 3 * (get_skill_level(12) - 1)) * (get_skill_level(12) - 1))

			"qlj":
				return 15 + ((2 + 2 * (get_skill_level(1) - 1)) * (get_skill_level(1) - 1))
			"dcj":
				return 15 + ((3 + 2 * (get_skill_level(2) - 1)) * (get_skill_level(2) - 1))
			"wdzt":
				return 15 + ((3 + 2 * (get_skill_level(3) - 1)) * (get_skill_level(3) - 1))
			"tkj":
				return 15 + ((3 + 2 * (get_skill_level(4) - 1)) * (get_skill_level(4) - 1))
			"mmw":
				return 25 + ((3 + 2 * (get_skill_level(5) - 1)) * (get_skill_level(5) - 1))
			"jdz":
				return 20 + ((3 + 2 * (get_skill_level(6) - 1)) * (get_skill_level(6) - 1))
			"lhsq":
				return 20 + ((3 + 2 * (get_skill_level(7) - 1)) * (get_skill_level(7) - 1))
			"zq":
				return 20 + ((3 + 2 * (get_skill_level(8) - 1)) * (get_skill_level(8) - 1))
			"wdww":
				return 10 + ((3 + 2 * (get_skill_level(9) - 1)) * (get_skill_level(9) - 1))
			"bylt":
				return 55 + ((3 + 3 * (get_skill_level(11) - 1)) * (get_skill_level(11) - 1))
			"cmly":
				return 55 + ((3 + 3 * (get_skill_level(12) - 1)) * (get_skill_level(12) - 1))

			"xyq":
				return 15 + ((2 + 2 * (get_skill_level(1) - 1)) * (get_skill_level(1) - 1))
			"slq":
				return 20 + ((3 + 2 * (get_skill_level(2) - 1)) * (get_skill_level(2) - 1))
			"blq":
				return 20 + ((3 + 2 * (get_skill_level(3) - 1)) * (get_skill_level(3) - 1))
			"fhf":
				return 20 + ((3 + 2 * (get_skill_level(4) - 1)) * (get_skill_level(4) - 1))
			"ltjz":
				return 50 + ((3 + 3 * (get_skill_level(11) - 1)) * (get_skill_level(11) - 1))
			"cxq":
				return 25 + ((3 + 2 * (get_skill_level(5) - 1)) * (get_skill_level(5) - 1))
			"llrd":
				return 30 + ((3 + 2 * (get_skill_level(6) - 1)) * (get_skill_level(6) - 1))
			"lljy":
				return 40 + ((3 + 2 * (get_skill_level(7) - 1)) * (get_skill_level(7) - 1))
			"ygth":
				return 40 + ((3 + 2 * (get_skill_level(8) - 1)) * (get_skill_level(8) - 1))
			"tllz":
				return 40 + ((3 + 2 * (get_skill_level(9) - 1)) * (get_skill_level(9) - 1))
			"":
				return 0
	else:
		match skill_name:
			"slz":
				return 10 + ((3 + 2 * (get_skill_level(1))) * (get_skill_level(1)))
			"hytj":
				return 8 + ((3 + 2 * (get_skill_level(2))) * (get_skill_level(2)))
			"lys":
				return 12 + ((4 + 2 * (get_skill_level(3))) * (get_skill_level(3)))
			"lyfb":
				return 35 + ((6 + 2 * (get_skill_level(4))) * (get_skill_level(4)))
			"hmz":
				return 35 + ((3 + 3 * (get_skill_level(5))) * (get_skill_level(5)))
			"hmz_ws":
				return 35 + ((3 + 3 * (get_skill_level(12))) * (get_skill_level(12)))
			"hyjj_ws":
				return 45 + ((4 + 3 * (get_skill_level(13))) * (get_skill_level(13)))
			"zz":
				return 12 + ((4 + 2 * (get_skill_level(6))) * (get_skill_level(6)))
			"gsrs":
				return 12 + ((4 + 2 * (get_skill_level(11))) * (get_skill_level(11)))
			"qsez":
				return 10 + ((8 + 2 * (get_skill_level(7))) * (get_skill_level(7)))
			"jdy":
				return 10 + ((8 + 2 * (get_skill_level(8))) * (get_skill_level(8)))
			"hyjj":
				return 22 + ((8 + 2 * (get_skill_level(9))) * (get_skill_level(9)))
			"blb":
				return 15 + ((3 + 2 * (get_skill_level(1))) * (get_skill_level(1)))
			"xbz":
				return 25 + ((3 + 2 * (get_skill_level(2))) * (get_skill_level(2)))
			"tjgl":
				return 35 + ((3 + 2 * (get_skill_level(4))) * (get_skill_level(4)))
			"shy":
				return 30 + ((3 + 2 * (get_skill_level(3))) * (get_skill_level(3)))
			"smb":
				return 60 + ((3 + 3 * (get_skill_level(5))) * (get_skill_level(5)))
			"myhc":
				return 35 + ((3 + 2 * (get_skill_level(7))) * (get_skill_level(7)))
			"sgq":
				return 40 + ((3 + 3 * (get_skill_level(6))) * (get_skill_level(6)))
			"jgz":
				return 40 + ((3 + 3 * (get_skill_level(8))) * (get_skill_level(8)))
			"jhsj":
				return 60 + ((3 + 3 * (get_skill_level(9))) * (get_skill_level(9)))
			"by":
				return 55 + ((3 + 3 * (get_skill_level(11))) * (get_skill_level(11)))
			"zfjg":
				return 80 + ((3 + 3 * (get_skill_level(12))) * (get_skill_level(12)))
			"ssp":
				return 10 + ((2 + 2 * (get_skill_level(1))) * (get_skill_level(1)))
			"dj":
				return 10 + ((3 + 2 * (get_skill_level(2))) * (get_skill_level(2)))
			"dgq":
				return 15 + ((3 + 2 * (get_skill_level(3))) * (get_skill_level(3)))
			"zznh":
				return 10 + ((3 + 2 * (get_skill_level(4))) * (get_skill_level(4)))
			"tmc":
				return 40 + ((3 + 2 * (get_skill_level(5))) * (get_skill_level(5)))
			"sd":
				return 10 + ((3 + 2 * (get_skill_level(6))) * (get_skill_level(6)))
			"jsp":
				return 20 + ((3 + 2 * (get_skill_level(7))) * (get_skill_level(7)))
			"xgq":
				return 20 + ((3 + 2 * (get_skill_level(8))) * (get_skill_level(8)))
			"syzq":
				return 20 + ((3 + 2 * (get_skill_level(9))) * (get_skill_level(9)))
			"bdqk":
				return 50 + ((3 + 3 * (get_skill_level(12))) * (get_skill_level(12)))

			"qlj":
				return 15 + ((2 + 2 * (get_skill_level(1))) * (get_skill_level(1)))
			"dcj":
				return 15 + ((3 + 2 * (get_skill_level(2))) * (get_skill_level(2)))
			"wdzt":
				return 15 + ((3 + 2 * (get_skill_level(3))) * (get_skill_level(3)))
			"tkj":
				return 15 + ((3 + 2 * (get_skill_level(4))) * (get_skill_level(4)))
			"mmw":
				return 25 + ((3 + 2 * (get_skill_level(5))) * (get_skill_level(5)))
			"jdz":
				return 20 + ((3 + 2 * (get_skill_level(6))) * (get_skill_level(6)))
			"lhsq":
				return 20 + ((3 + 2 * (get_skill_level(7))) * (get_skill_level(7)))
			"zq":
				return 20 + ((3 + 2 * (get_skill_level(8))) * (get_skill_level(8)))
			"wdww":
				return 10 + ((3 + 2 * (get_skill_level(9))) * (get_skill_level(9)))
			"bylt":
				return 55 + ((3 + 3 * (get_skill_level(11))) * (get_skill_level(11)))
			"cmly":
				return 55 + ((3 + 3 * (get_skill_level(12))) * (get_skill_level(12)))

			"xyq":
				return 15 + ((2 + 2 * (get_skill_level(1))) * (get_skill_level(1)))
			"slq":
				return 20 + ((3 + 2 * (get_skill_level(2))) * (get_skill_level(2)))
			"blq":
				return 20 + ((3 + 2 * (get_skill_level(3))) * (get_skill_level(3)))
			"fhf":
				return 20 + ((3 + 2 * (get_skill_level(4))) * (get_skill_level(4)))
			"ltjz":
				return 50 + ((3 + 3 * (get_skill_level(11))) * (get_skill_level(11)))
			"cxq":
				return 25 + ((3 + 2 * (get_skill_level(5))) * (get_skill_level(5)))
			"llrd":
				return 30 + ((3 + 2 * (get_skill_level(6))) * (get_skill_level(6)))
			"lljy":
				return 40 + ((3 + 2 * (get_skill_level(7))) * (get_skill_level(7)))
			"ygth":
				return 40 + ((3 + 2 * (get_skill_level(8))) * (get_skill_level(8)))
			"tllz":
				return 40 + ((3 + 2 * (get_skill_level(9))) * (get_skill_level(9)))
			"":
				return 0
	return 0


func get_skill_level(num):
	return PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能" + str(num)][DataKeys.LEVEL]


func death():
	if RoleProp.roleprop.Hp <= 0 and not is_death:
		_try_taiji_bagua_revive()
	return RoleProp.roleprop.Hp <= 0


func is_taiji_bagua_protected() -> bool:
	return Time.get_ticks_msec() < _taiji_bagua_protection_until


func _try_taiji_bagua_revive() -> void:
	if _taiji_bagua_revived:
		return
	var equipped: Array = PlayerData.player_data.get(DataKeys.MAGIC_WEAPON, [])
	if equipped.is_empty() or not equipped[0] is Dictionary:
		return
	if str(equipped[0].get(DataKeys.NAME, "")) != "tjbg":
		return
	_taiji_bagua_revived = true
	RoleProp.roleprop.Hp = RoleProp.roleprop.SHp
	if DataKeys.FIVE_ELEMENTS in equipped[0] and "木" in equipped[0][DataKeys.FIVE_ELEMENTS]:
		RoleProp.roleprop.Mp = mini(
			int(RoleProp.roleprop.SMp), int(RoleProp.roleprop.Mp) + int(RoleProp.roleprop.SMp / 2.0)
		)
	_taiji_bagua_protection_until = Time.get_ticks_msec() + 2000


func add_magic_weapon():
	if is_instance_valid(mg_target) and not mg_target.is_queued_for_deletion():
		return
	mg_target = null
	if str(PlayerData.player_data.get("实战法宝", "")) in PlayerData.RETIRED_WUDU_MAGIC_WEAPONS:
		PlayerData.player_data["实战法宝"] = ""
	if PlayerData.player_data[DataKeys.MAGIC_WEAPON].size() != 0:
		var name1 = PlayerData.player_data["实战法宝"]
		if name1 != "":
			var parent = get_parent().get_parent()
			mg_target = Global.add_magic_weapon(parent, name1, Vector2(0, 0), self)
			if mg_target != null and mg_target.has_method("set_magic_weapon_player"):
				mg_target.set_magic_weapon_player(self)
			else:
				if mg_target != null:
					mg_target.queue_free()
				mg_target = null
		else:
			PlayerData.player_data["实战法宝"] = PlayerData.player_data[DataKeys.MAGIC_WEAPON][0][DataKeys.NAME]
			var parent = get_parent().get_parent()
			mg_target = Global.add_magic_weapon(parent, PlayerData.player_data["实战法宝"], Vector2(0, 0), self)
			if mg_target != null and mg_target.has_method("set_magic_weapon_player"):
				mg_target.set_magic_weapon_player(self)
			else:
				if mg_target != null:
					mg_target.queue_free()
				mg_target = null
	else:
		if mg_target != null:
			mg_target.queue_free()
	if is_instance_valid(mg_target) and not mg_target.is_queued_for_deletion():
		_active_magic_weapon_name = str(PlayerData.player_data.get("实战法宝", ""))


func add_ws_effect():
	spawn_ws_effect(action, get_parent())


func _on_ws_timer_timeout() -> void:
	add_ws_effect()


func _add_role_protect(value: float) -> bool:
	if value <= 0.0 or is_death or need_protect:
		return need_protect
	current_protect = clampf(current_protect + value, 0.0, max_protect)
	if current_protect >= max_protect:
		_activate_role_protect()
	return need_protect


func _activate_role_protect() -> void:
	if is_death or need_protect:
		return
	current_protect = max_protect
	need_protect = true
	need_remove_protect = true
	white_bar_armor_time_left = WHITE_BAR_ARMOR_DURATION
	velocity = Vector2.ZERO
	Global.clear_white_bar_control_buffs(buff)
	_enforce_white_bar_control_immunity()
	_cancel_hit_reaction()
	_set_protect_visual(true)
	$Protect.start(ROLE_PROTECT_DURATION)


func is_white_bar_control_immune() -> bool:
	return white_bar_armor_time_left > 0.0


func _enforce_white_bar_control_immunity() -> void:
	if not is_white_bar_control_immune():
		return
	super_armor_active = true
	_cancel_hit_reaction()
	_pending_hit_stiff_seconds.clear()
	is_ice = false
	is_stun = false
	is_eye_fix = false
	is_dead_link = false
	is_immobilize = false
	is_scary = false
	islljy = false
	is_silent = false
	is_bound_to_the_ground = false
	is_blood_fix = false
	life_mana_lock = false
	is_reverse_move = false
	reverse_move_speed_multiplier = 1.0
	if is_speed_down:
		walk_speed = _fabao_jiasu_base_speed * 2 if is_fabao_jiasu else 240
	is_speed_down = false


func _clear_role_protect() -> void:
	need_protect = false
	need_remove_protect = false
	current_protect = 0.0
	_set_protect_visual(false)


func self_protect():
	_enforce_white_bar_control_immunity()
	current_protect = clampf(current_protect, 0.0, max_protect)
	if not need_protect and current_protect >= max_protect:
		_activate_role_protect()
		return
	if need_protect:
		_set_protect_visual(true)
		if $Protect.is_stopped():
			_clear_role_protect()
			return
		current_protect = maxf(0.0, current_protect - 1.0)
	else:
		current_protect = maxf(0.0, current_protect - 0.05)


func _on_protect_timeout() -> void:
	_clear_role_protect()


var _protect_visual_active := false


func _set_protect_visual(active: bool) -> void:
	if is_instance_valid(my_hurt_box):
		my_hurt_box.set_deferred("disabled", active)
	_protect_visual_active = active
	var alpha := 0.5 if active else 1.0
	if is_instance_valid(role_body):
		role_body.self_modulate = Color(1, 1, 1, alpha)
	if is_instance_valid(role_eq):
		role_eq.self_modulate = Color(1, 1, 1, alpha)


func on_eqchange():
	var wq: String
	var fj: String
	if PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WEAPON] == "":
		if PlayerData.player_data[DataKeys.WEAPON].size() == 0:
			wq = "Empty"
		else:
			wq = str(PlayerData.player_data[DataKeys.WEAPON][0][DataKeys.NAME])
	else:
		wq = str(PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WEAPON])
	change_eq(wq)
	if PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.ARMOR] == "":
		if PlayerData.player_data[DataKeys.FASHION].size() == 0:
			if PlayerData.player_data[DataKeys.ARMOR].size() == 0:
				fj = "Empty"
			else:
				fj = str(PlayerData.player_data[DataKeys.ARMOR][0][DataKeys.NAME])
		else:
			fj = str(PlayerData.player_data[DataKeys.FASHION][0][DataKeys.NAME])
	else:
		fj = str(PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.ARMOR])
	fj = Global.get_clean_name(fj)

	change_body(fj)
	var mount_runtime := get_node_or_null("MountRuntime")
	if mount_runtime != null and mount_runtime.has_method("refresh_rider_appearance"):
		mount_runtime.call("refresh_rider_appearance")
	add_special_effect_clothes(wq, fj)
	var wings_list
	if PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WINGS] == "":
		if PlayerData.player_data[DataKeys.WINGS].size() == 0:
			wings.visible = false
			wings_list = "empty"
		else:
			wings_list = PlayerData.player_data[DataKeys.WINGS][0][DataKeys.NAME]
	else:
		wings_list = PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WINGS]
	var show_wings: bool = (
		wings_list != "empty"
		and bool(PlayerData.player_data.get("翅膀显示", true))
		and not bool(MainSet.set_data.get("NotShowRoleBody", false))
	)
	wings.visible = show_wings
	wings.modulate = Color.WHITE if show_wings else Color(1, 1, 1, 0)
	if not show_wings:
		wings.stop()
		return
	if wings_list == "xyzy":
		_ensure_xianyu_wing_animation()
	elif wings_list == "hhyq":
		_ensure_huahao_wing_animation()

	_set_xianyu_wing_flip_tracks(false)
	_set_static_wing_animation_tracks(wings_list == "hhyq" or wings_list == "xyzy")
	wings.flip_h = wings_list == "xyzy" or wings_list == "hhyq"
	wings.z_index = 0
	wings.play(wings_list)
	_last_wings_name = ""
	set_wings_offset()


func _capture_wings_base_transform() -> void:
	if wings == null or _wings_base_transform_initialized:
		return
	_wings_base_position = wings.position
	_wings_base_offset = wings.offset
	_wings_base_rotation = wings.rotation
	_wings_base_scale = wings.scale
	_wings_base_flip_h = wings.flip_h
	_wings_base_transform_initialized = true


func _scan_late_static_wing_tracks() -> void:
	if not is_inside_tree():
		return
	var current_wings_name := ""
	var transmog_data: Variant = PlayerData.player_data.get(DataKeys.TRANSMOG_LIST, {})
	var transmog_wings := str(transmog_data.get(DataKeys.WINGS, "")) if transmog_data is Dictionary else ""
	if transmog_wings != "":
		current_wings_name = transmog_wings
	elif PlayerData.player_data.get(DataKeys.WINGS, []).size() > 0:
		current_wings_name = str(PlayerData.player_data[DataKeys.WINGS][0].get(DataKeys.NAME, ""))
	_set_static_wing_animation_tracks(current_wings_name == "hhyq" or current_wings_name == "xyzy")


func _reset_wings_base_transform() -> void:
	_capture_wings_base_transform()
	wings.position = _wings_base_position
	wings.offset = _wings_base_offset
	wings.rotation = _wings_base_rotation
	wings.scale = _wings_base_scale
	wings.flip_h = _wings_base_flip_h


func _set_static_wing_animation_tracks(disabled: bool) -> void:
	if role_action_player == null:
		return
	if disabled == _static_wing_tracks_disabled:
		if not disabled:
			return

		for library_name in role_action_player.get_animation_library_list():
			var library: AnimationLibrary = role_action_player.get_animation_library(library_name)
			if library == null:
				continue
			for animation_name in library.get_animation_list():
				var animation: Animation = library.get_animation(animation_name)
				if animation == null:
					continue
				for track_index in animation.get_track_count():
					var track_path := str(animation.track_get_path(track_index))
					if not _is_wing_transform_track(track_path) or not animation.track_is_enabled(track_index):
						continue
					var known_track := false
					for state in _static_wing_track_states:
						if state.get("animation") == animation and int(state.get("track_index", -1)) == track_index:
							known_track = true
							break
					if known_track:
						continue
					(
						_static_wing_track_states
						. append(
							{
								"animation": animation,
								"track_index": track_index,
								"enabled": true,
							}
						)
					)
					animation.track_set_enabled(track_index, false)
		return
	if disabled:
		_static_wing_track_states.clear()
		for library_name in role_action_player.get_animation_library_list():
			var library: AnimationLibrary = role_action_player.get_animation_library(library_name)
			if library == null:
				continue
			for animation_name in library.get_animation_list():
				var animation: Animation = library.get_animation(animation_name)
				if animation == null:
					continue
				for track_index in animation.get_track_count():
					var track_path := str(animation.track_get_path(track_index))
					if _is_wing_transform_track(track_path):
						(
							_static_wing_track_states
							. append(
								{
									"animation": animation,
									"track_index": track_index,
									"enabled": animation.track_is_enabled(track_index),
								}
							)
						)
						animation.track_set_enabled(track_index, false)
		_static_wing_tracks_disabled = true
		return
	for state in _static_wing_track_states:
		var animation: Animation = state.get("animation")
		if animation != null:
			animation.track_set_enabled(int(state.get("track_index", -1)), bool(state.get("enabled", true)))
	_static_wing_track_states.clear()
	_static_wing_tracks_disabled = false


func _is_wing_transform_track(track_path: String) -> bool:
	return (
		track_path.ends_with("Action/Wings:position")
		or track_path.ends_with("Action/Wings:offset")
		or track_path.ends_with("Action/Wings:rotation")
		or track_path.ends_with("Action/Wings:flip_h")
	)


func _set_xianyu_wing_flip_tracks(disabled: bool) -> void:
	if role_action_player == null or disabled == _xyzy_wing_flip_tracks_disabled:
		return
	if disabled:
		_xyzy_wing_flip_track_states.clear()
		for library_name in role_action_player.get_animation_library_list():
			var library: AnimationLibrary = role_action_player.get_animation_library(library_name)
			if library == null:
				continue
			for animation_name in library.get_animation_list():
				var animation: Animation = library.get_animation(animation_name)
				if animation == null:
					continue
				for track_index in animation.get_track_count():
					var track_path := str(animation.track_get_path(track_index))
					if not track_path.ends_with("Action/Wings:flip_h"):
						continue
					(
						_xyzy_wing_flip_track_states
						. append(
							{
								"animation": animation,
								"track_index": track_index,
								"enabled": animation.track_is_enabled(track_index),
							}
						)
					)
					animation.track_set_enabled(track_index, false)
		_xyzy_wing_flip_tracks_disabled = true
		return
	for state in _xyzy_wing_flip_track_states:
		var animation: Animation = state.get("animation")
		if animation != null:
			animation.track_set_enabled(int(state.get("track_index", -1)), bool(state.get("enabled", true)))
	_xyzy_wing_flip_track_states.clear()
	_xyzy_wing_flip_tracks_disabled = false


func _ensure_xianyu_wing_animation() -> void:
	if wings == null or wings.sprite_frames == null or wings.sprite_frames.has_animation(&"xyzy"):
		return
	var role_script := get_script() as Script
	var role_script_path := role_script.resource_path if role_script != null else ""
	var wing_path := str(XIANYU_WING_PATHS.get(role_script_path, ""))
	var source_frames := load(wing_path) as SpriteFrames if wing_path != "" else null
	if source_frames == null or not source_frames.has_animation(&"xyzy"):
		return
	var target_frames := wings.sprite_frames
	target_frames.add_animation(&"xyzy")
	target_frames.set_animation_loop(&"xyzy", source_frames.get_animation_loop(&"xyzy"))
	target_frames.set_animation_speed(&"xyzy", source_frames.get_animation_speed(&"xyzy"))
	for frame_index in source_frames.get_frame_count(&"xyzy"):
		target_frames.add_frame(
			&"xyzy",
			source_frames.get_frame_texture(&"xyzy", frame_index),
			source_frames.get_frame_duration(&"xyzy", frame_index)
		)


func _ensure_huahao_wing_animation() -> void:
	if wings == null or wings.sprite_frames == null or wings.sprite_frames.has_animation(&"hhyq"):
		return
	var target_frames := wings.sprite_frames
	target_frames.add_animation(&"hhyq")
	target_frames.set_animation_loop(&"hhyq", true)
	target_frames.set_animation_speed(&"hhyq", 30.0)
	for frame_index in range(1, 41):
		var texture := load("%s/%d.png" % [HUAHAO_WING_FRAME_DIR, frame_index]) as Texture2D
		if texture != null:
			target_frames.add_frame(&"hhyq", texture)


func change_body(name1):
	var role_id := clampi(int(PlayerData.player_data.get("Myself", 1)), 1, 7)
	self.role_body.texture = Global.load_role1_body(name1, role_id)
	preload("res://Script/hero/moon_palace_clothes_effect.gd").sync(role_body, str(name1), true)


func change_eq(name1):
	var role_id := clampi(int(PlayerData.player_data.get("Myself", 1)), 1, 7)
	self.role_eq.texture = Global.load_role1_eq(name1, role_id)


func add_special_effect_clothes(EqName, ClothesName):
	var lastname = EqName + ClothesName
	var body_list = [toukui, jianjia, huwan, shenti, yaodai, xiabai]
	match lastname:
		"zxstgzxstj":
			for i in body_list:
				if i != null:
					i.play("zxstj")
					i.offset = Vector2(0, 0)
			wuqi.play("zxstg")
			wuqi.offset = Vector2(0, 0)
			wuqi.scale = Vector2(0.87, 0.87)
			return
		"pftygpftyj":
			for i in body_list:
				if i != null:
					i.play("pftyj")
					match str(i.name):
						"toukui":
							i.offset = Vector2(3, -15)
							continue
						"jianjia":
							i.offset = Vector2(15, 0)
							continue
						"shenti":
							i.offset = Vector2(-25, -20)
							continue
					i.offset = Vector2(0, 0)

			wuqi.play("pftyg")
			wuqi.offset = Vector2(3, 0)
			wuqi.scale = Vector2(0.87, 0.87)
			return
		"slshgslshj":
			for i in body_list:
				if i != null:
					i.play("slshj")
					match str(i.name):
						"toukui":
							i.offset = Vector2(3, -15)
							continue
						"jianjia":
							i.offset = Vector2(15, 10)
							continue
						"xiabai":
							i.offset = Vector2(0, -10)
							continue
					i.offset = Vector2(0, 0)

			wuqi.play("slshg")
			wuqi.offset = Vector2(0, 0)
			wuqi.scale = Vector2(1, 1)
			return
	for i in effect_body.get_children():
		if i != null:
			i.play("Empty")


func _on_hit_box_area_entered(area: Area2D) -> void:
	if obj_attack_dict.has(get_action):
		if obj_attack_dict[get_action].has("addeffect"):
			var monster = area.get_parent().get_parent()
			if monster != null:
				if monster is BaseMonster and not _is_summon_or_pet_target(monster):
					if self is Role4Hero:
						if obj_attack_dict[get_action]["addeffect"]["Name"] == "Voodoo":
							if Global.check_wd(monster) < 10:
								Global.add_buff(monster.buff, obj_attack_dict[get_action]["addeffect"])
						else:
							Global.add_buff(monster.buff, obj_attack_dict[get_action]["addeffect"])
					else:
						Global.add_buff(monster.buff, obj_attack_dict[get_action]["addeffect"])
	if self is Role1Hero:
		if get_action == "qsez":
			velocity.x = 0
			Global.add_sound(self, "res://Music/hero/27_role1_hit13_2.mp3")
			if not is_call:
				is_call = true
				var pp = [
					Vector2(self.position.x, self.position.y),
					Vector2(self.position.x - 30, self.position.y),
					Vector2(self.position.x, self.position.y + 30),
					Vector2(self.position.x + 30, self.position.y),
					Vector2(self.position.x, self.position.y - 30)
				]
				for i in range(5):
					if randi_range(0, 100) < 50:
						Global.add_role_bullet_1_safe(self.bullet, pp[i], "qsez", self.obj_attack_dict["qsez"])
					else:
						Global.add_role_bullet_1_safe(self.bullet, pp[i], "qsez_1", self.obj_attack_dict["qsez"])
					await get_tree().create_timer(0.08, false).timeout


func _is_summon_or_pet_target(target: Node) -> bool:
	if target == null or not is_instance_valid(target):
		return true
	var is_tiger: bool = bool(target.get_meta("pet_tiger_unit")) if target.has_meta("pet_tiger_unit") else false
	var is_sum: bool = bool(target.get_meta("is_summon")) if target.has_meta("is_summon") else false
	if is_tiger or is_sum:
		return true
	if target.has_method("get") and target.get("is_summon") == true:
		return true
	return false


func check_monster(get_tt):
	if not is_instance_valid(get_tt):
		return null

	var node = get_tt
	var depth := 0
	while node != null and is_instance_valid(node) and depth < 10:
		if node is BaseMonster:
			return null if _is_summon_or_pet_target(node) else node
		node = node.get_parent()
		depth += 1

	return null


func get_real_target(get_tt):
	return get_tt.get_parent().get_parent()


func check_add_buff():
	var not_san_xian_hu_ti = true
	var not_reverse_move = true
	var not_magic_drain = true
	var not_yxbuff = true
	var not_lljy = true
	var not_ice = true
	var not_dl = true
	var not_eyefix = true
	var not_stun = true
	var not_sppeddown = true
	var not_silent = true
	var not_bound_floor = true
	var not_immobilize = true
	var not_is_blood_fix = true
	var not_life_mana_lock = true
	var not_defe_reduce = true
	var not_scary = true
	var not_super_armor = true
	var not_indestructible = true
	var not_indestructible1 = true
	var not_double_fall_pro = true
	var not_is_wdzt = true
	var not_slz = true
	var not_tsz = true
	var not_no_de_buff = true
	var not_xr = true
	if self.buff == null:
		return

	var buff_child_count := self.buff.get_child_count()
	var buff_child_index := 0
	while buff_child_index < buff_child_count:
		var i = self.buff.get_child(buff_child_index)
		buff_child_index += 1
		if i != null:
			var buff_info: Dictionary = i.buff_info
			match str(buff_info["Name"]):
				"SanXianHuTi":
					not_san_xian_hu_ti = false
				"ReverseMove":
					is_reverse_move = true
					reverse_move_speed_multiplier = 2.0
					not_reverse_move = false
				"yxbuff":
					is_yx_buff = true
					var bonus_rate = buff_info.get("value", 0.5)
					yx_buff_power_rate = bonus_rate
					yx_buff_crit_rate = bonus_rate
					yx_buff_lucky_rate = bonus_rate
					not_yxbuff = false
				"MagicDrain":
					is_magic_drain = true
					stored_mp = buff_info.get("stored_mp", 0)
					not_magic_drain = false
				"lljybuff":
					islljy = true
					not_lljy = false
				"no_debuff":
					no_debuff = true
					not_no_de_buff = false
				"lpzbuff":
					is_xr = true
					not_xr = false
				"tszbuff":
					istsz = true
					not_tsz = false
				"slzbuff":
					isslz = true
					not_slz = false
				"Ice":
					is_ice = true
					not_ice = false
				"PoisionBody":
					is_wdzt = true
					not_is_wdzt = false
				"SuperArmor":
					super_armor_active = true
					not_super_armor = false
				"DoubleFallPro":
					is_double_fall_pro = true
					not_double_fall_pro = false
				"defe_reduce":
					is_defe_reduce = true
					not_defe_reduce = false
				"Indestructible":
					is_indestructible = true
					not_indestructible = false
				"Indestructible1":
					is_indestructible1 = true
					not_indestructible1 = false
				"DeadLink":
					is_dead_link = true
					not_dl = false
				"EyeFix":
					is_eye_fix = true
					not_eyefix = false
				"Immobilize":
					is_immobilize = true
					not_immobilize = false
				"stun":
					is_stun = true
					not_stun = false
				"speed_down":
					is_speed_down = true
					not_sppeddown = false
				"blood_fix":
					is_blood_fix = true
					not_is_blood_fix = false
				"life_mana_lock":
					life_mana_lock = true
					not_life_mana_lock = false
				"silent":
					is_silent = true
					not_silent = false
				"Boundground":
					is_bound_to_the_ground = true
					not_bound_floor = false
				"Scary":
					is_scary = true
					not_scary = false

	if not_reverse_move:
		is_reverse_move = false
		reverse_move_speed_multiplier = 1.0

	if not_magic_drain:
		is_magic_drain = false
		stored_mp = 0

	if not_yxbuff:
		is_yx_buff = false
		yx_buff_power_rate = 0.0
		yx_buff_crit_rate = 0.0
		yx_buff_lucky_rate = 0.0

	if not_lljy:
		islljy = false

	if not_xr:
		is_xr = false
		xrbl = 0
	if not_no_de_buff:
		no_debuff = false
	if not_tsz:
		istsz = false
		tszzs = 0
	if not_slz:
		isslz = false
		slzjs2 = 0
	if not_is_wdzt:
		is_wdzt = false
	if not_double_fall_pro:
		is_double_fall_pro = false
	if not_indestructible:
		is_indestructible = false
	if not_indestructible1:
		is_indestructible1 = false
	if not_super_armor:
		super_armor_active = _skill_super_armor_active() or is_white_bar_control_immune()
	if not_defe_reduce:
		is_defe_reduce = false
		defe_reduce = 0
	if not_scary:
		is_scary = false
	if not_is_blood_fix:
		is_blood_fix = false
	if not_life_mana_lock:
		life_mana_lock = false
	if not_bound_floor:
		is_bound_to_the_ground = false
	if not_silent:
		is_silent = false
	if not_ice:
		is_ice = false
	if not_dl:
		is_dead_link = false
	if not_eyefix:
		is_eye_fix = false
	if not_stun:
		is_stun = false
	if not_immobilize:
		is_immobilize = false
	if not_sppeddown:
		is_speed_down = false
		walk_speed = _fabao_jiasu_base_speed * 2 if is_fabao_jiasu else 240
	if buff.get_child_count() == 0:
		is_speed_down = false
		walk_speed = _fabao_jiasu_base_speed * 2 if is_fabao_jiasu else 240
		is_stun = false
		is_eye_fix = false
		is_ice = false
		is_dead_link = false
		is_silent = false
		is_bound_to_the_ground = false
		is_reverse_move = false


func get_skill(name1):
	name1 = str(name1)
	var raw_skill_name = name1
	if is_silent or not is_inside_tree() or is_queued_for_deletion():
		return
	var scene_parent := get_parent()
	if scene_parent == null or not is_instance_valid(scene_parent):
		return
	var level := scene_parent.get_parent()
	if level == null or not is_instance_valid(level) or level.is_queued_for_deletion():
		return
	if level is Level17 or level is Level22:
		return
	if name1 == "":
		return
	var cooldown_key: String = name1
	if name1 == "jdy2":
		cooldown_key = "jdy"
	elif name1 == "tmc2":
		cooldown_key = "tmc"
	if not role1_skill_inter.has(cooldown_key):
		push_warning("忽略未知角色技能：%s" % raw_skill_name)
		return
	if self is Role1Hero:
		var is_can_use_slz = false
		if name1 == "slz":
			for i in PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能键位"]:
				if str(PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能键位"][i]) == "slz":
					is_can_use_slz = true
			if not is_can_use_slz:
				return
		if name1 == "hyjj":
			if not check_canuse_some_skill():
				return
		if RoleProp.roleprop.Mp >= get_need_mp(name1, false) and role1_skill_inter[cooldown_key] <= 0:
			RoleProp.roleprop.Mp -= get_need_mp(name1, false)
		else:
			return
		match name1:
			"slz":
				if role1_skill_inter["slz"] <= 0:
					do_slz()
			"zz":
				do_zz()
			"gsrs":
				do_gsrs()
			"lys":
				if role1_skill_inter["lys"] <= 0:
					do_lys()
			"lyfb":
				if role1_skill_inter["lyfb"] <= 0:
					do_lyfb()
			"hmz":
				if has_method("set_hmz_version"):
					call("set_hmz_version", false)
				if has_method("set_hmz_cooldown_key"):
					call("set_hmz_cooldown_key", "hmz")
				if has_method("set_hmz_damage_level"):
					call("set_hmz_damage_level", get_skill_level(5) + 1, "hmz")
				do_hmz_pro()
			"hmz_ws":
				if has_method("set_hmz_version"):
					call("set_hmz_version", true)
				if has_method("set_hmz_cooldown_key"):
					call("set_hmz_cooldown_key", "hmz_ws")
				if has_method("set_hmz_damage_level"):
					call("set_hmz_damage_level", get_skill_level(12) + 1, "hmz_ws")
				do_hmz_pro()
			"hyjj_ws":
				if has_method("do_wushuang_huoyan_jinjing"):
					call("do_wushuang_huoyan_jinjing")
			"hytj":
				if role1_skill_inter["hytj"] <= 0:
					do_hytj()
			"hyjj":
				if role1_skill_inter["hyjj"] <= 0:
					do_hyjj()
			"jdy":
				if role1_skill_inter["jdy"] <= 0:
					do_jdy()
			"jdy2":
				if role1_skill_inter["jdy"] <= 0:
					do_jdy_2()
			"qsez":
				if role1_skill_inter["qsez"] <= 0:
					do_qsez()
			"":
				return
	elif self is Role2Hero:
		if not is_on_floor():
			if name1 == "smb":
				return
		if smb1 == null:
			if RoleProp.roleprop.Mp < get_need_mp(name1, false) or role1_skill_inter[cooldown_key] > 0:
				return
		match name1:
			"blb":
				if role1_skill_inter["blb"] <= 0:
					skill_blb()
					RoleProp.roleprop.Mp -= get_need_mp(name1, false)
			"tjgl":
				if role1_skill_inter["tjgl"] <= 0:
					skill_tjgl()
					RoleProp.roleprop.Mp -= get_need_mp(name1, false)
			"xbz":
				if role1_skill_inter["xbz"] <= 0:
					skill_xbz()
					RoleProp.roleprop.Mp -= get_need_mp(name1, false)
			"shy":
				if role1_skill_inter["shy"] <= 0:
					skill_shy()
					if my_shallow == null:
						RoleProp.roleprop.Mp -= get_need_mp(name1, false)
			"sgq":
				if role1_skill_inter["sgq"] <= 0:
					skill_sgq()
					RoleProp.roleprop.Mp -= get_need_mp(name1, false)
			"myhc":
				if role1_skill_inter["myhc"] <= 0:
					skill_myhc()
					RoleProp.roleprop.Mp -= get_need_mp(name1, false)
			"jgz":
				if role1_skill_inter["jgz"] <= 0:
					skill_jgz()
					RoleProp.roleprop.Mp -= get_need_mp(name1, false)
			"jhsj":
				if role1_skill_inter["jhsj"] <= 0:
					skill_jhsj()
					RoleProp.roleprop.Mp -= get_need_mp(name1, false)
			"smb":
				if role1_skill_inter["smb"] <= 0:
					skill_smb()
					if smb1 == null:
						RoleProp.roleprop.Mp -= get_need_mp(name1, false)
			"by":
				if role1_skill_inter["by"] <= 0:
					skill_by()
					RoleProp.roleprop.Mp -= get_need_mp(name1, false)
			"zfjg":
				if role1_skill_inter["zfjg"] <= 0:
					call("skill_zfjg")
					RoleProp.roleprop.Mp -= get_need_mp(name1, false)
	elif self is Role3Hero:
		if name1 == "tmc2":
			if role1_skill_inter["tmc"] <= 0:
				skill_tmc2()
				return
			return
		if RoleProp.roleprop.Mp >= get_need_mp(name1, false) and role1_skill_inter[cooldown_key] <= 0:
			RoleProp.roleprop.Mp -= get_need_mp(name1, false)
		else:
			return
		match name1:
			"sd":
				if role1_skill_inter["sd"] <= 0:
					skill_sd()
			"ssp":
				if role1_skill_inter["ssp"] <= 0:
					skill_ssp()
			"jsp":
				if role1_skill_inter["jsp"] <= 0:
					skill_jsp()
			"zznh":
				if role1_skill_inter["zznh"] <= 0:
					skill_zznh()
			"dj":
				if role1_skill_inter["dj"] <= 0:
					skill_dj()
			"dgq":
				if role1_skill_inter["dgq"] <= 0:
					skill_dgq()
			"xgq":
				if role1_skill_inter["xgq"] <= 0:
					skill_xgq()
			"syzq":
				if role1_skill_inter["syzq"] <= 0:
					skill_syzq()
			"tmc":
				if role1_skill_inter["tmc"] <= 0:
					skill_tmc()
			"bdqk":
				if role1_skill_inter["bdqk"] <= 0:
					call("skill_bdqk")
	elif self is Role4Hero:
		if RoleProp.roleprop.Mp >= get_need_mp(name1, false) and role1_skill_inter[cooldown_key] <= 0:
			RoleProp.roleprop.Mp -= get_need_mp(name1, false)
		else:
			return
		match name1:
			"qlj":
				if role1_skill_inter["qlj"] <= 0:
					shovel_qlj()
			"dcj":
				if role1_skill_inter["dcj"] <= 0:
					shovel_dcj()
			"wdzt":
				if role1_skill_inter["wdzt"] <= 0:
					shovel_wdzt()
			"tkj":
				if role1_skill_inter["tkj"] <= 0:
					shovel_tkj()
			"mmw":
				if role1_skill_inter["mmw"] <= 0:
					shovel_mmw()
			"zq":
				if role1_skill_inter["zq"] <= 0:
					shovel_zq()
			"wdww":
				if role1_skill_inter["wdww"] <= 0:
					shovel_wdww()
			"bylt":
				if role1_skill_inter["bylt"] <= 0:
					call("shovel_bylt")
			"cmly":
				if role1_skill_inter["cmly"] <= 0:
					call("shovel_cmly")
			"lhsq":
				if role1_skill_inter["lhsq"] <= 0:
					shovel_mbyj()
			"jdz":
				if role1_skill_inter["jdz"] <= 0:
					shovel_jdz()
	elif self is Role5Hero:
		if RoleProp.roleprop.Mp >= get_need_mp(name1, false) and role1_skill_inter[cooldown_key] <= 0:
			RoleProp.roleprop.Mp -= get_need_mp(name1, false)
		else:
			return
		match name1:
			"slq":
				if role1_skill_inter["slq"] <= 0:
					use_slq()
			"cxq":
				if role1_skill_inter["cxq"] <= 0:
					use_cxq()
			"blq":
				if role1_skill_inter["blq"] <= 0:
					use_blq()
			"xyq":
				if role1_skill_inter["xyq"] <= 0:
					use_xyq()
			"llrd":
				if role1_skill_inter["llrd"] <= 0:
					use_llrd()
			"lljy":
				if role1_skill_inter["lljy"] <= 0:
					use_lljy()
			"tllz":
				if role1_skill_inter["tllz"] <= 0:
					use_tllz()
			"ygth":
				if role1_skill_inter["ygth"] <= 0:
					use_ygth()
			"fhf":
				if role1_skill_inter["fhf"] <= 0:
					use_fhf()
			"ltjz":
				if role1_skill_inter["ltjz"] <= 0:
					call("use_ltjz")


func improve_self_recovery_when_idle():
	if is_be_attacking:
		c_ure_cure_count = 0
		cure_value = 1
	else:
		c_ure_cure_count += 1
	if c_ure_cure_count % 180 == 0 and c_ure_cure_count != 0:
		cure_value += 0.5
	if velocity.x == 0:
		idle_count += 1
	else:
		idle_count = 0
	if idle_count % 120 == 0 and idle_count != 0:
		cure_value += 0.5


func reset_insky():
	is_in_sky = false


func set_insky():
	is_in_sky = true


func addsmsr_shenqi_lightning_round() -> void:
	if not RoleProp.is_ws_state or not has_smsrsz_fashion or current_fashion_quality != "shenqi":
		return
	if not obj_attack_dict.has("smsr"):
		return
	var effect := SMSR_SHENQI_LIGHTNING_EFFECT.new()
	effect.setup(self, obj_attack_dict["smsr"])
	var level := get_parent().get_parent()
	if level != null:
		level.add_child(effect)
	else:
		add_child(effect)


func addsmsr_effect():
	var dic = obj_attack_dict["smsr"].duplicate(true)
	if player_dir:
		dic["hurtBack"] = [-20, -1]
	else:
		dic["hurtBack"] = [20, -1]

	Global.add_role_bullet(self, Vector2(0, 20), false, "SMSRBullet", dic)


func addzlw_effect():
	Global.add_role_bullet(self, Vector2(0, 0), false, "ZLWBullet", obj_attack_dict["zlw"])


func startzlw_shenqi_effect():
	addzlw_shenqi_wheel_effect()
	if zlwsz_shenqi_timer == null:
		zlwsz_shenqi_timer = Timer.new()
		add_child(zlwsz_shenqi_timer)
		zlwsz_shenqi_timer.timeout.connect(_on_zlwsz_shenqi_timer_timeout)
	zlwsz_shenqi_timer.start(3.0)


func _on_zlwsz_shenqi_timer_timeout():
	if RoleProp.is_ws_state:
		addzlw_shenqi_wheel_effect()
	else:
		zlwsz_shenqi_timer.stop()


func addzlw_shenqi_wheel_effect():
	if not obj_attack_dict.has("zlw_shenqi_ws"):
		return
	var bullet_parent = get_tree().current_scene
	if bullet_parent == null:
		bullet_parent = self.bullet
	for i in range(3):
		var gear = ZLWSZ_GEAR_SCENE.instantiate()
		gear.follow_target = self
		gear.initial_angle = TAU / 3.0 * i
		gear.hit_dic = obj_attack_dict["zlw_shenqi_ws"]
		bullet_parent.add_child(gear)
		gear.global_position = self.global_position


func add_ttzs_effect():
	Global.add_role_bullet(self, Vector2(0, 0), false, "TtzsszBullet", obj_attack_dict["ttzs"])


func addnmw_effect():
	var position_list_1 = [Vector2(-65, 500), Vector2(65, 500)]
	var position_list_2 = [Vector2(-175, 500), Vector2(175, 500)]
	var position_list_3 = [Vector2(-285, 500), Vector2(285, 500)]
	var bullet_spawn_positions = {
		"1": [Vector2(-185, 500), Vector2(65, 500), Vector2(-65, 500), Vector2(185, 500)],
		"2":
		[
			Vector2(-285, 500),
			Vector2(-185, 500),
			Vector2(65, 500),
			Vector2(-65, 500),
			Vector2(185, 500),
			Vector2(285, 500)
		],
		"3":
		[
			Vector2(-385, 500),
			Vector2(-285, 500),
			Vector2(-185, 500),
			Vector2(65, 500),
			Vector2(-65, 500),
			Vector2(185, 500),
			Vector2(285, 500),
			Vector2(385, 500)
		],
	}
	var sz_name = Global.get_clean_name(PlayerData.player_data[DataKeys.FASHION][0][DataKeys.NAME])
	var pz = str(PlayerData.player_data[DataKeys.FASHION][0][DataKeys.NAME]).split(sz_name)[0]
	var count: int = 1
	match pz:
		"youxiu":
			count = 1
		"jingliang":
			count = 2
		"shishi":
			count = 3
	for i in bullet_spawn_positions[str(count)]:
		Global.add_role_bullet(self.bullet, Vector2(i.x + position.x, 500), false, "NMWBullet2", obj_attack_dict["nmw"])


func set_sz_value():
	has_smsrsz_fashion = false
	current_fashion_quality = ""
	if PlayerData.player_data[DataKeys.FASHION].size() <= 0:
		return
	var sz_name = Global.get_clean_name(PlayerData.player_data[DataKeys.FASHION][0][DataKeys.NAME])
	var pz = str(PlayerData.player_data[DataKeys.FASHION][0][DataKeys.NAME]).split(sz_name)[0]
	var bl = 1
	match sz_name:
		"ttzssz":
			var power: int
			var pj: float
			var time: float
			match pz:
				"youxiu":
					power = RoleProp.roleprop.power * 1
					pj = 0.15
					time = 4
				"jingliang":
					power = RoleProp.roleprop.power * 1.5
					pj = 0.25
					time = 6
				"shishi":
					power = RoleProp.roleprop.power * 2
					pj = 0.35
					time = 8
				"xieling":
					power = RoleProp.roleprop.power * 2.5
					pj = 0.4
					time = 10
				"hunqi":
					power = RoleProp.roleprop.power * 3
					pj = 0.45
					time = 12
				"chuanshuo":
					power = RoleProp.roleprop.power * 3.5
					pj = 0.5
					time = 14
				"shenqi":
					power = RoleProp.roleprop.power * 4
					pj = 0.4
					time = 16
			obj_attack_dict["ttzs"] = {
				"power": int(power),
				"hurtBack": [1, -1],
				"attackKind": "magic",
				"addeffect":
				{
					"Name": "defe_reduce",
					"AddTime": time,
					"reduce_interval": 0,
					"value": pj,
					"AttackKind": "",
					"CanRemove": true,
					"CanAdd": false,
					"DeBuff": true
				}
			}
		"nmwsz":
			var max_hp = RoleProp.roleprop.SHp
			var power: int
			var pj: float
			var time: float
			match pz:
				"youxiu":
					power = max_hp * 0.3
					pj = max_hp * 0.05
					time = 2
				"jingliang":
					power = max_hp * 0.5
					pj = max_hp * 0.07
					time = 3
				"shishi":
					power = max_hp * 0.7
					pj = max_hp * 0.09
					time = 5
				"xieling":
					power = max_hp * 0.9
					pj = max_hp * 0.11
					time = 7
				"hunqi":
					power = max_hp * 1.1
					pj = max_hp * 0.13
					time = 9
				"chuanshuo":
					power = max_hp * 1.3
					pj = max_hp * 0.15
					time = 11
				"shenqi":
					power = max_hp * 1.5
					pj = max_hp * 0.17
					time = 13
			obj_attack_dict["nmw"] = {
				"power": int(power),
				"hurtBack": [1, -1],
				"attackKind": "magic",
				"addeffect":
				{
					"Name": "Fire",
					"AddTime": time,
					"reduce_interval": 1,
					"value": int(pj),
					"AttackKind": "real",
					"CanRemove": true,
					"CanAdd": false,
					"DeBuff": true,
				}
			}
		"zlwsz":
			var power: int
			var time: float
			match pz:
				"youxiu":
					power = RoleProp.roleprop.power * 3
					time = 2
				"jingliang":
					power = RoleProp.roleprop.power * 4
					time = 3
				"shishi":
					power = RoleProp.roleprop.power * 5
					time = 4
				"xieling":
					power = RoleProp.roleprop.power * 6
					time = 5
				"hunqi":
					power = RoleProp.roleprop.power * 7
					time = 6
				"chuanshuo":
					power = RoleProp.roleprop.power * 8
					time = 7
				"shenqi":
					power = RoleProp.roleprop.power * 9
					time = 8
			obj_attack_dict["zlw"] = {
				"power": int(power),
				"hurtBack": [1, -1],
				"attackKind": "magic",
				"addeffect":
				{
					"Name": "stun",
					"AddTime": time,
					"reduce_interval": 0,
					"value": 0,
					"AttackKind": "",
					"CanRemove": true,
					"CanAdd": false,
					"DeBuff": true
				}
			}
			if pz == "shenqi":
				obj_attack_dict["zlw_shenqi_ws"] = {
					"power": int(RoleProp.roleprop.power * 2.5),
					"hurtBack": [0, 0],
					"attackKind": "magic",
					"stun_chance": 40,
					"addeffect":
					{
						"Name": "stun",
						"AddTime": 1,
						"reduce_interval": 0,
						"value": 0,
						"AttackKind": "",
						"CanRemove": true,
						"CanAdd": false,
						"DeBuff": true
					}
				}

		"smsrsz":
			has_smsrsz_fashion = true
			current_fashion_quality = pz
			var power: int
			match pz:
				"youxiu":
					power = RoleProp.roleprop.power * 3
				"jingliang":
					power = RoleProp.roleprop.power * 3
				"shishi":
					power = RoleProp.roleprop.power * 3
				"xieling":
					power = RoleProp.roleprop.power * 3
				"hunqi":
					power = RoleProp.roleprop.power * 3
				"chuanshuo":
					power = RoleProp.roleprop.power * 3
				"shenqi":
					power = RoleProp.roleprop.power * 3
			obj_attack_dict["smsr"] = {
				"power": int(power),
				"hurtBack": [0, 0],
				"attackKind": "magic",
			}


func _update_fashion_values_if_needed() -> void:
	var fashion_name := ""
	if not PlayerData.player_data[DataKeys.FASHION].is_empty():
		fashion_name = str(PlayerData.player_data[DataKeys.FASHION][0].get(DataKeys.NAME, ""))
	var current_power := int(RoleProp.roleprop.power)
	var current_max_hp := int(RoleProp.roleprop.SHp)
	if (
		_fashion_values_initialized
		and fashion_name == _last_fashion_name
		and current_power == _last_fashion_power
		and current_max_hp == _last_fashion_max_hp
	):
		return
	_fashion_values_initialized = true
	_last_fashion_name = fashion_name
	_last_fashion_power = current_power
	_last_fashion_max_hp = current_max_hp
	set_sz_value()


func when_scary():
	if not is_scary or is_be_attacking:
		return
	if ran_num <= 20:
		_play_locomotion_animation(&"wait")
		velocity.x = 0
	elif ran_num > 20 and ran_num <= 60:
		_play_locomotion_animation(&"run")
		get_action = "run"
		action.scale.x = 1
		base_damagebox.scale.x = 1
		velocity.x = -walk_speed * RoleProp.ws_up_power * 0.5
	else:
		_play_locomotion_animation(&"run")
		get_action = "run"
		action.scale.x = -1
		base_damagebox.scale.x = -1
		velocity.x = walk_speed * RoleProp.ws_up_power * 0.5


func add_tx():
	var title_name := "Empty"
	if PlayerData.player_data[DataKeys.TRANSMOG_LIST].has(DataKeys.TITLE):
		if PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.TITLE] == "":
			if PlayerData.player_data[DataKeys.TITLE].size() == 0:
				title_name = "Empty"
			else:
				title_name = str(PlayerData.player_data[DataKeys.TITLE][0][DataKeys.NAME])
		else:
			title_name = str(PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.TITLE])
	if title_name == _last_title_name:
		return
	_last_title_name = title_name
	_play_title(title_name)


func _play_title(title_name: String) -> void:
	tx.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if title_name == "htd":
		_ensure_title_animation(title_name, "res://Art/all_tx/htd.png")
	elif title_name == "ymqzq":
		_ensure_title_animation(title_name, "res://Art/all_tx/ymqzq.png")
	tx.play(title_name)
	var title_scale := 0.85
	if title_name == "bhyh":
		title_scale = 0.75
	tx.scale = Vector2(title_scale, title_scale)


func _ensure_title_animation(title_name: String, texture_path: String) -> void:
	if tx.sprite_frames == null or tx.sprite_frames.has_animation(StringName(title_name)):
		return
	var title_texture := load(texture_path) as Texture2D
	if title_texture == null:
		return
	var animation_name := StringName(title_name)
	tx.sprite_frames.add_animation(animation_name)
	tx.sprite_frames.set_animation_loop(animation_name, true)
	tx.sprite_frames.set_animation_speed(animation_name, 15.0)
	for row in range(4):
		for column in range(4):
			var frame_texture := AtlasTexture.new()
			frame_texture.atlas = title_texture
			frame_texture.region = Rect2(column * 208, row * 124, 208, 124)
			tx.sprite_frames.add_frame(animation_name, frame_texture)


func jsfzsy():
	var formation_name := str(PlayerData.player_data["已佩戴阵法"])
	var formation_level := 0
	if formation_name == "slz":
		formation_level = int(PlayerData.player_data["森罗阵"]["Level"])
	elif formation_name == "tsz":
		formation_level = int(PlayerData.player_data["腾蛇阵"]["Level"])
	if formation_name == _last_hero_formation and formation_level == _last_hero_formation_level:
		return
	_last_hero_formation = formation_name
	_last_hero_formation_level = formation_level
	if formation_name == "slz":
		var levelslz = formation_level
		slzjs = levelslz * 0.01
	else:
		slzjs = 0
	if formation_name == "tsz":
		var leveltsz = formation_level
		tszbsjm = leveltsz * 0.01
	else:
		tszbsjm = 0


func use_zhen_fa():
	if PlayerInput.is_action_just_pressed("阵法") or PlayerInput.is_action_just_pressed("MDS"):
		if _try_use_main_sword_array():
			return
		if PlayerData.player_data["已佩戴阵法"] == "" or PlayerData.player_data["已佩戴阵法"] == null:
			return
		match PlayerData.player_data["已佩戴阵法"]:
			"slz":
				if zhen_fa_cd <= 0:
					self.obj_attack_dict["slz"] = {"power": 0, "hurtBack": [0, 0], "attackKind": "magic", "WSValue": 0}
					Global.add_role_bullet(self, Vector2(0, 30), false, "SLZBullet", obj_attack_dict["slz"])
					_start_zhen_fa_cd(30)
			"lpz":
				if zhen_fa_cd <= 0:
					self.obj_attack_dict["lpz"] = {
						"power": int(RoleProp.roleprop.power * 1),
						"hurtBack": [0, 0],
						"attackKind": "magic",
						"WSValue": 0
					}
					Global.add_role_bullet(
						self.bullet, position + Vector2(0, 40), false, "LPZBullet", obj_attack_dict["lpz"]
					)
					_start_zhen_fa_cd(30)
			"tsz":
				if zhen_fa_cd <= 0:
					self.obj_attack_dict["tsz"] = {"power": 0, "hurtBack": [0, 0], "attackKind": "magic", "WSValue": 0}
					Global.add_role_bullet(self, Vector2(0, 30), false, "TSZBullet", obj_attack_dict["tsz"])
					_start_zhen_fa_cd(30)
			"tqz":
				if not is_on_floor():
					return
				if zhen_fa_cd <= 0:
					self.obj_attack_dict["tqz"] = {"power": 0, "hurtBack": [0, 0], "attackKind": "magic", "WSValue": 0}
					Global.add_role_bullet(
						self.bullet, position + Vector2(0, 40), false, "TQZBullet", obj_attack_dict["tqz"]
					)
					_start_zhen_fa_cd(35)


func _try_use_main_sword_array() -> bool:
	if PlayerData.has_method("ensure_main_sword_array"):
		PlayerData.ensure_main_sword_array()
	var active := str(PlayerData.player_data.get("主线剑阵出战", ""))
	if active == "":
		return false
	if PlayerData.has_method("can_main_sword_array_battle") and not PlayerData.can_main_sword_array_battle(active):
		PlayerData.player_data["主线剑阵出战"] = ""
		return false
	if zhen_fa_cd > 0:
		return true
	_sync_main_sword_array_weapon()
	if is_instance_valid(main_sword_array_target) and main_sword_array_target.has_method("cast_skill"):
		main_sword_array_target.cast_skill()
		_set_main_sword_array_cooldown_visible(false)
		_start_zhen_fa_cd(30)
		return true
	return false


func _start_zhen_fa_cd(cd_time: float) -> void:
	zhen_fa_cd = cd_time
	if is_instance_valid(Global.zhen_fa):
		Global.zhen_fa.max_time = zhen_fa_cd
	if is_instance_valid(zhen_fa):
		zhen_fa.start(zhen_fa_cd)


func _on_zhen_fa_timeout() -> void:
	zhen_fa_cd = 0
	_set_main_sword_array_cooldown_visible(true)


func _set_main_sword_array_cooldown_visible(value: bool) -> void:
	var active := str(PlayerData.player_data.get("主线剑阵出战", ""))
	if active == "":
		return
	if is_instance_valid(main_sword_array_target):
		main_sword_array_target.visible = value


func _on_hit_box_body_entered(body: Node2D) -> void:
	pass


func set_wings_offset():
	var current_wings_name: String
	if PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WINGS] == "":
		if PlayerData.player_data[DataKeys.WINGS].size() == 0:
			current_wings_name = "empty"
		else:
			current_wings_name = PlayerData.player_data[DataKeys.WINGS][0][DataKeys.NAME]
	else:
		current_wings_name = PlayerData.player_data[DataKeys.TRANSMOG_LIST][DataKeys.WINGS]
	var special_wing_position := Vector2(41, -4) if self is Role1Hero else _wings_base_position
	var special_wing_offset_y := (
		0.0
		if self is Role1Hero or self is Role4Hero or self is Role5Hero or self is NeZhaHero or self is YutuHero
		else -25.0
	)
	if current_wings_name == _last_wings_name:
		if current_wings_name == "xyzy":
			wings.position = special_wing_position
			wings.offset = Vector2(0, special_wing_offset_y)
			wings.rotation = 0.0
			wings.scale = Vector2.ONE
			return
		if current_wings_name == "hhyq":
			wings.position = special_wing_position
			wings.offset = Vector2(60, special_wing_offset_y)
			wings.rotation = 0.0
			wings.scale = Vector2.ONE
			return
		return
	_last_wings_name = current_wings_name
	_reset_wings_base_transform()
	wings.flip_h = current_wings_name == "xyzy" or current_wings_name == "hhyq"
	match current_wings_name:
		"xtzy", "ttzy":
			if self is Role2Hero or self is Role3Hero:
				wings.position = Vector2(0, 0)
			else:
				wings.offset = Vector2(0, 0)
			wings.scale = Vector2(1.4, 1.4)
		"xqzy":
			if self is Role2Hero or self is Role3Hero:
				wings.position = Vector2(14, 10)
			else:
				wings.offset = Vector2(5, 10)
			wings.scale = Vector2(1.2, 1.2)
		"jmzy":
			if self is Role2Hero or self is Role3Hero:
				wings.position = Vector2(45, 15)
			else:
				wings.offset = Vector2(25, 15)
			wings.scale = Vector2(1.1, 1.1)
		"xmzy":
			if self is Role2Hero or self is Role3Hero:
				wings.position = Vector2(40, -25)
			else:
				wings.offset = Vector2(30, -15)
			wings.scale = Vector2(1, 1)
		"bszy":
			if self is Role2Hero or self is Role3Hero:
				wings.position = Vector2(30, 0)
			else:
				wings.offset = Vector2(20, 10)
			wings.scale = Vector2(1, 1)
		"wyzy":
			if self is Role2Hero or self is Role3Hero:
				wings.position = Vector2(30, 0)
			else:
				wings.offset = Vector2(15, 15)
			wings.scale = Vector2(1, 1)
		"ryzy":
			if self is Role2Hero:
				wings.position = Vector2(30, 0)
			elif self is Role3Hero:
				wings.position = Vector2(45, -20)
				wings.scale = Vector2(1.1, 1.1)
			else:
				wings.offset = Vector2(25, 0)
		"xyzy":
			wings.position = special_wing_position
			wings.offset = Vector2(0, special_wing_offset_y)
			wings.scale = Vector2.ONE
			wings.rotation = 0.0
		"hhyq":
			wings.position = special_wing_position
			wings.offset = Vector2(60, special_wing_offset_y)
			wings.rotation = 0.0
			wings.scale = Vector2.ONE


func reset_san_xian_hu_ti():
	is_san_xian_hu_ti_used = false

# ==============================================================================
# Phase 6-3: 现代 GDScript 规范 snake_case 双轨兼容函数入口
# ==============================================================================
