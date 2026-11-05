# UI Theme 契约（Phase 32 完成）

> **状态**：Phase 32 已完成（2026-11-02）。静态直接 `theme_override_*` 为 0；旧 Theme 已退役；完整批次与截图记录见 [`../archive/iteration_32_ui_theme.md`](../archive/iteration_32_ui_theme.md)。
> **范围**：`source/Scene/**/*.tscn` 的静态控件样式、Theme 资源、`theme_type_variation` 与审计；不约束运行时业务状态。
> **依据**：[ADR-003](../decisions/ADR-003-modern-godot-design-with-legacy-exceptions.md)、[ADR-005](../decisions/ADR-005-no-compatibility-or-fallback-layers.md)、[ADR-006](../decisions/ADR-006-resource-first-data-and-data-keys.md)、[ADR-016](../decisions/ADR-016-display-canvas-window-and-hud-baseline.md)、[ADR-021](../decisions/ADR-021-project-wide-target-architecture.md)。

## 1. 目标

用共享 `Theme` 承载可复用的字体、字号、颜色、描边、阴影与按钮状态；用 `theme_type_variation` 表达控件角色；不在场景中重复内联值。保持现有视觉、布局、输入与显示基线不变。

Theme 只承载静态 UI 定义。HP/MP、品质色、奖励状态和战斗飘字继续由数据与脚本驱动。

## 2. 资源与所有权

| 项 | 规则 |
|:---|:---|
| 基础 Theme | `source/Scene/theme/bhyh_theme.tres`，唯一正式 Theme |
| 旧 Theme | `backpack_action_theme.tres` 已退役，不再恢复 |
| 全局 Theme | `project.godot` **不设置** `gui/theme/custom`；采用显式节点/场景绑定 |
| 运行时写入 | 不把控件状态写回 Theme；不为实例深复制 Theme |
| Autoload | 不新增 Theme Manager、Autoload 或服务定位器 |
| 局部主题 | 继承链必须可追踪；新增局部覆盖需登记理由 |

## 3. 命名与变体

- Theme 文件使用 `snake_case`：`bhyh_theme.tres`。
- `theme_type_variation` 使用 `PascalCase` 角色名；禁止路径、中文、空格与下划线分隔。
- 变体按角色命名，不按具体面板命名；同一角色跨面板复用。
- 变体必须登记在 `bhyh_theme.tres`；未定义变体、缺失类型或 Theme 加载失败均应在审计/加载阶段失败，不回退到内联样式。
- 32-4 冻结的完整变体名单与字体映射见归档页；新增/重命名变体必须评审。
- P2 排版 token 试点见 [`typography_tokens.md`](typography_tokens.md)；当前仅覆盖 `game_set` 与 `back_pack`，其余面板逐批迁移。

## 4. 静态、动画与动态覆盖

| 类别 | 处置 |
|:---|:---|
| 直接 `theme_override_*` 属性 | 必须为 **0**；由 Theme 基础类型或变体替代 |
| Animation 轨道 `theme_override_*` 路径 | 保留 `hit_text.tscn` 的 **26 条**最终例外 |
| 脚本 `add_theme_*` | 保留为数据/状态驱动；当前 384 处、41 文件，不计入静态迁移 |
| 一次性布局/特效覆盖 | 登记场景例外；不得复制成新的通用样式 |

## 5. 审计与基线

```bash
python scripts/theme_override_audit.py --check
python scripts/font_coverage_audit.py --check
```

基线：`scripts/theme_override_baseline.json`。基线是上限，不是迁移目标；直接属性或动画引用增加必须显式评审并更新基线，不能静默增长。

当前结果：直接属性 **0**；动画轨道 **26**（仅 `hit_text`）；静态变体缺失 **0**；旧 Theme 资源引用 **0**。字体覆盖审计：135 个显式绑定 Theme 的场景 / 790 个中文文本节点 / **0 缺字**。

## 6. 边界

- 不做主题切换、换肤、布局重排、动画时序修改或显示基线调整。Phase 32 未替换字体族；2026-11-05 P0 字体覆盖修正仅用同族完整版替换 FZCuYuan 资源并增加 fallback，见 §7。
- 不把运行时品质色、血量色、奖励状态色迁入 Theme。
- 不为兼容旧场景保留第二套 Theme；迁移完成即删除旧入口。
- 完整批次、截图、控件转储与历史计数见 [`../archive/iteration_32_ui_theme.md`](../archive/iteration_32_ui_theme.md)。

