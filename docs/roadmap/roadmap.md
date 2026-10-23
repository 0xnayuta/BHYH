# BHYH 后续开发路线图

> **定位**：只记录当前版本之后的工作方向，不保留历史阶段流水账。
>
> **当前版本**：6.9。当前迭代为 **Phase 12 画布与 HUD 重构**（规划中，未实施）。当前工程事实、规模与门禁见 [`../reference/status.md`](../reference/status.md)。
>
> **迁移方法**：见 [`../guides/migration_playbook.md`](../guides/migration_playbook.md)。

---

## 1. 当前迭代：Phase 12 画布与 HUD 重构

6.9 补丁回植已完成并通过收口验收，完整记录归档于 [`../archive/iteration_6_9_patch_backport.md`](../archive/iteration_6_9_patch_backport.md)。当前内容版本保持 **6.9**；Phase 12 只处理画布、窗口、相机和桌面 HUD 的展示层重构。

当前方案：

- 设计画布 **1280×800（16:10）**；
- 默认窗口 **1600×1000**，与画布成 **1.25×** 等比；
- `canvas_items` + `expand`，不使用降低渲染分辨率的 `viewport` 模式；
- 相机缩放约 **1.356**，保持原版 590 的世界可视高度；
- 桌面 HUD 恢复左下按钮簇、无双圆盘和 Y/U/I/O/L 技能槽，图标优先使用 6.9 高清素材；
- 移动端保留右上角/触控布局，不把 PC 布局强加给手机。

Phase 12-1 已完成：1280×800 画布、1600×1000 默认窗口、1.356 相机缩放和小屏全屏策略已落地，并通过七维门禁与完整关卡回归。Phase 12-2/12-3 的范围、实施顺序和验收矩阵见 [`current-iteration.md`](current-iteration.md)；Phase 12-2 须由用户明确确认后开始。

后续技术债与设计规范方向仍按本文后续章节推进；通用迁移方法与红线见 [`../guides/migration_playbook.md`](../guides/migration_playbook.md)。

---

## 2. Godot 设计规范落地

当前工程仍包含 Flash 正位重构遗留结构。后续新代码与主动重构按 [`../standards/godot_design_standard.md`](../standards/godot_design_standard.md) 执行：

- 场景单一职责、自包含、依赖注入；
- 新代码禁止深层 `get_node()` 与绝对路径；
- 新结构化数据使用 `Resource` / `.tres`；
- 新增 Autoload 必须评审；
- 输入动作与物理层使用具名配置；
- 遗留结构不阻塞功能，但不得继续扩张。

---

## 3. 技术债治理

按独立项目推进，不混入普通功能提交：

| 项目 | 目标 |
|:---|:---|
| `global.gd` 与字典数据 | 逐步拆分为 Resource、服务节点或强类型数据入口 |
| 13 个 Autoload | 降低耦合，新增 Autoload 需评审 |
| 类型分层目录 | 新功能按功能子目录聚合，不做无计划全量迁移 |
| `_bundled` 场景 | 按专项转换为原生文本场景，完成 UID 与导入缓存重建 |
| 深层节点路径 | 新代码使用依赖注入与 `%UniqueName`，重构时同步清理 |

---

## 4. 质量与工具链

- 保持 `check_all.py` 七维门禁与 0 ERROR / 0 WARNING；
- 报告由脚本按需生成，不提交历史报告；
- 保持门禁命令、报告路径和文档索引同步；
- 新增脚本只进入 `scripts/`，版本专用迁移工具不进入日常工具链；
- 公共仓库继续排除第三方素材；完整工作区验收以本地合法素材为准。

---

## 5. 验收基线

每个阶段结束时更新 [`../reference/status.md`](../reference/status.md)：

- 当前内容版本；
- 工程规模；
- 静态门禁、引擎健康检查、关卡回归与 Atlas 校验结果；
- 已知边界与未完成技术债；
- 下一次迁移的入口与前置条件。
