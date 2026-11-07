# 当前工程状态 (Status)

> **定位**：当前版本、运行基线、门禁与已知边界的单一事实源。
> **最后更新**：2026-11-07。历史验证记录已归档到 [`../archive/validation_history_2026.md`](../archive/validation_history_2026.md)；Phase 24/25/27 的实施记录见 [`../archive/README.md`](../archive/README.md)；本页只保留当前事实与最近基线。
> **阶段状态**：7.0 内容回植已完成并通过当前验收；Phase 35 的 7.1 回植进行中（35-1 完成），Phase 26 发布/平台测量长期暂缓。完整阶段顺序见 [`../roadmap/roadmap.md`](../roadmap/roadmap.md)。

---

## 1. 版本与运行基线

| 项目 | 值 |
|:---|:---|
| 工程标识 | **造梦西游八荒湮隳（BHYH）** |
| 当前内容版本 | **7.0**（6.9 基线 + 7.0 内容回植：角色 8、2P、UI 与系统修复） |
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
| `check_all --godot-bin` | **9/9 PASS**（2026-11-07 35-1 复跑） |
| 字体覆盖 | **135 场景 / 788 中文节点 / 0 缺字；Theme 字体 4 文件；动态样本 5 / 0 缺字**（`font_coverage_audit.py --check`） |
| `font_role` | **734 变体 / 0 错误 / 0 条存量字号例外**（`font_role_audit.py --check`） |
| UI Theme 运行时探针 | **PASS**（`scene_probe_runner --probe ui-theme`，7.32s） |
| UI Factory 运行时探针 | **PASS**（`scene_probe_runner --probe ui-factories`，32.86s） |
| Theme token | **734 变体 / 0 违规；有效字号与 8 类字体色全部在 token**（`theme_token_audit.py --check`） |
| UI Theme token 源 | **39 文字 token / 6 组表面 / 37 语义字体色 / 10 项受管 Theme 属性 / 0 漂移**（`convert_ui_theme_tokens.py --check`） |
| Theme 变体/规模 | **618 冻结变体 / 112 语义基类 / 734 总变体 / 属性 1,788 / StyleBox 36 / 独立重复组 10**（`theme_variant_audit.py --check`） |
| Theme 字体角色 | **body FZCuYuan M03 / ui LXGW WenKai Regular / display FZCuYuan M03 / accent LXGW WenKai Medium**；msyh 仅作 body fallback；直接字体 0 |
| 动态 Theme 覆盖 | **352 调用 / 静态 0 / token 173 / data 43 / layout 96 / dynamic_style 40**（`ui_dynamic_theme_audit.py --check`，覆盖 `Script` 与 `Scene`） |
| UI 表面色 token | **main_menu 0 裸色；StyleBox 0 处 / 0 新增**（`ui_surface_token_audit.py --check`，self-test 11/11） |
| UI Theme 直接覆盖 | **直接属性 0 / 动画轨道 26 / 直接字体 0**（`theme_override_audit.py --check`） |
| HUD 只读探针 | **PASS**（`coop_probe_runner --only LocalCoopHudReadOnlyProbe`，7.70s） |
| `health_check` | **796 脚本 0 Parse / 0 Error / 0 Warning** |
| `archive_probe_runner` | **344/344 PASS**（7.0 回植复跑） |
| `scene_probe_runner` | **35-1 全量 20 项：20 PASS**；`longnv-core` PASS；`load-guard` 的 0ms 超时用例中断 `level_3.tscn` 解析后产生的 Theme/字体依赖 `Failed loading resource` 已按预期噪声登记 |
| `coop_probe_runner` | **37/37 PASS**（7.0 回植复跑，含 2P 相机/HUD/推图） |
| `level_1` 冒烟 | **PASS，4 阶段，0/0/0；`--role 8` 主角为 Role_8** |
| 全量关卡回归 | **PASS 128/128 + SKIP 5，FAIL 0**（6.9 基线；7.0 未重跑全量） |
| PCK 验证包（FrameSequence） | **4,200/4,200 路径可达**；7,658,500,221 字节；sha256 `6bd42e324684b24208efe27448c9cae23ad0a1d5593d74338415e6eabbdd8010`；导出+校验 **890.48s**（6.9 基线） |
| PCK 原始数据清单 | **993/993**（7.0 原始数据闭包；`export_raw_manifest.py --check` 通过） |
| Release PCK（实际 exe） | **5,044/5,044**（6.9 基线；844 原始数据 + 4,200 FrameSequence）；7,658,516,894 字节；sha256 `8e73922e99daf2004e9f6a15a4ed6571e436d0e2974b7cb8cb64cb7c9e84dcc3`；`BHYH.exe` 109,293,056 字节；7.0 未重建 release PCK |
| Release 冷启动 | `load_scene.tscn` 加载，`--quit-after` 退出码 0；游戏与 stdout 均 **0 ERROR / 0 WARNING**；直接 `level_1` override 加载成功，1 条无档案会话警告属测试夹具限制 |

