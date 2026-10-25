extends BaseMonster

const PROJECTILE_SCRIPT := preload("res://Script/monster/wutai_minghai_projectile.gd")
const STREAM_SCRIPT := preload("res://Script/monster/streamed_png_effect.gd")
const BODY_STREAM_SCRIPT := preload("res://Script/monster/constellation_body_stream.gd")
const HEAL_AURA_SCRIPT := preload("res://Script/monster/constellation_heal_aura.gd")
const ASSET_ROOT := "res://Art/constellations/boss"
const SOURCE_FPS := 24.0
const MONSTER140_EFFECT_FPS := 24.0
const OFFICIAL_BODY_COLLISION_SIZE := Vector2(60, 130)
const OFFICIAL_SMALL_SUMMON_COLLISION_SIZE := Vector2(32, 30)

const MONSTER140_EFFECT_COLLISION := {
	"Monster140Bullet1": {"size": Vector2.ZERO, "offset": Vector2.ZERO},
	"Monster140Bullet2_1": {"size": Vector2(142, 170), "offset": Vector2(-1, -112)},
	"Monster140Bullet2_2": {"size": Vector2(124, 66), "offset": Vector2(8.5, 19.5)},
	"Monster140Bullet2_3": {"size": Vector2(108, 41), "offset": Vector2(1, 8.5)},
	"Monster140Bullet2_4": {"size": Vector2(142, 168), "offset": Vector2(-1, 109)},
	"Monster140Bullet3_1": {"size": Vector2(47, 36), "offset": Vector2(-27, 67)},
	"Monster140Bullet3_2": {"size": Vector2(49, 31), "offset": Vector2(-6, 68)},
	"Monster140Bullet3_3": {"size": Vector2(46, 37), "offset": Vector2(25.5, 68.5)},
	"Monster140Bullet4": {"size": Vector2(123, 122), "offset": Vector2(94.5, -96.5)},
}

const SKILL_REGISTRATIONS := {
	140:
	{
		"skill1": Vector2(-195.05, 94.0),
		"skill2": Vector2(86.95, 205.5),
		"skill2_2": Vector2(-7.2, -23.85),
		"skill2_3": Vector2(-1.25, -9.05),
		"skill2_4": Vector2(-5.2, -25.95),
		"skill3": Vector2(24.4, -66.45),
		"skill3_2": Vector2(5.6, -69.8),
		"skill3_3": Vector2(-21.7, -66.85),
		"skill4": Vector2(-92.5, 98.05),
	},
	141: {"skill1": Vector2(-93.0, 13.0)},
	142:
	{
		"skill1": Vector2(-219.7, 26.0),
		"skill2": Vector2(65.45, 62.8),
		"skill2_2": Vector2(55.35, 52.5),
		"skill3": Vector2(104.3, 63.9),
	},
	144:
	{
		"skill1": Vector2(-242.15, 69.5),
		"skill2": Vector2(3.0, 148.0),
		"skill3": Vector2(-186.0, 139.5),
	},
	145:
	{
		"skill1": Vector2(-2.0, 233.0),
		"skill2": Vector2(1.65, 1.3),
	},
	146:
	{
		"skill1": Vector2(-140.95, 33.9),
		"skill2": Vector2(40.0, 7.0),
		"skill3": Vector2(159.5, -23.15),
		"skill4": Vector2(4.05, -6.3),
	},
	147:
	{
		"skill1": Vector2(-87.75, 38.85),
		"skill2": Vector2(38.0, 29.0),
		"skill3": Vector2(-14.25, -146.5),
	},
	149:
	{
		"skill1": Vector2(-133.1, 64.2),
		"skill3": Vector2(-7.0, 15.15),
		"skill4": Vector2(2.5, -56.0),
	},
	150:
	{
		"skill1": Vector2(-4.95, 19.75),
		"skill2": Vector2(1.0, 0.0),
		"skill3": Vector2(4.55, -1.65),
		"skill4": Vector2(1.75, 2.75),
	},
	151:
	{
		"skill1": Vector2(-131.95, 120.8),
		"skill2": Vector2(1.15, -0.85),
		"skill2_2": Vector2(0.5, 0.0),
		"skill3": Vector2(5.9, 66.45),
	},
	152:
	{
		"skill1": Vector2(76.0, 93.0),
		"skill2": Vector2(-214.9, 66.3),
		"skill3": Vector2(102.5, 102.5),
		"skill4": Vector2(-1.0, -129.9),
	},
	156:
	{
		"skill1": Vector2(-1.5, 1.5),
		"skill2": Vector2(-230.35, 119.5),
		"skill3": Vector2(99.4, 118.5),
	},
	157:
	{
		"skill1": Vector2(-123.35, 46.65),
		"skill2": Vector2(1.5, -0.65),
	},
	158:
	{
		"skill1": Vector2(96.35, 96.3),
		"skill2": Vector2(-82.2, -136.35),
		"skill3": Vector2(-204.2, 52.0),
		"skill4": Vector2(-1.7, 35.3),
	},
	159:
	{
		"skill1": Vector2(-114.45, -48.05),
		"skill2": Vector2(102.5, -2.1),
		"skill3": Vector2(0.0, -132.9),
		"skill4": Vector2(1.4, -97.95),
	},
	162:
	{
		"skill1": Vector2(-160.2, -61.0),
		"skill2": Vector2(21.1, -93.95),
		"skill3": Vector2(-4.05, -91.55),
	},
}

const BODY_COUNTS := {
	140: 8,
	142: 8,
	144: 8,
	146: 8,
	147: 7,
	149: 9,
	150: 8,
	151: 7,
	152: 8,
	156: 7,
	157: 6,
	158: 8,
	159: 8,
	162: 7,
	141: 4,
	145: 6,
}

const BODY_ACTION_COUNTS := {
	140: [6, 4, 1, 5, 4, 2, 3, 2],
	142: [6, 4, 1, 5, 4, 1, 3, 2],
	144: [6, 4, 1, 5, 3, 3, 4, 3],
	146: [6, 4, 1, 5, 3, 16, 3, 3],
	147: [6, 4, 1, 5, 4, 2, 5],
	149: [6, 4, 1, 5, 4, 4, 4, 3, 2],
	150: [6, 4, 1, 5, 4, 3, 1, 3],
	151: [6, 4, 1, 5, 4, 1, 2],
	152: [6, 4, 1, 5, 4, 3, 1, 20],
	156: [6, 4, 1, 5, 20, 4, 1],
	157: [6, 4, 1, 5, 4, 2],
	158: [6, 4, 1, 5, 3, 2, 3, 1],
	159: [6, 4, 1, 5, 3, 2, 3, 72],
	162: [6, 4, 1, 5, 3, 28, 3],
	141: [6, 2, 1, 4],
	145: [6, 4, 1, 6, 3, 5],
}

const BODY_ACTION_STOPS := {
	140: [[2, 2, 2, 3, 2, 4], [4, 4, 4, 4], [8], [2, 2, 2, 2, 10], [2, 2, 2, 10], [2, 30], [2, 2, 30], [2, 10]],
	142: [[2, 2, 2, 3, 2, 4], [4, 4, 4, 4], [8], [2, 2, 2, 2, 10], [2, 5, 2, 10], [30], [2, 2, 36], [2, 10]],
	144: [[2, 2, 2, 3, 2, 4], [4, 4, 4, 4], [8], [2, 2, 2, 2, 10], [2, 2, 10], [2, 2, 10], [2, 2, 2, 10], [2, 2, 10]],
	146: [[2, 2, 2, 3, 2, 4], [4, 4, 4, 4], [8], [2, 2, 2, 2, 10], [2, 2, 10], [2, 2, 2, 2], [2, 2, 10], [2, 2, 48]],
	147: [[2, 2, 2, 3, 2, 4], [4, 4, 4, 4], [8], [2, 2, 2, 2, 10], [2, 2, 2, 10], [2, 10], [2, 2, 2, 2, 10]],
	149:
	[
		[2, 2, 2, 3, 2, 4],
		[4, 4, 4, 4],
		[8],
		[2, 2, 2, 2, 10],
		[2, 2, 2, 10],
		[1, 1, 1, 4],
		[1, 1, 1, 4],
		[2, 2, 10],
		[2, 20]
	],
	150: [[2, 2, 2, 3, 2, 4], [4, 4, 4, 4], [8], [2, 2, 2, 2, 10], [2, 2, 2, 10], [2, 2, 10], [40], [2, 2, 10]],
	151: [[2, 2, 2, 3, 2, 4], [4, 4, 4, 4], [8], [2, 2, 2, 2, 10], [2, 2, 2, 10], [30], [2, 10]],
	152: [[2, 2, 2, 3, 2, 4], [4, 4, 4, 4], [8], [2, 2, 2, 2, 10], [2, 2, 2, 10], [2, 2, 10], [50], [2, 2, 2, 2]],
	156: [[2, 2, 2, 3, 2, 4], [4, 4, 4, 4], [8], [2, 2, 2, 2, 10], [2, 2], [2, 2, 2, 10], [30]],
	157: [[2, 2, 2, 3, 2, 4], [4, 4, 4, 4], [8], [2, 2, 2, 2, 10], [2, 2, 2, 10], [30, 35]],
	158: [[2, 2, 2, 3, 2, 4], [4, 4, 4, 4], [8], [2, 2, 2, 2, 10], [2, 2, 10], [2, 10], [2, 2, 10], [34]],
	159: [[2, 2, 2, 3, 2, 4], [4, 4, 4, 4], [8], [2, 2, 2, 2, 10], [2, 2, 10], [2, 10], [2, 2, 10], [1, 1, 1, 1]],
	162: [[2, 2, 2, 3, 2, 4], [4, 4, 4, 4], [8], [2, 2, 2, 2, 10], [2, 2, 10], [2, 2, 2, 2], [2, 7, 10]],
	141: [[2, 2, 2, 3, 2, 4], [5, 5], [8], [2, 2, 2, 9]],
	145: [[2, 2, 2, 3, 2, 4], [4, 4, 4, 4], [8], [2, 2, 2, 2, 2, 10], [2, 2, 15], [1, 1, 1, 1, 10]],
}

const BODY_ACTION_ROWS := {
	&"wait": 0,
	&"walk": 1,
	&"hurt": 2,
	&"death": 3,
	&"hit1": 4,
	&"hit2": 5,
	&"hit3": 6,
	&"hit4": 7,
	&"hit5": 8,
	&"skill1": 4,
	&"skill2": 5,
	&"skill3": 6,
	&"skill4": 7,
}

const BODY_OFFSETS := {
	140: Vector2(10, -15),
	142: Vector2(10, -10),
	144: Vector2(10, -35),
	146: Vector2(10, -15),
	147: Vector2(5, -22),
	149: Vector2(5, -22),
	150: Vector2(15, -12),
	151: Vector2(10, -15),
	152: Vector2(10, -8),
	156: Vector2(0, -5),
	157: Vector2(0, 0),
	158: Vector2(0, 0),
	159: Vector2(0, -20),
	162: Vector2(0, -10),
	141: Vector2(0, -20),
	145: Vector2(2, 22),
}

const BODY_CANVAS_SIZES := {
	140: Vector2i(250, 250),
	142: Vector2i(250, 250),
	144: Vector2i(300, 300),
	146: Vector2i(250, 250),
	147: Vector2i(250, 250),
	149: Vector2i(300, 300),
	150: Vector2i(250, 250),
	151: Vector2i(250, 250),
	152: Vector2i(250, 250),
	156: Vector2i(250, 250),
	157: Vector2i(220, 220),
	158: Vector2i(250, 250),
	159: Vector2i(250, 250),
	162: Vector2i(250, 250),
	141: Vector2i(150, 150),
	145: Vector2i(200, 200),
}

