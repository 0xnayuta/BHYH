# BHYH 全工程命名规范与契约白皮书 (Comprehensive Naming & Contract Standard)

> **版本**：v2.1.0（2026-10-23 · BHYH 单工程结构适配版）
>
> **生效范围**：`source/` 活跃开发主工程全量代码、场景、资源与目录
>
> **权威依据**：
>
> - [Godot 4 Project organization](https://docs.godotengine.org/en/stable/tutorials/best_practices/project_organization.html)
> - [Godot 4 GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)

---

## 0. 核心宪章原则 (Core Tenets)

1. **单一真源原则 (Single Source of Truth)**：任何命名（文件、目录、节点、变量、函数、常量、字典键）必须有且仅有一个权威定义源。代码字面量、场景树引用与磁盘实体必须严格 100% 一致。
2. **跨平台大小写敏感铁律 (Case-Sensitivity Invariant)**：所有路径引用必须与磁盘实际字节大小写逐字精确对应；在 Windows 开发、Linux/macOS/Android 导出和 Git 跨平台检出之间不得存在隐式大小写差异。
3. **Godot 官方优先 (Godot Official First)**：文件与目录命名采用 Godot 官方推荐的 `snake_case`；`class_name` 与场景树节点采用 `PascalCase`；如项目规范与 Godot 官方冲突，以官方规范为准，除非白皮书明确记录经评审的项目级偏离。
4. **规范前置于施工 (Constitution Before Construction)**：新增代码、场景、资源必须先符合本规范；存量债务必须进入机读基线，不得以“历史原因”新增豁免。
5. **工具化原子落地 (Tool-Guaranteed Execution)**：涉及路径变更必须经由统一引擎 `scripts/rename_path.py` 执行两步式迁移与全盘协同更新，严禁人工裸改。

---

## 1. 目录结构命名规范 (Directory Naming)

### 1.1 核心规则

- **全小写下划线 (`snake_case`)**：工程内所有功能目录、分类目录与各级子目录一律使用纯小写 `snake_case`；
- **禁止格式**：严禁目录名使用 `PascalCase`、`camelCase`、空格、特殊符号或中文字符；
- **根级保留名**：`Art`、`Font`、`Music`、`Scene`、`Script`、`Shader`、`Spritesheet`、`addons`、`bin` 等工程根级目录为历史/引擎约定目录，其**内部**业务目录仍必须 `snake_case`。

### 1.2 顶层目录职责

| 顶层目录 | 规范 | 职责边界 |
|:---|:---|:---|
| `source/Scene/` | 业务子目录 `snake_case` | 场景树、预制体 |
| `source/Script/` | 业务子目录 `snake_case` | GDScript 业务逻辑 |
| `source/Art/` | 业务子目录 `snake_case` | 美术、精灵帧、图集 |
| `source/Music/` | 业务子目录 `snake_case` | 音乐与音效 |
| `source/Shader/` | `snake_case` | `.gdshader` |
| `source/Font/` | `snake_case` | 字体容器 |
| `source/addons/` | 遵从第三方插件 | 外部插件，独立白名单保护 |

### 1.3 目录迁移硬性约束

- 任何目录重命名**必须且仅能**通过 `scripts/rename_path.py` 执行；
- 严禁操作系统中直接改名，严禁单步 `git mv old new`；
- 凡单批次目录/文件重命名 ≥ 3 个、涉及 `.gd/.tscn/.tres/.import/.json` 引用、涉及字典键/动画名/UI 文案或机器导出白名单的迁移，必须在提交信息与变更说明中登记迁移范围、引用同步与白名单例外。

---

## 2. 文件命名规范 (File Naming)

### 2.1 Godot 官方文件命名基线

Godot 官方 Project organization 明确建议：

> **Use `snake_case` for folder and file names**（C# 脚本除外；C# 脚本按类名 PascalCase）。

Godot GDScript Style Guide 进一步给出：

```gdscript
# 文件应命名为 `yaml_parser.gd`
class_name YAMLParser
extends Object
```

因此本项目执行以下规则：

- **所有 `.tscn` 场景文件**：`snake_case`；
- **所有 `.gd` 脚本文件**：`snake_case`，即使声明了 `class_name`；
- **资源与资产文件**：`.tres`、`.res`、`.png`、`.jpg`、`.webp`、`.mp3`、`.ogg`、`.wav`、`.ttf`、`.otf`、`.gdshader`、`.json` 等默认 `snake_case`；
- **伴生元数据**：`.import`、`.uid` 必须与源文件全名完全同步；
- **机器导出例外**：Flash/TexturePacker 产物允许保留工具生成名称，但必须进入 `scripts/contract_whitelist.json` 的精确冻结表。

### 2.2 文件命名样例

```text
正确：
main_menu.tscn
level_1.tscn
base_hero.gd              # class_name BaseHero
monster_bullet.gd
hero_default_stats.tres
bgm_flower_fruit_mountain.mp3
hit_sword_01.wav

错误：
MainMenu.tscn
Level_1.tscn
BaseHero.gd               # class_name 为 PascalCase，但文件名应 snake_case
heroDefaultStats.tres
```

### 2.3 机器导出与素材工具产物

以下名称由上游 Flash/TexturePacker/Spine 工具生成，允许不作为普通业务文件重命名，但必须逐条登记：

- `DefineSprite_*`、`symbolClass`、`*-assets`、`*.sprites`、`glb_*`；
- 纯数字资源 ID 目录与数字 ID 场景；
- `addons/` 下第三方插件；
- `.atlas`、`.spine-json`、`.translation` 等工具链伴生文件。

未登记的机器导出结构、新增数字 ID 目录或新增数字 ID 场景，均视为违规。

构建期生成资源（如 `source/Art/frame_sequences/*.tres`）：

- 文件名由资产身份（`asset_id`）派生 `snake_case` slug，超长时截断并追加 8 位身份哈希；
- 文件名只用于定位与检索，资产身份由 `asset_id` 与资源头 UID 承载；改文件名不改变身份；
- 禁止用哈希、UUID 或纯序号作为生成资源文件名，除非该工具的输出格式强制要求并已登记；
- 生成器必须断言 slug 唯一，不得靠自动加后缀静默消解冲突。

---

## 3. 场景树节点命名规范 (Scene Tree Node Naming)

### 3.1 核心规则

- **统一采用 `PascalCase`（大驼峰）**：所有 `.tscn` 场景树内部节点名称必须严格使用 PascalCase，如 `CharacterBody2D`、`CollisionShape2D`、`RoleBody`、`HitBox`、`AnimatedSprite2D`；
- **节点名与文件名分离**：文件采用 `snake_case` 不代表节点名可以小写；场景树节点继续使用 PascalCase；
- **禁止把节点当变量**：变量是代码概念，遵循 `snake_case`；节点是场景拓扑概念，遵循 `PascalCase`。

### 3.2 节点路径引用契约 (NodePath Invariant)

- 代码中 `get_node("...")`、`get_node_or_null("...")`、`NodePath("...")`、`$...` 的节点路径必须与场景树真实节点名称**大小写绝对一致**；
- 严禁为迎合代码中的驼峰重构，把 `get_node("RoleBody")` 改写为 `get_node("role_body")`；
- 场景继承、`instance=ExtResource` 和动画轨道中的节点路径均纳入契约扫描。

---

## 4. GDScript 代码标识符命名规范 (Code Identifier Naming)

### 4.1 总表

| 语言要素 | 规范 | 正确样例 | 错误样例 |
|:---|:---|:---|:---|
| 类名 `class_name` | `PascalCase` | `BaseHero`, `BattleManager` | `base_hero`, `baseHero` |
| 文件名 `.gd` | `snake_case` | `base_hero.gd` | `BaseHero.gd` |
| 函数 `func` | `snake_case` | `get_target()`, `take_damage()` | `getTarget()`, `TakeDamage()` |
| 私有/虚函数 | `_snake_case` | `_ready()`, `_refresh_ui()` | `Ready()`, `_refreshUI()` |
| 普通变量 `var` | `snake_case` | `attack_range` | `attackRange`, `AttackRange` |
| 私有变量 | `_snake_case` | `_is_grounded`, `_last_position` | `_isGrounded`, `m_lastPos` |
| 常量 `const` | `UPPER_SNAKE_CASE` | `MAX_COUNT` | `maxCount`, `Max_Count` |
| 类别名常量 | `PascalCase` | `const Weapon = preload("res://weapon.gd")` | `const weapon = preload(...)` |
| 信号 `signal` | `snake_case`，推荐过去时 | `hit_received`, `skill_cast_finished` | `onHit`, `HitReceived` |
| 枚举名 `enum` | `PascalCase` | `SkillType`, `DamageElement` | `skill_type`, `skillType` |
| 枚举项 | `UPPER_SNAKE_CASE` | `PHYSICAL`, `MAGIC`, `FIRE` | `Physical`, `magic` |

### 4.2 细部规则

- **Autoload 兼容桥接变量例外**：`PlayerData`、`RoleProp`、`PlayerInput` 三个名称在继承上下文（`BaseObject`、`BaseRole`、`BaseMagicWeapon`、`SkillIcon`、`BaseRoleProperties`）中作为同名 Autoload 的按槽位桥接属性保留 PascalCase；仅限这三个名称，不得用于其它业务变量。

- **禁止尾下划线**：`add_font_`、`load_`、`aura_` 不是合法 `snake_case`；需要私有语义时使用前置下划线，如 `_add_font`；
- **类别名常量例外**：`const ClassAlias = preload("res://...")` / `load(...)` 允许 PascalCase，遵循 Godot 官方示例；普通值常量仍必须 `UPPER_SNAKE_CASE`；
- **枚举成员**必须 `UPPER_SNAKE_CASE`，不得使用 `PascalCase` 或 `camelCase`；
- **信号**使用 `snake_case`，推荐过去时动词；
- **函数参数**与局部变量遵循 `snake_case`，不得遮蔽基类成员或全局符号。

---

## 5. 数据字典键与字面量契约规范 (Data Keys & Literals)

### 5.1 字典键契约

- **禁止裸中文字符串**：严禁在业务逻辑中直接书写 `player_data["玩家等级"]`、`item["攻击力"]`；
- **统一常量化**：所有持久化、业务交互与配置属性字段必须在 `source/Script/base/data_keys.gd`（`DataKeys`）中声明常量，统一通过常量引用：

```gdscript
var level: int = PlayerData.player_data[DataKeys.PLAYER_LEVEL]
```

### 5.2 资源路径字面量

- 所有资源加载路径必须显式以 `res://` 开头；
- 路径中每一级目录与文件名必须与磁盘实际大小写逐字吻合；
- 动态拼接必须通过集中工厂函数或工具类管理，禁止在业务深处散落不规则路径。

### 5.3 动画轨道与反射

- `AnimationPlayer` Method Track 调用的函数名必须在对应挂载脚本中有明确且大小写严格一致的实现；
- `call()`、`call_deferred()`、`has_method()`、`set()`、`get()`、`connect()` 的字符串必须与目标声明的属性/方法/信号 100% 吻合。

---

## 6. 外围只读资产与机器导出白名单制度 (Asset Whitelisting)

### 6.1 白名单范围

以下范围可享受只读豁免，但必须逐条登记：

1. **Flash 反编译与时间轴导出资产**：`DefineSprite_*`、`symbolClass`、`*-assets` 等；
2. **TexturePacker 机器生成图集**：`*.sprites/` 及索引清单；
3. **外部第三方插件**：`source/addons/`；
4. **数值与配置 ID 驱动的目录/场景**：纯数字 ID 且由运行时按资源 ID 动态拼接。

### 6.2 白名单管理

- 所有豁免条目必须在 `scripts/contract_whitelist.json` 中显式登记；
- **只减不增**：普通业务文件、脚本、场景、资源不得以“历史原因”加入白名单；
- 白名单按精确路径匹配，禁止使用 `DefineSprite_*` 或数字前缀通配自动放行；
- 新增条目必须附技术评审记录，并更新 `frozen_manifest_sha256`。

---

## 7. 质量流水线与门禁执行铁律 (Quality Gates)

任何提交合并入主干前必须通过：

1. `scripts/normalize_eol.py`：全工程 LF；
2. `scripts/format_all.py --check`：`gdformat` 格式；
3. `gdlint`：静态异味；
4. `scripts/health_check.py`：Godot 4.7.2 全量编译/引用，并扫描 GDScript 静态分析 warning（白名单外必须为 0）；
5. `scripts/contract_gate.py`：字面量契约、AtlasMetadata、PNG allowlist、白名单冻结；
6. `scripts/naming_audit.py`：目录与新增文件命名；
7. `scripts/runtime_reference_audit.py`：NodePath 与 `Global.<method>()` 静态运行时引用；
8. `scripts/naming_compliance_audit.py`：全量命名终审（存量 + 代码标识符）；
9. `scripts/resource_path_audit.py`：静态资源路径大小写、动态格式路径、Spine atlas 页名与动态工厂目标。

> `naming_compliance_audit.py` 是人工全量终审，不在 `check_all.py` 的八维日常并发门禁内；其结论必须单独执行。

### 7.1 门禁基线

- `check_all.py` 八维必须 100% PASS；
- `naming_audit.py --all` 与 `naming_compliance_audit.py --fail-on-error` 用于全量终审；
- 存量命名债务必须保持在机读基线中逐步递减，不得新增；
- 任何新增文件若违反本白皮书，`naming_audit.py` 必须拦截。

### 7.2 路径迁移

- 涉及目录/文件改名必须使用 `scripts/rename_path.py`；
- 迁移后必须同步 `.import`、`.uid`、`res://` 引用、Autoload 路径、场景 `ext_resource`、动画轨道和字典键；
- 每批迁移后运行 `check_all.py`、对应关卡冒烟与全量命名报告。

---

## 8. 规范裁决与解释权

1. 本白皮书与 Godot 官方文档冲突时，以 Godot 官方文档为准；项目级偏离必须在本文件明确记录并附技术评审；
2. 本白皮书与 `scripts/contract_whitelist.json` 冲突时，以本白皮书为规范、以冻结表为机器执行边界；
3. 命名规则变更必须先更新本文件与审计工具，再运行全量报告，最后才允许修改业务文件；
4. 本文件由工程规范维护者解释；任何例外必须有书面记录，不得口头豁免。

---

## 附录：官方参考

- Godot Project organization：
  https://docs.godotengine.org/en/stable/tutorials/best_practices/project_organization.html
- Godot GDScript style guide：
  https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html
