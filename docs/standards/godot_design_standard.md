# Godot 现代项目设计规范

> **适用范围**：新增代码与主动重构代码。
>
> **遗留边界**：仅对 [`../reference/architecture.md`](../reference/architecture.md) 明确记录的存量结构按遗留处理；本文不授权无计划重构，也不允许新增同类依赖。
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
- 重构场景结构时同步更新所有 `get_node()` / `$` / 动画轨道引用；
- `AnimationPlayer` 驱动非数值状态的 value track（`AnimatedSprite2D.animation`、`playing` 等 `StringName`/`bool` 属性）MUST 使用离散更新（`keys.update = 1`）；连续更新会触发 Godot 的 String 混合实验算法 WARNING。数值属性可按需要连续插值。

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

- Autoload 数量不是目标；每次新增、合并或移除都必须评审替代方案、调用面、初始化顺序、生命周期与清理方式。
- 全局编排对象不得因便于访问而新增业务职责；职责提取必须按所有权边界迁移生产调用方、删除旧实现与过时入口，不保留兼容转发链。

---

## 5. 项目结构与迁移边界

- 按 ADR-008 保留现有类型顶层目录，在其内部按功能组织场景、脚本和资源；不得建立同一功能的平行目录体系。
- 不新增顶层类型目录，除非经过独立架构评审；不以“规范化”为由进行无边界的全工程搬迁。
- 目录与文件命名、路径迁移工具和引用同步要求遵循 [`naming_standard.md`](naming_standard.md)。跨目录迁移必须先有方案，并按 [`../reference/acceptance.md`](../reference/acceptance.md) 验证受影响行为。

---

## 6. 输入、物理层与项目设置

- 基础输入动作应在 `project.godot` 集中定义；运行时派生动作必须由明确的集中所有者管理，不得散落裸键或随意动态注册。
- 物理层使用具名层；碰撞掩码不得使用无注释的裸整数。
- `project.godot` 属于可审查配置；`.godot/` 导入缓存不得作为项目资源提交。
- UI 窗口栈、槽位绑定、输入交接及平台边界遵循 [`target_architecture_contract.md`](target_architecture_contract.md)；其当前实现见 [`../reference/architecture.md`](../reference/architecture.md)。

---

## 7. 验证要求

新增或主动重构场景、Resource、Autoload、输入动作或物理层时，必须按 [`../reference/acceptance.md`](../reference/acceptance.md) 选择适用验收档位，完成相关静态门禁与运行期验证；不得以单项工具通过替代验收。具体命令、失败判据与运行时夹具见 acceptance 和 [`../../scripts/README.md`](../../scripts/README.md)，本文不重复列单。

---

## 8. 存量结构边界

以下仅为已存在代码的有限遗留边界，不构成新增代码先例：

- 按 ADR-008 保留 `Scene/Script/Art` 等类型顶层目录，在其内部按功能组织；不强制全工程搬迁，也不新增顶层类型目录。
- 既有深层节点路径与场景继承只在尚未迁移的存量范围内保留；新增代码必须使用明确注入和场景内部引用，重构时同步修正节点路径。
- 既有双人面板全局视图交换属于迁移中的遗留路径；新增 UI 显式绑定操作者/槽位，且完整迁移前必须保留既有保存保护。决策见 [ADR-021](../decisions/ADR-021-project-wide-target-architecture.md)，实际边界见 [`../reference/architecture.md`](../reference/architecture.md) 与 [`../reference/acceptance.md`](../reference/acceptance.md)。

其他存量实现边界以 [`../reference/architecture.md`](../reference/architecture.md) 为准；跨域职责、所有权与生命周期目标以 [`target_architecture_contract.md`](target_architecture_contract.md) 为准。遗留改造须独立评估，不混入普通功能提交。
