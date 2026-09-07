## data_loader.gd
## 职责：启动时加载 /data 下所有 JSON，暴露全局数据访问接口
## 依赖：无
## 输出：供其他所有单例调用
## 数据加载器单例（通过 Autoload 注册为全局 DataLoader）
## 注意：不在此处定义 class_name，避免与 Autoload 单例同名冲突
extends Node

## 数据缓存
var _characters: Dictionary = {}
var _events: Dictionary = {}
var _locations: Dictionary = {}
var _items: Dictionary = {}
var _stats_def: Dictionary = {}
var _appearance: Dictionary = {}
var _houses: Dictionary = {}

## 就绪标志
var is_loaded: bool = false

signal data_loaded()
signal data_load_failed(error: String)

func _init() -> void:
	print("[DataLoader] 初始化中...")

func _ready() -> void:
	load_all_data()

## 加载所有配置数据
func load_all_data() -> void:
	var errors: Array[String] = []
	
	_characters = _load_json("res://data/characters.json")
	_events     = _load_json("res://data/events.json")
	_locations  = _load_json("res://data/locations.json")
	_items      = _load_json("res://data/items.json")
	_stats_def  = _load_json("res://data/stats_def.json")
	_appearance = _load_json("res://data/appearance.json")
	_houses     = _load_json("res://data/houses.json")
	
	if _characters.is_empty(): errors.append("characters.json")
	if _events.is_empty():     errors.append("events.json")
	if _locations.is_empty():   errors.append("locations.json")
	if _items.is_empty():       errors.append("items.json")
	if _stats_def.is_empty():  errors.append("stats_def.json")
	if _houses.is_empty():     errors.append("houses.json")
	
	if errors.is_empty():
		is_loaded = true
		print("[DataLoader] 全部配置加载完成")
		data_loaded.emit()
	else:
		var err_msg := "加载失败: " + ", ".join(errors)
		print("[DataLoader] " + err_msg)
		data_load_failed.emit(err_msg)

## 通用 JSON 加载
func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_warning("[DataLoader] 文件不存在: " + path)
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("[DataLoader] 读取失败: " + path)
		return {}
	var json := JSON.new()
	var parse_result := json.parse(file.get_as_text())
	file.close()
	if parse_result != OK:
		push_warning("[DataLoader] JSON 解析失败: " + path)
		return {}
	var result = json.get_data()
	if result is Dictionary:
		return result as Dictionary
	push_warning("[DataLoader] JSON 根类型不是 Dictionary: " + path)
	return {}

## ---- 对外访问接口 ----

func get_characters_data() -> Dictionary:
	return _characters

func get_events_data() -> Dictionary:
	return _events

func get_locations_data() -> Dictionary:
	return _locations

func get_items_data() -> Dictionary:
	return _items

func get_stats_def_data() -> Dictionary:
	return _stats_def

func get_appearance_data() -> Dictionary:
	return _appearance

func get_houses_data() -> Dictionary:
	return _houses

## 根据 ID 获取单条数据（便捷封装）
func get_character(char_id: String) -> Dictionary:
	var chars: Array = _characters.get("characters", [])
	for c: Dictionary in chars:
		if c.get("char_id") == char_id:
			return c
	return {}

func get_event(event_id: String) -> Dictionary:
	var evts: Array = _events.get("events", [])
	for e: Dictionary in evts:
		if e.get("event_id") == event_id:
			return e
	return {}

func get_location(loc_id: String) -> Dictionary:
	var locs: Array = _locations.get("locations", [])
	for l: Dictionary in locs:
		if l.get("loc_id") == loc_id:
			return l
	return {}

func get_item(item_id: String) -> Dictionary:
	var items: Array = _items.get("items", [])
	for i: Dictionary in items:
		if i.get("item_id") == item_id:
			return i
	return {}

func get_stat_def(stat_id: String) -> Dictionary:
	var stats: Array = _stats_def.get("stats", [])
	for s: Dictionary in stats:
		if s.get("stat_id") == stat_id:
			return s
	return {}

func get_house(house_id: String) -> Dictionary:
	var houses: Array = _houses.get("houses", [])
	for h: Dictionary in houses:
		if h.get("house_id") == house_id:
			return h
	return {}
