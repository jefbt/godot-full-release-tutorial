# Level finish trigger area. Becomes active when all collectibles are gathered,
# allowing the player to complete the level by entering the area.
class_name FinishLevel extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# State flags
var is_finished: bool = false
var can_finish: bool = false

# Enable level finishing when all collectibles are gathered
func on_get_all_collectibles() -> void:
	# TODO add a much more nice light around the place to show it's now finshable
	animated_sprite.play("finished")
	can_finish = true

# Trigger level completion when player enters finish area
func _on_body_entered(body: Node2D) -> void:
	if body is Player and not is_finished and can_finish:
		is_finished = true
		GameManager.on_level_finished()
