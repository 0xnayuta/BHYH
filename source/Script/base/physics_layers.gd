class_name PhysicsLayers
extends RefCounted

## 2D 物理层位值契约（Phase 31-0A）。
##
## 位值与 `project.godot` 的 `layer_2d_physics/layer_N` 名称一一对应：
## 位值 = 1 << (N - 1)。只登记脚本中实际使用的层，未使用的层不在此预定义。

## 不使用任何物理层（Area2D 仅做查询方或纯逻辑占位）。
const NONE := 0
## 层 1「环境」。
const ENVIRONMENT := 1
## 层 2「角色」：角色攻击判定所在层。
const CHARACTER := 2
## 层 3「怪物」：怪物本体与怪物攻击判定所在层。
const MONSTER := 4
## 层 5「出口」：出口触发区；关卡 GreenDetector 沿用同一层位。
const EXIT := 16
## 层 5 机关查询位：与出口共用；供角色近战命中可交互机关。
const MECHANISM := EXIT
## 层 6「台阶」：屏幕挡板与平台段。
const STEP := 32
