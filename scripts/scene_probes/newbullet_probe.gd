extends Node

## 验证保留的弹体场景能按基类字段播放动画并设置左右方向。

const RESULT_PREFIX := "NEWBULLET_PROBE_RESULT="
const SCENE_PATH := "res://Scene/hero/newbullet.tscn"


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var failures: Array[String] = []
	var checks: Dictionary = {}
	var scene := load(SCENE_PATH) as PackedScene
	if scene == null:
		failures.append("无法加载弹体场景")
		_finish(failures, checks)
		return
	var left := scene.instantiate() as RoleBullet
	var right := scene.instantiate() as RoleBullet
	if left == null or right == null:
		failures.append("弹体脚本没有解析为 RoleBullet")
		if left != null:
			left.free()
		if right != null:
			right.free()
		_finish(failures, checks)
		return
	left.direction = true
	right.direction = false
	add_child(left)
	add_child(right)
	await get_tree().physics_frame
	await get_tree().physics_frame
	checks["initialized"] = left.is_set and right.is_set
	checks["left_direction"] = left.middle.scale.x == -1.0
	checks["right_direction"] = right.middle.scale.x == 1.0
	checks["animation"] = (
		left.bullet_players.current_animation == "Role2Bullet5"
		and right.bullet_players.current_animation == "Role2Bullet5"
	)
	for check: String in checks:
		if not checks[check]:
			failures.append("弹体检查失败: " + check)
	var slim_scene := load("res://Scene/hero/role_bullet_slim/new_animation.tscn") as PackedScene
	if slim_scene == null:
		failures.append("无法加载精简弹体动画场景")
	else:
		var slim := slim_scene.instantiate() as RoleBullet
		if slim == null:
			failures.append("精简弹体未解析为 RoleBullet")
		else:
			slim._name = "new_animation"
			add_child(slim)
			var sprite := slim.get_node("Middle/BulletPlayer") as AnimatedSprite2D
			var player := slim.get_node("Middle/BulletPlayers") as AnimationPlayer
			player.play("new_animation")
			await get_tree().process_frame
			checks["slim_animation"] = (
				player.current_animation == "new_animation"
				and sprite.animation == &"new_animation"
				and sprite.sprite_frames.has_animation(&"new_animation")
			)
			if not checks["slim_animation"]:
				failures.append("精简弹体动画轨道缺少对应 SpriteFrames")
			slim.queue_free()
	left.queue_free()
	right.queue_free()
	await get_tree().process_frame
	_finish(failures, checks)


func _finish(failures: Array[String], checks: Dictionary) -> void:
	print(RESULT_PREFIX + JSON.stringify({"ok": failures.is_empty(), "failures": failures, "checks": checks}))
	print("NEWBULLET_PROBE_TEARDOWN")
	get_tree().quit(0 if failures.is_empty() else 1)
