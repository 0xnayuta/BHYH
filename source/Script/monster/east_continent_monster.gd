extends BaseMonster
class_name EastContinentMonster

const SOURCE_FPS := 30.0
const FRAME_ROOT := "res://Art/monster/swf_png"
const PROJECTILE_SCRIPT := preload("res://Script/monster/wutai_minghai_projectile.gd")
const RAIN_ANCESTOR_WEATHER_SCRIPT := preload("res://Script/monster/rain_ancestor_weather.gd")
const RANGED_EFFECT_ROOT := "res://Art/monster/game_4_special_effect/effect_3177/effect2_1"
const MONKEY_EFFECT2_ROOT := "res://Art/monster/game_4_special_effect/effect_3161/effect2_1"
const MONKEY_EFFECT3_1_ROOT := "res://Art/monster/game_4_special_effect/effect_3161/effect3_1"
const MONKEY_EFFECT3_2_ROOT := "res://Art/monster/game_4_special_effect/effect_3161/effect3_2"
const SIX_EAR_DASH_ROOT := "res://Art/monster/game_4_special_effect/effect_3179/effect5_1"
const SIX_EAR_IMPACT_ROOT := "res://Art/monster/game_4_special_effect/effect_3179/effect51"
const SAND_BOSS_WIND_ROOT := "res://Art/monster/game_4_special_effect/effect_3120/effect1_1"
const SAND_BOSS_STONE_ROOT := "res://Art/monster/game_4_special_effect/effect_3120/effect2_3"
const SAND_BOSS_DUST_ROOT := "res://Art/monster/game_4_special_effect/effect_3120/effect2_4"
const SAND_BOSS_ACTION_ROOTS := {
	&"hit1": "res://Art/monster/game_4_special_effect/effect_3120/effect1",
	&"hit2": "res://Art/monster/game_4_special_effect/effect_3120/effect2",
}
const SAND_BOSS_ACTION_COUNTS := {&"hit1": 47, &"hit2": 31}

const SAND_BOSS_ACTION_VISUAL_OFFSETS := {
	&"hit1": Vector2(0.0, -32.0),
	&"hit2": Vector2(0.0, -16.0),
}
const FLOWER_ARROW_ROOT := "res://Art/monster/game_4_special_effect/effect_3121/arrow1"
const AOLAIGUO_BOSS_METADATA := "res://Art/monster/swf_png/3136/atlas/metadata.tres"
const RAIN_ANCESTOR_METADATA := "res://Art/monster/swf_png/3182/atlas/metadata.tres"
const AOLAIGUO_BOSS_FRAMES := "res://Art/monster/swf_png/3136/atlas/swf_png_3136_frames.tres"
const RAIN_ANCESTOR_FRAMES := "res://Art/monster/swf_png/3182/atlas/swf_png_3182_frames.tres"
const SMALL_HURT_DURATION := 0.28
const CORPSE_LIFETIME := 0.9

const MONKEY_ACTION_ROOTS := {
	&"hit1": "res://Art/monster/game_4_special_effect/effect_3161/effect1",
	&"hit2": "res://Art/monster/game_4_special_effect/effect_3161/effect2",
	&"hit3": "res://Art/monster/game_4_special_effect/effect_3161/effect3",
	&"hit4": "res://Art/monster/game_4_special_effect/effect_3161/effect4",
}
const MONKEY_ACTION_COUNTS := {&"hit1": 49, &"hit2": 22, &"hit3": 100, &"hit4": 19}

const SOURCE_VISUAL_OFFSETS := {
	3159:
	{
		&"wait": Vector2(1.375, -46.45),
		&"walk": Vector2(4.875, -46.7),
		&"hurt": Vector2(-0.975, -46.6),
		&"death": Vector2(-28.5, -27.725),
		&"hit1": Vector2(35.05, -48.675),
	},
	3160:
	{
		&"wait": Vector2(1.325, -53.0),
		&"walk": Vector2(1.825, -53.5),
		&"hurt": Vector2(-13.8, -52.85),
		&"death": Vector2(-14.55, -52.85),
		&"hit1": Vector2(113.5, -54.5),
	},
	3161:
	{
		&"wait": Vector2(-14.7, -56.15),
		&"walk": Vector2(-19.25, -60.8),
		&"hurt": Vector2(-36.7, -62.625),
		&"death": Vector2(-41.2, -32.625),
		&"hit1": Vector2(45.95, -56.275),
		&"hit2": Vector2(20.6, -58.475),
		&"hit3": Vector2(5.5, -54.55),
		&"hit4": Vector2(5.975, -64.9),
	},
	3177:
	{
		&"wait": Vector2(12.975, -42.5),
		&"walk": Vector2(8.475, -43.3),
		&"hurt": Vector2(-5.625, -51.85),
		&"death": Vector2(-23.8, -20.45),
		&"hit1": Vector2(12.0, -61.0),
		&"hit2": Vector2(-38.775, -71.775),
	},
	3179:
	{
		&"wait": Vector2(0.7, -71.95),
		&"walk": Vector2(1.1, -73.65),
		&"hurt": Vector2(-4.525, -74.95),
		&"death": Vector2(-26.075, -58.125),
		&"hit1": Vector2(32.625, -85.55),
		&"hit2": Vector2(6.95, -59.55),
		&"hit3": Vector2(21.875, -53.55),
		&"hit4": Vector2(3.025, -67.45),
		&"hit5": Vector2(87.875, -105.275),
	},
}

const OFFICIAL_SKILL_SCOPE := {
	3161:
	{
		&"hit1": [0.0, 150.0],
		&"hit2": [0.0, 800.0],
		&"hit3": [0.0, 600.0],
		&"hit4": [0.0, 230.0],
	},
	3179:
	{
		&"hit1": [0.0, 120.0],
		&"hit2": [0.0, 475.0],
		&"hit3": [-170.0, 170.0],
		&"hit5": [0.0, 295.0],
	},
	3119: {&"hit1": [15.0, 145.0, 0.0, 85.0]},
	3126: {&"hit1": [15.0, 145.0, 0.0, 85.0]},
	3120:
	{
		&"hit1": [0.0, 400.0, 0.0, 0.0],
		&"hit2": [0.0, 800.0, 0.0, 0.0],
	},
	3198: {&"hit1": [0.0, 45.0, 0.0, 45.0]},
	3199: {&"hit1": [10.0, 170.0]},
	3200:
	{
		&"hit1": [0.0, 125.0, 0.0, 80.0],
		&"hit2": [0.0, 330.0, 50.0, 195.0],
		&"hit3": [0.0, 900.0, -200.0, 200.0],
	},
	3201: {&"hit1": [0.0, 45.0, 0.0, 50.0], &"hit2": [0.0, 110.0, 0.0, 70.0]},
	3222: {&"hit1": [0.0, 400.0]},
	3223: {&"hit1": [0.0, 170.0], &"hit2": [-999.0, 999.0], &"hit3": [-999.0, 999.0]},
	3224: {&"hit1": [0.0, 600.0], &"hit2": [-50.0, 50.0], &"hit3": [-220.0, 220.0]},
	3225: {&"hit1": [0.0, 350.0, 20.0, 50.0], &"hit2": [0.0, 65.0, 20.0, 50.0]},
	3276: {&"hit1": [0.0, 90.0]},
	3277:
	{
		&"hit1": [0.0, 230.0, -6000.0, 6000.0],
		&"hit2": [-999.0, 999.0, -2000.0, 2000.0],
		&"hit3": [-999.0, 999.0, -2000.0, 2000.0],
	},
	3308: {&"hit1": [0.0, 110.0], &"hit2": [0.0, 145.0]},
	3309: {&"hit1": [0.0, 75.0, 0.0, 150.0]},
	3310: {&"hit1": [0.0, 900.0], &"hit2": [0.0, 600.0], &"hit3": [0.0, 700.0]},
	3320: {&"hit1": [0.0, 140.0]},
	3323:
	{
		&"hit1": [0.0, 150.0, -125.0, 20.0],
		&"hit2": [0.0, 600.0, -150.0, 20.0],
		&"hit3": [0.0, 900.0, -600.0, 600.0],
	},
	3343:
	{
		&"hit1": [0.0, 160.0, -100.0, -20.0],
		&"hit2": [0.0, 900.0, -300.0, 300.0],
		&"hit3": [-85.0, 455.0, -300.0, 300.0],
	},
	3352:
	{
		&"hit1": [0.0, 900.0, -600.0, 600.0],
		&"hit2": [0.0, 900.0, -600.0, 600.0],
		&"hit3": [0.0, 900.0, -600.0, 600.0],
	},
}

const ENTITY_COLLISION_BOXES := {
	3223:
	{
		"hurt_position": Vector2(-5.0, -74.5),
		"hurt_size": Vector2(86.0, 145.0),
		"body_position": Vector2(-5.0, -70.0),
		"body_size": Vector2(76.0, 138.0),
	},
	3277:
	{
		"hurt_position": Vector2(-19.0, -224.0),
		"hurt_size": Vector2(390.0, 430.0),
		"body_position": Vector2(-19.0, -250.0),
		"body_size": Vector2(350.0, 500.0),
	},
}

const LATE_SKILL_EFFECTS := {
	"3222:hit1":
	{"sequence": "attack1_1", "shot_frame": 24, "speed": 300.0, "lifetime": 1.334, "offset": Vector2(42.0, -36.0)},
	"3224:hit1":
	{
		"sequence": "effect1_1",
		"shot_frame": 1,
		"speed": 360.0,
		"lifetime": 2.0,
		"max_hits": 6,
		"damage_pulse_interval": 0.334,
		"poll_overlaps_on_damage_pulse": true,
		"expire_on_hit": false
	},
	"3309:hit1":
	{
		"sequence": "attack1_1",
		"shot_frame": 7,
		"speed": 468.0,
		"lifetime": 0.467,
		"targeted": true,
		"orient_to_motion": true,
		"track_target": false,
		"repeats": 4,
		"repeat_delay": 0.1,
		"aim_angle_offsets": [-28.0, -10.0, 11.0, 29.0]
	},
	"3200:hit3":
	{
		"sequence": "effect3_1",
		"impact": "effect3_2",
		"shot_frame": 16,
		"speed": 360.0,
		"lifetime": 2.5,
		"targeted": true,
		"track_target": true,
		"orient_to_motion": true,
		"offset": Vector2(60.0, -20.0)
	},
	"3277:hit2":
	{
		"sequence": "effect2_1",
		"shot_frame": 20,
		"speed": 600.0,
		"lifetime": 1.2,
		"spawn_above_target": 600.0,
		"repeats": 6,
		"repeat_delay": 0.16,
		"spread": 150.0
	},
	"3310:hit1":
	{"sequence": "effect1_1", "shot_frame": 14, "speed": 540.0, "lifetime": 2.0, "offset": Vector2(57.0, -48.0)},
	"3310:hit2":
	{"sequence": "effect2_1", "shot_frame": 14, "speed": 360.0, "lifetime": 1.7, "offset": Vector2(61.0, -57.0)},
	"3310:hit3":
	{
		"sequence": "effect3_1",
		"impact": "effect3_2",
		"shot_frame": 15,
		"speed": 420.0,
		"lifetime": 1.2,
		"fox_rain": true,
		"spread": 50.0
	},
	"3323:hit2":
	{"sequence": "effect2_1", "shot_frame": 19, "speed": 360.0, "lifetime": 1.5, "offset": Vector2(170.0, -78.0)},
	"3323:hit3":
	{
		"sequence": "effect3_1",
		"impact": "effect3_2",
		"shot_frame": 12,
		"speed": 900.0,
		"lifetime": 1.0,
		"targeted": true,
		"track_target": true,
		"orient_to_motion": true,
		"offset": Vector2(0.0, -50.0)
	},
	"3343:hit2":
	{
		"sequence": "effect2_1",
		"sequences": ["effect2_1", "effect2_2"],
		"shot_frame": 23,
		"speed": 450.0,
		"lifetime": 2.0,
		"targeted": true,
		"track_target": true,
		"orient_to_motion": true,
		"repeats": 6,
		"repeat_delay": 0.165,
		"spread": 90.0
	},
	"3343:hit3":
	{
		"sequence": "effect3_1",
		"shot_frame": 26,
		"speed": 600.0,
		"lifetime": 1.5,
		"targeted": true,
		"track_target": true,
		"orient_to_motion": true,
		"offset": Vector2(-68.0, -234.0)
	},
	"3352:hit1":
	{
		"sequence": "effect1_1",
		"shot_frame": 17,
		"speed": 900.0,
		"lifetime": 1.0,
		"targeted": true,
		"track_target": true,
		"orient_to_motion": true
	},
	"3352:hit2":
	{
		"sequence": "effect2_1",
		"follow_owner": true,
		"lifetime": 4.0,
		"target_burst_sequence": "effect2_2",
		"target_burst_frames": [20, 37],
		"target_burst_offsets": [Vector2(-200.0, 0.0), Vector2(200.0, 0.0)]
	},
	"3352:hit3":
	{
		"sequence": "effect3_1",
		"speed": 720.0,
		"lifetime": 1.5,
		"targeted": true,
		"track_target": true,
		"orient_to_motion": true,
		"offset": Vector2(143.0, 3.0),
		"repeats": 3,
		"repeat_delay": 0.891
	},
}

const OFFICIAL_LATE_MONSTER_NAMES := {
	3136: "风之祖巫",
	3144: "银甲守卫",
	3145: "花骨朵",
	3146: "毒毛虫",
	3198: "吸血蝙蝠",
	3199: "雷吼兽",
	3200: "千年蝠妖",
	3201: "召唤小蝙蝠",
	3222: "邪魅童子",
	3223: "黄眉大王",
	3224: "金铙",
	3225: "后天魔袋",
	3276: "虎妖",
	3277: "雷之祖巫",
	3308: "小狐狸",
	3309: "琉璃鸟",
	3310: "九尾天狐",
	3320: "金甲护卫",
	3323: "金翅大鹏雕",
	3343: "电之祖巫",
	3352: "通天教主(混沌版)",
}

const SAND_BOSS_WIND_SPEED := 270.0
const SAND_BOSS_WIND_LIFETIME := 0.934
const SAND_BOSS_WIND_OFFSET := Vector2(150.0, 8.0)

const SAND_BOSS_WIND_VISUAL_OFFSET := Vector2(-70.05, -79.05)
const SAND_BOSS_WIND_COLLISION_SIZE := Vector2(263.85, 198.05)
const SAND_BOSS_WIND_COLLISION_OFFSET := Vector2(-21.025, -80.975)
const SAND_BOSS_WIND_FRAME := 12
const SAND_BOSS_WIND_MAX_HITS := 5
const SAND_BOSS_WIND_HIT_INTERVAL := 0.167
const SAND_BOSS_STONE_FRAME := 18
const SAND_BOSS_STONE_SPEED_Y := -495.0
const SAND_BOSS_STONE_GRAVITY := 1200.0
const SAND_BOSS_STONE_LIFETIME := 1.0
const SAND_BOSS_DUST_COUNT := 9
const SAND_BOSS_PROTECT_DELAY := 0.5
const SAND_BOSS_PROTECT_REAPPEAR_DELAY := 0.231
const RAIN_ANCESTOR_PHASE_HP_RATIO := 0.66
const RAIN_ANCESTOR_PHASE_COOLDOWN_MSEC := 18000
const RAIN_ANCESTOR_SKILL_COOLDOWNS := {
	&"hit1": 6000,
	&"hit2": 9000,
	&"hit3": 9000,
}
const RAIN_ANCESTOR_BONE_POINTS: Array[Vector2] = [
	Vector2(23.0, -390.0),
	Vector2(-41.0, -345.0),
	Vector2(-113.0, -300.0),
	Vector2(-185.0, -251.0),
]
static var _loose_geometry_cache: Dictionary = {}

const FOOT_OFFSETS := {
	3159: -50.0,
	3160: -57.0,
	3161: -65.0,
	3172: -50.0,
	3177: -47.0,
	3179: -77.0,
	3181: -44.0,
	3182: -260.5,
	3118: -50.0,
	3119: -50.0,
	3120: -55.0,
	3121: -50.0,
	3122: -28.5,
	3123: -30.5,
	3125: -70.5,
	3126: -50.0,
	3136: -271.0,
	3144: -50.0,
	3145: -50.0,
	3146: -50.0,
}

@export var monster_kind: int = 3159

