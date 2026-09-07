## game_manager.gd
## 职责：全局游戏状态、场景切换、主循环控制
## 依赖：DataLoader, TimeManager, SaveManager
## 游戏主管理器（Autoload: GameManager）
## 注意：不在此处定义 class_name，避免与 Autoload 单例同名冲突
extends Node

## 游戏状态枚举
enum GameState { MENU, PLAYING, PAUSED, DIALOGUE, EVENT }

## 当前状态
var current_state: GameState = GameState.MENU
var current_location: String = ""
var is_new_game: bool = true

## 出生点（默认中央）
@export var spawn_position: Vector2 = Vector2(640, 360)

## 信号
signal game_state_changed(state: GameState)
signal location_changed(loc_id: String)
signal game_paused()
signal game_resumed()

func _ready() -> void:
	print("[GameManager] 就绪")

## ---- 场景切换 ----

func change_scene(scene_path: String) -> void:
	if not ResourceLoader.exists(scene_path):
		push_error("[GameManager] 场景不存在: " + scene_path)
		return
	get_tree().change_scene_to_file(scene_path)

## 切换地点：根据 loc_id 查 locations.json 加载对应场景
func change_location(loc_id: String) -> void:
	if loc_id == current_location:
		return
	var loc: Dictionary = DataLoader.get_location(loc_id)
	if loc.is_empty():
		push_error("[GameManager] 找不到地点: " + loc_id)
		return
	current_location = loc_id
	location_changed.emit(loc_id)
	print("[GameManager] 切换地点: ", loc_id, " -> ", loc.get("scene_path", ""))
	change_scene(loc.get("scene_path", ""))

## ---- 状态控制 ----

func set_game_state(new_state: GameState) -> void:
	if current_state == new_state:
		return
	current_state = new_state
	game_state_changed.emit(new_state)
	print("[GameManager] 状态切换: ", GameState.keys()[new_state])

func pause_game() -> void:
	get_tree().paused = true
	set_game_state(GameState.PAUSED)
	game_paused.emit()

func resume_game() -> void:
	get_tree().paused = false
	set_game_state(GameState.PLAYING)
	game_resumed.emit()

func start_new_game() -> void:
	is_new_game = true
	current_location = ""
	## 初始化玩家位置为宿舍
	current_location = "loc_bedroom"
	location_changed.emit(current_location)
	## 清空背包
	InventoryManager.clear_inventory()
	## 初始装备：魔杖 + 校袍
	InventoryManager.add_item("item_wand_basic")
	InventoryManager.add_item("item_school_robe")
	## TODO: 重置所有系统状态
	## TODO: 加载初始存档
	change_scene("res://scenes/world/bedroom.tscn")
	set_game_state(GameState.PLAYING)

func continue_game() -> void:
	## TODO: 从存档加载
	pass

## ---- 全局工具 ----

func quit_game() -> void:
	get_tree().quit()
