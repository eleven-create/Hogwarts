## ui_dialogue_panel.gd
## 职责：监听 DialogueManager 信号，显示对话文本和选项
## 依赖：DialogueManager
extends CanvasLayer

## 节点引用
@onready var speaker_label: Label = %SpeakerLabel
@onready var text_label: RichTextLabel = %TextLabel
@onready var choices_container: VBoxContainer = %ChoicesContainer

## 当前显示的文本缓存（继续时清空）
var _current_lines: Array[String] = []
var _is_awaiting_choice: bool = false
## 数字键冷却（防止一帧多次触发）
var _key_cooldown: bool = false

func _ready() -> void:
	hide()
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_line.connect(_on_dialogue_line)
	DialogueManager.dialogue_choices.connect(_on_dialogue_choices)
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)
	print("[DialogueUI] 就绪")

func _input(event: InputEvent) -> void:
	if not visible:
		return
	# F / Space / Enter 继续对话（无选项时）
	if not _is_awaiting_choice:
		if event.is_action_pressed("ui_accept") and not _key_cooldown:
			_key_cooldown = true
			DialogueManager.continue_dialogue()
			# 重置冷却（下一帧）
			get_tree().create_timer(0.15, false).timeout.connect(_reset_key_cooldown)
		return
	# 有选项时：数字键 1-4 快捷选择
	if event is InputEventKey and event.pressed and not event.echo:
		var key_num: int = -1
		if event.keycode == KEY_1: key_num = 1
		elif event.keycode == KEY_2: key_num = 2
		elif event.keycode == KEY_3: key_num = 3
		elif event.keycode == KEY_4: key_num = 4
		if key_num > 0:
			_select_by_number(key_num)

func _reset_key_cooldown() -> void:
	_key_cooldown = false

func _on_dialogue_started(_knot: String, _event_id: String) -> void:
	show()
	_current_lines.clear()
	_is_awaiting_choice = false
	_clear_choices()
	speaker_label.text = ""
	text_label.text = "[i]...[/i]"

func _on_dialogue_line(_speaker: String, text: String) -> void:
	# 跳过 Ink 的 # speaker / # character 标记行
	if text.begins_with("# "):
		var parts: String = text.substr(2)
		var colon_idx: int = parts.find(":")
		if colon_idx > 0:
			var key: String = parts.substr(0, colon_idx).strip_edges()
			var val: String = parts.substr(colon_idx + 1).strip_edges()
			if key in ["speaker", "character"]:
				speaker_label.text = _resolve_speaker_name(val)
				return
		return
	_current_lines.append(text)
	text_label.text = "\n".join(_current_lines)

func _resolve_speaker_name(key_or_text: String) -> String:
	if key_or_text.begins_with("name_"):
		var translated: String = DataLoader.i18n(key_or_text)
		if translated != key_or_text:
			return translated
	return key_or_text

func _on_dialogue_choices(choices: Array) -> void:
	_is_awaiting_choice = true
	_clear_choices()
	for i in choices.size():
		var c: Dictionary = choices[i]
		var btn: Button = Button.new()
		btn.text = "[%d] %s" % [i + 1, c.get("label", "???")]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.custom_minimum_size = Vector2(0, 36)
		btn.pressed.connect(_on_choice_pressed.bind(i))
		choices_container.add_child(btn)

func _select_by_number(num: int) -> void:
	var buttons: Array[Button] = []
	for child in choices_container.get_children():
		if child is Button:
			buttons.append(child)
	if num > 0 and num <= buttons.size():
		_on_choice_pressed(num - 1)

func _on_choice_pressed(index: int) -> void:
	_is_awaiting_choice = false
	_clear_choices()
	DialogueManager.select_choice(index)

func _clear_choices() -> void:
	for child in choices_container.get_children():
		child.queue_free()

func _on_dialogue_finished(_event_id: String) -> void:
	hide()
	_current_lines.clear()
	_is_awaiting_choice = false
	_clear_choices()
