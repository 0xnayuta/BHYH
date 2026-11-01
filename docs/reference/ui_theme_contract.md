# UI Theme 契约（Phase 32-0 基线，32-1/32-2A/32-2B/32-3A/32-3B/32-3C/32-3D/32-3E/32-3F/32-3G-1/32-3G-2/32-3G-3 完成）

> **状态**：32-0 基线审计、32-1 `game_set`、32-2A 标签密集、32-2B Button 密集、32-3A 混合控件、32-3B 标签/混合面板、32-3C 首批标签、32-3D 标签/混合面板、32-3E 阵法/帮助面板与 32-3F 自动战斗/幻化/法宝/阵眼面板、32-3G-1 首批高密度面板、32-3G-2 低密度八场景与 32-3G-3 中高密度八场景批次已完成（2026-11-01）；32-3G-4 未启动。契约按已验收批次维护。
> **适用范围**：`source/Scene/**/*.tscn` 的静态控件样式、Theme 资源、`theme_type_variation` 与相关验证；不约束运行时业务状态。
> **依据**：[ADR-004](../decisions/ADR-004-naming-contract-and-frozen-whitelist.md)、[ADR-005](../decisions/ADR-005-no-compatibility-or-fallback-layers.md)、[ADR-006](../decisions/ADR-006-resource-first-data-and-data-keys.md)、[ADR-012](../decisions/ADR-012-zero-error-zero-warning-quality-gates.md)、[ADR-015](../decisions/ADR-015-documentation-layering-and-single-source-of-truth.md)、[ADR-016](../decisions/ADR-016-display-canvas-window-and-hud-baseline.md)、[ADR-021](../decisions/ADR-021-project-wide-target-architecture.md)。
> **规范**：[`godot_design_standard.md`](../standards/godot_design_standard.md)、[`naming_standard.md`](../standards/naming_standard.md)、[`naming_whitelist.md`](../standards/naming_whitelist.md)、[`target_architecture_contract.md`](../standards/target_architecture_contract.md) §6。

## 1. 问题与目标

当前 UI 样式主要写在场景节点的 `theme_override_*` 属性中，同一个按钮/标题/正文样式在多个面板复制。Phase 32 的目标是：

1. 用共享 `Theme` 资源承载可复用的字体、字号、颜色、描边、阴影与按钮状态样式；
2. 用 `theme_type_variation` 表达控件角色，而不是在每个场景重复内联值；
3. 在迁移前建立可复核基线，迁移中禁止样式计数增加，迁移后保留明确例外；
4. 保持现有视觉、布局、输入与显示基线不变。

Theme 只承载**静态 UI 定义**。HP/MP、品质色、奖励状态、战斗飘字等运行时状态继续由数据与脚本驱动。

## 2. 基线（2026-11-01）

由 `python scripts/theme_override_audit.py --json` 生成；机器基线为 `scripts/theme_override_baseline.json`。

| 项 | 32-0 基线 | 32-1 后 | 32-2A 后 | 32-2B 后 | 32-3A 后 | 32-3B 后 | 32-3C 后 | 32-3D 后 | 32-3E 后 | 32-3F 后 | 32-3G-1 后 | 32-3G-2 后 | 32-3G-3 后 | 说明 |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---|
| 文本 `theme_override_*` 引用 | 6,830 | 6,591 | 6,352 | 4,747 | 4,123 | 3,081 | 2,629 | 2,254 | 2,009 | 1,786 | 1,550 | 1,343 | **1,014** | 135 → 81 个 `.tscn` |
| 直接属性覆盖 | 6,804 | 6,565 | 6,326 | 4,721 | 4,097 | 3,055 | 2,603 | 2,228 | 1,983 | 1,760 | 1,524 | 1,317 | **988** | Phase 32 静态迁移对象 |
| Animation 轨道路径引用 | 26 | 26 | 26 | 26 | 26 | 26 | 26 | 26 | 26 | 26 | 26 | 26 | 26 | 仅 `hit_text.tscn`；动态例外 |
| 直接属性分类 | colors 1,730 / styles 1,625 / constants 1,393 / fonts 1,055 / font_sizes 1,001 | colors 1,703 / styles 1,516 / constants 1,371 / fonts 1,014 / font_sizes 961 | colors 1,619 / styles 1,516 / constants 1,312 / fonts 966 / font_sizes 913 | colors 1,366 / styles 702 / constants 1,208 / fonts 749 / font_sizes 696 | colors 1,189 / styles 556 / constants 1,100 / fonts 634 / font_sizes 618 | colors 924 / styles 419 / constants 786 / fonts 484 / font_sizes 442 | colors 776 / styles 383 / constants 673 / fonts 407 / font_sizes 364 | colors 671 / styles 298 / constants 612 / fonts 345 / font_sizes 302 | colors 592 / styles 283 / constants 520 / fonts 312 / font_sizes 276 | colors 519 / styles 269 / constants 456 / fonts 270 / font_sizes 246 | colors 447 / styles 234 / constants 376 / fonts 238 / font_sizes 229 | colors 399 / styles 177 / constants 331 / fonts 210 / font_sizes 200 | **colors 298 / styles 113 / constants 276 / fonts 154 / font_sizes 147** | 合计 6,804 → 6,565 → 6,326 → 4,721 → 4,097 → 3,055 → 2,603 → 2,228 → 1,983 → 1,760 → 1,524 → 1,317 |
| Label / Button 直接覆盖 | 3,921 / 2,380 | 3,865 / 2,205 | 3,647 / 2,193 | 3,350 / 895 | 3,100 / 745 | 2,272 / 590 | 2,059 / 554 | 1,625 / 424 | 1,402 / 409 | 1,231 / 392 | 1,041 / 348 | 934 / 283 | **736 / 174** | 迁移批次后下降 |
| `FontFile` 场景引用 | 207 | 205 | 205 | 200 | 186 | 173 | 166 | 155 | 146 | 134 | 126 | 113 | **102** | 11 个场景字体文件；迁移批次删除未引用场景字体 |
| Theme `.tres` | 1 / 2 引用 | 2 / 4 引用 | 2 / 6 引用 | 2 / 96 引用 | 2 / 199 引用 | 2 / 447 引用 | 2 / 543 引用 | 2 / 620 引用 | 2 / 663 引用 | 2 / 729 引用 | 2 / 767 引用 | 2 / 820 引用 | **2 / 898 引用** | 新增 `bhyh_theme.tres`；旧 `backpack_action_theme.tres` 仍保留 |
| `theme_type_variation` | 0 | 19 个直接类型 / 45 个节点引用 | 34 个直接类型 / 99 个节点引用 | 72 个直接类型 / 359 个节点引用 | 146 个直接类型 / 498 个节点引用 | 226 个直接类型 / 746 个节点引用 | 241 个直接类型 / 842 个节点引用 | 288 个直接类型 / 919 个节点引用 | 313 个直接类型 / 962 个节点引用 | 356 个直接类型 / 1028 个节点引用 | 372 个直接类型 / 1066 个节点引用 | 411 个直接类型 / 1119 个节点引用 | **460 个直接类型 / 1197 个节点引用** | Theme 共 462 个类型定义；另 2 个仅作基类 |
| 脚本 `add_theme_*` | 383 处 / 39 个文件 | 383 处 / 39 个文件 | 383 处 / 39 个文件 | 383 处 / 39 个文件 | 383 处 / 39 个文件 | 383 处 / 39 个文件 | 383 处 / 39 个文件 | 383 处 / 39 个文件 | 383 处 / 39 个文件 | 383 处 / 39 个文件 | 383 处 / 39 个文件 | 383 处 / 39 个文件 | 383 处 / 39 个文件 | 数据/状态驱动，不计入静态迁移 |

基线是**上限**，不是迁移目标。迁移只能使直接属性与动画引用下降，不能因新增面板或重构静默增加；新增场景需要显式更新基线并说明原因。

## 3. 数据与所有权

### 3.1 Theme 资源

- 基础资源：`source/Scene/theme/bhyh_theme.tres`（`snake_case` 文件；32-1 已创建）。
- 现有 `source/Scene/back_pack/backpack_action_theme.tres` 保留 2 个场景引用；32-1 未合并它。32-4 再决定迁移/退役，最终只保留一个正式 Theme 来源，避免两套长期主题。
- `Theme` 是共享静态 `Resource`，由场景/Control 引用；不得在运行时把控件状态写回 Theme，也不得为每个实例深复制 Theme。
- 不新增 Autoload、全局 Theme Manager 或服务定位器。主题的创建、加载和验证属于构建/资源层；UI 节点只消费资源。

### 3.2 场景应用边界

- 场景根为 `Node2D` / `CanvasLayer` 时，Theme 必须挂在可承载主题的 `Control` 子树；不得把根类型改成 `Control` 以迁就 Theme。
- 同一面板有多个 Control 根时（如 `game_set` 的 `Bg/BGColor` 与 `Bg/Return`），可分别引用同一 Theme；不强制为迁移重排节点树。
- 在 32-4 收口前，**不设置** `project.godot` 的 `gui/theme/custom` 作为全局主题。全局应用必须在所有面板迁移或登记例外后单独评审。
- 场景局部 Theme 的继承链必须可追踪；禁止深层场景用第二个 Theme 覆盖祖先变量而不登记理由。

### 3.3 静态与动态覆盖

| 类别 | 处置 |
|:---|:---|
| 直接 `theme_override_*` 属性 | 由 Theme 基础类型或 `theme_type_variation` 替代；迁移后删除 |
| Animation 轨道中的 `theme_override_*` 路径 | 不在 32-2 静态迁移中强行删除；`hit_text.tscn` 等动态表现保留并登记 |
| 脚本 `add_theme_*`（品质色、血量、状态色） | 保留为数据/状态驱动；不得为减少计数写死进 Theme |
| 一次性布局/特殊效果覆盖 | 登记为场景例外；不允许成为新通用样式的复制来源 |

