# Phase 30：关卡布局数据契约（归档）

> **归档日期**：2026-11-01
> **状态**：Archived
> **关联**：[ADR-023](../decisions/ADR-023-level-layout-data-contract.md)、[`level_layout_contract.md`](../reference/level_layout_contract.md)、[`phase_30_4_script_decisions.md`](phase_30_4_script_decisions.md)、[`architecture.md`](../reference/architecture.md) §4.3、[`status.md`](../reference/status.md)

## 1. 阶段结果

Phase 30 将 BHYH 关卡脚本中的结构化布局数据迁出为构建期生成的 Resource Catalog，并接入原始 ZMWS 关卡驱动器。完成时：

- 布局资源 **90 个**：`level_48` 试点、20 个原始 ZMWS 代表关卡、69 个已迁移 BHYH 关卡；
- 硬编码 `monster_group` 的脚本从 **85 个降至 10 个**；10 个均为动态/非连续流程的登记例外；
- 6 个空数据表删除；
- 30-4 对原 85 个数据容器脚本逐项复核：**55 个含独立玩法逻辑的脚本保留，30 个标准流程/空表脚本分类**；
- 外部怪物映射 **512 条**，原始 ZMWS 驱动器已接入；
- 发布依赖闭包包含布局 Catalog 与 90 个布局资源。

## 2. 迁移前差距

- 85 个关卡脚本直接维护 `monster_group` 字典，每个脚本约 30–100 行；
- 分屏最多 30 屏；`Gateway` 最多 32 个；`direction` 存在 int 与字符串混用及 `-5` 值；
- 接入 ZMWS 1,701 关时，直接复制脚本会把外部数据重新硬编码，无法形成可审计的数据契约；
- 既有扩展点 `_stage_count()` / `_stage_trigger_x()` / `_screen_starts()` / `_screen_rights()` / `_birth_points()` 可复用，无需重写 `BaseLevel` 继承结构。

## 3. 实施批次

### 30-0 设计与评审

- 产出 ADR-023 与 [`level_layout_contract.md`](../reference/level_layout_contract.md)；
- 确定五件套：`LevelLayoutEntry`、`LevelStageSpec`、`LevelSpawnPoint`、`LevelLayoutCatalog`、`LevelLayoutStore`；
- 明确“构建期生成、运行时只读、未登记场景沿用既有逻辑”的迁移策略；
- 不改变任何玩法数值、时序、掉落与输入。

### 30-1 五件套与单关试点

- 新增五件套与 `convert_level_layout_catalog.py`、`level_layout_sources.json`、`--check`；
- `BaseLevel` 的五个扩展点改为“有布局资源时读资源，未登记沿用现状”；
- 玩家出生点与刷怪点分离；
- 迁移 `level_48`，删除脚本内布局常量与五个覆写；
- 验收：`level_48` Stage 1–5 冒烟 PASS；`check_all` 9/9；全量回归通过。

### 30-2 外部怪物映射与代表关卡

- 新增 `ExternalMonsterCatalog` / `ExternalMonsterStore`：按中文名精确匹配，唯一归一化补 6 条，共 512 条；
- 新增 `ZmwsLevel` 与 `zmws_level_base.tscn`：组合原始地图、归一地面层、隐藏基础背景、布局驱动分屏/出口、深坐标刷怪；
- 20 个 `Scene/level/zmws_playable` 包装关卡，覆盖单屏、2 屏、5 屏与活动/剧情关；
- 验收：20/20 Stage 全 PASS 且 `can_pass=True`；日志 0 ERROR / 0 WARNING。

### 30-3 数据容器脚本迁出

- 按批迁移 85 个硬编码 `monster_group` 脚本；
- 共迁出 69 个：20 个单屏、13 个多阶段、36 个按最小长度截断；
- 删除 6 个空数据表；
- 10 个动态/非连续脚本登记例外，写入 `level_layout_data_exceptions.json`；
- 新增 `level_layout_migration_audit.py` 阻断脚本与布局双源；
- 每批迁移后删除脚本内数据表，不保留双份。

### 30-4 边界收尾

- 对原 85 个数据容器脚本逐项复核；
- 55 个含独立玩法逻辑的脚本保留，仅迁出其中的结构化数据块；
- 30 个标准流程/空表脚本分类：24 个已迁出、6 个空表删除；
- 更新 `architecture.md` §4.3、`status.md`、路线图与索引；
- 新增 [`phase_30_4_script_decisions.md`](phase_30_4_script_decisions.md) 记录逐项结论。

## 4. 完成时基线

> 以下为 2026-11-01 的阶段快照，不是长期 SLA。

| 项 | 快照 |
|:---|:---:|
| BHYH 关卡场景 / 脚本 | 153 / 164 |
| 硬编码 `monster_group` 脚本 | 10（均为例外） |
| 布局资源 | 90 |
| 原始 ZMWS 关卡场景 | 1,701 |
| ZMWS 包装关卡 | 20 |
| 外部怪物映射 | 512 |
| 发布依赖路径 | 4,191 |
| 验证用 PCK | 7,564,668,351 字节 |

## 5. 验证记录

- `check_all --godot-bin` 9/9 PASS；
- 全量关卡回归 **128/128 PASS + 5 SKIP**；30-4 收尾后基线总耗时 710.9s；
- 20/20 原始 ZMWS 代表关卡 Stage 全 PASS；
- 30-4 发布闭包复跑：4,191/4,191 条依赖可达，导出 + 包内校验 834.8s；PCK 使用 `all_resources` 验证预设，只证明路径闭包，不等于最小发布包或目标设备性能；
- 日志 0 ERROR / 0 WARNING。

## 6. 例外与边界

10 个登记例外：

```text
level_20
level_34_1
level_36
level_37
level_46
level_bxgh
level_llbt
level_sssl
level_stz
liu_sha_river_boss_level
```

例外覆盖动态刷怪、非连续流程或运行时坐标计算；逐项理由与数据处置见 [`phase_30_4_script_decisions.md`](phase_30_4_script_decisions.md)。

保留边界：

- 不重写 `BaseHero` / `BaseMonster` / `BaseThroughLevel` 继承；
- 不把 `PlayerData.player_data` 整体 Resource 化；
- 不保留已迁移关卡脚本内的数据副本；
- 不改变伤害、掉落、关卡时序、输入映射、存档格式与双人规则。

## 7. 发布闭包

- `level_preload_export_dependencies.json` 升级为 schema v2；
- 新增 `layout_catalog` 与 90 个布局路径；
- `frame_sequence_pack_probe.py` 合并 FrameSequence 与关卡预载清单，实际导出 PCK 并逐项验证路径可达；
- 资源再次变化后必须重跑 PCK，不沿用本归档的包体与路径数量。

## 8. 后续

Phase 30 已完成并归档。布局数据契约继续由 [`level_layout_contract.md`](../reference/level_layout_contract.md) 与 [`phase_30_4_script_decisions.md`](phase_30_4_script_decisions.md) 维护；当前迭代转入 Phase 32 / 33 规划，见 [`current-iteration.md`](../roadmap/current-iteration.md)。
