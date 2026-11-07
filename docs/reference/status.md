# 当前工程状态 (Status)

> **定位**：当前版本、运行基线、门禁与已知边界的单一事实源。
> **最后更新**：2026-11-07。历史验证记录已归档到 [`../archive/validation_history_2026.md`](../archive/validation_history_2026.md)；Phase 24/25/27 的实施记录见 [`../archive/README.md`](../archive/README.md)；本页只保留当前事实与最近基线。
> **阶段状态**：Phase 37 的 7.3 内容回植完成（37-0~37-4 批次完成；L3 已通过；PCK/release 暂缓）；Phase 36 的 7.2 L3 收口完成、待发布验证；Phase 35 的 7.1 L3 收口完成、待发布验证；Phase 26 发布/平台测量长期暂缓。完整阶段顺序见 [`../roadmap/roadmap.md`](../roadmap/roadmap.md)。

---

## 1. 版本与运行基线

| 项目 | 值 |
|:---|:---|
| 工程标识 | **造梦西游八荒湮隳（BHYH）** |
| 当前内容版本 | **7.3**（7.3 内容回植 L3 已完成；PCK/release 待发布验证） |
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
| `check_all --godot-bin` | **9/9 PASS**（2026-11-07 36-6 复跑，44.61s） |
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
| `health_check` | **806 脚本 0 Parse / 0 Error / 0 Warning** |
| `archive_probe_runner` | **344/344 PASS**（L3 复跑） |
| `scene_probe_runner` | **36-6 全量 26 项：26 PASS**（305.94s）；`awaken-72` / `menu-ui-72` 通过；`longnv-core` / `longnv-71` / `longnv-mechanism` / `menu-ui-71` 均 PASS；`load-guard` 的 0ms 超时用例中断 `level_3.tscn` 解析后产生的 Theme/字体依赖 `Failed loading resource` 已按预期噪声登记 |
| 7.2 觉醒运行时探针 | **PASS**（`scene_probe_runner --probe awaken-72`，10.41s；重斩三道地裂、玄冰阵五段冰刺与冰域、哪吒双火轮、月魔舞三月影、觉醒弹窗/技能面板/一阶觉醒石） |
| 7.2 其余脚本探针 | **PASS**（`scene_probe_runner --probe menu-ui-72`，8.82s；年兽预载、V7.2 公告、喜鹊叠加/上限、幻化翅膀/头衔、小龙女昵称） |
| `level_regression_all` | **128/128 PASS + 5 SKIP**（L3 全量，`--jobs 12`，370.18s；`level_ghg` 重试通过） |
| `coop_probe_runner` | **38/38 PASS**（L3 复跑，含 2P 相机/HUD/推图/年兽） |
| `level_1` 冒烟 | **PASS，4 阶段，0/0/0；`--role 8` 主角为 Role_8** |
| PCK 验证包（FrameSequence） | **历史 6.9 基线：4,200/4,200 路径可达**；7,658,500,221 字节；sha256 `6bd42e324684b24208efe27448c9cae23ad0a1d5593d74338415e6eabbdd8010`；**7.1 PCK 按用户决策暂缓** |
| PCK 原始数据清单 | **993/993**（7.1 原始数据闭包；`export_raw_manifest.py --check` 通过） |
| Release PCK（实际 exe） | **5,044/5,044**（6.9 基线；844 原始数据 + 4,200 FrameSequence）；7,658,516,894 字节；sha256 `8e73922e99daf2004e9f6a15a4ed6571e436d0e2974b7cb8cb64cb7c9e84dcc3`；`BHYH.exe` 109,293,056 字节；7.0 未重建 release PCK |
| Release 冷启动 | `load_scene.tscn` 加载，`--quit-after` 退出码 0；游戏与 stdout 均 **0 ERROR / 0 WARNING**；直接 `level_1` override 加载成功，1 条无档案会话警告属测试夹具限制 |

