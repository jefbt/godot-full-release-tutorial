# Central game manager singleton. Handles level loading, UI updates, collectibles,
# player respawn, scoring, and game state management.
extends Node

# Collision Layers:
#	1(1): ground
#	2(2): player
#	3(4): creatures
#	4(8): collectibles

# UI element references
@onready var animated_sprite_a: AnimatedSprite2D = $CanvasLayer/AnimatedSpriteA
@onready var animated_sprite_b: AnimatedSprite2D = $CanvasLayer/AnimatedSpriteB
@onready var animated_sprite_c: AnimatedSprite2D = $CanvasLayer/AnimatedSpriteC
@onready var player_respawn_timer: Timer = $PlayerRespawnTimer
@onready var animated_sprite_orbs: AnimatedSprite2D = $CanvasLayer/AnimatedSpriteOrbs
@onready var orbs_collected_label: Label = $CanvasLayer/OrbsCollectedLabel
@onready var pause_panel: Panel = $CanvasLayer/PausePanel
@onready var previous_level_button: Button = $CanvasLayer/PausePanel/PreviousLevelButton
@onready var next_level_button: Button = $CanvasLayer/PausePanel/NextLevelButton
@onready var resume_button: Button = 	$CanvasLayer/PausePanel/ResumeButton
@onready var orb_sfx: AudioStreamPlayer2D = $OrbSFX
@onready var gem_asfx: AudioStreamPlayer2D = $GemASFX
@onready var gem_bsfx: AudioStreamPlayer2D = $GemBSFX
@onready var gem_csfx: AudioStreamPlayer2D = $GemCSFX
@onready var level_finish_sfx: AudioStreamPlayer2D = $LevelFinishSFX
@onready var music_player: AudioStreamPlayer2D = $MusicPlayer
@onready var cancel_uisfx: AudioStreamPlayer2D = $CancelUISFX
@onready var accept_uisfx: AudioStreamPlayer2D = $AcceptUISFX
@onready var select_uisfx: AudioStreamPlayer2D = $SelectUISFX

const THREE_RED_HEARTS_BOX_JUMP = preload("res://assets/audio/Three Red Hearts Box Jump.ogg")
const THREE_RED_HEARTS_CANDY = preload("res://assets/audio/Three Red Hearts Candy.ogg")
const THREE_RED_HEARTS_DEEP_BLUE = preload("res://assets/audio/Three Red Hearts Deep Blue.ogg")
const THREE_RED_HEARTS_PENGUIN_TOWN = preload("res://assets/audio/Three Red Hearts Penguin Town.ogg")
const THREE_RED_HEARTS_PRINCESS_QUEST = preload("res://assets/audio/Three Red Hearts Princess Quest.ogg")
const THREE_RED_HEARTS_RABBIT_TOWN = preload("res://assets/audio/Three Red Hearts Rabbit Town.ogg")
const THREE_RED_HEARTS_SANCTUARY = preload("res://assets/audio/Three Red Hearts Sanctuary.ogg")
const VFX_BASE = preload("res://scenes/vfx.tscn")

var random_songs: Array = [
	THREE_RED_HEARTS_BOX_JUMP,
	THREE_RED_HEARTS_CANDY,
	THREE_RED_HEARTS_DEEP_BLUE,
	THREE_RED_HEARTS_PENGUIN_TOWN,
	THREE_RED_HEARTS_PRINCESS_QUEST,
	THREE_RED_HEARTS_RABBIT_TOWN,
	THREE_RED_HEARTS_SANCTUARY,
]

# Level configuration
@export var levels_path: String = "res://levels"
@export var start_on_level: int = 1

# Game state variables
@export var levels: Array[String] = []

var current_level_index: int = 0
var current_level: Level = null
var player: Player = null
# Collectible items state (A, B, C)
var collected: Array[bool] = [false, false, false]
# Scoring and statistics
var level_orbs: int = 0
var total_orbs: int = 0
var total_time_taken: float = 0
var level_start_time: float = 0
var total_knock_outs: int = 0
var max_orbs: int = 0
var orbs_per_level: Array[int] = []
var orbs_on_level: Array[int] = []
var time_on_level: Array[float] = []
var max_level_reached: int = 1

# Update all UI elements based on current game state
func update_ui() -> void:
	animated_sprite_a.visible = collected[0]
	animated_sprite_b.visible = collected[1]
	animated_sprite_c.visible = collected[2]
	if level_orbs > 0:
		animated_sprite_orbs.visible = true
		orbs_collected_label.visible = true
		orbs_collected_label.text = str(level_orbs)
	else:
		animated_sprite_orbs.visible = false
		orbs_collected_label.visible = false
	if current_level_index > 1:
		previous_level_button.visible = true
		previous_level_button.disabled = false
	else:
		previous_level_button.visible = false
		previous_level_button.disabled = true
	if current_level_index < max_level_reached:
		next_level_button.visible = true
		next_level_button.disabled = false
	else:
		next_level_button.visible = false
		next_level_button.disabled = true
	pause_panel.visible = get_tree().paused
	if pause_panel.visible:
		resume_button.grab_focus()

