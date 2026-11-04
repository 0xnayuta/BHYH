# ADR-025：原始数据导出闭包契约

- **状态**：Accepted
- **记录日期**：2026-11-04
- **关联**：ADR-006、ADR-015、ADR-020、ADR-024

## 背景

运行时仍有一批通过 `FileAccess` 直接读取的 JSON/BIN 数据，例如官方部件/坐骑姿态、玉兔装备定义、关卡地形与北俱芦洲数据。它们不是 Godot Resource，`export_filter="all_resources"` 不能保证 `.bin` 进入 PCK；历史验证也证明最小工程导出 `all_resources` 只包含 JSON，不包含 BIN。

以 `include_filter="*.bin"` 兜底可以临时修复路径缺失，但它把导出闭包交给字符串通配，无法说明哪些文件是运行时依赖，也无法阻止未来新增原始数据漏出。ADR-020 第 7 条要求延迟/非资源依赖形成单独发布依赖清单，并验证实际导出闭包；本 ADR 将这一要求落到可执行的构建与发布契约。

## 决策

1. **原始数据仍以原始格式存在**，不因导出问题在本批次强制转换为 Resource。新结构化数据仍遵守 ADR-006 的 Resource 优先规则。
2. **唯一手工配置是根清单**：`scripts/export_raw_roots.json` 登记根目录、扩展名与消费者；`scripts/export_raw_manifest.py --write` 从当前素材树生成 `source/Script/data/export_raw_dependencies.json`，`--check` 校验清单、素材、生产脚本字面量与导出配置。
3. **导出路径由清单驱动**：`source/addons/bhyh_export` 的 `EditorExportPlugin` 读取生成清单，对每个文件调用 `add_file(path, bytes, false)`；在 `_export_file` 中对已加入路径调用 `skip()`，避免与普通资源导出重复。导出时不再扫描目录，也不使用 `include_filter` 兜底。
4. **`all_resources` 只负责 Godot 资源基线**，不能作为原始数据闭包证明。`include_filter` 不再承担原始数据导出职责。
5. **实际 PCK 是最终证据**：`scripts/export_closure_probe.py` 使用同一清单实际导出 PCK，在最小工程挂载后逐条校验 JSON/BIN 可由 `FileAccess` 读取；插件日志必须报告 `files == expected` 且 `missing == 0`。
6. **发布包装 fail-closed**：`scripts/export_release.py` 先校验清单，再运行 PCK 探针；可选执行 release 导出。任一步失败不得进入发布。
7. **公开 clone 明确 BLOCKED**：素材目录缺失时，构建/探针返回 `BLOCKED`，不得伪造 PASS；编辑器导出手动操作若插件未启用或清单缺失，日志必须给出可操作错误。

## 后果

- 新增原始数据必须先登记根/文件并重新生成清单；`--check` 会阻断未登记的生产脚本字面量。
- 导出插件、清单与 PCK 探针共享同一事实源，避免三处路径漂移。
- 不再需要维护 `*.bin` 通配兜底；资源基线仍由 `all_resources` 管理。
- Resource 化仍是可选的后续数据架构迁移：当某类原始数据需要 Resource 身份、编辑器依赖图或跨平台导入能力时，另立 ADR 与批次，不在本契约中静默混做。
- 实际 PCK 证明路径可达，不等于 release 冷启动、目标设备 VRAM 或首帧耗时已验证；这些仍按 ADR-020/验收矩阵单独记录。

## 备选方案

- **继续使用 `include_filter="*.bin"`**：拒绝。它无法表达依赖、无法覆盖 JSON 语义，也无法防止新原始数据漏出。
- **把所有 FileAccess JSON/BIN 转成 Resource**：暂不采用。会改变数据格式、加载器、构建链与内存行为，影响面大于导出闭包；在现有原始格式继续运行时，声明式清单是 ADR-020 已允许的标准闭包方案。
- **只在探针里维护第二份路径清单**：拒绝。与导出插件重复声明，必然漂移。
- **只检查 `export_presets.cfg`**：拒绝。配置级检查不能证明实际 PCK 包含文件。

## 证据

- [ADR-020](ADR-020-typed-visual-assets-and-streaming-lifecycle.md) 第 7 条：延迟加载路径必须形成单独发布依赖清单，并验证实际导出闭包。
- [ADR-006](ADR-006-resource-first-data-and-data-keys.md)：新结构化数据优先 Resource；本 ADR 只处理既有原始数据的导出闭包，不扩张为无边界的数据格式迁移。
- `scripts/export_raw_roots.json`、`scripts/export_raw_manifest.py`、`source/Script/data/export_raw_dependencies.json`
- `source/addons/bhyh_export/export_plugin.gd`
- `scripts/export_closure_probe.py`、`scripts/export_release.py`
- `docs/reference/acceptance.md` 的原始数据导出闭包门禁。
