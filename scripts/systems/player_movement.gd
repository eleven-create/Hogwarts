## player_movement.gd
## 职责：玩家角色移动 + 场景出口切换 + NPC/事件互动
## 设计：所有 Area2D 名为 "ExitArea_*"，NPC 也是 Area2D
## 依赖：GameManager, DataLoader, StatsManager, DialogueManager, EventManager
extends CharacterBody2D

## 移动参数
@export var move_speed: float = 200.0

## 输入方向
var _input_dir: Vector2 = Vector2.ZERO

## 当前接近的出口
var _near_exit: Area2D = null

## 所有出口字典：Area2D -> 目标 loc_id（启动时自动扫描）
var _exit_targets: Dictionary = {}

## 当前接近的 NPC（按 E 互动）
var _near_npc: Area2D = null

## 顶部提示文字引用（自动发现）
@onready var exit_hint: Label = get_node_or_null("../ExitHint")

func _ready() -> void:
	add_to_group("player")
	print("[PlayerMovement] 就绪，位置: ", position)
	_scan_exits()
	_scan_npcs()
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

	## 出口/NPC 交互
	if Input.is_action_just_pressed("ui_accept"):
		if _near_npc != null:
			_interact_npc()
		elif _near_exit != null:
			_change_location()

## 扫描所有 ExitArea 子节点
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

## 扫描所有 NPC 子节点（同时是 Area2D 且有 npc.gd 脚本）
func _scan_npcs() -> void:
	var parent: Node = get_parent()
	if parent == null:
		return
	for child in parent.get_children():
		if child is Area2D and child.has_method("try_interact"):
			child.body_entered.connect(_on_npc_entered.bind(child))
			child.body_exited.connect(_on_npc_exited.bind(child))
			print("[PlayerMovement] 注册 NPC: ", child.name)

## 触发 NPC 交互
func _interact_npc() -> void:
	if _near_npc == null:
		return
	# 如果正在对话，E 键用于推进
	if DialogueManager.is_dialogue_running():
		DialogueManager.continue_dialogue()
		return
	var triggered: bool = _near_npc.try_interact()
	if triggered:
		print("[PlayerMovement] 互动 NPC: ", _near_npc.name)

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

func _on_exit_entered(body: Node, area: Area2D) -> void:
	if body != self:
		return
	_near_exit = area
	var target_loc: String = _exit_targets.get(area, "")
	if exit_hint and target_loc != "":
		var loc: Dictionary = DataLoader.get_location(target_loc)
		var loc_name: String = loc.get("loc_id", "未知地点")
		# 走 i18n
		if loc.has("name_key"):
			loc_name = tr(loc["name_key"])
		exit_hint.text = "[E] 前往 " + loc_name
		exit_hint.visible = true

func _on_exit_exited(body: Node, area: Area2D) -> void:
	if body != self:
		return
	if _near_exit == area:
		_near_exit = null
		_hide_hint()

func _on_npc_entered(body: Node, area: Area2D) -> void:
	if body != self:
		return
	_near_npc = area
	# 优先级：对话中不进 NPC 提示
	if DialogueManager.is_dialogue_running():
		return
	if exit_hint:
		var npc_label: Label = area.get_node_or_null("BodyHint")
		var name_str: String = npc_label.text if npc_label else area.name
		exit_hint.text = "[E] 与 " + name_str + " 交谈"
		exit_hint.visible = true

func _on_npc_exited(body: Node, area: Area2D) -> void:
	if body != self:
		return
	if _near_npc == area:
		_near_npc = null
		# 如果不在出口，隐藏提示
		if _near_exit == null:
			_hide_hint()
		elif exit_hint:
			# 恢复出口提示
			exit_hint.text = "[E] 前往"
			exit_hint.visible = true

func _hide_hint() -> void:
	if exit_hint:
		exit_hint.visible = false

func _on_location_changed(_loc_id: String) -> void:
	await get_tree().process_frame
	position = Vector2(640, 360)
	_near_exit = null
	_near_npc = null
	_hide_hint()
	# 新场景要重新扫描 NPC
	_scan_npcs()
	print("[PlayerMovement] 重置位置到出生点并重扫 NPC")
