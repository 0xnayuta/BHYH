# 全工程命名白名单与冻结登记 (Naming Whitelist Registry)

> **版本**：v2.1.2（BHYH 单工程结构适配；白名单条目不变）
>
> **维护规则**：白名单只减不增；新增条目必须经评审并在此登记理由与代码依据。
>
> **机器门禁**：`scripts/naming_audit.py`（Godot 官方 `snake_case` 规则 + 精确登记表白名单，`--all` 全量）；`scripts/naming_compliance_audit.py`（全量终审）；`scripts/whitelist_audit.py`（冻结摘要与未登记项）；`scripts/contract_scan.py`（字面量契约）。

---

## 0. 当前基线

- numeric 目录 **188 / 188** 全部为纯数字，全部位于 6 个动态拼接路径模板下；
- 机器导出结构 **120 / 120** 按 4 类复核（`DefineSprite_*` 72、`*.sprites` 34、`symbolClass` 11、`*-assets` 3）；
- numeric 场景 **48 / 48** 存在且由 `mount_runtime.gd` 动态拼接加载；
- `contract_whitelist.json` 缺失资源白名单 **0 条**（见 §2.3）；
- 复验：`python scripts/whitelist_audit.py --fail-on-error` 0 错误；`naming_audit.py --all` 目录维度 2,404 个 0 违规；负向测试拦截成功。

---

## 1. 目录白名单

### 1.1 numeric 动态拼接白名单（188 个 · 永不改名）

**判定依据**：目录名为纯数字，且位于运行时按资源 ID 拼接的路径模板下。任何改名都会导致 `load()` / `FileAccess` 路径断裂。

#### `monster/swf_png/`（83 个）

- **代码依据**：怪物图集（Bulk Registry / `MONSTER_ROOT + "/%d"` 动态回退）
- **完整清单**：

```text
monster/swf_png/3001  monster/swf_png/3002  monster/swf_png/3003  monster/swf_png/3004
monster/swf_png/3005  monster/swf_png/3006  monster/swf_png/3007  monster/swf_png/3008
monster/swf_png/3009  monster/swf_png/3010  monster/swf_png/3011  monster/swf_png/3012
monster/swf_png/3019  monster/swf_png/3020  monster/swf_png/3021  monster/swf_png/3028
monster/swf_png/3029  monster/swf_png/3030  monster/swf_png/3031  monster/swf_png/3032
monster/swf_png/3033  monster/swf_png/3034  monster/swf_png/3035  monster/swf_png/3036
monster/swf_png/3037  monster/swf_png/3038  monster/swf_png/3039  monster/swf_png/3040
monster/swf_png/3041  monster/swf_png/3042  monster/swf_png/3047  monster/swf_png/3048
monster/swf_png/3049  monster/swf_png/3050  monster/swf_png/3051  monster/swf_png/3056
monster/swf_png/3065  monster/swf_png/3066  monster/swf_png/3067  monster/swf_png/3068
monster/swf_png/3069  monster/swf_png/3070  monster/swf_png/3071  monster/swf_png/3076
monster/swf_png/3077  monster/swf_png/3078  monster/swf_png/3080  monster/swf_png/3081
monster/swf_png/3082  monster/swf_png/3117  monster/swf_png/3118  monster/swf_png/3119
monster/swf_png/3120  monster/swf_png/3121  monster/swf_png/3122  monster/swf_png/3123
monster/swf_png/3125  monster/swf_png/3136  monster/swf_png/3144  monster/swf_png/3159
monster/swf_png/3160  monster/swf_png/3161  monster/swf_png/3172  monster/swf_png/3177
monster/swf_png/3179  monster/swf_png/3181  monster/swf_png/3182  monster/swf_png/3198
monster/swf_png/3199  monster/swf_png/3200  monster/swf_png/3201  monster/swf_png/3222
monster/swf_png/3223  monster/swf_png/3224  monster/swf_png/3225  monster/swf_png/3276
monster/swf_png/3277  monster/swf_png/3308  monster/swf_png/3309  monster/swf_png/3310
monster/swf_png/3311  monster/swf_png/3320  monster/swf_png/3370
```

