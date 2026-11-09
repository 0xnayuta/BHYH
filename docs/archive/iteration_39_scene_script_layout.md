# Phase 39 Scene/Script 目录收敛归档

> 完成日期：2026-11-10。入口：[`../roadmap/current-iteration.md`](../roadmap/current-iteration.md)；规范：[`../standards/naming_standard.md`](../standards/naming_standard.md) §1.4；决策：[`../decisions/ADR-031-scene-script-relocation.md`](../decisions/ADR-031-scene-script-relocation.md)。

## 1. 范围

Phase 39 的目标是完成 `Scene/` 根级场景、`Script/` 根级脚本与混合场景目录的收敛，不改变玩法、数值、存档、输入映射或运行时行为。

## 2. 批次结果

| 批次 | 结果 |
|:---|:---|
| 39-0 根级清零与门禁 | `Scene/set_menu.tscn`、`Scene/auto_battle_config.tscn` 归 `Scene/level/`；`Script/main_menu/set_menu.gd` 归 `Script/level/set_menu.gd`；`Script/backpack.gd` 归 `Script/level/role_information_hud.gd`；`Script/monster_86.gd` 归 `Script/monster/monster_86.gd`；`naming_audit.py` 拦截 `Scene/*.tscn`、`Script/*.gd`，保留 `Scene/**/*.gd` |
| 39-1 `other_scene` 拆分 | 44 个场景按 10/11/8/4/7/3/1 迁移至 `Scene/main_menu/`、`Scene/other_menu/`、`Scene/skill/`、`Scene/level/`、`Scene/monster/`、`Scene/runtime/`、`Scene/archive_interface/`；`Scene/other_scene` 删除 |
| 39-2 文本、怪物与特效合并 | 29 个场景：`choose_scene` 归 `Scene/runtime/`，7 个文本场景归 `Scene/hittext/`，2 个血条 + 1 个受击场景归 `Scene/monster/`，18 个魂卡特效归 `Scene/hero/elite_soul_card/`；四个旧目录删除 |
| 39-3 大型目录与 Shader 评估 | 仅评估，不实施；结论见 §3 |
| 39-4 验收与文档 | 全部保留，不迁移、不删除；见 §4 |

结构结果：

- `Scene/` 根级 `.tscn` 为 0；
- `Script/` 根级 `.gd` 为 0；
- `Scene/` 顶层目录为 **22** 个；
- `project.godot` 主场景为 `res://Scene/runtime/startup_loading.tscn`；
- 不保留兼容 facade、旧路径重定向或永久双实现。

## 3. 39-3 评估结论

- `Scene/level/zmws/`：**1727 个 `.tscn` 保持平铺**，作为 `imported_unbound` / 预览参考域；仅 28 个 `Scene/level/zmws_playable/` 包装场景属于代表玩法入口；`Art/level/zmws/manifest.json` 与 `metadata.tres` 各登记 1727 条路径，两个场景探针依赖平铺目录，因此不做子目录迁移。
- `Script/monster/`：**261 个 `.gd` 保持现状**；196 个 `BaseMonster` 子类与 65 个 UI/特效/子弹/召唤辅助脚本混排；新怪物优先用 Resource/数据表承载，旧脚本作为基线，不做批量搬迁。`monster_zhw/` 是召唤物及观音效果子域，保持独立。
- `Shader/`：10 个 `.gdshader` 不分组迁移；`base_hero.gdshader` 与 `equipment_properies.gdshader` 当前零引用，**保留不删除**；角色描边暂缓，装备品质边框作为未启动创意登记在 [`../roadmap/roadmap.md`](../roadmap/roadmap.md) §4.3。

## 4. 39-4 验收

- 全量静态：`check_all --skip-engine` 全维度 PASS；
- 引擎：`health_check` 823 脚本，0 Parse Error / 0 Error / 0 Warning；
- 场景：`scene_probe_runner` **31/31 PASS**；
- 档案：`archive_probe_runner` **344/344 PASS**；
- 关卡：`level_1` PASS，0 ERROR / 0 WARNING；
- 命名：`naming_audit --all`、`naming_compliance_audit --fail-on-error`、`whitelist_audit --fail-on-error` 通过；
- 文档：`docs_audit` 969 链接 / 0 缺失；
- 结构：根级 `.tscn` / `.gd` 为 0，旧目录全部不存在，`Scene/` 顶层 22 个目录。

## 5. 关联

- [`../roadmap/roadmap.md`](../roadmap/roadmap.md) §4.3：品质颜色表、装备图标边框、角色描边试验；
- [`../guides/migration_playbook.md`](../guides/migration_playbook.md) §5.2：当前路径与符号回植索引；
- [`../reference/architecture.md`](../reference/architecture.md)：当前场景/脚本域结构；
- [`../reference/status.md`](../reference/status.md)：当前验证与保留边界。
