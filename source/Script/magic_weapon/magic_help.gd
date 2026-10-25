extends Node2D


func _on_close_pressed() -> void:
	queue_free()


## ESC 分层关闭：只关闭帮助层，法宝主窗口保持打开。
func request_escape_close() -> bool:
	queue_free()
	return true
