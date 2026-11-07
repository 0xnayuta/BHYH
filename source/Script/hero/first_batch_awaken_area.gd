extends "res://Script/hero/ne_zha_skill_effect.gd"
class_name FirstBatchAwakenArea

var freeze_seconds := 0.0
var _target_pulses: Dictionary = {}


func _ready() -> void:
	mirror_like_player = true
	super._ready()
	hit_box.monitorable = false


func _on_hit_box_area_entered(_area: Area2D) -> void:
	pass


func _physics_process(delta: float) -> void:
	if not is_instance_valid(player) or bool(player.get("is_death")):
		queue_free()
		return
	_elapsed += delta
	if _elapsed >= life_seconds:
		queue_free()
		return
	var pulse := mini(max_hit_pulses - 1, floori(_elapsed / hit_interval)) if hit_interval > 0.0 else 0
	for area: Area2D in hit_box.get_overlapping_areas():
		var target := _get_monster_from_hit_area(area)
		if target == null or _is_summon_or_pet_target(target) or target.hp <= 0:
			continue
		var target_id := target.get_instance_id()
		if int(_target_pulses.get(target_id, -1)) == pulse:
			continue
		_target_pulses[target_id] = pulse
		var before: int = target.hp
		target.apply_role_hit(self, player)
		if freeze_seconds > 0.0 and before > target.hp and not target.is_control_immune():
			Global.add_buff(
				target.buff,
				{
					"Name": "Ice",
					"AddTime": freeze_seconds,
					"reduce_interval": 0,
					"value": 0,
					"AttackKind": "",
					"DeBuff": true,
					"CanAdd": false
				}
			)
