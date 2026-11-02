# ADR-024：`check_all` 九维门禁与维度清单治理

- **状态**：Accepted
- **记录日期**：2026-11-02
- **影响范围**：提交、评审、发布、工具链与验收文档
- **关系**：扩展 ADR-012；不删除其零错误零警告与门禁先行结论。

## 背景

ADR-012 记录时 `check_all.py` 为八维，不包含 DragonBones 工厂加载验证。后续质量门禁已将 DragonBones 工厂加载作为独立第九维接入；`acceptance.md` 与最新验证记录使用九维口径，但多个活跃文档仍写八维，出现同一事实多副本。

## 决策

1. `scripts/check_all.py` 的实际任务注册是门禁组成的唯一事实源；当前完整口径为 **九维**，`--skip-engine` 为 **七维**静态口径。
2. `docs/reference/acceptance.md` 是门禁名称、命令与通过判据的唯一文档事实源；其他活跃文档只写“`check_all` 总门禁”或链接该页，不再复制维度数量与清单。
3. 新增、删除或替换门禁维度必须先修改脚本并更新 `acceptance.md`；契约性变化再新增 ADR，不以 README 或历史状态表代替决策。
4. ADR-012 的八维清单保留为历史基线；其零错误零警告、不得跳过检查、白名单冻结等结论继续有效。
5. 本次变更不改变任何门禁的通过条件、阈值或退出码。

## 后果

- 活跃文档不再各自维护门禁维度表，减少漂移；
- `acceptance.md` 需要承担完整门禁说明，其他文档以链接导航；
- 历史 ADR、归档验证记录中的八维表述保持原貌，不回写历史。

## 备选方案

| 方案 | 未采用原因 |
|:---|:---|
| 保留八维文案，把 DragonBones 当作“非维度检查” | 与 `check_all.py` 实际输出和 `acceptance.md` 九维矛盾，继续制造多事实源 |
| 删除 ADR-012 并改写为九维 | 违反已接受 ADR 不直接改写的治理规则，丢失历史决策 |
| 把维度数量完全从文档中删除 | 验收文档仍需描述实际门禁；保留一个 canonical 位置更可审计 |

## 证据

- [`../../scripts/check_all.py`](../../scripts/check_all.py)：维度 1~9 的任务定义。
- [`../reference/acceptance.md`](../reference/acceptance.md)：L0/L1 验收与九维说明。
- [`ADR-012`](ADR-012-zero-error-zero-warning-quality-gates.md)：历史八维与零错误零警告基线。
- [`../reference/status.md`](../reference/status.md)：最新门禁执行记录。
