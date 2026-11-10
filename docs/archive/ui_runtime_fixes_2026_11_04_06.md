# 2026-11-04 至 2026-11-06 UI 与运行时维护记录

> **归档日期**：2026-11-10
> **状态**：Archived
> **关联**：当前状态与验证边界见 [`../reference/status.md`](../reference/status.md)；Theme/字体契约见 [`../reference/ui_theme_contract.md`](../reference/ui_theme_contract.md)、[`../standards/ui_typography_contract.md`](../standards/ui_typography_contract.md)；历史验证索引见 [`validation_history_2026.md`](validation_history_2026.md)。

## 2026-11-04

- 修复宠物预热与寅虎动作帧；`convert_monster_action_views.py --check` 5/5，`pet-runtime` 通过。
- 将 183 个场景的 412 条 AnimationMixer 单键 value track 改为离散更新；关卡回归保留首轮失败证据，并在阶段清场后等待物理帧再传送。全量回归 128/128 PASS + 5 SKIP。
- 补齐 6.6/6.8 玉兔制作书掉落、材料合成例外、法宝出入炉回写和双人相机/Buff/灵气/被动/键位提示；`check_all`、`archive`、`scene`、`coop` 与全量关卡回归通过。
- 补齐原始数据导出清单、`bhyh_export` 插件与实际 PCK 闭包验证；移除 `include_filter="*.bin"` 兜底。原始数据 844/844、release PCK 5,044/5,044。
- 命名终审通过；第三方 DragonBones 前缀登记，私有 `Data` 目录统一为 `data`。

## 2026-11-05

- 装备与法宝 tooltip 经真实实例探针验证；`equipment_properies` 的描述与售价写入收敛到 `_set_description_and_sale`。`check_all` 9/9、`level_1` 四阶段通过。

## 2026-11-06

- UI 调整：加载页百分比字号改为 24 并居中；HUD 三值条统一高度、间距和起点；HP/MP/EXP 改用三个 `AtlasTexture`；法宝面板移除重复 `m_MDef`；实战法宝等级按整数显示。
- 内部名称与玩家可见标点清理；新增 report-only `ui_text_punctuation_audit.py`，自测 9 个样本，全仓无残留。
- 修正暂停菜单、音乐/背景列表间距、ESC 菜单布局、属性 tooltip 与炼丹炉按钮位置。
- 字体角色调整：帮助标题与技能界面使用 `display`；最终字体角色选择见 [`ui_typography_contract.md`](../standards/ui_typography_contract.md)。

以上均为当时的实施与验证快照，不作为当前门禁结果；当前事实只更新在 `status.md` 与对应契约中。