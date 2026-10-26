class_name FrameSequenceCatalog
extends Resource

## 构建期生成的帧序列索引；键是稳定 asset_id，不含播放策略。
@export var sequences: Dictionary[StringName, FrameSequence] = {}