#### `monster/north_original/`（51 个）

- **代码依据**：北俱芦洲怪物模型（`north_original_data.gd` `%d/manifest.json`）
- **完整清单**：

```text
monster/north_original/3353  monster/north_original/3354  monster/north_original/3355  monster/north_original/3356
monster/north_original/3357  monster/north_original/3361  monster/north_original/3367  monster/north_original/3371
monster/north_original/3372  monster/north_original/3381  monster/north_original/3382  monster/north_original/3383
monster/north_original/3384  monster/north_original/3385  monster/north_original/3399  monster/north_original/3400
monster/north_original/3401  monster/north_original/3402  monster/north_original/3408  monster/north_original/3409
monster/north_original/3410  monster/north_original/3415  monster/north_original/3416  monster/north_original/3417
monster/north_original/3418  monster/north_original/3419  monster/north_original/3420  monster/north_original/3421
monster/north_original/3422  monster/north_original/3423  monster/north_original/3430  monster/north_original/3431
monster/north_original/3481  monster/north_original/3482  monster/north_original/3483  monster/north_original/3484
monster/north_original/3485  monster/north_original/3486  monster/north_original/3487  monster/north_original/3499
monster/north_original/3500  monster/north_original/3501  monster/north_original/3528  monster/north_original/3529
monster/north_original/3530  monster/north_original/3531  monster/north_original/3535  monster/north_original/3536
monster/north_original/3537  monster/north_original/3538  monster/north_original/3539
```

#### `monster/palace_boss/`（2 个）

- **代码依据**：天宫飞行 Boss（`palace_flying_boss.gd` / `global.gd` `%d/manifest.json`）
- **完整清单**：

```text
monster/palace_boss/3323  monster/palace_boss/3343
```

#### `constellations/boss/`（36 个）

- **代码依据**：二十八星宿 Boss（`constellation_boss.gd` `ASSET_ROOT.path_join(str(source_id))`，含 `body/<n>`）
- **完整清单**：

```text
constellations/boss/140  constellations/boss/140/body/3  constellations/boss/141  constellations/boss/142
constellations/boss/142/body/3  constellations/boss/142/body/6  constellations/boss/144  constellations/boss/144/body/3
constellations/boss/145  constellations/boss/146  constellations/boss/146/body/3  constellations/boss/147
constellations/boss/147/body/3  constellations/boss/149  constellations/boss/149/body/3  constellations/boss/150
constellations/boss/150/body/3  constellations/boss/150/body/7  constellations/boss/151  constellations/boss/151/body/3
constellations/boss/151/body/6  constellations/boss/152  constellations/boss/152/body/3  constellations/boss/152/body/7
constellations/boss/156  constellations/boss/156/body/3  constellations/boss/156/body/7  constellations/boss/157
constellations/boss/157/body/3  constellations/boss/158  constellations/boss/158/body/3  constellations/boss/158/body/8
constellations/boss/159  constellations/boss/159/body/3  constellations/boss/162  constellations/boss/162/body/3
```

#### `mount/runtime/mounts/`（8 个）

- **代码依据**：坐骑本体（`mount_visual.gd` `"%s/%s/%s/manifest.json"`）
- **完整清单**：

```text
mount/runtime/mounts/1002200  mount/runtime/mounts/1002700  mount/runtime/mounts/1002800  mount/runtime/mounts/1003100
mount/runtime/mounts/1003500  mount/runtime/mounts/1003600  mount/runtime/mounts/1003900  mount/runtime/mounts/1004700
```

#### `mount/runtime/effects/`（8 个）

- **代码依据**：坐骑技能特效（同上，`EFFECT_RUNTIME_ROOT`）
- **完整清单**：

