extends Control

@onready var h_slider: HSlider = $ControlMaster/HSlider
@onready var sfxh_slider: HSlider = $ControlSFX/SFXHSlider
@onready var music_h_slider: HSlider = $ControlSFX2/MusicHSlider


func _ready() -> void:
	var bus_idx_master = AudioServer.get_bus_index("Master")
	var bus_idx_sfx = AudioServer.get_bus_index("SFX")
	var bus_idx_music = AudioServer.get_bus_index("Music")
	$HSlider.set_value_no_signal(AudioServer.get_bus_volume_linear(bus_idx_master))
	$SFXHSlider.set_value_no_signal(AudioServer.get_bus_volume_linear(bus_idx_sfx))
	$MusicHSlider.set_value_no_signal(AudioServer.get_bus_volume_linear(bus_idx_music))
	$HSlider.grab_focus()
	pass


func _on_return_button_pressed() -> void:
	GameManager.play_cancel_ui_sfx()
	GameManager.load_main_menu()


func _on_h_slider_value_changed(value: float) -> void:
	var bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_linear(bus_idx, value)


func _on_sfxh_slider_value_changed(value: float) -> void:
	var bus_idx = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_linear(bus_idx, value)
	GameManager.play_select_ui_sfx()


func _on_music_h_slider_value_changed(value: float) -> void:
	var bus_idx = AudioServer.get_bus_index("Music")
	AudioServer.set_bus_volume_linear(bus_idx, value)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		GameManager.play_cancel_ui_sfx()
		GameManager.load_main_menu()


func _on_return_button_focus_entered() -> void:
	GameManager.play_select_ui_sfx()


func _on_music_h_slider_focus_entered() -> void:
	GameManager.play_select_ui_sfx()


func _on_sfxh_slider_focus_entered() -> void:
	GameManager.play_select_ui_sfx()


func _on_h_slider_focus_entered() -> void:
	GameManager.play_select_ui_sfx()
