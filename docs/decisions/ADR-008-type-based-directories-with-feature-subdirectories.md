# ADR-008：保留类型分层目录，新功能按功能子目录聚合

- **状态**：Accepted
- **记录日期**：2026-10-25
- **影响范围**：目录结构、新功能落位、迁移边界

## 背景

`source/` 顶层按 `Scene/`、`Script/`、`Art/` 等类型划分，这是 Flash 迁移形成的历史结构。Godot 官方更推荐按功能聚合，但全量搬迁会触及 UID、场景引用、导入缓存与门禁基线。

## 决策

1. 保留现有顶层类型目录，不立即全量改为功能优先；
2. 新功能在现有顶层目录下建立**功能子目录**，例如：
   - `Scene/<feature>/`
   - `Script/<feature>/`
   - `Art/<feature>/`
3. 不在同一功能中再建立第二套并行目录体系；
4. 不新增顶层类型目录，除非经过独立架构评审；
5. 目录/文件命名继续遵循 [`naming_standard.md`](../standards/naming_standard.md)；
6. 涉及目录搬迁必须单独立项，先提交迁移方案，并使用 `scripts/rename_path.py`。

## 后果

- 现有引用与导入缓存保持稳定，避免大范围断裂；
- 新功能仍能在现有结构下按领域聚合；
- 目录结构会长期呈现“类型分层为主、功能子目录为辅”的混合形态；
- 迁移必须按批次执行，每批完成引用扫描、UID/`.import` 同步与门禁。

## 备选方案

| 方案 | 未采用原因 |
|:---|:---|
| 立即全量改为功能优先 | 引用面巨大，UID/导入缓存与场景路径风险高 |
| 保持现状，不设新目录规则 | 新功能落位随意，继续堆积 |
| 新建第二套并行分层 | 两套结构并存，更难维护 |

## 证据

- [`../standards/godot_design_standard.md`](../standards/godot_design_standard.md) §5
- [`../standards/naming_standard.md`](../standards/naming_standard.md) §1
- [`../reference/architecture.md`](../reference/architecture.md) §1.3、§8
- [`../guides/migration_playbook.md`](../guides/migration_playbook.md) §2
