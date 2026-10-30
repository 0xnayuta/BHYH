extends Node

## 八仙 Boss 与三太子动作帧探针（由 scripts/scene_probe_runner.py 复制到工程根目录执行）。
## 验证 21-4A 构建期产出的 body_frames.tres：动画集合、帧数、循环、速度、
## 166/168 与木吒超大帧的裁剪区域，以及 Boss 实例化后确实使用构建期帧。

const RESULT_PREFIX := "ACTION_FRAMES_PROBE_RESULT="
const TEARDOWN_MARKER := "ACTION_FRAMES_PROBE_TEARDOWN"
const EIGHT_IMMORTALS_PATH := "res://Art/monster/game_3_monster/monster_%d/body_actions/body_frames.tres"
const PRINCE_PATH := "res://Art/monster/game_3_monster/three_prince/%s/body_frames.tres"
const EIGHT_IMMORTALS_STATES: Array[StringName] = [
	&"wait", &"walk", &"hurt", &"death", &"hit1", &"hit2", &"hit3"
]
const EIGHT_IMMORTALS_COUNTS := {
	163: {"hit1": 4, "hit2": 3, "hit3": 3},
	164: {"hit1": 3, "hit2": 3, "hit3": 2},
	165: {"hit1": 4, "hit2": 2, "hit3": 3},
	166: {"hit1": 3, "hit2": 4, "hit3": 2},
	168: {"hit1": 4, "hit2": 4, "hit3": 4},
	169: {"hit1": 3, "hit2": 2, "hit3": 6},
	174: {"hit1": 3, "hit2": 4, "hit3": 3},
	175: {"hit1": 3, "hit2": 2, "hit3": 2},
}
const PRINCE_COUNTS := {
	"jinzha": {"idle": 6, "walk": 4, "hurt": 1, "death": 5, "hit1": 4, "hit2": 3, "hit3": 4, "hit4": 1},
	"muzha": {"idle": 6, "walk": 4, "hurt": 1, "death": 5, "hit1": 6, "hit2": 4, "hit3": 6, "hit4": 6},
}

var _failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var checks: Dictionary = {}
	_check_eight_immortals(checks)
	_check_three_prince(checks)
	await _check_boss_instances(checks)

	checks["teardown"] = true
	for check_name in checks:
		if not bool(checks[check_name]):
			_failures.append(str(check_name))
	var payload := {"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": checks}
	print(RESULT_PREFIX + JSON.stringify(payload))
	print(TEARDOWN_MARKER)


func _check_eight_immortals(checks: Dictionary) -> void:
	for monster_id in EIGHT_IMMORTALS_COUNTS:
		var frames := load(EIGHT_IMMORTALS_PATH % monster_id) as SpriteFrames
		checks["eight_%d_frames" % monster_id] = frames != null
		if frames == null:
			continue
		var names := frames.get_animation_names()
		checks["eight_%d_animations" % monster_id] = names.size() == EIGHT_IMMORTALS_STATES.size()
		var counts_ok := true
		var loop_ok := true
		var speed_ok := true
		for state in EIGHT_IMMORTALS_STATES:
			var expected := 6 if state == &"wait" else (4 if state == &"walk" else (1 if state == &"hurt" else (5 if state == &"death" else int(EIGHT_IMMORTALS_COUNTS[monster_id][String(state)]))))
			counts_ok = counts_ok and frames.get_frame_count(state) == expected
			loop_ok = loop_ok and frames.get_animation_loop(state) == (state in [&"wait", &"walk"])
			speed_ok = speed_ok and is_equal_approx(frames.get_animation_speed(state), 24.0)
		checks["eight_%d_counts" % monster_id] = counts_ok
		checks["eight_%d_loop" % monster_id] = loop_ok
		checks["eight_%d_speed" % monster_id] = speed_ok
	# 166 hit2 与 168 hit2 必须在构建期裁成运行期原来的区域。
	var crop_166 := _atlas_region((load(EIGHT_IMMORTALS_PATH % 166) as SpriteFrames).get_frame_texture(&"hit2", 0))
	checks["eight_166_hit2_crop"] = crop_166 == Rect2(0, 0, 250, 250)
	var crop_168 := _atlas_region((load(EIGHT_IMMORTALS_PATH % 168) as SpriteFrames).get_frame_texture(&"hit2", 0))
	checks["eight_168_hit2_crop"] = crop_168 == Rect2(40, 0, 250, 200)
	var plain_163 := (load(EIGHT_IMMORTALS_PATH % 163) as SpriteFrames).get_frame_texture(&"hit2", 0)
	checks["eight_163_hit2_uncropped"] = plain_163 != null and not (plain_163 is AtlasTexture)


