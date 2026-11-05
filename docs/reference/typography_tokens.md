# Typography and Control Tokens（P2）

> **状态**：P2-9 颜色批次（2026-11-05）。在 P2-8 基础上补齐 main_menu 深棕描边/阴影、菜单 hover/pressed 与 TowerFloorInput 占位色；新增 `UiColorTokens` 并迁移 `mount_panel`、`equipment_catalog_page` 等脚本动态文字色。其余面板继续使用既有 Theme 值，逐批迁移。
> **边界**：不重命名 618 个冻结 `theme_type_variation`，不改变字体族、布局层级或显示画布。

## 1. Token 标尺

### 字号

| Token | 值 | 用途 |
|:---|---:|:---|
| `caption` | 12 | 小号辅助文字 |
| `action` | 14 | 紧凑按钮 |
| `label` | 16 | 表单/属性标签 |
| `body_small` | 18 | 次级正文 |
| `body` | 20 | 默认正文 |
| `heading` | 24 | 面板分组标题 |
| `subtitle` | 28 | 公告标题/版本列表 |
| `title` | 32 | 面板主标题/返回 |
| `display` | 36 | 特殊主标题 |
| `combat` | 40 / 50 / 76 / 100 | 战斗、伤害与数字保留值 |

试点使用 `12/14/16/18/20/24/28/32/36`；战斗特殊值不在本批收敛范围内。

### 文字颜色

| Token | 值 | 用途 |
|:---|:---|:---|
| `text_primary` | `#FFFFFF` | 主文字 |
| `text_secondary` | `#F0F0F0` | 正文/说明 |
| `text_muted` | `#DFDFDF` | 次级文字 |
| `text_dim` | `#D0D0D0` | 更弱的辅助文字 |
| `text_gold_light` | `#FFF4BF` | 属性数值、亮金 |
| `text_gold` | `#FFD68A` | 提示、背包金色 |
| `text_gold_deep` | `#FFB829` | 存档/主菜单深金 |
| `text_info` | `#63C7FF` | 资源/信息 |
| `text_warning` | `#FF4A00` | 警告 |
| `text_danger` | `#FF0000` | 纯红危险/失败 |
| `text_success` | `#6BE0B3` | 成功/可用状态 |
| `text_hint` | `#D6DBE6` | 密码/辅助提示 |
| `text_gold_warm` | `#F0BA57` | 公告标题暖金 |
| `text_orange` | `#FF9500` | 商城提示/装备属性与售价 |
| `text_amber` | `#FFC000` | 治疗次数提示 |
| `text_green` | `#00FF00` | 锻造/强化材料与数值 |
| `text_orange_deep` | `#F66700` | 分解危险标题、HUD 数字 |
| `text_gold_bright` | `#FFF078` | 体能训练高亮金 |
| `text_jade` | `#C2E6D4` | 万灵分组/属性浅绿 |
| `text_jade_dim` | `#ABB8BA` | 万灵空态弱文字 |
| `text_ink_warm` | `#331F12` | 浅底暖黑正文 |
| `text_hint_dim` | `#9FB1BC` | 深色面板弱提示 |
| `text_parchment` | `#E5DBC9` | 装备图鉴羊皮纸正文 |
| `text_parchment_muted` | `#BBAE91` | 装备图鉴次级文字 |
| `text_warning_soft` | `#EF8E82` | 柔化警告/材料不足 |
| `text_gold_pressed_soft` | `#D9C28C` | 地图目录按下金 |
| `text_gold_placeholder` | `#FFF4BF` 70% | 镇妖塔输入占位 |
| `text_combat` | `#FFFF00` | 战斗冷却/需求 |
| `ink` | `#000000` | 描边/阴影 |

品质色、血量色、奖励状态色继续由脚本与数据拥有，不进入本表。

### 状态与 HUD 预留色

| Token | 值 | 用途 |
|:---|:---|:---|
| `text_hover` | `#FF6A00` | 存档/设置按钮悬停橙 |
| `text_placeholder` | `#A6A6A6` | 输入框占位弱文字 |
| `text_gold_pressed` | `#D38D00` | 存档删除按下金 |
| `text_disabled` | `#8E969B` | 脚本按钮禁用文字 |
| `icon_hover_soft` | `#FFFFFF` 68.2% | 神秘商店图标悬停 |
| `icon_hover_gold` | `#C9CF93` | 商品购买图标悬停 |
| `outline_none` | `transparent` | 无描边 |
| `outline_night` | `#05080D` 80% | 深色面板文字描边 |
| `text_hit_blue` | `#0099FF` | 法术命中飘字动画保留色 |

动画轨道中的 `hit_text` / `hurt_text` 颜色仍按 Phase 32 例外由 `hit_text.tscn` 持有；本表只登记语义名，不把运行时伤害状态迁入 Theme。

