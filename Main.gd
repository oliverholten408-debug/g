extends Node3D

@onready var player: CharacterBody3D = $Player

var enemy_scene = preload("res://Enemy.tscn")
var enemy_count_label: Label
var ammo_label: Label
var health_bar: ProgressBar
var weapon_label: Label
var score_label: Label
var objective_label: Label
var crosshair_h: ColorRect
var crosshair_v: ColorRect

var score := 0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	build_hud()
	spawn_wave()
	update_hud()

func _process(_delta: float) -> void:
	if get_tree().get_nodes_in_group("enemies").is_empty():
		spawn_wave()
	update_hud()

func build_hud() -> void:
	var canvas = CanvasLayer.new()
	add_child(canvas)

	var crosshair_root = Control.new()
	canvas.add_child(crosshair_root)

	crosshair_h = ColorRect.new()
	crosshair_h.size = Vector2(20, 2)
	crosshair_h.color = Color(1, 1, 1, 0.9)
	crosshair_root.add_child(crosshair_h)

	crosshair_v = ColorRect.new()
	crosshair_v.size = Vector2(2, 20)
	crosshair_v.color = Color(1, 1, 1, 0.9)
	crosshair_root.add_child(crosshair_v)

	var viewport_size = get_viewport().get_visible_rect().size
	crosshair_h.position = Vector2(viewport_size.x / 2.0 - 10, viewport_size.y / 2.0 - 1)
	crosshair_v.position = Vector2(viewport_size.x / 2.0 - 1, viewport_size.y / 2.0 - 10)

	var panel = PanelContainer.new()
	panel.position = Vector2(20, 20)
	canvas.add_child(panel)

	var vbox = VBoxContainer.new()
	panel.add_child(vbox)

	health_bar = ProgressBar.new()
	health_bar.min_value = 0
	health_bar.max_value = 100
	health_bar.value = 100
	health_bar.custom_minimum_size = Vector2(220, 18)
	health_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(health_bar)

	var stats = HBoxContainer.new()
	vbox.add_child(stats)

	ammo_label = Label.new()
	ammo_label.add_theme_font_size_override("font_size", 18)
	stats.add_child(ammo_label)

	weapon_label = Label.new()
	weapon_label.add_theme_font_size_override("font_size", 18)
	weapon_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats.add_child(weapon_label)

	score_label = Label.new()
	score_label.add_theme_font_size_override("font_size", 18)
	score_label.alignment = HAlignment.RIGHT
	stats.add_child(score_label)

	objective_label = Label.new()
	objective_label.add_theme_font_size_override("font_size", 16)
	objective_label.modulate = Color(0.8, 0.9, 1.0, 1.0)
	vbox.add_child(objective_label)

func update_hud() -> void:
	if player == null:
		return

	health_bar.value = player.health
	ammo_label.text = "Ammo %d / %d" % [player.ammo, player.reserve_ammo]
	weapon_label.text = "Weapon: %s" % player.weapon_name
	score_label.text = "Score: %d" % score
	objective_label.text = "Clear the arena" if get_tree().get_nodes_in_group("enemies").size() > 0 else "Arena clear"

func spawn_wave() -> void:
	for i in range(7):
		var enemy = enemy_scene.instantiate()
		var x = randf_range(-14.0, 14.0)
		var z = randf_range(-12.0, 12.0)
		enemy.position = Vector3(x, 1.0, z)
		add_child(enemy)
		enemy.add_to_group("enemies")

func add_score(amount: int) -> void:
	score += amount
	update_hud()
