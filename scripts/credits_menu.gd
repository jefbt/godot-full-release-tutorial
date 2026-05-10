extends Control

func _ready() -> void:
	$ReturnButton.grab_focus()

func _on_return_button_pressed() -> void:
	GameManager.play_cancel_ui_sfx()
	GameManager.load_main_menu()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		GameManager.play_cancel_ui_sfx()
		GameManager.load_main_menu()