### 脚本动态色

`source/Script/base/ui_color_tokens.gd` 提供 `UiColorTokens` 常量，供无法直接引用 Theme 变体的脚本动态 UI 使用。`mount_panel.gd` 与 `equipment_catalog_page.gd` 的文字色已改用该类别名；面板自绘的 StyleBox 底色、边框与阴影仍属面板样式，不进入文字 token。

### 描边

| Token | 值 | 用途 |
|:---|---:|:---|
| `none` | 0 | 无描边 |
| `thin` | 1 | 小字号/常规文字 |
| `regular` | 2 | 标题 |
| `strong` | 3 | 返回/强调按钮 |
| `hud` | 6 | HUD 与属性数值 |
| `combat` | 10 | 战斗飘字保留值 |

## 2. Button 共享族

本批把相同的 Text/Icon 样式收敛到既有基类，保留原变体名，视觉不变。

| Family | Shared base | 继承变体 |
|:---|:---|:---|
| Text / Menu | `MenuActionButton` | `ShopCloseButton`、`LdlDzButton`、`LdlFjButton`、`LdlHcButton`、`LdlQhButton`、`LdlReturnButton`、`LdlXqButton`、`SkillKeySetButton` |
| Text / Settings | `SettingsButton` | `SettingsButtonMedium`、`SettingsButtonBright`；`SettingsButtonTiny` 由 `SettingsButtonCompact` 继承 |
| Text / Llbt | `LlbtCgmsButton` | `LlbtTslzzButton`、`LlbtTznzButton`、`LlbtTztttwButton`、`LlbtTztxsButton`、`LlbtWxmsButton` |
| Icon | `EmptyButton` | `SkillIconButton`、`BackpackHeadButton`、`ZhenFaEmptyButton`、`ZhenYanSlotButton`、`PetBackpackSlotButtonEmpty` |
| Icon / Backpack | `BackpackHeadButton` | `BackpackWingsButton` |
| Action | `BackpackActionButton` | 专用三态 StyleBox |
| Toggle | `BackpackToggleButton` | 字体色表达开关 |
| Option | `SettingsOption` | `OptionButton` 选项控件 |

新增 Button 变体必须继承上述 token 基类，不得直接继承裸 `Button` 并复制一份空 StyleBox。

## 3. 试点映射

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

## 4. 对照结果

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

截图与控件转储：

```text
G:/tmp/p2_pilot_before/
G:/tmp/p2_pilot_after/
G:/tmp/p2b_before/
G:/tmp/p2b_after/
G:/tmp/p2c_before/
G:/tmp/p2c_after/
G:/tmp/p2c_before_1600/
G:/tmp/p2c_after_1600/
G:/tmp/p2d_before/
G:/tmp/p2d_after/
G:/tmp/p2d_before_1600/
G:/tmp/p2d_after_1600/
G:/tmp/p2d_equip_host.png
G:/tmp/p2f_before/
G:/tmp/p2f_after/
G:/tmp/p2f_before_1600/
G:/tmp/p2f_after_1600/
G:/tmp/p2fix_equipment_after.png
G:/tmp/p2color_after/
G:/tmp/p2color_after_1600/
G:/tmp/p2color2_after/
G:/tmp/p2color2_after_1600/
G:/tmp/p2color3_before/
G:/tmp/p2color3_after/
G:/tmp/p2color3_after_1600/
G:/tmp/p2color4_before/
G:/tmp/p2color4_before_dynamic/
G:/tmp/p2color4_after/
G:/tmp/p2color4_after_1600/
```

## 5. 审计

```bash
python scripts/theme_token_audit.py --check
```

- `scripts/theme_token_baseline.json` 冻结 618 个既有变体值；既有变体的合法迁移允许保留基线值。
- 新增变体或既有变体改写值必须使用本表 token；新增 Button 必须继承已登记 token 基类。
- 当前结果：**618 变体 / 0 违规**；P2-8 新增 token 只登记语义，不改变变体数量。
- `theme_override_audit` 保持直接属性 **0**、动画轨道 **26**（`hit_text.tscn` 命中颜色值同步）。

## 6. 既有门禁

- `font_coverage_audit.py --check`：135 场景 / 790 中文节点 / 0 缺字；
- `theme_override_audit.py --check`：直接属性 0，动画轨道 26；
- `check_all --godot-bin`：**9/9 PASS**（31.27s）；
- `scene_probe ui-theme`：PASS（8.09s）；
- `scene_probe ui-factories`：PASS（19.96s，含装备描述/售价、法宝售价、真实法宝信息与使用列表断言）；
- `level_1`：4 阶段冒烟，0 ERROR / 0 WARNING（23.84s）。

其余面板保持旧值，后续按同一流程分批迁移；不一次性重排 110 个颜色。
