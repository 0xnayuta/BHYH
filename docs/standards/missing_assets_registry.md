# 缺失资产登记与恢复台账

> **定位**：登记当前仍影响工程的缺失资产和经评审的缺失资源回退。已解决的历史取证、解包过程与批次记录见 [`../archive/README.md`](../archive/README.md)，不在本页重复。
> **本地路径**：恢复目录由执行者在本地参数化提供；本页不记录私有路径、密钥或二进制位置。

## 1. 状态定义

| 状态 | 含义 |
|:---|:---|
| **待恢复** | 已确认可从合法来源恢复，但资源尚未补齐 |
| **可代码修复** | 原版不存在该资源，需要修正引用或采用已批准的数据来源 |
| **有回退** | 当前实现有经评审的替代路径；仅对已登记条目有效 |
| **已废弃** | 资源不存在或已无用途，引用应清理 |
| **待评估** | 来源、语义或运行影响尚未确认 |

## 2. 当前缺失与回退

### 2.1 有回退的图标

| 资源 | 代码位置 | 回退行为 | 状态 |
|:---|:---|:---|:---|
| `Art/TwentyEightConstellations/42.png` | `Script/skill/zhen_fa_ui.gd` | Use 按钮显示“使用”，无图标 | **有回退（文本）** |
| `Art/TwentyEightConstellations/43.png` | `Script/skill/zhen_fa_ui.gd` | Use 按钮显示“已装备”，无图标 | **有回退（文本）** |
| `Art/backpack/all_items/lslztian.png` | `Script/skill/zhenyanbutton.gd` | 阵眼按钮显示“天” | **有回退（文本）** |
| `Art/backpack/all_items/lslzdi.png` | `Script/skill/zhenyanbutton.gd` | 阵眼按钮显示“地” | **有回退（文本）** |
| `Art/backpack/all_items/ren.png` | `Script/skill/zhenyanbutton.gd` | 阵眼按钮显示“人”；`renshen.png` 是不同物品，不得替代 | **有回退（文本）** |

### 2.2 待评估资源

| 资源 | 引用点 | 运行影响 | 证据与处理条件 | 状态 |
|:---|:---|:---|:---|:---|
| `Art/monster/pet_tiger_boss/model/frames/stage1~4/r*_c*.png` | `pet_tiger_boss_base.gd` `_load_tiger_frame_texture` | 若启用 `monster_1501~1504`，白虎 Boss 帧可能不可见 | 当前素材工作区无源网格；预构建帧资源缺 `hit5`/`hit6`，不能替代；恢复素材或确认并移除无消费者场景后复核 | **待评估** |

## 3. 维护规则

1. 新发现的缺失资源必须登记运行影响、证据、恢复来源与状态。
2. 恢复或清理后记录最小结论和验证命令；完整批次证据归档。
3. 本台账回答恢复/清理；[`naming_whitelist.md`](naming_whitelist.md) 只登记命名例外。
4. 资源恢复/清理的导入、冒烟和门禁按 [`../reference/acceptance.md`](../reference/acceptance.md) 的变更矩阵执行，不在本页复制门禁清单。