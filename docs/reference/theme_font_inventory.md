# Theme 与字体收敛盘点（Phase 27-0）

> **测量日期**：2026-11-05（27-0 基线）；27-2 字号、27-3 颜色与 27-4 语义基类结果已追加。
> **范围**：`source/Scene/theme/bhyh_theme.tres`、`source/Scene/theme/fz_cu_yuan_m03.tres`、`source/Scene/**/*.tscn`、`source/Script/**/*.gd` 与 `source/Font/`（本地完整素材工作区）。
> **定位**：现状事实与 Phase 27 收敛依据；只记录字体资产、角色映射、计数与审计事实，不是完成度承诺，不定义字体选择规则。角色与 Theme 使用边界见 [`../standards/ui_typography_contract.md`](../standards/ui_typography_contract.md)；计数与验证仍以 `status.md` 和审计脚本为准。
> **边界**：`source/Font/` 为私有素材目录，公开仓库不包含；本页不记录本地绝对路径、二进制来源或授权文件内容。

## 1. 当前规模

| 指标 | 当前值 | 说明 |
|:---|---:|:---|
| Theme 变体 | 733（618 冻结 + 112 `Semantic*` 基类 + `SetMenuHintLabel` + `SetMenuActionButtonGroup` + `SkillHeaderLabel`） | 27-6 新增 9 个字体角色变体；27-7 新增 1 个设置菜单字体变体；P2.6 新增 1 个技能表头字体变体 |
| Theme 属性 | 1,784（帮助标题 P2.6 后） | 27-0 为 3,218；27-4 删除 402 个原生默认冗余属性；27-7 增加字体角色回退与边界属性 |
| Theme 子资源 | 36（27-4 后） | 27-0 为 54；27-3 后 47；27-4 跨角色合并 47→36，仍为 `StyleBoxFlat`/`StyleBoxTexture`/`StyleBoxLine`/`StyleBoxEmpty` |
| 场景 Theme 引用 | 1,116 | `theme_override_audit` 统计 |
| `theme_type_variation` 节点引用 | 1,419 | 617 个不同变体被场景直接引用 |
| 动态 `add_theme_*` | 352 处 / 41 文件（27-7 后） | 静态字面角色 0；分类见 `ui_dynamic_theme_audit.py` |
| 字体文件（顶层） | 4 个 / 78,490,604 字节（约 78.49 MB） | P2.1 后：FZCuYuan M03、msyh fallback、LXGW WenKai Regular/Medium；不含 `Font/zmws`、`Font/zmws_bmfont` 子目录 |
| Theme 引用字体资产 | 4 个 FontVariation 资源 / 4 个文件 | `body` + msyh fallback、`ui`、`display`、`accent`；各角色均有显式回退链 |

## 2. 变体结构

### 2.1 基类分布（27-4 后）

| 基类 | 变体数 |
|:---|---:|
| `HBoxContainer` | 28 |
| `Label` | 20 |
| `SemanticTextSize20` | 17 |
| `Control` | 17 |
| `VBoxContainer` | 16 |
| `SemanticTextFontHy` | 15 |
| `SemanticTextSize12` | 15 |
| `SemanticTextFontMain` | 14 |
| `SemanticControlFontHkOutlineWidth2Size24` | 12 |
| `MarginContainer` | 11 |
| `SemanticTextFontReturn` | 11 |
| `SemanticTextFontMainOutlineWidth1` | 10 |
| `MenuActionButton` | 9 |
| 其他 | 516 |

27-4 后 103 个 `Semantic*` 基类；27-6 新增 9 个字体角色变体，共 112 个基类；27-7 新增 1 个 `SetMenuHintLabel` 业务变体；其余 618 个为冻结业务变体。基类按原生根类分树，Label 与 Button 不共享基类。

### 2.2 继承深度（27-4 后）

| 深度 | 变体数 | 说明 |
|:---|---:|:---|
| 1 | 104 | 冻结变体直接继承原生控件 |
| 2 | 153 | 冻结变体 -> 一层语义基类 |
| 3 | 172 | 冻结变体 -> 两层语义基类 |
| 4 | 78 | |
| 5 | 40 | |
| 6 | 17 | |
| 7 | 34 | |
| 8 | 10 | |
| 9 | 8 | |
| 10 | 2 | 最深层为冻结叶变体 |

语义基类自身最深 8 层；冻结叶最多再多两层。

### 2.3 重复度

按“基类、字体、字号、字体色、描边色、描边宽度、五个 Button 状态 StyleBox”组成签名：

