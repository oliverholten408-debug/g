extends CharacterBody3D

var move_speed := 7.0
var sprint_speed := 11.0
var gravity := 22.0
var jump_velocity := 7.0
var mouse_sensitivity := 0.0025

var health := 100
var ammo := 30
var reserve_ammo := 120
var mag_size := 30
var weapon_name := "AR-15"
var shoot_cooldown := 0.0
var recoil := 0.0
var can_shoot := true

@onready var camera: Camera3D = $Camera3D

func _ready() -> void:
	add_to_group("player")
	camera.current = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation.y -= event.relative.x * mouse_sensitivity
		camera.rotation.x = clamp(camera.rotation.x - event.relative.y * mouse_sensitivity, deg_to_rad(-80), deg_to_rad(80))

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			shoot()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			change_weapon()

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			reload()
		elif event.keycode == KEY_ESCAPE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _physics_process(delta: float) -> void:
	if shoot_cooldown > 0.0:
		shoot_cooldown = max(0.0, shoot_cooldown - delta)
		if shoot_cooldown == 0.0:
			can_shoot = true

	recoil = lerp(recoil, 0.0, delta * 12.0)
	camera.rotation.x += recoil * delta * 2.0

	var input_dir = Vector2(
		int(Input.is_physical_key_pressed(KEY_D)) - int(Input.is_physical_key_pressed(KEY_A)),
		int(Input.is_physical_key_pressed(KEY_S)) - int(Input.is_physical_key_pressed(KEY_W))
	)

	var move_vec = Vector3.ZERO
	if input_dir.length() > 0.0:
		move_vec = (transform.basis.x * input_dir.x + -transform.basis.z * input_dir.y).normalized()

	var target_speed = sprint_speed if Input.is_physical_key_pressed(KEY_SHIFT) else move_speed

	if move_vec.length() > 0.0:
		velocity.x = move_vec.x * target_speed
		velocity.z = move_vec.z * target_speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_speed)
		velocity.z = move_toward(velocity.z, 0.0, move_speed)

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0
		if Input.is_physical_key_pressed(KEY_SPACE):
			velocity.y = jump_velocity

	move_and_slide()

func shoot() -> void:
	if not can_shoot:
		return
	if ammo <= 0:
		reload()
		return

	ammo -= 1
	can_shoot = false
	shoot_cooldown = 0.10
	recoil = 0.17

	var from = camera.global_position
	var to = from - camera.global_transform.basis.z * 1000.0
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if result and result.collider and result.collider.has_method("apply_damage"):
		result.collider.apply_damage(34)

	if get_parent() and get_parent().has_method("update_hud"):
		get_parent().update_hud()

func reload() -> void:
	if ammo >= mag_size or reserve_ammo <= 0:
		return

	var needed = mag_size - ammo
	var loaded = min(needed, reserve_ammo)
	ammo += loaded
	reserve_ammo -= loaded

	if get_parent() and get_parent().has_method("update_hud"):
		get_parent().update_hud()

func change_weapon() -> void:
	if weapon_name == "AR-15":
		weapon_name = "Pistol"
		mag_size = 12
		move_speed = 7.5
	else:
		weapon_name = "AR-15"
		mag_size = 30
		move_speed = 7.0

	if ammo > mag_size:
		ammo = mag_size

	if get_parent() and get_parent().has_method("update_hud"):
		get_parent().update_hud()

func take_damage(amount: int) -> void:
	health = max(0, health - amount)
	if health <= 0:
		get_tree().reload_current_scene()

	if get_parent() and get_parent().has_method("update_hud"):
		get_parent().update_hud()
