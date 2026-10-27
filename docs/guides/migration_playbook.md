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
| UID / `.import` | 外部源素材维护导入配置；原生 `.tscn/.tres` 使用资源头 UID，脚本按机制维护 `.uid`；不复制缓存或伪造 `.import` |
| 命名 | 遵循 `docs/standards/naming_standard.md`，保留类型顶层与精确冻结例外；按实际收益迁移路径 |
| 数据 | 静态定义优先 Resource；会话/槽位状态与 JSON 持久化分离，不继续扩大 Global 与裸字典 |

### 5.1 总体目标架构下的高版本回植检查表

> 适用：7.0 及更高内容版本向当前治理工程回植。目标契约见
> [`../standards/target_architecture_contract.md`](../standards/target_architecture_contract.md)，
> 当前实现见 [`../reference/architecture.md`](../reference/architecture.md)。

1. **职责与依赖**：按目标契约 §2~§4 确认新增能力的拥有者、作用域和生产调用面；不把目标版本的全局依赖、场景切换旁路或深层节点路径直接复制进当前工程。
2. **会话与双人**：逐项核对个体/共享账本、攻击来源、输入与面板操作者。触及 2P 视图时联动检查保存快照互斥，不能只改 UI 或 LocalCoop。
3. **持久化**：维持当前加密 JSON、稳定密钥、原子写、备份与有限幂等补全；不可读档明确失败，不建立跨版本号迁移链或擅自改为 `.tres` 存档。
4. **版本与 schema**：分别记录业务定义/传输格式与视觉源格式变化；资源 schema 用范围明确的适配器，业务状态不塞进共享 Resource，不建万能转换器。
5. **资产身份**：同一内容身份维护稳定 UID；不同资源不得复用 UID。建立目标版本身份/路径映射，不因版本号不同无差别重发 UID；`source/` 改名走 `rename_path.py`。
6. **构建与清单**：变化资产先经对应转换器；按受影响范围生成关卡/FrameSequence Catalog 与代码侧/素材侧依赖清单，校验内容、schema、UID、闭包与确定性。
7. **运行时接入**：明确资源与后端；不恢复目录扫描、编号探测、空占位、旧路径别名或失败双加载。程序化内容与机读冻结例外按实际边界处理，不将一切 `SpriteFrames.new()` 一概列作禁令。
8. **生命周期**：检查冷启动/返回/重战、输入/结算交接、信号/计时/池重置、异步结果与退出回收；清字典不代表完成后台清理。
9. **Spine 与平台**：核对制作链、运行库、许可证和目标设备；Spine 原始源的导入配置与实际加载须验证，不假定复制旧缓存即可运行。
10. **验证与文档**：按 `acceptance.md` 的变更矩阵执行 L1、真实生产路径、相关双人/关卡/界面探针与阶段回归；涉及发布则验证实际包与 release。更新 architecture/status/roadmap，目标契约只保留长期规则。

本检查表覆盖总体接入边界，不替代 §1~§4 的功能代码三方语义合并。玩法、数值与显示变更单列验收，不与架构治理混写。

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
