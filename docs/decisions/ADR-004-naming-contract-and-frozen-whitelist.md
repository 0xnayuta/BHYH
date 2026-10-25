# ADR-004：全工程命名契约与冻结白名单

- **状态**：Accepted
- **记录日期**：2026-10-25
- **影响范围**：目录、文件、场景树节点、代码标识符、数据键、资源路径

## 背景

工程同时包含 Godot 原生资源、Flash 反编译产物、TexturePacker 图集、Spine 资源与第三方插件。Windows 开发与 Linux/macOS/Android 导出之间的大小写差异，曾导致资源路径、节点路径与动画轨道断裂。

## 决策

1. 执行 [`naming_standard.md`](../standards/naming_standard.md)：
   - `source/` 顶层历史目录（`Scene/`、`Script/`、`Art/` 等）保留，其内部业务目录统一 `snake_case`；
   - 文件统一 `snake_case`；
   - `.tscn` 场景树节点统一 `PascalCase`；
   - 函数/变量/信号 `snake_case`；常量 `UPPER_SNAKE_CASE`；`class_name`/枚举 `PascalCase`；
   - 字典键统一通过 `DataKeys` 访问；
2. 路径引用必须与磁盘字节大小写逐字一致；
3. 机器导出结构（`DefineSprite_*`、`*.sprites`、`symbolClass`、`*-assets`）、数字 ID 目录/场景、第三方插件进入**精确冻结白名单**；
4. 白名单只减不增；新增条目必须评审、登记并更新冻结摘要；
5. 目录/文件改名只允许通过 `scripts/rename_path.py`；
6. 门禁：`naming_audit.py`、`naming_compliance_audit.py`、`whitelist_audit.py`、`contract_scan.py`。

## 后果

- 跨平台路径与节点引用稳定，减少“Windows 能跑、导出失败”的问题；
- 机器导出资产不会被误改名，但白名单会长期存在；
- 新增文件若违反规范会被门禁拦截；
- 存量命名债务必须逐步下降，不能以历史原因新增豁免。

## 备选方案

| 方案 | 未采用原因 |
|:---|:---|
| 保留 Flash 原始命名 | 与 Godot 官方约定冲突，大小写问题持续 |
| 依赖 Windows 大小写不敏感 | 导出平台与 Git 检出会暴露差异 |
| 用通配符自动放行机器导出 | 会掩盖新增违规，无法审计 |

## 证据

- [`../standards/naming_standard.md`](../standards/naming_standard.md) §0–§7
- [`../standards/naming_whitelist.md`](../standards/naming_whitelist.md) §0–§2
- [`../../scripts/README.md`](../../scripts/README.md) §3.2
- [`../reference/acceptance.md`](../reference/acceptance.md) §7
