extends Node2D
@onready var box_1: Button = $text/box_1
@onready var text: Label = $text
@onready var player: AnimationPlayer = $player
var lq: bool = false
var textlist = [
	"挑战失败了？放弃吧，接受我的黑暗力量，这样你才能更强！",
	"不是吧，不是吧，这都打不过，我可以给你无穷的力量，接受我吧！",
	"坚持正义有用吗？你看，这么多人都已经接受我的黑暗力量了，你再努力可能像我一样强大吗？！",
	"接受我的力量吧，我可以让你天下无敌！！",
]
var textlist2 = [
	"没关系的，你迟早会需要我，哈哈哈哈！",
	"哦？你可不要后悔哦！",
	"好吧好吧，我会等着你的~",
	"没有人可以拒绝我的力量，你也不可能！！马上，你就会选择我，哈哈哈哈！！！",
	"不不不，你需要的，也许下一次，你就会接受我。",
	"嗯？坚守正义吗？哈哈哈哈！！！正义给你带来了什么呢？不要搞笑了，好吗？",
	"假惺惺的，你真的是正义吗？",
	"没有我，你不可能通关的，好好想想哦！~",
	"哦吼？呵呵！~",
	"装模做样，不敢永远拒绝吗？那还装什么呢？接受我吧！",
]
var textlist3 = [
	"好吧，好吧，看来你还是有点骨气的，祝你好运喽~",
	"？你真的敢！？下个存档再见喽！~",
	"躲得了一时，躲不了一世，你迟早会接受我，无论什么原因！",
]
const DEFEAT_DESIGN_SIZE := Vector2(940.0, 590.0)


func _fit_to_window() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var fit_scale = min(viewport_size.x / DEFEAT_DESIGN_SIZE.x, viewport_size.y / DEFEAT_DESIGN_SIZE.y)
	var content_size = DEFEAT_DESIGN_SIZE * fit_scale
	scale = Vector2(fit_scale, fit_scale)
	position = (viewport_size - content_size) * 0.5


var textlist4 = [
	"没错，没错，就是这样，我们是无敌的！！",
	"明智的选择，让我们来教训一下这些弱小的东西吧！！",
	"哈哈哈哈，我就知道你会接受我，我们是一类人，不是吗？",
	"对了，太对了，我来助你平定八荒！",
	"力量是属于强者的，而你，就是强者！",
]


func _ready() -> void:
	_fit_to_window()
	if not get_viewport().size_changed.is_connected(_fit_to_window):
		get_viewport().size_changed.connect(_fit_to_window)
	if not PlayerData.player_data["zyforever"] or not PlayerData.player_data["ieho"]:
		text.text = str(textlist[randi_range(0, textlist.size() - 1)])
		player.play("dh_1")
	else:
		player.play("dh_6")
		text.text = ""
	Global.add_bgm(self, "res://Music/level/12_over.mp3")
	box_1.is_in_ldl_gz = true
	box_1.is_in_hhgz = true
	box_1.set_button_icon(load_item_icon("xczg"))
	box_1.qh_level = 0
	box_1.wx = []
	box_1.eq_prop = AE.all_equipment["xczg"]
	if MainSet.is_auto_battle_enabled() and bool(MainSet.set_data.get("AutoBattleRetry", false)):
		call_deferred("_auto_rechallenge")


func _auto_rechallenge() -> void:
	await get_tree().create_timer(1.0).timeout
	if is_inside_tree() and not _is_rechallenging:
		_on_re_challenge_pressed()


func _on_return_map_pressed() -> void:
	RoleProp.ws_value = 0
	Global.is_dead_link = false
	if Global.current_level == "镇妖塔":
		Global.change_scene("res://Scene/main_menu/map_0.tscn")
		MemoryClass.request_save("level_defeat_return")
		return
	match int(PlayerData.player_data["Map_num"]):
		1:
			Global.change_scene("res://Scene/main_menu/map_1.tscn")
		2:
			Global.change_scene("res://Scene/main_menu/map_2.tscn")
		3:
			Global.change_scene("res://Scene/main_menu/map_3.tscn")
		4:
			Global.change_scene("res://Scene/main_menu/map_4.tscn")
		5:
			Global.change_scene("res://Scene/main_menu/map_5.tscn")
		6:
			Global.change_scene("res://Scene/main_menu/map_6.tscn")
		7:
			Global.change_scene("res://Scene/main_menu/map_7.tscn")
		8:
			if PlayerData.player_data.get("Map_variant", "") == "Map_8_1":
				Global.change_scene("res://Scene/main_menu/map_8_1.tscn")
			else:
				Global.change_scene("res://Scene/main_menu/map_8.tscn")
		9:
			if PlayerData.player_data.get("Map_variant", "") == "Map_9_1":
				Global.change_scene("res://Scene/main_menu/map_9_1.tscn")
			else:
				Global.change_scene("res://Scene/main_menu/map_9.tscn")
		_:
			Global.change_scene("res://Scene/main_menu/map_0.tscn")
	MemoryClass.request_save("level_defeat_return")


var _is_rechallenging := false


func _reset_role_state_for_rechallenge() -> void:
	RoleProp.set_full_hp()
	RoleProp.set_full_mp()
	RoleProp.current_hp = int(RoleProp.roleprop.Hp)
	RoleProp.current_mp = int(RoleProp.roleprop.Mp)
	RoleProp.ws_value = 0
	RoleProp.is_ws_state = false
	Global.is_dead_link = false


func _on_re_challenge_pressed() -> void:
	if _is_rechallenging:
		return
	if Global.last_level_path == "":
		Global.add_message_show(Global.windows, "获取关卡信息时出现错误，请手动更换关卡！！", 1.5, Vector2(470, 300))
		return
	_is_rechallenging = true
	_reset_role_state_for_rechallenge()
	Global.change_scene(Global.last_level_path)


func load_item_icon(_name):
	var abc = load("res://Art/backpack/all_items/" + str(_name) + ".png")
	return abc


func _on_js_pressed() -> void:
	text.text = str(textlist4[randi_range(0, textlist4.size() - 1)])
	PlayerData.add_zb("xczg", 0, {})
	MemoryClass.request_save("level_defeat_reward")
	player.play("dh_2")


func _on_yjjj_pressed() -> void:
	PlayerData.player_data["zyforever"] = true
	MemoryClass.request_save("level_defeat_reward")
	text.text = str(textlist3[randi_range(0, textlist3.size() - 1)])
	player.play("dh_3")


func _on_jj_pressed() -> void:
	text.text = str(textlist2[randi_range(0, textlist2.size() - 1)])
	player.play("dh_2")


func _on_lqjl_pressed() -> void:
	if lq:
		return
	PlayerData.add_dj("bsd_5", 1)
	PlayerData.add_dj("mpyj", 1)
	PlayerData.add_dj("xydxq", 3)
	PlayerData.add_dj("qhs_4", 8)
	PlayerData.add_dj("qhs_3", 8)
	PlayerData.add_dj("qhs_2", 8)
	PlayerData.add_dj("qhs_1", 8)
	lq = true


func _exit_tree() -> void:
	if get_viewport().size_changed.is_connected(_fit_to_window):
		get_viewport().size_changed.disconnect(_fit_to_window)
