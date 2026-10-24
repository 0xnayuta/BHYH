class_name RoleRuntimeCatalog
extends RefCounted

## 角色运行时资源清单的唯一注册表；预加载保证清单缺失在解析阶段暴露。
const MANIFESTS: Dictionary[int, RoleRuntimeResourceManifest] = {
	1: preload("res://Script/data/role_runtime/role_1_runtime.tres"),
	2: preload("res://Script/data/role_runtime/role_2_runtime.tres"),
	3: preload("res://Script/data/role_runtime/role_3_runtime.tres"),
	4: preload("res://Script/data/role_runtime/role_4_runtime.tres"),
	5: preload("res://Script/data/role_runtime/role_5_runtime.tres"),
	6: preload("res://Script/data/role_runtime/role_6_runtime.tres"),
	7: preload("res://Script/data/role_runtime/role_7_runtime.tres"),
}


static func get_manifest(role_id: int) -> RoleRuntimeResourceManifest:
	assert(MANIFESTS.has(role_id), "未注册角色运行资源清单: %d" % role_id)
	return MANIFESTS[role_id]
