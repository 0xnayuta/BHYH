# 项目文档索引

本目录按“参考 / 路线 / 指南 / 规范 / 报告 / 归档”分层。当前内容版本为 **6.8**，唯一活跃工程位于仓库根目录的 `source/`。

历史阶段报告与逐文件台账不再纳入仓库；可复用的迁移经验已蒸馏到 [`guides/migration_playbook.md`](guides/migration_playbook.md)。

---

## 1. 目录分层

| 目录 | 定位 | 维护方式 |
|:---|:---|:---|
| `reference/` | 当前状态、架构、验收与项目范围 | 人工维护 |
| `roadmap/` | 路线图、当前迭代与后续规划 | 人工维护 |
| `guides/` | 开发、构建、验证与迁移操作指南 | 人工维护 |
| `standards/` | 活跃规范，约束当前代码、场景与资产 | 随工程演进人工维护 |
| `reports/` | 脚本生成的机器报告 | 由脚本按需生成，不提交历史报告 |
| `archive/` | 已完成但仍有长期参考价值的文档 | 归档后原则上只读；入口见 [`archive/README.md`](archive/README.md) |

### 未来按需增加

- `decisions/`：出现第一条 ADR 时创建；
- `issues/`：出现正式已知问题清单时创建；
- `reference/` 下可继续增加架构、验收、项目范围文档。

---

## 2. 活跃文档

| 文档 | 内容 |
|:---|:---|
| [`reference/README.md`](reference/README.md) | 参考文档目录索引 |
| [`reference/status.md`](reference/status.md) | **当前状态单一事实源**：版本、目录、规模、门禁与验收基线 |
| [`roadmap/README.md`](roadmap/README.md) | 路线图目录索引 |
| [`roadmap/roadmap.md`](roadmap/roadmap.md) | 当前版本之后的开发路线 |
| [`roadmap/current-iteration.md`](roadmap/current-iteration.md) | 6.9 补丁回植当前迭代：范围、文件映射、实施批次与验收；6.9-1 至 6.9-5 已完成 |
| [`guides/README.md`](guides/README.md) | 操作指南目录索引 |
| [`guides/migration_playbook.md`](guides/migration_playbook.md) | 下一次版本迁移的方法、阶段与红线 |
| [`standards/README.md`](standards/README.md) | 规范目录索引、效力边界与修订流程 |
| [`standards/naming_standard.md`](standards/naming_standard.md) | 全工程命名规范与契约白皮书 |
| [`standards/godot_design_standard.md`](standards/godot_design_standard.md) | Godot 现代项目设计规范（场景、Resource、Autoload、结构） |
| [`standards/naming_whitelist.md`](standards/naming_whitelist.md) | 命名白名单与机器导出冻结登记 |
| [`standards/missing_assets_registry.md`](standards/missing_assets_registry.md) | 缺失资产登记与恢复台账 |
| [`standards/spriteframes_generation_policy.md`](standards/spriteframes_generation_policy.md) | SpriteFrames 生成策略（FPS、循环命名、speed 语义） |

---

## 3. 机器报告

`reports/` 中的文件由脚本生成，随时可能被覆盖，不纳入版本历史。需要长期保留的结论写入 [`reference/status.md`](reference/status.md)。

常用入口：

```bash
python scripts/check_all.py --skip-engine
python scripts/contract_scan.py --project-dir source --fail-on-error
python scripts/naming_compliance_audit.py --fail-on-error
python scripts/level_regression_all.py --jobs 4 --timeout 90
```

报告与生成脚本的对应关系见 [`reports/README.md`](reports/README.md)。

---

## 4. 归档

`archive/` 用于保存已完成、不再活跃、但对后续开发仍有参考价值的文档。

| 入口 | 内容 |
|:---|:---|
| [`archive/README.md`](archive/README.md) | 归档标准、命名约定、流程与索引 |

归档不接收机器报告、临时台账、旧路径映射和仅用于历史取证的原始材料；可复用的迁移方法见 [`guides/migration_playbook.md`](guides/migration_playbook.md)。

---

## 5. 维护约定

1. **规范优先**：代码、场景、资产改动必须先符合 `standards/`；
2. **报告不手改**：报告由脚本生成，结论写入 `reference/status.md`；
3. **文档分层**：当前事实放 `reference/`，计划放 `roadmap/`，操作步骤放 `guides/`，规范放 `standards/`；
4. **文档归档**：已完成且有长期价值的文档移入 `archive/`；不保留旧路径映射与历史阶段原始报告；
5. **状态单一事实源**：版本、规模与门禁结果统一维护在 `reference/status.md`；
6. **链接可验证**：移动文档后必须同步更新相对链接并重新检查。
