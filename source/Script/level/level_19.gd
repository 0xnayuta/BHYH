extends BaseLevel
class_name Level19
@onready var stop_1: CollisionShape2D = $wall/stop1
@onready var stop_2: CollisionShape2D = $wall/stop2
@onready var stop_3: CollisionShape2D = $wall/stop3

@onready var check_hero: Area2D = $CheckHero
@onready var ck_hero: CollisionShape2D = $CheckHero/ck_hero
@onready var bsz: Node2D = $BSZ
@onready var bsz_2: Node2D = $BSZ2
@onready var bsz_3: Node2D = $BSZ3
@onready var bsz_4: Node2D = $BSZ4
@onready var bsz_5: Node2D = $BSZ5
var entercount: int = 0
var canthro = false
var can_pass = false
var mm: Monster50
var mm2: Monster49
var randi_num = randi_range(0, 2)
var can_notpass = false


func _ready() -> void:
	Global.set_current_level_name("望乡台")
	var ppx = [1685, 2160, 2640]
	check_hero.position = Vector2(ppx[randi_num], 35)
	Global.get_audio_runtime().add_bgm(self, "res://Music/level/9_bg3.mp3")
	self.level_stage = 19
	super._ready()


func _physics_process(delta: float) -> void:
	if mm != null:
		if mm.death():
			canthro = true
	if bsz != null and bsz_2 != null and bsz_3 != null and bsz_4 != null and bsz_5 != null:
		if current_stage == 4:
			can_pass = true
			if randi_num == 0:
				bsz_4.free()
			elif randi_num == 1:
				bsz_5.free()
			elif randi_num == 2:
				bsz.free()
	if can_pass:
		if can_notpass:
			ck_hero.disabled = true
		else:
			ck_hero.disabled = false
	super._physics_process(delta)
	if current_stage >= 1:
		if check_can_pass() and current_stage < 4:
			role_information.gogo.visible = true
		else:
			role_information.gogo.visible = false


func set_through():
	if current_stage == 1:
		if check_can_pass():
			stop_1.disabled = true
	elif current_stage == 2:
		if check_can_pass():
			stop_2.disabled = true
	elif current_stage == 3:
		if check_can_pass():
			stop_3.disabled = true


func _on_area_2d_body_entered(body: Node2D) -> void:
	entercount += 1
	if entercount >= 5:
		if body is BaseHero:
			if can_pass:
				if mm == null:
					mm = Global.create_monster(50, monster, check_hero.position) as Monster50
					ck_hero.set_deferred("disabled", true)
					can_exit = false
					exit.visible = false
					exit_2.set_deferred("disabled", true)
				for i in monster.get_children():
					if i is Monster49:
						mm2 = i
						if mm2 != null:
							mm2.hp = -100
						entercount = 0

						return
