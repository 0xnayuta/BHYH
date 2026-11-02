extends Node

## 宠物运行期探针（由 scripts/scene_probe_runner.py 复制到工程根目录执行）。
## 覆盖三类回归：宠物在树外初始化属性时不得依赖绝对节点路径；宠物 HUD 头像
## 必须从构建期模型帧解析；寅虎 SpriteFrames 的逐帧 duration 必须使用相对时长，
## 保证 walk 的绝对帧时长不是 speed 倍加速后的闪烁值。

const RESULT_PREFIX := "PET_RUNTIME_PROBE_RESULT="
const TEARDOWN_MARKER := "PET_RUNTIME_PROBE_TEARDOWN"

var _failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var checks: Dictionary = {}
	_check_phoenix_outside_tree(checks)
	_check_head_textures(checks)
	_check_yin_tiger_timing(checks)

	checks["teardown"] = true
	for check_name in checks:
		if not bool(checks[check_name]):
			_failures.append(str(check_name))
	var payload := {"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": checks}
	print(RESULT_PREFIX + JSON.stringify(payload))
	print(TEARDOWN_MARKER)
	get_tree().quit(0 if _failures.is_empty() else 1)


func _check_phoenix_outside_tree(checks: Dictionary) -> void:
	# 预热与出战路径会在 add_child 前调用 apply_pet_data；该路径不得读取 /root 绝对路径。
	var scene := load("res://Scene/pet/pet_phoenix_summon_1.tscn") as PackedScene
	checks["phoenix_scene"] = scene != null
	if scene == null:
		return
	var pet = scene.instantiate()
	var data := {
		"等级": 20,
		"阶段": 2,
		"攻击": 100,
		"生命上限": 1000,
		"魔法上限": 200,
		"被动技能": {"热血": 5, "魔泉": 4},
	}
	pet.apply_pet_data(data)
	checks["phoenix_outside_tree"] = not pet.is_inside_tree()
	checks["phoenix_passive_hp"] = int(pet.max_hp) >= 1000 + int(PaSkill.get_value("热血", 5))
	checks["phoenix_passive_mp"] = int(pet.max_mp) >= 200 + int(PaSkill.get_value("魔泉", 4))
	pet.free()


func _check_head_textures(checks: Dictionary) -> void:
	# 虎/龙/朱雀的独立头像源文件已并入图集，HUD 必须从构建期 SpriteFrames 取首帧。
	var role: BaseRole = BaseRole.new()
	for stage in range(1, 5):
		checks["head_tiger_%d" % stage] = role._pet_tiger_head_texture(stage) != null
		checks["head_dragon_%d" % stage] = role._pet_dragon_head_texture(stage) != null
		checks["head_phoenix_%d" % stage] = role._pet_phoenix_head_texture(stage) != null
	role.free()


func _check_yin_tiger_timing(checks: Dictionary) -> void:
	for stage in [1, 2]:
		var path := "res://Art/pet/pet_yin_tiger/model/actions/stage%d/yin_tiger_stage%d_frames.tres" % [stage, stage]
		var frames := load(path) as SpriteFrames
		checks["yin_frames_%d" % stage] = frames != null
		if frames == null:
			continue
		var walk_speed := frames.get_animation_speed(&"walk")
		var walk_seconds := frames.get_frame_duration(&"walk", 0) / walk_speed
		var wait_seconds := frames.get_frame_duration(&"wait", 0) / walk_speed
		checks["yin_walk_speed_%d" % stage] = is_equal_approx(walk_speed, 24.0)
		checks["yin_walk_seconds_%d" % stage] = is_equal_approx(walk_seconds, 4.0 / 24.0)
		checks["yin_wait_seconds_%d" % stage] = is_equal_approx(wait_seconds, 2.0 / 24.0)
