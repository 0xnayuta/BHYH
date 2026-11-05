class_name UiTextFormat
extends RefCounted

## 物品提示文本的显示层格式：统一中文冒号、段落首行缩进与价格结尾。

const COLON := "："
const PARAGRAPH_INDENT := "　　"


static func stat_line(key: String, value: Variant) -> String:
	return "%s%s%s" % [key, COLON, str(value)]


static func description(raw: String) -> String:
	var paragraphs := raw.strip_edges().split("\n", true)
	for index in paragraphs.size():
		if not paragraphs[index].is_empty():
			paragraphs[index] = PARAGRAPH_INDENT + paragraphs[index]
	return "\n".join(paragraphs)


static func price(value: Variant) -> String:
	return "售价%s%s灵魂" % [COLON, str(value)]
