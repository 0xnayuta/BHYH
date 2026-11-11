## 7.4 启动加载页；在主加载流程前展示首帧进度。
## Android 签名校验仍由 load_scene 的既有内联流程执行，不新增 Autoload。
extends CanvasLayer

const LOADING_SCENE := "res://Scene/runtime/load_scene.tscn"
const STARTUP_TIMEOUT_MSEC := 60_000
## 普通线程加载没有进度回调；此阶段只占 0–10%，用有界时间估计填充进度条。
const PROGRESS_ESTIMATE_MSEC := 4000.0
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
	# 统一走资源运行时的普通线程加载，避免 4.7.2 load_threaded_request 的 LoadToken 泄漏。
	var runtime := Global.get_resource_runtime()
	var job_id := runtime.start_thread_load(LOADING_SCENE, "PackedScene", ResourceLoader.CACHE_MODE_REUSE)
	if job_id <= 0:
		percentage.text = "加载失败，请重新启动"
		return
	var started_msec := Time.get_ticks_msec()
	while is_inside_tree():
		if Time.get_ticks_msec() - started_msec > STARTUP_TIMEOUT_MSEC:
			runtime.retire_thread_load(job_id)
			percentage.text = "加载失败，请重新启动"
			return
		var status: int = runtime.get_thread_load_state(job_id)
		if status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			percentage.text = "加载失败，请重新启动"
			return
		var next_value := maxf(
			bar.value, minf(0.09, float(Time.get_ticks_msec() - started_msec) / PROGRESS_ESTIMATE_MSEC * 0.09)
		)
		if next_value != bar.value:
			bar.value = next_value
			percentage.text = "%d%%" % int(round(bar.value * 100.0))
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var scene := runtime.take_thread_load_resource(job_id) as PackedScene
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