- **49 个重复签名组**，覆盖 **239 个变体**；
- 最大重复组包含 45 个容器变体（`SettingsGroup`、`EquipmentStatGroup`、`TowerContent` 等），它们的属性完全相同；
- 第二组包含 41 个行布局变体（`TowerRow`、`SkillGridRow`、`ShopSearchRow` 等），第三组 14 个 Margin 变体，第四组 11 个 Grid 变体。

这不是 239 个视觉角色，而是 239 个“名字不同、值相同”的别名。后续可以保留变体名以避免冻结名迁移，但应把共享属性上移到语义基类，并让变体只声明差异。

**27-4 结果（2026-11-05）**：新增 103 个 `Semantic*` 基类；精确有效签名合并 72 组 / 135 个变体；当前 189 个纯别名（无自有 Theme 项），429 个独立变体，独立变体重复签名组 **3**；冻结名 618/618 保留。

**27-5 结果（2026-11-05）**：低频字体合并后独立变体重复组为 **5**（仍 ≤10）；Theme 字体资产 10→5，静态/动态覆盖 0 缺字。

**27-6 结果（2026-11-05）**：新增 9 个 `Semantic*` 字体角色变体；脚本动态断言 299 条，静态字面角色 0。

**27-7 结果（2026-11-05）**：动态审计扩至 `source/**/*.gd` 并支持跨行调用；动态调用 352 条（Scene 53），其中 29 处字面字号/字体色 token 化；新增 `FONT_SIZE_8`、`TEXT_ZHENFA_PURPLE`、`TEXT_ZHENFA_ORANGE` 与 `SetMenuHintLabel`；直接字体引用 0。

## 3. 字号与颜色

### 3.1 字号（27-0 基线）

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

主流字号仍是 20（67）、18（46）、24（41）、16（40）、14（34）、12（26）；字号体系并非完全失控，但“17/25/30”三档已经在大量变体中固化。

**27-2 结果（2026-11-05）**：111 个 off-token 变体已分三批映射到 token（9→10、13→12、15/17→16、19/21/22→20、23/25/26→24、27/29/30→28、31/33→32、35/38→36）；当前显式字号 391 个，分布为 10:4、12:29、14:34、16:63、18:46、20:84、24:81、28:23、32:12、36:10、40:2、50:1、76:1、100:1，**off-token 字号 0**。`theme_token_audit` 已改为强制所有当前字号落在 token 内。

### 3.2 字体颜色

- 756 处字体色赋值（含 `font_color`、`font_hover_color`、`font_pressed_color`、`font_outline_color`、`font_shadow_color` 等）；
- **108 个不同颜色值**；
- `theme_token_audit` 的 token 集合外仍有 **79 处**，大多只出现一次；
- 高频值：黑 254、白 138、黄 79、红 27、浅金 21、橙 16。

重复度低、一次性颜色多，说明颜色是逐面板复制出来的，而不是语义角色。

**27-3 结果（2026-11-05）**：139 处 off-token 字体色赋值已收敛为 0；756 处赋值最终使用 35 个实际值，语义 palette 37 个（含 `TEXT_CYAN`、`TEXT_PURPLE`、`TEXT_VIOLET`、`OUTLINE_NIGHT`、`OUTLINE_WARM`）。8 类字体色属性全部由 `theme_token_audit` 强制校验。

## 4. 字体资产

### 4.1 Theme 字体角色（P2.6 后）

| 角色 | Theme 资源 | 文件 | 有效变体 |
|:---|:---|:---|---:|
| `body` | 默认 `FontVariation` → `font_body` | `fz_cu_yuan_m03.ttf` + `msyh_semibold.ttc` fallback | 343 |
| `ui` | `font_ui.tres` FontVariation | LXGW WenKai Regular → body fallback | 154 |
| `display` | `font_display.tres` FontVariation | FZCuYuan M03 → body fallback | 111 |
| `accent` | `font_accent.tres` FontVariation | 霞鹜文楷 Medium → `font_ui` fallback | 125 |

角色选择与组件映射见 [`ui_typography_contract.md`](../standards/ui_typography_contract.md)；本节只保留当前资源事实。

P1 时字体资产为 **5 个文件 / 约 44.98 MB**；P2 为 **5 个文件 / 约 76.06 MB**；P2.1 移除两款思源宋体并加入 LXGW Regular 后为 **4 个文件 / 约 78.49 MB**（后续单独子集化）。以下 P1/P2.x 段落中的 `font_main`/`font_hk`/`font_return` 等旧资源名属于历史记录；当前资源名见本节表格。P1 中 `font_hy`（55 个有效引用）、`font_meng`（13）、`font_wo`（2）、`font_jin_qiao`（2）映射到旧 `font_main`；`font_194_song_ti`（2）映射到旧 `font_hk`。脚本直接字体路径中的旧 `font_meng` 已改为旧 `font_main`。

