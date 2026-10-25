# ADR-002：Godot 4.7.2 与 GDScript 2.0 基线

- **状态**：Accepted
- **记录日期**：2026-10-25
- **影响范围**：引擎版本、语言、渲染后端、升级流程

## 背景

工程从 Flash 底座迁移到 Godot 4，需要固定引擎与语言基线，避免不同机器、不同插件或不同导出目标产生行为差异。现有业务代码已按 GDScript 2.0 的类型语法与 Godot 4 节点 API 编写。

## 决策

1. 引擎固定为 **Godot 4.7.2**；
2. 业务脚本使用 **GDScript 2.0**，优先静态类型（变量、参数、返回值）；
3. 渲染配置以 `source/project.godot` 为准：默认 `mobile`，Web 使用 `forward_plus`；
4. 引擎升级必须作为独立任务，先查官方变更、再跑完整门禁与运行期夹具；
5. 不为旧引擎版本保留双分支、条件编译或兼容脚本。

## 后果

- 所有开发机、CI 与验收环境必须使用同一引擎版本；
- 升级会触及全部脚本与场景，必须单独立项，不混入功能提交；
- `source/project.godot` 是可审查配置，`.godot/` 导入缓存不入库；
- GDExtension（如 Spine）必须与引擎版本匹配，升级时同步验证。

## 备选方案

| 方案 | 未采用原因 |
|:---|:---|
| 跟随最新 Godot 次版本 | 行为与导入格式可能变化，破坏已验收基线 |
| 同时支持 Godot 4.x 多个版本 | 需要条件分支与双份验收，违背单一基线 |
| 改用 C# 或其他语言 | 现有业务、插件与工具链均为 GDScript，迁移收益不足 |

## 证据

- [`../../source/project.godot`](../../source/project.godot) `[application]`、`[rendering]`
- [`../../AGENTS.md`](../../AGENTS.md) §2.1
- [`../standards/godot_design_standard.md`](../standards/godot_design_standard.md) §1
- [`../reference/status.md`](../reference/status.md) §1