**边界**：PCK 为验证/发布预设的路径闭包；本表另有真实 release exe 冷启动证据，但 PCK 路径可达仍不等于目标设备 VRAM、首帧耗时或正式发布包裁剪已验证。原始数据由 `export_raw_dependencies.json` + `bhyh_export` 插件写入，不再使用 `include_filter` 兜底。

### 7.0 回植状态（2026-11-07）

- **角色 8 小龙女**：8 个 Longnv 脚本 + 风暴帧混合 shader、`Role_8` 场景、官方部件/音频、20 技能与双刃/圆刃形态已完成；角色选择卡、技能页 20 行、自动战斗配置、背包/幻化预览、2P 数据/属性/键位已接入。
- **2P**：角色 8 双人关卡已验证 P1/P2 生成、镜头居中、P2 HUD 绑定、独立档案/属性/冷却、P2 技能与近战起手、P1 倒地时由 P2 推进关卡。
- **7.0 系统修复**：等级溢出经验循环、死亡/满级升级保护、P2 八仙坠落、青龙剑乘骑/下落、哪吒技能等级上限、宋帝王双人命中数、`jgz` 伤害倍率、`skill_grid` 20 行背景等已按 7.0 语义接入。
- **边界**：7.0 云存档上传/下载差异依赖外部服务，未纳入本轮 gameplay 回植；7.0 release PCK、全量关卡回归与目标设备性能未重跑。角色 8 的训练/成就/云存档服务端闭环仍以外部能力为准。
- **验证**：`check_all --godot-bin` 9/9；`health_check --no-cache` 794 脚本 0/0/0；`archive_probe_runner` 344/344；`scene_probe_runner` 20/20；`longnv-core` PASS（20 技能、角色卡、技能页、自动战斗、背包/幻化/翅膀/坐骑、2P 关卡相机/HUD/战斗）；`level_1 --role 8` 4 阶段 0/0/0；`coop_probe_runner` 37/37。

### 7.1 回植进行中（35-0 / 35-1）

- **35-0**：已生成 7.1 反编译参考源码、19 个变更/测试场景与逐文件台账；7.1 清单新增 34、修改 41、删除 0，生产未映射 0，资源差异 0。
- **35-1**：已接入 `PlayerData` 宠物装备强化上限、`MainSet` 技能特效透明度设置、`RoleSkillOpacity`、`RoleAttackMechanism`、`BaseMonster` 的 `yyb` 觉醒眩晕/5 倍天雷，以及 `SkillDamageFormulaData` 说明文本。
- **边界**：当前内容版本仍为 **7.0**；7.1 尚未完成全部功能批次，`GameSet` 透明度滑条、Longnv 技能/关卡/场景批次仍待后续。PCK/release 与目标设备验证按用户决策暂缓，待 7.3 回植完成后统一验证。
- **本批验证**：`check_all --godot-bin` 9/9；`health_check --no-cache` 796 脚本 0/0/0；`archive_probe_runner` 344/344；`scene_probe_runner` 20/20；`longnv-core` PASS；`ui-theme` PASS；运行时诊断覆盖透明度、区域转发、宠物强化上限与 `yyb` 文本。

### 最近基线（2026-11-04 ~ 2026-11-07）

