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
- 连续编号 PNG 序列由通用 `scripts/convert_numbered_frames.py` 生成构建期 SpriteFrames；当前登记 BiLuoTian cast/hit、LeiTingJieZhen formation/lightning 与 Wutai 3077 tornado（7 个唯一帧，每帧 duration 3.0 @ 30 FPS），运行时不再拼路径建帧；
- 固定/超大 PNG 目录、四剑阵 AtlasMetadata 技能序列、星座动态 body/技能序列与五台弹道非 swf 序列由 `scripts/convert_frame_sequences.py` 生成 `FrameSequence.tres` 与 Catalog；当前登记四剑台背景、星座治疗 aura、混沌、饕餮、流沙河、五台 3077 固定序列、四剑阵 hit1/hit2/hit3、星座 169 个 body 序列、星座技能 60 个序列（15 个目录 × 4 种 loop/hold 组合）与五台弹道非 swf 序列。

## 校验

- `scripts/convert_atlas_metadata.py --check` 校验 manifest/metadata 同步；
- `scripts/convert_atlas_metadata.py --self-test` 校验 `source_frames` 负向样本；
- `scripts/convert_nezha_preview_frames.py --check` 校验全部输出存在且内容一致（数量以预览源清单为准）；
- `scripts/convert_numbered_frames.py --all --check` 校验 BiLuoTian / LeiTingJieZhen / Wutai 3077 tornado 构建期帧存在且未过期；
- `scripts/convert_frame_sequences.py --check` 校验全部 455 个序列资源与 Catalog 内容一致；
- `png_stream_audit.py --fail-on-error` 校验未登记的 `StreamedPngEffect`。
