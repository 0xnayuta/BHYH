# Theme 与字体事实清单

> **类型**：当前事实（Current）
> **来源**：Phase 27-0~27-7（2026-11-05）；计数以 `theme_variant_audit`、`font_role_audit`、`font_coverage_audit`、`ui_dynamic_theme_audit` 为准。
> **范围**：`source/Scene/theme/bhyh_theme.tres`、`source/Scene/theme/fz_cu_yuan_m03.tres`、`source/Scene/**/*.tscn`、`source/Script/**/*.gd` 与 `source/Font/`（本地完整素材工作区）。
> **定位**：只记录字体资产、角色映射、计数与审计事实；不定义字体选择规则，不复制批次流水。
> **边界**：`source/Font/` 为私有素材目录，公开仓库不包含；本页不记录本地绝对路径、二进制来源或授权文件内容。

## 1. 当前规模

| 指标 | 当前值 | 说明 |
|:---|---:|:---|
| Theme 变体 | 734 | 618 个冻结业务变体 + 112 个 `Semantic*` 基类 + `SetMenuHintLabel` / `SetMenuActionButtonGroup` / `SkillHeaderLabel` / `ChooseMusicButton` |
| Theme 属性 | 1,788 | 27-0 为 3,218；27-4 删除 402 个原生默认冗余属性；后续字体角色与弹窗布局增加边界属性 |
| Theme 子资源 | 36 | 27-0 为 54；27-3 后 47；27-4 跨角色合并 47→36；均为 `StyleBoxFlat`/`StyleBoxTexture`/`StyleBoxLine`/`StyleBoxEmpty` |
| 场景 Theme 引用 | 1,116 | `theme_override_audit` 统计 |
| `theme_type_variation` 节点引用 | 1,419 | 619 个不同变体被场景直接引用 |
| 动态 `add_theme_*` | 352 处 / 41 文件 | 静态字面角色 0；分类见 `ui_dynamic_theme_audit.py` |
| 字体文件（顶层） | 4 个 / 78,490,604 字节（约 78.49 MB） | FZCuYuan M03、msyh fallback、LXGW WenKai Regular/Medium；不含 `Font/zmws`、`Font/zmws_bmfont` 子目录 |
| Theme 引用字体资产 | 4 个 FontVariation 资源 / 4 个文件 | `body` + msyh fallback、`ui`、`display`、`accent`；各角色均有显式回退链 |

## 2. 变体结构

### 2.1 语义基类

27-4 新增 **112 个 `Semantic*` 基类**（27-4 的 103 个 + 27-6 的 9 个字体角色变体），按原生根类型分树：Label、Button、Container、Input、Panel、List 等；Label 与 Button 不共享基类。具体基类分布以 `theme_variant_audit` 为准，不在本页复制静态快照。

### 2.2 继承深度

语义基类自身最深 **8 层**；冻结叶变体最多再深 2 层。`theme_token_audit` 沿 `base_type` 链解析有效 Theme 项，继承值不能逃逸字号/颜色审计。

### 2.3 重复度

27-4 按“基类、字体、字号、字体色、描边色、描边宽度、五个 Button 状态 StyleBox”组成的有效签名合并：

- 精确有效签名合并 **72 个重复组 / 135 个变体**；
- **189 个纯别名**（无自有 Theme 项，继承已有变体/基类）；
- **429 个独立变体**；
- 当前独立变体重复签名组 **10**（契约上限 ≤10；27-4 为 3，27-5 为 5，P2 字体角色批次后为 10）。

冻结变体名 618/618 保留；场景引用未改。

## 3. 字号与颜色

### 3.1 字号

- 有显式 `font_sizes/font_size` 的变体：**391**；
- 使用继承/默认字号的变体：227；
- token 允许字号：10、12、14、16、18、20、24、28、32、36、40、50、76、100（14 种）；
- **off-token 字号 0**。

当前显式字号分布：10:4、12:29、14:34、16:63、18:46、20:84、24:81、28:23、32:12、36:10、40:2、50:1、76:1、100:1。

