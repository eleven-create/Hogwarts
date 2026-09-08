@tool
extends Node2D
## 原创占位地图：地面纹理、家具、出口标记以及与家具一致的碰撞。

@export_enum("bedroom", "corridor", "great_hall", "grounds") var scene_style: String = "bedroom"
@export var obstacles: Array[Rect2] = []

func _ready() -> void:
	if not Engine.is_editor_hint():
		var title: Label = get_parent().get_node_or_null("LocationLabel")
		if title != null:
			title.position = Vector2(100, 24)
			title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		for obstacle: Rect2 in obstacles:
			var body := StaticBody2D.new()
			var collision := CollisionShape2D.new()
			var shape := RectangleShape2D.new()
			shape.size = obstacle.size
			collision.shape = shape
			body.position = obstacle.get_center()
			body.add_child(collision)
			add_child(body)
	queue_redraw()

func _draw() -> void:
	match scene_style:
		"bedroom": _draw_bedroom()
		"corridor": _draw_corridor()
		"great_hall": _draw_great_hall()
		"grounds": _draw_grounds()
	_draw_door(Vector2(640, 670))
	if scene_style != "bedroom":
		_draw_door(Vector2(640, 50))

func _panel(rect: Rect2, color: Color, border: Color = Color.TRANSPARENT) -> void:
	draw_rect(rect, color)
	if border.a > 0.0:
		draw_rect(rect, border, false, 4.0)

func _draw_bedroom() -> void:
	_panel(Rect2(70, 80, 1140, 560), Color("#352641"), Color("#b88b9e"))
	_panel(Rect2(95, 105, 1090, 510), Color("#4e3455"), Color("#d3a5ae"))
	_floor(Color("#61415c"), true)
	for bed_x in [145.0, 425.0, 705.0, 985.0]:
		_panel(Rect2(bed_x, 165, 175, 280), Color("#8f536b"), Color("#e1b07e"))
		_panel(Rect2(bed_x + 12, 180, 151, 72), Color("#e8d8c4"))
		_panel(Rect2(bed_x + 25, 275, 125, 125), Color("#653d68"))
		for stripe: int in range(3):
			_panel(Rect2(bed_x + 34, 295 + stripe * 30, 107, 4), Color("#986283"))
		_panel(Rect2(bed_x + 18, 190, 135, 9), Color("#fff0d1"))
		_panel(Rect2(bed_x - 8, 158, 12, 297), Color("#3a2635"))
		_panel(Rect2(bed_x + 171, 158, 12, 297), Color("#3a2635"))
	_panel(Rect2(410, 535, 460, 55), Color("#c08b6d"), Color("#f0c39c"))
	for x: int in [190, 470, 750, 1030]:
		_window(Vector2(x, 85))

func _draw_corridor() -> void:
	_panel(Rect2(55, 75, 1170, 570), Color("#2c3048"), Color("#9ba3c4"))
	_panel(Rect2(100, 125, 1080, 470), Color("#4c526e"), Color("#d4b47e"))
	for x in range(120, 1160, 80): draw_line(Vector2(x, 145), Vector2(x, 575), Color("#626985"), 2.0)
	for y in range(155, 580, 70): draw_line(Vector2(120, y), Vector2(1160, y), Color("#626985"), 2.0)
	for x in [180.0, 345.0, 815.0, 980.0]: _panel(Rect2(x, 155, 120, 130), Color("#9bc4d4"), Color("#e8d5a5"))
	_panel(Rect2(475, 130, 330, 460), Color("#7e3d52"), Color("#d89c68"))
	for y: int in range(160, 580, 60):
		_panel(Rect2(495, y, 4, 28), Color("#cf9d75"))
		_panel(Rect2(780, y, 4, 28), Color("#cf9d75"))
	for x: int in [180, 345, 815, 980]:
		_panel(Rect2(x + 57, 155, 6, 130), Color("#e8d5a5"))
		_panel(Rect2(x, 215, 120, 6), Color("#e8d5a5"))
	for x: int in [125, 1125]:
		for y: int in [340, 470]:
			_panel(Rect2(x, y, 30, 70), Color("#9693a3"), Color("#d4b47e"))
			_candle(Vector2(x + 15, y - 10))

