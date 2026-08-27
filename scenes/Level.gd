extends Node3D

@export var modules: Array[PackedScene] = []
@export var road_speed: float = 4.0       # Speed the street moves towards the player
@export var offset: float = 3.0          # Length of each tile (adjust so they touch seamlessly)
@export var total_tiles: int = 20          # How many tiles stay loaded on screen

var active_modules: Array[Node3D] = []

func _ready() -> void:
	randomize()
	if modules.is_empty():
		push_error("Please add module scenes into the Level inspector!")
		return

	# Build the initial street
	for i in total_tiles:
		var is_safe_start = (i < 3) # First 3 are clear of obstacles
		var scene_to_use = modules[0] if is_safe_start else modules.pick_random()
		var piece = scene_to_use.instantiate() as Node3D
		piece.position.x = i * offset
		add_child(piece)
		active_modules.append(piece)

func _physics_process(delta: float) -> void:
	if active_modules.is_empty():
		return

	# 1. Move all road tiles backward towards the player (-X direction)
	for piece in active_modules:
		piece.position.x -= road_speed * delta

	# 2. When the first tile passes behind the camera, delete it and spawn a new one at the end!
	if active_modules[0].position.x < -offset * 1.5:
		var old_piece = active_modules.pop_front()
		old_piece.queue_free()

		# Attach new piece to the very end of the street
		var last_piece_x = active_modules.back().position.x
		var new_scene = modules.pick_random()
		var new_piece = new_scene.instantiate() as Node3D
		new_piece.position.x = last_piece_x + offset
		add_child(new_piece)
		active_modules.append(new_piece)