**边界**：PCK 为验证/发布预设的路径闭包；本表另有真实 release exe 冷启动证据，但 PCK 路径可达仍不等于目标设备 VRAM、首帧耗时或正式发布包裁剪已验证。原始数据由 `export_raw_dependencies.json` + `bhyh_export` 插件写入，不再使用 `include_filter` 兜底。

### 7.0 回植状态（2026-11-07）

- **角色 8 小龙女**：8 个 Longnv 脚本 + 风暴帧混合 shader、`Role_8` 场景、官方部件/音频、20 技能与双刃/圆刃形态已完成；角色选择卡、技能页 20 行、自动战斗配置、背包/幻化预览、2P 数据/属性/键位已接入。
- **2P**：角色 8 双人关卡已验证 P1/P2 生成、镜头居中、P2 HUD 绑定、独立档案/属性/冷却、P2 技能与近战起手、P1 倒地时由 P2 推进关卡。
- **7.0 系统修复**：等级溢出经验循环、死亡/满级升级保护、P2 八仙坠落、青龙剑乘骑/下落、哪吒技能等级上限、宋帝王双人命中数、`jgz` 伤害倍率、`skill_grid` 20 行背景等已按 7.0 语义接入。
- **边界**：7.0 云存档上传/下载差异依赖外部服务，未纳入本轮 gameplay 回植；7.0 release PCK、全量关卡回归与目标设备性能未重跑。角色 8 的训练/成就/云存档服务端闭环仍以外部能力为准。
- **验证**：`check_all --godot-bin` 9/9；`health_check --no-cache` 794 脚本 0/0/0；`archive_probe_runner` 344/344；`scene_probe_runner` 20/20；`longnv-core` PASS（20 技能、角色卡、技能页、自动战斗、背包/幻化/翅膀/坐骑、2P 关卡相机/HUD/战斗）；`level_1 --role 8` 4 阶段 0/0/0；`coop_probe_runner` 37/37。

### 7.1 回植完成（L3 已收口；待发布验证）

- **35-0**：已生成 7.1 反编译参考源码、19 个变更/测试场景与逐文件台账；7.1 清单新增 34、修改 41、删除 0，生产未映射 0，资源差异 0。
- **35-1**：已接入 `PlayerData` 宠物装备强化上限、`MainSet` 技能特效透明度设置、`RoleSkillOpacity`、`RoleAttackMechanism`、`BaseMonster` 的 `yyb` 觉醒眩晕/5 倍天雷，以及 `SkillDamageFormulaData` 说明文本。
- **35-2**：已接入 Longnv 7.1 技能数据、觉醒冷却、冲刺窗口/无敌、分刃、暂停层与 `LongnvScreenStorm` 增频；新增 `longnv-71` 运行时规格探针。
- **35-3**：已接入 `ContinentMonsterGrowth`、关卡机关 `RoleAttackMechanism`、9 个关卡场景机关、Level 5/28/34/75、北俱芦洲怪物/地形、三太子受击入口、`map_7`/`map_8` 开放范围；Level_77 无场景语义差异；新增 `longnv-mechanism` 运行时规格探针。
- **35-4**：已接入 GameSet 技能透明度、V7.1 公告、自动战斗角色 8 名称、觉醒浮层小龙女/玉兔/白龙描述、`zd_skill` 角色 8 觉醒按钮与玉兔冲刺无敌；新增 `menu-ui-71` 运行时规格探针。
- **边界**：7.1 回植已完成；当前内容版本为 **7.2**；PCK/release 与目标设备验证按用户决策暂缓，待最终发布统一验证；7.3 未立项。
- **本批验证**：`check_all --godot-bin` 9/9；`health_check --no-cache` **797 脚本 0/0/0**；`scene_probe_runner` **23/23**；`level_regression_all --jobs 12` **128/128 PASS + 5 SKIP**；`coop_probe_runner` **37/37**；`archive_probe_runner` **344/344**；`export_raw_manifest --check` 993 文件；`convert_atlas_metadata --check` 4015/4015；`longnv-core` / `longnv-71` / `longnv-mechanism` / `menu-ui-71` PASS；命名审计、白名单审计与 `docs_audit` 879/0 全部通过。

