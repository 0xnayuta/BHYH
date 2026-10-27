# BHYH Current Iteration

> **用途**：维护当前活跃阶段的范围、依赖、实施顺序与验收入口；长期路线以 [roadmap](roadmap.md) 为准。
>
> **当前状态**：**Phase 13 视觉资产契约收口**实施中；Phase 13-1、13-2A、13-2B（怪物域）与 13-3 已完成；13-4 删除完成，入口收敛待确认。
>
> **版本边界**：内容版本保持 **6.9**；Phase 13 只做内部架构与资产管线收口，不新增玩法、任务、掉落或数值内容。
>
> **上一阶段**：Phase 12 画布、相机与 HUD 重构已全部完成并归档，验收记录见 [`../archive/iteration_12_display_hud.md`](../archive/iteration_12_display_hud.md)。本页不再保留 Phase 12 的实施明细。
>
> **依据**：[`../standards/target_architecture_contract.md`](../standards/target_architecture_contract.md)（三层契约）、[`../standards/godot_design_standard.md`](../standards/godot_design_standard.md)、[ADR-020](../decisions/ADR-020-typed-visual-assets-and-streaming-lifecycle.md)、[ADR-005](../decisions/ADR-005-no-compatibility-or-fallback-layers.md)。

---

## 0. 参考入口

- 目标契约：[`../standards/target_architecture_contract.md`](../standards/target_architecture_contract.md)
- 当前真实实现：[`../reference/architecture.md`](../reference/architecture.md)
- 当前状态与规模：[`../reference/status.md`](../reference/status.md)
- 验收命令与阈值：[`../reference/acceptance.md`](../reference/acceptance.md)
- 规范索引：[`../standards/README.md`](../standards/README.md)
- 迁移方法与红线：[`../guides/migration_playbook.md`](../guides/migration_playbook.md)
- 缺失资产台账：[`../standards/missing_assets_registry.md`](../standards/missing_assets_registry.md)

---

## 1. 阶段背景与排序依据

Phase 12 收口后，`FrameSequence`（288 条序列）、`AtlasMetadata`（379 份）与关卡预载 Catalog 已经落地，构建层 / 资源层 / 运行时层的主干成立。按目标契约逐条比对，剩余偏离集中在四处，并且已经用落地数据量化（2026-10-26 实测）：

| 编号 | 契约条款 | 偏离事实 | 影响面 |
|:---|:---|:---|:---|
| A | §4.2 资源校验与失败 | 3 处失败被静默吞掉或仅靠 `assert` | 所有依赖该资源的战斗与 UI |
| B | §5.2 加载与预热 | 3 处主线程同步 IO / 逐帧 `load()` | 每帧开销、卡顿、移动端 |
| C | §3.1 构建层 | 70 个脚本仍在运行时构造 `SpriteFrames`（88 处） | 首次进入关卡、技能释放、Boss 战 |
| D | §4.3 发布依赖 | 预载 Catalog 的 198 个怪物 ID 与 25 条弹体路径未进任何依赖清单 | 发布包可能缺资源 |
| E | §4.2 / ADR-005 禁止兼容层 | 纹理别名表 2,313 条中 932 条目标文件不存在 | 静默回退、排查成本 |

排序口径为 **契约偏离程度 × 影响面**，并叠加“是否需要人工裁定”：能一次改完且可立即回归的排前，需要素材与批量转换的排后，需要人工逐条裁定的最后。

**因此 Phase 13 顺序为：13-1 → 13-2 → 13-3 → 13-4。** 13-1 与 13-2 可并行准备，但 13-1 必须先合入，因为 13-2 依赖新的失败语义来判断“构建资源缺失”。

---

## 2. Phase 13-1：失败语义与热路径 IO 收口

**对应契约**：§4.2（资源校验与失败）、§5.2（加载与预热）
**依赖**：无
**预估**：单批次可完成，不涉及素材与构建期产物

### 2.1 目标

