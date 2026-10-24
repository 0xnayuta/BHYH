extends TextureRect
signal selection_requested(head: Node)

const MonsterAttrData = preload("res://Scene/other_scene/monster_attr_data.gd")
const MONSTER_HEAD_FALLBACKS := {
	"stz_nz": "res://Art/monster/game_3_monster/three_prince/nezha/idle/1.png",
	"stz_mz": "res://Art/monster/game_3_monster/three_prince/muzha/idle/1.png",
	"stz_jz": "res://Art/monster/game_3_monster/three_prince/jinzha/idle/1.png",
	"bxgh_163": "res://Art/monster/game_3_monster/monster_163/body/1.png",
	"bxgh_175": "res://Art/monster/game_3_monster/monster_175/body/1.png",
	"bxgh_165": "res://Art/monster/game_3_monster/monster_165/body/1.png",
	"bxgh_166": "res://Art/monster/game_3_monster/monster_166/body/1.png",
	"bxgh_168": "res://Art/monster/game_3_monster/monster_168/body/1.png",
	"bxgh_169": "res://Art/monster/game_3_monster/monster_169/body/1.png",
	"bxgh_174": "res://Art/monster/game_3_monster/monster_174/body/1.png",
	"bxgh_164": "res://Art/monster/game_3_monster/monster_164/body/1.png",
	"轸宿": "res://Art/constellations/icons/1.png",
	"翼火蛇": "res://Art/constellations/icons/2.png",
	"张月鹿": "res://Art/constellations/icons/3.png",
	"星日马": "res://Art/constellations/icons/4.png",
	"柳宿": "res://Art/constellations/icons/5.png",
	"鬼宿": "res://Art/constellations/icons/6.png",
	"井宿": "res://Art/constellations/icons/7.png",
	"壁宿": "res://Art/constellations/icons/8.png",
	"室宿": "res://Art/constellations/icons/9.png",
	"危宿": "res://Art/constellations/icons/10.png",
	"虚宿": "res://Art/constellations/icons/11.png",
	"女宿": "res://Art/constellations/icons/12.png",
	"牛宿": "res://Art/constellations/icons/13.png",
	"斗宿": "res://Art/constellations/icons/14.png",
}
const ATLAS_HEAD_MODELS := {
	"xwm3001": 3001,
	"xwm3003": 3003,
	"xwm3004": 3004,
	"xwm3005": 3005,
	"zqj3002": 3002,
	"zqj3006": 3006,
	"weiyang3007": 3007,
	"蘑菇精": 3008,
	"金钱松": 3009,
	"闵老护法": 3019,
	"人形藤蔓": 3010,
	"苍耳妖": 3011,
	"道明妖僧": 3020,
	"木之祖巫": 3021,
	"虾兵": 3031,
	"虎鲨": 3029,
	"灵感大王": 3033,
	"贝壳": 3028,
	"夜叉": 3032,
	"四头虫": 3034,
	"蚌女": 3030,
	"水之祖巫": 3035,
	"火焰鸟": 3036,
	"蝎子精": 3037,
	"忍猴": 3038,
	"百足蜈蚣": 3039,
	"岩石怪": 3047,
	"赤炎金刚": 3040,
	"噬火毒蝎": 3041,
	"火之祖巫": 3042,
	"鸟身女妖": 3065,
	"泥偶精": 3066,
	"花妖": 3067,
	"核桃精": 3068,
	"金光孔雀": 3069,
	"芙蓉仙子": 3070,
	"土之祖巫": 3071,
	"守卫": 3076,
	"通天教主(穷奇版)": 3117,
	"金沙村小怪": 3118,
	"金沙村飞行怪": 3119,
	"金沙村首领": 3120,
	"煞人蜂": 3119,
	"3159": 3159,
	"3160": 3160,
	"3161": 3161,
	"3172": 3172,
	"3177": 3177,
	"3178": 3177,
	"3179": 3179,
	"3181": 3181,
	"3182": 3182,
	"3183": 3181,
	"3136": 3136,
	"3144": 3144,
	"3145": 3121,
	"3146": 3122,
	"3198": 3198,
	"3199": 3199,
	"3200": 3200,
	"3201": 3201,
	"3221": 3199,
	"3222": 3222,
	"3223": 3223,
	"3226": 3198,
	"3274": 3222,
	"3275": 3198,
	"3276": 3276,
	"3277": 3277,
	"3308": 3308,
	"3309": 3309,
	"3310": 3310,
	"3320": 3320,
	"3321": 3308,
	"3322": 3309,
	"3323": 3323,
	"3340": 3320,
	"3341": 3308,
	"3342": 3309,
	"3343": 3343,
	"3352": 3352,
}
const HUMAN_SOUL_CRYSTAL_MONSTER_IDS := {
	"xh": 1,
	"yh": 2,
	"dxx": 3,
	"mhw": 4,
	"yrw": 5,
	"lw": 6,
	"bf": 7,
	"bfsx": 8,
	"dsj": 9,
	"ys": 10,
	"stw": 11,
	"pmw": 12,
	"jjy": 13,
	"xb": 14,
	"xj": 15,
	"yjj": 16,
	"gcx": 17,
	"jmw": 18,
	"smw": 20,
	"nmds": 21,
	"nmw1": 22,
	"nmw2": 23,
	"nmw3": 24,
}
const UNDERWORLD_SOUL_CRYSTAL_MONSTER_IDS := {
	"gd": 26,
	"js": 27,
	"syr": 28,
	"bgj": 32,
	"hwc": 30,
	"bwc": 31,
	"klw": 33,
	"qgw": 37,
	"nt": 40,
	"mm": 39,
	"pg": 41,
	"ylw": 43,
	"yc": 48,
	"mp": 49,
	"mz": 53,
	"sh": 51,
	"qs": 54,
	"ht": 52,
	"zlsz": 58,
	"zlw1": 57,
	"zlw2": 55,
	"zlw3": 56,
}
const HEAVEN_SOUL_CRYSTAL_MONSTER_IDS := {
	"hg": 74,
	"hh": 75,
	"wy": 76,
	"qly": 77,
	"sfe": 78,
	"jls": 79,
	"tbq": 80,
	"tbd": 81,
	"tbg": 82,
	"zztw": 83,
	"gmtw": 84,
	"dwtw": 85,
	"goy": 86,
	"yy": 87,
	"ny": 88,
	"zzz": 89,
	"sey": 90,
	"yuh": 91,
	"wgj": 92,
	"els": 93,
	"mhwtf": 96,
	"jdhw": 97,
	"cdhw": 98,
	"hdhw": 99,
	"txs": 100,
	"lzz": 101,
	"nz": 102,
	"tttw": 103,
	"lhtz": 104,
	"wdtz": 105,
	"ghtz": 106,
	"yjdw": 107,
	"jjdw": 108,
	"yntz": 109,
	"qnj": 110,
	"rstz": 111,
	"tbjx": 112,
	"dhtz": 113,
	"tslj": 114,
	"mtj": 134,
	"twsz": 135,
	"cgkl": 136,
	"cgtw": 137,
}
@onready var hy: Sprite2D = $Hy
@onready var pic: Sprite2D = $pic
@onready var hot_area: ColorRect = $ColorRect

