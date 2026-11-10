# Typography Token 源与生成/消费

> 本页说明 token 的机器事实源、生成目标与审计消费者；不复制 token 数值表、字体角色规则、当前门禁计数或历史批次。

## 唯一机器事实源

[`scripts/ui_theme_tokens.json`](../../scripts/ui_theme_tokens.json) 是 UI 文字色、表面色、字号审计集合、Theme 字体色 palette、字体角色映射、默认字体及受管 Theme 属性的机器事实源。生成器同步它拥有的产物；审计配置由对应脚本直接读取。不要手改生成的 GDScript 常量或生成器管理的 Theme 属性。字体角色选择与组件矩阵见 [`ui_typography_contract.md`](../standards/ui_typography_contract.md)，Theme 覆盖约束见 [`ui_theme_contract.md`](ui_theme_contract.md)。

| JSON 字段 | 生成或消费位置 | 责任 |
|:---|:---|:---|
| `text_tokens` | [`UiColorTokens`](../../source/Script/base/ui_color_tokens.gd) | 脚本动态 UI 的语义文字色 |
| `surface_groups` | [`UiSurfaceTokens`](../../source/Script/base/ui_surface_tokens.gd) | 脚本自绘表面、边框、遮罩与输入配色 |
| `theme_audit.font_sizes`、`script_font_sizes` | [`UiFontSizes`](../../source/Script/base/ui_font_sizes.gd) | 生成脚本字号常量；其中 `theme_audit.font_sizes` 也是 Theme 字号审计集合 |
| `theme_font_colors`、`theme_audit.outline_sizes`、`theme_audit.button_token_bases` | [`theme_token_audit.py`](../../scripts/theme_token_audit.py) | 审核 Theme 显式字号/字体色、新增或改写的描边及 Button 基类 |
| `font_roles` | [`font_role_audit.py`](../../scripts/font_role_audit.py) | 读取角色 ID 与基础字体映射，并核对 Theme 角色包装的基础字体 |
| `default_font`、`theme_only`、`theme_properties` | [`convert_ui_theme_tokens.py`](../../scripts/convert_ui_theme_tokens.py) → [`bhyh_theme.tres`](../../source/Scene/theme/bhyh_theme.tres) | 解析受管引用并生成/校验指定默认字体和 Theme 属性 |

`theme_token_audit.py` 审计 Theme 变体上的显式字号和八类字体色；新建变体的描边与既有变体被改写的描边须在允许集合内，新增 Button 变体须满足登记的基类约束。`theme_token_baseline.json` 是迁移基线，不是 token 数值的来源。

## 生成与漂移判据

```bash
python scripts/convert_ui_theme_tokens.py --write
python scripts/convert_ui_theme_tokens.py --check
python scripts/theme_token_audit.py --check
```

`convert_ui_theme_tokens.py --write` 从 JSON 生成三份脚本 token 类，并回写 Theme 中声明的受管属性；`--check` 检查生成类与受管属性是否符合源文件。`theme_token_audit.py --check` 独立校验 Theme 中的有效字号、字体色、描边和 Button 基类。完整门禁归属见 [`acceptance.md`](acceptance.md)；最近验证快照见 [`status.md`](status.md)。
