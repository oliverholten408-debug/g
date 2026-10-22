extends CharacterBody3D

var health := 100.0
var speed := 3.4
var attack_cooldown := 0.0
var player: Node3D

func _ready() -> void:
	add_to_group("enemies")
	player = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	if attack_cooldown > 0.0:
		attack_cooldown = max(0.0, attack_cooldown - delta)

func _physics_process(delta: float) -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player")
		if player == null:
			return

	var offset = player.global_position - global_position
	offset.y = 0.0
	var distance = offset.length()

	if distance > 0.1:
		var direction = offset.normalized()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	if not is_on_floor():
		velocity.y -= 18.0 * delta
	else:
		velocity.y = 0.0

	move_and_slide()

	if distance < 1.7 and attack_cooldown <= 0.0 and player.has_method("take_damage"):
		player.take_damage(12)
		attack_cooldown = 1.0

func apply_damage(amount: int) -> void:
	health -= amount
	if health <= 0.0:
		if get_parent() and get_parent().has_method("add_score"):
			get_parent().add_score(100)
		queue_free()
