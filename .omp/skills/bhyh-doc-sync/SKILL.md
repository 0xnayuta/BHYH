---
name: bhyh-doc-sync
description: 对 BHYH 项目执行代码与 Markdown 文档的一致性审计与对齐更新——以 source/ 的当前真实代码与门禁为事实源，排查并平滑消除文档滞后、过时路径与易漂移统计；覆盖 README、docs/reference、docs/standards、docs/decisions、docs/roadmap、docs/guides 与 scripts/README；修改默认保留在工作区，禁止未经确认直接提交。
---

# BHYH 文档与代码一致性审计与对齐 (bhyh-doc-sync)

> 触发时机：每个重大开发阶段（Phase）结束、重大重构合并至主干后，或用户明确要求检查文档与代码一致性时。
> 核心原则：**以 `source/` 当前真实代码与可执行门禁为唯一事实源**，全面排查并更新落后、过时的 Markdown 文档；贯彻**“保留物理/业务契约，弱化工程统计度量”**防漂移准则；**修改默认保留在本地工作区（Unstaged），严禁未经用户明确确认直接提交**。

---

## 1. 范围与边界

### 1.1 必须审计与对齐的现行文档（Active Docs）

1. **项目门户与总览**：
   - `README.md`：项目定位、目录结构、快速开始、质量流水线、文档入口与许可证边界。
   - `docs/README.md`：文档分层、活跃文档索引、机器报告与归档规则。
2. **参考与验收（`docs/reference/`）**：
   - `docs/reference/architecture.md`：运行时架构、Autoload、场景流、对象模型、数据/持久化、资源层、UI/输入、遗留边界。
   - `docs/reference/acceptance.md`：验收分层、八维门禁、契约域、引擎健康、运行期夹具、阈值与变更矩阵。
   - `docs/reference/status.md`：版本、规模、门禁与验证结果的单一事实源。
3. **规范（`docs/standards/`）**：
   - `naming_standard.md`、`godot_design_standard.md`、`naming_whitelist.md`、`missing_assets_registry.md`、`spriteframes_generation_policy.md`。
   - 规范与代码冲突时，先判断是代码违规还是规范过期；规范变更必须先改规范、再改代码/门禁。
4. **决策记录（`docs/decisions/`）**：
   - `docs/decisions/README.md` 与全部 ADR；核对编号、状态、索引与实现一致性。
   - **已接受 ADR 不直接改写**；决策变化新增 ADR，并在旧 ADR 标注 `Superseded by ADR-xxx`。
5. **路线图与指南（`docs/roadmap/`、`docs/guides/`）**：
   - `roadmap.md`、`current-iteration.md`：阶段状态、边界与验收描述。
   - `migration_playbook.md`：版本迁移方法、阶段与红线。
6. **工具链索引**：
   - `scripts/README.md`：脚本职责、参数、产物、退出码与在 `check_all` 中的归属。
7. **工程摘要**：
   - `AGENTS.md`：只读核对；当详细规范变更导致摘要过期时，按 `docs/standards/README.md` 的优先级同步摘要，不重写红线。

### 1.2 严格排除与禁止修改的范围（Forbidden Scope）

- **`docs/archive/`**：已完成阶段归档，保持历史原貌，只作参考，严禁主动修改。
- **`docs/audit/`**：历史审计报告与只读模板，属于时间戳固化的审计档案；只读引用，不修改、不补写历史结论。
- **`docs/reports/`**：脚本生成的机器报告，随时可能被覆盖；不手改、不提交历史报告，结论写入 `docs/reference/status.md`。
- **`source/addons/`、`source/bin/`**：第三方插件与 Spine 运行库；只核对集成边界、版本与许可证，不修改其内部实现或文档。
- **`.omp/skills/`**：项目本地 agent skills；除非用户明确要求维护 skill，否则不作为文档同步对象。
- **`source/` 业务代码**：doc-sync 只改文档；发现代码缺陷另开修复/审计，不在本 skill 内顺手修改。

---

## 2. 核心原则：防漂移准则（Anti-Drift Policy）

更新 Markdown 时，必须执行**“保留物理/业务契约，弱化工程统计度量”**：

### 2.1 必须系统性弱化（抽象化）的波动性工程度量

以下指标随日常迭代频繁变动，**严禁在活跃文档中硬编码为长期事实**：

