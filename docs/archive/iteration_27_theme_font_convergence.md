# Phase 27 归档：Theme 与字体契约收敛

> **归档日期**：2026-11-06
> **状态**：Archived；27-0 ~ 27-7 全部完成（2026-11-05），Phase 27 已关闭。
> **关联**：当前 Theme 契约见 [`../reference/ui_theme_contract.md`](../reference/ui_theme_contract.md)；字体/变体事实见 [`../reference/theme_font_inventory.md`](../reference/theme_font_inventory.md)；token 标尺见 [`../reference/typography_tokens.md`](../reference/typography_tokens.md)；字体规则见 [`../standards/ui_typography_contract.md`](../standards/ui_typography_contract.md)。
> **职责**：本页保存 Phase 27 的批次、验证、资产决策与回滚边界；当前契约不在此复制。

---

## 1. 阶段边界

**目标**：把 618 个冻结变体从“逐控件复制字体/字号/颜色/StyleBox”收敛为“单一 token 源 + 语义基类 + 少数字体角色”；消除 Theme 与脚本双写、off-token 字号/颜色、未引用字体和静态动态覆盖，同时保持可验收的显示基线。

**前置**：Phase 32 的单一 Theme、P0 字体覆盖修正与 P2-1~P2-11 token 批次已完成。

**非目标**：

- 不重命名 618 个冻结变体；
- 不一次性重做全部 UI；
- 不改布局层级、输入映射、存档格式或动画时序；
- 不删除未确认授权/回滚证据的私有字体；
- 不以目录搬迁或变体数量作为完成标准。

**批次顺序**：27-0 盘点 → 27-1 Token 源 → 27-2 字号 → 27-3 颜色/StyleBox → 27-4 变体层级 → 27-5 字体族 → 27-6 动态覆盖 → 27-7 验收。

---

## 2. 批次记录

### 27-0 现状盘点与守卫

- 盘点基线：618 变体、3,218 属性、54 个子资源、108 个字体颜色值、31 种字号、13 个顶层字体文件（80.8 MB）、385 处动态 `add_theme_*`；
- 新增 `scripts/ui_surface_token_audit.py`：扫描自绘 `StyleBoxFlat` 的 `bg_color`/`border_color`/`shadow_color`，禁止 `Script/main_menu` 出现裸色；
- `theme_token_audit.py` 与 `ui_surface_token_audit.py` 接入 `contract_gate.py`；`ui_surface_token_baseline.json` 冻结迁移期 18 处（`coop_panel_host` 2、`pet_interface` 12、`learn_skill` 4）；
- P2-11 同步完成输入光标/选区与 main_menu 动态样式 token 化；
- 出口：专项审计通过，main_menu 裸色 0；不改显示基线。

### 27-1 Token 单一来源与生成/校验

- 新增 `scripts/ui_theme_tokens.json`：登记 21 个文字 token、5 组表面 token、输入/受管 Theme 值、默认字体与 Theme token 审计集合；
- 新增 `scripts/convert_ui_theme_tokens.py`：`--write` 生成 `UiColorTokens`/`UiSurfaceTokens` 并回写 Theme 受管属性；`--check` 逐字比较；
- 当前受管 Theme 属性 10 项：默认字体、`TowerFloorInput` 光标/选区/占位、`ShopSearchInput` 光标/选区、`ArchiveLoginInput`/`ArchiveNumberInput` 光标/选区；
- `theme_token_audit.py` 的允许字号、描边、颜色与 Button 基类改从 token 源读取；
- 漂移实测：手工把 `TowerFloorInput/colors/caret_color` 改为黑色，`--check` 精确报出文件/行并返回 1；`--write` 恢复后 0 漂移；
- 出口：生成结果与 token 源一致；`--check` 进入 `contract_gate.py`；受管 Theme 属性与脚本常量不再双写。

### 27-2 字号标尺收敛

- 常规标尺：10/12/14/16/18/20/24/28/32/36；40/50/76/100 仅战斗/数字；
- 111 个 off-token 变体按“最近 token、等距取低档”分三批映射：
  - 批次 A（9/13/15/19/21/23）18 个；
  - 批次 B（17/22/25/26）66 个；
  - 批次 C（27/29/30/31/33/35/38）27 个；
- 16 个代表场景 × 1280×800 截图与控件转储：A **0 位移/0 尺寸变化**；B 70 位移/50 尺寸变化，最大位移 12.8 px、最大尺寸变化 10.81 px；C 0 位移/4 尺寸变化，最大宽度变化 34 px；截图未见裁切；
- `theme_token_audit.py` 改为强制所有当前字号在 token 内；手工注入 `BuffIconTime=17` 后审计精确报错并返回 1，恢复后 0 违规；
- `theme_token_baseline.json` 按 618 个变体的新字号签名重建；
- 出口：off-token 字号变体 **111→0**；显式字号 391 个全部落在 14 档标尺内；无新增缺字/裁切。

