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
	pass

func start_game() -> void:
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
	update_ui()
	
func set_player(_player: Player) -> void:
	player = _player

func on_level_finished() -> void:
	total_time_taken += Time.get_ticks_msec() - level_start_time
	# TODO make level transition/loading screen etc
	current_level_index += 1
	
	if current_level_index >= 0 and current_level_index < levels.size():
		max_orbs += current_level.max_orbs
		current_level = null
		player = null
		total_orbs += level_orbs # fix this later
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

func _on_player_respawn_timer_timeout() -> void:
	respawn_player()
