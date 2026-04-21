class_name KnockoutZone extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.on_hit(self)
	elif body is Creature:
		body.knockout(self)
