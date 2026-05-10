# Game entry point node that initializes the game when the scene loads.
extends Node2D

@onready var button: Button = $Button

# Start the game
func _ready() -> void:
	await get_tree().create_timer(1).timeout
	button.show()

func _process(_delta: float) -> void:
	if button.visible:
		if Input.is_anything_pressed() or Input.is_action_pressed("jump"):
			GameManager.load_main_menu()


func _on_button_pressed() -> void:
	GameManager.load_main_menu()