### 7.2 回植完成（L3 已收口；待发布验证）

- **36-0 ~ 36-1**：完成 7.2 参考源码/场景/台账、年兽素材与数据、`xydxq` 描述迁移。
- **36-2 ~ 36-3**：完成年兽脚本/场景适配、档案与 HUD、2P 生成及 `pet-nian` / `LocalCoopPetNianProbe` 探针。
- **36-4**：接入 `nz_hlqg` 哪吒双火轮、`zz` 重斩觉醒、`xbz` 玄冰阵觉醒、`yt_ymw` 月魔舞三月影；`skill_awaken_popup` / `zd_skill` / `SkillDamageFormulaData` 覆盖四个新 ID；一阶觉醒石「tjs」与材料「ptjs」经 Catalog 校验。
- **36-5**：`Global` 接入年兽出战预载与空子弹场景保护；`GameAnnouncement` 增加 V7.2 文案/版本按钮；`dj_sell` 喜鹊双倍掉率支持叠加且上限 24 小时；`Transmogrified` 补充沙僧幻化项并聚合翅膀/头衔；`Role_8` 昵称标签上移；`addons/bone_export/export_plugin.gd` 按第三方插件边界不修改，`Script/Test` 仅作规格。
- **36-6 L3 收口**：`check_all --godot-bin` 9/9；`health_check --no-cache` **806 脚本 0/0/0**；`level_regression_all --jobs 12` **128/128 PASS + 5 SKIP**（370.18s，`level_ghg` 重试通过）；`scene_probe_runner` **26/26**；`coop_probe_runner` **38/38**；`archive_probe_runner` **344/344**；`level_1` 四阶段 **0/0/0**；`export_raw_manifest` 1033/1033、Atlas 4015/4015、编号帧/怪物帧/哪吒预览/FrameSequence/sheet 同步通过；`export_closure_probe --self-test` 修复 `normalize` 导入后通过；命名、白名单与 `docs_audit` 通过。
- **边界**：PCK/release 实际导出与目标设备 VRAM/首帧耗时未验证，按用户决策暂缓；`addons/bone_export` 的 7.2 导出根变化未移植；7.3 未立项。

### 7.3 回植（37-0~37-4 批次完成；L3 已通过）