**27-7 P1 结果**：为 `font_main`/`font_hk`/`font_return` 建立 FontVariation 回退链；`SynHelpBody`（12 px 长文本）由小楷改为宋体，HUD 名称/计时、角色自然属性、幻化操作等小楷功能文本改为 body；`CureTimesHint` 由海报体改为 body。字体角色边界调整未改变场景层级。

**27-7 P2 结果**：`ui` 改用 Source Han Serif CN Medium，`display` 改用 Source Han Serif CN SemiBold，`accent` 改用 LXGW WenKai Medium；`FZRunYYSJW` 仅用于 LOGO/活动，不进入 Theme。华康宋体、华康海报、文征明小楷已退役；Microsoft YaHei 保留为 body fallback。字体文件 5 / 76.06 MB，Theme 属性 1,744（P2 时点；当前计数以 `theme_variant_audit` 为准）。

**27-7 P2.1 结果**：`ui` 改为 LXGW WenKai Regular，`display` 改为 FZCuYuan M03，`accent` 保持 LXGW WenKai Medium，`body` 保持 FZCuYuan M03；移除 Source Han Serif 两个文件。Theme 字体资产 4 个资源 / 4 个文件；字体总量约 78.49 MB；E1–E4 字号/角色例外已清零；`MysteryShopTitle` 采用 body 12 px 解决侧栏 14 px 溢出。

**27-7 P2.6 结果**：技能界面安全子集迁 display；新增 `SkillHeaderLabel` 供五列表头使用，`SkillLabel` 保留给等级/描述数据；帮助标题 `HcHelpTitle`、`MosaicHelpTitle`、`MagicHelpTitle`、`LhhjHelpTitle`、`MonsterHelpTitle`、`MonsterHelpTitleLarge`、`ZhenFaHelpTitle` 迁 display。`font_role_audit` 733/0、`theme_token` 733/0、`theme_variant` 733 总变体/属性 1,784/重复组 10；`check_all` 9/9（43.46s）、`health_check` 6.58s / 0/0/0、`ui-factories` 32.86s、`level_1` 4 阶段 0/0/0；本次字体角色变更未重复全量回归，最近一次全量为 128/128 + 5 SKIP（565.3s）。

**27-7 P2.5 结果**：四个 FontVariation 包装统一为 `font_body.tres`、`font_ui.tres`、`font_display.tres`、`font_accent.tres`；同步 Theme ExtResource ID、角色映射、动态样本、退役清单与 token 基线。资源 UID 与实际 TTF 文件名保持不变；`font_role_audit` 732/0、`font_coverage` 4 资源/0 缺字、`theme_token` 732/0；`check_all` 9/9（35.95s）、`health_check` 5.73s / 0/0/0、`ui-theme` 7.32s、`ui-factories` 34.06s、`level_1` 4 阶段 0/0/0（27.21s）；全量回归 **128/128 + 5 SKIP（596.2s）**。

**27-7 P2.4 结果**：确认四个 body 10 变体均为固定小槽位微辅助文本（Buff 倒计时/次数、格位提示、`Max` 短后缀）；规范允许 body 10–11 微辅助，`font_role_baseline` 4→0。无 Theme 运行时变化，`check_all` **9/9（40.22s）**；全量回归沿用 P2.3 的 128/128 + 5 SKIP（346.4s）。

**27-7 P2.3 结果**：`AnnouncementHeading`、`EndStatsMoreInfo`、`GameNeedKnowTitle`、`LevelInfoTitle`、`SettingsTitle` 五个 36 px 标题与 `LijiText` 50 px 仪式标题迁 `display`；`font_role_baseline` 10→4，剩余 body 10 四条。`check_all` **9/9（46.72s）**；全量回归 **128/128 + 5 SKIP（346.4s）**。

**27-7 P2.2 结果**：优先将 body 24/28/32/36 的功能性数字/计时/短功能标签与 display 标题/操作分流，`GameInfoTitle`、`PelletTotalValue` 及 `ChoosePlayerRoleName` 的角色归属同步收敛；`BacisInfoNumber`、`ForgeSoulLabel`、`ShopHintLabel`、`ShopPageLabel`、`UserKeyTime` 以 body 覆盖保持功能性大号。`font_role_baseline` 43→10。双档代表场景截图与几何转储、`ui-theme` 8.38s、`ui-factories` 33.54s 通过；全量回归见 `status.md`。

### 4.2 未引用字体资产与边界

