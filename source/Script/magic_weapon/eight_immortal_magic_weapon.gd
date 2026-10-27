extends BaseMagicWeapon

@export var weapon_id: String = ""
@export var model_frames: SpriteFrames
@export var effect_frames: SpriteFrames
@export var skill_cost: int = 10
@export var skill_cooldown: float = 10.0

var _effect: AnimatedSprite2D
var _sword_entities: Array[Node2D] = []
var _sword_serial: int = 0
var _dragon_sword_id: int = 1
var _fan_entities: Array[Node2D] = []
var _fan_serial: int = 0
var _flower_serial: int = 0
var _pet_speed_serial: int = 0
var _effect_serial: int = 0

const DRAGON_SWORD_COOLDOWN := 0.1


func _ready() -> void:
	if model_frames == null:
		push_error("八仙法宝模型帧资源缺失: %s" % weapon_id)
		return
	mg_action.sprite_frames = model_frames
	mg_action.animation = &"wait"
	mg_action.play()
	obj_attack_dict["hit1"] = {"power": 0, "hurtBack": [0, 0], "attackKind": "magic"}


func _physics_process(delta: float) -> void:
	fb_level = PlayerData.get_most_level(weapon_id) + 1
	need_mp = skill_cost
	super._physics_process(delta)
	_process_swords(delta)
	_process_fan(delta)
	if weapon_id == "yyzlj":
		_update_dragon_sword_model()
	if (
		not is_use
		and mg_action.sprite_frames != null
		and mg_action.sprite_frames.has_animation("wait")
		and mg_action.animation != &"wait"
		and (weapon_id != "yyzlj" or _sword_entities.is_empty())
	):
		mg_action.play("wait")


func show_skill() -> void:
	match weapon_id:
		"yyzlj":
			_use_dragon_sword()
		"ywhl":
			_use_yaowang_bottle()
		"zhyx":
			_use_flute()
		"bjs":
			_use_fan()
		"sxyg":
			_use_shenxing()
		"dkhl":
			_use_flower_basket()
		"yyb":
			_use_yunyang_board()
		"hehua":
			_use_miaolian()
		_:
			pass
	if weapon_id == "yyzlj":
		_update_dragon_sword_model()
		use_over()
		return
	mg_action.play("hit")
	await get_tree().create_timer(0.12).timeout
	use_over()


func enough_mp() -> bool:
	if weapon_id == "yyzlj":
		return RoleProp.roleprop != null and int(RoleProp.roleprop.Mp) >= int(skill_cost)
	return super.enough_mp()


func _has_wood() -> bool:
	return bool(PlayerData.check_have_wx(weapon_id, "木"))


func _level_node() -> Node:
	if player == null or player.get_parent() == null:
		return null
	var level: Node = player.get_parent().get_parent()
	return level if level is Node else null


func _active_monsters() -> Array:
	var level := _level_node()
	if level != null and level.has_method("get_active_monsters"):
		return level.get_active_monsters()
	var result: Array = []
	if level != null and "monster" in level and level.monster != null:
		result = level.monster.get_children()
	return result


func _active_pet() -> Node:
	var level := _level_node()
	if level != null:
		var registered: Variant = level.get_meta("active_pet_unit", null)
		if registered is Node and is_instance_valid(registered) and not registered.is_queued_for_deletion():
			return registered
		if "monster" in level and level.monster != null:
			for child in level.monster.get_children():
				if child is SummonBaseMonster and not child.is_queued_for_deletion():
					return child
	return null


func _role_attack_damage(multiplier: float = 1.0) -> int:
	var power := int(RoleProp.roleprop.power) if RoleProp.roleprop != null else 1
	return maxi(1, int(float(power) * multiplier))


func _use_dragon_sword() -> void:
	if _sword_entities.size() >= 2:
		_remove_sword(_sword_entities[0])
	if _sword_entities.is_empty():
		_dragon_sword_id = 1
	_sword_serial += 1
	var sword := Node2D.new()
	sword.name = "EightImmortalDragonSword_%d" % _sword_serial
	sword.set_meta("sword_id", _dragon_sword_id)
	var faces_right := player != null and bool(player.get("player_dir"))
	sword.set_meta("speed", 432.0 * (1.0 if faces_right else -1.0))
	sword.set_meta("life", 12.0 if _has_wood() else 8.0)
	sword.set_meta("damage", _role_attack_damage())
	sword.set_meta("hit_interval_msec", 2147483647)
	sword.set_meta("hit", {})
	var sword_visual: AnimatedSprite2D = _add_visual_to_entity(sword)
	if sword_visual != null:
		sword_visual.flip_h = float(sword.get_meta("speed", 0.0)) < 0.0
	var scene := get_tree().current_scene
	if scene == null:
		sword.queue_free()
		return
	scene.add_child(sword)
	sword.global_position = _dragon_sword_spawn_position()
	_sword_entities.append(sword)
	_dragon_sword_id = 2 if _dragon_sword_id == 1 else 1
	_update_dragon_sword_model()


