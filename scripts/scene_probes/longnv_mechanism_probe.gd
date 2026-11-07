extends Node

## 小龙女 7.1 机关规格探针：七星洞升墙、入口门、尾妖林灯、北俱芦洲龙珠与白骨/玲珑宝塔。
## 由 scripts/scene_probe_runner.py 复制到工程根目录执行。

const RESULT_PREFIX := "LONGNV_MECHANISM_PROBE_RESULT="
const TEARDOWN_MARKER := "LONGNV_MECHANISM_PROBE_TEARDOWN"

var _checks: Dictionary = {}
var _failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var saved_data: Dictionary = PlayerData.player_data.duplicate(true)
	var saved_settings: Dictionary = MainSet.set_data.duplicate(true)
	var saved_cd_path: String = Global.get_cd_path()
	Global.set_cd_path("")
	MainSet.set_auto_battle_enabled(false)
	PlayerData.player_data = PlayerData.initialized_data.duplicate(true)
	PlayerData.player_data["Myself"] = 8
	PlayerData.player_data["实战法宝"] = ""
	PlayerData.player_data["宠物"] = []
	for slot in ["武器", "防具", "时装", "法宝", "翅膀", "头衔"]:
		PlayerData.player_data[slot] = []
	for slot in PlayerData.player_data["幻化列表"]:
		PlayerData.player_data["幻化列表"][slot] = ""
	PlayerData.ensure_skill_data()
	RoleProp.set_physics_process(false)
	_check_continent_growth()

	await _check_level_5()
	await _check_doors()
	await _check_lights()
	await _check_north_dragon()
	await _check_bai_gu_and_tower()

	RoleProp.source_player = null
	PlayerData.player_data = saved_data
	MainSet.set_data = saved_settings
	Global.set_cd_path(saved_cd_path)
	_report()


func _check_continent_growth() -> void:
	var previous := (load("res://Script/level/level_74.gd") as GDScript).new() as Game4EastLateLevel
	if previous == null:
		_checks["continent_growth_baseline"] = false
		return
	var baseline := previous.get_level_monster_config(3340)
	previous.free()
	var growth := preload("res://Script/level/continent_monster_growth.gd")
	var scaled: Dictionary = growth.apply(baseline, 2)
	var unchanged: Dictionary = growth.apply(baseline, 0)
	_checks["continent_growth_baseline"] = baseline.has("hp")
	if baseline.has("hp"):
		var expected := roundi(roundi(float(baseline["hp"]) * 1.1) * 1.1)
		_checks["continent_growth_two_steps"] = int(scaled["hp"]) == expected
		_checks["continent_growth_zero_steps"] = int(unchanged["hp"]) == int(baseline["hp"])


func _check_level_5() -> void:
	var level := await _open_level(5)
	if level == null:
		_checks["level_5_open"] = false
		return
	_checks["level_5_open"] = true
	var hero: LongnvHero = level.get("_role") as LongnvHero
	var area := level.get_node_or_null("jg") as Area2D
	if hero == null or area == null:
		_checks["level_5_actors"] = false
		await _close_level(level)
		return
	_checks["level_5_actors"] = true
	_hit(hero, area)
	_checks["level_5_gate_locked"] = int(level.get("hit_count")) == 0
	level.set("current_stage", 3)
	var groups: Dictionary = level.get("monster_group")
	groups["stage_3"] = []
	level.set("monster_group", groups)
	level.call("set_through")
	var stop_3 := level.get("stop_3") as CollisionShape2D
	_checks["level_5_gate_enabled"] = stop_3 != null and stop_3.disabled
	level.call("_physics_process", 0.0)
	await _settle()

	var pulse: Dictionary = {}
	_hit(hero, area, pulse)
	_hit(hero, area, pulse)
	_checks["level_5_same_pulse_once"] = int(level.get("hit_count")) == 1
	hero.hit_original_area(area.global_position, Vector2(50, 50), 0.0, {})
	hero.hit_original_area(area.global_position + Vector2(400, 0), Vector2(10, 10), 100.0, {})
	_checks["level_5_zero_or_miss"] = int(level.get("hit_count")) == 1
	area.monitoring = false
	_hit(hero, area)
	_checks["level_5_monitoring_guard"] = int(level.get("hit_count")) == 1
	area.monitoring = true

	var blade = preload("res://Script/hero/longnv_flying_blade.gd").new()
	blade.player = hero
	blade.position = area.global_position
	blade.speed = 0.0
	blade.damage = 100.0
	add_child(blade)
	blade.set_physics_process(false)
	blade._physics_process(0.01)
	blade._physics_process(0.01)
	_checks["level_5_blade_once"] = int(level.get("hit_count")) == 2
	blade.free()
	for _index in range(3):
		_hit(hero, area)
	_checks["level_5_five_hits"] = int(level.get("hit_count")) == 5
	var camera := level.get("my_camera") as Camera2D
	if camera != null:
		camera.enabled = false
	var view_camera := Camera2D.new()
	view_camera.position = Vector2(3500, 180)
	level.add_child(view_camera)
	hero.position = Vector2(3450, 290)
	hero.velocity = Vector2.ZERO
	level.call("_physics_process", 0.0)
	for _index in range(12):
		level.call("_physics_process", 0.0)
		await get_tree().process_frame
	await get_tree().create_timer(2.2).timeout
	var wall := level.get_node_or_null("Wall") as Node2D
	var stage2 := level.get_node_or_null("Wall/StaticBody2D/stage2") as CollisionShape2D
	_checks["level_5_wall_open"] = bool(level.get("is_set")) and wall != null and not wall.visible
	_checks["level_5_wall_collision"] = stage2 != null and stage2.disabled
	_hit(hero, area)
	_checks["level_5_completed_cap"] = int(level.get("hit_count")) == 5
	await _close_level(level)


