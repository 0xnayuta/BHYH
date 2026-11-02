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

**曾存在的一条不一致（31-1 已消除）**：外部导入的 1,727 个关卡场景使用现代 `Parallax2D`，BHYH 原有 89 个场景使用**已废弃**的 `ParallaxLayer`；当前 BHYH 89 个场景已全部迁移，`ParallaxLayer`/`ParallaxBackground` 全仓 0。

---

## 2. 量化基线

### 2.1 工程规模

| 指标 | 数值 | 口径 |
|:---|---:|:---|
| `.tscn` 场景总数 | **2,836** | `find source/Scene -name '*.tscn'` |
| 节点总数 | **93,633** | `grep -rh '^\[node '` |
| BHYH 原有场景 | ~1,135 | 总数减去外部导入 1,727 |
| 外部（ZMWS）导入场景 | **1,727** | `source/Scene/level/zmws/` |
| `source/Script/data` 体量 | 583 KB / 19,949 行 | `du`、`wc -l` |

### 2.2 关键计数

| 项 | 数值 | 判定 |
|:---|---:|:---|
| `ParallaxLayer` 场景 | **0**（31-1 已迁移） | A1 已消除 |
| `ParallaxBackground` 场景 | **0**（`base_through_level.tscn` 改为 `CanvasLayer`） | A1 已消除 |
| `Parallax2D` 场景 | **1,816**（外部 1,727 + BHYH 89） | 现代 |
| `TileMap` 节点 | **0**（31-0A 已迁移为 `TileMapLayer`） | A2 已消除 |
| `theme_override_*` 文本引用 | **6,830**（6,804 直接属性 + 26 动画轨道） | B1 |
| `.theme` 扩展文件 / `Theme` `.tres` | **0 / 1** | B1 |
| 场景引用 `theme` | **2** | B1 |
| `FontFile` 场景级 `ext_resource` | **207** | B1（字体未集中） |
| `Label` / `Button` / `TextureRect` / `Control` 节点 | 851 / 351 / 217 / 70 | B1 影响面 |
| `Art/all_number` 手工拼数字 | 25 处 / 3 文件；BMFont 替换评估后拒绝（无同源字体） | B2 保留现状 |
| `func load_item_icon` 定义数 | **0**（31-0A 收敛到 `ItemUtils`） | B5 已消除 |
| `Global.<member>` 调用点 | **2,832** | B8 |
| 脚本内硬编码 `"res://…"` 字符串 | **1,981** | B6 |
| `collision_layer = <整数>` | **0**（31-0A 收敛到 `PhysicsLayers`） | B4 已消除 |
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
| 现状 | 已消除：89 个场景 95 个 `ParallaxLayer` + 1 个 `ParallaxBackground` 全部迁移；`base_through_level.tscn` 容器改为 `CanvasLayer`（`layer=-100`、`follow_viewport_enabled=true`），层为 `Parallax2D`（31-1） |
| 官方依据 | `ParallaxLayer` 类文档：*Deprecated: Use the Parallax2D node instead.*；2D Parallax 教程：*recommended to use over the ParallaxLayer and ParallaxBackground nodes* |
| 内部不一致 | 已消除：外部 1,727 个关卡与 BHYH 89 个场景统一为 `Parallax2D` |
| 语义映射 | `motion_scale`→`scroll_scale`；`motion_mirroring`→`repeat_size`；`motion_offset`→`scroll_offset`；`position`→`scroll_offset`（Parallax2D 进树后 position 会被覆盖） |
| 结构变化 | `ParallaxBackground` → `CanvasLayer`（`layer=-100`、`follow_viewport_enabled=true`）；每层独立 `Parallax2D` |
| 风险 | 已对照：89 场景 × 4 相机 2,520 节点 transform；7 个代表场景截图；`level_4` 不可见 `stage` 与 `level_2` 子像素为已知例外 |
| 处置 | **31-1 已完成（2026-11-01）**；`ParallaxLayer`/`ParallaxBackground` 全仓 0；全量回归 128/128 PASS + 5 SKIP |

#### A2 `TileMap` 使用已废弃 API

| 项 | 内容 |
|:---|:---|
| 现状 | 已消除：`base_through_level.tscn` 的 `floor` 为 `TileMapLayer`；12 个关卡覆盖已迁移为 `tile_map_data`（31-0A） |
| 官方依据 | `TileMap` 类文档：*Deprecated: Use multiple TileMapLayer nodes instead.* |
| 影响 | 迁移已完成：基类 1 个节点 + 12 个关卡覆盖（15 个有 `tile_set` 覆盖），23,561 个格子逐格一致；原估算「单行替换」不成立，实际需按二进制格式迁移 |
| 处置 | **31-0A 已完成**（2026-11-01）：`TileMapLayer` + 12 个 `tile_map_data` 覆盖；23,561 格逐格一致 |

