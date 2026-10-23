extends BaseMonster

var buff_icon
@onready var rd: Area2D = $Rd
@onready var rrd: CollisionShape2D = $Rd/rrd
var has_hd = true

var rd_node
var shader_material: ShaderMaterial


func monster_8():
	skill_1_cd = 0
	self.cannot_attract = true
	self.is_quiescent = true
	self.is_boss = true
	self.my_mr_name = "蝙蝠石像"
	self.attack_in = 10
	self.level = 17
	self.max_hp = 2500
	self.hp = self.max_hp
	self.def = 500
	self.mdef = 500
	self.crit = 0
	self.miss = 0
	self.lucky = 0
	self.htarget = 0
	self.toughness = 200
	self.ar = 0
	self.sp = 0
	self.crit_reduce = 500
	self.speed = 0
	self.mysee = 300
	self.attack_range = 75
	self.attack_desire = 100
	self.behit_calmtime = 0.2
	self.self_rhp = 50
	self.add_exp = 50
	self.fall_coin = 14
	self.obj_attack_dict["hit1"] = {"power": 0, "hurtBack": [0, 0], "attackKind": ""}
	self.fall_pro = 0.5
	self.fall_list = [{"name": "whg", "value": 0}, {"name": "bsp", "value": 0}, {"name": "wtp", "value": 0}]
	self.independent_fall_list = [
		{"name": "211007001", "value": 0, "chance": 0.25},
	]
	enable_treasure_box = true
	treasure_box_item = "bfsxbx"
	update_fall_mode()
	if current_fall_mode == FallMode.TREASURE_BOX:
		self.independent_fall_list.clear()
	self.fall_stone_pro = 0
	self.fall_stone = []


func _ready():
	super._ready()
	monster_8()

	var original_material = $MonsterDir/mr_ani.material
	if original_material:
		shader_material = original_material.duplicate()
		$MonsterDir/mr_ani.material = shader_material
		shader_material.set_shader_parameter("TINT_COLOR", Color(1, 1, 1, 1))


func _physics_process(delta):
	if state != State.DEATH:
		if has_hd:
			self.self_rhp = 100
			self.def = 9999
			self.mdef = 9999
			mr_player.play("wait")
			if shader_material:
				shader_material.set_shader_parameter("TINT_COLOR", Color(1, 0.9, 0, 1))
		else:
			self.def = 60
			self.mdef = 70
			self.self_rhp = 0
			if buff_icon != null:
				buff_icon.queue_free()
			mr_player.play("can_hurt")
			if shader_material:
				shader_material.set_shader_parameter("TINT_COLOR", Color(1, 1, 1, 1))

	if rd_node != null:
		rrd.disabled = false
	else:
		rrd.disabled = true

	velocity.x = 0
	if is_on_floor():
		velocity.y = 0
	super._physics_process(delta)


func use_skill_1():
	skill_1_cd = 10
	call_monster()


func call_monster():
	Global.add_special_effect(self, Vector2(21, -46), "red_eyes", Vector2(1, 1), false, 1)
	Global.add_special_effect(self, Vector2(-27, -46), "red_eyes", Vector2(1, 1), true, 1)
	create_bf(randi_range(3, 6))


func create_bf(get_number):
	for i in range(get_number):
		var pp_x = self.position.x + randi_range(-200, 200)
		var pp_y = self.position.y + randi_range(-50, -350)
		var bf = Global.create_monster(7, get_parent(), Vector2(pp_x, pp_y))
		bf.def += 10
		bf.mdef += 10
		bf.max_hp = bf.max_hp * 1.5
		bf.hp = bf.max_hp
		bf.add_exp = 1
		bf.fall_coin = 1
		bf.fall_pro = 0
		bf.fall_stone_pro = 0


func _on_create_rd_timeout():
	randomize()
	var po_x_list = [-600, -700, -200, -250]

	var rd_pos = Vector2(po_x_list[randi_range(0, 3)], randi_range(-200, 50))

	if rd_node:
		rd_node.queue_free()
		rd_node = null

	rd_node = Global.add_special_effect(self, rd_pos, "rd", Vector2(1, 1), false, 1)
	rd.position = rd_pos
	rrd.disabled = false


func _on_rd_area_entered(area):
	if not has_hd:
		return

	$create_rd.stop()
	has_hd = false
	remove_hd()
	$reset_hd.wait_time = 5
	$reset_hd.start()


func ai_think():
	if skill_1_cd <= 0:
		use_skill_1()


func attack_target():
	pass


func _on_reset_hd_timeout():
	has_hd = true
	$create_rd.wait_time = 3
	$create_rd.start()