const DATA := {
	3159:
	{
		"name": "猴妖",
		"hp": 4500000,
		"attack": 24000,
		"def": 1050,
		"mdef": 1050,
		"speed": 12.0,
		"range": 140,
		"sight": 820,
		"is_boss": false,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false]
		}
	},
	3160:
	{
		"name": "银杏精",
		"hp": 4500000,
		"attack": 24000,
		"def": 1050,
		"mdef": 1050,
		"speed": 12.0,
		"range": 160,
		"sight": 820,
		"is_boss": false,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false]
		}
	},
	3161:
	{
		"name": "通臂白猿",
		"hp": 22000000,
		"attack": 35000,
		"def": 5200,
		"mdef": 5200,
		"speed": 10.0,
		"range": 180,
		"sight": 1200,
		"is_boss": true,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"attacks":
		{
			"hit1": {"multiplier": 0.25, "source_target_move": [21, 42]},
			"hit2": {"multiplier": 0.5, "source_target_move": [32, 42]},
			"hit3": {"multiplier": 1.5, "source_target_move": [400, 66]},
			"hit4": {"multiplier": 0.1, "source_target_move": [66, 200]}
		},
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false],
			&"hit2": ["hit2", false],
			&"hit3": ["hit3", false],
			&"hit4": ["hit4", false]
		}
	},
	3172:
	{
		"name": "法杖教徒",
		"hp": 4500000,
		"attack": 24000,
		"def": 1050,
		"mdef": 1050,
		"speed": 12.0,
		"range": 180,
		"sight": 820,
		"is_boss": false,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false]
		}
	},
	3177:
	{
		"name": "蘑菇长老",
		"hp": 4500000,
		"attack": 24000,
		"def": 1050,
		"mdef": 1050,
		"speed": 12.0,
		"range": 520,
		"sight": 820,
		"is_boss": false,
		"attack_animation": &"hit2",
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false],
			&"hit2": ["hit2", false]
		}
	},
	3179:
	{
		"name": "六耳猕猴",
		"hp": 22000000,
		"attack": 35000,
		"def": 5200,
		"mdef": 5200,
		"speed": 10.0,
		"range": 180,
		"sight": 1200,
		"is_boss": true,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"attacks":
		{
			"hit1": {"multiplier": 0.375, "source_target_move": [12, 42]},
			"hit2": {"multiplier": 0.5, "source_target_move": [21, 42]},
			"hit3": {"multiplier": 0.34, "source_target_move": [21, 42]},
			"hit4": {"multiplier": 0.0},
			"hit5": {"multiplier": 0.0}
		},
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false],
			&"hit2": ["hit2", false],
			&"hit3": ["hit3", false],
			&"hit4": ["hit4", false],
			&"hit5": ["hit5", false]
		}
	},
	3181:
	{
		"name": "骨刺兽",
		"hp": 4500000,
		"attack": 24000,
		"def": 1050,
		"mdef": 1050,
		"speed": 12.0,
		"range": 150,
		"sight": 820,
		"is_boss": false,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false],
			&"hit2": ["hit2", false]
		}
	},
	3182:
	{
		"name": "雨之祖巫",
		"hp": 22000000,
		"attack": 35000,
		"def": 5200,
		"mdef": 5200,
		"speed": 0.0,
		"range": 1200,
		"sight": 1200,
		"is_boss": true,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"attacks":
		{
			"hit1": {"multiplier": 1.0, "source_target_move": [32, 42]},
			"hit2": {"multiplier": 0.75, "source_target_move": [32, 42]},
			"hit3": {"multiplier": 1.0, "source_target_move": [33, 66]},
			"hit4": {"multiplier": 0.1},
			"hit5": {"multiplier": 0.0}
		},
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false],
			&"hit2": ["hit2", false],
			&"hit3": ["hit3", false],
			&"hit4": ["hit4", false],
			&"hit5": ["hit5", false]
		}
	},
	3118:
	{
		"name": "金沙村小怪",
		"hp": 4500000,
		"attack": 24000,
		"def": 1050,
		"mdef": 1050,
		"speed": 12.0,
		"range": 140,
		"sight": 820,
		"is_boss": false,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false]
		}
	},
	3119:
	{
		"name": "金沙村飞行怪",
		"hp": 4500000,
		"attack": 24000,
		"def": 1050,
		"mdef": 1050,
		"speed": 12.0,
		"range": 140,
		"sight": 820,
		"is_boss": false,
		"is_flying": true,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"Fly_wait": ["wait", true],
			&"Fly": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false]
		}
	},
	3120:
	{
		"name": "金沙村首领",
		"hp": 23000000,
		"attack": 42000,
		"def": 5500,
		"mdef": 5500,
		"speed": 12.5,
		"range": 720,
		"sight": 1200,
		"is_boss": true,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["wait", false],
			&"hit2": ["wait", false]
		}
	},
	3121:
	{
		"name": "百仙园弓手",
		"hp": 4500000,
		"attack": 24000,
		"def": 1050,
		"mdef": 1050,
		"speed": 12.0,
		"range": 520,
		"sight": 820,
		"is_boss": false,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false]
		}
	},
	3122:
	{
		"name": "百仙园妖灵",
		"hp": 4500000,
		"attack": 24000,
		"def": 1050,
		"mdef": 1050,
		"speed": 12.0,
		"range": 180,
		"sight": 820,
		"is_boss": false,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false]
		}
	},
	3123:
	{
		"name": "百仙园首领",
		"hp": 22000000,
		"attack": 35000,
		"def": 5200,
		"mdef": 5200,
		"speed": 10.0,
		"range": 700,
		"sight": 1200,
		"is_boss": true,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false]
		}
	},
	3125:
	{
		"name": "百仙碟",
		"hp": 22000000,
		"attack": 35000,
		"def": 5200,
		"mdef": 5200,
		"speed": 10.0,
		"range": 180,
		"sight": 1200,
		"is_boss": true,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false],
			&"hit2": ["hit2", false],
			&"hit3": ["hit3", false]
		}
	},
	3126:
	{
		"name": "煞人蜂",
		"hp": 4500000,
		"attack": 24000,
		"def": 1050,
		"mdef": 1050,
		"speed": 12.0,
		"range": 180,
		"sight": 820,
		"is_boss": false,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false]
		}
	},
	3136:
	{
		"name": "傲来国阵眼",
		"hp": 22000000,
		"attack": 35000,
		"def": 5200,
		"mdef": 5200,
		"speed": 0.0,
		"range": 1200,
		"sight": 1200,
		"is_boss": true,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["wait", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false],
			&"hit2": ["hit1", false],
			&"hit3": ["hit1", false]
		}
	},
	3144:
	{
		"name": "傲来国怪物",
		"hp": 4500000,
		"attack": 24000,
		"def": 1050,
		"mdef": 1050,
		"speed": 12.0,
		"range": 160,
		"sight": 820,
		"is_boss": false,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false]
		}
	},
	3145:
	{
		"name": "傲来国怪物",
		"hp": 4500000,
		"attack": 24000,
		"def": 1050,
		"mdef": 1050,
		"speed": 12.0,
		"range": 160,
		"sight": 820,
		"is_boss": false,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false]
		}
	},
	3146:
	{
		"name": "傲来国怪物",
		"hp": 4500000,
		"attack": 24000,
		"def": 1050,
		"mdef": 1050,
		"speed": 12.0,
		"range": 160,
		"sight": 820,
		"is_boss": false,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false]
		}
	},
	3198:
	{
		"name": "嗜血蝙蝠",
		"hp": 5200000,
		"attack": 27000,
		"def": 1250,
		"mdef": 1250,
		"speed": 13.0,
		"range": 150,
		"sight": 850,
		"is_boss": false,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false]
		}
	},
	3199:
	{
		"name": "白角妖",
		"hp": 5200000,
		"attack": 27000,
		"def": 1250,
		"mdef": 1250,
		"speed": 13.0,
		"range": 160,
		"sight": 850,
		"is_boss": false,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false]
		}
	},
	3200:
	{
		"name": "蝙蝠妖王",
		"hp": 26000000,
		"attack": 39000,
		"def": 5800,
		"mdef": 5800,
		"speed": 10.0,
		"range": 240,
		"sight": 1200,
		"is_boss": true,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false],
			&"hit2": ["hit2", false],
			&"hit3": ["hit3", false]
		}
	},
	3201:
	{
		"name": "蓝翼蝙蝠",
		"hp": 5600000,
		"attack": 28500,
		"def": 1350,
		"mdef": 1350,
		"speed": 13.0,
		"range": 220,
		"sight": 850,
		"is_boss": false,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false],
			&"hit2": ["hit2", false]
		}
	},
	3222:
	{
		"name": "小道童",
		"hp": 6000000,
		"attack": 30000,
		"def": 1500,
		"mdef": 1500,
		"speed": 12.0,
		"range": 180,
		"sight": 900,
		"is_boss": false,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false]
		}
	},
	3223:
	{
		"name": "黄眉大王",
		"hp": 30000000,
		"attack": 43000,
		"def": 6500,
		"mdef": 6500,
		"speed": 10.0,
		"range": 240,
		"sight": 1200,
		"is_boss": true,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"attacks":
		{
			"hit1": {"multiplier": 0.67, "source_target_move": [32, 42]},
			"hit2": {"multiplier": 0.0},
			"hit3": {"multiplier": 0.0}
		},
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false],
			&"hit2": ["hit2", false],
			&"hit3": ["hit3", false]
		}
	},
	3224:
	{
		"name": "金铙",
		"hp": 10000000,
		"attack": 43000,
		"def": 6500,
		"mdef": 6500,
		"speed": 10.0,
		"range": 600,
		"sight": 940,
		"is_boss": false,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"attacks":
		{
			"hit1": {"multiplier": 0.34, "source_target_move": [90, 42]},
			"hit2": {"multiplier": 0.5, "source_target_move": [0, 0]},
			"hit3": {"multiplier": 0.75, "source_target_move": [66, 66]}
		},
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false],
			&"hit2": ["hit2", false],
			&"hit3": ["hit3", false]
		}
	},
	3225:
	{
		"name": "后天魔袋",
		"hp": 10000000,
		"attack": 43000,
		"def": 6500,
		"mdef": 6500,
		"speed": 10.0,
		"range": 350,
		"sight": 940,
		"is_boss": false,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"attacks":
		{
			"hit1": {"multiplier": 0.5, "kind": "magic", "source_target_move": [0, 0]},
			"hit2": {"multiplier": 0.25, "kind": "magic", "source_target_move": [0, 0]}
		},
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false],
			&"hit2": ["hit2", false]
		}
	},
	3276:
	{
		"name": "黑山羊",
		"hp": 6400000,
		"attack": 32000,
		"def": 1650,
		"mdef": 1650,
		"speed": 12.0,
		"range": 180,
		"sight": 900,
		"is_boss": false,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false]
		}
	},
	3277:
	{
		"name": "金之祖巫",
		"hp": 34000000,
		"attack": 47000,
		"def": 7200,
		"mdef": 7200,
		"speed": 10.0,
		"range": 260,
		"sight": 1200,
		"is_boss": true,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["wait", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false],
			&"hit2": ["hit2", false],
			&"hit3": ["hit3", false]
		}
	},
	3308:
	{
		"name": "小鹿妖",
		"hp": 7000000,
		"attack": 35000,
		"def": 1800,
		"mdef": 1800,
		"speed": 13.0,
		"range": 220,
		"sight": 900,
		"is_boss": false,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false],
			&"hit2": ["hit2", false]
		}
	},
	3309:
	{
		"name": "花妖",
		"hp": 7000000,
		"attack": 35000,
		"def": 1800,
		"mdef": 1800,
		"speed": 12.0,
		"range": 180,
		"sight": 900,
		"is_boss": false,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false]
		}
	},
	3310:
	{
		"name": "蝎尾妖后",
		"hp": 38000000,
		"attack": 51000,
		"def": 7800,
		"mdef": 7800,
		"speed": 10.0,
		"range": 280,
		"sight": 1200,
		"is_boss": true,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false],
			&"hit2": ["hit2", false],
			&"hit3": ["hit3", false]
		}
	},
	3311:
	{
		"name": "妖花灵",
		"hp": 9000000,
		"attack": 39000,
		"def": 2100,
		"mdef": 2100,
		"speed": 0.0,
		"range": 500,
		"sight": 900,
		"is_boss": false,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false]
		}
	},
	3320:
	{
		"name": "羊角花妖",
		"hp": 7800000,
		"attack": 39000,
		"def": 2200,
		"mdef": 2200,
		"speed": 12.0,
		"range": 190,
		"sight": 950,
		"is_boss": false,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false]
		}
	},
	3323:
	{
		"name": "百花仙子",
		"hp": 43000000,
		"attack": 56000,
		"def": 8500,
		"mdef": 8500,
		"speed": 10.0,
		"range": 300,
		"sight": 1200,
		"is_boss": true,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false],
			&"hit2": ["hit2", false],
			&"hit3": ["hit3", false]
		}
	},
	3343:
	{
		"name": "木之祖巫",
		"hp": 50000000,
		"attack": 62000,
		"def": 9200,
		"mdef": 9200,
		"speed": 10.0,
		"range": 320,
		"sight": 1200,
		"is_boss": true,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false],
			&"hit2": ["hit2", false],
			&"hit3": ["hit3", false]
		}
	},
	3352:
	{
		"name": "通天教主化身",
		"hp": 68000000,
		"attack": 70000,
		"def": 10500,
		"mdef": 10500,
		"speed": 11.0,
		"range": 340,
		"sight": 1400,
		"is_boss": true,
		"damage_bonus": 0.0,
		"damage_reduction": 0.0,
		"animations":
		{
			&"wait": ["wait", true],
			&"walk": ["walk", true],
			&"hurt": ["hurt", false],
			&"death": ["death", false],
			&"hit1": ["hit1", false],
			&"hit2": ["hit2", false],
			&"hit3": ["hit3", false]
		}
	},
}
static var _east_metadata_cache: Dictionary = {}
static var _east_animation_bundle_cache: Dictionary = {}
static var _east_geometry_cache: Dictionary = {}
static var _east_loose_frames_cache: Dictionary = {}


static func _metadata_for_model(model_id: int) -> String:
	var path := "res://Art/monster/swf_png/%d/atlas/metadata.tres" % model_id
	return path if ResourceLoader.exists(path) else ""


static func _get_east_metadata(metadata_path: String) -> Dictionary:
	if _east_metadata_cache.has(metadata_path):
		return _east_metadata_cache[metadata_path] as Dictionary
	var data := AtlasMetadataStore.data_for(metadata_path)
	if not data.is_empty():
		_east_metadata_cache[metadata_path] = data
	return data


static func _seq_frame_count(metadata_path: String, sequence_name: String) -> int:
	var metadata := _get_east_metadata(metadata_path)
	var sequences: Dictionary = metadata.get("sequences", {})
	var sequence: Dictionary = sequences.get(sequence_name, {})
	return Array(sequence.get("frames", [])).size()


static func _seq_reg_anchor(metadata_path: String, sequence_name: String, frame_index: int = 0) -> Vector2:
	var metadata := _get_east_metadata(metadata_path)
	var sequences: Dictionary = metadata.get("sequences", {})
	var sequence: Dictionary = sequences.get(sequence_name, {})
	var frames: Array = sequence.get("frames", [])
	if frame_index < 0 or frame_index >= frames.size() or not frames[frame_index] is Array:
		return Vector2.ZERO
	var entry: Array = frames[frame_index]
	if entry.size() < 10:
		return Vector2.ZERO
	var used_size := Vector2(float(entry[4]), float(entry[5]))
	var margin := Rect2(float(entry[6]), float(entry[7]), float(entry[8]), float(entry[9]))
	var canvas_size := used_size + margin.size
	var center_x := margin.position.x + used_size.x * 0.5 - canvas_size.x * 0.5
	var bottom_y := margin.position.y + used_size.y - canvas_size.y * 0.5
	return Vector2(center_x, bottom_y)


static func _frame_geom(metadata_path: String, sequence_name: String, frame_index: int) -> Dictionary:
	var cache_key := "%s|%s|%d" % [metadata_path, sequence_name, frame_index]
	if _east_geometry_cache.has(cache_key):
		return _east_geometry_cache[cache_key] as Dictionary
	var metadata := _get_east_metadata(metadata_path)
	var sequences: Dictionary = metadata.get("sequences", {})
	var sequence: Dictionary = sequences.get(sequence_name, {})
	var frames: Array = sequence.get("frames", [])
	if frame_index < 0 or frame_index >= frames.size() or not frames[frame_index] is Array:
		var missing := {"size": Vector2.ONE, "center": Vector2.ZERO, "has_visual": false}
		_east_geometry_cache[cache_key] = missing
		return missing
	var entry: Array = frames[frame_index]
	if entry.size() < 10:
		var invalid := {"size": Vector2.ONE, "center": Vector2.ZERO, "has_visual": false}
		_east_geometry_cache[cache_key] = invalid
		return invalid
	var used_size := Vector2(float(entry[4]), float(entry[5]))
	var original_size := used_size + Vector2(float(entry[8]), float(entry[9]))
	var geom := {
		"size": used_size,
		"center": Vector2(float(entry[6]), float(entry[7])) + used_size * 0.5 - original_size * 0.5,
		"has_visual": used_size.x > 0.0 and used_size.y > 0.0,
	}
	_east_geometry_cache[cache_key] = geom
	return geom


