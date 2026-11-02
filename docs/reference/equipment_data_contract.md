# 装备数据契约（Phase 33 完成）

> **状态**：Phase 33 已完成（2026-11-02）。旧 `all_equipment_data.gd`、`all_equipment.gd`、字典 getter/setter 与 `AE` Autoload 已删除；运行时只加载 `equipment_catalog.tres`。完整批次、字段对照与验证记录见 [`../archive/iteration_33_equipment_data_contract.md`](../archive/iteration_33_equipment_data_contract.md)。

## 1. 三层模型

| 层 | 载体 | 职责 |
|:---|:---|:---|
| 定义 | `EquipmentDefinition` + `EquipmentCatalog`（只读 `.tres`） | 名称、品质、颜色、类型、价格、图标、属性、强化模板、扩展字段 |
| 规则 | `EquipmentRoller` + `EquipmentRules` | 随机字段物化、五行、神铸、强化、宝石共鸣 |
| 实例 | `PlayerData.player_data` JSON | 拥有状态、强化等级、宝石、槽位、双人共享/个体状态 |

不把 `PlayerData.player_data` 整体 Resource 化；实例状态不写回 Catalog。

## 2. 数据契约

- 定义：**1,035 条**；顶层字段 **32 个**；含随机字段 **163 条 / 258 个字段值**。
- 核心字段：`id`、`display_name`、`origin`、`quality`、`color_hex`、`category`、`description`、`price`、`icon_path`。
- 属性：`stats: Dictionary[StringName, Variant]`；16 个属性保留 int/float 原类型。
- 扩展：`enhancement`（16 属性 + `target`）、`gem_slots`、`fb_type`、`growth_rate`、`element`、`next_stage`、`forge_forbidden`、`equipment_type`。
- 元数据：`defined_fields` 保留字段存在性；`randomized_fields` 与 `random_rolls` 只登记随机规则，不保存采样值。
- `宝石` 定义期槽位保持空数组；宝石实例属于玩家档案。

字段白名单与类型由 `scripts/equipment_data_schema.py` 校验；未知字段、错误类型或采样值写入必须失败。

## 3. 构建与查询

| 路径 | 职责 |
|:---|:---|
| `scripts/equipment_sources.json` | 可审查构建源；只保存确定性字段、存在性和随机规格 |
| `scripts/convert_equipment_catalog.py` | 构建源 → Catalog；`--check` 逐字校验 |
| `scripts/equipment_data_audit.py` | 字段/类型/随机边界审计 |
| `source/Script/data/equipment_catalog.tres` | 运行时唯一 Catalog |
| `EquipmentStore` | 只读索引：`definition`、`has`、`ids`、`by_category` |
| `EquipmentService` | 静态服务入口；不新增 Autoload |
| `EquipmentRules` | 强化、神铸、宝石、五行规则 |

`EquipmentService.data()` 只用于需要旧字典形状的消费者；新代码优先使用 `EquipmentDefinition` 或 `EquipmentStore` 查询。

## 4. 随机与不可变

- 随机字段范围、采样器、缩放、取整登记在 `random_rolls`；构建源与 Catalog 不保存采样值。
- `EquipmentRoller` 按 ID 物化；规则不写回 Catalog。
- `get_wx()` 保留旧随机行为；五行结果不进入静态 `element`。
- 不改变装备数值、掉落规则、强化/神铸公式、存档格式或双人共享规则。

## 5. 发布闭包

`equipment_catalog.tres` 已登记在 `level_preload_export_dependencies.json`（schema 3），PCK 探针将其作为必需路径。当前验证包结果见 [`status.md`](status.md)。

## 6. 验收

```bash
python scripts/equipment_data_audit.py --check
python scripts/convert_equipment_catalog.py --check
python scripts/convert_level_preload_catalog.py --check
```

验收要求：字段/类型/随机边界 0 错误；Catalog 与构建源同步；装备/背包/商店/奖励/锻造/合成/分解/神铸/玉兔/双人路径探针通过；发布依赖清单包含 Catalog。

完整字段对照、历史计数与逐簇验证见归档页。
