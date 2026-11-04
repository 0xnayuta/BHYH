# ZMWS Asset Integration Matrix

> 由 `scripts/asset_library_catalog.py` 生成；状态决策来自 `scripts/asset_library_policy.json`。
> 本文不表示玩法接入；资产仍只在 `BHYH-assets-private` 中。

## 生命周期

```text
source -> imported -> cataloged -> previewable -> selected -> wired -> gameplay_verified
```

## 域矩阵

| 域 | 数量 | 现有消费方 | 资产状态 | 消费状态 | 下一步 |
|:---|---:|:---|:---|:---|:---|
| `dragonbones` | 3629 | DragonBonesFactory + DragonBonesArmatureView | `imported_unbound` | `available_not_bound` | 选择一个怪物/特效并绑定单场景 |
| `maps` | 1727 | Scene/level/zmws; Parallax2D + StaticBody2D | `imported_unbound` | `previewable_not_gameplay_complete` | 预览单张地图；触发器与玩法仍待设计 |
| `spine` | 1371 | SpineSprite (existing 14 assets only) | `imported_unbound` | `unbound` | 等待明确的内容需求 |
| `bhyh.spine` | 14 | Existing BHYH SpineSprite effects | `bound` | `wired` |  |
| `backpack.all_items` | 11401 | Texture2D / load_item_icon | `imported_unbound` | `available_not_bound` |  |
| `skill.all_skills` | 747 | Texture2D / load() | `imported_unbound` | `available_not_bound` |  |
| `effect.all_effects` | 679 | Texture2D / load() | `imported_unbound` | `available_not_bound` |  |
| `ui.module_res` | 2546 | Texture2D / load() | `imported_unbound` | `available_not_bound` |  |
| `level.mapbase` | 5020 | Sprite2D / Parallax2D | `imported_unbound` | `available_not_bound` |  |
| `audio.sfx` | 589 | AudioStreamPlayer | `imported_unbound` | `available_not_bound` |  |
| `font.ttf` | 1 | FontFile | `imported_unbound` | `available_not_bound` |  |
| `config` | 320 | ZmwsConfig | `imported_unbound` | `available_not_bound` |  |
| `ui_audio_font` | 15373 | Texture2D, AudioStreamPlayer, FontFile loaders | `imported_unbound` | `available_not_bound` | 通过现有加载器绑定选中的 UI/音频资产 |
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
- `imported_unbound` 不等于已接入；只有场景/脚本引用并通过关卡验证后才提升状态。
- 资产库不复制第二份素材；BHYH 的 `source/Art` 通过 junction 读取私有素材仓。
