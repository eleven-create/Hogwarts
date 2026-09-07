## npc.gd
## 职责：可交互 NPC 节点 — 玩家靠近时显示提示，按 E 触发 Ink 对话
## 用法：把 NPC 节点放在世界场景里，配 char_id 和 event_id
## 依赖：DialogueManager, EventManager, DataLoader
extends Area2D

## 角色 ID（指向 characters.json）
@export var char_id: String = ""
## 触发事件 ID（指向 events.json，可选；为空时直接触发 ink_knot）
@export var event_id: String = ""
## Ink knot 名（指向 .ink 文件里的 knot）
@export var ink_knot: String = ""
## 显示名（可覆盖 i18n；留空走 DataLoader）
@export var display_name_override: String = ""
## NPC 颜色（占位美术）
@export var body_color: Color = Color(0.5, 0.5, 0.5, 1.0)

## 玩家是否在交互范围内
var _player_in_range: bool = false

@onready var label_hint: Label = get_node_or_null("BodyHint")
@onready var body_rect: ColorRect = get_node_or_null("Body")

func _ready() -> void:
	if body_rect and body_rect is ColorRect:
		body_rect.color = body_color
	_update_hint()

func _update_hint() -> void:
	if label_hint == null:
		return
	var name_str: String = display_name_override
	if name_str.is_empty() and char_id != "" and DataLoader:
		var char: Dictionary = DataLoader.get_character(char_id)
		var name_key: String = char.get("display_name_key", "")
		if name_key != "" and TranslationServer:
			name_str = tr(name_key)
	if name_str == "":
		name_str = "???"
	label_hint.text = name_str

func _on_body_entered(body: Node) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		_player_in_range = true
		if label_hint:
			label_hint.modulate = Color(1, 1, 0.4)  # 高亮

func _on_body_exited(body: Node) -> void:
	if body.name == "Player" or body.is_in_group("player"):
		_player_in_range = false
		if label_hint:
			label_hint.modulate = Color.WHITE

## 由 player_movement 调用：检查是否要交互
func try_interact() -> bool:
	if not _player_in_range:
		return false
	# 优先用 event_id（EventManager 决定 ink_knot）
	if event_id != "" and EventManager:
		EventManager.trigger_event(event_id)
		return true
	# 否则直接用 ink_knot
	if ink_knot != "" and DialogueManager:
		DialogueManager.start_story_from_file(ink_knot, "")
		return true
	push_warning("[NPC %s] 缺少 event_id 和 ink_knot" % name)
	return false