var _config: Dictionary = {}
var _runtime_config: Dictionary = {}
var _attack_serial := 0
var _action_registration_offsets: Dictionary = {}
var _hit_box_base_position := Vector2.ZERO
var _active_attack_name: StringName = &""
var _last_attack_collision_animation: StringName = &""
var _last_attack_collision_frame := -1
var _last_attack_collision_flip_h := false
var _3125_attack_index := 0
var _3161_attack_index := 0
var _3179_attack_index := 0
var _3179_blood_eye_ready_msec := 0
var _3179_blood_eye_serial := 0
var _3179_blood_eye_base_ebol := 0.0
var _3179_fire_dash_until_msec := 0
var _3179_fire_dash_invincible := false
var _3179_fire_dash_cooldown_until_msec := 0
var _3179_fire_slash_invincible := false
var _3179_fire_slash_no_grav_before := false
var _3323_skill3_invincible := false
var _3323_skill_y := 0.0
var _3323_skill_y_locked := false
var _late_attack_index := 0
var _3223_summons: Dictionary = {}
var _3120_attack_index := 0
var _3120_protect_serial := 0
var _3182_attack_index := 0
var _3182_skill_ready_msec: Dictionary = {}
var _3182_phase_ready_msec := 0
var _3182_global_ready_msec := 0
var _3182_rain_serial := 0
var _attack_window_cache: Dictionary = {}
var _effective_attack_range := 0.0
var _effective_attack_vertical_range := 0.0
var _special_attack_active := false
var _fixed_world_position := Vector2.ZERO
var _fixed_world_position_ready := false
var _fixed_flight_y := 0.0
var _fixed_flight_height_ready := false
var _3161_dash_no_grav_before := false
var _3161_dash_ground_y := 0.0


func _ready() -> void:
	_config = _resolve_runtime_config()
	_configure_monster()
	_configure_entity_collision_boxes()
	if hit_box != null:
		_hit_box_base_position = hit_box.position
	_build_animations()
	super._ready()
	if is_fly and monster_kind not in [3119, 3198, 3200, 3201, 3309]:
		_fixed_flight_y = global_position.y if monster_kind == 3323 else position.y
		_fixed_flight_height_ready = true
	if monster_kind in [3136, 3182]:
		_fixed_world_position = global_position
		_fixed_world_position_ready = true


func _configure_entity_collision_boxes() -> void:
	if not ENTITY_COLLISION_BOXES.has(monster_kind):
		return
	var config: Dictionary = ENTITY_COLLISION_BOXES[monster_kind]
	if hurt_box != null:
		var hurt_shape := RectangleShape2D.new()
		hurt_shape.size = config["hurt_size"] as Vector2
		hurt_box.position = config["hurt_position"] as Vector2
		hurt_box.shape = hurt_shape
	if pz != null:
		var body_shape := RectangleShape2D.new()
		body_shape.size = config["body_size"] as Vector2
		pz.position = config["body_position"] as Vector2
		pz.shape = body_shape


func _physics_process(delta: float) -> void:
	if monster_kind == 3323 and not death():
		no_grav = true
		velocity.y = 0.0
		if _3323_skill_y_locked:
			global_position.y = _3323_skill_y
		elif _fixed_flight_height_ready:
			global_position.y = _fixed_flight_y
	super._physics_process(delta)

	if monster_kind == 3179 and _3179_fire_dash_until_msec > 0:
		if Time.get_ticks_msec() < _3179_fire_dash_until_msec and _active_attack_name == &"hit2":
			velocity.x = (1.0 if monster_direction else -1.0) * 1200.0
			velocity.y = 0.0
		else:
			velocity.x = 0.0
			velocity.y = 0.0
			_3179_fire_dash_until_msec = 0
	if monster_kind in [3224, 3225] and has_meta("yellow_brow_owner"):
		var owner_value: Variant = get_meta("yellow_brow_owner")
		var owner: BaseMonster = null
		if typeof(owner_value) == TYPE_OBJECT and is_instance_valid(owner_value):
			owner = owner_value as BaseMonster
		if owner == null or not is_instance_valid(owner) or owner.death():
			queue_free()
			return
	if _fixed_flight_height_ready and not death() and monster_kind != 3323:
		no_grav = true
		velocity.y = 0.0
		position.y = _fixed_flight_y
	if monster_kind in [3136, 3182] and _fixed_world_position_ready:
		no_grav = true
		velocity = Vector2.ZERO
		global_position = _fixed_world_position
	if monster_kind == 3323 and _3323_skill_y_locked and not death():
		no_grav = true
		velocity.y = 0.0
		global_position.y = _3323_skill_y
	elif monster_kind == 3323 and _fixed_flight_height_ready and not death():
		no_grav = true
		velocity.y = 0.0
		global_position.y = _fixed_flight_y


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if (
		monster_kind == 3179 and (_3179_fire_dash_invincible or _3179_fire_slash_invincible)
		or monster_kind == 3323 and _3323_skill3_invincible
	):
		return
	super._on_hurt_box_area_entered(area)


func reduce_hp(value: int):
	if (
		monster_kind == 3179 and (_3179_fire_dash_invincible or _3179_fire_slash_invincible)
		or monster_kind == 3323 and _3323_skill3_invincible
	):
		return 0
	return super.reduce_hp(value)


func hurt_reduce_hp(value, target):
	if (
		monster_kind == 3179 and (_3179_fire_dash_invincible or _3179_fire_slash_invincible)
		or monster_kind == 3323 and _3323_skill3_invincible
	):
		return 0
	return super.hurt_reduce_hp(value, target)


func reduce_pet_hp(value: int, attack_kind: String) -> int:
	if (
		monster_kind == 3179 and (_3179_fire_dash_invincible or _3179_fire_slash_invincible)
		or monster_kind == 3323 and _3323_skill3_invincible
	):
		return 0
	return super.reduce_pet_hp(value, attack_kind)


func is_control_immune() -> bool:
	var source_super_armor := (
		(monster_kind == 3161 and is_attacking)
		or (monster_kind == 3179 and _active_attack_name in [&"hit2", &"hit5"])
		or (monster_kind == 3323 and _3323_skill3_invincible)
	)
	return source_super_armor or monster_kind in [3136, 3182, 3277] or super.is_control_immune()


func _resolve_runtime_config() -> Dictionary:
	var base_config: Variant = DATA.get(monster_kind, DATA[3159])
	var config: Dictionary = (base_config as Dictionary).duplicate(true) if base_config is Dictionary else {}
	if OFFICIAL_LATE_MONSTER_NAMES.has(monster_kind):
		config["name"] = str(OFFICIAL_LATE_MONSTER_NAMES[monster_kind])
	if not _runtime_config.is_empty():
		config.merge(_runtime_config, true)
	var level_node := get_level_node()
	if level_node != null and level_node.has_method("get_level_monster_config"):
		var source_id: int = int(get_meta("source_monster_id", monster_kind))
		var level_config: Variant = level_node.call("get_level_monster_config", source_id)
		if level_config is Dictionary and not (level_config as Dictionary).is_empty():
			config.merge(level_config as Dictionary, true)
	if bool(config.get("is_flying", false)):
		var animations: Dictionary = (config.get("animations", {}) as Dictionary).duplicate(true)
		if not animations.has(&"Fly_wait") and animations.has(&"wait"):
			animations[&"Fly_wait"] = (animations[&"wait"] as Array).duplicate()
		if not animations.has(&"Fly") and animations.has(&"walk"):
			animations[&"Fly"] = (animations[&"walk"] as Array).duplicate()
		config["animations"] = animations
	return config


func _configure_monster() -> void:
	if _config.is_empty():
		_config = _resolve_runtime_config()
	my_mr_name = str(_config.get("name", "怪物"))
	level = int(_config.get("level", 90))
	attack_in = int(_config.get("attack", 0))
	max_hp = int(_config.get("hp", 1))
	hp = max_hp
	def = int(_config.get("def", 0))
	mdef = int(_config.get("mdef", 0))
	var boss := bool(_config.get("is_boss", false))
	crit = int(_config.get("crit", 500 if boss else 340))
	miss = int(_config.get("miss", 180))
	htarget = int(_config.get("hit", 500))
	ar = int(_config.get("armor_break", 2500))
	sp = int(_config.get("magic_break", 2500))
	toughness = float(_config.get("toughness", 0.0))
	crit_reduce = int(_config.get("crit_reduce", 0))
	speed = float(_config.get("speed", 0.0))
	attack_range = int(_config.get("range", 0))
	mysee = int(_config.get("sight", 0))
	attack_desire = int(_config.get("attack_desire", 100))
	add_exp = int(_config.get("exp", 120 if boss else 12))
	fall_coin = int(_config.get("coin", 320 if boss else 10))
	fall_pro = float(_config.get("drop_rate", 0.0))
	fall_list = Array(_config.get("drop_list", [])).duplicate(true)
	independent_fall_list = Array(_config.get("independent_drop_list", [])).duplicate(true)
	is_boss = boss
	damage_bonus = float(_config.get("damage_bonus", 0.0))
	damage_reduction = float(_config.get("damage_reduction", 0.0))

	is_fly = bool(_config.get("is_flying", false))
	no_grav = monster_kind in [3136, 3182] or is_fly
	if no_grav:
		velocity.y = 0.0
	boss_max_protect = float(_config.get("max_protect", 250.0 if is_boss else 100.0))
	obj_attack_dict.clear()
	var configured_attacks: Dictionary = _config.get("attacks", {}) as Dictionary
	for animation_name: StringName in _config["animations"]:
		if not str(animation_name).begins_with("hit"):
			continue
		var attack_value: Variant = configured_attacks.get(str(animation_name), {})
		var attack_data: Dictionary = attack_value as Dictionary if attack_value is Dictionary else {}
		var power := roundi(float(attack_in) * float(attack_data.get("multiplier", 1.0)))
		if attack_data.has("power"):
			power = int(attack_data["power"])
		var configured_attack := {
			"power": power,
			"hurtBack": Array(attack_data.get("hurt_back", [-4, -2])).duplicate(),
			"attackKind": str(attack_data.get("kind", "physics")),
			"HitProtect": int(attack_data.get("protect", 90)),
		}
		if attack_data.has("source_target_move"):
			configured_attack["sourceTargetMove"] = Array(attack_data["source_target_move"]).duplicate()
		obj_attack_dict[str(animation_name)] = configured_attack


func monster_info_base_attack() -> int:
	return int(_config.get("attack", attack_in))


func monster_info_attack_values_include_difficulty() -> bool:
	return false


func _metadata_path() -> String:
	return _metadata_for_model(monster_kind)


func _standard_body_frames_path() -> String:
	# 以 metadata 所在目录（.../<model>/atlas）为锚点推导标准资源路径。
	# 使用别名时 manifest_for_model 已解析到目标 model，因此别名场景自动复用同一资源。
	# 资源存在即启用，便于按批次逐步迁移而不改动本函数。
	var metadata := _metadata_path()
	if metadata.is_empty():
		return ""
	var atlas_dir := metadata.get_base_dir()
	var model := atlas_dir.get_base_dir().get_file()
	if model.is_empty():
		return ""
	var frames_path := atlas_dir.path_join("swf_png_%s_frames.tres" % model)
	return frames_path if ResourceLoader.exists(frames_path) else ""


func _load_standard_body_frames() -> SpriteFrames:
	var path := _standard_body_frames_path()
	if path.is_empty():
		return null
	var source := load(path) as SpriteFrames
	if source == null:
		return null
	var frames := SpriteFrames.new()
	if frames.has_animation(&"default"):
		frames.remove_animation(&"default")
	for action_name: StringName in _config.get("animations", {}).keys():
		# 使用独立 PNG 根目录的动作（如 3120/3161 的 hit 效果）不在图集内，
		# 由 _configure_monster 单独注入，否则会把占位序列错误当成该动作。
		if not _action_root(action_name).is_empty():
			continue
		var animation_data: Array = _config["animations"][action_name]
		var sequence_name := StringName(str(animation_data[0]))
		if not source.has_animation(sequence_name):
			return null
		frames.add_animation(action_name)
		frames.set_animation_speed(action_name, source.get_animation_speed(sequence_name))
		frames.set_animation_loop(action_name, source.get_animation_loop(sequence_name))
		for frame_index in range(source.get_frame_count(sequence_name)):
			frames.add_frame(action_name, source.get_frame_texture(sequence_name, frame_index))
	return frames


func _build_animations() -> void:
	var cache_key := var_to_str(
		[monster_kind, _metadata_path(), _standard_body_frames_path(), _config, SOURCE_FPS, SMALL_HURT_DURATION]
	)
	var cached: Dictionary = _east_animation_bundle_cache.get(cache_key, {})
	if not cached.is_empty():
		mr_ani.sprite_frames = cached["frames"] as SpriteFrames
		_action_registration_offsets = (cached["offsets"] as Dictionary).duplicate(true)
		_attack_window_cache = (cached["windows"] as Dictionary).duplicate(true)
		_effective_attack_range = float(cached["range"])
		_effective_attack_vertical_range = float(cached["vertical_range"])
		mr_ani.centered = true
		mr_ani.flip_h = true
		mr_ani.position = _visual_offset(&"wait")
		if mr_player.has_animation_library(&""):
			mr_player.remove_animation_library(&"")
		mr_player.add_animation_library(&"", cached["library"] as AnimationLibrary)
		return
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	var metadata := _metadata_path()
	var standard_frames := _load_standard_body_frames()
	if standard_frames != null:
		frames = standard_frames
	_attack_window_cache.clear()

	var registration_anchor: Variant = null
	if monster_kind in [3120, 3125]:
		registration_anchor = _seq_reg_anchor(metadata, "wait")
	var wait_anchor := _seq_reg_anchor(metadata, "wait")
	_action_registration_offsets.clear()
	for action_name: StringName in _config["animations"]:
		var action_data: Array = _config["animations"][action_name]

		if SOURCE_VISUAL_OFFSETS.has(monster_kind) or not _action_root(action_name).is_empty():
			_action_registration_offsets[action_name] = Vector2.ZERO
			continue
		var action_anchor := _seq_reg_anchor(metadata, str(action_data[0]))

		_action_registration_offsets[action_name] = Vector2(
			action_anchor.x - wait_anchor.x, wait_anchor.y - action_anchor.y
		)
	for animation_name: StringName in _config["animations"]:
		var animation_data: Array = _config["animations"][animation_name]
		var loose_root := _action_root(animation_name)
		# 标准资源已包含图集动作；仅独立 PNG 根目录的动作需要在此补充。
		if not loose_root.is_empty():
			_add_loose_animation(frames, loose_root, animation_name, SOURCE_FPS, bool(animation_data[1]))
	mr_ani.sprite_frames = frames
	mr_ani.centered = true
	mr_ani.flip_h = true
	mr_ani.position = _visual_offset(&"wait")
	if mr_player.has_animation_library(&""):
		mr_player.remove_animation_library(&"")
	var library := AnimationLibrary.new()
	for animation_name: StringName in _config["animations"]:
		var sequence_name: String = str(_config["animations"][animation_name][0])
		var frame_count := _animation_frame_count(animation_name, metadata, sequence_name)
		var animation := Animation.new()
		animation.length = maxf(float(frame_count) / SOURCE_FPS, 0.05)
		if animation_name == &"hurt" and not is_boss:
			animation.length = SMALL_HURT_DURATION
		animation.loop_mode = (
			Animation.LOOP_LINEAR if bool(_config["animations"][animation_name][1]) else Animation.LOOP_NONE
		)
		var track := animation.add_track(Animation.TYPE_METHOD)
		animation.track_set_path(track, NodePath("."))
		animation.track_insert_key(track, 0.0, {"method": &"_play_frames", "args": [animation_name]})
		if animation_name.begins_with("hit"):
			var attack_window := _attack_window(animation_name, metadata)
			_add_method_key(animation, float(attack_window[0]) / SOURCE_FPS, &"_enable_attack_box", [animation_name])
			_add_method_key(animation, float(attack_window[1]) / SOURCE_FPS, &"_disable_attack_box")
		if animation_name == &"death":
			animation.track_insert_key(
				track, maxf(animation.length - 0.01, 0.0), {"method": &"settle_death_drops_and_free", "args": []}
			)
		library.add_animation(animation_name, animation)
	mr_player.add_animation_library(&"", library)
	_effective_attack_range = _calculate_effective_attack_range()
	_east_animation_bundle_cache[cache_key] = {
		"frames": frames,
		"library": library,
		"offsets": _action_registration_offsets.duplicate(true),
		"windows": _attack_window_cache.duplicate(true),
		"range": _effective_attack_range,
		"vertical_range": _effective_attack_vertical_range,
	}


