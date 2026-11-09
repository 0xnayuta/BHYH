# ADR-031：`Scene/` 不承载 GDScript，脚本统一归 `Script/<domain>/`

- **状态**：Accepted
- **日期**：2026-11-09
- **关联**：[`ADR-004`](ADR-004-naming-contract-and-frozen-whitelist.md)、[`ADR-008`](ADR-008-type-based-directories-with-feature-subdirectories.md)、[`ADR-013`](ADR-013-tool-guaranteed-path-migration.md)、[`../standards/naming_standard.md`](../standards/naming_standard.md) §1.2/§1.4、[`../reference/scene_script_migration_matrix.md`](../reference/scene_script_migration_matrix.md)

## 1. 背景

`source/Scene/` 当前同时承载场景树（`.tscn`）与 56 个 GDScript（`.gd`）。这两个集合的生命周期不同：

- `.tscn` 是场景资源，路径与 `ext_resource`、预制体实例化和运行时代码字符串路径绑定；
- `.gd` 是逻辑代码，归属应由领域（domain）决定，而不是由“脚本挂在哪个场景旁边”决定。

现状带来三个问题：

1. `Scene/` 的目录语义与 `Script/` 重复，无法从路径判断代码域；
2. 同一领域逻辑散落在 `Scene/other_scene/` 等多个场景目录，重构时需同时移动场景资源与脚本；
3. `naming_standard.md` 只规定 `Scene/` 子目录为 `snake_case`，未明确禁止 `.gd`，无法用门禁阻止新增。

`source/Scene/` 下 56 个 `.gd` 全部为 `snake_case` 且无同名冲突；迁移不改变脚本内容、节点路径或业务行为，只改变 `res://` 路径与引用。

## 2. 决策

1. **职责分离**：`source/Scene/` 只承载 `.tscn`、`.tres` 与场景资源；`source/Script/` 承载全部 GDScript。
2. **落位规则**：所有 `.gd` 必须位于 `source/Script/<domain>/`；`Scene/` 下不得新增 `.gd`。
3. **例外为零**：不保留 `Scene/**/*.gd` 白名单，也不以“脚本与场景同名”为理由保留。`addons/` 第三方插件不受本规则影响，但不得作为规避通道。
4. **迁移范围**：本阶段迁移 `Scene/` 下 56 个 `.gd`；目标路径以 [`scene_script_migration_matrix.md`](../reference/scene_script_migration_matrix.md) 为唯一清单。
5. **引用同步**：迁移只通过 `scripts/rename_path.py` 执行；该工具负责更新 `.tscn` 的 `ext_resource`、脚本内 `res://` 字符串、`.uid`、`project.godot` 与资源引用。禁止手工批量替换路径。
6. **门禁**：Phase 29-4 在 `scripts/naming_audit.py` 增加 `source/Scene/**/*.gd` 报 `ERROR` 的目录规则，并清理因路径变化失效的白名单旧条目；门禁启用前不得再新增 `Scene/` 下 `.gd`。

## 3. 目标域

| 目标目录 | 职责 | 文件数 |
|:---|:---|:---:|
| `Script/runtime/` | 加载、场景流、运行时工厂与自动战斗配置 | 5 |
| `Script/archive_interface/` | 档案/存档界面 | 1 |
| `Script/main_menu/` | 主菜单、地图入口、设置、角色选择与挑战菜单 | 11 |
| `Script/other_menu/` | 公告、帮助、奖励、幻化与通用菜单面板 | 8 |
| `Script/level/` | 关卡信息、结算、评价与星级 | 4 |
| `Script/monster/` | 怪物/血条、受击、Buff、光环与怪物信息提示 | 10 |
| `Script/skill/` | 技能图标、阵法界面与阵法按钮 | 8 |
| `Script/data/` | 静态数据与属性表 | 1 |
| `Script/hittext/` | 连击、提示、击飞等战斗文本 | 7 |
| `Script/hero/` | 角色特效 | 1 |
| **合计** | | **56** |

## 4. 分批

| 批次 | 范围 | 文件数 |
|:---|:---|:---:|
| 29-1 | 加载、启动、用户载入、自动战斗配置与档案按钮 | 5 |
| 29-2 | 菜单、帮助、结算、奖励、阵法、怪物、数据 | 42 |
| 29-3 | 文本表现与角色特效 | 9 |
| 29-4 | 启用 `Scene/**/*.gd` 门禁并清理白名单 | 0 |

每批独立提交；每批后运行 `check_all`、`health_check`、相关关卡/场景探针；全部批次完成后 `Scene/` 下 `.gd` 必须为 0。

## 5. 后果

**收益**

- `Scene/` 与 `Script/` 的职责边界可机械判定；
- 新增脚本按领域落位，不依赖场景外观；
- 迁移由 `rename_path.py` 原子完成，引用同步可审计。

**代价与风险**

- 56 个 `.gd` 的 `res://` 路径变化会触发 `.tscn`、`.tres`、`global.gd`、工厂字符串与 `.uid` 的连锁更新；
- 迁移期间 `Scene/` 与 `Script/` 会短暂并存，搜索与审查需同时覆盖两处；
- 任何遗漏的字符串路径只会在运行期暴露，因此每批必须用对应探针覆盖。

**约束**

- 不改变脚本逻辑、节点名、场景树结构或存档格式；
- 不移动 `.tscn`/`.tres`；
- 不把 `global.gd`、根级脚本或 `addons/` 纳入本决策；
- 迁移后不得新增兼容 facade 或旧路径重定向。

## 6. 备选方案

| 方案 | 结论 |
|:---|:---|
| 保留 `Scene/` 下 `.gd`，仅要求 `snake_case` | 拒绝：目录语义继续重复，门禁无法阻止新增 |
| 按场景目录镜像到 `Script/<scene>/` | 拒绝：把场景拓扑复制到代码层，新增第二套目录约定 |
| 一次性全量迁移 | 拒绝：56 个引用面过大，故障难定位；按领域分批并逐批验证 |
| 只迁移新增脚本，存量不迁 | 拒绝：`Scene/` 永远无法归零，规则与门禁不可执行 |

## 7. 证据

- 文件清单与引用点：[`../reference/scene_script_migration_matrix.md`](../reference/scene_script_migration_matrix.md)
- 路径迁移工具：[`../../scripts/rename_path.py`](../../scripts/rename_path.py)
- 命名与目录规范：[`../standards/naming_standard.md`](../standards/naming_standard.md) §1.2、§1.4
- 当前目录职责：[`../reference/architecture.md`](../reference/architecture.md) §1
- 迁移方法论：[`../guides/migration_playbook.md`](../guides/migration_playbook.md)
