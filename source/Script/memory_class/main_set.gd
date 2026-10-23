extends Node

const FRAME_RATE_OPTIONS := [30, 60, 90, 120, 150]
const DEFAULT_FRAME_RATE := 150
const DEFAULT_MOBILE_FRAME_RATE := 60
# 主菜单背景按主线进度解锁：索引 1 为默认背景，2~6 对应 CurrentLevelPage 阈值。
const MAIN_MENU_BACKGROUND_UNLOCK_PAGES := [1, 2, 3, 4, 5, 6]


func get_default_frame_rate() -> int:
	return DEFAULT_MOBILE_FRAME_RATE if OS.has_feature("mobile") else DEFAULT_FRAME_RATE


var auto_battle_enabled_runtime: bool = false

var set_data: Dictionary = {
	"music": 1,
	"time1": "",
	"time2": "",
	"time3": "",
	"time4": "",
	"time5": "",
	"time6": "",
	"name1": "",
	"name2": "",
	"name3": "",
	"name4": "",
	"name5": "",
	"name6": "",
	"其他存档": {},
	"剧情跳过": false,
	"Map_num": 1,
	"MainMenuBG": 1,
	"BackGroundMusic": true,
	"RoleOrMonsterHit": true,
	"MonsterBloodSHow": true,
	"MonsterBloodTextSHow": false,
	"MonsterLittleBlood": true,
	"ShowDamageText": true,
	"MusicFB": 0,
	"MusicFB_2": 0,
	"NoShowMonsterBody": true,
	"HpBarDelay": false,
	"FristGame": true,
	"automatically_pick_up_items": false,
	"PickUpItemsMusic": false,
	"CurrentLevelPage": 0,
	"CreateMonsterSpeed": 1.2,
	"CreateMonsterCount": 1,
	"Difficult": 0,
	"镇妖塔自动下一层": false,
	"LevelInfo": true,
	"AutoBattleEnabled": false,
	"AutoBattleSkills": [],
	"AutoBattleSkillsByRole": {},
	"AutoBattleSkillsBySlot": {},
	"AutoBattlePlayerSlot": 1,
	"AutoBattleWushuang": false,
	"AutoBattleRetry": false,
	"AutoBattleSkillOnly": false,
	"AutoBattleMagicWeapon": false,
	"AutoBattleSwordArray": false,
	"xg": false,
	"Music4": false,
	"LevelHYS": true,
	"LevelLSH": false,
	"LevelTT": true,
	"MyTime": {},
	"FileValue": 1.0,
	"XiaoBaiLong": true,
	"NotShowRoleBody": false,
	"NotShowRoleEQ": false,
	"CdNum": 6,
	"FrameRate": get_default_frame_rate(),
}


func is_auto_battle_enabled() -> bool:
	return auto_battle_enabled_runtime


func set_auto_battle_enabled(enabled: bool) -> void:
	auto_battle_enabled_runtime = enabled


func get_frame_rate() -> int:
	var frame_rate := int(set_data.get("FrameRate", get_default_frame_rate()))
	if frame_rate not in FRAME_RATE_OPTIONS:
		frame_rate = get_default_frame_rate()
		set_data["FrameRate"] = frame_rate
	return frame_rate


func apply_frame_rate() -> void:
	Engine.max_fps = get_frame_rate()


func get_main_menu_background_unlock_page(index: int) -> int:
	var normalized_index := clampi(index, 1, MAIN_MENU_BACKGROUND_UNLOCK_PAGES.size())
	return int(MAIN_MENU_BACKGROUND_UNLOCK_PAGES[normalized_index - 1])


func is_main_menu_background_unlocked(index: int) -> bool:
	if index <= 1:
		return true
	return int(set_data.get("CurrentLevelPage", 0)) >= get_main_menu_background_unlock_page(index)


func get_max_unlocked_main_menu_background() -> int:
	var current_page := int(set_data.get("CurrentLevelPage", 0))
	var max_unlocked := 1
	for index in range(2, MAIN_MENU_BACKGROUND_UNLOCK_PAGES.size() + 1):
		if current_page >= int(MAIN_MENU_BACKGROUND_UNLOCK_PAGES[index - 1]):
			max_unlocked = index
	return max_unlocked


func normalize_main_menu_background(index: int) -> int:
	var normalized_index := clampi(index, 1, MAIN_MENU_BACKGROUND_UNLOCK_PAGES.size())
	return mini(normalized_index, get_max_unlocked_main_menu_background())