Theme 已无未引用字体资源；4 个 FontVariation 角色均被 `body`/`ui`/`display`/`accent` 使用。27-7 已按 `ASSET_CHANGE_CONTRACT.md` 删除此前无运行时引用的 8 个顶层字体及 `.import`，回收 **35,843,653 字节（约 35.84 MB）**：

- `194_song_ti.ttf`
- `aa_meng_li_tao_hua_dui_yue_yin_mianfeiziti_com.ttf`
- `aa_wo_du_shan_yue_shan_yue_du_wo_mianfeiziti_com.ttf`
- `hy_zhu_zi_mei_xin_ti_w.ttf`
- `i_pix_zhong_wen_xiang_su_zi_ti.ttf`
- `jin_qiao_fan_li_shu.ttf`
- `jin_qiao_jian_cu_hei.ttf`
- `jin_qiao_jian_zhong_yuan.ttf`

保留范围（用户指定的排除项）：

- `source/Font/zmws/ttf/fzy4jw.ttf`
- `source/Font/zmws_bmfont/` 下 BMFont 资源

删除回滚副本保存在工作区外；私人素材仓已提交删除，公共仓无二进制。清单与保留策略见 [`font_retirement_manifest.json`](../../scripts/font_retirement_manifest.json)。

### 4.3 动态字体与覆盖

- `add_theme_font_override`：34 处 / 8 文件；
- `add_theme_font_size_override`：52 处 / 13 文件；
- `add_theme_color_override`：110 处 / 25 文件；
- `add_theme_stylebox_override`：53 处 / 9 文件；
- 脚本直接 `preload/load` 字体：9 处；`Global.add_font_instance` 调用：4 处（公告、Boss 信息、怪物帮助）；
- 动态样本：5 个（公告、Boss 信息、怪物帮助、伤害数字、宠物面板），`font_coverage_audit --check` 同时校验；当前缺字样本 **0**。

这些调用绕过了 Theme 变体，是“主题已经统一、运行时仍各写各的”的主要来源。静态角色应回到 Theme 变体；只有数据驱动/运行时生成的控件保留 token 化覆盖。

## 5. 已完成的收敛

| 批次 | 结果 |
|:---|:---|
| Phase 32 | 唯一 Theme；静态直接 `theme_override_*` 0；旧 Theme 退役；618 变体冻结 |
| P0 字体覆盖 | FZCuYuan 同族完整版 + 微软雅黑 fallback；135 场景 / 790 中文节点 / 0 缺字 |
| P2-1~P2-10 | 字号、描边、文字色、Button 族、自绘菜单表面色逐批 token 化；`theme_token_audit` 618/0 |
| P2-11 | 输入光标/选区统一；main_menu 动态裸色清零；新增 `ui_surface_token_audit.py` 与基线 |
| Phase 27-1 | `ui_theme_tokens.json` 成为文字/表面 token、受管 Theme 输入属性、默认字体与 Theme 审计集合的单一来源；`convert_ui_theme_tokens.py --check` 进入契约门禁 |
| Phase 27-2 | 111 个 off-token 字号分三批映射到 token；off-token **111→0**；基线更新；截图/控件几何对照归档 |
| Phase 27-3 | 139 处 off-token 字体色收敛到 0（35 实际值 / 37 palette）；8 类字体色属性纳入审计；StyleBox 精确重复 **54→47**；跨色族 47→≤36 转入 27-4 |
| Phase 27-4 | 103 个语义基类；Theme 属性 **3,218→1,719**；StyleBox **47→36**；独立重复组 **3**；618 冻结名与场景引用不变；`theme_variant_audit.py` 接入门禁 |
| Phase 27-5 | 4 个字体角色 + fallback；Theme 字体资产 **10→5**（约 44.98 MB）；静态 135/790/0、动态样本 5/0 缺字；私有未引用字体保留边界登记 |

## 6. 主要风险

1. **未受管值仍手写**：受管输入/默认字体与 token 类已由 27-1 生成；618 变体的其余字号/颜色/StyleBox 仍直接写在 Theme 中，需继续扩大 token 覆盖并保留 `--check` 守卫。
2. **样式/颜色存量**：27-2/27-3 后字号与字体色均已强制在 token 内；27-4 后 StyleBox 36 个，27-5 后独立重复组 5，27-7 后静态字面动态覆盖 0。
3. **动态覆盖绕过 Theme**：352 处 `add_theme_*`（含 Scene 53 处）已分类；字面静态角色 0，剩余 token/data/layout/dynamic_style 均有基线。
4. **字体资源成本**：P2 后 Theme 加载 5 个文件 / 约 76.06 MB；思源宋体与霞鹜文楷体积较大，子集化必须单独立项并保留 OFL 保留字体名合规检查。
5. **静态覆盖不等于真实动态数据**：27-5 已加入 5 个动态样本；27-7 已覆盖公告、菜单、面板、输入与 HUD 代表场景的动态字体与几何检查，仍需在内容新增时复用样本机制。
6. **资产授权**：字体为私有素材，公开仓库不包含；任何删除、子集化或再分发都必须先完成授权与回滚证据。

