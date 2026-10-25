# Godot 现代项目设计规范

> **版本**：v1.0.0（2026-10-23）
>
> **适用范围**：新增代码与主动重构代码。
>
> **遗留边界**：现有 Flash 正位重构结构按“遗留例外”处理；本规范不授权无计划的大规模重构。
>
> **关联规范**：[`naming_standard.md`](naming_standard.md)（命名）、[`naming_whitelist.md`](naming_whitelist.md)（机器导出白名单）。

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

- 新场景与外部对象的依赖优先通过 `@export` 暴露；
- 由父场景/上层控制器负责注入依赖；
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
- 跨模块通信优先通过上层控制器或明确的信号总线，不新增全局可变状态。

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

- MUST 优先定义自定义 `Resource` 类，并保存为 `.tres`；
- 使用 `class_name`、`@export` 与默认值，保证 Inspector 可编辑；
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

### 3.3 资源生命周期

- 固定依赖优先 `preload`；
- 运行时动态加载必须缓存，避免高频 `load()`；
- 大图集/Spine/音频资源遵循现有缓存与预热机制；
- `.tres` 文本便于审查；导出时由引擎转换为二进制，不在仓库提交 `*.res` 构建产物。

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

- 当前 13 个 Autoload 属于历史结构，登记为遗留例外；
- `global.gd` 不得继续扩张为新的业务数据仓库；
- 新功能不得以“方便访问”为理由把状态塞进全局单例。

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

这是历史迁移结构，不立即全量改为 Godot 官方推荐的“按功能聚合”。

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

- 输入动作统一在 `project.godot` 中定义；代码不得散落裸按键字符串。
- 物理层使用具名层；碰撞掩码不得使用无注释的裸整数。
- 关卡内 HUD 窗口的 ESC 由 `backpack.gd` 统一分发；可关闭子层实现 `request_escape_close() -> bool`，只关闭一层并返回 `true`，不得在各窗口重复监听 `菜单` 打开设置。
- 新增窗口、渲染、音频、输入配置必须说明平台影响。
- `project.godot` 属于可审查配置；`.godot/` 导入缓存不入库。
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
| 13 个现有 Autoload | 保留，新增需评审 |
| `global.gd` 大体量全局状态 | 保留，禁止继续扩张 |
| 字典/JSON 业务数据 | 保留，新增数据优先 Resource |
| `Scene/Script/Art` 类型分层 | 保留，新功能按功能子目录聚合 |
| 既有深层 `get_node()` / 绝对路径 | 保留，新增代码禁止 |
| 既有场景继承与节点路径 | 保留，重构时同步清理 |

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
