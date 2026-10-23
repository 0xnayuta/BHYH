# SpriteFrames 生成策略

## 默认规则

- `speed` 统一使用源素材 FPS（默认 24；30 FPS 源显式传 `--fps 30`）；
- `AnimationPlayer` 只负责状态切换和时长，不再额外叠加速度倍率；
- 循环动画命名：`wait`、`walk`、`idle`、`run`、`Monster*`；
- 一次性攻击/受伤/死亡/特效默认不循环；
- 特效如确需循环，必须在生成命令显式传 `--loop` 或 `--loop-all`；
- `SpriteFrames` 内部动画名、源序列名和 `--strip-prefix` 结果必须唯一；
- 新增静态资产优先使用构建期转换器生成，不允许运行时目录扫描；
- 当前仓库保留的构建期工具为 `scripts/convert_atlas_metadata.py`；图集 manifest / PNG 序列转换器按迁移任务引入，不进入日常工具链。

## 校验

- `scripts/convert_atlas_metadata.py --check` 校验 manifest/metadata 同步；
- `scripts/convert_atlas_metadata.py --self-test` 校验 `source_frames` 负向样本；
- `png_stream_audit.py --fail-on-error` 校验未登记的 `StreamedPngEffect`。