func _add_method_key(animation: Animation, time: float, method_name: StringName, args: Array = []) -> void:
	var track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track, NodePath("."))
	animation.track_insert_key(
		track, clampf(time, 0.0, maxf(animation.length - 0.001, 0.0)), {"method": method_name, "args": args}
	)


func _action_root(animation_name: StringName) -> String:
	if monster_kind == 3161:
		return str(MONKEY_ACTION_ROOTS.get(animation_name, ""))
	if monster_kind == 3120:
		return str(SAND_BOSS_ACTION_ROOTS.get(animation_name, ""))
	return ""


func _animation_frame_count(animation_name: StringName, metadata: String, sequence_name: String) -> int:
	var loose_count: Variant = null
	if monster_kind == 3161:
		loose_count = MONKEY_ACTION_COUNTS.get(animation_name, null)
	elif monster_kind == 3120:
		loose_count = SAND_BOSS_ACTION_COUNTS.get(animation_name, null)
	if loose_count != null:
		return int(loose_count)
	return _seq_frame_count(metadata, sequence_name)


func _add_loose_animation(
	frames: SpriteFrames, root: String, animation_name: StringName, fps: float, looped: bool
) -> void:
	var source := _load_loose_frames(root)
	if source == null or not source.has_animation(&"play"):
		push_error("EastContinent standard effect frames missing: " + root)
		return
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, fps)
	frames.set_animation_loop(animation_name, looped)
	for frame_index in range(source.get_frame_count(&"play")):
		frames.add_frame(animation_name, source.get_frame_texture(&"play", frame_index))


func _load_loose_frames(root: String) -> SpriteFrames:
	if _east_loose_frames_cache.has(root):
		return _east_loose_frames_cache[root] as SpriteFrames
	var path := root + "_frames.tres"
	if not ResourceLoader.exists(path):
		return null
	var frames := load(path) as SpriteFrames
	_east_loose_frames_cache[root] = frames
	return frames


func _loose_frame_geometry(root: String, frame_index: int) -> Dictionary:
	var cache_key := "%s|%d" % [root, frame_index]
	if _loose_geometry_cache.has(cache_key):
		return _loose_geometry_cache[cache_key] as Dictionary
	var source := _load_loose_frames(root)
	var texture: Texture2D = null
	if source != null and source.has_animation(&"play") and frame_index < source.get_frame_count(&"play"):
		texture = source.get_frame_texture(&"play", frame_index)
	if texture == null:
		var missing := {"size": Vector2.ONE, "center": Vector2.ZERO, "has_visual": false}
		_loose_geometry_cache[cache_key] = missing
		return missing
	var image := texture.get_image()
	if image == null:
		var no_image := {"size": Vector2.ONE, "center": Vector2.ZERO, "has_visual": false}
		_loose_geometry_cache[cache_key] = no_image
		return no_image
	var used_rect := image.get_used_rect()
	if used_rect.size == Vector2i.ZERO:
		var empty := {"size": Vector2.ONE, "center": Vector2.ZERO, "has_visual": false}
		_loose_geometry_cache[cache_key] = empty
		return empty
	var size := Vector2(used_rect.size)
	var result := {
		"size": size,
		"center": Vector2(used_rect.position) + size * 0.5 - Vector2(texture.get_size()) * 0.5,
		"has_visual": true,
	}
	_loose_geometry_cache[cache_key] = result
	return result


func _attack_window(attack_name: StringName, metadata: String) -> Array[int]:
	if _attack_window_cache.has(attack_name):
		return _attack_window_cache[attack_name] as Array[int]
	var sequence_name := str(_config["animations"][attack_name][0])
	var action_root := _action_root(attack_name)
	var frame_count := _animation_frame_count(attack_name, metadata, sequence_name)
	if frame_count <= 0:
		return [0, 1]

	if monster_kind == 3161 and attack_name == &"hit2":
		var source_window: Array[int] = [21, frame_count]
		_attack_window_cache[attack_name] = source_window
		return source_window
	if monster_kind == 3179 and attack_name == &"hit3":
		var source_window: Array[int] = [5, frame_count]
		_attack_window_cache[attack_name] = source_window
		return source_window

	var first_active := -1
	var last_active := -1
	var action_offset := _action_geometry_offset(attack_name)
	var action_base := (
		_loose_frame_geometry(action_root, 0) if not action_root.is_empty() else _frame_geom(metadata, sequence_name, 0)
	)
	var base_size := action_base.get("size", Vector2.ONE) as Vector2
	var base_center := action_base.get("center", Vector2.ZERO) as Vector2
	base_center += action_offset
	var base_rect := Rect2(base_center - base_size * 0.5, base_size)
	for frame_index in range(frame_count):
		var geometry := (
			_loose_frame_geometry(action_root, frame_index)
			if not action_root.is_empty()
			else _frame_geom(metadata, sequence_name, frame_index)
		)
		if not bool(geometry.get("has_visual", false)):
			continue
		var size := geometry.get("size", Vector2.ONE) as Vector2
		var center := geometry.get("center", Vector2.ZERO) as Vector2
		center += action_offset
		var rect := Rect2(center - size * 0.5, size)
		var idle_area := maxf(base_rect.size.x * base_rect.size.y, 1.0)
		var frame_area := rect.size.x * rect.size.y
		var extends_idle := (
			rect.position.x < base_rect.position.x - 20.0
			or rect.end.x > base_rect.end.x + 20.0
			or rect.position.y < base_rect.position.y - 20.0
			or rect.end.y > base_rect.end.y + 20.0
			or frame_area > idle_area * 1.25
		)
		if extends_idle:
			if first_active < 0:
				first_active = frame_index
			last_active = frame_index
	if first_active < 0:
		first_active = 0
		last_active = frame_count - 1
	var derived_window: Array[int] = [first_active, mini(last_active + 1, frame_count)]
	_attack_window_cache[attack_name] = derived_window
	return derived_window


func _play_frames(animation_name: StringName) -> void:
	mr_ani.position = _visual_offset(animation_name)
	if hit_box != null:
		var hit_offset := _action_registration_offsets.get(animation_name, Vector2.ZERO) as Vector2
		if not _action_root(animation_name).is_empty():
			hit_offset = _action_geometry_offset(animation_name)
		if monster_kind == 3125 and animation_name.begins_with("hit"):
			hit_offset = Vector2.ZERO
		hit_box.position = _hit_box_base_position + hit_offset
	mr_ani.play(animation_name)
	if not animation_name.begins_with("hit"):
		_active_attack_name = &""


func _visual_offset(animation_name: StringName) -> Vector2:
	if SOURCE_VISUAL_OFFSETS.has(monster_kind):
		var source_offsets: Dictionary = SOURCE_VISUAL_OFFSETS[monster_kind]
		var source_offset: Vector2 = source_offsets.get(animation_name, source_offsets[&"wait"])
		if mr_ani.flip_h:
			source_offset.x = -source_offset.x
		return source_offset
	var foot_offset := float(FOOT_OFFSETS.get(monster_kind, NAN))
	if is_nan(foot_offset):
		foot_offset = -_seq_reg_anchor(_metadata_path(), "wait").y
	var offset := Vector2(0.0, foot_offset)
	if monster_kind == 3120 and SAND_BOSS_ACTION_VISUAL_OFFSETS.has(animation_name):
		offset += SAND_BOSS_ACTION_VISUAL_OFFSETS[animation_name] as Vector2
		return offset
	if monster_kind == 3125 and animation_name.begins_with("hit"):
		return offset

	offset += Vector2(_action_registration_offsets.get(animation_name, Vector2.ZERO))
	return offset


func _action_geometry_offset(animation_name: StringName) -> Vector2:
	if SOURCE_VISUAL_OFFSETS.has(monster_kind):
		return Vector2.ZERO
	var action_offset := _action_registration_offsets.get(animation_name, Vector2.ZERO) as Vector2
	if monster_kind == 3125 and animation_name.begins_with("hit"):
		return Vector2(-action_offset.x, action_offset.y)
	return action_offset


func _enable_attack_box(attack_name: StringName = &"") -> void:
	_active_attack_name = attack_name
	if (
		monster_kind == 3223
		or (monster_kind == 3224 and attack_name == &"hit3")
		or (monster_kind == 3177 and attack_name == &"hit2")
		or monster_kind == 3161
		or (monster_kind == 3179 and attack_name != &"hit2")
		or monster_kind in [3120, 3136, 3182]
		or monster_kind == 3121
	):
		_disable_attack_box()
		return
	_sync_attack_collision(true)
	if hit_box != null:
		hit_name = str(attack_name)
		hit_box.set_deferred("disabled", false)


func _disable_attack_box() -> void:
	if hit_box != null:
		hit_box.set_deferred("disabled", true)


func _sync_attack_collision(force: bool = false) -> void:
	if hit_box == null or _active_attack_name.is_empty():
		return
	_last_attack_collision_animation = mr_ani.animation
	_last_attack_collision_frame = mr_ani.frame
	_last_attack_collision_flip_h = mr_ani.flip_h
	if (
		monster_kind == 3223
		or (monster_kind == 3224 and _active_attack_name == &"hit3")
		or (monster_kind == 3177 and _active_attack_name == &"hit2")
		or monster_kind == 3161
		or (monster_kind == 3179 and _active_attack_name != &"hit2")
		or monster_kind == 3182
	):
		_disable_attack_box()
		return
	if LATE_SKILL_EFFECTS.has(_late_effect_key(_active_attack_name)):
		_disable_attack_box()
		return
	if (
		OFFICIAL_SKILL_SCOPE.has(monster_kind)
		and (OFFICIAL_SKILL_SCOPE[monster_kind] as Dictionary).has(_active_attack_name)
		and not LATE_SKILL_EFFECTS.has(_late_effect_key(_active_attack_name))
	):
		var scope: Array = (OFFICIAL_SKILL_SCOPE[monster_kind] as Dictionary)[_active_attack_name]
		var x_min := float(scope[0])
		var x_max := float(scope[1])
		var y_min := float(scope[2]) if scope.size() >= 4 else -300.0
		var y_max := float(scope[3]) if scope.size() >= 4 else 300.0
		if is_zero_approx(y_min) and is_zero_approx(y_max):
			y_min = -300.0
			y_max = 300.0
		var official_shape := hit_box.shape as RectangleShape2D
		if official_shape == null:
			official_shape = RectangleShape2D.new()
			hit_box.shape = official_shape
		official_shape.size = Vector2(x_max - x_min, y_max - y_min)

		hit_box.position = Vector2(-(x_min + x_max) * 0.5, (y_min + y_max) * 0.5)
		return
	var animation_data: Array = _config["animations"].get(_active_attack_name, [])
	if animation_data.is_empty():
		return
	var sequence_name := str(animation_data[0])
	var action_root := _action_root(_active_attack_name)
	var frame_index := clampi(
		mr_ani.frame, 0, maxi(_animation_frame_count(_active_attack_name, _metadata_path(), sequence_name) - 1, 0)
	)
	var geometry := (
		_loose_frame_geometry(action_root, frame_index)
		if not action_root.is_empty()
		else _frame_geom(_metadata_path(), sequence_name, frame_index)
	)
	if not bool(geometry.get("has_visual", false)):
		hit_box.set_deferred("disabled", true)
		return
	var size := geometry.get("size", Vector2.ONE) as Vector2
	var center := geometry.get("center", Vector2.ZERO) as Vector2
	if monster_kind == 3120 and action_root.is_empty():
		var wait_anchor := _seq_reg_anchor(_metadata_path(), "wait")
		var frame_anchor := _seq_reg_anchor(_metadata_path(), sequence_name, frame_index)
		center += wait_anchor - frame_anchor
	elif monster_kind == 3125 and _active_attack_name.begins_with("hit"):
		center += _action_geometry_offset(_active_attack_name)
	var shape := hit_box.shape as RectangleShape2D
	if shape == null:
		shape = RectangleShape2D.new()
		hit_box.shape = shape
	if force or not shape.size.is_equal_approx(size):
		shape.size = Vector2(maxf(size.x, 1.0), maxf(size.y, 1.0))

	var visual_center := center
	if mr_ani.flip_h:
		visual_center.x = -visual_center.x
	var visual_point := mr_ani.to_global(visual_center)
	var hit_box_parent := hit_box.get_parent() as Node2D
	var desired_position := hit_box_parent.to_local(visual_point) if hit_box_parent != null else visual_point
	if force or not hit_box.position.is_equal_approx(desired_position):
		hit_box.position = desired_position


func _process(_delta: float) -> void:
	if is_attacking and not _active_attack_name.is_empty():
		if (
			_last_attack_collision_animation == mr_ani.animation
			and _last_attack_collision_frame == mr_ani.frame
			and _last_attack_collision_flip_h == mr_ani.flip_h
		):
			return
		_sync_attack_collision()


func _calculate_effective_attack_range() -> float:
	var configured_range := float(_config.get("range", 0.0))
	if monster_kind == 3177:
		return 70.0 + 120.0 * 1.2
	if monster_kind == 3121:
		return 170.0
	if OFFICIAL_SKILL_SCOPE.has(monster_kind):
		var official_range := 0.0
		var scopes: Dictionary = OFFICIAL_SKILL_SCOPE[monster_kind]
		for scope_value: Variant in scopes.values():
			var scope: Array = scope_value as Array
			if scope.size() >= 2:
				official_range = maxf(official_range, maxf(absf(float(scope[0])), absf(float(scope[1]))) + 20.0)
		if official_range > 0.0:
			return official_range
	var max_forward_reach := 0.0
	var max_vertical_reach := 0.0
	var metadata := _metadata_path()
	for animation_name: StringName in _config["animations"]:
		if not str(animation_name).begins_with("hit"):
			continue
		var animation_data: Array = _config["animations"][animation_name]
		var action_root := _action_root(animation_name)
		var frame_count := _animation_frame_count(animation_name, metadata, str(animation_data[0]))
		for frame_index in range(frame_count):
			var geometry := (
				_loose_frame_geometry(action_root, frame_index)
				if not action_root.is_empty()
				else _frame_geom(metadata, str(animation_data[0]), frame_index)
			)
			if not bool(geometry.get("has_visual", false)):
				continue
			var size := geometry.get("size", Vector2.ONE) as Vector2
			var center := geometry.get("center", Vector2.ZERO) as Vector2
			max_forward_reach = maxf(max_forward_reach, absf(center.x) + size.x * 0.5)
			max_vertical_reach = maxf(max_vertical_reach, absf(center.y) + size.y * 0.5)
	_effective_attack_vertical_range = max_vertical_reach
	if max_forward_reach <= 0.0:
		return configured_range
	return minf(configured_range, max_forward_reach + 32.0)


func _pick_3120_attack() -> StringName:
	var result := &"hit1" if _3120_attack_index % 2 == 0 else &"hit2"
	_3120_attack_index += 1
	return result


func _pick_3161_attack(target_distance: float) -> StringName:
	var sequence: Array[StringName] = [&"hit1", &"hit3", &"hit1"]
	if max_hp > 0 and float(hp) / float(max_hp) <= 0.66:
		sequence = [&"hit2", &"hit1", &"hit3", &"hit1"]
	for offset in range(sequence.size()):
		var index := (_3161_attack_index + offset) % sequence.size()
		var candidate := sequence[index]
		var scope: Array = (OFFICIAL_SKILL_SCOPE[3161] as Dictionary)[candidate]
		if target_distance <= float(scope[1]) + 20.0:
			_3161_attack_index = index + 1
			return candidate
	return &""


