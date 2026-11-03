# 参考文档 (Reference)

本目录保存当前工程事实、架构、验收和仍生效的契约。已完成阶段的实施记录、历史验证与逐项决策见 [`../archive/README.md`](../archive/README.md)。

## 1. 当前文档

| 文档 | 内容 |
|:---|:---|
| [`architecture.md`](architecture.md) | **当前运行时架构**：Autoload、场景流、战斗、档案/双人、资源、UI/输入及遗留边界 |
| [`global_runtime_inventory.md`](global_runtime_inventory.md) | **Phase 22 已收口**：`Global` 状态字段、公开入口、26 个普通子服务、删除/迁出项、剩余字段所有者与机读守卫 |
| [`status.md`](status.md) | **当前状态单一事实源**：版本、门禁、最近验证与已知边界 |
| [`acceptance.md`](acceptance.md) | **验收标准**：`check_all` 总门禁、契约域、引擎健康、运行期夹具与变更矩阵 |
| [`autoload_boundary_matrix.md`](autoload_boundary_matrix.md) | 当前 11 个 Autoload 与 `Global` 边界；完整迁移记录见归档 |
| [`runtime_lifecycle_matrix.md`](runtime_lifecycle_matrix.md) | 当前场景流、加载、缓存/租约、清理与退出边界；完整记录见归档 |
| [`archive_session_matrix.md`](archive_session_matrix.md) | 当前保存入口、档案会话、槽位、共享账本与失败边界；完整记录见归档 |
| [`gameplay_module_matrix.md`](gameplay_module_matrix.md) | 当前归属、对象池、阶段/结算、成长命令、HUD/输入/音频与模块 API 边界；完整记录见归档 |
| [`pet_level_boundary_matrix.md`](pet_level_boundary_matrix.md) | Phase 23（已关闭）：`BaseLevel` 宠物调用面、八族矩阵、`PetLevelController` 与族规则、2P 写回修复、共享槽位边界及 73→16 收口证据 |
| [`pet_domain_contract.md`](pet_domain_contract.md) | Phase 23-4/24-3：`PlayerData` 宠物域只读 View、出战/休息/成长/阵法命令、保存失败回滚、共享容器恢复与调用面 |
| [`ui_panel_contract_matrix.md`](ui_panel_contract_matrix.md) | Phase 24-0/24-1/24-2/24-3/24-4：`CoopPanelHost`、`pet_interface` 子区域、阵法成长命令、LDL 成长面板、操作者/保存/直接与间接写档边界及登记例外 |
| [`module_api_matrix.md`](module_api_matrix.md) | Phase 17-6 试点模块公开 API 与依赖方向 |
| [`atlas_metadata_schema.md`](atlas_metadata_schema.md) | AtlasMetadata 生产者、schema、消费者、只读 View 与失败边界 |
| [`runtime_frames_exceptions.md`](runtime_frames_exceptions.md) | 运行时建帧冻结例外与后续边界 |
| [`level_layout_contract.md`](level_layout_contract.md) | 当前关卡布局对象模型、字段、构建与运行时契约 |
| [`equipment_data_contract.md`](equipment_data_contract.md) | 当前装备定义/规则/实例三层契约与发布闭包 |
| [`ui_theme_contract.md`](ui_theme_contract.md) | 当前 Theme 资源、变体命名、最终例外与审计 |
| [`spine_platform_baseline.md`](spine_platform_baseline.md) | Spine 运行时、平台、许可证与暂缓边界 |

## 2. 边界

- 当前状态、架构、验收和仍生效的契约放在本目录；
- 架构决策放在 [`../decisions/`](../decisions/README.md)；规范放在 [`../standards/`](../standards/README.md)；
- 已完成阶段的实施记录、历史计数和验证快照进入 [`../archive/`](../archive/README.md)；
- 新增或移动文件时同步本索引，不复制完整清单到其他入口；
- 本文档目录不把目标写成已实现，不复制历史批次台账。
