# 运行时建帧例外的评审语义

> **范围权威**：运行时 `SpriteFrames.new()` 文件集合及逐项允许理由只以 [`scripts/runtime_frames_allowlist.json`](../../scripts/runtime_frames_allowlist.json) 为准。本页不复写清单或其数量，只记录需人工保留的边界语义。缺失资产状态以 [`missing_assets_registry.md`](../standards/missing_assets_registry.md) 为准；门禁判据见 [`acceptance.md`](acceptance.md)。

## 1. 允许范围如何判定

`scripts/runtime_frames_audit.py` 扫描 `source/` 下含 `SpriteFrames.new()` 标记的 GDScript 文件，并将扫描集合与 JSON 清单双向比较；未登记文件、失效条目或空理由会失败。新增或迁移例外时更新 JSON 中的理由并由审阅者确认，不在此页维护第二份清单。

allowlist 是逐项评审边界，不是新增运行时建帧的通用许可。固定预载资源、已加载帧的组合、无可见图像的计时帧或调试 UI 等理由，只在 JSON 登记的具体代码路径内有效，不能据此引入逐帧路径扫描或逐帧 IO。

## 2. 现存例外中的人工判断

- `east_continent_monster.gd` 只复制已加载的标准帧，但最终动作名受合并后的关卡配置影响，不能仅凭单一构建输入静态确定。`weiyang_palace_boss.gd` 从现有的 3007 帧资源复制并重命名符号层，不重新扫描图集或逐帧读取 PNG。两者的评审点是已加载帧的语义组合，不是新增建帧模板。
- `nanhai_projectile.gd` 与 `three_prince_bullet.gd` 在标准帧资源未覆盖的模型/特效上仍有活跃逐帧回退；不能将其当作死代码删除。只有对应非标准输入均由可用构建期资源覆盖后，才可重新评审这些回退。
- `pet_tiger_boss_base.gd` 声明的 `model/frames/stage1~4/r<row>_c<col>.png` 源网格缺失，预构建 `pet_tiger_stage*_frames.tres` 又缺 `hit5` / `hit6`，因此现有资源不能代替源输入完成转换。这是待解决的资产缺口，而非可复制的运行期建帧先例；证据和复核条件见缺失资产登记。
- `pet_neat_bullet.gd` 的特效需对输入图像执行蓝底抠图。构建期替代需要可追溯的逐帧去底结果与图像编解码步骤；评审时需权衡输出资源的维护责任和重复素材成本，不能只把 PNG 序列静态化便视为语义等价。
- `monster_bullet.gd` 在标准帧缺失时生成的 null 帧只提供时间轴，不拼帧路径，可见画面由独立图层负责；`level_59.gd` 从固定 `preload` 纹理数组建帧，不做路径扫描或逐帧 IO；`user_key.gd` 使用固定图标序列且只服务调试工具 UI。这些理由都限定于各自现有消费路径。

现存例外与已完成迁移或路径修复的实现不在本文维护第二份清单；具体现存范围与理由只读 allowlist。是否需要验证及验证结果分别由 `acceptance.md`、`status.md` 维护。
