extends Area3D

# --- SETTINGS ---
@export var rocket_speed: float = 40.0     # Overtaking speed
@export var aim_duration: float = 1.2
@export var flash_duration: float = 0.25
@export var spawn_behind_x: float = -20.0  # Spawns behind the camera
@export var road_width: float = 2.8

enum State { AIMING, FLASHING, DASHING }
var current_state: State = State.AIMING

@onready var body_mesh: MeshInstance3D = $BodyMesh
@onready var warning_line: MeshInstance3D = $WarningLine

var red_mat: StandardMaterial3D = StandardMaterial3D.new()
var white_mat: StandardMaterial3D = StandardMaterial3D.new()

func _ready() -> void:
	# 1. Spawn BEHIND the player at random road position
	position.x = spawn_behind_x
	position.y = 1.0
	if position.z == 0.0:
		position.z = randf_range(-road_width, road_width)

	# 2. Glowing Line materials
	red_mat.albedo_color = Color(1.0, 0.0, 0.0, 0.8)
	red_mat.emission_enabled = true
	red_mat.emission = Color(1.0, 0.0, 0.0)

	white_mat.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
	white_mat.emission_enabled = true
	white_mat.emission = Color(2.0, 2.0, 2.0)

	# 3. Laser line shoots FORWARD past the player
	warning_line.position.x = 25.0 # Extends forward down the street
	warning_line.position.y = -0.45
	warning_line.material_override = red_mat

	body_entered.connect(_on_body_entered)
	start_charge_sequence()

func start_charge_sequence() -> void:
	# Aiming (Red)
	current_state = State.AIMING
	warning_line.material_override = red_mat
	await get_tree().create_timer(aim_duration).timeout

	# Flash White
	current_state = State.FLASHING
	warning_line.material_override = white_mat
	await get_tree().create_timer(flash_duration).timeout

	# ROCKET PAST FROM BEHIND!
	current_state = State.DASHING
	warning_line.hide()

func _physics_process(delta: float) -> void:
	if current_state == State.DASHING:
		# Zoom forward past player (+X direction)
		position.x += rocket_speed * delta

		# Despawn once far ahead in the distance
		if position.x > 80.0:
			queue_free()

func _on_body_entered(body: Node3D) -> void:
	if "Player" in body.name or body.is_in_group("player"):
		print("REAR-ENDED BY RACING BOY! 💥")
		get_tree().reload_current_scene()
		
