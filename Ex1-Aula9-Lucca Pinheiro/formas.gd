extends Node2D

# ============================
#   POSIÇÕES DAS FORMAS
# ============================
const POS_TRI := Vector2(150, 120)
const POS_HEX := Vector2(420, 120)
const POS_STAR := Vector2(690, 120)
const BASE_R := 70

# ============================
#   PALETA INICIAL
# ============================
var col_outline: Color = Color(0.6, 0.1, 0.9)
var col_fill: Color = Color(0.1, 0.8, 0.2)

var col_a := Color(1, 0, 0)
var col_b := Color(0, 1, 0)
var col_c := Color(0, 0, 1)
var col_d := Color(1, 0, 1)

@export var texture_pattern: Texture2D
@export var t_x := 2
@export var t_y := 2
var tint_pattern := Color(1, 1, 1, 1)


func _ready() -> void:
	randomize()
	queue_redraw()


func _input(event):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		_update_random_colors()
		queue_redraw()


func _update_random_colors():
	col_outline = Color(randf(), randf(), randf())
	col_fill = Color(randf(), randf(), randf())

	col_a = Color(randf(), 0, 0)
	col_b = Color(0, randf(), 0)
	col_c = Color(0, 0, randf())
	col_d = Color(randf(), randf(), randf())

	tint_pattern = col_fill


func _draw():

	# TRIÂNGULO
	var tri = _make_regular_polygon(POS_TRI, 3, BASE_R)
	_render_shape(tri)

	# HEXÁGONO
	var hex = _make_regular_polygon(POS_HEX, 6, BASE_R)
	_render_shape(hex)

	# ESTRELA
	var star = _make_star_polygon(POS_STAR, 5, BASE_R, BASE_R * 0.45)
	_render_shape(star)


# ====================================================
#    FUNÇÃO ÚNICA DE DESENHO QUE CHAMA TODAS AS ETAPAS
# ====================================================

func _render_shape(points: PackedVector2Array):

	# contorno
	draw_polyline(points + PackedVector2Array([points[0]]), col_outline, 3)

	# área sólida
	draw_polygon(points, PackedColorArray([col_fill]))

	# interpolação de cores por vértice
	var cols := PackedColorArray()
	for i in range(points.size()):
		match i % 4:
			0: cols.append(col_a)
			1: cols.append(col_b)
			2: cols.append(col_c)
			3: cols.append(col_d)

	draw_polygon(points, cols)

	# textura tileada
	if texture_pattern:
		_apply_tiled_pattern(points)


# ====================================================
#        DESENHA A TEXTURA REPETIDA NO POLÍGONO
# ====================================================

func _apply_tiled_pattern(pts: PackedVector2Array):
	if not texture_pattern:
		return

	var minx = pts[0].x
	var maxx = pts[0].x
	var miny = pts[0].y
	var maxy = pts[0].y

	for v in pts:
		minx = min(minx, v.x)
		maxx = max(maxx, v.x)
		miny = min(miny, v.y)
		maxy = max(maxy, v.y)

	var bounds := Rect2(Vector2(minx, miny), Vector2(maxx - minx, maxy - miny))
	var step_x = bounds.size.x / t_x
	var step_y = bounds.size.y / t_y

	for yy in range(t_y):
		for xx in range(t_x):
			var pos = bounds.position + Vector2(xx * step_x, yy * step_y)
			var r := Rect2(pos, Vector2(step_x, step_y))
			draw_texture_rect(texture_pattern, r, false, tint_pattern)


# ====================================================
#        GERADORES DE POLÍGONOS
# ====================================================

func _make_regular_polygon(center: Vector2, sides: int, rad: float) -> PackedVector2Array:
	var arr := PackedVector2Array()
	for i in range(sides):
		var ang = i * TAU / sides - PI / 2
		arr.append(center + Vector2(cos(ang), sin(ang)) * rad)
	return arr


func _make_star_polygon(center: Vector2, spikes: int, r_big: float, r_small: float) -> PackedVector2Array:
	var arr := PackedVector2Array()

	for i in range(spikes * 2):
		var use_r = r_big if i % 2 == 0 else r_small
		var ang = i * TAU / (spikes * 2) - PI / 2
		arr.append(center + Vector2(cos(ang), sin(ang)) * use_r)

	return arr
