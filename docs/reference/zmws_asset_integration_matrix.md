# ZMWS Asset Integration Matrix

> 由 `scripts/asset_library_catalog.py` 生成；状态决策来自 `scripts/asset_library_policy.json`。
> 本文不表示玩法接入；资产仍只在 `BHYH-assets-private` 中。

## 生命周期

```text
source -> imported -> cataloged -> previewable -> selected -> wired -> gameplay_verified
```

生命周期小结：

- `source`：原始文件位于私有素材仓，尚未进入 BHYH 工程或 Godot 导入路径。
- `imported`：已进入 BHYH 工程并完成 Godot 导入；资源可被引擎发现和加载，但不表示已有消费方。
- `cataloged`：已由本脚本登记到矩阵与清单，明确所属域、数量和来源；登记不等同于运行时消费。
- `previewable`：已在工程内完成加载或预览（如地图渲染、碰撞预览），但未接入关卡触发器或玩法链路。
- `selected`：已选定具体资产作为接入目标，但尚未形成可运行的场景/脚本引用。
- `wired`：场景或脚本已有引用，运行时消费路径成立；尚未完成关卡/玩法验收。
- `gameplay_verified`：已有 wired 消费路径，并通过对应关卡/玩法验证；必须有验证证据，不能由导入或预览推断。

> 生命周期是概念顺序，不是自动状态机；当前矩阵只在域矩阵中使用其中若干状态，`gameplay_verified` 必须有实际关卡/玩法验证证据，不能由导入或预览推断。

## 状态说明

资产状态描述资产自身所处阶段；消费状态描述是否存在可追踪的消费路径与绑定。两列相互独立，不能把“有加载器”或“已导入”解读为已接入。

### 资产状态

| 值 | 中文说明 | 当前使用 |
|:---|:---|:---|
| `imported_unbound` | 资产已完成 Godot 导入并可被引擎发现/加载，但尚未被场景、脚本或运行时系统绑定为消费对象；不等于已接入玩法。 | 是 |
| `bound` | 资产已选定并绑定到明确消费方（场景、脚本或工厂）；绑定表示存在消费入口，不单独证明已完成关卡玩法验证。 | 是 |
| `excluded` | 资产被明确排除在导入、导出与运行时消费之外；不得据此推断资产可用。 | 是 |

### 消费状态

| 值 | 中文说明 | 当前使用 |
|:---|:---|:---|
| `unbound` | 没有针对本域资产的可追踪消费方或绑定；工程中面向其他资产的加载器不视为本域消费。 | 是 |
| `available_not_bound` | 工程中存在可用的通用加载器或消费入口，但尚未选定具体资产并建立绑定；只证明通道存在，不证明已接入。 | 是 |
| `previewable_not_gameplay_complete` | 资产可被加载/预览（如地图渲染与碰撞预览），但触发器、关卡流程和玩法验证尚未完成。 | 是 |
| `wired` | 已有场景或脚本引用该域资产，运行时消费路径成立；不等同于关卡玩法验收。 | 是 |
| `excluded` | 明确不导入、不导出，也不参与运行时消费。 | 是 |
| `gameplay_verified` | 已有 wired 消费路径，并通过对应关卡/玩法验证；当前矩阵尚无域达到，保留为后续目标状态。 | 否（保留值） |

### 其他状态

| 值 | 中文说明 | 当前使用 |
|:---|:---|:---|
| `loaded_no_errors_exit_0` | 垂直切片场景在 headless 下加载无错误且进程退出码为 0；只证明加载与资源解析，不证明触发器或玩法。 | 是 |
| `quarantined` | 资产被隔离，不导入、不导出且无运行时引用；需在来源、版本与用途确认后再评估。 | 是 |

> `imported_unbound` 表示资产停在导入阶段；`available_not_bound` 表示消费通道存在但尚未选定并绑定具体资产。两者同时出现仍不构成接入。

> 资产状态 `bound` 与消费状态 `wired` 可以同时出现：前者表示资产已选定并挂接，后者表示引用路径成立；二者都不等于 `gameplay_verified`。

## 域矩阵

| 域 | 数量 | 现有消费方 | 资产状态 | 消费状态 | 下一步 |
|:---|---:|:---|:---|:---|:---|
| `dragonbones` | 3629 | DragonBonesFactory + DragonBonesArmatureView | `imported_unbound` | `available_not_bound` | 选择一个怪物/特效并绑定单场景 |
| `maps` | 1727 | Scene/level/zmws; Parallax2D + StaticBody2D | `imported_unbound` | `previewable_not_gameplay_complete` | 预览单张地图；触发器与玩法仍待设计 |
| `spine` | 1371 | SpineSprite (existing 14 assets only) | `imported_unbound` | `unbound` | 等待明确的内容需求 |
| `bhyh.spine` | 14 | Existing BHYH SpineSprite effects | `bound` | `wired` |  |
| `backpack.all_items` | 11471 | Texture2D / load_item_icon | `imported_unbound` | `available_not_bound` |  |
| `skill.all_skills` | 747 | Texture2D / load() | `imported_unbound` | `available_not_bound` |  |
| `effect.all_effects` | 679 | Texture2D / load() | `imported_unbound` | `available_not_bound` |  |
| `ui.module_res` | 2546 | Texture2D / load() | `imported_unbound` | `available_not_bound` |  |
| `level.mapbase` | 5020 | Sprite2D / Parallax2D | `imported_unbound` | `available_not_bound` |  |
| `audio.sfx` | 589 | AudioStreamPlayer | `imported_unbound` | `available_not_bound` |  |
| `font.ttf` | 1 | FontFile | `imported_unbound` | `available_not_bound` |  |
| `config` | 320 | ZmwsConfig | `imported_unbound` | `available_not_bound` |  |
| `ui_audio_font` | 15443 | Texture2D, AudioStreamPlayer, FontFile loaders | `imported_unbound` | `available_not_bound` | 通过现有加载器绑定选中的 UI/音频资产 |
| `prefab_scripts` | 0 | none | `excluded` | `excluded` | 不导入 |

## 垂直切片

- 域：`maps`
- 场景：`res://Scene/level/zmws/activity_10years_commemorate.tscn`
- 状态：`loaded_no_errors_exit_0`
- 范围：map render/collision preview; not gameplay trigger validation

## 隔离项

- `tipOpen`：`quarantined`；missing version; no runtime references; not included

## 边界

- 逐项资产清单见 `docs/reports/zmws_asset_inventory.json`（生成物，按报告规则处理）。
- `imported_unbound` 不等于已接入；只有场景/脚本引用并通过关卡验证后才提升到 `gameplay_verified`。
- 资产库不复制第二份素材；BHYH 的 `source/Art` 通过 junction 读取私有素材仓。