const SKILL_OFFSETS := {
	140: {1: Vector2(55, -125), 2: Vector2(90, -115), 3: Vector2(0, -55), 4: Vector2(80, 10)},
	142: {1: Vector2(145, -25), 2: Vector2(60, -100), 3: Vector2(315, -75), 4: Vector2(0, -55)},
	144: {1: Vector2(145, -75), 2: Vector2(0, -55), 3: Vector2(220, -220), 4: Vector2(0, -55)},
	146: {1: Vector2(80, -35), 2: Vector2(0, -55), 3: Vector2(160, -75), 4: Vector2(0, -300)},
	147: {1: Vector2(170, -45), 2: Vector2(0, 75), 3: Vector2(0, -55), 4: Vector2(0, -55)},
	149: {1: Vector2(170, -45), 2: Vector2(0, -55), 3: Vector2(0, -55), 4: Vector2(0, -55)},
	150: {1: Vector2(80, -20), 2: Vector2(0, -55), 3: Vector2(0, -55), 4: Vector2(0, -55)},
	151: {1: Vector2(175, -130), 2: Vector2(0, 30), 3: Vector2(135, -90), 4: Vector2(0, -55)},
	152: {1: Vector2(140, -110), 2: Vector2(60, -70), 3: Vector2(95, -117), 4: Vector2(80, 445)},
	156: {1: Vector2(0, -55), 2: Vector2(180, -140), 3: Vector2(110, -150), 4: Vector2(0, -55)},
	157: {1: Vector2(110, -52), 2: Vector2(0, -55), 3: Vector2(0, -55), 4: Vector2(0, -55)},
	158: {1: Vector2(150, -105), 2: Vector2(125, -55), 3: Vector2(45, -85), 4: Vector2(0, -55)},
	159: {1: Vector2(60, 45), 2: Vector2(95, -25), 3: Vector2(0, 445), 4: Vector2(0, 80)},
	162: {1: Vector2(30, 80), 2: Vector2(20, 85), 3: Vector2(45, 85), 4: Vector2(0, -55)},
	141: {1: Vector2(0, -55), 2: Vector2(0, -55), 3: Vector2(0, -55), 4: Vector2(0, -55)},
	145: {1: Vector2(0, -55), 2: Vector2(0, 75), 3: Vector2(0, -55), 4: Vector2(0, -55)},
}

const SUMMON_PROJECT_IDS := {140: 47115, 144: 47117}

const ATTACK_SLOTS := {
	140: [1, 2, 3, 4],
	142: [1, 2, 3, 4],
	144: [1, 2, 3, 4],
	146: [1, 2, 3, 4],
	147: [1, 2, 3, 4],
	149: [1, 2, 3, 4],
	150: [1, 2, 3, 4],
	151: [1, 2, 3],
	152: [1, 2, 3, 4],
	156: [1, 2, 3],
	157: [1, 2, 3, 4],
	158: [1, 2, 3, 4],
	159: [1, 2, 3, 4],
	162: [1, 2, 3],
	141: [1],
	145: [1, 2],
}

const ATTACK_ACTIONS := {
	140: {1: &"hit1", 2: &"hit2", 3: &"hit3", 4: &"hit4"},
	142: {1: &"hit1", 2: &"hit2", 3: &"hit3", 4: &"hit4"},
	144: {1: &"hit1", 2: &"hit2", 3: &"hit3", 4: &"hit4"},
	146: {1: &"hit1", 2: &"hit2", 3: &"hit3", 4: &"hit4"},
	147: {1: &"hit1", 2: &"", 3: &"hit2", 4: &"hit3"},
	149: {1: &"hit1", 2: &"hit2", 3: &"hit4", 4: &"hit5"},
	150: {1: &"hit1", 2: &"hit2", 3: &"hit3", 4: &"hit4"},
	151: {1: &"hit1", 2: &"hit2", 3: &"hit3"},
	152: {1: &"hit1", 2: &"hit2", 3: &"hit3", 4: &"hit4"},
	156: {1: &"hit2", 2: &"hit3", 3: &"hit1"},
	157: {1: &"hit1", 2: &"hit2", 3: &"", 4: &""},
	158: {1: &"hit1", 2: &"hit2", 3: &"hit3", 4: &"hit4"},
	159: {1: &"hit1", 2: &"hit2", 3: &"hit3", 4: &"hit4"},
	162: {1: &"hit1", 2: &"hit2", 3: &"hit3"},
	141: {1: &"hit1"},
	145: {1: &"hit1", 2: &"hit2"},
}

const NORMAL_ATTACK_ENABLED := {156: false, 157: false}
const NORMAL_ATTACK_RATES := {141: 0.5, 158: 0.7, 159: 0.7, 162: 0.7}
const FACE_TARGET_ON_SKILL_START := {
	149: [2],
	156: [1, 2, 3],
	157: [1, 2],
	158: [2, 3, 4],
	159: [2, 3, 4],
	162: [2, 3],
}

const OFFICIAL_EVENT_FRAMES := {
	140: {1: [6], 2: [0, 2], 3: [4], 4: [2]},
	142: {1: [2, 9], 2: [], 3: [4], 4: [2]},
	144: {1: [4], 2: [4], 3: [6], 4: [4]},
	146: {1: [4], 2: [], 3: [4], 4: [4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48]},
	147: {1: [6], 2: [], 3: [2], 4: [8]},
	149: {1: [6], 2: [], 3: [4], 4: [2]},
	150: {1: [6], 2: [4], 3: [], 4: [4]},
	151: {1: [6], 2: [], 3: [2]},
	152: {1: [6], 2: [4], 3: [], 4: [6]},
	156: {1: [6], 2: [], 3: [1]},
	157: {1: [6], 2: [], 3: [], 4: []},
	158: {1: [4], 2: [2], 3: [4], 4: [4]},
	159: {1: [4], 2: [2], 3: [4], 4: []},
	162: {1: [4], 2: [], 3: [2]},
	141: {1: [7]},
	145: {1: [4], 2: [4]},
}

const IMMEDIATE_EFFECT_SLOTS := {
	142: [2],
	146: [2],
	150: [3],
	151: [2],
	152: [3],
	156: [2, 3],
	159: [4],
	162: [2],
}

const INVULNERABLE_FRAMES := {
	140: {2: 100000, 3: 24, 4: 20},
	142: {2: 20, 3: 24, 4: 20},
	144: {2: 20, 3: 24, 4: 20},
	146: {2: 20, 3: 24, 4: 20},
	147: {3: 24},
	149: {2: 20, 3: 24, 4: 24},
	150: {2: 20, 3: 40, 4: 24},
	151: {2: 20, 3: 24, 4: 20},
	152: {2: 20, 3: 14, 4: 40},
	156: {1: 20, 2: 30, 3: 40},
	157: {1: 15, 2: 30},
	158: {2: 15, 3: 15, 4: 34},
	159: {2: 5, 3: 5, 4: 72},
	162: {2: 56, 3: 19},
	145: {2: 15},
}

const MOVING_ATTACKS := {
	140: [],
	142: [2],
	144: [],
	146: [2],
	147: [2],
	149: [2],
	150: [],
	151: [],
	152: [4],
	156: [3],
	157: [],
	158: [],
	159: [4],
	162: [2],
}

const ATTACK_RANGES := {
	140: {1: 200.0, 2: 450.0, 3: INF, 4: INF},
	142: {1: 200.0, 2: 450.0, 3: 600.0, 4: INF},
	144: {1: 200.0, 2: 600.0, 3: 600.0, 4: INF},
	146: {1: 200.0, 2: 600.0, 3: 600.0, 4: 400.0},
	147: {1: 200.0, 2: INF, 3: 1000.0, 4: INF},
	149: {1: 200.0, 2: INF, 3: 400.0, 4: INF},
	150: {1: 200.0, 2: INF, 3: INF, 4: INF},
	151: {1: 200.0, 2: 600.0, 3: INF},
	152: {1: 150.0, 2: 600.0, 3: INF, 4: 600.0},
	156: {1: 600.0, 2: INF, 3: INF},
	157: {1: 600.0, 2: INF, 3: INF, 4: INF},
	158: {1: 150.0, 2: 600.0, 3: INF, 4: 50.0},
	159: {1: 150.0, 2: 600.0, 3: INF, 4: 100.0},
	162: {1: 150.0, 2: 600.0, 3: 200.0},
	141: {1: 200.0},
	145: {1: 300.0, 2: 300.0},
}

const ATTACK_COOLDOWNS := {
	140: {1: [1.0, 1.0], 2: [6.0, 20.0], 3: [5.0, 10.0], 4: [8.0, 15.0]},
	142: {1: [0.8, 0.8], 2: [6.0, 10.0], 3: [5.0, 15.0], 4: [8.0, 20.0]},
	144: {1: [0.8, 0.8], 2: [6.0, 10.0], 3: [5.0, 15.0], 4: [8.0, 15.0]},
	146: {1: [0.8, 0.8], 2: [6.0, 10.0], 3: [5.0, 15.0], 4: [8.0, 15.0]},
	147: {1: [0.8, 0.8], 2: [6.0, 20.0], 3: [5.0, 15.0], 4: [8.0, 15.0]},
	149: {1: [0.8, 0.8], 2: [6.0, 20.0], 3: [5.0, 15.0], 4: [8.0, 15.0]},
	150: {1: [0.8, 0.8], 2: [5.0, 7.0], 3: [4.0, 14.0], 4: [8.0, 15.0]},
	151: {1: [0.8, 0.8], 2: [6.0, 10.0], 3: [5.0, 10.0], 4: [8.0, 15.0]},
	152: {1: [0.8, 0.8], 2: [6.0, 7.0], 3: [5.0, 13.0], 4: [5.0, 10.0]},
	156: {1: [4.0, 7.0], 2: [5.0, 15.0], 3: [5.0, 9.0]},
	157: {1: [4.0, 10.0], 2: [5.0, 12.0], 3: [0.5, 1.0], 4: [5.0, 15.0]},
	158: {1: [0.8, 0.8], 2: [4.0, 10.0], 3: [5.0, 18.0], 4: [5.0, 14.0]},
	159: {1: [0.8, 0.8], 2: [4.0, 10.0], 3: [5.0, 9.0], 4: [5.0, 8.0]},
	162: {1: [0.8, 0.8], 2: [4.0, 10.0], 3: [5.0, 18.0]},
	141: {1: [0.8, 0.8]},
	145: {1: [0.8, 0.8], 2: [6.0, 8.0]},
}

@export var monster_kind: int = 47101

static var _standard_frames_cache: Dictionary = {}
var source_id: int = 140
var _runtime_config: Dictionary = {}
var _body_stream: StreamedPngEffect
var _busy := false
var _death_started := false
var _death_notified := false
var _attack_serial := 0
var _skill_cycle := 0
var _next_attack_msec := 0
var _monster140_body_hidden := false
var _skill_ready_msec: Dictionary = {}
var _skill_cursor := -1
var _invulnerable_until_msec := 0
var _invulnerable_forever := false
var _monster140_buried := false
var _monster140_emergence_pending := 0
var _monster157_alpha_restore_serial := 0
var _monster157_dash_active := false
var _monster157_dash_elapsed := 0.0
var _monster157_dash_hit := false
var _monster159_bati := false
var _facing_right := false
var _monster147_hidden := false
var _monster157_alpha_active := false
var _monster147_guard_stone: WutaiMinghaiProjectile
var _monster159_reface_elapsed := 0.0
var _monster159_shadow_elapsed := 0.0
var _monster159_motion_direction := 0.0
var _monster149_combo_target: Node2D
var _monster158_reject_effects: Dictionary = {}
var _monster158_effect_accumulator := 0.0


func _ready() -> void:
	_runtime_config = _resolve_runtime_config()
	_configure_boss(_runtime_config)
	_initialize_attack_cooldowns()
	_build_animations()
	mr_ani.visible = false
	super._ready()


func _initialize_attack_cooldowns() -> void:
	_skill_ready_msec.clear()
	_skill_cursor = -1
	var source_value: Variant = ATTACK_COOLDOWNS.get(source_id, {})
	var source_cooldowns: Dictionary = source_value if source_value is Dictionary else {}
	var now := Time.get_ticks_msec()
	for slot_value in ATTACK_SLOTS.get(source_id, [1]):
		var slot := int(slot_value)
		var cooldown_value: Variant = source_cooldowns.get(slot, [0.8, 0.8])
		var cooldown_pair: Array = cooldown_value if cooldown_value is Array else [0.8, 0.8]
		var initial_seconds := float(cooldown_pair[0]) if not cooldown_pair.is_empty() else 0.8
		if source_id == 159 and slot == 2:
			initial_seconds = 3.0

		var is_normal_attack := slot == 1 and _normal_attack_enabled()
		_skill_ready_msec[slot] = now + 1000 if is_normal_attack else now + roundi(initial_seconds * 1000.0)


