## 7.4 魂卡 Boss 原生特效载体；场景在 38-3 接入，按需加载并缓存。
extends RefCounted

const SCENE_PATHS := {
	"qly": "res://Scene/hero/elite_soul_card/qly.tscn",
	"sfe": "res://Scene/hero/elite_soul_card/sfe.tscn",
	"jls": "res://Scene/hero/elite_soul_card/jls.tscn",
	"nz": "res://Scene/hero/elite_soul_card/nz.tscn",
	"hwc": "res://Scene/hero/elite_soul_card/hwc.tscn",
	"bwc": "res://Scene/hero/elite_soul_card/bwc.tscn",
	"pg": "res://Scene/hero/elite_soul_card/pg.tscn",
	"ylw": "res://Scene/hero/elite_soul_card/ylw.tscn",
	"lw": "res://Scene/hero/elite_soul_card/lw.tscn",
	"jmw": "res://Scene/hero/elite_soul_card/jmw.tscn",
	"stw": "res://Scene/hero/elite_soul_card/stw.tscn",
	"pmw": "res://Scene/hero/elite_soul_card/pmw.tscn",
	"zztw": "res://Scene/hero/elite_soul_card/zztw.tscn",
	"gmtw": "res://Scene/hero/elite_soul_card/gmtw.tscn",
	"dwtw": "res://Scene/hero/elite_soul_card/dwtw.tscn",
	"cgtw": "res://Scene/hero/elite_soul_card/cgtw.tscn",
	"dwtw_reflect": "res://Scene/hero/elite_soul_card/dwtw_reflect.tscn",
	"shield": "res://Scene/hero/elite_soul_card/shield.tscn",
}

static var _scene_cache: Dictionary = {}


static func _scene_for(id: String) -> PackedScene:
	if not SCENE_PATHS.has(id):
		return null
	if not _scene_cache.has(id):
		_scene_cache[id] = load(SCENE_PATHS[id]) as PackedScene
	return _scene_cache[id]


static func create(id: String, persistent: bool = false) -> Node2D:
	var scene: PackedScene = _scene_for(id)
	assert(scene != null, "Unknown or missing original Boss effect: " + id)
	if scene == null:
		return null
	var effect: Node2D = scene.instantiate()
	effect.name = "NativeBossEffect"
	effect.set_meta("skill_effect", true)
	effect.set_meta("boss_card_id", id)
	effect.scale.x *= float(effect.get_meta("native_forward", -1.0))
	var player = effect.get_node_or_null("NativeAnimation") as AnimationPlayer
	if persistent and player != null:
		var library = AnimationLibrary.new()
		var animation = player.get_animation("effect").duplicate() as Animation
		animation.loop_mode = Animation.LOOP_LINEAR
		library.add_animation("effect", animation)
		player.remove_animation_library("")
		player.add_animation_library("", library)
	return effect
