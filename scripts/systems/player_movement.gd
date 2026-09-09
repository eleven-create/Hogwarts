## player_movement.gd
## 职责：玩家角色移动控制 + 自动检测场景出口
## 设计：所有 Area2D 名为 "ExitArea_*"，出口检测自动扫描
## 依赖：GameManager, TimeManager, DataLoader, StatsManager
## 注意：不在此处定义 class_name（4.7 严格检查后保留）
extends CharacterBody2D

## 移动参数
@export var move_speed: float = 200.0

## 输入方向
var _input_dir: Vector2 = Vector2.ZERO

## 当前接近的出口
var _near_exit: Area2D = null
var _near_object: Node2D = null

## 所有出口字典：Area2D -> 目标 loc_id（启动时自动扫描）
var _exit_targets: Dictionary = {}

## 顶部提示文字引用（自动发现）
@onready var exit_hint: Label = get_node_or_null("../ExitHint")

func _ready() -> void:
	print("[PlayerMovement] 就绪，位置: ", position)
	_scan_exits()
	GameManager.location_changed.connect(_on_location_changed)

func _physics_process(_delta: float) -> void:
	_input_dir = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	).normalized()

	if _input_dir != Vector2.ZERO:
		velocity = _input_dir * move_speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO

	position = position.clamp(Vector2(105, 45), Vector2(1175, 685))
	queue_redraw()

	## 出口交互提示
	if _near_exit != null and Input.is_action_just_pressed("ui_accept"):
		_change_location()
	elif _near_object != null and Input.is_action_just_pressed("ui_accept"):
		_interact_object()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_E:
		if _near_exit != null:
			get_viewport().set_input_as_handled()
			_change_location()
		elif _near_object != null:
			get_viewport().set_input_as_handled()
			_interact_object()

## 临时原创像素角色；脚底是碰撞和地图定位锚点。
func _draw() -> void:
	draw_rect(Rect2(-14, -4, 28, 6), Color(0.1, 0.1, 0.16, 0.4))
	var step: float = 2.0 if velocity.length() > 0 and Time.get_ticks_msec() % 400 < 200 else 0.0
	draw_rect(Rect2(-9, -10 - step, 6, 10), Color("#292737"))
	draw_rect(Rect2(3, -10 + step, 6, 10), Color("#292737"))
	draw_rect(Rect2(-12, -29, 24, 21), Color("#384b69"))
	draw_rect(Rect2(-4, -28, 8, 18), Color("#c2996a"))
	draw_rect(Rect2(-9, -44, 18, 17), Color("#e1b58f"))
	draw_rect(Rect2(-10, -47, 20, 7), Color("#493640"))
	draw_rect(Rect2(-10, -43, 4, 9), Color("#493640"))
	draw_rect(Rect2(1, -37, 3, 3), Color("#302d3c"))

## 扫描所有 ExitArea 子节点，连接信号
func _scan_exits() -> void:
	var parent: Node = get_parent()
	if parent == null:
		return
	for child in parent.get_children():
		if child is Area2D and String(child.name).begins_with("ExitArea"):
			var target_loc: String = String(child.name).replace("ExitArea_", "")
			_exit_targets[child] = target_loc
			child.body_entered.connect(_on_exit_entered.bind(child))
			child.body_exited.connect(_on_exit_exited.bind(child))
			print("[PlayerMovement] 注册出口: ", child.name, " -> ", target_loc)
	for child in parent.get_children():
		if child.is_in_group("interactable_objects"):
			var area: Area2D = child.get_node_or_null("InteractArea")
			if area:
				area.body_entered.connect(_on_object_entered.bind(child))
				area.body_exited.connect(_on_object_exited.bind(child))

func _change_location() -> void:
	if _near_exit == null:
		return
	var target_loc: String = _exit_targets.get(_near_exit, "")
	if target_loc.is_empty():
		return
	print("[PlayerMovement] 切换到: ", target_loc)
	GameManager.change_location(target_loc)
	StatsManager.change_stat("energy", -5.0)
	_hide_hint()

func _on_exit_entered(body: Node2D, area: Area2D) -> void:
	if body != self:
		return
	_near_exit = area
	var target_loc: String = _exit_targets.get(area, "")
	if exit_hint and target_loc != "":
		exit_hint.text = "E / 空格 / 回车 · 前往出口"
		exit_hint.visible = true
	print("[PlayerMovement] 进入出口区域 -> ", target_loc)

func _on_exit_exited(body: Node2D, area: Area2D) -> void:
	if body != self:
		return
	if _near_exit == area:
		_near_exit = null
		_hide_hint()

func _on_object_entered(body: Node2D, object: Node2D) -> void:
	if body != self:
		return
	_near_object = object
	if exit_hint and _near_exit == null:
		exit_hint.text = "E / 空格 / 回车 · " + object.interact()
		exit_hint.visible = true

func _on_object_exited(body: Node2D, object: Node2D) -> void:
	if body == self and _near_object == object:
		_near_object = null
		if _near_exit == null:
			_hide_hint()

func _interact_object() -> void:
	if _near_object == null:
		return
	print("[PlayerMovement] 互动: ", _near_object.name, " -> ", _near_object.interact())
	if exit_hint:
		exit_hint.text = _near_object.interact()
		exit_hint.visible = true

func _hide_hint() -> void:
	if exit_hint:
		exit_hint.visible = false

func _on_location_changed(_loc_id: String) -> void:
	## 场景切换后，等一帧重置玩家位置
	await get_tree().process_frame
	position = Vector2(640, 400)
	_near_exit = null
	_hide_hint()
	print("[PlayerMovement] 重置位置到出生点")