## 4. 命名契约

### 4.1 文件与资源

- Theme 文件使用 `snake_case`：`bhyh_theme.tres`。
- `class_name` 仅在需要自定义 Theme 子类时使用 `PascalCase`；本项目优先使用原生 `Theme`，除非有可验证的额外职责。
- 不新增顶层目录；主题资源放在 `Scene/theme/` 功能子目录下。

### 4.2 `theme_type_variation`

`theme_type_variation` 的值使用 `PascalCase` 角色名，不使用文件路径、中文、空格或下划线分隔。32-1/32-2A/32-2B/32-3A/32-3B/32-3C/32-3D/32-3E 已冻结：

| 变体 | 基类 | 角色/参数 |
|:---|:---|:---|
| `SettingsTitle` | `Label` | 面板标题，35 / outline 2 |
| `SettingsSection` | `Label` | 分组标题，25 / outline 1 |
| `SettingsValue` | `Label` | 数值/状态，23 / outline 1 |
| `SettingsOptionLabel` | `Label` | 选项标签，22 / outline 1 |
| `SettingsControlLabel` | `Label` | 控制标签，21 / outline 1 |
| `SettingsCompactLabel` | `Label` | 紧凑标签，20 / outline 1 |
| `SettingsSmallLabel` | `Label` | 小标签，19 / outline 1 |
| `SettingsPlainLabel` | `Label` | 无字号覆盖的正文，16 / outline 1 |
| `SettingsButton` | `Button` | 默认设置按钮，25 / 空 StyleBox |
| `SettingsButtonSmall` | `Button` | 18 基类（由 SmallBright 继承） |
| `SettingsButtonTiny` | `Button` | 20 基类（由 TinyBright 继承） |
| `SettingsButtonCompact` | `Button` | 21 |
| `SettingsButtonMedium` | `Button` | 22 |
| `SettingsReturnButton` | `Button` | 返回按钮，字体族 5 / 30 / outline 4 |
| `SettingsButtonBright` | `SettingsButton` | 白色文字，25 |
| `SettingsButtonSmallBright` | `SettingsButtonSmall` | 白色文字，18 |
| `SettingsButtonTinyBright` | `SettingsButtonTiny` | 白色文字，20 |
| `SettingsOption` | `OptionButton` | 帧率选项，字体 3 / 21 |
| `SettingsSlider` | `HSlider` | 白色轨道 + 红色高亮 |
| `SettingsGroup` | `VBoxContainer` | separation 7 |
| `SettingsGroupSpacious` | `VBoxContainer` | separation 13 |
| `EquipmentPanelPadding` | `MarginContainer` | 四边 10 |
| `EquipmentStatGroup` | `VBoxContainer` | separation 5 |
| `EquipmentInfoGroup` | `VBoxContainer` | separation 16 |
| `EquipmentStatLabel` | `Label` | 字体 `1_fonts_fzcy...` / 16 / 橙色 |
| `EquipmentStatValue` | `Label` | 华康宋体 W3 / 15 / 黄色 + outline 1 |
| `EquipmentItemHighlight` | `Label` | 桃花字体 / 20 / 白色 + outline 1 |
| `EquipmentItemMeta` | `Label` | 桃花字体 / 20 / outline 1 |
| `LevelInfoValue` | `Label` | 文正字体 / 27 / 黄色 + black outline 9 |
| `LevelInfoShadowText` | `Label` | 华康宋体 / 22 / 黄色 shadow 12 |
| `LevelInfoAlertText` | `Label` | 华康宋体 / 22 / 红色 shadow 12 |
| `LevelInfoSuccessText` | `Label` | 华康宋体 / 25 / 绿色 shadow 10 |
| `LevelInfoModeButton` | `Button` | 华康宋体 / 25 / outline 5 |
| `LevelInfoFilterGroup` | `HBoxContainer` | separation 10 |
| `LevelInfoDropGroup` | `HBoxContainer` | separation 7 |
| `LevelInfoModeGroup` | `VBoxContainer` | separation 12 |
| `MenuActionButton` | `Button` | 菜单按钮，华康海报体 / 25 / 空 StyleBox |
| `MenuActionButtonOutline` | `MenuActionButton` | 白色 outline |
| `MenuHintLabel` | `Label` | 菜单提示，文正字体 / 18 / outline 1 |
| `MenuActionButtonGroup` | `VBoxContainer` | separation 20 |
| `TowerButton` | `Button` | 镇妖塔按钮，文正字体 / 18 / 棕色 Flat 三态 |
| `TowerButtonSmall` | `TowerButton` | 字号 16 |
| `TowerLabel` | `Label` | 镇妖塔标签，文正字体 / 20 / outline 2 |
| `TowerSmallLabel` | `TowerLabel` | 字号 17 |
| `TowerRow` | `HBoxContainer` | separation 8 |
| `TowerFloorPicker` | `HBoxContainer` | separation 12 |
| `TowerContent` | `VBoxContainer` | separation 10 |
| `TowerOptions` | `VBoxContainer` | separation 4 |
| `TowerPanel` | `PanelContainer` | 棕色面板 Flat |
| `AnnouncementButton` | `Button` | 公告列表按钮，华康海报体 / 28 / 空 StyleBox |
| `AnnouncementSecretButton` | `Button` | 秘钥按钮，华康宋体 / 20 / 深色 Flat 三态 |
| `AnnouncementSecretButtonSmall` | `AnnouncementSecretButton` | 字号 18 |
| `AnnouncementSecretButtonTiny` | `AnnouncementSecretButton` | 字号 19 |
| `AnnouncementHeading` | `Label` | 公告大标题，竹字美容 / 35 |
| `AnnouncementWarning` | `Label` | 红色阴影警告，华康宋体 / 17 / outline 2 / shadow 6 |
| `AnnouncementStatus` | `Label` | 青绿色状态，华康宋体 / 16 |
| `AnnouncementPrompt` | `Label` | 浅灰提示，华康宋体 / 17 |
| `AnnouncementSubtitle` | `Label` | 金色副标题，竹字美容 / 27 |
| `AnnouncementTitle` | `Label` | 金色标题，竹字美容 / 28 |
| `AnnouncementAlert` | `Label` | 红色错误，华康宋体 / 16 |
| `MonsterHelpButton` | `Button` | 怪物帮助按钮，文正字体 / 24 / 空 StyleBox |
| `MonsterHelpTitle` | `Label` | 桃花字体 / 25 / outline 1 |
| `MonsterHelpTitleLarge` | `MonsterHelpTitle` | 字号 30 |
| `MonsterHelpWarning` | `Label` | 文正字体 / 30 / 橙色 outline 1 |
| `SkillLabel` | `Label` | 技能主标签，文正字体 / 25 / outline 1 |
| `SkillSmallLabel` | `Label` | 技能小标签，文正字体 / 20 / outline 1 |
| `SkillCooldownLabel` | `Label` | 冷却文本，黄色 / 黑色 outline 10 / 25 |
| `SkillNeedLabel` | `Label` | 升级需求，黄色 / 黄色 outline 2 / 文正字体 |
| `SkillShadowLabel` | `Label` | 技能阴影，黑色 shadow 3 / outline 1 / 15 |
| `SkillShadowLabelPlain` | `Label` | 同尺寸但不显式设置 shadow 颜色 |
| `SkillTextButton` | `Button` | 技能文字按钮，文正字体 / 20 / 空 StyleBox |
| `SkillIconButton` | `Button` | 技能图标按钮，空 StyleBox 五态 |
| `SkillIconButtonTexture` | `SkillIconButton` | pressed 使用空 StyleBoxTexture |
| `SkillGridRow` | `HBoxContainer` | separation 25 |

