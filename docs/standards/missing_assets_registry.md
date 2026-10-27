# 缺失资产登记与恢复台账 (Missing Assets Registry)

> **版本**：v1.0.0
>
> **目的**：把"资产缺失"从"命名白名单"中分离出来，逐条登记运行影响、恢复来源与实际状态。
>
> **本地恢复源**：原始二进制与首次解包目录由本地环境提供，路径不纳入版本控制；本文以 `<原始二进制>` / `<首次解包目录>` 占位。

---

## 0. 状态定义

| 状态 | 含义 |
|:---|:---|
| **待恢复** | 已确认可从本地原始二进制/首次解包数据恢复 |
| **可代码修复** | 原版不存在该资源，应修正代码引用或改用 atlas 帧 |
| **有回退** | 运行时已有替代路径，缺失不造成功能中断 |
| **已废弃** | 原版不存在且无使用价值，应清理引用 |
| **待评估** | 原版数据不完整或语义不明，需人工决策 |

---

## 1. 13 条缺失资源逐条登记

| # | 资源 | 引用点 | 运行影响 | 原版 PCK/解包 | 恢复来源 | 状态 |
|:--:|:---|:---|:---|:---:|:---|:---|
| 1 | `res://.godot/` | 数据目录 | 无 | — | Godot 自动生成 | 无需处理 |
| 2 | `res://godot/` | 数据目录 | 无 | — | Godot 自动生成 | 无需处理 |
| 3 | `Art/monster/guanyin_spine/`（Spine 源文件前缀） | `guanyin_summon.gd`、`guanyin_normal_attack_effect.gd`、`guanyin_skill2_effect.gd`、`guanyin_skill_a_effect.gd` | 已恢复：`skeleton` 配对 `loaded=true` | 导入缓存存在 | 源文件已反向恢复 | **已恢复**（§2） |
| 4 | `Art/hero_picture/role_2/bing_yu/runtime/` | `bing_yu_effect.gd` | 已恢复：`510040_attack_hit1` 配对 `loaded=true` | 缓存存在 | 源文件已反向恢复 | **已恢复**（§2） |
| 5 | `Art/hero_picture/role_4/cang_mu_long_yun/runtime/` | `cang_mu_long_yun_effect.gd` | 已恢复：`HeroF_6009_skill` 配对 `loaded=true` | 缓存存在 | 源文件已反向恢复 | **已恢复**（§2） |
| 6 | `Art/hero_picture/role_2/jhsj_awaken/runtime/` | `jhsj_awaken_effect.gd`、`hmz_awaken_effect.gd` | 已恢复：`01_2_1` / `08_1` 两个 skeleton 均 `loaded=true` | 缓存存在 | 源文件已反向恢复 | **已恢复**（§2） |
| 7 | `Art/hero_picture/role_2/lyfb_awaken/runtime/` | `lyfb_awaken_effect.gd` | 已恢复：代码使用的 `07-gray` / `07-red` 均 `loaded=true` | 缓存存在 | 源文件已反向恢复 | **已恢复**（§2） |
| 8 | `Art/monster/game_3_monster/three_prince/nezha/idle/1.png` | `monster_head_info.gd:6` 头像 fallback | 源帧已补齐（`ResourceLoader.exists=true`）；atlas 回退仍保留 | **原版无 `idle/` 目录**；atlas manifest `idle` 帧 | 从 `nezha/atlas/pages/atlas_009.png` 裁切（region 858,2,210,127；margin 119,99,160,173 → 489×399） | **已补齐（派生）** |
| 9 | `Art/monster/qiong_qi/effects/buff_green.png` | `qiong_qi_boss.gd:12,255`；`Global.gd:253` | 源帧已补齐（`ResourceLoader.exists=true`）；atlas 回退仍保留 | **原版 `QiongQi/Effects/` 目录不存在**；atlas `Effects` 序列 | 从 `qiong_qi/atlas/pages/atlas_000.png` 裁切（region 88,2,82,120；margin 21,5,50,12 → 153×137）；路径已规范化为 snake_case | **已补齐（派生）** |
| 10 | `Art/monster/qiong_qi/effects/buff_blue.png` | `qiong_qi_boss.gd:13,255`；`Global.gd:254` | 源帧已补齐（`ResourceLoader.exists=true`）；atlas 回退仍保留 | 同上 | 从 `qiong_qi/atlas/pages/atlas_000.png` 裁切（region 2,2,82,120；margin 21,5,50,12 → 153×137）；路径已规范化为 snake_case | **已补齐（派生）** |
| 11 | `Art/add_effect/buff_icon/mp_poision.png` | 已移除 `Global.gd:2026,2058` 两处预加载 | 无（`Global.gd:924-925` 回退逻辑保留） | 原版无该文件 | 无需恢复；白名单条目已清理 | **已清理** |
| 12 | `Art/ui_2_6_0_0/Level_sxmg/csm/csm.wav` | 已删除 `sxmg_csm.gd` | 无 | 原版无 | 废弃工具已删除，白名单条目已清理 | **已清理** |
| 13 | `Scene/level/Level_sxmg.tscn` | 已删除 `sxmg_csm.gd` | 无 | 原版无 | 废弃工具已删除，白名单条目已清理 | **已清理** |