```text
mount/runtime/effects/1002200  mount/runtime/effects/1002700  mount/runtime/effects/1002800  mount/runtime/effects/1003100
mount/runtime/effects/1003500  mount/runtime/effects/1003600  mount/runtime/effects/1003900  mount/runtime/effects/1004700
```

### 1.2 机器导出结构白名单（120 个 · 永不改名）

| 类别 | 数量 | 豁免理由 |
|:---|:---:|:---|
| `DefineSprite_*` | 72 | Flash 反编译图元/时间轴符号，改名破坏 `.sprites` / atlas 引用 |
| `*.sprites` | 34 | TexturePacker 精灵表目录，内部帧索引与导出工具链绑定 |
| `symbolClass` | 11 | Flash 符号类映射目录 |
| `*-assets` | 3 | Flash/图集导出资源容器 |

**完整清单**：

#### `DefineSprite_*`（72）

```text
monster/cow/third/DefineSprite_Monster24BG
monster/cow/third/DefineSprite_export.monster.Monster23Child.Hands
monster/game_3_monster/monster_1401/DefineSprite_166_Monster118Bullet1
monster/game_3_monster/monster_1404/DefineSprite_213_monster131MusicBuff2
monster/game_3_monster/monster_1404/DefineSprite_217_monster131MusicBuff1
monster/game_3_monster/monster_1404/DefineSprite_258
monster/game_3_monster/monster_1404/DefineSprite_260
monster/game_3_monster/monster_1404/DefineSprite_266
monster/game_3_monster/monster_1404/DefineSprite_271
monster/game_3_monster/monster_1404/DefineSprite_274
monster/game_3_monster/monster_1404/DefineSprite_277
monster/game_3_monster/monster_1404/DefineSprite_281
monster/game_3_monster/monster_1407/DefineSprite_118
monster/game_3_monster/monster_1407/DefineSprite_120
monster/game_3_monster/monster_1407/DefineSprite_126
monster/game_3_monster/monster_1407/DefineSprite_131
monster/game_3_monster/monster_1407/DefineSprite_135
monster/game_3_monster/monster_1407/DefineSprite_139
monster/game_3_monster/monster_1407/DefineSprite_142
monster/game_3_monster/monster_1407/DefineSprite_147
monster/game_3_monster/monster_1408/DefineSprite_120
monster/game_3_monster/monster_1408/DefineSprite_122
monster/game_3_monster/monster_1408/DefineSprite_123
monster/game_3_monster/monster_1408/monster_140801/DefineSprite_272
monster/game_3_monster/monster_1408/monster_140801/DefineSprite_274
monster/game_3_monster/monster_1408/monster_140801/DefineSprite_279
monster/game_3_monster/monster_149/DefineSprite_13_Monster210Bullet2
monster/game_3_monster/monster_149/DefineSprite_49_Monster210Bullet3
monster/game_3_monster/monster_149/DefineSprite_55
monster/game_3_monster/monster_149/DefineSprite_57
monster/game_3_monster/monster_149/DefineSprite_62
monster/game_3_monster/monster_149/DefineSprite_66
monster/game_3_monster/monster_149/DefineSprite_70
monster/game_3_monster/monster_149/DefineSprite_72
monster/game_3_monster/monster_149/DefineSprite_8_Monster210Bullet1
monster/game_3_monster/monster_212/DefineSprite_44_Monster212
monster/game_3_monster/monster_212/DefineSprite_49_Monster212Bullet4_2_Cropped
monster/game_3_monster/monster_212/DefineSprite_66_Monster212Bullet4_1
monster/game_3_monster/monster_212/DefineSprite_71_Monster212Bullet3
monster/game_3_monster/monster_212/DefineSprite_88_Monster212Bullet2
monster/game_3_monster/monster_212/DefineSprite_92_Monster212Bullet1
monster/game_3_monster/monster_212/DefineSprite_92_Monster212Bullet1_Cropped
monster/game_3_monster/monster_215/DefineSprite_14
monster/game_3_monster/monster_215/DefineSprite_16
monster/game_3_monster/monster_215/DefineSprite_23
monster/game_3_monster/monster_215/DefineSprite_27
monster/game_3_monster/monster_215/DefineSprite_32
monster/game_3_monster/monster_215/DefineSprite_37_Monster215Bullet2
monster/game_3_monster/monster_215/DefineSprite_50_Monster215Bullet1
monster/game_3_monster/monster_215/DefineSprite_9
monster/liu_sha_river/effects/role_1_bullet_1/DefineSprite_236_Role1Bullet1
monster/liu_sha_river/effects/role_1_bullet_14_1/DefineSprite_437_Role1Bullet14_1
monster/liu_sha_river/effects/role_1_bullet_14_2/DefineSprite_441_Role1Bullet14_2
monster/liu_sha_river/effects/role_1_bullet_5/DefineSprite_240_Role1Bullet5
monster/liu_sha_river/effects/role_1_bullet_8/DefineSprite_274_Role1Bullet8
monster/swf_png/3012/DefineSprite_13_attack1
monster/swf_png/3012/DefineSprite_15_ab_attack1
monster/swf_png/3012/DefineSprite_19_axeOnFloor
monster/swf_png/3012/DefineSprite_20_walk
monster/swf_png/3012/DefineSprite_21_idle
monster/swf_png/3012/DefineSprite_3
monster/swf_png/3012/DefineSprite_4_dead
zhuxianjianzhen/zhu_xian_sword/sprites/DefineSprite_102
zhuxianjianzhen/zhu_xian_sword/sprites/DefineSprite_103_export.sword.SwordInterface
zhuxianjianzhen/zhu_xian_sword/sprites/DefineSprite_47
zhuxianjianzhen/zhu_xian_sword/sprites/DefineSprite_50_ZhuXianSword_fla.Symbol55_5
zhuxianjianzhen/zhu_xian_sword/sprites/DefineSprite_61
zhuxianjianzhen/zhu_xian_sword/sprites/DefineSprite_75
zhuxianjianzhen/zhu_xian_sword/sprites/DefineSprite_84
zhuxianjianzhen/zhu_xian_sword/sprites/DefineSprite_87
zhuxianjianzhen/zhu_xian_sword/sprites/DefineSprite_96
zhuxianjianzhen/zhu_xian_sword/sprites/DefineSprite_97_export.sword.SwordItem
```