### 27-3 颜色与 StyleBox 语义收敛

- 79 个 off-token 字体色值（139 处赋值）按语义调色板收敛：新增 `TEXT_CYAN`、`TEXT_PURPLE`、`TEXT_VIOLET`、`OUTLINE_NIGHT`、`OUTLINE_WARM` 等；最终 756 处字体色赋值收敛到 35 个实际值 / 37 个语义 token；
- 8 类字体色属性（`font_color`、`font_outline_color`、`font_shadow_color`、`font_hover_color`、`font_pressed_color`、`font_hover_pressed_color`、`font_disabled_color`、`font_placeholder_color`）全部纳入 `theme_token_audit`；手工注入 `Color(1,0.5,0,1)` 后审计精确报错并返回 1；
- StyleBox 精确重复合并：`constellation_panel`→`sub_StyleBoxFlat_pet_stat`、3 个 `backpack_action_*`→对应 pet page、`backpack_tab_pressed/selected`→对应 unselected/hovered、`sub_7`→`empty_button`；`sub_StyleBoxFlat_6y1b1`/`sub_1` 重命名为 `archive_black_panel`/`shop_search_input_texture`；子资源 **54→47**；
- 跨色族面板/按钮 StyleBox 未强行合并：合并会改变色相、圆角或焦点边框，留到 27-4 评审；
- 出口：off-token 字体色 **139→0**；StyleBox **54→47**；跨色族 ≤36 转入 27-4。

### 27-4 变体层级与共享样式合并

- 保留 **618 个冻结变体名**（`scripts/theme_legacy_variants.json`），新增 **103 个 `Semantic*` 语义基类**；总变体 721，基类链最深 8 层，场景引用未改动；
- 语义基类按原生根类型分树（Label/Button/Container/Input/Panel/List 等）；`theme_token_audit` 改为沿 `base_type` 链解析有效 Theme 项；
- Theme 属性 **3,218→1,719**（≤2,000）；删除 **402** 个与原生默认值相同的冗余属性；
- 精确有效签名合并：**72 个重复组 / 135 个变体**改绑代表变体；合计 **189 个纯别名**；独立变体 429 个，独立变体重复签名组 **3**（≤10）；
- StyleBox 角色合并 **47→36**：`learn_damage_focus/pressed`、`map0_catalog_pressed`、`divine_forge_pressed`、`tower_button_pressed`、`wan_ling_close_pressed`、`sub_StyleBoxFlat_secret_panel`、`wan_ling_section_panel`、`sub_StyleBoxFlat_pet_page_selected`、`auto_battle_button*` 分别并入对应 normal/hover/共享面板；重写 18 处引用；
- `auto_battle_button*` 并入 `tower_button_normal/hover` 后内容边距由 0 变为 6/4 px、按钮底色/描边变化；`auto_battle_config` 截图已对照，文字与按钮无裁切；
- 新增 `scripts/theme_variant_audit.py`：冻结清单、语义基类链、属性上限、StyleBox 上限、独立变体重复签名组全部纳入 `contract_gate.py`；
- 出口：StyleBox **47→36**；Theme 属性 **3,218→1,719**；独立重复签名组 **3**；冻结变体名 618/618；场景引用 0 改动。

### 27-5 字体族与资产收敛

- 建立 4 个运行字体角色 + 1 个 fallback：`body` = FZCuYuan-M03 + 微软雅黑 fallback，`ui` = 华康宋体 W3，`display` = 华康海报 W12，`accent` = 文征明小楷；
- Theme 字体资产 **10→5 个文件**（4 个资源 + FontVariation 的 2 个文件），约 **68.2 MB→44.98 MB**；`font_hy`（55 个有效引用）、`font_meng`（13）、`font_wo`（2）、`font_jin_qiao`（2）并入 `font_main`，`font_194_song_ti`（2）并入 `font_hk`；
- `some_monster_help.gd` 的动态字体路径由 `font_meng` 改为 `font_main`；`ui_theme_tokens.json` 增加 `font_roles`；`font_coverage_audit` 同时检查 Theme 资源数、未引用 Theme 资源与动态样本；
- 动态样本 5 个：公告、Boss 信息、怪物帮助、伤害数字、宠物面板；静态覆盖 **135 场景 / 790 节点 / 0 缺字**，动态样本 **5 / 0 缺字**；
- 物理未引用字体（`font_wo`/`meng`/`hy`/`194`/`jin`、`i_pix`、`jin_qiao_fan_li`、`jin_qiao_jian_cu`、`Font/zmws/ttf/fzy4jw`、`Font/zmws_bmfont`）保留在私有素材工作区，公开仓与 Theme 均无引用；删除/移动需素材所有者确认授权与回滚证据，清单见 `scripts/font_retirement_manifest.json`；
- 出口：Theme 字体资产 **10→5（≤6）**；静态/动态中文覆盖 **0 缺字**；Theme 未引用资源 **0**；私有物理资产保留边界已登记。