func _resolve_runtime_config() -> Dictionary:
	var level_node := get_level_node()
	if level_node != null and level_node.has_method("get_level_monster_config"):
		var value: Variant = level_node.call("get_level_monster_config", monster_kind)
		if value is Dictionary and not (value as Dictionary).is_empty():
			return (value as Dictionary).duplicate(true)
	push_error("ConstellationBoss has no level config for project id %d" % monster_kind)
	return {}


func _configure_boss(config: Dictionary) -> void:
	source_id = int(config.get("source_id", source_id))
	_configure_official_body_collision()
	my_mr_name = str(config.get("name", "星宿"))
	level = int(config.get("level", 90))
	attack_in = int(config.get("attack", 22000))
	max_hp = int(config.get("hp", 8000000))
	hp = max_hp
	def = int(config.get("def", 3000))
	mdef = int(config.get("mdef", 3000))
	crit = int(config.get("crit", 450))
	miss = int(config.get("miss", 180))
	htarget = int(config.get("hit", 400))
	toughness = float(config.get("toughness", 0.0))
	crit_reduce = int(config.get("crit_reduce", 0))
	ar = int(config.get("armor_break", 3000))
	sp = int(config.get("magic_break", 3000))
	speed = float(config.get("speed", 10.0))
	mysee = int(config.get("sight", 1200))
	attack_range = int(config.get("range", 280))
	attack_desire = int(config.get("attack_desire", 100))
	add_exp = int(config.get("exp", 2000))
	fall_coin = int(config.get("coin", 100))
	fall_pro = float(config.get("drop_rate", 100.0))
	fall_list = Array(config.get("drop_list", [])).duplicate(true)
	independent_fall_list = Array(config.get("independent_drop_list", [])).duplicate(true)
	is_boss = bool(config.get("is_boss", true))
	is_immobilize = bool(config.get("control_immune", false))
	boss_max_protect = float(config.get("max_protect", 100.0))
	if source_id in [140, 142, 144, 146, 147, 149, 150, 151, 152, 156, 157, 158, 159, 162]:
		speed = 4.0
		attack_range = 150 if source_id in [152, 158, 159, 162] else 200
		mysee = 2500
	obj_attack_dict.clear()
	var attacks: Dictionary = config.get("attacks", {})
	for attack_name: String in attacks:
		var attack: Dictionary = attacks[attack_name]
		obj_attack_dict[attack_name] = {
			"power": int(attack.get("power", roundi(float(attack_in) * float(attack.get("multiplier", 1.0))))),
			"hurtBack": Array(attack.get("hurt_back", [-3.0, -1.0])).duplicate(),
			"attackKind": str(attack.get("kind", "physics")),
			"HitProtect": int(attack.get("protect", 80)),
			"attackInterval": float(attack.get("interval", 0.16)),
			"hitMaxCount": int(attack.get("max_hits", 99)),
		}
	if source_id == 140 and obj_attack_dict.has("hit2") and not obj_attack_dict.has("hit2_2"):
		obj_attack_dict["hit2_2"] = (obj_attack_dict["hit2"] as Dictionary).duplicate(true)


func _configure_official_body_collision() -> void:
	if pz == null:
		return
	var rectangle := RectangleShape2D.new()
	rectangle.size = OFFICIAL_SMALL_SUMMON_COLLISION_SIZE if source_id == 141 else OFFICIAL_BODY_COLLISION_SIZE
	pz.position = Vector2.ZERO
	pz.shape = rectangle
	if hurt_box != null:
		hurt_box.position = Vector2.ZERO
		hurt_box.shape = rectangle


func _build_animations() -> void:
	if mr_player.has_animation_library(&""):
		mr_player.remove_animation_library(&"")
	var library := AnimationLibrary.new()
	library.add_animation(&"wait", _make_animation(&"wait", _body_action_duration(&"wait"), true))
	library.add_animation(&"walk", _make_animation(&"walk", _body_action_duration(&"walk"), true))
	library.add_animation(&"hurt", _make_animation(&"hurt", _body_action_duration(&"hurt"), false))
	var death_animation := _make_animation(&"death", _body_action_duration(&"death"), false)
	_add_method_key(death_animation, death_animation.length - 0.01, &"settle_death_drops_and_free")
	library.add_animation(&"death", death_animation)
	for skill in range(1, 5):
		var action := StringName("skill%d" % skill)
		var body_action := _attack_action(skill)
		var skill_length := _skill_animation_duration(skill, body_action)
		var skill_animation := _make_animation(body_action, skill_length, false)
		if source_id == 140:
			_add_monster140_emit_keys(skill_animation, skill)
		else:
			var source_events: Array = _official_event_frames(skill)
			for frame_value in source_events:
				_add_method_key(skill_animation, float(frame_value) / SOURCE_FPS, &"_emit_skill", [skill])
			if skill in IMMEDIATE_EFFECT_SLOTS.get(source_id, []):
				_add_method_key(skill_animation, 0.0, &"_emit_skill", [skill])
		_add_method_key(skill_animation, skill_animation.length - 0.01, &"_disable_attack_box")
		library.add_animation(action, skill_animation)
	if source_id == 149:
		library.add_animation(&"monster149_combo_mid", _make_animation(&"hit3", _body_action_duration(&"hit3"), false))
	mr_player.add_animation_library(&"", library)


func _make_animation(action: StringName, length: float, looped: bool) -> Animation:
	var animation := Animation.new()
	animation.length = maxf(length, 0.05)
	animation.loop_mode = Animation.LOOP_LINEAR if looped else Animation.LOOP_NONE
	if not action.is_empty():
		_add_method_key(animation, 0.0, &"_play_body_action", [action])
	return animation


func _attack_action(skill: int) -> StringName:
	var source_value: Variant = ATTACK_ACTIONS.get(source_id, {})
	var source_actions: Dictionary = source_value if source_value is Dictionary else {}
	var action_value: Variant = source_actions.get(skill, &"")
	return action_value as StringName if action_value is StringName else StringName(str(action_value))


func _official_event_frames(skill: int) -> Array:
	var source_value: Variant = OFFICIAL_EVENT_FRAMES.get(source_id, {})
	var source_events: Dictionary = source_value if source_value is Dictionary else {}
	var frames_value: Variant = source_events.get(skill, [])
	return frames_value as Array if frames_value is Array else []


func _skill_animation_duration(skill: int, body_action: StringName) -> float:
	if not body_action.is_empty():
		return _body_action_duration(body_action)
	var frames := _official_event_frames(skill)
	var last_frame := 1
	for frame_value in frames:
		last_frame = maxi(last_frame, int(frame_value) + 1)
	if source_id == 147 and skill == 2:
		return 0.05
	if source_id == 157 and skill == 4:
		return 0.05
	return float(last_frame) / SOURCE_FPS


func _add_method_key(animation: Animation, time: float, method_name: StringName, args: Array = []) -> void:
	var track := animation.add_track(Animation.TYPE_METHOD)
	animation.track_set_path(track, NodePath("."))
	(
		animation
		. track_insert_key(
			track,
			clampf(time, 0.0, maxf(animation.length - 0.001, 0.0)),
			{
				"method": method_name,
				"args": args,
			}
		)
	)


func _add_monster140_emit_keys(animation: Animation, skill: int) -> void:
	match skill:
		1:
			_add_method_key(animation, 6.0 / SOURCE_FPS, &"_emit_monster140_skill", [1, 1])
		2:
			_add_method_key(animation, 0.0, &"_emit_monster140_skill", [2, 1])
			_add_method_key(animation, 2.0 / SOURCE_FPS, &"_emit_monster140_skill", [2, 2])
		3:
			_add_method_key(animation, 4.0 / SOURCE_FPS, &"_emit_monster140_skill", [3, 1])
		4:
			_add_method_key(animation, 2.0 / SOURCE_FPS, &"_emit_monster140_skill", [4, 1])


func _body_sequence(action: StringName) -> FrameSequence:
	return FrameSequenceStore.get_sequence(
		"constellation/%d/body/%s" % [source_id, action],
		SOURCE_FPS,
		action in [&"wait", &"walk"],
		action not in [&"wait", &"walk"],
		2
	)


func _play_body_action(action: StringName) -> void:
	var stream := BODY_STREAM_SCRIPT.new() as StreamedPngEffect
	stream.name = "BodyStream"
	stream.sequence = _body_sequence(action)
	stream.auto_free = false
	stream.call(
		"configure_canvas",
		BODY_CANVAS_SIZES.get(source_id, Vector2i(250, 250)),
		BODY_OFFSETS.get(source_id, Vector2.ZERO),
		_facing_right
	)
	stream.visible = not _monster140_body_hidden and not _monster147_hidden
	stream.modulate.a = 0.5 if _monster157_alpha_active else 1.0
	var previous_stream := _body_stream
	monster_dir.add_child(stream)
	_body_stream = stream
	if previous_stream != null and is_instance_valid(previous_stream):
		previous_stream.clear_texture()
		previous_stream.queue_free()


func _standard_frames_resource_path() -> String:
	return _asset_root().path_join("atlas").path_join("constellation_%d_frames.tres" % source_id)


func _standard_frames() -> SpriteFrames:
	var path := _standard_frames_resource_path()
	if not _standard_frames_cache.has(path):
		_standard_frames_cache[path] = load(path) as SpriteFrames
	return _standard_frames_cache[path] as SpriteFrames


func _body_action_duration(action: StringName) -> float:
	return maxf(float(_body_sequence(action).count()) / SOURCE_FPS, 0.05)


func _asset_root() -> String:
	return ASSET_ROOT.path_join(str(source_id))


func ai_think() -> void:
	var target_position_value: Variant = _active_target_global_position()
	if _busy or death() or target_position_value == null:
		return
	var target_position := target_position_value as Vector2
	if Time.get_ticks_msec() < _next_attack_msec:
		velocity.x = 0.0
		mr_player.play(&"wait")
		return
	if source_id == 140 and (_monster140_body_hidden or _monster140_buried):
		velocity = Vector2.ZERO
		return
	var direction := 1.0 if target_position.x >= global_position.x else -1.0
	var delta_x := target_position.x - global_position.x
	var delta_y := target_position.y - global_position.y
	var distance := Vector2(delta_x, delta_y).length()
	has_target = distance <= float(mysee)
	if not has_target:
		velocity.x = 0.0
		mr_player.play(&"wait")
		return
	if source_id == 140:
		_monster140_intelligence(distance, direction)
		return
	var skill := _select_ready_skill(distance)
	if skill > 0:
		_start_skill(skill)
		return

	var now := Time.get_ticks_msec()
	if _normal_attack_enabled() and distance <= float(attack_range) and now >= int(_skill_ready_msec.get(1, 0)):
		_skill_ready_msec[1] = now + 1000
		if randf() <= _normal_attack_rate():
			_start_skill(1)
		else:
			velocity.x = 0.0
			mr_player.play(&"wait")
		return

	if distance > float(attack_range):
		_set_facing_direction(direction)
		velocity.x = speed * SOURCE_FPS * direction
		mr_player.play(&"walk")
	else:
		velocity.x = 0.0
		mr_player.play(&"wait")


func _monster140_intelligence(distance: float, direction: float) -> void:
	var now := Time.get_ticks_msec()
	if now >= int(_skill_ready_msec.get(2, now + 1)) and distance < 450.0:
		_start_skill(2)
		return
	if now >= int(_skill_ready_msec.get(3, now + 1)):
		_start_skill(3)
		return
	if now >= int(_skill_ready_msec.get(4, now + 1)):
		_start_skill(4)
		return

	if distance <= float(attack_range) and now >= int(_skill_ready_msec.get(1, now + 1)):
		_skill_ready_msec[1] = now + 1000
		if randf() <= 0.8:
			_start_skill(1)
		else:
			velocity.x = 0.0
			mr_player.play(&"wait")
		return

	if distance > float(attack_range):
		_set_facing_direction(direction)
		velocity.x = speed * SOURCE_FPS * direction
		mr_player.play(&"walk")
	else:
		velocity.x = 0.0
		mr_player.play(&"wait")