#### `*.sprites`（34）

```text
monster/monster_43/ghost_door_1/GhostDoor_1.sprites
monster/monster_43/ghost_door_2/GhostDoor_2.sprites
monster/monster_43/ghost_door_3/GhostDoor_3.sprites
monster/monster_61_00/bcwbullet/bcwbullet-0.sprites
monster/monster_61_00/bcwbullet/bcwbullet-1.sprites
monster/monster_61_00/dswbullet/dswbullet.sprites
monster/monster_61_00/skill_3_effect/Skill_3Effect.sprites
monster/monster_61_00/skill_3_effect_2/Skill_3Effect2-0.sprites
monster/monster_61_00/skill_3_effect_2/Skill_3Effect2-1.sprites
monster/monster_61_00/skill_3_effect_2/Skill_3Effect2-10.sprites
monster/monster_61_00/skill_3_effect_2/Skill_3Effect2-11.sprites
monster/monster_61_00/skill_3_effect_2/Skill_3Effect2-12.sprites
monster/monster_61_00/skill_3_effect_2/Skill_3Effect2-13.sprites
monster/monster_61_00/skill_3_effect_2/Skill_3Effect2-14.sprites
monster/monster_61_00/skill_3_effect_2/Skill_3Effect2-15.sprites
monster/monster_61_00/skill_3_effect_2/Skill_3Effect2-16.sprites
monster/monster_61_00/skill_3_effect_2/Skill_3Effect2-17.sprites
monster/monster_61_00/skill_3_effect_2/Skill_3Effect2-18.sprites
monster/monster_61_00/skill_3_effect_2/Skill_3Effect2-19.sprites
monster/monster_61_00/skill_3_effect_2/Skill_3Effect2-2.sprites
monster/monster_61_00/skill_3_effect_2/Skill_3Effect2-20.sprites
monster/monster_61_00/skill_3_effect_2/Skill_3Effect2-21.sprites
monster/monster_61_00/skill_3_effect_2/Skill_3Effect2-22.sprites
monster/monster_61_00/skill_3_effect_2/Skill_3Effect2-23.sprites
monster/monster_61_00/skill_3_effect_2/Skill_3Effect2-24.sprites
monster/monster_61_00/skill_3_effect_2/Skill_3Effect2-3.sprites
monster/monster_61_00/skill_3_effect_2/Skill_3Effect2-4.sprites
monster/monster_61_00/skill_3_effect_2/Skill_3Effect2-5.sprites
monster/monster_61_00/skill_3_effect_2/Skill_3Effect2-6.sprites
monster/monster_61_00/skill_3_effect_2/Skill_3Effect2-7.sprites
monster/monster_61_00/skill_3_effect_2/Skill_3Effect2-8.sprites
monster/monster_61_00/skill_3_effect_2/Skill_3Effect2-9.sprites
monster/monster_61_00/tswbullet/tswbullet.sprites
monster/monster_61_00/wgwbullet/wgwbullet.sprites
```

