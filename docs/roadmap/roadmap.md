# BHYH 后续开发路线图

> 本页是阶段状态、未完成工作范围/恢复条件与长期候选的唯一来源；不记录批次台账或当前实现/验证结果。当前实现与验证快照分别见 [`../reference/architecture.md`](../reference/architecture.md) 和 [`../reference/status.md`](../reference/status.md)；目标架构见 [`../standards/target_architecture_contract.md`](../standards/target_architecture_contract.md)，历史证据见 [`../archive/README.md`](../archive/README.md)。

## 1. 阶段状态

| 阶段 | 状态 | 证据或入口 |
|:---|:---|:---|
| Phase 12–20 | 已完成并归档 | [`../archive/README.md`](../archive/README.md) |
| Phase 21 平台与发布 | 可执行决策和验证项已完成；设备性能基线暂缓至 Phase 26 | [ADR-027](../decisions/ADR-027-platform-commitment-and-verification-device.md)、[`../reference/spine_platform_baseline.md`](../reference/spine_platform_baseline.md) |
| Phase 22 | 已完成并归档 | [`../archive/iteration_22_global_state_boundary.md`](../archive/iteration_22_global_state_boundary.md) |
| Phase 23 | 已完成并归档 | [`../archive/iteration_23_pet_domain_boundary.md`](../archive/iteration_23_pet_domain_boundary.md) |
| Phase 24–25 | 已完成并归档 | [`../archive/README.md`](../archive/README.md) |
| Phase 26 平台与发布验证 | 暂缓，未启动 | §2 |
| Phase 27–29 | 已完成并归档 | [`../archive/README.md`](../archive/README.md) |
| Phase 30–33 | 已完成并归档 | [`../archive/README.md`](../archive/README.md) |
| Phase 34–38 | 已完成并归档 | [`../archive/README.md`](../archive/README.md) |
| Phase 39 | 已完成并归档 | [`../archive/README.md`](../archive/README.md) |

阶段行只给出阶段级状态；实施过程和逐项证据由归档维护。当前候选是否活跃及其恢复入口见 [`current-iteration.md`](current-iteration.md)。

## 2. 未启动工作与恢复条件

### Phase 26：平台与发布验证

工作范围：明确目标与未验证平台、Spine 运行库/许可证/导出条件；验证真实 Release/PCK 的冷启动和依赖闭包；在固定验证设备上建立可比较的性能基线。不由此声明最低配置。

恢复条件：平台矩阵、验证设备、运行库/许可证与导出条件、Release 验收计划均已确认后再启动。PCK 路径可达不等于实际加载或设备性能通过。平台承诺以 [ADR-027](../decisions/ADR-027-platform-commitment-and-verification-device.md) 为准。

## 3. 长期候选：内容回植

维护者确认上游内容和迁移范围后再立项；按 [ADR-014](../decisions/ADR-014-three-way-semantic-merge-for-version-migration.md) 与 [`../guides/migration_playbook.md`](../guides/migration_playbook.md) 采用三方语义合并，不恢复旧路径、兼容层或跨版本存档迁移链。

## 4. UI 表现候选（未立项）

以下只记录创意，不代表产品决策、当前计划或已实现行为；立项后再登记范围与验收。

### 4.1 统一品质颜色表

统一装备品质颜色与顺序的来源。

### 4.2 装备图标品质边框

评估装备图标的品质边框表现。

### 4.3 角色描边试验

评估限定角色或角色预览的描边表现。