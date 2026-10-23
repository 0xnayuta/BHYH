extends TextureRect

var need_number: int
var type: String
var is_crit: bool
var is_set = false
var target: BaseObject


func _physics_process(_delta: float) -> void:
	changepic(type, need_number, is_crit)
	set_physics_process(false)


func changepic(Type_: String, num: int, _crit: bool):
	if num == null:
		self.set_texture(null)
		return

	var is_target_valid = target != null and is_instance_valid(target)

	if Type_ == "cure":
		self.set_texture(
			Global.get_cached_texture(
				"res://Art/all_number/" + str(Type_) + "/" + str(Type_) + "_" + str(int(num)) + ".png"
			)
		)
		return
	if Type_ == "CureMp":
		self.set_texture(Global.get_cached_texture("res://Art/all_number/cure_mp/cure_mp_" + str(int(num)) + ".png"))
		return
	if Type_ == "ReduceMp":
		self.set_texture(
			Global.get_cached_texture("res://Art/all_number/reduce_mp/reduce_mp_" + str(int(num)) + ".png")
		)
		return

	if is_target_valid:
		if target is BaseHero:
			if Type_ != "real":
				self.set_texture(
					Global.get_cached_texture(
						"res://Art/all_number/monster/" + str(Type_) + "/" + str(Type_) + "_" + str(int(num)) + ".png"
					)
				)
			else:
				self.set_texture(
					Global.get_cached_texture(
						"res://Art/all_number/" + str(Type_) + "/" + str(Type_) + "_" + str(int(num)) + ".png"
					)
				)
		elif target is BaseMonster or target is SummonBaseMonster:
			if is_crit:
				var tt = Type_ + "crit"
				self.set_texture(
					Global.get_cached_texture(
						"res://Art/all_number/" + str(tt) + "/" + str(type) + "_" + str(int(num)) + ".png"
					)
				)
			else:
				if type == "physics":
					self.set_texture(
						Global.get_cached_texture(
							"res://Art/all_number/magic/" + str(Type_) + "_" + str(int(num)) + ".png"
						)
					)
				else:
					self.set_texture(
						Global.get_cached_texture(
							"res://Art/all_number/" + str(Type_) + "/" + str(Type_) + "_" + str(int(num)) + ".png"
						)
					)
	else:
		if is_crit:
			var tt = Type_ + "crit"
			self.set_texture(
				Global.get_cached_texture(
					"res://Art/all_number/" + str(tt) + "/" + str(Type_) + "_" + str(int(num)) + ".png"
				)
			)
		else:
			if type == "physics":
				self.set_texture(
					Global.get_cached_texture("res://Art/all_number/magic/" + str(Type_) + "_" + str(int(num)) + ".png")
				)
			else:
				self.set_texture(
					Global.get_cached_texture(
						"res://Art/all_number/" + str(Type_) + "/" + str(Type_) + "_" + str(int(num)) + ".png"
					)
				)
