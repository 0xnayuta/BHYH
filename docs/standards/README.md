# 工程规范 (Standards)

本目录保存当前仍生效、约束 `source/` 活跃工程的规范。

已完成、仅用于历史参考的文档不放在这里，应进入 [`../archive/`](../archive/README.md)。

---

## 1. 规范索引

| 文档 | 约束范围 | 主要内容 |
|:---|:---|:---|
| [`naming_standard.md`](naming_standard.md) | 目录、文件、场景树、代码标识符、数据键 | 命名与契约白皮书；命名单一真源与大小写铁律 |
| [`naming_whitelist.md`](naming_whitelist.md) | 机器导出结构、数字 ID 目录与场景 | 冻结白名单；只减不增，新增必须评审登记 |
| [`godot_design_standard.md`](godot_design_standard.md) | 场景、Resource、Autoload、项目结构 | Godot 现代项目设计规则与遗留边界 |
| [`missing_assets_registry.md`](missing_assets_registry.md) | 缺失资产 | 状态、恢复来源与处置记录；不承担命名豁免 |
| [`spriteframes_generation_policy.md`](spriteframes_generation_policy.md) | SpriteFrames 生成 | 默认 FPS、循环命名、speed 语义与校验 |

---

## 2. 效力与边界

1. 本目录是详细规范正文；[`AGENTS.md`](../../AGENTS.md) 只保留摘要，二者冲突时以本目录的详细规则为准，并同步修正摘要。
2. 新增或修改代码、场景、资源前，必须先确认符合相关规范；存量遗留结构按各文档的“遗留例外”处理，不因历史原因新增豁免。
3. `naming_whitelist.md` 是唯一允许的命名例外登记处；`missing_assets_registry.md` 只回答资产是否恢复/清理，不构成命名豁免。
4. Godot 官方规范优先；项目级偏离必须被明确记录，不得以口头约定代替。
5. 规范不是历史档案；已完成阶段的决策记录应归档到 [`../archive/`](../archive/README.md)。

---

## 3. 新增与修订流程

1. 修改对应规范正文，写清适用范围、约束强度与遗留例外；
2. 同步更新 `AGENTS.md` 摘要、[`../README.md`](../README.md) 索引和本页；
3. 如涉及命名例外，同步更新 `naming_whitelist.md` 与 `scripts/contract_whitelist.json`；
4. 如涉及资产恢复，更新 `missing_assets_registry.md`；
5. 修改后运行相应门禁，确保规范、代码与报告一致。

---

## 4. 校验入口

```bash
python scripts/check_all.py --skip-engine
python scripts/naming_audit.py --root source --all
python scripts/naming_compliance_audit.py --fail-on-error
python scripts/resource_path_audit.py --project source
python scripts/whitelist_audit.py --fail-on-error
python scripts/convert_atlas_metadata.py --check
```

完整引擎与关卡验证见 [`../reference/status.md`](../reference/status.md)。

---

## 5. 归档

规范被替代或不再生效时：

1. 移入 [`../archive/`](../archive/README.md)；
2. 在归档索引登记；
3. 从本页和活跃文档索引移除；
4. 更新所有相对链接并执行链接检查。

归档后原则上只读；如需修订，先明确恢复为活跃规范。
