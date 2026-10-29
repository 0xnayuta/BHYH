extends Control

## 显式操作者：按所在面板的槽位解析数据与属性，不依赖全局 1P/2P 视图交换。
var PlayerData: PlayerDataStore:
	get:
		return LocalCoop.data_for(self) as PlayerDataStore
var RoleProp: BaseRoleProperties:
	get:
		return LocalCoop.props_for(self) as BaseRoleProperties

@onready var skill_icon: TextureRect = $SkillIcon
@onready var skill_name_label: Label = $SkillName
var skill_id := ""


func _ready() -> void:
	$CloseButton.pressed.connect(_close)
	$ConfirmButton.pressed.connect(_on_confirm_pressed)
	$AwakenEnabled.toggled.connect(_on_awaken_enabled_toggled)
	$Status.text = "觉醒效果"
	$ConfirmButton.visible = true


func configure(skill_name: String, icon: Texture2D, internal_skill_id: String) -> void:
	skill_id = "jhsj" if internal_skill_id == "jhsj" or skill_name == "九环圣经" else internal_skill_id
	$SkillName.text = skill_name
	$SkillIcon.texture = icon
	_refresh_awaken_state()


func _refresh_awaken_state() -> void:
	if (
		skill_id != "jhsj"
		and skill_id != "smb"
		and skill_id != "zfjg"
		and skill_id != "tjgl"
		and skill_id != "nz_lblc"
		and skill_id != "nz_hlhs"
		and skill_id != "nz_yysj"
		and skill_id != "hmz_ws"
		and skill_id != "lyfb"
		and skill_id != "lys"
		and skill_id != "mds"
		and skill_id != "tkj"
		and skill_id != "wdzt"
		and skill_id != "mmw"
		and skill_id != "jdz"
		and skill_id != "wdww"
		and skill_id != "lhsq"
		and skill_id != "dgq"
		and skill_id != "sd"
		and skill_id != "zznh"
		and skill_id != "ltjz"
		and skill_id != "tllz"
		and skill_id != "fhf"
		and skill_id != "ygth"
		and skill_id != "yt_yl"
		and skill_id != "yt_xdz"
		and skill_id != "yt_mds"
		and skill_id != "yt_ldmw"
	):
		$EffectDescription.text = "当前技能的觉醒效果暂未开放"
		$Status.text = "觉醒效果"
		$ConfirmButton.visible = true
		$ConfirmButton.disabled = true
		$ConfirmButton.tooltip_text = "当前技能觉醒暂未开放"
		$AwakenEnabled.visible = false
		$AwakenEnabled.disabled = true
		$AwakenEnabled.button_pressed = false
		return
	var awakened := _is_skill_awakened(skill_id)
	$Status.text = "已觉醒" if awakened else "觉醒效果"
	var effect_description := ""
	if skill_id == "jhsj":
		effect_description = "额外召唤光柱攻击"
	elif skill_id == "smb":
		effect_description = "50%概率额外释放1次水魔爆\n20%概率额外释放2次水魔爆"
	elif skill_id == "zfjg":
		effect_description = "正法金刚召唤上限提升至5个"
	elif skill_id == "tjgl":
		effect_description = "护盾不被击破不会消失，且护盾存在期间免疫击退效果"
	elif skill_id == "nz_lblc":
		effect_description = "技能一直处于强化状态"
	elif skill_id == "nz_hlhs":
		effect_description = "生命低于70%时消耗能量回血；每存在1能量增加火莲化身等级×1%攻击力"
	elif skill_id == "nz_yysj":
		effect_description = "间隔降低至0.12秒且剑会上下浮动发射"
	elif skill_id == "hmz_ws":
		effect_description = "强化最后一击"
	elif skill_id == "lyfb":
		effect_description = "向周围释放烈刃造成高频伤害"
	elif skill_id == "lys":
		effect_description = "按住W+技能键可以向上冲刺"
	elif skill_id == "mds":
		effect_description = "猛毒素伤害不触发怪物白条"
	elif skill_id == "tkj":
		effect_description = "腾空击向前方冲刺；按住W+技能键往上冲刺"
	elif skill_id == "wdzt":
		effect_description = "可开关此技能，开启期间每5秒消耗一次蓝"
	elif skill_id == "mmw":
		effect_description = "回旋镖可以触发猛毒素且向身后额外释放一次回旋镖"
	elif skill_id == "jdz":
		effect_description = "剧毒阵时间存在期间会一直向周围释放旋风"
	elif skill_id == "wdww":
		effect_description = "可连接四个敌人"
	elif skill_id == "lhsq":
		effect_description = "每次命中敌人增加20%最大生命值和20%攻击，最多叠加五次，持续10秒"
	elif skill_id == "dgq":
		effect_description = "翻滚速度加快；翻滚期间从地滚球当前位置连续释放土魔刺尖刺，围绕自身旋转攻击"
	elif skill_id == "sd":
		effect_description = "自动开启圣盾技能；圣盾期间受到的控制效果持续时间减半；每5秒消耗一次蓝，蓝量不足自动关闭；再次使用可关闭"
	elif skill_id == "zznh":
		effect_description = "被战争怒吼吸取的敌人额外降低50%物理防御和魔法防御"
	elif skill_id == "ltjz":
		effect_description = "在距离最远的目标位置额外释放一个雷霆劫阵"
	elif skill_id == "tllz":
		effect_description = "命中敌人后降低50%物理防御和魔法防御，并在目标位置额外释放一个雷阵"
	elif skill_id == "fhf":
		effect_description = "大幅减少前摇、后摇和冷却，均缩短为原来的三分之一"
	elif skill_id == "ygth":
		effect_description = "跳过前段挥枪，直接连续释放三次巨型银钩；每次伤害为未觉醒银钩的三倍，冷却缩短至0.8秒"
	elif skill_id == "yt_yl":
		effect_description = "牵引全屏怪物（包括空中目标），每次伤害叠加2层月印"
	elif skill_id == "yt_xdz":
		effect_description = YutuSkillData.NEEDLE_AWAKEN_DESCRIPTION
	elif skill_id == "yt_mds":
		effect_description = YutuSkillData.POWDER_AWAKEN_DESCRIPTION
	elif skill_id == "yt_ldmw":
		effect_description = YutuSkillData.JAR_AWAKEN_DESCRIPTION
	$EffectDescription.text = effect_description + ("\n（已觉醒）" if awakened else "")
	$ConfirmButton.visible = not awakened
	$ConfirmButton.disabled = awakened
	$ConfirmButton.tooltip_text = "已觉醒" if awakened else "觉醒"
	$AwakenEnabled.visible = awakened
	$AwakenEnabled.disabled = not awakened
	$AwakenEnabled.button_pressed = _is_awaken_enabled(skill_id) if awakened else false


