extends StaticBody2D
## 场景家具：自身带阻挡碰撞、交互范围和可见的像素化外观。

@export_enum("bed", "desk", "chest", "window", "table", "greenhouse", "statue") var object_kind: String = "chest"
@export var display_size: Vector2 = Vector2(100, 60)
@export var interaction_text: String = "查看"

var _prompt: String = ""

func _ready() -> void:
	add_to_group("interactable_objects")
	var solid := CollisionShape2D.new()
	var solid_shape := RectangleShape2D.new()
	solid_shape.size = display_size
	solid.shape = solid_shape
	add_child(solid)

	var interact_area := Area2D.new()
	interact_area.name = "InteractArea"
	interact_area.collision_layer = 0
	interact_area.collision_mask = 1
	var area_shape := CollisionShape2D.new()
	var area_rect := RectangleShape2D.new()
	area_rect.size = display_size + Vector2(42, 42)
	area_shape.shape = area_rect
	interact_area.add_child(area_shape)
	add_child(interact_area)
	queue_redraw()

func interact() -> String:
	match object_kind:
		"bed": return "床铺：休息会推进一个时间段"
		"desk": return "书桌：这里可以安排学习活动"
		"chest": return "箱子：需要钥匙才能打开"
		"window": return "窗户：夜色下可以看到城堡庭院"
		"table": return "长桌：这里是学院公共区域"
		"greenhouse": return "温室：可以种植魔法植物"
		"statue": return "石像：古老的守护者沉默地注视着你"
	return interaction_text

func _draw() -> void:
	var s := display_size
	match object_kind:
		"bed": _draw_bed(s)
		"desk": _draw_desk(s)
		"chest": _draw_chest(s)
		"window": _draw_window(s)
		"table": _draw_table(s)
		"greenhouse": _draw_greenhouse(s)
		"statue": _draw_statue(s)

func _outline(rect: Rect2, fill: Color, edge: Color = Color("#e3bc75")) -> void:
	draw_rect(rect, fill)
	draw_rect(rect, edge, false, 3.0)

func _draw_bed(s: Vector2) -> void:
	_outline(Rect2(-s.x / 2, -s.y / 2, s.x, s.y), Color("#6e2942"), Color("#b88657"))
	draw_rect(Rect2(-s.x / 2 + 9, -s.y / 2 + 8, s.x - 18, 22), Color("#ead7b1"))
	draw_line(Vector2(-s.x / 2 + 12, 2), Vector2(s.x / 2 - 12, 2), Color("#c99658"), 3.0)
	for x in [-s.x / 2 + 7, s.x / 2 - 10]:
		draw_rect(Rect2(x, -s.y / 2 - 8, 4, s.y + 14), Color("#4a3030"))

func _draw_desk(s: Vector2) -> void:
	_outline(Rect2(-s.x / 2, -s.y / 2, s.x, 22), Color("#70472f"))
	for x in [-s.x / 2 + 10, s.x / 2 - 15]:
		draw_rect(Rect2(x, -s.y / 2 + 20, 5, s.y - 20), Color("#48312b"))
	draw_rect(Rect2(-s.x / 2 + 18, -s.y / 2 + 5, 16, 10), Color("#38545a"))
	draw_rect(Rect2(2, -s.y / 2 + 5, 24, 12), Color("#dfc99b"))
	draw_line(Vector2(2, -s.y / 2 + 8), Vector2(23, -s.y / 2 + 7), Color("#9f815f"), 2.0)

func _draw_chest(s: Vector2) -> void:
	_outline(Rect2(-s.x / 2, -s.y / 2, s.x, s.y), Color("#70452f"))
	draw_line(Vector2(-s.x / 2 + 5, 0), Vector2(s.x / 2 - 5, 0), Color("#b17b4d"), 3.0)
	draw_rect(Rect2(-5, -4, 10, 9), Color("#d6ae5f"))
	draw_rect(Rect2(-2, -2, 4, 5), Color("#4e3430"))

func _draw_window(s: Vector2) -> void:
	draw_rect(Rect2(-s.x / 2, -s.y / 2, s.x, s.y), Color("#343849"))
	draw_rect(Rect2(-s.x / 2 + 7, -s.y / 2 + 7, s.x - 14, s.y - 14), Color("#1d3851"), false, 4.0)
	draw_line(Vector2(0, -s.y / 2 + 8), Vector2(0, s.y / 2 - 8), Color("#d9bd83"), 3.0)
	draw_line(Vector2(-s.x / 2 + 8, 0), Vector2(s.x / 2 - 8, 0), Color("#d9bd83"), 3.0)
	draw_circle(Vector2(-14, -8), 6, Color("#dfe2c9"))

func _draw_table(s: Vector2) -> void:
	_outline(Rect2(-s.x / 2, -s.y / 2, s.x, 20), Color("#5f382b"))
	for x in [-s.x / 2 + 10, s.x / 2 - 15]:
		draw_rect(Rect2(x, -s.y / 2 + 20, 5, s.y - 20), Color("#38272a"))
	for x in [-s.x / 2 + 22, 0, s.x / 2 - 32]:
		draw_rect(Rect2(x, -s.y / 2 + 6, 15, 7), Color("#eadbb5"))

func _draw_greenhouse(s: Vector2) -> void:
	_outline(Rect2(-s.x / 2, -s.y / 2, s.x, s.y), Color("#6f5139"))
	draw_rect(Rect2(-s.x / 2 + 8, -s.y / 2 + 8, s.x - 16, s.y - 16), Color("#709d66"), false, 3.0)
	for x in range(int(-s.x / 2 + 14), int(s.x / 2 - 8), 24):
		draw_line(Vector2(x, -s.y / 2 + 10), Vector2(x, s.y / 2 - 10), Color("#c7d994"), 2.0)

func _draw_statue(s: Vector2) -> void:
	draw_rect(Rect2(-s.x / 2, s.y / 2 - 15, s.x, 15), Color("#756252"), false, 3.0)
	draw_rect(Rect2(-12, -s.y / 2 + 8, 24, s.y - 24), Color("#818879"), false, 3.0)
	draw_circle(Vector2(0, -s.y / 2 + 8), 14, Color("#8f9686"))
