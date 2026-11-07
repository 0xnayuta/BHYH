extends Node

## 年兽 1–4 阶运行时规格探针。
## 覆盖：PetNianData 分阶、四阶召唤场景、四阶帧资源、官方部件图集与年兽效果脚本。
## 探针只在 scripts/ 中维护，由 scene_probe_runner 复制到工程根目录执行。

const RESULT_PREFIX := "PET_NIAN_RUNTIME_PROBE_RESULT="
const TEARDOWN_MARKER := "PET_NIAN_RUNTIME_PROBE_TEARDOWN"
const FAMILY = preload("res://Script/pet/pet_nian_family.gd")
const LEVELS := {1: 1, 2: 15, 3: 30, 4: 50}
const STAGES := {1: 1, 2: 2, 3: 3, 4: 4}

var _failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var checks: Dictionary = {}
	_check_data(checks)
	_check_archive(checks)
	await _check_scenes(checks)
	await _check_parts(checks)
	await _check_effects(checks)
	await _check_hud(checks)
	checks["teardown"] = true
	for check_name in checks:
		if not bool(checks[check_name]):
			_failures.append(str(check_name))
	print(RESULT_PREFIX + JSON.stringify({"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": checks}))
	print(TEARDOWN_MARKER)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_data(checks: Dictionary) -> void:
	checks["data_stage_1"] = PetNianData.stage_for_level(1) == 1
	checks["data_stage_2"] = PetNianData.stage_for_level(15) == 2
	checks["data_stage_3"] = PetNianData.stage_for_level(30) == 3
	checks["data_stage_4"] = PetNianData.stage_for_level(50) == 4
	checks["data_kind_match"] = PetNianData.matches({DataKeys.TYPE: "PetNian"})
	checks["data_legacy_name_match"] = PetNianData.matches({DataKeys.TYPE: "PetNian", DataKeys.ALT_NAME: "年兽"})
	var pet := {DataKeys.LEVEL: 50, DataKeys.Pet.SAVVY: 10, DataKeys.Pet.BONE: 0, "已学习技能": ["额外技能"]}
	PetNianData.normalize(pet)
	checks["data_normalize_type"] = str(pet.get(DataKeys.TYPE, "")) == "PetNian"
	checks["data_normalize_stage"] = int(pet.get(DataKeys.Pet.STAGE, 0)) == 4
	checks["data_skills_include_extra"] = (pet.get(DataKeys.Skill.SKILL, []) as Array).has("额外技能")
	checks["data_icon_stage_1"] = PetNianData.skill_icon_path(1, 1) == "res://Art/pet/pet_nian/icons/skill1.png"
	checks["data_icon_stage_4"] = PetNianData.skill_icon_path(4, 1) == "res://Art/pet/pet_nian/icons/skill7.png"
	checks["data_icon_ultimate"] = PetNianData.skill_icon_path(4, 4) == "res://Art/pet/skillicon/aoyi.png"


func _check_archive(checks: Dictionary) -> void:
	var before := _find_nian_entry(PlayerData)
	checks["archive_has_entry"] = not before.is_empty()
	if before.is_empty():
		return
	checks["archive_type"] = str(before.get(DataKeys.TYPE, "")) == FAMILY.KIND
	checks["archive_stage_name"] = str(before.get(DataKeys.ALT_NAME, "")) == PetNianData.NAMES[1]
	checks["archive_skill"] = (before.get(DataKeys.Skill.SKILL, []) as Array).has(PetNianData.SKILLS[0])
	checks["archive_slot_meta"] = LocalCoop.slot_for(PlayerData) == 1 or not LocalCoop.is_enabled()
	var normalized := before.duplicate(true)
	normalized[DataKeys.LEVEL] = 50
	FAMILY.normalize_spawn(normalized, PlayerData)
	checks["archive_normalize_stage4"] = int(normalized.get(DataKeys.Pet.STAGE, 0)) == 4
	checks["archive_normalize_name"] = str(normalized.get(DataKeys.ALT_NAME, "")) == PetNianData.NAMES[4]
	checks["archive_normalize_ultimate"] = (normalized.get(DataKeys.Skill.SKILL, []) as Array).has(PetNianData.SKILLS[3])
	checks["archive_growth_cap_hp"] = int(normalized.get("生命资质基础上限", 0)) == 3500
	checks["archive_growth_cap_atk"] = int(normalized.get("攻击资质基础上限", 0)) == 4000


func _find_nian_entry(profile: Node) -> Dictionary:
	if profile == null or not (profile.get("player_data") is Dictionary):
		return {}
	for pet in profile.player_data.get("宠物列表", []):
		if pet is Dictionary and FAMILY.matches(pet):
			return pet
	return {}