func _check_doors() -> void:
	for number: int in [23, 27, 38]:
		var level := await _open_level(number)
		if level == null:
			_checks["level_%d_open" % number] = false
			continue
		var hero: LongnvHero = level.get("_role") as LongnvHero
		var area := level.get_node_or_null("DoorCheck" if number == 27 else "Check") as Area2D
		if hero == null or area == null:
			_checks["level_%d_actors" % number] = false
			await _close_level(level)
			continue
		for child in area.get_children():
			if child is CollisionShape2D:
				(child as CollisionShape2D).disabled = false
		await _settle()
		for _index in range(5):
			_hit(hero, area)
		var count_key := "hit_count" if number == 27 else "hurt_count"
		_checks["level_%d_five_hits" % number] = int(level.get(count_key)) == 5
		level.call("_physics_process", 0.0)
		if number == 27:
			_checks["level_27_door"] = bool(level.get("is_open"))
		else:
			_checks["level_%d_door" % number] = bool(level.get("is_play"))
		_checks["level_%d_signal" % number] = not area.get_signal_connection_list("area_entered").is_empty()
		await get_tree().create_timer(1.5).timeout
		await _close_level(level)


func _check_lights() -> void:
	for number: int in [28, 34]:
		var level := await _open_level(number)
		if level == null:
			_checks["level_%d_open" % number] = false
			continue
		var hero: LongnvHero = level.get("_role") as LongnvHero
		var group := level.get_node_or_null("jg") as Node2D
		if hero == null or group == null:
			_checks["level_%d_actors" % number] = false
			await _close_level(level)
			continue
		for light in group.get_children():
			var area := light.get_node_or_null("Area2D") as Area2D
			if area == null:
				continue
			var before := bool(light.get("is_light"))
			_hit(hero, area)
			_checks["level_%d_light_%s_hit" % [number, light.name]] = bool(light.get("is_light")) != before
			_hit(hero, area)
			_checks["level_%d_light_%s_cooldown" % [number, light.name]] = bool(light.get("is_light")) != before
		if number == 34:
			_checks["level_34_lights_match"] = bool(level.call("_check_lights_match"))
			level.call("_physics_process", 0.0)
			await _settle()
			var area := level.get_node_or_null("Check") as Area2D
			if area != null:
				_hit(hero, area)
				_hit(hero, area)
			_checks["level_34_hidden_entrance"] = int(level.get("hurt_count")) == 2
		await _close_level(level)


