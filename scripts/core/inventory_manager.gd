## inventory_manager.gd
## 职责：背包系统 — 物品获取/丢弃/使用，支持堆叠
## 依赖：DataLoader, StatsManager
## 注意：不在此处定义 class_name（4.7 严格检查）
extends Node

## 背包槽位：Array[Dictionary]，每个 Dictionary = {item_id, count}
var _slots: Array[Dictionary] = []

## 背包容量上限
const MAX_SLOTS: int = 20

## 信号
signal item_added(item_id: String, count: int, total_now: int)
signal item_removed(item_id: String, count: int, total_now: int)
signal item_used(item_id: String)
signal inventory_changed()

## ---- 物品操作 ----

## 获取某物品数量
func get_item_count(item_id: String) -> int:
	for slot: Dictionary in _slots:
		if slot.get("item_id") == item_id:
			return slot.get("count", 0)
	return 0

## 获取背包所有物品
func get_all_items() -> Array[Dictionary]:
	return _slots.duplicate()

## 检查是否拥有某物品
func has_item(item_id: String) -> bool:
	return get_item_count(item_id) > 0

## 添加物品（支持堆叠，返回是否成功）
func add_item(item_id: String, count: int = 1) -> bool:
	var def: Dictionary = DataLoader.get_item(item_id)
	if def.is_empty():
		push_warning("[InventoryManager] 物品不存在: " + item_id)
		return false

	if not def.get("stackable", false):
		## 不可堆叠：每个占一个槽位
		for i: int in range(count):
			if not _add_single_slot(item_id):
				return false
	else:
		## 可堆叠：先找已有槽位
		var max_stack: int = def.get("max_stack", 99)
		for slot: Dictionary in _slots:
			if slot.get("item_id") == item_id and slot.get("count", 0) < max_stack:
				var space: int = max_stack - slot.get("count", 0)
				var to_add: int = mini(count, space)
				slot["count"] = slot.get("count", 0) + to_add
				count -= to_add
				if count <= 0:
					inventory_changed.emit()
					item_added.emit(item_id, to_add, get_item_count(item_id))
					return true
		## 再开新槽位
		while count > 0:
			if not _add_single_slot(item_id):
				return false
			count -= 1

	inventory_changed.emit()
	item_added.emit(item_id, 1, get_item_count(item_id))
	return true

func _add_single_slot(item_id: String) -> bool:
	if _slots.size() >= MAX_SLOTS:
		push_warning("[InventoryManager] 背包已满，无法获得 " + item_id)
		return false
	_slots.append({"item_id": item_id, "count": 1})
	return true

## 使用物品（减少数量，触发效果）
func use_item(item_id: String) -> bool:
	if not has_item(item_id):
		return false

	var def: Dictionary = DataLoader.get_item(item_id)
	if def.get("type") != "consumable":
		push_warning("[InventoryManager] 非消耗品不能直接使用: " + item_id)
		return false

	## 应用效果
	var effects: Array = def.get("effects", [])
	for effect: Dictionary in effects:
		_apply_effect(effect)

	## 减少数量
	_remove_item(item_id, 1)
	item_used.emit(item_id)
	return true

## 丢弃物品
func remove_item(item_id: String, count: int = 1) -> bool:
	return _remove_item(item_id, count)

func _remove_item(item_id: String, count: int) -> bool:
	for i: int in range(_slots.size()):
		if _slots[i].get("item_id") == item_id:
			var cur: int = _slots[i].get("count", 0)
			if cur <= count:
				count -= cur
				_slots.remove_at(i)
				i -= 1
			else:
				_slots[i]["count"] = cur - count
				count = 0
			if count <= 0:
				inventory_changed.emit()
				return true
	inventory_changed.emit()
	return false

## 应用效果到属性或好感
func _apply_effect(effect: Dictionary) -> void:
	var target: String = effect.get("target", "")
	var op: String = effect.get("op", "add")
	var value: float = float(effect.get("value", 0))

	match op:
		"add":   StatsManager.change_stat(target, value)
		"set":   StatsManager.set_stat(target, value)
		"mult":  StatsManager.change_stat(target, StatsManager.get_stat(target) * (value - 1.0))

## 清空背包
func clear_inventory() -> void:
	_slots.clear()
	inventory_changed.emit()

## ---- 存档兼容 ----

func serialize() -> Dictionary:
	return {"slots": _slots.duplicate()}

func deserialize(data: Dictionary) -> void:
	_slots = data.get("slots", [])
