extends Node2D

const TABLE_WIDTH := 760.0
const HEADER_HEIGHT := 34.0
const ROW_HEIGHT := 34.0
const ROW_COUNT := 7
const COLUMN_X := [0.0, 100.0, 310.0, 520.0, 640.0, TABLE_WIDTH]

const HEADER_COLOR := Color(0.0, 0.0, 0.0, 0.94)
const BODY_COLOR := Color(0.015, 0.07, 0.12, 0.38)
const GRID_COLOR := Color(0.0, 0.0, 0.0, 0.84)


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	var table_height := HEADER_HEIGHT + ROW_HEIGHT * ROW_COUNT
	draw_rect(Rect2(0.0, 0.0, TABLE_WIDTH, HEADER_HEIGHT), HEADER_COLOR)
	draw_rect(Rect2(0.0, HEADER_HEIGHT, TABLE_WIDTH, table_height - HEADER_HEIGHT), BODY_COLOR)

	for column_x in COLUMN_X:
		draw_line(Vector2(column_x, 0.0), Vector2(column_x, table_height), GRID_COLOR, 2.0)

	for row_index in range(ROW_COUNT + 1):
		var row_y := HEADER_HEIGHT + ROW_HEIGHT * row_index
		draw_line(Vector2(0.0, row_y), Vector2(TABLE_WIDTH, row_y), GRID_COLOR, 2.0)
