# 试点模块 API 与依赖方向（Phase 17-6）

> **状态**：17-6A/17-6B/17-6C 已完成，Phase 17 已归档；Phase 18 起见 [`current-iteration.md`](../roadmap/current-iteration.md)。范围仅 `pet_interface`、`zd_skill`、`base_role`、`base_magic_weapon`；未重排顶层目录，未全仓替换深层路径。
>
> **事实源**：`source/Script/pet/pet_interface.gd`、`source/Script/skill/zd_skill.gd`、`source/Script/base/base_role.gd`、`source/Script/base/base_magic_weapon.gd`。公开方法指供场景脚本、父节点或跨模块调用的方法；下划线开头方法默认是内部实现，除非本节显式列为回调。

## 1. 公开 API

### 1.1 `BaseRole`（`Script/base/base_role.gd`）

| 项 | 契约 |
|:---|:---|
| 注入字段 | `player`：HUD 所属英雄；必须在 `_ready` 前注入。`pet_panel`：可选宠物面板节点 |
| 公开查询 | `is_full_ws() -> bool` |
| 生命周期 | `reveal_after_scene_loaded() -> void`：场景加载完成后显示 P1/P2 HUD 并布局技能栏 |
| 内部渲染 | `_physics_process` → `_set_values`/`_set_pet_values`/`_set_skill_pic` 等；只读档案与属性，不写档 |
| 信号 | 无 |
| 场景依赖 | `base_role.tscn` 的 `role_hp_mp_exp`、`role_menu`、`SkillBox`、技能槽、宠物面板节点；由 HUD 父级 `role_information` 实例化并注入 `player` |
| 外部依赖 | `LocalCoop.data_for/props_for`（槽位解析）、`Global.all_buff_list`、`Global.mg_cd_pic`、`PlayerData`/`RoleProp` 属性 getter |

### 1.2 `BaseMagicWeapon`（`Script/base/base_magic_weapon.gd`）

| 项 | 契约 |
|:---|:---|
| 注入字段 | `player`：法宝持有英雄；缺失时槽位查询回退 1 号 |
| 公开方法 | `set_magic_weapon_player(hero) -> void`、`get_attack_snapshot(attack_name := "hit1") -> Dictionary`、`use_skill() -> void`、`enough_mp() -> bool`、`show_skill() -> void`、`fix_hero() -> void`、`use_over() -> void` |
| 公开属性 | `player`、`current_player_magic_summon`（读写委托 `Global`）、`fb_cd`、`fb_level` |
| 信号 | 无 |
| 场景依赖 | `mg_action`（`AnimatedSprite2D`）、`mg_player`（`AnimationPlayer`）、`skill_cd`（`Timer`）、`hitbox`/`hit_box`（碰撞） |
| 外部依赖 | `LocalCoop.data_for/props_for`、`Global.get_magic_summon_for/set_magic_summon_for`、`AudioRuntime.add_sound` 等表现入口 |

### 1.3 `zd_skill`（`Script/skill/zd_skill.gd`）

| 项 | 契约 |
|:---|:---|
| 公开入口 | `up_level()`（升级并提交）、`refresh_infor(save_state := true) -> bool`、`init_skill_variants()`、`update_skill_name_and_icon(...)`、`setup_variant_menu(...)` |
| 公开查询 | `get_role_key() -> String`、`get_level_storage_index(index) -> int`、`get_skill_level_by_index(index) -> int`、`get_skill_max_level(skill_internal) -> int`、`get_skill_book_need(level) -> int`、`get_skill_book_id(level) -> String`、`get_skill_book_name(level) -> String`、`get_skill_list_name(num) -> String`、`get_skill_row_heights() -> Array[float]` |
| 场景回调 | `_on_skill_N_pressed`、`_on_ski_N_pressed`、`_on_ski_N_mouse_entered/exited` 由 `learn_skill.tscn` 连接；不视为外部 API |
| 信号 | 无 |
| 场景依赖 | `ScrollContainer/HBoxContainer` 下的 `Sk_na`、`sk_pi`、`sk_lv`、`sk_le`、`sk_ms` 五列；`SkillGridBackdrop` |
| 外部依赖 | `PlayerData`（技能学习/等级/灵魂）、`PaSkill`、`RoleProp`（等级判定）、`Global.add_message_show`、`LocalCoop.data_for/props_for` |

### 1.4 `pet_interface`（`Script/pet/pet_interface.gd`）

