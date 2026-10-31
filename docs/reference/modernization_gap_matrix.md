# 现代化差距矩阵（Phase 31 候选依据）

> **状态**：2026-10-31 完成静态调查与分级；**本页只登记差距与建议批次，不实施**。Phase 31/32/33 为候选阶段，是否启动与何时启动以 [`roadmap.md`](../roadmap/roadmap.md) 为准。
> **范围**：`source/` 内的场景、脚本、资源与 UI 样式。不含第三方 `addons/`、`bin/`，不含素材本身（素材边界见 [ADR-011](../decisions/ADR-011-public-repository-asset-boundary.md)）。
> **事实快照**：2026-10-31 私有完整工作区静态扫描；数字随迭代变动，不承诺长期不变。运行时行为未实测的部分已标注。
> **依据**：[`target_architecture_contract.md`](../standards/target_architecture_contract.md)、[`godot_design_standard.md`](../standards/godot_design_standard.md)、[`architecture.md`](architecture.md)、[`status.md`](status.md)、[ADR-006](../decisions/ADR-006-resource-first-data-and-data-keys.md)、[ADR-023](../decisions/ADR-023-level-layout-data-contract.md)。

---

## 1. 决策摘要

**结论：核心架构已是现代的；剩余 6 项真实差距，其中仅 2 项达到「契约重构」级别，其余为 API 迁移或普通重构。**

| 判断 | 内容 |
|:---|:---|
| 已现代化、无需立项 | 场景切换单一入口、`_process` 无 IO、无 Godot 3 遗留 API、构建期数据管线、`Global` 工厂族收口 |
| 达到契约重构级别 | **B1 UI Theme 层**、**B3 装备数据**（与 Phase 30 同构：数据形态 + 多消费者 + 需要生成器） |
| 属 API 迁移 | **A1 视差节点**、**A2 `TileMap`** |
| 属普通重构 | **B4 具名物理层**、**B5 重复函数** |
| 不立项、随域收敛 | **B6 硬编码路径**、**B7 超大场景**、**B8 `Global` 调用密度** |
| 外部约束、非架构问题 | **C1 Spine 版本** |

**最重要的一条不一致**：同一引擎内并存两套视差实现——外部导入的 1,701 个关卡场景使用现代 `Parallax2D`，BHYH 原有 89 个场景使用**已废弃**的 `ParallaxLayer`。

---

## 2. 量化基线

### 2.1 工程规模

| 指标 | 数值 | 口径 |
|:---|---:|:---|
| `.tscn` 场景总数 | **2,836** | `find source/Scene -name '*.tscn'` |
| 节点总数 | **93,633** | `grep -rh '^\[node '` |
| BHYH 原有场景 | ~1,135 | 总数减去外部导入 1,701 |
| 外部（ZMWS）导入场景 | **1,701** | `source/Scene/level/zmws/` |
| `source/Script/data` 体量 | 583 KB / 19,949 行 | `du`、`wc -l` |

### 2.2 关键计数

| 项 | 数值 | 判定 |
|:---|---:|:---|
| `ParallaxLayer` 场景 | **89** | A1 废弃 |
| `ParallaxBackground` 场景 | **1**（`base_through_level.tscn`，所有关卡基类） | A1 废弃 |
| `Parallax2D` 场景 | **1,701** | 现代，仅外部导入 |
| `TileMap` 节点 | **1**（`base_through_level.tscn:193` 的 `floor`） | A2 废弃 |
| `theme_override_*` | **6,830** | B1 |
| `.theme` 资源 | **0** | B1 |
| 场景引用 `theme` | **2** | B1 |
| `FontFile` 场景级 `ext_resource` | **207** | B1（字体未集中） |
| `Label` / `Button` / `TextureRect` / `Control` 节点 | 851 / 351 / 217 / 70 | B1 影响面 |
| `Art/all_number` 手工拼数字 | 25 处 / 3 文件 | B2 |
| `func load_item_icon` 定义数 | **19** | B5 |
| `Global.<member>` 调用点 | **2,832** | B8 |
| 脚本内硬编码 `"res://…"` 字符串 | **1,981** | B6 |
| `collision_layer = <整数>` | **30** | B4 |
| `all_equipment_data.gd` | **19,185 行** | B3（占 `Script/data` 的 96%） |
| 最大单场景 `level_85.tscn` | **1,030 节点**（1,022 个 `Sprite2D`） | B7 |

