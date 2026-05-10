extends Control

const LEVEL_BUTTON = preload("res://scenes/level_button.tscn")

func _ready() -> void:
	var levels = []
	for l in GameManager.max_level_reached:
		var new_level = LEVEL_BUTTON.instantiate() as LevelButton
		levels.append(new_level)
		new_level.level = l + 1
		$FlowContainer.add_child(new_level)
		new_level.button.grab_focus()
	await get_tree().process_frame
	for l in levels.size():
		levels[l].button.text = str(l + 1)

func _on_return_button_pressed() -> void:
	GameManager.play_cancel_ui_sfx()
	GameManager.load_main_menu()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		GameManager.play_cancel_ui_sfx()
		GameManager.load_main_menu()


func _on_return_button_focus_entered() -> void:
	GameManager.play_select_ui_sfx()
