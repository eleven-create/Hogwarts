## stats_manager.gd
## 职责：玩家属性读写、经验值升级、属性变化通知
## 依赖：DataLoader
## 属性管理器（Autoload: StatsManager）
## 注意：不在此处定义 class_name，避免与 Autoload 单例同名冲突
extends Node

## 运行时属性值（stat_id -> 当前值）
var _stats: Dictionary = {}
## 经验值（仅 is_experience_based 的属性）
var _experiences: Dictionary = {}
## 升级缓存
var _level_cache: Dictionary = {}

## 信号
signal stat_changed(stat_id: String, old_value: float, new_value: float)
signal stat_level_up(stat_id: String, new_level: int)
signal experience_gained(stat_id: String, amount: int, total: int)

func _ready() -> void:
	print("[StatsManager] 就绪")
	_initialize_stats()

## ---- 初始化 ----

func _initialize_stats() -> void:
	var defs: Array = DataLoader.get_stats_def_data().get("stats", [])
	for def: Dictionary in defs:
		var sid: String = def.get("stat_id", "")
		if sid.is_empty():
			continue
		_stats[sid] = def.get("default", 0)
		_experiences[sid] = 0
		if def.get("is_experience_based", false):
			_level_cache[sid] = 0

## ---- 属性读写 ----

func get_stat(stat_id: String) -> float:
	return _stats.get(stat_id, 0.0)

func get_stat_max(stat_id: String) -> float:
	var def: Dictionary = DataLoader.get_stat_def(stat_id)
	return def.get("max", 100.0)

func set_stat(stat_id: String, value: float) -> void:
	if not _stats.has(stat_id):
		push_warning("[StatsManager] 未定义的属性: " + stat_id)
		return
	var def: Dictionary = DataLoader.get_stat_def(stat_id)
	var min_val: float = def.get("min", 0.0)
	var max_val: float = def.get("max", 100.0)
	var old: float = _stats[stat_id]
	var clamped: float = clampf(value, min_val, max_val)
	_stats[stat_id] = clamped
	stat_changed.emit(stat_id, old, clamped)

func change_stat(stat_id: String, amount: float) -> void:
	var current: float = get_stat(stat_id)
	set_stat(stat_id, current + amount)

## ---- 经验值系统 ----

func get_experience(stat_id: String) -> int:
	return _experiences.get(stat_id, 0)

func add_experience(stat_id: String, amount: int) -> void:
	if not _experiences.has(stat_id):
		return
	var def: Dictionary = DataLoader.get_stat_def(stat_id)
	if not def.get("is_experience_based", false):
		return  ## 非经验升级属性忽略
	
	var exp_needed: int = def.get("exp_to_upgrade", 100)
	_experiences[stat_id] += amount
	var current_exp: int = _experiences[stat_id]
	experience_gained.emit(stat_id, amount, current_exp)
	
	## 检查升级
	while current_exp >= exp_needed:
		current_exp -= exp_needed
		_stats[stat_id] = mini(_stats[stat_id] + 1, int(def.get("max", 100)))
		_level_cache[stat_id] += 1
		stat_changed.emit(stat_id, _stats[stat_id] - 1, _stats[stat_id])
		stat_level_up.emit(stat_id, _level_cache[stat_id])
	
	_experiences[stat_id] = current_exp

## ---- 批量 ----

func get_all_stats() -> Dictionary:
	return _stats.duplicate()

func set_all_stats(data: Dictionary) -> void:
	for k: String in data:
		set_stat(k, data[k])

## ---- 存档兼容 ----

func serialize() -> Dictionary:
	return {
		"stats": _stats.duplicate(),
		"experiences": _experiences.duplicate(),
		"levels": _level_cache.duplicate()
	}

func deserialize(data: Dictionary) -> void:
	_stats = data.get("stats", {})
	_experiences = data.get("experiences", {})
	_level_cache = data.get("levels", {})
