# 装备数据契约（Phase 33-0/33-1/33-2）

> **状态**：33-0（契约与字段审计）、33-1（Definition/Catalog/Store/生成器）与 33-2（EquipmentRules/EquipmentRoller 与随机字段恢复）已完成；33-3 消费方迁移、33-4 切换与 33-5 收口未启动。
>
> **范围**：`all_equipment_data.gd` 的 1,035 条静态装备/物品定义、玉兔合并项与确定性生成项。运行时旧路径在本批保持不变；本页描述新 Catalog 契约，不宣称消费者已迁移。
>
> **依据**：[ADR-003](../decisions/ADR-003-modern-godot-design-with-legacy-exceptions.md)、[ADR-005](../decisions/ADR-005-no-compatibility-or-fallback-layers.md)、[ADR-006](../decisions/ADR-006-resource-first-data-and-data-keys.md)、[ADR-012](../decisions/ADR-012-zero-error-zero-warning-quality-gates.md)、[总体目标契约](../standards/target_architecture_contract.md) §5。

---

## 1. 事实基线

| 项 | 当前值 |
|:---|:---:|
| 运行时装备/物品定义 | **1,035 条** |
| 顶层字段 | **32 个** |
| 含随机字段的定义 | **163 条** |
| 随机字段值 | **258 个** |
| `强化属性` 允许键 | **17 个**（16 属性 + 历史键 `target`） |
| 属性字段 | **16 个**，保留 int/float 原类型 |
| `宝石` 静态定义 | **456 条空数组**；实例属于玩家档案 |
| 图标 | 可选；缺失由 `defined_fields` 表达，不以空字符串伪造存在 |
| 旧运行入口 | `AE.all_equipment`，Autoload `AE` 懒加载 `all_equipment_data.gd` |

旧脚本的随机不是只存在于 `tjbg`：`SHp`、`SMp`、`power`、`Def`、`Mdef`、`Crit`、`Miss`、`R_hp`、`R_mp`、`Lucky`、`htarget`、`ar`、`sp` 与 `成长率` 均存在 `randi_range`/`randf_range`。本契约以实际源码与跨种子运行结果为准，不沿用“只有 `tjbg` 随机”的旧描述。

---

## 2. 三层边界

| 层 | 载体 | 内容 |
|:---|:---|:---|
| **定义** | `EquipmentDefinition` + `EquipmentCatalog`（只读 `.tres`） | 静态名称、品质、颜色、类型、价格、图标、属性、强化模板、扩展字段 |
| **规则** | `EquipmentRules` / `EquipmentRoller`（33-2 已落地） | 随机属性、五行、神铸、强化、宝石共鸣、成长倍率 |
| **实例** | 当前 `PlayerData.player_data` JSON | 拥有装备、强化等级、宝石实例、槽位、双人共享/个体状态 |

本批不得把 `PlayerData.player_data` 整体 Resource 化，也不得把实例状态写入 Catalog。

---

## 3. 32 字段 schema

### 3.1 核心字段

| 旧键 | `EquipmentDefinition` 属性 | 类型 | 约束 |
|:---|:---|:---|:---|
| `名字` | `display_name` | `String` | 必需 |
| `所属` | `origin` | `String` | 必需 |
| `品质` | `quality` | `String` | 必需；保留原字符串 |
| `颜色` | `color_hex` | `String` | 必需；十六进制文本原样保留 |
| `类型` | `category` | `String` | 必需；如 `武器`/`防具`/`道具`/`法宝` |
| `描述` | `description` | `String` | 必需 |
| `售价` | `price` | `int` | 必需；非负 |
| `图标` | `icon_path` | `String` | 可选；存在时以 `res://` 开头 |

### 3.2 属性字段

| 旧键 | 存储 | 类型 |
|:---|:---|:---|
| `SHp`、`SMp`、`power`、`Def`、`Mdef`、`Crit`、`Miss`、`R_hp`、`R_mp`、`vampirism`、`Lucky`、`toughness`、`htarget`、`CritReduce`、`ar`、`sp` | `stats: Dictionary[StringName, Variant]` | `int` 或 `float`，逐字段保留 |

- 只写入定义中实际存在的属性键；不存在的键不补 `0`。
- 不把 16 个属性拆成 16 个 `float` 字段；`0` 与 `0.0`、`5` 与 `5.0` 的比较/显示语义不得被静默改变。
- `defined_fields` 保留字段存在性，用于区分“缺少属性”和“属性值为 0”。

