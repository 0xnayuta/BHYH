# 视觉资产目标架构契约

> **定位**：规定视觉资产现代化的目标与验收边界，不描述当前实现或迁移进度。
> **适用范围**：新增及主动重构的、随产品交付的固定视觉资产。
> 当前实际架构见 [`../reference/architecture.md`](../reference/architecture.md)，验证快照见 [`../reference/status.md`](../reference/status.md)，实施计划见 [`../roadmap/roadmap.md`](../roadmap/roadmap.md)。

## 1. 决策与效力

本项目采用构建层、资源层、运行时层三层契约。统一资源生产、数据边界与调用契约，不把所有视觉内容强制转换为同一种格式或万能播放器。

本文是**项目选择**，不是 Godot 对所有项目的强制要求。相关决策见 [ADR-020](../decisions/ADR-020-typed-visual-assets-and-streaming-lifecycle.md)；现有 Spine 内容继续遵守 [ADR-010](../decisions/ADR-010-spine-runtime-boundary.md)。

| 层 | 职责 | 边界 |
|:---|:---|:---|
| 构建层 | 适配源格式，确定性生成，校验 schema、来源与发布依赖 | 源 JSON、目录发现和素材修复仅在离线工具执行 |
| 资源层 | 保存共享只读的视觉数据及稳定标识 | 不保存播放器时间、临时加载句柄或实例可变状态 |
| 运行时层 | 播放、预热、失败处理和请求收尾 | 消费明确资源，不猜目录、旧命名或可用后端 |

资源生命周期由实际持有引用决定；清空业务字典不等于取消后台请求，也不保证释放其它持有者引用。

## 2. 内容选型

| 内容/需求 | 默认选择 | 评审边界 |
|:---|:---|:---|
| 普通逐帧动画 | 构建期 `SpriteFrames`，由 `AnimatedSprite2D` 播放 | 可使用共享 `AtlasTexture` 页；不能仅凭帧数判断内存 |
| 规则精灵表或多属性/事件时间轴 | `Sprite2D` + `AnimationPlayer`，或 `AnimatedSprite2D` 配合 `AnimationPlayer` | 不重复驱动同一播放时钟；需要混合时评估 `AnimationTree` |
| 静态图、UI | `Texture2D` / `AtlasTexture` + `Sprite2D` / `TextureRect` | 不增加无意义的动画包装 |
| 现有 Spine 内容 | Spine 资源 + `SpineSprite` | 保留骨骼、皮肤、附件与变形，不为格式统一烘焙成帧 |
| 新增骨骼内容 | 按制作链和功能选择 Spine 或原生 `Skeleton2D` / `Bone2D` / `Polygon2D` + `AnimationPlayer` | 不因“骨骼动画”自动增加第三方依赖 |
| 需要按需驻留的逐帧内容 | `FrameSequence` + 专用流式播放器 | 记录目标平台、纹理页驻留量、并发数、首帧延迟和加载峰值的依据 |
| 图集源元数据 | `AtlasMetadata` 或明确的源格式适配器 | 它不是播放器，也不是所有资源必须经过的中间层 |

所有预录帧序列都是有限的；不得使用“有限/超大”作为唯一后端判断。流式方案也适用于已有明确驻留需求的背景，是否高频复用不是必要条件。

## 3. 构建层契约