func _check_three_prince(checks: Dictionary) -> void:
	for root_name in PRINCE_COUNTS:
		var frames := load(PRINCE_PATH % root_name) as SpriteFrames
		checks["prince_%s_frames" % root_name] = frames != null
		if frames == null:
			continue
		var names := frames.get_animation_names()
		checks["prince_%s_animations" % root_name] = names.size() == 8
		var counts_ok := true
		var loop_ok := true
		var speed_ok := true
		for action in PRINCE_COUNTS[root_name]:
			var key := StringName(action)
			counts_ok = counts_ok and frames.get_frame_count(key) == int(PRINCE_COUNTS[root_name][action])
			loop_ok = loop_ok and frames.get_animation_loop(key) == (action in ["idle", "walk"])
			speed_ok = speed_ok and is_equal_approx(frames.get_animation_speed(key), 24.0)
		checks["prince_%s_counts" % root_name] = counts_ok
		checks["prince_%s_loop" % root_name] = loop_ok
		checks["prince_%s_speed" % root_name] = speed_ok
	var muzha_hit3 := _atlas_region((load(PRINCE_PATH % "muzha") as SpriteFrames).get_frame_texture(&"hit3", 0))
	checks["prince_muzha_hit3_crop"] = muzha_hit3 == Rect2(21, 0, 250, 250)
	var jinzha_hit3 := (load(PRINCE_PATH % "jinzha") as SpriteFrames).get_frame_texture(&"hit3", 0)
	checks["prince_jinzha_hit3_uncropped"] = jinzha_hit3 != null and not (jinzha_hit3 is AtlasTexture)


func _check_boss_instances(checks: Dictionary) -> void:
	# 临时关闭血条挂载，避免探针根节点缺少关卡 monster_blood 容器。
	var previous_blood: Variant = MainSet.set_data.get("MonsterBloodSHow", true)
	MainSet.set_data["MonsterBloodSHow"] = false
	for scene_path in [
		"res://Scene/monster/monster_163.tscn",
		"res://Scene/monster/monster_4402.tscn",
		"res://Scene/monster/monster_4403.tscn",
	]:
		var packed := load(scene_path) as PackedScene
		var boss = packed.instantiate() if packed != null else null
		var label: String = str(scene_path).get_file().get_basename()
		checks["%s_instantiated" % label] = boss != null
		if boss == null:
			continue
		add_child(boss)
		await get_tree().process_frame
		await get_tree().process_frame
		checks["%s_uses_build_frames" % label] = (
			boss.mr_ani != null
			and boss.mr_ani.sprite_frames != null
			and boss.mr_ani.sprite_frames.get_animation_names().size() >= 7
		)
		checks["%s_animation" % label] = (
			boss.mr_ani != null and boss.mr_ani.animation in [&"wait", &"idle"]
		)
		boss.queue_free()
		await get_tree().process_frame
	MainSet.set_data["MonsterBloodSHow"] = previous_blood


func _atlas_region(texture: Texture2D) -> Rect2:
	if texture is AtlasTexture:
		return (texture as AtlasTexture).region
	return Rect2()
