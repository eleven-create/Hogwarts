## ui_dialogue_panel.gd
## 职责：监听 DialogueManager 信号，显示对话文本和选项
## 依赖：DialogueManager
extends CanvasLayer

## 节点引用（unique_name_in_owner 自动解析）
@onready var speaker_label: Label = %SpeakerLabel
@onready var text_label: RichTextLabel = %TextLabel
@onready var choices_container: VBoxContainer = %ChoicesContainer

## 当前显示的文本缓存（继续时清空）
var _current_lines: Array[String] = []
var _is_awaiting_choice: bool = false

func _ready() -> void:
	hide()
	# 监听 DialogueManager 信号
	DialogueManager.dialogue_started.connect(_on_dialogue_started)
	DialogueManager.dialogue_line.connect(_on_dialogue_line)
	DialogueManager.dialogue_choices.connect(_on_dialogue_choices)
	DialogueManager.dialogue_finished.connect(_on_dialogue_finished)
	print("[DialogueUI] 就绪")

func _process(_delta: float) -> void:
	# 在对话中：E / Space 继续
	if not visible:
		return
	if _is_awaiting_choice:
		return
	if Input.is_action_just_pressed("ui_accept"):
		DialogueManager.continue_dialogue()

func _on_dialogue_started(_knot: String, _event_id: String) -> void:
	show()
	_current_lines.clear()
	_is_awaiting_choice = false
	_clear_choices()
	speaker_label.text = ""
	text_label.text = "[i]...[/i]"

func _on_dialogue_line(speaker: String, text: String) -> void:
	# 跳过 speaker 标记行（用 # 开头的）
	if text.begins_with("# "):
		# 提取 speaker 字段（如 "# speaker: name_char_xxx"）
		var parts: String = text.substr(2)
		var colon_idx: int = parts.find(":")
		if colon_idx > 0:
			var key: String = parts.substr(0, colon_idx).strip_edges()
			var val: String = parts.substr(colon_idx + 1).strip_edges()
			if key == "speaker" or key == "character":
				speaker_label.text = _resolve_speaker_name(val)
				return
		# 其他 tag 忽略
		return
	_current_lines.append(text)
	text_label.text = "\n".join(_current_lines)

func _resolve_speaker_name(key_or_text: String) -> String:
	# 如果 key 以 "name_" 开头，走 i18n
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
		btn.custom_minimum_size = Vector2(0, 32)
		# 点击按钮
		btn.pressed.connect(_on_choice_pressed.bind(i))
		choices_container.add_child(btn)
	# 数字键快捷选择
	pass

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