1. 资源缺失不再用空占位或空字典掩盖，改为明确失败并拒绝生成错误消费者；
2. 消除 `_physics_process` / `_process` 内的同步 `load()` 与逐帧纹理加载；
3. 保留现有业务行为：只有“资源确实缺失”的路径才改变，正常路径不改变可见结果。

### 2.2 任务

#### 2.2.1 空 `SpriteFrames` 占位改为显式失败

现状（`source/Script/monster/monster_bullet.gd`）：

- L280 `_get_cached_pet_bullet_frames`：`push_error` 后返回 `SpriteFrames.new()` + `add_animation`，零帧动画静默不播放；
- L1094 `_get_pet_phoenix_frames`：同上，且不写缓存。

改为：

- 返回 `SpriteFrames`（null）并把调用方改为拒绝创建子弹节点，或在 `configure` 阶段返回 `false`；
- 保留 `push_error` 文案，但不再返回可用对象；
- 在 `COOP`/关卡探针中补一条负向用例，确认缺失时不再产生“看不见但逻辑存在”的子弹。

#### 2.2.2 `AtlasMetadataStore` 缺失路径可区分

现状（`source/Script/atlas/atlas_metadata_store.gd` L9-16）：

- 路径为空、文件不存在、schema 不合法三种情况都返回 `{}`；
- 调用方（`cloud_boss`、`east_continent_monster`、`north_continent_monster`、`palace_*`、`sword_boss_base`、`mount_visual`、`main_sword_array_weapon`，共 9 个文件）无法区分“空配置”与“资源缺失”。

改为：

- 保留 `data_for()` 的返回类型（避免大范围签名变更），但在“文件不存在”与“schema 不合法”时 `push_error` 并记录一次；
- 新增 `validate_path(path) -> Array[String]`，供构建期与探针显式断言；
- `mount_visual` 已有 `push_error`，改为复用统一失败判定，不重复报错。

#### 2.2.3 `RoleRuntimeCatalog` 的 `assert` 改为显式失败

现状（`source/Script/data/role_runtime_catalog.gd` L16-18）：

```gdscript
assert(MANIFESTS.has(role_id), "未注册角色运行资源清单: %d" % role_id)
return MANIFESTS[role_id]
```

`release` 下 `assert` 被剥离，越界会返回 `null`，随后在 `global.gd` L2153 / L2173 解引用。

改为：

- `push_error` + 返回 `null`；
- 两个调用方在拿到 `null` 时中止本次预热并记录，不继续解引用。

#### 2.2.4 热路径同步 IO

| 位置 | 现状 | 改法 |
|:---|:---|:---|
| `source/Script/level/hdzm.gd` L6-12 | `_physics_process` 每帧 `load()` 两张 PNG | 移到 `_ready` 一次性 `preload`/缓存，`_physics_process` 只做分支赋值 |
| `source/Script/monster/monster_bullet.gd` L437 / L470 | `DirAccess.get_files_at` 扫描目录 | 改为构建期清单（Phase 13-3 的 `monster_bullet` 表已具备该数据，可先接入） |
| 同上 L475 | `range(601)` 编号探测 | 同上，改为清单驱动 |
| 同上 L459 | `range(1, 31)` 固定 30 帧拼路径 | 改为清单 |
| `source/Script/magic_weapon/main_sword_array_weapon.gd` L94-148 | `StreamingFrameEffect._show_frame` 每帧 `ResourceLoader.load` | 该分支只服务 `AtlasStreamingFrameEffect`；基类保留接口，子类覆写为异步页加载（L319 已有 `_try_show_frame`），删除或收敛同步分支 |

**注意**：`monster_bullet` 的目录扫描与编号探测在 `png_stream_audit.py` 的 allowlist 之外，属于 §3.1 明确禁止项，必须在本 Phase 内消除，不能只做缓存。

### 2.3 出口标准

