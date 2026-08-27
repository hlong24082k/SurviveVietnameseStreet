extends Node3D

const SAFE_START_TILES: int = 3
const DESPAWN_OFFSET_FACTOR: float = 1.5

@export var modules: Array[PackedScene] = []
@export var road_speed: float = 4.0  # Speed the street moves towards the player
@export var offset: float = 3.0  # Length of each tile (adjust so they touch seamlessly)
@export var total_tiles: int = 20  # How many tiles stay loaded on screen

var active_modules: Array[Node3D] = []


func _ready() -> void:
	randomize()
	if modules.is_empty():
		push_error("Please add module scenes into the Level inspector!")
		return

	_build_initial_street()


func _physics_process(delta: float) -> void:
	if active_modules.is_empty():
		return

	_move_active_tiles(delta)
	_recycle_expired_tiles()


func _build_initial_street() -> void:
	for i: int in total_tiles:
		var is_safe_start: bool = (i < SAFE_START_TILES)
		var scene_to_use: PackedScene = modules[0] if is_safe_start else modules.pick_random()
		_spawn_tile(i * offset, scene_to_use)


func _spawn_tile(x_position: float, scene: PackedScene) -> Node3D:
	var piece: Node3D = scene.instantiate() as Node3D
	piece.position.x = x_position
	add_child(piece)
	active_modules.append(piece)
	return piece


func _move_active_tiles(delta: float) -> void:
	for piece: Node3D in active_modules:
		piece.position.x -= road_speed * delta


func _recycle_expired_tiles() -> void:
	if active_modules[0].position.x < -offset * DESPAWN_OFFSET_FACTOR:
		var old_piece: Node3D = active_modules.pop_front()
		old_piece.queue_free()

		var last_piece_x: float = active_modules.back().position.x
		var new_scene: PackedScene = modules.pick_random()
		_spawn_tile(last_piece_x + offset, new_scene)