func _select_ready_skill(distance: float) -> int:
	var slots_value: Variant = ATTACK_SLOTS.get(source_id, [1])
	var slots: Array = slots_value if slots_value is Array else [1]
	if slots.is_empty():
		return 0
	var now := Time.get_ticks_msec()
	for slot_value in slots:
		var slot := int(slot_value)
		if slot == 1 and _normal_attack_enabled():
			continue
		if now < int(_skill_ready_msec.get(slot, 0)):
			continue
		if distance > _attack_range(slot):
			continue
		if source_id == 147 and slot == 4 and _monster147_guard_active():
			continue
		return slot
	return 0


func _normal_attack_enabled() -> bool:
	return bool(NORMAL_ATTACK_ENABLED.get(source_id, true))


func _normal_attack_rate() -> float:
	if source_id == 159 and _monster159_bati:
		return 1.0
	return float(NORMAL_ATTACK_RATES.get(source_id, 0.8))


func _monster147_guard_active() -> bool:
	return (
		_monster147_guard_stone != null
		and is_instance_valid(_monster147_guard_stone)
		and not _monster147_guard_stone.is_queued_for_deletion()
	)


func _attack_range(skill: int) -> float:
	var source_value: Variant = ATTACK_RANGES.get(source_id, {})
	var source_ranges: Dictionary = source_value if source_value is Dictionary else {}
	return float(source_ranges.get(skill, 220.0))


func _nearest_attack_range() -> float:
	var slots_value: Variant = ATTACK_SLOTS.get(source_id, [1])
	var slots: Array = slots_value if slots_value is Array else [1]
	var result := 220.0
	for slot_value in slots:
		result = maxf(result, _attack_range(int(slot_value)))
	return result


func _start_skill(skill: int) -> void:
	if _busy or death() or (source_id == 140 and _monster140_buried):
		return
	_busy = true
	is_attacking = true
	_attack_serial += 1
	_skill_cycle = skill
	var body_action := _attack_action(skill)
	hit_name = str(body_action) if not body_action.is_empty() else "hit1"
	var preserve_velocity := source_id == 147 and skill == 3
	if not preserve_velocity:
		velocity.x = 0.0
	if source_id == 149 and skill == 2:
		_monster149_combo_target = _random_player()
	var face_slots_value: Variant = FACE_TARGET_ON_SKILL_START.get(source_id, [])
	var face_slots: Array = face_slots_value if face_slots_value is Array else []
	if skill == 1 and _normal_attack_enabled() or skill in face_slots:
		_face_role()
	if skill != 1 or not _normal_attack_enabled():
		_arm_skill_cooldown(skill)
	_apply_official_invulnerability(skill)
	if source_id == 140 and skill == 2:
		_monster140_begin_burrow()
	if source_id == 157 and skill == 2:
		_monster157_begin_dash()
	_begin_official_attack_motion(skill)
	if _run_state_only_skill(skill):
		_busy = false
		is_attacking = false
		return
	mr_player.play(StringName("skill%d" % skill))
	await mr_player.animation_finished
	if not is_instance_valid(self) or death():
		return
	if source_id == 149 and skill == 2:
		await _monster149_continue_combo()
		if not is_instance_valid(self) or death():
			return
	if source_id == 157 and skill == 2:
		_monster157_end_dash()
	_disable_attack_box()
	_busy = false
	is_attacking = false
	velocity.x = 0.0
	if _monster140_body_hidden or _monster140_buried:
		mr_player.stop()
	else:
		mr_player.play(&"wait")


func _begin_official_attack_motion(skill: int) -> void:
	var source_speed := 0.0
	if source_id in [142, 146, 162] and skill == 2:
		source_speed = 15.0
	elif source_id == 152 and skill == 4:
		source_speed = 20.0
	elif source_id == 156 and skill == 3:
		source_speed = 15.0
	elif source_id == 159 and skill == 4:
		source_speed = 8.0 if _monster159_bati else 4.0
		_monster159_reface_elapsed = 0.0
		_monster159_motion_direction = _facing_direction()
	if source_speed > 0.0:
		velocity.x = _facing_direction() * source_speed * SOURCE_FPS


func _monster149_continue_combo() -> void:
	velocity.x = 0.0
	var target := _monster149_combo_target
	if _is_alive_constellation_player(target):
		var target_faces_right := bool(target.get("player_dir"))
		global_position.x = target.global_position.x - 100.0 if target_faces_right else target.global_position.x + 100.0
		_face_role()
	mr_player.play(&"monster149_combo_mid")
	await mr_player.animation_finished
	if not is_instance_valid(self) or death():
		return
	_skill_cycle = 0
	velocity.x = 0.0
	mr_player.play(&"skill1")
	await mr_player.animation_finished
	_monster149_combo_target = null


func _continue_official_attack_motion(delta: float) -> void:
	if not _busy:
		return
	if source_id == 159 and _skill_cycle == 4:
		_monster159_reface_elapsed += delta
		if _monster159_reface_elapsed >= 1.0:
			_monster159_reface_elapsed = fmod(_monster159_reface_elapsed, 1.0)
			if RoleProp.get_nearest_monster_target_position(global_position).x != null:
				_monster159_motion_direction = (
					1.0
					if float(RoleProp.get_nearest_monster_target_position(global_position).x) >= global_position.x
					else -1.0
				)
		velocity.x = _monster159_motion_direction * (8.0 if _monster159_bati else 4.0) * SOURCE_FPS
		return
	if _skill_cycle not in MOVING_ATTACKS.get(source_id, []):
		return
	var source_speed := 20.0 if source_id == 152 else 15.0
	velocity.x = _facing_direction() * source_speed * SOURCE_FPS


func _run_state_only_skill(skill: int) -> bool:
	if source_id == 147 and skill == 2:
		_monster147_hide_for_skill()
		return true
	if source_id == 157 and skill == 3:
		_monster157_adjust_damage()
		return true
	if source_id == 157 and skill == 4:
		_monster157_start_alpha_skill()
		return true
	return _attack_action(skill).is_empty()


func _monster157_begin_dash() -> void:
	_monster157_dash_active = true
	_monster157_dash_elapsed = 0.0
	_monster157_dash_hit = false
	velocity.x = _facing_direction() * 15.0 * SOURCE_FPS


func _monster157_end_dash() -> void:
	_monster157_dash_active = false
	_monster157_dash_elapsed = 0.0
	velocity.x = 0.0


func _monster157_check_dash_collision() -> void:
	if not _monster157_dash_active or _monster157_dash_hit:
		return
	for target in _monster157_targets():
		if not is_instance_valid(target) or target == self:
			continue
		if not _monster157_overlaps_target(target):
			continue
		_monster157_dash_hit = true
		_monster157_end_dash()
		_invulnerable_until_msec = Time.get_ticks_msec() + roundi(35.0 * 1000.0 / SOURCE_FPS)
		_spawn_projectile_for_slot(
			2,
			2,
			{
				"folder": "skill2",
				"spawn_position": target.global_position,
				"right": false,
				"follow_owner": true,
				"follow_owner_offset": Vector2.ZERO,
				"damage_enabled": true,
				"lifetime": 1.5,
			}
		)
		return


func _monster157_targets() -> Array[Node2D]:
	var targets: Array[Node2D] = []
	var player := _random_player()
	if player != null:
		targets.append(player)
	var scene_root := get_tree().current_scene
	if scene_root != null:
		_monster157_collect_summons(scene_root, targets)
	return targets


func _monster157_collect_summons(node: Node, targets: Array[Node2D]) -> void:
	if node != self and node is Node2D and (node is SummonBaseMonster or bool(node.get_meta("is_summon", false))):
		var summon := node as Node2D
		if summon not in targets:
			targets.append(summon)
	for child in node.get_children():
		_monster157_collect_summons(child, targets)


func _monster157_overlaps_target(target: Node2D) -> bool:
	var boss_shape := pz.shape
	var target_pz := target.get_node_or_null("pz") as CollisionShape2D
	var target_shape := target_pz.shape if target_pz != null else null
	var horizontal_limit := 60.0
	var vertical_limit := 100.0
	if boss_shape is CapsuleShape2D:
		horizontal_limit = float((boss_shape as CapsuleShape2D).radius)
		vertical_limit = float((boss_shape as CapsuleShape2D).height) * 0.5
	if target_shape is RectangleShape2D:
		var target_size := (target_shape as RectangleShape2D).size
		horizontal_limit += target_size.x * 0.5
		vertical_limit += target_size.y * 0.5
	var boss_center := global_position + (pz.position if pz != null else Vector2.ZERO)
	var target_center := target.global_position + (target_pz.position if target_pz != null else Vector2.ZERO)
	return (
		absf(boss_center.x - target_center.x) <= horizontal_limit
		and absf(boss_center.y - target_center.y) <= vertical_limit
	)


func _monster147_hide_for_skill() -> void:
	_monster147_hidden = true
	if _body_stream != null and is_instance_valid(_body_stream):
		_body_stream.visible = false
	call_deferred("_monster147_restore_body")


func _monster147_restore_body() -> void:
	await get_tree().create_timer(10.0, false).timeout
	if not is_instance_valid(self) or death():
		return
	_monster147_hidden = false
	if _body_stream != null and is_instance_valid(_body_stream):
		_body_stream.visible = true


func _monster157_adjust_damage() -> void:
	var total_health_ratio := 0.0
	var count := 0
	var players: Array[BaseHero] = LocalCoop.living_players()
	for player_value in players:
		var player := player_value as Node
		var hp := float(player.get("hp")) if player != null and player.get("hp") != null else 0.0
		var max_hp := float(player.get("max_hp")) if player != null and player.get("max_hp") != null else 0.0
		if max_hp > 0.0:
			total_health_ratio += hp / max_hp
			count += 1
	if count <= 0:
		return
	var average_health := total_health_ratio / float(count)
	var bonus := clampf(1.0 - average_health, 0.0, 1.0)
	var source_power := 500.0 * float(_source_property_level()) * (1.0 + bonus)
	for action_name in [&"hit1", &"hit2"]:
		if obj_attack_dict.has(action_name):
			var attack: Dictionary = obj_attack_dict[action_name]
			attack["power"] = roundi(source_power)
			obj_attack_dict[action_name] = attack


func _monster157_start_alpha_skill() -> void:
	_monster157_alpha_restore_serial += 1
	var serial := _monster157_alpha_restore_serial
	_monster157_alpha_active = true
	_enter_constellation_invulnerability()
	if _body_stream != null and is_instance_valid(_body_stream):
		_body_stream.modulate.a = 0.5
	call_deferred("_monster157_restore_alpha", serial)


func _monster157_restore_alpha(serial: int) -> void:
	await get_tree().create_timer(6.0, false).timeout
	if not is_instance_valid(self) or serial != _monster157_alpha_restore_serial:
		return
	_monster157_alpha_active = false
	if _body_stream != null and is_instance_valid(_body_stream):
		_body_stream.modulate.a = 1.0


func _arm_skill_cooldown(skill: int) -> void:
	var source_value: Variant = ATTACK_COOLDOWNS.get(source_id, {})
	var source_cooldowns: Dictionary = source_value if source_value is Dictionary else {}
	var cooldown_value: Variant = source_cooldowns.get(skill, [0.8, 0.8])
	var cooldown_pair: Array = cooldown_value if cooldown_value is Array else [0.8, 0.8]

	var cooldown_seconds := float(cooldown_pair[1]) if cooldown_pair.size() > 1 else 0.8
	if source_id == 159 and skill == 2:
		cooldown_seconds = 2.0 * float(_source_property_level() + 1)
	_skill_ready_msec[skill] = Time.get_ticks_msec() + roundi(cooldown_seconds * 1000.0)


func _apply_official_invulnerability(skill: int) -> void:
	var source_value: Variant = INVULNERABLE_FRAMES.get(source_id, {})
	var source_frames: Dictionary = source_value if source_value is Dictionary else {}
	if not source_frames.has(skill):
		return
	var frame_count := int(source_frames[skill])
	if frame_count >= 100000:
		_invulnerable_forever = true
		_invulnerable_until_msec = 0
	elif frame_count > 0:
		_invulnerable_until_msec = Time.get_ticks_msec() + roundi(float(frame_count) * 1000.0 / SOURCE_FPS)
	_enter_constellation_invulnerability()


