extends Node2D
var catch = false
var speed = 50.0
var player: BaseHero
var players: Dictionary = {}
@onready var monster_47: CharacterBody2D = $Monster_47


func _physics_process(delta: float) -> void:
	_sync_coop_players()
	if self.position.x <= 4423:
		self.position.x += speed * delta
		for id in players.keys():
			var caught: Variant = players[id]
			if is_instance_valid(caught) and not caught.is_death:
				caught.position.x += speed * delta
		monster_47.position = self.position
	else:
		monster_47.position = Vector2(0, 0)


func _sync_coop_players() -> void:
	var candidates: Array = []
	var coop := get_node_or_null("/root/LocalCoop")
	if coop != null and coop.has_method("living_players") and coop.is_enabled():
		candidates = coop.living_players()
	elif is_instance_valid(player):
		candidates = [player]
	for candidate in candidates:
		if not is_instance_valid(candidate) or candidate.is_death:
			continue
		var local_pos := to_local(candidate.global_position)
		if absf(local_pos.x + 17.0) <= 170.0 and absf(local_pos.y - 94.0) <= 55.0:
			players[candidate.get_instance_id()] = candidate
	for id in players.keys():
		var caught: Variant = players[id]
		if not is_instance_valid(caught) or caught.is_death:
			players.erase(id)
	catch = not players.is_empty()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is BaseHero:
		players[body.get_instance_id()] = body
		player = body
		catch = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is BaseHero:
		players.erase(body.get_instance_id())
	catch = not players.is_empty()
