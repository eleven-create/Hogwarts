## dialogue_manager.gd
## 职责：Ink 剧情桥接 —— 加载 Ink、注册外部函数、驱动对话、序列化状态
## 依赖：DataLoader, StatsManager, RelationManager, FlagManager, EventManager
## 对话管理器（Autoload: DialogueManager）
## 注意：不在此处定义 class_name，避免与 Autoload 单例同名冲突
extends Node

## Ink 运行状态
var _current_knot: String = ""
var _is_running: bool = false
## 预留：Ink 运行时对象（待 Godot Ink 插件接入）
var _story: Object = null

## 信号
signal dialogue_started(knot: String)
## 以下信号供未来 DialogueUI 监听使用（公开 API），目前无人连接
@warning_ignore("unused_signal")
signal dialogue_line(line: String, speaker: String)
@warning_ignore("unused_signal")
signal dialogue_choices(choices: Array[String])
signal dialogue_finished(event_id: String)
signal ink_state_changed(state: String)

func _ready() -> void:
	print("[DialogueManager] 就绪")
	_register_external_functions()

## ---- 外部函数注册（Ink 调用的接口）----

func _register_external_functions() -> void:
	## TODO: 在这里注册所有 Ink EXTERNAL 函数
	## 示例：_story.bind_external_function("get_stat", _on_get_stat, [])
	pass

## ---- Ink 生命周期 ----

func start_dialogue(ink_knot: String, _event_id: String = "") -> void:
	if _is_running:
		push_warning("[DialogueManager] 对话已在运行中")
		return
	_current_knot = ink_knot
	_is_running = true
	dialogue_started.emit(ink_knot)
	## TODO: 加载 ink_knot 并开始运行
	## TODO: 设置 event_id 便于完成后回调 EventManager.complete_event()

func continue_dialogue() -> void:
	if not _is_running:
		return
	## TODO: 获取下一行文本，触发 dialogue_line 或 dialogue_choices

func select_choice(_choice_index: int) -> void:
	if not _is_running:
		return
	## TODO: 将玩家选择传给 Ink 运行时

func end_dialogue() -> void:
	_is_running = false
	_current_knot = ""
	dialogue_finished.emit("")
	ink_state_changed.emit(get_ink_state())

## ---- Ink 外部函数实现（注册到 Ink 运行时）----

func _on_get_stat(stat_id: String) -> float:
	return StatsManager.get_stat(stat_id)

func _on_change_stat(stat_id: String, amount: float) -> void:
	StatsManager.change_stat(stat_id, amount)

func _on_change_affection(char_id: String, amount: int) -> void:
	RelationManager.change_affection(char_id, amount)

func _on_set_flag(flag_id: String, value: Variant) -> void:
	FlagManager.set_flag(flag_id, value)

func _on_get_flag(flag_id: String) -> Variant:
	return FlagManager.get_flag(flag_id)

## ---- 状态序列化（存档用）----

func get_ink_state() -> String:
	## TODO: 返回当前 Ink 状态的序列化字符串
	return ""

func set_ink_state(_state: String) -> void:
	## TODO: 从序列化字符串恢复 Ink 状态
	pass

## ---- 工具 ----

func is_dialogue_running() -> bool:
	return _is_running

func get_current_knot() -> String:
	return _current_knot
