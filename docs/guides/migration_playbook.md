# 版本迁移操作手册

> **适用**：当前 `source/` 工程向更高内容版本迁移（6.9 已完成，下一次内容版本由用户确认）。
>
> **原则**：本手册只保留可复用的迁移方法与红线；具体版本的逐文件台账、原始验收记录不进入仓库。
>
> **配套**：[`../reference/status.md`](../reference/status.md)（当前状态）、[`../roadmap/roadmap.md`](../roadmap/roadmap.md)（未来路线）。

---

## 1. 核心策略

始终使用三方语义合并：

```text
base   = 目标版本之前的反编译源码基线
ours   = 当前 source/ 治理后的工程
theirs = 新版本的参考反编译源码
```

- 禁止“新版本整包覆盖”当前工程；
- 禁止把反编译 diff 直接 patch 到治理后的源码；
- 新版本差异只用于范围盘点、映射和最终验收；
- 每个功能域单独移植、单独验证、单独提交；
- 当前工程已有的命名、类型、契约和架构治理必须保留。

---

## 2. 迁移阶段

### Phase 0：基线与参考工程

1. 确认当前工作区可构建，记录当前门禁结果；
2. 在仓库外建立目标版本的解包/反编译沙盒；
3. 校验目标二进制的完整性与资源清单；
4. 生成目标版本的脚本、场景和资产参考工程；
5. 确认目标版本可以独立打开或反编译。

### Phase 1：路径与符号映射

1. 生成“目标版本路径 → 当前路径”映射；
2. 对无法自动映射的脚本、场景和资产人工核对；
3. 按文件类别标记：脚本、场景、数据、资产、导入缓存、打包文件；
4. 标记建议动作：移植、适配、复制资产、重建导入、忽略、复核；
5. 建立临时逐文件台账；台账属于迁移过程产物，不长期入库。

### Phase 2：功能批次移植

- 先基础设施与数据，再角色/技能，最后侵入性最大的系统；
- 每个批次保持可编译、可运行、可回滚；
- 新文件按当前架构重写，不直接复制反编译文本；
- 每批次完成静态门禁和相关冒烟后再进入下一批。

### Phase 3：资产与场景收口

- 按资源清单和哈希只复制新增/变化资产；
- 不复制旧导入缓存、`.ctex` 或旧 `.import`；
- 源资产复制后由 Godot 重新导入；
- 新增资产遵循 `docs/standards/naming_standard.md`；
- 场景先转为可比较的原生 `.tscn`，再做结构化差异；
- `project.godot` 只手工加入必要配置，不整体覆盖。

### Phase 4：全量验收

至少执行：

```bash
python scripts/check_all.py --skip-engine
python scripts/health_check.py --project source --godot-bin <godot>
python scripts/level_regression_all.py --changed-only --diff-base <base>
python scripts/level_test_runner.py --godot <godot> --level res://Scene/level/level_1.tscn
python scripts/coop_probe_runner.py --godot <godot>
python scripts/scene_probe_runner.py --godot <godot>
python scripts/convert_atlas_metadata.py --check
```

验收标准：

- 静态门禁全部通过；
- 完整工作区 0 ERROR / 0 WARNING；
- 关卡回归通过，或 changed-only 覆盖等价；
- Atlas 元数据与 manifest 全部同步；
- 所有变化文件都有明确处置结论；
- 临时探针、解包目录、逐文件台账不进入生产源码。

---

## 3. 解密与反编译验证

历史版本曾使用相同的 PE 布局、PCK 加密参数和 GDRE 反编译流程，但**不能假设新版本继续适用**。

每次迁移必须先验证：

1. PE 节区、PCK 起始偏移是否变化；
2. PCK 条目数与全量 MD5 是否一致；
3. 密钥常量与解密结果是否通过校验；
4. `.gdc` 字节码版本与 GDRE 映射是否仍匹配；
5. 反编译输出是否能与参考源码对上。

旧版解密/重建脚本只可作为参考：

- 通用解密器在确认偏移和密钥后可评估复用；
- 版本专用的重建、场景恢复、旧版本解包脚本不得直接用于新版本；
- 所有本地二进制路径、密钥和解包沙盒路径不得写入仓库。

---

## 4. 三方合并方法

对每个需要修改的脚本：

```bash
git merge-file --diff3 -p <ours.gd> <base.gd> <theirs.gd> > <merged.gd>
```

判定规则：

- 无冲突也必须人工复核命名、类型、契约；
- 有冲突按功能语义手工合并，禁止机械选择 ours/theirs；
- `modify/delete` 先判断当前删除是否属于治理性清理；
- 新增文件按当前架构改写，不直接复制；
- 优先做函数级 diff，避免整文件行级噪声。

