# Phase 29 Scene 脚本落位归档

> **归档日期**：2026-11-09
> **状态**：Archived
> **关联**：[`ADR-031`](../decisions/ADR-031-scene-script-relocation.md)、[`../standards/naming_standard.md`](../standards/naming_standard.md) §1.4、[`../reference/architecture.md`](../reference/architecture.md)

## Phase 29 `Scene/` 脚本落位（29-0~29-4 完成；Phase 29 完成）

- **目标**：统一 GDScript 落位规则为“`Scene/` 不存放 `.gd`，全部归 `Script/<domain>/`”，迁移当前 56 个场景脚本。
- **入口**：`source/Scene/` 下 56 个 `.gd`；[`naming_standard.md`](../standards/naming_standard.md) §1.2、§2.1；`scripts/naming_audit.py`。
- **非目标**：不改脚本行为；不搬 `Scene/` 下的 `.tscn`/`.tres`；不新建顶层类型目录；不处理 `global.gd`。

#### 29-0 规范与清单（完成）

- 更新 `naming_standard.md`：`Scene/` 承载场景树与预制体，`.gd` 一律归 `Script/<domain>/`。
- 产出 56 个文件的逐文件目标路径清单，检查同名冲突与场景引用。
- 新增或修订目录落位 ADR，同步 `architecture.md` 的目录说明。
- **产出**：`naming_standard.md` v2.2.0（§1.2、§1.4、§2.1）；[`ADR-031`](../decisions/ADR-031-scene-script-relocation.md)；本页附录的 56 文件迁移清单；56 个映射无同名冲突，10 个目标目录均无同名目标文件。

#### 29-1 应用编排与档案（完成）

- `load_scene.gd`、`startup_loading.gd`、`userload.gd`、`auto_battle_config.gd` → `Script/runtime/`。
- `bacis_ar_button.gd` → `Script/archive_interface/`。
- **完成记录**：`rename_path.py` 批量迁移 5 个脚本与 `.uid`；5 个 `.tscn` 的 `ext_resource` 同步；更新 `contract_scan.py` 路径基线、两份 theme 基线、`naming_whitelist.md` 与 `ADR-018` 链接；`check_all`、`health_check`、`level_1` 通过。

#### 29-2 菜单、关卡、奖励、阵法与怪物（29-2A、29-2B、29-2C 完成）

- 菜单、帮助、结算、角色选择 → `Script/main_menu/`、`Script/other_menu/`、`Script/level/`。
- 奖励与幻化 → `Script/other_menu/`；阵法与技能图标 → `Script/skill/`。
- 怪物、血条、受击、Buff、光环 → `Script/monster/`；怪物数据 → `Script/data/`。

#### 29-3 文本表现与角色特效（完成）

- `choose_scene.gd` → `Script/runtime/`；`combo`、`message`、`moment_text`、`touch_text`、`liji` → `Script/hittext/`。
- `special_effect_bullet.gd` → `Script/hero/`。
- **完成记录**：`rename_path.py` 批量迁移 9 个脚本与 `.uid`；同步 9 个 `.tscn` 的 `ext_resource`；更新两份 theme 基线的 `message_info` 路径；`contract_gate`、`check_all`、`health_check`、`level_1` 通过；`Scene/` 下 `.gd` 为 0。

#### 29-4 门禁启用（完成）

- `naming_audit.py` 增加 `source/Scene/**/*.gd` 报 ERROR 的规则；清理路径变化产生的白名单旧条目。
- **完成记录**：`naming_audit.py` 落位规则已启用；负向探针被拦截；`naming_audit --all`、`naming_compliance_audit --fail-on-error`、`whitelist_audit --fail-on-error`、`check_all`、`docs_audit` 通过。
- **出口**：`Scene/` 下 `.gd` 为 0；`check_all`、`health_check`、`scene_probe_runner`、相关关卡回归通过；`docs_audit` 0 缺失链接。

---

---

### 56 文件迁移清单（Phase 29-0）

> **状态**：29-1、29-2A、29-2B、29-2C、29-3 已迁移；`source/Scene/` 下 `.gd` 为 0；29-4 门禁已启用；Phase 29 完成。
>
> **规则**：`source/Scene/` 只承载 `.tscn`/`.tres`；全部 `.gd` 归 `source/Script/<domain>/`。决策见 [`../decisions/ADR-031-scene-script-relocation.md`](../decisions/ADR-031-scene-script-relocation.md)。
>
> **范围**：`source/Scene/` 下 **56** 个 `.gd`；不移动 `.tscn`/`.tres`，不修改脚本行为。
>
> **执行**：每批只通过 `scripts/rename_path.py` 迁移，引用由工具同步；禁止手工批量替换。每批后运行 `check_all`、`health_check` 与相关探针。