func _is_skill_awakened(internal_skill_id: String) -> bool:
	var awaken_data: Variant = PlayerData.player_data.get(DataKeys.Skill.AWAKENED, {})
	return awaken_data is Dictionary and bool(awaken_data.get(internal_skill_id, false))


func _is_awaken_enabled(internal_skill_id: String) -> bool:
	var enabled_data: Variant = PlayerData.player_data.get(DataKeys.Skill.AWAKENED_ENABLED, {})
	if not enabled_data is Dictionary:
		return true
	if not enabled_data.has(internal_skill_id):
		return true
	return bool(enabled_data.get(internal_skill_id, false))


func _close() -> void:
	queue_free()


## ESC 分层关闭：只关闭技能觉醒浮层。
func request_escape_close() -> bool:
	queue_free()
	return true


func _on_confirm_pressed() -> void:
	if (
		skill_id != "jhsj"
		and skill_id != "smb"
		and skill_id != "zfjg"
		and skill_id != "tjgl"
		and skill_id != "nz_lblc"
		and skill_id != "nz_hlhs"
		and skill_id != "nz_yysj"
		and skill_id != "hmz_ws"
		and skill_id != "lyfb"
		and skill_id != "lys"
		and skill_id != "mds"
		and skill_id != "tkj"
		and skill_id != "wdzt"
		and skill_id != "mmw"
		and skill_id != "jdz"
		and skill_id != "wdww"
		and skill_id != "lhsq"
		and skill_id != "dgq"
		and skill_id != "sd"
		and skill_id != "zznh"
		and skill_id != "ltjz"
		and skill_id != "tllz"
		and skill_id != "fhf"
		and skill_id != "ygth"
		and skill_id != "yt_yl"
		and skill_id != "yt_xdz"
		and skill_id != "yt_mds"
		and skill_id != "yt_ldmw"
	):
		Global.add_message_show(self, "当前技能觉醒暂未开启", 1.5, Vector2(470, 270))
		return
	if _is_skill_awakened(skill_id):
		return
	if PlayerData.count_item_amount("tjs") < 15:
		Global.add_message_show(self, "一阶觉醒石不足15个", 1.5, Vector2(470, 270))
		return
	if not PlayerData.awaken_skill(skill_id):
		Global.add_message_show(self, "存档保存失败：" + MemoryClass.describe_save_error(), 2.0, Vector2(470, 270))
		return
	_refresh_awaken_state()
	var skill_display_name := (
		"雷霆劫阵"
		if skill_id == "ltjz"
		else (
			"战争怒吼"
			if skill_id == "zznh"
			else (
				"万毒加护"
				if skill_id == "wdzt"
				else (
					"木魔舞"
					if skill_id == "mmw"
					else (
						"剧毒阵"
						if skill_id == "jdz"
						else (
							"地滚球"
							if skill_id == "dgq"
							else (
								"圣盾"
								if skill_id == "sd"
								else (
									"九环圣经"
									if skill_id == "jhsj"
									else (
										"水魔爆"
										if skill_id == "smb"
										else (
											"正法金刚"
											if skill_id == "zfjg"
											else (
												"六臂连刺"
												if skill_id == "nz_lblc"
												else (
													"阴阳神剑"
													if skill_id == "nz_yysj"
													else (
														"无双火魔斩"
														if skill_id == "hmz_ws"
														else (
															"烈焰风暴"
															if skill_id == "lyfb"
															else (
																"烈焰闪"
																if skill_id == "lys"
																else (
																	"猛毒素"
																	if skill_id == "mds"
																	else ("腾空击" if skill_id == "tkj" else ("火莲化身"))
																)
															)
														)
													)
												)
											)
										)
									)
								)
							)
						)
					)
				)
			)
		)
	)
	if skill_id == "tllz":
		skill_display_name = "天龙雷阵"
	elif skill_id == "fhf":
		skill_display_name = "翔龙闪"
	elif skill_id == "ygth":
		skill_display_name = "银钩铁画"
	elif skill_id == "wdww":
		skill_display_name = "巫毒娃娃"
	elif skill_id == "lhsq":
		skill_display_name = "灵魂摄取"
	elif skill_id == "tjgl":
		skill_display_name = "天降甘露"
	elif skill_id == "yt_yl":
		skill_display_name = "月轮"
	elif skill_id == "yt_xdz":
		skill_display_name = "玄毒针"
	elif skill_id == "yt_mds":
		skill_display_name = "蔓毒散"
	elif skill_id == "yt_ldmw":
		skill_display_name = "炼毒魔瓮"
	Global.add_message_show(self, skill_display_name + "觉醒成功", 1.5, Vector2(470, 270))


func _on_awaken_enabled_toggled(enabled: bool) -> void:
	if skill_id == "" or not _is_skill_awakened(skill_id):
		return
	var enabled_data: Dictionary = {}
	var enabled_value: Variant = PlayerData.player_data.get(DataKeys.Skill.AWAKENED_ENABLED, {})
	if enabled_value is Dictionary:
		enabled_data = enabled_value.duplicate(true)
	if not PlayerData.set_skill_awakened_enabled(skill_id, enabled):
		Global.add_message_show(self, "存档保存失败：" + MemoryClass.describe_save_error(), 2.0, Vector2(470, 270))
		_refresh_awaken_state()