### 1.1 可读文本回退登记（Readable Text Fallbacks）

以下资源在历史基线与导入缓存中均不可得，代码采用**可读文本回退**而非无关美术替代；
恢复源图后应移除对应文本回退并重新验证。

| # | 资源 | 代码位置 | 回退行为 | 恢复证据 | 状态 |
|:--:|:---|:---|:---|:---|:---|
| 14 | `Art/TwentyEightConstellations/42.png` | `Scene/other_scene/zhen_fa_ui.gd` `_refresh_use_button_icon` | Use 按钮显示“使用”，`icon = null` | 原 UID `uid://s0kne1rnj3c` 仅存在于场景/编辑器缓存；v1.2.0.1、v1.3.3.2、extracted/6.5.0.0 均无文件 | **有回退（文本）** |
| 15 | `Art/TwentyEightConstellations/43.png` | `Scene/other_scene/zhen_fa_ui.gd` `_refresh_use_button_icon` | Use 按钮显示“已装备”，`icon = null` | 同上；无可用 UID 映射 | **有回退（文本）** |
| 16 | `Art/backpack/all_items/lslztian.png` | `Scene/other_scene/zhenyanbutton.gd` `_physics_process` / `load_` | 阵眼按钮清空图标，显示“天” | 森罗阵·天；v1.2.0.1、v1.3.3.2、extracted/6.5.0.0 与导入缓存均无 PNG | **有回退（文本）** |
| 17 | `Art/backpack/all_items/lslzdi.png` | `Scene/other_scene/zhenyanbutton.gd` `_physics_process` / `load_` | 阵眼按钮清空图标，显示“地” | 森罗阵·地；同上 | **有回退（文本）** |
| 18 | `Art/backpack/all_items/ren.png` | `Scene/other_scene/zhenyanbutton.gd` `_physics_process` / `load_` | 阵眼按钮清空图标，显示“人” | 森罗阵·人；`renshen.png` 为不同物品（人参），不得替代 | **有回退（文本）** |

> **已修复（非回退）**：`Art/TwentyEightConstellations/{slz,lpz,tsz,tqz}.png` 的真实资源位于
> `Art/zhenfa/{senluozhen,luopozhen,tengshezhen,taiqingzhen}/`，已通过 `Global.ZHENFA_ICON_PATHS`
> 统一映射，不再属于缺失项。

> **补充发现（已处置）**：
> - `Art/magic_weapon/magic_weapon_xian_yujingping/160019.png`：原版缺失，但 `MonsterAtlasSequence` 回退
>   `HAS=true / TEX=true`；场景仅使用 `atlas/pages/*.png`。`160019.atlas` 与 `160019.skel.import`
>   零引用且加载会产生 3 条 ERROR，已删除 → **有回退（atlas manifest）**。
> - `GhostDoor_1.tpsheet`：源 `.tpsheet` 全工程 0 个，`.tpsheet.import` 为无效存根，已删除；
>   `GhostDoor_1.sprites/*.tres`（241 个 / 57KB）零路径引用但体积可忽略，保留 → **已清理**。
> - `Art/magic_weapon/guanyin_summon/source/`：与 `Art/monster/guanyin_spine/` 重复且零引用，
>   已整目录删除（2.1 MB）→ **已清理**。
> - `HeroF_5012_skill.spine-json`：零引用，`attackall` 解析失败，但代码使用 `07-gray/07-red`
>   变体（loaded=true），保留为原始资产 → **保留（未使用）**。

> **新发现（已处置）**：
> - `Art/magic_weapon/guanyin_summon/atlases/` + `manifest.json`：**27 MB**，旧版 Spine 3.8.55
>   逐帧透明烘焙方案（7 张图集 / 324 个 AtlasTexture regions），全工程零路径/UID/registry 引用；
>   当前运行时使用 `Art/monster/guanyin_spine/` 的 Spine 4.3 资源，无代码降级路径。
>   → **已删除**（Git 历史可恢复）。

---

## 2. Spine 缺陷专章（✅ 已恢复）

### 2.1 缺失范围

