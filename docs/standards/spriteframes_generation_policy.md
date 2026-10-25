# SpriteFrames 生成策略

## 默认规则

- `speed` 统一使用源素材 FPS（默认 24；30 FPS 源显式传 `--fps 30`）；
- `AnimationPlayer` 只负责状态切换和时长，不再额外叠加速度倍率；
- 循环动画命名：`wait`、`walk`、`idle`、`run`、`Monster*`；
- 一次性攻击/受伤/死亡/特效默认不循环；
- 特效如确需循环，必须在生成命令显式传 `--loop` 或 `--loop-all`；
- `SpriteFrames` 内部动画名、源序列名和 `--strip-prefix` 结果必须唯一；
- 新增静态资产优先使用构建期转换器生成，不允许运行时目录扫描；
- 当前仓库保留的构建期工具为 `scripts/convert_atlas_metadata.py`；哪吒官方部件预览帧由 `scripts/convert_nezha_preview_frames.py` 转为构建期 SpriteFrames `.tres`，运行时只加载 `.tres`，不再解析 `preview_*.json`；
- 连续编号 PNG 序列由通用 `scripts/convert_numbered_frames.py` 生成构建期 SpriteFrames；当前登记 BiLuoTian cast/hit 与 LeiTingJieZhen formation/lightning，运行时不再拼路径建帧。

## 校验

- `scripts/convert_atlas_metadata.py --check` 校验 manifest/metadata 同步；
- `scripts/convert_atlas_metadata.py --self-test` 校验 `source_frames` 负向样本；
- `scripts/convert_nezha_preview_frames.py --check` 校验全部输出存在且内容一致（数量以预览源清单为准）；
- `scripts/convert_numbered_frames.py --all --check` 校验 BiLuoTian / LeiTingJieZhen 构建期帧存在且未过期；
- `png_stream_audit.py --fail-on-error` 校验未登记的 `StreamedPngEffect`。