| `TowerFloorInput` | `LineEdit` | 镇妖塔输入 |
| `AnnouncementListGroup` | `VBoxContainer` | 公告面板混合控件/布局 |
| `AnnouncementOverlayPanel` | `PanelContainer` | 公告面板混合控件/布局 |
| `AnnouncementFunctionMargin` | `MarginContainer` | 公告面板混合控件/布局 |
| `AnnouncementFunctionContent` | `VBoxContainer` | 公告面板混合控件/布局 |
| `AnnouncementFunctionColumns` | `HBoxContainer` | 公告面板混合控件/布局 |
| `AnnouncementLeftColumn` | `VBoxContainer` | 公告面板混合控件/布局 |
| `AnnouncementCheckButton` | `CheckButton` | 公告面板混合控件/布局 |
| `AnnouncementCheckButtonSmall` | `CheckButton` | 公告面板混合控件/布局 |
| `AnnouncementOption` | `OptionButton` | 公告面板混合控件/布局 |
| `AnnouncementSecretPanel` | `PanelContainer` | 公告面板混合控件/布局 |
| `AnnouncementPasswordMargin` | `MarginContainer` | 公告面板混合控件/布局 |
| `AnnouncementPasswordContent` | `VBoxContainer` | 公告面板混合控件/布局 |
| `AnnouncementActionRow` | `HBoxContainer` | 公告面板混合控件/布局 |
| `AnnouncementPasswordInput` | `LineEdit` | 公告面板混合控件/布局 |
| `SkillPopupMenu` | `PopupMenu` | 技能面板 PopupMenu |
| `ArchiveReadOnlyLink` | `LineEdit` | 归档接口控件/布局 |
| `ArchiveStepText` | `Label` | 归档接口控件/布局 |
| `ArchiveSectionTitle` | `Label` | 归档接口控件/布局 |
| `ArchiveDialogTitle` | `Label` | 归档接口控件/布局 |
| `ArchivePopupPanel` | `Panel` | 归档接口控件/布局 |
| `ArchiveActionButtonSmall` | `Button` | 归档接口控件/布局 |
| `ArchiveHelpButton` | `Button` | 归档接口控件/布局 |
| `ArchiveMutedButton` | `Button` | 归档接口控件/布局 |
| `ArchiveUidHash` | `LineEdit` | 归档接口控件/布局 |
| `ArchiveFieldTitle` | `Label` | 归档接口控件/布局 |
| `ArchiveUploadButton` | `Button` | 归档接口控件/布局 |
| `ArchiveDialogActionButton` | `Button` | 归档接口控件/布局 |
| `ArchiveLoginInput` | `LineEdit` | 归档接口控件/布局 |
| `ArchiveLoginLabel` | `Label` | 归档接口控件/布局 |
| `ArchiveLoginButton` | `Button` | 归档接口控件/布局 |
| `ArchiveStatusText` | `Label` | 归档接口控件/布局 |
| `ArchivePanelTitle` | `Label` | 归档接口控件/布局 |
| `ArchiveConfirmButton` | `Button` | 归档接口控件/布局 |
| `ArchiveMessageText` | `Label` | 归档接口控件/布局 |
| `ArchiveCdButton` | `Button` | 归档接口控件/布局 |
| `ArchiveNumberInput` | `LineEdit` | 归档接口控件/布局 |
| `ArchiveCloudButton` | `Button` | 归档接口控件/布局 |
| `ArchiveDeleteButton` | `Button` | 归档接口控件/布局 |
| `ShopPageLabel` | `Label` | 商店控件/布局 |
| `ShopSearchRow` | `HBoxContainer` | 商店控件/布局 |
| `ShopSearchInput` | `LineEdit` | 商店控件/布局 |
| `ShopStatTitle` | `Label` | 商店控件/布局 |
| `ShopDamageText` | `Label` | 商店控件/布局 |
| `ShopTabRow` | `HBoxContainer` | 商店控件/布局 |
| `ShopTabText` | `Label` | 商店控件/布局 |
| `ShopTabTextStrong` | `Label` | 商店控件/布局 |
| `ShopRoleText` | `Label` | 商店控件/布局 |
| `ShopCloseButton` | `Button` | 商店控件/布局 |
| `ShopHintLabel` | `Label` | 商店控件/布局 |
| `ShopMessageText` | `Label` | 商店控件/布局 |
| `ShopTitleText` | `Label` | 商店控件/布局 |
| `SellFilterList` | `VBoxContainer` | 出售筛选与输入 |
| `SellFilterCs` | `CheckBox` | 出售筛选与输入 |
| `SellFilterGxms` | `CheckBox` | 出售筛选与输入 |
| `SellFilterHq` | `CheckBox` | 出售筛选与输入 |
| `SellFilterHsh` | `CheckBox` | 出售筛选与输入 |
| `SellFilterJl` | `CheckBox` | 出售筛选与输入 |
| `SellPageInput` | `LineEdit` | 出售筛选与输入 |
| `SellTitle` | `Label` | 出售筛选与输入 |
| `SellFilterPt` | `CheckBox` | 出售筛选与输入 |
| `SellFilterSq` | `CheckBox` | 出售筛选与输入 |
| `SellFilterSs` | `CheckBox` | 出售筛选与输入 |
| `SellWarning` | `Label` | 出售筛选与输入 |
| `SellFilterXl` | `CheckBox` | 出售筛选与输入 |
| `SellFilterYx` | `CheckBox` | 出售筛选与输入 |
| `LhhjActionLabel` | `Label` | 六合/挑战面板标签与输入 |
| `LhhjSectionText` | `Label` | 六合/挑战面板标签与输入 |
| `LhhjBossGrid` | `GridContainer` | 六合/挑战面板标签与输入 |
| `LhhjValueInput` | `LineEdit` | 六合/挑战面板标签与输入 |
| `LhhjHpLabel` | `Label` | 六合/挑战面板标签与输入 |
| `LhhjAltValueInput` | `LineEdit` | 六合/挑战面板标签与输入 |
| `LhhjSelfValueInput` | `LineEdit` | 六合/挑战面板标签与输入 |
| `LhhjTitle` | `Label` | 六合/挑战面板标签与输入 |

| `PelletStageRow` | `HBoxContainer` | 丹药面板标签/布局 |
| `PelletNameColumn` | `VBoxContainer` | 丹药面板标签/布局 |
| `PelletPropertyColumn` | `VBoxContainer` | 丹药面板标签/布局 |
| `PelletStageProperty` | `Label` | 丹药面板标签/布局 |
| `PelletPropertyButtonColumn` | `VBoxContainer` | 丹药面板标签/布局 |
| `PelletStageList` | `VBoxContainer` | 丹药面板标签/布局 |
| `PelletStagePropertyRow` | `HBoxContainer` | 丹药面板标签/布局 |
| `PelletEatLabel` | `Label` | 丹药面板标签/布局 |
| `PelletTitle` | `Label` | 丹药面板标签/布局 |
| `PelletTotalValue` | `Label` | 丹药面板标签/布局 |
| `PelletTotalGrid` | `GridContainer` | 丹药面板标签/布局 |
| `PelletAttValue` | `Label` | 丹药面板标签/布局 |
| `PelletCritValue` | `Label` | 丹药面板标签/布局 |
| `PelletEmpValue` | `Label` | 丹药面板标签/布局 |
| `PelletHpValue` | `Label` | 丹药面板标签/布局 |
| `PelletLuckyValue` | `Label` | 丹药面板标签/布局 |
| `PelletMpValue` | `Label` | 丹药面板标签/布局 |
| `PelletTypeRow` | `HBoxContainer` | 丹药面板标签/布局 |
| `PelletAttTab` | `Label` | 丹药面板标签/布局 |
| `PelletCritTab` | `Label` | 丹药面板标签/布局 |
| `PelletEmpTab` | `Label` | 丹药面板标签/布局 |
| `PelletHpTab` | `Label` | 丹药面板标签/布局 |
| `PelletLuckyTab` | `Label` | 丹药面板标签/布局 |
| `PelletMpTab` | `Label` | 丹药面板标签/布局 |
| `PelletTabLabel` | `Label` | 丹药面板标签/布局 |
| `PelletLineLabel` | `Label` | 丹药面板标签/布局 |
| `PetStatPanel` | `Panel` | 宠物面板控件/布局 |
| `PetStatName` | `Label` | 宠物面板控件/布局 |
| `PetStatValue` | `Label` | 宠物面板控件/布局 |
| `PetLearnButton` | `Button` | 宠物面板控件/布局 |
| `PetBackpackGrid` | `GridContainer` | 宠物面板控件/布局 |
| `PetBackpackSlotButton` | `Button` | 宠物面板控件/布局 |
| `PetFormationList` | `VBoxContainer` | 宠物面板控件/布局 |
| `PetFormationCost` | `Label` | 宠物面板控件/布局 |
| `PetFormationEffect` | `Label` | 宠物面板控件/布局 |
| `PetFormationLevel` | `Label` | 宠物面板控件/布局 |
| `PetFormationName` | `Label` | 宠物面板控件/布局 |
| `PetResourceLabel` | `Label` | 宠物面板控件/布局 |
| `PetSkillList` | `VBoxContainer` | 宠物面板控件/布局 |
| `PetLearnRowPanel` | `PanelContainer` | 宠物面板控件/布局 |
| `PetBookCount` | `Label` | 宠物面板控件/布局 |
| `PetSkillDescription` | `Label` | 宠物面板控件/布局 |
| `PetSkillName` | `Label` | 宠物面板控件/布局 |
| `PetPopupTitle` | `Label` | 宠物面板控件/布局 |
| `PetSkillLevel` | `Label` | 宠物面板控件/布局 |
| `PetSkillMana` | `Label` | 宠物面板控件/布局 |
| `PetSkillNeed` | `Label` | 宠物面板控件/布局 |
| `PetSoulLabel` | `Label` | 宠物面板控件/布局 |
| `PetPageButton` | `Button` | 宠物面板控件/布局 |
| `PetLevelLabel` | `Label` | 宠物面板控件/布局 |
| `PetExpLabel` | `Label` | 宠物面板控件/布局 |
| `PetNameLabel` | `Label` | 宠物面板控件/布局 |
| `GameInfoContentPanel` | `PanelContainer` | 游戏说明面板控件/布局 |
| `GameInfoHeaderRow` | `HBoxContainer` | 游戏说明面板控件/布局 |
| `GameInfoSectionColumn` | `VBoxContainer` | 游戏说明面板控件/布局 |
| `GameInfoSectionTitle` | `Label` | 游戏说明面板控件/布局 |
| `GameInfoBodyText` | `Label` | 游戏说明面板控件/布局 |
| `GameInfoNoticeRow` | `VBoxContainer` | 游戏说明面板控件/布局 |
| `GameInfoTitle` | `Label` | 游戏说明面板控件/布局 |
| `GameInfoGuideButton` | `Button` | 游戏说明面板控件/布局 |
| `GameInfoNoticeButton` | `Button` | 游戏说明面板控件/布局 |
| `GameInfoDetailButton` | `Button` | 游戏说明面板控件/布局 |
| `BackpackNameInput` | `LineEdit` | 背包面板控件/布局 |
| `BackpackTitleLabel` | `Label` | 背包面板控件/布局 |
| `BackpackHeadButton` | `Button` | 背包面板控件/布局 |
| `BackpackWingsButton` | `Button` | 背包面板控件/布局 |
| `BackpackWingLabel` | `Label` | 背包面板控件/布局 |
| `BackpackEquipmentRow` | `HBoxContainer` | 背包面板控件/布局 |
| `BackpackEquipmentColumn` | `VBoxContainer` | 背包面板控件/布局 |
| `BackpackExpLabel` | `Label` | 背包面板控件/布局 |
| `BackpackHpLabel` | `Label` | 背包面板控件/布局 |
| `BackpackHpValue` | `Label` | 背包面板控件/布局 |
| `BackpackMessageLabel` | `Label` | 背包面板控件/布局 |
| `BackpackMpLabel` | `Label` | 背包面板控件/布局 |
| `BackpackToggleButton` | `Button` | 背包面板控件/布局 |
| `BdSkillRow` | `HBoxContainer` | 被动技能面板标签/布局 |
| `BdSkillColumn` | `VBoxContainer` | 被动技能面板标签/布局 |
| `BdSkillTitle` | `Label` | 被动技能面板标签/布局 |
| `BdSkillName` | `Label` | 被动技能面板标签/布局 |
| `BdSkillUpgradeButton` | `Button` | 被动技能面板标签/布局 |