@onready var monster_name_button: Button = $MonsterName
@onready var boss: Label = $Boss

var monster_info: Node = null
var hover_attr_panel: Control = null
var level_monster_config: Dictionary = {}
var is_boss: bool = true
var monster_name: String = "dxx"
var monster_scene_path: String = ""
var level_path: String = ""
var is_set: bool
var is_selectable: bool = false
var is_selected: bool = false
var _selection_frame: Panel = null
var _hover_exit_grace_frames := 0
var monster_name_list = {
	"3159": "猴妖",
	"3160": "银杏精",
	"3161": "通臂白猿",
	"3172": "法杖教徒",
	"3177": "蘑菇长老",
	"3178": "蘑菇长老",
	"3179": "六耳猕猴",
	"3181": "骨刺兽",
	"3182": "雨之祖巫",
	"3183": "骨刺兽",
	"3136": "风之祖巫",
	"3144": "银甲守卫",
	"3145": "花骨朵",
	"3146": "毒毛虫",
	"3198": "吸血蝙蝠",
	"3199": "雷吼兽",
	"3200": "千年蝠妖",
	"3201": "召唤小蝙蝠",
	"3221": "雷吼兽",
	"3222": "邪魅童子",
	"3223": "黄眉大王",
	"3226": "吸血蝙蝠",
	"3274": "邪魅童子",
	"3275": "吸血蝙蝠",
	"3276": "虎妖",
	"3277": "雷之祖巫",
	"3308": "小狐狸",
	"3309": "琉璃鸟",
	"3310": "九尾天狐",
	"3320": "金甲护卫",
	"3321": "小狐狸",
	"3322": "琉璃鸟",
	"3323": "金翅大鹏雕",
	"3340": "金甲护卫",
	"3341": "小狐狸",
	"3342": "琉璃鸟",
	"3343": "电之祖巫",
	"3352": "通天教主(混沌版)",
	"3118": "金沙村小怪",
	"3119": "金沙村飞行怪",
	"3120": "金沙村首领",
	"3126": "煞人蜂",
	"stz_nz": "哪吒",
	"stz_mz": "木吒",
	"stz_jz": "金吒",
	"bxgh_163": "魔·吕洞宾",
	"bxgh_175": "魔·何仙姑",
	"bxgh_165": "魔·韩湘子",
	"bxgh_166": "魔·汉钟离",
	"bxgh_168": "魔·张果老",
	"bxgh_169": "魔·蓝采和",
	"bxgh_174": "魔·曹国舅",
	"bxgh_164": "魔·铁拐李",
	"xh": "小猴子",
	"yh": "妖猴",
	"dxx": "大猩猩",
	"mhw": "猕猴王",
	"lw": "龙王",
	"yrw": "禺狨王",
	"bf": "蝙蝠",
	"bfsx": "蝙蝠石像",
	"ys": "妖狮",
	"dsj": "地鼠精",
	"stw": "狮驼王",
	"jjy": "机甲鹰",
	"pmw": "鹏魔王",
	"xb": "虾兵",
	"xj": "蟹将",
	"gcx": "龟丞相",
	"yjj": "鱼将军",
	"jmw": "蛟魔王",
	"smw": "鲨魔王",
	"sy": "嗜血狂鲨",
	"nmds": "牛魔斗士",
	"nmw1": "牛魔王一",
	"nmw2": "牛魔王二",
	"nmw3": "牛魔王三",
	"hhe": "红孩儿",
	"gd": "鬼灯",
	"js": "僵尸",
	"syr": "守夜人",
	"bgj": "白骨精",
	"hwc": "黑无常",
	"bwc": "白无常",
	"kl": "傀儡",
	"klw": "傀儡王",
	"qgw": "秦广王",
	"pg": "判官",
	"ylw": "阎罗王",
	"sdgm": "三道鬼门",
	"sdw": "宋帝王",
	"yc": "夜叉",
	"mp": "孟婆",
	"xt": "刑天",
	"zsxt": "战神刑天",
	"zlw1": "转轮王一",
	"zlw2": "转轮王二",
	"zlw3": "转轮王三",
	"wgw": "五官王",
	"bcw": "卞城王",
	"tsw": "泰山王",
	"dsw": "都市王",
	"pdw": "平等王",
	"nt": "牛头",
	"mm": "马面",
	"mz": "曼珠",
	"sh": "沙华",
	"qs": "青蛇",
	"ht": "河童",
	"zlsz": "转轮使者",
	"gy": "鬼鱼",
	"xtq": "哮天犬",
	"ey": "恶鹰",
	"hg": "黑龟",
	"hh": "黑虎",
	"wy": "巫鹰",
	"qly": "千里眼",
	"sfe": "顺风耳",
	"mhwtf": "猕猴王·通风",
	"jls": "巨灵神",
	"tbd": "天兵刀",
	"tbq": "天兵枪",
	"tbg": "天兵弓",
	"tbf": "天兵斧",
	"tbc": "天兵锤",
	"zztw": "增长天王",
	"gmtw": "广目天王",
	"dwtw": "多闻天王",
	"mtj": "马天君",
	"twsz": "天王使者",
	"cgkl": "持国傀儡",
	"cgtw": "持国天王",
	"zzz": "朱子真",
	"yuh": "袁洪",
	"els": "二郎神",
	"goy": "狗妖",
	"yy": "羊妖",
	"ny": "牛妖",
	"sey": "蛇妖",
	"wgj": "蜈蚣精",
	"hdhw": "黑雕护卫",
	"cdhw": "长刀护卫",
	"jdhw": "巨盾护卫",
	"txs": "土行孙",
	"lzz": "雷震子",
	"nz": "哪吒",
	"tttw": "托塔天王",
	"lhtz": "硫磺童子",
	"wdtz": "巫毒童子",
	"ghtz": "勾魂童子",
	"yntz": "隐匿童子",
	"rstz": "人参童子",
	"dhtz": "电魂童子",
	"yjdw": "银角大王",
	"jjdw": "金角大王",
	"qnj": "青牛精",
	"tbjx": "太白金星",
	"tslj": "太上老君",
	"hlhw": "火龙护卫",
	"hylqs": "黑烟炼气师",
	"emlqs": "噩梦炼气师",
	"yflqs": "妖风炼气师",
	"dylqs": "地狱炼气师",
	"hbsz": "花豹圣者·高友乾",
	"jnsz": "狻猊圣者·杨森",
	"basz": "狴犴圣者·王魔",
	"znsz": "狰狞圣者",
	"ly": "吕岳",
	"yzx": "焰中仙",
	"fyj": "飞烟剑",
	"wll": "五龙轮",
	"lzg": "雷钻怪",
	"fl": "凤翎",
	"bx": "碧霄",
	"qx": "琼霄",
	"yx": "云霄",
	"qnyw": "千年妖蚊",
	"qnyc": "千年妖蝉",
	"qnwg": "千年蜈蚣",
	"fyg": "飞翼怪",
	"cysj": "赤月神君",
	"bssj": "白水神君",
	"zmjw": "紫眸鹫王",
	"zqpw": "紫晴鹏王",
	"qysj": "青阳神君",
	"hyr": "黑衣人",
	"ttjz": "通天教主",
	"ttjz2": "通天教主2",
	"ttjz3": "通天教主3",
	"ce": "嫦娥",
	"qiongqi": "穷奇",
	"taowu": "梼杌",
	"hundun": "混沌",
	"taotie": "饕餮",
	"zxjboss": "诛仙剑",
	"xxjboss": "陷仙剑",
	"lxjboss": "戮仙剑",
	"jxjboss": "绝仙剑",
	"xwm3001": "魔盾虎兵",
	"xwm3003": "牛铁枪",
	"xwm3004": "投石车",
	"xwm3005": "寅将军",
	"zqj3002": "猛虎射手",
	"zqj3006": "特处士",
	"weiyang3007": "金之祖巫",
	"蘑菇精": "蘑菇精",
	"金钱松": "金钱松",
	"闵老护法": "闵老护法",
	"人形藤蔓": "人形藤蔓",
	"苍耳妖": "苍耳妖",
	"道明妖僧": "道明妖僧",
	"木之祖巫": "木之祖巫",
}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	gui_input.connect(_on_selection_gui_input)
	if hot_area != null:
		hot_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	monster_name_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mouse_entered.connect(_on_monster_hover_entered)
	mouse_exited.connect(_on_monster_hover_exited)
	_apply_selectable_cursor()


