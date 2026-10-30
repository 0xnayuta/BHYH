# 参考文档 (Reference)

本目录保存描述当前工程事实、架构与验收边界的参考文档。

---

## 1. 当前文档

| 文档 | 内容 |
|:---|:---|
| [`architecture.md`](architecture.md) | **当前运行时架构**：应用/Autoload、场景流、战斗、档案/双人、资源、UI/输入及与目标的遗留差距 |
| [`runtime_frames_exceptions.md`](runtime_frames_exceptions.md) | **Phase 19-3A 运行时建帧例外决策**：12 个冻结例外的保留/补资源/删除回退结论、证据与后续边界 |
| [`archive_session_matrix.md`](archive_session_matrix.md) | **Phase 16-1 档案、持久化与槽位调用面矩阵**：保存入口、档案身份、会话字段、直接写入分域、补全清单、双人槽位、共享账本与面板显式操作者的当前所有者与失败边界 |
| [`gameplay_module_matrix.md`](gameplay_module_matrix.md) | **Phase 17-1 玩法与表现调用面矩阵（已完成）**：攻击/弹体/召唤/法宝归属、对象池、关卡阶段与结算、成长提交、HUD/输入/音频、模块 API 与场景依赖的所有者、写入者与失败边界 |
| [`runtime_lifecycle_matrix.md`](runtime_lifecycle_matrix.md) | **Phase 15 运行时调用面与所有权矩阵（已完成、归档）**：场景切换、加载页、缓存/池/UI、档案会话与退出清理的当前所有者及失败边界 |
| [`atlas_metadata_schema.md`](atlas_metadata_schema.md) | **Phase 14 矩阵与试点**：AtlasMetadata 生产者、源形态、消费者、View 与失败边界 |
| [`acceptance.md`](acceptance.md) | **验收标准**：八维门禁、契约域、引擎健康、运行期夹具、阈值与分变更矩阵 |
| [`status.md`](status.md) | **当前状态单一事实源**：版本、目录、规模、门禁与验收基线 |

## 2. 边界

- 当前状态、架构、验收与项目范围类文档放在本目录；
- 架构决策记录放在 [`../decisions/`](../decisions/README.md)；
- 规范约束放在 [`../standards/`](../standards/README.md)；
- 项目总体目标见 [`target_architecture_contract.md`](../standards/target_architecture_contract.md)；本文档目录只记录现状与实际验收，不把目标写成已实现。
- 操作步骤放在 [`../guides/`](../guides/README.md)；
- 已完成且不再活跃的历史资料放在 [`../archive/`](../archive/README.md)。

后续可继续在本目录增加架构、验收、项目范围文档；新增文件时同步更新本页与 [`../README.md`](../README.md)。