## 1. 引用与冲突检查

- 56 个源文件均无同名 `.gd` 冲突；10 个目标目录均无同名目标文件。
- 55 个源文件由同名 `.tscn` 的 `ext_resource` 直接引用；`Scene/monster_blood/buff_list.gd` 由 `boss_blood.tscn` 引用。
- 跨脚本/资源引用必须在迁移后核对：
  - `Scene/other_scene/monster_head_info.gd` → `Scene/other_scene/monster_attr_data.gd`
  - `Script/main_menu/equipment_catalog_data.gd` → `Scene/other_scene/level_info.gd`
  - `Script/runtime/level_entry_runtime.gd` → `level_info.tscn`
  - `Scene/hero/role_1/hmz_effect/special_effect_bullet_1.tscn` → `level_info.tscn` 与 `special_effect_bullet.gd`
  - `Script/data/role_runtime/role_1_runtime.tres`、`combat_presentation_factory.gd` → `special_effect_bullet.gd`
  - `global.gd` 与 `popup_factory.gd`/`show_text_factory.gd`/`combat_presentation_factory.gd` 等工厂持有多个 `res://Scene/...` 字符串路径，必须由迁移工具同步。
- `Scene/other_scene/star.gd` 当前未发现场景/脚本引用；仍按清单迁移，批次验证时确认是否可加载。

## 2. Phase 29-1：应用编排与档案（5）· 已完成

> 5 个脚本已通过 `scripts/rename_path.py` 批量迁移；`.uid` 与 5 个对应 `.tscn` 的 `ext_resource` 同步；`source/Scene/` 下剩余 51 个 `.gd`。基线同步：`contract_scan.py` 的 `load_scene`/`bacis_ar_button` 路径、`ui_dynamic_theme_baseline.json`、`theme_override_baseline.json`、`naming_whitelist.md` 与 `ADR-018` 证据链接。验证：`check_all` 7/7、`health_check` 823 脚本 0/0/0、`level_1` 4 阶段 0/0/0、`scene_probe_runner` 全量 PASS（345.46s）、`docs_audit` 940/0。

| 源路径 | 目标路径 | 场景/引用 |
|:---|:---|:---|
| `Scene/auto_battle_config.gd` | `Script/runtime/auto_battle_config.gd` | `auto_battle_config.tscn`；`set_menu.gd` 持有 `auto_battle_config.tscn`（场景路径不变） |
| `Scene/other_scene/load_scene.gd` | `Script/runtime/load_scene.gd` | `load_scene.tscn`；`startup_loading.gd`、`scene_flow.gd` 引用 |
| `Scene/other_scene/startup_loading.gd` | `Script/runtime/startup_loading.gd` | `startup_loading.tscn`；`project.godot` 主场景 |
| `Scene/other_scene/userload.gd` | `Script/runtime/userload.gd` | `userload.tscn` |
| `Scene/other_scene/bacis_ar_button.gd` | `Script/archive_interface/bacis_ar_button.gd` | `bacis_ar_button.tscn`；`menu_panel_factory.gd` |

## 3. Phase 29-2：菜单、帮助、结算、奖励、阵法与怪物（42）

