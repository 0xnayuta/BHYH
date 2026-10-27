# Phase 13 视觉资产契约收口验收归档

> **归档日期**：2026-10-27
> **状态**：Archived
> **关联**：[当前工程状态](../reference/status.md)、[路线图](../roadmap/roadmap.md)、[验收标准](../reference/acceptance.md)、[目标契约](../standards/target_architecture_contract.md)、[ADR-020](../decisions/ADR-020-typed-visual-assets-and-streaming-lifecycle.md)、[ADR-005](../decisions/ADR-005-no-compatibility-or-fallback-layers.md)
> **归档范围**：Phase 13-1、13-2A/13-2B/13-2C、13-3、13-4 与角色特效收口的实施结论、最终验收、冻结项与后续处理。
> **内容版本**：6.9；Phase 13 不产生新内容版本。

---

## 1. 收口结论

Phase 13 的内部目标已完成：

- 资源失败不再被空占位或 `assert` 静默吞掉；
- 固定视觉资产从运行时建帧迁移到构建期资源；
- 发布依赖从字符串路径变为可校验清单；
- 纹理别名兼容层清空并删除。

最终运行时建帧只保留 **12** 个已评审例外：

- 怪物域 **9** 个；
- 非怪物域 **3** 个：`pet_neat_bullet`、`level_59`、`user_key`。

Phase 13 不新增玩法、任务、掉落或数值内容；没有未完成的阻塞项，剩余项目均为已登记独立立项或明确冻结例外。

---

## 2. 阶段回顾

| 阶段 | 目标 | 最终结果 |
|:---|:---|:---|
| Phase 13-1 | 失败语义与热路径 IO | `push_error + null`、`AtlasMetadataStore.validate_path()`、`RoleRuntimeCatalog` 显式失败；删除热路径 `load()`、目录扫描与编号探测 |
| Phase 13-2A | 怪物帧通用转换器 | `convert_monster_frames.py` 覆盖 148 个目标 / 40,222 帧；抽样探针 6,123 帧零差异；`--check` 进入契约门禁 |
| Phase 13-2B | 怪物消费者切换 | 54 个怪物脚本加载构建期帧；动作别名在构建期展开；删除逐帧 PNG 回退 |
| Phase 13-2C | 非怪物运行时建帧 | 诛仙剑阵、青莲、青龙剑、太极、八仙、Lyfb、哪吒阴阳特效完成构建期化；非怪物例外 10→3 |
| Phase 13-3 | 发布闭包与动态依赖 | Catalog 展开 199 怪物场景 / 24 动态场景 / 8 弹体 / 767 动态纹理；发布依赖 4,100 条；PCK 闭包探针通过 |
| Phase 13-4 | 兼容层与遗留动态表 | 纹理别名 2,313→0；删除别名表、`TEXTURE_ALIASES` preload、`_resolve_texture_path()` 与分类脚本 |

### 2.1 Phase 13-1

- 宠物弹体缺失帧从“空 `SpriteFrames` 继续运行”改为显式 `null`，调用方拒绝创建不可见逻辑对象；
- `AtlasMetadataStore` 可区分空路径、文件缺失与 schema 失败，并新增 `validate_path()`；
- `RoleRuntimeCatalog` 的 `assert` 改为 `push_error + null`，`global.gd` 调用方中止预热；
- 删除 `hdzm.gd` 热路径 `load()`、`monster_bullet` 的 `DirAccess` 扫描与 `range(601)` 编号探测；
- 诛仙剑阵的同步流式分支在本阶段后的 13-2C 中进一步删除。

### 2.2 Phase 13-2

**13-2A**：复用既有怪物帧资源，不建立重复资产；转换器校验动画名、帧数、region/margin、页闭包、PNG 边界与确定性 UID。

**13-2B**：54 个怪物脚本改为加载构建期 `SpriteFrames`；标准加载器把 sequence 名重命名为动作名的行为迁移到构建期动作别名；删除“资源缺失再逐帧 PNG”回退。

**13-2C**：

