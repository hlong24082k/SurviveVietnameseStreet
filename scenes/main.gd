extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var ui: CanvasLayer = $UI

func _ready() -> void:
	if player and ui:
		player.player_died.connect(ui.show_game_over)
