## 7.4 启动加载页；在主加载流程前展示首帧进度。
## Android 签名校验仍由 load_scene 的既有内联流程执行，不新增 Autoload。
extends CanvasLayer

const LOADING_SCENE := "res://Scene/runtime/load_scene.tscn"
const TIPS := [
	"神秘商店中有概率出现强化石哦~~",
	"打不过关卡时，可以尝试回去强化装备。",
	"拾取装备时会自动判断背包是否已满。",
	"不同装备品质会用不同颜色显示。",
	"怪物攻击具有不同效果，请小心应对。",
	"宠物、技能和战斗资源会在进入存档时提前加载。",
]

@onready var bar: TextureProgressBar = $PanelContainer/loading_bar
@onready var percentage: Label = $PanelContainer/loading_bar/loading_text
@onready var tips: Label = $bg/Tips


func _ready() -> void:
	percentage.text = "0%"
	tips.text = "Tips: " + TIPS[randi_range(0, TIPS.size() - 1)]
	await RenderingServer.frame_post_draw
	if ResourceLoader.load_threaded_request(LOADING_SCENE, "PackedScene") != OK:
		percentage.text = "加载失败，请重新启动"
		return
	while is_inside_tree():
		var progress: Array = []
		var status := ResourceLoader.load_threaded_get_status(LOADING_SCENE, progress)
		if status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			percentage.text = "加载失败，请重新启动"
			return
		if not progress.is_empty():
			bar.value = maxf(bar.value, float(progress[0]) * 0.1)
			percentage.text = "%d%%" % int(round(bar.value * 100.0))
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var scene := ResourceLoader.load_threaded_get(LOADING_SCENE) as PackedScene
			if scene == null:
				percentage.text = "加载失败，请重新启动"
				return
			var loading := scene.instantiate()
			loading.set_meta("startup_progress", 0.1)
			get_tree().root.add_child(loading)
			get_tree().current_scene = loading
			queue_free()
			return
		await get_tree().process_frame
