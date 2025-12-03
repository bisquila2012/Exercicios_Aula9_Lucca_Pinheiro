extends Node3D

# ============================================================
# ======================= REFERÊNCIAS ==========================
# ============================================================

@onready var dynamic_light: SpotLight3D = $DynamicLight


# ============================================================
# ===================== FUNÇÕES AUXILIARES ====================
# ============================================================

func _generate_random_color() -> Color:
	var h := randf()
	var s := randf_range(0.7, 1.0)
	var v := randf_range(0.7, 1.0)
	return Color.from_hsv(h, s, v)


# ============================================================
# ====================== CONTROLE DE INPUT ====================
# ============================================================

func _input(event) -> void:
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:

		# Nova cor aleatória
		var new_col := _generate_random_color()

		# Aplicar à SpotLight3D
		dynamic_light.light_color = new_col

		# (Opcional)
		# $DirectionalLight3D.light_color = new_col.darkened(0.5)


# ============================================================
# ============================ READY ==========================
# ============================================================

func _ready() -> void:
	# Garante que este nó sempre receba eventos de input
	set_process_input(true)