### 3.3 强化与宝石

| 旧键 | `EquipmentDefinition` 属性 | 规则 |
|:---|:---|:---|
| `强化属性` | `enhancement: Dictionary[StringName, Variant]` | 允许 16 属性 + `target`；值必须为 int/float |
| `宝石` | `gem_slots: PackedStringArray` | 定义期槽位；当前全部为空；宝石实例不进入 Catalog |

`强化属性` 中的 `target` 是历史键，不能按 16 属性列表裁剪。未知嵌套键由审计脚本拒绝。

### 3.4 扩展字段

| 旧键 | `EquipmentDefinition` 属性 | 类型 |
|:---|:---|:---|
| `FBTYPE` | `fb_type` | `String` |
| `成长率` | `growth_rate` | `float`；随机定义不保存采样值 |
| `五行` | `element` | `PackedStringArray`；空或 `金/木/水/火/土` |
| `下一阶段` | `next_stage` | `String` |
| `不可神铸` | `forge_forbidden` | `bool` |
| `装备类型` | `equipment_type` | `String` |

### 3.5 元数据字段

`EquipmentDefinition` 额外保存以下非业务字段：

- `defined_fields: PackedStringArray`：旧字典出现过的 32 字段顶层键；保留“缺失”与“空值”的差异；
- `randomized_fields: PackedStringArray`：由运行时生成、构建源不保存值的字段；只允许 16 属性与 `成长率`；
- `random_rolls: Dictionary[StringName, EquipmentStatRoll]`：每个随机字段的范围/采样/变换规格。

`EquipmentStatRoll` 的规格键：

| 键 | 含义 |
|:---|:---|
| `sampler` | `randi`（randi_range）或 `randf`（randf_range） |
| `kind` | 采样输出类型：`int` / `float` |
| `minimum`、`maximum` | 采样闭区间 |
| `step` | `randf` 的 snapped 步长；`randi` 必须为 0 |
| `scale` | 采样后的缩放；1.0 表示不缩放 |
| `rounding` | `none` / `int_if_integral` / `ceil` |

规格不保存采样值。`randf` + 整数 `step` 保留旧 `snapped` 的 int 返回类型；`randf` + 小数 step 保留 float。

它们不是第 33/34 个业务字段，不进入旧字典键统计。

---

## 4. 随机例外

旧脚本在字典字面量中直接调用 `randi_range`/`randf_range`，并在中秋、月宫、玉兔映射中复制/缩放这些值。迁移不能把任意一次采样值写死。

本批处理：

1. 用 8 个固定种子加载旧脚本，记录每个 ID/字段的变化并集；
2. 与源码中的 `randi_range`/`randf_range` 位置交叉核对；
3. 将变化字段写入该定义的 `randomized_fields`；
4. 构建源与 Catalog **不保存这些字段的采样值**；`defined_fields` 仍记录其存在；
5. 33-2 由 `EquipmentRoller` 按 `random_rolls` 生成；`EquipmentRules` 消费物化快照，不写回定义。

当前结果为 **163 条定义、258 个随机字段值**。规格覆盖直接 `randi_range`、偏移 `N + randi_range`、`snapped(randf_range, step)`，以及玉兔复制、中秋 ×1.4、月宫 ×1.25 取整等生成关系。随机值不冻结为固定样本。

`get_wx()` 返回的五行列表是规则结果，不是静态定义；随机五行不写入 `element`。

---

## 5. 构建源与生成物

| 路径 | 职责 |
|:---|:---|
| `scripts/equipment_sources.json` | 已提交、可审查的单文件构建源；保存确定性字段、`defined_fields`、`randomized_fields` 与 `random_rolls` |
| `scripts/equipment_data_schema.py` | 32 字段白名单、类型/嵌套键/随机边界校验 |
| `scripts/equipment_data_audit.py` | 字段审计；未知字段、类型错误、随机字段采样值均失败 |
| `scripts/convert_equipment_catalog.py` | 构建源 → `equipment_catalog.tres`；`--check` 逐字比较 |
| `source/Script/data/equipment_definition.gd` | 单条定义 Resource |
| `source/Script/data/equipment_catalog.gd` | Catalog Resource |
| `source/Script/data/equipment_store.gd` | 只读索引/查询 |
| `source/Script/data/equipment_stat_roll.gd` | 随机范围/变换规格 Resource |
| `source/Script/data/equipment_roller.gd` | 按规格物化随机字段，生成稳定会话快照 |
| `source/Script/data/equipment_rules.gd` | 旧规则服务化：强化、五行、神铸、宝石共鸣 |
| `source/Script/data/equipment_catalog.tres` | 1,035 条定义的构建期产物 |

