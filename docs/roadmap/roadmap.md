# BHYH 后续开发路线图

> **定位**：项目状态、长期阶段顺序与近期重点的唯一来源。只记录当前版本之后的方向，不保留逐任务流水账。
>
> **当前版本**：6.9。**Phase 13 视觉资产契约收口已完成并归档**（[`../archive/iteration_13_visual_asset_contract.md`](../archive/iteration_13_visual_asset_contract.md)）；当前无活跃候选阶段。上一阶段 **Phase 12 画布与 HUD 重构已完成并归档**（[`../archive/iteration_12_display_hud.md`](../archive/iteration_12_display_hud.md)）。
>
> **事实基线**：工程状态、规模与门禁结果以 [`../reference/status.md`](../reference/status.md) 为单一事实源；架构实现见 [`../reference/architecture.md`](../reference/architecture.md)；验收阈值见 [`../reference/acceptance.md`](../reference/acceptance.md)。
>
> **迁移方法**：见 [`../guides/migration_playbook.md`](../guides/migration_playbook.md)。

---

## 0. 文档边界

| 文档 | 唯一职责 | 更新时机 | 不承担 |
|:---|:---|:---|:---|
| `roadmap.md` | 项目状态、长期阶段顺序、近期重点、独立立项 | 阶段目标变化、功能完成度变化、重大风险变化 | 逐任务步骤、批次内实施细节、每日恢复状态 |
| `current-iteration.md` | 当前候选阶段、恢复条件、实施顺序、验收入口 | 当前候选批次推进、阻塞、恢复或完成时 | 长期路线、跨阶段项目账本 |

`current-iteration.md` 频繁更新，不复制本页的阶段结论；本页不复制 `current-iteration.md` 的任务清单。两者冲突时，项目状态与长期顺序以本页为准，当前批次实施状态以 `current-iteration.md` 为准，事实与门禁结果以 `status.md` 为准。

---

## 1. 当前状态与近期重点

### 1.1 状态

| 项目 | 状态 | 说明 |
|:---|:---|:---|
| Phase 12 画布、相机与 HUD 重构 | **已完成并归档** | 不再进入当前迭代 |
| Phase 13 视觉资产契约收口 | **已完成并归档** | 失败语义、构建期视觉资产、发布闭包、兼容层治理与角色特效均收口；3 个非怪物例外冻结 |
| 当前活跃候选阶段 | **无** | 下一个独立项目明确后再写入 `current-iteration.md` |
| AtlasMetadata typed accessor | **规划，未启动** | 独立立项，见 §3.1 |
| Spine 跨平台运行时与平台验收 | **规划，未启动** | 独立立项，见 §3.2 |
| 新内容版本 | **未确认** | 当前不把 7.0 回植写成公开路线承诺 |

Phase 13 只做内部架构与资产管线收口，不新增玩法、任务、掉落或数值内容；内容版本保持 **6.9**。

### 1.2 近期重点

1. Windows release 启动、`level_1`、FPS、首帧代理与 VRAM 基线已在当前主机通过；后续补峰值 VRAM、战斗负载与跨平台验收；
2. 保持 12 个运行时建帧例外冻结，发布前复核 `runtime_frames_audit`；
3. 保持 L2 固定套件稳定，`scene_probe_runner` 的星座 / 关卡选择态 / 角色技能 / 法宝与角色特效覆盖不缩减；
4. AtlasMetadata typed accessor 与 Spine 跨平台运行时按独立项目重新立项，不提前占用当前批次。

---

## 2. 长期阶段顺序

```text
Phase 12 画布与 HUD（已完成，归档）
        │
        ▼
Phase 13 视觉资产契约收口（已完成，归档）
        │
        ▼
无活跃候选阶段
        │
        ▼
独立项目：AtlasMetadata typed accessor / Spine 跨平台运行时
（启动条件见 §3）
```

没有确认的新内容阶段，不新增 Phase 编号。版本回植只在目标明确后进入本页与 `current-iteration.md`，不以“未来可能”替代可执行范围。

---

## 3. 后续独立立项

以下项目按独立项目推进，不混入普通功能提交，也不进入当前候选批次。启动时先补详细规划到 `current-iteration.md`，并在 `status.md` 记录前置事实。

### 3.1 AtlasMetadata typed accessor

**目标**：把 `AtlasMetadata.data` 的裸字典访问收敛为强类型 Resource 或类型化 accessor，统一 schema 校验、序列/帧读取与失败语义；`.data` 只保留为迁移期边界，不继续扩大。

**为什么独立**：会同时触及 AtlasMetadata 生产者、构建期转换器、FrameSequence/帧资源消费者与校验门禁；属于数据契约变更，不是单个 Phase 批次可安全收口的改动。

