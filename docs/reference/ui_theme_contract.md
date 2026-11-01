# UI Theme 契约（Phase 32-0 草案）

> **状态**：Phase 32-0 基线审计已完成，契约为草案；**未实施迁移**。32-1 试点通过后，才允许开始 32-2 分批。
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

| 项 | 基线 | 说明 |
|:---|:---:|:---|
| 文本 `theme_override_*` 引用 | **6,830** | 135 个 `.tscn` |
| 直接属性覆盖 | **6,804** | Phase 32 的静态迁移对象 |
| Animation 轨道路径引用 | **26** | 仅 `hit_text.tscn`；属于动态表现，单独登记 |
| 直接属性分类 | colors 1,730 / styles 1,625 / constants 1,393 / fonts 1,055 / font_sizes 1,001 | 合计 6,804 |
| Label / Button 直接覆盖 | 3,921 / 2,380 | 合计 6,301，约占直接属性 92% |
| `FontFile` 场景引用 | 207 | 12 个字体文件 |
| Theme `.tres` | 1 | `backpack_action_theme.tres`；2 个场景引用 |
| `theme_type_variation` | 0 | 尚无变体契约 |
| 脚本 `add_theme_*` | 383 处 / 39 个文件 | 数据/状态驱动，不计入静态迁移 |

基线是**上限**，不是迁移目标。迁移只能使直接属性与动画引用下降，不能因新增面板或重构静默增加；新增场景需要显式更新基线并说明原因。

## 3. 数据与所有权

### 3.1 Theme 资源

- 候选基础资源：`source/Scene/theme/bhyh_theme.tres`（`snake_case` 文件；新建目录遵循功能子目录规则）。
- 现有 `source/Scene/back_pack/backpack_action_theme.tres` 先审计；若可复用则扩展并迁移其 2 个场景引用，最终只保留一个正式 Theme 来源，避免两套长期主题。
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

`theme_type_variation` 的值使用 `PascalCase` 角色名，不使用文件路径、中文、空格或下划线分隔。初始候选（32-1 审计后冻结）：

| 变体 | 角色 | 典型控件 |
|:---|:---|:---|
| `TitleLabel` | 面板标题 | `Label` |
| `SectionLabel` | 分组标题 | `Label` |
| `BodyLabel` | 正文 | `Label` |
| `CaptionLabel` | 辅助说明 | `Label` |
| `ValueLabel` | 数值/状态值 | `Label` |
| `PrimaryButton` | 主操作 | `Button` |
| `SecondaryButton` | 次操作 | `Button` |
| `MenuButton` | 菜单项 | `Button` |
| `ToggleButton` | 开关/切换 | `Button`、`CheckButton` |
| `DangerButton` | 危险/删除 | `Button` |
| `OptionControl` | 选项控件 | `OptionButton` |
| `InputField` | 文本输入 | `LineEdit` |
| `SliderControl` | 滑条 | `HSlider` |

规则：

1. 变体名表达**角色**，不按单个场景命名；
2. 不把一个场景的局部样式命名为全局变体；
3. 同一角色在不同字体族下需要保留字体差异时，可拆分为 `TitleLabelSerif` 等明确变体，不得用运行时覆盖临时修正；
4. 变体名单在 32-1 试点后冻结；新增变体需要在 Phase 32 批次评审中登记，不能静默扩散。

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

## 7. 32-1 试点协议

试点：`source/Scene/main_menu/game_set.tscn`。

| 项 | 值 |
|:---|:---:|
| 直接属性覆盖 | 239 |
| 涉及控件 | Button 175、Label 56、HSlider 4、OptionButton 2（按覆盖属性统计） |
| 动画轨道 | 0 |
| Theme 应用点 | `Bg/BGColor` 子树 + `Bg/Return` |

验收：

1. 在 1280×800 与 1600×1000 下截图，逐控件对照迁移前；控件矩形、字体、字号、颜色、描边、换行不得改变；
2. 设置开关、音量滑条、帧率选项与返回操作 PASS；
3. 场景内直接 `theme_override_*` 为 0，或逐项登记例外；
4. 无未引用 subresource 遗留，场景加载 0 ERROR / 0 WARNING；
5. `theme_override_audit.py --check` 通过，且直接属性计数下降；
6. 试点不通过时回滚该场景，不进入 32-2。

## 8. 分批与验收边界

- 32-2 按 Label 密集、Button 密集、混合输入/列表、其余场景分批；每批先快照、再迁移、后验证。
- 32-3 补齐 `OptionButton`、`CheckBox`、`CheckButton`、`LineEdit`、`HSlider`、`Panel`、`PanelContainer`、`TabBar`、`PopupMenu`、`ItemList` 等类型。
- 32-4 建立例外清单，评估是否启用全局 Theme，退役旧 Theme，更新 `architecture.md`、`status.md` 与索引。
- 每批必须保留截图/控件转储与相关 `scene_probe_runner` 结果；共享 HUD/关卡 UI 变更追加 `level_1` 冒烟与 changed-only 回归。
- 阶段完成标准是“直接属性为 0 或全部登记例外”，不是“总数看起来接近 0”；动画轨道与动态调用单独报告。

## 9. 失败语义与不做

- Theme 路径缺失、类型不符、变体不存在：在加载/审计阶段明确失败；不得回退到旧内联样式或静默使用默认主题。
- 不为兼容旧场景长期保留两套 Theme；迁移完成即删除旧入口。
- 不做主题切换、换肤、字体替换、布局重排、动画时序修改或显示基线调整。
- 不把运行时品质色、血量色、奖励状态色迁入 Theme；这些继续由数据/脚本拥有。

## 10. 未决项（32-1 后冻结）

| 项 | 当前状态 | 出口 |
|:---|:---|:---|
| 基础 Theme 路径与现有 `backpack_action_theme.tres` 的合并方式 | 候选 `Scene/theme/bhyh_theme.tres` | 32-1 试点评审 |
| 最终变体名单与字体族映射 | 初始候选见 §4.2 | 32-1 截图对照后冻结 |
| 是否启用全局 `gui/theme/custom` | 默认不启用 | 32-4 全 UI 覆盖评审 |
| 动画轨道/脚本动态覆盖的最终例外清单 | 仅登记，未迁移 | 32-4 收口 |

## 11. 参考

- [`modernization_gap_matrix.md`](modernization_gap_matrix.md) §3.2 B1
- [`current-iteration.md`](../roadmap/current-iteration.md) §5C
- [`acceptance.md`](acceptance.md) L0~L3
- [`status.md`](status.md) 当前验证事实
