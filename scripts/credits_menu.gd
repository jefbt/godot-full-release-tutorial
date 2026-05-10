extends Control

func _ready() -> void:
	$ReturnButton.grab_focus()

func _on_return_button_pressed() -> void:
		GameManager.load_main_menu()
