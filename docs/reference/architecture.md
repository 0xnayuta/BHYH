# 视觉资产架构契约 (Architecture)

> 状态：**活跃契约**。适用于当前 `source/` 工程及后续现代化改造。
> 本文定义资产生产、资源表示与运行时播放的边界；具体代码规范仍以 [`../standards/`](../standards/README.md) 为准。

---

## 1. 目的

本契约解决以下问题：

1. 明确 PNG、JSON、图集、Spine 与 SpriteFrames 的分层关系；
2. 规定新资产必须采用的构建方式与运行时类型；
3. 禁止继续扩散运行时路径拼接、目录扫描、JSON 解析和回退分支；
4. 为后续迁移提供统一的目标架构，而不是一次性大重构。

**统一的是构建契约、资源契约和调用契约，不是把所有内容强行塞进单一运行时格式。**

---

## 2. 核心决策

### 2.1 三层架构

| 层 | 职责 | 允许的产物 |
|:---|:---|:---|
| **构建层** | 把源素材转换为 Godot 资源；校验同步与过期 | 构建期生成的 `.tres`、`.import` 资源；转换器脚本 |
| **资源层** | 以强类型 `Resource` 表达动画、图集、骨骼与静态纹理 | `SpriteFrames`、`Texture2D`/`AtlasTexture`、`FrameSequence`、`AtlasMetadata`、Spine 资源 |
| **运行时层** | 用对应的 Godot 原生或受控第三方节点播放资源 | `AnimatedSprite2D`、`Sprite2D`/`TextureRect`、`SpineSprite`、流式帧播放器 |

三层之间只通过资源引用和明确 API 交互。运行时不得反向解析源文件，也不得根据目录猜测资源。

### 2.2 默认选型

| 内容类型 | 默认方案 | 运行时节点 |
|:---|:---|:---|
| 有限帧数的 2D 动画 | **构建期 `SpriteFrames.tres`** | `AnimatedSprite2D` |
| 静态图、UI、单张特效 | 直接 `Texture2D` / `AtlasTexture` | `Sprite2D`、`TextureRect` |
| 骨骼、皮肤、附件、网格变形 | **Spine** | `SpineSprite` |
| 实测会超出显存/加载预算的超大帧序列 | **`FrameSequence` + 流式播放器** | 专用流式帧播放器 |
| 图集帧数据源 | `AtlasMetadata.tres` | 由消费者转为 SpriteFrames 或 FrameSequence |

### 2.3 不允许的“统一”

- 不把 Spine 动画烘焙成 SpriteFrames；
- 不把静态 PNG/UI 强行包装成 SpriteFrames；
- 不把所有超大序列一次性装入 SpriteFrames；
- 不新增万能播放器，把帧动画、Spine、流式加载混在同一个类中；
- 不为了兼容旧资产同时保留两套加载路径。

---

## 3. 构建层契约

### 3.1 构建期生成

新增动画、图集帧与派生视觉资源必须在构建期生成，不允许在游戏运行时：

- 扫描目录；
- 猜测编号文件；
- 解析 `manifest.json`；
- 拼装 PNG 路径后逐帧 `load()`；
- 用 `SpriteFrames.new()` 现场构建有限帧动画。

构建产物可以是 `.tres` 或 Godot 导入后的原生资源；产物路径必须符合 [`../standards/naming_standard.md`](../standards/naming_standard.md)。

### 3.2 转换器职责

| 输入格式 | 工具 | 输出 |
|:---|:---|:---|
| 连续编号 PNG 序列 | `scripts/convert_numbered_frames.py` | `SpriteFrames.tres` |
| 哪吒 `preview_<layer>.json` + 图集 PNG | `scripts/convert_nezha_preview_frames.py` | 哪吒专用 `SpriteFrames.tres` |
| 图集 `manifest.json` | `scripts/convert_atlas_metadata.py` | `AtlasMetadata.tres` |
| Spine `.atlas` + `.spine-json` | Spine 运行时导入 | Spine 资源，不转换为 SpriteFrames |

转换器规则：

