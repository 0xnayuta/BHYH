extends Node2D
class_name Role4Bullet
var player: BaseHero
var old_monster: BaseMonster
var target_monster: BaseMonster
var hit_count: int = 0
var speed = 10
var is_set: bool


func _physics_process(delta: float) -> void:
	if not is_set:
		target_monster = check_monster()
		old_monster = target_monster
		is_set = true
	if target_monster != null:
		self.position += Global.get_position_between(self, target_monster) * speed
	else:
		queue_free()
	if target_monster == null or old_monster == null:
		self.queue_free()


func _on_queue_timer_timeout() -> void:
	queue_free()


func check_monster():
	var mr_list = []
	if player is BaseHero:
		mr_list = player.get_parent().get_parent().monster.get_children()
	for i in mr_list:
		if _is_valid_tmc_target(i):
			return i
	return null


func _is_valid_tmc_target(target: Node) -> bool:
	if target == null:
		return false
	if not is_instance_valid(target):
		return false
	if not (target is BaseMonster):
		return false
	if target == old_monster:
		return false
	if target.hp <= 0:
		return false
	if target.get_meta("pet_tiger_unit", false) or target.get_meta("is_summon", false):
		return false
	return true


func _process(delta: float) -> void:
	if hit_count > 3:
		queue_free()


func _on_check_body_entered(body: Node2D) -> void:
	if body == null:
		return
	if body is BaseMonster:
		if body == target_monster and _is_valid_tmc_target(body):
			old_monster = target_monster
			(
				Global
				. add_buff(
					body.buff,
					{
						"Name": "Voodoo",
						"AddTime": 5,
						"reduce_interval": 1,
						"value": 0,
						"CanAdd": true,
						"AttackKind": "real",
					}
				)
			)
			(
				Global
				. add_buff(
					body.buff,
					{
						"Name": "stun",
						"AddTime": 0.3,
						"reduce_interval": 0,
						"value": 0,
						"CanAdd": false,
						"AttackKind": "",
					}
				)
			)
			target_monster = check_monster()
