# Theme 与字体收敛盘点（Phase 27-0）

> **测量日期**：2026-11-05。
> **范围**：`source/Scene/theme/bhyh_theme.tres`、`source/Scene/theme/fz_cu_yuan_m03.tres`、`source/Scene/**/*.tscn`、`source/Script/**/*.gd` 与 `source/Font/`（本地完整素材工作区）。
> **定位**：现状事实与 Phase 27 收敛依据；不是完成度承诺，不替代 `ui_theme_contract.md`、`typography_tokens.md` 或 `status.md`。
> **边界**：`source/Font/` 为私有素材目录，公开仓库不包含；本页不记录本地绝对路径、二进制来源或授权文件内容。

## 1. 当前规模

| 指标 | 当前值 | 说明 |
|:---|---:|:---|
| Theme 变体 | 618 | 全部通过 `theme_type_variation` 使用；无直接属性覆盖 |
| Theme 属性 | 3,218 | `bhyh_theme.tres` 183,597 字节 |
| Theme 子资源 | 54 | 45 个 `StyleBoxFlat`、7 个 `StyleBoxTexture`、1 个 `StyleBoxLine`、1 个 `StyleBoxEmpty` |
| 场景 Theme 引用 | 1,117 | `theme_override_audit` 统计 |
| `theme_type_variation` 节点引用 | 1,418 | 616 个不同变体被场景直接引用 |
| 动态 `add_theme_*` | 385 处 / 41 文件 | 不区分 font/size/color/stylebox |
| 字体文件（顶层） | 13 个 / 80,827,070 字节 | 不含 `Font/zmws`、`Font/zmws_bmfont` 子目录 |
| Theme 引用字体资产 | 10 个 / 68,246,521 字节 | 含默认 `FontVariation` 的主字体与 fallback |

## 2. 变体结构

### 2.1 基类分布

| 基类 | 变体数 |
|:---|---:|
| `Label` | 368 |
| `Button` | 55 |
| `VBoxContainer` | 45 |
| `HBoxContainer` | 41 |
| `LineEdit` | 15 |
| `MarginContainer` | 14 |
| `CheckBox` | 11 |
| `GridContainer` | 11 |
| `MenuActionButton` | 9 |
| `PanelContainer` | 6 |
| 其他 | 43 |

`Label` 占 59.5%；前四类容器/文字基类合计 509 个，说明大量变体是“布局别名”或“文字别名”，而不是独立控件族。

### 2.2 继承深度

| 深度 | 变体数 | 说明 |
|:---|---:|:---|
| 1 | 586 | 直接继承原生控件或已有变体；没有二次语义层 |
| 2 | 30 | 有中间基类 |
| 3 | 2 | 最深链 |

当前 Theme 主要靠“每个控件一个变体 + 重复写字体/字号/颜色”维持，而不是“少量语义基类 + 变体只覆盖差异”。`SettingsButtonSmall`、`SettingsButtonTiny` 只作为基类出现，没有场景直接引用；其余 616 个变体均被直接引用。

### 2.3 重复度

按“基类、字体、字号、字体色、描边色、描边宽度、五个 Button 状态 StyleBox”组成签名：

- **49 个重复签名组**，覆盖 **239 个变体**；
- 最大重复组包含 45 个容器变体（`SettingsGroup`、`EquipmentStatGroup`、`TowerContent` 等），它们的属性完全相同；
- 第二组包含 41 个行布局变体（`TowerRow`、`SkillGridRow`、`ShopSearchRow` 等），第三组 14 个 Margin 变体，第四组 11 个 Grid 变体。

这不是 239 个视觉角色，而是 239 个“名字不同、值相同”的别名。后续可以保留变体名以避免冻结名迁移，但应把共享属性上移到语义基类，并让变体只声明差异。

## 3. 字号与颜色

### 3.1 字号

- 有显式 `font_sizes/font_size` 的变体：391；
- 使用继承/默认字号的变体：227；
- 当前实际字号值：31 种；
- token 允许字号：10、12、14、16、18、20、24、28、32、36、40、50、76、100（14 种）；
- **111 个变体使用 17 种 off-token 字号**。

| off-token 字号 | 变体数 |
|:---|---:|
| 25 | 33 |
| 17 | 18 |
| 30 | 15 |
| 22 | 10 |
| 15 / 26 / 35 | 各 5 |
| 19 | 4 |
| 13 / 21 | 各 3 |
| 23 / 27 / 29 | 各 2 |
| 9 / 31 / 33 / 38 | 各 1 |

主流字号仍是 20（67）、18（46）、24（41）、16（40）、14（34）、12（26）；字号体系并非完全失控，但“17/25/30”三档已经在大量变体中固化，必须通过最近 token 映射和截图验收处理，不能直接全局改值。

### 3.2 字体颜色

