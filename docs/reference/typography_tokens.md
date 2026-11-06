# Typography and Control Tokens

> **类型**：当前 token 标尺（Current）
> **来源**：Phase 27-1~27-7 收口（2026-11-05）；完整批次、逐面板映射与对照结果见 [`../archive/iteration_27_theme_font_convergence.md`](../archive/iteration_27_theme_font_convergence.md)。
> **边界**：不重命名 618 个冻结 `theme_type_variation`；新增字号、颜色、字体或 StyleBox 必须先进入 token 源；不改变布局层级或显示画布。
> **规范边界**：本文只维护字号、颜色、描边和 Button token；字体角色、组件选择与 Theme 使用边界见 [`../standards/ui_typography_contract.md`](../standards/ui_typography_contract.md)。

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

常规使用 `12/14/16/18/20/24/28/32/36`；战斗特殊值不在常规收敛范围内。

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

动画轨道中的 `hit_text` / `hurt_text` 颜色仍按已接受例外由 `hit_text.tscn` 持有；本表只登记语义名，不把运行时伤害状态迁入 Theme。

### 脚本动态色

`source/Script/base/ui_color_tokens.gd` 提供 `UiColorTokens` 常量，供无法直接引用 Theme 变体的脚本动态 UI 使用。`mount_panel.gd` 与 `equipment_catalog_page.gd` 等脚本的文字色已改用该类别名；面板自绘的 StyleBox 底色、边框与阴影仍属面板样式，不进入文字 token。

### 脚本表面色（UiSurfaceTokens）

`source/Script/base/ui_surface_tokens.gd` 集中自绘菜单 StyleBox 的结构色。与文字色分离，避免把背景/边框混入 `UiColorTokens`。

| 组 | Token 与值 |
|:---|:---|
| 冷色底色 | `COOL_DEEPEST #101519`、`COOL_FRAME Color(0.067,0.078,0.084,0.985)`、`COOL_DEEP #151B1E`、`COOL_PANEL #1B2023`、`COOL_PANEL_ALT #1C2429`、`COOL_RAISED #20272B`、`COOL_ICON_BG #171D20` |
| 冷色状态 | `COOL_CONTROL #293138`、`COOL_HOVER #3A464D`、`COOL_PRESSED #1D252A`、`COOL_DISABLED #343B3F` |
| 冷色边框 | `COOL_BORDER_DIM #58666D`、`COOL_BORDER #5C6870`、`COOL_BORDER_BRIGHT #89A69C`、`COOL_BORDER_SOFT #B6C9BD`、`COOL_PREVIEW_BORDER #4F5C61`、`COOL_DAMAGE_BORDER #52616A` |
| 冷色强调 | `COOL_ACCENT #BA9447`、`COOL_ACCENT_BRIGHT #D0A750`、`COOL_ACCENT_SOFT #E2B75C`、`COOL_ACCENT_LINE #BA9447 70%`、`COOL_PROGRESS #6F8E78` |
| 危险/绿色 | `DANGER_DEEP/DANGER_HOVER/DANGER_PRESSED/DANGER_BORDER/DANGER_BORDER_HOVER/DANGER_BORDER_PRESSED`、`DANGER_SELECTED #7A2E32`；`GREEN_DEEP #1D4937`、`GREEN #276149`、`GREEN_HOVER #347A5E`、`GREEN_BORDER #72AE8E`、`GREEN_BORDER_BRIGHT #A4D7BB`、`GREEN_BORDER_SOFT #D0EADB`、`DISABLED_BORDER #596166` |
| 大地色 | `EARTH_DEEP #171B19`、`EARTH_PANEL #20241F`、`EARTH_PANEL_ALT #232820`、`EARTH_CONTROL #242621`、`EARTH_CARD #282D25`、`EARTH_RAISED #2D3027`、`EARTH_HOVER #37362B`、`EARTH_SELECTED #49402C`、`EARTH_INPUT #20251F` |
| 大地边框 | `EARTH_BORDER #64563E`、`EARTH_BORDER_BRIGHT #B59A60`、`EARTH_BORDER_ACCENT #AA8B55`、`EARTH_BORDER_SOFT #454B3A`、`EARTH_BORDER_WARM #786443`、`EARTH_BORDER_DIM #735933`、`EARTH_ACCENT #E8C478` |
| 暖棕/输入 | `WARM_DEEPEST/WARM_DEEP/WARM_PANEL/WARM_PANEL_SOFT/WARM_HOVER/WARM_PRESSED/WARM_BORDER/WARM_BORDER_BRIGHT/WARM_ACCENT_LIGHT`；`INPUT_CARET #FFD97A`、`INPUT_SELECTION #C09C56 45%`、`WARM_OVERLAY` |
| 模式/地图 | `MODE_PANEL #DAB070`、`MODE_PANEL_BORDER #382714`、`MODE_ACTION #ED9908`、`MODE_ACTION_HOVER #FFC343`、`MODE_ACTION_PRESSED #C57A06`、`MODE_ACTION_BORDER #73501D`、`MAP_HIGHLIGHT #FFF000` |
| 状态 modulate | `PREVIEW_LOCKED_MODULATE #8C8C8C`、`DISABLED_MODULATE #9E9E9E`；`Color.WHITE` 为启用/复位 |
| 遮罩 | `OVERLAY_LIGHT 48%`、`OVERLAY_MEDIUM 68%`、`OVERLAY_STRONG 72%`、`OVERLAY_EARTH 78%`、`SHADOW 50%`、`WARM_OVERLAY 52%` |

