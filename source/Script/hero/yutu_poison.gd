extends Node2D

var player_data: PlayerDataStore:
	get:
		return LocalCoop.data_for(self)
var role_props: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self)

var source: WeakRef
var weak_stacks := 0
var strong_stacks := 0
var weak_time := 0.0
var strong_time := 0.0
var weak_level := 1
var strong_level := 1
var elapsed := 0.0
var weak_extra := 0
var strong_extra := 0
var weak_extra_time := 0.0
var strong_extra_time := 0.0
var weak_damage := 0.0
var strong_damage := 0.0
var weak_extra_damage := 0.0
var strong_extra_damage := 0.0
var weak_visual: AnimatedSprite2D
var strong_visual: AnimatedSprite2D


func _ready() -> void:
	for key: String in ["weak", "strong"]:
		var visual := AnimatedSprite2D.new()
		visual.sprite_frames = preload("res://Art/hero_picture/role_7/buffs/yutu_buffs.tres")
		visual.position.y = -55.0
		visual.play(key)
		add_child(visual)
		if key == "weak":
			weak_visual = visual
		else:
			strong_visual = visual


func add_poison(
	hero: BaseHero, strong: bool, count: int, level: int, skill_damage: float = -1.0, skill_id: String = ""
) -> void:
	if count <= 0:
		return
	source = weakref(hero)
	if skill_id.is_empty():
		skill_id = "1111030" if strong else "1111010"
	if skill_damage < 0.0:
		skill_damage = YutuSkillData.damage(skill_id, level, float(role_props.roleprop.power))
	if strong:
		var added := clampi(count, 0, 1000 - strong_stacks)
		strong_stacks += added
		strong_damage += maxf(0.0, skill_damage) * YutuSkillData.POISON_DAMAGE_RATIO * float(added) / count
		strong_time = 5.0
		strong_level = level
	else:
		var added := clampi(count, 0, 1000 - weak_stacks)
		weak_stacks += added
		weak_damage += maxf(0.0, skill_damage) * YutuSkillData.POISON_DAMAGE_RATIO * float(added) / count
		weak_time = 10.0
		weak_level = level


func amplify(count: int, skill_damage: float = -1.0, level: int = 1) -> void:
	if count <= 0:
		return
	if skill_damage < 0.0:
		skill_damage = YutuSkillData.damage("1111052", level, float(role_props.roleprop.power))
	var damage := maxf(0.0, skill_damage) * YutuSkillData.POISON_DAMAGE_RATIO
	var active_types := int(weak_stacks > 0) + int(strong_stacks > 0)
	if active_types == 0:
		return

	damage /= active_types
	if weak_stacks > 0:
		var added := clampi(count, 0, 1000 - weak_extra)
		weak_extra += added
		weak_extra_damage += damage * float(added) / count
		weak_extra_time = 10.0
	if strong_stacks > 0:
		var added := clampi(count, 0, 1000 - strong_extra)
		strong_extra += added
		strong_extra_damage += damage * float(added) / count
		strong_extra_time = 5.0


func _physics_process(delta: float) -> void:
	var hero: BaseHero = source.get_ref() if source != null else null
	var target := get_parent() as BaseMonster
	if not is_instance_valid(hero) or target == null or target.is_death:
		queue_free()
		return
	weak_time -= delta
	strong_time -= delta
	weak_extra_time -= delta
	strong_extra_time -= delta
	if weak_extra_time <= 0.0:
		weak_extra = 0
		weak_extra_damage = 0.0
	if strong_extra_time <= 0.0:
		strong_extra = 0
		strong_extra_damage = 0.0
	if weak_time <= 0.0:
		weak_stacks = 0
		weak_damage = 0.0
	if strong_time <= 0.0:
		strong_stacks = 0
		strong_damage = 0.0
	weak_visual.visible = weak_stacks + weak_extra > 0
	strong_visual.visible = strong_stacks + strong_extra > 0
	if weak_stacks + strong_stacks + weak_extra + strong_extra == 0:
		queue_free()
		return
	elapsed += delta
	if elapsed >= 1.0:
		elapsed -= 1.0
		var damage := weak_damage + strong_damage + weak_extra_damage + strong_extra_damage
		target.apply_role_hit(
			hero,
			hero,
			{"power": damage, "hurtBack": [0, 0], "attackKind": "magic", "WSValue": 0, "yutu_poison_damage": true}
		)


func get_buff_info() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var entries := [
		["YutuWeakPoison", "蔓毒", weak_stacks, weak_time, weak_damage, 10.0],
		["YutuStrongPoison", "玄毒", strong_stacks, strong_time, strong_damage, 5.0],
		["YutuWeakExtraPoison", "魔瓮蔓毒", weak_extra, weak_extra_time, weak_extra_damage, 10.0],
		["YutuStrongExtraPoison", "魔瓮玄毒", strong_extra, strong_extra_time, strong_extra_damage, 5.0],
	]
	for entry: Array in entries:
		if int(entry[2]) <= 0 or float(entry[3]) <= 0.0:
			continue
		result.append(
			{
				"Name": entry[0],
				"DisplayName": entry[1],
				"HaveCount": entry[2],
				"TimeLeft": entry[3],
				"value": entry[4],
				"AddTime": entry[5],
				"ReduceInterval": 1.0,
				"reduce_interval": 1.0,
				"AttackKind": "magic"
			}
		)
	return result
