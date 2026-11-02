# 关卡布局数据契约（当前）

> **状态**：Phase 30 已完成并归档；本页保留当前对象模型、字段语义、构建与运行时规则。完整 ZMWS 映射、迁移批次和例外逐项结论见 [`../archive/iteration_30_level_layout_contract.md`](../archive/iteration_30_level_layout_contract.md) 与 [`../archive/phase_30_4_script_decisions.md`](../archive/phase_30_4_script_decisions.md)。
> **决策依据**：[ADR-023](../decisions/ADR-023-level-layout-data-contract.md)、[ADR-006](../decisions/ADR-006-resource-first-data-and-data-keys.md)、[ADR-005](../decisions/ADR-005-no-compatibility-or-fallback-layers.md)。

## 1. 对象模型

| 类型 | 职责 |
|:---|:---|
| `LevelLayoutEntry` | 一关一份布局：尺寸、出生点、阶段、出口 |
| `LevelStageSpec` | 阶段：屏幕/触发矩形、开关挡板、刷怪点 |
| `LevelSpawnPoint` | 单点：位置、怪物 ID、数量、延迟、间隔、方向、前后依赖 |
| `LevelLayoutCatalog` | 场景路径 → 布局路径；不内联布局内容 |
| `LevelLayoutStore` | 按需加载单关布局；只读查询 |

布局数据只描述结构化关卡要素，不含渲染层、碰撞层或战斗数值。渲染仍在关卡场景；战斗数值走 `ZmwsConfig`。

## 2. 字段约束

- `stages` 非空时索引从 1 连续；长度可变，不设 4 阶段上限。
- 矩形必须落在 `layout_size` 内；终屏 `screen_rect` 允许零宽，其余宽高为正。
- `player_birth_points` 为空时沿用基类出生行为。
- `count >= 1`、`delay/interval >= 0`、`monster_ids` 非空且全部可解析。
- 方向按 int/字符串归一化后取符号；0 表示不变。
- 出口条件使用 `stage_clear`、`boss_dead`、`mids_dead`、`all_clear`、`auto`。
- 未登记布局视为沿用基类默认行为，不生成空布局。

## 3. 构建与运行时

- 构建源：`scripts/level_layout_sources.json`。
- 生成器：`scripts/convert_level_layout_catalog.py`；`--check` 校验 stage 连续、点位唯一、依赖存在、矩形范围和场景路径。
- 输出：`source/Script/data/level_layouts/*.tres` 与 `level_layout_catalog.tres`。
- 运行时只读；`LevelLayoutStore` 按场景懒加载并复用 Resource。
- 已迁移关卡的 `monster_group`/坐标表不得保留第二份数据源。
- 10 个动态/非连续例外由 `scripts/level_layout_data_exceptions.json` 登记，`level_layout_migration_audit.py` 校验精确集合；未登记或失效例外失败。

## 4. 验收

```bash
python scripts/convert_level_layout_catalog.py --check
python scripts/level_layout_migration_audit.py --fail-on-error
```

要求：生成器与 Catalog 同步；无「布局 + 脚本数据表」双源；例外集合精确；代表关卡与全量回归通过；不改变关卡数值、时序、掉落或输入。

完整 ZMWS 字段映射、迁移批次和历史验证见归档页；本页不复制逐关台账。