func _draw_great_hall() -> void:
	_panel(Rect2(55, 75, 1170, 570), Color("#3a211c"), Color("#d9b16b"))
	_panel(Rect2(95, 105, 1090, 510), Color("#70452b"), Color("#e5c17b"))
	_floor(Color("#885b39"), false)
	for x in [175.0, 390.0, 605.0, 820.0, 1035.0]: _panel(Rect2(x, 125, 90, 120), Color("#8ec4d0"), Color("#f3d494"))
	for y in [285.0, 430.0]:
		_panel(Rect2(180, y, 320, 70), Color("#4c2b28"), Color("#d6a15e"))
		_panel(Rect2(780, y, 320, 70), Color("#4c2b28"), Color("#d6a15e"))
		for x: int in [180, 780]:
			_panel(Rect2(x, y - 18, 320, 10), Color("#392c31"), Color("#ac784a"))
			_panel(Rect2(x, y + 80, 320, 10), Color("#392c31"), Color("#ac784a"))
			for place: int in range(4):
				_panel(Rect2(x + 24 + place * 76, y + 28, 20, 16), Color("#dfd3b0"))
				_candle(Vector2(x + 60 + place * 76, y + 32))
	_panel(Rect2(540, 260, 200, 300), Color("#9b6a43"), Color("#e0b873"))

func _draw_grounds() -> void:
	_panel(Rect2(55, 75, 1170, 570), Color("#173b3d"), Color("#a6cf8a"))
	_panel(Rect2(95, 105, 1090, 510), Color("#5f9b60"), Color("#b5d889"))
	for i: int in range(160):
		var point := Vector2(110 + (i * 97) % 1050, 125 + (i * 61) % 255)
		_panel(Rect2(point, Vector2(4, 8)), Color("#7eb36d"))
		if i % 9 == 0:
			_panel(Rect2(point + Vector2(4, 0), Vector2(4, 4)), Color("#f6d3a1"))
	_panel(Rect2(100, 390, 1080, 205), Color("#245c72"), Color("#8cc9c3"))
	for y in [430.0, 485.0, 540.0]: draw_line(Vector2(125, y), Vector2(1150, y), Color("#4d94a0"), 3.0)
	_panel(Rect2(560, 105, 160, 510), Color("#b69a6b"), Color("#e3c98d"))
	for y: int in range(110, 610, 24):
		_panel(Rect2(564, y, 152, 3), Color("#94734f"))
	for p in [Vector2(180, 190), Vector2(330, 330), Vector2(920, 220), Vector2(1080, 330)]:
		draw_rect(Rect2(p.x - 9, p.y + 20, 18, 58), Color("#69452d"))
		_panel(Rect2(p + Vector2(-32, -38), Vector2(64, 80)), Color("#275543"))
		_panel(Rect2(p + Vector2(-44, -20), Vector2(88, 44)), Color("#32754b"))
		_panel(Rect2(p + Vector2(-24, -32), Vector2(44, 44)), Color("#4b9357"))

func _floor(color: Color, wooden: bool) -> void:
	for row: int in range(12):
		var y: int = 110 + row * 42
		draw_line(Vector2(100, y), Vector2(1180, y), color, 2)
		for column: int in range(9):
			var x: int = 110 + column * 120 + (60 if row % 2 else 0)
			draw_line(Vector2(x, y), Vector2(x, y + 40), color, 2)
			if wooden:
				draw_line(Vector2(x + 12, y + 12), Vector2(x + 54, y + 12), color, 2)

func _window(point: Vector2) -> void:
	_panel(Rect2(point, Vector2(88, 66)), Color("#302c49"), Color("#c29177"))
	_panel(Rect2(point + Vector2(8, 8), Vector2(72, 50)), Color("#759fab"))
	_panel(Rect2(point + Vector2(41, 8), Vector2(6, 50)), Color("#e7c7a0"))
	_panel(Rect2(point + Vector2(8, 30), Vector2(72, 5)), Color("#e7c7a0"))

func _candle(point: Vector2) -> void:
	_panel(Rect2(point + Vector2(-3, -10), Vector2(6, 18)), Color("#e8d6a3"))
	_panel(Rect2(point + Vector2(-5, -20), Vector2(10, 10)), Color("#d99254"))
	_panel(Rect2(point + Vector2(-2, -19), Vector2(4, 7)), Color("#ffe7a3"))

func _draw_door(point: Vector2) -> void:
	if scene_style == "grounds" and point.y > 600:
		return
	_panel(Rect2(point + Vector2(-100, -26), Vector2(200, 52)), Color("#302c3c"), Color("#d4b47e"))
	var direction: float = 1.0 if point.y > 600 else -1.0
	draw_line(point - Vector2(0, 12 * direction), point + Vector2(0, 12 * direction), Color("#f8df9d"), 4)
	draw_line(point + Vector2(0, 12 * direction), point + Vector2(-9, 3 * direction), Color("#f8df9d"), 4)
	draw_line(point + Vector2(0, 12 * direction), point + Vector2(9, 3 * direction), Color("#f8df9d"), 4)