## 7. P0 字体覆盖修正（2026-11-05）

**范围**：只修字体覆盖与字体回退，不改配色、字号、描边、间距、布局或变体命名。

| 项 | 结果 |
|:---|:---|
| FZCuYuan 资源 | `font_fzcy` 与 3 个 `M03S` 子集收敛为 `font_fz_cu_yuan_m03` |
| 字体资源 | `source/Scene/theme/fz_cu_yuan_m03.tres`（FontVariation） |
| 主字体 | `source/Font/fz_cu_yuan_m03.ttf`（FZCuYuan-M03，Version 5.32） |
| 显式回退 | `source/Font/msyh_semibold.ttc`（Microsoft YaHei Semibold，本机 fallback） |
| Theme 默认字体 | `default_font = font_fz_cu_yuan_m03`，覆盖无显式字体的中文文本 |
| 变体 | 618 个类型保持不变；无新增/重命名变体 |
| 直接引用 | `hit_text.tscn`、`coop_panel_host.gd`、`game_mode_select.gd`、`pet_interface.gd` 同步改为新字体资源 |
| 静态覆盖 | **135 个场景 / 790 个中文文本节点 / 0 缺字** |
| 截图/转储 | 4 个代表场景 × 1280×800 / 1600×1000；无横向位移；字体度量导致的 Label 高度 +1~+3 px，居中标签纵向 <1 px，未见裁切 |

**授权与发布边界**：FZCuYuan-M03 已由项目方确认授权；Microsoft YaHei Semibold 仅作为本机 fallback，仍受 Microsoft 自身授权约束。`source/Font/` 不进入公开仓库，字体文件与 `.import` 不提交；发布包分发前需再次确认两款字体的分发许可。

**后续**：字体子集化作为独立打包优化，不在本修正批次的视觉基线内；必须保留 hinting、显式 fallback 并通过同一套截图/控件转储后方可采用。

**P1 资源清理（2026-11-05）**：旧 `1_fonts_fzcy_fz_cu_yuan_m03.ttf`、`1_aaa_fz_cu_yuan_m03_s.ttf`、`1_aaa_fz_cu_yuan_m03_s_ttf.ttf`、`8_fz_cu_yuan_m03_s.ttf` 及对应 `.import` 已确认零运行时引用，复制到本地回滚归档后从 `source/Font/` 移除；回滚归档不进入仓库或发布包。当前只保留 `fz_cu_yuan_m03.ttf` 与 `msyh_semibold.ttc`。

## 8. P2 排版 token 试点（2026-11-05）