1. **源码/场景/资源总量**：GDScript 总数、业务/插件脚本数、`.tscn` 数、`.tres` 数、PNG/MP3/WAV 数量、仓库体积。
2. **单文件行数**：`global.gd`、`base_hero.gd`、`level_info.gd`、`pet_interface.gd` 等“当前约 N 行”。
3. **历史验证计数**：`128/128 + 5 SKIP`、`16/16`、`379/379`、`8/8`、`7/7` 等 PASS 数，除非明确标注为某一提交/日期的历史快照。
4. **运行时测量值**：门禁耗时、关卡回归总耗时、VRAM 峰值、单帧耗时、缓存命中率、警告数量变化（如 `53→0`）。
5. **当前清单长度**：Atlas manifest 数量、哪吒输出套数、探针用例数、白名单条目数、输入动作/物理层数量，除非它是需要评审才能变更的契约。
6. **临时环境数据**：本机 Godot 路径、用户目录、日志大小、构建缓存文件数。

正确写法示例：

- ❌ `项目包含 706 个业务 GDScript、1,136 个场景、16,709 张 PNG。`
- ✅ `项目规模以 docs/reference/status.md 为单一事实源；本文只描述目录职责与架构边界。`
- ❌ `global.gd 当前约 5,592 行。`
- ✅ `global.gd 是遗留上帝对象，承担场景切换、UI 工厂、缓存/预池与部分业务判定，不得继续扩张。`
- ❌ `全量关卡回归 128/128 PASS，双人探针 16/16 PASS。`
- ✅ `全量关卡回归与双人探针按 acceptance.md 的 L2/L3 档位执行；历史结果见 status.md。`

### 2.2 坚决严格保留的契约性常量与规则

以下属于架构决策、业务契约、设计基线或质量 SLA，**必须保持精准表述**：

1. **引擎与语言**：Godot 4.7.2、GDScript 2.0、优先静态类型。
2. **显示基线**：1280×800 设计画布、1600×1000 默认窗口、16:10、1.25×、`canvas_items` + `expand`、相机 1.2 与纵向取景偏移；桌面 HUD 五按钮/无双/技能槽基线。
3. **质量门禁**：`check_all.py` 八维、完整工作区 0 ERROR / 0 WARNING、契约 ERROR=0、WARNING ≤ 1050、命名/资源路径/运行时引用门禁。
4. **命名与数据契约**：`snake_case` 文件/目录、`PascalCase` 场景节点/`class_name`、`DataKeys` 字典键、UID/`.import` 规则、白名单只减不增。
5. **架构决策**：单一活跃工程、Resource 优先、Autoload 边界、构建期资产管线、Spine 边界、本地双人槽位隔离、无兼容/回退/跨版本迁移链、三方语义合并、路径迁移走 `rename_path.py`。
6. **仓库与交付边界**：公开仓库排除第三方素材、代码 MIT、Spine 许可证、本地 commit 需验证且未经允许不 push、环境隔离（不记录本地私有路径）。
7. **存档契约**：加密 JSON、`.tmp`/`.bak` 原子写、稳定密钥、`ensure_*` 补全、旧目录/旧任务键/旧配置不迁移；只允许有限、幂等的当前格式规范化。

> 判断标准：修改该数值是否必须经过 ADR/规范/评审？是 → 契约，保留；否 → 统计度量，弱化或移到 `status.md`/审计报告。

---

## 3. 标准执行流程（Five-Step Workflow）

### Step 1：增量与代码基线探测（Code Survey）

1. 检查最近提交与变更范围：`git log -20 --oneline`、`git diff --stat <base>..HEAD`、`git status --porcelain`。
2. 梳理本阶段在 `source/` 引入的核心演进：新增/重构的 GDScript 类、场景、`project.godot` 配置、资源清单、DataKeys、转换器与门禁。
3. 记录核心类名、函数签名、状态枚举、资源路径与门禁命令；优先使用 codegraph，索引不可用时回退 `grep`/`read`，不凭记忆猜 API。
4. 涉及第三方 Godot API 时用 Context7/官方文档核实签名；涉及公共符号时用 LSP 查引用。

### Step 2：现行文档扫描与落后点定位（Doc Audit）

