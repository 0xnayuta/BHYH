class_name RunContext
extends RefCounted

## 单次挑战的运行上下文：关卡显示名、玲珑宝塔层数与战斗统计。
## 由 Global 持有唯一实例；统计字段只读消费，写入必须经过 add_*/count_* 与 reset_combat_stats()。
## 本类不做场景树操作、不读写存档；关卡入口与结算面板通过 Global 薄访问器或 get_run_context() 使用。

var level_display_name: String = ""
var tower_floor: int = 1

# 战斗统计：结算面板只读消费，写入走本类方法。
var damage_dealt: int = 0
var physical_dealt: int = 0
var magic_dealt: int = 0
var real_dealt: int = 0
var damage_taken: int = 0
var physical_taken: int = 0
var magic_taken: int = 0
var real_taken: int = 0
var healing: int = 0
var hit_count: int = 0
var hurt_count: int = 0
var crit_count: int = 0
var miss_count: int = 0


func get_level_display_name() -> String:
	return level_display_name


func set_level_display_name(value: String) -> void:
	level_display_name = value


func get_tower_floor() -> int:
	return tower_floor


func set_tower_floor(value: int) -> void:
	tower_floor = value


func advance_tower_floor() -> void:
	tower_floor += 1


## 累计造成伤害总量。分类型累计单独调用 add_damage_dealt_by_type，避免两套口径被合并。
func add_damage_dealt(amount: int) -> void:
	damage_dealt += amount


## damage_type 取 physics / magic / real；未知类型静默忽略，与迁移前的 if/elif 链一致。
func add_damage_dealt_by_type(damage_type: String, amount: int) -> void:
	match damage_type:
		"physics":
			physical_dealt += amount
		"magic":
			magic_dealt += amount
		"real":
			real_dealt += amount


## 累计受到伤害总量。分类型累计单独调用 add_damage_taken_by_type。
func add_damage_taken(amount: int) -> void:
	damage_taken += amount


func add_damage_taken_by_type(damage_type: String, amount: int) -> void:
	match damage_type:
		"physics":
			physical_taken += amount
		"magic":
			magic_taken += amount
		"real":
			real_taken += amount


func add_healing(amount: int) -> void:
	healing += amount


func count_hit() -> void:
	hit_count += 1


func count_hurt() -> void:
	hurt_count += 1


func count_crit() -> void:
	crit_count += 1


func count_miss() -> void:
	miss_count += 1


## 关卡入口重置战斗统计；关卡显示名与宝塔层数由各自入口维护，不在此清空。
func reset_combat_stats() -> void:
	damage_dealt = 0
	physical_dealt = 0
	magic_dealt = 0
	real_dealt = 0
	damage_taken = 0
	physical_taken = 0
	magic_taken = 0
	real_taken = 0
	healing = 0
	hit_count = 0
	hurt_count = 0
	crit_count = 0
	miss_count = 0
