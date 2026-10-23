extends BaseLevel

const BOSS_SCENE := preload("res://Scene/monster/constellation_boss_base.tscn")
const BOSS_GROUND_SPAWN := Vector2(500, 438)
const BOSS_SPAWN_X_SPACING := 80.0
const BACKGROUND_PATH_FORMAT := "res://Art/constellations/background/%d.png"
const PROJECT_IDS := [47101, 47102, 47103, 47104, 47105, 47106, 47107, 47108, 47109, 47110, 47111, 47112, 47113, 47114]
const SOURCE_IDS := [140, 142, 144, 146, 147, 149, 150, 151, 152, 156, 157, 158, 159, 162]
const TIER_NAMES := [
	"",
	"一阶",
	"二阶",
	"三阶",
	"四阶",
	"五阶",
	"六阶",
	"七阶",
	"八阶",
	"九阶",
	"十阶",
]
const NAMES := ["轸宿", "翼火蛇", "张月鹿", "星日马", "柳宿", "鬼宿", "井宿", "壁宿", "室宿", "危宿", "虚宿", "女宿", "牛宿", "斗宿"]
const ZHUQUE_CRYSTAL_DROPS := ["zqjs", "zqjh"]
const XUANWU_CRYSTAL_DROPS := ["xwjs", "xwjh"]
const PET_SKILL_BOOK_DROPS := [
	"smjc_skill_book",
	"gjjc_skill_book",
	"fyjc_skill_book",
	"mfby_skill_book",
	"sxkb_skill_book",
	"fsnl_skill_book",
	"tsml_skill_book",
	"zrsh_skill_book",
	"smzf_skill_book",
	"mfjc_skill_book",
]
const SUMMON_CONFIG := {
	47115:
	{
		"source_id": 141,
		"name": "星宿侍从",
		"attack": 250,
		"hp": 30000,
		"def": 0,
		"mdef": 0,
		"speed": 3.0,
		"range": 200,
		"sight": 2500,
		"is_boss": false,
		"summon": true
	},
	47117:
	{
		"source_id": 145,
		"name": "星宿侍从",
		"attack": 250,
		"hp": 30000,
		"def": 0,
		"mdef": 0,
		"speed": 4.0,
		"range": 300,
		"sight": 2500,
		"is_boss": false,
		"summon": true
	},
}

