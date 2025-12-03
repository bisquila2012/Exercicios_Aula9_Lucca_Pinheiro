extends Control

# ============================================================
# ======================== CONSTANTES =========================
# ============================================================

const LEVEL_SCENE := preload("res://Level.tscn")


# ============================================================
# ======================== CALLBACK UI ========================
# ============================================================

func _on_button_pressed() -> void:
	# Troca segura de cena
	var error := get_tree().change_scene_to_packed(LEVEL_SCENE)

	if error != OK:
		print("ERRO ao carregar a cena 3D: ", error)