func set_selectable(value: bool) -> void:
	is_selectable = value
	_apply_selectable_cursor()


func _apply_selectable_cursor() -> void:
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if is_selectable else Control.CURSOR_ARROW
	if hot_area != null:
		hot_area.mouse_default_cursor_shape = mouse_default_cursor_shape


func set_selected(value: bool) -> void:
	is_selected = value
	if _selection_frame == null:
		_selection_frame = Panel.new()
		_selection_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_selection_frame.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_selection_frame.z_index = 20
		var style := StyleBoxFlat.new()
		style.bg_color = Color(1.0, 0.72, 0.12, 0.08)
		style.border_color = Color(1.0, 0.72, 0.12, 1.0)
		style.set_border_width_all(3)
		style.set_corner_radius_all(4)
		_selection_frame.add_theme_stylebox_override("panel", style)
		add_child(_selection_frame)
	_selection_frame.visible = value


func get_display_name() -> String:
	return str(monster_name_list.get(monster_name, monster_name))


func _on_selection_gui_input(event: InputEvent) -> void:
	if not is_selectable:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		selection_requested.emit(self)
		accept_event()
	elif event is InputEventScreenTouch and event.index >= 0 and event.pressed:
		selection_requested.emit(self)
		accept_event()


func _physics_process(delta: float) -> void:
	if not is_set:
		var configured_name := str(level_monster_config.get("name", ""))
		monster_name_button.text = (
			configured_name if not configured_name.is_empty() else monster_name_list.get(monster_name, monster_name)
		)
		if is_boss:
			boss.visible = true
		else:
			boss.visible = false
		pic.texture = load_item_icon(monster_name)
		_fit_head_icon()
		_setup_north_idle_preview()
		is_set = true


