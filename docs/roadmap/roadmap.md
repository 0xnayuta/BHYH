# BHYH 后续开发路线图

> **定位**：只记录当前版本之后的工作方向，不保留历史阶段流水账。
>
> **当前版本**：6.9。当前迭代 **Phase 13 视觉资产契约收口**（规划完成，未开始；范围与批次见 [`current-iteration.md`](current-iteration.md)）。上一阶段 **Phase 12 画布与 HUD 重构已全部完成并归档**（验收记录见 [`../archive/iteration_12_display_hud.md`](../archive/iteration_12_display_hud.md)）。当前工程事实、规模与门禁见 [`../reference/status.md`](../reference/status.md)。
>
> **迁移方法**：见 [`../guides/migration_playbook.md`](../guides/migration_playbook.md)。

---

## 1. 活跃迭代：Phase 13 视觉资产契约收口

Phase 13 以 [`../standards/target_architecture_contract.md`](../standards/target_architecture_contract.md) 的三层契约为基准，按 **契约偏离程度 × 影响面** 排序，收口 Phase 12 之后剩余的四类偏离。完整范围、任务与验收见 [`current-iteration.md`](current-iteration.md)。

| 批次 | 主题 | 主要契约条款 |
|:---|:---|:---|
| Phase 13-1 | 失败语义与热路径 IO 收口 | §4.2、§5.2 |
| Phase 13-2 | 怪物视觉资产构建期化 | §3.1、§3.3 |
| Phase 13-3 | 发布闭包与动态依赖收敛 | §4.3 |
| Phase 13-4 | 兼容层与遗留动态表治理 | §4.2、ADR-005 |

排序依据（2026-10-26 实测）：

- 70 个脚本仍在运行时构造 `SpriteFrames`（88 处），其中怪物脚本 50 个；
- 3 处资源缺失被空占位或 `assert` 掩盖；
- 3 处主线程同步 IO / 逐帧 `load()`；
- 预载 Catalog 的 198 个怪物 ID 与 25 条弹体路径未进任何发布依赖清单；
- 纹理别名表 2,313 条中 932 条目标文件不存在。

Phase 13 不新增内容版本，不改变已验收的 6.9 业务行为。

---

## 1.1 上一阶段：Phase 12 画布与 HUD 重构（已归档）

Phase 12 只处理画布、窗口、相机和桌面 HUD 的展示层重构，已全部完成并归档。最终基线：设计画布 **1280×800（16:10）**、默认窗口 **1600×1000（1.25×）**、`canvas_items` + `expand`、相机缩放 **1.2** 且保持原屏幕下边缘、左下 HUD 与双人镜像技能栏。

详细验收记录见 [`../archive/iteration_12_display_hud.md`](../archive/iteration_12_display_hud.md)；6.9 补丁回植归档见 [`../archive/iteration_6_9_patch_backport.md`](../archive/iteration_6_9_patch_backport.md)。

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
| 流式发布验证 | 验证用 `export_presets.cfg` 与 `frame_sequence_pack_probe.py` 已入库；PCK 内延迟纹理闭包已实测通过（3,101 条）。仍需在目标平台验证 release 加载、VRAM 驻留与首帧耗时，不以包内路径代替运行时性能 |
| 视觉资产预算 | 按目标平台测量首帧延迟、纹理页驻留量及反复进出关卡后的回收，不把 headless 探针当 VRAM 证据 |
| 运行时建帧 | 70 个脚本仍构造 `SpriteFrames`；由 Phase 13-2 迁移到构建期资源 |
| 资源失败语义 | 空占位与 `assert` 掩盖缺失；由 Phase 13-1 改为显式失败 |
| 玩法资源发布闭包 | 预载 Catalog 的怪物与弹体路径未进依赖清单；由 Phase 13-3 收口 |
| 纹理别名兼容表 | 2,313 条中 932 条目标不存在；由 Phase 13-4 分类治理 |

---

## 4. 质量与工具链

- 保持 `check_all.py` 八维门禁（无 Godot 环境使用 `--skip-engine` 的 7/7 静态口径）与 0 ERROR / 0 WARNING；
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
