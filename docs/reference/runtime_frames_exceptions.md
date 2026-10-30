# 运行时建帧例外决策（Phase 19-3A）

> **状态**：2026-10-30 完成复核。允许清单以 [`scripts/runtime_frames_allowlist.json`](../../scripts/runtime_frames_allowlist.json) 为唯一事实源；本页记录 12 个冻结例外的逐项结论与证据，不复制长期维护的运行时统计。
> **范围**：Phase 13 收口后剩余的运行时 `SpriteFrames.new()` 例外（9 个怪物 + 3 个非怪物）。
> **结论口径**：`保留`（运行期构建有明确边界，无需迁移）、`补资源`（应迁移到构建期资源，但需现有转换器扩展或私有资源生成）、`删除回退`（异常兜底无正常调用路径，删除并改为显式失败）。

## 1. 决策总表

| 文件 | 运行期构建内容 | 证据 | 结论 |
|:---|:---|:---|:---|
| `source/Script/level/level_59.gd` | `_build_stone_frames` 使用 `STONE_TEXTURES` 固定 `preload` 数组建帧 | 固定纹理数组、固定 15 FPS；无路径扫描、无逐帧 IO | 保留 |
| `source/Script/monster/east_continent_monster.gd` | `_load_standard_body_frames` 复制构建期 `swf_png_<model>_frames.tres`，按合并后的关卡配置重命名动作 | 只复制已加载帧；`_config["animations"]` 由关卡配置 `merge`，无法完全静态化 | 保留 |
| `source/Script/monster/eight_immortals_boss.gd` | `_configure_visuals` 遍历 `body_actions/<state>/<n>.png`，并对 monster166/168 做 `AtlasTexture` 裁剪 | 8 个 Boss、多状态、多目录逐帧 PNG；现有转换器不覆盖多目录动作集 | 补资源待办 |
| `source/Script/monster/monster_bullet.gd` | `_get_cached_pet_bullet_frames` 在标准帧缺失时生成 null 帧计时 `SpriteFrames` | 只提供时间轴长度，不拼帧路径；可见画面由独立图层负责 | 保留 |
| `source/Script/monster/nanhai_projectile.gd` | `_standard_frames_for` 复用 `swf_png_<model>_frames.tres` 并重命名为 `play`；`get_frame_set` 保留逐帧 PNG 回退 | 标准资源复用；无标准资源的模型仍依赖逐帧回退，回退是活跃路径 | 保留 |
| `source/Script/monster/pet_tiger_boss_base.gd` | `_setup_tiger_model_frames` 读取 `stage<stage>/r<row>_c<col>.png` 固定网格 | 3 个阶段、固定行列网格；现有 sheet/编号帧转换器不覆盖多纹理网格 | 补资源待办 |
| `source/Script/monster/tao_wu_boss.gd` | 标准 `tao_wu_frames.tres` 缺失时用 `monster47.png` 单图伪造 `atlas` 动画 | `tao_wu_frames.tres` 含 `Monster47FramesCenteredCropped`；场景仅 `monster_151.tscn` 使用该脚本 | **删除回退（已执行）** |
| `source/Script/monster/three_prince_boss.gd` | `_build_body_frames` 遍历 `root/<action>/<n>.png`，超过 `frame_size` 时居中裁剪 | 4 个根目录 × 多动作逐帧 PNG；Nezha 根已走构建期资源，其余仍需运行期构建 | 补资源待办 |
| `source/Script/monster/three_prince_bullet.gd` | `_build_effect_frames` 有 `frames_resource_path` 时走资源，否则逐帧 PNG 回退 | Nezha 特效走资源；非 Nezha 特效仍依赖逐帧回退，回退是活跃路径 | 保留 |
| `source/Script/monster/weiyang_palace_boss.gd` | `_build_symbol_frames` 从现有帧资源复制并重命名为 `eye`/`mouth` 符号层 | **已修复（21-4B，2026-10-30）**：路径改为 `swf_png/3007/atlas/swf_png_3007_frames.tres`，`DefineSprite_45`(17)/`DefineSprite_68`(55)/`DefineSprite_28__1_fla.effect1_1_9`(78) 均存在；嘴部第 50 帧纹理可达，Boss 恢复发射 | **保留运行期复制**（`SpriteFrames.new()` 只复制现有帧，不重扫图集）；allowlist 不变 |
| `source/Script/pet/pet_neat_bullet.gd` | `_frames_for` 对 `pet_neat_4_bullet_3` 运行时执行蓝底抠图 | 构建期迁移需 22 张去底 PNG 与图像编解码步骤，收益低于素材重复成本 | 保留 |
| `source/Script/tools/user_key.gd` | `_make_ws_sprite_frames` 使用固定图标路径数组建帧 | 调试工具 UI，不进入游戏运行路径 | 保留 |

## 2. 已执行变更

- `tao_wu_boss.gd`：删除 `FALLBACK_BODY_TEXTURE` 与单图兜底；标准帧缺失时 `push_error` 并返回，不再用单图伪造动画。
- `runtime_frames_allowlist.json`：移除 `tao_wu_boss.gd` 条目；清单由 12 项降为 11 项，无新增条目。
- `runtime_frames_audit.py --fail-on-error`：11/11 PASS，运行时建帧集合与允许清单一致。
- `level_sssl` 冒烟 PASS（Stage 1~3，日志 0 ERROR / 0 WARNING）；`check_all --godot-bin` 8/8 PASS。

## 3. 后续边界

1. `eight_immortals_boss`、`pet_tiger_boss_base`、`three_prince_boss` 的“补资源”迁移需要扩展现有转换器以表达多目录/多纹理动作集；在转换器扩展前继续保留运行期构建，不新增 allowlist 条目。
2. `weiyang_palace_boss` 符号层路径已修正为 3007 帧资源（21-4B）；`weiyang-symbol` 探针覆盖帧数、初始帧、镜像与“嘴部推进到第 50 帧”，Boss 技能恢复发射。剩余运行期复制仍保留在 allowlist，不新增条目。
3. `nanhai_projectile` 与 `three_prince_bullet` 的逐帧回退是活跃路径，不是死代码；在非标准资源模型全部迁移前不得删除。
4. 其余保留项均为固定数组、已加载帧复制、null 计时帧、运行期抠图或调试工具，不满足“路径扫描/逐帧 IO”的新增禁止条件。
