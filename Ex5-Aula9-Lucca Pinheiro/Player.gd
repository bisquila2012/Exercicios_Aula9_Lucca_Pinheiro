extends CharacterBody3D

# ============================================================
# ====================== CONFIGURAÇÕES =========================
# ============================================================

@export var move_speed: float = 6.0
@export var jump_speed: float = 6.5
@export var accel: float = 12.0
@export var air_control: float = 3.5
@export var camera_sensitivity: float = 2.0

var gravity: float


# ============================================================
# =========================== READY ===========================
# ============================================================

func _ready() -> void:
	# Gravidade padrão do projeto
	gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

	# Trava o mouse (FPS)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# ============================================================
# ======================= LOOP DE FÍSICA ======================
# ============================================================

func _physics_process(delta: float) -> void:

	# 1) Gravidade
	_apply_gravity(delta)

	# 2) Direção de movimento
	var wish_dir := _get_wish_direction()

	# 3) Aceleração / Desaceleração
	_apply_acceleration(wish_dir, delta)

	# 4) Pulo
	_handle_jump()

	# 5) Mover com colisões
	move_and_slide()

	# 6) Rotação (Setas esquerda/direita)
	_handle_rotation(delta)


# ============================================================
# =================== FUNÇÕES DE MOVIMENTO ====================
# ============================================================

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta


func _get_wish_direction() -> Vector3:
	var input_vec := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down")  - Input.get_action_strength("ui_up")
	)

	if input_vec.length() == 0.0:
		return Vector3.ZERO

	input_vec = input_vec.normalized()

	# Movimento relativo à rotação do Player (FPS)
	return (transform.basis * Vector3(input_vec.x, 0.0, input_vec.y)).normalized()


func _apply_acceleration(wish_dir: Vector3, delta: float) -> void:
	var target := wish_dir * move_speed
	var factor := accel * delta if is_on_floor() else air_control * delta
	factor = clamp(factor, 0.0, 1.0)

	velocity.x = lerp(velocity.x, target.x, factor)
	velocity.z = lerp(velocity.z, target.z, factor)


func _handle_jump() -> void:
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_speed


# ============================================================
# ======================= ROTAÇÃO DA CÂMERA ===================
# ============================================================

func _handle_rotation(delta: float) -> void:
	var rot_input := Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	if rot_input == 0.0:
		return

	var amount := -rot_input * camera_sensitivity * delta * 60.0
	rotate_y(deg_to_rad(amount))