### 27-6 动态覆盖收敛

- 脚本 `add_theme_*` 从 **332 降至 299**：删除 18 处默认 body 字体覆盖，15 处主字体覆盖改绑 9 个 `Semantic*` 字体角色变体；
- 62 处字面字体色改用具名 `UiColorTokens`，47 处字面字号改用 `UiFontSizes`（token 源 `script_font_sizes`），18 处动态 StyleBox 字面色改用具名 `UiSurfaceTokens`；
- 新增 `scripts/ui_dynamic_theme_audit.py`：按 static/tokenized/data/layout/dynamic_style 分类；当前 **static 0 / tokenized 139 / data 37 / layout 83 / dynamic_style 40**，总调用 299；基线见 `ui_dynamic_theme_baseline.json`，接入 `contract_gate.py`；
- `hit_text` 的 26 条动画轨道保持已接受例外；`theme_override_audit` 的直接属性仍为 0；
- 出口：字面静态角色覆盖 **0**；数据驱动覆盖全部 token 化或登记为 data/layout/dynamic_style；动态覆盖总计数 **299**，后续不得增长。

### 27-7 阶段验收

- `ui_dynamic_theme_audit` 扫描扩至 `source/**/*.gd`（排除 addons/.godot）并支持跨行调用；动态调用 **299→352**（Scene 53 处），其中 **29 处**字面字号/字体色 token 化，静态 literal **0**；
- 新增 `FONT_SIZE_8`、`TEXT_ZHENFA_PURPLE`、`TEXT_ZHENFA_ORANGE`；`set_menu.tscn` 直接字体引用迁移为 `SetMenuHintLabel`；`theme_override_audit` 强制直接字体与动态调用上限；
- 更新 `theme_font_inventory.md`、`typography_tokens.md`、`ui_theme_contract.md`、`status.md` 与 `roadmap.md`；
- 出口：off-token 字号/颜色为 0；Theme 属性 ≤2,000；重复组 ≤10；字体资产 ≤6；静态动态覆盖 0；0 ERROR / 0 WARNING；显示基线差异均有截图批准记录。

---

## 3. P0/P1 字体资产治理

### P0 字体覆盖修正（2026-11-05）

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

**授权与发布边界**：FZCuYuan-M03 已由项目方确认授权；Microsoft YaHei Semibold 仅作本机 fallback，仍受 Microsoft 自身授权约束。`source/Font/` 不进入公开仓库，字体文件与 `.import` 不提交；发布包分发前需再次确认两款字体的分发许可。

**后续**：字体子集化作为独立打包优化，不在本修正批次的视觉基线内；必须保留 hinting、显式 fallback 并通过同一套截图/控件转储后方可采用。

### P1 字体资源清理（2026-11-05）

- 旧 `1_fonts_fzcy_fz_cu_yuan_m03.ttf`、`1_aaa_fz_cu_yuan_m03_s.ttf`、`1_aaa_fz_cu_yuan_m03_s_ttf.ttf`、`8_fz_cu_yuan_m03_s.ttf` 及对应 `.import` 已确认零运行时引用；
- 复制到本地回滚归档后从 `source/Font/` 移除；回滚归档不进入仓库或发布包；
- 当前只保留 `fz_cu_yuan_m03.ttf` 与 `msyh_semibold.ttc`。

### 27-7 P0/P1 字体治理

- 删除 8 个无运行时引用顶层字体及 `.import`（约 35.84 MB）；
- `font_main`/`font_hk`/`font_return` 建立 FontVariation 回退链；
- `SynHelpBody`、HUD 名称/计时、角色自然属性、幻化操作与 `CureTimesHint` 移出小楷/海报体；
- P1 受影响 **1,031 控件 / 0 位移**；全量 **128/128 + 5 SKIP**（325.4s）。

---

## 4. P2 排版与字体批次

### P2-1 ~ P2-11 token 试点（2026-11-05）

