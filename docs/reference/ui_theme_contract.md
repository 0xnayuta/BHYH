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
