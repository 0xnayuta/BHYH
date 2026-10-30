# Godot 现代项目设计规范

> **版本**：v1.1.0（2026-10-27，总体目标架构对齐）
>
> **适用范围**：新增代码与主动重构代码。
>
> **遗留边界**：现有 Flash 正位重构结构按“遗留例外”处理；本规范不授权无计划的大规模重构。
>
> **关联规范**：[`target_architecture_contract.md`](target_architecture_contract.md) 定义总体职责、依赖、所有权与生命周期；本文规定具体 Godot 设计方法；[`naming_standard.md`](naming_standard.md) 规定命名，例外见 [`naming_whitelist.md`](naming_whitelist.md)。

---

## 1. 官方依据

本项目遵循 Godot 4.7 官方最佳实践的主干原则，但只把项目相关部分固化为强制规则；完整背景以官方文档为准：

- [Project organization](https://docs.godotengine.org/en/4.7/tutorials/best_practices/project_organization.html)
- [Scene organization](https://docs.godotengine.org/en/4.7/tutorials/best_practices/scene_organization.html)
- [Applying object-oriented principles in Godot](https://docs.godotengine.org/en/4.7/tutorials/best_practices/what_are_godot_classes.html)
- [Resources](https://docs.godotengine.org/en/4.7/tutorials/scripting/resources.html)
- [Autoloads versus regular nodes](https://docs.godotengine.org/en/4.7/tutorials/best_practices/autoloads_versus_regular_nodes.html)
- [GDScript style guide](https://docs.godotengine.org/en/4.7/tutorials/scripting/gdscript/gdscript_styleguide.html)

---

## 2. 场景设计与组合

### 2.1 场景即类

- 场景必须具有单一职责，避免继续扩张为“万能场景”。
- 新场景应尽量自包含：所需节点、资源和默认行为在场景内部完成。
- 复杂界面/角色/怪物应拆成可复用子场景，通过实例组合，而不是在单个场景内堆叠数百个节点。
- 场景根脚本负责编排自身子节点；子节点不应反向控制父级或全局业务。

### 2.2 依赖注入

MUST：

- 需要 Inspector 配置的外部依赖通过强类型 `@export` 暴露；运行期档案、槽位、关卡上下文通过明确初始化方法或属性注入；
- 父场景/上层装配者只注入消费者需要的能力，不注入全能 Global/上下文字典；
- 禁止新增跨场景深层路径，例如 `get_node("/root/Game/World/Player")`；
- 禁止通过 `get_node("../../../../X")` 一类相对路径获取外部业务节点。

示例：

```gdscript
# 推荐：由上层注入，场景自身不依赖固定树结构
@export var target: Node2D

# 不推荐：绑定固定场景树
@onready var target := get_node("/root/Game/World/Player")
```

### 2.3 场景内部节点

SHOULD：

- 优先使用 `%UniqueName` + `@onready` 获取场景内部节点；
- 节点路径必须与场景树真实大小写一致；
- 重构场景结构时同步更新所有 `get_node()` / `$` / 动画轨道引用。

```gdscript
@onready var title_label: Label = %TitleLabel
```

### 2.4 父子通信

- 父节点可以调用子节点公开方法；
- 子节点通过 `signal` 通知父节点，不直接调用父级方法；
- 信号命名使用 `snake_case` 过去式；
- 跨模块通信优先通过上层控制器与明确依赖；信号用于报告事实，不把所有命令/状态搬进全局事件总线。

```gdscript
signal request_completed(result: Dictionary)

func _on_finished(result: Dictionary) -> void:
	request_completed.emit(result)
```

### 2.5 继承与组合

- 优先组合：复用行为通过子场景、组件节点、`Resource` 组合；
- 继承只用于稳定的“是一个”关系，不用于临时复用；
- 禁止为了少写几行代码而新增多层继承链。

---

## 3. 数据与 Resource

### 3.1 新数据优先 Resource

新增结构化静态数据时：

- MUST 优先定义强类型自定义 `Resource` 并保存为 `.tres`；原生 Resource 能满足时直接复用；
- 使用 `class_name`、默认值及必要的 `@export`；仅配置/序列化字段向 Inspector 暴露，不要求全部内部状态导出；
- 不把新增配置继续硬编码进 `global.gd` 或裸字典；
- 不在 `_process` / `_physics_process` 中反复读取磁盘 JSON；
- 遗留字典/JSON 结构保留为过渡，不做无计划迁移。

示例：

```gdscript
class_name EnemyConfig
extends Resource

@export var max_hp: int = 100
@export var move_speed: float = 80.0
@export var drop_table: Array[Resource] = []
```

### 3.2 DataKeys 过渡

- 现有 `DataKeys` 常量体系继续作为字典键的统一入口；
- 新增 Resource 字段使用强类型属性，不再新增裸中文字符串键；
- 字典与 Resource 混用期间，必须在代码中明确数据边界。

### 3.3 静态定义、实例状态与存档

- Resource 优先针对结构化静态配置，不要求玩家档案改存 `.tres`；当前加密 JSON、`DataKeys`、`ensure_*` 与原子写语义继续有效。
- HP/CD、播放时钟、面板状态等使用节点、`RefCounted` 或强类型容器，由实体/槽位/会话拥有，不写回共享定义。
- 已加载 Resource 通常共享；只读是项目约束，不由返回类型保证。消费者不能修改共享容器，不能为隔离少量状态深复制纹理。
- 档案、共同账本和玩家槽位分别标明写入者；新增 UI 显式接收操作者，不扩张全局 1P/2P 视图交换。

### 3.4 资源生命周期

- 小型固定依赖可 `preload`，大型资源按需加载；全局脚本不能间接常驻全部大资产。
- 缓存、预热、池与后台请求均需明确所有者、作用域、失效和释放路径，不以“必须缓存”授权永久持有。
- 退出消费者后使回调失效；未完成资源由受控收尾者跨帧取回释放，不在 `_exit_tree` 同步等待。
- `.tres` 便于审查；不提交引擎生成的二进制/导入缓存，不把所有 `.res` 一概当作格式迁移任务。

---

## 4. Autoload 边界

### 4.1 允许的 Autoload

Autoload 仅适用于：

- 跨场景、生命周期长的系统；
- 自身管理自身数据、不侵入其他对象状态的系统；
- 确有全局访问必要、且无法用普通节点、`Resource` 或静态函数合理替代的系统。

### 4.2 新增 Autoload 的评审

新增 Autoload 前必须说明：

1. 为什么不能使用普通场景节点；
2. 为什么不能使用 `Resource`、静态函数或 `class_name` 工具类；
3. 初始化顺序与依赖关系；
4. 生命周期、清理方式与测试入口；
5. 对现有 Autoload 数量与耦合度的影响。

未完成上述说明，不得新增 Autoload。

### 4.3 遗留例外

- 当前 12 个注册项是遗留基线，不是最终数量目标；增删/合并需评审调用面、初始化与关闭行为；
- `global.gd` 不再接收新业务职责；提取按所有权切片，不能只把字段搬进另一个 Manager；
- 新功能不以方便访问为由全局化；被替换 API 的调用方同批迁移，删除过时入口。正式职责仍正确的唯一入口可保留名称，不留兼容转发链。

---

## 5. 项目结构

### 5.1 当前结构

当前顶层按类型划分：

```text
source/
├── Scene/
├── Script/
├── Art/
├── Music/
├── Font/
├── Shader/
├── Spritesheet/
├── addons/
└── bin/
```

项目保留现有类型顶层，并在其内部功能聚合；这是 ADR-008 的明确选择，不将全仓目录搬迁视作架构完成条件。

### 5.2 新代码规则

- 新功能在现有顶层目录下使用功能子目录，例如：
  - `Scene/<feature>/`
  - `Script/<feature>/`
  - `Art/<feature>/`
- 不在同一功能中再建立第二套并行目录体系；
- 不新增顶层类型目录，除非经过独立架构评审；
- 目录与文件命名继续遵循 [`naming_standard.md`](naming_standard.md)。

### 5.3 迁移边界

任何跨目录重构必须：

1. 先提交迁移方案；
2. 使用 `scripts/rename_path.py`；
3. 完成引用扫描、UID/`.import` 同步；
4. 通过静态门禁与实机冒烟；
5. 保留回滚路径。

禁止借“规范化”名义进行无边界目录搬迁。

---

## 6. 输入、物理层与项目设置

- 基础输入动作统一在 `project.godot` 定义；`LocalCoop` 集中生成 `p2_*` 为已登记派生动作边界，不新增散落裸键或任意动态注册。
- 物理层使用具名层；碰撞掩码不得使用无注释的裸整数。
- 关卡内 HUD 窗口的 ESC 由 `backpack.gd` 统一分发；可关闭子层实现 `request_escape_close() -> bool`，只关闭一层并返回 `true`，不得在各窗口重复监听 `菜单` 打开设置。
- 新增窗口、渲染、音频、输入配置必须说明平台影响。
- `project.godot` 属于可审查配置；`.godot/` 导入缓存不入库。
- 活动 SceneTree 与玩法状态由主线程修改；后台只处理隔离数据/IO/受支持加载。线程交接明确同步、会话身份、过期结果拒绝与关闭路径。
- 新增平台导出前，先确认公开仓库素材边界与许可证。

---

## 7. 验证要求

新增或重构场景/资源后，至少执行：

```bash
python scripts/check_all.py --skip-engine
python scripts/health_check.py --project source --godot-bin <godot>
python scripts/level_test_runner.py --godot <godot> --level res://Scene/level/level_1.tscn
```

说明：

- 私有完整工作区必须保持 0 ERROR / 0 WARNING；
- 公开 clone 缺少第三方素材，出现资源缺失提示属于预期；
- 新增 Autoload、输入动作、物理层或全局资源路径时，必须执行对应实机验证。

---

## 8. 遗留例外清单

以下结构暂按遗留处理，不在本规范生效时强制迁移：

| 项目 | 状态 |
|:---|:---|
| 现有 Autoload 注册 | 遗留基线；变更需评审，不设数量目标 |
| `global.gd` 全局编排 | 禁止扩张；按职责闭环迁移，不永久保留旧 API |
| 字典/JSON 业务数据 | 保留存档边界；静态配置优先 Resource，可变状态按域拥有 |
| `Scene/Script/Art` 类型顶层 | 保留；内部功能聚合，不强制全仓搬迁 |
| 既有深层 `get_node()` / 绝对路径 | 保留，新增代码禁止 |
| 既有场景继承与节点路径 | 保留，重构时同步清理 |
| 2P 面板全局视图交换 | 现状与保存快照互斥；目标显式槽位绑定，迁移时联动验证 |

迁移遗留结构必须单独立项，不得混入普通功能提交。

---

## 9. PR 自检清单

- [ ] 新场景是否单一职责、可复用、尽量自包含？
- [ ] 外部依赖是否通过 `@export` / 上层注入，而非深层 `get_node()`？
- [ ] 子节点是否通过 signal 通知父级，而不是反向控制父级？
- [ ] 新数据是否优先使用 Resource / `.tres`？
- [ ] 是否新增 Autoload？是否完成评审说明？
- [ ] 输入动作、物理层是否使用具名配置？
- [ ] 是否新增公开素材或改变 `.gitignore` 边界？
- [ ] 是否执行静态门禁与必要的实机验证？
- [ ] 是否把遗留改造误混入普通功能提交？
