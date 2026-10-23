extends Line2D

var type: String
var player: BaseHero
var monster: BaseMonster
var reduce_count: int


func _physics_process(delta: float) -> void:
	player = RoleProp.source_player
	if player != null and is_instance_valid(player):
		if points.size() > 1:
			points[1] = player.position
		elif points.size() == 1:
			add_point(player.position)

	reduce_count += 1
	if reduce_count % 60 == 0:
		reduce_count = 0
		match type:
			"Red":
				if player != null and is_instance_valid(player):
					player.effect_reducehp(RoleProp.roleprop.SHp * 0.03, "magic")
			"Blue":
				if player != null and is_instance_valid(player):
					RoleProp.roleprop.Mp -= RoleProp.roleprop.SMp * 0.03
