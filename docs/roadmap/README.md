# 路线图 (Roadmap)

本目录保存项目路线图、当前迭代和后续任务规划。

---

## 1. 当前文档

| 文档 | 内容 |
|:---|:---|
| [`roadmap.md`](roadmap.md) | 项目状态、长期阶段顺序、近期重点与独立立项的唯一来源 |
| [`current-iteration.md`](current-iteration.md) | **Phase 17 玩法与表现模块边界**：17-1 调用面矩阵、17-2A 来源显式化、17-2B 池化复用清理、17-2C 归属回归、17-3 关卡阶段与结算已完成；17-4 成长系统命令边界、17-5 HUD/输入/音频表现、17-6 模块 API 与场景依赖、17-7 边界守卫与阶段收口未启动 |
| [`../archive/iteration_14_atlas_metadata_boundary.md`](../archive/iteration_14_atlas_metadata_boundary.md) | Phase 14 AtlasMetadata 类型化边界归档：View 迁移、守卫与验证 |
| [`../archive/iteration_15_app_orchestration_lifecycle.md`](../archive/iteration_15_app_orchestration_lifecycle.md) | Phase 15 应用编排与运行资源生命周期归档：场景入口、加载页、缓存/池/UI、退出与边界守卫 |
| [`../archive/iteration_13_visual_asset_contract.md`](../archive/iteration_13_visual_asset_contract.md) | Phase 13 视觉资产契约收口归档：阶段回顾、冻结/遗留项、发布验收与后续顺序 |
| [`../archive/iteration_6_9_patch_backport.md`](../archive/iteration_6_9_patch_backport.md) | 6.9 补丁回植归档：范围、文件映射、实施批次与验收结果 |
| [`../archive/iteration_12_display_hud.md`](../archive/iteration_12_display_hud.md) | Phase 12 显示层验收归档：分辨率矩阵、双人 HUD、门禁与已知边界 |

当前内容版本 **6.9**。Phase 12~16 已完成并归档；当前候选为 Phase 17 玩法与表现模块边界（七个切片均未启动）；Phase 16 归档见 [`../archive/iteration_16_archive_session_slots.md`](../archive/iteration_16_archive_session_slots.md)。目录治理不再作为全仓搬迁阶段。

## 2. 边界

- `roadmap.md` 只承担项目状态、长期阶段顺序、近期重点与独立立项；
- `current-iteration.md` 只承担当前候选阶段、恢复条件与实施顺序；
- 路线图不复制当前状态数字，也不复制批次内任务清单；
- 当前版本、规模与门禁结果以 [`../reference/status.md`](../reference/status.md) 为准；
- 架构方向见 [`总体目标契约`](../standards/target_architecture_contract.md)，视觉契约只是其中子系统；目标、现状与验收事实不能混写；
- 已完成阶段的资料按归档规则进入 [`../archive/`](../archive/README.md)；
- 新的当前迭代文档在本目录新增，并同步更新本页与 [`../README.md`](../README.md)。

历史阶段规划与已完成任务不直接堆放在本目录；需要长期参考时，先蒸馏结论，再归档。
