extends Node

## 未央宫 Boss 符号层探针（由 scripts/scene_probe_runner.py 复制到工程根目录执行）。
## 验证嘴/眼符号层从 3007 帧资源构建、初始帧与发射时间轴可达，
## 并确认 Boss 实例化后五个 AnimatedSprite2D 都拿到了真实帧。

const RESULT_PREFIX := "WEIYANG_SYMBOL_PROBE_RESULT="
const TEARDOWN_MARKER := "WEIYANG_SYMBOL_PROBE_TEARDOWN"
const BOSS_SCENE := "res://Scene/monster/monster_3007.tscn"
const MOUTH_DIRECTORY := "DefineSprite_28__1_fla.effect1_1_9"
const EYE3_DIRECTORY := "DefineSprite_45"
const EYE_DIRECTORY := "DefineSprite_68"

var _failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var checks: Dictionary = {}

	var mouth := WeiyangPalaceBoss._build_symbol_frames(&"mouth", MOUTH_DIRECTORY, 78, true)
	checks["mouth_frames_built"] = mouth != null
	checks["mouth_frame_count"] = mouth != null and mouth.get_frame_count(&"mouth") == 78
	checks["mouth_loops"] = mouth != null and mouth.get_animation_loop(&"mouth")
	checks["mouth_speed"] = mouth != null and is_equal_approx(mouth.get_animation_speed(&"mouth"), 30.0)
	var fire_frame := WeiyangPalaceBoss.SHOOT_TIMELINE_FRAME - 1
	checks["fire_frame_in_range"] = mouth != null and fire_frame < mouth.get_frame_count(&"mouth")
	checks["fire_frame_texture"] = mouth != null and mouth.get_frame_texture(&"mouth", fire_frame) != null
	checks["last_frame_texture"] = mouth != null and mouth.get_frame_texture(&"mouth", 77) != null

	var eye3 := WeiyangPalaceBoss._build_symbol_frames(&"eye", EYE3_DIRECTORY, 17, false)
	checks["eye3_frame_count"] = eye3 != null and eye3.get_frame_count(&"eye") == 17
	checks["eye3_no_loop"] = eye3 != null and not eye3.get_animation_loop(&"eye")
	var eye := WeiyangPalaceBoss._build_symbol_frames(&"eye", EYE_DIRECTORY, 55, false)
	checks["eye_frame_count"] = eye != null and eye.get_frame_count(&"eye") == 55
	checks["eye_no_loop"] = eye != null and not eye.get_animation_loop(&"eye")

	var standard := WeiyangPalaceBoss._get_frames()
	checks["standard_wait_available"] = standard != null and standard.has_animation(&"wait")

	# Boss 实例化：临时关闭血条挂载，避免探针根节点缺少关卡 monster_blood 容器。
	var previous_blood: Variant = MainSet.set_data.get("MonsterBloodSHow", true)
	MainSet.set_data["MonsterBloodSHow"] = false
	var scene := load(BOSS_SCENE) as PackedScene
	var boss = scene.instantiate() if scene != null else null
	checks["boss_instantiated"] = boss != null
	if boss != null:
		add_child(boss)
		await get_tree().process_frame
		await get_tree().process_frame
		checks["boss_mouth_frames"] = (
			boss._mouth1 != null and boss._mouth1.sprite_frames != null and boss._mouth1.sprite_frames.has_animation(&"mouth")
		)
		checks["boss_mouth_animation"] = boss._mouth1 != null and boss._mouth1.animation == &"mouth"
		checks["boss_mouth_initial_frame"] = boss._mouth1 != null and boss._mouth1.frame == 0
		checks["boss_mouth_paused"] = boss._mouth1 != null and not boss._mouth1.is_playing()
		checks["boss_eye3_initial_frame"] = boss._eye3 != null and boss._eye3.frame == 16
		checks["boss_eye_initial_frame"] = boss._eye1 != null and boss._eye1.frame == 54
		checks["boss_eyes_mirrored"] = (
			boss._eye1 != null and boss._eye2 != null and not boss._eye1.flip_h and boss._eye2.flip_h
		)
		checks["boss_mouth_mirrored"] = (
			boss._mouth1 != null and boss._mouth2 != null and not boss._mouth1.flip_h and boss._mouth2.flip_h
		)
		# 发射时间轴：嘴部动画必须能推进到第 50 帧（SHOOT_TIMELINE_FRAME - 1）。
		if boss._mouth1 != null:
			boss._mouth1.play(&"mouth")
			var waited := 0
			while boss._mouth1.frame < fire_frame and waited < 240:
				await get_tree().process_frame
				waited += 1
			checks["mouth_reaches_fire_frame"] = boss._mouth1.frame >= fire_frame
		boss.queue_free()
		await get_tree().process_frame
	MainSet.set_data["MonsterBloodSHow"] = previous_blood

	checks["teardown"] = true
	for check_name in checks:
		if not bool(checks[check_name]):
			_failures.append(str(check_name))
	var payload := {"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": checks}
	print(RESULT_PREFIX + JSON.stringify(payload))
	print(TEARDOWN_MARKER)
