# Game entry point node that initializes the game when the scene loads.
extends Node2D

# Start the game
func _ready() -> void:
	GameManager.start_game()
