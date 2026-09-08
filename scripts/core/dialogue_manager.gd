## dialogue_manager.gd
## 职责：Ink 剧情桥接 —— 加载 .ink 文件、注册 EXTERNAL 函数、驱动对话流程
## 依赖：StatsManager, RelationManager, FlagManager, EventManager, GameManager
## 对话管理器（Autoload: DialogueManager）
extends Node

## Ink 文件根目录
const INK_ROOT: String = "res://ink/"

## 当前 Ink 故事对象（C# InkStory 实例）
var _story: Object = null
## 当前 knot 名（来自 events.json 的 ink_knot 字段）
var _current_knot: String = ""
## 当前事件 ID（用于对话完成后回调 EventManager）
var _current_event_id: String = ""
## 是否正在播放对话
var _is_running: bool = false

## ---- 信号（供 DialogueUI 监听）----
signal dialogue_started(knot: String, event_id: String)
signal dialogue_line(speaker: String, text: String)
signal dialogue_choices(choices: Array)   ## Array of {label, index}
signal dialogue_finished(event_id: String)
signal dialogue_state_changed(state: String)

func _ready() -> void:
	print("[DialogueManager] 就绪")

## ---- 加载并启动对话 ----

## 从 .ink 文件加载（推荐）
func start_story_from_file(ink_knot: String, event_id: String = "") -> void:
	var path: String = INK_ROOT + "main.ink"
	if _is_running:
		push_warning("[DialogueManager] 对话已在运行中，忽略 start_story_from_file")
		return
	# 通过 C# 工厂类创建 InkStory
	# InkBridge 是 HarryPotter 命名空间下的 C# 类
	var story = ClassDB.instantiate("InkStory")
	if story == null:
		# 退而求其次：尝试通过 C# 静态类
		story = _create_story_via_csharp(path)
	if story == null:
		push_error("[DialogueManager] 无法创建 InkStory")
		return
	_start_with_story(story, ink_knot, event_id)

## 通过 C# 类直接调用（更可靠）
func _create_story_via_csharp(file_path: String) -> Object:
	# ClassDB 没有 InkBridge（不是 GlobalClass），用 load() 加载 C# script 类
	# GDScript 调用 C# 静态方法：ClassName.method(args)
	var InkBridge = load("res://addons/GodotInk/Src/InkBridge.cs")
	if InkBridge == null:
		push_error("[DialogueManager] 无法加载 InkBridge.cs")
		return null
	if not InkBridge.has_method("CreateStoryFromFile"):
		push_error("[DialogueManager] InkBridge 缺少 CreateStoryFromFile 方法")
		return null
	return InkBridge.call("CreateStoryFromFile", file_path)

func _start_with_story(story: Object, ink_knot: String, event_id: String) -> void:
	_story = story
	_current_knot = ink_knot
	_current_event_id = event_id
	_is_running = true

	# 绑定 EXTERNAL 函数到 GDScript Callable
	_bind_external_functions()

	# 跳转到目标 knot
	if not _story.get("ChoosePathString"):
		push_error("[DialogueManager] InkStory 缺少 ChoosePathString 方法（GodotInk 未正确安装？）")
		end_dialogue()
		return
	_story.call("ChoosePathString", ink_knot)

	# 通知 UI
	dialogue_started.emit(ink_knot, event_id)

	# 进入 DIALOGUE 状态
	GameManager.set_game_state(GameManager.GameState.DIALOGUE)

	# 立即推进（直到遇到第一个 choice）
	_continue_until_choice_or_end()

## 绑定所有 Ink EXTERNAL 函数到 GDScript 方法
func _bind_external_functions() -> void:
	_story.call("BindExternalFunction", "get_stat", _on_get_stat)
	_story.call("BindExternalFunction", "change_stat", _on_change_stat)
	_story.call("BindExternalFunction", "change_affection", _on_change_affection)
	_story.call("BindExternalFunction", "set_flag", _on_set_flag)
	_story.call("BindExternalFunction", "get_flag", _on_get_flag)
	_story.call("BindExternalFunction", "advance_time", _on_advance_time)
	_story.call("BindExternalFunction", "add_item", _on_add_item)

## ---- 推进对话 ----

