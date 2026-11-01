# 已知问题与待验证风险

> 状态：轻量风险清单。详细项目状态以路线图和当前迭代文档为准。
> 更新时机：发现新问题、完成验证、搁置项恢复时。已修复项保留最小回归线索，不复制阶段报告。

当前项目状态与风险以 [`../roadmap/roadmap.md`](../roadmap/roadmap.md) 为准；阶段验收见 [`../reference/acceptance.md`](../reference/acceptance.md)。当前批次见 [`../roadmap/current-iteration.md`](../roadmap/current-iteration.md)。

---

## 1. 当前限制与未修复问题

### GDScript `get_meta(key, null)` 在键缺失时仍记录 ERROR

> **状态**：已确认，待清理（2026-11-01）。
> **严重度**：低（不改变返回值）；**影响面**：日志噪声与零错误门禁。

#### 现象

调用 `Object.get_meta(key, null)` 时，如果对象没有该 key，Godot 仍输出：

```text
ERROR: The object does not have any 'meta' values with the key '...'.
   at: get_meta (core/object/object.cpp)
```

即使调用方预期“缺失时返回 `null`”，日志也会出现。返回值本身确实是 `null`，因此该问题主要表现为错误日志，而不是业务值错误。

#### 根因

Godot 4.7.2 的 `get_meta(key, default = null)` 将 `null` 视为“没有提供默认值”。只有非 `null` 默认值才会静默返回；显式传入 `null` 与省略参数走同一缺失键错误路径。

已用最小 headless 探针直接验证：

```gdscript
get_meta("missing_null", null)     # ERROR
get_meta("missing_false", false)   # 静默返回 false
get_meta("missing_zero", 0)        # 静默返回 0
get_meta("missing_empty", "")      # 静默返回 ""
get_meta("missing_vector", Vector2.ZERO) # 静默返回 Vector2.ZERO
```

因此修复不能依赖 `get_meta(key, null)` 作为“可选读取”；必须先 `has_meta(key)`，或使用语义明确的非 `null` 哨兵值。

#### 当前范围

2026-11-01 静态检索仍有 **29 个** `get_meta(..., null)` 调用点，分布在 **11 个文件**；其中部分调用点已有前置 `has_meta` 保护，未逐点证明其余路径均可触发。

| 文件 | 数量 | 代表位置 |
|:---|---:|:---|
| `source/Script/monster/monster_bullet.gd` | 12 | `get_meta("summoner", null)` |
| `source/Script/pet/pet_rabbit_bullet.gd` | 5 | `get_meta("summoner", null)` |
| `source/Script/pet/pet_neat_bullet.gd` | 2 | `get_meta("summoner", null)` |
| `source/Script/pet/pet_turtle_bullet.gd` | 2 | `get_meta("summoner", null)` |
| `source/Script/base/base_monster.gd` | 2 | `summoner`、`active_pet_unit`（嵌套键形式） |
| `source/Script/base/base_buff.gd` | 1 | `voodoo_effect_visual` |
| `source/Script/base/base_magic_weapon.gd` | 1 | `magic_cd_icon` |
| `source/Script/magic_weapon/eight_immortal_magic_weapon.gd` | 1 | `active_pet_unit` |
| `source/Script/monster/constellation_boss.gd` | 1 | `constellation_summoner` |
| `source/Script/pet/pet_mouse_bullet.gd` | 1 | `summoner` |
| `source/Script/pet/pet_yin_tiger_bullet.gd` | 1 | `summoner` |

该计数不包含已修复的 `pet_turtle_summon_base.gd` 同心链接路径，也不把使用非 `null` 默认值的调用计入。

#### 影响

- 违反项目“0 ERROR / 0 WARNING”的日志基线；
- 弹体、召唤物和法宝的冷路径可能重复刷日志，掩盖真正的错误；
- 不改变返回值时容易误判为“只是日志”，从而漏掉缺失元数据本身是否合理。

#### 处理方案

1. 逐文件核对调用点的前置条件与“缺失 key”语义；
2. 统一改为 `has_meta(key)` 判断后无默认值读取，或使用明确的非 `null` 哨兵；
3. 对确实代表“无归属”的键，不新增回退层或空对象，只保留既有缺省语义；
4. 清理完成后，可把 `get_meta(..., null)` 纳入静态门禁，防止回潮；
5. 每批修复后运行对应运行期夹具，并检查日志无新增 ERROR。

#### 验收

- `grep` 不再发现 `get_meta(..., null)` 代码调用（注释除外）；
- 缺失元数据、有效元数据、元数据指向已释放对象三种路径均无缺失键 ERROR；
- `check_all --godot-bin` 全维 PASS；
- 受影响关卡/弹体/召唤物冒烟通过，日志 0 ERROR / 0 WARNING。

#### 关联

- 模式修复先例：`37c2cf8`（同心链接路径，见 §2）；
- 静态门禁：`scripts/contract_scan.py`；
- 日志基线：`AGENTS.md` §7、[`../reference/acceptance.md`](../reference/acceptance.md)。

---

## 2. 已修复问题（回归参考）

### 同心链接清理缺失元数据报错

- **历史反证**：退出关卡时 `PetMouseSummonBase._exit_tree()` 调用基类 `_clear_turtle_link()`，在英雄没有 `pet_turtle_link_unit_ref` 时输出 `The object does not have any 'meta' values`。
- **根因**：`_clear_turtle_link()` 和 `_link_active()` 使用 `get_meta(key, null)`；同心链接未激活或已被英雄清理时 key 合法缺失。`_apply_turtle_link()` 首次设置前也会调用清理。
- **修复**：新增 `_linked_unit_ref()`，先 `has_meta` 再读取；缺失、非 `WeakRef` 或指向其它单位均视为未链接。清理保持幂等，不改变伤害/治疗/持续时间语义。
- **验证**：临时探针复现修复前 `pet_turtle_summon_base.gd:616` 报错；修复后缺失元数据、有效链接、其它持有者三条路径无 ERROR，`_exit_tree()` 无报错；`check_all --godot-bin` 9/9 PASS；`level_1` 冒烟 PASS。
- **关联**：`source/Script/pet/pet_turtle_summon_base.gd`；提交 `37c2cf8`。
