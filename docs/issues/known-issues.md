# 已知问题与待验证风险

> 本页只记录尚未解决的问题与待验证风险；阶段完成状态见 [`../roadmap/roadmap.md`](../roadmap/roadmap.md)，验收判据见 [`../reference/acceptance.md`](../reference/acceptance.md)。

## `Object.get_meta(name, null)` 的缺失键路径会产生 ERROR

Godot 4.7 的 [`Object.get_meta`](https://docs.godotengine.org/en/4.7/classes/class_object.html#class-object-method-get-meta) 在键不存在且默认值为 `null` 时返回默认值，同时记录 error。需要将“键可能不存在”作为正常情况处理时，先调用 `has_meta()`，再无默认值读取；或传入语义正确的非 `null` 默认值。

源码检索在以下文件中找到 `get_meta(..., null)` 调用。检索结果不证明这些键在运行时缺失，也不证明每条调用均可达；逐点风险尚未完成复核。

- `source/Script/base/base_buff.gd`
- `source/Script/base/base_magic_weapon.gd`
- `source/Script/base/base_monster.gd`
- `source/Script/magic_weapon/eight_immortal_magic_weapon.gd`
- `source/Script/monster/constellation_boss.gd`
- `source/Script/monster/monster_bullet.gd`
- `source/Script/pet/pet_mouse_bullet.gd`
- `source/Script/pet/pet_neat_bullet.gd`
- `source/Script/pet/pet_rabbit_bullet.gd`
- `source/Script/pet/pet_turtle_bullet.gd`
- `source/Script/pet/pet_yin_tiger_bullet.gd`

`pet_turtle_summon_base.gd` 的同心链接读取已先检查 `has_meta()`，可作为已修复实例；这不改变本页列出的其它调用点范围。源码见 [`pet_turtle_summon_base.gd`](../../source/Script/pet/pet_turtle_summon_base.gd)。

### 处置与验收

1. 逐调用点确认缺失键是否为合法状态及其失败语义。
2. 修正允许缺键的路径；不得为消除日志而改变业务默认值或隐藏真实失败。
3. 覆盖键存在、键缺失和对象已失效的实际运行路径，并检查日志。
4. 修复并验证前，继续按 [`../reference/acceptance.md`](../reference/acceptance.md) 的日志门禁处理；不以命中数或改写数量宣称完成。

## Godot 4.7.2 线程加载泄漏 `LoadToken`（嵌套 `preload`）

`ResourceLoader.load_threaded_request` + `load_threaded_get` 在加载包含嵌套 `preload()` 的资源时，`LoadToken` 的 `unreference()` 返回值被忽略，计数归零但对象不释放；泄漏的 token 继续持有加载结果，连带其引用链上的资源（实测为 `Scene/all_sound/bgm.tscn` 中的音频流）在退出时残留。上游记录见 [#120661](https://github.com/godotengine/godot/issues/120661)，修复 PR [#121025](https://github.com/godotengine/godot/pull/121025) 未合并。

### 实测证据（Godot 4.7.2.stable）

- 最小对照：40 场景嵌套 `preload`，同步 `load` 与普通 `Thread` + `ResourceLoader.load` 各 3 次均 0 泄漏；`load_threaded_request` / `get` 每次泄漏 39 个零引用对象。
- 项目场景：独立加载 `ldl.tscn` 泄漏 4 个，`load_scene.tscn` 泄漏 2 个；同步与普通线程对照均为 0。
- release EXE：`level_1` 探针退出 19 个 `ObjectDB`（验收 FAIL）；窗口冷启动 + `WM_CLOSE` 18 个零引用 `RefCounted`。

### 工程规避

`ResourceRuntime` 用普通 `Thread` + `ResourceLoader.load` 串行加载，主线程轮询 `get_thread_load_state`，`take_thread_load_resource` 取回结果后 `join`；排队、取消、代次失效与过期结果由作业表收尾。启动加载页、关卡加载页、UI 作用域、永久小 UI、单槽与 legacy 预载已切换。实现见 [`resource_runtime.gd`](../../source/Script/runtime/resource_runtime.gd)、[`startup_loading.gd`](../../source/Script/runtime/startup_loading.gd)、[`load_scene.gd`](../../source/Script/runtime/load_scene.gd)。

**工作线程约束**：加载线程内可能把 `resource_changed` 回调投递到主线程 `MessageQueue` 并等待；主线程阻塞在 `wait_to_finish()` 上会死锁。清理与退出只做非阻塞收尾；应用在加载进行中退出时，运行中的作业交由进程回收。

### 未切换调用点

仍使用 `load_threaded_request` 的调用点只加载纹理与 `SpriteFrames`，不触发嵌套 `preload` 路径，复测未见残留：`frame_texture_requests.gd`、`ba_di_qian_kun_effect.gd`、`streaming_role_bullet.gd`、`wu_shuang_huo_yan_jin_jing_effect.gd`、`mirror.gd`、`sword_boss_base.gd`、`mount_visual.gd`。新增含嵌套 `preload` 的资源不得使用线程请求接口。

### 处置与验收

1. 升级到包含上游修复的 Godot 版本后再评估恢复线程请求接口；升级前保持现有普通线程路径。
2. 回归时同时检查 release `level_1` 的 `ObjectDB` 与窗口 `WM_CLOSE` 的零引用对象，二者均为 0 才算通过。
3. 退出时仍存的纹理 RID 与 `RenderingServer::get_singleton() is null` 是独立问题，见下一节。

## 窗口退出残留 2 个 Texture RID 与 `RenderingServer::get_singleton() is null`

根因已确认：`display/mouse_cursor/custom_image="res://Art/main_game/sbgb.png"` 由引擎在启动时加载为 `CompressedTexture2D` 并持有到退出；引擎在 `RenderingServer` 关闭后才释放该纹理，析构时调用空单例，并残留 1 个 `TextureStorage::Texture` 与 2 个 `Texture` RID。与线程加载改造无关：改造前旧 EXE 同条件同样出现，headless 关卡探针不触发渲染路径。

最小复现：导出空场景，仅设置 `mouse_cursor/custom_image`，退出日志与正式包一致；移除该设置后为 0。启动图、窗口图标与 autoload 对照均不触发。

**上游定性**：这是 Godot 引擎缺陷，不是本项目引入的问题；任何设置自定义光标的工程都会触发。issue [#98806](https://github.com/godotengine/godot/issues/98806)（confirmed，Windows；4.2.1 / 4.3 / 4.4.dev3 可复现）记录同一组日志；修复 PR [#125110](https://github.com/godotengine/godot/pull/125110) 于 2026-11-04 合入 master（4.8 里程碑），在 `finalize_display()` 中先调用 `DisplayServer::cursor_clear_custom_image_cache()` 再 `rendering_server->finish()`。截至 2026-11-12 未检索到 4.7 回移植，当前 4.7.2 仍受影响，工程内保留退出重置光标的规避。

### 规避

`Global._exit_tree()` 在缓存与场景清理前调用 `Input.set_custom_mouse_cursor(null)`，让引擎提前释放自定义光标纹理。实现在 [`global.gd`](../../source/global.gd)。

### 处置与验收

1. 回归时保留自定义光标设置，检查 release 窗口冷启动 + `WM_CLOSE` 退出：无 `RID allocations ... leaked`、无 `~CompressedTexture2D` 空单例错误、0 `ObjectDB` 泄漏。
2. 若后续升级 Godot 或更换渲染后端，重新验证该退出顺序；未被本项覆盖的平台不得据此推定通过。
3. 确认前不得通过延迟退出、隐藏日志或跳过关卡日志门禁规避该告警。
