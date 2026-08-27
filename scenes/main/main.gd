extends Node3D

@onready var player: CharacterBody3D = $Player as CharacterBody3D
@onready var ui: CanvasLayer = $UI as CanvasLayer


func _ready() -> void:
	_connect_signals()


func _connect_signals() -> void:
	if player and ui:
		player.player_died.connect(ui.show_game_over)
