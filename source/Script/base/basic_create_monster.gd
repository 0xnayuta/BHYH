extends Node2D
var base_level: BaseLevel
@onready var create_monster_timer: Timer = $CreateMonster

@export var monster_id_list: Array[int]
@export var monster_position: Array[Vector2]
@export var id: int = 1
@export var stage: int = 1
var create_inter: float = 1.2
var can_create: bool = false
var can_chcek: bool


func _physics_process(_delta: float) -> void:
	if monster_id_list.is_empty() or monster_position.is_empty():
		set_physics_process(false)
		create_monster_timer.stop()
		return
	var monster_count := base_level.monster.get_child_count()
	if monster_count > 4 and monster_count < 6:
		can_chcek = true
	elif monster_count < 4:
		can_create = true
	if can_chcek:
		check()
		can_chcek = false
	if can_create:
		if create_monster_timer.is_stopped():
			create_monster_timer.start(create_inter)
		can_create = false


func check():
	match Stage:
		1:
			for i in base_level.create_1.get_children():
				if i.id > id:
					return
		2:
			for i in base_level.create_1.get_children():
				if i.id > id:
					return
		3:
			for i in base_level.create_1.get_children():
				if i.id > id:
					return
		4:
			for i in base_level.create_1.get_children():
				if i.id > id:
					return
	can_create = true


func create_monster(id: int, po: Vector2):
	Global.create_monster(id, base_level.monster, po)


func _on_create_monster_timeout() -> void:
	if monster_id_list.is_empty() or monster_position.is_empty():
		set_physics_process(false)
		return
	create_monster(monster_id_list[0], monster_position[0])
	monster_id_list.remove_at(0)
	monster_position.remove_at(0)