func _setup_north_idle_preview() -> void:
	if not monster_scene_path.begins_with("res://Scene/monster/monster_"):
		return
	var id := monster_scene_path.get_file().get_basename().to_lower().trim_prefix("monster_").to_int()
	var frames_path := "res://Art/monster/north_original/%d/north_original_%d_frames.tres" % [id, id]
	if not ResourceLoader.exists(frames_path):
		return
	var frames := load(frames_path) as SpriteFrames
	if frames == null or not frames.has_animation(&"wait") or frames.get_frame_count(&"wait") == 0:
		return
	var preview := AnimatedSprite2D.new()
	preview.name = "IdlePreview"
	preview.sprite_frames = frames
	preview.position = pic.position
	preview.show_behind_parent = true
	var max_size := Vector2.ONE
	for index in range(frames.get_frame_count(&"wait")):
		var tex := frames.get_frame_texture(&"wait", index)
		if tex != null:
			max_size = max_size.max(tex.get_size())
	var icon_scale := minf(56.0 / max_size.x, 52.0 / max_size.y)
	preview.scale = Vector2.ONE * icon_scale
	add_child(preview)
	pic.hide()
	preview.play(&"wait")


func load_item_icon(_name):
	var head_path := "res://Art/monster/monster_head/" + str(_name) + ".png"
	if ResourceLoader.exists(head_path):
		return load(head_path)
	var fallback_path := str(MONSTER_HEAD_FALLBACKS.get(str(_name), ""))
	if fallback_path != "" and ResourceLoader.exists(fallback_path):
		return Global.get_cached_texture(fallback_path)
	var model_value: Variant = ATLAS_HEAD_MODELS.get(str(_name), 0)
	if model_value is int and int(model_value) > 0:
		var model_id := int(model_value)
		var frames_path := "res://Art/monster/swf_png/%d/atlas/swf_png_%d_frames.tres" % [model_id, model_id]
		if ResourceLoader.exists(frames_path):
			var frames := load(frames_path) as SpriteFrames
			if frames != null:
				for anim in [&"wait", &"idle", &"walk"]:
					if frames.has_animation(anim) and frames.get_frame_count(anim) > 0:
						var tex := frames.get_frame_texture(anim, 0)
						if tex != null:
							return tex
	return null


func _texture_from_packed_atlas_sequence(manifest: Dictionary, sequence: Dictionary) -> Texture2D:
	var frames: Array = sequence.get("frames", [])
	var pages: Array = manifest.get("pages", [])
	if frames.is_empty() or not frames[0] is Array:
		return null
	var entry: Array = frames[0]
	if entry.size() < 10:
		return null
	var page_index := int(entry[1])
	if page_index < 0 or page_index >= pages.size() or not pages[page_index] is Dictionary:
		return null
	var page_path := str((pages[page_index] as Dictionary).get("path", ""))
	var page_texture := Global.get_cached_texture(page_path)
	if page_texture == null:
		return null
	var texture := AtlasTexture.new()
	texture.atlas = page_texture
	texture.region = Rect2(float(entry[2]), float(entry[3]), float(entry[4]), float(entry[5]))
	texture.margin = Rect2(float(entry[6]), float(entry[7]), float(entry[8]), float(entry[9]))
	texture.filter_clip = true
	return texture


func _fit_head_icon() -> void:
	if pic == null or pic.texture == null:
		return
	var texture_size := pic.texture.get_size()
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return
	var max_size := Vector2(56, 52)
	var icon_scale = min(max_size.x / texture_size.x, max_size.y / texture_size.y)
	pic.scale = Vector2(icon_scale, icon_scale)


func _on_monster_hover_entered() -> void:
	_show_monster_attr_panel()


func _on_monster_hover_exited() -> void:
	_hover_exit_grace_frames = 2


func _process(_delta: float) -> void:
	if hover_attr_panel == null or not is_instance_valid(hover_attr_panel):
		return
	if get_global_rect().has_point(get_viewport().get_mouse_position()):
		_hover_exit_grace_frames = 2
		return
	if _hover_exit_grace_frames > 0:
		_hover_exit_grace_frames -= 1
		return
	_hide_monster_attr_panel()


func _hide_monster_attr_panel() -> void:
	if hover_attr_panel != null and is_instance_valid(hover_attr_panel):
		Global.clear_hover_popup()
	hover_attr_panel = null
	_hover_exit_grace_frames = 0


func _show_monster_attr_panel() -> void:
	_hide_monster_attr_panel()
	var parent_node = Global.get_ui_popup_layer()
	hover_attr_panel = _create_monster_attr_panel()
	_hover_exit_grace_frames = 2
	hover_attr_panel.position = Global.screen_popup_position(Vector2(18, 18))
	parent_node.add_child(hover_attr_panel)
	Global.register_hover_popup(hover_attr_panel)
	hover_attr_panel.z_index = 4096
	call_deferred("_fit_hover_panel_to_screen")


func _fit_hover_panel_to_screen() -> void:
	if hover_attr_panel == null or not is_instance_valid(hover_attr_panel):
		return
	var viewport_size = get_viewport().get_visible_rect().size
	var panel_size = hover_attr_panel.size
	if panel_size.x <= 0 or panel_size.y <= 0:
		panel_size = hover_attr_panel.get_combined_minimum_size()
	var pos = Global.screen_popup_position(Vector2(18, 18))
	if pos.x + panel_size.x > viewport_size.x - 8:
		pos.x = viewport_size.x - panel_size.x - 8
	if pos.y + panel_size.y > viewport_size.y - 8:
		pos.y = viewport_size.y - panel_size.y - 8
	if pos.x < 8:
		pos.x = 8
	if pos.y < 8:
		pos.y = 8
	hover_attr_panel.position = pos


