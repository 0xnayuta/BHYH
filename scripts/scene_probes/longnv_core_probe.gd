extends Node

## 小龙女 1P 核心探针：实例化 Role_8，验证 20 个技能入口与普通攻击动作可启动。
## 由 scripts/scene_probe_runner.py 复制到工程根目录执行。

const RESULT_PREFIX := "LONGNV_CORE_PROBE_RESULT="
const TEARDOWN_MARKER := "LONGNV_CORE_PROBE_TEARDOWN"
const ROLE_SCENE := "res://Scene/hero/role_8/role_8.tscn"

var _failures: Array[String] = []
var _checks: Dictionary = {}


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var host := Node2D.new()
	host.name = "LongnvCoreProbeHost"
	add_child(host)

	PlayerData.player_data["Myself"] = 8
	PlayerData.player_data[DataKeys.PLAYER_LEVEL] = 1
	PlayerData.ensure_skill_data()
	for index in range(1, 21):
		var skill: Dictionary = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能" + str(index)]
		skill[DataKeys.LEVEL] = 1
		skill["学习"] = 1
	RoleProp.set_basic_prop()
	RoleProp.roleprop.Mp = 999999
	RoleProp.roleprop.SMp = 999999
	RoleProp.roleprop.Hp = 999999
	RoleProp.roleprop.SHp = 999999

	var hero = Global.call_hero("role_8", host, Vector2.ZERO, false)
	await get_tree().process_frame
	await get_tree().process_frame
	_checks["role_scene_registered"] = ResourceLoader.exists(ROLE_SCENE)
	_checks["hero_spawned"] = hero != null and is_instance_valid(hero)
	_checks["hero_class"] = hero is LongnvHero
	_checks["skill_count"] = LongnvSkillData.KEYS.size() == 20
	if not is_instance_valid(hero):
		_report()
		return

	_checks["body_loaded"] = str(hero.role_body.get("source_set")) == "default"
	_checks["animations_loaded"] = hero.role_action_player.has_animation("effect1")
	var hero_props = hero.call("_props")
	hero_props.roleprop.Mp = 999999
	hero_props.roleprop.SMp = 999999
	for index in range(LongnvSkillData.KEYS.size()):
		var key: String = LongnvSkillData.KEYS[index]
		hero_props.roleprop.Mp = 999999
		if hero.role1_skill_inter.has(key):
			hero.role1_skill_inter[key] = 0.0
		hero.set("_active", false)
		hero.set("is_using_skills", false)
		hero.set("is_attacking", false)
		hero.call("get_skill", key)
		for _frame in range(24):
			await get_tree().physics_frame
		_checks["skill_%02d_%s" % [index + 1, key]] = bool(hero.get("_active"))
		hero.call("_finish_action")
		await get_tree().process_frame

	hero.set("is_using_skills", false)
	hero.set("is_attacking", false)
	hero.call("_start_melee", "hit1")
	await get_tree().physics_frame
	_checks["melee_started"] = bool(hero.get("_active"))
	hero.call("_finish_action")

	for check_name in _checks:
		if not bool(_checks[check_name]):
			_failures.append(str(check_name))
	_report()
	if is_instance_valid(hero):
		hero.queue_free()


func _report() -> void:
	print(RESULT_PREFIX + JSON.stringify({"ok": _failures.is_empty(), "failures": _failures, "checks": _checks}))
	print(TEARDOWN_MARKER)
	get_tree().quit(0 if _failures.is_empty() else 1)