## 继续到下一个 choice 或故事结尾
func continue_dialogue() -> void:
	if not _is_running or _story == null:
		return
	_continue_until_choice_or_end()

func _continue_until_choice_or_end() -> void:
	# 一直推进直到不能继续（遇到选择或结束）
	var can_continue: bool = _story.call("GetCanContinue")
	while can_continue:
		var line: String = _story.call("Continue")
		# 解析 Ink 的 # speaker: xxx / # character: xxx tag
		var speaker: String = ""
		if line.begins_with("# "):
			var parts: String = line.substr(2)
			var colon_idx: int = parts.find(":")
			if colon_idx > 0:
				var key: String = parts.substr(0, colon_idx).strip_edges()
				var val: String = parts.substr(colon_idx + 1).strip_edges()
				if key in ["speaker", "character"]:
					speaker = val
					# 提取后不作为对话文本发出（DialogueUI 单独处理 speaker）
					can_continue = _story.call("GetCanContinue")
					continue
		dialogue_line.emit(speaker, line)
		can_continue = _story.call("GetCanContinue")

	# 推出循环后，要么是 choice 要么是 END
	var choices_array: Array = _story.call("GetCurrentChoices")
	if choices_array.size() > 0:
		var choices: Array = []
		for i in choices_array.size():
			var c = choices_array[i]
			# InkChoice 有 GetText() 方法（GDScript 兼容）
			var label_text: String = ""
			if c.has_method("GetText"):
				label_text = str(c.call("GetText"))
			elif c.get("text") != null:
				label_text = str(c.get("text"))
			choices.append({
				"label": label_text,
				"index": i
			})
		dialogue_choices.emit(choices)
	else:
		# 没有 choice 意味着故事结束
		end_dialogue()

## 玩家选择一个选项
func select_choice(choice_index: int) -> void:
	if not _is_running or _story == null:
		return
	_story.call("ChooseChoiceIndex", choice_index)
	_continue_until_choice_or_end()

## ---- 结束 ----

func end_dialogue() -> void:
	if not _is_running:
		return
	var finished_event_id: String = _current_event_id
	_is_running = false
	_current_knot = ""
	_current_event_id = ""
	_story = null
	dialogue_finished.emit(finished_event_id)

	# 通知 EventManager 标记完成
	if finished_event_id != "" and EventManager:
		EventManager.complete_event(finished_event_id)

	# 恢复 PLAYING 状态
	GameManager.set_game_state(GameManager.GameState.PLAYING)

## ---- EXTERNAL 函数实现 ----

func _on_get_stat(stat_id: String) -> float:
	return StatsManager.get_stat(stat_id)

func _on_change_stat(stat_id: String, amount: float) -> void:
	StatsManager.change_stat(stat_id, amount)
	print("[DialogueManager] Ink → change_stat(", stat_id, ", ", amount, ")")

func _on_change_affection(char_id: String, amount: int) -> void:
	RelationManager.change_affection(char_id, amount)
	print("[DialogueManager] Ink → change_affection(", char_id, ", ", amount, ")")

func _on_set_flag(flag_id: String, value: Variant) -> void:
	FlagManager.set_flag(flag_id, value)
	print("[DialogueManager] Ink → set_flag(", flag_id, " = ", value, ")")

func _on_get_flag(flag_id: String) -> Variant:
	return FlagManager.get_flag(flag_id)

func _on_advance_time(time_slot: String) -> void:
	print("[DialogueManager] Ink → advance_time(", time_slot, ")")
	TimeManager.advance_to_slot(time_slot)

func _on_add_item(item_id: String) -> void:
	print("[DialogueManager] Ink → add_item(", item_id, ")")
	InventoryManager.add_item(item_id, 1)

## ---- 存档兼容 ----

func get_ink_state() -> String:
	if _story == null:
		return ""
	# InkStory.GetState() 返回序列化的 JSON
	if _story.has_method("GetState"):
		return str(_story.call("GetState", "{\"errors\":[]}") if false else "")
	return ""

func set_ink_state(_state: String) -> void:
	## TODO: 通过 InkStory.SetState() 恢复
	pass

## ---- 查询 ----

func is_dialogue_running() -> bool:
	return _is_running

func get_current_knot() -> String:
	return _current_knot
