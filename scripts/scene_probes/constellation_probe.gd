extends Node

## 星座 Boss 运行时探针（由 scripts/scene_probe_runner.py 复制到工程根目录并执行）。
## 走 --scene 通道，确保 Autoload 注册先于依赖脚本编译；验证 body 流、
## 技能按真实资源显式选择标准 SpriteFrames 或 FrameSequence 后端。
## 错误动画拒绝用例仅在显式传入 --verify-visual-backend-rejection 时运行，
## 避免预期 push_error 污染常规 0/0 成功判据。

const RESULT_PREFIX := "CONSTELLATION_PROBE_RESULT="
const SOURCE_ID := 140
const BODY_KEY := "constellation/140/body/wait"
const BODY_ACTIONS := [
	"wait", "walk", "hurt", "death", "hit1", "hit2", "hit3", "hit4", "skill1", "skill2", "skill3", "skill4"
]
const STANDARD_FRAMES := "res://Art/constellations/boss/140/atlas/constellation_140_frames.tres"
const BODY_FPS := 24.0
const SKILL_FPS := 24.0
const BODY_CANVAS := Vector2i(250, 250)
const BODY_OFFSET := Vector2(10.0, -15.0)
const NEGATIVE_CHECK_FLAG := "--verify-visual-backend-rejection"

var _failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var checks: Dictionary = {}
	_verify_body_catalog(checks)
	await _verify_body_stream(checks)
	await _verify_skill_visual(checks, "skill1", false, WutaiMinghaiProjectile.VisualBackend.SPRITE_FRAMES)
	await _verify_skill_visual(checks, "skill2", false, WutaiMinghaiProjectile.VisualBackend.SPRITE_FRAMES)
	await _verify_skill_visual(checks, "skill3", false, WutaiMinghaiProjectile.VisualBackend.SPRITE_FRAMES)
	await _verify_skill_visual(checks, "skill4", false, WutaiMinghaiProjectile.VisualBackend.SPRITE_FRAMES)
	await _verify_skill_visual(checks, "skill2_2", false, WutaiMinghaiProjectile.VisualBackend.SPRITE_FRAMES)
	await _verify_skill_visual(checks, "skill2_3", false, WutaiMinghaiProjectile.VisualBackend.FRAME_SEQUENCE)
	await _verify_sequence_lifecycle(checks)
	if NEGATIVE_CHECK_FLAG in OS.get_cmdline_user_args():
		await _verify_wrong_animation_rejected(checks)
	var payload := {"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": checks}
	print(RESULT_PREFIX + JSON.stringify(payload))
	get_tree().quit(0 if _failures.is_empty() else 1)


func _verify_body_catalog(checks: Dictionary) -> void:
	var present := 0
	for action: String in BODY_ACTIONS:
		var key: String = "constellation/%d/body/%s" % [SOURCE_ID, action]
		if not FrameSequenceStore.has_sequence(StringName(key)):
			_fail("缺少星座 body 序列: " + key)
			continue
		if FrameSequenceStore.get_sequence(StringName(key)).count() <= 0:
			_fail("星座 body 序列为空: " + key)
			continue
		present += 1
	checks["body_actions"] = "%d/%d" % [present, BODY_ACTIONS.size()]
	checks["body_catalog"] = present == BODY_ACTIONS.size()


func _verify_body_stream(checks: Dictionary) -> void:
	if not FrameSequenceStore.has_sequence(StringName(BODY_KEY)):
		checks["body_stream"] = false
		return
	var stream := ConstellationBodyStream.new()
	stream.sequence = FrameSequenceStore.get_sequence(StringName(BODY_KEY))
	stream.configure_playback(BODY_FPS, true, false, 2)
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


func _verify_skill_visual(
	checks: Dictionary, folder: String, hold_last: bool, expected_backend: int
) -> void:
	var frames := load(STANDARD_FRAMES) as SpriteFrames
	var animation := StringName(folder)
	var frame_count := 0
	if frames != null and frames.has_animation(animation):
		frame_count = frames.get_frame_count(animation)
	if expected_backend == WutaiMinghaiProjectile.VisualBackend.FRAME_SEQUENCE:
		var asset_id := StringName("constellation/%d/skill/%s" % [SOURCE_ID, folder])
		if not FrameSequenceStore.has_sequence(asset_id):
			checks[folder + "_catalog"] = false
			_fail(folder + " 缺少 FrameSequence")
			return
		frame_count = FrameSequenceStore.get_sequence(asset_id).count()
	var config := {
		"position": Vector2.ZERO,
		"frame_count": frame_count,
		"frame_fps": SKILL_FPS,
		"loop_visual": false,
		"hold_last_frame": hold_last,
		"visual_backend": expected_backend,
		"collision_size": Vector2(10.0, 10.0),
		"damage_enabled": false,
		"lifetime": 1.0,
	}
	if expected_backend == WutaiMinghaiProjectile.VisualBackend.FRAME_SEQUENCE:
		config["frame_asset_id"] = "constellation/%d/skill/%s" % [SOURCE_ID, folder]
	else:
		config["frames_resource"] = STANDARD_FRAMES
		config["frames_animation"] = folder
	var projectile := WutaiMinghaiProjectile.new()
	var configured := projectile.configure(config)
	checks[folder + "_configured"] = configured
	checks[folder + "_backend"] = projectile.visual_backend == expected_backend
	if not configured:
		_fail(folder + " 显式后端配置失败")
		projectile.queue_free()
		return
	add_child(projectile)
	await _wait_frames(4)
	var standard_visual: Variant = projectile.get("_standard_visual")
	var visual_stream: Variant = projectile.get("_visual_stream")
	checks[folder + "_standard"] = standard_visual != null
	checks[folder + "_stream"] = visual_stream != null
	if expected_backend == WutaiMinghaiProjectile.VisualBackend.SPRITE_FRAMES:
		if standard_visual == null or visual_stream != null:
			_fail(folder + " 未按 SpriteFrames 后端创建唯一消费者")
	else:
		if visual_stream == null or standard_visual != null:
			_fail(folder + " 未按 FrameSequence 后端创建唯一消费者")
	projectile.queue_free()
	await _wait_frames(1)


