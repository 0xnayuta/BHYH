extends Node

## 法宝/角色特效构建期帧资源运行时探针。
## 验证诛仙剑阵、青莲、青龙剑/太极、八仙法宝、Lyfb 兼容特效与哪吒阴阳特效。
## 由 scripts/scene_probe_runner.py 复制到工程根目录执行。

const RESULT_PREFIX := "MAGIC_WEAPON_PROBE_RESULT="
const TEARDOWN_MARKER := "MAGIC_WEAPON_PROBE_TEARDOWN"
const MAIN_SWORD_SCENE := "res://Scene/magic_weapon/main_sword_array_weapon.tscn"
const QING_LIAN_SCENE := "res://Scene/magic_weapon/qing_lian.tscn"
const QLSWORD_SCENE := "res://Scene/magic_weapon/qlsword.tscn"
const TAIJI_SCENE := "res://Scene/magic_weapon/taiji_bagua.tscn"
const QLSWORD_FRAMES := "res://Art/magic_weapon/magic_weapon_qlsword/official/magic_big_sword_frames.tres"
const TAIJI_EFFECT_FRAMES := "res://Art/magic_weapon/taiji_bagua/effect/taiji_bagua_effect_frames.tres"
const EIGHT_IMMORTAL := {
	"bjs": {"scene": "res://Scene/magic_weapon/eight_immortal_bjs.tscn", "effect": 10, "animations": ["wait", "hit"]},
	"dkhl": {"scene": "res://Scene/magic_weapon/eight_immortal_dkhl.tscn", "effect": 100, "animations": ["wait", "hit"]},
	"hehua": {"scene": "res://Scene/magic_weapon/eight_immortal_hehua.tscn", "effect": 1, "animations": ["wait", "hit"]},
	"sxyg": {"scene": "res://Scene/magic_weapon/eight_immortal_sxyg.tscn", "effect": 16, "animations": ["wait", "hit"]},
	"ywhl": {"scene": "res://Scene/magic_weapon/eight_immortal_ywhl.tscn", "effect": 0, "animations": ["wait", "hit"]},
	"yyb": {"scene": "res://Scene/magic_weapon/eight_immortal_yyb.tscn", "effect": 1, "animations": ["wait", "hit"]},
	"yyzlj": {"scene": "res://Scene/magic_weapon/eight_immortal_yyzlj.tscn", "effect": 1, "animations": ["wait", "hit1", "hit2", "hit3"]},
	"zhyx": {"scene": "res://Scene/magic_weapon/eight_immortal_zhyx.tscn", "effect": 20, "animations": ["wait", "hit"]},
}
const HERO_EFFECTS := {
	"lyfb_skill07": {
		"path": "res://Art/hero_picture/role_2/lyfb_awaken/runtime/lyfb_awaken_skill07_frames.tres",
		"animation": "skill07", "count": 16, "loop": false, "speed": 30.0, "durations": [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0],
	},
	"nezha_sword_yin": {
		"path": "res://Art/hero_picture/role_6/effects/nezha_yin_yang_sword_yin_frames.tres",
		"animation": "yinYang_sword", "count": 1, "loop": false, "speed": 1.0, "durations": [1.0],
	},
	"nezha_sword_yang": {
		"path": "res://Art/hero_picture/role_6/effects/nezha_yin_yang_sword_yang_frames.tres",
		"animation": "yinYang_sword", "count": 1, "loop": false, "speed": 1.0, "durations": [1.0],
	},
	"nezha_aura_toggle": {
		"path": "res://Art/hero_picture/role_6/effects/nezha_yin_yang_aura_frames.tres",
		"animation": "yinYang_aura_toggle", "count": 8, "loop": false, "speed": 30.0, "durations": [2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0],
	},
	"nezha_aura_yin": {
		"path": "res://Art/hero_picture/role_6/effects/nezha_yin_yang_aura_frames.tres",
		"animation": "yinYang_aura_yin", "count": 4, "loop": false, "speed": 30.0, "durations": [2.0, 2.0, 2.0, 2.0],
	},
	"nezha_aura_yang": {
		"path": "res://Art/hero_picture/role_6/effects/nezha_yin_yang_aura_frames.tres",
		"animation": "yinYang_aura_yang", "count": 4, "loop": false, "speed": 30.0, "durations": [2.0, 2.0, 2.0, 2.0],
	},
	"nezha_launch_yin": {
		"path": "res://Art/hero_picture/role_6/effects/nezha_yin_yang_launch_yin_frames.tres",
		"animation": "yinYang_launch", "count": 6, "loop": false, "speed": 30.0, "durations": [1.0, 1.0, 2.0, 2.0, 2.0, 2.0],
	},
	"nezha_launch_yang": {
		"path": "res://Art/hero_picture/role_6/effects/nezha_yin_yang_launch_yang_frames.tres",
		"animation": "yinYang_launch", "count": 6, "loop": false, "speed": 30.0, "durations": [1.0, 1.0, 2.0, 2.0, 2.0, 2.0],
	},
}
const SWORD_BODIES := {
	"zhuxianjian": "res://Art/zhuxianjianzhen/sword_hover/sword1/sprites/DefineSprite_3_idle",
	"xianxianjian": "res://Art/zhuxianjianzhen/sword_hover/sword2/sprites/DefineSprite_3_idle",
	"sijianheyi": "res://Art/zhuxianjianzhen/sword_hover/sword3/sprites/DefineSprite_3_idle",
	"luxianjian": "res://Art/zhuxianjianzhen/sword_hover/sword4/sprites/DefineSprite_3_idle",
	"juexianjian": "res://Art/zhuxianjianzhen/sword_hover/sword5/sprites/DefineSprite_3_idle",
}


