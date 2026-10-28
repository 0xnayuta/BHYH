extends Node

## 关卡资源租约运行时探针（由 scripts/scene_probe_runner.py 复制到工程根目录并执行）。
## 验证租约只释放本次登记的路径，未登记的共享缓存不被误删；同时验证旧租约 ID
## 不能释放新租约，以及空租约快照的稳定形状。

const RESULT_PREFIX := "LEVEL_RESOURCE_LEASE_PROBE_RESULT="
const TEARDOWN_MARKER := "LEVEL_RESOURCE_LEASE_PROBE_TEARDOWN"
const TARGET_SCENE := "res://Scene/level/__lease_probe_target.tscn"
const TARGET_SCENE_2 := "res://Scene/level/__lease_probe_target_2.tscn"
const OWNED_TEXTURE := "res://Art/__lease_probe_owned.png"
const SHARED_TEXTURE := "res://Art/__lease_probe_shared.png"
const MONSTER_SCENE := "res://Scene/monster/__lease_probe_monster.tscn"
const BULLET_SCENE := "res://Scene/monster/monster_bullet_slim/__lease_probe_bullet.tscn"

var _failures: Array[String] = []


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var checks: Dictionary = {}
	var first_lease := Global.begin_level_resource_lease(TARGET_SCENE)
	checks["lease_started"] = first_lease > 0

	var owned_texture := PlaceholderTexture2D.new()
	var shared_texture := PlaceholderTexture2D.new()
	var monster_scene := PackedScene.new()
	var bullet_scene := PackedScene.new()
	checks["handoff_owned_texture"] = Global.handoff_loaded_resource(OWNED_TEXTURE, owned_texture, true)
	checks["handoff_shared_texture"] = Global.handoff_loaded_resource(SHARED_TEXTURE, shared_texture, false)
	checks["handoff_monster_scene"] = Global.handoff_loaded_resource(MONSTER_SCENE, monster_scene, true)
	checks["handoff_bullet_scene"] = Global.handoff_loaded_resource(BULLET_SCENE, bullet_scene, true)

	var snapshot := Global.get_level_resource_lease_snapshot()
	checks["target_recorded"] = str(snapshot.get("target_scene", "")) == TARGET_SCENE
	checks["owned_path_count"] = int(snapshot.get("owned_path_count", 0)) == 3
	checks["texture_category"] = (snapshot.get("texture_paths", []) as Array).has(OWNED_TEXTURE)
	checks["monster_category"] = (snapshot.get("monster_scene_paths", []) as Array).has(MONSTER_SCENE)
	checks["bullet_category"] = (snapshot.get("bullet_scene_paths", []) as Array).has(BULLET_SCENE)
	checks["shared_not_owned"] = not (snapshot.get("owned_paths", []) as Array).has(SHARED_TEXTURE)

	var scope := Global.get_cache_scope_snapshot()
	var scope_level: Dictionary = scope.get("level", {})
	var scope_lease: Dictionary = scope_level.get("lease", {})
	var scope_combat: Dictionary = scope.get("combat", {})
	var scope_build: Dictionary = scope.get("build_read_only", {})
	checks["scope_has_keys"] = (
		scope.has("build_read_only")
		and scope.has("shared_runtime")
		and scope.has("permanent")
		and scope.has("level")
		and scope.has("combat")
		and scope.has("ui")
	)
	checks["scope_level_count"] = int(scope_lease.get("owned_path_count", 0)) == 3
	checks["scope_build_read_only"] = (
		str(scope_build.get("cleanup", "")) == "none" and str(scope_build.get("owner", "")) != ""
	)
	checks["scope_combat_limits"] = (
		int(scope_combat.get("pool_limits", {}).get("damage_text", 0)) == 80
		and int(scope_combat.get("pool_limits", {}).get("sound_player", 0)) == 32
	)
	checks["scope_ui_owner"] = str(scope.get("ui", {}).get("owner", "")) == "Global"

	var released := Global.release_level_resource_lease(first_lease)
	checks["released_owned_count"] = released == 3
	checks["owned_texture_released"] = not Global.is_resource_cached(OWNED_TEXTURE)
	checks["monster_scene_released"] = not Global.is_resource_cached(MONSTER_SCENE)
	checks["bullet_scene_released"] = not Global.is_resource_cached(BULLET_SCENE)
	checks["shared_texture_preserved"] = Global.is_resource_cached(SHARED_TEXTURE)

	var empty_snapshot := Global.get_level_resource_lease_snapshot()
	checks["lease_cleared"] = not bool(empty_snapshot.get("active", true))
	checks["empty_snapshot"] = int(empty_snapshot.get("owned_path_count", -1)) == 0

	var second_lease := Global.begin_level_resource_lease(TARGET_SCENE_2)
	var stale_release := Global.release_level_resource_lease(first_lease)
	checks["stale_release_ignored"] = stale_release == 0
	var second_snapshot := Global.get_level_resource_lease_snapshot()
	checks["second_lease_active"] = bool(second_snapshot.get("active", false))
	checks["second_lease_id"] = int(second_snapshot.get("id", 0)) == second_lease
	checks["second_lease_released"] = Global.release_level_resource_lease(second_lease) == 0

	Global.release_cached_texture(SHARED_TEXTURE)
	checks["shared_cached_cleanup"] = not Global.is_resource_cached(SHARED_TEXTURE)

	var refight_lease := Global.begin_level_resource_lease(TARGET_SCENE)
	var refight_owned := PlaceholderTexture2D.new()
	var refight_shared := PlaceholderTexture2D.new()
	Global.handoff_loaded_resource(OWNED_TEXTURE, refight_owned, true)
	Global.handoff_loaded_resource(SHARED_TEXTURE, refight_shared, false)
	Global.clear_level_resource_cache()
	checks["refight_owned_released"] = not Global.is_resource_cached(OWNED_TEXTURE)
	checks["refight_shared_preserved"] = Global.is_resource_cached(SHARED_TEXTURE)
	checks["refight_lease_cleared"] = not bool(Global.get_level_resource_lease_snapshot().get("active", true))
	Global.release_cached_texture(SHARED_TEXTURE)

	Global.archive_session_active = true
	Global.archive_session_role_id = 1
	var exit_lease := Global.begin_level_resource_lease(TARGET_SCENE_2)
	var exit_owned := PlaceholderTexture2D.new()
	var exit_shared := PlaceholderTexture2D.new()
	Global.handoff_loaded_resource(OWNED_TEXTURE, exit_owned, true)
	Global.handoff_loaded_resource(SHARED_TEXTURE, exit_shared, false)
	Global.end_archive_session()
	checks["exit_owned_released"] = not Global.is_resource_cached(OWNED_TEXTURE)
	checks["exit_shared_preserved"] = Global.is_resource_cached(SHARED_TEXTURE)
	checks["exit_lease_cleared"] = not bool(Global.get_level_resource_lease_snapshot().get("active", true))
	Global.release_cached_texture(SHARED_TEXTURE)
	checks["exit_lease_ids"] = refight_lease > 0 and exit_lease > refight_lease
	var exit_scope := Global.get_cache_scope_snapshot()
	var exit_level: Dictionary = exit_scope.get("level", {})
	var exit_lease_snapshot: Dictionary = exit_level.get("lease", {})
	var exit_combat: Dictionary = exit_scope.get("combat", {})
	var exit_pool_sizes: Dictionary = exit_combat.get("pool_sizes", {})
	var pools_cleared := true
	for pool_size_value in exit_pool_sizes.values():
		if int(pool_size_value) != 0:
			pools_cleared = false
	checks["scope_exit_level_cleared"] = int(exit_lease_snapshot.get("owned_path_count", -1)) == 0
	checks["scope_exit_pools_cleared"] = pools_cleared

	for check_name in checks:
		if not bool(checks[check_name]):
			_failures.append(str(check_name))
	var payload := {"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": checks}
	print(RESULT_PREFIX + JSON.stringify(payload))
	print(TEARDOWN_MARKER)
	get_tree().quit(0 if _failures.is_empty() else 1)
