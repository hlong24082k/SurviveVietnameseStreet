extends CanvasLayer

@onready var start_menu: Control = $StartMenu
@onready var game_over_menu: Control = $GameOverMenu
@onready var start_button: Button = $StartMenu/PanelContainer/MarginContainer/VBoxContainer/StartButton
@onready var restart_button: Button = $GameOverMenu/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/RestartButton
@onready var exit_button: Button = $GameOverMenu/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ExitButton

func _ready() -> void:
	# Ensure the UI receives input and runs even when the tree is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Connect button signals
	start_button.pressed.connect(_on_start_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)

	# Initial state: Show Start menu, hide Game Over menu, and pause game world
	start_menu.show()
	game_over_menu.hide()
	get_tree().paused = true

func _on_start_button_pressed() -> void:
	start_menu.hide()
	get_tree().paused = false

func show_game_over() -> void:
	game_over_menu.show()
	get_tree().paused = true

func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_exit_button_pressed() -> void:
	get_tree().quit()