const OFFICIAL_ATTACK_SPECS := {
	140:
	{
		"hit1": [500, "physics", [-6.0, -5.0], 999, 99, true],
		"hit2": [500, "physics", [-3.0, 0.0], 999, 99, true],
		"hit2_2": [500, "physics", [-3.0, 0.0], 24, 99, true],
		"hit3": [500, "physics", [-3.0, 0.0], 999, 99, true],
		"hit4": [500, "physics", [-3.0, 0.0], 999, 999, false],
	},
	141: {"hit1": [250, "magic", [-6.0, -5.0], 999, 99, true]},
	142:
	{
		"hit1": [500, "physics", [-6.0, -5.0], 999, 99, true],
		"hit2": [500, "physics", [-10.0, 0.0], 10, 99, true],
		"hit3": [500, "magic", [0.0, 0.0], 10, 99, true],
		"hit4": [500, "physics", [-3.0, 0.0], 999, 999, false],
	},
	144:
	{
		"hit1": [500, "physics", [-6.0, -5.0], 999, 99, true],
		"hit2": [500, "physics", [-10.0, 0.0], 999, 99, true],
		"hit3": [500, "magic", [0.0, 0.0], 10, 99, true],
		"hit4": [500, "physics", [-3.0, 0.0], 999, 999, false],
	},
	145:
	{
		"hit1": [250, "magic", [-6.0, -5.0], 999, 99, true],
		"hit2": [250, "magic", [-6.0, -5.0], 999, 99, true],
	},
	146:
	{
		"hit1": [500, "physics", [-10.0, 0.0], 10, 99, true],
		"hit2": [500, "physics", [-15.0, 0.0], 10, 99, true],
		"hit3": [500, "magic", [0.0, 0.0], 10, 99, true],
		"hit4": [300, "physics", [-3.0, 0.0], 999, 999, true],
	},
	147:
	{
		"hit1": [500, "physics", [-10.0, 0.0], 10, 99, true],
		"hit2": [500, "physics", [-15.0, 0.0], 10, 99, true],
		"hit3": [250, "physics", [0.0, 0.0], 48, 99, true],
	},
	149:
	{
		"hit1": [500, "physics", [-10.0, 0.0], 10, 99, true],
		"hit2": [500, "physics", [-15.0, 0.0], 10, 99, true],
		"hit3": [250, "physics", [0.0, 0.0], 24, 99, true],
		"hit4": [250, "physics", [0.0, 0.0], 48, 99, true],
	},
	150:
	{
		"hit1": [500, "physics", [-10.0, 0.0], 10, 99, true],
		"hit2": [50, "magic", [-15.0, 0.0], 30, 999, true],
		"hit3": [250, "physics", [0.0, 0.0], 24, 99, true],
		"hit4": [500, "physics", [0.0, 0.0], 48, 99, true],
	},
	151:
	{
		"hit1": [500, "physics", [-10.0, 0.0], 10, 99, true],
		"hit2": [500, "physics", [-15.0, 0.0], 10, 99, true],
		"hit3": [500, "physics", [0.0, 0.0], 10, 99, true],
	},
	152:
	{
		"hit1": [500, "physics", [-10.0, 0.0], 10, 99, true],
		"hit2": [500, "magic", [-15.0, 0.0], 10, 99, true],
		"hit3": [500, "physics", [0.0, 0.0], 10, 99, true],
		"hit4": [250, "magic", [0.0, 0.0], 10, 99, true],
	},
	156:
	{
		"hit1": [165, "physics", [-10.0, 0.0], 10, 99, true],
		"hit2": [500, "physics", [-15.0, 0.0], 999, 99, true],
		"hit3": [100, "physics", [0.0, 0.0], 24, 99, true],
	},
	157:
	{
		"hit1": [500, "physics", [-15.0, 0.0], 10, 99, true],
		"hit2": [500, "physics", [0.0, 0.0], 10, 99, true],
	},
	158:
	{
		"hit1": [500, "physics", [-10.0, 0.0], 10, 99, true],
		"hit2": [250, "magic", [-15.0, 0.0], 10, 99, true],
		"hit3": [250, "physics", [-10.0, 0.0], 30, 99, true],
		"hit4": [100, "physics", [0.0, 0.0], 10, 99, true],
	},
	159:
	{
		"hit1": [500, "physics", [-10.0, 0.0], 10, 99, true],
		"hit2": [250, "magic", [-15.0, 0.0], 10, 99, true],
		"hit3": [500, "magic", [-10.0, 0.0], 999, 99, true],
		"hit4": [250, "physics", [0.0, 0.0], 24, 99, true],
	},
	162:
	{
		"hit1": [500, "physics", [-10.0, 0.0], 10, 99, true],
		"hit2": [250, "magic", [-15.0, 0.0], 15, 99, true],
		"hit3": [250, "physics", [-10.0, 0.0], 15, 99, true],
	},
}

@onready var constellation_background: Sprite2D = $BackGround/front/ConstellationBackground

var selected_level := 1
var current_tier := 1
var completed := false
var _advancing := false
var _boss_instance: BaseMonster
var _boss_instances: Array[BaseMonster] = []
var _boss_count_multiplier := 1
var _blackout_serial := 0


func _ready() -> void:
	selected_level = clampi(int(Global.selected_constellation_level), 1, 14)
	current_tier = 1
	_boss_count_multiplier = clampi(int(MainSet.set_data.get("CreateMonsterCount", 1)), 1, 5)
	MainSet.set_data["CreateMonsterCount"] = _boss_count_multiplier
	monster_group = {"stage_1": [], "stage_2": [], "stage_3": [], "stage_4": []}
	monster_position_x = {"stage_1": [], "stage_2": [], "stage_3": [], "stage_4": []}
	monster_position_y = {"stage_1": [], "stage_2": [], "stage_3": [], "stage_4": []}
	Global.current_level = "挑战28星宿阵"
	Global.game_over = 1
	level_stage = 47
	is_two_scene = false
	if constellation_background != null:
		constellation_background.texture = (
			ResourceLoader.load(BACKGROUND_PATH_FORMAT % selected_level, "Texture2D", ResourceLoader.CACHE_MODE_REUSE)
			as Texture2D
		)
	Global.add_bgm(self, "res://Music/level/music_emsd.mp3")
	super._ready()


func _exit_tree() -> void:
	Global.constellation_endless_mode = false


func _prepare_level_runtime_resources() -> void:
	if create_control != null:
		create_control.stop()
	current_stage = 1
	call_deferred("_spawn_current_boss")


