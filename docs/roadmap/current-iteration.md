# BHYH Current Iteration

> **用途**：维护当前候选阶段与已命名后续阶段的启动条件、实施顺序与验收；长期路线与总体架构顺序以 [roadmap](roadmap.md) 为唯一来源。
>
> **当前状态**：**Phase 14 数据契约与 AtlasMetadata typed accessor 已规划，未启动**。Phase 13 已完成并归档；Phase 15/16 为已命名后续候选，不进入当前批次。
>
> **版本边界**：内容版本保持 **6.9**；以下阶段均为内部架构治理，不新增玩法、任务、掉落或数值内容。
>
> **事实基线**：[`../reference/status.md`](../reference/status.md)、[`../reference/architecture.md`](../reference/architecture.md)、[`../reference/acceptance.md`](../reference/acceptance.md)
>
> **Phase 13 归档**：[`../archive/iteration_13_visual_asset_contract.md`](../archive/iteration_13_visual_asset_contract.md)。

---

## 0. 阶段队列与边界

| 阶段 | 主题 | 状态 | 入口 |
|:---|:---|:---|:---|
| Phase 14 | 数据契约与 AtlasMetadata typed accessor | **规划完成，未启动** | 本文 §1~§3 |
| Phase 15 | 全局状态与 Autoload 边界 | **已命名，初步规划** | Phase 14 收口后 |
| Phase 16 | 结构与场景现代化 | **已命名，初步规划** | Phase 14/15 收口后审计 |
| Spine 跨平台运行时 | 平台依赖与发布验收 | **独立项目** | roadmap / 平台条件满足后 |
| 7.0 内容回植 | 内容版本迁移 | **未确认** | migration_playbook §5.1 |

本文只展开当前候选 Phase 14；Phase 15/16 只保留启动条件，不提前拆任务。任一阶段启动前必须由用户确认，并先补齐该阶段的范围、批次与验收。

---

## 1. Phase 14：数据契约与 AtlasMetadata typed accessor

**对应契约**：目标架构契约 §4.1（类型、标识与共享）、§4.2（资源校验与失败）、§4.3（UID/发布依赖）
**依据**：[`../reference/architecture.md`](../reference/architecture.md) §5 数据分层、§6 资源层、§9 遗留例外
**依赖**：Phase 13 归档完成
**状态**：规划完成，未启动；不改变运行时行为。

### 1.1 目标

把 `AtlasMetadata.data` 从“外部可直接读写的裸字典”收敛为：

1. `AtlasMetadata` 内部的序列化边界；
2. 对外只暴露强类型 accessor/value object；
3. 构建期校验 schema，运行时失败显式传播；
4. 新消费者不再增长裸字符串键依赖。

本阶段不把 AtlasMetadata 改造成所有视觉资产必须经过的中间层，也不把现有 Spine/FrameSequence 统一成同一播放器。

### 1.2 当前事实

| 项目 | 当前状态 |
|:---|:---|
| `AtlasMetadata` | `Resource`，`data: Dictionary`，`validate()` 只做浅层 schema 检查 |
| `AtlasMetadataStore` | 缓存并返回裸 `Dictionary`；路径缺失/schema 失败已显式报错 |
| 已登记 schema 形态 | `pages + sequences`；`animation + frames + back/front atlases`；`files`；`__top_level=array` |
| 直接消费者 | `cloud_boss`、`east_continent_monster`、`north_continent_monster`、`palace_boss_projectile`、`palace_flying_boss`、`mount_visual` |
| 已移除消费者 | `main_sword_array_weapon` 已在 Phase 13-2C 删除 Atlas 回退 |
| 构建期入口 | `scripts/convert_atlas_metadata.py`、`metadata.tres`、Atlas manifest |

`AtlasMetadata.data` 同时存在多种 schema，**不得用一个统一 typed model 强行覆盖全部形态**；typed accessor 必须按 schema 分派。

### 1.3 批次 14-1：消费者与 schema 清单

**目标**：先建立可审核的迁移账本，不改代码行为。

任务：

1. 枚举所有 `AtlasMetadataStore.data_for`、`AtlasMetadata.data`、`metadata.tres` 消费者与构建期生产者；
2. 按 schema 形态分类：
   - `pages + sequences`（图集序列）；
   - `animation + frames + back_atlases/front_atlases`（动画元数据）；
   - `files`（文件映射）；
   - `__top_level=array`（顶层数组）；
3. 记录每个消费者使用的键、动画名、页引用、region/margin 与失败分支；
4. 建立迁移批次：boss/怪物 → palace/mount → 其余；
5. 明确哪些键属于稳定 schema，哪些只是转换器输出细节。

产物：`docs/reference/atlas_metadata_schema.md`（或在 `architecture.md` 增加可审核 schema 表）。

出口：

