class_name Orb extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var was_collected: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body is Player and not was_collected:
		was_collected = true
		animated_sprite.play("collect")
		GameManager.collect_orb(self)