- **目标二进制**：`八荒湮隳7.3.exe`，**2,282,485,752 字节**，SHA-256 `93817a09fd4508c7145631a67fe1cbcda9532028970d785b8ddda681009ef131`。
- **PCK**：`GDPC` v4，engine 4.7.0，raw offset `0x38D5C00`，`dir_offset` `0x84405870`；目录明文计数 **40,275**，加密目录 plaintext length **4,080,072**。
- **解密结果**：7.3 的目录与文件块均为标准 `FileAccessEncrypted`；目录/文件 key 由静态 SGXZ signer 与两组静态掩码 XOR 派生，不是旧版 `HBXZ` 固定 key/table。目录与全部 **40,275** 个文件块 MD5 校验通过。
- **参考工程**：已生成 **40,275** 个原始条目；**774/774** `.gdc` 反编译成功，**1,152/1,152** `.scn` 转文本成功；参考树与源码清单保存在仓库外。
- **台账初稿**：7.2→7.3 生产脚本 **49 个修改 + 1 个新增**（`Script/Data/WanLingJiejiaoData`），生产脚本删除 **0**；移除脚本 **216** 个全部位于测试/插件路径；缓存变化 **2**、构建场景变化 **3**、资产新增 **74** / 修改 **93**（多数为 `.ctex` 格式变化）。完整台账仍留在仓库外，等待逐项映射与语义复核。
- **37-1 数据/资产与截教接入**：JSON/BIN/Atlas/FrameSequence 的 1,028 条数据路径与 7.2 对比，生产内容无变化（仅 `uid_cache` 变化）；37 个上游新增 `.import`/`.ctex` 条目已复核：16 个八级宝石/精粹图标与 20 个截教魂晶图标进入运行期引用闭包（36/36 哈希、路径与引用通过）；另 `soul_crystal/1301.png` 为上游新增资产，当前无运行时消费者，按回植保真保留，不纳入运行期/PCK 闭包；未复制 `.ctex` 或旧 `.import`。装备构建源由 **1,089 → 1,127** 条定义：新增 16 个八级宝石、2 个天庭魂晶、20 个截教魂晶，三枚仙戒解除“不可神铸”；Catalog 已重新生成。新增 `WanLingJiejiaoData`；`BaseMonster` 接入截教噩梦属性倍率与魂晶掉落，`LevelInfo` 接入截教掉落预览、`Level_22` 天庭魂晶 72/73 预览；`PlayerData` 接入截教图录/魂晶计数/吞噬/属性汇总；`level_31` 冒烟通过。
- **37-2 完成**：NeZha/Yutu 重叠伤害与月舞碰撞掩码；`EastContinentMonster` 3120 传送前停止攻击、清理速度并修正当前 stage 屏幕边界；Level 47–62 的 `7_bsjh`、Level 63–75 的 `8_bsjh` 掉落/预览；`Level_64` 双 BOSS、`Level_65` 傲来国首领、`Level_63` 移除 `469000011` 等数据表差异已逐条合并。
- **37-3 完成**：`WanLingCatalogPage` 截教天境分栏与魂晶图标；`GameAnnouncement` V7.3 文案/版本按钮；`SHOP` 招财铃铛；三仙戒神铸解禁；装备分解返还累计强化石的 80%；8 级宝石配方与一键合成；`LevelProgressCommand` 写入天庭噩梦标记；`MonsterHeadInfo` 截教倍率/伤害/免伤与 `fixed_chance` 透传。`load_scene` 的 Android 首启完整性校验作为当前本地保护保留，未按 7.3 删除。
- **37-4 完成**：`BaseBuff` 的灵气/阵法/宠物加成/魔法汲取/初始 Buff 全部按 Buff 拥有者解析 `PlayerData`/`RoleProp`，移除英雄 Buff 图标写入全局 1P HUD 的旁路；`MonsterHeadInfo` 的公式与双倍掉落提示按怪物归属操作者解析；2P 相机居中/边界、灵气追踪最近玩家、P2 HUD 与操作者路径已由 `coop_probe_runner` **38/38** 收口。
- **验证**：`check_all --godot-bin` **9/9 PASS**；`health_check` **807 脚本 0 Parse / 0 Error / 0 Warning**；`archive_probe_runner` **344/344**；`scene_probe_runner` **26/26**（302.82s）；`level_regression_all` **128/128 PASS + 5 SKIP**（133 个场景，354.3s）；`coop_probe_runner` **38/38**（300.18s）；`level_1` 四阶段 0 ERROR / 0 WARNING；`level_47` / `level_63` / `level_65` / `level_75` 冒烟均 0 ERROR / 0 WARNING；截教数据/UI/配方/神铸/等级掉落与天庭噩梦进度运行时探针通过。新增资产运行期闭包 **36/36**；Atlas **4015/4015**、FrameSequence **288/288**、怪物帧 **152/152**、关卡预载 **101/101** 与导出清单自检通过。
- **37-1 收口**：资产引用闭包与 Atlas/FrameSequence/导出清单复核已完成。
- **边界**：未复制旧 `.ctex`/`.import`；`load_scene` Android 完整性保护保留；L3 已通过；PCK/release 与目标设备验证继续暂缓。

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
