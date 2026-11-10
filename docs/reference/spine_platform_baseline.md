# Spine 运行时集成基线

> **职责**：记录 Spine GDExtension、资源格式、实际运行时加载路径和许可证事实。平台承诺及设备口径以 [`ADR-027`](../decisions/ADR-027-platform-commitment-and-verification-device.md) 为准；整体当前状态与未验证边界以 [`status.md`](status.md) 为准；验收判据见 [`acceptance.md`](acceptance.md)。本文不维护平台承诺矩阵、阶段进度或性能快照。

## 1. GDExtension 与库文件

- `source/bin/spine_godot_extension.gdextension` 的入口符号为 `spine_godot_library_init`；其配置声明 `compatibility_minimum = "4.1"`。该声明不是此工程实际构建版本或平台支持承诺。
- 工程采用 Spine 4.3 / Godot 4.7.2-stable 对应的 GDExtension 构建（版本决策见 [`ADR-010`](../decisions/ADR-010-spine-runtime-boundary.md)）。随工程提供 Windows x86_64 editor、debug 与 release 三种 DLL；其文件路径由 `.gdextension` 声明。
- `.gdextension` 中其它目标的路径声明本身不能证明对应二进制已入库或该平台可运行。具体平台承诺与验证口径只查 ADR-027 和 `status.md`；本文不从配置项推导支持范围。

## 2. Spine 资源格式与版本

- Spine 骨骼资源以 `.atlas` 与 `.spine-json` 交给 Spine GDExtension 的 `SpineSprite` 播放；不烘焙为 `SpriteFrames`，也不把 `AtlasMetadata` 用作 Spine atlas 的替代。资源版本由 `.spine-json` 内 `skeleton.spine` 声明，运行时与导出资产须匹配相应 Spine major/minor。
- 当前工程中可查证的活动资源示例 `source/Art/hero_picture/role_2/jhsj_awaken/runtime/HeroF_6030_skill08_1.spine-json` 声明 `4.3.00`。这只是该资源的版本证据，不据此推断所有素材目录中的 JSON 版本；更换运行时或恢复资源时应核对实际源文件声明。
- 旧 Spine 3.8 资源不在本基线的迁移范围内；不能仅凭扩展名假定它们可由 4.3 运行时读取。源 `.atlas` / `.spine-json`、GDExtension 与导入链路都是加载前提，不能只恢复 `.godot` 导入缓存。

## 3. 实际运行时加载路径

实现中的 Spine 效果先检查 `ClassDB` 中扩展类型是否可用，再加载 `.atlas` 与 `.spine-json`，创建 `SpineSkeletonDataResource`、设置两项资源并调用 `update_skeleton_data()`；例如 `bing_yu_effect.gd`、`lyfb_awaken_effect.gd` 会检查 `is_skeleton_data_loaded()`，成功后把数据交给 `SpineSprite.set_skeleton_data_res()`。只看到路径声明或源文件存在，不能替代运行时加载确认；探针和验收口径见 `acceptance.md`。

资源或扩展加载失败后的处理由具体效果拥有者决定，不能概括成统一的“无回退”或“静默回退”：`jhsj_awaken_effect.gd` 使用替代场景，`lyfb_awaken_effect.gd` 使用既有帧资源，`cang_mu_long_yun_effect.gd` 具有替代视觉路径；其它消费者可能拒绝创建对应视觉或结束效果。修改加载或回退路径时，应以相应效果脚本和验收探针为准。

## 4. 许可证与素材权利

- 运行时许可全文位于 [`source/bin/SPINE_RUNTIMES_LICENSE.txt`](../../source/bin/SPINE_RUNTIMES_LICENSE.txt)，第三方声明见 [`THIRD_PARTY_NOTICES.md`](../../THIRD_PARTY_NOTICES.md)。最终产品的每位用户都需自行持有 Spine Editor 许可证；以任何形式再分发产品时须附带运行时许可证与版权声明。
- Spine Runtimes License 不授予 skeleton、atlas、图片或音频等 Spine 素材的使用权；Spine 运行时和素材不因仓库根 MIT 许可证而获得额外授权。