- 756 处字体色赋值（含 `font_color`、`font_hover_color`、`font_pressed_color`、`font_outline_color`、`font_shadow_color` 等）；
- **108 个不同颜色值**；
- `theme_token_audit` 的 token 集合外仍有 **79 处**，大多只出现一次；
- 高频值：黑 254、白 138、黄 79、红 27、浅金 21、橙 16。

重复度低、一次性颜色多，说明颜色是逐面板复制出来的，而不是语义角色。Phase 27 应先冻结新增（已由 `theme_token_audit` 执行），再按“文字主/次/弱、金/橙/绿/红、描边/阴影”收敛，不按每个面板建立新颜色。

## 4. 字体资产

### 4.1 Theme 字体角色

| Theme 资源 | 变体数 | 文件大小 | 现状 |
|:---|---:|---:|:---|
| 默认 `FontVariation` + 显式 `font_fz_cu_yuan_m03`（FZCuYuan-M03 + 微软雅黑 fallback） | 206 + 118 | 26,761,588 | 默认字体 206 个变体 + 显式引用同一字体资源 118 个变体；fallback 只覆盖默认链 |
| `font_main`（文征明小楷） | 56 | 12,674,434 | 面板/设置/商城/技能 |
| `font_hk`（华康宋体 W3） | 121 | 2,932,088 | 公告、怪物帮助、数值 |
| `font_return`（华康海报 W12） | 52 | 2,615,307 | 主菜单/返回/公告按钮 |
| `font_hy`（汉仪竹字美心） | 48 | 2,585,277 | 公告标题/副标题 |
| `font_meng`（孟丽桃花） | 11 | 4,064,749 | 装备图鉴强调 |
| `font_wo`（独山月） | 2 | 13,070,587 | 极少数文字 |
| `font_194_song_ti` | 2 | 45,403 | 极少数文字 |
| `font_jin_qiao`（金桥简中圆） | 2 | 3,497,088 | 极少数文字 |

主题实际加载 10 个字体文件（8 个 FontFile + 主字体与 fallback 2 个文件），合计约 68.2 MB。`font_wo` 用 13 MB 只服务 2 个变体，`font_main` 用 12.7 MB 服务 56 个变体，`font_jin_qiao`/`font_194` 各自只服务 2 个变体；这是当前最明显的资源与视觉一致性问题。

### 4.2 未引用字体资产

- `source/Font/i_pix_zhong_wen_xiang_su_zi_ti.ttf`（2,879,513 字节）
- `source/Font/jin_qiao_fan_li_shu.ttf`（5,410,904 字节）
- `source/Font/jin_qiao_jian_cu_hei.ttf`（4,290,132 字节）
- `source/Font/zmws/ttf/fzy4jw.ttf`（3,032,194 字节）
- `source/Font/zmws_bmfont/` 下 BMFont 资源当前在 `Scene`/`Script` 中无路径引用。

未引用不等于可立即删除：需要先核对动态路径、外部导入脚本、授权与回滚归档。Phase 27-5 才允许在证据齐全后移除或归档。

### 4.3 动态字体与覆盖

- `add_theme_font_override`：34 处 / 8 文件；
- `add_theme_font_size_override`：52 处 / 13 文件；
- `add_theme_color_override`：110 处 / 25 文件；
- `add_theme_stylebox_override`：53 处 / 9 文件；
- 脚本直接 `preload/load` 字体：9 处；`Global.add_font_instance` 调用：4 处（公告、Boss 信息、怪物帮助）。

这些调用绕过了 Theme 变体，是“主题已经统一、运行时仍各写各的”的主要来源。静态角色应回到 Theme 变体；只有数据驱动/运行时生成的控件保留 token 化覆盖。

## 5. 已完成的收敛

| 批次 | 结果 |
|:---|:---|
| Phase 32 | 唯一 Theme；静态直接 `theme_override_*` 0；旧 Theme 退役；618 变体冻结 |
| P0 字体覆盖 | FZCuYuan 同族完整版 + 微软雅黑 fallback；135 场景 / 790 中文节点 / 0 缺字 |
| P2-1~P2-10 | 字号、描边、文字色、Button 族、自绘菜单表面色逐批 token 化；`theme_token_audit` 618/0 |
| P2-11 | 输入光标/选区统一；main_menu 动态裸色清零；新增 `ui_surface_token_audit.py` 与基线 |
| Phase 27-1 | `ui_theme_tokens.json` 成为文字/表面 token、受管 Theme 输入属性、默认字体与 Theme 审计集合的单一来源；`convert_ui_theme_tokens.py --check` 进入契约门禁 |

## 6. 主要风险

