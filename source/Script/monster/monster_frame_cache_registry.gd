extends RefCounted

## 19-2D：怪物模块静态帧/几何缓存的唯一清理入口。
## 缓存只在档案退出/应用退出时释放；同一档案内的关卡切换保留不可变帧缓存。
const FRAME_CACHE_SCRIPTS := [
	preload("res://Script/monster/constellation_boss.gd"),
	preload("res://Script/monster/east_continent_monster.gd"),
	preload("res://Script/monster/emei_boss3040.gd"),
	preload("res://Script/monster/emei_boss3041.gd"),
	preload("res://Script/monster/emei_mountain_monster.gd"),
	preload("res://Script/monster/fire_ancestor_boss.gd"),
	preload("res://Script/monster/fire_ancestor_orb.gd"),
	preload("res://Script/monster/four_headed_boss.gd"),
	preload("res://Script/monster/jiuhua_mountain_monster.gd"),
	preload("res://Script/monster/jiuhua_pine_arrow.gd"),
	preload("res://Script/monster/linggan_king_boss.gd"),
	preload("res://Script/monster/minghai_boss3117.gd"),
	preload("res://Script/monster/monster130_bullet.gd"),
	preload("res://Script/monster/monster212_bullet1.gd"),
	preload("res://Script/monster/monster212_bullet2.gd"),
	preload("res://Script/monster/monster212_bullet3.gd"),
	preload("res://Script/monster/monster212_bullet4.gd"),
	preload("res://Script/monster/monster215_bullet1.gd"),
	preload("res://Script/monster/monster215_bullet2.gd"),
	preload("res://Script/monster/monster_1460.gd"),
	preload("res://Script/monster/monster_3012.gd"),
	preload("res://Script/monster/monster_3370.gd"),
	preload("res://Script/monster/monster_65.gd"),
	preload("res://Script/monster/monster_zhw/monster_143_zhw.gd"),
	preload("res://Script/monster/nanhai_monster.gd"),
	preload("res://Script/monster/nanhai_projectile.gd"),
	preload("res://Script/monster/shenguang_jinling_boss.gd"),
	preload("res://Script/monster/shuangxi_boss_arrow.gd"),
	preload("res://Script/monster/shuangxi_temple_monster.gd"),
	preload("res://Script/monster/three_prince_boss.gd"),
	preload("res://Script/monster/three_prince_bullet.gd"),
	preload("res://Script/monster/water_ancestor_boss.gd"),
	preload("res://Script/monster/weiyang_palace_boss.gd"),
	preload("res://Script/monster/wutai_boss3069.gd"),
	preload("res://Script/monster/wutai_boss3070.gd"),
	preload("res://Script/monster/wutai_earth_ancestor3077.gd"),
	preload("res://Script/monster/wutai_earth_ancestor3078.gd"),
	preload("res://Script/monster/wutai_guardian3076.gd"),
	preload("res://Script/monster/wutai_minghai_monster.gd"),
	preload("res://Script/monster/wutai_minghai_projectile.gd"),
	preload("res://Script/monster/xuanwu_gate_arrow.gd"),
	preload("res://Script/monster/xuanwu_gate_monster.gd"),
	preload("res://Script/monster/zhuque_street_monster.gd"),
	preload("res://Script/monster/zhuque_tiger_arrow.gd"),
]

const RUNTIME_CACHE_SCRIPTS := [
	preload("res://Script/monster/monster_bullet.gd"),
]

const SWORD_BOSS_CACHE_SCRIPTS := [
	preload("res://Script/monster/sword_boss_base.gd"),
]

const EFFECT_CACHE_SCRIPTS := [
	preload("res://Script/monster/monster_zhw/guanyin_normal_attack_effect.gd"),
	preload("res://Script/monster/monster_zhw/guanyin_skill2_effect.gd"),
	preload("res://Script/monster/monster_zhw/guanyin_skill_a_effect.gd"),
	preload("res://Script/monster/monster_zhw/guanyin_summon.gd"),
]


static func clear_all() -> int:
	var cleared := 0
	for script_value in FRAME_CACHE_SCRIPTS:
		script_value.clear_cached_frames()
		cleared += 1
	for script_value in RUNTIME_CACHE_SCRIPTS:
		script_value.clear_runtime_resource_caches()
		cleared += 1
	for script_value in SWORD_BOSS_CACHE_SCRIPTS:
		script_value.clear_prewarmed_sword_boss_frames()
		cleared += 1
	for script_value in EFFECT_CACHE_SCRIPTS:
		script_value.clear_cached_data()
		cleared += 1
	return cleared