| 批次 | 结果 |
|:---|:---|
| P2-1 字体覆盖 | FZCuYuan 4 个资源收敛为 `fz_cu_yuan_m03.tres`；静态 135 场景 / 790 节点 / 0 缺字 |
| P2-2 字号/描边/颜色 | `game_set`、`back_pack`、`main_menu`、`zd_skill`、`pet_interface`、`read_archive_interface` 收敛；`MenuActionButton`/`EmptyButton`/`SettingsButton`/`LlbtCgmsButton` 等改为继承合并 |
| P2-3 面板批次 | `game_announcement`、`main_backpack`、`ldl`、`shop`、`mystery_shop`；新增 `subtitle=28`；公告 13 位置/17 尺寸、`back_pack` 89 位置（≤0.98 px）、`ldl` 89 位置（≤1.33 px） |
| P2-4 背包/LDL/商店子面板 | 装备数值 15→16、描述 13→14、售价 17→18；道具使用 33/37→32/36；锻造 22/27→24/28；神铸 30→32；选择物品 25→24/19→20 |
| P2-5 法宝/帮助面板 | `magic_weapon_infor` Attr 13→14、SkillTitle 21→20、Action 9→10；`mosaic_help` Title 30→32、Line 17→18；`decompose_help` Title 25→24 |
| P2-6 公告颜色 | 新增 `text_danger`、`text_success`、`text_hint`、`text_gold_warm`；仅 `AnnouncementAlert` #FF574D→#FF4A00 |
| P2-7 商城/装备/锻造颜色 | 新增 `text_orange`、`text_amber`、`text_green`、`text_orange_deep`；`EquipmentStatLabel/Sale` #FF9933→#FF9500；`ForgeSubtitle` #00F900→#00FF00 |
| P2-8 主菜单/HUD/宠物颜色 | 新增 `text_gold_bright`、`text_jade`、`text_jade_dim`、`text_ink_warm`、`text_hover`、`text_placeholder`、`text_gold_pressed`、`icon_hover_soft`、`icon_hover_gold`、`outline_none`、`text_hit_blue` |
| P2-9 主菜单状态/动态菜单 | main_menu 深棕 outline/shadow 统一为 `ink`；新增 `UiColorTokens`；`mount_panel`、`equipment_catalog_page`、`wan_ling_catalog_page`、`zhen_yao_tower`、`game_mode_select`、`choose_player` 脚本文字色迁移 |
| P2-10 表面色 | 新增 `UiSurfaceTokens`；自绘菜单 StyleBox 底色/边框/状态/遮罩收敛；输入光标 `#FFD97A`、选区 `#C09C56 45%` |
| P2-11 输入/动态样式 | `ShopSearchInput` 浅底暖黑光标/25% 选区；`ArchiveLoginInput`/`ArchiveNumberInput` 深底金色光标/45% 选区；main_menu 动态裸色清零 |

### P2 字体角色收敛（2026-11-05 ~ 2026-11-06）

| 批次 | 结果 |
|:---|:---|
| P2 字体族 | `ui` 思源宋体 Medium、`display` 思源宋体 SemiBold、`accent` 霞鹜文楷 Medium；华康宋体/海报/文征明小楷退役；Microsoft YaHei 保留为 body fallback；字体文件 5 / 76.06 MB；18 场景双档 **2,323 控件 / 0 位移** |
| P2.1 角色与资产 | `ui` LXGW WenKai Regular、`display` FZCuYuan M03、`accent` LXGW WenKai Medium、`body` FZCuYuan M03；移除 Source Han Serif；字体资产 4 个资源 / 4 个文件、约 78.49 MB；E1–E4 例外迁移；新增 `font_role_audit.py` 与 `font_role_baseline.json`；全量 **128/128 + 5 SKIP**（372.9s） |
| P2.2 字号语义 | body 24/28/32/36 按功能数字/计时/短标签保留，标题/操作迁 display；ui 28 清零；`font_role_baseline` 43→10；全量 **128/128 + 5 SKIP**（351.7s） |
| P2.3 高级标题 | 五个 36 px 标题与 `LijiText` 50 px 仪式标题迁 display；`font_role_baseline` 10→4；全量 **128/128 + 5 SKIP**（346.4s） |
| P2.4 微辅助 | Buff 倒计时/次数、格位提示与 `Max` 登记为 body 10–11 微辅助；`font_role_baseline` 4→0 |
| P2.5 资源包装 | 四个 FontVariation 包装统一为 `font_body.tres`、`font_ui.tres`、`font_display.tres`、`font_accent.tres`；Theme ExtResource ID、`ui_theme_tokens`、动态样本、退役清单与 token 基线同步；保留资源 UID 与实际 TTF 文件名；`check_all` **9/9**（35.95s）；全量 **128/128 + 5 SKIP**（596.2s） |

### 后续 UI/字体修复（2026-11-06）

- 帮助标题 `HcHelpTitle`、`MosaicHelpTitle`、`MagicHelpTitle`、`LhhjHelpTitle`、`MonsterHelpTitle`、`MonsterHelpTitleLarge`、`ZhenFaHelpTitle` 迁 `display`；
- 技能字体安全子集：`LearnSkillTitle`、`LearnSkillDescriptionButton`、`BdSkillTitle`、`LearnSkillButton`、`LearnSkillLevelValue` 迁 `display`；新增 `SkillHeaderLabel`；全量 **128/128 + 5 SKIP**（565.3s）；
- 字体 P2.6a：`ChooseMusicButton`（`MenuActionButton`，20 号）用于音乐弹窗，列表间距 6→4；`ChangeBackgroundList` 间距 10→8；Theme 属性 1,788、总变体 734；
- 当前角色计数：**734 / display 112 / accent 125 / body 343 / ui 154**；Theme 属性 **1,788** / 重复组 **10**。