### 2.3 已经健康的部分（不做）

| 项 | 实测 | 依据 |
|:---|:---|:---|
| 场景切换绕过 `Global.change_scene` | **0 处** `get_tree().change_scene` | `architecture.md` §9.1 |
| `_process` / `_physics_process` 内的查找与加载 | **0 处** | `target_architecture_contract.md` §8 |
| Godot 3 遗留 API（`yield`、`instance()`） | **0 处** | ADR-002 |
| 构建期数据管线 | `LevelPreloadCatalog`、`AtlasMetadata`、`FrameSequence` 三段式已落地 | `architecture.md` §9.2 |
| `Global.add_*` 工厂 | 21-3A~J 已全部收口为薄转发 | `current-iteration.md` §4 |

---

## 3. 差距清单

### 3.1 A 级：直接违反 Godot 官方废弃/推荐

#### A1 视差节点使用已废弃 API

| 项 | 内容 |
|:---|:---|
| 现状 | `ParallaxBackground` + `ParallaxLayer`，**89 个场景** + 关卡基类 `base_through_level.tscn` |
| 官方依据 | `ParallaxLayer` 类文档：*Deprecated: Use the Parallax2D node instead.*；2D Parallax 教程：*recommended to use over the ParallaxLayer and ParallaxBackground nodes* |
| 内部不一致 | 外部导入的 1,701 个关卡场景已是 `Parallax2D`，与新老两套并存 |
| 语义映射 | `ParallaxLayer.motion_scale` → `Parallax2D.scroll_scale`；`motion_mirroring` → `repeat_size`；`ParallaxBackground.scroll_offset` → `screen_offset` |
| 结构变化 | 容器层 `ParallaxBackground` 消失，每个 `ParallaxLayer` 变为独立 `Parallax2D`，**不是纯文本替换** |
| 风险 | 89 个场景的视觉表现需逐个对照；`level_1.tscn` 等被大量关卡继承 |
| 处置 | **Phase 31-1**；验收必须含截图前后对照，不能只跑静态门禁 |

#### A2 `TileMap` 使用已废弃 API

| 项 | 内容 |
|:---|:---|
| 现状 | `base_through_level.tscn:193`：`[node name="floor" type="TileMap"]`，位于 `BackGround/floor_2` 下 |
| 官方依据 | `TileMap` 类文档：*Deprecated: Use multiple TileMapLayer nodes instead.* |
| 影响 | 基类场景 1 个 `TileMap` 节点；**12 个关卡场景有 `layer_0/tile_data` 覆盖、15 个有 `tile_set` 覆盖**，不能按单行替换 |
| 处置 | **Phase 31-0**；官方编辑器提供图层提取，改动面小 |

### 3.2 B 级：结构性问题

#### B1 UI 无 Theme 层（**最像 Phase 30 的契约缺失**）

| 项 | 内容 |
|:---|:---|
| 现状 | `theme_override_*` **6,830 处**内联样式；`.theme` 资源 **0 个**；场景仅 **2 处**引用 `theme`；`FontFile` 场景级引用 **207 处** |
| 影响面 | 851 个 `Label`、351 个 `Button`、217 个 `TextureRect`、70 个 `Control` |
| 问题 | 改一个全局字号/颜色要改 6,830 处；无法主题切换；字体在多场景重复引用；新增 UI 无统一层级 |
| Godot 推荐 | `Theme` 资源集中管理 + `theme_type_variation` 做变体 |
| 为什么算契约 | 有「定义形态（Theme + 变体命名）+ 大量消费者（6,830 处）+ 需要迁移规则」三要素 |
| 风险 | **视觉回归面覆盖全部 UI**，是全部候选中风险最高的一项 |
| 处置 | **Phase 32**；必须先做 1 个面板试点并截图对照，试点通过才允许分批 |

#### B2 数字显示靠手工拼 Sprite2D