---

## 5. 资产与数据规则

| 项目 | 规则 |
|:---|:---|
| Atlas manifest | 构建期由 `scripts/convert_atlas_metadata.py` 生成 `metadata.tres`；运行时只读 `AtlasMetadata` |
| SpriteFrames | 遵循 `docs/standards/spriteframes_generation_policy.md`；FPS、循环命名、speed 语义统一 |
| Spine | 先安装匹配的 GDExtension，再恢复源文件并重新导入；不复制旧导入缓存 |
| UID / `.import` | 新增资源必须带正确 `.import` 与唯一 UID；由 Godot 重新生成导入缓存 |
| 命名 | 遵循 `docs/standards/naming_standard.md`；白名单只减不增 |
| 数据 | 新结构化数据优先 `Resource` + `.tres`；不继续扩大 `global.gd` 与裸字典 |

### 5.1 视觉资产架构下的高版本回植检查表

> 适用：7.0 及更高内容版本向当前治理工程回植。目标契约见
> [`../standards/target_architecture_contract.md`](../standards/target_architecture_contract.md)，
> 当前实现见 [`../reference/architecture.md`](../reference/architecture.md)。

1. **版本与 schema**：确认目标版本的视觉资产格式、Spine 版本、动画命名与当前版本差异；schema 变化由专用适配器处理，不建立万能转换器。
2. **资产身份**：建立目标版本 `asset_id` / UID / 路径映射；禁止复用当前版本 UID，路径迁移统一走 `scripts/rename_path.py`。
3. **构建转换**：新增/变化资产必须先经构建期转换器（AtlasMetadata、MonsterFrames、FrameSequence、编号帧、动作视图等）；所有 `--check` 必须覆盖 schema、路径、UID、闭包与确定性。
4. **Catalog 与清单**：重新生成 `level_preload_catalog.tres`、`level_preload_export_dependencies.json`、FrameSequence Catalog 与两份发布依赖清单；PCK 闭包探针必须通过。
5. **运行时接入**：消费者只加载明确资源；禁止新增运行时目录扫描、编号探测、`SpriteFrames.new()` 重建、空占位或双加载回退。
6. **旧路径与别名**：纹理别名表已删除，旧路径不再静默兼容；回植时直接迁移数据/代码到规范路径，不重新建立无消费者别名表。
7. **动作与后端**：新动作进入 `monster_action_maps.json` 或动作视图；新视觉后端/Spine 版本必须新增 ADR 并单独验收；缺失动画显式失败。
8. **Spine 与导入**：每个 `.atlas` / `.spine-json` 必须有 `.import`、导入缓存与 `loaded=true`；不假定 `--import` 会自动为原始 Spine 源生成 `.import`。
9. **验证**：`check_all`、`health_check`、角色/UI 交互探针、全量回归、L2、PCK 闭包；角色技能资源需单独探针覆盖。
10. **版本与文档**：素材版本标签与内容版本一一对应；更新 `status.md`、`roadmap.md`、`architecture.md`；目标契约只维护目标，不写版本台账。

> 视觉资产检查表不替代功能代码的三方合并；玩法、数据与场景仍按本手册 §1~§4 执行。

---

## 6. 红线

1. 禁止整文件覆盖当前治理后的源码；
2. 禁止直接复制反编译代码进入生产工程；
3. 禁止直接 diff `_bundled` 场景；
4. 禁止复制 `.ctex`、旧 `.import` 或旧导入缓存；
5. 侵入性系统（例如双人模式）必须最后接入，先建接口再改基类；
6. 测试探针作为可执行规格，不直接进入主工程；
7. 打包差异不等于功能删除，不能据此移除当前工程的能力；
8. 每次提交保持原子性，提交前必须通过门禁；
9. 本地二进制、解密沙盒、临时目录与绝对路径不得进入文档或提交记录。

---

## 7. 下一次迁移检查表

- [ ] 目标版本二进制格式与加密参数已重新验证；
- [ ] 参考脚本/场景/资产已独立生成；
- [ ] 三方基线、ours、theirs 已明确；
- [ ] 逐文件映射与功能批次已拆分；
- [ ] 资产清单与 UID/`.import` 策略已确认；
- [ ] 静态门禁、引擎健康检查、关卡回归、Atlas 校验全部通过；
- [ ] 原始台账与临时产物未进入仓库；
- [ ] `status.md` 与 `roadmap.md` 已更新。
