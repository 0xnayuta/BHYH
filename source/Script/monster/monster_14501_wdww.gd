extends CharacterBody2D
class_name BossXieShaSengWdww
var my_target: BaseHero
@onready var mr_player: AnimationPlayer = $mr_player
@onready var boss_xie_sha_seng_wdww: CharacterBody2D = $"."
@onready var monster_dir: Node2D = $MonsterDir
var entity: BaseMonster
var speed = 200
var curr_hp = 2000
var max_hp = 2000
var gravity = 980


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta

	if curr_hp <= 0:
		mr_player.play("death")
		return
	if my_target == null:
		my_target = LocalCoop.nearest_player(self.global_position)
	else:
		if self.position.x >= my_target.position.x:
			move_left()
		else:
			move_right()
	move_and_slide()


func ai_think():
	pass


func _on_hurt_box_area_entered(area: Area2D) -> void:
	Global.get_run_context().count_hurt()
	var target = area.get_parent().get_parent()
	var monster_target: BaseMonster
	monster_target = entity
	if target == null or monster_target == null:
		return
	if target.obj_attack_dict.size() == 0:
		return
	var source_player: BaseHero = LocalCoop.owner_hero(area)
	if source_player == null or not is_instance_valid(source_player):
		return
	if monster_target is Monster47:
		Global.player_be_hit_count += 1
	var last_hit = source_player.get_monster_last_hurt(monster_target, target)

	if source_player is Role3Hero and source_player.RoleProp.is_ws_state:
		last_hit = int(last_hit * 0.7)
	if monster_target != null:
		monster_target.total_hit += last_hit
	Global.get_run_context().add_damage_taken(int(last_hit))

	if source_player is Role1Hero:
		Global.get_audio_runtime().add_sound(self, "res://Music/hero/49_role1_be_attack.mp3")
	elif source_player is Role2Hero:
		Global.get_audio_runtime().add_sound(self, "res://Music/hero/62_role2_be_attack.mp3")
	else:
		Global.get_audio_runtime().add_sound(self, "res://Music/hero/68_role3_be_attack.mp3")
		Global.add_mr_hurt(source_player.pz, Vector2(5, -20))
		if not source_player.is_t_mc:
			source_player.current_protect += randi_range(3, 7)
	if source_player is Role3Hero:
		var skill_level := int(source_player.PlayerData.player_data[DataKeys.SKILL_LEARNED]["技能10"][DataKeys.LEVEL])
		if randi_range(0, 100) <= 4 + skill_level * 0.5:
			if skill_level > 0:
				if not get_parent().get_parent() is Level17 and not get_parent().get_parent() is Level22:
					source_player.cure_hp(source_player.RoleProp.roleprop.power * (0.5 + skill_level * 0.02))

	if source_player is Role1Hero or source_player is Role2Hero:
		if source_player.is_miss or source_player.RoleProp.is_ws_state:
			source_player.is_be_attacking = false
		else:
			source_player.be_hit_back(monster_target, target)
			source_player.state_behit()
	elif source_player is Role3Hero:
		if source_player.is_miss or source_player.is_sd_buff or source_player.is_t_mc:
			source_player.is_be_attacking = false
		else:
			source_player.be_hit_back(monster_target, target)
			source_player.state_behit()
	source_player.reduce_hp(last_hit, monster_target, target)


func move_left():
	monster_dir.scale.x = 1

	velocity.x = -speed
	mr_player.play("walk")


func move_right():
	monster_dir.scale.x = -1

	velocity.x = speed
