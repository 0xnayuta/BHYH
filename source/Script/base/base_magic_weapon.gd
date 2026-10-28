extends Node2D
class_name BaseMagicWeapon

## 数据/属性经槽位查询解析：无持有者时退回 1 号槽位，不直接引用 /root 单例。
var PlayerData: PlayerDataStore:
	get:
		var coop := get_node_or_null("/root/LocalCoop")
		if coop != null:
			return coop.data_for(player) if is_instance_valid(player) else coop.data_for_slot(1)
		return get_node("/root/PlayerData")
var RoleProp: BaseRoleProperties:
	get:
		var coop := get_node_or_null("/root/LocalCoop")
		if coop != null:
			return coop.props_for(player) if is_instance_valid(player) else coop.props_for_slot(1)
		return get_node("/root/RoleProp")

@onready var mg_action: AnimatedSprite2D = $MgAction
@onready var mg_player: AnimationPlayer = $MgPlayer
@onready var skill_cd: Timer = $SkillCD
@onready var hitbox: CollisionShape2D = $HitBox/HitBox
@onready var hit_box: Area2D = $HitBox
var current_player_magic_summon: Node:
	get:
		return Global.get_magic_summon_for(self)
	set(value):
		Global.set_magic_summon_for(self, value)
var fb_cd: float = -10
var mg_cd_pic: Node:
	get:
		return player.get_meta("magic_cd_icon", null) if is_instance_valid(player) else null
var fb_level: int
var obj_attack_dict = {}
var set_count: int = 0
var need_mp = 20
var is_use = false
var is_canuse = true
var cd_remain: int
var usecd: float
var player: BaseHero
var hit_dic = {"power": 0, "hurtBack": [0, 0], "attackKind": "real"}
var self_dir: bool


func set_magic_weapon_player(hero) -> void:
	player = hero


func get_attack_snapshot(attack_name: String = "hit1") -> Dictionary:
	var attack_data: Variant = obj_attack_dict.get(attack_name)
	if attack_data is Dictionary:
		return attack_data.duplicate(true)
	return {}


func _physics_process(_delta: float) -> void:
	if not skill_cd.is_stopped():
		if mg_cd_pic != null:
			mg_cd_pic.max_time = usecd
	if scale.x == -1:
		self_dir = true
	elif scale.x == 1:
		self_dir = false

	if not self is Mirror and not self is GhostDoll:
		if fb_cd > 0:
			self.visible = false
		else:
			visible = true

	if not is_use and mg_player.has_animation("wait") and mg_player.current_animation != "wait":
		mg_player.play("wait")
	if is_use:
		if is_canuse:
			use_skill()

			if is_use:
				is_canuse = false
	elif cd_remain > 0:
		is_canuse = false
	set_count += 1
	if set_count % 30 == 0 and not is_use:
		fix_hero()


func use_skill():
	if enough_mp():
		RoleProp.roleprop.Mp -= need_mp
		show_skill()


func enough_mp():
	return RoleProp.roleprop.Mp > need_mp


func show_skill():
	pass


func fix_hero():
	var get_roleposition = Vector2(RoleProp.role_pos_x, RoleProp.role_pos_y)
	var newposition: Vector2
	if RoleProp.directon:
		scale.x = -1

		self_dir = true
		newposition = get_roleposition - Vector2(100, 180)
	else:
		self_dir = false
		scale.x = 1
		newposition = get_roleposition - Vector2(-100, 180)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", newposition, 0.5)


func use_over():
	is_use = false


func _on_skill_cd_timeout() -> void:
	fb_cd = -10
	is_canuse = true
	skill_cd.stop()

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
