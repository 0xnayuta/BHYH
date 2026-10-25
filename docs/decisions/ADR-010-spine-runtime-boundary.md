# ADR-010：Spine 保持骨骼运行时，不烘焙为 SpriteFrames

- **状态**：Accepted
- **记录日期**：2026-10-25
- **影响范围**：角色特效、Boss 特效、平台库、许可证

## 背景

工程包含 Spine 骨骼动画资源（角色技能、Boss 特效等），需要皮肤、附件、网格变形与动画混合能力。曾经存在将 Spine 逐帧烘焙为图集的旧方案，资源体积大且丢失骨骼能力。

## 决策

1. Spine 资源保持 `.atlas` / `.spine-json`，由 Spine GDExtension 的 `SpineSprite` 播放；
2. 不把 Spine 动画烘焙为 `SpriteFrames`，也不把 `AtlasMetadata` 当作 Spine atlas 的替代；
3. 当前入库 Spine 运行时为 **4.3 / Godot 4.7.2-stable / Windows x86_64**；
4. 跨平台发布前必须补齐对应平台库并验证；
5. Spine 运行时与素材分别遵循 Spine Runtimes License；素材权利不随代码许可证授予；
6. 源文件恢复、GDExtension 安装与 `loaded` 探针属于运行前提，不得只复制导入缓存。

## 后果

- 保留骨骼动画表现力与资源复用能力；
- 当前公开/可运行平台受 Windows x86_64 限制；
- 发布包必须附带许可证与版权声明；
- Spine 资源加载失败会直接表现为技能/特效缺失，必须通过运行时探针验证。

## 备选方案

| 方案 | 未采用原因 |
|:---|:---|
| 烘焙为 SpriteFrames | 丢失骨骼/皮肤/混合能力，资源体积膨胀 |
| 用 Godot 原生 AnimationPlayer 重做 | 重制成本高，视觉一致性风险大 |
| 只保留静态图 | 丢失动画表现，不可接受 |

## 证据

- [`../reference/architecture.md`](../reference/architecture.md) §6.2、§6.3
- [`../standards/missing_assets_registry.md`](../standards/missing_assets_registry.md) §2
- [`../../THIRD_PARTY_NOTICES.md`](../../THIRD_PARTY_NOTICES.md) Spine Runtimes
- [`../../.gitignore`](../../.gitignore) §7
