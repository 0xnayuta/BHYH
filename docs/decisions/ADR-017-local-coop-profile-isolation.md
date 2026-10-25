# ADR-017：本地双人使用独立档案实例与槽位路由

- **状态**：Accepted
- **记录日期**：2026-10-25
- **决策生效**：6.8 引入，6.9 扩展共享进度
- **影响范围**：双人模式、数据归属、HUD、面板、存档

## 背景

双人模式需要两个玩家各自拥有等级、属性、技能、装备与宠物，同时共享部分进度（背包、灵魂、炼体、万灵图录、宠物背包）。如果复制 Autoload 或让 2P 复用 1P 单例，会造成数据串槽、伤害/无双归属错误与面板读写错档。

## 决策

1. 不为 2P 新增 Autoload；由 `LocalCoop` 创建独立实例：
   - `secondary_data`：`PlayerDataStore`；
   - `secondary_props`：`BaseRoleProperties`；
   - `secondary_passives`：被动技能；
   - `inputs`：`CoopInput`，自动注册 `p2_*`；
2. 存档格式：`player_data["本地双人"] = {版本, 启用, 2P: profile}`；
3. 共享项：装备/道具/消耗品/宠物背包、被动技能、主线剑阵、灵魂、炼体、万灵图录；
4. 槽位解析顺序：meta → 祖先 `coop_slot` → `owner_hero()` 反射 → 脚本路径前缀 → 默认 1；
5. 2P 打开面板时临时交换数据视图，关闭后恢复；存档前先挂起视图再抓快照；
6. 伤害/无双/吸血/宠物归属必须解析实际出手者，不能默认取 1P；
7. 双人模式下只有全部玩家死亡才进入失败。

## 后果

- 1P/2P 数据隔离，共享项按显式规则合并；
- 新增/重构业务代码必须使用槽位感知入口，不能假定 `/root/PlayerData` 是当前操作者；
- `LocalCoop` 与 `BaseHero`/`BaseLevel`/`MemoryClass` 形成关键耦合，需要双人探针覆盖；
- 面板视图交换属于高风险路径，修改时必须验证关闭、暂停与场景切换。

## 备选方案

| 方案 | 未采用原因 |
|:---|:---|
| 复制 `PlayerData` Autoload 为 `PlayerData2` | Autoload 数量与初始化顺序失控，引用需全量分叉 |
| 2P 复用 1P 单例 | 数据串槽，伤害/面板归属错误 |
| 2P 只做“影子角色”不存档 | 无法支持独立装备/技能/宠物配置 |

## 证据

- [`../../source/Script/coop/local_coop.gd`](../../source/Script/coop/local_coop.gd)
- [`../../source/Script/base/base_object.gd`](../../source/Script/base/base_object.gd) 槽位感知属性
- [`../reference/architecture.md`](../reference/architecture.md) §5.4
- 提交 `4679269`：修正 P2 无双与伤害归属
- [`../reference/status.md`](../reference/status.md) 双人探针基线