> **29-2A 已完成（13）**：`monster_attr_data.gd` → `Script/data/`；`skill_icon.gd` 与 7 个阵法脚本 → `Script/skill/`；`after_level_end.gd`、`level_info.gd`、`ping_jia.gd`、`star.gd` → `Script/level/`。迁移后 6 个阵法 UI 增加槽位 `PlayerData` getter，`zhen_fa_ui.gd` 的佩戴写入改经 `PlayerData.set_equipped_formation()`；`Scene/` 剩余 38 个 `.gd`。验证：`check_all` 7/7、`health_check` 823 脚本 0/0/0、`level_1` 4 阶段 0/0/0、`scene_probe_runner` 全量 PASS（355.92s）、`docs_audit` 940/0。29-2B（main_menu/other_menu 19）与 29-2C（monster 10）未开始。
>
> **29-2B 已完成（19）**：11 个主菜单脚本 → `Script/main_menu/`；8 个公告/帮助/奖励/幻化脚本 → `Script/other_menu/`。`twenty_eight_constellations_button.gd` 的南北星宿颜色改用 `UiColorTokens.TEXT_CONSTELLATION_NORTH/SOUTH`（token 源新增两项并重新生成）；`Scene/` 剩余 19 个 `.gd`。验证：`contract_gate` 全 PASS、`check_all` 7/7、`health_check` 823 脚本 0/0/0、`level_1` 4 阶段 0/0/0、`scene_probe_runner` 全量 PASS（347.42s）、`docs_audit` 940/0。29-2C（monster 10）与 29-3（9）未开始。
>
> **29-2C 已完成（10）**：10 个怪物、血条、受击、Buff 与光环脚本 → `Script/monster/`。`monster_head_info.gd` 的 4 处 StyleBox 颜色改用 `UiSurfaceTokens.OVERLAY_EARTH` 与新增 `MONSTER_SELECT_BG`/`MONSTER_SELECT_BORDER`/`MONSTER_INFO_BORDER`（token 源新增三项并重新生成）；`Scene/` 剩余 9 个 `.gd`。验证：`contract_gate` 全 PASS、`check_all` 7/7、`health_check` 823 脚本 0/0/0、`level_1` 4 阶段 0/0/0、`scene_probe_runner` 全量 PASS（348.46s）、`docs_audit` 940/0。29-3 未开始。
>
> **29-3 已完成（9）**：`choose_scene.gd` → `Script/runtime/`；`combo`、`combo_num`、`liji`、`message_info`、`message_show`、`moment_text`、`touch_text` → `Script/hittext/`；`special_effect_bullet.gd` → `Script/hero/`。`source/Scene/` 下 `.gd` 为 **0**。验证：`contract_gate` 全 PASS、`check_all` 7/7、`health_check` 823 脚本 0/0/0、`level_1` 4 阶段 0/0/0、`scene_probe_runner` 全量 PASS（346.34s）、`docs_audit` 940/0。29-4 门禁未启用。
>
> **29-4 已完成**：`naming_audit.py` 对 `source/Scene/**/*.gd` 报 `ERROR`；负向探针被拦截；`naming_audit --all`、`naming_compliance_audit`、`whitelist_audit`、`check_all`、`docs_audit` 通过。Phase 29 完成。

### 3.1 主菜单与设置（11）· 已完成

| 源路径 | 目标路径 | 场景/引用 |
|:---|:---|:---|
| `Scene/other_scene/choose_music.gd` | `Script/main_menu/choose_music.gd` | `choose_music.tscn`；`menu_panel_factory.gd`、`ui_runtime.gd` |
| `Scene/other_scene/lhhj.gd` | `Script/main_menu/lhhj.gd` | `lhhj.tscn`；`menu_panel_factory.gd`、`level_lhhj.tscn` |
| `Scene/other_scene/lhhj_button.gd` | `Script/main_menu/lhhj_button.gd` | `lhhj_button.tscn`；`menu_panel_factory.gd` |
| `Scene/other_scene/lhhj_help.gd` | `Script/main_menu/lhhj_help.gd` | `lhhj_help.tscn`；`menu_panel_factory.gd` |
| `Scene/other_scene/lsh.gd` | `Script/main_menu/lsh.gd` | `lsh.tscn`；`map_overlay_factory.gd` |
| `Scene/other_scene/lxdy.gd` | `Script/main_menu/lxdy.gd` | `lxdy.tscn`；`map_overlay_factory.gd` |
| `Scene/other_scene/return_back_map.gd` | `Script/main_menu/return_back_map.gd` | `return_back_map.tscn`；`menu_panel_factory.gd` |
| `Scene/other_scene/role_button.gd` | `Script/main_menu/role_button.gd` | `role_button.tscn` |
| `Scene/set_menu.gd` | `Script/main_menu/set_menu.gd` | `set_menu.tscn`；`ui_runtime.gd`、`backpack.gd` |
| `Scene/other_scene/twenty_eight_constellations.gd` | `Script/main_menu/twenty_eight_constellations.gd` | `twenty_eight_constellations.tscn`；`ui_runtime.gd` |
| `Scene/other_scene/twenty_eight_constellations_button.gd` | `Script/main_menu/twenty_eight_constellations_button.gd` | `twenty_eight_constellations_button.tscn`；同级面板 |

### 3.2 公告、帮助、奖励与幻化（8）· 已完成

