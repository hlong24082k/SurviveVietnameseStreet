extends CanvasLayer

@onready var start_menu: Control = $StartMenu as Control
@onready var game_over_menu: Control = $GameOverMenu as Control
@onready var start_button: Button = $StartMenu/PanelContainer/MarginContainer/VBoxContainer/StartButton as Button
@onready var restart_button: Button = $GameOverMenu/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/RestartButton as Button
@onready var exit_button: Button = $GameOverMenu/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ExitButton as Button


func _ready() -> void:
	# Ensure the UI receives input and runs even when the tree is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

	_setup_signals()
	_setup_initial_state()


func show_game_over() -> void:
	game_over_menu.show()
	get_tree().paused = true


func _setup_signals() -> void:
	start_button.pressed.connect(_on_start_button_pressed)
	restart_button.pressed.connect(_on_restart_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)


func _setup_initial_state() -> void:
	start_menu.show()
	game_over_menu.hide()
	get_tree().paused = true


func _on_start_button_pressed() -> void:
	start_menu.hide()
	get_tree().paused = false


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_exit_button_pressed() -> void:
	get_tree().quit()
