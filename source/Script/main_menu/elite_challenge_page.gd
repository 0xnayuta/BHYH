## 7.4 精英副本挑战页；由 7.4 反编译参考按当前路径与 API 适配。
extends "res://Script/main_menu/soul_card_panel_base.gd"

const BOSS_STATS := preload("res://Script/level/elite_boss_stats.gd")
var PlayerData: PlayerDataStore:
	get:
		return LocalCoop.data_for(self) as PlayerDataStore
var boss_attributes: Dictionary = {}
var attributes: RichTextLabel
var selected_id := "qly"
var tier := 0
var boss_list: ItemList
var detail: RichTextLabel
var tier_select: OptionButton
var challenge_button: Button


func _ready() -> void:
	DATA.ensure(PlayerData.player_data)
	build_panel("精英副本 · 群王试炼")
	outer.add_child(label("独立挑战｜全屏索敌｜免疫控制｜首次通关获得对应魂卡", 17))
	var body = HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 18)
	outer.add_child(body)
	boss_list = ItemList.new()
	boss_list.name = "BossList"
	boss_list.custom_minimum_size = Vector2(300, 400)
	boss_list.fixed_icon_size = Vector2i(52, 52)
	boss_list.add_theme_constant_override("v_separation", 8)
	boss_list.item_selected.connect(func(index): select_boss(DATA.AVAILABLE_IDS[index]))
	body.add_child(boss_list)
	var right = VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(right)
	var controls = HBoxContainer.new()
	right.add_child(controls)
	controls.add_child(label("挑战难度："))
	tier_select = OptionButton.new()
	tier_select.name = "Difficulty"
	for value in DATA.TIERS:
		tier_select.add_item(value)
	tier_select.item_selected.connect(
		func(index):
			tier = index
			refresh_details()
	)
	controls.add_child(tier_select)
	attributes = detail_box(right)
	attributes.name = "BossAttributes"
	attributes.custom_minimum_size.y = 160
	attributes.size_flags_vertical = Control.SIZE_FILL
	detail = detail_box(right)
	challenge_button = button(right, "开始挑战", challenge)
	challenge_button.name = "StartChallenge"
	notice = label("首次通关必得对应魂卡，每次通关随机掉落5～12个碎片；25%概率掉落魂卡，已激活转换20碎片。", 17)
	outer.add_child(notice)
	var progress = DATA.ensure(PlayerData.player_data)
	for id in DATA.AVAILABLE_IDS:
		var cleared = int(progress.clears.get(id, -1))
		boss_list.add_item(
			"%s　%s" % [DATA.CARDS[id].name, DATA.TIERS[cleared] + "已通" if cleared >= 0 and cleared <= 2 else "未挑战"],
			load(DATA.portrait_path(id))
		)
	select_boss(selected_id)


func select_boss(id: String) -> void:
	selected_id = id
	boss_list.select(DATA.AVAILABLE_IDS.find(id))
	refresh_details()


func refresh_details() -> void:
	var card: Dictionary = DATA.CARDS[selected_id]
	refresh_attributes()
	detail.text = "[font_size=26][color=#f1cf81]%s · %s[/color][/font_size]\n\n" % [card.name, DATA.TIERS[tier]]
	detail.append_text("[color=#f1cf81]强化属性[/color]\n固定精英属性，攻击范围与索敌范围99999，免疫所有控制。\n\n")
	detail.append_text(
		(
			"[color=#f1cf81]专属机制[/color]\n%s\n%s\n\n"
			% [card.elite, ["保留原招式，追加专属强化招式。", "强化招式更密集；半血后进入二阶段。", "二阶段追加大招；原招特效先显现预警，可通过走位躲避。"][tier]]
		)
	)
	detail.append_text(
		"[color=#f1cf81]掉落奖励[/color]\n首次击败%s必得对应完整魂卡。\n每次通关随机掉落5～12个碎片；另有25%%概率掉落魂卡，已激活转换20碎片。\n\n" % [card.name]
	)
	detail.append_text("[color=#f1cf81]魂卡技能[/color]\n%s\n\n收藏属性常驻，装备后激活技能。" % card.skill)
	challenge_button.disabled = in_battle()


func challenge() -> void:
	if in_battle():
		notice.text = "请结束当前战斗后再进入。"
		return
	challenge_button.disabled = true
	Global.get_run_context().set_elite_challenge_selection({"card": selected_id, "tier": tier})
	DATA.persist(self)
	Global.change_scene("res://Scene/level/level_elite.tscn")


func refresh_attributes() -> void:
	boss_attributes = BOSS_STATS.preview(self, selected_id, tier)
	var attack_min = 9223372036854775807
	var attack_max = 0
	var attacks: PackedStringArray = []
	var index = 0
	for attack in boss_attributes.attacks.values():
		if not attack is Dictionary or not attack.has("power"):
			continue
		index += 1
		var value = int(attack.power)
		attack_min = mini(attack_min, value)
		attack_max = maxi(attack_max, value)
		attacks.append(
			(
				"招式%d：%d（%s）"
				% [
					index,
					value,
					{"physics": "物理", "magic": "魔法", "real": "真实"}.get(str(attack.get("attackKind", "")), "特殊")
				]
			)
		)
	attributes.text = (
		"[color=#f1cf81]怪物实际属性 · %s[/color]\n等级 %d　生命 %d\n攻击 %d～%d　命中 %d　暴击 %d　闪避 %d\n物防 %d　魔防 %d　物穿 %d　魔穿 %d\n伤害加成 %s%%　免伤 %s%%"
		% [
			"双人" if LocalCoop.is_enabled() else "单人",
			boss_attributes.level,
			boss_attributes.hp,
			0 if attack_min == 9223372036854775807 else attack_min,
			attack_max,
			boss_attributes.hit,
			boss_attributes.crit,
			boss_attributes.miss,
			boss_attributes.def,
			boss_attributes.mdef,
			boss_attributes.ar,
			boss_attributes.sp,
			str(snappedf(float(boss_attributes.damage_bonus) * 100.0, 0.1)),
			str(snappedf(float(boss_attributes.damage_reduction) * 100.0, 0.1))
		]
	)
	attributes.tooltip_text = "各原始招式攻击（未扣除玩家防御）：\n" + "\n".join(attacks)