| 类型 | 数量 | 说明 |
|:---|:---:|:---|
| `.atlas` 源文件 | 12 | 仅剩 `.atlas.import` + png |
| `.spine-json` 源文件 | 14 | 仅剩 `.spine-json.import` |
| Spine 导入缓存（`.spatlas`/`.spjson`） | 26 | **首次解包数据全部存在** |
| `.tpsheet` 缓存 | 1 | `GhostDoor_1`，首次解包不存在 |

### 2.2 可恢复性（已实测）

- `.spatlas` 是 JSON 包装，`atlas_data` 字段包含**原始 Spine atlas 文本**；
  - 样本 `HeroF_5012_skill.atlas`：482 行 atlas 文本，首个页文件 `HeroF_5012_skill.png` 存在；
  - 12 个 atlas 中 **11 个页 png 存在**；`160019.png` 缺失，但 atlas manifest 回退可用（见 §1 补充）。
- `.spjson` 是**标准 Spine 4.3 JSON**（`skeleton/bones/slots/skins/animations`），可直接作为 `.spine-json` 源文件；
  - 14/14 全部存在，版本统一为 `4.3.00`。
- 自动映射：当前项目 26 个 `.atlas.import`/`.spine-json.import` 的 `path` 与首次解包
  `godot/imported/` 缓存 **26/26 一一对应**。

### 2.3 运行时前提：Spine GDExtension

| 项目 | 实测结论 |
|:---|:---|
| 目标版本 | Spine **4.3**（全部 `.spjson` 的 `skeleton.spine = 4.3.00`） |
| Godot 兼容 | 官方 4.3 分支 workflow 明确构建 **Godot 4.7.2-stable**；`.gdextension` `compatibility_minimum = "4.1"` |
| 下载 | `spine-godot-extension-4.3-4.7.2-stable.zip`（约 17.9 MB，HTTP 200 已验证） |
| 安装位置 | 解压后将 `bin/` 复制到 Godot 项目根：`source/bin/`（含 `spine_godot_extension.gdextension` + Windows x86_64 DLL） |
| 许可证 | **Spine Runtimes License**：每个最终用户需自行获得 Spine Editor 许可证；再分发必须附带许可证与版权声明 |

### 2.4 恢复执行记录（已完成）

- **GDExtension**：`spine-godot-extension-4.3-4.7.2-stable.zip`（SHA-256
  `1ab0512ccd26fb5bd1e2fb93305b1757e48f7eb88268c710b84cf9a26fbb8b15`）已安装到
  `source/bin/`（Windows x86_64：editor / template_debug / template_release），
  许可证文本随包提交；
- **源文件**：外部迁移脚本（未入库）反向恢复 **26/26**
  （12 `.atlas` + 14 `.spine-json`）；
- **导入存根**：删除 27 个 GDRE 旧 `.import` remap（UID 零引用，可安全重建）；
  Spine GDExtension 通过 ResourceFormatLoader 直接加载源文件，不再依赖
  `.godot/imported` 缓存；
- **运行时验证**（Godot 4.7.2 headless）：
  - `SpineSprite` / `SpineSkeletonDataResource` / `SpineAtlasResource` 均存在；
  - `bing_yu`、`cang_mu_long_yun`、`guanyin_spine`（5 组）、`jhsj_awaken`
    （2 个 skeleton）、`lyfb`（gray/red）全部 `loaded=true`；
  - 例外：`HeroF_5012_skill.spine-json` 主 skeleton 的 `attackall` 动画解析失败，
    **但代码实际使用 `07-gray` / `07-red` 变体**，不影响运行；
> **2026-10-27 复核/恢复记录**：`role_2/bing_yu/510040_attack_hit1`、`role_2/lyfb_awaken/HeroF_5012_skill`（含 gray/red）、`role_2/jhsj_awaken/HeroF_6030_skill01_2_1` 与 `skill08_1`、`role_4/cang_mu_long_yun/HeroF_6009_skill` 与 `skill01_2` 共 **8 个 `.spine-json` 缺少 `.import`**；已恢复导入配置并由 Godot 生成 `.spjson` 缓存，`ResourceLoader.load` **8/8 成功**，`BingYu`/`Lyfb`/`HMZ`/`JHSJ`/`CangMuLongYun` 的 `preload_effect_data` **5/5 true**。`guanyin_spine` 的 6 个 `.spine-json` 保持正常。私人仓提交 `297b5707`。本节“GDExtension 直接加载源文件”仍需 `.import` 才能稳定工作。

- **已处置（不阻塞）**：
  - `guanyin_summon/source/skeleton.skel`：所属 `source/` 目录零引用且与运行时资源重复，已删除；
  - `160019.skel` / `160019.atlas`：零引用且加载会产生 ERROR，已删除；
  - `160019.png`：页纹理原版缺失，但 atlas manifest 回退已验证
    （`HAS=true / TEX=true`），场景仅使用 `atlas/pages/*.png`；
  - `HeroF_5012_skill.spine-json`：零引用、主 skeleton 解析失败，保留为原始资产。