func _pick_3179_attack(target_distance: float) -> StringName:
	var low_health := max_hp > 0 and float(hp) / float(max_hp) <= 0.66
	var now := Time.get_ticks_msec()
	if low_health and now >= _3179_blood_eye_ready_msec:
		_3179_blood_eye_ready_msec = now + 12000
		return &"hit4"
	var sequence: Array[StringName] = [&"hit1", &"hit2", &"hit3"]
	if low_health:
		sequence = [&"hit1", &"hit2", &"hit3", &"hit2", &"hit1", &"hit5"]
	for offset in range(sequence.size()):
		var index := (_3179_attack_index + offset) % sequence.size()
		var candidate := sequence[index]
		var scope: Array = (OFFICIAL_SKILL_SCOPE[3179] as Dictionary)[candidate]
		if target_distance <= maxf(absf(float(scope[0])), absf(float(scope[1]))) + 20.0:
			_3179_attack_index = index + 1
			return candidate
	return &""


func _pick_3182_attack() -> StringName:
	var now := Time.get_ticks_msec()
	if now < _3182_global_ready_msec:
		return &""
	if (
		max_hp > 0
		and float(hp) / float(max_hp) < RAIN_ANCESTOR_PHASE_HP_RATIO
		and now >= _3182_phase_ready_msec
		and mr_player.has_animation(&"hit4")
		and mr_player.has_animation(&"hit5")
	):
		_3182_phase_ready_msec = now + RAIN_ANCESTOR_PHASE_COOLDOWN_MSEC
		_3182_global_ready_msec = now + 6000
		return &"hit5"
	var candidates: Array[StringName] = [&"hit1", &"hit2", &"hit3"]
	for offset in range(candidates.size()):
		var index := (_3182_attack_index + offset) % candidates.size()
		var candidate := candidates[index]
		if not mr_player.has_animation(candidate):
			continue
		if now < int(_3182_skill_ready_msec.get(candidate, 0)):
			continue
		_3182_attack_index = index + 1
		_3182_skill_ready_msec[candidate] = now + int(RAIN_ANCESTOR_SKILL_COOLDOWNS[candidate])
		_3182_global_ready_msec = now + 3500
		return candidate
	return &""


func ai_think() -> void:
	if monster_kind in [3136, 3182]:
		_stationary_boss_intelligence()
		return
	if monster_kind in [3119, 3198, 3200, 3201, 3309] and is_fly:
		_monster_3119_intelligence()
		return
	if death() or is_attacking or _special_attack_active or RoleProp == null:
		return
	var target := RoleProp.get_nearest_monster_target_position(global_position)
	if target == null:
		stop_move()
		return
	var distance := absf(float(target.x) - position.x)
	if distance > float(mysee):
		stop_move()
		return
	to_hero()
	var combat_range := _effective_attack_range if _effective_attack_range > 0.0 else float(attack_range)
	if monster_kind == 3161 and max_hp > 0 and float(hp) / float(max_hp) > 0.66:
		combat_range = 620.0
	elif monster_kind == 3179:
		if Time.get_ticks_msec() < _3179_fire_dash_cooldown_until_msec:
			stop_move()
			return
		combat_range = 495.0
	if distance > combat_range:
		have_target()
	elif count % 30 == 0:
		attack_target()
	else:
		stop_move()


func _stationary_boss_intelligence() -> void:
	velocity = Vector2.ZERO
	if death() or is_attacking or _special_attack_active or RoleProp == null:
		return
	var target := RoleProp.get_nearest_monster_target_position(global_position)
	if target == null or absf(float(target.x) - global_position.x) > float(mysee):
		stop_move()
		return
	has_target = true
	to_hero()
	if count % 30 == 0:
		attack_target()
	else:
		stop_move()


func _official_in_skill_scope(target_position: Vector2, scope: Array) -> bool:
	if scope.size() < 2 or target_position == Vector2.ZERO:
		return false
	var x_min := float(scope[0])
	var x_max := float(scope[1])
	var rect_x := global_position.x + (x_min if monster_direction else -x_max)
	var rect_width := x_max - x_min
	var target_rect := _target_hurt_rect(target_position)
	if rect_x >= target_rect.end.x or rect_x + rect_width <= target_rect.position.x:
		return false
	if scope.size() < 4:
		return true
	var y_min := float(scope[2])
	var y_max := float(scope[3])
	if is_zero_approx(y_min) and is_zero_approx(y_max):
		return true
	var skill_rect := Rect2(Vector2(rect_x, global_position.y + y_min), Vector2(rect_width, y_max - y_min))
	return skill_rect.intersects(target_rect)


func _target_hurt_rect(fallback_position: Vector2) -> Rect2:
	var fallback := Rect2(fallback_position + Vector2(-20.0, -54.0), Vector2(40.0, 98.0))
	if RoleProp == null or not RoleProp.source_player is Node2D:
		return fallback
	var target := RoleProp.source_player as Node2D
	if not is_instance_valid(target) or not target.is_inside_tree():
		return fallback
	if target.global_position.distance_squared_to(fallback_position) > 4.0:
		return fallback
	var hurt_shape := target.get_node_or_null("base_damagebox/HurtBox/HurtBox") as CollisionShape2D
	if hurt_shape == null or hurt_shape.disabled or hurt_shape.shape == null:
		return fallback
	var shape_size := Vector2(40.0, 98.0)
	if hurt_shape.shape is RectangleShape2D:
		shape_size = (hurt_shape.shape as RectangleShape2D).size
	elif hurt_shape.shape is CapsuleShape2D:
		var capsule := hurt_shape.shape as CapsuleShape2D
		shape_size = Vector2(capsule.radius * 2.0, capsule.height)
	elif hurt_shape.shape is CircleShape2D:
		var radius := (hurt_shape.shape as CircleShape2D).radius
		shape_size = Vector2(radius * 2.0, radius * 2.0)
	shape_size *= Vector2(absf(hurt_shape.global_scale.x), absf(hurt_shape.global_scale.y))
	return Rect2(hurt_shape.global_position - shape_size * 0.5, shape_size)


func _official_scope_stand_position(target_position: Vector2, scope: Array) -> Vector2:
	var x_min := float(scope[0])
	var x_max := float(scope[1])
	var y_min := float(scope[2])
	var y_max := float(scope[3])
	var toward := 1.0 if target_position.x >= global_position.x else -1.0
	var half := (x_max - x_min) * 0.5
	var overlap := minf(maxf((y_max - y_min) * 0.5, 12.0), 24.0)
	var target_rect := _target_hurt_rect(target_position)
	var stand_y := target_rect.position.y - y_max + overlap
	if is_zero_approx(y_min) and is_zero_approx(y_max):
		stand_y = target_position.y - 30.0
	return Vector2(target_position.x - toward * half, stand_y)


func _monster_3119_intelligence() -> void:
	if death() or is_attacking or _special_attack_active or RoleProp == null:
		return
	var target := RoleProp.get_nearest_monster_target_position(global_position)
	if target == null:
		velocity = Vector2.ZERO
		stop_move()
		return
	var target_position: Vector2 = target
	var delta := target_position - global_position
	if absf(delta.x) > float(mysee):
		velocity = Vector2.ZERO
		stop_move()
		return

	has_target = true
	to_hero()

	monster_direction = target_position.x >= global_position.x
	var scope: Array = []
	if OFFICIAL_SKILL_SCOPE.has(monster_kind):
		scope = (OFFICIAL_SKILL_SCOPE[monster_kind] as Dictionary).get(&"hit1", [])
	var in_scope := false
	if monster_kind >= 3198:
		in_scope = not _reachable_official_attacks().is_empty()
	elif not scope.is_empty():
		in_scope = _official_in_skill_scope(target_position, scope)
	else:
		in_scope = absf(delta.x) <= (_effective_attack_range if _effective_attack_range > 0.0 else float(attack_range))

	var stand_position := (
		_official_scope_stand_position(target_position, scope)
		if not scope.is_empty()
		else Vector2(target_position.x - signf(delta.x) * 80.0, target_position.y)
	)
	var approach := stand_position - global_position
	var aligned := absf(approach.x) <= 6.0 and absf(approach.y) <= 6.0
	if in_scope and (monster_kind == 3200 or aligned):
		velocity.x = 0.0
		velocity.y = move_toward(velocity.y, 0.0, speed * 60.0 * get_physics_process_delta_time())
		if count % 30 == 0:
			attack_target()

		if is_attacking:
			return
	else:
		var desired_x := 0.0
		if absf(approach.x) > 2.0:
			desired_x = signf(approach.x) * speed * 10.0
		var desired_y := 0.0

		if absf(approach.y) > 2.0:
			desired_y = signf(approach.y) * speed * 7.0
		velocity.x = move_toward(velocity.x, desired_x, speed * 60.0 * get_physics_process_delta_time())
		velocity.y = move_toward(velocity.y, desired_y, speed * 60.0 * get_physics_process_delta_time())
	var moving := not is_zero_approx(velocity.x) or not is_zero_approx(velocity.y)
	var movement_animation: StringName = &"Fly" if moving else &"Fly_wait"
	if not mr_player.has_animation(movement_animation):
		movement_animation = &"walk" if moving else &"wait"
	if mr_player.current_animation != movement_animation:
		mr_player.play(movement_animation)


func _late_effect_key(attack_name: StringName) -> String:
	return "%d:%s" % [monster_kind, str(attack_name)]


func _reachable_official_attacks() -> Array[StringName]:
	var result: Array[StringName] = []
	if monster_kind < 3198 or not OFFICIAL_SKILL_SCOPE.has(monster_kind) or RoleProp == null:
		return result
	var target_value: Variant = RoleProp.get_nearest_monster_target_position(global_position)
	if not target_value is Vector2:
		return result
	var target_position := target_value as Vector2
	monster_direction = target_position.x >= global_position.x
	var scopes: Dictionary = OFFICIAL_SKILL_SCOPE[monster_kind]
	for attack_index in range(1, 6):
		var attack_name := StringName("hit%d" % attack_index)
		if not mr_player.has_animation(attack_name) or not scopes.has(attack_name):
			continue
		var scope: Array = scopes[attack_name] as Array
		if scope.size() < 2:
			continue
		if _official_in_skill_scope(target_position, scope):
			result.append(attack_name)
	return result


func _start_late_skill_effect(attack_name: StringName, serial: int) -> void:
	var effect_key := _late_effect_key(attack_name)
	if not LATE_SKILL_EFFECTS.has(effect_key):
		return
	var effect_config: Dictionary = (LATE_SKILL_EFFECTS[effect_key] as Dictionary).duplicate(true)
	if monster_kind == 3323 and attack_name == &"hit3":
		_special_attack_active = true
		is_attacking = true
		_3323_skill3_invincible = true
		hurt_box.set_deferred("disabled", true)
		effect_config["finished_callback"] = Callable(self, "_finish_3323_skill3")
	var shot_delay := maxf(float(effect_config.get("shot_frame", 0)) / SOURCE_FPS, 0.0)
	if shot_delay > 0.0:
		await get_tree().create_timer(shot_delay, false).timeout
	if not _late_attack_is_current(serial):
		if monster_kind == 3323 and attack_name == &"hit3":
			_finish_3323_skill3(global_position)
		elif monster_kind == 3323:
			_3323_skill_y_locked = false
		return
	if bool(effect_config.get("fox_rain", false)):
		_start_3310_fox_rain(attack_name, effect_config, serial)
		return
	_schedule_late_target_bursts(attack_name, effect_config, serial)
	var repeats := maxi(int(effect_config.get("repeats", 1)), 1)
	var repeat_delay := maxf(float(effect_config.get("repeat_delay", 0.0)), 0.0)
	for repeat_index in range(repeats):
		if not _late_attack_is_current(serial):
			if monster_kind == 3323 and attack_name == &"hit3":
				_finish_3323_skill3(global_position)
			elif monster_kind == 3323:
				_3323_skill_y_locked = false
			return
		_spawn_late_skill_effect(attack_name, effect_config, repeat_index, repeats)
		if repeat_index + 1 < repeats and repeat_delay > 0.0:
			await get_tree().create_timer(repeat_delay, false).timeout


func _start_3310_fox_rain(attack_name: StringName, effect_config: Dictionary, serial: int) -> void:
	var speed := maxf(float(effect_config.get("speed", 420.0)), 1.0)
	var spread := float(effect_config.get("spread", 50.0))
	var launch_config := effect_config.duplicate(true)
	launch_config.erase("fox_rain")
	launch_config.erase("impact")
	launch_config["targeted"] = false
	launch_config["track_target"] = false
	launch_config["orient_to_motion"] = false
	launch_config["lifetime"] = 1.5
	for index in range(9):
		if not _late_attack_is_current(serial):
			return
		launch_config["spawn_position"] = global_position + Vector2((float(index) - 4.0) * spread, 0.0)
		launch_config["velocity"] = Vector2(0.0, -speed)
		_spawn_late_skill_effect(attack_name, launch_config, 0, 1)
		if index < 8:
			await get_tree().create_timer(0.08, false).timeout
	await get_tree().create_timer(1.36, false).timeout
	if not _late_attack_is_current(serial):
		return
	var target_data := _late_effect_target_data()
	var target_position: Vector2 = target_data["position"]
	var rain_config := effect_config.duplicate(true)
	rain_config.erase("fox_rain")
	rain_config["sequence"] = "effect3_2"
	rain_config["impact"] = "effect3_3"
	rain_config["targeted"] = false
	rain_config["track_target"] = false
	rain_config["orient_to_motion"] = false
	rain_config["lifetime"] = 1.5
	for index in range(9):
		rain_config["spawn_position"] = Vector2(
			target_position.x + (float(index) - 4.0) * spread, target_position.y - 520.0
		)
		rain_config["velocity"] = Vector2(0.0, speed)
		_spawn_late_skill_effect(attack_name, rain_config, 0, 1)


func _schedule_late_target_bursts(attack_name: StringName, effect_config: Dictionary, serial: int) -> void:
	var sequence := str(effect_config.get("target_burst_sequence", ""))
	var frames: Array = effect_config.get("target_burst_frames", []) as Array
	var offsets: Array = effect_config.get("target_burst_offsets", []) as Array
	if sequence.is_empty() or frames.is_empty():
		return
	for index in range(frames.size()):
		var offset := offsets[index] as Vector2 if index < offsets.size() else Vector2.ZERO
		_spawn_late_target_burst_after(
			float(frames[index]) / SOURCE_FPS, attack_name, effect_config, sequence, offset, serial
		)


func _spawn_late_target_burst_after(
	delay: float,
	attack_name: StringName,
	source_config: Dictionary,
	sequence: String,
	target_offset: Vector2,
	serial: int
) -> void:
	await get_tree().create_timer(delay, false).timeout
	if not _late_attack_is_current(serial):
		return
	var burst_config := source_config.duplicate(true)
	burst_config.erase("target_burst_sequence")
	burst_config.erase("target_burst_frames")
	burst_config.erase("target_burst_offsets")
	burst_config["sequence"] = sequence
	burst_config["follow_owner"] = false
	burst_config["targeted"] = false
	burst_config["track_target"] = false
	burst_config["orient_to_motion"] = false
	burst_config["speed"] = 0.0
	burst_config["lifetime"] = maxf(float(_seq_frame_count(_metadata_path(), sequence)) / SOURCE_FPS, 0.1)
	burst_config["spawn_position"] = (_late_effect_target_data()["position"] as Vector2) + target_offset
	_spawn_late_skill_effect(attack_name, burst_config, 0, 1)


func _nearest_target_position(origin: Vector2) -> Variant:
	if RoleProp == null:
		return null
	return RoleProp.get_nearest_monster_target_position(origin)


func _late_effect_target_data() -> Dictionary:
	var target_value: Variant = _nearest_target_position(global_position)
	var has_target := target_value is Vector2
	var raw_position: Vector2 = (
		target_value as Vector2
		if has_target
		else global_position + Vector2(100.0 if monster_direction else -100.0, 0.0)
	)
	var target_node: Node2D = null
	if has_target and RoleProp != null and RoleProp.source_player is Node2D:
		var source_player := RoleProp.source_player as Node2D
		if (
			is_instance_valid(source_player)
			and source_player.is_inside_tree()
			and source_player.global_position.distance_squared_to(raw_position) <= 4.0
		):
			target_node = source_player
	var aim_position := _target_hurt_rect(raw_position).get_center() if has_target else raw_position
	return {
		"has_target": has_target,
		"position": aim_position,
		"node": target_node,
		"offset": aim_position - target_node.global_position if target_node != null else Vector2.ZERO,
	}