func _create_monster_attr_panel() -> Control:
	var panel = PanelContainer.new()
	panel.name = "MonsterAttrHover"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0.78)
	style.border_color = Color(1.0, 0.65, 0.18, 0.95)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", style)

	var margin = MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	var list = VBoxContainer.new()
	list.mouse_filter = Control.MOUSE_FILTER_IGNORE
	list.add_theme_constant_override("separation", 3)
	margin.add_child(list)

	var display_name := str(monster_name_list.get(monster_name, monster_name))
	if not level_monster_config.is_empty() and str(level_monster_config.get("name", "")) != "":
		display_name = str(level_monster_config["name"])
	_add_attr_label(list, display_name, 18, "ffb347")
	if is_boss:
		_add_attr_label(list, "Boss", 14, "ff6b00")
	if monster_name == "ce":
		var rabbit_unlock_text := "击败后必定永久解锁月兔"
		if PlayerData.has_method("is_pet_rabbit_unlocked") and PlayerData.is_pet_rabbit_unlocked():
			rabbit_unlock_text += "（已解锁）"
		_add_attr_label(list, rabbit_unlock_text, 14, "ffdf7e")

	var data: Dictionary = (MonsterAttrData.DATA.get(monster_name, {}) as Dictionary).duplicate(true)
	var scene_data := _get_scene_attr_data()
	if _is_scene_attr_data_valid(scene_data):
		data = scene_data

	if monster_name == "zqj3006" and not data.has("掉落"):
		data["掉落"] = [
			{
				"name": "tjs",
				"value": 1,
				"min_value": 1,
				"max_value": 3,
				"chance": 0.1,
			}
		]
	var human_monster_id := int(HUMAN_SOUL_CRYSTAL_MONSTER_IDS.get(monster_name, 0))
	if int(MainSet.set_data.get("Difficult", 0)) == BaseMonster.NIGHTMARE_DIFFICULTY and human_monster_id > 0:
		data["掉落"] = [
			{
				"name": BaseMonster.HUMAN_SOUL_CRYSTAL_ITEM_PREFIX + str(human_monster_id),
				"value": 1,
				"min_value": 3,
				"max_value": 5,
				"chance": 0.25,
				"fixed_chance": true,
			}
		]
	elif (
		int(MainSet.set_data.get("Difficult", 0)) == BaseMonster.NIGHTMARE_DIFFICULTY
		and BaseMonster.is_underworld_nightmare_path(level_path)
	):
		data["掉落"] = []
		var underworld_monster_id := int(UNDERWORLD_SOUL_CRYSTAL_MONSTER_IDS.get(monster_name, 0))
		if underworld_monster_id > 0:
			data["掉落"] = [
				{
					"name": BaseMonster.UNDERWORLD_SOUL_CRYSTAL_ITEM_PREFIX + str(underworld_monster_id),
					"value": 1,
					"min_value": 3,
					"max_value": 5,
					"chance": 0.25,
					"fixed_chance": true,
				}
			]
	elif (
		int(MainSet.set_data.get("Difficult", 0)) == BaseMonster.NIGHTMARE_DIFFICULTY
		and BaseMonster.is_heaven_nightmare_path(level_path)
	):
		data["掉落"] = []
		var heaven_monster_id := int(HEAVEN_SOUL_CRYSTAL_MONSTER_IDS.get(monster_name, 0))
		if heaven_monster_id > 0:
			data["掉落"] = [
				{
					"name": BaseMonster.HEAVEN_SOUL_CRYSTAL_ITEM_PREFIX + str(heaven_monster_id),
					"value": 1,
					"min_value": 3,
					"max_value": 5,
					"chance": 0.25,
					"fixed_chance": true,
				}
			]
	if data.is_empty():
		_add_attr_label(list, "暂无属性数据", 14, "ffffff")
		return panel

	var diff = int(MainSet.set_data.get("Difficult", 0))
	diff = clampi(diff, 0, MonsterAttrData.DIFFICULTY_MULTIPLIERS.size() - 1)
	var mult: float = float(MonsterAttrData.DIFFICULTY_MULTIPLIERS[diff])
	var advanced_nightmare_path := (
		BaseMonster.is_underworld_nightmare_path(level_path) or BaseMonster.uses_heaven_nightmare_attributes(level_path)
	)
	var order = _monster_attr_order()
	if LocalCoop.is_enabled() and not data.has("免伤"):
		data["免伤"] = 0.0
	for key in order:
		if data.has(key):
			var value = _get_display_attr_value(key, _resolve_attr_value(data[key]), mult, diff, level_path)
			var label_name := "攻击" if key == "基础攻击" else str(key)
			var value_text := _format_attr_value(value)
			if key in ["伤害", "免伤"] and (typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT):
				value_text = _format_attr_value(snapped(float(value) * 100.0, 0.1)) + "%"
			_add_attr_label(list, label_name + "：" + value_text, 14, "ffffff")
	if diff == BaseMonster.NIGHTMARE_DIFFICULTY and not data.has("伤害"):
		var nightmare_damage_text := (
			"100%"
			if BaseMonster.uses_heaven_nightmare_attributes(level_path)
			else "60%" if advanced_nightmare_path else "30%"
		)
		_add_attr_label(list, "伤害：" + nightmare_damage_text, 14, "ffffff")
	if diff == BaseMonster.NIGHTMARE_DIFFICULTY and not data.has("免伤"):
		var nightmare_reduction_text := (
			"100%"
			if BaseMonster.uses_heaven_nightmare_attributes(level_path)
			else "60%" if advanced_nightmare_path else "30%"
		)
		_add_attr_label(list, "免伤：" + nightmare_reduction_text, 14, "ffffff")

	if data.has(DataKeys.ATTACK):
		_add_attr_label(list, "攻击伤害：", 14, "ffdf7e")
		for attack in data[DataKeys.ATTACK]:
			if not attack.has("power"):
				continue
			var attack_mult: float = 1.0 if bool(attack.get("difficulty_scaled", false)) else mult
			var power = _get_display_attr_value(
				"攻击", _resolve_attr_value(attack["power"]), attack_mult, diff, level_path
			)
			var kind = ""
			if attack.has("kind") and str(attack["kind"]) != "":
				kind = " / " + str(attack["kind"])
			_add_attr_label(
				list, "  " + str(attack.get("name", "hit")) + "：" + _format_attr_value(power) + kind, 14, "ffffff"
			)
	if not bool(get_meta("hide_independent_drops", false)) and data.has("掉落"):
		_add_attr_label(list, "独立掉落：", 14, "ffdf7e")
		for drop in data["掉落"]:
			if not drop is Dictionary:
				continue
			var item_id := str(drop.get("name", ""))
			if item_id == "":
				continue
			var item_name := item_id
			if AE.all_equipment.has(item_id):
				item_name = str(AE.all_equipment[item_id].get(DataKeys.NAME, item_id))
			var chance := _get_drop_chance_text(
				float(drop.get("chance", 0.0)), diff, bool(drop.get("fixed_chance", false))
			)
			var minimum_value := int(drop.get("min_value", drop.get("value", 1)))
			var maximum_value := int(drop.get("max_value", minimum_value))
			var value_text := str(minimum_value)
			if maximum_value != minimum_value:
				value_text += "-" + str(maximum_value)
			var destination := ""
			if bool(drop.get("direct_to_pet_backpack", false)):
				destination = "（宠物背包）"
			_add_attr_label(list, "  " + item_name + " ×" + value_text + destination + "：" + chance, 14, "ffffff")
	return panel