- 覆盖 `game_set`、`back_pack`、`main_backpack`、`main_menu`、`skill/zd_skill`、`pet/pet_interface`、`archive_interface/read_archive_interface`、`game_announcement`、`ldl`、`shop`、`mystery_shop`，以及 `equipment_properies`、`use_items`、`skill_select`、`pl_sell`、`dj_information`、`dj_sell`、`forge`、`synthesis`、`strength`、`mosaic`、`decompose`、`divine_forge`、`bone_forge`、`choose_item`、`cure_times_box`、`shop_item`、`sell_or_equ`、`use_magic_weapon`、`magic_weapon_infor`、`forge_help`、`mosaic_help`、`decompose_help`；字号、描边、文字颜色与 Button 族按 [`typography_tokens.md`](typography_tokens.md) 收敛。
- 不重命名 618 个冻结变体；重复 Text/Icon 按钮改为继承 `MenuActionButton`、`EmptyButton`、`SettingsButton`、`SettingsButtonTiny`、`LlbtCgmsButton` 等共享基类，视觉不变。
- P2-3 新增：公告版本列表 28、Heading 36；背包标题 24、小 Tab 16、BoxLockMark 14/3；`ldl` 按钮 24；商店 Tab/Search 16、Stat/Hint 24、SoulValue 18；神秘商店标签 14。
- P2-4 新增：装备数值 16/描述 14/售价 18；道具使用 32/36、13/14、15/16；锻造 24/28、标题 36；神铸 32；选择物品 24/20；治疗次数 24/24；`shop_item` 本批无字体重写。
- P2-5 新增：`magic_weapon_infor` Attr 14/SkillTitle 20/描边 10 或 6/3；`use_magic_weapon` Page outline 6；`mosaic_help` Title 32/6、Line 18；`decompose_help` Title 24；`sell_or_equ` 与 `forge_help` 已为 token，无改写。装备 tooltip 的武器/法宝描述与售价空值已在独立修复中补齐。
- P2-6 颜色批次：新增 `text_danger`、`text_success`、`text_hint`、`text_gold_warm`，公告 Warning/Alert/Status/Prompt/Subtitle/Title 分别收敛；仅 Alert 色值变化，控件 0/0。
- P2-7 颜色批次：新增 `text_orange`、`text_amber`、`text_green`、`text_orange_deep`；商城提示、治疗提示、装备属性/售价、锻造绿色与分解橙色收敛；1280×800/1600×1000 截图与控件转储 0 位置/0 尺寸。
- P2-8 颜色批次：新增 `text_gold_bright`、`text_jade`、`text_jade_dim`、`text_ink_warm` 与状态/HUD token；主菜单子面板、存档状态色、shop 三场景次要状态色（含商品盒数量/锁标）、命中/暴击 HUD、宠物槽位橙色收敛；1280×800 面板控件 0 位置/0 尺寸（HUD 合成 Label 除外），1600×1000 截图归档。
- P2-9 颜色批次：main_menu 深棕 outline/shadow 收敛为 `ink`，菜单 hover/pressed 与 TowerFloorInput 占位色 token 化；新增 `UiColorTokens`（`source/Script/base/ui_color_tokens.gd`），`mount_panel`/`equipment_catalog_page`/`wan_ling_catalog_page`/`zhen_yao_tower`/`game_mode_select`/`choose_player` 脚本文字色迁移；动态菜单 1280×800 控件 0 位置/0 尺寸。
- P2-10 表面色批次：新增 `UiSurfaceTokens`（`source/Script/base/ui_surface_tokens.gd`），`mount_panel`/`equipment_catalog_page`/`wan_ling_catalog_page`/`zhen_yao_tower` 的 StyleBox 底色、边框、状态、遮罩收敛；`TowerFloorInput` 与搜索框统一光标/选区色；1280×800 控件 0 位置/0 尺寸。
- P2-11 输入与动态样式批次：`ShopSearchInput` 使用浅底暖黑光标/25% 选区，`ArchiveLoginInput`/`ArchiveNumberInput` 使用深底金色光标/45% 选区；`game_mode_select` 遮罩/面板/按钮、地图高亮、坐骑锁定预览、诛仙剑禁用态与材料需求色全部接入 `UiSurfaceTokens`/`UiColorTokens`；公告动态文字色改由 `UiColorTokens.TEXT_PRIMARY` 派生。新增 `ui_surface_token_audit.py`，main_menu 裸色 0，StyleBox 迁移期基线 18 处。
- 控件转储：`game_set` 3、`back_pack` 5、`main_menu` 4、`archive` 4 个尺寸变化；`zd_skill` ScrollContainer 内 27 个位置随行高变化；P2-3 公告 13 位置/17 尺寸、`back_pack` 89 位置（≤0.98 px）、`ldl` 89 位置（≤1.33 px）、`shop` 4 位置/1 尺寸、`mystery_shop` 0；P2-4 装备面板 18 位置/23 尺寸（直场景无实例时 1025→1043 px；真实背包宿主选择“初月双刀”后 tooltip 正常、无裁切，武器/法宝描述与售价已由后续修复提交补齐），其余 15 个子面板 0 位置或 ≤12 位置（≤1 px）；P2-5 `sell_or_equ`/`use_magic_weapon`/`forge_help`/`decompose_help` 0/0，`magic_weapon_infor` 0/1，`mosaic_help` 5（≤5 px）/7；P2-6 公告颜色 0/0；P2-7 商城/装备/锻造颜色 0/0；P2-8 主菜单子面板/商店/宠物颜色 0/0；P2-9 主菜单描边/状态 0/0，动态菜单 39/61/287/32/32/7 控件 0/0；P2-10 自绘菜单表面色 0/0，`TowerFloorInput` 光标/选区已转储；P2-11 输入/动态样式颜色值分别转储 `331f1240`、`ffd97aff`、`c09c5673`。
- `theme_token_audit.py --check` 冻结 618 个既有变体，新增/改写值必须使用 token；当前 **0 违规**。
- `ui_surface_token_audit.py --check` 扫描自绘 StyleBox 与 main_menu 裸色；当前 **0 新增**。
- 其余面板继续保持既有 Theme 值，后续按 token 表分批迁移。Phase 27 的现状盘点、字号/颜色/字体资产收敛路线见 [`theme_font_inventory.md`](theme_font_inventory.md)。
