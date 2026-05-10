extends Control

@onready var quit_button: Button = $QuitButton

func _ready() -> void:
	if OS.has_feature("mobile") or OS.has_feature("web"):
		quit_button.hide()
	$StartButton.grab_focus()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_credits_button_pressed() -> void:
	GameManager.load_credits_menu()


func _on_settings_button_pressed() -> void:
	GameManager.load_settings_menu()


func _on_start_button_pressed() -> void:
	# TODO when we don't have saved data, just go to level 1, else go to level select menu
	if true:
		GameManager.start_game()
	else:
		GameManager.load_level_select_menu()