`theme_token_audit` 强制所有当前字号落在 token 内；新增字号必须先进入 token 源。

### 3.2 字体颜色

- 756 处字体色赋值（`font_color`、`font_hover_color`、`font_pressed_color`、`font_outline_color`、`font_shadow_color` 等）；
- 使用 **35 个实际值 / 37 个语义 palette**；
- 8 类字体色属性全部由 `theme_token_audit` 强制校验；
- **off-token 字体色 0**。

## 4. 字体资产

### 4.1 当前 Theme 字体角色

| 角色 | Theme 资源 | 文件 | 有效变体 |
|:---|:---|:---|---:|
| `body` | 默认 `FontVariation` → `font_body` | `fz_cu_yuan_m03.ttf` + `msyh_semibold.ttc` fallback | 343 |
| `ui` | `font_ui.tres` FontVariation | LXGW WenKai Regular → body fallback | 154 |
| `display` | `font_display.tres` FontVariation | FZCuYuan M03 → body fallback | 112 |
| `accent` | `font_accent.tres` FontVariation | 霞鹜文楷 Medium → `font_ui` fallback | 125 |

角色选择与组件映射见 [`ui_typography_contract.md`](../standards/ui_typography_contract.md)；本节只保留当前资源事实。

### 4.2 未引用字体资产与边界

- 当前 Theme **无未引用字体资源**；4 个 FontVariation 角色均被使用；
- 27-7 已删除 8 个无运行时引用的顶层字体及 `.import`，回收 **35,843,653 字节（约 35.84 MB）**；
- 保留 `source/Font/zmws/ttf/fzy4jw.ttf` 与 `source/Font/zmws_bmfont/`（排除项）；
- 删除回滚副本保存在工作区外；私人素材仓已提交删除，公共仓无二进制；
- 清单与保留策略见 [`font_retirement_manifest.json`](../../scripts/font_retirement_manifest.json)。

### 4.3 动态字体与覆盖

- 动态 `add_theme_*`：**352 处 / 41 文件**；
- 分类：static **0** / token **173** / data **43** / layout **96** / dynamic_style **40**；
- 动态样本 **5** 个（公告、Boss 信息、怪物帮助、伤害数字、宠物面板），`font_coverage_audit --check` 同时校验；当前缺字样本 **0**；
- 静态字体覆盖：135 个显式绑定 Theme 的场景 / 788 个中文文本节点 / **0 缺字**。

静态角色必须使用 Theme 变体；只有数据驱动/运行时生成的控件保留 token 化覆盖。新增动态调用必须登记分类并更新基线。

## 5. 当前结构

### 5.1 单一 token 源

`scripts/ui_theme_tokens.json` 是字号、语义色、字体角色、受管 Theme 属性与 Theme 审计集合的唯一来源。构建期 `scripts/convert_ui_theme_tokens.py` 负责：

- 生成 `UiColorTokens` / `UiSurfaceTokens`；
- 回写 Theme 的受管属性（默认字体与输入光标/选区/占位）；
- `--check` 逐字比较生成结果，发现 Theme/脚本常量漂移时失败。

当前受管内容：39 个文字 token、6 组表面 token、37 个语义字体色、10 项受管 Theme 属性、0 漂移。

### 5.2 语义层级

保留 618 个冻结变体名，结构为：

```text
原生控件
  └── 语义基类（112 个 Semantic*，按根类型分树）
        └── 冻结变体（只声明差异）
```

27-4 合并 72 个精确重复组 / 135 个变体，并以 189 个纯别名承接共享属性；场景中的 618 个冻结变体名保持不变。

### 5.3 字体角色

4 个运行角色 + 1 个 fallback，资源与有效变体见 §4.1：

- `body`：默认正文/表单/说明；
- `ui`：面板/按钮/列表 UI；
- `display`：标题/返回/公告主标题；
- `accent`：强调/图鉴/少量装饰；
- fallback：缺字兜底与 body 回退。

