# 试点模块公开 API 与依赖方向

> **定位**：记录 `BaseRole`、`BaseMagicWeapon`、`zd_skill` 与 `pet_interface` 当前公开 API 的边界；实现和调用者以源码/LSP 为准。
> **历史**：Phase 17-6 路径迁移、调用预算和验收见 [`../archive/iteration_17_gameplay_module_boundaries.md`](../archive/iteration_17_gameplay_module_boundaries.md)。
> **范围**：下划线前缀方法默认是内部实现，本页显式列出的场景回调除外。

## 1. 公开 API

### 1.1 `BaseRole` (`Script/base/base_role.gd`)

| 项 | 契约 |
|:---|:---|
| 注入字段 | `player`：HUD 所属英雄，须在 `_ready` 前注入；`pet_panel`：可选宠物面板 |
| 公开查询/生命周期 | `is_full_ws() -> bool`；`reveal_after_scene_loaded() -> void` |
| 归属 | `PlayerData` / `RoleProp` getter 按注入的 `player` 经 `LocalCoop` 解析 |
| 回调 | `_physics_process` 与 `_on_*` 属内部渲染/场景回调；只读档案和属性 |

### 1.2 `BaseMagicWeapon` (`Script/base/base_magic_weapon.gd`)

| 项 | 契约 |
|:---|:---|
| 注入字段 | `player`：法宝持有英雄；未设置时数据/属性查询使用 1 号槽位 |
| 公开方法 | `set_magic_weapon_player`、`get_attack_snapshot`、`use_skill`、`enough_mp`、`show_skill`、`fix_hero`、`use_over` |
| 公开属性 | `player`、`current_player_magic_summon`、`fb_cd`、`fb_level` |
| 依赖 | `LocalCoop` 槽位查询、`Global` 法宝运行时和音频入口 |

### 1.3 `zd_skill` (`Script/skill/zd_skill.gd`)

| 项 | 契约 |
|:---|:---|
| 命令/刷新 | `up_level`、`refresh_infor`、`init_skill_variants`、`update_skill_name_and_icon`、`setup_variant_menu` |
| 查询 | 角色键、技能存储索引/等级/上限、技能书和行高查询 |
| 回调 | `_on_skill_*` / `_on_ski_*` 由 `learn_skill.tscn` 连接，不是调用方 API |
| 操作者 | getter 经 `LocalCoop.data_for/props_for(self)`；不得假定 1P |

### 1.4 `pet_interface` (`Script/pet/pet_interface.gd`)

| 项 | 契约 |
|:---|:---|
| 场景命令 | 出战/休息、喂养/培养、技能面板、背包入口及相关场景回调 |
| View/Command | 宠物列表、出战/休息、成长、阵法、被动遵循 [`pet_domain_contract.md`](pet_domain_contract.md) |
| 回调 | `_on_*` / `_*_click` 多为场景连接点，不作为跨模块稳定 API |
| 操作者 | 通过注入的面板槽位/`LocalCoop` 解析 |

## 2. 依赖方向

- 父场景实例化并注入 `player` / `pet_panel`；模块不反向持有父级业务字段。
- 档案读写经 `LocalCoop` 槽位查询与 `PlayerData` 命令；HUD 只读。
- 模块可使用 `Global` 的正式表现入口；不得在渲染回调直接写档。
- 禁止新增 `/root/<Autoload>` 回落、跨模块私有字段访问和跨场景深层路径。

本页不维护动态调用数或历史路径计数；路径门禁见 [`acceptance.md`](acceptance.md)，架构规则见 [`../standards/godot_design_standard.md`](../standards/godot_design_standard.md)。