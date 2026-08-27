extends Area3D

enum State { AIMING, FLASHING, DASHING }

const INITIAL_POSITION_Y: float = 1.0
const WARNING_LINE_OFFSET_X: float = 25.0
const WARNING_LINE_OFFSET_Y: float = -0.45
const TILT_VELOCITY_FACTOR: float = 6.0
const TILT_LERP_SPEED: float = 15.0
const DESPAWN_X_THRESHOLD: float = 90.0

const COLOR_RED_LINE: Color = Color(1.0, 0.0, 0.0, 0.8)
const EMISSION_RED_LINE: Color = Color(2.0, 0.0, 0.0)
const COLOR_WHITE_LINE: Color = Color(1.0, 1.0, 1.0, 1.0)
const EMISSION_WHITE_LINE: Color = Color(3.0, 3.0, 3.0)

# --- SETTINGS ---
@export var rocket_speed: float = 45.0
@export var aim_duration: float = 1.2
@export var flash_duration: float = 0.25
@export var spawn_behind_x: float = -20.0
@export var road_width: float = 3.5

# --- WEAVING ---
@export var weave_frequency: float = 4.5
@export var weave_amplitude: float = 3.0

var current_state: State = State.AIMING
var time_elapsed: float = 0.0
var random_offset: float = 0.0

var red_mat: StandardMaterial3D = StandardMaterial3D.new()
var white_mat: StandardMaterial3D = StandardMaterial3D.new()

@onready var body_mesh: MeshInstance3D = $BodyMesh as MeshInstance3D
@onready var warning_line: MeshInstance3D = $WarningLine as MeshInstance3D


func _ready() -> void:
	random_offset = randf_range(0.0, 100.0)
	position.x = spawn_behind_x
	position.y = INITIAL_POSITION_Y

	_setup_materials()
	_setup_warning_line()
	start_charge_sequence()


func start_charge_sequence() -> void:
	# 1. Aiming (Red)
	current_state = State.AIMING
	warning_line.material_override = red_mat
	await get_tree().create_timer(aim_duration).timeout
	if not is_inside_tree():
		return

	# 2. Flash White
	current_state = State.FLASHING
	warning_line.material_override = white_mat
	await get_tree().create_timer(flash_duration).timeout
	if not is_inside_tree():
		return

	# 3. Rocket Dash!
	current_state = State.DASHING
	warning_line.hide()


func _physics_process(delta: float) -> void:
	time_elapsed += delta

	var lateral_velocity: float = _update_lateral_weaving(delta)
	_update_body_tilt(lateral_velocity, delta)

	if current_state == State.DASHING:
		_process_dash(delta)


func _setup_materials() -> void:
	red_mat.albedo_color = COLOR_RED_LINE
	red_mat.emission_enabled = true
	red_mat.emission = EMISSION_RED_LINE

	white_mat.albedo_color = COLOR_WHITE_LINE
	white_mat.emission_enabled = true
	white_mat.emission = EMISSION_WHITE_LINE


func _setup_warning_line() -> void:
	warning_line.position.x = WARNING_LINE_OFFSET_X
	warning_line.position.y = WARNING_LINE_OFFSET_Y
	warning_line.material_override = red_mat


func _update_lateral_weaving(delta: float) -> float:
	var lateral_velocity: float = cos((time_elapsed * weave_frequency) + random_offset) * weave_amplitude
	position.z += lateral_velocity * delta
	position.z = clamp(position.z, -road_width, road_width)
	return lateral_velocity


func _update_body_tilt(lateral_velocity: float, delta: float) -> void:
	var target_tilt: float = deg_to_rad(-lateral_velocity * TILT_VELOCITY_FACTOR)
	body_mesh.rotation.x = lerp_angle(body_mesh.rotation.x, target_tilt, TILT_LERP_SPEED * delta)


func _process_dash(delta: float) -> void:
	position.x += rocket_speed * delta
	_check_dash_collisions()

	# Despawn if drove off safely into horizon
	if position.x > DESPAWN_X_THRESHOLD:
		queue_free()


func _check_dash_collisions() -> void:
	for body: Node3D in get_overlapping_bodies():
		# 1. Hit the Player -> Game Over
		if "Player" in body.name or body.is_in_group("player"):
			print("HIT PLAYER! 💥")
			if body.has_method("trigger_crash"):
				body.trigger_crash()
			return

		# 2. Hit an obstacle / red block -> Wipeout & Delete!
		if position.x > 0.0 and (body is StaticBody3D or body.is_in_group("obstacle")):
			print("RACING BOY SMASHED & DELETED! 💥")
			queue_free()
			return
