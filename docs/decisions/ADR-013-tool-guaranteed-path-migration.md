# ADR-013：`source/` 内路径迁移只走 `rename_path.py`

- **状态**：Accepted
- **记录日期**：2026-10-25
- **影响范围**：文件/目录重命名、引用同步、UID/`.import`、回滚

## 背景

工程同时存在 `.gd`、`.tscn`、`.tres`、`.import`、`.uid`、动画轨道、Autoload、字典键与 `res://` 路径引用。手工改名或单步 `git mv` 容易漏改大小写、场景 `ext_resource`、动画轨道或导入缓存，导致跨平台断裂。

## 决策

1. `source/` 内的文件/目录重命名**必须且仅能**通过 `scripts/rename_path.py`；
2. 禁止在操作系统中直接改名，禁止单步 `git mv old new`；
3. 迁移必须同步：
   - `res://` 引用与 `ext_resource`；
   - `.import`、`.uid` 与导入缓存；
   - Autoload 路径、场景挂载脚本、动画轨道；
   - 字典键/UI 文案/白名单（如涉及）；
4. 单批次 ≥ 3 个文件或涉及 `.gd/.tscn/.tres/.import/.json` 引用时，必须在提交信息中登记迁移范围、引用同步与白名单例外；
5. 迁移后运行静态门禁、命名审计与受影响关卡冒烟；
6. `docs/` 与 `scripts/` 不适用该工具，使用普通文件移动/`git mv` 并更新相对链接。

## 后果

- 大小写与引用同步由工具保证，支持失败回滚；
- 迁移速度比手工改名慢，但可审计；
- 工具本身成为关键路径，修改后必须做负向测试；
- 大批量迁移仍需单独立项并分批验收。

## 备选方案

| 方案 | 未采用原因 |
|:---|:---|
| 手工改名 + 全局搜索替换 | 易漏场景轨道、UID、大小写 |
| 依赖 Windows 大小写不敏感 | Linux/macOS/Android 导出会失败 |
| 一次性大迁移 | 回归面过大，难以定位失败 |

## 证据

- [`../standards/naming_standard.md`](../standards/naming_standard.md) §1.3、§7.2
- [`../../scripts/README.md`](../../scripts/README.md) §3.3
- [`../../AGENTS.md`](../../AGENTS.md) §8.1
- [`../guides/migration_playbook.md`](../guides/migration_playbook.md) §2