# Initialize and start the game at the specified level
func start_game() -> void:
	get_tree().paused = false
	await get_tree().process_frame
	if start_on_level >= 0 and start_on_level < levels.size():
		current_level_index = start_on_level
		start_on_level = -1
	get_tree().change_scene_to_file(levels[current_level_index])
	update_ui()
	level_start_time = Time.get_ticks_msec()
	music_player.stop()
	music_player.stream = random_songs.pick_random()
	await get_tree().process_frame
	music_player.play()
	
# Set the current level and reset level-specific state
func set_level(level: Level) -> void:
	current_level = level
	level_orbs = 0
	for c in collected.size():
		collected[c] = false
	if current_level_index > 0 and current_level_index < levels.size() - 2:
		orbs_per_level[current_level_index] = current_level.max_orbs
	update_ui()

# Register the player instance
func set_player(_player: Player) -> void:
	player = _player

func call_jump_vfx(pos: Vector2) -> void:
	_call_vfx("jump", pos)

func call_hit_vfx(pos: Vector2) -> void:
	_call_vfx("hit", pos, false, true)
	
func call_collect_vfx(pos: Vector2) -> void:
	var vfx = _call_vfx("collect", pos)
	vfx.scale = Vector2.ONE * 2

func _call_vfx(animation: String, pos: Vector2, flip: bool = false, random_flip: bool = false) -> VFX:
	var vfx = VFX_BASE.instantiate() as VFX
	vfx.start_vfx(animation)
	current_level.add_child(vfx)
	if flip or (random_flip and randf() <= 0.5):
		vfx.animated_sprite.flip_h = true
	vfx.global_position = pos
	return vfx
	
# Handle level completion - update stats and load next level
func on_level_finished(pos: Vector2) -> void:
	var level_time = Time.get_ticks_msec() - level_start_time
	if level_time < time_on_level[current_level_index] or time_on_level[current_level_index] < 0:
		time_on_level[current_level_index] = level_time
	total_time_taken = 0.0
	for t in time_on_level:
		total_time_taken += t
	
	max_orbs = 0
	for o in orbs_per_level:
		max_orbs += o
		
	if orbs_on_level[current_level_index] < level_orbs:
		orbs_on_level[current_level_index] = level_orbs
	total_orbs = 0
	for o in orbs_on_level:
		total_orbs += o
		
	get_tree().paused = true
	level_finish_sfx.play()
	var vfx = _call_vfx("finish", pos)
	vfx.process_mode = Node.PROCESS_MODE_ALWAYS
	await vfx.animated_sprite.animation_finished
	
	# TODO make level transition/loading screen etc
	current_level_index += 1
	if current_level_index > max_level_reached:
		max_level_reached = current_level_index
	
	save_data()
	
	if current_level_index >= 0 and current_level_index < levels.size():
		current_level = null
		player = null
		level_orbs = 0
		for c in collected.size():
			collected[c] = false
		start_game()
	else:
		print("No more levels")
		# TODO return to menu

# Handle collection of A, B, C collectibles and check for level completion
func collect(collectible: Collectible) -> void:
	if collectible.type == Collectible.Type.A:
		collected[0] = true
		gem_asfx.play()
		call_collect_vfx(collectible.global_position)
	if collectible.type == Collectible.Type.B:
		collected[1] = true
		gem_bsfx.play()
		call_collect_vfx(collectible.global_position)
	if collectible.type == Collectible.Type.C:
		collected[2] = true
		gem_csfx.play()
		call_collect_vfx(collectible.global_position)
	if current_level:
		current_level.on_collected(collectible)
		var can_finish_level: bool = true
		for c in collected:
			if not c:
				can_finish_level = false
				break
		if can_finish_level:
			current_level.on_get_all_collectibles()
	collectible.queue_free()
	update_ui()

# Handle orb collection for scoring
func collect_orb(orb: Orb) -> void:
	orb_sfx.play()
	level_orbs += 1
	update_ui()
	await orb.animated_sprite.animation_finished
	orb.queue_free()

# Handle player being knocked out - start respawn timer
func player_knockout(_player: Player, _source: Node2D) -> void:
	if player != _player:
		_player.queue_free()
		return
	total_knock_outs += 1
	player_respawn_timer.start()

# Respawn player and reset level progress
func respawn_player() -> void:
	for c in collected.size():
		collected[c] = false
	level_orbs = 0
	get_tree().reload_current_scene()
	update_ui()

# Handle creature being defeated
func creature_knockout(creature: Creature, _source: Node2D) -> void:
	call_hit_vfx(creature.global_position)
	creature.queue_free()

