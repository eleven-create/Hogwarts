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
	_panel(Rect2(55, 75, 1170, 570), Color("#191d31"), Color("#caa66a"))
	_panel(Rect2(92, 112, 1096, 486), Color("#42465f"), Color("#e1c58b"))
	_floor(Color("#555b76"), false)
	_panel(Rect2(468, 128, 344, 466), Color("#6e3048"), Color("#d6a25f"))
	_panel(Rect2(492, 150, 296, 420), Color("#7b3c55"), Color("#9e6a63"))
	for y: int in range(165, 560, 54):
		draw_line(Vector2(510, y), Vector2(770, y), Color("#995f70"), 2.0)
	for x in [180.0, 345.0, 815.0, 980.0]:
		_arch(Vector2(x, 150), Vector2(120, 145), Color("#6d7189"), Color("#d8bd83"))
		_window(Vector2(x + 16, 177))
	for x: int in [118, 1128]:
		for y: int in [340, 470]:
			_panel(Rect2(x, y, 34, 74), Color("#29283d"), Color("#d4b47e"))
			_candle(Vector2(x + 17, y - 10))
	for x: int in [142, 1118]:
		_panel(Rect2(x, 132, 38, 430), Color("#292b40"), Color("#9c805b"))
		for y: int in range(150, 550, 72):
			_panel(Rect2(x - 8, y, 54, 8), Color("#c6a875"))
	_banner(Vector2(120, 275), Color("#8b304b"), "G")
	_banner(Vector2(1120, 275), Color("#264c75"), "R")

func _draw_great_hall() -> void:
	_panel(Rect2(55, 75, 1170, 570), Color("#24191d"), Color("#d9b16b"))
	_panel(Rect2(95, 105, 1090, 510), Color("#70452b"), Color("#e5c17b"))
	_floor(Color("#885b39"), true)
	for x in [175.0, 390.0, 605.0, 820.0, 1035.0]:
		_arch(Vector2(x, 125), Vector2(90, 125), Color("#4a3140"), Color("#edcf8c"))
		_panel(Rect2(x + 12, 145, 66, 82), Color("#284258"), Color("#93b5bf"))
		for pane in [0, 1, 2]:
			draw_line(Vector2(x + 18 + pane * 22, 151), Vector2(x + 18 + pane * 22, 220), Color("#6d8d98"), 2.0)
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
	_panel(Rect2(565, 285, 150, 245), Color("#c19258"), Color("#f0d28d"))
	for y in range(315, 510, 42):
		_panel(Rect2(590, y, 100, 7), Color("#8b5b3d"))
	for x in [200.0, 1060.0]:
		_banner(Vector2(x, 180), Color("#8d304b" if x < 500 else "#315d86"), "H")
		_statue(Vector2(x, 535))

func _draw_grounds() -> void:
	_panel(Rect2(55, 75, 1170, 570), Color("#173b3d"), Color("#a6cf8a"))
	_panel(Rect2(95, 105, 1090, 510), Color("#5f9b60"), Color("#b5d889"))
	_panel(Rect2(95, 105, 1090, 78), Color("#718a66"), Color("#c4d79f"))
	for x in range(120, 1160, 110):
		_panel(Rect2(x, 120, 72, 36), Color("#788d78"), Color("#b4c59b"))
		_panel(Rect2(x + 7, 128, 58, 20), Color("#314451"))
	for p in [Vector2(150, 215), Vector2(310, 215), Vector2(930, 215), Vector2(1090, 215)]:
		_arch(p, Vector2(88, 82), Color("#65735d"), Color("#cfbf88"))
		_panel(Rect2(p + Vector2(17, 22), Vector2(54, 42)), Color("#334956"), Color("#a7b9a0"))
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
	_panel(Rect2(840, 300, 260, 72), Color("#6d5136"), Color("#d9b978"))
	_panel(Rect2(855, 315, 230, 42), Color("#8b6f43"), Color("#e7cb8f"))
	for x in range(870, 1080, 42):
		_panel(Rect2(x, 322, 28, 28), Color("#6f9b55"), Color("#b4d77f"))
		_panel(Rect2(x + 8, 304, 12, 18), Color("#b8d67c"))
	_panel(Rect2(115, 335, 170, 38), Color("#756044"), Color("#d8bc7d"))
	_panel(Rect2(125, 342, 150, 20), Color("#a68b54"))

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

func _arch(point: Vector2, size: Vector2, fill: Color, border: Color) -> void:
	_panel(Rect2(point + Vector2(0, size.y * 0.25), Vector2(size.x, size.y * 0.75)), fill, border)
	draw_arc(point + Vector2(size.x * 0.5, size.y * 0.25), size.x * 0.5, PI, TAU, 18, border, 8.0)

func _banner(point: Vector2, color: Color, crest: String) -> void:
	_panel(Rect2(point, Vector2(54, 112)), color, Color("#e4bd69"))
	var tip := PackedVector2Array([point + Vector2(0, 112), point + Vector2(27, 136), point + Vector2(54, 112)])
	draw_colored_polygon(tip, color)
	draw_string(ThemeDB.fallback_font, point + Vector2(21, 66), crest, HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("#f5d68c"))

func _statue(point: Vector2) -> void:
	_panel(Rect2(point + Vector2(-24, -18), Vector2(48, 18)), Color("#756252"), Color("#d3b77c"))
	_panel(Rect2(point + Vector2(-14, -74), Vector2(28, 56)), Color("#7f897d"), Color("#d2c39a"))
	_panel(Rect2(point + Vector2(-22, -88), Vector2(44, 18)), Color("#6e786f"), Color("#d2c39a"))

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