func _monster_attr_order() -> Array:
	return [
		"等级",
		"生命",
		"基础攻击",
		"攻击间隔",
		"物防",
		"魔防",
		"暴击",
		"闪避",
		"魔抗",
		"命中",
		"幸运",
		"物穿",
		"魔穿",
		"暴击减免",
		"回血",
		"速度",
		"视野",
		"攻击范围",
		"攻击欲望",
		"伤害",
		"免伤"
	]


func _get_scene_attr_data() -> Dictionary:
	if monster_scene_path == "":
		return _get_level_config_attr_data()
	if not ResourceLoader.exists(monster_scene_path):
		return {}
	var packed := load(monster_scene_path) as PackedScene
	if packed == null:
		return {}
	var monster := packed.instantiate()
	if monster == null:
		return {}
	var skip_runtime_configuration := false
	if _has_object_property(monster, "_runtime_config"):
		if not level_monster_config.is_empty() and level_monster_config.has("name"):
			monster.set("_runtime_config", level_monster_config.duplicate(true))
		else:
			skip_runtime_configuration = true
		var runtime_config: Variant = monster.get("_runtime_config")
		skip_runtime_configuration = (
			skip_runtime_configuration or (runtime_config is Dictionary and (runtime_config as Dictionary).is_empty())
		)

	if monster_name == "ce" and monster.has_method("_configure_stats"):
		monster.call("_configure_stats")
	if monster.has_method("set_data"):
		monster.call("set_data")
	if not skip_runtime_configuration and monster.has_method("_configure_boss"):
		monster.call("_configure_boss")
	if monster.has_method("_configure_qingyang"):
		monster.call("_configure_qingyang")
	if monster.has_method("_configure_sword_boss"):
		monster.call("_configure_sword_boss")
	if monster.has_method("_apply_sword_boss_stats"):
		monster.call("_apply_sword_boss_stats")
	if (
		not skip_runtime_configuration
		and not monster.has_meta("tower_config")
		and monster.has_method("_configure_monster")
	):
		monster.call("_configure_monster")

	var attacks_include_difficulty := false
	if monster.has_method("monster_info_attack_values_include_difficulty"):
		attacks_include_difficulty = bool(monster.call("monster_info_attack_values_include_difficulty"))

	var keys := [
		"等级",
		"生命",
		"攻击间隔",
		"物防",
		"魔防",
		"暴击",
		"闪避",
		"魔抗",
		"命中",
		"幸运",
		"物穿",
		"魔穿",
		"暴击减免",
		"回血",
		"速度",
		"视野",
		"攻击范围",
		"攻击欲望"
	]
	var base_health: int = int(_read_monster_value(monster, "max_hp", 0))
	if monster.has_method("get_health_without_coop"):
		base_health = int(monster.call("get_health_without_coop"))
	var data := {
		keys[0]: _read_monster_value(monster, "level", 0),
		keys[1]: base_health,
		keys[2]: _read_monster_value(monster, "attack_in", 0),
		keys[3]: _read_monster_value(monster, "def", 0),
		keys[4]: _read_monster_value(monster, "mdef", 0),
		keys[5]: _read_monster_value(monster, "crit", 0),
		keys[6]: _read_monster_value(monster, "miss", 0),
		keys[7]: _read_monster_value(monster, "ebol", 0),
		keys[8]: _read_monster_value(monster, "htarget", 0),
		keys[9]: _read_monster_value(monster, "lucky", 0),
		keys[10]: _read_monster_value(monster, "ar", 0),
		keys[11]: _read_monster_value(monster, "sp", 0),
		keys[12]: _read_monster_value(monster, "crit_reduce", 0),
		keys[13]: _read_monster_value(monster, "self_rhp", 0),
		keys[14]: _read_monster_value(monster, "speed", 0),
		keys[15]: _read_monster_value(monster, "mysee", 0),
		keys[16]: _read_monster_value(monster, "attack_range", _read_monster_value(monster, "attackRange", 0)),
		keys[17]: _read_monster_value(monster, "attack_desire", 0),
	}
	if level_monster_config.has("damage_bonus"):
		data["伤害"] = _read_monster_value(monster, "damage_bonus", 0.0)
	if level_monster_config.has("damage_reduction"):
		data["免伤"] = _read_monster_value(monster, "damage_reduction", 0.0)
		if LocalCoop.is_enabled():
			data["免伤"] -= 0.25
	if monster.has_method("monster_info_base_attack"):
		data.erase("攻击间隔")
		data["基础攻击"] = monster.call("monster_info_base_attack")
	var attacks: Array = []
	var attack_dic = _read_monster_value(monster, "obj_attack_dict", {})
	if attack_dic is Dictionary:
		for attack_name in attack_dic.keys():
			var attack = attack_dic[attack_name]
			if attack is Dictionary and attack.has("power"):
				(
					attacks
					. append(
						{
							"name": str(attack_name),
							"power": attack["power"],
							"kind": str(attack.get("attackKind", "")),
							"difficulty_scaled": attacks_include_difficulty,
						}
					)
				)
	if not attacks.is_empty():
		data[DataKeys.ATTACK] = attacks
	var drops: Array = []
	var independent_drops = _read_monster_value(monster, "independent_fall_list", [])
	if (
		(not independent_drops is Array or independent_drops.is_empty())
		and level_monster_config.has("independent_drop_list")
	):
		independent_drops = level_monster_config.get("independent_drop_list", [])
	if independent_drops is Array:
		for drop in independent_drops:
			if drop is Dictionary and str(drop.get("name", "")) != "":
				var minimum_value := int(drop.get("min_value", drop.get("value", 1)))
				var maximum_value := int(drop.get("max_value", minimum_value))
				(
					drops
					. append(
						{
							"name": str(drop.get("name", "")),
							"value": minimum_value,
							"min_value": minimum_value,
							"max_value": maximum_value,
							"chance": float(drop.get("chance", 0.0)),
							"direct_to_pet_backpack": bool(drop.get("direct_to_pet_backpack", false)),
						}
					)
				)
	if not drops.is_empty():
		data["掉落"] = drops
	monster.free()
	return data


