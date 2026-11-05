extends Node

## Phase 32-1 UI Theme 试点探针（由 scripts/scene_probe_runner.py 复制执行）。
## 验证 game_set 的 Theme 应用、类型变体、关键控件计算样式与布局语义。
## equipment_properies 与 level_info 的逐控件计算/截图对照在 32-2A 批次中单独执行，
## 避免无数据上下文产生无关运行期日志。
## 静态 scene override 守恒由 scripts/theme_override_audit.py 负责。

const RESULT_PREFIX := "UI_THEME_PROBE_RESULT="
const TEARDOWN_MARKER := "UI_THEME_PROBE_TEARDOWN"
const GAME_SET_PATH := "res://Scene/main_menu/game_set.tscn"
const EQUIPMENT_PATH := "res://Scene/back_pack/equipment_properies.tscn"
const LEVEL_INFO_PATH := "res://Scene/other_scene/level_info.tscn"
const THEME_PATH := "res://Scene/theme/bhyh_theme.tres"
const MAIN_FONT := "res://Font/lxgw_wen_kai_medium.ttf"
const RETURN_FONT := "res://Font/source_han_serif_cn_semibold.otf"

var _failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var checks: Dictionary = {}
	var packed := load(GAME_SET_PATH) as PackedScene
	var scene := packed.instantiate() if packed != null else null
	checks["scene_loaded"] = scene != null
	if scene == null:
		_finish(checks)
		return
	add_child(scene)
	await get_tree().process_frame
	await get_tree().process_frame

	var bg := scene.get_node("Bg/BGColor") as Control
	var return_button := scene.get_node("Bg/Return") as Button
	var title := scene.get_node("Bg/BGColor/Title") as Label
	var section := scene.get_node("Bg/BGColor/VBoxContainer/GameMusicTitle") as Label
	var plain := scene.get_node("Bg/BGColor/VBoxContainer2/BodyShow") as Label
	var slider := scene.get_node("Bg/BGColor/VBoxContainer/GameMusicFB/HSlider") as HSlider
	var option := (
		scene.get_node("Bg/BGColor/VBoxContainer2/FrameRate/FrameRateOption") as OptionButton
	)
	var normal_button := scene.get_node("Bg/BGColor/VBoxContainer2/GameMusicTitle/GMzm_1") as Button
	var bright_button := (
		scene.get_node("Bg/BGColor/VBoxContainer/GameMusicTitle/GMOpenOrClose") as Button
	)
	var group := scene.get_node("Bg/BGColor/VBoxContainer") as VBoxContainer
	var spacious_group := scene.get_node("Bg/BGColor/VBoxContainer2") as VBoxContainer

	checks["bg_theme"] = _theme_path(bg) == THEME_PATH
	checks["return_theme"] = _theme_path(return_button) == THEME_PATH
	checks["theme_resource"] = (
		bg.theme != null and _native_variation_base(bg.theme, &"SettingsTitle") == &"Label"
	)

	checks["title_variation"] = title.theme_type_variation == &"SettingsTitle"
	checks["title_font"] = (
		_font_path(title) == MAIN_FONT and title.get_theme_font_size("font_size") == 36
	)
	checks["title_outline"] = title.get_theme_constant("outline_size") == 2
	checks["section_variation"] = section.theme_type_variation == &"SettingsSection"
	checks["section_font"] = (
		_font_path(section) == MAIN_FONT and section.get_theme_font_size("font_size") == 24
	)
	checks["section_outline"] = section.get_theme_constant("outline_size") == 1
	checks["plain_variation"] = plain.theme_type_variation == &"SettingsPlainLabel"
	checks["plain_font"] = (
		_font_path(plain) == MAIN_FONT and plain.get_theme_font_size("font_size") == 16
	)
	checks["plain_outline"] = plain.get_theme_constant("outline_size") == 1

	checks["normal_button_variation"] = normal_button.theme_type_variation == &"SettingsButton"
	checks["normal_button_font"] = (
		_font_path(normal_button) == MAIN_FONT
		and normal_button.get_theme_font_size("font_size") == 24
	)
	checks["normal_button_colors"] = (
		normal_button.get_theme_color("font_color").to_html(true) == "dfdfdfff"
		and normal_button.get_theme_color("font_hover_color").to_html(true)
		== UiColorTokens.TEXT_HOVER.to_html(true)
	)
	checks["normal_button_style"] = normal_button.get_theme_stylebox("normal") is StyleBoxEmpty
	checks["bright_button_variation"] = (
		bright_button.theme_type_variation == &"SettingsButtonBright"
	)
	checks["bright_button_color"] = (
		bright_button.get_theme_color("font_color").to_html(true) == "ffffffff"
	)

	checks["return_variation"] = return_button.theme_type_variation == &"SettingsReturnButton"
	checks["return_font"] = (
		_font_path(return_button) == RETURN_FONT
		and return_button.get_theme_font_size("font_size") == 32
	)
	checks["return_outline"] = return_button.get_theme_constant("outline_size") == 3
	checks["return_colors"] = (
		return_button.get_theme_color("font_color").to_html(true) == "dfdfdfff"
		and return_button.get_theme_color("font_outline_color").to_html(true) == "000000ff"
	)

	checks["slider_variation"] = slider.theme_type_variation == &"SettingsSlider"
	checks["slider_track"] = slider.get_theme_stylebox("slider") is StyleBoxLine
	checks["slider_fill"] = slider.get_theme_stylebox("grabber_area_highlight") is StyleBoxFlat
	checks["group_separation"] = group.get_theme_constant("separation") == 7
	checks["spacious_group_separation"] = spacious_group.get_theme_constant("separation") == 13
	checks["option_variation"] = option.theme_type_variation == &"SettingsOption"
	checks["option_font"] = (
		_font_path(option) == MAIN_FONT and option.get_theme_font_size("font_size") == 20
	)

	var variation_count := 0
	var valid_variations := true
	for node in scene.find_children("*", "Control", true):
		var control := node as Control
		if control == null or control.theme_type_variation == &"":
			continue
		variation_count += 1
		valid_variations = (
			valid_variations
			and bg.theme.get_type_variation_base(control.theme_type_variation) != &""
		)
	checks["variation_count"] = variation_count == 45
	checks["variation_bases"] = valid_variations

	var music_before := bool(MainSet.set_data["BackGroundMusic"])
	bright_button.pressed.emit()
	await get_tree().process_frame
	checks["interaction_toggle"] = bool(MainSet.set_data["BackGroundMusic"]) != music_before
	bright_button.pressed.emit()
	await get_tree().process_frame
	checks["interaction_restore"] = bool(MainSet.set_data["BackGroundMusic"]) == music_before

	_finish(checks)
	scene.queue_free()


func _finish(checks: Dictionary) -> void:
	for check_name in checks:
		if not bool(checks[check_name]):
			_failures.append(str(check_name))
	print(
		(
			RESULT_PREFIX
			+ JSON.stringify(
				{"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": checks}
			)
		)
	)
	print(TEARDOWN_MARKER)
	get_tree().quit()


func _native_variation_base(theme: Theme, variation: StringName) -> StringName:
	var current := variation
	var seen := {}
	while theme.get_type_variation_base(current) != &"":
		if seen.has(current):
			break
		seen[current] = true
		current = theme.get_type_variation_base(current)
	return current


func _theme_path(control: Control) -> String:
	return control.theme.resource_path if control.theme != null else ""


func _font_path(control: Control) -> String:
	var font := control.get_theme_font("font")
	while font is FontVariation and font.base_font != null:
		font = font.base_font
	return font.resource_path if font != null else ""


func _variation_count(scene: Node) -> int:
	var count := 0
	for node in scene.find_children("*", "Control", true):
		if (node as Control).theme_type_variation != &"":
			count += 1
	return count
