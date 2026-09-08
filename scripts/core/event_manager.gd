## event_manager.gd
## 职责：事件触发判定、事件队列管理
## 依赖：DataLoader, FlagManager, StatsManager, TimeManager
## 事件管理器（Autoload: EventManager）
## 注意：不在此处定义 class_name，避免与 Autoload 单例同名冲突
extends Node

## 事件队列
var _active_events: Array[Dictionary] = []
var _event_history: Array[String] = []  ## 已完成事件记录

## 信号
signal event_triggered(event_id: String)
signal event_completed(event_id: String)
signal event_queue_updated(queue_size: int)

func _ready() -> void:
	print("[EventManager] 就绪")

## ---- 事件触发判定 ----

func check_events_for_location(loc_id: String) -> Array[Dictionary]:
	## 检查当前位置可以触发的事件
	var available: Array[Dictionary] = []
	var events: Array = DataLoader.get_events_data().get("events", [])
	for evt: Dictionary in events:
		if not _check_trigger(evt):
			continue
		if evt.get("repeatable", false) == false and _event_history.has(evt.get("event_id")):
			continue
		var trigger: Dictionary = evt.get("trigger", {})
		if trigger.get("location") == loc_id or trigger.get("location") == null:
			available.append(evt)
	
	## 按优先级排序
	available.sort_custom(func(a, b): return a.get("priority", 0) > b.get("priority", 0))
	return available

func _check_trigger(evt: Dictionary) -> bool:
	var trigger: Dictionary = evt.get("trigger", {})
	var conditions: Array = trigger.get("conditions", [])
	if not conditions.is_empty():
		if not FlagManager.check_conditions(conditions):
			return false
		if not _check_stat_conditions(conditions):
			return false
	return true

func _check_stat_conditions(conditions: Array) -> bool:
	for cond: Dictionary in conditions:
		if cond.has("time_slot"):
			var slot_name: String = cond.get("time_slot", "").to_lower()
			var current: String = TimeManager.get_current_time_slot_name().to_lower()
			if slot_name != current:
				return false
		if cond.has("stat"):
			var stat_id: String = cond.get("stat", "")
			var op: String = cond.get("op", ">=")
			var value: float = float(cond.get("value", 0))
			var current_val: float = StatsManager.get_stat(stat_id)
			match op:
				">=": if not (current_val >= value): return false
				"<=": if not (current_val <= value): return false
				"==": if not (current_val == value): return false
				">":  if not (current_val > value): return false
				"<":  if not (current_val < value): return false
	return true

## ---- 事件队列操作 ----

func enqueue_event(event_id: String) -> void:
	var evt: Dictionary = DataLoader.get_event(event_id)
	if evt.is_empty():
		push_warning("[EventManager] 事件不存在: " + event_id)
		return
	if not _active_events.any(func(e): return e.get("event_id") == event_id):
		_active_events.append(evt)
		event_queue_updated.emit(_active_events.size())

func dequeue_event(event_id: String) -> void:
	_active_events = _active_events.filter(func(e): return e.get("event_id") != event_id)
	event_queue_updated.emit(_active_events.size())

func get_next_event() -> Dictionary:
	if _active_events.is_empty():
		return {}
	return _active_events[0]

func start_event(event_id: String) -> void:
	event_triggered.emit(event_id)
	var evt: Dictionary = DataLoader.get_event(event_id)
	if evt.is_empty():
		push_warning("[EventManager] 找不到事件: " + event_id)
		return
	var ink_knot: String = evt.get("ink_knot", "")
	if ink_knot.is_empty():
		push_warning("[EventManager] 事件 %s 缺少 ink_knot" % event_id)
		return
	# 委托 DialogueManager 启动 ink
	if DialogueManager:
		DialogueManager.start_story_from_file(ink_knot, event_id)

## 由玩家/NPC 主动触发事件（绕过位置/条件检查）
func trigger_event(event_id: String) -> void:
	print("[EventManager] 手动触发: ", event_id)
	start_event(event_id)

func complete_event(event_id: String) -> void:
	_event_history.append(event_id)
	dequeue_event(event_id)
	event_completed.emit(event_id)

func clear_all_events() -> void:
	_active_events.clear()
	_event_history.clear()
	print("[EventManager] 已重置所有事件状态")

## ---- 查询 ----

func is_event_completed(event_id: String) -> bool:
	return _event_history.has(event_id)

func get_completed_events() -> Array[String]:
	return _event_history.duplicate()

func get_available_event_ids() -> Array[String]:
	var result: Array[String] = []
	for e: Dictionary in check_events_for_location(GameManager.current_location):
		result.append(e.get("event_id"))
	return result

## ---- 存档兼容 ----

func serialize() -> Dictionary:
	return {
		"history": _event_history.duplicate(),
		"active": _active_events.map(func(e): return e.get("event_id"))
	}

func deserialize(data: Dictionary) -> void:
	_event_history = data.get("history", [])
	## TODO: 重新构建 active 事件队列
