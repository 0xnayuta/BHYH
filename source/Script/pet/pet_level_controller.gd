class_name PetLevelController
extends RefCounted
## 关卡宠物生成控制器：当前接管龟布、白虎、青龙三族，其余族仍由 BaseLevel 旧分派处理。
## 控制器只持有生命周期逻辑，族规则由 Pet*Family 提供；不新增 Autoload。

const PET_TURTLE_FAMILY := preload("res://Script/pet/pet_turtle_family.gd")
const PET_TIGER_FAMILY := preload("res://Script/pet/pet_tiger_family.gd")
const PET_DRAGON_FAMILY := preload("res://Script/pet/pet_dragon_family.gd")
const PET_LIFE_BONUS_RUNTIME := preload("res://Script/pet/pet_life_bonus_runtime.gd")
const PET_SKILL_PROGRESSION := preload("res://Script/pet/pet_skill_progression.gd")
const PET_UNIT_METAS := [
	"pet_tiger_unit",
	"pet_dragon_unit",
	"pet_phoenix_unit",
	"pet_turtle_unit",
	"pet_rabbit_unit",
	"pet_mouse_unit",
	"pet_neat_unit",
	"pet_yin_tiger_unit",
]


func spawn_for_slot(level: Node, slot: int, profile: Node, pet_data: Dictionary) -> bool:
	var family = _family_for(pet_data)
	if family == null:
		return false
	if level == null or profile == null:
		return true
	var source_player: Node = level.get("role_p2") if slot == 2 else level.get("_role")
	if not is_instance_valid(source_player) or bool(source_player.get("is_death")):
		return true
	var monster: Node = level.get("monster")
	if monster == null:
		return true
	profile.clamp_pet_level_to_player(pet_data)
	var pet_name: String = str(family.KIND)
	if bool(level.call("_is_active_pet_dead_this_level", pet_name, slot)):
		pet_data[DataKeys.DEPLOYED] = false
		var active_key := _active_pet_name_key()
		if str(profile.player_data.get(active_key, "")) == pet_name:
			profile.player_data[active_key] = ""
			profile.player_data["出战宠物"] = ""
		return true
	if int(pet_data.get(DataKeys.HP, 0)) <= 0:
		pet_data[DataKeys.HP] = int(pet_data.get("生命上限", 1))
	if int(pet_data.get(DataKeys.MP, 0)) <= 0:
		pet_data[DataKeys.MP] = int(pet_data.get("魔法上限", 1))
	var learned_custom_skills: Array = PET_LIFE_BONUS_RUNTIME.learned_skill_names(pet_data)
	var learned_custom_levels: Dictionary = {}
	for learned_skill in learned_custom_skills:
		learned_custom_levels[str(learned_skill)] = PET_SKILL_PROGRESSION.get_level(pet_data, str(learned_skill))
	if _has_pet_unit(monster, slot):
		return true
	family.normalize_spawn(pet_data, profile)
	level.call("_recalculate_active_pet_growth_stats", pet_data)
	level.call("_restore_active_pet_for_level_start", pet_data)
	family.evolve(pet_data, profile)
	if not learned_custom_skills.is_empty():
		var normalized_skills: Array = pet_data.get("技能", []) if pet_data.get("技能", []) is Array else []
		for learned_skill in learned_custom_skills:
			if not normalized_skills.has(learned_skill):
				normalized_skills.append(learned_skill)
		pet_data["技能"] = normalized_skills
		var normalized_levels := PET_SKILL_PROGRESSION.ensure_levels(pet_data)
		for learned_skill in learned_custom_levels:
			normalized_levels[learned_skill] = learned_custom_levels[learned_skill]
	var pet_stage: int = clampi(int(pet_data.get("阶段", 1)), 1, 4)
	await Global.prewarm_active_pet_runtime_resources(slot)
	var scene_path: String = family.scene_path(pet_stage)
	var scene := Global.preload_scene_path(scene_path)
	if scene == null:
		return true
	if not is_instance_valid(source_player) or monster == null:
		return true
	var pet = scene.instantiate()
	pet.set_meta("coop_slot", slot)
	pet.set_meta(str(family.UNIT_META), true)
	pet.set_meta("is_summon", true)
	if pet.has_method("apply_pet_data"):
		pet.apply_pet_data(pet_data)
	family.setup(pet, pet_stage)
	monster.add_child(pet)
	if pet.has_method("apply_pet_data"):
		pet.call_deferred("apply_pet_data", pet_data)
	if not learned_custom_skills.is_empty():
		var life_bonus_runtime := PET_LIFE_BONUS_RUNTIME.new()
		life_bonus_runtime.name = "PetLearnedSkillRuntime"
		life_bonus_runtime.setup(pet_data)
		pet.add_child(life_bonus_runtime)
	level.set_meta(LocalCoop.pet_meta_key("active_pet_unit", slot), pet)
	var spawn_position: Vector2 = level.call("_active_pet_spawn_position", pet, source_player)
	level.call("_place_active_pet_near_role", pet, spawn_position)
	level.call_deferred("_place_active_pet_near_role", pet, spawn_position)
	if pet.has_method("set_summon_properties"):
		pet.call_deferred("set_summon_properties", source_player, 0.0)
	return true


func _family_for(pet_data: Dictionary) -> Variant:
	if PET_TURTLE_FAMILY.matches(pet_data):
		return PET_TURTLE_FAMILY
	if PET_TIGER_FAMILY.matches(pet_data):
		return PET_TIGER_FAMILY
	if PET_DRAGON_FAMILY.matches(pet_data):
		return PET_DRAGON_FAMILY
	return null


func _has_pet_unit(monster: Node, slot: int) -> bool:
	for child in monster.get_children():
		if child == null or child.is_queued_for_deletion():
			continue
		if int(child.get_meta("coop_slot", 1)) != slot:
			continue
		for meta_key in PET_UNIT_METAS:
			if child.has_meta(meta_key):
				return true
	return false


func _active_pet_name_key() -> String:
	return str(PlayerDataStore.ACTIVE_PET_KEY)