```text
1. 下载并解压 Spine 4.3 GDExtension（Godot 4.7.2-stable 版本）
2. 复制 bin/ 到 source/bin/
3. 恢复源文件（脚本化，dry-run 先验证）：
   遍历 source/**/{*.atlas.import,*.spine-json.import}
   - 源路径 = .import 路径去掉 .import
   - dest = .import 中 path="res://.godot/imported/<file>"
   - 从 <首次解包目录>/godot/imported/<file> 读取：
     * .spatlas -> json["atlas_data"] 写入源 .atlas（UTF-8）
     * .spjson  -> 原样写入源 .spine-json（UTF-8；保留标准 JSON）
4. 启动 Godot 编辑器 / --import：Spine 导入器重建 .spatlas/.spjson 缓存
5. 验证：
   - ClassDB.class_exists("SpineSprite") / "SpineSkeletonDataResource" 为 true
   - 技能触发（冰玉、苍木龙陨、画魂觉醒、灵翼锋芒、观音技能）日志 0 ERROR
   - .atlas/.spine-json 不再缺失，导入缓存与 .import dest_files 一致
```

> **注意**：只复制导入缓存而不安装扩展，Godot 会因缺少 `importer="spine.*"` 判定无效；
> 因此必须先安装扩展，再恢复源文件并重新导入。

### 2.5 验证清单

- [x] `spine_godot_extension.gdextension` 位于 `source/bin/`
- [x] 26 个 `.atlas`/`.spine-json` 源文件恢复完成（12 + 14）
- [x] Godot 4.7.2 headless 双轮 0 ERROR / 0 WARNING
- [x] 关键技能资源 `loaded=true`（bing_yu / cang_mu / guanyin / jhsj / lyfb gray+red）
- [x] `160019`（仙玉净瓶）：`160019.png` 经 atlas manifest 回退 `HAS/TEX=true`；`160019.atlas` / `.skel.import` 已删除，无需完整恢复

---

## 3. 高优先级资源预调研结论

| 资源 | 原版是否存在 | 结论 |
|:---|:---:|:---|
| `effects/buff_green.png` / `buff_blue.png` | **否**（`QiongQi/Effects/` 不存在） | 已从 `qiong_qi/atlas` 裁切补齐源帧；命名已规范化为 snake_case；白名单已清空 |
| `nezha/idle/1.png` | **否**（原版仅 `atlas/`、`effect_wind/`、`hurt/`） | 已从 `nezha/atlas` 裁切补齐源帧（489×399）；白名单已清空 |
| `mp_poision.png` | **否** | 已移除 `Global.gd` 两处预加载；`poision.png` 回退逻辑保留；白名单已清理 |
| `csm.wav` / `Level_sxmg.tscn` | **否** | 废弃工具 `sxmg_csm.tscn/.gd` 已删除；白名单已清理 |
| Spine 26 个源文件 | 缓存存在，源文件不在 pck | **已恢复**（§2，25 个实际可用 + 1 个未使用） |
| `160019.png` | **否** | **有回退（atlas manifest，`HAS/TEX=true`）**；`160019.atlas` / `.skel.import` 已删除 |

## 4. 恢复来源说明

| 来源 | 可用性 | 说明 |
|:---|:---:|:---|
| 原始二进制 PCK | ✅ | 39,833 条目，MD5 校验通过（17s）；含全部导入缓存与元数据 |
| 首次解包目录 | ✅ | 2.5 GB / 39,833 文件；含 16,812 `.ctex`、12 `.spatlas`、14 `.spjson`、127 `.mp3str` |
| Git 历史 | ❌ | 上述缺失文件从未入库（`git log --all -- <path>` 为空） |
| Spine 工程源文件 | ❌ | 未随项目提供；`.spatlas`/`.spjson` 可反向恢复 `.atlas`/`.spine-json` |

> 恢复脚本必须参数化输入/输出目录，禁止在仓库内硬编码本地私有路径。

---

## 5. 维护规则

1. 任何新增缺失资源必须登记本表，并标注状态（待恢复 / 可代码修复 / 有回退 / 已废弃 / 待评估）；
2. 恢复完成后更新状态，并在提交信息与变更说明中记录验证结果；
3. 本表与 `docs/standards/naming_whitelist.md` 分离：命名白名单只回答"是否改名"，本表回答"是否恢复/清理"；
4. 恢复/清理必须伴随 `godot --import`、实机冒烟与六维门禁复验。