func _dragon_sword_spawn_position() -> Vector2:
	if player == null or not is_instance_valid(player):
		return global_position
	var role_body := player.get_node_or_null("Action/RoleBody") as Sprite2D
	if role_body != null:
		return role_body.global_position + role_body.offset
	var action := player.get_node_or_null("Action") as Node2D
	return action.global_position if action != null else player.global_position


func _update_dragon_sword_model() -> void:
	if weapon_id != "yyzlj" or mg_action.sprite_frames == null:
		return
	if _sword_entities.is_empty():
		mg_action.animation = &"wait"
		mg_action.stop()
		mg_action.frame = 0
		return
	var animation_name: StringName = (
		&"hit3"
		if _sword_entities.size() >= 2
		else (&"hit1" if int(_sword_entities[0].get_meta("sword_id", 1)) == 1 else &"hit2")
	)
	mg_action.play(animation_name)
	mg_action.stop()
	mg_action.frame = 0


func _use_yaowang_bottle() -> void:
	if player == null or RoleProp.roleprop == null:
		return
	var missing := maxi(0, int(RoleProp.roleprop.SHp) - int(RoleProp.roleprop.Hp))
	player.cure_hp(fb_level * 100 + int(float(missing) * 0.15))
	var wait_time := 10.0 if _has_wood() else 20.0
	_spawn_effect_for_duration(wait_time)


func _use_flute() -> void:
	const DURATION := 3.0
	for monster in _active_monsters():
		if not (monster is BaseMonster) or not is_instance_valid(monster) or monster.hp <= 0:
			continue
		if monster is Monster49 or monster is Monster50 or monster is Monster51:
			continue
		if monster.is_control_immune():
			continue
		monster.is_stun = true
		var buff_node: Node = monster.get_node_or_null("Buff")
		if buff_node != null:
			Global.add_buff(
				buff_node,
				{
					"Name": "stun",
					"AddTime": DURATION,
					"reduce_interval": 1.0,
					"value": 0,
					"AttackKind": "",
					"DeBuff": true,
					"CanRemove": false
				}
			)
	_spawn_effect_for_duration(DURATION)


func _use_fan() -> void:
	_fan_serial += 1
	var fan_entity := Node2D.new()
	fan_entity.name = "EightImmortalFan_%d" % _fan_serial
	var fan_origin := player.global_position if player != null and is_instance_valid(player) else global_position
	fan_entity.global_position = fan_origin
	fan_entity.set_meta("origin_x", fan_entity.global_position.x)
	fan_entity.set_meta("origin_y", fan_entity.global_position.y)
	fan_entity.set_meta("direction", 1.0 if player != null and bool(player.get("player_dir")) else -1.0)
	fan_entity.set_meta("phase", 0)
	fan_entity.set_meta("life", 5.0)
	fan_entity.set_meta("damage", _role_attack_damage(2.0 if _has_wood() else 1.0))
	fan_entity.set_meta("hit_interval_msec", 1000)
	fan_entity.set_meta("hit", {})
	_add_visual_to_entity(fan_entity)
	var scene := get_tree().current_scene
	if scene == null:
		fan_entity.queue_free()
		return
	scene.add_child(fan_entity)
	_fan_entities.append(fan_entity)


func _use_shenxing() -> void:
	if player == null or not player.has_method("fabao_jiasu"):
		return
	_pet_speed_serial += 1
	var token := _pet_speed_serial
	const DURATION := 8.0
	player.fabao_jiasu()
	_spawn_effect_for_duration(maxf(1.0, DURATION))
	if _effect != null and is_instance_valid(_effect) and player != null and is_instance_valid(player):
		_effect.reparent(player, false)
		_effect.position = Vector2.ZERO
	get_tree().create_timer(maxf(1.0, DURATION)).timeout.connect(_reset_speed.bind(token), CONNECT_ONE_SHOT)


func _reset_speed(token: int) -> void:
	if token != _pet_speed_serial:
		return
	if player != null and is_instance_valid(player) and player.has_method("reset_fabao_jiasu"):
		player.reset_fabao_jiasu()


func _use_flower_basket() -> void:
	_flower_serial += 1
	var token := _flower_serial
	const DURATION := 8.0
	_heal_flower_tick(token, DURATION)