1. 对照 Step 1 的代码事实，逆向检索相关文档。
2. 重点排查：
   - 架构文档的 Autoload/场景流/对象模型/资源层是否仍描述旧实现；
   - `project.godot` 的 Autoload、输入、物理层、显示配置是否与文档一致；
   - `acceptance.md` 的门禁命令、阈值、档位是否与 `scripts/` 实际行为一致；
   - `status.md` 的当前版本、已知边界与最新验证记录是否同步；
   - 命名、白名单、缺失资产、SpriteFrames 策略是否与转换器/审计脚本一致；
   - ADR 索引是否完整，是否出现“已接受决策被静默改写”；
   - 文档中的旧路径、旧文件名、旧命令、旧链接；
   - 易漂移统计是否仍在活跃文档中硬编码。

分类处理：

| 类型 | 处理 |
|:---|:---|
| 当前事实过期 | 直接更新活跃文档 |
| 决策变化 | 新增 ADR；旧 ADR 只标注替代关系，不改结论 |
| 历史事实 | 保留在 `archive/` 或历史审计报告，不搬进活跃文档 |
| 机器报告 | 不手改；结论写入 `status.md` |
| 代码缺陷/规范冲突 | 记录为待修复项，另开修复或审计；不在 doc-sync 内改代码 |
| 无法验证的能力 | 不写入文档，或明确标注未实现/未验证 |

### Step 3：精确编辑与防漂移平滑对齐（Editing & Alignment）

1. 使用项目工具小步编辑，遵守中文注释/文档规范与既有术语；代码标识符、路径、API 名称不翻译。
2. 逐一更新落后描述、结构图、命令、路径、索引与测试/验证说明。
3. 应用 §2 防漂移准则：剥离易变统计，保留契约常量；统计需要保留时明确基线日期与来源。
4. 更新索引：`README.md`、`docs/README.md`、`docs/reference/README.md`、`docs/decisions/README.md`、`scripts/README.md` 中受影响的入口。
5. 不修改 `docs/archive/`、`docs/audit/`、`docs/reports/`、已接受 ADR 或第三方目录。
6. 不把规划目标写成现状；未实现能力标“目标/未落地”，并给出边界。

### Step 4：质量门禁与回归验证（Gate Verification）

1. 文档链接检查：对 `README.md`、`docs/**/*.md`、`scripts/README.md` 的相对链接做一次检查，记录检查文件数与缺失链接数。
2. `git diff --check` 检查空白错误；`python scripts/normalize_eol.py docs --dry-run` 检查 CRLF（注意该脚本可能在仓库根生成 `.cache/`，结束后清理自有产物）。
3. 若本次只改文档：不需要引擎门禁，但必须确认未误改 `source/`。
4. 若同时改了 `scripts/` 或代码：执行 `python scripts/check_all.py --skip-engine`；涉及运行时/场景/资源时按 `acceptance.md` 追加引擎/冒烟/回归。
5. 检查 `git status`，确认没有把 `docs/reports/` 机器报告、`.godot/` 缓存或临时探针加入变更。
6. 文档中的命令必须来自实际脚本参数，不写未经验证的 `...` 或本地绝对路径。

### Step 5：交付汇总与等待确认（Report & Confirmation）

1. 运行 `git status` 与 `git diff --stat` 确认修改范围。
2. 向用户输出审计与对齐报告：
   - 识别出的关键代码演进与文档落后点；
   - 本次更新的文件清单与每个文件的核心改动；
   - 防漂移准则落实情况（哪些统计被抽象化、哪些契约被保留）；
   - 门禁/链接检查结果与未验证范围。
3. **保持工作区修改未提交（Unstaged）**，明确等待用户审查并给出提交指示。
4. 用户确认后，按 `AGENTS.md` §6 使用中文 Conventional Commits（`docs:` 类型，单逻辑单提交）；未经明确允许不得 `git push`。

---

## 4. 交付与行动准则

- **单一事实源**：实现以 `source/` 当前代码与门禁为准；状态以 `docs/reference/status.md` 为准；架构以 `architecture.md` 为准；验收以 `acceptance.md` 为准；决策以 `docs/decisions/` 为准。严禁把未实现能力写进文档。
- **不越界**：doc-sync 只改文档，不修代码、不改归档/审计历史、不改第三方、不重建机器报告。
- **免提交承诺**：文档更新完成后只汇总报告，不自动执行 `git add` 或 `git commit`。
- **可回滚**：保持小步编辑；每次修改前后可用 `git diff` 审阅；不进行大规模无边界重写。
- **链接可验证**：移动/新增文档必须同步索引与相对链接，并执行链接检查。
- **提交建议**：用户确认后推荐 `docs: 对齐文档与当前代码状态并应用防漂移准则`；正文写明范围、契约保留与验证结果。
