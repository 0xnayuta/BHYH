extends BaseMagicWeapon
class_name Nmwdnh

var add_time: float
var add_bl: float = 1

var role_7_scene = null
var current_summon: Node = null
var summon_timer: Timer = null

var weapon_level: int = 1
var summon_attribute_scale: float = 0.1
var weapon_name: String = "nmwdnh"


func set_magic_weapon_name(_name: String) -> void:
	weapon_name = _name


func _ready() -> void:
	summon_timer = Timer.new()
	summon_timer.one_shot = true
	summon_timer.autostart = false
	add_child(summon_timer)
	summon_timer.timeout.connect(_on_summon_timeout)


func get_summon_attribute_scale() -> float:
	var scale_value: float
	if weapon_level >= 10:
		scale_value = 1.0
	else:
		scale_value = 0.1 + (weapon_level - 1) * 0.1
	if weapon_name == "sqnmwdnh":
		scale_value *= 3.0
	return scale_value


func get_summon_damage_scale() -> float:
	if weapon_name == "sqnmwdnh":
		return 3.0
	return 1.0


func _physics_process(delta: float) -> void:
	self.fb_level = PlayerData.get_most_level(weapon_name) + 1
	weapon_level = self.fb_level

	summon_attribute_scale = get_summon_attribute_scale()

	need_mp = 50 + self.fb_level * 5
	if PlayerData.check_have_wx(weapon_name, "木"):
		add_time = self.fb_level * 0.1 + 3
	else:
		add_time = 3

	super._physics_process(delta)
	if not is_use:
		mg_player.play("wait")


func show_skill():
	mg_player.play("hit")
	await mg_player.animation_finished

	summon_zlw()
	use_over()


func use_over():
	self.usecd = 5
	fb_cd = 1
	is_use = false
	skill_cd.start(5)


func summon_zlw():
	if current_summon and is_instance_valid(current_summon):
		current_summon.queue_free()
		current_summon = null

	var summon_scene := Global.load_scene_uncached("res://Scene/monster/monster_zhw/monster_141_zhw.tscn")
	if summon_scene == null:
		return
	var summon_instance = summon_scene.instantiate()

	var summon_pos = global_position
	summon_pos.x += 100
	summon_instance.position = summon_pos

	summon_attribute_scale = get_summon_attribute_scale()
	if summon_instance.has_method("set_weapon_level"):
		summon_instance.set_weapon_level(weapon_level, summon_attribute_scale, get_summon_damage_scale())

	get_tree().current_scene.add_child(summon_instance)
	current_summon = summon_instance

	var duration = 20.0 + (weapon_level - 1) * 2.0
	summon_timer.start(duration)

	print("召唤物牛魔王，法宝等级: %d, 属性系数: %.1f%%, 持续时间: %.1f秒" % [weapon_level, summon_attribute_scale * 100, duration])


func _on_summon_timeout():
	if current_summon and is_instance_valid(current_summon):
		print("召唤物牛魔王持续时间结束，已销毁")
		current_summon.queue_free()
		current_summon = null


func _exit_tree():
	if current_summon and is_instance_valid(current_summon):
		current_summon.queue_free()

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
