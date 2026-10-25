# ADR-007：保留 13 个 Autoload，新增必须评审

- **状态**：Accepted
- **记录日期**：2026-10-25
- **影响范围**：全局状态、初始化顺序、生命周期、测试

## 背景

当前有 13 个 Autoload 注册项，承担存档、属性、设置、装备、锻造、被动、音乐、信号、全局工厂、双人等职责。它们与业务代码深度耦合，立即移除会破坏启动流程与双人模型；但继续新增“方便访问”的单例会让耦合进一步失控。

## 决策

1. 现有 13 个注册项按遗留例外保留：
   - 12 个业务单例；
   - `MCPGameBridge` 是编辑器调试桥，不参与业务依赖；
2. 新增 Autoload 前必须说明：
   - 为什么不能用普通场景节点；
   - 为什么不能用 `Resource`、静态函数或 `class_name` 工具类；
   - 初始化顺序与依赖；
   - 生命周期、清理方式与测试入口；
   - 对现有 Autoload 数量与耦合度的影响；
3. `global.gd` 不得继续扩张为新的业务数据仓库；
4. 新功能不得以“方便访问”为理由把状态塞进全局单例；
5. `LocalCoop` 最后注册，相关代码使用 `get_node_or_null` 探测，避免启动期空引用。

## 后果

- 全局状态规模受控，但短期内仍存在大型单例；
- 新 Autoload 评审成本提高，促使优先使用场景/Resource；
- 拆解现有 Autoload 必须单独立项，不能混入功能提交；
- 初始化顺序成为显式契约，新增依赖必须验证冷启动与场景切换。

## 备选方案

| 方案 | 未采用原因 |
|:---|:---|
| 立即移除全部 Autoload | 启动、存档、双人与 UI 工厂全面重构，风险过高 |
| 允许按需新增单例 | 耦合持续增长，测试与生命周期不可控 |
| 用服务定位器替代所有单例 | 只是换名字，仍隐藏依赖 |

## 证据

- [`../../source/project.godot`](../../source/project.godot) `[autoload]`
- [`../standards/godot_design_standard.md`](../standards/godot_design_standard.md) §4
- [`../reference/architecture.md`](../reference/architecture.md) §2
- [`../../AGENTS.md`](../../AGENTS.md) §3.5
