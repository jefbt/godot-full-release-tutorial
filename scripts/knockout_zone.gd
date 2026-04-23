# Dangerous area that knocks out any creature or player that enters it.
class_name KnockoutZone extends Area2D

# Option to not affect the player
@export var ignore_player: bool = false

# Handle bodies entering the knockout zone
func _on_body_entered(body: Node2D) -> void:
	if body is Player and not ignore_player:
		body.on_hit(self)
	elif body is Creature:
		body.knockout(self)
