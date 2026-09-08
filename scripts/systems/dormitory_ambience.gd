extends Node2D
## 宿舍动态氛围层：壁炉火星、烛光和浮尘，不依赖图片 API。

var _time: float = 0.0
var _embers: Array[Vector3] = []
var _dust: Array[Vector3] = []

func _ready() -> void:
	z_index = -3
	for index: int in range(18):
		_embers.append(Vector3(610 + (index * 29) % 76, 286 - (index * 17) % 52, index * 0.57))
	for index: int in range(28):
		_dust.append(Vector3(145 + (index * 181) % 990, 155 + (index * 73) % 430, index * 0.83))
	queue_redraw()

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()

func _draw() -> void:
	# Fireplace glow and layered, irregular flames.
	var breathe: float = 1.0 + sin(_time * 2.2) * 0.035
	draw_circle(Vector2(640, 285), 104.0 * breathe, Color(1.0, 0.42, 0.12, 0.035))
	draw_circle(Vector2(640, 282), 62.0 * breathe, Color(1.0, 0.62, 0.22, 0.055))
	for index: int in range(10):
		var phase: float = _time * (4.0 + index * 0.13) + index * 1.7
		var x: float = 608.0 + index * 7.0 + sin(phase) * 2.0
		var height: float = 15.0 + (index % 4) * 5.0 + sin(phase * 1.3) * 4.0
		var color := Color("#f07a3f") if index % 2 else Color("#ffd27b")
		draw_colored_polygon(PackedVector2Array([
			Vector2(x - 4, 292), Vector2(x, 292 - height),
			Vector2(x + 5, 292), Vector2(x + 1, 284)
		]), color)

	# Candle flames: each flickers at a slightly different rhythm.
	for index: int in range(3):
		var origin: Vector2 = [Vector2(568, 174), Vector2(704, 174), Vector2(178, 553)][index]
		var sway: float = sin(_time * (5.4 + index) + index) * 2.0
		draw_circle(origin, 22.0 + sin(_time * 3.0 + index) * 2.0, Color(1.0, 0.69, 0.28, 0.045))
		draw_colored_polygon(PackedVector2Array([
			origin + Vector2(-3, 5), origin + Vector2(sway, -8), origin + Vector2(3, 5)
		]), Color("#ffd991"))

	# Slow dust and occasional orange embers.
	for particle: Vector3 in _dust:
		var pos := Vector2(
			particle.x + sin(_time * 0.32 + particle.z) * 12.0,
			particle.y + fmod(_time * (2.5 + fmod(particle.z, 2.0)), 34.0) - 17.0
		)
		draw_rect(Rect2(pos, Vector2(2, 2)), Color(0.88, 0.80, 0.65, 0.22))
	for particle: Vector3 in _embers:
		var rise: float = fmod(_time * 24.0 + particle.z * 19.0, 68.0)
		var pos := Vector2(particle.x + sin(_time * 2.3 + particle.z) * 8.0, particle.y - rise)
		draw_rect(Rect2(pos, Vector2(2, 3)), Color(1.0, 0.49, 0.17, maxf(0.0, 0.75 - rise / 90.0)))