| `BodyTrainingHitButton` | `Button` | 炼体面板标签/按钮 |
| `BodyTrainingLevelLabel` | `Label` | 炼体面板标签/按钮 |
| `BodyTrainingMainLabel` | `Label` | 炼体面板标签/按钮 |
| `SwordPageLevelLabel` | `Label` | 诛仙剑阵页面标签 |
| `SwordPageMaterialLabel` | `Label` | 诛仙剑阵页面标签 |
| `SwordPageStatLabel` | `Label` | 诛仙剑阵页面标签 |
| `MagicHelpBody` | `Label` | 法宝帮助标签 |
| `MagicHelpTitle` | `Label` | 法宝帮助标签 |
| `LhhjHelpList` | `VBoxContainer` | 六合帮助标签/布局 |
| `LhhjHelpBody` | `Label` | 六合帮助标签/布局 |
| `LhhjHelpTitle` | `Label` | 六合帮助标签/布局 |
| `SynHelpTitleRow` | `HBoxContainer` | s_yn 帮助标签/布局 |
| `SynHelpSection` | `VBoxContainer` | s_yn 帮助标签/布局 |
| `SynHelpBody` | `Label` | s_yn 帮助标签/布局 |
| `SynHelpTitle` | `Label` | s_yn 帮助标签/布局 |

| `LetterTitle` | `Label` | 全服信件面板控件 |
| `LetterBody` | `Label` | 全服信件面板控件 |
| `LetterPageButton` | `Button` | 全服信件面板控件 |
| `LetterPageLabel` | `Label` | 全服信件面板控件 |
| `LlbtCureText` | `Label` | 挑战面板按钮/文本 |
| `LlbtTitle` | `Label` | 挑战面板按钮/文本 |
| `LlbtList` | `VBoxContainer` | 挑战面板按钮/文本 |
| `LlbtCgmsButton` | `Button` | 挑战面板按钮/文本 |
| `LlbtTslzzButton` | `Button` | 挑战面板按钮/文本 |
| `LlbtTznzButton` | `Button` | 挑战面板按钮/文本 |
| `LlbtTztttwButton` | `Button` | 挑战面板按钮/文本 |
| `LlbtTztxsButton` | `Button` | 挑战面板按钮/文本 |
| `LlbtWxmsButton` | `Button` | 挑战面板按钮/文本 |
| `EndStatsMoreInfo` | `Label` | 结算统计标签/布局 |
| `EndStatsWarning` | `Label` | 结算统计标签/布局 |
| `EndStatsHeaderRow` | `HBoxContainer` | 结算统计标签/布局 |
| `EndStatsColumn` | `VBoxContainer` | 结算统计标签/布局 |
| `EndStatsCritCount` | `Label` | 结算统计标签/布局 |
| `EndStatsHit` | `Label` | 结算统计标签/布局 |
| `EndStatsHitCount` | `Label` | 结算统计标签/布局 |
| `EndStatsRealHit` | `Label` | 结算统计标签/布局 |
| `EndStatsMagicHit` | `Label` | 结算统计标签/布局 |
| `EndStatsPhysicalHit` | `Label` | 结算统计标签/布局 |
| `EndStatsHurt` | `Label` | 结算统计标签/布局 |
| `EndStatsHurtCount` | `Label` | 结算统计标签/布局 |
| `EndStatsMagicHurt` | `Label` | 结算统计标签/布局 |
| `EndStatsMissCount` | `Label` | 结算统计标签/布局 |
| `EndStatsPhysicalHurt` | `Label` | 结算统计标签/布局 |
| `EndStatsRealHurt` | `Label` | 结算统计标签/布局 |
| `EndStatsCure` | `Label` | 结算统计标签/布局 |
| `LdlTitleLabel` | `Label` | 副本/对话面板按钮/标签 |
| `LdlDzButton` | `Button` | 副本/对话面板按钮/标签 |
| `LdlFjButton` | `Button` | 副本/对话面板按钮/标签 |
| `LdlHcButton` | `Button` | 副本/对话面板按钮/标签 |
| `LdlQhButton` | `Button` | 副本/对话面板按钮/标签 |
| `LdlReturnButton` | `Button` | 副本/对话面板按钮/标签 |
| `LdlXqButton` | `Button` | 副本/对话面板按钮/标签 |
| `RoleLevelLabel` | `Label` | 角色 HUD 标签/技能行 |
| `RoleExpText` | `Label` | 角色 HUD 标签/技能行 |
| `RoleHpText` | `Label` | 角色 HUD 标签/技能行 |
| `RoleNatureHp` | `Label` | 角色 HUD 标签/技能行 |
| `RoleMpText` | `Label` | 角色 HUD 标签/技能行 |
| `RoleNatureMp` | `Label` | 角色 HUD 标签/技能行 |
| `RoleKeyLabel` | `Label` | 角色 HUD 标签/技能行 |
| `RoleSkillRow` | `HBoxContainer` | 角色 HUD 标签/技能行 |
| `RoleSkillRowTight` | `HBoxContainer` | 角色 HUD 标签/技能行 |
| `RolePetSkillRow` | `HBoxContainer` | 角色 HUD 标签/技能行 |

| `ZhenFaCurrentLabel` | `Label` | 阵法当前佩戴标签 |
| `ZhenFaCurrentName` | `Label` | 阵法当前名称 |
| `ZhenFaTabRow` | `HBoxContainer` | 阵法功能页签行 |
| `ZhenFaTabLabel` | `Label` | 阵法功能页签文字 |
| `ZhenFaSourceLabel` | `Label` | 阵法获得方式 |
| `ZhenFaNameLabel` | `Label` | 阵法名称 |
| `ZhenFaEmptyButton` | `Button` | 阵法空样式按钮 |
| `ZhenFaInfoPropGroup` | `VBoxContainer` | 阵法属性组 |
| `ZhenFaInfoPropLabel` | `Label` | 阵法属性条目 |
| `ZhenFaInfoLevelLabel` | `Label` | 阵法等级 |
| `ZhenFaInfoBodyGroup` | `VBoxContainer` | 阵法信息组 |
| `ZhenFaInfoAddProp` | `Label` | 阵法附加属性 |
| `ZhenFaInfoSkill` | `Label` | 阵法技能说明 |
| `ZhenFaTuPoList` | `VBoxContainer` | 阵法突破列表 |
| `ZhenFaTuPoHeader` | `Label` | 阵法突破等级标题 |
| `ZhenFaTuPoProp` | `Label` | 阵法突破属性 |
| `ZhenFaTuPoSkill` | `Label` | 阵法突破技能说明 |
| `ZhenFaTuPoNeed` | `Label` | 阵法突破材料数量 |
| `ZhenFaTuPoNeedNote` | `Label` | 阵法突破灵魂需求 |
| `HcHelpTitle` | `Label` | 合成帮助标题 |
| `HcHelpTabRow` | `HBoxContainer` | 合成帮助页签行 |
| `HcHelpTabLabel` | `Label` | 合成帮助页签文字 |
| `HcHelpColumnRow` | `HBoxContainer` | 合成帮助材料列表头行 |
| `HcHelpColumnLabel` | `Label` | 合成帮助材料列表头 |
| `HcHelpPage` | `Label` | 合成帮助页码 |