func _ready() -> void:
	var checks := {}
	var qing_lian := _instantiate(QING_LIAN_SCENE)
	checks["qing_lian_idle"] = _frame_check(_sprite_frames(qing_lian.get_node("MgAction")), "wait", 24, true, 12.0)
	checks["qing_lian_effect"] = _frame_check(_sprite_frames(qing_lian.get_node("SpecialEffect")), "effect", 14, false, 30.0)
	checks["qing_lian_aura"] = _frame_check(_sprite_frames(qing_lian.get_node("AuraEffect")), "effect", 8, true, 10.0)
	_free(qing_lian)

	var qlsword := _instantiate(QLSWORD_SCENE)
	var qlsword_frames := _sprite_frames(qlsword.get_node("MgAction"))
	checks["qlsword_wait"] = _frame_check(qlsword_frames, "wait", 1, true, 5.0)
	checks["qlsword_hit"] = _frame_check(qlsword_frames, "hit", 1, true, 5.0)
	checks["qlsword_resource"] = _has_animations(load(QLSWORD_FRAMES) as SpriteFrames, ["wait", "hit"])
	_free(qlsword)

	var taiji := _instantiate(TAIJI_SCENE)
	var taiji_frames := _sprite_frames(taiji.get_node("MgAction"))
	checks["taiji_wait"] = _frame_check(taiji_frames, "wait", 1, true, 5.0)
	checks["taiji_hit"] = _frame_check(taiji_frames, "hit", 1, true, 5.0)
	checks["taiji_effect"] = _frame_check(load(TAIJI_EFFECT_FRAMES) as SpriteFrames, "default", 22, false, 24.0)
	_free(taiji)

	var eight_checks := {}
	for weapon_id in EIGHT_IMMORTAL:
		var spec: Dictionary = EIGHT_IMMORTAL[weapon_id]
		var eight := _instantiate(str(spec["scene"]))
		var model_ok := _has_animations(_sprite_frames(eight.get_node("MgAction")), spec["animations"])
		var effect := eight.get("effect_frames") as SpriteFrames
		var effect_count := int(spec["effect"])
		var effect_ok := (
			effect == null
			if effect_count == 0
			else _frame_check(effect, "default", effect_count, true, 24.0)
		)
		eight_checks[weapon_id] = model_ok and effect_ok
		_free(eight)
	checks["eight_immortal"] = eight_checks

	var hero_checks := {}
	for effect_name in HERO_EFFECTS:
		var spec: Dictionary = HERO_EFFECTS[effect_name]
		var frames := load(str(spec["path"])) as SpriteFrames
		hero_checks[effect_name] = (
			_frame_check(frames, str(spec["animation"]), int(spec["count"]), bool(spec["loop"]), float(spec["speed"]))
			and _duration_check(frames, str(spec["animation"]), spec["durations"])
		)
	checks["hero_effects"] = hero_checks

	var sword := _instantiate(MAIN_SWORD_SCENE)
	var sword_checks := {}
	for sword_id in SWORD_BODIES:
		sword.call("set_sword_id", sword_id)
		var sprite := sword.get_node("Sprite2D") as AnimatedSprite2D
		var body := str(SWORD_BODIES[sword_id])
		sword_checks[sword_id] = (
			sprite.sprite_frames != null
			and sprite.sprite_frames.has_animation(body)
			and sprite.animation == StringName(body)
		)
	checks["swords"] = sword_checks
	_free(sword)

	var failures: Array[String] = []
	for key in checks:
		var value: Variant = checks[key]
		if value is bool and not value:
			failures.append(str(key))
		elif value is Dictionary:
			for sub_key in value:
				if not value[sub_key]:
					failures.append(str(key) + "." + str(sub_key))
	print(RESULT_PREFIX + JSON.stringify({"ok": failures.is_empty(), "checks": checks, "failures": failures}))
	print(TEARDOWN_MARKER)
	get_tree().quit()


func _instantiate(path: String) -> Node:
	var scene := load(path) as PackedScene
	var node := scene.instantiate()
	add_child(node)
	if node is Node2D:
		(node as Node2D).set_physics_process(false)
	return node


func _free(node: Node) -> void:
	if node != null and is_instance_valid(node):
		node.queue_free()


func _sprite_frames(node: Node) -> SpriteFrames:
	var sprite := node as AnimatedSprite2D
	return sprite.sprite_frames if sprite != null else null


func _has_animations(frames: SpriteFrames, animations: Array) -> bool:
	if frames == null:
		return false
	for animation in animations:
		if not frames.has_animation(animation):
			return false
	return true


func _duration_check(frames: SpriteFrames, animation: String, durations: Array) -> bool:
	if frames == null or not frames.has_animation(animation):
		return false
	if frames.get_frame_count(animation) != durations.size():
		return false
	for index in durations.size():
		if not is_equal_approx(frames.get_frame_duration(animation, index), float(durations[index])):
			return false
	return true


func _frame_check(
	frames: SpriteFrames, animation: String, count: int, loop: bool, speed: float
) -> bool:
	if frames == null or not frames.has_animation(animation):
		return false
	return (
		frames.get_frame_count(animation) == count
		and frames.get_animation_loop(animation) == loop
		and is_equal_approx(frames.get_animation_speed(animation), speed)
	)