func _enter_constellation_invulnerability() -> void:
	_cancel_hurt_reaction()
	_enforce_control_immunity_state()
	_process_pet_tiger_sxhz_air_hold()


func _is_constellation_invulnerable() -> bool:
	if _invulnerable_forever or _monster157_alpha_active:
		return true
	return _invulnerable_until_msec > Time.get_ticks_msec()


func _monster140_begin_burrow() -> void:
	_monster140_buried = true
	_monster140_emergence_pending = 0
	_monster140_body_hidden = false
	_invulnerable_forever = true
	_invulnerable_until_msec = 0
	_enter_constellation_invulnerability()
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)


func _emit_skill(skill: int) -> void:
	if death() or not _busy:
		return
	if source_id == 140:
		_emit_monster140_skill(skill, 1)
		return
	if source_id in [141, 145]:
		_emit_constellation_summon_skill(skill)
		return
	hit_name = str(_attack_action(skill)) if not _attack_action(skill).is_empty() else "hit1"
	match source_id:
		142:
			_emit_monster142_skill(skill)
		144:
			_emit_monster144_skill(skill)
		146:
			_emit_monster146_skill(skill)
		147:
			_emit_monster147_skill(skill)
		149:
			_emit_monster149_skill(skill)
		150:
			_emit_monster150_skill(skill)
		151:
			_emit_monster151_skill(skill)
		152:
			_emit_monster152_skill(skill)
		156:
			_emit_monster156_skill(skill)
		157:
			_emit_monster157_skill(skill)
		158:
			_emit_monster158_skill(skill)
		159:
			_emit_monster159_skill(skill)
		162:
			_emit_monster162_skill(skill)
		_:
			_spawn_projectile_for_slot(skill)


func _emit_constellation_summon_skill(skill: int) -> void:
	var direction := _facing_direction()
	if source_id == 141 and skill == 1:
		_spawn_projectile_for_slot(
			1,
			1,
			{
				"offset": Vector2(direction * 50.0, -10.0),
				"hit_interval": 999.0 / SOURCE_FPS,
				"max_hits": 99,
			}
		)
	elif source_id == 145 and skill == 1:
		var player := _random_player()
		if player != null:
			_spawn_projectile_for_slot(
				1,
				1,
				{
					"spawn_position": Vector2(player.global_position.x, 480.0),
					"hit_interval": 999.0 / SOURCE_FPS,
					"max_hits": 99,
				}
			)
	elif source_id == 145 and skill == 2:
		var target := _random_alive_monster()
		if target != null:
			_spawn_projectile_for_slot(
				2,
				2,
				{
					"spawn_position": target.global_position,
					"target_node": target,
					"follow_target": true,
					"damage_enabled": false,
					"finished_callback": Callable(self, "_monster145_heal_target").bind(target),
				}
			)


func _random_alive_monster() -> BaseMonster:
	var candidates: Array[BaseMonster] = []
	var parent := get_parent()
	if parent == null:
		return null
	for child in parent.get_children():
		if child is BaseMonster and not child.is_queued_for_deletion() and not child.death():
			candidates.append(child as BaseMonster)
	return candidates.pick_random() if not candidates.is_empty() else null


func _monster145_heal_target(_effect_position: Vector2, target: BaseMonster) -> void:
	if target != null and is_instance_valid(target) and not target.death():
		target.cure_hp(1000)


func _emit_monster142_skill(skill: int) -> void:
	var direction := _facing_direction()
	match skill:
		1:
			_spawn_projectile_for_slot(1)
			_spawn_projectile_for_slot(1, 1, {"offset": Vector2(direction * 145.0, -35.0)})
		2:
			for folder in ["skill2", "skill2_2"]:
				var effect := _spawn_projectile_for_slot(
					2,
					2,
					{
						"folder": folder,
						"offset": Vector2(direction * 60.0, -100.0),
						"follow_owner": true,
						"follow_owner_offset": Vector2(direction * 60.0, -100.0),
						"damage_enabled": true,
					}
				)
				if effect != null and folder == "skill2_2":
					effect.z_index = -1
		3:
			_spawn_projectile_for_slot(
				3,
				3,
				{"offset": Vector2(direction * 315.0, -75.0), "lifetime": 30.0 / SOURCE_FPS, "hold_last_frame": true}
			)


func _emit_monster144_skill(skill: int) -> void:
	var direction := _facing_direction()
	match skill:
		1:
			_spawn_projectile_for_slot(1)
		2:
			var target := _random_player()
			if target != null:
				_spawn_projectile_for_slot(
					2,
					2,
					{
						"spawn_position": Vector2(target.global_position.x, 475.0),
						"damage_enable_delay": 13.0 / SOURCE_FPS,
					}
				)
		3:
			_spawn_projectile_for_slot(3, 3, {"offset": Vector2(direction * 220.0, -220.0)})
		4:
			_spawn_source_summon(47117, Vector2(direction * 40.0, -20.0), 20.0)


func _emit_monster146_skill(skill: int) -> void:
	var direction := _facing_direction()
	match skill:
		1:
			_spawn_projectile_for_slot(1)
		2:
			_spawn_projectile_for_slot(
				2,
				2,
				{
					"offset": Vector2.ZERO,
					"follow_owner": true,
					"follow_owner_offset": Vector2.ZERO,
					"lifetime": 48.0 / SOURCE_FPS,
					"damage_enabled": true,
					"hold_last_frame": true,
				}
			)
		3:
			_spawn_projectile_for_slot(3, 3, {"offset": Vector2(direction * 160.0, -75.0)})
		4:
			_spawn_monster146_bullet4(direction)


func _emit_monster147_skill(skill: int) -> void:
	var direction := _facing_direction()
	match skill:
		1:
			_spawn_projectile_for_slot(1)
		2:
			pass
		3:
			_spawn_monster147_stones(direction)
		4:
			_monster147_guard_stone = _spawn_projectile_for_slot(
				3,
				3,
				{
					"offset": Vector2.ZERO,
					"follow_owner": true,
					"follow_owner_offset": Vector2.ZERO,
					"lifetime": INF,
					"damage_enabled": true,
					"hold_last_frame": true,
				}
			)


func _emit_monster149_skill(skill: int) -> void:
	var direction := _facing_direction()
	match skill:
		1:
			_spawn_projectile_for_slot(1)
		2:
			velocity.x = direction * 15.0
		3:
			_spawn_projectile_for_slot(
				3,
				3,
				{
					"offset": Vector2.ZERO,
					"follow_owner": true,
					"follow_owner_offset": Vector2.ZERO,
					"lifetime": 50.0 / SOURCE_FPS,
					"damage_enabled": true
				}
			)
		4:
			_spawn_projectile_for_slot(
				4,
				4,
				{
					"offset": Vector2.ZERO,
					"follow_owner": true,
					"follow_owner_offset": Vector2.ZERO,
					"damage_enabled": false,
					"finished_callback": Callable(self, "_monster149_gaze_effect"),
				}
			)


func _emit_monster150_skill(skill: int) -> void:
	var direction := _facing_direction()
	match skill:
		1:
			_spawn_projectile_for_slot(1)
		2:
			_spawn_monster150_fireflies(direction)
		3:
			_spawn_projectile_for_slot(
				3,
				3,
				{
					"offset": Vector2.ZERO,
					"follow_owner": true,
					"follow_owner_offset": Vector2.ZERO,
					"lifetime": 40.0 / SOURCE_FPS,
					"damage_enabled": false,
					"hold_last_frame": true,
					"finished_callback": Callable(self, "_monster150_start_blackout"),
				}
			)
		4:
			var target := _random_player()
			if target != null:
				_spawn_projectile_for_slot(
					4, 4, {"spawn_position": Vector2(target.global_position.x, 500.0), "damage_enabled": true}
				)


func _emit_monster151_skill(skill: int) -> void:
	var direction := _facing_direction()
	match skill:
		1:
			_spawn_projectile_for_slot(
				1,
				1,
				{
					"hit_callback": Callable(self, "_monster151_heal_on_hit"),
				}
			)
		2:
			_spawn_projectile_for_slot(
				2,
				2,
				{
					"offset": Vector2(0.0, 30.0),
					"follow_owner": true,
					"follow_owner_offset": Vector2(0.0, 30.0),
					"damage_enabled": false,
					"lifetime": 1.5,
					"finished_callback": Callable(self, "_monster151_start_drain_buff"),
				}
			)
		3:
			_spawn_projectile_for_slot(
				3,
				3,
				{
					"offset": Vector2(direction * 135.0, -90.0),
					"hit_callback": Callable(self, "_monster151_heal_on_hit"),
				}
			)


func _emit_monster152_skill(skill: int) -> void:
	var direction := _facing_direction()
	match skill:
		1:
			_spawn_projectile_for_slot(1)
		2:
			_spawn_projectile_for_slot(2, 2, {"offset": Vector2(direction * 60.0, -70.0)})
		3:
			_spawn_projectile_for_slot(
				3,
				3,
				{
					"offset": Vector2(direction * 95.0, -117.0),
					"follow_owner": true,
					"follow_owner_offset": Vector2(direction * 95.0, -117.0),
					"damage_enabled": false,
					"lifetime": 50.0 / SOURCE_FPS,
					"hold_last_frame": true
				}
			)
		4:
			_spawn_projectile_for_slot(
				4,
				4,
				{
					"spawn_position": Vector2(global_position.x - direction * 80.0, 500.0),
					"damage_enabled": true,
				}
			)
			_face_role()


func _emit_monster156_skill(skill: int) -> void:
	var direction := _facing_direction()
	match skill:
		1:
			_spawn_projectile_for_slot(
				1,
				2,
				{
					"folder": "skill2",
					"offset": Vector2(direction * 180.0, -140.0),
					"follow_owner": true,
					"follow_owner_offset": Vector2(direction * 180.0, -140.0)
				}
			)
		2:
			var effect := _spawn_projectile_for_slot(
				2,
				3,
				{
					"folder": "skill3",
					"offset": Vector2(direction * 110.0, -150.0),
					"follow_owner": true,
					"follow_owner_offset": Vector2(direction * 110.0, -150.0),
					"lifetime": 120.0 / SOURCE_FPS,
					"hold_last_frame": true
				}
			)
			call_deferred("_monster156_heal_loop", effect)
		3:
			_spawn_projectile_for_slot(
				3,
				1,
				{
					"folder": "skill1",
					"offset": Vector2.ZERO,
					"follow_owner": true,
					"follow_owner_offset": Vector2.ZERO,
					"lifetime": 40.0 / SOURCE_FPS,
					"collision_size": Vector2(115, 107),
				}
			)


func _monster156_heal_loop(effect: WutaiMinghaiProjectile) -> void:
	for _index in range(4):
		await get_tree().create_timer(1.0, false).timeout
		if (
			not is_instance_valid(self)
			or death()
			or effect == null
			or not is_instance_valid(effect)
			or effect.is_queued_for_deletion()
		):
			return
		cure_hp(1000 * _source_property_level())


func _emit_monster157_skill(skill: int) -> void:
	match skill:
		1:
			_spawn_projectile_for_slot(1)
		2:
			pass
		3, 4:
			pass


func _emit_monster158_skill(skill: int) -> void:
	var direction := _facing_direction()
	match skill:
		1:
			_spawn_projectile_for_slot(1, 1, {"offset": Vector2(direction * 150.0, -105.0)})
		2:
			_spawn_projectile_for_slot(2, 2, {"offset": Vector2(direction * 125.0, -55.0)})
		3:
			_spawn_projectile_for_slot(
				3,
				3,
				{
					"offset": Vector2(direction * 45.0, -85.0),
					"hit_interval": 30.0 / SOURCE_FPS,
					"hit_callback": Callable(self, "_monster158_reject_hp_on_hit"),
				}
			)
		4:
			_spawn_projectile_for_slot(
				4,
				4,
				{
					"offset": Vector2.ZERO,
					"hit_callback": Callable(self, "_monster158_heal_on_hit"),
				}
			)


