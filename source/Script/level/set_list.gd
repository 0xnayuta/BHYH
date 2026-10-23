extends GridContainer

@onready var backpack: TextureButton = $"../ButtonGroup/backpack"
@onready var _set: TextureButton = $"../ButtonGroup/set"
@onready var skill: TextureButton = $"../ButtonGroup/skill"
@onready var magic_weapon: TextureButton = $"../ButtonGroup/magic_weapon"
@onready var pet: TextureButton = $"../ButtonGroup/pet"
var set_cd: float = 0


func _physics_process(delta):
	# PC 端按钮常驻；仅移动端恢复自动隐藏。
	if not OS.has_feature("android") or not backpack.visible:
		set_cd = 0
		return
	set_cd += delta
	if set_cd >= 5:
		set_cd = 0
		_on_menu_pressed()


func _on_menu_pressed():
	var is_hidden: bool = !backpack.visible
	backpack.visible = is_hidden
	_set.visible = is_hidden
	skill.visible = is_hidden
	magic_weapon.visible = is_hidden
	pet.visible = is_hidden