func _spawn_late_skill_effect(
	attack_name: StringName, effect_config: Dictionary, repeat_index: int, repeat_count: int
) -> void:
	var metadata := _metadata_path()
	var sequence := str(effect_config.get("sequence", ""))
	var sequence_options: Array = effect_config.get("sequences", []) as Array
	if not sequence_options.is_empty():
		var sequence_index := mini(
			int(float(repeat_index) * float(sequence_options.size()) / float(maxi(repeat_count, 1))),
			sequence_options.size() - 1
		)
		sequence = str(sequence_options[sequence_index])
	var frame_count := _seq_frame_count(metadata, sequence)
	if sequence.is_empty() or frame_count <= 0:
		push_warning("Missing late monster effect %s:%s" % [monster_kind, sequence])
		return
	var target_data := _late_effect_target_data()
	var has_target := bool(target_data["has_target"])
	var target_position: Vector2 = target_data["position"]
	var target_node := target_data["node"] as Node2D
	var target_offset: Vector2 = target_data["offset"]
	var facing := 1.0 if target_position.x >= global_position.x else -1.0
	var local_offset: Vector2 = effect_config.get("offset", Vector2.ZERO)
	local_offset.x *= facing
	var spread := float(effect_config.get("spread", 0.0))
	var spread_offset := 0.0
	if repeat_count > 1 and not is_zero_approx(spread):
		spread_offset = (float(repeat_index) - float(repeat_count - 1) * 0.5) * spread
		local_offset.x += spread_offset
	var spawn_position: Vector2 = effect_config.get("spawn_position", global_position + local_offset)
	var speed := maxf(float(effect_config.get("speed", 0.0)), 0.0)
	var targeted := bool(effect_config.get("targeted", false))
	var velocity := Vector2.ZERO
	if effect_config.has("velocity"):
		velocity = effect_config["velocity"] as Vector2
	elif effect_config.has("spawn_above_target") and has_target and speed > 0.0:
		spawn_position = Vector2(
			target_position.x + spread_offset, target_position.y - float(effect_config["spawn_above_target"])
		)
		velocity = Vector2(0.0, speed)
	elif targeted and has_target and speed > 0.0:
		var aim_direction := spawn_position.direction_to(target_position)
		var angle_offsets: Array = effect_config.get("aim_angle_offsets", []) as Array
		if repeat_index < angle_offsets.size():
			aim_direction = aim_direction.rotated(deg_to_rad(float(angle_offsets[repeat_index])))
		velocity = aim_direction * speed
	elif speed > 0.0:
		velocity = Vector2(speed * facing, 0.0)
	var lifetime := maxf(float(effect_config.get("lifetime", 1.0)), 0.05)
	var follow_owner := bool(effect_config.get("follow_owner", false))
	var impact_sequence := str(effect_config.get("impact", ""))
	var impact_frame_count := _seq_frame_count(metadata, impact_sequence) if not impact_sequence.is_empty() else 0
	var orient_to_motion := bool(effect_config.get("orient_to_motion", targeted and speed > 0.0))
	var track_target := bool(effect_config.get("track_target", targeted and speed > 0.0)) and target_node != null
	var frames_path := _standard_body_frames_path()
	var projectile := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	var configured := (
		projectile
		. configure(
			{
				"owner": self,
				"position": spawn_position,
				"right": facing > 0.0,
				"hit_name": str(attack_name),
				"attack_data": _attack_entry(attack_name),
				"skill_name": "EastLate%d_%s" % [monster_kind, str(attack_name)],
				"visual_backend": WutaiMinghaiProjectile.VisualBackend.SPRITE_FRAMES,
				"frames_resource": frames_path,
				"frames_animation": sequence,
				"frame_count": frame_count,
				"frame_fps": SOURCE_FPS,
				"loop_visual": not follow_owner,
				"visual_faces_right": facing > 0.0 if orient_to_motion else true,
				"velocity": velocity,
				"orient_to_motion": orient_to_motion,
				"track_target": track_target,
				"target_node": target_node,
				"target_offset": target_offset,
				"follow_owner": follow_owner,
				"follow_owner_offset": local_offset,
				"lifetime": lifetime,
				"damage_duration": float(effect_config.get("damage_duration", lifetime)),
				"damage_pulse_interval": float(effect_config.get("damage_pulse_interval", 0.0)),
				"poll_overlaps_on_damage_pulse": bool(effect_config.get("poll_overlaps_on_damage_pulse", false)),
				"expire_on_hit": bool(effect_config.get("expire_on_hit", not impact_sequence.is_empty())),
				"max_hits": maxi(int(effect_config.get("max_hits", 1)), 1),
				"impact_visual_backend":
				(
					WutaiMinghaiProjectile.VisualBackend.SPRITE_FRAMES
					if impact_frame_count > 0
					else WutaiMinghaiProjectile.VisualBackend.NONE
				),
				"impact_frames_resource": frames_path if impact_frame_count > 0 else "",
				"impact_frames_animation": impact_sequence if impact_frame_count > 0 else "",
				"impact_frame_count": impact_frame_count,
				"impact_duration": float(impact_frame_count) / SOURCE_FPS,
				"finished_callback": effect_config.get("finished_callback", Callable()),
			}
		)
	)
	if not configured:
		projectile.queue_free()
		return
	bullet.add_child(projectile)


func _finish_3323_skill3(impact_position: Vector2) -> void:
	if not is_instance_valid(self) or not is_inside_tree():
		return
	var landing := impact_position
	var level_node := get_level_node()
	if level_node != null and level_node.has_method("_screen_starts") and level_node.has_method("_screen_rights"):
		var starts: Array = level_node.call("_screen_starts")
		var rights: Array = level_node.call("_screen_rights")
		for index in range(mini(starts.size(), rights.size())):
			var left := float(starts[index])
			var right := float(rights[index])
			if impact_position.x >= left and impact_position.x <= right:
				landing.x = clampf(impact_position.x, left + 100.0, right - 100.0)
				break
	landing.y -= 50.0
	landing.y = maxf(landing.y, 50.0)
	global_position = landing
	_3323_skill_y = landing.y
	_fixed_flight_y = landing.y
	_3323_skill_y_locked = false
	velocity = Vector2.ZERO
	no_grav = true
	_3323_skill3_invincible = false
	hurt_box.set_deferred("disabled", false)
	_special_attack_active = false
	is_attacking = false
	_active_attack_name = &""
	_disable_attack_box()
	_play_frames(&"wait")
	mr_player.play(&"wait")


func _late_attack_is_current(serial: int) -> bool:
	return is_instance_valid(self) and is_inside_tree() and not death() and serial == _attack_serial


func attack_target() -> void:
	if is_attacking or death() or not mr_player.has_animation(&"hit1"):
		return
	_attack_serial += 1
	var current_attack_serial := _attack_serial
	is_attacking = true
	var attack_name: StringName = StringName(_config.get("attack_animation", "hit1"))
	if not mr_player.has_animation(attack_name):
		attack_name = &"hit1"
	var official_candidates := _reachable_official_attacks()
	if monster_kind >= 3198 and OFFICIAL_SKILL_SCOPE.has(monster_kind):
		if official_candidates.is_empty():
			is_attacking = false
			have_target()
			return
		attack_name = official_candidates[_late_attack_index % official_candidates.size()]
		_late_attack_index += 1
	elif monster_kind == 3120:
		attack_name = _pick_3120_attack()
	elif monster_kind == 3182:
		attack_name = _pick_3182_attack()
		if attack_name.is_empty():
			is_attacking = false
			return
	elif monster_kind == 3161:
		var monkey_target_value: Variant = _nearest_target_position(global_position)
		var monkey_target_distance := (
			absf((monkey_target_value as Vector2).x - global_position.x) if monkey_target_value is Vector2 else INF
		)
		attack_name = _pick_3161_attack(monkey_target_distance)
		if attack_name.is_empty():
			is_attacking = false
			have_target()
			return
	elif monster_kind == 3179:
		var six_ear_target_value: Variant = _nearest_target_position(global_position)
		var six_ear_target_distance := (
			absf((six_ear_target_value as Vector2).x - global_position.x) if six_ear_target_value is Vector2 else INF
		)
		attack_name = _pick_3179_attack(six_ear_target_distance)
		if attack_name.is_empty():
			is_attacking = false
			have_target()
			return
	elif is_boss:
		var boss_attacks: Array[StringName] = []
		for candidate: StringName in [&"hit1", &"hit2", &"hit3"]:
			if mr_player.has_animation(candidate):
				boss_attacks.append(candidate)
		if not boss_attacks.is_empty():
			if monster_kind == 3125:
				attack_name = boss_attacks[_3125_attack_index % boss_attacks.size()]
				_3125_attack_index += 1
			else:
				attack_name = boss_attacks[randi_range(0, boss_attacks.size() - 1)]
	hit_name = str(attack_name)
	_active_attack_name = attack_name
	if monster_kind == 3323:
		_3323_skill_y = global_position.y
		_3323_skill_y_locked = true
		no_grav = true
		velocity.y = 0.0
	velocity = Vector2.ZERO
	_disable_attack_box()

	_play_frames(attack_name)
	mr_player.play(attack_name)
	if monster_kind == 3223:
		_start_3223_official_attack(attack_name)
	elif monster_kind == 3224 and attack_name == &"hit3":
		_start_3224_ground_shock(current_attack_serial)
	elif monster_kind == 3177 and attack_name == &"hit2":
		_spawn_ranged_effect_after_shot_frame(current_attack_serial)
	elif monster_kind == 3179:
		_start_3179_attack(attack_name, current_attack_serial)
	elif monster_kind == 3161:
		_start_3161_attack(attack_name, current_attack_serial)
	elif monster_kind == 3120 and attack_name == &"hit1":
		_start_3120_wind_blade(current_attack_serial)
	elif monster_kind == 3120 and attack_name == &"hit2":
		_start_3120_stone_throw(current_attack_serial)
	elif monster_kind == 3121 and attack_name == &"hit1":
		_start_3121_arrow_burst(current_attack_serial)
	elif monster_kind == 3136:
		_start_3136_attack(attack_name, current_attack_serial)
	elif monster_kind == 3182:
		_start_3182_attack(attack_name, current_attack_serial)
	elif LATE_SKILL_EFFECTS.has(_late_effect_key(attack_name)):
		_start_late_skill_effect(attack_name, current_attack_serial)

	if (
		(monster_kind == 3161 and attack_name == &"hit3")
		or (monster_kind == 3179 and attack_name == &"hit2")
		or (monster_kind == 3179 and attack_name == &"hit5")
		or (monster_kind == 3323 and attack_name == &"hit3")
		or (monster_kind == 3182 and attack_name == &"hit5")
	):
		while (
			is_instance_valid(self)
			and not death()
			and current_attack_serial == _attack_serial
			and _special_attack_active
		):
			await get_tree().process_frame
	else:
		await mr_player.animation_finished
	if is_instance_valid(self) and not death() and current_attack_serial == _attack_serial:
		_disable_attack_box()
		_play_frames(&"wait")
		is_attacking = false
		if monster_kind == 3323 and not _special_attack_active:
			_3323_skill_y_locked = false
		stop_move()


func _start_3223_official_attack(attack_name: StringName) -> void:
	match attack_name:
		&"hit1":
			_spawn_official_pulse_area(attack_name, [0.0, 170.0], 3, 0.534, 1.168)
		&"hit2":
			_spawn_3223_summon(3224, Vector2(100.0, -50.0))
		&"hit3":
			_spawn_3223_summon(3225, Vector2(100.0, -100.0))


func _spawn_3223_summon(summon_id: int, source_offset: Vector2) -> void:
	var existing_value: Variant = _3223_summons.get(summon_id, null)
	var existing: BaseMonster = null
	if typeof(existing_value) == TYPE_OBJECT and is_instance_valid(existing_value):
		existing = existing_value as BaseMonster
	if existing != null and is_instance_valid(existing) and not existing.death():
		return
	var scene := load("res://Scene/monster/monster_%d.tscn" % summon_id) as PackedScene
	var parent := get_parent()
	if scene == null or parent == null or not is_instance_valid(parent):
		return
	var summoned := scene.instantiate() as EastContinentMonster
	if summoned == null:
		return
	var facing := 1.0 if monster_direction else -1.0
	var bounds := _screen_bounds_3120()
	var spawn_position := global_position + Vector2(source_offset.x * facing, source_offset.y)
	spawn_position.x = clampf(spawn_position.x, bounds.x, bounds.y - 100.0)
	summoned.position = parent.to_local(spawn_position)
	summoned.set_meta("yellow_brow_owner", self)
	summoned.set_meta("hide_independent_drops", true)
	parent.add_child(summoned)
	_3223_summons[summon_id] = summoned


func _spawn_official_pulse_area(
	attack_name: StringName, scope: Array, hit_count: int, interval: float, duration: float
) -> WutaiMinghaiProjectile:
	var x_min := float(scope[0])
	var x_max := float(scope[1])
	var y_min := float(scope[2]) if scope.size() >= 4 else -120.0
	var y_max := float(scope[3]) if scope.size() >= 4 else 20.0
	var facing := 1.0 if monster_direction else -1.0
	var area := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	var configured := (
		area
		. configure(
			{
				"owner": self,
				"position": global_position + Vector2((x_min + x_max) * 0.5 * facing, (y_min + y_max) * 0.5),
				"right": facing > 0.0,
				"hit_name": str(attack_name),
				"attack_data": _attack_entry(attack_name),
				"skill_name": "East%d_%sPulse" % [monster_kind, str(attack_name)],
				"visual_backend": WutaiMinghaiProjectile.VisualBackend.NONE,
				"collision_size": Vector2(maxf(x_max - x_min, 1.0), maxf(y_max - y_min, 1.0)),
				"lifetime": duration + 0.05,
				"damage_duration": duration,
				"damage_pulse_interval": interval,
				"poll_overlaps_on_damage_pulse": true,
				"expire_on_hit": false,
				"max_hits": hit_count,
			}
		)
	)
	if not configured:
		area.free()
		return null

	var pulse_hit_box := area.get_node("middle/HitBox") as Area2D
	pulse_hit_box.collision_layer = 0
	pulse_hit_box.collision_mask = 0
	bullet.add_child(area)
	return area


func _start_3224_ground_shock(serial: int) -> void:
	await get_tree().create_timer(10.0 / SOURCE_FPS, false).timeout
	if not _late_attack_is_current(serial):
		return
	var target_value: Variant = RoleProp.get_nearest_monster_target_position(global_position)
	if target_value is Vector2:
		global_position.x = (target_value as Vector2).x
	_spawn_official_pulse_area(&"hit3", [-220.0, 220.0], 2, 0.234, 0.35)


func _start_3182_attack(attack_name: StringName, serial: int) -> void:
	match attack_name:
		&"hit1":
			_spawn_3182_destroying_rip(serial)
		&"hit2":
			_spawn_3182_tracking_needles(serial)
		&"hit3":
			_spawn_3182_bone_barrage(serial)
		&"hit5":
			_start_3182_rain_combo(serial)


func _spawn_3182_destroying_rip(serial: int) -> void:
	await get_tree().create_timer(8.0 / SOURCE_FPS, false).timeout
	if not _attack_3182_is_current(serial):
		return
	var direction := 1.0 if monster_direction else -1.0
	var area := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	var configured := (
		area
		. configure(
			{
				"owner": self,
				"position": global_position + Vector2(75.0 * direction, 0.0),
				"right": direction > 0.0,
				"hit_name": "hit1",
				"attack_data": _attack_entry(&"hit1"),
				"skill_name": "RainAncestorDestroyingRip",
				"visual_backend": WutaiMinghaiProjectile.VisualBackend.NONE,
				"collision_size": Vector2(550.0, 12000.0),
				"damage_enabled": true,
				"damage_duration": 0.2,
				"lifetime": 0.25,
				"expire_on_hit": false,
				"max_hits": 1,
			}
		)
	)
	if not configured:
		area.free()
		return
	bullet.add_child(area)


func _spawn_3182_tracking_needles(serial: int) -> void:
	for delay_seconds: float in [0.66, 1.32]:
		_spawn_3182_tracking_needle_after(delay_seconds, serial)


func _spawn_3182_tracking_needle_after(delay_seconds: float, serial: int) -> void:
	await get_tree().create_timer(delay_seconds, false).timeout
	if not _attack_3182_is_current(serial):
		return
	var target := RoleProp.source_player as Node2D
	if target == null or not is_instance_valid(target):
		return
	var direction := 1.0 if monster_direction else -1.0
	var spawn_position := global_position + Vector2(125.0 * direction, -100.0)
	var aim_position := target.global_position + Vector2(0.0, -60.0)
	var projectile := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	var configured := (
		projectile
		. configure(
			{
				"owner": self,
				"position": spawn_position,
				"right": aim_position.x >= spawn_position.x,
				"hit_name": "hit2",
				"attack_data": _attack_entry(&"hit2"),
				"skill_name": "RainAncestorRainNeedle",
				"visual_backend": WutaiMinghaiProjectile.VisualBackend.SPRITE_FRAMES,
				"frames_resource": RAIN_ANCESTOR_FRAMES,
				"frames_animation": "effect2_1",
				"frame_fps": SOURCE_FPS,
				"loop_visual": true,
				"velocity": spawn_position.direction_to(aim_position) * 720.0,
				"lifetime": 2.0,
				"damage_duration": 2.0,
				"expire_on_hit": false,
				"max_hits": 1,
			}
		)
	)
	if not configured:
		projectile.free()
		return
	bullet.add_child(projectile)