# Initialize game manager - set up UI and load level list
func _ready() -> void:
	if $CanvasLayer/PausePanel.visible:
		$CanvasLayer/PausePanel.visible = false
	RenderingServer.set_default_clear_color(Color.CORNFLOWER_BLUE)
	animated_sprite_a.visible = false
	animated_sprite_b.visible = false
	animated_sprite_c.visible = false
	animated_sprite_orbs.visible = false
	orbs_collected_label.visible = false
	if not levels or levels.is_empty():
		levels = get_levels(levels_path)
		if not levels or levels.is_empty():
			levels = ["res://levels/level.tscn"]
	
	for i in levels.size():
		orbs_per_level.append(0)
	if not load_data():
		orbs_on_level = []
		time_on_level = []
		for i in levels.size():
			orbs_per_level.append(0)
			orbs_on_level.append(0)
			time_on_level.append(-1)

# Scan directory for level files and return sorted list
func get_levels(path: String, begins_with: String = "level_") -> Array[String]:
	var files: Array[String] = []
	var dir := DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var is_dir: bool = dir.current_is_dir()
			var begins: bool = file_name.ends_with(".tscn")
			var ends: bool = file_name.begins_with(begins_with)
			if not is_dir and begins and ends:
				var full_path = path + "/" + file_name
				print(full_path)
				files.append(full_path)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		return []
	return files

# Handle pause input
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") and current_level:
		get_tree().paused = not get_tree().paused
		update_ui()

# Respawn timer expired - respawn player
func _on_player_respawn_timer_timeout() -> void:
	respawn_player()

# Go to previous level
func _on_previous_level_button_pressed() -> void:
	current_level_index = max(current_level_index - 1, 1)
	if current_level_index >= 0 and current_level_index < levels.size():
		play_accept_ui_sfx()
		current_level = null
		player = null
		level_orbs = 0
		for c in collected.size():
			collected[c] = false
		start_game()
	else:
		play_cancel_ui_sfx()

# Go to next unlocked level
func _on_next_level_button_pressed() -> void:
	current_level_index = min(current_level_index + 1, max_level_reached)
	if current_level_index >= 0 and current_level_index < levels.size():
		play_accept_ui_sfx()
		current_level = null
		player = null
		level_orbs = 0
		for c in collected.size():
			collected[c] = false
		start_game()
	else:
		play_cancel_ui_sfx()

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	update_ui()
	GameManager.play_cancel_ui_sfx()

func unload_game() -> void:
	animated_sprite_a.visible = false
	animated_sprite_b.visible = false
	animated_sprite_c.visible = false
	animated_sprite_orbs.visible = false
	orbs_collected_label.visible = false
	pause_panel.visible = false
	get_tree().paused = false

func load_main_menu() -> void:
	unload_game()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	start_music()

func load_credits_menu() -> void:
	unload_game()
	get_tree().change_scene_to_file("res://scenes/credits_menu.tscn")

func load_settings_menu() -> void:
	unload_game()
	get_tree().change_scene_to_file("res://scenes/settings_menu.tscn")

func load_level_select_menu() -> void:
	unload_game()
	get_tree().change_scene_to_file("res://scenes/level_select_menu.tscn")

func _on_return_menu_button_pressed() -> void:
	GameManager.play_accept_ui_sfx()
	load_main_menu()
	
func start_music() -> void:
	music_player.stop()
	music_player.stream = random_songs.pick_random()
	await get_tree().process_frame
	music_player.play()

func save_data() -> void:
	var data: Dictionary = {}
	
	data["total_knock_outs"] = total_knock_outs
	data["max_level_reached"] = max_level_reached
	data["orbs"] = []
	data["time"] = []
	
	for l in levels.size():
		if orbs_on_level.size() > l:
			data["orbs"].append(orbs_on_level[l])
		else:
			data["orbs"].append(0)
		if time_on_level.size() > l:
			data["time"].append(time_on_level[l])
		else:
			data["time"].append(-1)

	var json_string = JSON.stringify(data)
	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	file.store_string(json_string)
	file.close()


func load_data() -> bool:
	if not FileAccess.file_exists("user://savegame.json"):
		return false
		
	var file = FileAccess.open("user://savegame.json", FileAccess.READ)
	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_string)

	if error == OK:
		var data = json.data
		total_knock_outs = int(data["total_knock_outs"])
		max_level_reached = int(data["max_level_reached"])
		orbs_on_level = []
		time_on_level = []
		for o in data["orbs"]:
			orbs_on_level.append(int(o))
		for o in data["time"]:
			time_on_level.append(float(o))
	else:
		print("JSON Parse Error: ", json.get_error_message())
		return false
	
	return true

func play_cancel_ui_sfx() -> void:
	cancel_uisfx.play()
	
func play_accept_ui_sfx() -> void:
	accept_uisfx.play()

func play_select_ui_sfx() -> void:
	select_uisfx.play()
	
	


func _on_previous_level_button_focus_entered() -> void:
	GameManager.play_select_ui_sfx()


func _on_next_level_button_focus_entered() -> void:
	GameManager.play_select_ui_sfx()


func _on_resume_button_focus_entered() -> void:
	GameManager.play_select_ui_sfx()


func _on_return_menu_button_focus_entered() -> void:
	GameManager.play_select_ui_sfx()