### 3.2 B 级：结构性问题

#### B1 UI 无 Theme 层（**最像 Phase 30 的契约缺失**）

| 项 | 内容 |
|:---|:---|
| 现状 | `theme_override_*` 文本引用 **6,830 处**（6,804 直接属性 + 26 动画轨道）；`.theme` 扩展文件 0 个，另有一个 **`Theme` 类型的 `.tres`**（`backpack_action_theme.tres`）；场景仅 **2 处**引用 `theme`；`theme_type_variation` 0 处；`FontFile` 场景级引用 **207 处** |
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
| 现成替代 | 已导入 7 个 BMFont（`Font/zmws_bmfont/`），但均与数字图不同源：等级字形 alpha IoU 最高 0.866、颜色归一化差异 0.988；伤害数字 15 种样式无等价字体 |
| 处置 | **31-0B 评估后拒绝**（2026-11-01）：保留旧数字图。如未来必须迁移，需从现有数字图生成同源 BMFont（构建期私有派生资源），不得直接用 ZMWS BMFont；当前不纳入批次 |

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
| 现状 | **0 处**：30 处已改用 `PhysicsLayers` 具名常量（31-0A） |
| 规范依据 | `godot_design_standard.md` §6：物理层使用具名层；碰撞掩码不得使用无注释的裸整数 |
| 处置 | **Phase 31-0**；提取具名常量，改动面小 |

#### B5 同一函数重复定义

| 项 | 内容 |
|:---|:---|
| 现状 | **0 处**：19 处定义与 99 处调用已收敛到 `ItemUtils` 的 5 个具名解析入口（31-0A）；原实现存在 5 种不同兜底语义 |
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
| C3 | 关卡数据硬编码在 85 个脚本 | 已归 [Phase 30](../roadmap/roadmap.md) + [ADR-023](../decisions/ADR-023-level-layout-data-contract.md)，本页不重复 |

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
| **Phase 31-0A** | A2 `TileMap`→`TileMapLayer`（基类 1 + 12 个覆盖场景）、B4 具名物理层（30 处）、B5 去重（19 处） | API/普通重构 | 1–2 天 | 无 |
| ~~Phase 31-0B~~ | B2 数字图→BMFont（3 文件 25 处）：评估后拒绝，保留旧数字图 | 方案替换 | 已评估 | 无（需同源 BMFont 才重启） |
| **Phase 31-1** | 视差迁移：89 场景 `ParallaxLayer` → `Parallax2D`（完成） | API 迁移 | 已实施 | 31-0 完成 |
| **Phase 32** | UI Theme 契约：定义 Theme 资源 + `theme_type_variation` 命名规范；1 个面板试点；试点通过后分批迁移 6,804 处直接属性，动画轨道单独登记 | **契约重构** | 试点 2 天 + 分批 | **32-0/32-1/32-2A/32-2B/32-3A/32-3B/32-3C/32-3D/32-3E/32-3F/32-3G-1/32-3G-2/32-3G-3/32-3G-4/32-3G-5/32-3G-6/32-3G-7/32-3G-8/32-3G-9 已完成**（基线/契约/审计 + `game_set` + 标签/Button 密集 + 混合控件/布局 + 多批标签/混合/阵法/输入/地图/技能/主菜单/关卡结算/运行时面板）；32-3G-10 未启动；见 `current-iteration.md` §5C |
| **Phase 33** | 装备数据契约：19,185 行 → Resource + 生成器 | **契约重构** | 3–5 天 | **已规划、未启动**；Phase 30 已完成，推荐 32-1 后启动；需全量数值回归方案，见 `current-iteration.md` §5D |

**不建议立项**：B6、B7、B8、C1、C2。

---

## 6. 验收要点

| 批次 | 必需证据 | 不必执行 |
|:---|:---|:---|
| 31-0A | `check_all` 9/9 PASS；12 个 TileMap 覆盖关卡逐格一致 + 代表关冒烟；`collision_layer` 裸整数归零；`load_item_icon` 定义数归零且 5 种图标语义有对照证据 | 不做全量截图 |
| 31-0B | 已评估：字形/颜色/步进与截图对照不达标，保留旧实现并登记；未改代码 | 不为归零强行替换 |
| 31-1 | 已实施：89 场景 × 4 相机 2,520 节点 transform 对照；7 个代表场景截图前后对照；全量回归 128/128 + 5 SKIP；`ParallaxLayer`/`ParallaxBackground` 归零 | 不重跑平台性能 |
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
