extends CharacterBody2D
const BossXieShaSengWdww := preload("res://Script/monster/monster_14501_wdww.gd")
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var _speed
var _direction
var distance: int
var position_1
var position_2
var _name
var level = 0
var def = 0
var mdef = 0
var crit = 0
var miss = 0
var lucky = 0
var htarget = 0
var toughness = 0
var ar = 0
var sp = 0
var crit_reduce = 0
var att_list
var obj_attack_dict = {}
var skill_name: String
var dir: bool
var speed: float
var bullet_name
var hit
var attack_kind
var hurt_back
var hit_name
var total_hit = 0
var is_get = false


func _ready():
	set_meta("is_monster_bullet", true)


func _physics_process(delta: float) -> void:
	get_prop()
	$AnimationPlayer.play(_name)
	if not is_get:
		position_1 = self.position.x
		is_get = true

	if _direction == -1:
		self.scale.x = -self.scale.x
	else:
		self.scale.x = self.scale.x
	velocity.x -= _direction * _speed * delta
	check_and_free()
	move_and_slide()


func check_and_free():
	position_2 = self.position.x
	if abs(position_2 - position_1) >= distance:
		self.queue_free()


func _on_hit_area_area_entered(area: Area2D) -> void:
	var target = area.get_parent().get_parent()

	if target is BossXieShaSengWdww:
		return
	if obj_attack_dict[hit_name].has("addeffect"):
		Global.add_buff(target.buff, obj_attack_dict[hit_name]["addeffect"])

	if _name == "Monster14Bullet" or _name == "Monster41Bullet":
		queue_free()


func get_prop():
	var tt = get_parent().get_parent()
	if tt is BaseMonster:
		level = tt.level
		def = tt.def
		mdef = tt.mdef
		crit = tt.crit
		miss = tt.miss
		lucky = tt.lucky
		htarget = tt.htarget
		toughness = tt.toughness
		ar = tt.ar
		sp = tt.sp
		crit_reduce = tt.crit_reduce
		total_hit = tt.total_hit
	if hit_name != "":
		self.obj_attack_dict[hit_name] = att_list
