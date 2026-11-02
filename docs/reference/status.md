# 当前工程状态 (Status)

> **定位**：当前版本、运行基线、门禁与已知边界的单一事实源。
> **最后更新**：2026-11-02。历史验证记录已归档到 [`../archive/validation_history_2026.md`](../archive/validation_history_2026.md)；本页只保留当前事实与最近基线。

---

## 1. 版本与运行基线

| 项目 | 值 |
|:---|:---|
| 工程标识 | **造梦西游八荒湮隳（BHYH）** |
| 当前内容版本 | **6.9**（6.5.0.0 基线 + 6.6 / 6.7 / 6.8 / 6.9 回植） |
| 引擎 | Godot **4.7.2**（默认 `mobile`；Web 使用 `forward_plus`） |
| 设计画布 / 默认窗口 | **1280×800 / 1600×1000**（16:10，1.25×；`canvas_items` + `expand`） |
| 主场景 | `res://Scene/other_scene/load_scene.tscn` |
| 工程根 | `source/` |
| Autoload | **11 个注册项**：10 个业务单例 + 1 个编辑器调试桥；注册与职责见 [`architecture.md`](architecture.md) §2 |
| 语言 | GDScript 2.0，优先静态类型 |

版本谱系与归档入口见 [`../archive/README.md`](../archive/README.md)。

---

## 2. 当前门禁与最近验证

门禁名称、命令与通过判据以 [`acceptance.md`](acceptance.md) 为准。

| 验证 | 结果 |
|:---|:---|
| `check_all --godot-bin` | **9/9 PASS**（2026-11-02 最新复跑 **33.09s**） |
| `health_check` | **762 脚本 0 Parse / 0 Error / 0 Warning** |
| `archive_probe_runner` | **297/297 PASS** |
| `scene_probe_runner` | **17/17 PASS**（含 `pet-runtime`、`load-guard`） |
| `coop_probe_runner` | **26/26 PASS** |
| `level_1` 冒烟 | **PASS，4 阶段，0/0/0** |
| 全量关卡回归 | **PASS 128/128 + SKIP 5，FAIL 0**（最新 302.07s，**无重试**，日志 0 ERROR / 0 WARNING） |
| PCK 验证包 | **4,200/4,200 可达**；7,628,138,078 字节；sha256 `b0d6d3526256…` |

**边界**：PCK 为验证用 `all_resources` 包的路径闭包，不等于 release 加载、目标设备 VRAM、首帧耗时或最小发布包已验证。

### 最近完成

- Phase 33：装备数据契约完成；旧 `all_equipment_data.gd`、`all_equipment.gd`、字典入口与 `AE` Autoload 已删除；运行时只加载 `equipment_catalog.tres`。
- 最新宠物预热门禁与寅虎动作帧修复：`convert_monster_action_views.py --check` **5/5**，`pet-runtime` 场景探针 PASS，全量场景探针 **17/17**、`coop_probe_runner` **26/26**、`level_1` PASS；完整记录见归档。
- AnimationMixer String 状态轨道警告修复：183 个场景、**412** 条单键 value track（`animation` 296 + `playing` 116）改为离散更新；新增 `contract_scan` 的 `ANIM_TRACK_STATE_CONTINUOUS` 规则与 `pet-runtime` 动画缓存探针；全量回归 **128/128 + SKIP 5**（304.5s，0/0/0）、场景探针 **17/17**、`check_all --godot-bin` **9/9**。
- 关卡回归瞬态修复：保留失败关首轮 `errors/stages/log`，过滤三类已验证 headless dummy renderer 噪声，阶段清场后等待物理帧再传送；全量回归 **128/128 + SKIP 5，302.07s，无重试**。
- Phase 31/32/33 的实施记录、Phase 30-4 决策页和 2026 验证历史已归档，不再占用当前参考页。
- 文档与工具链收敛：活跃 reference 页面只保留当前契约；`scripts/README` 补齐脚本索引；`docs_audit.py` 检查 **703 条链接 / 0 缺失 / 0 索引缺项**；未修改 `source/`。

---

## 3. 当前已知边界

1. **平台**：Spine GDExtension 当前仅入库 Windows x86_64；21-2A 最低设备确认与 21-2B 平台测量仍暂缓。
2. **发布**：现有 PCK 是验证包，不是最小发布包；release 启动、目标设备峰值 VRAM 与首帧耗时需单独设备实测。
3. **公开仓库**：不包含第三方素材；公开 clone 的缺失资源提示属于预期。
4. **存档**：加密 JSON、`.tmp`/`.bak` 原子写与当前格式补全不变；不引入跨版本迁移链。
5. **架构**：Autoload 与 `Global` 普通子节点运行时是遗留基线；新增需按 [`autoload_boundary_matrix.md`](autoload_boundary_matrix.md) 评审。
6. **文档**：历史验证只在归档中保留，当前页不复制逐批计数。

---

## 4. 目录与规模

工程根为 `source/`，目录职责见 [`architecture.md`](architecture.md) 与 [`../../README.md`](../../README.md)。具体脚本/场景/资源数量随迭代变化，不作为本页契约；需要时从当前工作区重新统计，不使用历史数字。
