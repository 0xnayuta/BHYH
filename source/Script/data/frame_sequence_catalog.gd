class_name FrameSequenceCatalog
extends Resource

## 构建期生成的帧序列索引；键由 FrameSequenceStore.key_for() 生成。
@export var sequences: Dictionary[StringName, FrameSequence] = {}