func _spawn_current_boss() -> void:
	if completed or _advancing:
		return
	if _has_alive_current_boss():
		return
	_boss_instances.clear()
	_boss_instance = null
	var project_id: int = int(PROJECT_IDS[selected_level - 1])
	for index in range(_boss_count_multiplier):
		var target := _spawn_constellation_unit(project_id, _get_boss_spawn_position(index))
		if target == null:
			continue
		target.set_meta("constellation_boss", true)
		_boss_instances.append(target)
	if not _boss_instances.is_empty():
		_boss_instance = _boss_instances[0]


func _get_boss_spawn_position(index: int) -> Vector2:
	var middle := float(_boss_count_multiplier - 1) * 0.5
	var spawn_position := BOSS_GROUND_SPAWN
	spawn_position.x += (float(index) - middle) * BOSS_SPAWN_X_SPACING
	spawn_position.x = clampf(spawn_position.x, 180.0, 1120.0)
	return spawn_position


func _has_alive_current_boss() -> bool:
	for boss in _boss_instances:
		if boss != null and is_instance_valid(boss) and not boss.is_queued_for_deletion() and not boss.death():
			return true
	return false


func _spawn_constellation_unit(project_id: int, spawn_position: Vector2) -> BaseMonster:
	if monster == null:
		return null
	var target := BOSS_SCENE.instantiate() as BaseMonster
	if target == null:
		return null
	target.set("monster_kind", project_id)
	target.position = spawn_position
	monster.add_child(target)
	return target


func spawn_constellation_summon(project_id: int, spawn_position: Vector2) -> BaseMonster:
	var summon_limit: int = int(
		(
			{
				47115: 10,
				47117: 8,
			}
			. get(project_id, 0)
		)
	)
	if summon_limit > 0 and monster != null:
		var active_monsters := 0
		for child in monster.get_children():
			if child is BaseMonster and not child.is_queued_for_deletion() and int(child.get("hp")) > 0:
				active_monsters += 1
		if active_monsters >= int(summon_limit):
			return null
	return _spawn_constellation_unit(project_id, spawn_position)


func on_constellation_boss_defeated(boss: BaseMonster) -> void:
	if boss != null and is_instance_valid(boss):
		boss.settle_death_drops()
	if _advancing or completed:
		return
	if not _boss_instances.has(boss):
		return
	_boss_instances.erase(boss)
	if _has_alive_current_boss():
		return
	_advancing = true
	var key := str(selected_level)
	var stored_best := PlayerData.get_constellation_highest_defeated_tier(selected_level)
	var best := mini(maxi(maxi(stored_best, int(Global.constellation_best_tier.get(key, 0))), current_tier), 10)
	var progress_changed := PlayerData.record_constellation_defeated_tier(selected_level, best)
	Global.constellation_best_tier[key] = best
	if progress_changed and str(Global.cd_path).contains("Ar_"):
		MemoryClass.save_game(str(Global.cd_path))
	if current_tier >= 10:
		completed = not Global.constellation_endless_mode
	else:
		current_tier += 1
	call_deferred("_advance_after_boss")


func _advance_after_boss() -> void:
	await get_tree().create_timer(0.38).timeout
	_clear_constellation_units()
	_boss_instances.clear()
	_boss_instance = null
	_advancing = false
	if not completed:
		_spawn_current_boss()


func _clear_constellation_units() -> void:
	if monster == null:
		return
	for child in monster.get_children():
		if child is BaseMonster:
			child.queue_free()


func get_constellation_tier() -> int:
	return current_tier


func _get_highest_defeated_tier() -> int:
	var key := str(selected_level)
	var stored_best := PlayerData.get_constellation_highest_defeated_tier(selected_level)
	var legacy_best := clampi(int(Global.constellation_best_tier.get(key, 0)), 0, 10)
	if legacy_best > stored_best:
		PlayerData.record_constellation_defeated_tier(selected_level, legacy_best)
		stored_best = legacy_best
	Global.constellation_best_tier[key] = stored_best
	return stored_best


func get_selected_constellation_level() -> int:
	return selected_level


func start_constellation_blackout(duration: float) -> void:
	_blackout_serial += 1
	var serial := _blackout_serial
	if constellation_background != null:
		constellation_background.modulate = Color.BLACK
	await get_tree().create_timer(maxf(duration, 0.0), false).timeout
	if serial == _blackout_serial and constellation_background != null:
		constellation_background.modulate = Color.WHITE