#### `symbolClass`（11）

```text
zhuxianjianzhen/juexianjian/symbolClass
zhuxianjianzhen/luxianjian/symbolClass
zhuxianjianzhen/sijianguiyi/symbolClass
zhuxianjianzhen/sword_hover/sword1/symbolClass
zhuxianjianzhen/sword_hover/sword2/symbolClass
zhuxianjianzhen/sword_hover/sword3/symbolClass
zhuxianjianzhen/sword_hover/sword4/symbolClass
zhuxianjianzhen/sword_hover/sword5/symbolClass
zhuxianjianzhen/xianxianjian/symbolClass
zhuxianjianzhen/zhu_xian_sword/symbolClass
zhuxianjianzhen/zhuxianjian/symbolClass
```

#### `*-assets`（3）

```text
backpack/all_items/empty-assets
level/game_3_level/level_lsh/3-assets
level/game_3_level/level_lsh/9-assets
```

### 1.3 numeric 场景白名单（48 个 · 永不改名）

- **范围**：`Scene/mount/rider_adjustments/role{1..6}/<mount_id>.tscn`
- **代码依据**：`mount_runtime.gd:409`
  ```gdscript
  var pose_path := "%s/role%d/%s.tscn" % [RIDER_ADJUSTMENT_ROOT, role_id, _current_mount_id]
  ```
- **理由**：场景文件名即数值策划的坐骑 ID（`1002200` ~ `1004700`），必须与策划表 `mount_id` 逐字一致。
- **验证**：48 / 48 文件存在；`role1` ~ `role6` 目录为合法 snake_case。

