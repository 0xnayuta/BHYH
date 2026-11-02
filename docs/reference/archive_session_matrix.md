# 档案会话、持久化与玩家槽位边界（当前）

> **状态**：Phase 16 已完成并归档；本页保留当前保存入口、会话、槽位和失败边界。完整 16-2~16-6 实施记录见 [`../archive/iteration_16_archive_session_matrix.md`](../archive/iteration_16_archive_session_matrix.md)。

## 1. 保存入口

| 入口 | 用途 | 约束 |
|:---|:---|:---|
| `MemoryClass.request_save(reason)` | 业务唯一保存入口 | 需要有效档案会话；失败可观察 |
| `MemoryClass.request_save_result(...)` | 需要结构化结果/反馈的调用 | 返回 `ok/reason/error/message/path/notify` |
| `MemoryClass.save_game(path)` | 持久化边界内部委托 | 业务代码不得直接调用 |
| `MemoryClass.safe_write_archive(...)` | 存档界面写回 | 仅限登记入口 |
| `MemoryClass.request_background_save(...)` | 后台保存 | 携带代次；过期任务不写回 |

业务侧 `save_game` 直调为 0。保存失败通过 `save_failed` 信号、`last_save_outcome` 或 `Global` 反馈观察；不得丢弃失败假象。

## 2. 档案身份与会话

- `Global.set_cd_path()` 是唯一身份写入口；切换前 flush 待写队列并推进 session/epoch。
- 云存档登录会话由 `MemoryClass` 持有的 `CloudSession`（`RefCounted`）保存，不写入本地档案；档案界面通过 `MemoryClass.get_cloud_session()` 使用，不新增 Autoload。
- `ArchiveSession` 只读持有档案号、角色、路径与会话代次；业务查询会话，不直接读写 `cd_path`。
- 无会话时保存、关卡入口和后台保存必须拒绝；过期身份回写不得覆盖当前档案。
- `load_game` 在合并前重置内存档，并按 `loaded/missing/empty/unreadable/invalid/invalid_path` 返回显式状态。

## 3. 补全与原子写

- 保存侧使用固定补全清单，并在补全后执行后置条件校验；失败拒绝写入，不出现“补全失败但保存成功”。
- 写盘顺序：`.tmp` → 回读校验 → 旧档转 `.bak` → 原子替换；失败保留可读旧档。
- 当前格式规范化必须幂等；不引入跨版本迁移链或旧目录回退。
- 加密格式、密钥、`.tmp`/`.bak` 与字段语义不变。

## 4. 槽位与共享账本

- `slot_for`/`data_for`/`props_for`/`slot_snapshot` 是槽位查询入口；面板使用显式 `coop_slot`，不交换全局 `PlayerData`/`RoleProp`。
- `shared_keys()` 登记共享键；`save_profile` 按登记剥离 2P 档案的共享副本。
- 运行期共享背包/宠物背包/被动/剑阵/炼体/万灵/灵魂保持单容器；个体等级、属性、技能、装备和出战状态保留个体归属。
- 新增共享键必须登记，`shared_ledger_report()` 必须能逐键校验。

## 5. 面板与快照

- 面板根/弹出层携带 `coop_slot`；脚本通过显式 `PlayerData`/`RoleProp` 属性解析操作者。
- 保存快照期间 `is_save_snapshot_in_progress()` 阻止面板打开/切换。
- 面板关闭保存必须检查会话；关闭失败不得静默改写 1P 视图或残留全局别名。

## 6. 失败边界

| 场景 | 语义 |
|:---|:---|
| 无会话/身份过期 | 拒绝保存和关卡入口；返回结构化错误 |
| 非法路径/非法角色 | 拒绝加载或写入；不落到 1 号档 |
| 写盘失败 | 保留旧档；恢复快照；发出可观察信号 |
| 补全后置条件失败 | 拒绝写入并报告键 |
| 切档/退出 | 先 flush；旧后台任务按 epoch 丢弃 |
| 快照与面板并发 | 互斥入口拒绝面板操作 |

完整实施细节、历史计数与逐项关闭记录见归档页；本页只描述当前契约。