func _emit_monster159_skill(skill: int) -> void:
	var direction := _facing_direction()
	match skill:
		1:
			_spawn_projectile_for_slot(1, 1, {"offset": Vector2(direction * 60.0, 45.0)})
		2:
			_monster159_bati = true
			speed = 8.0
			_monster159_shadow_elapsed = 0.0
			_spawn_projectile_for_slot(
				2,
				2,
				{
					"offset": Vector2(direction * 95.0, -25.0),
					"damage_enabled": false,
					"lifetime": float(_source_property_level() + 2),
					"hold_last_frame": true
				}
			)
			call_deferred("_monster159_end_bati")
		3:
			for _index in range(3 + randi_range(0, 2)):
				_spawn_projectile_for_slot(
					3, 3, {"spawn_position": Vector2(randf_range(100.0, 900.0), 510.0), "damage_enabled": true}
				)
		4:
			_spawn_projectile_for_slot(
				4,
				4,
				{
					"offset": Vector2(0.0, 80.0),
					"follow_owner": true,
					"follow_owner_offset": Vector2(0.0, 80.0),
					"lifetime": 3.0,
					"right": false
				}
			)


func _monster159_end_bati() -> void:
	await get_tree().create_timer(float(_source_property_level() + 2), false).timeout
	if not is_instance_valid(self):
		return
	_monster159_bati = false
	speed = 4.0
	velocity.x = 0.0


func _emit_monster162_skill(skill: int) -> void:
	var direction := _facing_direction()
	match skill:
		1:
			_spawn_projectile_for_slot(1, 1, {"offset": Vector2(direction * 30.0, 80.0)})
		2:
			_spawn_projectile_for_slot(
				2,
				2,
				{
					"offset": Vector2(-direction * 20.0, 85.0),
					"follow_owner": true,
					"follow_owner_offset": Vector2(-direction * 20.0, 85.0),
					"lifetime": 56.0 / SOURCE_FPS
				}
			)
		3:
			_spawn_projectile_for_slot(3, 3, {"offset": Vector2(direction * 45.0, 85.0)})


func _monster149_gaze_effect(_effect_position: Vector2) -> void:
	for target in _constellation_players():
		if target.need_protect:
			continue
		var target_faces_right := target.player_dir
		var in_gaze := false
		if target.global_position.x < global_position.x:
			in_gaze = target_faces_right and not _facing_right
		elif target.global_position.x > global_position.x:
			in_gaze = not target_faces_right and _facing_right
		if not in_gaze:
			continue
		target.effect_reducehp(500 * _source_property_level(), "real")
		target.set_meta("monster149_buff_until", Time.get_ticks_msec() + 10000)


func _constellation_players() -> Array[BaseHero]:
	var players: Array[BaseHero] = []
	for candidate: BaseHero in LocalCoop.living_players():
		if _is_alive_constellation_player(candidate):
			players.append(candidate)
	return players


func _is_alive_constellation_player(target: Node) -> bool:
	if target == null or not is_instance_valid(target) or not target is BaseHero:
		return false
	var player := target as BaseHero
	return not player.is_death and not player.death()


func _monster150_start_blackout(_effect_position: Vector2) -> void:
	var level_node := get_level_node()
	if level_node != null and level_node.has_method("start_constellation_blackout"):
		level_node.call("start_constellation_blackout", float(4 + _source_property_level()))


func _monster151_heal_on_hit(_projectile: WutaiMinghaiProjectile, target: BaseHero) -> void:
	if target == null or not is_instance_valid(target) or get_parent() == null:
		return
	var aura := HEAL_AURA_SCRIPT.new() as ConstellationHealAura
	if aura == null:
		return
	var target_position := target.global_position + Vector2(randf_range(-10.0, 10.0), randf_range(-10.0, 10.0))
	aura.configure(self, target_position, maxi(1, int(max_hp / 1000.0)))
	get_parent().add_child(aura)


func _monster151_start_drain_buff(_effect_position: Vector2) -> void:
	var target := _random_player()
	if target != null:
		call_deferred("_monster151_drain_target", target)


func _monster151_drain_target(target: Node2D) -> void:
	var drain_value := 100 * _source_property_level()
	for tick in range(3):
		if not _is_alive_constellation_player(target):
			return
		if target.has_method("reduce_mp"):
			target.call("reduce_mp", drain_value)
		if target.has_method("effect_reducehp"):
			target.call("effect_reducehp", drain_value, "real")
		if tick < 2:
			await get_tree().create_timer(1.0, false).timeout


func _monster158_reject_hp_on_hit(_projectile: WutaiMinghaiProjectile, target: BaseHero) -> void:
	if target == null or not is_instance_valid(target) or target.death():
		return
	var target_id := target.get_instance_id()
	if _monster158_reject_effects.has(target_id):
		var current: Dictionary = _monster158_reject_effects[target_id]
		current["remaining_ticks"] = 72
		_monster158_reject_effects[target_id] = current
		return
	_monster158_reject_effects[target_id] = {
		"target": target,
		"value": 250 * _source_property_level(),
		"remaining_ticks": 72,
		"pulse_ticks": 24,
	}


func _process_monster158_reject_effects(delta: float) -> void:
	if source_id != 158 or _monster158_reject_effects.is_empty():
		return
	_monster158_effect_accumulator += delta
	var source_tick := 1.0 / SOURCE_FPS
	while _monster158_effect_accumulator >= source_tick:
		_monster158_effect_accumulator -= source_tick
		for target_id in _monster158_reject_effects.keys():
			var effect: Dictionary = _monster158_reject_effects[target_id]
			var target := effect.get("target") as BaseHero
			if target == null or not is_instance_valid(target) or target.death():
				_monster158_reject_effects.erase(target_id)
				continue
			var remaining_ticks := int(effect.get("remaining_ticks", 0)) - 1
			var pulse_ticks := int(effect.get("pulse_ticks", 1)) - 1
			if pulse_ticks <= 0:
				var value := int(effect.get("value", 0))
				target.effect_reducehp(value, "real")
				cure_hp(value)
				pulse_ticks = 24
			if remaining_ticks <= 0:
				_monster158_reject_effects.erase(target_id)
			else:
				effect["remaining_ticks"] = remaining_ticks
				effect["pulse_ticks"] = pulse_ticks
				_monster158_reject_effects[target_id] = effect


func _monster158_heal_on_hit(_projectile: WutaiMinghaiProjectile, _target: BaseHero) -> void:
	cure_hp(100 * _source_property_level())


func _spawn_monster146_bullet4(direction: float) -> void:
	var count := randi_range(1, 2)
	var source_velocity_scale := SOURCE_FPS
	var source_acceleration_scale := SOURCE_FPS * SOURCE_FPS
	for _index in range(count):
		var spawn_position := global_position + Vector2((randf() - 0.5) * 1000.0, -300.0 - (randf() - 0.5) * 200.0)
		_spawn_projectile_for_slot(
			4,
			4,
			{
				"folder": "skill4",
				"spawn_position": spawn_position,
				"velocity": Vector2(direction * 3.0, 3.0) * source_velocity_scale,
				"acceleration": Vector2(direction * 0.3, 0.3) * source_acceleration_scale,
				"max_distance": 1000.0,
				"lifetime": 30.0,
				"loop_visual": true,
				"hold_last_frame": false,
				"damage_enabled": true,
				"damage_duration": 30.0,
				"expire_on_hit": false,
			}
		)


func _spawn_monster147_stones(direction: float) -> void:
	var target := _random_player()
	if target == null:
		return
	for index in range(5):
		var start_position := global_position + Vector2((2 - index) * 75.0, 75.0)
		var target_position := Vector2(start_position.x, global_position.y - 150.0 - float(index % 2) * 75.0)
		var rising := _spawn_projectile_for_slot(
			2,
			2,
			{
				"folder": "skill2",
				"spawn_position": start_position,
				"damage_enabled": false,
				"loop_visual": false,
				"hold_last_frame": true,
				"lifetime": 1.2,
			}
		)
		if rising == null:
			continue
		var tween := create_tween()
		tween.tween_property(rising, "global_position", target_position, 1.0)
		tween.tween_callback(Callable(self, "_spawn_monster147_stone_rise_finished").bind(rising, target, direction))


func _spawn_monster147_stone_rise_finished(rising: WutaiMinghaiProjectile, target: Node2D, direction: float) -> void:
	if rising == null or not is_instance_valid(rising):
		return
	var spawn_position := rising.global_position
	if not _is_alive_constellation_player(target):
		rising.queue_free()
		return
	var aim := spawn_position.direction_to(target.global_position)
	if aim.is_zero_approx():
		aim = Vector2(direction, 0.0)
	var source_velocity_scale := SOURCE_FPS
	var source_acceleration_scale := SOURCE_FPS * SOURCE_FPS
	_spawn_projectile_for_slot(
		2,
		2,
		{
			"folder": "skill2",
			"spawn_position": spawn_position,
			"right": direction > 0.0,
			"velocity": aim * 8.0 * source_velocity_scale,
			"acceleration": aim * source_acceleration_scale,
			"max_distance": 2000.0,
			"lifetime": 30.0,
			"loop_visual": true,
			"hold_last_frame": false,
			"damage_enabled": true,
			"damage_duration": 30.0,
			"expire_on_hit": false,
		}
	)
	rising.queue_free()


func _spawn_monster150_fireflies(direction: float) -> void:
	var target := _random_player()
	if target == null:
		return
	var count := randi_range(1, 5)
	var property_level := _source_property_level()
	var source_velocity_scale := SOURCE_FPS
	for _index in range(count):
		_spawn_projectile_for_slot(
			2,
			3,
			{
				"folder": "skill2",
				"spawn_position": global_position + Vector2((randf() - 0.5) * 100.0, (randf() - 0.5) * 100.0),
				"right": direction > 0.0,
				"target_node": target,
				"track_target": true,
				"velocity": Vector2(4.0, 4.0) * source_velocity_scale,
				"max_distance": 1000.0,
				"lifetime": float(property_level + 2),
				"loop_visual": true,
				"hold_last_frame": false,
				"damage_enabled": true,
				"damage_duration": float(property_level + 2),
				"expire_on_hit": false,
			}
		)


func _random_player() -> Node2D:
	var players: Array[BaseHero] = LocalCoop.living_players()
	if players.is_empty():
		return null
	return players[randi() % players.size()]


func _source_property_level() -> int:
	var level_node := get_level_node()
	if level_node != null and level_node.has_method("get_constellation_tier"):
		return clampi(int(level_node.call("get_constellation_tier")), 1, 10)
	return clampi(level - 90, 1, 10)


func _emit_monster140_skill(skill: int, stage: int) -> void:
	if death() or not _busy or source_id != 140:
		return
	var direction := _facing_direction()
	match skill:
		1:
			if stage == 1:
				_spawn_monster140_effect(
					"Monster140Bullet1",
					"skill1",
					global_position + Vector2(direction * 55.0, -125.0),
					"hit1",
					direction > 0.0
				)
		2:
			if stage == 1:
				_spawn_monster140_effect(
					"Monster140Bullet2_1",
					"skill2",
					global_position + Vector2(direction * 90.0, -115.0),
					"hit2",
					direction > 0.0
				)
			elif stage == 2:
				_spawn_monster140_effect(
					"Monster140Bullet2_2",
					"skill2_2",
					global_position + Vector2(0.0, 50.0),
					"hit2",
					direction > 0.0,
					false,
					Callable(self, "_monster140_hit2_3")
				)
		3:
			if stage == 1:
				_spawn_monster140_skill3()
		4:
			if stage == 1:
				_spawn_monster140_effect(
					"Monster140Bullet4",
					"skill4",
					global_position + Vector2(direction * 80.0, 10.0),
					"hit2",
					false,
					true,
					Callable(self, "_monster140_start_hit4")
				)