| `AutoBattlePanel` | `PanelContainer` | 自动战斗面板背景 |
| `AutoBattleContent` | `VBoxContainer` | 自动战斗内容区 |
| `AutoBattleTitle` | `Label` | 自动战斗标题 |
| `AutoBattleSectionLabel` | `Label` | 自动战斗分区标签 |
| `AutoBattleOptionsGrid` | `GridContainer` | 自动战斗选项网格 |
| `AutoBattleCheck` | `CheckButton` | 自动战斗复选按钮 |
| `AutoBattleOption` | `OptionButton` | 自动战斗角色选择 |
| `AutoBattleSkillRow` | `HBoxContainer` | 技能选择行 |
| `AutoBattleSkillOption` | `OptionButton` | 技能下拉框 |
| `AutoBattleSmallButton` | `Button` | 添加技能按钮 |
| `AutoBattleSelectedList` | `VBoxContainer` | 已选技能列表 |
| `AutoBattleHint` | `Label` | 自动战斗提示 |
| `AutoBattleActions` | `HBoxContainer` | 自动战斗操作行 |
| `AutoBattleActionButton` | `Button` | 自动战斗确定/取消 |
| `TransTabRow` | `HBoxContainer` | 幻化页签行 |
| `TransTabLabel` | `Label` | 幻化页签文字 |
| `TransRoleLabel` | `Label` | 幻化角色标题 |
| `TransCollectValue` | `Label` | 幻化收集进度 |
| `TransSlotLabel` | `Label` | 幻化部位标签 |
| `TransTips` | `Label` | 幻化说明 |
| `TransTipsSmall` | `Label` | 幻化说明小字 |
| `TransPage` | `Label` | 幻化页码 |
| `TransGrid` | `GridContainer` | 幻化物品网格 |
| `MagicWeaponValue` | `Label` | 法宝数值文本 |
| `MagicWeaponEmpty` | `Label` | 法宝空状态 |
| `MagicWeaponStat` | `Label` | 法宝属性值 |
| `MagicWeaponStatHp` | `Label` | 法宝生命值 |
| `MagicWeaponAttr` | `Label` | 法宝五行属性 |
| `MagicWeaponSkillTitle` | `Label` | 法宝技能标题 |
| `MagicWeaponSkillBody` | `Label` | 法宝技能正文 |
| `MagicWeaponPsTitle` | `Label` | 法宝被动标题 |
| `MagicWeaponPsSkill` | `Label` | 法宝被动正文 |
| `MagicWeaponName` | `Label` | 法宝名称 |
| `MagicWeaponAction` | `Label` | 法宝操作按钮文字 |
| `MagicWeaponActionSmall` | `Label` | 法宝操作小字 |
| `MagicWeaponActionAlt` | `Label` | 法宝操作文字（8 描边） |
| `MagicWeaponSkillGroup` | `VBoxContainer` | 法宝技能组 |
| `ZhenYanPropList` | `VBoxContainer` | 阵眼属性列 |
| `ZhenYanLevelInfo` | `Label` | 阵眼等级 |
| `ZhenYanPropInfo` | `Label` | 阵眼属性 |
| `ZhenYanNeedTitle` | `Label` | 阵眼需求标题 |
| `ZhenYanNeedNum` | `Label` | 阵眼需求数量 |
| `ZhenYanNeedNote` | `Label` | 阵眼灵魂需求 |

| `ZhenFaHelpTitle` | `Label` | 阵法帮助标题 |
| `ZhenFaHelpBody` | `Label` | 阵法帮助正文 |
| `Monster139Button` | `Button` | 测试怪物操作按钮 |
| `Monster139DamageLabel` | `Label` | 测试怪物伤害统计 |
| `CureTimesHeader` | `Label` | 兑换次数标题 |
| `CureTimesSection` | `Label` | 兑换次数分区标签 |
| `CureTimesHint` | `Label` | 兑换次数说明 |
| `CureTimesCurrency` | `Label` | 兑换次数操作文字 |
| `CureTimesRow` | `HBoxContainer` | 兑换次数输入行 |
| `DecomposeHelpTitle` | `Label` | 分解帮助标题 |
| `DecomposeHelpBody` | `Label` | 分解帮助正文 |
| `DecomposeHelpRow` | `BoxContainer` | 分解帮助正文行 |
| `SkillSelectName` | `Label` | 技能选择名称 |
| `SkillSelectLevel` | `Label` | 技能选择等级 |
| `SkillSelectInfo` | `Label` | 技能选择说明 |
| `SkillSelectNoHave` | `Label` | 技能选择空状态 |

| `BackpackCompactVBox` | `VBoxContainer` | 背包紧凑列表 |
| `DjSellMargin` | `MarginContainer` | 道具丢弃边距 |
| `DjSellInfo` | `Label` | 道具丢弃说明 |
| `DjSellNumber` | `LineEdit` | 道具丢弃数量 |
| `DjSellCloseButton` | `Button` | 道具丢弃关闭 |
| `SellOrEquInfo` | `Label` | 出售/装备说明 |
| `BackpackLockText` | `Label` | 背包锁定文字 |
| `BackpackInnerMargin` | `MarginContainer` | 背包内边距 |
| `BackpackTitle` | `Label` | 背包标题 |
| `BackpackTabBar` | `TabBar` | 背包页签 |
| `BackpackTabRow` | `HBoxContainer` | 背包页签行 |
| `BackpackTabLabel` | `Label` | 背包页签基础文字 |
| `BackpackTabLabelLarge` | `Label` | 背包页签大文字 |
| `BackpackTabLabelSmall` | `Label` | 背包页签小文字 |
| `BackpackGridMargin` | `MarginContainer` | 背包网格边距 |
| `BackpackGrid` | `GridContainer` | 背包网格 |
| `BackpackPageRow` | `HBoxContainer` | 背包分页行 |
| `BackpackPageLabel` | `Label` | 背包页码 |
| `BackpackCoinLabel` | `Label` | 背包铜钱数 |
| `ShopItemName` | `Label` | 商店物品名称 |
| `ShopItemNumber` | `LineEdit` | 商店购买数量 |
| `ShopItemBuyButton` | `Button` | 商店购买按钮 |
| `ShopItemSoulValue` | `Label` | 商店灵魂数值 |
| `ShopItemSoulText` | `Label` | 商店灵魂说明 |
| `Map3RegionLabel` | `Label` | 天界区域名 |
| `Map3ButtonTitle` | `Label` | 天界按钮标题 |
| `ChoosePlayerTitle` | `Label` | 选角标题 |
| `ChoosePlayerCardRow` | `HBoxContainer` | 选角卡片行 |
| `ChoosePlayerRoleName` | `Label` | 选角角色名 |
| `ChoosePlayerProp` | `Label` | 选角属性 |
| `ChoosePlayerInfo` | `Label` | 选角说明 |
| `Map0PlayerLevel` | `Label` | 主地图等级 |
| `Map0CatalogButton` | `Button` | 主地图图鉴按钮 |
| `ForgeTitle` | `Label` | 锻造标题 |
| `ForgeSubtitle` | `Label` | 锻造副标题 |
| `ForgeMaterialRow` | `HBoxContainer` | 锻造材料行 |
| `ForgeBoxRow` | `HBoxContainer` | 锻造结果行 |
| `ForgeItemName` | `Label` | 锻造物品名称 |
| `ForgeSoulLabel` | `Label` | 锻造灵魂需求 |

规则：

1. 变体名表达**角色**，不按单个场景命名；
2. 不把一个场景的局部样式命名为全局变体；
3. 同一角色在不同字体族下需要保留字体差异时，可拆分为 `TitleLabelSerif` 等明确变体，不得用运行时覆盖临时修正；
4. 32-2A/32-2B/32-3A/32-3B/32-3C/32-3D/32-3E/32-3F/32-3G-1/32-3G-2/32-3G-3 后共有 **462 个类型**（460 个直接使用 + 2 个基类）；新增变体需要在 Phase 32 批次评审中登记，不能静默扩散。

## 5. 字体与样式

- 保留现有 12 个字体族与字形，不把一个默认字体强加给所有控件。
- Theme 变体可以携带精确 `FontFile`、字号、描边、阴影；只有视觉对照一致时才删除场景级 `FontFile` 引用。
- 颜色沿用现有十六进制/`Color` 结果；不因迁移改变颜色空间、透明度或抗锯齿。
- StyleBox 优先按状态族复用（normal/hover/pressed/disabled/focus），不把一次性背景纹理包装成通用变体。
- 字体/主题资源不改变 1280×800 设计画布、1600×1000 默认窗口、16:10、`canvas_items` + `expand` 或 HUD 布局。

## 6. 审计工具与基线守恒

```bash
# 只读摘要
python scripts/theme_override_audit.py

# JSON 报告
python scripts/theme_override_audit.py --json

# 与基线比较；直接属性或动画引用增加时返回 1
python scripts/theme_override_audit.py --check

# 仅在完成一批迁移并审阅后更新上限
python scripts/theme_override_audit.py --write-baseline
```

- 脚本统计直接属性、动画轨道、Theme 资源/引用、`theme_type_variation`、字体引用与脚本动态调用。
- `--check` 按场景比较直接属性与动画引用，并比较总数；新增带覆盖的场景直接失败。
- 基线更新必须与迁移/评审同批提交；不得为了让新覆盖通过而单独放宽基线。
- 动画轨道计数不是静态属性计数；两者不能互抵或混算。

## 7. 32-1 试点结果（已完成，2026-11-01）

试点：`source/Scene/main_menu/game_set.tscn`。

| 项 | 值 |
|:---|:---:|
| 直接属性覆盖 | 239 → **0** |
| 涉及控件 | Button 175、Label 56、HSlider 4、OptionButton 2（按覆盖属性统计） |
| 迁移后变体 | 45 个节点 / 19 个直接类型 |
| 动画轨道 | 0 |
| Theme 应用点 | `Bg/BGColor` 子树 + `Bg/Return` |
| 运行时探针 | `ui-theme` PASS |

验收：

1. **计算样式/几何**：45 个 Control 的字体、字号、描边、颜色、StyleBox 类型、位置、尺寸、`custom_minimum_size`、文本逐项对照，**0 差异**；
2. **截图**：1600×1000 与 1280×800 前后对照，仅字形抗锯齿边缘出现 ±1 通道差异（1600：7,274 / 1,600,000，0.45%；1280：4,937 / 1,024,000，0.48%），无可见布局/颜色变化；
3. **交互**：`ui-theme` 探针的开关状态切换与恢复 PASS；场景加载 0 SCRIPT ERROR；
4. 场景内直接 `theme_override_*` 为 **0**；无未引用 subresource 遗留；
5. `theme_override_audit.py --check` PASS；`contract_gate` PASS；`check_all --skip-engine` 7/7；
6. 后续 32-2 仍按批截图；32-1 通过，不进入回滚分支。