| 源路径 | 目标路径 | 场景/引用 |
|:---|:---|:---|
| `Scene/other_scene/a_letter_for_all_players.gd` | `Script/other_menu/a_letter_for_all_players.gd` | `a_letter_for_all_players.tscn`；`show_text_factory.gd` |
| `Scene/other_scene/game_need_know.gd` | `Script/other_menu/game_need_know.gd` | `game_need_know.tscn`；`level_hint_factory.gd` |
| `Scene/other_scene/hc_help.gd` | `Script/other_menu/hc_help.gd` | `hc_help.tscn`；`level_hint_factory.gd` |
| `Scene/other_scene/help_things.gd` | `Script/other_menu/help_things.gd` | `help_things.tscn`；`level_hint_factory.gd` |
| `Scene/other_scene/list_button.gd` | `Script/other_menu/list_button.gd` | `list_button.tscn`；`menu_panel_factory.gd` |
| `Scene/other_scene/reward_box_2.gd` | `Script/other_menu/reward_box_2.gd` | `reward_box_2.tscn`；`reward_factory.gd` |
| `Scene/other_scene/reward_interface.gd` | `Script/other_menu/reward_interface.gd` | `reward_interface.tscn`；`reward_factory.gd` |
| `Scene/other_scene/transmogtified_box.gd` | `Script/other_menu/transmogtified_box.gd` | `transmogtified_box.tscn`；`shop_factory.gd`、`ui_runtime.gd` |

### 3.3 关卡信息与结算（4）· 已完成

| 源路径 | 目标路径 | 场景/引用 |
|:---|:---|:---|
| `Scene/other_scene/after_level_end.gd` | `Script/level/after_level_end.gd` | `after_level_end.tscn`；`reward_factory.gd` |
| `Scene/other_scene/level_info.gd` | `Script/level/level_info.gd` | `level_info.tscn`；`level_entry_runtime.gd`、`equipment_catalog_data.gd`、`special_effect_bullet_1.tscn` |
| `Scene/other_scene/ping_jia.gd` | `Script/level/ping_jia.gd` | `ping_jia.tscn`；`show_text_factory.gd` |
| `Scene/other_scene/star.gd` | `Script/level/star.gd` | `star.tscn`；未发现引用 |

### 3.4 技能与阵法（8）· 已完成

| 源路径 | 目标路径 | 场景/引用 |
|:---|:---|:---|
| `Scene/other_scene/skill_icon.gd` | `Script/skill/skill_icon.gd` | `skill_icon.tscn`；`base_role.gd` |
| `Scene/other_scene/zhen_fa_help.gd` | `Script/skill/zhen_fa_help.gd` | `zhen_fa_help.tscn`；`zhen_fa_factory.gd` |
| `Scene/other_scene/zhen_fa_tu_po.gd` | `Script/skill/zhen_fa_tu_po.gd` | `zhen_fa_tu_po.tscn`；`zhen_fa_factory.gd` |
| `Scene/other_scene/zhen_fa_ui.gd` | `Script/skill/zhen_fa_ui.gd` | `zhen_fa_ui.tscn`；`ui_runtime.gd` |
| `Scene/other_scene/zhen_yan_cure_level.gd` | `Script/skill/zhen_yan_cure_level.gd` | `zhen_yan_cure_level.tscn`；`zhen_fa_factory.gd` |
| `Scene/other_scene/zhenfainfo.gd` | `Script/skill/zhenfainfo.gd` | `zhenfainfo.tscn`；`zhen_fa_factory.gd` |
| `Scene/other_scene/zhenfalxbutton.gd` | `Script/skill/zhenfalxbutton.gd` | `zhenfalxbutton.tscn`；`zhen_fa_factory.gd` |
| `Scene/other_scene/zhenyanbutton.gd` | `Script/skill/zhenyanbutton.gd` | `zhenyanbutton.tscn`；`zhen_fa_factory.gd`、`zhen_yan_cure_level.tscn` |

### 3.5 怪物、血条、受击、Buff 与光环（10）· 已完成

| 源路径 | 目标路径 | 场景/引用 |
|:---|:---|:---|
| `Scene/other_scene/auras.gd` | `Script/monster/auras.gd` | `auras.tscn`；`effect_factory.gd` |
| `Scene/other_scene/basic_monment_info.gd` | `Script/monster/basic_monment_info.gd` | `basic_monment_info.tscn`；`monster_display_factory.gd` |
| `Scene/other_scene/buff_icon.gd` | `Script/monster/buff_icon.gd` | `buff_icon.tscn`；`base_role.gd`、`boss_blood.gd`、`combat_presentation_factory.gd` |
| `Scene/other_scene/buff_information.gd` | `Script/monster/buff_information.gd` | `buff_information.tscn`；`popup_factory.gd` |
| `Scene/monster_blood/buff_list.gd` | `Script/monster/buff_list.gd` | `boss_blood.tscn` |
| `Scene/monster_damage/monster_be_hit.gd` | `Script/monster/monster_be_hit.gd` | `monster_be_hit.tscn`；`audio_runtime.gd`、`combat_presentation_factory.gd`、`global.gd` |
| `Scene/monster_blood/monster_blood_bar.gd` | `Script/monster/monster_blood_bar.gd` | `monster_blood_bar.tscn`；`combat_presentation_factory.gd`、`global.gd` |
| `Scene/other_scene/monster_head.gd` | `Script/monster/monster_head.gd` | `monster_head.tscn` |
| `Scene/other_scene/monster_head_info.gd` | `Script/monster/monster_head_info.gd` | `monster_head_info.tscn`；`monster_display_factory.gd` |
| `Scene/other_scene/nmw_aura.gd` | `Script/monster/nmw_aura.gd` | `nmw_aura.tscn`；`effect_factory.gd` |

