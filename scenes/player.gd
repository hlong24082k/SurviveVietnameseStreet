extends CharacterBody3D

# --- SETTINGS ---
@export var forward_speed: float = 0      # Forward speed down the street
@export var steer_speed: float = 12.0         # Turning speed left/right
@export var road_width: float = 4.0           # Curb limits (adjust if street is wider/narrower)
@export var tilt_angle: float = 20.0          # Bike lean angle

var lateral_speed: float = 0.0

func _ready() -> void:
	# Make sure player starts on the road surface
	position.y = 1.0

func _physics_process(delta: float) -> void:
	var steer_dir: float = 0.0
	
	# Direct Keyboard Checks (A / D / Left / Right)
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		steer_dir -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		steer_dir += 1.0

	# Smooth drifting momentum
	lateral_speed = lerp(lateral_speed, steer_dir * steer_speed, 10.0 * delta)

	# Movement: Moving forward on +X, steering on Z
	velocity.x = forward_speed
	velocity.z = lateral_speed
	velocity.y = 0.0 # Keep flat on the road

	move_and_slide()

	# Keep within road boundaries
	position.z = clamp(position.z, -road_width, road_width)

	# Bike leaning / tilt visual effect
	var target_tilt = deg_to_rad(-steer_dir * tilt_angle)
	rotation.x = lerp_angle(rotation.x, target_tilt, 12.0 * delta)