- 全工程 `grep -n 'SpriteFrames.new()' source/Script` 中不再有“`push_error` 后返回空帧”的写法；
- `_physics_process` / `_process` 内无 `load()`、无 `ResourceLoader.load`、无 `DirAccess`；
- `monster_bullet.gd` 无目录扫描与编号探测；
- 八维门禁 8/8 PASS；`health_check` 0 Parse / 0 Error / 0 Warning；
- `level_1`、`level_59`、`level_61`、`level_pty` 冒烟 PASS（0 ERROR / 0 WARNING）；
- `coop_probe_runner` 16/16 PASS；`scene_probe_runner` 2/2 PASS。

### 2.4 风险

| 风险 | 处理 |
|:---|:---|
| 空帧占位可能被某些 Boss 当作“无动画但可运行”的合法状态 | 先加负向探针确认这些路径在实际对局中是否真会命中；命中则同步补齐构建资源，而不是恢复占位 |
| 剑阵同步分支删除后，页加载失败会变成不可见 | 保留 `_mark_atlas_failed` 与失败信号，让上层拒绝生成而非空白显示 |
| `monster_bullet` 清单化依赖 13-3 的产出 | 若 13-3 未就绪，本项先用 `LevelPreloadCatalog.monster_bullets` 的既有 17 条覆盖，剩余路径登记为 13-3 的出口条件 |

---

## 3. Phase 13-2：怪物视觉资产构建期化

**对应契约**：§3.1（构建层：固定视觉资产离线生成）、§3.3（生成结果确定性）
**依赖**：Phase 13-1（失败语义）
**预估**：分两批，每批单独提交

### 3.1 目标

把 50 个在运行时构造 `SpriteFrames` 的怪物脚本，改为加载构建期生成的 `monster_<id>_frames.tres`；运行时只做“取资源 + 校验 + 播放”。

### 3.2 现状数据

| 指标 | 数量 |
|:---|:---:|
| 含 `SpriteFrames.new()` 的 Script 文件（88 处） | **70** |
| 其中怪物脚本 | **50** |
| 已能定位到构建期 `*_frames.tres` 或 `swf_png` 路径的怪物脚本 | **37**（其中 2 个同时依赖 `AtlasMetadata`） |
| 依赖 `AtlasMetadata` 序列构造的怪物脚本 | 3（含上述 2 个重叠） |
| 已生成的怪物帧资源 `*_frames.tres` | 227 |
| `AtlasMetadata` 产物 | 379 |

结论：**素材侧已基本就绪**，缺的是“元数据 → 怪物帧资源”的通用转换器与消费者切换。

### 3.3 批次 13-2A：新增通用转换器（已完成 2026-10-26）

新增 `scripts/convert_monster_frames.py`：

- **输入**：`Art/monster/**/metadata.tres` 的 `sequences`；
- **目标解析**：同目录唯一 `*_frames.tres` 优先；`atlas*` 目录无同目录目标时取父目录唯一目标；其余显式跳过并登记原因（`pet_tiger_boss/atlas` 为 stage 聚合名，不是一比一投影）；
- **输出**：沿用既有生产命名，不新建重复资源。`--all` 只写缺失或与 metadata 语义不一致的目标；`--rewrite` 才按规范格式重写并补 UID；`--emit <dir>` 输出到指定目录供探针验证；
- **校验**：`--check` 比较动画名集合、帧数、每帧页路径 / `region` / `margin`、页文件闭包与 PNG 边界、动画名唯一性、确定性 UID 与全局 UID 冲突；
- **稳定 UID**：由 `bhyh:monster_frames|<metadata 相对路径>` 派生；148 个历史目标无 UID 头，按已评审例外接受，`--rewrite` 可一次性补齐；
- **实测**：148 个目标 / 40,222 帧全部与 metadata 一致；8 个样本（6,123 帧）经 Godot 探针比对「生成 vs metadata vs 生产」零差异（含 loop/speed）；`--all` 幂等写入 0 个文件；
- **门禁**：`--check` 已并入 `scripts/contract_gate.py`。

规划原定「新建 `monster_<id>_frames.tres`」与现状冲突：148 个模型已有按既有命名生成的同源资源，消费者按现有路径引用。13-2A 改为复用现有资源，避免重复资产与 13-2B 的路径迁移开销。

