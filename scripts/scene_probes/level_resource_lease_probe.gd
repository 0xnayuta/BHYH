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
const STALE_TEXTURE := "res://Art/__lease_probe_stale.png"
const MONSTER_SCENE := "res://Scene/monster/__lease_probe_monster.tscn"
const BULLET_SCENE := "res://Scene/monster/monster_bullet_slim/__lease_probe_bullet.tscn"

var _failures: Array[String] = []


func _diagnostics() -> RuntimeDiagnostics:
	return Global.get_runtime_diagnostics()


func _audio_snapshot() -> Dictionary:
	return Global.get_audio_runtime().get_snapshot()


func _check_pool_scope(checks: Dictionary) -> void:
	var pool: Array = Global._pool_data["damage_text"]
	var first := Node.new()
	first.name = "PoolCapacityProbe"
	Global._store_pooled_node(first, pool, 1)
	var second := Node.new()
	Global._store_pooled_node(second, pool, 1)
	checks["pool_capacity"] = pool.size() == 1
	var pool_scope: Dictionary = _diagnostics().get_cache_scope_snapshot().get("combat", {})
	checks["pool_root"] = bool(pool_scope.get("pool_root_valid", false))
	Global._clear_runtime_pools()
	checks["pool_clear"] = pool.is_empty() and not bool(
		_diagnostics().get_cache_scope_snapshot().get("combat", {}).get("pool_root_valid", true)
	)


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var checks: Dictionary = {}
	_check_pool_scope(checks)
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

	var snapshot := _diagnostics().get_level_resource_lease_snapshot()
	checks["target_recorded"] = str(snapshot.get("target_scene", "")) == TARGET_SCENE
	checks["owned_path_count"] = int(snapshot.get("owned_path_count", 0)) == 3
	checks["texture_category"] = (snapshot.get("texture_paths", []) as Array).has(OWNED_TEXTURE)
	checks["monster_category"] = (snapshot.get("monster_scene_paths", []) as Array).has(MONSTER_SCENE)
	checks["bullet_category"] = (snapshot.get("bullet_scene_paths", []) as Array).has(BULLET_SCENE)
	checks["shared_not_owned"] = not (snapshot.get("owned_paths", []) as Array).has(SHARED_TEXTURE)

	var scope := _diagnostics().get_cache_scope_snapshot()
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
	checks["scope_ui_owner"] = str(scope.get("ui", {}).get("owner", "")) == "UiRuntime"

	var released := Global.release_level_resource_lease(first_lease)
	checks["released_owned_count"] = released == 3
	checks["owned_texture_released"] = not Global.is_resource_cached(OWNED_TEXTURE)
	checks["monster_scene_released"] = not Global.is_resource_cached(MONSTER_SCENE)
	checks["bullet_scene_released"] = not Global.is_resource_cached(BULLET_SCENE)
	checks["shared_texture_preserved"] = Global.is_resource_cached(SHARED_TEXTURE)

	var empty_snapshot := _diagnostics().get_level_resource_lease_snapshot()
	checks["lease_cleared"] = not bool(empty_snapshot.get("active", true))
	checks["empty_snapshot"] = int(empty_snapshot.get("owned_path_count", -1)) == 0

	var second_lease := Global.begin_level_resource_lease(TARGET_SCENE_2)
	var stale_release := Global.release_level_resource_lease(first_lease)
	checks["stale_release_ignored"] = stale_release == 0
	var second_snapshot := _diagnostics().get_level_resource_lease_snapshot()
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
	checks["refight_lease_cleared"] = not bool(_diagnostics().get_level_resource_lease_snapshot().get("active", true))
	Global.release_cached_texture(SHARED_TEXTURE)

	Global.set_cd_path("user://MyAr_1.json")
	PlayerData.player_data["Myself"] = 1
	checks["session_bound"] = Global.bind_archive_session()
	var exit_lease := Global.begin_level_resource_lease(TARGET_SCENE_2)
	var exit_owned := PlaceholderTexture2D.new()
	var exit_shared := PlaceholderTexture2D.new()
	Global.handoff_loaded_resource(OWNED_TEXTURE, exit_owned, true)
	Global.handoff_loaded_resource(SHARED_TEXTURE, exit_shared, false)
	var generation_before_end := _diagnostics().get_runtime_generation()
	Global.end_archive_session()
	checks["runtime_generation_invalidated"] = not Global.is_runtime_generation_current(generation_before_end)
	Global._preload_paths_threaded([STALE_TEXTURE], generation_before_end)
	checks["stale_async_skipped"] = not Global.is_resource_cached(STALE_TEXTURE)
	checks["exit_owned_released"] = not Global.is_resource_cached(OWNED_TEXTURE)
	checks["exit_shared_preserved"] = Global.is_resource_cached(SHARED_TEXTURE)
	checks["exit_lease_cleared"] = not bool(_diagnostics().get_level_resource_lease_snapshot().get("active", true))
	Global.release_cached_texture(SHARED_TEXTURE)
	checks["exit_lease_ids"] = refight_lease > 0 and exit_lease > refight_lease
	var exit_scope := _diagnostics().get_cache_scope_snapshot()
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
	checks["scope_exit_pool_root_cleared"] = not bool(exit_combat.get("pool_root_valid", true))
	checks["scope_exit_active_sound_cleared"] = (
		int(_audio_snapshot().get("active_sound_players", -1)) == 0
	)

	for check_name in checks:
		if not bool(checks[check_name]):
			_failures.append(str(check_name))
	var payload := {"ok": _failures.is_empty(), "failures": _failures.duplicate(), "checks": checks}
	print(RESULT_PREFIX + JSON.stringify(payload))
	print(TEARDOWN_MARKER)
	get_tree().quit(0 if _failures.is_empty() else 1)
