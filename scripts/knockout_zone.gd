class_name KnockoutZone extends Area2D

@export var ignore_player: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body is Player and not ignore_player:
		body.on_hit(self)
	elif body is Creature:
		body.knockout(self)