### 3.4 批次 13-2B：消费者切换（已完成 2026-10-27，怪物域）

实测修正：清单虽称“35 个仅依赖构建期帧路径”，但 26 个标准加载器全部在运行时把 sequence 名重命名为动作名（如资源 `effect1` → 动作 `skill1`）。直接 `load` 会让 `AnimatedSprite2D.animation` 找不到动作。因此 13-2B 的实际路径是：

1. **构建期动作视图**：`convert_monster_frames.py` 按 `scripts/monster_action_maps.json` 在既有帧资源中追加动作别名动画，复用原 `AtlasTexture` 子资源并显式声明 loop；
2. **消费者直接加载**：删除 `_load_standard_frames()` 中的 `SpriteFrames.new()` 重建与 `add_animation` 循环，改为 `return load(frames_path) as SpriteFrames`；保留 `ACTIONS`/`MODEL_ACTIONS` 的帧数、offset、loop 用于 `AnimationPlayer` 时长与位移；
3. **删除回退**：`_get_frames_for_model()` 的逐帧 PNG 回退分支删除，资源缺失即返回 `null`；
4. **已完成 54 个脚本**：3040/3041/3042/3033/3034/3035/3069/3070/3076/3117/3370、3012/3007/3021/3056/3077/3078、峨眉山/五台明海/南海/双喜寺/玄武门/朱雀街/九华山、剑 Boss 基类 951~954、四头 Boss 头部与火灵珠、玄武门箭/朱雀虎箭/双喜 Boss 箭/未央宫弹体、212/215/130 编号帧弹体、九华松针与东胜神洲 loose 特效、流沙河本体/分身、130/212/215 动作视图、遁地与震雷法宝、宠物四弹体与寅虎 stage 视图、闪电特效与关卡 46 背景；
5. **冻结保留（怪物域 9 个）**：`east_continent_monster`（仅剩标准动作重命名，loose 已构建期化；关卡配置 merge 使其无法完全静态化）、`eight_immortals_boss`（运行时裁剪）、`monster_bullet`（标准帧缺失时的 null 计时帧）、`nanhai_projectile`（单序列裁剪）、`pet_tiger_boss_base`（图集行列裁剪）、`tao_wu_boss`（资源异常单图兜底）、`three_prince_boss`（运行时裁剪）、`three_prince_bullet`（资源缺失逐帧回退）、`weiyang_palace_boss`（符号层裁剪）；全部已登记到 `runtime_frames_allowlist.json` 并在 §3.5 出口标准中守恒。

**完成结果**：54 个怪物脚本改为加载构建期帧资源；运行时建帧文件从 70 降到 **19**（怪物 9 + 非怪物 10）。非怪物 10 个不纳入 13-2 怪物域，按角色特效、法宝、宠物、关卡、工具拆批。

**禁止**：为了少改代码而保留“先试 `.tres`，失败再回退运行时建帧”的双路径——这正是 ADR-005 与 §4.2 禁止的兼容层。

### 3.5 出口标准

- `grep -rl 'SpriteFrames.new()' source/Script` 的文件数从 70 降到 **19**（怪物 9 + 非怪物 10）；**怪物域 ≤10 且全部登记例外**；非怪物 10 个不纳入本 Phase 计数，按域拆批（例如运行时生成的颜色/几何占位，需在 `docs/reference/architecture.md` 的“遗留”清单中写明）；
- `convert_monster_frames.py --check` 通过并进入契约门禁；
- `runtime_frames_audit.py --fail-on-error` 通过，运行时建帧集合与
  `scripts/runtime_frames_allowlist.json` 守恒；迁移后条目只减不增；
- `health_check` 0 Parse / 0 Error / 0 Warning；
- 全量关卡回归 `level_regression_all.py`（默认 auto 并发）PASS，FAIL 0；
- 至少 6 个代表关卡（含 5 阶段关、Boss 关、八仙、三太子）冒烟 0 ERROR / 0 WARNING。

