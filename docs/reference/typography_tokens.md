# Typography and Control Tokens（P2）

> **状态**：P2-2 试点（2026-11-05）。当前覆盖 `game_set`、`back_pack`、`main_menu`、`skill/zd_skill`、`pet/pet_interface`、`archive_interface/read_archive_interface`；其余面板继续使用既有 Theme 值，逐批迁移。
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
| `title` | 32 | 面板主标题/返回 |
| `display` | 36 | 特殊主标题 |
| `combat` | 40 / 50 / 76 / 100 | 战斗、伤害与数字保留值 |

试点使用 `12/14/16/18/20/24/32/36`；战斗特殊值不在本批收敛范围内。

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
| `text_combat` | `#FFFF00` | 战斗冷却/需求 |
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

## 4. 对照结果

| 场景 | 位置变化 | 尺寸变化 | 说明 |
|:---|---:|---:|:---|
| `game_set` | 0 | 3 | 标题/按钮随字号变化，无裁切 |
| `back_pack` | 0 | 5 | 属性行高度 +2 px，无裁切 |
| `main_menu` | 3（纵向 <1 px） | 4 | 居中标签随字体度量重排 |
| `skill/zd_skill` | 27（ScrollContainer 内） | 2 | 行高增加，滚动容器高度 +33 px；内容仍可滚动，无裁切 |
| `pet/pet_interface` | 0 | 0 | 仅字体颜色/字号变化 |
| `read_archive_interface` | 0 | 4 | 按钮/标题宽度随字号变化，无裁切 |

截图与控件转储：

```text
G:/tmp/p2_pilot_before/
G:/tmp/p2_pilot_after/
G:/tmp/p2b_before/
G:/tmp/p2b_after/
```

## 5. 审计

```bash
python scripts/theme_token_audit.py --check
```

- `scripts/theme_token_baseline.json` 冻结 618 个既有变体值；既有变体的合法迁移允许保留基线值。
- 新增变体或既有变体改写值必须使用本表 token；新增 Button 必须继承已登记 token 基类。
- 当前结果：**618 变体 / 0 违规**。

## 6. 既有门禁

- `font_coverage_audit.py --check`：135 场景 / 790 中文节点 / 0 缺字；
- `theme_override_audit.py --check`：直接属性 0，动画轨道 26；
- `check_all --godot-bin`：**9/9 PASS**（37.38s）；
- `scene_probe ui-theme`：PASS（4.88s）；
- `level_1`：4 阶段冒烟，0 ERROR / 0 WARNING。

其余面板保持旧值，后续按同一流程分批迁移；不一次性重排 110 个颜色。