1. 固定视觉资产必须离线生成播放定义。不得在战斗热路径扫描目录、猜编号、解析源 manifest 或逐帧拼路径建帧。
2. 规则精灵表、程序化内容和当前格式用户数据不属于上述固定资产禁令；不得借此恢复旧资产兼容路径。
3. 同一资产只有一个声明的正式来源；源格式选择必须显式。缺失动画不得自动替换为单张图或其它命名。合法静态保持必须在构建定义中声明。
4. 通用源格式使用通用转换器；专用 schema 可以使用名称明确的适配器，不预先建立万能转换器。
5. `--check` 必须校验生成内容、schema、资源路径、唯一标识、Catalog 闭包与发布依赖；不只检查输出文件是否存在。
6. 构建结果确定性生成，不依赖目录枚举顺序、运行时状态或随机 UID。UID 按已登记身份保持稳定；路径迁移由专用工具同步。生成资源文件名由资产身份派生可读 slug，文件名为定位投影、身份由 `asset_id` 与 UID 承载。
7. 生成文件的陈旧清理只能作用于转换器明确拥有的输出集合，不能删除用户或其它工具的文件。
8. 公开仓库不包含第三方素材；转换器和规格入库，私有素材及其派生产物本地生成。

工具职责以 [`../../scripts/README.md`](../../scripts/README.md) 为准；资产数量不在本文固化。

## 4. 资源层契约

### 4.1 类型、标识与共享

- 设计器配置与序列化数据优先自定义或原生 `Resource`。运行时状态使用普通节点、`RefCounted` 或强类型容器；不要求所有数据都 `@export`。
- 只向 Inspector/序列化暴露需要配置的字段。新增结构化资源使用强类型字段，不扩张裸字典边界。
- 资产 ID 表示内容身份，不包含浮点格式化的 FPS、loop、hold 或预取参数。
- 资源可提供播放默认值；时间、循环覆盖、末帧覆盖、速度倍率与预取窗口是实例状态，不回写共享资源。
- Catalog 中的元数据可共享；不得通过强引用全部 `Texture2D` 来解决流式资源的导出依赖。
- `AtlasMetadata.data` 是已登记的遗留边界；后续按消费者需要提供强类型访问，不强制把所有资产再包装成 AtlasMetadata。

### 4.2 资源校验与失败

- 构建期校验完整性；运行时接纳外部资源时校验一次 schema，拒绝错误类型、空序列、数组长度不一致、非法时间或区域。
- debug 可附加 `assert`；release 必须同样记录明确错误并拒绝启动错误消费者。不得仅依赖 `assert`。
- 后端由资源定义或显式配置选择。指定 SpriteFrames 动画缺失时，不得改走 FrameSequence；不同资产声明不同后端是合法选型，不是兼容层。
- 失败必须向拥有者传播；可中止该视觉或场景加载，不允许通过旧路径、猜名或空白占位掩盖错误。正常错误处理不属于被禁止的兼容层。

### 4.3 导入、UID 与发布依赖

- PNG/音频等外部源素材经 Godot 导入，旁置 `.import` 保存配置；`.godot/imported/` 是可重建缓存，不入库。
- `.tres/.tscn` 是 Godot 原生资源，不要求伪造 `.import`；可序列化资源的 UID 写在资源头，脚本/着色器按引擎机制维护伴生 `.uid`。
- 生成资源必须有可重复的稳定 UID 或明确评审的例外；不同资源不能复用同一 UID。
- 仅存为字符串的延迟加载路径不自动构成 Godot 资源依赖。必须生成独立依赖清单，并通过显式导出规则或导出插件打包。
- 构建检查证明源资源齐全不等于发布包齐全；发布前必须从 PCK/导出包验证路径闭包与实际加载。

## 5. 运行时层契约

### 5.1 播放与状态

- 优先采用原生节点；流式播放器只负责帧时钟、纹理窗口、区域和显示事件，不侵入战斗伤害与关卡编排。
- 资源在启动前显式注入；通过小范围组合或必要的适配器复用，不新增万能节点或资源平台。
- 明确顺播、循环、末帧、手动跳帧、空白帧和失败信号语义。碰撞跟随视觉时，必须使用已显示帧的几何，不使用未就绪的未来帧。
- `.tres` 是序列化格式，不是独立播放器；不得以扩展名代替资源类型设计。

### 5.2 加载、预热与退出

