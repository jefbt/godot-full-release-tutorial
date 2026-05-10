extends Control

@onready var quit_button: Button = $QuitButton

func _ready() -> void:
	if OS.has_feature("mobile") or OS.has_feature("web"):
		quit_button.hide()
	$StartButton.grab_focus()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_credits_button_pressed() -> void:
	GameManager.play_accept_ui_sfx()
	GameManager.load_credits_menu()


func _on_settings_button_pressed() -> void:
	GameManager.play_accept_ui_sfx()
	GameManager.load_settings_menu()


func _on_start_button_pressed() -> void:
	GameManager.play_accept_ui_sfx()
	if GameManager.max_level_reached > 1:
		GameManager.load_level_select_menu()
	else:
		GameManager.start_game()


func _on_start_button_focus_entered() -> void:
	GameManager.play_select_ui_sfx()


func _on_quit_button_focus_entered() -> void:
	GameManager.play_select_ui_sfx()


func _on_credits_button_focus_entered() -> void:
	GameManager.play_select_ui_sfx()


func _on_settings_button_focus_entered() -> void:
	GameManager.play_select_ui_sfx()
