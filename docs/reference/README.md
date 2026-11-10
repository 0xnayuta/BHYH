# 参考文档 (Reference)

本目录维护当前实现、当前状态、验收判据和仍生效的契约。阶段实施记录与历史验证见 [`../archive/README.md`](../archive/README.md)。本页只提供文档入口，不复制阶段状态、验证计数或契约正文。

## 1. 当前文档

| 文档 | 唯一职责 |
|:---|:---|
| [`status.md`](status.md) | 当前内容版本、最近一次完整验证和未验证边界 |
| [`architecture.md`](architecture.md) | 当前运行时架构、项目配置映射、初始化/场景流和遗留边界 |
| [`acceptance.md`](acceptance.md) | 门禁实际行为、验收档位、失败语义和变更矩阵 |
| [`autoload_boundary_matrix.md`](autoload_boundary_matrix.md) | Autoload 增删评审规则与 `Global` 边界；注册表在 `architecture.md` |
| [`runtime_lifecycle_matrix.md`](runtime_lifecycle_matrix.md) | 当前场景流、资源租约、清理、退出和异步失败边界 |
| [`archive_session_matrix.md`](archive_session_matrix.md) | 当前保存入口、档案会话、槽位、共享账本和持久化失败边界 |
| [`gameplay_module_matrix.md`](gameplay_module_matrix.md) | 战斗归属、关卡结算、对象池、成长与表现的跨模块边界 |
| [`combat_behavior_matrix.md`](combat_behavior_matrix.md) | 自动战斗、法宝展示、Boss 保护与受击反应的当前所有权 |
| [`pet_domain_contract.md`](pet_domain_contract.md) | 宠物档案 View/Command 及失败回滚；关卡族生命周期见 architecture §4.3 |
| [`passive_skill_contract.md`](passive_skill_contract.md) | 玩家被动等级、`pasl_prop` 快照及事件刷新规则 |
| [`ui_panel_contract_matrix.md`](ui_panel_contract_matrix.md) | 面板操作者、生命周期与未闭合写入风险 |
| [`module_api_matrix.md`](module_api_matrix.md) | 四个试点模块当前公开 API 与依赖方向 |
| [`atlas_metadata_schema.md`](atlas_metadata_schema.md) | AtlasMetadata schema、运行时消费者、构建工具和失败语义 |
| [`runtime_frames_exceptions.md`](runtime_frames_exceptions.md) | 运行时建帧例外的人工评审边界 |
| [`level_layout_contract.md`](level_layout_contract.md) | 关卡布局 Resource 字段、不变量和消费语义 |
| [`equipment_data_contract.md`](equipment_data_contract.md) | 装备定义、规则、实例所有权与随机数据语义 |
| [`ui_theme_contract.md`](ui_theme_contract.md) | 唯一当前 Theme 契约：资源所有权、变体和静态/动画/动态覆盖边界 |
| [`theme_font_inventory.md`](theme_font_inventory.md) | Theme 字体角色包装与基础字体映射 |
| [`typography_tokens.md`](typography_tokens.md) | token JSON 的机器事实源、生成目标与审计消费者 |
| [`spine_platform_baseline.md`](spine_platform_baseline.md) | Spine GDExtension、资源格式、加载路径与许可证事实；平台承诺见 ADR-027 |
| [`zmws_asset_integration_matrix.md`](zmws_asset_integration_matrix.md) | 由 `asset_library_catalog.py` 生成的资产生命周期与消费矩阵 |

两个保留的 Phase 22/23 历史链接入口见 [`../archive/README.md`](../archive/README.md) 的 retired path 索引；它们不是当前契约。
## 2. 归档链接入口

以下两个历史路径仅用于解析 Phase 22/23 归档中的旧链接，不是当前契约正文；原矩阵快照见 [`../archive/README.md`](../archive/README.md) §7。

- [`global_runtime_inventory.md`](global_runtime_inventory.md)
- [`pet_level_boundary_matrix.md`](pet_level_boundary_matrix.md)


## 3. 边界

- 当前状态只见 [`status.md`](status.md)；阶段状态只见 [`../roadmap/roadmap.md`](../roadmap/roadmap.md)。
- 当前实现架构只见 [`architecture.md`](architecture.md)；目标和规范见 [`../standards/`](../standards/README.md)；长期决策见 [`../decisions/`](../decisions/README.md)。
- 当前门禁判据只见 [`acceptance.md`](acceptance.md)；脚本参数和产物索引见 [`../../scripts/README.md`](../../scripts/README.md)。
- 本目录只保留当前行为契约或仍有运行时价值的专题事实；历史批次与过期验证进入归档，不在入口索引展开。
