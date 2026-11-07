extends Node2D

## 玲珑漫天屏幕雷暴：一次绘制全屏帧混合，按固定时间轴结算七段伤害。

const PARTS := preload("res://Script/hero/longnv_official_parts.gd")
const FRAME_BLEND := preload("res://Shader/longnv_storm_frame_blend.gdshader")
const DURATION := 1.8
const VISUAL_START := 0.5
const VISUAL_FPS := 30.0
const SOURCE_SIZE := Vector2(1200, 640)

static var _rendering_prepared := false
static var _rendering_preparing := false
var source: WeakRef
var damage := 0.0
var elapsed := 0.0
var pulse_count := 0
var visual: Sprite2D
var pulse_targets: Dictionary = {}
var visual_elapsed := 0.0
var _frame_runs := PackedInt32Array()
var _run_starts := PackedInt32Array()
var _run_regions: Array[Rect2] = []
var _last_run := -1
var _frame_material: ShaderMaterial


static func prewarm_rendering(parent: Node) -> void:
	if _rendering_prepared or _rendering_preparing or DisplayServer.get_name() == "headless":
		return
	_rendering_preparing = true
	var tree := parent.get_tree()
	var layer := CanvasLayer.new()
	layer.layer = -128
	parent.add_child(layer)
	var sample := Sprite2D.new()
	sample.set_script(PARTS)
	sample.offset = Vector2(0, -188)
	layer.add_child(sample)
	sample.load_set("ring_effect10")
	sample.set_pose("attack", 0)
	sample.position = parent.get_viewport().get_visible_rect().get_center()
	sample.scale = Vector2(0.01, 0.01)
	sample.modulate.a = 0.001
	var material := ShaderMaterial.new()
	material.shader = FRAME_BLEND
	material.set_shader_parameter("frame_blend", 0.5)
	sample.material = material
	await tree.process_frame
	if not is_instance_valid(layer):
		_rendering_preparing = false
		return
	await RenderingServer.frame_post_draw
	if is_instance_valid(layer):
		layer.queue_free()
	_rendering_prepared = true
	_rendering_preparing = false


func _ready() -> void:
	visual = Sprite2D.new()
	visual.set_script(PARTS)
	visual.offset = Vector2(0, -188)
	add_child(visual)
	visual.load_set("ring_effect10")
	_frame_material = ShaderMaterial.new()
	_frame_material.shader = FRAME_BLEND
	visual.material = _frame_material

	var frames: Array = visual._animations["attack"]["frames"]
	var last_region := -1
	for index in frames.size():
		var region := int(visual._poses[int(frames[index][0]) * visual.STRIDE])
		if region != last_region:
			_run_starts.append(index)
			_run_regions.append(visual._regions[region])
			last_region = region
		_frame_runs.append(_run_starts.size() - 1)
	update_visual()


func _process(delta: float) -> void:
	visual_elapsed += delta
	update_visual()


func update_visual() -> void:
	var screen := get_viewport_rect()
	var cover := maxf(screen.size.x / SOURCE_SIZE.x, screen.size.y / SOURCE_SIZE.y)
	visual.position = screen.get_center()
	visual.scale = Vector2(cover, cover)
	visual.visible = visual_elapsed >= VISUAL_START and visual_elapsed < DURATION
	var frame_time := maxf(0.0, visual_elapsed - VISUAL_START) * VISUAL_FPS
	var run := _frame_runs[mini(int(frame_time), _frame_runs.size() - 1)]
	var next_run := mini(run + 1, _run_starts.size() - 1)
	var end_frame := _run_starts[next_run] if next_run != run else _frame_runs.size()
	if run != _last_run:
		visual.set_pose("attack", _run_starts[run])
		var uv_offset := (_run_regions[next_run].position - _run_regions[run].position) / Vector2(visual.atlas_size)
		_frame_material.set_shader_parameter("next_frame_uv_offset", uv_offset)
		_last_run = run
	_frame_material.set_shader_parameter(
		"frame_blend", clampf((frame_time - _run_starts[run]) / float(end_frame - _run_starts[run]), 0.0, 1.0)
	)
	var fade_start := VISUAL_START + float(_frame_runs.size()) / VISUAL_FPS
	visual.modulate.a = 1.0 - clampf((visual_elapsed - fade_start) / (DURATION - fade_start), 0.0, 1.0)


func _physics_process(delta: float) -> void:
	var caster = source.get_ref()
	if not is_instance_valid(caster) or caster.is_death:
		queue_free()
		return
	if elapsed < 0.5 and (not caster._active or caster._skill_index != 19):
		queue_free()
		return
	var previous := elapsed
	elapsed += delta
	var canvas := get_viewport().get_canvas_transform()
	var screen := get_viewport_rect()
	var hit_times: Array = LongnvSkillData.HIT_TIMES[19].duplicate()
	if caster.is_skill_awakened("xln_llmt"):
		var extended: Array = []
		for index in hit_times.size():
			extended.append(hit_times[index])
			if index + 1 < hit_times.size():
				extended.append((float(hit_times[index]) + float(hit_times[index + 1])) * 0.5)
		hit_times = extended
	for index in hit_times.size():
		var hit_at := float(hit_times[index])
		if elapsed < hit_at or previous >= hit_at + 0.09:
			continue
		if not pulse_targets.has(index):
			pulse_targets[index] = {}
			pulse_count += 1
		caster.hit_original_area(
			canvas.affine_inverse() * screen.get_center(),
			screen.size / canvas.get_scale().abs(),
			damage,
			pulse_targets[index],
			{"longnv_skill": 19, "attackKind": "magic", "hurtBack": [0, 0]}
		)
	if elapsed >= DURATION:
		queue_free()
