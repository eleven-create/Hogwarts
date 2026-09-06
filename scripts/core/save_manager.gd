## save_manager.gd
## 职责：存档/读档（JSON 格式），整合所有单例状态
## 依赖：所有单例
## 存档管理器（Autoload: SaveManager）
## 注意：不在此处定义 class_name，避免与 Autoload 单例同名冲突
extends Node

## 存档目录
const SAVE_PATH: String = "user://saves/"
const SAVE_FILE: String = "save.json"
const MAX_SAVE_SLOTS: int = 3

## 信号
signal save_completed(slot: int)
signal load_completed(slot: int)
signal save_failed(slot: int, error: String)
signal load_failed(slot: int, error: String)

func _ready() -> void:
	print("[SaveManager] 就绪")
	_ensure_save_directory()

func _ensure_save_directory() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_PATH):
		DirAccess.make_dir_recursive_absolute(SAVE_PATH)

## ---- 存档 ----

func save_game(slot: int = 0) -> bool:
	if slot < 0 or slot >= MAX_SAVE_SLOTS:
		push_error("[SaveManager] 无效存档槽位: " + str(slot))
		return false
	
	var path: String = SAVE_PATH + "slot_" + str(slot) + ".json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		var err: int = FileAccess.get_open_error()
		save_failed.emit(slot, "无法创建存档文件，错误码: " + str(err))
		return false
	
	var data: Dictionary = _collect_save_data()
	var json_str := JSON.stringify(data, "\t")
	file.store_string(json_str)
	file.close()
	
	save_completed.emit(slot)
	print("[SaveManager] 存档完成: 槽位 ", slot)
	return true

func _collect_save_data() -> Dictionary:
	return {
		"version": 1,
		"timestamp": Time.get_datetime_string_from_system(),
		"game": {
			"state": GameManager.current_state,
			"location": GameManager.current_location,
			"is_new_game": GameManager.is_new_game
		},
		"date": TimeManager.get_date().to_dict(),
		"stats": StatsManager.serialize(),
		"relations": RelationManager.serialize(),
		"flags": FlagManager.serialize(),
		"events": EventManager.serialize(),
		## TODO: 背包、换装等数据
		"ink_state": DialogueManager.get_ink_state()
	}

## ---- 读档 ----

func load_game(slot: int = 0) -> bool:
	if slot < 0 or slot >= MAX_SAVE_SLOTS:
		push_error("[SaveManager] 无效存档槽位: " + str(slot))
		return false
	
	var path: String = SAVE_PATH + "slot_" + str(slot) + ".json"
	if not FileAccess.file_exists(path):
		load_failed.emit(slot, "存档文件不存在")
		return false
	
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		load_failed.emit(slot, "无法打开存档文件")
		return false
	
	var json := JSON.new()
	var parse_result := json.parse(file.get_as_text())
	file.close()
	if parse_result != OK:
		load_failed.emit(slot, "JSON 解析失败")
		return false
	
	var data: Dictionary = json.get_data()
	if not data is Dictionary:
		load_failed.emit(slot, "存档格式错误")
		return false
	
	_apply_save_data(data)
	load_completed.emit(slot)
	print("[SaveManager] 读档完成: 槽位 ", slot)
	return true

func _apply_save_data(data: Dictionary) -> void:
	var game: Dictionary = data.get("game", {})
	GameManager.current_state = game.get("state", GameManager.GameState.MENU)
	GameManager.current_location = game.get("location", "")
	GameManager.is_new_game = game.get("is_new_game", true)
	
	var date_data: Dictionary = data.get("date", {})
	TimeManager.set_date(TimeManager.GameDate.from_dict(date_data))
	
	StatsManager.deserialize(data.get("stats", {}))
	RelationManager.deserialize(data.get("relations", {}))
	FlagManager.deserialize(data.get("flags", {}))
	EventManager.deserialize(data.get("events", {}))
	
	DialogueManager.set_ink_state(data.get("ink_state", ""))

## ---- 工具 ----

func get_save_info(slot: int) -> Dictionary:
	var path: String = SAVE_PATH + "slot_" + str(slot) + ".json"
	if not FileAccess.file_exists(path):
		return {}
	
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var json := JSON.new()
	json.parse(file.get_as_text())
	file.close()
	return json.get_data()

func delete_save(slot: int) -> bool:
	var path: String = SAVE_PATH + "slot_" + str(slot) + ".json"
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		return true
	return false

func has_save(slot: int) -> bool:
	return FileAccess.file_exists(SAVE_PATH + "slot_" + str(slot) + ".json")
