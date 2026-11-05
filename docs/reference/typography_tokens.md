# Typography and Control Tokens（P2 pilot）

> **状态**：P2 试点（2026-11-05）。当前只覆盖 `game_set` 与 `back_pack` 使用的变体；其余面板继续使用既有 Theme 值，逐批迁移。
> **边界**：不重命名 618 个冻结 `theme_type_variation`，不改变 Theme 结构、字体族、布局层级或显示画布。

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
| `title` | 32 | 面板主标题/返回 |
| `display` | 36 | 特殊主标题 |
| `combat` | 40 / 50 / 76 / 100 | 战斗、伤害与数字保留值 |

试点只使用 `12/14/16/18/20/24/32/36`；战斗特殊值不在本批收敛范围内。

### 文字颜色

| Token | 值 | 用途 |
|:---|:---|:---|
| `text_primary` | `#FFFFFF` | 主文字 |
| `text_muted` | `#DFDFDF` | 次级/禁用前的弱文字 |
| `text_gold_light` | `#FFF4BF` | 属性数值、亮金 |
| `text_gold` | `#FFD68A` | 提示、背包金色 |
| `ink` | `#000000` | 描边/阴影 |

品质色、血量色、奖励状态色继续由脚本与数据拥有，不进入本表。

### 描边

| Token | 值 | 用途 |
|:---|---:|:---|
| `none` | 0 | 无描边 |
| `thin` | 1 | 小字号/常规文字 |
| `regular` | 2 | 标题 |
| `strong` | 3 | 返回/强调按钮 |
| `hud` | 6 | HUD 与属性数值 |
| `combat` | 10 | 战斗飘字保留值 |

### Button 族

| Family | 试点变体 | 规则 |
|:---|:---|:---|
| Text / Ghost | `SettingsButton`、`SettingsButtonBright`、`SettingsButtonCompact`、`SettingsButtonMedium`、`SettingsButtonSmallBright`、`SettingsButtonTinyBright`、`SettingsReturnButton` | 透明 StyleBox + 字体色状态 |
| Icon | `BackpackHeadButton`、`BackpackWingsButton` | 空 StyleBox + 图标内容 |
| Action | `BackpackActionButton` | 背包动作专用 StyleBox 三态 |
| Toggle | `BackpackToggleButton` | 开关状态由字体色表达 |
| Option | `SettingsOption` | `OptionButton` 选项控件 |

`BackpackWingsButton` 在本批改为继承 `BackpackHeadButton`，共享 Icon 族的空 StyleBox，视觉不变；名称保留。

## 2. Pilot 映射

| 变体 | 原值 | Token 值 |
|:---|:---|:---|
| `SettingsTitle` | 35 / outline 2 | 36 / outline 2 |
| `SettingsSection` | 25 / outline 1 | 24 / outline 1 |
| `SettingsValue` | 23 / outline 1 | 24 / outline 1 |
| `SettingsOptionLabel` | 22 / outline 1 | 24 / outline 1 |
| `SettingsControlLabel` | 21 / outline 1 | 20 / outline 1 |
| `SettingsSmallLabel` | 19 / outline 1 | 18 / outline 1 |
| `SettingsButton` | 25 | 24 |
| `SettingsButtonCompact` | 21 | 20 |
| `SettingsButtonMedium` | 22 | 24 |
| `SettingsReturnButton` | 30 / outline 4 | 32 / outline 3 |
| `SettingsOption` | 21 | 20 |
| `BackpackHpLabel` / `BackpackMpLabel` | 15 | 16 |
| `BackpackExpLabel` / `BackpackHpValue` | outline 5 | outline 6 |
| `BackpackHpValue` | `#FFFFA4` | `text_gold_light` |
| `BackpackMessageLabel` / `BackpackWingLabel` | 各自金色 | `text_gold` |
| `BackpackWingsButton` | `Button` + 重复空 StyleBox | 继承 `BackpackHeadButton` |

`BackpackHpValue`、`BackpackExpLabel`、返回按钮的金色/描边变化属于既有意图的 token 化；不新增颜色族。

## 3. 验证

- 场景：`game_set`、`back_pack`；1280×800 与 1600×1000。
- 控件转储：位置移动 **0**；`game_set` 3 个控件尺寸随字号变化；`back_pack` 5 个属性行高度增加 2 px；未见裁切。
- 截图：`G:/tmp/p2_pilot_before/` 与 `G:/tmp/p2_pilot_after/` 对照；颜色/字号变化只落在试点变体。
- 既有门禁：`font_coverage_audit --check`、`theme_override_audit --check`、`check_all --godot-bin`、`scene_probe ui-theme`、`level_1` 冒烟。