---

## 5. 验收指标与最终状态

| 指标 | Phase 27 出口 | 最终状态 |
|:---|---:|---:|
| off-token 字号变体 | 0 | **0**（111→0） |
| off-token 字体色赋值 | 0 | **0**（139→0） |
| Theme 属性总数 | ≤2,000 | **1,788**（3,218→1,719→1,788） |
| StyleBox 子资源 | ≤36 | **36**（54→47→36） |
| 独立重复签名组 | ≤10 | **10** |
| Theme 字体资产 | ≤6 | **4 个文件 / 78.49 MB** |
| 静态字面主题覆盖 | 0 | **0** |
| 动态覆盖 | 字面静态角色 0；token/data/layout/dynamic_style 已登记 | **352 调用 / static 0 / token 173 / data 43 / layout 96 / dynamic_style 40** |
| 字体覆盖 | 0 缺字 | **135 场景 / 788 节点 / 0 缺字；动态样本 5 / 0 缺字** |
| 视觉基线 | 1280×800 / 1600×1000 每批截图 + 控件几何 | **2,323 控件 / 0 位移**（P2 字体批次） |

**门禁**：`check_all` **9/9**；`health_check` **784 脚本 0/0/0**；`theme_override_audit` 直接属性 0 / 动画轨道 26 / 直接字体 0；`theme_token_audit` **734 变体 / 0 违规**；`theme_variant_audit` **618 冻结变体 / 112 语义基类 / 734 总变体 / 属性 1,788 / StyleBox 36 / 独立重复组 10**；`font_role_audit` **734 变体 / 0 错误 / 0 条存量字号例外**；`font_coverage_audit` **135 场景 / 788 节点 / 0 缺字**。

**最终字体角色**：

| 角色 | 字体 |
|:---|:---|
| `body` | FZCuYuan M03（msyh 仅 fallback） |
| `ui` | LXGW WenKai Regular |
| `display` | FZCuYuan M03 |
| `accent` | LXGW WenKai Medium |

**最终边界**：618 个冻结变体名未改；场景引用未改；`hit_text` 26 条动画轨道为唯一最终例外；未引用私有字体保留在素材工作区，公开仓与 Theme 均无引用。

---

## 6. 回滚与实施边界

- Token 源以 `scripts/ui_theme_tokens.json` 为唯一入口；回滚通过版本控制，不保留脚本/Theme 双写。
- 冻结变体名只减不增；新增字号、颜色、字体或 StyleBox 必须先进入 token 源。
- 字体删除/子集化必须保留授权与回滚证据；不得因“未引用”直接删除私有素材。
- 显示基线差异必须有截图与控件几何批准记录；不以“更统一”为由静默改变色相、圆角、间距或字形。
- 审计脚本新增规则后必须同时提供正负样本自测，避免把迁移期基线固化为永久豁免。

---

## 7. 关联文档

- [`../reference/ui_theme_contract.md`](../reference/ui_theme_contract.md)：当前 Theme 资源、变体命名与覆盖边界
- [`../reference/theme_font_inventory.md`](../reference/theme_font_inventory.md)：当前规模、变体结构、字体资产与审计事实
- [`../reference/typography_tokens.md`](../reference/typography_tokens.md)：字号、颜色、描边与 Button 共享族 token
- [`../standards/ui_typography_contract.md`](../standards/ui_typography_contract.md)：字体角色、组件矩阵、字号边界与存量例外
- [`iteration_32_ui_theme.md`](iteration_32_ui_theme.md)：Phase 32 单一 Theme 与变体冻结
- [`../decisions/ADR-026-ui-font-theme-role-contract.md`](../decisions/ADR-026-ui-font-theme-role-contract.md)：字体角色与 Theme 使用边界
- [`../reference/status.md`](../reference/status.md)：当前门禁与验证基线

---

## 附录 A：P2 逐面板映射