func _spawn_3182_bone_barrage(serial: int) -> void:
	for index in range(RAIN_ANCESTOR_BONE_POINTS.size()):
		_run_3182_bone_needle(index, serial)


func _run_3182_bone_needle(index: int, serial: int) -> void:
	var charge_delay := 0.297 + float(index) * 0.33
	var fire_delay := 1.485 + float(index) * 0.495
	await get_tree().create_timer(charge_delay, false).timeout
	if not _attack_3182_is_current(serial):
		return
	var facing := 1.0 if monster_direction else -1.0
	var source_point: Vector2 = RAIN_ANCESTOR_BONE_POINTS[index]
	var spawn_position := global_position + Vector2(source_point.x * facing, source_point.y)
	var charge := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	var configured := (
		charge
		. configure(
			{
				"owner": self,
				"position": spawn_position,
				"right": facing > 0.0,
				"hit_name": "hit3",
				"attack_data": _attack_entry(&"hit3"),
				"skill_name": "RainAncestorBoneCharge",
				"visual_backend": WutaiMinghaiProjectile.VisualBackend.SPRITE_FRAMES,
				"frames_resource": RAIN_ANCESTOR_FRAMES,
				"frames_animation": "effect3_1",
				"frame_fps": SOURCE_FPS,
				"loop_visual": true,
				"damage_enabled": false,
				"lifetime": maxf(fire_delay - charge_delay, 0.05),
			}
		)
	)
	if not configured:
		charge.free()
	else:
		bullet.add_child(charge)
	await get_tree().create_timer(maxf(fire_delay - charge_delay, 0.0), false).timeout
	if not _attack_3182_is_current(serial):
		return
	var target_value: Variant = _nearest_target_position(spawn_position)
	if target_value == null:
		return
	var target_position: Vector2 = target_value
	var horizontal_speed := (target_position.x - spawn_position.x) / 2.0
	var needle := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	var needle_configured := (
		needle
		. configure(
			{
				"owner": self,
				"position": spawn_position,
				"right": horizontal_speed >= 0.0,
				"hit_name": "hit3",
				"attack_data": _attack_entry(&"hit3"),
				"skill_name": "RainAncestorBoneNeedle",
				"visual_backend": WutaiMinghaiProjectile.VisualBackend.SPRITE_FRAMES,
				"frames_resource": RAIN_ANCESTOR_FRAMES,
				"frames_animation": "effect3_1",
				"frame_fps": SOURCE_FPS,
				"loop_visual": true,
				"velocity": Vector2(horizontal_speed, -660.0),
				"acceleration": Vector2(0.0, 980.0),
				"orient_to_motion": true,
				"motion_rotation_offset": PI,
				"lifetime": 2.0,
				"damage_duration": 2.0,
				"expire_on_hit": false,
				"max_hits": 1,
			}
		)
	)
	if not needle_configured:
		needle.free()
		return
	bullet.add_child(needle)


func _start_3182_rain_combo(serial: int) -> void:
	_special_attack_active = true
	await get_tree().create_timer(1.5, false).timeout
	if not _attack_3182_is_current(serial):
		_special_attack_active = false
		return
	_disable_attack_box()
	_play_frames(&"hit4")
	mr_player.play(&"hit4")
	_3182_rain_serial += 1
	_run_3182_rain(_3182_rain_serial)
	await mr_player.animation_finished
	if is_instance_valid(self) and serial == _attack_serial:
		_special_attack_active = false


func _run_3182_rain(rain_serial: int) -> void:
	var weather := RAIN_ANCESTOR_WEATHER_SCRIPT.new() as RainAncestorWeather
	weather.configure(global_position, 1.0 if monster_direction else -1.0, 10.0)
	var level_node := get_level_node()
	if level_node != null:
		level_node.add_child(weather)
	else:
		bullet.add_child(weather)
	for pulse in range(5):
		await get_tree().create_timer(2.0, false).timeout
		if not is_instance_valid(self) or death() or rain_serial != _3182_rain_serial:
			return
		var player := RoleProp.source_player as BaseHero
		if player != null and is_instance_valid(player) and not player.is_death:
			var rain_damage := maxi(1, roundi(float(RoleProp.roleprop.SHp) * 0.01) + 142)
			player.effect_reducehp(rain_damage, "real")
		cure_hp(maxi(1, roundi(float(max_hp) * 0.018)))


func _attack_3182_is_current(serial: int) -> bool:
	return is_instance_valid(self) and is_inside_tree() and not death() and serial == _attack_serial


func _start_3136_attack(attack_name: StringName, serial: int) -> void:
	await get_tree().create_timer(6.0 / SOURCE_FPS, false).timeout
	if not is_instance_valid(self) or not is_inside_tree() or death() or serial != _attack_serial:
		return
	var target_value: Variant = _nearest_target_position(global_position)
	if target_value == null:
		return
	var target_position: Vector2 = target_value
	var effect := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	var effect_config := {
		"owner": self,
		"right": target_position.x >= global_position.x,
		"hit_name": str(attack_name),
		"attack_data": _attack_entry(attack_name),
		"visual_backend": WutaiMinghaiProjectile.VisualBackend.SPRITE_FRAMES,
		"frames_resource": AOLAIGUO_BOSS_FRAMES,
		"frame_fps": SOURCE_FPS,
		"loop_visual": false,
		"expire_on_hit": false,
		"max_hits": 1,
	}
	if attack_name == &"hit2":
		var projectile_anchor := _seq_reg_anchor(AOLAIGUO_BOSS_METADATA, "effect2_1")
		var projectile_position := Vector2(global_position.x, target_position.y - projectile_anchor.y)
		var direction := projectile_position.direction_to(target_position)
		(
			effect_config
			. merge(
				{
					"position": projectile_position,
					"skill_name": "AolaiguoArrayProjectile",
					"frames_animation": "effect2_1",
					"loop_visual": true,
					"velocity": direction * 360.0,
					"lifetime": 2.0,
					"damage_duration": 2.0,
				},
				true
			)
		)
	elif attack_name == &"hit3":
		var burst_anchor := _seq_reg_anchor(AOLAIGUO_BOSS_METADATA, "effect5_1")
		(
			effect_config
			. merge(
				{
					"position": Vector2(target_position.x, target_position.y - burst_anchor.y),
					"skill_name": "AolaiguoArrayBurst",
					"frames_animation": "effect5_1",
					"lifetime": 24.0 / SOURCE_FPS,
					"hit_delay": 8.0 / SOURCE_FPS,
					"damage_duration": 12.0 / SOURCE_FPS,
				},
				true
			)
		)
	else:
		var pillar_anchor := _seq_reg_anchor(AOLAIGUO_BOSS_METADATA, "effect1_1")
		(
			effect_config
			. merge(
				{
					"position": Vector2(target_position.x, target_position.y - pillar_anchor.y),
					"skill_name": "AolaiguoArrayPillar",
					"frames_animation": "effect1_1",
					"lifetime": 15.0 / SOURCE_FPS,
					"hit_delay": 5.0 / SOURCE_FPS,
					"damage_duration": 8.0 / SOURCE_FPS,
				},
				true
			)
		)
	if not effect.configure(effect_config):
		effect.free()
		return
	bullet.add_child(effect)


func _spawn_ranged_effect_after_shot_frame(serial: int) -> void:
	if not is_inside_tree():
		return
	await get_tree().create_timer(21.0 / SOURCE_FPS, false).timeout
	if not is_instance_valid(self) or not is_inside_tree() or death() or serial != _attack_serial:
		return
	var direction := 1.0 if monster_direction else -1.0
	var target: Variant = _nearest_target_position(global_position)
	if target != null:
		direction = 1.0 if float(target.x) >= global_position.x else -1.0
	var projectile := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	var configured := (
		projectile
		. configure(
			{
				"owner": self,
				"position": global_position + Vector2(70.0 * direction, -34.0),
				"right": direction > 0.0,
				"hit_name": "hit2",
				"attack_data": _attack_entry(&"hit2"),
				"skill_name": "MushroomElderEffect2_1",
				"visual_backend": WutaiMinghaiProjectile.VisualBackend.FRAME_SEQUENCE,
				"frame_root": RANGED_EFFECT_ROOT,
				"frame_count": 10,
				"frame_fps": SOURCE_FPS,
				"loop_visual": true,
				"velocity": Vector2(120.0 * direction, 0.0),
				"lifetime": 1.2,
				"damage_duration": 1.2,
				"expire_on_hit": false,
				"max_hits": 1,
			}
		)
	)
	if not configured:
		projectile.free()
		return
	bullet.add_child(projectile)


func _start_3121_arrow_burst(serial: int) -> void:
	await get_tree().create_timer(16.0 / SOURCE_FPS, false).timeout
	if not is_instance_valid(self) or not is_inside_tree() or death() or serial != _attack_serial:
		return
	var diagonal := 240.0 / sqrt(2.0)
	var velocities: Array[Vector2] = [
		Vector2(diagonal, -diagonal),
		Vector2(0.0, -240.0),
		Vector2(-diagonal, -diagonal),
		Vector2(-240.0, 0.0),
	]

	var direction_scale := -1.0 if monster_direction else 1.0
	for base_velocity: Vector2 in velocities:
		var arrow_velocity := Vector2(base_velocity.x * direction_scale, base_velocity.y)
		var projectile := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
		var configured := (
			projectile
			. configure(
				{
					"owner": self,
					"position": global_position + Vector2(0.0, -51.0),
					"right": true,
					"hit_name": "hit1",
					"attack_data": _attack_entry(&"hit1"),
					"skill_name": "FlowerArrow1",
					"visual_backend": WutaiMinghaiProjectile.VisualBackend.FRAME_SEQUENCE,
					"frame_root": FLOWER_ARROW_ROOT,
					"frame_count": 8,
					"frame_fps": SOURCE_FPS,
					"loop_visual": true,
					"velocity": arrow_velocity,
					"orient_to_motion": true,
					"lifetime": 0.5,
					"damage_duration": 0.5,
					"expire_on_hit": true,
					"max_hits": 1,
				}
			)
		)
		if not configured:
			projectile.free()
			continue
		bullet.add_child(projectile)


func _start_3161_attack(attack_name: StringName, serial: int) -> void:
	match attack_name:
		&"hit1":
			_spawn_official_pulse_area(&"hit1", [0.0, 150.0], 8, 0.134, 0.95)
		&"hit2":
			_start_3161_effect2(serial)
		&"hit3":
			_start_3161_effect3(serial)


func _start_3179_attack(attack_name: StringName, serial: int) -> void:
	match attack_name:
		&"hit1":
			_spawn_official_pulse_area(&"hit1", [0.0, 120.0], 4, 0.334, 1.01)
		&"hit2":
			_start_3179_fire_dash(serial)
		&"hit3":
			_spawn_official_pulse_area(&"hit3", [-170.0, 170.0], 3, 0.167, 0.534)
		&"hit4":
			_start_3179_blood_eye(serial)
		&"hit5":
			_start_six_ear_dash(serial)


func _start_3179_fire_dash(serial: int) -> void:
	_special_attack_active = true
	var dash_ground_y := global_position.y
	var dash_no_grav_before := no_grav
	_3179_fire_dash_until_msec = 0
	no_grav = true
	velocity.x = 0.0
	velocity.y = 0.0
	await get_tree().create_timer(3.0 / SOURCE_FPS, false).timeout
	if not is_instance_valid(self) or death() or serial != _attack_serial:
		_3179_fire_dash_until_msec = 0
		velocity.x = 0.0
		velocity.y = 0.0
		no_grav = dash_no_grav_before
		_3179_fire_dash_invincible = false
		hurt_box.set_deferred("disabled", false)
		_special_attack_active = false
		return
	var direction := 1.0 if monster_direction else -1.0
	_3179_fire_dash_until_msec = Time.get_ticks_msec() + 334
	_3179_fire_dash_invincible = true
	hurt_box.set_deferred("disabled", true)

	velocity.x = direction * 1200.0
	var dash_elapsed := 0.0
	while is_instance_valid(self) and not death() and serial == _attack_serial and dash_elapsed < 0.334:
		global_position.y = dash_ground_y
		velocity.y = 0.0
		await get_tree().physics_frame
		dash_elapsed += get_physics_process_delta_time()
	if is_instance_valid(self) and serial == _attack_serial:
		velocity.x = 0.0
		velocity.y = 0.0
		global_position.y = dash_ground_y
		no_grav = dash_no_grav_before
		_3179_fire_dash_until_msec = 0
		_3179_fire_dash_invincible = false
		hurt_box.set_deferred("disabled", false)
		_3179_fire_dash_cooldown_until_msec = Time.get_ticks_msec() + 500
	_special_attack_active = false


func _start_3179_blood_eye(_serial: int) -> void:
	_3179_blood_eye_serial += 1
	var buff_serial := _3179_blood_eye_serial
	_3179_blood_eye_base_ebol = ebol

	ebol = maxf(ebol, 0.6)
	await get_tree().create_timer(10.0, false).timeout
	if is_instance_valid(self) and buff_serial == _3179_blood_eye_serial:
		ebol = _3179_blood_eye_base_ebol


func _start_six_ear_dash(serial: int) -> void:
	_special_attack_active = true
	_3179_fire_slash_invincible = true
	_3179_fire_slash_no_grav_before = no_grav
	no_grav = true
	velocity = Vector2.ZERO
	hurt_box.set_deferred("disabled", true)
	await get_tree().create_timer(5.0 / SOURCE_FPS, false).timeout
	if not is_instance_valid(self) or death() or serial != _attack_serial:
		_3179_fire_slash_invincible = false
		no_grav = _3179_fire_slash_no_grav_before
		hurt_box.set_deferred("disabled", false)
		_special_attack_active = false
		return
	var direction := 1.0 if monster_direction else -1.0
	var dash_spawn := global_position + Vector2(177.0 * direction, -95.0)
	var dash_velocity := Vector2(direction * 150.0, 0.0)
	var dash_lifetime := 31.0 / SOURCE_FPS
	var dash := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	var configured := (
		dash
		. configure(
			{
				"owner": self,
				"position": dash_spawn,
				"right": direction > 0.0,
				"hit_name": "hit5",
				"attack_data": _attack_entry_with_multiplier(&"hit5", 0.1, [21, 33]),
				"skill_name": "SixEarEffect5_1",
				"visual_backend": WutaiMinghaiProjectile.VisualBackend.FRAME_SEQUENCE,
				"frame_root": SIX_EAR_DASH_ROOT,
				"frame_count": 31,
				"frame_fps": SOURCE_FPS,
				"loop_visual": false,
				"velocity": dash_velocity,
				"lifetime": dash_lifetime,
				"damage_duration": dash_lifetime,
				"damage_pulse_interval": 0.1,
				"poll_overlaps_on_damage_pulse": true,
				"expire_on_hit": false,
				"max_hits": 11,
			}
		)
	)
	if not configured:
		dash.free()
	else:
		bullet.add_child(dash)
	await get_tree().create_timer(dash_lifetime, false).timeout
	if not is_instance_valid(self) or death() or serial != _attack_serial:
		_3179_fire_slash_invincible = false
		no_grav = _3179_fire_slash_no_grav_before
		hurt_box.set_deferred("disabled", false)
		_special_attack_active = false
		return
	var impact_position := dash_spawn + dash_velocity * dash_lifetime
	if is_instance_valid(dash):
		impact_position = dash.global_position
	velocity = Vector2.ZERO
	global_position = impact_position
	_spawn_six_ear_impact(impact_position, direction)