func _get_level_config_attr_data() -> Dictionary:
	if level_monster_config.is_empty():
		return {}
	var config_keys := {
		"等级": "level",
		"生命": "hp",
		"基础攻击": "attack",
		"物防": "def",
		"魔防": "mdef",
		"暴击": "crit",
		"闪避": "miss",
		"命中": "hit",
		"物穿": "armor_break",
		"魔穿": "magic_break",
		"暴击减免": "crit_reduce",
		"速度": "speed",
		"视野": "sight",
		"攻击范围": "range",
		"攻击欲望": "attack_desire",
		"伤害": "damage_bonus",
		"免伤": "damage_reduction",
	}
	var data := {}
	for label_name: String in config_keys:
		var config_name: String = config_keys[label_name]
		if level_monster_config.has(config_name):
			data[label_name] = level_monster_config[config_name]

	var attacks: Array = []
	var attack_config: Variant = level_monster_config.get("attacks", {})
	if attack_config is Dictionary:
		for attack_name: String in attack_config:
			var attack: Variant = attack_config[attack_name]
			if attack is Dictionary and attack.has("power"):
				(
					attacks
					. append(
						{
							"name": attack_name,
							"power": attack["power"],
							"kind": str(attack.get("kind", "")),
							"difficulty_scaled": false,
						}
					)
				)
	if not attacks.is_empty():
		data[DataKeys.ATTACK] = attacks

	var drops: Array = []
	for drop_group_value in [
		level_monster_config.get("drop_list", []),
		level_monster_config.get("independent_drop_list", []),
	]:
		if not drop_group_value is Array:
			continue
		for drop: Variant in drop_group_value:
			if not drop is Dictionary or str(drop.get("name", "")) == "":
				continue
			var minimum_value := int(drop.get("min_value", drop.get("value", 1)))
			(
				drops
				. append(
					{
						"name": str(drop.get("name", "")),
						"value": minimum_value,
						"min_value": minimum_value,
						"max_value": int(drop.get("max_value", minimum_value)),
						"chance": float(drop.get("chance", float(level_monster_config.get("drop_rate", 0.0)) / 100.0)),
						"direct_to_pet_backpack": bool(drop.get("direct_to_pet_backpack", false)),
					}
				)
			)
	if not drops.is_empty():
		data["掉落"] = drops
	return data


func _is_scene_attr_data_valid(data: Dictionary) -> bool:
	if data.is_empty():
		return false
	return float(data.get(DataKeys.HP, 0)) > 0.0 or int(data.get(DataKeys.LEVEL, 0)) > 0


func _read_monster_value(monster: Object, property_name: String, fallback):
	var value = monster.get(property_name)
	if value == null:
		return fallback
	return value


func _has_object_property(object: Object, property_name: String) -> bool:
	for property: Dictionary in object.get_property_list():
		if str(property.get("name", "")) == property_name:
			return true
	return false


func _resolve_attr_value(value):
	if typeof(value) != TYPE_STRING:
		return value
	var expr = str(value)

	match expr:
		"78 if not is_phantom else 82":
			return 78
		"int(2700 * phantom_multiplier)":
			return 2700
		"int(5000 * phantom_multiplier)":
			return 5000
		"int(1950000 * hp_multiplier)":
			return 1950000
		"int(2100000 * hp_multiplier)":
			return 2100000
		"int(350 * bl)":
			return 350
		"hd":
			return "技能变量"
	if expr == "200 * poweradd":
		return 200
	if expr == "6000 + Stage * 3000":
		return "随层数变化"
	if expr == "150 + Stage * 45":
		return "随层数变化"
	if expr == "19000 + BeHitCount * 8000":
		return "随受击次数变化"
	if expr in ["128 + BeHitCount * 25", "333 + BeHitCount * 20"]:
		return "随受击次数变化"
	if expr.find("Global.llbt_level") >= 0:
		return _resolve_llbt_value(expr)
	if expr.find("RoleProp.roleprop.SHp") >= 0:
		return _resolve_role_number_expr(expr, float(RoleProp.roleprop.SHp), "RoleProp.roleprop.SHp")
	if expr.find("RoleProp.roleprop.power") >= 0:
		return _resolve_role_number_expr(expr, float(RoleProp.roleprop.power), "RoleProp.roleprop.power")
	if expr.find("RoleProp.baseroleprop.Level") >= 0:
		return _resolve_role_number_expr(expr, float(RoleProp.baseroleprop.Level), "RoleProp.baseroleprop.Level")
	return "动态数值"