- 所有直接消费者均可归属到 schema；
- 不存在“未知 schema”的隐式消费者；
- 新增 ADR 草案，记录 typed accessor 与 `.data` 迁移边界。

### 1.4 批次 14-2：typed accessor 与构建期校验

**目标**：在保留 `.data` 序列化边界的前提下，提供强类型访问。

设计原则：

- `.data` 仍由 `@export` 用于 `.tres` 序列化，不直接暴露给业务消费者；
- 新增 `AtlasMetadataStore.metadata_for(path) -> AtlasMetadata` 或等价入口；
- 类型建议：
  - `AtlasPage`、`AtlasFrame`、`AtlasSequence`、`AtlasAnimation`、`AtlasFileEntry`；
  - 由 `AtlasMetadata` 提供 `pages()`, `sequences()`, `animation()`, `files()`, `items()` 等 typed accessor；
  - 不在 accessor 内做后端选择，不返回可写共享状态；
- schema 校验一次并在资源加载时缓存；缺失字段、错误数组长度、非法 region、未注册 schema 明确失败；
- 页面/纹理引用保持共享，不复制 `Texture2D` 或页数据；
- 增加负向测试：错误类型、空序列、数组长度不一致、缺失页、非法时间/区域；
- 构建期 `convert_atlas_metadata.py --check` 校验 typed 字段与 `.data` 序列化后的等价性。

出口：

- typed accessor 覆盖四种 schema；
- `--check` 与负向测试通过；
- schema 不合法时消费者拒绝生成，不切换旧路径或空占位。

### 1.5 批次 14-3：消费者迁移

按域迁移，保持视觉与数值行为不变：

| 批次 | 消费者 | 重点 |
|:---|:---|:---|
| 14-3A | `cloud_boss`、`east_continent_monster`、`north_continent_monster` | 图集序列、页引用与动画名 |
| 14-3B | `palace_boss_projectile`、`palace_flying_boss`、`mount_visual` | animation/frames、back/front atlases、mount 视图 |
| 14-3C | 其余通过 `metadata.tres` 或字符串键读取的消费者 | 清零外部 `data` 访问 |

约束：

- 不修改 Atlas 资源内容；不改变 region/margin、页路径、UID；
- 不恢复任何运行时回退；
- 每批单独提交，保持可回滚；
- 迁移后补一个只读访问审计，阻断新增直接 `.data` 访问。

### 1.6 批次 14-4：边界冻结

- 业务代码不再直接读 `AtlasMetadata.data`；
- `AtlasMetadataStore.data_for` 如需保留，只能作为内部/迁移适配器，并标注 deprecated 或改为私有；
- `convert_atlas_metadata.py --check` 进入契约门禁；
- 更新 `architecture.md`、`acceptance.md`、`scripts/README.md` 与 ADR；
- 记录仍未 typed 化的 schema 或消费者，作为明确例外而非隐式欠债。

### 1.7 出口标准

- 消费者清单中不存在未登记的 `.data` 直接访问；
- 四种 schema 均有 typed accessor 与负向测试；
- `convert_atlas_metadata.py --check`、`contract_gate`、`check_all` 通过；
- `health_check` 0 Parse / 0 Error / 0 Warning；
- `scene_probe_runner` 4/4、L2 三件套、全量回归 PASS；
- 视觉资源加载路径与 frame/region/loop 行为无变化；
- 发布 PCK 闭包与 release 基线继续通过。

### 1.8 风险与处理

| 风险 | 处理 |
|:---|:---|
| 四种 schema 被强行统一 | 按 schema 分派 typed accessor，不为统一而丢字段 |
| shared AtlasTexture 被复制导致内存上升 | accessor 只返回引用；不复制页/纹理 |
| `.data` 半迁移，新代码继续读裸字典 | 增加访问审计；新代码只允许 typed accessor |
| 构建期与运行时 schema 漂移 | `--check` 校验等价性；消费者探针断言关键字段 |
| 迁移影响 Boss/坐骑显示 | 每批代表场景探针 + 全量回归；先只换读取方式，不改资源 |
| release 包体积/闭包变化 | 复用现有资源；重跑 PCK 闭包与 L2 |

### 1.9 启动条件

- Phase 14-1 清单与 ADR 草案经用户确认；
- 明确 typed accessor 的 API 形态（Resource 还是 RefCounted value object）；
- 不修改素材内容，素材变更仍走私人仓契约。

---

## 2. Phase 15：全局状态与 Autoload 边界

**状态**：已命名，未规划细节；Phase 14 收口后启动。
**对应契约**：目标架构契约 §4.1、§5.2；[`../reference/architecture.md`](../reference/architecture.md) §2、§9.1。

### 2.1 目标

降低 `global.gd` 这个大型遗留单例与 13 个 Autoload 的耦合，但不做一次性全量重写：