func _spawn_six_ear_impact(spawn_position: Vector2, direction: float) -> void:
	var impact := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	var configured := (
		impact
		. configure(
			{
				"owner": self,
				"position": spawn_position,
				"right": direction > 0.0,
				"hit_name": "hit5",
				"attack_data": _attack_entry_with_multiplier(&"hit5", 1.0, [80, 120]),
				"skill_name": "SixEarEffect51",
				"visual_backend": WutaiMinghaiProjectile.VisualBackend.FRAME_SEQUENCE,
				"frame_root": SIX_EAR_IMPACT_ROOT,
				"frame_count": 17,
				"frame_fps": SOURCE_FPS,
				"loop_visual": false,
				"lifetime": 17.0 / SOURCE_FPS,
				"damage_duration": 17.0 / SOURCE_FPS,
				"expire_on_hit": false,
				"max_hits": 1,
				"finished_callback": Callable(self, "_finish_six_ear_impact"),
			}
		)
	)
	if not configured:
		impact.free()
		_finish_six_ear_impact(spawn_position)
		return
	bullet.add_child(impact)


func _finish_six_ear_impact(_position: Vector2) -> void:
	_3179_fire_slash_invincible = false
	no_grav = _3179_fire_slash_no_grav_before
	velocity = Vector2.ZERO
	hurt_box.set_deferred("disabled", false)
	_special_attack_active = false


func _start_3161_effect2(serial: int) -> void:
	await get_tree().create_timer(21.0 / SOURCE_FPS, false).timeout
	if not is_instance_valid(self) or death() or serial != _attack_serial:
		return
	var target: Variant = _nearest_target_position(global_position)
	var spawn_position := global_position
	if target != null:
		spawn_position.x = float(target.x)
	var effect := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	var configured := (
		effect
		. configure(
			{
				"owner": self,
				"position": spawn_position,
				"right": monster_direction,
				"hit_name": "hit2",
				"attack_data": _attack_entry(&"hit2"),
				"skill_name": "WhiteApeEffect2_1",
				"visual_backend": WutaiMinghaiProjectile.VisualBackend.FRAME_SEQUENCE,
				"frame_root": MONKEY_EFFECT2_ROOT,
				"frame_count": 148,
				"frame_fps": SOURCE_FPS,
				"loop_visual": false,
				"lifetime": 148.0 / SOURCE_FPS,
				"damage_duration": 148.0 / SOURCE_FPS,
				"expire_on_hit": false,
				"max_hits": 1,
			}
		)
	)
	if not configured:
		effect.free()
		return
	bullet.add_child(effect)


func _start_3161_effect3(serial: int) -> void:
	_special_attack_active = true
	var dash_ground_y := global_position.y
	_3161_dash_ground_y = dash_ground_y
	_3161_dash_no_grav_before = no_grav
	no_grav = true
	velocity.y = 0.0
	await get_tree().create_timer(1.0 / SOURCE_FPS, false).timeout
	if not is_instance_valid(self) or death() or serial != _attack_serial:
		_special_attack_active = false
		return
	var effect := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	var direction := 1.0 if monster_direction else -1.0
	var configured := (
		effect
		. configure(
			{
				"owner": self,
				"position": global_position + Vector2(0.0, -60.0),
				"right": monster_direction,
				"hit_name": "hit3",
				"attack_data": _attack_entry(&"hit3"),
				"skill_name": "WhiteApeEffect3_1",
				"visual_backend": WutaiMinghaiProjectile.VisualBackend.FRAME_SEQUENCE,
				"frame_root": MONKEY_EFFECT3_1_ROOT,
				"frame_count": 2,
				"frame_fps": SOURCE_FPS,
				"loop_visual": true,
				"velocity": Vector2(direction * 1200.0, 0.0),
				"lifetime": 0.5,
				"damage_enabled": true,
				"expire_on_hit": false,
				"damage_duration": 0.5,
				"damage_pulse_interval": 0.05,
				"poll_overlaps_on_damage_pulse": true,
				"max_hits": 1,
				"finished_callback": Callable(self, "_spawn_3161_effect3_impact"),
			}
		)
	)
	if not configured:
		effect.free()
		_finish_3161_special(global_position)
		return
	bullet.add_child(effect)

	while (
		is_instance_valid(self)
		and serial == _attack_serial
		and is_instance_valid(effect)
		and not effect.is_queued_for_deletion()
	):
		global_position.x = effect.global_position.x
		global_position.y = dash_ground_y
		velocity.y = 0.0
		await get_tree().process_frame
	if is_instance_valid(self) and serial == _attack_serial:
		global_position.y = dash_ground_y
		velocity.y = 0.0


func _spawn_3161_effect3_impact(spawn_position: Vector2) -> void:
	if not is_instance_valid(self) or death():
		_special_attack_active = false
		return
	spawn_position.y = global_position.y
	var effect := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	var configured := (
		effect
		. configure(
			{
				"owner": self,
				"position": spawn_position,
				"right": monster_direction,
				"hit_name": "hit3",
				"attack_data": _attack_entry(&"hit3"),
				"skill_name": "WhiteApeEffect3_2",
				"visual_backend": WutaiMinghaiProjectile.VisualBackend.FRAME_SEQUENCE,
				"frame_root": MONKEY_EFFECT3_2_ROOT,
				"frame_count": 10,
				"frame_fps": SOURCE_FPS,
				"loop_visual": false,
				"lifetime": 10.0 / SOURCE_FPS,
				"damage_duration": 10.0 / SOURCE_FPS,
				"expire_on_hit": false,
				"max_hits": 1,
				"finished_callback": Callable(self, "_finish_3161_special"),
			}
		)
	)
	if not configured:
		effect.free()
		_finish_3161_special(spawn_position)
		return
	bullet.add_child(effect)


func _finish_3161_special(_position: Vector2) -> void:
	global_position.y = _3161_dash_ground_y
	velocity.y = 0.0
	no_grav = _3161_dash_no_grav_before
	_special_attack_active = false


func _start_3120_stone_throw(serial: int) -> void:
	await get_tree().create_timer(float(SAND_BOSS_STONE_FRAME) / SOURCE_FPS, false).timeout
	if not is_instance_valid(self) or not is_inside_tree() or death() or serial != _attack_serial:
		return
	var target: Variant = _nearest_target_position(global_position)
	if target == null:
		return
	var target_position: Vector2 = target
	var direction := 1.0 if target_position.x >= global_position.x else -1.0

	target_position.x += direction * 600.0
	var spawn_position := global_position + Vector2(60.0 * direction, -34.0)
	var drop := maxf(target_position.y - spawn_position.y, 0.0)

	var discriminant := SAND_BOSS_STONE_SPEED_Y * SAND_BOSS_STONE_SPEED_Y + 2.0 * SAND_BOSS_STONE_GRAVITY * drop
	var flight := clampf(
		(-SAND_BOSS_STONE_SPEED_Y + sqrt(discriminant)) / SAND_BOSS_STONE_GRAVITY, 0.2, SAND_BOSS_STONE_LIFETIME
	)
	var horizontal := target_position.x - spawn_position.x
	var stone := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	var configured := (
		stone
		. configure(
			{
				"owner": self,
				"position": spawn_position,
				"right": horizontal >= 0.0,
				"hit_name": "hit2",
				"attack_data": _attack_entry(&"hit2"),
				"skill_name": "SandBossStoneThrow",
				"visual_backend": WutaiMinghaiProjectile.VisualBackend.FRAME_SEQUENCE,
				"frame_root": SAND_BOSS_STONE_ROOT,
				"frame_count": 2,
				"frame_fps": SOURCE_FPS,
				"loop_visual": true,
				"velocity": Vector2(horizontal / flight, SAND_BOSS_STONE_SPEED_Y),
				"acceleration": Vector2(0.0, SAND_BOSS_STONE_GRAVITY),
				"lifetime": flight,
				"damage_duration": flight,
				"expire_on_hit": false,
				"max_hits": 1,
				"finished_callback": Callable(self, "_spawn_3120_dust"),
			}
		)
	)
	if not configured:
		stone.free()
		return
	bullet.add_child(stone)


func _spawn_3120_dust(spawn_position: Vector2) -> void:
	if not is_instance_valid(self) or death():
		return
	var direction := 1.0 if monster_direction else -1.0
	var dust := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	var configured := (
		dust
		. configure(
			{
				"owner": self,
				"position": spawn_position,
				"right": direction > 0.0,
				"hit_name": "hit2",
				"attack_data": _attack_entry(&"hit2"),
				"skill_name": "SandBossStoneImpact",
				"visual_backend": WutaiMinghaiProjectile.VisualBackend.FRAME_SEQUENCE,
				"frame_root": SAND_BOSS_DUST_ROOT,
				"frame_count": SAND_BOSS_DUST_COUNT,
				"frame_fps": SOURCE_FPS,
				"loop_visual": false,
				"lifetime": float(SAND_BOSS_DUST_COUNT) / SOURCE_FPS,
				"damage_duration": float(SAND_BOSS_DUST_COUNT) / SOURCE_FPS,
				"expire_on_hit": false,
				"max_hits": 1,
			}
		)
	)
	if not configured:
		dust.free()
		return
	bullet.add_child(dust)


func _start_3120_wind_blade(serial: int) -> void:
	await get_tree().create_timer(float(SAND_BOSS_WIND_FRAME) / SOURCE_FPS, false).timeout
	if not is_instance_valid(self) or not is_inside_tree() or death() or serial != _attack_serial:
		return
	var direction := 1.0 if monster_direction else -1.0
	var wind := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	var configured := (
		wind
		. configure(
			{
				"owner": self,
				"position": global_position + Vector2(SAND_BOSS_WIND_OFFSET.x * direction, SAND_BOSS_WIND_OFFSET.y),
				"right": direction > 0.0,
				"hit_name": "hit1",
				"attack_data": _attack_entry(&"hit1"),
				"skill_name": "SandBossWindBlade",
				"visual_backend": WutaiMinghaiProjectile.VisualBackend.FRAME_SEQUENCE,
				"frame_root": SAND_BOSS_WIND_ROOT,
				"frame_count": 29,
				"frame_fps": SOURCE_FPS,
				"loop_visual": false,
				"visual_offset": SAND_BOSS_WIND_VISUAL_OFFSET,
				"velocity": Vector2(SAND_BOSS_WIND_SPEED * direction, 0.0),
				"lifetime": SAND_BOSS_WIND_LIFETIME,
				"damage_duration": SAND_BOSS_WIND_LIFETIME,
				"hit_interval": SAND_BOSS_WIND_HIT_INTERVAL,
				"max_hits": SAND_BOSS_WIND_MAX_HITS,
				"collision_size": SAND_BOSS_WIND_COLLISION_SIZE,
				"collision_offset": SAND_BOSS_WIND_COLLISION_OFFSET,
				"expire_on_hit": false,
			}
		)
	)
	if not configured:
		wind.free()
		return
	bullet.add_child(wind)


func _add_boss_protect_from_hit(source: Node) -> void:
	var was_active := boss_protect_active
	super._add_boss_protect_from_hit(source)
	if monster_kind == 3120 and not was_active and boss_protect_active:
		_start_3120_protect_teleport()
	elif monster_kind == 3161 and not was_active and boss_protect_active:
		_start_3161_protect_counter()


func _start_3161_protect_counter() -> void:
	_attack_serial += 1
	var serial := _attack_serial
	_special_attack_active = true
	is_attacking = true
	velocity = Vector2.ZERO
	hit_name = "hit4"
	_active_attack_name = &"hit4"
	_disable_attack_box()
	_play_frames(&"hit4")
	mr_player.play(&"hit4")

	_spawn_official_pulse_area(&"hit4", [0.0, 230.0], 1, 0.0, 0.2)
	await mr_player.animation_finished
	if not is_instance_valid(self) or death() or serial != _attack_serial:
		return
	_special_attack_active = false
	is_attacking = false
	_active_attack_name = &""
	_play_frames(&"wait")
	stop_move()


func _start_3120_protect_teleport() -> void:
	_3120_protect_serial += 1
	var serial := _3120_protect_serial
	_special_attack_active = true
	velocity = Vector2.ZERO
	is_attacking = false
	monster_dir.visible = false
	var hide_effect := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	var configured := (
		hide_effect
		. configure(
			{
				"owner": self,
				"position": global_position,
				"right": monster_direction,
				"hit_name": "protectSkill",
				"attack_data": {},
				"skill_name": "SandBossProtectHide",
				"visual_backend": WutaiMinghaiProjectile.VisualBackend.FRAME_SEQUENCE,
				"frame_root": "res://Art/monster/game_4_special_effect/effect_3120/effect3",
				"frame_count": 16,
				"frame_fps": SOURCE_FPS,
				"loop_visual": false,
				"damage_enabled": false,
				"lifetime": 16.0 / SOURCE_FPS,
			}
		)
	)
	if configured:
		bullet.add_child(hide_effect)
	else:
		hide_effect.free()
	await get_tree().create_timer(SAND_BOSS_PROTECT_DELAY, false).timeout
	if not is_instance_valid(self) or not is_inside_tree() or death() or serial != _3120_protect_serial:
		return
	var bounds := _screen_bounds_3120()
	var move_left := global_position.x >= (bounds.x + bounds.y) * 0.5
	global_position.x = bounds.x + 50.0 if move_left else bounds.y - 50.0
	monster_dir.scale.x = -1.0 if move_left else 1.0
	var appear_effect := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	var appear_configured := (
		appear_effect
		. configure(
			{
				"owner": self,
				"position": global_position,
				"right": not move_left,
				"hit_name": "protectSkill",
				"attack_data": {},
				"skill_name": "SandBossProtectAppear",
				"visual_backend": WutaiMinghaiProjectile.VisualBackend.FRAME_SEQUENCE,
				"frame_root": "res://Art/monster/game_4_special_effect/effect_3120/effect3_1",
				"frame_count": 6,
				"frame_fps": SOURCE_FPS,
				"loop_visual": false,
				"damage_enabled": false,
				"lifetime": 6.0 / SOURCE_FPS,
			}
		)
	)
	if appear_configured:
		bullet.add_child(appear_effect)
	else:
		appear_effect.free()
	await get_tree().create_timer(SAND_BOSS_PROTECT_REAPPEAR_DELAY, false).timeout
	if not is_instance_valid(self) or death() or serial != _3120_protect_serial:
		return
	monster_dir.visible = true
	_special_attack_active = false


func _screen_bounds_3120() -> Vector2:
	var level_node := get_level_node()
	if level_node != null and level_node.has_method("_screen_starts") and level_node.has_method("_screen_rights"):
		var starts: Array = level_node.call("_screen_starts")
		var rights: Array = level_node.call("_screen_rights")
		for index in range(mini(starts.size(), rights.size())):
			if global_position.x >= float(starts[index]) and global_position.x <= float(rights[index]):
				return Vector2(float(starts[index]), float(rights[index]))
	return Vector2(0.0, 1200.0)


func _attack_entry(attack_name: StringName) -> Dictionary:
	return (
		obj_attack_dict
		. get(
			str(attack_name),
			{
				"power": attack_in,
				"hurtBack": [-4, -2],
				"attackKind": "physics",
				"HitProtect": 90,
			}
		)
		. duplicate(true)
	)


func _attack_entry_with_multiplier(
	attack_name: StringName, multiplier: float, source_target_move: Array = []
) -> Dictionary:
	var entry := _attack_entry(attack_name)
	entry["power"] = maxi(1, roundi(float(attack_in) * multiplier))
	if not source_target_move.is_empty():
		entry["sourceTargetMove"] = source_target_move.duplicate()
	return entry


func get_ice_effect_offset() -> Vector2:
	return Vector2(0, 10)


func settle_death_drops() -> void:
	if has_meta("yellow_brow_owner"):
		return

	if monster_kind == 3123 and not bool(get_meta("transformed_to_3125", false)):
		return
	super.settle_death_drops()


func settle_death_drops_and_free() -> void:
	if is_queued_for_deletion():
		return
	if monster_kind == 3123 and not bool(get_meta("transformed_to_3125", false)):
		set_meta("transformed_to_3125", true)
		var parent := get_parent()
		if parent != null and is_instance_valid(parent):
			var replacement := Global.create_monster(3125, parent, global_position)
			if replacement != null:
				replacement.set_meta("source_birth_point", get_meta("source_birth_point", -1))
				replacement.set_meta("source_stage", get_meta("source_stage", 0))
				replacement.set_meta("allow_position_y_over_800", get_meta("allow_position_y_over_800", false))
				replacement.set_meta("transformed_from_3123", true)
				var facing := float(monster_dir.scale.x) if monster_dir != null else 1.0
				var level_node := get_level_node()
				if level_node != null and level_node.has_method("replace_stage_monster_instance"):
					level_node.call("replace_stage_monster_instance", self, replacement)
					level_node.call_deferred("_apply_spawn_facing", replacement, facing)
				else:
					replacement.set_meta("spawn_face", facing)
		queue_free()
		return
	super.settle_death_drops_and_free()

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