### 3.6 风险

| 风险 | 处理 |
|:---|:---|
| 动画名迁移后与原 `AnimatedSprite2D.animation` 字符串不一致 | 转换器把动画名作为 schema 的一部分输出，消费者按同一常量引用；门禁校验名称集合 |
| 帧几何（offset/居中/缩放）在运行时脚本里硬编码 | 迁移时把这些字段写入帧资源或保留在消费者常量中，并在探针中断言首帧可见 |
| Atlas 页共享导致内存上升 | 复用现有 `AtlasTexture` 页引用；不新建纹理副本；必要时按 §6.5 记录驻留依据 |

---

## 4. Phase 13-3：发布闭包与动态依赖收敛

**对应契约**：§4.3（导入、UID 与发布依赖）
**依赖**：Phase 13-2（帧资源产出后才有完整闭包）

### 4.1 目标

让“字符串路径”全部变成可校验的发布依赖，使 PCK 闭包探针能覆盖玩法资源，而不只是 FrameSequence。

### 4.2 现状缺口

| 缺口 | 数据 |
|:---|:---|
| `level_preload_catalog.tres` 内怪物场景 | 199 条解析后的实际 `.tscn`（生成期展开 26 个别名） |
| 别名来源 | `scripts/monster_dynamic_paths.json` 26 条；运行时已删除 ID→ID 映射 |
| `level_preload_catalog.tres` 内弹体场景 | 17 个键 / 8 条唯一路径 |
| 动态纹理来源 | 16 个 ID / 30 条来源（目录展开为 767 个文件） |
| 动态场景来源 | 16 个 ID / 24 条唯一路径（原始 37 条去重） |
| 现有发布依赖清单 | `frame_sequence_export_dependencies.json`（288 序列 / 2,812 纹理） |

### 4.3 任务

1. **扩展现有清单 schema**：在 `level_preload_catalog.tres` 同目录新增 `source/Script/data/level_preload_export_dependencies.json`，记录：
   - `catalog`：`level_preload_catalog.tres`；
   - `monster_scenes`：199 条解析后的实际 `.tscn` 路径（**已展开别名**）；
   - `dynamic_monster_scenes`：24 条；
   - `bullet_scenes`：8 条；
   - `dynamic_textures`：767 条（目录展开为文件列表）。
2. **生成方**：由 `convert_level_preload_catalog.py` 同步输出，`--check` 逐字比较。
3. **回收动态表**：`DYNAMIC_MONSTER_TEXTURE_PATHS` 与 `DYNAMIC_MONSTER_SCENE_PATHS` 并入 Catalog，删除 `global.gd` 中的两张表与 `_append_dynamic_monster_*` 两个函数（已完成）。
4. **闭包探针**：`frame_sequence_pack_probe.py` 已扩展为多清单合并，在最小空工程挂载 PCK 后逐条 `ResourceLoader.exists()`（已完成）。
5. **别名前置**：`MONSTER_SCENE_ALIASES` 迁入 `monster_dynamic_paths.json` 并在生成期展开；运行时不再做 ID→ID 映射；无场景且无别名的 Catalog ID 生成器直接失败（已完成）。

### 4.4 出口标准

- 新增清单 `--check` 通过并进入契约门禁；
- `global.gd` 不再包含两张动态表、别名表与对应函数（净减少 ≥ 70 行）；
- 发布包探针 PASS：两份清单合并 **4,100 条**依赖全部可达（PCK 2,738,623,739 字节，sha256 `f87a631c73db…`（清单迁到公共路径后复跑））；
- 全量关卡回归 PASS，FAIL 0；
- `reference/architecture.md` 的“发布依赖”段落与 `scripts/README.md` 同步。

### 4.5 风险

