extends Node3D

@export var racing_boy_scene: PackedScene = preload("res://scenes/racing_boy.tscn")
@export var spawn_interval: float = 6.0
@export var road_width: float = 2.8

func _ready() -> void:
	spawn_loop()

func spawn_loop() -> void:
	while true:
		await get_tree().create_timer(spawn_interval).timeout
		spawn_racing_boy_pair()

func spawn_racing_boy_pair() -> void:
	# Pick 2 separate lanes
	var lane1_z = randf_range(-road_width, -0.4) # Left side
	var lane2_z = randf_range(0.4, road_width)  # Right side

	# Spawn Boy 1
	var boy1 = racing_boy_scene.instantiate()
	boy1.position.z = lane1_z
	add_child(boy1)

	# Spawn Boy 2
	var boy2 = racing_boy_scene.instantiate()
	boy2.position.z = lane2_z
	add_child(boy2)
