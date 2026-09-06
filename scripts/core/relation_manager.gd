## relation_manager.gd
## 职责：好感度管理、角色关系查询
## 依赖：DataLoader
## 关系管理器（Autoload: RelationManager）
## 注意：不在此处定义 class_name，避免与 Autoload 单例同名冲突
extends Node

## 运行时好感度（char_id -> affection 值）
var _affections: Dictionary = {}

## 常量
const MAX_AFFECTION: int = 100
const DEFAULT_AFFECTION: int = 0

## 信号
signal affection_changed(char_id: String, old_value: int, new_value: int)
signal affection_maxed(char_id: String)  ## 好感度满触发某些特殊事件
signal relationship_established(char_id: String, level: int)

## 关系等级阈值
const RELATION_LEVELS: Array[int] = [0, 20, 40, 60, 80, 100]

func _ready() -> void:
	print("[RelationManager] 就绪")

## ---- 好感度操作 ----

func get_affection(char_id: String) -> int:
	if not _affections.has(char_id):
		var char_data: Dictionary = DataLoader.get_character(char_id)
		_affections[char_id] = char_data.get("affection", DEFAULT_AFFECTION)
	return _affections[char_id]

func set_affection(char_id: String, value: int) -> void:
	var clamped: int = clampi(value, 0, MAX_AFFECTION)
	var old: int = get_affection(char_id)
	if old == clamped:
		return
	_affections[char_id] = clamped
	affection_changed.emit(char_id, old, clamped)
	if clamped >= MAX_AFFECTION:
		affection_maxed.emit(char_id)

func change_affection(char_id: String, amount: int) -> void:
	var current: int = get_affection(char_id)
	set_affection(char_id, current + amount)

## ---- 关系等级 ----

func get_relationship_level(char_id: String) -> int:
	var affection: int = get_affection(char_id)
	for i: int in range(RELATION_LEVELS.size() - 1, -1, -1):
		if affection >= RELATION_LEVELS[i]:
			return i
	return 0

func get_relationship_name(char_id: String) -> String:
	var level: int = get_relationship_level(char_id)
	match level:
		0: return "stranger"
		1: return "acquaintance"
		2: return "friend"
		3: return "close_friend"
		4: return "romantic_interest"
		5: return "beloved"
	return "unknown"

## ---- 查询 ----

func get_all_affections() -> Dictionary:
	return _affections.duplicate()

func is_romanceable(char_id: String) -> bool:
	var char_data: Dictionary = DataLoader.get_character(char_id)
	return char_data.get("romanceable", false)

func can_unlock_romance(char_id: String) -> bool:
	return is_romanceable(char_id) and get_relationship_level(char_id) >= 4

## ---- 存档兼容 ----

func serialize() -> Dictionary:
	return {"affections": _affections.duplicate()}

func deserialize(data: Dictionary) -> void:
	_affections = data.get("affections", {})