| 风险 | 处理 |
|:---|:---|
| 目录型动态纹理展开后条目数暴增 | 只登记文件路径，不登记目录；清单体积按实际文件数增长，必要时拆分按怪物 ID 分组 |
| 别名展开后与运行时 `_canonical_monster_scene_id` 不一致 | 以生成期展开为唯一真源，运行时删除映射；用探针逐 ID 比对 |
| PCK 探针耗时上升 | 探针只在发布前执行，不进入日常八维门禁 |

---

## 5. Phase 13-4：兼容层与遗留动态表治理

**对应契约**：§4.2（不得用旧路径/猜名掩盖）、ADR-005（禁止兼容层）
**依赖**：Phase 13-3
**预估**：需要人工逐条裁定，单独立项节奏

### 5.1 目标

把 `duplicate_texture_aliases.gd` 从 2,313 条兼容表收敛为 1,381 条目标可达的映射，并把无法恢复的条目按 `missing_assets_registry.md` 状态机归档。

### 5.2 现状

| 指标 | 数量 |
|:---|:---:|
| 别名条目 | **2,313** |
| 目标文件不存在 | **933** |
| 其中键/目标均不存在 | **933** |
| 目标仅大小写不一致 | **1** |
| 解析入口 | `global.gd` L785/L807、`ne_zha_official_parts_data.gd` L36、`eight_immortal_magic_weapon.gd` L31/L79 |

933 条目标缺失意味着这些别名**不可能生效**：命中时仍会 `load()` 失败，只是把失败推迟到了运行时。

### 5.3 任务

0. **分类脚本（已完成 2026-10-27）**：新增 `scripts/classify_texture_aliases.py`，只读扫描别名键/目标、代码与资源文本引用，输出 `docs/reports/texture_alias_classification.json/.md`；
1. **分类裁定**：把每条别名标记为
   - `valid`：目标存在 → 保留；
   - `recoverable`：目标缺失但原版素材可恢复 → 登记 `missing_assets_registry.md` 的“待恢复”；
   - `obsolete`：原版不存在或已被构建期资源取代 → 删除别名与引用；
2. **代码修复优先**：对 `MagicWeapon` 等“编号+1 映射”类别名，改为构建期序列（`convert_numbered_frames.py` / `convert_monster_frames.py`），不再靠别名凑帧；
3. **删除悬空条目（已完成 2026-10-27）**：删除 932 条键/目标均缺失的条目，别名表从 2,313 降到 **1,381**；
4. **入口收敛（未执行）**：`TEXTURE_ALIASES.resolve` 只保留在 `Global` 的一个私有解析点，其它脚本走 `Global` 接口；对仍然直连的 3 处逐一评估。

### 5.3a 删除结果（2026-10-27，已执行）

| 分类 | 数量 | 裁定 |
|:---|:---:|:---|
| 目标存在 | **1,381** | 保留（含 1 条大小写修正后目标存在） |
| 删除 | **932** | 已删除（917 无引用 + 15 仅通用基名） |
| 待恢复 | **0** | 无代码/台账/资源文本强引用 |

**执行结果**：2,313 → **1,381** 条；`classify_texture_aliases.py --check` PASS；`check_all` **8/8**；`health_check` **0/0/0**；全量回归 **PASS 128/128 + SKIP 5**（283.0s）；L2 三件套 PASS。入口收敛未执行。

### 5.4 出口标准

- 别名表目标缺失数 = **0**（每条都能解析到真实文件或已删除）；
- `TEXTURE_ALIASES.resolve` 调用点收敛到 1 处；
- `missing_assets_registry.md` 更新，新增条目均带状态与恢复来源占位；
- 八维门禁 + 全量关卡回归 PASS；
- `docs/reference/architecture.md` 的“遗留例外”表删除对应项或改为已收口。

### 5.5 风险

| 风险 | 处理 |
|:---|:---|
| 部分“悬空别名”实际是未使用的历史残留，删除无风险 | 先用引用扫描确认键名是否出现在代码/场景中；无引用直接删除 |
| 删除后某些冷门角色/法宝外观缺失 | 按角色逐个实机抽检，不依赖单一关卡回归 |
| 别名表是某些 6.8 补丁的隐含依赖 | 对 6.8/6.9 补丁涉及的角色与法宝做定向截图对比 |