func _spawn_monster140_effect(
	effect_name: String,
	visual_folder: String,
	spawn_position: Vector2,
	action_name: String,
	right_facing: bool,
	disabled: bool = false,
	finished_callback: Callable = Callable(),
	lifetime_override: float = -1.0,
	hold_last: bool = false,
	pulse_interval: float = 0.0,
	target_interval: float = 0.0
) -> WutaiMinghaiProjectile:
	var frame_count := _skill_frame_count_from_folder(visual_folder)
	var collision_value: Variant = MONSTER140_EFFECT_COLLISION.get(effect_name, {})
	var collision: Dictionary = collision_value if collision_value is Dictionary else {}
	var visual_registration := _skill_visual_registration(visual_folder)
	var lifetime := float(frame_count) / MONSTER140_EFFECT_FPS
	if lifetime_override > 0.0:
		lifetime = lifetime_override
	var effect := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	(
		effect
		. configure(
			{
				"owner": self,
				"position": spawn_position,
				"right": right_facing,
				"hit_name": action_name,
				"attack_data": obj_attack_dict.get(action_name, {}),
				"skill_name": effect_name,
				"frame_root": _asset_root().path_join(visual_folder),
				"frames_resource": _standard_frames_resource_path(),
				"frames_animation": visual_folder,
				"atlas_sequence": visual_folder,
				"frame_count": frame_count,
				"frame_fps": MONSTER140_EFFECT_FPS,
				"loop_visual": false,
				"hold_last_frame": hold_last,
				"visual_offset": Vector2.ZERO,
				"visual_registration": visual_registration,
				"visual_faces_right": false,
				"velocity": Vector2.ZERO,
				"collision_size": collision.get("size", Vector2.ZERO),
				"collision_offset": collision.get("offset", Vector2.ZERO) + visual_registration,
				"lifetime": lifetime,
				"damage_duration": lifetime,
				"damage_pulse_interval": pulse_interval,
				"poll_overlaps_on_damage_pulse": true,
				"target_move_interval": target_interval,
				"max_hits": int((obj_attack_dict.get(action_name, {}) as Dictionary).get("hitMaxCount", 99)),
				"expire_on_hit": false,
				"damage_enabled": not disabled,
				"finished_callback": finished_callback,
			}
		)
	)
	bullet.add_child(effect)
	return effect


func _skill_frame_count_from_folder(folder: String) -> int:
	var frames := _standard_frames()
	var animation := StringName(folder)
	if frames != null and frames.has_animation(animation):
		return frames.get_frame_count(animation)
	var root := _asset_root().path_join(folder)
	for looped in [false, true]:
		for hold_last in [false, true]:
			if FrameSequenceStore.has_sequence(root, SOURCE_FPS, looped, hold_last, 2):
				return FrameSequenceStore.get_sequence(root, SOURCE_FPS, looped, hold_last, 2).count()
	return 1


func _spawn_monster140_skill3() -> void:
	var target := _monster140_random_player()
	if target == null:
		return
	_spawn_monster140_skill3_effect(target, "skill3", "Monster140Bullet3_1")
	call_deferred("_spawn_monster140_delayed_skill3", target, "skill3_2", "Monster140Bullet3_2", randf() / 2.0)
	call_deferred("_spawn_monster140_delayed_skill3", target, "skill3_3", "Monster140Bullet3_3", randf() / 2.0)


func _spawn_monster140_delayed_skill3(target: Node2D, visual_folder: String, effect_name: String, delay: float) -> void:
	await get_tree().create_timer(delay, false).timeout
	if death() or not is_instance_valid(target):
		return
	_spawn_monster140_skill3_effect(target, visual_folder, effect_name)


func _spawn_monster140_skill3_effect(target: Node2D, visual_folder: String, effect_name: String) -> void:
	var spawn_position := Vector2(target.global_position.x - randf() * 100.0, 500.0)
	_spawn_monster140_effect(effect_name, visual_folder, spawn_position, "hit3", false)


func _monster140_random_player() -> Node2D:
	return _random_player()


func _monster140_hit2_3(effect_position: Vector2) -> void:
	if death():
		return
	if _body_stream != null and is_instance_valid(_body_stream):
		_body_stream.visible = false
		_body_stream.set_process(false)
	_monster140_body_hidden = true
	_monster140_buried = true
	_invulnerable_forever = true
	_invulnerable_until_msec = 0
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)
	_spawn_monster140_effect(
		"Monster140Bullet2_3",
		"skill2_3",
		effect_position,
		"hit2_2",
		false,
		false,
		Callable(self, "_monster140_hit2_4"),
		5.0,
		true,
		1.0,
		2.0
	)


func _monster140_hit2_4(effect_position: Vector2) -> void:
	if death():
		return

	_monster140_emergence_pending = 2
	_spawn_monster140_effect(
		"Monster140Bullet2_2", "skill2_2", effect_position, "hit2", false, false, Callable(self, "_monster140_hit2_5")
	)
	_spawn_monster140_effect(
		"Monster140Bullet2_4",
		"skill2_4",
		effect_position + Vector2(0.0, -100.0),
		"hit2",
		false,
		false,
		Callable(self, "_monster140_hit2_5")
	)


func _monster140_hit2_5(effect_position: Vector2) -> void:
	if death():
		return
	global_position = Vector2(effect_position.x, effect_position.y - 60.0)
	if _body_stream != null and is_instance_valid(_body_stream):
		_body_stream.visible = true
		_body_stream.set_process(true)
	_monster140_body_hidden = false
	_monster140_emergence_pending = maxi(_monster140_emergence_pending - 1, 0)

	_monster140_buried = false
	_invulnerable_forever = false
	_invulnerable_until_msec = Time.get_ticks_msec() + int(10.0 * 1000.0 / SOURCE_FPS)
	if hurt_box != null:
		hurt_box.set_deferred("disabled", false)
	_next_attack_msec = Time.get_ticks_msec() + int(10.0 * 1000.0 / SOURCE_FPS)


func _monster140_start_hit4(effect_position: Vector2) -> void:
	var level_node := get_level_node()
	if level_node == null or not level_node.has_method("spawn_constellation_summon"):
		return
	var summon := (
		level_node.call("spawn_constellation_summon", 47115, effect_position + Vector2(0.0, -50.0)) as BaseMonster
	)
	if summon != null:
		summon.set_meta("constellation_summon", true)
		summon.set_meta("constellation_summoner", self)
		_expire_monster140_summon(summon)


func _expire_monster140_summon(summon: BaseMonster) -> void:
	await get_tree().create_timer(15.0, false).timeout
	if is_instance_valid(summon) and not summon.is_queued_for_deletion():
		summon.queue_free()


func _monster141_spawn_children() -> void:
	if source_id != 141 or get_meta("constellation_summon_children_spawned", false):
		return
	set_meta("constellation_summon_children_spawned", true)
	var level_node := get_level_node()
	if level_node == null or not level_node.has_method("spawn_constellation_summon"):
		return
	for offset in [Vector2(-30.0, -80.0), Vector2(30.0, -80.0)]:
		var child := level_node.call("spawn_constellation_summon", 47115, global_position + offset) as BaseMonster
		if child != null:
			child.set_meta("constellation_summon", true)
			child.set_meta("constellation_summoner", get_meta("constellation_summoner", null))
			_expire_monster140_summon(child)


func _run_melee_pulses(skill: int, serial: int) -> void:
	var pulses := 1 if skill == 1 else 3
	_set_attack_box(Vector2(190, 135), Vector2(-105, -70))
	for index in range(pulses):
		if death() or serial != _attack_serial:
			break
		_enable_attack_box()
		await get_tree().physics_frame
		_disable_attack_box()
		if index + 1 < pulses:
			await get_tree().create_timer(0.14).timeout


func _spawn_skill_sequence(skill: int, allow_damage: bool, serial: int) -> void:
	var stage_count := _skill_stage_count(skill)
	if stage_count <= 0:
		_spawn_projectile(skill, allow_damage, 0)
		return
	for stage_index in range(1, stage_count + 1):
		if death() or serial != _attack_serial:
			return
		_spawn_projectile(skill, allow_damage, stage_index)
		if stage_index < stage_count:
			await get_tree().create_timer(0.12).timeout


func _spawn_projectile(skill: int, allow_damage: bool = true, stage_index: int = 0) -> void:
	var options := {
		"stage_index": stage_index,
		"damage_enabled": allow_damage,
	}
	_spawn_projectile_for_slot(skill, skill, options)


func _spawn_projectile_for_slot(skill: int, attack_slot: int = -1, options: Dictionary = {}) -> WutaiMinghaiProjectile:
	var direction := _facing_direction()
	var resolved_attack_slot := attack_slot if attack_slot > 0 else skill
	var hit_name_value: Variant = options.get("hit_name", "hit%d" % resolved_attack_slot)
	var resolved_hit_name := str(hit_name_value)
	var attack_value: Variant = options.get("attack_data", obj_attack_dict.get(resolved_hit_name, {}))
	var attack_data: Dictionary = attack_value as Dictionary if attack_value is Dictionary else {}
	var stage_index := int(options.get("stage_index", 0))
	var folder_value: Variant = options.get("folder", "")
	var folder := str(folder_value)
	if folder.is_empty():
		folder = "skill%d" % skill if stage_index <= 0 else "skill%d_%d" % [skill, stage_index]
	var frame_count := int(options.get("frame_count", _skill_frame_count_from_folder(folder)))
	var frame_fps := float(options.get("frame_fps", SOURCE_FPS))
	var visual_offset_value: Variant = options.get("visual_offset", Vector2.ZERO)
	var resolved_visual_offset := visual_offset_value as Vector2 if visual_offset_value is Vector2 else Vector2.ZERO
	var visual_registration_value: Variant = options.get("visual_registration", _skill_visual_registration(folder))
	var resolved_visual_registration := (
		visual_registration_value as Vector2 if visual_registration_value is Vector2 else Vector2.ZERO
	)
	var offset_value: Variant = options.get("offset", _skill_spawn_offset(skill, direction, stage_index))
	var offset := offset_value as Vector2 if offset_value is Vector2 else Vector2.ZERO
	var spawn_value: Variant = options.get("spawn_position", global_position + offset)
	var spawn_position := spawn_value as Vector2 if spawn_value is Vector2 else global_position + offset
	var velocity_value: Variant = options.get("velocity", Vector2.ZERO)
	var motion_velocity := velocity_value as Vector2 if velocity_value is Vector2 else Vector2.ZERO
	var acceleration_value: Variant = options.get("acceleration", Vector2.ZERO)
	var motion_acceleration := acceleration_value as Vector2 if acceleration_value is Vector2 else Vector2.ZERO
	var lifetime := float(options.get("lifetime", maxf(float(frame_count) / frame_fps, 0.05)))
	var projectile := PROJECTILE_SCRIPT.new() as WutaiMinghaiProjectile
	var target_value: Variant = options.get("target_node", null)
	var right_facing := bool(options.get("right", direction > 0.0))
	(
		projectile
		. configure(
			{
				"owner": self,
				"position": spawn_position,
				"right": right_facing,
				"hit_name": resolved_hit_name,
				"attack_data": attack_data,
				"skill_name": str(options.get("skill_name", "Constellation%dSkill%d" % [source_id, skill])),
				"frame_root": _asset_root().path_join(folder),
				"frames_resource": _standard_frames_resource_path(),
				"frames_animation": folder,
				"atlas_sequence": folder,
				"frame_count": frame_count,
				"frame_fps": frame_fps,
				"loop_visual": bool(options.get("loop_visual", false)),
				"hold_last_frame": bool(options.get("hold_last_frame", false)),
				"visual_offset": resolved_visual_offset,
				"visual_registration": resolved_visual_registration,
				"visual_faces_right": bool(options.get("visual_faces_right", false)),
				"velocity": motion_velocity,
				"acceleration": motion_acceleration,
				"orient_to_motion": bool(options.get("orient_to_motion", false)),
				"follow_owner": bool(options.get("follow_owner", false)),
				"follow_owner_offset": options.get("follow_owner_offset", Vector2.ZERO),
				"target_node": target_value,
				"target_offset": options.get("target_offset", Vector2.ZERO),
				"track_target": bool(options.get("track_target", false)),
				"max_distance": float(options.get("max_distance", 0.0)),
				"collision_size": options.get("collision_size", Vector2.ZERO),
				"collision_offset":
				options.get("collision_offset", resolved_visual_offset + resolved_visual_registration),
				"damage_enabled": bool(options.get("damage_enabled", true)) and not attack_data.is_empty(),
				"damage_enable_delay": float(options.get("damage_enable_delay", 0.0)),
				"hit_delay": float(options.get("hit_delay", 0.0)),
				"damage_duration": float(options.get("damage_duration", lifetime)),
				"hit_interval": float(options.get("hit_interval", attack_data.get("attackInterval", 0.16))),
				"damage_pulse_interval": float(options.get("damage_pulse_interval", 0.0)),
				"poll_overlaps_on_damage_pulse": true,
				"max_hits": int(options.get("max_hits", attack_data.get("hitMaxCount", 99))),
				"lifetime": lifetime,
				"expire_on_hit": bool(options.get("expire_on_hit", false)),
				"finished_callback": options.get("finished_callback", Callable()),
				"hit_callback": options.get("hit_callback", Callable()),
			}
		)
	)
	bullet.add_child(projectile)
	return projectile


