extends CharacterBody2D
var item_name: String
var _num: int
var is_set: bool
var is_set2: bool
@onready var item_pic: Sprite2D = $item_pic
@onready var remove_pl = $remove_player
@onready var get_area: CollisionShape2D = $Area2D/get_area
var is_pick: bool
var player: BaseHero


func _physics_process(delta: float) -> void:
	if not is_set2:
		set_pic(item_name)
		if MainSet.set_data["automatically_pick_up_items"]:
			get_area.disabled = true
		else:
			get_area.disabled = false
		is_set2 = true
	player = get_parent().get_parent()._role

	if not is_on_floor():
		velocity.y -= delta * -980
	if MainSet.set_data["automatically_pick_up_items"]:
		if not is_pick:
			automatically_pick_up_items()

	move_and_slide()


func set_pic(_name):
	var texture_path = "res://Art/item_icon/" + str(_name).to_lower() + ".png"
	var texture = load_soft(texture_path)

	if not texture:
		texture_path = "res://Art/backpack/all_items/" + str(_name).to_lower() + ".png"
		texture = load_soft(texture_path)

	if not texture:
		var item_data: Dictionary = AE.all_equipment.get(str(_name), {})
		var custom_icon_path := str(item_data.get("图标", ""))
		if custom_icon_path != "":
			texture = load_soft(custom_icon_path)

	if not texture:
		texture = load_soft("res://Art/item_icon/zxbx_3.png")

	if item_pic:
		item_pic.visible = true
		item_pic.scale = Vector2(1, 1)
		item_pic.modulate = Color(1, 1, 1, 1)
		item_pic.region_enabled = false
		item_pic.centered = true
		item_pic.z_index = 100
		item_pic.flip_h = false
		item_pic.flip_v = false
		item_pic.texture = texture

	if item_name == "peach" or item_name == "Bble" or item_name == "radish":
		await get_tree().create_timer(6).timeout
		queue_free()


func load_soft(path: String) -> Texture2D:
	return Global.get_static_texture(path)


func automatically_pick_up_items():
	pick_up_items(player)


func _on_area_2d_body_entered(body: Node2D) -> void:
	pick_up_items(body)


func pick_up_items(body):
	if MainSet.set_data["PickUpItemsMusic"]:
		Global.add_sound(self, "res://Music/level/86_pickup.mp3")
	if item_name != "peach" and item_name != "Bble" and item_name != "radish":
		var get_type = AE.all_equipment[item_name][DataKeys.TYPE]
		match get_type:
			"武器", "防具", "饰品", "翅膀", "时装", "头衔":
				if not PlayerData.check_can_use_page("装备列表") == 0:
					PlayerData.add_zb(item_name, 0, {})
				else:
					return
			"法宝":
				if not PlayerData.check_can_use_page("装备列表") == 0:
					PlayerData.add_fb(item_name, 0, AE.get_wx(), {})
				else:
					return
			"道具":
				if PlayerData.get_dj_page(item_name) != 0 or not PlayerData.check_can_use_page("道具列表") == 0:
					PlayerData.add_dj(item_name, max(1, _num))
				else:
					return
			"消耗品":
				if PlayerData.get_xhp_page(item_name) != 0 or not PlayerData.check_can_use_page("消耗品列表") == 0:
					PlayerData.add_xhp(item_name, _num)
				else:
					return
			"宠物装备":
				if PlayerData.has_method("add_pet_backpack_item"):
					var added_count := int(PlayerData.add_pet_backpack_item(item_name, max(1, _num)))
					if added_count <= 0:
						return
					_save_pet_backpack_pickup()
				else:
					return
	match item_name:
		"peach":
			body.cure_hp(RoleProp.roleprop.SHp * 0.45)
			body.cure_mp(RoleProp.roleprop.SMp * 0.45)
		"Bble":
			body.cure_mp(RoleProp.roleprop.SMp * 0.2)

		"radish":
			body.cure_hp(RoleProp.roleprop.SHp * 0.25)
	is_pick = true
	remove_pl.play("remove")


func _save_pet_backpack_pickup() -> void:
	MemoryClass.request_save("pet_backpack_pickup")


func pick():
	is_pick = true
