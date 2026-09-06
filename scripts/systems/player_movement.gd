## player_movement.gd
## 职责：玩家角色移动控制 — WASD/方向键，支持碰撞和场景出口检测
## 依赖：GameManager, TimeManager
class_name PlayerMovement
extends CharacterBody2D

## 移动参数
@export var move_speed: float = 200.0  ## 像素/秒

## 输入方向
var _input_dir: Vector2 = Vector2.ZERO

## 出口区域引用
@onready var exit_hint: Label = $"../ExitHint"
var _near_exit: bool = false

func _ready() -> void:
	print("[PlayerMovement] 就绪，位置: ", position)

func _physics_process(delta: float) -> void:
	## 读取输入
	_input_dir = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	).normalized()
	
	## 移动
	if _input_dir != Vector2.ZERO:
		velocity = _input_dir * move_speed
		move_and_slide()
		## 能量消耗（每帧）
		# StatsManager.change_stat("energy", -0.01)
	else:
		velocity = Vector2.ZERO
	
	## 出口交互提示
	if _near_exit and Input.is_action_just_pressed("ui_accept"):
		_change_location()

## 离开场景时恢复精力
func _exit_tree() -> void:
	pass  ## TODO: 睡眠恢复逻辑

## 场景切换
func _change_location() -> void:
	## TODO: 从 locations.json 读取下一个 loc_id
	print("[PlayerMovement] 切换到走廊...")
	GameManager.change_location("loc_corridor")
	## 消耗精力
	StatsManager.change_stat("energy", -5.0)

## 出口区域检测
func _on_exit_area_body_entered(_body: Node2D) -> void:
	_near_exit = true
	if exit_hint:
		exit_hint.visible = true
	print("[PlayerMovement] 进入出口区域")

func _on_exit_area_body_exited(_body: Node2D) -> void:
	_near_exit = false
	if exit_hint:
		exit_hint.visible = false
	print("[PlayerMovement] 离开出口区域")
