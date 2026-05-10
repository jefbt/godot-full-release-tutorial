class_name LevelButton extends ColorRect

@onready var button: Button = $Button
var level: int = 1

func _on_button_pressed() -> void:
	GameManager.play_accept_ui_sfx()
	GameManager.start_on_level = level
	GameManager.start_game()


func _on_button_focus_entered() -> void:
	GameManager.play_select_ui_sfx()
