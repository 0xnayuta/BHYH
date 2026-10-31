extends Node

## AtlasMetadataView 类型化 accessor 契约探针（由 scripts/scene_probe_runner.py 复制执行）。
## 使用合成元数据覆盖 pages+sequences 与 animation+frames 两族，不依赖私有素材，
## 验证只读 View 的公开查询返回值、边界与失败语义。

const RESULT_PREFIX := "ATLAS_ACCESSOR_PROBE_RESULT="
const TEARDOWN_MARKER := "ATLAS_ACCESSOR_PROBE_TEARDOWN"

var _failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var checks: Dictionary = {}

	# pages + sequences：帧元组、geometry、mask 与边界查询。
	var sequence_metadata := AtlasMetadata.new()
	sequence_metadata.data = {
		"pages": [{"path": "res://probe/page_0.png"}],
		"sequences":
		{
			"wait":
			{
				"frames":
				[
					[0, 0, 10, 20, 30, 40, 1, 2, 3, 4],
					[1, 0, 0, 0, 8, 9, 0, 0, 0, 0],
				]
			}
		},
		"geometry": {"wait": {"center": [5, 6], "size": [7, 8], "origin": [1, 2]}},
		"masks": {"wait": [[1, 2, 3, 4], []]},
	}
	var sequence_view := AtlasMetadataView.new(sequence_metadata, "res://probe/sequences.tres")
	checks["sequence_valid"] = sequence_view.is_valid() and not sequence_view.is_animation()
	checks["sequence_has"] = sequence_view.has_sequence(&"wait")
	checks["sequence_missing"] = not sequence_view.has_sequence(&"missing")
	checks["sequence_frame_count"] = sequence_view.sequence_frame_count(&"wait") == 2
	checks["sequence_frame_size"] = sequence_view.frame_size(&"wait", 0) == Vector2(30, 40)
	checks["sequence_frame_margin"] = sequence_view.frame_margin(&"wait", 0) == Rect2(1, 2, 3, 4)
	checks["sequence_frame_center"] = sequence_view.frame_center(&"wait", 0) == Vector2(-0.5, 0.0)
	checks["sequence_frame_anchor"] = sequence_view.frame_reg_anchor(&"wait", 0) == Vector2(-0.5, 20.0)
	checks["sequence_geometry"] = (
		sequence_view.has_geometry(&"wait")
		and sequence_view.geometry_center(&"wait") == Vector2(5, 6)
		and sequence_view.geometry_size(&"wait") == Vector2(7, 8)
		and sequence_view.geometry_origin(&"wait") == Vector2(1, 2)
	)
	checks["sequence_masks"] = (
		sequence_view.has_mask_sequence(&"wait")
		and sequence_view.mask_frame_count(&"wait") == 2
		and sequence_view.mask_frame_rect(&"wait", 0) == Rect2(1, 2, 3, 4)
		and sequence_view.mask_frame_is_empty(&"wait", 1)
		and sequence_view.mask_frame_is_empty(&"wait", 2)
	)
	checks["sequence_out_of_range"] = (
		sequence_view.frame_size(&"wait", 9) == Vector2.ZERO
		and sequence_view.frame_margin(&"wait", -1) == Rect2()
		and sequence_view.mask_frame_rect(&"wait", 9) == Rect2()
	)

	# animation + frames：播放参数、图集页名、图层与 rider transform。
	var animation_metadata := AtlasMetadata.new()
	animation_metadata.data = {
		"animation": "idle",
		"fps": 24.0,
		"loop": true,
		"frame_count": 1,
		"back_atlases": ["back.png"],
		"front_atlases": ["front.png"],
		"frames":
		[
			{
				"back": {"page": 0, "region": [1, 2, 3, 4], "offset": [5, 6]},
				"front": {"page": 0, "region": [7, 8, 9, 10], "offset": [11, 12]},
				"ride": {"a": 1.0, "b": 0.0, "c": 0.0, "d": 1.0, "tx": 2.0, "ty": 3.0},
			}
		],
	}
	var animation_view := AtlasMetadataView.new(animation_metadata, "res://probe/animation.tres")
	var back_names: Array[String] = animation_view.animation_back_atlas_names()
	var front_names: Array[String] = animation_view.animation_front_atlas_names()
	checks["animation_valid"] = animation_view.is_valid() and animation_view.is_animation()
	checks["animation_playback"] = (
		animation_view.animation_frame_count() == 1
		and is_equal_approx(animation_view.animation_fps(), 24.0)
		and animation_view.animation_loop()
	)
	checks["animation_atlas_names"] = (
		back_names == ["back.png"]
		and front_names == ["front.png"]
		and typeof(back_names[0]) == TYPE_STRING
		and typeof(front_names[0]) == TYPE_STRING
	)
	checks["animation_back_layer"] = (
		animation_view.animation_layer_has(0, &"back")
		and animation_view.animation_layer_page(0, &"back") == 0
		and animation_view.animation_layer_region(0, &"back") == Rect2(1, 2, 3, 4)
		and animation_view.animation_layer_offset(0, &"back") == Vector2(5, 6)
	)
	checks["animation_front_layer"] = (
		animation_view.animation_layer_has(0, &"front")
		and animation_view.animation_layer_region(0, &"front") == Rect2(7, 8, 9, 10)
		and animation_view.animation_layer_offset(0, &"front") == Vector2(11, 12)
	)
	checks["animation_bounds"] = animation_view.animation_frame_bounds(0) == Rect2(5, 6, 15, 16)
	checks["animation_ride"] = (
		animation_view.animation_has_ride(0)
		and animation_view.animation_ride_transform(0) == Transform2D(Vector2(1, 0), Vector2(0, 1), Vector2(2, 3))
		and not animation_view.animation_ride_has_origin(0)
		and not animation_view.animation_has_official_ride(0)
	)
	checks["animation_missing_layer"] = (
		not animation_view.animation_layer_has(0, &"side")
		and animation_view.animation_layer_page(0, &"side") == -1
		and animation_view.animation_layer_region(0, &"side") == Rect2()
	)

	# 失败语义：缺 pages/sequences 的 View 必须无效并返回错误文本。
	var invalid_metadata := AtlasMetadata.new()
	invalid_metadata.data = {"pages": []}
	var invalid_view := AtlasMetadataView.new(invalid_metadata, "res://probe/invalid.tres")
	checks["invalid_view_rejected"] = not invalid_view.is_valid() and not invalid_view.error_message().is_empty()

	for check_name in checks:
		if not bool(checks[check_name]):
			_failures.append(str(check_name))
	var payload := {"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": checks}
	print(RESULT_PREFIX + JSON.stringify(payload))
	print(TEARDOWN_MARKER)
	get_tree().quit(0 if _failures.is_empty() else 1)
