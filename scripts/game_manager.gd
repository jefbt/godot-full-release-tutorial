extends Node

# Collision Layers:
#	1: ground
#	2: player
#	3: creatures
#	4: collectibles

@onready var animated_sprite_a: AnimatedSprite2D = $CanvasLayer/AnimatedSpriteA
@onready var animated_sprite_b: AnimatedSprite2D = $CanvasLayer/AnimatedSpriteB
@onready var animated_sprite_c: AnimatedSprite2D = $CanvasLayer/AnimatedSpriteC

@export var levels_path: String = "res://levels"

var levels: Array[String] = []

var current_level_index: int = 0
var current_level: Level = null
var player: Player = null
var collected: Array[bool] = [false, false, false]

func start_game() -> void:
	var level = load(levels[current_level_index]).instantiate()
	get_tree().root.add_child.call_deferred(level)

func set_level(level: Level) -> void:
	current_level = level

func collect(collectible: Collectible) -> void:
	if collectible.type == Collectible.Type.A:
		collected[0] = true
		animated_sprite_a.visible = true
	if collectible.type == Collectible.Type.B:
		collected[1] = true
		animated_sprite_b.visible = true
	if collectible.type == Collectible.Type.C:
		collected[2] = true
		animated_sprite_c.visible = true
	if current_level:
		current_level.on_collected(collectible)
	# TODO player collect vfx and sfx
	# TODO check all collectibles
	collectible.queue_free()
	pass


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.CORNFLOWER_BLUE)
	animated_sprite_a.visible = false
	animated_sprite_b.visible = false
	animated_sprite_c.visible = false
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
