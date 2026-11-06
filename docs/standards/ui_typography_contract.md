# UI 字体角色与 Theme 使用边界契约

> **状态**：生效（2026-11-06）
> **范围**：`source/Scene/**/*.tscn`、`source/Script/**/*.gd` 的 UI 文本、`source/Scene/theme/bhyh_theme.tres`、字体资源与相关审计。
> **定位**：定义“哪个界面元素使用哪个字体角色、Theme 变体与字号区间”。当前字体清单、资源规模和审计结果仍由 [`../reference/theme_font_inventory.md`](../reference/theme_font_inventory.md)、[`../reference/ui_theme_contract.md`](../reference/ui_theme_contract.md) 与 [`../reference/typography_tokens.md`](../reference/typography_tokens.md) 记录。
> **效力**：新增 UI 与主动重构的 UI 必须遵守本规范；冻结变体与现有例外按 §7 处置，不能把历史映射当作新代码先例。
> **决策**：[ADR-026](../decisions/ADR-026-ui-font-theme-role-contract.md)；显示基线仍由 [ADR-016](../decisions/ADR-016-display-canvas-window-and-hud-baseline.md) 约束。

---

## 1. 目标与非目标

### 1.1 目标

1. 为所有 UI 文本提供唯一、可评审的字体选择规则，避免按面板或按开发者偏好新增字体。
2. 保留已经完成的三层收敛：唯一 Theme、语义变体、字体 fallback。
3. 让标题、操作、正文、数值与专有名词形成稳定层级，而不是依赖逐面板调参。
4. 让存量例外可追踪、可迁移，不因“当前代码这样写”而扩大。

### 1.2 非目标

- 本规范不重新设计布局、配色或显示基线。
- 本规范不强制重命名冻结的 `theme_type_variation`。
- 本规范不引入 Theme 切换、换肤、可变字体或运行时字体管理服务。
- 本规范不把运行时品质色、血量色、奖励状态色迁入 Theme。
- 本规范不把角色语义审计等同于视觉验收；组件矩阵仍需人工评审与截图验证。

---

## 2. 字体角色模型

运行时 UI 只允许以下 **4 个字体角色**，另有 1 个不进入 Theme 的品牌字体：

| 角色 | 当前实现资源 | 主要用途 | 建议字号 | 约束 |
|:---|:---|:---|---:|:---|
| `body` | 默认 `fz_cu_yuan_m03.tres`，fallback `msyh_semibold.ttc` | HUD、数字、输入框、属性标签、紧凑控件、默认正文 | 12–20；功能性大号 24/28/32/36；战斗数字 40/50/76/100 | 默认角色；大号仅用于数字/计时/短功能标签，不承担标题或长段叙事 |
| `ui` | `font_hk.tres`（LXGW WenKai Regular） | 公告、帮助、描述、对话正文、物品元数据 | 14–24 | 不用于 12 px；不承担主标题 |
| `display` | `font_return.tres`（FZCuYuan M03） | 屏幕/面板标题、菜单级操作、主 CTA、短强调标签 | 16–40；标题 24+ | 不用于长段正文或数据行 |
| `accent` | `font_main.tres`（LXGW WenKai Medium） | 物品名、技能名、选中标签、专有名词、单点强调 | 16–32 | 一个组件只允许一个短 accent 字符串；不用于段落或元数据组 |
| `brand` | `FZRunYYSJW` | 游戏 LOGO、活动主视觉 | 不进入运行时 Theme | 不用于普通 UI；不进入 Theme |

### 2.1 资源文件名是历史名

`font_main`、`font_hk`、`font_return` 是旧字体时代的文件名，当前语义已经变化：

```text
font_main   -> accent
font_hk     -> ui
font_return -> display
默认字体     -> body
```

维护时必须以**角色**为准，不能从资源文件名推断用途。资源重命名属于独立迁移，不得在普通 UI 修改中顺手重命名。

### 2.2 单一默认角色

`body` 是唯一默认角色。没有明确理由时，新控件使用 `body`，而不是选择“看起来更有气氛”的 `display` 或 `accent`。