func _heal_flower_tick(token: int, remaining: float) -> void:
	if token != _flower_serial:
		return
	if player != null and is_instance_valid(player):
		player.cure_hp(fb_level * 2)
		if player.has_method("cure_mp"):
			player.cure_mp(fb_level)
	var pet := _active_pet()
	if pet != null and pet.has_method("cure_hp"):
		pet.cure_hp(fb_level * 2)
	if pet != null and "mp" in pet and "max_mp" in pet:
		pet.mp = mini(int(pet.max_mp), int(pet.mp) + fb_level)
	if remaining > 1.0:
		get_tree().create_timer(1.0).timeout.connect(_heal_flower_tick.bind(token, remaining - 1.0), CONNECT_ONE_SHOT)


func _use_yunyang_board() -> void:
	var pet := _active_pet()
	if pet == null:
		return
	_pet_speed_serial += 1
	var token := _pet_speed_serial
	const DURATION := 8.0
	if pet.has_method("turn_to_gxp"):
		pet.turn_to_gxp(int(DURATION))
	else:
		var old_speed := float(pet.get("speed"))
		var old_ini_speed := float(pet.get("init_speed"))
		pet.set_meta("eight_yunyang_token", token)
		pet.set_meta("eight_yunyang_speed", old_speed)
		pet.set_meta("eight_yunyang_ini_speed", old_ini_speed)
		pet.set("speed", old_speed * 2.0)
		pet.set("init_speed", old_ini_speed * 2.0)
	get_tree().create_timer(DURATION).timeout.connect(_reset_yunyang.bind(pet, token), CONNECT_ONE_SHOT)


func _reset_yunyang(pet: Node, token: int) -> void:
	if not is_instance_valid(pet) or int(pet.get_meta("eight_yunyang_token", -1)) != token:
		return
	pet.set("speed", float(pet.get_meta("eight_yunyang_speed", pet.get("speed"))))
	pet.set("init_speed", float(pet.get_meta("eight_yunyang_ini_speed", pet.get("init_speed"))))
	pet.remove_meta("eight_yunyang_token")
	pet.remove_meta("eight_yunyang_speed")
	pet.remove_meta("eight_yunyang_ini_speed")


func _use_miaolian() -> void:
	var level := _level_node()
	var pets: Variant = PlayerData.player_data.get("宠物列表", [])
	if level == null or not (pets is Array):
		return
	var dead_name := str(level.get_meta("active_pet_dead_display_name", ""))
	var target_pet: Dictionary = {}
	for pet in pets:
		if not (pet is Dictionary):
			continue
		if (
			bool(pet.get(DataKeys.DEPLOYED, false))
			or dead_name == ""
			or str(pet.get(DataKeys.ALT_NAME, "")) == dead_name
		):
			if int(pet.get(DataKeys.HP, 0)) <= 0:
				target_pet = pet
				break
	if target_pet.is_empty():
		return
	var percent := float(fb_level * 5 + (25 if _has_wood() else 0)) / 100.0
	target_pet[DataKeys.HP] = maxi(1, int(float(target_pet.get("生命上限", 1)) * percent))
	target_pet[DataKeys.DEPLOYED] = true
	PlayerData.player_data["出战宠物"] = str(target_pet.get(DataKeys.ALT_NAME, ""))
	level.set_meta("active_pet_dead_this_level", false)
	level.set_meta("active_pet_dead_keys", [])
	level.set_meta("active_pet_dead_name", "")
	level.set_meta("active_pet_dead_type", "")
	level.set_meta("active_pet_dead_display_name", "")
	if level.has_method("_spawn_active_pet"):
		level.call_deferred("_spawn_active_pet")


func _process_swords(delta: float) -> void:
	for sword in _sword_entities.duplicate():
		if not is_instance_valid(sword):
			_sword_entities.erase(sword)
			continue
		var speed := float(sword.get_meta("speed", 0.0))
		sword.position.x += speed * delta
		var sword_visual := sword.get_child(0) as AnimatedSprite2D if sword.get_child_count() > 0 else null
		if sword_visual != null and not is_zero_approx(speed):
			sword_visual.flip_h = speed < 0.0

		sword.set_meta("speed", move_toward(speed, 0.0, 12.0 * delta))
		var life := float(sword.get_meta("life", 0.0)) - delta
		sword.set_meta("life", life)
		_damage_near_entity(sword, 70.0)
		if life <= 0.0:
			_remove_sword(sword)


