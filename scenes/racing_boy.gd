extends Area3D

# --- TUNING ---
@export var rocket_speed: float = 40.0
@export var aim_duration: float = 1.3
@export var flash_duration: float = 0.25
@export var spawn_behind_x: float = -20.0
@export var road_width: float = 2.8

# --- SWERVING / WEAVING (LẠNG LÁCH) ---
@export var weave_frequency: float = 4.5    # How fast they swing left and right
@export var weave_amplitude: float = 3.5    # How wide they swerve
@export var lean_tilt_angle: float = 30.0   # Leaning visual angle

enum State { AIMING, FLASHING, DASHING }
var current_state: State = State.AIMING

@onready var body_mesh: MeshInstance3D = $BodyMesh
@onready var warning_line: MeshInstance3D = $WarningLine

var red_mat: StandardMaterial3D = StandardMaterial3D.new()
var white_mat: StandardMaterial3D = StandardMaterial3D.new()

var time_elapsed: float = 0.0
var random_offset: float = 0.0 # Gives each racing boy a different rhythm

func _ready() -> void:
	# Random rhythm offset so pairs don't move identically
	random_offset = randf_range(0.0, 100.0)

	position.x = spawn_behind_x
	position.y = 1.0
	if position.z == 0.0:
		position.z = randf_range(-road_width, road_width)

	# Setup Laser Materials
	red_mat.albedo_color = Color(1.0, 0.0, 0.0, 0.8)
	red_mat.emission_enabled = true
	red_mat.emission = Color(1.0, 0.0, 0.0)

	white_mat.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
	white_mat.emission_enabled = true
	white_mat.emission = Color(2.0, 2.0, 2.0)

	warning_line.position.x = 25.0
	warning_line.position.y = -0.45
	warning_line.material_override = red_mat

	body_entered.connect(_on_body_entered)
	start_charge_sequence()

func start_charge_sequence() -> void:
	# 1. Aiming (Laser sweeps across road)
	current_state = State.AIMING
	warning_line.material_override = red_mat
	await get_tree().create_timer(aim_duration).timeout

	# 2. Flash White
	current_state = State.FLASHING
	warning_line.material_override = white_mat
	await get_tree().create_timer(flash_duration).timeout

	# 3. Rocket Dash!
	current_state = State.DASHING
	warning_line.hide()

func _physics_process(delta: float) -> void:
	time_elapsed += delta

	# --- UNPREDICTABLE WEAVING (Z AXIS) ---
	# Uses sine wave calculation for smooth, frantic swerving
	var lateral_velocity = cos((time_elapsed * weave_frequency) + random_offset) * weave_amplitude
	position.z += lateral_velocity * delta
	position.z = clamp(position.z, -road_width, road_width)

	# Lean into the swerve
	var target_tilt = deg_to_rad(-lateral_velocity * 5.0)
	body_mesh.rotation.x = lerp_angle(body_mesh.rotation.x, target_tilt, 15.0 * delta)

	# --- FORWARD DASHING (X AXIS) ---
	if current_state == State.DASHING:
		position.x += rocket_speed * delta

		# Despawn if they survived and drove off into horizon
		if position.x > 80.0:
			queue_free()

func _on_body_entered(body: Node3D) -> void:
	if is_queued_for_deletion():
		return

	# 1. Hit Player -> Game Over
	if "Player" in body.name or body.is_in_group("player"):
		print("HIT PLAYER! 💥")
		get_tree().reload_current_scene()
		return

	# 2. ONLY explode on obstacles AFTER passing the player (in front of the camera)!
	if current_state == State.DASHING and position.x > 1.0:
		print("RACING BOY SMASHED INTO OBSTACLE AHEAD! 💥")
		queue_free()