func get_level_monster_config(project_id: int) -> Dictionary:
	if SUMMON_CONFIG.has(project_id):
		var summon_config: Dictionary = SUMMON_CONFIG[project_id].duplicate(true)
		var summon_source_id := int(summon_config["source_id"])
		var summon_tier := clampi(current_tier, 1, 10)
		summon_config["level"] = 90
		summon_config["hp"] = 30000 * summon_tier
		summon_config["attack"] = 250 * summon_tier
		summon_config["def"] = 0
		summon_config["mdef"] = 0
		summon_config["crit"] = 0
		summon_config["miss"] = 0
		summon_config["hit"] = 0
		summon_config["attack_desire"] = 100
		summon_config["exp"] = 0
		summon_config["coin"] = 0
		summon_config["drop_rate"] = 0.0
		summon_config["attacks"] = _official_attacks(summon_source_id, summon_tier)
		return summon_config
	var index := PROJECT_IDS.find(project_id)
	if index < 0:
		return {}
	var tier := clampi(current_tier, 1, 10)
	var source_id := int(SOURCE_IDS[index])
	var magic_reduction := clampf(0.05 * float(tier), 0.0, 0.95)
	var equivalent_magic_def := roundi(100.0 * magic_reduction / (1.0 - magic_reduction))
	var crystal_drops: Array = ZHUQUE_CRYSTAL_DROPS if index < 7 else XUANWU_CRYSTAL_DROPS
	var drop_multiplier := 5 if tier >= 7 else (3 if tier >= 3 else 1)
	var independent_drop_list: Array = [
		{"name": crystal_drops[0], "value": drop_multiplier * 2, "chance": 0.2 * drop_multiplier},
		{"name": crystal_drops[1], "value": drop_multiplier, "chance": 0.1 * drop_multiplier},
	]
	if index < PET_SKILL_BOOK_DROPS.size():
		(
			independent_drop_list
			. append(
				{
					"name": PET_SKILL_BOOK_DROPS[index],
					"value": drop_multiplier,
					"chance": 0.05 * drop_multiplier,
				}
			)
		)
	var drop_center := float(independent_drop_list.size() - 1) * 0.5
	for drop_index in range(independent_drop_list.size()):
		independent_drop_list[drop_index]["spawn_offset"] = Vector2((float(drop_index) - drop_center) * 36.0, 0.0)
	return {
		"source_id": source_id,
		"name": "%s %s" % [TIER_NAMES[tier], NAMES[index]],
		"level": 90 + tier,
		"hp": 1500000 * tier,
		"attack": 10000 * tier,
		"def": 400 * tier,
		"mdef": equivalent_magic_def,
		"crit": 300 * tier,
		"miss": 0,
		"hit": 300 * tier,
		"toughness": 0.0,
		"crit_reduce": 0,
		"armor_break": 400 * tier,
		"magic_break": 400 * tier,
		"speed": 4.0,
		"range": 150 if source_id in [152, 158, 159, 162] else 200,
		"sight": 2500,
		"attack_desire": 100,
		"exp": 2000 * tier,
		"coin": 100 * tier,
		"drop_rate": 0.0,
		"drop_list": [],
		"is_boss": true,
		"max_protect": 240.0,
		"independent_drop_list": independent_drop_list,
		"control_immune": false,
		"attacks": _official_attacks(source_id, tier),
	}


func _official_attacks(source_id: int, property_level: int) -> Dictionary:
	var source_value: Variant = OFFICIAL_ATTACK_SPECS.get(source_id, {})
	var source_specs: Dictionary = source_value if source_value is Dictionary else {}
	var attacks: Dictionary = {}
	for attack_name: String in source_specs:
		var spec: Array = source_specs[attack_name]
		var scales_with_level := bool(spec[5])
		var power := int(spec[0]) * property_level if scales_with_level else int(spec[0])
		attacks[attack_name] = {
			"power": power,
			"hurt_back": Array(spec[2]).duplicate(),
			"kind": str(spec[1]),
			"interval": float(spec[3]) / 24.0,
			"max_hits": int(spec[4]),
			"protect": 0,
		}
	return attacks


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if my_camera != null:
		my_camera.max_left = 0
		my_camera.max_right = 1200
	if role_information != null and role_information.gogo != null:
		role_information.gogo.visible = one_check_can_exit()


func set_through() -> void:
	if my_camera != null:
		my_camera.max_left = 0
		my_camera.max_right = 1200


func one_check_can_exit() -> bool:
	return completed and _get_alive_stage_monster_count() == 0


func check_can_exit() -> bool:
	return one_check_can_exit()
