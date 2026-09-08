## ui_inventory_panel.gd
## 职责：背包 UI 显示 — 列表展示、可使用/丢弃物品
## 依赖：InventoryManager
extends PanelContainer

@onready var item_list: ItemList = $MarginContainer/VBoxContainer/ItemList
@onready var use_button: Button = $MarginContainer/VBoxContainer/HBoxButtons/UseButton
@onready var drop_button: Button = $MarginContainer/VBoxContainer/HBoxButtons/DropButton

## 当前选中的 item_id
var _selected_item_id: String = ""

func _ready() -> void:
	InventoryManager.inventory_changed.connect(_refresh)
	item_list.item_selected.connect(_on_item_selected)
	use_button.pressed.connect(_on_use_pressed)
	drop_button.pressed.connect(_on_drop_pressed)
	_refresh()

func _input(event: InputEvent) -> void:
	## B 键切换显示
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_B:
			visible = not visible
			if visible:
				_refresh()

func _refresh() -> void:
	item_list.clear()
	var items: Array[Dictionary] = InventoryManager.get_all_items()
	if items.is_empty():
		use_button.disabled = true
		drop_button.disabled = true
		return
	for slot: Dictionary in items:
		var item_id: String = slot.get("item_id", "")
		var count: int = slot.get("count", 1)
		var def: Dictionary = DataLoader.get_item(item_id)
		var name_key: String = def.get("name_key", "")
		var display_name: String = _lookup_i18n(name_key, item_id)
		var label: String = "%s × %d" % [display_name, count] if count > 1 else display_name
		item_list.add_item(label)
		## 把 item_id 存到 ItemList 的 metadata 里
		item_list.set_item_metadata(item_list.item_count - 1, item_id)

func _on_item_selected(index: int) -> void:
	_selected_item_id = String(item_list.get_item_metadata(index))
	use_button.disabled = _selected_item_id.is_empty()
	drop_button.disabled = _selected_item_id.is_empty()

func _on_use_pressed() -> void:
	if _selected_item_id.is_empty():
		return
	if InventoryManager.use_item(_selected_item_id):
		print("[UIInventoryPanel] 使用物品: ", _selected_item_id)
	_selected_item_id = ""
	use_button.disabled = true
	drop_button.disabled = true

func _on_drop_pressed() -> void:
	if _selected_item_id.is_empty():
		return
	InventoryManager.remove_item(_selected_item_id, 1)
	print("[UIInventoryPanel] 丢弃物品: ", _selected_item_id)
	_selected_item_id = ""
	use_button.disabled = true
	drop_button.disabled = true

## i18n 查询：优先 DataLoader.i18n（加载了 zh_CN.json），fallback 为显示 item_id
func _lookup_i18n(key: String, fallback: String) -> String:
	if key.is_empty():
		return fallback
	var result: String = DataLoader.i18n(key)
	if result != key:
		return result
	return fallback