---

## 6. 阶段顺序、依赖与提交规则

```text
Phase 13-1 失败语义与热路径 IO
        │
        ▼
Phase 13-2 怪物视觉资产构建期化（13-2A 转换器 → 13-2B 消费者）
        │
        ▼
Phase 13-3 发布闭包与动态依赖收敛
        │
        ▼
Phase 13-4 兼容层与遗留动态表治理
```

| 批次 | 状态 | 提交粒度 |
|:---|:---|:---|
| Phase 13-1 | **已完成**（2026-10-26） | 单个提交 |
| Phase 13-2A | **已完成**（2026-10-26） | 转换器 + `--check` 一个提交 |
| Phase 13-2B | **已完成**（2026-10-27，怪物域；非怪物按域拆批） | 按怪物域分批，每批一个提交 |
| Phase 13-3 | **已完成**（2026-10-27） | 清单生成 + 运行时删表分开提交 |
| Phase 13-4 | 删除完成（2026-10-27），入口收敛待确认 | 分类脚本 → 删除 → 入口收敛，分开提交 |

**红线**：

- 每个 Phase 单独提交，不把失败语义、资产迁移与发布闭包混在同一批次；
- 不保留“新路径失败就回退旧路径”的双路径；
- 13-2 与 13-3 的转换器必须支持 `--check` 并进入契约门禁，不能只校验文件存在；
- 不修改 `source/Art` 等素材内容；素材变更走私有仓 `ASSET_CHANGE_CONTRACT.md`。

---

## 7. 统一验收矩阵

每个 Phase 收口时至少执行：

```bash
python scripts/check_all.py --godot-bin "<godot>"
python scripts/contract_gate.py
python scripts/coop_probe_runner.py --godot "<godot>"
python scripts/scene_probe_runner.py --godot "<godot>"
python scripts/level_regression_all.py --timeout 150
python scripts/level_regression_all.py --changed-only --diff-base HEAD~1
```

| 判据 | 阈值 |
|:---|:---|
| 八维门禁 | 8/8 PASS |
| 契约门禁 | 全子命令 PASS，含新增转换器 `--check` |
| 引擎健康 | 0 Parse / 0 Error / 0 Warning |
| 场景探针 | 2/2 PASS（星座 + 关卡选择态） |
| 双人探针 | 16/16 PASS，SKIP 不计 PASS |
| 关卡回归 | FAIL 0；SKIP 仅限 5 个非战斗场景 |
| 发布闭包 | 13-3 起为必跑项，13-1/13-2 可后置 |

结果写入 [`../reference/status.md`](../reference/status.md)，报告不提交。

---

## 8. 已知边界与不在本阶段范围

1. **不改内容版本**：Phase 13 全部为内部重构，不产生 7.0；
2. **不处理 Spine**：现有 Spine 内容继续遵守 ADR-010，本阶段不烘焙、不替换运行时；
3. **不处理 `global.gd` 整体拆分**：仅删除与预载/动态表相关的死代码，God 对象拆分仍是独立立项；
4. **不做 13 个 Autoload 的合并或新增**；
5. **不验证目标平台性能**：首帧延迟、VRAM 驻留与 release 加载仍需在真实设备测量，headless 探针不作为证据；
6. **不迁移 `_bundled` 场景**：与视觉资产契约无关，留在技术债清单。

---

## 9. 恢复规则

- 本页记录 Phase 13 实施状态：13-1、13-2A、13-2B（怪物域）与 13-3 已完成；13-4 删除完成，入口收敛待用户确认后启动。
- 每个 Phase 完成后在本页更新状态与实测结果，并把验收结论同步到 [`../reference/status.md`](../reference/status.md)。
- Phase 12 的实施明细已归档，不在本页重复；如需回溯，见 [`../archive/iteration_12_display_hud.md`](../archive/iteration_12_display_hud.md)。
- 内容版本保持 6.9；Phase 13 不产生新的内容版本号。
