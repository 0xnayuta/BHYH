# 全工程命名例外登记

> 本页只说明例外类别、理由与审批条件，不复制逐项路径名单、计数或复验结果。实际豁免以 `scripts/contract_whitelist.json` 中冻结的精确集合为准。

## 1. 允许的例外类型

| 类型 | 有限范围 | 技术理由 | 机器登记位置 |
|:---|:---|:---|:---|
| 数字 ID 目录 | 动态资源路径模板下的精确目录 | 运行时按资源 ID 拼接，改名会破坏路径 | `naming.numeric_directory_prefixes` 与 `naming.numeric_directories` |
| 机器导出结构 | Flash、TexturePacker 等生成的精确目录 | 名称与上游格式或导出引用绑定 | `naming.machine_export_directories` |
| 数字 ID 场景 | `Scene/mount/rider_adjustments/role<1..6>/<mount_id>.tscn` 内登记场景 | 文件名是策划坐骑 ID，由运行时按角色和 ID 拼接 | 顶层 `numeric_scene_allowlist` 与 `naming.numeric_scene_files` |
| 第三方插件路径 | `source/addons/` 内已登记的上游路径 | 名称和内部引用由第三方版本控制 | `naming.third_party_prefixes`、`scripts/contract_whitelist.json` 的 `suppressed_files` |
| 字面量、扩展方法、未解析节点模式 | 仅限扫描器无法静态判定的登记项 | 说明静态分析边界，不豁免真实资源或新增深层业务路径 | 顶层 `suppressed_literals`、`known_extension_methods`、`unresolved_node_patterns` |
| 同名 Autoload 桥接属性 | `PlayerData`、`RoleProp`、`PlayerInput`，仅限登记继承上下文 | 为槽位感知 getter 保留兼容 Autoload 拼写 | `scripts/naming_compliance_audit.py` 内部规则 |

这些类别不是前缀豁免；机器导出名字或动态目录模板不能单独放行具体路径。缺失资源由 [`missing_assets_registry.md`](missing_assets_registry.md) 登记，不构成命名豁免。

## 2. 冻结与审批

1. 白名单只减不增。新增项须证明属于 §1 的有限类别，给出最窄路径/符号、技术理由、源码/资源依据和可复核退出条件。
2. 数字目录/场景须证明运行时按 ID 拼接且改名会破坏有效路径；机器导出/第三方路径须证明上游格式约束；静态分析豁免须指出精确分析盲区。
3. 新增需评审并同时登记在 `scripts/contract_whitelist.json`，更新其冻结摘要。已失效项也必须删除，不能保留“以后可能用”的条目。
4. 规则只按 JSON 登记的精确路径、字面量、方法或受限模式匹配；禁止相似名称、宽泛前缀或通配符自动放行普通业务。

## 3. 核查

- 冻结集合以 [`scripts/contract_whitelist.json`](../../scripts/contract_whitelist.json) 为机器事实源。
- 命名及白名单门禁的命令、调用关系和通过判据见 [`../reference/acceptance.md`](../reference/acceptance.md) 与 [`../../scripts/README.md`](../../scripts/README.md)。