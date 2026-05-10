class_name VFX extends Node2D

@export var animation: String = "default"

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_playing: bool = false

# Called when the node enters the scene tree for the first time.
func start_vfx(_animation: String = "") -> void:
	if _animation != "":
		animation = _animation
	is_playing = true

func _process(_delta: float) -> void:
	if is_playing and not animated_sprite.is_playing():
		animated_sprite.play(animation)
		is_playing = false
		await animated_sprite.animation_finished
		queue_free()