1. **双写漂移**：Theme 值与 `UiColorTokens`/`UiSurfaceTokens` 值分别手写，缺少生成或全量一致性校验；P2 已出现过类名损坏被门禁发现的情况。
2. **冻结基线掩盖存量**：`theme_token_audit` 允许既有 111 个 off-token 字号和 79 个 off-token 字体色；它防止新增，不代表已收敛。
3. **动态覆盖绕过 Theme**：385 处 `add_theme_*` 中大量是静态角色，导致同一视觉角色在 Theme 与脚本中各有一份。
4. **字体资源成本**：约 68 MB 字体随 Theme 引用；少数族只服务 1~2 个变体，且部分无显式 fallback。
5. **静态覆盖不等于动态覆盖**：`font_coverage_audit` 只检查 `.tscn` 静态文本；公告、Boss 信息等动态文本依赖运行时字体链。
6. **资产授权**：字体为私有素材，公开仓库不包含；任何删除、子集化或再分发都必须先完成授权与回滚证据。

## 7. 目标结构

### 7.1 单一 token 源

Phase 27-1 已建立 `scripts/ui_theme_tokens.json`：字号、语义色、字体角色、受管 Theme 属性与 Theme 审计集合的唯一来源。构建期 `scripts/convert_ui_theme_tokens.py` 负责：

- 生成 `UiColorTokens` / `UiSurfaceTokens`；
- 回写 Theme 的受管属性（默认字体与输入光标/选区/占位）；
- `--check` 逐字比较生成结果，发现 Theme/脚本常量漂移时失败。

首期只管理共享输入/字体值与 token 审计集合，不重排 618 个变体；字号、全量颜色与 StyleBox 的收敛仍按 27-2~27-4 分批进行。

### 7.2 语义层级

保留 618 个冻结变体名，但把结构改为：

```text
原生控件
  └── 语义基类（如 UiLabelBody / UiLabelTitle / UiButtonText / UiPanel）
        └── 现有变体（只声明差异）
```

优先合并 49 个重复签名组；容器别名可只保留布局属性，文字/颜色继承语义基类。目标是减少总属性数与重复值，而不是改场景中的变体名。

### 7.3 字体角色

目标 4 个运行角色 + 1 个 fallback：

| 角色 | 用途 | 目标 |
|:---|:---|:---|
| `body` | 默认正文/表单/说明 | FZCuYuan-M03 + 显式 fallback |
| `ui` | 面板/按钮/列表 UI | 从 `font_main` 等现有族中择一 |
| `display` | 标题/返回/公告主标题 | 从 `font_return`/`font_hy` 中择一 |
| `accent` | 强调/图鉴/少量装饰 | 从 `font_hk`/`font_meng` 中择一 |
| `fallback` | 缺字兜底 | 保留现有一致性策略，不新增无授权字体 |

`font_wo`、`font_194`、`font_jin_qiao` 等低频族先映射到上述角色，截图通过后再退役；未引用资产先归档，不直接删除。

### 7.4 字号与颜色

- 字号以 10/12/14/16/18/20/24/28/32/36 为常规标尺，40/50/76/100 仅战斗/数字；
- 颜色以 `text_primary/secondary/dim`、`gold/orange/green/red`、`ink/outline` 等语义角色为入口；
- 新增字号、颜色、字体或 StyleBox 必须先进入 token 源，再由 Theme 使用。

### 7.5 动态覆盖

- 静态角色：改用 Theme 变体，删除对应 `add_theme_*_override`；
- 数据驱动角色：只允许从 `UiColorTokens`/`UiSurfaceTokens` 取值；
- 审计：`ui_surface_token_audit` 继续扫描 StyleBox 与 main_menu；Phase 27-6 增加动态覆盖计数基线，禁止新增未登记覆盖。

## 8. 验收指标

| 指标 | 当前 | Phase 27 出口 |
|:---|---:|---:|
| off-token 字号变体 | 111 | 0 |
| off-token 字体色赋值 | 79 | 0 |
| 重复签名组 | 49（239 变体） | ≤10 组，且仅容器别名 |
| Theme 属性总数 | 3,218 | ≤2,000 |
| Theme 引用字体资产 | 10 个 / 68.2 MB | ≤6 个；未引用字体为 0 |
| 静态主题覆盖 | 0 | 0 |
| 动态覆盖 | 385 处 / 41 文件 | 静态角色覆盖为 0；数据驱动覆盖全部 token 化并登记 |
| 字体覆盖 | 135 场景 / 790 节点 / 0 缺字 | 保持 0；动态文本增加样本 |
| 视觉 | 1280×800 / 1600×1000 基线 | 每批截图 + 控件几何对照 |

## 9. 参考

- [`ui_theme_contract.md`](ui_theme_contract.md)
- [`typography_tokens.md`](typography_tokens.md)
- [`status.md`](status.md)
- [`current-iteration.md`](../roadmap/current-iteration.md) Phase 27
- [`acceptance.md`](acceptance.md)