角色选择、组件矩阵与字号边界见 [`ui_typography_contract.md`](../standards/ui_typography_contract.md)；本文只记录资源事实。

### 5.4 字号与颜色

- 字号以 10/12/14/16/18/20/24/28/32/36 为常规标尺，40/50/76/100 仅战斗/数字；
- 颜色以 `text_primary/secondary/dim`、`gold/orange/green/red`、`ink/outline` 等语义角色为入口；
- 新增字号、颜色、字体或 StyleBox 必须先进入 token 源，再由 Theme 使用。

### 5.5 动态覆盖

- 静态角色：字面静态覆盖 0；字体角色使用 `Semantic*` 变体，字号/颜色使用 `UiFontSizes`/`UiColorTokens`；
- 数据驱动角色：只允许从 `UiColorTokens`/`UiSurfaceTokens` 取值；
- 审计：`ui_dynamic_theme_audit.py` 分类 static/tokenized/data/layout/dynamic_style；`ui_surface_token_audit` 扫描 StyleBox 与 main_menu；禁止新增未登记覆盖。

## 6. 当前指标与上限

| 指标 | 当前 | 契约上限 |
|:---|---:|---:|
| off-token 字号变体 | 0 | 0 |
| off-token 字体色赋值 | 0 | 0 |
| 独立重复签名组 | 10 | ≤10 |
| StyleBox 子资源 | 36 | ≤36 |
| Theme 属性总数 | 1,788 | ≤2,000 |
| Theme 字体资产 | 4 个文件 | ≤6；Theme 未引用资源为 0 |
| 静态主题覆盖 | 0 | 0 |
| 动态覆盖 | 352 处 / 41 文件 | 字面静态角色 0；token/data/layout/dynamic_style 已登记 |
| 字体覆盖 | 135 场景 / 788 节点 / 0 缺字 | 保持 0；动态文本增加样本 |
| 视觉基线 | 1280×800 / 1600×1000 | 每批截图 + 控件几何对照 |

指标以 `theme_variant_audit`、`theme_token_audit`、`font_role_audit`、`font_coverage_audit`、`ui_dynamic_theme_audit` 的输出为准；当前门禁结果见 [`status.md`](status.md)。

## 7. 当前边界

1. **未受管值**：token 覆盖受管输入/默认字体、字号、8 类字体色与 StyleBox 精确重复；618 变体的其余属性仍直接写在 Theme 中，扩面需单独评审。
2. **StyleBox 上限**：36 个已到契约上限；跨色族合并会改变色相、圆角或焦点边框，不再强行合并。
3. **动态覆盖冻结**：352 处已分类并冻结；新增动态调用必须进入 token/data/layout/dynamic_style 分类并更新基线。
4. **字体授权与子集化**：字体为私有素材；删除、子集化或再分发必须先完成授权与回滚证据；公开仓库不包含字体文件。
5. **静态覆盖不等于真实动态数据**：字体覆盖审计包含 5 个动态样本；内容新增时需复用样本机制，不能只依赖静态扫描。
6. **计数时点**：本页数字与 `status.md` 同步更新；不复制历史批次计数，历史见 [`../archive/iteration_27_theme_font_convergence.md`](../archive/iteration_27_theme_font_convergence.md)。

## 8. 关联

- [`ui_typography_contract.md`](../standards/ui_typography_contract.md)：字体角色、组件矩阵与字号边界
- [`ui_theme_contract.md`](ui_theme_contract.md)：Theme 资源、变体命名与覆盖边界
- [`typography_tokens.md`](typography_tokens.md)：字号、颜色、描边与 Button token
- [`../archive/iteration_27_theme_font_convergence.md`](../archive/iteration_27_theme_font_convergence.md)：Phase 27 完整批次与验证
- [`../archive/iteration_32_ui_theme.md`](../archive/iteration_32_ui_theme.md)：Phase 32 单一 Theme 与变体冻结
- [`status.md`](status.md)：当前门禁与验证基线

