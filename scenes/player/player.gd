extends CharacterBody3D

signal player_died

const INITIAL_POSITION_X: float = 0.0
const INITIAL_POSITION_Y: float = 1.0
const LATERAL_LERP_SPEED: float = 10.0
const HEAD_ON_COLLISION_NORMAL_X_THRESHOLD: float = -0.5

# --- TUNING SETTINGS ---
@export var steer_speed: float = 12.0  # How fast you steer left / right
@export var road_width: float = 8.0  # Limits how close you can get to the side walls
@export var tilt_angle: float = 20.0  # How much the bike leans when turning (degrees)
@export var tilt_speed: float = 12.0  # How fast the lean responds

var lateral_speed: float = 0.0
var is_dead: bool = false


func _ready() -> void:
	# Make sure player starts centered and flat on the ground
	position.x = INITIAL_POSITION_X
	position.y = INITIAL_POSITION_Y


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	var steer_dir: float = _get_steer_input()
	_apply_movement(steer_dir, delta)
	_apply_tilt(steer_dir, delta)
	check_for_crash()


func check_for_crash() -> void:
	for i: int in get_slide_collision_count():
		var collision: KinematicCollision3D = get_slide_collision(i)
		
		# If an obstacle hits us head-on from the front (X direction)
		if collision.get_normal().x < HEAD_ON_COLLISION_NORMAL_X_THRESHOLD:
			trigger_crash()


func trigger_crash() -> void:
	if is_dead:
		return
	is_dead = true
	print("CRASHED!")
	player_died.emit()


func _get_steer_input() -> float:
	var steer_dir: float = 0.0
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		steer_dir -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		steer_dir += 1.0
	return steer_dir


func _apply_movement(steer_dir: float, delta: float) -> void:
	# Smooth Drifting Movement
	lateral_speed = lerp(lateral_speed, steer_dir * steer_speed, LATERAL_LERP_SPEED * delta)
	velocity.x = 0.0  # Stationary on X (road moves to you)
	velocity.y = 0.0  # Kept on the road surface
	velocity.z = lateral_speed

	move_and_slide()

	# Lock X position to 0 so moving walls never pull/drag you backwards
	position.x = INITIAL_POSITION_X

	# Clamp Z so you stop before grinding into the angled walls
	position.z = clamp(position.z, -road_width, road_width)


func _apply_tilt(steer_dir: float, delta: float) -> void:
	# Bike Lean / Tilt Effect
	var target_tilt: float = deg_to_rad(-steer_dir * tilt_angle)
	rotation.x = lerp_angle(rotation.x, target_tilt, tilt_speed * delta)
