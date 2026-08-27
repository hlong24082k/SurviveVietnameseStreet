extends Node3D

const LANE_CENTER_MARGIN: float = 0.4

@export var racing_boy_scene: PackedScene = preload("res://scenes/racing_boy/racing_boy.tscn")
@export var spawn_interval: float = 6.0
@export var road_width: float = 2.8


func _ready() -> void:
	spawn_loop()


func spawn_loop() -> void:
	while is_inside_tree():
		await get_tree().create_timer(spawn_interval).timeout
		if not is_inside_tree():
			return
		spawn_racing_boy_pair()


func spawn_racing_boy_pair() -> void:
	if not racing_boy_scene:
		return

	# Pick 2 separate lanes (Left side and Right side)
	var lane1_z: float = randf_range(-road_width, -LANE_CENTER_MARGIN)
	var lane2_z: float = randf_range(LANE_CENTER_MARGIN, road_width)

	_spawn_racing_boy(lane1_z)
	_spawn_racing_boy(lane2_z)


func _spawn_racing_boy(lane_z: float) -> void:
	var boy: Node3D = racing_boy_scene.instantiate() as Node3D
	boy.position.z = lane_z
	add_child(boy)