func _process_fan(delta: float) -> void:
	for fan_entity in _fan_entities.duplicate():
		if fan_entity == null or not is_instance_valid(fan_entity):
			_fan_entities.erase(fan_entity)
			continue
		var life := float(fan_entity.get_meta("life", 0.0)) - delta
		fan_entity.set_meta("life", life)
		var origin_x := float(fan_entity.get_meta("origin_x", fan_entity.global_position.x))
		var origin_y := float(fan_entity.get_meta("origin_y", fan_entity.global_position.y))
		var direction := float(fan_entity.get_meta("direction", 1.0))
		var phase := int(fan_entity.get_meta("phase", 0))
		fan_entity.global_position.y = origin_y
		if phase == 0:
			fan_entity.global_position.x += direction * 600.0 * delta
			if absf(fan_entity.global_position.x - origin_x) >= 100.0:
				fan_entity.set_meta("phase", 1)
		else:
			fan_entity.global_position.x = move_toward(fan_entity.global_position.x, origin_x, 600.0 * delta)
		_damage_near_entity(fan_entity, 110.0)
		if life <= 0.0:
			fan_entity.queue_free()
			_fan_entities.erase(fan_entity)


func _damage_near_entity(entity: Node2D, radius: float) -> void:
	var hit: Dictionary = entity.get_meta("hit", {})
	for monster in _active_monsters():
		if not (monster is BaseMonster) or not is_instance_valid(monster) or monster.hp <= 0:
			continue
		if entity.global_position.distance_to(monster.global_position) > radius:
			continue
		var id: int = monster.get_instance_id()
		var last_hit := int(hit.get(id, 0))
		var hit_interval := int(entity.get_meta("hit_interval_msec", 1000))
		if hit.has(id) and Time.get_ticks_msec() - last_hit < hit_interval:
			continue
		var actual_damage: int = int(
			monster.receive_friendly_damage(int(entity.get_meta("damage", 1)), "magic", player)
		)
		if actual_damage > 0:
			Global.add_special_effect(monster, Vector2.ZERO, "RoleBeHit", Vector2.ONE, false, 1)
		hit[id] = Time.get_ticks_msec()
	entity.set_meta("hit", hit)


func _remove_sword(sword: Node2D) -> void:
	_sword_entities.erase(sword)
	if is_instance_valid(sword):
		sword.free()


func _add_visual_to_entity(entity: Node2D):
	if effect_frames == null or effect_frames.get_frame_count("default") == 0:
		return null
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = effect_frames
	sprite.animation = &"default"
	sprite.z_index = 1
	_configure_effect_visual(sprite)
	entity.add_child(sprite)
	sprite.play()
	return sprite


func _spawn_effect_for_duration(duration: float) -> void:
	if effect_frames == null or effect_frames.get_frame_count("default") == 0:
		return
	_effect_serial += 1
	var token := _effect_serial
	if _effect != null and is_instance_valid(_effect):
		_effect.queue_free()
	_effect = AnimatedSprite2D.new()
	_effect.sprite_frames = effect_frames
	_effect.animation = &"default"
	_effect.z_index = 1
	_configure_effect_visual(_effect)
	var effect_parent: Node = get_tree().current_scene
	if effect_parent == null:
		effect_parent = self
	effect_parent.add_child(_effect)
	if effect_parent == self:
		_effect.position = Vector2(0, -20)
	else:
		_effect.global_position = global_position + Vector2(0, -20)
	_effect.play()
	if duration > 0.0:
		get_tree().create_timer(duration).timeout.connect(_on_effect_finished.bind(token), CONNECT_ONE_SHOT)


func _on_effect_finished(token: int) -> void:
	if token != _effect_serial:
		return
	if _effect != null and is_instance_valid(_effect):
		_effect.queue_free()
		_effect = null


func use_over() -> void:
	is_use = false
	if weapon_id == "yyzlj":
		fb_cd = -10
		usecd = DRAGON_SWORD_COOLDOWN
		is_canuse = false
		skill_cd.start(DRAGON_SWORD_COOLDOWN)
		return
	fb_cd = 1
	usecd = maxf(skill_cooldown, 0.1)
	skill_cd.start(usecd)


func _configure_effect_visual(sprite: AnimatedSprite2D) -> void:
	var shader := Shader.new()
	shader.code = "shader_type canvas_item; render_mode unshaded; void fragment(){ vec4 c = texture(TEXTURE, UV); float v = max(c.r, max(c.g, c.b)); if (c.a > 0.0 && v < 0.02) { c.a = 0.0; } COLOR = c; }"
	var material := ShaderMaterial.new()
	material.shader = shader
	sprite.material = material


func _exit_tree() -> void:
	if _effect != null and is_instance_valid(_effect):
		_effect.queue_free()
	for sword in _sword_entities:
		if is_instance_valid(sword):
			sword.queue_free()
	_sword_entities.clear()
	for fan_entity in _fan_entities:
		if is_instance_valid(fan_entity):
			fan_entity.queue_free()
	_fan_entities.clear()

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
