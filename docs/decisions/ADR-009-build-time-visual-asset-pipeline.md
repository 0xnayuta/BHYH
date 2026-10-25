# ADR-009：视觉资源构建期生成，运行时只读类型资源

- **状态**：Superseded by [ADR-020](ADR-020-typed-visual-assets-and-streaming-lifecycle.md)；原决策正文作为历史保留。
- **记录日期**：2026-10-25
- **影响范围**：动画、图集、特效、加载性能、构建工具

## 背景

历史实现中，运行时目录扫描、编号文件猜测、`manifest.json` 解析与 `SpriteFrames.new()` 现场建帧同时存在。它们导致加载抖动、错误被隐藏、资源类型混杂，并使构建产物与运行时行为不一致。

## 决策

1. 采用构建层 / 资源层 / 运行时层三层契约：
   - 构建层把源素材转换为 Godot 资源并校验；
   - 资源层使用 `SpriteFrames`、`Texture2D` / `AtlasTexture`、`AtlasMetadata`、Spine 资源；
   - 运行时只消费资源引用，不反向解析源文件；
2. 有限帧动画默认在构建期生成 `SpriteFrames.tres`；
3. 图集 `manifest.json` 构建期生成 `AtlasMetadata.tres`，运行时通过 `AtlasMetadataStore` 只读；
4. 转换器必须支持 `--check`，能验证内容时必须逐字/逐帧校验；
5. 禁止新增运行时目录扫描、编号猜测、manifest 解析、PNG 路径拼接与逐帧 `load()`；
6. 超大帧序列的目标方案是 `FrameSequence` + 流式播放器；当前 `StreamedPngEffect` 属于遗留实现，受 allowlist 限制，不新增使用；
7. 不为旧资产保留第二套加载路径。

## 后果

- 资源行为可重复、可审计，加载错误在构建期暴露；
- 构建流程增加转换器步骤，资源变更必须重新生成并 `--check`；
- 运行时性能更稳定，但需要维护转换器与资源清单；
- 现有 73 个运行时 `SpriteFrames.new()` 文件与 `StreamedPngEffect` 属于待迁移债务。

## 备选方案

| 方案 | 未采用原因 |
|:---|:---|
| 运行时现场建帧 | 加载抖动、错误延迟暴露、显存不可控 |
| 万能播放器统一帧/Spine/流式 | 巨型类，边界模糊，难测试 |
| 把所有 Spine 烘焙为帧 | 丢失骨骼/皮肤能力，资源体积膨胀 |

## 证据

- [`../reference/architecture.md`](../reference/architecture.md) §6
- [`../standards/spriteframes_generation_policy.md`](../standards/spriteframes_generation_policy.md)
- [`../../scripts/README.md`](../../scripts/README.md) §3.2、§3.4
- 提交 `dd86d0c`、`f0088da`、`1b4ef73`