> 只保留当前仍需知晓的最近结果；逐批耗时、截图位置与历史计数不在此复制，完整记录见对应归档页。

- **2026-11-07 7.0 内容回植**：角色 8 小龙女、2P、角色选择/技能页/自动战斗、背包/幻化/翅膀/坐骑与 7.0 系统修复收口；详见上节。私人素材仓以 `assets(7.0)` 独立提交，公开仓只保留代码/场景/资源引用。
- **2026-11-06 存档槽文本居中**：`bacis_ar_button` 的 `InfoBox` 由 `x=52..249` 扩为槽位全宽 `0..265`，`VBoxContainer.alignment` 改为居中；空名称与空时间行隐藏；空档、单角色与双角色行均按槽位中心排列。`archive_probe_runner` **344/344 PASS（14.26s）**，`check_all` **9/9（30.24s）**，未重跑全量关卡回归。
- **2026-11-06 UI 四项修复**：加载页百分比字号由 32 收至 24 并居中；HUD 三值条统一为 12px 高、3px 间隔、按可见框体边界统一起点 26px；HP/MP/EXP 切为三个 `AtlasTexture`；法宝面板删除重复的 `m_MDef`（33 个法宝 `Def`/`Mdef` 全部相等）；实战法宝等级改用 `%d` 取整。`ui-factories` 新增 `backpack_magp_single_defense`、`backpack_magp_def_value`、`backpack_skill_select_level_integer` 断言；`check_all` **9/9（26.69s）**，`ui-factories` **PASS（30.00s）**，HUD 只读 **PASS（7.70s）**；未重跑全量回归。
- **2026-11-06 标点与内部名称迁移**：修订 19 处玩家可见标点并补齐 `magic_help` 3 处句末句号；11 处源码内部名称改为中文括号，覆盖 `level_info`、`lhhj`、`monster_head_info`、`level_62`、`minghai_boss3117`、`game4_east_late_level`、`east_continent_monster` 与 `monster_zhw` 族，未保留旧名别名；扫描 33 个文件统一中英文标点。新增 report-only `scripts/ui_text_punctuation_audit.py`，自测 9 个样本、全仓 0 残留。`check_all` **9/9（37.00s）**，`health_check` 0/0/0。
- **2026-11-06 UI 偏移与弹窗边界**：暂停菜单提示上移；`choose_music` 新增 `ChooseMusicButton`，列表间距 6→4；`change_back_ground` 列表间距 10→8；ESC 暂停菜单按钮块垂直居中、间距 9→11；属性 tooltip 宽度 315→380 并补充伤害/免伤提示；炼丹炉 8 个按钮统一坐标。`check_all` **9/9（29.83s）**，`ui-factories` **33.08s**，`level_1` 4 阶段 0/0/0。
- **2026-11-06 字体角色延伸**：帮助标题 7 个变体与技能界面 5 个变体迁 `display`；新增 `SkillHeaderLabel`；最终角色为 `body` FZCuYuan M03 / `ui` LXGW WenKai Regular / `display` FZCuYuan M03 / `accent` LXGW WenKai Medium；Theme **734 变体 / 属性 1,788 / 重复组 10**；`font_role_audit`、`theme_variant_audit`、`theme_token_audit` 均 0 违规。完整批次见 [`../archive/iteration_27_theme_font_convergence.md`](../archive/iteration_27_theme_font_convergence.md)。
- **2026-11-05 真实法宝与装备 tooltip**：`ui-factories` 临时注入 `tjbg` 法宝实例，验证名称/技能标题、`1/N` 分页与 3 个技能项；`equipment_properies` 各分支统一经 `_set_description_and_sale` 写入描述/售价，新增 3 条工厂宿主断言。`check_all` **9/9（31.52s）**，`level_1` 4 阶段 0/0/0。
- **2026-11-04 回植收口与原始数据导出契约**：`Level_65`/`Level_68` BOSS 出生点移除 `ignore_count_multiplier` 并新增 `boss-multiplier` 探针；新增 `export_raw_roots.json`、`export_raw_manifest.py`、`export_raw_dependencies.json`、`bhyh_export` 插件、`export_closure_probe.py` 与 `export_release.py`；移除 `include_filter="*.bin"`，原始数据 **844/844**、release PCK **5,044/5,044**。`check_all` **9/9（31.39s）**，`archive` **344/344**，`scene` **19/19**，`coop` **37/37**。
- **2026-11-04 命名终审**：DragonBones GDExtension 登记为第三方前缀；私有 `source/Data` 收敛为 `source/data`；`naming_compliance_audit --fail-on-error` 目录/文件/代码标识符均 **100%**；白名单评审 5 条、未登记/失效 0。
- **2026-11-04 6.6/6.8 回植缺口**：补齐清音阁/五台山口/桃花谷/万妖穴四条玉兔制作书掉落及 `LevelInfo` 预览；恢复 8 个八仙/太极八卦材料合成例外与法宝出入炉回写；恢复 6.8 双人相机/Buff/灵气/2P 被动/键位提示。`check_all` **9/9**，`archive` **344/344**，`scene` **17/17**，`coop` **37/37**，全量 **128/128 + 5 SKIP（308.4s）**。
- **2026-11-04 运行时回归修复**：宠物预热门禁与寅虎动作帧修复（`convert_monster_action_views.py --check` **5/5**，`pet-runtime` PASS）；183 个场景 **412** 条 AnimationMixer 单键 value track 改为离散更新；关卡回归保留失败关首轮证据并过滤三类已验证 headless 噪声，阶段清场后等待物理帧再传送。全量 **128/128 + SKIP 5**。