- 固定的小依赖优先 `preload`；大型资源按需加载。不要让全局脚本的 `preload` 间接常驻全部大型视觉。
- 游戏线程允许跨帧轮询线程加载状态；禁止主线程同步磁盘 IO 和高频同步加载。流式组件依据构建清单发起受控异步请求不属于逐帧猜名禁令。
- 每个请求必须有所有者。共享请求必须去重并计数；消费者退出后仍须在请求完成时取回并释放结果，不能仅清空本地字典。
- 不在 `_exit_tree` 同步等待未完成请求；场景树仍运行时，由受控收尾者跨帧处理。进程退出另有明确关闭路径。
- 预热区分：元数据就绪、纹理资源就绪、可显示首帧。命名和验收不得把 Catalog 加载冒充纹理预热。
- 预热纹理必须保持引用直到消费者接手或预热所有者释放；规定驻留范围，避免按动画重复持有相同图集页。
- 缓存需有可观察的命中、在途请求和释放边界；性能预算基于实际目标平台测量，不在本文编造统一阈值。

### 5.3 Spine

Spine `.atlas` 与项目 `AtlasMetadata` 是不同格式。现有 Spine 内容不烘焙为 SpriteFrames；新增原生骨骼内容不强制 Spine。第三方库版本、许可证和目标平台二进制单独核实，不能把本机编辑器加载通过外推为跨平台发布通过。

## 6. 验收契约

执行档位和命令见 [`../reference/acceptance.md`](../reference/acceptance.md)。视觉资源变更至少覆盖：

1. 构建内容、schema、路径、唯一 ID/UID、Catalog key 与发布依赖闭包；
2. 正常播放、循环、末帧、跳帧、空白帧、首次就绪和失败传播；
3. 缺资源/错误动画/错误类型必须失败，不能切换其它来源；
4. 多播放器共享请求、提前销毁、场景切换与结果回收；
5. 元数据/纹理预热的不同判据，以及重复进入退出后的驻留检查；
6. 静态门禁、引擎健康、生产消费者场景探针及相关关卡；
7. release 失败语义、导出包实际依赖和目标平台性能（发布前）。

首帧显示或节点存在不能代替完整动画、几何与生命周期验收。源码枚举门禁与会临时向 `source/` 安装夹具的运行探针必须串行，避免把临时夹具当生产文件。

## 7. 文档与决策维护

- 本文只维护目标与长期规则，不保存资源总数、迁移完成列表、耗时或 PASS 计数。
- `reference/architecture.md` 记录当前真实实现；`status.md` 记录带日期/提交的验证快照；roadmap 记录待做工作。
- 规范先于实现修订，实施完成再同步实际架构与验收文档；不得把目标直接写成现状。
- Accepted ADR 的实质变更新增替代 ADR；旧 ADR 只标注替代关系，保留原结论。
- 任何偏离须有明确范围、理由和验收，不得用兼容分支绕过契约。

## 8. 官方依据与关联文档

- [Godot AnimatedSprite2D](https://docs.godotengine.org/en/4.7/classes/class_animatedsprite2d.html)
- [Godot Skeleton2D](https://docs.godotengine.org/en/4.7/classes/class_skeleton2d.html)
- [Godot Resources](https://docs.godotengine.org/en/4.7/classes/class_resource.html)
- [Godot 后台加载](https://docs.godotengine.org/en/4.7/tutorials/io/background_loading.html)
- [Godot 导入流程](https://docs.godotengine.org/en/4.7/tutorials/assets_pipeline/import_process.html)
- [Godot 导出资源](https://docs.godotengine.org/en/4.7/tutorials/export/exporting_projects.html)
- [`godot_design_standard.md`](godot_design_standard.md)
- [`spriteframes_generation_policy.md`](spriteframes_generation_policy.md)
- [`../reference/architecture.md`](../reference/architecture.md)
- [`../reference/acceptance.md`](../reference/acceptance.md)
- [`../reference/status.md`](../reference/status.md)
