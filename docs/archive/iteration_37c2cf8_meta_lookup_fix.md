# `get_meta(key, null)` 缺失键读取防护记录

> **归档日期**：2026-11-10
> **状态**：Archived
> **关联**：当前未复核调用点见 [`../issues/known-issues.md`](../issues/known-issues.md)；项目日志验收见 [`../reference/acceptance.md`](../reference/acceptance.md)。

## 已确认的 API 行为

Godot 4.7 [`Object.get_meta`](https://docs.godotengine.org/en/4.7/classes/class_object.html#class-object-method-get-meta) 文档说明：键不存在时返回 `default`；若 `default` 是 `null`，同时产生 error。可选元数据应先以 `has_meta()` 区分缺失，再在存在时调用无默认值的 `get_meta()`；有语义明确的非 `null` 默认值时也可直接使用。

## 已修复调用路径

`PetTurtleSummonBase._linked_unit_ref()` 在对象有效且包含 `pet_turtle_link_unit_ref` 时才读取元数据；缺键路径直接返回 `null`。当前实现位于 [`pet_turtle_summon_base.gd`](../../source/Script/pet/pet_turtle_summon_base.gd)。

## 证据边界

该记录只确认上述 API 文档行为和这一处源码防护，不代表项目内其它 `get_meta(key, null)` 调用均已复核或修复。独立运行时复现报告不在当前仓库；不得将本文作为全局零 ERROR 运行证据。
