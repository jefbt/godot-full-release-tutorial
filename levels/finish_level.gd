class_name FinishLevel extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var is_finished: bool = false
var can_finish: bool = false

func on_get_all_collectibles() -> void:
	animated_sprite.play("finished")
	can_finish = true

func _on_body_entered(body: Node2D) -> void:
	if body is Player and not is_finished and can_finish:
		is_finished = true
		GameManager.on_level_finished()