| 项 | 契约 |
|:---|:---|
| 公开命令 | `ate_click`、`eip_click`、`groom_click`、`release_click`、`fight_click`、`rest_click`、`eat_immor`、`push_pet_skill`、`push_pet_attribute`、`ok_click`、`pet_backpack_click`、`no_click`、`pet_strength_click` |
| 公开查询 | 无稳定只读 API；面板内部通过 `PlayerData`/`LocalCoop` 查询 |
| 场景回调 | 大量 `_on_*`/`_*_click` 按钮回调；只作为 `pet_interface.tscn` 连接入口 |
| 信号 | 无 |
| 场景依赖 | `PetAttributeShow`、`PetBackPackShow`、`PetDevelopInterface`、`PetSkillLearnPopup`、`PetSkillUpgradePopup`、`PetFormationPopup`、`PetAttributePages` 根节点及子节点 |
| 外部依赖 | `PlayerData`（宠物、背包、成长、技能书）、`LocalCoop.data_for/props_for`、`Global.add_message_show`、`AE`、`MainSet` |

## 2. 依赖方向

| 方向 | 规则 | 现状 |
|:---|:---|:---|
| 父场景 → 模块 | 父级实例化并注入 `player`/`pet_panel`；模块不反向持有父级业务字段 | `role_information` 注入 `player`/`player_p2`；`pet_interface` 由宠物面板父级实例化 |
| 模块 → 档案 | 读写经 `LocalCoop.data_for`/`props_for` 解析槽位；跨模块写经 `PlayerData` 命令 | HUD 只读；技能升级经 `PlayerData`/`up_level`；宠物命令经 `PlayerData` |
| 模块 → 全局 | 可用 `Global` 表现/场景入口，但不得在 HUD 绘制回调写档 | 本批清理后无新增 HUD 写档 |
| 模块 → 其他模块私有字段 | 禁止；父调用子公开方法，子用信号/回调通知 | 本批未新增跨模块私有访问 |
| 面板 → 场景树 | 深层路径限定在模块自身场景根内；跨模块节点通过注入或公开方法 | `BaseRole` 不再访问 `/root`；`zd_skill` 路径统一经列访问器 |

**禁止**：新增 `/root/<Autoload>` 绝对路径；在 `_process`/`_physics_process` 直接写 `PlayerData.player_data`；跨模块直接读取对方私有字段或节点。

## 3. 路径清理

| 文件 | 清理前深层字面路径 | 清理后 | 方式 |
|:---|:---:|:---:|:---|
| `pet_interface.gd` | 117 | 0 | 保留 `_pet_ui_node(root, child)`；动态行先取 `Content`，再取直接子节点，消除剩余 `Content/*` 与嵌套字面路径 |
| `zd_skill.gd` | 26 | 0 | 新增 `SKILL_UI_ROOT`、`_skill_root_node`、`_skill_column_node`、`_skill_grandchild`、`_skill_column_path` |
| `base_role.gd` | 12 | 0 | 删除 `/root` 回落；宠物 HUD 先取 `hp_bar`/`mp_bar`/`exp_bar`/`PanelContainer`，再取子节点，深层字面路径清零 |
| `base_magic_weapon.gd` | 4 | 0 | 同上；法宝数据/属性改由 `LocalCoop` 槽位查询 |
| `Scene/other_scene/skill_icon.gd` | 2 处 `/root` | 0 | 删除 `/root/LocalCoop` 与 `/root/PlayerData`/`RoleProp` 回落，直接 `LocalCoop.data_for/props_for` |

统计口径：`get_node()`/`get_node_or_null()` 字符串参数中包含 `/` 或 `/root` 的字面路径；不含动态拼接后的运行时结果。

## 4. 验证

- `archive_probe_runner` 275 项 PASS（含 `zd_skill` 主动技能成功/保存失败回滚、`pet_interface` 根节点解析）；
- `coop_probe_runner` 23/23 PASS（P1/P2 HUD 与宠物 HUD）；
- `level_1` 冒烟 PASS（0 ERROR / 0 WARNING）；
- `level_regression_all --changed-only` 128/128 PASS + 5 SKIP（273.6s）；
- `check_all --godot-bin` 8/8 PASS。

## 5. 未迁移项

- `pet_interface`/`base_role` 深层字面路径为 **0**；未改场景节点名或 `%UniqueName`，以中间节点访问器消除字面深层路径；
- `skill_icon.gd` 的 `/root` 回落为 **0**，`SLOT_ROOT_ALLOWLIST` 移除该文件并加入 Phase 17 绝对路径禁入清单；
- 本批未移动任何文件、未重排目录、未修改场景节点名或输入映射。
