# UI 操作者、生命周期与未闭合写入风险

> **职责**：只记录面板如何选择操作者、谁负责开关/关闭，以及尚无可靠操作级提交/回滚的面板风险。宠物命令边界见 [`pet_domain_contract.md`](pet_domain_contract.md)，档案身份/共享键见 [`archive_session_matrix.md`](archive_session_matrix.md)，总体 UI/HUD 结构见 [`architecture.md`](architecture.md) §7。

## 操作者与守卫范围

- 协作面板由 `CoopPanelHost` 创建 `CanvasLayer` 并在面板根和图层携带 `coop_slot`；`LocalCoop.data_for/props_for` 按显式槽位、祖先/持有者和 `ui_slot` 解析数据/属性。新面板须声明槽位感知的 `PlayerData: PlayerDataStore` / `RoleProp: BaseRoleProperties`，不把默认 1P 视图当操作对象。
- `CoopPanelHost.open_panel()` 在快照生成期间检查 `MemoryClass.is_save_snapshot_in_progress()` 并拒绝打开；`switch_panel()` 的 `_switch_panel()` 没有对应显式检查，不应将该守卫描述为“阻止所有打开和切换”。
- 面板打开时宿主记录既有暂停态、暂停场景、压入窗口栈并创建槽位选择器。用户关闭通过面板 `tree_exited` 清图层/窗口、恢复暂停与槽位、刷新共享视图并请求 `coop_panel_close` 保存；保存失败只给可见反馈，不恢复该面板已做的操作。槽位切换会直接替换实例，不触发关闭保存。
- 宿主 `clear()` 用于会话重置/场景变化，断开关闭回调并释放面板，不走用户关闭保存。主菜单单人面板（例如 `map_0` 的坐骑页）由地图持有，不自动获得 `CoopPanelHost` 的关闭保存。
- `role_information_hud` 统一处理 ESC：先关闭协作宿主，再遍历当前 HUD 窗口的最上层子节点调用 `request_escape_close()`，最后关闭窗口；没有窗口时才打开设置。面板不得自建竞争的全局 ESC 规则。
- 静态 `panel_operator` 检查覆盖 `Script/back_pack/`、`skill/`、`pet/`、`mount/`、`ldl/`，沿继承链检查操作者属性。`hud_panel_boundary` 的覆盖集合不同：背包、技能、LDL 目录及若干具名 HUD/宠物/坐骑文件；部分遗留文件整文件豁免字典写检查、宠物/合成有逐行例外，但档案 IO 禁令仍检查。精确范围和白名单以 `scripts/contract_scan.py` 为准。

## 尚未闭合的面板写入

| 面板/操作 | 当前失败边界 |
|:---|:---|
| 宠物技能学习/升级 | 直接扣技能书/灵魂并改宠物技能，之后调用 `_save_pet_changes()`；忽略失败结果且不恢复操作快照，界面仍可能显示成功。喂养/资质/潜力和部分强化点操作也直接改档，有些只等后续/关闭保存。 |
| 宠物装备/出售 | 直接改共享宠物背包/装备及灵魂，随后请求关闭式保存；保存失败不回滚，仍显示操作结果。仅 View/Command 契约覆盖的命令不属于此风险。 |
| 法宝强化/五行/成长率 | 操作直接改档并消耗灵魂/材料；强化保存结果不驱动回滚，五行/成长率处理也没有统一的操作级保存结果。 |
| 坐骑 | 解锁/强化/资质方法直接消费材料/灵魂并改坐骑状态。`_train_mount`、一键升级和资质操作无操作级保存/回滚；单人地图页关闭也不经协作宿主保存。后续地图保存可能持久化，不是本操作的原子提交保证。 |
| LDL 一键合成、分解、镶嵌 | 一键合成逐项扣材料，部分扣除失败不恢复此前扣除，保存结果被忽略且仍提示成功；分解/镶嵌使用临时列表、关闭归还/恢复及普通保存，未形成覆盖所有路径的单次快照事务。强化、打造、神铸及普通合成已有局部快照回滚，不代表整个 LDL 面板已原子化。 |
| 协作背包昵称 | 直接写所选槽位；持久化依赖宿主关闭保存，关闭保存失败没有昵称级回滚。 |

`LevelInfo` 与 `MonsterHeadInfo` 是只读展示，不属于协作面板；若需显示操作者专属数据，应显式解析槽位，不读取可交换的全局视图。守卫验收范围见 [`acceptance.md`](acceptance.md) §4；Phase 24 历史实施记录见 [`../archive/iteration_24_ui_growth_boundaries.md`](../archive/iteration_24_ui_growth_boundaries.md)。