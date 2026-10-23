extends TextureRect
var _texture = "poision"
var _tt
var _last_texture_key := ""


func _ready() -> void:
	_refresh_texture()


func _physics_process(_delta: float) -> void:
	if _last_texture_key != _texture:
		_refresh_texture()


func _refresh_texture() -> void:
	_last_texture_key = _texture
	set_texture(load_item_icon(_texture))


func _on_mouse_entered() -> void:
	match _texture:
		"poision":
			_tt = Global.add_buff_info(self, Vector2(35, 35), "中毒：受中毒效果影响，这个单位开始每秒扣除一定的生命值。")
		"mp_poision":
			_tt = Global.add_buff_info(self, Vector2(35, 35), "反噬：在使用消耗魔法的行动时，迅速除相当于所消耗魔法一定比率的生命。")
		"ice":
			_tt = Global.add_buff_info(self, Vector2(35, 35), "冰封：这个单位现在处于冰冻状态，无法做出某些行动。")
		"Fire":
			_tt = Global.add_buff_info(self, Vector2(35, 35), "灼烧：受灼烧效果影响，这个单位开始每秒扣除一定的生命值。")
		"speed_down":
			_tt = Global.add_buff_info(self, Vector2(35, 35), "减速：这个单位的移动速度降低了。")
		"stun":
			_tt = Global.add_buff_info(self, Vector2(35, 35), "眩晕：这个单位现在处于眩晕状态，无法做出某些行动。")
		"htsf":
			_tt = Global.add_buff_info(self, Vector2(35, 35), "护体石肤：这个单位拥有极高的护盾\n并且防御能力大大提升。")
		"Bleed":
			_tt = Global.add_buff_info(self, Vector2(35, 35), "流血：这个单位正在持续快速流血。")
		"yxbuff":
			_tt = Global.add_buff_info(self, Vector2(35, 35), "入魔：提升攻击力、暴击率、幸运。")


func _on_mouse_exited() -> void:
	if _tt != null:
		_tt.queue_free()


func load_item_icon(_name):
	if _name == "mp_poision":
		_name = "poision"
	return Global.get_cached_texture("res://Art/add_effect/buff_icon/" + str(_name).to_lower() + ".png")