**启动条件**：

- 完成消费者与字符串键清单，确认迁移顺序；
- 定义 typed schema、缺失字段与旧 schema 的失败边界；
- `--check`、UID/闭包校验与代表场景探针可覆盖；
- 明确不改变视觉效果与已验收玩法。

**当前状态**：仅登记路线，未启动；不进入 6.9 或 Phase 13 的完成定义。

### 3.2 Spine 跨平台运行时与平台验收

**目标**：为 Spine 内容提供与 Godot 4.7.2、Spine 运行时版本匹配的 macOS/Linux/Android/Web 二进制，补齐许可证与再分发声明，并在目标平台验证加载、角色技能、UI 与发布包。

**为什么独立**：涉及外部二进制、平台工具链、许可证与真实设备验收；Windows 编辑器或 headless 探针不能证明跨平台运行时可用。

**启动条件**：

- 确定目标平台与 Spine 运行时版本，核对许可证；
- 各平台二进制入库边界、`.gdextension` 配置与回滚策略；
- 平台构建、Spine 加载、角色/UI 探针与发布验收可执行；
- 若平台暂不可用，明确写入 `status.md` 与发布边界，不把 Windows-only 写成全平台通过。

**当前状态**：仅登记路线，未启动；不进入 Phase 13，也不替代当前 Windows 完整工作区验收。

---

## 4. Godot 设计规范落地

当前工程仍包含 Flash 正位重构遗留结构。后续新代码与主动重构按 [`../standards/godot_design_standard.md`](../standards/godot_design_standard.md) 执行：

- 场景单一职责、自包含、依赖注入；
- 新代码禁止深层 `get_node()` 与绝对路径；
- 新结构化数据使用 `Resource` / `.tres`；
- 新增 Autoload 必须评审；
- 输入动作与物理层使用具名配置；
- 遗留结构不阻塞功能，但不得继续扩张。

---

## 5. 技术债治理

按独立项目或明确批次推进，不混入普通功能提交：

| 项目 | 目标 |
|:---|:---|
| `global.gd` 与字典数据 | 逐步拆分为 Resource、服务节点或强类型数据入口 |
| 13 个 Autoload | 降低耦合，新增 Autoload 需评审 |
| 类型分层目录 | 新功能按功能子目录聚合，不做无计划全量迁移 |
| `_bundled` 场景 | 按专项转换为原生文本场景，完成 UID 与导入缓存重建 |
| 深层节点路径 | 新代码使用依赖注入与 `%UniqueName`，重构时同步清理 |
| 流式发布验证 | 验证用 `export_presets.cfg` 与 `frame_sequence_pack_probe.py` 已入库；PCK 内延迟纹理闭包已实测通过。仍需在目标平台验证 release 加载、VRAM 驻留与首帧耗时，不以包内路径代替运行时性能 |
| 视觉资产预算 | 按目标平台测量首帧延迟、纹理页驻留量及反复进出关卡后的回收，不把 headless 探针当 VRAM 证据 |
| 运行时建帧 | 怪物域已构建期化并冻结例外；非怪物域 13-2C-1/2/3 与角色特效收口已完成；剩余宠物、关卡、工具 3 个例外冻结 |
| 资源失败语义 | 空占位与 `assert` 掩盖缺失已在 Phase 13-1 收口；新增路径继续显式失败 |
| 玩法资源发布闭包 | 预载 Catalog 的怪物与弹体路径已进入发布依赖清单；变更后重跑闭包探针 |
| 纹理别名兼容表 | 已清空并收敛入口；禁止重新建立无消费者别名表 |

---

## 6. 质量与工具链

- 保持 `check_all.py` 八维门禁（无 Godot 环境使用 `--skip-engine` 的静态口径）与 0 ERROR / 0 WARNING；
- 报告由脚本按需生成，不提交历史报告；
- 保持门禁命令、报告路径和文档索引同步；
- 新增脚本只进入 `scripts/`，版本专用迁移工具不进入日常工具链；
- 公共仓库继续排除第三方素材；完整工作区验收以本地合法素材为准。

---

## 7. 验收基线

每个阶段结束时更新 [`../reference/status.md`](../reference/status.md)：

- 当前内容版本；
- 工程规模；
- 静态门禁、引擎健康检查、关卡回归与 Atlas 校验结果；
- 已知边界与未完成技术债；
- 下一次迁移的入口与前置条件。

发布前 L2 固定套件与变更矩阵见 [`../reference/acceptance.md`](../reference/acceptance.md) §6；`scene_probe_runner` 的三个固定探针与耗时记录以该节为准。
