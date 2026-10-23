extends Area2D
class_name RoleBullet1

var player_data: PlayerDataStore:
	get:
		return LocalCoop.data_for(self)
var role_props: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self)
@onready var bullet_an: AnimatedSprite2D = $BulletAN
@onready var bullet_player: AnimationPlayer = $BulletPlayer
var monster_list
var _name: String
var player: BaseHero
var is_set = false
var hit_dic = {"power": 0, "hurtBack": [0, 0], "attackKind": "real"}
var shallow
var first_hyjj: bool = true


func _physics_process(_delta: float) -> void:
	if not is_set:
		player = get_parent().get_parent()
		if _name == "hyjj":
			call_hyjj()
		else:
			bullet_player.play(_name)
			await bullet_player.animation_finished
		is_set = true


func call_hyjj():
	var cur_level = player_data.player_data[DataKeys.SKILL_LEARNED]["技能9"][DataKeys.LEVEL] + 1

	for i in range(3):
		var monster = get_monster()

		if monster == null:
			self.queue_free()
			return

		self.position = monster.position

		bullet_player.play(_name)
		Global.add_sound(self, "res://Music/hero/44_role1_hit12_2.mp3")

		await bullet_player.animation_finished
		await get_tree().create_timer(0.55, false).timeout

	self.queue_free()


func get_monster():
	var all_monster_list = player.get_parent().get_parent().get_node("Monster").get_children()
	if all_monster_list.size() <= 0:
		return null
	for i in all_monster_list:
		if i is BaseMonster:
			if (
				i.get_meta("pet_tiger_unit", false)
				or i.get_meta("is_summon", false)
				or (i.has_method("get") and i.get("is_summon") == true)
			):
				continue

			if i.is_death:
				continue

			if i is Monster48:
				if i.change_body_flag:
					continue
			if i is Monster50:
				if i.is_stop:
					continue
			if i is Monster49:
				if i.is_stop:
					continue

			if abs(i.position.x - player.position.x) >= 2000:
				continue

			if player.player_dir:
				if i.position.x > player.position.x:
					return i
			else:
				if i.position.x < player.position.x:
					return i
	return null


func _on_area_entered(_area: Area2D) -> void:
	randomize()
	if _name == "qsez" or _name == "qsez_1":
		var num = randi_range(0, 4)

		if player.shallow_list.size() < get_max_min_shallow_num()[0]:
			for i in range(get_max_min_shallow_num()[0]):
				if player.shallow_list.size() > get_max_min_shallow_num()[1]:
					return
				Global.add_role1_shallow(player.get_parent(), player.position, player.action.scale.x, num)
		if player.shallow_list.size() >= get_max_min_shallow_num()[1]:
			return
		if randi_range(0, 100) < 45 + (player_data.player_data[DataKeys.SKILL_LEARNED]["技能7"][DataKeys.LEVEL] + 1) * 3:
			Global.add_role1_shallow(player.get_parent(), player.position + Vector2(0, -20), player.action.scale.x, num)


func get_max_min_shallow_num():
	var get_level = int(player_data.player_data[DataKeys.SKILL_LEARNED]["技能7"][DataKeys.LEVEL])

	if get_level <= 2:
		return [1, 5]
	if get_level <= 5:
		return [2, 6]
	if get_level <= 8:
		return [2, 8]
	return [2, 12]
