# 已知问题与待验证风险

> 本页只记录尚未解决的问题与待验证风险；阶段完成状态见 [`../roadmap/roadmap.md`](../roadmap/roadmap.md)，验收判据见 [`../reference/acceptance.md`](../reference/acceptance.md)。

## `Object.get_meta(name, null)` 的缺失键路径会产生 ERROR

Godot 4.7 的 [`Object.get_meta`](https://docs.godotengine.org/en/4.7/classes/class_object.html#class-object-method-get-meta) 在键不存在且默认值为 `null` 时返回默认值，同时记录 error。需要将“键可能不存在”作为正常情况处理时，先调用 `has_meta()`，再无默认值读取；或传入语义正确的非 `null` 默认值。

源码检索在以下文件中找到 `get_meta(..., null)` 调用。检索结果不证明这些键在运行时缺失，也不证明每条调用均可达；逐点风险尚未完成复核。

- `source/Script/base/base_buff.gd`
- `source/Script/base/base_magic_weapon.gd`
- `source/Script/base/base_monster.gd`
- `source/Script/magic_weapon/eight_immortal_magic_weapon.gd`
- `source/Script/monster/constellation_boss.gd`
- `source/Script/monster/monster_bullet.gd`
- `source/Script/pet/pet_mouse_bullet.gd`
- `source/Script/pet/pet_neat_bullet.gd`
- `source/Script/pet/pet_rabbit_bullet.gd`
- `source/Script/pet/pet_turtle_bullet.gd`
- `source/Script/pet/pet_yin_tiger_bullet.gd`

`pet_turtle_summon_base.gd` 的同心链接读取已先检查 `has_meta()`，可作为已修复实例；这不改变本页列出的其它调用点范围。源码见 [`pet_turtle_summon_base.gd`](../../source/Script/pet/pet_turtle_summon_base.gd)。

### 处置与验收

1. 逐调用点确认缺失键是否为合法状态及其失败语义。
2. 修正允许缺键的路径；不得为消除日志而改变业务默认值或隐藏真实失败。
3. 覆盖键存在、键缺失和对象已失效的实际运行路径，并检查日志。
4. 修复并验证前，继续按 [`../reference/acceptance.md`](../reference/acceptance.md) 的日志门禁处理；不以命中数或改写数量宣称完成。
