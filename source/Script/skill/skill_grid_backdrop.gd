extends Node2D

const TABLE_WIDTH := 760.0
const HEADER_HEIGHT := 40.0
const ROW_HEIGHT := 74.0
const MAX_ROW_COUNT := 13
const COLUMN_X := [0.0, 120.0, 232.0, 380.0, 486.0, TABLE_WIDTH]

const HEADER_COLOR := Color(0.0, 0.0, 0.0, 0.94)
const BODY_COLOR := Color(0.015, 0.07, 0.12, 0.38)
const GRID_COLOR := Color(0.0, 0.0, 0.0, 0.84)


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	var row_count := _get_row_count()
	var skill_page = get_parent().get_parent().get_parent()
	var row_heights: Array = []
	if skill_page and skill_page.has_method("get_skill_row_heights"):
		row_heights = skill_page.get_skill_row_heights()
	var row_boundaries: Array[float] = [HEADER_HEIGHT]
	var table_height := HEADER_HEIGHT
	for row_index in range(row_count):
		table_height += float(row_heights[row_index]) if row_index < row_heights.size() else ROW_HEIGHT
		row_boundaries.append(table_height)
	draw_rect(Rect2(0.0, 0.0, TABLE_WIDTH, HEADER_HEIGHT), HEADER_COLOR)
	draw_rect(Rect2(0.0, HEADER_HEIGHT, TABLE_WIDTH, table_height - HEADER_HEIGHT), BODY_COLOR)

	for column_x in COLUMN_X:
		draw_line(Vector2(column_x, 0.0), Vector2(column_x, table_height), GRID_COLOR, 2.0)

	for row_y in row_boundaries:
		draw_line(Vector2(0.0, row_y), Vector2(TABLE_WIDTH, row_y), GRID_COLOR, 2.0)


func _get_row_count() -> int:
	var skill_page = get_parent().get_parent().get_parent()
	if skill_page and skill_page.has_method("get_role_key"):
		var skill_list = skill_page.get("skill_list")
		if skill_list == null:
			skill_list = skill_page.get("Skill_list")
		if skill_list is Dictionary:
			var role_skills = skill_list.get(skill_page.get_role_key(), [])
			if role_skills is Array:
				return clampi(role_skills.size(), 1, MAX_ROW_COUNT)
	return MAX_ROW_COUNT
