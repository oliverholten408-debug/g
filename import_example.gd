extends Node

@export var speed: float = 200.0

func _ready() -> void:
    print("Import example loaded")

func move(delta: float) -> void:
    position.x += speed * delta