| 项 | 内容 |
|:---|:---|
| 现状 | `Art/all_number/*/level_0.png` 等；3 个文件 25 处 `number_1.texture = load(...)` 逐位拼接 |
| 影响 | 无法用 `Label`；排版逻辑手写且重复；换字号要改图 |
| 现成替代 | 已导入 7 个 BMFont（`Font/zmws_bmfont/`，见 [`level_layout_contract.md`](level_layout_contract.md) 关联的外部资产交付记录） |
| 处置 | **Phase 31-0**；消费方仅 3 个文件，成本最低 |

#### B3 装备数据是 19,185 行单个 GDScript

| 项 | 内容 |
|:---|:---|
| 现状 | `source/Script/data/all_equipment_data.gd` **19,185 行**，占 `Script/data` 的 96% |
| 问题 | 加载即全量编译；不可 Inspector 审查；字段无类型契约 |
| 与 ADR-006 关系 | 该文件是**静态装备定义**，属 ADR-006「新结构化静态数据优先 Resource」的管辖对象；与 `current-iteration.md` §1.2「不把 `PlayerData.player_data` 整体改成 Resource」不冲突（后者是可变档案） |
| 处置 | **Phase 33**；需生成器 + 全量数值回归（装备属性必须逐字段不变） |

#### B4 `collision_layer` 使用裸整数

| 项 | 内容 |
|:---|:---|
| 现状 | **30 处** `collision_layer = <整数>` |
| 规范依据 | `godot_design_standard.md` §6：物理层使用具名层；碰撞掩码不得使用无注释的裸整数 |
| 处置 | **Phase 31-0**；提取具名常量，改动面小 |

#### B5 同一函数重复定义

| 项 | 内容 |
|:---|:---|
| 现状 | `func load_item_icon` **19 处**重复定义（`back_pack.gd`、`box_1.gd`、`main_backpack.gd`、`sell_or_equ.gd`、`buff.gd` 等） |
| 问题 | 修改一处逻辑要改 19 个文件；实现存在细微差异（有的带 fallback、有的不带） |
| 处置 | **Phase 31-0**；提取共享实现（含缓存）并逐处替换 |

#### B6 脚本内硬编码 `res://` 路径

| 项 | 内容 |
|:---|:---|
| 现状 | **1,981 处**字符串路径 |
| 问题 | 路径迁移需全仓搜索；字符串路径不计入导出依赖（同 [`ADR-023`](../decisions/ADR-023-level-layout-data-contract.md) 决策 5 的论证） |
| 处置 | **不单独立项**；随各业务域治理逐步收敛（已收敛的例子：`LevelPreloadCatalog`、`AtlasMetadata`） |

#### B7 超大单场景

| 项 | 内容 |
|:---|:---|
| 现状 | `level_85.tscn` **1,030 节点**，其中 **1,022 个 `Sprite2D`** |
| 问题 | 违反「场景单一职责、可复用子场景」；编辑器操作与版本控制成本高 |
| 处置 | **不单独立项**；个案评估，通常是关卡美术堆叠，拆分需美术侧确认 |

#### B8 `Global` 调用密度

| 项 | 内容 |
|:---|:---|
| 现状 | `Global.<member>` 调用 **2,832 处**；最高 `add_message_show` 332、`add_bullet` 300、`get_audio_runtime` 289 |
| 已有约束 | ADR-007：`global.gd` 不再接收新业务职责；21-3 已完成工厂族收口 |
| 处置 | **不单独立项**；继续按职责域收口，不追求「减到某个数字」 |

### 3.3 C 级：外部约束

| 编号 | 问题 | 结论 |
|:---|:---|:---|
| C1 | Spine 运行时仅支持 4.x，外部源为 3.7/3.8 | [ADR-010](../decisions/ADR-010-spine-runtime-boundary.md) 已定边界；受商业软件授权约束，**不是架构落后**，不纳入本矩阵的批次建议 |
| C2 | Autoload 11 个 | [ADR-007](../decisions/ADR-007-autoload-boundary.md)：遗留基线，不设数量目标 |
| C3 | 关卡数据硬编码在 84 个脚本 | 已归 [Phase 30](../roadmap/roadmap.md) + [ADR-023](../decisions/ADR-023-level-layout-data-contract.md)，本页不重复 |

---

## 4. 处置类型判定

「契约重构」不是万能模板。按三要素筛选（数据形态可枚举、多个消费者、需要生成器）：

