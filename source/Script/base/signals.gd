extends Node
signal choose_pressed


func connect_choose_box_signal(Obj: Object, funcName: String):
	for i in choose_pressed.get_connections():
		var remove_callable = i["callable"]
		disconnect("choose_pressed", remove_callable)
	connect("choose_pressed", Callable(Obj, funcName))
