extends Node

## 小龙女持续伤害节点；由技能命中挂到目标身上，按固定间隔结算。

var source: WeakRef
var target: WeakRef
var damage := 0.0
var ticks_left := 3
var clock := 0.0
var current_life_ratio := 0.0


func _physics_process(delta: float) -> void:
	var caster: BaseHero = source.get_ref() if source != null else null
	var enemy: BaseMonster = target.get_ref() if target != null else null
	if not is_instance_valid(caster) or not is_instance_valid(enemy) or caster.is_death or enemy.is_death:
		queue_free()
		return
	clock += delta
	while clock >= 1.0 and ticks_left > 0:
		clock -= 1.0
		ticks_left -= 1
		var amount := float(enemy.hp) * current_life_ratio if current_life_ratio > 0.0 else damage
		if current_life_ratio > 0.0:
			amount = LongnvSkillData.bleed_damage(enemy, caster, current_life_ratio)
		enemy.is_crit = false
		enemy.is_miss = false
		enemy.hurt_reduce_hp(maxi(1, int(amount)), self)
	if ticks_left == 0:
		queue_free()