---

## 3. 选择规则

### 3.1 信息层级

1. 一个信息块只能有一个**主角色**；标题可以使用 `display`，正文使用 `ui` 或 `body`。
2. 同一行内的标签与数值默认使用同一角色。需要强调数值时，优先改变颜色、描边或字号，不新增第二个字体族。
3. `accent` 只用于短专名或单点强调。一个物品、技能或面板条目只保留一个短 accent 字符串。
4. `display` 只用于标题、菜单级操作和主 CTA，不用于数据行、属性组、长描述。
5. 同一屏内的字体角色数量应保持可控。出现 3 个以上角色时，必须能说明每个角色的信息职责；不能仅因“这里以前就是这样”保留。
6. 字体角色不能替代布局、间距、颜色或状态设计；禁止用字体堆叠来弥补信息层级。

### 3.2 组件矩阵

| 组件/信息 | 角色 | 说明 |
|:---|:---|:---|
| 屏幕标题、面板主标题 | `display` | 24 px 以上；短字符串 |
| 菜单级操作、主 CTA | `display` | 20–32 px；同一菜单可统一使用 |
| 菜单底部路径提示 | `body` 或 `ui` | 16–18 px；不承担强调 |
| 面板内分组标题 | `display` 或 `ui` | 20–28 px；行内小标题优先 `ui`/`body` |
| HUD 数字、伤害、冷却 | `body` | 战斗数字可用 24/28/32/36/40/50/76/100 |
| 属性标签 | `body` | 12–20 px |
| 属性数值 | `body` | 与标签同角色；用金色/描边/字号区分 |
| 物品名、技能名 | `accent` | 16–28 px；每项最多一个 |
| 物品元数据（品质/类型/拥有等） | `ui` | 14–20 px；不整组使用 accent |
| 物品/技能描述 | `ui` | 14–24 px；可换行 |
| 售价、资源数值 | `ui` 或 `body` | 同一面板保持一致 |
| 公告、帮助、对话正文 | `ui` | 14–24 px |
| 输入框文本/占位 | `body` | 14–20 px |
| 紧凑功能标签 | `body` | 12–14 px；12 px 仅限辅助信息 |
| 品牌 LOGO、活动主视觉 | `brand` | 不进入 Theme |

**默认判断顺序**：先问“这是操作/标题、阅读文本、数值还是专名”，再选角色；不要先选字体。

### 3.3 字号边界

字号数值本身仍由 [`typography_tokens.md`](../reference/typography_tokens.md) 和 `theme_token_audit.py` 管理；本规范定义角色可用的区间。

| 角色 | 允许区间 | 禁止 |
|:---|---:|:---|
| `body` | 12–20；功能性大号 24/28/32/36；战斗数字 40/50/76/100 | 大号仅用于数字/计时/短功能标签；不使用 8/10 等非 token 字号；不用于长正文 |
| `ui` | 14–24 | **12 px 禁止用于新增 UI**；存量仅按 §7 例外 |
| `display` | 16–40 | 16/18/20 只用于短标签/操作；24+ 才承担标题；不用于长文本 |
| `accent` | 16–32 | 不使用 12/14；不用于段落、属性组或元数据块 |

新增字号必须落在既有 token 内；本规范不新增字号 token。

### 3.4 禁止模式

- 在 `.tscn` 中写 `theme_override_fonts/font` 或直接 `ExtResource` 字体资源。
- 在脚本中为静态文本调用 `add_theme_font_override`；静态控件必须使用 Theme 角色。
- 脚本直接字体路径只允许用于运行时拼接的富文本、动态列表或主题无法表达的生成内容，并且必须使用角色对应文件与集中映射；不得成为静态 UI 的普通入口。
- 为单个面板新增字体文件或新字体角色。
- 用 `display` 承担描述、帮助、属性列表或数据行。
- 用 `accent` 承担整段元数据或长文本。
- 用 fallback 字体承担正常视觉设计；fallback 只处理缺字。
- 把临时布局或单场景字体覆盖复制成通用样式。