## 7A. 32-2A Label 密集面板结果（已完成，2026-11-01）

| 场景 | 迁移前直接属性 | 迁移后直接属性 | 迁移节点/变体 | 保留例外 |
|:---|:---:|:---:|:---|:---|
| `back_pack/equipment_properies.tscn` | 173 | **18** | 40 节点 / 7 变体 | 4 个一次性标签：`eq_name`、`Title`、`eq_ms`、`eq_sj` |
| `other_scene/level_info.tscn` | 118 | **34** | 14 节点 / 8 变体 | 6 个一次性标签：顶部 `Title`、`Enemy`、`Challenge`、`MyPj`、`Fall`、模式对话框 `Title` |

共同结果：

- 合计直接属性 **6,565 → 6,326**；Theme 场景引用 **6**；类型变体 **36 个定义 / 34 个直接使用 / 99 个节点引用**；
- 两个场景分别覆盖 49 / 38 个 Control 的计算字体、字号、描边、阴影、颜色、StyleBox、位置、尺寸与文本，**0 差异**；
- 1600×1000 与 1280×800 截图前后 **0 像素差异**；
- 保留的一次性标签不使用新变体，避免把单场景局部样式扩散为全局角色；后续批次可再评审；
- `theme_override_audit.py --check`、`contract_gate` 与 `check_all --godot-bin` 9/9（29.33s）通过；`scene_probe_runner --probe ui-theme` 仍覆盖 `game_set`，标签面板采用独立计算转储/截图证据。

## 7B. 32-2B Button 密集面板结果（已完成，2026-11-01）

| 场景 | 迁移前直接属性 | 迁移后直接属性 | 迁移节点/变体 | 保留例外 |
|:---|:---:|:---:|:---|:---|
| `set_menu.tscn` | 136 | **0** | 18 节点 / 4 变体 | 无 |
| `main_menu/zhen_yao_tower.tscn` | 161 | **8** | 26 节点 / 9 变体 | `FloorInput` LineEdit 的 8 处字体/描边/样式覆盖，留待 32-3 |
| `main_menu/game_announcement.tscn` | 507 | **34** | 68 节点 / 11 变体 | 5 个 CheckButton（10）、1 个 LineEdit（2）、1 个 OptionButton（2）与 14 个容器/面板/边距（20）；留待 32-3/32-4 |
| `monster/some_monster_help.tscn` | 502 | **0** | 65 节点 / 4 变体 | 无 |
| `skill/zd_skill.tscn` | 343 | **2** | 83 节点 / 10 变体 | 2 个 PopupMenu 的字体覆盖，留待 32-3 |

共同结果：

- 五个场景合计直接属性 **1,649 → 44**；全局直接属性 **6,326 → 4,721**，文本引用 **4,747**，剩余含覆盖场景 **132**；
- Theme 新增 38 个变体，累计 **74 个定义 / 72 个直接使用 / 359 个节点引用**；Theme 场景引用 **96**；
- 五个场景分别覆盖 24 / 32 / 108 / 79 / 85 个 Control，合计 **328 个 Control** 的字体、字号、描边、阴影、颜色、StyleBox、位置、尺寸与文本，迁移前后 **0 差异**；
- 1600×1000 与 1280×800 各 5 张截图，共 **13,120,000 像素**，**0 像素差异**；
- 五个场景直接启动与 0 ERROR / 0 WARNING；`check_all --godot-bin` 通过；
- `zd_skill` 的控件位于 `Node2D` 容器（`Sk_na`/`sk_pi`/`sk_lv`/`sk_le`/`sk_ms`）下，Theme 继承在 Node2D 边界中断；因此除根 `MarginContainer` 外，对每个带变体的 Control 显式绑定同一 Theme。该重复是当前 Node2D UI 形态的已知边界，32-4 评估全局 Theme 时再收敛；
- `set_menu` 的 16 个空 StyleBox 按钮收敛为 `MenuActionButton` / `MenuActionButtonOutline` 两态；`some_monster_help` 的 61 个按钮收敛为一个 `MonsterHelpButton`；
- 剩余 44 处均是混合控件/布局或 PopupMenu 字体，不以“只改文本”归零；未迁移场景不假装完成。

## 7C. 32-3A 混合控件与布局批次结果（已完成，2026-11-01）

| 场景 | 迁移前直接属性 | 迁移后直接属性 | 迁移节点/变体 | 覆盖控件 |
|:---|:---:|:---:|:---|:---|
| `main_menu/zhen_yao_tower.tscn` | 8 | **0** | 1 节点 / 1 变体 | LineEdit |
| `main_menu/game_announcement.tscn` | 34 | **0** | 21 节点 / 14 变体 | CheckButton、OptionButton、LineEdit、PanelContainer、MarginContainer、VBox/HBox |
| `skill/zd_skill.tscn` | 2 | **0** | 2 节点 / 1 变体 | PopupMenu |
| `archive_interface/read_archive_interface.tscn` | 230 | **0** | 42 节点 / 23 变体 | Button、Label、LineEdit、Panel |
| `shop/shop.tscn` | 94 | **0** | 16 节点 / 13 变体 | Label、LineEdit、Button、HBox |
| `back_pack/pl_sell.tscn` | 107 | **0** | 14 节点 / 14 变体 | CheckBox、Label、LineEdit、VBox |
| `other_scene/lhhj.tscn` | 149 | **0** | 43 节点 / 8 变体 | Label、LineEdit、GridContainer |

共同结果：

- 七个场景合计直接属性 **624 → 0**；全局直接属性 **4,721 → 4,097**，文本引用 **4,123**，剩余含覆盖场景 **125**；
- Theme 新增 **74 个变体**，累计 **148 个定义 / 146 个直接使用 / 498 个节点引用**；Theme 场景引用 **199**；FontFile 场景引用 **186**；
- 七个场景分别覆盖 32 / 108 / 85 / 56 / 29 / 20 / 59 个 Control，合计 **389 个 Control** 的字体、字号、描边、阴影、颜色、StyleBox、位置、尺寸与文本，迁移前后 **0 差异**；
- 1600×1000 与 1280×800 各 7 张截图，共 **18,368,000 像素**，**0 像素差异**；
- 七个场景直接启动 0 ERROR / 0 WARNING；`theme_override_audit.py --check`、`contract_gate` 与 `check_all --godot-bin` 9/9（28.91s）通过；
- `read_archive_interface`、`shop`、`lhhj` 的 `Node2D`/`Sprite2D` 父级会阻断 Theme 继承，已对迁移节点显式绑定同一 Theme；`pl_sell` 使用 Control 根，`zhen_yao_tower`/`game_announcement` 使用既有 Control 根，`zd_skill` 保留 32-2B 的显式绑定；
- 32-2B 登记的 44 处混合/布局/PopupMenu 覆盖已全部关闭；这些场景不再有静态 `theme_override_*`；
- 仍未迁移的混合面板留待 32-3B；不把一次性背景纹理或运行时品质色伪装成全局面板角色。

## 7D. 32-3B 标签与混合面板批次结果（已完成，2026-11-01）

| 场景 | 迁移前直接属性 | 迁移后直接属性 | 迁移节点/变体 | 覆盖控件 |
|:---|:---:|:---:|:---|:---|
| `pellet/basic_pellet.tscn` | 231 | **0** | 45 节点 / 26 变体 | Label、HBox/VBox、GridContainer |
| `pet/pet_interface.tscn` | 430 | **0** | 108 节点 / 26 变体 | Label、Button、Panel、PanelContainer、VBox、GridContainer |
| `main_menu/game_information.tscn` | 157 | **0** | 23 节点 / 10 变体 | Label、Button、PanelContainer、VBox/HBox |
| `back_pack/back_pack.tscn` | 117 | **0** | 32 节点 / 13 变体 | Label、Button、LineEdit、VBox/HBox |
| `skill/bd_skill.tscn` | 107 | **0** | 40 节点 / 5 变体 | Label、Button、VBox/HBox |

共同结果：

- 五个场景合计直接属性 **1,042 → 0**；全局直接属性 **4,097 → 3,055**，文本引用 **3,081**，剩余含覆盖场景 **120**；
- Theme 新增 **80 个变体**，累计 **228 个定义 / 226 个直接使用 / 746 个节点引用**；Theme 场景引用 **447**；FontFile 场景引用 **173**；
- 五个场景分别覆盖 86 / 356 / 46 / 152 / 48 个 Control，合计 **688 个 Control** 的字体、字号、描边、阴影、颜色、StyleBox、位置、尺寸与文本，迁移前后 **0 差异**；
- 1600×1000 与 1280×800 各 5 张截图，共 **13,120,000 像素**，**0 像素差异**；
- 五个场景直接启动 0 ERROR / 0 WARNING；`theme_override_audit.py --check`、`contract_gate` 与 `check_all --godot-bin` 9/9（27.80s）通过；
- 五个场景的 Theme 均绑定到迁移节点；`back_pack` 保留旧的 `backpack_action_theme.tres` 引用与 32-4 退役决策，不重复建立第二套主题；
- 该批不处理尚未迁移的其余 UI 面板；它们进入 32-3C，不以计数接近目标冒充阶段完成。

## 7E. 32-3C 首批标签面板结果（已完成，2026-11-01）