- C1：删除诛仙剑阵的运行时建帧、Atlas 流式回退与页面加载器；青莲 3 组序列生成 `.tres`；
- C2：新增 sheet-frame 转换器；青龙剑、太极模型与太极 22 帧效果改为构建期资源；新增永久法宝探针；
- C3：八仙 8 个场景改为引用模型/效果资源，删除 `model_path`/`effect_dir` 扫描与 1..100 探测；
- 角色特效：Lyfb 兼容特效 16 帧、哪吒阴阳剑/光环/Launch 5 个资源改为构建期资源。

最终运行时建帧：

```text
70 → 12
```

### 2.3 Phase 13-3

- `level_preload_catalog.tres` 与公共发布依赖清单由构建期生成；
- `global.gd` 删除两张动态表、`MONSTER_SCENE_ALIASES` 与追加函数；
- PCK 闭包合并 FrameSequence 与关卡预载清单，最终 **4,100** 条依赖全部可达；
- 最终实测 PCK **2,738,628,976** 字节，sha256 前缀 `8743a5ae4de4`；该数字是本次归档快照，后续资源变化后必须重跑。

### 2.4 Phase 13-4

- 2,313 条纹理别名全部分类并清空：
  - 932 条键/目标均缺失；
  - 86 条静态基名误报；
  - 1,021 条无命中 Monster；
  - 274 条无命中 UI/法宝/坐骑；
- 删除 `duplicate_texture_aliases.gd`、`TEXTURE_ALIASES` preload、`Global._resolve_texture_path()`、debug 命中统计与分类脚本；
- 纹理路径直接加载，旧路径不再兼容。

---

## 3. 冻结项与遗留项

### 3.1 运行时建帧冻结例外

| 域 | 文件 | 冻结理由 | 后续处理 |
|:---|:---|:---|:---|
| 怪物 | `east_continent_monster` | 关卡配置 merge，仅剩标准动作重命名 | 保持 allowlist；不强行静态化 |
| 怪物 | `eight_immortals_boss` | 运行时图集裁剪 | 保持；如资源可预生成再评估 |
| 怪物 | `monster_bullet` | 标准帧缺失时的 null 计时帧 | 保持；新增缺失应显式失败 |
| 怪物 | `nanhai_projectile` | 单序列裁剪 | 保持；等序列资源化 |
| 怪物 | `pet_tiger_boss_base` | 图集行列裁剪 | 保持；等帧资源覆盖 |
| 怪物 | `tao_wu_boss` | 资源异常时单图占位 | 保持；异常路径显式记录 |
| 怪物 | `three_prince_boss` | 运行时部件裁剪 | 保持；等部件资源化 |
| 怪物 | `three_prince_bullet` | 资源缺失时逐帧回退 | 保持；优先补资源而非恢复回退 |
| 怪物 | `weiyang_palace_boss` | 符号层单序列裁剪 | 保持；等符号层资源化 |
| 非怪物 | `pet_neat_bullet` | `pet_neat_4_bullet_3` 需蓝底抠图；构建期化需重复去底 PNG | 冻结；素材成本下降后再评估 |
| 非怪物 | `level_59` | 固定 `STONE_TEXTURES` 数组，无 IO | 冻结为合法例外 |
| 非怪物 | `user_key` | 调试工具 UI，不进入游戏运行路径 | 冻结为合法例外 |

约束：新增运行时 `SpriteFrames.new()` 未登记会被 `runtime_frames_audit.py` 阻断；allowlist 只减不增。

### 3.2 独立立项

