extends Node

## 星座 Boss 运行时探针（由 scripts/scene_probe_runner.py 复制到工程根目录并执行）。
## 走 --scene 通道，确保 Autoload 注册先于依赖脚本编译；验证 body 流、技能
## 标准 SpriteFrames 与 FrameSequence 回退三条真实运行路径。

const RESULT_PREFIX := "CONSTELLATION_PROBE_RESULT="
const SOURCE_ID := 140
const BODY_KEY := "constellation/140/body/wait"
const BODY_ACTIONS := [
	"wait", "walk", "hurt", "death", "hit1", "hit2", "hit3", "hit4", "skill1", "skill2", "skill3", "skill4"
]
const STANDARD_FRAMES := "res://Art/constellations/boss/140/atlas/constellation_140_frames.tres"
const SKILL_ROOT := "res://Art/constellations/boss/140/"
const BODY_FPS := 24.0
const BODY_CANVAS := Vector2i(250, 250)
const BODY_OFFSET := Vector2(10.0, -15.0)

var _failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var checks: Dictionary = {}
	_verify_body_catalog(checks)
	await _verify_body_stream(checks)
	await _verify_skill_visual(checks, "skill1", false, true)
	await _verify_skill_visual(checks, "skill2", false, true)
	await _verify_skill_visual(checks, "skill3", false, true)
	await _verify_skill_visual(checks, "skill4", false, true)
	await _verify_skill_visual(checks, "skill2_2", false, true)
	await _verify_skill_visual(checks, "skill2_3", true, false)
	var payload := {"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": checks}
	print(RESULT_PREFIX + JSON.stringify(payload))
	get_tree().quit(0 if _failures.is_empty() else 1)


func _verify_body_catalog(checks: Dictionary) -> void:
	var present := 0
	for action: String in BODY_ACTIONS:
		var looped: bool = action in ["wait", "walk"]
		var key: String = "constellation/%d/body/%s" % [SOURCE_ID, action]
		if not FrameSequenceStore.has_sequence(key, BODY_FPS, looped, not looped, 2):
			_fail("缺少星座 body 序列: " + key)
			continue
		if FrameSequenceStore.get_sequence(key, BODY_FPS, looped, not looped, 2).count() <= 0:
			_fail("星座 body 序列为空: " + key)
			continue
		present += 1
	checks["body_actions"] = "%d/%d" % [present, BODY_ACTIONS.size()]
	checks["body_catalog"] = present == BODY_ACTIONS.size()


func _verify_body_stream(checks: Dictionary) -> void:
	if not FrameSequenceStore.has_sequence(BODY_KEY, BODY_FPS, true, false, 2):
		checks["body_stream"] = false
		return
	var stream := ConstellationBodyStream.new()
	stream.sequence = FrameSequenceStore.get_sequence(BODY_KEY, BODY_FPS, true, false, 2)
	stream.auto_free = false
	stream.configure_canvas(BODY_CANVAS, BODY_OFFSET, true)
	add_child(stream)
	await _wait_frames(4)
	var displayed := stream.has_displayed_frame()
	checks["body_stream_displayed"] = displayed
	if not displayed:
		_fail("星座 body 流未显示首帧")
	stream.queue_free()
	await _wait_frames(1)


func _verify_skill_visual(checks: Dictionary, folder: String, hold_last: bool, expect_standard: bool) -> void:
	var frames := load(STANDARD_FRAMES) as SpriteFrames
	var animation := StringName(folder)
	var frame_count := 1
	if frames != null and frames.has_animation(animation):
		frame_count = frames.get_frame_count(animation)
	var projectile := WutaiMinghaiProjectile.new()
	(
		projectile
		. configure(
			{
				"position": Vector2.ZERO,
				"frame_root": SKILL_ROOT + folder,
				"frames_resource": STANDARD_FRAMES,
				"frames_animation": folder,
				"atlas_sequence": folder,
				"frame_count": frame_count,
				"frame_fps": BODY_FPS,
				"hold_last_frame": hold_last,
				"collision_size": Vector2(10.0, 10.0),
				"damage_enabled": false,
				"lifetime": 1.0,
			}
		)
	)
	add_child(projectile)
	await _wait_frames(4)
	var standard_visual: Variant = projectile.get("_standard_visual")
	var visual_stream: Variant = projectile.get("_visual_stream")
	checks[folder + "_standard"] = standard_visual != null
	checks[folder + "_stream"] = visual_stream != null
	if expect_standard and standard_visual == null:
		_fail(folder + " 未走标准 SpriteFrames 路径")
	if not expect_standard and visual_stream == null:
		_fail(folder + " 未走 FrameSequence 回退路径")
	projectile.queue_free()
	await _wait_frames(1)


func _wait_frames(count: int) -> void:
	for _index in range(count):
		await get_tree().process_frame


func _fail(message: String) -> void:
	_failures.append(message)