---

## 4. Theme 与变体规则

1. 唯一正式 Theme 为 `source/Scene/theme/bhyh_theme.tres`；禁止恢复旧 Theme 或新增平行 Theme。
2. `body` 是 Theme 默认字体；`ui`、`display`、`accent` 通过语义基类和业务变体消费。
3. 新增业务变体应继承既有 `Semantic*` 基类；业务变体只声明颜色、字号、描边、间距等差异。
4. 叶子变体不得直接引用字体文件；字体角色由语义基类或标准中的角色别名提供。
5. 不重命名冻结的业务变体名；新增/重命名必须评审并同步 `theme_variant_audit` 基线。
6. 不在场景树中深层查找 Theme；不在运行时把控件状态写回共享 Theme。
7. `project.godot` 不设置全局 `gui/theme/custom`；继续采用显式节点/场景绑定。
8. 字体资源必须是 `FontVariation`；每个角色必须有显式 fallback，fallback 链在 `source/Scene/theme/*.tres` 中可见。

---

## 5. Fallback 与字体资产

| 角色 | 回退 |
|:---|:---|
| `body` | FZCuYuan → Microsoft YaHei Semibold |
| `ui` | LXGW WenKai Regular → `body` |
| `display` | FZCuYuan M03 → `body` |
| `accent` | LXGW WenKai Medium → `ui` |

规则：

1. fallback 只解决缺字，不改变角色语义。
2. `Microsoft YaHei` 是本地 fallback，不作为新的设计字体，也不新增其用途。
3. `FZRunYYSJW` 只用于 LOGO/活动主视觉，不进入 Theme，不参与普通 UI 文本。
4. `source/Font/` 为私有素材目录，不进入公开仓库；字体文件、`.import` 与授权信息不得写入公开提交。
5. 字体子集化是独立打包优化，必须保留 hinting、fallback、OFL 保留字体名合规与截图验证；不能与角色迁移混做。
6. 新增或替换字体必须先完成授权与覆盖检查，再更新本规范、清单和门禁。

---

## 6. 变更流程

### 6.1 允许的变更

- 在既有 4 个角色内调整某个组件的角色；
- 新组件按 §3.2 选择既有角色；
- 新增/调整字号、颜色、描边 token；
- 为缺字补充 fallback。

### 6.2 必须评审的变更

- 新增字体角色或品牌字体；
- 新增字体文件或替换角色字体；
- 新增全局例外；
- 修改冻结变体的字体归属；
- 改变 Theme 默认字体。

新增角色必须同时更新本规范、ADR、角色清单与审计基线；没有 ADR 的角色扩展不允许进入代码。

### 6.3 视觉变更验收

改变字体角色、字号或 fallback 后，必须执行：

1. `1280×800` 与 `1600×1000` 代表场景截图；
2. 控件几何转储与位移对照；
3. `font_coverage_audit` 缺字检查；
4. Theme 变体、token 与直接覆盖门禁；
5. 受影响场景的运行时探针；涉及玩法/关卡时执行全量回归。

仅修改文档时不需要引擎门禁，但必须执行 `docs_audit.py` 与链接检查。

---

## 7. 存量例外与迁移

### 7.1 首批已迁移（2026-11-06）

E1–E4 已完成角色与字号迁移，不再作为例外保留：

| 原例外 | 当前结果 |
|:---|:---|
| E1 `SynHelpBody` 等 `ui` 12 px | `BackpackWingLabel` 改 `body` 12 px；`SynHelpBody`、`TaskRewardTitle` 改 `ui` 14 px；`MysteryShopTitle` 改 `body` 12 px（侧栏长说明，避免 14 px 溢出） |
| E2 装备元数据 `accent` | `EquipmentItemMeta`、`EquipmentItemHighlight` 改 `ui`；`EquipmentName` 保留 `accent` |
| E3 装备数值 `ui` | `EquipmentStatValue` 改 `body`，与 `EquipmentStatLabel` 同角色 |
| E4 菜单提示 `accent` | `MenuHintLabel` 改 `body` 18 px |