1. 通用输入格式使用通用工具；角色专用 schema 可以使用角色专用适配器；
2. 适配器名称必须反映其真实作用域，不允许把专用工具伪装成通用工具；
3. 转换器必须支持 `--check`，至少验证输出存在；能验证内容时必须验证内容一致性；
4. 转换器输出不进入公开仓库的内容边界不变：Art 派生资源由本地构建，脚本与契约入库；
5. 构建产物必须可重复生成，生成顺序和输入不得依赖运行时时序。

### 3.3 当前工具边界

- `convert_nezha_preview_frames.py` 是角色 6 专用适配器，只处理哪吒 `official_parts_trial` 的目录、三层 schema 与输出命名；
- `convert_numbered_frames.py` 是通用编号序列工具，当前登记 BiLuoTian 与 LeiTingJieZhen；
- 若未来第二个角色采用相同的哪吒预览 JSON schema，再把路径、层定义参数化并升级为通用工具；当前不预先抽象。

---

## 4. 资源层契约

### 4.1 强类型资源

新增静态数据必须使用自定义 `Resource` 或 Godot 原生强类型资源，并通过 `@export` 暴露：

- 不允许继续扩大无类型 `Dictionary` 配置；
- 条件字段、帧列表、路径表必须使用强类型字段；
- 固定依赖优先 `preload`；
- 大型资源允许按需加载，但必须缓存并支持显式预热/释放；
- 资源路径由资源字段或静态注册表提供，不在业务逻辑中重复拼接。

### 4.2 单一事实源

同一份动画/资源集合只能有一个生成源：

- 不允许 Manifest 与旧硬编码路径表并存；
- 不允许运行时构建与构建期 `.tres` 同时作为同一有限帧动画的正式来源；
- 不允许通过“文件不存在就回退旧路径”的方式保持旧行为；
- 清单缺失、路径缺失或类型不符必须明确失败，而不是静默降级。

### 4.3 资源类型

| 类型 | 用途 | 约束 |
|:---|:---|:---|
| `SpriteFrames` | 有限帧动画 | 默认使用；构建期生成；由 `AnimatedSprite2D` 播放 |
| `Texture2D` / `AtlasTexture` | 静态图、UI、图集页 | 不携带动画时间轴；由 `Sprite2D`/`TextureRect` 使用 |
| `FrameSequence` | 超大流式帧序列 | 目标资源类型；必须包含帧路径/区域、FPS、循环、末帧策略与预取策略 |
| `AtlasMetadata` | 图集页与帧元数据 | 构建期数据源；不是播放器；不得在运行时回写 |
| Spine 资源 | 骨骼/皮肤/网格动画 | 保持 Spine `.atlas`/`.spine-json` 与 `SpineSprite`；不转 SpriteFrames |

### 4.4 `AtlasMetadata` 的边界

`AtlasMetadata` 是项目自定义的构建期图集元数据，不是 Spine 的 `.atlas`：

- `manifest.json` → `AtlasMetadata.tres`；
- 运行时通过 `AtlasMetadataStore` 读取；
- 消费者可以选择：
  - 有限帧：构建期转为 `SpriteFrames`；
  - 超大帧：构建期生成 `FrameSequence`，运行时由流式播放器读取；
- 新增字段必须逐步使用强类型结构；现有 `data: Dictionary` 是遗留过渡，不得继续扩大无类型数据面。

---

## 5. 运行时层契约

### 5.1 默认播放器

- 有限帧动画：`AnimatedSprite2D` + `SpriteFrames`；
- 静态视觉：`Sprite2D` / `TextureRect` + `Texture2D`；
- 骨骼动画：`SpineSprite`；
- 超大序列：统一的流式帧播放器，消费 `FrameSequence`，不消费目录路径。

### 5.2 调用边界

- 业务代码不得在 `_process` / `_physics_process` 中执行磁盘 IO、运行时 JSON 解析或高频资源加载；
- 有限帧动画不得在首次释放技能时现场构建；
- 资源预热必须有明确的所有者和释放路径；
- 角色、怪物、特效的资源选择由 Manifest、Catalog 或 typed Resource 驱动；
- 如确需统一调用入口，使用工厂/适配器选择播放器，不把不同播放器合并成一个巨型节点。

### 5.3 Spine 边界