| 项目 | 现状 | 最佳处理 |
|:---|:---|:---|
| `AtlasMetadata.data` typed accessor | 弱类型字典仍是过渡边界，未启动 | 先做消费者/字符串键清单与 typed schema；保留 `.data` 迁移边界；`--check` 与代表场景探针覆盖；不改变视觉结果 |
| Spine 跨平台运行时 | 仓库仅入库 Windows x86_64；其他平台声明存在但无二进制 | 先确定目标平台、Spine 运行时版本与许可证；补二进制/`.gdextension`；做目标平台加载与发布验收；不把 Windows 或 headless 结果当跨平台通过 |
| `global.gd` 与 13 个 Autoload | 遗留上帝对象与全局状态 | 独立拆分项目；新代码不扩张；不从 Phase 13 继续顺手改 |
| 类型分层目录 | 历史 `Scene/Script/Art` 结构 | 新功能按功能子目录聚合；不做无计划全量迁移 |
| `_bundled` 场景 | 仍是历史二进制场景 | 单独立项转换；补齐 UID/导入缓存并做回归 |
| 目标平台性能 | PCK 闭包已验证；VRAM、首帧、release 加载未在目标设备测量 | 真实设备验收；headless 探针不作为 VRAM 证据 |

### 3.3 未启动内容方向

7.0 及更高内容版本的回植尚未确认，不写入当前路线承诺。启动前必须按 `migration_playbook.md` §5.1 建立资产/UID 映射、转换器差异清单、Catalog/依赖更新与目标平台验收。

---

## 4. 发布前验收快照

| 项目 | 结果 |
|:---|:---|
| `check_all --godot-bin` | **8/8 PASS** |
| `health_check` | **0 Parse / 0 Error / 0 Warning** |
| `runtime_frames_audit --fail-on-error` | **12/12 PASS** |
| `convert_numbered_frames.py --all --check` | **PASS** |
| `convert_sheet_frames.py --check` | **PASS** |
| 场景探针 | **4/4 PASS**（星座 / 关卡选择态 / 角色技能 / 法宝与角色特效） |
| L2 `level_1` | **PASS**，Stage 1~4，日志 0/0 |
| L2 `coop_probe_runner` | **16/16 PASS** |
| L2 `scene_probe_runner` | **4/4 PASS** |
| 全量关卡回归 | **128/128 PASS + 5 SKIP，FAIL 0**（321.6s） |
| 发布依赖清单自检 | **4,100 条 PASS** |
| PCK 闭包探针 | **4,100/4,100 可达**；PCK 2,738,628,976 字节 |
| Windows release 可执行包 | **BLOCKED（2026-10-27）**：本机缺少 Godot 4.7.2 Windows export templates，`--export-release` 在模板检查阶段失败；未生成可运行 exe。官方 1.19 GB 模板下载未完成，不能用 PCK 或 headless 结果替代 |
| 目标设备首帧 / VRAM | **未验证**：需要在安装导出模板并生成 release 包后，于目标 Windows 设备测量；当前无有效结论 |

L2 与全量回归是发布前阻断项；`SKIP` 只允许既有 5 个非战斗场景。机器报告不归档，结论以本文与 `status.md` 为准。

---

## 5. 后续顺序

1. **发布前平台验收**：先安装 Godot 4.7.2 Windows export templates，生成 release exe，再在目标 Windows 设备验证加载、VRAM 与首帧；当前模板缺失，release 可执行包验收为 BLOCKED；
2. **AtlasMetadata typed accessor**：独立项目，先清单与 schema，再迁移消费者；
3. **Spine 跨平台运行时**：独立项目，先二进制/许可证/平台矩阵；
4. **内容版本回植**：目标明确后按 `migration_playbook.md` §5.1 执行；
5. `global.gd`、Autoload、类型分层与 `_bundled` 场景继续作为独立技术债，不混入普通功能提交。

Phase 13 已无待执行批次；后续工作从上述独立项目重新立项。

---

## 6. 经验与边界

- 构建期资源必须同时具备转换器 `--check`、消费者直接加载与探针；只生成 `.tres` 不足以证明运行时可用；
- 动作别名、region、duration、loop/speed 都是资源 schema 的一部分，必须逐项校验；
- 资源缺失应显式失败，不能用空帧或双路径回退掩盖；
- 运行期探针只证明 headless/编辑器路径，不能替代真实平台性能；
- 私有素材与公共代码必须按 `ASSET_CHANGE_CONTRACT.md` 分仓提交；
- 活跃文档只保留当前事实与路线，阶段过程进入归档，避免再次形成历史流水账。