### 3.6 怪物数据（1）· 已完成

| 源路径 | 目标路径 | 场景/引用 |
|:---|:---|:---|
| `Scene/other_scene/monster_attr_data.gd` | `Script/data/monster_attr_data.gd` | 无同名 `.tscn`；`monster_head_info.gd` 引用 |

## 4. Phase 29-3：文本表现与角色特效（9）· 已完成

| 源路径 | 目标路径 | 场景/引用 |
|:---|:---|:---|
| `Scene/show_text/choose_scene.gd` | `Script/runtime/choose_scene.gd` | `choose_scene.tscn`；`popup_factory.gd` |
| `Scene/show_text/combo.gd` | `Script/hittext/combo.gd` | `combo.tscn`；`popup_factory.gd`、`global.gd` |
| `Scene/show_text/combo_num.gd` | `Script/hittext/combo_num.gd` | `combo_num.tscn`；`popup_factory.gd`、`global.gd` |
| `Scene/show_text/liji.gd` | `Script/hittext/liji.gd` | `liji.tscn`；`popup_factory.gd`、`global.gd` |
| `Scene/show_text/message_info.gd` | `Script/hittext/message_info.gd` | `message_info.tscn`；`show_text_factory.gd` |
| `Scene/show_text/message_show.gd` | `Script/hittext/message_show.gd` | `message_show.tscn`；`popup_factory.gd`、`global.gd` |
| `Scene/show_text/moment_text.gd` | `Script/hittext/moment_text.gd` | `moment_text.tscn`；`popup_factory.gd`、`global.gd` |
| `Scene/show_text/touch_text.gd` | `Script/hittext/touch_text.gd` | `touch_text.tscn`；`popup_factory.gd` |
| `Scene/hero/role_1/hmz_effect/special_effect_bullet.gd` | `Script/hero/special_effect_bullet.gd` | `special_effect_bullet.tscn`、`special_effect_bullet_1.tscn`；`role_1_runtime.tres`、`combat_presentation_factory.gd` |

## 5. 统计

| 批次 | 目标目录 | 文件数 |
|:---|:---|:---:|
| 29-1 | `Script/runtime/` | 4 |
| 29-1 | `Script/archive_interface/` | 1 |
| 29-2 | `Script/main_menu/` | 11 |
| 29-2 | `Script/other_menu/` | 8 |
| 29-2 | `Script/level/` | 4 |
| 29-2 | `Script/skill/` | 8 |
| 29-2 | `Script/monster/` | 10 |
| 29-2 | `Script/data/` | 1 |
| 29-3 | `Script/runtime/` | 1 |
| 29-3 | `Script/hittext/` | 7 |
| 29-3 | `Script/hero/` | 1 |
| **合计** | | **56** |

## 6. 出口与门禁

- 每批迁移后：`Scene/` 下对应 `.gd` 为 0；目标文件与 `.uid` 存在；引用点全部指向新路径。
- 每批验证：`python scripts/check_all.py --skip-engine`、`python scripts/health_check.py --project source --godot-bin <godot>`、相关 `scene_probe_runner`/关卡冒烟。
- 29-4：`scripts/naming_audit.py` 对 `source/Scene/**/*.gd` 报 `ERROR`；清理失效白名单条目；`naming_audit.py --all` 与 `whitelist_audit.py` 通过。
- 最终出口：`Scene/` 下 `.gd` 为 **0**；`docs_audit.py` 0 缺失链接；`check_all`、`health_check`、`scene_probe_runner` 与相关关卡回归通过。

## 7. 关联

- [`../decisions/ADR-031-scene-script-relocation.md`](../decisions/ADR-031-scene-script-relocation.md)
- [`../standards/naming_standard.md`](../standards/naming_standard.md) §1.2、§1.4
- [`architecture.md`](architecture.md) §1
- [`../guides/migration_playbook.md`](../guides/migration_playbook.md)
- [`../../scripts/rename_path.py`](../../scripts/rename_path.py)
