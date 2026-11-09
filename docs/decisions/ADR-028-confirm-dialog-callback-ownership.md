# ADR-028：确认框回调归打开者所有，移除全局确认信号

- **状态**：Accepted
- **记录日期**：2026-11-09
- **影响范围**：UI 确认框、全局信号、Autoload 注册项、场景探针

## 背景

`Signals` Autoload 只有 `choose_pressed` 一个信号；`connect_choose_box_signal()` 在连接新回调前断开所有旧连接。该实现隐含“同一时刻只有一个确认框、最后打开者接管”的全局状态，但信号层没有表达单实例约束。旧确认框仍可被点击并触发新回调，存在重复扣费、重复删除等风险；10 个业务调用点依赖这个隐式语义。

## 决策

1. 删除 `Signals` Autoload 与 `choose_pressed`；Autoload 注册项由 11 降为 10（9 个业务单例 + `MCPGameBridge`）。
2. `choose_scene.gd` 暴露实例信号 `confirmed` 与 `cancelled`；确认/取消先发信号，再释放实例。
3. 确认回调归打开者所有：调用方在 `Global.add_choose_text()` 返回值上连接，不再经过全局路由。
4. 单确认框约束由 `PopupFactory` 显式维护：新确认框打开时隐藏并释放旧实例，不依赖信号断开。
5. 新增全局信号基线门禁：Autoload 脚本的 `signal` 声明与基线比较，新增报 ERROR。删除 `Signals` 后基线为 `MemoryClass` 的 `background_save_finished` 与 `save_failed`。

## 后果

- 确认回调的生命周期与打开者一致，不再存在跨面板的隐式接管。
- 单确认框语义显式化；重复打开会关闭旧实例，旧操作不会被误确认。
- 业务调用点增加 null 检查与显式连接；遗漏会在编译或场景探针中暴露。
- `Signals` 不再是 Autoload；文档计数与架构表同步为 10 项。

## 备选方案

| 方案 | 未采用原因 |
|:---|:---|
| 保留 `Signals` 并加注释 | 只记录隐式全局状态，不消除跨面板接管风险 |
| 每个面板自定义信号 | 复制连接/断开逻辑，仍缺单实例约束 |
| 保持 `choose_pressed` 并增加实例参数 | 仍是全局路由，回调所有权不清晰 |

## 证据

- `source/project.godot` `[autoload]`（10 项）
- `source/Scene/show_text/choose_scene.gd`、`source/Script/runtime/popup_factory.gd`
- `source/Script/archive_interface/read_archive_interface.gd` 等 10 个调用点
- `scripts/contract_scan.py` 全局信号基线门禁
- [`../reference/autoload_boundary_matrix.md`](../reference/autoload_boundary_matrix.md)