| 场景 | 迁移前直接属性 | 迁移后直接属性 | 迁移节点/变体 | 覆盖控件 |
|:---|:---:|:---:|:---|:---|
| `main_menu/body_training.tscn` | 101 | **0** | 25 节点 / 3 变体 | Button、Label |
| `main_menu/zhu_xian_sword_page.tscn` | 100 | **0** | 20 节点 / 3 变体 | Label |
| `magic_weapon/magic_help.tscn` | 95 | **0** | 11 节点 / 2 变体 | Label |
| `other_scene/lhhj_help.tscn` | 78 | **0** | 10 节点 / 3 变体 | Label、VBox |
| `ldl/s_yn_help.tscn` | 78 | **0** | 30 节点 / 4 变体 | Label、VBox、HBox |

共同结果：

- 五个场景合计直接属性 **452 → 0**；全局直接属性 **3,055 → 2,603**，文本引用 **2,629**，剩余含覆盖场景 **115**；
- Theme 新增 **15 个变体**，累计 **243 个定义 / 241 个直接使用 / 842 个节点引用**；Theme 场景引用 **543**；FontFile 场景引用 **166**；
- 五个场景合计 **179 个 Control** 的字体、字号、描边、阴影、颜色、StyleBox、位置、尺寸与文本迁移前后 **0 差异**；
- 1600×1000 与 1280×800 各 5 张截图，共 **13,120,000 像素**，**0 像素差异**；
- 五个场景直接启动 0 ERROR / 0 WARNING；
- 本批全部节点显式绑定 Theme，避免 `Node2D`/`Sprite2D` 父级阻断继承；
- 其余高覆盖面板留待 32-3D；不以直接属性接近目标冒充阶段完成。

## 7F. 32-3D 标签/混合面板结果（已完成，2026-11-01）

| 场景 | 迁移前直接属性 | 迁移后直接属性 | 迁移节点/变体 | 覆盖控件 |
|:---|:---:|:---:|:---|:---|
| `other_scene/a_letter_for_all_players.tscn` | 82 | **0** | 16 节点 / 4 变体 | Button、Label |
| `level/llbt_challenge.tscn` | 77 | **0** | 12 节点 / 9 变体 | Button、Label、VBox |
| `other_scene/after_level_end.tscn` | 74 | **0** | 19 节点 / 17 变体 | Label、VBox/HBox |
| `ldl/ldl.tscn` | 74 | **0** | 10 节点 / 7 变体 | Button、Label |
| `base/base_role.tscn` | 68 | **0** | 20 节点 / 10 变体 | Label、HBox |

共同结果：

- 五个场景合计直接属性 **375 → 0**；全局直接属性 **2,603 → 2,228**，文本引用 **2,254**，剩余含覆盖场景 **110**；
- Theme 新增 **47 个变体**，累计 **290 个定义 / 288 个直接使用 / 919 个节点引用**；Theme 场景引用 **620**；FontFile 场景引用 **155**；
- 五个场景合计 **223 个 Control** 的字体、字号、描边、阴影、颜色、StyleBox、位置、尺寸与文本迁移前后 **0 差异**；
- 1600×1000 与 1280×800 各 5 张截图，共 **13,120,000 像素**，**0 像素差异**；
- 四个场景直接启动 0 ERROR / 0 WARNING；`ldl` 的直接启动会在 HEAD 复现既有的 `add_child()` 时机与退出泄漏日志，本批未改变该行为，作为**既有运行期例外**登记，不冒充 0；
- `a_letter_for_all_players` 的多行文本 `Title13` 保留原文字与换行，未因资源清理改变正文；
- 其余高覆盖面板进入 32-3E，不以属性数接近目标冒充阶段完成。

## 7G. 32-3E 阵法/帮助面板结果（已完成，2026-11-01）

| 场景 | 迁移前直接属性 | 迁移后直接属性 | 迁移节点/变体 | 覆盖控件 |
|:---|:---:|:---:|:---|:---|
| `other_scene/zhen_fa_ui.tscn` | 65 | **0** | 10 节点 / 7 变体 | Button、Label、HBox |
| `other_scene/zhenfainfo.tscn` | 62 | **0** | 9 节点 / 6 变体 | Label、VBox |
| `other_scene/zhen_fa_tu_po.tscn` | 62 | **0** | 11 节点 / 7 变体（含共享空按钮） | Button、Label、VBox |
| `other_scene/hc_help.tscn` | 56 | **0** | 13 节点 / 6 变体 | Label、HBox |

共同结果：

- 四个场景合计直接属性 **245 → 0**；全局直接属性 **2,228 → 1,983**，文本引用 **2,009**，剩余含覆盖场景 **106**；
- Theme 新增 **25 个变体**，累计 **315 个定义 / 313 个直接使用 / 962 个节点引用**；Theme 引用 **663**；FontFile 场景引用 **146**；
- 四个场景合计 **166 个 Control** 的字体、字号、描边、阴影、颜色、StyleBox、位置、尺寸与文本迁移前后 **0 差异**；
- 1600×1000 与 1280×800 各 4 张截图，共 **10,496,000 像素**；将 `zhenyanbutton` 的 `AnimationPlayer` 冻结到 t=0 后 **0 像素差异**。未冻结时仅该阵眼指示器动画相位产生局部差异（1600：788 像素、max 8；1280：684 像素、max 22），样式与非动画区域无变化；
- 四个场景直接启动均 **0 ERROR / 0 WARNING**；
- `zhen_fa_ui` 的 `Title` 区域采用共享 `ZhenFaTabLabel`，`hc_help` 的合成页签、材料列与页码分别收敛到 `HcHelp*`；旧一次性 `StyleBoxEmpty` subresource 与场景字体 `ext_resource` 已删除；
- 其余高覆盖面板进入 32-3F，不把 1,983 处剩余直接属性写成阶段完成。

## 7H. 32-3F 自动战斗/幻化/法宝/阵眼面板结果（已完成，2026-11-01）

| 场景 | 迁移前直接属性 | 迁移后直接属性 | 迁移节点/变体 | 覆盖控件 |
|:---|:---:|:---:|:---|:---|
| `auto_battle_config.tscn` | 58 | **0** | 21 节点 / 14 变体 | Button、CheckButton、OptionButton、Label、容器 |
| `other_scene/transmogrified.tscn` | 57 | **0** | 16 节点 / 9 变体 | Label、HBox、Grid |
| `back_pack/magic_weapon_infor.tscn` | 55 | **0** | 19 节点 / 14 变体 | Label、VBox |
| `other_scene/zhen_yan_cure_level.tscn` | 53 | **0** | 10 节点 / 6 变体（共享空按钮） | Label、Button、VBox |

共同结果：

- 四个场景合计直接属性 **223 → 0**；全局直接属性 **1,983 → 1,760**，文本引用 **1,786**，剩余含覆盖场景 **102**；
- Theme 新增 **43 个变体**，累计 **358 个定义 / 356 个直接使用 / 1028 个节点引用**；Theme 节点引用 **729**；FontFile 场景引用 **134**；
- 四个场景合计 **114 个 Control** 的字体、字号、描边、阴影、颜色、StyleBox、位置、尺寸与文本迁移前后 **0 差异**；
- 1600×1000 与 1280×800 各 4 张截图，共 **10,496,000 像素**；冻结 `AnimationPlayer` 与 `AnimatedSprite2D` 到首帧后 **0 像素差异**；
- 四个场景直接启动均 **0 ERROR / 0 WARNING**；
- `auto_battle_config` 的面板与按钮 StyleBox 已移入 Theme；`magic_weapon_infor` 的空状态截图与隐藏内容由 Control 计算转储共同覆盖；`zhen_yan_cure_level` 复用 32-3E 的 `ZhenFaEmptyButton`；
- 其余高覆盖面板进入 32-3G-1 及后续低密度批次，不把当时的 1,760 处剩余直接属性写成阶段完成。

## 7I. 32-3G-1 首批高密度五场景结果（已完成，2026-11-01）

| 场景 | 迁移前直接属性 | 迁移后直接属性 | 迁移节点/变体 | 覆盖控件 |
|:---|:---:|:---:|:---|:---|
| `other_scene/zhen_fa_help.tscn` | 49 | **0** | 6 节点 / 2 变体 | Label |
| `monster/monster_139.tscn` | 48 | **0** | 6 节点 / 2 变体 | Button、Label |
| `shop/cure_times_box.tscn` | 47 | **0** | 14 节点 / 5 变体（共享空按钮） | Button、Label、HBox |
| `ldl/decompose_help.tscn` | 46 | **0** | 6 节点 / 3 变体 | Label、Box |
| `back_pack/skill_select.tscn` | 46 | **0** | 6 节点 / 4 变体 | Label |

共同结果：

- 五个场景合计直接属性 **236 → 0**；全局直接属性 **1,760 → 1,524**，文本引用 **1,550**，剩余含覆盖场景 **97**；
- Theme 新增 **16 个变体**，累计 **374 个定义 / 372 个直接使用 / 1066 个节点引用**；Theme 节点引用 **767**；FontFile 场景引用 **126**；
- 五个场景合计 **55 个 Control** 的字体、字号、描边、阴影、颜色、StyleBox、位置、尺寸与文本迁移前后 **0 差异**；
- 1600×1000 与 1280×800 各 5 张截图，共 **13,120,000 像素**；冻结 `AnimationPlayer`/`AnimatedSprite2D`，`monster_139` 额外冻结物理时间后 **0 像素差异**；
- `zhen_fa_help`、`cure_times_box`、`decompose_help`、`skill_select` 直接启动 0 ERROR / 0 WARNING；
- `monster_139` 的直接场景在 HEAD 上即会因缺少关卡 `monster_blood` 节点报既有 `SCRIPT ERROR`；本批未改变该行为，按**既有运行期例外**登记。截图使用独立捕获夹具关闭怪物血条与时间推进，主题差异仍为 0；
- 32-3G-2 继续低密度 8–10 场景批次，不以本批 5 场景验证替代阶段完成。

