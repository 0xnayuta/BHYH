# ADR-012：零错误零警告与八维门禁为合并门槛

- **状态**：Accepted
- **记录日期**：2026-10-25
- **影响范围**：提交、评审、发布、工具链

## 背景

工程规模大、历史包袱多，仅靠人工检查无法阻止命名漂移、路径大小写错误、失效 NodePath、运行时 manifest 解析与静态警告回归。需要可重复、可自动化的门槛。

## 决策

1. 完整工作区必须保持 **0 ERROR / 0 WARNING**；
2. 每次提交至少执行：
   ```bash
   python scripts/check_all.py --skip-engine
   ```
3. 涉及运行时、场景、资源、输入、物理层时执行：
   ```bash
   python scripts/check_all.py --godot-bin "<godot>"
   ```
4. `check_all.py` 八维为：行尾、格式、gdlint、引擎健康、契约域、命名、运行时引用、资源路径；
5. 契约域 ERROR 必须为 0，WARNING 不得超过当前预算（1050）；
6. 命名白名单冻结，新增豁免必须评审；
7. 涉及玩法/关卡/双人/HUD 时追加运行期夹具；
8. 不得通过删除检查、扩大白名单、跳过维度或把失败改写成警告来通过门禁。

## 后果

- 大多数结构性问题在提交前暴露；
- 门禁本身需要维护，规则变更必须同步文档与脚本；
- 当前覆盖仍有边界：`gdlint` 只覆盖 10 个核心脚本，`health_check` 不把普通 `ERROR:` 计入失败，严格 `0 ERROR` 由关卡冒烟补充；
- 历史“七维 7/7”是 `--skip-engine` 口径，不是另一套门禁。

## 备选方案

| 方案 | 未采用原因 |
|:---|:---|
| 只做人工 Code Review | 无法覆盖全量路径、命名与契约 |
| 只跑编译，不跑契约/命名 | 编译通过不代表资源路径与引用有效 |
| 允许 WARNING 无限增长 | 警告会被忽略，最终失去信号价值 |

## 证据

- [`../reference/acceptance.md`](../reference/acceptance.md) §3–§8
- [`../../scripts/check_all.py`](../../scripts/check_all.py)
- [`../../scripts/README.md`](../../scripts/README.md) §2、§3
- [`../reference/status.md`](../reference/status.md) §4、§5