func _verify_wrong_animation_rejected(checks: Dictionary) -> void:
	var frames := load(STANDARD_FRAMES) as SpriteFrames
	var frame_count := 1
	if frames != null and frames.has_animation(&"skill1"):
		frame_count = frames.get_frame_count(&"skill1")
	var projectile := WutaiMinghaiProjectile.new()
	var configured := projectile.configure(
		{
			"position": Vector2.ZERO,
			"visual_backend": WutaiMinghaiProjectile.VisualBackend.SPRITE_FRAMES,
			"frames_resource": STANDARD_FRAMES,
			"frames_animation": "skill2_3",
			"frame_asset_id": "constellation/%d/skill/skill2_3" % SOURCE_ID,
			"frame_count": frame_count,
			"frame_fps": SKILL_FPS,
			"loop_visual": false,
			"collision_size": Vector2(10.0, 10.0),
			"damage_enabled": false,
			"lifetime": 1.0,
		}
	)
	checks["wrong_animation_configured"] = configured
	if configured:
		_fail("错误动画不得被 SpriteFrames 后端接纳")
	add_child(projectile)
	await _wait_frames(2)
	checks["wrong_animation_rejected"] = not is_instance_valid(projectile)
	if is_instance_valid(projectile):
		_fail("错误配置的弹体必须被释放，不能继续形成隐形判定")
		projectile.queue_free()
		await _wait_frames(1)
	var missing_only := WutaiMinghaiProjectile.new()
	var missing_configured := missing_only.configure(
		{
			"position": Vector2.ZERO,
			"visual_backend": WutaiMinghaiProjectile.VisualBackend.SPRITE_FRAMES,
			"frames_resource": STANDARD_FRAMES,
			"frames_animation": "skill2_3",
			"frame_count": frame_count,
			"frame_fps": SKILL_FPS,
			"loop_visual": false,
			"collision_size": Vector2(10.0, 10.0),
			"damage_enabled": false,
			"lifetime": 1.0,
		}
	)
	checks["missing_animation_configured"] = missing_configured
	if missing_configured:
		_fail("缺失动画不得被 SpriteFrames 后端接纳")
	add_child(missing_only)
	await _wait_frames(2)
	checks["missing_animation_rejected"] = not is_instance_valid(missing_only)
	if is_instance_valid(missing_only):
		_fail("缺失动画的弹体必须被释放")
		missing_only.queue_free()
		await _wait_frames(1)


func _verify_sequence_lifecycle(checks: Dictionary) -> void:
	FrameSequenceStore.clear_prewarmed_textures()
	var source := FrameSequenceStore.get_sequence(StringName("constellation/%d/skill/skill2_3" % SOURCE_ID))
	var path: String = source.frame_paths[0]
	await FrameSequenceStore.prewarm_sequence(source)
	checks["texture_prewarm_ready"] = ResourceLoader.has_cached(path)
	var a := StreamedPngEffect.new()
	var b := StreamedPngEffect.new()
	a.sequence = source
	b.sequence = source
	a.manual_frame_control = true
	b.manual_frame_control = true
	a.auto_free = false
	b.auto_free = false
	add_child(a)
	add_child(b)
	await _wait_frames(4)
	a.queue_free()
	await _wait_frames(2)
	checks["shared_request_survivor"] = b.has_displayed_frame()
	b.queue_free()
	FrameSequenceStore.clear_prewarmed_textures()
	var held := FrameSequence.new()
	held.asset_id = &"probe/hold_last_frame"
	held.frame_paths = PackedStringArray([path, path])
	held.default_fps = 120.0
	held.default_hold_last_frame = true
	var player := StreamedPngEffect.new()
	player.sequence = held
	player.auto_free = false
	add_child(player)
	await _wait_frames(8)
	checks["hold_last_frame"] = player.has_displayed_frame() and player.displayed_frame() == 1
	player.queue_free()
	var manual := StreamedPngEffect.new()
	manual.sequence = held
	manual.manual_frame_control = true
	manual.auto_free = false
	add_child(manual)
	manual.show_frame(1)
	await _wait_frames(4)
	checks["manual_jump"] = manual.has_displayed_frame() and manual.displayed_frame() == 1
	manual.queue_free()
	var orphan := StreamedPngEffect.new()
	orphan.sequence = source
	orphan.auto_free = false
	add_child(orphan)
	orphan.queue_free()
	for index in range(120):
		await _wait_frames(1)
		if FrameTextureRequests.pending_count() == 0 and FrameTextureRequests.retained_count() == 0:
			break
	checks["requests_drained_after_free"] = FrameTextureRequests.pending_count() == 0 and FrameTextureRequests.retained_count() == 0
	for key: String in ["texture_prewarm_ready", "shared_request_survivor", "hold_last_frame", "manual_jump", "requests_drained_after_free"]:
		if not bool(checks[key]):
			_fail("FrameSequence 生命周期检查失败: " + key)


func _wait_frames(count: int) -> void:
	for _index in range(count):
		await get_tree().process_frame


func _fail(message: String) -> void:
	_failures.append(message)