---

## 3. 当前已知边界

1. **平台**：Spine GDExtension 当前仅入库 Windows x86_64；21-2A 最低设备确认与 21-2B 平台测量仍暂缓。
2. **发布**：`BHYH.exe` + `BHYH.pck` 冷启动已通过（`load_scene.tscn`、游戏与 stdout 均 0 ERROR / 0 WARNING），实际 release PCK **5,044/5,044** 路径可达；目标设备峰值 VRAM、首帧耗时与正式发布包裁剪仍需单独设备实测。直接以 `level_1` override 启动属于无档案会话测试，会产生 1 条预期 `change_scene` 警告，不据此判定发布流程失败。
3. **公开仓库**：不包含第三方素材；公开 clone 的缺失资源提示属于预期。
4. **存档**：加密 JSON、`.tmp`/`.bak` 原子写与当前格式补全不变；不引入跨版本迁移链。
5. **架构**：Autoload 与 `Global` 普通子节点运行时是遗留基线；新增需按 [`autoload_boundary_matrix.md`](autoload_boundary_matrix.md) 评审。
6. **文档**：历史验证只在归档中保留，当前页不复制逐批计数。
7. **命名终审**：`naming_compliance_audit.py --fail-on-error` 已通过（目录、文件、代码标识符均 **100%**）；`naming_audit.py --all` 与 `whitelist_audit.py` 通过。第三方 DragonBones 前缀已登记，私有 `Data` 别名已收敛为 `data`；该结果可作为 L3/release 命名终审证据，但不替代目标设备性能与正式发布包裁剪验证。
8. **回植剩余边界**：6.6 `Level_65`/`Level_68` 的 BOSS 出生点已按上游移除 `ignore_count_multiplier`，`boss-multiplier` 探针覆盖 `×1`/`×5`；上游 `Monster_63-1` 无生产场景消费者，`MagicWeapon_qlsword/Official/source.json` 与 `Music/Hero/Role6/official_manifest.json` 为无运行时消费者的溯源文件，登记为非运行时、不移植。
9. **7.0 外部服务边界**：7.0 云存档上传/下载差异依赖外部服务，未纳入 gameplay 回植；角色 8 的训练/成就/云存档服务端闭环以外部能力为准。7.0 release PCK、全量关卡回归与目标设备性能未重跑。

---

## 4. 目录与规模

工程根为 `source/`，目录职责见 [`architecture.md`](architecture.md) 与 [`../../README.md`](../../README.md)。具体脚本/场景/资源数量随迭代变化，不作为本页契约；需要时从当前工作区重新统计，不使用历史数字。
