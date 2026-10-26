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
- 固定/按需驻留序列由 `scripts/convert_frame_sequences.py` 生成 FrameSequence、Catalog、确定性 UID 与独立发布依赖清单；构建定义显式选择图集、原始帧或静态保持来源，不在缺失时自动替代。数量以转换器检查输出和状态快照为准。

## 校验

- `scripts/convert_atlas_metadata.py --check` 校验 manifest/metadata 同步；
- `scripts/convert_atlas_metadata.py --self-test` 校验 `source_frames` 负向样本；
- `scripts/convert_nezha_preview_frames.py --check` 校验全部输出存在且内容一致（数量以预览源清单为准）；
- `scripts/convert_numbered_frames.py --all --check` 校验 BiLuoTian / LeiTingJieZhen / Wutai 3077 tornado 构建期帧存在且未过期；
- `scripts/convert_monster_frames.py --check` 校验怪物 `AtlasMetadata.sequences` 与既有 `*_frames.tres` 的动画名集合、帧数与 `region`/`margin`、页路径闭包、确定性 UID 唯一性；`--all` 按 `scripts/monster_action_maps.json` 追加动作别名（共享原 `AtlasTexture` 子资源）并修正 loop，`--rewrite` 只补 UID 头；已接入 `contract_gate`；
- 怪物消费者直接 `load` 帧资源，不再运行时 `SpriteFrames.new()` 重建动画；动作名以 `monster_action_maps.json` 为构建期契约，资源中必须同时存在 sequence 名与动作别名；
- `scripts/convert_frame_sequences.py --check` 校验内容、schema、UID、Catalog 与延迟纹理路径闭包；已接入 `contract_gate`；
- `scripts/convert_frame_sequences.py --export-preset [NAME]` 只读检查实际导出预设；缺预设明确失败，配置通过不等于导出包通过；
- `png_stream_audit.py --fail-on-error` 限制未登记使用，并拦截已迁移消费者恢复旧字段、目录扫描或编号探测。