| 面板 | 映射 |
|:---|:---|
| `game_set` | `SettingsTitle` 35→36；Section/Button/Value 25/23→24；Control/Compact 21→20；Small 19→18；Return 30/4→32/3；Option 21→20 |
| `back_pack` | 属性行 15→16；Exp/HP outline 5→6；金色统一为 `gold_light` / `gold`；`BackpackWingsButton` 继承 Icon 基类 |
| `main_menu` | PlayerName 30→32；PlayerDetail 17→18；Label 26→24；深金/警告色 token 化 |
| `skill/zd_skill` | Cooldown/Label 25→24；Shadow 15→16；需求文字使用 `text_combat`；行高变化由 ScrollContainer 吸收 |
| `pet/pet_interface` | 13→14、15→16、11→12；金色/信息/弱文字分别映射到 `gold_light`、`info`、`muted`/`secondary` |
| `read_archive_interface` | 17→18、19→20、22→24、25→24、13→14、11→12；金色/弱文字映射到 `gold_deep`、`gold`、`secondary`、`muted` |
| `game_announcement` | Heading 35→36；Subtitle 27→28；Warning/Prompt 17→18；CheckButton 22→20；CheckButtonSmall 21→20；SecretButtonTiny 19→20；Button/Title 保持 28 |
| `game_announcement（颜色）` | Warning→danger；Alert→warning；Status→success；Prompt→hint；Subtitle/Title→gold_warm；仅 Alert 值 #FF574D→#FF4A00 |
| `shop / cure_times_box（颜色）` | ShopMessageText→text_orange；CureTimesHint→text_amber；值保持 `#FF9500` / `#FFC000` |
| `equipment_properies（颜色）` | EquipmentStatLabel/Sale `#FF9933`→text_orange `#FF9500` |
| `ldl/forge（颜色）` | ForgeSubtitle `#00F900`→text_green；ForgeMaterialNeed/StrengthNumber 使用 text_green；DecomposeTitleOrange→text_orange_deep；DecomposeHelpBody `#FFA200`→text_orange |
| `main_menu 子面板（颜色）` | BodyTraining 亮金→text_gold_bright、等级金→text_gold_light、暖黑正文→text_ink_warm；ChoosePlayer 角色/标题→text_gold_deep、信息→text_gold_light；Map0 目录→text_gold；MapReturn→text_orange；SwordPage 等级→text_combat；Tower 全族→text_gold_light；WanLing 标题→text_gold、浅绿→text_jade、空态→text_jade_dim；MainMenuTitle 描边→text_orange_deep |
| `main_menu 子面板（描边/状态）` | BodyTraining/ChoosePlayer/Map0/Tower/WanLing 深棕 outline/shadow→ink；Settings/Announcement/GameInfo 悬停→text_hover；Map0 悬停→text_gold_light、按下→text_gold_pressed_soft；Tower 悬停→text_gold_light、按下→text_primary；TowerFloorInput 占位→text_gold_placeholder |
| `mount_panel（脚本）` | 标题/名称/状态/页签/提示改用 `UiColorTokens`：text_gold、text_gold_light、text_jade、text_hint、text_hint_dim、text_dim、text_info、text_warning_soft |
| `equipment_catalog_page（脚本）` | 羊皮纸正文/次级文字/暖金/浅金/浅绿/提示改用 `UiColorTokens`：text_parchment、text_parchment_muted、text_gold_warm、text_gold_light、text_jade、text_hint |
| `其他 main_menu 脚本` | `wan_ling_catalog_page` 按钮/名称/效果/等级/材料/禁用色；`zhen_yao_tower` 文字/按钮/输入与描边；`game_mode_select` 深棕按钮文字；`choose_player` 星级金色，均改用 `UiColorTokens` |
| `自绘菜单 StyleBox（颜色）` | `mount_panel`/`equipment_catalog_page`/`wan_ling_catalog_page`/`zhen_yao_tower` 的底色、边框、状态、遮罩改用 `UiSurfaceTokens` 冷色/大地/暖棕/危险/绿色组；值保持原有色相 |
| `输入配色` | `zhen_yao_tower` 数量输入与 `equipment_catalog_page` 搜索框使用 `INPUT_CARET #FFD97A`、`INPUT_SELECTION #C09C56 45%`；`ShopSearchInput` 使用 `#331F12`/25%；`ArchiveLoginInput`/`ArchiveNumberInput` 使用 `INPUT_CARET`/`INPUT_SELECTION`；主题 `TowerFloorInput` 同步 |
| `main_menu 动态样式` | `game_mode_select` 遮罩/面板/动作按钮、`map_6/7/8` 高亮、`mount_panel` 锁定预览、`zhu_xian_sword_page` 禁用/材料色接入 `UiSurfaceTokens`/`UiColorTokens`；公告动态文字色由 `TEXT_PRIMARY` 派生 |
| `archive_interface（状态色）` | 按钮悬停 `#FF6A00`→text_hover；输入占位 `#A6A6A6`→text_placeholder；删除按下 `#D38D00`→text_gold_pressed；值不变 |
| `mystery_shop / choose_item / shop_item（状态色）` | 神秘商店图标悬停→icon_hover_soft；商品购买图标悬停→icon_hover_gold；商品灵魂描边→outline_none；ChooseItemList guide→text_primary；BoxItemNumber `#FF7700`→text_orange；BoxLockMark `#FFDB33`→text_amber |
| `战斗 HUD（颜色）` | HitTextBase `#25FF00`→text_green；LijiText `#FF4600`→text_warning；BacisInfoNumber `#FF6000`→text_orange_deep；法术飘字动画 `#0099FF` 登记为 text_hit_blue，动画例外保留 |
| `pet_interface（颜色）` | PetBackpackSlotNumber `#FF7700`→text_orange；PetLevelLabel 浮点重复值收敛为 text_gold_light |
| `main_backpack` | Title 25→24；TabLabelSmall 15→16；LockText 11→12；BoxLockMark 13/4→14/3；TabBar/Large/Page/Coin 保持既有 token |
| `ldl` | Title 19→20；六个 `MenuActionButton` 派生按钮 25→24；内嵌 `main_backpack` 同步 |
| `shop` | Search/TabText 15→16；StatTitle/Hint 25→24；StatTitle outline 8→6；RoleText outline 9→10；Close 25→24；ItemSoulValue 17→18；ItemSoulText outline 7→6 |
| `mystery_shop` | MysteryShopLabel 13→14；Info 16；Title 12；BoxLockMark 共享 14/3 |
| `equipment_properies` | StatValue 15→16；Description 13→14；Sale 17→18；其余 20/16 保持 |
| `use_items` | Title 15→16、outline 7→6；StatName 13→14/6；Up 33→32/6；Down 37→36/6；Min 11→12/6；Max/Key outline 6 |
| `skill_select` | SkillSelectInfo 15→16；Name/Level/NoHave 保持既有 token |
| `pl_sell` | SellPageInput 15→16；筛选色与警告色保持数据语义色 |
| `dj_information` | DjInfoDescription 15→16、outline 5→6；Title/Line 20 |
| `dj_sell` | DjSellNumber outline 9→10；Close 76；Info 12 |
| `forge` | Title color→combat/outline 6；Subtitle 22→24/6；ItemName 27→28/6；Soul 22→24；HelpTitle 35→36/6；HelpLine/MaterialNeed outline 6 |
| `synthesis` | SynthesisTitle color→combat/outline 6；ItemName 18；Cost 16 |
| `strength` | StrengthNumber outline 8→6；ForgeTitle 共享 |
| `mosaic` | 仅共享 DecomposeTitle（32/combat/6） |
| `decompose` | DecomposeTitle 共享；TitleOrange outline 12→10 |
| `divine_forge` | DivineForgeButton 30→32；继承 strength/Forge 变体 |
| `bone_forge` | 无自有变体；继承 divine/strength |
| `choose_item` | ChooseItemTitle 25→24；ChooseItemList 19→20 |
| `cure_times_box` | CureTimesHeader 25→24；Currency 22→24；Section 20 |
| `shop_item` | 已在前批完成；本批逐项对照 **0** 字体重写 |
| `sell_or_equ` | SellOrEquInfo 10、BackpackLockText 12 均已 token；本批无改写 |
| `use_magic_weapon` | UseMagicPage outline 7→6；Title 16、outline 2 |
| `magic_weapon_infor` | Attr 13→14；SkillTitle 21→20；Action outline 9→10；ActionSmall/Alt/CdText/PsTitle outline 8→6；PsSkill outline 4→3 |
| `forge_help` | 前批已完成 36/20/6；本批 **0** 改写 |
| `mosaic_help` | Title 30→32、outline 5→6；Line 17→18 |
| `decompose_help` | Title 25→24；Body 20；Row 共享 |

