extends Area3D

# --- SETTINGS ---
@export var rocket_speed: float = 45.0
@export var aim_duration: float = 1.2
@export var flash_duration: float = 0.25
@export var spawn_behind_x: float = -20.0
@export var road_width: float = 3.5

# --- WEAVING ---
@export var weave_frequency: float = 4.5
@export var weave_amplitude: float = 3.0

enum State { AIMING, FLASHING, DASHING }
var current_state: State = State.AIMING

@onready var body_mesh: MeshInstance3D = $BodyMesh
@onready var warning_line: MeshInstance3D = $WarningLine

var red_mat: StandardMaterial3D = StandardMaterial3D.new()
var white_mat: StandardMaterial3D = StandardMaterial3D.new()

var time_elapsed: float = 0.0
var random_offset: float = 0.0

func _ready() -> void:
	random_offset = randf_range(0.0, 100.0)
	position.x = spawn_behind_x
	position.y = 1.0

	# Line visual setup
	red_mat.albedo_color = Color(1.0, 0.0, 0.0, 0.8)
	red_mat.emission_enabled = true
	red_mat.emission = Color(2.0, 0.0, 0.0)

	white_mat.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
	white_mat.emission_enabled = true
	white_mat.emission = Color(3.0, 3.0, 3.0)

	warning_line.position.x = 25.0
	warning_line.position.y = -0.45
	warning_line.material_override = red_mat

	# Start attack
	start_charge_sequence()

func start_charge_sequence() -> void:
	# 1. Aiming (Red)
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

	# Lateral Weaving
	var lateral_velocity = cos((time_elapsed * weave_frequency) + random_offset) * weave_amplitude
	position.z += lateral_velocity * delta
	position.z = clamp(position.z, -road_width, road_width)

	# Lean into turns
	var target_tilt = deg_to_rad(-lateral_velocity * 6.0)
	body_mesh.rotation.x = lerp_angle(body_mesh.rotation.x, target_tilt, 15.0 * delta)

	# Dashing & Active Collision Check
	if current_state == State.DASHING:
		position.x += rocket_speed * delta

		# CHECK EVERYTHING TOUCHING THE RACING BOY RIGHT NOW
		for body in get_overlapping_bodies():
			# 1. Hit the Player -> Game Over
			if "Player" in body.name or body.is_in_group("player"):
				print("HIT PLAYER! 💥")
				get_tree().reload_current_scene()
				return

			# 2. Hit an obstacle / red block -> Wipeout & Delete!
			if position.x > 0.0 and (body is StaticBody3D or body.is_in_group("obstacle")):
				print("RACING BOY SMASHED & DELETED! 💥")
				queue_free()
				return

		# Despawn if drove off safely into horizon
		if position.x > 90.0:
			queue_free()
