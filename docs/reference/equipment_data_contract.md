# 装备数据契约

> 当前实现与运行时接入见 [`architecture.md`](architecture.md)；验收与发布闭包判据见 [`acceptance.md`](acceptance.md)；最近验证见 [`status.md`](status.md)；阶段状态见 [`../roadmap/roadmap.md`](../roadmap/roadmap.md)；工具职责与 CLI 见 [`../../scripts/README.md`](../../scripts/README.md)。本页只记录装备域的数据模型、字段与消费规则。
>
> 设计依据：[ADR-006](../decisions/ADR-006-resource-first-data-and-data-keys.md) 与 [`../standards/target_architecture_contract.md`](../standards/target_architecture_contract.md)。构建源与字段校验规则分别以 [`../../scripts/equipment_sources.json`](../../scripts/equipment_sources.json) 和 [`../../scripts/equipment_data_schema.py`](../../scripts/equipment_data_schema.py) 为准。

## 1. 模型与所有权

| 层 | 载体 | 所有内容 |
|:---|:---|:---|
| 定义 | `EquipmentDefinition` / `EquipmentCatalog` | 只读静态定义与随机规格；不写入玩家拥有状态或随机采样结果 |
| 规则 | `EquipmentRoller` / `EquipmentRules` | 按定义生成随机字段，并计算强化、神铸、宝石共鸣与五行规则结果 |
| 实例 | `PlayerData.player_data` | 玩家拥有状态、强化等级、宝石实例、槽位及双人共享/个体状态 |

一条装备定义在构建源中有一个正式来源，由生成器产出 Catalog；不得再以手写资源、脚本字典或第二份运行时定义覆盖它。实例状态属于玩家档案，不能写回共享 Catalog。

### 1.1 `EquipmentDefinition`

| 属性 | 类型 | 语义与约束 |
|:---|:---|:---|
| `id` | `StringName` | 定义 ID；构建源要求非空、无空白且全局唯一 |
| `display_name`、`origin`、`quality`、`color_hex`、`category`、`description` | `String` | 对应定义的名称、来源、品质、颜色、类别与说明 |
| `price` | `int` | 售价，非负 |
| `icon_path` | `String` | 可选图标路径；非空时必须是 `res://` 路径 |
| `stats` | `Dictionary[StringName, Variant]` | 可选属性键仅为 `SHp`、`SMp`、`power`、`Def`、`Mdef`、`Crit`、`Miss`、`R_hp`、`R_mp`、`vampirism`、`Lucky`、`toughness`、`htarget`、`CritReduce`、`ar`、`sp`；值为 `int` 或 `float`，保留原类型，不以 `0` 补缺失键 |
| `enhancement` | `Dictionary[StringName, Variant]` | 强化模板；允许上述属性键及历史键 `target`，数值为 `int` 或 `float` |
| `gem_slots` | `PackedStringArray` | 定义期槽位；镶入的宝石 ID 属于玩家实例 |
| `fb_type`、`next_stage`、`equipment_type` | `String` | 扩展分类、后续阶段与装备类型 |
| `growth_rate` | `float` | 成长率；可由随机规则生成 |
| `element` | `PackedStringArray` | 静态五行标签；元素限于金、木、水、火、土 |
| `forge_forbidden` | `bool` | 是否禁止神铸 |
| `defined_fields` | `PackedStringArray` | 保留构建源中字段的存在性，区分“缺少”与“空值” |
| `randomized_fields` | `PackedStringArray` | 标记由规则生成的字段；不在定义中保存采样值 |
| `random_rolls` | `Dictionary[StringName, EquipmentStatRoll]` | 每个随机字段对应一份采样与变换规格 |

`EquipmentCatalog` 保存 `schema_version`、源摘要、定义数与 `Array[EquipmentDefinition]`。其中定义数是 Catalog 的一致性元数据，不是另一份数据源。

### 1.2 随机规格与物化

`EquipmentStatRoll` 的字段为 `sampler`、`kind`、`minimum`、`maximum`、`step`、`scale`、`rounding`：采样器为 `randi` 或 `randf`，输出类型为 `int` 或 `float`；范围上下界必须有效，步长非负、缩放为正，`randi` 的步长为零。`randf` 可按步长取整/取样；采样后应用缩放，再按 `none`、`int_if_integral` 或 `ceil` 取整规则处理。

- `randomized_fields` 只能包含已登记的属性键或 `成长率`，且必须同时存在于 `defined_fields`；每项必须有对应 `random_rolls`。
- 随机字段不得出现在构建源的确定性 `values` 中；缺失的确定性值、未知字段/嵌套键、类型错误、重复 ID 或无效规格都使构建输入校验失败。
- `EquipmentRoller` 按 ID 物化定义并在实例内缓存结果；`materialize()` 返回深副本，`clear_cache()` 后才重新采样。规则不改写 Catalog。
- `EquipmentRules.get_wx()` 返回运行期规则结果，不把结果写入静态 `element`。

## 2. 查询与实例边界

`EquipmentStore` 只读索引提供定义查询；未知 ID 的 `definition()` 报错并返回 `null`，`EquipmentRoller.materialize()` 对未知 ID 报错并返回空字典。ID 列表及分类查询返回副本。`EquipmentService.data()` 是需要旧字典形状的消费者使用的物化入口，返回值与 Catalog 分离；新消费者优先读 `EquipmentDefinition` / `EquipmentStore`，不要自行拼接第二份装备字典。

玩家装备、强化与镶嵌状态由玩家档案拥有；双人共享或个体分配仍遵循存档/槽位契约，不由定义或规则资源决定。关卡布局不承担装备数值或运行时所有权。

## 3. 缺失与发布闭包

- 构建源不存在、不可解析或不符合字段/schema 规则时，审计与 Catalog 构建必须失败；不得从旧脚本、字典或素材数据猜测并回退。
- 运行时缺失 Catalog 时，`EquipmentService` 报错并返回空结果；未知定义也报错，不再尝试其他数据源。
- 发布依赖清单 [`level_preload_export_dependencies.json`](../../source/Script/data/level_preload_export_dependencies.json) 将装备 Catalog 纳入必需路径；实际 PCK 闭包由 [`frame_sequence_pack_probe.py`](../../scripts/frame_sequence_pack_probe.py) 验证。清单缺项或包内路径缺失是发布闭包失败，不可记为通过。门禁判据以 [`acceptance.md`](acceptance.md) 为准，最近验证结果只记在 [`status.md`](status.md)。

类型定义见 [`EquipmentDefinition`](../../source/Script/data/equipment_definition.gd)、[`EquipmentStatRoll`](../../source/Script/data/equipment_stat_roll.gd)、[`EquipmentCatalog`](../../source/Script/data/equipment_catalog.gd)、[`EquipmentStore`](../../source/Script/data/equipment_store.gd)、[`EquipmentRoller`](../../source/Script/data/equipment_roller.gd)、[`EquipmentRules`](../../source/Script/data/equipment_rules.gd) 与 [`EquipmentService`](../../source/Script/data/equipment_service.gd)。