## 附录 B：P2 对照结果

| 场景 | 位置变化 | 尺寸变化 | 说明 |
|:---|---:|---:|:---|
| `game_set` | 0 | 3 | 标题/按钮随字号变化，无裁切 |
| `back_pack` | 0 | 5 | 属性行高度 +2 px，无裁切 |
| `main_menu` | 3（纵向 <1 px） | 4 | 居中标签随字体度量重排 |
| `skill/zd_skill` | 27（ScrollContainer 内） | 2 | 行高增加，滚动容器高度 +33 px；内容仍可滚动，无裁切 |
| `pet/pet_interface` | 0 | 0 | 仅字体颜色/字号变化 |
| `read_archive_interface` | 0 | 4 | 按钮/标题宽度随字号变化，无裁切 |
| `game_announcement` | 13（标题/隐藏面板，最大 7 px） | 17 | 版本列表保持 28；滚动内容与隐藏功能页不新增越界 |
| `game_announcement（颜色）` | 0 | 0 | 仅 `AnnouncementAlert` #FF574D→#FF4A00；其余颜色值不变 |
| `shop / cure_times_box（颜色）` | 0 | 0 | 值不变，仅建立语义 token |
| `equipment_properies（颜色）` | 0 | 0 | 属性/售价橙色 #FF9933→#FF9500 |
| `ldl/forge（颜色）` | 0 | 0 | 绿色/橙色提示归一；无布局变化 |
| `main_menu 子面板（颜色）` | 0 | 0 | 体能/选择角色/地图/镇妖塔/万灵/诛仙剑页；仅文字颜色变化 |
| `main_menu 子面板（描边/状态）` | 0 | 0 | 描边/阴影统一为 ink；hover/pressed/placeholder 色值收敛 |
| `mount_panel（脚本）` | 0 | 0 | 39 控件；26 处颜色变化，仅字体色 |
| `equipment_catalog_page（脚本）` | 0 | 0 | 61 控件；42 处颜色变化，仅字体色 |
| `其他 main_menu 脚本` | 0 | 0 | `wan_ling` 287、`zhen_yao_tower` 32、`choose_player` 32、`game_mode_select` 7 控件；仅字体/描边色 |
| `自绘菜单 StyleBox（颜色）` | 0 | 0 | 4 个自绘面板；仅替换样式颜色，静态控件转储无布局变化 |
| `输入配色` | 0 | 0 | `ShopSearchInput` 光标 `#331F12`、选区 25%；`Archive*`/`TowerFloorInput` 光标 `#FFD97A`、选区 `#C09C56` 45% |
| `main_menu 动态样式` | 0 | 0 | 模式选择 1 面板/3 按钮；地图 3 处高亮；坐骑预览/诛仙剑状态；公告 9 个动态 Label 使用 `TEXT_PRIMARY` |
| `archive_interface（状态色）` | 0 | 0 | 悬停/占位/按下值登记为 token，无可见变化 |
| `mystery_shop / choose_item / shop_item（状态色）` | 0 | 0 | 图标悬停/guide/透明描边登记；BoxItemNumber/BoxLockMark 橙/黄归一 |
| `战斗 HUD（颜色）` | — | — | HitTextBase、LijiText、BacisInfoNumber 颜色变化；合成 Label 各 1 控件 |
| `pet_interface（颜色）` | 0 | 0 | 槽位数橙色收敛；等级金精度归一 |
| `back_pack` | 89（纵向 ≤0.98 px） | 1 | 标题 25→24 引起整行上移；无可见越界 |
| `ldl` | 89（纵向 ≤1.33 px） | 3 | 标题/内嵌背包行高变化；底部按钮缩小 1 px；无可见越界 |
| `shop` | 4（搜索行最大 3.05 px） | 1 | Tab 字号增加；底部提示标签原有右边界扩展未新增 |
| `mystery_shop` | 0 | 0 | 仅文字字号/描边变化 |
| `equipment_properies` | 18（面板布局，≤17 px） | 23 | 真实背包宿主选择“初月双刀”后 tooltip 正常、无裁切；武器/法宝描述与售价已补齐；直场景无实例时 1025→1043 px 仅作布局参考 |
| `use_items` | 0 | 2 | Up/Down/Min 字号变化，无位移/裁切 |
| `skill_select` | 0 | 0 | Info 字号变化 |
| `pl_sell` | 12（≤1 px） | 3 | 输入框字号 15→16；无新增越界 |
| `dj_information` | 1（2 px） | 2 | 描述字号 15→16；无裁切 |
| `dj_sell` | 0 | 0 | 描边 9→10 |
| `forge` | 0 | 1 | 字号/描边变化，无位移 |
| `synthesis` | 0 | 0 | 标题颜色/描边变化 |
| `strength` | 0 | 0 | 数字描边 8→6 |
| `mosaic` | 0 | 0 | 共享标题变化 |
| `decompose` | 0 | 0 | 标题描边/颜色变化 |
| `divine_forge` | 0 | 0 | 按钮 30→32，固定按钮框吸收 |
| `bone_forge` | 0 | 0 | 无自有变体 |
| `choose_item` | 0 | 0 | 标题 25→24、列表 19→20 |
| `cure_times_box` | 0 | 0 | Header/Currency 字号变化，容器固定 |
| `shop_item` | 0 | 0 | 无字体重写 |
| `sell_or_equ` | 0 | 0 | 全部既有 token，无改写 |
| `use_magic_weapon` | 0 | 0 | 仅 UseMagicPage 描边 7→6 |
| `magic_weapon_infor` | 0 | 1 | 7 个字体/描边变化；直场景无装备数据上下文 |
| `forge_help` | 0 | 0 | 前批已完成 |
| `mosaic_help` | 5（≤5 px） | 7 | Title/Line 增大，无新增可见越界 |
| `decompose_help` | 0 | 0 | Title 25→24 |

截图与控件转储保存在本地临时目录，不进入仓库；批次与结论以本页和 `status.md` 为准。
