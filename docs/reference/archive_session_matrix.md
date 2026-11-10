# 档案会话、持久化与共享账本

> **职责**：回答档案身份如何建立、保存如何提交以及双人数据如何归属；运行时场景退出次序见 [`runtime_lifecycle_matrix.md`](runtime_lifecycle_matrix.md)，总体数据层见 [`architecture.md`](architecture.md) §5。

## 身份与会话

- `Global.set_cd_path()` 是档案路径唯一写入口。档案路径变化时先 flush 待写任务、结束旧会话，再更新路径并推进档案身份 epoch；flush 失败会通过 `false` 暴露，但路径切换仍继续。异步任务以路径和 epoch 校验，旧身份不得更新当前档案元数据。
- `Global.bind_archive_session()` 只在当前路径可解析为正档案号且角色 ID 有效时建立 `ArchiveSession`；会话快照只读提供档案号、角色、路径和会话代次。会话代次用于运行时预热，档案 identity epoch 用于存档写入，两者不是同一计数。
- 没有有效会话时，同步/后台保存及默认关卡入口拒绝；保存路径只能由会话提供，业务不得拼接档案路径或把路径参数用于越过当前身份。
- `load_game()` 对非法路径、缺失、空、不可读、结构无效和成功返回显式状态；可从 `.bak` 恢复。只有有效档案进入合并前才清空内存档并装载，再执行当前有限、幂等的规范化；不是通用跨版本迁移链。

## 保存提交与失败

- 业务走 `MemoryClass.request_save(reason)`；需要结果时用 `request_save_result()`，其结果包含 `ok/reason/error/message/path/notify`。失败写入 `last_save_outcome` 并发出 `save_failed`，调用方不能把失败当成功。
- 保存前使用固定补全步骤及后置条件；无效数据、补全失败、会话缺失/过期均阻止写盘。业务命令是否恢复内存状态由该命令的事务边界负责，持久化层本身不替任意面板恢复其操作。
- 加密档以稳定密钥写入 `.tmp`，回读校验后将旧档转为 `.bak` 再替换；替换失败时保留旧档或备份。`.tmp` 不作为已提交档案。
- 后台保存任务绑定档案路径和 identity epoch，旧任务不会覆盖新档；失败快照保留供同一身份的 flush/重试。应用暂停、关闭请求及 `MemoryClass._exit_tree()` 会尝试 flush。flush 失败不会阻止 `set_cd_path()` 继续切换身份。

| 失败场景 | 当前语义 |
|:---|:---|
| 无会话、非法路径或身份已过期 | 拒绝保存/加载；返回或发出可观察失败，不转写到 1 号档。 |
| 档案不可读、为空或结构无效 | 返回对应读取状态，不合并该档；不猜测旧目录或另一种存档格式。 |
| 补全或后置条件失败 | 拒绝写入并报告失败键/原因。 |
| 临时文件写入、回读或替换失败 | 不报告成功；旧档/备份保留以便恢复。内存回滚由调用命令负责。 |
| 切档时 flush 失败 | 返回 `false`，但路径与身份 epoch 仍切换；旧后台任务不能写入新的身份。 |

## 双人槽位与共享账本

- `LocalCoop` 持有独立 2P `PlayerDataStore`、属性与输入；`data_for/props_for` 按节点槽位解析。新调用方显式携带 `coop_slot` 或显式传入档案，不用全局视图交换代替操作者身份。
- `shared_keys()` 是共享键清单的写入所有者：四类背包、玩家被动、剑阵及等级、炼体、万灵图录、共享灵魂。运行期这些键使用单一共享容器；个体宠物列表、等级/属性/技能/装备与出战状态留在各自档案。
- `save_profile()` 将 2P 独有数据写入双人档案并剥离共享键副本；新增共享键必须登记。读入旧双人数据时，有限的共享键规范化由 `LocalCoop` 处理，不据此扩展为通用迁移框架。
- 档案快照期间 `is_save_snapshot_in_progress()` 阻止协作面板**打开**；切换面板的守卫范围见 [`ui_panel_contract_matrix.md`](ui_panel_contract_matrix.md)。

历史实施记录见 [`../archive/iteration_16_archive_session_matrix.md`](../archive/iteration_16_archive_session_matrix.md)；保存/档案验收判据见 [`acceptance.md`](acceptance.md)。