- 建立 Global/autoload 依赖与所有权地图；
- 先抽出纯数据、资源路径表、缓存/池、场景切换/UI 工厂等可证明边界；
- 保持 `Global.change_scene` 等现有入口作为 facade，避免全工程同时改动；
- 不新增 Autoload；新增业务能力优先 Resource、服务节点、RefCounted 或静态工具类。

### 2.2 预设批次

1. **15-1 清单与 ADR**：依赖图、初始化顺序、调用面、可测边界；冻结新 Global 业务 API。
2. **15-2 纯数据/资源表**：将常量、路径表、静态数据迁移到 typed Resource 或 Catalog；不改变场景流。
3. **15-3 场景切换与加载编排**：引入可注入的 scene/session service，`Global.change_scene` 保留 facade；验证加载页、覆盖式切换、缓存清理。
4. **15-4 UI/缓存/池**：逐步抽出 UI factory、transient UI 清理、缓存与对象池；保留 1P/2P 槽位语义。
5. **15-5 Autoload 边界复核**：评估 13 个注册项的生命周期与替代方案；不新增，是否合并另立 ADR。

### 2.3 出口与风险

- 不改变已验收玩法、场景流、存档与 1P/2P 行为；
- 新增服务有明确所有权、初始化顺序、清理路径与探针；
- `check_all`、health、L2、全量回归、PCK 通过；
- 高风险：启动顺序、`LocalCoop` 槽位路由、加载页缓存、UI 生命周期；必须分批与 ADR。

---

## 3. Phase 16：结构与场景现代化

**状态**：已命名，未规划细节；Phase 14/15 收口后先审计再决定是否启动。
**依据**：architecture §1.3、§9.1；godot_design_standard。

### 3.1 方向

- 从 `Scene/Script/Art` 类型分层逐步过渡到功能子目录聚合；
- 深层 `get_node()`/绝对路径仅在触达场景时同步清理，不做无边界批量替换；
- `_bundled` 场景先审计：当前 `source/` 中未检索到 `*bundled*` 文件，若确认已无目标，关闭该技术债条目；若发现二进制场景，再单列转换批次；
- 路径迁移必须走 `scripts/rename_path.py`，同步 UID、`.import`、引用、文档和回归。

### 3.2 预设批次

1. **16-1 审计与决策**：产出真实目录、场景、依赖、深层路径与 `_bundled` 清单；确认 `_bundled` 是否已消解，形成是否启动的 ADR。
2. **16-2 单模块试点**：选择一个边界清晰的业务模块，迁移到功能子目录；使用 `scripts/rename_path.py`，同步 UID、`.import`、引用与文档。
3. **16-3 触达场景清理**：只清理试点/迁移触达的深层 `get_node()` 与绝对路径；不做全工程无边界替换。
4. **16-4 扩展决策**：试点通过后按 ADR 决定是否分域全量迁移；未通过则保留现状并记录边界。
5. **16-5 验收**：命名/UID/断裂引用、健康、代表场景、L2、全量回归与发布闭包。

### 3.3 入口条件

- Phase 14/15 完成，Global/数据边界稳定；
- 先产出一份真实目录/依赖/场景清单，不基于历史数字；
- 单模块试点后再决定是否全量迁移；
- 不把目录迁移与玩法改动混在同一提交。

### 3.4 出口与风险

- 目录与场景身份稳定，链接、UID、`.import`、预载 Catalog 与发布依赖全部同步；
- 不把目录迁移、场景重命名与玩法重构混在同一提交；
- 深层路径清理以触达范围为准，不承诺一次清零；
- 高风险：全量场景、历史二进制场景、路径动态拼装、双人/关卡预载；必须先审计与试点。

---

## 4. 统一验收与提交规则

Phase 14 每批至少执行：

```bash
python scripts/check_all.py --godot-bin "<godot>"
python scripts/contract_gate.py
python scripts/health_check.py --project source --godot-bin "<godot>"
python scripts/scene_probe_runner.py --godot "<godot>"
python scripts/coop_probe_runner.py --godot "<godot>"
python scripts/level_test_runner.py --godot "<godot>" --level res://Scene/level/level_1.tscn
python scripts/level_regression_all.py --timeout 150
```

提交规则：

- 每批独立提交，先 schema/accessor，再消费者，再删除旧入口；
- 不保留“typed accessor 失败再读 `.data`”的双路径；
- 不修改 `source/Art` 内容；素材改动走私人仓；
- 文档与代码同批更新，结论写入 `status.md`，报告不提交。

---

## 5. 恢复入口

- 若 Phase 14 中断：按 §1.3 清单恢复，不重新猜消费者；
- 若某 schema 无法 typed 化：登记为明确例外，保留只读 accessor，不扩大裸字典面；
- 若 Phase 15 改动触发启动/双人问题：回滚该批次，保留 facade，不以兼容分支继续；
- Phase 14 收口后，将本页归档并重新评估 Phase 15 入口。