构建源是运行时数据的唯一新来源；生成器不读取旧 `all_equipment_data.gd`、玉兔 JSON 或 Art 目录。公开 clone 缺少玉兔素材时，已提交的 Catalog 仍可加载；不能以公开环境重建源或伪造玉兔条目。

---

## 6. Store API

`EquipmentStore` 由 Catalog 构造：

```gdscript
var catalog := load("res://Script/data/equipment_catalog.tres") as EquipmentCatalog
var store := catalog.create_store()
store.size()
store.has(&"tjbg")
store.definition(&"tjbg")
store.ids()
store.by_category(&"武器")
```

- 只读：不提供 `all_equipment` 字典、setter 或兼容别名；
- `definition()` 缺失时 `push_error` 并返回 `null`，不静默回退；
- 索引只在构造时建立；`ids()` 返回副本；`by_category()` 返回新数组；
- 本批不新增 Autoload；`AE` 旧路径不变。

---

## 7. 规则层

`EquipmentRoller` 与 `EquipmentRules` 都由 `EquipmentStore` 构造，不新增 Autoload：

```gdscript
var catalog := load("res://Script/data/equipment_catalog.tres") as EquipmentCatalog
var store := catalog.create_store()
var roller := EquipmentRoller.new(store)
var rules := EquipmentRules.new(store, roller)

var data := roller.materialize(&"tjbg")   # 旧字典形状的随机会话快照
rules.get_last_equ_pro(&"tjbg", 3, data)
rules.get_divine_forge_properties(&"tjbg", 3, data, true)
rules.get_wx()
```

- `EquipmentRoller.materialize()` 只读 Catalog，把确定性字段与随机字段合成旧字典形状；按 ID 缓存，`clear_cache()` 重置；
- `EquipmentRules` 保留旧方法名与旧字典输入/输出，`AE` 现有路径未迁移；
- 规则不写回 Catalog/定义；旧实现对非道具且缺少 `强化属性` 的输入会索引缺失键，新实现返回未修改结果，比较用例只覆盖有效输入；
- `get_wx()` 保留旧 `randomize()` 行为；五行结果不进入静态定义。

---

## 8. 验证

本批已执行：

- 构建源审计：**1,035 条**、**32 字段**、**163 条随机定义 / 258 个随机字段值**、**258 个随机规格**，0 错误；
- 8 个种子下确定性字段逐 ID/逐字段一致；随机字段变化集合与源码随机表达式交叉核对；
- Catalog 往返：Godot 加载 **1,035 条**，Store 查询、分类、缺失 ID 失败语义 PASS；
- 旧实现对照：**20,640 个字段值**、**258 个随机字段**、**980 个有效规则用例**、8 槽宝石合成用例，**0 差异**（浮点按 `is_equal_approx`；整数、字段存在性与容器精确）；旧随机值均在规格范围/类型内，32 次/规格抽样 PASS；
- `equipment_catalog.tres` 与构建源逐字同步；`convert_equipment_catalog.py --check` PASS；
- `contract_gate` 含 `equipment_catalog_check` 与 `equipment_data_audit`，PASS；
- `check_all`、`health_check` 结果记录于 [`status.md`](status.md)。

未执行：33-3 消费方迁移、33-4 旧脚本删除、33-5 全量回归与 PCK；不得据本页宣称 Phase 33 完成。

---

## 9. 边界与下一步

- 不改变装备数值、掉落、随机范围、强化/神铸公式、存档格式或双人共享规则；
- 不删除 `all_equipment_data.gd`，不保留第二份可写字典；
- 33-2 已完成规则抽取与随机字段恢复；33-3 按四簇迁移 `AE.all_equipment`；33-4 删除旧脚本与字典 API；33-5 补全量对比、L2/UI/关卡回归与 PCK。
