extends CharacterBody3D

# --- TUNING SETTINGS ---
@export var steer_speed: float = 12.0        # How fast you steer left / right
@export var road_width: float = 3.2          # Limits how close you can get to the side walls
@export var tilt_angle: float = 20.0         # How much the bike leans when turning (degrees)
@export var tilt_speed: float = 12.0         # How fast the lean responds

var lateral_speed: float = 0.0
var is_dead: bool = false

func _ready() -> void:
	# Make sure player starts centered and flat on the ground
	position.x = 0.0
	position.y = 1.0

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	# 1. Direct Keyboard Input (A / D / Left / Right)
	var steer_dir: float = 0.0
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
		steer_dir -= 1.0
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
		steer_dir += 1.0

	# 2. Smooth Drifting Movement
	lateral_speed = lerp(lateral_speed, steer_dir * steer_speed, 10.0 * delta)
	velocity.x = 0.0  # Stationary on X (road moves to you)
	velocity.y = 0.0  # Kept on the road surface
	velocity.z = lateral_speed

	move_and_slide()

	# 3. FIX: Lock X position to 0 so moving walls never pull/drag you backwards
	position.x = 0.0

	# 4. FIX: Clamp Z so you stop before grinding into the angled walls
	position.z = clamp(position.z, -road_width, road_width)

	# 5. Bike Lean / Tilt Effect
	var target_tilt = deg_to_rad(-steer_dir * tilt_angle)
	rotation.x = lerp_angle(rotation.x, target_tilt, tilt_speed * delta)

	# 6. Check if an incoming red block hits us from the front
	check_for_crash()

func check_for_crash() -> void:
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		
		# If an obstacle hits us head-on from the front (X direction)
		if collision.get_normal().x < -0.5:
			trigger_crash()

func trigger_crash() -> void:
	if is_dead:
		return
	is_dead = true
	print("CRASHED!")
	
	# Instantly reload and restart the game
	get_tree().reload_current_scene()
