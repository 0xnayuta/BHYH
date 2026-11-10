# Theme 与字体资源映射

> 本页只记录当前 Theme 的字体包装资源与基础字体文件映射，以及不属于 Theme 角色的保留资产。角色用途与回退规则以[字体规范](../standards/ui_typography_contract.md)为准；资源 ID 与基础字体路径等机器映射以 [`scripts/ui_theme_tokens.json`](../../scripts/ui_theme_tokens.json) 为准。

## Theme 字体资源

[`bhyh_theme.tres`](../../source/Scene/theme/bhyh_theme.tres) 将下列资源声明为 `FontVariation`；包装文件中的 `base_font` 指向基础字体。回退关系由规范及包装资源负责，本表不复写。

| 角色 | Theme `ExtResource` ID | `FontVariation` 包装 | 基础字体文件 |
|:---|:---|:---|:---|
| `body` | `font_body`（`default_font`） | `font_body.tres` | `Font/fz_cu_yuan_m03.ttf` |
| `ui` | `font_ui` | `font_ui.tres` | `Font/lxgw_wen_kai_regular.ttf` |
| `display` | `font_display` | `font_display.tres` | `Font/fz_cu_yuan_m03.ttf` |
| `accent` | `font_accent` | `font_accent.tres` | `Font/lxgw_wen_kai_medium.ttf` |

## 其他保留字体资产

[`font_retirement_manifest.json`](../../scripts/font_retirement_manifest.json) 登记了不属于当前 Theme 角色映射的保留资产：`Font/zmws/ttf/fzy4jw.ttf` 与 `Font/zmws_bmfont/`。素材授权与仓库边界以[字体规范](../standards/ui_typography_contract.md)为准。

## 核查入口

- [`font_role_audit.py`](../../scripts/font_role_audit.py) `--check`：核对 Theme 变体字体角色、角色包装资源映射、直接字体引用与字号例外。
- [`font_coverage_audit.py`](../../scripts/font_coverage_audit.py) `--check`：核对已绑定 Theme 的静态文本与登记动态样本的字体覆盖，并拒绝未引用 Theme 字体资源。
- 门禁归属与判据见 [`acceptance.md`](acceptance.md)；最近验证快照见 [`status.md`](status.md)。

