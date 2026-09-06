## flag_manager.gd
## 职责：剧情 flag 存储与查询（剧情分支、事件完成标记）
## 依赖：无
## 标志位管理器（Autoload: FlagManager）
## 注意：不在此处定义 class_name，避免与 Autoload 单例同名冲突
extends Node

## 运行时 flag（flag_id -> bool/数值）
var _flags: Dictionary = {}

## 信号
signal flag_changed(flag_id: String, value: Variant)
signal flag_set(flag_id: String, value: Variant)
signal flag_deleted(flag_id: String)

func _ready() -> void:
	print("[FlagManager] 就绪")

## ---- 基础操作 ----

func get_flag(flag_id: String, default_value: Variant = false) -> Variant:
	return _flags.get(flag_id, default_value)

func set_flag(flag_id: String, value: Variant) -> void:
	var old: Variant = _flags.get(flag_id)
	if old == value:
		return
	_flags[flag_id] = value
	flag_changed.emit(flag_id, value)
	flag_set.emit(flag_id, value)

func delete_flag(flag_id: String) -> void:
	if _flags.has(flag_id):
		_flags.erase(flag_id)
		flag_deleted.emit(flag_id)

func clear_all_flags() -> void:
	_flags.clear()

## ---- 便捷封装 ----

func is_flag_true(flag_id: String) -> bool:
	return get_flag(flag_id, false) == true

func toggle_flag(flag_id: String) -> void:
	var current: bool = is_flag_true(flag_id)
	set_flag(flag_id, not current)

## ---- 条件检查（供 EventManager 调用）----

func check_conditions(conditions: Array) -> bool:
	## conditions 格式: [{"flag": "xxx", "value": true}, {"stat": "xxx", "op": ">=", "value": 30}]
	for cond: Dictionary in conditions:
		if cond.has("flag"):
			if get_flag(cond["flag"], cond.get("default_value", false)) != cond.get("value"):
				return false
		## stat 条件由 StatsManager 处理，这里不做处理
	return true

## ---- 批量 ----

func get_all_flags() -> Dictionary:
	return _flags.duplicate()

func import_flags(data: Dictionary) -> void:
	for k: String in data:
		_flags[k] = data[k]

## ---- 存档兼容 ----

func serialize() -> Dictionary:
	return {"flags": _flags.duplicate()}

func deserialize(data: Dictionary) -> void:
	_flags = data.get("flags", {})