```text
Scene/mount/rider_adjustments/role1/1002200.tscn  Scene/mount/rider_adjustments/role1/1002700.tscn  Scene/mount/rider_adjustments/role1/1002800.tscn  Scene/mount/rider_adjustments/role1/1003100.tscn
Scene/mount/rider_adjustments/role1/1003500.tscn  Scene/mount/rider_adjustments/role1/1003600.tscn  Scene/mount/rider_adjustments/role1/1003900.tscn  Scene/mount/rider_adjustments/role1/1004700.tscn
Scene/mount/rider_adjustments/role2/1002200.tscn  Scene/mount/rider_adjustments/role2/1002700.tscn  Scene/mount/rider_adjustments/role2/1002800.tscn  Scene/mount/rider_adjustments/role2/1003100.tscn
Scene/mount/rider_adjustments/role2/1003500.tscn  Scene/mount/rider_adjustments/role2/1003600.tscn  Scene/mount/rider_adjustments/role2/1003900.tscn  Scene/mount/rider_adjustments/role2/1004700.tscn
Scene/mount/rider_adjustments/role3/1002200.tscn  Scene/mount/rider_adjustments/role3/1002700.tscn  Scene/mount/rider_adjustments/role3/1002800.tscn  Scene/mount/rider_adjustments/role3/1003100.tscn
Scene/mount/rider_adjustments/role3/1003500.tscn  Scene/mount/rider_adjustments/role3/1003600.tscn  Scene/mount/rider_adjustments/role3/1003900.tscn  Scene/mount/rider_adjustments/role3/1004700.tscn
Scene/mount/rider_adjustments/role4/1002200.tscn  Scene/mount/rider_adjustments/role4/1002700.tscn  Scene/mount/rider_adjustments/role4/1002800.tscn  Scene/mount/rider_adjustments/role4/1003100.tscn
Scene/mount/rider_adjustments/role4/1003500.tscn  Scene/mount/rider_adjustments/role4/1003600.tscn  Scene/mount/rider_adjustments/role4/1003900.tscn  Scene/mount/rider_adjustments/role4/1004700.tscn
Scene/mount/rider_adjustments/role5/1002200.tscn  Scene/mount/rider_adjustments/role5/1002700.tscn  Scene/mount/rider_adjustments/role5/1002800.tscn  Scene/mount/rider_adjustments/role5/1003100.tscn
Scene/mount/rider_adjustments/role5/1003500.tscn  Scene/mount/rider_adjustments/role5/1003600.tscn  Scene/mount/rider_adjustments/role5/1003900.tscn  Scene/mount/rider_adjustments/role5/1004700.tscn
Scene/mount/rider_adjustments/role6/1002200.tscn  Scene/mount/rider_adjustments/role6/1002700.tscn  Scene/mount/rider_adjustments/role6/1002800.tscn  Scene/mount/rider_adjustments/role6/1003100.tscn
Scene/mount/rider_adjustments/role6/1003500.tscn  Scene/mount/rider_adjustments/role6/1003600.tscn  Scene/mount/rider_adjustments/role6/1003900.tscn  Scene/mount/rider_adjustments/role6/1004700.tscn
```

---

## 2. 字面量 / 文件 / 契约白名单

### 2.1 字面量豁免（`suppressed_literals`）

| 字面量 | 位置 | 理由 |
|:---|:---|:---|
| `ililillliiillil` | `Scene/other_scene/load_scene.gd:97` | 加密校验器的方法名，非资源路径 |

### 2.2 文件级豁免（`suppressed_files`）

| 路径 | 理由 |
|:---|:---|
| `addons/godot_mcp` | 第三方编辑器通信插件，遵从插件自身命名 |

### 2.3 已知缺失资源白名单（0 条 · 已清空）

- 数据目录 `res://.godot/`、`res://godot/` 已由 `contract_scan.py` 直接排除，无需白名单；
- `nezha/idle/1.png`、`qiong_qi/Effects/BuffGreen.png`、`BuffBlue.png` 已从对应 atlas 页裁切补齐源帧，
  路径真实存在；
- `mp_poision.png`、`csm.wav`、`Level_sxmg.tscn` 的源码引用已移除；
- `missing_asset_known_allowlist` 现为空数组（门禁不再依赖缺失资源豁免）。

### 2.4 反射方法白名单（`known_extension_methods`，14 个）

```text
set_skeleton_data_res, set_skin_by_name, set_slots_to_setup_pose, set_animation, update_world_transform, get_pose, get_attachment, get_color, get_bone, find_bone, find_slot, get_global_transform, get_skeleton, get_animation_state
```

### 2.5 节点路径模式（`unresolved_node_patterns`）

```text
/root/
```

### 2.6 运行时 manifest 冻结名单（`RUNTIME_MANIFEST_FROZEN_ALLOWLIST`，0 个 · 已清零）