输入配色：`zhen_yao_tower.gd` 数量输入、`equipment_catalog_page.gd` 搜索框与主题 `TowerFloorInput` 使用 `INPUT_CARET` / `INPUT_SELECTION`；`ShopSearchInput` 使用浅底 `#331F12` 光标与 25% 选区；`ArchiveLoginInput` / `ArchiveNumberInput` 使用深底 `INPUT_CARET` / `INPUT_SELECTION`。

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

相同 Text/Icon 样式收敛到既有基类，保留原变体名，视觉不变。

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

## 3. 审计

```bash
python scripts/theme_token_audit.py --check
```

- `scripts/theme_token_baseline.json` 冻结 **734 个变体**的有效值（618 个冻结业务名 + 112 个 `Semantic*` 基类 + `SetMenuHintLabel` / `SetMenuActionButtonGroup` / `SkillHeaderLabel` / `ChooseMusicButton`）。
- 新增变体或既有变体改写值必须使用本表 token；新增 Button 必须继承已登记 token 基类。
- 当前结果：**734 变体 / 0 违规**；新增语义基类走 `Semantic*` 前缀，不绕过字号/颜色 token。
- `theme_override_audit` 保持直接属性 **0**、动画轨道 **26**（`hit_text.tscn` 命中颜色值同步）。

## 4. 既有门禁

- `font_coverage_audit.py --check`：135 场景 / 788 中文节点 / 0 缺字；Theme 字体资产 4；动态样本 5 / 0 缺字；
- `theme_override_audit.py --check`：直接属性 0，动画轨道 26；
- `theme_token_audit.py --check`：734 变体 / 0 违规；有效字号与 8 类字体色全部在 token；
- `convert_ui_theme_tokens.py --check`：39 文字 token、6 组表面 token、37 语义字体色、10 项受管 Theme 属性 / 0 漂移；
- `ui_surface_token_audit.py --check`：主菜单 0 裸色；StyleBox 字面色 0 / 基线 0；
- `theme_variant_audit.py --check`：618 冻结变体 / 112 基类 / 734 总变体 / 属性 1,788 / StyleBox 36 / 独立重复组 10；
- `font_role_audit.py --check`：734 变体 / 0 错误 / 0 条存量字号例外；
- `ui_dynamic_theme_audit.py --check`：352 调用 / 静态 0（`Script` 与 `Scene`）；基线 `ui_dynamic_theme_baseline.json`；
- `ui_text_punctuation_audit.py`：`--self-test` 9/9；全仓 report-only 扫描 0 残留；
- `check_all --godot-bin`、`scene_probe ui-theme`、`scene_probe ui-factories`、HUD 只读探针与 `level_1` 4 阶段冒烟：最近结果见 [`status.md`](status.md)。

## 5. 边界

- 字号、颜色、描边与 Button token 的变更必须有截图/控件几何对照；不静默改变显示基线。
- 品质色、血量色、奖励状态色、战斗飘字动画色不迁入 token 表。
- 完整 P2 逐面板映射与对照结果见 [`../archive/iteration_27_theme_font_convergence.md`](../archive/iteration_27_theme_font_convergence.md) 附录 A/B。

