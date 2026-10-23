extends Node2D

var source: WeakRef
var stacks := 0


func _ready() -> void:
	hide()


func add_mark() -> bool:
	stacks += 1
	var triggered := stacks >= YutuSkillData.PASSIVE_MARKS
	if triggered:
		stacks = 0
	return triggered


func _physics_process(_delta: float) -> void:
	var hero: BaseHero = source.get_ref() if source != null else null
	var target := get_parent() as BaseMonster
	if (
		not is_instance_valid(hero)
		or not hero.is_inside_tree()
		or hero.is_death
		or target == null
		or target.death()
		or target.is_death
	):
		queue_free()
