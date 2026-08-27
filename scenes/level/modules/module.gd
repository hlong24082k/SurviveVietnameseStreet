extends Node3D

const DESPAWN_X_THRESHOLD: float = -15.0

@export var speed: float = 10.0

@onready var level: Node = $"../"


func _physics_process(delta: float) -> void:
	position.x -= speed * delta
	if position.x < DESPAWN_X_THRESHOLD:
		if level and level.has_method("spawnModule"):
			level.spawnModule(position.x + (level.amnt * level.offset))
		queue_free()