func _check_hud(checks: Dictionary) -> void:
	var hud_scene := load("res://Scene/base/base_role.tscn") as PackedScene
	if hud_scene == null:
		checks["hud_scene"] = false
		return
	var hud := hud_scene.instantiate()
	add_child(hud)
	await get_tree().process_frame
	var pet := _find_nian_entry(PlayerData)
	checks["hud_nian_match"] = hud._is_pet_nian_hud_data(pet, null)
	checks["hud_skill_list_stage1"] = hud._pet_skill_icon_names_for_pet(pet, null, 1) == ["nian_1"]
	var stage4 := pet.duplicate(true)
	stage4[DataKeys.Pet.STAGE] = 4
	checks["hud_skill_list_stage4"] = hud._pet_skill_icon_names_for_pet(stage4, null, 4) == [
		"nian_1", "nian_2", "nian_3", "nian_4"
	]
	checks["hud_cooldown_key_2"] = hud._pet_skill_cooldown_key("nian_2") == "skill_1_cd"
	checks["hud_cooldown_key_3"] = hud._pet_skill_cooldown_key("nian_3") == "skill_2_cd"
	checks["hud_cooldown_key_4"] = hud._pet_skill_cooldown_key("nian_4") == "skill_4_cd"
	checks["hud_cooldown_max_2"] = is_equal_approx(hud._pet_skill_cooldown_max("nian_2", null), 8.0)
	checks["hud_cooldown_max_3"] = is_equal_approx(hud._pet_skill_cooldown_max("nian_3", null), 12.0)
	checks["hud_cooldown_max_4"] = is_equal_approx(hud._pet_skill_cooldown_max("nian_4", null), 20.0)
	checks["hud_death_alias"] = hud._pet_dead_aliases("大年兽").has(FAMILY.KIND)
	hud.queue_free()
	await get_tree().process_frame


func _check_scenes(checks: Dictionary) -> void:
	for stage in range(1, 5):
		var scene_path := "res://Scene/pet/pet_nian_summon_%d.tscn" % stage
		var scene := load(scene_path) as PackedScene
		checks["scene_%d" % stage] = scene != null
		if scene == null:
			continue
		var pet = scene.instantiate()
		pet.set("pet_data", {
			DataKeys.LEVEL: LEVELS[stage],
			DataKeys.ATTACK: 120,
			DataKeys.HP: 1200,
			DataKeys.MP: 240,
			DataKeys.Pet.SAVVY: 0,
			DataKeys.Pet.BONE: 0,
		})
		add_child(pet)
		await get_tree().process_frame
		await get_tree().process_frame
		checks["ready_%d" % stage] = is_instance_valid(pet) and bool(pet.get_meta("pet_nian_unit", false))
		checks["stage_%d" % stage] = int(pet.get("turtle_stage")) == stage
		var sprite := pet.get("turtle_sprite") as AnimatedSprite2D
		checks["sprite_%d" % stage] = sprite != null and sprite.sprite_frames != null
		if sprite != null and sprite.sprite_frames != null:
			checks["wait_%d" % stage] = sprite.sprite_frames.has_animation("wait")
			checks["hit_%d" % stage] = sprite.sprite_frames.has_animation("hit1")
		var action_visual = pet.get("_nian_action_visual")
		checks["parts_%d" % stage] = action_visual != null
		checks["bank_%d" % stage] = _check_bank(pet, 1)
		if stage >= 2:
			checks["bank_skill2_%d" % stage] = _check_bank(pet, 2)
		pet.queue_free()
		await get_tree().process_frame


func _check_bank(pet: Node, skill: int) -> bool:
	var bank: String = str(pet.call("_nian_effect_bank", skill))
	if bank.is_empty():
		return false
	return FileAccess.file_exists("res://Art/pet/pet_nian/official_parts/%s/poses.json" % bank)


func _check_parts(checks: Dictionary) -> void:
	for stage in range(1, 5):
		var parts := PetNianParts.new()
		add_child(parts)
		checks["parts_load_%d" % stage] = parts.load_set("nianshou%d" % stage)
		checks["parts_effect_%d" % stage] = parts.load_set("nianshou%d_effect1" % stage)
		parts.queue_free()
		await get_tree().process_frame
	var parts := PetNianParts.new()
	add_child(parts)
	checks["parts_load"] = parts.load_set("nianshou1")
	checks["parts_max"] = int(parts.max_parts) > 0
	checks["parts_effect_frames"] = parts.get_frame_count("effect1") > 0
	var beam := parts.beam_sample()
	checks["parts_beam_shape"] = beam is Dictionary
	parts.queue_free()
	await get_tree().process_frame


func _check_effects(checks: Dictionary) -> void:
	var scene := load("res://Scene/pet/pet_nian_summon_1.tscn") as PackedScene
	if scene == null:
		checks["effects_scene"] = false
		return
	var pet = scene.instantiate()
	pet.set("pet_data", {DataKeys.LEVEL: 1, DataKeys.ATTACK: 120, DataKeys.HP: 1200, DataKeys.MP: 240})
	add_child(pet)
	await get_tree().process_frame
	await get_tree().process_frame
	var effect = load("res://Script/pet/pet_nian_effect.gd").new()
	effect.summoner = pet
	effect.bank = "nianshou1_effect1"
	effect.direction = 1.0
	effect.power = 100
	effect.hit_size = Vector2(100, 70)
	add_child(effect)
	await get_tree().process_frame
	checks["effect_visual"] = effect.get("visual") != null
	checks["effect_duration"] = float(effect.get("duration")) > 0.0
	effect.queue_free()
	var magic_ball = load("res://Script/pet/pet_nian_magic_ball.gd").new()
	magic_ball.summoner = pet
	magic_ball.bank = "nianshou1_effect1"
	magic_ball.stage = 1
	magic_ball.direction = 1.0
	add_child(magic_ball)
	await get_tree().process_frame
	checks["magic_ball_visual"] = magic_ball.get("visual") != null
	magic_ball.queue_free()
	var beam = load("res://Script/pet/pet_nian_reflected_beam.gd").new()
	beam.summoner = pet
	add_child(beam)
	await get_tree().process_frame
	checks["beam_alive"] = is_instance_valid(beam)
	beam.queue_free()
	pet.queue_free()
	await get_tree().process_frame