| 类型 | 适用条件 | 本矩阵中的项 |
|:---|:---|:---|
| **契约重构** | 数据形态 + 多消费者 + 需要生成器/规范 | **B1 UI Theme**、**B3 装备数据** |
| **API 迁移** | 引擎废弃 API → 官方替代，语义可映射 | **A1 视差**、**A2 `TileMap`** |
| **普通重构** | 代码重复、常量提取 | **B4**、**B5** |
| **随域收敛** | 全局面过大，整体替换风险不抵收益 | **B6**、**B7**、**B8** |
| **方案替换** | 消费方少、替代方案已就绪 | **B2** |

---

## 5. 批次建议

| 批次 | 内容 | 类型 | 预估 | 启动前提 |
|:---|:---|:---|:---|:---|
| **Phase 31-0** | 顺手包：A2 `TileMap`（1 处）、B2 数字图→BMFont（3 文件 25 处）、B4 具名物理层（30 处）、B5 去重（19 处） | API/普通重构 | 1–2 天 | 无；不必等待 Phase 30 |
| **Phase 31-1** | 视差迁移：89 场景 `ParallaxLayer` → `Parallax2D`，含基类 `base_through_level.tscn` | API 迁移 | 3–5 天 | 31-0 完成；建立关卡截图对照基线 |
| **Phase 32** | UI Theme 契约：定义 Theme 资源 + `theme_type_variation` 命名规范；1 个面板试点；试点通过后分批迁移 6,830 处 | **契约重构** | 试点 2 天 + 分批 | Phase 30 实施完成并验证契约模式工作量 |
| **Phase 33** | 装备数据契约：19,185 行 → Resource + 生成器 | **契约重构** | 3–5 天 | Phase 30/32 至少一个完成；需全量数值回归方案 |

**不建议立项**：B6、B7、B8、C1、C2。

---

## 6. 验收要点

| 批次 | 必需证据 | 不必执行 |
|:---|:---|:---|
| 31-0 | `check_all` 全维 PASS；数字图显示与替换前逐位一致；`collision_layer` 具名常量无裸整数残留；`load_item_icon` 全仓定义数归零 | 不做全量截图 |
| 31-1 | 89 个场景**逐场景**截图前后对照；`level_regression_all.py` 无新增失败；`ParallaxLayer`/`ParallaxBackground` 全仓计数归零 | 不要求重跑平台性能 |
| 32 | 试点面板截图逐像素或逐控件对照；`.theme` 资源登记；迁移清单按面板分批 | 不在试点前批量迁移 |
| 33 | 装备属性逐字段与迁移前一致（脚本比对）；`all_equipment_data.gd` 删除或降为生成器输出的薄封装 | 不改装备数值与掉落规则 |

---

## 7. 恢复入口

- 差距数据可用以下命令重测：

```bash
grep -rl "ParallaxLayer" source/Scene --include=*.tscn | wc -l
grep -rh "theme_override" source/Scene --include=*.tscn | wc -l
grep -rn "^func load_item_icon" source/Script --include=*.gd | wc -l
grep -rn "collision_layer = [0-9]" source/Script --include=*.gd | wc -l
grep -rho "Global\.[a-z_]*" source/Script --include=*.gd | wc -l
wc -l source/Script/data/all_equipment_data.gd
```

- 相关文档：[`architecture.md`](architecture.md) §9 遗留与现代化分界、[`status.md`](status.md)、[`autoload_boundary_matrix.md`](autoload_boundary_matrix.md)、[`gameplay_module_matrix.md`](gameplay_module_matrix.md)。

---

## 8. 已知未测量项

以下项本次**未做实测**，不得据此下结论：

| 项 | 说明 |
|:---|:---|
| 89 个场景迁移后的实际视觉差异 | 需逐场景截图对照，静态扫描无法判断 |
| Theme 试点后的真实视觉回归范围 | 需实际迁移一个面板才能量化 |
| 1,981 处硬编码路径的域分布 | 未按业务域聚类，无法给出收敛批次 |
| `level_85.tscn` 1,022 个 `Sprite2D` 是否可合并为图集 | 需美术侧确认是否为独立可交互元素 |
| 装备数据的实际加载耗时 | 未做 profile；不据此声称「编译慢」 |
