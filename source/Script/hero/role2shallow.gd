extends BaseHero
class_name Role2Shallow

var my_owner: BaseHero = null
@onready var hurt_box = $base_damagebox/HurtBox/HurtBox
var interv: int
var shallow_list: Array
var dir: bool
var should_use_skill: bool
var skill_name: String
var is_set: bool


func _ready() -> void:
	walk_speed = 360
	role_2_handler()


func role_2_handler():
	var level_1 = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能1"][DataKeys.LEVEL] + 1
	var level_2 = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能2"][DataKeys.LEVEL] + 1
	var level_3 = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能3"][DataKeys.LEVEL] + 1
	var level_4 = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能4"][DataKeys.LEVEL] + 1
	var level_5 = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能5"][DataKeys.LEVEL] + 1
	var level_6 = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能6"][DataKeys.LEVEL] + 1
	var level_7 = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能7"][DataKeys.LEVEL] + 1
	var level_8 = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能8"][DataKeys.LEVEL] + 1
	var level_9 = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能9"][DataKeys.LEVEL] + 1
	var level_10 = PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能10"][DataKeys.LEVEL]
	self.obj_attack_dict["xbz"] = {
		"power": RoleProp.roleprop.power * (0.55 + (level_2 * 0.055)), "hurtBack": [8, -13], "attackKind": "magic"
	}
	self.obj_attack_dict["jhsj"] = {
		"power": RoleProp.roleprop.power * (0.9 + (level_9 * 0.1)), "hurtBack": [3, -8], "attackKind": "magic"
	}

	walk_speed = 360 + (level_3 - 1) * (660 - 360) / 9.0
	walk_speed = int(walk_speed)


func _physics_process(delta: float) -> void:
	$Action/EffectBody.visible = false
	if self.is_in_sky:
		self.gravity = 0
		velocity.y = 0
	else:
		self.gravity = -980
	if not is_on_floor():
		hit_count = 0
		velocity.y -= gravity * delta
	role_2_handler()
	if not should_use_skill:
		if dir:
			$Action.scale.x = -1
			velocity.x = walk_speed
			_play_locomotion_animation(&"run")
		else:
			$Action.scale.x = 1
			velocity.x = -walk_speed
			_play_locomotion_animation(&"run")
	else:
		if not is_set:
			use_skill()
			is_set = true
	move_and_slide()


func use_skill():
	match skill_name:
		"xbz":
			skill_tjgl()
		"tjgl":
			skill_xbz()
		"jhsj":
			skill_jhsj()


func skill_xbz():
	velocity.x = 0
	get_action = "tjgl"
	is_using_skills = true
	super.get_hit_data("xbz")
	is_attacking = true
	role_action_player.play("tjgl")
	await role_action_player.animation_finished
	is_attacking = false
	is_using_skills = false


func skill_tjgl():
	velocity.x = 0
	get_action = "tjgl"
	is_using_skills = true
	is_attacking = true
	role_action_player.play("xbz")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func skill_jhsj():
	velocity.x = 0
	get_action = "jhsj"
	is_using_skills = true
	is_attacking = true
	role_action_player.play("jhsj")
	await role_action_player.animation_finished
	turn_to_wait()
	is_attacking = false
	is_using_skills = false


func add_tjgl():
	var eff = Global.add_role_special_effect(self.bullet, position + Vector2(0, -35), false, "tjgl")
	if eff != null and my_owner != null:
		eff.owner_player = my_owner


func add_xbz():
	var bullet_spawn_positions = [Vector2(-80, -15)]
	var scale_list = [Vector2(1, 1), Vector2(1.3, 1.3), Vector2(1.5, 1.5)]
	if !dir:
		bullet_spawn_positions = [Vector2(-80, -15), Vector2(-175, -20), Vector2(-275, -25)]
	else:
		bullet_spawn_positions = [Vector2(80, -15), Vector2(175, -20), Vector2(275, -25)]
	for i in bullet_spawn_positions.size():
		var xbz = Global.add_role_bullet(
			self.bullet, bullet_spawn_positions[i] + position, dir, "Role2Bullet3", obj_attack_dict["xbz"]
		)
		xbz.scale = scale_list[i]
		await get_tree().create_timer(0.2, false).timeout


func add_jhsj_2():
	var bullet_pos = Vector2()
	bullet_pos = Vector2(0, -10)
	var jhsj_2 = Global.add_role_bullet(self, bullet_pos, false, "Role2Bullet6", obj_attack_dict["jhsj"])
	jhsj_2.show_behind_parent = true


func _on_death_timeout() -> void:
	if not should_use_skill:
		self.queue_free()


func _on_spontaneous_recovery_timeout() -> void:
	return
