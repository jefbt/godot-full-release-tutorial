extends Node

# Collision Layers:
#	1(1): ground
#	2(2): player
#	3(4): creatures
#	4(8): collectibles

@onready var animated_sprite_a: AnimatedSprite2D = $CanvasLayer/AnimatedSpriteA
@onready var animated_sprite_b: AnimatedSprite2D = $CanvasLayer/AnimatedSpriteB
@onready var animated_sprite_c: AnimatedSprite2D = $CanvasLayer/AnimatedSpriteC
@onready var player_respawn_timer: Timer = $PlayerRespawnTimer
@onready var animated_sprite_orbs: AnimatedSprite2D = $CanvasLayer/AnimatedSpriteOrbs
@onready var orbs_collected_label: Label = $CanvasLayer/OrbsCollectedLabel
@onready var pause_panel: Panel = $CanvasLayer/PausePanel
@onready var previous_level_button: Button = $CanvasLayer/PausePanel/PreviousLevelButton
@onready var next_level_button: Button = $CanvasLayer/PausePanel/NextLevelButton
@onready var resume_button: Button = $CanvasLayer/PausePanel/ResumeButton

@export var levels_path: String = "res://levels"
@export var start_on_level: int = 1

var levels: Array[String] = []

var current_level_index: int = 0
var current_level: Level = null
var player: Player = null
var collected: Array[bool] = [false, false, false]
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

func start_game() -> void:
	get_tree().paused = false
	await get_tree().process_frame
	if start_on_level >= 0 and start_on_level < levels.size():
		current_level_index = start_on_level
		start_on_level = -1
	get_tree().change_scene_to_file(levels[current_level_index])
	update_ui()
	level_start_time = Time.get_ticks_msec()
	

func set_level(level: Level) -> void:
	current_level = level
	level_orbs = 0
	for c in collected.size():
		collected[c] = false
	if current_level_index > 0 and current_level_index < levels.size() - 2:
		orbs_per_level[current_level_index] = current_level.max_orbs
	update_ui()
	
func set_player(_player: Player) -> void:
	player = _player

func on_level_finished() -> void:
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
	
	# TODO make level transition/loading screen etc
	current_level_index += 1
	if current_level_index > max_level_reached:
		max_level_reached = current_level_index
	
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

func collect(collectible: Collectible) -> void:
	if collectible.type == Collectible.Type.A:
		collected[0] = true
	if collectible.type == Collectible.Type.B:
		collected[1] = true
	if collectible.type == Collectible.Type.C:
		collected[2] = true
	if current_level:
		current_level.on_collected(collectible)
		var can_finish_level: bool = true
		for c in collected:
			if not c:
				can_finish_level = false
				break
		if can_finish_level:
			current_level.on_get_all_collectibles()
	# TODO player collect vfx and sfx
	# TODO check all collectibles
	collectible.queue_free()
	update_ui()

func collect_orb(orb: Orb) -> void:
	level_orbs += 1
	update_ui()
	await orb.animated_sprite.animation_finished
	orb.queue_free()

func player_knockout(_player: Player, _source: Node2D) -> void:
	if player != _player:
		_player.queue_free()
		return
	total_knock_outs += 1
	player_respawn_timer.start()

func respawn_player() -> void:
	for c in collected.size():
		collected[c] = false
	level_orbs = 0
	get_tree().reload_current_scene()
	update_ui()

func creature_knockout(creature: Creature, _source: Node2D) -> void:
	# TODO make animation and stuff
	creature.queue_free()

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.CORNFLOWER_BLUE)
	animated_sprite_a.visible = false
	animated_sprite_b.visible = false
	animated_sprite_c.visible = false
	animated_sprite_orbs.visible = false
	orbs_collected_label.visible = false
	levels = get_levels(levels_path)
	if not levels:
		levels = ["res://levels/level.tscn"]
	for i in levels.size():
		orbs_per_level.append(0)
		orbs_on_level.append(0)
		time_on_level.append(-1)

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

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = not get_tree().paused
		update_ui()

func _on_player_respawn_timer_timeout() -> void:
	respawn_player()

func _on_previous_level_button_pressed() -> void:
	current_level_index = max(current_level_index - 1, 1)
	if current_level_index >= 0 and current_level_index < levels.size():
		current_level = null
		player = null
		level_orbs = 0
		for c in collected.size():
			collected[c] = false
		start_game()

func _on_next_level_button_pressed() -> void:
	current_level_index = min(current_level_index + 1, max_level_reached)
	if current_level_index >= 0 and current_level_index < levels.size():
		current_level = null
		player = null
		level_orbs = 0
		for c in collected.size():
			collected[c] = false
		start_game()


func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	update_ui()
