extends Node

## 法宝构建期帧资源运行时探针。
## 验证诛仙剑阵 5 把剑、青莲 3 组动画、青龙剑/太极模型与太极 22 帧效果。
## 由 scripts/scene_probe_runner.py 复制到工程根目录执行。

const RESULT_PREFIX := "MAGIC_WEAPON_PROBE_RESULT="
const TEARDOWN_MARKER := "MAGIC_WEAPON_PROBE_TEARDOWN"
const MAIN_SWORD_SCENE := "res://Scene/magic_weapon/main_sword_array_weapon.tscn"
const QING_LIAN_SCENE := "res://Scene/magic_weapon/qing_lian.tscn"
const QLSWORD_SCENE := "res://Scene/magic_weapon/qlsword.tscn"
const TAIJI_SCENE := "res://Scene/magic_weapon/taiji_bagua.tscn"
const QLSWORD_FRAMES := "res://Art/magic_weapon/magic_weapon_qlsword/official/magic_big_sword_frames.tres"
const TAIJI_EFFECT_FRAMES := "res://Art/magic_weapon/taiji_bagua/effect/taiji_bagua_effect_frames.tres"
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