## 7. 目标结构

### 7.1 单一 token 源

Phase 27-1 已建立 `scripts/ui_theme_tokens.json`：字号、语义色、字体角色、受管 Theme 属性与 Theme 审计集合的唯一来源。构建期 `scripts/convert_ui_theme_tokens.py` 负责：

- 生成 `UiColorTokens` / `UiSurfaceTokens`；
- 回写 Theme 的受管属性（默认字体与输入光标/选区/占位）；
- `--check` 逐字比较生成结果，发现 Theme/脚本常量漂移时失败。

首期只管理共享输入/字体值与 token 审计集合，不重排 618 个冻结变体；字号与字体色已分别于 27-2/27-3 收敛，StyleBox 精确重复与跨角色合并在 27-3/27-4 完成，语义基类见 §2。

### 7.2 语义层级

保留 618 个冻结变体名，但把结构改为：

```text
原生控件
  └── 语义基类（如 UiLabelBody / UiLabelTitle / UiButtonText / UiPanel）
        └── 现有变体（只声明差异）
```

27-4 已按精确有效签名合并 72 个重复组、135 个变体，并以 103 个语义基类承接共享属性；场景中的 618 个冻结变体名保持不变。

### 7.3 字体角色

目标 4 个运行角色 + 1 个 fallback：

| 角色 | 用途 | 目标 |
|:---|:---|:---|
| `body` | 默认正文/表单/说明 | FZCuYuan-M03 + 显式 fallback |
| `ui` | 面板/按钮/列表 UI | `font_ui.tres` |
| `display` | 标题/返回/公告主标题 | `font_display.tres` |
| `accent` | 强调/图鉴/少量装饰 | `font_accent.tres` |
| `fallback` | 缺字兜底 | 保留现有一致性策略，不新增无授权字体 |

`font_wo`、`font_194`、`font_jin_qiao` 等低频族先映射到上述角色，截图通过后再退役；未引用资产先归档，不直接删除。

### 7.4 字号与颜色

- 字号以 10/12/14/16/18/20/24/28/32/36 为常规标尺，40/50/76/100 仅战斗/数字；
- 颜色以 `text_primary/secondary/dim`、`gold/orange/green/red`、`ink/outline` 等语义角色为入口；
- 新增字号、颜色、字体或 StyleBox 必须先进入 token 源，再由 Theme 使用。

### 7.5 动态覆盖

- 静态角色：字面静态覆盖 0；字体角色使用 `Semantic*` 变体，字号/颜色使用 `UiFontSizes`/`UiColorTokens`；
- 数据驱动角色：只允许从 `UiColorTokens`/`UiSurfaceTokens` 取值；
- 审计：`ui_dynamic_theme_audit.py` 分类 static/tokenized/data/layout/dynamic_style；`ui_surface_token_audit` 继续扫描 StyleBox 与 main_menu；禁止新增未登记覆盖。

## 8. 验收指标

| 指标 | 当前 | Phase 27 出口 |
|:---|---:|---:|
| off-token 字号变体 | 0（27-0 基线 111） | 0 |
| off-token 字体色赋值 | 0（27-3 结果） | 0 |
| 独立重复签名组 | 9（P2.3 后） | ≤10 |
| StyleBox 子资源 | 36（27-4 结果） | ≤36 |
| Theme 属性总数 | 1,775（P2.3 后） | ≤2,000 |
| Theme 字体资产 | 4 个文件（P2.1 结果） | ≤6；Theme 未引用资源为 0 |
| 静态主题覆盖 | 0 | 0 |
| 动态覆盖 | 352 处 / 41 文件（27-7 结果） | 字面静态角色 0；token/data/layout/dynamic_style 已登记 |
| 字体覆盖 | 135 场景 / 788 节点 / 0 缺字 | 保持 0；动态文本增加样本 |
| 视觉 | 1280×800 / 1600×1000 基线 | 每批截图 + 控件几何对照 |

## 9. 参考

- [`ui_theme_contract.md`](ui_theme_contract.md)
- [`typography_tokens.md`](typography_tokens.md)
- [`status.md`](status.md)
- [`current-iteration.md`](../roadmap/current-iteration.md) Phase 27
- [`acceptance.md`](acceptance.md)