func _skill_visual_registration(folder: String) -> Vector2:
	var source_value: Variant = SKILL_REGISTRATIONS.get(source_id, {})
	var source_registrations: Dictionary = source_value if source_value is Dictionary else {}
	var registration_value: Variant = source_registrations.get(folder, Vector2.ZERO)
	return registration_value as Vector2 if registration_value is Vector2 else Vector2.ZERO


func _skill_spawn_offset(skill: int, direction: float, stage_index: int = 0) -> Vector2:
	var source_offsets_value: Variant = SKILL_OFFSETS.get(source_id, {})
	var source_offsets: Dictionary = source_offsets_value if source_offsets_value is Dictionary else {}
	var offset_value: Variant = source_offsets.get(skill, Vector2(direction * 55.0, -55.0))
	var offset := offset_value as Vector2 if offset_value is Vector2 else Vector2(direction * 55.0, -55.0)
	var mirror_x := true
	if source_id == 140 and skill == 2 and stage_index >= 2:
		if stage_index == 2:
			offset = Vector2(0.0, 50.0)
		else:
			offset = Vector2(0.0, -100.0)
			if RoleProp.get_nearest_monster_target_position(global_position).x != null:
				offset.x = float(RoleProp.get_nearest_monster_target_position(global_position).x) - global_position.x
				mirror_x = false
	elif source_id == 140 and skill == 3:
		offset = Vector2(0.0, 445.0)
		if RoleProp.get_nearest_monster_target_position(global_position).x != null:
			offset.x = float(RoleProp.get_nearest_monster_target_position(global_position).x) - global_position.x
			mirror_x = false

	if source_id == 152 and skill == 4:
		offset.x = -absf(offset.x) * direction
		offset.y = 445.0
		mirror_x = false
	elif source_id == 162 and skill == 2:
		offset.x = -absf(offset.x) * direction
		mirror_x = false
	elif source_id == 159 and skill == 3:
		offset.y = 445.0
		if RoleProp.get_nearest_monster_target_position(global_position).x != null:
			offset.x = float(RoleProp.get_nearest_monster_target_position(global_position).x) - global_position.x
			mirror_x = false
	if mirror_x:
		offset.x *= direction
	return offset


func _skill_stage_count(skill: int) -> int:
	var prefix := "skill%d_" % skill
	var suffixes: Array[int] = []
	var frames := _standard_frames()
	if frames != null:
		for animation in frames.get_animation_names():
			var animation_name := String(animation)
			if not animation_name.begins_with(prefix):
				continue
			var animation_suffix := animation_name.trim_prefix(prefix)
			if animation_suffix.is_valid_int() and int(animation_suffix) > 1:
				suffixes.append(int(animation_suffix))
	if suffixes.is_empty():
		var root := _asset_root()
		for suffix in range(2, 21):
			var stage_root := root.path_join("skill%d_%d" % [skill, suffix])
			if not FrameSequenceStore.has_sequence(stage_root, SOURCE_FPS, false, false, 2):
				break
			suffixes.append(suffix)
	suffixes.sort()
	var expected := 2
	for suffix in suffixes:
		if suffix != expected:
			break
		expected += 1
	return expected - 1


func _spawn_source_summon(project_id: int, offset: Vector2, lifetime: float) -> void:
	var level_node := get_level_node()
	if level_node == null:
		return
	if not level_node.has_method("spawn_constellation_summon"):
		return
	var summon := level_node.call("spawn_constellation_summon", project_id, global_position + offset) as BaseMonster
	if summon != null:
		summon.set_meta("constellation_summon", true)
		summon.set_meta("constellation_summoner", self)
		if lifetime > 0.0:
			_expire_constellation_summon(summon, lifetime)


func _expire_constellation_summon(summon: BaseMonster, lifetime: float) -> void:
	await get_tree().create_timer(lifetime, false).timeout
	if is_instance_valid(summon) and not summon.is_queued_for_deletion():
		summon.queue_free()


func _set_attack_box(size: Vector2, offset: Vector2) -> void:
	var rectangle := hit_box.shape as RectangleShape2D
	if rectangle == null:
		rectangle = RectangleShape2D.new()
		hit_box.shape = rectangle
	rectangle.size = size
	hit_box.position = offset


func _enable_attack_box() -> void:
	if hit_box != null:
		hit_box.set_deferred("disabled", false)


func _disable_attack_box() -> void:
	if hit_box != null:
		hit_box.set_deferred("disabled", true)


func _face_role() -> void:
	var target_position_value: Variant = _active_target_global_position()
	if target_position_value == null:
		return
	var target_position := target_position_value as Vector2
	var direction := 1.0 if target_position.x >= global_position.x else -1.0
	_set_facing_direction(direction)


func _active_target_global_position() -> Variant:
	var target: BaseHero = null
	var target_distance := INF
	for candidate: BaseHero in LocalCoop.living_players():
		var distance := global_position.distance_squared_to(candidate.global_position)
		if distance < target_distance:
			target_distance = distance
			target = candidate
	if target == null:
		return null
	return target.global_position


func _set_facing_direction(direction: float) -> void:
	_facing_right = direction > 0.0

	monster_dir.scale.x = 1.0
	base_damage_box.scale.x = -direction
	if _body_stream != null and is_instance_valid(_body_stream):
		_body_stream.call("set_face_right", _facing_right)


func _facing_direction() -> float:
	return 1.0 if _facing_right else -1.0


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	_continue_official_attack_motion(delta)
	_process_monster158_reject_effects(delta)
	_process_monster159_shadows(delta)
	if source_id in [146, 147, 149, 150, 151, 152, 156, 157, 158, 159, 162]:
		if global_position.x > 1100.0:
			global_position.x = 800.0
		elif global_position.x < -100.0:
			global_position.x = 100.0
	if _monster157_dash_active:
		_monster157_dash_elapsed += delta
		_monster157_check_dash_collision()
		if _monster157_dash_elapsed >= 30.0 / SOURCE_FPS:
			_monster157_end_dash()


func _process_monster159_shadows(delta: float) -> void:
	if source_id != 159 or not _monster159_bati or _body_stream == null or not is_instance_valid(_body_stream):
		return
	_monster159_shadow_elapsed += delta
	if _monster159_shadow_elapsed < 4.0 / SOURCE_FPS:
		return
	_monster159_shadow_elapsed = fmod(_monster159_shadow_elapsed, 4.0 / SOURCE_FPS)
	var body_sprite := _body_stream.get_child(0) as Sprite2D if _body_stream.get_child_count() > 0 else null
	if body_sprite == null or body_sprite.texture == null or get_parent() == null:
		return
	var shadow := Sprite2D.new()
	shadow.centered = body_sprite.centered
	shadow.texture = body_sprite.texture
	shadow.flip_h = body_sprite.flip_h
	shadow.modulate = Color.WHITE
	shadow.z_index = z_index - 1
	get_parent().add_child(shadow)
	shadow.global_position = body_sprite.global_position
	var tween := shadow.create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(shadow, "modulate", Color(1.0, 1.0, 1.0, 0.0), 1.0)
	tween.tween_callback(shadow.queue_free)


func _on_hurt_box_area_entered(area: Area2D) -> void:
	if _is_constellation_invulnerable():
		return
	var hp_before := hp
	super._on_hurt_box_area_entered(area)
	if source_id == 147 and hp < hp_before and _monster147_guard_active():
		_monster147_launch_guard(_random_player())


func is_control_immune() -> bool:
	return _is_constellation_invulnerable() or super.is_control_immune()


func play_hit_effect(attacker = null) -> void:
	if _is_constellation_invulnerable():
		return
	super.play_hit_effect(attacker)


func resolve_friendly_damage(base_damage: int, attack_kind: String, attacker: Node = null) -> int:
	if _is_constellation_invulnerable():
		return 0
	return super.resolve_friendly_damage(base_damage, attack_kind, attacker)


func receive_friendly_damage(base_damage: int, attack_kind: String, attacker: Node = null) -> int:
	if _is_constellation_invulnerable():
		return 0
	if _monster152_absorbing_damage():
		var resolved := super.resolve_friendly_damage(base_damage, attack_kind, attacker)
		cure_hp(resolved)
		return 0
	var hp_before := hp
	var dealt := super.receive_friendly_damage(base_damage, attack_kind, attacker)
	if source_id == 147 and hp < hp_before and _monster147_guard_active():
		_monster147_launch_guard(attacker as Node2D)
	return dealt


func receive_reflected_damage(base_damage: int, attack_kind: String, penetration: int = 0) -> int:
	if _is_constellation_invulnerable():
		return 0
	if _monster152_absorbing_damage():
		cure_hp(base_damage)
		return 0
	return super.receive_reflected_damage(base_damage, attack_kind, penetration)


func reduce_pet_hp(value: int, attack_kind: String) -> int:
	if _is_constellation_invulnerable():
		return 0
	if _monster152_absorbing_damage():
		cure_hp(value)
		return 0
	return super.reduce_pet_hp(value, attack_kind)


func reduce_hp(value: int):
	if _is_constellation_invulnerable():
		return
	if _monster152_absorbing_damage():
		cure_hp(value)
		return 0
	super.reduce_hp(value)


func hd_reduce(value):
	if _is_constellation_invulnerable():
		return 0
	return super.hd_reduce(value)


func hurt_reduce_hp(value, target):
	if _is_constellation_invulnerable():
		return 0
	if _monster152_absorbing_damage():
		cure_hp(int(value))
		return 0
	return super.hurt_reduce_hp(value, target)


func _monster152_absorbing_damage() -> bool:
	return source_id == 152 and _busy and _skill_cycle == 3


func _monster147_launch_guard(target: Node2D) -> void:
	if not _monster147_guard_active():
		return
	if target == null or not is_instance_valid(target):
		return
	var guard := _monster147_guard_stone
	var guard_position := guard.global_position
	var destination_x := (
		target.global_position.x + 600.0
		if guard_position.x < target.global_position.x
		else target.global_position.x - 600.0
	)
	guard.launch_linear(Vector2((destination_x - guard_position.x) / 2.0, 0.0), 2.0)
	_monster147_guard_stone = null


func _interrupt_attack_state_on_hit() -> void:
	if _monster159_bati or _monster157_alpha_active:
		return
	super._interrupt_attack_state_on_hit()


func state_hurt() -> void:
	if death() or _busy or _monster159_bati or _monster157_alpha_active:
		return
	super.state_hurt()


func state_death() -> void:
	if _death_started:
		return
	_death_started = true
	_attack_serial += 1
	_busy = true
	_disable_attack_box()
	_clear_owned_projectiles()
	if hurt_box != null:
		hurt_box.set_deferred("disabled", true)
	if not _death_notified:
		_death_notified = true
		var level_node := get_level_node()
		if level_node != null and level_node.has_method("on_constellation_boss_defeated"):
			level_node.call_deferred("on_constellation_boss_defeated", self)
	if source_id == 141:
		_monster141_spawn_children()

		settle_death_drops()
		queue_free()
		return
	super.state_death()


func _clear_owned_projectiles() -> void:
	if bullet == null:
		return
	for child in bullet.get_children():
		if child != null:
			child.queue_free()


func _clear_body_stream() -> void:
	if _body_stream != null and is_instance_valid(_body_stream):
		_body_stream.clear_texture()
		_body_stream.queue_free()
	_body_stream = null


func _exit_tree() -> void:
	_clear_body_stream()

# ==============================================================================
# Phase 7-1: 高频多态弹幕与状态虚函数向后兼容代理
# ==============================================================================
