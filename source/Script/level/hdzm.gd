extends Node2D

const MAP3_CSM_TEXTURE := preload("res://Art/game_3/other_map_button/jjtj.png")
const MAP4_CSM_TEXTURE := preload("res://Art/game_3/other_map_button/hdtt.png")

@onready var csm: Sprite2D = $Hdzm/csm
var parent_node
var _applied_csm_texture: Texture2D


func _physics_process(_delta: float) -> void:
	var texture: Texture2D = null
	if parent_node is Map3:
		texture = MAP3_CSM_TEXTURE
	elif parent_node is Map4:
		texture = MAP4_CSM_TEXTURE
	if texture != null and texture != _applied_csm_texture:
		csm.texture = texture
		_applied_csm_texture = texture


func _on_ttzstz_pressed() -> void:
	if PlayerData.check_eq_zb("头衔", "xczg"):
		Global.add_message_show(get_parent(), "本副本不允许使用修成正果头衔！", 1.5, Vector2(470, 300))
		return
	if PlayerData.player_data[DataKeys.PLAYER_LEVEL] <= 50:
		Global.add_message_show(get_parent(), "需要角色等级大于50级！", 1.5, Vector2(470, 300))
		return
	elif PlayerData.get_item_data("ttlp") == 0:
		Global.add_message_show(get_parent(), "需要拥有通天令牌！", 1.5, Vector2(470, 300))
		return
	elif not PlayerData.player_data["截教天镜"]:
		Global.add_message_show(get_parent(), "前置关卡要求未达到！", 1.5, Vector2(470, 300))
		return
	Global.change_scene("res://Scene/level/level_hdzm.tscn")


func _on_csm_pressed() -> void:
	if parent_node == null:
		return
	if parent_node is Map3:
		if PlayerData.player_data[DataKeys.PLAYER_LEVEL] < 50:
			Global.add_message_show(get_parent(), "需要角色等级大于等于50级！", 1.5, Vector2(470, 300))
		elif PlayerData.get_item_data("ttlp") == 0:
			Global.add_message_show(get_parent(), "需要拥有通天令牌！", 1.5, Vector2(470, 300))
		elif not PlayerData.player_data["截教天镜"]:
			Global.add_message_show(get_parent(), "前置关卡要求未达到！", 1.5, Vector2(470, 300))
		else:
			if PlayerData.player_data["FristJiejiao"]:
				Signals.connect_choose_box_signal(self, "challenge")
				Global.add_choose_text(self, Vector2(0, 0), "后面关卡可能非常难，需要极高的耐心和技术，确定继续挑战吗？（截教部分关卡无法使用修成正果头衔！）", 0)
			else:
				Global.change_scene("res://Scene/main_menu/map_4.tscn")
	elif parent_node is Map4:
		Global.change_scene("res://Scene/main_menu/map_3.tscn")


func challenge():
	PlayerData.player_data["FristJiejiao"] = false
	Global.change_scene("res://Scene/main_menu/map_4.tscn")
	MemoryClass.save_game(Global.cd_path)


func _on_hdgq_pressed() -> void:
	if PlayerData.check_eq_zb("头衔", "xczg"):
		Global.add_message_show(get_parent(), "本副本不允许使用修成正果头衔！", 1.5, Vector2(470, 300))
		return
	if PlayerData.player_data[DataKeys.PLAYER_LEVEL] <= 50:
		Global.add_message_show(get_parent(), "需要角色等级大于50级！", 1.5, Vector2(470, 300))
		return
	elif PlayerData.get_item_data("ttlp") == 0:
		Global.add_message_show(get_parent(), "需要拥有通天令牌！", 1.5, Vector2(470, 300))
		return
	elif not PlayerData.player_data["截教天镜"]:
		Global.add_message_show(get_parent(), "前置关卡要求未达到！", 1.5, Vector2(470, 300))
		return
	Global.addhdgqmap(self, Vector2(0, 0))


func _on_close_pressed() -> void:
	queue_free()
