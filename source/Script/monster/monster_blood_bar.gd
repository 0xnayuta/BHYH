extends Node2D
class_name MrBloodBar
@onready var blood_bar: TextureProgressBar = $blood_bar
@onready var blood_text: Label = $blood_bar/blood_text
@onready var queue_free_timer: Timer = $queue_free_Timer
@onready var blood_bar_2: TextureProgressBar = $blood_bar/blood_bar2

var bar_value: float
var bar_text: int
var can_show: bool
var _last_applied_bar_value := INF
var blood:
	set(va):
		blood = va
		on_hp_change(blood)


func _ready() -> void:
	if not MainSet.set_data["MonsterLittleBlood"] or not MainSet.set_data["NoShowMonsterBody"]:
		self.queue_free()


func _physics_process(_delta: float) -> void:
	if bar_text <= 0:
		bar_text = 0
	if can_show == false:
		if not queue_free_timer.is_stopped():
			queue_free_timer.stop()
		if self.modulate != Color.WHITE:
			self.modulate = Color.WHITE
	if not is_equal_approx(_last_applied_bar_value, bar_value):
		blood_bar.value = bar_value
		blood = bar_value
		_last_applied_bar_value = bar_value
	if blood_text.text != "":
		blood_text.text = ""


func _on_timer_timeout() -> void:
	var tween = create_tween()
	tween.stop()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 2)
	await tween.finished
	queue_free()


func on_hp_change(vale):
	if not MainSet.set_data["HpBarDelay"]:
		$blood_bar/blood_bar2.value = 0
		return
	var tween = create_tween()
	tween.stop()
	tween.tween_property($blood_bar/blood_bar2, "value", vale, 0.5)