### 7.2 剩余存量字号偏离

P2.2 已优先处理 body 24/28/32/36 与 ui 28 的语义归属；`scripts/font_role_baseline.json` 目前只保留 body 10 四条、accent 36 五条、accent 50 一条，继续只允许收紧。该基线只允许收紧，不允许新增未登记例外；它不属于目标设计，不能作为新代码依据。

未列入首批迁移或基线的现有组合不自动成为例外；必须按 §3 评审，或在迁移批次中登记后才可保留。

补充说明：

- `MenuActionButton`、`MenuActionButtonOutline` 使用 `display` 属于 §3.2 的菜单级操作，不是例外。
- `SetMenuHintLabel` 使用 `display` 24 px 属于短强调标签/菜单操作；如果后续改为表单标签，应改用 `ui`/`body`。
- `EquipmentTitle` 使用 `ui` 承担面板内分组标题，符合 §3.2 的“行内小标题优先 ui/body”。
- 例外清理完成或新增例外时，必须同步更新本表、`theme_font_inventory.md` 的事实记录与 `font_role_baseline.json`。

---

## 8. 审计与事实边界

### 8.1 当前生效门禁

| 命令 | 当前职责 |
|:---|:---|
| `theme_override_audit.py --check` | 静态直接 `theme_override_*`、直接字体引用与动态调用上限 |
| `theme_token_audit.py --check` | 字号、字体色、受管 Theme 属性必须落在 token 内 |
| `theme_variant_audit.py --check` | 冻结变体、变体规模、StyleBox 与重复组基线 |
| `font_coverage_audit.py --check` | 场景字体覆盖、动态样本、未引用字体 |
| `ui_dynamic_theme_audit.py --check` | 脚本 `add_theme_*` 分类与基线 |
| `font_role_audit.py --check` | 角色归属、包装/fallback、直接字体、宋体残留、字号例外 |

这些门禁不判断“角色选择是否语义正确”。因此新增/修改 UI 必须按 §3 和 §7 人工评审；不能因为现有门禁通过就认为角色边界已经满足。

### 8.2 角色语义审计

`scripts/font_role_audit.py --check` 已接入 `contract_gate.py`，覆盖：

1. 每个业务变体的有效字体角色；
2. 角色包装、基础字体与 fallback 一致性；
3. 场景/脚本中的未登记直接字体；
4. 宋体文件残留；
5. 角色字号区间与 `scripts/font_role_baseline.json` 存量例外。

`font_role_baseline.json` 是迁移期冻结基线，不是目标值；新增未登记字号例外会被阻断。该脚本不替代组件矩阵的人工评审，截图与布局验证仍按 §6.3 执行。

### 8.3 Reference 的职责

- [`theme_font_inventory.md`](../reference/theme_font_inventory.md)：记录当前字体角色、文件、计数与审计事实，不定义新规则。
- [`ui_theme_contract.md`](../reference/ui_theme_contract.md)：记录 Theme 资源、变体、覆盖和审计实现，不重复角色选择矩阵。
- [`typography_tokens.md`](../reference/typography_tokens.md)：记录字号、颜色、描边和 Button token，不重复字体角色规则。

这三份文档与本规范冲突时，**角色选择与使用边界以本规范为准**；计数与验证以 `status.md` 和审计脚本为准。

---

## 9. 关联入口

- [ADR-026](../decisions/ADR-026-ui-font-theme-role-contract.md)
- [ADR-016 显示基线](../decisions/ADR-016-display-canvas-window-and-hud-baseline.md)
- [ADR-020 视觉资产](../decisions/ADR-020-typed-visual-assets-and-streaming-lifecycle.md)
- [ADR-021 总体目标架构](../decisions/ADR-021-project-wide-target-architecture.md)
- [Theme 与字体盘点](../reference/theme_font_inventory.md)
- [UI Theme 契约](../reference/ui_theme_contract.md)
- [Typography Token](../reference/typography_tokens.md)
- [验收标准](../reference/acceptance.md)