- Spine 是第三方骨骼运行时，不参与 SpriteFrames 统一；
- `.atlas` 由 Spine 运行时读取，`AtlasMetadata` 不替代 Spine atlas；
- Spine 二进制、许可证与平台支持必须单独维护；
- 当前仓库只入库 Windows x86_64 运行库；跨平台发布前必须补齐并验证。

---

## 6. 例外与禁止事项

### 6.1 合法例外

| 场景 | 处理 |
|:---|:---|
| 静态图像/UI | 直接 `Texture2D`，无需 SpriteFrames |
| 骨骼动画 | 保留 Spine，不转换 |
| 经实测超大、频繁复用的帧序列 | 使用 `FrameSequence` + 流式播放器，并记录显存/加载依据 |
| 舞台/关卡背景大图 | 直接纹理或 Streaming，不强制 SpriteFrames |

### 6.2 禁止事项

1. 新增运行时 `DirAccess` 扫描或编号文件猜测；
2. 新增运行时 `manifest.json` 解析；
3. 新增运行时 PNG 路径拼接与逐帧 `load()`；
4. 新增 Manifest 缺失回退、旧路径兼容层或“先看文件是否存在”的双轨逻辑；
5. 把 Spine 动画烘焙成 SpriteFrames；
6. 把静态 PNG 包装成无意义的 SpriteFrames；
7. 在全局逻辑中继续扩散角色专属资源路径表。

---

## 7. 迁移状态

### 7.1 已完成

- 角色 1~7 的运行资源清单与静态 Catalog；
- 哪吒 117 个装备层构建期 SpriteFrames；
- BiLuoTian cast/hit 与 LeiTingJieZhen formation/lightning 构建期 SpriteFrames；
- `convert_nezha_preview_frames.py --check` 内容级校验；
- `AtlasMetadata` 构建期转换与运行时只读加载。

### 7.2 待迁移

| 项目 | 目标 |
|:---|:---|
| `StreamedPngEffect` 的目录扫描 | 改为构建期 `FrameSequence`，运行时只读资源 |
| `sword_boss_base.gd` 等运行时建帧 | 有限帧改为构建期 SpriteFrames |
| 魔法武器运行时 `_build_frames()` | 有限帧改为构建期资源；超大帧走 FrameSequence |
| `AtlasMetadata.data` 无类型字典 | 逐步提供 typed accessor 或 typed 子资源 |
| Spine 平台库 | 按目标平台补齐并验证 |

### 7.3 迁移顺序

1. 先消除运行时目录扫描与 JSON 解析；
2. 再把有限帧运行时建帧迁移到构建期；
3. 再收敛 `AtlasMetadata` 的类型边界；
4. 最后处理平台与第三方运行库问题。

---

## 8. 验收要求

架构改动必须同时满足：

- `python scripts/check_all.py --godot-bin <godot>` 八维门禁通过；
- 构建期转换器的 `--check` 通过；
- Godot 场景加载与脚本编译保持 **0 ERROR / 0 WARNING**；
- 新增/重构资源具有唯一 UID、正确 `.import`（如适用）与 snake_case 路径；
- 受影响的角色/关卡冒烟或探针通过；
- 文档、脚本索引与状态记录同步更新。

---

## 9. 变更流程

1. 先修改本文与相关 `docs/standards/`；
2. 再修改转换器、资源与运行时；
3. 最后更新 `docs/reference/status.md` 的验证记录；
4. 禁止用新的兼容分支绕过本契约；
5. 若必须偏离本契约，必须记录原因、影响范围、退出计划，并经评审。

---

## 10. 关联文档

- [`status.md`](status.md)：版本、规模与验证状态单一事实源
- [`../standards/godot_design_standard.md`](../standards/godot_design_standard.md)：Resource、场景、Autoload 与项目结构规范
- [`../standards/spriteframes_generation_policy.md`](../standards/spriteframes_generation_policy.md)：SpriteFrames 生成策略
- [`../standards/naming_standard.md`](../standards/naming_standard.md)：命名契约
- [`../standards/missing_assets_registry.md`](../standards/missing_assets_registry.md)：缺失资产与回退登记
- [`../../scripts/README.md`](../../scripts/README.md)：构建、门禁与回归工具索引
