# SpriteFrames 生成策略

> 本文规定 SpriteFrames 生成、命名与播放时序；资源类型选型、共享/实例状态、加载生命周期与发布边界见 [`target_architecture_contract.md` §7](target_architecture_contract.md#7-资源与视觉资产子契约)。当前转换器和具体输出由 [`scripts/README.md`](../../scripts/README.md) 维护；门禁判据与验收档位见 [`../reference/acceptance.md`](../reference/acceptance.md)。并非所有视觉内容都应转为 SpriteFrames。

## 生成规则

- 固定或静态帧序列应由构建期工具生成 SpriteFrames 资源；运行时不得扫描目录、猜编号或拼接静态序列路径来重建动画。
- 每个动画资源必须声明唯一正式来源与所用帧序列；缺帧或缺动画不得静默替换为其他来源或单图。合法静态保持必须显式声明。
- `speed` 使用源素材 FPS，默认 24 FPS；30 FPS 源必须显式设置 `--fps 30`。
- 逐帧 `duration` 是相对时长，绝对帧时长为 `duration / (speed × playing_speed)`。不得把绝对秒数写入 `duration` 后再叠加 `speed`，否则速度会被重复放大。
- 配合 `AnimatedSprite2D` 时，`AnimationPlayer` 可编排状态、属性、事件与时长，但不得重复驱动同一帧播放时钟或额外叠加速度倍率。
- 循环动画使用 `wait`、`walk`、`idle`、`run`、`Monster*` 等约定名称；攻击、受伤、死亡与特效默认不循环。特效确需循环时，必须在生成定义中显式声明。
- `SpriteFrames` 内部动画名、源序列名及去除前缀后的名称必须唯一；名称冲突必须失败，不能静默覆盖或改名消解。
- 运行时 `SpriteFrames.new()` 仅允许 [`runtime_frames_exceptions.md`](../reference/runtime_frames_exceptions.md) 和机器 allowlist 登记的有限例外；新增例外须经评审并满足该页准入规则。
- 确定性输出、资源身份、陈旧输出清理和生成内容校验遵循 [`target_architecture_contract.md` §7.2](target_architecture_contract.md#7-资源与视觉资产子契约)；具体源格式及转换器职责以 [`scripts/README.md`](../../scripts/README.md) 为准。

## 验收

生成器的校验必须覆盖源数据/schema、帧次序与内容、duration、循环/速度、资源身份及必要的发布依赖闭包，不能只检查输出文件存在。对受影响转换器执行 `--check`、必要的负向样本以及受影响消费者的运行期验收；实际脚本、参数、门禁接入与验收档位以 [`../reference/acceptance.md`](../reference/acceptance.md) 和 [`scripts/README.md`](../../scripts/README.md) 为准。源资源检查通过不等于导出包闭包或目标平台已验收。