func _resolve_llbt_value(expr: String):
	var level = float(Global.llbt_level)
	if expr == "8000 + Global.llbt_level * 350":
		return int(8000 + level * 350)
	if expr == "7000 + Global.llbt_level * 400":
		return int(7000 + level * 400)
	if expr == "9000 + Global.llbt_level * 500":
		return int(9000 + level * 500)
	if expr == "270 + Global.llbt_level * 10":
		return int(270 + level * 10)
	if expr == "350 + Global.llbt_level * 5":
		return int(350 + level * 5)
	if expr == "330 + Global.llbt_level * 6":
		return int(330 + level * 6)
	return "随玲珑宝塔层数变化"


func _resolve_role_number_expr(expr: String, role_value: float, token: String):
	var e = expr.replace("int(", "").replace(")", "")
	e = e.replace(token, "X")
	var parts = e.split("+")
	var total = 0.0
	for raw_part in parts:
		var part = str(raw_part).strip_edges()
		if part == "":
			continue
		if part.find("X") >= 0:
			var mult = 1.0
			var sub = part.split("*")
			if sub.size() == 2:
				if str(sub[0]).strip_edges() == "X":
					mult = float(str(sub[1]).strip_edges())
				else:
					mult = float(str(sub[0]).strip_edges())
			total += role_value * mult
		else:
			total += float(part)
	return int(total)


func _get_display_attr_value(key: String, value, mult: float, difficulty: int, level_path: String = ""):
	var result = _get_difficulty_value(key, value, mult, difficulty, level_path)
	if not LocalCoop.is_enabled() or (typeof(result) != TYPE_INT and typeof(result) != TYPE_FLOAT):
		return result
	match key:
		"生命":
			return int(result) * 2
		"基础攻击", "攻击":
			return int(int(result) * 1.3)
		"免伤":
			return float(result) + 0.25
	return result


func _get_difficulty_value(key: String, value, mult: float, difficulty: int, level_path: String = ""):
	if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
		return value
	if difficulty == 3:
		var underworld_nightmare := BaseMonster.is_underworld_nightmare_path(level_path)
		var heaven_nightmare := BaseMonster.uses_heaven_nightmare_attributes(level_path)
		var health_bonus := (
			BaseMonster.HEAVEN_NIGHTMARE_HEALTH_BONUS
			if heaven_nightmare
			else (
				BaseMonster.UNDERWORLD_NIGHTMARE_HEALTH_BONUS
				if underworld_nightmare
				else BaseMonster.NIGHTMARE_HEALTH_BONUS
			)
		)
		var attack_bonus := (
			BaseMonster.HEAVEN_NIGHTMARE_ATTACK_BONUS
			if heaven_nightmare
			else (
				BaseMonster.UNDERWORLD_NIGHTMARE_ATTACK_BONUS
				if underworld_nightmare
				else BaseMonster.NIGHTMARE_ATTACK_BONUS
			)
		)
		var defense_bonus := (
			BaseMonster.HEAVEN_NIGHTMARE_DEFENSE_BONUS
			if heaven_nightmare
			else (
				BaseMonster.UNDERWORLD_NIGHTMARE_DEFENSE_BONUS
				if underworld_nightmare
				else BaseMonster.NIGHTMARE_DEFENSE_BONUS
			)
		)
		var penetration_bonus := BaseMonster.HEAVEN_NIGHTMARE_PENETRATION_BONUS if heaven_nightmare else defense_bonus
		match key:
			"等级":
				return value + BaseMonster.NIGHTMARE_LEVEL_BONUS
			"生命":
				return value * mult + health_bonus
			"基础攻击", "攻击":
				return value * mult + attack_bonus
			"物防", "魔防", "物穿", "魔穿":
				return value * mult + (penetration_bonus if key in ["物穿", "魔穿"] else defense_bonus)
			"命中":
				return value * mult + BaseMonster.NIGHTMARE_HIT_BONUS
			"闪避":
				return value * mult
			"暴击", "幸运", "魔抗", "暴击减免", "回血":
				return value * mult
			"伤害":
				return (
					BaseMonster.HEAVEN_NIGHTMARE_DAMAGE_BONUS
					if heaven_nightmare
					else (
						BaseMonster.UNDERWORLD_NIGHTMARE_DAMAGE_BONUS
						if underworld_nightmare
						else BaseMonster.NIGHTMARE_DAMAGE_BONUS
					)
				)
			"免伤":
				return (
					BaseMonster.HEAVEN_NIGHTMARE_DAMAGE_REDUCTION
					if heaven_nightmare
					else (
						BaseMonster.UNDERWORLD_NIGHTMARE_DAMAGE_REDUCTION
						if underworld_nightmare
						else BaseMonster.NIGHTMARE_DAMAGE_REDUCTION
					)
				)
	if key in ["生命", "基础攻击", "攻击"]:
		return value * mult
	return value


func _get_drop_chance_text(base_chance: float, difficulty_index: int, fixed_chance := false) -> String:
	var multipliers := [1.0, 2.0, 3.0, 3.0]
	var chance: float = (
		base_chance
		if fixed_chance
		else base_chance * float(multipliers[clampi(difficulty_index, 0, multipliers.size() - 1)])
	)
	chance = clampf(chance, 0.0, 1.0)
	if RoleProp.source_player != null and RoleProp.source_player.is_double_fall_pro:
		chance = clampf(chance * 2.0, 0.0, 1.0)
	return str(snapped(chance * 100.0, 0.1)) + "%"


func _format_attr_value(value) -> String:
	if typeof(value) == TYPE_FLOAT:
		if abs(value - round(value)) < 0.001:
			return str(int(round(value)))
		return str(snapped(value, 0.001))
	return str(value)


func _add_attr_label(parent: Node, text_: String, _size: int, color_: String) -> void:
	var label = Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = text_
	label.add_theme_font_size_override("font_size", _size)
	label.add_theme_color_override("font_color", Color(color_))
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 4)
	parent.add_child(label)
