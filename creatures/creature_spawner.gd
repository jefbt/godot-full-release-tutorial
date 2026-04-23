class_name CreatureSpawner extends Node2D

@onready var spawned: Node2D = $Spawned
@onready var spawn_timer: Timer = $SpawnTimer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

const CREATURE_SIMPLE = preload("res://creatures/creature_simple.tscn")
const CREATURE_FOLLOW = preload("res://creatures/creature_follow.tscn")
const CREATURE_FLY = preload("res://creatures/creature_fly.tscn")

@export var type: Creature.Type = Creature.Type.SIMPLE
@export var max_creatures_spawned: int = 1
@export var start_flipped: bool = true
@export var spawn_time: float = 2.0

func _ready() -> void:
	animated_sprite.visible = false
	spawn(true)

func _process(_delta: float) -> void:
	if spawn_timer.is_stopped() and spawned.get_child_count() < max_creatures_spawned:
		spawn_timer.start(spawn_time)

func spawn(ignore_animation: bool = false) -> void:
	if not ignore_animation:
		animated_sprite.visible = true
		animated_sprite.play("default")
		await animated_sprite.animation_finished
		animated_sprite.visible = false
	var creature: Creature = null
	match (type):
		Creature.Type.FOLLOW:
			creature = CREATURE_FOLLOW.instantiate() as Creature
		Creature.Type.FLY:
			creature = CREATURE_FLY.instantiate() as Creature
		_:
			creature = CREATURE_SIMPLE.instantiate() as Creature
	if creature:
		creature.start_flipped = start_flipped
		spawned.add_child(creature)

func _on_spawn_timer_timeout() -> void:
	if spawned.get_child_count() < max_creatures_spawned:
		spawn()
