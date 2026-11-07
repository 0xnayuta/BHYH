extends Area2D

## 角色攻击区域转发：7.1 关卡用该脚本把 Area2D 的形状命中转成 area_entered。


func receive_role_area_hit(area: Area2D) -> void:
	if not monitoring or area == null or (area.collision_layer & collision_mask) == 0:
		return
	for owner_id in get_shape_owners():
		if not is_shape_owner_disabled(owner_id) and shape_owner_get_shape_count(owner_id) > 0:
			area_entered.emit(area)
			return
