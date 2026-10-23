extends BaseMagicWeapon
class_name Dhqf

var def_timer: Timer


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not is_use:
		mg_player.play("wait")


func show_skill():
	var level = PlayerData.get_most_level("dhqf") + 1
	level = clamp(level, 0, 10)
	need_mp = 20 + level * 6

	var percent = 0.1 + level * 0.02
	var max_hp = RoleProp.roleprop.SHp
	var max_mp = RoleProp.roleprop.SMp
	var heal_hp = int(max_hp * percent)
	var heal_mp = int(max_mp * percent)

	if player != null:
		player.cure_hp(heal_hp)
		player.cure_mp(heal_mp)

	var def_increase = int(round(20 + level * 5.0))

	if def_timer != null and def_timer.time_left > 0:
		player.temp_def_bonus = 0
		player.temp_mdef_bonus = 0
		def_timer.stop()
		def_timer.queue_free()
		def_timer = null

	player.temp_def_bonus = def_increase
	player.temp_mdef_bonus = def_increase

	if player != null and player.buff != null:
		var super_armor_buff = {
			"Name": "SuperArmor",
			"value": 0.0,
			"AddTime": 10.0,
			"reduce_interval": 0.0,
			"AttackKind": "",
			"CanRemove": true,
			"CanAdd": false,
			"DeBuff": false
		}
		Global.add_buff(player.buff, super_armor_buff)

	def_timer = Timer.new()
	def_timer.one_shot = true
	def_timer.wait_time = 30.0
	def_timer.timeout.connect(_on_def_timer_timeout)
	add_child(def_timer)
	def_timer.start()

	var cd_seconds = 20 - level
	if PlayerData.check_have_wx("dhqf", "木"):
		cd_seconds = 15

	cd_seconds = max(cd_seconds, 1)
	self.usecd = cd_seconds

	mg_player.play("hit")
	await mg_player.animation_finished
	use_over()


func _on_def_timer_timeout():
	if player and is_instance_valid(player):
		player.temp_def_bonus = 0
		player.temp_mdef_bonus = 0
	def_timer.queue_free()
	def_timer = null


func use_over():
	fb_cd = 1
	is_use = false
	skill_cd.start(usecd)

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
