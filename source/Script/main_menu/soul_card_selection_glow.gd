## 7.4 魂卡选中描边。
extends NinePatchRect


func _draw() -> void:
	for spread in range(1, 13):
		var strength = 1.0 - float(spread - 1) / 12.0
		var glow := UiColorTokens.TEXT_GOLD_ORANGE
		glow.a = 0.75 * strength * strength
		draw_rect(Rect2(Vector2.ONE * -spread, size + Vector2.ONE * spread * 2), glow, false, 1.0)
	draw_rect(Rect2(Vector2.ONE * -1.5, size + Vector2.ONE * 3.0), UiColorTokens.TEXT_GOLD_PALE, false, 2.0)