## 7J. 32-3G-2 低密度八场景结果（已完成，2026-11-01）

| 场景 | 迁移前直接属性 | 迁移后直接属性 | 迁移节点/变体 | 覆盖控件 |
|:---|:---:|:---:|:---|:---|
| `back_pack/dj_sell.tscn` | 29 | **0** | 7 节点 / 5 变体（共享空按钮） | Button、Label、LineEdit、Margin |
| `back_pack/sell_or_equ.tscn` | 27 | **0** | 6 节点 / 2 变体（共享空按钮/紧凑 VBox） | Button、Label、VBox |
| `back_pack/main_backpack.tscn` | 27 | **0** | 14 节点 / 12 变体 | Button、Label、TabBar、容器 |
| `shop/shop_item.tscn` | 26 | **0** | 5 节点 / 5 变体 | Button、Label、LineEdit |
| `main_menu/map_3.tscn` | 26 | **0** | 6 节点 / 2 变体（共享空按钮） | Button、Label |
| `main_menu/choose_player.tscn` | 25 | **0** | 5 节点 / 5 变体 | Label、HBox |
| `main_menu/map_0.tscn` | 24 | **0** | 3 节点 / 2 变体 | Button、Label |
| `ldl/forge.tscn` | 23 | **0** | 7 节点 / 6 变体 | Label、HBox |

共同结果：

- 八个场景合计直接属性 **207 → 0**；全局直接属性 **1,524 → 1,317**，文本引用 **1,343**，剩余含覆盖场景 **89**；
- Theme 新增 **39 个变体**，累计 **413 个定义 / 411 个直接使用 / 1119 个节点引用**；Theme 节点引用 **820**；FontFile 场景引用 **113**；
- 八个场景合计 **267 个 Control** 的字体、字号、描边、阴影、颜色、StyleBox、位置、尺寸与文本迁移前后 **0 差异**；
- 1600×1000 与 1280×800 各 8 张截图，共 **20,992,000 像素**；冻结动画后 **0 像素差异**；
- `sell_or_equ`、`main_backpack`、`shop_item`、`map_3`、`map_0`、`forge` 直接启动 0 ERROR / 0 WARNING；
- `dj_sell` 的直接场景在 HEAD 上即因未绑定物品上下文报既有 `Dictionary` 访问错误；本批未改变该行为，按既有运行期例外登记；截图使用禁用处理模式固定静态状态；
- `choose_player` 在 HEAD 上同样复现 CanvasLayer/退出泄漏日志，本批未改变，按既有运行期例外登记；
- `main_backpack` 的 `backpack_action_theme.tres` 只保留在未迁移的 `SortButton` 上，本批新增的 `bhyh_theme` 引用不覆盖该路径；
- 32-3G-3 已按静态/帮助组 171 处与动态菜单/背包组 158 处完成，两组均无动态布局差异。

## 7K. 32-3G-3 中高密度八场景结果（已完成，2026-11-01）

| 场景 | 迁移前直接属性 | 迁移后直接属性 | 迁移节点/变体 | 覆盖控件 |
|:---|:---:|:---:|:---|:---|
| `skill/skill_key_set.tscn` | 45 | **0** | 6 节点 / 2 变体 | Button、Label |
| `other_scene/game_need_know.tscn` | 44 | **0** | 15 节点 / 9 变体 | Label、Button、Margin、VBox |
| `main_menu/main_menu.tscn` | 42 | **0** | 10 节点 / 4 变体 | Label |
| `skill/learn_skill.tscn` | 41 | **0** | 6 节点 / 4 变体 | Label、Button |
| `ldl/forge_help.tscn` | 41 | **0** | 9 节点 / 3 变体 | Label、VBox |
| `main_menu/wan_ling_catalog_page.tscn` | 40 | **0** | 15 节点 / 13 变体 | Panel、Label、Button、容器 |
| `main_menu/body_training_detail.tscn` | 39 | **0** | 7 节点 / 5 变体 | Label、Button |
| `back_pack/use_items.tscn` | 37 | **0** | 10 节点 / 9 变体 | Label、LineEdit |

共同结果：

- 静态/帮助组（`skill_key_set`、`game_need_know`、`learn_skill`、`forge_help`）直接属性 **171 → 0**；动态菜单/背包组（`main_menu`、`wan_ling_catalog_page`、`body_training_detail`、`use_items`）直接属性 **158 → 0**；合计 **329 → 0**；
- 全局直接属性 **1,317 → 988**，文本引用 **1,014**，剩余含覆盖场景 **81**；
- Theme 新增 **49 个变体** 与 **9 个 StyleBox 子资源**，累计 **462 个定义 / 460 个直接使用 / 1197 个节点引用**；Theme 场景引用 **898**；FontFile 场景引用 **102**；
- 八个场景合计 **519 个 Control** 的字体、字号、描边、阴影、颜色、StyleBox、位置、尺寸与文本迁移前后 **0 差异**；
- 1600×1000 与 1280×800 各 8 张截图，共 **20,992,000 像素**；`main_menu`、`wan_ling_catalog_page`、`body_training_detail`、`use_items` 冻结动画与时间推进后 **0 像素差异**；
- `game_need_know`、`main_menu`、`learn_skill`、`forge_help`、`wan_ling_catalog_page`、`body_training_detail`、`use_items` 直接启动 0 ERROR / 0 WARNING；
- `skill_key_set` 的直接场景在 HEAD 上即因缺少技能 `need_name` 上下文报既有 `Dictionary` 访问错误；本批未改变该行为，按既有运行期例外登记；截图夹具注入有效的 `need_name` 后完成对照；
- `theme_override_audit --check`、`contract_gate`、`scene_probe ui-theme` 与 `check_all --godot-bin` 9/9（28.91s）通过；
- 32-3G-3 的两组均无动态布局差异，未拆分提交；32-3G-4 继续剩余最高密度面板。

## 8. 分批与验收边界

- 32-2A（标签密集）、32-2B（Button 密集）、32-3A（混合控件/布局）、32-3B（标签/混合五场景）、32-3C（首批标签五场景）、32-3D（标签/混合五场景）、32-3E（阵法/帮助四场景）、32-3F（自动战斗/幻化/法宝/阵眼四场景）、32-3G-1（首批高密度五场景）、32-3G-2（低密度八场景）与 32-3G-3（中高密度八场景）已完成；32-3G-4 继续剩余面板；每批先快照、再迁移、后验证。
- 32-3A 已补齐 `OptionButton`、`CheckButton`、`LineEdit`、`Panel`、`PanelContainer`、`PopupMenu`、`GridContainer`；32-3B 覆盖宠物、丹药、游戏说明、背包与被动技能；32-3C 覆盖炼体、诛仙剑阵、法宝与帮助面板；32-3D 覆盖全服信件、挑战、结算、ldl 与角色 HUD；32-3E 覆盖阵法 UI/信息/突破与合成帮助；32-3F 覆盖自动战斗、幻化、法宝与阵眼面板；32-3G-1 覆盖阵法帮助、测试怪物、兑换次数、分解帮助与技能选择；32-3G-2 覆盖道具出售、背包、商店、地图、选角与锻造；32-3G-3 覆盖技能按键/技能学习、游戏须知、主菜单、锻造帮助、万灵图录、炼体详情与道具使用；32-3G-4 继续其余面板与 `HSlider`/`TabBar`/`ItemList`。
- 32-4 建立例外清单，评估是否启用全局 Theme，退役旧 Theme，更新 `architecture.md`、`status.md` 与索引。
- 每批必须保留截图/控件转储与相关 `scene_probe_runner` 结果；共享 HUD/关卡 UI 变更追加 `level_1` 冒烟与 changed-only 回归。
- 阶段完成标准是“直接属性为 0 或全部登记例外”，不是“总数看起来接近 0”；动画轨道与动态调用单独报告。

## 9. 失败语义与不做

- Theme 路径缺失、类型不符、变体不存在：在加载/审计阶段明确失败；不得回退到旧内联样式或静默使用默认主题。
- 不为兼容旧场景长期保留两套 Theme；迁移完成即删除旧入口。
- 不做主题切换、换肤、字体替换、布局重排、动画时序修改或显示基线调整。
- 不把运行时品质色、血量色、奖励状态色迁入 Theme；这些继续由数据/脚本拥有。

## 10. 后续决策

| 项 | 当前状态 | 出口 |
|:---|:---|:---|
| 基础 Theme 路径与现有 `backpack_action_theme.tres` 的合并方式 | `Scene/theme/bhyh_theme.tres` 已用于 pilot；旧 Theme 未合并 | 32-4 迁移/退役 |
| 最终变体名单与字体族映射 | 32-1/32-2A/32-2B/32-3A/32-3B/32-3C/32-3D/32-3E/32-3F/32-3G-1/32-3G-2/32-3G-3 已冻结 462 个类型（460 直接 + 2 基类） | 32-3G-4 只按批扩展，不重命名 |
| 是否启用全局 `gui/theme/custom` | 默认不启用 | 32-4 全 UI 覆盖评审 |
| 动画轨道/脚本动态覆盖的最终例外清单 | 动画 26 处、动态调用 383 处均未迁移 | 32-4 收口 |

## 11. 参考

- [`modernization_gap_matrix.md`](modernization_gap_matrix.md) §3.2 B1
- [`current-iteration.md`](../roadmap/current-iteration.md) §5C
- [`acceptance.md`](acceptance.md) L0~L3
- [`status.md`](status.md) 当前验证事实
