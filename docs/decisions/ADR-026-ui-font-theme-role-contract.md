# ADR-026：UI 字体角色与 Theme 使用边界

- **状态**：Accepted；规范生效，存量迁移按例外清单分批完成
- **记录日期**：2026-11-06
- **关联**：ADR-003、ADR-005、ADR-006、ADR-015、ADR-016、ADR-020、ADR-021、ADR-024
- **规范**：[UI 字体角色与 Theme 使用边界契约](../standards/ui_typography_contract.md)

## 背景

项目已完成 Phase 27 的 Theme、字体角色和 P0/P1/P2 字体替换：运行时使用 `body`、`ui`、`display`、`accent` 四个字体角色，品牌字体不进入 Theme。实现事实记录在 `theme_font_inventory.md`、`ui_theme_contract.md`、`typography_tokens.md`，实际映射由 `bhyh_theme.tres` 与 `font_*.tres` 提供。

问题在于“有哪些字体、如何 fallback”已经有记录，但“哪个界面元素应该使用哪个角色”没有规范性入口：

- 角色表只存在于 Phase 27 盘点页，页头明确说明它不替代契约；
- `ui_theme_contract.md` 主要约束 Theme 资源、变体与静态覆盖，不定义字体选择；
- `typography_tokens.md` 管理字号、颜色、描边 token，不定义字体角色；
- 现有审计检查覆盖、token、变体与直接覆盖，不检查角色语义；
- 暂停菜单、装备属性、装备 tooltip 等界面存在跨角色混用，当前没有规则判断哪些是有意层级，哪些是历史残留。

如果继续把规则散落在 reference 页，角色边界会随阶段记录一起漂移。需要一份稳定、可评审、可迁移的标准。

## 决策

1. **新增规范性标准** `docs/standards/ui_typography_contract.md`，作为字体角色、Theme 变体、字号区间、fallback、例外和变更流程的单一规范源。
2. **运行时固定 4 个字体角色**：`body`、`ui`、`display`、`accent`；`FZRunYYSJW` 仅作为品牌/LOGO 字体，不进入 Theme。新增角色必须新增 ADR 并更新标准。
3. **角色优先于资源文件名**：`font_main` 对应 `accent`、`font_hk` 对应 `ui`、`font_return` 对应 `display`，默认字体对应 `body`；资源文件名是历史实现，不作为语义依据。
4. **默认使用 `body`**：只有阅读文本、标题/操作、短专名才分别使用 `ui`、`display`、`accent`。同一行标签与数值默认同角色，强调优先使用颜色、描边或字号，不新增第二个字体族。
5. **现有冻结变体不重命名、不静默换角色**。已知例外登记在标准 §7，按排版、装备面板、暂停菜单批次迁移；例外不是新代码先例。
6. **静态 UI 禁止直接字体引用、逐面板字体和静态 `add_theme_font_override`**。Theme 继续使用唯一资源、语义基类和显式节点绑定；脚本直接字体路径仅允许用于运行时拼接的富文本、动态列表或主题无法表达的生成内容，并必须使用角色对应文件与集中映射。
7. **现有 reference 只保留事实、实现与审计结果**，不重复角色选择规则；与本标准冲突时，角色选择以标准为准，计数与验证以 `status.md` 和审计脚本为准。
8. **角色语义审计已落地**：`scripts/font_role_audit.py` 接入 `contract_gate`，检查有效字体角色、包装/fallback、直接字体、宋体残留与字号例外；`font_role_baseline.json` 冻结存量例外。组件矩阵仍需人工评审与截图验证，审计通过不等同于视觉验收完成。

## 后果

- 角色选择有了稳定入口，新增 UI 不再依赖 Phase 27 历史页或反向推断资源名。
- 当前冻结变体保持视觉稳定；装备元数据、属性数值、菜单提示、12 px serif 等已知例外进入可追踪的迁移队列。
- `theme_font_inventory.md`、`ui_theme_contract.md`、`typography_tokens.md` 继续承担事实与审计职责，减少重复规范。
- 规范本身不改变代码、布局、字号或字体文件；迁移批次必须单独截图、几何对照和回归。
- 字体授权、私有素材边界与子集化策略不变；品牌字体仍不进入运行时 Theme。
- 角色语义审计已接入总门禁；当前存量字号例外只允许收紧，组件矩阵仍需人工评审。

## 备选方案

- **继续扩充 `ui_theme_contract.md`**：拒绝。该页是 Phase 32 的实现契约与阶段记录，已同时承担资源、变体和变更日志；把角色规则放进去会继续漂移。
- **把角色规则放进 `typography_tokens.md`**：拒绝。该页管理 token 值，不负责“元素 → 角色”的语义选择；两者变更频率不同。
- **把 Phase 27 盘点页提升为规范**：拒绝。该页明确是现状盘点，包含规模与阶段统计，不适合作为长期规则。
- **为每个面板维护字体说明**：拒绝。会产生第二套角色定义，无法跨面板复用。
- **立即重命名 `font_main`/`font_hk`/`font_return`**：暂不采用。重命名会扩大引用与 UID 影响面，先由标准固定语义，资源迁移另行立项。
- **只接受标准、不同步实现审计**：拒绝。角色语义审计已随字体角色批次实现，并通过 `contract_gate` 接入总门禁；没有审计的标准无法阻止新增漂移。

## 证据

- [UI 字体角色与 Theme 使用边界契约](../standards/ui_typography_contract.md)
- [Theme 与字体盘点（当前事实）](../reference/theme_font_inventory.md)
- [UI Theme 契约（Theme 实现与覆盖）](../reference/ui_theme_contract.md)
- [Typography Token（字号/颜色/描边）](../reference/typography_tokens.md)
- [显示基线 ADR-016](../decisions/ADR-016-display-canvas-window-and-hud-baseline.md)
- [视觉资产契约 ADR-020](../decisions/ADR-020-typed-visual-assets-and-streaming-lifecycle.md)
- `source/Scene/theme/bhyh_theme.tres`、`source/Scene/theme/font_main.tres`、`font_hk.tres`、`font_return.tres`
- `scripts/theme_override_audit.py`、`scripts/theme_token_audit.py`、`scripts/theme_variant_audit.py`、`scripts/font_coverage_audit.py`、`scripts/ui_dynamic_theme_audit.py`、`scripts/font_role_audit.py`、`scripts/font_role_baseline.json`
