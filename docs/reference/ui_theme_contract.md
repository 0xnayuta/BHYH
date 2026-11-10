# UI Theme 契约

> **范围**：`source/Scene/**/*.tscn` 的 Theme 绑定、`theme_type_variation` 与 Theme 覆盖边界。字体角色选择以 [`ui_typography_contract.md`](../standards/ui_typography_contract.md) 为准；token 数值和生成/消费关系见 [`typography_tokens.md`](typography_tokens.md)。
> **依据**：[ADR-003](../decisions/ADR-003-modern-godot-design-with-legacy-exceptions.md)、[ADR-005](../decisions/ADR-005-no-compatibility-or-fallback-layers.md)、[ADR-016](../decisions/ADR-016-display-canvas-window-and-hud-baseline.md)、[ADR-021](../decisions/ADR-021-project-wide-target-architecture.md)。

## 唯一 Theme 与所有权

- `source/Scene/theme/bhyh_theme.tres` 是唯一正式 Theme；`project.godot` 不设置全局 `gui/theme/custom`，使用显式节点/场景绑定。不得恢复或新增平行 Theme、Theme Manager 或相关 Autoload。
- Theme 承载静态、可复用的 UI 样式。运行时不得把实例状态写回共享 Theme，也不得为控件实例深复制 Theme。
- 每个场景变体必须来自 `bhyh_theme.tres` 中已登记的 `theme_type_variation`。名称使用 `PascalCase` 并按可复用角色组织；冻结变体不静默重命名或删除。新增变体需评审，并遵循既有 `Semantic*` 基类与 token 基类规则。
- 一次性局部样式只允许作为有理由的场景例外，不得推广为新的通用样式。Theme 使用的字体素材授权与公开仓库边界见[字体规范](../standards/ui_typography_contract.md)。
- 运行时品质、HP/MP、奖励状态等数据驱动表现仍由数据和脚本拥有，不迁入静态 Theme。

## 静态、动画与动态覆盖边界

- **场景静态属性**：禁止新增未评审的 `theme_override_*`。当前保留项以 [`theme_override_baseline.json`](../../scripts/theme_override_baseline.json) 为准；`source/Scene/main_menu/map_0.tscn` 的图鉴按钮使用局部 StyleBox 例外。通过门禁不代表该基线冻结了属性值或免除视觉评审。
- **动画轨道**：`source/Scene/hittext/hit_text.tscn` 保留运行时命中、治疗等飘字动画所需的 Theme 覆盖；除此以外不得扩展动画 `theme_override_*`。同一基线按场景和数量登记例外。
- **脚本 `add_theme_*`**：仅供数据/状态驱动、token、布局或动态样式需要；静态字体角色不能在脚本中覆盖。可抽象为语义 token 的动态颜色、表面色和字号应使用对应生成 token 类，数据驱动业务状态仍由数据拥有。
- [`theme_override_audit.py`](../../scripts/theme_override_audit.py) `--check` 对照各场景和总量基线，拒绝新增带覆盖场景、直接属性/动画轨道数量增长、场景直接字体引用增长，以及动态调用总数/文件数/路径增长。该基线记录数量与路径，不校验现存局部 StyleBox 的资源值或样式含义。
- [`ui_dynamic_theme_audit.py`](../../scripts/ui_dynamic_theme_audit.py) `--check` 在动态调用无法解析、发现静态角色覆盖、调用总数超出基线、出现未登记文件或单文件调用数增长时失败。允许的动态调用分类与基线详见该脚本及 [`acceptance.md`](acceptance.md)。

## 结构门禁

[`theme_variant_audit.py`](../../scripts/theme_variant_audit.py) `--check` 保护冻结变体清单，检查继承成环和缺失的 StyleBox 子资源引用，并限制 Theme 属性数、StyleBox 数与有效重复签名组（上限分别为 2,000、36、10）。Theme 字号、字体色、描边和 Button 基类使用 [`typography_tokens.md`](typography_tokens.md) 所述 token 审计；所有门禁判据见 [`acceptance.md`](acceptance.md)。

变体审计校验冻结清单与 Theme 结构；这些 UI Theme 门禁不应被描述为逐一验证任意场景中的全部 `theme_type_variation` 名称。最近验证快照见 [`status.md`](status.md)。