func _check_north_dragon() -> void:
	var level := await _open_level(82)
	if level == null:
		_checks["level_82_open"] = false
		return
	var hero: LongnvHero = level.get("_role") as LongnvHero
	var terrain := level.get_node_or_null("OriginalTerrain")
	if hero == null or terrain == null:
		_checks["level_82_actors"] = false
		await _close_level(level)
		return
	var statues := 0
	var records: Array = terrain.get("_source_objects")
	for record: Dictionary in records:
		if record.get("type") != "DragonItemEntity":
			continue
		statues += 1
		var area := record.get("target") as Area2D
		_hit(hero, area)
		_checks["level_82_dragon_%d" % statues] = (
			float(record.get("revive_at", 0.0)) > 0.0 and not (record.get("sprite") as Node2D).visible
		)
	_checks["level_82_dragon_count"] = statues > 0
	await get_tree().create_timer(0.6).timeout
	var lit := false
	for record: Dictionary in records:
		if record.get("type") == "LightEntity" and float(record.get("lit_until", 0.0)) > float(terrain.get("_clock")):
			lit = true
	_checks["level_82_light"] = lit
	await _close_level(level)


func _check_bai_gu_and_tower() -> void:
	var holder := Node2D.new()
	add_child(holder)
	var hero: LongnvHero = Global.call_hero("role_8", holder, Vector2(620, 450), true) as LongnvHero
	hero.set_physics_process(false)
	var bone := (load("res://Scene/level/bai_gu_level.tscn") as PackedScene).instantiate()
	add_child(bone)
	bone.set_physics_process(false)
	bone.position = Vector2(450, 300)
	await _settle()
	var hurt_box := bone.get_node_or_null("Hurt_box") as Area2D
	for _index in range(5):
		_hit(hero, hurt_box)
	_checks["bai_gu_five_hits"] = int(bone.get("hit_count")) == 5
	bone.call("_physics_process", 0.0)
	var show := bone.get_node_or_null("Show") as AnimationPlayer
	_checks["bai_gu_show"] = show != null and show.current_animation == "Show"
	await get_tree().create_timer(2.0).timeout
	bone.free()

	var tower := (load("res://Scene/level/level_llbt.tscn") as PackedScene).instantiate()
	var area := tower.get_node_or_null("LZ/Area2D") as Area2D
	if area == null:
		_checks["llbt_area"] = false
		tower.free()
		holder.free()
		return
	area.owner = null
	tower.get_node("LZ").remove_child(area)
	add_child(area)
	area.position = Vector2(450, 300)
	area.monitoring = true
	var shape := area.get_child(0) as CollisionShape2D
	if shape != null:
		shape.disabled = false
	tower.set("lz_sprite", tower.get_node("LZ/LZDZ/LZ"))
	area.area_entered.connect(tower._on_lz_area_entered)
	await _settle()
	_hit(hero, area)
	_hit(hero, area)
	_checks["llbt_two_hits"] = int(tower.get("lz_hit_count")) == 2
	tower.set("lz_triggered", true)
	_hit(hero, area)
	_checks["llbt_triggered_cap"] = int(tower.get("lz_hit_count")) == 2
	area.free()
	tower.free()
	holder.free()


func _open_level(number: int) -> Node:
	var packed := load("res://Scene/level/level_%d.tscn" % number) as PackedScene
	if packed == null:
		return null
	var level := packed.instantiate()
	add_child(level)
	level.set_physics_process(false)
	var control: Node = level.get("create_control") as Node
	if control != null and control.has_method("stop"):
		control.call("stop")
	var hero := level.get("_role") as Node
	if hero != null:
		hero.set_physics_process(false)
		hero.set("needProtect", true)
	await get_tree().create_timer(0.3).timeout
	var control_after: Node = level.get("create_control") as Node
	if control_after != null and control_after.has_method("stop"):
		control_after.call("stop")
	var monster := level.get("monster") as Node
	if monster != null:
		for enemy in monster.get_children():
			enemy.free()
	level.set("current_stage", 0)
	return level


func _close_level(level: Node) -> void:
	level.queue_free()
	await get_tree().create_timer(0.15).timeout
	RoleProp.source_player = null


func _hit(hero: LongnvHero, area: Area2D, targets: Dictionary = {}) -> void:
	if hero == null or area == null:
		return
	var center := area.global_position
	for child in area.get_children():
		if child is CollisionShape2D:
			center = (child as CollisionShape2D).global_position
			break
	hero.hit_original_area(center, Vector2(12, 12), 100.0, targets)


func _settle() -> void:
	await get_tree().physics_frame
	await get_tree().process_frame


func _report() -> void:
	for check_name in _checks:
		if not bool(_checks[check_name]):
			_failures.append(str(check_name))
	var payload := {"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": _checks}
	print(RESULT_PREFIX + JSON.stringify(payload))
	print(TEARDOWN_MARKER)
	get_tree().quit(0 if _failures.is_empty() else 1)