当前状态：全部运行时 atlas manifest 读取已迁移到构建期生成的
`AtlasMetadata` 资源，冻结名单清零。`scripts/contract_scan.py` 的
`RUNTIME_MANIFEST_PATTERNS` 对“manifest 标识 + 运行时 IO
（`FileAccess` / `JSON.parse_string`）”组合报 `RUNTIME_MANIFEST_FORBIDDEN`（ERROR），
新增文件一律不得加入豁免。

- 构建期转换器：`scripts/convert_atlas_metadata.py`
  （每个 `manifest.json` 同目录生成 `metadata.tres`，共 379 个；数组型 manifest 包装为
  `{"__top_level": "array", "items": [...]}`）；
- 运行时入口：`Script/atlas/atlas_metadata_store.gd`
  （`AtlasMetadataStore.data_for(path)`，只接受 `metadata.tres` 路径，不再兼容 manifest.json）；
- 已迁移消费者：东胜神洲/北俱芦洲/云 Boss/天宫 Boss/天宫弹道/五台明海弹道/
  诛仙剑阵/剑阵 Boss/坐骑视觉/关卡拉怪预热；
- 已删除：`MonsterAtlasSequence`、`atlas_manifest_registry.json`、
  `monster_bullet.gd` 的 `STREAMED_BULLET_MANIFESTS` 与未使用的流式回退字段；
- 负向自测：`python scripts/contract_scan.py --self-test`（坏样本必须被拦截）；
- 同步校验：`python scripts/convert_atlas_metadata.py --check`。

---

### 2.7 版本化冻结

- `scripts/contract_whitelist.json` 已升级为 `schema_version=2`、`frozen=true`；
- 机器目录白名单改为**精确条目**匹配，不再按 `DefineSprite_*` / 数字前缀通配自动放行；
- 冻结条目：机器导出 120 条、数字 ID 目录 188 条、数字 ID 场景 48 条；
- `scripts/whitelist_audit.py` 校验 `frozen_manifest_sha256`、技术评审记录、
  未登记项与失效项；负向测试已确认未登记 `DefineSprite_*` 目录会被拦截；
- 冻结记录由 `scripts/contract_whitelist.json` 与本文维护；阶段报告不进入仓库。

### 2.8 命名口径修订

- Godot 官方 `Project organization` 规定文件/目录 `snake_case`，`class_name` 与节点 PascalCase；
- 旧白皮书 v1.0.0 的 `.tscn`/`.gd` PascalCase 规则已废弃，改由 `docs/standards/naming_standard.md` v2.1.0 替代；
- 白名单仍按精确路径冻结，**不新增业务文件豁免**；
- `naming_audit.py --all` 与 `naming_compliance_audit.py` 使用同一套 v2.0.0 规则。

## 3. 冻结准则

1. 白名单条目**只减不增**；新增豁免必须同时满足：
   - 属于机器导出结构（`DefineSprite_*` / `symbolClass` / `*.sprites` / `*-assets`）；
   - 或属于运行时按资源 ID 动态拼接的纯数字目录（需给出代码行号）；
   - 或属于第三方插件（`addons/`）；
2. 任何目录改名必须通过 `scripts/rename_path.py`，并在提交信息与变更说明中登记迁移范围与白名单例外；
3. 新增资产由 `scripts/naming_audit.py` 拦截：目录、`.tscn` 场景、`.gd` 脚本与资源文件统一 `snake_case`；`class_name` 使用 PascalCase；
4. 白名单外的非规范目录/文件必须为 **0**；负向测试必须能拦截。

---

## 4. 复核命令

```bash
# 目录与新增资产命名门禁
python scripts/naming_audit.py

# 六维契约扫描（ERROR 必须为 0）
# 运行时 manifest 门禁负向自测
python scripts/contract_scan.py --self-test
python scripts/contract_scan.py --fail-on-error

# 全量门禁
python scripts/check_all.py
```
